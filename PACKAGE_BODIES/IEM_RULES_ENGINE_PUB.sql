--------------------------------------------------------
--  DDL for Package Body IEM_RULES_ENGINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_RULES_ENGINE_PUB" AS
/* $Header: iemprulb.pls 120.5.12010000.3 2009/07/23 23:40:40 siahmed ship $ */
--
--
-- Purpose: Email Processing Engine to process emails based on the rules
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   06/10/2002   Create
--  Liang Xia   12/04/2002   Fixed GSCC warning: NOCOPY,No G_MISS..
--  Liang Xia   07/06/2003   Added Document Mapping validation
--  Liang Xia   08/17/2003   Added Auto-Redirect rule type
--  Liang Xia   09/24/2003   Added extra validation on AUTOACKNOWLEDGE,
--                           AUTOREPLYSPECDOC to check if the document is exist
--  Liang Xia   08/16/2004   Appending Rule_id for Document Retrieval to retrieval result later.( 11.5.10)
--  Liang Xia   04/06/2005   Fixed GSCC sql.46 ( bug 4256769 )
--  Liang Xia   06/24/2005   Fixed GSCC sql.46 ( bug 4452895 )
--  PKESANI     02/22/2006   ACSR project - code fix
--  lkullamb    07/13/2009   added parameter3 column to iem_action_dtls table, hence the procedure changed
--                           auto_process_email
-- ---------   ------  ------------------------------------------

/*GLOBAL VARIABLES FOR PRIVATE USE
  ==================================*/
  G_PKG_NAME    VARCHAR2(100):= 'IEM_RULES_ENGINE_PUB';

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
	    	FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.EVALUATEAND.OTHERS', errorMessage);
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
	    	FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.EVALUATEOR.OTHERS', errorMessage);
		end if;

  End evaluateOr;


 PROCEDURE auto_process_email(
  p_api_version_number  IN Number,
  p_init_msg_list       IN VARCHAR2 := null,
  p_commit              IN VARCHAR2 := null,
  p_rule_type           IN VARCHAR2,
  p_keyVals_tbl         IN IEM_ROUTE_PUB.keyVals_tbl_type,
  p_accountId           IN Number,
  x_result              OUT NOCOPY VARCHAR2,
  x_action              OUT NOCOPY Varchar2,
  x_parameters          OUT NOCOPY IEM_RULES_ENGINE_PUB.parameter_tbl_type,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2)

IS

  l_api_version_number      CONSTANT    NUMBER:= 1.0;
  l_api_name                CONSTANT    VARCHAR2(30):= 'auto_process_email';

  x number:= 1;
  y number:= 1;
  ruleHold Rules_tbl_type;
  satisfied Boolean := false;
  l_action  VARCHAR2(30);
  enabledFlag varchar(1):= 'Y';
  booleanTypeCode iem_emailprocs.boolean_type_code%type;

  l_module VARCHAR2(30);
  l_emailproc_id NUMBER;
  L_SERVICE_REQUEST_ID VARCHAR2(30);
  l_doc_total NUMBER;
  l_doc_exist_auto_reply boolean := true;

  logMessage varchar2(2000);
  errorMessage varchar2(2000);

  l_log_enabled  BOOLEAN := false;
  l_exception_log BOOLEAN := false;
  l_encrypted_id  NUMBER;
  l_subject       varchar2(256);

  IEM_UNKNOWN_RULE_TYPE_EXP EXCEPTION;

  --The active emailprocs for auto_acknowledge in the system
  cursor c_auto_processings (p_enabled_flag iem_account_emailprocs.enabled_flag%type,
   p_account_id iem_email_accounts.email_account_id%type,
   p_rule_type iem_emailprocs.rule_type%type)
  is
  select
    a.emailproc_id,
    a.boolean_type_code,
    a.all_email
  from
    iem_emailprocs a,
    iem_account_emailprocs b
  where
    a.emailproc_id = b.emailproc_id
  and
    a.rule_type = p_rule_type
  and
    b.enabled_flag = p_enabled_flag
  and
    b.email_account_id = p_account_id
