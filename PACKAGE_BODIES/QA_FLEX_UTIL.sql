--------------------------------------------------------
--  DDL for Package Body QA_FLEX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_FLEX_UTIL" AS
/* $Header: qltutlfb.plb 120.7.12000000.2 2007/07/17 10:18:23 bhsankar ship $ */


    FUNCTION item2(p_org_id NUMBER, p_item_id NUMBER) RETURN VARCHAR2 IS
    -- ERES project, tracking bug 3071511.
    -- This function differs from item() because it does not raise
    -- exception if ID is not found.
    --
    -- Return item name from mtl_system_items.
    -- Return null if not found.
    --
        l_value varchar2(2000);
        CURSOR c IS
            SELECT concatenated_segments
            FROM   mtl_system_items_kfv
            WHERE  inventory_item_id = p_item_id AND
                   organization_id = p_org_id;

    BEGIN
        IF p_org_id IS NULL OR p_item_id IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO l_value;
        CLOSE c;

        RETURN l_value;
    END item2;


    FUNCTION locator2(p_org_id NUMBER, p_locator_id NUMBER) RETURN VARCHAR2 IS
    -- ERES project, tracking bug 3071511.
    -- This function differs from locator() because it does not raise
    -- exception if ID is not found.
    --
    -- Return locator name from mtl_item_locations.
    -- Return null if not found.
    --
        l_value varchar2(2000);
        CURSOR c IS
            SELECT concatenated_segments
            FROM   mtl_item_locations_kfv
            WHERE  inventory_location_id = p_locator_id and
                   organization_id = p_org_id;

    BEGIN
        IF p_org_id IS NULL OR p_locator_id IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO l_value;
        CLOSE c;

        RETURN l_value;
    END locator2;


FUNCTION  item(x_org_id number, x_item_id number) return varchar2 is

        item_name varchar2(2000);

       -- Bug 5245271 and 5245135. Modified query to consider EAM maint org.
       cursor c(c_org_id NUMBER,c_item_id NUMBER) IS
        select concatenated_segments
        from mtl_system_items_kfv
        where inventory_item_id = c_item_id
        and organization_id = c_org_id
	and rownum=1
         UNION ALL
        select concatenated_segments
        from mtl_system_items_kfv msikfv,mtl_parameters mp
        where msikfv.inventory_item_id = c_item_id
        and msikfv.organization_id = mp.organization_id
        and mp.maint_organization_id = c_org_id
        and rownum=1;

BEGIN
        IF ((x_org_id IS NULL) or (x_item_id is null))  THEN
            RETURN NULL;
        END IF;

        OPEN c(x_org_id,x_item_id);
        FETCH c into item_name;
        CLOSE c;
        return item_name;

        EXCEPTION
                when OTHERS then
                        raise;

END;


FUNCTION get_item_id (x_org_id number, x_item VARCHAR2) return NUMBER is

        id NUMBER;

BEGIN

        IF ((x_org_id IS NULL) or (x_item is null))  THEN
            RETURN NULL;
        END IF;

        --
        -- Bug 2672398.  The SQL used to have upper() on
        -- both sides of the x_item where condition.  This
        -- is too expensive because it hides the index.
        -- bso Mon Nov 25 19:11:12 PST 2002
        --

/*
        select inventory_item_id into id
        from mtl_system_items_kfv
        where concatenated_segments = x_item
        and organization_id = x_org_id
        and rownum = 1;

        return id;
*/

        -- Bug 3111310. For SQL Performance Project.
        -- Used to have a SQL that select from _kfv which is inefficient.
        -- Commented the above code and used FND_FLEX routine for attaining
        -- the same.
        -- ksoh/kabalakr Fri Sep 26 06:31:05 PDT 2003
        --

        IF (FND_FLEX_KEYVAL.validate_segs(
                   operation        => 'CHECK_COMBINATION',
                   key_flex_code    => 'MSTK',
                   appl_short_name  => 'INV',
                   structure_number => '101',
                   concat_segments  => x_item,
                   data_set         => x_org_id)) THEN

           return FND_FLEX_KEYVAL.combination_id;

        ELSE
           return NULL;

        END IF;

        EXCEPTION

                when OTHERS then
                        raise;

