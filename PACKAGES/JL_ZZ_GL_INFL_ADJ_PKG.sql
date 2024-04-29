--------------------------------------------------------
--  DDL for Package JL_ZZ_GL_INFL_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_GL_INFL_ADJ_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzgaxs.pls 115.2 2002/11/21 02:01:38 vsidhart ship $ */

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   inflation_adjustment                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this process to perform the Inflation Adjustment for Argentina   --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--   Product : Oracle General Ledger - Latin America                      --
--                                                                        --
-- PARAMETERS:                                                            --
--   Inflation Run Id : Execution id                                      --
--   From period      : First period to be adjusted                       --
--   To Period        : Last period to be adjusted                        --
--   Set of Books Id  : Set of books to be adjusted                       --
--   Index Id         : used to adjust the accounts                       --
--   Error Message    : Returned to the report                            --
--   Error Message Number : Idem                                          --
--   Error Message Code : Idem                                            --
--                                                                        --
-- HISTORY:                                                               --
--   19/03/97   German Bertot                                             --
--   20/08/97   German Bertot  Changed the procedure definition to call   --
--                            it from the Infl. Adj. Report instead of    --
--                            submiting it as a concurrent request.       --
----------------------------------------------------------------------------

  FUNCTION INFLATION_ADJUSTMENT (p_inflation_adj_run_id IN NUMBER
                               , p_adjust_from_period   IN VARCHAR2
                               , p_adjust_to_period     IN VARCHAR2
                               , p_set_of_books_id      IN NUMBER
                               , p_infl_adj_index_id    IN NUMBER
                               , p_group_id             IN OUT NOCOPY NUMBER
                               , p_err_msg_name         IN OUT NOCOPY VARCHAR2
                               , p_err_msg_num          IN OUT NOCOPY NUMBER
                               , p_err_msg_code         IN OUT NOCOPY VARCHAR2)
   RETURN NUMBER;

END JL_ZZ_GL_INFL_ADJ_PKG;

 

/
