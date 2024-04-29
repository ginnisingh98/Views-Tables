--------------------------------------------------------
--  DDL for Package Body CST_PERIODIC_AVERAGE_PROC_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PERIODIC_AVERAGE_PROC_CP" AS
-- $Header: CSTVITPB.pls 120.7.12010000.8 2009/07/18 03:22:16 vjavli ship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     CSTVITPB.pls   Created By Vamshi Mutyala                          |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Periodic Average Cost Processor  Concurrent Program                |
--|                                                                       |
--| Bug 6699275 FP:11I-12.0 fix: CSTPPWRO.process_wip_resovhd_txns        |
--| In the invoked procedure l_err_msg length changed from VARCHAR2(255)  |
--| to VARCHAR2(2000).  Invoked proc build_job_info                       |
--|                                                                       |
--| FP BUG 7342514 FIX: periodic_cost_update value change is removed.     |
--| periodic_cost_update procedure for PCU value change has to be invoked |
--| after processing all the cost owned txns including inter-org receipts |
--| across cost groups, after first iteration in the iteration package    |
--| CSTVIIPB.pls                                                          |
--| For non-interorg items, periodic_cost_update procedure is invoked     |
--| in the Periodic Absorption Cost processor outside of iteration proc   |
--| Periodic_Cost_Update procedure : PCU value change cursor and logic    |
--| removed since PCU value change is performed using Periodic_Cost_Update|
--| _By_Level procedure                                                   |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'CST_PERIODIC_AVERAGE_PROC';

--========================================================================
-- PRIVATE CONSTANTS AND VARIABLES
--========================================================================
G_MODULE_HEAD CONSTANT  VARCHAR2(50) := 'cst.plsql.' || G_PKG_NAME || '.';

TYPE g_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_tbl_char_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

--========================================================================
-- PROCEDURE : Set Status    PRIVATE
-- COMMENT   : Set the status of a specific phase
--========================================================================
PROCEDURE set_status
( p_period_id           IN NUMBER
, p_cost_group_id       IN NUMBER
, p_phase               IN NUMBER
, p_status              IN NUMBER
, p_end_date            IN DATE
, p_user_id             IN NUMBER
, p_login_id            IN NUMBER
, p_req_id              IN NUMBER
, p_prg_id              IN NUMBER
, p_prg_appid           IN NUMBER
)
IS

l_routine  CONSTANT  VARCHAR2(30) := 'set_status';
--=================
-- VARIABLES
--=================

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  UPDATE cst_pac_process_phases
  SET process_status = p_status,
      process_date = SYSDATE,
      process_upto_date = p_end_date,
      last_update_date = SYSDATE,
      last_updated_by = p_user_id,
      request_id = p_req_id,
      program_application_id = p_prg_appid,
      program_id = p_prg_id,
      program_update_date = SYSDATE,
      last_update_login = p_login_id
  WHERE pac_period_id = p_period_id
    AND cost_group_id = p_cost_group_id
    AND process_phase = p_phase;

  -- the following commit is required to prevent
  -- a complete rollback if the process errors out

  COMMIT;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END set_status;

