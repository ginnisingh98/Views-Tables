--------------------------------------------------------
--  DDL for Package Body CSD_RULES_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RULES_ENGINE_PVT" as
/* $Header: csdvrulb.pls 120.7.12010000.6 2008/11/11 01:46:12 swai ship $ */
-- Start of Comments
-- Package name     : CSD_RULES_ENGINE_PVT
-- Purpose          : Jan-14-2008    rfieldma created
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSD_RULES_ENGINE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvrulb.pls';


/*--------------------------------------------------------------------*/
/* procedure name: PROCESS_RULE_MATCHING                              */
/* description : procedure used to Match Rules with input data        */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Bulletins                               */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_rule_matching_rec CSD_RULE_MATCHING_REC_TYPE                  */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE PROCESS_RULE_MATCHING(
    p_api_version_number           IN            NUMBER,
    p_init_msg_list                IN            VARCHAR2   := FND_API.G_FALSE,
    p_commit                       IN            VARCHAR2   := FND_API.G_FALSE,
    p_validation_level             IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    px_rule_matching_rec           IN OUT NOCOPY CSD_RULE_MATCHING_REC_TYPE,
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2
)
IS
   ---- local constants ----
   c_TEMP_CHAR               CONSTANT VARCHAR(1)   := 'B';  -- used to pass as attribute type/code for bulletin
   c_API_NAME                CONSTANT VARCHAR2(30) := 'PROCESS_RULE_MATCHING';
   c_API_VERSION_NUMBER      CONSTANT NUMBER       := G_L_API_VERSION_NUMBER;

   ---- local variables ----
   l_rule_type               VARCHAR2(30)  := NULL;
   l_attr_type               VARCHAR2(30)  := NULL;
   l_attr_code               VARCHAR2(30)  := NULL;
   l_match_condition_ret_val VARCHAR2(1)   := FND_API.G_FALSE;
   l_is_match                VARCHAR2(1)   := FND_API.G_FALSE;
   l_tbl_last_ind            NUMBER        := 1;
   l_repair_line_id          NUMBER        := NULL;

   ---- cursors ----
   --* Cursor: cur_get_rules                                            *--
   --*         return rules  that match rule_type, attr_type, attr_code *--
   CURSOR cur_get_rules(p_rule_type VARCHAR2,
                               p_attr_type VARCHAR2,
                               p_attr_code VARCHAR2) IS
     SELECT attribute1, rule_id, value_type_code, attribute_category
     FROM   csd_rules_b
     where  rule_type_code = p_rule_type
     AND    NVL(entity_attribute_type, c_TEMP_CHAR)=NVL(p_attr_type, c_TEMP_CHAR)
     AND    NVL(entity_attribute_code, c_TEMP_CHAR)=NVL(p_attr_code, c_TEMP_CHAR)
     ORDER BY precedence
   ; --* end CURSOR cur_get_rules(..) *--

   l_rule_rec cur_get_rules%ROWTYPE;

   --* Cursor: cur_get_rule_conditions                *--
   --*         return all conditions for a given rule *--
   CURSOR cur_get_rule_conditions(p_rule_id NUMBER) IS
      SELECT attribute_category,
             attribute1,
             attribute2
      FROM   csd_rule_conditions_b
      WHERE  rule_id = p_rule_id
   ; --* end CURSOR cur_get_rule_conditions(..) *--

   l_rule_cond_rec cur_get_rule_conditions%ROWTYPE;

