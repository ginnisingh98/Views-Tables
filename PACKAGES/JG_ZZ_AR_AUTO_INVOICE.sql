--------------------------------------------------------
--  DDL for Package JG_ZZ_AR_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_AR_AUTO_INVOICE" AUTHID CURRENT_USER AS
/* $Header: jgzztnus.pls 120.1.12010000.1 2008/11/25 12:43:57 rsaini noship $ */

---------------------------------------------------------------------------
--   PUBLIC FUNCTIONS/PROCEDURES                                         --
---------------------------------------------------------------------------

   Function Is_Reg_Loc_Enabled Return Boolean;

   Procedure Trx_Num_Upd (p_request_id In Number);

   PROCEDURE val_trx_range (p_request_id IN Number, p_flag OUT NOCOPY Number);

END JG_ZZ_AR_AUTO_INVOICE;

/
