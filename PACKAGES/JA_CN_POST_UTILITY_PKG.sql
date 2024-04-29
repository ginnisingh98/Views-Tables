--------------------------------------------------------
--  DDL for Package JA_CN_POST_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_POST_UTILITY_PKG" AUTHID CURRENT_USER AS
--$Header: JACNPSTS.pls 120.0.12000000.1 2007/08/13 14:09:46 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNPSTS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used in account and journal itemizatoin to post   |
--|     the CNAO journal to CNAO balance                                  |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE post_journal_itemized                                  |
--|      PROCEDURE open_period                                            |
--|                                                                       |
--| HISTORY                                                               |
--|      05/21/2006     Jogen Hu          Created                         |
--+======================================================================*/

--==========================================================================
--  PROCEDURE NAME:
--    post_journal_itemized                     Public
--
--  DESCRIPTION:
--      	This procedure is used to open a period which had never post
--        journal from "Itemized journal table" to "Itemized balance table"
--
--  PARAMETERS:
--      In: p_period_name          	     the end period name in which
--                                       the CNAO journal should be processed
--          p_ledger_id                  Ledger ID
--          p_legal_entity_ID            Legal entity id

--
--  DESIGN REFERENCES:
--      None
--
--  CHANGE HISTORY:
--	    02/21/2006     Jogen Hu          Created
--      04/28/2007     Qingjun Zhao      Change P_set_of_books_id to P_ledger_id
--===========================================================================
PROCEDURE post_journal_itemized
( p_period_name          IN        VARCHAR2
,p_ledger_id       IN        NUMBER
, p_legal_entity_ID      IN        NUMBER
);


END JA_CN_POST_UTILITY_PKG;

 

/
