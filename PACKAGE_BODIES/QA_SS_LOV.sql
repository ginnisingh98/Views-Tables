--------------------------------------------------------
--  DDL for Package Body QA_SS_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_LOV" as
/* $Header: qltsslvb.plb 120.2 2006/02/06 00:34:22 saugupta noship $ */

--
--		PRIVATE FUNCTIONS AND PROCEDURES HERE
--

  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_Comp_Revision (
			    plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL )
	Return VARCHAR2
    IS
    BEGIN
       RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------

function Q_Comp_Subinventory (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        pos NUMBER;
        dep_err BOOLEAN;
        e_value VARCHAR2(150);
        e_id NUMBER;
        sql_stmt VARCHAR2(32000);

    BEGIN

                -- Construct the sql (hardcoded)
                sql_stmt := 'SELECT SECONDARY_INVENTORY_NAME, DESCRIPTION '
                            || ' FROM MTL_SECONDARY_INVENTORIES '
                            || ' WHERE Organization_id = :parameter.org_id '
                            || ' And nvl(disable_date, sysdate+1) > sysdate '
                            || ' order by secondary_inventory_name';

                Return sql_stmt;

        -- return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Comp_subinventory');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_Comp_UOM (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
 IS
    BEGIN
       RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------

function Q_Customers (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        pos NUMBER;
        dep_err BOOLEAN;
        e_value VARCHAR2(150);
        e_id NUMBER;
        sql_stmt VARCHAR2(32000);
    BEGIN
-- Bug 5003509. SQL Repository Fix. Obsoleted the function
/*
       sql_stmt := 'Select Customer_name, customer_Number '
                    || ' From qa_customers_lov_v '
                    || ' where status = ''A'' and '
                    || ' nvl(customer_prospect_code, ''CUSTOMER'') = ''CUSTOMER'' order by '
                    || ' customer_number';

       Return sql_stmt;
*/
           return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Customers');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Department (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        pos NUMBER;
        dep_err BOOLEAN;
        e_value VARCHAR2(150);
        e_id NUMBER;
        sql_stmt VARCHAR2(32000);
    BEGIN
        sql_stmt := 'Select department_code department, description '
                    || ' From bom_departments_val_v '
                    || ' where organization_id = :parameter.org_id '
                    || ' order by department_code';

        Return sql_stmt;


        -- return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Department');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_From_Op_Seq_Num (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
 BEGIN
   RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------

function Q_Line (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        sql_stmt VARCHAR2(32000);
    BEGIN
        sql_stmt := 'SELECT wl.line_code, wl.description '
                    || ' From wip_lines_val_v wl '
                    || ' where wl.organization_id = :parameter.org_id '
                    || ' order by wl.line_code';

        Return sql_stmt;
        -- return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Line');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Lot_Number (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS

    BEGIN
	-- not supported here
	-- there is nothing like :mtl_trx_line.transaction_temp_id
	-- equivalent in selfservice
        return 'DEP_ERROR';
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Lot_Number');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Po_Headers (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL )
	Return VARCHAR2
     IS
        sql_stmt VARCHAR2(32000);
    BEGIN
-- Bug 5003509. SQL Repository Fix. Obsoleted the function
/*
           sql_stmt := 'Select segment1, type_name '
                        || ' From po_pos_val_v '
                        || ' order by segment1';

           Return sql_stmt;
*/
        return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Po_Headers');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_Po_Lines (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
    BEGIN
       RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_Po_Release_Nums (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
    BEGIN
      RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_Po_Shipments (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
    BEGIN
       RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------

function Q_Project (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        sql_stmt VARCHAR2(32000);
    BEGIN
/*
mtl_project_v changed to pjm_projects_all_v (selects from both pjm enabled and
non-pjm enabled orgs).
rkaza, 11/10/2001.
*/
-- Bug 5003509. SQL Repository Fix. Obsoleted the function
/*
        sql_stmt := 'SELECT project_number, project_name '
                    || ' FROM pjm_projects_all_v '
                    || ' Order By project_number ';

        Return sql_stmt;
*/
        return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Project');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Receipt_Nums (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        sql_stmt VARCHAR2(32000);
    BEGIN
-- Bug 5003509. SQL Repository Fix. Obsoleted the function
/*
	sql_stmt :=
	'SELECT DISTINCT RCVSH.RECEIPT_NUM, POV.VENDOR_NAME
 	 FROM  RCV_SHIPMENT_HEADERS RCVSH, PO_VENDORS POV, RCV_TRANSACTIONS RT
	 WHERE RCVSH.RECEIPT_SOURCE_CODE = ''VENDOR'' AND
	       RCVSH.VENDOR_ID = POV.VENDOR_ID AND
	       RT.SHIPMENT_HEADER_ID = RCVSH.SHIPMENT_HEADER_ID';

            return sql_stmt;
*/
        return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Receipt_Nums');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Resource (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        sql_stmt VARCHAR2(32000);
    BEGIN
          sql_stmt := 'SELECT resource_code Resource, description Description '
                        || ' From BOM_Resources_Val_V '
                        || ' Where organization_id = :parameter.org_id '
                        || ' Order by resource_code ';

          Return sql_stmt;
        -- return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Resource');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_Revision (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
  BEGIN
     RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------

function Q_Rma_Number (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
	sql_stmt VARCHAR2(32000);
    BEGIN
	-- Order Management
-- Bug 5003509. SQL Repository Fix. Obsoleted the function
/*
	sql_stmt := 'SELECT to_char(SH.ORDER_NUMBER), SOT.NAME '
                    || ' FROM SO_ORDER_TYPES SOT, OE_ORDER_HEADERS SH, '
                    || ' QA_CUSTOMERS_LOV_V RC '
                    || ' WHERE sh.order_type_id = sot.order_type_id and '
                    || ' sh.sold_to_org_id = rc.customer_id and '
                    || ' sh.order_category_code in (''RETURN'',''MIXED'') ';
        RETURN sql_stmt;
*/
        return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Rma_Number');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Serial_Number (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS

    BEGIN
	-- not in selfservice - look at lot num for similar comment
        return 'DEP_ERROR';
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Serial_Number');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Sales_Orders (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
	sql_stmt VARCHAR2(32000);
    BEGIN
	-- Order Management changes
-- Bug 5003509. SQL Repository Fix. Obsoleted the function
/*
	sql_stmt := 'SELECT to_char(SH.ORDER_NUMBER), SOT.NAME '
                    || ' FROM SO_ORDER_TYPES SOT, OE_ORDER_HEADERS SH, '
                    || ' QA_CUSTOMERS_LOV_V RC '
                    || ' WHERE sh.order_type_id = sot.order_type_id and '
                    || ' sh.sold_to_org_id = rc.customer_id and '
                    || ' sh.order_category_code in (''ORDER'',''MIXED'') ';
        RETURN sql_stmt;
*/
        return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Sales_Orders');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Subinventory (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
	sql_stmt VARCHAR2(32000);
    BEGIN
	  sql_stmt := 'SELECT Secondary_Inventory_Name, Description '
		     || ' FROM mtl_secondary_inventories '
		     || ' WHERE organization_id = :parameter.org_id '
		     || ' AND NVL(disable_date, sysdate+1) > sysdate '
		     || ' ORDER BY SECONDARY_INVENTORY_NAME ';

	  RETURN sql_stmt;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Subinventory');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_To_Op_Seq_Num (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
  BEGIN
       RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_UOM (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
  BEGIN
     RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------

function Q_Vendors (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL )
	Return VARCHAR2
     IS
        sql_stmt VARCHAR2(32000);
    BEGIN
-- Bug 5003509. SQL Repository Fix. Obsoleted the function
/*
            sql_stmt := 'SELECT vendor_name, segment1 '
                        || ' FROM po_vendors '
                        || ' order by vendor_name ';
             Return sql_stmt;
*/
         return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Vendors');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

function Q_Job (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        sql_stmt VARCHAR2(32000);
    BEGIN

	-- #2382432
	-- Changed the view to WIP_DISCRETE_JOBS_ALL_V instead of
	-- earlier wip_open_discrete_jobs_val_v
	-- rkunchal Sun Jun 30 22:59:11 PDT 2002

            sql_stmt := 'SELECT wip_entity_name, description '
                        || ' From wip_discrete_jobs_all_v '
                        || ' where organization_id = :parameter.org_id '
                        || ' order by wip_entity_name ';

             Return sql_stmt;
        -- return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Job');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------
  --
  -- Bug 5003509. R12 Performance fix. Obsoleted the function.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --

function Q_Task (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
    BEGIN
       RETURN NULL;
    END;
 -------------------------------------------------------------------------------------------
function Q_Item (
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2
     IS
        sql_stmt VARCHAR2(32000);
    BEGIN
       sql_stmt := 'SELECT concatenated_segments, description '
                    || ' From mtl_system_items_b_kfv '
                    || ' where organization_id = :parameter.org_id '
                    || ' order by concatenated_segments ';
      Return sql_stmt;

        -- return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package Q_Item');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------

--
--			PUBLIC FUNCTIONS AND PROCEDURES BELOW AREA
--

procedure gen_list (
vchar_id IN qa_chars.char_id%TYPE,
rnumb IN NUMBER,
cnumb IN NUMBER,
find1 IN VARCHAR2
		)

IS
    xyz VARCHAR2(20000);
    find_str VARCHAR2(2000);
BEGIN
    if (icx_sec.validatesession) then

        find_str := wfa_html.conv_special_url_chars(find1);

        xyz := 'qa_ss_lov.Lov_Header?vchar_id='||vchar_id
		||'&' 	|| 'rnumb='||rnumb
		||'&'  	||'cnumb='||cnumb
		||'&'	|| 'find_str=' || find_str;


		htp.p('<HTML>');
		htp.p('<HEAD>');
		htp.p('<SCRIPT LANGUAGE="JavaScript">');
		htp.p('</SCRIPT>');
		htp.p('</HEAD>');
		htp.p('<FRAMESET ROWS="70,*">');
		htp.p('<FRAME NAME="LOVHeader" SRC="'||xyz|| '">');
		htp.p('<FRAME NAME="LOVValues" SRC="qa_ss_lov.Lov_Values">');
		htp.p('</FRAMESET>');
		htp.p('</HTML>');


    end if; -- end icx session

EXCEPTION

	WHEN OTHERS THEN
		htp.p('Exception in procedure gen_list');
		htp.p(SQLERRM);

END gen_list;
--------------------------------------------------------------------------------------

procedure LOV_Header  (
			vchar_id IN qa_chars.char_id%TYPE,
			rnumb IN NUMBER,
			cnumb IN NUMBER,
			find_str IN VARCHAR2
		)

IS
V_Prompt VARCHAR2(30);
msg VARCHAR2(2000);
l_language_code VARCHAR2(30);
BEGIN
    if (icx_sec.validatesession) then
        fnd_message.clear;
        l_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

         htp.p('<HTML>');
        htp.p('<HEAD>');
	htp.p('<SCRIPT LANGUAGE="JavaScript">');
	htp.p('function Lov_Check(rnumb, strow, lastrow)
		{
        document.LOVHeader.x_txn_num.value = parent.opener.document.HiddenRSMDF.x_txn_num.value;
        document.LOVHeader.x_wip_entity_type.value = parent.opener.document.HiddenRSMDF.x_wip_entity_type.value;
        document.LOVHeader.x_wip_rep_sch_id.value = parent.opener.document.HiddenRSMDF.x_wip_rep_sch_id.value;
        document.LOVHeader.x_po_header_id.value = parent.opener.document.HiddenRSMDF.x_po_header_id.value;
        document.LOVHeader.x_po_release_id.value = parent.opener.document.HiddenRSMDF.x_po_release_id.value;
        document.LOVHeader.x_po_line_id.value = parent.opener.document.HiddenRSMDF.x_po_line_id.value;
        document.LOVHeader.x_line_location_id.value = parent.opener.document.HiddenRSMDF.x_line_location_id.value;
        document.LOVHeader.x_po_distribution_id.value = parent.opener.document.HiddenRSMDF.x_po_distribution_id.value;
        document.LOVHeader.x_item_id.value = parent.opener.document.HiddenRSMDF.x_item_id.value;
        document.LOVHeader.x_wip_entity_id.value = parent.opener.document.HiddenRSMDF.x_wip_entity_id.value;
        document.LOVHeader.x_wip_line_id.value = parent.opener.document.HiddenRSMDF.x_wip_line_id.value;
        document.LOVHeader.x_po_shipment_id.value = parent.opener.document.HiddenRSMDF.x_po_shipment_id.value;

	document.LOVHeader.start_row.value = strow;
	document.LOVHeader.p_end_row.value = lastrow;
        document.LOVHeader.Flag.value = 1; //indicator to lov_values procedure
        document.LOVHeader.orgz_id.value = parent.opener.document.RSMDF.orgz_id.value;
        document.LOVHeader.plan_id_i.value = parent.opener.document.RSMDF.hid_planid.value;
		// copy values to hidden form elements
		 document.LOVHeader.p1.value = parent.opener.document.RSMDF.p_col1[rnumb].value;
 document.LOVHeader.p2.value = parent.opener.document.RSMDF.p_col2[rnumb].value;
 document.LOVHeader.p3.value = parent.opener.document.RSMDF.p_col3[rnumb].value;
 document.LOVHeader.p4.value = parent.opener.document.RSMDF.p_col4[rnumb].value;
 document.LOVHeader.p5.value = parent.opener.document.RSMDF.p_col5[rnumb].value;
 document.LOVHeader.p6.value = parent.opener.document.RSMDF.p_col6[rnumb].value;
 document.LOVHeader.p7.value = parent.opener.document.RSMDF.p_col7[rnumb].value;
 document.LOVHeader.p8.value = parent.opener.document.RSMDF.p_col8[rnumb].value;
 document.LOVHeader.p9.value = parent.opener.document.RSMDF.p_col9[rnumb].value;
 document.LOVHeader.p10.value = parent.opener.document.RSMDF.p_col10[rnumb].value;
 document.LOVHeader.p11.value = parent.opener.document.RSMDF.p_col11[rnumb].value;
 document.LOVHeader.p12.value = parent.opener.document.RSMDF.p_col12[rnumb].value;
 document.LOVHeader.p13.value = parent.opener.document.RSMDF.p_col13[rnumb].value;
 document.LOVHeader.p14.value = parent.opener.document.RSMDF.p_col14[rnumb].value;
 document.LOVHeader.p15.value = parent.opener.document.RSMDF.p_col15[rnumb].value;
 document.LOVHeader.p16.value = parent.opener.document.RSMDF.p_col16[rnumb].value;
 document.LOVHeader.p17.value = parent.opener.document.RSMDF.p_col17[rnumb].value;
 document.LOVHeader.p18.value = parent.opener.document.RSMDF.p_col18[rnumb].value;
 document.LOVHeader.p19.value = parent.opener.document.RSMDF.p_col19[rnumb].value;
 document.LOVHeader.p20.value = parent.opener.document.RSMDF.p_col20[rnumb].value;
 document.LOVHeader.p21.value = parent.opener.document.RSMDF.p_col21[rnumb].value;
 document.LOVHeader.p22.value = parent.opener.document.RSMDF.p_col22[rnumb].value;
 document.LOVHeader.p23.value = parent.opener.document.RSMDF.p_col23[rnumb].value;
 document.LOVHeader.p24.value = parent.opener.document.RSMDF.p_col24[rnumb].value;
 document.LOVHeader.p25.value = parent.opener.document.RSMDF.p_col25[rnumb].value;
 document.LOVHeader.p26.value = parent.opener.document.RSMDF.p_col26[rnumb].value;
 document.LOVHeader.p27.value = parent.opener.document.RSMDF.p_col27[rnumb].value;
 document.LOVHeader.p28.value = parent.opener.document.RSMDF.p_col28[rnumb].value;
 document.LOVHeader.p29.value = parent.opener.document.RSMDF.p_col29[rnumb].value;
 document.LOVHeader.p30.value = parent.opener.document.RSMDF.p_col30[rnumb].value;
 document.LOVHeader.p31.value = parent.opener.document.RSMDF.p_col31[rnumb].value;
 document.LOVHeader.p32.value = parent.opener.document.RSMDF.p_col32[rnumb].value;
 document.LOVHeader.p33.value = parent.opener.document.RSMDF.p_col33[rnumb].value;
 document.LOVHeader.p34.value = parent.opener.document.RSMDF.p_col34[rnumb].value;
 document.LOVHeader.p35.value = parent.opener.document.RSMDF.p_col35[rnumb].value;
 document.LOVHeader.p36.value = parent.opener.document.RSMDF.p_col36[rnumb].value;
 document.LOVHeader.p37.value = parent.opener.document.RSMDF.p_col37[rnumb].value;
 document.LOVHeader.p38.value = parent.opener.document.RSMDF.p_col38[rnumb].value;
 document.LOVHeader.p39.value = parent.opener.document.RSMDF.p_col39[rnumb].value;
 document.LOVHeader.p40.value = parent.opener.document.RSMDF.p_col40[rnumb].value;
 document.LOVHeader.p41.value = parent.opener.document.RSMDF.p_col41[rnumb].value;
 document.LOVHeader.p42.value = parent.opener.document.RSMDF.p_col42[rnumb].value;
 document.LOVHeader.p43.value = parent.opener.document.RSMDF.p_col43[rnumb].value;
 document.LOVHeader.p44.value = parent.opener.document.RSMDF.p_col44[rnumb].value;
 document.LOVHeader.p45.value = parent.opener.document.RSMDF.p_col45[rnumb].value;
 document.LOVHeader.p46.value = parent.opener.document.RSMDF.p_col46[rnumb].value;
 document.LOVHeader.p47.value = parent.opener.document.RSMDF.p_col47[rnumb].value;
 document.LOVHeader.p48.value = parent.opener.document.RSMDF.p_col48[rnumb].value;
 document.LOVHeader.p49.value = parent.opener.document.RSMDF.p_col49[rnumb].value;
 document.LOVHeader.p50.value = parent.opener.document.RSMDF.p_col50[rnumb].value;
 document.LOVHeader.p51.value = parent.opener.document.RSMDF.p_col51[rnumb].value;
 document.LOVHeader.p52.value = parent.opener.document.RSMDF.p_col52[rnumb].value;
 document.LOVHeader.p53.value = parent.opener.document.RSMDF.p_col53[rnumb].value;
 document.LOVHeader.p54.value = parent.opener.document.RSMDF.p_col54[rnumb].value;
 document.LOVHeader.p55.value = parent.opener.document.RSMDF.p_col55[rnumb].value;
 document.LOVHeader.p56.value = parent.opener.document.RSMDF.p_col56[rnumb].value;
 document.LOVHeader.p57.value = parent.opener.document.RSMDF.p_col57[rnumb].value;
 document.LOVHeader.p58.value = parent.opener.document.RSMDF.p_col58[rnumb].value;
 document.LOVHeader.p59.value = parent.opener.document.RSMDF.p_col59[rnumb].value;
 document.LOVHeader.p60.value = parent.opener.document.RSMDF.p_col60[rnumb].value;
 document.LOVHeader.p61.value = parent.opener.document.RSMDF.p_col61[rnumb].value;
 document.LOVHeader.p62.value = parent.opener.document.RSMDF.p_col62[rnumb].value;
 document.LOVHeader.p63.value = parent.opener.document.RSMDF.p_col63[rnumb].value;
 document.LOVHeader.p64.value = parent.opener.document.RSMDF.p_col64[rnumb].value;
 document.LOVHeader.p65.value = parent.opener.document.RSMDF.p_col65[rnumb].value;
 document.LOVHeader.p66.value = parent.opener.document.RSMDF.p_col66[rnumb].value;
 document.LOVHeader.p67.value = parent.opener.document.RSMDF.p_col67[rnumb].value;
 document.LOVHeader.p68.value = parent.opener.document.RSMDF.p_col68[rnumb].value;
 document.LOVHeader.p69.value = parent.opener.document.RSMDF.p_col69[rnumb].value;
 document.LOVHeader.p70.value = parent.opener.document.RSMDF.p_col70[rnumb].value;
 document.LOVHeader.p71.value = parent.opener.document.RSMDF.p_col71[rnumb].value;
 document.LOVHeader.p72.value = parent.opener.document.RSMDF.p_col72[rnumb].value;
 document.LOVHeader.p73.value = parent.opener.document.RSMDF.p_col73[rnumb].value;
 document.LOVHeader.p74.value = parent.opener.document.RSMDF.p_col74[rnumb].value;
 document.LOVHeader.p75.value = parent.opener.document.RSMDF.p_col75[rnumb].value;
 document.LOVHeader.p76.value = parent.opener.document.RSMDF.p_col76[rnumb].value;
 document.LOVHeader.p77.value = parent.opener.document.RSMDF.p_col77[rnumb].value;
 document.LOVHeader.p78.value = parent.opener.document.RSMDF.p_col78[rnumb].value;
 document.LOVHeader.p79.value = parent.opener.document.RSMDF.p_col79[rnumb].value;
 document.LOVHeader.p80.value = parent.opener.document.RSMDF.p_col80[rnumb].value;
 document.LOVHeader.p81.value = parent.opener.document.RSMDF.p_col81[rnumb].value;
 document.LOVHeader.p82.value = parent.opener.document.RSMDF.p_col82[rnumb].value;
 document.LOVHeader.p83.value = parent.opener.document.RSMDF.p_col83[rnumb].value;
 document.LOVHeader.p84.value = parent.opener.document.RSMDF.p_col84[rnumb].value;
 document.LOVHeader.p85.value = parent.opener.document.RSMDF.p_col85[rnumb].value;
 document.LOVHeader.p86.value = parent.opener.document.RSMDF.p_col86[rnumb].value;
 document.LOVHeader.p87.value = parent.opener.document.RSMDF.p_col87[rnumb].value;
 document.LOVHeader.p88.value = parent.opener.document.RSMDF.p_col88[rnumb].value;
 document.LOVHeader.p89.value = parent.opener.document.RSMDF.p_col89[rnumb].value;
 document.LOVHeader.p90.value = parent.opener.document.RSMDF.p_col90[rnumb].value;
 document.LOVHeader.p91.value = parent.opener.document.RSMDF.p_col91[rnumb].value;
 document.LOVHeader.p92.value = parent.opener.document.RSMDF.p_col92[rnumb].value;
 document.LOVHeader.p93.value = parent.opener.document.RSMDF.p_col93[rnumb].value;
 document.LOVHeader.p94.value = parent.opener.document.RSMDF.p_col94[rnumb].value;
 document.LOVHeader.p95.value = parent.opener.document.RSMDF.p_col95[rnumb].value;
 document.LOVHeader.p96.value = parent.opener.document.RSMDF.p_col96[rnumb].value;
 document.LOVHeader.p97.value = parent.opener.document.RSMDF.p_col97[rnumb].value;
 document.LOVHeader.p98.value = parent.opener.document.RSMDF.p_col98[rnumb].value;
 document.LOVHeader.p99.value = parent.opener.document.RSMDF.p_col99[rnumb].value;
 document.LOVHeader.p100.value = parent.opener.document.RSMDF.p_col100[rnumb].value;
 document.LOVHeader.p101.value = parent.opener.document.RSMDF.p_col101[rnumb].value;
 document.LOVHeader.p102.value = parent.opener.document.RSMDF.p_col102[rnumb].value;
 document.LOVHeader.p103.value = parent.opener.document.RSMDF.p_col103[rnumb].value;
 document.LOVHeader.p104.value = parent.opener.document.RSMDF.p_col104[rnumb].value;
 document.LOVHeader.p105.value = parent.opener.document.RSMDF.p_col105[rnumb].value;
 document.LOVHeader.p106.value = parent.opener.document.RSMDF.p_col106[rnumb].value;
 document.LOVHeader.p107.value = parent.opener.document.RSMDF.p_col107[rnumb].value;
 document.LOVHeader.p108.value = parent.opener.document.RSMDF.p_col108[rnumb].value;
 document.LOVHeader.p109.value = parent.opener.document.RSMDF.p_col109[rnumb].value;
 document.LOVHeader.p110.value = parent.opener.document.RSMDF.p_col110[rnumb].value;
 document.LOVHeader.p111.value = parent.opener.document.RSMDF.p_col111[rnumb].value;
 document.LOVHeader.p112.value = parent.opener.document.RSMDF.p_col112[rnumb].value;
 document.LOVHeader.p113.value = parent.opener.document.RSMDF.p_col113[rnumb].value;
 document.LOVHeader.p114.value = parent.opener.document.RSMDF.p_col114[rnumb].value;
 document.LOVHeader.p115.value = parent.opener.document.RSMDF.p_col115[rnumb].value;
 document.LOVHeader.p116.value = parent.opener.document.RSMDF.p_col116[rnumb].value;
 document.LOVHeader.p117.value = parent.opener.document.RSMDF.p_col117[rnumb].value;
 document.LOVHeader.p118.value = parent.opener.document.RSMDF.p_col118[rnumb].value;
 document.LOVHeader.p119.value = parent.opener.document.RSMDF.p_col119[rnumb].value;
 document.LOVHeader.p120.value = parent.opener.document.RSMDF.p_col120[rnumb].value;
 document.LOVHeader.p121.value = parent.opener.document.RSMDF.p_col121[rnumb].value;
 document.LOVHeader.p122.value = parent.opener.document.RSMDF.p_col122[rnumb].value;
 document.LOVHeader.p123.value = parent.opener.document.RSMDF.p_col123[rnumb].value;
 document.LOVHeader.p124.value = parent.opener.document.RSMDF.p_col124[rnumb].value;
 document.LOVHeader.p125.value = parent.opener.document.RSMDF.p_col125[rnumb].value;
 document.LOVHeader.p126.value = parent.opener.document.RSMDF.p_col126[rnumb].value;
 document.LOVHeader.p127.value = parent.opener.document.RSMDF.p_col127[rnumb].value;
 document.LOVHeader.p128.value = parent.opener.document.RSMDF.p_col128[rnumb].value;
 document.LOVHeader.p129.value = parent.opener.document.RSMDF.p_col129[rnumb].value;
 document.LOVHeader.p130.value = parent.opener.document.RSMDF.p_col130[rnumb].value;
 document.LOVHeader.p131.value = parent.opener.document.RSMDF.p_col131[rnumb].value;
 document.LOVHeader.p132.value = parent.opener.document.RSMDF.p_col132[rnumb].value;
 document.LOVHeader.p133.value = parent.opener.document.RSMDF.p_col133[rnumb].value;
 document.LOVHeader.p134.value = parent.opener.document.RSMDF.p_col134[rnumb].value;
 document.LOVHeader.p135.value = parent.opener.document.RSMDF.p_col135[rnumb].value;
 document.LOVHeader.p136.value = parent.opener.document.RSMDF.p_col136[rnumb].value;
 document.LOVHeader.p137.value = parent.opener.document.RSMDF.p_col137[rnumb].value;
 document.LOVHeader.p138.value = parent.opener.document.RSMDF.p_col138[rnumb].value;
 document.LOVHeader.p139.value = parent.opener.document.RSMDF.p_col139[rnumb].value;
 document.LOVHeader.p140.value = parent.opener.document.RSMDF.p_col140[rnumb].value;

                document.LOVHeader.submit(); // this will call Lov_Values plsql procedure
            // alert (parent.opener.document.RSMDF.p_col2[rnumb].value);


		}');
	htp.p('function queryText()
		{
			document.write("queryText function");
		}');

	htp.p('</SCRIPT>');
	htp.p('</HEAD>');
	htp.p('<BODY bgcolor="#cccccc">');
	htp.p('<FORM ACTION="qa_ss_lov.Lov_Values" METHOD="POST"
		NAME="LOVHeader" TARGET="LOVValues">');

       -- Hidden elements in the LOVHeaderForm
    htp.formHidden('vchar_id', vchar_id);
    htp.formHidden('rnumb', rnumb);
    htp.formHidden('cnumb', cnumb);
    htp.formHidden('orgz_id'); -- set in JS
    htp.formHidden('plan_id_i'); -- set in JS
    htp.formHidden('Flag'); -- value will be set inside Javascript
    htp.formHidden('start_row', '1');
    htp.formHidden('p_end_row');
    htp.formHidden('x_txn_num');
    htp.formHidden('x_wip_entity_type');
    htp.formHidden('x_wip_rep_sch_id');
    htp.formHidden('x_po_header_id');
    htp.formHidden('x_po_release_id');
    htp.formHidden('x_po_line_id');
    htp.formHidden('x_line_location_id');
    htp.formHidden('x_po_distribution_id'); -- Primary Key for OSP
    htp.formHidden('x_item_id');
    htp.formHidden('x_wip_entity_id');
    htp.formHidden('x_wip_line_id'); -- This is Production Line
    htp.formHidden('x_po_shipment_id'); -- Primary Key for SS Shipments

    htp.formHidden('p1'); -- values for p1 to p160 will be set  inside Javascript
htp.formHidden('p2');
htp.formHidden('p3');
htp.formHidden('p4');
htp.formHidden('p5');
htp.formHidden('p6');
htp.formHidden('p7');
htp.formHidden('p8');
htp.formHidden('p9');
htp.formHidden('p10');
htp.formHidden('p11');
htp.formHidden('p12');
htp.formHidden('p13');
htp.formHidden('p14');
htp.formHidden('p15');
htp.formHidden('p16');
htp.formHidden('p17');
htp.formHidden('p18');
htp.formHidden('p19');
htp.formHidden('p20');
htp.formHidden('p21');
htp.formHidden('p22');
htp.formHidden('p23');
htp.formHidden('p24');
htp.formHidden('p25');
htp.formHidden('p26');
htp.formHidden('p27');
htp.formHidden('p28');
htp.formHidden('p29');
htp.formHidden('p30');
htp.formHidden('p31');
htp.formHidden('p32');
htp.formHidden('p33');
htp.formHidden('p34');
htp.formHidden('p35');
htp.formHidden('p36');
htp.formHidden('p37');
htp.formHidden('p38');
htp.formHidden('p39');
htp.formHidden('p40');
htp.formHidden('p41');
htp.formHidden('p42');
htp.formHidden('p43');
htp.formHidden('p44');
htp.formHidden('p45');
htp.formHidden('p46');
htp.formHidden('p47');
htp.formHidden('p48');
htp.formHidden('p49');
htp.formHidden('p50');
htp.formHidden('p51');
htp.formHidden('p52');
htp.formHidden('p53');
htp.formHidden('p54');
htp.formHidden('p55');
htp.formHidden('p56');
htp.formHidden('p57');
htp.formHidden('p58');
htp.formHidden('p59');
htp.formHidden('p60');
htp.formHidden('p61');
htp.formHidden('p62');
htp.formHidden('p63');
htp.formHidden('p64');
htp.formHidden('p65');
htp.formHidden('p66');
htp.formHidden('p67');
htp.formHidden('p68');
htp.formHidden('p69');
htp.formHidden('p70');
htp.formHidden('p71');
htp.formHidden('p72');
htp.formHidden('p73');
htp.formHidden('p74');
htp.formHidden('p75');
htp.formHidden('p76');
htp.formHidden('p77');
htp.formHidden('p78');
htp.formHidden('p79');
htp.formHidden('p80');
htp.formHidden('p81');
htp.formHidden('p82');
htp.formHidden('p83');
htp.formHidden('p84');
htp.formHidden('p85');
htp.formHidden('p86');
htp.formHidden('p87');
htp.formHidden('p88');
htp.formHidden('p89');
htp.formHidden('p90');
htp.formHidden('p91');
htp.formHidden('p92');
htp.formHidden('p93');
htp.formHidden('p94');
htp.formHidden('p95');
htp.formHidden('p96');
htp.formHidden('p97');
htp.formHidden('p98');
htp.formHidden('p99');
htp.formHidden('p100');
htp.formHidden('p101');
htp.formHidden('p102');
htp.formHidden('p103');
htp.formHidden('p104');
htp.formHidden('p105');
htp.formHidden('p106');
htp.formHidden('p107');
htp.formHidden('p108');
htp.formHidden('p109');
htp.formHidden('p110');
htp.formHidden('p111');
htp.formHidden('p112');
htp.formHidden('p113');
htp.formHidden('p114');
htp.formHidden('p115');
htp.formHidden('p116');
htp.formHidden('p117');
htp.formHidden('p118');
htp.formHidden('p119');
htp.formHidden('p120');
htp.formHidden('p121');
htp.formHidden('p122');
htp.formHidden('p123');
htp.formHidden('p124');
htp.formHidden('p125');
htp.formHidden('p126');
htp.formHidden('p127');
htp.formHidden('p128');
htp.formHidden('p129');
htp.formHidden('p130');
htp.formHidden('p131');
htp.formHidden('p132');
htp.formHidden('p133');
htp.formHidden('p134');
htp.formHidden('p135');
htp.formHidden('p136');
htp.formHidden('p137');
htp.formHidden('p138');
htp.formHidden('p139');
htp.formHidden('p140');
htp.formHidden('p141');
htp.formHidden('p142');
htp.formHidden('p143');
htp.formHidden('p144');
htp.formHidden('p145');
htp.formHidden('p146');
htp.formHidden('p147');
htp.formHidden('p148');
htp.formHidden('p149');
htp.formHidden('p150');
htp.formHidden('p151');
htp.formHidden('p152');
htp.formHidden('p153');
htp.formHidden('p154');
htp.formHidden('p155');
htp.formHidden('p156');
htp.formHidden('p157');
htp.formHidden('p158');
htp.formHidden('p159');
htp.formHidden('p160');

    htp.p('<TABLE BORDER=0 WIDTH=100%>');

	SELECT Prompt into V_Prompt
	From QA_CHARS
	Where char_id = vchar_id;

	htp.p('<TR>');
	htp.p('<TD><SELECT NAME="a_1"><OPTION SELECTED VALUE="value">'||V_Prompt
			||'</SELECT></TD>');
	htp.p('<TD><SELECT NAME="c_1"<OPTION VALUE="AIS">is<OPTION VALUE="BNOT">is not<OPTION VALUE="CCONTAIN">contains<OPTION SELECTED VALUE="DSTART">starts with<OPTION VALUE="EEND">ends with</SELECT>
</TD>');
	htp.p('<TD><INPUT TYPE="text" NAME="i_1" SIZE="20" MAXLENGTH="35" VALUE="'
				|| replace(find_str,'"','&'||'quot;') || '"></TD>');
	htp.p('<SCRIPT LANGUAGE="JavaScript">');
	-- htp.p('queryText()');
	htp.p('</SCRIPT>');
	htp.p('<TD ALIGN="LEFT" WIDTH="100%">');

        fnd_message.set_name('QA','QA_SS_FIND');
        msg := fnd_message.get;
        msg := substr(msg,1, 20);

		/*
		icx_util.DynamicButton(P_ButtonText => msg,
		P_ImageFileName => 'FNDBSBMT',
		P_OnMouseOverText => msg,
		P_HyperTextCall => 'javascript:Lov_Check('||rnumb||',1,3)',
		P_LanguageCode => l_language_code,
		P_JavaScriptFlag => FALSE);
		*/
		qa_ss_core.draw_html_button('javascript:Lov_Check('||rnumb||',1,3)',msg);
	htp.p('</TD>');
	htp.p('</TR>');
	htp.p('<TR>');
	htp.p('<TD><INPUT TYPE="checkbox" NAME="case_sensitive" CHECKED>Match Case</TD>');
	htp.p('</TR>');
	htp.p('</TABLE>');
	htp.p('</CENTER>');
	htp.p('</FORM>');

	htp.p('</BODY>');

	htp.p('</HTML>');

    fnd_message.clear;

    end if; -- end icx session

EXCEPTION
     WHEN OTHERS THEN
        htp.p('Exception in Lov_Headers');
        htp.p(SQLERRM);

END LOV_Header;
-------------------------------------------------------------------------------------

procedure LOV_Values (
vchar_id IN qa_chars.char_id%TYPE DEFAULT NULL,
rnumb IN NUMBER DEFAULT NULL,
cnumb IN NUMBER DEFAULT NULL,
start_row IN NUMBER DEFAULT 1,
p_end_row IN NUMBER DEFAULT NULL,
orgz_id IN NUMBER DEFAULT NULL,
plan_id_i IN NUMBER DEFAULT NULL,
x_txn_num IN NUMBER DEFAULT NULL,
x_wip_entity_type IN NUMBER DEFAULT NULL,
x_wip_rep_sch_id IN NUMBER DEFAULT NULL,
x_po_header_id IN NUMBER DEFAULT NULL,
x_po_release_id IN NUMBER DEFAULT NULL,
x_po_line_id IN NUMBER DEFAULT NULL,
x_line_location_id IN NUMBER DEFAULT NULL,
x_po_distribution_id IN NUMBER DEFAULT NULL,
x_item_id IN NUMBER DEFAULT NULL,
x_wip_entity_id IN NUMBER DEFAULT NULL,
x_wip_line_id IN NUMBER DEFAULT NULL,
x_po_shipment_id IN NUMBER DEFAULT NULL,
p1 IN VARCHAR2 DEFAULT NULL,
p2 IN VARCHAR2 DEFAULT NULL,
p3 IN VARCHAR2 DEFAULT NULL,
p4 IN VARCHAR2 DEFAULT NULL,
p5 IN VARCHAR2 DEFAULT NULL,
p6 IN VARCHAR2 DEFAULT NULL,
p7 IN VARCHAR2 DEFAULT NULL,
p8 IN VARCHAR2 DEFAULT NULL,
p9 IN VARCHAR2 DEFAULT NULL,
p10 IN VARCHAR2 DEFAULT NULL,
p11 IN VARCHAR2 DEFAULT NULL,
p12 IN VARCHAR2 DEFAULT NULL,
p13 IN VARCHAR2 DEFAULT NULL,
p14 IN VARCHAR2 DEFAULT NULL,
p15 IN VARCHAR2 DEFAULT NULL,
p16 IN VARCHAR2 DEFAULT NULL,
p17 IN VARCHAR2 DEFAULT NULL,
p18 IN VARCHAR2 DEFAULT NULL,
p19 IN VARCHAR2 DEFAULT NULL,
p20 IN VARCHAR2 DEFAULT NULL,
p21 IN VARCHAR2 DEFAULT NULL,
p22 IN VARCHAR2 DEFAULT NULL,
p23 IN VARCHAR2 DEFAULT NULL,
p24 IN VARCHAR2 DEFAULT NULL,
p25 IN VARCHAR2 DEFAULT NULL,
p26 IN VARCHAR2 DEFAULT NULL,
p27 IN VARCHAR2 DEFAULT NULL,
p28 IN VARCHAR2 DEFAULT NULL,
p29 IN VARCHAR2 DEFAULT NULL,
p30 IN VARCHAR2 DEFAULT NULL,
p31 IN VARCHAR2 DEFAULT NULL,
p32 IN VARCHAR2 DEFAULT NULL,
p33 IN VARCHAR2 DEFAULT NULL,
p34 IN VARCHAR2 DEFAULT NULL,
p35 IN VARCHAR2 DEFAULT NULL,
p36 IN VARCHAR2 DEFAULT NULL,
p37 IN VARCHAR2 DEFAULT NULL,
p38 IN VARCHAR2 DEFAULT NULL,
p39 IN VARCHAR2 DEFAULT NULL,
p40 IN VARCHAR2 DEFAULT NULL,
p41 IN VARCHAR2 DEFAULT NULL,
p42 IN VARCHAR2 DEFAULT NULL,
p43 IN VARCHAR2 DEFAULT NULL,
p44 IN VARCHAR2 DEFAULT NULL,
p45 IN VARCHAR2 DEFAULT NULL,
p46 IN VARCHAR2 DEFAULT NULL,
p47 IN VARCHAR2 DEFAULT NULL,
p48 IN VARCHAR2 DEFAULT NULL,
p49 IN VARCHAR2 DEFAULT NULL,
p50 IN VARCHAR2 DEFAULT NULL,
p51 IN VARCHAR2 DEFAULT NULL,
p52 IN VARCHAR2 DEFAULT NULL,
p53 IN VARCHAR2 DEFAULT NULL,
p54 IN VARCHAR2 DEFAULT NULL,
p55 IN VARCHAR2 DEFAULT NULL,
p56 IN VARCHAR2 DEFAULT NULL,
p57 IN VARCHAR2 DEFAULT NULL,
p58 IN VARCHAR2 DEFAULT NULL,
p59 IN VARCHAR2 DEFAULT NULL,
p60 IN VARCHAR2 DEFAULT NULL,
p61 IN VARCHAR2 DEFAULT NULL,
p62 IN VARCHAR2 DEFAULT NULL,
p63 IN VARCHAR2 DEFAULT NULL,
p64 IN VARCHAR2 DEFAULT NULL,
p65 IN VARCHAR2 DEFAULT NULL,
p66 IN VARCHAR2 DEFAULT NULL,
p67 IN VARCHAR2 DEFAULT NULL,
p68 IN VARCHAR2 DEFAULT NULL,
p69 IN VARCHAR2 DEFAULT NULL,
p70 IN VARCHAR2 DEFAULT NULL,
p71 IN VARCHAR2 DEFAULT NULL,
p72 IN VARCHAR2 DEFAULT NULL,
p73 IN VARCHAR2 DEFAULT NULL,
p74 IN VARCHAR2 DEFAULT NULL,
p75 IN VARCHAR2 DEFAULT NULL,
p76 IN VARCHAR2 DEFAULT NULL,
p77 IN VARCHAR2 DEFAULT NULL,
p78 IN VARCHAR2 DEFAULT NULL,
p79 IN VARCHAR2 DEFAULT NULL,
p80 IN VARCHAR2 DEFAULT NULL,
p81 IN VARCHAR2 DEFAULT NULL,
p82 IN VARCHAR2 DEFAULT NULL,
p83 IN VARCHAR2 DEFAULT NULL,
p84 IN VARCHAR2 DEFAULT NULL,
p85 IN VARCHAR2 DEFAULT NULL,
p86 IN VARCHAR2 DEFAULT NULL,
p87 IN VARCHAR2 DEFAULT NULL,
p88 IN VARCHAR2 DEFAULT NULL,
p89 IN VARCHAR2 DEFAULT NULL,
p90 IN VARCHAR2 DEFAULT NULL,
p91 IN VARCHAR2 DEFAULT NULL,
p92 IN VARCHAR2 DEFAULT NULL,
p93 IN VARCHAR2 DEFAULT NULL,
p94 IN VARCHAR2 DEFAULT NULL,
p95 IN VARCHAR2 DEFAULT NULL,
p96 IN VARCHAR2 DEFAULT NULL,
p97 IN VARCHAR2 DEFAULT NULL,
p98 IN VARCHAR2 DEFAULT NULL,
p99 IN VARCHAR2 DEFAULT NULL,
p100 IN VARCHAR2 DEFAULT NULL,
p101 IN VARCHAR2 DEFAULT NULL,
p102 IN VARCHAR2 DEFAULT NULL,
p103 IN VARCHAR2 DEFAULT NULL,
p104 IN VARCHAR2 DEFAULT NULL,
p105 IN VARCHAR2 DEFAULT NULL,
p106 IN VARCHAR2 DEFAULT NULL,
p107 IN VARCHAR2 DEFAULT NULL,
p108 IN VARCHAR2 DEFAULT NULL,
p109 IN VARCHAR2 DEFAULT NULL,
p110 IN VARCHAR2 DEFAULT NULL,
p111 IN VARCHAR2 DEFAULT NULL,
p112 IN VARCHAR2 DEFAULT NULL,
p113 IN VARCHAR2 DEFAULT NULL,
p114 IN VARCHAR2 DEFAULT NULL,
p115 IN VARCHAR2 DEFAULT NULL,
p116 IN VARCHAR2 DEFAULT NULL,
p117 IN VARCHAR2 DEFAULT NULL,
p118 IN VARCHAR2 DEFAULT NULL,
p119 IN VARCHAR2 DEFAULT NULL,
p120 IN VARCHAR2 DEFAULT NULL,
p121 IN VARCHAR2 DEFAULT NULL,
p122 IN VARCHAR2 DEFAULT NULL,
p123 IN VARCHAR2 DEFAULT NULL,
p124 IN VARCHAR2 DEFAULT NULL,
p125 IN VARCHAR2 DEFAULT NULL,
p126 IN VARCHAR2 DEFAULT NULL,
p127 IN VARCHAR2 DEFAULT NULL,
p128 IN VARCHAR2 DEFAULT NULL,
p129 IN VARCHAR2 DEFAULT NULL,
p130 IN VARCHAR2 DEFAULT NULL,
p131 IN VARCHAR2 DEFAULT NULL,
p132 IN VARCHAR2 DEFAULT NULL,
p133 IN VARCHAR2 DEFAULT NULL,
p134 IN VARCHAR2 DEFAULT NULL,
p135 IN VARCHAR2 DEFAULT NULL,
p136 IN VARCHAR2 DEFAULT NULL,
p137 IN VARCHAR2 DEFAULT NULL,
p138 IN VARCHAR2 DEFAULT NULL,
p139 IN VARCHAR2 DEFAULT NULL,
p140 IN VARCHAR2 DEFAULT NULL,
p141 IN VARCHAR2 DEFAULT NULL,
p142 IN VARCHAR2 DEFAULT NULL,
p143 IN VARCHAR2 DEFAULT NULL,
p144 IN VARCHAR2 DEFAULT NULL,
p145 IN VARCHAR2 DEFAULT NULL,
p146 IN VARCHAR2 DEFAULT NULL,
p147 IN VARCHAR2 DEFAULT NULL,
p148 IN VARCHAR2 DEFAULT NULL,
p149 IN VARCHAR2 DEFAULT NULL,
p150 IN VARCHAR2 DEFAULT NULL,
p151 IN VARCHAR2 DEFAULT NULL,
p152 IN VARCHAR2 DEFAULT NULL,
p153 IN VARCHAR2 DEFAULT NULL,
p154 IN VARCHAR2 DEFAULT NULL,
p155 IN VARCHAR2 DEFAULT NULL,
p156 IN VARCHAR2 DEFAULT NULL,
p157 IN VARCHAR2 DEFAULT NULL,
p158 IN VARCHAR2 DEFAULT NULL,
p159 IN VARCHAR2 DEFAULT NULL,
p160 IN VARCHAR2 DEFAULT NULL,
i_1 IN VARCHAR2 DEFAULT NULL, -- find_str
a_1 IN VARCHAR2 DEFAULT NULL, -- search on
c_1 IN VARCHAR2 DEFAULT NULL, -- condition
case_sensitive IN VARCHAR2 DEFAULT NULL,
Flag IN NUMBER DEFAULT NULL
		)

IS
	r_cnt NUMBER := 0;
	more_records BOOLEAN;
    	vef NUMBER := 0;
	fld VARCHAR2(20);
    sbox VARCHAR2(20); -- New (for select box)
	f_str VARCHAR2(500); -- increased from 40
	code VARCHAR2(500);
	description VARCHAR2(500);
	cur INTEGER;
	sql_val_str qa_chars.sql_validation_string%TYPE := NULL;
	ignore INTEGER;
	ORDER_POS NUMBER;
	empty_valstring_ex EXCEPTION;
	--    A    qa_ss_const.var150_table;
	-- instead of A table above, use global GV_Elmt_tab better perf
    plan_org_ex EXCEPTION;

	/* PAGING VARS */
	end_row NUMBER;
	total_rows NUMBER;
	l_query_size NUMBER := 10;
	srow_st varchar2(1000);
	erow_st varchar2(1000);

    row_color VARCHAR2(10) := 'BLUE';
	where_cond varchar2(20);

BEGIN
    if (icx_sec.validatesession) then
       if (Flag = 1) Then
          -- htp.p('Find Button has been clicked');
          --  htp.p('variable sensit = ' || case_sensitive);
	  --  htp.p('search condition = ' || c_1);

        if (orgz_id is Null or plan_id_i is Null) Then
            Raise plan_org_ex;
        end if;

	if (p_end_row is Null) then
		end_row := l_query_size;
	else
		end_row := p_end_row;
	end if;

    /*
	 htp.p('start = ' || start_row);
	 htp.p('end = ' || end_row);
	 htp.p('l_query_size = ' || l_query_size);

    htp.nl;
    htp.p('orgz_id: '|| to_char(NVL(orgz_id, -9999))); htp.nl;
    htp.p('plan_id_i: ' || to_char(NVL(plan_id_i, -9999))); htp.nl;
    htp.p('x_txn_num: ' || to_char(NVL(x_txn_num, -9999))); htp.nl;
    htp.p('x_wip_entity_type: ' || to_char(NVL(x_wip_entity_type,-9999))); htp.nl;
    htp.p('x_wip_rep_sch_id: ' || to_char(NVL(x_wip_rep_sch_id, -9999))); htp.nl;
    htp.p('x_po_header_id: ' || to_char(NVL(x_po_header_id, -9999))); htp.nl;
    htp.p('x_po_release_id: ' || to_char(NVL(x_po_release_id, -9999))); htp.nl;
    htp.p('x_po_line_id: ' || to_char(NVL(x_po_line_id, -9999))); htp.nl;
    htp.p('x_line_location_id: ' || to_char(NVL(x_line_location_id, -9999))); htp.nl;
    htp.p('x_po_distribution_id: ' || to_char(NVL(x_po_distribution_id, -9999))); htp.nl;
    htp.p('x_item_id: ' || to_char(NVL(x_item_id, -9999))); htp.nl;
    htp.p('x_wip_entity_id: ' || to_char(NVL(x_wip_entity_id, -9999))); htp.nl;
    htp.p('x_wip_line_id: ' || to_char(NVL(x_wip_line_id, -9999))); htp.nl;
    htp.p('x_po_shipment_id: ' || to_char(NVL(x_po_shipment_id, -9999))); htp.nl;
    */

	if (c_1 = 'BNOT') then
		f_str := i_1;
		where_cond := '<>';
	elsif (c_1 = 'DSTART') then
		f_str := i_1||'%';
		where_cond := 'LIKE';
	elsif (c_1 = 'EEND') then
		f_str := '%'||i_1;
		where_cond := 'LIKE';
	else
		f_str := '%'||i_1||'%';
		where_cond := 'LIKE';
	end if;

	-- adding the dequote function here,  Oct22 1999
	f_str := QA_CORE_PKG.dequote(f_str);

	select sql_validation_string
	into sql_val_str
	from qa_chars
	where char_id = vchar_id; -- THIS has to be changed to vchar_id later. DONE now

	select qpc.values_exist_flag into vef
	from qa_plan_chars qpc
	where char_id = vchar_id
	and plan_id = plan_id_i;
  --
  -- Bug 5003509. R12 Performance fix. Comment out the code.
  -- srhariha. Wed Feb  1 03:29:16 PST 2006
  --
        /*
	IF (vef = 1) Then  -- User defined Values do exist
		sql_val_str := 'SELECT short_code, description from qa_plan_char_value_lookups '
			|| ' where char_id = '||vchar_id
			|| ' and plan_id = ' ||plan_id_i;
	End IF; -- end if user values exist
        */

        -- Assign values to the table A
       GV_Elmt_tab(1) := p1;
       GV_Elmt_tab(2) := p2;
       GV_Elmt_tab(3) := p3;
       GV_Elmt_tab(4) := p4;
       GV_Elmt_tab(5) := p5;
       GV_Elmt_tab(6) := p6;
       GV_Elmt_tab(7) := p7;
       GV_Elmt_tab(8) := p8;
       GV_Elmt_tab(9) := p9;
       GV_Elmt_tab(10) := p10;
       GV_Elmt_tab(11) := p11;
       GV_Elmt_tab(12) := p12;
       GV_Elmt_tab(13) := p13;
       GV_Elmt_tab(14) := p14;
       GV_Elmt_tab(15) := p15;
       GV_Elmt_tab(16) := p16;
       GV_Elmt_tab(17) := p17;
       GV_Elmt_tab(18) := p18;
       GV_Elmt_tab(19) := p19;
       GV_Elmt_tab(20) := p20;
       GV_Elmt_tab(21) := p21;
       GV_Elmt_tab(22) := p22;
       GV_Elmt_tab(23) := p23;
       GV_Elmt_tab(24) := p24;
       GV_Elmt_tab(25) := p25;
       GV_Elmt_tab(26) := p26;
       GV_Elmt_tab(27) := p27;
       GV_Elmt_tab(28) := p28;
       GV_Elmt_tab(29) := p29;
       GV_Elmt_tab(30) := p30;
       GV_Elmt_tab(31) := p31;
       GV_Elmt_tab(32) := p32;
       GV_Elmt_tab(33) := p33;
       GV_Elmt_tab(34) := p34;
       GV_Elmt_tab(35) := p35;
       GV_Elmt_tab(36) := p36;
       GV_Elmt_tab(37) := p37;
       GV_Elmt_tab(38) := p38;
       GV_Elmt_tab(39) := p39;
       GV_Elmt_tab(40) := p40;
       GV_Elmt_tab(41) := p41;
       GV_Elmt_tab(42) := p42;
       GV_Elmt_tab(43) := p43;
       GV_Elmt_tab(44) := p44;
       GV_Elmt_tab(45) := p45;
       GV_Elmt_tab(46) := p46;
       GV_Elmt_tab(47) := p47;
       GV_Elmt_tab(48) := p48;
       GV_Elmt_tab(49) := p49;
       GV_Elmt_tab(50) := p50;
       GV_Elmt_tab(51) := p51;
       GV_Elmt_tab(52) := p52;
       GV_Elmt_tab(53) := p53;
       GV_Elmt_tab(54) := p54;
       GV_Elmt_tab(55) := p55;
       GV_Elmt_tab(56) := p56;
       GV_Elmt_tab(57) := p57;
       GV_Elmt_tab(58) := p58;
       GV_Elmt_tab(59) := p59;
       GV_Elmt_tab(60) := p60;
       GV_Elmt_tab(61) := p61;
       GV_Elmt_tab(62) := p62;
       GV_Elmt_tab(63) := p63;
       GV_Elmt_tab(64) := p64;
       GV_Elmt_tab(65) := p65;
       GV_Elmt_tab(66) := p66;
       GV_Elmt_tab(67) := p67;
       GV_Elmt_tab(68) := p68;
       GV_Elmt_tab(69) := p69;
       GV_Elmt_tab(70) := p70;
       GV_Elmt_tab(71) := p71;
       GV_Elmt_tab(72) := p72;
       GV_Elmt_tab(73) := p73;
       GV_Elmt_tab(74) := p74;
       GV_Elmt_tab(75) := p75;
       GV_Elmt_tab(76) := p76;
       GV_Elmt_tab(77) := p77;
       GV_Elmt_tab(78) := p78;
       GV_Elmt_tab(79) := p79;
       GV_Elmt_tab(80) := p80;
       GV_Elmt_tab(81) := p81;
       GV_Elmt_tab(82) := p82;
       GV_Elmt_tab(83) := p83;
       GV_Elmt_tab(84) := p84;
       GV_Elmt_tab(85) := p85;
       GV_Elmt_tab(86) := p86;
       GV_Elmt_tab(87) := p87;
       GV_Elmt_tab(88) := p88;
       GV_Elmt_tab(89) := p89;
       GV_Elmt_tab(90) := p90;
       GV_Elmt_tab(91) := p91;
       GV_Elmt_tab(92) := p92;
       GV_Elmt_tab(93) := p93;
       GV_Elmt_tab(94) := p94;
       GV_Elmt_tab(95) := p95;
       GV_Elmt_tab(96) := p96;
       GV_Elmt_tab(97) := p97;
       GV_Elmt_tab(98) := p98;
       GV_Elmt_tab(99) := p99;
       GV_Elmt_tab(100) := p100;
       GV_Elmt_tab(101) := p101;
       GV_Elmt_tab(102) := p102;
       GV_Elmt_tab(103) := p103;
       GV_Elmt_tab(104) := p104;
       GV_Elmt_tab(105) := p105;
       GV_Elmt_tab(106) := p106;
       GV_Elmt_tab(107) := p107;
       GV_Elmt_tab(108) := p108;
       GV_Elmt_tab(109) := p109;
       GV_Elmt_tab(110) := p110;
       GV_Elmt_tab(111) := p111;
       GV_Elmt_tab(112) := p112;
       GV_Elmt_tab(113) := p113;
       GV_Elmt_tab(114) := p114;
       GV_Elmt_tab(115) := p115;
       GV_Elmt_tab(116) := p116;
       GV_Elmt_tab(117) := p117;
       GV_Elmt_tab(118) := p118;
       GV_Elmt_tab(119) := p119;
       GV_Elmt_tab(120) := p120;
       GV_Elmt_tab(121) := p121;
       GV_Elmt_tab(122) := p122;
       GV_Elmt_tab(123) := p123;
       GV_Elmt_tab(124) := p124;
       GV_Elmt_tab(125) := p125;
       GV_Elmt_tab(126) := p126;
       GV_Elmt_tab(127) := p127;
       GV_Elmt_tab(128) := p128;
       GV_Elmt_tab(129) := p129;
       GV_Elmt_tab(130) := p130;
       GV_Elmt_tab(131) := p131;
       GV_Elmt_tab(132) := p132;
       GV_Elmt_tab(133) := p133;
       GV_Elmt_tab(134) := p134;
       GV_Elmt_tab(135) := p135;
       GV_Elmt_tab(136) := p136;
       GV_Elmt_tab(137) := p137;
       GV_Elmt_tab(138) := p138;
       GV_Elmt_tab(139) := p139;
       GV_Elmt_tab(140) := p140;
       GV_Elmt_tab(141) := p141;
       GV_Elmt_tab(142) := p142;
       GV_Elmt_tab(143) := p143;
       GV_Elmt_tab(144) := p144;
       GV_Elmt_tab(145) := p145;
       GV_Elmt_tab(146) := p146;
       GV_Elmt_tab(147) := p147;
       GV_Elmt_tab(148) := p148;
       GV_Elmt_tab(149) := p149;
       GV_Elmt_tab(150) := p150;
       GV_Elmt_tab(151) := p151;
       GV_Elmt_tab(152) := p152;
       GV_Elmt_tab(153) := p153;
       GV_Elmt_tab(154) := p154;
       GV_Elmt_tab(155) := p155;
       GV_Elmt_tab(156) := p156;
       GV_Elmt_tab(157) := p157;
       GV_Elmt_tab(158) := p158;
       GV_Elmt_tab(159) := p159;
       GV_Elmt_tab(160) := p160;

	-- Assign Package Global Variables here
	GV_Wip_Entity_Type := x_wip_entity_type;
	GV_Wip_Rep_Sch_Id := x_wip_rep_sch_id;
	GV_Po_Header_Id := x_po_header_id;
	GV_Po_Release_Id := x_po_release_id;
	GV_Po_Line_Id := x_po_line_id;
	GV_Line_Location_Id := x_line_location_id;
	GV_Po_Distribution_Id := x_po_distribution_id;
	GV_Item_Id := x_item_id;
	GV_wip_entity_Id := x_wip_entity_id;
	GV_Wip_Line_Id := x_wip_line_id;
	GV_Po_Shipment_Id := x_po_shipment_id;
	GV_Txn_Num := x_txn_num;

	/* -- only for debugging
	FOR b in 1..160
	Loop
		htp.p('A('||b||') = '|| A(b));
	End Loop;
	*/


	If (vchar_id = qa_ss_const.Item) Then
        sql_val_str := Q_Item(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Comp_Revision) Then
        sql_val_str := Q_Comp_Revision(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Comp_Subinventory) Then
        sql_val_str := Q_Comp_Subinventory(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Comp_UOM) Then
        sql_val_str := Q_Comp_Uom(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Customer_Name) Then
        sql_val_str := Q_Customers(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Department) Then
        sql_val_str := Q_Department(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.From_Op_Seq_Num) Then
        sql_val_str := Q_From_Op_Seq_Num(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Production_Line) Then
        sql_val_str := Q_Line(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Po_Number) Then
        sql_val_str := Q_Po_Headers(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Po_Line_Num) Then
        sql_val_str := Q_Po_Lines(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Po_Release_Num) Then
        sql_val_str := Q_Po_Release_Nums(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Po_Shipment_Num) Then
        sql_val_str := Q_Po_Shipments(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Project_Number) Then
        sql_val_str := Q_Project(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Receipt_Num) Then
        sql_val_str := Q_Receipt_Nums(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Resource_Code) Then
        sql_val_str := Q_Resource(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Revision) Then
        sql_val_str := Q_Revision(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.RMA_Number) Then
        sql_val_str := Q_Rma_Number(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Sales_Order) Then
        sql_val_str := Q_Sales_Orders(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Subinventory) Then
        sql_val_str := Q_Subinventory(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.To_op_seq_num) Then
        sql_val_str := Q_To_Op_Seq_Num(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.UOM) Then
        sql_val_str := Q_UOM(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Vendor_Name) Then
        sql_val_str := Q_Vendors(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Job_Name) Then
        sql_val_str := Q_Job(plan_id_i, vchar_id, orgz_id);
    Elsif (vchar_id = qa_ss_const.Task_Number) Then
        sql_val_str := Q_Task(plan_id_i, vchar_id, orgz_id);

	End If;




	IF (sql_val_str IS NULL or sql_val_str = 'DEP_ERROR' )
	Then
		RAISE empty_valstring_ex;
	End if;
	-- Now lets do some processing of the validation string obtained
	sql_val_str := UPPER(sql_val_str);
	ORDER_POS := INSTR(sql_val_str, 'ORDER BY');
	IF (ORDER_POS <> 0) THEN
		sql_val_str := SUBSTR(sql_val_str, 1, ORDER_POS-1);
	END IF;

	sql_val_str := REPLACE(sql_val_str, ':PARAMETER.ORG_ID', to_char(orgz_id));
	-- adding this rtrim below oct27,1999
	-- bryan suggested this as per bug 956708 he fixed
	-- after / I hit enter key on purpose. dont alter this
	sql_val_str := rtrim(sql_val_str, ' ;/
');
	-- htp.p('after rtrim as per bryan suggestion');
	sql_val_str := 'SELECT CODE, DESCRIPTION FROM (' ||
		        'SELECT ''1'' AS CODE, ''1'' AS DESCRIPTION ' ||
			'FROM DUAL WHERE 1=2 ' ||
			'UNION ALL (' ||
			sql_val_str ||
			') )
			WHERE CODE '||where_cond|| '''' || f_str || '''
			ORDER BY CODE';
	-- htp.p('Before Cursor open: '||sql_val_str);

	cur := dbms_sql.open_cursor;
	-- htp.p('before parse');
	dbms_sql.parse(cur, sql_val_str, DBMS_SQL.v7);
	-- htp.p('after parse');
	dbms_sql.define_column(cur, 1, code, 500);
	dbms_sql.define_column(cur, 2, description, 500);
	ignore := dbms_sql.execute(cur);

	fld := 'p_col'||cnumb|| '[' || rnumb || ']';
    sbox := 'selectbox[' || rnumb || ']';
	htp.htmlOpen;
	htp.headOpen;
	htp.p('<SCRIPT LANGUAGE="JavaScript">');

    -- New code Make the selectbox to be Yes
    -- Otherwise, if you choose Lov, it does not mark the record as dirty, which it should
    -- Initial Bug Fix July 29, 1999
	htp.p('function clicked(return_val)
		{
		  parent.opener.document.RSMDF.'||fld||'.value = return_val;
          parent.opener.document.RSMDF.'||sbox||'.checked = true;
		  parent.window.close();
		}');

	htp.p('</SCRIPT>');
	htp.headClose;

	htp.bodyOpen(cattributes=>'bgcolor="#cccccc"');
	-- htp.p('Corresponding field is ' || fld);

	htp.p('Records ' || to_char(start_row) || ' to ' || to_char(end_row));

	htp.p('<FORM ACTION="" METHOD="POST" NAME="LOVValues">');

    htp.tableOpen('BORDER');
    htp.tableRowOpen(cattributes=>'BGCOLOR="#336699"');
	htp.p('<TD ALIGN="LEFT"><STRONG><FONT color="#ffffff">Code</Font></STRONG></TD>');
	htp.p('<TD ALIGN="LEFT"><STRONG><FONT color="#ffffff">Description</Font></STRONG></TD>');
    htp.tableRowClose;

	r_cnt := 0;
	more_records := TRUE;
	LOOP
	  IF DBMS_SQL.FETCH_ROWS(cur) > 0 THEN
		r_cnt := r_cnt + 1;
		if (r_cnt > end_row) then
			exit;
		end if;

		if (r_cnt >= start_row) THEN
		dbms_sql.column_value(cur, 1, code);
		dbms_sql.column_value(cur, 2, description);
                if (row_color = 'BLUE') then
    		              htp.tableRowOpen(cattributes=>'BGCOLOR="#99ccff"');
                          row_color := 'WHITE';
                else
                           htp.tableRowOpen(cattributes=>'BGCOLOR="#ffffff"');
                          row_color := 'BLUE';
                end if; -- end if for row color
			/*
                	htp.tableData('<A HREF="javascript:clicked('''||
                        replace(code,'"','&'||'quot;')||''')">'||code||'</A>');
			*/
			-- AUG 19 Using icx_util to try and fix special chars issue
			htp.tableData('<A HREF="javascript:clicked('''||
                        icx_util.replace_jsdw_quotes(code)||''')">'||code||'</A>');

			if (description IS NULL)
			then
				description := '&nbsp';
			end if;
			htp.tableData(description);
                htp.tableRowClose;
		end if; -- end r_cnt check
	  ELSE
		-- no more rows
		more_records := FALSE;
		EXIT;
	  End If;
	END LOOP; -- end of dynamic cursor loop
    htp.tableClose;


	srow_st := 'javascript:parent.LOVHeader.Lov_Check('
			|| to_char(rnumb)
			|| ', ' || to_char(start_row-l_query_size)
			|| ', ' || to_char(start_row-1) || ')';

	erow_st := 'javascript:parent.LOVHeader.Lov_Check('
			|| to_char(rnumb)
			|| ', ' || to_char(end_row+1)
			|| ', ' || to_char(end_row+l_query_size) || ')';

	 if (start_row > 1) then
	 htp.anchor(srow_st , 'Previous ');
	 end if;

--		||to_char(start_row-l_query_size)||' to '
--				|| to_char(start_row-1));

	htp.p('------------'); -- Dont delete this is a spacer

	 if (more_records = TRUE) then
	 htp.anchor(erow_st, 'Next ');
	 end if;

--		 ||  to_char(end_row+1) || ' to '
--				|| to_char(end_row+l_query_size));


    htp.bodyClose;

	htp.htmlClose;
  Else
	htp.p('Please Enter Search above and click Find button');

    End If; -- End if flag=1

		-- htp.p('Before Find has been clicked');



    end if; -- end icx session

EXCEPTION
        WHEN empty_valstring_ex THEN
		htp.p(fnd_message.get_string('QA','QA_SS_NO_LOV_VALUES'));
        WHEN plan_org_ex THEN
        htp.p('Plan id or Org Id is Null');
     WHEN OTHERS THEN
        htp.p('Exception in Lov_Values');
        htp.p(SQLERRM);
END LOV_Values;
-----------------------------------------------------------------------------------------


function return_col_num ( x_char_id IN NUMBER, x_plan_id IN NUMBER )
RETURN NUMBER
 IS
        CURSOR qpc_cur IS
            select qpc.char_id
            from qa_plan_chars qpc
            where qpc.plan_id = x_plan_id
            and qpc.enabled_flag = 1
            ORDER BY qpc.prompt_sequence;

          pos NUMBER;
    BEGIN
            pos := 0;
             FOR qpc_rec IN qpc_cur
            LOOP
                pos := pos + 1;
                If (qpc_rec.char_id = x_char_id) Then
                        RETURN pos;
                End If;
            END LOOP; -- end cursor for loop

            RETURN -1; -- charid Not found, some mistake

        -- return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package - function return_col_num');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------


function value_to_id ( charid IN NUMBER, val IN VARCHAR2, orgz_id IN NUMBER DEFAULT NULL)
RETURN NUMBER
-- eg, pass in Project Number as val, will return Project Id
 IS
        str varchar2(10000);
        x_pk_id varchar2(30);
        x_fk_table_name varchar2(30);
        x_fk_meaning varchar2(30);
        cur INTEGER;
        ignore INTEGER;
        id NUMBER := -1 ;
    BEGIN
            if (charid is Null or val is Null )
                then
                    return -1;
            end if;

            if (charid in (qa_ss_const.Item,
                            qa_ss_const.job_name,
                            qa_ss_const.production_line,
                            qa_ss_const.po_number,
                            qa_ss_const.project_number,
                            qa_ss_const.item,
                            qa_ss_const.comp_item) )
             THEN
                    select qc.fk_table_name, qc.pk_id, qc.fk_meaning
                            INTO x_fk_table_name, x_pk_id, x_fk_meaning
                    FROM qa_chars qc
                    WHERE qc.char_id = charid;

		   --this code path is obsolete -only used for old
		   --plsql web cartridge based application
  		   --never get executed in 11.5.9
                   --commenting out just to prevent false positive
	           --in SQL Bind project
		   -- isivakum May 5, 2003

		     str := null;

                 --  str := 'SELECT ' || x_pk_id || ' FROM ' || x_fk_table_name
                 --           || ' Where ' || x_fk_meaning || ' = ''' || val
                 --           || ''' and Rownum = 1 ';



                    cur := dbms_sql.open_cursor;
                    dbms_sql.parse(cur, str, DBMS_SQL.v7);
                    dbms_sql.define_column( cur, 1, id);
                    ignore := dbms_sql.execute(cur);

                    if dbms_sql.fetch_rows(cur) > 0 Then
                        dbms_sql.column_value(cur, 1, id);
                    end if;
                    return id;
             ELSE
                    Return -1;
             End If;
        -- return NULL;
    EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in Lov package - func value_to_id');
            htp.p(SQLERRM);
    END;
 -------------------------------------------------------------------------------------------


end qa_ss_lov;


/
