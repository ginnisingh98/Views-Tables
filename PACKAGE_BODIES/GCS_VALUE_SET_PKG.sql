--------------------------------------------------------
--  DDL for Package Body GCS_VALUE_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_VALUE_SET_PKG" AS
/* $Header: gcsvsetb.pls 120.2 2006/01/06 06:57:58 mikeward noship $ */
 new_line VARCHAR2(4) := '
 ';
 g_api			VARCHAR2(80)	:=	'gcs.plsql.GCS_VALUE_SET_PKG';

 g_entity_type_attr_id 	NUMBER := 	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id;
 g_entity_type_version_id	NUMBER :=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').version_id;

 PROCEDURE  create_entity_value_set(x_errbuf	OUT NOCOPY VARCHAR2,
                            				x_retcode	OUT NOCOPY VARCHAR2)

 IS

   l_flex_value_set_id		NUMBER(10);

 BEGIN

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.create_entity_value_set.begin', '<<Enter>>');
   END IF;

   fnd_file.put_line(fnd_file.log, 'Creating Entity Value Set for ICM Integration.');

   SELECT flex_value_set_id
   INTO   l_flex_value_set_id
   FROM   fnd_flex_value_sets
   WHERE  flex_value_set_name = 'FCH_ICM_ENTITY_VALUE_SET';

   MERGE INTO fnd_flex_values ffv
   USING (SELECT feb.entity_id,
                 feb.entity_display_code,
                 decode(fea.dim_attribute_varchar_member,'C','Y','N') summary_flag
          FROM   fem_entities_b feb,
                 fem_entities_attr fea
          WHERE  feb.value_set_id = 18
          AND    fea.entity_id = feb.entity_id
          AND    fea.attribute_id = g_entity_type_attr_id
          AND    fea.version_id =  g_entity_type_version_id
         ) entity
   ON (ffv.flex_value_id = entity.entity_id)
   WHEN MATCHED THEN
     UPDATE SET flex_value = entity.entity_display_code,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
   WHEN NOT MATCHED THEN
     INSERT(flex_value_set_id,
            flex_value_id,
            flex_value,
            enabled_flag,
            summary_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)
     VALUES(l_flex_value_set_id,
            entity.entity_id,
            entity.entity_display_code,
            'Y',
            entity.summary_flag,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id);

   MERGE INTO fnd_flex_values_tl ffvt
   USING (SELECT fet.entity_id,
                 fet.entity_name,
                 fet.description,
                 fet.language,
                 fet.source_lang
          FROM   fem_entities_tl fet
          WHERE  fet.value_set_id = 18
         ) entity
   ON (ffvt.flex_value_id = entity.entity_id AND
       ffvt.language = entity.language)
   WHEN MATCHED THEN
     UPDATE SET flex_value_meaning = entity.entity_name,
                description = entity.entity_name,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
   WHEN NOT MATCHED THEN
     INSERT(flex_value_id,
            language,
            source_lang,
            flex_value_meaning,
            description,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)
     VALUES(entity.entity_id,
            entity.language,
            entity.source_lang,
            entity.entity_name,
            entity.entity_name,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id);

   COMMIT;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.create_entity_value_set.end', '<<Exit>>');
   END IF;
   fnd_file.put_line(fnd_file.log, 'End of Entity Value Set creation for ICM Integration.');

   EXCEPTION
     WHEN OTHERS THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_ERROR) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR, g_api || '.create_entity_value_set.error', SQLERRM);
       END IF;
       fnd_file.put_line(fnd_file.log, SUBSTR(SQLERRM,1,200));

 END create_entity_value_set;

 PROCEDURE  recurse_hierarchy( p_hierarchy_id		     IN NUMBER,
                               p_entity_id		       IN NUMBER,
                               p_eff_date            IN VARCHAR2,
                               p_entity_display_code IN VARCHAR2,
                               p_flex_value_set_id   IN NUMBER )
 IS

   CURSOR c_child_entity ( p_hierarchy_id            NUMBER,
                           p_entity_id               NUMBER,
                           p_eff_date                VARCHAR2)
   IS
          SELECT gcr.child_entity_id,
                 feb.entity_display_code child_entity_display_code,
                 fea.dim_attribute_varchar_member child_entity_type_code
          FROM   gcs_cons_relationships gcr,
                 fem_entities_b feb,
                 fem_entities_attr fea
          WHERE  gcr.hierarchy_id = p_hierarchy_id
          AND    gcr.parent_entity_id = p_entity_id
          AND    TO_DATE(p_eff_date,'DD-MM-YYYY') BETWEEN gcr.start_date AND NVL(gcr.end_date, TO_DATE(p_eff_date,'DD-MM-YYYY'))
          AND    gcr.dominant_parent_flag = 'Y'
          AND    feb.entity_id = gcr.child_entity_id
          AND    fea.entity_id = gcr.child_entity_id
          AND    fea.attribute_id = g_entity_type_attr_id
          AND    fea.version_id   = g_entity_type_version_id;
 BEGIN

   FOR v_temp IN c_child_entity ( p_hierarchy_id,
                                  p_entity_id,
                                  p_eff_date)
   LOOP

       INSERT INTO fnd_flex_value_norm_hierarchy ( flex_value_set_id,
                                                   parent_flex_value,
                                                   range_attribute,
                                                   child_flex_value_low,
                                                   child_flex_value_high,
                                                   creation_date,
                                                   created_by,
                                                   last_update_date,
                                                   last_updated_by,
                                                   last_update_login,
                                                   start_date_active,
                                                   end_date_active)
        VALUES                                   ( p_flex_value_set_id,
                                                   p_entity_display_code,
                                                   decode(v_temp.child_entity_type_code,
                                                          'C', 'P',
                                                          'C'),
                                                   v_temp.child_entity_display_code,
                                                   v_temp.child_entity_display_code,
                                                   sysdate,
                                                   fnd_global.user_id,
                                                   sysdate,
                                                   fnd_global.user_id,
                                                   fnd_global.login_id,
                                                   null,
                                                   null);

         IF (v_temp.child_entity_type_code = 'C') THEN

             recurse_hierarchy( p_hierarchy_id,
                                v_temp.child_entity_id,
                                p_eff_date,
                                v_temp.child_entity_display_code,
                                p_flex_value_set_id
                               );

         END IF;

   END LOOP;
   EXCEPTION
     WHEN OTHERS THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_ERROR) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR, g_api || '.create_value_set_hierarchy.recurse_error', 'Value Set Id:'||p_flex_value_set_id||' Hierarchy Id:'||p_hierarchy_id ||' Entity Id:'|| p_entity_id	||'-'||SQLERRM);
       END IF;
       fnd_file.put_line(fnd_file.log, 'Recurse error '||SUBSTR(SQLERRM,1,200));
 END recurse_hierarchy;

 PROCEDURE  create_entity_value_set_hier( x_errbuf	   OUT NOCOPY VARCHAR2,
                            			x_retcode	   OUT NOCOPY VARCHAR2,
                                          p_eff_date     IN         VARCHAR2 )

 IS

   l_hierarchy_id		      NUMBER(15);
   l_top_entity_id		    NUMBER;
   l_entity_display_code  VARCHAR2(150);
   l_flex_value_set_id		NUMBER(10);
   l_request_id           NUMBER(15);
 BEGIN

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.create_entity_value_set_hier.begin', '<<Enter>>');
   END IF;

   fnd_file.put_line(fnd_file.log, 'Creating Entity Value Set Hierarchy for ICM Integration.');

   SELECT ghb.hierarchy_id,
          ghb.top_entity_id,
          feb.entity_display_code
   INTO   l_hierarchy_id,
          l_top_entity_id,
          l_entity_display_code
   FROM   gcs_hierarchies_b ghb,
          fem_entities_b feb
   WHERE  ghb.certification_flag = 'Y'
   AND    feb.entity_id = ghb.top_entity_id;

   SELECT flex_value_set_id
   INTO   l_flex_value_set_id
   FROM   fnd_flex_value_sets
   WHERE  flex_value_set_name = 'FCH_ICM_ENTITY_VALUE_SET';

   DELETE fnd_flex_value_norm_hierarchy
   WHERE  flex_value_set_id = l_flex_value_set_id;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.create_entity_value_set_hier.recurse_hierarchy', '<<Exit>>');
   END IF;
   fnd_file.put_line(fnd_file.log, 'Start Recursive Entity Value Set Hierarchy creation for ICM Integration.');

   recurse_hierarchy( l_hierarchy_id,
                      l_top_entity_id,
                      p_eff_date,
                      l_entity_display_code,
                      l_flex_value_set_id
                    );

   COMMIT;

    -- Compile value set hierarchies
   l_request_id :=     fnd_request.submit_request( application     => 'FND',
                                                   program         => 'FDFCHY',
                                                   sub_request     => FALSE,
                                                   argument1       => l_flex_value_set_id);


   GCS_ICM_INTG_PROF_PKG.launch_fin_stmt_import;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.create_entity_value_set_hier.end', '<<Exit>>');
   END IF;
   fnd_file.put_line(fnd_file.log, 'End of Entity Value Set Hierarchy creation for ICM Integration.');

   EXCEPTION
     WHEN OTHERS THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_ERROR) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR, g_api || '.create_entity_value_set_hier.error', SQLERRM);
       END IF;
       fnd_file.put_line(fnd_file.log, SUBSTR(SQLERRM,1,200));

 END create_entity_value_set_hier;

END GCS_VALUE_SET_PKG;

/
