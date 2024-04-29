--------------------------------------------------------
--  DDL for Package JA_TH_AR_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_TH_AR_AUTO_INVOICE" AUTHID CURRENT_USER AS
/* $Header: jathrais.pls 120.2 2005/10/30 01:47:56 appldev ship $ */

FUNCTION validate_tax_invoice(p_request_id  IN NUMBER) RETURN NUMBER;

END ja_th_ar_auto_invoice;

/
