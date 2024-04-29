--------------------------------------------------------
--  DDL for Package GL_AUTOREVERSE_DATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTOREVERSE_DATE_PKG" AUTHID CURRENT_USER as
/* $Header: glustars.pls 120.5 2005/05/05 01:43:52 kvora ship $ */



-- Public Variables
   Error_Buffer                     VARCHAR2(500);

   GET_REV_PERIOD_DATE_FAILED       EXCEPTION;
   NO_DEFAULT                       EXCEPTION;

-- Public Procedures;

PROCEDURE get_reversal_period_date(X_Ledger_Id    	      NUMBER,
                                   X_Je_Category              VARCHAR2,
                                   X_Je_Source                VARCHAR2,
                                   X_Je_Period_Name           VARCHAR2,
                                   X_Je_Date                  DATE,
                                   X_Reversal_Method  IN OUT NOCOPY  VARCHAR2,
                                   X_Reversal_Period  IN OUT NOCOPY  VARCHAR2,
                                   X_Reversal_Date    IN OUT NOCOPY  DATE);

PROCEDURE get_default_reversal_data
                       (X_Category_name            VARCHAR2,
                        X_adb_lgr_flag             VARCHAR2 DEFAULT 'N',
                        X_cons_lgr_flag            VARCHAR2 DEFAULT 'N' ,
                        X_Reversal_Method_code     IN OUT NOCOPY  VARCHAR2,
                        X_Reversal_Period_code     IN OUT NOCOPY  VARCHAR2,
                        X_Reversal_Date_code       IN OUT NOCOPY  VARCHAR2);

PROCEDURE get_default_reversal_method
                       (X_Ledger_Id                NUMBER,
			X_Category_name            VARCHAR2,
                        X_Reversal_Method_code     IN OUT NOCOPY  VARCHAR2);


END GL_AUTOREVERSE_DATE_PKG;

 

/
