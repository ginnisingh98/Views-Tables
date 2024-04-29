--------------------------------------------------------
--  DDL for Package Body CST_MOHRULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_MOHRULES_PUB" AS
/* $Header: CSTMOHRB.pls 120.1.12010000.2 2010/01/20 02:52:25 jkwac ship $*/

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'cst_mohRules_pub';

PROCEDURE INSERT_ROW_MOH(
p_rule_id               IN      NUMBER,
p_last_update_date      IN      DATE,
p_creation_date         IN      DATE,
p_last_updated_by       IN      NUMBER,
p_created_by            IN      NUMBER,
p_organization_id       IN      NUMBER,
p_earn_moh              IN      NUMBER,
p_transaction_type      IN      NUMBER,
p_selection_criteria    IN      NUMBER ,
p_category_id           IN      NUMBER ,
p_item_from             IN      NUMBER ,
p_item_to               IN      NUMBER ,
p_item_type             IN      NUMBER,
p_ship_from_org         IN      NUMBER ,
p_cost_type_id          IN      NUMBER,
err_code                OUT     NOCOPY NUMBER,
err_msg                 OUT     NOCOPY VARCHAR2 ) IS

l_stmt_num              NUMBER;
l_api_name    CONSTANT        VARCHAR2(30) := 'Insert_Row_MOH';
l_api_version CONSTANT        NUMBER       := 1.0;



BEGIN

     ---------------------------------------------
      --  Standard start of API savepoint
      ---------------------------------------------
      SAVEPOINT insert_row_moh;

      -------------------------------------------------------------
      --  Initialize API return status to Success
      -------------------------------------------------------------
      l_stmt_num := 30;
      err_code :=0;

        l_stmt_num := 40;

	INSERT INTO cst_material_ovhd_rules
        (rule_id,
 	last_update_date,
    	creation_date,
	last_updated_by,
	created_by,
	organization_id,
	selection_criteria,
	earn_moh,
        item_type,
	cost_type_id,
	ship_from_org,
	category_id,
	item_from,
	item_to,
        transaction_type
        )
        VALUES
        (p_rule_id,
        p_last_update_date,
        p_creation_date,
        p_last_updated_by,
        p_created_by,
        p_organization_id,
        p_selection_criteria,
        p_earn_moh,
        p_item_type,
        p_cost_type_id,
        p_ship_from_org,
        p_category_id,
        p_item_from,
        p_item_to,
        p_transaction_type
        );

EXCEPTION
  WHEN OTHERS THEN
  err_msg := 'CST_MOH_RULES_PUB.insert_row_moh(' ||l_stmt_num|| '): Error while inserting';
  err_code := -1;
  ROLLBACK;
END insert_row_moh;


PROCEDURE update_row_moh(
p_rule_id               IN      NUMBER,
p_last_update_date      IN      DATE,
p_last_updated_by       IN      NUMBER,
p_earn_moh              IN      NUMBER,
p_transaction_type      IN      NUMBER,
p_selection_criteria    IN      NUMBER ,
p_category_id           IN      NUMBER ,
p_item_from             IN      NUMBER ,
p_item_to               IN      NUMBER ,
p_item_type             IN      NUMBER,
p_ship_from_org         IN      NUMBER ,
p_cost_type_id          IN      NUMBER,
err_code                OUT     NOCOPY NUMBER,
err_msg                 OUT     NOCOPY VARCHAR2
) IS

BEGIN
    err_code := 0;

    UPDATE cst_material_ovhd_rules
    SET    last_update_date = p_last_update_date,
           last_updated_by  = p_last_updated_by,
           earn_moh         = p_earn_moh,
           selection_criteria = p_selection_criteria,
           category_id      = p_category_id,
           item_from        = p_item_from,
           item_to          = p_item_to ,
           item_type        = p_item_type,
           ship_from_org    = p_ship_from_org,
           cost_type_id     = p_cost_type_id
    WHERE  rule_id = p_rule_id;


EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     err_code := -1;
     err_msg := sqlerrm;

