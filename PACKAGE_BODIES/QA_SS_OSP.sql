--------------------------------------------------------
--  DDL for Package Body QA_SS_OSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_OSP" as
/* $Header: qltssopb.plb 120.1 2005/10/02 02:51:52 bso noship $ */


function are_osp_plans_applicable (
		P_Item_Number IN VARCHAR2 DEFAULT NULL,
		P_Supplier IN VARCHAR2 DEFAULT NULL,
		P_Wip_Entity_Name IN VARCHAR2 DEFAULT NULL,
		P_Po_Number IN VARCHAR2 DEFAULT NULL,
		P_Vendor_Item_Number IN VARCHAR2 DEFAULT NULL,
		P_Wip_Operation_Seq_Num IN NUMBER DEFAULT NULL,
		P_UOM_Name IN VARCHAR2 DEFAULT NULL,
		P_Production_Line IN VARCHAR2 DEFAULT NULL,
		P_Quantity_Ordered IN NUMBER DEFAULT NULL,
		P_Item_Revision IN VARCHAR2 DEFAULT NULL,
		P_Po_Release_Number IN NUMBER DEFAULT NULL,
		P_Organization_Id IN NUMBER DEFAULT NULL,
        P_Wip_Entity_Type IN NUMBER DEFAULT NULL)

	Return VARCHAR2

 IS
    Ctx qa_ss_const.Ctx_Table;
    p_category_id NUMBER;
    p_category VARCHAR2(240);

 BEGIN
    -- dont think icx validate session is needed here, becos this is
    -- a function called as part of wip's view definition
    -- check the above

        Ctx(qa_ss_const.Item) := P_Item_Number;
        Ctx(qa_ss_const.Vendor_Name) := P_Supplier;
        Ctx(qa_ss_const.Job_Name) := P_Wip_Entity_Name;
        Ctx(qa_ss_const.Po_Number) := P_Po_Number;
        Ctx(qa_ss_const.Vender_Item_Number) := P_Vendor_Item_Number;
			-- Typo vender in seed data
        Ctx(qa_ss_const.From_Op_Seq_Num) := to_char(P_Wip_Operation_Seq_Num);
        Ctx(qa_ss_const.UOM_Name) := P_UOM_Name;
        Ctx(qa_ss_const.Production_Line) := P_Production_Line;
        Ctx(qa_ss_const.Ordered_Quantity) := to_char(P_Quantity_Ordered);
        Ctx(qa_ss_const.Revision) := P_Item_Revision;
        Ctx(qa_ss_const.PO_Release_Num) := to_char(P_Po_Release_Number);
        Ctx(qa_ss_const.Organization_Id) := to_char(P_Organization_Id);
        qa_ss_core.get_item_category_val(
            p_org_id => p_organization_id,
            p_item_val => p_item_number,
            x_category_val => p_category,
            x_category_id => p_category_id);
        Ctx(qa_ss_const.item_category) := p_category;


            -- P_Wip_entity_type can be used for any checking if needed



        IF ( qa_ss_core.any_applicable_plans( Ctx, 100, P_Organization_Id))
	THEN
		return 'Y'; -- there are applicable plans
	ELSE
		return 'N'; -- No plans
	End If;

                        -- argument 100 is txn_num
    NULL;

 END are_osp_plans_applicable;
--------------------------------------------------------------------------

procedure osp_to_quality (
			PK1 IN VARCHAR2 DEFAULT NULL,
			PK2 IN VARCHAR2 DEFAULT NULL,
			PK3 IN VARCHAR2 DEFAULT NULL,
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL,
			c_outputs1 OUT NOCOPY VARCHAR2,
			c_outputs2 OUT NOCOPY VARCHAR2,
			c_outputs3 OUT NOCOPY VARCHAR2,
			c_outputs4 OUT NOCOPY VARCHAR2,
			c_outputs5 OUT NOCOPY VARCHAR2,
			c_outputs6 OUT NOCOPY VARCHAR2,
			c_outputs7 OUT NOCOPY VARCHAR2,
			c_outputs8 OUT NOCOPY VARCHAR2,
			c_outputs9 OUT NOCOPY VARCHAR2,
			c_outputs10 OUT NOCOPY VARCHAR2)

 IS


 BEGIN

            if (icx_sec.validateSession) then
                qa_ss_core.plan_list_frames(100, pk1, pk2, pk3, pk4, pk5, pk6, pk7, pk8, pk9, pk10);
            end if; -- end icx validate session

 EXCEPTION
        WHEN OTHERS THEN

            htp.p('Exception in procedure osp_to_quality');
            htp.p(SQLERRM);

 END osp_to_quality;

