--------------------------------------------------------
--  DDL for Package PV_MATCH_V3_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_MATCH_V3_PUB" AUTHID CURRENT_USER AS
/* $Header: pvxmtv3s.pls 120.4 2006/05/23 22:00:59 dhii noship $*/


g_from_match_lov_flag           BOOLEAN      := FALSE;

   -- --------------------------------------------------------------------
   -- This is used for caching the rule-attribute-value information
   -- for all the opportunity selection rules.
   --
   -- last_attr_flag is used for indicating the last attribute in the rule.
   -- count is used for determining whether a attribute record is involved
   -- in an AND/OR logic.  If count = 1, the logic is AND. If count > 1,
   -- the logic is OR.
   -- --------------------------------------------------------------------
   TYPE t_opp_selection_rec IS RECORD (
      rank                  NUMBER,
      process_rule_id       NUMBER,
      attribute_id          NUMBER,
      currency_code         VARCHAR2(15),
      operator              VARCHAR2(30),
      selection_criteria_id NUMBER,
      attribute_value       VARCHAR2(500),
      attribute_to_value    VARCHAR2(500),
      last_attr_flag        VARCHAR2(1),
      count                 NUMBER
   );

TYPE t_opp_selection_tab IS TABLE OF t_opp_selection_rec
    INDEX BY BINARY_INTEGER;

g_opp_selection_tab t_opp_selection_tab;

Procedure Manual_match(
    p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_attr_id_tbl           IN OUT NOCOPY   JTF_NUMBER_TABLE,
    p_attr_value_tbl        IN OUT NOCOPY   JTF_VARCHAR2_TABLE_4000,
    p_attr_operator_tbl     IN OUT NOCOPY   JTF_VARCHAR2_TABLE_100,
    p_attr_data_type_tbl    IN OUT NOCOPY   JTF_VARCHAR2_TABLE_100,
    p_attr_selection_mode   IN     VARCHAR2,
    p_att_delmter           IN     VARCHAR2,
    p_selection_criteria    IN     VARCHAR2,
    p_resource_id           IN     NUMBER,
    p_lead_id               IN     NUMBER,
    p_auto_match_flag       IN     VARCHAR2,
    p_get_distance_flag     IN     VARCHAR2 := 'F',
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_top_n_rows_by_profile IN     VARCHAR2 := 'T'
);

PROCEDURE Partner_Selection(
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2  := FND_API.g_false,
   p_commit                 IN  VARCHAR2  := FND_API.g_false,
   p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full,
   p_process_rule_id        IN  NUMBER,
   p_entity_id              IN  NUMBER,
   p_entity                 IN  VARCHAR2,
   p_user_name              IN  VARCHAR2  := NULL,
   p_resource_id            IN  NUMBER    := NULL,
   p_routing_flag           IN  VARCHAR2,
   x_partner_cnt            OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE Clear_Rules_Cache;


PROCEDURE Opportunity_Selection(
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2  := FND_API.g_false,
   p_commit                 IN  VARCHAR2  := FND_API.g_false,
   p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full,
   p_entity_id              IN  NUMBER,
   p_entity                 IN  VARCHAR2,
   p_user_name              IN  VARCHAR2  := NULL,
   p_resource_id            IN  NUMBER    := NULL,
   x_selected_rule_id       OUT NOCOPY NUMBER,
   x_matched_partner_count  OUT NOCOPY NUMBER,
   x_failure_code           OUT NOCOPY VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE Opportunity_Selection(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.g_false,
    p_commit                 IN  VARCHAR2  := FND_API.g_false,
    p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full,
    p_entity_id              IN  NUMBER,
    p_entity                 IN  VARCHAR2,
    p_user_name              IN  VARCHAR2  := NULL,
    p_resource_id            IN  NUMBER    := NULL,
    p_routing_flag           IN  VARCHAR2  := 'N',
    x_partner_cnt            OUT NOCOPY NUMBER,
    x_partner_details        OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
    x_flagcount              OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    x_distance_tbl           OUT NOCOPY JTF_NUMBER_TABLE,
    x_distance_uom_returned  OUT NOCOPY VARCHAR2,
    x_selected_rule_id       OUT NOCOPY NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
);

Procedure Get_Matched_Partner_Details(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_lead_id               IN  NUMBER,
    p_matched_id            IN  OUT NOCOPY JTF_NUMBER_TABLE,
    p_distance_tbl          IN  JTF_NUMBER_TABLE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
);

FUNCTION get_partner_types (partner_id NUMBER)
RETURN VARCHAR2;

FUNCTION get_attribute_value (attribute_id NUMBER ,partner_id NUMBER)
RETURN VARCHAR2;

FUNCTION get_metric_value(attribute_id NUMBER ,partner_id NUMBER)
RETURN NUMBER;

FUNCTION get_currency_metric_value(attribute_id NUMBER ,partner_id NUMBER)
RETURN VARCHAR2;

FUNCTION pref_partner_flag (p_lead_id NUMBER, p_partner_id NUMBER)
RETURN VARCHAR2;

FUNCTION lock_flag (p_lead_assign_id NUMBER, p_wf_item_key VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_assign_status_meaning (p_lead_id NUMBER, p_partner_id NUMBER)
RETURN VARCHAR2;

END PV_MATCH_V3_PUB;

 

/
