--------------------------------------------------------
--  DDL for Package Body PV_CHECK_MATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_CHECK_MATCH_PUB" as
/* $Header: pvxvcmpb.pls 120.7 2006/09/20 09:57:09 rdsharma ship $ */

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variables                                               */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
-- ----------------------------------------------------------------------------------
-- Used in the Retrieve_Token function to indicate that an index is out of bound.
-- ----------------------------------------------------------------------------------
g_out_of_bound      CONSTANT VARCHAR2(20) := 'OUT OF BOUND';

-- ----------------------------------------------------------------------------------
-- Used by MATCH_FUE so that it can use Check_Match public function.
-- g_attribute_type is normally 'NORMAL'. MATCH_FUE sets it to 'MATCH_FUE' in
-- the beginning of its code and sets it back to 'NORMAL' after it finishes
-- its processing.
-- ----------------------------------------------------------------------------------
g_attribute_type    VARCHAR2(30) := 'NORMAL';

-- ----------------------------------------------------------------------------------
-- Trap the following error:
-- "ORA-01006: bind variable does not exist"
--
-- This can happen when the # of bind variables specified in the USING clause is
-- more than the # of bind variables in the actual SQL statement.
-- ----------------------------------------------------------------------------------
g_e_no_bind_variable EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_no_bind_variable, -1006);


-- ----------------------------------------------------------------------------------
-- ORA-06502: PL/SQL: numeric or value error: character to number conversion error
-- ----------------------------------------------------------------------------------
g_e_numeric_conversion EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_numeric_conversion, -6502);


/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private routine declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
-- -----------------------------------------------------------------------------------
-- Provide the logic for checking if there's a match between the opportunity's
-- attribute value and opportunity selection's attribute value.
-- -----------------------------------------------------------------------------------
FUNCTION Check_Match_Logic(
   p_attribute_id        NUMBER,
   p_attribute_type      VARCHAR2,
   p_operator            VARCHAR2,
   p_entity_attr_value   VARCHAR2,
   p_rule_attr_value     VARCHAR2,
   p_rule_to_attr_value  VARCHAR2,
   p_return_type         VARCHAR2,
   p_rule_currency_code  VARCHAR2
)
RETURN BOOLEAN;
/*
-- -----------------------------------------------------------------------------------
-- Given a string that contains attribute values separated by p_delimiter, retrieve
-- the n th (p_index) token in the string.
-- e.g.
-- p_attr_value_string = '+++abc+++def+++'; p_delimiter = '+++'; p_index = 2.
-- This function will return 'def'.
-- If p_index is out of bound, return g_out_of_bound.
--
-- There are 2 types (p_input_type) of p_attr_value_string:
-- (1) +++abc+++def+++                ==> 'STD TOKEN'
-- (2) 1000000:::USD:::20011225164500 ==> 'In Token'
--
-- When the p_input_type is 'In Token', we will pad p_attr_value_string with
-- p_delimiter like the following:
-- :::1000000:::USD:::20011225164500:::
-- -----------------------------------------------------------------------------------
FUNCTION Retrieve_Token(
   p_delimiter           VARCHAR2,
   p_attr_value_string   VARCHAR2,
   p_input_type          VARCHAR2,
   p_index               NUMBER
)
RETURN VARCHAR2;

-- -----------------------------------------------------------------------------------
-- Given a string, p_string, search for the number of tokens separated by the
-- delimiter, p_delimiter.
--
-- e.g.
--   p_string = '+++abc+++def+++ghi+++'
--   p_delimiter = '+++'
--   The function will return 3 because there are 3 tokens in the string.
-- -----------------------------------------------------------------------------------
FUNCTION Get_Num_Of_Tokens (
   p_delimiter       VARCHAR2,
   p_string          VARCHAR2
)
RETURN NUMBER;
*/

-- -----------------------------------------------------------------------------------
-- This function is used when the attribute_id = 1 which is FUE (Functional
-- Expertise).  It takes the attribute value of an FUE attribute and return the
-- expanded version of it separated by p_delimiter.
-- e.g.
--    If p_attr_value = 'SW/App/CRM', the return string would be:
--    +++SW+++SW/App+++SW/App/CRM+++
-- -----------------------------------------------------------------------------------
FUNCTION Expand_FUE_Values (
   p_attr_value       VARCHAR2,
   p_delimiter        VARCHAR2,
   p_additional_token VARCHAR2 DEFAULT null
)
RETURN VARCHAR2;


-- -----------------------------------------------------------------------------------
-- This function is used when the attribute is purchase_amount or purchase_quantity.
-- It takes an attribute value and returns the expanded version of it separated by
-- p_delimiter.
-- e.g.
-- SW/APP:10000:USD:20020115142534
-- (Product Category:::Line Amount:::Currency Code:::Currency Date)
--
-- Will get expanded into:
-- +++SW:10000:USD:20020115142534+++SW/APP:10000:USD:20020115142534+++
-- -----------------------------------------------------------------------------------
FUNCTION Process_Purchase_Amt_Qty (
   p_attribute_id     IN  VARCHAR2,
   p_attr_value       IN  VARCHAR2,
   p_delimiter        IN  VARCHAR2
)
RETURN VARCHAR2;

-- -----------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------
FUNCTION Match_FUE (
   p_attribute_id         IN      NUMBER,
   p_entity_attr_value    IN      VARCHAR2,
   p_rule_attr_value      IN      VARCHAR2,
   p_rule_to_attr_value   IN      VARCHAR2,
   p_operator             IN      VARCHAR2,
   p_input_filter         IN      t_input_filter,
   p_delimiter            IN      VARCHAR2,
   p_return_type          IN      VARCHAR2,
   p_rule_currency_code   IN      VARCHAR2
)
RETURN BOOLEAN;


-- -----------------------------------------------------------------------------------
-- Use for inserting output messages to the message table.
-- -----------------------------------------------------------------------------------
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2
);

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);


/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                               public routines                                     */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/



--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    Check_Match                                                             |
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
FUNCTION Check_Match (
   p_attribute_id         IN      NUMBER,
   p_entity               IN      VARCHAR2,
   p_entity_id            IN      NUMBER,
   p_rule_attr_value      IN      VARCHAR2,
   p_rule_to_attr_value   IN      VARCHAR2,
   p_operator             IN      VARCHAR2,
   p_input_filter         IN      t_input_filter,
   p_delimiter            IN      VARCHAR2,
   p_rule_currency_code   IN      VARCHAR2,
   x_entity_attr_value    IN OUT  NOCOPY t_entity_attr_value
)
RETURN BOOLEAN
IS
   l_matched           BOOLEAN := FALSE;
   l_entity_attr_value VARCHAR2(4000);
   l_return_type       VARCHAR2(30);
   l_return_status     VARCHAR2(30);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(1000);
   l_api_name          VARCHAR2(30) := 'Check_Match';

BEGIN
   -- ---------------------------------------------------------------------
   -- Get entity's attribute value if it doesn't already exist.
   -- ---------------------------------------------------------------------
   Get_Entity_Attr_Values (
      p_api_version_number   => 1.0,
      p_attribute_id         => p_attribute_id,
      p_entity               => p_entity,
      p_entity_id            => p_entity_id,
      p_delimiter            => p_delimiter,
      x_entity_attr_value    => x_entity_attr_value,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data
   );

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;

   ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (NOT x_entity_attr_value.EXISTS(p_attribute_id)) THEN
      RETURN FALSE;
   END IF;

   l_entity_attr_value := x_entity_attr_value(p_attribute_id).attribute_value;
   l_return_type       := x_entity_attr_value(p_attribute_id).return_type;

   -- ---------------------------------------------------------------------
   -- Call the overloading Check_Match to perform attribute value matching.
   -- ---------------------------------------------------------------------
   l_matched := Check_Match(
      p_attribute_id       => p_attribute_id,
      p_entity_attr_value  => l_entity_attr_value,
      p_rule_attr_value    => p_rule_attr_value,
      p_rule_to_attr_value => p_rule_to_attr_value,
      p_operator           => p_operator,
      p_input_filter       => p_input_filter,
      p_delimiter          => p_delimiter,
      p_return_type        => l_return_type,
      p_rule_currency_code => p_rule_currency_code
   );

   RETURN l_matched;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         RETURN FALSE;
         --RAISE;

      WHEN FND_API.g_exc_unexpected_error THEN
         RETURN FALSE;
         -- RAISE;

      WHEN OTHERS THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         --RETURN FALSE;
         RAISE;
END Check_Match;
-- ==============================Check_Match====================================


--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    Check_Match                                                             |
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
FUNCTION Check_Match (
   p_attribute_id         IN      NUMBER,
   p_entity_attr_value    IN      VARCHAR2,
   p_rule_attr_value      IN      VARCHAR2,
   p_rule_to_attr_value   IN      VARCHAR2,
   p_operator             IN      VARCHAR2,
   p_input_filter         IN      t_input_filter,
   p_delimiter            IN      VARCHAR2,
   p_return_type          IN      VARCHAR2,
   p_rule_currency_code   IN      VARCHAR2
)
RETURN BOOLEAN
IS
   l_api_name              VARCHAR2(30) := 'Check_Match';
   l_counter               NUMBER;
   l_outer_counter         NUMBER;
   l_matched               BOOLEAN;
   l_is_matched            BOOLEAN;
   l_num_of_tokens         NUMBER;
   l_num_of_to_tokens      NUMBER;
   l_num_of_entity_tokens  NUMBER;
   l_matching_tokens       NUMBER;
   l_rule_attr_value       VARCHAR2(4000);
   l_rule_attr_value_temp  VARCHAR2(4000) := p_rule_attr_value;
   l_rule_to_attr_value    VARCHAR2(4000);
   l_entity_attr_value     VARCHAR2(4000);
   l_entity_attr_value_temp VARCHAR2(4000) := p_entity_attr_value;
   l_attribute_type        VARCHAR2(30) := 'NORMAL';
   l_FUE_matched           BOOLEAN;

   l_operator              VARCHAR2(50);
   l_stop_flag             BOOLEAN := FALSE;

BEGIN
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Inside Check_Match =====================================');
      Debug('Operator is: ' || p_operator);
      Debug('Entity Attribute Value (80 chars): ' || substr(p_entity_attr_value,1,80));
      Debug('Rule Attribute Value (80 chars):  ' || substr(p_rule_attr_value,1,80));
   END IF;

   IF (p_rule_attr_value IS NULL) THEN
      l_rule_attr_value := p_delimiter || p_delimiter;
      l_rule_attr_value_temp := l_rule_attr_value;
   END IF;

   IF (p_entity_attr_value IS NULL) THEN
      l_entity_attr_value_temp := p_delimiter || p_delimiter;
   END IF;

   -- ---------------------------------------------------------------------------
   -- Process Input Filter if it exists.
   -- ---------------------------------------------------------------------------
