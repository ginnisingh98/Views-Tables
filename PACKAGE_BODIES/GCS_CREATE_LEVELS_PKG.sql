--------------------------------------------------------
--  DDL for Package Body GCS_CREATE_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CREATE_LEVELS_PKG" AS
/* $Header: gcslevelb.pls 120.2 2005/09/15 18:25:05 skamdar noship $ */
     -- Store the log level
     runtimeLogLevel     NUMBER := FND_LOG.g_current_runtime_level;
     statementLogLevel   CONSTANT NUMBER := FND_LOG.level_statement;
     procedureLogLevel   CONSTANT NUMBER := FND_LOG.level_procedure;
     exceptionLogLevel   CONSTANT NUMBER := FND_LOG.level_exception;
     errorLogLevel       CONSTANT NUMBER := FND_LOG.level_error;
     unexpectedLogLevel  CONSTANT NUMBER := FND_LOG.level_unexpected;

     g_src_sys_code NUMBER := GCS_UTILITY_PKG.g_gcs_source_system_code;


   PROCEDURE Gcs_Create_Level (
		errbuf       OUT NOCOPY VARCHAR2,
		retcode      OUT NOCOPY VARCHAR2,
                p_level_exists OUT NOCOPY VARCHAR2,
                p_sequence_num NUMBER,
		p_dimension  VARCHAR2,
                p_hierarchy_name   VARCHAR2,
                p_analysis_flag    VARCHAR2 ) IS

        stmt           VARCHAR2(10000);
        level_flag     NUMBER;
        l_btable       VARCHAR2(30);
        l_displaycol   VARCHAR2(30);
        max_depth      NUMBER;
        phase          VARCHAR2(80);
        status         VARCHAR2(80);
        dev_phase      VARCHAR2(80);
        dev_status     VARCHAR2(80);
        message        VARCHAR2(240) ;
        parent         VARCHAR2(30);
        l_call_status  BOOLEAN;
        -- p_level_exists VARCHAR2(1);

        l_req_id      NUMBER;
        l_dim_id      NUMBER;
        l_value_set_id NUMBER;

        -- l_req_id   NUMBER := FND_GLOBAL.conc_request_id;
        -- l_login_id NUMBER := FND_GLOBAL.login_id;
        -- l_user_id  NUMBER := FND_GLOBAL.user_id;

	module	  VARCHAR2(30) := 'GCS_CREATE_LEVELS';

        CURSOR get_parent IS
          SELECT child_display_code
           FROM  gcs_hier_members_t
           WHERE parent_display_code = child_display_code
             AND sequence_num = p_sequence_num;

        --Exception handlers: everything that can go wrong here
        SUBMISSION_FAILED    EXCEPTION;
        REQUEST_ERROR        EXCEPTION;
        NO_VALUE_SET_FOUND   EXCEPTION;

   BEGIN

     runtimeLogLevel := FND_LOG.g_current_runtime_level;

     IF (procedureloglevel >= runtimeloglevel ) THEN
    	 FND_LOG.STRING(procedureloglevel, 'gcs.plsql.gcs_create_levels_pkg.gcs_create_level.begin' || GCS_UTILITY_PKG.g_module_enter, to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
     END IF;
     IF (statementloglevel >= runtimeloglevel ) THEN
          FND_LOG.STRING(statementloglevel, 'gcs.plsql.gcs_create_levels_pkg.gcs_create_level', 'p_dimension = ' || p_dimension);
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter || 'Gcs_Create_Levels' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

     -- Set the dimension table info
     IF ( p_dimension = 'COMPANY_COST_CENTER_ORG') THEN
       l_btable := 'FEM_CCTR_ORGS_B';
       l_displaycol := 'cctr_org_display_code';
     ELSIF ( p_dimension = 'FINANCIAL_ELEMENT' ) THEN
       l_btable := 'FEM_FIN_ELEMS_B';
       l_displaycol := 'financial_elem_display_code';
     ELSIF ( p_dimension = 'PRODUCT') THEN
       l_btable := 'FEM_PRODUCTS_B';
       l_displaycol := 'product_display_code';
     ELSIF ( p_dimension = 'NATURAL_ACCOUNT' ) THEN
       l_btable := 'FEM_NAT_ACCTS_B';
       l_displaycol := 'natural_account_display_code';
     ELSIF ( p_dimension = 'CHANNEL') THEN
       l_btable := 'FEM_CHANNELS_B';
       l_displaycol := 'channel_display_code';
     ELSIF ( p_dimension = 'LINE_ITEM') THEN
       l_btable := 'FEM_LN_ITEMS_B';
       l_displaycol := 'line_item_display_code';
     ELSIF ( p_dimension = 'PROJECT') THEN
       l_btable := 'FEM_PROJECTS_B';
       l_displaycol := 'project_display_code';
     ELSIF ( p_dimension = 'CUSTOMER') THEN
       l_btable := 'FEM_CUSTOMERS_B';
       l_displaycol := 'customer_display_code';
     ELSIF ( p_dimension = 'ENTITY') THEN
       l_btable := 'FEM_ENTITIES_B ';
       l_displaycol := 'entity_display_code';
     ELSIF ( p_dimension = 'TASK') THEN
       l_btable := 'FEM_TASKS_B';
       l_displaycol := 'task_display_code';
     ELSIF ( p_dimension = 'USER_DIM10') THEN
       l_btable := 'FEM_USER_DIM10_B';
       l_displaycol := 'user_dim10_display_code';
     ELSIF ( p_dimension like 'USER_DIM%') THEN
       l_btable := 'FEM_USER_DIM' || substr(p_dimension, 9) || '_B' ;
       l_displaycol := 'user_dim' || substr(p_dimension, 9) || '_display_code';
     END IF;


    -- Shouldn't need this but I noticed some strange behavior on fin115p1 so adding this delete
    DELETE FROM GCS_EPB_LEVELS_GT;

    -- fetch the parents and populate the temp table for each parent
    OPEN get_parent;
    LOOP
     -- get the parent
     FETCH get_parent INTO parent;
     EXIT WHEN get_parent%NOTFOUND OR get_parent%NOTFOUND IS NULL;

     -- insert into global temp table
     INSERT INTO GCS_EPB_LEVELS_GT
     ( dim_display_code, dim_value_set_display_code, dim_group_display_code, dim_group_level)
     SELECT DISTINCT hier.parent_display_code, hier.parent_vs_display_code, p_dimension || level*100, level*100
      FROM GCS_HIER_MEMBERS_T hier
      WHERE hier.sequence_num = p_sequence_num
      START WITH hier.parent_display_code = parent
      AND hier.child_display_code <> parent
      CONNECT BY PRIOR hier.child_display_code = hier.parent_display_code;
    END LOOP;
    CLOSE get_parent;

     -- Get the max depth for the child nodes
     SELECT max(dim_group_level) + 100
      INTO max_depth
      FROM GCS_EPB_LEVELS_GT;

     -- Insert the level info for leaf nodes in the temp table
     INSERT INTO GCS_EPB_LEVELS_GT
     ( dim_display_code, dim_value_set_display_code, dim_group_display_code, dim_group_level )
     SELECT DISTINCT hier.child_display_code, hier.child_vs_display_code, p_dimension || max_depth, max_depth
      FROM GCS_HIER_MEMBERS_T hier
      WHERE hier.sequence_num = p_sequence_num
       AND child_display_code NOT IN
         ( SELECT parent_display_code
            FROM GCS_HIER_MEMBERS_T
           WHERE sequence_num = p_sequence_num );

     SELECT dimension_id
       INTO l_dim_id
       FROM FEM_DIMENSIONS_B
       WHERE dimension_varchar_label = p_dimension;

     -- Delete orphan records from the _T table
     DELETE FROM fem_dimension_grps_b_t
     WHERE dimension_varchar_label = p_dimension
       AND dimension_group_display_code IN
                ( SELECT dimension_group_display_code FROM GCS_EPB_LEVELS_GT );

     DELETE FROM fem_dimension_grps_tl_t
      WHERE dimension_varchar_label = p_dimension
        AND dimension_group_display_code IN
                ( SELECT dimension_group_display_code FROM GCS_EPB_LEVELS_GT );

     -- Populate the dimension groups interface tables
     INSERT INTO fem_dimension_grps_b_t
        (dimension_group_display_code,
         dimension_varchar_label,
         dimension_group_seq,
         status)
     SELECT DISTINCT
        dim_group_display_code,
        p_dimension,
        dim_group_level,
        'LOAD'
     FROM GCS_EPB_LEVELS_GT;

     INSERT INTO fem_dimension_grps_tl_t
       (dimension_group_display_code,
        language,
        dimension_group_name,
        description,
        status,
        dimension_varchar_label)
     SELECT DISTINCT
       dim_group_display_code,
       userenv('LANG'),
       dim_group_display_code,
       dim_group_display_code,
       'LOAD',
       p_dimension
     FROM GCS_EPB_LEVELS_GT;

     FEM_DIM_MEMBER_LOADER_PKG.Main(
         errbuf => errbuf,
         retcode => retcode,
         p_execution_mode => 'S',
         p_dimension_id => l_dim_id);

     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Gcs_Create_Levels : dim loader status = '
        || retcode
        || '     '
        || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));


     -- Check whether levels conflict with existing assigned levels
     stmt := 'SELECT count(*)
     FROM ' || l_btable || ' dimb, fem_dimension_grps_b dimgrpb, gcs_epb_levels_gt tempsp, fem_value_sets_b val
     WHERE nvl(dimb.dimension_group_id, dimgrpb.dimension_group_id) <> dimgrpb.dimension_group_id
     AND tempsp.dim_group_display_code = dimgrpb.dimension_group_display_code
     AND tempsp.dim_display_code = dimb.' || l_displaycol || ' AND dimb.value_set_id = val.value_set_id AND val.value_set_display_code = tempsp.dim_value_set_display_code ';

     EXECUTE IMMEDIATE stmt INTO level_flag;

     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Gcs_Create_Levels : Dimension _B table =  ' || l_btable );
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Gcs_Create_Levels : Dimension display column =  ' || l_displaycol );
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Gcs_Create_Levels : Conflicting level row count =  ' || to_char(level_flag) );

     IF ( level_flag) = 0 THEN
        p_level_exists := 'N';
     ELSE
        p_level_exists := 'Y';
     END IF;

   errbuf := 'Conflicting levels exist';

     -- Continue only if there are no conflicting levels

   IF ( p_level_exists = 'N') THEN

     -- Insert data into fem_hier_dim_grps_t

     IF p_analysis_flag = 'Y' THEN

       -- get rid of orphan records
       DELETE FROM fem_hier_dim_grps_t
         WHERE hierarchy_object_name = p_hierarchy_name
           AND dimension_group_display_code IN
            ( SELECT dimension_group_display_code FROM GCS_EPB_LEVELS_GT );

       INSERT INTO fem_hier_dim_grps_t (
                  hierarchy_object_name,
                  language,
                  status,
                  dimension_group_display_code)
        SELECT DISTINCT p_hierarchy_name,
                      USERENV('LANG'),
                      'LOAD',
                      levelgt.dim_group_display_code
                FROM  GCS_EPB_LEVELS_GT levelgt;
     END IF;

     IF retcode is null or retcode <> '2' THEN

          stmt := 'UPDATE ' || l_btable || ' dimb SET dimb.dimension_group_id =
              (SELECT grp.dimension_group_id
              FROM GCS_EPB_LEVELS_GT hier, FEM_VALUE_SETS_B val, FEM_DIMENSION_GRPS_B grp
              WHERE grp.dimension_group_display_code = hier.dim_group_display_code
                AND hier.dim_value_set_display_code = val.value_set_display_code
                AND val.value_set_id = dimb.value_set_id
                AND hier.dim_display_code = dimb.' || l_displaycol || ')
              WHERE dimb.' || l_displaycol || ' IN
                    ( SELECT dim_display_code FROM GCS_EPB_LEVELS_GT)
                AND dimb.value_set_id IN
                     ( SELECT val2.value_set_id
                       FROM GCS_EPB_LEVELS_GT hier2, FEM_VALUE_SETS_B val2
                       WHERE hier2.dim_value_set_display_code = val2.value_set_display_code) ';


          EXECUTE IMMEDIATE stmt;

          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Gcs_Create_Levels : Update rows =  ' || to_char(SQL%ROWCOUNT));

     END IF;
   END IF; -- if p_level_exists is 'N'

     EXCEPTION
       WHEN SUBMISSION_FAILED THEN
         --An error msg is placed on the stack at the exception raise point
         --A logString call is made at the exception raise point
         errbuf    := FND_MESSAGE.get;
         retcode   := '0';
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_EPB_CREATE_LEVELS_PKG.GCS_EPB_CREATE_LEVEL', 'SUBMISSION_FAILED');
         END IF;
         RAISE;
      WHEN REQUEST_ERROR THEN
         --An error msg is placed on the stack at the exception raise point
         --A logString call is made at the exception raise point
         errbuf    := FND_MESSAGE.get;
         retcode   := '0';
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_EPB_CREATE_LEVELS_PKG.GCS_EPB_CREATE_LEVEL', 'REQUEST_ERROR');
         END IF;
         RAISE;

       WHEN NO_DATA_FOUND THEN
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_EPB_CREATE_LEVELS_PKG.GCS_EPB_CREATE_LEVEL', 'GCS_NO_DATA_FOUND');
         END IF;
         retcode := '0';
         errbuf := 'GCS_NO_DATA_FOUND';
         RAISE NO_DATA_FOUND;

       WHEN OTHERS THEN
         errbuf := substr( SQLERRM, 1, 2000);
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, 'gcs.plsql.GCS_EPB_CREATE_LEVELS_PKG.GCS_EPB_CREATE_LEVEL', errbuf);
         END IF;
         retcode := '0';
         RAISE;


  END Gcs_Create_Level;

END GCS_CREATE_LEVELS_PKG;

/
