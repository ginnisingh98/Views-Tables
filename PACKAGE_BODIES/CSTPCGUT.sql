--------------------------------------------------------
--  DDL for Package Body CSTPCGUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPCGUT" AS
/* $Header: CSTCGUTB.pls 120.1 2005/08/26 12:00:44 awwang noship $ */




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
                            p_cost_group_type_id         IN      NUMBER) IS

 l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                  INTEGER := 0;
 l_statement                NUMBER;
 l_miss_num            	    NUMBER := FND_API.G_MISS_NUM;


 CURSOR c_cost_group is SELECT ccg.cost_group_id
                          FROM cst_cost_groups ccg,
                               cst_cost_group_accounts cca
                         WHERE ccg.cost_group_id = cca.cost_group_id
                           AND NVL(ccg.organization_id, p_organization_id)
					= cca.organization_id
                           AND ccg.cost_group_type  = p_cost_group_type_id
                           AND sysdate <= nvl(ccg.disable_date, sysdate)
                           AND NVL(ccg.organization_id, p_organization_id )
					= p_organization_id
			   AND (p_material_account = l_miss_num
         			OR (p_material_account IS NULL AND cca.material_account IS NULL)
         			OR p_material_account = cca.material_account
         			)
                           AND (p_material_overhead_account = l_miss_num
                                OR (p_material_overhead_account IS NULL AND cca.material_overhead_account IS NULL)
                                OR p_material_overhead_account = cca.material_overhead_account
                                )
                           AND (p_resource_account = l_miss_num
                                OR (p_resource_account IS NULL AND cca.resource_account IS NULL)
                                OR p_resource_account = cca.resource_account
                                )
                           AND (p_overhead_account = l_miss_num
                                OR (p_overhead_account IS NULL AND cca.overhead_account IS NULL)
                                OR p_overhead_account = cca.overhead_account
                                )
                           AND (p_outside_processing_account = l_miss_num
                                OR (p_outside_processing_account IS NULL AND cca.outside_processing_account IS NULL)
                                OR p_outside_processing_account = cca.outside_processing_account
                                )
                           AND (p_expense_account = l_miss_num
                                OR (p_expense_account IS NULL AND cca.expense_account IS NULL)
                                OR p_expense_account = cca.expense_account
                                )
                           AND (p_encumbrance_account = l_miss_num
                                OR (p_encumbrance_account IS NULL AND cca.encumbrance_account IS NULL)
                                OR p_encumbrance_account = cca.encumbrance_account
                                )
                           AND (p_average_cost_var_account = l_miss_num
                                OR (p_average_cost_var_account IS NULL AND cca.average_cost_var_account IS NULL)
                                OR p_average_cost_var_account = cca.average_cost_var_account
                                )
                           AND (p_payback_mat_var_account = l_miss_num
                                OR (p_payback_mat_var_account IS NULL AND cca.payback_mat_var_account IS NULL)
                                OR p_payback_mat_var_account = cca.payback_mat_var_account
                                )
                           AND (p_payback_res_var_account = l_miss_num
                                OR (p_payback_res_var_account IS NULL AND cca.payback_res_var_account IS NULL)
                                OR p_payback_res_var_account = cca.payback_res_var_account
                                )
                           AND (p_payback_osp_var_account = l_miss_num
                                OR (p_payback_osp_var_account IS NULL AND cca.payback_osp_var_account IS NULL)
                                OR p_payback_osp_var_account = cca.payback_osp_var_account
                                )
                           AND (p_payback_moh_var_account = l_miss_num
                                OR (p_payback_moh_var_account IS NULL AND cca.payback_moh_var_account IS NULL)
                                OR p_payback_moh_var_account = cca.payback_moh_var_account
                                )
                           AND (p_payback_ovh_var_account = l_miss_num
                                OR (p_payback_ovh_var_account IS NULL AND cca.payback_ovh_var_account IS NULL)
                                OR p_payback_ovh_var_account = cca.payback_ovh_var_account
                                );




 BEGIN

    IF p_organization_id IS NULL THEN

        RAISE fnd_api.g_exc_error;
    END IF;

 FOR rec_cost_group IN  c_cost_group LOOP

 l_statement := 10;
    l_counter := l_counter + 1;
    x_cost_group_id_tbl( l_counter) := rec_cost_group.cost_group_id;

 END LOOP;
 l_statement := 20;
 x_count  := l_counter;
 x_return_status := l_return_status;

 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CSTPCGUT'
              , 'GET_COST_GROUP : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END get_cost_group;


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
                            p_multi_org                  IN      NUMBER DEFAULT 2) IS


    l_last_updated_by         NUMBER := fnd_global.user_id;
    l_last_update_login       NUMBER := fnd_global.login_id;
    l_request_id              NUMBER := fnd_global.conc_request_id;
    l_program_application_id  NUMBER := fnd_global.prog_appl_id;
    l_program_id              NUMBER := fnd_global.conc_program_id;
    l_sysdate                 DATE   := SYSDATE;
    l_return_status           VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_cost_group_id           NUMBER;
    l_statement               NUMBER;
    l_count                   NUMBER;
    l_cost_group              VARCHAR2(15);

 BEGIN

     SAVEPOINT create_CG;

   l_statement := 10;
   IF p_cost_group IS NOT NULL THEN
    SELECT COUNT(*)
      INTO l_count
      FROM CST_COST_GROUPS
     WHERE COST_GROUP = p_cost_group;

      IF l_count <> 0 THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF p_organization_id IS NULL THEN

        RAISE fnd_api.g_exc_error;
    END IF;

    l_statement := 20;

    SELECT cst_cost_groups_s.NEXTVAL
      INTO l_cost_group_id
      FROM  dual;
    l_statement := 30;

    IF p_cost_group IS  NULL THEN
      l_cost_group := 'CG-'||to_char(l_cost_group_id);
    ELSE
      l_cost_group := p_cost_group;
    END IF;


     l_statement := 40;

    INSERT INTO CST_COST_GROUPS( COST_GROUP_ID,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 REQUEST_ID,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID ,
                                 PROGRAM_UPDATE_DATE,
                                 ORGANIZATION_ID,
                                 COST_GROUP,
                                 COST_GROUP_TYPE)
                         VALUES (l_cost_group_id,
                                 l_sysdate,
                                 l_last_updated_by,
                                 l_sysdate,
                                 l_last_updated_by,
                                 l_last_update_login,
                                 l_request_id,
                                 l_program_application_id,
                                 l_program_id,
                                 l_sysdate,
                                 decode (p_multi_org, 1, NULL, p_organization_id),
                                 l_cost_group,
                                 p_cost_group_type_id);

     l_statement := 50;

    INSERT INTO CST_COST_GROUP_ACCOUNTS( COST_GROUP_ID,
                                    ORGANIZATION_ID,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_LOGIN,
                                    REQUEST_ID,
                                    PROGRAM_APPLICATION_ID,
                                    PROGRAM_ID ,
                                    PROGRAM_UPDATE_DATE,
                                    MATERIAL_ACCOUNT,
                                    MATERIAL_OVERHEAD_ACCOUNT,
                                    RESOURCE_ACCOUNT,
                                    OVERHEAD_ACCOUNT,
                                    OUTSIDE_PROCESSING_ACCOUNT,
                                    ENCUMBRANCE_ACCOUNT,
                                    EXPENSE_ACCOUNT,
                                    AVERAGE_COST_VAR_ACCOUNT,
                                    PAYBACK_MAT_VAR_ACCOUNT,
                                    PAYBACK_RES_VAR_ACCOUNT,
                                    PAYBACK_OSP_VAR_ACCOUNT,
                                    PAYBACK_MOH_VAR_ACCOUNT,
                                    PAYBACK_OVH_VAR_ACCOUNT)
                         VALUES (l_cost_group_id,
                                 p_organization_id,
                                 l_sysdate,
                                 l_last_updated_by,
                                 l_sysdate,
                                 l_last_updated_by,
                                 l_last_update_login,
                                 l_request_id,
                                 l_program_application_id,
                                 l_program_id,
                                 l_sysdate,
                                 p_material_account,
                                 p_material_overhead_account,
                                 p_resource_account,
                                 p_overhead_account,
                                 p_outside_processing_account,
                                 p_encumbrance_account,
                                 p_expense_account,
                                 p_average_cost_var_account,
                                 p_payback_mat_var_account,
                                 p_payback_res_var_account,
                                 p_payback_osp_var_account,
                                 p_payback_moh_var_account,
                                 p_payback_ovh_var_account);
 x_cost_group_id := l_cost_group_id;
 x_return_status := l_return_status;

 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

   ROLLBACK WORK TO SAVEPOINT create_CG;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

   ROLLBACK WORK TO SAVEPOINT create_CG;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CSTPCGUT'
              , 'CREATE_COST_GROUP : Statement -'||to_char(l_statement)
              );
        END IF;

        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      ROLLBACK WORK TO SAVEPOINT create_CG;
 END;

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
				   p_organization_id            IN      NUMBER
					) IS


 l_statement     NUMBER;
 BEGIN


    IF p_organization_id IS NULL OR
       p_cost_group_id IS NULL THEN

        RAISE fnd_api.g_exc_error;
    END IF;


 l_statement := 10;

  SELECT  MATERIAL_ACCOUNT,
          MATERIAL_OVERHEAD_ACCOUNT,
          RESOURCE_ACCOUNT,
          OVERHEAD_ACCOUNT,
          OUTSIDE_PROCESSING_ACCOUNT,
          ENCUMBRANCE_ACCOUNT,
          EXPENSE_ACCOUNT,
          AVERAGE_COST_VAR_ACCOUNT,
          PAYBACK_MAT_VAR_ACCOUNT,
          PAYBACK_RES_VAR_ACCOUNT,
          PAYBACK_OSP_VAR_ACCOUNT,
          PAYBACK_MOH_VAR_ACCOUNT,
          PAYBACK_OVH_VAR_ACCOUNT

   INTO   x_material_account,
          x_material_overhead_account,
          x_resource_account,
          x_overhead_account,
          x_outside_processing_account,
          x_encumbrance_account,
          x_expense_account,
          x_average_cost_var_account,
          x_payback_mat_var_account,
          x_payback_res_var_account,
          x_payback_osp_var_account,
          x_payback_moh_var_account,
          x_payback_ovh_var_account
   FROM  CST_COST_GROUP_ACCOUNTS
  WHERE  COST_GROUP_ID =  p_cost_group_id
  AND	 ORGANIZATION_ID = p_organization_id ;

  x_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CSTPCGUT'
              , 'GET_COST_GROUP_ACCOUNTS : Statement - '||to_char(l_statement)
              );
        END IF;
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

 END;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   verify_cg_change                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to verify if changing the accounts of a cost group--