--  and
--    a.emailproc_id <> 0
  order by b.priority;

  --All the rules for a classification
  cursor c_rules (p_emailproc_id iem_emailprocs.emailproc_id%type)
   is
  select
    key_type_code,
    operator_type_code,
    value
  from
    iem_emailproc_rules
  where
    emailproc_id = p_emailproc_id;

  --Get parameter(s)
  cursor c_params(p_emailproc_id iem_emailprocs.emailproc_id%type)
  is
  select b.parameter1, b.parameter2,b.parameter3, b.parameter_tag
  from iem_actions a, iem_action_dtls b
  where a.action_id = b.action_id and a.emailproc_id = p_emailproc_id;

  --Verify that there are document under category for Document Mapping
   BEGIN

   --Standard begin of API savepoint
   SAVEPOINT    Auto_Process_Email_PUB;

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

	l_log_enabled :=  FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;


	l_exception_log := FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;


    IF (p_rule_type = 'AUTODELETE' ) THEN
        l_module := 'AUTODELETE';
    ELSIF (p_rule_type = 'AUTOACKNOWLEDGE' ) THEN
        l_module := 'AUTOACKNOWLEDGE';
    ELSIF (p_rule_type = 'AUTOPROCESSING' ) THEN
        l_module := 'AUTOPROCESSING';
    ELSIF (p_rule_type = 'AUTOREDIRECT' ) THEN
        l_module := 'AUTOREDIRECT';
    ELSIF (p_rule_type = 'AUTORRRS' ) THEN
        l_module := 'AUTORRRS';
    ELSIF (p_rule_type = 'DOCUMENTRETRIEVAL' ) THEN
        l_module := 'DOCUMENTRETRIEVAL';
    ELSE
        if l_log_enabled then
            logMessage := '[Error unknown RuleType: p_rule_type= ' || p_rule_type || ' p_account_id=' || to_char(p_accountid) || ']';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.START', logMessage);
        end if;

        raise IEM_UNKNOWN_RULE_TYPE_EXP;
    END IF;

    if l_log_enabled then
        logMessage := '[p_rule_type= ' || p_rule_type || ' p_account_id=' || to_char(p_accountid) || ']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.START', logMessage);
    end if;


   --Initialize x_result to fals
   x_result := FND_API.G_FALSE;

   --Iniitalize the Rule data structure
   --ruleHold.delete;


   --Check to see if the passed in PL/SQL table has valid key-vals
   If p_keyVals_tbl.count > 0 then

    if l_log_enabled then
        logMessage := '[p_keyValsCount=' || to_char(p_keyVals_tbl.count) || ']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.KEY_VALS_MORE_THAN_0', logMessage);
    end if;


       --Get all the active routes in the system
       For v_emailprocs in c_auto_processings (enabledFlag, p_accountId, p_rule_type) Loop

            --Reset local variables for each rule
            l_doc_exist_auto_reply := true;

            --Check 'All Emails' is set or not. If set, return result without evaluate rules
            IF v_emailprocs.all_email = 'Y' THEN
                    --Get action name. Currently one rule type corresponding to one action
                    select action into l_action from iem_actions where emailproc_id =  v_emailprocs.emailproc_id;