BEGIN
   --* Standard Start of API savepoint
   SAVEPOINT PROCESS_RULE_MATCHING_PVT;

   --* Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( c_API_VERSION_NUMBER,
                                        p_api_version_number,
                                        c_API_NAME,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --* logic starts here *--

   --* populate p_rule_input_rec
   l_repair_line_id := PX_RULE_MATCHING_REC.RULE_INPUT_REC.repair_line_id;
   IF ( l_repair_line_id IS NOT NULL) THEN
      POPULATE_RULE_INPUT_REC(PX_RULE_MATCHING_REC.RULE_INPUT_REC, l_repair_line_id);
   END IF; --* end IF ( l_repair_line_id IS NULL) *--


   /*   BEGIN: Algorithm:
   *   (1) Query for all ACTIVE rules that match:
   *          px_rule_matching_rec.ENTITY_ATTRIBUTE_CODE
   *          and px_rule_matching_rec.ENTITY_ATTRIBUTE_TYPE
   *          and px_rule_matching_rec.RULE_TYPE
   *          order by PRECEDENCE (ascending).
   *   (2) For each rule:
   *      (a) Query the list of the conditions for the rule
   *      (b) l_is_match := 'T' -- assume the condition is match unless proven otherwise.
   *      (c) for each condition,
   *              if (match_condition ( p_parameter_type => attribute_category,
   *                                    p_operator => attribute1,
   *                                    p_criterion => attribute2,
   *                                    p_rule_input_rec => px_rule_matching_rec.RULE_INPUT_REC
   *                                  ) = G_MISS_G_FALSE )then
   *                  l_is_match := 'F'
   *                  break;  --condition doesn't match, so rule doesn't match.
   *               end if;
   *          end for loop (looping through conditions for a single rule)
   *      (d) if (l_is_match = 'T') then
   *            if (px_csd_rule_matching_rec_type = 1) then
   *                  -- we only need to find the first match, so we can exit out of the loop.
   *                  px_csd_rule_matching_rec_type.RULE_RESULTS_TBL(1).rule_id = current rule
   *                  px_csd_rule_matching_rec_type.RULE_RESULTS_TBL(1).defaulting_value = current rule's attribute1
   *                  px_csd_rule_matching_rec_type.RULE_RESULTS_TBL(1).value_type = current rule's value_type_code
   *                  break;
   *             end if;
   *                    -- if not a match, keep looping through the rules for a match.
   *       end for loop  (looping through rules for given defaulting attribute)
   *    END: Algorithm*/
   l_rule_type := px_rule_matching_rec.RULE_TYPE;
   l_attr_type := px_rule_matching_rec.ENTITY_ATTRIBUTE_TYPE;
   l_attr_code := px_rule_matching_rec.ENTITY_ATTRIBUTE_CODE;
   FOR l_rule_rec  IN cur_get_rules(l_rule_type, l_attr_type, l_attr_code) LOOP
      --** debug starts!!
      --dbms_output.put_line('PROCESS_RULE_MATCHING - LP - get_rules - rule id = ' || l_rule_rec.rule_id || '<-----');
      --** debug ends!!
      --* default to false, assume not match unless otherwise returned by match_condition
      l_is_match := FND_API.G_FALSE;
      FOR l_rule_cond_rec IN cur_get_rule_conditions(l_rule_rec.rule_id) LOOP
         --** debug starts!!
         --dbms_output.put_line('> PROCESS_RULE_MATCHING - LP - get_rule_cond - attr_cat = ' || l_rule_cond_rec.attribute_category);
         --dbms_output.put_line('> PROCESS_RULE_MATCHING - LP - get_rule_cond - attr1 = ' || l_rule_cond_rec.attribute1);
         --dbms_output.put_line('> PROCESS_RULE_MATCHING - LP - get_rule_cond - attr2 = ' || l_rule_cond_rec.attribute2);
         --** debug ends!!

         l_is_match := match_condition(p_parameter_type => l_rule_cond_rec.attribute_category,
                                                      p_operator => l_rule_cond_rec.attribute1,
                                                      p_criterion => l_rule_cond_rec.attribute2,
                                                      p_rule_input_rec => px_rule_matching_rec.RULE_INPUT_REC
                                                     );


         IF (l_is_match = FND_API.G_FALSE )THEN
            --** debug starts!!
            --dbms_output.put_line('PROCESS_RULE_MATCHING -> l_match_condition_ret_val = FALSE - l_is_match = ' || l_is_match);
            --** debug ends!!

            EXIT; --* a condition didn't match, so no need to go on
         END IF; --* end  IF (l_match_condition_ret_val = FND_API.G_FALSE ) *--

      END LOOP; --* end FOR l_rule_cond_rec... *--

      IF (l_is_match = FND_API.G_TRUE) THEN
         -- we only need to find the first match, so we can exit out of the loop.
         l_tbl_last_ind := px_rule_matching_rec.RULE_RESULTS_TBL.COUNT;
         l_tbl_last_ind := l_tbl_last_ind+1;
         --** debug starts!!
         --dbms_output.put_line('PROCESS_RULE_MATCHING -> l_is_match is true, table_count ' || px_rule_matching_rec.RULE_RESULTS_TBL.COUNT);
         --dbms_output.put_line('PROCESS_RULE_MATCHING -> l_is_match is true, table_ind ' || l_tbl_last_ind);
         --** debug ends!!

         px_rule_matching_rec.RULE_RESULTS_TBL(l_tbl_last_ind).rule_id := l_rule_rec.rule_id;
         px_rule_matching_rec.RULE_RESULTS_TBL(l_tbl_last_ind).defaulting_value := l_rule_rec.attribute1;
         px_rule_matching_rec.RULE_RESULTS_TBL(l_tbl_last_ind).value_type := l_rule_rec.value_type_code;

         IF (px_rule_matching_rec.RULE_MATCH_CODE = G_RULE_MATCH_ONE) THEN
            EXIT;
         END IF; --* end I(px_rule_matching_rec.RULE_MATCH_CODE = G_RULE_MATCH_ONE) *--
      END IF; --* end IF (l_is_match = FND_API.G_TRUE) *--
      --** debug starts!!
      --dbms_output.put_line('PROCESS_RULE_MATCHING -> before exiting rules loop');
      --** debug ends!!

   END LOOP; --* end FOR l_rule_rec ... *--

   --* logic ends here *--

   --* Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   --** debug starts!!
   --dbms_output.put_line('PROCESS_RULE_MATCHING -> after commit work');
   --** debug ends!!

   --* Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   --** debug starts!!
   --dbms_output.put_line('PROCESS_RULE_MATCHING -> after standard call to message count');
   --** debug ends!!

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         --** debug starts!!
         --dbms_output.put_line('PROCESS_RULE_MATCHING -> exception 1');
         --** debug ends!!

         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         --** debug starts!!
         --dbms_output.put_line('PROCESS_RULE_MATCHING -> exception 2');
         --** debug ends!!

         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         --** debug starts!!
         --dbms_output.put_line('PROCESS_RULE_MATCHING -> exception 3');
         --** debug ends!!

         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
            ,P_SQLCODE => SQLCODE
            ,P_SQLERRM => SQLERRM
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
END PROCESS_RULE_MATCHING;


/*--------------------------------------------------------------------*/
/* procedure name: GET_DEFAULT_VALUE_FROM_RULE   (overloaded)         */
/* description : procedure used to get default values from rules      */
/*               default value = VARCHAR2 data type                   */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Workbench defaulting                    */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   p_entity_attribute_type VARCHAR2 Req                             */
/*   p_entity_attribute_code VARCHAR2 Req                             */
/*   p_rule_input_rec    CSD_RULE_INPUT_REC_TYPE Req                  */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/*   x_default_value     VARCHAR2                                     */
/*   x_rule_id           NUMBER        Rule ID that determined value  */
/*                                     if null, then no rule used     */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*               Aug-20-08   swai       added param x_rule_id         */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE GET_DEFAULT_VALUE_FROM_RULE (
    p_api_version_number           IN            NUMBER,
    p_init_msg_list                IN            VARCHAR2   := FND_API.G_FALSE,
    p_commit                       IN            VARCHAR2   := FND_API.G_FALSE,
    p_validation_level             IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_entity_attribute_type        IN            VARCHAR2,
    p_entity_attribute_code        IN            VARCHAR2,
    p_rule_input_rec               IN            CSD_RULE_INPUT_REC_TYPE,
    x_default_value                OUT    NOCOPY VARCHAR2,
    x_rule_id                      OUT    NOCOPY NUMBER,  -- swai: 12.1.1 ER 7233924
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2
)
IS
   ---- local constants ----
   c_API_NAME                CONSTANT VARCHAR2(30) := 'GET_DEFAULT_VALUE_FROM_RULE';
   c_API_VERSION_NUMBER      CONSTANT NUMBER       := G_L_API_VERSION_NUMBER;

   ---- local variables ----
   l_rule_matching_rec  CSD_RULE_MATCHING_REC_TYPE;
   l_default_val_str    VARCHAR2(150) := NULL;
   l_tbl_count          NUMBER        := 0;
   l_value_type         VARCHAR(30)   := NULL;
   l_defaulting_value   VARCHAR(150)  := NULL;
   l_default_rule_id    NUMBER        := NULL;  -- swai: added for 12.1.1
BEGIN
   --* Standard Start of API savepoint
   SAVEPOINT GET_DFLT_VAL_FROM_RULE_PVT;

   --* Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( c_API_VERSION_NUMBER,
                                        p_api_version_number,
                                        c_API_NAME,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --* Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   --* Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --* logic starts here *--

   /*   BEGIN: Algorithm:
   *   (1) initialize a local record l_rule_matching_rec of type CSD_RULE_MATCHING_REC_TYPE:
   *      l_rule_matching_rec.rule_match_code := 1;
   *      l_rule_matching_rec.rule_type = DEFAULTING;
   *      l_rule_matching_rec.entity_attribute_type := p_entity_attribute_type;
   *      l_rule_matching_rec.entity_attribute_code := p_entity_attribute_code;
   *      l_rule_matching_rec.rule_input_rec := p_rule_input_rec;
   *
   *   (2) Call procedure PROCESS_RULE_MATCHING
   *   (3) Check if any retrieval needs to be done for default value:
   *               IF l_rule_matching_rec.RULE_RESULTS_TBL(1).VALUE_TYPE = ATTRIBUTE THEN
   *                  DEFAULT_VALUE :=  l_rule_matching_rec.RULE_RESULTS_TBL(1).defaulting_value
   *               ELSIF l_rule_matching_rec.RULE_RESULTS_TBL(1).VALUE_TYPE = PROFILE THEN
   *                  DEFAULT_VALUE := get fnd_profile value for profile name stored in
   *                                   l_rule_matching_rec.RULE_RESULTS_TBL(1).defaulting_value
   *               ELSIF l_rule_matching_rec.RULE_RESULTS_TBL(1).VALUE_TYPE = PLSQL THEN
   *                  DEFAULT_VALUE := execute PL/SQL API.
   *               END IF;
   *    END: Algorithm*/

   --* init l_rule_matching_rec
   l_rule_matching_rec.rule_match_code := G_RULE_MATCH_ONE;
   l_rule_matching_rec.rule_type := G_RULE_TYPE_DEFAULTING;
   l_rule_matching_rec.entity_attribute_type := p_entity_attribute_type;
   l_rule_matching_rec.entity_attribute_code := p_entity_attribute_code;
   l_rule_matching_rec.rule_input_rec := p_rule_input_rec;

   --** debug starts!!
   --dbms_output.put_line('GET_DEFAULT_VALUE_FROM_RULE before PROCESS_RULE_MATCHING, x_return_status ' || x_return_status);
   --** debug ends!!


   PROCESS_RULE_MATCHING(
      p_api_version_number  => p_api_version_number,
      p_commit              => p_commit,
      p_init_msg_list       => p_init_msg_list,
      p_validation_level    => p_validation_level,
      px_rule_matching_rec  => l_rule_matching_rec,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
   );
   --** debug starts!!
   --dbms_output.put_line('GET_DEFAULT_VALUE_FROM_RULE -> x_return_status = ' || x_return_status);
   --** debug ends!!

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('CSD', 'CSD_RULE_MATCH_FAILED');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; --* end IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) *--

   l_tbl_count := l_rule_matching_rec.RULE_RESULTS_TBL.COUNT;

   --** debug starts!!
   --dbms_output.put_line('GET_DEFAULT_VALUE_FROM_RULE -> l_tbl_count = ' || l_tbl_count);
   --** debug ends!!

   IF (l_tbl_count > 0) THEN
      l_value_type := l_rule_matching_rec.RULE_RESULTS_TBL(1).VALUE_TYPE;
      l_defaulting_value := l_rule_matching_rec.RULE_RESULTS_TBL(1).DEFAULTING_VALUE;
      l_default_rule_id := l_rule_matching_rec.RULE_RESULTS_TBL(1).RULE_ID;    -- swai: 12.1.1 ER 7233924
      --** debug starts!!
      --dbms_output.put_line('GET_DEFAULT_VALUE_FROM_RULE , value_type ' || l_value_type);
      --dbms_output.put_line('GET_DEFAULT_VALUE_FROM_RULE , defaulting_value ' || l_defaulting_value);
      --** debug ends!!
    END IF; --* end IF (l_tbl_count > 0) *--

   --* GET_DEFAULT_VALUE must be always called because if l_defaulting_value is null,
   --* then the value would be returned from a profile option
   l_default_val_str := GET_DEFAULT_VALUE(
                              p_value_type        => l_value_type,
                              p_defaulting_value  => l_defaulting_value,
                              p_attribute_type    => p_entity_attribute_type,
                              p_attribute_code    => p_entity_attribute_code
                              );

   --** debug starts!!
   --dbms_output.put_line('GET_DEFAULT_VALUE_FROM_RULE , after GET_DEFAULT_VALUE,  l_default_val_str = ' || l_default_val_str);
   --** debug ends!!

   x_rule_id := l_default_rule_id;     -- swai: 12.1.1 ER 7233924
   x_default_value := l_default_val_str;
   --* logic ends here *--


   --* Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
            ,P_SQLCODE => SQLCODE
            ,P_SQLERRM => SQLERRM
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
END GET_DEFAULT_VALUE_FROM_RULE;


/*--------------------------------------------------------------------*/
/* procedure name: GET_DEFAULT_VALUE_FROM_RULE   (overloaded)         */
/* description : procedure used to get default values from rules      */
/*               default value =  NUMBER data type                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Workbench defaulting                    */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   p_entity_attribute_type VARCHAR2 Req                             */
/*   p_entity_attribute_code VARCHAR2 Req                             */
/*   p_rule_input_rec    CSD_RULE_INPUT_REC_TYPE Req                  */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/*   x_default_value     NUMBER                                       */
/*   x_rule_id           NUMBER        Rule ID that determined value  */
/*                                     if null, then no rule used     */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*               Aug-20-08   swai       added param x_rule_id         */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE GET_DEFAULT_VALUE_FROM_RULE (
   p_api_version_number           IN            NUMBER,
   p_init_msg_list                IN            VARCHAR2   := FND_API.G_FALSE,
   p_commit                       IN            VARCHAR2   := FND_API.G_FALSE,
   p_validation_level             IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_entity_attribute_type        IN            VARCHAR2,
   p_entity_attribute_code        IN            VARCHAR2,
   p_rule_input_rec               IN            CSD_RULE_INPUT_REC_TYPE,
   x_default_value                OUT    NOCOPY NUMBER,
   x_rule_id                      OUT    NOCOPY NUMBER,  -- swai: 12.1.1 ER 7233924
   x_return_status                OUT    NOCOPY VARCHAR2,
   x_msg_count                    OUT    NOCOPY NUMBER,
   x_msg_data                     OUT    NOCOPY VARCHAR2
)
IS
   ---- local constants ----
   c_API_NAME                CONSTANT VARCHAR2(30) := 'GET_DEFAULT_VALUE_FROM_RULE';

   ---- local variables ----
   l_default_val_str    VARCHAR2(150) := NULL;
BEGIN
   --* Standard Start of API savepoint
   SAVEPOINT GET_DFLT_VAL_FROM_RULE_PVT;

   --* call the string function
   GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => p_api_version_number,
          p_init_msg_list         => p_init_msg_list,
          p_commit                => p_commit,
          p_validation_level      => p_validation_level,
          p_entity_attribute_type => p_entity_attribute_type,
          p_entity_attribute_code => p_entity_attribute_code,
          p_rule_input_rec        => p_rule_input_rec,
          x_default_value         => l_default_val_str,
          x_rule_id               => x_rule_id,  -- swai: 12.1.1 ER 7233924
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data
   );

   --* convert value to number
   x_default_value := to_number(l_default_val_str);

   --* logic ends here *--
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
            ,P_SQLCODE => SQLCODE
            ,P_SQLERRM => SQLERRM
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
END GET_DEFAULT_VALUE_FROM_RULE;


