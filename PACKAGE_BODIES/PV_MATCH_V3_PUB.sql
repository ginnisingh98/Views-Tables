--------------------------------------------------------
--  DDL for Package Body PV_MATCH_V3_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_MATCH_V3_PUB" AS
/* $Header: pvxmtv3b.pls 120.15 2006/09/21 22:27:38 amaram noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_MATCH_V3_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxmtv3b.pls';

/*************************************************************
Almost all of this code has been taken from PV_MATCH_V2_PUB
and PV_OPP_MATCH_PUB. Small modifications have been made to them
to remove the preferred partner logic. This code was duplicated
so that we could have a new set of PL/SQL APIs to handle the new
OA UIs. These UIs expect slightly different things from the APIs
So even thought most of the funtionality is the same it was not
possible to stictly call the older APIs. So we wrote this new set
which for most part is the old code but has the minor mosifications
to cater to the new functionality.
**************************************************************/

g_no_more_rules          CONSTANT NUMBER := 100000000000000;
g_rule_engine_trace_flag VARCHAR2(1);
g_failure_code           VARCHAR2(100) := null;
g_matching_engine_type   VARCHAR2(50);

g_e_buffer_too_small EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_buffer_too_small, -6502);

PROCEDURE debug(p_msg_string       IN VARCHAR2) IS
BEGIN
      FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT', p_msg_string);
      FND_MSG_PUB.Add;
END debug;


PROCEDURE Cache_Rules;

FUNCTION Get_Next_Rule_Index(
   p_current_index     NUMBER,
   p_opp_selection_tab t_opp_selection_tab
)
RETURN NUMBER;

-- --------------------------------------------------------------------
-- Tie-breaking API
-- --------------------------------------------------------------------
PROCEDURE Tie_Breaker(
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2  := FND_API.g_false,
   p_commit                 IN  VARCHAR2  := FND_API.g_false,
   p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full,
   p_process_rule_id        IN  NUMBER,
   x_partner_tbl            IN OUT NOCOPY JTF_NUMBER_TABLE,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------------------
-- The following private routines are used by the tie-breaking API.
-- -----------------------------------------------------------------------------------
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);

PROCEDURE Get_Attr_Length(
   p_attr_value    IN  VARCHAR2,
   p_left_length   OUT NOCOPY NUMBER,
   p_right_length  OUT NOCOPY NUMBER)
;

FUNCTION Convert_To_String(
   p_attr_value             NUMBER,
   p_max_left_length        NUMBER,
   p_max_right_length       NUMBER,
   p_format_string          VARCHAR2,
   p_positive_format_string VARCHAR2,
   p_min_max                VARCHAR2)
RETURN VARCHAR2;


FUNCTION Build_Format_String (
   p_max_left_length  NUMBER,
   p_max_right_length NUMBER)
RETURN VARCHAR2;

-- The Procudures Start Here =================================================

-- ===========================End of Opportunity_Selection=========================
PROCEDURE Opportunity_Selection
(
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
) IS
   l_api_name           VARCHAR2(30) := 'Opportunity_Selection';
   l_return_status      VARCHAR2(100);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(500);
   l_partner_cnt        NUMBER;
   l_partner_details    JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
   l_flagcount          JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100();
   l_distance_tbl       JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE();
   l_distance_uom       VARCHAR2(30);
   l_distance_uom_returned VARCHAR2(30);


BEGIN
   g_failure_code := NULL;
   g_matching_engine_type := 'BACKGROUND_PARTNER_MATCHING';

   Opportunity_Selection(
      p_api_version            => p_api_version,
      p_init_msg_list          => p_init_msg_list,
      p_commit                 => p_commit,
      p_validation_level       => p_validation_level,
      p_entity_id              => p_entity_id,
      p_entity                 => p_entity,
      p_user_name              => p_user_name,
      p_resource_id            => p_resource_id,
      p_routing_flag           => 'Y',
      x_partner_cnt            => l_partner_cnt,
      x_partner_details        => l_partner_details,
      x_flagcount              => l_flagcount,
      x_distance_tbl           => l_distance_tbl,
      x_distance_uom_returned  => l_distance_uom_returned,
      x_selected_rule_id       => x_selected_rule_id,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data
   );

   x_matched_partner_count := l_partner_cnt;

   -- ----------------------------------------------------------------------
   -- Set the failure_code so the caller would know what exactly went wrong.
   -- ----------------------------------------------------------------------
   x_failure_code          := g_failure_code;

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;

   ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );
END Opportunity_Selection;
-- ===========================End of Opportunity_Selection=========================


--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    Opportunity_Selection                                                   |
--|                                                                            |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
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
)
IS
   l_api_version        NUMBER := 1.0;
   l_api_name           VARCHAR2(30) := 'Opportunity_Selection';

   l_entity_attr_value  pv_check_match_pub.t_entity_attr_value;
   l_input_filter       pv_check_match_pub.t_input_filter;
   i                    NUMBER := 1;
   j                    NUMBER;
   l_next_index         NUMBER;
   l_next_rule_id       NUMBER;
   l_stop_flag          BOOLEAN := FALSE;
   l_matched            BOOLEAN;
   l_start              NUMBER;
   l_stop_at_index      NUMBER;
   l_concat_attr_val    VARCHAR2(4000);
   l_concat_to_attr_val VARCHAR2(4000);
   l_dummy              VARCHAR2(4000);
   l_count              NUMBER;
   l_attribute_id       NUMBER;
   l_return_status      VARCHAR2(100);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(500);
   l_delimiter          VARCHAR2(10) := '+++';
   l_partner_cnt        NUMBER;

   -- -----------------------------------------------------------------
   -- Retrieve from a system profile, indicating the type of matching
   -- to be used. Values to be determined:
   --
   -- EXHAUST_ALL_RULES
   -- STOP_AT_FIRST_RULE
   -- -----------------------------------------------------------------
   l_matching_type      VARCHAR2(30);

   l_winning_rule_flag      VARCHAR2(10);
   l_entity_rule_applied_id NUMBER;
   l_attr_val_temp varchar2(4000);

BEGIN
   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -------------------------- Source code --------------------

   -- ------------------------------------------------------------------------
   -- Make sure that either p_user_name or p_resource IS NOT NULL.
   -- ------------------------------------------------------------------------
   IF (p_user_name IS NULL AND p_resource_id IS NULL) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NO_USERNAME_ID_DEFINED',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

      g_failure_code := 'OTHER';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- ------------------------------------------------------------------------
   -- Initialize OUT parameters.
   -- ------------------------------------------------------------------------
   x_partner_details    := JTF_VARCHAR2_TABLE_4000();
   x_flagcount          := JTF_VARCHAR2_TABLE_100();
   x_distance_tbl       := JTF_NUMBER_TABLE();

   -- ------------------------------------------------------------------------
   -- Retrieve profile value for stack trace profile option.
   -- ------------------------------------------------------------------------
   --g_rule_engine_trace_flag := NVL(FND_PROFILE.VALUE('PV_RULE_ENGINE_TRACE_ON'), 'N');

   -- --------------------------------------------------------------------------
   -- Retrieving Matching Type Profile Value, which can be one of the following:
   --
   -- EXHAUST_ALL_RULES
   -- STOP_AT_FIRST_RULE
   -- --------------------------------------------------------------------------
   l_matching_type := NVL(FND_PROFILE.VALUE('PV_PARTNER_MATCHING_TYPE'), 'STOP_AT_FIRST_RULE');


   -- ---------------------------------------------------------------------------------
   -- Cache all the opportunity selection rules (attributes-values) in a global
   -- PL/SQL table, g_opp_selection_tab.
   -- ---------------------------------------------------------------------------------
   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('----------------------------------------------------------------');
      Debug('g_matching_engine_type: ' || g_matching_engine_type);
      Debug('Matching Type:          ' || l_matching_type);
      Debug('----------------------------------------------------------------');

      Debug('Clear Rules Cache.......................................');
   END IF;

   Clear_Rules_Cache;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Rule Caching............................................');
   END IF;

   l_start := dbms_utility.get_time;
   Cache_Rules;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
   END IF;

   l_count := g_opp_selection_tab.COUNT;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Number of Rule items Cached: ' || l_count);
   END IF;

   i := 1;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Opportunity Rule Selection Starts....................................');
   END IF;

   l_start := dbms_utility.get_time;

   WHILE (i <= l_count AND (NOT l_stop_flag)) LOOP
      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('******************************************************');
         Debug('Rule # :::' || g_opp_selection_tab(i).process_rule_id);
      END IF;

      -- ---------------------------------------------------------------------------
      -- If the opportunity's attribute value is not already retrieved, retrieve it.
      -- ---------------------------------------------------------------------------
      l_attribute_id := g_opp_selection_tab(i).attribute_id;

      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Attribute ID:   ' || l_attribute_id);
         Debug('Opportunity ID: ' || p_entity_id);
      END IF;

      pv_check_match_pub.Get_Entity_Attr_Values(
         p_api_version_number => 1.0,
         p_attribute_id       => l_attribute_id,
         p_entity             => p_entity,
         p_entity_id          => p_entity_id,
         p_delimiter          => l_delimiter,
         x_entity_attr_value  => l_entity_attr_value,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data
      );

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- ---------------------------------------------------------------------------
      -- If the attribute value for this entity doesn't exist (which is different
      -- from a NULL), there's a problem. It should have been caught in
      -- Get_Entity_Attr_Values.
      --
      -- Advance to the next rule for evaluation.
      -- ---------------------------------------------------------------------------
      IF (NOT l_entity_attr_value.EXISTS(l_attribute_id)) THEN
         i := Get_Next_Rule_Index(i, g_opp_selection_tab);

         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('No attribute value for this attribute ' || l_attribute_id);
            Debug('There is something wrong in the attribute setup.');
         END IF;

      ELSE

			-- ---------------------------------------------------------------------------
			-- Now we have the attribute value for this attribute, let's compare it with
			-- the attribute value specified in the opportunity selection.
			-- ---------------------------------------------------------------------------
			l_matched := FALSE;

			-- ---------------------------------------------------------------------------
			-- AND logic...
			-- ---------------------------------------------------------------------------
			IF (g_opp_selection_tab(i).count = 1) THEN
				-- ------------------------------------------------------------------------
				-- Use operator to do the match. If the match fails, go to the next rule
				-- until all rules are exhausted.
				-- If the match succeeds, check if last_attr_flag = TRUE. If yes, there's
				-- a match. set l_stop_flag = TRUE
				-- ------------------------------------------------------------------------
				IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
					Debug('Calling Check_Match...AND LOGIC...');
					Debug('p_attribute_id:      ' || l_attribute_id);
					--Debug('p_entity_attr_value: ' || l_entity_attr_value(l_attribute_id).attribute_value);

					l_attr_val_temp := l_entity_attr_value(l_attribute_id).attribute_value;
					while (l_attr_val_temp is not null) loop
						Debug('p_entity_attr_value: ' || substr( l_attr_val_temp, 1, 1800 ) );
						l_attr_val_temp := substr( l_attr_val_temp, 1801 );
					end loop;

					--Debug('p_rule_attr_value:   ' || g_opp_selection_tab(i).attribute_value);
					l_attr_val_temp := g_opp_selection_tab(i).attribute_value;
					while (l_attr_val_temp is not null) loop
						Debug('p_rule_attr_value: ' || substr( l_attr_val_temp, 1, 1800 ) );
						l_attr_val_temp := substr( l_attr_val_temp, 1801 );
					end loop;

					Debug('p_operator:          ' || g_opp_selection_tab(i).operator);
					Debug('p_delimiter:         ' || l_delimiter);
					Debug('p_return_type:   '     || l_entity_attr_value(l_attribute_id).return_type);
				END IF;

				l_matched := pv_check_match_pub.Check_Match(
                         p_attribute_id       => l_attribute_id,
                         p_entity_attr_value  => l_entity_attr_value(l_attribute_id).attribute_value,
                         p_rule_attr_value    => g_opp_selection_tab(i).attribute_value,
                         p_rule_to_attr_value => g_opp_selection_tab(i).attribute_to_value,
                         p_operator           => g_opp_selection_tab(i).operator,
                         p_input_filter       => l_input_filter,
                         p_delimiter          => l_delimiter,
                         p_return_type        => l_entity_attr_value(l_attribute_id).return_type,
                         p_rule_currency_code => g_opp_selection_tab(i).currency_code
                      );

				IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
					IF (l_matched) THEN
						Debug('Check_Match TRUE!');
					ELSE
						Debug('Check_Match FALSE!');
					END IF;
				END IF;

				-- ---------------------------------------------------------------------------
				-- We have an OR logic here. Need special processing...Concatenate all the
				-- attribute values involved in the OR logic into one long string, and pass
				-- this string as the attribute value into Check_Match function.
				-- ---------------------------------------------------------------------------
         ELSE
            -- -------------------------------------------------------------
            -- l_stop_at_index is the index where the current OR logic ends.
            -- -------------------------------------------------------------
            l_stop_at_index   := i + g_opp_selection_tab(i).count - 1;
            l_concat_attr_val := l_delimiter;

            FOR j IN i..l_stop_at_index LOOP
               l_concat_attr_val := l_concat_attr_val ||
                                    g_opp_selection_tab(j).attribute_value || l_delimiter;

               l_concat_to_attr_val := l_concat_to_attr_val ||
                                       g_opp_selection_tab(j).attribute_to_value || l_delimiter;
            END LOOP;

				IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
					Debug('Calling Check_Match...OR Logic');
					Debug('p_attribute_id:      ' || l_attribute_id);
					--Debug('p_entity_attr_value: ' || l_entity_attr_value(l_attribute_id).attribute_value);
					l_attr_val_temp := l_entity_attr_value(l_attribute_id).attribute_value;
					while (l_attr_val_temp is not null) loop
						Debug('p_entity_attr_value: ' || substr( l_attr_val_temp, 1, 1800 ) );
						l_attr_val_temp := substr( l_attr_val_temp, 1801 );
					end loop;

					--Debug('p_rule_attr_value:   ' || l_concat_attr_val);
					l_attr_val_temp := l_concat_attr_val;
					while (l_attr_val_temp is not null) loop
						Debug('p_rule_attr_value: ' || substr( l_attr_val_temp, 1, 1800 ) );
						l_attr_val_temp := substr( l_attr_val_temp, 1801 );
					end loop;

               Debug('p_operator:          ' || g_opp_selection_tab(i).operator);
               Debug('p_delimiter:         ' || l_delimiter);
               Debug('p_return_type:       ' || l_entity_attr_value(l_attribute_id).return_type);
            END IF;

            l_matched := pv_check_match_pub.Check_Match(
                            p_attribute_id       => l_attribute_id,
                            p_entity_attr_value  => l_entity_attr_value(l_attribute_id).attribute_value,
                            p_rule_attr_value    => l_concat_attr_val,
                            p_rule_to_attr_value => l_concat_to_attr_val,
                            p_operator           => g_opp_selection_tab(i).operator,
                            p_input_filter       => l_input_filter,
                            p_delimiter          => l_delimiter,
                            p_return_type        => l_entity_attr_value(l_attribute_id).return_type,
                            p_rule_currency_code => g_opp_selection_tab(i).currency_code
                         );

				IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
					IF (l_matched) THEN
						Debug('Check_Match TRUE!');
					ELSE
						Debug('Check_Match FALSE!');
					END IF;
				END IF;

            -- ------------------------------------------------------
            -- Advance i to the last record involved in the OR logic.
            -- ------------------------------------------------------
            i := l_stop_at_index;
			END IF;

         -- ------------------------------------------------------------------------
         -- The attribute value match fails. Advance to the next rule.
         -- ------------------------------------------------------------------------
			IF (NOT l_matched) THEN
            -- ---------------------------------------------------------------------------
            -- If there are no more rules in the group, it will be set to g_no_more_rules.
            -- ---------------------------------------------------------------------------
            i := Get_Next_Rule_Index(i, g_opp_selection_tab);

				-- ------------------------------------------------------------------------
				-- The attribute value match succeeds. Check if the current record is the
				-- last record/attribute in the rule.  If yes, there's a match between
				-- this opportunity and the rule. Set l_stop_flag to TRUE to stop processing.
				-- ------------------------------------------------------------------------
			ELSE
				IF (g_opp_selection_tab(i).last_attr_flag = 'Y') THEN
					IF (l_matching_type = 'STOP_AT_FIRST_RULE') THEN
                  l_stop_flag := TRUE;
               END IF;

               -- -------------------------------------------------------------
               -- The current rule is selected for this opportunity.
               -- -------------------------------------------------------------
               x_selected_rule_id := g_opp_selection_tab(i).process_rule_id;

               IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  Debug('%%%%%%%Selected Rule ID: ' || x_selected_rule_id);
                  Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
                  Debug('Number of rule items scanned/evaluated before finding a matching rule: ' || i);
               END IF;

               -- -------------------------------------------------------------
               -- Perform Partner Selection - call matching engine.
               -- pv_match_pub package.form_where_clause --> pass in a record
               -- of tables (operator, attribute, attribute_value) +
               -- "selection mode" --> Only partners which match all search
               -- attributes are returned.
               -- -------------------------------------------------------------
               IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  Debug('..........................................................');
                  Debug('Calling Partner_Selection................................');
               END IF;

               Partner_Selection(
                  p_api_version     => 1.0,
                  p_process_rule_id => x_selected_rule_id,
                  p_entity_id       => p_entity_id,
                  p_entity          => p_entity,
                  p_user_name       => p_user_name,
                  p_resource_id     => p_resource_id,
                  p_routing_flag    => p_routing_flag,
                  x_partner_cnt     => l_partner_cnt,
                  x_return_status   => l_return_status,
                  x_msg_count       => l_msg_count,
                  x_msg_data        => l_msg_data
					);

					IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
						RAISE FND_API.G_EXC_ERROR;

					ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
						RAISE FND_API.g_exc_unexpected_error;
					END IF;

					-- ------------------------------------------------------------
					-- Log the selected rules if the matching engine type is
					-- 'BACKGROUND PARTNER MATCHING'. This provides a snapshot of what
					-- actually occurred in partner matching.
					-- ------------------------------------------------------------
					IF (g_matching_engine_type = 'BACKGROUND_PARTNER_MATCHING') THEN
						IF (l_partner_cnt > 0) THEN
							l_winning_rule_flag := 'Y';
						ELSE
							l_winning_rule_flag := 'N';
						END IF;

						l_entity_rule_applied_id := null;

						PV_ENTITY_RULES_APPLIED_PKG.Insert_Row(
						px_ENTITY_RULE_APPLIED_ID => l_entity_rule_applied_id,
						p_LAST_UPDATE_DATE        => SYSDATE,
						p_LAST_UPDATED_BY         => p_resource_id,
						p_CREATION_DATE           => SYSDATE,
						p_CREATED_BY              => p_resource_id,
						p_LAST_UPDATE_LOGIN       => p_resource_id,
						p_OBJECT_VERSION_NUMBER   => 1,
						p_REQUEST_ID              => FND_API.G_MISS_NUM,
						p_PROGRAM_APPLICATION_ID  => FND_API.G_MISS_NUM,
						p_PROGRAM_ID              => FND_API.G_MISS_NUM,
						p_PROGRAM_UPDATE_DATE     => SYSDATE,
						p_ENTITY                  => p_entity,
						p_ENTITY_ID               => p_entity_id,
						p_PROCESS_RULE_ID         => x_selected_rule_id,
						p_PARENT_PROCESS_RULE_ID  => FND_API.G_MISS_NUM,
						p_LATEST_FLAG             => FND_API.G_MISS_CHAR,
						p_ACTION_VALUE            => FND_API.G_MISS_CHAR,
						p_PROCESS_TYPE            => 'BACKGROUND_PARTNER_MATCHING',
						p_WINNING_RULE_FLAG       => l_winning_rule_flag,
						p_entity_detail           => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE_CATEGORY      => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE1              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE2              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE3              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE4              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE5              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE6              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE7              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE8              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE9              => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE10             => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE11             => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE12             => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE13             => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE14             => FND_API.G_MISS_CHAR,
						p_ATTRIBUTE15             => FND_API.G_MISS_CHAR,
						p_PROCESS_STATUS          => FND_API.G_MISS_CHAR
						);
					END IF;

					-- ------------------------------------------------------------
					-- If there are no partners returned, go on to the next rule
					-- to find a matching partner until all rules are exhausted.
					-- ------------------------------------------------------------
               IF (l_matching_type = 'EXHAUST_ALL_RULES') THEN
						IF (l_partner_cnt = 0) THEN
							-- reset failure code
							g_failure_code := NULL;
							i := i + 1;

						ELSIF (l_partner_cnt > 0) THEN
							l_stop_flag := TRUE;
						END IF;
					END IF;

				ELSE
               -- ------------------------------
               -- Advance to the next attribute
               -- ------------------------------
               i := i + 1;
            END IF;

			END IF;
		END IF;
	END LOOP;

	IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
	END IF;

	IF (NOT l_stop_flag) THEN
		IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
			Debug('No matching rules found!!!!!');
		END IF;
	END IF;

  x_partner_cnt := l_partner_cnt;

   IF (g_rule_engine_trace_flag = 'Y') THEN
      FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   END IF;

   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

      WHEN g_e_buffer_too_small THEN
         x_return_status := l_return_status;

      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );


END Opportunity_Selection;
-- ===========================End of Opportunity_Selection===========================


-- ===========================End of Partner_Selection=============================
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
) IS
   -- -------------------------------------------------------------------------
   -- Cursor for retrieving partner-to-opportunity mapping for a process rule.
   -- -------------------------------------------------------------------------
   CURSOR lc_partner_mapping IS
      SELECT a.source_attr_id, a.target_attr_id, a.operator, b.return_type
      FROM   pv_entity_attr_mappings a,
             pv_attributes_vl b
      WHERE  a.target_attr_id   = b.attribute_id AND
             a.process_rule_id  = p_process_rule_id AND
             a.source_attr_type = 'LEAD' AND
             --a.source_attr_type = 'OPPORTUNITY' AND
             a.target_attr_type = 'PARTNER';

   -- -------------------------------------------------------------------------
   -- Cursor for retrieving partner selection attribute-value pairs.
   -- -------------------------------------------------------------------------
   CURSOR lc_partner_selection IS
      SELECT a.attribute_id, a.operator,
             b.attribute_value, b.attribute_to_value,
             a.selection_criteria_id,
             c.return_type
      FROM   pv_enty_select_criteria a,
             pv_selected_attr_values b,
             pv_attributes_vl c
      WHERE  a.attribute_id          = c.attribute_id AND
             a.selection_criteria_id = b.selection_criteria_id (+) AND
             a.selection_type_code   = 'PARTNER_SELECTION' AND
             a.process_rule_id       = p_process_rule_id
      ORDER  BY a.attribute_id, b.selection_criteria_id;

   -- -------------------------------------------------------------------------
   -- Cursor for retrieving geo proximity and routing information.
   -- -------------------------------------------------------------------------
   CURSOR lc_entity_routings (p_selected_rule_id IN NUMBER) IS
      SELECT entity_routing_id, max_nearest_partner, distance_from_customer,
             distance_uom_code, routing_type,
             NVL(bypass_cm_ok_flag, 'N') bypass_cm_ok_flag
      FROM   pv_entity_routings
      WHERE  process_rule_id = p_selected_rule_id;

   -- -------------------------------------------------------------------------
   -- Cursor for retrieving location_id for the opportunity (customer).
   -- -------------------------------------------------------------------------
   CURSOR lc_get_location_id (p_entity_id IN NUMBER) IS
      SELECT b.location_id
      FROM   as_leads_all   a,
             hz_party_sites b,
             hz_locations   l
      WHERE  a.lead_id       = p_entity_id AND
             a.customer_id   = b.party_id AND
             b.party_site_id = a.address_id AND
             b.location_id   = l.location_id AND
             l.geometry IS NOT NULL;

   -- -------------------------------------------------------------------------
   -- Cursor for retrieving the process rule name.
   -- -------------------------------------------------------------------------
   CURSOR lc_get_process_rule_name (p_process_rule_id IN NUMBER) IS
      SELECT process_rule_name
      FROM   pv_process_rules_vl
      WHERE  process_rule_id = p_process_rule_id;

   x_partner_tbl           JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE();
   x_distance_uom_returned VARCHAR2(30);
   x_distance_tbl          JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE();

   l_entity_routing     lc_entity_routings%ROWTYPE;

   l_api_version         NUMBER := 1.0;
   l_api_name            VARCHAR2(30) := 'Partner_Selection';
   l_entity_attr_value   pv_check_match_pub.t_entity_attr_value;
   l_temp                VARCHAR2(4000);
   l_num_of_tokens       NUMBER;
   l_attribute_id        NUMBER;
   l_attribute_value     VARCHAR2(4000);
   l_return_status       VARCHAR2(100);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(500);
   l_delimiter           VARCHAR2(10) := '+++';
   l_start               NUMBER;
   i                     NUMBER := 1;
   j                     NUMBER;
   k                     NUMBER := 1;
   l_resource_id         NUMBER;
   l_user_name           VARCHAR2(100);
   l_first_record        BOOLEAN := TRUE;
   l_previous_attr_id    NUMBER;
   l_previous_sc_id      NUMBER;
   l_previous_operator   VARCHAR2(100);
   l_previous_return_type VARCHAR2(100);

   l_customer_address    pv_locator.party_address_rec_type;
   l_distance_uom        VARCHAR2(30);
   --l_distance_uom_returned VARCHAR2(30);

   l_attr_id_tbl         JTF_NUMBER_TABLE       := JTF_NUMBER_TABLE();
   l_attr_value_tbl      JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
   l_attr_operator_tbl   JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_attr_data_type_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

   l_source_tbl          JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_rank_tbl            JTF_NUMBER_TABLE       := JTF_NUMBER_TABLE();
   l_extra_partner_details JTF_VARCHAR2_TABLE_1000 := JTF_VARCHAR2_TABLE_1000();

   -- l_partner_tbl_temp    JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE();
   l_partner_tbl         JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE();
-- vansub
   l_partner_id_tbl      JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE();
--
   l_partner_details     JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
   l_flagcount           JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100();

   l_stop_flag           BOOLEAN := FALSE;

   l_partner_distance_tbl       DBMS_SQL.NUMBER_TABLE;
   l_preferred_partner_party_id NUMBER;
   l_distance_tbl               JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_rule_currency_code         VARCHAR2(15);
   l_entity_routings_exists     BOOLEAN := TRUE;
   l_preferred_idx              NUMBER;
   l_process_rule_name          VARCHAR2(100);
      l_attr_val_temp		VARCHAR2(4000);
BEGIN
   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -------------------------- Source code --------------------

   -- ------------------------------------------------------------------------
   -- Make sure that either p_user_name or p_resource IS NOT NULL.
   -- ------------------------------------------------------------------------
   IF (p_user_name IS NULL AND p_resource_id IS NULL) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NO_USERNAME_ID_DEFINED',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

      g_failure_code := 'OTHER';
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- ------------------------------------------------------------------------
   -- Retrieve profile value for stack trace profile option.
   -- ------------------------------------------------------------------------
   --g_rule_engine_trace_flag := NVL(FND_PROFILE.VALUE('PV_RULE_ENGINE_TRACE_ON'), 'N');

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('............................................................');
      Debug('Stack trace turned on? ' || g_rule_engine_trace_flag);
      Debug('............................................................');

      Debug('  ');
      Debug('Routing Flag is ' || p_routing_flag);
      Debug('***Rule ID Selected Is: ' || p_process_rule_id || '***');
   END IF;

   -- -------------------------------------------------------------
   -- Retrieve Entity Routings info (geo proximity and routings)
   -- -------------------------------------------------------------
   OPEN  lc_entity_routings(p_process_rule_id);
   FETCH lc_entity_routings INTO l_entity_routing;

   IF (lc_entity_routings%NOTFOUND) THEN
      l_entity_routings_exists := FALSE;
   END IF;

   CLOSE lc_entity_routings;

   -- -------------------------------------------------------------
   -- Retrieve location_id for the opportunity (customer).
   -- -------------------------------------------------------------
   FOR x IN lc_get_location_id(p_entity_id) LOOP
      l_customer_address.location_id := x.location_id;
   END LOOP;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('***l_entity_routing.max_nearest_partner: ' || l_entity_routing.max_nearest_partner || '***');
      Debug('***l_entity_routing.distance_from_customer: ' || l_entity_routing.distance_from_customer || '***');
   END IF;

   IF (l_entity_routings_exists AND
      (l_entity_routing.max_nearest_partner IS NOT NULL OR
       l_entity_routing.distance_from_customer IS NOT NULL) AND
       l_customer_address.location_id IS NULL)
   THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NO_GEOMETRY_INFO',
                  p_token1       => 'TEXT',
                  p_token1_value => 'Entity ID: ' || p_entity_id,
                  p_token2       => null,
                  p_token2_value => null);

      g_failure_code := 'OTHER';
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- ------------------------------------------------------------------------
   -- Retrieve the rule's currency_code.
   -- ------------------------------------------------------------------------

   BEGIN
      SELECT currency_code
      INTO   l_rule_currency_code
      FROM   pv_process_rules_b
      WHERE  process_rule_id = p_process_rule_id;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
        IF (l_process_rule_name IS NULL) THEN
           FOR x IN lc_get_process_rule_name(p_process_rule_id) LOOP
              l_process_rule_name := x.process_rule_name;
           END LOOP;
        END IF;

        Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name     => 'PV_DEBUG_MSG',
                    p_token1       => 'TEXT',
                    p_token1_value => 'This rule "' || l_process_rule_name ||
                                      '" (ID: ' || p_process_rule_id || ') does not exist',
                    p_token2       => null,
                    p_token2_value => null);

        g_failure_code := 'OTHER';
        RAISE FND_API.G_EXC_ERROR;
   END;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Rule Currency is: ' || l_rule_currency_code);
   END IF;

   -- ========================================================================
   -- Opportunity-Partner Attribute Mapping                                  =
   -- ========================================================================
   -- ------------------------------------------------------------------------
   -- Loop through opportunity-partner attribute mappings and retrieve the
   -- attribute values of each of the attributes in mapping.
   -- ------------------------------------------------------------------------
   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Retrieve opportunity-to-partner attribute mapping..................');
   END IF;

   FOR lc_cursor IN lc_partner_mapping LOOP
      l_attribute_id := lc_cursor.source_attr_id;

      -- ---------------------------------------------------------------------
      -- Retrieve opportunity's attribute value if it hasn't already been
      -- retrieved.
      -- ---------------------------------------------------------------------
      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Attribute ID before calling Get_Entity_Attr_Values: ' || l_attribute_id);
         --Debug('Entity Type: ' || p_entity);
      END IF;

      pv_check_match_pub.Get_Entity_Attr_Values(
         p_api_version_number => 1.0,
         p_attribute_id       => l_attribute_id,
         p_entity             => p_entity,
         p_entity_id          => p_entity_id,
         p_delimiter          => l_delimiter,
         p_expand_attr_flag   => 'N',
         x_entity_attr_value  => l_entity_attr_value,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data
      );

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         g_failure_code := 'OTHER';
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         g_failure_code := 'OTHER';
         RAISE FND_API.g_exc_unexpected_error;

      ELSE
         -- ---------------------------------------------------------------------
         -- Note that l_entity_attr_value stores concatenated attribute values
         -- with delimiters in the beginning and end of the string.
         -- e.g. +++USA+++UK+++
         --
         -- However, pv_match_pub.form_where_clause API expects a string without
         -- leading and trailing delimiters:
         -- e.g. USA+++UK
         --
         -- Therefore, we need to take these two delimiters out of the string
         -- before passing it to the API as a parameter.
         -- ---------------------------------------------------------------------
         l_temp := l_entity_attr_value(l_attribute_id).attribute_value;

         -- ---------------------------------------------------------------------
         -- Populate PL/SQL table only when the attribute value string IS NOT NULL.
         -- ---------------------------------------------------------------------
         IF (l_temp IS NOT NULL AND l_temp <> '++++++') THEN
            l_num_of_tokens := pv_check_match_pub.Get_Num_Of_Tokens(l_delimiter, l_temp);

            l_attr_id_tbl.EXTEND(l_num_of_tokens);
            l_attr_value_tbl.EXTEND(l_num_of_tokens);
            l_attr_operator_tbl.EXTEND(l_num_of_tokens);
            l_attr_data_type_tbl.EXTEND(l_num_of_tokens);

            -- ------------------------------------------------------------------
            -- Everything under the mapping section should be treated as AND
            -- condition, which requires one table element per item.
            -- ------------------------------------------------------------------
            FOR j IN 1..l_num_of_tokens LOOP
               l_attribute_value := pv_check_match_pub.Retrieve_Token(
                                       p_delimiter         => l_delimiter,
                                       p_attr_value_string => l_temp,
                                       p_input_type        => 'STD TOKEN',
                                       p_index             => j
                                    );

