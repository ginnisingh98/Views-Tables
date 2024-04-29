--------------------------------------------------------
--  DDL for Package Body QA_SS_LOV_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_LOV_API" AS
/* $Header: qltsslob.plb 120.16.12010000.10 2010/04/26 17:14:25 ntungare ship $ */


TYPE qa_plan_chars_table IS TABLE OF qa_plan_chars%ROWTYPE
    INDEX BY BINARY_INTEGER;

--
-- Package Variables: These will be populated at run time
--

x_qa_plan_chars_array           qa_plan_chars_table;
g_bind_value_list_seperator CONSTANT VARCHAR2(3) := ',';


-- anagarwa Thu Aug 12 15:49:51 PDT 2004
-- bug 3830258 incorrect LOVs in QWB
-- utility method to check if given item is revision controlled or not.
FUNCTION is_item_revision_controlled(p_item_id IN NUMBER ,
                                     p_org_id IN NUMBER)
RETURN BOOLEAN IS

l_rev_control_code NUMBER;

CURSOR c IS
  SELECT  revision_qty_control_code
  FROM    mtl_system_items
  WHERE   inventory_item_id = p_item_id
  AND     organization_id = p_org_id;
BEGIN

  OPEN c;
  FETCH c INTO l_rev_control_code;
  IF (c%FOUND AND l_rev_control_code = 2) THEN
     CLOSE c;
     RETURN true;
  END IF;
  CLOSE c;
  RETURN false;

END is_item_revision_controlled;


-- anagarwa Thu Aug 12 15:49:51 PDT 2004
-- bug 3830258 incorrect LOVs in QWB
-- utility method to check if given item is lot controlled or not.
FUNCTION is_item_lot_controlled(p_item_id IN NUMBER ,
                                p_org_id IN NUMBER)
RETURN BOOLEAN IS

l_lot_control_code NUMBER;

CURSOR c IS
  SELECT  lot_control_code
  FROM    mtl_system_items
  WHERE   inventory_item_id = p_item_id
  AND     organization_id = p_org_id;
BEGIN

  OPEN c;
  FETCH c INTO l_lot_control_code;
  IF (c%FOUND AND l_lot_control_code = 2) THEN
     CLOSE c;
     RETURN true;
  END IF;
  CLOSE c;
  RETURN false;

END is_item_lot_controlled;



    --
    -- All the fetch_... procedures are auxiliary caching functions
    -- called only by inquiry APIs that return the object's attributes.
    --

    --
    -- This plan element index is used to hash plan id and element id
    -- into one unique integer to be used as index into the cache.
    -- Can also be used by spec_chars.
    --

FUNCTION plan_element_index(plan_id IN NUMBER, element_id IN NUMBER)
    RETURN NUMBER IS

    i NUMBER;
BEGIN
    --
    -- Bug 2409938
    -- This is a potential installation/upgrade error.
    -- Error happens if there is some customization of
    -- collection plans or elements with huge IDs.
    -- Temporarily fixed with a modulus.  It should be
    -- properly fixed with a hash collision resolution.
    -- But the temp workaround should only have collision
    -- when user has more than 20,000 collection plans
    -- *and still* with a probability of about 1/200,000.
    -- bso Tue Jul 16 12:41:23 PDT 2002
    --

    --
    -- Bug 2465704
    -- The above hash collision problem is now fixed with
    -- linear hash collision resolution.
    -- The plan_element array is hit to see if the index
    -- contains the right plan element.  If not, we search
    -- forward until either the matching plan element is
    -- reached or an empty cell is reached.
    --
    -- Because of this, we need to introduce a new function
    -- spec_element_index for use by the spec_element array.
    -- bso Sun Dec  1 17:39:18 PST 2002
    --
    -- COMMENTS: its seems like this caching mechanism is
    -- a mirror copy of that in qltelemb.  Can this one be
    -- removed?
    --

    i := mod(plan_id * qa_ss_const.max_elements + element_id,
           2147483647);

    LOOP
        IF NOT x_qa_plan_chars_array.EXISTS(i) THEN
            RETURN i;
        END IF;

        IF x_qa_plan_chars_array(i).plan_id = plan_id AND
           x_qa_plan_chars_array(i).char_id = element_id THEN
            RETURN i;
        END IF;

        i := mod(i + 1, 2147483647);
    END LOOP;

END plan_element_index;