--========================================================================
-- PROCEDURE : Build Job Info   PRIVATE
-- COMMENT   : Build Job Info (essentially Phase 4 for all cost groups)
--=========================================================================
PROCEDURE build_job_info
( p_period_id         IN NUMBER
, p_start_date        IN DATE
, p_end_date          IN DATE
, p_cost_group_id     IN NUMBER
, p_cost_type_id      IN NUMBER
, p_pac_rates_id      IN NUMBER
, p_user_id           IN NUMBER
, p_login_id          IN NUMBER
, p_req_id            IN NUMBER
, p_prg_id            IN NUMBER
, p_prg_appid         IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'build_job_info';
--=================
-- VARIABLES
--=================

l_item_id            NUMBER := NULL;
l_error_num          NUMBER;
l_error_code         VARCHAR2(240);
l_error_msg          VARCHAR2(2000);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  set_status
   (p_period_id         => p_period_id
   ,p_cost_group_id     => p_cost_group_id
   ,p_phase             => 4
   ,p_status            => 2
   ,p_end_date          => p_end_date
   ,p_user_id           => p_user_id
   ,p_login_id          => p_login_id
   ,p_req_id            => p_req_id
   ,p_prg_id            => p_prg_id
   ,p_prg_appid         => p_prg_appid);

  CSTPPWRO.process_wip_resovhd_txns
   (p_pac_period_id     => p_period_id
   ,p_start_date        => p_start_date
   ,p_end_date          => p_end_date
   ,p_cost_group_id     => p_cost_group_id
   ,p_cost_type_id      => p_cost_type_id
   ,p_item_id           => l_item_id
   ,p_pac_ct_id         => p_pac_rates_id
   ,p_user_id           => p_user_id
   ,p_login_id          => p_login_id
   ,p_request_id        => p_req_id
   ,p_prog_id           => p_prg_id
   ,p_prog_app_id       => p_prg_appid
   ,x_err_num           => l_error_num
   ,x_err_code          => l_error_code
   ,x_err_msg           => l_error_msg);

  l_error_num  := NVL(l_error_num, 0);
  l_error_code := NVL(l_error_code, 'No Error');
  l_error_msg  := NVL(l_error_msg, 'No Error');

  IF l_error_num <> 0
  THEN

     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 4
     ,p_status            => 3
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', 'process_wip_resovhd_txns for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

  ELSE

     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 4
     ,p_status            => 4
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END build_job_info;

--========================================================================
-- PROCEDURE : Explode Bom   PRIVATE
-- COMMENT   : Explode Bill Of Materials for all Cost Groups
--=========================================================================
PROCEDURE explode_bom
( p_period_id         IN  NUMBER
, p_cost_group_id     IN  NUMBER
, p_start_date        IN  DATE
, p_end_date          IN  DATE
, p_user_id           IN  NUMBER
, p_login_id          IN  NUMBER
, p_req_id            IN  NUMBER
, p_prg_id            IN  NUMBER
, p_prg_appid         IN  NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'explode_bom';
--=================
-- VARIABLES
--=================

l_error_num          NUMBER;
l_error_code         VARCHAR2(240);
l_error_msg          VARCHAR2(240);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

   set_status
   (p_period_id         => p_period_id
   ,p_cost_group_id     => p_cost_group_id
   ,p_phase             => 3
   ,p_status            => 2
   ,p_end_date          => p_end_date
   ,p_user_id           => p_user_id
   ,p_login_id          => p_login_id
   ,p_req_id            => p_req_id
   ,p_prg_id            => p_prg_id
   ,p_prg_appid         => p_prg_appid);

  CSTPPLLC.pac_low_level_codes
   (i_pac_period_id     => p_period_id
   ,i_cost_group_id     => p_cost_group_id
   ,i_start_date        => p_start_date
   ,i_end_date          => p_end_date
   ,i_user_id           => p_user_id
   ,i_login_id          => p_login_id
   ,i_request_id        => p_req_id
   ,i_prog_id           => p_prg_id
   ,i_prog_app_id       => p_prg_appid
   ,o_err_num           => l_error_num
   ,o_err_code          => l_error_code
   ,o_err_msg           => l_error_msg);

  l_error_num  := NVL(l_error_num, 0);
  l_error_code := NVL(l_error_code, 'No Error');
  l_error_msg  := NVL(l_error_msg, 'No Error');

  IF l_error_num <> 0
  THEN

     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 3
     ,p_status            => 3
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    ,G_MODULE_HEAD || l_routine || '.paclowcode'
                    ,l_error_msg
                    );
    END IF;

    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', 'pac_low_level_codes for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

  ELSE

     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 3
     ,p_status            => 4
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END explode_bom;

--========================================================================
-- PROCEDURE : Copy Balance   PRIVATE
-- COMMENT   : Bring Forward the Beginning Balance from the previous period
--=========================================================================
PROCEDURE copy_balance
( p_period_id          IN NUMBER
, p_prev_period_id     IN NUMBER
, p_end_date           IN DATE
, p_legal_entity       IN NUMBER
, p_cost_type_id       IN NUMBER
, p_cost_group_id      IN NUMBER
, p_cost_method        IN NUMBER
, p_user_id            IN NUMBER
, p_login_id           IN NUMBER
, p_req_id             IN NUMBER
, p_prg_id             IN NUMBER
, p_prg_appid          IN NUMBER
, p_starting_phase     IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'copy_balance';
--=================
-- VARIABLES
--=================

-- Initialize to purge phase 2 to 5
l_acquisition_flag   NUMBER := 0;

l_error_num          NUMBER;
l_error_code         VARCHAR2(240);
l_error_msg          VARCHAR2(240);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

   set_status
   (p_period_id         => p_period_id
   ,p_cost_group_id     => p_cost_group_id
   ,p_phase             => 2
   ,p_status            => 2
   ,p_end_date          => p_end_date
   ,p_user_id           => p_user_id
   ,p_login_id          => p_login_id
   ,p_req_id            => p_req_id
   ,p_prg_id            => p_prg_id
   ,p_prg_appid         => p_prg_appid);

  IF p_starting_phase = 2 THEN
	  CSTPPPUR.purge_period_data
	   ( i_pac_period_id     => p_period_id
	   , i_legal_entity      => p_legal_entity
	   , i_cost_group_id     => p_cost_group_id
	   , i_acquisition_flag  => l_acquisition_flag
	   , i_user_id           => p_user_id
	   , i_login_id          => p_login_id
	   , i_request_id        => p_req_id
	   , i_prog_id           => p_prg_id
	   , i_prog_app_id       => p_prg_appid
	   , o_err_num           => l_error_num
	   , o_err_code          => l_error_code
	   , o_err_msg           => l_error_msg);

	  l_error_num  := NVL(l_error_num, 0);
	  l_error_code := NVL(l_error_code, 'No Error');
	  l_error_msg  := NVL(l_error_msg, 'No Error');

	  IF l_error_num <> 0
	  THEN
	     set_status
	     (p_period_id         => p_period_id
	     ,p_cost_group_id     => p_cost_group_id
	     ,p_phase             => 2
	     ,p_status            => 3
	     ,p_end_date          => p_end_date
	     ,p_user_id           => p_user_id
	     ,p_login_id          => p_login_id
	     ,p_req_id            => p_req_id
	     ,p_prg_id            => p_prg_id
	     ,p_prg_appid         => p_prg_appid);

	    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
	    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
	    FND_MESSAGE.set_token('MESSAGE', 'purge_period_data for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
	    FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
   END IF;

  CSTPPBBS.copy_prior_info
   ( i_pac_period_id          => p_period_id
   , i_prior_pac_period_id    => p_prev_period_id
   , i_legal_entity           => p_legal_entity
   , i_cost_type_id           => p_cost_type_id
   , i_cost_group_id          => p_cost_group_id
   , i_cost_method            => p_cost_method
   , i_user_id                => p_user_id
   , i_login_id               => p_login_id
   , i_request_id             => p_req_id
   , i_prog_id                => p_prg_id
   , i_prog_app_id            => p_prg_appid
   , o_err_num                => l_error_num
   , o_err_code               => l_error_code
   , o_err_msg                => l_error_msg);

  l_error_num  := NVL(l_error_num, 0);
  l_error_code := NVL(l_error_code, 'No Error');
  l_error_msg  := NVL(l_error_msg, 'No Error');

  IF l_error_num <> 0 THEN
    -- Set phase 2 to 3 - Error
     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 2
     ,p_status            => 3
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', 'copy_prior_info for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

  ELSE
    -- Set Phase 2 to 4 - Completion
     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 2
     ,p_status            => 4
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END copy_balance;

--========================================================================
-- PROCEDURE : Run Acquisition Cost Processor   PRIVATE
-- COMMENT   : Aquisition Cost Processor
--=========================================================================
PROCEDURE run_acquisition_cp
( p_period_id            IN NUMBER
, p_start_date           IN DATE
, p_end_date             IN DATE
, p_legal_entity         IN NUMBER
, p_cost_type_id         IN NUMBER
, p_cost_group_id        IN NUMBER
, p_user_id              IN NUMBER
, p_login_id             IN NUMBER
, p_req_id               IN NUMBER
, p_prg_id               IN NUMBER
, p_prg_appid            IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'run_acquisition_cp';
--=================
-- VARIABLES
--=================

-- Initialize to purge all phases
l_acquisition_flag   NUMBER := 1;

l_error_num        NUMBER;
l_error_code       VARCHAR2(240);
l_error_msg        VARCHAR2(240);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

   set_status
   (p_period_id         => p_period_id
   ,p_cost_group_id     => p_cost_group_id
   ,p_phase             => 1
   ,p_status            => 2
   ,p_end_date          => p_end_date
   ,p_user_id           => p_user_id
   ,p_login_id          => p_login_id
   ,p_req_id            => p_req_id
   ,p_prg_id            => p_prg_id
   ,p_prg_appid         => p_prg_appid);

  -- ==============================================================
  -- Prerequisite for Phase 1 is to purge all phases
  -- If purging errors out, the status of phase 1 will be set to
  -- ERROR.  Otherwise it continues to process phase 1.
  -- ==============================================================
  CSTPPPUR.purge_period_data
   ( i_pac_period_id     => p_period_id
   , i_legal_entity      => p_legal_entity
   , i_cost_group_id     => p_cost_group_id
   , i_acquisition_flag  => l_acquisition_flag
   , i_user_id           => p_user_id
   , i_login_id          => p_login_id
   , i_request_id        => p_req_id
   , i_prog_id           => p_prg_id
   , i_prog_app_id       => p_prg_appid
   , o_err_num           => l_error_num
   , o_err_code          => l_error_code
   , o_err_msg           => l_error_msg);

  l_error_num  := NVL(l_error_num, 0);
  l_error_code := NVL(l_error_code, 'No Error');
  l_error_msg  := NVL(l_error_msg, 'No Error');

  IF l_error_num <> 0
  THEN
     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 1
     ,p_status            => 3
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', 'purge_period_data for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CSTPPACQ.acq_cost_processor
   (i_period            => p_period_id
   ,i_start_date        => p_start_date
   ,i_end_date          => p_end_date + (86399/86400)
   ,i_cost_type_id      => p_cost_type_id
   ,i_cost_group_id     => p_cost_group_id
   ,i_user_id           => p_user_id
   ,i_login_id          => p_login_id
   ,i_req_id            => p_req_id
   ,i_prog_id           => p_prg_id
   ,i_prog_appl_id      => p_prg_appid
   ,o_err_num           => l_error_num
   ,o_err_code          => l_error_code
   ,o_err_msg           => l_error_msg);

  l_error_num  := NVL(l_error_num, 0);
  l_error_code := NVL(l_error_code, 'No Error');
  l_error_msg  := NVL(l_error_msg, 'No Error');

  IF l_error_num <> 0
  THEN

     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 1
     ,p_status            => 3
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', 'acq_cost_processor for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

  ELSE

     set_status
     (p_period_id         => p_period_id
     ,p_cost_group_id     => p_cost_group_id
     ,p_phase             => 1
     ,p_status            => 4
     ,p_end_date          => p_end_date
     ,p_user_id           => p_user_id
     ,p_login_id          => p_login_id
     ,p_req_id            => p_req_id
     ,p_prg_id            => p_prg_id
     ,p_prg_appid         => p_prg_appid);

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

END run_acquisition_cp;

--========================================================================
-- PROCEDURE : prepare absorption process   PRIVATE
-- COMMENT   :
--=========================================================================

PROCEDURE  prepare_absorption_process
       (p_period_id         IN NUMBER
       ,p_start_date        IN DATE
       ,p_end_date          IN DATE
       ,p_cost_group_id     IN NUMBER
       ,p_cost_type_id      IN NUMBER
       ,p_pac_rates_id      IN NUMBER
       ,p_user_id           IN NUMBER
       ,p_login_id          IN NUMBER
       ,p_req_id            IN NUMBER
       ,p_prg_id            IN NUMBER
       ,p_prg_appid         IN NUMBER
 )
IS

l_routine CONSTANT VARCHAR2(30) := 'prepare_absorption_process';

l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);

BEGIN

    -- Delete interorg item records for the period
      DELETE CST_PAC_INTORG_ITMS_TEMP
      WHERE  pac_period_id = p_period_id
      AND cost_group_id = p_cost_group_id;

    -- Delete MPACD TEMP records for the period
      DELETE MTL_PAC_ACT_CST_DTL_TEMP
      WHERE pac_period_id = p_period_id
      AND cost_group_id = p_cost_group_id;

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT
                    , G_MODULE_HEAD || l_routine || '.Before_retrieve_items'
                    , 'Before Retrieve interorg items'
                    );
      END IF;

      -- ========================================================
      -- Populate temporary table CST_PAC_INTERORG_TXNS_TMP
      -- with across CG interorg transactions
      -- ========================================================
       CST_PAC_ITERATION_PROCESS_PVT.Populate_Temp_Tables(
         p_cost_group_id         => p_cost_group_id
	,p_period_id             => p_period_id
        ,p_period_start_date     => p_start_date
        ,p_period_end_date       => p_end_date
        );
      -- ========================================================
      -- Retrieve Interorg Items for the period
      -- This will be invoked only once during Run Options Start
      -- Interorg Items are stored in temporary table
      -- Interorg Items are assigned with Absorption Level Codes
      -- ========================================================
      CST_PAC_ITERATION_PROCESS_PVT.Retrieve_Interorg_Items
        (p_period_id             => p_period_id
	,p_cost_group_id         => p_cost_group_id
        ,p_period_start_date     => p_start_date
        ,p_period_end_date       => p_end_date
        );

END  prepare_absorption_process;

--========================================================================
-- PROCEDURE : Periodic Cost Update   PRIVATE
-- COMMENT   : Run the cost processor for modes
--           : periodic cost update (new cost, and % change
--           : new cost, and %ge change has txn category 2
--=========================================================================
PROCEDURE Periodic_Cost_Update
( p_period_id                 IN NUMBER
, p_legal_entity              IN NUMBER
, p_cost_type_id              IN NUMBER
, p_cost_group_id             IN NUMBER
, p_cost_method               IN NUMBER
, p_start_date                IN DATE
, p_end_date                  IN DATE
, p_pac_rates_id              IN NUMBER
, p_master_org_id             IN NUMBER
, p_cost_update_type          IN NUMBER
, p_uom_control               IN NUMBER
, p_user_id                   IN NUMBER
, p_login_id                  IN NUMBER
, p_req_id                    IN NUMBER
, p_prg_id                    IN NUMBER
, p_prg_appid                 IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'periodic_cost_update';


--=================
-- CURSORS
--=================

-- =============================================
-- PCU New Cost or %ge txns for all items
-- =============================================
  CURSOR upd_new_csr_type IS
    SELECT mmt.transaction_id
         , mmt.transaction_action_id
         , mmt.transaction_source_type_id
         , mmt.inventory_item_id
         , mmt.primary_quantity
         , mmt.organization_id
         , nvl(mmt.transfer_organization_id,-1) transfer_organization_id
         , mmt.subinventory_code
    FROM mtl_material_transactions mmt
       , mtl_transaction_types mtt
    WHERE mmt.transaction_date between p_start_date
    AND p_end_date
    AND mmt.transaction_action_id = 24
    AND mmt.transaction_source_type_id = 14
    AND mtt.transaction_action_id = mmt.transaction_action_id
    AND mtt.transaction_source_type_id = mmt.transaction_source_type_id
    AND mmt.transaction_type_id = mtt.transaction_type_id
    AND (new_cost IS NOT NULL or percentage_change IS NOT NULL)
    AND NVL(org_cost_group_id,-1) = p_cost_group_id
    AND NVL(cost_type_id,-1) = p_cost_type_id;

    CURSOR upd_val_csr_type IS
    SELECT mmt.transaction_id
         , mmt.transaction_action_id
         , mmt.transaction_source_type_id
         , mmt.inventory_item_id
         , mmt.primary_quantity
         , mmt.organization_id
         , nvl(mmt.transfer_organization_id,-1) transfer_organization_id
         , mmt.subinventory_code
    FROM mtl_material_transactions mmt
       , mtl_transaction_types mtt
    WHERE mmt.transaction_date between p_start_date
    AND p_end_date
    AND mmt.transaction_action_id = 24
    AND mmt.transaction_source_type_id = 14
    AND mtt.transaction_action_id = mmt.transaction_action_id
    AND mtt.transaction_source_type_id = mmt.transaction_source_type_id
    AND mmt.transaction_type_id = mtt.transaction_type_id
    AND mmt.value_change IS NOT NULL
    AND mmt.primary_quantity > 0
    AND NVL(org_cost_group_id,-1) = p_cost_group_id
    AND NVL(cost_type_id,-1) = p_cost_type_id;



TYPE upd_val_tab IS TABLE OF upd_new_csr_type%rowtype INDEX BY BINARY_INTEGER;

l_upd_val_tab		upd_val_tab;
l_empty_upd_val_tab	upd_val_tab;
--=================
-- VARIABLES
--=================


l_error_num        NUMBER;
l_error_code       VARCHAR2(240);
l_error_msg        VARCHAR2(240);
l_exp_flag         NUMBER;
l_exp_item         NUMBER;
l_process_group    NUMBER := 0;

l_loop_count       NUMBER := 0;
-- Transaction category variable
l_txn_category      NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  -- ===============================
  -- Initialize transaction category
  -- ===============================
  -- Set Transaction category for PCU New Cost or %ge
    l_txn_category := 2;


	-- PCU New Cost or %ge txns
	IF NOT upd_new_csr_type%ISOPEN
	THEN
		OPEN upd_new_csr_type;
	END IF;

	-- clear the pl/sql table before use
	l_upd_val_tab := l_empty_upd_val_tab;
	FETCH upd_new_csr_type BULK COLLECT INTO l_upd_val_tab;

	CLOSE upd_new_csr_type;


  l_loop_count := l_upd_val_tab.COUNT;

  l_error_num := 0;

  FOR i IN 1..l_loop_count
  LOOP

      IF l_error_num = 0 THEN

        CSTPPINV.cost_inv_txn
         (i_pac_period_id       => p_period_id
         ,i_legal_entity        => p_legal_entity
         ,i_cost_type_id        => p_cost_type_id
         ,i_cost_group_id       => p_cost_group_id
         ,i_cost_method         => p_cost_method
         ,i_txn_id              => l_upd_val_tab(i).transaction_id
         ,i_txn_action_id       => l_upd_val_tab(i).transaction_action_id
         ,i_txn_src_type_id     => l_upd_val_tab(i).transaction_source_type_id
         ,i_item_id             => l_upd_val_tab(i).inventory_item_id
         ,i_txn_qty             => l_upd_val_tab(i).primary_quantity
         ,i_txn_org_id          => l_upd_val_tab(i).organization_id
         ,i_txfr_org_id         => l_upd_val_tab(i).transfer_organization_id
         ,i_subinventory_code   => l_upd_val_tab(i).subinventory_code
         ,i_exp_flag            => l_exp_flag
         ,i_exp_item            => l_exp_item
         ,i_pac_rates_id        => p_pac_rates_id
         ,i_process_group       => l_process_group
         ,i_master_org_id       => p_master_org_id
         ,i_uom_control         => p_uom_control
         ,i_user_id             => p_user_id
         ,i_login_id            => p_login_id
         ,i_request_id          => p_req_id
         ,i_prog_id             => p_prg_id
         ,i_prog_appl_id        => p_prg_appid
         ,i_txn_category        => l_txn_category
         ,i_transfer_price_pd   => 0
         ,o_err_num             => l_error_num
         ,o_err_code            => l_error_code
         ,o_err_msg             => l_error_msg);

        l_error_num  := NVL(l_error_num, 0);
        l_error_code := NVL(l_error_code, 'No Error');
        l_error_msg  := NVL(l_error_msg, 'No Error');

        IF l_error_num <> 0
        THEN
		IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
			, G_MODULE_HEAD || l_routine || '.others'
			, 'cost_inv_txn for cost group '||p_cost_group_id||' txn id '
	                 ||l_upd_val_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg
                    );
		END IF;

		FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
	        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
	        FND_MESSAGE.set_token('MESSAGE', 'cost_inv_txn for cost group '||p_cost_group_id||' txn id '
	                                 ||l_upd_val_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg);
	        FND_MSG_PUB.Add;
	        RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- error num check

  END LOOP;

  l_txn_category := 2.5;


	-- PCU value change with qty txns
	IF NOT upd_val_csr_type%ISOPEN
	THEN
		OPEN upd_val_csr_type;
	END IF;

	-- clear the pl/sql table before use
	l_upd_val_tab := l_empty_upd_val_tab;
	FETCH upd_val_csr_type BULK COLLECT INTO l_upd_val_tab;

	CLOSE upd_val_csr_type;

  l_loop_count := 0;
  l_loop_count := l_upd_val_tab.COUNT;


  FOR i IN 1..l_loop_count
  LOOP
        l_error_num := 0;
             IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000) THEN
	        CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cost_group_id
                                 ,i_txn_category      => l_txn_category
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );
		l_error_num  := NVL(l_error_num, 0);
                l_error_code := NVL(l_error_code, 'No Error');
                l_error_msg  := NVL(l_error_msg, 'No Error');

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.inscppb5'
                        ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
	        END IF;
              END IF; -- item table count check

	IF l_error_num = 0 THEN

        CSTPPINV.cost_inv_txn
         (i_pac_period_id       => p_period_id
         ,i_legal_entity        => p_legal_entity
         ,i_cost_type_id        => p_cost_type_id
         ,i_cost_group_id       => p_cost_group_id
         ,i_cost_method         => p_cost_method
         ,i_txn_id              => l_upd_val_tab(i).transaction_id
         ,i_txn_action_id       => l_upd_val_tab(i).transaction_action_id
         ,i_txn_src_type_id     => l_upd_val_tab(i).transaction_source_type_id
         ,i_item_id             => l_upd_val_tab(i).inventory_item_id
         ,i_txn_qty             => l_upd_val_tab(i).primary_quantity
         ,i_txn_org_id          => l_upd_val_tab(i).organization_id
         ,i_txfr_org_id         => l_upd_val_tab(i).transfer_organization_id
         ,i_subinventory_code   => l_upd_val_tab(i).subinventory_code
         ,i_exp_flag            => l_exp_flag
         ,i_exp_item            => l_exp_item
         ,i_pac_rates_id        => p_pac_rates_id
         ,i_process_group       => 1
         ,i_master_org_id       => p_master_org_id
         ,i_uom_control         => p_uom_control
         ,i_user_id             => p_user_id
         ,i_login_id            => p_login_id
         ,i_request_id          => p_req_id
         ,i_prog_id             => p_prg_id
         ,i_prog_appl_id        => p_prg_appid
         ,i_txn_category        => l_txn_category
         ,i_transfer_price_pd   => 0
         ,o_err_num             => l_error_num
         ,o_err_code            => l_error_code
         ,o_err_msg             => l_error_msg);

        l_error_num  := NVL(l_error_num, 0);
        l_error_code := NVL(l_error_code, 'No Error');
        l_error_msg  := NVL(l_error_msg, 'No Error');

        IF l_error_num <> 0
        THEN
		IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
			, G_MODULE_HEAD || l_routine || '.others'
			, 'cost_inv_txn for cost group '||p_cost_group_id||' txn id '
	                 ||l_upd_val_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg
                    );
		END IF;

		FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
	        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
	        FND_MESSAGE.set_token('MESSAGE', 'cost_inv_txn for cost group '||p_cost_group_id||' txn id '
	                                 ||l_upd_val_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg);
	        FND_MSG_PUB.Add;
	        RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;


  END LOOP;
  IF (CSTPPINV.l_item_id_tbl.COUNT > 0) THEN
        CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cost_group_id
                                 ,i_txn_category      => l_txn_category
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.inscppb'
                        ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
        END IF;

  END IF;

   IF (l_error_num = 0 AND l_loop_count > 0) THEN
        CSTPPWAC.update_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cost_group_id
                                 ,i_txn_category      => l_txn_category
                                 ,i_low_level_code => -2
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.updcppb3'
                        ,'After calling update_item_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
        END IF;

      END IF;

      IF l_error_num <> 0
      THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_HEAD || l_routine || '.others'
                    , 'Error for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg
                    );
	END IF;

        FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
        FND_MESSAGE.set_token('MESSAGE', 'Error for cost group '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
 WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END Periodic_Cost_Update;

--========================================================================
-- PROCEDURE : Process Cost Owned Transactions   PRIVATE
-- COMMENT   : Run the cost processor for all cost owned items
--=========================================================================
PROCEDURE process_cst_own_txns
( p_period_id                 IN NUMBER
, p_legal_entity              IN NUMBER
, p_cost_type_id              IN NUMBER
, p_cost_group_id             IN NUMBER
, p_cost_method               IN NUMBER
, p_start_date                IN DATE
, p_end_date                  IN DATE
, p_pac_rates_id              IN NUMBER
, p_master_org_id             IN NUMBER
, p_uom_control               IN NUMBER
, p_user_id                   IN NUMBER
, p_login_id                  IN NUMBER
, p_req_id                    IN NUMBER
, p_prg_id                    IN NUMBER
, p_prg_appid                 IN NUMBER
)
IS

l_routine CONSTANT VARCHAR2(30) := 'process_cst_own_txns';
--=================
-- CURSORS
--=================

-- ===========================================================
-- Cursor to get Group 1 (cost owned) transactions
-- Normal cost owned txns
-- Interorg transactions across Cost Groups originating from
-- Sales Orders or internal requisitions when the transfer
-- price profile option value is 2 - Yes, Transfer Price as
-- incoming cost;
-- Transaction Source Type Id is 7 for Internal Requisition
-- and 8 for Internal Order
-- OPM Convergence - transaction action id 15 for logical
-- intransit receipt to be processed for the receiving CG
-- Direct interorg receipt due to OPM org to be processed for
-- the receiving org
-- ===========================================================
CURSOR cst_own_txns(c_period_start_date     DATE
                   ,c_period_end_date       DATE
                   ,c_cost_group_id         NUMBER
                   )
IS
SELECT mmt.transaction_id  transaction_id
     , mmt.transaction_action_id transaction_action_id
     , mmt.transaction_source_type_id transaction_source_type_id
     , mmt.inventory_item_id inventory_item_id
     , mmt.primary_quantity primary_quantity
     , mmt.organization_id organization_id
     , NVL(mmt.transfer_organization_id,-1) transfer_organization_id
     , mmt.subinventory_code subinventory_code
     , nvl(mmt.transfer_price,0) transfer_price
FROM mtl_material_transactions mmt
   , cst_cost_group_assignments ccga
WHERE mmt.transaction_date BETWEEN c_period_start_date
  AND c_period_end_date
  AND ccga.organization_id = mmt.organization_id
  AND ccga.cost_group_id = c_cost_group_id
  AND mmt.organization_id = nvl(mmt.owning_organization_id,mmt.organization_id)
  AND nvl(mmt.owning_tp_type,2) = 2
  AND mmt.parent_transaction_id is null
  AND mmt.transaction_type_id <> 20
  AND (transaction_source_type_id = 1
       OR transaction_action_id = 29
       OR ((transaction_action_id = 1
            OR transaction_action_id = 27
            OR transaction_action_id = 6)
         AND transaction_source_type_id IN (3,6,13)
         AND transaction_cost IS NOT NULL)
       OR (transaction_action_id = 27 AND transaction_source_type_id = 12))
UNION
SELECT
  mmt1.transaction_id   transaction_id
, mmt1.transaction_action_id   transaction_action_id
, mmt1.transaction_source_type_id  transaction_source_type_id
, mmt1.inventory_item_id  inventory_item_id
, mmt1.primary_quantity   primary_quantity
, mmt1.organization_id  organization_id
, nvl(mmt1.transfer_organization_id,-1) transfer_organization_id
, mmt1.subinventory_code  subinventory_code
, nvl(mmt1.transfer_price,0) transfer_price
FROM
  mtl_material_transactions mmt1
, mtl_parameters mp1
WHERE mmt1.transaction_date BETWEEN c_period_start_date AND c_period_end_date
  AND mmt1.organization_id = nvl(mmt1.owning_organization_id, mmt1.organization_id)
  AND nvl(mmt1.owning_tp_type,2) = 2
  AND mmt1.organization_id = mp1.organization_id
  AND nvl(mp1.process_enabled_flag,'N') = 'N'
  AND EXISTS (SELECT 'X'
	      FROM  mtl_intercompany_parameters mip
	      WHERE nvl(fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER'),0) = 1
  		AND mip.flow_type = 1
		AND nvl(fnd_profile.value('CST_TRANSFER_PRICING_OPTION'),0) = 2
	        AND mip.ship_organization_id = (select to_number(hoi.org_information3)
		                                from hr_organization_information hoi
				                where hoi.organization_id = decode(mmt1.transaction_action_id,21,
						                             mmt1.organization_id,mmt1.transfer_organization_id)
						  AND hoi.org_information_context = 'Accounting Information')
		AND mip.sell_organization_id = (select to_number(hoi2.org_information3)
		 			        from  hr_organization_information hoi2
						where hoi2.organization_id = decode(mmt1.transaction_action_id,21,
						                                    mmt1.transfer_organization_id, mmt1.organization_id)
						  AND hoi2.org_information_context = 'Accounting Information'))
  AND NOT EXISTS ( SELECT 'X'
                   FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
                   WHERE c1.organization_id = mmt1.organization_id
                     AND c2.organization_id = mmt1.transfer_organization_id
                     AND c1.cost_group_id = c2.cost_group_id)
  AND (
      (mmt1.transaction_action_id = 3 AND mmt1.transaction_source_type_id = 8
       AND EXISTS ( SELECT 'X'
                    FROM cst_cost_group_assignments ccga1
                    WHERE ccga1.cost_group_id = c_cost_group_id
                      AND ccga1.organization_id = mmt1.organization_id
                      AND mmt1.primary_quantity > 0))
    OR (mmt1.transaction_action_id = 21 AND mmt1.transaction_source_type_id IN (7,8)
        AND EXISTS ( SELECT 'X'
                     FROM mtl_interorg_parameters mip,
                          cst_cost_group_assignments ccga2
                     WHERE mip.from_organization_id = mmt1.organization_id
                       AND mip.to_organization_id   = mmt1.transfer_organization_id
                       AND nvl(mmt1.fob_point,mip.fob_point) = 1
                       AND ccga2.organization_id = mip.to_organization_id
                       AND ccga2.cost_group_id = c_cost_group_id))
    OR (mmt1.transaction_action_id = 12 AND mmt1.transaction_source_type_id IN (7,8)
        AND EXISTS ( SELECT 'X'
                     FROM mtl_interorg_parameters mip,
                          cst_cost_group_assignments ccga2
                     WHERE mip.from_organization_id = mmt1.transfer_organization_id
                       AND mip.to_organization_id = mmt1.organization_id
                       AND nvl(mmt1.fob_point,mip.fob_point) = 2
                       AND ccga2.organization_id = mip.to_organization_id
                       AND ccga2.cost_group_id = c_cost_group_id)))
UNION
SELECT
  mmt2.transaction_id   transaction_id
, mmt2.transaction_action_id   transaction_action_id
, mmt2.transaction_source_type_id  transaction_source_type_id
, mmt2.inventory_item_id  inventory_item_id
, mmt2.primary_quantity   primary_quantity
, mmt2.organization_id  organization_id
, nvl(mmt2.transfer_organization_id,-1) transfer_organization_id
, mmt2.subinventory_code  subinventory_code
, nvl(mmt2.transfer_price,0) transfer_price
FROM
  mtl_material_transactions mmt2
, mtl_parameters mp2
WHERE mmt2.transaction_date BETWEEN c_period_start_date AND c_period_end_date
  AND mmt2.organization_id = nvl(mmt2.owning_organization_id, mmt2.organization_id)
  AND nvl(mmt2.owning_tp_type,2) = 2
  AND mmt2.organization_id = mp2.organization_id
  AND nvl(mp2.process_enabled_flag,'N') = 'N'
  AND mmt2.primary_quantity > 0
  AND NOT EXISTS ( SELECT 'X'
                   FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
                   WHERE c1.organization_id = mmt2.organization_id
                     AND c2.organization_id = mmt2.transfer_organization_id
                     AND c1.cost_group_id = c2.cost_group_id)
  AND (
      (mmt2.transaction_action_id = 15
      AND EXISTS ( SELECT 'X'
                   FROM cst_cost_group_assignments ccga2
                   WHERE ccga2.organization_id  =  mmt2.organization_id
                     AND ccga2.cost_group_id = c_cost_group_id))
    OR (mmt2.transaction_action_id = 3
       AND EXISTS ( SELECT 'X'
                    FROM cst_cost_group_assignments ccga3
                        ,mtl_parameters mp3
                    WHERE mp3.organization_id = mmt2.transfer_organization_id
                      AND nvl(mp3.process_enabled_flag,'N') = 'Y'
                      AND ccga3.organization_id  = mmt2.organization_id
                      AND ccga3.cost_group_id = c_cost_group_id ))
      )
ORDER BY inventory_item_id;

TYPE cst_own_txns_type IS TABLE OF cst_own_txns%rowtype INDEX BY BINARY_INTEGER;

l_cst_own_txns_tab	cst_own_txns_type;
l_empty_cst_own_txns_tab cst_own_txns_type;
--=================
-- VARIABLES
--=================

l_error_num        NUMBER;
l_error_code       VARCHAR2(240);
l_error_msg        VARCHAR2(240);
l_exp_flag         NUMBER;
l_exp_item         NUMBER;
l_process_group    NUMBER := 1;

l_txn_category     NUMBER;
l_batch_size       NUMBER := 200;
l_loop_count       NUMBER := 0;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || 'Daterange'
                  ,'Start Date:' || p_start_date || ' End Date:' ||
                   p_end_date
                  );
  END IF;

  -- initialize transaction category for group 1 cost owned transactions
  l_txn_category := 3;

  IF NOT cst_own_txns%ISOPEN
  THEN
    OPEN cst_own_txns(p_start_date
                     ,p_end_date
                     ,p_cost_group_id
                     );
  END IF;

  LOOP
	  -- clear the pl/sql table before use
	  l_cst_own_txns_tab := l_empty_cst_own_txns_tab;
	  FETCH cst_own_txns BULK COLLECT INTO l_cst_own_txns_tab LIMIT l_batch_size;

	  l_loop_count := l_cst_own_txns_tab.COUNT;

	  FOR i IN 1..l_loop_count
	  LOOP

	      CST_PERIODIC_ABSORPTION_PROC.get_exp_flag(p_item_id             => l_cst_own_txns_tab(i).inventory_item_id
						       ,p_org_id              => l_cst_own_txns_tab(i).organization_id
						       ,p_subinventory_code   => l_cst_own_txns_tab(i).subinventory_code
						       ,x_exp_flag            => l_exp_flag
						       ,x_exp_item            => l_exp_item);

	      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  ,G_MODULE_HEAD || l_routine || '.befcostinvtxn'
                  ,'Before calling cost_inv_txn: Cost Group Id:' ||
                   p_cost_group_id || ' Txn Id:' || l_cst_own_txns_tab(i).transaction_id
                  );
	      END IF;

	      -- insert into cppb
	      l_error_num := 0;

	      IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000) THEN
			CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
						,i_cost_group_id     => p_cost_group_id
						,i_txn_category      => l_txn_category
						,i_user_id           => p_user_id
						,i_login_id          => p_login_id
						,i_request_id        => p_req_id
						,i_prog_id           => p_prg_id
						,i_prog_appl_id      => p_prg_appid
						,o_err_num           => l_error_num
						,o_err_code          => l_error_code
						,o_err_msg           => l_error_msg
						);
	        l_error_num  := NVL(l_error_num, 0);
                l_error_code := NVL(l_error_code, 'No Error');
                l_error_msg  := NVL(l_error_msg, 'No Error');

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.string(FND_LOG.LEVEL_STATEMENT
				,G_MODULE_HEAD || l_routine || '.inscppb'
	                        ,'After calling insert_into_cppb1:'|| l_error_num || l_error_code || l_error_msg
		                );
			END IF;
	      END IF;

	      IF l_error_num = 0 THEN

			CSTPPINV.cost_inv_txn(i_pac_period_id       => p_period_id
	  				     ,i_legal_entity        => p_legal_entity
	                 		     ,i_cost_type_id        => p_cost_type_id
					     ,i_cost_group_id       => p_cost_group_id
					     ,i_cost_method         => p_cost_method
					     ,i_txn_id              => l_cst_own_txns_tab(i).transaction_id
					     ,i_txn_action_id       => l_cst_own_txns_tab(i).transaction_action_id
					     ,i_txn_src_type_id     => l_cst_own_txns_tab(i).transaction_source_type_id
					     ,i_item_id             => l_cst_own_txns_tab(i).inventory_item_id
					     ,i_txn_qty             => l_cst_own_txns_tab(i).primary_quantity
					     ,i_txn_org_id          => l_cst_own_txns_tab(i).organization_id
					     ,i_txfr_org_id         => l_cst_own_txns_tab(i).transfer_organization_id
					     ,i_subinventory_code   => l_cst_own_txns_tab(i).subinventory_code
					     ,i_exp_flag            => l_exp_flag
					     ,i_exp_item            => l_exp_item
					     ,i_pac_rates_id        => p_pac_rates_id
					     ,i_process_group       => l_process_group
					     ,i_master_org_id       => p_master_org_id
					     ,i_uom_control         => p_uom_control
					     ,i_user_id             => p_user_id
					     ,i_login_id            => p_login_id
					     ,i_request_id          => p_req_id
					     ,i_prog_id             => p_prg_id
					     ,i_prog_appl_id        => p_prg_appid
					     ,i_txn_category        => l_txn_category
					     ,i_transfer_price_pd   => l_cst_own_txns_tab(i).transfer_price
					     ,o_err_num             => l_error_num
					     ,o_err_code            => l_error_code
					     ,o_err_msg             => l_error_msg);

			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.string(FND_LOG.LEVEL_STATEMENT
				,G_MODULE_HEAD || l_routine || '.befcostinvtxn'
				,'After calling cost_inv_txn:'|| l_error_num || l_error_code || l_error_msg
				);
			END IF;

	      END IF; -- error num check

	      l_error_num  := NVL(l_error_num, 0);
	      l_error_code := NVL(l_error_code, 'No Error');
	      l_error_msg  := NVL(l_error_msg, 'No Error');

	      IF l_error_num <> 0
	      THEN
			IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
				, G_MODULE_HEAD || l_routine || '.others'
	                        , 'cost_inv_txn for cost group '||p_cost_group_id||' txn id '
	                                 ||l_cst_own_txns_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg
		                );
			END IF;
			FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
			FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
			FND_MESSAGE.set_token('MESSAGE', 'cost_inv_txn for cost group '||p_cost_group_id||' txn id '
	                                 ||l_cst_own_txns_tab(i).transaction_id||' ('||l_error_code||') '||l_error_msg);
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
	      END IF;
          END LOOP; --	FOR i IN 1..l_loop_count

	EXIT WHEN cst_own_txns%NOTFOUND;
      END LOOP; --	FETCH loop
      CLOSE cst_own_txns;
      -- ======================================================
      -- insert left over cost owned transactions into cppb
      -- ======================================================
      l_error_num := 0;

      IF (CSTPPINV.l_item_id_tbl.COUNT > 0) THEN
        CSTPPWAC.insert_into_cppb(i_pac_period_id     => p_period_id
                                 ,i_cost_group_id     => p_cost_group_id
                                 ,i_txn_category      => l_txn_category
                                 ,i_user_id           => p_user_id
                                 ,i_login_id          => p_login_id
                                 ,i_request_id        => p_req_id
                                 ,i_prog_id           => p_prg_id
                                 ,i_prog_appl_id      => p_prg_appid
                                 ,o_err_num           => l_error_num
                                 ,o_err_code          => l_error_code
                                 ,o_err_msg           => l_error_msg
                                 );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.inscppb2'
                        ,'After calling insert_into_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
        END IF;

      END IF;

      IF l_error_num = 0 THEN
        CSTPPWAC.update_cppb(i_pac_period_id     => p_period_id
                            ,i_cost_group_id     => p_cost_group_id
                            ,i_txn_category      => l_txn_category
                            ,i_low_level_code    => -2
                            ,i_user_id           => p_user_id
                            ,i_login_id          => p_login_id
                            ,i_request_id        => p_req_id
                            ,i_prog_id           => p_prg_id
                            ,i_prog_appl_id      => p_prg_appid
                            ,o_err_num           => l_error_num
                            ,o_err_code          => l_error_code
                            ,o_err_msg           => l_error_msg
                            );

          l_error_num  := NVL(l_error_num, 0);
          l_error_code := NVL(l_error_code, 'No Error');
          l_error_msg  := NVL(l_error_msg, 'No Error');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_HEAD || l_routine || '.updcppb1'
                        ,'After calling update_cppb:'|| l_error_num || l_error_code || l_error_msg
                        );
        END IF;

      END IF;

      IF l_error_num <> 0
      THEN
        FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
        FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
        FND_MESSAGE.set_token('MESSAGE', 'Error in insert/update cppb for '||p_cost_group_id||' ('||l_error_code||') '||l_error_msg);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

 EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
 WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_INTERORG_PAC_ERROR');
    FND_MESSAGE.set_token('ROUTINE', G_PKG_NAME||'.'||l_routine);
    FND_MESSAGE.set_token('MESSAGE', '('||SQLCODE||') '||SQLERRM);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END process_cst_own_txns;