/*--------------------------------------------------------------------*/
/* procedure name: GET_DEFAULT_VALUE_FROM_RULE   (overloaded)         */
/* description : procedure used to get default values from rules      */
/*               default value = DATE data type                       */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Workbench defaulting                    */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   p_entity_attribute_type VARCHAR2 Req                             */
/*   p_entity_attribute_code VARCHAR2 Req                             */
/*   p_rule_input_rec    CSD_RULE_INPUT_REC_TYPE Req                  */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/*   x_default_value     DATE                                         */
/*   x_rule_id           NUMBER        Rule ID that determined value  */
/*                                     if null, then no rule used     */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*               Aug-20-08   swai       added param x_rule_id         */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE GET_DEFAULT_VALUE_FROM_RULE (
   p_api_version_number           IN            NUMBER,
   p_init_msg_list                IN            VARCHAR2   := FND_API.G_FALSE,
   p_commit                       IN            VARCHAR2   := FND_API.G_FALSE,
   p_validation_level             IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_entity_attribute_type        IN            VARCHAR2,
   p_entity_attribute_code        IN            VARCHAR2,
   p_rule_input_rec               IN            CSD_RULE_INPUT_REC_TYPE,
   x_default_value                OUT    NOCOPY DATE,
   x_rule_id                      OUT    NOCOPY NUMBER,  -- swai: 12.1.1 ER 7233924
   x_return_status                OUT    NOCOPY VARCHAR2,
   x_msg_count                    OUT    NOCOPY NUMBER,
   x_msg_data                     OUT    NOCOPY VARCHAR2
)
IS
   ---- local constants ----
   c_API_NAME                CONSTANT VARCHAR2(30) := 'GET_DEFAULT_VALUE_FROM_RULE';

   ---- local variables ----
   l_default_val_str    VARCHAR2(150) := NULL;

BEGIN
   --* Standard Start of API savepoint
   SAVEPOINT GET_DFLT_VAL_FROM_RULE_PVT;
   --* call the string function
   GET_DEFAULT_VALUE_FROM_RULE (
          p_api_version_number    => p_api_version_number,
          p_init_msg_list         => p_init_msg_list,
          p_commit                => p_commit,
          p_validation_level      => p_validation_level,
          p_entity_attribute_type => p_entity_attribute_type,
          p_entity_attribute_code => p_entity_attribute_code,
          p_rule_input_rec        => p_rule_input_rec,
          x_default_value         => l_default_val_str,
          x_rule_id               => x_rule_id,  -- swai: 12.1.1 ER 7233924
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data
   );

   --* convert value to date
   x_default_value := to_date(l_default_val_str, 'DD-MM-YY HH:MI:SS');


   --* logic ends here *--
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
            ,P_SQLCODE => SQLCODE
            ,P_SQLERRM => SQLERRM
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
END GET_DEFAULT_VALUE_FROM_RULE;

/*--------------------------------------------------------------------*/
/* procedure name: MATCH_CONDITION                                    */
/* description : procedure used to match parameter to criterion based */
/*               on operatior                                         */
/*               Calls overloaded function - CHECK_CONDITION_MATCH    */
/*                                                                    */
/*                                                                    */
/* Called from : PROCEDURE PROCESS_RULE_MATCHING                      */
/* Input Parm  :                                                      */
/*    p_parameter_type  VARCHAR2 Req                                  */
/*    p_operator        VARCHAR2 Req                                  */
/*    p_criterion       VARCHAR2 Req                                  */
/*    p_rule_input_rec  CSD_RULE_INPUT_REC_TYPE Req                   */
/* Return Val :                                                       */
/*    VARCHAR2 G_MISS.G_TRUE/G_MISS.G_FALSE                           */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION  MATCH_CONDITION (
   p_parameter_type              IN            VARCHAR2,
   p_operator                    IN            VARCHAR2,
   p_criterion                   IN            VARCHAR2,
   p_rule_input_rec              IN            CSD_RULE_INPUT_REC_TYPE
) RETURN VARCHAR2 IS
   ---- local variables ----
   l_return_val         VARCHAR2(1)               := Fnd_Api.G_FALSE;
   l_rule_input_rec     CSD_RULE_INPUT_REC_TYPE;
   l_number_input       NUMBER                    := -1;
   l_short_string_input VARCHAR2(30)              := NULL;
   l_repair_line_id     NUMBER                    := NULL;
   l_date_field         DATE                      := NULL;

   ---- cursors ----

BEGIN
   l_repair_line_id := p_rule_input_rec.repair_line_id;
   COPY_RULE_INPUT_REC_VALUES(p_rule_input_rec, l_rule_input_rec);


   IF (p_parameter_type = 'USER_ID') THEN -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - USER_ID');
      --** debug ends!!

      l_number_input := FND_GLOBAL.USER_ID;
      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));
   ELSIF (p_parameter_type = 'USER_RESPONSIBILITY') THEN -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - USER_RESPONSIBILITY');
      --** debug ends!!
      l_number_input := FND_GLOBAL.RESP_ID;
      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));
   ELSIF (p_parameter_type = 'USER_INV_ORG') THEN -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - USER_INV_ORG');
      --** debug ends!!

      l_number_input := FND_PROFILE.VALUE(G_PROFILE_INV_ORG); -- get user inventory org id
      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));
   ELSIF (p_parameter_type = 'USER_OU') THEN -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - USER_OU');
      --** debug ends!!

      l_number_input := FND_GLOBAL.ORG_ID;  -- ou id
      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));
   ELSIF (p_parameter_type = 'SR_CUSTOMER_ID') THEN  -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - SR_CUSTOMER_ID');
      --** debug ends!!

      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_rule_input_rec.SR_CUSTOMER_ID,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));
   ELSIF (p_parameter_type = 'SR_CUSTOMER_ACCOUNT_ID') THEN  -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - SR_CUSTOMER_ACCOUNT_ID ');
      --** debug ends!!

      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_rule_input_rec.SR_CUSTOMER_ACCOUNT_ID,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));

   ELSIF (p_parameter_type = 'SR_BILL_TO_COUNTRY') THEN -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - SR_BILL_TO_COUNTRY');
      --** debug ends!!

      --* site_use_id -> site_id  hz_party_site_uses
      --* site_id -> location_id  hz_party_sites_v or hz_party_sites
      --* location has country code hz_locations, use CSDSERVC.pld as example
      l_short_string_input := GET_COUNTRY_CODE(p_site_use_id => l_rule_input_rec.SR_BILL_TO_SITE_USE_ID); --get sr bill to country from l_rule_input_rec.SR_BILL_TO_SITE_USE_ID
      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_short_string_input,
                                            p_operator    => p_operator,
                                            p_criterion   => p_criterion);
   ELSIF (p_parameter_type = 'SR_SHIP_TO_COUNTRY') THEN -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - SR_SHIP_TO_COUNTRY ');
      --** debug ends!!

     l_short_string_input := GET_COUNTRY_CODE(p_site_use_id => l_rule_input_rec.SR_SHIP_TO_SITE_USE_ID); --get sr bill to country from l_rule_input_rec.SR_BILL_TO_SITE_USE_ID
     l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_short_string_input,
                                           p_operator    => p_operator,
                                           p_criterion   => p_criterion);
   ELSIF (p_parameter_type = 'SR_ITEM_ID') THEN -- OK --
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - SR_ITEM_ID');
      --** debug ends!!

      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_rule_input_rec.SR_ITEM_ID,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));
   ELSIF (p_parameter_type = 'SR_ITEM_CATEGORY_ID') THEN --  to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - SR_ITEM_CATEGORY_ID');
      --** debug ends!!

      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_rule_input_rec.SR_ITEM_CATEGORY_ID,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));

   ELSIF (p_parameter_type = 'SR_CONTRACT_ID') THEN -- to test
      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_rule_input_rec.SR_CONTRACT_ID,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));
   ELSIF (p_parameter_type = 'SR_PROBLEM_CODE') THEN -- to test
      --** debug starts!!
      --dbms_output.put_line('>>>MATCH_CONDITION - SR_PROBLEM_CODE');
      --** debug ends!!

      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_rule_input_rec.SR_PROBLEM_CODE,
                                            p_operator    => p_operator,
                                            p_criterion   => p_criterion);
   -- swai: 12.1.1 ER 7233924
   ELSIF (p_parameter_type = 'RO_ITEM_ID') THEN
      l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_rule_input_rec.RO_ITEM_ID,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));
   -- swai: 12.1.1 ER 7233924
   ELSIF (p_parameter_type = 'RO_ITEM_CATEGORY_ID') THEN --  to test
      l_return_val := CHECK_RO_ITEM_CATEGORY(p_ro_item_id => l_rule_input_rec.RO_ITEM_ID,
                                            p_operator    => p_operator,
                                            p_criterion   => to_number(p_criterion));

   ELSIF (p_parameter_type = 'RO_PROMISE_DATE_THRESHOLD') THEN -- to test
      --* get # days for sysdate promise_date
      l_return_val := CHECK_PROMISE_DATE(p_repair_line_id => l_repair_line_id,
                                         p_operator       => p_operator,
                                         p_criterion      => p_criterion);
   ELSIF (p_parameter_type = 'RO_RESOLVE_BY_DATE_THRESHOLD') THEN -- to test
      l_return_val := CHECK_RESOLVE_BY_DATE(p_repair_line_id => l_repair_line_id,
                                            p_operator       => p_operator,
                                            p_criterion      => p_criterion);
   ELSIF (p_parameter_type = 'RO_THIRD_PTY_THRESHOLD') THEN -- to test
      --* get # days a third party based on repair line id (return by date on 3rd party return logistics line)
      l_return_val := CHECK_RETURN_BY_DATE(p_repair_line_id => l_repair_line_id,
                                           p_action_type    => G_ACTION_TYPE_RMA_THIRD_PTY,
                                           p_action_code    => '%',
                                           p_operator       => p_operator,
                                           p_criterion      => p_criterion);
   ELSIF (p_parameter_type = 'RO_EXCHANGE_THRESHOLD') THEN -- to test
      --* get # days exchange is out based on repair line id
      l_return_val := CHECK_RETURN_BY_DATE(p_repair_line_id => l_repair_line_id,
                                           p_action_type    => G_ACTION_TYPE_RMA,
                                           p_action_code    => G_ACTION_CODE_EXCHANGE,
                                           p_operator       => p_operator,
                                           p_criterion      => p_criterion);
   ELSIF (p_parameter_type = 'RO_LOANER_THRESHOLD') THEN -- to test
      --*get # days loaner is out based on repair line id (return by date on loaner line)
      l_return_val := CHECK_RETURN_BY_DATE(p_repair_line_id => l_repair_line_id,
                                           p_action_type    => G_ACTION_TYPE_RMA,
                                           p_action_code    => G_ACTION_CODE_LOANER,
                                           p_operator       => p_operator,
                                           p_criterion      => p_criterion);
   -- swai: bug 7524870 - add new condition
   ELSIF (p_parameter_type = 'RO_RMA_CUST_PROD_THRESHOLD') THEN
      --*get # days until customer product is due based on repair line id (return by date on rma line)
      l_return_val := CHECK_RETURN_BY_DATE(p_repair_line_id => l_repair_line_id,
                                           p_action_type    => G_ACTION_TYPE_RMA,
                                           p_action_code    => G_ACTION_CODE_CUST_PROD,
                                           p_operator       => p_operator,
                                           p_criterion      => p_criterion);
   -- end swai: bug 7524870
   ELSIF (p_parameter_type = 'RO_REPEAT_REPAIR_THRESHOLD') THEN -- code, need to find out how to get ship date
      --*get # days since last repair based on instance_id
      l_return_val := CHECK_REPEAT_REPAIR  (p_repair_line_id => l_repair_line_id,
                                            p_operator       => p_operator,
                                            p_criterion      => p_criterion);
   ELSIF (p_parameter_type = 'RO_CHRONIC_REPAIR_THRESHOLD') THEN -- code, need to find out how to get ship date
      --* quality check period is a new profile option, it's a number uom (day)
      --* number of repairs during the check period per instance
      --* get # repair orders within quality check period, for instance_id
      l_return_val := CHECK_CHRONIC_REPAIR(p_repair_line_id => l_repair_line_id,
                                           p_operator       => p_operator,
                                           p_criterion      => p_criterion);
   ELSIF (p_parameter_type = 'RO_CONTRACT_EXP_THRESHOLD') THEN -- to test, what does grace period mean?
      --* get # days until contract expires
      l_return_val := CHECK_CONTRACT_EXP_DATE(p_repair_line_id => l_repair_line_id,
                                              p_operator       => p_operator,
                                              p_criterion      => p_criterion);

   END IF; --* end IF (p_parameter_type = 'USER_ID') *--

   RETURN l_return_val;