END;


-- The following function is added to make item_category a collection trigger
-- It can be called from mobile or self service.
-- In mobile, the user will have item_value and not the id but in self service
-- item_id is available. To ensure the scalability, this function takes in
-- both, item_value as well as item_id. It calls get_item_id to get item_id
-- based upon item_value and then uses this to get item_category.
-- anagarwa Tue Sep 18 16:19:08 PDT 2001

PROCEDURE get_item_category_val (p_org_id NUMBER,
                                 p_item_val VARCHAR2,
                                 p_item_id NUMBER,
                                 x_category_val OUT NOCOPY VARCHAR2,
                                 x_category_id OUT NOCOPY NUMBER) IS

l_item_id          NUMBER;
l_category_set_id  NUMBER;
l_category_val     VARCHAR2(1000) := NULL;
l_category_id      NUMBER := NULL;


CURSOR category_cur(p_org_id NUMBER, p_item_id NUMBER, p_category_set_id NUMBER) IS
        select  mck.concatenated_segments,
                mck.category_id
        from    mtl_item_categories mic, mtl_categories_kfv mck
        where   mic.organization_id = p_org_id
        and     mic.category_id = mck.category_id
        and     mic.inventory_item_id =p_item_id
        and     mic.category_set_id = p_category_set_id;

BEGIN
        -- org_id should never be null
        IF (p_org_id IS NULL) THEN
            RETURN ;
        END IF;

        -- if calling from mobile, then get_item_id
        IF ((p_item_id <0 OR p_item_id IS NULL) AND (p_item_val IS NOT NULL))
	 THEN
            l_item_id := get_item_id(p_org_id, p_item_val);
        ELSE
            l_item_id := p_item_id;
        END IF;

        l_category_set_id :=  FND_PROFILE.VALUE('QA_CATEGORY_SET');

        OPEN category_cur( p_org_id, l_item_id, l_category_set_id);

        FETCH category_cur INTO l_category_val, l_category_id;

        CLOSE category_cur;

	--if cursor did not fetch any rows
	--then l_category_val and l_category_id will have
	--initialized NULL values
	--Do Not Raise Exception Here
	--
	x_category_val  := l_category_val;
	x_category_id	:= l_category_id;

        RETURN;

END;

    --orashid Wed Sep 19 16:55:39 PDT 2001
    FUNCTION work_order (x_org_id NUMBER, x_work_order_id number)
        RETURN VARCHAR2 IS

        x_work_order varchar2(150) := NULL;
         --
         -- Bug 4958777. R12 Performance fix.
         -- Use base table to reduce the shared memory.
         -- srhariha. Mon Jan 30 01:25:38 PST 2006
         --
        CURSOR c IS
            SELECT wip_entity_name
            FROM wip_entities
            WHERE wip_entity_id = x_work_order_id
                AND organization_id = x_org_id;

/*
            SELECT wip_entity_name
            FROM wip_eam_work_order_dtls_v
            WHERE wip_entity_id = x_work_order_id
            AND organization_id = x_org_id;
*/

    BEGIN

        IF ((x_org_id IS NULL) or (x_work_order_id is null))  THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO x_work_order;
        CLOSE c;

        RETURN x_work_order;

    END work_order;



FUNCTION locator(x_org_id number, x_locator_id number) return varchar2 is
        locator_name varchar2(2000);

BEGIN

        IF ((x_org_id IS NULL) or (x_locator_id is null))  THEN
            RETURN NULL;
        END IF;

        select concatenated_segments into locator_name
        from mtl_item_locations_kfv
        where  INVENTORY_LOCATION_ID  = x_locator_id
              and organization_id = x_org_id
              and rownum=1;

        return locator_name;

        EXCEPTION when OTHERS then
                raise;
