--------------------------------------------------------
--  DDL for Package Body INL_TAXESHOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_TAXESHOOK_PVT" AS
/* $Header: INLVTAHB.pls 120.0.12010000.5 2008/10/30 16:11:43 acferrei noship $ */

-- Utility name : Get_Taxes
-- Type       : Private
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN OUT     : inl_etax_pvt_ac.tax_ln_rec
--
-- OUT        : x_override_default_processing  OUT BOOLEAN
--              x_return_status                OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_Taxes(
    x_tax_ln_tbl                   IN OUT NOCOPY inl_tax_pvt.tax_ln_tbl,
    x_override_default_processing  OUT NOCOPY  BOOLEAN,
    x_return_status                OUT NOCOPY VARCHAR2
) IS
BEGIN
    x_override_default_processing := FALSE;
    RETURN;
END Get_Taxes;

END INL_TAXESHOOK_PVT;

/
