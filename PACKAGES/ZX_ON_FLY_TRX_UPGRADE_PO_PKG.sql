--------------------------------------------------------
--  DDL for Package ZX_ON_FLY_TRX_UPGRADE_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ON_FLY_TRX_UPGRADE_PO_PKG" AUTHID CURRENT_USER AS
/* $Header: zxmigtrxflypos.pls 120.0 2005/09/01 23:58:38 hongliu ship $ */

PROCEDURE upgrade_trx_on_fly_po(
  p_upg_trx_info_rec   IN          ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type,
  x_return_status      OUT NOCOPY  VARCHAR2
);


PROCEDURE upgrade_trx_on_fly_blk_po(
  x_return_status      OUT NOCOPY  VARCHAR2
);

END ZX_ON_FLY_TRX_UPGRADE_PO_PKG;


 

/