/*
               IF (lc_cursor.return_type = 'CURRENCY') THEN
                  l_attribute_value := l_attribute_value || ':::' || l_rule_currency_code ||
                                       TO_CHAR(SYSDATE, 'yyyymmddhh24miss');
               END IF;
*/
               l_attr_id_tbl(i)        := lc_cursor.target_attr_id;
               l_attr_value_tbl(i)     := l_attribute_value;
               l_attr_operator_tbl(i)  := lc_cursor.operator;
               l_attr_data_type_tbl(i) := lc_cursor.return_type;

               i := i + 1;
            END LOOP;
         END IF;
      END IF;
   END LOOP;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Partner Matching/Mapping Attributes...');

      FOR i IN 1..l_attr_id_tbl.COUNT LOOP

	    l_attr_val_temp := l_attr_value_tbl(i);
   	        while (l_attr_val_temp is not null) loop
		Debug(i || '-->' ||l_attr_id_tbl(i) || ': ' || substr( l_attr_val_temp, 1, 1800 ) ||
	            ':::' || l_attr_operator_tbl(i) || ':::' || l_attr_data_type_tbl(i));
		l_attr_val_temp := substr( l_attr_val_temp, 1801 );
		end loop;
      END LOOP;

      Debug('-----------------------------------------');

      Debug('Appending Partner Selection Attributes...');
   END IF;

   k := i;

   -- ========================================================================
   -- Partner Selection Attributes                                           =
   -- ========================================================================
   -- ------------------------------------------------------------------------
   -- Get partner selection attribute value and append them to the record
   -- of tables, l_match_attr_rec.
   -- The following code also performs AND/OR logic.  Attribute values
   -- involved in an OR logic will be concatenated in a string separated
   -- by a delimiter.
   -- ------------------------------------------------------------------------
   FOR x IN lc_partner_selection LOOP
      IF (l_previous_attr_id = x.attribute_id AND
          l_previous_sc_id   = x.selection_criteria_id)
      THEN
         l_attr_value_tbl(i - 1) := l_attr_value_tbl(i - 1) ||
                                    l_delimiter || x.attribute_value;

         IF (x.return_type = 'CURRENCY') THEN
            l_attr_value_tbl(i - 1) := l_attr_value_tbl(i - 1) || ':::' ||
               l_rule_currency_code || ':::' || TO_CHAR(SYSDATE, 'yyyymmddhh24miss');
         END IF;

      ELSE
         l_attr_id_tbl.EXTEND;
         l_attr_value_tbl.EXTEND;
         l_attr_operator_tbl.EXTEND;
         l_attr_data_type_tbl.EXTEND;

         l_attr_value_tbl(i)      := x.attribute_value;
         l_attr_id_tbl(i)         := x.attribute_id;
         l_attr_data_type_tbl(i)  := x.return_type;
         l_attr_operator_tbl(i)   := x.operator;

         IF (x.return_type = 'CURRENCY') THEN
            l_attr_value_tbl(i) := l_attr_value_tbl(i) || ':::' ||
               l_rule_currency_code || ':::' || TO_CHAR(SYSDATE, 'yyyymmddhh24miss');
         END IF;

         IF (x.operator = 'BETWEEN') THEN
            l_attr_operator_tbl(i) := '>=';

            i := i + 1;
            l_attr_id_tbl.EXTEND;
            l_attr_value_tbl.EXTEND;
            l_attr_operator_tbl.EXTEND;
            l_attr_data_type_tbl.EXTEND;
            l_attr_operator_tbl(i)   := '<=';
            l_attr_id_tbl(i)         := x.attribute_id;
            l_attr_data_type_tbl(i)  := x.return_type;
            l_attr_value_tbl(i)      := x.attribute_to_value;

            IF (x.return_type = 'CURRENCY') THEN
               l_attr_value_tbl(i) := l_attr_value_tbl(i) ||
                                      ':::' || 'USD' || ':::' ||
                                      TO_CHAR(SYSDATE, 'yyyymmddhh24miss');
            END IF;
         END IF;

         i := i + 1;
      END IF;

      l_previous_attr_id := x.attribute_id;
      l_previous_sc_id   := x.selection_criteria_id;
   END LOOP;


   -- ------------------------------------------------------------------------
   -- For debugging only...
   -- ------------------------------------------------------------------------
   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FOR i IN k..l_attr_id_tbl.COUNT LOOP
         --since fnd_msg_pub supports debiug message of length 1972
	 -- we are passing split of attribute value as it may exceed 2000 length
	 l_attr_val_temp := l_attr_value_tbl(i);
	 while (l_attr_val_temp is not null) loop
	    Debug(i || '-->' || l_attr_id_tbl(i) || ': ' || substr( l_attr_val_temp, 1, 1800 ) ||
            ':::' || l_attr_operator_tbl(i) || ':::' || l_attr_data_type_tbl(i));
	    l_attr_val_temp := substr( l_attr_val_temp, 1801 );
         end loop;
      END LOOP;
   END IF;

   -- ------------------------------------------------------------------------
   -- Perform Partner Matching...
   -- ------------------------------------------------------------------------
   IF (p_resource_id IS NULL) THEN
      SELECT resource_id
      INTO   l_resource_id
      FROM   fnd_user a, jtf_rs_resource_extns b
      WHERE  a.user_id   = b.user_id AND
             a.user_name = p_user_name;
   ELSE
      l_resource_id := p_resource_id;
   END IF;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('..........................................................');
      Debug('Calling Form_Where_Clause.......................');
   END IF;

   l_start := DBMS_UTILITY.get_time;

   pv_match_v2_pub.Form_Where_Clause(
     p_api_version_number  => p_api_version,
     p_attr_id_tbl         => l_attr_id_tbl,
     p_attr_value_tbl      => l_attr_value_tbl,
     p_attr_operator_tbl   => l_attr_operator_tbl,
     p_attr_data_type_tbl  => l_attr_data_type_tbl,
     p_attr_selection_mode => 'OR',
     p_att_delmter         => l_delimiter,
     p_selection_criteria  => 'ALL',
     p_resource_id         => l_resource_id,
     p_lead_id             => p_entity_id,
     p_auto_match_flag     => 'N',
     x_matched_id          => x_partner_tbl,
     x_return_status       => l_return_status,
     x_msg_count           => l_msg_count,
     x_msg_data            => l_msg_data
   );

   -- -----------------------------------------------------------
   -- RULE_FOUND_NO_PARTNER...
   -- -----------------------------------------------------------
   IF (NOT x_partner_tbl.EXISTS(1)) THEN
      g_failure_code := 'RULE_FOUND_NO_PARTNER';
   END IF;

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;

   ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');

      Debug('# of Partners Matched: ' || x_partner_tbl.COUNT);
      Debug('Partners Matched: ');

      FOR i IN 1..x_partner_tbl.COUNT LOOP
         Debug(x_partner_tbl(i) || ',');
      END LOOP;

      Debug('..........................................................');
      Debug('Retrieving GEO Proximity and Routings Info...');
   END IF;


   -- -------------------------------------------------------------
   -- Geographic proximity restrictions.
   -- -------------------------------------------------------------
   IF (l_entity_routing.entity_routing_id IS NOT NULL) THEN
      IF (l_entity_routing.distance_uom_code = 'KILOMETERS') THEN
         l_distance_uom := pv_locator.g_distance_unit_km;

         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('Distance Unit: ' || l_distance_uom);
         END IF;

      ELSIF (l_entity_routing.distance_uom_code = 'MILES') THEN
         l_distance_uom := pv_locator.g_distance_unit_mile;

         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('Distance Unit: ' || l_distance_uom);
         END IF;

      ELSE
         --l_distance_uom := pv_locator.g_distance_unit_mile;

         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('No Distance Unit Specified. Use the default from the pv_locator profile.');
         END IF;
      END IF;

   ELSE
      --l_distance_uom := pv_locator.g_distance_unit_mile;

      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('No Distance Unit Specified. Use the default from the pv_locator profile.');
      END IF;
   END IF;


   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Geo Proximity and Routing Parameters..............................');
      Debug('Location ID: ' || l_customer_address.location_id);
      Debug('Distance from partner: ' || l_entity_routing.distance_from_customer);
      Debug('Max # of partners to be returned: ' || l_entity_routing.max_nearest_partner);
      Debug('Distance UOM Code: ' || l_entity_routing.distance_uom_code);
      Debug('Routing Type: ' || l_entity_routing.routing_type);
   END IF;

   -- ------------------------------------------------------------------------
   -- Perform Geo Proximity Restrictions...
   --
   -- Execute Geo Proximity API only when there is at least one partner
   -- returned from Partner Matching above.
   -- ------------------------------------------------------------------------

   l_partner_id_tbl := x_partner_tbl;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('# of Partners Sent: ' || x_partner_tbl.COUNT);
   END IF;


   IF (l_partner_id_tbl.EXISTS(1) AND l_partner_id_tbl.COUNT > 0) THEN
      -- -------------------------------------------------------------
      -- Execute geo proximity API.
      -- -------------------------------------------------------------
      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('..........................................................');
         Debug('Calling pv_locator.Get_Partners..........................');
         Debug('# of Partners Sent: ' || l_partner_id_tbl.COUNT);
      END IF;

      l_start := DBMS_UTILITY.get_time;

      pv_locator.Get_Partners (
         p_api_version      => p_api_version,
         p_customer_address => l_customer_address,
         p_partner_tbl      => l_partner_id_tbl,
         p_max_no_partners  => l_entity_routing.max_nearest_partner,
         p_distance         => l_entity_routing.distance_from_customer,
         p_distance_unit    => l_distance_uom,
         x_partner_tbl      => x_partner_tbl,
         x_distance_tbl     => x_distance_tbl,
         x_distance_unit    => x_distance_uom_returned,
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data
      );

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         g_failure_code := 'ELOCATION_LOOKUP_FAILURE';
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         g_failure_code := 'ELOCATION_LOOKUP_FAILURE';
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
      END IF;

      IF (x_distance_uom_returned = pv_locator.g_distance_unit_km) THEN
         x_distance_uom_returned := 'KILOMETERS';

      ELSIF (x_distance_uom_returned = pv_locator.g_distance_unit_mile) THEN
         x_distance_uom_returned := 'MILES';
      END IF;

      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Distance UOM returned is: ' || x_distance_uom_returned);
         Debug('# of Partners Returned: ' || x_partner_tbl.COUNT);
         Debug('Partners Matched and distance to customer: ');
      END IF;


      -- -------------------------------------------------------------
      -- Store partners' distance to customer.
      -- -------------------------------------------------------------
      FOR i IN 1..x_partner_tbl.COUNT LOOP
         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug(x_partner_tbl(i) || ':::' || TRUNC(x_distance_tbl(i), 2));
         END IF;

         l_partner_distance_tbl(x_partner_tbl(i)) := x_distance_tbl(i);
      END LOOP;


      --Debug('...........Saved partner distance info..............');
      i := l_partner_distance_tbl.FIRST;

      WHILE (i <= l_partner_distance_tbl.LAST) LOOP
         --Debug(i || ':::' || TRUNC(l_partner_distance_tbl(i), 2));
         i := l_partner_distance_tbl.NEXT(i);
      END LOOP;
   END IF;

   -- -------------------------------------------------------------
   -- Tie-breaker
   -- -------------------------------------------------------------
   -- IF (l_entity_routing.routing_type IN ('SERIAL', 'SINGLE') AND
   IF (x_partner_tbl.EXISTS(1) AND x_partner_tbl.COUNT > 1) THEN
      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('..........................................................');
         Debug('Calling Tie_Breaker......................................');
         Debug('# of Partners Sent: ' || x_partner_tbl.COUNT);
      END IF;

      l_start := DBMS_UTILITY.get_time;

       Tie_Breaker(
          p_api_version     => p_api_version,
          p_process_rule_id => p_process_rule_id,
          x_partner_tbl     => x_partner_tbl,
          x_return_status   => l_return_status,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data
       );

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         g_failure_code := 'OTHER';
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         g_failure_code := 'OTHER';
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
      END IF;
   END IF;

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('# of Partners Returned: ' || x_partner_tbl.COUNT);
   END IF;

   -- ------------------------------------------------------------------------------
   -- Retreive partner's detail info.
   -- ------------------------------------------------------------------------------
   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Retrieve partners detail info.................................................');
   END IF;

   IF (x_partner_tbl.EXISTS(1)) THEN
      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('..........................................................');
         Debug('Calling Get_Matched_Partner_Details..........................');
      END IF;

      l_start := DBMS_UTILITY.get_time;

      IF (x_distance_tbl.EXISTS(1)) THEN
         FOR i IN 1..x_partner_tbl.COUNT LOOP
            x_distance_tbl(i) := l_partner_distance_tbl(x_partner_tbl(i));
         END LOOP;

         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('Partner Details and distance info...........................');
            FOR i IN 1..x_partner_tbl.COUNT LOOP
               Debug(x_partner_tbl(i) || ':::' || TRUNC(x_distance_tbl(i), 2));
               --Debug(x_partner_details(i));
            END LOOP;
         END IF;
      END IF;

      Get_Matched_Partner_Details(
            p_api_version_number    => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            p_lead_id               => p_entity_id,
            p_matched_id            => x_partner_tbl,
            p_distance_tbl          => x_distance_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data
      );

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('Return Status: ' || l_return_status);
         END IF;

         g_failure_code := 'OTHER';
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('Return Status: ' || l_return_status);
         END IF;

         g_failure_code := 'OTHER';
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
      END IF;

      -- ------------------------------------------------------------------
      -- Reassign distance to each partner.
      -- ------------------------------------------------------------------
      IF (NOT x_distance_tbl.EXISTS(1)) THEN
         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('Initialize x_distance_tbl...');
         END IF;

         x_distance_tbl := JTF_NUMBER_TABLE();
      END IF;

   END IF;

   x_partner_cnt := x_partner_tbl.count;

   -- ---------------------------------------------------------------------------
   -- Get message count if the stack trace flag is turned on.
   -- ---------------------------------------------------------------------------
   IF (g_rule_engine_trace_flag = 'Y') THEN
      FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   END IF;


   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         IF (g_failure_code IS NULL) THEN
            g_failure_code := 'OTHER';
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

         -- Cause the calling program to raise the same exception!
         --RAISE;

      WHEN FND_API.g_exc_unexpected_error THEN
         IF (g_failure_code IS NULL) THEN
            g_failure_code := 'OTHER';
         END IF;

         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

      WHEN OTHERS THEN
         IF (g_failure_code IS NULL) THEN
            g_failure_code := 'OTHER';
         END IF;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );

END Partner_Selection;
-- ===========================End of Partner_Selection=========================


-- ===========================Begin of Manual_match============================
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
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'Manual_Match';
    l_api_version_number  CONSTANT NUMBER       := 1.0;

    CURSOR lc_get_incumbent_pt (pc_lead_id NUMBER) IS
      SELECT asla.INCUMBENT_PARTNER_PARTY_ID
      FROM as_leads_all asla
      WHERE asla.lead_id = pc_lead_id;

    l_matched_id                JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    l_new_matched_id            JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

    l_incumbent_pt_party_id     NUMBER;
    l_matched_tbl_last_idx      NUMBER := 0;
    l_incumbent_idx             NUMBER := 0;

    l_distance_uom              VARCHAR2(100);
    l_customer_address          pv_locator.party_address_rec_type;

    x_matched_id                JTF_NUMBER_TABLE;
    x_partner_details           JTF_VARCHAR2_TABLE_4000;
    x_distance_tbl              JTF_NUMBER_TABLE;
    x_distance_uom_returned     VARCHAR2(30);
    x_flagcount                 JTF_VARCHAR2_TABLE_100;

    l_no_of_prefered_pts        NUMBER := 0;
    l_prefered_pt_id_tbl        JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    l_prefered_partner_distance NUMBER;
    l_prefered_dist_tbl         JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    l_prefered_dist_uom         VARCHAR2(200);

    l_partner_dist_tbl          JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    l_tokenize_attr_tbl         JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();

    l_locator_flag              VARCHAR2(1) := 'Y';
BEGIN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        debug('In '||l_api_name);
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                       p_api_version_number,
                       l_api_name,
                       G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    x_matched_id      := JTF_NUMBER_TABLE();
    x_partner_details := JTF_VARCHAR2_TABLE_4000();
    x_distance_tbl    := JTF_NUMBER_TABLE();
    x_flagcount       := JTF_VARCHAR2_TABLE_100();

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- ================================================================================
    -- Get matched Partner ID's for the specified attributes
    -- ================================================================================

    PV_MATCH_V2_PUB.Form_Where_clause(
         p_api_version_number    => l_api_version_number
        ,p_init_msg_list         => p_init_msg_list
        ,p_commit                => p_commit
        ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
        ,p_attr_id_tbl           => p_attr_id_tbl
        ,p_attr_value_tbl        => p_attr_value_tbl
        ,p_attr_operator_tbl     => p_attr_operator_tbl
        ,p_attr_data_type_tbl    => p_attr_data_type_tbl
        ,p_attr_selection_mode   => p_attr_selection_mode
        ,p_att_delmter           => p_att_delmter
        ,p_selection_criteria    => p_selection_criteria
        ,p_resource_id           => p_resource_id
        ,p_lead_id               => p_lead_id
        ,p_auto_match_flag       => p_auto_match_flag
        ,p_top_n_rows_by_profile => p_top_n_rows_by_profile
        ,x_matched_id            => x_matched_id
        ,x_return_status         => x_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
     );

    -- l_matched_id and x_matched_id are 2 tables which maintain matched partners.
    -- They are identical tables to begin with. Refer to the below statement.
    --
    -- One of them (l_matched_id) is sent as an IN parameter to elocation  and the
    -- x_matched_id returns from elocation with distance information. The x_matched_id
    -- x_matched_id table could be in a different order than l_matched_id when it returns.
    -- So l_matched_id table contains partner list as we got it from FORM_WHERE_CALUSE
    -- and x_matched_id contains partner list as we had it from Elocation.
    l_matched_id := x_matched_id;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Partner from FORM_WHERE_CLAUSE '||x_matched_id.COUNT);
    END IF;

   /******************Begin of preferred partner Code comments ****************
   -- Rivendell UI does not have Preferred partner as a part of the Matching LOV
   -- The preferred partner is directly added to the matching table instead of
   -- being added from the matching LOV.
   -- So the whole section of the code involving preferred partner will be commented
   -- out.
   -- ================================================================================
   -- Get Preferred Partner Details
   -- ================================================================================
    OPEN lc_get_incumbent_pt (p_lead_id);
      FETCH lc_get_incumbent_pt INTO l_incumbent_pt_party_id;
    CLOSE lc_get_incumbent_pt;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        debug('Preferred partner for lead :'||p_lead_id||' is '||l_incumbent_pt_party_id);
    END IF;

    -- Checking to see if the preferred partner already exists in the matched partner tbl
    IF (x_matched_id.EXISTS(1) AND l_incumbent_pt_party_id IS NOT NULL) THEN
        FOR x IN (
         SELECT idx
         FROM   (SELECT rownum idx, column_value party_id
                 FROM  (SELECT column_value
                        FROM TABLE (CAST(x_matched_id AS JTF_NUMBER_TABLE)))) a
                        WHERE  a.party_id = l_incumbent_pt_party_id)
         LOOP
            l_incumbent_idx := x.idx;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                debug('Preferred partner already exists at matched partner list, position is '||l_incumbent_idx);
            END IF;
         END LOOP;
    END IF;

    -- Adding preferred partner to matched partner id tbl if there is an
    -- incumbent partner and that partner was not already there in the table.
    IF l_incumbent_idx = 0 and l_incumbent_pt_party_id IS NOT NULL THEN
        x_matched_id.extend;
        x_matched_id(x_matched_id.count) := l_incumbent_pt_party_id;
    END IF;
   ******************End of preferred partner Code comments ****************/

    -- ------------------------------------------------------------------------
    -- Retrieve customer-to-partner distance info...
    --
    -- Execute Geo Proximity API only when there is at least one partner
    -- returned from Partner Matching above.
    -- ------------------------------------------------------------------------
    IF (p_get_distance_flag = 'T' AND
        l_matched_id.EXISTS(1) AND l_matched_id.COUNT > 0)
    THEN
        -- -------------------------------------------------------------
        -- Retrieve location_id for this opportunity.
        -- -------------------------------------------------------------
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
             Debug('before retrieving locator info');
        END IF;

        BEGIN
        SELECT b.location_id
        INTO   l_customer_address.location_id
        FROM   as_leads_all   a,
            hz_party_sites b,
            hz_locations   l
        WHERE  a.lead_id   = p_lead_id AND
            a.customer_id   = b.party_id AND
            b.party_site_id = a.address_id AND
            b.location_id   = l.location_id AND
            l.geometry IS NOT NULL;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
              l_locator_flag := 'N';
        END;

        Debug('Locator Flag :::' || l_locator_flag);

        IF l_locator_flag = 'Y' THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                Debug('Location ID: ' || l_customer_address.location_id);
                Debug('..........................................................');
                Debug('Calling pv_locator.Get_Partners..........................');
                Debug('# of Partners Sent: ' || l_matched_id.COUNT);

                FOR i IN 1 .. x_matched_id.COUNT
                LOOP
                    Debug('Partner Id ' || l_matched_id(i));
                END LOOP;
            END IF;

            -- -------------------------------------------------------------
            -- Execute geo proximity API.
            -- -------------------------------------------------------------
            -- Default to mile
            l_distance_uom := pv_locator.g_distance_unit_mile;
            pv_locator.Get_Partners (
                  p_api_version      => 1.0,
                  p_init_msg_list    => FND_API.g_false,
                  p_commit           => FND_API.g_false,
                  p_validation_level => FND_API.g_valid_level_full,
                  p_customer_address => l_customer_address,
                  p_partner_tbl      => l_matched_id,
                  p_max_no_partners  => null,
                  p_distance     => null,
                  p_distance_unit    => l_distance_uom,
                  p_sort_by_distance => 'T',
                  x_partner_tbl      => x_matched_id,
                  x_distance_tbl     => x_distance_tbl,
                  x_distance_unit    => x_distance_uom_returned,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data     => x_msg_data
            );

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF (x_distance_uom_returned = pv_locator.g_distance_unit_km) THEN
              x_distance_uom_returned := 'KILOMETERS';

            ELSIF (x_distance_uom_returned = pv_locator.g_distance_unit_mile) THEN
              x_distance_uom_returned := 'MILES';
            END IF;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               Debug('Distance UOM returned is: ' || x_distance_uom_returned);
               Debug('# of Partners Returned: ' || x_matched_id.COUNT);
            END IF;

     /****************Begin of preferred partner Code comments ****************
            -- ----------------------------------------------------------------
            -- Adding preferred partner on top
            -- ----------------------------------------------------------------
            IF  l_incumbent_pt_party_id IS NOT NULL THEN

                FOR x IN (
                SELECT idx
                FROM   (SELECT rownum idx, column_value party_id
                     FROM  (SELECT column_value
                        FROM TABLE (CAST(x_matched_id AS JTF_NUMBER_TABLE)))) a
                WHERE  a.party_id = l_incumbent_pt_party_id)
                LOOP
                    l_incumbent_idx := x.idx;
                END LOOP;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                   debug('location of Preferred partner in matched partner list '
                         ||l_incumbent_idx);
                END IF;

                l_prefered_partner_distance := x_distance_tbl(l_incumbent_idx);

                IF (x_matched_id.COUNT > 1) THEN
                    FOR i IN REVERSE 1..(l_incumbent_idx - 1) LOOP
                        x_matched_id(i + 1) := x_matched_id(i);
                        x_distance_tbl(i+1) := x_distance_tbl(i);
                    END LOOP;
                    x_matched_id(1)   := l_incumbent_pt_party_id;
                    x_distance_tbl(1) := l_prefered_partner_distance;
                END IF;
            END IF;
     ************************End of preferred partner Code comments **********/

            -- ------------------------------------------------------------------------
            -- Getting the partner details
            -- ------------------------------------------------------------------------
            FOR i IN 1 .. x_matched_id.COUNT LOOP
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                    debug('Partner ID after prefered partner on top '||x_matched_id(i));
                    debug('Distance after prefered partner on top '||x_distance_tbl(i));
                END IF;
            END LOOP;

        END IF; -- Locator flag is 'Y'

    END IF;

    IF x_matched_id.count > 0 THEN

        g_from_match_lov_flag := TRUE;

        Get_Matched_Partner_Details(
            p_api_version_number     => 1.0
            ,p_init_msg_list          => FND_API.G_FALSE
            ,p_commit                 => FND_API.G_FALSE
            ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
            ,p_lead_id                => p_lead_id
            ,p_matched_id             => x_matched_id
            ,p_distance_tbl           => x_distance_tbl
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
        );

        IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
        ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('# of Partners Returned from matched_partner_details: ' || x_matched_id.COUNT);
        END IF;

   END IF;

   IF FND_API.To_Boolean ( p_commit )  THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                 p_count     =>  x_msg_count,
                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                 p_count     =>  x_msg_count,
                 p_data      =>  x_msg_data);


   WHEN OTHERS THEN

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                 p_count     =>  x_msg_count,
                 p_data      =>  x_msg_data);

END Manual_Match;
-- ===========================Begin of Manual_match============================