/*
   IF (p_attribute_id IN (g_purchase_amount_attr_id, g_purchase_quantity_attr_id,
       g_PSS_amount_attr_id, g_pss_quantity_attr_id))
   THEN
 */
   IF (p_attribute_id IN (g_a_Purchase_Amount_Product, g_a_Purchase_Quantity_Product,
       g_a_Purchase_Amount_Solutions, g_a_Purchase_Qty_Solutions))
   THEN
      -- ------------------------------------------------------------------------
      -- If there is no input filter for this purchase amount, this is
      -- considered a LINE_AMOUNT, which means that we do not need to match
      -- purchase amount by product categories.
      -- ------------------------------------------------------------------------
      IF (p_input_filter IS NULL OR p_input_filter.COUNT = 0) THEN
         l_attribute_type := 'LINE_AMOUNT';
      ELSE
         -- l_attribute_type := 'FILTER_AMOUNT';

         -- ---------------------------------------------------------------------
         -- Process input filter and identify for a match between the product
         -- interest (FUE) of the input filter and that of the entity lines.
         --
         -- If there's no match at all, we don't need to evaluate this entity
         -- attribute value.  We will immediately return FALSE (no match).
         -- If there's a match in FUE, go on to evaluate the match between
         -- the purchase amount.
         -- ---------------------------------------------------------------------
         l_FUE_matched := Match_FUE(p_attribute_id       => p_attribute_id,
                                    p_entity_attr_value  => l_entity_attr_value_temp,
                                    p_rule_attr_value    => l_rule_attr_value_temp,
                                    p_rule_to_attr_value => p_rule_to_attr_value,
                                    p_operator           => p_operator,
                                    p_input_filter       => p_input_filter,
                                    p_delimiter          => p_delimiter,
                                    p_return_type        => p_return_type,
                                    p_rule_currency_code => p_rule_currency_code);

         IF (l_FUE_matched) THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IF;

   ELSIF (p_attribute_id = g_dummy_attr_id) THEN
      l_attribute_type := 'FILTER_AMOUNT';
   END IF;

   l_num_of_tokens    := Get_Num_Of_Tokens(p_delimiter, l_rule_attr_value_temp);

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('# of Rule Tokens: ' || l_num_of_tokens);
   END IF;

   IF (UPPER(p_operator) = 'BETWEEN') THEN
      l_num_of_to_tokens := Get_Num_Of_Tokens(p_delimiter, p_rule_to_attr_value);

      IF (l_num_of_tokens <> l_num_of_to_tokens) THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_UNMATCHED_TOKEN_NUMBER',
                     p_token1       => 'attribute_value string',
                     p_token1_value => l_rule_attr_value_temp,
                     p_token2       => 'attribute_to_value string',
                     p_token2_value => p_rule_to_attr_value);

         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


   l_outer_counter := 1;

   -- -----------------------------------------------------------------------
   -- 'NOT EQUAL' has a different logic. For token strings like
   -- '+++US+++UK+++', the engine usually treats this as OR logic.
   -- In the case of 'NOT EQUAL', however, the engine will treat it as
   -- 'NOT IN'.
   --
   -- This means that when '+++US+++' is not equal to '+++US+++UK+++',
   -- the engine evaluates the condition to be FALSE. Under OR logic, it
   -- would have been evaluated to TRUE since 'US' is not equal to 'UK'
   -- is TRUE.
   --
   -- This change was made for bug #3374554 for 11.5.10.
   -- -----------------------------------------------------------------------
   IF (p_operator = g_not_equal) THEN
      l_matched := TRUE;
   ELSE
      l_matched := FALSE;
   END IF;


   FOR i IN 1..l_num_of_tokens LOOP
      l_rule_attr_value := Retrieve_Token (
                              p_delimiter         => p_delimiter,
                              p_attr_value_string => l_rule_attr_value_temp,
                              p_input_type        => 'STD TOKEN',
                              p_index             => i
                           );

      IF (UPPER(p_operator) = 'BETWEEN') THEN
         l_rule_to_attr_value := Retrieve_Token (
                                    p_delimiter         => p_delimiter,
                                    p_attr_value_string => p_rule_to_attr_value,
                                    p_input_type        => 'STD TOKEN',
                                    p_index             => i
                                 );

         IF (UPPER(l_rule_to_attr_value) = 'NULL') THEN
            l_rule_to_attr_value := NULL;
         END IF;
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Rule Token #' || i || '(80 chars): ' || substr(l_rule_attr_value,1,80));
         Debug('Operator: ' || p_operator);
      END IF;

      l_num_of_entity_tokens := Get_Num_Of_Tokens(p_delimiter, l_entity_attr_value_temp);


      -- -------------------------------------------------------------------------------
      -- Inner Loop
      -- -------------------------------------------------------------------------------
      FOR j IN 1..l_num_of_entity_tokens LOOP
         l_entity_attr_value := Retrieve_Token (
                                   p_delimiter         => p_delimiter,
                                   p_attr_value_string => l_entity_attr_value_temp,
                                   p_input_type        => 'STD TOKEN',
                                   p_index             => j
                                );

         IF (p_operator = g_not_equal) THEN
            l_operator := g_equal;
         ELSE
            l_operator := p_operator;
         END IF;

         l_is_matched := Check_Match_Logic (
                         p_attribute_id       => p_attribute_id,
                         p_attribute_type     => l_attribute_type,
                         p_operator           => l_operator,
                         p_entity_attr_value  => l_entity_attr_value,
                         p_rule_attr_value    => l_rule_attr_value,
                         p_rule_to_attr_value => l_rule_to_attr_value,
                         p_return_type        => p_return_type,
                         p_rule_currency_code => p_rule_currency_code
                      );

         IF (l_is_matched) THEN
            IF (p_operator = g_not_equal) THEN
               l_matched := FALSE;
            ELSE
               l_matched := TRUE;
            END IF;

            l_stop_flag := TRUE;
            EXIT;
         END IF;
      END LOOP; -- ------------------------ Inner Loop --------------------------

      IF (l_stop_flag) THEN
         EXIT;
      END IF;
   END LOOP; -- ------------------------ Outer Loop -----------------------------

   RETURN l_matched;


   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         RETURN FALSE;
         --RAISE;

      WHEN FND_API.g_exc_unexpected_error THEN
         RETURN FALSE;
         --RAISE;

      WHEN OTHERS THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         --RETURN FALSE;
         RAISE;
END Check_Match;
-- ==============================Check_Match====================================


--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    Get_Entity_Attr_Values                                                  |
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
PROCEDURE Get_Entity_Attr_Values (
   p_api_version_number   IN      NUMBER,
   p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit               IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level     IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_attribute_id         IN      NUMBER,
   p_entity               IN      VARCHAR2,
   p_entity_id            IN      NUMBER,
   p_delimiter            IN      VARCHAR2,
   p_expand_attr_flag     IN      VARCHAR2 := 'Y',
   x_entity_attr_value    IN OUT  NOCOPY t_entity_attr_value,
   x_return_status        OUT     NOCOPY VARCHAR2,
   x_msg_count            OUT     NOCOPY NUMBER,
   x_msg_data             OUT     NOCOPY VARCHAR2
)
IS
   TYPE c_attr_type IS REF CURSOR;

   l_api_version     CONSTANT NUMBER := 1.0;
   l_api_name        CONSTANT VARCHAR2(30) := 'Get_Entity_Attr_Values';

   lc_attr_cursor    c_attr_type;
   l_sql_text        VARCHAR2(2000);
   l_return_type     VARCHAR2(30);
   l_attribute_type  VARCHAR2(30);
   l_output          JTF_VARCHAR2_TABLE_4000;
   l_first_record    BOOLEAN := TRUE;
   l_attr_value      VARCHAR2(32000);
   l_msg_string      VARCHAR2(4000);
   l_num_of_tokens   NUMBER;
   l_token_value     VARCHAR2(2000);

   -- -----------------------------------------------------------------
   -- q1.entity
   -- 'LEAD' = opportunity
   -- 'SALES_LEAD' = lead
   -- -----------------------------------------------------------------
   CURSOR lc_sql_cursor IS
      SELECT  q1.sql_text, q2.return_type, q2.attribute_type
      FROM    pv_entity_attrs q1,
              pv_attributes_vl q2
      WHERE   q1.sql_text IS NOT NULL AND
              q1.entity = UPPER(p_entity) AND
              q1.attribute_id = q2.attribute_id AND
              q1.enabled_flag = 'Y' AND
              q2.enabled_flag = 'Y' AND
              q1.attribute_id = p_attribute_id;

