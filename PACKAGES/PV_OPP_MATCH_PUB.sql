--------------------------------------------------------
--  DDL for Package PV_OPP_MATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_OPP_MATCH_PUB" AUTHID CURRENT_USER AS
/* $Header: pvxvomps.pls 120.3 2006/01/10 13:50:34 amaram noship $ */

   -- ========================================================================
   -- Global Variables Declaration
   -- ========================================================================
   G_PKG_NAME      CONSTANT VARCHAR2(30):= 'PV_OPP_MATCH_PUB';

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


   -- ========================================================================
   -- Procedure Declaration
   -- ========================================================================
   -- --------------------------------------------------------------------
   -- Opportunity/Rule Selection API
   -- --------------------------------------------------------------------
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
      x_partner_tbl            OUT NOCOPY JTF_NUMBER_TABLE,
      x_partner_details        OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
      x_flagcount              OUT NOCOPY JTF_VARCHAR2_TABLE_100,
      x_distance_tbl           OUT NOCOPY JTF_NUMBER_TABLE,
      x_distance_uom_returned  OUT NOCOPY VARCHAR2,
      x_selected_rule_id       OUT NOCOPY NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

   -- --------------------------------------------------------------------
   -- Cache all the ACTIVE Opportunity Selection rules in the system.
   -- --------------------------------------------------------------------
   PROCEDURE Cache_Rules;

   -- --------------------------------------------------------------------
   -- Used for clearing the PL/SQL table that stores Opportunity Selection
   -- Rules.
   -- --------------------------------------------------------------------
   PROCEDURE Clear_Rules_Cache;


   -- --------------------------------------------------------------------
   -- Partner Selection API
   -- --------------------------------------------------------------------
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
      p_incumbent_partner_only IN  VARCHAR2  := 'N',
      x_partner_tbl            OUT NOCOPY JTF_NUMBER_TABLE,
      x_partner_details        OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
      x_flagcount              OUT NOCOPY JTF_VARCHAR2_TABLE_100,
      x_distance_tbl           OUT NOCOPY JTF_NUMBER_TABLE,
      x_distance_uom_returned  OUT NOCOPY VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   );

END pv_opp_match_pub;

 

/