--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    Get_Matched_Partner_Details                                             |
--|    This procedure Gets the Matched Partner Details required in the UI      |
--|                                                                            |
--|                                                                            |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================


 /*
     Following Assumptions are made for the following select statements.
     1. Flag values should each be a different power of 2 to ensure that
        each bit is used by only one flag.
        Also, these flag values should match with the flag constants defined
        in java API to resolve flags on the front end side.

        REJECTED CURRENT OPPORTUNITY  = 1
        PREFERRED OR INCUMBENT PARTNER FOR CURRENT OPPORTUNITY  = 2

     2. Most of the select statements assume that PT_APPROVED row for accepted
        partner exists in pv_lead_assignments until oppty is recycled by the partner

     3. ISSUE : RECYCLED from_status does not have partner_id populated in
        pv_assignment_logs. So, rejected partner query may not give the correct result

        PROPOSAL :  We need to identify an assignment status when partner is
            rejecting an oppty

        after accepting it . Then, we can populate  partner_id in logs table
        to identify rejected partner

 */

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
     x_msg_data              OUT NOCOPY VARCHAR2)
  IS


   l_api_name            CONSTANT VARCHAR2(30) := 'Get_Matched_Partner_Details';
   l_api_version_number  CONSTANT NUMBER       := 1.0;


   -- In this API we get details for the partner and insert into
   -- an oracle temp table. any commit/rollback action will empty this
   -- table since this table maintains data for only the current transaction.
   -- so we are setting the l_commit flag to false so that the commit routine
   -- is never executed.
   l_commit                 VARCHAR2(1) := FND_API.G_FALSE;

   REJECTED_OPPTY_FLAG      CONSTANT NUMBER := 1;
   INCUMBENT_PARTNER_FLAG   CONSTANT NUMBER := 2;
   TOKEN                    CONSTANT VARCHAR2(3) := '~';
   NULLTOKEN                CONSTANT VARCHAR2(3) := '===';
   l_party_name             VARCHAR2(360);
   l_city                   VARCHAR2(60);
   l_state                  VARCHAR2(60);
   l_country                VARCHAR2(60);
   l_postal_code            VARCHAR2(60);
   l_address1               VARCHAR2(1000);
   l_address2               VARCHAR2(240);
   l_address3               VARCHAR2(240);
   l_attr_desc              VARCHAR2(60);
   l_partner_id             NUMBER;
   l_oppty_last_offer_dt    VARCHAR2(20);
   l_party_id               NUMBER;
   l_partner_count          NUMBER  := 0;
   l_recycled_flag          VARCHAR2(4);
   l_incumbent_pt_party_id  NUMBER;
   l_incumbent_exists_flag  boolean;
   l_relationship_id        NUMBER;
   l_partner_name           VARCHAR2(3600);
   l_internal_org_name      VARCHAR2(3600);
   l_internal_flag          VARCHAR2(1);
   l_party_flag             VARCHAR2(1);
   l_partner_names          VARCHAR2(3600);
   l_count                  NUMBER;
   l_wf_status              VARCHAR2(1000);
   l_active_flag            VARCHAR2(1);

   l_party_name_tbl         JTF_VARCHAR2_TABLE_1000 := JTF_VARCHAR2_TABLE_1000();
   l_party_id_tbl           JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_partner_id_tbl         JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_address1_tbl           JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
   l_attr_desc_tbl          JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
   l_oppty_last_offer_dt_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_active_flag_tbl        JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_order_table            JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   l_membertype_table       JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_industry_table         JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_geography_table        JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_capacityrating_table   JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

   l_incumbent_party_name   VARCHAR2(3600);
   l_pt_id                  NUMBER;
   l_pt_count               NUMBER;

   l_dist_exists            BOOLEAN;

   x_partner_details        JTF_VARCHAR2_TABLE_4000;
   x_recycled_flag_tbl      JTF_VARCHAR2_TABLE_100;
   x_incumbent_flag_tbl     JTF_VARCHAR2_TABLE_100;

   TYPE partner_det_rec is REF CURSOR;
   lc_partner_detail_cur partner_det_rec;

   /*
   TYPE l_tmp IS TABLE OF VARCHAR2(4000) INDEX BY binary_integer;
   l_tmp_ids_tbl            l_tmp;
   l_tmp_pt_details_tbl     l_tmp;
   */

   CURSOR lc_get_incumbent_pt (pc_lead_id NUMBER) IS
      SELECT asla.INCUMBENT_PARTNER_PARTY_ID
      FROM as_leads_all asla
      WHERE asla.lead_id = pc_lead_id;

   CURSOR lc_get_recycled_flag(pc_lead_id NUMBER , pc_partner_id NUMBER)
   IS
   SELECT  DECODE(status
                   ,'PT_REJECTED','Y'
                   ,'PT_ABANDONED','Y'
                   ,'PT_TIMEOUT','Y'
                   ,'N')
   FROM    pv_lead_assignments pval
   WHERE   pval.lead_id = pc_lead_id
   AND     pval.status in ('PT_REJECTED', 'PT_ABANDONED', 'PT_TIMEOUT')
   AND     pval.partner_id = pc_partner_id;

  /*
   CURSOR lc_duplicate_pt_count
   IS
   SELECT  pvpp.partner_id,
           hzp.party_name,
           hzop_pt.internal_flag pt_int_flag,
           vend.party_name,
           hzop_vend.internal_flag vend_int_flag
   FROM    hz_parties hzp , pv_partner_profiles pvpp , hz_parties vend,
           hz_relationships hzr,
           hz_organization_profiles HZOP_pt,
           hz_organization_profiles hzop_vend
   WHERE   hzr.party_id = pvpp.partner_id
   AND     pvpp.partner_party_id = hzr.subject_id
   AND     hzr.subject_id = hzp.party_id
   AND     hzr.subject_table_name = 'HZ_PARTIES'
   AND     hzr.object_table_name = 'HZ_PARTIES'
   AND     hzr.status = 'A' and hzr.start_date <= sysdate and nvl(hzr.end_date,sysdate) >= sysdate
   AND     hzr.subject_id = HZOP_pt.party_id and nvl(hzop_pt.effective_end_date,sysdate) >= sysdate
   AND     hzr.object_id = HZOP_vend.party_id and nvl(hzop_vend.effective_end_date,sysdate) >= sysdate
   AND     (HZOP_vend.internal_flag   = 'N' or hzop_pt.internal_flag = 'Y')
   AND     pvpp.partner_id in (
        SELECT * FROM TABLE (CAST(p_matched_id AS JTF_NUMBER_TABLE))
        )
   AND     hzr.object_id = vend.party_id
   AND     hzr.relationship_code in ('PARTNER_OF','VAD_OF');
  */
   -- =================================================================================
   -- When the Partner Status is Inactive OR Relationship status is inactive
   -- OR if the relationship is end dated OR if the Vendor ORG is end dated
   -- then the active_flag's value would be 'Inactive'
   -- Uncomment this when the local databases are upgraded to 9i
   -- =================================================================================
/*
   -- 11.5.9
   CURSOR l_partner_detail_cur
   IS
      select  hzp.party_name, hzp.city,  hzp.state ,
          hzp.postal_code, hzp.country, hzp.address1,
          hzp.address2, hzp.address3, hzp.party_id,
          pvpp.partner_id,
          to_char(pvpp.OPPTY_LAST_OFFERED_DATE, 'YYYY-MM-DD HH:MM:SS'),
          pvac.description, hzr.relationship_id,
          (case when hzp.status = 'A'
           and  hzr.status = 'A'
           and nvl(hzop.effective_start_date, sysdate) <= sysdate
           and nvl(hzop.effective_end_date, sysdate) >= sysdate
           and hzr.start_date <= SYSDATE and NVL(hzr.end_date,SYSDATE) >= SYSDATE
           then 'A'
           else 'I'
           end ) active_flag
      from    hz_parties hzp , pv_partner_profiles pvpp ,
          pv_attribute_codes_vl  pvac, hz_relationships hzr ,
          hz_organization_profiles HZOP,
         (SELECT rownum idx, column_value
          FROM   (SELECT column_value FROM TABLE (CAST(p_matched_id AS JTF_NUMBER_TABLE)))) x_partner
      where   pvpp_partner_id in (SELECT * FROM THE(select CAST(p_matched_id AS JTF_NUMBER_TABLE) from dual))
      and     pvpp.partner_id = x_partner.column_value
      and     hzr.party_id = pvpp.partner_id
      and     hzr.subject_id = hzp.party_id
      and     hzr.object_id = HZOP.party_id
      and     HZOP.internal_flag   = 'Y'
      and     hzr.subject_table_name = 'HZ_PARTIES'
      and     hzr.object_table_name = 'HZ_PARTIES'
      and     pvpp.PARTNER_LEVEL = pvac.attr_code_id(+)
      order   by x_partner.idx;

   -- 11.5.10 -- pklin
   CURSOR l_partner_detail_cur
   IS
      select  hzp.party_name, hzp.city,  hzp.state ,
          hzp.postal_code, hzp.country, hzp.address1,
          hzp.address2, hzp.address3, hzp.party_id,
          pvpp.partner_id,
          to_char(pvpp.OPPTY_LAST_OFFERED_DATE, 'YYYY-MM-DD HH:MM:SS'),
          pvac.description,
              pvpp.status active_flag
      from    hz_parties hzp,
              pv_partner_profiles pvpp,
          pv_attribute_codes_vl pvac,
         (SELECT rownum idx, column_value
          FROM   (SELECT column_value FROM TABLE (CAST(p_matched_id AS JTF_NUMBER_TABLE)))) x_partner
      where   pvpp.partner_id = x_partner.column_value
      and     pvpp.partner_party_id = hzp.party_id
      and     pvpp.PARTNER_LEVEL = pvac.attr_code_id(+)
      order   by x_partner.idx;
*/



/*   CURSOR lc_get_pt_org_name(lc_partner_id NUMBER)
   IS
   select distinct party_name
   from   hz_relationships hzr,
      hz_parties hzp,
      hz_organization_profiles HZOP
   where  hzr.subject_id = hzp.party_id
   and    hzr.object_id = HZOP.party_id
   and    HZOP.internal_flag   = 'Y'
   and    hzr.subject_table_name = 'HZ_PARTIES'
   and    hzr.object_table_name = 'HZ_PARTIES'
   and    hzr.party_id = lc_partner_id; */

-- =================================================================================

