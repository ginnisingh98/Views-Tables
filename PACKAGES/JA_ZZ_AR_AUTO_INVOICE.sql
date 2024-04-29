--------------------------------------------------------
--  DDL for Package JA_ZZ_AR_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_ZZ_AR_AUTO_INVOICE" AUTHID CURRENT_USER AS
/* $Header: jazzrais.pls 120.2 2005/10/30 01:48:13 appldev ship $ */

----------------------------------------------------------------------------
--   PUBLIC FUNCTIONS/PROCEDURES  					  --
----------------------------------------------------------------------------

FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

FUNCTION trx_num_upd(p_batch_source_id IN NUMBER
                    ,p_trx_number      IN VARCHAR2) RETURN VARCHAR2;

END ja_zz_ar_auto_invoice;

/
