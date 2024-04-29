--------------------------------------------------------
--  DDL for Package CSTPOYUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPOYUT" AUTHID CURRENT_USER AS
/* $Header: CSTOYUTS.pls 115.3 2002/11/08 23:23:26 awwang ship $ */

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   update_mat_cost                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to update operation cost in WIP_OPERATION_YIELDS   --
--   from material cost manager.                                          --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--  i_cost_type_id    : Cost Type id                                      --
--  i_txn_id          : Material Transaction Id                           --
--  i_org_id          : Organization Id                                   --
--  i_op_seq_num      : Operation Sequence Number                         --
--  i_item_id         : Inventory Item id                                 --
--  i_txn_qty         : Transaction quanity                               --
--  i_entity_id       : WIP Entity Id                                     --
--  i_entity_type     : WIP Entity Type                                   --
--                                                                        --
-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

Function update_mat_cost (i_cost_type_id            IN   NUMBER,
                          i_txn_id                  IN   NUMBER,
                          i_org_id                  IN   NUMBER,
                          i_op_seq_num              IN   NUMBER,
                          i_item_id                 IN   NUMBER,
                          i_txn_qty                 IN   NUMBER,
                          i_entity_id               IN   NUMBER,
                          i_entity_type             IN   NUMBER,
                          i_user_id                 IN   NUMBER,
                          i_login_id                IN   NUMBER,
                          i_prg_appl_id             IN   NUMBER,
                          i_prg_id                  IN   NUMBER,
                          i_req_id                  IN   NUMBER)
RETURN Number;

---------------------------------------------------------------------------
-- FUNCTION                                                               --
--  update_wip_cost                                                       --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to update operation cost in WIP_OPERATION_YIELDS   --
--   from WIP cost manager.                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_group_id     : group_id                                   --
-- RETURNS                                                                --
--     1 : Success                                                        --
--     0 : Failure                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
Function update_wip_cost (i_group_id       IN   NUMBER,
                          i_user_id        IN   NUMBER,
                          i_login_id       IN   NUMBER,
                          i_prg_appl_id    IN   NUMBER,
                          i_prg_id         IN   NUMBER,
                          i_req_id         IN   NUMBER,
                          o_err_msg      OUT NOCOPY  VARCHAR2)
return Number;

 ---------------------------------------------------------------------------
-- FUNCTION                                                               --
--  update_woy_status                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to update status of WIP_OPERATION_YIELDS when      --
--   scrap transaction takes place.                                       --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_org_id        : Organization Id                           --
--            i_wip_entity_id : WIP Entity Id                             --
--            i_op_seq_num    : Operation Sequence Number                 --
-- RETURNS                                                                --
--     1 : Success                                                        --
--     0 : Failure                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    02/12/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
Function update_woy_status (i_org_id              NUMBER,
                            i_wip_entity_id       NUMBER,
                            i_op_seq_num          NUMBER,
                            i_user_id        IN   NUMBER,
                            i_login_id       IN   NUMBER,
                            i_prg_appl_id    IN   NUMBER,
                            i_prg_id         IN   NUMBER,
                            i_req_id         IN   NUMBER,
                            o_err_num        OUT NOCOPY  NUMBER,
                            o_err_code     OUT NOCOPY  VARCHAR2,
                            o_err_msg      OUT NOCOPY  VARCHAR2)
return NUMBER;


end CSTPOYUT;

 

/