END;


FUNCTION get_locator_id (x_org_id number, x_locator VARCHAR2) return NUMBER is

        id NUMBER;

BEGIN

        IF ((x_org_id IS NULL) or (x_locator is null))  THEN
            RETURN NULL;
        END IF;

        --
        -- Bug 2672398.  The SQL used to have upper() on
        -- both sides of the x_locator where condition.  This
        -- is too expensive because it hides the index.
        -- bso Mon Nov 25 19:11:12 PST 2002
        --

/*
        select inventory_location_id into id
        from mtl_item_locations_kfv
        where concatenated_segments = x_locator
        and organization_id = x_org_id
        and rownum = 1;

        return id;
*/

        -- Bug 3111310. For SQL Performance Project.
        -- Used to have a SQL that select from _kfv which is inefficient.
        -- Commented the above code and used FND_FLEX routine for attaining
        -- the same.
        -- ksoh/kabalakr Fri Sep 26 06:31:05 PDT 2003
        --

        IF (FND_FLEX_KEYVAL.validate_segs(
                   operation        => 'CHECK_COMBINATION',
                   key_flex_code    => 'MTLL',
                   appl_short_name  => 'INV',
                   structure_number => '101',
                   concat_segments  => x_locator,
                   -- bug 6129280
                   -- The default is values, but since the x_locator
                   -- has the id values the processing needs to be done
                   -- using IDs, hence, added the following parameter.
                   -- bhsankar Tue Jul 17 02:35:19 PDT 2007
                   values_or_ids    => 'I',
                   data_set         => x_org_id)) THEN

           return FND_FLEX_KEYVAL.combination_id;

        ELSE
           return NULL;

        END IF;

        EXCEPTION when OTHERS then
                raise;

