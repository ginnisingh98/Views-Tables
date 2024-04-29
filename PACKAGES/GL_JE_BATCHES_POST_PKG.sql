--------------------------------------------------------
--  DDL for Package GL_JE_BATCHES_POST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_BATCHES_POST_PKG" AUTHID CURRENT_USER as
/* $Header: glijebps.pls 120.4 2005/05/05 00:38:48 kvora ship $ */


  -- PUBLIC VARIABLES
     access_set_id      NUMBER;

  --
  -- Procedure
  --   set_access_set_id
  -- Purpose
  --   Sets the access_set_id
  -- Arguments
  --   access_set_id
  -- Example
  --   gl_je_batches_post_pkg.set_access_set_id(221);
  -- Notes
  --
  PROCEDURE set_access_set_id(X_access_set_id NUMBER);

   --
  -- Procedure
  --   get_access_set_id
  -- Purpose
  --   Gets the package (global) variable
  -- History:  09-21-96  Rashmi Goyal Created
  -- Example
  --   l_access_set_id := gl_je_batches_post_pkg.get_access_set_id;
  -- Notes
  --
  FUNCTION get_access_set_id RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(get_access_set_id,WNDS,WNPS);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique posting_run_id
  -- Arguments
  --   * None *
  -- Example
  --   :WORLD.posting_run_id := gl_je_batches_post_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   check_budget_status
  -- Purpose
  --   Checks whether budget batch contains journals with budget that
  --   is frozen or in unopened budget year
  --   Returns:
  --	 BF	With frozen budget
  --	 BU	With unopened budget year
  --	 OK	Neither
  -- Arguments
  --   je_batch_id		JE batch id
  --   period_year		Period year of batch
  -- Example
  --   status := gl_je_batches_post_pkg.check_budget_status(
  --		   :BATCHES.je_batch_id, :BATCHES.period_year );
  -- Notes
  --
  FUNCTION check_budget_status( X_je_batch_id   NUMBER,
				X_period_year   NUMBER ) RETURN VARCHAR2;

  --
  -- Procedure
  --   check_unbal_monetary_headers
  -- Purpose
  --   Checks if there are any unbalanced monetary headers in the
  --   specified batch.
  --   It is okay to have STAT headers that are not balanced.
  --   Returns:
  --	 TRUE   Batch is unbalanced
  --	 FALSE  Batch is balanced
  -- Arguments
  --   je_batch_id		JE batch id
  -- Example
  --   status := gl_je_batches_post_pkg.check_unbal_monetary_headers(
  --		   :BATCHES.je_batch_id );
  -- Notes
  --   For bug #394393:
  --   This function replaces the function gl_je_batches_pkg.all_stat_headers
  --   to check for an out of balance condition.

  FUNCTION check_unbal_monetary_headers( X_je_batch_id NUMBER ) RETURN BOOLEAN;

  --
  -- Procedure
  --   check_untax_monetary_headers
  -- Purpose
  --   Checks if there are any untaxed monetary headers in the specified batch.
  --   It is okay to have STAT headers that are not taxed.
  --   Returns:
  --	 TRUE   Batch is untaxed  ( tax_status_code = 'R' in any headers )
  --	 FALSE  Batch is taxed
  -- Arguments
  --   je_batch_id		JE batch id
  -- Example
  --   status := gl_je_batches_post_pkg.check_untax_monetary_headers(
  --		   :BATCHES.je_batch_id );
  -- Notes
  FUNCTION check_untax_monetary_headers( X_je_batch_id NUMBER ) RETURN BOOLEAN;


PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Je_Batch_Id                            NUMBER,
                   X_Chart_Of_Accounts_Id                   NUMBER,
                   X_Name                                   VARCHAR2,
                   X_Status                                 VARCHAR2,
                   X_Status_Verified                        VARCHAR2,
                   X_Actual_Flag                            VARCHAR2,
                   X_Budgetary_Control_Status               VARCHAR2,
                   X_Default_Period_Name                    VARCHAR2,
                   X_Control_Total                          NUMBER,
                   X_Running_Total_Dr                       NUMBER,
                   X_Running_Total_Cr                       NUMBER,
                   X_Posting_Run_Id                         NUMBER,
                   X_Request_Id 	                    NUMBER
                  );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Name                                VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Status_Verified                     VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Budgetary_Control_Status            VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Default_Period_Name                 VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Posting_Run_Id                      NUMBER,
                     X_Request_Id 	                   NUMBER
                     );


END GL_JE_BATCHES_POST_PKG;

 

/