BEGIN

    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
    END IF;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                       p_api_version_number,
                       l_api_name,
                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    x_incumbent_flag_tbl :=  JTF_VARCHAR2_TABLE_100();
    x_recycled_flag_tbl :=  JTF_VARCHAR2_TABLE_100();
    x_return_status   :=  FND_API.G_RET_STS_SUCCESS ;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       debug('Partner Id count before getting details '||p_matched_id.count);
    END IF;

    l_partner_id_tbl.EXTEND(p_matched_id.count);
    l_order_table.EXTEND(p_matched_id.count);
    x_incumbent_flag_tbl.EXTEND(p_matched_id.count);
    x_recycled_flag_tbl.EXTEND(p_matched_id.count);
    l_industry_table.EXTEND(p_matched_id.count);
    l_membertype_table.EXTEND(p_matched_id.count);
    l_geography_table.EXTEND(p_matched_id.count);
    l_capacityrating_table.EXTEND(p_matched_id.count);

    FOR i IN 1..p_matched_id.COUNT LOOP
        l_partner_id_tbl(i) := p_matched_id(i);
    END LOOP;

    FOR i IN 1..l_partner_id_tbl.COUNT LOOP
        debug('i '||i);
        debug('l_partner_id length '||l_partner_id_tbl(i));
    END LOOP;


    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       debug('l_partner_id length '||l_partner_id_tbl.count);
    END IF;

    OPEN lc_get_incumbent_pt (p_lead_id);
    FETCH lc_get_incumbent_pt INTO l_incumbent_pt_party_id;
        IF l_incumbent_pt_party_id IS NULL THEN
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                fnd_message.Set_Token('TEXT', 'Incumbent Partner party ID is null. So, setting it to be zero');
                fnd_msg_pub.Add;
            END IF;
            l_incumbent_pt_party_id := 0;
        END IF;
    CLOSE lc_get_incumbent_pt;

    IF l_partner_id_tbl.count > 0 THEN

        FOR j IN 1 .. l_partner_id_tbl.COUNT LOOP

            l_order_table(j)  := j;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               debug('Value of index '||j);
            END IF;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_Token('TEXT', 'Checking if preferred Partner: ' || l_incumbent_pt_party_id );
              fnd_msg_pub.Add;
            END IF;

            IF l_partner_id_tbl(j) = l_incumbent_pt_party_id THEN
                x_incumbent_flag_tbl(j) := 'Y';
            ELSE
                x_incumbent_flag_tbl(j) := 'N';
            END IF;



            -- This section gets the values for
            -- Membertype
            -- PartnerSince
            -- Phone
            -- Industry
            -- Geographic coverage
            -- capacity Rating
            -- Size of Company
            -- All these attributes have the same SQL_TEXT for the Partner entity
            -- So we are using it to query diff attr values and popluating it into
            -- the temp table.
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_Token('TEXT', 'Getting Personalized columns for : ' || l_partner_id_tbl(j));
              fnd_msg_pub.Add;
            END IF;

            l_industry_table(j)       := get_attribute_value(5, l_partner_id_tbl(j));
            l_membertype_table(j)     := get_attribute_value(6, l_partner_id_tbl(j));
            l_geography_table(j)      := get_attribute_value(8, l_partner_id_tbl(j));
            l_capacityrating_table(j) := get_attribute_value(18, l_partner_id_tbl(j));

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_Token('TEXT', 'Values for Attrs :5 ' ||l_industry_table(j)||
                                    'Values for Attrs :6 ' ||l_membertype_table(j)||
                                    'Values for Attrs :8 ' || l_geography_table(j)||
                                    'Values for Attrs :18 ' || l_capacityrating_table(j) );
              fnd_msg_pub.Add;
            END IF;


            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_Token('TEXT', 'Looking for recycled flag for Partner Id : ' || l_partner_id_tbl(j));
              fnd_msg_pub.Add;
            END IF;

            -- Check if this lead has been recycled by this partner before.
            -- If it has then set the recycled column to 'Y'.
            OPEN lc_get_recycled_flag(p_lead_id, l_partner_id_tbl(j));
            FETCH lc_get_recycled_flag INTO l_recycled_flag;

                x_recycled_flag_tbl.extend;
                IF  lc_get_recycled_flag%FOUND AND  l_recycled_flag IS NOT NULL THEN
                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                        Debug( 'Recycled flag : ' ||  l_recycled_flag);
                    END IF;
                    x_recycled_flag_tbl(j) :=  l_recycled_flag;
                ELSE
                    x_recycled_flag_tbl(j) := 'N';
                END IF;

                l_recycled_flag := 'N';

            CLOSE lc_get_recycled_flag;
        END LOOP;
    END IF;

    BEGIN
        IF p_distance_tbl.COUNT > 0 THEN
            FORALL i IN 1..p_matched_id.COUNT
                INSERT INTO pv_matched_partners_gt
                VALUES (
                l_partner_id_tbl(i)
                ,p_distance_tbl(i)
                ,x_recycled_flag_tbl(i)
                ,x_incumbent_flag_tbl(i)
                ,l_order_table(i)
                ,l_industry_table(i)
                ,l_membertype_table(i)
                ,l_geography_table(i)
                ,l_capacityrating_table(i)
                );
        ELSE
            FORALL i IN 1..p_matched_id.COUNT
                INSERT INTO pv_matched_partners_gt
                (
                PARTNER_ID
                ,RECYCLED_FLAG
                ,INCUMBENT_FLAG
                ,PARTNER_ORDER
                ,INDUSTRY
                ,MEMBER_TYPE
                ,GEOGRAPHY
                ,CAPACITY_RATING
                )
                VALUES (
                l_partner_id_tbl(i)
                ,x_recycled_flag_tbl(i)
                ,x_incumbent_flag_tbl(i)
                ,l_order_table(i)
                ,l_industry_table(i)
                ,l_membertype_table(i)
                ,l_geography_table(i)
                ,l_capacityrating_table(i)
                );
        END IF;
        EXCEPTION
            WHEN others THEN
                Debug('Bad row index = ' || (1 +sql%rowcount) ||' ' || sqlerrm);
    END;

    IF FND_API.To_Boolean ( l_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get( p_encoded     =>  FND_API.G_FALSE,
            p_count =>  x_msg_count,
            p_data  =>  x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                 p_count     =>  x_msg_count,
                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                 p_count     =>  x_msg_count,
                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN


      x_return_status :=    FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                 p_count     =>  x_msg_count,
                 p_data      =>  x_msg_data);

End get_matched_partner_details;
--====================End of get_matched_partner_details ======================

--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Tie_Breaker                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
   PROCEDURE Tie_Breaker(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2  := FND_API.g_false,
      p_commit                 IN  VARCHAR2  := FND_API.g_false,
      p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full,
      p_process_rule_id        IN  NUMBER,
      x_partner_tbl            IN OUT NOCOPY JTF_NUMBER_TABLE,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2)
   IS

      l_api_version      NUMBER := 1.0;
      l_api_name         VARCHAR2(30) := 'Tie_Breaker';
      l_tie_breaking_tab PV_TIE_BREAKING_TBL := PV_TIE_BREAKING_TBL();
      l_sql_string       VARCHAR2(10000);
      l_index            NUMBER;
      l_last_index       NUMBER;
      l_comma            VARCHAR2(1) := ',';
      i                  NUMBER;
      l_max_left_length  NUMBER; -- Length to the left of the decimal point
      l_max_right_length NUMBER; -- Length to the right of the decimal point
      l_left_length      NUMBER;
      l_right_length     NUMBER;
      l_attribute_id     NUMBER;
      l_format_string    VARCHAR2(300);
      l_positive_format_string    VARCHAR2(300);
      --l_any_negative     BOOLEAN := FALSE;
      l_prev_party_id    NUMBER;
      l_party_id    NUMBER;
      l_attribute_value varchar2(2000);

      l_start            NUMBER;
      l_dup_count        NUMBER;
      l_stop_flag        BOOLEAN := FALSE;

      -- --------------------------------------------------------------------
      -- Fetch all the tie-breaking attributes for a matching rule.
      -- --------------------------------------------------------------------
      CURSOR c_tie_breaking_attr IS
         SELECT a.attribute_id, a.operator, b.return_type
         FROM   pv_enty_select_criteria a,
                pv_attributes_vl b
         WHERE  a.process_rule_id            = p_process_rule_id AND
                UPPER(a.selection_type_code) = 'TIE_BREAKING' AND
                a.attribute_id               = b.attribute_id
         ORDER  BY a.rank;

      lc_cursor          c_tie_breaking_attr%ROWTYPE;

      -- --------------------------------------------------------------------
      -- For a specified attribute, fetch all the attribute values for all
      -- the partners in the list (x_partner_tbl).
      --
      -- The outer join to hz_parties is to trick the query so that NULL values
      -- are returned for partners that don't have a corresponding record in
      -- pv_search_attr_values.
      -- ---------------------------------------------------------------------
/*
      CURSOR lc_attr_values IS
         SELECT b.party_id,
                DECODE(a.attr_text, NULL, TO_CHAR(a.attr_value), a.attr_text) attribute_value
         FROM   pv_search_attr_values a,
                hz_parties b
         WHERE  a.party_id     (+) = b.party_id AND
                a.attribute_id (+) = l_attribute_id AND
                b.party_id IN (
                  SELECT * FROM TABLE (CAST(x_partner_tbl AS JTF_NUMBER_TABLE))
                )
         ORDER  BY b.party_id;
*/

      -- --------------------------------------------------------------------
      -- The use of "rownum idx" is to preserve the order of party_id's as
      -- they were passed in through x_partner_tbl.
      --
      -- The "leading" hint is to make sure that the optimizer will make
      -- c (CAST PLSQL table) as the driving table as it is most likely the
      -- smallest "table" in the join.  This, in most cases, speeds up the
      -- performance dramatically.
      -- ---------------------------------------------------------------------
     lc_attr_values_string  varchar2(1000) :=
      '		select  '  ||
      '		c.party_id, '||
      '		(select decode(a.attr_text, null, to_char(a.attr_value),  ' ||
      '		a.attr_text) from pv_search_attr_values a where a.party_id = c.party_id and ' ||
      '		a.attribute_id = :1) attribute_value, ' ||
      '		c.idx ' ||
      '		from ' ||
      '		(select * from (select rownum idx, ' ||
      '		column_value party_id from (select column_value from table (cast(:2 as ' ||
      '		jtf_number_table))))) c ' ||
      '		order by c.idx ' ;

/*
     '          SELECT  ' ||
     '	        b.party_id, ' ||
     '           DECODE(a.attr_text, NULL, TO_CHAR(a.attr_value), a.attr_text) attribute_value, ' ||
     '           c.idx ' ||
     '    FROM   pv_search_attr_values a, ' ||
     '           hz_parties b, ' ||
     '          (SELECT * ' ||
     '           FROM   (SELECT rownum idx, column_value party_id ' ||
     '                   FROM  (SELECT column_value ' ||
     '                          FROM TABLE (CAST(:1 AS JTF_NUMBER_TABLE))))) c ' ||
     '    WHERE  a.party_id     (+) = b.party_id AND ' ||
     '           a.attribute_id (+) = :2 AND ' ||
     '           b.party_id     = c.party_id ' ||
     '    ORDER  BY c.idx ' ;
  */

     TYPE t_attr_values_cursor IS REF CURSOR;
     lc_attr_values t_attr_values_cursor;
     l_idx number;

  --    CURSOR lc_attr_values IS
--         SELECT /*+ leading(c) */
/*	        b.party_id,
                DECODE(a.attr_text, NULL, TO_CHAR(a.attr_value), a.attr_text) attribute_value,
                c.idx
         FROM   pv_search_attr_values a,
                hz_parties b,
               (SELECT *
                FROM   (SELECT rownum idx, column_value party_id
                        FROM  (SELECT column_value
                               FROM TABLE (CAST(x_partner_tbl AS JTF_NUMBER_TABLE))))) c
         WHERE  a.party_id     (+) = b.party_id AND
                a.attribute_id (+) = l_attribute_id AND
                b.party_id     = c.party_id
         ORDER  BY c.idx;
*/


   BEGIN
      -------------------- initialize -------------------------
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      IF NOT FND_API.compatible_api_call(
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name
      ) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -------------------------- Source code --------------------

      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Inside Tie-Breaking................................');
      END IF;

      -- ----------------------------------------------------------
      -- Loop through tie-breaking attributes one at a time to
      -- break the tie.
      -- ----------------------------------------------------------
      OPEN  c_tie_breaking_attr;
      FETCH c_tie_breaking_attr INTO lc_cursor;

      WHILE (c_tie_breaking_attr%FOUND AND (NOT l_stop_flag)) LOOP
         i := 1;
         l_attribute_id := lc_cursor.attribute_id;

         l_max_left_length  := 0;
         l_max_right_length := 0;
         -- l_any_negative     := FALSE;
         l_prev_party_id    := NULL;

         --FOR lc_cursor_inner IN lc_attr_values LOOP

	 OPEN lc_attr_values FOR lc_attr_values_string using l_attribute_id, x_partner_tbl  ;
         LOOP

	 FETCH lc_attr_values INTO  l_party_id, l_attribute_value, l_idx;
	 EXIT WHEN lc_attr_values%NOTFOUND;

            -- ----------------------------------------------------------------------------
            -- Raise an exception if there are more than 1 record with the same party_id.
            -- If this were the case, we won't be able to determine which attribute value
            -- to use for tie-breaking.
            -- ----------------------------------------------------------------------------
            IF (l_party_id = l_prev_party_id) THEN
               Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                           p_msg_name     => 'PV_MULTIPLE_ATTR_VALUES',
                           p_token1       => 'TEXT',
                           p_token1_value => 'Party ID: ' || l_prev_party_id,
                           p_token2       => 'TEXT',
                           p_token2_value => 'Attribute ID: ' || l_attribute_id);

               g_failure_code := 'OTHER';
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_prev_party_id := l_party_id;

            -- ----------------------------------------------------------------------------
            -- Note: indexing the table this way (using i, which is sequential) will not
            -- mess up the party_id order because the cursor is sorted by party_id.
            -- Consistent read will guarantee that the order won't be changed.
            -- However, may want to change this in the future!!!
            -- ----------------------------------------------------------------------------
            IF (NOT l_tie_breaking_tab.EXISTS(i)) THEN
               l_tie_breaking_tab.EXTEND;
               l_tie_breaking_tab(i) := system.PV_TIE_BREAKING_TYPE(
                                           l_party_id,
                                           l_attribute_value,
                                           null
                                           --,l_idx
                                           );
            ELSE
               l_tie_breaking_tab(i).attr_value := l_attribute_value;
            END IF;

           /* .....................................................................
            IF ((TO_NUMBER(l_tie_breaking_tab(i).attr_value) < 0) AND (NOT l_any_negative)) THEN
               l_any_negative := TRUE;
            END IF;
            * ..................................................................... */

            Get_Attr_Length(
               p_attr_value     => l_tie_breaking_tab(i).attr_value,
               p_left_length    => l_left_length,
               p_right_length   => l_right_length
            );

            --Debug('LEFT : ' || l_left_length);
            --Debug('RIGHT: ' || l_right_length);

            IF (l_left_length > l_max_left_length) THEN
               l_max_left_length := l_left_length;
            END IF;

            IF (l_right_length > l_max_right_length) THEN
               l_max_right_length := l_right_length;
            END IF;

            i := i + 1;
         END LOOP; -- lc_cursor_inner -- end of OPEN lc_attr_values FOR lc_attr_values_string

         --Debug('MAX RIGHT: ' || l_max_right_length);
         --Debug('MAX LEFT : ' || l_max_left_length);

         -- -------------------------------------------------------
         -- Build the format string for converting the attribute
         -- value to the format that we desire.
         -- -------------------------------------------------------
         l_format_string := Build_Format_String (
                               p_max_left_length  => l_max_left_length,
                               p_max_right_length => l_max_right_length
                            );

         -- -----------------------------------------------------------
         -- If there are any negative numbers in the list, make sure
         -- the format string for positive numbers is 1 digit more than
         -- the that of the negative numbers.
         -- -----------------------------------------------------------
