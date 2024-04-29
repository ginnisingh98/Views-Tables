--------------------------------------------------------
--  DDL for Package Body ZX_ON_FLY_TRX_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ON_FLY_TRX_UPGRADE_PKG" AS
/* $Header: zxmigtrxflypkgb.pls 120.2.12010000.2 2008/12/31 13:35:20 rajessub ship $ */

 g_current_runtime_level      NUMBER;
 g_level_statement            CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure            CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_level_event                CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
 g_level_unexpected           CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- upgrade_trx_on_fly
--
-- DESCRIPTION
-- on the fly migration for one transaction
--
-------------------------------------------------------------------------------

PROCEDURE upgrade_trx_on_fly(
  p_application_id   IN    NUMBER,
  p_entity_code      IN    VARCHAR2,
  p_event_class_code IN    VARCHAR2,
  p_trx_id           IN    NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
) IS
l_return_status VARCHAR2(100);
l_upg_trx_info_rec zx_upg_trx_info_rec_type;
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(+).wrapper');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_upg_trx_info_rec.application_id := p_application_id;
  l_upg_trx_info_rec.entity_code := p_entity_code;
  l_upg_trx_info_rec.event_class_code := p_event_class_code;
  l_upg_trx_info_rec.trx_id := p_trx_id;

  upgrade_trx_on_fly( l_upg_trx_info_rec, x_return_status);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly.END',
                    'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(-)');
    END IF;

END;



PROCEDURE upgrade_trx_on_fly(
  p_upg_trx_info_rec   IN           zx_upg_trx_info_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
) AS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly',
                   'p_upg_trx_info_rec.application_id: '||
                   p_upg_trx_info_rec.application_id );
  END IF;

  IF p_upg_trx_info_rec.application_id = 222 THEN
    ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_ar(
      p_upg_trx_info_rec => p_upg_trx_info_rec,
      x_return_status => x_return_status
    );
  ELSIF p_upg_trx_info_rec.application_id = 200 THEN
    ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap(
      p_upg_trx_info_rec => p_upg_trx_info_rec,
      x_return_status => x_return_status
    );

  ELSIF p_upg_trx_info_rec.application_id = 201 THEN
    ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po(
      p_upg_trx_info_rec => p_upg_trx_info_rec,
      x_return_status => x_return_status
    );

  ELSE
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly',
                   'On the fly upgrade currently not support product: '||
                   p_upg_trx_info_rec.application_id );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly',
                   'x_return_status: '|| x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly.END',
                   'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly.END',
                    'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(-)');
    END IF;

END;

-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- upgrade_trx_on_fly_blk
--
-- DESCRIPTION
-- handle bulk on the fly migration, called from validate and default API
--
-- NOTE
-- in validation API, the first validation done is to check if any other
-- doc missing, if yes, this API will be called.
-------------------------------------------------------------------------------

PROCEDURE upgrade_trx_on_fly_blk(
  x_return_status        OUT NOCOPY  VARCHAR2
) AS
  -- Bug 7637302 Added Union condition to fetch other doc application id for processing
  CURSOR c_distinct_app_id IS
    SELECT distinct application_id
      FROM zx_validation_errors_gt
  UNION
    SELECT distinct other_doc_application_id
    FROM zx_validation_errors_gt;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR t IN c_distinct_app_id LOOP
    IF t.application_id = 222 THEN
      ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar(
        x_return_status => x_return_status
      );
    ELSIF t.application_id = 200 THEN
      ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap(
        x_return_status => x_return_status
      );

    ELSIF t.application_id = 201 THEN
      ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po(
        x_return_status => x_return_status
      );

    ELSE
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk',
                     'On the fly upgrade currently not support product: '||
                     t.application_id );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk',
                   'x_return_status: '|| x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk.END',
                   'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk.END',
                    'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk(-)');
    END IF;

END upgrade_trx_on_fly_blk;

-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- is_trx_migrated
--
-- DESCRIPTION
-- This function is used to check if trx is already migrated
--
-- NOTE
--  case 1: called from ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(),
--          get_tax_lines_from_adjusted/applied():
--      trx_line_id in the rec is passed, need to check if the trx_line_id
--      exists in the zx_lines_det_factors table.
--  case 2: called from ZX_TRL_PUB_PKG.document_level_changes()
--      trx level update, if there is any trx line exist for the trx_id,
--      the trx is regarded as alreayd migrated.
--
-------------------------------------------------------------------------------

PROCEDURE is_trx_migrated(
  p_upg_trx_info_rec   IN          zx_upg_trx_info_rec_type,
  x_trx_migrated_b     OUT NOCOPY  BOOLEAN,
  x_return_status      OUT NOCOPY  VARCHAR2
) AS
  l_count   NUMBER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(+)');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_trx_migrated_b := TRUE;
  IF p_upg_trx_info_rec.TRX_LINE_ID IS NOT NULL THEN
    SELECT count(*) into l_count
      FROM zx_lines_det_factors
     WHERE application_id   = p_upg_trx_info_rec.application_id
       AND event_class_code = p_upg_trx_info_rec.event_class_code
       AND entity_code      = p_upg_trx_info_rec.entity_code
       AND trx_id           = p_upg_trx_info_rec.trx_id
       AND trx_line_id      = p_upg_trx_info_rec.trx_line_id
       AND trx_level_type   = p_upg_trx_info_rec.trx_level_type;
  ELSE
    SELECT count(*) into l_count
      FROM zx_lines_det_factors
     WHERE application_id   = p_upg_trx_info_rec.application_id
       AND event_class_code = p_upg_trx_info_rec.event_class_code
       AND entity_code      = p_upg_trx_info_rec.entity_code
       AND trx_id           = p_upg_trx_info_rec.trx_id;
  END IF;

  IF l_count = 0 THEN
    x_trx_migrated_b := FALSE;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated.END',
                   'ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated.END',
                    'ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(-)');
    END IF;
END is_trx_migrated;

END ZX_ON_FLY_TRX_UPGRADE_PKG;


/
