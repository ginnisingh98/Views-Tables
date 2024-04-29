--------------------------------------------------------
--  DDL for Package Body MRP_KANBAN_SNAPSHOT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_KANBAN_SNAPSHOT_PK" AS
/* $Header: MRPKSNPB.pls 120.4 2005/12/29 19:11:57 ksuleman noship $  */


-- ========================================================================
--  This function checks if the from locations (from subinventory and from
--  locator ) are null in the mrp_low_level_codes table and populates them
-- ========================================================================
FUNCTION CHECK_ITEM_LOCATIONS RETURN BOOLEAN IS

l_count		number;
l_item		varchar2(40);

-- declare a cursor for detailed debug information. This will be used
-- only if debug is turned on.
CURSOR cur_debug is
SELECT distinct msi.concatenated_segments
FROM   mtl_system_items_kfv msi, mrp_low_level_codes mllc
WHERE  mllc.plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
AND    mllc.organization_id =
		mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
AND    mllc.from_subinventory IS NULL
AND    mllc.from_locator_id IS NULL
AND    mllc.kanban_item_flag = 'Y'
AND    mllc.assembly_item_id <> mllc.component_item_id
AND    msi.organization_id = mllc.organization_id
AND    msi.inventory_item_id = mllc.component_item_id;


BEGIN

  mrp_kanban_plan_pk.g_stmt_num := 120;
  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  mrp_kanban_plan_pk.g_log_message := 'Entering Check_Item_Locations Procedure';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;


  -- first check if any of the kanban items have null locations
  SELECT count(*)
  INTO   l_count
  FROM   mrp_low_level_codes
  WHERE  plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
  AND    organization_id = mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
  AND    from_subinventory IS NULL
  AND    from_locator_id IS NULL
  AND    kanban_item_flag = 'Y'
  AND    assembly_item_id <> component_item_id;


/*  This section will be enabled for R12, We will not have any data in
bom_inventory_backflush_subinv for R11


  -- this is the first thing we do to get the sub and locator information
  IF l_count > 0 THEN

    UPDATE mrp_low_level_codes mllc
    SET    (mllc.from_subinventory, mllc.from_locator_id) =
    	   (SELECT bibs.SUBINVENTORY_NAME, bibs.LOCATOR_ID
    	    FROM   bom_inventory_backflush_subinv bibs
    	    AND    bibs.inventory_item_id = mllc.component_item_id
    	    AND	   bibs.organization_id = mllc.organization_id
    	    AND    bibs.location_type = 1)  --  ??
    WHERE  mllc.plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
    AND    mllc.organization_id =
		mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
    AND    mllc.from_subinventory IS NULL
    AND	   mllc.from_locator_id IS NULL
    AND	   mllc.kanban_item_flag = 'Y'
    AND	   mllc.assembly_item_id <> mllc.component_item_id;

  END IF;


  -- now check again to see if we have any kanban items with null locations
  SELECT count(*)
  INTO   l_count
  FROM   mrp_low_level_codes
  WHERE  plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
  AND    organization_id = mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
  AND    from_subinventory IS NULL
  AND    from_locator_id IS NULL
  AND    kanban_item_flag = 'Y'
  AND    assembly_item_id <> component_item_id;

end  of section - enable for R12  */

  -- if we now still have some records with null sub and locator
  -- we go after the item master for the information

  IF l_count > 0 THEN

    UPDATE mrp_low_level_codes mllc
    SET    (mllc.from_subinventory, mllc.from_locator_id) =
    	   (SELECT msi.wip_supply_subinventory,
  	   	   msi.wip_supply_locator_id
    	    FROM   mtl_system_items msi
            WHERE  msi.organization_id = mllc.organization_id
    	    AND	   msi.inventory_item_id = mllc.component_item_id)
    WHERE  mllc.plan_id =
		mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
    AND    mllc.organization_id =
                mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
    AND    mllc.from_subinventory IS NULL
    AND    mllc.from_locator_id IS NULL
    AND    mllc.kanban_item_flag = 'Y'
    AND    mllc.assembly_item_id <> mllc.component_item_id;

  END IF;

  -- now check again if we have any kanban items with incomplete from
  -- location information.  If so error out
  SELECT count(*)
  INTO   l_count
  FROM   mrp_low_level_codes
  WHERE  plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
  AND    organization_id = mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
  AND    from_subinventory IS NULL
  AND    from_locator_id IS NULL
  AND    kanban_item_flag = 'Y'
  AND    assembly_item_id <> component_item_id;

  IF l_count > 0 THEN
  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'End of CHECK_ITEM_LOCATIONS function';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

    l_count := 0;
    OPEN cur_debug;

    WHILE TRUE LOOP

      FETCH cur_debug INTO l_item;

      EXIT WHEN cur_debug%NOTFOUND;

  IF mrp_kanban_plan_pk.g_debug THEN
      FND_MESSAGE.SET_NAME ('MRP','MRP_KANBAN_ITEM_INCOMP_LOC');
      FND_MESSAGE.SET_TOKEN ('ITEMNAME', l_item);
      mrp_kanban_plan_pk.g_log_message := FND_MESSAGE.GET;
      MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

      l_count := l_count + 1;

    END LOOP;

  IF mrp_kanban_plan_pk.g_debug THEN
    FND_MESSAGE.SET_NAME ('MRP','MRP_KANBAN_INCOMP_LOC');
    FND_MESSAGE.SET_TOKEN ('NUMITEMS', to_char(l_count));
    mrp_kanban_plan_pk.g_log_message := FND_MESSAGE.GET;
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

    --set the flag to return warning here
    MRP_KANBAN_PLAN_PK.g_raise_warning := TRUE;

  END IF;

  RETURN TRUE;

--Exception handling
EXCEPTION

  WHEN OTHERS THEN
    mrp_kanban_plan_pk.g_log_message := 'CHECK_ITEM_LOCATIONS Sql Error ';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    RETURN FALSE;

END CHECK_ITEM_LOCATIONS;

-- ========================================================================
--  This function checks for presence of loops in the bill structure
--  build in the mrp_low_level_codes table and errors out if we find one
-- ========================================================================
FUNCTION CHECK_FOR_LOOPS RETURN BOOLEAN IS

l_count			number;
exc_loop_error		exception;
l_loop_found		boolean := FALSE;
l_logged_loop_err_msg	boolean := FALSE;

l_assembly_item_id	number;
l_to_subinventory	varchar2(10);
l_to_locator_id		number;
l_component_item_id	number;
l_from_subinventory	varchar2(10);
l_from_locator_id	number;
l_parent_item		varchar2(40);
l_child_item		varchar2(40);
l_parent_loc		number;
l_child_loc		number;

CURSOR cur_loop_check IS
SELECT 	parent.concatenated_segments assembly_item,
	mllc.to_subinventory,
	parent_loc.inventory_location_id to_location,
	child.concatenated_segments component_item,
	mllc.from_subinventory,
	child_loc.inventory_location_id from_location
