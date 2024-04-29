--------------------------------------------------------
--  DDL for Package CSTPOYLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPOYLD" AUTHID CURRENT_USER AS
/* $Header: CSTOYLDS.pls 120.1 2006/08/28 05:47:25 rajagraw noship $ */

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   process_op_yield                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to calculate operation yield for lot based jobs.  --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_entity_id    : Wip entity id of lot based job             --
--            i_run_option   : 1 if it is called from standard cost       --
--                             processor and split merge cost processor   --
--                             for txn type Split or Merge                --
--                             2 if is called from standard cost update   --
--                             3 if it is called from split merge cost    --
--                             processor with txn type bonus and update   --
--                             quanitty.                                  --
--            i_txn_op_seq_num :Operation sequence number for bonus and   --
--                              update quantity txn number.               --
--            i_range_option : 1 if it is to run for an organization      --
--                             2 if it is to run for a WIP entity         --
--                                                                        --
-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE  process_op_yield(ERRBUF             OUT NOCOPY VARCHAR2,
                            RETCODE            OUT NOCOPY VARCHAR2,
                            i_range_option         NUMBER,
                            i_entity_id            NUMBER,
                            i_run_option           NUMBER,
                            i_txn_op_seq_num       NUMBER,
                            i_organization_id      NUMBER default NULL,
                            i_sm_txn_id            NUMBER default NULL);

---------------------------------------------------------------------------
-- FUNCTION                                                               --
--  transact_op_yield_var                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate op yield reallocation and op yield    --
--   variance. This function is to be called from discrete job close      --
--   variance program cmlwjv()                                            --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_group_id     : Wip entity id of lot based job             --
-- RETURNS                                                                --
--     1 : Success                                                        --
--     0 : Failure                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
FUNCTION  transact_op_yield_var( i_group_id    IN   NUMBER,
                                 i_user_id     IN   NUMBER,
                                 i_login_id    IN   NUMBER,
                                 i_prg_appl_id IN   NUMBER,
                                 i_prg_id      IN   NUMBER,
                                 i_req_id      IN   NUMBER,
                                 o_err_num     OUT NOCOPY NUMBER,
                                 o_err_code  OUT NOCOPY VARCHAR2,
                                 o_err_msg   OUT NOCOPY VARCHAR2)
return NUMBER;

 ---------------------------------------------------------------------------
-- FUNCTION                                                               --
--  process_sm_op_yld                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate op yield for jobs involved in split   --
--   merge transaction.                                                   --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_txn_id     : split merge txn id                           --
-- RETURNS                                                                --
--     1 : Success                                                        --
--     0 : Failure                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    02/12/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
FUNCTION  process_sm_op_yld    ( i_txn_id      IN   NUMBER,
                                 i_user_id     IN   NUMBER,
                                 i_login_id    IN   NUMBER,
                                 i_prg_appl_id IN   NUMBER,
                                 i_prg_id      IN   NUMBER,
                                 i_req_id      IN   NUMBER,
                                 o_err_num     OUT NOCOPY NUMBER,
                                 o_err_code  OUT NOCOPY VARCHAR2,
                                 o_err_msg   OUT NOCOPY VARCHAR2)

 return NUMBER;

-----------------------------------------------------------------------------
-- FUNCTION
-- cost_update_adjustment
--
-- DESCRIPTION
--   This function is used by the standard cost update program, to adjust the
-- operation cost by the change in unit costs due to cost update
--
-- PURPOSE:
--   Oracle Applications Rel 11i.1, to support WIP ShopFloor Management
--
-- PARAMETERS:
--            i_org_id 		:  Organization ID
--            i_update_id       :  Cost Update ID
-- RETURNS
--      1  :  Success
--      2  :  Failure

--
-- HISTORY
--    03/03/2000    Anitha Balasubramanian   Creation
------------------------------------------------------------------------------
Function cost_update_adjustment (i_org_id 	       NUMBER,
				 i_update_id	       NUMBER,
                                 i_user_id        IN   NUMBER,
                                 i_login_id       IN   NUMBER,
                                 i_prg_appl_id    IN   NUMBER,
                                 i_prg_id         IN   NUMBER,
                                 i_req_id         IN   NUMBER,
                                 o_err_num        OUT NOCOPY  NUMBER,
                                 o_err_code       OUT NOCOPY  VARCHAR2,
                                 o_err_msg        OUT NOCOPY  VARCHAR2)
return NUMBER;
end CSTPOYLD;

 

/
