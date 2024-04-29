--------------------------------------------------------
--  DDL for Package GMS_PA_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_PA_API2" AUTHID CURRENT_USER AS
/* $Header: gmspax2s.pls 120.1 2007/02/06 09:52:06 rshaik ship $ */

     -- -----------------------------------
     -- Function to check the award status
     -- -----------------------------------
      FUNCTION IS_AWARD_CLOSED(x_expenditure_item_id IN NUMBER ,x_task_id IN NUMBER ,x_doc_type in varchar2 default 'EXP') return VARCHAR2 ; --5726575

      -- ====================================================
      -- BUG: 2733355 is_grants_enabled function was added.
      -- ====================================================
      -- Return value : Y - Grants enabled.
      --                N - Grants not enabled.

      function is_grants_enabled return varchar2 ;

END gms_pa_api2;

/