/*
         IF (l_any_negative) THEN
            l_positive_format_string :=
               SUBSTR(l_format_string, 1, 1) || '9' || SUBSTR(l_format_string, 2, LENGTH(l_format_string));
         ELSE
            l_positive_format_string := l_format_string;
         END IF;
*/

         -- -----------------------------------------------------------
         -- Instead of figuring out if there are any negative numbers
         -- (which is difficult to do since the operator could be MIN
         -- which would revert a positive number to a negative one),
         -- always add an additonal '9' to the right side of a positive
         -- format filter.
         -- -----------------------------------------------------------
         l_positive_format_string :=
            SUBSTR(l_format_string, 1, 1) || '9' || SUBSTR(l_format_string, 2, LENGTH(l_format_string));

         --Debug('Format String: ' || l_format_string);

         -- -------------------------------------------------------
         -- Now we have the attribute value for a specified
         -- attribute for all the partners, we will find the max
         -- length of the attribute values in the set, convert
         -- the numeric attribute_value into a string, padding
         -- 0's if necessary.  Depending on the operator for this
         -- attribute, we may need to do some special processing
         -- (see conver_to_string below) on the attribute value.
         -- -------------------------------------------------------
         l_index      := l_tie_breaking_tab.FIRST;
         l_last_index := l_tie_breaking_tab.LAST;

         WHILE (l_index <= l_last_index) LOOP
            l_tie_breaking_tab(l_index).concat_value_str :=
               l_tie_breaking_tab(l_index).concat_value_str ||
               Convert_To_String(p_attr_value       => TO_NUMBER(l_tie_breaking_tab(l_index).attr_value),
                                 p_max_left_length  => l_max_left_length,
                                 p_max_right_length => l_max_right_length,
                                 p_format_string    => l_format_string,
                                 p_positive_format_string => l_positive_format_string,
                                 p_min_max          => lc_cursor.operator) || '#';

            l_index := l_tie_breaking_tab.NEXT(l_index);
         END LOOP;

         -- -------------------------------------------------------
         -- Check for dupes. No need to continue if there are no
         -- dupes.
         -- -------------------------------------------------------
         l_start := dbms_utility.get_time;

         BEGIN
            SELECT *
            INTO   l_dup_count
            FROM (
               SELECT COUNT(*)
               FROM   THE (SELECT CAST(l_tie_breaking_tab AS PV_TIE_BREAKING_TBL)
                           FROM   dual) a
               WHERE  ROWNUM < 2
               GROUP  BY concat_value_str
               HAVING COUNT(*) > 1) b;

            EXCEPTION
             WHEN no_data_found THEN
                --Debug('There are no dupes.');
                l_stop_flag := TRUE;

         END;


         FETCH c_tie_breaking_attr INTO lc_cursor;

         IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('Finding Dups Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
         END IF;
      END LOOP;

      CLOSE c_tie_breaking_attr;


      -- DEBUGGING -------------------------------------------------------------
      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Print out concatenated strings...');
         l_index      := l_tie_breaking_tab.FIRST;
         l_last_index := l_tie_breaking_tab.LAST;

         WHILE (l_index <= l_last_index) LOOP
            Debug(l_tie_breaking_tab(l_index).party_id || ':::' ||
                  l_tie_breaking_tab(l_index).concat_value_str);
            l_index := l_tie_breaking_tab.NEXT(l_index);
         END LOOP;
      END IF;
      -- DEBUGGING -------------------------------------------------------------


      -- ------------------------------------------------------------
      -- Sort the partners by their concatenated attribute values
      -- ------------------------------------------------------------
      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Start sorting..............................');
      END IF;

      l_start := dbms_utility.get_time;

      l_index := 1;

      FOR x IN (
         SELECT *
         FROM   THE (SELECT CAST(l_tie_breaking_tab AS PV_TIE_BREAKING_TBL)
                     FROM   dual) a
         ORDER  BY concat_value_str DESC)
      LOOP
         x_partner_tbl(l_index) := x.party_id;
         --Debug(x.party_id || ':::' || x.concat_value_str);
         l_index := l_index + 1;
      END LOOP;


     /* =====================================================================
      -- ------------------------------------------------------------
      -- Sorting by concat_value_str and then by idx will preserve the
      -- party_ids order as they are passed in through x_partner_tbl
      -- should there be a tie in tie-breaking (e.g. all tie-breaking
      -- attributes come up with NULL values).
      -- ------------------------------------------------------------
      FOR x IN (
         SELECT *
         FROM   THE (SELECT CAST(l_tie_breaking_tab AS PV_TIE_BREAKING_TBL)
                     FROM   dual) a
         ORDER  BY concat_value_str DESC, idx ASC)
      LOOP
         x_partner_tbl(l_index) := x.party_id;
         --Debug(x.party_id || ':::' || x.concat_value_str);
         l_index := l_index + 1;
      END LOOP;
      * ===================================================================== */


      -- DEBUGGING -------------------------------------------------------------
      IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Sorting Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');

         Debug('Printing out partner IDs after sorting...');
         FOR i IN 1..x_partner_tbl.COUNT LOOP
            Debug(x_partner_tbl(i));
         END LOOP;
      END IF;
      -- DEBUGGING -------------------------------------------------------------
   END Tie_Breaker;
-- =========================End of Tie_Breaker==================================

--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level) THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);

        IF (p_token2 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        END IF;

        IF (p_token3 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        END IF;

        FND_MSG_PUB.Add;
    END IF;
END Set_Message;

--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Get_Attr_Length                                                         |
--|        Given a "string of NUMBER", this procedure will return the length of|
--|        the string to the left of the decimal point as well as that of the  |
--|        string to the right of the decimal point.                           |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Get_Attr_Length(
   p_attr_value      IN  VARCHAR2,
   p_left_length     OUT NOCOPY NUMBER,
   p_right_length    OUT NOCOPY NUMBER)
IS
   l_attr_value      VARCHAR2(2000);

BEGIN
   -- --------------------------------------------------------------------------
   -- The negative sign should not be counted when counting string length.
   -- --------------------------------------------------------------------------
   l_attr_value := REPLACE(p_attr_value, '-', '');

   IF (INSTR(p_attr_value, '.') = 0) THEN
      p_left_length  := LENGTH(l_attr_value);
      p_right_length := 0;

   ELSE
      p_left_length  := LENGTH(SUBSTR(l_attr_value, 1, INSTR(l_attr_value, '.') - 1));
      p_right_length := LENGTH(SUBSTR(l_attr_value, INSTR(l_attr_value, '.') + 1, LENGTH(l_attr_value)));
   END IF;
END Get_Attr_Length;
-- ===========================End of Get_Attr_Length============================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Build_Format_String                                                     |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|  e.g. of value returned:                                                   |
--|     '09999999.9990', '09999.990'                                           |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Build_Format_String (
   p_max_left_length  NUMBER,
   p_max_right_length NUMBER)
RETURN VARCHAR2 IS
   l_format_string VARCHAR2(100);

BEGIN
   l_format_string := '0';

   FOR i IN 1..p_max_left_length - 1 LOOP
      l_format_string := l_format_string || '9';
   END LOOP;

   IF (p_max_right_length > 0) THEN
      l_format_string := l_format_string || '.';

      FOR i IN 1..p_max_right_length - 1 LOOP
         l_format_string := l_format_string || '9';
      END LOOP;

      l_format_string := l_format_string || '0';
   END IF;

   RETURN l_format_string;
END;
-- ====================End of Build_Format_String==========================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Convert_To_String                                                       |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Convert_To_String(p_attr_value             NUMBER,
                           p_max_left_length        NUMBER,
                           p_max_right_length       NUMBER,
                           p_format_string          VARCHAR2,
                           p_positive_format_string VARCHAR2,
                           p_min_max                VARCHAR2)
RETURN VARCHAR2 IS
   l_attr_value    NUMBER := p_attr_value;
   l_format_string VARCHAR2(300);
   l_null_string   VARCHAR2(300);

BEGIN
   -- -----------------------------------------------------------------
   -- If the attribute value is NULL, we want to assign it the
   -- "smallest" possible VARCHAR2 value with a length of the format
   -- string.  The "smallest" value would be a string with all '-'s.
   -- e.g. '----------'
   -- -----------------------------------------------------------------
   IF (p_attr_value IS NULL) THEN
      FOR i IN 1..LENGTH(p_positive_format_string) LOOP
         IF (p_min_max = 'MIN') THEN
            l_null_string := l_null_string || '9';
        ELSE
            l_null_string := l_null_string || '-';
        END IF;
      END LOOP;

      RETURN l_null_string;
   END IF;

   -- -----------------------------------------------------------------
   -- If p_min_max is 'MIN', which means that 40 is
   -- ranked higher than 60, then we need to substract the attribute
   -- value from x where x is:
   -- POWER(10, p_max_attr_length)
   --
   -- e.g.
   --    If p_max_left_length is 3 (e.g. 100, 200, 250, etc.), then
   --    x = POWER(10, 3) = 1000
   --
   -- The attribute value in this case would be (1000 - p_attr_value).
   --
   -- Also if the attribute value is a negative number, we need to the
   -- similar thing described above for 'MIN'.  Of course, we want
   -- to leave the negative sign intact.
   --
   -- The reason for doing this is that we are doing string comparsion
   -- even though we are really comparing numbers.  When a number is
   -- negative, a normal string comparsion would yield the opposite
   -- result.
   -- e.g.
   --    '-1.7' > '-1.6'  ==> This is TRUE for string comparsion but
   --                         FALSE for number comparsion.
   --
   -- In the case of 'MIN' and negative number, nothing needs to be
   -- done since it would just be doing the above operation twice,
   -- reverting it to its original result.
   --
   -- Here's the algorithm:
   -- IF (negative AND MIN) THEN
   --    Turn it into a positive number
   -- ELSIF (negative AND MAX) THEN
   --    Substract from x (see above) and keep the negative sign
   -- ELSIF (positive AND MIN) THEN
   --    Substract from x and prefix it with a negative sign
   -- ELSIF (positive and MAX) THEN
   --    Just pad with 0's
   -- END IF;
   -- -----------------------------------------------------------------
   IF (p_min_max = 'MIN') THEN
      -- --------------------------------------------------------------
      -- If a positive number.
      -- --------------------------------------------------------------
      IF (TO_NUMBER(p_attr_value) > 0) THEN
         l_attr_value := POWER(10, p_max_left_length) - p_attr_value;
         l_attr_value := -l_attr_value;

      -- --------------------------------------------------------------
      -- If a negative number.
      -- --------------------------------------------------------------
      ELSIF (TO_NUMBER(p_attr_value) < 0) THEN
         l_attr_value := -l_attr_value;
      END IF;

   ELSIF (p_min_max = 'MAX') THEN
      -- --------------------------------------------------------------
      -- If a negative number.
      -- --------------------------------------------------------------
      IF (TO_NUMBER(p_attr_value) < 0) THEN
         -- -----------------------------------------------------------
         -- Only substract the positive portion of a negative number
         -- string from POWER(10, p_max_left_length). This is
         -- equivalent of adding it.
         -- -----------------------------------------------------------
         l_attr_value := POWER(10, p_max_left_length) + p_attr_value;
         l_attr_value := -l_attr_value;
      END IF;
   END IF;

   -- -----------------------------------------------------------------
   -- If the number is positive, apply the format string for positive
   -- numbers.  This is to ensure that positive and negative numbers
   -- end up with a string with equal length.
   --
   -- e.g. TO_CHAR(100, '0999')  ==> '0100'
   --      TO_CHAR(-100, '0999') ==> '-0100'
   --
   -- We want it to be like this for positive numbers:
   --      TO_CHAR(100, '09999') ==> '00100'
   --      TO_CHAR(-100, '0999') ==> '-0100'
   -- -----------------------------------------------------------------
   IF (l_attr_value >= 0) THEN
      l_format_string := p_positive_format_string;
   ELSE
      l_format_string := p_format_string;
   END IF;

   -- -----------------------------------------------------------------
   -- It is important to use LTRIM() here because ORACLE always adds
   -- a blank space in front of the converted string unless the number
   -- is negative.
   -- -----------------------------------------------------------------
   RETURN LTRIM(TO_CHAR(l_attr_value, l_format_string));
END Convert_To_String;
-- ====================End of Convert_To_String==========================

-- ====================Start of get_attribute_value========================
FUNCTION get_attribute_value (attribute_id NUMBER ,partner_id NUMBER)
RETURN VARCHAR2
as
    CURSOR lc_get_pt_type (pc_attribute_id NUMBER,pc_partner_id NUMBER) is
    SELECT pac.description
    FROM pv_attribute_codes_vl pac,
        pv_enty_attr_values peav
    WHERE peav.entity_id =  pc_partner_id
    AND peav.entity(+) = 'PARTNER'
    AND peav.attribute_id(+) = pc_attribute_id
    AND peav.attribute_id = pac.attribute_id(+)
    AND pac.attr_code(+) = peav.attr_value
    AND peav.latest_flag = 'Y'
    AND peav.enabled_flag = 'Y';

    l_partner_type_str VARCHAR2(500);
BEGIN

    FOR c1 IN lc_get_pt_type(pc_attribute_id => attribute_id, pc_partner_id => partner_id)
    LOOP
        IF c1.description IS NOT NULL THEN
            l_partner_type_str := l_partner_type_str || ',' || c1.description;
        END IF;

    END LOOP;

    RETURN substr(l_partner_type_str,2);
END get_attribute_value;
-- ====================End of get_attribute_value==========================

-- ====================Start of get_metric_value========================
FUNCTION get_metric_value(attribute_id NUMBER ,partner_id NUMBER)
RETURN NUMBER
AS
    --CURSOR lc_get_metric_raw_value (pc_attribute_id NUMBER,pc_partner_id NUMBER) is

    l_get_metric_raw_value  varchar2(500) :=

    'SELECT pav.return_type, pav.display_style, psav.attr_value,psav.attr_text, pav.decimal_points ' ||
    'FROM pv_attributes_vl pav, ' ||
    '    pv_search_attr_values psav ' ||
    'WHERE psav.PARTY_ID =  :1 ' ||
    'AND psav.attribute_id = :2 ' ||
    'AND psav.attribute_id = pav.attribute_id ' ;

    TYPE t_metric_raw_value_cursor IS REF CURSOR;
    lc_get_metric_raw_value t_metric_raw_value_cursor;


    l_return_type VARCHAR2(100);
    l_display_style VARCHAR2(100);
    l_attr_value NUMBER;
    l_attr_text VARCHAR2(1000);
    l_metric_value NUMBER;
    l_decimals NUMBER;
BEGIN

   --OPEN  lc_get_metric_raw_value(pc_attribute_id => attribute_id , pc_partner_id => partner_id);

    OPEN lc_get_metric_raw_value FOR l_get_metric_raw_value using partner_id, attribute_id ;
    LOOP
    FETCH lc_get_metric_raw_value INTO l_return_type,l_display_style,l_attr_value,l_attr_text,l_decimals;
    EXIT; -- WHEN lc_get_metric_raw_value%NOTFOUND;
    END LOOP;

    IF (lc_get_metric_raw_value%NOTFOUND) THEN
        l_metric_value := null;
    ELSE
        IF l_return_type = 'NUMBER'  THEN

            IF l_display_style = 'PERCENTAGE'  THEN

                l_metric_value := l_attr_value * 100;
            ELSE
                l_metric_value := l_attr_value;
            END IF;
            IF l_decimals IS NOT NULL THEN
                l_metric_value := trunc(l_metric_value,l_decimals);
            ELSE
                l_metric_value := trunc(l_metric_value,2);
            END IF;


        ELSIF  l_return_type = 'CURRENCY'  THEN
            l_metric_value := pv_check_match_pub.currency_conversion(l_attr_text);

        ELSE
           l_metric_value := 0;
        END IF;


    END IF;

    RETURN l_metric_value;

END get_metric_value;
-- ====================End of get_metric_value==========================

-- ====================Start of get_currency_metric_value========================
FUNCTION get_currency_metric_value(attribute_id NUMBER ,partner_id NUMBER)
RETURN varchar2
AS
    --CURSOR lc_get_metric_raw_value (pc_attribute_id NUMBER,pc_partner_id NUMBER) is

    l_get_metric_raw_value  varchar2(500) :=

    'SELECT pav.return_type, pav.display_style, psav.attr_value,psav.attr_text, pav.decimal_points ' ||
    'FROM pv_attributes_vl pav, ' ||
    '    pv_search_attr_values psav ' ||
    'WHERE psav.PARTY_ID =  :1 ' ||
    'AND psav.attribute_id = :2 ' ||
    'AND psav.attribute_id = pav.attribute_id ' ;

    TYPE t_metric_raw_value_cursor IS REF CURSOR;
    lc_get_metric_raw_value t_metric_raw_value_cursor;


    l_return_type VARCHAR2(100);
    l_display_style VARCHAR2(100);
    l_attr_value NUMBER;
    l_attr_text VARCHAR2(1000);
    l_metric_value VARCHAR2(100);
    l_decimals NUMBER;
    l_user_currency_code VARCHAR(30)	:=nvl(fnd_profile.value('ICX_PREFERRED_CURRENCY'), 'USD');
    --l_curr_value VARCHAR2(80);
BEGIN

   --OPEN  lc_get_metric_raw_value(pc_attribute_id => attribute_id , pc_partner_id => partner_id);

    OPEN lc_get_metric_raw_value FOR l_get_metric_raw_value using partner_id, attribute_id ;
    LOOP
    FETCH lc_get_metric_raw_value INTO l_return_type,l_display_style,l_attr_value,l_attr_text,l_decimals;
    EXIT; -- WHEN lc_get_metric_raw_value%NOTFOUND;
    END LOOP;

    IF (lc_get_metric_raw_value%NOTFOUND) THEN
        l_metric_value := null;
    ELSE
        IF  l_return_type = 'CURRENCY'  THEN
            begin
                --select name into l_curr_value from fnd_currencies_vl
				--where currency_code=l_user_currency_code;

                l_metric_value := pv_check_match_pub.Currency_Conversion(
							l_attr_text,
							l_user_currency_code
							) || ' ' || l_user_currency_code;

                exception
			when others then
			--dbms_output.put_line('error:' || SQLERRM);
			l_metric_value:= '';
			end;


        ELSE
           l_metric_value := '';
        END IF;


    END IF;

    RETURN l_metric_value;

END get_currency_metric_value;

-- ====================End of get_currency_metric_value===============


-- ====================Start of get_assign_status_meaning===============
FUNCTION get_assign_status_meaning (p_lead_id NUMBER, p_partner_id NUMBER)
RETURN VARCHAR2
AS
    CURSOR lc_assign_status (pc_lead_id NUMBER, pc_partner_id NUMBER) is
    SELECT DECODE(pla.status,'MATCH_WITHDRAWN','UNASSIGNED'
                            ,'MATCH_WITHDRAWN','UNASSIGNED'
                            ,'OFFER_WITHDRAWN','UNASSIGNED'
                            ,'PT_TIMEOUT','UNASSIGNED'
                            ,'ACTIVE_WITHDRAWN','UNASSIGNED'
                            ,'LOST_CHANCE','UNASSIGNED'
                            ,'CM_ADDED','ASSIGNED'
                            ,'PT_REJECTED','CM_REJECTED'
                            ,'CM_BYPASSED','CM_APPROVED'
                            ,'CM_TIMEOUT','CM_APPROVED'
                            ,'CM_APP_FOR_PT','PT_APPROVED'
                            ,'CM_ADD_APP_FOR_PT','PT_APPROVED'
                            ,'PT_CREATED','PT_APPROVED'
                            ,pla.status) assign_status
           , plw.wf_status
           , plw.routing_status
           , pla.status
           , plw.routing_type
           , pla.wf_item_key
           , pla.assign_sequence
    FROM   pv_lead_assignments pla,
           pv_lead_workflows plw
    WHERE  plw.lead_id = pc_lead_id
    AND    plw.wf_item_key = pla.wf_item_key
    AND    plw.wf_item_type = pla.wf_item_type
    AND    pla.partner_id = pc_partner_id
    AND    plw.latest_routing_flag = 'Y';

    CURSOR lc_status_meaning (pc_status VARCHAR2) IS
    SELECT MEANING
    FROM   PV_LOOKUPS
    WHERE  LOOKUP_TYPE = 'PV_ASN_ASSIGNMENT_STATUS'
    AND    LOOKUP_CODE = pc_status;

    CURSOR lc_curr_rank (p_wf_item_key NUMBER) IS
    SELECT wf_engine.GetItemAttrNumber( 'PVASGNMT',p_wf_item_key,'PV_SERIAL_RANK_ATTR')
    FROM   dual;

    l_assign_status VARCHAR2(500) := 'UNASSIGNED';
    l_wf_status VARCHAR2(500);
    l_routing_status VARCHAR2(500);
    l_routing_type VARCHAR2(50);
    l_wf_item_key VARCHAR2(10);
    l_curr_offered_rank NUMBER;
    l_curr_partner_in_serial VARCHAR2(10);
    l_assign_seq NUMBER;

    l_assign_status_mean VARCHAR2(500);
BEGIN

    FOR c1 IN lc_assign_status(pc_lead_id => p_lead_id
                             , pc_partner_id => p_partner_id)
    LOOP
        l_wf_status := c1.wf_status;
        l_routing_status := c1.routing_status;
        l_routing_type := c1.routing_type;
        l_wf_item_key := c1.wf_item_key;
        l_assign_seq := c1.assign_sequence;
        l_assign_status := c1.assign_status;

        -- Cases like recycled, abandonded, partner timeout will come
        -- under this case. the wf is closed and not active.
        IF l_wf_status = 'CLOSED' AND l_routing_status <> 'ACTIVE' THEN
            l_assign_status := 'UNASSIGNED';
        -- If wf_status is null that means it is unassigned
        ELSIF l_wf_status IS NULL  THEN
            l_assign_status := 'UNASSIGNED';
        -- This works only in serial case. If the routing is serial and
        -- the current partner is the one to whom it is offered then it
        -- must say offered not active
        ELSIF l_routing_type = 'SERIAL' THEN
            BEGIN
                OPEN lc_curr_rank(l_wf_item_key);
                FETCH lc_curr_rank into l_curr_offered_rank;
                CLOSE lc_curr_rank;

                IF l_assign_seq = l_curr_offered_rank THEN
                    l_curr_partner_in_serial := 'Y';
                END IF;

            EXCEPTION
            WHEN OTHERS THEN
                    l_curr_partner_in_serial := 'N';
            END;

	    /*
            IF l_curr_partner_in_serial = 'Y' THEN
                l_assign_status := 'OFFERED';
            END IF;
	    */
	    --for bug# 4217950
	    IF(l_wf_status = 'OPEN' and l_curr_partner_in_serial = 'Y') THEN
                l_assign_status := 'OFFERED';
	    END IF;
	    -- end of change fir bug# 4217950

        -- If the routing status is Offered then all rows that are Approved
        -- should say Offered.
        ELSIF l_routing_status = 'OFFERED'
              AND c1.assign_status = 'CM_APPROVED'
              AND l_routing_type <> 'SERIAL' THEN
            l_assign_status := 'OFFERED';
        ELSE
            l_assign_status := c1.assign_status;
        END IF;
    END LOOP;

    OPEN  lc_status_meaning(pc_status => l_assign_status);
    FETCH lc_status_meaning INTO l_assign_status_mean;

    IF (lc_status_meaning%NOTFOUND) THEN
        l_assign_status_mean := null;
    END IF;

    RETURN l_assign_status_mean;
END get_assign_status_meaning;
-- ====================End of get_assign_status_meaning==================
-- ====================Start of get_partner_types========================
FUNCTION get_partner_types (partner_id NUMBER)
RETURN VARCHAR2
as
    CURSOR lc_get_pt_type (pc_partner_id NUMBER) is
    SELECT pac.description
    FROM pv_attribute_codes_vl pac,
        pv_enty_attr_values peav
    WHERE peav.entity_id =  pc_partner_id
    AND peav.entity(+) = 'PARTNER'
    AND peav.attribute_id(+) = 3
    AND peav.attribute_id = pac.attribute_id(+)
    AND pac.attr_code(+) = peav.attr_value
    AND peav.latest_flag = 'Y'
    AND peav.enabled_flag = 'Y'
    AND peav.attr_value_extn = 'Y' ;

    l_partner_type_str VARCHAR2(500);
BEGIN

    FOR c1 IN lc_get_pt_type(pc_partner_id => partner_id)
    LOOP
        l_partner_type_str := l_partner_type_str || ',' || c1.description;
    END LOOP;

    RETURN substr(l_partner_type_str,2);
END get_partner_types;
-- ====================End of get_partner_types==========================

-- ====================Start of pref_partner_flag========================
FUNCTION pref_partner_flag (p_lead_id NUMBER, p_partner_id NUMBER)
RETURN VARCHAR2
AS
    CURSOR lc_incumbent_part (pc_lead_id NUMBER, pc_partner_id NUMBER) is
    SELECT 'Y'
    FROM  as_leads_all
    WHERE lead_id = pc_lead_id
    AND   incumbent_partner_party_id = pc_partner_id;

    l_pref_part_str VARCHAR2(1);
BEGIN

    l_pref_part_str := 'N';

    OPEN  lc_incumbent_part(p_lead_id , p_partner_id);
    FETCH lc_incumbent_part INTO l_pref_part_str;

    IF (lc_incumbent_part%NOTFOUND) THEN
        l_pref_part_str := 'N';
    END IF;

   CLOSE lc_incumbent_part;

    RETURN l_pref_part_str;
END pref_partner_flag;
-- ====================End of pref_partner_flag==========================
-- ====================Begin of is_cm_flag==========================
FUNCTION lock_flag (p_lead_assign_id NUMBER, p_wf_item_key VARCHAR2)
RETURN VARCHAR2
AS
    CURSOR lc_cm_for_partner (pc_lead_assign_id NUMBER, pc_wf_item_key VARCHAR2)
    IS
    SELECT 'N'
    FROM pv_party_notifications
    WHERE lead_assignment_id = pc_lead_assign_id
    AND wf_item_type = 'PVASGNMT'
    AND wf_item_key = pc_wf_item_key
    --AND notification_type = 'MATCHED_TO'
    AND user_id = FND_GLOBAL.user_id;

    CURSOR lc_routing_status (pc_wf_item_key VARCHAR2)
    IS
    SELECT routing_status
    FROM   pv_lead_workflows
    WHERE  wf_item_key = pc_wf_item_key
    AND    wf_item_type = 'PVASGNMT'
    AND    latest_routing_flag = 'Y';

    CURSOR lc_user_type
    IS
    SELECT jtfre.category
    FROM jtf_rs_resource_extns jtfre
    WHERE jtfre.user_id = FND_GLOBAL.user_id
    AND start_date_active <= sysdate
    AND (end_date_active IS NULL OR end_date_active > sysdate);


    l_lock_flag VARCHAR2(1);
    l_routing_status VARCHAR2(50);
    l_user_type VARCHAR2(50);
BEGIN
    -- In the UI we are using an API which locks the
    -- row for value 'Y' and leaves it enabled for value 'N'

    -- Added fix to make sure checking for the vendor and statuses
    -- before showing lock flag. This was found when testing fix for
    -- Bug 4115728
    l_lock_flag := 'Y';

    OPEN  lc_routing_status(p_wf_item_key);
    FETCH lc_routing_status INTO l_routing_status;

    IF (lc_routing_status%NOTFOUND
        OR l_routing_status = 'UNASSIGNED'
        OR l_routing_status = 'WITHDRAWN'
        OR l_routing_status = 'RECYCLED'
        OR l_routing_status = 'ABANDONED'
        OR l_routing_status = 'ACTIVE') THEN

        OPEN  lc_user_type;
        FETCH lc_user_type INTO l_user_type;

        IF l_user_type = 'EMPLOYEE' THEN
            l_lock_flag := 'N';
        ELSE
            OPEN  lc_cm_for_partner(p_lead_assign_id , p_wf_item_key);
            FETCH lc_cm_for_partner INTO l_lock_flag;

            IF (lc_cm_for_partner%NOTFOUND) THEN
                l_lock_flag := 'Y';
            END IF;
            CLOSE lc_cm_for_partner;
        END IF;

        CLOSE lc_user_type;

    ELSE
        OPEN  lc_cm_for_partner(p_lead_assign_id , p_wf_item_key);
        FETCH lc_cm_for_partner INTO l_lock_flag;

        IF (lc_cm_for_partner%NOTFOUND) THEN
            l_lock_flag := 'Y';
        END IF;
        CLOSE lc_cm_for_partner;

    END IF;

    CLOSE lc_routing_status;


    RETURN l_lock_flag;
END lock_flag;
-- ====================End of is_cm_flag==========================
--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    PROCEDURE Clear_Rules_Cache                                             |
--|                                                                            |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Clear_Rules_Cache IS
BEGIN
   g_opp_selection_tab.DELETE;
END;
-- ==========================End of Clear_Rules_Cache===========================

FUNCTION Get_Next_Rule_Index(
   p_current_index     NUMBER,
   p_opp_selection_tab t_opp_selection_tab
)
RETURN NUMBER
IS
   i                 NUMBER := p_current_index;
   l_current_rule_id NUMBER := p_opp_selection_tab(p_current_index).process_rule_id;
   l_last_index      NUMBER := p_opp_selection_tab.LAST;

BEGIN
   -- ---------------------------------------------------------------------------
   -- We're already at the end of the array. No more rules to evaluate.
   -- ---------------------------------------------------------------------------
   IF (i = l_last_index) THEN
      RETURN g_no_more_Rules;
   END IF;

   -- ---------------------------------------------------------------------------
   -- Starting from the next item in the array, if the process_rule_id changes,
   -- this indicates the start of a new record.  Return the index of this record.
   -- ---------------------------------------------------------------------------
   i := i + 1;

   WHILE ((p_opp_selection_tab(i).process_rule_id = l_current_rule_id) AND
         (i < l_last_index))
   LOOP
      i := i + 1;
   END LOOP;

   -- ---------------------------------------------------------------------------
   -- We've reached the end of the index, no more rules to evaluate.
   -- ---------------------------------------------------------------------------
   IF ((i = l_last_index) AND
      (p_opp_selection_tab(i).process_rule_id = l_current_rule_id))
   THEN
      i := g_no_more_rules;
   END IF;

   RETURN i;

   -- -------------------------------------------------------
   -- May want to capture INDEX OUT OF BOUND here by trapping
   -- ORA-01403: no data found
   -- -------------------------------------------------------
END Get_Next_Rule_Index;
-- ===========================End of Get_Next_Rule_Index===========================

PROCEDURE Cache_Rules IS
   -- --------------------------------------------------------------------
   -- Note that we need an outer join from pv_enty_select_criteria to
   -- pv_selected_attr_value
   -- since certain attributes (e.g. <condition> is not null) will not
   -- have attribute values.
   -- --------------------------------------------------------------------

   CURSOR lc_opp_selection IS
      SELECT prr.process_rule_id,
             prr.rank,
             pesc.attribute_id,
             prr.currency_code,
             pesc.operator,
             pesc.selection_criteria_id,
             psav.attribute_value,
             psav.attribute_to_value
      FROM   pv_process_rules_vl prr,
             pv_enty_select_criteria pesc,
             pv_selected_attr_values psav
      WHERE  prr.process_rule_id = pesc.process_rule_id AND
             pesc.selection_criteria_id = psav.selection_criteria_id (+) AND
             prr.status_code = 'ACTIVE' AND
             TRUNC(SYSDATE) BETWEEN prr.start_date AND
                NVL(prr.end_date, to_DATE('31-12-4000', 'DD-MM-YYYY')) AND
             pesc.selection_type_code = 'OPPORTUNITY_SELECTION'
      ORDER  BY prr.rank DESC, prr.process_rule_id, pesc.attribute_id,
             pesc.selection_criteria_id;

   i                   NUMBER := 1;
   l_count             NUMBER;
   l_or_count          NUMBER;
   l_next_index        NUMBER;
   l_next_rule_id      NUMBER;
   l_next_attribute_id NUMBER;
   l_next_sc_id        NUMBER;
   l_lower_index       NUMBER;

BEGIN
   -- --------------------------------------------------------------------------
   -- Cache rules only if they are not already cached.
   -- --------------------------------------------------------------------------
   IF (g_opp_selection_tab.COUNT = 0) THEN
      FOR l_opp_selection IN lc_opp_selection LOOP
         g_opp_selection_tab(i).rank                  := l_opp_selection.rank;
         g_opp_selection_tab(i).process_rule_id       := l_opp_selection.process_rule_id;
         g_opp_selection_tab(i).attribute_id          := l_opp_selection.attribute_id;
         g_opp_selection_tab(i).currency_code         := l_opp_selection.currency_code;
         g_opp_selection_tab(i).operator              := l_opp_selection.operator;
         g_opp_selection_tab(i).selection_criteria_id := l_opp_selection.selection_criteria_id;
         g_opp_selection_tab(i).attribute_value       := l_opp_selection.attribute_value;
         g_opp_selection_tab(i).attribute_to_value    := l_opp_selection.attribute_to_value;

         i := i + 1;
      END LOOP;

      -- --------------------------------------------------------------------------------
      -- Set last_attr_flag and count in g_opp_selection_tab.
      -- --------------------------------------------------------------------------------
      l_count    := g_opp_selection_tab.COUNT;
      l_or_count := 1;

      FOR i IN 1..l_count LOOP
         IF (i = l_count) THEN
            g_opp_selection_tab(i).last_attr_flag := 'Y';

            l_lower_index := i - l_or_count + 1;

            FOR j IN l_lower_index..i LOOP
               g_opp_selection_tab(j).count := l_or_count;
            END LOOP;

         ELSE
            l_next_index        := g_opp_selection_tab.NEXT(i);
            l_next_rule_id      := g_opp_selection_tab(l_next_index).process_rule_id;
            l_next_attribute_id := g_opp_selection_tab(l_next_index).attribute_id;
            l_next_sc_id        := g_opp_selection_tab(l_next_index).selection_criteria_id;

            -- ---------------------------------------------------------------------------
            -- If the current process_rule_id is not the same as the next
            -- process_rule_id, then this is the last attribute in the rule.
            -- ---------------------------------------------------------------------------
            IF (l_next_rule_id <> g_opp_selection_tab(i).process_rule_id) THEN
               g_opp_selection_tab(i).last_attr_flag := 'Y';
            ELSE
               g_opp_selection_tab(i).last_attr_flag := 'N';
            END IF;

            -- ---------------------------------------------------------------------------
            -- Set g_opp_selection_tab.count.  This field is used to indicate the number
            -- of records involved in an AND/OR logic. If the count is 1, then the logic
            -- is AND. If the count is greater than 1, the logic is OR.
            -- ---------------------------------------------------------------------------
            IF (l_next_rule_id      = g_opp_selection_tab(i).process_rule_id) AND
               (l_next_attribute_id = g_opp_selection_tab(i).attribute_id) AND
               (l_next_sc_id        = g_opp_selection_tab(i).selection_criteria_id)
            THEN
               l_or_count := l_or_count + 1;

            ELSE
               l_lower_index := i - l_or_count + 1;

               FOR j IN l_lower_index..i LOOP
                  g_opp_selection_tab(j).count := l_or_count;
               END LOOP;

               l_or_count := 1;
            END IF;
         END IF;
      END LOOP;
   END IF;

   -- -------------------------------------------------------------------
   -- Debugging code
   -- -------------------------------------------------------------------

   IF (g_rule_engine_trace_flag = 'Y') OR FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      l_count    := g_opp_selection_tab.COUNT;

      FOR i IN 1..l_count LOOP
         Debug('===== ' || i || ' ===========================================');
         Debug(g_opp_selection_tab(i).rank || '::' ||
               g_opp_selection_tab(i).process_rule_id || '::' ||
               g_opp_selection_tab(i).attribute_id || '::' ||
               g_opp_selection_tab(i).currency_code || '::' ||
               g_opp_selection_tab(i).operator || '::' ||
               g_opp_selection_tab(i).selection_criteria_id || '::' ||
               g_opp_selection_tab(i).attribute_value || '::' ||
               g_opp_selection_tab(i).attribute_to_value || '::' ||
               g_opp_selection_tab(i).last_attr_flag || '::' ||
               g_opp_selection_tab(i).count
         );
      END LOOP;
   END IF;

END Cache_Rules;
-- =============================End of Cache_Rules==============================

END PV_MATCH_V3_PUB;

/