--   is allowed. Replaces get_cg_pending_txns.                            --
--                                                                        --
--   Allow the change of accounts if the following conditions are met:    --
--   1. Cost group / org holds no quantity inside MOQ                     --
--   2. Cost group / org holds no quantity inside CQL                     --
--   3. No uncosted transactions for this cost group / org                --
--   4. No pending transactions for this cost group / org                 --
----------------------------------------------------------------------------

PROCEDURE      verify_cg_change(x_return_status              OUT NOCOPY     VARCHAR2,
                                x_msg_count                  OUT NOCOPY     NUMBER,
                                x_msg_data                   OUT NOCOPY     VARCHAR2,
                                x_change_allowed             OUT NOCOPY     NUMBER,
                                p_cost_group_id              IN      NUMBER,
                                p_organization_id            IN      NUMBER) IS

  l_statement     NUMBER;
  l_cost_method   NUMBER;

BEGIN

  x_change_allowed := 0;
  l_cost_method    := 0;

  l_statement := 10;

  SELECT COUNT(*)
  INTO   x_change_allowed
  FROM   mtl_onhand_quantities
  WHERE  organization_id = p_organization_id
  AND    cost_group_id = p_cost_group_id
  AND    rownum = 1;

  IF x_change_allowed = 1 THEN
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
  END IF;

  l_statement := 20;

  SELECT primary_cost_method
  INTO   l_cost_method
  FROM   mtl_parameters
  WHERE  organization_id = p_organization_id;

  IF l_cost_method <> 1 THEN
    SELECT COUNT(*)
    INTO   x_change_allowed
    FROM   cst_quantity_layers
    WHERE  organization_id = p_organization_id
    AND    cost_group_id = p_cost_group_id
    AND    layer_quantity <> 0
    AND    rownum = 1;

    IF x_change_allowed = 1 THEN
     x_return_status := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;
  END IF;

  l_statement := 30;

  SELECT COUNT(*)
  INTO   x_change_allowed
  FROM   mtl_material_transactions_temp
  WHERE  (
           (    organization_id = p_organization_id
            AND cost_group_id = p_cost_group_id
           )
          OR
           (    transfer_organization = p_organization_id
            AND transfer_cost_group_id = p_cost_group_id
           )
         )
  AND    rownum = 1;

  IF x_change_allowed = 1 THEN
   x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
  END IF;

  l_statement := 40;

  SELECT COUNT(*)
  INTO   x_change_allowed
  FROM   mtl_material_transactions
  WHERE  costed_flag in ('N','E')
  AND    (
           (    organization_id = p_organization_id
            AND cost_group_id = p_cost_group_id
           )
          OR
           (    transfer_organization_id = p_organization_id
            AND transfer_cost_group_id = p_cost_group_id
           )
         )
  AND    rownum = 1;

  IF x_change_allowed = 1 THEN
   x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CSTPCGUT'
              , 'VERIFY_CG_CHANGE : Statement - '||to_char(l_statement)
              );
        END IF;
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END;

end CSTPCGUT;

/
