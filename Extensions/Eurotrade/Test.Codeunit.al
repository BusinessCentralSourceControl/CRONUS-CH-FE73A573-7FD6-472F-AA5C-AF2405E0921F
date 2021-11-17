codeunit 50050 Test
{
    trigger OnRun()var WSCategory: Record "LOGWS Category";
    PageSysId: Guid;
    PageId: Integer;
    TotalNoOfWSCategoryItems: Integer;
    ResultParams: Dictionary of[Text, Text];
    begin
        // Page Background Task Calculations
        if not Evaluate(PageId, Page.GetBackgroundParameters().Get('PageId'))then;
        if not Evaluate(PageSysId, Page.GetBackgroundParameters().Get('PageSysId'))then;
        case PageId of Page::"LOGWS Category Card": begin
            if WSCategory.GetBySystemId(PageSysId)then TotalNoOfWSCategoryItems:=GetTotalNoOfWSCategoryItems(WSCategory);
            ResultParams.Add('TotalNoOfWSCategoryItems', Format(TotalNoOfWSCategoryItems));
        end;
        end;
        Page.SetBackgroundTaskResult(ResultParams);
    end;
    var TempWSCategory: Record "LOGWS Category" temporary;
    ContinueQst: Label '\Do you want to continue?';
    ExcludeWSCategoryTreeMsg: Label 'WS Category ''%1'' incl. subordinated WS Categories will be excluded.';
    IncludeWSCategoryTreeMsg: Label 'WS Category ''%1'' incl. subordinated WS Categories will be included.';
    ItemRelationsSearchingTxt: Label 'Item Relations are being searched.';
    ItemsSearchingTxt: Label 'Items are being searched.';
    ItemSubstitutionsSearchingTxt: Label 'Item Substitutions are being searched.';
    RecordsCalculatingTxt: Label 'Records are being calculated. Status: #1';
    RemoveWSCategoryTreeMsg: Label 'WS Category ''%1'' incl. subordinated WS Categories will be removed.';
    StatusTxt: Label 'Status: #1';
    WSAssortmentItemsRecalculatedMsg: Label 'WS Assortment Items have been recalculated.';
    WSAssortmentItemsRecalculatingTxt: Label 'WS Assortment Items are being recalculated.';
    WSCategoryRelationsSearchingTxt: Label 'WS Category Relations are being searched.';
    WSCategoryTreeRemovingTxt: Label 'WS Category Tree is being removed.';
    procedure GetNoOfWSCategoryItems(WSCategory: Record "LOGWS Category")NoOfItems: Integer var DummyItem: Record Item;
    WSCategoryRelation2: Record "LOGWS Category Relation";
    WSCategoryRelation: Record "LOGWS Category Relation";
    WSCatItemDataMode: Enum "LOGWS WS Cat. Item Data Mode";
    begin
        WSCategoryRelation.SetRange("WS Category Code", WSCategory."Code Value");
        if WSCategoryRelation.FindSet()then repeat WSCategoryRelation2:=WSCategoryRelation;
                WSCategoryRelation2.FilterGroup(2);
                WSCategoryRelation2.SetRecFilter();
                WSCategoryRelation2.FilterGroup(0);
                NoOfItems+=GetWSCategoryItemData(DummyItem, WSCategoryRelation2, WSCatItemDataMode::Item, false);
            until WSCategoryRelation.Next() = 0;
    end;
    procedure GetStyleText(WSCategory: Record "LOGWS Category"): Text begin
        if WSCategory.Excluded then exit('Subordinate');
        if(WSCategory.Indentation = 0) or WSCategory."Has Children" then exit('Strong');
        exit('');
    end;
    procedure GetTotalNoOfWSCategoryItems(WSCategoryParm: Record "LOGWS Category"): Integer var WSCategory: Record "LOGWS Category";
    NoOfItems: Integer;
    begin
        WSCategory.SetRange("Parent Category", WSCategoryParm."Code Value");
        if WSCategory.FindSet()then begin
            repeat NoOfItems+=GetTotalNoOfWSCategoryItems(WSCategory);
            until WSCategory.Next() = 0;
            exit(NoOfItems + GetNoOfWSCategoryItems(WSCategoryParm));
        end
        else
            exit(GetNoOfWSCategoryItems(WSCategoryParm));
    end;
    procedure GetTotalWSCategoryItems(WSCategoryParm: Record "LOGWS Category";
    var FilterItem: Record Item)var WSCategory: Record "LOGWS Category";
    begin
        FilterItem.MarkedOnly(false);
        GetWSCategoryItems(WSCategoryParm, FilterItem);
        WSCategory.SetRange("Parent Category", WSCategoryParm."Code Value");
        if WSCategory.FindSet()then begin
            repeat GetTotalWSCategoryItems(WSCategory, FilterItem);
            until WSCategory.Next() = 0;
        end;
        FilterItem.MarkedOnly(true);
    end;
    procedure GetWSAssortmentItemRelationData(var Item: Record Item;
    var ItemRelation: Record "LOGWS Item Relation";
    IncludeData: Boolean)DataCount: Integer;
    var ItemFilter2: Record Item;
    ItemFilter: Record Item;
    ItemRelationFilter: Record "LOGWS Item Relation";
    Window: Dialog;
    begin
        if IncludeData then Window.Open(ItemRelationsSearchingTxt);
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        ItemFilter2.CopyFilters(Item);
        ItemRelationFilter.CopyFilters(ItemRelation);
        ItemFilter.SetRange("LOGWS Assortment Item", true);
        if ItemFilter.FindSet()then repeat ItemRelationFilter.SetRange("WS Item Rel. Assign. Type", ItemRelation."WS Item Rel. Assign. Type"::Item);
                ItemRelationFilter.SetRange("Assigned to No.", ItemFilter."No.");
                if ItemRelationFilter.FindSet()then repeat ItemFilter2.SetRange("No.", ItemRelationFilter."Item No.");
                        if not ItemFilter2.IsEmpty()then begin
                            DataCount+=1;
                            if IncludeData then begin
                                ItemRelation:=ItemRelationFilter;
                                if ItemRelation.Find()then ItemRelation.Mark(true);
                            end;
                        end;
                    until ItemRelationFilter.Next() = 0;
            until ItemFilter.Next() = 0;
        if IncludeData then begin
            ItemRelation.MarkedOnly(true);
            Window.Close();
        end;
    end;
    procedure GetWSAssortmentItemSubstitutionData(var Item: Record Item;
    var ItemSubstitution: Record "Item Substitution";
    IncludeData: Boolean)DataCount: Integer;
    var ItemFilter2: Record Item;
    ItemFilter: Record Item;
    ItemSubstitutionFilter: Record "Item Substitution";
    Window: Dialog;
    begin
        if IncludeData then Window.Open(ItemSubstitutionsSearchingTxt);
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        ItemFilter2.CopyFilters(Item);
        ItemSubstitutionFilter.CopyFilters(ItemSubstitution);
        ItemFilter.SetRange("LOGWS Assortment Item", true);
        if ItemFilter.FindSet()then repeat ItemSubstitutionFilter.SetRange(Type, ItemSubstitutionFilter.Type::Item);
                ItemSubstitutionFilter.SetRange("No.", ItemFilter."No.");
                ItemSubstitutionFilter.SetRange("Substitute Type", ItemSubstitutionFilter."Substitute Type"::Item);
                if ItemSubstitutionFilter.FindSet()then repeat ItemFilter2.SetRange("No.", ItemSubstitutionFilter."Substitute No.");
                        if not ItemFilter2.IsEmpty()then begin
                            DataCount+=1;
                            if IncludeData then begin
                                ItemSubstitution:=ItemSubstitutionFilter;
                                if ItemSubstitution.Find()then ItemSubstitution.Mark(true);
                            end;
                        end;
                    until ItemSubstitutionFilter.Next() = 0;
            until ItemFilter.Next() = 0;
        if IncludeData then begin
            ItemSubstitution.MarkedOnly(true);
            Window.Close();
        end;
    end;
    procedure GetWSCategoryItemData(var Item: Record Item;
    var WSCategoryRelation: Record "LOGWS Category Relation";
    DataMode: Enum "LOGWS WS Cat. Item Data Mode";
    IncludeData: Boolean)DataCount: Integer var ItemFilter: Record Item;
    ItemWSGrpRel: Record "LOGWS Item WS Grp. Rel.";
    WSCategoryRelationFilter: Record "LOGWS Category Relation";
    Window2: Dialog;
    Window: Dialog;
    RecCount: Integer;
    RecCounter: Integer;
    WindowText: Text;
    ProgressTime: Time;
    begin
        case DataMode of DataMode::Item: begin
            WindowText:=ItemsSearchingTxt;
        end;
        DataMode::WSCategory: begin
            WindowText:=WSCategoryRelationsSearchingTxt;
        end;
        DataMode::SetItemAssortmentFlag: begin
            WindowText:=WSAssortmentItemsRecalculatingTxt;
            // Clear exisiting flags
            ItemFilter.Reset();
            ItemFilter.SetCurrentKey("LOGWS Assortment Item");
            // ItemFilter.SetRange("LOGWS Assortment Item", true);
            ItemFilter.ModifyAll("LOGWS Assortment Item", false);
        // ItemFilter.Reset();
        // //ItemFilter.SetFilter("LOGWS No. of WS Cat. Rel.", '<>%1', 0);
        // ItemFilter.ModifyAll("LOGWS No. of WS Cat. Rel.", 0);
        // ItemFilter.Reset();
        // //ItemFilter.SetFilter("LOGWS No. of Item Subst.", '<>%1', 0);
        // ItemFilter.ModifyAll("LOGWS No. of Item Subst.", 0);
        // ItemFilter.Reset();
        // //ItemFilter.SetFilter("LOGWS No. of Item Relations", '<>%1', 0);
        // ItemFilter.ModifyAll("LOGWS No. of Item Relations", 0);
        end;
        end;
        if IncludeData then Window.Open(WindowText + ' ' + StatusTxt);
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        WSCategoryRelation.SetAutoCalcFields("WS Category Excluded");
        WSCategoryRelation.SetRange("WS Category Excluded", false);
        // Update status
        if IncludeData then Window.Update(1, WSCategoryRelationFilter.FieldCaption("WS Category Type") + ' ''' + Format(WSCategoryRelationFilter."WS Category Type"::Item) + '''');
        WSCategoryRelationFilter.Reset();
        WSCategoryRelationFilter.CopyFilters(WSCategoryRelation);
        WSCategoryRelationFilter.SetRange("WS Category Type", WSCategoryRelationFilter."WS Category Type"::Item);
        if WSCategoryRelationFilter.FindSet()then repeat ItemFilter.Reset();
                ItemFilter.CopyFilters(Item);
                ItemFilter.SetFilter("No.", WSCategoryRelationFilter."No. Filter");
                case DataMode of DataMode::Item: begin
                    if ItemFilter.FindSet()then repeat DataCount+=1;
                            if IncludeData then begin
                                Item:=ItemFilter;
                                if Item.Find()then Item.Mark(true);
                            end;
                        until ItemFilter.Next() = 0;
                end;
                DataMode::WSCategory: begin
                    if not ItemFilter.IsEmpty()then begin
                        DataCount+=1;
                        if IncludeData then begin
                            WSCategoryRelation:=WSCategoryRelationFilter;
                            if WSCategoryRelation.Find()then WSCategoryRelation.Mark(true);
                        end;
                    end;
                end;
                DataMode::SetItemAssortmentFlag: begin
                    SetWSAssortmentItem(ItemFilter);
                end;
                end;
            until WSCategoryRelationFilter.Next() = 0;
        // Update status
        if IncludeData then Window.Update(1, WSCategoryRelationFilter.FieldCaption("WS Category Type") + ' ''' + Format(WSCategoryRelationFilter."WS Category Type"::"WS Group") + '''');
        WSCategoryRelationFilter.Reset();
        WSCategoryRelationFilter.CopyFilters(WSCategoryRelation);
        WSCategoryRelationFilter.SetRange("WS Category Type", WSCategoryRelationFilter."WS Category Type"::"WS Group");
        if WSCategoryRelationFilter.FindSet()then repeat ItemWSGrpRel.SetCurrentKey("Item No.");
                ItemWSGrpRel.SetFilter("WS Group Code", WSCategoryRelationFilter."No. Filter");
                if ItemWSGrpRel.FindSet()then begin
                    if IncludeData then begin
                        Window2.Open(RecordsCalculatingTxt);
                        RecCount:=ItemWSGrpRel.Count();
                        ProgressTime:=Time();
                    end;
                    repeat if IncludeData then begin
                            RecCounter+=1;
                            if(ProgressTime < (Time() - 1000)) or (RecCounter = 1)then begin // Update every sec. or initial
                                ProgressTime:=Time();
                                Window2.Update(1, Round(RecCounter / RecCount * 100, 1));
                            end;
                        end;
                        if ItemWSGrpRel."Item No." <> '' then begin
                            ItemFilter.Reset();
                            ItemFilter.CopyFilters(Item);
                            ItemFilter.SetRange("No.", ItemWSGrpRel."Item No.");
                            if not ItemFilter.IsEmpty()then begin
                                case DataMode of DataMode::Item: begin
                                    DataCount+=1;
                                    if IncludeData then begin
                                        ItemFilter.FindFirst();
                                        Item:=ItemFilter;
                                        if Item.Find()then Item.Mark(true);
                                    end;
                                end;
                                DataMode::WSCategory: begin
                                    DataCount+=1;
                                    if IncludeData then begin
                                        WSCategoryRelation:=WSCategoryRelationFilter;
                                        if WSCategoryRelation.Find()then WSCategoryRelation.Mark(true);
                                    end;
                                end;
                                DataMode::SetItemAssortmentFlag: begin
                                    SetWSAssortmentItem(ItemFilter);
                                end;
                                end;
                            end;
                        end;
                        // Get distinct records
                        ItemWSGrpRel.SetRange("Item No.", ItemWSGrpRel."Item No.");
                        ItemWSGrpRel.FindLast();
                        ItemWSGrpRel.SetRange("Item No.");
                    until ItemWSGrpRel.Next() = 0;
                    if IncludeData then begin
                        Window2.Close();
                        RecCounter:=0;
                    end;
                end;
            until WSCategoryRelationFilter.Next() = 0;
        // Update status
        if IncludeData then Window.Update(1, WSCategoryRelationFilter.FieldCaption("WS Category Type") + ' ''' + Format(WSCategoryRelationFilter."WS Category Type"::"New Item") + '''');
        WSCategoryRelationFilter.Reset();
        WSCategoryRelationFilter.CopyFilters(WSCategoryRelation);
        WSCategoryRelationFilter.SetRange("WS Category Type", WSCategoryRelationFilter."WS Category Type"::"New Item");
        if WSCategoryRelationFilter.FindSet()then repeat ItemFilter.Reset();
                ItemFilter.CopyFilters(Item);
                ItemFilter.SetRange("LOGWS New Item", true);
                case DataMode of DataMode::Item: begin
                    if ItemFilter.FindSet()then repeat DataCount+=1;
                            if IncludeData then begin
                                Item:=ItemFilter;
                                if Item.Find()then Item.Mark(true);
                            end;
                        until ItemFilter.Next() = 0;
                end;
                DataMode::WSCategory: begin
                    if not ItemFilter.IsEmpty()then begin
                        DataCount+=1;
                        if IncludeData then begin
                            WSCategoryRelation:=WSCategoryRelationFilter;
                            if WSCategoryRelation.Find()then WSCategoryRelation.Mark(true);
                        end;
                    end;
                end;
                DataMode::SetItemAssortmentFlag: begin
                    SetWSAssortmentItem(ItemFilter);
                end;
                end;
            until WSCategoryRelationFilter.Next() = 0;
        // Update status
        if IncludeData then Window.Update(1, WSCategoryRelationFilter.FieldCaption("WS Category Type") + ' ''' + Format(WSCategoryRelationFilter."WS Category Type"::"Special Offer") + '''');
        WSCategoryRelationFilter.Reset();
        WSCategoryRelationFilter.CopyFilters(WSCategoryRelation);
        WSCategoryRelationFilter.SetRange("WS Category Type", WSCategoryRelationFilter."WS Category Type"::"Special Offer");
        if WSCategoryRelationFilter.FindSet()then repeat ItemFilter.Reset();
                ItemFilter.CopyFilters(Item);
                ItemFilter.SetRange("LOGWS Special Offer", true);
                case DataMode of DataMode::Item: begin
                    if ItemFilter.FindSet()then repeat DataCount+=1;
                            if IncludeData then begin
                                Item:=ItemFilter;
                                if Item.Find()then Item.Mark(true);
                            end;
                        until ItemFilter.Next() = 0;
                end;
                DataMode::WSCategory: begin
                    if not ItemFilter.IsEmpty()then begin
                        DataCount+=1;
                        if IncludeData then begin
                            WSCategoryRelation:=WSCategoryRelationFilter;
                            if WSCategoryRelation.Find()then WSCategoryRelation.Mark(true);
                        end;
                    end;
                end;
                DataMode::SetItemAssortmentFlag: begin
                    SetWSAssortmentItem(ItemFilter);
                end;
                end;
            until WSCategoryRelationFilter.Next() = 0;
        case DataMode of DataMode::Item: begin
            if IncludeData then Item.MarkedOnly(true);
        end;
        DataMode::WSCategory: begin
            if IncludeData then WSCategoryRelation.MarkedOnly(true);
        end;
        DataMode::SetItemAssortmentFlag: begin
            Message(WSAssortmentItemsRecalculatedMsg);
        end;
        end;
        if IncludeData then Window.Close();
    end;
    procedure GetWSCategoryItems(WSCategory: Record "LOGWS Category";
    var FilterItem: Record Item)var WSCategoryRelation: Record "LOGWS Category Relation";
    WSCatItemDataMode: Enum "LOGWS WS Cat. Item Data Mode";
    begin
        WSCategoryRelation.FilterGroup(2);
        WSCategoryRelation.SetRange("WS Category Code", WSCategory."Code Value");
        WSCategoryRelation.FilterGroup(0);
        GetWSCategoryItemData(FilterItem, WSCategoryRelation, WSCatItemDataMode::Item, true);
    end;
    procedure InheritWSCategoryExcludedToTree(WSCategoryParm: Record "LOGWS Category")var CurrWSCategory: Record "LOGWS Category";
    TempTempStack: Record TempStack temporary;
    WSCategory: Record "LOGWS Category";
    ConfirmMgt: Codeunit "Confirm Management";
    CurrWSCategoryId: RecordID;
    IncludeExcludeWSCategoryTreeTxt: Text;
    begin
        if WSCategoryParm.Excluded then IncludeExcludeWSCategoryTreeTxt:=ExcludeWSCategoryTreeMsg
        else
            IncludeExcludeWSCategoryTreeTxt:=IncludeWSCategoryTreeMsg;
        if not ConfirmMgt.GetResponseOrDefault(StrSubstNo(IncludeExcludeWSCategoryTreeTxt + ContinueQst, WSCategoryParm."Code Value"), true)then Error('');
        // Check if Parent not excluded
        if WSCategoryParm."Parent Category" <> '' then begin
            if WSCategory.Get(WSCategoryParm."Parent Category")then WSCategory.TestField(Excluded, false);
        end;
        WSCategory.SetRange("Parent Category", WSCategoryParm."Code Value");
        if WSCategory.FindSet()then repeat TempTempStack.Push(WSCategory.RecordId());
            until WSCategory.Next() = 0;
        while TempTempStack.Pop(CurrWSCategoryId)do begin
            CurrWSCategory.Get(CurrWSCategoryId);
            WSCategory.SetRange("Parent Category", CurrWSCategory."Code Value");
            if WSCategory.FindSet()then repeat TempTempStack.Push(WSCategory.RecordId());
                until WSCategory.Next() = 0;
            CurrWSCategory.Excluded:=WSCategoryParm.Excluded;
            CurrWSCategory.Modify();
        end;
    end;
    procedure IsChildCategory(ChildCode: Code[20];
    ParentCode: Code[20]): Boolean var WSCategory: Record "LOGWS Category";
    begin
        if WSCategory.Get(ChildCode)then begin
            if WSCategory."Parent Category" <> ParentCode then exit(IsChildCategory(WSCategory."Parent Category", ParentCode))
            else
                exit(true);
        end
        else
            exit(false);
    end;
    procedure MoveDownWSCategory(var WSCategoryParm: Record "LOGWS Category")var SiblingWSCategory: Record "LOGWS Category";
    CurrWSSorting: Integer;
    begin
        // Find closest sibling
        SiblingWSCategory.SetCurrentKey("Presentation Order");
        SiblingWSCategory.Get(WSCategoryParm."Code Value");
        SiblingWSCategory.SetRange("Parent Category", SiblingWSCategory."Parent Category");
        if SiblingWSCategory.Next(1) <> 0 then begin
            CurrWSSorting:=SiblingWSCategory."WS Sorting";
            SiblingWSCategory."WS Sorting":=WSCategoryParm."WS Sorting";
            SiblingWSCategory.Modify();
            WSCategoryParm."WS Sorting":=CurrWSSorting;
            WSCategoryParm.Modify();
            UpdateWSCategoryPresentationOrder();
        end;
    end;
    procedure MoveUpWSCategory(var WSCategoryParm: Record "LOGWS Category")var SiblingWSCategory: Record "LOGWS Category";
    CurrWSSorting: Integer;
    begin
        // Find sibling
        SiblingWSCategory.SetCurrentKey("Presentation Order");
        SiblingWSCategory.Get(WSCategoryParm."Code Value");
        SiblingWSCategory.SetRange("Parent Category", SiblingWSCategory."Parent Category");
        if SiblingWSCategory.Next(-1) <> 0 then begin
            CurrWSSorting:=SiblingWSCategory."WS Sorting";
            SiblingWSCategory."WS Sorting":=WSCategoryParm."WS Sorting";
            SiblingWSCategory.Modify();
            WSCategoryParm."WS Sorting":=CurrWSSorting;
            WSCategoryParm.Modify();
            UpdateWSCategoryPresentationOrder();
        end;
    end;
    procedure RecalcWSAssortmentItems()var DummyItem: Record Item;
    DummyWSCategoryRelation: Record "LOGWS Category Relation";
    WSCatItemDataMode: Enum "LOGWS WS Cat. Item Data Mode";
    begin
        GetWSCategoryItemData(DummyItem, DummyWSCategoryRelation, WSCatItemDataMode::SetItemAssortmentFlag, true);
    end;
    procedure RemoveWSCategoryInclTree(WSCategory: Record "LOGWS Category")var CurrWSCategory: Record "LOGWS Category";
    TempTempStack: Record TempStack temporary;
    ConfirmMgt: Codeunit "Confirm Management";
    WSDataIntegrityMgt: Codeunit "LOGWS Data Integrity Mgt.";
    Window: Dialog;
    CurrWSCategoryId: RecordID;
    begin
        if not ConfirmMgt.GetResponseOrDefault(StrSubstNo(RemoveWSCategoryTreeMsg + ContinueQst, WSCategory."Code Value"), true)then exit;
        Window.Open(WSCategoryTreeRemovingTxt);
        TempTempStack.Push(WSCategory.RecordId());
        while TempTempStack.Pop(CurrWSCategoryId)do begin
            CurrWSCategory.Get(CurrWSCategoryId);
            WSCategory.SetRange("Parent Category", CurrWSCategory."Code Value");
            if WSCategory.FindSet()then repeat TempTempStack.Push(WSCategory.RecordId());
                until WSCategory.Next() = 0;
            WSDataIntegrityMgt.SetCheckDataReferenceLimit(true);
            WSDataIntegrityMgt.CheckDataReference(CurrWSCategory, true, true);
            CurrWSCategory.Delete();
            WSDataIntegrityMgt.DeleteDataReference(CurrWSCategory);
        end;
        Window.Close();
    end;
    procedure SetWSAssortmentItem(var Item: Record Item)begin
        if Item.FindSet(true, false)then repeat // if Item."LOGWS No. of WS Cat. Rel." = 0 then
                Item.Validate("LOGWS Assortment Item", true);
                Item."LOGWS No. of WS Cat. Rel."+=1;
                Item.Modify();
            until Item.Next() = 0;
    end;
    procedure SetWSAssortmentOnItemRelations(ItemParm: Record Item)var Item: Record Item;
    ItemRelation: Record "LOGWS Item Relation";
    ItemSubstitution: Record "Item Substitution";
    begin
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        ItemSubstitution.SetRange(Type, ItemSubstitution.Type::Item);
        ItemSubstitution.SetRange("No.", ItemParm."No.");
        ItemSubstitution.SetRange("Substitute Type", ItemSubstitution."Substitute Type"::Item);
        if ItemSubstitution.FindSet()then begin
            repeat Item.SetRange("No.", ItemSubstitution."Substitute No.");
                if Item.FindFirst()then begin
                    Item."LOGWS Assortment Item":=ItemParm."LOGWS Assortment Item";
                    if Item."LOGWS Assortment Item" then Item."LOGWS No. of Item Subst."+=1
                    else
                        Item."LOGWS No. of Item Subst."-=1;
                    Item.Modify();
                end;
            until ItemSubstitution.Next() = 0;
        end;
        ItemRelation.SetRange("WS Item Rel. Assign. Type", ItemRelation."WS Item Rel. Assign. Type"::Item);
        ItemRelation.SetRange("Assigned to No.", ItemParm."No.");
        if ItemRelation.FindSet()then begin
            repeat Item.SetRange("No.", ItemRelation."Item No.");
                if Item.FindFirst()then begin
                    Item."LOGWS Assortment Item":=ItemParm."LOGWS Assortment Item";
                    if Item."LOGWS Assortment Item" then Item."LOGWS No. of Item Relations"+=1
                    else
                        Item."LOGWS No. of Item Relations"-=1;
                    Item.Modify();
                end;
            until ItemRelation.Next() = 0;
        end;
    end;
    procedure SetWSCategorySorting(var WSCategoryParm: Record "LOGWS Category")var SiblingWSCategory: Record "LOGWS Category";
    begin
        // Find last child
        SiblingWSCategory.SetCurrentKey("Presentation Order");
        SiblingWSCategory.SetRange("Parent Category", WSCategoryParm."Parent Category");
        SiblingWSCategory.SetFilter("Code Value", '<>%1', WSCategoryParm."Code Value");
        SiblingWSCategory.LockTable();
        if SiblingWSCategory.FindLast()then WSCategoryParm."WS Sorting":=SiblingWSCategory."WS Sorting" + 10
        else
            WSCategoryParm."WS Sorting":=10;
        WSCategoryParm.Modify();
    end;
    procedure UpdateWSCategoryPresentationOrder()begin
        PrepareTempWSCategory();
        UpdateWSCategoryPresentationOrderIterative();
    end;
    procedure UpdateWSCategorySorting()var WSCategory: Record "LOGWS Category";
    CurrWSSorting: Integer;
    begin
        // Reset sortings
        WSCategory.ModifyAll("WS Sorting", 0);
        WSCategory.SetCurrentKey("Presentation Order");
        WSCategory.SetRange("Parent Category", '');
        if WSCategory.FindSet(true, false)then repeat CurrWSSorting+=10;
                WSCategory."WS Sorting":=CurrWSSorting;
                WSCategory.Modify();
                UpdateWSCategorySorting(WSCategory);
            until WSCategory.Next() = 0;
    end;
    procedure UpdateWSCategorySorting(WSCategoryParm: Record "LOGWS Category")var WSCategory: Record "LOGWS Category";
    CurrWSSorting: Integer;
    begin
        WSCategory.SetCurrentKey("Presentation Order");
        WSCategory.SetRange("Parent Category", WSCategoryParm."Code Value");
        if WSCategory.FindSet(true, false)then repeat CurrWSSorting+=10;
                WSCategory."WS Sorting":=CurrWSSorting;
                WSCategory.Modify();
                UpdateWSCategorySorting(WSCategory);
            until WSCategory.Next() = 0;
    end;
    local procedure PrepareTempWSCategory()var WSCategory: Record "LOGWS Category";
    begin
        TempWSCategory.Reset();
        TempWSCategory.DeleteAll();
        // This is to cleanup wrong created blank entries created by an import mistake
        if WSCategory.Get('')then WSCategory.Delete();
        if WSCategory.FindSet()then repeat TempWSCategory.TransferFields(WSCategory);
                TempWSCategory.Insert();
            until WSCategory.Next() = 0;
    end;
    local procedure UpdateWSCategoryPresentationOrderIterative()var TempCurrWSCategory: Record "LOGWS Category" temporary;
    TempTempStack: Record TempStack temporary;
    WSCategory: Record "LOGWS Category";
    CurrWSCategoryId: RecordID;
    Excluded: Boolean;
    HasChildren: Boolean;
    Indentation: Integer;
    MainLevel: Integer;
    PresentationOrder: Integer;
    begin
        PresentationOrder:=0;
        TempCurrWSCategory.Copy(TempWSCategory, true);
        TempWSCategory.SetCurrentKey("Parent Category", "WS Sorting");
        TempWSCategory.Ascending(false);
        TempWSCategory.SetRange("Parent Category", '');
        if TempWSCategory.FindSet()then repeat TempTempStack.Push(TempWSCategory.RecordId());
            until TempWSCategory.Next() = 0;
        while TempTempStack.Pop(CurrWSCategoryId)do begin
            TempCurrWSCategory.Get(CurrWSCategoryId);
            HasChildren:=false;
            TempWSCategory.SetRange("Parent Category", TempCurrWSCategory."Code Value");
            if TempWSCategory.FindSet()then repeat TempTempStack.Push(TempWSCategory.RecordId());
                    HasChildren:=true;
                until TempWSCategory.Next() = 0;
            Indentation:=0;
            Excluded:=TempCurrWSCategory.Excluded;
            if TempCurrWSCategory."Parent Category" <> '' then begin
                TempWSCategory.Get(TempCurrWSCategory."Parent Category");
                Indentation:=TempWSCategory.Indentation + 1;
                if TempWSCategory.Excluded then Excluded:=TempWSCategory.Excluded;
            end;
            if Indentation = 0 then MainLevel+=1;
            PresentationOrder+=1;
            if(TempCurrWSCategory."Presentation Order" <> PresentationOrder) or (TempCurrWSCategory.Indentation <> Indentation) or (TempCurrWSCategory."Has Children" <> HasChildren) or (TempCurrWSCategory."Main Level" <> MainLevel) or (TempCurrWSCategory.Excluded <> Excluded)then begin
                WSCategory.Get(TempCurrWSCategory."Code Value");
                WSCategory."Presentation Order":=PresentationOrder;
                WSCategory.Indentation:=Indentation;
                WSCategory."Has Children":=HasChildren;
                WSCategory."Main Level":=MainLevel;
                WSCategory.Excluded:=Excluded;
                WSCategory.Modify();
                TempWSCategory.Get(TempCurrWSCategory."Code Value");
                TempWSCategory."Presentation Order":=PresentationOrder;
                TempWSCategory.Indentation:=Indentation;
                TempWSCategory."Has Children":=HasChildren;
                TempWSCategory."Main Level":=MainLevel;
                TempWSCategory.Excluded:=Excluded;
                TempWSCategory.Modify();
            end;
        end;
    end;
}