BEGIN
   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -------------------------- Source code --------------------

   -- --------------------------------------------------------------------------
   -- If the attribute entry exists, but the return_type is NULL, retrieve
   -- the return_type from pv_attributes_vl.
   -- --------------------------------------------------------------------------
   IF (x_entity_attr_value.EXISTS(p_attribute_id)) THEN
      IF (x_entity_attr_value(p_attribute_id).return_type IS NULL) THEN
         SELECT return_type
         INTO   x_entity_attr_value(p_attribute_id).return_type
         FROM   pv_attributes_vl
         WHERE  attribute_id = p_attribute_id;
      END IF;

   -- --------------------------------------------------------------------------
   -- If this attribute is not cached (in PL/SQL table). Retrieve its
   -- attribute value(s) and cache it.
   -- --------------------------------------------------------------------------
   ELSE
      -- -----------------------------------------------------------------------
      -- Retrieve SQL Program used for retrieving attribute value(s).
      -- It may not be efficient to retrieve the same sql_text every time.
      -- We may be able to cache the sql_text much the same way we cache
      -- entity's attribute value.
      --
      -- Note that there will only be one row returned from the following
      -- cursor. However, still need to use FOR LOOP to get around the
      -- following Oracle error:
      -- ORA-00600: internal error code, arguments: [12261]
      --
      -- THis is a bug that's fixed in 8.172.
      -- -----------------------------------------------------------------------
      FOR v_sql_cursor IN lc_sql_cursor LOOP
         l_sql_text       := v_sql_cursor.sql_text;
         l_return_type    := v_sql_cursor.return_type;
         l_attribute_type := v_sql_cursor.attribute_type;
      END LOOP;

      --Debug('l_return_type: ' || l_return_type);
      --Debug('l_attribute_type: ' || l_attribute_type);
      --Debug('SQL TEXT:::' );
      --Debug(l_sql_text);

      IF (l_sql_text IS NULL OR LENGTH(l_sql_text) = 0) THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ABSENT_SQL_TEXT',
                     p_token1       => 'TEXT',
                     p_token1_value => 'There is no SQL TEXT for this attribute: ' || p_attribute_id,
                     p_token2       => 'TEXT',
                     p_token2_value => 'Entity Type: ' || p_entity);

         RAISE FND_API.G_EXC_ERROR;
      END IF;

     --BEGIN
      -- -------------------------------------------------------------------------
      -- Execute SQL_TEXT only if there is something in sql_text.
      -- -------------------------------------------------------------------------
      IF (l_sql_text IS NOT NULL OR LENGTH(l_sql_text) <> 0) THEN
         -- =================================================
         -- Handling 'FUNCTION' (program/derived) attributes.
         -- =================================================
         IF (l_attribute_type = 'FUNCTION') THEN
            l_sql_text := 'BEGIN ' || l_sql_text || '; END;';
            EXECUTE IMMEDIATE l_sql_text USING p_entity_id, OUT l_output;

            FOR i IN 1..l_output.COUNT LOOP
               IF (l_first_record) THEN
                  x_entity_attr_value(p_attribute_id).return_type := l_return_type;
                  x_entity_attr_value(p_attribute_id).attribute_value := p_delimiter;
                  l_first_record := FALSE;
               END IF;

               x_entity_attr_value(p_attribute_id).attribute_value :=
                  x_entity_attr_value(p_attribute_id).attribute_value ||
                  RTRIM(LTRIM(l_output(i))) || p_delimiter;

            END LOOP;


         -- =================================================
         -- All other attributes (non-function attributes).
         -- =================================================
         ELSE -- =============Begin Processing non-function attributes============
            OPEN lc_attr_cursor FOR l_sql_text USING p_attribute_id, p_entity, p_entity_id;

         -- ------------------------------------------------------------------------
         -- Note this will not eliminate duplicate values. Do we need to de-dup?
         -- ------------------------------------------------------------------------
         LOOP
            FETCH lc_attr_cursor INTO l_attr_value;
            EXIT WHEN lc_attr_cursor%NOTFOUND;

            --Debug('************Original Attribute Value: ' || l_attr_value);

            -- --------------------------------------------------------------------
            -- Check the attribute value returned. If it contains multiple tokens
            -- as in the case of currency and purchase amount attributes, make
            -- sure there are no tokens with NULL values.
            -- e.g.
            --
            -- 2 tokens:
            --   SW/APP:::10                   is ok,
            --   SW/APP:::                     is also ok,
            --   :::10                         is not. Throws an error.
            --
            -- 3 tokens:
            --   100000:::USD:::20020103145100 is ok, but
            --   100000::::::20020103145100    has a missing currency_code.
            --   :::USD:::20020103145100       has a missing amount, but we will
            --                                 not raise an exception for this. Set the
            --                                 entire string to NULL.
            --   ::::::20020103145100          the amount is null, don't raise the
            --                                 exception even when other tokens are null.
            --
            -- 4 tokens:
            --   SW/APP:::10000:::USD:::20020123101600 is ok, but
            --   SW/APP:::10000::::::20020123101600    not ok.
            --   SW/APP:::10000:::USD:::               not ok.
            --   SW/APP::::::USD:::20020123101600      is ok. leaves it the way it is.
            --   :::10000:::USD:::20020123101600       technically, impossible, but throw
            --                                         an error it this case.
            --
            -- Raise an exception when any of the tokens are missing.
            --
            -- When the number of tokens is 0, it means one of the two possible
            -- things:
            -- (1). The attribute value is NULL as in the case of '::::::'.
            -- (2). The attribute is not a multi-token attribute.
            -- --------------------------------------------------------------------
            IF (INSTR(l_attr_value, g_token_delimiter) > 0) THEN
               l_num_of_tokens := (LENGTH(l_attr_value) -
                                   LENGTH(REPLACE(l_attr_value, g_token_delimiter, '')))
                                  /LENGTH(g_token_delimiter)
                                  + 1;

               -- ..................................................................
               -- 3 tokens
               -- ..................................................................
               IF (l_num_of_tokens = 3) THEN
                  l_token_value := Retrieve_Token (
                                      p_delimiter         => g_token_delimiter,
                                      p_attr_value_string => l_attr_value,
                                      p_input_type        => 'IN TOKEN',
                                      p_index             => 1
                                   );

                  IF (l_token_value IS NULL) THEN
                     l_attr_value := NULL;

                  ELSE
                     l_token_value := Retrieve_Token (
                                         p_delimiter         => g_token_delimiter,
                                         p_attr_value_string => l_attr_value,
                                         p_input_type        => 'IN TOKEN',
                                         p_index             => 2
                                      );

                     IF (l_token_value IS NOT NULL) THEN
                        l_token_value := Retrieve_Token (
                                            p_delimiter         => g_token_delimiter,
                                            p_attr_value_string => l_attr_value,
                                            p_input_type        => 'IN TOKEN',
                                            p_index             => 3
                                         );
                     END IF;

                     IF (l_token_value IS NULL) THEN
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                           Debug('Null Token Found in: ' || l_attr_value);
                        END IF;

                        fnd_message.SET_NAME('PV', 'PV_NULL_TOKEN');
                        fnd_msg_pub.ADD;
                        RAISE FND_API.G_EXC_ERROR;

                        Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                    p_msg_name     => 'PV_NULL_TOKEN',
                                    p_token1       => 'Attribute Value',
                                    p_token1_value => l_attr_value);

                        RAISE FND_API.G_EXC_ERROR;
                     END IF;
                  END IF;

               -- ..................................................................
               -- 2 tokens
               -- ..................................................................
               ELSIF (l_num_of_tokens = 2) THEN
                  l_token_value := Retrieve_Token (
                                      p_delimiter         => g_token_delimiter,
                                      p_attr_value_string => l_attr_value,
                                      p_input_type        => 'IN TOKEN',
                                      p_index             => 1
                                   );

                  IF (l_token_value IS NULL) THEN
                     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                        Debug('Null Token Found in: ' || l_attr_value);
                     END IF;

                     fnd_message.SET_NAME('PV', 'PV_NULL_TOKEN');
                     fnd_msg_pub.ADD;
                     RAISE FND_API.G_EXC_ERROR;

                     Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 p_msg_name     => 'PV_NULL_TOKEN',
                                 p_token1       => 'Attribute Value',
                                 p_token1_value => l_attr_value);

                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

               -- ..................................................................
               -- 4 tokens
               -- ..................................................................
               ELSIF (l_num_of_tokens = 4) THEN
                  l_token_value := Retrieve_Token (
                                      p_delimiter         => g_token_delimiter,
                                      p_attr_value_string => l_attr_value,
                                      p_input_type        => 'IN TOKEN',
                                      p_index             => 1
                                   );

                  IF (l_token_value IS NOT NULL) THEN
                     l_token_value := Retrieve_Token (
                                         p_delimiter         => g_token_delimiter,
                                         p_attr_value_string => l_attr_value,
                                         p_input_type        => 'IN TOKEN',
                                         p_index             => 3
                                      );

                     IF (l_token_value IS NOT NULL) THEN
                        l_token_value := Retrieve_Token (
                                            p_delimiter         => g_token_delimiter,
                                            p_attr_value_string => l_attr_value,
                                            p_input_type        => 'IN TOKEN',
                                            p_index             => 4
                                         );
                     END IF;
                  END IF;

                  IF (l_token_value IS NULL) THEN
                     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                        Debug('Null Token Found in: ' || l_attr_value);
                     END IF;

                     fnd_message.SET_NAME('PV', 'PV_NULL_TOKEN');
                     fnd_msg_pub.ADD;
                     RAISE FND_API.G_EXC_ERROR;

                     Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 p_msg_name     => 'PV_NULL_TOKEN',
                                 p_token1       => 'Attribute Value',
                                 p_token1_value => l_attr_value);

                     RAISE FND_API.G_EXC_ERROR;
                  END IF;
               END IF;
            END IF;


            -- --------------------------------------------------------------------
            -- Pass NULL token check. Start processing/concatenating the retrieved
            -- attribute value if necessary.
            -- --------------------------------------------------------------------
            IF (l_first_record) THEN
               x_entity_attr_value(p_attribute_id).return_type := l_return_type;
               x_entity_attr_value(p_attribute_id).attribute_value := p_delimiter;
               l_first_record := FALSE;
            END IF;

            -- --------------------------------------------------------------------
            -- If attribute_id is 1 (which is FUE), we need to expand the
            -- attribute value as follows:
            -- e.g. if the attribute value retrieved for FUE is
            -- SW/APP/CRM, we
            -- will expand this so that the result will become:
            -- SW, SW/APP, SW/APP/CRM. Therefore, when attribute_id is 1,
            -- the attribute value will be a concatenated string
            -- separted by a delimiter:
            -- +++SW+++SW/APP+++SW/APP/CRM+++
            -- --------------------------------------------------------------------
            -- IF (p_attribute_id = g_FUE_attr_id) THEN
            IF (p_attribute_id IN (g_a_FUE, g_a_Product_Interest) AND
                p_expand_attr_flag = 'Y')
            THEN
               x_entity_attr_value(p_attribute_id).attribute_value :=
                  x_entity_attr_value(p_attribute_id).attribute_value ||
                  Expand_FUE_Values(
                     p_attr_value       => RTRIM(LTRIM(l_attr_value)),
                     p_delimiter        => p_delimiter,
                     p_additional_token => null);

            -- --------------------------------------------------------------------
            -- If the attribute is "Purchase Amount/Quantity", the attribute value
            -- will be expanded as follows:
            --
            -- e.g.
            --
            -- Suppose that the sql_text returns something like this:
            -- SW/APP:10000:USD:20020123101600
            -- (Product Category:Line Amount:Currency Code:Currency Date)
            --
            -- This string will be expanded into:
            -- +++SW:10000:USD:20020123101600+++SW/APP:10000:USD:20020123101600+++
            -- --------------------------------------------------------------------
            ELSIF (p_attribute_id IN
                  (g_a_Purchase_Amount_Product, g_a_Purchase_Quantity_Product))
            THEN
               x_entity_attr_value(p_attribute_id).attribute_value :=
                  x_entity_attr_value(p_attribute_id).attribute_value ||
                  Process_Purchase_Amt_Qty(p_attribute_id,
                                           RTRIM(LTRIM(l_attr_value)),
                                           p_delimiter);

            -- --------------------------------------------------------------------
            -- All the other attributes will simply have each of the
            -- attribute values concatenated and separated by a delimiter.
            -- --------------------------------------------------------------------
            ELSE
               x_entity_attr_value(p_attribute_id).attribute_value :=
                  x_entity_attr_value(p_attribute_id).attribute_value ||
                  RTRIM(LTRIM(l_attr_value)) || p_delimiter;
            END IF;
         END LOOP;

         CLOSE lc_attr_cursor;

         END IF; -- =============End Processing non-function attributes============

      END IF;

      -- -----------------------------------------------------------------------------------
      -- Even if there are no attribute value returned for this attribute, we still want
      -- to populate x_entity_attr_value with a null value so the caller of this API
      -- will be able to use this to compare to a rule's attribute value in the event
      -- that the operator is IS_NULL or IS_NOT_NULL.
      -- -----------------------------------------------------------------------------------
      IF (NOT x_entity_attr_value.EXISTS(p_attribute_id) OR
          x_entity_attr_value(p_attribute_id).attribute_value IS NULL)
      THEN
         x_entity_attr_value(p_attribute_id).attribute_value := p_delimiter || p_delimiter;
         x_entity_attr_value(p_attribute_id).return_type     := l_return_type;
      END IF;

     /*-------------------------------------------------------------------------
      EXCEPTION
       WHEN g_e_no_bind_variable THEN
          Debug('This SQL Text does not the right numbers of bind variables: ' );
          Debug(l_sql_text);

       WHEN others THEN
          Debug(SQLCODE || ': ' || SQLERRM);
    END; -- End of the BEGIN-END.
      *-------------------------------------------------------------------------*/
   END IF;

   -- -------------------------------------------------------------
   -- Debug Message.
   -- -------------------------------------------------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('********************* Get_Entity_Attr_Values ******************');
      l_msg_string := 'Attr Value: ' || x_entity_attr_value(p_attribute_id).attribute_value;
      -- Debug(l_msg_string);
      Debug('Return Type: ' || x_entity_attr_value(p_attribute_id).return_type);
      Debug('********************************************************************');
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_DEBUG_MSG',
                     p_token1       => 'TEXT',
                     p_token1_value => 'Exception raised while evaluating attribute ID: ' || p_attribute_id,
                     p_token2       => null,
                     p_token2_value => null);

         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

         RAISE;

      WHEN FND_API.g_exc_unexpected_error THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_DEBUG_MSG',
                     p_token1       => 'TEXT',
                     p_token1_value => 'Exception raised while evaluating attribute ID: ' || p_attribute_id,
                     p_token2       => null,
                     p_token2_value => null);

         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

         RAISE;

      WHEN g_e_no_bind_variable THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('This SQL Text does not have the right numbers of bind variables: ' );
            Debug(l_sql_text);
         END IF;

         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_DEBUG_MSG',
                     p_token1       => 'TEXT',
                     p_token1_value => 'Exception raised while evaluating attribute ID: ' || p_attribute_id,
                     p_token2       => null,
                     p_token2_value => null);


         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

         RAISE;

      WHEN OTHERS THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_DEBUG_MSG',
                     p_token1       => 'TEXT',
                     p_token1_value => 'Exception raised while evaluating attribute ID: ' || p_attribute_id,
                     p_token2       => null,
                     p_token2_value => null);

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );

        RAISE;


