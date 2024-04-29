--------------------------------------------------------
--  DDL for Package Body IEM_ROUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ROUTE_PUB" AS
/* $Header: iemproub.pls 120.2 2006/05/22 20:10:32 pkesani noship $ */
--
--
-- Purpose: Mantain route classification related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   01/10/2002   fix bug that if the number of rules for a classification is less than
--                          that of classification with higher priority, this classification
--                          is never satisfied. ( No bug logged, shipped with FP-M )
--  Liang Xia   06/05/2002   Added Dynamic Route function
--  Liang Xia   08/06/2002  Changed jtf_rs_roles_vl to jtf_rs_roles_b, jtf_rs_group_members_vl to jtf_rs_group_members for
-- 	                       performance issue.
--  Liang Xia   11/12/2002  Added All_email tag, which overwrite the rules
-- 	                        Fixed GSCC warning: NOCOPY, FND_API.G_MISS...
--  Liang Xia   11/26/2002  Not to route groups that are expired.
--  Liang Xia   09/24/2003  Not to route groups that don't have 'Call Center' usage
--  Liang Xia   08/24/2004  Tar 4021452.999/bug 3855036.
--                          Do not Auto-Route to agent if the agent has been auto-routed, but requeued the message
--                          Do not route to group which doesn't have at least one agent who never requeue this message
--  Liang Xia   04/06/2005   Fixed GSCC sql.46 ( bug 4256769 )
--  Liang Xia   06/23/2005  Ported fixed: 12/06/2004  Changed for 115.11 schema complaince
-- 			    			Fixed more GSCC.sql46 warning ( bug 4452895 ).
--  PKESANI     05/20/2006  For Bug 5195496, change the SQL to look for responsibility_key
--                          instead of responsibility_id.
-- ---------   ------  ------------------------------------------


  /*GLOBAL VARIABLES FOR PRIVATE USE
  ==================================*/
  G_PKG_NAME    VARCHAR2(100):= 'IEM_ROUTE_PUB';

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
  PROCEDURE evaluateAnd(keyVals IN keyVals_tbl_type, rules IN Rules_tbl_type, fireRoute OUT NOCOPY Boolean)
    IS

  x number := 1;
  y number := 1;

  keyToFind iem_route_rules.key_type_code%type;
  operator iem_route_rules.operator_type_code%type;
  valueToFind iem_route_rules.value%type;

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
            fireRoute := false;
            EXIT;
        else
            fireRoute := true;
        end if;

       x := x + 1;
       end loop;

    EXCEPTION
        When others then

		if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Others';
	  	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_PUB.EVALUATEAND.OTHERS', errorMessage);
		end if;


  End evaluateAnd;

  /* Evaluate OR conditions */
  PROCEDURE evaluateOr(keyVals IN keyVals_tbl_type, rules IN Rules_tbl_type, fireRoute OUT NOCOPY Boolean)
    IS

  x number := 1;
  y number := 1;

  keyToFind iem_route_rules.key_type_code%type;
  operator iem_route_rules.operator_type_code%type;
  valueToFind iem_route_rules.value%type;

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
            fireRoute := true;
            EXIT;
        else
            fireRoute := false;
        end if;

       x := x + 1;
       end loop;

    EXCEPTION
        When others then

		if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Others';
	  	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_PUB.EVALUATEOR.OTHERS', errorMessage);
		end if;

  End evaluateOr;

/*Check if a group is valid
1. Has at least one resource in it
2. At least one resource is assigned to the email account
3. At least one resource has the one of the 3 eMC Roles*
4. At least one resource(agent) that has not requeued the message ( added for 11.59
and later version. For Tar 4021452.999./bug 3855036 )*/
FUNCTION validGroup(
    groupIdToCheck IN jtf_rs_group_members.group_id%TYPE,
    emailAccountId IN iem_mstemail_accounts.email_account_id%TYPE,
    p_message_id IN number)
return Boolean is

groupOK Boolean := TRUE;

resourceId      JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE;
roleTypeCode    JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE := 'ICENTER';
deleteFlag      JTF_RS_ROLE_RELATIONS.DELETE_FLAG%TYPE := 'N';
groupUsage      JTF_RS_GROUP_USAGES.usage%TYPE :='CALL';

errorMessage varchar2(2000);