------------------------------------------------------------------------------------------

procedure default_osp_values (Ctx IN OUT NOCOPY qa_ss_const.Ctx_Table,
			Txn_Num IN NUMBER DEFAULT NULL,
			PK1 IN VARCHAR2 DEFAULT NULL,
			PK2 IN VARCHAR2 DEFAULT NULL,
			PK3 IN VARCHAR2 DEFAULT NULL,
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL,
            X_PO_AGENT_ID OUT NOCOPY NUMBER,
            X_Item_Id OUT NOCOPY NUMBER,
            X_PO_HEADER_ID OUT NOCOPY NUMBER,
            X_Wip_Entity_Type OUT NOCOPY NUMBER,
            X_Wip_Rep_Sch_Id OUT NOCOPY NUMBER,
            X_Po_Release_Id OUT NOCOPY NUMBER,
            X_Po_Line_Id OUT NOCOPY NUMBER,
            X_Line_Location_Id OUT NOCOPY NUMBER,
            X_Po_Distribution_Id OUT NOCOPY NUMBER,
            X_Wip_Entity_Id OUT NOCOPY NUMBER,
            X_Wip_Line_Id OUT NOCOPY NUMBER,
            X_Po_Shipment_Id OUT NOCOPY NUMBER,
	    X_Organization_Id OUT NOCOPY NUMBER)

 IS
    l_po_header_id NUMBER := NULL;
    l_po_release_id NUMBER := NULL;

    -- Po Header Id and release id columns are added to the below cursor
    -- only for the purpose of finding out po_agent_id
    CURSOR def_osp_cur IS
        SELECT Assembly_Item_Number, Vendor_Name, Wip_Entity_Name,
                     Base_Po_Num, Supplier_Item_Number,
                     Wip_Operation_Seq_Num, Assembly_Primary_UOM,
                     Wip_Line_code, Assembly_Quantity_Ordered,
                     Assembly_Item_Revision, Po_Release_Number,
                     Po_Header_Id, Po_Release_Id, Assembly_Item_Id,
                     Wip_Entity_Type, Wip_Repetitive_Schedule_Id,
                     Po_Line_Id, Line_Location_Id,
                     Po_Distribution_Id, Wip_Entity_Id,
                     Wip_Line_Id, Organization_Id
         FROM  WIP_ICX_OSP_WORKBENCH_V
            Where Po_Distribution_Id = to_number(PK1);

    CURSOR buyer1_cur(p_h_id IN NUMBER) IS
        SELECT AGENT_ID
        FROM PO_HEADERS_ALL
        where po_header_id = p_h_id;

    CURSOR buyer2_cur(p_rel_id IN NUMBER) IS
        SELECT AGENT_ID
         FROM PO_RELEASES_ALL
         where PO_RELEASE_ID = p_rel_id;

    -- R12 Project MOAC 4637896
    -- Completely removed cursor operating_unit_cur

 BEGIN

    -- R12 Project MOAC 4637896
    -- Completely removed set_org_context

    -- dont need icx validate session here, becos this is already done
    -- before this procedure is invoked, this is called starting from
    -- draw_table procedure and thro the generic procedure to default values


            -- only context element values are being selected
            -- this stmt does not select ids like wip_entity_id and so on
            -- the lov code should figure this
            -- if there are problems then we can modify the architecture
            -- to maybe pickout the ids here. test and see

            -- View Name is  WIP_ICX_OSP_WORKBENCH_V
            -- Use base_po_num column from this view
            -- TYPO "Vender"_Item_Number in seed data

            OPEN def_osp_cur;

            FETCH  def_osp_cur
            INTO Ctx(qa_ss_const.Item), Ctx(qa_ss_const.Vendor_Name), Ctx(qa_ss_const.Job_Name),
                 Ctx(qa_ss_const.Po_Number), Ctx(qa_ss_const.Vender_Item_Number),
                 Ctx(qa_ss_const.From_op_seq_num), Ctx(qa_ss_const.uom_name),
                 Ctx(qa_ss_const.Production_Line), Ctx(qa_ss_const.Ordered_Quantity),
                 Ctx(qa_ss_const.Revision), Ctx(qa_ss_const.Po_Release_Num),
                 l_po_header_id, l_po_release_id, X_Item_ID,
                 X_Wip_Entity_Type, X_Wip_Rep_Sch_Id,
                 X_Po_Line_Id, X_Line_Location_Id,
                 X_Po_Distribution_Id, X_Wip_Entity_ID,
                 X_Wip_Line_Id, X_Organization_Id ;

            CLOSE def_osp_cur;
                X_Po_Header_ID := l_po_header_id;
                X_Po_Release_ID := l_po_release_id;
                X_Po_Shipment_ID := NULL; -- not relevant in OSP

            -- Adding code to find buyer ie. Po_Agent_Id
                If (l_po_release_id is NOT NULL) Then
                    OPEN buyer2_cur(l_po_release_id);
                    FETCH buyer2_cur INTO  X_PO_AGENT_ID;
                    CLOSE buyer2_cur;
                Elsif (l_po_header_id is NOT NULL) Then
                    OPEN buyer1_cur(l_po_header_id);
                    FETCH buyer1_cur INTO X_PO_AGENT_ID;
                    CLOSE buyer1_cur;
                Else
                    X_PO_AGENT_ID := NULL;
                END IF; -- end buyer processing


 EXCEPTION
    WHEN OTHERS THEN
            IF def_osp_cur%ISOPEN THEN
                       CLOSE def_osp_cur;
            End If;
            IF buyer1_cur%ISOPEN THEN
                       CLOSE buyer1_cur;
            End If;
            IF buyer2_cur%ISOPEN THEN
                       CLOSE buyer2_cur;
            End If;
            htp.p('Exception in procedure default_osp_values');
            htp.p(SQLERRM);

 END default_osp_values;
