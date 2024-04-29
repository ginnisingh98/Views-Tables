--------------------------------------------------------
--  DDL for Package Body GCS_TRANSLATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_TRANSLATION_PKG" as
/* $Header: gcsxlatb.pls 120.7 2007/06/28 12:27:36 vkosuri noship $ */

--
-- PRIVATE TYPES
--
  TYPE RefCursor IS REF CURSOR;

--
-- PRIVATE GLOBAL VARIABLES
--
  -- The API name
  g_api			CONSTANT VARCHAR2(40) := 'gcs.plsql.GCS_TRANSLATION_PKG';

  -- The dimension information table
  g_dims	gcs_utility_pkg.t_hash_gcs_dimension_info;

  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter	CONSTANT VARCHAR2(2) := '>>';
  g_module_success	CONSTANT VARCHAR2(2) := '<<';
  g_module_failure	CONSTANT VARCHAR2(2) := '<x';

  -- A newline character. Included for convenience when writing long strings.
  g_nl	CONSTANT VARCHAR2(1) := '
';

--
-- PRIVATE EXCEPTIONS
--

  GCS_CCY_INVALID_ENTRY		EXCEPTION;
  GCS_CCY_INVALID_REL		EXCEPTION;
  GCS_CCY_INVALID_CCY_TREAT	EXCEPTION;
  GCS_CCY_INVALID_CHILD		EXCEPTION;
  GCS_CCY_INVALID_PARENT	EXCEPTION;
  GCS_CCY_INVALID_HIERARCHY	EXCEPTION;
  GCS_CCY_INVALID_PERIOD	EXCEPTION;
  GCS_CCY_INVALID_TARGET_CCY	EXCEPTION;
  GCS_CCY_INVALID_LEDGER	EXCEPTION;
  GCS_CCY_INVALID_DATASET	EXCEPTION;
  GCS_CCY_INVALID_ORG_TRACKING	EXCEPTION;
  GCS_CCY_INVALID_SEC_TRACKING	EXCEPTION;
  GCS_CCY_NO_END_DATE		EXCEPTION;
  GCS_CCY_NO_RE_TEMPLATE	EXCEPTION;
  GCS_CCY_NO_DATA		EXCEPTION;
  GCS_CCY_NO_RE_ACCT_CREATED	EXCEPTION;
  GCS_CCY_NO_RE_ACCT_UPDATED	EXCEPTION;
  GCS_CCY_NO_RATE_CREATED	EXCEPTION;
  GCS_CCY_NO_RATE_UPDATED	EXCEPTION;
  GCS_CCY_NO_END_RATE		EXCEPTION;
  GCS_CCY_NO_AVG_RATE		EXCEPTION;
  GCS_CCY_NO_DATASET		EXCEPTION;
  GCS_CCY_AVG_RATE_NOT_FOUND	EXCEPTION;
  GCS_CCY_END_RATE_NOT_FOUND	EXCEPTION;
  GCS_CCY_NO_SS_CODE		EXCEPTION;
  GCS_CCY_NO_ATTR_VERSION	EXCEPTION;
  GCS_CCY_NO_SPECIFIC_INTERCO	EXCEPTION;

--
-- PRIVATE PROCEDURES/FUNCTIONS
--

  --
  -- Procedure
  --   Module_Log_Write
  -- Purpose
  --   Write the procedure or function entered or exited, and the time that
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module		Name of the module
  --   p_action_type	Entered, Exited Successfully, or Exited with Failure
  -- Example
  --   GCS_TRANSLATION_PKG.Module_Log_Write
  -- Notes
  --
  PROCEDURE Module_Log_Write
    (p_module		VARCHAR2,
     p_action_type	VARCHAR2) IS
  BEGIN
    -- Only print if the log level is set at the appropriate level
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE, g_api || '.' || p_module,
                     p_action_type || ' ' || p_module || '() ' ||
                     to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
--    FND_FILE.PUT_LINE(FND_FILE.LOG, p_action_type || ' ' || p_module ||
--                      '() ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
  END Module_Log_Write;

  --
  -- Procedure
  --   Write_To_Log
  -- Purpose
  --   Write the text given to the log in 3500 character increments
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module		Name of the module
  --   p_level		Logging level
  --   p_text		Text to write
  -- Example
  --   GCS_TRANSLATION_PKG.Write_To_Log
  -- Notes
  --
  PROCEDURE Write_To_Log
    (p_module	VARCHAR2,
     p_level	NUMBER,
     p_text	VARCHAR2)
  IS
    api_module_concat	VARCHAR2(200);
    text_with_date	VARCHAR2(32767);
    text_with_date_len	NUMBER;
    curr_index		NUMBER;
  BEGIN
    -- Only print if the log level is set at the appropriate level
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= p_level THEN
      api_module_concat := g_api || '.' || p_module;
      text_with_date := to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||g_nl||p_text;
      text_with_date_len := length(text_with_date);
      curr_index := 1;
      WHILE curr_index <= text_with_date_len LOOP
        fnd_log.string(p_level, api_module_concat,
                       substr(text_with_date, curr_index, 3500));
        curr_index := curr_index + 3500;
      END LOOP;
    END IF;
  END Write_To_Log;

  --
  -- Procedure
  --   Set_Globals
  -- Purpose
  --   Sets all the global variables necessary for GCS Translation.
  -- Example
  --   GCS_TRANSLATION_PKG.Set_Globals;
  -- Notes
  --
  PROCEDURE Set_Globals IS
    module	VARCHAR2(30);
  BEGIN
    module := 'SET_GLOBALS';
    module_log_write(module, g_module_enter);

    g_fnd_user_id := fnd_global.user_id;
    g_fnd_login_id := fnd_global.login_id;

    -- Initialize the dimension attribute and dimension information.
    GCS_UTILITY_PKG.init_dimension_attr_info;
    GCS_UTILITY_PKG.init_dimension_info;

    g_cp_end_date_attr_id := GCS_UTILITY_PKG.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id;

    g_li_acct_type_attr_id := GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id;

    g_xat_sign_attr_id := GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').attribute_id;

    g_xat_basic_acct_type_attr_id := GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id;

    g_cp_end_date_v_id := GCS_UTILITY_PKG.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;

    g_li_acct_type_v_id := GCS_UTILITY_PKG.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id;

    g_xat_sign_v_id := GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-SIGN').version_id;

    g_xat_basic_acct_type_v_id := GCS_UTILITY_PKG.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id;

    g_dims := gcs_utility_pkg.g_gcs_dimension_info;

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_GLOBALS_UNEXP_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Set_Globals;

  --
  -- Procedure
  --   Get_Setup_Data
  -- Purpose
  --   Get all the data necessary to perform this translation, such as the
  --   translation mode, source and target currencies, etc.
  -- Arguments
  --   p_cal_period_id		Period that is to be translated.
  --   p_cons_relationship_id	The relationship for which this translation
  --				is taking place.
  --   p_balance_type_code	'ACTUAL', 'ADB', or 'BUDGET' translation.
  --   x_dataset_code		Dataset for which this translation is being
  --				performed.
  --   x_cal_period_info	Information regarding this period.
  --   x_curr_treatment_id	Currency Treatment.
  --   x_eq_translation_mode	YTD or PTD mode equity translation.
  --   x_is_translation_mode	YTD or PTD mode income statement translation.
  --   x_per_rate_type_name	Period End Rate Type Name.
  --   x_per_avg_rate_type_name	Period Average Rate Type Name.
  --   x_hierarchy_id		Consolidation Hierarchy.
  --   x_child_entity_id	Entity on which translation is being performed.
  --   x_parent_entity_id	Parent entity for consolidation relationship.
  --   x_ledger_id		Ledger of the child entity.
  --   x_source_currency	From currency.
  --   x_target_currency	To currency.
  --   x_period_end_date	Last day of this period.
  --   x_period_end_rate	Period End Rate.
  --   x_period_avg_rate	Period Average Rate.
  --   x_ccy_round_factor	The minimum accountable unit or precision for
  --				the parent currency.
  --   x_first_ever_period	Y/N whether this is the first period ever
  --				translated for the relationship.
  --   x_re_tmp			Retained Earnings template.
  --   x_cta_tmp		CTA account template.
  --   x_org_tracking_flag	'Y' (balance by org) or 'N' (don't)
  --   x_secondary_dim_col	Secondary tracking dimension column name.
  --   x_source_system_code	Source System Code for GCS.
  --   x_specific_interco_id	Specific intercomany id if applicable.
  --   x_group_by_flag		Whether or not a group by is needed in the
  --				SQL statements for translation.
  --   x_hier_li_id             Retained earnings' line item id.
  -- Example
  --   GCS_TRANSLATION_PKG.Get_Setup_Data;
  -- Notes
  --
  PROCEDURE Get_Setup_Data
    (p_cal_period_id		NUMBER,
     p_cons_relationship_id	NUMBER,
     p_balance_type_code	VARCHAR2,
     p_hier_dataset_code	NUMBER,
     x_cal_period_info		OUT NOCOPY GCS_UTILITY_PKG.r_cal_period_info,
     x_curr_treatment_id	OUT NOCOPY NUMBER,
     x_eq_translation_mode	OUT NOCOPY VARCHAR2,
     x_is_translation_mode	OUT NOCOPY VARCHAR2,
     x_per_rate_type_name	OUT NOCOPY VARCHAR2,
     x_per_avg_rate_type_name	OUT NOCOPY VARCHAR2,
     x_hierarchy_id		OUT NOCOPY NUMBER,
     x_child_entity_id		OUT NOCOPY NUMBER,
     x_parent_entity_id		OUT NOCOPY NUMBER,
     x_ledger_id		OUT NOCOPY NUMBER,
     x_source_currency		OUT NOCOPY VARCHAR2,
     x_target_currency		OUT NOCOPY VARCHAR2,
     x_period_end_date		OUT NOCOPY DATE,
     x_period_end_rate		OUT NOCOPY NUMBER,
     x_period_avg_rate		OUT NOCOPY NUMBER,
     x_ccy_round_factor		OUT NOCOPY NUMBER,
     x_first_ever_period	OUT NOCOPY VARCHAR2,
     x_re_tmp			OUT NOCOPY GCS_TEMPLATES_PKG.TemplateRecord,
     x_cta_tmp			OUT NOCOPY GCS_TEMPLATES_PKG.TemplateRecord,
     x_org_tracking_flag	OUT NOCOPY VARCHAR2,
     x_secondary_dim_col	OUT NOCOPY VARCHAR2,
     x_source_system_code	OUT NOCOPY NUMBER,
     x_specific_interco_id	OUT NOCOPY NUMBER,
     x_group_by_flag		OUT NOCOPY VARCHAR2,
     x_hier_li_id               OUT NOCOPY NUMBER) IS

    my_lang	VARCHAR2(30);

    -- Used to obtain the period name given the cal_period_id
    CURSOR	period_name_c IS
    SELECT	cal_period_name
    FROM	fem_cal_periods_tl
    WHERE	cal_period_id = p_cal_period_id
    AND		language = my_lang;

    -- Used to obtain the entity name given the entity_id
    CURSOR	entity_name_c(c_entity_id NUMBER) IS
    SELECT	entity_name
    FROM	fem_entities_tl
    WHERE	entity_id = c_entity_id
    AND		language = my_lang;

    -- Used to obtain relationship information.
    CURSOR	relationship_c IS
    SELECT	rel.hierarchy_id,
		rel.child_entity_id,
		rel.parent_entity_id,
		rel.curr_treatment_id
    FROM	gcs_cons_relationships rel
    WHERE	rel.cons_relationship_id = p_cons_relationship_id;

    -- Used to obtain currency treatment information including cta template.
    CURSOR	curr_treatment_c(c_curr_treatment_id NUMBER) IS
    SELECT	equity_mode_code,
		inc_stmt_mode_code,
		ending_rate_type,
		average_rate_type,
		financial_elem_id, product_id,
		natural_account_id, channel_id, line_item_id, project_id,
		customer_id, task_id, cta_user_dim1_id, cta_user_dim2_id,
		cta_user_dim3_id, cta_user_dim4_id, cta_user_dim5_id,
		cta_user_dim6_id, cta_user_dim7_id, cta_user_dim8_id,
		cta_user_dim9_id, cta_user_dim10_id
    FROM	gcs_curr_treatments_b ctb
    WHERE	curr_treatment_id = c_curr_treatment_id;

    -- Used to obtain entity information for the parent
    CURSOR	entity_c(c_entity_id NUMBER, c_hierarchy_id NUMBER) IS
    SELECT	eca.currency_code
    FROM	gcs_entity_cons_attrs eca
    WHERE	eca.entity_id = c_entity_id
    AND		eca.hierarchy_id = c_hierarchy_id;

    -- Used to obtain hierarchy information
    CURSOR	hierarchy_c(c_hierarchy_id NUMBER) IS
    SELECT	balance_by_org_flag,
		column_name,
		fem_ledger_id
    FROM	gcs_hierarchies_b
    WHERE	hierarchy_id = c_hierarchy_id;

    -- Used to get the specific intercompany information
    CURSOR	category_c IS
    SELECT	specific_intercompany_id
    FROM	gcs_categories_b
    WHERE	category_code = 'INTRACOMPANY';

    -- Used to determine if translation is being run for the first time for
    -- this relationship and dataset.
    CURSOR	is_earliest_period_c(	c_hierarchy_id		NUMBER,
					c_entity_id		NUMBER,
					c_currency_code		VARCHAR2) IS
    SELECT	decode(earliest_ever_period_id, p_cal_period_id, 'Y', 'N')
    FROM	gcs_translation_track_h
    WHERE	hierarchy_id = c_hierarchy_id
    AND		entity_id = c_entity_id
    AND		currency_code = c_currency_code
    AND		dataset_code = p_hier_dataset_code;

    -- Used to get the end date of the period for which translation is
    -- being run.
    CURSOR	end_date_c IS
    SELECT	fcpa_period_end_date.date_assign_value
    FROM	fem_cal_periods_attr fcpa_period_end_date
    WHERE	fcpa_period_end_date.cal_period_id = p_cal_period_id
    AND		fcpa_period_end_date.attribute_id = g_cp_end_date_attr_id
    AND		fcpa_period_end_date.version_id = g_cp_end_date_v_id;

    -- Used to get the retained earnings template.
    CURSOR	re_template_c(c_hierarchy_id	NUMBER) IS
    SELECT	financial_elem_id, product_id, natural_account_id, channel_id,
		line_item_id, project_id, customer_id, task_id, user_dim1_id,
		user_dim2_id, user_dim3_id, user_dim4_id, user_dim5_id,
		user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id,
		user_dim10_id
    FROM	GCS_DIMENSION_TEMPLATES
    WHERE	hierarchy_id = c_hierarchy_id
    AND		template_code = 'RE';

    -- Used to get the minimum accountable unit for the currency given.
    CURSOR	ccy_mau_c(c_ccy VARCHAR2) IS
    SELECT	nvl(minimum_accountable_unit, power(10, -precision))
    FROM	fnd_currencies
    WHERE	currency_code = c_ccy;

    -- Get the source system code for GCS
    CURSOR	source_system_code_c IS
    SELECT	source_system_code
    FROM	fem_source_systems_b
    WHERE	source_system_display_code = 'GCS';

    -- Used to get the end and average rate type names
    CURSOR	rate_type_name_c(c_rate_type VARCHAR2) IS
    SELECT	user_conversion_type
    FROM	gl_daily_conversion_types
    WHERE	conversion_type = c_rate_type;

     -- Used to get the entity type
    CURSOR	entity_type_c(c_entity_id NUMBER) IS
    SELECT	fea.dim_attribute_varchar_member
    FROM	fem_entities_attr fea,
		fem_dim_attributes_b fdab,
		fem_dim_attr_versions_b fdavb
    WHERE	fea.entity_id = c_entity_id
    AND		fea.attribute_id = fdab.attribute_id
    AND		fea.version_id = fdavb.version_id
    AND		fdab.attribute_varchar_label = 'ENTITY_TYPE_CODE'
    AND         fdavb.attribute_id = fdab.attribute_id
    AND         fdavb.default_version_flag = 'Y';

    -- See whether there are any non-DataPrep rows in an operating entity
    CURSOR	source_balance_c(
		  c_cal_period_id	NUMBER,
		  c_source_system_code	NUMBER,
		  c_currency_code	VARCHAR2,
		  c_ledger_id		NUMBER,
		  c_entity_id		NUMBER) IS
    SELECT	1
    FROM	fem_balances fb,
		gcs_categories_b cb
    WHERE	fb.dataset_code = p_hier_dataset_code
    AND		fb.cal_period_id = c_cal_period_id
    AND		fb.source_system_code = c_source_system_code
    AND		fb.currency_code = c_currency_code
    AND		fb.ledger_id = c_ledger_id
    AND		fb.entity_id = c_entity_id
    AND		fb.created_by_object_id <> cb.associated_object_id
    AND		cb.category_code = 'DATAPREPARATION';


    -- Bugfix 5707630: Cursor returns the line item id slected for retained earnings on hierarchy page.
    CURSOR  re_line_item_cur (p_hier_id NUMBER) IS
    SELECT  line_item_id
    FROM    gcs_dimension_templates
    WHERE   hierarchy_id = p_hier_id
    AND     template_code = 'RE';


    dummy		NUMBER;

    -- entity type of the child
    entity_type		VARCHAR2(30);

    -- Used for error logging
    period_name		VARCHAR2(150);

    per_rate_type	VARCHAR2(30);
    per_avg_rate_type	VARCHAR2(30);

    module	VARCHAR2(30);
  BEGIN
    module := 'GET_SETUP_DATA';
    my_lang := userenv('LANG');
    module_log_write(module, g_module_enter);

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT rel.hierarchy_id, rel.child_entity_id, ' ||
'rel.parent_entity_id, rel.curr_treatment_id' || g_nl ||
'FROM   gcs_cons_relationships rel' || g_nl ||
'WHERE  rel.cons_relationship_id = ' || p_cons_relationship_id);

    -- Get relationship information.
    OPEN relationship_c;
    FETCH relationship_c INTO x_hierarchy_id, x_child_entity_id,
                              x_parent_entity_id, x_curr_treatment_id;
    IF relationship_c%NOTFOUND THEN
      CLOSE relationship_c;
      raise GCS_CCY_INVALID_REL;
    END IF;
    CLOSE relationship_c;

    begin
      -- Get current and previous period information.
      GCS_UTILITY_PKG.get_cal_period_details(p_cal_period_id, x_cal_period_info);
    exception
      when others then
        raise GCS_CCY_INVALID_PERIOD;
    end;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT cal_period_name' || g_nl ||
'FROM   fem_cal_periods_tl' || g_nl ||
'WHERE  cal_period_id = ' || p_cal_period_id || g_nl ||
'AND    language = ''' || my_lang || '''');

    -- Get the period name
    OPEN period_name_c;
    FETCH period_name_c INTO period_name;
    IF period_name_c%NOTFOUND THEN
      CLOSE period_name_c;
      raise GCS_CCY_INVALID_PERIOD;
    END IF;
    CLOSE period_name_c;


    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT	balance_by_org_flag, column_name, fem_ledger_id' || g_nl||
'FROM	gcs_hierarchies_b' || g_nl ||
'WHERE	hierarchy_id = ' || x_hierarchy_id);

    -- Get org tracking and secondary tracking information.
    OPEN hierarchy_c(x_hierarchy_id);
    FETCH hierarchy_c INTO x_org_tracking_flag, x_secondary_dim_col, x_ledger_id;
    IF hierarchy_c%NOTFOUND THEN
      CLOSE hierarchy_c;
      raise GCS_CCY_INVALID_HIERARCHY;
    END IF;
    CLOSE hierarchy_c;


    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT	specific_intercompany_id' || g_nl||
'FROM	gcs_categories_b' || g_nl ||
'WHERE	category_code = ''INTRACOMPANY''');

    -- Get the intercompany information
    OPEN category_c;
    FETCH category_c INTO x_specific_interco_id;
    IF category_c%NOTFOUND THEN
      CLOSE category_c;
      raise GCS_CCY_NO_SPECIFIC_INTERCO;
    END IF;
    CLOSE category_c;


    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT equity_mode_code, inc_stmt_mode_code, ending_rate_type, ' ||
