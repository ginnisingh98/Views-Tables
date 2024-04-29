--------------------------------------------------------
--  DDL for Package Body GMD_CONC_REPLACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_CONC_REPLACE_PKG" AS
/* $Header: GMDROPRB.pls 120.21 2006/09/19 03:39:42 kamanda noship $ */

  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_CONC_REPLACE_PKG';

--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST 20-FEB-2004, END

  /*#############################################################
  # NAME
  #	delete_recipe_dependencies
  # SYNOPSIS
  #	delete_recipe_dependencies
  # DESCRIPTION
  #    Deletes Recipe Dependencies when either its formula or Recipe
  #    information is changed.
  ###############################################################*/
  PROCEDURE delete_recipe_dependencies(precipe_id NUMBER,
                                       update_item VARCHAR2) IS
    l_api_name       VARCHAR2(100)  := 'DELETE_RECIPE_DEPENDENCIES';
  BEGIN
   IF (update_item = 'FORMULA') THEN
     /* Bug 3037410 Appended the where clause to check for the
        validity rule's Product */
     DELETE FROM gmd_recipe_validity_rules
     WHERE recipe_id = precipe_id AND
           inventory_item_id NOT IN (SELECT inventory_item_id FROM fm_matl_dtl
                           WHERE formula_id = (SELECT formula_id FROM gmd_recipes_b
                                               WHERE recipe_id = precipe_id)
                           AND line_type = 1);

     fnd_message.set_name('GMD', 'GMD_DELETE_RECIPE_FM_DEP');
     FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
     FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   ELSIF(update_item = 'ROUTING') THEN
     DELETE FROM gmd_recipe_routing_steps
     WHERE recipe_id = precipe_id;

     DELETE FROM gmd_recipe_orgn_activities
     WHERE recipe_id = precipe_id;

     DELETE FROM gmd_recipe_orgn_resources
     WHERE recipe_id = precipe_id;

     fnd_message.set_name('GMD', 'GMD_DELETE_RECIPE_RT_DEP');
     FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
     FND_FILE.NEW_LINE(FND_FILE.LOG,1);
   END IF;

     DELETE FROM gmd_recipe_step_materials
     WHERE recipe_id = precipe_id;

     fnd_message.set_name('GMD', 'GMD_DELETE_STEP_MAT_ASSOC');
     FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
     FND_FILE.NEW_LINE(FND_FILE.LOG,1);

 EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
 END delete_recipe_dependencies;

 /*###############################################################
  # NAME
  #	Populate_search_table
  # SYNOPSIS
  #	Populate_search_table
  # DESCRIPTION
  #    Performs populates a PL/SQL table with the search query.
  ###############################################################*/
  Procedure Populate_search_table(X_search_tbl OUT NOCOPY Search_Result_Tbl) IS
    l_api_name      VARCHAR2(100)  := 'POPULATE_SEARCH_TABLE';
    l_dsql_text     VARCHAR2(2000);
    l_cursor_id     int;
    l_num_of_rows   NUMBER;
    l_value         NUMBER;
    l_row_cnt       NUMBER := 0;
    l_error         VARCHAR2(2000);
    l_Object_id     NUMBER;
    l_object_name   VARCHAR2(240);
    l_object_vers   NUMBER;
    l_object_desc   VARCHAR2(240);
    l_object_status_desc   VARCHAR2(240);
    l_object_select_ind   NUMBER;
    l_object_status_code   VARCHAR2(240);

    l_debug_text  VARCHAR2(2000);

  BEGIN
    -- Delete rows from previous searches
    DELETE FROM gmd_msnr_results
    WHERE concurrent_id IS NULL;

    l_cursor_id := dbms_sql.open_cursor;
    fnd_dsql.set_cursor(l_cursor_id);
    l_dsql_text := fnd_dsql.get_text(FALSE);

    l_debug_text := fnd_dsql.get_text(TRUE);
    --insert into shy_text values (l_debug_text); commit;

    dbms_sql.parse(l_cursor_id, l_dsql_text, dbms_sql.native);
    fnd_dsql.do_binds;

    dbms_sql.define_column(l_cursor_id, 1, l_Object_id           );
    dbms_sql.define_column(l_cursor_id, 2, l_object_name, 240    );
    dbms_sql.define_column(l_cursor_id, 3, l_object_vers         );
    dbms_sql.define_column(l_cursor_id, 4, l_object_desc, 240    );
    dbms_sql.define_column(l_cursor_id, 5, l_object_status_desc, 240  );
    dbms_sql.define_column(l_cursor_id, 6, l_object_select_ind  );
    dbms_sql.define_column(l_cursor_id, 7, l_object_status_code, 240  );

    l_num_of_rows := dbms_sql.execute(l_cursor_id);

    LOOP
      IF dbms_sql.fetch_rows(l_cursor_id) > 0 then
        l_row_cnt := l_row_cnt + 1;

        dbms_sql.column_value(l_cursor_id, 1, l_Object_id           );
        dbms_sql.column_value(l_cursor_id, 2, l_object_name         );
        dbms_sql.column_value(l_cursor_id, 3, l_object_vers         );
        dbms_sql.column_value(l_cursor_id, 4, l_object_desc         );
        dbms_sql.column_value(l_cursor_id, 5, l_object_status_desc  );
        dbms_sql.column_value(l_cursor_id, 6, l_object_select_ind   );
        dbms_sql.column_value(l_cursor_id, 7, l_object_status_code  );

        IF (l_object_status_code IN ('200','500','800','1000')) THEN
          l_object_select_ind := 0;
        END IF;

        -- Populate the pl/sql table
        -- This should go away soon !!!!!!
        X_search_tbl(l_row_cnt).Object_id           :=  l_object_id     ;
        X_search_tbl(l_row_cnt).object_name         :=  l_object_name ;
        X_search_tbl(l_row_cnt).object_vers         :=  l_object_vers        ;
        X_search_tbl(l_row_cnt).object_desc         :=  l_object_desc        ;
        X_search_tbl(l_row_cnt).object_status_desc  :=  l_object_status_desc ;
        X_search_tbl(l_row_cnt).object_select_ind   :=  l_object_select_ind  ;
        X_search_tbl(l_row_cnt).object_status_code  :=  l_object_status_code ;

        -- Save the set of details in work table
        INSERT INTO gmd_msnr_results
        ( concurrent_id
         ,object_id
         ,object_name
         ,object_vers
         ,object_desc
         ,object_status_code
         ,object_status_desc
         ,object_select_ind
        )
        VALUES
        ( Null
         ,l_object_id
         ,l_object_name
         ,l_object_vers
         ,l_object_desc
         ,l_object_status_code
         ,l_object_status_desc
         ,l_object_select_ind
        );
      ELSE
        EXIT;
      END IF;
    END LOOP;

    dbms_sql.close_cursor(l_cursor_id);
    -- Commit all data populated
    --Commit; Bug 4479488 Commented the commit
 EXCEPTION
   WHEN OTHERS THEN
     IF (dbms_sql.is_open(l_cursor_id)) THEN
       dbms_sql.close_cursor(l_cursor_id);
     END IF;
     fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
  END Populate_search_table;

 /*  ************************************************************************ */
 /*  API name    : Mass_Replace_Operation                                     */
 /*  Type        : Private                                                    */
 /*  Function    :                                                            */
 /*  Pre-reqs    : None.                                                      */
 /*  Parameters  :                                                            */
 /*  IN          : prequest_id             IN      NUMBER  (Required)         */
 /*  Notes       : Performs replace of one or more instance of entities like  */
 /*                formula, routing, recipe, operation, Validity Rules.       */
 /*  HISTORY                                                                  */
 /*  20-Feb-2003   Shyam Sitaraman    Initial Implementation                  */
 /*  17-MAR-2206   Kapil M            Made changes for better log details     */
 /*  20-JUN-2006   Kapil M            Changes made to get the recipe type     */
 /*                                   value                                   */
 /*  19-SEP-2006   Kalyani            Display orgn code in log file.          */
 /*  19-SEP-2006   Kalyani            Check item access for override orgn     */
 /*  19-SEP-2006   Kalyani            Removed unwanted fnd_msg_pub.add calls. */
 /*  ************************************************************************ */
 PROCEDURE Mass_Replace_Operation (  err_buf           OUT NOCOPY VARCHAR2,
    	                             ret_code          OUT NOCOPY VARCHAR2,
                                     pConcurrent_id    IN  NUMBER DEFAULT NULL,
                                     pObject_type      IN  VARCHAR2,
                                     pReplace_type     IN  VARCHAR2,
                                     pOld_Name         IN  VARCHAR2,
                                     pNew_Name         IN  VARCHAR2,
                                     pOld_Version      IN  VARCHAR2 DEFAULT NULL,
                                     pNew_Version      IN  VARCHAR2 DEFAULT NULL,
                                     pScale_factor     IN  VARCHAR2 DEFAULT '1',
                                     pVersion_flag     IN  VARCHAR2 DEFAULT 'N',
                                     pCreate_Recipe    IN  NUMBER
                        				   ) IS
    l_api_name       VARCHAR2(100)  := 'MASS_REPLACE_OPERATION';
    l_mesg_count     NUMBER;
    l_mesg_data      VARCHAR2(2000);
    l_return_status  VARCHAR2(1);
    l_action_flag    VARCHAR2(1) := 'U';
    l_status_type    GMD_STATUS_B.status_type%TYPE;

    l_item_no	     VARCHAR2(2000);
    l_formula_class  FM_FORM_MST_B.formula_class%TYPE;
    l_new_ingredient FM_MATL_DTL.inventory_item_id%TYPE;
    l_old_ingredient FM_MATL_DTL.inventory_item_id%TYPE;
    l_owner_id       FM_FORM_MST_B.owner_id%TYPE;
    l_formula_id     FM_FORM_MST_B.formula_id%TYPE;
    l_form_id	     FM_FORM_MST_B.formula_id%TYPE;
    l_scale_factor   NUMBER;

    l_start_date     VARCHAR2(32);
    l_end_date       VARCHAR2(32);
    l_old_end_date   VARCHAR2(32);  -- Kapil

    l_old_oprn       GMD_OPERATIONS_B.oprn_no%TYPE;
    l_new_oprn       GMD_OPERATIONS_B.oprn_no%TYPE;
    l_routing_class  GMD_ROUTINGS_B.routing_class%TYPE;
    l_routing_id     GMD_ROUTINGS_B.routing_id%TYPE;
    l_routingStep_id FM_ROUT_DTL.RoutingStep_id%TYPE;

    l_old_actv       GMD_OPERATION_ACTIVITIES.activity%TYPE;
    l_new_actv       GMD_OPERATION_ACTIVITIES.activity%TYPE;
    l_oprn_class     GMD_OPERATIONS_B.oprn_class%TYPE;
    l_old_resource   GMD_OPERATION_RESOURCES.resources%TYPE;
    l_new_resource   GMD_OPERATION_RESOURCES.resources%TYPE;
    l_oprn_id        GMD_OPERATIONS_B.oprn_id%TYPE;
    l_oprn_line_id   GMD_OPERATION_ACTIVITIES.oprn_line_id%TYPE;


    l_owner_org      GMD_RECIPES_B.owner_orgn_code%TYPE;
    l_organization_id GMD_RECIPES_B.owner_organization_id%TYPE;
    l_recipe_id      GMD_RECIPES_B.recipe_id%TYPE;
    l_recipe_type    GMD_RECIPES_B.recipe_type%TYPE;

    l_user_id        NUMBER := FND_GLOBAL.USER_ID;

    l_dummy_cnt      NUMBER;
    l_error_text     VARCHAR2(2000);
    l_rowcount       NUMBER := 0;
    l_object_version NUMBER;
    l_orgn_id	     NUMBER;
    l_vers_cntrl     VARCHAR2(3);
    l_return_stat    VARCHAR2(10);

    l_text           VARCHAR2(100);
    l_dependent_val  BOOLEAN := FALSE;
    l_object_name_vers VARCHAR2(200);

    l_retval         BOOLEAN;
    l_version_enabled VARCHAR2(1);
    l_status	      VARCHAR2(10);

    -- Define different table types
    p_rout_update_table     GMD_ROUTINGS_PUB.update_tbl_type;
    p_oprn_update_table     GMD_OPERATIONS_PUB.update_tbl_type;
    p_oprn_activity_table   GMD_OPERATION_ACTIVITIES_PUB.update_tbl_type;
    p_oprn_resources_table  GMD_OPERATION_RESOURCES_PUB.update_tbl_type;
    p_validity_rules_table  GMD_VALIDITY_RULES_PVT.update_tbl_type;

    CURSOR get_object_info  IS
      SElECT  Upper(pObject_type)  Object_type  -- e.g 'FORMULA', 'RECIPE' etc
             ,Upper(pReplace_type) Replace_type -- e.g 'FORMULA_CLASS'
             ,pOld_Name            Old_Name     -- e.g 'SHY-TEST-FMCLS'
             ,pNew_Name            New_Name     -- e.g 'TDAN-TEST-FMCLS'
             ,pOld_Version         Old_Version  -- Applicable only for formula
             ,pNew_Version         New_version  -- Routing and Operation
             ,pScale_factor        Scale_factor -- defaults to 1
             ,pVersion_flag        Version_flag -- defaults to 'N'
             ,object_id                         -- e.g formula_id = 100
             ,object_name                       -- e.g formula_no = 'SHY-TEST'
             ,object_vers                       -- e.g formula_vers = 2
             ,object_desc
             ,object_status_code                -- e.g formula_status = '100'
             ,concurrent_id
      FROM   gmd_msnr_results
      WHERE  object_select_ind = 1 AND
             concurrent_id = pConcurrent_id;

   CURSOR Check_version_enabled(vStatus VARCHAR2) IS
       SELECT version_enabled
       FROM gmd_status_b
       WHERE status_type = vStatus;

   -- Cursor to get formula_id when recipe_id is passed
   CURSOR get_formula_id(v_recp_id NUMBER) IS
       SELECT formula_id
       FROM   gmd_recipes_b
       WHERE  recipe_id = v_recp_id;

   -- Cursor to get formula_id when Validity Rule Id is passed
   CURSOR get_recp_formula_id(v_vr_id NUMBER) IS
       SELECT r.formula_id
       FROM   gmd_recipes_b r, gmd_recipe_validity_rules vr
       WHERE  vr.recipe_validity_rule_id  = v_vr_id
         AND  r.recipe_id = vr.recipe_id;

  CURSOR Cur_get_validity (V_rcp_vldty_rule_id NUMBER) IS
     SELECT recipe_id
     FROM   gmd_recipe_validity_rules
     WHERE  recipe_validity_rule_id = V_rcp_vldty_rule_id;

  CURSOR Cur_check_item (V_form_id NUMBER, V_item_id NUMBER) IS
      SELECT 1
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = V_item_id
      AND    recipe_enabled_flag = 'Y'
      AND    organization_id = (SELECT owner_organization_id
				FROM   fm_form_mst_b
				WHERE  formula_id = V_form_id);
