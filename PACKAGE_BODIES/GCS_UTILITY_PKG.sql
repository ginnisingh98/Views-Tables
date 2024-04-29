--------------------------------------------------------
--  DDL for Package Body GCS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_UTILITY_PKG" as
/* $Header: gcsutilb.pls 120.5 2007/06/28 12:23:18 vkosuri noship $ */

  --
  -- Procedure
  --   init_dimension_attr_info
  -- Purpose
  --   Caches all critical info stored in dim_attributes_b within g_dimension_attr_info
  --
  -- Arguments
  --
  -- Example
  --
  -- Notes
  --

  PROCEDURE init_dimension_attr_info IS

    TYPE t_index_dimension_attr_info IS TABLE OF r_dimension_attr_info;

    l_index_dimension_attr_info		t_index_dimension_attr_info;
    l_hashkey				VARCHAR2(200);

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.init_dimension_attr_info.begin', null);
    END IF;

    SELECT ftcb.dimension_id,
    	   fda.attribute_id,
    	   ftcb.column_name,
    	   fda.attribute_varchar_label,
    	   fda.attribute_value_column_name,
-- STK 3/29/04	Added Default Version ID for performance purposes
	   fdavb.version_id
    BULK COLLECT INTO l_index_dimension_attr_info
    FROM   fem_tab_columns_b 		ftcb,
    	   fem_dim_attributes_b		fda,
    	   fem_tab_column_prop  	ftcp,
    	   fem_dim_attr_versions_b	fdavb
    WHERE  ftcb.table_name		= 	'FEM_BALANCES'
    AND    ftcb.dimension_id		= 	fda.dimension_id
    AND    ftcp.table_name		= 	'FEM_BALANCES'
    AND    ftcp.column_property_code 	=	'PROCESSING_KEY'
    AND	   fdavb.attribute_id		=	fda.attribute_id
    AND	   fdavb.default_version_flag	=	'Y'
    AND    ftcp.column_name		=       ftcb.column_name;

    FOR l_counter IN
    		l_index_dimension_attr_info.FIRST..l_index_dimension_attr_info.LAST
    LOOP

      -- The hashkey will be COLUMN NAME - DIMENSION ATTRIBUTE LABEL in order to resolve issue with attributes sharing names between
      -- dimensions and/or columns (Issue Found by Mike Ward)

      l_hashkey := l_index_dimension_attr_info(l_counter).column_name || '-' || l_index_dimension_attr_info(l_counter).attribute_varchar_label;

      g_dimension_attr_info(l_hashkey) :=
      		l_index_dimension_attr_info(l_counter);
    END LOOP;

    SELECT fdb.dimension_id,
    	   fda.attribute_id,
    	   DECODE(fdb.dimension_varchar_label,
                  'COST_CENTER', 'COST_CENTER','EXT_ACCOUNT_TYPE_CODE'),
    	   fda.attribute_varchar_label,
    	   fda.attribute_value_column_name,
-- STK 3/29/04	Added Default Version ID for performance purposes
	   fdavb.version_id
    BULK COLLECT INTO l_index_dimension_attr_info
    FROM   fem_dim_attributes_b		fda,
           fem_dimensions_b         	fdb,
    	   fem_dim_attr_versions_b	fdavb
    WHERE  fdb.dimension_id		           	= 	fda.dimension_id
    AND	   fdavb.attribute_id		       		=	fda.attribute_id
    AND	   fdavb.default_version_flag	   		=	'Y'
    AND    fdb.dimension_varchar_label     		IN      ('EXTENDED_ACCOUNT_TYPE','COST_CENTER');

    FOR l_counter IN
    		l_index_dimension_attr_info.FIRST..l_index_dimension_attr_info.LAST
    LOOP

      -- The hashkey will be COLUMN NAME - DIMENSION ATTRIBUTE LABEL in order to resolve issue with attributes sharing names between
      -- dimensions and/or columns (Issue Found by Mike Ward)

      l_hashkey := l_index_dimension_attr_info(l_counter).column_name || '-' || l_index_dimension_attr_info(l_counter).attribute_varchar_label;

      g_dimension_attr_info(l_hashkey) :=
      		l_index_dimension_attr_info(l_counter);
    END LOOP;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.init_dimension_attr_info.end', null);
    END IF;

  END init_dimension_attr_info;

  -- END init_dimension_attr_info


 --
  -- Procedure
  --   init_dimension_info
  -- Purpose
  --   Caches the active dimension for GCS II, in addition to the value sets associated with each dimension.
  --
  -- Arguments
  --
  -- Example
  --
  -- Notes
  --

  PROCEDURE init_dimension_info IS

    TYPE t_index_gcs_dimension_info IS TABLE OF r_gcs_dimension_info;

    l_index_gcs_dimension_info		t_index_gcs_dimension_info;
    l_application_group_id		NUMBER(15);
    l_err_code 				NUMBER;
    l_err_msg 				VARCHAR2(2000);
    l_required_for_gcs			VARCHAR2(1)	:= 'N';

    -- Bugfix 5707630: Type added to hold historical rates dimension.
    TYPE t_index_hrate_dim_info IS TABLE OF r_hrate_dim_info;
    l_index_hrate_dim_info	t_index_hrate_dim_info;

    inv_application_exception		EXCEPTION;
    inv_global_combo_exception		EXCEPTION;

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.init_dimension_info.begin', null);
    END IF;

   -- Start bugfix 5707630: Select the dimensions enabled for historical rates on the
   -- processing keys page and store it into the record for use during translation
    SELECT  gedm.gcs_column,
            nvl(gedm.hrate_enabled_flag, 'Y')
    BULK COLLECT INTO l_index_hrate_dim_info
    FROM    gcs_epb_dim_maps gedm;


    IF l_index_hrate_dim_info.COUNT > 0 THEN
      FOR l_counter IN l_index_hrate_dim_info.FIRST..l_index_hrate_dim_info.LAST
      LOOP
        g_hrate_dim_info(l_index_hrate_dim_info(l_counter).column_name) :=
      		l_index_hrate_dim_info(l_counter);
      END LOOP;
    END IF;
    -- End bugfix 5707630