END MATCH_CONDITION;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CONDITION_MATCH   (overloaded)               */
/* description : procedure used to check if parameter matches         */
/*               criterion based on operator                          */
/*               parameter, criterion = NUMBER data type              */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_parameter_type  NUMBER Req                                    */
/*    p_operator        NUMBER Req                                    */
/*    p_criterion       NUMBER Req                                    */
/* Return Val :                                                       */
/*    VARCHAR2 G_MISS.G_TRUE/G_MISS.G_FALSE                           */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION  CHECK_CONDITION_MATCH (
   p_input_param                 IN            NUMBER,
   p_operator                    IN            VARCHAR2,
   p_criterion                   IN            NUMBER
) RETURN VARCHAR2 IS
   l_return_val VARCHAR2(1):= FND_API.G_FALSE;
BEGIN

   --** debug starts!!
   --dbms_output.put_line('NNN CHECK_CONDITION_MATCH_N top p_input_param = ' || p_input_param);
   --dbms_output.put_line('NNN CHECK_CONDITION_MATCH_N top p_operator = ' || p_operator);
   --dbms_output.put_line('NNN CHECK_CONDITION_MATCH_N top p_criterion = ' || p_criterion);
   --** debug ends!!


   IF (p_operator = G_EQUALS AND p_input_param = p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   ELSIF (p_operator = G_NOT_EQUALS AND p_input_param <> p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   ELSIF (p_operator = G_LESS_THAN AND p_input_param < p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   ELSIF (p_operator = G_GREATER_THAN AND p_input_param > p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   END IF;

   --** debug starts!!
   --dbms_output.put_line('NNN CHECK_CONDITION_MATCH_N l_return_val = ' || l_return_val);
   --** debug ends!!

   --* if all of the above cases fail, then there is no match.
   RETURN l_return_val;
END CHECK_CONDITION_MATCH;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CONDITION_MATCH   (overloaded)               */
/* description : procedure used to check if parameter matches         */
/*               criterion based on operator                          */
/*               parameter, criterion = VARCHAR2 data type            */
/*               varchar type only matches = and <>                   */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_parameter_type  VARCHAR2 Req                                  */
/*    p_operator        VARCHAR2 Req                                  */
/*    p_criterion       VARCHAR2 Req                                  */
/* Return Val :                                                       */
/*    VARCHAR2 G_MISS.G_TRUE/G_MISS.G_FALSE                           */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION  CHECK_CONDITION_MATCH (
   p_input_param                 IN            VARCHAR2,
   p_operator                    IN            VARCHAR2,
   p_criterion                   IN            VARCHAR2
) RETURN VARCHAR2 IS
   l_return_val VARCHAR2(1) := FND_API.G_FALSE;
BEGIN
   --** debug starts!!
   --dbms_output.put_line('VVV CHECK_CONDITION_MATCH_V top p_input_param = ' || p_input_param);
   --dbms_output.put_line('VVV CHECK_CONDITION_MATCH_V top p_operator = ' || p_operator);
   --dbms_output.put_line('VVV CHECK_CONDITION_MATCH_V top p_criterion = ' || p_criterion);
   --** debug ends!!

   IF (p_operator = G_EQUALS AND p_input_param = p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   ELSIF (p_operator = G_NOT_EQUALS AND p_input_param <> p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   END IF;

   --** debug starts!!
   --dbms_output.put_line('VVV CHECK_CONDITION_MATCH_V l_return_val = ' || l_return_val);
   --** debug ends!!

   --* if all of the above cases fail, then there is no match.
   RETURN l_return_val;   -- FND_API.G_FALSE
END CHECK_CONDITION_MATCH;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CONDITION_MATCH   (overloaded)               */
/* description : procedure used to check if parameter matches         */
/*               criterion based on operator                          */
/*               parameter, criterion = DATE data type                */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_parameter_type  DATE     Req                                  */
/*    p_operator        VARCHAR2 Req                                  */
/*    p_criterion       DATE     Req                                  */
/* Return Val :                                                       */
/*    VARCHAR2 G_MISS.G_TRUE/G_MISS.G_FALSE                           */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION  CHECK_CONDITION_MATCH (
   p_input_param                 IN            DATE,
   p_operator                    IN            VARCHAR2,
   p_criterion                   IN            DATE
) RETURN VARCHAR2 IS
   l_return_val VARCHAR2(1) := FND_API.G_FALSE;
BEGIN
   --** debug starts!!
   --dbms_output.put_line('DDD CHECK_CONDITION_MATCH_D top p_input_param = ' || p_input_param);
   --dbms_output.put_line('DDD CHECK_CONDITION_MATCH_D top p_operator = ' || p_operator);
   --dbms_output.put_line('DDD CHECK_CONDITION_MATCH_D top p_criterion = ' || p_criterion);
   --** debug ends!!

   IF (p_operator = G_EQUALS AND p_input_param = p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   ELSIF (p_operator = G_NOT_EQUALS AND p_input_param <> p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   ELSIF (p_operator = G_LESS_THAN AND p_input_param < p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   ELSIF (p_operator = G_GREATER_THAN AND p_input_param > p_criterion) THEN
      l_return_val := FND_API.G_TRUE;
   END IF;

   --** debug starts!!
   --dbms_output.put_line('DDD CHECK_CONDITION_MATCH_D l_return_val_D = ' || l_return_val);
   --** debug ends!!

   --* if all of the above cases fail, then there is no match.
   RETURN l_return_val;         -- FND_API.G_FALSE
END CHECK_CONDITION_MATCH;


/*--------------------------------------------------------------------*/
/* procedure name: COPY_RULE_INPUT_REC_VALUES                         */
/* description : copies source rec into dest rec                      */
/*               rec typ = CSD_RULE_INPUT_REC_TYPE                    */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_s_rec  CSD_RULE_INPUT_REC_TYPE     Req                        */
/*    p_d_Rec  CSD_RULE_INPUT_REC_TYPE     VARCHAR2 Req               */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE COPY_RULE_INPUT_REC_VALUES(
   p_s_rec                       IN                   CSD_RULE_INPUT_REC_TYPE, -- source rec
   px_d_rec                      IN OUT NOCOPY        CSD_RULE_INPUT_REC_TYPE  -- destination rec
) IS
BEGIN
   px_d_rec.SR_CUSTOMER_ID          := p_s_rec.SR_CUSTOMER_ID;
   px_d_rec.SR_CUSTOMER_ACCOUNT_ID  := p_s_rec.SR_CUSTOMER_ACCOUNT_ID;
   px_d_rec.SR_BILL_TO_SITE_USE_ID  := p_s_rec.SR_BILL_TO_SITE_USE_ID;
   px_d_rec.SR_SHIP_TO_SITE_USE_ID  := p_s_rec.SR_SHIP_TO_SITE_USE_ID;
   px_d_rec.SR_ITEM_ID              := p_s_rec.SR_ITEM_ID;
   px_d_rec.SR_ITEM_CATEGORY_ID     := p_s_rec.SR_ITEM_CATEGORY_ID;
   px_d_rec.SR_CONTRACT_ID          := p_s_rec.SR_CONTRACT_ID;
   px_d_rec.SR_PROBLEM_CODE         := p_s_rec.SR_PROBLEM_CODE;
   px_d_rec.SR_INSTANCE_ID          := p_s_rec.SR_INSTANCE_ID;
   px_d_rec.RO_ITEM_ID              := p_s_rec.RO_ITEM_ID;     -- swai: 12.1.1 ER 7233924

   --** debug starts!!
   -- dbms_output.put_line('in COPY_RULE_INPUT_REC_VALUES - SR_ITEM_ID  = ' || px_d_rec.SR_ITEM_ID);
   --** debug ends!!

END COPY_RULE_INPUT_REC_VALUES;

/*--------------------------------------------------------------------*/
/* procedure name: COPY_RULE_INPUT_REC_VALUES                         */
/* description : copies source rec into dest rec                      */
/*               rec typ = CSD_RULE_INPUT_REC_TYPE                    */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_s_rec  CSD_RULE_INPUT_REC_TYPE     Req                        */
/*    p_d_Rec  CSD_RULE_INPUT_REC_TYPE     VARCHAR2 Req               */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE POPULATE_RULE_INPUT_REC(
   px_rule_input_rec              IN OUT NOCOPY   CSD_RULE_INPUT_REC_TYPE,
   p_repair_line_id               IN              NUMBER
)IS
   ---- cursors ----
   CURSOR cur_get_rec_info (p_repair_line_id NUMBER) IS
      SELECT a.customer_id,
             a.account_id,
             a.bill_to_site_use_id,
             a.ship_to_site_use_id,
             a.inventory_item_id,
             c.category_id,
             a.contract_id,
             a.problem_code,
             a.customer_product_id,
             b.inventory_item_id  -- swai: 12.1.1 ER 7233924
      FROM   CSD_INCIDENTS_V a, CSD_REPAIRS b, CS_INCIDENTS_B_SEC c
      WHERE  a.incident_id = b.incident_id
      AND    a.incident_id = c.incident_id
      AND    b.repair_line_Id =  p_repair_line_id;
BEGIN
   OPEN cur_get_rec_info(p_repair_line_id);
   FETCH cur_get_rec_info INTO
      px_rule_input_rec.SR_CUSTOMER_ID,
      px_rule_input_rec.SR_CUSTOMER_ACCOUNT_ID,
      px_rule_input_rec.SR_BILL_TO_SITE_USE_ID,
      px_rule_input_rec.SR_SHIP_TO_SITE_USE_ID,
      px_rule_input_rec.SR_ITEM_ID,
      px_rule_input_rec.SR_ITEM_CATEGORY_ID,
      px_rule_input_rec.SR_CONTRACT_ID,
      px_rule_input_rec.SR_PROBLEM_CODE,
      px_rule_input_rec.SR_INSTANCE_ID,
      px_rule_input_rec.RO_ITEM_ID;   -- swai: 12.1.1 ER 7233924
   CLOSE cur_get_rec_info;

   --** debug starts!!
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC P_REPAIR_LINE_ID = ' || p_repair_line_id);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_CUSTOMER_ID = ' || px_rule_input_rec.SR_CUSTOMER_ID);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_CUSTOMER_ACCOUNT_ID = ' || px_rule_input_rec.SR_CUSTOMER_ACCOUNT_ID);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_BILL_TO_SITE_USE_ID = ' || px_rule_input_rec.SR_BILL_TO_SITE_USE_ID);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_SHIP_TO_SITE_USE_ID = ' || px_rule_input_rec.SR_SHIP_TO_SITE_USE_ID);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_ITEM_ID = ' || px_rule_input_rec.SR_ITEM_ID);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_ITEM_CATEGORY_ID = ' || px_rule_input_rec.SR_ITEM_CATEGORY_ID);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_CONTRACT_ID = ' || px_rule_input_rec.SR_CONTRACT_ID);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_PROBLEM_CODE = ' || px_rule_input_rec.SR_PROBLEM_CODE);
   --dbms_output.put_line('***** POPULATE_RULE_INPUT_REC SR_INSTANCE_ID = ' || px_rule_input_rec.SR_INSTANCE_ID);
   --** debug ends!!


END POPULATE_RULE_INPUT_REC;


/*--------------------------------------------------------------------*/
/* procedure name: GET_DEFAULT_VALUE                                  */
/* description : retrieves default value based on type                */
/*               ATTRIBUTE -> return default value as is              */
/*               PROFILE   -> return profile (default value)          */
/*               PLSQL     -> execute function call stored in default */
/*                            value and cast return value to string   */
/*                            and return that string value            */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  GET_DEFAULT_VALUE_FROM_RULE                */
/* Input Parm  :                                                      */
/*    p_value_type       VARCHAR2 Req                                 */
/*    p_defaulting_value VARCHAR2 Req                                 */
/*   p_attribute_type    VARCHAR2 Req                                 */
/*   p_attribute_code    VARCHAR2 Req                                 */
/*    x_return_status   VARCHAR2 Req                                  */
/*    x_msg_count       VARCHAR2 Req                                  */
/*    x_msg_data        VARCHAR2 Req                                  */
/* Return Val :                                                       */
/*    VARCHAR2 - the actual default value                             */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_DEFAULT_VALUE(
   p_value_type        IN            VARCHAR2,
   p_defaulting_value  IN            VARCHAR2,
   p_attribute_type    IN            VARCHAR2,
   p_attribute_code    IN            VARCHAR2
) RETURN VARCHAR2 IS
   ---- local constants ----
   c_SELECT    VARCHAR2(7)   := 'SELECT ';
   c_FROM_DUAL VARCHAR2(10)  := ' FROM DUAL';

   ---- local variables ----
   l_return_val VARCHAR2(150)  := NULL;  -- size of flex field
   l_sql_stmt   VARCHAR2(2000) := NULL;
   l_fdbk       NUMBER         := NULL;
   l_cursor     NUMBER         := NULL;

BEGIN

   --** debug starts!!
   --dbms_output.put_line('~~~ GET_DEFAULT_VALUE top, p_value_type =' || p_value_type);
   --dbms_output.put_line('~~~ GET_DEFAULT_VALUE top, p_defaulting_value =' || p_defaulting_value);
   --dbms_output.put_line('~~~ GET_DEFAULT_VALUE top, p_attribute_type =' || p_attribute_type);
   --dbms_output.put_line('~~~ GET_DEFAULT_VALUE top, p_attribute_code =' || p_attribute_code);
   --** debug ends!!

   -- if defaulting value is null, the try to find profile value if applies
   IF (p_defaulting_value IS NULL) THEN -- get profile values and put them in
      IF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_REPAIR_ORG) THEN
         l_return_val := FND_PROFILE.VALUE(G_PROFILE_REPAIR_ORG);
         --** debug starts!!
         --dbms_output.put_line('~~~ GET_DEFAULT_VALUE , G_ATTR_CODE_REPAIR_ORG, l_return_val from profile = ' || l_return_val);
         --** debug ends!!

      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_REPAIR_OWNER) THEN
         --* no profile
         l_return_val := NULL;
         --** debug starts!!
         --dbms_output.put_line('~~~ GET_DEFAULT_VALUE , G_ATTR_CODE_REPAIR_OWNER, l_return_val set to null ');
         --** debug ends!!

      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_INV_ORG) THEN
         l_return_val := FND_PROFILE.VALUE(G_PROFILE_INV_ORG);
      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_RMA_RCV_ORG) THEN
         --* no profile
         l_return_val := NULL;
      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_RMA_RCV_SUBINV) THEN
         --* no profile
         l_return_val := NULL;
      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_PRIORITY) THEN
         --* no profile, place holder for if other defaulting logic is needed.
         l_return_val := NULL;
      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_REPAIR_TYPE) THEN
         l_return_val := FND_PROFILE.VALUE(G_PROFILE_REPAIR_TYPE);
      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_SHIP_FROM_ORG) THEN
         --* no profile
         l_return_val := NULL;
      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_SHIP_FROM_SUBINV) THEN
         --* no profile
         l_return_val := NULL;
      ELSIF (p_attribute_type = G_ATTR_TYPE_RO) AND (p_attribute_code = G_ATTR_CODE_VENDOR_ACCOUNT) THEN
         --* no profile, no logic needed
         l_return_val := NULL;
      ELSE
         l_return_val := NULL;
      END IF; --*end  IF (p_attribute_type = G_ATTR_TYPE_RO) ...*--

   ELSE
      IF    (p_value_type IS NULL) OR (p_value_type = FND_API.G_MISS_CHAR) --* bulletin rules does not specify this value
         OR (p_value_type = G_VALUE_TYPE_ATTRIBUTE) THEN
         l_return_val := p_defaulting_value;
      ELSIF (p_value_type = G_VALUE_TYPE_PROFILE) THEN
         l_return_val := FND_PROFILE.VALUE(p_defaulting_value);
      ELSIF (p_value_type = G_VALUE_TYPE_PLSQL) THEN
         l_sql_stmt := c_SELECT || p_defaulting_value || c_FROM_DUAL;

         --** debug starts!!
         --dbms_output.put_line('~~~ GET_DEFAULT_VALUE , G_VALUE_TYPE_PLSQL, l_sql_stmt ' || l_sql_stmt);
         --** debug ends!!

         l_cursor := DBMS_SQL.OPEN_CURSOR;

         --* Parse the query  with a dynamic WHERE clause
         DBMS_SQL.PARSE (l_cursor, l_sql_stmt, DBMS_SQL.NATIVE);

         --* Define the columns in the cursor for this query
         DBMS_SQL.DEFINE_COLUMN (l_cursor, 1, l_return_val,150);


         --* Now I can execute the query
         l_fdbk:= DBMS_SQL.EXECUTE (l_cursor);
         LOOP
           --* Try to fetch next row. If done, then exit the loop.
           EXIT WHEN DBMS_SQL.FETCH_ROWS (l_cursor) = 0;

           --* Retrieve data via calls to COLUMN_VALUE and place those
           --* values in a new record in the block.

           DBMS_SQL.COLUMN_VALUE (l_cursor, 1, l_return_val);

         END LOOP;

         /* Clean up the cursor */
         DBMS_SQL.CLOSE_CURSOR (l_cursor);

      ELSE --* unrecognized type, so return null
         l_return_val := NULL;
      END IF; --* end IF (p_value_type = G_VALUE_TYPE_ATTRIBUTE) *--
   END IF; --* end IF (p_defaulting_value IS NULL) *--

   RETURN l_return_val;