'average_rate_type, financial_elem_id, ' ||
'product_id, natural_account_id, channel_id, line_item_id, project_id, ' ||
'customer_id, task_id, cta_user_dim1_id, cta_user_dim2_id, ' ||
'cta_user_dim3_id, cta_user_dim4_id, cta_user_dim5_id, cta_user_dim6_id, ' ||
'cta_user_dim7_id, cta_user_dim8_id, cta_user_dim9_id, ' ||
'cta_user_dim10_id' || g_nl ||
'FROM   gcs_curr_treatments_b ctb' || g_nl ||
'WHERE  curr_treatment_id = ' || x_curr_treatment_id);

    -- Get information on the currency_treatment.
    OPEN curr_treatment_c(x_curr_treatment_id);
    FETCH curr_treatment_c INTO
      x_eq_translation_mode, x_is_translation_mode, per_rate_type,
      per_avg_rate_type,
      x_cta_tmp.financial_elem_id, x_cta_tmp.product_id,
      x_cta_tmp.natural_account_id, x_cta_tmp.channel_id,
      x_cta_tmp.line_item_id, x_cta_tmp.project_id, x_cta_tmp.customer_id,
      x_cta_tmp.task_id, x_cta_tmp.user_dim1_id, x_cta_tmp.user_dim2_id,
      x_cta_tmp.user_dim3_id, x_cta_tmp.user_dim4_id, x_cta_tmp.user_dim5_id,
      x_cta_tmp.user_dim6_id, x_cta_tmp.user_dim7_id, x_cta_tmp.user_dim8_id,
      x_cta_tmp.user_dim9_id, x_cta_tmp.user_dim10_id;
    IF curr_treatment_c%NOTFOUND THEN
      CLOSE curr_treatment_c;
      raise GCS_CCY_INVALID_CCY_TREAT;
    END IF;
    CLOSE curr_treatment_c;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT user_conversion_type' || g_nl ||
'FROM   gl_daily_conversion_types' || g_nl ||
'WHERE  conversion_type = ''' || per_rate_type || '''');

    OPEN rate_type_name_c(per_rate_type);
    FETCH rate_type_name_c INTO x_per_rate_type_name;
    IF rate_type_name_c%NOTFOUND THEN
      CLOSE rate_type_name_c;
      raise GCS_CCY_END_RATE_NOT_FOUND;
    END IF;
    CLOSE rate_type_name_c;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT user_conversion_type' || g_nl ||
'FROM   gl_daily_conversion_types' || g_nl ||
'WHERE  conversion_type = ''' || per_avg_rate_type || '''');

    OPEN rate_type_name_c(per_avg_rate_type);
    FETCH rate_type_name_c INTO x_per_avg_rate_type_name;
    IF rate_type_name_c%NOTFOUND THEN
      CLOSE rate_type_name_c;
      raise GCS_CCY_AVG_RATE_NOT_FOUND;
    END IF;
    CLOSE rate_type_name_c;



    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT eca.currency_code' || g_nl ||
'FROM   gcs_entity_cons_attrs eca' || g_nl ||
'WHERE  eca.entity_id = ' || x_child_entity_id || g_nl ||
'AND    eca.hierarchy_id = ' || x_hierarchy_id);

    -- Get information on the parent entity.
    OPEN entity_c(x_child_entity_id, x_hierarchy_id);
    FETCH entity_c INTO x_source_currency;
    IF entity_c%NOTFOUND THEN
      CLOSE entity_c;
      raise GCS_CCY_INVALID_CHILD;
    END IF;
    CLOSE entity_c;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT eca.currency_code' || g_nl ||
'FROM   gcs_entity_cons_attrs eca' || g_nl ||
'WHERE  eca.entity_id = ' || x_parent_entity_id || g_nl ||
'AND    eca.hierarchy_id = ' || x_hierarchy_id);

    -- Get information on the parent entity.
    OPEN entity_c(x_parent_entity_id, x_hierarchy_id);
    FETCH entity_c INTO x_target_currency;
    IF entity_c%NOTFOUND THEN
      CLOSE entity_c;
      raise GCS_CCY_INVALID_PARENT;
    END IF;
    CLOSE entity_c;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT fcpa_period_end_date.date_assign_value' || g_nl ||
'FROM   fem_cal_periods_attr fcpa_period_end_date' || g_nl ||
'WHERE  fcpa_period_end_date.cal_period_id = ' || p_cal_period_id || g_nl ||
'AND    fcpa_period_end_date.attribute_id = ' || g_cp_end_date_attr_id || g_nl ||
'AND    fcpa_period_end_date.version_id = ' || g_cp_end_date_v_id);

    -- Get the end date for this particular period
    OPEN end_date_c;
    FETCH end_date_c INTO x_period_end_date;
    IF end_date_c%NOTFOUND THEN
      CLOSE end_date_c;
      raise GCS_CCY_NO_END_DATE;
    END IF;
    CLOSE end_date_c;

    -- Get the end rate, and make sure to check for errors.
    begin
      x_period_end_rate := GL_CURRENCY_API.get_rate
                             (x_source_currency, x_target_currency,
                              x_period_end_date, per_rate_type);
      IF x_period_end_rate IS NULL THEN
        raise GCS_CCY_NO_END_RATE;
      END IF;
    exception
      when others then
        raise GCS_CCY_NO_END_RATE;
    end;

    -- Get the average rate, and make sure to check for errors.
    begin
      x_period_avg_rate := GL_CURRENCY_API.get_rate
                             (x_source_currency, x_target_currency,
                              x_period_end_date, per_avg_rate_type);
      IF x_period_avg_rate IS NULL THEN
        raise GCS_CCY_NO_AVG_RATE;
      END IF;
    exception
      when others then
        raise GCS_CCY_NO_AVG_RATE;
    end;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT financial_elem_id, product_id, ' ||
'natural_account_id, channel_id, line_item_id, project_id, customer_id, ' ||
'task_id, user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id, ' ||
'user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id, ' ||
'user_dim10_id' || g_nl ||
'FROM   GCS_DIMENSION_TEMPLATES' || g_nl ||
'WHERE  hierarchy_id = ' || x_hierarchy_id || g_nl ||
'AND    template_code = ''RE''');

    -- Get the retained earnings template.
    OPEN re_template_c(x_hierarchy_id);
    FETCH re_template_c INTO x_re_tmp;
    IF re_template_c%NOTFOUND THEN
      CLOSE re_template_c;
      raise GCS_CCY_NO_RE_TEMPLATE;
    END IF;
    CLOSE re_template_c;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT nvl(minimum_accountable_unit, power(10, -precision))' || g_nl ||
