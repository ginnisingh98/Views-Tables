--------------------------------------------------------
--  DDL for Package Body IEM_ROUTE_CLASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ROUTE_CLASS_PUB" AS
/* $Header: iempclsb.pls 120.2 2005/06/23 13:04:09 appldev ship $ */
--
--
-- Purpose: Mantain route classification related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   01/10/2002   fix bug that if the number of rules for a classification is less than
--                          that of classification with higher priority, this classification
--                          is never satisfied. ( No bug logged, shipped with FP-M )
--  Liang Xia   11/18/2002   Added dynamic classification. Shipped in MP-Q ( 11.5.9 )
--  Liang Xia   12/06/2004  Changed for 115.11 schema complaince
--  Liang Xia   06/24/2005  Fixed GSCC sql.46 ( bug 4452895 )
-- ---------   ------  ------------------------------------------

/*GLOBAL VARIABLES FOR PRIVATE USE
  ==================================*/
  G_PKG_NAME    VARCHAR2(100):= 'IEM_ROUTE_CLASS_PUB';

  --The record type for passing rules
  TYPE Rules_rec_type is RECORD (
    key      iem_route_rules.key_type_code%type,
    operator iem_route_rules.operator_type_code%type,
    value    iem_route_rules.value%type);

  --The table type for passing rules
  TYPE Rules_tbl_type IS table of Rules_rec_type INDEX BY BINARY_INTEGER;



  /* PRIVATE PROCEDURES NOT AVAILABLE TO THE PUBLIC
  ================================================*/

  /* Evaluate And conditions */
  PROCEDURE evaluateAnd(keyVals IN iem_route_pub.keyVals_tbl_type, rules IN Rules_tbl_type, fireClass OUT NOCOPY Boolean)
    IS

  x number := 1;
  y number := 1;

  keyToFind iem_route_class_rules.key_type_code%type;
  operator iem_route_class_rules.operator_type_code%type;
  valueToFind iem_route_class_rules.value%type;

  foundKey Boolean;
  foundKeyValue Boolean;

  numberOfKeys  Number;
  numberOfRules Number;

  errorMessage varchar2(2000);

  Begin


       numberOfKeys := keyVals.count;
       numberofRules := rules.count;

       --Evaluate each rule one at a time
       while x <= numberOfRules loop

        --Copy the rule into temp variables to save repetitive calls to the UDT
        keyToFind := rules(x).key;
        valueToFind := rules(x).value;
        operator := rules(x).operator;

        y := 1;
        foundKey := false;
        foundKeyValue := false;

        --Search through all the keys that got passed in
        while y <= numberOfKeys loop

          --Make the key comparison
          if keyToFind = keyVals(y).key then
                foundKey := true;

                --If the key is found then see if the value matches up based on the operator
                if iem_operators_pvt.satisfied(keyVals(y).value, operator, valueToFind, keyVals(y).datatype) then
                    foundKeyValue := true;
                end if;
                --Exit since we found what we wanted
                EXIT;
           end if;

         y := y + 1;
         end loop;

        --If we were unable to find the key or the value then exit since this is AND chaining
        if (foundKey = false or foundKeyValue = false) then
            fireClass := false;
            EXIT;
        else
            fireClass := true;
        end if;

       x := x + 1;
       end loop;

    EXCEPTION
        When others then

		if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Others';
	       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.EVALUATEAND.OTHERS', errorMessage);
		end if;

  End evaluateAnd;


  /* Evaluate OR conditions */
  PROCEDURE evaluateOr(keyVals IN iem_route_pub.keyVals_tbl_type, rules IN Rules_tbl_type, fireClass OUT NOCOPY Boolean)
    IS

  x number := 1;
  y number := 1;

  keyToFind iem_route_class_rules.key_type_code%type;
  operator iem_route_class_rules.operator_type_code%type;
  valueToFind iem_route_class_rules.value%type;

  foundKeyValue Boolean;

  numberOfKeys  Number;
  numberOfRules Number;

  errorMessage varchar2(2000);

  Begin

       numberOfKeys := keyVals.count;
       numberofRules := rules.count;

       --Evaluate each rule one at a time
       while x <= numberOfRules loop

       --Copy the rule into temp variables to save repetitive calls to the UDT
        keyToFind := rules(x).key;
        valueToFind := rules(x).value;
        operator := rules(x).operator;

        y := 1;
        foundKeyValue := false;

        --Search through all the keys that got passed in
        while y <= numberOfKeys loop

          --Make the key comparison case insensitive
          if upper(keyToFind) = upper(keyVals(y).key) then
                --If the key is found then see if the value matches up based on the operator
                if iem_operators_pvt.satisfied(keyVals(y).value, operator, valueToFind, keyVals(y).datatype) then
                    foundKeyValue := true;
                end if;
                --Exit since we found what we wanted
                EXIT;
           end if;

         y := y + 1;
         end loop;

        --If we found a key value pair then exit since this is OR chaining
        if foundKeyValue then
            fireClass := true;
            EXIT;
        else
            fireClass := false;
        end if;

       x := x + 1;
       end loop;

    EXCEPTION
        When others then
		if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        	errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Others';
	    	FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.EVALUATEOR.OTHERS', errorMessage);
		end if;
  End evaluateOr;