begin
    select
     c.resource_id
   into
     resourceId
   from
    jtf_rs_roles_b a,
    jtf_rs_role_relations b,
    jtf_rs_group_members c,
    --jtf_rs_resource_values d,
	iem_agents d,
    JTF_RS_GROUPS_B e,
    JTF_RS_RESOURCE_EXTNS f,
    FND_USER_RESP_GROUPS g,
    FND_USER h,
    JTF_RS_GROUP_USAGES i,
    FND_RESPONSIBILITY resp
   where
    a.role_type_code = roleTypeCode
   and
    a.role_id = b.role_id
   and
    b.delete_flag = deleteFlag
   and
     b.START_DATE_ACTIVE< sysdate
   and
    ( b.END_DATE_ACTIVE>sysdate or b.END_DATE_ACTIVE is null)
   and
    b.role_resource_id = c.resource_id
   and
    c.group_id = groupIdToCheck
   and
    c.delete_flag = deleteFlag
   and
    c.resource_id = d.resource_id
   and
    --d.value_type = emailAccountId
	d.email_account_id = emailAccountId
   and
    c.group_id = e.group_id
   and
    e.START_DATE_ACTIVE< sysdate
   and
    ( e.END_DATE_ACTIVE>sysdate or e.END_DATE_ACTIVE is null)
   and
     c.resource_id = f.resource_id
   and
     f.START_DATE_ACTIVE< sysdate
   and
    ( f.END_DATE_ACTIVE>sysdate or f.END_DATE_ACTIVE is null)
   and
     f.user_id = g.user_id
   and
     g.START_DATE< sysdate
   and
    ( g.END_DATE>sysdate or g.END_DATE is null)
   and
--    ( g.responsibility_id = 23720 or g.responsibility_id = 23107 )
    ( g.responsibility_id = resp.responsibility_id and resp.application_id=680)
   and
    ( resp.responsibility_key = 'EMAIL_CENTER_SUPERVISOR' or resp.responsibility_key='IEM_SA_AGENT')
   and
    g.user_id = h.user_id
   and
     h.START_DATE< sysdate
   and
    ( h.END_DATE>sysdate or h.END_DATE is null)
   and
     c.group_id = i.group_id
   and
     i.usage = groupUsage
   and
    d.resource_id not in (select agent_id from iem_reroute_hists where message_id=p_message_id)
   and
    rownum = 1;

   return groupOK;

   EXCEPTION
        When NO_DATA_FOUND then
            groupOK := false;
            return groupOK;

        When OTHERS then

			if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            	errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Others';
	    		FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_PUB.VALIDGROUP.OTHERS', errorMessage);
			end if;

		  	groupOK := false;
        	return groupOK;