'FROM   fnd_currencies' || g_nl ||
'WHERE  currency_code = ''' || x_target_currency || '''');

    -- Get the minimum accountable unit of the target currency.
    OPEN ccy_mau_c(x_target_currency);
    FETCH ccy_mau_c INTO x_ccy_round_factor;
    IF ccy_mau_c%NOTFOUND THEN
      CLOSE ccy_mau_c;
      raise GCS_CCY_INVALID_TARGET_CCY;
    END IF;
    CLOSE ccy_mau_c;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT decode(earliest_ever_period_id, ' || p_cal_period_id ||
', ''Y'', ''N'')' || g_nl ||
'FROM   gcs_translation_track_h' || g_nl ||
'WHERE  cons_relationship_id = ' || p_cons_relationship_id || g_nl ||
'AND    dataset_code = ' || p_hier_dataset_code);

    -- Check if this is the first ever translated period. If so, this program
    -- will use the first ever translated period rule. If not, it will use
    -- the rule for non-first ever translated periods.
    OPEN is_earliest_period_c(	x_hierarchy_id, x_child_entity_id,
				x_target_currency);
    FETCH is_earliest_period_c INTO x_first_ever_period;
    IF is_earliest_period_c%NOTFOUND THEN
      x_first_ever_period := 'Y';
    END IF;
    CLOSE is_earliest_period_c;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT source_system_code' || g_nl ||
'FROM   fem_source_systems_b' || g_nl ||
'WHERE  source_system_display_code = ''GCS''');

    -- Get the source system code for GCS.
    OPEN source_system_code_c;
    FETCH source_system_code_c INTO x_source_system_code;
    IF source_system_code_c%NOTFOUND THEN
      CLOSE source_system_code_c;
      raise GCS_CCY_NO_SS_CODE;
    END IF;
    CLOSE source_system_code_c;

    -- Set the financial_elem_id of the templates appropriately if the
    -- balance type is 'ADB'
    IF p_balance_type_code = 'ADB' THEN
      x_re_tmp.financial_elem_id := gcs_utility_pkg.g_avg_fin_elem;
      x_cta_tmp.financial_elem_id := gcs_utility_pkg.g_avg_fin_elem;
    END IF;

    -- Now figure out whether a group by is needed or not
    OPEN entity_type_c(x_child_entity_id);
    FETCH entity_type_c INTO entity_type;
    IF entity_type_c%NOTFOUND THEN
      CLOSE entity_type_c;
      raise GCS_CCY_INVALID_CHILD;
    END IF;
    CLOSE entity_type_c;

    IF entity_type = 'O' THEN
      OPEN source_balance_c(x_cal_period_info.cal_period_id, x_source_system_code, x_source_currency, x_ledger_id, x_child_entity_id);
      FETCH source_balance_c INTO dummy;
      IF source_balance_c%NOTFOUND THEN
        CLOSE source_balance_c;
        x_group_by_flag := 'N';
      ELSE
        CLOSE source_balance_c;
        x_group_by_flag := 'Y';
      END IF;
    ELSE
      x_group_by_flag := 'N';
    END IF;

   -- Bugfix 5707630: Fectch the line item id from the cursor.
    OPEN re_line_item_cur(x_hierarchy_id);
    FETCH re_line_item_cur INTO x_hier_li_id;
    CLOSE re_line_item_cur;



    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_SS_CODE THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_SS_CODE_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_SPECIFIC_INTERCO THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_INTERCO_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_INVALID_PERIOD THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_INVALID_PERIOD_ERR');
      FND_MESSAGE.set_token('CAL_PERIOD_ID', p_cal_period_id);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_INVALID_REL THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_INVALID_REL_ERR');
      FND_MESSAGE.set_token('RELATIONSHIP_ID', p_cons_relationship_id);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_INVALID_CCY_TREAT THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_INVALID_CCY_TREAT_ERR');
      FND_MESSAGE.set_token('RELATIONSHIP_ID', p_cons_relationship_id);
      FND_MESSAGE.set_token('TREATMENT_ID', x_curr_treatment_id);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_INVALID_CHILD THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_CHILD_ENTITY_ERR');
      FND_MESSAGE.set_token('ENTITY_ID', x_child_entity_id);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_INVALID_PARENT THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_PARENT_ENTITY_ERR');
      FND_MESSAGE.set_token('ENTITY_ID', x_parent_entity_id);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_INVALID_HIERARCHY THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_INVALID_HIERARCHY_ERR');
      FND_MESSAGE.set_token('HIERARCHY_ID', x_hierarchy_id);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_DATASET THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_DATASET_ERR');
      FND_MESSAGE.set_token('BAL_TYPE', p_balance_type_code);
      FND_MESSAGE.set_token('HIERARCHY_ID', x_hierarchy_id);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_END_DATE THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_END_DATE_ERR');
      FND_MESSAGE.set_token('PERIOD_NAME', period_name);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_AVG_RATE_NOT_FOUND THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_RATE_NOT_FOUND_ERR');
      FND_MESSAGE.set_token('RATE_TYPE', per_avg_rate_type);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_END_RATE_NOT_FOUND THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_RATE_NOT_FOUND_ERR');
      FND_MESSAGE.set_token('RATE_TYPE', per_rate_type);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_END_RATE THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_END_RATE_ERR');
      FND_MESSAGE.set_token('PERIOD_NAME', period_name);
      FND_MESSAGE.set_token('RATE_TYPE', x_per_rate_type_name);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_AVG_RATE THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_AVG_RATE_ERR');
      FND_MESSAGE.set_token('PERIOD_NAME', period_name);
      FND_MESSAGE.set_token('RATE_TYPE', x_per_avg_rate_type_name);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_RE_TEMPLATE THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_RE_TEMPLATE_ERR');
      FND_MESSAGE.set_token('HIERARCHY_ID', x_hierarchy_id);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_INVALID_TARGET_CCY THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_INFO_NOT_FOUND_ERR');
      FND_MESSAGE.set_token('CURRENCY', x_target_currency);
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_SETUP_UNEXPECTED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Get_Setup_Data;

  --
  -- Procedure
  --   Create_RE_Sec_Tracking_Text
  -- Purpose
  --   Create part of the dynamic sql for seconday tracking in the equity
  --   calculation.
  -- Arguments
  --   p_re_acct	Retained earnings account existence check cursor.
  --   p_ins_re		Retained earnings account creation statement.
  --   p_ins_join	Retained earnings account creation statement join.
  --   p_upd_re		Retained earnings account update statement.
  --   p_sec_dim	Secondary tracking dimension column.
  --   p_curr_dim	Current dimension column being looked at.
  --   p_template_id	Template value to use.
  -- Example
  --   GCS_TRANSLATION_PKG.Create_RE_Sec_Tracking_Text;
  -- Notes
  --
  PROCEDURE Create_RE_Sec_Tracking_Text
    (p_re_acct		IN OUT NOCOPY	VARCHAR2,
     p_ins_re		IN OUT NOCOPY	VARCHAR2,
     p_ins_join		IN OUT NOCOPY	VARCHAR2,
     p_upd_re		IN OUT NOCOPY	VARCHAR2,
     p_sec_dim				VARCHAR2,
     p_curr_dim				VARCHAR2,
     p_template_id			NUMBER) IS
    module	VARCHAR2(30);
  BEGIN
    module := 'CREATE_RE_SEC_TRACKING_TEXT';
    module_log_write(module, g_module_enter);

    IF gcs_utility_pkg.get_dimension_required(p_curr_dim) = 'Y' THEN
      p_re_acct   := p_re_acct   || 'AND    '     || p_curr_dim || ' = ';
      p_ins_join  := p_ins_join  || 'AND    fb.'  || p_curr_dim || ' = ';
      p_upd_re    := p_upd_re    || 'AND    '     || p_curr_dim || ' = ';
      IF p_sec_dim = p_curr_dim THEN
        p_re_acct   := p_re_acct   || ':sec_dim_val_id' || g_nl;
        p_ins_re    := p_ins_re    || ':sec_dim_val_id, ';
        p_ins_join  := p_ins_join  || ':sec_dim_val_id' || g_nl;
        p_upd_re    := p_upd_re    || ':sec_dim_val_id' || g_nl;
      ELSE
        p_re_acct   := p_re_acct   || p_template_id || g_nl;
        p_ins_re    := p_ins_re    || p_template_id || ', ';
        p_ins_join  := p_ins_join  || p_template_id || g_nl;
        p_upd_re    := p_upd_re    || p_template_id || g_nl;
      END IF;
    ELSE
      p_ins_re := p_ins_re || 'null, ';
    END IF;

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_RE_SEC_TRK_UNEXP_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Create_RE_Sec_Tracking_Text;

  --
  -- Procedure
  --   Create_RE_Rate_Sec_Track_Text
  -- Purpose
  --   Create part of the dynamic sql for seconday tracking in the equity
  --   calculation.
  -- Arguments
  --   p_amt_text	Retained earnings rate amount calculation text.
  --   p_amt_join	Retained earnings rate amount calculation join.
  --   p_re_rate	Retained earnings rate existence check cursor.
  --   p_ins_rate	Retained earnings rate creation statement.
  --   p_upd_rate	Retained earnings rate update statement.
  --   p_sec_dim	Secondary tracking dimension column.
  --   p_curr_dim	Current dimension column being looked at.
  --   p_template_id	Template value to use.
  -- Example
  --   GCS_TRANSLATION_PKG.Create_RE_Rate_Sec_Track_Text
  -- Notes
  --
  PROCEDURE Create_RE_Rate_Sec_Track_Text
    (p_amt_text		IN OUT NOCOPY	VARCHAR2,
     p_amt_join		IN OUT NOCOPY	VARCHAR2,
     p_re_rate		IN OUT NOCOPY	VARCHAR2,
     p_ins_rate		IN OUT NOCOPY	VARCHAR2,
     p_upd_rate		IN OUT NOCOPY	VARCHAR2,
     p_sec_dim				VARCHAR2,
     p_curr_dim				VARCHAR2,
     p_template_id			NUMBER) IS
    module	VARCHAR2(30);
  BEGIN
    module := 'CREATE_RE_RATE_SEC_TRACK_TEXT';
    module_log_write(module, g_module_enter);

    IF gcs_utility_pkg.get_dimension_required(p_curr_dim) = 'Y' THEN
      p_amt_text  := p_amt_text  || '            AND fb.' || p_curr_dim || ' = ';
      p_amt_join  := p_amt_join  || '            AND el.' || p_curr_dim || ' = ';
      p_re_rate   := p_re_rate   || 'AND    '     || p_curr_dim || ' = ';
      p_upd_rate  := p_upd_rate  || 'AND    '     || p_curr_dim || ' = ';
      IF p_sec_dim = p_curr_dim THEN
        p_amt_text  := p_amt_text  || ':sec_dim_val_id' || g_nl;
        p_amt_join  := p_amt_join  || ':sec_dim_val_id' || g_nl;
        p_re_rate   := p_re_rate   || ':sec_dim_val_id' || g_nl;
        p_ins_rate  := p_ins_rate  || ':sec_dim_val_id, ';
        p_upd_rate  := p_upd_rate  || ':sec_dim_val_id' || g_nl;
      ELSE
        p_amt_text  := p_amt_text  || p_template_id || g_nl;
        p_amt_join  := p_amt_join  || p_template_id || g_nl;
        p_re_rate   := p_re_rate   || p_template_id || g_nl;
        p_ins_rate  := p_ins_rate  || p_template_id || ', ';
        p_upd_rate  := p_upd_rate  || p_template_id || g_nl;
      END IF;
    ELSE
      p_ins_rate := p_ins_rate || 'null, ';
    END IF;

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_RE_SEC_TRK_UNEXP_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Create_RE_Rate_Sec_Track_Text;

  --
  -- Procedure
  --   Create_All_RE_Tracking_Text
  -- Purpose
  --   Create all of the dynamic sql for tracking in the retained earnings
  --   calculation.
  -- Arguments
  --   p_re_acct	Retained earnings account existence check cursor.
  --   p_ins_re		Retained earnings account creation statement.
  --   p_ins_join	Retained earnings account creation statement join.
  --   p_upd_re		Retained earnings account update statement.
  --   p_org_track_flag	Whether or not org tracking is enabled.
  --   p_sec_dim_col	Secondary tracking dimension column.
  --   p_hierarchy_id	Hierarchy on which the translation is being run.
  --   p_entity_id	Entity on which the translation is being run.
  --   p_relationship_id Relationship on which the translation is being run.
  --   p_specific_interco_id	Specific intercomany id if applicable.
  --   p_re_template	Retained earnings template to use.
  -- Example
  --   GCS_TRANSLATION_PKG.Create_All_RE_Tracking_Text;
  -- Notes
  --
  PROCEDURE Create_All_RE_Tracking_Text
    (p_re_acct		IN OUT NOCOPY	VARCHAR2,
     p_ins_re		IN OUT NOCOPY	VARCHAR2,
     p_ins_join		IN OUT NOCOPY	VARCHAR2,
     p_upd_re		IN OUT NOCOPY	VARCHAR2,
     p_org_track_flag			VARCHAR2,
     p_sec_dim_col			VARCHAR2,
     p_hierarchy_id			NUMBER,
     p_entity_id			NUMBER,
     p_relationship_id			NUMBER,
     p_specific_interco_id		NUMBER,
     p_re_template			GCS_TEMPLATES_PKG.TemplateRecord) IS

    re_org_id		NUMBER; -- retained earnings org_id, if applicable
    re_interco_id	NUMBER; -- retained earnings interco_id, if applicable
    interco_text	VARCHAR2(100); -- intercompany matching text

    module	VARCHAR2(30);
  BEGIN
    module := 'CREATE_ALL_RE_TRACKING_TEXT';
    module_log_write(module, g_module_enter);

    -- First add the org tracking joins
    IF p_org_track_flag = 'Y' THEN
      IF p_specific_interco_id IS NOT NULL THEN
        interco_text := p_specific_interco_id;
      ELSE
        interco_text := ':org_id';
      END IF;

      p_re_acct := p_re_acct ||
