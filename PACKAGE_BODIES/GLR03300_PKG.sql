--------------------------------------------------------
--  DDL for Package Body GLR03300_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GLR03300_PKG" AS
/* $Header: gl03300b.pls 120.8 2005/05/05 02:01:07 kvora ship $ */
        PROCEDURE set_criteria (X_code_combination_id     	NUMBER,
                                X_budget_version_id       	NUMBER,
                                X_encumbrance_type_id     	NUMBER,
                                X_template_id             	NUMBER,
                                X_factor                  	NUMBER,
                                X_currency_code           	VARCHAR2,
                                X_translated_flag         	VARCHAR2,
                                X_balance_type            	VARCHAR2,
                                X_currency_type         	VARCHAR2,
                                X_actual_flag             	VARCHAR2,
				X_ledger_id			NUMBER,
				X_period_name			VARCHAR2,
                                X_ledger_currency               VARCHAR2) IS
	BEGIN
        	GLR03300_PKG.code_combination_id 	:= X_code_combination_id;
                GLR03300_PKG.budget_version_id		:= X_budget_version_id;
                GLR03300_PKG.encumbrance_type_id 	:= X_encumbrance_type_id;
                GLR03300_PKG.template_id 		:= X_template_id;
                GLR03300_PKG.factor 			:= X_factor;
                GLR03300_PKG.currency_code 		:= X_currency_code;
                GLR03300_PKG.translated_flag 		:= X_translated_flag;
                GLR03300_PKG.balance_type 		:= X_balance_type;
                GLR03300_PKG.currency_type 		:= X_currency_type;
                GLR03300_PKG.actual_flag 		:= X_actual_flag;
		GLR03300_PKG.ledger_id			:= X_ledger_id;
		GLR03300_PKG.period_name		:= X_period_name;
                GLR03300_PKG.ledger_currency            := X_ledger_currency;
	END set_criteria;

	PROCEDURE set_sec_criteria (X_code_combination_id     		NUMBER,
                                X_budget_version_id       		NUMBER,
                                X_encumbrance_type_id     		NUMBER,
                                X_template_id             		NUMBER,
                                X_factor                  		NUMBER,
                                X_currency_code           		VARCHAR2,
                                X_translated_flag         		VARCHAR2,
                                X_balance_type            		VARCHAR2,
                                X_currency_type          		VARCHAR2,
                                X_actual_flag             		VARCHAR2,
				X_sec_actual_flag  			VARCHAR2,
				X_sec_budget_version_id 		NUMBER,
				X_sec_encumbrance_type_id 		NUMBER,
				X_ledger_id				NUMBER,
				X_period_name				VARCHAR2,
                                X_ledger_currency                       VARCHAR2) IS
	BEGIN
        	GLR03300_PKG.code_combination_id 		:= X_code_combination_id;
                GLR03300_PKG.budget_version_id 			:= X_budget_version_id;
                GLR03300_PKG.encumbrance_type_id 		:= X_encumbrance_type_id;
                GLR03300_PKG.template_id 			:= X_template_id;
                GLR03300_PKG.factor 				:= X_factor;
                GLR03300_PKG.currency_code 			:= X_currency_code;
                GLR03300_PKG.translated_flag 			:= X_translated_flag;
                GLR03300_PKG.balance_type 			:= X_balance_type;
                GLR03300_PKG.currency_type 			:= X_currency_type;
                GLR03300_PKG.actual_flag 			:= X_actual_flag;
                GLR03300_PKG.sec_actual_flag 			:= X_sec_actual_flag;
                GLR03300_PKG.sec_budget_version_id 		:= X_sec_budget_version_id;
                GLR03300_PKG.sec_encumbrance_type_id 		:= X_sec_encumbrance_type_id;
		GLR03300_PKG.ledger_id				:= X_ledger_id;
		GLR03300_PKG.period_name			:= X_period_name;
                GLR03300_PKG.ledger_currency            := X_ledger_currency;
	END set_sec_criteria;

	PROCEDURE set_ledger_id ( X_ledger_id    	NUMBER) IS
	BEGIN
        	GLR03300_PKG.ledger_id := X_ledger_id;
	END set_ledger_id;

	PROCEDURE set_ar_cc ( X_ar_code_combination_id    	NUMBER) IS
	BEGIN
        	GLR03300_PKG.ar_code_combination_id := X_ar_code_combination_id;
	END set_ar_cc;


        -- Procedure
        -- populate_fields
        --  PURPOSE Populates the USER_JE_SOURCE_NAME,USER_JE_CATEGORY ,ENCUMBRANCE_TYPE ,
        --  BUDGET_NAME ,SHOW_BATCH_STATUS , SHOW_BC_STATUS
        -- History: 16-sep-2002 KAKRISHN Created
        -- Arguments: X_header_id IN ,
        --            X_user_je_source_name OUT NOCOPY VARCHAR2,
        --  	        X_user_je_category_name OUT NOCOPY VARCHAR2 ,
        --	        X_encumbrance_type OUT NOCOPY VARCHAR2 ,
        --            X_budget_name OUT NOCOPY VARCHAR2
        --  	        X_show_batch_status OUT NOCOPY VARCHAR2 ,
        --	        X_show_bc_status OUT NOCOPY VARCHAR2

        -- Notes:
        --         This procedure is called in post query trigger of JOURNALS block at GLXIQACC.fmb-- bug fix 2519486

    	PROCEDURE populate_fields (X_header_id IN NUMBER ,
	                           X_user_je_source_name OUT NOCOPY VARCHAR2,
				   X_user_je_category_name OUT NOCOPY VARCHAR2 ,
				   X_encumbrance_type OUT NOCOPY VARCHAR2 ,
				   X_budget_name OUT NOCOPY VARCHAR2,
				   X_show_batch_status OUT NOCOPY VARCHAR2 ,
				   X_show_bc_status OUT NOCOPY VARCHAR2 ) IS

        CURSOR c_header (lv_header_id gl_je_headers.je_header_id%type ) IS
        SELECT  je_header_id,je_source,je_category,encumbrance_type_id,
        budget_version_id,currency_conversion_type , je_batch_id
        FROM gl_je_headers
        WHERE je_header_id=lv_header_id ;

	CURSOR  c_user_source_name (lv_gl_je_source gl_je_headers.je_source%type ) IS
        SELECT  user_je_source_name
        FROM gl_je_sources
        WHERE je_source_name= lv_gl_je_source ;

        CURSOR  c_user_category_name (lv_gl_je_category gl_je_headers.je_category%type ) IS
        SELECT  user_je_category_name
        FROM gl_je_categories
        WHERE je_category_name= lv_gl_je_category ;

        CURSOR  c_encumb_type (lv_encumb_type_id gl_je_headers.encumbrance_type_id%type ) IS
        SELECT  encumbrance_type
        FROM gl_encumbrance_types
        WHERE encumbrance_type_id= lv_encumb_type_id ;

        CURSOR  c_bud_ver (lv_bud_ver_id gl_je_headers.budget_version_id%type ) IS
        SELECT  budget_name
        FROM gl_budget_versions
        WHERE budget_version_id= lv_bud_ver_id ;

        CURSOR  c_curr_conv (lv_curr_conv_type gl_je_headers.currency_conversion_type%type ) IS
        SELECT  user_conversion_type
        FROM gl_daily_conversion_types
        WHERE conversion_type = lv_curr_conv_type ;

        CURSOR  c_show_batch_stat (lv_je_header_id gl_je_headers.je_header_id%type ,
                                   lv_status gl_je_batches.status%type ) IS
        SELECT  description
        FROM gl_lookups
        WHERE lookup_type=decode ( lv_je_header_id,NULL,NULL,'MJE_BATCH_STATUS')
        AND lookup_code=substr( lv_status , 1 , 1);


        CURSOR  c_show_bc_stat (lv_je_header_id gl_je_headers.je_header_id%type ,
                                lv_status gl_je_batches.budgetary_control_status%type ) IS
        SELECT  meaning
        FROM gl_lookups
        WHERE lookup_type=decode ( lv_je_header_id,NULL,NULL,'JE_BATCH_BC_STATUS')
        AND lookup_code= lv_status ;

        CURSOR c1 (lv_je_batch_id gl_je_headers.je_batch_id%type  ) IS
        select status,budgetary_control_status from  gl_je_batches where
        je_batch_id=lv_je_batch_id ;


        lv_header c_header%rowtype;
        lv_status c1%rowtype;

        BEGIN


             --To Get the value of header columns

	    OPEN  c_header (X_header_id);
	    FETCH c_header into lv_header;
	    CLOSE c_header;

             --To populate User Source Name
	    OPEN c_user_source_name ( lv_header.je_source);
	    FETCH c_user_source_name INTO X_user_je_source_name;
	    CLOSE c_user_source_name ;


             --To populate Category Name
 	    OPEN c_user_category_name ( lv_header.je_category);
	    FETCH c_user_category_name INTO X_user_je_category_name;
	    CLOSE c_user_category_name ;


	    --To popualte encumbrance type
	    OPEN c_encumb_type ( lv_header.encumbrance_type_id);
	    FETCH c_encumb_type INTO X_encumbrance_type;
	    CLOSE  c_encumb_type;

	    --To popualte budget version
    	    OPEN  c_bud_ver ( lv_header.budget_version_id);
            FETCH  c_bud_ver INTO X_budget_name;
            CLOSE  c_bud_ver;


	    --To populate SHOW BATCH STATUS
	    OPEN  c1 ( lv_header.je_batch_id);
	    FETCH  c1 INTO lv_status;
	    CLOSE  c1;

	    OPEN c_show_batch_stat ( lv_header.JE_header_id ,lv_status.status );
	    FETCH c_show_batch_stat into X_show_batch_status;
	    CLOSE c_show_batch_stat;

	    OPEN c_show_bc_stat ( lv_header.JE_header_id ,lv_status.budgetary_control_status );
	    FETCH c_show_bc_stat into X_show_bc_status;
	    CLOSE c_show_bc_stat;

        END populate_fields;

	FUNCTION	get_ar_cc	RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.ar_code_combination_id;
        END get_ar_cc;
