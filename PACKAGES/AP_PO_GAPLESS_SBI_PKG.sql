--------------------------------------------------------
--  DDL for Package AP_PO_GAPLESS_SBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PO_GAPLESS_SBI_PKG" AUTHID CURRENT_USER AS
/* $Header: apposbis.pls 120.0 2006/01/11 06:33:46 vdesu noship $ */

function this_is_dup_inv_num(
    p_invoice_num                   IN VARCHAR2,
    p_selling_co_id                 IN VARCHAR2)

RETURN BOOLEAN;

PROCEDURE site_uses_gapless_num(
    p_site_id                       IN NUMBER,
    x_gapless_inv_num_flag          OUT NOCOPY VARCHAR2,
    x_selling_company_id            OUT NOCOPY VARCHAR2);

END AP_PO_GAPLESS_SBI_PKG;

 

/