'WHERE  company_cost_center_org_id = :org_id' || g_nl ||
'AND    intercompany_id = ' || interco_text || g_nl;
      p_ins_re := p_ins_re || ':org_id, ' || interco_text || ', ';
      p_ins_join :=
'AND    fb.company_cost_center_org_id = :org_id' || g_nl ||
'AND    fb.intercompany_id = ' || interco_text || g_nl;
      p_upd_re := p_upd_re ||
'WHERE  company_cost_center_org_id = :org_id' || g_nl ||
'AND    intercompany_id = ' || interco_text || g_nl;
    ELSE
      re_org_id := gcs_utility_pkg.get_org_id(p_entity_id, p_hierarchy_id);

      -- If a specific intercompany id is to be used, use it
      IF p_specific_interco_id IS NOT NULL THEN
        re_interco_id := p_specific_interco_id;
      ELSE
        re_interco_id := re_org_id;
      END IF;

      p_re_acct := p_re_acct ||
'WHERE  company_cost_center_org_id = ' || re_org_id || g_nl ||
'AND    intercompany_id = ' || re_interco_id || g_nl;
      p_ins_re := p_ins_re || re_org_id || ', ' || re_interco_id || ', ';
      p_ins_join :=
'AND    fb.company_cost_center_org_id = ' || re_org_id || g_nl ||
'AND    fb.intercompany_id = ' || re_interco_id || g_nl;
      p_upd_re := p_upd_re ||
'WHERE  company_cost_center_org_id = ' || re_org_id || g_nl ||
'AND    intercompany_id = ' || re_interco_id || g_nl;
    END IF;

    -- Now add the secondary tracking joins
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'FINANCIAL_ELEM_ID', p_re_template.financial_elem_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'PRODUCT_ID', p_re_template.product_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'NATURAL_ACCOUNT_ID', p_re_template.natural_account_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'CHANNEL_ID', p_re_template.channel_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'LINE_ITEM_ID', p_re_template.line_item_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'PROJECT_ID', p_re_template.project_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'CUSTOMER_ID', p_re_template.customer_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'TASK_ID', p_re_template.task_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM1_ID', p_re_template.user_dim1_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM2_ID', p_re_template.user_dim2_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM3_ID', p_re_template.user_dim3_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM4_ID', p_re_template.user_dim4_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM5_ID', p_re_template.user_dim5_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM6_ID', p_re_template.user_dim6_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM7_ID', p_re_template.user_dim7_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM8_ID', p_re_template.user_dim8_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM9_ID', p_re_template.user_dim9_id);
    create_re_sec_tracking_text(p_re_acct, p_ins_re, p_ins_join, p_upd_re, p_sec_dim_col, 'USER_DIM10_ID', p_re_template.user_dim10_id);

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_ALL_RE_TRK_UNEXP_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Create_All_RE_Tracking_Text;

  --
  -- Procedure
  --   Create_All_RE_Rate_Track_Text
  -- Purpose
  --   Create all of the dynamic sql for tracking in the retained earnings
  --   calculation.
  -- Arguments
  --   p_amt_text	Retained earnings rate amount calculation text.
  --   p_amt_join	Retained earnings rate amount calculation join.
  --   p_re_rate	Retained earnings rate existence check cursor.
  --   p_ins_rate	Retained earnings rate creation statement.
  --   p_upd_rate	Retained earnings rate update statement.
  --   p_org_track_flag	Whether or not org tracking is enabled.
  --   p_sec_dim_col	Secondary tracking dimension column.
  --   p_hierarchy_id	Hierarchy on which the translation is being run.
  --   p_entity_id	Entity on which the translation is being run.
  --   p_relationship_id Relationship on which the translation is being run.
  --   p_specific_interco_id	Specific intercomany id if applicable.
  --   p_re_template	Retained earnings template to use.
  -- Example
  --   GCS_TRANSLATION_PKG.Create_All_RE_Rate_Track_Text;
  -- Notes
  --
  PROCEDURE Create_All_RE_Rate_Track_Text
    (p_amt_text		IN OUT NOCOPY	VARCHAR2,
     p_amt_join		IN OUT NOCOPY	VARCHAR2,
     p_re_rate		IN OUT NOCOPY	VARCHAR2,
     p_ins_rate		IN OUT NOCOPY	VARCHAR2,
     p_upd_rate		IN OUT NOCOPY	VARCHAR2,
     p_org_track_flag			VARCHAR2,
     p_sec_dim_col			VARCHAR2,
     p_hierarchy_id			NUMBER,
     p_entity_id			NUMBER,
     p_relationship_id			NUMBER,
     p_specific_interco_id		NUMBER,
     p_re_template			GCS_TEMPLATES_PKG.TemplateRecord) IS

    re_org_id		NUMBER; -- retained earnings org_id, if applicable
    re_interco_id	NUMBER; -- retained earnings interco_id, if applicable
    interco_text	VARCHAR2(100); -- intercompany matching text

    module	VARCHAR2(30);
  BEGIN
    module := 'CREATE_ALL_RE_RATE_TRACK_TEXT';
    module_log_write(module, g_module_enter);

    -- First add the org tracking joins
    IF p_org_track_flag = 'Y' THEN
      IF p_specific_interco_id IS NOT NULL THEN
        interco_text := p_specific_interco_id;
      ELSE
        interco_text := ':org_id';
      END IF;

      p_amt_text := p_amt_text ||
'            fb.company_cost_center_org_id = :org_id' || g_nl ||
'            AND fb.intercompany_id = ' || interco_text || g_nl;
      p_amt_join :=
'           el.company_cost_center_org_id = :org_id' || g_nl ||
'           AND el.intercompany_id = ' || interco_text || g_nl;
      p_re_rate := p_re_rate ||
'AND    company_cost_center_org_id = :org_id' || g_nl ||
'AND    intercompany_id = ' || interco_text || g_nl;
      p_ins_rate := p_ins_rate || ':org_id, ' || interco_text || ', ';
      p_upd_rate := p_upd_rate ||
'AND    company_cost_center_org_id = :org_id' || g_nl ||
'AND    intercompany_id = ' || interco_text || g_nl;
    ELSE
      re_org_id := gcs_utility_pkg.get_org_id(p_entity_id, p_hierarchy_id);

      -- If a specific intercompany id is to be used, use it
      IF p_specific_interco_id IS NOT NULL THEN
        re_interco_id := p_specific_interco_id;
      ELSE
        re_interco_id := re_org_id;
      END IF;

      p_amt_text := p_amt_text ||
'            fb.company_cost_center_org_id = ' || re_org_id || g_nl ||
'            AND fb.intercompany_id = ' || re_interco_id || g_nl;
      p_amt_join :=
'            el.company_cost_center_org_id = ' || re_org_id || g_nl ||
'            AND el.intercompany_id = ' || re_interco_id || g_nl;
      p_re_rate := p_re_rate ||
'AND    company_cost_center_org_id = ' || re_org_id || g_nl ||
'AND    intercompany_id = ' || re_interco_id || g_nl;
      p_ins_rate := p_ins_rate || re_org_id || ', ' || re_interco_id || ', ';
      p_upd_rate := p_upd_rate ||
'AND    company_cost_center_org_id = ' || re_org_id || g_nl ||
'AND    intercompany_id = ' || re_interco_id || g_nl;
    END IF;

    -- Now add the secondary tracking joins
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'FINANCIAL_ELEM_ID', p_re_template.financial_elem_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'PRODUCT_ID', p_re_template.product_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'NATURAL_ACCOUNT_ID', p_re_template.natural_account_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'CHANNEL_ID', p_re_template.channel_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'LINE_ITEM_ID', p_re_template.line_item_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'PROJECT_ID', p_re_template.project_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'CUSTOMER_ID', p_re_template.customer_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'TASK_ID', p_re_template.task_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM1_ID', p_re_template.user_dim1_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM2_ID', p_re_template.user_dim2_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM3_ID', p_re_template.user_dim3_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM4_ID', p_re_template.user_dim4_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM5_ID', p_re_template.user_dim5_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM6_ID', p_re_template.user_dim6_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM7_ID', p_re_template.user_dim7_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM8_ID', p_re_template.user_dim8_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM9_ID', p_re_template.user_dim9_id);
    create_re_rate_sec_track_text(p_amt_text, p_amt_join, p_re_rate, p_ins_rate, p_upd_rate, p_sec_dim_col, 'USER_DIM10_ID', p_re_template.user_dim10_id);

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_ALL_RE_TRK_UNEXP_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Create_All_RE_Rate_Track_Text;

  --
  -- Procedure
  --   Calculate_RE_Amt
  -- Purpose
  --   Calculate balances for the retained earnings account.
  -- Arguments
  --   p_relationship_id The relationship for which translation is being run.
  --   p_cal_period_id	The period being translated.
  --   p_prev_period_id	The period prior to the translation period.
  --   p_entity_id	Entity on which the translation is being performed.
  --   p_hierarchy_id	Hierarchy in which the entity resides.
  --   p_ledger_id	Ledger of the entity to be translated.
  --   p_from_ccy	From currency code.
  --   p_to_ccy		To currency code.
  --   p_eq_xlate_mode	Equity translation mode (YTD or PTD).
  --   p_dataset_code	Actual or budget translation.
  --   p_org_track_flag	Whether org tracking is enabled.
  --   p_sec_dim_col	Secondary tracking dimension column.
  --   p_re_template	Retained earnings template.
  --   p_source_system_code	Source System Code for GCS.
  --   p_specific_interco_id	Specific intercomany id if applicable.
  -- Example
  --   GCS_TRANSLATION_PKG.Calculate_RE_Amt;
  -- Notes
  --
  PROCEDURE Calculate_RE_Amt
    (p_relationship_id	NUMBER,
     p_cal_period_id	NUMBER,
     p_prev_period_id	NUMBER,
     p_entity_id	NUMBER,
     p_hierarchy_id	NUMBER,
     p_ledger_id	NUMBER,
     p_from_ccy		VARCHAR2,
     p_to_ccy		VARCHAR2,
     p_eq_xlate_mode	VARCHAR2,
     p_hier_dataset_code	NUMBER,
     p_org_track_flag	VARCHAR2,
     p_sec_dim_col	VARCHAR2,
     p_re_template	GCS_TEMPLATES_PKG.TemplateRecord,
     p_source_system_code	NUMBER,
     p_specific_interco_id	NUMBER) IS

    -- Holds a dynamically created cursor for the secondary dimension
    -- only or a combination of the secondary and org dimensions
    dims_cv		refcursor;
    dims_cv_text	VARCHAR2(32767);

    -- Lists all orgs for GCS
    CURSOR	all_orgs IS
    SELECT	DISTINCT company_cost_center_org_id org_id
    FROM	gcs_translation_gt;

    org_id		NUMBER;
    sec_dim_val_id	NUMBER;

    -- Get the object id for TRANSLATION
    CURSOR get_object_id IS
    SELECT cb.associated_object_id
    FROM   gcs_categories_b cb
    WHERE  cb.category_code = 'TRANSLATION';

    fb_object_id	NUMBER;

    -- Used when secondary tracking is enabled.
    re_acct_exists_cv	refcursor;
    re_acct_text	VARCHAR2(32767);

    -- Whether or not the retained earning account already exists in the
    -- interim table
    re_account_exists	VARCHAR2(1);

    -- Used for getting the aggregate revenues minus expenses for the
    -- previous year (P/L)
    pl_text		VARCHAR2(32767);

    -- Used for inserting and updating the retained earnings account
    ins_re_text		VARCHAR2(32767);
    ins_join		VARCHAR2(8000);
    upd_re_text		VARCHAR2(32767);

    -- The total P/L for the previous year, to be rolled into this year's
    -- retained earnings account
    re_delta_dr		NUMBER;
    re_delta_cr		NUMBER;

    module	VARCHAR2(30);
  BEGIN
    module := 'CALCULATE_RE_AMT';
    module_log_write(module, g_module_enter);

    OPEN get_object_id;
    FETCH get_object_id INTO fb_object_id;
    CLOSE get_object_id;

    re_acct_text :=
'SELECT ''Y''' || g_nl ||
'FROM   GCS_TRANSLATION_GT' || g_nl;

    pl_text :=