--- PK
	      if l_action = 'AUTOCREATESR' then

		   --Check if Tag exists
                      l_subject := IEM_ROUTE_PUB.get_key_value
                                ( p_keyVals_tbl=>p_keyVals_tbl,
                                  p_key_name=>'IEMSSUBJECT');

		      IEM_EMAIL_PROC_PVT.IEM_RETURN_ENCRYPTID
			    (p_subject=>l_subject,
			     x_id=>l_encrypted_id,
			     x_Status=>x_return_status);

		   if l_encrypted_id is NULL then
			    x_action := l_action;
                            --Get parameters
                            y := 1;
                            l_emailproc_id := v_emailprocs.emailproc_id;
                            For v_params in c_params(l_emailproc_id) Loop
                                x_parameters(y).parameter1 := v_params.parameter1;
                                x_parameters(y).parameter2 := v_params.parameter2;
                                x_parameters(y).parameter3 := v_params.parameter3;
                                x_parameters(y).type := v_params.parameter_tag;

                                if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 ||'parameter3='|| v_params.parameter3 || ']';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
	                        end if;
                                y := y + 1;
                            End Loop;

                            x_result :=  FND_API.G_TRUE;
                            exit;

                        else    --Action is AutoCreateSR, but TAG exists
                            if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||'. But TAG exists . So continue eval next rule.';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		            end if;
                   end if;
                    --Check if SR id is null or not
                   elsif l_action = 'UPDSERVICEREQID' then
                        l_service_request_id := IEM_ROUTE_PUB.get_key_value
                                                    (   p_keyVals_tbl=>p_keyVals_tbl,
                                                        p_key_name=>'IEMNBZTSRVSRID');

                        if is_valid( l_service_request_id )= FND_API.G_TRUE then

                            x_action := l_action;
                            --Get parameter for template_id
                            y := 1;
                            l_emailproc_id := v_emailprocs.emailproc_id;
                            For v_params in c_params(l_emailproc_id) Loop
                                x_parameters(y).parameter1 := v_params.parameter1;
                                x_parameters(y).parameter2 := v_params.parameter2;
				x_parameters(y).parameter3 := v_params.parameter3;
                                x_parameters(y).type := v_params.parameter_tag;

                                if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 || ']';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                        end if;
                                y := y + 1;
                            End Loop;

                            x_result :=  FND_API.G_TRUE;
                            exit;
                        --Action is UpdateSR, but no valid SR_id
                        else
                            if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||'. But ServiceRequest ID is null. So continue eval next rule.';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                    end if;
                        end if;

                    else -- Action <> 'UPDSERVICEREQID'
                        x_action := l_action;
                        y := 1;
                        l_emailproc_id := v_emailprocs.emailproc_id;

                        x_parameters.delete;
                        For v_params in c_params(l_emailproc_id) Loop
                            x_parameters(y).parameter1 := v_params.parameter1;
                            x_parameters(y).parameter2 := v_params.parameter2;
			    x_parameters(y).parameter3 := v_params.parameter3;
                            x_parameters(y).type := v_params.parameter_tag;

                            if l_log_enabled then
                                logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 || ']';
		                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                    end if;
                            y := y + 1;
                        End Loop;

                        -- For bug 3809733, to return Emailproc_id ( to be stored in iem_post_mdts.category_map_id. exmple:if return 123, store as -123)
                        -- so that corresponding Category_IDs could be used later
                        if l_module = 'DOCUMENTRETRIEVAL' then
                                x_parameters(y).parameter1 := 'RULE_ID';
                                x_parameters(y).parameter2 := l_emailproc_id;
                        end if;

                        --Verify if there is document under category for DOCUMENT MAPPING
                        --If not, continue next rule evaluation.
                        if l_action = 'MES_CATEGORY_MAPPING' then
                            l_doc_total := get_document_total(x_parameters(1).parameter1);
                            if (l_doc_total > 0 ) then
                                --exit with correct result
                                 x_result :=  FND_API.G_TRUE;
                                exit;
                            end if;
                        elsif l_action = 'AUTOACKNOWLEDGE' then
                            if is_document_exist( x_parameters(1).parameter1,x_parameters(1).parameter2  )= FND_API.G_TRUE then
                                x_result :=  FND_API.G_TRUE;
                                exit;
                            end if;
                        elsif l_action='AUTOREPLYSPECIFIEDDOC' then
                           FOR m IN x_parameters.FIRST..x_parameters.LAST   loop
                              if is_document_exist( x_parameters(m).parameter1,x_parameters(m).parameter2 )= FND_API.G_FALSE then
                                l_doc_exist_auto_reply := false;
                                exit;
                              end if;
                           end loop;

                           if l_doc_exist_auto_reply then
                                x_result :=  FND_API.G_TRUE;
                                exit;
                           end if;
                        else --NO validation on other action, so result is true, return parameters
                            x_result :=  FND_API.G_TRUE;
                            exit;
                        end if; --end if l_action = 'MES_CATEGORY_MAPPING'

                    end if;  --end if l_action = 'UPDSERVICEREQID'
             ELSE
           -- END IF; --v_emailprocs.all_email = 'Y'

             --The boolean operator for the rule chaining
             booleanTypeCode := v_emailprocs.boolean_type_code;

             --Iniitalize the Rule data structure
             ruleHold.delete;
	         x := 1;

             --Get all the rules for the route and load it into the data structure
             For v_rules in c_rules(v_emailprocs.emailproc_id) Loop

                ruleHold(x).key := v_rules.key_type_code;
                ruleHold(x).operator := v_rules.operator_type_code;
                ruleHold(x).value := v_rules.value;

                if l_log_enabled then
        		  logMessage := '[' || ruleHold(x).key || ruleHold(x).operator || ruleHold(x).value || ']';
		          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.RULES', logMessage);
		        end if;


                x := x + 1;
             End Loop;


             --Depending on the operator call different evaluation functions
             if booleanTypeCode = 'AND' then
                 evaluateAnd(p_keyVals_tbl, ruleHold, satisfied);
             elsif booleanTypeCode = 'OR' then
                 evaluateOr(p_keyVals_tbl, ruleHold, satisfied);
             end if;


              --If the rules got satisfied then return result
              if satisfied then

                    --Get action name. Currently one rule type corresponding to one action
                    select action into l_action from iem_actions where emailproc_id =  v_emailprocs.emailproc_id;

