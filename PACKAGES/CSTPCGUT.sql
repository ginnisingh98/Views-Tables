--------------------------------------------------------
--  DDL for Package CSTPCGUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPCGUT" AUTHID CURRENT_USER AS
/* $Header: CSTCGUTS.pls 120.1 2005/08/26 12:00:19 awwang noship $ */



type cost_group_rec is record
(
 cost_group_id number

);

type cost_group_tbl is table of NUMBER
index by binary_integer;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_cost_group                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to obatain cost groups based on account information.--
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.2                                        --
--                                                                        --

-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE    get_cost_group(x_return_status              OUT NOCOPY     VARCHAR2,
                            x_msg_count                  OUT NOCOPY     NUMBER,
                            x_msg_data                   OUT NOCOPY     VARCHAR2,
                            x_cost_group_id_tbl          OUT NOCOPY     CSTPCGUT.cost_group_tbl,
                            x_count                      OUT NOCOPY     NUMBER,
                            p_material_account           IN      NUMBER default FND_API.G_MISS_NUM,
                            p_material_overhead_account  IN      NUMBER default FND_API.G_MISS_NUM,
                            p_resource_account           IN      NUMBER default FND_API.G_MISS_NUM,
                            p_overhead_account           IN      NUMBER default FND_API.G_MISS_NUM,
                            p_outside_processing_account IN      NUMBER default FND_API.G_MISS_NUM,
                            p_expense_account            IN      NUMBER default FND_API.G_MISS_NUM,
                            p_encumbrance_account        IN      NUMBER default FND_API.G_MISS_NUM,
                            p_average_cost_var_account   IN      NUMBER default FND_API.G_MISS_NUM,
                            p_payback_mat_var_account    IN      NUMBER default FND_API.G_MISS_NUM,
                            p_payback_res_var_account    IN      NUMBER default FND_API.G_MISS_NUM,
                            p_payback_osp_var_account    IN      NUMBER default FND_API.G_MISS_NUM,
                            p_payback_moh_var_account    IN      NUMBER default FND_API.G_MISS_NUM,
                            p_payback_ovh_var_account    IN      NUMBER default FND_API.G_MISS_NUM,
                            p_organization_id            IN      NUMBER ,
                            p_cost_group_type_id         IN      NUMBER);


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   create_cost_group                                                       --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to create a new cost group.                       --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.2                                        --
--                                                                        --
-- Parameter :                                                            --
--  p_multi_org = 1 (Multi org cost group)                                --
--                2 ( Non Multi org cost group)                           --

-- HISTORY:                                                               --
--    05/26/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE  create_cost_group(x_return_status              OUT NOCOPY     VARCHAR2,
                            x_msg_count                  OUT NOCOPY     NUMBER,
                            x_msg_data                   OUT NOCOPY     VARCHAR2,
                            x_cost_group_id              OUT NOCOPY     NUMBER,
                            p_cost_group                 IN      VARCHAR2,
                            p_material_account           IN      NUMBER default NULL,
                            p_material_overhead_account  IN      NUMBER default NULL,
                            p_resource_account           IN      NUMBER default NULL,
                            p_overhead_account           IN      NUMBER default NULL,
                            p_outside_processing_account IN      NUMBER default NULL,
                            p_expense_account            IN      NUMBER default NULL,
                            p_encumbrance_account        IN      NUMBER default NULL,
                            p_average_cost_var_account   IN      NUMBER default NULL,
                            p_payback_mat_var_account    IN      NUMBER default NULL,
                            p_payback_res_var_account    IN      NUMBER default NULL,
                            p_payback_osp_var_account    IN      NUMBER default NULL,
                            p_payback_moh_var_account    IN      NUMBER default NULL,
                            p_payback_ovh_var_account    IN      NUMBER default NULL,
                            p_organization_id            IN      NUMBER,
                            p_cost_group_type_id         IN      NUMBER,
                            p_multi_org                  IN      NUMBER DEFAULT 2);


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_cost_group_accounts                                              --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to obatain cost groups based on account information.--
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.2                                        --
--                                                                        --

-- HISTORY:                                                               --
--    05/26/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
PROCEDURE  get_cost_group_accounts(x_return_status              OUT NOCOPY     VARCHAR2,
                                   x_msg_count                  OUT NOCOPY     NUMBER,
                                   x_msg_data                   OUT NOCOPY     VARCHAR2,
                                   x_material_account           OUT NOCOPY     NUMBER,
                                   x_material_overhead_account  OUT NOCOPY     NUMBER,
                                   x_resource_account           OUT NOCOPY     NUMBER,
                                   x_overhead_account           OUT NOCOPY     NUMBER,
                                   x_outside_processing_account OUT NOCOPY     NUMBER,
                                   x_expense_account            OUT NOCOPY     NUMBER,
                                   x_encumbrance_account        OUT NOCOPY     NUMBER,
                                   x_average_cost_var_account   OUT NOCOPY     NUMBER,
                                   x_payback_mat_var_account    OUT NOCOPY     NUMBER,
                                   x_payback_res_var_account    OUT NOCOPY     NUMBER,
                                   x_payback_osp_var_account    OUT NOCOPY     NUMBER,
                                   x_payback_moh_var_account    OUT NOCOPY     NUMBER,
                                   x_payback_ovh_var_account    OUT NOCOPY     NUMBER,
                                   p_cost_group_id              IN      NUMBER,
			           p_organization_id		IN	NUMBER
				);


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   verify_cg_change                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to verify if changing the accounts of a cost group--
--   is allowed. Replaces get_cg_pending_txns.                            --
----------------------------------------------------------------------------

PROCEDURE      verify_cg_change(x_return_status              OUT NOCOPY     VARCHAR2,
                                x_msg_count                  OUT NOCOPY     NUMBER,
                                x_msg_data                   OUT NOCOPY     VARCHAR2,
                                x_change_allowed             OUT NOCOPY     NUMBER,
                                p_cost_group_id              IN      NUMBER,
                                p_organization_id            IN      NUMBER);


end CSTPCGUT;

 

/