----------------------------------------------------------------------------------------------
-- Below procedure to be called from qa_ss_core.plan_list_frames
procedure osp_plans (
            PK1 IN VARCHAR2 DEFAULT NULL,
			PK2 IN VARCHAR2 DEFAULT NULL,
			PK3 IN VARCHAR2 DEFAULT NULL,
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL )

IS
      P_Organization_Id NUMBER;
    Ctx qa_ss_const.Ctx_Table;

    CURSOR osp_cur IS
        SELECT Assembly_Item_Number, Vendor_Name, Wip_Entity_Name,
                     Base_Po_Num, Supplier_Item_Number,
                     Wip_Operation_Seq_Num, Assembly_Primary_UOM,
                     Wip_Line_code, Assembly_Quantity_Ordered,
                     Assembly_Item_Revision, Po_Release_Number,
                    Organization_Id
         FROM  WIP_ICX_OSP_WORKBENCH_V
            Where Po_Distribution_Id = to_number(PK1);
BEGIN

                -- View Name is WIP_ICX_OSP_WORKBENCH_V
                -- Use base_po_num column from this view
                -- Typo "Vender"_Item_Number in seed data
    if (icx_sec.validatesession) then
            OPEN osp_cur;

            FETCH osp_cur
            INTO Ctx(qa_ss_const.Item), Ctx(qa_ss_const.Vendor_Name), Ctx(qa_ss_const.Job_Name),
                 Ctx(qa_ss_const.Po_Number), Ctx(qa_ss_const.Vender_Item_Number),
                 Ctx(qa_ss_const.From_op_seq_num), Ctx(qa_ss_const.uom_name),
                 Ctx(qa_ss_const.Production_Line), Ctx(qa_ss_const.Ordered_Quantity),
                 Ctx(qa_ss_const.Revision), Ctx(qa_ss_const.Po_Release_Num),
                P_Organization_Id;

            CLOSE osp_cur;
            -- Now Ctx is populated. Also, populated P_Organization_Id above

            qa_ss_core.all_applicable_plans( Ctx, 100, P_Organization_Id, PK1, PK2,Pk3,
                        Pk4,PK5,PK6,PK7,PK8,PK9,PK10);

            -- This is all we do here. all_applicable_plans will call necessary procedures
            -- to take care from here onwards

    end if;-- end if for icx session
EXCEPTION
    WHEN OTHERS THEN
         IF osp_cur%ISOPEN THEN
                       CLOSE osp_cur;
            End If;
            htp.p('Exception in procedure qa_ss_osp.osp_plans');
            htp.p(SQLERRM);
END osp_plans;
----------------------------------------------------------------------------------------------

end qa_ss_osp;



/