--- PK
	      if l_action = 'AUTOCREATESR' then

		   --Check if Tag exists
                      l_subject := IEM_ROUTE_PUB.get_key_value
                                ( p_keyVals_tbl=>p_keyVals_tbl,
                                  p_key_name=>'IEMSSUBJECT');

		      IEM_EMAIL_PROC_PVT.IEM_RETURN_ENCRYPTID
			    (p_subject=>l_subject,
			     x_id=>l_encrypted_id,
			     x_Status=>x_return_status);

		   if l_encrypted_id is NULL then
			    x_action := l_action;
                            --Get parameters
                            y := 1;
                            l_emailproc_id := v_emailprocs.emailproc_id;
                            For v_params in c_params(l_emailproc_id) Loop
                                x_parameters(y).parameter1 := v_params.parameter1;
                                x_parameters(y).parameter2 := v_params.parameter2;
				x_parameters(y).parameter3 := v_params.parameter3;
                                x_parameters(y).type := v_params.parameter_tag;

                                if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 || ']';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
	                        end if;
                                y := y + 1;
                            End Loop;

                            x_result :=  FND_API.G_TRUE;
                            exit;

                        else    --Action is AutoCreateSR, but TAG exists
                            if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||'. But TAG exists . So continue eval next rule.';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		            end if;
                   end if;
	    --  end if;  -- AUTOCREATESR  commented by Ranjan

                    --Check if SR id is null or not
                    elsif l_action = 'UPDSERVICEREQID' then		-- convert if to elsif by ranjan
                        l_service_request_id := IEM_ROUTE_PUB.get_key_value
                                                    (   p_keyVals_tbl=>p_keyVals_tbl,
                                                        p_key_name=>'IEMNBZTSRVSRID');

                        if is_valid( l_service_request_id )= FND_API.G_TRUE then

                            x_action := l_action;
                            --Get parameter for template_id
                            y := 1;
                            l_emailproc_id := v_emailprocs.emailproc_id;
                            For v_params in c_params(l_emailproc_id) Loop
                                x_parameters(y).parameter1 := v_params.parameter1;
                                x_parameters(y).parameter2 := v_params.parameter2;
				x_parameters(y).parameter3 := v_params.parameter3;
                                x_parameters(y).type := v_params.parameter_tag;

                                if l_log_enabled then
        		                    logMessage := '[Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 || ']';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                        end if;
                                y := y + 1;
                            End Loop;

                            x_result :=  FND_API.G_TRUE;
                            exit;
                        else
                            if l_log_enabled then
        		                    logMessage := '[Rule satisfied for Emailproc_id=' || l_emailproc_id || ' action='||l_action||'. But ServiceRequest ID is null. So continue eval next rule.';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                    end if;
                        end if;
                    --Getting parameter, then do validation on particular action
                    else

                        x_action := l_action;
                        --Get parameter for template_id
                        y := 1;
                        l_emailproc_id := v_emailprocs.emailproc_id;
                        For v_params in c_params(l_emailproc_id) Loop
                            x_parameters(y).parameter1 := v_params.parameter1;
                            x_parameters(y).parameter2 := v_params.parameter2;
			    x_parameters(y).parameter3 := v_params.parameter3;
                            x_parameters(y).type := v_params.parameter_tag;

                            if l_log_enabled then
        		              logMessage := '[Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 || ']';
		                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                    end if;
                            y := y + 1;
                        End Loop;

                        -- For bug 3809733, to return Emailproc_id ( to be stored in iem_post_mdts.category_map_id. exmple:if return 123, store as -123)
                        -- so that corresponding Category_IDs could be used later
                        if l_module = 'DOCUMENTRETRIEVAL' then
                                x_parameters(y).parameter1 := 'RULE_ID';
                                x_parameters(y).parameter2 := l_emailproc_id;
                        end if;

                        --Verify if there is document under category for DOCUMENT MAPPING
                        --If not, continue next rule evaluation.
                        if l_action = 'MES_CATEGORY_MAPPING' then
                            l_doc_total := get_document_total(x_parameters(1).parameter1);
                            if (l_doc_total > 0 ) then
                                --exit with correct result
                                 x_result :=  FND_API.G_TRUE;
                                exit;
                            end if;
                        elsif l_action = 'AUTOACKNOWLEDGE' then
                            if is_document_exist( x_parameters(1).parameter1,x_parameters(1).parameter2  )= FND_API.G_TRUE then
                                x_result :=  FND_API.G_TRUE;
                                exit;
                            end if;
                        elsif l_action='AUTOREPLYSPECIFIEDDOC' then
                           FOR m IN x_parameters.FIRST..x_parameters.LAST   loop
                              if is_document_exist( x_parameters(m).parameter1,x_parameters(m).parameter2 )= FND_API.G_FALSE then
                                l_doc_exist_auto_reply := false;
                                exit;
                              end if;
                           end loop;

                           if ( l_doc_exist_auto_reply ) then
                                x_result :=  FND_API.G_TRUE;
                                exit;
                           end if;
                        else --NO validation on other action, so result is true, return parameters
                            x_result :=  FND_API.G_TRUE;
                            exit;
                        end if; --end if l_action = 'MES_CATEGORY_MAPPING'


                    end if;

              end if; --end of if satisfied
          END IF; --end of All_email is checked
       End Loop;
   Else --in case no key-value passed in, still check if all_email is set to 'Y'. If yes, processing correspondingly
       --Get all the active emailprocs in the system
       For v_emailprocs in c_auto_processings (enabledFlag, p_accountId, p_rule_type) Loop

            --Check 'All Emails' is set or not. If set, return result without evaluate rules
            IF v_emailprocs.all_email = 'Y' THEN
                    --Get action name. Currently one rule type corresponding to one action
                    select action into l_action from iem_actions where emailproc_id =  v_emailprocs.emailproc_id;