FUNCTION exists_qa_plan_chars(plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN IS
BEGIN

    RETURN x_qa_plan_chars_array.EXISTS(
        plan_element_index(plan_id, element_id));
END exists_qa_plan_chars;


PROCEDURE fetch_qa_plan_chars (plan_id IN NUMBER, element_id IN NUMBER) IS

    CURSOR C1 (p_id NUMBER, e_id NUMBER) IS
        SELECT *
        FROM qa_plan_chars
        WHERE plan_id = p_id AND char_id = e_id;

BEGIN

    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN

        OPEN C1(plan_id, element_id);
        FETCH C1 INTO x_qa_plan_chars_array(
            plan_element_index(plan_id, element_id));

        CLOSE C1;
    END IF;

    EXCEPTION WHEN OTHERS THEN
        RAISE;
END fetch_qa_plan_chars;

--parent-child addition
FUNCTION qa_chars_values_exist (x_char_id IN NUMBER)
    RETURN BOOLEAN IS

        result BOOLEAN;
        dummy NUMBER;

        CURSOR c IS
                select 1
                from qa_chars qc
                where qc.char_id = x_char_id
                AND qc.values_exist_flag = 1;
BEGIN
    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;



END qa_chars_values_exist;
---

FUNCTION qpc_values_exist_flag(plan_id IN NUMBER,
    element_id IN NUMBER) RETURN NUMBER IS
BEGIN

    fetch_qa_plan_chars(plan_id, element_id);
    IF NOT exists_qa_plan_chars(plan_id, element_id) THEN
        RETURN NULL;
    END IF;

    RETURN x_qa_plan_chars_array(plan_element_index(plan_id, element_id)).
        values_exist_flag;
END qpc_values_exist_flag;


FUNCTION values_exist (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    RETURN qpc_values_exist_flag(plan_id, element_id) = 1;

END values_exist;


FUNCTION sql_validation_exists (element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    RETURN qa_chars_api.sql_validation_string(element_id) IS NOT NULL;

END sql_validation_exists;


FUNCTION element_in_plan (plan_id IN NUMBER, element_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    fetch_qa_plan_chars(plan_id, element_id);
    RETURN exists_qa_plan_chars(plan_id, element_id);

END element_in_plan;


FUNCTION get_sql_validation_string (element_id IN NUMBER)
    RETURN VARCHAR2 IS
BEGIN
    RETURN qa_chars_api.sql_validation_string(element_id);
END get_sql_validation_string;


FUNCTION sql_string_exists(x_plan_id IN NUMBER, x_char_id IN NUMBER,
    org_id IN NUMBER, user_id NUMBER, x_lov_sql OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN IS

BEGIN

    IF (x_plan_id = -1) THEN
        IF qa_chars_values_exist(x_char_id) THEN
                x_lov_sql := 'SELECT short_code, description
                      FROM   qa_char_value_lookups
                      WHERE  char_id = :1 ';

                RETURN TRUE;
                -- we will not go down further in the chain
        END IF;
    END IF;

    -- if x_plan_id is not -1, then proceed as below

    IF values_exist(x_plan_id, x_char_id) THEN
        x_lov_sql := 'SELECT short_code, description
                      FROM   qa_plan_char_value_lookups
                      WHERE  plan_id = :1
                      AND    char_id = :2';
        RETURN TRUE;

    ELSIF sql_validation_exists(x_char_id) THEN

        x_lov_sql := get_sql_validation_string(x_char_id);
        x_lov_sql := qa_chars_api.format_sql_for_lov(x_lov_sql,
            org_id, user_id);

        RETURN TRUE;

    ELSE
        RETURN FALSE;
    END IF;

END sql_string_exists;

FUNCTION sql_string_bind_values(p_plan_id IN NUMBER,
                                p_char_id IN NUMBER)
                                      RETURN VARCHAR2 IS

BEGIN

    IF (p_plan_id = -1) THEN
        IF qa_chars_values_exist(p_char_id) THEN

                RETURN to_char(p_char_id);

        END IF;
    END IF;

    -- if p_plan_id is not -1, then proceed as below

    IF values_exist(p_plan_id, p_char_id) THEN
        RETURN to_char(p_plan_id) || g_bind_value_list_seperator || to_char(p_char_id);

    END IF;

    RETURN NULL;

END sql_string_bind_values;

-- *** start of get_lov functions ****


PROCEDURE get_department_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT department_code, description
                  FROM   bom_departments_val_v
                  WHERE organization_id = :1
                  ORDER BY department_code';

END get_department_lov;


PROCEDURE get_job_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

 -- #2382432
 -- Changed the view to WIP_DISCRETE_JOBS_ALL_V instead of
 -- earlier wip_open_discrete_jobs_val_v
 -- rkunchal Sun Jun 30 22:59:11 PDT 2002

    x_lov_sql := 'SELECT wip_entity_name, description
                   FROM  wip_discrete_jobs_all_v
                   WHERE organization_id = :1
                   ORDER BY wip_entity_name';

END get_job_lov;


PROCEDURE get_work_order_lov(org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
/* rkaza 10/21/2002. Bug 2635736 */
    x_lov_sql :=
    'select WE.wip_entity_name, WDJ.description
     from wip_entities WE, wip_discrete_jobs WDJ
     where WDJ.organization_id = :1  and
           WDJ.status_type in (3,4) and
           WDJ.wip_entity_id = WE.wip_entity_id and
           WE.entity_type IN (6, 7)
     order by WE.wip_entity_name';

END get_work_order_lov;


PROCEDURE get_production_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT line_code, description
                   FROM  wip_lines_val_v
                   WHERE organization_id = :1
                   ORDER BY line_code';


END get_production_lov;


PROCEDURE get_resource_code_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT resource_code, description
                   FROM   bom_resources_val_v
                   WHERE  organization_id = :1
                   ORDER BY resource_code';

END get_resource_code_lov;


PROCEDURE get_supplier_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT vendor_name, segment1
                  FROM   po_vendors
                  WHERE  nvl(end_date_active, sysdate + 1) > sysdate
                  ORDER BY vendor_name';



END get_supplier_lov;

  --
  -- Bug 5003511. R12 Performance bug. SQLID: 15008553
  -- After MOAC changes, PO Number uses different LOV logic.
  -- This method is not used. So stubbing it out.
  -- srhariha. Wed Feb  8 02:10:26 PST 2006.
  --

PROCEDURE get_po_number_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    -- Bug 3215866 ksoh Wed Oct 29 16:21:11 PST 2003
    -- fixed sql to make it return value instead of id.

/*
    x_lov_sql := 'SELECT  segment1, vendor_name
                   FROM   po_pos_val_v
                   ORDER BY po_header_id';
*/
    x_lov_sql := NULL;

END get_po_number_lov;


PROCEDURE get_customer_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    -- Bug 3384771 ksoh Wed Jan 21 10:23:25 PST 2004
    -- fixed sql to make it return value instead of id.
    x_lov_sql := 'SELECT customer_name, customer_number
                  FROM   qa_customers_lov_v
                  WHERE  status = ''A''
                  AND nvl(customer_prospect_code, ''CUSTOMER'') = ''CUSTOMER''
                  ORDER BY customer_number';

END get_customer_lov;


PROCEDURE get_so_number_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT order_number, order_type
                  FROM   qa_sales_orders_lov_v mso
                  ORDER BY order_number';

END get_so_number_lov;
 --
 -- Bug 5003511. R12 Performance bug. SQLID: 15008608
 -- SO Line number is not at all an LOV. So simply stubbing
 -- out the procedure.
 -- srhariha. Wed Feb  8 02:10:26 PST 2006.
 --

 -- Bug 7716875.pdube Mon Apr 13 03:25:19 PDT 2009
 -- Introduced new procedure to get the LOV of SO Line Number
 -- Based on the SO Number element value.Commenting the old one.
/*PROCEDURE get_so_line_number_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN


    /*x_lov_sql := 'SELECT to_char(sl.line_number), msik.concatenated_segments
                  FROM   mtl_system_items_kfv msik, so_lines sl
                  WHERE  sl.inventory_item_id = msik.inventory_item_id'; *//*

    x_lov_sql := NULL;

END get_so_line_number_lov;*/

PROCEDURE get_so_line_number_lov (p_plan_id IN NUMBER,
 	                              p_so_number IN VARCHAR2,
 	                              value IN VARCHAR2,
 	                              x_lov_sql OUT NOCOPY VARCHAR2) IS
 	 BEGIN

 	     IF (p_so_number is null) THEN
 	         fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
 	         fnd_message.set_token('DEPELEM',
 	         qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.sales_order));
 	         fnd_msg_pub.add();
 	     END IF;

 	     x_lov_sql := 'select distinct to_char(oel.line_number) ,''Sales Order: '' ||
 	                   oeha.order_number || '';'' || ''Item: '' || oel.ordered_item  description
 	                   from oe_order_lines_all oel, oe_order_headers_all oeha
 	                   where oel.header_id = oeha.header_id ' ||
 	                   ' and oeha.order_number = :1 ' ||
 	                   ' order by description, line_number ';

END get_so_line_number_lov;

 -- Bug 7716875
 -- Return so_number as bind value for LOV of SO Line Number
 -- pdube Mon Apr 13 03:25:19 PDT 2009
 FUNCTION get_so_line_num_bind_values (p_so_number IN VARCHAR2)
                                                RETURN VARCHAR2 IS
 BEGIN

   IF (p_so_number IS NULL) THEN
     RETURN NULL;
   END IF;

   RETURN to_char(p_so_number);

 END get_so_line_num_bind_values;

  --
  -- Bug 5003511. R12 Performance bug. SQLID: 15008630
  -- Release number is dependent on PO Number.
  -- As per safe spec, creating an overloaded method for getting
  -- the lov sql. Also created new method for getting the bind value.
  -- srhariha. Wed Feb  8 02:10:26 PST 2006.
  --
PROCEDURE get_po_release_number_lov (p_plan_id IN NUMBER,
                                     po_header_id IN VARCHAR2,
                                     value IN VARCHAR2,
                                     x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    IF ((p_plan_id is not null) AND (po_header_id is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.po_number));
        fnd_msg_pub.add();
    END IF;

    x_lov_sql := 'SELECT to_char(release_num), QLTDATE.date_to_user(release_date) ' ||
                 'FROM   po_releases pr ' ||
                 'WHERE  pr.po_header_id = :1 ' ||
                 'ORDER BY pr.release_num ';

END get_po_release_number_lov;

FUNCTION get_po_rel_no_bind_values (p_po_header_id IN VARCHAR2)
                                                   RETURN VARCHAR2 IS

BEGIN

    RETURN p_po_header_id;

END get_po_rel_no_bind_values;

-- End Bug 5003511. SQLID : 15008630.

-- Bug 5003511 SQLID : 15008630
-- commneting out unused overridden procedure below
-- saugupta Tue, 14 Feb 2006 07:07:11 -0800 PDT
/*
PROCEDURE get_po_release_number_lov (value IN VARCHAR2, x_lov_sql OUT
    NOCOPY VARCHAR2) IS

BEGIN
    -- Bug 3215866 ksoh Wed Oct 29 16:21:11 PST 2003
    -- added to_char and QLTDATE to lov sql to make it compatible to
    -- char column when it is union with the kludge sql: select '1'.....
    x_lov_sql := 'SELECT to_char(release_num), QLTDATE.date_to_user(release_date)
                  FROM   po_releases pr
                  ORDER BY pr.release_num';

END get_po_release_number_lov;
*/

PROCEDURE get_project_number_lov (value IN VARCHAR2, x_lov_sql OUT
    NOCOPY VARCHAR2) IS

BEGIN
/*
mtl_project_v changed to pjm_projects_all_v (selects from both pjm enabled and
non-pjm enabled orgs).
rkaza, 11/10/2001.
*/

--
--  Bug 5249078.  Changed pjm_projects_all_v to
--  pjm_projects_v for MOAC compliance.
--  bso Thu Jun  1 10:46:50 PDT 2006
--

    x_lov_sql := 'SELECT project_number, project_name
                  FROM   pjm_projects_v
                  ORDER BY project_number';

END get_project_number_lov;


/*
 anagarwa Thu Jan 29 15:04:26 PST 2004
 Bug 3404863 : Task LOV should be dependent upon Project lov
 We look for project number and get project id and then add this to where
 clause of task lov sql

*/
PROCEDURE get_task_number_lov (plan_id IN NUMBER,
                               p_project_number IN VARCHAR2,
                               value IN VARCHAR2,
                               x_lov_sql OUT
    NOCOPY VARCHAR2) IS

 l_project_id NUMBER ;

BEGIN

    l_project_id := qa_plan_element_api.get_project_number_id(p_project_number);
    IF (l_project_id is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
            qa_plan_element_api.get_prompt(plan_id, qa_ss_const.project_number));
        fnd_msg_pub.add();
    END IF;

    x_lov_sql := 'select task_number, task_name
                  from mtl_task_v
                  where project_id = :1
                  ORDER BY task_number';

END get_task_number_lov;

-- Bug 4270911. SQL bind compliance fix.
-- New function added to return bind values.
-- Please see bugdb for more details and TD link.
-- srhariha. Thu Apr  7 21:43:08 PDT 2005

FUNCTION get_task_number_bind_values (p_project_number IN VARCHAR2)
                                                       RETURN VARCHAR2  IS

l_project_id NUMBER;
BEGIN

 l_project_id := qa_plan_element_api.get_project_number_id(p_project_number);

 RETURN to_char(l_project_id);

END get_task_number_bind_values;

PROCEDURE get_task_number_lov (value IN VARCHAR2, x_lov_sql OUT
    NOCOPY VARCHAR2) IS

BEGIN

    -- anagarwa Thu Jan 29 15:04:26 PST 2004
    -- Bug 3404863 : task lov should be dependent upon project.
    get_task_number_lov(NULL, NULL, value, x_lov_sql);
/*
    x_lov_sql := 'SELECT task_number, task_name
                  FROM   mtl_task_v
                  ORDER BY task_number';
*/

END get_task_number_lov;


PROCEDURE get_rma_number_lov (value IN VARCHAR2, x_lov_sql OUT
    NOCOPY VARCHAR2) IS

BEGIN
    -- Bug 3215866 ksoh Wed Oct 29 16:21:11 PST 2003
    -- added to_char to lov sql to make it compatible to
    -- char column when it is union with the kludge sql: select '1'.....
    x_lov_sql := 'SELECT to_char(sh.order_number), sot.name
                  FROM   so_order_types sot,
                         oe_order_headers sh,
                         qa_customers_lov_v rc
                  WHERE  sh.order_type_id = sot.order_type_id and
                         sh.sold_to_org_id = rc.customer_id and
                         sh.order_category_code in (''RETURN'', ''MIXED'')
                  ORDER BY sh.order_number';

END get_rma_number_lov;

--
-- Bug 6161802
-- Added procedure to return lov for rma line number
-- with rma number as a bind variable
-- skolluku Mon Jul 16 22:08:16 PDT 2007
--
PROCEDURE get_rma_line_num_lov (p_plan_id IN NUMBER,
                                p_rma_number IN VARCHAR2,
                                value IN VARCHAR2,
                                x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    IF (p_rma_number is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.rma_number));
        fnd_msg_pub.add();
    END IF;

    x_lov_sql := 'select distinct to_char(oel.line_number),''RMA Number: '' ||
                  sh.order_number || '';'' || ''Item: '' || oel.ordered_item  description
                  from oe_order_lines oel, so_order_types sot, oe_order_headers sh
                  where sh.order_type_id = sot.order_type_id ' ||
                  ' and oel.header_id = sh.header_id ' ||
                  ' and oel.line_category_code in (''RETURN'', ''MIXED'') ' ||
                  ' and sh.order_number = :1 ' ||
                  ' order by description, line_number ';

END get_rma_line_num_lov;

--
-- Bug 6161802
-- Return rma number as bind value for rma line number lov
-- skolluku Mon Jul 16 22:08:16 PDT 2007
--
FUNCTION get_rma_line_num_bind_values (p_rma_number IN VARCHAR2)
                                               RETURN VARCHAR2 IS
BEGIN

  IF (p_rma_number IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(p_rma_number);

END get_rma_line_num_bind_values;


-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior
PROCEDURE get_uom_lov (plan_id IN NUMBER, org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

    -- x_item_id NUMBER DEFAULT NULL;

BEGIN
    IF ((plan_id is not null) and (x_item_name is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.item));
        fnd_msg_pub.add();
    END IF;

    -- This procedure is used for both uom and component uom

    -- x_item_id := qa_flex_util.get_item_id(org_id, x_item_name);

    x_lov_sql := 'SELECT uom_code, description
                   FROM   mtl_item_uoms_view
                   WHERE organization_id = :1
                   AND inventory_item_id = :2
                   ORDER BY uom_code';

END get_uom_lov;

PROCEDURE get_uom_lov (org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_uom_lov (NULL, org_id, x_item_name, value, x_lov_sql);
END get_uom_lov;

-- Bug 5005707. New function to return the proper bind values
-- saugupta Mon, 10 Jul 2006 21:51:04 -0700 PDT
FUNCTION get_uom_bind_values (p_org_id IN NUMBER,
                                   p_item_name IN VARCHAR2)
                                               RETURN VARCHAR2 IS

l_item_id NUMBER;

BEGIN

  l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

  IF (l_item_id IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_item_id) ;

END get_uom_bind_values;



-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior
PROCEDURE get_revision_lov (plan_id IN NUMBER, org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

    -- x_item_id NUMBER DEFAULT NULL;

BEGIN
    IF ((plan_id is not null) AND (x_item_name is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.item));
        fnd_msg_pub.add();
    END IF;

    -- This procedure is used for both revision and component revision

    -- x_item_id := qa_flex_util.get_item_id(org_id, x_item_name);

    -- anagarwa Mon Feb 24 17:08:57 PST 2003
    -- Bug 2808693
    -- using  QLTDATE.date_to_user for effectivity date as LOV's in selfservice
    -- expect both selected columns to be varchar2 or they give an Error.

    -- Bug 5371467. Rewriting revision LOV SQL
    -- saugupta Tue, 18 Jul 2006 01:30:18 -0700 PDT
/*
    x_lov_sql := 'SELECT revision, QLTDATE.date_to_user(effectivity_date)
                   FROM   mtl_item_revisions
                   WHERE  inventory_item_id = :1
                   AND    organization_id = :2
                   ORDER BY revision';
*/
    x_lov_sql := 'SELECT revision, QLTDATE.date_to_user(effectivity_date)
                   FROM mtl_item_revisions mir,
                     mtl_system_items_kfv msi
                   WHERE mir.inventory_item_id         = msi.inventory_item_id
                   AND mir.organization_id           = msi.organization_id
                   AND msi.revision_qty_control_code = 2
                   AND mir.inventory_item_id         = :1
                   AND mir.organization_id           = :2
                   ORDER BY revision';

END get_revision_lov;


FUNCTION get_revision_bind_values (p_org_id IN NUMBER,
                                   p_item_name IN VARCHAR2)
                                               RETURN VARCHAR2 IS

l_item_id NUMBER;

BEGIN

  l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

  IF (l_item_id IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(l_item_id) || g_bind_value_list_seperator || to_char(p_org_id) ;

END get_revision_bind_values;

PROCEDURE get_revision_lov (org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_revision_lov (NULL, org_id, x_item_name, value, x_lov_sql);
END get_revision_lov;


PROCEDURE get_subinventory_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    -- This procedure is used for both subinventory and component subinventory

    x_lov_sql := 'SELECT secondary_inventory_name, description
                   FROM   mtl_secondary_inventories
                   WHERE  organization_id = :1
                   AND    nvl(disable_date, sysdate+1) > sysdate ';
                --   ORDER BY secondary_inventory_name';

END get_subinventory_lov;


-- anagarwa Thu Aug 12 15:49:51 PDT 2004
-- bug 3830258 incorrect LOVs in QWB
-- synced up the lot number lov with forms
PROCEDURE get_lot_number_lov (p_plan_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_item IN VARCHAR2,
                              value IN VARCHAR2,
                              x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN

    IF (p_item is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.item));
        fnd_msg_pub.add();
    END IF;

    x_lov_sql := 'select lot_number, description
                  from mtl_lot_numbers
                  where organization_id = :1' ||
                  ' and inventory_item_id = :2 ' ||
                  ' and (disable_flag = 2 or disable_flag is null)';

END get_lot_number_lov;

FUNCTION get_lot_number_bind_values(p_org_id IN NUMBER,
                                    p_item_name IN VARCHAR2)
                                                RETURN VARCHAR2 IS


l_item_id NUMBER;

BEGIN

  l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

  IF l_item_id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_item_id);

END get_lot_number_bind_values;

-- anagarwa Thu Aug 12 15:49:51 PDT 2004
-- bug 3830258 incorrect LOVs in QWB
-- synced up the component lot number lov with forms
PROCEDURE get_comp_lot_number_lov (p_plan_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_comp_item IN VARCHAR2,
                              value IN VARCHAR2,
                              x_lov_sql OUT NOCOPY VARCHAR2) IS
-- l_lov_sql VARCHAR2(300);
BEGIN
    IF (p_comp_item is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.comp_item));
        fnd_msg_pub.add();
    END IF;

    x_lov_sql := 'select lot_number, description
                  from mtl_lot_numbers
                  where organization_id = :1 '||
                  ' and inventory_item_id = :2 ' ||
                  ' and (disable_flag = 2 or disable_flag is null)';

END get_comp_lot_number_lov;

FUNCTION get_comp_lot_bind_values(p_org_id IN NUMBER,
                                         p_item_name IN VARCHAR2)
                                                RETURN VARCHAR2 IS


l_item_id NUMBER;

BEGIN

  l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

  IF l_item_id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_item_id);

END get_comp_lot_bind_values;

 --
 -- Bug 5003511. R12 Performance fix. Obsolete the unused method
 -- so that it wont appear in fututre SQL Literal reports.
 -- srhariha. Wed Feb  1 04:16:10 PST 2006
 --

PROCEDURE get_lot_number_lov (x_transaction_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
/*
    x_lov_sql := 'SELECT lot_number, lot_expiration_date
                   FROM   mtl_transaction_lots_temp
                   WHERE  transaction_temp_id = ' || x_transaction_id || '
                   ORDER BY lot_number';
*/
    x_lov_sql := NULL;

END get_lot_number_lov;

-- anagarwa Thu Aug 12 15:49:51 PDT 2004
-- bug 3830258 incorrect LOVs in QWB
-- synced up the serial number lov with forms
PROCEDURE get_serial_number_lov (p_plan_id IN NUMBER,
                                 p_org_id IN NUMBER,
                                 p_item IN VARCHAR2,
                                 p_revision IN VARCHAR2,
                                 p_lot_number IN VARCHAR2,
                                 p_value IN VARCHAR2,
                                 x_lov_sql OUT NOCOPY VARCHAR2) IS

l_item_id NUMBER;
j NUMBER;
BEGIN

    IF (p_item is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.item));
        fnd_msg_pub.add();
    END IF;

    l_item_id := qa_flex_util.get_item_id(p_org_id, p_item);

    x_lov_sql := 'SELECT msn.serial_number, msn.current_status_name
                  FROM mtl_serial_numbers_all_v msn
                  WHERE msn.current_organization_id = :1 ' ||
                  ' AND msn.inventory_item_id = :2 ';

    -- anagarwa Thu Aug 12 15:49:51 PDT 2004
    -- discussed with Bryan. This sql is a little different from the one
    -- being used in forms. The reason is that if user selects a lot number
    -- we expect the item to be lot controlled too. So serial lov is restricted
    -- by lot number
    j := 3;
    IF (qa_plan_element_api.element_in_plan(p_plan_id, qa_ss_const.lot_number)
        AND p_lot_number is not NULL
        AND is_item_lot_controlled(l_item_id, p_org_id))  THEN
           x_lov_sql := x_lov_sql || ' AND msn.lot_number =  :' || to_char(j) || ' ';
        j := j+1;
    END IF;
    -- anagarwa Thu Aug 12 15:49:51 PDT 2004
    -- if revision is entered then restrict the serial lov with revision
    IF (qa_plan_element_api.element_in_plan(p_plan_id, qa_ss_const.revision)
       AND p_revision is not NULL
       AND is_item_revision_controlled(l_item_id, p_org_id))  THEN
            x_lov_sql := x_lov_sql || ' AND  msn.revision = :' || to_char(j) || ' ';
    END IF;

END get_serial_number_lov;


FUNCTION get_serial_no_bind_values (p_plan_id IN NUMBER,
                                    p_org_id IN NUMBER,
                                    p_item IN VARCHAR2,
                                    p_revision IN VARCHAR2,
                                    p_lot_number IN VARCHAR2)
                                        RETURN VARCHAR2 IS

l_item_id NUMBER;
l_ret_string VARCHAR2(1000);
BEGIN


    l_item_id := qa_flex_util.get_item_id(p_org_id, p_item);

    IF l_item_id IS NULL THEN
      RETURN NULL;
    END IF;

    l_ret_string := to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_item_id);


   IF (qa_plan_element_api.element_in_plan(p_plan_id, qa_ss_const.lot_number)
        AND p_lot_number is not NULL
        AND is_item_lot_controlled(l_item_id, p_org_id))  THEN
      l_ret_string := l_ret_string || g_bind_value_list_seperator ||  p_lot_number;
   END IF;

   IF (qa_plan_element_api.element_in_plan(p_plan_id, qa_ss_const.revision)
       AND p_revision is not NULL
       AND is_item_revision_controlled(l_item_id, p_org_id))  THEN
      l_ret_string := l_ret_string || g_bind_value_list_seperator || p_revision;
   END IF;

   RETURN l_ret_string;

END get_serial_no_bind_values;


-- anagarwa Thu Aug 12 15:49:51 PDT 2004
-- bug 3830258 incorrect LOVs in QWB
-- synced up the component serial number lov with forms
PROCEDURE get_comp_serial_number_lov (p_plan_id IN NUMBER,
                                 p_org_id IN NUMBER,
                                 p_comp_item IN VARCHAR2,
                                 p_comp_revision IN VARCHAR2,
                                 p_comp_lot_number IN VARCHAR2,
                                 p_value IN VARCHAR2,
                                 x_lov_sql OUT NOCOPY VARCHAR2) IS
l_item_id NUMBER;
j NUMBER;
BEGIN

    IF (p_comp_item is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.comp_item));
        fnd_msg_pub.add();
    END IF;

    l_item_id :=  qa_flex_util.get_item_id(p_org_id, p_comp_item);

    x_lov_sql := 'SELECT msn.serial_number, msn.current_status_name
                  FROM mtl_serial_numbers_all_v msn
                  WHERE msn.current_organization_id = :1 ' ||
                  ' AND msn.inventory_item_id = :2 ';
    j := 3;
    IF (qa_plan_element_api.element_in_plan(p_plan_id, qa_ss_const.comp_lot_number)
        AND p_comp_lot_number is not NULL
        AND is_item_lot_controlled(l_item_id, p_org_id))  THEN
           x_lov_sql := x_lov_sql || ' AND msn.lot_number =  :' || to_char(j) || ' ';
           j := j+1;
    END IF;
    IF (qa_plan_element_api.element_in_plan(p_plan_id, qa_ss_const.comp_revision)
       AND p_comp_revision is not NULL
        AND is_item_revision_controlled(l_item_id, p_org_id))  THEN
            x_lov_sql := x_lov_sql || ' AND msn.revision =  :' || to_char(j) || ' ';
    END IF;

END get_comp_serial_number_lov;

FUNCTION get_comp_serial_no_bind_values (p_plan_id IN NUMBER,
                                         p_org_id IN NUMBER,
                                         p_item IN VARCHAR2,
                                         p_revision IN VARCHAR2,
                                         p_lot_number IN VARCHAR2)
                                                     RETURN VARCHAR2 IS

l_item_id NUMBER;
l_ret_string VARCHAR2(1000);
BEGIN


    l_item_id := qa_flex_util.get_item_id(p_org_id, p_item);

    IF l_item_id IS NULL THEN
      RETURN NULL;
    END IF;

    l_ret_string := to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_item_id);


   IF (qa_plan_element_api.element_in_plan(p_plan_id, qa_ss_const.lot_number)
        AND p_lot_number is not NULL
        AND is_item_lot_controlled(l_item_id, p_org_id))  THEN
      l_ret_string := l_ret_string || g_bind_value_list_seperator ||  p_lot_number;
   END IF;

   IF (qa_plan_element_api.element_in_plan(p_plan_id, qa_ss_const.revision)
       AND p_revision is not NULL
       AND is_item_revision_controlled(l_item_id, p_org_id))  THEN
      l_ret_string := l_ret_string || g_bind_value_list_seperator || p_revision;
   END IF;

   RETURN l_ret_string;

END get_comp_serial_no_bind_values;



-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior

 --
 -- Bug 5003511. R12 Performance fix. Obsolete the unused method
 -- so that it wont appear in fututre SQL Literal reports.
 -- srhariha. Wed Feb  1 04:16:10 PST 2006
 --

PROCEDURE get_serial_number_lov (plan_id IN NUMBER, x_transaction_id IN NUMBER, x_lot_number
    IN VARCHAR2, value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
/*
    IF (x_lot_number is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.lot_number));
        fnd_msg_pub.add();
    END IF;

    x_lov_sql := 'SELECT msn.serial_number, msn.current_status
                   FROM  mtl_serial_numbers msn,
                         mtl_transaction_lots_temp mtlt
                   WHERE msn.line_mark_id = ' || x_transaction_id || '
                   AND  mtlt.transaction_temp_id = msn.line_mark_id
                   AND mtlt.serial_transaction_temp_id = msn.lot_line_mark_id
                   AND mtlt.lot_number = ' || '''' || x_lot_number || '''' || '
                   AND mtlt.lot_number IS NOT NULL
                   UNION ALL
                   SELECT msn.serial_number, msn.current_status
                   FROM mtl_serial_numbers msn
                   WHERE msn.line_mark_id = ' || x_transaction_id || '
                   ORDER BY serial_number';
*/
    x_lov_sql := NULL;
END get_serial_number_lov;

PROCEDURE get_serial_number_lov (x_transaction_id IN NUMBER, x_lot_number
    IN VARCHAR2, value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    get_serial_number_lov (NULL, x_transaction_id, x_lot_number, value, x_lov_sql);
END get_serial_number_lov;

PROCEDURE get_asset_instance_number_lov (plan_id IN NUMBER, x_org_id IN NUMBER, x_asset_group IN VARCHAR2,
 x_asset_number IN VARCHAR2,value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS
j NUMBER;
BEGIN

   x_lov_sql :=
     'SELECT cii.instance_number, cii.instance_description
      FROM
      csi_item_instances cii, mtl_system_items_b msib, mtl_parameters mp
      WHERE
      msib.organization_id = mp.organization_id and
      msib.organization_id = cii.last_vld_organization_id and
      msib.inventory_item_id = cii.inventory_item_id and
      msib.eam_item_type in (1,3) and
      msib.serial_number_control_code <> 1 and
      sysdate between nvl(cii.active_start_date, sysdate-1)
                and nvl(cii.active_end_date, sysdate+1) and
      mp.maint_organization_id = :1';


    j := 2;
    IF (x_asset_group is not NULL)  THEN
           x_lov_sql := x_lov_sql || ' AND cii.inventory_item_id =  :' || to_char(j) || ' ';
        j := j+1;
    END IF;

    IF (x_asset_number is not NULL )  THEN
            x_lov_sql := x_lov_sql || ' AND cii.serial_number = :' || to_char(j) || ' ';
    END IF;
            x_lov_sql := x_lov_sql || 'order by cii.instance_number';

END get_asset_instance_number_lov;

FUNCTION get_asset_inst_num_bind_values (p_org_id IN NUMBER,
            p_asset_group IN VARCHAR2, p_asset_number IN VARCHAR2)
                                               RETURN VARCHAR2 IS
l_asset_group_id NUMBER;
l_ret_string VARCHAR2(1000);

BEGIN
   l_asset_group_id := qa_plan_element_api.get_asset_group_id(p_org_id, p_asset_group);
   l_ret_string := to_char(p_org_id);
   --RETURN to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_asset_group_id) ||
    -- g_bind_value_list_seperator || p_asset_number;

    IF l_asset_group_id is  not NULL THEN
     l_ret_string := l_ret_string||g_bind_value_list_seperator||to_char(l_asset_group_id);
    END IF;

    IF p_asset_number is not NULL THEN
     l_ret_string := l_ret_string||g_bind_value_list_seperator||to_char(p_asset_number);
    END IF;

    RETURN l_ret_string;
END get_asset_inst_num_bind_values;
-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior
PROCEDURE get_asset_number_lov (plan_id IN NUMBER, x_org_id IN NUMBER, x_asset_group IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    IF ((plan_id is not null) AND (x_asset_group is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.asset_group));
        fnd_msg_pub.add();
    END IF;

    --dgupta: Start R12 EAM Integration. Bug 4345492
    x_lov_sql := 'SELECT
    	distinct msn.serial_number, msn.descriptive_text
    	FROM
    	mtl_serial_numbers msn, csi_item_instances cii, mtl_system_items_b msib, mtl_parameters mp
    	WHERE
    	msib.organization_id = mp.organization_id and
    	msib.organization_id = cii.last_vld_organization_id and
    	msib.inventory_item_id = cii.inventory_item_id and
    	msib.eam_item_type in (1,3) and
    	sysdate between nvl(cii.active_start_date(+), sysdate-1)
    	          and nvl(cii.active_end_date(+), sysdate+1) and
    	msib.organization_id = msn.current_organization_id and
    	cii.serial_number=msn.serial_number and
    	msib.inventory_item_id = msn.inventory_item_id and
    	mp.maint_organization_id = :1 and
    	msn.inventory_item_id = :2 and --removed nvl: serial number requires asset group as well
    	cii.instance_id= nvl(:3, cii.instance_id)
    	order by msn.serial_number';
    --dgupta: End R12 EAM Integration. Bug 4345492

END get_asset_number_lov;


--dgupta: Start R12 EAM Integration. Bug 4345492
FUNCTION get_asset_number_bind_values (p_org_id IN NUMBER,
            p_asset_group IN VARCHAR2, p_asset_instance_number IN VARCHAR2)
                                               RETURN VARCHAR2 IS
l_asset_group_id NUMBER;
l_asset_instance_id NUMBER;

BEGIN
   l_asset_group_id := qa_plan_element_api.get_asset_group_id(p_org_id, p_asset_group);
   l_asset_instance_id := qa_plan_element_api.get_asset_instance_id(p_asset_instance_number);

   RETURN to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_asset_group_id) ||
     g_bind_value_list_seperator || to_char(l_asset_instance_id);

END get_asset_number_bind_values;
--dgupta: End R12 EAM Integration. Bug 4345492


PROCEDURE get_asset_number_lov (x_org_id IN NUMBER, x_asset_group IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_asset_number_lov (NULL, x_org_id, x_asset_group, value, x_lov_sql);
END get_asset_number_lov;

--
-- Removed the DEFAULT clause to make the code GSCC compliant
-- List of changed arguments.
-- Old
--    production_line IN VARCHAR2 DEFAULT NULL
-- New
--    production_line IN VARCHAR2
--

-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior
PROCEDURE get_op_seq_number_lov (plan_id IN NUMBER, org_id IN NUMBER, value IN VARCHAR2,
    job_name IN VARCHAR2, production_line IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

    x_line_id NUMBER DEFAULT NULL;
    -- x_wip_entity_id NUMBER DEFAULT NULL;

BEGIN

    -- anagarwa Sun May  2 11:15:38 PDT 2004
    -- Bug 3574820 If production line is not present then we cannot save op seq
    -- number. This is not consistent with forms behaviour where for
    -- to/from op seq number only job is the required field. Production line is
    -- used only if present. Hence changing the following if condition to look
    -- for job only.
    IF (plan_id is not null) AND (job_name is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.job_name));
        fnd_msg_pub.add();
    END IF;

    IF (production_line IS NOT NULL) THEN
         x_line_id := qa_plan_element_api.get_production_line_id(org_id,
             production_line);
    END IF;

    -- x_wip_entity_id := qa_plan_element_api.get_job_id(org_id, job_name);

    IF (x_line_id IS NULL) THEN

        -- anagarwa  Thu Jan 16 19:02:01 PST 2003
        -- Bug 2751198
        -- to_char added as first col for lov is supposed to be a varchar
        x_lov_sql := 'SELECT to_char(operation_seq_num), operation_code
                       FROM  wip_operations_all_v
                       WHERE wip_entity_id = :1
                       AND   organization_id = :2
                       ORDER BY operation_seq_num';

    ELSE

        -- anagarwa Thu Jan 16 19:02:01 PST 2003
        -- Bug 2751198
        -- to_char added as first col for lov is supposed to be a varchar
        x_lov_sql := 'SELECT to_char(operation_seq_num), operation_code
                       FROM  wip_operations_all_v
                       WHERE wip_entity_id = :1
                       AND   organization_id = :2
                       AND   repetitive_schedule_id =
                       (
                        SELECT  repetitive_schedule_id
                        FROM    wip_first_open_schedule_v
                        WHERE   line_id = :3
                        AND     wip_entity_id = :4
                        AND organization_id = :5
                        )
                       ORDER BY operation_seq_num';

    END IF;

END get_op_seq_number_lov;

FUNCTION get_op_seq_no_bind_values (p_plan_id IN NUMBER,
                                    p_org_id IN NUMBER,
                                    p_job_name IN VARCHAR2,
                                    p_production_line IN VARCHAR2)
                                       RETURN VARCHAR2 IS

    l_line_id NUMBER;
    l_wip_entity_id NUMBER;

BEGIN

    l_line_id := NULL;

    IF (p_production_line IS NOT NULL OR p_production_line <> '') THEN
        l_line_id := qa_plan_element_api.get_production_line_id(p_org_id,
             p_production_line);
    END IF;

    l_wip_entity_id := qa_plan_element_api.get_job_id(p_org_id,p_job_name);

    IF (l_line_id IS NULL) THEN

       RETURN to_char(l_wip_entity_id) || g_bind_value_list_seperator || to_char(p_org_id);

    ELSE

      RETURN to_char(l_wip_entity_id) || g_bind_value_list_seperator || to_char(p_org_id) ||
              g_bind_value_list_seperator || to_char(l_line_id) ||
              g_bind_value_list_seperator || to_char(l_wip_entity_id) ||
              g_bind_value_list_seperator || to_char(p_org_id);

    END IF;

END get_op_seq_no_bind_values;

PROCEDURE get_op_seq_number_lov (org_id IN NUMBER, value IN VARCHAR2,
    job_name IN VARCHAR2, production_line IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_op_seq_number_lov (NULL, org_id, value, job_name, production_line, x_lov_sql);
END get_op_seq_number_lov;
          --
          -- MOAC Project. 4637896
          -- Now we are passing po header id directly.
          -- Corresponding change in dependent lov evaluation.
          -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
          --

-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior
PROCEDURE get_po_line_number_lov (plan_id IN NUMBER, po_header_id IN VARCHAR2, value IN
    VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

    -- po_number_id NUMBER;

BEGIN
    -- MOAC. Just changed the name becuase we are not using po_header_id
    -- in this method except for this dependency check.
    IF ((plan_id is not null) AND (po_header_id is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.po_number));
        fnd_msg_pub.add();
    END IF;

    -- po_number_id := qa_plan_element_api.get_po_number_id(po_number);

    -- Bug 3215866 ksoh Wed Oct 29 16:21:11 PST 2003
    -- fixed sql to make it return value instead of id.
    x_lov_sql := 'SELECT to_char(line_num), concatenated_segments
                   FROM   PO_LINES_VAL_TRX_V
                   WHERE  po_header_id = :1
                   ORDER BY line_num';

END get_po_line_number_lov;


FUNCTION get_po_line_no_bind_values (p_po_header_id IN VARCHAR2)
                                                   RETURN VARCHAR2 IS

BEGIN

--    l_po_number_id := qa_plan_element_api.get_po_number_id(p_po_number);
    RETURN p_po_header_id;

END get_po_line_no_bind_values;


PROCEDURE get_po_line_number_lov (po_number IN VARCHAR2, value IN
    VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_po_line_number_lov (NULL, po_number, value, x_lov_sql);
END get_po_line_number_lov;


-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior
--
-- bug 9652549 CLM changes
--

PROCEDURE get_po_shipments_lov (plan_id IN NUMBER, po_line_num IN VARCHAR2, po_header_id IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

    -- po_number_id NUMBER;

BEGIN
    IF ((plan_id is not null) AND ((po_header_id is null) OR (po_line_num is null))) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.po_number) ||
            ', ' || qa_plan_element_api.get_prompt(plan_id, qa_ss_const.po_line_num));
        fnd_msg_pub.add();
    END IF;

    -- po_number_id := qa_plan_element_api.get_po_number_id(po_number);

    -- Bug 3215866 ksoh Wed Oct 29 16:21:11 PST 2003
    -- added to_char to lov sql to make it compatible to
    -- char column when it is union with the kludge sql: select '1'.....

    -- Bug 5003511. SQL Repository Fix SQL ID: 15008892
/*
    x_lov_sql := 'SELECT to_char(shipment_num), shipment_type
                  FROM  po_shipments_all_v
                  WHERE po_line_id =
                       (SELECT po_line_id
                        FROM po_lines_val_v
                        WHERE line_num = :1
                        AND po_header_id = :2)';
*/
    --
    -- bug 9652549 CLM changes
    --
    x_lov_sql := 'SELECT  to_char(pll.shipment_num), pll.shipment_type
                  FROM PO_LINE_LOCATIONS_TRX_V pll
                  WHERE pll.ship_to_location_id is not null
                  AND pll.po_line_id =
                      (SELECT po_line_id
                       FROM PO_LINES_TRX_V
                       WHERE line_num = :1
                       AND po_header_id= :2 )';


END get_po_shipments_lov;

--
-- bug 9652549 CLM changes
--
FUNCTION get_po_shipments_bind_values (p_po_line_num IN VARCHAR2,
                                       p_po_header_id IN VARCHAR2)
                                                   RETURN VARCHAR2 IS


BEGIN

--   l_po_number_id := qa_plan_element_api.get_po_number_id(p_po_number);

   RETURN to_char(p_po_line_num) || g_bind_value_list_seperator || p_po_header_id;

END get_po_shipments_bind_values;

--
-- Bug 9652549 CLM changes
--
PROCEDURE get_po_shipments_lov (po_line_num IN VARCHAR2, po_number IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

    -- po_number_id NUMBER;

BEGIN
    get_po_shipments_lov (NULL, po_line_num, po_number, value, x_lov_sql);
END get_po_shipments_lov;


PROCEDURE get_receipt_num_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    -- Bug 7491455.FP For bug 6800960
    -- changing the validation query for receipt number to include RMA receipts
    -- pdube Fri Oct 17 00:14:28 PDT 2008
    -- x_lov_sql := 'SELECT receipt_num, vendor_name
    --                FROM   rcv_receipts_all_v
    --                ORDER BY receipt_num';
    x_lov_sql := 'SELECT receipt_num, vendor_name
                   FROM   ( SELECT DISTINCT RCVSH.RECEIPT_NUM,
                                            POV.VENDOR_NAME
                             FROM  RCV_SHIPMENT_HEADERS RCVSH,
                                   PO_VENDORS POV,
                                   RCV_TRANSACTIONS RT
                             WHERE RCVSH.RECEIPT_SOURCE_CODE in (''VENDOR'',''CUSTOMER'') AND
                                   RCVSH.VENDOR_ID = POV.VENDOR_ID(+) AND
                                   RT.SHIPMENT_HEADER_ID = RCVSH.SHIPMENT_HEADER_ID)
                   ORDER BY receipt_num';

END get_receipt_num_lov;


--
-- bug 7197055
-- Added new parameter, p_production_line to base item's lov on the prod line
-- if a valule is entered for it.
-- skolluku
--
PROCEDURE get_item_lov (org_id IN NUMBER, value IN VARCHAR2, p_production_line IN VARCHAR2 DEFAULT NULL,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT concatenated_segments, description
                   FROM  mtl_system_items_kfv
                   WHERE organization_id = :1';
    --
    -- bug 7197055
    -- Added the below condition only if a value for production_line is entered
    -- In such a case, the item becomes dependent on prod line.
    -- skolluku
    --
    IF (p_production_line IS NOT NULL OR p_production_line <> '') THEN
       x_lov_sql := x_lov_sql || ' AND inventory_item_id IN
                                  (SELECT primary_item_id
                                    FROM wip_rep_assy_val_v
                                    WHERE organization_id = :2
                                     AND line_id = :3
                                   UNION
                                   SELECT assembly_item_id
                                    FROM bom_operational_routings
                                    WHERE organization_id = :4
                                     AND line_id = :5)';
    END IF;
    x_lov_sql := x_lov_sql || ' ORDER BY concatenated_segments';
END get_item_lov;

--
-- bug 7197055
-- New method to return the bind values for item.
-- In addition to org id, prod line also needs to be returned in case
-- production line is entered.
-- skolluku
--
FUNCTION get_item_bind_values (p_org_id IN NUMBER,
				   p_production_line IN VARCHAR2)
				         RETURN VARCHAR2 IS

    l_line_id NUMBER;
BEGIN
    IF (p_production_line IS NOT NULL OR p_production_line <> '') THEN
        l_line_id := qa_plan_element_api.get_production_line_id(p_org_id,
             p_production_line);

        RETURN to_char(p_org_id) || g_bind_value_list_seperator || to_char(p_org_id) ||
               g_bind_value_list_seperator || to_char(l_line_id) || g_bind_value_list_seperator ||
               to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_line_id);
    ELSE
       RETURN to_char(p_org_id);
    END IF;
END get_item_bind_values;

    -- rkaza. 12/15/2003. bug 3280307. Added lov for comp item
PROCEDURE get_comp_item_lov (plan_id IN NUMBER, x_org_id IN NUMBER,
				p_item IN VARCHAR2, value IN VARCHAR2,
				x_lov_sql OUT NOCOPY VARCHAR2) IS

    -- l_item_id NUMBER DEFAULT NULL;
BEGIN

    IF (p_item is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.item));
        fnd_msg_pub.add();
    END IF;

    IF (p_item is not null) THEN

    	-- l_item_id := qa_flex_util.get_item_id(x_org_id, p_item);

    	x_lov_sql := 'SELECT concatenated_segments, description
                      FROM  mtl_system_items_kfv
                      WHERE organization_id = :1 ' ||
		      ' and inventory_item_id in (
      		      	 SELECT bic.component_item_id
      			 FROM bom_inventory_components bic,
           		 bom_bill_of_materials bom
      			 WHERE bic.bill_sequence_id = bom.bill_sequence_id AND
            		       bic.effectivity_date <= sysdate AND
            		       nvl(bic.disable_date, sysdate+1) > sysdate AND
            		       bom.assembly_item_id = :2 AND
            		       bom.organization_id = :3)
                      ORDER BY concatenated_segments';
    else

	-- show an empty list if parent item is not passed
    	x_lov_sql := 'SELECT concatenated_segments, description
                      FROM  mtl_system_items_kfv
                      WHERE 1 = 2
                      ORDER BY concatenated_segments';

    end if;

END get_comp_item_lov;

FUNCTION get_comp_item_bind_values (p_org_id IN NUMBER,
				   p_item IN VARCHAR2)
				         RETURN VARCHAR2 IS

    l_item_id NUMBER;
BEGIN


    IF (p_item is null) THEN
    	RETURN NULL;
    end if;

    l_item_id := qa_flex_util.get_item_id(p_org_id, p_item);
    RETURN  to_char(p_org_id) || g_bind_value_list_seperator ||
            to_char(l_item_id) || g_bind_value_list_seperator ||
            to_char(p_org_id);

END get_comp_item_bind_values;


PROCEDURE get_asset_group_lov (x_org_id IN NUMBER, value IN VARCHAR2,
                               x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

--dgupta: Start R12 EAM Integration. Bug 4345492
x_lov_sql := 'select distinct msikfv.concatenated_segments, msikfv.description
                    from mtl_system_items_b_kfv msikfv, mtl_parameters mp
                    where msikfv.organization_id = mp.organization_id
                    and msikfv.eam_item_type in (1,3)
                    and mp.maint_organization_id = :1
                    order by msikfv.concatenated_segments';
--dgupta: End R12 EAM Integration. Bug 43454922


END get_asset_group_lov;


-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior
--dgupta: Start R12 EAM Integration. Bug 4345492
PROCEDURE get_asset_activity_lov (plan_id IN NUMBER, x_org_id IN NUMBER, p_asset_group IN VARCHAR2,
				  p_asset_number IN VARCHAR2, p_asset_instance_number IN VARCHAR2, value IN VARCHAR2,
				  x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    -- rkaza. 12/02/2003. bug 3215372. Asset number can be null.
    -- Only Asset group is needed.
    -- Dependency on Asset Number is not a must. So removed it from the check.
    -- dgupta: Added that either asset group or asset instance number be present
    IF ((plan_id is not null) AND (p_asset_group is null)
      AND (p_asset_instance_number is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.asset_group));
        fnd_msg_pub.add();
    END IF;

    if (p_asset_number is null  and p_asset_instance_number is null) then
    -- show all activities asssociated to the asset group
    -- If no match found or if asset group passed in is null, lov is empty
/*
    	x_lov_sql := 'SELECT meaav.activity, meaav.activity_description
         FROM   mtl_eam_asset_activities_v meaav, mtl_system_items_b msib
         WHERE  msib.organization_id = :1
         and meaav. maintenance_object_id = :2 --pass asset group inventory_item_id
  		   and (meaav.end_date_active is null or meaav.end_date_active > sysdate)
  		   and (meaav.start_date_active is null or meaav.start_date_active < sysdate)
         and msib.inventory_item_id = meaav. maintenance_object_id
  		   and meaav.maintenance_object_type = 2 --non serialized item
         ORDER BY meaav.activity';
*/
       -- Bug 5003511. SQL Repository Fix SQL ID: 15008957
       x_lov_sql := 'SELECT
                    msib.concatenated_segments activity ,
                    msib.description activity_description
                FROM mtl_eam_asset_activities meaav,
                    mtl_system_items_b_kfv msib
                WHERE msib.organization_id = :1
                    AND meaav.maintenance_object_id = :2 --pass asset group inventory_item_id
                    AND (meaav.end_date_active is null
                         OR meaav.end_date_active > sysdate)
                    AND (meaav.start_date_active is null
                         OR meaav.start_date_active < sysdate)
                    AND msib.inventory_item_id = meaav.asset_activity_id
                    AND meaav.maintenance_object_type = 2 --non serialized item
                ORDER BY msib.concatenated_segments';
    else
    -- show all activities associated to asset group and asset number
    -- if exact match not found, lov is empty.
/*
    	x_lov_sql := 'SELECT meaav.activity, meaav.activity_description
         FROM   mtl_eam_asset_activities_v meaav, mtl_system_items_b msib
         WHERE  msib.organization_id = :1
  		   and meaav.maintenance_object_id = :2 --pass asset instance_id
  		   and meaav.maintenance_object_type = 3  --serialized item
  		   and (meaav.end_date_active is null or meaav.end_date_active > sysdate)
  		   and (meaav.start_date_active is null or meaav.start_date_active < sysdate)
         and msib.inventory_item_id = meaav.inventory_item_id
         ORDER BY meaav.activity';
*/
       -- Bug 5003511. SQL Repository Fix SQL ID: 15008986
       x_lov_sql := 'SELECT
                            msi.concatenated_segments activity ,
                            msi.description activity_description
                        FROM mtl_eam_asset_activities meaa,
                            mtl_system_items_b_kfv msi
                        WHERE msi.organization_id = :1
                            AND meaa.maintenance_object_id = :2 --pass asset instance_id
                            AND meaa.maintenance_object_type = 3 --serialized item
                            AND (meaa.end_date_active is null
                                 OR meaa.end_date_active > sysdate)
                            AND (meaa.start_date_active is null
                                 OR meaa.start_date_active < sysdate)
                            AND msi.inventory_item_id = meaa.asset_activity_id
                        ORDER BY msi.concatenated_segments';

    end if;

END get_asset_activity_lov;


FUNCTION get_asset_activity_bind_values (p_org_id IN NUMBER,
                                         p_asset_group IN VARCHAR2,
				         p_asset_number IN VARCHAR2, p_asset_instance_number IN VARCHAR2)
				           RETURN VARCHAR2 IS

    l_asset_group_id NUMBER DEFAULT NULL;
    l_asset_instance_id NUMBER DEFAULT NULL;

BEGIN
  if (p_asset_number is null  and p_asset_instance_number is null) then
    l_asset_group_id := qa_plan_element_api.get_asset_group_id(p_org_id, p_asset_group);
    RETURN to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_asset_group_id);
  else
    l_asset_instance_id := qa_plan_element_api.get_asset_instance_id(p_asset_instance_number);
    if (l_asset_instance_id is null) then
      l_asset_instance_id := qa_plan_element_api.get_asset_instance_id(l_asset_group_id, p_asset_number);
    end if;
    RETURN to_char(p_org_id) || g_bind_value_list_seperator || to_char(l_asset_instance_id);
  end if;
END get_asset_activity_bind_values;


PROCEDURE get_asset_activity_lov (x_org_id IN NUMBER, p_asset_group IN VARCHAR2,
				  p_asset_number IN VARCHAR2, p_asset_instance_number IN VARCHAR2, value IN VARCHAR2,
				  x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_asset_activity_lov (NULL, x_org_id, p_asset_group, p_asset_number,
      p_asset_instance_number, value, x_lov_sql);
END get_asset_activity_lov;

-- added the following to include new hardcoded element followup activity
-- saugupta
PROCEDURE get_followup_activity_lov (plan_id IN NUMBER, x_org_id IN NUMBER, p_asset_group IN VARCHAR2,
				  p_asset_number IN VARCHAR2, p_asset_instance_number IN VARCHAR2, value IN VARCHAR2,
				  x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
  get_asset_activity_lov (plan_id, x_org_id, p_asset_group, p_asset_number,
    p_asset_instance_number, value, x_lov_sql); --no use duplicating code

END get_followup_activity_lov;

FUNCTION get_followup_act_bind_values (p_org_id IN NUMBER,
                                       p_asset_group IN VARCHAR2,
			               p_asset_number IN VARCHAR2, p_asset_instance_number IN VARCHAR2)
				           RETURN VARCHAR2 IS

BEGIN
    RETURN get_asset_activity_bind_values(p_org_id, p_asset_group,
      p_asset_number, p_asset_instance_number); -- same as asset activity lov, dont duplicate
END get_followup_act_bind_values;

PROCEDURE get_followup_activity_lov (x_org_id IN NUMBER, p_asset_group IN VARCHAR2,
				  p_asset_number IN VARCHAR2, p_asset_instance_number IN VARCHAR2, value IN VARCHAR2,
				  x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_followup_activity_lov (NULL, x_org_id, p_asset_group,
				  p_asset_number, p_asset_instance_number, value,
				  x_lov_sql);
END get_followup_activity_lov;

--dgupta: End R12 EAM Integration. Bug 4345492

PROCEDURE get_xfr_lpn_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN

   x_lov_sql := 'SELECT license_plate_number, attribute1
                 FROM   wms_license_plate_numbers
                 ORDER BY license_plate_number';

END get_xfr_lpn_lov;




-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior

-- anagarwa Thu May 13 14:56:49 PDT 2004
-- Bug 3625998 Locator should be restricted by subinventory
-- Earlier, we were taking in item and not using it. I have changed the
-- variable name to x_subinventory and used it in the lov sql
PROCEDURE get_locator_lov (plan_id IN NUMBER, org_id IN NUMBER,
                           x_subinventory IN VARCHAR2, value IN VARCHAR2,
                           x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    IF ((plan_id is not null) AND (x_subinventory is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.subinventory));
        fnd_msg_pub.add();
    END IF;

    -- anagarwa  Thu May 13 14:56:49 PDT 2004
    -- Bug 3625998: Added subinventory and disable_date to restrict the lov
    x_lov_sql := 'SELECT concatenated_segments, description
                  FROM   mtl_item_locations_kfv
                  WHERE  organization_id = :1
                  AND    subinventory_code = :2
                  AND    nvl(disable_date, sysdate+1) > sysdate
                  ORDER BY concatenated_segments';

END get_locator_lov;


FUNCTION get_locator_bind_values (p_org_id IN NUMBER,
                                   p_subinventory IN VARCHAR2)
                                          RETURN VARCHAR2 IS

BEGIN

    RETURN to_char(p_org_id) || g_bind_value_list_seperator || p_subinventory;

END get_locator_bind_values;

PROCEDURE get_locator_lov (org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    get_locator_lov (NULL, org_id, x_item_name, value, x_lov_sql);
END get_locator_lov;


PROCEDURE get_party_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT party_name, party_number
                  FROM   hz_parties
                  WHERE  status = ''A''
                  AND party_type IN (''ORGANIZATION'',''PERSON'')
                  ORDER BY party_name';

END get_party_lov;

--
-- Implemented the following six get_lov procedures for
-- Service_Item, Counter, Maintenance_Requirement, Service_Request, Rework_Job
-- For ASO project
-- rkunchal Thu Aug  1 12:04:56 PDT 2002
--

PROCEDURE get_item_instance_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT cii.instance_number, cii.serial_number
	          FROM   qa_csi_item_instances cii, mtl_system_items_kfv msik
		  WHERE  cii.inventory_item_id = msik.inventory_item_id
		  AND    cii.last_vld_organization_id = msik.organization_id
		  ORDER BY 1';

END get_item_instance_lov;

--
-- Bug 9032151
-- Overloading above procedure and with the new one which takes
-- care of the dependency of item instance on item.
-- skolluku
--
PROCEDURE get_item_instance_lov (p_plan_id IN NUMBER, p_item IN VARCHAR2,
                                 value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    IF (p_item is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.item));
        fnd_msg_pub.add();
    END IF;

    x_lov_sql := 'SELECT cii.instance_number, cii.serial_number
                   FROM   qa_csi_item_instances cii, mtl_system_items_kfv msik
                   WHERE  cii.inventory_item_id = msik.inventory_item_id
                    AND   cii.last_vld_organization_id = msik.organization_id
                    AND   cii.inventory_item_id = :1
                    AND   trunc(sysdate) BETWEEN trunc(nvl(cii.active_start_date, sysdate))
                                            AND trunc(nvl(cii.active_end_date, sysdate))
                  ORDER BY cii.instance_number';

END get_item_instance_lov;

--
-- Bug 8979498
-- New function to fetch bind values for item instance lov
-- skolluku
--
FUNCTION get_item_instance_bind_values(p_org_id IN NUMBER,
                                       p_item_name IN VARCHAR2)
                                                RETURN VARCHAR2 IS


l_item_id NUMBER;

BEGIN

  l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

  IF l_item_id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN to_char(l_item_id);

END get_item_instance_bind_values;

--
-- Bug 9359442
-- New procedure which returns lov for item instance serial based on item.
-- skolluku
--
PROCEDURE get_item_instance_serial_lov (p_plan_id IN NUMBER, p_item IN VARCHAR2,
                                 value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN
    IF (p_item is null) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
            qa_plan_element_api.get_prompt(p_plan_id, qa_ss_const.item));
        fnd_msg_pub.add();
    END IF;

    x_lov_sql := 'SELECT cii.serial_number, msik.concatenated_segments
                   FROM qa_csi_item_instances cii, mtl_system_items_kfv msik
                   WHERE cii.inventory_item_id = msik.inventory_item_id
                    AND cii.inv_master_organization_id = msik.organization_id
                    AND msik.inventory_item_id = :1
                    AND trunc(sysdate) BETWEEN trunc(nvl(cii.active_start_date, sysdate))
                    AND trunc(nvl(cii.active_end_date, sysdate))
                    AND cii.serial_number IS NOT NULL
                  ORDER BY cii.serial_number';

END get_item_instance_serial_lov;

--
-- Bug 9359442
-- New function to fetch bind values for item instance serial lov
-- skolluku
--
FUNCTION get_item_inst_ser_bind_values(p_org_id IN NUMBER,
                                              p_item_name IN VARCHAR2)
                                                RETURN VARCHAR2 IS


l_item_id NUMBER;

BEGIN

  l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

  IF l_item_id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN to_char(l_item_id);

END get_item_inst_ser_bind_values;

PROCEDURE get_counter_name_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

-- Bug 5003511. SQL Repository Fix SQL ID: 15009044
    x_lov_sql := 'SELECT name, description
                   FROM csi_counters_vl
                   WHERE trunc(sysdate) BETWEEN
                          nvl(start_date_active, trunc(sysdate))
                     AND  nvl(end_date_active, trunc(sysdate))
                   ORDER BY 1';
/*
    x_lov_sql := 'SELECT cc.name, cc.description
		  FROM   cs_counters cc, cs_counter_groups ccg
		  WHERE  cc.counter_group_id = ccg.counter_group_id
		  AND    ccg.template_flag = ''N''
		  ORDER BY 1';
*/

END get_counter_name_lov;


PROCEDURE get_maintenance_req_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT amr.title, amr.version_number
                  FROM qa_ahl_mr amr
		  WHERE trunc(sysdate) BETWEEN
		  trunc(nvl(amr.effective_from, sysdate)) AND trunc(nvl(amr.effective_to, sysdate))
		  ORDER BY 1';

END get_maintenance_req_lov;


PROCEDURE get_service_request_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT incident_number, summary
                  FROM   cs_incidents
                  ORDER BY 1';

END get_service_request_lov;


PROCEDURE get_rework_job_lov (org_id IN NUMBER, value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql:= 'SELECT wip_entity_name, description
                 FROM   wip_discrete_jobs_all_v
                 WHERE  organization_id = :1
                 ORDER BY wip_entity_name';

END get_rework_job_lov;

PROCEDURE get_disposition_source_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
		  v.description
		  FROM qa_char_value_lookups v
		  WHERE v.char_id = :1
		  ORDER BY 1';

END get_disposition_source_lov;

PROCEDURE get_disposition_action_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
		  v.description
		  FROM qa_char_value_lookups v
		  WHERE v.char_id = :1
		  ORDER BY 1';

END get_disposition_action_lov;

PROCEDURE get_disposition_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
		  v.description
		  FROM qa_char_value_lookups v
		  WHERE v.char_id = :1
                  ORDER BY 1';

END get_disposition_lov;

PROCEDURE get_disposition_status_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
		  v.description
	          FROM qa_char_value_lookups v
		  WHERE v.char_id = :1
		  ORDER BY 1';

END get_disposition_status_lov;

/* R12 DR Integration. Bug 4345489 Strat */
PROCEDURE get_repair_order_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT cr.repair_number,
                  cr.problem_description
                  FROM csd_repairs cr
		  WHERE status not in (''C'', ''H'')
                  ORDER BY 1';

END get_repair_order_lov;

PROCEDURE get_jtf_task_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT task_number, task_name
                  FROM JTF_TASKS_VL
 		      ORDER BY 1';

END get_jtf_task_lov;
/* R12 DR Integration. Bug 4345489 End */

-- R12 OPM Deviations. Bug 4345503 Start

PROCEDURE get_process_batch_num_lov
(org_id                      IN            NUMBER,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2) IS
BEGIN
  x_lov_sql := 'SELECT BATCH_NO, BATCH_NO BATCH_DESC FROM GME_BATCH_HEADER '||
               'WHERE ORGANIZATION_ID is null or ORGANIZATION_ID = :1'||
               'ORDER BY BATCH_NO';
END get_process_batch_num_lov;

PROCEDURE get_process_batchstep_num_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_batch_num           IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2) IS

 l_process_batch_id number;
BEGIN
  l_process_batch_id := qa_plan_element_api.get_process_batch_id (process_batch_num, org_id);

  IF (l_process_batch_id is null) THEN
    fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
    fnd_message.set_token('DEPELEM',
                           qa_plan_element_api.get_prompt(plan_id, qa_ss_const.process_batch_num)
                         );
    fnd_msg_pub.add();
  END IF;

  x_lov_sql := 'SELECT to_char(STEPS.BATCHSTEP_NO) ,OPS.OPRN_DESC BATCHSTEP_DESC '||
               'FROM GME_BATCH_STEPS STEPS, GMD_OPERATIONS OPS '||
               'WHERE STEPS.BATCH_ID = :1 ' ||
               'AND STEPS.OPRN_ID = OPS.OPRN_ID '||
               'ORDER BY BATCHSTEP_NO';

END get_process_batchstep_num_lov;

FUNCTION GET_PROCESS_STEP_BIND_VALUE
(org_id IN NUMBER,
 process_batch_num IN VARCHAR2)
RETURN VARCHAR2 IS

  l_process_batch_id number;
BEGIN
  l_process_batch_id := qa_plan_element_api.get_process_batch_id (process_batch_num, org_id);

  IF (l_process_batch_id IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(l_process_batch_id);
END GET_PROCESS_STEP_BIND_VALUE;

PROCEDURE get_process_operation_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_batch_num           IN            VARCHAR2,
 process_batchstep_num       IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2) IS

 l_process_batch_id number;
 l_process_batchstep_id number;
BEGIN
  L_PROCESS_BATCH_ID := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCH_ID(PROCESS_BATCH_NUM,ORG_ID);

  IF (l_process_batch_id is null) THEN
    fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
    fnd_message.set_token('DEPELEM',
                           qa_plan_element_api.get_prompt(plan_id, qa_ss_const.process_batch_num)
                         );
    fnd_msg_pub.add();
  END IF;

  L_PROCESS_BATCHSTEP_ID := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCHSTEP_ID
                           (process_batchstep_num,L_PROCESS_BATCH_ID);

  IF (l_process_batchstep_id is null) THEN
    fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
    fnd_message.set_token('DEPELEM',
                           qa_plan_element_api.get_prompt(plan_id, qa_ss_const.process_batchstep_num)
                         );
    fnd_msg_pub.add();
  END IF;

  x_lov_sql := 'SELECT OPERATION PROCESS_OPERATION, OPRN_DESC '||
               'FROM GMO_BATCH_STEPS_V '||
               'WHERE BATCHSTEP_ID = :1 '||
               ' AND BATCH_ID = :2 '||
               ' ORDER BY PROCESS_OPERATION';
END get_process_operation_lov;

FUNCTION GET_PROCESS_OPRN_BIND_VALUE
(org_id IN NUMBER,
 process_batch_num IN VARCHAR2,
 process_batchstep_num IN VARCHAR2)
RETURN VARCHAR2 IS

  l_process_batch_id number;
  l_process_batchstep_id number;
BEGIN
  l_process_batch_id := qa_plan_element_api.get_process_batch_id (process_batch_num, org_id);
  IF (l_process_batch_id IS NULL) THEN
    RETURN NULL;
  END IF;

  l_process_batchstep_id := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCHSTEP_ID
                           (process_batchstep_num,L_PROCESS_BATCH_ID);
  IF (l_process_batchstep_id IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(l_process_batchstep_id) ||
                 g_bind_value_list_seperator ||
                 to_char(l_process_batch_id);

END GET_PROCESS_OPRN_BIND_VALUE;

PROCEDURE get_process_activity_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_batch_num           IN            VARCHAR2,
 process_batchstep_num       IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2) IS

 l_process_batch_id number;
 l_process_batchstep_id number;
BEGIN
  L_PROCESS_BATCH_ID := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCH_ID(PROCESS_BATCH_NUM,ORG_ID);

  IF (l_process_batch_id is null) THEN
    fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
    fnd_message.set_token('DEPELEM',
                           qa_plan_element_api.get_prompt(plan_id, qa_ss_const.process_batch_num)
                         );
    fnd_msg_pub.add();
  END IF;

  L_PROCESS_BATCHSTEP_ID := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCHSTEP_ID
                           (PROCESS_BATCHSTEP_NUM,L_PROCESS_BATCH_ID);

  IF (l_process_batchstep_id is null) THEN
    fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
    fnd_message.set_token('DEPELEM',
                           qa_plan_element_api.get_prompt(plan_id, qa_ss_const.process_batchstep_num)
                         );
    fnd_msg_pub.add();
  END IF;

  x_lov_sql := 'SELECT STEPS.ACTIVITY, ACTIVITIES.ACTIVITY_DESC '||
               'FROM GME_BATCH_STEP_ACTIVITIES STEPS, GMD_ACTIVITIES ACTIVITIES	'||
               'WHERE STEPS.BATCHSTEP_ID = :1 '||
               ' AND STEPS.BATCH_ID = :2 '||
               ' AND STEPS.ACTIVITY = ACTIVITIES.ACTIVITY '||
               'ORDER BY ACTIVITY';
END get_process_activity_lov;

FUNCTION GET_PROCESS_ACT_BIND_VALUE
(org_id IN NUMBER,
 process_batch_num IN VARCHAR2,
 process_batchstep_num IN VARCHAR2)
RETURN VARCHAR2 IS

  l_process_batch_id number;
  l_process_batchstep_id number;
BEGIN
  l_process_batch_id := qa_plan_element_api.get_process_batch_id (process_batch_num, org_id);
  IF (l_process_batch_id IS NULL) THEN
    RETURN NULL;
  END IF;

  l_process_batchstep_id := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCHSTEP_ID
                           (process_batchstep_num,L_PROCESS_BATCH_ID);
  IF (l_process_batchstep_id IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(l_process_batchstep_id) ||
                 g_bind_value_list_seperator ||
                 to_char(l_process_batch_id);

END GET_PROCESS_ACT_BIND_VALUE;

PROCEDURE get_process_resource_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_batch_num           IN            VARCHAR2,
 process_batchstep_num       IN            VARCHAR2,
 process_activity            IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2) IS

 l_process_batch_id number;
 l_process_batchstep_id number;
 l_process_activity_id number;
BEGIN
  L_PROCESS_BATCH_ID := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCH_ID(PROCESS_BATCH_NUM,ORG_ID);

  IF (l_process_batch_id is null) THEN
    fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
    fnd_message.set_token('DEPELEM',
                           qa_plan_element_api.get_prompt(plan_id, qa_ss_const.process_batch_num)
                         );
    fnd_msg_pub.add();
  END IF;

  L_PROCESS_BATCHSTEP_ID := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCHSTEP_ID
                           (PROCESS_BATCHSTEP_NUM,L_PROCESS_BATCH_ID);

  IF (l_process_batchstep_id is null) THEN
    fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
    fnd_message.set_token('DEPELEM',
                           qa_plan_element_api.get_prompt(plan_id, qa_ss_const.process_batchstep_num)
                         );
    fnd_msg_pub.add();
  END IF;

  L_PROCESS_ACTIVITY_ID := QA_PLAN_ELEMENT_API.GET_PROCESS_ACTIVITY_ID
                                     (PROCESS_ACTIVITY,L_PROCESS_BATCH_ID,L_PROCESS_BATCHSTEP_ID);

  IF (l_process_activity_id is null) THEN
    fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
    fnd_message.set_token('DEPELEM',
                           qa_plan_element_api.get_prompt(plan_id, qa_ss_const.process_activity)
                         );
    fnd_msg_pub.add();
  END IF;

  x_lov_sql := 'SELECT GBSR.RESOURCES, CRMV.RESOURCE_DESC '||
               'FROM GME_BATCH_STEP_RESOURCES GBSR, CR_RSRC_MST_VL CRMV '||
               'WHERE GBSR.BATCHSTEP_ACTIVITY_ID = :1 '||
               'AND GBSR.BATCHSTEP_ID = :2 '||
               'AND GBSR.BATCH_ID = :3 '||
               'AND GBSR.RESOURCES = CRMV.RESOURCES '||
               'ORDER BY RESOURCES';

END get_process_resource_lov;

FUNCTION GET_PROCESS_RSR_BIND_VALUE
(org_id IN NUMBER,
 process_batch_num IN VARCHAR2,
 process_batchstep_num IN VARCHAR2,
 process_activity IN VARCHAR2)
RETURN VARCHAR2 IS

  l_process_batch_id number;
  l_process_batchstep_id number;
  l_process_activity_id number;
BEGIN
  l_process_batch_id := qa_plan_element_api.get_process_batch_id (process_batch_num, org_id);
  IF (l_process_batch_id IS NULL) THEN
    RETURN NULL;
  END IF;

  l_process_batchstep_id := QA_PLAN_ELEMENT_API.GET_PROCESS_BATCHSTEP_ID
                           (process_batchstep_num,L_PROCESS_BATCH_ID);
  IF (l_process_batchstep_id IS NULL) THEN
    RETURN NULL;
  END IF;

  L_PROCESS_ACTIVITY_ID := QA_PLAN_ELEMENT_API.GET_PROCESS_ACTIVITY_ID
                                     (PROCESS_ACTIVITY,L_PROCESS_BATCH_ID,L_PROCESS_BATCHSTEP_ID);

  IF (l_process_activity_id IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(l_process_activity_id) ||
                 g_bind_value_list_seperator ||
                 to_char(l_process_batchstep_id) ||
                 g_bind_value_list_seperator ||
                 to_char(l_process_batch_id);

END GET_PROCESS_RSR_BIND_VALUE;

PROCEDURE get_process_parameter_lov
(org_id                      IN            NUMBER,
 plan_id                     IN            NUMBER,
 process_resource            IN            VARCHAR2,
 value                       IN            VARCHAR2,
 x_lov_sql                   OUT NOCOPY    VARCHAR2) IS
BEGIN
  x_lov_sql := 'SELECT DISTINCT GP.PARAMETER_NAME, GP.PARAMETER_DESCRIPTION '||
               'FROM GMP_PROCESS_PARAMETERS GP, GME_PROCESS_PARAMETERS GE '||
               'WHERE GP.PARAMETER_ID = GE.PARAMETER_ID '||
               'AND GE.RESOURCES =  :1'||
               ' ORDER BY PARAMETER_NAME';

END get_process_parameter_lov;

FUNCTION GET_PROCESS_PARAM_BIND_VALUE
(org_id IN NUMBER,
 process_resource IN VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
  IF (process_resource IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(process_resource);
END GET_PROCESS_PARAM_BIND_VALUE;
-- R12 OPM Deviations. Bug 4345503 End

--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--
-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior
PROCEDURE get_maintenance_op_seq_lov(plan_id IN NUMBER, org_id IN NUMBER,
                                     value IN VARCHAR2,
                                     maintenance_work_order IN VARCHAR2,
                                     x_lov_sql OUT NOCOPY VARCHAR2) IS

    x_wip_entity_id NUMBER DEFAULT NULL;

BEGIN
    IF ((plan_id is not null) AND (maintenance_work_order is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.work_order));
        fnd_msg_pub.add();
    END IF;
   -- rkaza. 10/22/2003. 3209804.
   -- operation_seq_num should be made a varchar2 to be compatible with
   -- code and description in a dynamic lov.
   -- Also lov should not error out if wip_entity_id is null.

    x_wip_entity_id := qa_plan_element_api.get_job_id(org_id, maintenance_work_order);

    if x_wip_entity_id is not null then
    	x_lov_sql := 'SELECT to_char(operation_seq_num), operation_code
                  FROM   wip_operations_all_v
                  WHERE  wip_entity_id = :1
                  AND    organization_id = :2
                  ORDER BY operation_seq_num';
    else
	-- nothing should be selected.
    	x_lov_sql := 'SELECT to_char(operation_seq_num), operation_code
                  FROM   wip_operations_all_v
                  WHERE  1 = 2' || '
                  ORDER BY operation_seq_num';
    end if;

END get_maintenance_op_seq_lov;


FUNCTION get_maint_op_seq_bind_values (p_org_id IN NUMBER,
                                       p_maintenance_work_order IN VARCHAR2)
                                          RETURN VARCHAR2 IS

    l_wip_entity_id NUMBER;

BEGIN

    l_wip_entity_id := qa_plan_element_api.get_job_id(p_org_id, p_maintenance_work_order);

    if l_wip_entity_id is not null then
    	RETURN to_char(l_wip_entity_id) || g_bind_value_list_seperator || to_char(p_org_id);
    end if;

    RETURN NULL;

END get_maint_op_seq_bind_values;

PROCEDURE get_maintenance_op_seq_lov(org_id IN NUMBER,
                                     value IN VARCHAR2,
                                     maintenance_work_order IN VARCHAR2,
                                     x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_maintenance_op_seq_lov (NULL, org_id,
        value, maintenance_work_order, x_lov_sql);
END get_maintenance_op_seq_lov;

--
-- End of inclusions for ASO project
-- rkunchal Thu Aug  1 12:04:56 PDT 2002
--


-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

PROCEDURE get_bill_reference_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

    BEGIN

        x_lov_sql := 'SELECT concatenated_segments, description
                      FROM  mtl_system_items_kfv
                      WHERE organization_id = :1
                      ORDER BY concatenated_segments';

END get_bill_reference_lov;

PROCEDURE get_routing_reference_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

    BEGIN

        x_lov_sql := 'SELECT concatenated_segments, description
                      FROM  mtl_system_items_kfv
                      WHERE organization_id = :1
                      ORDER BY concatenated_segments';

END get_routing_reference_lov;

PROCEDURE get_to_subinventory_lov (org_id IN NUMBER, value IN VARCHAR2,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

    BEGIN

            x_lov_sql := 'SELECT secondary_inventory_name, description
                          FROM   mtl_secondary_inventories
                          WHERE  organization_id = :1
                          AND    nvl(disable_date, sysdate+1) > sysdate
                          ORDER BY secondary_inventory_name';

END get_to_subinventory_lov;

-- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
-- check if any dependent element value is null
-- if so, put error message with element prompts
-- requires plan_id to be passed in to retrieve element prompts.
-- old signature calls new signature with plan_id = NULL to
-- maintain old behavior

-- anagarwa Thu May 13 14:56:49 PDT 2004
-- Bug 3625998 Locator should be restricted by subinventory
-- Earlier, we were taking in item and not using it. I have changed the
-- variable name to x_subinventory and used it in the lov sql
PROCEDURE get_to_locator_lov (plan_id IN NUMBER, org_id IN NUMBER,
                              x_subinventory IN VARCHAR2, value IN VARCHAR2,
                              x_lov_sql OUT NOCOPY VARCHAR2) IS

    BEGIN

    -- anagarwa Thu May 13 14:56:49 PDT 2004
    -- Bug 3625998 Locator should be restricted by subinventory
    -- We are doing exactly the same thing as in get_locator_lov.
    -- I do not see the reason to maintain 2 occurrences of same code.
    -- If we need to change the this lov for some reason, then we can simply
    -- comment out my changes and write new logic here.
    get_locator_lov(plan_id, org_id, x_subinventory, value, x_lov_sql);
/*
    IF ((plan_id is not null) AND (x_item_name is null)) THEN
        fnd_message.set_name('QA', 'QA_SSQR_DEPENDENT_LOV');
        fnd_message.set_token('DEPELEM',
	    qa_plan_element_api.get_prompt(plan_id, qa_ss_const.item));
        fnd_msg_pub.add();
    END IF;

        x_lov_sql := 'SELECT concatenated_segments, description
                      FROM   mtl_item_locations_kfv
                      WHERE  organization_id = ' || org_id || '
                      ORDER BY concatenated_segments';
*/

END get_to_locator_lov;

PROCEDURE get_to_locator_lov (org_id IN NUMBER, x_item_name IN VARCHAR2,
    value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN
    get_to_locator_lov (NULL, org_id, x_item_name, value, x_lov_sql);
END get_to_locator_lov;

PROCEDURE get_lot_status_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT status_code,description
                  FROM mtl_material_statuses
                  ORDER BY status_code';

END get_lot_status_lov;

-- Bug 7588754.pdube Wed Apr 15 07:37:25 PDT 2009
-- Added parameters item_name and srl_num
-- PROCEDURE get_serial_status_lov (value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2) IS
PROCEDURE get_serial_status_lov (value IN VARCHAR2,
				 item_name IN VARCHAR2,
                                 serial_num IN VARCHAR2,
                                 x_lov_sql OUT NOCOPY VARCHAR2) IS
BEGIN

    -- Bug 7588754
    -- Changed the Lov SQL based on srl number and item
    x_lov_sql := 'SELECT mms.status_code, mms.description
                  FROM mtl_serial_numbers msn, mtl_material_statuses mms
                  WHERE msn.inventory_item_id = :1
                  AND msn.serial_number like :2
                  AND msn.status_id = mms.status_id
                  AND mms.enabled_flag = 1';

END get_serial_status_lov;

-- Bug 7588754. New function to return the proper bind values
-- pdube Wed Apr 15 07:37:25 PDT 2009
FUNCTION get_serial_status_bind_values (p_org_id IN NUMBER,
                                       p_item_name IN VARCHAR2,
                                       p_serial_num IN VARCHAR2)
                                       RETURN VARCHAR2 IS

l_item_id NUMBER;

BEGIN

  l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

  IF (l_item_id IS NULL) THEN
    RETURN NULL;
  END IF;

  RETURN to_char(l_item_id) || g_bind_value_list_seperator || p_serial_num ;

END get_serial_status_bind_values;

PROCEDURE get_nonconformance_source_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_nonconformance_source_lov;

PROCEDURE get_nonconform_severity_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_nonconform_severity_lov;

PROCEDURE get_nonconform_priority_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_nonconform_priority_lov;

PROCEDURE get_nonconformance_type_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_nonconformance_type_lov;


PROCEDURE get_nonconformance_status_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_nonconformance_status_lov;

--anagarwa Wed Jan 15 13:51:41 PST 2003
-- Bug 2751198
-- support needed for contract number, contract line number and
-- deliverable number

PROCEDURE get_contract_lov (value IN VARCHAR2,
                            x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT k_number, short_description
                   FROM oke_k_headers_lov_v order by k_number';

END get_contract_lov;


PROCEDURE get_contract_line_lov (value IN VARCHAR2,
                                 x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT line_number, line_description
                   FROM oke_k_lines_full_v order by line_number';

END get_contract_line_lov;

PROCEDURE get_deliverable_lov(value IN VARCHAR2,
                              x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    x_lov_sql := 'SELECT deliverable_num, description
                   FROM oke_k_deliverables_vl order by deliverable_num' ;

END get_deliverable_lov;


-- End of inclusions for NCM Hardcode Elements.

--anagarwa Fri Nov 15 13:03:35 PST 2002
--Following added for new CAR lov's

PROCEDURE get_request_source_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_request_source_lov;

PROCEDURE get_request_priority_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_request_priority_lov;

PROCEDURE get_request_severity_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_request_severity_lov;


PROCEDURE get_request_status_lov(value IN VARCHAR2, x_lov_sql OUT NOCOPY VARCHAR2)
IS

BEGIN

    x_lov_sql := 'SELECT v.short_code code,
                  v.description
                  FROM qa_char_value_lookups v
                  WHERE v.char_id = :1
                  ORDER BY 1';

END get_request_status_lov;

-- End of inclusions for CAR Hardcode Elements.


--
-- Removed the DEFAULT clause to make the code GSCC compliant
-- List of changed arguments.
-- Old
--    user_id IN NUMBER DEFAULT NULL
-- New
--    user_id IN NUMBER
--


PROCEDURE get_plan_element_lov(plan_id IN NUMBER, char_id IN NUMBER,
    org_id IN NUMBER, user_id IN NUMBER,
    x_lov_sql OUT NOCOPY VARCHAR2) IS

BEGIN

    -- The function sql_string_exists simple checks to see
    -- if the user defined element should have a LOV
    -- associated with it or not. If it should then it returns
    -- true and populates sql_string - an out parameter.

    IF sql_string_exists(plan_id, char_id, org_id, user_id, x_lov_sql) THEN
        RETURN;
    END IF;

END get_plan_element_lov;

--
-- Added to the IF-ELSIF ladder for newly added collection elements
-- for ASO project. New entries are appended after Party_Name
-- rkunchal Thu Aug  1 12:27:48 PDT 2002
--

FUNCTION get_lov_sql (
    plan_id IN NUMBER,
    char_id IN NUMBER,
    org_id IN NUMBER,
    user_id IN NUMBER,
    depen1 IN VARCHAR2,
    depen2 IN VARCHAR2,
    depen3 IN VARCHAR2,
    value IN VARCHAR2) RETURN VARCHAR2 IS

    l_lov_sql VARCHAR2(1500);

BEGIN
    -- Bug 3228490 ksoh Fri Oct 31 11:38:21 PST 2003
    -- Now that we utilize fnd_msg_pub to show error messages
    -- we should clear stack so that errors are not shown over and over again.
    fnd_msg_pub.Initialize();
    fnd_msg_pub.reset();

    IF (char_id = qa_ss_const.department) THEN
        get_department_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.job_name) THEN
        get_job_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.work_order) THEN
        get_work_order_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.production_line) THEN
        get_production_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.resource_code) THEN
        get_resource_code_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.vendor_name) THEN
        get_supplier_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.po_number) THEN
        get_po_number_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.customer_name) THEN
        get_customer_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.sales_order) THEN
        get_so_number_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.order_line) THEN
       -- Bug 7716875.Added sales Order as dependent.The depen1 here
       -- will be passed as SO Number.pdube Mon Apr 13 03:25:19 PDT 2009
       -- get_so_line_number_lov(value, l_lov_sql);
       get_so_line_number_lov(plan_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.po_release_num) THEN
      --
      -- Bug 5003511. R12 Performance bug. SQLID: 15008630
      -- Release number is dependent on PO Number.
      -- Call new overloaded method.
      -- srhariha. Wed Feb  8 02:10:26 PST 2006.
      --
        get_po_release_number_lov(plan_id,depen1,value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.project_number) THEN
        get_project_number_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.task_number) THEN
       -- anagarwa Thu Jan 29 15:04:26 PST 2004
       -- Bug 3404863 : task lov should be dependent upon project so now we
       -- pass project number as parent element value.
        get_task_number_lov(plan_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.rma_number) THEN
        get_rma_number_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.uom) THEN
        -- get_uom_lov(org_id, item_name, value, l_lov_sql);
        get_uom_lov(plan_id, org_id, depen1, value, l_lov_sql);

    -- anagarwa Mon Feb 24 17:08:57 PST 2003
    -- Bug 2808693
    -- adding support for comp_revision
    ELSIF (char_id = qa_ss_const.revision OR
           char_id = qa_ss_const.comp_revision) THEN
        -- get_revision_lov(org_id, item_name, value, l_lov_sql);
        get_revision_lov(plan_id, org_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.subinventory) THEN
        get_subinventory_lov(org_id, value, l_lov_sql);

     -- anagarwa Thu Aug 12 15:49:51 PDT 2004
     -- bug 3830258 incorrect LOVs in QWB
     -- synced up the lot and serial number lov with forms
    ELSIF (char_id = qa_ss_const.lot_number) THEN
        -- get_lot_number_lov(transaction_id, value, l_lov_sql);
        -- get_lot_number_lov(depen3, value, l_lov_sql);
        get_lot_number_lov(plan_id, org_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.serial_number) THEN
        -- get_serial_number_lov(transaction_id, lot_number, value, l_lov_sql);
        -- get_serial_number_lov(plan_id, depen3, depen1, value, l_lov_sql);
        get_serial_number_lov(plan_id, org_id, depen2, depen3, depen1, value, l_lov_sql);

    -- dgupta: Start R12 EAM Integration. Bug 4345492
    ELSIF (char_id = qa_ss_const.asset_instance_number) THEN
        get_asset_instance_number_lov(plan_id, org_id, depen1,depen2,value, l_lov_sql);
    --dgupta: End R12 EAM Integration. Bug 4345492

    ELSIF (char_id = qa_ss_const.asset_number) THEN
        -- get_asset_number_lov(org_id, depen1, value, l_lov_sql);
        get_asset_number_lov(plan_id, org_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.from_op_seq_num) OR
        (char_id = qa_ss_const.to_op_seq_num) THEN
        -- get_op_seq_number_lov(org_id, value, job_name, production_line,
        --     l_lov_sql);
        get_op_seq_number_lov(plan_id, org_id, value, depen1, depen2, l_lov_sql);

    ELSIF (char_id = qa_ss_const.po_line_num) THEN
        -- get_po_line_number_lov(po_number, value, l_lov_sql);
        get_po_line_number_lov(plan_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.po_shipment_num) THEN
        -- get_po_shipments_lov(po_line_number, po_number, value, l_lov_sql);
        get_po_shipments_lov(plan_id, depen1, depen2, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.receipt_num) THEN
        get_receipt_num_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.item) THEN
        --
        -- bug 7197055
        -- Added depen1 (prod line) for item.
        -- skolluku
        --
        get_item_lov(org_id, value, depen1, l_lov_sql);

    -- rkaza. 12/15/2003. bug 3280307. Added lov for comp item
    ELSIF (char_id = qa_ss_const.comp_item) THEN
        get_comp_item_lov(plan_id, org_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.asset_group) THEN
        get_asset_group_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.asset_activity) THEN
        -- get_asset_activity_lov(org_id, depen1, depen2, value, l_lov_sql);
        get_asset_activity_lov(plan_id, org_id, depen1, depen2, value, l_lov_sql);

-- added the following to include new hardcoded element followup activity
-- saugupta

    ELSIF (char_id = qa_ss_const.followup_activity) THEN
        -- get_followup_activity_lov(org_id, depen1, depen2, value, l_lov_sql);
        get_followup_activity_lov(plan_id, org_id, depen1, depen2, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.xfr_license_plate_number) THEN
        get_xfr_lpn_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.locator) THEN
        -- get_locator_lov(org_id, depen1, value, l_lov_sql);
        get_locator_lov(plan_id, org_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.party_name) THEN
        get_party_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.item_instance) THEN
        --
        -- Bug 9032151
        -- Modified the below procedure to include the value
        -- for item on which item instance is dependent.
        -- skolluku
        --
        get_item_instance_lov(plan_id, depen1, value, l_lov_sql);

    --
    -- Bug 9359442
    -- Added lov for item instance serial based on item.
    -- skolluku
    --
    ELSIF (char_id = qa_ss_const.item_instance_serial) THEN
        get_item_instance_serial_lov(plan_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.service_request) THEN
        get_service_request_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.maintenance_requirement) THEN
        get_maintenance_req_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.rework_job) THEN
        get_rework_job_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.counter_name) THEN
        get_counter_name_lov(value, l_lov_sql);

    -- anagarwa Mon Feb  2 16:27:56 PST 2004
    -- Bug 3415693
    -- Disposition, disposition source, disposition actions and
    -- disposition status can all be processed using
    -- get_plan_element_lov and hence there is no need for the following code.
    -- Infact, the inclusion of the following code will cause incorrect lov
    -- to appear on selfservice
    -- For maintenance sake we should remove corresponding get lov functions
    -- too as they serve no purpose other than making this file bulkier.
/*
    ELSIF (char_id = qa_ss_const.disposition_source) THEN
        get_disposition_source_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.disposition_action) THEN
        get_disposition_action_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.disposition) THEN
        get_disposition_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.disposition_status) THEN
        get_disposition_status_lov(value, l_lov_sql);

*/
--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--
    ELSIF (char_id = qa_ss_const.maintenance_op_seq) THEN
        -- get_maintenance_op_seq_lov(org_id, value, depen1, l_lov_sql);
        get_maintenance_op_seq_lov(plan_id, org_id, value, depen1, l_lov_sql);
--
-- End of inclusions for Bug 2588213
--

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

    ELSIF (char_id = qa_ss_const.bill_reference) THEN
        get_bill_reference_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.routing_reference) THEN
        get_routing_reference_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.to_subinventory) THEN
        get_to_subinventory_lov(org_id, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.to_locator) THEN
        -- get_to_locator_lov(org_id, depen1, value, l_lov_sql);
        get_to_locator_lov(plan_id, org_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.lot_status) THEN
        get_lot_status_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.serial_status) THEN
        -- Bug 7588754. Added additional bind parameters
        -- pdube Wed Apr 15 07:37:25 PDT 2009
	-- get_serial_status_lov(value, l_lov_sql);
	get_serial_status_lov(value,depen1,depen2, l_lov_sql);

    ELSIF (char_id = qa_ss_const.nonconformance_source) THEN
        get_nonconformance_source_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.nonconform_severity) THEN
        get_nonconform_severity_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.nonconform_priority) THEN
        get_nonconform_priority_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.nonconformance_type) THEN
        get_nonconformance_type_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.nonconformance_status) THEN
        get_nonconformance_status_lov(value, l_lov_sql);

    --anagarwa Wed Jan 15 13:51:41 PST 2003
    -- Bug 2751198
    -- support needed for contract number, contract line number and
    -- deliverable number

    ELSIF (char_id = qa_ss_const.contract_number) THEN
        get_contract_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.contract_line_number) THEN
        get_contract_line_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.deliverable_number) THEN
        get_deliverable_lov(value, l_lov_sql);

