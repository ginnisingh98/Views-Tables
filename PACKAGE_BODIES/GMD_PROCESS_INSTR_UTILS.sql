--------------------------------------------------------
--  DDL for Package Body GMD_PROCESS_INSTR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_PROCESS_INSTR_UTILS" AS
/* $Header: GMDPIUTB.pls 120.9 2006/07/12 18:08:07 txdaniel noship $ */

/* Cursor Definitions */

/* Cursor to get the routing_id attached with the recipe */
CURSOR Get_recipe_details (v_recipe_id NUMBER) IS
  SELECT r.routing_id, r.formula_id
    FROM gmd_recipes_b r
   WHERE r.recipe_id = v_recipe_id;

/* Cursor to fetch formula item details */
CURSOR Get_formula_details (v_formula_id NUMBER) IS
  SELECT f.formulaline_id, f.line_no, f.line_type, f.inventory_item_id, i.concatenated_segments
    FROM fm_matl_dtl f, mtl_system_items_kfv i
   WHERE f.formula_id = v_formula_id
     AND f.inventory_item_id = i.inventory_item_id
     AND f.organization_id = i.organization_id
ORDER BY f.line_type, f.line_no;

/* Cursor to fetch activity details for an operation */
CURSOR Get_activity_details (v_oprn_id NUMBER) IS
  SELECT oprn_line_id, activity
    FROM gmd_operation_activities
   WHERE oprn_id = v_oprn_id
ORDER BY oprn_line_id;

/* Cursor to fetch routing details */
CURSOR Get_routing_details (v_routing_id NUMBER) IS
  SELECT r.routingstep_id, r.routingstep_no, r.oprn_id, o.oprn_no
    FROM fm_rout_dtl r, gmd_operations_b o
   WHERE r.routing_id = v_routing_id
     AND r.oprn_id = o.oprn_id
ORDER BY r.routingstep_no;

/* Cursor to fetch resource details for an activity */
CURSOR Get_resource_details (v_oprn_line_id NUMBER) IS
  SELECT oprn_line_id, resources
    FROM gmd_operation_resources
   WHERE oprn_line_id = v_oprn_line_id
ORDER BY resources;


/*-------------------------------------------------------------------
-- NAME
--    Build_Array
--
-- SYNOPSIS
--    Procedure Build_Array
--
-- DESCRIPTION
--     This procedure is used to build the array to pass to GMO
--
-- HISTORY
--     B5305793 - Added this procedure to fix the issue reported.
--------------------------------------------------------------------*/

PROCEDURE Build_Array  (
				p_entity_name		 IN            VARCHAR2	,
				p_entity_id	         IN            NUMBER		,
                                x_name_array             OUT    NOCOPY GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                                x_key_array              OUT    NOCOPY GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
			        x_return_status          OUT    NOCOPY VARCHAR2) IS

l_instruction_type	VARCHAR2(10);
l_proc_instr_id		NUMBER;

l_rout_dets		GMD_RECIPE_FETCH_PUB.routing_step_tbl;
l_rout_id		FM_ROUT_HDR.ROUTING_ID%TYPE;
l_form_id		FM_FORM_MST.FORMULA_ID%TYPE;
l_oprn_id		NUMBER;
l_oprn_no		VARCHAR2(200);
l_msg_cnt		NUMBER;
l_msg_data		VARCHAR2(2000);
l_return_code		VARCHAR2(20);
l_status		VARCHAR2(30);
l_entity_name		VARCHAR2(200);
l_count			NUMBER;
l_line_id		NUMBER;
l_line_no		NUMBER;
l_line_type		NUMBER;
i			NUMBER;
j			NUMBER;

