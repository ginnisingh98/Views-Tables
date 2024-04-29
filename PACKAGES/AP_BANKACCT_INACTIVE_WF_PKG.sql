--------------------------------------------------------
--  DDL for Package AP_BANKACCT_INACTIVE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_BANKACCT_INACTIVE_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: apbainws.pls 120.0 2005/07/02 00:55:25 bghose noship $ */

  FUNCTION Rule_Function  (P_Subscription  IN RAW,
                           P_Event         IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2;

  FUNCTION Update_Payment_Schedules (
          P_bank_account_id       NUMBER,
          P_party_id              NUMBER,
          P_instr_assgn_id        NUMBER,
          P_calling_sequence      VARCHAR2) RETURN BOOLEAN;


END AP_BANKACCT_INACTIVE_WF_PKG;

 

/