--========================================================================
-- PROCEDURE :  Process cost owned txns  PRIVATE
-- COMMENT   :
--=========================================================================

PROCEDURE Process_group1_txns_partial
       (p_period_id         IN NUMBER
       ,p_legal_entity      IN NUMBER
       ,p_master_org_id     IN NUMBER
       ,p_start_date        IN DATE
       ,p_end_date          IN DATE
       ,p_cost_group_id     IN NUMBER
       ,p_cost_method       IN NUMBER
       ,p_cost_type_id      IN NUMBER
       ,p_pac_rates_id      IN NUMBER
       ,p_uom_control       IN NUMBER
       ,p_user_id           IN NUMBER
       ,p_login_id          IN NUMBER
       ,p_req_id            IN NUMBER
       ,p_prg_id            IN NUMBER
       ,p_prg_appid         IN NUMBER
 )
IS
l_cost_update_type            NUMBER;
BEGIN
   l_cost_update_type := 1;

    -- Periodic Cost Update New cost, %ge change for all items
    periodic_cost_update
     (p_period_id           => p_period_id
     ,p_legal_entity        => p_legal_entity
     ,p_cost_type_id        => p_cost_type_id
     ,p_cost_group_id       => p_cost_group_id
     ,p_cost_method         => p_cost_method
     ,p_start_date          => p_start_date
     ,p_end_date            => p_end_date
     ,p_pac_rates_id        => p_pac_rates_id
     ,p_master_org_id       => p_master_org_id
     ,p_cost_update_type    => l_cost_update_type
     ,p_uom_control         => p_uom_control
     ,p_user_id             => p_user_id
     ,p_login_id            => p_login_id
     ,p_req_id              => p_req_id
     ,p_prg_id              => p_prg_id
     ,p_prg_appid           => p_prg_appid);

    -- Process Group 1 for All items
     process_cst_own_txns
     (p_period_id              => p_period_id
     ,p_legal_entity           => p_legal_entity
     ,p_cost_type_id           => p_cost_type_id
     ,p_cost_group_id          => p_cost_group_id
     ,p_cost_method            => p_cost_method
     ,p_start_date             => p_start_date
     ,p_end_date               => p_end_date
     ,p_pac_rates_id           => p_pac_rates_id
     ,p_master_org_id          => p_master_org_id
     ,p_uom_control            => p_uom_control
     ,p_user_id                => p_user_id
     ,p_login_id               => p_login_id
     ,p_req_id                 => p_req_id
     ,p_prg_id                 => p_prg_id
     ,p_prg_appid              => p_prg_appid);

