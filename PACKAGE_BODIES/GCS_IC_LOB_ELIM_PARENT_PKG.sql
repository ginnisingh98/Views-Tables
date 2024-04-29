--------------------------------------------------------
--  DDL for Package Body GCS_IC_LOB_ELIM_PARENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_IC_LOB_ELIM_PARENT_PKG" AS
/* $Header: gcsiclbb.pls 120.3 2007/02/01 21:55:10 skamdar noship $*/

--
-- Package
--   CREATE_ELIM_PARENT_LOB
-- Purpose
--   Creates the elimination parent elimination line of business.
-- History
--   17-AUG-04    Srini Pala       Created
--

-- Public variables

     g_pkg_name       VARCHAR2(80)          := 'gcs.plsql.GCS_IC_LOB_ELIM_PARENT_PKG';
     g_nl             CONSTANT VARCHAR2(1)  := fnd_global.newline;
     g_no_rows        NUMBER                := 0;
     g_fnd_user_id    NUMBER                := fnd_global.user_id;
     g_fnd_login_id   NUMBER                := fnd_global.login_id;


   -- Bug fix : 5257413, removed the parameter values_set_id

   PROCEDURE  CREATE_ELIM_PARENT_LOB (p_errbuf  OUT NOCOPY  VARCHAR2,
                                      p_retcode OUT NOCOPY  VARCHAR2,
                                      p_hierarchy_name   IN VARCHAR2,
                                      p_hierarchy_obj_id IN VARCHAR2,
                                      p_version_name     IN VARCHAR2
                                     ) IS

   l_api_name               VARCHAR2(50) := 'CREATE_ELIM_PARENT_LOB';
   l_version_id             NUMBER ;
   l_vs_display_code        VARCHAR2(150);
   req_id                   NUMBER;
   l_hier_obj_name          VARCHAR2(150);
   l_hier_obj_def_dis_name  VARCHAR2(150);
   l_submit_req             NUMBER :=0;
   l_existing_hier_dis_name VARCHAR2(150);
    -- bug fix : 5257413
   l_hierarchy_obj_def_id   NUMBER;
   l_attribute_id           NUMBER;

   l_value_set_id           NUMBER;
   l_elims_const   CONSTANT VARCHAR2(20) := ' Eliminations';


   NO_USER_DIM1_PROC_KEY         EXCEPTION;
   CONSOLIDATION_GVSC_UNDEFINED  EXCEPTION;

   x_return_status 	varchar2(100);
   x_msg_count 		number;
   x_msg_data 		varchar2(4000);

   --Bugfix 5851171: Removed check to only retrieve enabled parent values, as elim lobs are required for even disabled parents
   CURSOR c_additional_lobs IS
      SELECT   DISTINCT
               fudb.value_set_id,
               fudb.user_dim1_display_code || l_elims_const elim_lob_display_code,
               fudb.enabled_flag,
               fudb.personal_flag,
               fudb.read_only_flag,
               fudb.object_version_number
      FROM     fem_user_dim1_b     fudb,
               fem_user_dim1_hier  fudh
      WHERE    fudh.hierarchy_obj_def_id   = l_hierarchy_obj_def_id
      AND      fudh.parent_id              <> fudh.child_id
      AND      fudh.parent_value_set_id    = fudb.value_set_id
      AND      fudb.user_dim1_id           = fudh.parent_id
      AND      NOT EXISTS
                 (SELECT 'X'
                     FROM fem_user_dim1_attr fuda
                    WHERE fuda.value_set_id  = fudb.value_set_id
                      AND fuda.user_dim1_id  = fudb.user_dim1_id
                      AND fuda.attribute_id  = l_attribute_id
                      AND fuda.version_id    = l_version_id);

   BEGIN

     -- Bugfix 5257413: Added some logging information
     fnd_file.put_line(fnd_file.log, '.............Beginning of Concurrent Program.............');
     fnd_file.put_line(fnd_file.log, '.............Beginning of Parameter Listing.............');
     fnd_file.put_line(fnd_file.log, 'Hierarchy Identifier: ' || p_hierarchy_obj_id);
     fnd_file.put_line(fnd_file.log, 'Version Name        : ' || p_version_name);
     fnd_file.put_line(fnd_file.log, 'Hierarchy Name      : ' || p_hierarchy_name);
     fnd_file.put_line(fnd_file.log, '.............End of Parameter Listing.............');

     -- Bug fix : 5257413, Start
     -- Checking if the User Dimension-01 is a part of the Processing Key
     BEGIN
       --SKAMDAR: Ensure user dimension 1 is enabled for processing
       --Prior check was made against fem_tab_column_prop but we can go straight to utility package
       IF (gcs_utility_pkg.g_gcs_dimension_info('USER_DIM1_ID').required_for_gcs = 'N') THEN
         RAISE NO_USER_DIM1_PROC_KEY;
       END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RAISE NO_USER_DIM1_PROC_KEY;
     END;

     BEGIN

       SELECT attribute_id
        INTO  l_attribute_id
        FROM  fem_dim_attributes_b
        WHERE dimension_id            = 19
        AND   attribute_varchar_label = 'ELIMINATION_LOB';

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             FEM_DIM_ATTRIBUTES_UTIL_PKG.CREATE_ATTRIBUTE(
                           x_attribute_id                 => l_attribute_id
                          ,x_msg_count                    => x_msg_count
                          ,x_msg_data                     => x_msg_data
                          ,x_return_status                => x_return_status
                          ,p_api_version                  => 1.0
                          ,p_commit                       => FND_API.G_TRUE
                          ,p_attr_varchar_label           => 'ELIMINATION_LOB'
                          ,p_attr_name                    => 'Elimination Line of Business'
                          ,p_attr_description             => 'Elimination Line of Business'
                          ,p_dimension_varchar_label      => 'USER_DIM1'
                          ,p_allow_mult_versions_flag     => 'N'
                          ,p_queryable_for_reporting_flag => 'Y'
                          ,p_use_inheritance_flag         => 'N'
                          ,p_attr_order_type_code         => 'NOMINAL'
                          ,p_allow_mult_assign_flag       => 'N'
                          ,p_personal_flag                => 'N'
                          ,p_attr_data_type_code          => 'DIMENSION'
                          ,p_attr_dimension_varchar_label => 'USER_DIM1'
                          ,p_version_display_code         => 'Default'
                          ,p_version_name                 => 'Default'
                          ,p_version_description          => 'Default Verison' );


    END;

    -- SKAMDAR: Retrieve Version Value for Attribute
    SELECT version_id
    INTO   l_version_id
    FROM   fem_dim_attr_versions_b
    WHERE  attribute_id         = l_attribute_id
    AND    default_version_flag = 'Y';

    fnd_file.put_line(fnd_file.log, '.............Beginning of Attribute Information.............');
    fnd_file.put_line(fnd_file.log, 'Attribute Identifier: ' || l_attribute_id);
    fnd_file.put_line(fnd_file.log, 'Version Identifier  : ' || l_version_id);
    fnd_file.put_line(fnd_file.log, '.............End of Attribute Information.............');

    --SKAMDAR: Modifying select statement to use version_name passed into the concurrent program
    SELECT  object_definition_id
     INTO   l_hierarchy_obj_def_id
     FROM   fem_object_definition_vl
    WHERE   object_id      = p_hierarchy_obj_id
      AND   display_name   = p_version_name;

    -- Retreiving the value_set_id of user dimension-1
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.STRING (fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                           'Retreive the value_set_id of user dimension-1' );
    END IF;

    --SKAMDAR: Information can be retrieved from the utility package rather than executing a select against fem tables
    BEGIN

      l_value_set_id := gcs_utility_pkg.g_gcs_dimension_info('USER_DIM1_ID').associated_value_set_id;

      SELECT value_set_display_code
        INTO l_vs_display_code
        FROM fem_value_sets_b fvsb
       WHERE fvsb.value_set_id = l_value_set_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --If no data is found then the consolidation chart of accounts has not been assigned
        RAISE  CONSOLIDATION_GVSC_UNDEFINED;
    END;

    fnd_file.put_line(fnd_file.log, '.............Beginning of Hierarchy Information.............');
    fnd_file.put_line(fnd_file.log, 'Hierarchy Object Def Identifier: ' || l_hierarchy_obj_def_id);
    fnd_file.put_line(fnd_file.log, 'Value Set Identifier           : ' || l_value_set_id);
    fnd_file.put_line(fnd_file.log, 'Value Set Display Code         : ' || l_vs_display_code);
    fnd_file.put_line(fnd_file.log, '.............End of Hierarchy Information.............') ;


    fnd_file.put_line(fnd_file.log, '.............Beginning Generation of Eliminations LOBs (_B Records).............');
    g_no_rows := 0;
    --SKAMDAR: Can change this into bulk statement in future.
    FOR v_additional_lobs IN c_additional_lobs LOOP
      INSERT INTO fem_user_dim1_b
                (user_dim1_id,
                 value_set_id,
                 user_dim1_display_code,
                 enabled_flag,
                 personal_flag,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 read_only_flag,
                 object_version_number,
                 dimension_group_id)
      SELECT     fnd_flex_values_s.nextval,
                 v_additional_lobs.value_set_id,
                 v_additional_lobs.elim_lob_display_code,
                 v_additional_lobs.enabled_flag,
                 v_additional_lobs.personal_flag,
                 sysdate,
                 g_fnd_user_id,
                 g_fnd_user_id,
                 sysdate,
                 g_fnd_login_id,
                 v_additional_lobs.read_only_flag,
                 v_additional_lobs.object_version_number,
                 NULL
      FROM       DUAL;

      g_no_rows := g_no_rows + 1;

    END LOOP;

    fnd_file.put_line(fnd_file.log, '# of rows: ' || g_no_rows);
    fnd_file.put_line(fnd_file.log, '.............Completed Generation of Eliminations LOBs (_B Records).............');

    fnd_file.put_line(fnd_file.log, '.............Beginning Generation of Eliminations LOBs (_TL Records).............');

    INSERT INTO fem_user_dim1_tl
                (user_dim1_id,
                value_set_id,
                language,
                source_lang,
                user_dim1_name,
                description,
                creation_date,
                created_by,
                last_updated_by,
                last_update_date,
                last_update_login)
        SELECT  fudb.user_dim1_id,
                fudb.value_set_id,
                fl.language_code,
                userenv('LANG'),
                fudb.user_dim1_display_code,
                fudb.user_dim1_display_code,
                sysdate,
                g_fnd_user_id,
                g_fnd_user_id,
                sysdate,
                g_fnd_login_id
         FROM   fem_user_dim1_b fudb,
                fnd_languages fl
        WHERE   fl.installed_flag in ('I', 'B')
          AND   fudb.user_dim1_display_code like '%'||l_elims_const
          AND   NOT EXISTS
                (SELECT  'X'
                   FROM  fem_user_dim1_tl fudt
                  WHERE  fudt.user_dim1_id = fudb.user_dim1_id
                    AND  fudt.language     = fl.language_code);

    g_no_rows := NVL(SQL%ROWCOUNT,0);

    fnd_file.put_line(fnd_file.log, '# of rows: ' || g_no_rows);
    fnd_file.put_line(fnd_file.log, '.............Completed Generation of Eliminations LOBs (_TL Records).............');

    fnd_file.put_line(fnd_file.log, '.............Beginning Generation of Eliminations LOBs (_ATTR Records).............');

    INSERT INTO fem_user_dim1_attr
                  (attribute_id,
                  version_id,
                  user_dim1_id,
                  value_set_id,
                  creation_date,
                  created_by,
                  last_updated_by,
                  last_update_date,
                  last_update_login,
                  object_version_number,
                  aw_snapshot_flag,
                  dim_attribute_numeric_member,
                  dim_attribute_varchar_member
                  )
    SELECT       fdab.attribute_id,
                 fdavb.version_id,
                 fudb.user_dim1_id,
                 fudb.value_set_id,
                 sysdate,
                 g_fnd_user_id,
                 g_fnd_user_id,
                 sysdate,
                 g_fnd_login_id,
                 1,
                'N',
                DECODE(fdab.attribute_varchar_label, 'SOURCE_SYSTEM_CODE', fdab.default_assignment, NULL),
                DECODE(fdab.attribute_varchar_label, 'RECON_LEAF_NODE_FLAG', fdab.default_assignment, NULL)
    FROM        fem_dim_attributes_b     fdab,
                fem_dim_attr_versions_b  fdavb,
                fem_user_dim1_b          fudb
    WHERE       fudb.value_set_id            =  l_value_set_id
    AND         fudb.user_dim1_display_code  LIKE  '%'||l_elims_const
    AND         fdab.dimension_id            = 19
    AND         fdab.attribute_id            = fdavb.attribute_id
    AND         fdavb.default_version_flag   = 'Y'
    AND         fdab.attribute_varchar_label IN ('SOURCE_SYSTEM_CODE', 'RECON_LEAF_NODE_FLAG')
    AND         NOT EXISTS (SELECT 'X'
                              FROM  fem_user_dim1_attr fuda
                              WHERE  fuda.attribute_id   = fdavb.attribute_id
                              AND  fuda.version_id     = fdavb.version_id
                              AND  fuda.user_dim1_id   = fudb.user_dim1_id
                              AND  fuda.value_set_id   = fudb.value_set_id);

    g_no_rows   := NVL(SQL%ROWCOUNT,0);

    fnd_file.put_line(fnd_file.log, '# of rows: ' || g_no_rows);
    fnd_file.put_line(fnd_file.log, '.............Completed Generation of Eliminations LOBs (_ATTR Records).............');

    fnd_file.put_line(fnd_file.log, '.............Beginning Generation of Elimination Attributes.............');
    INSERT INTO fem_user_dim1_attr(
                  attribute_id,
                  version_id,
                  user_dim1_id,
                  value_set_id,
                  dim_attribute_numeric_member,
                  creation_date,
                  created_by,
                  last_updated_by,
                  last_update_date,
                  last_update_login,
                  object_version_number,
                  aw_snapshot_flag)
    SELECT        DISTINCT
                  l_attribute_id,
                  l_version_id,
                  fudb.user_dim1_id,
                  fudb.value_set_id,
                  fudb1.user_dim1_id,
                  sysdate,
                  g_fnd_user_id,
                  g_fnd_user_id,
                  sysdate,
                  g_fnd_login_id ,
                  1,
                  'N'
    FROM          fem_user_dim1_hier fudh,
                  fem_user_dim1_b fudb,
                  fem_user_dim1_b fudb1
    WHERE         fudh.hierarchy_obj_def_id                  = l_hierarchy_obj_def_id
    AND           fudh.parent_id                             <> fudh.child_id
    AND           fudh.parent_id                             = fudb.user_dim1_id
    AND           fudh.parent_value_set_id                   = fudb.value_set_id
    AND           fudb.value_set_id                          = fudb1.value_set_id
    AND           fudb.user_dim1_display_code||l_elims_const = fudb1.user_dim1_display_code
    AND           NOT EXISTS
                  (SELECT 'X'
                     FROM fem_user_dim1_attr fuda1
                    WHERE fuda1.attribute_id  = l_attribute_id
                      AND fuda1.version_id    = l_version_id
                      AND fuda1.user_dim1_id  = fudb.user_dim1_id
                      AND fuda1.value_set_id  = fudb.value_set_id);

    g_no_rows   := NVL(SQL%ROWCOUNT,0);

    fnd_file.put_line(fnd_file.log, '# of rows: ' || g_no_rows);
    fnd_file.put_line(fnd_file.log, '.............Completed Generation of Elimination Attributes .............');

    INSERT INTO fem_hierarchies_t
                (hierarchy_object_name,
                 folder_name,
                 language,
                 dimension_varchar_label,
                 hierarchy_type_code,
                 group_sequence_enforced_code,
                 multi_top_flag,
                 multi_value_set_flag,
                 hierarchy_usage_code,
                 flattened_rows_flag,
                 status,
                 hier_obj_def_display_name ,
                 effective_start_date,
                 effective_end_date)
    SELECT       p_hierarchy_name,
                 'Default',
                 USERENV('LANG'),
                 'USER_DIM1',
                 'OPEN',
                 'NO_GROUPS',
                 fh.multi_top_flag,
                 fh.multi_value_set_flag,
                 'STANDARD',
                 'Y',
                 'LOAD',
                 p_version_name,
                 fodb.effective_start_date,
                 fodb.effective_end_date
    FROM         fem_object_definition_b fodb,
                 fem_hierarchies fh
    WHERE        fodb.object_definition_id = l_hierarchy_obj_def_id
    AND          fodb.object_id            = fh.hierarchy_obj_id;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'Insert new hierarchy value set '
                     ||'  into FEM_HIER_VALUE_SETS_T ');
    END IF;

    INSERT INTO  fem_hier_value_sets_t
                (hierarchy_object_name,
                 value_set_display_code,
                 language,
                 status)
         VALUES (p_hierarchy_name,
                 l_vs_display_code,
                 USERENV('LANG'),
                 'LOAD'
                );

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'Insert existing hierarchy members '
                     ||'  into fem_user_dim1_hier_T ');
    END IF;

    INSERT INTO fem_user_dim1_hier_t
               (hierarchy_object_name,
                hierarchy_obj_def_display_name,
                parent_display_code,
                parent_value_set_display_code,
                child_display_code,
                child_value_set_display_code,
                display_order_num,
                status,
                language)
         SELECT p_hierarchy_name,
                p_version_name,
                parent.user_dim1_display_code,
                l_vs_display_code,
                child.user_dim1_display_code,
                l_vs_display_code,
                1,
                'LOAD',
                USERENV('LANG')
          FROM  fem_user_dim1_hier fudh,
                fem_object_definition_tl fodt,
                fem_object_catalog_tl foct,
                fem_user_dim1_b parent,
                fem_user_dim1_b child
         WHERE  fudh.hierarchy_obj_def_id = l_hierarchy_obj_def_id
           AND  fudh.hierarchy_obj_def_id = fodt.object_definition_id
           AND  fodt.language             = userenv('LANG')
           AND  fodt.object_id            = foct.object_id
           AND  foct.language             = userenv('LANG')
           AND  parent_value_set_id       = l_value_set_id
           AND  child_value_set_id        = l_value_set_id
           AND  fudh.parent_id            = parent.user_dim1_id
           AND  fudh.child_id             = child.user_dim1_id
           AND  fudh.single_depth_flag    = 'Y';

    l_submit_req := SQL%ROWCOUNT;
    g_no_rows    := NVL(SQL%ROWCOUNT,0);

    INSERT INTO  fem_user_dim1_hier_t
                (hierarchy_object_name,
                 hierarchy_obj_def_display_name,
                 parent_display_code,
                 parent_value_set_display_code,
                 child_display_code,
                 child_value_set_display_code,
                 display_order_num,
                 status,
                 language)
    SELECT       DISTINCT
                 p_hierarchy_name,
                 p_version_name,
                 fudh.parent_display_code,
                 l_vs_display_code,
                 fudh.parent_display_code ||l_elims_const,
                 l_vs_display_code ,
                 1,
                 'LOAD',
                 USERENV('LANG')
    FROM         fem_user_dim1_hier_t fudh
    WHERE        fudh.hierarchy_object_name              = p_hierarchy_name
    AND          fudh.hierarchy_obj_def_display_name     = p_version_name
    AND          fudh.parent_display_code                <> fudh.child_display_code
    AND          fudh.parent_value_set_display_code      = fudh.child_value_set_display_code;

    g_no_rows   := NVL(SQL%ROWCOUNT,0);

    COMMIT;

     -- Submit Dimension hierarchy loader.
    fnd_file.put_line(fnd_file.log, '.............Beginning Submission of EPF Hierarchy Loader.............');
    IF (l_submit_req >= 1) THEN
       req_id :=  fnd_request.submit_request(
                                        application     => 'FEM',
                                        program         => 'FEM_HIER_LOADER',
                                        sub_request     => FALSE,
                                        argument1       => 1400,  -- p_obj_defn_id
                                        argument2       => 'S',  -- p_exec_mode
                                        argument3       => 'USER_DIM1',
                                        argument4       => p_hierarchy_name,
                                        argument5       => p_version_name);
       COMMIT;

       fnd_file.put_line(fnd_file.log, 'Request Identifier: ' || req_id);
       fnd_file.put_line(fnd_file.log, '.............Completed Submission of EPF Hierarchy Loader.............');

       IF req_id <= 0 THEN
         p_errbuf  :=  FND_MESSAGE.get;
         p_retcode := '2';
       END IF;
     END IF;

    EXCEPTION
      WHEN NO_USER_DIM1_PROC_KEY THEN
        fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<<<Beginning of Error>>>>>>>>>>>>>>>>>>>>>>>>>>>');
        fnd_file.put_line(fnd_file.log, 'User Dimension 1 must be part of the consolidation processing key in order to run this program.');
        fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<<<<<End of Error>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
        p_errbuf := 'User Dimension 1 must be part of the consolidation processing key in order to run this program.';
        p_retcode := 2;
     WHEN CONSOLIDATION_GVSC_UNDEFINED THEN
        fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<<<Beginning of Error>>>>>>>>>>>>>>>>>>>>>>>>>>>');
        fnd_file.put_line(fnd_file.log, 'The consolidation chart of accounts must be assigned before running this program.');
        fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<<<<<End of Error>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
        p_errbuf  := 'The consolidation chart of accounts must be assigned before running this program.';
        p_retcode := 2;
     WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<<<Beginning of Error>>>>>>>>>>>>>>>>>>>>>>>>>>>');
        fnd_file.put_line(fnd_file.log, SQLERRM);
        fnd_file.put_line(fnd_file.log, '<<<<<<<<<<<<<<<<<<<<<<<<End of Error>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
        p_errbuf  := SUBSTR(SQLERRM, 1, 255);
        p_retcode := 2;
        ROLLBACK;


   END CREATE_ELIM_PARENT_LOB;



END GCS_IC_LOB_ELIM_PARENT_PKG;

/
