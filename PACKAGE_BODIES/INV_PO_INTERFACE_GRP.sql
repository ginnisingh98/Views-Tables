--------------------------------------------------------
--  DDL for Package Body INV_PO_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PO_INTERFACE_GRP" AS
/* $Header: INVPOIGB.pls 120.0 2005/05/25 05:23:01 appldev noship $ */

--
-- Name : DELETE_LOT_SER_TRX
--
--   Input Parameters:
--              p_trx_tmp_id    : Transction temp id
--              p_org_id        : Organization id
--              p_item_id       : Inventory Item Id
--              p_lotctrl       : Lot control code
--              p_serctrl       : Serial number control code
--   Output Parameters:
--              x_return_status : Return Status
--

PROCEDURE DELETE_LOT_SER_TRX(
                p_trx_tmp_id    IN NUMBER,
                p_org_id        IN NUMBER,
                p_item_id       IN NUMBER,
                p_lotctrl       IN NUMBER,
                p_serctrl       IN NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS


BEGIN

	INV_TRX_UTIL_PUB.DELETE_LOT_SER_TRX(
		p_trx_tmp_id => p_trx_tmp_id,
		p_org_id     => p_org_id,
		p_item_id    => p_item_id,
		p_lotctrl    => p_lotctrl,
		p_serctrl    => p_serctrl,
                x_return_status => x_return_status);

END DELETE_LOT_SER_TRX;

END INV_PO_INTERFACE_GRP;

/