FROM
      	mtl_item_locations parent_loc,
      	mtl_item_locations child_loc,
      	mtl_system_items_kfv parent,
	mtl_system_items_kfv child,
	mrp_low_level_codes mllc
WHERE   mllc.plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
AND     mllc.organization_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
AND     mllc.low_level_code IS NULL
AND     parent.inventory_item_id = mllc.assembly_item_id
AND     parent.organization_id = mllc.organization_id
AND     child.inventory_item_id = mllc.component_item_id
AND     child.organization_id = mllc.organization_id
AND     parent_loc.inventory_location_id (+)  = mllc.to_locator_id
AND     parent_loc.organization_id (+)  = mllc.organization_id
AND     child_loc.inventory_location_id (+)  = mllc.from_locator_id
AND     child_loc.organization_id (+)  = mllc.organization_id
ORDER BY
	assembly_item,
	component_item;

BEGIN

  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'In Check_For_Loops Procedure';
    fnd_file.put_line (fnd_file.log, mrp_kanban_plan_pk.g_log_message);
  END IF;

  -- We just go and check if we have assigned a low level code value
  -- to every entry for the current plan.  If we have at least one
  -- record without a low level code, this indicates the presence of
  -- a loop and we error out

  l_logged_loop_err_msg := FALSE; -- flag to help us log the loop check
				  -- error message only once in the log file

  OPEN cur_loop_check;

  WHILE TRUE LOOP
    FETCH cur_loop_check
    INTO  l_parent_item,
	  l_to_subinventory,
	  l_parent_loc,
	  l_child_item,
	  l_from_subinventory,
	  l_child_loc;

    EXIT WHEN cur_loop_check%NOTFOUND;

    l_loop_found := TRUE;

    IF not l_logged_loop_err_msg THEN
    IF mrp_kanban_plan_pk.g_debug THEN
      FND_MESSAGE.SET_NAME ('MRP','MRP_KANBAN_LOOP_ERROR');
      mrp_kanban_plan_pk.g_log_message := FND_MESSAGE.GET;
      MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);

      FND_MESSAGE.SET_NAME ('MRP','MRP_KANBAN_LOOP_INFO_START');
      mrp_kanban_plan_pk.g_log_message := FND_MESSAGE.GET;
      MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    END IF;

      l_logged_loop_err_msg := TRUE;

    END IF;

    -- now go ahead and log messages giving details of the loop found

  IF mrp_kanban_plan_pk.g_debug THEN
    FND_MESSAGE.SET_NAME ('MRP','MRP_KANBAN_LOOP_INFO');
    FND_MESSAGE.SET_TOKEN ('PARENT_ITEM', l_parent_item);
    FND_MESSAGE.SET_TOKEN ('PARENT_SUB', l_to_subinventory);
    FND_MESSAGE.SET_TOKEN ('PARENT_LOC', to_char(l_parent_loc));
    FND_MESSAGE.SET_TOKEN ('CHILD_ITEM', l_child_item);
    FND_MESSAGE.SET_TOKEN ('CHILD_SUB', l_from_subinventory);
    FND_MESSAGE.SET_TOKEN ('CHILD_LOC', to_char(l_child_loc));
    mrp_kanban_plan_pk.g_log_message := FND_MESSAGE.GET;
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

  END LOOP;

  CLOSE cur_loop_check;

  IF l_loop_found THEN

  IF mrp_kanban_plan_pk.g_debug THEN
    FND_MESSAGE.SET_NAME ('MRP','MRP_KANBAN_LOOP_INFO_END');
    mrp_kanban_plan_pk.g_log_message := FND_MESSAGE.GET;
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

    raise exc_loop_error;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN exc_loop_error THEN
    RETURN FALSE;

  WHEN OTHERS THEN
    mrp_kanban_plan_pk.g_log_message := 'CHECK_FOR_LOOPS Sql Error ';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    RETURN FALSE;


END CHECK_FOR_LOOPS;

-- ========================================================================
--  location combinations in mrp_low_level_codes table
-- ========================================================================

FUNCTION CALC_LOW_LEVEL_CODE RETURN BOOLEAN
IS

l_low_level_code  	number;

BEGIN

  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'In Calc_Low_Level_Codes Procedure';
    fnd_file.put_line (fnd_file.log, mrp_kanban_plan_pk.g_log_message);
  END IF;

  -- start calculating the low level codes
  -- we start by assigning a low_level_code of 1000 to the lowest level
  -- item/location combinations in the bill structure and then go up the
  -- bill structure in a loop.
  -- Note that the item for which low level code is being assigned is
  -- the component_item_id NOT the assembly_item_id

  l_low_level_code := 1000;  /* initialize */

  WHILE TRUE LOOP

    UPDATE mrp_low_level_codes mllc1
    SET	mllc1.low_level_code = l_low_level_code
    WHERE mllc1.plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
    AND   mllc1.organization_id =
		mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
    AND   mllc1.low_level_code IS NULL
    AND  	NOT EXISTS
	(SELECT /*+index(mllc2 MRP_LOW_LEVEL_CODES_N1)*/ 'Exists as parent' /* Bug 4608294 - added hint*/
	 FROM	mrp_low_level_codes mllc2
	 WHERE 		mllc2.plan_id = mllc1.plan_id
         AND		mllc2.organization_id = mllc1.organization_id
         AND		mllc2.low_level_code IS NULL
         AND		( mllc2.assembly_item_id = mllc1.component_item_id AND
            		 ((((mllc2.to_subinventory = mllc1.from_subinventory AND
	 		   nvl(mllc2.to_locator_id,-1) =
					nvl(mllc1.from_locator_id, -1) ) OR
			   mllc2.to_subinventory is NULL  ) AND
			   nvl(mllc1.kanban_item_flag,'N') = 'Y') OR
			   nvl(mllc1.kanban_item_flag,'N') = 'N'))

	);

    EXIT WHEN SQL%ROWCOUNT = 0;

    l_low_level_code := l_low_level_code - 1;

  END LOOP;  /* end while loop */

  RETURN TRUE;

-- exception handling
EXCEPTION
  WHEN OTHERS THEN
    mrp_kanban_plan_pk.g_log_message := 'CALC_LOW_LEVEL_CODE Sql Error ';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    RETURN FALSE;

END CALC_LOW_LEVEL_CODE;

-- ========================================================================
--  This function builds the where clause for the item range specified
--  The where clause is used in the first select statement while
--  snapshotting kanban items
-- ========================================================================
FUNCTION Item_Where_Clause( p_item_lo 		IN 	VARCHAR2,
                             p_item_hi 		IN 	VARCHAR2,
                             p_table_name 	IN 	VARCHAR2,
                             p_where   		OUT 	NOCOPY	VARCHAR2 )
RETURN BOOLEAN IS

   /* This function is obsoleted since we now use the same-named function in
      package 'flm_util', where we use bind variables. */

BEGIN

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END Item_Where_Clause;


