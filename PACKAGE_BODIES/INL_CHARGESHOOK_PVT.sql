--------------------------------------------------------
--  DDL for Package Body INL_CHARGESHOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_CHARGESHOOK_PVT" AS
/* $Header: INLVCHHB.pls 120.3.12010000.1 2008/09/25 07:34:06 appldev ship $ */

-- Utility name : Get_Charges
-- Type       : Private
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN         :   p_ship_ln_group_rec   inl_charge_pvt.ship_ln_group_rec
--                p_ship_ln_tbl         inl_charge_pvt.ship_ln_tbl
--
-- OUT            x_charge_ln_tbl                OUT NOCOPY inl_charge_pvt.charge_ln_tbl
--                x_override_default_processing  OUT BOOLEAN (If TRUE, it enables the hook execution
--                                                            to override the default processing from
--                                                            the caller routine)
--                x_return_status                OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_Charges(p_ship_ln_group_rec            IN inl_charge_pvt.ship_ln_group_rec,
                      p_ship_ln_tbl                  IN inl_charge_pvt.ship_ln_tbl,
                      x_charge_ln_tbl                OUT NOCOPY inl_charge_pvt.charge_ln_tbl,
                      x_override_default_processing  OUT NOCOPY BOOLEAN,
                      x_return_status                OUT NOCOPY VARCHAR2) IS
BEGIN
        x_override_default_processing := FALSE;
        RETURN;
END Get_Charges;

END INL_CHARGESHOOK_PVT;

/