END update_row_moh;

PROCEDURE delete_row_moh(
p_rule_id               IN      NUMBER,
err_code                OUT     NOCOPY NUMBER,
err_msg                 OUT     NOCOPY VARCHAR2
) IS

BEGIN

  err_code := 0;

  DELETE  FROM cst_material_ovhd_rules
  WHERE   rule_id = p_rule_id;


EXCEPTION
  WHEN OTHERS THEN
   ROLLBACK;
   err_code := -1;
   err_msg := sqlerrm;

END delete_row_moh;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   apply_moh                                                            --
--                                                                        --
-- DESCRIPTION                                                            --
-- This API determines if default MOH absorption is overriden for the     --
-- given transaction.                                                     --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.8                                        --
-- Rules Engine for MOH Absorption                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    12/03/01     Anju Gupta        Created                              --
----------------------------------------------------------------------------

PROCEDURE apply_moh(
p_api_version           IN      NUMBER,
p_init_msg_list         IN      VARCHAR2   := FND_API.G_FALSE,
p_commit                IN      VARCHAR2   := FND_API.G_FALSE,
p_validation_level      IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
p_organization_id       IN      NUMBER,
p_earn_moh              OUT     NOCOPY NUMBER,
p_txn_id                IN      NUMBER,
p_item_id               IN      NUMBER,
x_return_status         OUT     NOCOPY VARCHAR2,
x_msg_count             OUT     NOCOPY NUMBER,
x_msg_data              OUT     NOCOPY VARCHAR2 ) IS

l_api_name    CONSTANT  VARCHAR2(30) := 'apply_moh';
l_api_version CONSTANT  NUMBER       := 1.0;

l_api_message           VARCHAR2(240);

l_txn_type_id           NUMBER;
l_txn_action_id         NUMBER;
l_txn_type              NUMBER;
l_source_type_id        NUMBER;
l_stmt_num              NUMBER;
l_item_id               NUMBER;
l_item_type             NUMBER;
l_count                 NUMBER;
l_rule_item_type        NUMBER;
l_earn_moh              NUMBER;
l_rule_count            NUMBER;
l_debug                 VARCHAR2(80);
l_rule_id               NUMBER;

