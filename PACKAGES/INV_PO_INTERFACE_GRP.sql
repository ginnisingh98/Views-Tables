--------------------------------------------------------
--  DDL for Package INV_PO_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PO_INTERFACE_GRP" AUTHID CURRENT_USER AS
/* $Header: INVPOIGS.pls 115.0 2003/09/19 23:51:42 arsawant noship $ */

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
                x_return_status OUT NOCOPY VARCHAR2);

END INV_PO_INTERFACE_GRP;

 

/