END;


    FUNCTION project_number(x_id number) RETURN varchar2 IS
    --
    -- Return project_number from mtl_project_v given a project ID.
    --
    -- This function is created mostly for performance reason.  We do
    -- outer joins to mtl_project_v from qa_results_v and global views.
    -- The outer join is causing full table scans in various PJM tables.
    -- A stored procedure will be able to decode the project number with
    -- index hits.
    --
    -- mtl_project_v may be obsoleted in R12, use pjm_org_projects_v
    --
    -- bso Thu Jul  8 15:53:37 PDT 1999
    -- pjm_org_projects_v changed to pjm_projects_all_v - rkaza, 11/10/2001.

    --
    -- Bug 5249078.  There is no need to change the following
    -- pjm_projects_all_v because this is a de-reference logic,
    -- not a validation logic.
    -- bso Thu Jun  1 10:56:46 PDT 2006
    --
        x_project_number varchar2(100) := NULL;
        CURSOR c IS
            SELECT project_number
            FROM   pjm_projects_all_v
            WHERE  project_id = x_id;

    BEGIN
        IF x_id IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO x_project_number;
        CLOSE c;

        --
        -- x_project_number will be null if not found.
        --
        RETURN x_project_number;
    END project_number;


    FUNCTION sales_order(x_id number) RETURN varchar2 IS
    --
    -- Return sales_order given a sales order ID.
    --
    -- *OBSOLETE*
    -- This function is created mostly for performance reason.  OE
    -- is revamping their product.  Eventually, the so_headers table
    -- will be obsolete and a view so_headers_interop_v will be in
    -- its place.  Then, our outer join in qa_results_v will cause
    -- full table scans to various underlying tables.  When that
    -- happens, we will use this function to decode the sales order
    -- in the view.
    --
    -- bso Sun Jul 25 12:48:25 PDT 1999
    --
    -- *OBSOLETE*
    -- changed to query from oe_order_headers view in case interop_v
    -- is not supported.
    -- bso Fri Mar  3 15:56:03 PST 2000
    --
    -- Completely eliminated oe table(s) from the query because
    -- mtl_sales_orders is a superset of all sales orders.  Further,
    -- 3rd party sales orders can be alphanumeric, changed from
    -- a numeric function to a varchar2 function.
    -- See Bug 1982788.
    -- bso Sun Sep 16 15:58:51 PDT 2001

        x_sales_order mtl_sales_orders.segment1%TYPE := NULL;
        CURSOR c IS
            SELECT segment1 order_number
            FROM   mtl_sales_orders
            WHERE  sales_order_id = x_id;

    BEGIN
        IF x_id IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO x_sales_order;
        CLOSE c;

        --
        -- x_sales_order will be null if not found.
        --
        RETURN x_sales_order;
    END sales_order;


    FUNCTION rma_number(x_id number) RETURN number IS
    --
    -- Return rma_number given a sales order ID.
    -- Same comments as above.
    -- bso Sun Jul 25 12:48:25 PDT 1999
    --
    -- changed to query from oe_order_headers view in case interop_v
    -- is not supported.
    -- bso Fri Mar  3 15:56:03 PST 2000

    -- Changed the from clause in the below cursor from the view
    -- oe_order_headers to the base table oe_order_headers_all to
    -- enable RMA number collection element to honour all Operating
    -- Units. Refer bug for more details.
    -- Bug 3430888. suramasw

        x_sales_order number := NULL;
        CURSOR c IS
            SELECT order_number
            FROM   oe_order_headers_all
            WHERE  header_id = x_id;

    BEGIN
        IF x_id IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO x_sales_order;
        CLOSE c;

        --
        -- x_sales_order will be null if not found.
        --
        RETURN x_sales_order;
    END rma_number;


    -- Added the following three functions for performance reason.
    -- This functions are called from qa_results_v definition to
    -- get the number value from the IDs. Using stored procedure will
    -- avoid outjoin to complex views as will cause full table scan.
    -- jezheng
    --  Wed Sep 13 11:00:28 PDT 2000

    -- Return contract_number from oke_k_headers_lov_v
    -- given a contract ID.

    FUNCTION contract_number(x_id number) RETURN varchar2 IS

    x_contract_number varchar2(120) := NULL;
    CURSOR c IS
        SELECT k_number
        FROM   oke_k_headers_lov_v
        WHERE  k_header_id = x_id;

    BEGIN
        IF x_id IS NOT NULL THEN
            OPEN c;
            FETCH c INTO x_contract_number;
            CLOSE c;
        END IF;

        -- x_contract_number will be null if not found.
        RETURN x_contract_number;

    END contract_number;

    -- Return contract_line_number from oke_k_lines_full_v
    -- given contract_line_id.

    FUNCTION contract_line_number(x_id number) RETURN varchar2 IS

    x_contract_line_number varchar2(150) := NULL;
    CURSOR c IS
        SELECT line_number
        FROM   oke_k_lines_full_v
        WHERE  k_line_id = x_id;

    BEGIN
        IF x_id IS NOT NULL THEN
            OPEN c;
            FETCH c INTO x_contract_line_number;
            CLOSE c;
        END IF;

        -- x_contract_line_number will be null if not found.
        RETURN x_contract_line_number;

    END contract_line_number;

    -- Return deliverable_number from oke_k_deliverables_vl
    -- given a deliverable ID.

    FUNCTION deliverable_number(x_id number) RETURN varchar2 IS

    x_deliverable_number varchar2(150) := NULL;
    CURSOR c IS
        SELECT deliverable_num
        FROM   oke_k_deliverables_vl
        WHERE  deliverable_id = x_id;

    BEGIN
        IF x_id IS NOT NULL THEN
            OPEN c;
            FETCH c INTO x_deliverable_number;
            CLOSE c;
        END IF;

        -- x_deliverable_number will be null if not found.
        RETURN x_deliverable_number;

    END deliverable_number;


    --
    --  The following qpc functions are implemented but not used.
    --  A better way to fix the problem was found.  But I'll leave
    --  these here as a model of an interesting cache programming
    --  technique which will be useful for any api programming.
    --  bso Thu Oct 28 17:05:21 PDT 1999
    --

        PROCEDURE qpc_fetch(x_plan_id number, x_char_id number) IS
        --
        -- To maintain a cache for the qa_plan_chars table.
        --
            CURSOR c IS
                SELECT result_column_name, values_exist_flag
                FROM   qa_plan_chars
                WHERE  plan_id = x_plan_id AND
                       char_id = x_char_id;
        BEGIN
            --
            -- Fetch only if primary keys different from cached.
            --
            IF x_plan_id <> cached_qpc_plan_id OR
                x_char_id <> cached_qpc_char_id THEN
                cached_qpc_plan_id := x_plan_id;
                cached_qpc_char_id := x_char_id;
                OPEN c;
                FETCH c INTO
                    cached_qpc_result_column_name,
                    cached_qpc_values_exist_flag;
                IF c%notfound THEN
                    --
                    -- Cached values should be null if not found.
                    --
                    cached_qpc_result_column_name := null;
                    cached_qpc_values_exist_flag := null;
                END IF;
                CLOSE c;
            END IF;
        END qpc_fetch;



    FUNCTION qpc_result_column_name(x_plan_id number, x_char_id number)
        RETURN varchar2 IS
    --
    -- Return the result_column_name from qa_plan_chars given a plan_id
    -- and a char_id.  Return null if not found.
    -- bso
    --
    BEGIN
        qpc_fetch(x_plan_id, x_char_id);
        RETURN cached_qpc_result_column_name;
    END qpc_result_column_name;


    FUNCTION qpc_values_exist_flag(x_plan_id number, x_char_id number)
        RETURN number IS
    --
    -- Return qpc_values_exist_flag (an integer) from qa_plan_chars given a
    -- plan_id and a char_id.  Return null if not found.
    -- bso
    --
    BEGIN
        qpc_fetch(x_plan_id, x_char_id);
        RETURN cached_qpc_values_exist_flag;
    END qpc_values_exist_flag;


    FUNCTION qch_plan_id(x_criteria_id number) RETURN number IS
    --
    -- Return plan_id from qa_criteria_headers given a criteria_id.
    -- Return null if not found.
    --
        x_plan_id number := null;
        CURSOR c IS
            SELECT plan_id
            FROM   qa_criteria_headers
            WHERE  criteria_id = x_criteria_id;
    BEGIN
        IF x_criteria_id IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO x_plan_id;
        CLOSE c;

        RETURN x_plan_id;
    END qch_plan_id;


    FUNCTION mtl_categories_description(x_category_id number) RETURN varchar2 IS
    --
    -- Return description from mtl_categories_kfv given category_id.
    -- Return null if not found.
    --
        x_description varchar2(240) := null;
        CURSOR c IS
            SELECT description
            FROM   mtl_categories_kfv
            WHERE  category_id = x_category_id;
    BEGIN
        IF x_category_id IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO x_description;
        CLOSE c;

        RETURN x_description;
    END mtl_categories_description;

    --
    -- Derive project id given an LPN.  Used internally.
    -- bso Wed Mar 13 16:53:35 PST 2002
    --
    FUNCTION get_project_id_from_lpn(
        p_org_id NUMBER,
        p_lpn_id NUMBER) RETURN NUMBER IS

        l_project_id NUMBER;
        l_task_id NUMBER;
        l_return_status VARCHAR2(10);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);

    BEGIN
        inv_project.get_proj_task_from_lpn(
            p_organization_id => p_org_id,
            p_lpn_id => p_lpn_id,
            x_project_id => l_project_id,
            x_task_id => l_task_id,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data);

        RETURN l_project_id;
    END get_project_id_from_lpn;

    --
    -- Derive task id given an LPN.  Used internally.
    -- bso Wed Mar 13 16:53:35 PST 2002
    --
    FUNCTION get_task_id_from_lpn(
        p_org_id NUMBER,
        p_lpn_id NUMBER) RETURN NUMBER IS

        l_project_id NUMBER;
        l_task_id NUMBER;
        l_return_status VARCHAR2(10);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);

    BEGIN
        inv_project.get_proj_task_from_lpn(
            p_organization_id => p_org_id,
            p_lpn_id => p_lpn_id,
            x_project_id => l_project_id,
            x_task_id => l_task_id,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data);

        RETURN l_task_id;
    END get_task_id_from_lpn;


    --
    -- Derive project number given an LPN.  Used by WMS/QA mobile integration.
    -- See /qadev/qa/51.0/11.5.8/wms_pjm_dld.txt
    -- bso Wed Mar 13 16:53:35 PST 2002
    --
    PROCEDURE get_project_number_from_lpn(
        p_org_id NUMBER,
        p_lpn_id NUMBER,
        x_project_number OUT NOCOPY VARCHAR2) IS

    BEGIN

        x_project_number := project_number(
            get_project_id_from_lpn(p_org_id, p_lpn_id));

    END get_project_number_from_lpn;


    --
    -- Derive task number given an LPN.  Used by WMS/QA mobile integration.
    -- See /qadev/qa/51.0/11.5.8/wms_pjm_dld.txt
    -- bso Wed Mar 13 16:53:35 PST 2002
    --
    PROCEDURE get_task_number_from_lpn(
        p_org_id NUMBER,
        p_lpn_id NUMBER,
        x_task_number OUT NOCOPY VARCHAR2) IS
    BEGIN

        x_task_number := inv_project.get_task_number(
            get_task_id_from_lpn(p_org_id, p_lpn_id));

    END get_task_number_from_lpn;

    FUNCTION get_vendor_site_id(p_vendor_site VARCHAR2) RETURN NUMBER IS

    x_vendor_site_id NUMBER;
    CURSOR c IS
       SELECT vendor_site_id
       FROM   po_vendor_sites_all
       WHERE  vendor_site_code = p_vendor_site;
    BEGIN
       IF p_vendor_site IS NULL THEN
          RETURN -1;
       END IF;

       OPEN c;
       FETCH c INTO x_vendor_site_id;
       CLOSE c;

       RETURN x_vendor_site_id;

    END get_vendor_site_id;

    FUNCTION get_project_id(p_project_number VARCHAR2) RETURN NUMBER IS
    --
    -- Return project_id given a project number.
    --
    -- rponnusa Mon Oct  7 05:59:17 PDT 2002

    --
    --  Bug 5249078.  Changed pjm_projects_all_v to
    --  pjm_projects_v for MOAC compliance.
    --  bso Thu Jun  1 10:46:50 PDT 2006
    --

        l_project_id NUMBER;
        CURSOR c IS
            SELECT project_id
            FROM   pjm_projects_v
            WHERE  project_number = p_project_number;

    BEGIN
        IF p_project_number IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO l_project_id;
        CLOSE c;
        RETURN l_project_id;

    END get_project_id;

    FUNCTION get_task_id(p_project_id NUMBER,p_task_number VARCHAR2) RETURN NUMBER IS
    --
    -- Return task_id given a project_id and task number.
    --
    -- rponnusa Mon Oct  7 05:59:17 PDT 2002

        l_task_id NUMBER;
        CURSOR c IS
            SELECT task_id
            FROM   mtl_task_v
            WHERE  project_id = p_project_id
            AND    task_number = p_task_number;

    BEGIN
        IF p_project_id IS NULL  OR p_task_number IS NULL THEN
            RETURN NULL;
        END IF;

        OPEN c;
        FETCH c INTO l_task_id;
        CLOSE c;

        RETURN l_task_id;

    END get_task_id;


    -- Bug 3096256.
    -- This procedures returns the Subinventory of an LPN given the LPN_ID
    -- from wms_license_plate_numbers. This procedure is called from
    -- getSubinventoryFromLPN() method in ContextElementTable.java.
    -- For RCV/WMS Enhancements. kabalakr Mon Aug 25 04:12:48 PDT 2003.

    PROCEDURE get_subinventory_from_lpn(
                p_lpn_id NUMBER,
                x_subinventory OUT NOCOPY VARCHAR2) IS

        CURSOR C1 IS
          SELECT subinventory_code
          FROM   wms_license_plate_numbers
          WHERE  lpn_id = p_lpn_id;

    BEGIN

        OPEN C1;
        FETCH C1 INTO x_subinventory;
        CLOSE C1;

    END get_subinventory_from_lpn;


    -- Bug 3096256.
    -- This procedures returns the Locator of an LPN given the LPN_ID
    -- from wms_license_plate_numbers. This procedure is called from
    -- getLocatorFromLPN() method in ContextElementTable.java.
    -- For RCV/WMS Enhancements. kabalakr Mon Aug 25 04:12:48 PDT 2003.

    PROCEDURE get_locator_from_lpn(
                p_org_id NUMBER,
                p_lpn_id NUMBER,
                x_locator OUT NOCOPY VARCHAR2) IS

        l_locator_id  NUMBER;

        CURSOR C1 IS
          SELECT locator_id
          FROM   wms_license_plate_numbers
          WHERE  lpn_id = p_lpn_id;

    BEGIN

        OPEN C1;
        FETCH C1 INTO l_locator_id;
        CLOSE C1;

        x_locator := locator(p_org_id, l_locator_id);

    END get_locator_from_lpn;


