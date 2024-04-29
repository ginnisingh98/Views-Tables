--------------------------------------------------------
--  DDL for Package CST_MGD_LIFO_COST_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_MGD_LIFO_COST_PROCESSOR" AUTHID CURRENT_USER AS
--$Header: CSTGLCPS.pls 120.1 2005/07/07 12:28:44 vjavli noship $
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    CSTGLCPS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Incremental Lifo Cost Processor                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     1/29/99      DHerring   Created                                   |
--|     2/1/99       DHerring   Compiled                                  |
--|     2/3/99       DHerring   Tested                                    |
--|     2/5/99       DHerring   Re-Formatted to meet MGD standards        |
--|     3/4/99       DHerring   Incorporated feedback from code review    |
--|     7/9/99       Dherring   Added procedure CSTGILEV_TEMP             |
--|     1/29/01      AFerrara   Added procedure get_pac_id                |
--|     			Added procedure check_quantity		  |
--|     04/13/2001   Vjavli     Created procedure lifo_purge for the      |
--|                             purge functionality                       |
--|     04/25/2001   vjavli     order of the parameters modified to       |
--|                             the procedure lifo_purge                  |
--|     12/04/2002   Fdubois    add NOCOPY for OU parameters              |
--|     11/22/2004   vjavli     Logging as per the standards              |
--|     07/08/2005   vjavli     declared variables as per the old stds    |
--+======================================================================*/

--===================
-- GLOBAL CONSTANTS
--===================
G_LOG_ERROR                  CONSTANT NUMBER := 5;
G_LOG_EXCEPTION              CONSTANT NUMBER := 4;
G_LOG_EVENT                  CONSTANT NUMBER := 3;
G_LOG_PROCEDURE              CONSTANT NUMBER := 2;
G_LOG_STATEMENT              CONSTANT NUMBER := 1;

--===============================================
-- CONSTANTS for concurrent program return values
--===============================================
-- Return values for RETCODE parameter (standard for concurrent programs):
RETCODE_SUCCESS                         VARCHAR2(10)    := '0';
RETCODE_WARNING                         VARCHAR2(10)    := '1';
RETCODE_ERROR                           VARCHAR2(10)    := '2';

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

--=========================================================================
-- PROCEDURE  : lifo_cost_processor            PUBLIC
-- PARAMETERS : p_pac_period_id                period id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_user_id                      user id
--            : p_login_id                     login id
--            : p_req_id                       requisition id
--            : p_prg_id                       prg id
--            : p_prg_appl_id                  prg appl id
--            : x_err_num                      error number
--            : x_err_code                     error code
--            : x_err_msg                      error message
-- COMMENT    : Gateway procedure to the three procedures that calcualate
--              incremental LIFO. Called from the pac worker after
--              transactional processing and loops through all inventory
--              items for a particular period.
-- PRE-COND   : The weighted average cost recorded in CST_PAC_ITEM_COSTS
--              for the period must be solely for items bought or made in
--              that period.
--=========================================================================
PROCEDURE lifo_cost_processor
( p_pac_period_id  IN  NUMBER
, p_cost_group_id  IN  NUMBER
, p_cost_type_id   IN  NUMBER
, p_user_id        IN  NUMBER
, p_login_id       IN  NUMBER
, p_req_id         IN  NUMBER
, p_prg_id         IN  NUMBER
, p_prg_appl_id    IN  NUMBER
, x_retcode        OUT NOCOPY NUMBER
, x_errbuff        OUT NOCOPY VARCHAR2
, x_errcode        OUT NOCOPY VARCHAR2
);

--=========================================================================
-- PROCEDURE  : populate_temp_table            PUBLIC
-- PARAMETERS : p_legal_entity                 legal entity
--            : p_pac_period_id                period id
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_item_code_from               beginning of item range
--            : p_item_code_to                 end of item range
--            : x_retcode                      0 success, 1 warning, 2 error
--            : x_errbuff                      error buffer
-- COMMENT    : This Procedure first decides whether to populate
--              the temporary table CSTGILEV_TEMP with summarized
--              or detailed information. The appropriate procedure is then
--              called.
-- PRE-COND   : The procedure is called from a before report trigger in
--              the incremental LIFO evaluation report. The cost processor
--              has already run.
--=========================================================================
PROCEDURE populate_temp_table
( p_legal_entity_id   IN  NUMBER
, p_pac_period_id     IN  NUMBER
, p_cost_group_id     IN  NUMBER
, p_cost_type_id      IN  NUMBER
, p_detailed_report   IN  VARCHAR2
, p_item_code_from    IN  VARCHAR2
, p_item_code_to      IN  VARCHAR2
, x_retcode           OUT NOCOPY NUMBER
, x_errbuff           OUT NOCOPY VARCHAR2
, x_errcode           OUT NOCOPY VARCHAR2
);