/* Code for resolving application group id, and global value set combo will remain commented until reconvening in early Jan 2004 */
-- Bugfix 4267992 : Storing Global Value Set Combo on gcs_system_options
   l_application_group_id	:= 266;

    SELECT  ftcb.column_name,
            fvsb.dimension_id,
            fvsb.value_set_id,
            'N' gcs_required,
            'Y' fem_required,
            fvsb.default_member_id,
            -1,
	    fxd.member_b_table_name,
	    fxd.member_vl_object_name,
	    fxd.member_col,
	    fxd.member_display_code_col
    BULK COLLECT INTO l_index_gcs_dimension_info
    FROM    fem_value_sets_b            fvsb,
            fem_global_vs_combo_defs    fgvcd,
            fem_tab_columns_b           ftcb,
            fem_tab_column_prop         ftcp,
	    fem_xdim_dimensions		fxd,
	    gcs_system_options		gso
    WHERE   fvsb.dimension_id           = DECODE(fgvcd.dimension_id, 17, 8, fgvcd.dimension_id)
    AND     fvsb.value_set_id		= fgvcd.value_set_id
    AND     fgvcd.global_vs_combo_id    = gso.fch_global_vs_combo_id
    AND     ftcb.dimension_id           = fgvcd.dimension_id
    AND     ftcb.table_name             = 'FEM_BALANCES'
    AND     ftcp.table_name             = 'FEM_BALANCES'
    AND     ftcp.column_property_code   = 'PROCESSING_KEY'
    AND	    ftcb.dimension_id		= fxd.dimension_id
    AND     ftcp.column_name            = ftcb.column_name;


    IF l_index_gcs_dimension_info.FIRST IS NOT NULL AND
       l_index_gcs_dimension_info.LAST IS NOT NULL THEN
      FOR l_counter IN
    		l_index_gcs_dimension_info.FIRST..l_index_gcs_dimension_info.LAST
      LOOP

        BEGIN
          SELECT 'N'
          INTO    l_required_for_gcs
          FROM    DUAL
          WHERE   EXISTS
                  (SELECT 'X'
                   FROM   fem_app_grp_dim_exclsns fagde
                   WHERE  fagde.application_group_id = l_application_group_id
                   AND    fagde.dimension_id         = l_index_gcs_dimension_info(l_counter).dimension_id)
          OR     EXISTS
                  (SELECT 'X'
                   FROM   fem_app_grp_col_exclsns fagce
                   WHERE  fagce.application_group_id = l_application_group_id
                   AND    fagce.column_name          = l_index_gcs_dimension_info(l_counter).column_name);
        EXCEPTION
          WHEN OTHERS THEN
            l_index_gcs_dimension_info(l_counter).required_for_gcs := 'Y';
        END;

        g_gcs_dimension_info(l_index_gcs_dimension_info(l_counter).column_name) :=
      		l_index_gcs_dimension_info(l_counter);
      END LOOP;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.init_dimension_info.end', null);
    END IF;

  EXCEPTION
    WHEN inv_application_exception THEN
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'gcs.plsql.gcs_utility_pkg.init_dimension_info', 'Invalid Applications Context');
      END IF;
      FND_MESSAGE.SET_NAME('GCS','Invalid_App_Group');
      app_exception.raise_exception;
    WHEN inv_global_combo_exception THEN
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'gcs.plsql.gcs_utility_pkg.init_dimension_info', 'Invalid Global VS Combo');
      END IF;
        FND_MESSAGE.SET_NAME('GCS','Invalid_Global_Como');
        app_exception.raise_exception;
    WHEN NO_DATA_FOUND THEN
      NULL;
  END init_dimension_info;


  --
  -- Procedure
  --   get_cal_period_details
  -- Purpose
  --   Returns the attribute information for the current period, and the prior period.
  --   Needs to be leveraged by Dataprep and Translation
  --
  -- Arguments
  --
  --   p_cal_period_id		Calendar Period Identifier
  --   p_cal_period_record	Records containing attribute values for prior and specified period.
  -- Example
  --
  -- Notes
  --

  PROCEDURE get_cal_period_details(p_cal_period_id 	NUMBER,
  				   p_cal_period_record	IN OUT NOCOPY r_cal_period_info) IS

    l_curr_cal_period_number		NUMBER(15);
    l_curr_cal_period_year		NUMBER(15);
    l_periods_per_year			NUMBER(15);
    l_calendar_id			NUMBER(15);
    l_calendar_group_id			NUMBER(15);
    l_prev_cal_period_id		NUMBER;
    l_prev_cal_period_number		NUMBER(15);
    l_prev_cal_period_year		NUMBER(15);
    l_next_cal_period_id		NUMBER;
    l_next_cal_period_number		NUMBER(15);
    l_next_cal_period_year		NUMBER(15);

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.get_cal_period_details.begin', null);
    END IF;

      SELECT fcpb.calendar_id, fcpb.dimension_group_id,
             fcpa_number.number_assign_value, fcpa_year.number_assign_value,
             ftgta.number_assign_value
        INTO l_calendar_id, l_calendar_group_id,
             l_curr_cal_period_number, l_curr_cal_period_year,
             l_periods_per_year
        FROM fem_cal_periods_b fcpb,
             fem_cal_periods_attr fcpa_number,
             fem_cal_periods_attr fcpa_year,
             fem_dimension_grps_b fdgb,
             fem_time_grp_types_attr ftgta,
             fem_dim_attributes_b feab,
             fem_dim_attr_versions_b fdavb
       WHERE fcpb.cal_period_id = p_cal_period_id
         AND fcpb.dimension_group_id = fdgb.dimension_group_id
         AND fdgb.time_group_type_code = ftgta.time_group_type_code
         AND ftgta.attribute_id = feab.attribute_id
         AND ftgta.version_id   = fdavb.version_id
         AND feab.attribute_varchar_label = 'PERIODS_IN_YEAR'
         AND feab.attribute_id  = fdavb.attribute_id
         AND fdavb.default_version_flag = 'Y'
         AND fcpa_number.cal_period_id = fcpb.cal_period_id
         AND fcpa_number.attribute_id =
                g_dimension_attr_info ('CAL_PERIOD_ID-GL_PERIOD_NUM').attribute_id
         AND fcpa_number.version_id   =
                g_dimension_attr_info ('CAL_PERIOD_ID-GL_PERIOD_NUM').version_id
         AND fcpa_year.attribute_id =
                g_dimension_attr_info ('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id
         AND fcpa_year.version_id   =
                g_dimension_attr_info ('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id
         AND fcpa_year.cal_period_id = fcpb.cal_period_id;

    IF (l_curr_cal_period_number = 1) THEN
      l_prev_cal_period_number 	:= l_periods_per_year;
      l_prev_cal_period_year	:= l_curr_cal_period_year - 1;
    ELSE
      l_prev_cal_period_number	:= l_curr_cal_period_number - 1;
      l_prev_cal_period_year	:= l_curr_cal_period_year;
    END IF;

    BEGIN

      SELECT fcpb.cal_period_id
      INTO   l_prev_cal_period_id
      FROM   fem_cal_periods_b		fcpb,
      	     fem_cal_periods_attr	fcpa_number,
      	     fem_cal_periods_attr	fcpa_year
      WHERE  fcpb.calendar_id			=	l_calendar_id
      AND    fcpb.dimension_group_id		= 	l_calendar_group_id
      AND    fcpb.cal_period_id			= 	fcpa_number.cal_period_id
      AND    fcpb.cal_period_id			=	fcpa_year.cal_period_id
      AND    fcpa_number.attribute_id		= 	g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').attribute_id
      AND    fcpa_number.version_id		=       g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').version_id
      AND    fcpa_number.number_assign_value	=	l_prev_cal_period_number
      AND    fcpa_year.attribute_id		= 	g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id
      AND    fcpa_year.version_id		=       g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id
      AND    fcpa_year.number_assign_value	=	l_prev_cal_period_year;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      	l_prev_cal_period_id 		:= -1;
      	l_prev_cal_period_year  	:= -1;
      	l_prev_cal_period_number	:= -1;
    END;

    -- next get the information for the subsequent period
    IF (l_curr_cal_period_number = l_periods_per_year) THEN
      l_next_cal_period_number := 1;
      l_next_cal_period_year := l_curr_cal_period_year + 1;
    ELSE
      l_next_cal_period_number := l_curr_cal_period_number + 1;
      l_next_cal_period_year := l_curr_cal_period_year;
    END IF;

    BEGIN

      SELECT fcpb.cal_period_id
      INTO   l_next_cal_period_id
      FROM   fem_cal_periods_b		fcpb,
      	     fem_cal_periods_attr	fcpa_number,
      	     fem_cal_periods_attr	fcpa_year
      WHERE  fcpb.calendar_id			=	l_calendar_id
      AND    fcpb.dimension_group_id		= 	l_calendar_group_id
      AND    fcpb.cal_period_id			= 	fcpa_number.cal_period_id
      AND    fcpb.cal_period_id			=	fcpa_year.cal_period_id
      AND    fcpa_number.attribute_id		= 	g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').attribute_id
      AND    fcpa_number.version_id		=       g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').version_id
      AND    fcpa_number.number_assign_value	=	l_next_cal_period_number
      AND    fcpa_year.attribute_id		= 	g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id
      AND    fcpa_year.version_id		=       g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id
      AND    fcpa_year.number_assign_value	=	l_next_cal_period_year;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      	l_next_cal_period_id 		:= -1;
      	l_next_cal_period_year  	:= -1;
      	l_next_cal_period_number	:= -1;
    END;


    p_cal_period_record.cal_period_id		:= p_cal_period_id;
    p_cal_period_record.cal_period_number	:= l_curr_cal_period_number;
    p_cal_period_record.cal_period_year		:= l_curr_cal_period_year;
    p_cal_period_record.prev_cal_period_id	:= l_prev_cal_period_id;
    p_cal_period_record.prev_cal_period_number	:= l_prev_cal_period_number;
    p_cal_period_record.prev_cal_period_year	:= l_prev_cal_period_year;
    p_cal_period_record.next_cal_period_id	:= l_next_cal_period_id;
    p_cal_period_record.next_cal_period_number	:= l_next_cal_period_number;
    p_cal_period_record.next_cal_period_year	:= l_next_cal_period_year;
    p_cal_period_record.cal_periods_per_year	:= l_periods_per_year;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.get_cal_period_details.end', null);
    END IF;

  END get_cal_period_details;

  -- STK 1/12/04
  -- Procedure
  --   get_entry_header()
  -- Purpose
  --   generates a unique name, and appropriate description for all automated GCS II processes
  -- Arguments
  --   p_process_type_code	Automated Process Values: Data Prep, Translation, Aggregation,Acquisitions and Disposals,
  --							  Pre-Intercompany, Intercompany, Post-Intercompany,
  --							  Minority Interest, Post-Minority Interest
  --   p_entry_id		Entry ID
  --   p_entity_id		Entity ID associated with process (parent entity in case of rules)
  --   p_currency_code		Currency Code of Entry
  --   p_rule_id		Required Only for Automated Rules
  -- Notes
  --
  PROCEDURE get_entry_header(	p_process_type_code	VARCHAR2,
  				p_entry_id 		NUMBER,
  				p_entity_id		NUMBER,
  				p_currency_code		VARCHAR2,
  				p_rule_id		NUMBER DEFAULT NULL,
  				p_entry_header	IN OUT NOCOPY r_entry_header) IS

  l_entity_name		VARCHAR2(80);
  l_rule_name		VARCHAR2(80);
  l_entry_header	VARCHAR2(240);
  l_entry_description	VARCHAR2(240);
  l_temp		VARCHAR2(1);

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.get_entry_header.begin', null);
    END IF;

     SELECT entity_name
     INTO   l_entity_name
     FROM   fem_entities_tl
     WHERE  entity_id 		=  p_entity_id
     AND    language 		=  USERENV('LANG');

     IF (p_rule_id IS NOT NULL) THEN
        SELECT rule_name
        INTO   l_rule_name
        FROM   gcs_elim_rules_tl
        WHERE  rule_id 		= p_rule_id
        AND    language		= USERENV('LANG');
     END IF;

     IF (p_process_type_code = 'Data Prep') THEN
     	l_entry_header 		:= l_entity_name || '(' || p_currency_code || ')';
    	l_entry_description	:= 'Data Preparation of ' || l_entity_name;
     ELSIF (p_process_type_code = 'Translation') THEN
     	l_entry_header		:= l_entity_name || '(' || p_currency_code || ')';
     	l_entry_description	:= 'Translation of ' || l_entity_name || ' to ' || p_currency_code;
     ELSE
     	l_entry_header		:= l_rule_name || ' for ' || l_entity_name;
     	l_entry_description     := l_rule_name || ' Executed For ' || l_entity_name;
     END IF;

     BEGIN

     SELECT 'X'
     INTO   l_temp
     FROM   gcs_entry_headers
     WHERE  entry_name = l_entry_header;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         null;
     END;

     IF (l_temp = 'X') THEN
       l_entry_header := l_entry_header || ' ID #' || p_entry_id;
     END IF;

     p_entry_header.name 	:= l_entry_header;
     p_entry_header.description	:= l_entry_description;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.get_entry_header.end', null);
    END IF;

  END get_entry_header;


  --
  -- Function
  --   Get_Dimension_Required
  -- Purpose
  --   Get whether or not this dimension is required. Return 'Y' or 'N'.
  -- Arguments
  --   p_dim_col Dimension column name
  -- Example
  --   GCS_UTILITY_PKG.Get_Dimension_Required
  -- Notes
  --
  FUNCTION Get_Dimension_Required(p_dim_col VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    return g_gcs_dimension_info(p_dim_col).required_for_gcs;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return 'N';
  END Get_Dimension_Required;

  --
  -- Function
  --   Get_Fem_Dim_Required
  -- Purpose
  --   Get whether or not this dimension is required for FEM. Return 'Y' or 'N'.
  -- Arguments
  --   p_dim_col Dimension column name
  -- Example
  --   GCS_UTILITY_PKG.Get_Fem_Dim_Required
  -- Notes
  --
  FUNCTION Get_Fem_Dim_Required(p_dim_col VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    return g_gcs_dimension_info(p_dim_col).required_for_fem;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return 'N';
  END Get_Fem_Dim_Required;

  -- Bug fix 5707630
  -- Function
  --   Get_Hrate_Dim_Required
  -- Purpose
  --   Get whether or not this dimension is required for historical rates
  -- Arguments
  --   p_dim_col Dimension column name
  -- Example
  --   GCS_UTILITY_PKG.Get_Hrate_Dim_Required
  -- Notes
  --
  FUNCTION Get_Hrate_Dim_Required(p_dim_col VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    return g_hrate_dim_info(p_dim_col).required_for_hrate;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'N';
  END Get_Hrate_Dim_Required;



  --
  -- Function
  --   Get_Default_Value
  -- Purpose
  --   Get default value for the dimension
  -- Arguments
  --   p_dim_col Dimension column name
  -- Example
  --   GCS_UTILITY_PKG.Get_Default_Value
  -- Notes
  --
  FUNCTION Get_Default_Value(p_dim_col VARCHAR2) RETURN NUMBER IS
  BEGIN
    return g_gcs_dimension_info(p_dim_col).default_value;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return -1;
  END Get_Default_Value;

  --
  -- Function
  --   Get_Dimension_Attribute
  -- Purpose
  --   Get attribute_id for the dimension-attribute
  -- Arguments
  --   p_dim_attr Dimension attribute
  -- Example
  --   GCS_UTILITY_PKG.Get_Dimension_Attribute('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
  -- Notes
  --
  FUNCTION Get_Dimension_Attribute(p_dim_attr VARCHAR2) RETURN NUMBER IS
  BEGIN
    return g_dimension_attr_info(p_dim_attr).attribute_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return -1;
  END Get_Dimension_Attribute;


  --  *********************************************************************
  -- Function (PRIVATE)
  --   Get_Base_Org_Id(p_entity_id NUMBER) RETURN NUMBER
  -- Purpose
  --   Get org_id for the given entity.
  -- Arguments
  --   p_entity_id	   Entity Id
  -- Example
  --   GCS_UTILITY_PKG.Get_Org_Id
  -- Notes
  --   This is a private function, only called by the public Get_Org_Id().
  -- History
  --   23-Jun-2004  J Huang  BaseOrg enhancement. (Bug 3711204)
  --

  FUNCTION Get_Base_Org_Id(p_entity_id NUMBER) RETURN NUMBER IS
    cursor getOrgId (cEntityId NUMBER) is
      SELECT DIM_ATTRIBUTE_NUMERIC_MEMBER
      FROM   FEM_ENTITIES_ATTR
      WHERE  ENTITY_ID = cEntityId
      AND    VERSION_ID   = g_dimension_attr_info('ENTITY_ID-BASE_ORGANIZATION').version_id
      AND    ATTRIBUTE_ID = g_dimension_attr_info('ENTITY_ID-BASE_ORGANIZATION').attribute_id;

    org_id   NUMBER;
  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'gcs.plsql.GCS_UTILITY_PKG.GET_BASE_ORG_ID.begin',
                        TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'gcs.plsql.GCS_UTILITY_PKG.GET_BASE_ORG_ID.bind',
    			 'ENTITY_ID: ' || p_entity_id);
    END IF;

    OPEN getOrgId( p_entity_id);
    FETCH getOrgId INTO org_id;
    IF getOrgId%NOTFOUND THEN
      --Bugfix 4302199: Remove closing of this cursor
      org_id :=-1;
    END IF;
    CLOSE getOrgId;

    IF (org_id IS NULL) THEN
      org_id :=-1;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'gcs.plsql.GCS_UTILITY_PKG.GET_BASE_ORG_ID',
                         'BASE_ORG_ID: ' || org_id);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'gcs.plsql.GCS_UTILITY_PKG.GET_BASE_ORG_ID.end',
                        TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    RETURN org_id;
  END Get_Base_Org_Id;

  --
  -- Function
  --   Get_Org_Id(p_entity_id NUMBER, p_hierarchy_id NUMBER, p_relationship_id NUMBER) RETURN NUMBER
  -- Purpose
  --   Get org_id for the given entity. If no org_id is found, then look
  --   for org_id for the associated operating entity for this consolidation
  --   entity.  If no org_id is found, then look for org_id for any one of the
  --   child entities
  --   Get org_id for the given entity.  If the given entity is an operating
  --   entity, then org_id is just base_org_id assigned to the entity. If
  --   the entity is a consolidation entity, then get the base_org_id of the
  --   asso
  -- Arguments
  --   p_entity_id	   Entity Id
  --   p_hierarchy_id  Hierarchy Id
  --   p_relationship_id Relationship Id
  -- Example
  --   GCS_UTILITY_PKG.Get_Org_Id
  -- Notes
  --
  -- History
  --   23-Jun-2004  J Huang  BaseOrg enhancement. (Bug 3711204)
  --   15-Jul-2004  J Huang  Bug 3761865
  --

  FUNCTION Get_Org_Id(p_entity_id NUMBER, p_hierarchy_id NUMBER)RETURN NUMBER IS
    l_org_id          NUMBER;
    l_entity_id       NUMBER;   --entity_id;
    c_entity_id       NUMBER;   --consolidation entity_id, when applicable;
    l_hierarchy_id    NUMBER;
    l_entity_type     VARCHAR2(2);

    --Gets the ENTITY_ID for the associated operating entity for this consolidation entity.
    cursor getOpEntityId (cEntityId NUMBER) IS
      SELECT DIM_ATTRIBUTE_NUMERIC_MEMBER
      FROM   FEM_ENTITIES_ATTR
      WHERE  ENTITY_ID = cEntityId
      AND    VERSION_ID   = g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').version_id
      AND    ATTRIBUTE_ID = g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY').attribute_id;


    --Gets all other operationg entity ENTITY_ID this consolidation entity.
    cursor getAllChildEntityId(cEntityId NUMBER, cHierarchyId NUMBER)IS
      SELECT r.child_entity_id
      FROM   GCS_CONS_RELATIONSHIPS r
      START WITH  r.parent_entity_id = cEntityId
      AND    r.hierarchy_id = cHierarchyId

      AND    ( sysdate BETWEEN r.start_date
      AND NVL(r.end_date, sysdate))
      AND    r.actual_ownership_flag='Y'
      CONNECT BY  prior r.child_entity_id = r.parent_entity_id
      AND    r.hierarchy_id = cHierarchyId
      AND   ( sysdate BETWEEN r.start_date
      AND NVL(r.end_date, sysdate))
      AND    r.actual_ownership_flag='Y';

  BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                  'gcs.plsql.GCS_UTILITY_PKG.GET_ORG_ID. begin',
                  TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    l_entity_id:=p_entity_id;
    c_entity_id:=p_entity_id;
    l_hierarchy_id := p_hierarchy_id;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'gcs.plsql.GCS_UTILITY_PKG.GET_ORG_ID.bind',
                     'ENTITY_ID: '||l_entity_id
                     ||'; HIERARCHY_ID: '|| l_hierarchy_id);
    END IF;

    --Get entity_type
    SELECT dim_attribute_varchar_member
    INTO   l_entity_type
    FROM   FEM_ENTITIES_ATTR
    WHERE  entity_id = l_entity_id
    AND    attribute_id = g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id
    AND    version_id = g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').version_id
    AND    value_set_id = g_gcs_dimension_info('ENTITY_ID').associated_value_set_id;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'gcs.plsql.GCS_UTILITY_PKG.GET_ORG_ID.get_entity_type',
                     'ATTRIBUTE_ID: '|| g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id
                     ||'; VERSION_ID: '|| g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').version_id
                     ||'; VALUE_SET_ID: '|| g_gcs_dimension_info('ENTITY_ID').associated_value_set_id
                     ||'; ENTITY_TYPE: '|| l_entity_type);
    END IF;

    IF (l_entity_type= 'O') THEN
      l_org_id := Get_Base_Org_Id(l_entity_id);

    ELSE
      --If entity is an elim entity, then get the consolidated entity
      IF (l_entity_type = 'E') THEN
        --Bugfix 5256700: Need to modify this code to handle case where child is owned multiple times. Will determine consolidation entity by looking
        --at fem_entities_attr

        /* Commenting out original query
        SELECT R.PARENT_ENTITY_ID
        INTO   c_entity_id
        FROM   GCS_CONS_RELATIONSHIPS R
        WHERE  R.CHILD_ENTITY_ID = l_entity_id
        AND    R.actual_ownership_flag='Y'
        AND    R.HIERARCHY_ID = l_hierarchy_id;
        */

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'gcs.plsql.GCS_UTILITY_PKG.GET_ORG_ID.get_consolidation_entity',
                     'ATTRIBUTE_ID: '|| g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').attribute_id
                     ||'; VERSION_ID: '|| g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').version_id
                     ||'; ENTITY_ID: '|| l_entity_id);
        END IF;

        SELECT fea.entity_id
        INTO   c_entity_id
        FROM   fem_entities_attr fea
        WHERE  fea.attribute_id                 = g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').attribute_id
        AND    fea.version_id                   = g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY').version_id
        AND    fea.dim_attribute_numeric_member = l_entity_id;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'gcs.plsql.GCS_UTILITY_PKG.GET_ORG_ID.get_consolidation_entity',
                     'CONSOLIDATION ENTITY: '|| c_entity_id);
        END IF;

      END IF; --IF entity_type = 'E'

      --Get the assoicated operating entity id for the consolidated entity.
      OPEN  getOpEntityId(c_entity_id);
      FETCH getOpEntityId INTO l_entity_id;

      --If no associated operating entity is found, get base_org_id of any child operating entity
      IF    getOpEntityId%ROWCOUNT <1  THEN
        FOR childRec IN getAllChildEntityId(c_entity_id, l_hierarchy_id ) LOOP
          IF childRec.child_entity_id <> l_entity_id then
	    l_org_id :=Get_Base_Org_Id(childRec.child_entity_id);
          END IF;
   	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'gcs.plsql.GCS_UTILITY_PKG.GET_ORG_ID.bind',
                     'Consolidation entity ENTITY_ID: ' || c_entity_id
                     ||'; Operating entity ENTITY_ID: '     || l_entity_id);
    	  END IF;

          EXIT WHEN l_org_id > -1;
        END LOOP;
      ELSE
        l_org_id := Get_Base_Org_Id(l_entity_id);

   	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'gcs.plsql.GCS_UTILITY_PKG.GET_ORG_ID.bind',
                     'Consolidation entity ENTITY_ID: ' || c_entity_id
                     ||'; Associated Operating entity ENTITY_ID: ' || l_entity_id);
    	END IF;
      END IF;  --If getOpEntityId%ROWCOUNT<1
      CLOSE getOpEntityId;

    END IF; --If entity_type ='O'

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'gcs.plsql.GCS_UTILITY_PKG.GET_ORG_ID.end',
                         TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    RETURN l_org_id;

  END Get_Org_Id;