END GET_DEFAULT_VALUE;

/*--------------------------------------------------------------------*/
/* procedure name: GET_COUNTRY_CODE                                   */
/* description : returns country code based on site_useid             */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_site_use_id   NUMBER   Req                                    */
/* Return Val :                                                       */
/*    VARCHAR2 - COUNTRY code                                         */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_COUNTRY_CODE(
   p_site_use_id    IN NUMBER
) RETURN VARCHAR2 IS
   ---- local variables ----
   l_country_code   VARCHAR2(60) := NULL;

   ---- cursors ----
   CURSOR cur_get_country_code(p_site_use_id NUMBER) IS
     SELECT b.country
     FROM   hz_party_sites a,
            hz_locations b,
            hz_party_site_uses c
     WHERE  a.location_id = b.location_id
     AND    a.party_site_id = c.party_site_id
     AND    c.party_site_use_id = p_site_use_id
   ; --* end CURSOR cur_get_country_code *--
BEGIN
   OPEN cur_get_country_code(p_site_use_id);
   FETCH cur_get_country_code INTO l_country_code;
   CLOSE cur_get_country_code;

   --** debug starts!!
   --dbms_output.put_line('***GET_COUNTRY_CODE , p_site_use_id = ' || p_site_use_id);
   --dbms_output.put_line('***GET_COUNTRY_CODE , l_country_code =' || l_country_code);
   --** debug ends!!



   RETURN l_country_code;
