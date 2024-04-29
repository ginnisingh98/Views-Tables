--------------------------------------------------------
--  DDL for Package Body GCS_XML_DT_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_XML_DT_UTILITY_PKG" AS
/* $Header: gcsxmldtutilb.pls 120.24 2008/01/10 09:21:52 rthati noship $ */

--
-- PRIVATE GLOBAL VARIABLES
--

   -- The API name
   g_pkg_name     CONSTANT VARCHAR2 (40) := 'gcs.plsql.GCS_XML_DT_UTILITY_PKG';
   -- A newline character. Included for convenience when writing long strings.
   g_nl                    VARCHAR2 (1)                               := '
';
   -- session id
   g_session_id            NUMBER;

--
-- PRIVATE PROCEDURES
--
---------------------------------------------------------------------------
   --
   -- Procedure
   --   get_value_set_clause
   -- Purpose
   --   An API to handle Data Submission Trial Balance Data Template Literals
   --   for handling value_set_id for dimensions
   -- Arguments
   -- Notes
   -- Created to fix bug 5394468

   -- Bugfix 5843592 , Added one parameter p_load_id
 PROCEDURE  get_value_set_clause	( p_entity_id			      IN  NUMBER,
                                    p_load_id             IN  NUMBER,
					                          p_value_set_clause		OUT NOCOPY VARCHAR2)


 IS
   TYPE r_dimension_vs_id       IS RECORD
                                (dimension_id            NUMBER(15),
                                 value_set_id            NUMBER);

   TYPE t_dimension_vs_id	IS TABLE OF 	r_dimension_vs_id;

   l_dimension_vs_id		     t_dimension_vs_id;

  -- Bug Fix: 5843592, Get the attribute id and version id of the CAL_PERIOD_END_DATE of calendar period
   l_period_end_date_attr        NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .attribute_id;
   l_period_end_date_version     NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .version_id;

  l_api_name                VARCHAR2 (30) := 'GET_VALUE_SET_CLAUSE';


 BEGIN

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, '<<Enter>>');
   END IF;

  -- Bugfix 5843592, Get the correct source ledger Id, depending upon the calendar period

   SELECT gvcd.dimension_id,
		      gvcd.value_set_id
   BULK COLLECT INTO
          l_dimension_vs_id
   FROM	  fem_global_vs_combo_defs	gvcd,
		      fem_ledgers_attr		      fla,
		      gcs_entities_attr		      gea,
		      fem_tab_column_prop		    ftcp,
		      fem_tab_columns_b		      ftcb,
          gcs_data_sub_dtls         gdsd,
          fem_cal_periods_attr      fcpa
   WHERE  gdsd.load_id                = p_load_id
     AND  gea.entity_id               = p_entity_id
     AND  gea.data_type_code          = gdsd.balance_type_code
     AND  fcpa.cal_period_id          = gdsd.cal_period_id
     AND  fcpa.attribute_id           = l_period_end_date_attr
     AND  fcpa.version_id             = l_period_end_date_version
     AND  fcpa.date_assign_value BETWEEN gea.effective_start_date
                                     AND NVL(gea.effective_end_date,  fcpa.date_assign_value)
     AND  fla.ledger_id			          =	gea.ledger_id
     AND  fla.attribute_id		        =	pLedgerVsComboAttr
     AND  fla.version_id			        =	pLedgerVsComboVersion
     AND  ftcb.table_name			        =	'FEM_BALANCES'
     AND  ftcb.dimension_id		        =	gvcd.dimension_id
     AND  ftcb.column_name		        =	ftcp.column_name
     AND  ftcb.column_name		        <>	'INTERCOMPANY_ID'
     AND  ftcp.column_property_code   =	'PROCESSING_KEY'
     AND  ftcp.table_name			        =	ftcb.table_name
     AND  gvcd.global_vs_combo_id   	=	fla.dim_attribute_numeric_member;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'Dimension Value Set retrieved in the collection');
   END IF;

   IF (l_dimension_vs_id.FIRST IS NOT NULL AND l_dimension_vs_id.LAST IS NOT NULL) THEN

      FOR	l_counter	IN	l_dimension_vs_id.FIRST..l_dimension_vs_id.LAST 	LOOP

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'Adding value set clause for dimension-id :' || l_dimension_vs_id(l_counter).dimension_id);
          END IF;

          IF (l_dimension_vs_id(l_counter).dimension_id 	=	8) THEN

              p_value_set_clause		:=	p_value_set_clause	|| g_nl ||
   								' AND	 fcov.value_set_id	= '	|| l_dimension_vs_id(l_counter).value_set_id || g_nl ||
   						    ' AND	 fciv.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;

		       ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	14) THEN

              p_value_set_clause              :=      p_value_set_clause  || g_nl ||
   								' AND 	 fliv.value_set_id	= '	|| l_dimension_vs_id(l_counter).value_set_id ;

		       ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	3 AND

                 gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID') = 'Y') THEN
              p_value_set_clause		:=	p_value_set_clause || g_nl ||
   								' AND	 fpb.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;

		       ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	2 AND

                 gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID') = 'Y') THEN
              p_value_set_clause		:=	p_value_set_clause || g_nl ||
   								' AND    fnab.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;

		       ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	13 AND

                 gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
   								' AND	 fchb.value_set_id	= '	|| l_dimension_vs_id(l_counter).value_set_id ;

		       ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	15 AND

                 gcs_utility_pkg.get_fem_dim_required('PROJECT_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND	 fpjb.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	16 AND

                 gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
   								' AND	 fcb.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;

		       ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	30 AND

                 gcs_utility_pkg.get_fem_dim_required('TASK_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND	 ftb.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	19 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud1.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	20 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud2.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       21 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud3.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       22 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud4.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       23 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud5.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       24 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud6.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id    =      25 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud7.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       26 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud8.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       27 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud9.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;

          ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       28 AND

                 gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
              p_value_set_clause              :=      p_value_set_clause || g_nl ||
              					' AND    fud10.value_set_id     = '     || l_dimension_vs_id(l_counter).value_set_id ;

          END IF;

      END LOOP;
   END IF;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, '<<Exit>>');
   END IF;

 END;

---------------------------------------------------------------------------
   --
   -- Function
   --   before_cmtb_report
   -- Purpose
   --   An API to handle consolidation Trial Balance Data Template Literals
   -- Arguments
   -- Notes
   --
   FUNCTION before_cmtb_report RETURN BOOLEAN
   IS
      l_api_name   VARCHAR2 (30) := 'BEFORE_CMTB_REPORT';


      -- Bugfix 5087857
      -- Bugfix 5696229: added distinct clause

      CURSOR c1 ( p_entity_id number,
                  p_run_name varchar2 )
      IS
          SELECT DISTINCT gcr.child_entity_id
          FROM   gcs_cons_relationships gcr,
                 gcs_cons_eng_runs gcer,
                 fem_cal_periods_attr fcpa
          WHERE  gcr.parent_entity_id     = p_entity_id
          AND    gcr.dominant_parent_flag = 'Y'
          AND    gcr.hierarchy_id         = gcer.hierarchy_id
          AND    gcer.run_name            = p_run_name
          AND    gcer.MOST_RECENT_FLAG    = 'Y'
          AND    fcpa.cal_period_id       = gcer.cal_period_id
          AND    fcpa.attribute_id        = pCalPeriodEndDateAttr
          AND	   fcpa.version_id          = pCalPeriodEndDateVersion
          AND    fcpa.date_assign_value   BETWEEN gcr.start_date
                                              AND NVL(gcr.end_date,fcpa.date_assign_value);


   BEGIN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.begin', '<<Enter>>');
     END IF;

      -- Prepare parent entity and it's children in comma delimited list
      -- which would be used by IN clause of data template query
      entityIdListLiteral :=' AND   fb.entity_id  IN ('||pEntityId;
      FOR temp in c1(pEntityId, pRunName) LOOP
         entityIdListLiteral := entityIdListLiteral ||','|| temp.child_entity_id;
      END LOOP;
      entityIdListLiteral := entityIdListLiteral ||') ';

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'entityIdListLiteral : ' || entityIdListLiteral);
      END IF;

      -- insert into temp_cmtb values (entityIdListLiteral);
     --  commit;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.end', '<<Exit>>');
     END IF;

     RETURN(TRUE);

   EXCEPTION
     WHEN OTHERS THEN
     BEGIN
        -- Write appropriate error log information
        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
           FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_pkg_name || '.' || l_api_name, substr(SQLERRM, 1, 200) || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
        END IF;         RETURN(FALSE);
     END;

   END before_cmtb_report;