--dgupta: Start R12 EAM Integration. Bug 4345492
FUNCTION get_asset_group_name (org_id IN NUMBER, value IN NUMBER)
    RETURN VARCHAR2 IS

    name          VARCHAR2(2000);
   --rownum=1 =>better performance since all rows have same inventory_item_id
    CURSOR c (o_id NUMBER, asset_group_id NUMBER) IS
        SELECT msikfv.concatenated_segments
        FROM mtl_system_items_b_kfv msikfv, mtl_parameters mp
        WHERE msikfv.organization_id = mp.organization_id
        and msikfv.eam_item_type in (1,3)
        and mp.maint_organization_id = o_id
        and msikfv.inventory_item_id = asset_group_id
        and rownum=1;

BEGIN

    IF value IS NULL THEN
        RETURN NULL;
    END IF;

    OPEN c(org_id, value);
    FETCH c INTO name;
    CLOSE c;

    RETURN name;

END get_asset_group_name;
--dgupta: End R12 EAM Integration. Bug 4345492

 --
 --  Bug 4958739. R12 Performance fixes.
 --  New utility function for getting qa_lookup meaning.
 --  srhariha. Mon Jan 30 01:25:38 PST 2006
 --
 FUNCTION get_qa_lookups_meaning (p_lookup_type IN VARCHAR2,
                                  p_lookup_code IN VARCHAR2)
                                                 RETURN VARCHAR2 IS

    l_meaning  VARCHAR2(80);

    CURSOR C1 IS
      SELECT meaning
      FROM   qa_lookups
      WHERE  lookup_type = p_lookup_type
      AND lookup_code = p_lookup_code;

  BEGIN

    OPEN  C1;
    FETCH C1 INTO l_meaning;
    CLOSE C1;

    RETURN l_meaning;

  END get_qa_lookups_meaning;

 --
 --  Bug 5279941.
 --  New utility function for getting the asset instance
 --  name from the asset instance Number
 --  ntungare Wed Jun 21 01:45:43 PDT 2006
 --
 FUNCTION get_asset_instance_name (p_asset_instance_number IN VARCHAR2)
    RETURN VARCHAR2 IS

    l_asset_instance_name  VARCHAR2(2000) :=NULL;

    CURSOR C1 IS
     SELECT instance_number
        FROM CSI_ITEM_INSTANCES
      WHERE INSTANCE_id = p_asset_instance_number;

  BEGIN

    OPEN  C1;
    FETCH C1 INTO l_asset_instance_name;
    CLOSE C1;

    RETURN l_asset_instance_name;

  END get_asset_instance_name;

END QA_FLEX_UTIL;

/
