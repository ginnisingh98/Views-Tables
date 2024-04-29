--------------------------------------------------------
--  DDL for Package JA_TW_AR_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_TW_AR_AUTO_INVOICE" AUTHID CURRENT_USER AS
/* $Header: jatwrais.pls 120.1 2004/11/04 21:42:34 thwon ship $ */

---------------------------------------------------------------------------
--   PUBLIC FUNCTIONS/PROCEDURES                                         --
---------------------------------------------------------------------------

FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

FUNCTION trx_num_upd(p_batch_source_id IN NUMBER
                    ,p_trx_number      IN VARCHAR2) RETURN VARCHAR2;

END ja_tw_ar_auto_invoice;

 

/
