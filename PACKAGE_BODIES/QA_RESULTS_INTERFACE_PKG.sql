--------------------------------------------------------
--  DDL for Package Body QA_RESULTS_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_RESULTS_INTERFACE_PKG" as
/* $Header: qltimptb.plb 120.3.12010000.5 2015/11/09 22:15:50 ntungare ship $ */


FUNCTION dequote(s1 in varchar2) RETURN varchar2 IS
--
-- The string s1 may be used in a dynamically constructed SQL
-- statement.  If s1 contains a single quote, there will be syntax
-- error.  This function returns a string s2 that is same as s1
-- except each single quote is replaced with two single quotes.
-- Put in for NLS fix.  Previously if plan name or element name
-- contains a single quote, that will cause problem when creating
-- views.
-- bso
--
BEGIN
    RETURN replace(s1, '''', '''''');
END dequote;

--
-- Bug 22176228
-- Stubbing out the API to avoid security issue due to
-- SQL injection through ss_where_clause
-- ntungare
--
FUNCTION BUILD_VQR_SQL ( given_plan_id IN NUMBER,
			 ss_where_clause in varchar2 default null)
    return VARCHAR2 as

begin

--	DECLARE
--
--	cursor CES is select result_column_name, qpc.char_id
--			from qa_plan_chars qpc, qa_chars qc
--			where plan_id = given_plan_id
--			and qpc.char_id = qc.char_id
--			and qpc.enabled_flag = 1
--                        order by prompt_sequence;
--
--	first 		NUMBER;
--        column_name 	VARCHAR2(240);
--	key		VARCHAR2(240);
--        select_clause 	VARCHAR2(32000);
--	from_clause 	VARCHAR2(1000);
-- 	where_clause 	VARCHAR2(1000);
--	table_name 	VARCHAR2(240);
--	org_id		NUMBER;
--begin
--
--
--  select_clause := 'SELECT ';
--  from_clause   := ' FROM qa_results_v' ;
--  where_clause  := ' WHERE plan_id = ' || given_plan_id ||
--		   ' AND' || ' (status = 2 or status is null) ' ;
--  if (ss_where_clause is not null) then
--	where_clause := where_clause || ' AND ' || ss_where_clause;
--  end if;
--
--  where_clause := where_clause ||  ' ORDER BY ' || 'occurrence desc';
--
--
--  first := 1;
--
----  select min(organization_id) into org_id
----  from qa_results_v
----  where plan_id = given_plan_id;
--
--  FOR element in CES LOOP
--
--
--	if ((element.char_id = 10) or  element.char_id = 60) then
--
--		column_name := 'qa_flex_util.item(organization_id , item_id) ITEM';
--
--
--	elsif ((element.char_id = 15) or (element.char_id = 65)) then
--		column_name := 'qa_flex_util.locator(organization_id, locator_id) LOCATOR';
--
--	else
--		column_name := upper(QA_CORE_PKG.get_result_column_name(element.char_id, given_plan_id));
--
--	end if;
--
--	if (first = 1) then
--      		select_clause := select_clause || column_name;
--      		first := 0;
--   	else
--      		select_clause := select_clause || ', ' || column_name;
--   	end if;
--
--
--  END LOOP;
--
--  -- This sql script should return QA_CREATED_BY_NAME instead of CREATED_BY
--  -- please see bug # 1054779.
--
--  select_clause :=  select_clause || ', ' || 'QA_CREATED_BY_NAME'
--			 	   || ', ' || 'COLLECTION_ID'
--				   || ', ' || 'fnd_date.date_to_chardt(LAST_UPDATE_DATE,2) LAST_UPDATE_DATE';
--
--  select_clause := select_clause || from_clause || where_clause;
--  return select_clause;
-- end;
--
-- EXCEPTION  when others then
--	raise;

   NULL;
End BUILD_VQR_SQL;


FUNCTION build_select_clause (p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS

    cursor CES is
        SELECT   result_column_name, qpc.char_id, qc.datatype
        FROM     qa_plan_chars qpc, qa_chars qc
        WHERE    plan_id = p_plan_id
        AND      qpc.char_id = qc.char_id
        AND      qpc.enabled_flag = 1
        ORDER BY prompt_sequence;

    first 		NUMBER;
    column_name 	VARCHAR2(240);
    select_clause 	VARCHAR2(32000);

BEGIN

    first := 1;

    FOR element in CES LOOP

        IF element.char_id = qa_ss_const.item THEN
            column_name := 'qa_flex_util.item(organization_id , item_id) ITEM';
	ELSIF element.char_id =  qa_ss_const.comp_item THEN
		column_name := 'qa_flex_util.item(organization_id , comp_item_id) COMP_ITEM';

        -- anagarwa Fri Feb  7 14:38:21 PST 2003
        -- Bug 2792353
        -- even though following 2 statements are for bill reference and
        -- routing reference, we still use qa_flex_util.item to get the values
        -- because foreign keys for both bill reference and routing reference
        -- point to mtl_system_items_kfv.inventory_item_id and the actual
        -- value comes from concatenated segments.
        -- Therefore there is no need to write a separate function for these
        -- 2 elements.

	ELSIF element.char_id =  qa_ss_const.bill_reference THEN
            column_name := 'qa_flex_util.item(organization_id, bill_reference_id) BILL_REFERENCE';

	ELSIF element.char_id =  qa_ss_const.routing_reference THEN
            column_name := 'qa_flex_util.item(organization_id, routing_reference_id) ROUTING_REFERENCE';

        ELSIF element.char_id = qa_ss_const.locator THEN
  	    column_name := 'qa_flex_util.locator(organization_id, locator_id)
                LOCATOR';

        ELSIF element.char_id = qa_ss_const.comp_locator THEN
  	    column_name := 'qa_flex_util.locator(organization_id, comp_locator_id)
                COMP_LOCATOR';

        ELSIF element.char_id = qa_ss_const.to_locator THEN
  	    column_name := 'qa_flex_util.locator(organization_id, to_locator_id)
               TO_LOCATOR';

        -- end of changes by anagarwa

        /*
           Bug 4261053.suramasw.

           Appending ASSET_GROUP_ID to be assigned to column_name when assigning
           ASSET_GROUP. This was done so that view quality results in EAM Asset
           Query transaction shows the quality result(s) collected only for the
           asset number, which the user tries to view. Plz see the method
           setupStandAloneQuery in QaVqrDataTopCO.java to know the details on
           why ASSET_GROUP_ID should also be assigned to column_name.
        */
--dgupta: Start R12 EAM Integration. Bug 4345492
        ELSIF element.char_id = qa_ss_const.asset_group THEN
            column_name := 'qa_flex_util.get_asset_group_name(organization_id,
                asset_group_id) ASSET_GROUP, ASSET_GROUP_ID';
--dgupta: End R12 EAM Integration. Bug 4345492
        ELSIF element.char_id = qa_ss_const.asset_activity THEN
            column_name := 'qa_flex_util.item(organization_id,
                asset_activity_id) ASSET_ACTIVITY';

-- added the following to include new hardcoded element followup activity
-- saugupta

	ELSIF element.char_id = qa_ss_const.followup_activity THEN
            column_name := 'qa_flex_util.item(organization_id,
                followup_activity_id) FOLLOWUP_ACTIVITY';

    ELSIF element.char_id = qa_ss_const.work_order THEN
            column_name := 'qa_flex_util.work_order(organization_id, work_order_id) WORK_ORDER';

	ELSIF not qa_plan_element_api.hardcoded(element.char_id) and
		element.datatype in (qa_ss_const.date_datatype ,
		qa_ss_const.datetime_datatype) then
	    column_name := upper(QA_CORE_PKG.get_result_column_name(element.char_id, p_plan_id));
	    column_name := 'fnd_date.canonical_to_date(' || column_name || ') ' || column_name;

    -- Bug 17999440
    -- Converting the number to user format for view page conversion.
    -- hmakam

    ELSIF not qa_plan_element_api.hardcoded(element.char_id) and
		element.datatype in (qa_ss_const.number_datatype) then
        column_name := upper(QA_CORE_PKG.get_result_column_name(element.char_id, p_plan_id));
        column_name := 'QLTDATE.canon_to_number(' || column_name || ') ' || column_name;

    ELSE
	    column_name := upper(QA_CORE_PKG.get_result_column_name(
                element.char_id, p_plan_id));
    END IF;

        IF (first = 1) THEN
      	    select_clause := select_clause || column_name;
      	    first := 0;
        ELSE
      	  select_clause := select_clause || ', ' || column_name;
        END IF;

    END LOOP;

    -- rkaza. bug 3265506. 11/18/2003. Adding status column
    select_clause := select_clause || ', OCCURRENCE, PLAN_ID, STATUS ';
    RETURN select_clause;

END build_select_clause;

--
-- Bug 20844486 - ENHANCEMENTS TO QUALITY CODE FOR EAM MOBILE USE
--                copy of build_select_clause but for date elements instead of returning date it returns
--                the iso8601 equivalent by adding to select the QLTDATE.date_to_iso8601 for date elements
--
FUNCTION build_select_clause_mobile (p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS

    cursor CES is
        SELECT   result_column_name, qpc.char_id, qc.datatype
        FROM     qa_plan_chars qpc, qa_chars qc
        WHERE    plan_id = p_plan_id
        AND      qpc.char_id = qc.char_id
        AND      qpc.enabled_flag = 1
        ORDER BY prompt_sequence;

    first 		NUMBER;
    column_name 	VARCHAR2(240);
    select_clause 	VARCHAR2(32000);

BEGIN

    first := 1;

    FOR element in CES LOOP

        IF element.char_id = qa_ss_const.item THEN
            column_name := 'qa_flex_util.item(organization_id , item_id) ITEM';
	ELSIF element.char_id =  qa_ss_const.comp_item THEN
		column_name := 'qa_flex_util.item(organization_id , comp_item_id) COMP_ITEM';

        -- anagarwa Fri Feb  7 14:38:21 PST 2003
        -- Bug 2792353
        -- even though following 2 statements are for bill reference and
        -- routing reference, we still use qa_flex_util.item to get the values
        -- because foreign keys for both bill reference and routing reference
        -- point to mtl_system_items_kfv.inventory_item_id and the actual
        -- value comes from concatenated segments.
        -- Therefore there is no need to write a separate function for these
        -- 2 elements.

	ELSIF element.char_id =  qa_ss_const.bill_reference THEN
            column_name := 'qa_flex_util.item(organization_id, bill_reference_id) BILL_REFERENCE';

	ELSIF element.char_id =  qa_ss_const.routing_reference THEN
            column_name := 'qa_flex_util.item(organization_id, routing_reference_id) ROUTING_REFERENCE';

        ELSIF element.char_id = qa_ss_const.locator THEN
  	    column_name := 'qa_flex_util.locator(organization_id, locator_id)
                LOCATOR';

        ELSIF element.char_id = qa_ss_const.comp_locator THEN
  	    column_name := 'qa_flex_util.locator(organization_id, comp_locator_id)
                COMP_LOCATOR';

        ELSIF element.char_id = qa_ss_const.to_locator THEN
  	    column_name := 'qa_flex_util.locator(organization_id, to_locator_id)
               TO_LOCATOR';

        -- end of changes by anagarwa

        /*
           Bug 4261053.suramasw.

           Appending ASSET_GROUP_ID to be assigned to column_name when assigning
           ASSET_GROUP. This was done so that view quality results in EAM Asset
           Query transaction shows the quality result(s) collected only for the
           asset number, which the user tries to view. Plz see the method
           setupStandAloneQuery in QaVqrDataTopCO.java to know the details on
           why ASSET_GROUP_ID should also be assigned to column_name.
        */
--dgupta: Start R12 EAM Integration. Bug 4345492
        ELSIF element.char_id = qa_ss_const.asset_group THEN
            column_name := 'qa_flex_util.get_asset_group_name(organization_id,
                asset_group_id) ASSET_GROUP, ASSET_GROUP_ID';
--dgupta: End R12 EAM Integration. Bug 4345492
        ELSIF element.char_id = qa_ss_const.asset_activity THEN
            column_name := 'qa_flex_util.item(organization_id,
                asset_activity_id) ASSET_ACTIVITY';

-- added the following to include new hardcoded element followup activity
-- saugupta

	ELSIF element.char_id = qa_ss_const.followup_activity THEN
            column_name := 'qa_flex_util.item(organization_id,
                followup_activity_id) FOLLOWUP_ACTIVITY';

        ELSIF element.char_id = qa_ss_const.work_order THEN
            column_name := 'qa_flex_util.work_order(organization_id, work_order_id) WORK_ORDER';

	ELSIF not qa_plan_element_api.hardcoded(element.char_id) and
		element.datatype in (qa_ss_const.date_datatype ,
		qa_ss_const.datetime_datatype) then
	    column_name := upper(QA_CORE_PKG.get_result_column_name(element.char_id, p_plan_id));
	    column_name := 'QLTDATE.date_to_iso8601(fnd_date.canonical_to_date(' || column_name || ')) ' || column_name;
        ELSE
	    column_name := upper(QA_CORE_PKG.get_result_column_name(
                element.char_id, p_plan_id));
        END IF;

        IF (first = 1) THEN
      	    select_clause := select_clause || column_name;
      	    first := 0;
        ELSE
      	  select_clause := select_clause || ', ' || column_name;
        END IF;

    END LOOP;

    -- rkaza. bug 3265506. 11/18/2003. Adding status column
    select_clause := select_clause || ', OCCURRENCE, PLAN_ID, STATUS ';
    RETURN select_clause;

END build_select_clause_mobile;



FUNCTION get_txn_specific_where_clause(p_txn_number IN NUMBER, p_plan_id IN
    NUMBER, p_values_table IN qa_ss_const.ctx_table)
    RETURN VARCHAR2 IS

    CURSOR c1 IS
        SELECT collection_trigger_id
        FROM qa_txn_collection_triggers
        WHERE transaction_number = p_txn_number
        AND search_flag = 1;

    element_id NUMBER;
    column_name VARCHAR2(240);
    column_value VARCHAR2(150);
    where_clause VARCHAR2(2000) DEFAULT NULL;

BEGIN

    OPEN c1;
    LOOP

        FETCH c1 INTO element_id;
        EXIT WHEN c1%NOTFOUND;

        IF qa_plan_element_api.element_in_plan(p_plan_id, element_id) THEN

            IF element_id IN (qa_ss_const.item, qa_ss_const.comp_item) then
                column_name := 'qa_flex_util.item(organization_id , item_id)';

            ELSIF element_id IN (qa_ss_const.locator,
                qa_ss_const.comp_locator) THEN
  	        column_name := 'qa_flex_util.locator(organization_id,
                    locator_id)';
--dgupta: Start R12 EAM Integration. Bug 4345492
            ELSIF element_id IN (qa_ss_const.asset_group) then
                column_name := 'qa_flex_util.get_asset_group_name(organization_id,
                    asset_group_id)';
--dgupta: End R12 EAM Integration. Bug 4345492
            ELSIF element_id = qa_ss_const.asset_activity THEN
                column_name := 'qa_flex_util.item(organization_id,
                asset_activity_id)';

-- added the following to include new hardcoded element followup activity
-- saugupta

	    ELSIF element_id = qa_ss_const.followup_activity THEN
                column_name := 'qa_flex_util.item(organization_id,
                followup_activity_id)';


            ELSIF element_id = qa_ss_const.work_order THEN
                column_name := 'qa_flex_util.work_order(organization_id, work_order_id)';

            ELSE
	        column_name := upper(QA_CORE_PKG.get_result_column_name(
                    element_id, p_plan_id));
            END IF;

            where_clause := where_clause || ' and ' || column_name;
            column_value := p_values_table(element_id);

            IF (column_value IS NOT NULL) THEN
                where_clause := where_clause || ' =  '
                    || '''' || column_value || '''';
            ELSE
                where_clause := where_clause || ' IS NULL';
            END IF;

         END IF;

    END LOOP;
    CLOSE c1;

    RETURN where_clause;

END get_txn_specific_where_clause;


FUNCTION BUILD_OSP_VQR_SQL ( p_plan_id IN NUMBER,
    p_item IN VARCHAR2 DEFAULT NULL,
    p_revision IN VARCHAR2 DEFAULT NULL,
    p_job_name IN VARCHAR2 DEFAULT NULL,
    p_from_op_seq_num IN VARCHAR2 DEFAULT NULL,
    p_vendor_name IN VARCHAR2 DEFAULT NULL,
    p_po_number IN VARCHAR2 DEFAULT NULL,
    p_ordered_quantity IN VARCHAR2 DEFAULT NULL,
    p_vendor_item_number IN VARCHAR2 DEFAULT NULL,
    p_po_release_num IN VARCHAR2 DEFAULT NULL,
    p_uom_name IN VARCHAR2 DEFAULT NULL,
    p_production_line IN VARCHAR2 DEFAULT NULL,
    p_po_header_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS

    -- po_header_id is being added for security reasons

    select_clause 	VARCHAR2(32000);
    from_clause 	VARCHAR2(1000);
    where_clause 	VARCHAR2(1000);
    order_by_clause 	VARCHAR2(100);
    values_table        qa_ss_const.ctx_table;

BEGIN

    values_table.delete();

    values_table(qa_ss_const.item) := p_item;
    values_table(qa_ss_const.revision) := p_revision;
    values_table(qa_ss_const.job_name) := p_job_name;
    values_table(qa_ss_const.from_op_seq_num) := p_from_op_seq_num;
    values_table(qa_ss_const.vendor_name) := p_vendor_name;
    values_table(qa_ss_const.po_number) := p_po_number;
    values_table(qa_ss_const.ordered_quantity) := p_ordered_quantity;
    values_table(qa_ss_const.vendor_item_number) := p_vendor_item_number;
    values_table(qa_ss_const.po_release_num) := p_po_release_num;
    values_table(qa_ss_const.uom_name) := p_uom_name;
    values_table(qa_ss_const.production_line) := p_production_line;

    select_clause := 'SELECT ';
    from_clause   := ' FROM qa_results_v' ;
    where_clause  := ' WHERE plan_id = ' || p_plan_id ||
        ' AND' || ' (status = 2 or status is null) ' ;

    select_clause := select_clause || build_select_clause(p_plan_id);

    -- bug 3178307. rkaza. 10/07/2003. Timezone Support.
    select_clause :=  select_clause || ', '
        || 'QA_CREATED_BY_NAME'
        || ', ' || 'COLLECTION_ID' || ', '
        || 'LAST_UPDATE_DATE';


    -- If po_header_id is null then we should not return any quality results
    -- The above is for security reasons.

    IF (p_po_header_id IS NULL) THEN
        where_clause := ' WHERE 1 = 2 ';
    ELSE
        where_clause := where_clause || get_txn_specific_where_clause(
            qa_ss_const.ss_outside_processing_txn, p_plan_id, values_table);
        where_clause := where_clause ||
            ' AND PO_HEADER_ID = ' || p_po_header_id;
    END IF;

    order_by_clause := ' ORDER BY ' || 'occurrence desc';

    select_clause := select_clause || from_clause || where_clause
        || order_by_clause;

    RETURN select_clause;

End BUILD_OSP_VQR_SQL;


FUNCTION BUILD_SHIPMENT_VQR_SQL ( p_plan_id IN NUMBER,
    p_item IN VARCHAR2 DEFAULT NULL,
    p_item_category IN VARCHAR2 DEFAULT NULL,
    p_revision IN VARCHAR2 DEFAULT NULL,
    p_supplier IN VARCHAR2 DEFAULT NULL,
    p_po_number IN VARCHAR2 DEFAULT NULL,
    p_po_line_num IN VARCHAR2 DEFAULT NULL,
    p_po_shipment_num IN VARCHAR2 DEFAULT NULL,
    p_ship_to IN VARCHAR2 DEFAULT NULL,
    p_ordered_quantity IN VARCHAR2 DEFAULT NULL,
    p_vendor_item_number IN VARCHAR2 DEFAULT NULL,
    p_po_release_num IN VARCHAR2 DEFAULT NULL,
    p_uom_name IN VARCHAR2 DEFAULT NULL,
    p_supplier_site IN VARCHAR2 DEFAULT NULL,
    p_ship_to_location IN VARCHAR2 DEFAULT NULL,
    p_po_header_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS

    -- po_header_id is being added for security reasons

    select_clause 	VARCHAR2(32000);
    from_clause 	VARCHAR2(1000);
    where_clause 	VARCHAR2(1000);
    order_by_clause 	VARCHAR2(100);
    table_name 		VARCHAR2(240);
    values_table        qa_ss_const.ctx_table;

BEGIN

    values_table.delete();

    values_table(qa_ss_const.item) := p_item;
    values_table(qa_ss_const.item_category) := p_item_category;
    values_table(qa_ss_const.revision) := p_revision;
    values_table(qa_ss_const.vendor_name) := p_supplier;
    values_table(qa_ss_const.po_number) := p_po_number;
    values_table(qa_ss_const.po_line_num) := p_po_line_num;
    values_table(qa_ss_const.po_shipment_num) := p_po_shipment_num;
    values_table(qa_ss_const.ship_to) := p_ship_to;
    values_table(qa_ss_const.ordered_quantity) := p_ordered_quantity;
    values_table(qa_ss_const.vendor_item_number) := p_vendor_item_number;
    values_table(qa_ss_const.po_release_num) := p_po_release_num;
    values_table(qa_ss_const.uom_name) := p_uom_name;
    values_table(qa_ss_const.vendor_site_code) := p_supplier_site;
    values_table(qa_ss_const.ship_to_location) := p_ship_to_location;

    select_clause := 'SELECT ';
    from_clause   := ' FROM qa_results_v' ;
    where_clause  := ' WHERE plan_id = ' || p_plan_id ||
        ' AND' || ' (status = 2 or status is null) ' ;

    select_clause := select_clause || build_select_clause(p_plan_id);

    -- bug 3178307. rkaza. 10/07/2003. Timezone Support.
    select_clause :=  select_clause || ', '
        || 'QA_CREATED_BY_NAME'
        || ', ' || 'COLLECTION_ID' || ', '
        || 'LAST_UPDATE_DATE';

    -- If po_header_id is null then we should not return any quality results
    -- The above is for security reasons.

    IF (p_po_header_id IS NULL) THEN
        where_clause := ' WHERE 1 = 2 ';
    ELSE
        where_clause := where_clause || get_txn_specific_where_clause(
            qa_ss_const.ss_shipments_txn, p_plan_id, values_table);
        where_clause := where_clause ||
            ' AND PO_HEADER_ID = ' || p_po_header_id;
    END IF;

    order_by_clause := ' ORDER BY ' || 'occurrence desc';

    select_clause := select_clause || from_clause || where_clause
        || order_by_clause;

    RETURN select_clause;

End BUILD_SHIPMENT_VQR_SQL;


FUNCTION BUILD_OM_VQR_SQL ( p_plan_id IN NUMBER,
    p_so_header_id IN VARCHAR2,
    p_so_line_id IN VARCHAR2 DEFAULT NULL,
    p_item_id IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS

    select_clause 	VARCHAR2(32000);
    from_clause 	VARCHAR2(1000);
    where_clause 	VARCHAR2(1000);
    order_by_clause 	VARCHAR2(100);

    l_sales_order_id NUMBER := -99;

BEGIN

    select_clause := 'SELECT ';
    from_clause   := ' FROM qa_results_v' ;
    where_clause  := ' WHERE plan_id = ' || p_plan_id ||
        ' AND' || ' (status = 2 or status is null) ' ;

    select_clause := select_clause || build_select_clause(p_plan_id);

    -- bug 3178307. rkaza. 10/07/2003. Timezone Support.
    select_clause :=  select_clause || ', '
        || 'QA_CREATED_BY_NAME'
        || ', ' || 'COLLECTION_ID' || ', '
        || 'LAST_UPDATE_DATE';

	l_sales_order_id :=
		qa_results_interface_pkg.OEHeader_to_MTLSales
			( p_so_header_id );

    where_clause := where_clause || 'AND so_header_id = ' || l_sales_order_id;

    IF (p_item_id IS NOT NULL) THEN
        where_clause := where_clause || 'AND item_id = ' || p_item_id;
    END IF;

    order_by_clause := ' ORDER BY ' || 'occurrence desc';

    select_clause := select_clause || from_clause || where_clause
        || order_by_clause;

    RETURN select_clause;

End BUILD_OM_VQR_SQL;

--parent-child modifications
FUNCTION get_plan_vqr_sql (p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS

    select_clause 	VARCHAR2(32000);
    from_clause 	VARCHAR2(1000);
    where_clause	VARCHAR2(1000);
BEGIN

    select_clause := 'SELECT ';
    from_clause   := ' FROM qa_results_v' ;
    -- where_clause  := ' WHERE plan_id = ' || p_plan_id ;
    select_clause := select_clause || build_select_clause(p_plan_id);
    select_clause := select_clause || ' , name ';
    --Ilam removed extra collection id from above
    --it was redundant collection_id was mentioned twice earlier

    select_clause :=  select_clause || ', ' || 'QA_CREATED_BY_NAME' || ', '
        || 'COLLECTION_ID' || ', ' || 'LAST_UPDATE_DATE';

    --  || 'fnd_date.date_to_chardt(LAST_UPDATE_DATE) LAST_UPDATE_DATE';

    RETURN select_clause || from_clause;

END get_plan_vqr_sql;


--
-- Bug 20844486 - ENHANCEMENTS TO QUALITY CODE FOR EAM MOBILE USE
--                copy of get_plan_vqr_sql but instead of calling build_select_clause
--                build_select_clause_mobile. Also add the last_update_date with a function
--                to convert to iso8601.
--
FUNCTION get_plan_vqr_sql_mobile (p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS

    select_clause 	VARCHAR2(32000);
    from_clause 	VARCHAR2(1000);
    where_clause	VARCHAR2(1000);
BEGIN

    select_clause := 'SELECT ';
    from_clause   := ' FROM qa_results_v' ;
    -- where_clause  := ' WHERE plan_id = ' || p_plan_id ;
    select_clause := select_clause || build_select_clause_mobile(p_plan_id);
    select_clause := select_clause || ' , name ';
    --Ilam removed extra collection id from above
    --it was redundant collection_id was mentioned twice earlier

    select_clause :=  select_clause || ', ' || 'QA_CREATED_BY_NAME' || ', '
        || 'COLLECTION_ID' || ', ' || 'QLTDATE.date_to_iso8601(LAST_UPDATE_DATE) LAST_UPDATE_DATE';

    --  || 'fnd_date.date_to_chardt(LAST_UPDATE_DATE) LAST_UPDATE_DATE';

    RETURN select_clause || from_clause;

END get_plan_vqr_sql_mobile;


FUNCTION build_asset_vqr_sql ( p_plan_id IN NUMBER DEFAULT NULL,
    p_asset_group IN VARCHAR2 DEFAULT NULL,
    p_asset_number IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS

    select_clause 	VARCHAR2(32000);
    from_clause 	VARCHAR2(1000);
    where_clause 	VARCHAR2(1000);
    order_by_clause 	VARCHAR2(100);

BEGIN

    select_clause := 'SELECT ';
    from_clause   := ' FROM qa_results_v' ;
    where_clause  := ' WHERE plan_id = ' || p_plan_id ||
        ' AND' || ' (status = 2 or status is null) ' ;

    select_clause := select_clause || build_select_clause(p_plan_id);

    select_clause :=  select_clause || ', '
        || 'QA_CREATED_BY_NAME'
        || ', ' || 'COLLECTION_ID' || ', '
        || 'fnd_date.date_to_chardt(LAST_UPDATE_DATE,2) LAST_UPDATE_DATE';

    order_by_clause := ' ORDER BY ' || 'occurrence desc';

    select_clause := select_clause || from_clause;

    -- || where_clause
    --    || order_by_clause;

    RETURN select_clause;

END build_asset_vqr_sql;


PROCEDURE START_IMPORT_ROW ( proc_status IN NUMBER,
    			     org_id IN NUMBER,
			     given_plan_id IN NUMBER,
    			     script OUT NOCOPY VARCHAR2,
    			     tail_script OUT NOCOPY VARCHAR2,
			     source_code IN VARCHAR2 default null,
			     source_line_id IN NUMBER default null,
			     po_agent_id IN NUMBER default null )  IS

    plan_name           qa_plans.name%TYPE;
    org_code 		mtl_parameters.organization_code%TYPE;



BEGIN

	script := null;
	tail_script := null;

 	select organization_code into org_code
  	from mtl_parameters
	where organization_id = org_id;


      	select name into plan_name
	from qa_plans
	where plan_id = given_plan_id;

      	-- plan_name := ''''||upper(plan_name)|| '''';
	-- CHANGED on Aug 20,1999 to fix single quotes problem
 	plan_name := upper(plan_name);


      	script := 'Insert into qa_results_interface ' ||
                '(process_status, organization_code, plan_name, source_code, source_line_id, po_agent_id';

      	tail_script := ' values ( ' ||  proc_status || ', '
                     || '''' || dequote(org_code) || '''' || ', '|| '''' ||
				dequote(plan_name) || '''';
	-- CHANGED on Aug 20,1999 to fix single quotes problem
	-- Because dequote for plan_name was causing problem above

	if (source_code is not null) then
		tail_script := tail_script || ', ' || '''' ||source_code || '''';
	else
		tail_script := tail_script || ', null ';
	end if;


	if (source_line_id is not null) then
		tail_script := tail_script || ', ' || '''' || to_char(source_line_id)|| '''';
	else
		tail_script := tail_script || ', null ';
end if;

	if (po_agent_id is not null) then
		tail_script := tail_script || ', ' || '''' || to_char(po_agent_id)|| '''';
	else
		tail_script := tail_script || ', null ';
end if;



 EXCEPTION  when others then
	raise;

END START_IMPORT_ROW;



FUNCTION  ADD_ELEMENT_VALUE ( GIVEN_PLAN_ID IN NUMBER,
                              ELEMENT_ID IN NUMBER,
                              ELEMENT_VALUE IN VARCHAR2,
                              SCRIPT IN OUT NOCOPY VARCHAR2,
                              TAIL_SCRIPT IN OUT NOCOPY VARCHAR2) return NUMBER IS

BEGIN

 	DECLARE
		DATE_FORMAT_ERROR 	EXCEPTION;
		INVALID_DATE 		EXCEPTION;

		PRAGMA EXCEPTION_INIT (DATE_FORMAT_ERROR, -1861);
		PRAGMA EXCEPTION_INIT (INVALID_DATE, -1858);

    		element_name 		VARCHAR2(240);
	    	temp_date		DATE;
	    	temp			VARCHAR2(240);
	    	temp_num 		NUMBER;
		date_flag		NUMBER default 0;
BEGIN


 	if (ELEMENT_ID is not null) then


		if (ELEMENT_VALUE is null) then
			if (QA_CORE_PKG.is_mandatory (GIVEN_PLAN_ID, ELEMENT_ID) = True) then
				return 4;
			end if;
		end if;

        	element_name := QA_CORE_PKG.get_result_column_name (ELEMENT_ID, given_plan_id);

		script := script || ', ' || element_name;

        	if (QA_CORE_PKG.get_element_data_type(Element_ID) = 3 ) then
           		if (ELEMENT_ID = 1 ) then
			 	date_flag := -1;
              			temp_date := qltdate.any_to_date(ELEMENT_VALUE);
				date_flag := 0;
              			tail_script := tail_script || ', ' || ''''|| temp_date || '''';
           		else
              			temp :=qltdate.any_to_canon(ELEMENT_VALUE);
              			tail_script := tail_script || ', ' || ''''|| temp || '''';
           		end if;

        	elsif (QA_CORE_PKG.get_element_data_type(ELEMENT_ID) = 2 ) then
              		temp_num := to_number(ELEMENT_VALUE);
              		tail_script := tail_script || ', ' || ''''|| temp_num || '''';
        	else
              		tail_script := tail_script || ', ' || ''''|| dequote(ELEMENT_VALUE) || '''';
        	end if;
		return 0;

      else
		return -1;

      end if;


    EXCEPTION

	when INVALID_NUMBER or VALUE_ERROR then
		return 2;

	when DATE_FORMAT_ERROR OR INVALID_DATE then
		return 3;

	when OTHERS then
		if (date_flag = -1) then
			return 3;
		else
			return 1;
		end if;
END;

END ADD_ELEMENT_VALUE;



PROCEDURE END_IMPORT_ROW ( script IN VARCHAR2,
	                   tail_script IN VARCHAR2, no_error IN BOOLEAN) IS

	final_script VARCHAR2(32000);

BEGIN

	if (no_error) then

      		final_script := script || ') ' || taiL_script || ')';
		-- htp.p(final_script); htp.nl;
		QA_CORE_PKG.EXEC_SQL(final_script);

	end if;


  EXCEPTION  when others then
	raise;

END END_IMPORT_ROW;



FUNCTION COMMIT_ROWS RETURN NUMBER IS

BEGIN

 commit;
 return 0;

 EXCEPTION  when others then
	raise;
END;


FUNCTION ROLLBACK_ROWS RETURN NUMBER IS

BEGIN

 rollback;
 return 0;

 EXCEPTION  when others then
	raise;

END;



--Bug 3140760
--A sales order has a representation in two tables
--OE_HEADERS_ALL.HEADER_ID and MTL_SALES_ORDERS.SALES_ORDER_ID
--Given a header id, finding the equivalent sales_order_id is a little tricky
--Similar logic is done in the view QA_SALES_ORDERS_LOV_V
--Function below is built for Convenience purpose
--This function takes a SO Header id (OE_HEADERS_ALL.HEADER_ID)
--Computes the equivalent Sales_order_id in Mtl_sales_orders and return it
--
FUNCTION OEHEADER_TO_MTLSALES ( p_oe_header_id IN NUMBER )
	RETURN NUMBER
IS

  l_sales_order_id NUMBER := -99;

    --
    -- bug 4328665
    -- Added the function to_char() to the
    -- filtering condition
    -- mso.segment1 = oe.order_number
    -- so that the index MTL_SALES_ORDERS_N1 is
    -- refrerred to; while selecting the data from
    -- MTL_SALES_ORDERS table, instead of doing
    -- a FTS.
    -- ntungare Wed May  2 03:50:09 PDT 2007
    --
    CURSOR mtl_so_cur IS
      SELECT mso.sales_order_id
      FROM mtl_sales_orders mso,
           oe_order_headers_all oe,
           qa_customers_lov_v rc,
           oe_transaction_types_tl ot,
           fnd_languages fl
      WHERE mso.segment1 = to_char(oe.order_number)
            AND oe.order_type_id = ot.transaction_type_id
            AND ot.language = fl.language_code
            AND fl.installed_flag = 'B'
            AND oe.sold_to_org_id = rc.customer_id (+)
            AND mso.segment2 = ot.name
            AND mso.segment3 = fnd_profile.value('ONT_SOURCE_CODE')
            AND oe.header_id = p_oe_header_id;

BEGIN

    open  mtl_so_cur;
    fetch mtl_so_cur into l_sales_order_id;
    close mtl_so_cur;

    RETURN l_sales_order_id; -- Negative 99 returned if not found

END OEHEADER_TO_MTLSALES;



end QA_RESULTS_INTERFACE_PKG;


/