END  Process_group1_txns_partial;

--========================================================================
-- PROCEDURE : Begin_Cost_Processor_Worker     PUBLIC
-- COMMENT   : This procedure will process phases 1-4 for all transactions
--=========================================================================
PROCEDURE begin_cp_worker
( x_errbuf                 OUT NOCOPY VARCHAR2
, x_retcode                OUT NOCOPY VARCHAR2
, p_legal_entity           IN  NUMBER
, p_cost_type_id           IN  NUMBER
, p_master_org_id          IN  NUMBER
, p_cost_method            IN  NUMBER
, p_cost_group_id          IN  NUMBER
, p_period_id              IN  NUMBER
, p_prev_period_id         IN  NUMBER
, p_starting_phase         IN  NUMBER
, p_pac_rates_id           IN  NUMBER
, p_uom_control            IN  NUMBER
, p_start_date             IN  DATE
, p_end_date               IN  DATE
)
IS

l_routine CONSTANT VARCHAR2(30) := 'begin_cp_worker';

--=================
-- VARIABLES
--=================

l_current_index    BINARY_INTEGER;
l_prg_appid        NUMBER;
l_prg_id           NUMBER;
l_req_id           NUMBER;
l_user_id          NUMBER;
l_login_id         NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;
    -- Getting Program Information
  l_prg_appid := FND_GLOBAL.prog_appl_id;
  l_prg_id    := FND_GLOBAL.conc_program_id;
  l_req_id    := FND_GLOBAL.conc_request_id;
  l_user_id   := FND_GLOBAL.user_id;
  l_login_id  := FND_GLOBAL.login_id;

    IF p_starting_phase = 1  THEN
   -- Run the Acquisition Cost Processor if the run option
      -- is start or Resume from error and acquisition process not complete

       run_acquisition_cp
       (p_period_id         => p_period_id
       ,p_start_date        => p_start_date
       ,p_end_date          => p_end_date
       ,p_legal_entity      => p_legal_entity
       ,p_cost_type_id      => p_cost_type_id
       ,p_cost_group_id     => p_cost_group_id
       ,p_user_id           => l_user_id
       ,p_login_id          => l_login_id
       ,p_req_id            => l_req_id
       ,p_prg_id            => l_prg_id
       ,p_prg_appid         => l_prg_appid);

    END IF;

    IF p_starting_phase < 3  THEN

      -- Copy the balance from the previous period if the run option
      -- is start or a previous run did not complete this phase

       copy_balance
       (p_period_id         => p_period_id
       ,p_prev_period_id    => p_prev_period_id
       ,p_end_date          => p_end_date
       ,p_legal_entity      => p_legal_entity
       ,p_cost_type_id      => p_cost_type_id
       ,p_cost_group_id     => p_cost_group_id
       ,p_cost_method       => p_cost_method
       ,p_user_id           => l_user_id
       ,p_login_id          => l_login_id
       ,p_req_id            => l_req_id
       ,p_prg_id            => l_prg_id
       ,p_prg_appid         => l_prg_appid
       ,p_starting_phase    => p_starting_phase);

    END IF;

     IF p_starting_phase < 4 THEN

      -- Explode the bill of materials if the run option
      -- is start or a previous run did not complete this phase

       explode_bom
       (p_period_id         => p_period_id
       ,p_cost_group_id     => p_cost_group_id
       ,p_start_date        => p_start_date
       ,p_end_date          => p_end_date
       ,p_user_id           => l_user_id
       ,p_login_id          => l_login_id
       ,p_req_id            => l_req_id
       ,p_prg_id            => l_prg_id
       ,p_prg_appid         => l_prg_appid
       );

    END IF;

    IF p_starting_phase < 5 THEN

       build_job_info
       (p_period_id         => p_period_id
       ,p_start_date        => p_start_date
       ,p_end_date          => p_end_date
       ,p_cost_group_id     => p_cost_group_id
       ,p_cost_type_id      => p_cost_type_id
       ,p_pac_rates_id      => p_pac_rates_id
       ,p_user_id           => l_user_id
       ,p_login_id          => l_login_id
       ,p_req_id            => l_req_id
       ,p_prg_id            => l_prg_id
       ,p_prg_appid         => l_prg_appid);

    END IF;

   --process Periodic Cost update and Cost Owned transactions

      Process_group1_txns_partial
       (p_period_id         => p_period_id
       ,p_legal_entity      => p_legal_entity
       ,p_master_org_id     => p_master_org_id
       ,p_start_date        => p_start_date
       ,p_end_date          => Trunc(p_end_date) + (86399/86400) /*Added timestamp for Bug 8503757*/
       ,p_cost_group_id     => p_cost_group_id
       ,p_cost_method       => p_cost_method
       ,p_cost_type_id      => p_cost_type_id
       ,p_pac_rates_id      => p_pac_rates_id
       ,p_uom_control       => p_uom_control
       ,p_user_id           => l_user_id
       ,p_login_id          => l_login_id
       ,p_req_id            => l_req_id
       ,p_prg_id            => l_prg_id
       ,p_prg_appid         => l_prg_appid);

 -- call retrieve interorg items and at the end set the status of phase 7 for the CG to Running.
      prepare_absorption_process
       (p_period_id         => p_period_id
       ,p_start_date        => p_start_date
       ,p_end_date          => Trunc(p_end_date) + (86399/86400) /*Added timestamp for Bug 8503757*/
       ,p_cost_group_id     => p_cost_group_id
       ,p_cost_type_id      => p_cost_type_id
       ,p_pac_rates_id      => p_pac_rates_id
       ,p_user_id           => l_user_id
       ,p_login_id          => l_login_id
       ,p_req_id            => l_req_id
       ,p_prg_id            => l_prg_id
       ,p_prg_appid         => l_prg_appid);