BEGIN

  /* Default the process type to 'PROCESS' when called from NPD */
  l_instruction_type := 'PROCESS';


  IF p_entity_name = 'FORMULA' THEN

    /* Set the Source entity name and key for Formula*/
    i := 1;
    FOR l_rec IN Get_formula_details(p_entity_id)
    LOOP
      X_name_array(i)	:= 'MATERIAL';
      X_key_array(i)	:= TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
      i := i + 1;
    END LOOP;

  ELSIF p_entity_name = 'OPERATION' THEN

    /* Set the Source entity name and key for Operation*/
    i := 1;
    X_name_array(i)	:= 'OPERATION';
    X_key_array(i)	:= p_entity_id;

    -- Get all activity details for the operation
    FOR l_rec IN Get_activity_details(p_entity_id)
    LOOP
      i := i + 1;
      X_name_array(i)	:= 'ACTIVITY';
      X_key_array(i)	:= TO_CHAR(l_rec.oprn_line_id);

      -- Get all resource details for the activity
      FOR l_rec_rsrc IN Get_resource_details(l_rec.oprn_line_id)
      LOOP
	i := i + 1;
	X_name_array(i)	:= 'RESOURCE';
	X_key_array(i)	:= TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
      END LOOP;
    END LOOP;
  ELSIF p_entity_name = 'ROUTING' THEN
    /* Set the Source entity name and key for Routing */
    i := 1;
    FOR l_rec IN Get_routing_details(p_entity_id)
    LOOP
      X_name_array(i)	:= 'OPERATION';
      X_key_array(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec.oprn_id);

      -- Get all activity details for the operation
      FOR l_rec_actv IN Get_activity_details(l_rec.oprn_id)
      LOOP
	i := i + 1;
	X_name_array(i)	:= 'ACTIVITY';
	X_key_array(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

	-- Get all resource details for the activity
	FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
	LOOP
	  i := i + 1;
	  X_name_array(i)	:= 'RESOURCE';
	  X_key_array(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
	END LOOP;
      END LOOP;
      i := i + 1;
    END LOOP;
  END IF;
END Build_Array;

/*-------------------------------------------------------------------
-- NAME
--    Copy_Process_Instructions
--
-- SYNOPSIS
--    Procedure Copy_Process_Instructions
--
-- DESCRIPTION
--     This procedure is called to copy the process instructions from
-- one entity to another
--
-- HISTORY
--     B5305793 - Added this procedure to fix the issue reported.
--------------------------------------------------------------------*/

PROCEDURE Copy_Process_Instructions  (
                                p_source_name_array      IN     GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                                p_source_key_array       IN     GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                                p_target_name_array      IN     GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                                p_target_key_array       IN     GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
			        x_return_status          OUT	NOCOPY VARCHAR2) IS
  l_proc_instr_id		NUMBER(15);
  l_msg_count                   NUMBER(5);
  l_msg_data                    VARCHAR2(2000);
BEGIN

  /* Call the GMO Create defn from defn API */
  FOR j IN 1..p_source_name_array.COUNT
  LOOP
    GMO_INSTRUCTION_GRP.CREATE_DEFN_FROM_DEFN
	   (
	      P_API_VERSION             =>      1.0				,
	      P_INIT_MSG_LIST           =>	FND_API.G_FALSE			,
	      P_VALIDATION_LEVEL        =>	FND_API.G_VALID_LEVEL_FULL	,
	      P_SOURCE_ENTITY_NAME	=>	p_source_name_array(j)		,
	      P_SOURCE_ENTITY_KEY	=>	p_source_key_array(j)		,
	      P_TARGET_ENTITY_NAME	=>	p_target_name_array(j)		,
	      P_TARGET_ENTITY_KEY	=>	p_target_key_array(j)		,
	      P_INSTRUCTION_TYPE	=>	'PROCESS'		        ,
	      X_INSTRUCTION_SET_ID	=>	l_proc_instr_id			,
	      X_RETURN_STATUS		=>	x_return_status			,
	      X_MSG_COUNT		=>	l_msg_count                     ,
	      X_MSG_DATA		=>	l_msg_data
	   );

  END LOOP;

END Copy_Process_Instructions;


/*-------------------------------------------------------------------
-- NAME
--    COPY_PROCESS_INSTR
--
-- SYNOPSIS
--    Procedure COPY_PROCESS_INSTR
--
-- DESCRIPTION
--     This procedure is called to copy the process instructions from
-- one entity to another
--
-- HISTORY
--    Sriram    7/20/2005     Created for GMD-GMO Integration Build
--------------------------------------------------------------------*/

PROCEDURE COPY_PROCESS_INSTR  (
				p_entity_name		 IN	VARCHAR2	,
				p_from_entity_id	 IN	NUMBER		,
			        p_to_entity_id		 IN	NUMBER		,
			        x_return_status          OUT	NOCOPY VARCHAR2	,
			        x_msg_count              OUT	NOCOPY NUMBER	,
				x_msg_data               OUT	NOCOPY VARCHAR2	) IS

l_source_entity_name	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_source_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_target_entity_name	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_target_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_instruction_type	VARCHAR2(10);
l_proc_instr_id		NUMBER;

l_old_rout_dets		GMD_RECIPE_FETCH_PUB.routing_step_tbl;
l_new_rout_dets		GMD_RECIPE_FETCH_PUB.routing_step_tbl;
l_old_rout_id		FM_ROUT_HDR.ROUTING_ID%TYPE;
l_new_rout_id		FM_ROUT_HDR.ROUTING_ID%TYPE;
l_old_form_id		FM_FORM_MST.FORMULA_ID%TYPE;
l_new_form_id		FM_FORM_MST.FORMULA_ID%TYPE;
l_oprn_id		NUMBER;
l_oprn_no		VARCHAR2(200);
l_msg_cnt		NUMBER;
l_msg_data		VARCHAR2(2000);
l_return_code		VARCHAR2(20);
l_status		VARCHAR2(30);
l_entity_name		VARCHAR2(200);
l_count			NUMBER;
l_line_id		NUMBER;
l_line_no		NUMBER;
l_line_type		NUMBER;
i			NUMBER;
j			NUMBER;

BEGIN

/* Default the process type to 'PROCESS' when called from NPD */
l_instruction_type := 'PROCESS';

IF p_entity_name = 'RECIPE' THEN

	/* Get the old routing and formula id */
	OPEN Get_recipe_details(p_from_entity_id);
	FETCH Get_recipe_details INTO l_old_rout_id, l_old_form_id;
	CLOSE Get_recipe_details;

	/* Get the new routing and formula id */
	OPEN Get_recipe_details(p_to_entity_id);
	FETCH Get_recipe_details INTO l_new_rout_id, l_new_form_id;
	CLOSE Get_recipe_details;

	/* Set the Source entity name and key for Recipe*/
	i := 1;
	IF l_old_rout_id = l_new_rout_id THEN
	GMD_RECIPE_FETCH_PUB.get_routing_step_details(
		p_api_version           =>	1.0		,
		p_init_msg_list         =>	'F'		,
		p_routing_id            =>      l_old_rout_id	,
		x_return_status         =>      l_status	,
		x_msg_count             =>      l_msg_cnt	,
		x_msg_data              =>      l_msg_data	,
		x_return_code           =>      l_return_code	,
		x_routing_step_out	=>	l_old_rout_dets	);

	l_count := l_old_rout_dets.COUNT;

	FOR j IN 1..l_count
	LOOP
		l_line_id	:=	l_old_rout_dets(j).ROUTINGSTEP_ID;
		l_oprn_id	:=	l_old_rout_dets(j).OPRN_ID;

		l_source_entity_name(i)	:= 'OPERATION';
		l_source_entity_key(i)	:= TO_CHAR(p_from_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_oprn_id)
		LOOP
			i := i + 1;
			l_source_entity_name(i)	:= 'ACTIVITY';
			l_source_entity_key(i)	:= TO_CHAR(p_from_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_source_entity_name(i)	:= 'RESOURCE';
				l_source_entity_key(i)	:= TO_CHAR(p_from_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;
	END IF; -- IF l_old_rout_id = l_new_rout_id THEN

	IF l_old_form_id = l_new_form_id THEN
	FOR l_rec IN Get_formula_details(l_old_form_id)
	LOOP
		l_source_entity_name(i)	:= 'MATERIAL';
		l_source_entity_key(i)	:= TO_CHAR(p_from_entity_id) || '$' || TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
		i := i + 1;
	END LOOP;
	END IF;

	/* Set the Target entity name and key for Recipe*/

	i := 1;
	IF l_old_rout_id = l_new_rout_id THEN
	GMD_RECIPE_FETCH_PUB.get_routing_step_details(
		p_api_version           =>	1.0		,
		p_init_msg_list         =>	'F'		,
		p_routing_id            =>      l_new_rout_id	,
		x_return_status         =>      l_status	,
		x_msg_count             =>      l_msg_cnt	,
		x_msg_data              =>      l_msg_data	,
		x_return_code           =>      l_return_code	,
		x_routing_step_out	=>	l_new_rout_dets	);

	l_count := l_new_rout_dets.COUNT;

	FOR j IN 1..l_count
	LOOP
		l_line_id	:=	l_new_rout_dets(j).ROUTINGSTEP_ID;
		l_oprn_id	:=	l_new_rout_dets(j).OPRN_ID;

		l_target_entity_name(i)	:= 'OPERATION';
		l_target_entity_key(i)	:= TO_CHAR(p_to_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_oprn_id)
		LOOP
			i := i + 1;
			l_target_entity_name(i)	:= 'ACTIVITY';
			l_target_entity_key(i)	:= TO_CHAR(p_to_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_target_entity_name(i)	:= 'RESOURCE';
				l_target_entity_key(i)	:= TO_CHAR(p_to_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;
	END IF; -- IF l_old_rout_id = l_new_rout_id THEN

	IF l_old_form_id = l_new_form_id THEN
	FOR l_rec IN Get_formula_details(l_new_form_id)
	LOOP
		l_target_entity_name(i)	:= 'MATERIAL';
		l_target_entity_key(i)	:= TO_CHAR(p_to_entity_id) || '$' || TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
		i := i + 1;
	END LOOP;
	END IF;

ELSIF p_entity_name = 'FORMULA' THEN

	/* Set the Source entity name and key for Formula*/
	i := 1;
	FOR l_rec IN Get_formula_details(p_from_entity_id)
	LOOP
		l_source_entity_name(i)	:= 'MATERIAL';
		l_source_entity_key(i)	:= TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
		i := i + 1;
	END LOOP;

	/* Set the Target entity name and key for Formula*/
	i := 1;
	FOR l_rec IN Get_formula_details(p_to_entity_id)
	LOOP
		l_target_entity_name(i)	:= 'MATERIAL';
		l_target_entity_key(i)	:= TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
		i := i + 1;
	END LOOP;

ELSIF p_entity_name = 'OPERATION' THEN

	/* Set the Source entity name and key for Operation*/

	i := 1;
	l_source_entity_name(i)	:= 'OPERATION';
	l_source_entity_key(i)	:= TO_CHAR(p_from_entity_id);


	-- Get all activity details for the operation
	FOR l_rec IN Get_activity_details(p_from_entity_id)
	LOOP
		i := i + 1;
		l_source_entity_name(i)	:= 'ACTIVITY';
		l_source_entity_key(i)	:= TO_CHAR(l_rec.oprn_line_id);

		-- Get all resource details for the activity
		FOR l_rec_rsrc IN Get_resource_details(l_rec.oprn_line_id)
		LOOP
			i := i + 1;
			l_source_entity_name(i)	:= 'RESOURCE';
			l_source_entity_key(i)	:= TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
		END LOOP;
	END LOOP;

	/* Set the Target entity name and key for Operation*/

	i := 1;
	l_target_entity_name(i)	:= 'OPERATION';
	l_target_entity_key(i)	:= TO_CHAR(p_to_entity_id);

	-- Get all activity details for the operation
	FOR l_rec IN Get_activity_details(p_to_entity_id)
	LOOP
		i := i + 1;
		l_target_entity_name(i)	:= 'ACTIVITY';
		l_target_entity_key(i)	:= TO_CHAR(l_rec.oprn_line_id);

		-- Get all resource details for the activity
		FOR l_rec_rsrc IN Get_resource_details(l_rec.oprn_line_id)
		LOOP
			i := i + 1;
			l_target_entity_name(i)	:= 'RESOURCE';
			l_target_entity_key(i)	:= TO_CHAR(l_rec_rsrc.oprn_line_id)  || '$' || l_rec_rsrc.resources;
		END LOOP;
	END LOOP;

ELSIF p_entity_name = 'ROUTING' THEN

	/* Set the Source entity name and key for Routing */

	i := 1;
	FOR l_rec IN Get_routing_details(p_from_entity_id)
	LOOP
		l_source_entity_name(i)	:= 'OPERATION';
		l_source_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec.oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_rec.oprn_id)
		LOOP
			i := i + 1;
			l_source_entity_name(i)	:= 'ACTIVITY';
			l_source_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_source_entity_name(i)	:= 'RESOURCE';
				l_source_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;

	/* Set the Target entity name and key for Routing */

	i := 1;
	FOR l_rec IN Get_routing_details(p_to_entity_id)
	LOOP
		l_target_entity_name(i)	:= 'OPERATION';
		l_target_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec.oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_rec.oprn_id)
		LOOP
			i := i + 1;
			l_target_entity_name(i)	:= 'ACTIVITY';
			l_target_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_target_entity_name(i)	:= 'RESOURCE';
				l_target_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;

END IF;

/* Call the GMO Create defn from defn API */
FOR j IN 1..l_source_entity_name.COUNT
LOOP

	GMO_INSTRUCTION_GRP.CREATE_DEFN_FROM_DEFN
	   (
	      P_API_VERSION             =>      1.0				,
	      P_INIT_MSG_LIST           =>	FND_API.G_FALSE			,
	      P_VALIDATION_LEVEL        =>	FND_API.G_VALID_LEVEL_FULL	,
	      P_SOURCE_ENTITY_NAME	=>	l_source_entity_name(j)		,
	      P_SOURCE_ENTITY_KEY	=>	l_source_entity_key(j)		,
	      P_TARGET_ENTITY_NAME	=>	l_target_entity_name(j)		,
	      P_TARGET_ENTITY_KEY	=>	l_target_entity_key(j)		,
	      P_INSTRUCTION_TYPE	=>	l_instruction_type		,
	      X_INSTRUCTION_SET_ID	=>	l_proc_instr_id			,
	      X_RETURN_STATUS		=>	X_RETURN_STATUS			,
	      X_MSG_COUNT		=>	X_MSG_COUNT			,
	      X_MSG_DATA		=>	X_MSG_DATA
	   );

END LOOP;

END COPY_PROCESS_INSTR;

/*-------------------------------------------------------------------
-- NAME
--    COPY_PROCESS_INSTR
--
-- SYNOPSIS
--    Procedure COPY_PROCESS_INSTR
--
-- DESCRIPTION
--     This procedure is called to copy the process instructions from
-- child entites to parent entity
--
-- E.g When a reciipe is created, copy the PI's defined at routing and
--     formula level to  recipe-routing and recipe-formula level
--
--     When a routing is created, copy the PI's defined at operation level to the
--     routing-operation level
--
-- HISTORY
--    Sriram    7/20/2005     Created for GMD-GMO Integration Build
--------------------------------------------------------------------*/

PROCEDURE COPY_PROCESS_INSTR  (
				p_entity_name		 IN	VARCHAR2	,
				p_entity_id		 IN	NUMBER		,
			        x_return_status          OUT	NOCOPY VARCHAR2	,
			        x_msg_count              OUT	NOCOPY NUMBER	,
				x_msg_data               OUT	NOCOPY VARCHAR2	) IS

l_rout_id	FM_ROUT_HDR.ROUTING_ID%TYPE;
l_form_id	FM_FORM_MST.FORMULA_ID%TYPE;
l_rout_dets	GMD_RECIPE_FETCH_PUB.routing_step_tbl;

l_parent_entity_name	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_parent_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_child_entity_name	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_child_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_instruction_type	VARCHAR2(10);
l_proc_instr_id		NUMBER;


l_msg_cnt		NUMBER;
l_msg_data		VARCHAR2(2000);
l_return_code		VARCHAR2(20);
l_status		VARCHAR2(30);
l_line_id		NUMBER;
l_oprn_id		NUMBER;
i			NUMBER;


BEGIN

/* Default the process type to 'PROCESS' when called from NPD */
l_instruction_type := 'PROCESS';

IF p_entity_name = 'RECIPE' THEN

	OPEN Get_recipe_details(p_entity_id);
	FETCH Get_recipe_details INTO l_rout_id, l_form_id;
	CLOSE Get_recipe_details;

	i := 1;

	/* Copy routing level PI's to the recipe */
	IF l_rout_id IS NOT NULL THEN
		GMD_RECIPE_FETCH_PUB.get_routing_step_details(
			p_api_version           =>	1.0		,
			p_init_msg_list         =>	'F'		,
			p_routing_id            =>      l_rout_id	,
			x_return_status         =>      l_status	,
			x_msg_count             =>      l_msg_cnt	,
			x_msg_data              =>      l_msg_data	,
			x_return_code           =>      l_return_code	,
			x_routing_step_out	=>	l_rout_dets	);

		FOR j IN 1..l_rout_dets.COUNT
		LOOP
			l_line_id	:=	l_rout_dets(j).ROUTINGSTEP_ID;
			l_oprn_id	:=	l_rout_dets(j).OPRN_ID;

			l_parent_entity_name(i)	:= 'OPERATION';
			l_parent_entity_key(i)	:= TO_CHAR(p_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_oprn_id);

			l_child_entity_name(i)  := 'OPERATION';
			l_child_entity_key(i)	:= TO_CHAR(l_line_id) || '$' || TO_CHAR(l_oprn_id);

			-- Get all activity details for the operation
			FOR l_rec_actv IN Get_activity_details(l_oprn_id)
			LOOP
				i := i + 1;
				l_parent_entity_name(i)	:= 'ACTIVITY';
				l_parent_entity_key(i)	:= TO_CHAR(p_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

				l_child_entity_name(i)  := 'ACTIVITY';
				l_child_entity_key(i)	:= TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

				-- Get all resource details for the activity
				FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
				LOOP
					i := i + 1;
					l_parent_entity_name(i)	:= 'RESOURCE';
					l_parent_entity_key(i)	:= TO_CHAR(p_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;

					l_child_entity_name(i)  := 'RESOURCE';
					l_child_entity_key(i)	:=  TO_CHAR(l_line_id)  || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
				END LOOP;
			END LOOP;
			i := i + 1;
		END LOOP;
	END IF; -- IF l_rout_id IS NOT NULL

	/* Copy formula level PI's to the recipe */
	IF l_form_id IS NOT NULL THEN
		FOR l_rec IN Get_formula_details(l_form_id)
		LOOP
			l_parent_entity_name(i)	:= 'MATERIAL';
			l_parent_entity_key(i)	:= TO_CHAR(p_entity_id) || '$' || TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);

			l_child_entity_name(i)	:= 'MATERIAL';
			l_child_entity_key(i)	:= TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);

			i := i + 1;
		END LOOP;
	END IF; -- IF l_form_id IS NOT NULL

ELSIF p_entity_name = 'ROUTING' THEN

	i := 1;
	FOR l_rec IN Get_routing_details(p_entity_id)
	LOOP
		l_parent_entity_name(i)	:= 'OPERATION';
		l_parent_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec.oprn_id);
		l_child_entity_name(i)	:= 'OPERATION';
		l_child_entity_key(i)	:= TO_CHAR(l_rec.oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_rec.oprn_id)
		LOOP
			i := i + 1;
			l_parent_entity_name(i)	:= 'ACTIVITY';
			l_parent_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);
			l_child_entity_name(i)	:= 'ACTIVITY';
			l_child_entity_key(i)	:= TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_parent_entity_name(i)	:= 'RESOURCE';
				l_parent_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
				l_child_entity_name(i)	:= 'RESOURCE';
				l_child_entity_key(i)	:= TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;

END IF;

/* Call the GMO Create defn from defn API */
FOR j IN 1..l_parent_entity_name.COUNT
LOOP

	GMO_INSTRUCTION_GRP.CREATE_DEFN_FROM_DEFN
	   (
	      P_API_VERSION             =>      1.0				,
	      P_INIT_MSG_LIST           =>	FND_API.G_FALSE			,
	      P_VALIDATION_LEVEL        =>	FND_API.G_VALID_LEVEL_FULL	,
	      P_SOURCE_ENTITY_NAME	=>	l_child_entity_name(j)		,
	      P_SOURCE_ENTITY_KEY	=>	l_child_entity_key(j)		,
	      P_TARGET_ENTITY_NAME	=>	l_parent_entity_name(j)		,
	      P_TARGET_ENTITY_KEY	=>	l_parent_entity_key(j)		,
	      P_INSTRUCTION_TYPE	=>	l_instruction_type		,
	      X_INSTRUCTION_SET_ID	=>	l_proc_instr_id			,
	      X_RETURN_STATUS		=>	X_RETURN_STATUS			,
	      X_MSG_COUNT		=>	X_MSG_COUNT			,
	      X_MSG_DATA		=>	X_MSG_DATA
	   );

END LOOP;

END COPY_PROCESS_INSTR;

/*-----------------------------------------------------------------------------
-- NAME
--    COPY_PROCESS_INSTR_ROW
--
-- SYNOPSIS
--    Procedure COPY_PROCESS_INSTR_ROW
--
-- DESCRIPTION
--     This procedure is called to copy the process instructions of a single from
--     child entity to a parent entity
--
--     When a routing is updated by adding an operation, copy the PI's defined at
--     operation level to the routing-operation level
--
-- HISTORY
--    Kapil M    18-MAY-2006    Bug# 5173039
--------------------------------------------------------------------------------*/

PROCEDURE COPY_PROCESS_INSTR_ROW   (
                                p_entity_name		 IN	VARCHAR2	,
				p_entity_id		 IN	NUMBER		,
			        x_return_status          OUT	NOCOPY VARCHAR2	,
			        x_msg_count              OUT	NOCOPY NUMBER	,
				x_msg_data               OUT	NOCOPY VARCHAR2	) IS

/* Cursor to fetch activity details for an operation */
CURSOR Get_activity_details_t (v_oprn_id NUMBER) IS
  SELECT oprn_line_id, activity
    FROM gmd_operation_activities
   WHERE oprn_id = v_oprn_id
ORDER BY oprn_line_id;

/* Cursor to fetch resource details for an activity */
CURSOR Get_resource_details_t (v_oprn_line_id NUMBER) IS
  SELECT oprn_line_id, resources
    FROM gmd_operation_resources
   WHERE oprn_line_id = v_oprn_line_id
ORDER BY resources;

CURSOR Get_routingstep_details(v_routingstep_id NUMBER) IS
  SELECT r.routingstep_id,r.oprn_id
    FROM fm_rout_dtl r
   WHERE r.routingstep_id = v_routingstep_id;


l_parent_entity_name	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_parent_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_child_entity_name	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_child_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;

l_instruction_type	VARCHAR2(10);
l_return_status         VARCHAR2(10);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_proc_instr_id		NUMBER;
i			NUMBER;
j			NUMBER;
l_routing_step_id        NUMBER;
l_oprn_id               NUMBER;

BEGIN

	/* Default the process type to 'PROCESS' when called from NPD */
	l_instruction_type := 'PROCESS';

IF p_entity_name = 'ROUTING' THEN
	i := 1;
        OPEN Get_routingstep_details(p_entity_id);
        FETCH Get_routingstep_details INTO l_routing_step_id , l_oprn_id;
        CLOSE Get_routingstep_details;

		l_parent_entity_name(i)	:= 'OPERATION';
		l_parent_entity_key(i)	:= TO_CHAR(l_routing_step_id) || '$' || TO_CHAR(l_oprn_id);
		l_child_entity_name(i)	:= 'OPERATION';
		l_child_entity_key(i)	:= TO_CHAR(l_oprn_id);


	-- Get all activity details for the operation
	FOR l_rec_actv IN Get_activity_details_t(l_oprn_id)
	LOOP
		i := i + 1;
		l_parent_entity_name(i)	:= 'ACTIVITY';
		l_parent_entity_key(i)	:= TO_CHAR(l_routing_step_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);
		l_child_entity_name(i)	:= 'ACTIVITY';
		l_child_entity_key(i)	:= TO_CHAR(l_rec_actv.oprn_line_id);


		-- Get all resource details for the activity
		FOR l_rec_rsrc IN Get_resource_details_t(l_oprn_id)
		LOOP
			i := i + 1;
			l_parent_entity_name(i)	:= 'RESOURCE';
			l_parent_entity_key(i)	:= TO_CHAR(l_routing_step_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			l_child_entity_name(i)	:= 'RESOURCE';
			l_child_entity_key(i)	:= TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
		END LOOP;
	END LOOP;

	FOR j IN 1..l_parent_entity_name.COUNT
	LOOP
		GMO_INSTRUCTION_GRP.CREATE_DEFN_FROM_DEFN
		(
		      P_API_VERSION             =>      1.0				,
                      P_COMMIT			=>      'F'				,
		      P_INIT_MSG_LIST           =>	'F'				,
		      P_VALIDATION_LEVEL        =>	NULL				,
		      P_SOURCE_ENTITY_NAME	=>	l_child_entity_name(j)		,
		      P_SOURCE_ENTITY_KEY	=>	l_child_entity_key(j)		,
		      P_TARGET_ENTITY_NAME	=>	l_parent_entity_name(j)		,
		      P_TARGET_ENTITY_KEY	=>	l_parent_entity_key(j)		,
		      P_INSTRUCTION_TYPE	=>	l_instruction_type		,
		      X_INSTRUCTION_SET_ID	=>	l_proc_instr_id			,
		      X_RETURN_STATUS		=>	l_RETURN_STATUS			,
		      X_MSG_COUNT		=>	l_MSG_COUNT			,
		      X_MSG_DATA		=>	l_MSG_DATA
	   );
	END LOOP;

END IF;

END COPY_PROCESS_INSTR_ROW;



/*-------------------------------------------------------------------
-- NAME
--    SEND_PI_ACKN
--
-- SYNOPSIS
--    Procedure SEND_PI_ACKN
--
-- DESCRIPTION
--     This procedure is called to send acknowledgment to the PI framework
-- if version contrl is ON. The source and entity names and keys needs to
-- passed to copy the pending (current) changes from old entity to new entity.
--
--
-- HISTORY
--    Sriram    7/20/2005     Created for GMD-GMO Integration Build
--------------------------------------------------------------------*/

PROCEDURE SEND_PI_ACKN(
				p_entity_name		 IN	VARCHAR2	,
				p_INSTRUCTION_PROCESS_ID IN	NUMBER		,
				p_old_entity_id		 IN	NUMBER		,
				p_new_entity_id		 IN	NUMBER		,
			        X_RETURN_STATUS          OUT	NOCOPY VARCHAR2	,
			        X_MSG_COUNT              OUT	NOCOPY NUMBER	,
				X_MSG_DATA               OUT	NOCOPY VARCHAR2	) IS

l_entity_name		GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_target_entity_name	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_source_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
l_target_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;

l_old_rout_dets		GMD_RECIPE_FETCH_PUB.routing_step_tbl;
l_new_rout_dets		GMD_RECIPE_FETCH_PUB.routing_step_tbl;
l_old_rout_id		FM_ROUT_HDR.ROUTING_ID%TYPE;
l_new_rout_id		FM_ROUT_HDR.ROUTING_ID%TYPE;
l_old_form_id		FM_FORM_MST.FORMULA_ID%TYPE;
l_new_form_id		FM_FORM_MST.FORMULA_ID%TYPE;
l_oprn_id		NUMBER;
l_oprn_no		VARCHAR2(200);
l_msg_cnt		NUMBER;
l_msg_data		VARCHAR2(2000);
l_return_code		VARCHAR2(20);
l_status		VARCHAR2(30);
l_count			NUMBER;
l_line_id		NUMBER;
l_line_no		NUMBER;
l_line_type		NUMBER;
i			NUMBER;
j			NUMBER;

BEGIN

IF p_entity_name IN ('RECIPE', 'STEP_MAT') THEN

	/* Get the old routing and formula id */
	OPEN Get_recipe_details(p_old_entity_id);
	FETCH Get_recipe_details INTO l_old_rout_id, l_old_form_id;
	CLOSE Get_recipe_details;

	/* Get the new routing and formula id */
	OPEN Get_recipe_details(p_new_entity_id);
	FETCH Get_recipe_details INTO l_new_rout_id, l_new_form_id;
	CLOSE Get_recipe_details;

	/* Set the Source entity name and key for Recipe*/
	i := 1;
	IF l_old_rout_id = l_new_rout_id THEN
	GMD_RECIPE_FETCH_PUB.get_routing_step_details(
		p_api_version           =>	1.0		,
		p_init_msg_list         =>	'F'		,
		p_routing_id            =>      l_old_rout_id	,
		x_return_status         =>      l_status	,
		x_msg_count             =>      l_msg_cnt	,
		x_msg_data              =>      l_msg_data	,
		x_return_code           =>      l_return_code	,
		x_routing_step_out	=>	l_old_rout_dets	);

	l_count := l_old_rout_dets.COUNT;

	FOR j IN 1..l_count
	LOOP
		l_line_id	:=	l_old_rout_dets(j).ROUTINGSTEP_ID;
		l_oprn_id	:=	l_old_rout_dets(j).OPRN_ID;

		l_entity_name(i)	:= 'OPERATION';
		l_source_entity_key(i)	:= TO_CHAR(p_old_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_oprn_id)
		LOOP
			i := i + 1;
			l_entity_name(i)	:= 'ACTIVITY';
			l_source_entity_key(i)	:= TO_CHAR(p_old_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_entity_name(i)	:= 'RESOURCE';
				l_source_entity_key(i)	:= TO_CHAR(p_old_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;
	END IF; -- IF l_old_rout_id = l_new_rout_id THEN

	IF l_old_form_id = l_new_form_id THEN
	FOR l_rec IN Get_formula_details(l_old_form_id)
	LOOP
		l_entity_name(i)	:= 'MATERIAL';
		l_source_entity_key(i)	:= TO_CHAR(p_old_entity_id) || '$' || TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
		i := i + 1;
	END LOOP;
	END IF;

	/* Set the Target entity name and key for Recipe*/

	i := 1;
	IF l_old_rout_id = l_new_rout_id THEN
	GMD_RECIPE_FETCH_PUB.get_routing_step_details(
		p_api_version           =>	1.0		,
		p_init_msg_list         =>	'F'		,
		p_routing_id            =>      l_new_rout_id	,
		x_return_status         =>      l_status	,
		x_msg_count             =>      l_msg_cnt	,
		x_msg_data              =>      l_msg_data	,
		x_return_code           =>      l_return_code	,
		x_routing_step_out	=>	l_new_rout_dets	);

	l_count := l_new_rout_dets.COUNT;

	FOR j IN 1..l_count
	LOOP
		l_line_id	:=	l_new_rout_dets(j).ROUTINGSTEP_ID;
		l_oprn_id	:=	l_new_rout_dets(j).OPRN_ID;

		l_target_entity_name(i)	:= 'OPERATION';
		l_target_entity_key(i)	:= TO_CHAR(p_new_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_oprn_id)
		LOOP
			i := i + 1;
			l_target_entity_name(i)	:= 'ACTIVITY';
			l_target_entity_key(i)	:= TO_CHAR(p_new_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_target_entity_name(i)	:= 'RESOURCE';
				l_target_entity_key(i)	:= TO_CHAR(p_new_entity_id) || '$' || TO_CHAR(l_line_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;
	END IF; -- IF l_old_rout_id = l_new_rout_id THEN

	IF l_old_form_id = l_new_form_id THEN
	FOR l_rec IN Get_formula_details(l_new_form_id)
	LOOP
		l_target_entity_name(i)	:= 'MATERIAL';
		l_target_entity_key(i)	:= TO_CHAR(p_new_entity_id) || '$' || TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
		i := i + 1;
	END LOOP;
	END IF;

ELSIF p_entity_name = 'FORMULA' THEN

	/* Set the Source entity name and key for Formula*/
	i := 1;
	FOR l_rec IN Get_formula_details(p_old_entity_id)
	LOOP
		l_entity_name(i)	:= 'MATERIAL';
		l_source_entity_key(i)	:= TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
		i := i + 1;
	END LOOP;

	/* Set the Target entity name and key for Formula*/
	i := 1;
	FOR l_rec IN Get_formula_details(p_new_entity_id)
	LOOP
		l_target_entity_name(i)	:= 'MATERIAL';
		l_target_entity_key(i)	:= TO_CHAR(l_rec.FORMULALINE_ID) || '$' || TO_CHAR(l_rec.INVENTORY_ITEM_ID);
		i := i + 1;
	END LOOP;

ELSIF p_entity_name = 'OPERATION' THEN

	/* Set the Source entity name and key for Operation*/
	i := 1;
	l_entity_name(i)	:= 'OPERATION';
	l_source_entity_key(i)	:= TO_CHAR(p_old_entity_id);
	i := i + 1;

	-- Get all activity details for the operation
	FOR l_rec IN Get_activity_details(p_old_entity_id)
	LOOP
		l_entity_name(i)	:= 'ACTIVITY';
		l_source_entity_key(i)	:= TO_CHAR(l_rec.oprn_line_id);

		-- Get all resource details for the activity
		FOR l_rec_rsrc IN Get_resource_details(l_rec.oprn_line_id)
		LOOP
			i := i + 1;
			l_entity_name(i)	:= 'RESOURCE';
			l_source_entity_key(i)	:= TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
		END LOOP;
		i := i + 1;
	END LOOP;

	/* Set the Target entity name and key for Operation*/

	i := 1;
	l_target_entity_name(i)	:= 'OPERATION';
	l_target_entity_key(i)	:= TO_CHAR(p_new_entity_id);
	i := i + 1;

	-- Get all activity details for the operation
	FOR l_rec IN Get_activity_details(p_new_entity_id)
	LOOP
		l_target_entity_name(i)	:= 'ACTIVITY';
		l_target_entity_key(i)	:= TO_CHAR(l_rec.oprn_line_id);

		-- Get all resource details for the activity
		FOR l_rec_rsrc IN Get_resource_details(l_rec.oprn_line_id)
		LOOP
			i := i + 1;
			l_target_entity_name(i)	:= 'RESOURCE';
			l_target_entity_key(i)	:= TO_CHAR(l_rec_rsrc.oprn_line_id)  || '$' || l_rec_rsrc.resources;
		END LOOP;
		i := i + 1;
	END LOOP;

ELSIF p_entity_name = 'ROUTING' THEN

	/* Set the Source entity name and key for Routing */

	i := 1;
	FOR l_rec IN Get_routing_details(p_old_entity_id)
	LOOP
		l_entity_name(i)	:= 'OPERATION';
		l_source_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec.oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_rec.oprn_id)
		LOOP
			i := i + 1;
			l_entity_name(i)	:= 'ACTIVITY';
			l_source_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_entity_name(i)	:= 'RESOURCE';
				l_source_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;

	/* Set the Target entity name and key for Routing */

	i := 1;
	FOR l_rec IN Get_routing_details(p_new_entity_id)
	LOOP
		l_target_entity_name(i)	:= 'OPERATION';
		l_target_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec.oprn_id);

		-- Get all activity details for the operation
		FOR l_rec_actv IN Get_activity_details(l_rec.oprn_id)
		LOOP
			i := i + 1;
			l_target_entity_name(i)	:= 'ACTIVITY';
			l_target_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_actv.oprn_line_id);

			-- Get all resource details for the activity
			FOR l_rec_rsrc IN Get_resource_details(l_rec_actv.oprn_line_id)
			LOOP
				i := i + 1;
				l_target_entity_name(i)	:= 'RESOURCE';
				l_target_entity_key(i)	:= TO_CHAR(l_rec.routingstep_id) || '$' || TO_CHAR(l_rec_rsrc.oprn_line_id) || '$' || l_rec_rsrc.resources;
			END LOOP;
		END LOOP;
		i := i + 1;
	END LOOP;

END IF;

-- Send the acknowledgment for the new entity created by version control
GMO_INSTRUCTION_GRP.SEND_DEFN_ACKN(
    P_API_VERSION		=>	1.0				,
    P_INIT_MSG_LIST		=>	FND_API.G_FALSE			,
    P_VALIDATION_LEVEL		=>	FND_API.G_VALID_LEVEL_FULL	,
    X_RETURN_STATUS		=>	X_RETURN_STATUS			,
    X_MSG_COUNT			=>	X_MSG_COUNT			,
    X_MSG_DATA			=>	X_MSG_DATA			,
    P_INSTRUCTION_PROCESS_ID	=>	p_INSTRUCTION_PROCESS_ID	,
    P_ENTITY_NAME		=>	l_entity_name			,
    P_SOURCE_ENTITY_KEY		=>	l_source_entity_key		,
    P_TARGET_ENTITY_KEY		=>	l_target_entity_key
);

END SEND_PI_ACKN;

--API related Designer.

FUNCTION  GET_DESG_INVOKE_PI_ID(p_entity_type VARCHAR2)
/*-------------------------------------------------------------------
-- NAME
--    GET_DESG_INVOKE_PI_ID
-- DESCRIPTION
--
--
-- HISTORY
-- kkillams     20-SEP-2005    Created for GMD-GMO Integration Build
-------------------------------------------------------------------*/
RETURN NUMBER AS
BEGIN
IF p_entity_type    = 'FORMULA' THEN
   RETURN p_formula_instr_process_id;
ELSIF p_entity_type = 'ROUTING' THEN
   RETURN p_routing_instr_process_id;
ELSIF p_entity_type = 'RECIPE' THEN
   RETURN p_recipe_instr_process_id;
ELSIF p_entity_type = 'STEP_MAT' THEN
   RETURN p_setp_instr_process_id;
END IF;
END;
PROCEDURE  SET_DESG_INVOKE_PI_ID(p_entity_type  VARCHAR2,
                                p_pi_entity_id NUMBER) AS
/*-------------------------------------------------------------------
-- NAME
--    DESG_SEND_PI_ACKN
-- DESCRIPTION
--
--
-- HISTORY
-- kkillams     20-SEP-2005    Created for GMD-GMO Integration Build
-------------------------------------------------------------------*/
BEGIN
 IF p_entity_type    = 'FORMULA' THEN
       p_formula_instr_process_id := p_pi_entity_id;
 ELSIF p_entity_type = 'ROUTING' THEN
       p_routing_instr_process_id := p_pi_entity_id;
 ELSIF p_entity_type = 'RECIPE' THEN
       p_recipe_instr_process_id := p_pi_entity_id;
 ELSIF p_entity_type = 'STEP_MAT' THEN
       p_setp_instr_process_id := p_pi_entity_id;
 END IF;
END;

PROCEDURE DESG_SEND_PI_ACKN(p_return_status OUT NOCOPY VARCHAR2) AS
/*-------------------------------------------------------------------
-- NAME
--    DESG_SEND_PI_ACKN
-- DESCRIPTION
--
--
-- HISTORY
-- kkillams     20-SEP-2005    Created for GMD-GMO Integration Build
-------------------------------------------------------------------*/
    l_entity_name       GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
    l_src_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
    l_target_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_return_status     VARCHAR2(10);

BEGIN
 p_return_status := 'S';
 IF   gmd_process_instr_utils.p_recipe_instr_process_id  IS NOT NULL THEN
         gmo_instruction_pvt.send_defn_ackn
                   ( p_instruction_process_id => gmd_process_instr_utils.p_recipe_instr_process_id,
                     p_entity_name            => l_entity_name,
                     p_source_entity_key      => l_src_entity_key,
                     p_target_entity_key      => l_target_entity_key,
                     x_return_status          => l_return_status,
                     x_msg_count              => l_msg_count,
                     x_msg_data               => l_msg_data );
        IF l_return_status <> 'S' THEN
           p_return_status := 'E';
        END IF;
 END IF;
 IF   gmd_process_instr_utils.p_formula_instr_process_id  IS NOT NULL THEN
         gmo_instruction_pvt.send_defn_ackn
                   ( p_instruction_process_id => gmd_process_instr_utils.p_formula_instr_process_id,
                     p_entity_name            => l_entity_name,
                     p_source_entity_key      => l_src_entity_key,
                     p_target_entity_key      => l_target_entity_key,
                     x_return_status          => l_return_status,
                     x_msg_count              => l_msg_count,
                     x_msg_data               => l_msg_data );
        IF l_return_status <> 'S' THEN
           p_return_status := 'E';
        END IF;
 END IF;
 IF   gmd_process_instr_utils.p_routing_instr_process_id  IS NOT NULL THEN
         gmo_instruction_pvt.send_defn_ackn
                   ( p_instruction_process_id => gmd_process_instr_utils.p_routing_instr_process_id,
                     p_entity_name            => l_entity_name,
                     p_source_entity_key      => l_src_entity_key,
                     p_target_entity_key      => l_target_entity_key,
                     x_return_status          => l_return_status,
                     x_msg_count              => l_msg_count,
                     x_msg_data               => l_msg_data );
        IF l_return_status <> 'S' THEN
           p_return_status := 'E';
        END IF;
 END IF;
 IF   gmd_process_instr_utils.p_setp_instr_process_id  IS NOT NULL THEN
         gmo_instruction_pvt.send_defn_ackn
                   ( p_instruction_process_id => gmd_process_instr_utils.p_setp_instr_process_id,
                     p_entity_name            => l_entity_name,
                     p_source_entity_key      => l_src_entity_key,
                     p_target_entity_key      => l_target_entity_key,
                     x_return_status          => l_return_status,
                     x_msg_count              => l_msg_count,
                     x_msg_data               => l_msg_data );
        IF l_return_status <> 'S' THEN
           p_return_status := 'E';
        END IF;
 END IF;

p_recipe_instr_process_id     := NULL;
p_formula_instr_process_id    := NULL;
p_routing_instr_process_id    := NULL;
p_setp_instr_process_id       := NULL;

EXCEPTION
WHEN OTHERS THEN
     p_return_status := 'U';
END DESG_SEND_PI_ACKN;

/*-------------------------------------------------------------------
-- NAME
--    DESG_SEND_VER_PI_ACKN
-- DESCRIPTION
--
--
-- HISTORY
-- kkillams     20-SEP-2005    Created for GMD-GMO Integration Build
--------------------------------------------------------------------*/
PROCEDURE DESG_SEND_VER_PI_ACKN(p_from_recipe_id         IN  VARCHAR2,
                                p_from_formula_id        IN  VARCHAR2,
                                p_from_routing_id        IN  VARCHAR2,
                                p_to_recipe_id           IN  VARCHAR2,
                                p_return_status          OUT NOCOPY VARCHAR2) AS
    CURSOR Cur_get_rcp_hdr(cp_recipe_id NUMBER) IS
      SELECT formula_id, routing_id ,recipe_id
      FROM   gmd_recipes
      WHERE  recipe_id      = cp_recipe_id;

    rec_from_recipe       Cur_get_rcp_hdr%ROWTYPE;
    rec_to_recipe         Cur_get_rcp_hdr%ROWTYPE;

    l_entity_name       GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
    l_src_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
    l_target_entity_key	GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_return_status     VARCHAR2(10);

BEGIN

    rec_from_recipe.recipe_id  := p_from_recipe_id;
    rec_from_recipe.formula_id := p_from_formula_id;
    rec_from_recipe.routing_id := p_from_routing_id;

    OPEN Cur_get_rcp_hdr(p_to_recipe_id);
    FETCH Cur_get_rcp_hdr INTO rec_to_recipe;
    CLOSE Cur_get_rcp_hdr;

    IF ( p_recipe_instr_process_id IS NOT NULL AND
       ( rec_from_recipe.recipe_id <> rec_to_recipe.recipe_id )) THEN
        GMD_PROCESS_INSTR_UTILS.SEND_PI_ACKN(
                        p_entity_name		 => 	'RECIPE'			,
                        p_INSTRUCTION_PROCESS_ID =>	p_recipe_instr_process_id	,
                        p_old_entity_id		 =>	rec_from_recipe.recipe_id	,
                        p_new_entity_id		 =>     rec_to_recipe.recipe_id 	,
                        X_RETURN_STATUS          =>	l_return_status			,
                        X_MSG_COUNT              =>	l_msg_count			,
                        X_MSG_DATA               =>	l_msg_data			);
        IF l_return_status <> 'S' THEN
           p_return_status := 'E';
        END IF;
        p_recipe_instr_process_id := NULL;
    END IF;
    IF ( p_formula_instr_process_id IS NOT NULL AND
       ( rec_from_recipe.formula_id <> rec_to_recipe.formula_id )) THEN
        GMD_PROCESS_INSTR_UTILS.SEND_PI_ACKN(
                        p_entity_name		 => 	'FORMULA'			,
                        p_INSTRUCTION_PROCESS_ID =>	p_formula_instr_process_id	,
                        p_old_entity_id		 =>	rec_from_recipe.formula_id	,
                        p_new_entity_id		 =>     rec_to_recipe.formula_id 	,
                        X_RETURN_STATUS          =>	l_return_status			,
                        X_MSG_COUNT              =>	l_msg_count			,
                        X_MSG_DATA               =>	l_msg_data			);

        IF l_return_status <> 'S' THEN
           p_return_status := 'E';
        END IF;
        p_formula_instr_process_id := NULL;
    END IF;

    IF ( p_routing_instr_process_id IS NOT NULL AND
       ( rec_from_recipe.routing_id <> rec_to_recipe.routing_id )) THEN
        GMD_PROCESS_INSTR_UTILS.SEND_PI_ACKN(
                        p_entity_name		 => 	'ROUTING'			,
                        p_INSTRUCTION_PROCESS_ID =>	p_routing_instr_process_id	,
                        p_old_entity_id		 =>	    rec_from_recipe.routing_id	,
                        p_new_entity_id		 =>     rec_to_recipe.routing_id 	,
                        X_RETURN_STATUS          =>	l_return_status			,
                        X_MSG_COUNT              =>	l_msg_count			,
                        X_MSG_DATA               =>	l_msg_data			);

        IF l_return_status <> 'S' THEN
           p_return_status := 'E';
        END IF;
        p_routing_instr_process_id :=  NULL;
    END IF;

    DESG_SEND_PI_ACKN (p_return_status => p_return_status);
EXCEPTION
WHEN OTHERS THEN
     p_return_status := 'U';
END DESG_SEND_VER_PI_ACKN;

END GMD_PROCESS_INSTR_UTILS;

/
