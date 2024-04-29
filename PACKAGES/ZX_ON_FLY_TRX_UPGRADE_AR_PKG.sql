--------------------------------------------------------
--  DDL for Package ZX_ON_FLY_TRX_UPGRADE_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ON_FLY_TRX_UPGRADE_AR_PKG" AUTHID CURRENT_USER AS
/* $Header: zxmigtrxflyars.pls 120.0 2005/09/01 04:26:41 lxzhang noship $ */

PROCEDURE upgrade_trx_on_fly_ar(
  p_upg_trx_info_rec   IN          ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type,
  x_return_status      OUT NOCOPY  VARCHAR2
);


PROCEDURE upgrade_trx_on_fly_blk_ar(
  x_return_status      OUT NOCOPY  VARCHAR2
);

END ZX_ON_FLY_TRX_UPGRADE_AR_PKG;


 

/