'SELECT nvl(sum(nvl(fb.ytd_debit_balance_e, 0)),0), ' ||
'nvl(sum(nvl(fb.ytd_credit_balance_e, 0)),0)' || g_nl ||
'FROM   FEM_BALANCES fb,' || g_nl ||
'       FEM_LN_ITEMS_ATTR li,' || g_nl ||
'       FEM_EXT_ACCT_TYPES_ATTR fxata' || g_nl ||
'WHERE  fb.dataset_code = ' || p_hier_dataset_code || g_nl ||
'AND    fb.created_by_object_id = ' || fb_object_id || g_nl ||
'AND    fb.cal_period_id = ' || p_prev_period_id || g_nl ||
'AND    fb.source_system_code = ' || p_source_system_code || g_nl ||
'AND    fb.currency_code = ''' || p_to_ccy || '''' || g_nl ||
'AND    fb.ledger_id = ' || p_ledger_id || g_nl ||
'AND    fb.entity_id = ' || p_entity_id || g_nl ||
'AND    li.line_item_id = fb.line_item_id' || g_nl ||
'AND    li.attribute_id = ' || g_li_acct_type_attr_id || g_nl ||
'AND    li.version_id = ' || g_li_acct_type_v_id || g_nl ||
'AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member' || g_nl ||
'AND    fxata.attribute_id = ' || g_xat_basic_acct_type_attr_id || g_nl ||
'AND    fxata.version_id = ' || g_xat_basic_acct_type_v_id || g_nl ||
'AND    fxata.dim_attribute_varchar_member IN (''REVENUE'',''EXPENSE'')' || g_nl;

    IF p_org_track_flag = 'Y' THEN
      pl_text := pl_text || 'AND    fb.company_cost_center_org_id = :org_id' || g_nl;
    END IF;
    IF p_sec_dim_col IS NOT NULL THEN
      pl_text := pl_text || 'AND    fb.' || p_sec_dim_col || ' = :sec_dim_val_id' || g_nl;
    END IF;

    ins_re_text :=
'INSERT INTO gcs_translation_gt(translate_rule_code, account_type_code, ' ||
'company_cost_center_org_id, intercompany_id, ' ||
'financial_elem_id, product_id, natural_account_id, channel_id, ' ||
'line_item_id, project_id, customer_id, task_id, user_dim1_id, ' ||
'user_dim2_id, user_dim3_id, user_dim4_id, user_dim5_id, user_dim6_id, ' ||
'user_dim7_id, user_dim8_id, user_dim9_id, user_dim10_id, t_amount_dr, ' ||
't_amount_cr, begin_ytd_dr, begin_ytd_cr, xlate_ptd_dr, xlate_ptd_cr, ' ||
'xlate_ytd_dr, xlate_ytd_cr)' || g_nl ||
'SELECT ''' || p_eq_xlate_mode || ''', ''EQUITY'', ';

    upd_re_text :=
'UPDATE GCS_TRANSLATION_GT' || g_nl ||
'SET    begin_ytd_dr = nvl(begin_ytd_dr, 0) + :re_delta_dr,' || g_nl ||
'       begin_ytd_cr = nvl(begin_ytd_cr, 0) + :re_delta_cr' || g_nl;

    -- Create all the text involving secondary and org tracking, including
    -- select portions of statements and joins.
    create_all_re_tracking_text(
      re_acct_text, ins_re_text, ins_join, upd_re_text, p_org_track_flag,
      p_sec_dim_col, p_hierarchy_id, p_entity_id, p_relationship_id,
      p_specific_interco_id, p_re_template);

    ins_re_text := ins_re_text ||
'decode(''' || p_eq_xlate_mode || ''', ''YTD'', nvl(min(ytd_debit_balance_e),0) + :re_delta_dr, 0), ' ||
'decode(''' || p_eq_xlate_mode || ''', ''YTD'', nvl(min(ytd_credit_balance_e),0) + :re_delta_cr, 0), ' ||
'nvl(min(ytd_debit_balance_e),0) + :re_delta_dr, ' ||
'nvl(min(ytd_credit_balance_e),0) + :re_delta_cr, 0, 0, 0, 0' || g_nl ||
'FROM   FEM_BALANCES fb' || g_nl ||
'WHERE  fb.dataset_code = ' || p_hier_dataset_code || g_nl ||
'AND    fb.created_by_object_id = ' || fb_object_id || g_nl ||
'AND    fb.cal_period_id = ' || p_prev_period_id || g_nl ||
'AND    fb.source_system_code = ' || p_source_system_code || g_nl ||
'AND    fb.currency_code = ''' || p_to_ccy || '''' || g_nl ||
'AND    fb.ledger_id = ' || p_ledger_id || g_nl ||
'AND    fb.entity_id = ' || p_entity_id || g_nl ||
ins_join;

    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      write_to_log(module, FND_LOG.LEVEL_STATEMENT, re_acct_text);
      write_to_log(module, FND_LOG.LEVEL_STATEMENT, pl_text);
      write_to_log(module, FND_LOG.LEVEL_STATEMENT, ins_re_text);
      write_to_log(module, FND_LOG.LEVEL_STATEMENT, upd_re_text);
    END IF;


    IF p_sec_dim_col IS NOT NULL AND p_org_track_flag = 'Y' THEN
      dims_cv_text :=
	'SELECT DISTINCT ' || p_sec_dim_col ||
        ', COMPANY_COST_CENTER_ORG_ID FROM gcs_translation_gt';

      write_to_log(module, FND_LOG.LEVEL_STATEMENT, dims_cv_text);

      OPEN dims_cv FOR dims_cv_text;
      FETCH dims_cv INTO sec_dim_val_id, org_id;
      WHILE dims_cv%FOUND LOOP
        -- Check if the given account is already in the interim table.
        IF p_specific_interco_id IS NOT NULL THEN
          OPEN re_acct_exists_cv FOR re_acct_text
            USING org_id, sec_dim_val_id;
        ELSE
          OPEN re_acct_exists_cv FOR re_acct_text
            USING org_id, org_id, sec_dim_val_id;
        END IF;
        FETCH re_acct_exists_cv INTO re_account_exists;
        IF re_acct_exists_cv%NOTFOUND THEN
          re_account_exists := 'N';
        END IF;
        CLOSE re_acct_exists_cv;

        EXECUTE IMMEDIATE pl_text
        INTO re_delta_dr, re_delta_cr
        USING org_id, sec_dim_val_id;

        -- Insert or update the retained earnings account in the temporary
        -- table.
        IF re_account_exists = 'N' THEN
          IF p_specific_interco_id IS NOT NULL THEN
            EXECUTE IMMEDIATE ins_re_text
              USING org_id, sec_dim_val_id, re_delta_dr, re_delta_cr, re_delta_dr, re_delta_cr,
                    org_id, sec_dim_val_id;
          ELSE
            EXECUTE IMMEDIATE ins_re_text
              USING org_id, org_id, sec_dim_val_id, re_delta_dr, re_delta_cr, re_delta_dr, re_delta_cr,
                    org_id, org_id, sec_dim_val_id;
          END IF;

          -- Retained Earnings account was not created successfully.
          IF SQL%ROWCOUNT = 0 THEN
            CLOSE dims_cv;
            raise GCS_CCY_NO_RE_ACCT_CREATED;
          END IF;
        ELSE
          IF p_specific_interco_id IS NOT NULL THEN
            EXECUTE IMMEDIATE upd_re_text
              USING re_delta_dr, re_delta_cr, org_id, sec_dim_val_id;
          ELSE
            EXECUTE IMMEDIATE upd_re_text
              USING re_delta_dr, re_delta_cr, org_id, org_id, sec_dim_val_id;
          END IF;

          -- Retained earnings account was not updated successfully.
          IF SQL%ROWCOUNT = 0 THEN
            CLOSE dims_cv;
            raise GCS_CCY_NO_RE_ACCT_UPDATED;
          END IF;
        END IF;

        FETCH dims_cv INTO sec_dim_val_id, org_id;
      END LOOP;
      CLOSE dims_cv;
    ELSIF p_sec_dim_col IS NOT NULL THEN
      dims_cv_text := 'SELECT DISTINCT ' || p_sec_dim_col ||
                      ' FROM gcs_translation_gt';

      write_to_log(module, FND_LOG.LEVEL_STATEMENT, dims_cv_text);

      OPEN dims_cv FOR dims_cv_text;
      FETCH dims_cv INTO sec_dim_val_id;
      WHILE dims_cv%FOUND LOOP
        -- Check if the given account is already in the interim table.
        OPEN re_acct_exists_cv FOR re_acct_text USING sec_dim_val_id;
        FETCH re_acct_exists_cv INTO re_account_exists;
        IF re_acct_exists_cv%NOTFOUND THEN
          re_account_exists := 'N';
        END IF;
        CLOSE re_acct_exists_cv;

        EXECUTE IMMEDIATE pl_text
        INTO re_delta_dr, re_delta_cr
        USING sec_dim_val_id;

        -- Insert or update the retained earnings account in the temporary
        -- table.
        IF re_account_exists = 'N' THEN
          EXECUTE IMMEDIATE ins_re_text
            USING sec_dim_val_id, re_delta_dr, re_delta_cr, re_delta_dr, re_delta_cr, sec_dim_val_id;
          -- Retained Earnings account was not created successfully.
          IF SQL%ROWCOUNT = 0 THEN
            CLOSE dims_cv;
            raise GCS_CCY_NO_RE_ACCT_CREATED;
          END IF;
        ELSE
          EXECUTE IMMEDIATE upd_re_text
            USING re_delta_dr, re_delta_cr, sec_dim_val_id;
          -- Retained earnings account was not updated successfully.
          IF SQL%ROWCOUNT = 0 THEN
            CLOSE dims_cv;
            raise GCS_CCY_NO_RE_ACCT_UPDATED;
          END IF;
        END IF;

        FETCH dims_cv INTO sec_dim_val_id;
      END LOOP;
      CLOSE dims_cv;
    ELSIF p_org_track_flag = 'Y' THEN
      write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT DISTINCT company_cost_center_org_id org_id FROM gcs_translation_gt');

      FOR org IN all_orgs LOOP
        org_id := org.org_id;

        -- Check if the given account is already in the interim table.
        IF p_specific_interco_id IS NOT NULL THEN
          OPEN re_acct_exists_cv FOR re_acct_text USING org_id;
        ELSE
          OPEN re_acct_exists_cv FOR re_acct_text USING org_id, org_id;
        END IF;
        FETCH re_acct_exists_cv INTO re_account_exists;
        IF re_acct_exists_cv%NOTFOUND THEN
          re_account_exists := 'N';
        END IF;
        CLOSE re_acct_exists_cv;

        EXECUTE IMMEDIATE pl_text
        INTO re_delta_dr, re_delta_cr
        USING org_id;

        -- Insert or update the retained earnings account in the temporary
        -- table.
        IF re_account_exists = 'N' THEN
          IF p_specific_interco_id IS NOT NULL THEN
            EXECUTE IMMEDIATE ins_re_text
              USING org_id, re_delta_dr, re_delta_cr, re_delta_dr, re_delta_cr, org_id;
          ELSE
            EXECUTE IMMEDIATE ins_re_text
              USING org_id, org_id, re_delta_dr, re_delta_cr, re_delta_dr, re_delta_cr, org_id, org_id;
          END IF;

          -- Retained Earnings account was not created successfully.
          IF SQL%ROWCOUNT = 0 THEN
            raise GCS_CCY_NO_RE_ACCT_CREATED;
          END IF;
        ELSE
          IF p_specific_interco_id IS NOT NULL THEN
            EXECUTE IMMEDIATE upd_re_text
              USING re_delta_dr, re_delta_cr, org_id;
          ELSE
            EXECUTE IMMEDIATE upd_re_text
              USING re_delta_dr, re_delta_cr, org_id, org_id;
          END IF;
          -- Retained earnings account was not updated successfully.
          IF SQL%ROWCOUNT = 0 THEN
            raise GCS_CCY_NO_RE_ACCT_UPDATED;
          END IF;
        END IF;

      END LOOP;
    ELSE
      -- Check if the given account is already in the interim table.
      OPEN re_acct_exists_cv FOR re_acct_text;
      FETCH re_acct_exists_cv INTO re_account_exists;
      IF re_acct_exists_cv%NOTFOUND THEN
        re_account_exists := 'N';
      END IF;
      CLOSE re_acct_exists_cv;

      EXECUTE IMMEDIATE pl_text
      INTO re_delta_dr, re_delta_cr;

      -- Insert or update the retained earnings account in the temporary
      -- table.
      IF re_account_exists = 'N' THEN
        EXECUTE IMMEDIATE ins_re_text USING re_delta_dr, re_delta_cr, re_delta_dr, re_delta_cr;
        -- Retained Earnings account was not created successfully.
        IF SQL%ROWCOUNT = 0 THEN
          raise GCS_CCY_NO_RE_ACCT_CREATED;
        END IF;
      ELSE
        EXECUTE IMMEDIATE upd_re_text USING re_delta_dr, re_delta_cr;
        -- Retained earnings account was not updated successfully.
        IF SQL%ROWCOUNT = 0 THEN
          raise GCS_CCY_NO_RE_ACCT_UPDATED;
        END IF;
      END IF;
    END IF;

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'UPDATE GCS_TRANSLATION_GT tg' || g_nl ||
'SET    begin_ytd_dr = 0,' || g_nl ||
'       begin_ytd_cr = 0' || g_nl ||
'WHERE  EXISTS' || g_nl ||
'(SELECT 1' || g_nl ||
' FROM   FEM_LN_ITEMS_ATTR li,' || g_nl ||
'        FEM_EXT_ACCT_TYPES_ATTR fxata' || g_nl ||
' WHERE  li.line_item_id = tg.line_item_id' || g_nl ||
' AND    li.attribute_id = ' || g_li_acct_type_attr_id || g_nl ||
' AND    li.version_id = ' || g_li_acct_type_v_id || g_nl ||
' AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member' || g_nl ||
' AND    fxata.attribute_id = ' || g_xat_basic_acct_type_attr_id || g_nl ||
' AND    fxata.version_id = ' || g_xat_basic_acct_type_v_id || g_nl ||
' AND    fxata.dim_attribute_varchar_member IN (''REVENUE'',''EXPENSE''))');

    -- Zero out the Income Statement begin balances, since we moved
    -- those balances over to the retained earnings account.
    UPDATE	GCS_TRANSLATION_GT tg
    SET		begin_ytd_dr = 0,
		begin_ytd_cr = 0
    WHERE	EXISTS
    (SELECT	1
     FROM	FEM_LN_ITEMS_ATTR li,
		FEM_EXT_ACCT_TYPES_ATTR fxata
     WHERE	li.line_item_id = tg.line_item_id
     AND	li.attribute_id = g_li_acct_type_attr_id
     AND	li.version_id = g_li_acct_type_v_id
     AND	fxata.ext_account_type_code = li.dim_attribute_varchar_member
     AND	fxata.attribute_id = g_xat_basic_acct_type_attr_id
     AND	fxata.version_id = g_xat_basic_acct_type_v_id
     AND	fxata.dim_attribute_varchar_member IN ('REVENUE','EXPENSE'));

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_RE_ACCT_CREATED THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_RE_CREATED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_RE_ACCT_UPDATED THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_RE_UPDATED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_RE_UNEXPECTED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Calculate_RE_Amt;

  --
  -- Procedure
  --   Calculate_RE_Rate
  -- Purpose
  --   Calculate historical rates for the retained earnings account.
  -- Arguments
  --   p_relationship_id The relationship for which translation is being run.
  --   p_cal_period_id	The period being translated.
  --   p_next_period_id	The next period, which is the first period of the year.
  --   p_entity_id	Entity on which the translation is being performed.
  --   p_hierarchy_id	Hierarchy in which the entity resides.
  --   p_ledger_id	Ledger of the entity to be translated.
  --   p_from_ccy	From currency code.
  --   p_to_ccy		To currency code.
  --   p_dataset_code	Actual or budget translation.
  --   p_org_track_flag	Whether org tracking is enabled.
  --   p_sec_dim_col	Secondary tracking dimension column.
  --   p_re_template	Retained earnings template.
  --   p_source_system_code	Source System Code for GCS.
  --   p_specific_interco_id	Specific intercomany id if applicable.
  --   p_entry_id	The translation entry created.
  -- Example
  --   GCS_TRANSLATION_PKG.Calculate_RE_Rate;
  -- Notes
  --
  PROCEDURE Calculate_RE_Rate
    (p_relationship_id	NUMBER,
     p_cal_period_id	NUMBER,
     p_next_period_id	NUMBER,
     p_entity_id	NUMBER,
     p_hierarchy_id	NUMBER,
     p_ledger_id	NUMBER,
     p_from_ccy		VARCHAR2,
     p_to_ccy		VARCHAR2,
     p_hier_dataset_code	NUMBER,
     p_org_track_flag	VARCHAR2,
     p_sec_dim_col	VARCHAR2,
     p_re_template	GCS_TEMPLATES_PKG.TemplateRecord,
     p_source_system_code	NUMBER,
     p_specific_interco_id	NUMBER,
     p_entry_id		NUMBER) IS

    -- Holds a dynamically created cursor for the secondary dimension
    -- only or a combination of the secondary and org dimensions
    dims_cv		refcursor;
    dims_cv_text	VARCHAR2(32767);

    -- Lists all orgs for GCS
    CURSOR	all_orgs IS
    SELECT	DISTINCT company_cost_center_org_id org_id
    FROM	gcs_entry_lines
    WHERE	entry_id = p_entry_id;

    org_id		NUMBER;
    sec_dim_val_id	NUMBER;

    -- Used for getting the calculated_historical rate
    amounts_text	VARCHAR2(32767);
    amounts_join	VARCHAR2(8000);

    new_rate		NUMBER;

    -- Used to check whether a historical rate is defined, and returns the
    -- rate type if such a rate is defined.
    re_rate_exists_cv	refcursor;
    re_rate_text	VARCHAR2(32767);

    -- SQL to insert or update the new retained earnings historical rate.
    re_ins_rate		VARCHAR2(32767);
    re_upd_rate		VARCHAR2(32767);

    -- The historical rate type for the retained earnings account
    re_rate_type	VARCHAR2(30);

    module	VARCHAR2(30);
  BEGIN
    module := 'CALCULATE_RE_RATE';
    module_log_write(module, g_module_enter);

    amounts_text :=
'SELECT decode(func.ytd_debit - func.ytd_credit,' || g_nl ||
'              0, decode(func.ytd_debit,' || g_nl ||
'                        0, 0,' || g_nl ||
'                        xlat.ytd_debit/func.ytd_debit),' || g_nl ||
'              (xlat.ytd_debit - xlat.ytd_credit)/(func.ytd_debit - func.ytd_credit))' || g_nl ||
'FROM' || g_nl ||
'  (SELECT nvl(sum(nvl(fb.ytd_debit_balance_e, 0)),0) ytd_debit, ' ||
'nvl(sum(nvl(fb.ytd_credit_balance_e, 0)),0) ytd_credit' || g_nl ||
'   FROM   FEM_BALANCES fb,' || g_nl ||
'          FEM_LN_ITEMS_ATTR li,' || g_nl ||
'          FEM_EXT_ACCT_TYPES_ATTR fxata' || g_nl ||
'   WHERE  fb.dataset_code = ' || p_hier_dataset_code || g_nl ||
'   AND    fb.cal_period_id = ' || p_cal_period_id || g_nl ||
'   AND    fb.source_system_code = ' || p_source_system_code || g_nl ||
'   AND    fb.currency_code = ''' || p_from_ccy || '''' || g_nl ||
'   AND    fb.ledger_id = ' || p_ledger_id || g_nl ||
'   AND    fb.entity_id = ' || p_entity_id || g_nl ||
'   AND    li.line_item_id = fb.line_item_id' || g_nl ||
'   AND    li.attribute_id = ' || g_li_acct_type_attr_id || g_nl ||
'   AND    li.version_id = ' || g_li_acct_type_v_id || g_nl ||
'   AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member' || g_nl ||
'   AND    fxata.attribute_id = ' || g_xat_basic_acct_type_attr_id || g_nl ||
'   AND    fxata.version_id = ' || g_xat_basic_acct_type_v_id || g_nl ||
'   AND    ((fxata.dim_attribute_varchar_member IN (''REVENUE'',''EXPENSE'')' || g_nl;

    IF p_org_track_flag = 'Y' THEN
      amounts_text := amounts_text || '            AND    fb.company_cost_center_org_id = :org_id' || g_nl;
    END IF;
    IF p_sec_dim_col IS NOT NULL THEN
      amounts_text := amounts_text || '            AND    fb.' || p_sec_dim_col || ' = :sec_dim_val_id' || g_nl;
    END IF;

    amounts_text := amounts_text ||
'           ) OR ' || g_nl ||
'           (' || g_nl;

    re_rate_text :=
'SELECT rate_type_code' || g_nl ||
'FROM   GCS_HISTORICAL_RATES' || g_nl ||
'WHERE  entity_id = ' || p_entity_id || g_nl ||
'AND    hierarchy_id = ' || p_hierarchy_id || g_nl ||
'AND    cal_period_id = ' || p_next_period_id || g_nl ||
'AND    from_currency = ''' ||p_from_ccy || '''' || g_nl ||
'AND    to_currency = ''' || p_to_ccy || '''' || g_nl;

    re_ins_rate :=
'INSERT INTO gcs_historical_rates(standard_re_rate_flag, entity_id, hierarchy_id, ' ||
'cal_period_id, from_currency, to_currency, company_cost_center_org_id, ' ||
'intercompany_id, financial_elem_id, ' ||
'product_id, natural_account_id, channel_id, line_item_id, project_id, ' ||
'customer_id, task_id, user_dim1_id, user_dim2_id, user_dim3_id, ' ||
'user_dim4_id, user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id, ' ||
'user_dim9_id, user_dim10_id, translated_rate, translated_amount, ' ||
'rate_type_code, update_flag, account_type_code, stop_rollforward_flag, ' ||
'last_update_date, last_updated_by, last_update_login, creation_date, ' ||
'created_by)' || g_nl ||
'VALUES(''Y'', ' || p_entity_id || ', ' || p_hierarchy_id ||
', ' || p_next_period_id || ', ''' || p_from_ccy || ''', ''' || p_to_ccy ||
''', ';

    re_upd_rate :=
'UPDATE GCS_HISTORICAL_RATES' || g_nl ||
'SET translated_rate = :re_rate,' || g_nl ||
'    translated_amount = null,' || g_nl ||
'    rate_type_code = ''C'',' || g_nl ||
'    last_update_date = sysdate,' || g_nl ||
'    last_updated_by = ' || g_fnd_user_id || ',' || g_nl ||
'    last_update_login = ' || g_fnd_login_id || g_nl ||
'WHERE  entity_id = ' || p_entity_id || g_nl ||
'AND    hierarchy_id = ' || p_hierarchy_id || g_nl ||
'AND    from_currency = ''' || p_from_ccy || '''' || g_nl ||
'AND    to_currency = ''' || p_to_ccy || '''' || g_nl ||
'AND    cal_period_id = ' || p_next_period_id || g_nl;

    -- Create all the text involving secondary and org tracking, including
    -- select portions of statements and joins.
    create_all_re_rate_track_text(
      amounts_text, amounts_join, re_rate_text, re_ins_rate, re_upd_rate,
      p_org_track_flag, p_sec_dim_col, p_hierarchy_id, p_entity_id,
      p_relationship_id, p_specific_interco_id, p_re_template);


    amounts_text := amounts_text ||
'           ))' || g_nl ||
'  ) func,' || g_nl ||
'  (SELECT nvl(sum(nvl(el.ytd_debit_balance_e, 0)), 0) ytd_debit, ' ||
'nvl(sum(nvl(el.ytd_credit_balance_e, 0)), 0) ytd_credit' || g_nl ||
'   FROM   GCS_ENTRY_LINES el,' || g_nl ||
'          FEM_LN_ITEMS_ATTR lia,' || g_nl ||
'          FEM_EXT_ACCT_TYPES_ATTR xata' || g_nl ||
'   WHERE  el.entry_id = ' || p_entry_id || g_nl ||
'   AND    lia.line_item_id = el.line_item_id' || g_nl ||
'   AND    lia.attribute_id = ' || g_li_acct_type_attr_id || g_nl ||
'   AND    lia.version_id = ' || g_li_acct_type_v_id || g_nl ||
'   AND    xata.ext_account_type_code = lia.dim_attribute_varchar_member' || g_nl ||
'   AND    xata.attribute_id = ' || g_xat_basic_acct_type_attr_id || g_nl ||
'   AND    xata.version_id = ' || g_xat_basic_acct_type_v_id || g_nl ||
'   AND    ((xata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')' || g_nl;

    IF p_org_track_flag = 'Y' THEN
      amounts_text := amounts_text || '           AND    el.company_cost_center_org_id = :org_id' || g_nl;
    END IF;
    IF p_sec_dim_col IS NOT NULL THEN
      amounts_text := amounts_text || '           AND    el.' || p_sec_dim_col || ' = :sec_dim_val_id' || g_nl;
    END IF;

    amounts_text := amounts_text ||
'          ) OR' || g_nl ||
'          (' || g_nl ||
amounts_join ||
'          ))' || g_nl ||
'  ) xlat';


    re_ins_rate := re_ins_rate ||
':re_rate, null, ''C'', ''N'', ''EQUITY'', ''N'', sysdate, ' || g_fnd_user_id ||
', ' || g_fnd_login_id || ', sysdate, ' || g_fnd_user_id || ')';

    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      write_to_log(module, FND_LOG.LEVEL_STATEMENT, amounts_text);
      write_to_log(module, FND_LOG.LEVEL_STATEMENT, re_rate_text);
      write_to_log(module, FND_LOG.LEVEL_STATEMENT, re_ins_rate);
      write_to_log(module, FND_LOG.LEVEL_STATEMENT, re_upd_rate);
    END IF;


    IF p_sec_dim_col IS NOT NULL AND p_org_track_flag = 'Y' THEN
      dims_cv_text :=
	'SELECT DISTINCT ' || p_sec_dim_col ||
        ', COMPANY_COST_CENTER_ORG_ID FROM gcs_entry_lines where entry_id = ' || p_entry_id;

      write_to_log(module, FND_LOG.LEVEL_STATEMENT, dims_cv_text);

      OPEN dims_cv FOR dims_cv_text;
      FETCH dims_cv INTO sec_dim_val_id, org_id;
      WHILE dims_cv%FOUND LOOP

        IF p_specific_interco_id IS NOT NULL THEN
          EXECUTE IMMEDIATE amounts_text
          INTO new_rate
          USING org_id, sec_dim_val_id, org_id, sec_dim_val_id,
                org_id, sec_dim_val_id, org_id, sec_dim_val_id;

          OPEN re_rate_exists_cv FOR re_rate_text
            USING org_id, sec_dim_val_id;
        ELSE
          EXECUTE IMMEDIATE amounts_text
          INTO new_rate
          USING org_id, sec_dim_val_id, org_id, org_id, sec_dim_val_id,
                org_id, sec_dim_val_id, org_id, org_id, sec_dim_val_id;

          OPEN re_rate_exists_cv FOR re_rate_text
            USING org_id, org_id, sec_dim_val_id;
        END IF;
        FETCH re_rate_exists_cv INTO re_rate_type;
        IF re_rate_exists_cv%NOTFOUND THEN
          CLOSE re_rate_exists_cv;
          IF p_specific_interco_id IS NOT NULL THEN
            EXECUTE IMMEDIATE re_ins_rate
              USING org_id, sec_dim_val_id, new_rate;
          ELSE
            EXECUTE IMMEDIATE re_ins_rate
              USING org_id, org_id, sec_dim_val_id, new_rate;
          END IF;

          -- Retained earnings historical rate not created successfully.
          IF SQL%ROWCOUNT = 0 THEN
            raise GCS_CCY_NO_RATE_CREATED;
          END IF;
        ELSE
          CLOSE re_rate_exists_cv;
          IF nvl(re_rate_type, 'X') <> 'H' THEN
            IF p_specific_interco_id IS NOT NULL THEN
              EXECUTE IMMEDIATE re_upd_rate
                USING new_rate, org_id, sec_dim_val_id;
            ELSE
              EXECUTE IMMEDIATE re_upd_rate
                USING new_rate, org_id, org_id, sec_dim_val_id;
            END IF;

            -- Retained earnings historical rate not updated successfully.
            IF SQL%ROWCOUNT = 0 THEN
              raise GCS_CCY_NO_RATE_UPDATED;
            END IF;
          END IF;
        END IF;

        FETCH dims_cv INTO sec_dim_val_id, org_id;
      END LOOP;
      CLOSE dims_cv;
    ELSIF p_sec_dim_col IS NOT NULL THEN
      dims_cv_text := 'SELECT DISTINCT ' || p_sec_dim_col ||
                      ' FROM gcs_entry_lines WHERE entry_id = ' || p_entry_id;

      write_to_log(module, FND_LOG.LEVEL_STATEMENT, dims_cv_text);

      OPEN dims_cv FOR dims_cv_text;
      FETCH dims_cv INTO sec_dim_val_id;
      WHILE dims_cv%FOUND LOOP

        EXECUTE IMMEDIATE amounts_text
        INTO new_rate
        USING sec_dim_val_id, sec_dim_val_id,
              sec_dim_val_id, sec_dim_val_id;

        OPEN re_rate_exists_cv FOR re_rate_text USING sec_dim_val_id;
        FETCH re_rate_exists_cv INTO re_rate_type;
        IF re_rate_exists_cv%NOTFOUND THEN
          CLOSE re_rate_exists_cv;
          EXECUTE IMMEDIATE re_ins_rate USING sec_dim_val_id, new_rate;

          -- Retained earnings historical rate not created successfully.
          IF SQL%ROWCOUNT = 0 THEN
            raise GCS_CCY_NO_RATE_CREATED;
          END IF;
        ELSE
          CLOSE re_rate_exists_cv;
          IF nvl(re_rate_type, 'X') <> 'H' THEN
            EXECUTE IMMEDIATE re_upd_rate
              USING new_rate, sec_dim_val_id;

            -- Retained earnings historical rate not updated successfully.
            IF SQL%ROWCOUNT = 0 THEN
              raise GCS_CCY_NO_RATE_UPDATED;
            END IF;
          END IF;
        END IF;

        FETCH dims_cv INTO sec_dim_val_id;
      END LOOP;
      CLOSE dims_cv;
    ELSIF p_org_track_flag = 'Y' THEN
      write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'SELECT DISTINCT company_cost_center_org_id org_id FROM gcs_entry_lines WHERE entry_id = ' || p_entry_id);

      FOR org IN all_orgs LOOP
        org_id := org.org_id;

        IF p_specific_interco_id IS NOT NULL THEN
          EXECUTE IMMEDIATE amounts_text
          INTO new_rate
          USING org_id, org_id, org_id, org_id;

          OPEN re_rate_exists_cv FOR re_rate_text USING org_id;
        ELSE
          EXECUTE IMMEDIATE amounts_text
          INTO new_rate
          USING org_id, org_id, org_id, org_id, org_id, org_id;

          OPEN re_rate_exists_cv FOR re_rate_text USING org_id, org_id;
        END IF;
        FETCH re_rate_exists_cv INTO re_rate_type;
        IF re_rate_exists_cv%NOTFOUND THEN
          CLOSE re_rate_exists_cv;
          IF p_specific_interco_id IS NOT NULL THEN
            EXECUTE IMMEDIATE re_ins_rate
              USING org_id, new_rate;
          ELSE
            EXECUTE IMMEDIATE re_ins_rate
              USING org_id, org_id, new_rate;
          END IF;

          -- Retained earnings historical rate not created successfully.
          IF SQL%ROWCOUNT = 0 THEN
            raise GCS_CCY_NO_RATE_CREATED;
          END IF;
        ELSE
          CLOSE re_rate_exists_cv;
          IF nvl(re_rate_type, 'X') <> 'H' THEN
            IF p_specific_interco_id IS NOT NULL THEN
              EXECUTE IMMEDIATE re_upd_rate
                USING new_rate, org_id;
            ELSE
              EXECUTE IMMEDIATE re_upd_rate
                USING new_rate, org_id, org_id;
            END IF;

            -- Retained earnings historical rate not updated successfully.
            IF SQL%ROWCOUNT = 0 THEN
              raise GCS_CCY_NO_RATE_UPDATED;
            END IF;
          END IF;
        END IF;

      END LOOP;
    ELSE

      EXECUTE IMMEDIATE amounts_text
      INTO new_rate;

      OPEN re_rate_exists_cv FOR re_rate_text;
      FETCH re_rate_exists_cv INTO re_rate_type;
      IF re_rate_exists_cv%NOTFOUND THEN
        CLOSE re_rate_exists_cv;
        EXECUTE IMMEDIATE re_ins_rate USING new_rate;

        -- Retained earnings historical rate not created successfully.
        IF SQL%ROWCOUNT = 0 THEN
          raise GCS_CCY_NO_RATE_CREATED;
        END IF;
      ELSE
        CLOSE re_rate_exists_cv;
        IF nvl(re_rate_type, 'X') <> 'H' THEN
          EXECUTE IMMEDIATE re_upd_rate USING new_rate;

          -- Retained earnings historical rate not updated successfully.
          IF SQL%ROWCOUNT = 0 THEN
            raise GCS_CCY_NO_RATE_UPDATED;
          END IF;
        END IF;
      END IF;
    END IF;

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_RATE_CREATED THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_RE_RT_CREATED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN GCS_CCY_NO_RATE_UPDATED THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_RE_RT_UPDATED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_RE_UNEXPECTED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Calculate_RE_Rate;

  --
  -- Procedure
  --   Calculate_Xlated_PTD_YTD
  -- Purpose
  --   Calculate the PTD or YTD balances for YTD or PTD translations,
  --   respectively.
  -- Example
  --   GCS_TRANSLATION_PKG.Calculate_Xlated_PTD_YTD;
  -- Notes
  --
  PROCEDURE Calculate_Xlated_PTD_YTD IS
    module	VARCHAR2(30);
  BEGIN
    module := 'CALCULATE_XLATED_PTD_YTD';
    module_log_write(module, g_module_enter);

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'UPDATE gcs_translation_gt' || g_nl ||
'SET    xlate_ptd_dr = t_amount_dr,' || g_nl ||
'       xlate_ptd_cr = t_amount_cr,' || g_nl ||
'       xlate_ytd_dr = t_amount_dr + begin_ytd_dr,' || g_nl ||
'       xlate_ytd_cr = t_amount_cr + begin_ytd_cr' || g_nl ||
'WHERE  translate_rule_code = ''PTD''');

    -- Calculate YTD balances for PTD translation
    UPDATE	gcs_translation_gt
    SET		xlate_ptd_dr = t_amount_dr,
		xlate_ptd_cr = t_amount_cr,
		xlate_ytd_dr = t_amount_dr + begin_ytd_dr,
		xlate_ytd_cr = t_amount_cr + begin_ytd_cr
    WHERE	translate_rule_code = 'PTD';

    write_to_log(module, FND_LOG.LEVEL_STATEMENT,
'UPDATE gcs_translation_gt' || g_nl ||
'SET    xlate_ptd_dr = t_amount_dr - begin_ytd_dr,' || g_nl ||
'       xlate_ptd_cr = t_amount_cr - begin_ytd_cr,' || g_nl ||
'       xlate_ytd_dr = t_amount_dr,' || g_nl ||
'       xlate_ytd_cr = t_amount_cr' || g_nl ||
'WHERE	translate_rule_code = ''YTD''');

    -- Calculate PTD balances for YTD translation
    UPDATE	gcs_translation_gt
    SET		xlate_ptd_dr = t_amount_dr - begin_ytd_dr,
		xlate_ptd_cr = t_amount_cr - begin_ytd_cr,
		xlate_ytd_dr = t_amount_dr,
		xlate_ytd_cr = t_amount_cr
    WHERE	translate_rule_code = 'YTD';

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_PTDYTD_UNEXPECTED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Calculate_Xlated_PTD_YTD;



  PROCEDURE Update_Status_Tracking(
	p_hierarchy_id		IN NUMBER,
	p_entity_id		IN NUMBER,
	p_currency_code		IN VARCHAR2,
	p_cal_period_id		IN NUMBER,
	p_hier_dataset_code	IN NUMBER,
	p_cal_period_number	IN NUMBER,
	p_cal_period_year	IN NUMBER,
	p_next_cal_period_id	IN NUMBER) IS
    module	VARCHAR2(30);

    -- Check the status of a translation
    CURSOR	status_check_c(c_cal_period_id NUMBER) IS
    SELECT	status_code
    FROM	gcs_translation_statuses
    WHERE	hierarchy_id = p_hierarchy_id
    AND		entity_id = p_entity_id
    AND		currency_code = p_currency_code
    AND		cal_period_id = c_cal_period_id
    AND		dataset_code = p_hier_dataset_code;

    status	VARCHAR2(30);

    -- Check the translation tracking information for an entity
    CURSOR	tracking_check_c IS
    SELECT	earliest_ever_period_id,
		earliest_never_period_id
    FROM	gcs_translation_track_h
    WHERE	hierarchy_id = p_hierarchy_id
    AND		entity_id = p_entity_id
    AND		currency_code = p_currency_code
    AND		dataset_code = p_hier_dataset_code;

    earliest_period_id		NUMBER;
    never_period_id		NUMBER;
    earliest_period_info	GCS_UTILITY_PKG.r_cal_period_info;
    never_period_info		GCS_UTILITY_PKG.r_cal_period_info;

    next_period_id	NUMBER;
    next_period_info	GCS_UTILITY_PKG.r_cal_period_info;

  BEGIN
    module := 'UPDATE_STATUS_TRACKING';
    module_log_write(module, g_module_enter);

    -- If a status row does not exist, create one. If it does exist, make sure
    -- it is set to the 'Current' status
    OPEN status_check_c(p_cal_period_id);
    FETCH status_check_c INTO status;
    IF status_check_c%NOTFOUND THEN
      CLOSE status_check_c;
      INSERT INTO gcs_translation_statuses(
	hierarchy_id, entity_id, currency_code, cal_period_id, dataset_code,
	status_code, request_id, creation_date, created_by, last_update_date,
	last_updated_by, last_update_login)
      VALUES(
	p_hierarchy_id, p_entity_id, p_currency_code, p_cal_period_id,
	p_hier_dataset_code, 'C', '', sysdate, g_fnd_user_id, sysdate,
	g_fnd_user_id, g_fnd_login_id);
    ELSE
      CLOSE status_check_c;
      IF status <> 'C' THEN
        UPDATE	gcs_translation_statuses
        SET	status_code = 'C'
        WHERE	hierarchy_id = p_hierarchy_id
        AND	entity_id = p_entity_id
        AND	currency_code = p_currency_code
        AND	cal_period_id = p_cal_period_id
        AND	dataset_code = p_hier_dataset_code;
      END IF;
    END IF;

    -- If a tracking row does not exist, create one. If it does exist, make
    -- sure the latest translated period is included in the range
    OPEN tracking_check_c;
    FETCH tracking_check_c INTO earliest_period_id, never_period_id;
    IF tracking_check_c%NOTFOUND THEN
      CLOSE tracking_check_c;
      INSERT INTO gcs_translation_track_h(
	hierarchy_id, entity_id, currency_code, dataset_code,
	earliest_ever_period_id, earliest_never_period_id, created_by,
	creation_date, last_updated_by, last_update_date, last_update_login)
      VALUES(
	p_hierarchy_id, p_entity_id, p_currency_code, p_hier_dataset_code,
	p_cal_period_id, p_cal_period_id, g_fnd_user_id, sysdate,
	g_fnd_user_id, sysdate, g_fnd_login_id);
    ELSE
      CLOSE tracking_check_c;
      GCS_UTILITY_PKG.get_cal_period_details
	(earliest_period_id, earliest_period_info);
      GCS_UTILITY_PKG.get_cal_period_details
	(never_period_id, never_period_info);

      -- If this is prior to the first ever translated period, update the
      -- tracking table accordingly. Otherwise, move the earliest_never_period
      -- forward to the appropriate spot.
      IF p_cal_period_year < earliest_period_info.cal_period_year OR
         (p_cal_period_year = earliest_period_info.cal_period_year AND
          p_cal_period_number < earliest_period_info.cal_period_number) THEN
        UPDATE	gcs_translation_track_h
        SET	earliest_ever_period_id = p_cal_period_id
        WHERE	hierarchy_id = p_hierarchy_id
        AND	entity_id = p_entity_id
        AND	currency_code = p_currency_code
        AND	dataset_code = p_hier_dataset_code;

        -- Now, if the period after the period just translated is not the
        -- previous first-ever translated period,then update the earliest-
        -- never period accordingly
        IF p_next_cal_period_id <> earliest_period_info.cal_period_id THEN
          UPDATE	gcs_translation_track_h
          SET		earliest_never_period_id = p_next_cal_period_id
          WHERE		hierarchy_id = p_hierarchy_id
          AND		entity_id = p_entity_id
          AND		currency_code = p_currency_code
          AND		dataset_code = p_hier_dataset_code;
        END IF;
      ELSIF p_cal_period_id = never_period_info.cal_period_id THEN
        next_period_id := p_next_cal_period_id;
        OPEN status_check_c(next_period_id);
        FETCH status_check_c INTO status;
        WHILE status_check_c%FOUND LOOP
          CLOSE status_check_c;
          GCS_UTILITY_PKG.get_cal_period_details
            (next_period_id, next_period_info);
          next_period_id := next_period_info.next_cal_period_id;
          OPEN status_check_c(next_period_id);
          FETCH status_check_c INTO status;
        END LOOP;
        CLOSE status_check_c;

        IF next_period_id <> -1 THEN
          -- Now we have found the next period that has not been translated
          UPDATE gcs_translation_track_h
          SET earliest_never_period_id = next_period_id
          WHERE hierarchy_id = p_hierarchy_id
          AND   entity_id = p_entity_id
          AND   currency_code = p_currency_code
          AND   dataset_code = p_hier_dataset_code;
        END IF;
      END IF;
    END IF;

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_TRACK_UNEXPECTED_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(module, g_module_failure);
      raise GCS_CCY_SUBPROGRAM_RAISED;
  END Update_Status_Tracking;