END Get_Entity_Attr_Values;
-- ========================End of Get_Entity_Attr_Values=======================



--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Retrieve_Input_Filter                                                   |
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
PROCEDURE Retrieve_Input_Filter (
   p_api_version_number   IN      NUMBER,
   p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit               IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level     IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_process_rule_id      IN      NUMBER,
   p_delimiter            IN      VARCHAR2 := '+++',
   x_input_filter         IN OUT  NOCOPY t_input_filter,
   x_return_status        OUT     NOCOPY VARCHAR2,
   x_msg_count            OUT     NOCOPY NUMBER,
   x_msg_data             OUT     NOCOPY VARCHAR2
)
IS
   -- -------------------------------------------------------------------
   -- Only retrieve necessary input filter components (FUE and PSS)
   -- -------------------------------------------------------------------
   CURSOR lc_input_filter IS
      SELECT a.attribute_id,  a.selection_criteria_id, b.attribute_value
      FROM   pv_enty_select_criteria a, pv_selected_attr_values b
      WHERE  a.selection_criteria_id = b.selection_criteria_id AND
             a.process_rule_id       = p_process_rule_id AND
             --a.attribute_id IN (g_FUE_attr_id, g_PSS_attr_id) AND
             a.attribute_id IN (g_a_Product_Interest, g_a_FUE, g_a_PSS) AND
             a.selection_type_code   = 'INPUT_FILTER';

   l_first_record        BOOLEAN := TRUE;
   l_attribute_value     VARCHAR2(3000);
   l_previous_attr_id    NUMBER;
   l_previous_sc_id      NUMBER;
   i                     NUMBER := 1;
   l_api_version         NUMBER := 1;
   l_api_name            VARCHAR2(30) := 'RETRIEVE_INPUT_FILTER';

BEGIN
   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -------------------------- Source code --------------------

   x_input_filter.DELETE;

   FOR lc_cursor IN lc_input_filter LOOP
      IF (l_first_record) THEN
         l_attribute_value := p_delimiter || lc_cursor.attribute_value;
         l_first_record    := FALSE;

      ELSIF (lc_cursor.attribute_id          = l_previous_attr_id AND
             lc_cursor.selection_criteria_id = l_previous_sc_id)
      THEN
         l_attribute_value := l_attribute_value || p_delimiter ||
                              lc_cursor.attribute_value;
      ELSE
         x_input_filter(i).attribute_id    := l_previous_attr_id;
         x_input_filter(i).attribute_value := l_attribute_value || p_delimiter;
         i := i + 1;
         l_attribute_value := p_delimiter || lc_cursor.attribute_value;
      END IF;

      l_previous_attr_id    := lc_cursor.attribute_id;
      l_previous_sc_id      := lc_cursor.selection_criteria_id;
   END LOOP;

   IF (l_previous_attr_id IS NOT NULL) THEN
      x_input_filter(i).attribute_id    := l_previous_attr_id;
      x_input_filter(i).attribute_value := l_attribute_value || p_delimiter;
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

END Retrieve_Input_Filter;
-- ===========================End of Retrieve_Input_Filter=========================



--=============================================================================+
--|  Public Function                                                           |
--|                                                                            |
--|    Currency_Conversion                                                     |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--| NOTES:                                                                     |
--|   When the attribute is of currency type, the attribute value has 3 tokens:|
--|      100000:::USD:::20020115142503                                         |
--|     (Line Amount:::Currency:::Currency Date)                               |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Currency_Conversion(
   p_amount                   IN NUMBER,
   p_currency_code            IN VARCHAR2,
   p_currency_conversion_date IN DATE := SYSDATE,
   p_rule_currency_code       IN VARCHAR2,
   p_no_exception_flag        IN VARCHAR2 := 'N'
)
RETURN NUMBER
IS
   l_api_name               VARCHAR2(30) := 'Currency_Conversion';
   l_converted_attr_value   NUMBER;
   l_conversion_status_flag NUMBER;

BEGIN
   IF (p_amount IS NULL) THEN
      RETURN p_amount;
   END IF;


   -- ---------------------------------------------------------------------------
   -- If the currency_code of the "from" currency is same as that of the "to"
   -- currency, no conversion is necessary.
   -- ---------------------------------------------------------------------------
   IF (p_currency_code = p_rule_currency_code) THEN
      RETURN p_amount;
   END IF;


   -- ---------------------------------------------------------------------------
   -- Package Global Variables needed for doing currency conversion.
   -- ---------------------------------------------------------------------------
   IF (g_period_set_name IS NULL) THEN
      g_period_set_name := FND_PROFILE.Value('AS_FORECAST_CALENDAR');
   END IF;

   IF (g_period_type IS NULL) THEN
      g_period_type := FND_PROFILE.Value('AS_DEFAULT_PERIOD_TYPE');
   END IF;


   BEGIN
      SELECT round((p_amount/rate.denominator_rate) * rate.numerator_rate,2),
             rate.conversion_status_flag
      INTO   l_converted_attr_value, l_conversion_status_flag
      FROM   as_period_rates rate,
             as_period_days day
      WHERE  rate.from_currency  = p_currency_code AND
             rate.to_currency    = p_rule_currency_code AND
             day.period_name     = rate.period_name AND
             day.period_set_name = g_period_set_name AND
             day.period_type     = g_period_type AND
             day.period_day      = TRUNC(p_currency_conversion_date)
	     --- Condition added to fix the bug # 5509934
	     and exists (select 1 from gl_periods glp
			 where glp.period_set_name=g_period_set_name
                         and   glp.adjustment_period_flag='N'
			 and   glp.period_type = g_period_type
                         and   glp.period_name = day.period_name
                         );

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_NO_CURRENCY_RATE_INFO',
                     p_token1       => 'Rule Currency Code',
                     p_token1_value => p_rule_currency_code,
                     p_token2       => 'Entity Currency Code',
                     p_token2_value => p_currency_code,
                     p_token3       => 'Conversion Date',
                     p_token3_value => p_currency_conversion_date);

       IF (p_no_exception_flag = 'Y') THEN
          RETURN null;

       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END; -- End of BEGIN-END

   IF (l_conversion_status_flag = 1) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NO_CURRENCY_RATE_INFO',
                  p_token1       => 'Rule Currency Code',
                  p_token1_value => p_rule_currency_code,
                  p_token2       => 'Entity Currency Code',
                  p_token2_value => p_currency_code,
                  p_token3       => 'Conversion Date',
                  p_token3_value => p_currency_conversion_date);

       IF (p_no_exception_flag = 'Y') THEN
          RETURN null;

       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;

   RETURN l_converted_attr_value;

   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         RAISE;

      WHEN FND_API.g_exc_unexpected_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         RAISE;

      WHEN OTHERS THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         RAISE;

END Currency_Conversion;
-- ===========================End of Currency_Conversion=========================

--=============================================================================+
--|  Public Function                                                           |
--|                                                                            |
--|    Currency_Conversion                                                     |
--|                                                                            |
--==============================================================================
FUNCTION Currency_Conversion(
   p_entity_attr_value  IN VARCHAR2
)
RETURN NUMBER
IS
   l_entity_attr_value      NUMBER;