END GET_COUNTRY_CODE;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_RO_ITEM_CATEGORY                             */
/* description : checks if the RO item is in the specified category   */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_ro_item_id   NUMBER   Req RO Inventory Item Id                */
/*    p_operator     VARCHAR2 Req 'EQUALS': check item is in category */
/*                                'NOT_EQUALS': check item is not in  */
/*                                 item category                      */
/*    p_criterion    NUMBER   Req  Item Category Id                   */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Aug-18-08    swai  created for 12.1.1 ER 7233924     */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_RO_ITEM_CATEGORY(
   p_ro_item_id        IN NUMBER,
   p_operator          IN VARCHAR2,
   p_criterion         IN NUMBER
) RETURN VARCHAR2 IS

   -- cursors --
   CURSOR cur_is_item_in_cat (p_inventory_item_id NUMBER,
                              p_category_id NUMBER)
   IS
      SELECT 'X'
      FROM   mtl_item_categories_v
      WHERE  inventory_item_id = p_inventory_item_id
        and  category_id = p_category_id
        and  organization_id = cs_std.get_item_valdn_orgzn_id;

   -- variables --
   l_item_is_in_cat VARCHAR2(1);
   l_return_val     VARCHAR2(1) := FND_API.G_FALSE;

BEGIN
    OPEN cur_is_item_in_cat (p_ro_item_id, p_criterion);
    FETCH cur_is_item_in_cat into l_item_is_in_cat;
    CLOSE cur_is_item_in_cat;

    CASE p_operator
        when G_EQUALS then
            if (l_item_is_in_cat is null) then
                l_return_val := FND_API.G_FALSE;
            else
                l_return_val := FND_API.G_TRUE;
            end if;
        when G_NOT_EQUALS then
            if (l_item_is_in_cat is null) then
                l_return_val := FND_API.G_TRUE;
            else
                l_return_val := FND_API.G_FALSE;
            end if;
        else
            l_return_val := FND_API.G_FALSE;
    END CASE;
    return l_return_val;

END CHECK_RO_ITEM_CATEGORY;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_PROMISE_BY_DATE                              */
/* description : retrieves RO promise by date                         */
/*               compare threshold with promise_date - sysdate        */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_PROMISE_DATE(
   p_repair_line_id    IN NUMBER,
   p_operator          IN VARCHAR2,
   p_criterion         IN VARCHAR2
) RETURN VARCHAR2 IS
   ---- local variables ----
   l_return_val   VARCHAR2(1) := FND_API.G_FALSE;
   l_number_input NUMBER      := NULL;
   l_date_field   DATE        := NULL;

   ---- cursors ----
   CURSOR cur_get_promise_date(p_repair_line_id NUMBER) IS
      SELECT promise_date
      FROM   csd_repairs
      WHERE  repair_line_id = p_repair_line_id
   ; --* end CURSOR get_promise_date *--
BEGIN
   IF (p_repair_line_id IS NOT NULL) THEN
      OPEN cur_get_promise_date (p_repair_line_id);
      FETCH cur_get_promise_date into l_date_field;
      CLOSE cur_get_promise_date;

      --** debug starts!!
      --dbms_output.put_line('=== CHECK_PROMISE_DATE , l_date_field = ' || l_date_field);
      --** debug ends!!

      IF (l_date_field IS NOT NULL) AND (l_date_field <> FND_API.G_MISS_DATE) THEN
         l_number_input := l_date_field - sysdate;
         l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                               p_operator => p_operator,
                                               p_criterion => to_number(p_criterion));
      END IF; --* IF (l_date_field IS NOT NULL)  ... *--
   END IF; --* end  IF ( l_repair_line_id IS NOT NULL) *--

   RETURN l_return_val;
END CHECK_PROMISE_DATE;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_RESOLVE_BY_DATE                              */
/* description : retrieves RO resolve by date                         */
/*               compare threshold with resolve_by_date - sysdate     */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_RESOLVE_BY_DATE(
   p_repair_line_id    IN NUMBER,
   p_operator          IN VARCHAR2,
   p_criterion         IN VARCHAR2
) RETURN VARCHAR2 IS
   ---- local variables ----
   l_return_val   VARCHAR2(1) := FND_API.G_FALSE;
   l_number_input NUMBER      := NULL;
   l_date_field   DATE        := NULL;
   ---- cursors ----
   CURSOR cur_get_resolve_by_date(p_repair_line_id NUMBER) IS
      SELECT resolve_by_date
      FROM   csd_repairs
      WHERE  repair_line_id = p_repair_line_id
   ; --* end CURSOR get_resolve_by_date *--

BEGIN
   IF (p_repair_line_id IS NOT NULL) THEN
      OPEN cur_get_resolve_by_date (p_repair_line_id);
      FETCH cur_get_resolve_by_date into l_date_field;
      CLOSE cur_get_resolve_by_date;

      --** debug starts!!
      --dbms_output.put_line('==== CHECK_RESOLVE_BY_DATE , l_date_field = ' || l_date_field);
      --** debug ends!!

      IF (l_date_field IS NOT NULL) AND (l_date_field <> FND_API.G_MISS_DATE) THEN
         l_number_input := l_date_field - sysdate; --get # days for sysdate resolve by date
         l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                               p_operator => p_operator,
                                               p_criterion => to_number(p_criterion));
      END IF; --* end IF (l_date_field IS NOT NULL) ...*--
   END IF; -- end  IF ( l_repair_line_id IS NOT NULL) *--

   RETURN l_return_val;
END CHECK_RESOLVE_BY_DATE;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_RETURN_BY_DATE                               */
/* description : retrieves return by date on logistics line           */
/*               '%'       => RMA_THIRD_PARTY line                    */
/*               loaner    => RMA line                                */
/*               exchange  => RMA line                                */
/*               compare threshold with return by date - sysdate      */
/*               -- swai: bug 7524870 - only return a match if the    */
/*               line has not been received AND the condition matches */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/*    p_action_type      VARCHAR2 Req                                 */
/*    p_action_code      VARCHAR2 Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_RETURN_BY_DATE(
   p_repair_line_id    IN NUMBER,
   p_action_type       IN VARCHAR2,
   p_action_code       IN VARCHAR2,
   p_operator          IN VARCHAR2,
   p_criterion         IN VARCHAR2
) RETURN VARCHAR2 IS
   ---- local variables ----
   l_return_val   VARCHAR2(1) := FND_API.G_FALSE;
   l_number_input NUMBER      := NULL;
   l_date_field   DATE        := NULL;
   l_prod_txn_status VARCHAR(30) := NULL;
   ---- cursors ----
   CURSOR cur_get_return_by_date(p_repair_line_id NUMBER,
                             p_action_type    VARCHAR2,
                             p_action_code    VARCHAR2) IS
      SELECT return_by_date, prod_txn_status
      FROM   csd_product_txns_v
      WHERE  action_type = p_action_type
      AND    action_code LIKE p_action_code  -- for 3rd party, pass in '%'
      AND    repair_line_id = p_repair_line_id
   ;  --* end CURSOR get_return_by_date *--

BEGIN
   IF (p_repair_line_id IS NOT NULL) THEN
      OPEN cur_get_return_by_date (p_repair_line_id, p_action_type, p_action_code);
      FETCH cur_get_return_by_date into l_date_field, l_prod_txn_status;
      CLOSE cur_get_return_by_date;

      --** debug starts!!
      --dbms_output.put_line('+++ CHECK_REPEAT_REPAIR , l_date_field = ' || l_date_field);
      --** debug ends!!

      IF (l_date_field IS NOT NULL) AND (l_date_field <> FND_API.G_MISS_DATE) THEN
          -- swai: bug 7524870 if the line has been received, do not return a match
         if (l_prod_txn_status = 'RECEIVED')  then
             l_return_val := FND_API.G_FALSE;
         else
             l_number_input := l_date_field - sysdate;
             l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                               p_operator => p_operator,
                                               p_criterion => to_number(p_criterion));
         end if;
      END IF; --* end IF (l_date_field IS NOT NULL) ...*--
   END IF; --* end IF (l_repair_line_id IS NOT NULL) *--

   RETURN l_return_val;

END CHECK_RETURN_BY_DATE;

/*--------------------------------------------------------------------*/
/* procedure name: CHECK_REPEAT_REPAIR                                */
/* description : 1) get instance id based on repair_line_id           */
/*               2) get the lastest repair based on the instance id   */
/*                  (order by closed_date desc  )                     */
/*                  NOTE: ideally, we would like to use the ship date */
/*                        on the logistics line.  But due to the      */
/*                        complexity, we are using closed_date for    */
/*                        this release.                               */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_REPEAT_REPAIR(
   p_repair_line_id IN NUMBER,
   p_operator       IN VARCHAR2,
   p_criterion      IN VARCHAR2
) RETURN VARCHAR2 IS
   ---- local variables ----
   l_return_val    VARCHAR2(1) := FND_API.G_FALSE;
   l_number_input  NUMBER      := NULL;
   l_date_field    DATE        := NULL;
   l_creation_date DATE        := NULL;
   l_instance_id   NUMBER      := NULL;
   ---- cursors ----
   -- need to redo this query based on ship date, could return
   CURSOR cur_get_latest_repair_date(p_instance_id NUMBER) IS
      SELECT   MAX(a.date_closed)
      FROM     csd_repairs a
      WHERE    a.customer_product_id = p_instance_id
      AND      a.date_closed IS NOT NULL
   ; --* end cur_get_latest_repair_date *--

   CURSOR cur_get_creation_date(p_repair_line_id NUMBER) IS
      SELECT creation_date
      FROM   csd_repairs
      WHERE  repair_line_id = p_repair_line_id
   ; -- end* cur_get_creation_date*--