-- ========================================================================
--  This function builds the where clause for the category range specified
--  The where clause is used in the first select statement while
--  snapshotting kanban items
-- ========================================================================
FUNCTION Category_Where_Clause (  p_cat_lo 	IN 	VARCHAR2,
                             	  p_cat_hi 	IN 	VARCHAR2,
                             	  p_table_name 	IN 	VARCHAR2,
                             	  p_where   	OUT 	NOCOPY	VARCHAR2 )
RETURN BOOLEAN IS

   /* This function is obsoleted since we now use the same-named function in
      package 'flm_util', where we use bind variables. */

BEGIN

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END Category_Where_Clause;

-- ========================================================================
--  This function returns 1 if the alternate designator passed corresponds
--  to the alternate_routing_designator with the highest priority, else
--  it returns -1
-- ========================================================================
FUNCTION Check_Min_Priority
( p_assembly_item_id            IN NUMBER,
  p_organization_id             IN NUMBER,
  p_line_id                     IN NUMBER,
  p_alternate_designator        IN VARCHAR2)
RETURN NUMBER IS

l_dummy          		VARCHAR2(30);
l_highest_priority              NUMBER := NULL;
l_num_routings			NUMBER := 0;

BEGIN

  IF p_assembly_item_id IS NULL OR p_organization_id IS NULL
                OR p_line_id IS NULL THEN
    IF p_alternate_designator IS NULL THEN
      RETURN 1;
    ELSE
      RETURN -1;
    END IF;
  END IF;

  -- ---------------------------------------------------
  -- Find the number of routings for this given line
  -- Also find the highest priority among the routings
  -- ---------------------------------------------------
  SELECT min(bor.priority), count(*)
  INTO   l_highest_priority, l_num_routings
  FROM   bom_operational_routings bor
  WHERE  bor.organization_id = p_organization_id
  AND    bor.assembly_item_id = p_assembly_item_id
  AND    bor.cfm_routing_flag = 1
  AND    bor.line_id  = p_line_id;

  -- ---------------------------------------------------
  -- If there no routings for this given line
  -- we return true if p_alternate_designator is the primary
  -- routing designator (ie IS NULL)
  -- ---------------------------------------------------
  IF l_num_routings = 0 THEN
    IF p_alternate_designator IS NULL THEN
      RETURN 1;
    ELSE
      RETURN -1;
    END IF;
  END IF;

  -- ---------------------------------------------------
  -- IF there are multiple routings for this given line
  -- all of which has NULL for the priority, we return
  -- false
  -- ---------------------------------------------------
  IF ((l_highest_priority IS NULL) AND (l_num_routings > 1) AND (p_alternate_designator IS NOT NULL) ) THEN
    RETURN -1;
  END IF;


  SELECT 'Condition Satisfied'
  INTO   l_dummy
  FROM   bom_operational_routings bor
  WHERE  bor.organization_id  = p_organization_id
  AND    bor.assembly_item_id  = p_assembly_item_id
  AND    bor.line_id  = p_line_id
  AND    bor.cfm_routing_flag  = 1
  AND    NVL(bor.priority,-1) = NVL(l_highest_priority,-1)
  AND    NVL(bor.alternate_routing_designator,'xx') =
             NVL(p_alternate_designator, 'xx');

  RETURN 1;

Exception
  WHEN NO_DATA_FOUND THEN
    RETURN -1;

  WHEN OTHERS THEN
    RETURN -1;

END Check_Min_Priority;

FUNCTION Check_assy_cfgitem
  (p_assembly_item_id           IN NUMBER,
   p_comp_item_id               IN NUMBER,
   p_organization_id            IN NUMBER)
RETURN NUMBER IS

/* Declare cursor for assembly item to check whether it is a configured item */

CURSOR config_item_flag(p_assemply_item_id IN NUMBER,
                        p_organization_id IN NUMBER) IS

SELECT msi.base_item_id,msi.bom_item_type
FROM   mtl_system_items msi
WHERE  msi.inventory_item_id = p_assembly_item_id
AND    msi.organization_id = p_organization_id;

config_item_flag_rec config_item_flag%ROWTYPE;

/* Declare cursor to determine if the component is a Model or an Option class */

CURSOR comp_type(p_comp_item_id IN NUMBER,
                 p_organization_id IN NUMBER) IS

SELECT msi.bom_item_type
FROM   mtl_system_items msi
WHERE  msi.inventory_item_id = p_comp_item_id
AND    msi.organization_id = p_organization_id;

comp_type_rec comp_type%ROWTYPE;


BEGIN


   OPEN config_item_flag(p_assembly_item_id,
                         p_organization_id);
   FETCH config_item_flag into config_item_flag_rec;

-- If the assembly item is not a configured item, return 1

   IF (config_item_flag_rec.base_item_id IS NULL) THEN
      RETURN 1;
   ELSE
      OPEN comp_type(p_comp_item_id ,
                     p_organization_id );
      FETCH comp_type into comp_type_rec;

     -- If assembly is a configured item and the component is Model or Option class,
     --   do not create demand for the item

      IF(comp_type_rec.bom_item_type IN (1,2)) THEN
         RETURN -1;
      ELSE
         RETURN 1;
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     RETURN -1;

END check_assy_cfgitem;

-- ========================================================================
--
--  This procedure will identify the list of items that need to be included
--  in the current kanban plan run.  User can limit thelist of items by
--  specifying an item range or item categroy.  It will select the bill
--  structure of these items and insert them into the table mrp_kanban_ll_code.
--
-- ========================================================================
FUNCTION SNAPSHOT_ITEM_LOCATIONS RETURN BOOLEAN IS

