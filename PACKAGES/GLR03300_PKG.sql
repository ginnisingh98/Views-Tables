--------------------------------------------------------
--  DDL for Package GLR03300_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GLR03300_PKG" AUTHID CURRENT_USER AS
/* $Header: gl03300s.pls 120.7 2005/05/05 02:01:14 kvora ship $ */
--
-- Package
--   GLR03300_pkg
-- Purpose
--   To contain database functions needed in Account Inquiry form
-- History
--   09-01-94   Kai Pigg	Created

--
-- PUBLIC VARIABLES
--
	code_combination_id		NUMBER;
	budget_version_id		NUMBER;
	encumbrance_type_id		NUMBER;
	template_id			NUMBER;
	factor				NUMBER;
	currency_code			VARCHAR2(30);
	translated_flag			VARCHAR2(1);
	balance_type			VARCHAR2(1);
	currency_type			VARCHAR2(1);
	actual_flag			VARCHAR2(1);
	sec_actual_flag			VARCHAR2(1);
	sec_budget_version_id		NUMBER;
	sec_encumbrance_type_id		NUMBER;
	ledger_id			NUMBER;
	period_name			VARCHAR2(15);
	ar_code_combination_id		NUMBER;
        ledger_currency                 VARCHAR2(30);

--
-- PUBLIC PROCEDURES
--

  --
  -- Procedure
  -- set_criteria
  --  PURPOSE sets ALL (non-secondary) the package (global) variables
  -- History: 09-02-94 Kai Pigg Created
  -- Arguments: All the global values of this package
  -- Notes:
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
                                X_ledger_currency               VARCHAR2);
  --
  -- Procedure
  -- set_sec_criteria
  --  PURPOSE sets ALL the package (global) variables
  -- History: 09-05-94 Kai Pigg Created
  -- Arguments: All the global values of this package
  -- Notes:
    	PROCEDURE set_sec_criteria (X_code_combination_id     		NUMBER,
        			X_budget_version_id       		NUMBER,
        			X_encumbrance_type_id     		NUMBER,
        			X_template_id             		NUMBER,
        			X_factor                  		NUMBER,
        			X_currency_code           		VARCHAR2,
        			X_translated_flag         		VARCHAR2,
        			X_balance_type            		VARCHAR2,
        			X_currency_type         		VARCHAR2,
        			X_actual_flag             		VARCHAR2,
        			X_sec_actual_flag   			VARCHAR2,
        			X_sec_budget_version_id       		NUMBER,
        			X_sec_encumbrance_type_id     		NUMBER,
				X_ledger_id				NUMBER,
				X_period_name				VARCHAR2,
                                X_ledger_currency                       VARCHAR2);
  --
  -- Procedure
  -- set_ledger_id
  --  PURPOSE sets the ledger_id
  -- History: 09-12-94 Kai Pigg Created
  --          05-feb-03 vchikkar renamed
  -- Arguments: ledger_id
  -- Notes:
    	PROCEDURE set_ledger_id (X_ledger_id NUMBER);

  --
  -- Procedure
  -- set_ar_cc
  --  PURPOSE sets the code_combination_id for ar drill down
  -- History: 01-20-9 Kai Pigg Created
  -- Arguments: code_combination_id
  -- Notes:
    	PROCEDURE set_ar_cc (X_ar_code_combination_id NUMBER);



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
  --         This procedure is called in post query trigger of JOURNALS block at  GLXIQACC.fmb

    	PROCEDURE populate_fields (X_header_id IN NUMBER ,
	                           X_user_je_source_name OUT NOCOPY VARCHAR2,
				   X_user_je_category_name OUT NOCOPY VARCHAR2 ,
				   X_encumbrance_type OUT NOCOPY VARCHAR2 ,
				   X_budget_name OUT NOCOPY VARCHAR2 ,
				   X_show_batch_status OUT NOCOPY VARCHAR2 ,
				   X_show_bc_status OUT NOCOPY VARCHAR2 );

  --
  -- Procedure
  --  get_ar_cc
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  01-20-95  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_ar_cc	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_ar_cc,WNDS,WNPS);

--
-- PUBLIC FUNCTIONS
--
  --
  -- Procedure
  --  get_code_combination_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-01-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_code_combination_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_code_combination_id,WNDS,WNPS);

  --
  -- Procedure
  --  get_budget_version_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-01-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_budget_version_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_budget_version_id,WNDS,WNPS);
  --
  -- Procedure
  --  get_encumbrance_type_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-01-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_encumbrance_type_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_encumbrance_type_id,WNDS,WNPS);
  --
  -- Procedure
  --  get_template_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-01-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_template_id		RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_template_id,WNDS,WNPS);
  --
  -- Procedure
  --  get_entered_currency_code
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-01-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_entered_currency_code	RETURN VARCHAR2;
	PRAGMA 		RESTRICT_REFERENCES(get_entered_currency_code,WNDS,WNPS);
  --
  -- Procedure
  --  get_translated_flag
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-01-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_translated_flag	RETURN VARCHAR2;
	PRAGMA 		RESTRICT_REFERENCES(get_translated_flag,WNDS,WNPS);
  --
  -- Procedure
  --  get_balance_type
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-01-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_balance_type	RETURN VARCHAR2;
	PRAGMA 		RESTRICT_REFERENCES(get_balance_type,WNDS,WNPS);
  --
  -- Procedure
  --  get_factor
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-01-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_factor		RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_factor,WNDS,WNPS);

  --
  -- Procedure
  --  get_currency_type
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-02-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_currency_type RETURN VARCHAR2;
	PRAGMA 		RESTRICT_REFERENCES(get_currency_type,WNDS,WNPS);
  --
  -- Procedure
  --  get_actual_flag
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-02-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_actual_flag RETURN VARCHAR2;
	PRAGMA 		RESTRICT_REFERENCES(get_actual_flag,WNDS,WNPS);

  --
  -- Procedure
  --  get_sec_actual_flag
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-05-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_sec_actual_flag RETURN VARCHAR2;
	PRAGMA 		RESTRICT_REFERENCES(get_sec_actual_flag,WNDS,WNPS);
  --
  -- Procedure
  --  get_sec_budget_version_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-05-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_sec_budget_version_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_sec_budget_version_id,WNDS,WNPS);
  --
  -- Procedure
  --  get_sec_encumbrance_type_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-05-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_sec_encumbrance_type_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_sec_encumbrance_type_id,WNDS,WNPS);

  --
  -- Procedure
  --  get_functional_currency_code
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-07-94  Kai Pigg Created
  -- Notes
  --
--	FUNCTION	get_functional_currency_code	RETURN VARCHAR2;
--	PRAGMA 		RESTRICT_REFERENCES(get_functional_currency_code,WNDS,WNPS);

  --
  -- Procedure
  --  get_ledger_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-07-94  Kai Pigg Created
  --           28-jan-03 vchikkar renamed
  -- Notes
  --
	FUNCTION	get_ledger_id		RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_ledger_id,WNDS,WNPS);

  --
  -- Procedure
  --  get_period_name
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-07-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_period_name		RETURN VARCHAR2;
	PRAGMA 		RESTRICT_REFERENCES(get_period_name,WNDS,WNPS);

  --
  -- Procedure
  --  get_ledger_currency
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History:  09-07-94  Kai Pigg Created
  -- Notes
  --
	FUNCTION	get_ledger_currency		RETURN VARCHAR2;
	PRAGMA 		RESTRICT_REFERENCES(get_ledger_currency,WNDS,WNPS);


END GLR03300_PKG;

 

/
