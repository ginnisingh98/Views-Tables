--------------------------------------------------------
--  DDL for Package INL_CHARGESHOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_CHARGESHOOK_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVCHHS.pls 120.3.12010000.1 2008/09/25 07:34:08 appldev ship $ */

G_MODULE_NAME  CONSTANT VARCHAR2(200) := 'INL.PLSQL.INL_CHARGESHOOK_PVT.';
G_PKG_NAME     CONSTANT VARCHAR2(30)  := 'INL_CHARGESHOOK_PVT';

PROCEDURE Get_Charges(p_ship_ln_group_rec            IN inl_charge_pvt.ship_ln_group_rec,
                      p_ship_ln_tbl                  IN inl_charge_pvt.ship_ln_tbl,
                      x_charge_ln_tbl                OUT NOCOPY inl_charge_pvt.charge_ln_tbl,
                      x_override_default_processing  OUT NOCOPY  BOOLEAN,
                      x_return_status                OUT NOCOPY VARCHAR2);

END INL_CHARGESHOOK_PVT;

/
