--------------------------------------------------------
--  DDL for Package Body GCS_DATASUB_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DATASUB_UTILITY_PKG" AS
 
--API Name
  g_api		VARCHAR2(50) :=	'gcs.plsql.GCS_DATASUB_UTILITY_PKG';
 
  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter    VARCHAR2(2) := '>>';
  g_module_success  VARCHAR2(2) := '<<';
  g_module_failure  VARCHAR2(2) := '<x';
 
-- Beginning of private procedures 
 
 PROCEDURE update_ytd_balances (p_load_id			IN	NUMBER, 
				    p_source_system_code	IN	NUMBER, 
				    p_dataset_code		IN	NUMBER, 
				    p_cal_period_id		IN	NUMBER, 
				    p_ledger_id			IN	NUMBER, 
				    p_currency_type		IN	VARCHAR2, 
				    p_currency_code		IN	VARCHAR2) 
 IS PRAGMA AUTONOMOUS_TRANSACTION; 
 BEGIN 
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL	<=	FND_LOG.LEVEL_PROCEDURE) THEN 
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_YTD_BALANCES.begin', '<<Enter>>' ); 
   END IF; 
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL	<=	FND_LOG.LEVEL_STATEMENT) THEN 
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_YTD_BALANCES',
            'Load Id : ' || p_load_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_YTD_BALANCES',
            'Source System : ' || p_source_system_code );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_YTD_BALANCES',
            'Dataset Code : ' || p_dataset_code );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_YTD_BALANCES',
            'Cal Period Id : ' || p_cal_period_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_YTD_BALANCES',
            'Ledger Id : ' || p_ledger_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_YTD_BALANCES',
            'Currency Type : ' || p_currency_type );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_YTD_BALANCES',
            'Currency Code : ' || p_currency_code );
 
   END IF;
 
   UPDATE gcs_bal_interface_t gbit 
   SET    (ytd_debit_balance_e, 
 	       ytd_credit_balance_e, 
	       ytd_balance_e, 
	       ytd_balance_f) = (
			SELECT fb.ytd_debit_balance_e  + NVL(gbit.ptd_debit_balance_e,0)  , 
			       fb.ytd_credit_balance_e + NVL(gbit.ptd_credit_balance_e,0) , 
			       fb.ytd_balance_e + NVL(gbit.ptd_debit_balance_e, 0) - 
				 		  NVL(gbit.ptd_credit_balance_e, 0), 
			       fb.ytd_balance_f + NVL(gbit.ptd_debit_balance_f, 0) - 
						  NVL(gbit.ptd_credit_balance_f, 0) 
			FROM   fem_balances fb 
			      ,fem_cctr_orgs_b fcob 
			      ,fem_ln_items_b  flib 
			      ,fem_cctr_orgs_b fcib 
			WHERE fb.ledger_id			=	p_ledger_id 
			AND   fb.cal_period_id			=	p_cal_period_id 
			AND   fb.dataset_code			=	p_dataset_code 
			AND   fb.source_system_code		=	p_source_system_code 
			AND   fb.currency_type_code		=	p_currency_type	
			AND   fb.currency_code			=	DECODE(p_currency_code, NULL, 
			    					        gbit.currency_code, 
		     						        p_currency_code)
			AND   fb.company_cost_center_org_id	=       fcob.company_cost_center_org_id
			AND   fcob.cctr_org_display_code	=	gbit.cctr_org_display_code
			AND   fb.line_item_id			=	flib.line_item_id
			AND   flib.line_item_display_code	=  	gbit.line_item_display_code
			AND   fb.intercompany_id		=	fcib.company_cost_center_org_id
			AND   fcib.cctr_org_display_code	=	gbit.intercompany_display_code
			)
   WHERE  load_id	=	p_load_id;
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN 
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_YTD_BALANCES.end', '<<Exit>>'); 
   END IF; 
 
   COMMIT;
   END    update_ytd_balances;
 --	
 -- 
 PROCEDURE update_ptd_balances (p_load_id			IN	NUMBER, 
				    p_source_system_code	IN	NUMBER, 
				    p_dataset_code		IN	NUMBER, 
				    p_cal_period_id		IN	NUMBER, 
				    p_ledger_id			IN	NUMBER, 
				    p_currency_type		IN	VARCHAR2, 
				    p_currency_code		IN	VARCHAR2) 
 IS PRAGMA AUTONOMOUS_TRANSACTION; 
 BEGIN 
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN 
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_PTD_BALANCES.begin',
            '<<Enter>>' ); 
   END IF; 
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_STATEMENT) THEN 
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCES',
                                          'Load Id : ' || p_load_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCES',
                                          'Source System : ' || p_source_system_code );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCES',
                                          'Dataset Code : ' || p_dataset_code );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCES',
                                          'Cal Period Id : ' || p_cal_period_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCES',
                                          'Ledger Id : ' || p_ledger_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCES',
                                          'Currency Type : ' || p_currency_type );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCES',
                                          'Currency Code : ' || p_currency_code );
 
   END IF;
 
   UPDATE gcs_bal_interface_t gbit 
   SET    (ptd_debit_balance_e, 
 	       ptd_credit_balance_e, 
	       ptd_balance_e, 
	       ptd_balance_f) = (
			SELECT gbit.ytd_debit_balance_e  - NVL(fb.ytd_debit_balance_e,0) , 
			       gbit.ytd_credit_balance_e - NVL(fb.ytd_credit_balance_e,0) , 
			       gbit.ytd_balance_e - NVL(fb.ytd_balance_e, 0), 
			       gbit.ytd_balance_f - NVL(fb.ytd_balance_f, 0) 
			FROM   fem_balances fb 
			      ,fem_cctr_orgs_b fcob 
			      ,fem_ln_items_b  flib 
			      ,fem_cctr_orgs_b fcib 
			WHERE fb.ledger_id			=	p_ledger_id 
			AND   fb.cal_period_id			=	p_cal_period_id 
			AND   fb.dataset_code			=	p_dataset_code 
			AND   fb.source_system_code		=	p_source_system_code 
			AND   fb.currency_type_code		=	p_currency_type	
			AND   fb.currency_code			=	DECODE(p_currency_code, NULL, 
			    					        gbit.currency_code, 
		     						        p_currency_code)
			AND   fb.company_cost_center_org_id	=       fcob.company_cost_center_org_id
			AND   fcob.cctr_org_display_code	=	gbit.cctr_org_display_code
			AND   fb.line_item_id			=	flib.line_item_id
			AND   flib.line_item_display_code	=  	gbit.line_item_display_code
			AND   fb.intercompany_id		=	fcib.company_cost_center_org_id
			AND   fcib.cctr_org_display_code	=	gbit.intercompany_display_code
			)
   WHERE  gbit.load_id	=	p_load_id;
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_PTD_BALANCES.end', '<<Exit>>'); 
   END IF; 
 
   COMMIT; 
   END    update_ptd_balances;
 -- 
 PROCEDURE update_ptd_balance_sheet (	p_load_id                   IN      NUMBER, 
                                		p_source_system_code        IN      NUMBER, 
                                		p_dataset_code              IN      NUMBER, 
                                		p_cal_period_id             IN      NUMBER, 
                                		p_ledger_id                 IN      NUMBER, 
                                		p_currency_type             IN      VARCHAR2, 
                                		p_currency_code             IN      VARCHAR2) 
 IS PRAGMA AUTONOMOUS_TRANSACTION; 
   	l_line_item_vs_id		NUMBER;	
	l_ledger_vs_combo_attr		NUMBER(15)	:= 
		gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO').attribute_id;
	l_ledger_vs_combo_version	NUMBER(15)	:= 
		gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO').version_id;
	l_line_item_type_attr		NUMBER(15)	:= 
	        gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id;
	l_line_item_type_version	NUMBER(15)	:= 
		gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id;
    l_acct_type_attr           	NUMBER(15)      := 
            gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id;
    l_acct_type_version        	NUMBER(15)      := 
            gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id;
 
 BEGIN 
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN 
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_PTD_BALANCE_SHEET.begin',
                                          '<<Enter>>' ); 
   END IF; 
 
   SELECT      fgvcd.value_set_id 
   INTO        l_line_item_vs_id 
   FROM        fem_ledgers_attr                fla, 
               fem_global_vs_combo_defs        fgvcd 
   WHERE	   fla.ledger_id			=	p_ledger_id 
   AND	   fgvcd.global_vs_combo_id		=	fla.dim_attribute_numeric_member 
   AND	   fla.attribute_id			= 	l_ledger_vs_combo_attr 
   AND	   fla.version_id			=	l_ledger_vs_combo_version 
   AND	   fgvcd.dimension_id			=	14; 
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_STATEMENT) THEN 
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCE_SHEET',
                                          'Load Id : ' || p_load_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCE_SHEET',
                                          'Source System : ' || p_source_system_code );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCE_SHEET',
                                          'Dataset Code : ' || p_dataset_code );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCE_SHEET',
                                          'Cal Period Id : ' || p_cal_period_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCE_SHEET',
                                          'Ledger Id : ' || p_ledger_id );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCE_SHEET',
                                          'Currency Type : ' || p_currency_type );
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_PTD_BALANCE_SHEET',
                                          'Currency Code : ' || p_currency_code );
 
   END IF;
 
   UPDATE gcs_bal_interface_t gbit 
   SET    (ptd_debit_balance_e, 
           ptd_credit_balance_e, 
           ptd_balance_e, 
           ptd_balance_f) = (
                    SELECT gbit.ytd_debit_balance_e  - NVL(fb.ytd_debit_balance_e,0) , 
                           gbit.ytd_credit_balance_e - NVL(fb.ytd_credit_balance_e,0) , 
                           gbit.ytd_balance_e - NVL(fb.ytd_balance_e, 0), 
                           gbit.ytd_balance_f - NVL(fb.ytd_balance_f, 0) 
                    FROM   fem_balances fb 
                          ,fem_cctr_orgs_b fcob 
                          ,fem_ln_items_b  flib 
                          ,fem_cctr_orgs_b fcib 
                    WHERE fb.ledger_id                      =       p_ledger_id 
                    AND   fb.cal_period_id                  =       p_cal_period_id 
                    AND   fb.dataset_code                   =       p_dataset_code 
                    AND   fb.source_system_code             =       p_source_system_code 
                    AND   fb.currency_type_code             =       p_currency_type 
                    AND   fb.currency_code                  =       DECODE(p_currency_code, NULL, 
                                                                    gbit.currency_code, 
                                                                    p_currency_code)
                    AND   fb.company_cost_center_org_id     =       fcob.company_cost_center_org_id
                    AND   fcob.cctr_org_display_code        =       gbit.cctr_org_display_code
                    AND   fb.line_item_id                   =       flib.line_item_id
                    AND   flib.line_item_display_code       =       gbit.line_item_display_code
                    AND   fb.intercompany_id                =       fcib.company_cost_center_org_id
                    AND   fcib.cctr_org_display_code        =       gbit.intercompany_display_code
                    )
   WHERE  gbit.load_id      =       p_load_id					
   AND    EXISTS	(SELECT 'X'							
   			 FROM	fem_ln_items_b 			flib,			
			        fem_ln_items_attr 		flia,			
				fem_ext_acct_types_attr      	fea_attr		
			 WHERE  gbit.line_item_display_code = flib.line_item_display_code 
			 AND    flib.line_item_id	    = flia.line_item_id		
			 AND	flib.value_set_id	    = l_line_item_vs_id		
			 AND	flib.value_set_id	    = flia.value_set_id		
			 AND	flia.attribute_id	    = l_line_item_type_attr	
			 AND	flia.version_id		    = l_line_item_type_version	
			 AND	flia.dim_attribute_varchar_member = fea_attr.ext_account_type_code 
			 AND    fea_attr.attribute_id	    = l_acct_type_attr		
			 AND    fea_attr.version_id 	    = l_acct_type_version	
			 AND	fea_attr.dim_attribute_varchar_member IN ('EQUITY',   
			  						  'ASSET',    
									  'LIABILITY'
									 )		
			);								
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_PTD_BALANCE_SHEET.end', '<<Exit>>'); 
   END IF; 
 
   COMMIT; 
   END    update_ptd_balance_sheet;
 -- 
 
 PROCEDURE validate_dimension_members(p_load_id			IN	NUMBER ) 
  IS PRAGMA AUTONOMOUS_TRANSACTION; 
   TYPE dim_vs_info_rec_type IS RECORD( 
      vs_id   NUMBER , 
      dim_display_code  VARCHAR2(50),
      dim_id_col VARCHAR2(50) , 
      dim_name  VARCHAR2(50) ); 
   TYPE t_dim_vs_info IS TABLE OF dim_vs_info_rec_type; 
   l_dim_vs_info       t_dim_vs_info; 
   l_ledger_id         NUMBER(10); 
   l_dim_id_col        VARCHAR2(50); 
   l_invalid_err_msg   VARCHAR2(2000); 
   l_null_err_msg      VARCHAR2(2000); 
  BEGIN 
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN 
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.VALIDATE_DIMENSION_MEMBERS.begin',
                                          '<<Enter>>' ); 
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.VALIDATE_DIMENSION_MEMBERS',
                                          'Load Id : ' || p_load_id );
   END IF;
 
 
   UPDATE 
   gcs_bal_interface_t 
   SET error_message_code = NULL 
   WHERE load_id = p_load_id; 
 
   SELECT fea.dim_attribute_numeric_member 
   INTO   l_ledger_id 
   FROM   fem_entities_attr fea, 
          gcs_data_sub_dtls gdsd 
   WHERE  gdsd.load_id     = p_load_id 
   AND    fea.entity_id    = gdsd.entity_id   
   AND    fea.attribute_id = gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID').attribute_id   
   AND    fea.version_id   = gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID').version_id; 
 
 
   SELECT fgvcd.value_set_id, 
       fxd.member_display_code_col, 
       fxd.member_col, 
       fdt.dimension_name 
   BULK COLLECT 
   INTO  l_dim_vs_info 
   FROM  fem_global_vs_combo_defs fgvcd,  
         fem_ledgers_attr fla,    
         fem_xdim_dimensions fxd, 
         fem_dimensions_tl  fdt 
   WHERE gcs_utility_pkg.get_fem_dim_required(fxd.MEMBER_COL) = 'Y' 
     AND global_vs_combo_id  = fla.dim_attribute_numeric_member   
     AND fla.ledger_id       = l_ledger_id  
     AND fla.attribute_id    = gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO').attribute_id 
     AND fla.version_id      = gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO').version_id 
     AND fgvcd.dimension_id  = fxd.dimension_id   
     AND fxd.member_col IN ('COMPANY_COST_CENTER_ORG_ID','FINANCIAL_ELEM_ID','PRODUCT_ID','NATURAL_ACCOUNT_ID','CHANNEL_ID', 
                           'LINE_ITEM_ID','PROJECT_ID','CUSTOMER_ID','TASK_ID','USER_DIM1_ID','USER_DIM10_ID', 
                           'USER_DIM2_ID','USER_DIM3_ID', 'USER_DIM4_ID','USER_DIM5_ID', 
                           'USER_DIM6_ID','USER_DIM7_ID','USER_DIM8_ID','USER_DIM9_ID') 
     AND fdt.dimension_id    = fxd.dimension_id 
     AND fdt.language        = userenv('LANG'); 
 
 
   IF l_dim_vs_info.FIRST IS NOT NULL THEN 
     FOR l_counter IN l_dim_vs_info.FIRST..l_dim_vs_info.LAST  LOOP 
       FND_MESSAGE.set_name( 'GCS', 'GCS_DS_DIM_INVALID_MSG' ); 
       FND_MESSAGE.set_token('DIM_NAME', l_dim_vs_info(l_counter).dim_name) ; 
       l_invalid_err_msg := FND_MESSAGE.get ;
 
       FND_MESSAGE.set_name( 'GCS', 'GCS_DS_DIM_NULL_MSG' ); 
       FND_MESSAGE.set_token('COLUMN_NAME', l_dim_vs_info(l_counter).dim_display_code) ; 
       l_null_err_msg := FND_MESSAGE.get ; 
       l_dim_id_col := l_dim_vs_info(l_counter).dim_id_col ; 
 
       IF ( l_dim_id_col = 'COMPANY_COST_CENTER_ORG_ID' ) THEN 
          UPDATE gcs_bal_interface_t gbit 
          SET   error_message_code = error_message_code 
                || DECODE (  cctr_org_display_code, NULL , l_null_err_msg , 
                l_invalid_err_msg  || '(' || cctr_org_display_code || ').' )
           WHERE  load_id             = p_load_id  
           AND    NOT EXISTS (SELECT 'X'  
                              FROM   fem_cctr_orgs_b fcob   
                              WHERE  fcob.cctr_org_display_code =  gbit.cctr_org_display_code  
                              AND    fcob.value_set_id = l_dim_vs_info(l_counter).vs_id ) ;   
       ELSIF ( l_dim_id_col = 'FINANCIAL_ELEM_ID' ) THEN 
          UPDATE gcs_bal_interface_t gbit 
          SET    error_message_code = error_message_code 
                 || DECODE (  financial_elem_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || financial_elem_display_code || ').' )
          WHERE  load_id             = p_load_id  
          AND    NOT EXISTS (SELECT 'X'  
                             FROM   fem_fin_elems_b ffeb  
                             WHERE  ffeb.financial_elem_display_code =  gbit.financial_elem_display_code  
                             AND    ffeb.value_set_id =  l_dim_vs_info(l_counter).vs_id ) ; 
       ELSIF ( l_dim_id_col = 'LINE_ITEM_ID'  ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  line_item_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || line_item_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_ln_items_b flib  
                             WHERE  flib.line_item_display_code =  gbit.line_item_display_code  
                             AND    flib.value_set_id =  l_dim_vs_info(l_counter).vs_id ) ;  
       ELSIF (  l_dim_id_col = 'PRODUCT_ID') THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  product_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || product_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                              FROM   fem_products_b fpb  
                              WHERE  fpb.product_display_code =  gbit.product_display_code  
                              AND    fpb.value_set_id = l_dim_vs_info(l_counter).vs_id ) ; 
      ELSIF (  l_dim_id_col = 'NATURAL_ACCOUNT_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  natural_account_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || natural_account_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_nat_accts_b fnab  
                             WHERE  fnab.natural_account_display_code =  gbit.natural_account_display_code  
                             AND    fnab.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
       ELSIF (  l_dim_id_col = 'CHANNEL_ID') THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  channel_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || channel_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_channels_b fcb  
                             WHERE  fcb.channel_display_code =  gbit.channel_display_code  
                             AND    fcb.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
       ELSIF ( l_dim_id_col = 'PROJECT_ID') THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  project_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || project_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_projects_b fpb  
                             WHERE  fpb.project_display_code =  gbit.project_display_code  
                             AND    fpb.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
       ELSIF ( l_dim_id_col = 'CUSTOMER_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  customer_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || customer_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_customers_b fcb  
                             WHERE  fcb.customer_display_code =  gbit.customer_display_code  
                             AND    fcb.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
      ELSIF ( l_dim_id_col = 'TASK_ID') THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  task_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || task_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_tasks_b ftb  
                             WHERE  ftb.task_display_code =  gbit.task_display_code  
                             AND    ftb.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
      ELSIF ( l_dim_id_col =  'USER_DIM1_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  user_dim1_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || user_dim1_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_user_dim1_b fub  
                             WHERE  fub.user_dim1_display_code =  gbit.user_dim1_display_code  
                             AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
      ELSIF ( l_dim_id_col =  'USER_DIM2_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  user_dim2_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || user_dim2_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_user_dim2_b fub  
                             WHERE  fub.user_dim2_display_code =  gbit.user_dim2_display_code  
                             AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
      ELSIF ( l_dim_id_col =  'USER_DIM3_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  user_dim3_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || user_dim3_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_user_dim3_b fub  
                             WHERE  fub.user_dim3_display_code =  gbit.user_dim3_display_code  
                             AND    fub.value_set_id =l_dim_vs_info(l_counter).vs_id ) ; 
       ELSIF ( l_dim_id_col =  'USER_DIM4_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  user_dim4_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || user_dim4_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                             FROM   fem_user_dim4_b fub  
                             WHERE  fub.user_dim4_display_code =  gbit.user_dim4_display_code  
                             AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
       ELSIF ( l_dim_id_col =  'USER_DIM5_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET   error_message_code = error_message_code 
                 || DECODE (  user_dim5_display_code, NULL , l_null_err_msg , 
                 l_invalid_err_msg  || '(' || user_dim5_display_code || ').' )
           WHERE load_id             = p_load_id  
           AND   NOT EXISTS (SELECT 'X'  
                                 FROM   fem_user_dim5_b fub  
                                 WHERE  fub.user_dim5_display_code =  gbit.user_dim5_display_code  
                                 AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
       ELSIF ( l_dim_id_col =  'USER_DIM6_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET    error_message_code = error_message_code 
                  || DECODE (  user_dim6_display_code, NULL , l_null_err_msg , 
                  l_invalid_err_msg  || '(' || user_dim6_display_code || ').' )
           WHERE  load_id             = p_load_id  
           AND    NOT EXISTS (SELECT 'X'  
                              FROM   fem_user_dim6_b fub  
                              WHERE  fub.user_dim6_display_code =  gbit.user_dim6_display_code  
                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
      ELSIF ( l_dim_id_col =  'USER_DIM7_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET    error_message_code = error_message_code 
                  || DECODE (  user_dim7_display_code, NULL , l_null_err_msg , 
                  l_invalid_err_msg  || '(' || user_dim7_display_code || ').' )
           WHERE  load_id             = p_load_id  
           AND    NOT EXISTS (SELECT 'X'  
                              FROM   fem_user_dim7_b fub  
                              WHERE  fub.user_dim7_display_code =  gbit.user_dim7_display_code  
                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id ) ; 
       ELSIF ( l_dim_id_col =  'USER_DIM8_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET    error_message_code = error_message_code 
                  || DECODE (  user_dim8_display_code, NULL , l_null_err_msg , 
                  l_invalid_err_msg  || '(' || user_dim8_display_code || ').' )
           WHERE  load_id             = p_load_id  
           AND    NOT EXISTS (SELECT 'X'  
                              FROM   fem_user_dim8_b fub  
                              WHERE  fub.user_dim8_display_code =  gbit.user_dim8_display_code  
                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
       ELSIF ( l_dim_id_col =  'USER_DIM9_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET    error_message_code = error_message_code 
                  || DECODE (  user_dim9_display_code, NULL , l_null_err_msg , 
                  l_invalid_err_msg  || '(' || user_dim9_display_code || ').' )
           WHERE  load_id             = p_load_id  
           AND    NOT EXISTS (SELECT 'X'  
                              FROM   fem_user_dim9_b fub  
                              WHERE  fub.user_dim9_display_code =  gbit.user_dim9_display_code  
                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
       ELSIF ( l_dim_id_col =  'USER_DIM10_ID' ) THEN 
           UPDATE gcs_bal_interface_t gbit 
           SET    error_message_code = error_message_code 
                  || DECODE (  user_dim10_display_code, NULL , l_null_err_msg , 
                  l_invalid_err_msg  || '(' || user_dim10_display_code || ').' )
           WHERE  load_id             = p_load_id  
           AND    NOT EXISTS (SELECT 'X'  
                              FROM   fem_user_dim10_b fub  
                              WHERE  fub.user_dim10_display_code =  gbit.user_dim10_display_code  
                              AND    fub.value_set_id = l_dim_vs_info(l_counter).vs_id  ) ; 
       END IF;  
     END LOOP; 
   END IF;  
 
   COMMIT; 
 
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL      <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.VALIDATE_DIMENSION_MEMBERS.end', '<<Exit>>'); 
   END IF; 
 
 END validate_dimension_members; 
 -- 
 
END GCS_DATASUB_UTILITY_PKG; 

/
