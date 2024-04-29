--------------------------------------------------------
--  DDL for Package Body PV_RULE_EVALUATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_RULE_EVALUATION_PUB" as
/* $Header: pvxpprgb.pls 120.5 2006/05/16 17:44:46 dhii noship $*/

-- --------------------------------------------------------------
-- Used for inserting output messages to the message table.
-- --------------------------------------------------------------
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_level     IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT
);

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

function in_list  ( p_string in varchar2 ) return jtf_varchar2_table_32767;


-- #############################################################################
--     Partner Evaluation Outcome
-- #############################################################################


PROCEDURE partner_evaluation_outcome(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2       := FND_API.g_false,
   p_commit                     IN  VARCHAR2         := FND_API.g_false,
   p_validation_level           IN  NUMBER          := FND_API.g_valid_level_full,
   p_partner_id                 IN  NUMBER,
   p_rule_id_tbl                IN  JTF_NUMBER_TABLE,
   x_attr_id_tbl                OUT NOCOPY JTF_NUMBER_TABLE,
   x_attr_evaluation_result_tbl OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_partner_attr_value_tbl     OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
   x_evaluation_criteria_tbl    OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
   x_rule_pass_flag             OUT NOCOPY VARCHAR2,
   x_delimiter       OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS

        TYPE c_attr_mean IS REF CURSOR;

   l_rule_id_tbl      JTF_NUMBER_TABLE    := JTF_NUMBER_TABLE();
        l_attr_val_tbl      JTF_VARCHAR2_TABLE_4000   := JTF_VARCHAR2_TABLE_4000();
   l_attr_to_val      JTF_VARCHAR2_TABLE_1000   := JTF_VARCHAR2_TABLE_1000();
   l_operator_tbl     JTF_VARCHAR2_TABLE_1000   := JTF_VARCHAR2_TABLE_1000();
        l_currency_tbl      JTF_VARCHAR2_TABLE_100    := JTF_VARCHAR2_TABLE_100();
   l_criterion_id_tbl    JTF_NUMBER_TABLE    := JTF_NUMBER_TABLE();
   l_cri_condition_tbl      JTF_VARCHAR2_TABLE_100    := JTF_VARCHAR2_TABLE_100();
   l_attribute_value_tbl    JTF_VARCHAR2_TABLE_4000   := JTF_VARCHAR2_TABLE_4000();


   l_input_filter    pv_check_match_pub.t_input_filter;
   l_entity_attr_value   pv_check_match_pub.t_entity_attr_value;

   lc_attr_cursor    c_attr_mean;
   l_lov_string      VARCHAR2(4000) :=  null;

   l_rule_id      NUMBER;
   l_attribute_id    NUMBER;
   l_currency      VARCHAR2(30);
   l_operator     VARCHAR2(30);
   l_cri_id    NUMBER;
   l_att_val      VARCHAR2(4000);
   l_att_to_val      VARCHAR2(1000);
   l_att_val_mean    VARCHAR2(1000);
   l_opr_meaning           VARCHAR2(1000);
   l_attribute_name        VARCHAR2(1000);
   l_attr_in_string        VARCHAR2(4000);

   l_prev_rule_id    NUMBER := NULL;
   l_prev_attr_id    NUMBER := NULL;
   l_prev_criteria_id   NUMBER := NULL;
   l_prev_currency      VARCHAR2(1000);
   l_prev_operator      VARCHAR2(1000);
   l_prev_att_val    VARCHAR2(4000) := NULL;
   l_prev_att_to_val VARCHAR2(1000);
   l_prev_att_name        VARCHAR2(1000);

   l_attr_value      VARCHAR2(4100) := NULL;
   l_attr_val_meaning      VARCHAR2(1000) := NULL;
   l_attr_to_val_mean      VARCHAR2(1000) := NULL;
   l_attrib_to_val         VARCHAR2(1000) := NULL;
   l_att_code          VARCHAR2(1000) := NULL;
   l_concat_attr_mean   VARCHAR2(1000) := NULL;


   l_attribute_value       VARCHAR2(4100) := NULL;

   l_rule_pass_flag  BOOLEAN := FALSE;
   l_total_rows      NUMBER;
   l_criteria_count  NUMBER := 0;
   l_non_cri_count    NUMBER := 0;
   l_last_cri_cnt    NUMBER := 0;
   l_total_criteria  NUMBER := 0;
   l_temp_variable varchar2(4000);
   j         NUMBER;
   l_cnt       NUMBER := 0;
   l_count        NUMBER := 0;


        l_result     BOOLEAN;


   -- =============================================================================================
   -- This query evaluates the attribute Id for the given Rule ID Set
   -- Rules are hierarchical.
   -- e.g.
   -- Rule1(root) --> Rule2(Level 1 Child) --> Rule3(Level 2 Child)
   -- -----------------------------------------------------------------------
   -- Rule1 (attribute1 > 30, attribute2 > 40)
   -- Rule2 (attribute3 > 50, attribute4 > 60)
   -- Rule3 (attribute1 > 45, attribute4 > 50)

   -- Combined Attribute List (which will be used as the basis of evaluation:
   -- attribute1 > 45 (R3 overwrites R1)
   -- attribute2 > 40
   -- attribute3 > 50
   -- attribute4 > 60

   -- Query Description :


   -- Inline View Z :

        -- "SELECT a.process_rule_id, b.attribute_id, x.rank, x.process_rule_id rule_id
   --    FROM  pv_process_rules_vl a, pv_enty_select_criteria b,
        --     (SELECT rownum rank, column_value process_rule_id
        --      FROM  (SELECT column_value FROM   TABLE (CAST(p_rule_id_tbl AS JTF_NUMBER_TABLE))) ) x
        --      WHERE  a.process_rule_id = x.process_rule_id
        --      AND    a.process_rule_id = b.process_rule_id "

        -- " SELECT column_value FROM   TABLE (CAST(p_rule_id_tbl AS JTF_NUMBER_TABLE "
   -- In the above select statement CAST ensures the order of Rule ID set from the query
   -- remains the same as that of INPUT RULE ID TABLE.

        --
   -- Since rules are hierarchical rank is assigned to them starting with the Parent (Parent
   -- Rule ID gets the least priority )

   -- Rownum evaluates the rank of the attribute ID based on how many times it is repeated in the rule.
   -- Result of the above inline view Z would be
   -- -----------------------------------------------------------------------------------------------
   -- Rule ID        Attribute ID      Rank
   -- ================================================================================================
   --         1          attribute1     1
   --         1                     attribute2      1
   --         2          attribute3     2
   --    2         attribute4     2
   --         3                     attribute1      3
   --         3          attribute4     3
   -- ------------------------------------------------------------------------------------------------
   -- When we take the MAX(rank)  grouped by attribute ID
   -- for the above set the combined attribute list is achieved

   -- Final combined attribute list from INLINE VIEW XY would be
   -- -------------------------------------------------------------------------------------------------
   --    Rule ID        Attribute ID      Rank
   -- =================================================================================================
   --         1                     attribute2      1
   --         2          attribute3     2
   --         3                     attribute1      3
   --         3          attribute4     3
   -- --------------------------------------------------------------------------------------------------

   -- ====================================================================================================


   cursor lc_get_rule_details
   is
   SELECT  /*+ leading(x) */ xy.attribute_id Attribute_ID,
           xy.rule_id Rule_ID,
                rule.currency_code Currency_Code,
                criterion.operator Operator,
                criterion.selection_criteria_id Criteria_ID,
                AttVal.attribute_value Attr_Value,
                AttVal.attribute_to_value Attr_To_Value
        FROM    pv_process_rules_vl Rule,
           pv_enty_select_criteria Criterion,
                pv_selected_attr_values AttVal,
          ( SELECT attribute_id,TO_NUMBER(LTRIM(substr(rule_rank, 1, 10), 0)) rank,TO_NUMBER(LTRIM(substr(rule_rank, 11, LENGTH(rule_rank)), 0)) rule_id
            FROM (
                 SELECT z.attribute_id, MAX(LPAD(z.rank, 10, 0) || LPAD(z.process_rule_id, 100, 0)) rule_rank
                 FROM (
                      SELECT a.process_rule_id, b.attribute_id, x.rank, x.process_rule_id rule_id
                      FROM  pv_process_rules_vl a,
                       pv_enty_select_criteria b,
                      (SELECT rownum rank, column_value process_rule_id
                       FROM  (SELECT column_value
                         FROM   TABLE (CAST(p_rule_id_tbl AS JTF_NUMBER_TABLE))) ) x
                      WHERE  a.process_rule_id = x.process_rule_id
                      AND    a.process_rule_id = b.process_rule_id ) z
                      group by z.attribute_id
            )) xy
        WHERE  Rule.process_rule_id            = Criterion.process_rule_id
        AND    Criterion.selection_criteria_id = Attval.selection_criteria_id
        AND    Criterion.selection_type_code   = 'PARTNER_SELECTION'
        AND    Rule.process_rule_id        = xy.rule_id
   AND    criterion.attribute_id          = xy.attribute_id
   AND    criterion.process_rule_id       = xy.rule_id
        order  by xy.rank;

        CURSOR  lc_attr_mean_cursor(pc_attribute_id NUMBER) IS
        SELECT  lov_string
        FROM    pv_entity_attrs
        WHERE   lov_string IS NOT NULL
   AND     entity = 'PARTNER'
   AND     enabled_flag = 'Y'
   AND     attribute_id = pc_attribute_id;

   l_api_name            CONSTANT VARCHAR2(30) := 'partner_evaluation_outcome';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

begin

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      Debug(l_api_name,FND_LOG.LEVEL_PROCEDURE);
   END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;
   x_delimiter     := '+++';

   IF p_rule_id_tbl.count  = 0 THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_DEBUG_MESSAGE',
                     p_token1       => 'TEXT',
                     p_token1_value => 'Rule ID is not passed in',
                     p_token2       => NULL,
                     p_token2_value => NULL);

         RAISE FND_API.G_EXC_ERROR;
   END IF;

   x_attr_id_tbl                := JTF_NUMBER_TABLE();
   x_attr_evaluation_result_tbl := JTF_VARCHAR2_TABLE_100();
   x_partner_attr_value_tbl     := JTF_VARCHAR2_TABLE_4000();
   x_evaluation_criteria_tbl    := JTF_VARCHAR2_TABLE_4000();


   open lc_get_rule_details;
   loop

      fetch lc_get_rule_details into l_attribute_id, l_rule_id, l_currency,l_operator,l_cri_id, l_att_val, l_att_to_val;

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         debug(' Rule ID '||l_rule_id ||' Attribute ID '||l_attribute_id||' Criteria ID '||l_cri_id);
			l_temp_variable := l_att_val;
	      while (l_temp_variable is not null) loop
				debug('attr Val' ||substr( l_temp_variable, 1, 1800 ));
				l_temp_variable := substr( l_temp_variable, 1801 );
			end loop;
		END IF;

		l_total_rows := lc_get_rule_details%ROWCOUNT;

      IF lc_get_rule_details%NOTFOUND AND l_total_rows = 0 THEN
			x_rule_pass_flag := 'PASS';
			return;
      END IF;

      -- ===========================================================================================
      -- If a rule has same attributes with two criteria, they would be considered as AND Condition
      -- In that case Attribute ID tbl will have same entry twice. If not then it is considered to be
      -- OR condition.
      -- Attr Value for OR Condition would be like US,UK ( Concatnated Value of all the attribute value
      -- for that Rule ID and Attribute ID combination
      -- =============================================================================================

      -- ==============================================================================================
      -- Evaluating for OR Condition
      -- ==============================================================================================

		IF l_cri_id is not null THEN

         IF  (l_prev_rule_id = l_rule_id  AND l_prev_attr_id = l_attribute_id
         AND l_prev_criteria_id  = l_cri_id )      THEN

            IF l_attr_value is null THEN
					l_attr_value  := l_prev_att_val;
					l_attribute_value  := ''''||l_prev_att_val||'''';
					IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
						l_temp_variable := l_attribute_value;
						while (l_temp_variable is not null) loop
							debug('l_attribute_value' ||substr( l_temp_variable, 1, 1800 ));
							l_temp_variable := substr( l_temp_variable, 1801 );
						end loop;
					END IF;

				END IF;

				l_criteria_count   := l_criteria_count + 1;
				l_attr_value       := l_attr_value || x_delimiter ||l_att_val;
				l_attribute_value  := l_attribute_value || ',' || '''' || l_att_val || '''';

				IF lc_get_rule_details%NOTFOUND THEN

					IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
						debug('At the last record ................');
					END IF;

					l_criteria_count   := l_criteria_count - 1;

					-- =================================================================================================
					-- Since the loop is not exited even after the last record the values of previous and current record
					-- will be the same hence attr_value will have the value appended twice for the last record
					-- Hence removing it
					-- ==================================================================================================

					l_attr_value := substr(l_attr_value, 1, length(l_attr_value)-length(l_att_val)-length(x_delimiter));
					l_attribute_value  := substr(l_attribute_value, 1, length(l_attribute_value)-length(l_att_val)-3);

					IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
						l_temp_variable := l_attribute_value;
						while (l_temp_variable is not null) loop
							debug('l_attribute_value for the last record' ||substr( l_temp_variable, 1, 1800 ));
							l_temp_variable := substr( l_temp_variable, 1801 );
						end loop;
					END IF;

					-- ========================================================================================
					-- Here the values will be inserted to the PL/SQL table only for the last record
					-- and also if it is an OR condition
					-- ========================================================================================

					IF l_criteria_count >= 1 THEN

						l_cnt := l_cnt + 1;

						l_rule_id_tbl.extend;
						x_attr_id_tbl.extend;
						l_currency_tbl.extend;
						l_operator_tbl.extend;
						l_criterion_id_tbl.extend;
						l_attr_val_tbl.extend;
						l_attr_to_val.extend;
						l_cri_condition_tbl.extend;
						l_attribute_value_tbl.extend;

						l_rule_id_tbl(l_cnt)      := l_rule_id;
						x_attr_id_tbl(l_cnt)     := l_attribute_id;
						l_currency_tbl(l_cnt)       := l_currency;
						l_operator_tbl(l_cnt)       := l_operator;
						l_criterion_id_tbl(l_cnt)   := l_cri_id;
						l_attr_val_tbl(l_cnt)       := x_delimiter||l_attr_value||x_delimiter;
						l_attribute_value_tbl(l_cnt)     := l_attribute_value;

						IF l_att_to_val is not null THEN
							l_attr_to_val(l_cnt)  := l_att_to_val;
						ELSE
							l_attr_to_val(l_cnt)  := NULL;
						END IF;

						l_cri_condition_tbl(l_cnt)   := 'OR';

					END IF;
				END IF;

			ELSE

				IF  l_prev_rule_id is not null   AND  l_prev_attr_id is not null
				AND l_prev_criteria_id is not null  THEN

					-- ============================================================================
					-- Making sure that first record does not get inserted always with criteria
					-- condition check.For the first record all the previous values will be null.
					-- ============================================================================

					l_cnt := l_cnt + 1;

					l_rule_id_tbl.extend;
					x_attr_id_tbl.extend;
					l_currency_tbl.extend;
					l_operator_tbl.extend;
					l_criterion_id_tbl.extend;
					l_attr_val_tbl.extend;
					l_attr_to_val.extend;
					l_cri_condition_tbl.extend;
					l_attribute_value_tbl.extend;

					l_total_criteria := l_criteria_count;
					l_criteria_count := 0;

					l_rule_id_tbl(l_cnt)      := l_prev_rule_id;
					x_attr_id_tbl(l_cnt)      := l_prev_attr_id;
					l_currency_tbl(l_cnt)     := l_prev_currency;
					l_operator_tbl(l_cnt)     := l_prev_operator;
					l_criterion_id_tbl(l_cnt)    := l_prev_criteria_id;

					IF l_total_criteria > 0 THEN

						l_attr_val_tbl(l_cnt)     := x_delimiter|| l_attr_value ||x_delimiter;
						l_attribute_value_tbl(l_cnt):= l_attribute_value;

						IF l_prev_att_to_val is not null THEN
							l_attr_to_val(l_cnt)  := l_prev_att_to_val;
						ELSE
							l_attr_to_val(l_cnt)  := NULL;
						END IF;

						l_cri_condition_tbl(l_cnt)  := 'OR';

					ELSE
						-- ===================================================================================
						-- Criteria Condition Will be '0' for the AND condition which means that the Criteria ID
						-- has changed.
						-- ===================================================================================

						l_attr_value := l_att_val;

						IF l_prev_att_val IS NOT NULL THEN
							l_attr_val_tbl(l_cnt)    := x_delimiter||l_prev_att_val||x_delimiter;
							l_attribute_value_tbl(l_cnt) := ''||l_prev_att_val||'';
						ELSE
							l_attr_val_tbl(l_cnt)   := NULL;
							l_attribute_value_tbl(l_cnt) := NULL;
						END IF;
						l_cri_condition_tbl(l_cnt) := 'AND';

						IF l_prev_att_to_val is not null THEN
							l_attr_to_val(l_cnt)  := l_prev_att_to_val;
						ELSE
							l_attr_to_val(l_cnt)  := NULL;
						END IF;

					END IF;

				ELSE
					IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
						debug('At first record ');
					END IF;

					l_non_cri_count := l_non_cri_count + 1;

				END IF;

				l_total_criteria := 0;
				l_attr_value    := null;
				l_attribute_value := null;

			END IF;

		END IF;

		-- ========================================================================================
		-- Here the values will be inserted to the PL/SQL table only for the last record
		-- and also if it is an AND condition
		-- ========================================================================================

		IF (lc_get_rule_details%NOTFOUND
		AND l_total_rows > 0 AND l_criteria_count = 0) THEN

			l_last_cri_cnt := l_criteria_count ;
         l_attr_value := l_att_val;

         l_rule_id_tbl.extend;
         x_attr_id_tbl.extend;
         l_currency_tbl.extend;
         l_operator_tbl.extend;
         l_criterion_id_tbl.extend;
         l_attr_val_tbl.extend;
         l_attr_to_val.extend;
         l_cri_condition_tbl.extend;
         l_attribute_value_tbl.extend;

         l_cnt := l_cnt+1;

         l_rule_id_tbl(l_cnt)    := l_rule_id;
         x_attr_id_tbl(l_cnt)    := l_attribute_id;
         l_currency_tbl(l_cnt)      := l_currency;
         l_operator_tbl(l_cnt)      := l_operator;
         l_criterion_id_tbl(l_cnt)  := l_cri_id;

         IF l_attr_value IS NOT NULL THEN
            l_attr_val_tbl(l_cnt)    := x_delimiter|| l_attr_value ||x_delimiter;
            l_attribute_value_tbl(l_cnt)  := ''||l_attr_value||'';
         ELSE
            l_attr_val_tbl(l_cnt)    := NULL;
         END IF;

         IF l_att_to_val is not null THEN
            l_attr_to_val(l_cnt)  :=  l_att_to_val;
         ELSE
            l_attr_to_val(l_cnt)  := NULL;
         END IF;

			l_cri_condition_tbl(l_cnt)   := 'AND';

		END IF;

		l_prev_attr_id      := l_attribute_id;
		l_prev_rule_id      := l_rule_id;
		l_prev_criteria_id  := l_cri_id;
		l_prev_currency     := l_currency;
		l_prev_operator     := l_operator;
		l_prev_att_to_val   := l_att_to_val;
		l_prev_att_val      := l_att_val;

		exit when lc_get_rule_details%notfound;

  end loop;
  close lc_get_rule_details;

  l_rule_pass_flag := TRUE;
  x_rule_pass_flag := 'PASS';

  IF l_rule_id_tbl.count > 0 THEN

     for i in 1 .. l_rule_id_tbl.count
     loop
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          debug(' Rule ID ####################### '|| l_rule_id_tbl(i));
          debug(' Attribute ID ################## '|| x_attr_id_tbl(i));
          debug(' Criteria ID ################### '|| l_criterion_id_tbl(i));
          debug(' Currency ###################### '|| l_currency_tbl(i));
          debug(' Operator ###################### '|| l_operator_tbl(i));
          debug(' Attr to Val ################### '|| l_attr_to_val(i));
          debug(' Criteria Condition ############ '|| l_cri_condition_tbl(i));
          --debug(' Attr Value #################### '|| l_attr_val_tbl(i));
          l_temp_variable := l_attr_val_tbl(i);
	      while (l_temp_variable is not null) loop
		debug('Attr Value ####################  ' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;

	  --debug(' Attribute Value ############### '|| l_attribute_value_tbl(i));

	  l_temp_variable := l_attribute_value_tbl(i);
	      while (l_temp_variable is not null) loop
		debug('Attribute Value ############### ' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;
        END IF;

            l_count := l_count + 1;

      -- =======================================================================
      -- Retrieve meaning for operator
      -- =======================================================================

          select meaning
          into   l_opr_meaning
          from   pv_lookups
          where  lookup_type = 'PV_NUM_DATE_OPERATOR'
          and    lookup_code = l_operator_tbl(i);

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            debug(' Operator Meaning  '|| l_opr_meaning );
          END IF;

     -- ==========================================================================
     -- Retrieve the LOV String for the attribute to get the meaning of Attribute
     -- Value
     -- ==========================================================================

        FOR v_sql_cursor IN lc_attr_mean_cursor(x_attr_id_tbl(i))
        LOOP
            l_lov_string := v_sql_cursor.lov_string;
        END LOOP;

--     debug(' LOV String from pv_entity_attrs  '|| l_lov_string );


     -- ==========================================================================
     -- LOV String is appended with the evaluated attribute value to get meaning
     -- only for selected attribute values
     -- ==========================================================================
       IF (l_lov_string IS NULL OR LENGTH(l_lov_string) = 0) THEN

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              Debug ('Value could be NUMBER, DATE OR CURRENCY or STRING would be free text');
          END IF;

       END IF;




      IF (l_lov_string IS NOT NULL OR LENGTH(l_lov_string) <> 0) THEN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          debug(' in the If Condition ');
         END IF;

          -- ==========================================================================
          -- Retrieved LOV_String has an '?' replacing that with ':X' since SQL cannot
          -- recoganize '?' as an input
          -- ==========================================================================

          l_lov_string := replace(l_lov_string,'?',':X');

          IF l_operator_tbl(i) = 'BETWEEN' THEN

             l_lov_string   := 'SELECT decode(t.code, :1, t.meaning, t.code) Attr_Value ,'||
                               'decode(t.code, :2, t.meaning, t.code) Attr_to_Value, t.code ' ||
                               'FROM ('|| l_lov_string ||' )  t WHERE t.code in ( :4,:5)';



           ELSE

               l_lov_string   := 'SELECT t.meaning FROM (' || l_lov_string ||' )  t WHERE t.code IN '||
                                   '( SELECT * FROM THE ( SELECT CAST( :Y as JTF_VARCHAR2_TABLE_32767 ) from dual ))';

           END IF;

           l_attr_in_string := replace(l_attribute_value_tbl(i),'''','');

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             --debug(' Attribute in string '||l_attr_in_string);
	     l_temp_variable := l_attr_in_string;
	      while (l_temp_variable is not null) loop
		debug('Attribute in string  ' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;
          END IF;
          IF l_operator_tbl(i) = 'BETWEEN' THEN
            l_attr_val_meaning := null;
            OPEN lc_attr_cursor FOR l_lov_string USING l_attr_in_string,l_attr_to_val(i),x_attr_id_tbl(i),l_attr_in_string, l_attr_to_val(i);
            LOOP
                FETCH lc_attr_cursor INTO l_att_val_mean, l_attrib_to_val, l_att_code;
                EXIT WHEN lc_attr_cursor%NOTFOUND;


                IF l_att_val_mean =  l_att_code THEN
                   l_attr_to_val_mean  := l_attrib_to_val;
                END IF;

                IF l_attrib_to_val  = l_att_code THEN
                   l_attr_val_meaning := l_att_val_mean;
                END IF;
             END LOOP;
            CLOSE lc_attr_cursor;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               debug('Attribute Meaning for Between '|| l_attr_val_meaning ||'AND' ||l_attr_to_val_mean);
            END IF;

            l_concat_attr_mean := l_attr_val_meaning || ' and ' || l_attr_to_val_mean;


        ELSE

            OPEN lc_attr_cursor FOR l_lov_string USING x_attr_id_tbl(i),in_list(l_attr_in_string);
            LOOP
                FETCH lc_attr_cursor INTO l_attr_val_meaning;
                          EXIT WHEN lc_attr_cursor%NOTFOUND;

                IF l_concat_attr_mean IS NOT NULL THEN
                       l_concat_attr_mean := l_concat_attr_mean ||','|| l_attr_val_meaning;
                ELSE
                   l_concat_attr_mean := l_attr_val_meaning;
                END IF;
               IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  debug('line Attribute Meaning '||l_attr_val_meaning);
               END IF;
            END LOOP;
            CLOSE lc_attr_cursor;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               debug('Attribute Meaning '||l_concat_attr_mean);
            END IF;


      END IF;

       IF l_concat_attr_mean IS NULL THEN
          l_concat_attr_mean := fnd_message.get_string('PV', 'PV_UNKNOWN');
       END IF;

            x_evaluation_criteria_tbl.extend;
            x_evaluation_criteria_tbl(l_count) :=  l_opr_meaning || ' '|| l_concat_attr_mean;


            l_concat_attr_mean := null;
            l_lov_string       := null;

         ELSE

           x_evaluation_criteria_tbl.extend;

            IF l_operator_tbl(i) = 'BETWEEN' THEN
               x_evaluation_criteria_tbl(l_count) :=  l_opr_meaning || ' '||
                        replace(l_attribute_value_tbl(i),'''') || ' and ' || l_attr_to_val(i);
            ELSE
               x_evaluation_criteria_tbl(l_count) := l_opr_meaning ||' '|| replace(l_attribute_value_tbl(i),'''');
               IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  debug(' x_evaluation_criteria_tbl(l_count) '|| x_evaluation_criteria_tbl(l_count));
               END IF;
            END IF;

         END IF;

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               Debug('Before calling check_match  partner_id '||p_partner_id||
	       ' l_attr_val_tbl(i) ' ||l_attr_val_tbl(i) ||'p_operator '|| l_operator_tbl(i),FND_LOG.LEVEL_PROCEDURE );
           END IF;

        l_result := pv_check_match_pub.Check_Match
   (
          p_attribute_id        => x_attr_id_tbl(i),
          p_entity              => 'PARTNER',
          p_entity_id           => p_partner_id,
          p_rule_attr_value     => l_attr_val_tbl(i),
          p_rule_to_attr_value  => x_delimiter||l_attr_to_val(i)||x_delimiter,
          p_operator            => l_operator_tbl(i),
          p_input_filter        => l_input_filter,
          p_delimiter           => '+++',
          p_rule_currency_code  => l_currency_tbl(i),
          x_entity_attr_value   => l_entity_attr_value
        );

        x_attr_evaluation_result_tbl.extend;

        IF (l_result) THEN

           x_attr_evaluation_result_tbl(x_attr_evaluation_result_tbl.count) := 'PASS';

        ELSE

      x_attr_evaluation_result_tbl(x_attr_evaluation_result_tbl.count) := 'FAIL';
      l_rule_pass_flag := FALSE;
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               Debug('Failed evaluating ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',FND_LOG.LEVEL_PROCEDURE);
           END IF;
           x_rule_pass_flag := 'FAIL';
        END IF;


         x_partner_attr_value_tbl.extend;
          x_partner_attr_value_tbl(x_partner_attr_value_tbl.count) := l_entity_attr_value(x_attr_id_tbl(i)).attribute_value;

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            --debug('Partner Attribute Value %%%%%%%% :'||l_entity_attr_value(x_attr_id_tbl(i)).attribute_value,FND_LOG.LEVEL_PROCEDURE);
	    l_temp_variable := l_entity_attr_value(x_attr_id_tbl(i)).attribute_value;
	      while (l_temp_variable is not null) loop
		debug('Partner Attribute Value %%%%%%%% :' ||substr( l_temp_variable, 1, 1800 ) ,FND_LOG.LEVEL_PROCEDURE);
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;

            debug('Return Type %%%%%%%%%%%%%%%%%%%% :'||l_entity_attr_value(x_attr_id_tbl(i)).return_type,FND_LOG.LEVEL_PROCEDURE);
         END IF;

      END LOOP;


  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      debug('End of partner_eval_outcome',FND_LOG.LEVEL_PROCEDURE);
  END IF;




   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            debug( fnd_msg_pub.get(p_encoded => 'F'),FND_LOG.LEVEL_ERROR );
         END IF;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;

         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            debug( fnd_msg_pub.get(p_encoded => 'F'),FND_LOG.LEVEL_UNEXPECTED );
         END IF;

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

         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            debug( fnd_msg_pub.get(p_encoded => 'F'),FND_LOG.LEVEL_UNEXPECTED );
         END IF;

	FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );


END;
--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    quick_partner_eval_outcome                                              |
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

PROCEDURE quick_partner_eval_outcome(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2       := FND_API.g_false,
   p_commit                     IN  VARCHAR2       := FND_API.g_false,
   p_validation_level           IN  NUMBER         := FND_API.g_valid_level_full,
   p_partner_id                 IN  NUMBER,
   p_rule_id_tbl                IN  JTF_NUMBER_TABLE,
   x_rule_pass_flag             OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS
        x_attr_id_tbl                JTF_NUMBER_TABLE;
        x_attr_evaluation_result_tbl JTF_VARCHAR2_TABLE_100;
        x_partner_attr_value_tbl     JTF_VARCHAR2_TABLE_4000;
        x_evaluation_criteria_tbl    JTF_VARCHAR2_TABLE_4000;
        x_delimiter                  VARCHAR2(10);

        TYPE c_attr_mean IS REF CURSOR;

   l_rule_id_tbl      JTF_NUMBER_TABLE    := JTF_NUMBER_TABLE();
        l_attr_val_tbl      JTF_VARCHAR2_TABLE_1000   := JTF_VARCHAR2_TABLE_1000();
   l_attr_to_val      JTF_VARCHAR2_TABLE_1000   := JTF_VARCHAR2_TABLE_1000();
   l_operator_tbl     JTF_VARCHAR2_TABLE_1000   := JTF_VARCHAR2_TABLE_1000();
        l_currency_tbl      JTF_VARCHAR2_TABLE_100    := JTF_VARCHAR2_TABLE_100();
   l_criterion_id_tbl    JTF_NUMBER_TABLE    := JTF_NUMBER_TABLE();
   l_cri_condition_tbl      JTF_VARCHAR2_TABLE_100    := JTF_VARCHAR2_TABLE_100();
   l_attribute_value_tbl    JTF_VARCHAR2_TABLE_4000   := JTF_VARCHAR2_TABLE_4000();


   l_input_filter    pv_check_match_pub.t_input_filter;
   l_entity_attr_value   pv_check_match_pub.t_entity_attr_value;

   lc_attr_cursor    c_attr_mean;
   l_lov_string      VARCHAR2(32000) :=  null;

   l_rule_id      NUMBER;
   l_attribute_id    NUMBER;
   l_currency      VARCHAR2(30);
   l_operator     VARCHAR2(30);
   l_cri_id		NUMBER;
   l_att_val      VARCHAR2(4000);
   l_att_to_val      VARCHAR2(1000);
   l_att_val_mean    VARCHAR2(1000);
   l_opr_meaning           VARCHAR2(1000);
   l_attribute_name        VARCHAR2(1000);
   l_attr_in_string        VARCHAR2(4000);

   l_prev_rule_id    NUMBER := NULL;
   l_prev_attr_id    NUMBER := NULL;
   l_prev_criteria_id   NUMBER := NULL;
   l_prev_currency      VARCHAR2(1000);
   l_prev_operator      VARCHAR2(1000);
   l_prev_att_val    VARCHAR2(4000) := NULL;
   l_prev_att_to_val VARCHAR2(1000);
   l_prev_att_name        VARCHAR2(1000);

   l_attr_value      VARCHAR2(4000) := NULL;
   l_attr_val_meaning      VARCHAR2(1000) := NULL;
   l_attr_to_val_mean      VARCHAR2(1000) := NULL;
   l_attrib_to_val         VARCHAR2(1000) := NULL;
   l_att_code          VARCHAR2(1000) := NULL;
   l_concat_attr_mean   VARCHAR2(1000) := NULL;


   l_attribute_value       VARCHAR2(4000) := NULL;

   l_rule_pass_flag  BOOLEAN := FALSE;
   l_total_rows      NUMBER;
   l_criteria_count  NUMBER := 0;
        l_non_cri_count    NUMBER := 0;
   l_last_cri_cnt    NUMBER := 0;
   l_total_criteria  NUMBER := 0;
l_temp_variable varchar2(4000);
        j         NUMBER;
   l_cnt       NUMBER := 0;
   l_count        NUMBER := 0;


        l_result     BOOLEAN;


   -- =============================================================================================
   -- This query evaluates the attribute Id for the given Rule ID Set
   -- Rules are hierarchical.
   -- e.g.
   -- Rule1(root) --> Rule2(Level 1 Child) --> Rule3(Level 2 Child)
   -- -----------------------------------------------------------------------
   -- Rule1 (attribute1 > 30, attribute2 > 40)
   -- Rule2 (attribute3 > 50, attribute4 > 60)
   -- Rule3 (attribute1 > 45, attribute4 > 50)

   -- Combined Attribute List (which will be used as the basis of evaluation:
   -- attribute1 > 45 (R3 overwrites R1)
   -- attribute2 > 40
   -- attribute3 > 50
   -- attribute4 > 60

   -- Query Description :


   -- Inline View Z :

        -- "SELECT a.process_rule_id, b.attribute_id, x.rank, x.process_rule_id rule_id
   --    FROM  pv_process_rules_vl a, pv_enty_select_criteria b,
        --     (SELECT rownum rank, column_value process_rule_id
        --      FROM  (SELECT column_value FROM   TABLE (CAST(p_rule_id_tbl AS JTF_NUMBER_TABLE))) ) x
        --      WHERE  a.process_rule_id = x.process_rule_id
        --      AND    a.process_rule_id = b.process_rule_id "

        -- " SELECT column_value FROM   TABLE (CAST(p_rule_id_tbl AS JTF_NUMBER_TABLE "
   -- In the above select statement CAST ensures the order of Rule ID set from the query
   -- remains the same as that of INPUT RULE ID TABLE.

        --
   -- Since rules are hierarchical rank is assigned to them starting with the Parent (Parent
   -- Rule ID gets the least priority )

   -- Rownum evaluates the rank of the attribute ID based on how many times it is repeated in the rule.
   -- Result of the above inline view Z would be
   -- -----------------------------------------------------------------------------------------------
   -- Rule ID        Attribute ID      Rank
   -- ================================================================================================
   --         1          attribute1     1
   --         1                     attribute2      1
   --         2          attribute3     2
   --    2         attribute4     2
   --         3                     attribute1      3
   --         3          attribute4     3
   -- ------------------------------------------------------------------------------------------------
   -- When we take the MAX(rank)  grouped by attribute ID
   -- for the above set the combined attribute list is achieved

   -- Final combined attribute list from INLINE VIEW XY would be
   -- -------------------------------------------------------------------------------------------------
   --    Rule ID        Attribute ID      Rank
   -- =================================================================================================
   --         1                     attribute2      1
   --         2          attribute3     2
   --         3                     attribute1      3
   --         3          attribute4     3
   -- --------------------------------------------------------------------------------------------------

   -- ====================================================================================================


   cursor lc_get_rule_details
   is
   SELECT  xy.attribute_id Attribute_ID,
           xy.rule_id Rule_ID,
                rule.currency_code Currency_Code,
                criterion.operator Operator,
                criterion.selection_criteria_id Criteria_ID,
                AttVal.attribute_value Attr_Value,
                AttVal.attribute_to_value Attr_To_Value
        FROM    pv_process_rules_vl Rule,
           pv_enty_select_criteria Criterion,
                pv_selected_attr_values AttVal,
          ( SELECT attribute_id,TO_NUMBER(LTRIM(substr(rule_rank, 1, 10), 0)) rank,TO_NUMBER(LTRIM(substr(rule_rank, 11, LENGTH(rule_rank)), 0)) rule_id
            FROM (
                 SELECT z.attribute_id, MAX(LPAD(z.rank, 10, 0) || LPAD(z.process_rule_id, 100, 0)) rule_rank
                 FROM (
                      SELECT a.process_rule_id, b.attribute_id, x.rank, x.process_rule_id rule_id
                      FROM  pv_process_rules_vl a,
                       pv_enty_select_criteria b,
                      (SELECT rownum rank, column_value process_rule_id
                       FROM  (SELECT column_value
                         FROM   TABLE (CAST(p_rule_id_tbl AS JTF_NUMBER_TABLE))) ) x
                      WHERE  a.process_rule_id = x.process_rule_id
                      AND    a.process_rule_id = b.process_rule_id ) z
                      group by z.attribute_id
            )) xy
        WHERE  Rule.process_rule_id            = Criterion.process_rule_id
        AND    Criterion.selection_criteria_id = Attval.selection_criteria_id
        AND    Criterion.selection_type_code   = 'PARTNER_SELECTION'
        AND    Rule.process_rule_id        = xy.rule_id
   AND    criterion.attribute_id          = xy.attribute_id
   AND    criterion.process_rule_id       = xy.rule_id
        order  by xy.rank;

  CURSOR  lc_attr_mean_cursor(pc_attribute_id NUMBER) IS
   SELECT  lov_string
   FROM    pv_entity_attrs
   WHERE   lov_string IS NOT NULL
   AND     entity = 'PARTNER'
   AND     enabled_flag = 'Y'
   AND     attribute_id = pc_attribute_id;


   l_api_name            CONSTANT VARCHAR2(30) := 'quick_partner_eval_outcome';
   l_api_version_number  CONSTANT NUMBER       := 1.0;



begin




  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      Debug(l_api_name,FND_LOG.LEVEL_PROCEDURE);
   END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;
   x_delimiter     := '+++';


   IF p_rule_id_tbl.count  = 0 THEN

         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_DEBUG_MESSAGE',
                     p_token1       => 'TEXT',
                     p_token1_value => 'Rule ID is not passed in',
                     p_token2       => NULL,
                     p_token2_value => NULL);

         RAISE FND_API.G_EXC_ERROR;

   END IF;


   x_attr_id_tbl                := JTF_NUMBER_TABLE();
   x_attr_evaluation_result_tbl := JTF_VARCHAR2_TABLE_100();
   x_partner_attr_value_tbl     := JTF_VARCHAR2_TABLE_4000();
   x_evaluation_criteria_tbl    := JTF_VARCHAR2_TABLE_4000();

   open lc_get_rule_details;
   loop

      fetch lc_get_rule_details into l_attribute_id, l_rule_id, l_currency,l_operator,l_cri_id, l_att_val, l_att_to_val;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          debug(' Rule ID '||l_rule_id ||' Attribute ID '||l_attribute_id||' Criteria ID '||l_cri_id);
	  --||' Attr Value '||l_att_val);
	  l_temp_variable := l_att_val;
	      while (l_temp_variable is not null) loop
		debug('attr Val ' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;

            END IF;


      l_total_rows := lc_get_rule_details%ROWCOUNT;


      IF lc_get_rule_details%NOTFOUND AND l_total_rows = 0 THEN

       x_rule_pass_flag := 'PASS';
       return;

      END IF;



      -- ===========================================================================================
      -- If a rule has same attributes with two criteria, they would be considered as AND Condition
      -- In that case Attribute ID tbl will have same entry twice. If not then it is considered to be
      -- OR condition.
      -- Attr Value for OR Condition would be like US,UK ( Concatnated Value of all the attribute value
      -- for that Rule ID and Attribute ID combination
      -- =============================================================================================


      -- ==============================================================================================
      -- Evaluating for OR Condition
      -- ==============================================================================================

     IF l_cri_id is not null THEN

         IF  (l_prev_rule_id = l_rule_id  AND l_prev_attr_id = l_attribute_id
         AND l_prev_criteria_id  = l_cri_id )      THEN


      IF l_attr_value is null THEN

             l_attr_value  := l_prev_att_val;

        l_attribute_value  := ''''||l_prev_att_val||'''';

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           --debug('l_attribute_value '||l_attribute_value);
	    l_temp_variable := l_attribute_value;
	      while (l_temp_variable is not null) loop
		debug('l_attribute_value ' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;
             END IF;

     END IF;

          l_criteria_count   := l_criteria_count + 1;



          l_attr_value       := l_attr_value || x_delimiter ||l_att_val;

     l_attribute_value  := l_attribute_value || ',' || '''' || l_att_val || '''';



          IF lc_get_rule_details%NOTFOUND THEN

             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           debug('At the last record ................');
             END IF;


        l_criteria_count   := l_criteria_count - 1;

        -- =================================================================================================
        -- Since the loop is not exited even after the last record the values of previous and current record
        -- will be the same hence attr_value will have the value appended twice for the last record
             -- Hence removing it
        -- ==================================================================================================


        l_attr_value := substr(l_attr_value, 1, length(l_attr_value)-length(l_att_val)-length(x_delimiter));
        l_attribute_value  := substr(l_attribute_value, 1, length(l_attribute_value)-length(l_att_val)-3);

             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           --debug('l_attribute_value for last record '|| l_attribute_value);
	   l_temp_variable := l_attribute_value;
	      while (l_temp_variable is not null) loop
		debug('l_attribute_value for the last record' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;

        END IF;

        -- ========================================================================================
        -- Here the values will be inserted to the PL/SQL table only for the last record
        -- and also if it is an OR condition
        -- ========================================================================================

        IF l_criteria_count >= 1 THEN

      l_cnt := l_cnt + 1;

      l_rule_id_tbl.extend;
      x_attr_id_tbl.extend;
      l_currency_tbl.extend;
      l_operator_tbl.extend;
      l_criterion_id_tbl.extend;
      l_attr_val_tbl.extend;
      l_attr_to_val.extend;
      l_cri_condition_tbl.extend;
      l_attribute_value_tbl.extend;

      l_rule_id_tbl(l_cnt)      := l_rule_id;
      x_attr_id_tbl(l_cnt)     := l_attribute_id;
      l_currency_tbl(l_cnt)       := l_currency;
      l_operator_tbl(l_cnt)       := l_operator;
      l_criterion_id_tbl(l_cnt)   := l_cri_id;
      l_attr_val_tbl(l_cnt)       := x_delimiter||l_attr_value||x_delimiter;
      l_attribute_value_tbl(l_cnt)     := l_attribute_value;

      IF l_att_to_val is not null THEN
         l_attr_to_val(l_cnt)  := l_att_to_val;
      ELSE
         l_attr_to_val(l_cnt)  := NULL;
      END IF;

            l_cri_condition_tbl(l_cnt)   := 'OR';

             END IF;

           END IF;

      ELSE


       IF  l_prev_rule_id is not null   AND  l_prev_attr_id is not null
       AND l_prev_criteria_id is not null  THEN

       -- ============================================================================
       -- Making sure that first record does not get inserted always with criteria
       -- condition check.For the first record all the previous values will be null.
       -- ============================================================================


      l_cnt := l_cnt + 1;

      l_rule_id_tbl.extend;
      x_attr_id_tbl.extend;
      l_currency_tbl.extend;
      l_operator_tbl.extend;
      l_criterion_id_tbl.extend;
      l_attr_val_tbl.extend;
      l_attr_to_val.extend;
      l_cri_condition_tbl.extend;
      l_attribute_value_tbl.extend;


      l_total_criteria := l_criteria_count;
      l_criteria_count := 0;

      l_rule_id_tbl(l_cnt)      := l_prev_rule_id;
      x_attr_id_tbl(l_cnt)      := l_prev_attr_id;
      l_currency_tbl(l_cnt)     := l_prev_currency;
      l_operator_tbl(l_cnt)     := l_prev_operator;
      l_criterion_id_tbl(l_cnt)    := l_prev_criteria_id;

      IF l_total_criteria > 0 THEN

         l_attr_val_tbl(l_cnt)     := x_delimiter|| l_attr_value ||x_delimiter;
         l_attribute_value_tbl(l_cnt):= l_attribute_value;

         IF l_prev_att_to_val is not null THEN
            l_attr_to_val(l_cnt)  := l_prev_att_to_val;
         ELSE
            l_attr_to_val(l_cnt)  := NULL;
              END IF;

         l_cri_condition_tbl(l_cnt)  := 'OR';



           ELSE

      -- ===================================================================================
      -- Criteria Condition Will be '0' for the AND condition which means that the Criteria ID
      -- has changed.
      -- ===================================================================================



         l_attr_value := l_att_val;


         IF l_prev_att_val IS NOT NULL THEN
            l_attr_val_tbl(l_cnt)    := x_delimiter||l_prev_att_val||x_delimiter;
            l_attribute_value_tbl(l_cnt) := ''''||l_prev_att_val||'''';
         ELSE
            l_attr_val_tbl(l_cnt)   := NULL;
            l_attribute_value_tbl(l_cnt) := NULL;
         END IF;

         l_cri_condition_tbl(l_cnt) := 'AND';

         IF l_prev_att_to_val is not null THEN
            l_attr_to_val(l_cnt)  := l_prev_att_to_val;
         ELSE
            l_attr_to_val(l_cnt)  := NULL;
         END IF;



           END IF;

       ELSE
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           debug('At first record ');
         END IF;

           l_non_cri_count := l_non_cri_count + 1;

       END IF;

     l_total_criteria := 0;
     l_attr_value    := null;
     l_attribute_value := null;

     END IF;

   END IF;

     -- ========================================================================================
     -- Here the values will be inserted to the PL/SQL table only for the last record
     -- and also if it is an AND condition
     -- ========================================================================================

     IF (lc_get_rule_details%NOTFOUND
     AND l_total_rows > 0 AND l_criteria_count = 0) THEN


      l_last_cri_cnt := l_criteria_count ;

      l_attr_value := l_att_val;


      l_rule_id_tbl.extend;
      x_attr_id_tbl.extend;
      l_currency_tbl.extend;
      l_operator_tbl.extend;
      l_criterion_id_tbl.extend;
      l_attr_val_tbl.extend;
      l_attr_to_val.extend;
      l_cri_condition_tbl.extend;
      l_attribute_value_tbl.extend;


        l_cnt := l_cnt+1;

         l_rule_id_tbl(l_cnt)    := l_rule_id;
         x_attr_id_tbl(l_cnt)    := l_attribute_id;
         l_currency_tbl(l_cnt)      := l_currency;
         l_operator_tbl(l_cnt)      := l_operator;
         l_criterion_id_tbl(l_cnt)  := l_cri_id;

         IF l_attr_value IS NOT NULL THEN
            l_attr_val_tbl(l_cnt)    := x_delimiter|| l_attr_value ||x_delimiter;
            l_attribute_value_tbl(l_cnt)  := ''''||l_attr_value||'''';
         ELSE
            l_attr_val_tbl(l_cnt)    := NULL;
         END IF;

         IF l_att_to_val is not null THEN
            l_attr_to_val(l_cnt)  :=  l_att_to_val;
         ELSE
            l_attr_to_val(l_cnt)  := NULL;
         END IF;

         l_cri_condition_tbl(l_cnt)   := 'AND';


     END IF;

     l_prev_attr_id      := l_attribute_id;
     l_prev_rule_id      := l_rule_id;
     l_prev_criteria_id  := l_cri_id;
     l_prev_currency     := l_currency;
     l_prev_operator     := l_operator;
     l_prev_att_to_val   := l_att_to_val;
     l_prev_att_val      := l_att_val;


     exit when lc_get_rule_details%notfound;


  END LOOP;


  close lc_get_rule_details;

 l_rule_pass_flag := TRUE;
  x_rule_pass_flag := 'PASS';

  IF l_rule_id_tbl.count > 0 THEN

     for i in 1 .. l_rule_id_tbl.count
     loop
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             debug(' Rule ID ####################### '|| l_rule_id_tbl(i));
             debug(' Attribute ID ################## '|| x_attr_id_tbl(i));
             debug(' Criteria ID ################### '|| l_criterion_id_tbl(i));
             debug(' Currency ###################### '|| l_currency_tbl(i));
             debug(' Operator ###################### '|| l_operator_tbl(i));
             debug(' Attr to Val ################### '|| l_attr_to_val(i));
             debug(' Criteria Condition ############ '|| l_cri_condition_tbl(i));
             --debug(' Attr Value #################### '|| l_attr_val_tbl(i));

	     l_temp_variable := l_attr_val_tbl(i);
	      while (l_temp_variable is not null) loop
		debug('Attr Value ###############' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;

	     --debug(' Attribute Value ############### '|| l_attribute_value_tbl(i));

	     l_temp_variable := l_attribute_value_tbl(i);
	      while (l_temp_variable is not null) loop
		debug('Attribute Value ###############' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;
         END IF;

            l_count := l_count + 1;

      -- =======================================================================
      -- Retrieve meaning for operator
      -- =======================================================================

       select meaning
       into   l_opr_meaning
       from   pv_lookups
       where  lookup_type = 'PV_NUM_DATE_OPERATOR'
       and    lookup_code = l_operator_tbl(i);

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          debug(' Operator Meaning  '|| l_opr_meaning );
       END IF;

     -- ==========================================================================
     -- Retrieve the LOV String for the attribute to get the meaning of Attribute
     -- Value
     -- ==========================================================================

       FOR v_sql_cursor IN lc_attr_mean_cursor(x_attr_id_tbl(i)) LOOP
         l_lov_string := v_sql_cursor.lov_string;
       END LOOP;

--     debug(' LOV String from pv_entity_attrs  '|| l_lov_string );


     -- ==========================================================================
     -- LOV String is appended with the evaluated attribute value to get meaning
     -- only for selected attribute values
     -- ==========================================================================
       IF (l_lov_string IS NULL OR LENGTH(l_lov_string) = 0) THEN

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             Debug ('Value could be NUMBER, DATE OR CURRENCY or STRING would be free text');
          END IF;

       END IF;


      IF (l_lov_string IS NOT NULL OR LENGTH(l_lov_string) <> 0) THEN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          debug(' in the If Condition ');
        END IF;

          -- ==========================================================================
          -- Retrieved LOV_String has an '?' replacing that with ':X' since SQL cannot
          -- recoganize '?' as an input
          -- ==========================================================================

          l_lov_string := replace(l_lov_string,'?',':X');


          IF l_operator_tbl(i) = 'BETWEEN' THEN

             l_lov_string   := 'SELECT decode(t.code, :1, t.meaning, t.code) Attr_Value ,'||
                               'decode(t.code, :2, t.meaning, t.code) Attr_to_Value, t.code ' ||
                               'FROM ('|| l_lov_string ||' )  t WHERE t.code in ( :4,:5)';



           ELSE

               l_lov_string   := 'SELECT t.meaning FROM (' || l_lov_string ||' )  t WHERE t.code IN '||
                                   '( SELECT * FROM THE ( SELECT CAST( :Y as JTF_VARCHAR2_TABLE_32767 ) from dual ))';

           END IF;

           l_attr_in_string := replace(l_attribute_value_tbl(i),'''','');

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             --debug(' Attribute in string '||l_attr_in_string);
	     l_temp_variable := l_attr_in_string;
	      while (l_temp_variable is not null) loop
		debug('Attribute in String ' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;
          END IF;

          IF l_operator_tbl(i) = 'BETWEEN' THEN
                -- --------------------------------------------------------------------------
          -- The bind variables in l_lov_string are as follows:
          -- 1 = l_attribute_value_tbl(i)
          -- 2 = l_attr_to_val(i)
          -- 3 = :attribute_id in l_lov_string
          -- 4 = l_attribute_value_tbl(i)
          -- 5 = l_attr_to_val(i)
          -- --------------------------------------------------------------------------
            OPEN lc_attr_cursor FOR l_lov_string USING l_attr_in_string,l_attr_to_val(i),x_attr_id_tbl(i),l_attr_in_string, l_attr_to_val(i);
            LOOP
                FETCH lc_attr_cursor INTO l_att_val_mean, l_attrib_to_val, l_att_code;
                EXIT WHEN lc_attr_cursor%NOTFOUND;


                IF l_att_val_mean =  l_att_code THEN
                   l_attr_to_val_mean  := l_attrib_to_val;
                END IF;

                IF l_attrib_to_val  = l_att_code THEN
                   l_attr_val_meaning := l_att_val_mean;
                END IF;
             END LOOP;
            CLOSE lc_attr_cursor;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               debug('Attribute Meaning for Between '|| l_attr_val_meaning ||'AND' ||l_attr_to_val_mean);
            END IF;

            l_concat_attr_mean := l_attr_val_meaning || ' and ' || l_attr_to_val_mean;


        ELSE
                  -- --------------------------------------------------------------------------
          -- The bind variables in l_lov_string are as follows:
          -- 1 = :attribute_id in l_lov_string
          -- 2 = l_attribute_value_tbl(i)
          -- --------------------------------------------------------------------------


            OPEN lc_attr_cursor FOR l_lov_string USING x_attr_id_tbl(i),in_list(l_attr_in_string);
            LOOP
                FETCH lc_attr_cursor INTO l_attr_val_meaning;
                          EXIT WHEN lc_attr_cursor%NOTFOUND;

                IF l_concat_attr_mean IS NOT NULL THEN
                       l_concat_attr_mean := l_concat_attr_mean ||','|| l_attr_val_meaning;
                ELSE
                   l_concat_attr_mean := l_attr_val_meaning;
                END IF;
               IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  debug('line Attribute Meaning '||l_attr_val_meaning);
               END IF;
            END LOOP;
            CLOSE lc_attr_cursor;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               debug('Attribute Meaning '||l_concat_attr_mean);
            END IF;


      END IF;
       /* ------------------------------------------------------------------
       IF l_concat_attr_mean IS NULL THEN
          l_concat_attr_mean := fnd_message.get_string('PV', 'PV_UNKNOWN');
       END IF;
                  * -------------------------------------------------------------------- */

    x_evaluation_criteria_tbl.extend;
       x_evaluation_criteria_tbl(l_count) :=  l_opr_meaning || ' '|| l_concat_attr_mean;


            l_concat_attr_mean := null;
       l_lov_string       := null;

         ELSE

       x_evaluation_criteria_tbl.extend;

            IF l_operator_tbl(i) = 'BETWEEN' THEN
               x_evaluation_criteria_tbl(l_count) :=  l_opr_meaning || ' '||
                        replace(l_attribute_value_tbl(i),'''') || ' and ' || l_attr_to_val(i);
           ELSE
              x_evaluation_criteria_tbl(l_count) := l_opr_meaning ||' '|| replace(l_attribute_value_tbl(i),'''');

            END IF;

         END IF;

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            debug('Start of pv_check_match_pub.Check_Match ',FND_LOG.LEVEL_PROCEDURE);
            debug('p_entity_id '||p_partner_id);
	    --||' p_rule_attr_value '||l_attr_val_tbl(i)
	    l_temp_variable := l_attr_val_tbl(i);
	      while (l_temp_variable is not null) loop
		debug('p_rule_attr_value  ' ||substr( l_temp_variable, 1, 1800 ));
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;

	    debug(' p_attribute_id '||x_attr_id_tbl(i)||' p_rule_to_attr_value '||l_attr_to_val(i)
	  					  ||' p_operator '||l_operator_tbl(i),FND_LOG.LEVEL_PROCEDURE );


         END IF;

        l_result := pv_check_match_pub.Check_Match
   (
          p_attribute_id        => x_attr_id_tbl(i),
          p_entity              => 'PARTNER',
          p_entity_id           => p_partner_id,
          p_rule_attr_value     => l_attr_val_tbl(i),
          p_rule_to_attr_value  => x_delimiter||l_attr_to_val(i)||x_delimiter,
          p_operator            => l_operator_tbl(i),
          p_input_filter        => l_input_filter,
          p_delimiter           => '+++',
          p_rule_currency_code  => l_currency_tbl(i),
          x_entity_attr_value   => l_entity_attr_value
        );

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            --debug('Partner Attribute Value %%%%%%%% :'||l_entity_attr_value(x_attr_id_tbl(i)).attribute_value,FND_LOG.LEVEL_PROCEDURE);
	    l_temp_variable := l_entity_attr_value(x_attr_id_tbl(i)).attribute_value;
	      while (l_temp_variable is not null) loop
		debug('Partner Attribute Value %%%%%%%% : ' ||substr( l_temp_variable, 1, 1800 ),FND_LOG.LEVEL_PROCEDURE);
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;
         END IF;

	x_attr_evaluation_result_tbl.extend;

        IF (l_result) THEN

           x_attr_evaluation_result_tbl(x_attr_evaluation_result_tbl.count) := 'PASS';

        ELSE

      x_attr_evaluation_result_tbl(x_attr_evaluation_result_tbl.count) := 'FAIL';
      l_rule_pass_flag := FALSE;

           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              Debug('Failed evaluating ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
           END IF;

      x_rule_pass_flag := 'FAIL';

           -- -------------------------------------------------------------------------------
           -- Exit the code as soon as there is a mismatch
           -- -------------------------------------------------------------------------------
           RETURN;
        END IF;


   x_partner_attr_value_tbl.extend;
        x_partner_attr_value_tbl(x_partner_attr_value_tbl.count)
      := l_entity_attr_value(x_attr_id_tbl(i)).attribute_value;

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            --debug('Partner Attribute Value %%%%%%%% :'||l_entity_attr_value(x_attr_id_tbl(i)).attribute_value,FND_LOG.LEVEL_PROCEDURE);
	    l_temp_variable := l_entity_attr_value(x_attr_id_tbl(i)).attribute_value;
	      while (l_temp_variable is not null) loop
		debug('Partner Attribute Value %%%%%%%% : ' ||substr( l_temp_variable, 1, 1800 ) ,FND_LOG.LEVEL_PROCEDURE);
		l_temp_variable := substr( l_temp_variable, 1801 );
	      end loop;
            debug('Return Type %%%%%%%%%%%%%%%%%%%% :'||l_entity_attr_value(x_attr_id_tbl(i)).return_type,FND_LOG.LEVEL_PROCEDURE);


         END IF;

      END LOOP;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      debug('End of quick_partner_eval_outcome',FND_LOG.LEVEL_PROCEDURE);
    END IF;

  END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            debug( fnd_msg_pub.get(p_encoded => 'F'),FND_LOG.LEVEL_ERROR );
         END IF;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;

         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            debug( fnd_msg_pub.get(p_encoded => 'F'),FND_LOG.LEVEL_UNEXPECTED );
         END IF;

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

         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            debug( fnd_msg_pub.get(p_encoded => 'F'),FND_LOG.LEVEL_UNEXPECTED );
         END IF;

	FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );



END;



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
   p_msg_string    IN VARCHAR2,
   p_msg_level     IN NUMBER := FND_LOG.LEVEL_STATEMENT
)
IS
   l_module_source VARCHAR2(100) := 'pv.plsql.program.rule.evaluation';
BEGIN

  IF (p_msg_level >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.string(p_msg_level, l_module_source,p_msg_string);
  END IF;
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

--=============================================================================+
--|  private function                                                          |
--|                                                                            |
--|    in_list                                                                 |
--|                                                                            |
--|  Parameters                                                                |
--|  IN  p_string                                                              |
--|  OUT                                                                       |
--|    jtf_varchar2_table_32767                                                |
--|                                                                            |
--| NOTES:                                                                     |
--|    converts string to pl/sql table                                         |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION in_list
      ( p_string IN VARCHAR2 )
RETURN jtf_varchar2_table_32767
 as
     l_data             jtf_varchar2_table_32767 := jtf_varchar2_table_32767();
     l_string           long default p_string || ',';
     l_n                number;
 BEGIN

   LOOP
     EXIT WHEN l_string IS NULL;
     l_data.EXTEND;
     l_n := INSTR( l_string, ',' );
     l_data( l_data.count ) := SUBSTR( l_string, 1, l_n-1 );
     l_string := SUBSTR( l_string, l_n+1 );
   END LOOP;
   RETURN l_data;
 END;
-- ==============================End of in_lisr=============================


END PV_RULE_EVALUATION_PUB;

/