--- PK
	      if l_action = 'AUTOCREATESR' then

		   --Check if Tag exists
                      l_subject := IEM_ROUTE_PUB.get_key_value
                                ( p_keyVals_tbl=>p_keyVals_tbl,
                                  p_key_name=>'IEMSSUBJECT');

		      IEM_EMAIL_PROC_PVT.IEM_RETURN_ENCRYPTID
			    (p_subject=>l_subject,
			     x_id=>l_encrypted_id,
			     x_Status=>x_return_status);

		   if l_encrypted_id is NULL then
			    x_action := l_action;
                            --Get parameters
                            y := 1;
                            l_emailproc_id := v_emailprocs.emailproc_id;
                            For v_params in c_params(l_emailproc_id) Loop
                                x_parameters(y).parameter1 := v_params.parameter1;
                                x_parameters(y).parameter2 := v_params.parameter2;
				x_parameters(y).parameter3 := v_params.parameter3;
                                x_parameters(y).type := v_params.parameter_tag;

                                if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 || ']';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
	                        end if;
                                y := y + 1;
                            End Loop;

                            x_result :=  FND_API.G_TRUE;
                            exit;

                        else    --Action is AutoCreateSR, but TAG exists
                            if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||'. But TAG exists . So continue eval next rule.';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		            end if;
                   end if;

                   --Check if SR id is null or not
                   elsif l_action = 'UPDSERVICEREQID' then
                        l_service_request_id := IEM_ROUTE_PUB.get_key_value
                                                    (   p_keyVals_tbl=>p_keyVals_tbl,
                                                        p_key_name=>'IEMNBZTSRVSRID');

                        if is_valid( l_service_request_id )= FND_API.G_TRUE then

                            x_action := l_action;
                            --Get parameter for template_id
                            y := 1;
                            l_emailproc_id := v_emailprocs.emailproc_id;
                            For v_params in c_params(l_emailproc_id) Loop
                                x_parameters(y).parameter1 := v_params.parameter1;
                                x_parameters(y).parameter2 := v_params.parameter2;
				x_parameters(y).parameter3 := v_params.parameter3;
                                x_parameters(y).type := v_params.parameter_tag;

                                if l_log_enabled then
        		                    logMessage := '[No key-val passed in but ALL Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 || ']';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                        end if;
                                y := y + 1;
                            End Loop;

                            x_result :=  FND_API.G_TRUE;
                            exit;
                        --Action is UpdateSR, but no valid SR_id
                        else
                            if l_log_enabled then
        		                    logMessage := '[All Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||'. But ServiceRequest ID is null. So continue eval next rule.';
		                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                    end if;
                        end if;
                    else
                    --Getting parameter, then do validation on particular action
                        x_action := l_action;
                        y := 1;
                        l_emailproc_id := v_emailprocs.emailproc_id;

                        x_parameters.delete;
                        For v_params in c_params(l_emailproc_id) Loop
                            x_parameters(y).parameter1 := v_params.parameter1;
                            x_parameters(y).parameter2 := v_params.parameter2;
			    x_parameters(y).parameter3 := v_params.parameter3;
                            x_parameters(y).type := v_params.parameter_tag;

                            if l_log_enabled then
                                logMessage := '[No key-val passed in but ALL Email is set! Emailproc_id=' || l_emailproc_id || ' action='||l_action||' parameter1='|| v_params.parameter1 ||' parameter2='|| v_params.parameter2 || ']';
		                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.'||l_module||'.PARAMS', logMessage);
		                    end if;
                            y := y + 1;
                        End Loop;

                        -- For bug 3809733, to return Emailproc_id ( to be stored in iem_post_mdts.category_map_id. exmple:if return 123, store as -123)
                        -- so that corresponding Category_IDs could be used later
                        if l_module = 'DOCUMENTRETRIEVAL' then
                                x_parameters(y).parameter1 := 'RULE_ID';
                                x_parameters(y).parameter2 := l_emailproc_id;
                        end if;

                        --Verify if there is document under category for DOCUMENT MAPPING
                        --If not, continue next rule evaluation.
                        if l_action = 'MES_CATEGORY_MAPPING' then
                            l_doc_total := get_document_total(x_parameters(1).parameter1);
                            if (l_doc_total > 0 ) then
                                --exit with correct result
                                 x_result :=  FND_API.G_TRUE;
                                exit;
                            end if;
                        elsif l_action = 'AUTOACKNOWLEDGE' then
                            if is_document_exist( x_parameters(1).parameter1,x_parameters(1).parameter2  )= FND_API.G_TRUE then
                                x_result :=  FND_API.G_TRUE;
                                exit;
                            end if;
                        elsif l_action='AUTOREPLYSPECIFIEDDOC' then
                           FOR m IN x_parameters.FIRST..x_parameters.LAST   loop
                              if is_document_exist( x_parameters(m).parameter1,x_parameters(m).parameter2 )= FND_API.G_FALSE then
                                l_doc_exist_auto_reply := false;
                                exit;
                              end if;
                           end loop;

                           if l_doc_exist_auto_reply then
                                x_result :=  FND_API.G_TRUE;
                                exit;
                           end if;
                        else --NO validation on other action, so result is true, return parameters
                            x_result :=  FND_API.G_TRUE;
                            exit;
                        end if; --end if l_action = 'MES_CATEGORY_MAPPING'


                    end if;  --end if l_action = 'UPDSERVICEREQID'
            END IF; --v_emailprocs.all_email = 'Y'

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
       when NO_DATA_FOUND THEN
          Rollback to Auto_Process_Email_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('IEM','IEM_NO_ACTION');
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

		  if l_exception_log then
          	 errorMessage := '[There is no action in iem_actions corresponding to the email_proc_id' ||l_emailproc_id||']' ;
	      	 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL', errorMessage);
		  end if;

       WHEN IEM_UNKNOWN_RULE_TYPE_EXP THEN
          Rollback to Auto_Process_Email_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('IEM','IEM_UNKNOWN_RULE_TYPE_EXP');
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

		  if l_exception_log then
          	 errorMessage := '[Unknown Rule type... p_rule_type=' || p_rule_type ||']' ;
	      	 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL', errorMessage);
		  end if;

      WHEN FND_API.G_EXC_ERROR THEN
          Rollback to Auto_Process_Email_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

		  if l_exception_log then
          	 errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Execution Error';
	      	 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.EXEC_ERROR', errorMessage);
		  end if;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Rollback to Auto_Process_Email_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

		  if l_exception_log then
          	 errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Unexpected Execution Error';
	      	 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.UNEXP_EXEC_ERROR', errorMessage);
		  end if;

     WHEN OTHERS THEN
          Rollback to Auto_Process_Email_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF fnd_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

		  if l_exception_log then
          	 errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Others';
	      	 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_RULES_ENGINE_PUB.AUTO_PROCESS_EMAIL.OTHERS', errorMessage);
		  end if;