--
-- PUBLIC PROCEDURES
--

  PROCEDURE Translate(
        x_errbuf     OUT NOCOPY	VARCHAR2,
        x_retcode    OUT NOCOPY	VARCHAR2,
        p_cal_period_id		NUMBER,
        p_cons_relationship_id	NUMBER,
        p_balance_type_code	VARCHAR2,
        p_hier_dataset_code	NUMBER,
	p_new_entry_id		NUMBER) IS

    -- information about this period and the previous period
    cal_period_info	GCS_UTILITY_PKG.r_cal_period_info;

    source_currency	        VARCHAR2(15);
    target_currency	        VARCHAR2(15);
    curr_treatment_id	        NUMBER;
    hierarchy_id	        NUMBER;
    child_entity_id	        NUMBER;
    parent_entity_id	        NUMBER;
    ledger_id		        NUMBER;
    eq_translation_mode	        VARCHAR2(30);
    is_translation_mode	        VARCHAR2(30);
    per_rate_type_name	        VARCHAR2(30);
    per_avg_rate_type_name      VARCHAR2(30);
    secondary_dimension_column	VARCHAR2(30);
    org_tracking_flag		VARCHAR2(1);
    source_system_code	        NUMBER;
    specific_interco_id	        NUMBER;
    group_by_flag	        VARCHAR2(1);

    ccy_round_factor	NUMBER; -- minimum accountable amount for target ccy

    period_end_rate	NUMBER;
    period_avg_rate	NUMBER;

    period_end_date	DATE;

    re_template		GCS_TEMPLATES_PKG.TemplateRecord;
    cta_template	GCS_TEMPLATES_PKG.TemplateRecord;

    first_ever_period	VARCHAR2(1); -- First period ever for translation (Y/N)

    -- Bugfix 5707630: Holds the lin item id selected on the hierarchy page for
    -- retained earnings.
    hier_li_id   NUMBER;

    module	VARCHAR2(30);
  BEGIN
    module := 'TRANSLATE';
    module_log_write(module, g_module_enter);

    -- In case of an error, we will roll back to this point in time.
    SAVEPOINT gcs_ccy_translation_start;

    -- Set all global variables as necessary
    Set_Globals;

    -- Get various information regarding the relationship passed in.
    Get_Setup_Data(
	p_cal_period_id		=> p_cal_period_id,
	p_cons_relationship_id	=> p_cons_relationship_id,
	p_balance_type_code	=> p_balance_type_code,
	p_hier_dataset_code	=> p_hier_dataset_code,
	x_cal_period_info	=> cal_period_info,
	x_curr_treatment_id	=> curr_treatment_id,
	x_eq_translation_mode	=> eq_translation_mode,
	x_is_translation_mode	=> is_translation_mode,
	x_per_rate_type_name	=> per_rate_type_name,
	x_per_avg_rate_type_name=> per_avg_rate_type_name,
	x_hierarchy_id		=> hierarchy_id,
	x_child_entity_id	=> child_entity_id,
	x_parent_entity_id	=> parent_entity_id,
	x_ledger_id		=> ledger_id,
	x_source_currency	=> source_currency,
	x_target_currency	=> target_currency,
	x_period_end_date	=> period_end_date,
	x_period_end_rate	=> period_end_rate,
	x_period_avg_rate	=> period_avg_rate,
	x_ccy_round_factor	=> ccy_round_factor,
	x_first_ever_period	=> first_ever_period,
	x_re_tmp		=> re_template,
	x_cta_tmp		=> cta_template,
	x_org_tracking_flag	=> org_tracking_flag,
	x_secondary_dim_col	=> secondary_dimension_column,
	x_source_system_code	=> source_system_code,
	x_specific_interco_id	=> specific_interco_id,
	x_group_by_flag		=> group_by_flag,
        x_hier_li_id            => hier_li_id);

    -- Bugfix 5725759
    GCS_TRANS_DYNAMIC_PKG.Initialize_Data_Load_Status (
                     p_hier_dataset_code  =>  p_hier_dataset_code,
                     p_cal_period_id	  =>  p_cal_period_id,
                     p_source_system_code =>  source_system_code,
                     p_from_ccy		      =>  source_currency,
                     p_ledger_id		  =>  ledger_id,
                     p_entity_id		  =>  child_entity_id,
                     p_line_item_id       =>  hier_li_id);

    -- Roll forward the historical rates applicable for this translation.
    GCS_TRANS_DYNAMIC_PKG.Roll_Forward_Rates(
	p_hier_dataset_code	=> p_hier_dataset_code,
	p_source_system_code	=> source_system_code,
	p_ledger_id		=> ledger_id,
	p_cal_period_id		=> p_cal_period_id,
	p_prev_period_id	=> cal_period_info.prev_cal_period_id,
	p_entity_id		=> child_entity_id,
	p_hierarchy_id		=> hierarchy_id,
	p_from_ccy		=> source_currency,
	p_to_ccy		=> target_currency,
	p_eq_xlate_mode		=> eq_translation_mode,
        p_hier_li_id            => hier_li_id);

    -- Populate GCS_TRANSLATION_GT based on whether this is the first ever
    -- translated period or not.
    IF first_ever_period = 'Y' THEN
      GCS_TRANS_DYNAMIC_PKG.Translate_First_Ever_Period(
	p_hier_dataset_code   =>  p_hier_dataset_code,
	p_source_system_code  =>  source_system_code,
	p_ledger_id	      =>  ledger_id,
	p_cal_period_id	      =>  p_cal_period_id,
	p_entity_id	      =>  child_entity_id,
	p_hierarchy_id 	      =>  hierarchy_id,
	p_from_ccy	      =>  source_currency,
	p_to_ccy	      =>  target_currency,
	p_eq_xlate_mode	      =>  eq_translation_mode,
	p_is_xlate_mode	      =>  is_translation_mode,
	p_avg_rate	      =>  period_avg_rate,
	p_end_rate            =>  period_end_rate,
	p_group_by_flag	      =>  group_by_flag,
	p_round_factor	      =>  ccy_round_factor,
        p_hier_li_id          =>  hier_li_id);
    ELSE
      GCS_TRANS_DYNAMIC_PKG.Translate_Subsequent_Period(
	p_hier_dataset_code   =>   p_hier_dataset_code,
	p_cal_period_id	      =>   p_cal_period_id,
	p_prev_period_id      =>   cal_period_info.prev_cal_period_id,
	p_entity_id	      =>   child_entity_id,
	p_hierarchy_id	      =>   hierarchy_id,
	p_ledger_id           =>   ledger_id,
	p_from_ccy	      =>   source_currency,
	p_to_ccy	      =>   target_currency,
	p_eq_xlate_mode	      =>   eq_translation_mode,
	p_is_xlate_mode	      =>   is_translation_mode,
	p_avg_rate	      =>   period_avg_rate,
	p_end_rate	      =>   period_end_rate,
	p_group_by_flag	      =>   group_by_flag,
	p_round_factor	      =>   ccy_round_factor,
	p_source_system_code  =>   source_system_code,
        p_hier_li_id          =>   hier_li_id);

      -- If this is the first period of a fiscal year, perform retained
      -- earnings account maintenance as well.
      IF cal_period_info.cal_period_number = 1 AND
         p_balance_type_code <> 'BUDGET' THEN
        Calculate_RE_Amt(
		p_relationship_id       =>  p_cons_relationship_id,
		p_cal_period_id	        =>  p_cal_period_id,
		p_prev_period_id        =>  cal_period_info.prev_cal_period_id,
		p_entity_id	        =>  child_entity_id,
		p_hierarchy_id	        =>  hierarchy_id,
		p_ledger_id             =>  ledger_id,
		p_from_ccy	        =>  source_currency,
		p_to_ccy	        =>  target_currency,
		p_eq_xlate_mode	        =>  eq_translation_mode,
		p_hier_dataset_code     =>  p_hier_dataset_code,
		p_org_track_flag        =>  org_tracking_flag,
		p_sec_dim_col	        =>  secondary_dimension_column,
		p_re_template	        =>  re_template,
		p_source_system_code	=>  source_system_code,
		p_specific_interco_id	=>  specific_interco_id);
      END IF;

      -- Calculate the PTD or YTD translated balances for YTD or PTD mode
      -- translation, respectively.
      Calculate_Xlated_PTD_YTD;
    END IF;

    -- Create a new entry in the gcs_entry_headers table, and associated lines.
    GCS_TRANS_DYNAMIC_PKG.Create_New_Entry(
	p_new_entry_id		=> p_new_entry_id,
	p_hierarchy_id		=> hierarchy_id,
	p_entity_id		=> child_entity_id,
	p_cal_period_id		=> p_cal_period_id,
	p_balance_type_code	=> p_balance_type_code,
	p_to_ccy		=> target_currency);


    IF p_balance_type_code <> 'BUDGET' THEN
      --Calculate the CTA account balances
      GCS_TEMPLATES_DYNAMIC_PKG.balance(p_new_entry_id, cta_template,
					p_balance_type_code, hierarchy_id,
					child_entity_id);
    END IF;

    -- If this is the last period of a fiscal year, calculate
    -- the retained earnings historical rate
    IF cal_period_info.next_cal_period_number = 1 AND
       p_balance_type_code <> 'BUDGET' AND
       eq_translation_mode = 'YTD' THEN
      Calculate_RE_Rate(
	p_relationship_id       =>  p_cons_relationship_id,
	p_cal_period_id	        =>  p_cal_period_id,
	p_next_period_id        =>  cal_period_info.next_cal_period_id,
	p_entity_id	        =>  child_entity_id,
	p_hierarchy_id	        =>  hierarchy_id,
	p_ledger_id	        =>  ledger_id,
	p_from_ccy	        =>  source_currency,
	p_to_ccy	        =>  target_currency,
	p_hier_dataset_code     =>  p_hier_dataset_code,
	p_org_track_flag        =>  org_tracking_flag,
	p_sec_dim_col           =>  secondary_dimension_column,
	p_re_template	        =>  re_template,
	p_source_system_code	=>  source_system_code,
	p_specific_interco_id	=>  specific_interco_id,
	p_entry_id	        =>  p_new_entry_id);
    END IF;

    -- Create or update rows in the gcs_translation_track_h and
    -- gcs_translation_statuses tables
    update_status_tracking(
	p_hierarchy_id		=> hierarchy_id,
	p_entity_id		=> child_entity_id,
	p_currency_code		=> target_currency,
	p_cal_period_id		=> p_cal_period_id,
	p_hier_dataset_code	=> p_hier_dataset_code,
	p_cal_period_number	=> cal_period_info.cal_period_number,
	p_cal_period_year	=> cal_period_info.cal_period_year,
	p_next_cal_period_id	=> cal_period_info.next_cal_period_id);

    commit;

    -- Write the appropriate information to the execution report
    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_TEMPLATES_PKG.GCS_TMP_BALANCING_FAILED THEN
      ROLLBACK TO gcs_ccy_translation_start;
      x_errbuf := FND_MESSAGE.get;
      x_retcode := '2';
      module_log_write(module, g_module_failure);
    WHEN GCS_CCY_SUBPROGRAM_RAISED THEN
      ROLLBACK TO gcs_ccy_translation_start;
      x_errbuf := g_error_text;
      x_retcode := '2';
      module_log_write(module, g_module_failure);
    WHEN OTHERS THEN
      ROLLBACK TO gcs_ccy_translation_start;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      x_errbuf := SQLERRM;
      x_retcode := '2';
      module_log_write(module, g_module_failure);
  END Translate;

END GCS_TRANSLATION_PKG;

/