BEGIN
   l_entity_attr_value :=
   Currency_Conversion(
      p_entity_attr_value  => p_entity_attr_value,
      p_rule_currencY_code => fnd_profile.value('ICX_PREFERRED_CURRENCY'),
      p_no_exception_flag  => 'Y'
   );

   RETURN l_entity_attr_value;
END Currency_Conversion;
-- ===========================End of Currency_Conversion========================


--=============================================================================+
--|  Public Function                                                           |
--|                                                                            |
--|    Currency_Conversion                                                     |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--| NOTES:                                                                     |
--|   When the attribute is of currency type, the attribute value has 3 tokens:|
--|      100000:::USD:::20020115142503                                         |
--|     (Line Amount:::Currency:::Currency Date)                               |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Currency_Conversion(
   p_entity_attr_value   IN VARCHAR2,
   p_rule_currency_code  IN VARCHAR2,
   p_no_exception_flag   IN VARCHAR2 := 'N'
)
RETURN NUMBER
IS
   l_api_name               VARCHAR2(30) := 'Currency_Conversion';
   l_converted_attr_value   NUMBER;
   l_entity_attr_value      NUMBER;
   l_entity_currency_code   VARCHAR2(10);
   l_currency_date          DATE;
   l_num_of_tokens          NUMBER;
   l_conversion_status_flag NUMBER;
   le_rate_not_found        EXCEPTION;
   le_wrong_token_numbers   EXCEPTION;

BEGIN
   --fnd_msg_pub.g_msg_level_threshold := fnd_msg_pub.g_msg_lvl_debug_low;

   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) AND
      (g_display_message))
   THEN
      Debug('Currency Conversion..........................................');
   END IF;

   IF (p_entity_attr_value IS NULL) THEN
      RETURN null;
   END IF;

   -- ----------------------------------------------------------------------------
   -- Parse out tokens in the string.
   -- ----------------------------------------------------------------------------
   l_num_of_tokens := (LENGTH(p_entity_attr_value) -
                       LENGTH(REPLACE(p_entity_attr_value, g_token_delimiter, '')))
                      /LENGTH(g_token_delimiter)
                      + 1;

   IF (l_num_of_tokens <> 3) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_CURRENCY_WRONG_FORMAT',
                  p_token1       => 'TEXT',
                  p_token1_value => 'Entity Attribute Value: ' || p_entity_attr_value,
                  p_token2       => null,
                  p_token2_value => null);

      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- ---------------------------------------------------------------------------
   -- The format mask '999999999999.99' is to ensure that no matter what
   -- NLS_NUMERIC_CHARACTERS is set to in the current session, TO_NUMBER()
   -- function can still interpret it correctly.
   -- ---------------------------------------------------------------------------
   l_entity_attr_value := TO_NUMBER(Retrieve_Token (
                                       p_delimiter         => g_token_delimiter,
                                       p_attr_value_string => p_entity_attr_value,
                                       p_input_type        => 'IN TOKEN',
                                       p_index             => 1
				    ),
                                    '999999999999.99'
                          );


   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) AND
      (g_display_message))
   THEN
      Debug('Entity Attribute Value: ' || l_entity_attr_value);
   END IF;

   -- ----------------------------------------------------------------------------
   -- If the amount is NULL, just return NULL.
   -- ----------------------------------------------------------------------------
   IF (l_entity_attr_value IS NULL) THEN
      RETURN NULL;
   END IF;


   l_entity_currency_code := Retrieve_Token (
                                p_delimiter         => g_token_delimiter,
                                p_attr_value_string => p_entity_attr_value,
                                p_input_type        => 'IN TOKEN',
                                p_index             => 2
                             );


   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) AND
      (g_display_message))
   THEN
      Debug('Entity Currency Code: ' || l_entity_currency_code);
   END IF;

   -- ----------------------------------------------------------------------------
   -- Check for the existence of currency code.
   -- ----------------------------------------------------------------------------
   IF (l_entity_currency_code IS NULL) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NULL_TOKEN',
                  p_token1       => 'TEXT',
                  p_token1_value => 'Entity Attribute Value: ' || p_entity_attr_value,
                  p_token2       => 'TEXT',
                  p_token2_value => 'This attribute value does not have a currency code!');

      RAISE FND_API.G_EXC_ERROR;
   END IF;


   l_currency_date := TO_DATE(Retrieve_Token (
                                p_delimiter         => g_token_delimiter,
                                p_attr_value_string => p_entity_attr_value,
                                p_input_type        => 'IN TOKEN',
                                p_index             => 3
                              ),
                              'yyyymmddhh24miss');



   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) AND
      (g_display_message))
   THEN
      Debug('Currency Date: ' || l_currency_date);
   END IF;

   -- ----------------------------------------------------------------------------
   -- If the currency_code of the entity is the same as that of the rule,
   -- no conversion is necessary.
   -- ----------------------------------------------------------------------------
   IF (l_entity_currency_code = p_rule_currency_code) THEN
      RETURN l_entity_attr_value;
   END IF;

   -- ----------------------------------------------------------------------------
   -- Check for the existence of currency conversion date.
   -- ----------------------------------------------------------------------------
   IF (l_currency_date IS NULL) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NULL_TOKEN',
                  p_token1       => 'TEXT',
                  p_token1_value => 'Entity Attribute Value: ' || p_entity_attr_value,
                  p_token2       => 'TEXT',
                  p_token2_value => 'This attribute value does not have a currency conversion date!');

      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- ----------------------------------------------------------------------------
   -- Check for the existence of currency conversion date.
   -- ----------------------------------------------------------------------------
   IF (g_period_set_name IS NULL) THEN
      g_period_set_name := FND_PROFILE.Value('AS_FORECAST_CALENDAR');
   END IF;

   IF (g_period_type IS NULL) THEN
      g_period_type := FND_PROFILE.Value('AS_DEFAULT_PERIOD_TYPE');
   END IF;


   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) AND
      (g_display_message))
   THEN
      Debug('Period Set Name: ' || g_period_set_name);
      Debug('Period Type:     ' || g_period_type);
   END IF;



  BEGIN
   SELECT round((l_entity_attr_value/rate.denominator_rate) * rate.numerator_rate,2),
          rate.conversion_status_flag
   INTO   l_converted_attr_value, l_conversion_status_flag
   FROM   as_period_rates rate,
          as_period_days day
   WHERE  rate.from_currency  = l_entity_currency_code AND
          rate.to_currency    = p_rule_currency_code AND
          day.period_name     = rate.period_name AND
          day.period_set_name = g_period_set_name AND
          day.period_type     = g_period_type AND
          day.period_day      = TRUNC(l_currency_date) AND
	  --- Condition added to fix the bug # 5509934
	  exists (select 1 from gl_periods glp
		  where glp.period_set_name=g_period_set_name
                  and   glp.adjustment_period_flag='N'
		  and   glp.period_type = g_period_type
                  and   glp.period_name = day.period_name
                  );


   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NO_CURRENCY_RATE_INFO',
                  p_token1       => 'Rule Currency Code',
                  p_token1_value => p_rule_currency_code,
                  p_token2       => 'Entity Currency Code',
                  p_token2_value => l_entity_currency_code,
                  p_token3       => 'Conversion Date',
                  p_token3_value => l_currency_date);

       IF (p_no_exception_flag = 'Y') THEN
          RETURN null;

       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
  END; -- End of BEGIN-END

   IF (l_conversion_status_flag = 1) THEN
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_NO_CURRENCY_RATE_INFO',
                  p_token1       => 'Rule Currency Code',
                  p_token1_value => p_rule_currency_code,
                  p_token2       => 'Entity Currency Code',
                  p_token2_value => l_entity_currency_code,
                  p_token3       => 'Conversion Date',
                  p_token3_value => l_currency_date);

       IF (p_no_exception_flag = 'Y') THEN
          RETURN null;

       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;

   RETURN l_converted_attr_value;

   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         RAISE;

      WHEN FND_API.g_exc_unexpected_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         RAISE;

      WHEN OTHERS THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         RAISE;
END Currency_Conversion;
-- ===========================End of Currency_Conversion========================



--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Debug                                                                   |
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
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2
)
IS

BEGIN
    --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT', p_msg_string);
        FND_MSG_PUB.Add;
    --END IF;
END Debug;
-- =================================End of Debug================================

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
-- ==============================End of Set_Message==============================




-- *****************************************************************************
-- *****************************************************************************
-- ********************* Private Routines Start Here...*************************
-- *****************************************************************************
-- *****************************************************************************


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Check_Match_Logic                                                       |
--|       Provide the logic for checking if there's a match between the        |
--|       opportunity's attribute value and opportunity selection's            |
--|       attribute value.                                                     |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|   When the attribute is purchase_amount, the attribute                     |
--|   value has 4 tokens:                                                      |
--|      SW/APP:::100000:::USD:::20020115142503                                |
--|     (Product Category:::Line Amount:::Currency:::Currency Date)            |
--|                                                                            |
--|   When the attribute is of currency type, the attribute value has 3 tokens:|
--|      100000:USD:20020115142503                                             |
--|     (Line Amount:::Currency:::Currency Date)                               |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Check_Match_Logic(
   p_attribute_id        NUMBER,
   p_attribute_type      VARCHAR2,
   p_operator            VARCHAR2,
   p_entity_attr_value   VARCHAR2,
   p_rule_attr_value     VARCHAR2,
   p_rule_to_attr_value  VARCHAR2,
   p_return_type         VARCHAR2,
   p_rule_currency_code  VARCHAR2
)
RETURN BOOLEAN
IS
   l_matched                 BOOLEAN := FALSE;
   l_entity_num_attr_value   NUMBER;
   l_rule_num_attr_value     NUMBER;
   l_rule_num_to_value       NUMBER;
   l_entity_attr_value       VARCHAR2(2010) := UPPER(p_entity_attr_value);