END auto_process_email;

   function is_valid ( p_value VARCHAR2 )
    return VARCHAR2
   is
        l_value varchar2(256);
        x_result varchar2(30) := FND_API.G_FALSE;
   begin
        l_value := TRIM(LTRIM(p_value));

        if l_value is null then
            x_result := FND_API.G_FALSE;
        else
            x_result := FND_API.G_TRUE;
        end if;

        return x_result;
   end;

   function get_document_total ( p_cat_id VARCHAR2 )
    return number
   is
        l_value varchar2(256);
        x_total number := 0;
   begin
        l_value := TRIM(LTRIM(p_cat_id));

        if l_value is not null then


                    select count(ib.item_id) into x_total
                    from   amv_c_chl_item_match cim,
                        jtf_amv_items_vl ib
                    where  cim.channel_category_id = p_cat_id
                        and	  cim.channel_id is null
                        and	  cim.approval_status_type ='APPROVED'
                        and	  cim.table_name_code ='ITEM'
                        and	  cim.available_for_channel_date <= sysdate
                        and	  cim.item_id = ib.item_id
                        and   nvl(ib.effective_start_date, sysdate) <= sysdate + 1
                        and	  nvl(ib.expiration_date, sysdate) >= sysdate;

        /*
            Select count(*) into x_total
            from
            (
                SELECT i.item_id,i.item_name,i.description,i.item_type,i.last_update_date
                FROM   jtf_amv_items_vl i,jtf_amv_attachments_v a
                WHERE  i.item_id = a.attachment_used_by_id (+)
                AND    i.item_id IN
                (
                    select ib.item_id
                    from   amv_c_chl_item_match cim,
                        jtf_amv_items_vl ib
                    where  cim.channel_category_id = p_cat_id
                        and	  cim.channel_id is null
                        and	  cim.approval_status_type ='APPROVED'
                        and	  cim.table_name_code ='ITEM'
                        and	  cim.available_for_channel_date <= sysdate
                        and	  cim.item_id = ib.item_id
                        and   nvl(ib.effective_start_date, sysdate) <= sysdate + 1
                        and	  nvl(ib.expiration_date, sysdate) >= sysdate
                )
                GROUP BY i.item_id,
                    i.item_name,
                    i.description,
                    i.item_type,
                    i.last_update_date
            );
        */
        end if;

        return x_total;
   end;


   function is_document_exist ( p_cat_id VARCHAR2, p_doc_id VARCHAR2 )
    return VARCHAR2
   is
        l_value varchar2(256);
        l_total number :=0 ;
        x_result varchar2(30) := FND_API.G_FALSE;
   begin
        l_value := TRIM(LTRIM(p_cat_id));

        if l_value is not null then

                    select count(ib.item_id) into l_total
                    from   amv_c_chl_item_match cim,
                        jtf_amv_items_vl ib
                    where  cim.channel_category_id = l_value
                        and	  cim.channel_id is null
                        and	  cim.approval_status_type ='APPROVED'
                        and	  cim.table_name_code ='ITEM'
                        and   ib.item_id = p_doc_id
                        and	  cim.available_for_channel_date <= sysdate
                        and	  cim.item_id = ib.item_id
                        and   nvl(ib.effective_start_date, sysdate) <= sysdate + 1
                        and	  nvl(ib.expiration_date, sysdate) >= sysdate;

        end if;

        if ( l_total > 0 ) then
            x_result := FND_API.G_TRUE;
        else
            x_result := FND_API.G_FALSE;
        end if;

        return x_result;
   end;

END IEM_RULES_ENGINE_PUB;

/