PROCEDURE classify(
  p_api_version_number  IN Number,
  p_init_msg_list       IN VARCHAR2 := NULL,
  p_commit              IN VARCHAR2 := NULL,
  p_keyVals_tbl         IN IEM_ROUTE_PUB.keyVals_tbl_type,
  p_accountId           IN Number,
  x_classificationId    OUT NOCOPY Number,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2)

IS
  l_api_version_number      CONSTANT    NUMBER:= 1.0;
  l_api_name                CONSTANT    VARCHAR2(30):= 'Classify';


  --The active classifications in the system
  cursor c_classifications (p_enabled_flag iem_account_route_class.enabled_flag%type,
   p_account_id iem_mstemail_accounts.email_account_id%type)
  is
  select
    a.route_classification_id,
    a.procedure_name,
    a.boolean_type_code
  from
    iem_route_classifications a,
    iem_account_route_class b
  where
    a.route_classification_id = b.route_classification_id
  and
    b.enabled_flag = p_enabled_flag
  and
    b.email_account_id = p_account_id
  and
    a.route_classification_id <> 0
  order by b.priority;

  --All the rules for a classification
  cursor c_rules (p_route_classification_id iem_route_classifications.route_classification_id%type)
   is
  select
    key_type_code,
    operator_type_code,
    value
  from
    iem_route_class_rules
  where
    route_classification_id = p_route_classification_id;


  x number:= 1;
  ruleHold Rules_tbl_type;
  classSatisfied Boolean := false;
  enabledFlag varchar(1):= 'Y';
  booleanTypeCode iem_route_classifications.boolean_type_code%type;

  runTimekeyVals_tbl IEM_ROUTE_PUB.keyVals_tbl_type;
  procedureName   iem_route_classifications.procedure_name%type;
  returnParamType   iem_route_class_rules.key_type_code%type;
  runTimeSuccess    Boolean := true;

  l_result          VARCHAR2(256);
  l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);

  l_log_enabled  BOOLEAN := false;
  l_exception_log BOOLEAN := false;
  logMessage varchar2(2000);
  errorMessage varchar2(2000);

   BEGIN

   --Standard begin of API savepoint
   SAVEPOINT    Classify_PUB;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(
                    l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --=================--
   -- Begining of API --
   --=================--
    FND_LOG_REPOSITORY.init(null,null);


	l_log_enabled := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

	l_exception_log :=  FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

    if l_log_enabled then
        logMessage := '[p_account_id=' || to_char(p_accountid) || ']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.ROUTE.START', logMessage);
    end if;


   --Initialize group to 0
   x_classificationId := 0;

   --Iniitalize the Rule data structure
   --ruleHold.delete;

   --Check to see if the passed in PL/SQL table has valid key-vals
   If p_keyVals_tbl.count > 0 then

    if l_log_enabled then
        logMessage := '[p_keyValsCount=' || to_char(p_keyVals_tbl.count) || ']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.ROUTE.KEY_VALS_MORE_THAN_0', logMessage);
    end if;


       --Get all the active routes in the system
       For v_classifications in c_classifications (enabledFlag, p_accountId) Loop

             --The boolean operator for the rule chaining
             booleanTypeCode := v_classifications.boolean_type_code;
             procedureName := v_classifications.procedure_name;

             --Iniitalize the Rule data structure
             ruleHold.delete;
	         x := 1;
             -- Identify classification type
             IF ( booleanTypeCode = 'DYNAMIC' ) THEN
                    if l_log_enabled then
            		logMessage := '[DYNAMIC procedure_name='||procedureName|| ']';
    		        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.DYNAMIC_CLASS', logMessage);
    		        end if;

                 runTimekeyVals_tbl.delete;
                 runTimeSuccess := true;

                 --Get rules for the dynamic route and load it into the data structure
                 For v_rules in c_rules(v_classifications.route_classification_id) Loop
                    returnParamType:= v_rules.key_type_code;

                    -- begin PROCEDURE processing
                    BEGIN
                        IEM_ROUTE_RUN_PROC_PVT.run_Procedure(
                                    p_api_version_number    =>P_Api_Version_Number,
                                    p_init_msg_list         => FND_API.G_FALSE,
                                    p_commit                => FND_API.G_FALSE,--P_Commit,
                                    p_procedure_name        => procedureName,
                                    p_key_value             => p_keyVals_tbl,
                                    p_param_type            => returnParamType,
                                    x_result                => l_result,
                                    x_return_status         => l_return_status,
                                    x_msg_count             => l_msg_count,
                                    x_msg_data              => l_msg_data);

                        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                            if l_log_enabled then
                                logMessage := '[ERROR when execute procedure for RouteID: '||v_classifications.route_classification_id ||']';
                                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.DYNAMIC_CLASS', logMessage);
                            end if;
                            runTimeSuccess := false;
                        else
                            -- Insert data in key-value pair table
                            if returnParamType = 'IEMNNUMBER' then
                                runTimekeyVals_tbl(x).key := 'IEMNDYNROUTERETURNVAL';
                                runTimekeyVals_tbl(x).value := l_result;
                                runTimekeyVals_tbl(x).datatype := 'N';
                            elsif  returnParamType = 'IEMSVARCHAR2' then
                                runTimekeyVals_tbl(x).key := 'IEMSDYNROUTERETURNVAL';
                                runTimekeyVals_tbl(x).value := l_result;
                                runTimekeyVals_tbl(x).datatype := 'S';
                            end if;

                            if l_log_enabled then
            		          logMessage := '[DYNAMIC ROUTE RETURNED VALUE =' || l_result || ']';
    		                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.DYNAMIC_CLASS', logMessage);
    		                end if;
                        end if;
                     EXCEPTION
                  	     WHEN OTHERS THEN
                            runTimeSuccess := false;
                            if l_log_enabled then
                                logMessage := '[ERROR (Others) when execute procedure for keyId: '||v_classifications.route_classification_id ||'. error:'||sqlerrm||']';
                                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.DYNAMIC_CLASS', logMessage);
                            end if;
                     END; -- end of PROCEDURE processing

                    -- Exit when run procedure failed
                    if runTimeSuccess then
                      if returnParamType = 'IEMNNUMBER' then
                          ruleHold(x).key := 'IEMNDYNROUTERETURNVAL';
                      elsif  returnParamType = 'IEMSVARCHAR2' then
                          ruleHold(x).key := 'IEMSDYNROUTERETURNVAL';
                      end if;


                      ruleHold(x).operator := v_rules.operator_type_code;
                      ruleHold(x).value := v_rules.value;

                      if l_log_enabled then
              		    logMessage := '[DYNAMIC ROUTE' || ruleHold(x).key || ruleHold(x).operator || ruleHold(x).value || ']';
      		            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.DYNAMIC_CLASS', logMessage);
      		          end if;
                    else
                        exit;
                    end if;

                    x := x + 1;
                 End Loop;

                 --Depending on the operator call different evaluation functions
                 if runTimeSuccess then
                    evaluateAnd(runTimekeyVals_tbl, ruleHold, classSatisfied);
                 else
                    classSatisfied := false;
                 end if;

                if classSatisfied then
                    x_classificationId := v_classifications.route_classification_id;
                    EXIT;
                end if;


             ELSIF ( booleanTypeCode = 'AND' ) or ( booleanTypeCode = 'OR') THEN
             --Get all the rules for the route and load it into the data structure
             For v_rules in c_rules(v_classifications.route_classification_id) Loop
                ruleHold(x).key := v_rules.key_type_code;
                ruleHold(x).operator := v_rules.operator_type_code;
                ruleHold(x).value := v_rules.value;

                if l_log_enabled then
        		  logMessage := '[' || ruleHold(x).key || ruleHold(x).operator || ruleHold(x).value || ']';
		          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.CLASSIFY.RULES', logMessage);
		        end if;


                x := x + 1;
             End Loop;


             --Depending on the operator call different evaluation functions
             if booleanTypeCode = 'AND' then
                 evaluateAnd(p_keyVals_tbl, ruleHold, classSatisfied);
             elsif booleanTypeCode = 'OR' then
                 evaluateOr(p_keyVals_tbl, ruleHold, classSatisfied);
             end if;


              --If the rules got satisfied then check if group is valid
              if classSatisfied then
                    x_classificationId := v_classifications.route_classification_id;
                    EXIT;
              end if;
            END IF; -- end if boolean_type is Dynamic
       End Loop;

   End if;
   --==========--
   --End of API--
   --==========--

   --Standard check of p_commit
   If FND_API.To_Boolean(p_commit) then
        COMMIT WORK;
   End if;

   --Standard call to get message count and if count is 1 then get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          Rollback to Classify_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
		  if l_exception_log then
          	 errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Execution Error';
	      	 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.ROUTE.EXEC_ERROR', errorMessage);
		  end if;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Rollback to Classify_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
		  if l_exception_log then
          	 errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Unexpected Execution Error';
			 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.ROUTE.UNEXP_EXEC_ERROR', errorMessage);
		  end if;
     WHEN OTHERS THEN
          Rollback to Classify_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF fnd_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

		  if l_exception_log then
          	 errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Others';
	      	 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_CLASS_PUB.ROUTE.OTHERS', errorMessage);
		  end if;



END;

END IEM_ROUTE_CLASS_PUB;

/