BEGIN

      l_debug := fnd_profile.value('MRP_DEBUG');

      ------------------------------------------------
      --  Standard call to check for API compatibility
      ------------------------------------------------
      l_stmt_num := 10;
      IF not fnd_api.compatible_api_call (
                                  l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME ) then
            RAISE fnd_api.G_exc_unexpected_error;
      END IF;

      ------------------------------------------------------------

      ------------------------------------------------------------
      -- Initialize message list if p_init_msg_list is set to TRUE
      -------------------------------------------------------------
      l_stmt_num := 20;
      IF fnd_api.to_Boolean(p_init_msg_list) then
          fnd_msg_pub.initialize;
      end if;

      -------------------------------------------------------------
      --  Initialize API return status to Success
      -------------------------------------------------------------
      l_stmt_num := 30;
      x_return_status := fnd_api.g_ret_sts_success;

       -------------------------------------------------------------
      -- Select transaction and item details.Treat RTV
      -- like PO Receipt txnx
      -------------------------------------------------------------

      l_stmt_num := 40;
      p_earn_moh := 1;
      l_txn_type := 0;

      IF (l_debug = 'Y') THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'IN Rule Package CST_MOHRULES_PUB.apply_moh');
      END IF;

       SELECT mmt.transaction_type_id,  mmt.transaction_source_type_id, mmt.transaction_action_id
       INTO   l_txn_type_id, l_source_type_id, l_txn_action_id
       FROM   mtl_material_transactions mmt
       WHERE  transaction_id = p_txn_id;

       l_stmt_num := 50;

       SELECT planning_make_buy_code
       INTO   l_item_type
       FROM   mtl_system_items
       WHERE  inventory_item_id = p_item_id
       AND    organization_id = p_organization_id;

       l_stmt_num := 60;

       IF (l_source_type_id = 1 and ((l_txn_action_id = 27) or (l_txn_action_id = 1) or (l_txn_action_id = 29))) THEN    /*PO Receipt/RTV*/
           l_txn_type := 1;
       ELSIF (l_source_type_id = 5 and ((l_txn_action_id = 32) or (l_txn_action_id = 31))) THEN
                                     /* Assembly Completion/Return */
           l_txn_type := 2;
       ELSIF (l_source_type_id = 8 and l_txn_action_id = 3) THEN /*Internal Order direct transfer */
           l_txn_type := 3;
       ELSIF (l_source_type_id = 13 and l_txn_action_id = 3) THEN /* Inventory direct transfer */
           l_txn_type := 4;
       --
       -- Bug 5021305: Added txn types (65, 76) and (59, 60) for process/discrete xfers.
       --
       ELSIF ((l_source_type_id = 7 and l_txn_action_id = 12)
           or (l_source_type_id = 7 and l_txn_action_id = 29)
           or (l_source_type_id = 8 and l_txn_action_id = 21)
           or (l_source_type_id = 8 and l_txn_action_id = 22)
           or (l_source_type_id = 7 and l_txn_action_id = 15)) THEN /* internal intransit*/
           l_txn_type := 5;
       ELSIF (l_source_type_id = 13 and ((l_txn_action_id = 12) or (l_txn_action_id = 21) or (l_txn_action_id = 29) or (l_txn_action_id = 15) or (l_txn_action_id = 22))) THEN /* inventory intransit*/
           l_txn_type := 6;
       ELSIF ((l_source_type_id = 1 and l_txn_action_id = 6)
           or (l_source_type_id = 13 and l_txn_action_id = 6)) THEN  /*Consigned ownership transfer transactions*/
           l_txn_type := 7;
       END IF;

       l_stmt_num := 70;

       IF (l_debug = 'Y') THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_txn_type:' || l_txn_type);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_txn_type_id:' || l_txn_type_id);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'organization_id:' || p_organization_id);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'item_type:'|| l_item_type);
       END IF;

       IF(l_txn_type <> 0) THEN

         BEGIN
           SELECT count(*)
           INTO   l_count
           FROM   cst_material_ovhd_rules
           WHERE  transaction_type = l_txn_type
           AND    organization_id = p_organization_id;

           IF (l_count > 0 ) THEN
             BEGIN
               SELECT earn_moh, rule_id, count(*)
               INTO   p_earn_moh,l_rule_id, l_rule_count
               FROM   cst_material_ovhd_rules
               WHERE  transaction_type = l_txn_type
               AND    organization_id = p_organization_id
               AND    item_type = l_item_type
               GROUP BY earn_moh, rule_id;
              EXCEPTION
                WHEN others THEN
                l_rule_count := 0;
              END;

             IF (l_rule_count = 0) THEN
               SELECT earn_moh, rule_id,count(*)
               INTO   p_earn_moh,l_rule_id,l_rule_count
               FROM   cst_material_ovhd_rules
               WHERE  transaction_type = l_txn_type
               AND    organization_id = p_organization_id
               AND    item_type = 3
               GROUP BY earn_moh, rule_id;
             END IF;

         END IF;
       EXCEPTION
         WHEN others THEN
           p_earn_moh := 1;
       END;
       END IF;

      IF(l_count > 1) THEN
        FND_MESSAGE.SET_NAME('BOM', 'CST_RULE_MULTIPLE');
        FND_MESSAGE.SET_TOKEN('RULE_ID',l_rule_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
      END IF;

       IF (l_debug = 'Y') THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'earn moh :' || p_earn_moh);
       END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error then
       x_return_status := fnd_api.g_ret_sts_error;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN fnd_api.g_exc_unexpected_error then
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      If fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
           fnd_msg_pub.add_exc_msg
          ( 'CST_MOH_RULES_PUB','apply_moh : Statement - ' || to_char(l_stmt_num));
      end if;

      fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data );

END apply_moh;


END;

/