-- End of inclusions for NCM Hardcode Elements.

--anagarwa Fri Nov 15 13:03:35 PST 2002
--Following added for new CAR lov's

    ELSIF (char_id = qa_ss_const.request_source) THEN
        get_request_source_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.request_priority) THEN
        get_request_priority_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.request_severity) THEN
        get_request_severity_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.request_status) THEN
        get_request_status_lov(value, l_lov_sql);

     -- anagarwa Thu Aug 12 15:49:51 PDT 2004
     -- bug 3830258 incorrect LOVs in QWB
     -- synced up the component lot number and component serial number
     -- lov with forms
    ELSIF (char_id = qa_ss_const.comp_lot_number) THEN
        get_comp_lot_number_lov(plan_id, org_id, depen1, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.comp_serial_number) THEN
        get_comp_serial_number_lov(plan_id, org_id, depen2, depen3, depen1, value, l_lov_sql);

-- End of inclusions for CAR Hardcode Elements.
    /* R12 DR Integration. Bug 4345489 Start */
    ELSIF (char_id = qa_ss_const.repair_order_number) THEN
        get_repair_order_lov(value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.jtf_task_number) THEN
        get_jtf_task_lov(value, l_lov_sql);
    /* R12 DR Integration. Bug 4345489 End */

-- R12 OPM Deviations. Bug 4345503 Start
    ELSIF (char_id = qa_ss_const.process_batch_num) THEN
        get_process_batch_num_lov(org_id,value,l_lov_sql);

    ELSIF (char_id = qa_ss_const.process_batchstep_num) THEN
          get_process_batchstep_num_lov
          (org_id,plan_id,depen1,value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.process_operation) THEN
          get_process_operation_lov
          (org_id,plan_id,depen1, depen2,value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.process_activity) THEN
          get_process_activity_lov
          (org_id,plan_id,depen1, depen2,value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.process_resource) THEN
         get_process_resource_lov
         (org_id,plan_id,depen1, depen2, depen3, value, l_lov_sql);

    ELSIF (char_id = qa_ss_const.process_parameter) THEN
         get_process_parameter_lov
         (org_id,plan_id,depen1, value, l_lov_sql);