---------------------------------------------------------------------------
   --
   -- Function
   --   before_dstb_report
   -- Purpose
   --   An API to handle Data Submission Trial Balance Data Template Literals
   -- Arguments
   -- Notes
   --
   FUNCTION before_dstb_report RETURN BOOLEAN
   IS
      l_api_name               VARCHAR2 (30) := 'BEFORE_DSTB_REPORT';
      l_currency_type_code     VARCHAR2(30);
      l_currency_code          VARCHAR2(15);
      l_balance_type_code      VARCHAR2(30);
      l_source_system_code     VARCHAR2(30);
      l_entity_currency_code   VARCHAR2(30);
      l_map_flag               VARCHAR2(30);
      --start bug fix 5394468
      l_value_set_clause       VARCHAR2(2000);
      l_entity_id              NUMBER;
      --end bug fix 5394468

      -- Bug Fix: 5843592, Get the attribute id and version id of the CAL_PERIOD_END_DATE of calendar period
      l_period_end_date_attr        NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .attribute_id;
      l_period_end_date_version     NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .version_id;


   BEGIN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.begin', '<<Enter>>');
     END IF;
    -- Retrieve information to construct appropriate literals
    -- used by data template to avoid unnecessary decodes
    -- Since decodes are making index unutilized and impacting performance


    -- Bugfix 5843592, Get the correct source ledger Id, depending upon the calendar period

    SELECT gdsd.currency_type_code,
           gdsd.currency_code,
           gdsd.balance_type_code,
           gea.source_system_code,
           fla_comp.dim_attribute_varchar_member entity_currency_code,
           gdsd.entity_id
      INTO l_currency_type_code,
           l_currency_code,
           l_balance_type_code,
           l_source_system_code,
           l_entity_currency_code,
           l_entity_id
      FROM gcs_data_sub_dtls     gdsd,
           gcs_entities_attr     gea,
           fem_ledgers_attr      fla_comp,
           fem_cal_periods_attr  fcpa
     WHERE gdsd.load_id                = pXmlFileId
       AND gea.entity_id               = gdsd.entity_id
       AND gea.data_type_code          = gdsd.balance_type_code
       AND fcpa.cal_period_id          = gdsd.cal_period_id
       AND fcpa.attribute_id           = l_period_end_date_attr
       AND fcpa.version_id             = l_period_end_date_version
       AND fcpa.date_assign_value BETWEEN gea.effective_start_date AND NVL(gea.effective_end_date,  fcpa.date_assign_value)
       AND fla_comp.ledger_id          = gea.ledger_id
       AND fla_comp.attribute_id       = pLedgerCurrAttr
       AND fla_comp.version_id         = pLedgerCurrVersion ;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'Load Id              : ' || pXmlFileId );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'Source System Code   : ' || l_source_system_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'Balance Type Code    : ' || l_balance_type_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'Currency Type Code   : ' || l_currency_type_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'Currency Code	       : ' || l_currency_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'Entity Currency Code : ' || l_entity_currency_code);
      END IF;

      currencyLiteral := ' ';
      currencyTypeLiteral := ' ';
      entityOrgsLiteral := ' ';
      finElemsLiteral := ' ';

      -- Prepare literals for data template line level select without need complex decodes
      -- Also when l_currency_code is not null we need not call fnd_currency.safe_get_format_mask
      -- at line level
      IF (l_currency_code IS NULL ) THEN
         dsSelectLiteral :=
                      'to_char(fb.ytd_debit_balance_e,fnd_currency.safe_get_format_mask(fb.currency_code,50)) ytd_debit_balance_e,'||
                      'to_char(fb.ytd_credit_balance_e,fnd_currency.safe_get_format_mask(fb.currency_code,50)) ytd_credit_balance_e,'||
                      'to_char(fb.ytd_balance_e,fnd_currency.safe_get_format_mask(fb.currency_code,50)) ytd_balance_e,'||
                      'to_char(fb.ytd_balance_f,fnd_currency.safe_get_format_mask(fb.currency_code,50)) ytd_balance_f,'||
                      ' fb.currency_code currency_code1,'||
                      ' fct.name currency_name1,';
      ELSE
         dsSelectLiteral :=
                      'to_char(fb.ytd_debit_balance_e,:FORMAT_MASK) ytd_debit_balance_e,'||
                      'to_char(fb.ytd_credit_balance_e,:FORMAT_MASK) ytd_credit_balance_e,'||
                      'to_char(fb.ytd_balance_e,:FORMAT_MASK) ytd_balance_e,'||
                      'to_char(fb.ytd_balance_f,:FORMAT_MASK) ytd_balance_f,'||
                      ':currency_code currency_code1,'||
                      ':currency_name currency_name1,';

      END IF;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'dsSelectLiteral : ' || dsSelectLiteral);
      END IF;

      -- Prepare financial element where clause literal for data template line level query
      -- Bug 5066176 :: Santosh
      -- Default financial_elem_id to 100 if financial_elem_id is not enabled
      -- Bug 5162091 :: Santosh
      IF (l_balance_type_code = 'ADB') THEN
         finElemsLiteral := ' AND fb.FINANCIAL_ELEM_ID = 140 ';
      ELSE
         finElemsLiteral := ' AND NVL(fb.FINANCIAL_ELEM_ID,100) NOT IN (140,10000) ';
      END IF;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'finElemsLiteral : ' || finElemsLiteral);
      END IF;

      -- Prepare base_currency where clause literal for data template line level query
      IF (l_source_system_code <> 10 AND l_currency_type_code = 'BASE_CURRENCY') THEN
         currencyLiteral := ' AND fb.currency_code = '||''''||l_currency_code||'''';
      ELSE
         currencyLiteral := ' ';
      END IF;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'currencyLiteral : ' || currencyLiteral);
      END IF;

      -- Check if this is a mapped (for which org mapping in not required)
      -- or unmapped (for which org mapping is required) dstb case

      -- Bugfix 5843592, Get the correct source ledger Id, depending upon the calendar period

       SELECT decode(gvcd.value_set_id, fch_gvcd.value_set_id, 'MAPPED', 'UNMAPPED')
        INTO  l_map_flag
        FROM  fem_global_vs_combo_defs gvcd,
              fem_ledgers_attr         fla,
              gcs_entities_attr        gea,
              fem_tab_column_prop      ftcp,
              fem_tab_columns_b        ftcb,
              gcs_system_options       gso,
              fem_global_vs_combo_defs fch_gvcd,
              gcs_data_sub_dtls        gdsd ,
              fem_cal_periods_attr     fcpa
        WHERE gso.fch_global_vs_combo_id = fch_gvcd.global_vs_combo_id
          AND gea.entity_id              = gdsd.entity_id
          AND gea.data_type_code         = gdsd.balance_type_code
          AND fcpa.cal_period_id         = gdsd.cal_period_id
          AND fcpa.attribute_id          = l_period_end_date_attr
          AND fcpa.version_id            = l_period_end_date_version
          AND fcpa.date_assign_value BETWEEN gea.effective_start_date AND NVL(gea.effective_end_date,  fcpa.date_assign_value)
          AND fla.ledger_id              = gea.ledger_id
          AND fla.attribute_id           = pLedgerVsComboAttr
          AND fla.version_id             = pLedgerVsComboVersion
          AND ftcb.table_name            = 'FEM_BALANCES'
          AND ftcb.dimension_id          = gvcd.dimension_id
          AND ftcb.column_name           = ftcp.column_name
          AND ftcb.column_name          <> 'INTERCOMPANY_ID'
          AND ftcp.column_property_code  = 'PROCESSING_KEY'
          AND ftcp.table_name            = ftcb.table_name
          AND gvcd.global_vs_combo_id    = fla.dim_attribute_numeric_member
          AND gvcd.dimension_id          = 8
          AND fch_gvcd.dimension_id      = 8
          AND gdsd.load_id               = pXmlFileId;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_map_flag : ' || l_map_flag);
      END IF;

      -- If OGL dstb case
      IF (l_source_system_code = 10 ) THEN
         -- if loaded currency = entity currency then entered currency case
         IF (l_currency_code = l_entity_currency_code) THEN
            currencyTypeLiteral := ' AND fb.currency_type_code = '||''''||'ENTERED'||'''';
         -- else translated currency case
         ELSE
            currencyTypeLiteral := ' AND fb.currency_type_code = '||''''||'TRANSLATED'||'''';
         END IF;

         -- if mapped OGL dstb
         IF (l_map_flag = 'MAPPED') THEN
            entityOrgsLiteral :=  ' AND EXISTS (SELECT 1 '||
                                  '              FROM fem_cctr_orgs_b cob,  '||
                                  '                   gcs_entity_cctr_orgs eco '||
                                  '             WHERE cob.value_set_id = :ORG_VALUE_SET_ID'||
                                  '               AND eco.entity_id = :ENTITY_ID'||
                                  '               AND eco.company_cost_center_org_id = cob.company_cost_center_org_id  '||
                                  '               AND cob.company_cost_center_org_id = fb.company_cost_center_org_id)';
         END IF;
      -- else Non OGL dstb case
      ELSE
         currencyTypeLiteral := ' ';
         entityOrgsLiteral := ' ';
      END IF;

      -- Check if unmapped dstb case then for prepare entity org literal
      -- irrespective of source system code value
      IF (l_map_flag = 'UNMAPPED') THEN

         entityOrgsLiteral :=  ' AND   EXISTS  (SELECT  1  '||
                               '                 FROM  fem_cctr_orgs_hier fcoh,  '||
                               '                       fem_global_vs_combo_defs fgvscd_master,  '||
                               '                       gcs_system_options gso,  '||
                               '                       fem_global_vs_combo_defs fgvscd_child,  '||
                               '                       fem_xdim_dimensions fxd,  '||
                               '                       fem_object_definition_b fodb,  '||
                               '                       gcs_entity_cctr_orgs feco  '||
                               '               WHERE   fcoh.child_id = fb.company_cost_center_org_id  '||
                               '               AND     fxd.dimension_id = 8  '||
                               '               AND     fodb.object_id = fxd.default_mvs_hierarchy_obj_id  '||
                               '               AND     fcoh.hierarchy_obj_def_id = fodb.object_definition_id '||
                               '               AND     fgvscd_master.global_vs_combo_id = gso.fch_global_vs_combo_id  '||
                               '               AND     fgvscd_master.dimension_id = 8  '||
                               -- hakumar 5350290: removed trailing tabs from SUB_GLOBAL_VS_COMBO_ID
                               '               AND     fgvscd_child.global_vs_combo_id = :SUB_GLOBAL_VS_COMBO_ID'||
                               '               AND     fgvscd_child.dimension_id = 8  '||
                               '               AND     fcoh.parent_value_set_id = fgvscd_master.value_set_id  '||
                               '               AND     fcoh.child_value_set_id = fgvscd_child.value_set_id  '||
                               '               AND     feco.entity_id = :ENTITY_ID'||
                               '               AND     fcoh.parent_id = feco.company_cost_center_org_id) ';


      END IF;
      --start bug fix 5394468
      get_value_set_clause      ( p_entity_id          => l_entity_id,
                                  p_load_id            => pXmlFileId,
                                  p_value_set_clause   => l_value_set_clause);

      entityOrgsLiteral := entityOrgsLiteral || l_value_set_clause;
      --end bug fix 5394468

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'currencyTypeLiteral : ' || currencyTypeLiteral);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'entityOrgsLiteral   : ' || entityOrgsLiteral);
      END IF;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.end', '<<Exit>>');
      END IF;

      RETURN(TRUE);

   EXCEPTION
      WHEN OTHERS THEN
      BEGIN

         -- Write appropriate error log information
         IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_pkg_name || '.' || l_api_name, SUBSTR(SQLERRM, 1, 200) || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
         END IF;
         RETURN(FALSE);
      END;

   END before_dstb_report;




   --
   -- Function
   --   before_femnonposted_report
   -- Purpose
   --   An API to handle Fem Non Posted  Data Template Literals
   -- Arguments
   -- Notes
   --