-- set phase 8 status to 4 success
     set_status
     ( p_period_id        => p_period_id
     , p_cost_group_id    => p_cost_group_id
     , p_phase            => 8
     , p_status           => 4
     , p_end_date         => p_end_date
     , p_user_id          => l_user_id
     , p_login_id         => l_login_id
     , p_req_id           => l_req_id
     , p_prg_id           => l_prg_id
     , p_prg_appid        => l_prg_appid);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
    END IF;

 EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      set_status
     ( p_period_id        => p_period_id
     , p_cost_group_id    => p_cost_group_id
     , p_phase            => 8
     , p_status           => 3
     , p_end_date         => p_end_date
     , p_user_id          => l_user_id
     , p_login_id         => l_login_id
     , p_req_id           => l_req_id
     , p_prg_id           => l_prg_id
     , p_prg_appid        => l_prg_appid);

      set_status
     ( p_period_id        => p_period_id
     , p_cost_group_id    => p_cost_group_id
     , p_phase            => 7
     , p_status           => 3
     , p_end_date         => p_end_date
     , p_user_id          => l_user_id
     , p_login_id         => l_login_id
     , p_req_id           => l_req_id
     , p_prg_id           => l_prg_id
     , p_prg_appid        => l_prg_appid);

      x_retcode := '2';
      x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                          ,1
                          ,250);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine , x_errbuf
                  );
    END IF;

  WHEN OTHERS THEN
      ROLLBACK;
      set_status
     ( p_period_id        => p_period_id
     , p_cost_group_id    => p_cost_group_id
     , p_phase            => 8
     , p_status           => 3
     , p_end_date         => p_end_date
     , p_user_id          => l_user_id
     , p_login_id         => l_login_id
     , p_req_id           => l_req_id
     , p_prg_id           => l_prg_id
     , p_prg_appid        => l_prg_appid);

      set_status
     ( p_period_id        => p_period_id
     , p_cost_group_id    => p_cost_group_id
     , p_phase            => 7
     , p_status           => 3
     , p_end_date         => p_end_date
     , p_user_id          => l_user_id
     , p_login_id         => l_login_id
     , p_req_id           => l_req_id
     , p_prg_id           => l_prg_id
     , p_prg_appid        => l_prg_appid);

      x_errbuf        := SQLCODE || substr(SQLERRM, 1, 200);
      x_retcode := '2';

      FND_FILE.put_line
     ( FND_FILE.log
      , 'Error in begin_cp_worker '|| x_errbuf
     );

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_HEAD || l_routine ||'.others_exc'
                  , 'others:' || x_errbuf
                  );
    END IF;

 END begin_cp_worker;

END CST_PERIODIC_AVERAGE_PROC_CP;

/