BEGIN
   Debug('Inside Check_Match_Logic...');
   Debug('Return Type: ' || p_return_type);
   Debug('l_entity_attr_value (80 chars): ' || substr(l_entity_attr_value,1,80));

   -- ----------------------------------------------------------------------
   -- 'MATCH_FUE' is a special process for matching the input filter portion
   -- of a rule.  When the attibute is this type, retrieve the first token
   -- (FUE - Product Interest) of p_entity_attr_value.
   -- ----------------------------------------------------------------------
   IF (g_attribute_type = 'MATCH_FUE') THEN
      l_entity_attr_value :=
         SUBSTR(p_entity_attr_value, 1,
            INSTR(p_entity_attr_value, g_token_delimiter) - 1);

   -- ----------------------------------------------------------------------
   -- If attribute is a purchase_amount (LINE_AMOUNT or FILTER_AMOUNT),
   -- strip the first token (product interest)
   -- off the attribute value string.
   -- ----------------------------------------------------------------------
   ELSIF (p_attribute_type IN ('LINE_AMOUNT', 'FILTER_AMOUNT')) THEN
      l_entity_attr_value :=
         SUBSTR(p_entity_attr_value,
                INSTR(p_entity_attr_value, g_token_delimiter) + LENGTH(g_token_delimiter),
                LENGTH(p_entity_attr_value));
   END IF;

   -- -------------------------------------------------------------------------
   -- Process 'currency' attributes.
   -- -------------------------------------------------------------------------
   IF (p_return_type = 'CURRENCY') THEN
      l_entity_num_attr_value :=
         Currency_Conversion(
            p_entity_attr_value  => l_entity_attr_value,
            p_rule_currency_code => p_rule_currency_code
         );

      IF (l_entity_num_attr_value = g_currency_conversion_error) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

     /* ---------------------------------------------------------------
      l_rule_num_attr_value   :=
         Currency_Conversion(
            p_entity_attr_value  => p_rule_attr_value,
            p_rule_currency_code => p_rule_currency_code
         );

      l_rule_num_to_value     :=
         Currency_Conversion(
            p_entity_attr_value  => p_rule_to_attr_value,
            p_rule_currency_code => p_rule_currency_code
         );
      * ---------------------------------------------------------------- */

      -- ----------------------------------------------------------------
      -- Rule's attribute value should not be in the 3 token format.
      -- It should just be an amount.
      -- Commented out above lines whose modification was made in
      -- 115.26. Reverted back to the logic used in that release.
      -- ----------------------------------------------------------------
      l_rule_num_attr_value   := TO_NUMBER(p_rule_attr_value);
      l_rule_num_to_value     := TO_NUMBER(p_rule_to_attr_value);

      --Debug('l_rule_num_attr_value = ' || l_rule_num_attr_value);
      --Debug('l_entity_num_attr_value = ' || l_entity_num_attr_value);


   ELSIF (p_return_type = 'NUMBER') THEN
      l_entity_num_attr_value := TO_NUMBER(l_entity_attr_value);
      l_rule_num_attr_value   := TO_NUMBER(p_rule_attr_value);
      l_rule_num_to_value     := TO_NUMBER(p_rule_to_attr_value);
   END IF;

   -- Debug('Operator: ' || p_operator);
   -- Debug('l_entity_attr_value: ' || l_entity_attr_value);

   -- ----------------------------------------------------------
   -- operator -> EQUALS
   -- ----------------------------------------------------------
   IF (p_operator = g_equal) THEN
      IF (p_return_type IN ('NUMBER', 'CURRENCY')) THEN
         IF (l_entity_num_attr_value = l_rule_num_attr_value) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         IF (l_entity_attr_value = UPPER(p_rule_attr_value)) THEN
            l_matched := TRUE;
         END IF;
      END IF;

   -- ----------------------------------------------------------
   -- operator -> GREATER_THAN
   -- ----------------------------------------------------------
   ELSIF (p_operator = g_greater_than) THEN
      IF (p_return_type IN ('NUMBER', 'CURRENCY')) THEN
         IF (l_entity_num_attr_value > l_rule_num_attr_value) THEN
            l_matched := TRUE;
         END IF;

      ELSIF (p_return_type = 'DATE') THEN
         IF (l_entity_attr_value > UPPER(p_rule_attr_value)) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- ----------------------------------------------------------
   -- operator -> GREATER_THAN_OR_EQUALS
   -- ----------------------------------------------------------
   ELSIF (p_operator = g_greater_than_equal) THEN
      IF (p_return_type IN ('NUMBER', 'CURRENCY')) THEN
         IF (l_entity_num_attr_value >= l_rule_num_attr_value) THEN
            l_matched := TRUE;
         END IF;

      ELSIF (p_return_type = 'DATE') THEN
         IF (l_entity_attr_value >= UPPER(p_rule_attr_value)) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- ----------------------------------------------------------
   -- operator -> LESS_THAN
   -- ----------------------------------------------------------
   ELSIF (p_operator = g_less_than) THEN
      IF (p_return_type IN ('NUMBER', 'CURRENCY')) THEN
         IF (l_entity_num_attr_value < l_rule_num_attr_value) THEN
            l_matched := TRUE;
         END IF;

      ELSIF (p_return_type = 'DATE') THEN
         IF (l_entity_attr_value < UPPER(p_rule_attr_value)) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- ----------------------------------------------------------
   -- operator -> LESS_THAN_OR_EQUALS
   -- ----------------------------------------------------------
   ELSIF (p_operator = g_less_than_equal) THEN
      IF (p_return_type IN ('NUMBER', 'CURRENCY')) THEN
         IF (l_entity_num_attr_value <= l_rule_num_attr_value) THEN
            l_matched := TRUE;
         END IF;

      ELSIF (p_return_type = 'DATE') THEN
         IF (l_entity_attr_value <= UPPER(p_rule_attr_value)) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- ----------------------------------------------------------
   -- operator -> NOT_EQUALS
   -- ----------------------------------------------------------
   ELSIF (p_operator = g_not_equal) THEN
      IF (p_return_type IN ('NUMBER', 'CURRENCY')) THEN
         IF (l_entity_num_attr_value IS NULL OR
             l_entity_num_attr_value <> l_rule_num_attr_value) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         IF (l_entity_attr_value IS NULL OR
             l_entity_attr_value <> UPPER(p_rule_attr_value)) THEN
            l_matched := TRUE;
         END IF;
      END IF;

   -- ----------------------------------------------------------
   -- operator -> BETWEEN
   -- ----------------------------------------------------------
   ELSIF (UPPER(p_operator) = g_between) THEN
      IF (p_return_type IN ('NUMBER', 'CURRENCY')) THEN
         IF (l_entity_num_attr_value BETWEEN
             l_rule_num_attr_value AND l_rule_num_to_value) THEN
            l_matched := TRUE;
         END IF;

      ELSIF (p_return_type IN ('DATE', 'STRING')) THEN
         -- ----------------------------------------------------------------------------
         -- POSTAL CODE |
         -- -------------
         -- Make a special case for postal code. Use numeric comparision for postal code
         -- if possible. If not, as in the case of Canadian postal code, use string
         -- comparison (handled in the exception).
         -- ----------------------------------------------------------------------------
         IF (p_attribute_id = g_a_Postal_Code) THEN
           BEGIN
            l_rule_num_attr_value    := TO_NUMBER(REPLACE(p_rule_attr_value, '-', '.'));
            l_rule_num_to_value      := TO_NUMBER(REPLACE(p_rule_to_attr_value, '-', '.'));
            l_entity_num_attr_value  := TO_NUMBER(REPLACE(l_entity_attr_value, '-', '.'));


            IF (l_entity_num_attr_value BETWEEN
                l_rule_num_attr_value AND l_rule_num_to_value) THEN
               l_matched := TRUE;
            END IF;

           -- --------------------------------------------------------------------------
           -- If the postal code cannot be converted to a number, use string comparison.
           -- --------------------------------------------------------------------------
           EXCEPTION
              WHEN g_e_numeric_conversion THEN
                 IF (l_entity_attr_value BETWEEN
                    UPPER(p_rule_attr_value) AND UPPER(p_rule_to_attr_value)) THEN
                    l_matched := TRUE;
                 END IF;
           END;

         -- ----------------------------------------------------------------------------
         -- Non-Postal-Code comparison.
         -- ----------------------------------------------------------------------------
         ELSE
            IF (l_entity_attr_value BETWEEN
                UPPER(p_rule_attr_value) AND UPPER(p_rule_to_attr_value)) THEN
               l_matched := TRUE;
            END IF;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;


   -- ----------------------------------------------------------
   -- operator -> BEGINS_WITH
   -- ----------------------------------------------------------
   ELSIF (UPPER(p_operator) = g_begins_with) THEN
      IF (p_return_type = 'STRING') THEN
         -- --------------------------------------------------------
         -- If the matching position starts with 1, then there is a
         -- match.
         -- --------------------------------------------------------
         IF (INSTR(l_entity_attr_value, UPPER(p_rule_attr_value)) = 1) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;


   -- ----------------------------------------------------------
   -- operator -> ENDS_WITH
   -- ----------------------------------------------------------
   ELSIF (UPPER(p_operator) = g_ends_with) THEN
      IF (p_return_type = 'STRING') THEN
         -- --------------------------------------------------------
         -- If the matching position starts with 1, then there is a
         -- match.
         -- --------------------------------------------------------
         IF (SUBSTR(l_entity_attr_value,
                    LENGTH(l_entity_attr_value) - LENGTH(p_rule_attr_value) + 1,
                    LENGTH(p_rule_attr_value))
             =  UPPER(p_rule_attr_value))
         THEN
            l_matched := TRUE;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;


   -- ----------------------------------------------------------
   -- operator -> CONTAINS
   -- ----------------------------------------------------------
   ELSIF (UPPER(p_operator) = g_contains) THEN
      IF (p_return_type = 'STRING') THEN
         IF (INSTR(l_entity_attr_value, UPPER(p_rule_attr_value)) > 0) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;


   -- ----------------------------------------------------------
   -- operator -> NOT CONTAINS
   -- ----------------------------------------------------------
   ELSIF (UPPER(p_operator) = g_not_contains) THEN
      IF (p_return_type = 'STRING') THEN
         IF (INSTR(l_entity_attr_value, UPPER(p_rule_attr_value)) = 0) THEN
            l_matched := TRUE;
         END IF;

      ELSE
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                     p_token1       => 'Operator',
                     p_token1_value => p_operator,
                     p_token2       => 'Attribute Return Type',
                     p_token2_value => p_return_type);

         RAISE FND_API.G_EXC_ERROR;
      END IF;


   -- ----------------------------------------------------------
   -- operator -> IS NULL
   -- ----------------------------------------------------------
   ELSIF (UPPER(p_operator) = g_is_null) THEN
      IF (l_entity_attr_value IS NULL) THEN
         l_matched := TRUE;
      END IF;

   -- ----------------------------------------------------------
   -- operator -> IS NOT NULL
   -- ----------------------------------------------------------
   ELSIF (UPPER(p_operator) = g_is_not_null) THEN
      IF (l_entity_attr_value IS NOT NULL) THEN
         l_matched := TRUE;
      END IF;

   -- ----------------------------------------------------------
   -- WRONG OPERATOR!
   -- ----------------------------------------------------------
   ELSE
      Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_ILLEGAL_OPERATOR',
                  p_token1       => 'Operator',
                  p_token1_value => p_operator,
                  p_token2       => 'Attribute Return Type',
                  p_token2_value => p_return_type);

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   RETURN l_matched;
END Check_Match_Logic;
-- ========================End of Check_Match_Logic=============================


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Retrieve_Token                                                          |
--|        Given a string that contains attribute values separated by          |
--|        p_delimiter, retrieve the n th token in the string.                 |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES: This function assumes that p_string is always preceeded and ended   |
--|        with a p_delimiter. e.g. '+++abc+++def+++'.                         |
--|        The only time that p_string is allowed to not preceed or end with   |
--|        a p_delimiter is when there's only one token in the string.         |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Retrieve_Token (
   p_delimiter           VARCHAR2,
   p_attr_value_string   VARCHAR2,
   p_input_type          VARCHAR2,
   p_index               NUMBER
)
RETURN VARCHAR2
IS
   l_start_position    NUMBER := 1;
   l_token_length      NUMBER;
   l_attr_value_string VARCHAR2(32000);