--=========================================================================
-- PROCEDURE  : get_period_id		       PUBLIC
-- PARAMETERS : p_interface_id                 interface id
-- 	      : p_legal_entity                 legal entity
--            : p_cost_type_id                 cost type id
--            : p_pac_period_id                period id
--            : p_err_num		       end of item range
--            : p_err_code                     0 success, 1 warning, 2 error
--            : p_err_msg                      error buffer
-- COMMENT    : This procedere gets the period id to manage
--              the LIFO loading layer utility
-- PRE-COND   :
--=========================================================================
PROCEDURE get_pac_id
( p_interface_header_id   IN      NUMBER
, p_legal_entity          IN      NUMBER
, p_cost_type_id          IN      NUMBER
, p_pac_period_id         OUT     NOCOPY NUMBER
, p_err_num               OUT     NOCOPY NUMBER
, p_err_code              OUT     NOCOPY VARCHAR2
, p_err_msg               OUT     NOCOPY VARCHAR2
);



--=========================================================================
-- PROCEDURE  : check_quantity		     PUBLIC
-- PARAMETERS : p_interface_group_id         interface id
--            : p_err_num		     end of item range
--            : p_err_code                   0 success, 1 warning, 2 error
--            : p_err_msg                    error buffer
-- COMMENT    : This procedere check if layer quantity of period n is equal
--              to begin layer quantity of period n+1 for the LIFO loading layer
-- PRE-COND   :
--=========================================================================
PROCEDURE check_quantity
( p_interface_group_id   IN      NUMBER
, p_err_num              OUT     NOCOPY NUMBER
, p_err_code             OUT     NOCOPY VARCHAR2
, p_err_msg              OUT     NOCOPY VARCHAR2
);

--=========================================================================
-- PROCEDURE  : loading_lifo_cost               PUBLIC
-- PARAMETERS : p_interface_header_id        interface unique id
--            : p_user_id                    user id
--            : p_login_id                   login id
--            : p_req_id                     req_id
--            : p_prg_id                     prg_id
--            : p_prg_appl_id                prg_appl_id
--            : x_err_num                    end of item range
--            : x_err_code                   0 success, 1 warning, 2 error
--            : x_err_msg                    error buffer
-- COMMENT    : This procedure reads cost group, period id, item id from
--              the interface header table and uses them as input to
--              the standard procedure that calculates lifo.
-- PRE-COND   :
--=========================================================================
PROCEDURE loading_lifo_cost
(p_interface_group_id    IN      NUMBER
,p_user_id               IN      NUMBER
,p_login_id              IN      NUMBER
,p_req_id                IN      NUMBER
,p_prg_id                IN      NUMBER
,p_prg_appl_id           IN      NUMBER
,x_err_num               OUT     NOCOPY NUMBER
,x_err_code              OUT     NOCOPY VARCHAR2
,x_err_msg               OUT     NOCOPY VARCHAR2
);

--=========================================================================
-- PROCEDURE  : lifo_purge                     PUBLIC
-- PARAMETERS : x_errbuff                      error buffer
--            : x_retcode                      0 success, 1 warning, 2 error
--            : p_legal_entity_id              legal entity
--            : p_cost_group_id                cost group id
--            : p_cost_type_id                 cost type id
--            : p_pac_period_id                period id
--            : p_category_set_name            Item category set name
--            : p_category_struct              Category Structure used by
--                                             category pair
--            : p_category_from                begining of item category
--                                             range
--            : p_category_to                  end of item category range
--            : p_item_from                    beginning of item range
--            : p_item_to                      end of item range
-- COMMENT    : This Procedure purges the historical LIFO layers as per the
--              purge algorithm.  This procedure will invoke the private
--              procedures find_first_period and selective_purge
--=========================================================================
PROCEDURE lifo_purge
(x_errbuff           OUT NOCOPY VARCHAR2
,x_retcode           OUT NOCOPY VARCHAR2
,p_legal_entity_id   IN  NUMBER
,p_cost_group_id     IN  NUMBER
,p_cost_type_id      IN  NUMBER
,p_pac_period_id     IN  NUMBER
,p_category_set_name IN  VARCHAR2
,p_category_struct   IN  NUMBER
,p_category_from     IN  VARCHAR2
,p_category_to       IN  VARCHAR2
,p_item_from         IN  VARCHAR2
,p_item_to           IN  VARCHAR2
);

END CST_MGD_LIFO_COST_PROCESSOR;

 

/