-- R12 OPM Deviations. Bug 4345503 End

    --
    -- Bug 6161802
    -- Obtain rma line number lov with rma number as a bind variable.
    -- skolluku Mon Jul 16 22:08:16 PDT 2007
    --
    ELSIF (char_id = qa_ss_const.rma_line_num) THEN
        get_rma_line_num_lov(plan_id, depen1, value, l_lov_sql);

    ELSE
        get_plan_element_lov (plan_id, char_id, org_id, user_id, l_lov_sql);
    END IF;

    RETURN l_lov_sql;

END get_lov_sql;


-- Bug 4270911. SQL bind compliance fix.
-- Please see bugdb for more details and TD link.
-- srhariha. Thu Apr  7 21:43:08 PDT 2005.

FUNCTION get_lov_bind_values (
    plan_id IN NUMBER,
    char_id IN NUMBER,
    org_id IN NUMBER DEFAULT NULL,
    user_id IN NUMBER DEFAULT NULL,
    depen1 IN VARCHAR2 DEFAULT NULL,
    depen2 IN VARCHAR2 DEFAULT NULL,
    depen3 IN VARCHAR2 DEFAULT NULL,
    value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS

BEGIN


  -- Collection elements dependent only on ORG_ID.
  --
  -- Bug 7197055
  -- Commented out item, because a new method to fetch its bind values
  -- been created.
  -- skolluku
  --
  IF char_id IN ( qa_ss_const.department,
                  qa_ss_const.job_name,
                  qa_ss_const.work_order,
                  qa_ss_const.production_line,
                  qa_ss_const.resource_code,
                  -- qa_ss_const.uom,
                  qa_ss_const.subinventory,
                  -- qa_ss_const.item,
                  qa_ss_const.asset_group,
                  qa_ss_const.rework_job,
                  qa_ss_const.bill_reference,
                  qa_ss_const.routing_reference,
                  -- R12 OPM Deviations. Bug 4345503 Start
                  qa_ss_const.process_batch_num,
                  -- R12 OPM Deviations. Bug 4345503 End
                  qa_ss_const.to_subinventory )  THEN

    RETURN to_char(org_id);

  END IF;

  -- Collection elements based on QA_LOOKUPS.

  IF char_id IN ( qa_ss_const.nonconformance_source,
                  qa_ss_const.nonconform_severity,
                  qa_ss_const.nonconform_priority,
                  qa_ss_const.nonconformance_status,
                  qa_ss_const.nonconformance_type,
                  qa_ss_const.request_source,
                  qa_ss_const.request_priority,
                  qa_ss_const.request_severity,
                  qa_ss_const.request_status ) THEN

    RETURN to_char(char_id);

  END IF;

  -- Other dependent elements.

  IF char_id = qa_ss_const.task_number THEN
    RETURN get_task_number_bind_values(depen1);

  ELSIF (char_id = qa_ss_const.revision OR
         char_id = qa_ss_const.comp_revision) THEN
    RETURN get_revision_bind_values(org_id, depen1);

  -- Bug 5005707. Adding item as a filtering criteria
  -- for item uom to improve performance.
  -- Removed the same from the above if condition
  -- saugupta Mon, 10 Jul 2006 21:47:17 -0700 PDT
  ELSIF (char_id = qa_ss_const.uom) THEN
    RETURN get_uom_bind_values(p_org_id => org_id, p_item_name => depen1);

  ELSIF (char_id = qa_ss_const.lot_number) THEN
    RETURN  get_lot_number_bind_values(org_id, depen1);

  ELSIF (char_id = qa_ss_const.comp_lot_number) THEN
    RETURN  get_comp_lot_bind_values(org_id, depen1);

  ELSIF (char_id = qa_ss_const.serial_number) THEN
    RETURN  get_serial_no_bind_values(plan_id, org_id, depen2, depen3, depen1);

  ELSIF (char_id = qa_ss_const.comp_serial_number) THEN
    RETURN  get_comp_serial_no_bind_values(plan_id, org_id, depen2, depen3, depen1);

  -- dgupta: Start R12 EAM Integration. Bug 4345492
  ELSIF (char_id = qa_ss_const.asset_instance_number) THEN
    RETURN  get_asset_inst_num_bind_values(org_id, depen1, depen2);

  ELSIF (char_id = qa_ss_const.asset_number) THEN
    RETURN  get_asset_number_bind_values(org_id, depen1, depen2);
  --dgupta: End R12 EAM Integration. Bug 4345492

  ELSIF (char_id = qa_ss_const.from_op_seq_num) OR
        (char_id = qa_ss_const.to_op_seq_num) THEN
    RETURN  get_op_seq_no_bind_values(plan_id, org_id, depen1, depen2);

  ELSIF (char_id = qa_ss_const.po_line_num) THEN
    RETURN get_po_line_no_bind_values(depen1);

  ELSIF (char_id = qa_ss_const.po_shipment_num) THEN
    RETURN get_po_shipments_bind_values (depen1, depen2);

  ELSIF (char_id = qa_ss_const.comp_item) THEN
    RETURN get_comp_item_bind_values (org_id, depen1);

  -- dgupta: Start R12 EAM Integration. Bug 4345492
  ELSIF (char_id = qa_ss_const.asset_activity) THEN
    RETURN  get_asset_activity_bind_values (org_id, depen1, depen2, depen3);

  ELSIF (char_id = qa_ss_const.followup_activity) THEN
    RETURN  get_followup_act_bind_values(org_id, depen1, depen2, depen3);
  --dgupta: End R12 EAM Integration. Bug 4345492

  ELSIF (char_id = qa_ss_const.locator) OR
        (char_id = qa_ss_const.to_locator) THEN
    RETURN  get_locator_bind_values(org_id, depen1);

  ELSIF (char_id = qa_ss_const.maintenance_op_seq) THEN
    RETURN get_maint_op_seq_bind_values(org_id, depen1);

  -- R12 OPM Deviations. Bug 4345503 Start
  ELSIF (char_id = qa_ss_const.process_batchstep_num) THEN
    RETURN GET_PROCESS_STEP_BIND_VALUE(org_id, depen1);

  ELSIF (char_id = qa_ss_const.process_operation) THEN
    RETURN GET_PROCESS_OPRN_BIND_VALUE(org_id, depen1, depen2);

  ELSIF (char_id = qa_ss_const.process_activity) THEN
    RETURN GET_PROCESS_ACT_BIND_VALUE(org_id, depen1, depen2);

  ELSIF (char_id = qa_ss_const.process_resource) THEN
    RETURN GET_PROCESS_RSR_BIND_VALUE(org_id, depen1, depen2, depen3);

  ELSIF (char_id = qa_ss_const.process_parameter) THEN
    RETURN GET_PROCESS_PARAM_BIND_VALUE(org_id, depen1);
  -- R12 OPM Deviations. Bug 4345503 End

  ELSIF (char_id = qa_ss_const.po_release_num) THEN
      --
      -- Bug 5003511. R12 Performance bug. SQLID: 15008630
      -- Release number is dependent on PO Number.
      -- Call new method for bind values.
      -- srhariha. Wed Feb  8 02:10:26 PST 2006.
      --
      RETURN get_po_rel_no_bind_values(depen1);
  --
  -- Bug 6161802
  -- Return rma number as a bind variable for rma line number lov
  -- skolluku Mon Jul 16 22:08:16 PDT 2007
  --
  ELSIF (char_id = qa_ss_const.rma_line_num) THEN
    RETURN get_rma_line_num_bind_values(depen1);

  -- Bug 7716875.Return SO Number as bind variable for
  -- SO Line Number.pdube Mon Apr 13 03:25:19 PDT 2009
  ELSIF (char_id = qa_ss_const.order_line) THEN
     RETURN get_so_line_num_bind_values(depen1);

  -- Bug 7588754.Added org_id,item and srl number as binds
  ELSIF (char_id = qa_ss_const.serial_status) THEN
     RETURN get_serial_status_bind_values(org_id,depen1,depen2);
  --
  -- bug 7197055
  -- Fetch bind values for item.
  -- skolluku
  --
  ELSIF (char_id = qa_ss_const.item) THEN
     RETURN get_item_bind_values(org_id,depen1);
  --
  -- Bug 9032151
  -- Return item as a bind variable for item instance lov
  -- skolluku
  --
  ELSIF (char_id = qa_ss_const.item_instance) THEN
    RETURN get_item_instance_bind_values(org_id, depen1);
  --
  -- Bug 9359442
  -- Return item as a bind variable for item instance serial lov
  -- skolluku
  --
  ELSIF (char_id = qa_ss_const.item_instance_serial) THEN
    RETURN get_item_inst_ser_bind_values(org_id, depen1);
  ELSE

    -- Will handle qa_plan_char_value_lookups.
    -- For all other cases it returns  NULL
    RETURN  sql_string_bind_values (plan_id, char_id);

  END IF;


RETURN NULL;

END get_lov_bind_values;


END qa_ss_lov_api;

/