BEGIN
   Debug('Retrieving Token (80 chars): ' || substr(p_attr_value_string,1,80));

   IF (p_attr_value_string IS NULL) THEN
      RETURN null;
   END IF;

   -- --------------------------------------------------------------------------
   -- Pad 'IN TOKEN' string with p_delimiter in the beginning and the end of
   -- the string so we would only need one algorithm for token retrieval.
   -- --------------------------------------------------------------------------
   IF (p_input_type = 'IN TOKEN') THEN
      l_attr_value_string := p_delimiter || p_attr_value_string || p_delimiter;
   ELSE
      l_attr_value_string := p_attr_value_string;
   END IF;

   -- --------------------------------------------------------------------------
   -- If the index is out of bound, return g_out_of_bound.
   -- --------------------------------------------------------------------------
   IF (p_index > Get_Num_Of_Tokens(p_delimiter, l_attr_value_string)) THEN
      RETURN g_out_of_bound;
   END IF;

   -- --------------------------------------------------------------------------
   -- There's only one token in the string. Return it the way it is.
   -- --------------------------------------------------------------------------
   IF (INSTR(l_attr_value_string, p_delimiter) = 0) THEN
      RETURN l_attr_value_string;
   END IF;

   -- --------------------------------------------------------------------------
   -- Retrieve the token by locating its start position and the length.
   -- --------------------------------------------------------------------------
   FOR i IN 1..p_index LOOP
      l_start_position := INSTR(l_attr_value_string, p_delimiter,
                                l_start_position, 1) + LENGTH(p_delimiter);
   END LOOP;

   l_token_length := INSTR(l_attr_value_string, p_delimiter, l_start_position, 1) -
                     l_start_position;

   RETURN SUBSTR(l_attr_value_string, l_start_position, l_token_length);

   EXCEPTION
      WHEN others THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            Debug('Retrieve Token: ' || p_attr_value_string);
            Debug(SQLCODE || ': ' || SQLERRM);
         END IF;

END Retrieve_Token;
-- ========================End of Retrieve_Token==============================


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Get_Num_Of_Tokens                                                       |
--|        Given a string, p_string, search for the number of tokens separated |
--|        by the delimiter, p_delimiter.                                      |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES: This function assumes that p_string is always preceeded and ended   |
--|        with a p_delimiter. e.g. '+++abc+++def+++'.                         |
--|        The only time that p_string is allowed to not preceed or end with   |
--|        a p_delimiter is when there's only one token in the string.         |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Get_Num_Of_Tokens (
   p_delimiter       VARCHAR2,
   p_string          VARCHAR2
) RETURN NUMBER
IS
   l_num_of_tokens     NUMBER;

BEGIN
   IF (INSTR(p_string, p_delimiter) = 0) THEN
      RETURN 1;
   END IF;

   l_num_of_tokens := ((LENGTH(p_string) - NVL(LENGTH(REPLACE(p_string, p_delimiter, '')), 0))
                      /LENGTH(p_delimiter)) - 1;

   IF (l_num_of_tokens = -1) THEN
      l_num_of_tokens := 1;
   END IF;

   RETURN l_num_of_tokens;

   -- --------------------------------------------------------------------------
   -- Exception Handling: Should check for p_string with more than 1 token, but
   -- does not precced and end with p_delimiter.
   -- --------------------------------------------------------------------------
END Get_Num_Of_Tokens;
-- ===========================End of Get_Num_Of_Token===========================


--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Expand_FUE_Values                                                       |
--|        Pre-11.5.10                                                         |
--|        This function is used when the attribute_id = 1 which is FUE        |
--|        (Functional Expertise). It takes the attribute value of an FUE      |
--|        attribute and return the expanded version of it separted by         |
--|        p_delimiter.                                                        |
--|        e.g.                                                                |
--|           If p_attr_value = 'SW/APP/CRM', the return string would be:      |
--|           SW+++SW/App+++SW/APP/CRM+++                                      |
--|                                                                            |
--|        Since 11.5.10                                                       |
--|        Since 11.5.10, we've moved to single product hierarchy. There will  |
--|        no longer be just 3 levels like 'SW/APP/CRM', but will have n levels|
--|        using category_id. p_attr_value will have store                     |
--|        <category_id>                                                       |
--|        e.g.                                                                |
--|        '1140'                                                              |
--|                                                                            |
--|        Depending on the level that the category_id is at, it may return    |
--|        something like the following:                                       |
--|        1139+++1140+++                                                      |
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
FUNCTION Expand_FUE_Values (
   p_attr_value       VARCHAR2,
   p_delimiter        VARCHAR2,
   p_additional_token VARCHAR2 DEFAULT null
)
RETURN VARCHAR2
IS
   -- ---------------------------------------------------------------------------
   -- The SQL uses the denormalized single product hierarchy view to retrieve
   -- all the parents in the tree. It will also retrieve itself.
   -- ---------------------------------------------------------------------------
   CURSOR c IS
      SELECT a.parent_id attr_value
      FROM   eni_prod_denorm_hrchy_v a,
             ENI_PROD_DEN_HRCHY_PARENTS_V b
      WHERE  a.child_id          = TO_NUMBER(p_attr_value) AND
             a.parent_id         = b.category_id AND
             b.purchase_interest = 'Y' AND
            (b.disable_date IS NULL OR b.disable_date > SYSDATE);

   l_concat_value VARCHAR2(1000);

BEGIN
   FOR x IN c LOOP
      l_concat_value := l_concat_value || x.attr_value ||
                        p_additional_token || p_delimiter;
   END LOOP;

Debug('l_concat_value = ' || l_concat_value);

   RETURN l_concat_value;
END Expand_FUE_Values;
-- ===========================End of Expand_FUE_Values===========================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Process_Purchase_Amt_Qty                                                |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|   For Purchase Amount,                                                     |
--|   the expected format of the attribute value, p_attr_value, is:            |
--|      SW/APP:::100000:::USD:::20020115142502                                |
--|     (Product Category:Line Amount:Currency:Date)                           |
--|                                                                            |
--|   For Purchase Quantity,                                                   |
--|   the expected format of the attribute value, p_attr_value, is:            |
--|      SW/APP:::10                                                           |
--|     (Product Category:Quantity)                                            |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Process_Purchase_Amt_Qty (
   p_attribute_id     IN  VARCHAR2,
   p_attr_value       IN  VARCHAR2,
   p_delimiter        IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_num_of_tokens    NUMBER;
   l_product_category VARCHAR2(1000);
   l_additional_token VARCHAR2(1000);

BEGIN
   l_num_of_tokens := (LENGTH(p_attr_value) -
                       LENGTH(REPLACE(p_attr_value, g_token_delimiter, '')))
                      /LENGTH(g_token_delimiter)
                      + 1;

   -- IF (p_attribute_id = g_purchase_amount_attr_id) THEN
   IF (p_attribute_id = g_a_Purchase_Amount_Product) THEN
      IF (l_num_of_tokens <> 4) THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_WRONG_PSS_FORMAT',
                     p_token1       => 'Attribute ID',
                     p_token1_value => p_attribute_id,
                     p_token2       => 'Attribute Value',
                     p_token2_value => p_attr_value);
      END IF;

   -- ELSIF (p_attribute_id = g_purchase_quantity_attr_id) THEN
   ELSIF (p_attribute_id = g_a_Purchase_Quantity_Product) THEN
      IF (l_num_of_tokens <> 2) THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_WRONG_PSS_QTY_FORMAT',
                     p_token1       => 'Attribute ID',
                     p_token1_value => p_attribute_id,
                     p_token2       => 'Attribute Value',
                     p_token2_value => p_attr_value);
      END IF;
   END IF;

   l_product_category  := SUBSTR(p_attr_value, 1, INSTR(p_attr_value, g_token_delimiter) - 1);
   l_additional_token  := SUBSTR(p_attr_value, INSTR(p_attr_value, g_token_delimiter),
                                 LENGTH(p_attr_value));

   RETURN Expand_FUE_Values(p_attr_value       => l_product_category,
                            p_delimiter        => p_delimiter,
                            p_additional_token => l_additional_token);
END Process_Purchase_Amt_Qty;
-- ===========================End of Process_Purchase_Amt_Qty===========================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Match_FUE                                                               |
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
FUNCTION Match_FUE (
   p_attribute_id         IN      NUMBER,
   p_entity_attr_value    IN      VARCHAR2,
   p_rule_attr_value      IN      VARCHAR2,
   p_rule_to_attr_value   IN      VARCHAR2,
   p_operator             IN      VARCHAR2,
   p_input_filter         IN      t_input_filter,
   p_delimiter            IN      VARCHAR2,
   p_return_type          IN      VARCHAR2,
   p_rule_currency_code   IN      VARCHAR2
)

RETURN BOOLEAN
IS
   l_count                NUMBER  := p_input_filter.COUNT;
   i                      NUMBER  := 1;
   l_matched              BOOLEAN := FALSE;
   l_token_matched        BOOLEAN;
   l_token_matched_count  NUMBER  := 0;
   l_counter              NUMBER;
   l_outer_counter        NUMBER;
   l_rule_attr_value      VARCHAR2(500);
   l_num_of_tokens        NUMBER;
   l_num_of_entity_tokens NUMBER;
   l_entity_attr_value    VARCHAR2(500);
   l_input_filter         t_input_filter;
   l_num_of_input_filter  NUMBER := 0;
   l_attr_id_interested   NUMBER;