--
-- PUBLIC FUNCTIONS
--
	FUNCTION	get_code_combination_id	RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.code_combination_id;
        END get_code_combination_id;

	FUNCTION	get_budget_version_id	RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.budget_version_id;
        END get_budget_version_id;

	FUNCTION	get_encumbrance_type_id	RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.encumbrance_type_id;
        END get_encumbrance_type_id;

	FUNCTION	get_template_id		RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.template_id;
        END get_template_id;

	FUNCTION	get_entered_currency_code	RETURN VARCHAR2 IS
        BEGIN
                RETURN GLR03300_pkg.currency_code;
        END get_entered_currency_code;

	FUNCTION	get_translated_flag	RETURN VARCHAR2 IS
        BEGIN
                RETURN GLR03300_pkg.translated_flag;
        END get_translated_flag;

	FUNCTION	get_balance_type	RETURN VARCHAR2 IS
        BEGIN
                RETURN GLR03300_pkg.balance_type;
        END get_balance_type;

	FUNCTION	get_factor		RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.factor;
        END get_factor;

	FUNCTION	get_currency_type RETURN VARCHAR2 IS
        BEGIN
                RETURN GLR03300_pkg.currency_type;
        END get_currency_type;

	FUNCTION	get_actual_flag RETURN VARCHAR2 IS
        BEGIN
                RETURN GLR03300_pkg.actual_flag;
        END get_actual_flag;

	FUNCTION	get_sec_actual_flag RETURN VARCHAR2 IS
        BEGIN
                RETURN GLR03300_pkg.sec_actual_flag;
        END get_sec_actual_flag;

	FUNCTION	get_sec_budget_version_id	RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.sec_budget_version_id;
        END get_sec_budget_version_id;

	FUNCTION	get_sec_encumbrance_type_id	RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.sec_encumbrance_type_id;
        END get_sec_encumbrance_type_id;

--	FUNCTION	get_functional_currency_code RETURN VARCHAR2 IS
--        BEGIN
--                RETURN GLR03300_pkg.functional_currency_code;
--        END get_functional_currency_code;

	FUNCTION	get_ledger_id RETURN NUMBER IS
        BEGIN
                RETURN GLR03300_pkg.ledger_id;
        END get_ledger_id;

	FUNCTION	get_period_name  RETURN VARCHAR2 IS
        BEGIN
                RETURN GLR03300_pkg.period_name;
        END get_period_name;

	FUNCTION	get_ledger_currency  RETURN VARCHAR2 IS
        BEGIN
                RETURN GLR03300_pkg.ledger_currency;
        END get_ledger_currency;

END GLR03300_PKG;

/
