--------------------------------------------------------
--  DDL for Package Body QA_SS_SHIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_SHIP" as
/* $Header: qltssshb.plb 120.2 2006/02/09 05:43:20 saugupta noship $ */

function are_ship_plans_applicable (
		P_Po_Number IN VARCHAR2 DEFAULT NULL,
		P_Po_Line_Num IN VARCHAR2 DEFAULT NULL,
		P_Po_Release_Num IN VARCHAR2 DEFAULT NULL,
		P_Shipment_Num IN VARCHAR2 DEFAULT NULL,
		P_Location IN VARCHAR2 DEFAULT NULL,
		P_Supplier_Item IN VARCHAR2 DEFAULT NULL,
		P_Ord_Qty IN VARCHAR2 DEFAULT NULL,
		P_Uom_Name IN VARCHAR2 DEFAULT NULL,
		P_Vendor IN VARCHAR2 DEFAULT NULL,
		P_Vendor_Site IN VARCHAR2 DEFAULT NULL,
		P_Organization IN VARCHAR2 DEFAULT NULL,
		P_Item IN VARCHAR2 DEFAULT NULL,
		P_Item_Rev IN VARCHAR2 DEFAULT NULL,
		P_Item_Cat IN VARCHAR2 DEFAULT NULL
	)
    -- Ideally, i need one more parameter called p_organization_id
    -- do this next time to improve performance
    -- This needs change to view icx_pos_qa_shipments_V to pass extra argument
	Return VARCHAR2

 IS
    Ctx qa_ss_const.Ctx_Table;
    l_organization_id NUMBER := NULL;
    p_category_id NUMBER;
    p_category VARCHAR2(240);

    --anagarwa Wed Nov 14 12:30:30 PST 2001
    -- cursor modified to have corret case for Organizations

    -- Bug 4958773. SQL Repository Fix SQL ID: 15008412
    CURSOR org_cur(x_org_name IN VARCHAR2) IS
        SELECT
            organization_id
        FROM inv_organization_name_v
        WHERE lower(organization_name) = lower(x_org_name);
/*
        SELECT organization_id
        FROM ORG_ORGANIZATION_DEFINITIONS
        WHERE lower(organization_name) = lower(x_org_name);
*/

 BEGIN
    -- dont think icx validate session is needed here, becos this is
    -- a function called as part of po view definition
    -- check the above

        Ctx(qa_ss_const.Po_Number) := P_Po_Number;
        Ctx(qa_ss_const.Po_Line_Num) := P_Po_Line_Num;
        Ctx(qa_ss_const.Po_Release_Num) := P_Po_Release_Num;
        Ctx(qa_ss_const.Po_Shipment_Num) := P_Shipment_Num;
        Ctx(qa_ss_const.Ship_To_Location) := P_Location;
        Ctx(qa_ss_const.Vender_Item_Number) := P_Supplier_Item;
        Ctx(qa_ss_const.Ordered_Quantity) := P_Ord_Qty;
        Ctx(qa_ss_const.UOM_Name) := P_Uom_Name;
        Ctx(qa_ss_const.Vendor_Name) := P_Vendor;
        Ctx(qa_ss_const.Vendor_Site_code) := P_vendor_site;
        Ctx(qa_ss_const.Ship_To) := P_Organization;
        Ctx(qa_ss_const.Item) := P_Item;
        Ctx(qa_ss_const.Revision) := P_Item_Rev;

        If (P_Organization is NOT NULL) THEN
                OPEN org_cur(P_Organization);
                FETCH org_cur INTO l_organization_id;
                CLOSE org_cur;
        END IF;

        -- anagarwa Tue Nov 13 17:26:18 PST 2001
        -- PO calls this function in their view pos_po_qa_shipments_v .
        -- The last parameter they pass us is item_category. But the
        -- supplied value is incorrect as they do not check for the profile
        --  FND_PROFILE.VALUE('QA_CATEGORY_SET').
        -- To circumvent this dependency and to avoid changes in POS code,
        -- I'm adding following logic to derive item category at our end
        -- and ignore supplied value.
            qa_ss_core.get_item_category_val(
               p_org_id => l_Organization_Id,
               p_item_val => P_Item,
               x_category_val => p_category,
               x_category_id => p_category_id);
            Ctx(qa_ss_const.Item_Category) := p_category;

        IF ( qa_ss_core.any_applicable_plans( Ctx, 110, l_Organization_Id))
    	THEN
	       	return 'Y'; -- there are applicable plans
	   ELSE
	       	return 'N'; -- No plans
    	End If;

                        -- argument 110 is txn_num


 END are_ship_plans_applicable;
