--------------------------------------------------------
--  DDL for Package ZX_ON_FLY_TRX_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ON_FLY_TRX_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxmigtrxflypkgs.pls 120.2 2005/10/06 17:24:45 lxzhang noship $ */


TYPE zx_upg_trx_info_rec_type IS RECORD(
  application_id      ZX_LINES_DET_FACTORS.APPLICATION_ID%TYPE,
  event_class_code    ZX_LINES_DET_FACTORS.EVENT_CLASS_CODE%TYPE,
  entity_code         ZX_LINES_DET_FACTORS.ENTITY_CODE%TYPE,
  trx_id              ZX_LINES_DET_FACTORS.TRX_ID%TYPE,
  trx_line_id         ZX_LINES_DET_FACTORS.TRX_LINE_ID%TYPE,
  trx_level_type      ZX_LINES_DET_FACTORS.TRX_LEVEL_TYPE%TYPE
);


PROCEDURE upgrade_trx_on_fly(
  p_upg_trx_info_rec   IN           zx_upg_trx_info_rec_type,
  x_return_status      OUT NOCOPY  VARCHAR2
);

PROCEDURE upgrade_trx_on_fly(
  p_application_id   IN   NUMBER,
  p_entity_code      IN   VARCHAR2,
  p_event_class_code IN   VARCHAR2,
  p_trx_id           IN   NUMBER,
  x_return_status      OUT NOCOPY  VARCHAR2
);

PROCEDURE upgrade_trx_on_fly_blk(
  x_return_status      OUT NOCOPY  VARCHAR2
);

PROCEDURE is_trx_migrated(
  p_upg_trx_info_rec   IN          zx_upg_trx_info_rec_type,
  x_trx_migrated_b     OUT NOCOPY  BOOLEAN,
  x_return_status      OUT NOCOPY  VARCHAR2
);

END ZX_ON_FLY_TRX_UPGRADE_PKG;


 

/