/* BEGIN Declaration KSHUKLA bug 5198213 */
   -- Cursor to check if the item revision is enabled
   CURSOR cur_ITEM_VER_ENABLED(v_item_id NUMBER) IS
          select REVISION_QTY_CONTROL_CODE
          from mtl_system_items_b
          where inventory_item_id = v_item_id;
   CURSOR cur_item_ver_access(v_form_id NUMBER, v_item_id NUMBER) IS
          select 1
          from mtl_item_revisions
          where inventory_item_id = v_item_id
          and organization_id =(SELECT owner_organization_id
				FROM   fm_form_mst_b
				WHERE  formula_id = V_form_id)
          and  REVISION = pNew_Version ;
      l_item_rev_ctl NUMBER;
      l_rev_access   NUMBER := 0;
  /* END Declaration KSHUKLA bug 5198213 */

  CURSOR Cur_get_recipe_org (V_recipe_id NUMBER) IS
     SELECT owner_organization_id
     FROM   gmd_recipes_b
     WHERE  recipe_id = V_recipe_id;

  -- Bug 5531717 Added
  CURSOR Cur_get_recipe_override_org (V_recipe_id NUMBER) IS
     SELECT organization_id
     FROM   gmd_recipe_process_loss
     WHERE  recipe_id = V_recipe_id;

  l_recipe_override_orgn Cur_get_recipe_override_org%ROWTYPE;

   -- Item substitution related change, BUG 4479101
   CURSOR Cur_get_substitute_id(vOriginal_item_id NUMBER, V_form_id NUMBER) IS
     SELECT substitution_id
     FROM   gmd_item_substitution_hdr_b
     WHERE  original_inventory_item_id = vOriginal_item_id
     AND    owner_organization_id = (SELECT owner_organization_id
				     FROM   fm_form_mst_b
				     WHERE  formula_id = V_form_id) ;

   -- Cursor to chk if item is an expr item in formula owning orgn
   CURSOR Cur_experimental_items(V_form_id NUMBER, V_item_id NUMBER) IS
	SELECT COUNT(i.inventory_item_id)
	  FROM fm_form_mst f, mtl_system_items i
	 WHERE f.formula_id = V_form_id
	   AND i.organization_id  = f.owner_organization_id
	   AND i.inventory_item_id = V_item_id
	   AND i.eng_item_flag = 'Y';


 l_obj_id	NUMBER;
 l_org_id	NUMBER;
 l_itm_exists	NUMBER := 0;
 l_item_txt	VARCHAR2(100);
 l_expr_items_found   NUMBER;

    -- Exception declare
    NO_UPDATE_EXCEPTION    EXCEPTION;
    NO_REPLACE_EXCEPTION   EXCEPTION;

    -- Internal Functions
    FUNCTION get_recipe_use(vRecipe_use VARCHAR2) Return VARCHAR2 IS
      CURSOR  recipe_use_meaning(vRecipe_use VARCHAR2) IS
       SELECT meaning
       FROM   Gem_lookups
       WHERE  lookup_type = 'GMD_FORMULA_USE'
       AND    lookup_code = vRecipe_use;

      l_recipe_use  VARCHAR2(100);
    BEGIN
      OPEN recipe_use_meaning(vRecipe_use);
      FETCH recipe_use_meaning INTO l_recipe_use;
      CLOSE recipe_use_meaning;

      RETURN l_recipe_use;
    END get_recipe_use;

    FUNCTION get_item_no(vItem_id VARCHAR2) Return VARCHAR2 IS

      CURSOR get_item(vItem_id VARCHAR2) IS
        SELECT concatenated_segments
        FROM   mtl_system_items_kfv
        WHERE  inventory_item_id = vItem_id;

      l_item_no  VARCHAR2(2000);
    BEGIN
      OPEN get_item(vItem_id);
      FETCH get_item INTO l_item_no;
      CLOSE get_item;

      RETURN l_item_no;
    END get_item_no;



    FUNCTION get_owner_name(vOwner_id VARCHAR2) Return VARCHAR2 IS
      CURSOR get_owner(vOwner_id VARCHAR2) IS
        SELECT user_name
        FROM   fnd_user
        WHERE  user_id = vOwner_id;
      l_owner  VARCHAR2(100);
    BEGIN
      OPEN get_owner(vOwner_id);
      FETCH get_owner INTO l_owner;
      CLOSE get_owner;

      RETURN l_owner;
    END get_owner_name;

    FUNCTION get_status_meaning(P_status_code IN VARCHAR2)  RETURN VARCHAR2 IS
      CURSOR Cur_get IS
        SELECT meaning
        FROM   gmd_status
        WHERE  status_code = P_status_code;

        l_meaning  gmd_status.meaning%TYPE;
    BEGIN
      OPEN Cur_get;
      FETCH Cur_get INTO l_meaning;
      CLOSE Cur_get;

      RETURN l_meaning;
    END get_status_meaning;

    FUNCTION get_orgn_code(p_orgn_id IN NUMBER)  RETURN VARCHAR2 IS
      CURSOR Cur_get IS
	SELECT organization_code
	FROM   mtl_parameters
	WHERE  organization_id = p_orgn_id;

        l_orgn_code  VARCHAR2(4);
    BEGIN
      OPEN Cur_get;
      FETCH Cur_get INTO l_orgn_code;
      CLOSE Cur_get;

      RETURN l_orgn_code;
    END get_orgn_code;

        -- Bug# 5234792 Kapil M.
        -- To retrieve the recipe_type
    FUNCTION get_recipe_type(vRecipe_type VARCHAR2) Return VARCHAR2 IS
      CURSOR  recipe_type_meaning(vRecipe_type VARCHAR2) IS
       SELECT meaning
       FROM   Gem_lookups
       WHERE  lookup_type = 'GMD_RECIPE_TYPE'
       AND    lookup_code = vRecipe_type;

      l_recipe_type  VARCHAR2(100);
    BEGIN
      OPEN recipe_type_meaning(vRecipe_type);
      FETCH recipe_type_meaning INTO l_recipe_type;
      CLOSE recipe_type_meaning;
      RETURN l_recipe_type;
    END get_recipe_type;

  BEGIN
    -- gmd_debug.log_initialize('MSNR');

    IF (l_debug = 'Y') THEN
        gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : 1st line ');
    END IF;

    -- Using concurrent_id/request_id we get the details on the object and column that
    -- is being replaced.
    -- Please Note : Each request id can have multiple replace rows.
    FOR get_object_rec IN get_object_info LOOP
      -- Initialize the following variables
      l_error_text := '';
      l_return_status := 'S';

      BEGIN
        IF (get_object_rec.object_vers  IS NULL) THEN
          get_object_rec.object_name
                        := GMD_API_GRP.get_object_name_version
                                       (get_object_rec.object_type
                                       ,get_object_rec.object_id
                                       ,'NAME');
          get_object_rec.object_vers
                        := GMD_API_GRP.get_object_name_version
                                       (get_object_rec.object_type
                                       ,get_object_rec.object_id
                                       ,'VERSION');
         l_object_name_vers := get_object_rec.object_name||' - '||
                               get_object_rec.object_vers;
        END IF;

        -- Making new line entry and prompting users about MSNR request
        -- Bug# 5008299 Kapil M
        -- Moved the code for log file so that it is shown for every replace
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
        FND_MESSAGE.SET_NAME('GMD','GMD_MSNR_REPLACE_MESG');
        FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
        FND_MESSAGE.SET_TOKEN('NAME',get_object_rec.object_name);
        FND_MESSAGE.SET_TOKEN('VERSION',get_object_rec.object_vers);
        FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
        FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);

	-- NPD Conv.
	-- Check if the Entity Owning organization is available for the responsibility
	IF NOT gmd_api_grp.Check_orgn_access(	Entity     => get_object_rec.object_type,
						Entity_id  => get_object_rec.object_id) THEN
		RAISE NO_UPDATE_EXCEPTION;
	END IF;

        IF (l_debug = 'Y') THEN

          gmd_debug.put_line(g_pkg_name||'.'||l_api_name
              ||' : Call Sts API - object type, replace_type, '
              ||'object id , old_name/version and new_name = '
              ||get_object_rec.object_type||' - '
              ||get_object_rec.replace_type||' - '
              ||get_object_rec.object_id||' - '
              ||get_object_rec.old_name||' / '||get_object_rec.object_vers||' - '
              ||get_object_rec.new_name);
        END IF;

        -- Check if the replaceable column is Status
        -- If so then call the Change status API
        IF get_object_rec.replace_type = 'STATUS' THEN

          -- Call the change status API
          GMD_STATUS_PUB.modify_status
          ( p_entity_name       =>  get_object_rec.object_type
          , p_entity_id         =>  get_object_rec.object_id
          , p_to_status         =>  get_object_rec.new_name
          , p_ignore_flag       =>  TRUE
          , x_message_count     =>  l_mesg_count
          , x_message_list      =>  l_mesg_data
          , x_return_status     =>  l_return_status
          );

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line
            ('In MSNR replace : After Sts API - return status = '
            ||l_return_status);
          END IF;

          -- Can return pending or success status
          IF (l_return_status <> 'S') AND (l_return_status <> 'P')  THEN
            RAISE No_Update_Exception;
          END IF;
        ELSE -- for all other object-replace types.
          -- Get the status type for this object
          l_status_type := GMD_API_GRP.get_object_status_type
                           ( get_object_rec.object_type
                           , get_object_rec.object_id);

          OPEN  Check_version_enabled(l_status_type);
          FETCH Check_version_enabled  INTO l_version_enabled;
            IF (Check_version_enabled%NOTFOUND) THEN
               l_version_enabled := 'N';
            END IF;
          CLOSE Check_version_enabled;

          gmd_debug.put_line('In MSNR Replace : The status type = '||l_status_type||
                    ' and the version flag API passes = '||get_object_rec.version_flag||
                    ' and version enabled check = '||l_version_enabled);

          IF (get_object_rec.object_type <> 'VALIDITY') THEN
            GMD_API_GRP.Validate_with_dep_entities
                      (get_object_rec.object_type,
                       get_object_rec.object_id,
                       l_dependent_val);
            IF l_dependent_val THEN
              FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
              FND_FILE.NEW_LINE(FND_FILE.LOG,1);
            END IF;
          END IF;

          -- Work thro' each object and call its appropriate APIs
          IF (get_object_rec.object_type = 'FORMULA') THEN
            -- Get the action flag to decide on update or insert(version control)

	    SELECT fm.owner_organization_id
              INTO l_orgn_id
	      FROM fm_form_mst_b fm
	     WHERE fm.formula_id = get_object_rec.object_id;

	    -- Get the Formula version control for the entity orgn.
	    GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => l_orgn_id,
					  P_parm_name  => 'GMD_FORMULA_VERSION_CONTROL',
                                          P_parm_value => l_vers_cntrl,
					  x_return_status => l_return_stat);

            IF (l_vers_cntrl IN ('Y','O')) AND
               (l_version_enabled = 'Y' )  AND (get_object_rec.Version_flag = 'Y') THEN
	       -- NPD Conv. added 100 here
               -- bug #4758484
               -- Enabling frozen formulas to be replaced if version enabled flag is Y
               -- Bug # 5005145 .Changed the Condition for new creating vew version
               IF (l_status_type IN ('100','300','400','600','700','900')) THEN
                l_action_flag := 'I';
               ELSE
                l_action_flag := 'N';
               END IF;
            ELSE -- version flag is off
              IF l_status_type IN ('100','300','400','600','700') THEN
                l_action_flag := 'U';
              ELSE
                l_action_flag := 'N';
              END IF;
            END IF;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line
              ('In MSNR replace : For formula Action flag = '
              ||l_action_flag);
            END IF;

	    IF (l_action_flag = 'N') THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_REPLACE_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
              FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
              FND_MESSAGE.SET_TOKEN('STATUS',get_status_meaning(l_status_type) );
              FND_MSG_PUB.ADD;
              RAISE NO_UPDATE_EXCEPTION;
            END IF;

            -- Convert scale factor to number - applicable in non US number formats
            l_scale_factor := fnd_number.canonical_to_number(get_object_rec.scale_factor);

            -- Construct a PL/SQL table only if action is
            -- either insert ('I') or update ('U')
            -- l_action_flag is I, we need to create PLSQL table for
            -- for both formula header and details


            -- NPD Conv.
	    -- Check if the new item is available in the formula owning orgn.
	    IF (get_object_rec.replace_type = 'INGREDIENT') THEN
		OPEN Cur_check_item(get_object_rec.object_id, get_object_rec.new_name);
		FETCH Cur_check_item INTO l_itm_exists;
		CLOSE Cur_check_item;
		IF l_itm_exists <> 1 THEN
			FND_MESSAGE.SET_NAME('gmd', 'GMD_FORMULA_ITMORG_NOT_FOUND');
			FND_MESSAGE.SET_TOKEN('ITEM',get_item_no(get_object_rec.new_name));
		        FND_MESSAGE.SET_TOKEN('ORGN',get_orgn_code(l_orgn_id));
			FND_MSG_PUB.ADD;
			RAISE NO_UPDATE_EXCEPTION;
		END IF;

	-- Check if the Revision is enabled for the item.
		-- KSHUKLA if the revision control is enabled
	IF pNew_Version is not NULL THEN
		OPEN cur_ITEM_VER_ENABLED(get_object_rec.new_name);
		FETCH cur_ITEM_VER_ENABLED INTO l_item_rev_ctl;
		CLOSE cur_ITEM_VER_ENABLED;
		IF l_item_rev_ctl = 2 THEN
		   -- Rev control is enabled now check for the rev access.
		   OPEN cur_item_ver_access(get_object_rec.object_id, get_object_rec.new_name);
		   FETCH cur_item_ver_access INTO l_rev_access;
                   CLOSE cur_item_ver_access;
		   IF l_rev_access <> 1 THEN
                        -- Bug# 5198213 New message shown for items with revision
		        FND_MESSAGE.SET_NAME('GMD', 'GMD_FORMULA_ITMREV_NOT_FOUND');
			FND_MESSAGE.SET_TOKEN('ITEM',get_item_no(get_object_rec.new_name));
                        FND_MESSAGE.set_token('REV',get_object_rec.new_version );
		        FND_MESSAGE.SET_TOKEN('ORGN',get_orgn_code(l_orgn_id));
			FND_MSG_PUB.ADD;
		        RAISE NO_UPDATE_EXCEPTION;
                   END IF;
                END IF;
	END IF;
       -- END KSHUKLA bug 5198213

		-- Chk if we are trying to substitute an experimental item in Apfgu formula
		IF l_status_type BETWEEN 700 AND 799 THEN
			OPEN Cur_experimental_items(get_object_rec.object_id, get_object_rec.new_name);
			FETCH Cur_experimental_items INTO l_expr_items_found;
			CLOSE Cur_experimental_items;
			IF l_expr_items_found > 0 THEN
				FND_MESSAGE.SET_NAME('GMD', 'GMD_EXPR_ITEMS_FOUND');
				FND_MSG_PUB.ADD;
				RAISE NO_UPDATE_EXCEPTION;
			END IF;
		END IF;
	    END IF;

            IF (l_action_flag IN ('I')) THEN
              -- Create formula header table
              SELECT DECODE(get_object_rec.replace_type,'FORMULA_CLASS'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'INGREDIENT'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'INGREDIENT'
                            ,get_object_rec.old_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'OWNER_ID'
                            ,get_object_rec.new_name
                            ,NULL)
              INTO l_formula_class, l_new_ingredient, l_old_ingredient, l_owner_id
              FROM dual;

              IF (l_debug = 'Y') THEN
                gmd_debug.put_line
                ('In MSNR replace : In Insert mode '
                ||' l_fm_class  = '||l_formula_class
                ||' l_new_ingredient  = '||l_new_ingredient
                ||' l_old_ingredient  = '||l_old_ingredient
                ||' l_owner_id  = '||l_owner_id);
              END IF;
              -- Create a new formula version
              gmd_search_replace_vers.create_new_formula
                (p_formula_id		=>  get_object_rec.object_id
                ,p_formula_class	=>  l_formula_class
                ,p_new_ingredient	=>  l_new_ingredient
                ,p_old_ingredient	=>  l_old_ingredient
		,p_old_ingr_revision	=>  get_object_rec.old_version
		,p_new_ingr_revision	=>  get_object_rec.new_version
                ,p_inactive_ind		=>  NULL
                ,p_owner_id		=>  l_owner_id
                ,x_formula_id		=>  l_formula_id
                ,x_scale_factor		=>  l_scale_factor
                ,pCreate_Recipe		=>  pCreate_Recipe
                 );
               IF l_formula_id IS NULL THEN
                 RAISE No_Update_Exception;
               ELSE
                 SELECT formula_vers
                 INTO   l_object_version
                 FROM   fm_form_mst_b
                 WHERE  formula_id = l_formula_id;
                 -- Setup message to indicate that a new version
                 -- has been created
                 FND_MESSAGE.SET_NAME('GMD','GMD_CONC_NEW_OBJECT_VERSION');
  	         FND_MESSAGE.SET_TOKEN('VERSION',l_object_version);
                 FND_MESSAGE.SET_TOKEN('OBJECT_NAME',get_object_rec.object_name);
                 FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);

                 IF (get_object_rec.replace_type = 'INGREDIENT') THEN
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','LM_INGREDIENT',true);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',
                                          get_item_no(get_object_rec.new_name) );
                 ELSIF (get_object_rec.replace_type = 'OWNER_ID') THEN
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OWNER',true);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',
                                          get_owner_name(get_object_rec.new_name) );
                 ELSE
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',get_object_rec.new_name);
                 END IF;

                 FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
               END IF;

            ELSIF (l_action_flag IN ('U')) THEN
              IF (get_object_rec.replace_type IN ('FORMULA_CLASS','OWNER_ID')) THEN
                UPDATE fm_form_mst_b
                   SET formula_class =  DECODE(get_object_rec.replace_type,'FORMULA_CLASS'
                                              ,get_object_rec.new_name
                                              ,formula_class),
                       owner_id      =  DECODE(get_object_rec.replace_type,'OWNER_ID'
                                              ,get_object_rec.new_name
                                              ,owner_id),
                       last_update_date = P_last_update_date,
                       last_updated_by  = p_last_updated_by,
                       last_update_login  = p_last_update_login
                 WHERE formula_id    = get_object_rec.object_id;
              ELSIF (get_object_rec.replace_type = 'INGREDIENT') THEN
                IF (l_debug = 'Y') THEN
                  gmd_debug.put_line
                  ('In MSNR replace for formula : action flag = '
                  ||l_action_flag
                  ||' and replace type = '
                  ||get_object_rec.replace_type
                  ||' and scale factor = '
                  ||l_scale_factor
                  ||' and new item id = '
                  ||get_object_rec.new_name
                  ||' and user id '
                  ||l_user_id);
                END IF;
		--Bug 5237351 Validate item access
		GMD_COMMON_VAL.CHECK_FORMULA_ITEM_ACCESS(get_object_rec.object_id,
                                    get_object_rec.new_name,
                                    l_return_status ,
				    get_object_rec.new_version);
		IF l_return_status  <> 'S' THEN
                   RAISE NO_UPDATE_EXCEPTION;
		END IF;

                UPDATE fm_matl_dtl
                   SET inventory_item_id	= get_object_rec.new_name,
		       revision			= get_object_rec.new_version,
                       qty			= qty * l_scale_factor,
                       ingredient_end_date      = Null, --bug 4479101
                       last_update_date		= SYSDATE,
                       last_updated_by		= l_user_id
                 WHERE formula_id		= get_object_rec.object_id
                  AND  line_type		= -1
                  AND  inventory_item_id        = get_object_rec.old_name
		  AND  NVL(revision, -1)	= NVL(get_object_rec.old_version, -1);
                -- Raise and exception is replace was not performed
                IF (SQL%NOTFOUND) THEN
                  FND_MESSAGE.SET_NAME('GMD', 'GMD_FORM_UPD_NO_ACCESS');
                  FND_MSG_PUB.ADD;
                  RAISE NO_UPDATE_EXCEPTION;
                END IF;
                -- Item substitution realted fix, Bug 4479101
                FOR my_subs_rec IN Cur_get_substitute_id(get_object_rec.old_name, get_object_rec.object_id) LOOP  --bug 4479101
                  DELETE from gmd_formula_substitution
                  WHERE formula_id = get_object_rec.object_id
                  AND substitution_id = my_subs_rec.substitution_id;
                END LOOP;
              END IF;
            END IF; -- when action_flag is either 'U' or 'I'
          ELSIF (get_object_rec.object_type = 'RECIPE') THEN
            -- Get the action flag to decide on update or insert(version control)
	    SELECT rcp.owner_organization_id
              INTO l_orgn_id
	      FROM gmd_recipes_b rcp
	     WHERE rcp.recipe_id = get_object_rec.object_id;

	    -- Get the Recipe version control for the entity orgn.
	    GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => l_orgn_id,
					  P_parm_name  => 'GMD_RECIPE_VERSION_CONTROL',
                                          P_parm_value => l_vers_cntrl,
					  x_return_status => l_return_stat);

            IF (l_vers_cntrl IN  ('Y','O')) AND
               (l_version_enabled = 'Y' ) AND (get_object_rec.Version_flag = 'Y') THEN
               -- Bug # 5005145 .Changed the Condition for new creating vew version
              IF (l_status_type IN ('300','400'))  THEN
                IF (get_object_rec.replace_type <> 'FORMULA_ID') THEN
                  l_action_flag := 'I';
                ELSE
                  l_action_flag := 'N';
                END IF;
              ELSIF (l_status_type IN ('600','700')  ) THEN
                IF (get_object_rec.replace_type = 'FORMULA_ID') THEN
                  l_action_flag := 'I';  -- kkillams, 'N' is replaced with th 'I' w.r.t. bug 4013844
                                         -- Should allow to update the formula as version control is set YES.
                ELSIF (get_object_rec.replace_type = 'ROUTING_ID') THEN
                  IF ((get_object_rec.old_name IS NULL) AND
                      (get_object_rec.new_name IS NOT NULL) ) THEN
                    l_action_flag := 'I';
                  ELSE
                    l_action_flag := 'N';
                  END IF;
                ELSE -- other columns
                  l_action_flag := 'I';
                END IF;
              ELSE -- for all other status types
                l_action_flag := 'N';
              END IF;
            ELSE -- When version control is off
              IF (l_debug = 'Y') THEN
                gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                        ||' : About check if Recipe update is allowed, Recipe Id  = '
                        ||get_object_rec.object_id);
              END IF;

              IF NOT GMD_API_GRP.Check_orgn_access
                                   (Entity     => 'RECIPE'
                                   ,Entity_id  => get_object_rec.object_id) THEN
                RAISE NO_UPDATE_EXCEPTION;
              ELSE
                IF (l_status_type IN ('200','500','800','900','1000')) THEN
                  l_action_flag := 'N';
                ELSIF (l_status_type IN ('300','400','600','700')) THEN
                  IF (get_object_rec.replace_type = 'FORMULA_ID') THEN
                    l_action_flag := 'N';
                  ELSIF (get_object_rec.replace_type = 'ROUTING_ID') THEN
                    IF (l_status_type IN ('300','400','600') ) THEN
                      l_action_flag := 'U';
                    ELSIF ((get_object_rec.old_name IS NULL) AND
                          (get_object_rec.new_name IS NOT NULL) AND
                          (l_status_type = '700')) THEN
                      l_action_flag := 'U';
                    ELSE
                      l_action_flag := 'N';
                    END IF;
                  END IF; -- check for recipe columns end here
                 END IF; -- check for status type ends here
              END IF; -- check for GMD_API_GRP.Check_orgn_access
            END IF; -- check for version control on / off

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : For Recipe Action flag = '
              ||l_action_flag);
            END IF;

            IF (l_action_flag = 'N') THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_REPLACE_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
              FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
              FND_MESSAGE.SET_TOKEN('STATUS',get_status_meaning(l_status_type) );
              FND_MSG_PUB.ADD;
              RAISE NO_UPDATE_EXCEPTION;
            END IF;

              SELECT DECODE(get_object_rec.replace_type,'FORMULA_ID'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'ROUTING_ID'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'OWNER_ORGN_CODE'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'RECIPE_TYPE'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'OWNER_ID'
                            ,get_object_rec.new_name
                            ,NULL)
              INTO l_formula_id, l_routing_id, l_organization_id, l_recipe_type, l_owner_id
              FROM dual;

	      -- NPD Conv
	     IF (get_object_rec.replace_type = 'OWNER_ORGN_CODE') THEN

		-- Get formula associated with recipe
		OPEN get_formula_id (get_object_rec.object_id);
		FETCH get_formula_id INTO l_form_id;
		CLOSE get_formula_id;

		-- Check if formula items belong to the new recipe organization
		GMD_API_GRP.check_item_exists
                                   (p_formula_id      => l_form_id
                                   ,p_organization_id => l_organization_id
				   ,x_return_status   => l_status );

		IF l_status <> FND_API.g_ret_sts_success THEN
		  -- Bug 5531791 Removed FND_MSG_PUB.GET and FND_MSG_PUB.ADD as the message
		  -- is already added by GMD_API_GRP.check_item_exists
	          RAISE NO_UPDATE_EXCEPTION;
		END IF;

	     END IF;

	     -- NPD Conv
	     IF (get_object_rec.replace_type = 'FORMULA_ID') THEN

		-- Get the recipe owning organization
		OPEN Cur_get_recipe_org(get_object_rec.object_id);
		FETCH Cur_get_recipe_org INTO l_org_id;
		CLOSE Cur_get_recipe_org;

	     	-- Check if new formula's items belong to the recipe organization
		GMD_API_GRP.check_item_exists
                                   (p_formula_id      => l_formula_id
                                   ,p_organization_id => l_org_id
				   ,x_return_status   => l_status );

		IF l_status <> FND_API.g_ret_sts_success THEN
		  -- Bug 5531791 Removed FND_MSG_PUB.GET and FND_MSG_PUB.ADD as the message
		  -- is already added by GMD_API_GRP.check_item_exists
	          RAISE NO_UPDATE_EXCEPTION;
		END IF;
                -- Bug 5531717 add code to check for ovverride orgn
                FOR l_recipe_override_orgn IN Cur_get_recipe_override_org(get_object_rec.object_id)
		LOOP
	     	-- Check if new formula's items belong to the recipe organization
		  GMD_API_GRP.check_item_exists
                                   (p_formula_id      => l_formula_id
                                   ,p_organization_id => l_recipe_override_orgn.organization_id
				   ,x_return_status   => l_status );

		  IF l_status <> FND_API.g_ret_sts_success THEN
                    RAISE NO_UPDATE_EXCEPTION;
		  END IF;
                END LOOP;
	     END IF;

            IF (l_action_flag IN ('I')) THEN

	      GMD_SEARCH_REPLACE_VERS.create_new_recipe
              (p_recipe_id        =>  get_object_rec.object_id
              ,p_routing_id       =>  l_routing_id
              ,p_formula_id       =>  l_formula_id
              ,powner_id          =>  l_owner_id
              ,powner_orgn_code   =>  NULL
	      ,p_Organization_Id  =>  l_organization_id
	      ,p_recipe_type	  =>  l_recipe_type
              ,x_recipe_id        =>  l_recipe_id);

              IF (l_recipe_id IS NULL) THEN
                 RAISE No_Update_Exception;
              ELSE
                 SELECT recipe_version
                 INTO   l_object_version
                 FROM   gmd_recipes_b
                 WHERE  recipe_id = l_recipe_id;

                 -- Setup message to indicate that a new version
                 -- has been created
                 FND_MESSAGE.SET_NAME('GMD','GMD_CONC_NEW_OBJECT_VERSION');
  	         FND_MESSAGE.SET_TOKEN('VERSION',l_object_version);
                 FND_MESSAGE.SET_TOKEN('OBJECT_NAME',get_object_rec.object_name);
                 FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);

                 IF (get_object_rec.replace_type = 'FORMULA_ID' )  THEN
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_FORMULA',true);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',
                                  GMD_API_GRP.get_object_name_version
                                  ('FORMULA'
                                  ,get_object_rec.new_name)
                                  );
                 ELSIF (get_object_rec.replace_type = 'ROUTING_ID' )  THEN
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_ROUTING',true);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',
                                  GMD_API_GRP.get_object_name_version
                                  ('ROUTING'
                                  ,get_object_rec.new_name)
                                  );
                 ELSIF (get_object_rec.replace_type = 'OWNER_ID') THEN
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OWNER',true);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',
                                           get_owner_name(get_object_rec.new_name) );
                 ELSIF (get_object_rec.replace_type = 'RECIPE_TYPE') THEN
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_RECIPE_TYPE',true);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',
                                           get_recipe_type(get_object_rec.new_name) );
                -- Bug# 5234792 To get the recipe type value.
                 ELSE
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',get_object_rec.new_name);
                 END IF;


                 FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
              END IF;

            ELSIF (l_action_flag IN ('U')) THEN
              -- Perform updates
              UPDATE gmd_recipes_b
                 SET formula_id =  DECODE(get_object_rec.replace_type,'FORMULA_ID'
                                         ,get_object_rec.new_name
                                         ,formula_id),
                     routing_id =  DECODE(get_object_rec.replace_type,'ROUTING_ID'
                                         ,get_object_rec.new_name
                                         ,routing_id),
                     owner_id   =  DECODE(get_object_rec.replace_type,'OWNER_ID'
                                         ,get_object_rec.new_name
                                         ,owner_id),
                     owner_organization_id =  DECODE(get_object_rec.replace_type,'OWNER_ORGN_CODE'
                                         ,get_object_rec.new_name
                                         ,owner_organization_id),
		     recipe_type =       DECODE(get_object_rec.replace_type,'RECIPE_TYPE'
                                         ,get_object_rec.new_name
                                         ,recipe_type),
                     last_update_date = P_last_update_date,
                     last_updated_by  = p_last_updated_by,
                     last_update_login  = p_last_update_login
              WHERE recipe_id = get_object_rec.object_id;

              IF (sql%notfound) THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_RCP_UPD_NO_ACCESS');
                FND_MSG_PUB.ADD;
                RAISE NO_UPDATE_EXCEPTION;
              END IF;
              -- Delete all recipe dependencies if either formula or
              -- routing is replaced.
              IF (l_debug = 'Y') THEN
                gmd_debug.put_line(g_pkg_name||'.'||l_api_name||
                         ': About check fm and rout dependency with Recipe = '||
                         get_object_rec.object_id||
                         ' Replace column = '||get_object_rec.replace_type||
                         ' Replace value = '||get_object_rec.new_name);
              END IF;

              IF (get_object_rec.replace_type = 'FORMULA_ID') THEN
                delete_recipe_dependencies(get_object_rec.object_id,'FORMULA');
              ELSIF (get_object_rec.replace_type = 'ROUTING_ID') THEN
                IF (get_object_rec.new_name IS NOT NULL) THEN
                  delete_recipe_dependencies(get_object_rec.object_id,'ROUTING');
                END IF;
              END IF;

              IF (l_debug = 'Y') THEN
                gmd_debug.put_line(g_pkg_name||'.'||l_api_name||
                         ' After checking the fm and rout dep with Recipe ');
              END IF;

            END IF; -- When action flag is either 'U' or 'I'

          ELSIF (get_object_rec.object_type = 'ROUTING') THEN
            -- Get the action flag to decide on update or insert(version control)
	    SELECT rot.owner_organization_id , rot.effective_end_date
              INTO l_orgn_id, l_old_end_date
	      FROM gmd_routings_b rot
	     WHERE rot.routing_id = get_object_rec.object_id;

	    -- Get the Routing version control for the entity orgn.
	    GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => l_orgn_id,
					  P_parm_name  => 'GMD_ROUTING_VERSION_CONTROL',
                                          P_parm_value => l_vers_cntrl,
					  x_return_status => l_return_stat);

            IF (l_vers_cntrl IN ('Y','O')) AND
               (l_version_enabled = 'Y') AND (get_object_rec.Version_flag = 'Y')  THEN
               -- Bug # 5005145 .Changed the Condition for new creating vew version
               IF (l_status_type IN ('400', '700')) THEN
                 l_action_flag := 'I';
               ELSIF ((l_status_type = '900') AND
                      (get_object_rec.replace_type = 'END_DATE') )THEN
                 l_action_flag := 'I';
               ELSE
                 l_action_flag := 'N';
               END IF;
            ELSE
              IF(l_status_type IN ('100','300','400','600','700') ) OR
                  (l_status_type = '900' AND get_object_rec.replace_type = 'END_DATE')THEN
                l_action_flag := 'U';
              ELSE
                l_action_flag := 'N';
              END IF;
           END IF;

            IF (l_debug = 'Y') THEN
              gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                           ||' : For Routing Action flag = '||l_action_flag);
            END IF;

            IF (l_action_flag = 'N') THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_REPLACE_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
              FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
              FND_MESSAGE.SET_TOKEN('STATUS',get_status_meaning(l_status_type) );
              FND_MSG_PUB.ADD;
              RAISE NO_UPDATE_EXCEPTION;
            END IF;

            IF (l_action_flag IN ('I')) THEN
              SELECT DECODE(get_object_rec.replace_type,'START_DATE'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'END_DATE'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'OPRN_ID'
                            ,get_object_rec.old_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'OPRN_ID'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'ROUTING_CLASS'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'OWNER_ID'
                            ,get_object_rec.new_name
                            ,NULL)
              INTO l_start_date, l_end_date, l_old_oprn, l_new_oprn,
                   l_routing_class, l_owner_id
              FROM dual;
         -- Bug# 5493773 Kapil M Pass the old End date
              IF NOT get_object_rec.replace_type = 'END_DATE' THEN
                 l_end_date := FND_DATE.date_to_canonical(l_old_end_date);
              END IF;

              -- Call the insert API
              gmd_search_replace_vers.create_new_routing
              (p_routing_id          =>   get_object_rec.object_id
              ,p_effective_start_date     =>   l_start_date
              ,p_effective_end_date  =>   l_end_date
              ,p_inactive_ind        =>   NULL
              ,p_owner               =>   l_owner_id
              ,p_old_operation       =>   l_old_oprn
              ,p_new_operation       =>   l_new_oprn
              ,p_routing_class       =>   l_routing_class
              ,x_routing_id          =>   l_routing_id
              );

              IF (l_routing_id IS NULL) THEN
                 RAISE No_Update_Exception;
              ELSE
                 SELECT routing_vers
                 INTO   l_object_version
                 FROM   gmd_routings_b
                 WHERE  routing_id = l_routing_id;

                 -- Setup message to indicate that a new version
                 -- has been created
                 FND_MESSAGE.SET_NAME('GMD','GMD_CONC_NEW_OBJECT_VERSION');
  	         FND_MESSAGE.SET_TOKEN('VERSION',l_object_version);
                 FND_MESSAGE.SET_TOKEN('OBJECT_NAME',get_object_rec.object_name);
                 FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);

                 IF (get_object_rec.replace_type = 'OPRN_ID') THEN
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OPERATION',true);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',
                                  GMD_API_GRP.get_object_name_version
                                  ('OPERATION'
                                  ,get_object_rec.new_name)
                                  );
                 ELSIF (get_object_rec.replace_type = 'OWNER_ID') THEN
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OWNER',true);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',
                                  get_owner_name(get_object_rec.new_name) );
                 ELSE
                   FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
                   FND_MESSAGE.SET_TOKEN('NEW_ITEM',get_object_rec.new_name);
                 END IF;

                 FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
              END IF;

            ELSIF (l_action_flag IN ('U')) THEN
              p_rout_update_table(1).p_col_to_update := get_object_rec.replace_type;

              IF (l_debug = 'Y') THEN
                gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : About update Routing '
                                   ||'  Replace type = '
                                   ||get_object_rec.replace_type
                                   ||' new_name = '
                                   ||get_object_rec.new_name
                                   );
              END IF;

              p_rout_update_table(1).p_value := get_object_rec.new_name;

              IF (get_object_rec.replace_type = 'OPRN_ID') THEN
                -- Get the routingstep id
                SELECT RoutingStep_id
                INTO   l_routingStep_id
                FROM   fm_rout_dtl
                WHERE  routing_id = get_object_rec.object_id
                AND    oprn_id    = get_object_rec.old_name;

                IF (l_debug = 'Y') THEN
                  gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                                   ||' : About update Routing - Operation'
                                   ||'  Routing Step id  = '
                                   ||l_routingStep_id
                                   ||' Routing id = '
                                   ||get_object_rec.object_id
                                   ||' old_name = '
                                   ||get_object_rec.old_name
                                   );
                END IF;

                GMD_ROUTING_STEPS_PUB.update_routing_steps
                (p_routingstep_id   => l_routingStep_id
                ,p_routing_id       => get_object_rec.object_id
                ,p_update_table     => p_rout_update_table
                ,x_return_status    => l_return_status
                ,x_message_count    => l_mesg_count
                ,x_message_list     => l_mesg_data
                );

                IF (l_debug = 'Y') THEN
                 gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                                   ||' : After calling Rt Step API '
                                   ||' l_return_status  = '
                                   ||l_return_status
                                   );
                END IF;
              ELSE
                IF (l_debug = 'Y') THEN
                  gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                             ||' : About to call Update Routing API ');
                END IF;

                -- Call the routing API
                GMD_ROUTINGS_PUB.update_routing
                ( p_routing_id      =>  get_object_rec.object_id
                , p_update_table    =>  p_rout_update_table
                , x_message_count   =>  l_mesg_count
                , x_message_list    =>  l_mesg_data
                , x_return_status   =>  l_return_status
                );
              END IF;
              IF (l_return_status <> 'S') THEN
                RAISE No_Update_Exception;
              END IF;
            END IF;-- when action_flag is either 'U' or 'I'

          ELSIF (get_object_rec.object_type = 'OPERATION') THEN
            -- Get the action flag to decide on update or insert(version control)
	    SELECT opr.owner_organization_id
              INTO l_orgn_id
	      FROM gmd_operations_b opr
	     WHERE opr.oprn_id = get_object_rec.object_id;

	    -- Get the Operation version control for the entity orgn.
	    GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => l_orgn_id,
					  P_parm_name  => 'GMD_OPERATION_VERSION_CONTROL',
                                          P_parm_value => l_vers_cntrl,
					  x_return_status => l_return_stat);

            IF (l_vers_cntrl IN ('Y','O')) AND
               (l_version_enabled = 'Y' ) AND (get_object_rec.Version_flag = 'Y') THEN
               -- Bug # 5005145 .Changed the Condition for new creating vew version
               IF (l_status_type IN ('300','400','600','700')) THEN
                 l_action_flag := 'I';
               ELSIF ((l_status_type = 900) AND
                     (get_object_rec.replace_type like '%END_DATE%')) THEN
                 l_action_flag := 'I';
               ELSE
                 l_action_flag := 'N';
               END IF;
            ELSE
              IF(l_status_type IN ('100','300','400','600','700') ) OR
                  ((l_status_type = '900') AND
                   (get_object_rec.replace_type like '%END_DATE%') )THEN
                l_action_flag := 'U';
              ELSE
                l_action_flag := 'N';
              END IF;
            END IF;

            IF (l_debug = 'Y') THEN
                gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                             ||' Version Flag = '
                             ||get_object_rec.version_flag
                             ||' Replace Column = '
                             ||get_object_rec.replace_type
                             ||' Status Type = '
                             ||l_status_type
                             ||' : Action Flag  = '
                             ||l_action_flag);
            END IF;

            IF (l_action_flag = 'N') THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_REPLACE_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
              FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
              FND_MESSAGE.SET_TOKEN('STATUS',get_status_meaning(l_status_type) );
              FND_MSG_PUB.ADD;
              RAISE NO_UPDATE_EXCEPTION;
            END IF;

            IF (l_action_flag IN ('I')) THEN
              SELECT DECODE(get_object_rec.replace_type,'START_DATE'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'END_DATE'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'ACTIVITY'
                            ,get_object_rec.old_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'ACTIVITY'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'OPRN_CLASS'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'RESOURCES'
                            ,get_object_rec.old_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'RESOURCES'
                            ,get_object_rec.new_name
                            ,NULL),
                     DECODE(get_object_rec.replace_type,'OWNER_ORGN_CODE'
                            ,get_object_rec.new_name
                            ,NULL)
              INTO l_start_date, l_end_date, l_old_actv, l_new_actv,
                   l_oprn_class, l_old_resource, l_new_resource, l_organization_id
              FROM dual;

              IF (l_debug = 'Y') THEN
                gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                             ||' : About to call create_new_operation - End Date = '
                             ||l_end_date);
              END IF;

              -- Call the Operation Insert API
              GMD_SEARCH_REPLACE_VERS.create_new_operation
              (  p_oprn_id               =>  get_object_rec.object_id
               , p_old_activity          =>  l_old_actv
               , p_activity              =>  l_new_actv
               , p_effective_start_date  =>  l_start_date
               , p_effective_end_date    =>  l_end_date
               , p_operation_class       =>  l_oprn_class
               , p_inactive_ind          =>  NULL
               , p_old_resource          =>  l_old_resource
               , p_resource              =>  l_new_resource
	       , x_oprn_id               =>  l_oprn_id
               );

               IF l_oprn_id IS NULL THEN
                 RAISE No_Update_Exception;
               ELSE
                 SELECT oprn_vers
                 INTO   l_object_version
                 FROM   gmd_operations_b
                 WHERE  oprn_id = l_oprn_id;

                 -- Setup message to indicate that a new version
                 -- has been created
                 FND_MESSAGE.SET_NAME('GMD','GMD_CONC_NEW_OBJECT_VERSION');
                 FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
  	         FND_MESSAGE.SET_TOKEN('VERSION',l_object_version);
                 FND_MESSAGE.SET_TOKEN('OBJECT_NAME',get_object_rec.object_name);
                 FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
                 FND_MESSAGE.SET_TOKEN('NEW_ITEM',get_object_rec.new_name);
                 FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
               END IF;

            ELSIF (l_action_flag IN ('U')) THEN
              IF (get_object_rec.replace_type
                  IN ('OPRN_CLASS','START_DATE','END_DATE')) THEN
                  p_oprn_update_table(1).P_COL_TO_UPDATE := get_object_rec.replace_type;
                  p_oprn_update_table(1).P_VALUE := get_object_rec.new_name;

                  IF (l_debug = 'Y') THEN
                    gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : Update of Operation '||
                            ' Replace type = '||p_oprn_update_table(1).P_COL_TO_UPDATE||
                            ' and value = '||p_oprn_update_table(1).P_VALUE);
                  END IF;

                  -- Call the operation API
                  GMD_OPERATIONS_PUB.update_operation
                  ( p_oprn_id         =>  get_object_rec.object_id
                  , p_update_table    =>  p_oprn_update_table
                  , x_message_count   =>  l_mesg_count
                  , x_message_list    =>  l_mesg_data
                  , x_return_status   =>  l_return_status
                  );
              ELSIF (get_object_rec.replace_type = 'ACTIVITY') THEN
                  -- Get the oprn_line_id based on the old oprn_id (object_id)
                  -- and old activity (old_name).
                  SELECT oprn_line_id
                  INTO   l_oprn_line_id
                  FROM   gmd_operation_activities
                  WHERE  oprn_id = get_object_rec.object_id
                    AND  activity = get_object_rec.old_name;

                  p_oprn_activity_table(1).P_COL_TO_UPDATE := get_object_rec.replace_type;
                  p_oprn_activity_table(1).P_VALUE         := get_object_rec.new_name;

                  GMD_OPERATION_ACTIVITIES_PUB.update_operation_activity
                  ( p_oprn_line_id     => l_oprn_line_id
                  , p_update_table     => p_oprn_activity_table
                  , X_RETURN_STATUS    => l_return_status      --Return Status
                  , X_MESSAGE_COUNT    => l_mesg_count         --Message Count
                  , X_MESSAGE_LIST     => l_mesg_data          --Message Data
                  );
              ELSIF (get_object_rec.replace_type = 'RESOURCES') THEN
                  -- Get the oprn_line_id based on the old oprn_id (object_id)
                  -- and old resource (old_name).
                  IF (l_debug = 'Y') THEN
                    gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : About replace a resource '
                    ||' in a operation. The oprn_id = '||get_object_rec.object_id||' and'
                    ||' old resource = '||get_object_rec.old_name);
                  END IF;

                  SELECT r.oprn_line_id
                  INTO   l_oprn_line_id
                  FROM   gmd_operation_resources r, gmd_operation_activities a
                  WHERE  a.oprn_id = get_object_rec.object_id
                    AND  r.resources = get_object_rec.old_name
                    AND  a.oprn_line_id = r.oprn_line_id;

                  IF (l_debug = 'Y') THEN
                    gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : The oprn_line_id = '
                    ||l_oprn_line_id||' and'||' new resource = '||get_object_rec.new_name);
                  END IF;

                  p_oprn_resources_table(1).P_COL_TO_UPDATE := get_object_rec.replace_type;
                  p_oprn_resources_table(1).P_VALUE         := get_object_rec.new_name;

                  GMD_OPERATION_RESOURCES_PUB.update_operation_resources
                  ( p_oprn_line_id     => l_oprn_line_id
                  , p_resources		     => get_object_rec.old_name
                  , p_update_table     => p_oprn_resources_table
                  , X_RETURN_STATUS    => l_return_status      --Return Status
                  , X_MESSAGE_COUNT    => l_mesg_count         --Message Count
                  , X_MESSAGE_LIST     => l_mesg_data          --Message Data
                  );
              END IF;

              IF (l_return_status <> 'S') THEN
                RAISE No_Update_Exception;
              END IF;

            END IF;
          ELSIF (get_object_rec.object_type = 'VALIDITY') THEN
            IF (l_debug = 'Y') THEN
              gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : The Vr status = '||l_status_type
                               ||' and replace type = '||get_object_rec.replace_type);
            END IF;
            IF (get_object_rec.replace_type <> 'STATUS') THEN
              -- If status code is On-Hold or obsolete no update is allowed
              IF (l_status_type IN ('200','500','800','1000')) THEN
                l_action_flag := 'N';
              -- If status code is Frozen, no update except End Date is allowed
              ELSIF (l_status_type IN ('900')) AND
                    (get_object_rec.replace_type <> 'END_DATE') THEN
                l_action_flag := 'N';
              END IF;
            END IF;
            IF (l_debug = 'Y') THEN
              gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : The Vr action_flag = '
              ||l_action_flag);
            END IF;

            IF (l_action_flag = 'U') THEN
              OPEN Cur_get_validity(get_object_rec.object_id);
              FETCH Cur_get_validity INTO l_obj_id;
	      CLOSE Cur_get_validity;
              IF NOT GMD_API_GRP.Check_orgn_access
                                   (Entity     => 'RECIPE'
                                   ,Entity_id  => l_obj_id) THEN
                RAISE NO_UPDATE_EXCEPTION;
              END IF;

              -- Currently for Validity Rules we do not provide version
              -- control.  So there would not be any creation of Validity Rules
              If (l_debug = 'Y') THEN
                gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : The update clumn = '||
                                   get_object_rec.replace_type||
                                   ' and update value = '||
                                   get_object_rec.new_name);
              END IF;

	      -- NPD Conv.
	      IF get_object_rec.replace_type = 'ORGN_CODE' THEN
	        p_validity_rules_table(1).p_col_to_update := 'ORGANIZATION_ID';
		p_validity_rules_table(1).p_value         := get_object_rec.new_name;

		-- Get formula associated with recipe for the VR
		OPEN get_recp_formula_id (get_object_rec.object_id);
		FETCH get_recp_formula_id INTO l_form_id;
		CLOSE get_recp_formula_id;

		-- Check if formula items belong to the new organization
		GMD_API_GRP.check_item_exists
                                   (p_formula_id      => l_form_id
                                   ,p_organization_id => get_object_rec.new_name
				   ,x_return_status   => l_status );
		IF l_status <> FND_API.g_ret_sts_success THEN
		  -- Bug 5531791 Removed FND_MSG_PUB.GET and FND_MSG_PUB.ADD as the message
		  -- is already added by GMD_API_GRP.check_item_exists
	          RAISE NO_UPDATE_EXCEPTION;
		END IF;
	      ELSE
                p_validity_rules_table(1).p_col_to_update := get_object_rec.replace_type;
	        p_validity_rules_table(1).p_value         := get_object_rec.new_name;
	      END IF;


              GMD_VALIDITY_RULES_PVT.update_validity_rules
              ( p_validity_rule_id  =>	get_object_rec.object_id
              , p_update_table	    =>  p_validity_rules_table
              , x_message_count     =>  l_mesg_count
              , x_message_list 	    =>  l_mesg_data
              , x_return_status	    =>  l_return_status
              );
              -- check the return status from vr aPI
              IF (l_return_status <> 'S') THEN
                RAISE No_Update_Exception;
              END IF;
            ELSIF (l_action_flag = 'N') THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_REPLACE_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
              FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
              FND_MESSAGE.SET_TOKEN('STATUS',get_status_meaning(l_status_type) );
              FND_MSG_PUB.ADD;
              RAISE NO_UPDATE_EXCEPTION;
            END IF; -- for action flags for VRs
          END IF; -- After working thro' every object type condition
        END IF;   -- replace type is checked for 'STATUS'

        -- Provide a log entry after any entity instance is successfully replaced
        -- Bug# 5234792 Kapil M
        -- Log for Update of existing version only
        IF ((l_return_status = 'S')AND (l_action_flag = 'U')) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT');
           FND_MESSAGE.SET_TOKEN('OBJECT_NAME',get_object_rec.object_name);

           IF (get_object_rec.replace_type = 'INGREDIENT') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','LM_INGREDIENT',true);
	     IF get_object_rec.new_version IS NULL THEN
	  	l_item_txt := get_item_no(get_object_rec.new_name);
	     ELSE
	 	l_item_txt := get_item_no(get_object_rec.new_name) ||' , '|| fnd_message.GET_STRING('INV', 'REVISION') || ' : '||get_object_rec.new_version;
	     END IF;
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE', l_item_txt );
           ELSIF (get_object_rec.replace_type = 'STATUS') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_STATUS',true);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   get_status_meaning(
                                   GMD_API_GRP.get_object_status_type
                                   (get_object_rec.object_type
                                  , get_object_rec.object_id)
                                  ) );
           ELSIF (get_object_rec.replace_type = 'ROUTING_ID') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_ROUTING',true);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   GMD_API_GRP.get_object_name_version
                                   ('ROUTING',get_object_rec.new_name)
                                   );
           ELSIF (get_object_rec.replace_type = 'OPRN_ID') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OPERATION',true);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   GMD_API_GRP.get_object_name_version
                                   ('OPERATION',get_object_rec.new_name)
                                   );
           ELSIF (get_object_rec.replace_type = 'FORMULA_ID') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_FORMULA',true);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   GMD_API_GRP.get_object_name_version
                                   ('FORMULA',get_object_rec.new_name)
                                   );
           ELSIF (get_object_rec.replace_type = 'OWNER_ID') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OWNER',true);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   get_owner_name(get_object_rec.new_name) );
           ELSIF (get_object_rec.replace_type = 'RECIPE_USE') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   get_recipe_use(get_object_rec.new_name) );
           -- Bug# 5234792 Kapil M
           -- To get the recipe type value
           ELSIF (get_object_rec.replace_type = 'RECIPE_TYPE') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   get_recipe_type(get_object_rec.new_name) );
           ELSIF ((get_object_rec.replace_type like '%START_DATE%') OR
                   (get_object_rec.replace_type like '%END_DATE%') ) THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   FND_DATE.canonical_to_date(get_object_rec.new_name) );
	   -- 5532058 If replace_type is 'OWNER_ORGN_CODE', display orgn code
           ELSIF (get_object_rec.replace_type = 'OWNER_ORGN_CODE') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   get_orgn_code(get_object_rec.new_name) );

           ELSE
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',get_object_rec.new_name);
           END IF;

           FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',pObject_type);
           FND_MESSAGE.SET_TOKEN('OBJECT_VERS',get_object_rec.object_vers);
            -- to be removed
           -- fnd_msg_pub.add;
        END IF;

         FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
         FND_FILE.NEW_LINE(FND_FILE.LOG,1);

         -- Set the row counter
         l_rowcount := l_rowcount + 1;
         gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : Within loop for Row # '
                             ||l_rowcount);
      EXCEPTION
        WHEN NO_UPDATE_EXCEPTION THEN
        -- Bug# 5008299 Kapil M
        -- Passing fnd_msg_pub.Count_Msg to get the top most message
          fnd_msg_pub.get
          (p_msg_index     => fnd_msg_pub.Count_Msg
          ,p_data          => l_error_text
          ,p_encoded       => 'F'
          ,p_msg_index_out => l_dummy_cnt
          );

          ret_code := 2;
          err_buf := NULL;
          l_retval := fnd_concurrent.set_completion_status('WARNING',l_error_text);

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                               ||' : In the No_update_exception section '
                               ||' Error text is '||l_error_text);
          END IF;
          FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT_FAILED');

          IF (get_object_rec.replace_type = 'INGREDIENT') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','LM_INGREDIENT',true);
	    IF get_object_rec.new_version IS NULL THEN
		l_item_txt := get_item_no(get_object_rec.new_name);
	    ELSE
		l_item_txt := get_item_no(get_object_rec.new_name) ||' , '|| fnd_message.GET_STRING('INV', 'REVISION') || ' : '||get_object_rec.new_version;
	    END IF;
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE', l_item_txt );
          ELSIF (get_object_rec.replace_type = 'STATUS') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_STATUS',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_status_meaning(get_object_rec.new_name) );
          ELSIF (get_object_rec.replace_type = 'ROUTING_ID') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_ROUTING',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  GMD_API_GRP.get_object_name_version
                                  ('ROUTING'
                                  ,get_object_rec.new_name)
                                  );
          ELSIF (get_object_rec.replace_type = 'OPRN_ID') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OPERATION',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  GMD_API_GRP.get_object_name_version
                                  ('OPERATION'
                                  ,get_object_rec.new_name)
                                  );
          ELSIF (get_object_rec.replace_type = 'FORMULA_ID') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_FORMULA',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  GMD_API_GRP.get_object_name_version
                                  ('FORMULA'
                                  ,get_object_rec.new_name)
                                  );
          ELSIF (get_object_rec.replace_type = 'OWNER_ID') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OWNER',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_owner_name(get_object_rec.new_name) );
          ELSIF (get_object_rec.replace_type = 'RECIPE_USE') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_recipe_use(get_object_rec.new_name) );
          ELSIF ((get_object_rec.replace_type like '%START_DATE%') OR
                   (get_object_rec.replace_type like '%END_DATE%') ) THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   FND_DATE.canonical_to_date(get_object_rec.new_name) );
	  ELSIF (get_object_rec.replace_type IN ('ORGN_CODE', 'OWNER_ORGN_CODE')) THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_orgn_code(get_object_rec.new_name) );

          ELSE
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',get_object_rec.new_name);
          END IF;

          FND_MESSAGE.SET_TOKEN('OBJECT_NAME',get_object_rec.object_name);
          FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
          FND_MESSAGE.SET_TOKEN('OBJECT_VERS',get_object_rec.object_vers);
          FND_MESSAGE.SET_TOKEN('ERRMSG',l_error_text);
          FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG,1);
        WHEN OTHERS THEN

          ret_code := 2;
          err_buf := NULL;
          l_retval := fnd_concurrent.set_completion_status('WARNING',sqlerrm);

          fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
          FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT_FAILED');

          IF (get_object_rec.replace_type = 'INGREDIENT') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','LM_INGREDIENT',true);
	    IF get_object_rec.new_version IS NULL THEN
		l_item_txt := get_item_no(get_object_rec.new_name);
	    ELSE
		l_item_txt := get_item_no(get_object_rec.new_name) ||' , '|| fnd_message.GET_STRING('INV', 'REVISION') || ' : '||get_object_rec.new_version;
	    END IF;
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE', l_item_txt );
          ELSIF (get_object_rec.replace_type = 'STATUS') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_STATUS',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_status_meaning(get_object_rec.new_name) );
          ELSIF (get_object_rec.replace_type = 'ROUTING_ID') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_ROUTING',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  GMD_API_GRP.get_object_name_version
                                  ('ROUTING'
                                  ,get_object_rec.new_name)
                                  );
          ELSIF (get_object_rec.replace_type = 'OPRN_ID') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OPERATION',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  GMD_API_GRP.get_object_name_version
                                  ('OPERATION'
                                  ,get_object_rec.new_name)
                                  );
          ELSIF (get_object_rec.replace_type = 'FORMULA_ID') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_FORMULA',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  GMD_API_GRP.get_object_name_version
                                  ('FORMULA'
                                  ,get_object_rec.new_name)
                                  );
          ELSIF (get_object_rec.replace_type = 'OWNER_ID') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE','GMD_OWNER',true);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_owner_name(get_object_rec.new_name) );
          ELSIF (get_object_rec.replace_type = 'RECIPE_USE') THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_recipe_use(get_object_rec.new_name) );
          ELSIF ((get_object_rec.replace_type like '%START_DATE%') OR
                   (get_object_rec.replace_type like '%END_DATE%') ) THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                   FND_DATE.canonical_to_date(get_object_rec.new_name) );
	  ELSIF (get_object_rec.replace_type IN ('ORGN_CODE', 'OWNER_ORGN_CODE')) THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_orgn_code(get_object_rec.new_name) );
          ELSE
             FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',get_object_rec.replace_type);
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',get_object_rec.new_name);
          END IF;

          FND_MESSAGE.SET_TOKEN('OBJECT_NAME',get_object_rec.object_name);
          FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',get_object_rec.object_type);
          FND_MESSAGE.SET_TOKEN('OBJECT_VERS',get_object_rec.object_vers);
          FND_MESSAGE.SET_TOKEN('ERRMSG',SQLERRM);
          FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
          FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END;    -- End created to handle exception for each record


    END LOOP; -- For all rows that needs to be replaced

    -- If MSNR was successful until here then
    -- Delete rows specific to this concurrent id
    IF (pConcurrent_id IS NOT NULL) THEN
      DELETE
      FROM gmd_msnr_results
      WHERE  concurrent_id = pconcurrent_id;
      COMMIT;
    END IF;

    -- There were no row selected for replace raise an error
    IF (l_rowcount = 0) THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_NO_ROW_FOUND');
      Raise No_Replace_Exception;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(g_pkg_name||'.'||l_api_name||'Completed '||l_api_name ||' at '
                 ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

 EXCEPTION
   -- this exception occurs when no rows were selected for update.
   WHEN NO_REPLACE_EXCEPTION THEN
     fnd_msg_pub.get
      (p_msg_index     => 1
      ,p_data          => l_error_text
      ,p_encoded       => 'F'
      ,p_msg_index_out => l_dummy_cnt
      );

      ret_code := 2;
      err_buf := NULL;
      l_retval := fnd_concurrent.set_completion_status('WARNING',l_error_text);

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line(g_pkg_name||'.'||l_api_name
                           ||' : In the No_replace_exception section '
                           ||' Error text is '||l_error_text);
      END IF;
      FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
   -- outer excepption handles all error that occur prior to or after
   -- Mass updates (or within LOOP above)

   WHEN OTHERS THEN

      ret_code := 2;
      err_buf := NULL;
      l_retval := fnd_concurrent.set_completion_status('WARNING',sqlerrm);

      fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);
      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT_FAILED');
      FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',pReplace_type);
      IF (pReplace_type = 'INGREDIENT') THEN
          FND_MESSAGE.SET_TOKEN('REPLACE_VALUE', get_item_no(pNew_name) );
      ELSIF (preplace_type = 'STATUS') THEN
             FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',get_status_meaning(pnew_name) );
      ELSIF (pReplace_type IN ('ORGN_CODE', 'OWNER_ORGN_CODE')) THEN
            FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',
                                  get_orgn_code(pnew_name) );
      ELSE
          FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',pnew_name);
      END IF;
      FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',pObject_type);
      FND_MESSAGE.SET_TOKEN('ERRMSG',SQLERRM);
      FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);

 END Mass_Replace_Operation;


 /*###############################################################
  # NAME
  #	Validate_All_Replace_Rows
  # SYNOPSIS
  #	Validate_All_Replace_Rows
  # DESCRIPTION
  #    Validates each row that has been choosen for replace.
  #    Called by forms prior to submiting request for Mass replace
  ###############################################################*/
  PROCEDURE Validate_All_Replace_Rows(pObject_type      IN  VARCHAR2,
                                     pReplace_type     IN  VARCHAR2,
                                     pOld_Name         IN  VARCHAR2,
                                     pRows_Processed   OUT NOCOPY NUMBER,
                                     x_return_status   OUT NOCOPY VARCHAR2) IS
  -- all related to dynamic sql
  l_api_name       VARCHAR2(100)  := 'Validate_All_Replace_Rows';

  l_replace_type    VARCHAR2(100);
  l_cursor_id       int;
  l_Row_count       NUMBER;
  l_rows_processed  NUMBER;
  l_dynamic_select  VARCHAR2(2000);
  l_dsql_debug      VARCHAR2(2000);
  l_table_name      VARCHAR2(100);
  l_primary_key     VARCHAR2(100);

  CURSOR get_select_id  IS
    Select object_id
    From   Gmd_MSNR_Results
    Where  concurrent_id IS NULL
    And    object_select_ind = 1;

   VALIDATION_FAILED_EXCEPTION  EXCEPTION;
 BEGIN

     SAVEPOINT validate_all_rows;
     x_return_status := 'S';

     SELECT count(*)
     INTO   l_row_count
     FROM   Gmd_MSNR_Results
     WHERE  object_select_ind = 1
     AND    Concurrent_id IS NULL;

     SELECT DECODE(pObject_type,
                  'FORMULA','FM_FORM_MST_B',
                  'RECIPE','GMD_RECIPES_B',
                  'OPERATION','GMD_OPERATIONS_B',
                  'ROUTING','GMD_ROUTINGS_B',
                  'VALIDITY','GMD_RECIPE_VALIDITY_RULES'),
            DECODE(pObject_type,
                  'FORMULA','FORMULA_ID',
                  'RECIPE','RECIPE_ID',
                  'OPERATION','OPRN_ID',
                  'ROUTING','ROUTING_ID',
                  'VALIDITY','RECIPE_VALIDITY_RULE_ID')
     INTO l_table_name, l_primary_key
     FROM sys.dual;

     l_replace_type := pReplace_type;

     IF (l_debug = 'Y') THEN
       gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : l_replace_type = '||l_replace_type||
                          ' and l_table_name = '||l_table_name);
     END IF;

     IF (pObject_type = 'FORMULA') THEN
       IF (pReplace_type = 'STATUS') THEN
         l_replace_type := 'FORMULA_STATUS';
       ELSIF (pReplace_type = 'INGREDIENT') THEN
         l_replace_type := 'FORMULA_ID';
       END IF;

     ELSIF (pObject_type = 'RECIPE') THEN
       IF (pReplace_type = 'STATUS') THEN
         l_replace_type := 'RECIPE_STATUS';
       ELSIF (pReplace_type = 'OWNER_ORGN_CODE') THEN
         l_replace_type := 'OWNER_ORGANIZATION_ID';
       END IF;

     ELSIF (pObject_type = 'ROUTING') THEN
       IF (pReplace_type = 'STATUS') THEN
         l_replace_type := 'ROUTING_STATUS';
       ELSIF (pReplace_type = 'START_DATE') THEN
         l_replace_type := 'EFFECTIVE_START_DATE';
       ELSIF (pReplace_type = 'END_DATE') THEN
         l_replace_type := 'EFFECTIVE_END_DATE';
       ELSIF (pReplace_type = 'OPRN_ID') THEN
         l_replace_type := 'ROUTING_ID';
       END IF;

     ELSIF (pObject_type = 'OPERATION') THEN
       IF (pReplace_type = 'STATUS') THEN
         l_replace_type := 'OPERATION_STATUS';
       ELSIF (pReplace_type = 'ACTIVITY') THEN
         l_replace_type := 'OPRN_ID';
       ELSIF (pReplace_type = 'RESOURCES') THEN
         l_replace_type := 'OPRN_ID';
       ELSIF (pReplace_type = 'START_DATE') THEN
         l_replace_type := 'EFFECTIVE_START_DATE';
       ELSIF (pReplace_type = 'END_DATE') THEN
         l_replace_type := 'EFFECTIVE_END_DATE';
       END IF;

     ELSIF (pObject_type = 'VALIDITY') THEN
       IF (pReplace_type = 'STATUS') THEN
         l_replace_type := 'VALIDITY_RULE_STATUS';
       ELSIF (pReplace_type = 'ORGN_CODE') THEN
         l_replace_type := 'ORGANIZATION_ID';
       END IF;

     END IF;

     fnd_dsql.init;
     fnd_dsql.add_text(  ' Update Gmd_MSNR_Results '||
                         ' Set Object_select_ind = 0 '||
                         ' Where concurrent_id IS NULL '||
                         ' And Object_select_ind = 1 '||
                         ' And object_id NOT IN  ( Select object_id '||
                                                 ' From Gmd_MSNR_Results, '||l_table_name||
                                                 ' Where '||l_primary_key||' = object_id'||
                                                 ' And concurrent_id IS NULL '||
                                                 ' And Object_select_ind = 1' );
     IF (pOld_Name = ' ' or pOld_name IS NULL) THEN
       IF l_Replace_type IN ('END_DATE'
                            ,'EFFECTIVE_END_DATE'
                            ,'PLANNED_PROCESS_LOSS'
                            ,'ORGANIZATION_ID'
			    ,'OWNER_ORGANIZATION_ID'
                            ,'OPRN_CLASS'
                            ,'ROUTING_CLASS'
                            ,'ROUTING_ID'
                            ,'FORMULA_CLASS') THEN
         fnd_dsql.add_text( ' And '||l_replace_type||' IS NULL )');
       ELSE
         -- pOld_Name cannot be null
         FND_MESSAGE.SET_NAME('GMD','GMD_NO_ASSIGN_VALUE_EXCEPTION');
         FND_MSG_PUB.ADD;
         RAISE VALIDATION_FAILED_EXCEPTION;
       END IF;
     ELSE
       fnd_dsql.add_text( ' And '||l_replace_type||' IN (');

       IF (pReplace_type = 'INGREDIENT') THEN
         fnd_dsql.add_text(' SELECT FORMULA_ID FROM FM_MATL_DTL
                             WHERE LINE_TYPE = -1
                             AND   INVENTORY_ITEM_ID   = ');
         fnd_dsql.add_bind(pOld_name);
         fnd_dsql.add_text(' ))');
       ELSIF (pReplace_type = 'ACTIVITY') THEN
         fnd_dsql.add_text(' SELECT OPRN_ID FROM GMD_OPERATION_ACTIVITIES
                             WHERE ACTIVITY = ');
         fnd_dsql.add_bind(pOld_name);
         fnd_dsql.add_text(' ))');
       ELSIF (pReplace_type = 'RESOURCES') THEN
         fnd_dsql.add_text(' SELECT OPRN_ID
                             FROM GMD_OPERATION_ACTIVITIES a, GMD_OPERATION_RESOURCES r
                             WHERE a.OPRN_LINE_ID = r.OPRN_LINE_ID
                             AND   r.RESOURCES = ');
         fnd_dsql.add_bind(pOld_name);
         fnd_dsql.add_text(' ))');
       ELSIF ((pObject_type = 'ROUTING') AND (pReplace_type = 'OPRN_ID'))THEN
         fnd_dsql.add_text(' SELECT ROUTING_ID
                             FROM FM_ROUT_DTL
                             WHERE OPRN_ID = ');
         fnd_dsql.add_bind(pOld_name);
         fnd_dsql.add_text(' ))');
       ELSIF ((pObject_type = 'RECIPE') AND (pReplace_type = 'OWNER_ORGANIZATION_ID'))THEN
         fnd_dsql.add_text(' SELECT RECIPE_ID
                             FROM GMD_RECIPES_B
                             WHERE OWNER_ORGANIZATION_ID = ');
         fnd_dsql.add_bind(pOld_name);
         fnd_dsql.add_text(' ))');
       ELSIF ((pObject_type = 'VALIDITY') AND (pReplace_type = 'ORGANIZATION_ID'))THEN
         fnd_dsql.add_text(' SELECT recipe_validity_rule_id
                             FROM GMD_RECIPE_VALIDITY_RULES
                             WHERE ORGANIZATION_ID = ');
         fnd_dsql.add_bind(pOld_name);
         fnd_dsql.add_text(' ))');
       ELSIF (pReplace_type IN ('START_DATE','END_DATE')) THEN
         fnd_dsql.add_bind(fnd_date.displaydt_to_date(pOld_name));
         fnd_dsql.add_text(' ))');
       ELSE
         fnd_dsql.add_bind(pOld_name);
         fnd_dsql.add_text(' ))');
       END IF;

     END IF;

     l_cursor_id := dbms_sql.open_cursor;
     fnd_dsql.set_cursor(l_cursor_id);
     l_dynamic_select := fnd_dsql.get_text(FALSE);

     l_dsql_debug := fnd_dsql.get_text(TRUE);
     IF (l_debug = 'Y') THEN
       gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : l_dsql_debug = '||l_dsql_debug);
     END IF;

     dbms_sql.parse(l_cursor_id, l_dynamic_select, dbms_sql.native);
     fnd_dsql.do_binds;

     pRows_Processed := dbms_sql.execute(l_cursor_id);

     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : Rows fetched = '||pRows_Processed||
                            ' and Original select cnt = '||l_row_count);
     END IF;

     dbms_sql.close_cursor(l_cursor_id); -- close cursor

     IF (l_debug = 'Y') THEN
       gmd_debug.put_line(g_pkg_name||'.'||l_api_name||' : pRows_Processed = '||pRows_Processed);
     END IF;

     -- If all rows processed it actually means that none of the
     -- rows selected met the initial criteria, so we rollback all changes
     IF (l_row_count = pRows_Processed) THEN
       ROLLBACK to SAVEPOINT validate_all_rows;
     END IF;

 EXCEPTION
   WHEN VALIDATION_FAILED_EXCEPTION THEN
     x_return_status := 'E';
   WHEN OTHERS THEN
     ROLLBACK to SAVEPOINT validate_all_rows;
     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(g_pkg_name||'.'||l_api_name
         ||' : When Others for Validate_all_rep_rows, Error '||
         sqlerrm);
     END IF;
     x_return_status := 'U';
     fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name);

 END Validate_All_Replace_rows;

END;

/