--------------------------------------------------------------------------

procedure ship_to_quality (
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
 if (icx_sec.validatesession) then

        qa_ss_core.plan_list_frames(110, PK1, PK2, PK3, PK4, PK5, PK6, PK7, PK8, PK9, PK10);


     end if; -- end icx validate session
 EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in procedure ship_to_quality');
            htp.p(SQLERRM);

 END ship_to_quality;

------------------------------------------------------------------------------------------

procedure default_ship_values (Ctx IN OUT NOCOPY qa_ss_const.Ctx_Table,
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
    -- fixing base_po_num below for Bug 1241396

    -- R12 Project MOAC 4637896
    -- Changed view ICX_POS_QA_SHIPMENTS_V to POS_PO_QA_SHIPMENTS_V
    CURSOR def_ship_cur IS
        SELECT BASE_PO_NUM, LINE_NUMBER,
              PO_RELEASE_ID, SHIPMENT_NUMBER,
              Ship_To_Location_Code, Supplier_Item_Number,
              Quantity_Ordered, Unit_of_Measure_code,
              supplier_name, supplier_site_code,
              ship_to_organization_name,
              Item_Number, Item_Revision,
              Category, PO_HEADER_ID, Item_ID,    -- already selected po_release_id above
              Po_Line_Id, Po_Shipment_Id, Ship_To_Organization_Id
         FROM  pos_po_qa_shipments_v
            Where Po_Shipment_Id = to_number(PK1);

   CURSOR rel_num_cur (x_rel_id IN NUMBER) IS
        SELECT RELEASE_NUM
        FROM PO_RELEASES_ALL
        WHERE PO_RELEASE_ID =  x_rel_id;

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

    OPEN def_ship_cur;
    FETCH def_ship_cur
            INTO Ctx(qa_ss_const.Po_Number),
            Ctx(qa_ss_const.Po_Line_Num),
            Ctx(qa_ss_const.Po_Release_Num),
            Ctx(qa_ss_const.Po_Shipment_Num),
            Ctx(qa_ss_const.Ship_To_Location),
            Ctx(qa_ss_const.Vender_Item_Number),
            Ctx(qa_ss_const.Ordered_Quantity),
            Ctx(qa_ss_const.UOM_Name),
            Ctx(qa_ss_const.Vendor_Name),
            Ctx(qa_ss_const.Vendor_Site_code),
            Ctx(qa_ss_const.Ship_To),
            Ctx(qa_ss_const.Item),
            Ctx(qa_ss_const.Revision),
            Ctx(qa_ss_const.Item_Category),
            l_po_header_id, X_Item_Id,
            X_Po_Line_Id, X_Po_Shipment_Id, X_Organization_Id;

            -- Assign l_po_release_id
            l_po_release_id := Ctx(qa_ss_const.Po_Release_Num);
            -- Dont change this. We do X_po_release_id assignment
            -- below
            X_Po_Header_ID := l_po_header_id; -- for sake of out variable
            X_Po_Release_ID := l_po_release_id;

            X_Wip_Entity_Type := NULL;  -- These have no value in Shipments
            X_Wip_Rep_Sch_Id := NULL;
            X_Line_Location_Id := NULL;
            X_Po_Distribution_Id := NULL;
            X_Wip_Entity_Id := NULL;
            X_Wip_Line_Id := NULL;

      CLOSE def_ship_cur;
       -- now ctx(release_num) actually has release id. lets get release num
                IF ( Ctx(qa_ss_const.Po_Release_Num) is NOT NULL) Then
                        OPEN rel_num_cur( Ctx(qa_ss_const.Po_Release_Num) );
                        FETCH rel_num_cur INTO  Ctx(qa_ss_const.Po_Release_Num);
                        CLOSE rel_num_cur;
                END IF;

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
            IF def_ship_cur%ISOPEN THEN
                       CLOSE def_ship_cur;
            End If;
            IF rel_num_cur%ISOPEN THEN
                       CLOSE rel_num_cur;
            End If;
            IF buyer1_cur%ISOPEN THEN
                       CLOSE buyer1_cur;
            End If;
            IF buyer2_cur%ISOPEN THEN
                       CLOSE buyer2_cur;
            End If;
            htp.p('Exception in procedure default_ship_values');
            htp.p(SQLERRM);

 END default_ship_values;
----------------------------------------------------------------------------------------------
procedure shipping_plans (
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

    -- fixing base_po_num for bug 1241396

    -- R12 Project MOAC 4637896
    -- Changed view ICX_POS_QA_SHIPMENTS_V to POS_PO_QA_SHIPMENTS_V
    CURSOR ship_cur IS
        SELECT BASE_PO_NUM, LINE_NUMBER,
              PO_RELEASE_ID, SHIPMENT_NUMBER,
              Ship_To_Location_Code, Supplier_Item_Number,
              Quantity_Ordered, Unit_of_Measure_code,
              supplier_name, supplier_site_code,
              ship_to_organization_name,
              Item_Number, Item_Revision,
              Category, Ship_To_Organization_ID
         FROM  pos_po_qa_shipments_v
            Where Po_Shipment_Id = to_number(PK1);

   CURSOR rel_num_cur (x_rel_id IN NUMBER) IS
        SELECT RELEASE_NUM
        FROM PO_RELEASES_ALL
        WHERE PO_RELEASE_ID =  x_rel_id;

BEGIN

IF (icx_sec.validateSession) THEN
         -- htp.p(' PK1 = ' || PK1); htp.nl;
            -- htp.p('PK2 = ' || PK2) ; htp.nl;
            -- htp.p('PK3 = ' || PK3); htp.nl;
            -- htp.p('PK10 = ' || PK10); htp.nl;
            OPEN ship_cur;
               -- htp.p('ship_cur opened'); htp.nl;
            FETCH ship_cur
            INTO Ctx(qa_ss_const.Po_Number),
            Ctx(qa_ss_const.Po_Line_Num),
            Ctx(qa_ss_const.Po_Release_Num),
            Ctx(qa_ss_const.Po_Shipment_Num),
            Ctx(qa_ss_const.Ship_To_Location),
            Ctx(qa_ss_const.Vender_Item_Number),
            Ctx(qa_ss_const.Ordered_Quantity),
            Ctx(qa_ss_const.UOM_Name),
            Ctx(qa_ss_const.Vendor_Name),
            Ctx(qa_ss_const.Vendor_Site_code),
            Ctx(qa_ss_const.Ship_To),
            Ctx(qa_ss_const.Item),
            Ctx(qa_ss_const.Revision),
            Ctx(qa_ss_const.Item_Category),
            P_Organization_Id;
             --   htp.p('ship_cur fetched successfully'); htp.nl;
            CLOSE ship_cur;
             --    htp.p('ship_cur closed successfully'); htp.nl;
            -- now ctx(release_num) actually has release id. lets get release num

                IF ( Ctx(qa_ss_const.Po_Release_Num) is NOT NULL) Then
                        -- htp.p('attempt to fetch release num'); htp.nl;
                        OPEN rel_num_cur( Ctx(qa_ss_const.Po_Release_Num) );
                        FETCH rel_num_cur INTO  Ctx(qa_ss_const.Po_Release_Num);
                        CLOSE rel_num_cur;
                        -- htp.p('successful rel num fetch'); htp.nl;
                END IF;
            -- Now Ctx is populated. Also, populated P_Organization_Id above
             --   htp.p('before call to all applicable plans'); htp.nl;
            qa_ss_core.all_applicable_plans( Ctx, 110, P_Organization_Id, PK1, PK2,Pk3,
                        Pk4,PK5,PK6,PK7,PK8,PK9,PK10);
              --  htp.p('after call to all_applicable_plans'); htp.nl;

END IF; -- end icx validate session

EXCEPTION
    WHEN OTHERS THEN
            IF ship_cur%ISOPEN THEN
                       CLOSE ship_cur;
            End If;
             IF rel_num_cur%ISOPEN THEN
                       CLOSE rel_num_cur;
            End If;

            htp.p('Exception in procedure qa_ss_ship.shipping plans');
            htp.p(SQLERRM);


END  shipping_plans;
 ----------------------------------------------------------------------------------------------



end qa_ss_ship;


/