BEGIN
   -- Debug('Inside MATCH_FUE...');
   -- Debug('Operator is ' || p_operator);

   g_attribute_type := 'MATCH_FUE';
   l_token_matched := TRUE;

   -- -------------------------------------------------------------------------
   -- Determine which attribute we are evaluting.
   -- -------------------------------------------------------------------------
  /*
   IF (p_attribute_id IN (g_purchase_amount_attr_id, g_purchase_quantity_attr_id)) THEN
      l_attr_id_interested := g_FUE_attr_id;

   ELSIF (p_attribute_id IN (g_PSS_amount_attr_id, g_PSS_quantity_attr_id)) THEN
      l_attr_id_interested := g_PSS_attr_id;
   END IF;
   */

   IF (p_attribute_id IN (g_a_Purchase_Amount_Product, g_a_Purchase_Quantity_Product)) THEN
      l_attr_id_interested := g_a_Product_Interest;

   ELSIF (p_attribute_id IN (g_a_Purchase_Amount_Solutions, g_a_Purchase_Qty_Solutions)) THEN
      l_attr_id_interested := g_a_PSS;
   END IF;

   -- Debug('MATCH_FUE Attribute ID interested is: ' || l_attr_id_interested);

   WHILE (i <= l_count AND l_token_matched) LOOP
      -- -----------------------------------------------------------------------
      -- Do comparison only if the attribute is "product category" (FUE) or
      -- "PSS".
      -- -----------------------------------------------------------------------
      IF (p_input_filter(i).attribute_id = l_attr_id_interested) THEN
         l_num_of_input_filter := l_num_of_input_filter + 1;
         l_outer_counter := 1;
         l_num_of_tokens := Get_Num_Of_Tokens(p_delimiter, p_input_filter(i).attribute_value);
         l_token_matched := FALSE;

         -- ---------------------------------------------------------------------
         -- Going through the input filter tokens one at a time (OR condition).
         -- ---------------------------------------------------------------------
         WHILE ((NOT l_token_matched) AND l_outer_counter <= l_num_of_tokens) LOOP
            l_rule_attr_value := Retrieve_Token (
                                    p_delimiter         => p_delimiter,
                                    p_attr_value_string => p_input_filter(i).attribute_value,
                                    p_input_type        => 'STD TOKEN',
                                    p_index             => l_outer_counter
                                 );

            l_num_of_entity_tokens := Get_Num_Of_Tokens(p_delimiter, p_entity_attr_value);
            l_counter := 1;
            l_matched := FALSE;

            --Debug('Input Filter/Rule Attribute Value: ' || l_rule_attr_value);

            -- ---------------------------------------------------------------------
            -- Going through the lead's attribute value (FUE) one at a time.
            -- ---------------------------------------------------------------------
            WHILE ((NOT l_token_matched) AND l_counter <= l_num_of_entity_tokens) LOOP
               l_entity_attr_value := Retrieve_Token (
                                         p_delimiter         => p_delimiter,
                                         p_attr_value_string => p_entity_attr_value,
                                         p_input_type        => 'STD TOKEN',
                                         p_index             => l_counter
                                      );

               -- ------------------------------------------------------------------
               -- Compare Product Category Attribute for the lead and the input
               -- filter.
               -- ------------------------------------------------------------------
               l_matched := Check_Match_Logic (
                               p_attribute_id       => p_attribute_id,
                               p_attribute_type     => 'DUMMY',
                               p_operator           => g_equal,
                               p_entity_attr_value  => l_entity_attr_value,
                               p_rule_attr_value    => l_rule_attr_value,
                               p_rule_to_attr_value => null,
                               p_return_type        => 'STRING',
                               p_rule_currency_code => null
                            );


               -- Debug('--------------------------------------------------');
               -- Debug('Input Filter Index:        ' || i);
               -- Debug('Rule Entity Outer Counter: ' || l_outer_counter);
               -- Debug('Lead Token Counter       : ' || l_counter);

               -- -----------------------------------------------------------------------
               -- Compare PURCHASE AMOUNT/QUANTITY of the CRITERIA to that of the lead's.
               -- -----------------------------------------------------------------------
               IF (l_matched) THEN
                  g_attribute_type := 'NORMAL';

                  l_token_matched := Check_Match(
                                        p_attribute_id       => g_dummy_attr_id, -- Dummy Value
                                        p_entity_attr_value  => l_entity_attr_value,
                                        p_rule_attr_value    => p_rule_attr_value,
                                        p_rule_to_attr_value => p_rule_to_attr_value,
                                        p_operator           => p_operator,
                                        p_input_filter       => l_input_filter,
                                        p_delimiter          => p_delimiter,
                                        p_return_type        => p_return_type,
                                        p_rule_currency_code => p_rule_currency_code
                                     );

                  g_attribute_type      := 'MATCH_FUE';

                  IF (l_token_matched) THEN
                     l_token_matched_count := l_token_matched_count + 1;
                     -- Debug('TOKEN MATCHED!!!!!!!');
                  END IF;
               END IF;

               l_counter := l_counter + 1;
            END LOOP;

            l_outer_counter := l_outer_counter + 1;
         END LOOP;
      END IF;

      i := i + 1;
   END LOOP;

   IF (l_token_matched_count < l_num_of_input_filter) THEN
      l_matched := FALSE;
      -- Debug('Final MATCH_FUE MATCH? ' || 'FALSE');

   ELSE
      l_matched := TRUE;
      -- Debug('Final MATCH_FUE MATCH? ' || 'TRUE');
   END IF;

   g_attribute_type := 'NORMAL';

   RETURN l_matched;
END Match_FUE;
-- ===========================End of Match_FUE==================================

-- -----------------------------------------------------------------------------------
   -- For given a Partner_Id, Attribute_id, it returns value for currency related attribute
   --
   -- -----------------------------------------------------------------------------------
  FUNCTION get_attr_curr(p_partner_id IN NUMBER , p_attribute_id IN NUMBER)
  RETURN VARCHAR2
   IS

  l_attr_curr   	VARCHAR2(2000) ;
  l_sql_attr_curr       VARCHAR2(4000) ;

  BEGIN

    l_attr_curr := NULL;
    l_sql_attr_curr := 'SELECT attr_text
                        FROM PV_SEARCH_ATTR_VALUES
                        WHERE party_id(+) =  :1  AND attribute_id(+) = :2 ';

     EXECUTE IMMEDIATE l_sql_attr_curr
             INTO l_attr_curr
             USING p_partner_id, p_attribute_id;

     return l_attr_curr;

  END get_attr_curr;

   -- -----------------------------------------------------------------------------------
   -- For given a Partner_Id, Attribute_id, it returns value for count related attribute
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_attr_cnt(
                p_partner_id IN NUMBER ,
                p_attribute_id IN NUMBER)
   RETURN NUMBER
   IS

  l_attr_cnt   NUMBER;
  l_sql_attr_cnt   VARCHAR2(4000);

BEGIN

     l_attr_cnt := NULL;
     l_sql_attr_cnt := 'SELECT attr_value
                        FROM PV_SEARCH_ATTR_VALUES
                        WHERE party_id(+) = :1 AND attribute_id(+) = :2 '  ;

     EXECUTE IMMEDIATE l_sql_attr_cnt
             INTO l_attr_cnt
             USING p_partner_id, p_attribute_id;

     return l_attr_cnt;
  END get_attr_cnt;


   -- -----------------------------------------------------------------------------------
   -- For given a Partner_Id, Attribute_id, it returns value for rate related attribute
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_attr_rate(
                p_partner_id IN NUMBER ,
                p_attribute_id IN NUMBER)
   RETURN NUMBER
   IS

  l_attr_rate   NUMBER;
  l_sql_attr_rate   VARCHAR2(4000);

BEGIN

      l_attr_rate := NULL;
      l_sql_attr_rate := 'SELECT round(psav.attr_value*100,pav.decimal_points)
                          FROM   PV_SEARCH_ATTR_VALUES psav, pv_attributes_b pav
                          WHERE  party_id(+) =  :1
                          AND    pav.attribute_id=psav.attribute_id
                          AND    psav.attribute_id(+) = :2';

     EXECUTE IMMEDIATE l_sql_attr_rate
             INTO l_attr_rate
             USING p_partner_id, p_attribute_id;

     return l_attr_rate;
  END get_attr_rate;

   -- -----------------------------------------------------------------------------------
   -- For given a ATTRIBUTE_ID and ATTR_CODE_ID, it returns description of the attribute
   -- code. E.g. It's mainly used for Partner_Level code only.
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_partner_level_desc(
                p_attribute_id IN NUMBER,
		p_attr_code_id IN NUMBER
		)
   RETURN VARCHAR2
   IS

     l_partner_level_desc	VARCHAR2(240);

     CURSOR l_get_partner_level(cv_attribute_id NUMBER, cv_attr_code_id NUMBER) IS
	SELECT description
	FROM   pv_attribute_codes_vl
	WHERE  attribute_id = cv_attribute_id
	AND    attr_code_id = cv_attr_code_id ;

   BEGIN

     l_partner_level_desc := NULL;

     OPEN l_get_partner_level(p_attribute_id, p_attr_code_id );
     FETCH l_get_partner_level INTO l_partner_level_desc;
     CLOSE l_get_partner_level;

     RETURN l_partner_level_desc;

   END get_partner_level_desc;

   -- -----------------------------------------------------------------------------------
   -- For a given a ATTRIBUTE_ID, and ATTR_CODE, it returns description of the attribute
   -- code. E.g. It's mainly used for all attributes other than Partner_Level code.
   --
   -- -----------------------------------------------------------------------------------
   FUNCTION get_attr_code_desc(
                p_attribute_id IN NUMBER,
		p_attr_code    IN VARCHAR2
		)
   RETURN VARCHAR2
   IS

	l_attr_code_desc	VARCHAR2(240);

	CURSOR lc_attr_code_desc(cv_attribute_id NUMBER, cv_attr_code VARCHAR2) IS
		SELECT description
		FROM   pv_attribute_codes_vl
		WHERE  attribute_id = cv_attribute_id
		AND    attr_code = cv_attr_code;

   BEGIN

	l_attr_code_desc := NULL;

	OPEN lc_attr_code_desc(p_attribute_id, p_attr_code );
	FETCH lc_attr_code_desc INTO l_attr_code_desc;
	CLOSE lc_attr_code_desc;

	RETURN l_attr_code_desc;

   END get_attr_code_desc;

END pv_check_match_pub;

/