BEGIN
   IF (p_repair_Line_id IS NOT NULL) THEN
      OPEN cur_get_creation_date (p_repair_line_id);
      FETCH cur_get_creation_date INTO l_creation_date;
      CLOSE cur_get_creation_date;

      IF (l_creation_date IS NOT NULL) AND (l_creation_date <> FND_API.G_MISS_DATE) THEN
         l_instance_id := GET_RO_INSTANCE_ID(p_repair_line_id);

         IF (l_instance_id IS NOT NULL) AND (l_instance_id <> FND_API.G_MISS_NUM) THEN
            -- found instance id, so get latest repair date
            OPEN cur_get_latest_repair_date(l_instance_id);
            FETCH cur_get_latest_repair_date INTO l_date_field;
            CLOSE cur_get_latest_repair_date;

            --** debug starts!!
            --dbms_output.put_line('+++ CHECK_REPEAT_REPAIR , l_date_field = ' || l_date_field);
            --** debug ends!!

            IF (l_date_field IS NOT NULL) AND (l_date_field <> FND_API.G_MISS_DATE) THEN
               l_number_input := sysdate - l_date_field;
               l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                                     p_operator => p_operator,
                                                     p_criterion => to_number(p_criterion));
            END IF; --* end IF (l_date_field IS NOT NULL).. *--
         END IF; --* end IF(l_instance_id IS NOT NULL).. *--
      END IF; --* end IF (l_createion_date IS NOT NULL)...*--
   END IF;--* end IF (p_repair_Line_id IS NOT NULL).. *--

   RETURN l_return_val;
END CHECK_REPEAT_REPAIR;

/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CHRONIC_REPAIR                               */
/* description : 1) get instance id based on repair_line_id           */
/*               2) get profile option CSD_QUALITY_CHECK_PERIOD value */
/*               3) query # of repair orders during this period       */
/*                  (closed_date)                                     */
/*                  NOTE: ideally, we would like to use the ship date */
/*                        on the logistics line.  But due to the      */
/*                        complexity, we are using closed_date for    */
/*                        this release.                               */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_CHRONIC_REPAIR(
   p_repair_line_id IN NUMBER,
   p_operator       IN VARCHAR2,
   p_criterion      IN VARCHAR2
)RETURN VARCHAR2 IS
   ---- local variables ----
   l_return_val   VARCHAR2(1) := FND_API.G_FALSE;
   l_number_input NUMBER      := NULL;
   l_instance_id  NUMBER      := NULL;
   l_period       NUMBER      := NULL;

   ---- cursors ----
   -- need to redo this query based on ship date
   CURSOR cur_get_chronic_repairs(p_instance_id NUMBER,
                                  p_period      NUMBER) IS
      SELECT count(a.repair_line_id)
      FROM   csd_repairs a
      WHERE  a.customer_product_id = p_instance_id
      AND    a.date_closed   BETWEEN sysdate - p_period
                             AND     sysdate
   ; --* end cur_get_chronic_repairs *--
BEGIN
   IF (p_repair_line_id IS NOT NULL) THEN
      l_period := FND_PROFILE.VALUE(G_PROFILE_QUALITY_CHECK_PERIOD);


      --** debug starts!!
      --dbms_output.put_line('+++>> CHECK_CHRONIC_REPAIR , l_period = ' || l_period);
      --** debug ends!!

      l_instance_id := GET_RO_INSTANCE_ID(p_repair_line_id);
      IF (l_instance_id IS NOT NULL) AND (l_instance_id <> FND_API.G_MISS_NUM) THEN
      --* found instance id, so get the number of repairs in period
         OPEN cur_get_chronic_repairs(l_instance_id, l_period);
         FETCH cur_get_chronic_repairs into l_number_input;
         CLOSE cur_get_chronic_repairs;
         l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                               p_operator => p_operator,
                                               p_criterion => to_number(p_criterion));
      END IF; --* end (l_instance_id IS NOT NULL).. *--
   END IF; --* end IF (p_repair_Line_id IS NOT NULL).. *--

   RETURN l_return_val;

END;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CONTRACT_EXP_DATE                            */
/* description : calls OKS_ENTITLEMENTS_PUB.Get_Contracts_Expiration  */
/*               checks threshold with exp date - sysdate             */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id      NUMBER   Req                              */
/*                                                                    */
/*                                                                    */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_CONTRACT_EXP_DATE(
   p_repair_line_id IN NUMBER,
   p_operator       IN VARCHAR2,
   p_criterion      IN VARCHAR2
) RETURN VARCHAR2 IS
   ---- local variables ----
   l_return_val              VARCHAR2(1)      := FND_API.G_FALSE;
   l_number_input            NUMBER           := NULL;
   l_ro_contract_id          NUMBER           := NULL;

   l_return_status           VARCHAR2(1)      := NULL;
   l_msg_count               NUMBER           := NULL;
   l_msg_data                VARCHAR2(2000)   := NULL;
   l_contract_end_date       DATE             := NULL;

   ---- cursors ----
   CURSOR cur_get_ro_contract_id(p_repair_line_id NUMBER) IS
      SELECT contract_line_id
      FROM   csd_repairs
      WHERE  repair_line_id = p_repair_line_id
   ; --* end cur_get_ro_contract_id *--

   -- bug 7323831 - contract line can expire if either end date or termination date
   -- has passed.  If either date is null, do not consider it as a valid date for.
   -- comparison. If both end and termination dates are null, then return null.
   CURSOR cur_get_contract_end_date(p_contract_line_id NUMBER) IS
      SELECT least(nvl(end_date, date_terminated), nvl(date_terminated, end_date))
      FROM   OKC_K_Lines_B
      WHERE  id = p_contract_line_id
   ;

BEGIN
   IF (p_repair_Line_id IS NOT NULL) THEN
      OPEN cur_get_ro_contract_id (p_repair_line_id);
      FETCH cur_get_ro_contract_id INTO l_ro_contract_id;
      CLOSE cur_get_ro_contract_id;

      --** debug starts!!
      --dbms_output.put_line('+++-- CHECK_CONTRACT_EXP_DATE , l_ro_contract_id = ' || l_ro_contract_id);
      --** debug ends!!

      IF (l_ro_contract_id IS NOT NULL) AND (l_ro_contract_id <> FND_API.G_MISS_NUM) THEN
         OPEN cur_get_contract_end_date (l_ro_contract_id);
         FETCH cur_get_contract_end_date INTO l_contract_end_date;
         CLOSE cur_get_contract_end_date;

         --** debug starts!!
         --dbms_output.put_line('+++-- CHECK_CONTRACT_EXP_DATE , l_contract_end_date = ' || l_contract_end_date);
         --** debug ends!!


         IF (l_contract_end_date IS NOT NULL) AND (l_contract_end_date <> FND_API.G_MISS_DATE) THEN
            l_number_input := l_contract_end_date - sysdate;
            l_return_val := CHECK_CONDITION_MATCH(p_input_param => l_number_input,
                                                  p_operator => p_operator,
                                                  p_criterion => to_number(p_criterion));
         END IF; --* end IF (l_contract_end_date IS NOT NULL)...*--
       END IF;  --* end IF (l_ro_contract_id IS NOT NULL)... *--
    END IF; --* end IF (p_repair_Line_id IS NOT NULL)... *--


    RETURN l_return_val;
END CHECK_CONTRACT_EXP_DATE;


/*   probably should be moved to util package                         */
/*--------------------------------------------------------------------*/
/* procedure name: GET_RO_INSTANCE_ID                                 */
/* description : returns customer_producet_id of the SR header for    */
/*               the repair line                                      */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_contract_id      NUMBER   Req                                 */
/*                                                                    */
/*                                                                    */
/* Return Val :                                                       */
/*    NUMBER - Instance ID                                            */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_RO_INSTANCE_ID(
    p_repair_line_id IN NUMBER
) RETURN NUMBER IS
   ---- local variables ----
   l_instance_id NUMBER := NULL;
   ---- cursors ----
   CURSOR cur_get_instance_id(p_repair_line_id NUMBER) IS
      SELECT customer_product_id
      FROM   csd_repairs
      WHERE  repair_line_id = p_repair_line_id
   ;--* end cur_get_instance_id *--
BEGIN
   IF (p_repair_Line_id IS NOT NULL) THEN
      OPEN cur_get_instance_id(p_repair_line_id);
      FETCH cur_get_instance_id INTO l_instance_id;

      IF ( cur_get_instance_id%NOTFOUND) OR (l_instance_id IS NULL) OR (l_instance_Id = FND_API.G_MISS_NUM) THEN -- no instance, do nothing
         l_instance_id := NULL; -- force value to null
      END IF;
      CLOSE cur_get_instance_id;
   END IF; --* end IF (p_repair_Line_id IS NOT NULL) *--

   --** debug starts!!
   --dbms_output.put_line(' *helper* GET_RO_INSTANCE_ID l_instance_id = ' ||  l_instance_id);
   --** debug ends!!

   RETURN l_instance_id;
END GET_RO_INSTANCE_ID;


/*--------------------------------------------------------------------*/
/* function name: GET_RULE_SQL_FOR_RO                                 */
/* description : Given a single rule, generate a sql query            */
/*               that will match all repair orders for all its        */
/*               conditions                                           */
/*                                                                    */
/* Called from : PROCEDURE  LINK_BULLETIN_FOR_RULE                    */
/* Input Parm  :                                                      */
/*    l_rule_condition_rec      CSD_RULE_CONDITION_REC_TYPE     Req   */
/*                                                                    */
/*                                                                    */
/* Return Val :                                                       */
/*    VARCHAR2 - SQL Query to get ROs for rule  condition             */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_RULE_SQL_FOR_RO(
    p_rule_id IN NUMBER
) RETURN VARCHAR2
IS
    -- CURSORS --
    CURSOR c_rule_conditions (p_rule_id number) IS
    SELECT rule_condition_id,
           rule_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM CSD_RULE_CONDITIONS_B
    WHERE rule_id = p_rule_id;

    -- VARIABLES --
    l_sql_query           VARCHAR2(32767) := null;
    l_rule_condition_rec  CSD_RULES_ENGINE_PVT.CSD_RULE_CONDITION_REC_TYPE;
    l_join_stmt           VARCHAR2(3000) := null;
    l_operator VARCHAR2 (2);
    l_num_condition VARCHAR2(3000); -- for conditions that match a number type
    l_str_condition VARCHAR2(3000); -- for conditions that match a string type
    l_condition_count NUMBER :=0;