FUNCTION before_femnonposted_report RETURN BOOLEAN
IS
  l_api_name                 VARCHAR2 (30) := 'BEFORE_FEMNONPOSTED_REPORT';
  l_ledger_id                NUMBER;
  l_balances_rule_id         NUMBER;
  l_source_datasetcode       NUMBER;
  l_datatype_code            VARCHAR2(150);
  l_dataset_code             VARCHAR2(150);
  l_budget_vers_id           NUMBER;
  l_enc_type_id              NUMBER;
  l_cal_period               VARCHAR2(150);
  l_coa_id                   NUMBER;
  l_currency_code            VARCHAR2(150);
  l_segment_column           VARCHAR2(150);
  l_global_vsid              NUMBER;
  l_fch_vsid                 NUMBER;
  l_cal_pd_end_date          VARCHAR2(150);
  l_def_hier_id              NUMBER;
  l_her_obj_def_id           NUMBER        := -1;
  l_map_flag                 VARCHAR2(10)  := 'UNMAPPED';
  g_dimension_attr_info gcs_utility_pkg.t_hash_dimension_attr_info := gcs_utility_pkg.g_dimension_attr_info;

  -- Bug Fix: 5843592, Get the attribute id and version id of the CAL_PERIOD_END_DATE of calendar period

  l_period_end_date_attr     NUMBER        := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                              .attribute_id;
  l_period_end_date_version  NUMBER        := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                              .version_id;

