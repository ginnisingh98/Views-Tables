--------------------------------------------------------
--  DDL for Package QP_LIMIT_CONC_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIMIT_CONC_REQ" AUTHID CURRENT_USER AS
/* $Header: QPXTRANS.pls 120.1 2005/06/09 04:08:41 appldev  $ */

---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    QPXTRANS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of concurrent program package QP_LIMIT_CONC_REQ             |
--|                                                                       |
--| HISTORY                                                               |
--|    21-May-2001 abprasad    Created                                    |
--|                                                                       |
--+======================================================================


--========================================================================
-- PROCEDURE : Update_Balances       PUBLIC
-- PARAMETERS:
--   x_retcode                  OUT VARCHAR2
--   x_errbuf                   OUT VARCHAR2
--   p_list_header_id           Identifier for the Modifier List
--   p_list_line_id             Identifier for the  Modifier line( Null or -1)
--   p_limit_id                 Identifier for limit
--   p_limit_balance_id         Identifier for the balance
--
-- COMMENT   : This is the concurrent program for updating the balances
--             once manual transactions are created. The scope of updation
--             can be Modifier level, Modifier line level, Limit balance
--             level or all levels.
--
--========================================================================
PROCEDURE Update_Balances
( x_retcode                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_errbuf                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, p_list_header_id          IN NUMBER default null
, p_list_line_id            IN NUMBER default null  -- Must be -1 or null
, p_limit_id                IN NUMBER default null
, p_limit_balance_id        IN NUMBER  default null
) ;

END QP_LIMIT_CONC_REQ;


 

/
