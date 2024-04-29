--------------------------------------------------------
--  DDL for Package RG_DSS_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_REQUESTS_PKG" AUTHID CURRENT_USER as
/* $Header: rgidreqs.pls 120.2 2003/04/29 00:47:28 djogg ship $ */
  /* Name: lock_row
   * Desc: Lock the row specified by X_Rowid.
   *
   *
   *
   */
  PROCEDURE Lock_Row(X_request_id                           NUMBER,
                     X_status_flag                          VARCHAR2
                   );


  /* Name: update_row
   * Desc: Update the row specified by X_Request_id.
   *
   *
   *
   */
  PROCEDURE Update_Row(X_request_id                         NUMBER,
                     X_status_flag                          VARCHAR2,
                     X_file_spec                            VARCHAR2,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER
                     );

  /* Name: Submit_Budget_Load
   * Desc: Submit the Upload Budget program. This is only invoked
   *       by Oracle Financial Analyzer.
   *
   *
   */
  PROCEDURE Submit_Budget_Load(X_ledger_id                       VARCHAR2,
                               X_coa_id                       VARCHAR2,
                               X_budget_name                  VARCHAR2,
                               X_budget_version               VARCHAR2,
                               X_org_name                     VARCHAR2,
                               X_org_id                       VARCHAR2);

END RG_DSS_REQUESTS_PKG;

 

/