BEGIN
  --Do initial logging
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.begin', '<<Enter>>');
  END IF;

  /*
  From the entity_id, Fetch currency_code and dataset_code.
  */

  -- Bugfix 5843592, Get the correct source ledger Id, depending upon the calendar period

  SELECT fla.dim_attribute_varchar_member,
  		   fda.dim_attribute_varchar_member,
         gea.ledger_id
  INTO   l_currency_code,
         l_dataset_code,
         l_ledger_id
  FROM   gcs_data_type_codes_vl gdtcb,
         gcs_entities_attr      gea,
         fem_ledgers_attr       fla,
         fem_datasets_attr      fda,
         fem_cal_periods_attr   fcpa
  WHERE  gea.data_type_code     = gdtcb.data_type_code
    AND  fla.ledger_id          = gea.ledger_id
    AND  fda.dataset_code       = gdtcb.source_dataset_code
    AND  gea.entity_id          = pEntityId
    AND  gea.data_type_code     = pDataTypeCode
    AND  fcpa.cal_period_id     = pCalPeriodId
    AND  fcpa.attribute_id      = l_period_end_date_attr
    AND  fcpa.version_id        = l_period_end_date_version
    AND  fcpa.date_assign_value BETWEEN gea.effective_start_date
                                   AND NVL(gea.effective_end_date, fcpa.date_assign_value )
    AND  fla.attribute_id       = gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE').attribute_id
    AND  fla.version_id         = gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE').version_id
    AND  fda.attribute_id       = gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-DATASET_BALANCE_TYPE_CODE').attribute_id
    AND  fda.version_id         = gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-DATASET_BALANCE_TYPE_CODE').version_id  ;

  IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_currency_code : '||l_currency_code);
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_dataset_code  : '||l_dataset_code);
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_ledger_id     : '||l_ledger_id);
  END IF;

  -- Bugfix 5843592, Get the correct source data set code, depending upon the calendar period

  SELECT fibrd.actual_output_dataset_code
    INTO l_source_datasetcode
    FROM gcs_entities_attr       gea ,
         fem_object_definition_b fodb,
         fem_intg_bal_rule_defs  fibrd,
         fem_cal_periods_attr    fcpa
  WHERE  fodb.object_id            = gea.balances_rule_id
    AND  fibrd.bal_rule_obj_def_id = fodb.object_definition_id
    AND  gea.entity_id             = pEntityId
    AND  gea.data_type_code        = pDataTypeCode
    AND  fcpa.cal_period_id        = pCalPeriodId
    AND  fcpa.attribute_id         = l_period_end_date_attr
    AND  fcpa.version_id           = l_period_end_date_version
    AND  fcpa.date_assign_value BETWEEN gea.effective_start_date AND NVL(gea.effective_end_date, fcpa.date_assign_value ) ;


  IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_source_datasetcode : '||l_source_datasetcode);
  END IF;

  /*
  From each dataset code (fem_datasets_attr), you can get the
  balance type (actual, budget, or encumbrance), and the
  budget_version_id or encumbrance_type_id, if applicable.
  */

  /* Distinguish between budget and encumbrance*/
  IF(l_dataset_code='BUDGET') THEN

    SELECT fda.dim_attribute_numeric_member
      INTO l_budget_vers_id
      FROM fem_datasets_attr  fda
     WHERE fda.attribute_id = gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-BUDGET_ID').attribute_id
       AND fda.version_id   = gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-BUDGET_ID').version_id
       AND fda.dataset_code = l_source_datasetcode ;     -- datasetcode from previous query

    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_budget_vers_id : '||l_budget_vers_id);
    END IF;

  END IF;

  IF(l_dataset_code='ENCUMBRANCE') THEN

  SELECT fda.dim_attribute_numeric_member
    INTO l_enc_type_id
    FROM fem_datasets_attr  fda
   WHERE fda.attribute_id = gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-ENCUMBRANCE_TYPE_ID').attribute_id
     AND fda.version_id   = gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-ENCUMBRANCE_TYPE_ID').version_id
     AND fda.dataset_code = l_source_datasetcode  ;    -- datasetcode from previous query

     IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_enc_type_id : '||l_enc_type_id);
   END IF;

  END IF;

  /*
  From the cal_period_id in fem_cal_periods_tl, you can get the cal_period_name,
  which will match the period_name value in GL
  */

  SELECT cal_period_name
    INTO l_cal_period
    FROM fem_cal_periods_tl
   WHERE cal_period_id = pCalPeriodId --obtained from UI parameters
     AND language      = userenv('LANG');

  IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_cal_period : '||l_cal_period);
  END IF;

  /*
  we need to know which column it corresponds to in the GL data table
  */

  SELECT application_column_name
    INTO l_segment_column
    FROM fnd_segment_attribute_values fsav ,
  	     gl_sets_of_books gsob
   WHERE fsav.id_flex_num            =  gsob.CHART_OF_ACCOUNTS_ID
     AND fsav.segment_attribute_type = 'GL_BALANCING'
     AND fsav.attribute_value        = 'Y'
     AND fsav.application_id         = 101
     AND fsav.id_flex_code           = 'GL#'
     AND gsob.set_of_books_id        = l_ledger_id;

  IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_segment_column : '||l_segment_column);
  END IF;

  /* Finally form the literal to return back to the main template*/
  FilterParamsLiteral := ' AND  gbd.LEDGER_ID = ' || l_ledger_id ;
  FilterParamsLiteral := FilterParamsLiteral || ' AND gbd.CURRENCY_CODE = ''' || l_currency_code ||'''' ;
  FilterParamsLiteral := FilterParamsLiteral || ' AND gbd.PERIOD_NAME = ''' || l_cal_period ||'''' ;

  IF (l_budget_vers_id IS NOT NULL) THEN
     FilterParamsLiteral := FilterParamsLiteral || ' and gbd.BUDGET_VERSION_ID = ' || l_enc_type_id  ;
  END IF;
  IF (l_enc_type_id IS NOT NULL) THEN
     FilterParamsLiteral := FilterParamsLiteral || ' and  gbd.ENCUMBRANCE_TYPE_ID =' || l_enc_type_id ;
  END IF;

  FilterParamsLiteral := FilterParamsLiteral || ' AND gcc.' ||l_segment_column || ' = fidl.balance_seg_value';
  FilterParamsLiteral := FilterParamsLiteral || ' AND  fidl.ledger_id  = ' || l_ledger_id ;
  FilterParamsLiteral := FilterParamsLiteral || ' AND fidl.dataset_code   = ' || l_source_datasetcode  ;

  IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'FilterParamsLiteral : '||FilterParamsLiteral);
  END IF;

  --Collect header level Names here
  --LEDGER
   SELECT ''''  ||LEDGER_NAME || ''''
     INTO LedgerLiteral
     FROM fem_ledgers_vl
    WHERE ledger_id = l_ledger_id;

   IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'LedgerLiteral : '||LedgerLiteral);
   END IF;

  --Decide the Mapped/Unmapped status.

  -- Bugfix 5843592, Get the correct source ledger Id, depending upon the calendar period

     SELECT gvcd.value_set_id,
            fch_gvcd.value_set_id,
            decode(gvcd.global_vs_combo_id, fch_gvcd.global_vs_combo_id, 'MAPPED', 'UNMAPPED')
      INTO  l_global_vsid,
            l_fch_vsid,
            l_map_flag
      FROM  fem_global_vs_combo_defs gvcd,
            fem_ledgers_attr         fla,
            gcs_entities_attr        gea,
            gcs_system_options       gso,
            fem_global_vs_combo_defs fch_gvcd,
            gcs_data_sub_dtls        gdsd,
            fem_cal_periods_attr     fcpa
      WHERE gso.fch_global_vs_combo_id = fch_gvcd.global_vs_combo_id
        AND fla.ledger_id              = gea.ledger_id
        AND fla.attribute_id           = pLedgerVsComboAttr
        AND fla.version_id             = pLedgerVsComboVersion
        AND gdsd.load_id               = pLoadId
        AND gea.entity_id              = gdsd.entity_id
        AND gea.data_type_code         = gdsd.balance_type_code
        AND fcpa.cal_period_id         = gdsd.cal_period_id
        AND fcpa.attribute_id          = l_period_end_date_attr
        AND fcpa.version_id            = l_period_end_date_version
        AND fcpa.date_assign_value BETWEEN gea.effective_start_date
                                       AND NVL(gea.effective_end_date, fcpa.date_assign_value )
        AND gvcd.global_vs_combo_id    = fla.dim_attribute_numeric_member
        AND gvcd.dimension_id          = 8
        AND fch_gvcd.dimension_id      = 8 ;

  IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_global_vsid : '||l_global_vsid);
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_fch_vsid : '||l_fch_vsid);
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_map_flag : '||l_map_flag);
  END IF;

  IF (l_map_flag = 'MAPPED') THEN
            entityOrgsLiteral :=  ' AND EXISTS (SELECT 1 '||
                                  '              FROM gcs_entity_cctr_orgs eco  '||
                                  '              WHERE eco.entity_id =' ||pEntityId ||
                                  '              AND eco.company_cost_center_org_id = fb.company_cost_center_org_id) ';

  ELSE
    --Do further filtration  on HIERARCHY_OBJ_DEF_ID
    -- Get the Cal Period End Date
    SELECT fcpa.date_assign_value
      INTO l_cal_pd_end_date
      FROM fem_cal_periods_attr fcpa
     WHERE fcpa.attribute_id  = l_period_end_date_attr
       AND fcpa.version_id    = l_period_end_date_version
       AND fcpa.cal_period_id = pCalPeriodId ;

    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_cal_pd_end_date : '||l_cal_pd_end_date);
    END IF;

    -- Get the  object_def_id with care for end date
	  SELECT  NVL(default_mvs_hierarchy_obj_id,-1)
      INTO  l_def_hier_id
      FROM  fem_xdim_dimensions
      WHERE dimension_id = 8;

    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_def_hier_id : '||l_def_hier_id);
    END IF;
    --Bugfix 5853090
    IF(l_def_hier_id IS NULL OR l_def_hier_id = -1) THEN

        entityOrgsLiteral := 'and 1=2'   ;

    ELSE

       SELECT object_definition_id
         INTO l_her_obj_def_id
         FROM fem_object_definition_b
        WHERE object_id = l_def_hier_id
          AND l_cal_pd_end_date BETWEEN effective_start_date AND effective_end_date;

       IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_her_obj_def_id : '||l_her_obj_def_id);
       END IF;

   -- Append the extra filter clause here

      entityOrgsLiteral := ' AND fb.company_cost_center_org_id IN (SELECT ' ||
         ' child_id FROM fem_cctr_orgs_hier WHERE  parent_value_set_id = ' || l_fch_vsid ||
         ' AND child_value_set_id = ' || l_global_vsid ||
         ' AND parent_id in (SELECT company_cost_center_org_id FROM gcs_entity_cctr_orgs'||
         ' WHERE entity_id = ' || pEntityId || ')' || ' AND HIERARCHY_OBJ_DEF_ID = ' || l_her_obj_def_id || ')';


      END IF;
  END IF;

  IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'entityOrgsLiteral : '||entityOrgsLiteral);
  END IF;

--Finally return true to show success of the call.
   RETURN(TRUE);
EXCEPTION
  WHEN OTHERS THEN
   BEGIN
      -- Write appropriate error log information
      IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
        FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_pkg_name || '.' || l_api_name, SUBSTR(SQLERRM, 1, 200) || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
    RETURN(FALSE);
  END;
END before_femnonposted_report;

   --
   -- Function
   --   writeback_report
   -- Purpose
   --   An API to handle Adjustment Writeback Data Template Literals
   -- Arguments
   -- Notes
   --
   FUNCTION writeback_report RETURN BOOLEAN
   IS
     l_api_name   VARCHAR2 (30) := 'WRITEBACK_REPORT';
     CURSOR c1 ( p_Xml_File_Id NUMBER)
     IS
       SELECT application_column_name
         FROM fnd_id_flex_segments  fifs,
              gcs_writeback_headers gwh,
              gl_sets_of_books      gsb
        WHERE gwh.writeback_id = p_Xml_File_Id
  	      AND gwh.ledger_id    = gsb.set_of_books_id
	        AND fifs.id_flex_num = gsb.chart_of_accounts_id
          AND id_flex_code     = 'GL#'
          AND application_id   = 101
     ORDER BY segment_num;
     counter NUMBER;

     BEGIN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <=	FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.begin', '<<Enter>>');
       END IF;

       accountName := NULL;
       FOR temp IN c1(pXmlFileId) LOOP
         IF accountName IS NULL THEN
           accountName := temp.application_column_name;
         ELSE
           accountName := accountName || '||''-''||' || temp.application_column_name;
         END IF;
       END LOOP;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'accountName : ' || accountName);
       END IF;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.end', '<<Exit>>');
       END IF;

     RETURN(TRUE);

     EXCEPTION WHEN OTHERS THEN
       BEGIN
       -- Write appropriate error log information
       IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
         FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_pkg_name || '.' || l_api_name, SUBSTR(SQLERRM, 1, 200) || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
       END IF;
       RETURN(FALSE);
     END;

   END writeback_report;

   --
   -- Function
   --   before_entry_report
   -- Purpose
   --   Adds the additional where clasue to the query displaying the entry
   --   report data depending upon the LINE_TYPE_CODE column.
   -- Arguments
   -- Notes
   --   Added to fix bug 5518000
   --
   FUNCTION before_entry_report RETURN BOOLEAN
   IS
     l_api_name   VARCHAR2 (30) := 'BEFORE_ENTRY_REPORT';
     CURSOR period_cur (pEntryId NUMBER, pAccountingYrAttrId NUMBER, pAccountingYrVerId NUMBER)
     IS
       SELECT fcpa.number_assign_value view_period_year
         FROM gcs_entry_headers    geh,
              fem_cal_periods_attr fcpa
        WHERE geh.entry_id       = pEntryId
          AND fcpa.cal_period_id = pCalPeriodId
          AND fcpa.attribute_id  = pAccountingYrAttrId
          AND fcpa.version_id    = pAccountingYrVerId;

     CURSOR year_to_apply_re_cur (pEntryId NUMBER)
     IS
       SELECT geh.year_to_apply_re
         FROM gcs_entry_headers geh
        WHERE geh.entry_id = pEntryId;

     l_year_to_appy_re GCS_ENTRY_HEADERS.YEAR_TO_APPLY_RE%TYPE;
     l_view_period FEM_CAL_PERIODS_ATTR.NUMBER_ASSIGN_VALUE%TYPE;

     BEGIN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <=	FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.begin', '<<Enter>>');
       END IF;

       --Bugfix 6610924: The default value of 'addWhereClause' must be blank
       addWhereClause    := ' ';
       l_year_to_appy_re := NULL;
       l_view_period     := NULL;

       OPEN period_cur(pXmlFileId, pCalPeriodYearAttr, pCalPeriodYearVersion);
         FETCH period_cur INTO l_view_period;
       CLOSE period_cur;

       OPEN year_to_apply_re_cur(pXmlFileId);
         FETCH year_to_apply_re_cur INTO l_year_to_appy_re;
       CLOSE year_to_apply_re_cur;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_year_to_appy_re : ' || l_year_to_appy_re);
         FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'l_view_period : ' || l_view_period);
       END IF;


       IF (pSourceUI = 'MANUAL' OR pSourceUI = 'ACQ_DISP' OR  pSourceUI = 'REPORTING') THEN
         IF (l_year_to_appy_re IS NULL) THEN
           addWhereClause := ' ';
           addREWhereClause := 'AND 1=2';
         ELSE
           addWhereClause := 'AND gel.line_type_code IN (''PROFIT_LOSS'',''BALANCE_SHEET'')';
           addREWhereClause := 'AND gel.line_type_code	= ''CALCULATED''';
         END IF;
       ELSIF (pSourceUI = 'CONS_MONITOR') THEN
         addREWhereClause := 'AND 1=2';
         IF (l_year_to_appy_re IS NULL) THEN
           addWhereClause := ' ';
         ELSIF (l_view_period < l_year_to_appy_re) THEN
           addWhereClause := 'AND gel.line_type_code IN(''PROFIT_LOSS'',''BALANCE_SHEET'')';
         ELSE
           addWhereClause := 'AND gel.line_type_code IN(''BALANCE_SHEET'',''CALCULATED'')';
         END IF;
       END IF;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'addWhereClause : ' || addWhereClause);
         FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name || '.' || l_api_name, 'addREWhereClause : ' || addREWhereClause);
       END IF;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.end', '<<Exit>>');
       END IF;

       RETURN(TRUE);

       EXCEPTION WHEN OTHERS THEN
         BEGIN
         -- Write appropriate error log information
         IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
           FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_pkg_name || '.' || l_api_name, SUBSTR(SQLERRM, 1, 200) || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
         END IF;
         RETURN(FALSE);
       END;
     END before_entry_report;
   --
   -- Function
   --   intercompany_report
   -- Purpose
   --   Returns where clause as per the variable values passed and
   --   are appended to the data template query
   -- Arguments
   -- Notes
   --   Added to fix bug 5861665.
   --
   FUNCTION intercompany_report RETURN BOOLEAN
   IS
     l_api_name   VARCHAR2 (30) := 'INTERCOMPANY_REPORT';
     BEGIN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <=	FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.begin', '<<Enter>>');
       END IF;

       --Checking for the value of the counter entity passed
       --If Counter Entity = -1 condition is always true
       --Else we return the condition that appends to the where clause
       IF (pCEntity = -1) THEN
           counterEntityIdLiteral := ' ';
       ELSE
           counterEntityIdLiteral := 'AND (gcerd.child_entity_id = ' || pCEntity ||
                                     ' OR gcerd.contra_child_entity_id = ' || pCEntity || ')';
       END IF;

       --Checking for the value of the Rule id passed
       --If Rule id = -1 condition is always true
       --Else we return the condition that appends to the where clause
       IF (pRule = -1) THEN
           ruleIdLiteral := ' ';
       ELSE
           ruleIdLiteral := 'AND gcerd.rule_id = ' || pRule;
       END IF;

       --Bugfix:6008841
       --Checking for the values of pTransactionType
       --If pTransactionType is 'N', return string that fetch rows with suspense_exceeded_flag = 'N' or 'X'
       --If pTransactionType is 'Y', return string that fetch rows with suspense_exceeded_flag = 'Y' or 'X'
       --Else we return the empty String
       IF (pTransactionType = 'N') THEN
           suspenseExFlagLiteral := 'AND geh.suspense_exceeded_flag IN (''N'',''X'')';
       ELSIF(pTransactionType = 'Y') THEN
           suspenseExFlagLiteral := 'AND geh.suspense_exceeded_flag IN (''X'',''Y'')';
       ELSE
           suspenseExFlagLiteral := ' ';
       END IF;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <=	FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.' || counterEntityIdLiteral, '<<Enter>>');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.' || ruleIdLiteral, '<<Enter>>');
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_pkg_name || '.' || l_api_name || '.' || suspenseExFlagLiteral, '<<Enter>>');
       END IF;

       RETURN(TRUE);

       EXCEPTION WHEN OTHERS THEN
         BEGIN
         -- Write appropriate error log information
         IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
           FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_pkg_name || '.' || l_api_name, SUBSTR(SQLERRM, 1, 200) || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
         END IF;
         RETURN(FALSE);
       END;
     END intercompany_report;

END GCS_XML_DT_UTILITY_PKG;

/