l_level_count 		number;
l_sql_stmt		varchar2(5000):= NULL;
l_item_where_clause  	varchar2(750) := NULL;
l_cat_where_clause 	varchar2(750) := NULL;
l_additional_tables     varchar2(150) := NULL;
l_additional_where	varchar2(2000):= NULL;
l_cursor		integer;
l_rows_processed 	integer;
l_quote             	varchar2(1) := '''';
l_ret_val		boolean;
l_eco_profile	boolean := TRUE;
l_error_buf       varchar2(2000);

BEGIN

  mrp_kanban_plan_pk.g_stmt_num := 30;
  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message :=
		'Entering Snapshot_Item_Locations function';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;


  l_eco_profile :=  FND_PROFILE.VALUE('FLM_KANBAN_ECO') = 'Y';

  if (l_eco_profile is null)
  then
     l_eco_profile := TRUE ;
  end if ;

  -- ------------------------------------------------------------------------
  -- if we are not replanning, then go ahead and get the initial set of items
  -- based on the parameters passed to the concurrent program
  -- ------------------------------------------------------------------------

  IF nvl(mrp_kanban_plan_pk.g_kanban_info_rec.replan_flag, 2 ) = 2 THEN

    -- now lets go ahead and build our dynamic sql statement based on
    -- the item/category range and category set parameter values

     flm_util.init_bind;

    -- include category set in the sql stmt
    l_additional_tables := ' mtl_item_categories mic, ';
    l_additional_where :=
    ' AND mic.category_set_id (+) = :b_category_set_id' ||
    ' AND mic.inventory_item_id (+) = msi.inventory_item_id' ||
    ' AND mic.organization_id (+) = msi.organization_id ';

    -- now check if item range has been specified and add the extra condition
    -- if necessary

    mrp_kanban_plan_pk.g_stmt_num := 40;
    IF mrp_kanban_plan_pk.g_debug THEN
      mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
      MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    END IF;

    IF mrp_kanban_plan_pk.g_kanban_info_rec.from_item IS NOT NULL OR
       mrp_kanban_plan_pk.g_kanban_info_rec.to_item IS NOT NULL THEN

      -- call the function that builds the item where clause
      l_ret_val := flm_util.Item_Where_Clause(
			mrp_kanban_plan_pk.g_kanban_info_rec.from_item,
		      	mrp_kanban_plan_pk.g_kanban_info_rec.to_item,
		      	'msi',
			l_item_where_clause,
			l_error_buf);

      IF NOT l_ret_val THEN
        RETURN FALSE;
      END IF;

      IF l_item_where_clause IS NOT NULL THEN
        l_additional_where := ' AND ' || l_item_where_clause ||
						l_additional_where;

        IF mrp_kanban_plan_pk.g_debug THEN
          mrp_kanban_plan_pk.g_log_message := 'Item Where Clause is : ';
          MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
         mrp_kanban_plan_pk.g_log_message := substr(l_item_where_clause,1,2000);
          MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
        END IF;
      END IF;

    END IF;

    -- similarly check if category range has been specified and add the extra
    -- condition if necessary

    mrp_kanban_plan_pk.g_stmt_num := 50;
    IF mrp_kanban_plan_pk.g_debug THEN
      mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
      MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    END IF;

    IF (mrp_kanban_plan_pk.g_kanban_info_rec.from_category IS NOT NULL OR
       mrp_kanban_plan_pk.g_kanban_info_rec.to_category IS NOT NULL) AND
       mrp_kanban_plan_pk.g_kanban_info_rec.category_set_id IS NOT NULL THEN

      l_ret_val := flm_util.Category_Where_Clause(
			mrp_kanban_plan_pk.g_kanban_info_rec.from_category,
		        mrp_kanban_plan_pk.g_kanban_info_rec.to_category,
			'mcat',
			mrp_kanban_plan_pk.g_kanban_info_rec.category_structure_id,
			l_cat_where_clause,
			l_error_buf);

      IF NOT l_ret_val THEN
        RETURN FALSE;
      END IF;

      IF l_cat_where_clause IS NOT NULL THEN
        l_additional_tables := 'mtl_categories mcat, ' || l_additional_tables;
        l_additional_where := l_additional_where || ' AND ' ||
			    ' mcat.category_id = mic.category_id AND ' ||
			    l_cat_where_clause||' ';
        IF mrp_kanban_plan_pk.g_debug THEN
          mrp_kanban_plan_pk.g_log_message := 'Category Where Clause is : ';
          MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
          mrp_kanban_plan_pk.g_log_message := substr(l_cat_where_clause,1,2000);
          MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
        END IF;
      END IF;

    END IF;

    -- now here goes the 'cool' sql statement that gets all the kanban planned
    -- items based on our constraints specified above and inserts into
    -- mrp_low_codes table

    -- Probably this sql statement needs a little explanation.  We are driving
    -- off of mrp_kanban_plans table where we get the organization id in which
    -- this plan is defined, then we hit mtl_system_items table to get the
    -- list of kanban items (here if category set or item/category range is
    -- is specified, then we impose extra where conditions and join a couple
    -- of more tables as seen in the sql statement we just built). As we get
    -- the inventory item id from mtl_system_items , we also get location
    -- information for this item by joining to bom_inventory_components.  We
    -- are not satisfied with that.  So we join bom_bill_of_materials
    -- to get the assembly_item_id and its location information which is
    -- (if its a kanban item) stored (hopefully) in mtl_kanban_pull_sequences
    -- table.  The catch here is that for a production kind of source type in
    -- in the replenishment chain we specify a line for the source.  We want
    -- this to be the line that's specified in the CFM routing with priority = 1
    -- so we end up joining bom_operational_routings table also.

    mrp_kanban_plan_pk.g_stmt_num := 60;
    IF mrp_kanban_plan_pk.g_debug THEN
      mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
      MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    END IF;

    l_sql_stmt :=
    'INSERT INTO mrp_low_level_codes ( ' ||
    'plan_id,' ||
    'organization_id,' ||
    'assembly_item_id,' ||
    'to_subinventory,' ||
    'to_locator_id,' ||
    'component_item_id,' ||
    'from_subinventory,' ||
    'from_locator_id,' ||
    'component_usage,' ||
    'component_yield,' ||
/* Updated by Liye Ma  4/30/2001
   Add two more columns, to fix bug 1745046 and 1757798. */
    'planning_factor,' ||
    'item_num,' ||
/* End of update */
/*  Modified for lot based material support. Adding query of basis_type and wip_supply_type */
    'basis_type,' ||
    'wip_supply_type,' ||
    'alternate_designator,' ||
    'kanban_item_flag,' ||
    'component_category_id,' ||
    'levels_below,' ||
    'request_id,' ||
    'program_application_id,' ||
    'program_id,' ||
    'program_update_date,' ||
    'last_updated_by,' ||
    'last_update_date,' ||
    'created_by,' ||
    'creation_date )' ||
    'SELECT  /*+ ordered */' ||
    'mkp.kanban_plan_id,' ||
    'mkp.organization_id,' ||
    'bbom.assembly_item_id,' ||
    'ps.subinventory_name,' ||
    'ps.locator_id,' ||
    'msi.inventory_item_id,' ||
    'mrp_bic.supply_subinventory,' ||
    'mrp_bic.supply_locator_id,' ||
    'mrp_bic.component_quantity,' ||
    'mrp_bic.component_yield_factor,' ||
/* Updated by Liye Ma  4/30/2001
   Add two more columns, to fix bug 1745046 and 1757798. */
    'mrp_bic.planning_factor,' ||
    'mrp_bic.item_num,' ||
/* End of Update */
/*  Modified for lot based material support. Adding query of basis_type and wip_supply_type */
/*  Basis type of 1 = WIP_CONSTANTS.ITEM_BASED_MTL */
    'nvl(mrp_bic.basis_type,1),' ||
/*  Supply type of 1 = WIP_CONSTANTS.PUSH */
    'nvl(mrp_bic.wip_supply_type,1),' ||
    'bbom.alternate_bom_designator,' ||
    l_quote || 'Y' || l_quote || ',' ||
    'mic.category_id,' ||
    '1,' ||
    'fnd_global.conc_request_id,' ||
    'fnd_global.prog_appl_id,' ||
    'fnd_global.conc_program_id,' ||
    'sysdate,' ||
    'fnd_global.user_id,' ||
    'sysdate,' ||
    'fnd_global.user_id,' ||
    'sysdate ' ||
    'FROM ' ||
    'mrp_kanban_plans mkp, ' ||
    'mtl_system_items msi, ' ||
    '( SELECT /*+ no_merge */  distinct inventory_item_id ,organization_id ' ||
    '  FROM mtl_kanban_pull_sequences ' ||
    '  WHERE kanban_plan_id = :b_PRODUCTION_KANBAN ) iv, ' ||
    'bom_inventory_components mrp_bic, ' ||
    'bom_bill_of_materials bbom, ' ||
    'mtl_kanban_pull_sequences ps, ' ||
    l_additional_tables ||
    'mtl_system_items msi2 ' ||
    'WHERE mkp.kanban_plan_id = :b_kanban_plan_id ' ||
    'AND mkp.organization_id = :b_organization_id ' ||
    'AND msi.organization_id = mkp.organization_id ' ||
    'AND iv.inventory_item_id= msi.inventory_item_id ' ||
    'AND iv.organization_id = msi.organization_id ' ||
    l_additional_where ||
    'AND mrp_bic.component_item_id = msi.inventory_item_id ' ||
    'AND nvl(mrp_bic.disable_date,:b_bom_effectivity) + 1 >= :b_bom_effectivity ' ||
    'AND mrp_bic.effectivity_date <= :b_bom_effectivity ';

	if (l_eco_profile = TRUE)
	then
		l_sql_stmt := l_sql_stmt ||
			'AND NOT EXISTS ( ' ||
			'SELECT /*+ INDEX(bic2 BOM_INVENTORY_COMPONENTS_N1) */ '||
			'NULL ' ||
			'FROM bom_inventory_components bic2 ' ||
			'WHERE  bic2.bill_sequence_id = mrp_bic.bill_sequence_id ' ||
			'AND    bic2.component_item_id = mrp_bic.component_item_id ' ||
			'AND    (decode(bic2.implementation_date, null, ' ||
			'bic2.old_component_sequence_id, ' ||
			'bic2.component_sequence_id) = ' ||
			'decode(mrp_bic.implementation_date, null, ' ||
			'mrp_bic.old_component_sequence_id, ' ||
			'mrp_bic.component_sequence_id) ' ||
			'OR bic2.operation_seq_num = mrp_bic.operation_seq_num) ' ||
			'AND    bic2.effectivity_date <= :b_bom_effectivity ' ||
			'AND    bic2.effectivity_date > mrp_bic.effectivity_date ' ||
			'AND    (bic2.implementation_date is not null OR ' ||
			'(bic2.implementation_date is null AND EXISTS ' ||
			'(SELECT NULL ' ||
			'FROM   eng_revised_items eri ' ||
			'WHERE  bic2.revised_item_sequence_id = ' ||
			'eri.revised_item_sequence_id ' ||
			'AND    eri.mrp_active = 1 )))) ' ||
			'AND   (mrp_bic.implementation_date is not null OR ' ||
			'(mrp_bic.implementation_date is null AND EXISTS ' ||
			'(SELECT NULL ' ||
			'FROM   eng_revised_items eri ' ||
			'WHERE  mrp_bic.revised_item_sequence_id = ' ||
			'eri.revised_item_sequence_id '  ||
			'AND eri.mrp_active = 1 ))) ';
	end if;
	l_sql_stmt := l_sql_stmt ||
    'AND bbom.organization_id = msi.organization_id ' ||
    'AND bbom.common_bill_sequence_id = mrp_bic.bill_sequence_id ' ||
    'AND ps.kanban_plan_id (+) = :b_PRODUCTION_KANBAN ' ||
    'AND ps.organization_id (+) = bbom.organization_id ' ||
    'AND ps.inventory_item_id (+) = bbom.assembly_item_id ' ||
    'AND msi2.inventory_item_id = bbom.assembly_item_id ' ||
    'AND msi2.organization_id = bbom.organization_id ' ||
    'AND msi2.planning_make_buy_code = 1 ' ||
    'AND ps.source_type (+) = :b_PRODUCTION_SOURCE_TYPE ';
/* Updated by Liye Ma. 1/23/2001
   This check_min_priority serves no purposes...
   ||
    'AND 1 =  MRP_KANBAN_SNAPSHOT_PK.Check_Min_Priority ( ' ||
    				'ps.inventory_item_id, ' ||
    				'ps.organization_id, ' ||
    				'ps.wip_line_id, ' ||
    				'bbom.alternate_bom_designator ) '; */

    -- get a cursor handle
    l_cursor := dbms_sql.open_cursor;

    -- parse the sql statement that we just built
    dbms_sql.parse (l_cursor, l_sql_stmt, dbms_sql.native);

    -- put values into all the bind variables
    flm_util.add_bind (':b_kanban_plan_id',
  			mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id);
    flm_util.add_bind (':b_organization_id',
  			mrp_kanban_plan_pk.g_kanban_info_rec.organization_id);
    flm_util.add_bind (':b_bom_effectivity',
  			mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity);
    flm_util.add_bind (':b_PRODUCTION_KANBAN',
  			mrp_kanban_plan_pk.G_PRODUCTION_KANBAN);
    flm_util.add_bind (':b_PRODUCTION_SOURCE_TYPE',
  			mrp_kanban_plan_pk.G_PRODUCTION_SOURCE_TYPE);
    flm_util.add_bind (':b_category_set_id',
  			mrp_kanban_plan_pk.g_kanban_info_rec.category_set_id);
    flm_util.do_binds(l_cursor);

    -- now execute the sql stmt
    l_rows_processed := dbms_sql.execute(l_cursor);

    -- close the cursor
    dbms_sql.close_cursor (l_cursor);

  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message :=
  		'----------------------------------------------';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message :=
  		'Successfully executed the Dynamic Sql Statement';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message := 'Inserted ' ||
		to_char(l_rows_processed) || ' into mrp_low_level_codes table';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

  END IF; -- so we basically did all the above only if we are not replanning

  ---------------------------------------------------------------------------
  -- Now go ahead and get all the other items that are required for planning
  -- from the bill structure
  -- ------------------------------------------------------------------------

  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

  l_level_count := 1;

  WHILE TRUE LOOP

  -- ------------------------------------------------------------------------
  -- Select parent of the current level items and insert into
  -- mrp_low_level_codes table if not already present. So basically once
  -- we got our initial list of items into mrp_low_level_codes, it becomes
  -- driver for our select statement for insert. The rest of the logic is
  -- similar to the above built sql statement. Notice how we are using
  -- the levels_below column to walk our way up the bill
  -- ------------------------------------------------------------------------

	if l_eco_profile = FALSE  then

		INSERT INTO mrp_low_level_codes (
		plan_id,
		organization_id,
		assembly_item_id,
		to_subinventory,
		to_locator_id,
		component_item_id,
		from_subinventory,
		from_locator_id,
		component_usage,
		component_yield,
/* Updated by Liye Ma  4/30/2001
   Add two more columns, to fix bug 1745046 and 1757798. */
                planning_factor,
		item_num,
/* End of Update */
/*  Modified for lot based material support. Adding query of basis_type and wip_supply_type */
                basis_type,
		wip_supply_type,
		alternate_designator,
		levels_below,
		kanban_item_flag,
		component_category_id,
			request_id,
			program_application_id,
			program_id,
			program_update_date,
			last_updated_by,
			last_update_date,
			created_by,
			creation_date)
		SELECT /*+
                    LEADING(MLLC)
                    USE_NL(MLLC MRP_BIC BBOM MIC PS)
                  */ DISTINCT
		mllc.plan_id,
		mllc.organization_id,
		bbom.assembly_item_id,
		ps.subinventory_name,
		ps.locator_id,
		mrp_bic.component_item_id,
		mrp_bic.supply_subinventory,
		mrp_bic.supply_locator_id,
		mrp_bic.component_quantity,
		mrp_bic.component_yield_factor,
/* Updated by Liye Ma  4/30/2001
   Add two more columns, to fix bug 1745046 and 1757798. */
                mrp_bic.planning_factor,
		mrp_bic.item_num,
/* End of Update */
/*  Modified for lot based material support. Adding query of basis_type and wip_supply_type */
                nvl(mrp_bic.basis_type,WIP_CONSTANTS.ITEM_BASED_MTL),
		nvl(mrp_bic.wip_supply_type,WIP_CONSTANTS.PUSH),
		bbom.alternate_bom_designator,
		l_level_count + 1,
		NULL,		-- set it to NULL and update it next stmt
		mic.category_id,
			fnd_global.conc_request_id,
			fnd_global.prog_appl_id,
			fnd_global.conc_program_id,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			sysdate
		FROM
		mtl_kanban_pull_sequences ps,
		bom_bill_of_materials bbom,
		mtl_item_categories mic,
		bom_inventory_components mrp_bic,
		mrp_low_level_codes mllc
		WHERE	mllc.plan_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
		AND	mllc.organization_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
		AND		mllc.levels_below = l_level_count
		AND		mrp_bic.component_item_id = mllc.assembly_item_id
		AND		(nvl(mrp_bic.disable_date,
		mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity)) +1 >=
			mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
		AND         mrp_bic.effectivity_date <=
			mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
		AND	bbom.common_bill_sequence_id = mrp_bic.bill_sequence_id
		AND     bbom.organization_id = mllc.organization_id
		AND    	ps.kanban_plan_id (+) =
		decode(mrp_kanban_plan_pk.g_kanban_info_rec.replan_flag,
		2, mrp_kanban_plan_pk.G_PRODUCTION_KANBAN,
		1, mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id,
		mrp_kanban_plan_pk.G_PRODUCTION_KANBAN)
		AND       	ps.organization_id (+) = bbom.organization_id
		AND       	ps.inventory_item_id (+) = bbom.assembly_item_id
		AND       	ps.source_type (+) = 4 /* KANBAN_PRODUCTION */
/* Fix bug 2090054
		AND         1 =  Check_Min_Priority (
	        ps.inventory_item_id,
	        ps.organization_id,
	        ps.wip_line_id,
		bbom.alternate_bom_designator)
*/
		AND    	mic.organization_id (+)  =
		mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
		AND    	mic.inventory_item_id (+) = mllc.assembly_item_id
		AND    	mic.category_set_id (+) =
			mrp_kanban_plan_pk.g_kanban_info_rec.category_set_id
		/*  Avoid re-selecting items already in mrp_low_level_codes */
		AND	 NOT EXISTS
		( SELECT 'Exists'
		 FROM 	mrp_low_level_codes mllc2
		 WHERE  mllc2.plan_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
		 AND	mllc2.organization_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
		 AND    mllc2.component_item_id = mrp_bic.component_item_id )
         AND    EXISTS(
            SELECT  /*+no_unnest*/ 1
             FROM mtl_system_items msi
            WHERE msi.organization_id = bbom.organization_id
              AND msi.inventory_item_id = bbom.assembly_item_id
              AND msi.planning_make_buy_code = 1);
	else
		INSERT INTO mrp_low_level_codes (
		plan_id,
		organization_id,
		assembly_item_id,
		to_subinventory,
		to_locator_id,
		component_item_id,
		from_subinventory,
		from_locator_id,
		component_usage,
		component_yield,
/* Updated by Liye Ma  4/30/2001
   Add two more columns, to fix bug 1745046 and 1757798. */
                planning_factor,
		item_num,
/* End of Update */
/*  Modified for lot based material support. Adding query of basis_type and wip_supply_type */
                basis_type,
		wip_supply_type,
		alternate_designator,
		levels_below,
		kanban_item_flag,
		component_category_id,
			request_id,
			program_application_id,
			program_id,
			program_update_date,
			last_updated_by,
			last_update_date,
			created_by,
			creation_date)
		SELECT /*+ INDEX(PS MTL_KANBAN_PULL_SEQUENCES_N1) */ DISTINCT
		mllc.plan_id,
		mllc.organization_id,
		bbom.assembly_item_id,
		ps.subinventory_name,
		ps.locator_id,
		mrp_bic.component_item_id,
		mrp_bic.supply_subinventory,
		mrp_bic.supply_locator_id,
		mrp_bic.component_quantity,
		mrp_bic.component_yield_factor,
/* Updated by Liye Ma  4/30/2001
   Add two more columns, to fix bug 1745046 and 1757798. */
                mrp_bic.planning_factor,
		mrp_bic.item_num,
/* End of Update */
/*  Modified for lot based material support. Adding query of basis_type and wip_supply_type */
                nvl(mrp_bic.basis_type,WIP_CONSTANTS.ITEM_BASED_MTL),
		nvl(mrp_bic.wip_supply_type,WIP_CONSTANTS.PUSH),
		bbom.alternate_bom_designator,
		l_level_count + 1,
		NULL,		-- set it to NULL and update it next stmt
		mic.category_id,
			fnd_global.conc_request_id,
			fnd_global.prog_appl_id,
			fnd_global.conc_program_id,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			sysdate
		FROM
		mtl_kanban_pull_sequences ps,
		bom_bill_of_materials bbom,
			mtl_item_categories mic,
		bom_inventory_components mrp_bic,
		mrp_low_level_codes mllc
		WHERE	mllc.plan_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
		AND	mllc.organization_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
		AND		mllc.levels_below = l_level_count
		AND		mrp_bic.component_item_id = mllc.assembly_item_id
		AND		(nvl(mrp_bic.disable_date,
		mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity)) +1 >=
		mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
		AND         mrp_bic.effectivity_date <=
			mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
		AND         NOT EXISTS (
		SELECT /*+ INDEX(bic2 BOM_INVENTORY_COMPONENTS_N1) */
		NULL
		FROM   bom_inventory_components bic2
		WHERE  bic2.bill_sequence_id = mrp_bic.bill_sequence_id
		AND    bic2.component_item_id = mrp_bic.component_item_id
		AND    (decode(bic2.implementation_date, null,
	        bic2.old_component_sequence_id,
	        bic2.component_sequence_id) =
		decode(mrp_bic.implementation_date, null,
		mrp_bic.old_component_sequence_id,
		mrp_bic.component_sequence_id)
		OR bic2.operation_seq_num = mrp_bic.operation_seq_num)
		AND    bic2.effectivity_date <=
		mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
		AND    bic2.effectivity_date > mrp_bic.effectivity_date
		AND    (bic2.implementation_date is not null OR
		(bic2.implementation_date is null AND EXISTS
		(SELECT NULL
		  FROM   eng_revised_items eri
		  WHERE  bic2.revised_item_sequence_id =
		  eri.revised_item_sequence_id
		  AND    eri.mrp_active = 1 ))))
		AND 	(mrp_bic.implementation_date is not null OR
		(mrp_bic.implementation_date is null AND EXISTS
		(SELECT NULL
		 FROM   eng_revised_items eri
		 WHERE  mrp_bic.revised_item_sequence_id =
			eri.revised_item_sequence_id
		 AND    eri.mrp_active = 1 )))
		 AND	bbom.common_bill_sequence_id = mrp_bic.bill_sequence_id
		AND     bbom.organization_id = mllc.organization_id
		AND     ps.kanban_plan_id (+) =
			decode(mrp_kanban_plan_pk.g_kanban_info_rec.replan_flag,
		        2, mrp_kanban_plan_pk.G_PRODUCTION_KANBAN,
			1, mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id,
			mrp_kanban_plan_pk.G_PRODUCTION_KANBAN)
		AND     ps.organization_id (+) = bbom.organization_id
		AND     ps.inventory_item_id (+) = bbom.assembly_item_id
		AND     ps.source_type (+) = 4 /* KANBAN_PRODUCTION */
/* Fix bug 2090054
		AND     1 =  Check_Min_Priority (
			ps.inventory_item_id,
			ps.organization_id,
			ps.wip_line_id,
			bbom.alternate_bom_designator)
*/
		AND     mic.organization_id (+)  =
			mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
		AND     mic.inventory_item_id (+) = mllc.assembly_item_id
		AND     mic.category_set_id (+) =
			mrp_kanban_plan_pk.g_kanban_info_rec.category_set_id
		/*  Avoid re-selecting items already in mrp_low_level_codes */
		AND	 NOT EXISTS
		( SELECT 'Exists'
		 FROM 	mrp_low_level_codes mllc2
		 WHERE  mllc2.plan_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
		 AND	mllc2.organization_id =
			mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
		 AND    mllc2.component_item_id = mrp_bic.component_item_id )
         AND    EXISTS(
            SELECT  /*+no_unnest*/ 1
             FROM mtl_system_items msi
            WHERE msi.organization_id = bbom.organization_id
              AND msi.inventory_item_id = bbom.assembly_item_id
              AND msi.planning_make_buy_code = 1);

	end if;


    EXIT WHEN SQL%ROWCOUNT = 0;

    l_level_count := l_level_count + 1;

  END LOOP;


  -- The purpose of this statment is to improve the performance
  -- The above insert stmt has performance problems and
  -- to avoid two outer join in mtl_kanban_pull_sequences
  -- we decide to break it down.
  UPDATE mrp_low_level_codes mllc
  SET (mllc.kanban_item_flag) =
      (select nvl(max(decode(kbn_items.release_kanban_flag, 1, 'Y', 'Y')), 'N')
       from   mtl_kanban_pull_sequences kbn_items
       where kbn_items.kanban_plan_id =
	     mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
       and   kbn_items.organization_id =
	     mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
       and   kbn_items.inventory_item_id = mllc.assembly_item_id)
  WHERE mllc.plan_id =
          mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
  AND mllc.organization_id =
          mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
  AND mllc.kanban_item_flag is null;


  mrp_kanban_plan_pk.g_stmt_num := 80;
  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

  -- now update the mrp_low_level_codes table with operation_yield
  -- and net_planning_percent from the bom_operation_sequences table.
  -- We did this separately after inserting all that we wanted to
  -- insert only to make the code a little cleaner.  We tried doing
  -- this in the above sql statement itself but obviously if got
  -- kinda ugly trying to achieve it.

  -- bom_inventory_components and bom_operation_sequences are linked
  -- by the operation sequence number and for a particular operation
  -- sequence we have the net_planning_percent and the operation_yield
  -- (actually the reverse_cumulative_yield column) stored in
  -- bom_operation_sequences table

  UPDATE  mrp_low_level_codes mllc
  SET	  (mllc.operation_yield,mllc.net_planning_percent) =
	  (SELECT min(bos.reverse_cumulative_yield),
	 	  min(bos.net_planning_percent)
	   FROM	  bom_operation_sequences bos,
		  bom_operational_routings bor,
		  bom_inventory_components mrp_bic,
		  bom_bill_of_materials bbom
	   WHERE  bbom.assembly_item_id = mllc.assembly_item_id
	   AND	  bbom.organization_id = mllc.organization_id
	   AND	  nvl(bbom.alternate_bom_designator, 'xxx') =
               	  nvl(mllc.alternate_designator, 'xxx')
	   AND	  mrp_bic.bill_sequence_id = bbom.common_bill_sequence_id
	   AND	  mrp_bic.component_item_id = mllc.component_item_id
    	   AND	  (nvl(mrp_bic.disable_date,
		   mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity) +1) >=
		   mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
    	   AND     mrp_bic.effectivity_date <=
		   mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
      	   AND    NOT EXISTS (
               	  SELECT NULL
                  FROM   bom_inventory_components bic2
                  WHERE  bic2.bill_sequence_id = mrp_bic.bill_sequence_id
                  AND    bic2.component_item_id = mrp_bic.component_item_id
                  AND    (decode(bic2.implementation_date, null,
                               bic2.old_component_sequence_id,
                               bic2.component_sequence_id) =
                       decode(mrp_bic.implementation_date, null,
                              mrp_bic.old_component_sequence_id,
                              mrp_bic.component_sequence_id)
                       OR bic2.operation_seq_num = mrp_bic.operation_seq_num)
                  AND    bic2.effectivity_date <=
			mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
                  AND    bic2.effectivity_date > mrp_bic.effectivity_date
                  AND    (bic2.implementation_date is not null OR
                         (bic2.implementation_date is null AND EXISTS
                         (SELECT NULL
                          FROM   eng_revised_items eri
                          WHERE  bic2.revised_item_sequence_id =
                                                eri.revised_item_sequence_id
                          AND    eri.mrp_active = 1 ))))
           AND    (mrp_bic.implementation_date is not null OR
                         (mrp_bic.implementation_date is null AND EXISTS
                         (SELECT NULL
                          FROM   eng_revised_items eri
                          WHERE  mrp_bic.revised_item_sequence_id =
                                                eri.revised_item_sequence_id
                          AND    eri.mrp_active = 1 )))
	   AND	  bor.organization_id = bbom.organization_id
	   AND	  bor.assembly_item_id = bbom.assembly_item_id
	   AND	  nvl(bor.alternate_routing_designator, 'xxx') =
               	  nvl(bbom.alternate_bom_designator, 'xxx')
	   AND	  bos.routing_sequence_id = bor.routing_sequence_id
	   AND	  bos.operation_seq_num = mrp_bic.operation_seq_num
	   AND	  nvl(bos.operation_type, 1) = 1
	   AND	  nvl(bos.disable_date,
		    mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity) + 1
			>= mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity
	   AND	  bos.effectivity_date <=
		  mrp_kanban_plan_pk.g_kanban_info_rec.bom_effectivity)
  WHERE	   mllc.plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id;

  mrp_kanban_plan_pk.g_stmt_num := 90;


  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message := 'Updated mrp_low_level_codes ' ||
			'with net planning percent and yield information';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;


  -- ------------------------------------------------------------------------
  -- Now insert the top level assembly item
  -- Since the top level assembly item does not have a parent, it would not
  -- gotten into mrp_low_level_codes table as a component item (which is
  -- what we use to plan).  So, we create a dummy parent of -1 for him and
  -- insert him into the mrp_low_level_codes table
  -- ------------------------------------------------------------------------

    INSERT INTO mrp_low_level_codes (
	plan_id,
	organization_id,
	assembly_item_id,
	component_item_id,
        from_subinventory,
	from_locator_id,
	levels_below,
	kanban_item_flag,
	component_category_id,
    	request_id,
    	program_application_id,
    	program_id,
    	program_update_date,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date )
    SELECT DISTINCT
	mllc1.plan_id,
	mllc1.organization_id,
	-1,
	mllc1.assembly_item_id,
	mllc1.to_subinventory,
	mllc1.to_locator_id,
	l_level_count + 1,
	decode(kbn_items.release_kanban_flag, 1, 'Y', 2, 'Y', 'N'),
	mic.category_id,
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate
    FROM
 	mtl_item_categories mic,
 	mtl_kanban_pull_sequences kbn_items,
	mrp_low_level_codes mllc1
    WHERE
    	mllc1.plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id AND
    	mllc1.organization_id =
	   mrp_kanban_plan_pk.g_kanban_info_rec.organization_id AND
	kbn_items.inventory_item_id (+) =
				mrp_kanban_plan_pk.G_PRODUCTION_KANBAN AND
	kbn_items.inventory_item_id (+) = mllc1.assembly_item_id AND
	kbn_items.organization_id (+) = mllc1.organization_id AND
	mic.inventory_item_id (+) = mllc1.assembly_item_id AND
	mic.organization_id (+) = mllc1.organization_id AND
	mic.category_set_id (+) =
		mrp_kanban_plan_pk.g_kanban_info_rec.category_set_id AND
    	--select only the assembly items that do not exist as components
     	NOT EXISTS
	(SELECT 'Exists'
	 FROM 	mrp_low_level_codes mllc2
	 WHERE  mllc2.plan_id = mllc1.plan_id AND
	 	mllc2.organization_id = mllc1.organization_id AND
	     	mllc2.component_item_id = mllc1.assembly_item_id );



  mrp_kanban_plan_pk.g_stmt_num := 100;
  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

  -- ------------------------------------------------------------------------
  -- Now find information in mtl_kanban_pull_sequences about inter-org and
  -- intra-org transfers and insert into mrp_low_level_codes
  -- Note here that replan flag drives whether I pull infomation from the
  -- production kanban plan or the current kanban plan itself.  Replan_flag
  -- = 2 is not a replan and if its 1 then its a replan run.
  -- We are not including supplier kind of replenishment here because we
  -- can afford to not calculate the low_level_code for a supplier source type
  -- (since we know that's the end point in the chain, we can stop one point
  -- before that).
  -- ------------------------------------------------------------------------

  INSERT INTO mrp_low_level_codes (
        plan_id,
        organization_id,
        assembly_item_id,
        to_subinventory,
        to_locator_id,
        component_item_id,
        from_subinventory,
        from_locator_id,
        component_usage,
        component_yield,
	supply_source_type,
	replenishment_lead_time,
	kanban_item_flag,
	component_category_id,
    	request_id,
    	program_application_id,
    	program_id,
    	program_update_date,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date )
  SELECT DISTINCT
	mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id,
	ps.organization_id,
	ps.inventory_item_id,
	ps.subinventory_name,
	ps.locator_id,
	ps.inventory_item_id,
	ps.source_subinventory,
	ps.source_locator_id,
	1,
	1,
	ps.source_type,
	ps.replenishment_lead_time,
	'Y',
	mllc.component_category_id,
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate
  FROM  mtl_kanban_pull_sequences ps,
	mrp_low_level_codes mllc
  WHERE	ps.source_type = 3 -- only intra org replenishments
  AND   ps.kanban_plan_id =
		decode(mrp_kanban_plan_pk.g_kanban_info_rec.replan_flag,
                2, mrp_kanban_plan_pk.G_PRODUCTION_KANBAN,
                1, mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id,
                mrp_kanban_plan_pk.G_PRODUCTION_KANBAN)
  AND	ps.organization_id = mllc.organization_id
  AND	ps.inventory_item_id = mllc.component_item_id
  AND	mllc.organization_id =
		mrp_kanban_plan_pk.g_kanban_info_rec.organization_id
  AND	mllc.plan_id = mrp_kanban_plan_pk.g_kanban_info_rec.kanban_plan_id
  AND   mllc.kanban_item_flag = 'Y';


  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message :=
		'Completed inserting into mrp_low_level_codes table';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;
  mrp_kanban_plan_pk.g_stmt_num := 110;
  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

  -- call the check_item_locations procedure to ensure that
  -- kanban items have the from-locations populated in the
  -- mrp_low_level_codes table.  If the kanban items do not have
  -- the from locations populated, we can run into issues while
  -- calculating low_level_codes

  IF NOT Check_Item_Locations THEN
    RETURN FALSE;
  END IF;

  mrp_kanban_plan_pk.g_stmt_num := 130;
  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : '
				|| to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

  -- now we are ready for our low level code calculation
  -- so call that procedure

  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Calling CALC_LOW_LEVEL_code function';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;

  IF NOT Calc_Low_Level_code THEN
    RETURN FALSE;
  END IF;

  mrp_kanban_plan_pk.g_stmt_num := 140;
  IF mrp_kanban_plan_pk.g_debug THEN
    mrp_kanban_plan_pk.g_log_message := 'Debug Statement Number : ' ||
				   to_char (mrp_kanban_plan_pk.g_stmt_num);
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message := 'Calling CHECK_FOR_LOOPS function';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
  END IF;


  -- after low level code calculation, if we have component items
  -- in mrp_low_level_code table with no low level code assigned
  -- then we have loop in the bill. Call the procedure to check this

  IF NOT Check_For_Loops THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN OTHERS THEN
    mrp_kanban_plan_pk.g_log_message := 'SNAPSHOT_ITEM_LOCATIONS Sql Error ';
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    mrp_kanban_plan_pk.g_log_message := sqlerrm;
    MRP_UTIL.MRP_LOG (mrp_kanban_plan_pk.g_log_message);
    RETURN FALSE;

END SNAPSHOT_ITEM_LOCATIONS;


END MRP_KANBAN_SNAPSHOT_PK;


/