end validGroup;

 /* PUBLIC PROCEDURES THAT CAN BE CALLED BY ALL USERS
 ===================================================*/
  PROCEDURE route(
  p_api_version_number  IN Number,
  p_init_msg_list       IN VARCHAR2 := null,
  p_commit              IN VARCHAR2 := null,
  p_keyVals_tbl         IN keyVals_tbl_type,
  p_accountId           IN Number,
  x_groupId             OUT NOCOPY Number,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2)
  IS

  l_api_version_number      CONSTANT    NUMBER:= 1.0;
  l_api_name                CONSTANT    VARCHAR2(30):= 'Route';


  --The active routes in the system
  cursor c_routes (p_enabled_flag iem_account_routes.enabled_flag%type,
   p_account_id iem_mstemail_accounts.email_account_id%type)
  is
  select
    a.route_id,
    a.boolean_type_code,
    a.procedure_name,
    a.all_email,
    b.destination_group_id,
    b.default_group_id
  from
    iem_routes a,
    iem_account_routes b
  where
    a.route_id = b.route_id
  and
    b.enabled_flag = p_enabled_flag
  and
    b.email_account_id = p_account_id
  order by b.priority;

  --All the rules for a route
  cursor c_rules (p_route_id iem_routes.route_id%type)
   is
  select
    key_type_code,
    operator_type_code,
    value
  from
    iem_route_rules
  where
    route_id = p_route_id;


  x number:= 1;
  ruleHold Rules_tbl_type;
  runTimekeyVals_tbl keyVals_tbl_type;
  routeSatisfied Boolean := false;
  enabledFlag varchar(1):= 'Y';
  booleanTypeCode iem_routes.boolean_type_code%type;
  procedureName   iem_routes.procedure_name%type;
  returnParamType   iem_route_rules.key_type_code%type;
  runTimeSuccess    Boolean := true;
  l_agent_id VARCHAR2(256);
  all_email VARCHAR2(1);
  l_msg_id  VARCHAR2(15);
  l_count   NUMBER := 0;

  l_result          VARCHAR2(256);
  l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);

  logMessage varchar2(2000);
  errorMessage varchar2(2000);

  l_log_enabled  BOOLEAN := false;
  l_exception_log BOOLEAN := false;
   BEGIN

   --Standard begin of API savepoint
   SAVEPOINT    Route_PUB;
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

   	l_log_enabled := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;


	l_exception_log := FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;


    if l_log_enabled then
        logMessage := '[p_account_id=' || to_char(p_accountid) || ']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.START', logMessage);
    end if;

   --Initialize group to 0
   x_groupId := 0;

   --Iniitalize the Rule data structure
   --ruleHold.delete;

   --Check to see if the passed in PL/SQL table has valid key-vals
   If p_keyVals_tbl.count > 0 then

    if l_log_enabled then
        logMessage := '[p_keyValsCount=' || to_char(p_keyVals_tbl.count) || ']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.KEY_VALS_MORE_THAN_0', logMessage);
    end if;
       --Get all the active routes in the system
       For v_routes in c_routes (enabledFlag, p_accountId) Loop

             --The boolean operator for the rule chaining
             booleanTypeCode := v_routes.boolean_type_code;
             procedureName := v_routes.procedure_name;

            all_email := v_routes.all_email;

            if all_email = 'Y' then
                routeSatisfied := true;
            else
             --Iniitalize the Rule data structure
             ruleHold.delete;
             x := 1;
             -- Identify route type
             IF ( booleanTypeCode = 'DYNAMIC' ) THEN
                    if l_log_enabled then
            		logMessage := '[DYNAMIC procedure_name='||procedureName|| ']';
    		        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.DYNAMIC_ROUTE', logMessage);
    		        end if;

                 runTimekeyVals_tbl.delete;
                 runTimeSuccess := true;

                 --Get rules for the dynamic route and load it into the data structure
                 For v_rules in c_rules(v_routes.route_id) Loop
                    returnParamType:= v_rules.key_type_code;

                    -- begin PROCEDURE processing
                    BEGIN
                        IEM_ROUTE_RUN_PROC_PVT.run_Procedure(
                                    p_api_version_number    =>P_Api_Version_Number,
                                    p_init_msg_list         => FND_API.G_FALSE,
                                    p_commit                => P_Commit,
                                    p_procedure_name        => procedureName,
                                    p_key_value             => p_keyVals_tbl,
                                    p_param_type            => returnParamType,
                                    x_result                => l_result,
                                    x_return_status         => l_return_status,
                                    x_msg_count             => l_msg_count,
                                    x_msg_data              => l_msg_data);

                        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                            if l_log_enabled then
                                logMessage := '[ERROR when execute procedure for RouteID: '||v_routes.route_id ||']';
                                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.DYNAMIC_ROUTE', logMessage);
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
    		                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.DYNAMIC_ROUTE', logMessage);
    		                end if;
                        end if;
                     EXCEPTION
                  	     WHEN OTHERS THEN
                            runTimeSuccess := false;
                            if l_log_enabled then
                                logMessage := '[ERROR (Others) when execute procedure for keyId: '||v_routes.route_id ||'. error:'||sqlerrm||']';
                                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.DYNAMIC_ROUTE', logMessage);
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
      		            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.DYNAMIC_ROUTE', logMessage);
      		          end if;
                    else
                        exit;
                    end if;

                    x := x + 1;
                 End Loop;

                 --Depending on the operator call different evaluation functions
                 if runTimeSuccess then
                    evaluateAnd(runTimekeyVals_tbl, ruleHold, routeSatisfied);
                 else
                    routeSatisfied := false;
                 end if;


             ELSIF ( booleanTypeCode = 'AND' ) or ( booleanTypeCode = 'OR') THEN

                 --Get all the rules for the route and load it into the data structure
                 For v_rules in c_rules(v_routes.route_id) Loop
                    ruleHold(x).key := v_rules.key_type_code;
                    ruleHold(x).operator := v_rules.operator_type_code;
                    ruleHold(x).value := v_rules.value;

                    if l_log_enabled then
            		logMessage := '[' || ruleHold(x).key || ruleHold(x).operator || ruleHold(x).value || ']';
    		        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.RULES', logMessage);
    		        end if;

                    x := x + 1;
                 End Loop;

                 --Depending on the operator call different evaluation functions
                 if booleanTypeCode = 'AND' then
                     evaluateAnd(p_keyVals_tbl, ruleHold, routeSatisfied);
                 elsif booleanTypeCode = 'OR' then
                     evaluateOr(p_keyVals_tbl, ruleHold, routeSatisfied);
                 end if;
            END IF;
        end if; --end of if all_email = 'Y'

              --If the rules got satisfied then check
              -- 1. if route to Agent originating the email, check if agent ID is valid
              -- 2. otherwise route to valid group or destination group
              if routeSatisfied then

                    l_msg_id := get_key_value(p_keyVals_tbl=>p_keyVals_tbl,
                                                    p_key_name=>'IEMNMESSAGEID');

                    --Valid if the key-value contains valid agent ID for auto-route to Agent
                    if v_routes.destination_group_id ='-1' then
                        l_agent_id := get_key_value(p_keyVals_tbl=>p_keyVals_tbl,
                                                    p_key_name=>'IEMNAGENTID');

                        if l_log_enabled then
              		        logMessage := '[ROUTE to oringinating agent. IEMNAGENTID=' || l_agent_id|| ']';
      		                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.RULES', logMessage);
      		            end if;


                        if ( l_agent_id is null or l_agent_id='') then
                            if (v_routes.default_group_id = '0') then
                                x_groupId := 0;
                            elsif validGroup(v_routes.default_group_id, p_accountId, TO_NUMBER(l_msg_id)) then
                                x_groupId := v_routes.default_group_id;
                            else
                                x_groupId := 0;
                            end if;
                        else
                            -- Added on 8/21/2004. For Tar 4021452.999
                            -- Validate agent_id to see if the message has been route to the same agent before. For scenario
                            -- that auto-routed Agent pick up the message and requeues the message and expects it routed to different group
                            select count(*) into l_count from iem_reroute_hists
                                where message_id=l_msg_id and  agent_id=l_agent_id;


                            if( l_count = 0 and IEM_TAGPROCESS_PUB.isValidAgent(l_agent_id,p_accountId)) then
                                x_groupId := -1;
                            elsif (v_routes.default_group_id = '0') then
                                x_groupId := 0;
                            elsif validGroup(v_routes.default_group_id, p_accountId, TO_NUMBER(l_msg_id)) then
                                x_groupId := v_routes.default_group_id;
                            else
                                x_groupId := 0;
                            end if;
                        end if;
                    else
                        if validGroup(v_routes.destination_group_id, p_accountId, TO_NUMBER(l_msg_id)) then
                            x_groupId := v_routes.destination_group_id;
                        elsif (v_routes.default_group_id = '0') then
                            x_groupId := 0;
                        elsif validGroup(v_routes.default_group_id, p_accountId, TO_NUMBER(l_msg_id)) then
                            x_groupId := v_routes.default_group_id;
                        else
                            x_groupId := 0;
                        end if;
                    end if;

                    if l_log_enabled then
              		    logMessage := '[Route destination = ' || x_groupId|| ']';
      		            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.RULES', logMessage);
      		        end if;
                    EXIT;
               end if;

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
          Rollback to Route_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

		  if l_exception_log then
          	 	errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Execution Error';
	  	  		FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.EXEC_ERROR', errorMessage);
		  end if;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Rollback to Route_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
		  if l_exception_log then
          	 errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Unexpected Execution Error';
	  		 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.UNEXP_EXEC_ERROR', errorMessage);
		  end if;

     WHEN OTHERS THEN
          Rollback to Route_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF fnd_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

		  if l_exception_log then
          	 errorMessage := '[' || sqlcode || sqlerrm || ']' || ' Others';
	  		 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.OTHERS', errorMessage);
		  end if;

   END route;

   function get_key_value (   p_keyVals_tbl IN keyVals_tbl_type,
                              p_key_name IN VARCHAR2 )
   return VARCHAR2
   is
   x_value VARCHAR(256):=''; --FND_API.G_MISS_CHAR;
   begin
        if p_keyVals_tbl.count <> 0 then
            for i in 1..p_keyVals_tbl.count loop
                if p_keyVals_tbl(i).key = p_key_name then
                    x_value := p_keyVals_tbl(i).value;
                    exit;
                end if;
            end loop;
        end if;

        return x_value;
   end;

END IEM_ROUTE_PUB;

/
