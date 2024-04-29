--------------------------------------------------------
--  DDL for Package INL_TAXESHOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_TAXESHOOK_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVTAHS.pls 120.0.12010000.4 2008/10/30 16:14:11 acferrei noship $ */

G_MODULE_NAME  CONSTANT VARCHAR2(200) := 'INL.PLSQL.INL_TAXESHOOK_PVT.';
G_PKG_NAME     CONSTANT VARCHAR2(30)  := 'INL_TAXESHOOK_PVT';

PROCEDURE Get_Taxes(
    x_tax_ln_tbl                   IN OUT NOCOPY inl_tax_pvt.tax_ln_tbl,
    x_override_default_processing  OUT NOCOPY  BOOLEAN,
    x_return_status                OUT NOCOPY VARCHAR2
);

END INL_TAXESHOOK_PVT;

/
