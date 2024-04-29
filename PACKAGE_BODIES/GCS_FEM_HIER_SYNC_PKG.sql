--------------------------------------------------------
--  DDL for Package Body GCS_FEM_HIER_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_FEM_HIER_SYNC_PKG" AS
/* $Header: gcs_hier_syncb.pls 120.2 2007/02/19 20:50:38 skamdar ship $ */
--
-- Private Global Variables
--
   -- The API name
   g_api   CONSTANT VARCHAR2 (30) := 'GCS_FEM_HIER_SYNC_PKG';

--
-- Private Procedures
--
   PROCEDURE synchronize_hierarchy_private(
      					p_hierarchy_id   IN      	NUMBER,
      					p_start_date	 IN	 	DATE		DEFAULT NULL,
      					p_end_date	 IN	 	DATE		DEFAULT NULL,
      					x_errbuf         OUT NOCOPY     VARCHAR2,
      					x_retcode        OUT NOCOPY     VARCHAR2
   ) IS

     l_hierarchy_name		VARCHAR2(150);
     l_folder_name		VARCHAR2(150);
     l_start_date		DATE;
     l_top_entity_display_code	VARCHAR2(150);

     --Bugfix 5744068: Adding users to folder automatically
     l_user_assigned_flag       VARCHAR2(1);
     l_msg_count                NUMBER;
     l_msg_data                 VARCHAR2(2000);
     l_return_status            VARCHAR2(1);

   BEGIN

     --Bugfix 5744068: Check folder access prior to executing loader
     BEGIN
       SELECT     'Y'
       INTO       l_user_assigned_flag
       FROM       fem_user_folders fuf
       WHERE      fuf.folder_id         = 1100
       AND        fuf.user_id           = FND_GLOBAL.USER_ID;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         fem_folders_utl_pkg.assign_user_to_folder(
                                         p_api_version    => 1.0,
                                         p_folder_id      => 1100,
                                         p_write_flag     => 'Y',
                                         x_msg_count      => l_msg_count,
                                         x_msg_data       => l_msg_data,
                                         x_return_status  => l_return_status);
     END;

     --Bugfix 5744068: Check folder access prior to executing loader
     BEGIN
       SELECT     'Y'
       INTO       l_user_assigned_flag
       FROM       fem_user_folders fuf
       WHERE      fuf.folder_id         = 1000
       AND        fuf.user_id           = FND_GLOBAL.USER_ID;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         fem_folders_utl_pkg.assign_user_to_folder(
                                         p_api_version    => 1.0,
                                         p_folder_id      => 1000,
                                         p_write_flag     => 'Y',
                                         x_msg_count      => l_msg_count,
                                         x_msg_data       => l_msg_data,
                                         x_return_status  => l_return_status);
     END;

     SELECT	folder_name
     INTO	l_folder_name
     FROM	fem_folders_vl
     WHERE	folder_id		= 1100;

     SELECT 	hierarchy_name,
		ghv.start_date,
		feb.entity_display_code
     INTO 	l_hierarchy_name,
		l_start_date,
		l_top_entity_display_code
     FROM 	gcs_hierarchies_vl 	ghv,
             	gcs_hierarchies_b 	ghb,
             	fem_entities_b	 	feb
     WHERE 	ghb.hierarchy_id 	= p_hierarchy_id
     AND 	ghb.top_entity_id 	= feb.entity_id
     AND 	ghv.hierarchy_id 	= p_hierarchy_id;

     IF (p_start_date IS NOT NULL) THEN
	   l_start_date		:=	p_start_date;
     END IF;

     l_hierarchy_name		:=	substr(l_hierarchy_name, 1, 110) || ' effective since ' || l_start_date;

     -- Step 1: insert hierarchy header info

     INSERT INTO fem_hierarchies_t
     (	hierarchy_object_name,
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
	hier_obj_def_display_name,
        effective_start_date
     )
     VALUES
     (	l_hierarchy_name,
	l_folder_name,
	USERENV('LANG'),
        'ENTITY',
	'OPEN',
        'NO_GROUPS',
	'N',
        'N',
	'STANDARD',
        'N',
	'LOAD',
	l_hierarchy_name,
        l_start_date
     );

     -- Step 2: insert fem_hier_values_sets_t
     -- we use 'ENTITY' as value_set_display_code for now;

     INSERT INTO fem_hier_value_sets_t
     (	hierarchy_object_name,
	value_set_display_code,
	language,
        status
     )
     VALUES
     (	l_hierarchy_name,
	'ENTITY',
	USERENV('LANG'),
        'LOAD'
     );

     -- Step 3: insert all relationships

     INSERT INTO fem_entities_hier_t
     (	hierarchy_object_name,
	hierarchy_obj_def_display_name,
        parent_display_code,
	parent_value_set_display_code,
        child_display_code,
	child_value_set_display_code,
        display_order_num,
	weighting_pct,
	status,
	language)
     SELECT
	l_hierarchy_name,
	l_hierarchy_name,
        fev_p.entity_display_code,
	'ENTITY',
        fev_c.entity_display_code,
	'ENTITY',
	1,
	NULL,
	'LOAD',
        USERENV('LANG')
     FROM 	fem_entities_b fev_p,
        	fem_entities_b fev_c,
                gcs_cons_relationships gcr
     WHERE 	gcr.hierarchy_id 	= p_hierarchy_id
     AND 	gcr.parent_entity_id 	= fev_p.entity_id
     AND	l_start_date		BETWEEN		gcr.start_date	AND	NVL(gcr.end_date, l_start_date)
     AND	gcr.dominant_parent_flag= 'Y'
     AND 	gcr.child_entity_id 	= fev_c.entity_id;

     -- we need to insert a record for the top node

     INSERT INTO fem_entities_hier_t
     (
	hierarchy_object_name,
	hierarchy_obj_def_display_name,
        parent_display_code,
	parent_value_set_display_code,
        child_display_code,
	child_value_set_display_code,
        display_order_num,
	weighting_pct,
	status,
	language
     )
     VALUES
     (
	l_hierarchy_name,
	l_hierarchy_name,
        l_top_entity_display_code,
	'ENTITY',
        l_top_entity_display_code,
	'ENTITY',
        1,
	NULL,
	'LOAD',
 	USERENV('LANG')
     );

     -- Step 4: run loader program

     FEM_HIER_LOADER_PKG.MAIN
     (	errbuf                           => x_errbuf,
        retcode                          => x_retcode,
        p_execution_mode                 => 'S',
        p_object_definition_id           => NULL,
        p_dimension_varchar_label        => 'ENTITY',
        p_hierarchy_object_name          => l_hierarchy_name,
        p_hier_obj_def_display_name      => l_hierarchy_name
     );

  END synchronize_hierarchy_private;

