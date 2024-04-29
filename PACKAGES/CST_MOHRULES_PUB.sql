--------------------------------------------------------
--  DDL for Package CST_MOHRULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_MOHRULES_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTMOHRS.pls 115.3 2002/11/08 23:01:54 awwang ship $*/

PROCEDURE insert_row_moh(
p_rule_id               IN      NUMBER,
p_last_update_date      IN      DATE,
p_creation_date         IN      DATE,
p_last_updated_by       IN      NUMBER,
p_created_by            IN      NUMBER,
p_organization_id       IN      NUMBER,
p_earn_moh              IN      NUMBER,
p_transaction_type      IN      NUMBER,
p_selection_criteria    IN      NUMBER DEFAULT NULL,
p_category_id           IN      NUMBER DEFAULT NULL,
p_item_from             IN      NUMBER DEFAULT NULL,
p_item_to               IN      NUMBER DEFAULT NULL,
p_item_type             IN      NUMBER,
p_ship_from_org         IN      NUMBER DEFAULT NULL,
p_cost_type_id          IN      NUMBER,
err_code                OUT NOCOPY     NUMBER,
err_msg                 OUT NOCOPY     VARCHAR2
);

PROCEDURE update_row_moh(
p_rule_id               IN      NUMBER,
p_last_update_date      IN      DATE,
p_last_updated_by       IN      NUMBER,
p_earn_moh              IN      NUMBER,
p_transaction_type      IN      NUMBER,
p_selection_criteria    IN      NUMBER DEFAULT NULL,
p_category_id           IN      NUMBER DEFAULT NULL,
p_item_from             IN      NUMBER DEFAULT NULL,
p_item_to               IN      NUMBER DEFAULT NULL,
p_item_type             IN      NUMBER,
p_ship_from_org         IN      NUMBER DEFAULT NULL,
p_cost_type_id          IN      NUMBER,
err_code                OUT NOCOPY     NUMBER,
err_msg                 OUT NOCOPY     VARCHAR2
);

PROCEDURE delete_row_moh(
p_rule_id               IN      NUMBER,
err_code                OUT NOCOPY     NUMBER,
err_msg                 OUT NOCOPY     VARCHAR2
);


PROCEDURE apply_moh(
p_api_version           IN      NUMBER,
p_init_msg_list         IN      VARCHAR2   := FND_API.G_FALSE,
p_commit                IN      VARCHAR2   := FND_API.G_FALSE,
p_validation_level      IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
p_organization_id       IN      NUMBER,
p_earn_moh              OUT NOCOPY     NUMBER,
p_txn_id                IN      NUMBER,
p_item_id               IN      NUMBER,
x_return_status         OUT NOCOPY     VARCHAR2,
x_msg_count             OUT NOCOPY     NUMBER,
x_msg_data              OUT NOCOPY     VARCHAR2
);


END;

 

/
