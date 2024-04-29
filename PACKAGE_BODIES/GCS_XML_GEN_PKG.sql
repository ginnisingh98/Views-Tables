--------------------------------------------------------
--  DDL for Package Body GCS_XML_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_XML_GEN_PKG" AS
/* $Header: gcsxmlgenb.pls 120.14 2005/12/23 11:57:59 hakumar noship $ */
 new_line VARCHAR2(1) := '
';
 g_api			VARCHAR2(80)	:=	'gcs.plsql.GCS_XML_GEN_PKG';
/*
 l_ledger_vs_combo_attr	NUMBER	:=
					gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO').attribute_id;
 l_ledger_vs_combo_version	NUMBER	:=
					gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO').version_id;
 l_entity_ledger_attr         NUMBER  :=
                    gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID').attribute_id;
 l_entity_ledger_version      NUMBER  :=
                    gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID').version_id;
 l_ldg_curr_attr      NUMBER  :=
                    gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE').attribute_id;
 l_ldg_curr_version      NUMBER  :=
                    gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE').version_id;
 l_entity_srcsys_attr      NUMBER  :=
                    gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-SOURCE_SYSTEM_CODE').attribute_id;
 l_entity_srcsys_version      NUMBER  :=
                    gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-SOURCE_SYSTEM_CODE').version_id;
 l_entity_type_attr      NUMBER  :=
                    gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id;
 l_entity_type_version      NUMBER  :=
                    gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').version_id;

 PROCEDURE  append_value_set_query	( p_entity_id			IN  NUMBER,
					  p_value_set_clause		OUT NOCOPY VARCHAR2)


 IS
   TYPE r_dimension_vs_id       IS RECORD
                                (dimension_id            NUMBER(15),
                                 value_set_id            NUMBER);

   TYPE t_dimension_vs_id	IS TABLE OF 	r_dimension_vs_id;

   l_dimension_vs_id		t_dimension_vs_id;

 BEGIN

   SELECT	gvcd.dimension_id,
		    gvcd.value_set_id
   BULK COLLECT INTO
            l_dimension_vs_id
   FROM		fem_global_vs_combo_defs	gvcd,
		    fem_ledgers_attr		fla,
		    fem_entities_attr		fea,
		    fem_tab_column_prop		ftcp,
		    fem_tab_columns_b		ftcb
   WHERE	fla.ledger_id			    =	fea.dim_attribute_numeric_member
   AND		fla.attribute_id		    =	l_ledger_vs_combo_attr
   AND		fla.version_id			    =	l_ledger_vs_combo_version
   AND		fea.entity_id			    =	p_entity_id
   AND		fea.attribute_id		    =	l_entity_ledger_attr
   AND		fea.version_id			    =	l_entity_ledger_version
   AND		ftcb.table_name			    =	'FEM_BALANCES'
   AND		ftcb.dimension_id		    =	gvcd.dimension_id
   AND		ftcb.column_name		    =	ftcp.column_name
   AND		ftcb.column_name		    <>	'INTERCOMPANY_ID'
   AND		ftcp.column_property_code 	=	'PROCESSING_KEY'
   AND		ftcp.table_name			    =	ftcb.table_name
   AND		gvcd.global_vs_combo_id		=	fla.dim_attribute_numeric_member;

   FOR	l_counter	IN	l_dimension_vs_id.FIRST..l_dimension_vs_id.LAST 	LOOP

    IF (l_dimension_vs_id(l_counter).dimension_id 	=	8) THEN
  	p_value_set_clause		:=	p_value_set_clause								     ||
						' AND	 fcob.value_set_id	= '	|| l_dimension_vs_id(l_counter).value_set_id ||
					        ' AND	 fcib.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	3) THEN
	p_value_set_clause		:=	p_value_set_clause								     ||
						' AND	 fpb.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	2) THEN
	p_value_set_clause		:=	p_value_set_clause								     ||
						' AND    fnab.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	13) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
						' AND	 fchb.value_set_id	= '	|| l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	14) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
						' AND 	 flib.value_set_id	= '	|| l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	15) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND	 fpjb.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	16) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
						' AND	 fcb.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	30) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND	 ftb.value_set_id	= ' 	|| l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	19) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud1.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id	=	20) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud2.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       21) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud3.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       22) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud4.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       23) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud5.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       24) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud6.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id    =      25) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud7.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       26) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud8.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       27) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud9.value_set_id      = '     || l_dimension_vs_id(l_counter).value_set_id ;
    ELSIF (l_dimension_vs_id(l_counter).dimension_id    =       28) THEN
        p_value_set_clause              :=      p_value_set_clause                                                                   ||
        					' AND    fud10.value_set_id     = '     || l_dimension_vs_id(l_counter).value_set_id ;
    END IF;

   END LOOP;

 END;

 PROCEDURE  generate_dimension_name_xml ( p_language_code      	IN  VARCHAR2,
                                          p_fem_dim_y_n        	IN  VARCHAR2,
                                          p_xml_file_type      	IN  VARCHAR2,
                                          p_dimension_name_xml 	OUT NOCOPY CLOB )

 IS
   l_index NUMBER;

   TYPE DIM_XML_TAG_LIST IS TABLE OF VARCHAR2(200);
   L_DIM_XML_TAG_LIST DIM_XML_TAG_LIST;
   TYPE DIM_COL_NAMES_LIST IS TABLE OF VARCHAR2(200);
   L_DIM_COL_NAMES_LIST DIM_COL_NAMES_LIST;
   TYPE DIM_COL_NUM_LIST IS TABLE OF NUMBER;
   L_DIM_COL_NUM_LIST DIM_COL_NUM_LIST;

   CURSOR  c_dimension_name (p_language_code VARCHAR2)
   IS
           SELECT  '  <Name><![CDATA[' ||
                   ftcb.display_name || ']]></Name>' xml_tags,
                   DECODE(ftcb.column_name, 'COMPANY_COST_CENTER_ORG_ID', 1,
                                            'INTERCOMPANY_ID', 4,
                                            'LINE_ITEM_ID', 2,
                                             3),
                   ftcb.column_name
           FROM    fem_tab_columns_tl   ftcb,
                   fem_tab_column_prop  ftcp
           WHERE   ftcb.table_name             =   'FEM_BALANCES'
           AND     ftcb.table_name             =   ftcp.table_name
           AND     ftcb.language	             =   p_language_code
           AND     ftcb.column_name            =   ftcp.column_name
           AND     ftcp.column_property_code   = 'PROCESSING_KEY'
           AND NOT EXISTS ( SELECT  'X'
                            FROM    fem_app_grp_col_exclsns col_exclsns
                            WHERE   col_exclsns.application_group_id = 266
                            AND	    col_exclsns.table_name           = ftcb.table_name
                            AND	    col_exclsns.column_name          = ftcb.column_name)
           AND     ftcb.column_name IN ( 'CHANNEL_ID',
                                         'COMPANY_COST_CENTER_ORG_ID',
                                         'CUSTOMER_ID',
                                         'FINANCIAL_ELEM_ID',
                                         'INTERCOMPANY_ID',
                                         'LINE_ITEM_ID',
                                         'NATURAL_ACCOUNT_ID',
                                         'PRODUCT_ID',
                                         'PROJECT_ID',
                                         'TASK_ID',
                                         'USER_DIM10_ID',
                                         'USER_DIM1_ID',
                                         'USER_DIM2_ID',
                                         'USER_DIM3_ID',
                                         'USER_DIM4_ID',
                                         'USER_DIM5_ID',
                                         'USER_DIM6_ID',
                                         'USER_DIM7_ID',
                                         'USER_DIM8_ID',
                                         'USER_DIM9_ID')
           ORDER BY 2,3;

   CURSOR  c_fem_dimension_name ( p_language_code VARCHAR2 )
   IS
           SELECT  '  <Name><![CDATA[' || ftcb.display_name ||
                   ']]></Name>' xml_tags,
                   DECODE(ftcb.column_name, 'COMPANY_COST_CENTER_ORG_ID', 1,
                                            'INTERCOMPANY_ID', 4,
                                            'LINE_ITEM_ID', 2,
                                             3),
                   ftcb.column_name
           FROM    fem_tab_columns_tl          ftcb,
                   fem_tab_column_prop         ftcp
           WHERE   ftcb.table_name             =   'FEM_BALANCES'
           AND     ftcb.table_name             =   ftcp.table_name
           AND     ftcb.language		        =   p_language_code
           AND     ftcb.column_name            =   ftcp.column_name
           AND     ftcp.column_property_code   = 'PROCESSING_KEY'
           AND     ftcb.column_name            IN ( 'CHANNEL_ID',
                                                    'COMPANY_COST_CENTER_ORG_ID',
                                                    'CUSTOMER_ID',
                                                    'FINANCIAL_ELEM_ID',
                                                    'INTERCOMPANY_ID',
                                                    'LINE_ITEM_ID',
                                                    'NATURAL_ACCOUNT_ID',
                                                    'PRODUCT_ID',
                                                    'PROJECT_ID',
                                                    'TASK_ID',
                                                    'USER_DIM10_ID',
                                                    'USER_DIM1_ID',
                                                    'USER_DIM2_ID',
                                                    'USER_DIM3_ID',
                                                    'USER_DIM4_ID',
                                                    'USER_DIM5_ID',
                                                    'USER_DIM6_ID',
                                                    'USER_DIM7_ID',
                                                    'USER_DIM8_ID',
                                                    'USER_DIM9_ID')
           ORDER BY 2,3;

 BEGIN

   p_dimension_name_xml		:=	' <DimensionInfo>'|| new_line;

   IF p_fem_dim_y_n = 'Y' THEN

     OPEN c_fem_dimension_name(p_language_code);
     FETCH c_fem_dimension_name BULK COLLECT INTO L_DIM_XML_TAG_LIST, L_DIM_COL_NUM_LIST, L_DIM_COL_NAMES_LIST;
     FOR l_index IN L_DIM_XML_TAG_LIST.FIRST .. L_DIM_XML_TAG_LIST.LAST LOOP
         p_dimension_name_xml := p_dimension_name_xml || L_DIM_XML_TAG_LIST(l_index) || new_line;
     END LOOP;
     CLOSE c_fem_dimension_name;

     p_dimension_name_xml   := p_dimension_name_xml || '</DimensionInfo>' || new_line;

   ELSE

     OPEN c_dimension_name(p_language_code);
     FETCH c_dimension_name BULK COLLECT INTO L_DIM_XML_TAG_LIST, L_DIM_COL_NUM_LIST, L_DIM_COL_NAMES_LIST;
     FOR l_index IN L_DIM_XML_TAG_LIST.FIRST .. L_DIM_XML_TAG_LIST.LAST LOOP
         p_dimension_name_xml := p_dimension_name_xml || L_DIM_XML_TAG_LIST(l_index) || new_line;
     END LOOP;
     CLOSE c_dimension_name;

         p_dimension_name_xml   := p_dimension_name_xml || '</DimensionInfo>' || new_line;


   END IF;

 END generate_dimension_name_xml;


 PROCEDURE  generate_cmtb_header_xml  ( p_cmtb_header_data   IN   r_cmtb_header_data,
                                        p_cmtb_header_xml    OUT  NOCOPY CLOB )
 IS

 BEGIN

  p_cmtb_header_xml :=    ' <TB_HEADER>'       || new_line                           ||
                          '  <RUN_NAME><![CDATA['       || p_cmtb_header_data.run_name        || ']]></RUN_NAME>'      || new_line ||
                          '  <PERIOD><![CDATA['         || p_cmtb_header_data.cal_period_name || ']]></PERIOD>'        || new_line ||
                          '  <BALANCE_TYPE><![CDATA['   || p_cmtb_header_data.balance_type    || ']]></BALANCE_TYPE>'  || new_line ||
                          '  <START_TIME><![CDATA['     || p_cmtb_header_data.start_time      || ']]></START_TIME>'    || new_line ||
                          '  <END_TIME><![CDATA['       || p_cmtb_header_data.end_time        || ']]></END_TIME>'      || new_line ||
                          '  <CURRENCY_NAME><![CDATA['  || p_cmtb_header_data.currency_name   || ']]></CURRENCY_NAME>' || new_line ||
                          '  <HIERARCHY_NAME><![CDATA[' || p_cmtb_header_data.hierarchy_name  || ']]></HIERARCHY_NAME>'|| new_line ||
                          '  <HIERARCHY_ID>'            || p_cmtb_header_data.hierarchy_id    || '</HIERARCHY_ID>'     || new_line ||
                          '  <CAL_PERIOD_ID>'           || p_cmtb_header_data.cal_period_id   || '</CAL_PERIOD_ID>'    || new_line ||
                          ' </TB_HEADER>'      || new_line;

 END generate_cmtb_header_xml;

 PROCEDURE  generate_cmtb_entity_name_xml ( p_language_code        IN   VARCHAR2,
                                            p_hierarchy_id         IN   NUMBER,
                                            p_entity_id            IN   NUMBER,
                                            p_cal_period_id        IN   NUMBER,
                                            p_balance_type_code    IN   VARCHAR2,
                                            p_currency_code        IN   VARCHAR2,
                                            p_cmtb_col_xml         OUT  NOCOPY CLOB,
                                            p_cmtb_lines_xml       OUT  NOCOPY CLOB )
 IS
   TYPE entity_name_list 		IS TABLE OF VARCHAR2(450);
   EntityList entity_name_list 		:= entity_name_list();
   TYPE cmtb_line_item_list 		IS TABLE OF VARCHAR2(150);
   l_cmtb_line_item_list 		cmtb_line_item_list;
   TYPE cmtb_entity_name_list 		IS TABLE OF VARCHAR2(450);
   l_cmtb_entity_name_list 		cmtb_entity_name_list;
   TYPE cmtb_balance_list 		IS TABLE OF NUMBER;
   l_cmtb_balance_list 			cmtb_balance_list;
   TYPE cmtb_entity_type_list 		IS TABLE OF NUMBER;
   l_cmtb_entity_type_list 		cmtb_entity_type_list;
   TYPE cmtb_line_item_id_list          IS TABLE OF NUMBER;
   l_cmtb_line_item_id_list             cmtb_line_item_id_list;
   TYPE cmtb_entity_id_list             IS TABLE OF NUMBER;
   l_cmtb_entity_id_list                cmtb_entity_id_list;
   TYPE cmtb_is_drillable_list          IS TABLE OF VARCHAR2(1);
   l_cmtb_is_drillable_list             cmtb_is_drillable_list;

   l_entity_type_attr_id    		NUMBER;
   l_cal_period_attr_id     		NUMBER;
   l_entity_type_version_id 		NUMBER;
   l_cal_period_version_id		NUMBER;
   l_maxnum_entities        		NUMBER(15)      :=  0;
   l_item_list_first        		NUMBER(15);
   l_item_list_last         		NUMBER(15);
   l_item_list_current      		NUMBER(15);
   l_entity_index           		NUMBER(15);
   l_cmtb_lines_xml         		CLOB;
   l_cal_period_end_date		DATE;

   CURSOR  c_entity_name  ( p_language_code 		VARCHAR2,
                            p_hierarchy_id  		NUMBER,
                            p_entity_id     		NUMBER,
			    p_cal_period_end_date 	DATE)
   IS
           SELECT entity_name,
                  MIN(DECODE(fea.dim_attribute_varchar_member,
                                      'O', 1,
                                      'C', DECODE(fev.entity_id, gcs.parent_entity_id, 4, 2),
                                      'E', 3)) entity_type
           FROM     gcs_cons_relationships gcs,
                    fem_entities_tl fev,
                    fem_entities_attr fea
           WHERE    hierarchy_id 		= 	p_hierarchy_id
           AND      child_entity_id 		= 	fev.entity_id
           --Begin Fix#4198102
           AND      dominant_parent_flag 	= 	'Y'
	       AND	    p_cal_period_end_date	BETWEEN	gcs.start_date	AND	NVL(gcs.end_date, p_cal_period_end_date)
           --End Fix#4198102
	       AND	    fea.attribute_id		=	l_entity_type_attr_id
           AND	    fea.version_id		=	l_entity_type_version_id
           AND      fev.entity_id 		= 	fea.entity_id
           AND      fev.language  		= 	p_language_code
           AND      gcs.parent_entity_id 	= 	p_entity_id
           GROUP BY entity_name
           UNION ALL
           SELECT   entity_name, 4
           FROM     fem_entities_tl fev
           WHERE    entity_id 			= 	p_entity_id
           AND      fev.language  		= 	p_language_code
           ORDER BY entity_type, entity_name;

   CURSOR  c_tb_data  ( p_language_code 		VARCHAR2,
                         p_hierarchy_id  		NUMBER,
                         p_entity_id     		NUMBER,
                         p_cal_period_id 		NUMBER,
                         p_currency_code 		VARCHAR2,
			 p_cal_period_end_date		DATE)
   IS
           SELECT  flit.line_item_name,
                   fet.entity_name,
                   SUM (fb.ytd_balance_e) balance,
                   MIN (DECODE (fea.dim_attribute_varchar_member,
                                'O', 1,
                                'C', DECODE (fet.entity_id, geca.entity_id, 4, 2),
                                'E', 3)) entity_type,
                   flit.line_item_id,
                   fet.entity_id,
                   decode(fea.dim_attribute_varchar_member,
                          'O', decode(fli_parents.line_item_id,
                                      null, 'Y',
                                      'N'),
                          'N') is_drillable
           FROM fem_balances 		fb,
                gcs_dataset_codes 	gdc,
                fem_ln_items_tl 	flit,
                (select flib.line_item_id
                 from fem_ln_items_b flib
                 where exists
                 (select 1
                  from fem_ln_items_hier flih,
                       gcs_system_options gso,
                       fem_object_definition_b odb,
                       fem_global_vs_combo_defs gvscd
                  where odb.object_id = gso.ln_item_hierarchy_obj_id
                  and p_cal_period_end_date BETWEEN odb.effective_start_date and odb.effective_end_date
                  and gvscd.global_vs_combo_id = gso.fch_global_vs_combo_id
                  and gvscd.dimension_id = 14
                  and flih.hierarchy_obj_def_id = odb.object_definition_id
                  and flih.parent_id = flib.line_item_id
                  and flih.child_id <> flih.parent_id
                  and flih.parent_value_set_id = gvscd.value_set_id
                  and flih.child_value_set_id = gvscd.value_set_id
                 )
                ) fli_parents,
                gcs_entity_cons_attrs 	geca,
                fem_entities_tl 	fet,
                fem_entities_attr 	fea
          WHERE fb.source_system_code 		= 	70
          AND   fb.dataset_code 		= 	gdc.dataset_code
          AND   gdc.balance_type_code 		= 	p_balance_type_code
          AND   fb.line_item_id 		= 	flit.line_item_id
          AND   flit.language 			= 	p_language_code
          AND   geca.hierarchy_id 		= 	p_hierarchy_id
          AND   geca.hierarchy_id 		= 	gdc.hierarchy_id
          AND   fb.currency_code 		= 	p_currency_code
          AND   fb.currency_code 		= 	geca.currency_code
          AND   geca.entity_id 			= 	p_entity_id
          AND   fb.cal_period_id 		= 	p_cal_period_id
          AND   fb.entity_id 			= 	fet.entity_id
          AND   fet.language 			= 	p_language_code
          AND   fb.entity_id 			= 	fea.entity_id
          AND   fea.attribute_id 		= 	l_entity_type_attr_id
          AND	fea.version_id			=	l_entity_type_version_id
          AND   ( fb.entity_id = geca.entity_id
                  OR
                  EXISTS ( SELECT 1
                                  FROM   gcs_cons_relationships gcr
                                  WHERE  gcr.parent_entity_id 		= 	geca.entity_id
                                  AND    gcr.hierarchy_id 		=  	geca.hierarchy_id
				  AND	 gcr.dominant_parent_flag	=	'Y'
				  AND	 p_cal_period_end_date	BETWEEN	gcr.start_date	AND NVL(gcr.end_date, p_cal_period_end_date)
                                  AND    gcr.child_entity_id 		= 	fb.entity_id)
                )
          AND fli_parents.line_item_id (+)= flit.line_item_id
          GROUP BY fet.entity_name, flit.line_item_name,
                   fet.entity_id, flit.line_item_id,
                   fea.dim_attribute_varchar_member, fli_parents.line_item_id
          ORDER BY line_item_name, entity_type, entity_name;

 BEGIN
   l_entity_type_attr_id 	:= 	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id;
   l_cal_period_attr_id 	:= 	gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id;
   l_entity_type_version_id	:=	gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE').version_id;
   l_cal_period_version_id	:=	gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;

   SELECT	date_assign_value
   INTO		l_cal_period_end_date
   FROM		fem_cal_periods_attr
   WHERE	cal_period_id	=	p_cal_period_id
   AND		attribute_id	=	l_cal_period_attr_id
   AND		version_id	=	l_cal_period_version_id;

   p_cmtb_col_xml		:=	' <TB_COL_DATA>'  ||  new_line;
   FOR v_entity_name IN c_entity_name(	p_language_code,
					p_hierarchy_id,
					p_entity_id,
					l_cal_period_end_date)
   LOOP
     p_cmtb_col_xml	:=	p_cmtb_col_xml                 ||
                                '  <DimensionInfo><COL_NAME><![CDATA[' ||
                                v_entity_name.entity_name      ||
                                ']]></COL_NAME></DimensionInfo>' ||  new_line;
     EntityList.EXTEND;
     l_maxnum_entities :=  l_maxnum_entities + 1;
     EntityList(l_maxnum_entities) :=  v_entity_name.entity_name;
   END LOOP;

   --fnd_file.put_line(fnd_file.log, 'Begin CMTB XML generation');
   IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
   THEN
        fnd_log.STRING
             (fnd_log.level_statement,
              g_api, 'Begin CMTB XML generation'
             );
   END IF;

   p_cmtb_col_xml       :=  p_cmtb_col_xml   ||
                            '</TB_COL_DATA>' || new_line;
   -- Create a temporary CLOB to hold XML (because it may be of size > 32767 bytes)
   DBMS_LOB.CREATETEMPORARY(l_cmtb_lines_xml, TRUE);
   DBMS_LOB.WRITEAPPEND(l_cmtb_lines_xml ,
                            length('  <TB_LINES_DATA><TB_LINE_ROWS>'),
							'  <TB_LINES_DATA><TB_LINE_ROWS>');
   --fnd_file.put_line(fnd_file.log, 'Collect Data');
   IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
   THEN
        fnd_log.STRING
             (fnd_log.level_statement,
              g_api, 'Collect Data'
             );
   END IF;
   OPEN c_tb_data(	p_language_code,
			p_hierarchy_id,
			p_entity_id,
			p_cal_period_id,
			p_currency_code,
			l_cal_period_end_date);
   FETCH c_tb_data
   BULK COLLECT INTO
	l_cmtb_line_item_list,
	l_cmtb_entity_name_list,
	l_cmtb_balance_list,
	l_cmtb_entity_type_list,
        l_cmtb_line_item_id_list,
        l_cmtb_entity_id_list,
        l_cmtb_is_drillable_list;
   CLOSE c_tb_data;

   --fnd_file.put_line(fnd_file.log, 'End of Data Collection');
   IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
   THEN
        fnd_log.STRING
             (fnd_log.level_statement,
              g_api, 'End of Data Collection'
             );
   END IF;
   l_item_list_first := l_cmtb_line_item_list.FIRST;
   l_item_list_last := l_cmtb_line_item_list.LAST;
   l_item_list_current := 1;
   l_entity_index := EntityList.FIRST;
    -- Evaluate all the reported entities
	LOOP
      --And check for balance availability against each reported line item
	  LOOP
         --fnd_file.put_line(fnd_file.log, 'Processing Entity : ' || EntityList(l_entity_index));
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
             fnd_log.STRING
                   (fnd_log.level_statement,
                    g_api, 'Processing Entity : ' || EntityList(l_entity_index)
                   );
         END IF;
         --fnd_file.put_line(fnd_file.log, 'for line item : ' || l_cmtb_line_item_list(l_item_list_current));
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
             fnd_log.STRING
                   (fnd_log.level_statement,
                    g_api, 'for line item : ' || l_cmtb_line_item_list(l_item_list_current)
                   );
         END IF;
         --If the line item list contains reported entiry, then generate not for the actual balance
         IF EntityList(l_entity_index) = l_cmtb_entity_name_list(l_item_list_current) THEN
         BEGIN
           --fnd_file.put_line(fnd_file.log, 'Processing Entity (with balance): ' ||
		       --                            l_cmtb_entity_name_list(l_item_list_current));
           IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
           THEN
               fnd_log.STRING
                     (fnd_log.level_statement,
                      g_api, 'Processing Entity (with balance): ' ||
					                        l_cmtb_entity_name_list(l_item_list_current)
                     );
           END IF;
		   DBMS_LOB.WRITEAPPEND(l_cmtb_lines_xml,
		                                        length('<TB_LINE><LINE_ITEM_NAME><![CDATA['   ||
                                                l_cmtb_line_item_list(l_item_list_current)||
                                                ']]></LINE_ITEM_NAME>'      || new_line ||
                                                '    <ENTITY_NAME><![CDATA['      ||
                                                l_cmtb_entity_name_list(l_item_list_current)||
                                                ']]></ENTITY_NAME>'         || new_line ||
                                                '    <LINE_ITEM_ID>'      ||
                                                l_cmtb_line_item_id_list(l_item_list_current)||
                                                '</LINE_ITEM_ID>'         || new_line ||
                                                '    <ENTITY_ID>'      ||
                                                l_cmtb_entity_id_list(l_item_list_current)||
                                                '</ENTITY_ID>'         || new_line ||
                                                '    <IS_DRILLABLE><![CDATA['      ||
                                                l_cmtb_is_drillable_list(l_item_list_current)||
                                                ']]></IS_DRILLABLE>'         || new_line ||
                                                '    <BALANCE>'          ||
                                                l_cmtb_balance_list(l_item_list_current)||
                                                '</BALANCE></TB_LINE>'             || new_line),

                                                '<TB_LINE><LINE_ITEM_NAME><![CDATA['   ||
                                                l_cmtb_line_item_list(l_item_list_current)||
                                                ']]></LINE_ITEM_NAME>'      || new_line ||
                                                '    <ENTITY_NAME><![CDATA['      ||
                                                l_cmtb_entity_name_list(l_item_list_current)||
                                                ']]></ENTITY_NAME>'         || new_line ||
                                                '    <LINE_ITEM_ID>'      ||
                                                l_cmtb_line_item_id_list(l_item_list_current)||
                                                '</LINE_ITEM_ID>'         || new_line ||
                                                '    <ENTITY_ID>'      ||
                                                l_cmtb_entity_id_list(l_item_list_current)||
                                                '</ENTITY_ID>'         || new_line ||
                                                '    <IS_DRILLABLE><![CDATA['      ||
                                                l_cmtb_is_drillable_list(l_item_list_current)||
                                                ']]></IS_DRILLABLE>'         || new_line ||
                                                '    <BALANCE>'          ||
                                                l_cmtb_balance_list(l_item_list_current)||
                                                '</BALANCE></TB_LINE>'             || new_line);

           IF l_entity_index <= l_maxnum_entities THEN
              l_item_list_current := l_item_list_current + 1;
           END IF;
         END;

         ELSE

         BEGIN
           --fnd_file.put_line(fnd_file.log, 'Processing Entity (without balance): ' ||
		       --                            EntityList(l_entity_index));
           IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
           THEN
               fnd_log.STRING
                     (fnd_log.level_statement,
                      g_api, 'Processing Entity (without balance): ' ||
					                        EntityList(l_entity_index)
                     );
           END IF;
		   DBMS_LOB.WRITEAPPEND(l_cmtb_lines_xml,
		                                        length('<TB_LINE><LINE_ITEM_NAME><![CDATA['   ||
                                                l_cmtb_line_item_list(l_item_list_current)||
                                                ']]></LINE_ITEM_NAME>'      || new_line ||
                                                '    <ENTITY_NAME><![CDATA['      ||
                                                EntityList(l_entity_index)||
                                                ']]></ENTITY_NAME>'         || new_line ||
                                                '    <LINE_ITEM_ID>'      ||
                                                l_cmtb_line_item_id_list(l_item_list_current)||
                                                '</LINE_ITEM_ID>'         || new_line ||
                                                '    <ENTITY_ID>'      ||
                                                l_cmtb_entity_id_list(l_item_list_current)||
                                                '</ENTITY_ID>'         || new_line ||
                                                '    <IS_DRILLABLE><![CDATA['      ||
                                                'N'||
                                                ']]></IS_DRILLABLE>'         || new_line ||
                                                '    <BALANCE>'          ||
                                                '</BALANCE></TB_LINE>'             || new_line),

                                                '<TB_LINE><LINE_ITEM_NAME><![CDATA['   ||
                                                l_cmtb_line_item_list(l_item_list_current)||
                                                ']]></LINE_ITEM_NAME>'      || new_line ||
                                                '    <ENTITY_NAME><![CDATA['      ||
                                                EntityList(l_entity_index)||
                                                ']]></ENTITY_NAME>'         || new_line ||
                                                '    <LINE_ITEM_ID>'      ||
                                                l_cmtb_line_item_id_list(l_item_list_current)||
                                                '</LINE_ITEM_ID>'         || new_line ||
                                                '    <ENTITY_ID>'      ||
                                                l_cmtb_entity_id_list(l_item_list_current)||
                                                '</ENTITY_ID>'         || new_line ||
                                                '    <IS_DRILLABLE><![CDATA['      ||
                                                'N'||
                                                ']]></IS_DRILLABLE>'         || new_line ||
                                                '    <BALANCE>'          ||
                                                '</BALANCE></TB_LINE>'             || new_line);

           --fnd_file.put_line(fnd_file.log, 'Line item context: '||l_item_list_current ||length(p_cmtb_lines_xml));
           IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
           THEN
               fnd_log.STRING
                     (fnd_log.level_statement,
                      g_api, 'Line item context: '||l_item_list_current ||length(p_cmtb_lines_xml)
                     );
           END IF;
         END;
         END IF;
         IF l_entity_index = l_maxnum_entities THEN
               --fnd_file.put_line(fnd_file.log, 'Exit inner loop when: l_entity_index('||l_entity_index||
			         --                ') = l_maxnum_entities('||l_maxnum_entities||')');
               IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
               THEN
                   fnd_log.STRING
                         (fnd_log.level_statement,
                          g_api, 'Exit inner loop when: l_entity_index('||l_entity_index||
			                         ') = l_maxnum_entities('||l_maxnum_entities||')'
                         );
               END IF;
               EXIT;
         END IF;
         l_entity_index := l_entity_index + 1;
      END LOOP;

      IF l_item_list_current > l_item_list_last THEN
         --fnd_file.put_line(fnd_file.log, 'Exit outer loop when: l_item_list_current('||l_item_list_current||
  	     --                    ') = l_item_list_last('||l_item_list_last||')');
         IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
         THEN
             fnd_log.STRING
                   (fnd_log.level_statement,
                    g_api, 'Exit outer loop when: l_item_list_current('||l_item_list_current||
  	                         ') = l_item_list_last('||l_item_list_last||')'
                    );
         END IF;
         DBMS_LOB.WRITEAPPEND(l_cmtb_lines_xml, length('</TB_LINE_ROWS></TB_LINES_DATA>' || new_line),
                                   '</TB_LINE_ROWS></TB_LINES_DATA>' || new_line);

         EXIT;
      ELSIF l_entity_index = l_maxnum_entities THEN
               --fnd_file.put_line(fnd_file.log, 'Reset entity context when: l_entity_index('||l_entity_index||
  	           --                                  ') = l_maxnum_entities('||l_maxnum_entities||')');
               IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
               THEN
                   fnd_log.STRING
                         (fnd_log.level_statement,
                          g_api, 'Reset entity context when: l_entity_index('||l_entity_index||
  	                                             ') = l_maxnum_entities('||l_maxnum_entities||')'
                         );
               END IF;
               l_entity_index := EntityList.FIRST;
               DBMS_LOB.WRITEAPPEND(l_cmtb_lines_xml, length('</TB_LINE_ROWS><TB_LINE_ROWS>'),
			                        '</TB_LINE_ROWS><TB_LINE_ROWS>');
	  END IF;

   END LOOP;
   p_cmtb_lines_xml := l_cmtb_lines_xml;

 END generate_cmtb_entity_name_xml;

 PROCEDURE  generate_cmtb_xml ( p_entry_id          IN  NUMBER,
                                p_entity_id         IN	NUMBER,
                                p_hierarchy_id      IN  NUMBER,
                                p_cal_period_id     IN  NUMBER,
                                p_balance_type_code IN  VARCHAR2,
                                p_currency_code     IN  VARCHAR2)
 IS

   l_cmtb_header_data	r_cmtb_header_data;
   l_cmtb_header_xml	CLOB;
   l_cmtb_col_xml     CLOB;
   l_cmtb_lines_xml   CLOB;
   l_cmtb_xml         CLOB;
   file_exist         NUMBER;
   p_xml_file_type    VARCHAR2(10) := 'CMTB';
   doc_in                   xmldom.DOMDocument;
   retval                   xmldom.domnodelist;
   prsr                     xmlparser.parser;
   l_node                   xmldom.domnode;

   CURSOR    c_languages
   IS
       SELECT  language_code
       FROM     fnd_languages
       WHERE  installed_flag IN ('I','B');

   CURSOR	  c_xml_id ( p_language_code VARCHAR2,
                             p_entry_id     NUMBER )
   IS
       SELECT 1
       FROM   gcs_xml_files
       WHERE  XML_FILE_ID = p_entry_id
       AND    XML_FILE_TYPE = p_xml_file_type
       AND    LANGUAGE = p_language_code;

 BEGIN

   FOR 	v_languages	IN	c_languages
   LOOP
   BEGIN
   -- Get the Entity Header Info for the entry_id
       SELECT gcer.run_name,
              fcpt.cal_period_name,
              flv.meaning balance_type,
              gcer.start_time,
              gcer.end_time,
              fct.name currency_name,
			  ght.hierarchy_name,
              ght.hierarchy_id,
              fcpt.cal_period_id
       INTO   l_cmtb_header_data.run_name,
              l_cmtb_header_data.cal_period_name,
              l_cmtb_header_data.balance_type,
              l_cmtb_header_data.start_time,
              l_cmtb_header_data.end_time,
              l_cmtb_header_data.currency_name,
              l_cmtb_header_data.hierarchy_name,
              l_cmtb_header_data.hierarchy_id,
              l_cmtb_header_data.cal_period_id
       FROM   gcs_cons_eng_runs gcer,
              gcs_hierarchies_tl ght,
              fem_cal_periods_tl fcpt,
              fnd_currencies_tl fct,
              fnd_lookup_values flv
       WHERE  gcer.cal_period_id = fcpt.cal_period_id
       AND    fct.currency_code = p_currency_code
       AND    fct.language = v_languages.language_code
       AND    gcer.balance_type_code = flv.lookup_code
       AND    flv.lookup_type = 'BALANCE_TYPE_CODE'
       AND    flv.language = v_languages.language_code
       AND    fcpt.language = v_languages.language_code
       AND    gcer.hierarchy_id = p_hierarchy_id
       AND    gcer.hierarchy_id = ght.hierarchy_id
       AND    ght.language = v_languages.language_code
       AND    gcer.RUN_ENTITY_ID = p_entity_id
       AND    gcer.BALANCE_TYPE_CODE = p_balance_type_code
       AND    gcer.CAL_PERIOD_ID = p_cal_period_id
       AND    gcer.MOST_RECENT_FLAG = 'Y'
       AND    rownum <= 1;

       --fnd_file.put_line(fnd_file.log, 'Start CMTB XML for entry_id: ' || p_entry_id);
       IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
       THEN
            fnd_log.STRING
               (fnd_log.level_statement,
                g_api, 'Start CMTB XML for entry_id: '||p_entry_id
                );
        END IF;

       -- Generate the header level XML
       generate_cmtb_header_xml ( p_cmtb_header_data => l_cmtb_header_data,
                                  p_cmtb_header_xml  => l_cmtb_header_xml);

       -- Generate the entity name XML
       generate_cmtb_entity_name_xml ( p_language_code     => v_languages.language_code,
                                       p_hierarchy_id      => p_hierarchy_id,
                                       p_entity_id         => p_entity_id,
                                       p_cal_period_id     => p_cal_period_id,
                                       p_balance_type_code => p_balance_type_code,
                                       p_currency_code     => p_currency_code,
                                       p_cmtb_col_xml	   => l_cmtb_col_xml,
                                       p_cmtb_lines_xml    => l_cmtb_lines_xml);

       l_cmtb_xml := '<CMTB_DATA>' || l_cmtb_header_xml || l_cmtb_col_xml || l_cmtb_lines_xml ||'</CMTB_DATA>';

       OPEN c_xml_id(v_languages.language_code, p_entry_id);
       FETCH c_xml_id INTO file_exist;
       IF c_xml_id%NOTFOUND THEN
          insert into gcs_xml_files ( xml_file_id,
                                      xml_file_type,
                                      language,
                                      xml_data,
                                      last_update_date,
                                      last_updated_by,
                                      creation_date,
                                      created_by,
                                      object_version_number)
           values
                                    ( p_entry_id,
                                      p_xml_file_type,
                                      v_languages.language_code,
                                      '<?xml version="1.0"?>'||new_line||l_cmtb_xml,
                                      sysdate,
                                      0,
                                      sysdate,
                                      0,
                                      0);
           CLOSE c_xml_id;

            --fnd_file.put_line(fnd_file.log, 'Inserted CMTB XML for entry_id: ' || p_entry_id);
            IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
            THEN
                fnd_log.STRING
                   (fnd_log.level_statement,
                     g_api, 'Inserted CMTB XML for entry_id: '||p_entry_id
                   );
            END IF;

       ELSE
          update gcs_xml_files
          set    xml_data              = '<?xml version="1.0"?>'||new_line||l_cmtb_xml,
                 last_update_date      = sysdate,
                 last_updated_by       = 0,
                 object_version_number = object_version_number + 1
          where  xml_file_id = p_entry_id
          and    xml_file_type = p_xml_file_type
          and    language = v_languages.language_code;

          CLOSE c_xml_id;

          --fnd_file.put_line(fnd_file.log, 'Updated CMTB XML for entry_id: ' || p_entry_id);
          IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
          THEN
                fnd_log.STRING
                   (fnd_log.level_statement,
                     g_api, 'Updated CMTB XML for entry_id: '||p_entry_id
                   );
          END IF;

       END IF;
       COMMIT;


       EXCEPTION
             WHEN others THEN
             BEGIN
                --fnd_file.put_line(fnd_file.log, 'Exception CMTB XML for entry_id: ' || p_entry_id||' - ' || SQLERRM);
                IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
                THEN
                   fnd_log.STRING
                     (fnd_log.level_statement,
                      g_api, 'Exception CMTB XML for entry_id: '||p_entry_id ||' - '||SQLERRM
                     );
                END IF;
             END;
   END;
   END LOOP;
 END generate_cmtb_xml;


 PROCEDURE  generate_entry_header_xml ( p_entry_header_data  IN	  r_entry_header_data,
 			                p_entry_header_xml   OUT  NOCOPY CLOB )

 IS

 BEGIN

  p_entry_header_xml	:= ' <ENTRY_HEADER>'    || new_line ||
                           '  <ENTRY_NAME><![CDATA['     || p_entry_header_data.entry_name     || ']]></ENTRY_NAME>'    || new_line ||
                           '  <DESCRIPTION><![CDATA['    || p_entry_header_data.description    || ']]></DESCRIPTION>'   || new_line ||
                           '  <HIERARCHY_NAME><![CDATA[' || p_entry_header_data.hierarchy_name || ']]></HIERARCHY_NAME>'|| new_line ||
                           '  <ENTITY_NAME><![CDATA['    || p_entry_header_data.entity_name    || ']]></ENTITY_NAME>'   || new_line ||
                           '  <CURRENCY_NAME><![CDATA['  || p_entry_header_data.currency_name  || ']]></CURRENCY_NAME>' || new_line ||
                           '  <CAL_PERIOD_NAME><![CDATA['|| p_entry_header_data.cal_period_name||']]></CAL_PERIOD_NAME>'|| new_line ||
                           '  <SUSPENSE_FLAG><![CDATA['  || p_entry_header_data.suspense_flag  || ']]></SUSPENSE_FLAG>' || new_line ||
                           '  <HIERARCHY_ID>'            || p_entry_header_data.hierarchy_id   || '</HIERARCHY_ID>'     || new_line ||
                           '  <ENTITY_ID>'               || p_entry_header_data.entity_id      || '</ENTITY_ID>'        || new_line ||
                           '  <CAL_PERIOD_ID>'           || p_entry_header_data.cal_period_id  || '</CAL_PERIOD_ID>'    || new_line ||
                           '  <IS_DRILLABLE><![CDATA[';

  --Bugfix 4725916: Modifed is drillable to check the category code rather than the entity type
  IF p_entry_header_data.category_code IN ('DATAPREPARATION', 'INTRACOMPANY', 'TRANSLATION', 'INTERCOMPANY') THEN
   p_entry_header_xml := p_entry_header_xml || 'Y';
  ELSE
   p_entry_header_xml := p_entry_header_xml || 'N';
  END IF;

  p_entry_header_xml := p_entry_header_xml || ']]></IS_DRILLABLE>'  || new_line ||
                           ' </ENTRY_HEADER>'    ||  new_line;

 END generate_entry_header_xml;


 PROCEDURE  generate_entry_xml ( p_entry_id       IN NUMBER,
                                 p_category_code  IN VARCHAR2,
                                 p_cons_rule_flag IN VARCHAR2 )
 IS
   l_entry_header_data      r_entry_header_data;
   l_entry_header_xml	    CLOB;
   l_dimension_name_xml	    CLOB;
   l_entry_lines_xml        CLOB;
   l_entry_xml              CLOB;
   l_entry_lines_sql        VARCHAR2(10000);
   l_rp_lines_xml           CLOB;
   l_rp_lines_sql           VARCHAR2(10000);
   l_qryCtx                 DBMS_XMLGEN.ctxHandle;
   file_exist               NUMBER;
   doc_in                   xmldom.DOMDocument;
   retval                   xmldom.domnodelist;
   prsr                     xmlparser.parser;
   l_node                   xmldom.domnode;
   doc_in1                  xmldom.DOMDocument;
   retval1                  xmldom.domnodelist;
   prsr1                    xmlparser.parser;
   l_node1                  xmldom.domnode;
   p_xml_file_type          VARCHAR2(10) := 'ENTRY';
   CURSOR	c_languages
   IS
     SELECT 	language_code
     FROM	fnd_languages
     WHERE	installed_flag IN ('I','B');

   CURSOR	c_xml_id ( p_language_code VARCHAR2,
                     p_entry_id      NUMBER )
   IS
     SELECT 1
     FROM   gcs_xml_files
     WHERE  xml_file_id = p_entry_id
     AND    xml_file_type = p_xml_file_type
     AND    language = p_language_code;

 BEGIN

   --fnd_file.put_line(fnd_file.log, 'Enter: gcs_xml_gen_pkg.generate_entry_xml(p_entry_id =>'||p_entry_id||
   --            ', p_category_code =>'||p_category_code||', p_cons_rule_flag =>' || p_cons_rule_flag ||' )');
   IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
   THEN
       fnd_log.STRING
           (fnd_log.level_statement,
            g_api,
               'Enter: gcs_xml_gen_pkg.generate_entry_xml(p_entry_id =>'||p_entry_id||
               ', p_category_code =>'||p_category_code||', p_cons_rule_flag =>' || p_cons_rule_flag ||' )'
           );
   END IF;

   FOR 	v_languages	IN	c_languages
   LOOP
   BEGIN
   -- Get the Entry Header Info for the entry_id
     SELECT geh.entry_name,
            geh.description,
            ghtl.hierarchy_name,
   	    fetl.entity_name,
   	    fctl.name currency_name,
   	    fcptl_start.cal_period_name,
  	    geh.suspense_exceeded_flag,
 	    geh.rule_id,
            geh.entity_id,
            geh.hierarchy_id,
            geh.start_cal_period_id,
            geh.balance_type_code,
            geh.currency_code,
            fea_type.dim_attribute_varchar_member,
	    geh.category_code
     INTO   l_entry_header_data.entry_name,
   	    l_entry_header_data.description,
   	    l_entry_header_data.hierarchy_name,
   	    l_entry_header_data.entity_name,
   	    l_entry_header_data.currency_name,
   	    l_entry_header_data.cal_period_name,
            l_entry_header_data.suspense_flag,
   	    l_entry_header_data.rule_id,
            l_entry_header_data.entity_id,
            l_entry_header_data.hierarchy_id,
            l_entry_header_data.cal_period_id,
            l_entry_header_data.balance_type_code,
            l_entry_header_data.currency_code,
            l_entry_header_data.entity_type_code,
	    l_entry_header_data.category_code
     FROM   gcs_entry_headers 		geh,
   	    gcs_hierarchies_tl 		ghtl,
   	    fem_entities_tl		fetl,
   	    fnd_currencies_tl		fctl,
   	    fem_cal_periods_tl		fcptl_start,
   	    fem_cal_periods_tl		fcptl_end,
	    fem_entities_attr 		fea_type
     WHERE	geh.entry_id		=	p_entry_id
     AND	geh.hierarchy_id	=	ghtl.hierarchy_id
     AND	ghtl.language		=	v_languages.language_code
     AND	geh.entity_id		=	fetl.entity_id
     AND	fctl.language		=	v_languages.language_code
     AND	geh.currency_code	=	fctl.currency_code
     AND	fetl.language		=	v_languages.language_code
     AND	geh.start_cal_period_id	=	fcptl_start.cal_period_id
     AND	fcptl_start.language	=	v_languages.language_code
     AND	geh.end_cal_period_id	=	fcptl_end.cal_period_id(+)
     AND	fcptl_end.language(+)	=	v_languages.language_code
     AND	fea_type.entity_id	=	geh.entity_id
     AND	fea_type.attribute_id	=	l_entity_type_attr
     AND	fea_type.version_id	=	l_entity_type_version
     AND    ROWNUM                  <=      1;
     --fnd_file.put_line(fnd_file.log, ' Start Header XML generation ');
     IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
     THEN
       fnd_log.STRING
           (fnd_log.level_statement,
            g_api, ' Select statement results: '||
            'l_entry_header_data.entry_name =>'||l_entry_header_data.entry_name||
   		    'l_entry_header_data.description =>'||l_entry_header_data.description||
   		    'l_entry_header_data.hierarchy_name =>'||l_entry_header_data.hierarchy_name||
   		    'l_entry_header_data.entity_name =>'||l_entry_header_data.entity_name||
   		    'l_entry_header_data.currency_name =>'||l_entry_header_data.currency_name||
   		    'l_entry_header_data.cal_period_name =>'||l_entry_header_data.cal_period_name||
   		    'l_entry_header_data.suspense_flag =>'||l_entry_header_data.suspense_flag||
   		    'l_entry_header_data.rule_id =>'||l_entry_header_data.rule_id||
            'l_entry_header_data.entity_id =>'||l_entry_header_data.entity_id||
            'l_entry_header_data.hierarchy_id =>'||l_entry_header_data.hierarchy_id||
            'l_entry_header_data.cal_period_id =>'||l_entry_header_data.cal_period_id||
            'l_entry_header_data.balance_type_code =>'||l_entry_header_data.balance_type_code||
            'l_entry_header_data.currency_code =>'||l_entry_header_data.currency_code
           );
     END IF;

    -- Generate the header level XML
    generate_entry_header_xml( p_entry_header_data => l_entry_header_data,
                               p_entry_header_xml  => l_entry_header_xml );

    --fnd_file.put_line(fnd_file.log, ' Generated Header XML Successfully ');
    IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
    THEN
        fnd_log.STRING
            (fnd_log.level_statement,
             g_api, ' Generated Header XML Successfully '
            );
    END IF;

    IF (p_category_code <> 'AGGREGATION') THEN

        --fnd_file.put_line(fnd_file.log, 'Start: generate_dimension_name_xml ( p_language_code	   => '||
		    --                                           v_languages.language_code||
        --                                               'p_fem_dim_y_n        => N'||
        --                                               'p_xml_file_type      => ENTRY'||
        --                                               'p_dimension_name_xml => ');
        IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
        THEN
           fnd_log.STRING
             (fnd_log.level_statement,
              g_api, 'Start: generate_dimension_name_xml ( p_language_code	   => '||v_languages.language_code||
                                                       'p_fem_dim_y_n        => N'||
                                                       'p_xml_file_type      => ENTRY'||
                                                       'p_dimension_name_xml => '
             );
        END IF;
        -- Generate the dimension name XML
        generate_dimension_name_xml ( p_language_code	   => v_languages.language_code,
                                      p_fem_dim_y_n        => 'N',
                                      p_xml_file_type      => 'ENTRY',
                                      p_dimension_name_xml => l_dimension_name_xml );

        --fnd_file.put_line(fnd_file.log, 'End: generate_dimension_name_xml ( p_language_code	   => '||
		    --                                           v_languages.language_code||
        --                                               'p_fem_dim_y_n        => N'||
        --                                               'p_xml_file_type      => ENTRY'||
        --                                               'p_dimension_name_xml => ');
        IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
        THEN
          fnd_log.STRING
              (fnd_log.level_statement,
               g_api, 'End: generate_dimension_name_xml ( p_language_code	   => '||v_languages.language_code||
                                                       'p_fem_dim_y_n        => N'||
                                                       'p_xml_file_type      => ENTRY'||
                                                       'p_dimension_name_xml => '
              );
        END IF;
        -- take the sql query from gcs_xml_utility_pkg.g_entry_lines_select_stmnt
        -- add the clause for gel.entry_id and lang.language_code

        l_entry_lines_sql:= gcs_xml_utility_pkg.g_entry_lines_select_stmnt||
                            ' and lang.language_code = '''||
                            v_languages.language_code||
                            ''' and gel.entry_id = '||
                            p_entry_id|| ' ORDER BY ' ||
                            gcs_xml_utility_pkg.g_order_by_stmnt;

        --fnd_file.put_line(fnd_file.log, 'l_entry_lines_sql ' || l_entry_lines_sql);
        IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
        THEN
          fnd_log.STRING
            (fnd_log.level_statement,
             g_api, 'l_entry_lines_sql '||l_entry_lines_sql
           );
        END IF;
        -- Generate new query context and set desired Row Set and Row Tag and
        -- generate XML data
        l_qryCtx := DBMS_XMLGEN.newContext(l_entry_lines_sql);
        DBMS_XMLGEN.setRowSetTag(l_qryCtx,'ENTRY_LINES');
        DBMS_XMLGEN.setRowTag(l_qryCtx,'ENTRY_LINES_ROW');
        DBMS_XMLGEN.setConvertSpecialChars(l_qryCtx,FALSE);
        l_entry_lines_xml := DBMS_XMLGEN.getXML(l_qryCtx);

        -- Remove xml version header tag from XML data
        IF (l_entry_lines_xml IS NOT NULL) THEN
           prsr := xmlparser.newparser;
           xmlparser.parseclob (prsr, l_entry_lines_xml);
           doc_in := xmlparser.getdocument (prsr);
           xmlparser.freeparser (prsr);
           retval := xslprocessor.selectnodes (xmldom.makenode( doc_in), 'ENTRY_LINES' );
           l_node := xmldom.item(retval , 0);
           xmldom.writetoclob(l_node, l_entry_lines_xml);
        END IF;
        l_entry_xml := '<ENTRY_DATA> '|| new_line ||
                                l_entry_header_xml|| l_dimension_name_xml|| l_entry_lines_xml||
                                '</ENTRY_DATA> ';

        --fnd_file.put_line(fnd_file.log, 'Entry XML generated for entry id: ' || p_entry_id);
        IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
        THEN
          fnd_log.STRING
            (fnd_log.level_statement,
             g_api, 'Entry XML generated for entry id: '||p_entry_id
           );
        END IF;

    ELSE

        generate_cmtb_xml ( p_entry_id          => p_entry_id,
		                    p_entity_id         => l_entry_header_data.entity_id,
                            p_hierarchy_id      => l_entry_header_data.hierarchy_id,
                            p_cal_period_id     => l_entry_header_data.cal_period_id,
                            p_balance_type_code => l_entry_header_data.balance_type_code,
                            p_currency_code     => l_entry_header_data.currency_code);

    END IF;

    IF (p_cons_rule_flag = 'Y') THEN

        l_rp_lines_sql:= gcs_xml_utility_pkg.g_rp_select_stmnt||
                         ' and lang.language_code = '''||
                         v_languages.language_code||
                         ''' and gel.rule_id = '||
                         l_entry_header_data.rule_id|| ' ORDER BY ' ||
                         gcs_xml_utility_pkg.g_order_by_stmnt||
                         gcs_xml_utility_pkg.g_order_by_stmnt1;

        -- Generate new query context and set desired Row Set and Row Tag and
        -- generate XML data
        l_qryCtx := DBMS_XMLGEN.newContext(l_rp_lines_sql);
        DBMS_XMLGEN.setRowSetTag(l_qryCtx,'RP_LINES');
        DBMS_XMLGEN.setRowTag(l_qryCtx,'RP_LINES_ROW');
        l_rp_lines_xml := DBMS_XMLGEN.getXML(l_qryCtx);

        -- Remove xml version header tag from XML data
        IF (l_rp_lines_xml IS NOT NULL) THEN
           prsr := xmlparser.newparser;
           xmlparser.parseclob (prsr, l_rp_lines_xml);
           doc_in := xmlparser.getdocument (prsr);
           xmlparser.freeparser (prsr);
           retval := xslprocessor.selectnodes (xmldom.makenode( doc_in), 'RP_LINES' );
           l_node := xmldom.item(retval , 0);
           xmldom.writetoclob(l_node, l_rp_lines_xml);
        END IF;
    END IF;

    IF (p_category_code <> 'AGGREGATION') THEN

    OPEN c_xml_id(v_languages.language_code, p_entry_id);
    FETCH c_xml_id INTO file_exist;
    IF c_xml_id%NOTFOUND THEN
            insert into gcs_xml_files
                              ( xml_file_id,
                                xml_file_type,
                                language,
                                xml_data,
                                xml_execution_data,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                object_version_number)
            values            ( p_entry_id,
                                p_xml_file_type,
                                v_languages.language_code,
                                '<?xml version="1.0"?>'||new_line||l_entry_xml,
                                '<?xml version="1.0"?>'||new_line||l_rp_lines_xml,
                                sysdate,
                                0,
                                sysdate,
                                0,
                                0 );

            CLOSE c_xml_id;

            --fnd_file.put_line(fnd_file.log, 'Inserted Entry XML for entry_id: ' || p_entry_id);
            IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
            THEN
                fnd_log.STRING
                   (fnd_log.level_statement,
                     g_api, 'Inserted Entry XML for entry_id: '||p_entry_id
                   );
            END IF;

            IF p_cons_rule_flag = 'Y' THEN
               --fnd_file.put_line(fnd_file.log, 'Inserted RP XML for entry_id: ' || p_entry_id);
               IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
               THEN
                   fnd_log.STRING
                       (fnd_log.level_statement,
                        g_api, 'Inserted RP XML for entry_id: '||p_entry_id );
               END IF;
            END IF;

    ELSE
            update  gcs_xml_files
            set     xml_data              = '<?xml version="1.0"?>'||new_line||l_entry_xml,
                    xml_execution_data    = '<?xml version="1.0"?>'||new_line||l_rp_lines_xml,
                    last_update_date      = sysdate,
                    last_updated_by       = 0,
                    object_version_number = object_version_number + 1
            where   xml_file_id = p_entry_id
            and     xml_file_type = p_xml_file_type
    	    and     language = v_languages.language_code;

            CLOSE c_xml_id;

            --fnd_file.put_line(fnd_file.log, 'Updated Entry XML for entry_id: ' || p_entry_id);
            IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
            THEN
                fnd_log.STRING
                  (fnd_log.level_statement,
                   g_api, 'Updated Entry XML for entry_id: '||p_entry_id
                   );
            END IF;

            IF p_cons_rule_flag = 'Y' THEN
               --fnd_file.put_line(fnd_file.log, 'Updated RP XML for entry_id: ' || p_entry_id);
               IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
               THEN
                   fnd_log.STRING
                       (fnd_log.level_statement,
                        g_api, 'Updated RP XML for entry_id: '||p_entry_id );
               END IF;
            END IF;

    END IF;
    COMMIT;
    END IF;
    exception
            when others then
			begin
			     DBMS_XMLGEN.closeContext(l_qryCtx);
                 --fnd_file.put_line(fnd_file.log, 'Exception: Others - entry_id: ' || p_entry_id||' - '|| SQLERRM);
                 IF fnd_log.g_current_runtime_level <= fnd_log.level_error
                 THEN
                     fnd_log.STRING
                                  (fnd_log.level_error,
                                   g_api, 'Exception: Others - entry_id: '||p_entry_id ||' - '||SQLERRM);
                 END IF;
            end;
    END;
   END LOOP;
 END generate_entry_xml;

 PROCEDURE  generate_ds_header_xml ( p_ds_header_data IN   r_ds_header_data,
                                     p_dataset_code   IN   NUMBER,
                                     p_ds_header_xml  OUT  NOCOPY CLOB )

 IS

 BEGIN

    p_ds_header_xml:=  ' <Header>'                      || new_line                            ||
                       '  <LoadId>'                     || p_ds_header_data.load_id            || '</LoadId>'              || new_line ||
                       '  <LoadName><![CDATA['          || p_ds_header_data.load_name          || ']]></LoadName>'         || new_line ||
                       '  <EntityName><![CDATA['        || p_ds_header_data.entity_name        || ']]></EntityName>'       || new_line ||
                       '  <BalanceTypeName><![CDATA['   || p_ds_header_data.balance_type       || ']]></BalanceTypeName>'  || new_line ||
                       '  <AmountTypeCode><![CDATA['    || p_ds_header_data.amount_type_code   || ']]></AmountTypeCode>'   || new_line ||
                       '  <AmountTypeName><![CDATA['    || p_ds_header_data.amount_type_name   || ']]></AmountTypeName>'   || new_line ||
                       '  <CurrencyTypeCode><![CDATA['  || p_ds_header_data.curr_type_code     || ']]></CurrencyTypeCode>' || new_line ||
                       '  <CurrencyTypeName><![CDATA['  || p_ds_header_data.curr_type_name     || ']]></CurrencyTypeName>' || new_line ||
                       '  <CurrencyCode><![CDATA['      || p_ds_header_data.currency_code      || ']]></CurrencyCode>'     || new_line ||
                       '  <EntityCurrencyCode><![CDATA['||p_ds_header_data.entity_currency_code||']]></EntityCurrencyCode>'||new_line||
                       '  <CurrencyName><![CDATA['      || p_ds_header_data.currency_name      || ']]></CurrencyName>'     || new_line ||
                       '  <CalPeriodId>'                || p_ds_header_data.cal_period_id      || '</CalPeriodId>'         || new_line ||
                       '  <CalPeriodName><![CDATA['     || p_ds_header_data.cal_period_name    || ']]></CalPeriodName>'    || new_line ||
                       '  <MeasureTypeCode><![CDATA['   || p_ds_header_data.measure_type_code  || ']]></MeasureTypeCode>'  || new_line ||
                       '  <MeasureType><![CDATA['       || p_ds_header_data.measure_type_name  || ']]></MeasureType>'      || new_line ||
                       '  <StartTime><![CDATA['         || p_ds_header_data.start_time         || ']]></StartTime>'        || new_line ||
                       '  <EndTime><![CDATA['           || p_ds_header_data.end_time           || ']]></EndTime>'          || new_line ||
                       '  <StatusCode><![CDATA['        || p_ds_header_data.status_code        || ']]></StatusCode>'       || new_line ||
                       '  <SourceSystemCode><![CDATA['  || p_ds_header_data.source_system_code || ']]></SourceSystemCode>' || new_line ||
                       '  <LedgerId>'                   || p_ds_header_data.ledger_id          || '</LedgerId>'            || new_line ||
                       '  <DatasetCode>'                || p_dataset_code                      || '</DatasetCode>'         || new_line ||
                       '</Header>'                      || new_line;

 END generate_ds_header_xml;

 PROCEDURE  generate_ds_xml ( p_load_id	      IN NUMBER)
 IS

   l_ds_header_data	    	    r_ds_header_data;
   l_ds_header_xml	    	    CLOB;
   l_dimension_name_xml		    CLOB;
   l_ds_lines_xml       	    CLOB;
   l_dstb_lines_xml     	    CLOB;
   l_ds_xml                   CLOB;
   l_dstb_xml                 CLOB;
   l_ds_lines_sql       	    VARCHAR2(10000);
   l_dstb_lines_sql     	    VARCHAR2(10000);
   l_dataset_code             NUMBER;
   l_qryCtx             	    DBMS_XMLGEN.ctxHandle;
   file_exist           	    NUMBER;
   doc_in               	    xmldom.DOMDocument;
   retval               	    xmldom.domnodelist;
   prsr                 	    xmlparser.parser;
   l_node               	    xmldom.domnode;
   doc_in1                    xmldom.DOMDocument;
   retval1                    xmldom.domnodelist;
   prsr1                      xmlparser.parser;
   l_node1                    xmldom.domnode;
   doc_in2                    xmldom.DOMDocument;
   retval2                    xmldom.domnodelist;
   prsr2                      xmlparser.parser;
   l_node2                    xmldom.domnode;
   l_xml_file_type      	    VARCHAR2(10);
   l_value_set_where_clause	  VARCHAR2(10000);
   l_rowseq_hash_sql          VARCHAR2(2000);

   TYPE r_rowseq_hash_table IS TABLE OF r_rowseq_hash_data;
   l_rowseq_hash_table        r_rowseq_hash_table;

   CURSOR	c_languages
   IS
     SELECT 	    language_code
     FROM	        fnd_languages
     WHERE	        installed_flag IN ('I','B');

   CURSOR	c_xml_id (
	                    p_language_code 	VARCHAR2,
                     	p_load_id 		NUMBER,
                     	l_xml_file_type 	VARCHAR2 )
   IS
     SELECT     	1
     FROM	    	gcs_xml_files
     WHERE	    	xml_file_id 	= 	p_load_id
     AND        	xml_file_type 	= 	l_xml_file_type
     AND        	language 	= 	p_language_code;


 BEGIN

   FOR 	v_languages	IN	c_languages
   LOOP
   BEGIN
   -- Get the DS Header Info for the load_id

      SELECT 	gdsd.load_id,
                gdsd.load_name,
                gdsd.entity_id,
                fet.entity_name,
                flv.meaning balance_type,
                gdsd.amount_type_code,
                amt.meaning amount_type_name,
                gdsd.currency_type_code,
                curr.meaning curr_type_name,
                gdsd.currency_code,
                fct.name currency_name,
                gdsd.cal_period_id,
                fcpt.cal_period_name,
                gdsd.measure_type_code,
                measure.meaning measure_type_name,
                gdsd.start_time,
                gdsd.end_time,
                gdsd.status_code,
                gdsd.balance_type_code,
                gdsd.balances_rule_id,
                foct.object_name balances_rule_name,
                flt.ledger_id,
                flt.ledger_name,
                fea_srcsys.dim_attribute_numeric_member source_system_code,
                fla_comp.dim_attribute_varchar_member entity_currency_code,
                fla_gvsc.dim_attribute_numeric_member sub_global_vs_combo_id
      INTO	    l_ds_header_data.load_id,
                l_ds_header_data.load_name,
                l_ds_header_data.entity_id,
                l_ds_header_data.entity_name,
                l_ds_header_data.balance_type,
                l_ds_header_data.amount_type_code,
                l_ds_header_data.amount_type_name,
                l_ds_header_data.curr_type_code,
                l_ds_header_data.curr_type_name,
                l_ds_header_data.currency_code,
                l_ds_header_data.currency_name,
                l_ds_header_data.cal_period_id,
                l_ds_header_data.cal_period_name,
                l_ds_header_data.measure_type_code,
                l_ds_header_data.measure_type_name,
                l_ds_header_data.start_time,
                l_ds_header_data.end_time,
                l_ds_header_data.status_code,
                l_ds_header_data.balance_type_code,
                l_ds_header_data.balances_rule_id,
                l_ds_header_data.balances_rule_name,
                l_ds_header_data.ledger_id,
                l_ds_header_data.ledger_name,
                l_ds_header_data.source_system_code,
                l_ds_header_data.entity_currency_code,
                l_ds_header_data.sub_global_vs_combo_id
      FROM      gcs_data_sub_dtls	gdsd,
                fem_entities_tl		fet,
                fnd_currencies_tl	fct,
                fem_cal_periods_tl	fcpt,
                fnd_lookup_values	flv,
                fnd_lookup_values   amt,
                fnd_lookup_values   curr,
                fnd_lookup_values   measure,
                fem_ledgers_tl flt,
                fem_entities_attr fea_ledger,
                fem_entities_attr fea_srcsys,
                fem_object_catalog_tl foct,
                fem_ledgers_attr fla_comp,
                fem_ledgers_attr fla_gvsc
      WHERE	    gdsd.load_id                =       	p_load_id
      AND       gdsd.entity_id 		        = 	    	fet.entity_id
      AND 	    fet.language 		        = 	    	v_languages.language_code
      AND 	    gdsd.currency_code 	        = 	    	fct.currency_code(+)
      AND 	    fct.language (+)	        = 	    	v_languages.language_code
      AND 	    gdsd.cal_period_id 	        = 	    	fcpt.cal_period_id
      AND 	    fcpt.language 		        = 	    	v_languages.language_code
      AND 	    gdsd.balance_type_code      = 	    	flv.lookup_code
      AND 	    flv.language 		        = 	    	v_languages.language_code
      AND 	    flv.lookup_type 	        = 	    	'GCS_BALANCE_TYPE_CODES'
      AND 	    flv.view_application_id     = 	    	266
      AND       gdsd.amount_type_code       =       	amt.lookup_code
      AND       amt.lookup_type             =       	'GCS_AMOUNT_TYPE_CODES'
      AND       amt.LANGUAGE                =       	v_languages.language_code
      AND       amt.view_application_id     =       	266
      AND       gdsd.currency_type_code     =       	curr.lookup_code
      AND       curr.lookup_type            =       	'GCS_CURRENCY_TYPES'
      AND       curr.LANGUAGE               =       	v_languages.language_code
      AND       curr.view_application_id    =       	266
      AND       gdsd.measure_type_code      =       	measure.lookup_code
      AND       measure.lookup_type         =       	'GCS_MEASURE_TYPE_CODES'
      AND       measure.LANGUAGE            =       	v_languages.language_code
      AND       measure.view_application_id =       	266
      AND       fea_ledger.entity_id        =           gdsd.entity_id
      AND       fea_ledger.attribute_id     =           l_entity_ledger_attr
      AND       fea_ledger.version_id       =           l_entity_ledger_version
      AND       flt.ledger_id               =           fea_ledger.dim_attribute_numeric_member
      AND       flt.language                =           v_languages.language_code
      AND       fea_srcsys.entity_id        =           gdsd.entity_id
      AND       fea_srcsys.attribute_id     =           l_entity_srcsys_attr
      AND       fea_srcsys.version_id       =           l_entity_srcsys_version
      AND       foct.object_id (+)          =           gdsd.balances_rule_id
      AND       foct.language (+)           =           v_languages.language_code
      AND       fla_comp.ledger_id          =           fea_ledger.dim_attribute_numeric_member
      AND       fla_comp.attribute_id       =           l_ldg_curr_attr
      AND       fla_comp.version_id         =           l_ldg_curr_version
      AND       fla_gvsc.ledger_id          =           fea_ledger.dim_attribute_numeric_member
      AND       fla_gvsc.attribute_id       =           l_ledger_vs_combo_attr
      AND       fla_gvsc.version_id         =           l_ledger_vs_combo_version
      AND       ROWNUM                      <           2;

      IF (l_ds_header_data.source_system_code = 10) THEN
         SELECT actual_output_dataset_code
         INTO   l_dataset_code
         FROM   fem_object_definition_b fodb,
                fem_cal_periods_attr fcpa_enddate,
                fem_dim_attr_versions_b fdavb_enddate,
                fem_intg_bal_rule_defs fibrd
         WHERE  fodb.object_id = l_ds_header_data.balances_rule_id
         AND    fcpa_enddate.date_assign_value BETWEEN fodb.effective_start_date AND fodb.effective_end_date
         AND    fcpa_enddate.attribute_id    =   gcs_utility_pkg.get_dimension_attribute('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
         AND    fcpa_enddate.attribute_id    =   fdavb_enddate.attribute_id
         AND    fcpa_enddate.version_id      =   fdavb_enddate.version_id
         AND    fdavb_enddate.default_version_flag            = 'Y'
         AND    fodb.object_definition_id    = fibrd.bal_rule_obj_def_id
         AND    ROWNUM < 2;
      END IF;

      --fnd_file.put_line(fnd_file.log, 'start DS XML for Load Id : ' || p_load_id);
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_DS_XML.begin', 'Start DS XML for Load Id : '||p_load_id);
      END IF;

    -- Generate the header level XML
    generate_ds_header_xml( p_ds_header_data => l_ds_header_data,
                            p_dataset_code   => l_dataset_code,
                            p_ds_header_xml  => l_ds_header_xml );

    IF l_ds_header_data.source_system_code <> 10 THEN
    -- Generate the dimension name XML
    generate_dimension_name_xml ( p_language_code      => v_languages.language_code,
                                  p_fem_dim_y_n        => 'Y',
                                  p_xml_file_type      => 'DSLOAD',
                                  p_dimension_name_xml => l_dimension_name_xml );

    append_value_set_query      ( p_entity_id          => l_ds_header_data.entity_id,
                                  p_value_set_clause   => l_value_set_where_clause);

    -- take the sql query from gcs_xml_utility_pkg.g_datasub_lines_select_stmnt
    -- add the clause for gel.load_id and lang.language_code
    l_xml_file_type := 'DSLOAD';
    l_ds_lines_sql:= gcs_xml_utility_pkg.g_datasub_lines_select_stmnt	 	||
			' AND load_id = '|| p_load_id				||
		 	l_value_set_where_clause				||
			' ORDER BY ' || gcs_xml_utility_pkg.g_ds_order_by_stmnt;

    -- Generate new query context and set desired Row Set and Row Tag and
    -- generate XML data
    l_qryCtx := DBMS_XMLGEN.newContext(l_ds_lines_sql);
    DBMS_XMLGEN.setRowSetTag(l_qryCtx,'Lines');
    DBMS_XMLGEN.setRowTag(l_qryCtx,'Row');
    DBMS_XMLGEN.setConvertSpecialChars(l_qryCtx,FALSE);
    l_ds_lines_xml := DBMS_XMLGEN.getXML(l_qryCtx);

    -- Remove xml version header tag from XML data
    IF (l_ds_lines_xml IS NOT NULL) THEN
       prsr := xmlparser.newparser;
       xmlparser.parseclob (prsr, l_ds_lines_xml);
       l_ds_lines_xml := ' ';
       doc_in := xmlparser.getdocument (prsr);
       xmlparser.freeparser (prsr);
       retval := xslprocessor.selectnodes (xmldom.makenode( doc_in), 'Lines' );
       l_node := xmldom.item(retval , 0);
       xmldom.writetoclob(l_node, l_ds_lines_xml);
    END IF;

    l_ds_xml := '<DataSubRoot> '||new_line||
                l_ds_header_xml||l_dimension_name_xml|| l_ds_lines_xml||
                '</DataSubRoot> ';

    OPEN c_xml_id(v_languages.language_code, p_load_id, l_xml_file_type);
    FETCH c_xml_id INTO file_exist;

    IF c_xml_id%NOTFOUND THEN
                 insert into    gcs_xml_files
	                      ( xml_file_id,
                                xml_file_type,
                                language,
                                xml_data,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                object_version_number)
                  values      ( p_load_id,
                                l_xml_file_type,
                                v_languages.language_code,
								'<?xml version="1.0"?>'||new_line||l_ds_xml,
                                sysdate,
                                0,
                                sysdate,
                                0,
                                0 );
            CLOSE c_xml_id;

            --fnd_file.put_line(fnd_file.log, 'Inserted DS LOAD XML for Load Id : ' || p_load_id);
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_DS_XML.INSERT', 'Inserted DS LOAD XML for Load Id : '||p_load_id);
            END IF;

    ELSE
            update gcs_xml_files
            set    xml_data = '<?xml version="1.0"?>'||new_line||l_ds_xml,
                   last_update_date = sysdate,
                   last_updated_by = 0,
                   object_version_number = object_version_number + 1
            where  xml_file_id = p_load_id
            and    xml_file_type = l_xml_file_type
            and    language = v_languages.language_code;

            CLOSE c_xml_id;

            --fnd_file.put_line(fnd_file.log, 'Updated DS LOAD XML for Load Id : ' || p_load_id);
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_DS_XML.UPDATE', 'Updated DS LOAD XML for Load Id : '||p_load_id);
            END IF;

    END IF;
    COMMIT;

    END IF;
    -- Generate the dimension name XML
    generate_dimension_name_xml ( p_language_code      => v_languages.language_code,
                                  p_fem_dim_y_n        => 'Y',
                                  p_xml_file_type      => 'DSTB',
                                  p_dimension_name_xml => l_dimension_name_xml );

    -- take the sql query from gcs_xml_utility_pkg.g_dstb_lines_select_stmnt
    l_xml_file_type := 'DSTB';

    IF l_ds_header_data.source_system_code = 10 THEN

          l_dstb_lines_sql:=  gcs_xml_utility_pkg.g_ogl_dstb_lines_select_stmnt||
                              l_ds_header_data.sub_global_vs_combo_id||
                              gcs_xml_utility_pkg.g_ogl_dstb_lines_select_stmnt1||
                              ' AND fea_balrule.ENTITY_ID = '||
                              l_ds_header_data.entity_id ||
                              ' AND gel.SOURCE_SYSTEM_CODE = '||
                              l_ds_header_data.source_system_code ||
                              ' AND fct.language(+) = '''||
                              v_languages.language_code ||
                             ''' AND gel.CAL_PERIOD_ID = '||
                             l_ds_header_data.cal_period_id;
    ELSE
         l_dstb_lines_sql:=  gcs_xml_utility_pkg.g_dstb_lines_select_stmnt||
                             ' AND fem_entities_source_system.ENTITY_ID = '||
                             l_ds_header_data.entity_id ||
                             ' AND fct.language(+) = '''||
                             v_languages.language_code ||
                             ''' AND gel.CAL_PERIOD_ID = '||
                             l_ds_header_data.cal_period_id;
    END IF;

    IF (l_ds_header_data.balance_type_code = 'ACTUAL') THEN

         l_dstb_lines_sql := l_dstb_lines_sql|| ' AND gel.FINANCIAL_ELEM_ID <> 140';

    ELSE

         l_dstb_lines_sql := l_dstb_lines_sql|| ' AND gel.FINANCIAL_ELEM_ID = 140';

    END IF;

    IF (l_ds_header_data.curr_type_code = 'BASE_CURRENCY'
                                       AND l_ds_header_data.source_system_code <> 10) THEN

         l_dstb_lines_sql := l_dstb_lines_sql|| ' AND gel.CURRENCY_CODE = '||
                             ''''||l_ds_header_data.currency_code||'''';

    ELSIF (l_ds_header_data.currency_code = l_ds_header_data.entity_currency_code
                                        AND l_ds_header_data.source_system_code = 10) THEN

         l_dstb_lines_sql := l_dstb_lines_sql||'AND   gel.currency_type_code = ''ENTERED'' ';

    ELSIF (l_ds_header_data.currency_code <> l_ds_header_data.entity_currency_code
                                        AND l_ds_header_data.source_system_code = 10) THEN

         l_dstb_lines_sql := l_dstb_lines_sql||  'AND   gel.currency_type_code = ''TRANSLATED'' ';

    END IF;

	  l_dstb_lines_sql := l_dstb_lines_sql || ' GROUP BY ' ||
                       gcs_xml_utility_pkg.g_ds_order_by_stmnt ;

    IF l_ds_header_data.source_system_code <> 10 THEN

           l_dstb_lines_sql := l_dstb_lines_sql ||', fct.name';
    ELSE

           l_dstb_lines_sql := l_dstb_lines_sql ||', '||
                        gcs_xml_utility_pkg.g_group_by_stmnt;

           l_rowseq_hash_sql := gcs_xml_utility_pkg.g_ogl_hash_select_stmnt;

           -- Generate ccid hash keys table using dynamic query string created earlier
           EXECUTE IMMEDIATE l_rowseq_hash_sql
           BULK COLLECT INTO l_rowseq_hash_table
           USING l_dataset_code, l_ds_header_data.cal_period_id,
                 l_ds_header_data.source_system_code, l_ds_header_data.ledger_id,
                 l_ds_header_data.currency_code;
    END IF;

    l_dstb_lines_sql := l_dstb_lines_sql || ' ORDER BY ' ||
                                        gcs_xml_utility_pkg.g_ds_order_by_stmnt;

    IF (l_ds_header_data.source_system_code <> 10) THEN
           l_dstb_lines_sql := l_dstb_lines_sql ||', fct.name';
    END IF;
    -- Generate new query context and set desired Row Set and Row Tag and
    -- generate XML data
    l_qryCtx := DBMS_XMLGEN.newContext(l_dstb_lines_sql);
    DBMS_XMLGEN.setRowSetTag(l_qryCtx,'Lines');
    DBMS_XMLGEN.setRowTag(l_qryCtx,'Row');
    DBMS_XMLGEN.setConvertSpecialChars(l_qryCtx,FALSE);
    l_dstb_lines_xml := DBMS_XMLGEN.getXML(l_qryCtx);

    -- Remove xml version header tag from XML data
    IF (l_dstb_lines_xml IS NOT NULL) THEN
       prsr := xmlparser.newparser;
       xmlparser.parseclob (prsr, l_dstb_lines_xml);
       l_dstb_lines_xml := ' ';
       doc_in := xmlparser.getdocument (prsr);
       xmlparser.freeparser (prsr);
       retval := xslprocessor.selectnodes (xmldom.makenode( doc_in), 'Lines' );
       l_node := xmldom.item(retval , 0);
       xmldom.writetoclob(l_node, l_dstb_lines_xml);
       -- Manipulate dstb xml and update creation row sequence node
       IF l_ds_header_data.source_system_code = 10 THEN
          IF (l_rowseq_hash_table.FIRST IS NOT NULL AND
              l_rowseq_hash_table.LAST IS NOT NULL) THEN
             FOR i IN l_rowseq_hash_table.FIRST..l_rowseq_hash_table.LAST
             LOOP
                  l_dstb_lines_xml :=  replace(l_dstb_lines_xml, '<CREATION_ROW_SEQUENCE>-1111111111</CREATION_ROW_SEQUENCE>'|| new_line ||
                                         '      <HASHKEY>'||l_rowseq_hash_table(i).rowseq_hash_key||'</HASHKEY>',
	                                       '<CREATION_ROW_SEQUENCE>'||l_rowseq_hash_table(i).creation_row_sequence||'</CREATION_ROW_SEQUENCE>' || new_line ||
                                         '      <HASHKEY>'||l_rowseq_hash_table(i).rowseq_hash_key||'</HASHKEY>');
              END LOOP;
          END IF;
       END IF;
    END IF;
	  l_dstb_xml := '<DataSubRoot> '||new_line||
                l_ds_header_xml||l_dimension_name_xml|| l_dstb_lines_xml||
                '</DataSubRoot> ';

    OPEN c_xml_id(v_languages.language_code, p_load_id, l_xml_file_type);
    FETCH c_xml_id INTO file_exist;

    IF c_xml_id%NOTFOUND THEN
                 insert into    gcs_xml_files
	                      ( xml_file_id,
                                xml_file_type,
                                language,
                                xml_data,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                object_version_number)
                  values      ( p_load_id,
                                l_xml_file_type,
                                v_languages.language_code,
                                '<?xml version="1.0"?>'||new_line||l_dstb_xml,
                                sysdate,
                                0,
                                sysdate,
                                0,
                                0 );
            CLOSE c_xml_id;

            --fnd_file.put_line(fnd_file.log, 'Inserted DSTB XML for Load Id : ' || p_load_id);
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_DS_XML.INSERT', 'Inserted DSTB XML for Load Id : '||p_load_id);
            END IF;

    ELSE
            update gcs_xml_files
            set    xml_data = '<?xml version="1.0"?>'||new_line||l_dstb_xml,
                   last_update_date = sysdate,
                   last_updated_by = 0,
                   object_version_number = object_version_number + 1
            where  xml_file_id = p_load_id
            and    xml_file_type = l_xml_file_type
            and    language = v_languages.language_code;

            CLOSE c_xml_id;
            --fnd_file.put_line(fnd_file.log, 'Updated DSTB XML for Load Id : ' || p_load_id);
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_DS_XML.UPDATE', 'Updated DSTB XML for Load Id : '||p_load_id);
            END IF;

    END IF;
    COMMIT;

    exception
           when others then
			     begin
			           DBMS_XMLGEN.closeContext(l_qryCtx);
                 --fnd_file.put_line(fnd_file.log, 'Error DS XML for Load Id : ' || p_load_id||' - '|| SQLERRM);
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_DS_XML.UPDATE', 'Error DS XML for Load Id : '||p_load_id||' - '||SQLERRM);
                 END IF;
            end;
    END;
   END LOOP;
 END generate_ds_xml;


 PROCEDURE  generate_ad_header_xml ( p_ad_header_data IN  r_ad_header_data,
                                     p_ad_header_xml  OUT NOCOPY CLOB )

 IS

 BEGIN

    p_ad_header_xml:=  ' <AD_HEADER>'         || new_line                             ||
                       '  <ENTRY_NAME><![CDATA['       || p_ad_header_data.entry_name          || ']]></ENTRY_NAME>'       || new_line ||
                       '  <DESCRIPTION><![CDATA['      || p_ad_header_data.description         || ']]></DESCRIPTION>'      || new_line ||
                       '  <CONSIDERATION><![CDATA['    || p_ad_header_data.total_consideration || ']]></CONSIDERATION>'    || new_line ||
                       '  <CATEGORY_NAME><![CDATA['    || p_ad_header_data.category_name       || ']]></CATEGORY_NAME>'    || new_line ||
                       '  <TRANSACTION_DATE><![CDATA[' || p_ad_header_data.transaction_date    || ']]></TRANSACTION_DATE>' || new_line ||
                       '  <HIERARCHY_NAME><![CDATA['   || p_ad_header_data.hierarchy_name      || ']]></HIERARCHY_NAME>'   || new_line ||
                       '  <CONS_ENTITY_NAME><![CDATA[' || p_ad_header_data.cons_entity_name    || ']]></CONS_ENTITY_NAME>' || new_line ||
                       '  <CHILD_ENTITY_NAME><![CDATA['|| p_ad_header_data.child_entity_name   || ']]></CHILD_ENTITY_NAME>'|| new_line ||
                       '  <CURRENCY_NAME><![CDATA['    || p_ad_header_data.currency_name       || ']]></CURRENCY_NAME>'    || new_line ||
                       '</AD_HEADER>'         || new_line;
 END generate_ad_header_xml;

 PROCEDURE  generate_ad_xml ( p_ad_transaction_id IN NUMBER )
 IS

   l_ad_header_data	    r_ad_header_data;
   l_ad_header_xml	    CLOB;
   l_dimension_name_xml	CLOB;
   l_ad_lines_xml       CLOB;
   l_ad_xml             CLOB;
   l_ad_lines_sql       VARCHAR2(10000);
   l_qryCtx             DBMS_XMLGEN.ctxHandle;
   file_exist           NUMBER;
   doc_in               xmldom.DOMDocument;
   retval               xmldom.domnodelist;
   prsr                 xmlparser.parser;
   l_node               xmldom.domnode;
   doc_in1              xmldom.DOMDocument;
   retval1              xmldom.domnodelist;
   prsr1                xmlparser.parser;
   l_node1              xmldom.domnode;
   p_xml_file_type      VARCHAR2(10) := 'ADTB';

   CURSOR	c_languages
   IS
         SELECT language_code
         FROM	  fnd_languages
         WHERE	installed_flag IN ('I','B');

   CURSOR	c_xml_id ( p_language_code     VARCHAR2,
                     p_ad_transaction_id NUMBER )
   IS
         SELECT 1
         FROM	  gcs_xml_files
         WHERE	xml_file_id = p_ad_transaction_id
         AND    xml_file_type = p_xml_file_type
         AND    language = p_language_code;

 BEGIN

   FOR 	v_languages	IN	c_languages
   LOOP
   BEGIN
   -- Get the ad Header Info for the ad_transaction_id
   SELECT
         flv.meaning category_name,
         treatments.transaction_date,
         ght.hierarchy_name hierarchy_name,
         fet1.entity_name consolidation_entity_name,
         fet2.entity_name child_entity_name,
         treatments.total_consideration||' '||fct.name total_consideration,
         treatments.entry_name
   INTO
         l_ad_header_data.category_name,
         l_ad_header_data.transaction_date,
         l_ad_header_data.hierarchy_name,
         l_ad_header_data.cons_entity_name,
         l_ad_header_data.child_entity_name,
         l_ad_header_data.total_consideration,
         l_ad_header_data.entry_name
   FROM
         fnd_lookup_values flv,
         fem_entities_tl fet1,
         fem_entities_tl fet2,
         gcs_entity_cons_attrs geca,
         gcs_hierarchies_tl ght,
         fnd_currencies_tl fct,
         fnd_currencies fcb,
         (select gtt_to.treatment_id to_treatment_id,
                 gtt_from.treatment_id from_treatment_id,
                 gtt_to.treatment_name to_treatment,
                 gtt_from.treatment_name from_treatment,
                 fcr.status_code,
                 gat.post_cons_relationship_id,
                 gat.pre_cons_relationship_id,
                 gat.intermediate_treatment_id,
                 gat.transaction_type_code,
                 gat.total_consideration,
                 fcr.request_id,
                 gat.ad_transaction_id,
                 gat.transaction_date,
                 nvl(gcr.parent_entity_id, gcr_pre.parent_entity_id) parent_entity_id,
                 nvl(gcr.child_entity_id, gcr_pre.child_entity_id) child_entity_id,
                 nvl(gcr.hierarchy_id, gcr_pre.hierarchy_id) hierarchy_id,
                 NVL (gcr.ownership_percent, 0) to_percent,
                 NVL (gcr_pre.ownership_percent, 0) from_percent,
                 geh.entry_name entry_name
          from   gcs_treatments_tl gtt_from,
                 gcs_treatments_tl gtt_to,
                 gcs_ad_transactions gat,
                 gcs_entry_headers geh,
                 fnd_concurrent_requests fcr,
                 gcs_cons_relationships gcr,
                 gcs_cons_relationships gcr_pre
          where
                 gtt_from.LANGUAGE = v_languages.language_code AND
                 gtt_to.LANGUAGE = v_languages.language_code AND
                 gat.assoc_entry_id = geh.entry_id AND
                 gat.request_id = fcr.request_id (+) AND
                 gat.ad_transaction_id = p_ad_transaction_id AND
                 gat.post_cons_relationship_id = gcr.cons_relationship_id (+) AND
                 gat.pre_cons_relationship_id = gcr_pre.cons_relationship_id(+) AND
                 nvl(gcr.treatment_id, gat.intermediate_treatment_id) = gtt_to.treatment_id AND
                 nvl(gcr_pre.treatment_id, gat.intermediate_treatment_id) = gtt_from.treatment_id
		 ) treatments,
		 (select grb.to_treatment_id,
		         grb.from_treatment_id,
		         grb.rule_id, grt.rule_name,
		  		 grb.transaction_type_code
		  from   gcs_elim_rules_tl grt,
		         gcs_elim_rules_b grb
		  where  grt.LANGUAGE = v_languages.language_code AND
                 grb.rule_id = grt.rule_id
         ) rules
   WHERE treatments.to_treatment_id = rules.to_treatment_id (+) AND
         treatments.from_treatment_id = rules.from_treatment_id (+) AND
         rules.transaction_type_code (+)= treatments.transaction_type_code AND
         fet1.entity_id = treatments.parent_entity_id AND
         fet1.LANGUAGE = v_languages.language_code AND
         fet2.entity_id = treatments.child_entity_id AND
         fet2.LANGUAGE = v_languages.language_code AND
         geca.entity_id = treatments.parent_entity_id AND
         geca.hierarchy_id = ght.hierarchy_id AND
         ght.language = v_languages.language_code AND
         geca.currency_code = fcb.currency_code AND
         treatments.hierarchy_id = ght.hierarchy_id AND
         treatments.transaction_type_code = flv.lookup_code AND
         flv.lookup_type = 'TRANSACTION_TYPE_CODE' AND
         flv.LANGUAGE = v_languages.language_code AND
         flv.view_application_id = 266 AND
         fct.currency_code = fcb.currency_code AND
         fct.LANGUAGE = v_languages.language_code AND
         ROWNUM <= 1;

          --fnd_file.put_line(fnd_file.log, 'Start AD XML for AD Transaction Id : ' || p_ad_transaction_id);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_AD_XML.begin', 'Start AD XML for AD Transaction Id : '||p_ad_transaction_id);
          END IF;

    -- Generate the header level XML
    generate_ad_header_xml( p_ad_header_data =>	l_ad_header_data,
                            p_ad_header_xml  =>	l_ad_header_xml );

    -- Generate the dimension name XML
    generate_dimension_name_xml ( p_language_code       => v_languages.language_code,
                                  p_fem_dim_y_n         => 'N',
                                  p_xml_file_type       => 'ADTB',
                                  p_dimension_name_xml	=> l_dimension_name_xml );

    -- take the sql query from gcs_xml_utility_pkg.g_datasub_lines_select_stmnt
    -- add the clause for gel.ad_transaction_id and lang.language_code
    l_ad_lines_sql:= gcs_xml_utility_pkg.g_ad_lines_select_stmnt ||
                     ' AND ad_transaction_id = ' ||
                     p_ad_transaction_id ||
                     ' ORDER BY TRIAL_BALANCE_SEQ, '||
                     gcs_xml_utility_pkg.g_order_by_stmnt;

    -- Generate new query context and set desired Row Set and Row Tag
    -- and generate XML data
    l_qryCtx := DBMS_XMLGEN.newContext(l_ad_lines_sql);
    DBMS_XMLGEN.setRowSetTag(l_qryCtx,'AD_LINES');
    DBMS_XMLGEN.setRowTag(l_qryCtx,'AD_LINES_ROW');
    DBMS_XMLGEN.setConvertSpecialChars(l_qryCtx,FALSE);
    l_ad_lines_xml := DBMS_XMLGEN.getXML(l_qryCtx);

    -- Remove xml version header tag from XML data
    IF (l_ad_lines_xml IS NOT NULL) THEN
       prsr := xmlparser.newparser;
       xmlparser.parseclob (prsr, l_ad_lines_xml);
       doc_in := xmlparser.getdocument (prsr);
       xmlparser.freeparser (prsr);
       retval := xslprocessor.selectnodes (xmldom.makenode( doc_in), 'AD_LINES' );
       l_node := xmldom.item(retval , 0);
       xmldom.writetoclob(l_node, l_ad_lines_xml);
    END IF;
    l_ad_xml := '<AD_DATA> '||new_line||
                l_ad_header_xml|| l_dimension_name_xml|| l_ad_lines_xml||
                '</AD_DATA> ';

    OPEN c_xml_id(v_languages.language_code, p_ad_transaction_id);
    FETCH c_xml_id INTO file_exist;

    IF c_xml_id%NOTFOUND THEN
           insert into   gcs_xml_files
                        (xml_file_id,
                         xml_file_type,
                         language,
                         xml_data,
                         last_update_date,
                         last_updated_by,
                         creation_date,
                         created_by,
                         object_version_number)
           values       (p_ad_transaction_id,
                         p_xml_file_type,
                         v_languages.language_code,
                         '<?xml version="1.0"?>'||new_line||l_ad_xml,
                         sysdate,
                         0,
                         sysdate,
                         0,
                         0);
          CLOSE c_xml_id;

          --fnd_file.put_line(fnd_file.log, 'Inserted AD XML for AD Transaction Id : ' || p_ad_transaction_id);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_AD_XML.INSERT', 'Inserted AD XML for AD Transaction Id : '||p_ad_transaction_id);
          END IF;

    ELSE
          update gcs_xml_files
          set    xml_data              = '<?xml version="1.0"?>'||new_line||l_ad_xml,
                 last_update_date      = sysdate,
                 last_updated_by       = 0,
                 object_version_number = object_version_number + 1
          where  xml_file_id = p_ad_transaction_id
          and    xml_file_type = p_xml_file_type
          and    language = v_languages.language_code;

          CLOSE c_xml_id;

          --fnd_file.put_line(fnd_file.log, 'Updated AD XML for AD Transaction Id : ' || p_ad_transaction_id);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_AD_XML.UPDATE', 'Updated AD XML for AD Transaction Id : '||p_ad_transaction_id);
          END IF;

    END IF;
    COMMIt;

    exception
            when others then
			begin
			     DBMS_XMLGEN.closeContext(l_qryCtx);
                 --fnd_file.put_line(fnd_file.log, 'Error occurred : ' || SQLERRM);
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_AD_XML.EXCEPTION', '<<Error>>'||SQLERRM);
                 END IF;
		    end;
    END;
   END LOOP;
 END generate_ad_xml;
*/
 PROCEDURE submit_entry_xml_gen	( x_errbuf		OUT NOCOPY	VARCHAR2,
                                  x_retcode		OUT NOCOPY	VARCHAR2,
                                  p_run_name		IN VARCHAR2,
                                  p_cons_entity_id   	IN NUMBER,
                                  p_category_code    	IN VARCHAR2,
                                  p_child_entity_id  	IN NUMBER,
                                  p_run_detail_id    	IN NUMBER)

   IS

     l_errbuf			VARCHAR2(200);
     l_retcode			VARCHAR2(200);

     TYPE entry_list		IS TABLE OF NUMBER(15);
     l_entry_list 		entry_list;
     TYPE stat_entry_list	IS TABLE OF NUMBER(15);
     l_stat_entry_list		stat_entry_list;
     TYPE run_detail_list	IS TABLE OF NUMBER(15);
     l_run_detail_list		run_detail_list;
     TYPE request_error_list	IS TABLE OF VARCHAR2(400);
     l_request_error_list	request_error_list;

     l_entry_id			NUMBER(15);
     l_stat_entry_id		NUMBER(15);
     l_request_error_code	VARCHAR2(400);

     CURSOR c_intracomp_info IS
     SELECT  	run_detail_id,
		entry_id,
		stat_entry_id,
		request_error_code
     FROM   	gcs_cons_eng_run_dtls
     WHERE  	run_name		= p_run_name
     AND    	consolidation_entity_id	= p_cons_entity_id
     AND    	child_entity_id		= p_child_entity_id
     AND    	category_code		= p_category_code;

     CURSOR c_intercomp_info IS
     SELECT 	run_detail_id,
		entry_id,
		stat_entry_id,
		request_error_code
     FROM   	gcs_cons_eng_run_dtls
     WHERE  	run_name		= p_run_name
     AND    	consolidation_entity_id	= p_cons_entity_id
     AND	child_entity_id		IS NOT NULL
     AND    	category_code		= p_category_code;

     CURSOR c_operational_consol_rules IS
     SELECT	run_detail_id,
		entry_id,
		stat_entry_id,
		request_error_code
     FROM	gcs_cons_eng_run_dtls
     WHERE	run_name		= p_run_name
     AND	consolidation_entity_id	= p_cons_entity_id
     AND	category_code		= p_category_code
     AND 	child_entity_id		= p_child_entity_id;

     CURSOR c_consol_rules IS
     SELECT     run_detail_id,
                entry_id,
                stat_entry_id,
                request_error_code
     FROM       gcs_cons_eng_run_dtls
     WHERE      run_name                = p_run_name
     AND        consolidation_entity_id = p_cons_entity_id
     AND	child_entity_id		IS NOT NULL
     AND        category_code           = p_category_code;

   BEGIN
     --fnd_file.put_line(fnd_file.log, 'Beginning XML generation');
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.begin', '<<Enter>>');
     END IF;

     IF p_category_code = 'DATAPREPARATION' THEN
       BEGIN
        SELECT 	entry_id,
                stat_entry_id,
                request_error_code
        INTO   	l_entry_id,
                l_stat_entry_id,
                l_request_error_code
        FROM   	gcs_cons_eng_run_dtls
        WHERE  	run_detail_id		= p_run_detail_id;

        EXCEPTION
         WHEN OTHERS THEN
         BEGIN
           --fnd_file.put_line(fnd_file.log, 'Error occurred : ' || SQLERRM);
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.DATAPREPARATION', 'Error:' ||SQLERRM);
           END IF;
         END;
       END;
     ELSIF p_category_code = 'TRANSLATION' OR p_category_code = 'AGGREGATION' THEN
       BEGIN
        SELECT	entry_id,
                request_error_code
        INTO   	l_entry_id,
                l_request_error_code
        FROM   	gcs_cons_eng_run_dtls
        WHERE  	run_detail_id		= p_run_detail_id;
        --fnd_file.put_line(fnd_file.log, 'Entry Id'|| l_entry_id);
        EXCEPTION
         WHEN OTHERS THEN
         BEGIN
	       --fnd_file.put_line(fnd_file.log, 'Error occurred : ' || SQLERRM);
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.'||p_category_code, 'Error:' ||SQLERRM);
           END IF;
         END;
       END;
     ELSIF p_category_code = 'INTRACOMPANY' THEN
       OPEN  c_intracomp_info;
       FETCH c_intracomp_info BULK COLLECT INTO l_run_detail_list, l_entry_list, l_stat_entry_list, l_request_error_list;
       CLOSE c_intracomp_info;
     ELSIF p_category_code = 'INTERCOMPANY' THEN
       OPEN  c_intercomp_info;
       FETCH c_intercomp_info BULK COLLECT INTO l_run_detail_list, l_entry_list, l_stat_entry_list, l_request_error_list;
       CLOSE c_intercomp_info;
     ELSIF p_child_entity_id IS NOT NULL THEN
       OPEN  c_operational_consol_rules;
       FETCH c_operational_consol_rules BULK COLLECT INTO l_run_detail_list, l_entry_list, l_stat_entry_list, l_request_error_list;
       CLOSE c_operational_consol_rules;
     ELSE
       OPEN  c_consol_rules;
       FETCH c_consol_rules BULK COLLECT INTO l_run_detail_list, l_entry_list, l_stat_entry_list, l_request_error_list;
       CLOSE c_consol_rules;
     END IF;

     IF ( p_category_code	=	'DATAPREPARATION') THEN
       /*IF l_entry_id IS NOT NULL THEN
          generate_entry_xml( p_entry_id       => l_entry_id,
                              p_category_code  => p_category_code,
                              p_cons_rule_flag => 'N' );
          --fnd_file.put_line(fnd_file.log, 'generate_entry_xml Entry_id ='|| l_entry_id || ' category= ' ||p_category_code);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.'||p_category_code,
                         'generate_entry_xml Entry_id ='|| l_entry_id || ' category= ' ||p_category_code);
          END IF;
       END IF;
       IF l_stat_entry_id IS NOT NULL THEN
          generate_entry_xml( p_entry_id       => l_stat_entry_id,
                              p_category_code  => p_category_code,
                              p_cons_rule_flag => 'N' );
          --fnd_file.put_line(fnd_file.log, 'generate_entry_xml Entry_id ='|| l_stat_entry_id || ' category= ' ||p_category_code);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.'||p_category_code,
                         'generate_entry_xml Entry_id ='|| l_stat_entry_id || ' category= ' ||p_category_code);
          END IF;
       END IF; */
       IF (l_request_error_code	 NOT IN	('COMPLETED', 'N/A')) THEN
           gcs_wf_ntf_pkg.raise_status_notification(
			      p_cons_detail_id => p_run_detail_id);
       END IF;
     /*ELSIF (p_category_code	=	'AGGREGATION') THEN
       IF l_entry_id IS NOT NULL THEN
          generate_entry_xml( p_entry_id       => l_entry_id,
                              p_category_code  => p_category_code,
                              p_cons_rule_flag => 'N' );
          --fnd_file.put_line(fnd_file.log, 'generate_entry_xml Entry_id ='|| l_entry_id || ' category= ' ||p_category_code);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.'||p_category_code,
                         'generate_entry_xml Entry_id ='|| l_entry_id || ' category= ' ||p_category_code);
          END IF;
       END IF;*/
     ELSIF (p_category_code	=	'TRANSLATION') THEN
       /*IF l_entry_id IS NOT NULL THEN
          generate_entry_xml( p_entry_id       => l_entry_id,
                              p_category_code  => p_category_code,
                              p_cons_rule_flag => 'N' );
          --fnd_file.put_line(fnd_file.log, 'generate_entry_xml Entry_id ='|| l_entry_id || ' category= ' ||p_category_code);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.'||p_category_code,
                         'generate_entry_xml Entry_id ='|| l_entry_id || ' category= ' ||p_category_code);
          END IF;
       END IF;*/
       IF (l_request_error_code	NOT IN ('COMPLETED', 'N/A')) THEN
          gcs_wf_ntf_pkg.raise_status_notification(
				p_cons_detail_id => p_run_detail_id);
       END IF;
     ELSE
       IF (l_entry_list.FIRST IS NOT NULL AND l_entry_list.LAST IS NOT NULL) THEN
         /*FOR l_index IN l_entry_list.FIRST..l_entry_list.LAST LOOP
           IF l_entry_list(l_index) IS NOT NULL THEN
             generate_entry_xml( p_entry_id       => l_entry_list(l_index),
                                 p_category_code  => p_category_code,
                                 p_cons_rule_flag => 'N' );
           END IF;
         END LOOP;
         FOR l_index IN l_stat_entry_list.FIRST..l_stat_entry_list.LAST LOOP
           IF l_stat_entry_list(l_index) IS NOT NULL THEN
             generate_entry_xml( p_entry_id       => l_stat_entry_list(l_index),
                                 p_category_code  => p_category_code,
                                 p_cons_rule_flag => 'N' );
           END IF;
         END LOOP;*/
         FOR l_index IN l_entry_list.FIRST..l_entry_list.LAST LOOP
           IF (l_request_error_list(l_index) 	NOT IN ('COMPLETED', 'N/A')) THEN
               gcs_wf_ntf_pkg.raise_status_notification(
                                 p_cons_detail_id => l_run_detail_list(l_index));
           END IF;
         END LOOP;
       END IF;
     END IF;

     --fnd_file.put_line(fnd_file.log, 'Completed XML generation');
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.end', '<<Exit>>');
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
     BEGIN
       --fnd_file.put_line(fnd_file.log, 'Error occurred : ' || SQLERRM);
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_ENTRY_XML_GEN.EXCEPTION', '<<Error>>'||SQLERRM);
       END IF;
     END;
 END submit_entry_xml_gen;

END GCS_XML_GEN_PKG;

/