--
-- Public Procedures
--

   PROCEDURE synchronize_hierarchy(
      			p_hierarchy_id   IN              NUMBER,
      			x_errbuf         OUT NOCOPY      VARCHAR2,
      			x_retcode        OUT NOCOPY      VARCHAR2)
   IS
      l_hierarchy_name            	VARCHAR2 (150);
      l_top_entity_display_code         VARCHAR2 (150);
      l_start_date		  	DATE;
      l_api_name                  	VARCHAR2 (30)           := 'initial_push';
      l_folder_name			VARCHAR2 (150);

   BEGIN

     fnd_file.put_line(fnd_file.log, 'Preparing Hierarchy for Integration with EPF');

     synchronize_hierarchy_private(
		p_hierarchy_id		=>	p_hierarchy_id,
		x_errbuf		=>	x_errbuf,
		x_retcode		=>	x_retcode);

     fnd_file.put_line(fnd_file.log, 'End of Integration with EPF');

   EXCEPTION
     WHEN OTHERS THEN
       x_retcode := gcs_utility_pkg.g_ret_sts_error;
       fnd_file.put_line(fnd_file.log, 'Error occurring during integration with EPF');
   END synchronize_hierarchy;

   PROCEDURE entity_added(
			p_hierarchy_id		IN		NUMBER,
			p_cons_relationship_id	IN		NUMBER)
   IS
     l_start_date		DATE;
     l_parent_entity_id		NUMBER;
     l_child_entity_id		NUMBER;
     l_entity_type		VARCHAR2(1);
     l_parent_depth_num		NUMBER(15);
     l_entity_type_attr		NUMBER	:=
				gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id;
     l_entity_type_version	NUMBER	:=
				gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').version_id;
     l_elim_entity_attr		NUMBER	:=
				gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').attribute_id;
     l_elim_entity_version	NUMBER	:=
				gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').version_id;
     l_oper_entity_attr		NUMBER	:=
				gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').attribute_id;
     l_oper_entity_version	NUMBER	:=
				gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').version_id;
     l_prior_relation_exists	BOOLEAN := FALSE;
     l_object_definition_id	NUMBER(9);
     l_object_id		NUMBER(9);
     l_hierarchy_name		VARCHAR2(150);
     l_errbuf			VARCHAR2(200);
     l_retcode			VARCHAR2(200);

     CURSOR c_prior_relationship_exists (p_hierarchy_id		NUMBER,
					 p_child_entity_id 	NUMBER)
     IS
       SELECT	gcr.parent_entity_id,
		gcr.child_entity_id,
		gcr.start_date,
		gcr.end_date
       FROM	gcs_cons_relationships	gcr
       WHERE	gcr.hierarchy_id		=	p_hierarchy_id
       AND	gcr.dominant_parent_flag	=	'Y'
       AND	gcr.child_entity_id		=	p_child_entity_id;

   BEGIN

     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.ENTITY_ADDED.begin', '<<Enter>>');
     END IF;

     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ENTITY_ADDED', 'p_hierarchy_id	: ' || p_hierarchy_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.ENTITY_ADDED', 'p_cons_relationship_id: ' || p_cons_relationship_id);
     END IF;

     SELECT	gcr.parent_entity_id,
		gcr.child_entity_id,
		gcr.start_date,
		fea.dim_attribute_varchar_member,
		substr(ghv.hierarchy_name,1,110) || ' effective since'
     INTO	l_parent_entity_id,
		l_child_entity_id,
		l_start_date,
		l_entity_type,
	 	l_hierarchy_name
     FROM	gcs_cons_relationships 	gcr,
		fem_entities_attr	fea,
		gcs_hierarchies_vl	ghv
     WHERE	gcr.cons_relationship_id	=	p_cons_relationship_id
     AND	gcr.hierarchy_id		=	ghv.hierarchy_id
     AND	gcr.dominant_parent_flag	=	'Y'
     AND	gcr.child_entity_id		=	fea.entity_id
     AND	fea.attribute_id		=	l_entity_type_attr
     AND	fea.version_id			=	l_entity_type_version;

     -- Check if prior relationship exists
     FOR v_prior_relationship_exists IN c_prior_relationship_exists(	p_hierarchy_id,
									l_child_entity_id) LOOP

       IF (v_prior_relationship_exists.parent_entity_id <>	l_parent_entity_id) THEN
         l_prior_relation_exists	:=	TRUE;
	 EXIT;
       END IF;
     END LOOP;

     SELECT   fodb.object_definition_id
     INTO     l_object_definition_id
     FROM     fem_object_definition_vl fodb,
              fem_hierarchies          fh
     WHERE    fh.hierarchy_obj_id     =               fodb.object_id
     AND      fh.dimension_id         =               18
     AND      fodb.display_name       like            l_hierarchy_name || '%'
     AND      l_start_date            between         fodb.effective_start_date and fodb.effective_end_date
     AND      effective_end_date      =               TO_DATE('01-01-2500','DD-MM-YYYY');

     IF (l_prior_relation_exists) THEN

       UPDATE	fem_object_definition_b
       SET	effective_end_date    =			l_start_date
       WHERE	object_definition_id  =			l_object_definition_id;

       synchronize_hierarchy_private(
                                        p_hierarchy_id   =>	p_hierarchy_id,
                                        p_start_date     =>	l_start_date,
                                        x_errbuf         =>	l_errbuf,
                                        x_retcode        =>	l_retcode);

     ELSE

       BEGIN
         SELECT	feh.parent_depth_num
         INTO	l_parent_depth_num
         FROM	fem_entities_hier feh
         WHERE	feh.hierarchy_obj_def_id	=	l_object_definition_id
         AND	feh.parent_id			=	l_parent_entity_id
         AND	feh.single_depth_flag		=	'Y'
         AND	ROWNUM				<	2;
       EXCEPTION
         WHEN OTHERS THEN
	   SELECT feh.child_depth_num
           INTO   l_parent_depth_num
           FROM   fem_entities_hier feh
           WHERE  feh.hierarchy_obj_def_id        =       l_object_definition_id
           AND    feh.child_id                    =       l_parent_entity_id
           AND    feh.single_depth_flag           =       'Y'
           AND    ROWNUM                          <       2;
       END;

       INSERT INTO fem_entities_hier
       (hierarchy_obj_def_id,
	parent_depth_num,
	parent_id,
	parent_value_set_id,
	child_depth_num,
	child_id,
	child_value_set_id,
	single_depth_flag,
	display_order_num,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	object_version_number,
	read_only_flag
       )
       VALUES
       (l_object_definition_id,
	l_parent_depth_num,
	l_parent_entity_id,
	18,
	l_parent_depth_num + 1,
	l_child_entity_id,
	18,
	'Y',
	1,
	sysdate,
	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.USER_ID,
	FND_GLOBAL.LOGIN_ID,
	1,
	'N'
       );

       IF (l_entity_type	=	'C') THEN
         INSERT INTO fem_entities_hier
         (hierarchy_obj_def_id,
          parent_depth_num,
          parent_id,
          parent_value_set_id,
          child_depth_num,
          child_id,
          child_value_set_id,
          single_depth_flag,
          display_order_num,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          object_version_number,
          read_only_flag
         )
         SELECT  l_object_definition_id,
          	l_parent_depth_num + 1,
          	l_child_entity_id,
          	18,
        	l_parent_depth_num + 2,
        	fea.dim_attribute_numeric_member,
        	18,
        	'Y',
        	1,
        	sysdate,
        	FND_GLOBAL.USER_ID,
        	sysdate,
        	FND_GLOBAL.USER_ID,
        	FND_GLOBAL.LOGIN_ID,
        	1,
        	'N'
	 FROM   fem_entities_attr fea
	 WHERE	fea.entity_id		=	l_child_entity_id
	 AND	fea.attribute_id	IN	(l_oper_entity_attr, l_elim_entity_attr)
	 AND	fea.version_id		IN	(l_oper_entity_version, l_elim_entity_version);
       END IF;
     END IF;

     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.ENTITY_ADDED.end', '<<Exit>>');
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_ERROR) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR, g_api || '.ENTITY_ADDED',  SQLERRM);
       END IF;
   END entity_added;



END gcs_fem_hier_sync_pkg;


/