BEGIN
    l_sql_query := 'select dra.repair_line_id from csd_repairs dra, cs_incidents_b_sec csb '
                || 'where csb.incident_id = dra.incident_id';
    OPEN c_rule_conditions(p_rule_id);
    LOOP
        FETCH c_rule_conditions into l_rule_condition_rec;
        EXIT WHEN c_rule_conditions%NOTFOUND;

        -- if there is a condition to be processed, then increment the count
        l_condition_count := l_condition_count + 1;

        -- try to build the the join statement
        l_join_stmt := null;
        l_operator := GET_SQL_OPERATOR(l_rule_condition_rec.attribute1);
        IF (l_operator is not null) AND (l_rule_condition_rec.attribute2 is not null) THEN
            l_num_condition :=  l_operator ||  ' ' || l_rule_condition_rec.attribute2;
            l_str_condition :=  l_operator ||  ' ''' || l_rule_condition_rec.attribute2 || '''';

            case l_rule_condition_rec.attribute_category
                when 'USER_ID' then
                    l_join_stmt := 'FND_GLOBAL.USER_ID ' || l_num_condition;
                when 'USER_RESPONSIBILITY' then
                    l_join_stmt := 'FND_GLOBAL.RESP_ID ' || l_num_condition;
                when 'USER_INV_ORG' then
                    l_join_stmt := 'FND_PROFILE.VALUE(''' || G_PROFILE_INV_ORG || ''') '
                                 || l_num_condition;
                when 'USER_OU' then
                    l_join_stmt := 'FND_GLOBAL.ORG_ID ' || l_num_condition;
                when 'SR_CUSTOMER_ID' then
                    l_join_stmt :=  'csb.customer_id ' || l_num_condition;
                when 'SR_CUSTOMER_ACCOUNT_ID' then
                    l_join_stmt :=  'csb.account_id ' || l_num_condition;
                when 'SR_BILL_TO_COUNTRY' then
                    l_join_stmt :=  'csb.bill_to_site_use_id in (select hpsu.party_site_use_id'
                                 || ' from hz_party_sites hps, hz_locations hl, hz_party_site_uses hpsu'
                                 || ' where hps.location_id = hl.location_id'
                                 || ' and hps.party_site_id = hpsu.party_site_id'
                                 || ' and hpsu.party_site_use_id = csb.bill_to_site_use_id'
                                 || ' and hl.country '
                                 || l_str_condition || ')';
                when 'SR_SHIP_TO_COUNTRY' then
                    l_join_stmt :=  'csb.ship_to_site_use_id in (select hpsu.party_site_use_id'
                                 || ' from hz_party_sites hps, hz_locations hl, hz_party_site_uses hpsu'
                                 || ' where hps.location_id = hl.location_id'
                                 || ' and hps.party_site_id = hpsu.party_site_id'
                                 || ' and hpsu.party_site_use_id = csb.ship_to_site_use_id'
                                 || ' and hl.country '
                                 || l_str_condition || ')';
                when 'SR_ITEM_ID' then
                    l_join_stmt :=  'csb.inventory_item_id ' || l_num_condition;
                when 'SR_ITEM_CATEGORY_ID' then
                    l_join_stmt :=  'csb.category_id ' || l_num_condition;
                when 'SR_CONTRACT_ID' then
                    l_join_stmt :=  'csb.contract_id ' || l_num_condition;
                when 'SR_PROBLEM_CODE' then
                    l_join_stmt :=  'csb.problem_code ' || l_str_condition;
                -- swai: 12.1.1 ER 7233924
                when 'RO_ITEM_ID' then
                    l_join_stmt :=  'dra.inventory_item_id ' || l_num_condition;
                -- swai: 12.1.1 ER 7233924
                when 'RO_ITEM_CATEGORY_ID' then
                    if (l_rule_condition_rec.attribute1 = 'EQUALS') then
                        l_join_stmt := 'exists';
                    elsif(l_rule_condition_rec.attribute1 = 'NOT_EQUALS') then
                        l_join_stmt := 'not exists';
                    else
                        l_join_stmt := null;
                    end if;

                    if (l_join_stmt is not null) then
                       l_join_stmt :=  l_join_stmt || ' (select ''X'''
                                 || ' from   mtl_item_categories_v  cat'
                                 || ' where  cat.inventory_item_id = dra.inventory_item_id'
                                 || ' and  cat.organization_id = cs_std.get_item_valdn_orgzn_id'
                                 || ' and  cat.category_id = '
                                 || l_rule_condition_rec.attribute2 || ')';
                    end if;

                when 'RO_PROMISE_DATE_THRESHOLD' then
                    l_join_stmt :=  '(dra.promise_date  - sysdate) ' || l_num_condition;
                when 'RO_RESOLVE_BY_DATE_THRESHOLD' then
                    l_join_stmt :=  '(dra.resolve_by_date  - sysdate) ' || l_num_condition;
                when 'RO_EXCHANGE_THRESHOLD' then
                    l_join_stmt :=  'dra.repair_line_id in (select prod.repair_line_id'
                                 || ' from csd_product_txns_v prod'
                                 || ' WHERE prod.action_type = ''' || G_ACTION_TYPE_RMA || ''''
                                 || ' AND prod.action_code = ''' || G_ACTION_CODE_EXCHANGE || ''''
                                 || ' AND nvl(prod.prod_txn_status, '''') <> ''RECEIVED''' -- swai: bug 7524870
                                 || ' AND (prod.return_by_date - sysdate) '
                                 || l_num_condition || ')';
                when 'RO_LOANER_THRESHOLD' then
                    l_join_stmt :=  'dra.repair_line_id in (select prod.repair_line_id'
                                 || ' from csd_product_txns_v prod'
                                 || ' WHERE prod.action_type = ''' || G_ACTION_TYPE_RMA || ''''
                                 || ' AND prod.action_code = ''' || G_ACTION_CODE_LOANER || ''''
                                 || ' AND nvl(prod.prod_txn_status, '''') <> ''RECEIVED''' -- swai: bug 7524870
                                 || ' AND (prod.return_by_date - sysdate) '
                                 || l_num_condition || ')';
                when 'RO_THIRD_PTY_THRESHOLD' then
                    l_join_stmt :=  'dra.repair_line_id in (select prod.repair_line_id'
                                 || ' from csd_product_txns_v prod'
                                 || ' WHERE prod.action_type = ''' || G_ACTION_TYPE_RMA_THIRD_PTY || ''''
                                 || ' AND nvl(prod.prod_txn_status, '''') <> ''RECEIVED''' -- swai: bug 7524870
                                 || ' AND (prod.return_by_date - sysdate) '
                                 || l_num_condition || ')';
                -- swai: bug 7524870 - add new condition
                when 'RO_RMA_CUST_PROD_THRESHOLD' then
                    l_join_stmt :=  'dra.repair_line_id in (select prod.repair_line_id'
                                 || ' from csd_product_txns_v prod'
                                 || ' WHERE prod.action_type = ''' || G_ACTION_TYPE_RMA || ''''
                                 || ' AND prod.action_code = ''' || G_ACTION_CODE_CUST_PROD || ''''
                                 || ' AND nvl(prod.prod_txn_status, '''') <> ''RECEIVED'''
                                 || ' AND (prod.return_by_date - sysdate) '
                                 || l_num_condition || ')';
                -- end swai: bug 7524870
                when 'RO_REPEAT_REPAIR_THRESHOLD' then
                    l_join_stmt :=  'sysdate - ( SELECT   MAX(dra2.date_closed)'
                                             || ' FROM  csd_repairs dra2 '
                                             || ' WHERE dra2.customer_product_id = dra.customer_product_id '
                                             || ' AND      dra2.date_closed IS NOT NULL) '
                                             || l_num_condition;
                when 'RO_CHRONIC_REPAIR_THRESHOLD' then
                    l_join_stmt :=  '(SELECT count(dra2.repair_line_id) '
                                  || ' FROM   csd_repairs dra2 '
                                  || ' WHERE  dra2.customer_product_id = dra.customer_product_id '
                                  || ' AND dra2.date_closed BETWEEN sysdate - '
                                  || ' nvl(FND_PROFILE.VALUE(''CSD_QUALITY_CHECK_PERIOD''), 0) '
                                  || ' AND sysdate) ' || l_num_condition;
                -- bug 7323831 - contract line can expire if either end date or termination date
                -- has passed.  If either date is null, do not consider it as a valid date.
                when 'RO_CONTRACT_EXP_THRESHOLD' then
                    l_join_stmt :=  'dra.contract_line_id in (select okl.id'
                                 || ' from okc_k_lines_b okl'
                                 || ' where  okl.id = dra.contract_line_id'
                                 || ' AND (least(nvl(end_date, date_terminated), nvl(date_terminated, end_date))  - sysdate)'
                                 -- || ' AND (okl.end_date - sysdate) '
                                 || l_num_condition || ')';
            end case;
        end if;

        -- If unsuccessful in building join statement, create one
        -- that will always make this query return no rows
        IF (l_join_stmt is null) THEN
            l_join_stmt := ' 1=0 ';
        END IF;

        -- append the join statement to the existing query
        l_sql_query := l_sql_query || ' AND ' || l_join_stmt;

    END LOOP;

    -- if there were no conditions in the rule, then ensure that the query
    -- returns no rows, since a rule without conditions is not applicable
    -- to any repair order.
    IF (l_condition_count = 0) THEN
        l_sql_query := l_sql_query || ' AND 1=0';
    END IF;

    RETURN l_sql_query;
END GET_RULE_SQL_FOR_RO;



/*--------------------------------------------------------------------*/
/* function name: GET_SQL_OPERATOR                                    */
/* description : Turns the given operator into the corresponding      */
/*               operator symbol used in a sql query                  */
/*                                                                    */
/* Called from : FUNCTION  GET_RULE_SQL_FOR_RO                        */
/* Input Parm  :                                                      */
/*    p_operator      VARCHAR2     Req                                */
/*                                                                    */
/*                                                                    */
/* Return Val :                                                       */
/*    VARCHAR2 - Operator Lookup code from CSD_RULE_OPERATORS         */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_SQL_OPERATOR (
    p_operator IN VARCHAR2
) RETURN VARCHAR2
IS
BEGIN
    CASE P_OPERATOR
        when G_EQUALS then
            return '=';
        when G_NOT_EQUALS then
            return '<>';
        when G_GREATER_THAN then
            return '>';
        when G_LESS_THAN then
            return '<';
        else
            return null;
    END CASE;
END GET_SQL_OPERATOR;

END CSD_RULES_ENGINE_PVT; /* package ends here */

/