---*************************************************************-----
 -- Procedure
  --   Get_Conversion_Rate
  -- Purpose
  --   Get the conversion rate.

  -- The API do the following:
  -- 1) Get the last date for the given cal_period_id
  -- 2) Check for a default currency treatment and if one is found
  --    do the following else proceed to step (3) :
  --        a) For the ending rate type see if a rate exists
  --           for the currency, and date combination.
  --           Return the rate if found, else return 1 plus a
  --          'NO_RATE_ERROR' code.
  --
  -- 3) Check if a rate exists for the 'Corporate' rate type,
  --    currency and date combination. Return the rate if found,
  --    else return 1 plus a 'NO_RATE_ERROR' code.
  --
  --
  -- Arguments
  --   p_source_currency	 Source Currency
  --   p_target_currency         Target Currency
  --   p_cal_period_id           Cal Period Id
  --   P_errbuf                  Error Buffer
  --   P_errcode                 Error Code
  -- Example
  --   GCS_UTILITY_PKG.Get_Conversion_Rate('EUR', 'USD',
  --                                        24528210000000000000061000200140,
  --                                        l_errbuf,
  --                                        l_errcode);
  -- Notes
  --

 PROCEDURE  get_conversion_rate (P_Source_Currency IN	 	VARCHAR2,
                                 P_Target_Currency IN     	VARCHAR2,
  			         p_cal_period_Id   IN		NUMBER,
                                 p_conversion_rate IN OUT NOCOPY          NUMBER,
                                 P_errbuf     IN OUT  NOCOPY   	VARCHAR2,
                                 p_errcode    IN OUT   NOCOPY  	NUMBER) IS

   l_period_end_date      DATE;
   l_rate_type            VARCHAR2(90);
   l_conv_rate      NUMBER;

  BEGIN


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                  'gcs.plsql.gcs_utility_pkg.get_conversion_rate. begin',
                   null);
    END IF;
    p_errbuf := 'SUCCESS';
    -- Get the period end date.

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'gcs.plsql.gcs_utility_pkg.get_conversion_rate.Get the period end date.'
       , null);
     END IF;

       SELECT DATE_ASSIGN_VALUE
       INTO   l_period_end_date
       FROM   fem_cal_periods_attr fcpa
       WHERE  fcpa.cal_period_id = p_cal_period_id
       AND    fcpa.attribute_id =
           gcs_utility_pkg.g_dimension_attr_info ('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id
       AND    fcpa.version_id   =
           gcs_utility_pkg.g_dimension_attr_info ('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;


    BEGIN
        -- Get the default currency treatment.

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'gcs.plsql.gcs_utility_pkg.'
                     ||'get_conversion_rate'
                     ||'Source Currency: '||P_source_currency
                     ||' Target Currency: '||P_Target_currency
                     ||' End Date: '||l_period_end_date,
                     null);
     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'gcs.plsql.gcs_utility_pkg.'
                     ||'get_conversion_rate.Get the default rate type',
                      null);
     END IF;


         SELECT Ending_Rate_Type
         INTO   l_rate_type
         FROM   GCS_CURR_TREATMENTS_B
         WHERE  ENABLED_FLAG = 'Y'
         AND    DEFAULT_FLAG = 'Y';


      BEGIN
         -- Get the conversion rate for the above ending_rate_type and
         -- period end date combination.

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                 'gcs.plsql.gcs_utility_pkg.get_conversion_rate.'
                  ||'Get the rate for default rate type and period '
                  ||'end  date combination', null);
         END IF;


        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'gcs.plsql.gcs_utility_pkg.'
                     ||'get_conversion_rate'
                     ||' Default Conversion Type: '||l_rate_type,
                     null);
        END IF;


         SELECT conversion_rate
         INTO   l_conv_rate
         FROM   GL_DAILY_RATES
         WHERE  From_Currency = p_Source_Currency
         AND    TO_Currency   = P_Target_Currency
         AND    Conversion_type = l_rate_type
         AND    Conversion_date = l_period_end_date;

      EXCEPTION

       WHEN OTHERS  THEN

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'gcs.plsql.gcs_utility_pkg.'
                 ||'get_conversion_rate'|| SUBSTR(SQLERRM, 1, 255), null);
          END IF;

          l_conv_rate := 1;
          p_errbuf := 'NO_RATE_ERROR';
          p_errcode := 2;

      END;

     EXCEPTION
       WHEN OTHERS THEN
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'gcs.plsql.gcs_utility_pkg.'
                 ||'get_conversion_rate'|| SUBSTR(SQLERRM, 1, 255), null);
         END IF;

         -- Get the conversion Rate for 'Corporate' rate type and period
         -- end date combination.

        BEGIN

         -- Get the conversion Rate for 'Corporate' rate type and period
         -- end date combination.

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                  'gcs.plsql.gcs_utility_pkg.get_conversion_rate.'
                   ||'Get the rate for ''Corporate''rate type and period '
                   ||'end date combination', null);
           END IF;

           SELECT conversion_rate
           INTO   l_conv_rate
           FROM   GL_DAILY_RATES
           WHERE  From_Currency = p_Source_Currency
           AND    TO_Currency   = P_Target_Currency
           AND    Conversion_type = 'Corporate'
           AND    Conversion_date = l_period_end_date;

         EXCEPTION

           WHEN OTHERS THEN
             l_conv_rate := 1;
             p_errbuf := 'NO_RATE_ERROR';
             p_errcode :=2;

        END; -- Corporate Type Block Ends

    END;  -- Default Rate Type Block End;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         gcs_utility_pkg.g_module_success
                         || ' '
                         || 'gcs.plsql.gcs_utility_pkg.'
                         ||'get_conversion_rate'
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'),
                          null);

    END IF;

  p_conversion_rate := l_conv_rate;
  p_errbuf := p_errbuf;
  p_errcode := 1;

  EXCEPTION
       WHEN OTHERS THEN

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         gcs_utility_pkg.g_module_success
                         || ' '
                         || 'gcs.plsql.gcs_utility_pkg.'
                         ||'get_conversion_rate'
                         || '() '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'),
                          null);
          END IF;
          p_conversion_rate := 1;
          p_errbuf := 'NO_RATE_ERROR';
          p_errcode :=2;


 END get_conversion_rate;

  --
  -- Function
  --   populate_calendar_map_details
  -- Purpose
  --   Takes the source calendar period and maps it to the target calendar period
  -- Arguments
  --   p_source_cal_period_id   Calendar Period
  -- Example
  -- Notes
  --

  PROCEDURE populate_calendar_map_details(p_cal_period_id 	IN	NUMBER,
					  p_source_period_flag	IN	VARCHAR2,
					  p_greater_than_flag	IN	VARCHAR2)

  IS

    l_data_exists		NUMBER(15);
    l_cal_period_record		gcs_utility_pkg.r_cal_period_info;
    l_period_num_attr 		NUMBER		:=
						gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').attribute_id;
    l_period_num_version	NUMBER		:=
						gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').version_id;
    l_period_year_attr		NUMBER		:=
						gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id;
    l_period_year_version	NUMBER		:=
						gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id;

  BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.populate_calendar_map_details.begin', '<<Enter>>');
    END IF;

    delete from gcs_cal_period_maps_gt;

    gcs_utility_pkg.get_cal_period_details(  p_cal_period_id,
                                             l_cal_period_record);

    --Insert one row where source and target are the same
    INSERT INTO       gcs_cal_period_maps_gt
    ( source_cal_period_id,
      target_cal_period_id)
    VALUES
    ( p_cal_period_id,
      p_cal_period_id);


    IF (p_source_period_flag			=	'N') THEN

      IF (p_greater_than_flag			=	'N') THEN

        --Insert all mapping options
        INSERT INTO	gcs_cal_period_maps_gt
        ( 	source_cal_period_id,
		target_cal_period_id)
        SELECT	fcpb_source.cal_period_id,
		p_cal_period_id
        FROM	fem_cal_periods_b	fcpb_source,
		fem_cal_periods_b	fcpb_target,
		gcs_cal_period_maps	gcpm,
		fem_cal_periods_attr	fcpb_source_num,
		fem_cal_periods_attr	fcpb_source_year,
		gcs_cal_period_map_dtls	gcpmd
        WHERE	fcpb_target.cal_period_id		=	p_cal_period_id
        AND	fcpb_target.calendar_id			=	gcpm.target_calendar_id
        AND	fcpb_target.dimension_group_id		=	gcpm.target_dimension_group_id
        AND	gcpm.cal_period_map_id			=	gcpmd.cal_period_map_id
        AND 	gcpmd.target_period_number		=	l_cal_period_record.cal_period_number
        AND	fcpb_source_num.attribute_id		=	l_period_num_attr
        AND	fcpb_source_num.version_id		=	l_period_num_version
        AND	fcpb_source_year.attribute_id		=	l_period_year_attr
        AND	fcpb_source_year.version_id		=	l_period_year_version
        AND	fcpb_source.cal_period_id		=	fcpb_source_num.cal_period_id
        AND	fcpb_source.cal_period_id		=	fcpb_source_year.cal_period_id
        AND	fcpb_source.calendar_id			=	gcpm.source_calendar_id
        AND	fcpb_source.dimension_group_id		=	gcpm.source_dimension_group_id
        AND	fcpb_source_num.number_assign_value	=	gcpmd.source_period_number
        AND	fcpb_source_year.number_assign_value	=	DECODE(gcpmd.target_relative_year_code,
									'CURRENT', l_cal_period_record.cal_period_year,
									'PRIOR', l_cal_period_record.cal_period_year + 1,
									'FOLLOWING', l_cal_period_record.cal_period_year - 1);
      ELSE

        --Insert all mapping options
        INSERT INTO     gcs_cal_period_maps_gt
        (       source_cal_period_id,
                target_cal_period_id)
        SELECT  fcpb_source.cal_period_id,
                fcpb_target.cal_period_id
        FROM    fem_cal_periods_b       fcpb_source,
                fem_cal_periods_b       fcpb_target,
                gcs_cal_period_maps     gcpm,
                fem_cal_periods_attr    fcpb_source_num,
                fem_cal_periods_attr    fcpb_source_year,
                gcs_cal_period_map_dtls gcpmd
        WHERE   fcpb_target.cal_period_id               >=       p_cal_period_id
        AND     fcpb_target.calendar_id                 =       gcpm.target_calendar_id
        AND     fcpb_target.dimension_group_id          =       gcpm.target_dimension_group_id
        AND     gcpm.cal_period_map_id                  =       gcpmd.cal_period_map_id
        AND     gcpmd.target_period_number              =       l_cal_period_record.cal_period_number
        AND     fcpb_source_num.attribute_id            =       l_period_num_attr
        AND     fcpb_source_num.version_id              =       l_period_num_version
        AND     fcpb_source_year.attribute_id           =       l_period_year_attr
        AND     fcpb_source_year.version_id             =       l_period_year_version
        AND     fcpb_source.cal_period_id               =       fcpb_source_num.cal_period_id
        AND     fcpb_source.cal_period_id               =       fcpb_source_year.cal_period_id
        AND     fcpb_source.calendar_id                 =       gcpm.source_calendar_id
        AND     fcpb_source.dimension_group_id          =       gcpm.source_dimension_group_id
        AND     fcpb_source_num.number_assign_value     =       gcpmd.source_period_number
        AND     fcpb_source_year.number_assign_value    =       DECODE(gcpmd.target_relative_year_code,
                                                                        'CURRENT', l_cal_period_record.cal_period_year,
                                                                        'PRIOR', l_cal_period_record.cal_period_year + 1,
                                                                        'FOLLOWING', l_cal_period_record.cal_period_year - 1);
        INSERT INTO	gcs_cal_period_maps_gt
	(	source_cal_period_id,
		target_cal_period_id)
	SELECT	distinct target_cal_period_id,
		target_cal_period_id
	FROM	gcs_cal_period_maps_gt
	WHERE	target_cal_period_id			<>	p_cal_period_id;

      END IF;

    ELSE
      --Insert all mapping options
      INSERT INTO       gcs_cal_period_maps_gt
      (         source_cal_period_id,
                target_cal_period_id)
      SELECT    p_cal_period_id,
                fcpb_target.cal_period_id
      FROM      fem_cal_periods_b       fcpb_source,
                fem_cal_periods_b       fcpb_target,
                gcs_cal_period_maps     gcpm,
                fem_cal_periods_attr    fcpb_target_num,
                fem_cal_periods_attr    fcpb_target_year,
                gcs_cal_period_map_dtls gcpmd
      WHERE     fcpb_source.cal_period_id               =       p_cal_period_id
      AND       fcpb_source.calendar_id                 =       gcpm.source_calendar_id
      AND       fcpb_source.dimension_group_id          =       gcpm.source_dimension_group_id
      AND       gcpm.cal_period_map_id                  =       gcpmd.cal_period_map_id
      AND       gcpmd.source_period_number              =       l_cal_period_record.cal_period_number
      AND       fcpb_target_num.attribute_id            =       l_period_num_attr
      AND       fcpb_target_num.version_id              =       l_period_num_version
      AND       fcpb_target_year.attribute_id           =       l_period_year_attr
      AND       fcpb_target_year.version_id             =       l_period_year_version
      AND       fcpb_target.cal_period_id               =       fcpb_target_num.cal_period_id
      AND       fcpb_target.cal_period_id               =       fcpb_target_year.cal_period_id
      AND       fcpb_target.calendar_id                 =       gcpm.target_calendar_id
      AND       fcpb_target.dimension_group_id          =       gcpm.target_dimension_group_id
      AND       fcpb_target_num.number_assign_value     =       gcpmd.target_period_number
      AND       fcpb_target_year.number_assign_value    =       DECODE(gcpmd.target_relative_year_code,
                                                                        'CURRENT', l_cal_period_record.cal_period_year,
                                                                        'PRIOR', l_cal_period_record.cal_period_year - 1,
                                                                        'FOLLOWING', l_cal_period_record.cal_period_year + 1);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs.plsql.gcs_utility_pkg.init_dimension_attr_info.end', '<<Exit>>');
    END IF;

  END;



---*************************************************************-----
  --
  -- Function
  --   Get_Associated_Value_Set_Id
  -- Purpose
  --   Get associated_value_set_id for the dimension
  -- Arguments
  --   p_dim_col Dimension
  -- Example
  --   GCS_UTILITY_PKG.Get_Associated_Value_Set_Id('LINE_ITEM_ID')
  -- Notes
  --

  FUNCTION Get_Associated_Value_Set_Id(p_dim_col VARCHAR2) RETURN NUMBER IS
  BEGIN
    return g_gcs_dimension_info(p_dim_col).associated_value_set_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return -1;
  END Get_Associated_Value_Set_Id;

---*************************************************************-----

BEGIN

  init_dimension_attr_info();
  init_dimension_info();

  BEGIN
    SELECT 	 fch_global_vs_combo_id
    INTO	 g_fch_global_vs_combo_id
    FROM	 gcs_system_options;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

END GCS_UTILITY_PKG;



/
