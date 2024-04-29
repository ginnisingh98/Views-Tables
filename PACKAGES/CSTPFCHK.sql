--------------------------------------------------------
--  DDL for Package CSTPFCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPFCHK" AUTHID CURRENT_USER AS
--$Header: CSTFCHKS.pls 120.1.12010000.3 2008/11/10 13:14:27 anjha ship $
--+==========================================================================+
--|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA         |
--|                          All rights reserved.                            |
--+==========================================================================+
--|                                                                          |
--| File Name	: CSTFCHKS.pls                                               |
--| Description	: Cost Method specific processing extension                  |
--|                                                                          |
--| Revision                                                                 |
--|  11/12/98	Jung Ha    Creation                                          |
--|  10/11/04   vjavli  OUT NOCOPY added for GSSC std                        |
--|  10/12/2004 vjavli  Header correction for proper version from mainline   |
--|                     11.5.8                                               |
--|  02/07/2008 vjavli  Bug 6751847 performance fix: added parameter         |
--|                     txn_category in procedures compute_pac_cost_hook,    |
--|                     calc_pac_cost_hook, and periodic_cost_update_hook    |
--+==========================================================================+

-- FUNCTION
--  compute_pac_cost_hook
--
function compute_pac_cost_hook(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_ORG_ID		IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_PAC_RATES_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_TXN_SRC_TYPE_ID 	IN	NUMBER,
  I_INTERORG_REC	IN	NUMBER,
  I_ACROSS_CGS		IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer;



-- PROCEDURE
--  calc_pac_cost_hook
--
procedure calc_pac_cost_hook(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_ISSUE_QTY		IN	NUMBER,
  I_BUY_QTY		IN	NUMBER,
  I_MAKE_QTY		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID		IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID 	IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);



-- PROCEDURE
--  current_pac_cost_hook
--
procedure current_pac_cost_hook(
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_ISSUE_QTY		IN	NUMBER,
  I_BUY_QTY		IN	NUMBER,
  I_MAKE_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_NO_UPDATE_QTY 	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID		IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID 	IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);


FUNCTION pac_wip_issue_cost_hook(
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_ORG_ID              IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_COST_TYPE_ID        IN      NUMBER,
  I_COST_METHOD         IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_COST_LAYER_ID       IN      NUMBER,
  I_QTY_LAYER_ID        IN      NUMBER,
  I_PAC_RATES_ID        IN      NUMBER,
  I_ITEM_ID             IN      NUMBER,
  I_PRI_QTY             IN      NUMBER,
  I_TXN_ACTION_ID       IN      NUMBER,
  I_ENTITY_ID           IN      NUMBER,
  I_LINE_ID             IN      NUMBER,
  I_OP_SEQ              IN      NUMBER,
  I_EXP_FLAG            IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2
)
return integer;

-- PROCEDURE
--  copy_prior_info_hook
--
procedure copy_prior_info_hook(
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_PRIOR_PAC_PERIOD_ID IN      NUMBER,
  I_LEGAL_ENTITY        IN      NUMBER,
  I_COST_TYPE_ID        IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_COST_METHOD         IN	NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQUEST_ID          IN      NUMBER,
  I_PROG_APP_ID         IN      NUMBER,
  I_PROG_ID             IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2
);

-- ===================================================
-- Periodic Cost Update invoked for Incremental LIFO.
-- The procedure is a copy from BOM115100 inorder to
-- prevent regression.  The regression is due to
-- cppb insert/update introduced in R12 code
-- ===================================================
PROCEDURE periodic_cost_update_hook (
  I_PAC_PERIOD_ID       IN            NUMBER,
  I_COST_GROUP_ID       IN            NUMBER,
  I_COST_TYPE_ID        IN            NUMBER,
  I_TXN_ID              IN            NUMBER,
  I_COST_LAYER_ID       IN            NUMBER,
  I_QTY_LAYER_ID        IN            NUMBER,
  I_ITEM_ID             IN            NUMBER,
  I_USER_ID             IN            NUMBER,
  I_LOGIN_ID            IN            NUMBER,
  I_REQ_ID              IN            NUMBER,
  I_PRG_APPL_ID         IN            NUMBER,
  I_PRG_ID              IN            NUMBER,
  I_TXN_CATEGORY        IN            NUMBER,
  I_TXN_QTY             IN            NUMBER,
  O_Err_Num             OUT NOCOPY    NUMBER,
  O_Err_Code            OUT NOCOPY    VARCHAR2,
  O_Err_Msg             OUT NOCOPY    VARCHAR2);

END CSTPFCHK;

/
