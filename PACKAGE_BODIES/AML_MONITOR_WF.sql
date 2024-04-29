--------------------------------------------------------
--  DDL for Package Body AML_MONITOR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_MONITOR_WF" AS
/* $Header: amlldmnb.pls 115.40 2004/06/02 01:37:25 chchandr ship $ */

G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlldmnb.pls';
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);



-- Start of Comments
-- Package name     : AML_MONITOR_WF
-- Purpose          : Sales Leads Workflow
-- NOTE             :
-- History          :
--
-- END of Comments


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AML_MONITOR_WF';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlldmnb.pls';

/*-------------------------------------------------------------------------*/




 PROCEDURE LAUNCH_MONITOR (
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    P_Sales_Lead_Id              IN  NUMBER,
    P_Changed_From_stage         IN VARCHAR2 ,
    P_Lead_Action                IN VARCHAR2 ,
    P_Attribute_Changed          IN VARCHAR2 ,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
    l_api_name                   CONSTANT VARCHAR2(30) := 'LAUNCH_MONITOR';
    l_api_version_number         CONSTANT NUMBER   := 2.0;

    l_sales_lead_id         NUMBER;
    l_monitor_condition_id  NUMBER;
    l_lead_country          VARCHAR2(60);
    l_lead_rank_id          NUMBER;
    l_process_rule_id       NUMBER;
    l_monitor_found         VARCHAR2(1);
    l_time_lag_num          NUMBER;
    l_monitor_type_code     VARCHAR2(60);
    l_count                 NUMBER;

    l_new_itemtype             VARCHAR2(8);
    l_new_itemkey              VARCHAR2(8);
    l_itemtype                 VARCHAR2(8) := g_item_type; --'ASXSLASW';
    l_itemkey                  VARCHAR2(50);
    l_itemkey_like             VARCHAR2(50);
    l_existing_itemkey         VARCHAR2(50);
    itemtype                 VARCHAR2(8);
    itemkey                  VARCHAR2(50);
    workflowprocess VARCHAR2(30) := 'SALES_LEAD_ASSIGNMENT';
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_status        VARCHAR2(80);
    l_result        VARCHAR2(80);
    l_changed_from_stage VARCHAR2(100);
    l_monitor_launch_date date;
    l_lead_creation_date date;
    l_new_lead  varchar2(1) := 'N';
    l_prev_creation_monitor  varchar2(1) := 'N';
    l_start_new_monitor  varchar2(1) := 'Y';
  -- SWKHANNA 9/8/03
    l_prev_monitor_type VARCHAR2(60);
    l_attribute_changed VARCHAR2(60);
    l_prev_process_rule_id  NUMBER;

-- Get Lead Info
CURSOR c_get_lead_info (c_sales_lead_id number) IS
    SELECT hzl.country, asl.lead_rank_id, asl.creation_date
    FROM  as_sales_leads asl,
          hz_party_sites hzp,
          hz_locations hzl
    WHERE hzl.location_id = hzp.location_id
    AND   hzp.party_site_id = asl.address_id
    AND   asl.sales_lead_id = c_sales_lead_id;

-- Get all matching monitors -

CURSOR c_get_matching_monitors(c_country VARCHAR2, c_lead_rank VARCHAR2, c_from_stage_changed VARCHAR2) IS
SELECT rule.process_rule_id,  rule.monitor_condition_id, rule.time_lag_num
	   FROM  (
	            -- ------------------------------------------------------------
	            -- Country
	            -- ------------------------------------------------------------
    	           SELECT DISTINCT a.process_rule_id, d.monitor_condition_id, d.time_lag_num
        	         FROM   pv_process_rules_b a,
	                        pv_enty_select_criteria b,
	                        pv_selected_attr_values c,
                            AML_monitor_conditions d
	                 WHERE  b.selection_type_code = 'MONITOR_SCOPE'
	                 AND    b.attribute_id        = pv_check_match_pub.g_a_Country_
	                 AND    a.process_type        = 'LEAD_MONITOR'
	                 AND    a.process_rule_id     = b.process_rule_id
	                 AND    b.selection_criteria_id = c.selection_criteria_id(+)
	                 AND   (b.operator = 'EQUALS' AND c.attribute_value = c_country)
	                 AND a.process_rule_id = d.process_rule_id
                     AND a.status_code = 'ACTIVE'
                     AND d.time_lag_from_stage = c_from_stage_changed
	-- ------------------------------------------------------------
	-- Lead Rating
	-- ------------------------------------------------------------
         --   INTERSECT
	 UNION ALL
	                 SELECT DISTINCT a.process_rule_id, d.monitor_condition_id, d.time_lag_num
	                 FROM   pv_process_rules_b a,
	                        pv_enty_select_criteria b,
	                        pv_selected_attr_values c,
                            AML_monitor_conditions d
	                 WHERE  b.selection_type_code = 'MONITOR_SCOPE'
	                 AND    b.attribute_id =pv_check_match_pub.g_a_Lead_Rating
	                 AND    a.process_type        = 'LEAD_MONITOR'
	                 AND    a.process_rule_id     = b.process_rule_id
	                 AND    b.selection_criteria_id = c.selection_criteria_id(+)
	                 AND  (b.operator = 'EQUALS' AND c.attribute_value =  c_lead_rank )
	                 AND a.process_rule_id = d.process_rule_id
                     AND a.status_code = 'ACTIVE'
                     AND d.time_lag_from_stage = c_from_stage_changed
                 ) rule
GROUP BY rule.process_rule_id, rule.monitor_condition_id,rule.time_lag_num
      HAVING (rule.process_rule_id, COUNT(*)) IN (
         SELECT a.process_rule_id, COUNT(*)
	 FROM   pv_process_rules_b a,
                pv_enty_select_criteria b
         WHERE  a.process_rule_id     = b.process_rule_id AND
                b.selection_type_code = 'MONITOR_SCOPE' AND
                a.status_code         = 'ACTIVE' AND
                a.process_type        = 'LEAD_MONITOR' AND
                SYSDATE >= a.start_date AND SYSDATE <= a.end_date
         GROUP  BY a.process_rule_id)
ORDER BY COUNT(*) DESC,
rule.time_lag_num ASC;


 CURSOR c_get_existing_wf (c_item_type varchar2, c_item_key_like varchar2) is
          SELECT item_key
          FROM   wf_items
          WHERE  item_type= c_item_type
          AND    item_key like c_item_key_like
          AND    end_date is null
          ORDER BY item_key desc;


   cursor c_chk_item_key (c_itemtype varchar2,c_itemkey_like varchar2) is
   select item_key
   from wf_items
   where item_type= c_itemtype
   AND    item_key like c_itemkey_like
   ORDER BY to_number (substr(item_key,(instr(item_key,'_')+1) ) ) desc;

    CURSOR c_prev_monitor_type (c_item_type varchar2, c_item_key varchar2) is
      SELECT text_value from wf_item_attribute_values
       WHERE item_type = c_item_type
         AND item_key like c_item_key
         AND name = 'TIMELAG_FROM_STAGE'
        -- swkhanna 9/8/03
        -- AND text_value = 'CREATION_DATE'
     ORDER BY item_key desc;



    CURSOR c_monitor_values (c_item_type varchar2, c_item_key varchar2, c_attr_name varchar2) is
      SELECT number_value from wf_item_attribute_values
       WHERE item_type = c_item_type
         AND item_key = c_item_key
         AND name = c_attr_name
     ORDER BY item_key desc;

BEGIN
      IF (AS_DEBUG_LOW_ON) THEN
      	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API' || l_api_name );
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT LAUNCH_MONITOR_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'PVT:' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

 if fnd_profile.value('AS_RUN_LEAD_MONITOR_ENGINE') = 'Y' then
       -- ******************************************************************
       -- Get Lead Country and Rank
       -- ******************************************************************
       open  c_get_lead_info (P_Sales_Lead_Id);
       fetch c_get_lead_info into l_lead_country, l_lead_rank_id,l_lead_creation_date;
       close c_get_lead_info;

    	IF (AS_DEBUG_LOW_ON) THEN
       		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_lead_country '||l_lead_country );
       		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_lead_rank_id '||l_lead_rank_id );
         END IF;
     -- See if this is a new lead or old_lead
        if p_lead_action = 'CREATE' then
           l_new_lead := 'Y';
        elsif p_lead_action = 'UPDATE' then
           l_new_lead := 'N';
        end if;
     --
      l_attribute_changed := P_Attribute_Changed;
    -- *******************************************************************************
     -- swkhanna 9/8/03 Monitors 11.5.10
    -- *******************************************************************************
     -- If New Lead, look for creation date monitors. If found , start one.
     -- If not, look for Relative (assignment) monitors. If found, start that one.

    -- If Old Lead Update,
    -- check previous monitor running
    -- If owner changed and rank not changed then
    --   If previous monitor is 'Absolute', then do not stop it.
    --   if previous monitor is relative, then reevaluate
    -- If lead rank changed and owner not changed ,then
    --   Reevaluate existing, stop existing if not valid
    --    start new one
    -- If lead ranb changed and owner changed, then rank gets preference.
    --  In such case, as_sales_lead_engine will pass in 'RANK' as the attribute change

    -- *******************************************************************************


     -- if new_lead, then need to try finding a creation date monitor
   if l_new_lead = 'Y' then

       IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'New Lead ' );
       END IF;

       open  c_get_matching_monitors(l_lead_country, l_lead_rank_id ,  P_Changed_From_stage);
       fetch c_get_matching_monitors into l_process_rule_id,  l_monitor_condition_id, l_time_lag_num;
       if c_get_matching_monitors%NOTFOUND then
          l_monitor_found := 'N';
       else
          l_monitor_found:= 'Y';
       end if;
       close c_get_matching_monitors;

       IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_monitor_found '||l_monitor_found );
       END IF;

       -- if no creation date monitors found, then look for assigned date monitor

       IF p_changed_from_stage = 'CREATION_DATE' and l_monitor_found = 'N' then

          l_changed_from_stage := 'ASSIGNED_DATE';
          open  c_get_matching_monitors(l_lead_country, l_lead_rank_id ,  l_Changed_From_stage);
          fetch c_get_matching_monitors into l_process_rule_id,  l_monitor_condition_id,
                                             l_time_lag_num;
          if c_get_matching_monitors%NOTFOUND then
              l_monitor_found := 'N';
          else
              l_monitor_found:= 'Y';
          end if;
          close c_get_matching_monitors;
      END IF;


     -- if old_lead, then chk if any creation_date monitors were attached to this lead earlier
   elsif l_new_lead = 'N' then

         -- reevaluate on which monitor satisfies now
          l_changed_from_stage := 'ASSIGNED_DATE';
          open  c_get_matching_monitors(l_lead_country, l_lead_rank_id ,  l_Changed_From_stage);
          fetch c_get_matching_monitors into l_process_rule_id,  l_monitor_condition_id,
                                             l_time_lag_num;
          if c_get_matching_monitors%NOTFOUND then
              l_monitor_found := 'N';
          else
              l_monitor_found:= 'Y';
          end if;
          close c_get_matching_monitors;

         -- ******************************************************************
          -- Find earlier Active Workflow for this lead
          -- assuming only one active can exist at one time
          -- ******************************************************************
          l_itemkey_like := p_sales_lead_id||'%';

              Open c_get_existing_wf(l_itemtype,l_itemkey_like);
              loop
              fetch c_get_existing_wf into l_existing_itemkey;

                 IF (AS_DEBUG_LOW_ON) THEN
                   AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_existing_itemkey:' || l_existing_itemkey);
                 END IF;
                exit when c_get_existing_wf%NOTFOUND;

                IF (AS_DEBUG_LOW_ON) THEN
                   AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_existing_itemkey:' || l_existing_itemkey);
                END IF;

                if l_existing_itemkey is not null then
                   -- Find process_rule_id for the current one running
                   open c_monitor_values (l_itemtype, l_existing_itemkey, 'PROCESS_RULE_ID');
                   fetch c_monitor_values into l_prev_process_rule_id;
                   close c_monitor_values;

                   -- Find process type for current running one
                  Open c_prev_monitor_type(l_itemtype,l_itemkey_like);
      			  fetch c_prev_monitor_type into l_prev_monitor_type;
       			  close c_prev_monitor_type;


                   if (l_monitor_found = 'Y' and l_process_rule_id = l_prev_process_rule_id )
                     or ( l_prev_monitor_type = 'CREATION_DATE' and l_attribute_changed = 'OWNER')then
						-- no need to stop earlier one
                       null;
                    else
                        -- abort existing process
                        Wf_Engine.AbortProcess(itemtype => l_itemtype,
                                               itemkey  => l_existing_itemkey) ;
                    end if;

                     IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'after aborting the old one:' || l_existing_itemkey);
                     END IF;



              end if;
              end loop;
      close c_get_existing_wf;
     end if;






   /* If l_start_new_monitor = 'Y' then
 -- end 3/17/03 swkhanna

      -- ******************************************************************
      -- Select Monitors with particular Time_Lag_From_Stage
      -- Set Monitors_found flag
      -- Store Monitors in a PL/SQL table
      -- If Monitors_Found = 'N' then
      --    Do Nothing, exit procedure with sucesss
      -- If count of Monitors_found > 1 then
      -- Pick one based on Tie breaking rules
            --	Monitor Scope - More no of attributes, better
            --	Time Lag Number - Lesser number is better

      -- Find earlier Active workflows for this lead
      -- If found, then abort earlier process
      -- Start New Process
      -- ******************************************************************
    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Getting Matching Monitor ' );
    END IF;

       open  c_get_matching_monitors(l_lead_country, l_lead_rank_id ,  P_Changed_From_stage);
       fetch c_get_matching_monitors into l_process_rule_id,  l_monitor_condition_id, l_time_lag_num;
       if c_get_matching_monitors%NOTFOUND then
          l_monitor_found := 'N';
       else
          l_monitor_found:= 'Y';
       end if;
       close c_get_matching_monitors;

     IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_monitor_found '||l_monitor_found );
     END IF;

       -- if no creation date monitors found, then look for assigned date monitor

       IF p_changed_from_stage = 'CREATION_DATE' and l_monitor_found = 'N' then

          l_changed_from_stage := 'ASSIGNED_DATE';
          open  c_get_matching_monitors(l_lead_country, l_lead_rank_id ,  l_Changed_From_stage);
          fetch c_get_matching_monitors into l_process_rule_id,  l_monitor_condition_id,
                                             l_time_lag_num;
          if c_get_matching_monitors%NOTFOUND then
              l_monitor_found := 'N';
          else
              l_monitor_found:= 'Y';
          end if;
          close c_get_matching_monitors;
        END IF;

       --
       IF l_monitor_found = 'Y' THEN
          --
        IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'inside l_monitor_found = Y :' );
        END IF;
          -- ******************************************************************
          -- Find earlier Active Workflow for this lead
          -- assuming only one active can exist at one time
          -- ******************************************************************
          l_itemkey_like := p_sales_lead_id||'%';

              Open c_get_existing_wf(l_itemtype,l_itemkey_like);
              loop
              fetch c_get_existing_wf into l_existing_itemkey;

       IF (AS_DEBUG_LOW_ON) THEN
         AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_existing_itemkey:' || l_existing_itemkey);
       END IF;
              exit when c_get_existing_wf%NOTFOUND;

        IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_existing_itemkey:' || l_existing_itemkey);
        END IF;

              if l_existing_itemkey is not null then
                  -- abort existing process
                 Wf_Engine.AbortProcess(itemtype => l_itemtype,
                                        itemkey  => l_existing_itemkey) ;

        IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'after aborting the old one:' || l_existing_itemkey);
        END IF;



              end if;
              end loop;
      close c_get_existing_wf;

   -- ******************************************************************
*/
 /*     SELECT TO_CHAR(AS_WORKFLOW_KEYS_S.nextval) INTO itemkey  */
/*      FROM dual;  */

 if l_monitor_found = 'Y' then
   l_existing_itemkey := null;
   open c_chk_item_key(g_item_type, P_Sales_Lead_Id||'%' );
   fetch c_chk_item_key into l_existing_itemkey;
   close  c_chk_item_key;


    if l_existing_itemkey is null then
       select p_sales_lead_id||'_'||'1' into itemkey from dual;
    else
       select p_sales_lead_id || '_' || (substr(l_existing_itemkey,(instr(l_existing_itemkey,'_')+1) ) + 1 ) into itemkey
       from dual ;
    end if;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'itemkey:' || itemkey);
      END IF;

    itemtype := AML_MONITOR_WF.g_item_type;

    wf_engine.CreateProcess( ItemType => itemtype,
                             ItemKey  => itemkey,
                             process  => Workflowprocess);


    wf_engine.SetItemUserKey( ItemType => itemtype,
                              ItemKey  => itemkey,
                               userkey  => p_sales_lead_id);


/*  procedure SetItemOwner(
  itemtype in varchar2,
  itemkey in varchar2,
  owner in varchar2)     */

    -- Initialize workflow item attributes
   -- l_process_rule_id,  l_monitor_condition_id, l_time_lag_num, l_count
    --

      wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PROCESS_RULE_ID',
                                 avalue   => l_process_rule_id);

           IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_process_rule_id:' || l_process_rule_id);
           END IF;

      wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MONITOR_CONDITION_ID',
                                  avalue   => l_monitor_condition_id);


      wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'TIMELAG_NUM',
                                  avalue   => l_time_lag_num);

       wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SALES_LEAD_ID',
                                  avalue   => p_sales_lead_id);


       select to_date(to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')
       into l_monitor_launch_date from dual;

       wf_engine.SetItemAttrDate(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MONITOR_LAUNCH_DATE',
                                  avalue   =>   l_monitor_launch_date);

     IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_time_lag_num:' || l_time_lag_num);
     END IF;

    wf_engine.StartProcess(itemtype  => ItemType,
                           itemkey   => ItemKey );

     IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'after start process:' );
     END IF;

    wf_engine.ItemStatus(itemtype => ItemType,
                         itemkey  => ItemKey,
                         status   => l_status,
                         result   => l_result);

   IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'After ItemStatus:' || l_result);
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_status:' || l_status);
   END IF;

    l_itemtype := ItemType;
    l_itemkey := ItemKey;
  -- swkhanna 4/7/03 Bug2891236 - changed to check l_result instead of x_return_status
   -- x_return_status := l_result ;

           IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'x_return_status: '|| x_return_status);
           END IF;

	          -- verify the valid values of return_status from WF and handle them
               IF l_result = '#NULL' THEN
                   x_return_status := FND_API.G_RET_STS_SUCCESS;
               ELSIF l_result = 'ERROR' THEN
                 IF (AS_DEBUG_LOW_ON) THEN
                   AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'AS_LEAD_MONITOR_START_FAIL');
                 END IF;
                    RAISE FND_API.G_EXC_ERROR;
               --ELSIF l_result = 'W' THEN
        	--       x_return_status := 'W';
               ELSE
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
               END IF;
               --

 END IF;-- monitor found
      --
 /* else -- if l_start_new_monitor = N
     x_return_status := FND_API.G_RET_STS_SUCCESS;
  end if; -- l_start_new_monitor = Y
 */

end if; --profile run_lead_monitor_engine
      -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'PVT: ' || l_api_name || ' End');
    END IF;
      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
END LAUNCH_MONITOR;
-- *****************************************************************************
-- Launch Process
-- *****************************************************************************

PROCEDURE GET_MONITOR_DETAILS(
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

    l_status        VARCHAR2(80);
    l_result        VARCHAR2(80);
    l_sequence      VARCHAR2(240);
    l_seqnum        NUMBER(38);

    l_profile_rs_id NUMBER;


  l_sales_lead_id         NUMBER;
  l_process_rule_id       NUMBER;
  l_monitor_type_code     VARCHAR2(60);
  l_object_version_number NUMBER;
  l_time_lag_uom_code     VARCHAR2(30);
  l_time_lag_num          NUMBER;
  l_time_lag_from_stage   VARCHAR2(100);
  l_time_lag_to_stage     VARCHAR2(100);
  l_max_reroutes          NUMBER;
  l_expiration_relative   VARCHAR2(1);
  l_Reminder_defined      VARCHAR2(1);
  l_total_reminders       NUMBER;
  l_reminder_frequency    NUMBER;
  l_timeout_defined       VARCHAR2(1);
  l_timeout_duration      NUMBER;
  l_timeout_uom_code      VARCHAR2(30);

  l_creation_date         DATE;
  l_last_update_date      DATE;
  l_status_code           VARCHAR2(30);
  l_assign_date           DATE;
  l_accept_flag           VARCHAR2(1);
  l_lead_number           VARCHAR2(30);
  l_lead_rank_id          NUMBER;
  l_monitor_condition_id  NUMBER;
  l_monitor_defined         VARCHAR2(1);
  l_recipient_role          varchar2(30);
  l_lead_owner_username     varchar2(60);
  l_lead_owner_fullname     varchar2(60);
  l_monitor_owner_username   varchar2(60);
  l_manager_username         varchar2(60);
  l_notify_owner             varchar2(1);
  l_notify_manager           varchar2(1);
  l_notify_m_owner           varchar2(1);
  l_notify_role_list		 VARCHAR2(2000);
  l_notify_role			     VARCHAR2(80);
  l_from_stage_changed       VARCHAR2(100);
  l_expiration_date          DATE;
  l_resource_id              NUMBER;
  l_mgr_resource_id              NUMBER;
  l_current_reroutes            NUMBER;
  l_group_id NUMBER;
  l_customer_id NUMBER;
  l_customer_name varchar2(500);

  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

   l_notify_display_name varchar2(100);
  l_email_address varchar2(100);
  l_notification_pref varchar2(100);
  l_language varchar2(100);
 l_territory varchar2(100);

TYPE UserRecType		IS RECORD (
		user_name			fnd_user.user_name%type
    );
TYPE UserTableType      IS TABLE OF UserRecType   INDEX BY BINARY_INTEGER;

  l_user_table			UserTableType;
  l_user_count			NUMBER := 1;
  l_description                 VARCHAR2(500);
  l_time_lag_to_stage_meaning   VARCHAR2(60);
  l_get_lead_status_meaning     VARCHAR2(60);
  l_status_code_meaning         VARCHAR2(60);
  l_notify_role_name VARCHAR2(80):= '';
 l_monitor_launch_date Date;

CURSOR c_get_monitor_details (c_monitor_condition_id number) is
   SELECT  DISTINCT d.monitor_type_code,d.object_version_number,
                    d.time_lag_from_stage, d.time_lag_to_stage,
                    d.time_lag_num, d.time_lag_uom_code,
                    d.expiration_relative, d.Reminder_defined, d.total_reminders,
                    d.reminder_frequency,d.timeout_defined, d.timeout_duration,
                    d.timeout_uom_code, d.notify_owner, d.notify_owner_manager
   FROM   AML_monitor_conditions d
   WHERE  d.monitor_condition_id = c_monitor_condition_id;

-- Get lead info
CURSOR c_get_lead_details (c_sales_lead_id NUMBER) IS
    SELECT creation_date, last_update_date, lead_number, status_code,
    assign_date, accept_flag, lead_rank_id, expiration_date,
    assign_to_salesforce_id, assign_sales_group_id, current_reroutes, description,
    customer_id
    FROM   as_sales_leads
    WHERE  sales_lead_id = c_sales_lead_id;

CURSOR c_lead_owner (c_lead_id number) IS
    SELECT  usr.user_name
    FROM    as_sales_leads lead, fnd_user usr
    WHERE   lead.sales_lead_id = c_lead_id
    and     lead.assign_to_person_id =  usr.employee_id;


CURSOR c_lead_owner_fullname (c_assign_to_salesforce_id number) is
select source_first_name || ' '||source_last_name
from jtf_rs_resource_extns
where resource_id = c_assign_to_salesforce_id;


/*        */
/*  CURSOR c_monitor_owner (c_process_rule_id number) IS  */
/*      SELECT  usr.user_name  */
/*      FROM   pv_process_rules_b rule, fnd_user usr, jtf_rs_resource_extns res  */
/*      WHERE  rule.process_rule_id = c_process_rule_id  */
/*      AND    rule.owner_resource_id = res.resource_id  */
/*      and     res.user_id = usr.user_id;       */

          Cursor c_get_mgr_username (c_resource_id number, c_group_id number) is
          select usr.user_name, res.resource_id
             from jtf_rs_rep_managers mgr, fnd_user usr, jtf_rs_resource_extns res
            where mgr.manager_person_id = res.source_id
             and res.user_id = usr.user_id
             and mgr.resource_id= c_resource_id
             and mgr.group_id = c_group_id
             and mgr.start_date_active <= SYSDATE
             and (mgr.end_date_active IS NULL OR mgr.end_date_active >= SYSDATE)
             and mgr.reports_to_flag = 'Y';

	     cursor c_get_meaning (c_lookup_type varchar2, c_lookup_code varchar2) is
	     select meaning
	     from as_lookups
	     where lookup_type = c_lookup_type
	     and   lookup_code = c_lookup_code;

	     cursor c_get_lead_status_meaning (c_status_code varchar2) is
	     select meaning
	     from as_statuses_vl
	     where status_code = c_status_code;

             cursor c_get_customer_name (c_customer_id number) is
             select party_name
             from hz_parties
             where party_id = c_customer_id;

BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Get_Monitor_Details: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN
           l_monitor_condition_id :=  wf_engine.GetItemAttrText(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'MONITOR_CONDITION_ID');

       select to_date(to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')
       into l_monitor_launch_date from dual;

       wf_engine.SetItemAttrDate(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MONITOR_LAUNCH_DATE',
                                  avalue   =>   l_monitor_launch_date);


   -- Get Monitor Details
      OPEN c_get_monitor_details (l_monitor_condition_id);
      FETCH c_get_monitor_details INTO l_monitor_type_code,l_object_version_number,
                    l_time_lag_from_stage, l_time_lag_to_stage,
                    l_time_lag_num, l_time_lag_uom_code,
                    l_expiration_relative, l_Reminder_defined, l_total_reminders,
                    l_reminder_frequency,l_timeout_defined, l_timeout_duration,
                    l_timeout_uom_code, l_notify_owner, l_notify_manager;
      CLOSE c_get_monitor_details;

  IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'after getting monitor details:' || l_time_lag_from_stage);
  END IF;
           l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'SALES_LEAD_ID');
      -- Get Lead Details
       open c_get_lead_details(l_sales_lead_id);
       fetch c_get_lead_details into l_creation_date, l_last_update_date, l_lead_number, l_status_code, l_assign_date,
                                      l_accept_flag, l_lead_rank_id , l_expiration_date,
                                      l_resource_id, l_group_id , l_current_reroutes, l_description,l_customer_id;
       close c_get_lead_details;

  IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'after getting lead details:' || l_creation_date);
  END IF;

       wf_engine.SetItemAttrDate(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'LEAD_CREATION_DATE',
                                  avalue   => l_creation_date);

       wf_engine.SetItemAttrDate(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'EXPIRATION_DATE',
                                  avalue   => l_expiration_date);

       wf_engine.SetItemAttrDate(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'LEAD_UPDATED_DATE',
                                  avalue   => l_last_update_date);

       wf_engine.SetItemAttrDate(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'LEAD_ASSIGNED_DATE',
                                  avalue   => l_assign_date);


      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_REQD',
                                avalue   => 'N');

      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_NAME',
                                avalue   => l_description);

      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_NUMBER',
                                avalue   => l_lead_number);

     open c_get_customer_name (l_customer_id);
     fetch c_get_customer_name into l_customer_name;
     close c_get_customer_name;


         wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_CUSTOMER_NAME',
                                avalue   => l_customer_name);



      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TIMELAG_UOM_CODE',
                                avalue   => l_time_lag_uom_code);


    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TIMELAG_FROM_STAGE',
                                avalue   => l_time_lag_from_stage);

    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TIMELAG_TO_STAGE',
                                avalue   => l_time_lag_to_stage);

     open c_get_meaning('TIME_LAG_TO_STAGE',l_time_lag_to_stage);
     fetch c_get_meaning into l_time_lag_to_stage_meaning;
     close c_get_meaning;


    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TIMELAG_TO_STAGE_MEANING',
                                avalue   => l_time_lag_to_stage_meaning);

     open c_get_lead_status_meaning (l_status_code);
     fetch c_get_lead_status_meaning into l_status_code_meaning;
     close c_get_lead_status_meaning;

    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_STATUS_MEANING',
                                avalue   => l_status_code_meaning);



        l_process_rule_id :=  wf_engine.GetItemAttrNumber(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'PROCESS_RULE_ID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'EXPIRATION_RELATIVE',
                                avalue   => l_expiration_relative);


    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'REMINDER_DEFINED',
                                avalue   => l_Reminder_defined);

   -- swkhanna 3/21
     wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'CURRENT_REMINDERS',
                                  avalue   => 1);

    wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TOTAL_REMINDERS',
                                avalue   => l_total_reminders);


     wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'REMINDER_FREQUENCY',
                                avalue   => l_reminder_frequency);


    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TIMEOUT_DEFINED',
                                avalue   => l_timeout_defined);


    wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TIMEOUT_DURATION',
                                avalue   => l_timeout_duration);

    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TIMEOUT_UOM_CODE',
                                avalue   => l_timeout_uom_code);

   IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_process_rule_id:' || l_process_rule_id);
   END IF;

            if l_current_Reroutes is null then
                l_current_reroutes := 0;
            end if;
    wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TIMEOUT_CURR_REROUTES',
                                avalue   => l_current_reroutes);

                wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'NOTIFY_LEAD_OWNER',
                                      avalue   => l_notify_owner);


                wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'NOTIFY_LD_OWNR_MANAGER',
                                      avalue   => l_notify_manager);


      OPEN  c_lead_owner_fullname (l_resource_id);
       FETCH c_lead_owner_fullname into l_lead_owner_fullname;
       CLOSE c_lead_owner_fullname;




 /*               wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'LEAD_OWNER',
                                   avalue   => l_lead_owner_fullname);*/



       if l_notify_owner = 'Y' then
          OPEN c_lead_owner (l_sales_lead_id);
          FETCH c_lead_owner INTO l_lead_owner_username;
          CLOSE c_lead_owner;

          l_notify_role_list := l_notify_role_list||','||l_lead_owner_username;
       end if;


  /*  wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_RESOURCE_ID',
                                avalue   => l_resource_id);

    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_USERNAME',
                                avalue   => l_lead_owner_username);*/


      if l_notify_manager = 'Y' then
          -- Get manager username

          Open c_get_mgr_username (l_resource_id, l_group_id);
          loop
             fetch c_get_mgr_username into l_manager_username, l_mgr_resource_id;
             exit when c_get_mgr_username%NOTFOUND;
             if l_manager_username = l_lead_owner_username then
                null;
             else
                l_notify_role_list := l_notify_role_list||','||l_manager_username;
             end if;
          end loop;
          close c_get_mgr_username;
/*
             if l_mgr_resource_id is not null and l_mgr_resource_id <> 0 then

                   wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_MGR_RESOURCE_ID',
                                avalue   => l_mgr_resource_id);


                 wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_MGR_USERNAME',
                                avalue   => l_manager_username);

            end if;*/
       end if;

      l_notify_role_list := substr(l_notify_role_list,2);
      l_notify_role := 'AML_' || itemKey;

   IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'l_notify_role_list :' || l_notify_role_list);

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'l_notify_role :' || l_notify_role);
   END IF;

          -- Create Role

      wf_directory.GetRoleInfo    (Role => l_notify_role,
                                   Display_Name => l_notify_display_name,
                                   Email_Address => l_email_address,
                                   Notification_Preference => l_notification_pref,
                                   Language => l_language,
                                   Territory => l_territory);


if l_notify_display_name = l_notify_role then
 -- skip role creation

   wf_directory.RemoveUsersFromAdHocRole
     (role_name => l_notify_role,
      role_users => null);

  /*    wf_directory.AddUsersToAdHocRole
     (role_name => l_notify_role,
      role_users => l_notify_role_list);*/
else
  wf_directory.CreateAdHocRole(role_name         => l_notify_role,
                                 role_display_name => l_notify_role,
                                 --role_users        => l_notify_role_list);
                                   role_users        => null);
end if;

 IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'After createAdHocRole :');
 END IF;

	wf_engine.SetItemAttrText (    ItemType =>   itemType,
				                    ItemKey  => itemKey,
                                    aname    => 'NOTIFY_ROLE',
                                    avalue   => l_notify_role);

 IF (AS_DEBUG_LOW_ON) THEN
  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'After setting notify role value :');
 END IF;


    --x_item_type := ItemType;
    --x_item_key := ItemKey;
    --x_return_status := l_result ;


              l_result := 'COMPLETE';

    END IF;

  IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_result);
  END IF;

        result := l_result;


EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
         AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
             SQLERRM);
      END IF;

        wf_core.context(
            itemtype,
            'Get_Monitor_Details',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END GET_MONITOR_DETAILS;

  /*******************************/
-- API: Owner_Needed
/*******************************/
PROCEDURE OWNER_NEEDED (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
 IS

    l_lead_owner_reqd  VARCHAR2(1):= 'N';
   l_api_name              CONSTANT VARCHAR2(30) := 'OWNER_NEEDED';


     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
BEGIN
     IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Owner_Needed: Start');
      END IF;

    IF funcmode = 'RUN'
    THEN
           l_lead_owner_reqd :=  wf_engine.GetItemAttrText(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'LEAD_OWNER_REQD');

         --  if l_lead_owner_reqd = 'N' then
          --     l_resultout := 'COMPLETE:'||'N';
         --  elsif l_lead_owner_reqd = 'Y' then
               l_resultout := 'COMPLETE';
         -- end if;



    END IF;

   IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
   END IF;

        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'Owner_Needed',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END OWNER_NEEDED;




 /*******************************/
-- API: TIMEOUT_DEFINED
/*******************************/
PROCEDURE TIMEOUT_DEFINED (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS
   l_timeout_defined VARCHAR2(1);
 --  l_notify_monitor_defined  VARCHAR2(1);
   l_api_name              CONSTANT VARCHAR2(30) := 'TIMEOUT_DEFINED';
  -- l_api_version_number     CONSTANT NUMBER   := 1.0;


     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
BEGIN
 IF (AS_DEBUG_LOW_ON) THEN
   AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Timeout_Defined: Start');
 END IF;

      IF funcmode = 'RUN'
    THEN

         -- Get item attributes -
        l_timeout_defined :=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'TIMEOUT_DEFINED');


       IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'l_timeout_defined:' || l_timeout_defined);
       END IF;

         if  l_timeout_defined = 'Y' then
            l_resultout := 'COMPLETE:'||'Y';
         else
           l_resultout := 'COMPLETE:'||'N';
         end if;
    END IF;

    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
    END IF;
        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
         AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
             SQLERRM);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'Timeout_Defined',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END TIMEOUT_DEFINED;


 /*******************************/
-- API: SET_NOTIFY_ATTRIBUTES
/*******************************/
PROCEDURE SET_NOTIFY_ATTRIBUTES (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_timelag_number    number;
     l_total_timelag    number;
     l_timelag_minutes   number;
     l_monitor_launch_date Date;
     l_timelag_due_date  Date;
     l_expiration_date   Date;
     l_due_date   Date;
     l_relative_to_expiration varchar2(1);
BEGIN
   IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'SET_NOTIFY_ATTRIBUTES: Start');
   END IF;

    IF funcmode = 'RUN'
    THEN
         IF (AS_DEBUG_LOW_ON) THEN
           AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'SET_NOTIFY_ATTRIBUTES: Start');
         END IF;


            l_timelag_number :=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'TIMELAG_NUM');

        IF (AS_DEBUG_LOW_ON) THEN
           AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       ' l_timelag_number: '||l_timelag_number);
        END IF;

            l_monitor_launch_date :=  wf_engine.GetItemAttrDate(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'MONITOR_LAUNCH_DATE');

        IF (AS_DEBUG_LOW_ON) THEN
           AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       ' l_monitor_launch_date: '||l_monitor_launch_date);
        END IF;

            l_relative_to_expiration:=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'EXPIRATION_RELATIVE');

         IF (AS_DEBUG_LOW_ON) THEN
           AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       ' l_relative_to_expiration: '||l_relative_to_expiration);
         END IF;

       if l_relative_to_expiration is null then
          l_relative_to_expiration := 'N' ;
       end if;

                      l_expiration_date:=  wf_engine.GetItemAttrDate(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'EXPIRATION_DATE');

        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       ' l_expiration_date: '||l_expiration_date);
        END IF;

              aml_monitor_wf.set_timelag
                ( p_start_date => l_monitor_launch_date,
                  p_timeout  => l_timelag_number,
                  x_due_date => l_due_date,
                  x_total_timeout => l_total_timelag) ;

        if  l_relative_to_expiration = 'N'  then
            -- assuming only days uom are allowed
              l_timelag_minutes :=   l_timelag_number * 24 * 60;

              l_timelag_due_date :=  l_monitor_launch_date +  l_total_timelag;
             l_resultout := 'COMPLETE';


         IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       ' l_timelag_due_date: '||l_timelag_due_date);
         END IF;

         elsif l_relative_to_expiration = 'Y' and l_expiration_date is not null then

                l_timelag_due_date := l_expiration_date - l_total_timelag;
             l_resultout := 'COMPLETE';

         elsif l_relative_to_expiration = 'Y' and l_expiration_date is  null then
            -- set the due date to monitor launch date as the chk_timelag condition
            -- will fail in this case and no notification should be sentr

              l_timelag_due_date :=  l_monitor_launch_date ;
             l_resultout := 'COMPLETE';

         end if;


            wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'TIMELAG_MINUTES',
                                        avalue   => l_timelag_minutes);

            wf_engine.SetItemAttrDate(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'TIMELAG_DUE_DATE',
                                        avalue   => l_timelag_due_date);


   elsif (funcmode = 'CANCEL') then
             l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
             l_resultout := 'COMPLETE';
   elsif (funcmode = 'TIMEOUT') then
             l_resultout := 'COMPLETE';

    END IF;

      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
       END IF;
                        l_timelag_minutes :=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'TIMELAG_MINUTES');

       IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_timelag_minutes:' || l_timelag_minutes);
       END IF;
        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'SET_NOTIFY_ATTRIBUTES',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END SET_NOTIFY_ATTRIBUTES;


/*******************************/
-- API: LOG_ACTION
/*******************************/
PROCEDURE LOG_ACTION (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

      l_monitor_log_rec AML_MONITOR_LOG_PVT.monitor_log_rec_type ;
      l_monitor_condition_id    NUMBER;
      l_sales_lead_id           NUMBER;
      l_monitor_action          VARCHAR2(30);
      l_notify_owner            VARCHAR2(1);
      l_lead_owner_resource_id  NUMBER;
      l_notify_owner_manager    VARCHAR2(1);
      l_lead_owner_mgr_resource_id NUMBER;
      l_monitor_log_id          NUMBER;




     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
BEGIN
   IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'LOG_NOTIFICATION_ACTION: Start');
   END IF;

    IF funcmode = 'RUN'
    THEN


            l_monitor_condition_id:=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'MONITOR_CONDITION_ID');

            l_sales_lead_id:=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'SALES_LEAD_ID');


            l_monitor_action:= wf_engine.GetActivityAttrText(itemtype => itemtype,
						   itemkey  => itemkey,
						    actid   =>  actid,
						    aname   => 'MONITOR_ACTION');

/*
            l_monitor_action:=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'MONITOR_ACTION');
*/
         --   l_monitor_action := 'NOTIFICATION';


            l_notify_owner:=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'NOTIFY_LEAD_OWNER');

            l_lead_owner_resource_id:=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'LEAD_OWNER_RESOURCE_ID');


            l_notify_owner_manager:=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'NOTIFY_LD_OWNR_MANAGER');

            l_lead_owner_mgr_resource_id:=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'LEAD_OWNER_MGR_RESOURCE_ID');


       --if    l_notify_owner = 'Y' then
            l_monitor_log_rec.monitor_condition_id             := l_monitor_condition_id;
            l_monitor_log_rec.recipient_role                   := 'LEAD_OWNER';
            l_monitor_log_rec.monitor_action                   :=  l_monitor_action;
            l_monitor_log_rec.recipient_resource_id            := l_lead_owner_resource_id;
            l_monitor_log_rec.sales_lead_id                    := l_sales_lead_id;

            AML_MONITOR_LOG_PVT.Create_monitor_Log(
                            p_api_version_number        => 2.0,
                            p_init_msg_list             => FND_API.G_FALSE,
                            p_commit                    => FND_API.G_FALSE,
                            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
                            p_monitor_log_rec           => l_monitor_log_rec,
                            x_monitor_log_id             => l_monitor_log_id,
                            X_Return_Status             => l_return_status,
                            X_Msg_Count                 => l_msg_count,
                            X_Msg_Data                  => l_msg_data
                            ) ;
/*

SELECT aml_MONITOR_LOG_S.nextval into l_monitor_log_id FROM sys.dual;


   INSERT INTO aml_MONITOR_LOG(
           MONITOR_LOG_ID
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,OBJECT_VERSION_NUMBER
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE
          ,MONITOR_CONDITION_ID
          ,RECIPIENT_ROLE
          ,MONITOR_ACTION
          ,RECIPIENT_RESOURCE_ID
          ,SALES_LEAD_ID
          ) VALUES (
           l_monitor_log_id
          ,sysdate
          ,fnd_global.user_id
          ,sysdate
          ,fnd_global.user_id
          ,fnd_global.user_id
          ,1
          ,null
          ,null
          ,null
          ,null
          ,l_monitor_condition_id
          ,'OWNER'
          ,l_monitor_action
          ,l_lead_owner_resource_id
          ,l_sales_lead_id
);

*/
       --  end if;

         if    l_notify_owner_manager = 'Y' then
            l_monitor_log_rec.monitor_condition_id             := l_monitor_condition_id;
            l_monitor_log_rec.recipient_role                   := 'LEAD_OWNER_MANAGER';
            l_monitor_log_rec.monitor_action                   :=  l_monitor_action;
            l_monitor_log_rec.recipient_resource_id            := l_lead_owner_mgr_resource_id;
            l_monitor_log_rec.sales_lead_id                    := l_sales_lead_id;

            AML_MONITOR_LOG_PVT.Create_monitor_Log(
                            p_api_version_number        => 2.0,
                            p_init_msg_list             => FND_API.G_FALSE,
                            p_commit                    => FND_API.G_FALSE,
                            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
                            p_monitor_log_rec           => l_monitor_log_rec,
                            x_monitor_log_id             => l_monitor_log_id,
                            X_Return_Status             => l_return_status,
                            X_Msg_Count                 => l_msg_count,
                            X_Msg_Data                  => l_msg_data
                            ) ;


         end if;



            l_resultout := 'COMPLETE';

    END IF;
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
      END IF;

        result := l_resultout;
EXCEPTION

    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'LOG_ACTION',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END LOG_ACTION;
/*******************************/
-- API: CHK_MAX_REMINDERS
-- check if reminders defined.
-- if reminders are defined and the timeout has still not happened, then
-- return 'Y' else 'N'
/*******************************/
PROCEDURE CHK_MAX_REMINDERS (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_current_reminders     number;
     l_total_reminders       number;
     l_reminder_defined      varchar2(1);
     l_timeout_defined      varchar2(1);
BEGIN
     IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'CHK_MAX_REMINDERS: Start');
     END IF;

    IF funcmode = 'RUN'
    THEN
             -- Get item attributes -
        l_reminder_defined :=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'REMINDER_DEFINED');



      l_timeout_defined :=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'TIMEOUT_DEFINED');


    if      l_reminder_defined = 'Y' then

       l_total_reminders :=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'TOTAL_REMINDERS');

        l_current_reminders :=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'CURRENT_REMINDERS');
    end if;


    END IF;

    if      l_reminder_defined = 'Y' then
        if l_current_reminders <= l_total_reminders then
             l_resultout := 'COMPLETE:'||'N';
        else
             l_resultout := 'COMPLETE:'||'Y';
       end if;
    else
         l_resultout := 'COMPLETE:'||'Y';
    end if;

     IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
     END IF;

        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'CHK_MAX_REMINDERS',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END CHK_MAX_REMINDERS;

 /*******************************/
-- API: SET_REMINDER_ATTRIBUTES
/*******************************/
PROCEDURE SET_REMINDER_ATTRIBUTES (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_timelag_number   number;
     l_current_reminder number;
     l_reminder_frequency    number;
     l_reminder_timelag_minutes number;
     l_total_reminder_timelag number;
     l_due_date   Date;

BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'SET_REMINDER_ATTRIBUTES: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN

            l_timelag_number :=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'TIMELAG_NUM');

       IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_timelag_number:' || l_timelag_number);
       END IF;

            l_current_reminder :=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'CURRENT_REMINDERS');

     IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_current_reminder:' || l_current_reminder);
     END IF;

            l_reminder_frequency :=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'REMINDER_FREQUENCY');

     IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_reminder_frequency:' || l_reminder_frequency);
      END IF;

              aml_monitor_wf.set_timelag
                ( p_start_date => sysdate,
                  p_timeout  => l_reminder_frequency,
                  x_due_date => l_due_date,
                  x_total_timeout => l_total_reminder_timelag) ;

            -- assuming only days uom are allowed
          -- l_reminder_timelag_minutes :=  ( l_timelag_number*24*60 + (l_current_reminder * l_reminder_frequency*24*60));
           -- l_reminder_timelag_minutes := l_reminder_frequency*24*60;
            l_reminder_timelag_minutes := l_total_reminder_timelag*24*60;

    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_reminder:' || l_reminder_timelag_minutes);
    END IF;

            wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'REMINDER_TIMELAG_MINUTES',
                                        avalue   => l_reminder_timelag_minutes);


              wf_engine.SetItemAttrText(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'MONITOR_ACTION',
                                        avalue   => 'REMINDER');

            l_resultout := 'COMPLETE';

    END IF;

     IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
     END IF;

        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'SET_REMINDER_ATTRIBUTES',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END SET_REMINDER_ATTRIBUTES;



 /*******************************/
-- API: INCREMENT_CURR_REMINDER
/*******************************/
PROCEDURE INCREMENT_CURR_REMINDER (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_timelag_number   number;
     l_current_reminder number;
     l_reminder_frequency    number;
     l_reminder_timelag_minutes number;

BEGIN

    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'INCREMENT_CURR_REMINDER: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN



            l_current_reminder :=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'CURRENT_REMINDERS');

           l_current_reminder := l_current_reminder + 1;

            wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'CURRENT_REMINDERS',
                                        avalue   => l_current_reminder);



           l_resultout := 'COMPLETE';

    END IF;
       IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
       END IF;
        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'INCREMENT_CURR_REMINDER',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END INCREMENT_CURR_REMINDER;

/*******************************/
-- API: INCREMENT_CURR_REROUTES
/*******************************/
PROCEDURE INCREMENT_CURR_REROUTES (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_timelag_number   number;
     l_current_reroutes number;
     l_sales_lead_id    number;


BEGIN

    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'INCREMENT_CURR_REROUTES: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN



            l_current_reroutes :=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'TIMEOUT_CURR_REROUTES');

           l_sales_lead_id := wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'SALES_LEAD_ID');

           l_current_reroutes := l_current_reroutes + 1;

           begin
                update as_sales_leads
                set current_reroutes = l_current_reroutes
                where sales_lead_id = l_sales_lead_id;
           exception
               when others then
                IF (AS_DEBUG_LOW_ON) THEN
                   AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
                END IF;
                raise;
           end;

           l_resultout := 'COMPLETE';

    END IF;

    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
    END IF;

        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'INCREMENT_CURR_REROUTES',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END INCREMENT_CURR_REROUTES;



 /*******************************/
-- API: SET_TIMEOUT
/*******************************/
PROCEDURE SET_TIMEOUT (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_timeout_duration_minutes number;
     l_timeout_duration         number;
     l_monitor_launch_date Date;
     l_timeout_due_date  Date;
     l_due_date  Date;
     l_total_timelag number;
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Set_Timeout: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN

       l_timeout_duration :=  wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'TIMEOUT_DURATION');

      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_timeout_duration:' || l_timeout_duration);
      END IF;

      l_monitor_launch_date :=  wf_engine.GetItemAttrDate(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'MONITOR_LAUNCH_DATE');

           l_timeout_duration_minutes := l_timeout_duration*24*60;

              aml_monitor_wf.set_timelag
                ( p_start_date => l_monitor_launch_date,
                  p_timeout  => l_timeout_duration,
                  x_due_date => l_due_date,
                  x_total_timeout => l_total_timelag) ;


           l_timeout_due_date :=  l_monitor_launch_date +  l_total_timelag;

    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            ' l_timeout_duration_minutes:' || l_timeout_duration_minutes);
    END IF;

            wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'TIMEOUT_DURATION_MINUTES',
                                        avalue   => l_timeout_duration_minutes);

            wf_engine.SetItemAttrDate(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'TIMEOUT_DUE_DATE',
                                        avalue   => l_timeout_due_date);


              wf_engine.SetItemAttrText(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'MONITOR_ACTION',
                                        avalue   => 'TIMEOUT');

            l_resultout := 'COMPLETE';

    END IF;
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
    END IF;

        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
     IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
     END IF;
        wf_core.context(
            itemtype,
            'Set_Timeout',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END SET_TIMEOUT;

/*******************************/
-- API: CHK_MAX_REROUTES
/*******************************/
PROCEDURE CHK_MAX_REROUTES (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_curr_reroutes     number;
     l_max_reroutes      number;
     l_esc_mgr_resource_id number;
     l_source_id         number;
     l_source_name       varchar2(360);
     l_source_email     varchar2(2000);
     l_esc_username      varchar2(100);

    CURSOR c_esc_username (c_esc_mgr_resource_id number) IS
    select source_id, source_name, source_email, user_name
    from  jtf_rs_resource_extns
    where resource_id = c_esc_mgr_resource_id;


BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Chk_Max_Reroutes: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN
           -- Get item attributes -
      l_curr_reroutes :=  wf_engine.GetItemAttrNumber(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'TIMEOUT_CURR_REROUTES');

     l_max_reroutes := fnd_profile.value('AS_MAX_WF_LEAD_REROUTES');

     -- swkhanna Jun18,03
     -- Get escalation Manager profile value
        l_esc_mgr_resource_id := fnd_profile.value('AS_LEAD_ESC_MGR_RESOURCE_ID');


          OPEN c_esc_username (l_esc_mgr_resource_id);
          FETCH c_esc_username INTO l_source_id, l_source_name, l_source_email, l_esc_username;
          CLOSE c_esc_username;

         if l_esc_username is not null then

              wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'ESCALATION_MGR_USERNAME',
                                avalue   => l_esc_username);


        end if;



      if l_curr_reroutes < l_max_reroutes then
            l_resultout := 'COMPLETE:'||'N';
       else
             l_resultout := 'COMPLETE:'||'Y';
      end if;
    END IF;
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
    END IF;

        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'Chk_Max_Reroutes',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END CHK_MAX_REROUTES;


/*******************************/
-- API: CHK_TIMELAG_CONDITION_TRUE
/*******************************/
PROCEDURE CHK_TIMELAG_CONDITION_TRUE (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_timelag_to_stage     varchar2(30);
     l_sales_lead_id      number;
     l_is_timelag_lead_status varchar2(1);
     l_lead_current_status varchar2(30);
     l_is_timelag_lookup varchar2(1);
     l_condition_true varchar2(1) := 'N';
     l_accept_flag    varchar2(1);
     l_curr_last_update_date date;
     l_orig_last_update_date date;
     l_opp_open_status_flag varchar2(1);
     l_expiration_date   Date;
     l_relative_to_expiration varchar2(1);

   cursor c_chk_is_timelag_lead_status (c_status_code varchar2) is
         select 'Y'
         from as_statuses_b
         where lead_flag = 'Y'
         and status_code = c_status_code;

     cursor c_chk_lead_current_status (c_sales_lead_id number) is
     select status_code
     from as_sales_leads
     where sales_lead_id = c_sales_lead_id;

     cursor c_chk_timelag_to_stage (c_lookup_code varchar2) is
      select 'Y'
      from as_lookups
      where lookup_type = 'TIME_LAG_TO_STAGE'
      and   lookup_code = c_lookup_code;

    cursor c_chk_lead_accepted (c_sales_lead_id number) is
    select accept_flag
    from as_sales_leads
    where sales_lead_id = c_sales_lead_id;

BEGIN

   IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'CHK_TIMELAG_CONDITION_TRUE: Start');
   END IF;

IF funcmode = 'RUN'
    THEN
          -- Get item attributes -
      l_timelag_to_stage :=  wf_engine.GetItemAttrText(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'TIMELAG_TO_STAGE');


       l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'SALES_LEAD_ID');

            l_relative_to_expiration:=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'EXPIRATION_RELATIVE');

       if l_relative_to_expiration is null then
          l_relative_to_expiration := 'N' ;
       end if;

                      l_expiration_date:=  wf_engine.GetItemAttrDate(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                       aname    => 'EXPIRATION_DATE');

-- bugfix# 2801435. Closed Lead should not be monitored

          -- add code to see if lead id closed
          open c_chk_lead_current_status (l_sales_lead_id);
	  fetch c_chk_lead_current_status into l_lead_current_status;
       	  close c_chk_lead_current_status;

          SELECT nvl(opp_open_status_flag, 'Y')
          INTO l_opp_open_status_flag
          FROM as_statuses_b
          WHERE status_code = l_lead_current_status;

          if l_opp_open_status_flag = 'Y' then
            l_condition_true := 'Y'; --Need to validate other Timelag condition
          else
            l_condition_true := 'N';--do not validate any Timelag condition. No notification required
          end if;

       -- chk if it is a new lookup
          open  c_chk_timelag_to_stage (l_timelag_to_stage);
          fetch c_chk_timelag_to_stage into l_is_timelag_lookup;
          close c_chk_timelag_to_stage;

          if (l_condition_true = 'Y' AND l_is_timelag_lookup = 'Y') then
                 -- handle each lookup separately
                 if l_timelag_to_stage = 'ACCEPTED' then

                    -- chk if the lead has been accepted yet or not
                    open c_chk_lead_accepted (l_sales_lead_id);
                    fetch c_chk_lead_accepted into l_accept_flag;
                    close c_chk_lead_accepted;

                    if l_accept_flag = 'N' then
                       l_condition_true := 'Y';
                    else
                       l_condition_true := 'N';
                    end if;

-- bugfix# 2808633. Need to get date by calling GetItemAttrDate.

                 elsif l_timelag_to_stage = 'LAST_UPDATE_DATE' then
                    -- chk to see if lead has been updated since the workflow started
                    l_orig_last_update_date :=  wf_engine.GetItemAttrDate(
                                                       itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => 'LEAD_UPDATED_DATE');


                    select last_update_date
                    into l_curr_last_update_date
                    from as_sales_leads
                    where sales_lead_id = l_sales_lead_id;

-- bugfix# 2808633. The date comparasion cannot be done with equals. If the lead is updated , do not send out notification
                    --if l_orig_last_update_date = l_curr_last_update_date then
                    if l_orig_last_update_date < l_curr_last_update_date then
                       l_condition_true := 'N';
                    else
                       l_condition_true := 'Y';
                    end if;

-- bugfix# 2801435. Closed Lead should not be monitored, LAST_UPDATE_DATE is no longer supported in Action param To
/*
                 elsif l_timelag_to_stage = 'CLOSED' then
                     -- add code to see if lead id closed
                	 open c_chk_lead_current_status (l_sales_lead_id);
	                 fetch c_chk_lead_current_status into l_lead_current_status;
       	                 close c_chk_lead_current_status;

                         --
                         SELECT nvl(opp_open_status_flag, 'Y')
                         INTO l_opp_open_status_flag
                         FROM as_statuses_b
                         WHERE status_code = l_lead_current_status;

                         if l_opp_open_status_flag = 'Y' then
                            l_condition_true := 'Y';
                         else
                            l_condition_true := 'N';
                         end if;
*/
                 elsif l_timelag_to_stage = 'IN_PROGRESS' then
                     -- chk to see if lead in 'In_Progress' status

                	 open c_chk_lead_current_status (l_sales_lead_id);
	                 fetch c_chk_lead_current_status into l_lead_current_status;
       	                 close c_chk_lead_current_status;

                         if l_lead_current_status = 'IN_PROGRESS' then
                          -- monitor condition still holds true
                             l_condition_true := 'N';
                         else
                             l_condition_true := 'Y';
                         end if;

           end if;
      end if;
 ---
/*
         else -- if not the new lookup, chk for lead status

              -- chk if timelag_to_stage is a lead status

             open c_chk_is_timelag_lead_status(l_timelag_to_stage);
             fetch c_chk_is_timelag_lead_status into l_is_timelag_lead_status;
             close c_chk_is_timelag_lead_status;

             if l_is_timelag_lead_status = 'Y' then
             -- check if lead is still in same status

                 open c_chk_lead_current_status (l_sales_lead_id);
                 fetch c_chk_lead_current_status into l_lead_current_status;
                 close c_chk_lead_current_status;

                 if l_lead_current_status = l_timelag_to_stage then
                    -- monitor condition still holds true
                    l_condition_true := 'N';
                 else
                     l_condition_true := 'Y';
                 end if;
              end if;

        end if;
*/

 /*
          -- chk if timelag_to_stage is a lead status

         open c_chk_is_timelag_lead_status(l_timelag_to_stage);
         fetch c_chk_is_timelag_lead_status into l_is_timelag_lead_status;
         close c_chk_is_timelag_lead_status;

      if l_is_timelag_lead_status = 'Y' then
         -- check if lead is still in same status

                 open c_chk_lead_current_status (l_sales_lead_id);
                 fetch c_chk_lead_current_status into l_lead_current_status;
                 close c_chk_lead_current_status;

                 if l_lead_current_status = l_timelag_to_stage then
                    -- monitor condition still holds true
                    l_condition_true := 'N';
                 else
                     l_condition_true := 'Y';
                 end if;

        else    -- if time_lag_to_stage is not a lead status

              -- chk if it is a new lookup
              open  c_chk_timelag_to_stage (l_timelag_to_stage);
              fetch c_chk_timelag_to_stage into l_is_timelag_lookup;
              close c_chk_timelag_to_stage;

              if    l_is_timelag_lookup = 'Y' then
                 -- handle each lookup separately
                 if l_timelag_to_stage = 'ACCEPTED' then

                    -- chk if the lead has been accepted yet or not
                    open c_chk_lead_accepted (l_sales_lead_id);
                    fetch c_chk_lead_accepted into l_accept_flag;
                    close c_chk_lead_accepted;

                    if l_accept_flag = 'N' then
                       l_condition_true := 'Y';
                    else
                       l_condition_true := 'N';
                    end if;

                 elsif l_timelag_to_stage = 'LAST_UPDATE_DATE' then
                    -- chk to see if lead has been updated since the workflow started
                    l_orig_last_update_date :=  wf_engine.GetItemAttrText(
                                                       itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => 'LEAD_UPDATED_DATE');


                    select last_update_date
                    into l_curr_last_update_date
                    from as_sales_leads
                    where sales_lead_id = l_sales_lead_id;

                    if l_orig_last_update_date = l_curr_last_update_date then
                       l_condition_true := 'Y';
                    else
                       l_condition_true := 'N';
                    end if;

                 end if; -- last_update_date
              end if; --l_is_timelag_lookup

     end if;  -- l_is_timelag_lead_status = 'Y'/'N'

     if l_condition_true = 'Y' then
              wf_engine.SetItemAttrText(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'MONITOR_ACTION',
                                        avalue   => 'NOTIFICATION');
     end if;

*/


     if l_condition_true = 'Y' then
        -- expiration date check
                if  l_relative_to_expiration = 'N' then
                     l_condition_true := 'Y';
                elsif  l_relative_to_expiration = 'Y' and l_expiration_date is not null then
                     l_condition_true := 'Y';
                elsif l_relative_to_expiration = 'Y' and l_expiration_date is  null then
                     l_condition_true := 'N';
                end if;
      end if;
--
-- swkhanna 2/11/03 Bug 2795647
-- if time_lag condition is true, then get the latest lead owner and set the attribute
-- for sending notification

   AML_MONITOR_WF.get_lead_owner
       (    itemtype     => itemtype,
            itemkey      => itemkey);


      l_resultout := 'COMPLETE:'||l_condition_true;

 END IF;

     IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
     END IF;

        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'Chk_Timelag_condition_true',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END CHK_TIMELAG_CONDITION_TRUE;


/*******************************/
-- API: SET_DEFAULT_RESOURCE
/*******************************/
PROCEDURE SET_DEFAULT_RESOURCE (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS
    l_rs_id     NUMBER := NULL;
    l_group_id     NUMBER := NULL;
    l_person_id     NUMBER := NULL;
    l_resultout varchar2(100);

    CURSOR C_get_current_resource IS
      SELECT res.resource_id
      FROM jtf_rs_resource_extns res
      WHERE res.category = 'EMPLOYEE'
      AND res.user_id = fnd_global.user_id;

    CURSOR c_get_group_id(c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> 'Y'
      AND rrel.delete_flag <> 'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = 'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    -- A resource may not be in any group. Besides, jtf_rs_group_members
    -- may not have person_id for all resources. Therefore, get person_id
    -- in this cursor, instead of in the above cursor.
    CURSOR c_get_person_id(c_resource_id NUMBER) IS
      SELECT res.source_id
      FROM jtf_rs_resource_extns res
      WHERE res.resource_id = c_resource_id;

BEGIN

IF funcmode = 'RUN'
    THEN

    l_rs_id := fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
    IF l_rs_id IS NULL
    THEN

        -- Profile is not set. hence going against the logged in user

        OPEN C_get_current_resource;
        FETCH C_get_current_resource INTO l_rs_id;
        IF (C_get_current_resource%NOTFOUND)
        THEN

            CLOSE C_get_current_resource;
            RETURN;
        END IF;
        CLOSE C_get_current_resource;

        IF l_rs_id IS NOT NULL
        THEN

                OPEN c_get_group_id (l_rs_id);
                FETCH c_get_group_id INTO l_group_id;
                CLOSE c_get_group_id;
        END IF;

            OPEN c_get_person_id (l_rs_id);
            FETCH c_get_person_id INTO l_person_id;
            CLOSE c_get_person_id;



    ELSE -- profile resource id is not null

        l_group_id := NULL;
        OPEN c_get_group_id (l_rs_id);
        FETCH c_get_group_id INTO l_group_id;
        CLOSE c_get_group_id;

        OPEN c_get_person_id (l_rs_id);
        FETCH c_get_person_id INTO l_person_id;
        CLOSE c_get_person_id;

/*
        OPEN C_get_current_resource;
        FETCH C_get_current_resource INTO l_rs_id;
        IF (C_get_current_resource%NOTFOUND)
        THEN
            CLOSE C_get_current_resource;
            -- result := 'COMPLETE:ERROR';

            RETURN;
        END IF;
        CLOSE C_get_current_resource;
*/

    END IF; -- resource id from profile check

       wf_engine.SetItemAttrNumber (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'RESOURCE_ID',
        avalue   => l_rs_id);

    wf_engine.SetItemAttrNumber (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'GROUP_ID',
        avalue   => l_group_id);

    wf_engine.SetItemAttrNumber (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'PERSON_ID',
        avalue   => l_person_id);

    wf_engine.SetItemAttrText (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'DEFAULT_RESOURCE_SET',
        avalue   => 'Y');

    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);
    END IF;

       l_resultout := 'COMPLETE';
 end if;
        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'Set_Default_Resource',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END SET_DEFAULT_RESOURCE;
/*******************************/
-- API: CHK_RESTART_REQD
/*******************************/
PROCEDURE CHK_RESTART_REQD (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);
     l_resultout         varchar2(50);
     l_timeout_duration_minutes number;
     l_timeout_duration         number;
     l_monitor_launch_date Date;
     l_timeout_due_date  Date;
     l_default_resource_set varchar2(1);
     l_timelag_from_stage varchar2(60);
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Chk_Restart_Reqd: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN
    -- 3/17/03 swkhanna
    -- Chk if this is Creation_date monitor, then don't restart
       l_timelag_from_stage := wf_engine.GetItemAttrText(
                                                   itemtype => itemtype,
                                                   itemkey => itemkey,
                                                   aname => 'TIMELAG_FROM_STAGE' );
       if l_timelag_from_stage = 'CREATION_DATE' then
         l_resultout := 'COMPLETE:N';

       else
       		l_default_resource_set := wf_engine.GetItemAttrText(
                                                   itemtype => itemtype,
                                                   itemkey => itemkey,
                                                   aname => 'DEFAULT_RESOURCE_SET' );

               if l_default_resource_set = 'N' then
               -- if default resource id is already not set, need to restart
                  l_resultout := 'COMPLETE:Y';
               else
                  l_resultout := 'COMPLETE:N';
               end if;
       end if;
    END IF;
     IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Result:' || l_resultout);

     END IF;
        result := l_resultout;
EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'chk_restart_reqd',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END CHK_RESTART_REQD;
/*******************************/
-- API: SET_RESTART_ATTR
/*******************************/
PROCEDURE SET_RESTART_ATTR (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

    l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);

    l_sales_lead_id         NUMBER;
    l_monitor_condition_id  NUMBER;
    l_lead_country          VARCHAR2(60);
    l_lead_rank_id          NUMBER;
    l_process_rule_id       NUMBER;
    l_monitor_found         VARCHAR2(1);
    l_time_lag_num          NUMBER;
    l_monitor_type_code     VARCHAR2(60);
    l_count                 NUMBER;

    -- SOLIN, 02/25/2003, bug 2801660
    l_reminder_defined      VARCHAR2(1);
    -- SOLIN, end bug 2801660

    l_monitor_launch_date date;
-- Get Lead Info
CURSOR c_get_lead_info1 (c_sales_lead_id number) IS
    SELECT hzl.country, asl.lead_rank_id
    FROM  as_sales_leads asl,
          hz_party_sites hzp,
          hz_locations hzl
    WHERE hzl.location_id = hzp.location_id
    AND   hzp.party_site_id = asl.address_id
    AND   asl.sales_lead_id = c_sales_lead_id;

-- Get all matching monitors -

CURSOR c_get_matching_monitors1(c_country VARCHAR2, c_lead_rank VARCHAR2, c_from_stage_changed VARCHAR2) IS
SELECT rule.process_rule_id,  rule.monitor_condition_id, rule.time_lag_num
	   FROM  (
	            -- ------------------------------------------------------------
	            -- Country
	            -- ------------------------------------------------------------
    	           SELECT DISTINCT a.process_rule_id, d.monitor_condition_id, d.time_lag_num
        	         FROM   pv_process_rules_b a,
	                        pv_enty_select_criteria b,
	                        pv_selected_attr_values c,
                            AML_monitor_conditions d
	                 WHERE  b.selection_type_code = 'MONITOR_SCOPE'
	                 AND    b.attribute_id        = pv_check_match_pub.g_a_Country_
	                 AND    a.process_type        = 'LEAD_MONITOR'
	                 AND    a.process_rule_id     = b.process_rule_id
	                 AND    b.selection_criteria_id = c.selection_criteria_id(+)
	                 AND   (b.operator = 'EQUALS' AND c.attribute_value = c_country)
	                 AND a.process_rule_id = d.process_rule_id
                     AND a.status_code = 'ACTIVE'
                     AND d.time_lag_from_stage = c_from_stage_changed
	-- ------------------------------------------------------------
	-- Lead Rating
	-- ------------------------------------------------------------
                   INTERSECT
	                 SELECT DISTINCT a.process_rule_id, d.monitor_condition_id, d.time_lag_num
	                 FROM   pv_process_rules_b a,
	                        pv_enty_select_criteria b,
	                        pv_selected_attr_values c,
                            AML_monitor_conditions d
	                 WHERE  b.selection_type_code = 'MONITOR_SCOPE'
	                 AND    b.attribute_id =pv_check_match_pub.g_a_Lead_Rating
	                 AND    a.process_type        = 'LEAD_MONITOR'
	                 AND    a.process_rule_id     = b.process_rule_id
	                 AND    b.selection_criteria_id = c.selection_criteria_id(+)
	                 AND  (b.operator = 'EQUALS' AND c.attribute_value =  c_lead_rank )
	                 AND a.process_rule_id = d.process_rule_id
                     AND a.status_code = 'ACTIVE'
                     AND d.time_lag_from_stage = c_from_stage_changed
                 ) rule
GROUP BY rule.process_rule_id, rule.monitor_condition_id,rule.time_lag_num
      HAVING (rule.process_rule_id) IN (
         SELECT a.process_rule_id
         FROM   pv_process_rules_b a,
                pv_enty_select_criteria b
         WHERE  a.process_rule_id     = b.process_rule_id AND
                b.selection_type_code = 'MONITOR_SCOPE' AND
                a.status_code         = 'ACTIVE' AND
                a.process_type        = 'LEAD_MONITOR' AND
                SYSDATE >= a.start_date AND SYSDATE <= a.end_date
         GROUP  BY a.process_rule_id)
ORDER BY  rule.time_lag_num ASC;





BEGIN

IF funcmode = 'RUN'
    THEN
        -- ******************************************************************
       -- Get Lead Country and Rank
       -- ******************************************************************

              l_sales_lead_id := wf_engine.GetItemAttrText(
                                                   itemtype => itemtype,
                                                   itemkey => itemkey,
                                                   aname => 'SALES_LEAD_ID' );


       open  c_get_lead_info1 (l_Sales_Lead_Id);
       fetch c_get_lead_info1 into l_lead_country, l_lead_rank_id;
       close c_get_lead_info1;


      -- ******************************************************************
      -- Select Monitors with particular Time_Lag_From_Stage
      -- Set Monitors_found flag
      -- Store Monitors in a PL/SQL table
      -- If Monitors_Found = 'N' then
      --    Do Nothing, exit procedure with sucesss
      -- If count of Monitors_found > 1 then
      -- Pick one based on Tie breaking rules
            --	Monitor Scope - More no of attributes, better
            --	Time Lag Number - Lesser number is better

      -- Find earlier Active workflows for this lead
      -- If found, then abort earlier process
      -- Start New Process
      -- ******************************************************************
      IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Getting Matching Monitor ' );
      END IF;
       open  c_get_matching_monitors1(l_lead_country, l_lead_rank_id ,  'ASSIGNED_DATE');
       fetch c_get_matching_monitors1 into l_process_rule_id,  l_monitor_condition_id, l_time_lag_num;
       if c_get_matching_monitors1%NOTFOUND then
          l_monitor_found := 'N';
       else
          l_monitor_found:= 'Y';
       end if;
       close c_get_matching_monitors1;

      IF (AS_DEBUG_LOW_ON) THEN
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_monitor_found '||l_monitor_found );
      END IF;
       --


  if l_monitor_found = 'Y' then

    -- Initialize workflow item attributes
   -- l_process_rule_id,  l_monitor_condition_id, l_time_lag_num, l_count
    --

      wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PROCESS_RULE_ID',
                                 avalue   => l_process_rule_id);

             IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_process_rule_id:' || l_process_rule_id);
             END IF;

      wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MONITOR_CONDITION_ID',
                                  avalue   => l_monitor_condition_id);


      wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'TIMELAG_NUM',
                                  avalue   => l_time_lag_num);

       wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SALES_LEAD_ID',
                                  avalue   => l_sales_lead_id);


       select to_date(to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')
       into l_monitor_launch_date from dual;

       wf_engine.SetItemAttrDate(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MONITOR_LAUNCH_DATE',
                                  avalue   =>   l_monitor_launch_date);

       -- SOLIN, 02/25/2003, bug 2801660
       l_reminder_defined :=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'REMINDER_DEFINED');
/* 3/24/03 swkhanna commented out
       IF l_reminder_defined = 'Y'
       THEN
           wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'CURRENT_REMINDERS',
                                  avalue   => 1);
       END IF;
*/
       -- SOLIN, end bug 2801660

       result := 'COMPLETE:Y'   ;

 elsif l_monitor_found = 'N' then
      result := 'COMPLETE:N';
end if;
  END IF;


EXCEPTION
    WHEN OTHERS THEN
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
      END IF;
        wf_core.context(
            itemtype,
            'SET_RESTART_ATTR',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END SET_RESTART_ATTR;

procedure set_timelag
(p_start_date in date,
 p_timeout in out NOCOPY number,
 x_due_date out NOCOPY date,
x_total_timeout out nocopy number) is

l_timeout number;
 l_due_date date;
 l_no_of_wkend number;
 l_matched_GMT_date date;
 l_server_timezone_id number;
 l_GMT_timezone_id number;
l_total_timeout number;

begin


   l_timeout := p_timeout;
   l_total_timeout := p_timeout;

/* 3/20/03 swkhanna - commented out following to fix bug 2832001
   l_server_timezone_id :=  fnd_profile.value('AMS_SYSTEM_TIMEZONE_ID');

   select timezone_id
   into l_GMT_timezone_id
   from hz_timezones_vl
   where name = 'GMT';
*/
      l_due_date := p_start_date + l_timeout;
      l_no_of_wkend := trunc(l_timeout/5);

      -- Here the timeout means the number of business days excluding weekends
      -- If the timeout crosses the weekends the number of weekends will be added
      -- to the timeout date

      IF l_no_of_wkend <> 0 THEN

	 l_due_date := l_due_date + l_no_of_wkend*2;
	 l_total_timeout := l_total_timeout + l_no_of_wkend*2;

      ELSE

         -- If the timeout does not cross the weekend i.e < 5 and
	 -- the day of the assignment is on thursday or friday then
	 -- the weekend will be added to the timeout date

	 IF  (to_char(sysdate, 'D') <> 7)  THEN

	      IF to_char(sysdate,'D') > to_char(sysdate+l_timeout,'D')
	      AND l_timeout > 0
	      THEN

		 l_due_date := l_due_date+2;
	         l_total_timeout := l_total_timeout + 2;


  	      END IF;

         END IF;

      END IF;


      -- If the assignment is done in the weekend the
      -- actual day the timeout starts will
      -- be from the following business day

      IF to_char(sysdate,'D') = 7  THEN

         l_due_date := l_due_date + 2;
	 l_total_timeout := l_total_timeout + 2;

      ELSIF to_char(sysdate,'D') = 1 THEN

	 l_due_date := l_due_date + 1;
	 l_total_timeout := l_total_timeout + 1;

      END IF;

      -- If the timeout falls on the weekend

      IF (to_char(l_due_date, 'D') = 1)  OR (to_char(l_due_date, 'D') = 7)  THEN

          l_due_date := l_due_date + 2;
	 l_total_timeout := l_total_timeout + 2;

      END IF;



     IF l_timeout > 5 THEN

        IF to_char(sysdate,'D') = 5  THEN

           IF mod(l_timeout,5) = 4   THEN

              l_due_date := l_due_date+2;
	      l_total_timeout := l_total_timeout + 2;

       END IF;

    ELSIF  to_char(sysdate,'D') = 6 THEN

       IF mod(l_timeout,5) = 4 OR  mod(l_timeout,5) = 3  THEN

          l_due_date := l_due_date+2;
	  l_total_timeout := l_total_timeout + 2;

       END IF;

    END IF;


  END IF;

  x_due_date := l_due_date;
  p_timeout := l_timeout;
  x_total_timeout := l_total_timeout ;
 -- set item attribute - timeout_due_date
  /*    update pv_lead_workflows set matched_due_date = l_matched_due_date,
             object_version_number = object_version_number + 1
      where wf_item_type = p_itemtype
      and   wf_item_key  = p_itemkey;*/


/*      HZ_TIMEZONE_PUB.get_time(
	   p_api_version       => 1.0,
	   p_init_msg_list     => p_init_msg_list,
	   p_source_tz_id      => l_server_timezone_id ,
	   p_dest_tz_id        => l_GMT_timezone_id ,
	   p_source_day_time   => l_due_date,
	   x_dest_day_time     => l_matched_GMT_date,
	   x_return_status     => x_return_status,
	   x_msg_count         => x_msg_count,
	   x_msg_data          => x_msg_data);


     l_matched_GMT_time  := to_char(l_matched_GMT_date,'DD-MON-YYYY HH:MI')||' '||'GMT';*/


 /*  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Matched GMT timeout is  '|| l_matched_GMT_time);
      fnd_msg_pub.Add;
   END IF;



      wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => pv_workflow_pub.g_wf_attr_matched_timeout,
                                   avalue   => l_timeout*60*24);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => pv_workflow_pub.g_wf_attr_matched_timeout_dt,
                                   avalue   => l_matched_GMT_time);*/
end set_timelag;

Procedure get_lead_owner
   ( itemtype         IN  VARCHAR2,
     itemkey          IN  VARCHAR2)
is

 l_sales_lead_id         NUMBER;
 l_assign_date 		DATE;
 l_resource_id		NUMBER;
 l_person_id		NUMBER;
 l_group_id		NUMBER;
 l_notify_owner		VARCHAR2(60);
 l_notify_manager	VARCHAR2(60);
 l_lead_owner_fullname 	VARCHAR2(60);
 l_lead_owner_username	VARCHAR2(60);
 l_notify_role_list	VARCHAR2(500);
 l_notify_role		VARCHAR2(60);
 l_manager_username	VARCHAR2(60);
 l_mgr_resource_id	NUMBER;

   l_notify_display_name varchar2(100);
  l_email_address varchar2(100);
  l_notification_pref varchar2(100);
  l_language varchar2(100);
 l_territory varchar2(100);
 l_number number;


l_own_source_id	   NUMBER;
l_own_source_name  VARCHAR2(360);
l_own_source_email VARCHAR2(2000);
l_own_name         VARCHAR2(320);
l_own_display_name VARCHAR2(360);
l_mgr_source_id    NUMBER;
l_mgr_source_name  VARCHAR2(360);
l_mgr_source_email VARCHAR2(2000);
l_mgr_name         VARCHAR2(320);
l_mgr_display_name VARCHAR2(360);
l_default_resource_id	   NUMBER :=  fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
l_source_username	VARCHAR2(60);


-- Get lead info
CURSOR c_get_lead_details (c_sales_lead_id NUMBER) IS
    SELECT assign_date, assign_to_salesforce_id, assign_sales_group_id, assign_to_person_id
    FROM   as_sales_leads
    WHERE  sales_lead_id = c_sales_lead_id;

CURSOR c_lead_owner (c_lead_id number) IS
    SELECT  usr.user_name
    FROM    as_sales_leads lead, fnd_user usr
    WHERE   lead.sales_lead_id = c_lead_id
    and     lead.assign_to_person_id =  usr.employee_id;


CURSOR c_lead_owner_fullname (c_assign_to_salesforce_id number) is
select source_first_name || ' '||source_last_name
from jtf_rs_resource_extns
where resource_id = c_assign_to_salesforce_id;

Cursor c_get_mgr_username (c_resource_id number, c_group_id number) is
          select usr.user_name, res.resource_id
             from jtf_rs_rep_managers mgr, fnd_user usr, jtf_rs_resource_extns res
            where mgr.manager_person_id = res.source_id
             and res.user_id = usr.user_id
             and mgr.resource_id= c_resource_id
             and mgr.group_id = c_group_id
             and mgr.start_date_active <= SYSDATE
             and (mgr.end_date_active IS NULL OR mgr.end_date_active >= SYSDATE)
             and mgr.reports_to_flag = 'Y';



-- 5/2/03 add cursor
Cursor c_get_resource_info(c_resource_id number) is
   select source_id, source_name, source_email, user_name
   from  jtf_rs_resource_extns
   where resource_id = c_resource_id;

Begin

         l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'SALES_LEAD_ID');


         l_notify_owner :=    wf_engine.GetItemAttrText
                                    (itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'NOTIFY_LEAD_OWNER');


         l_notify_manager :=  wf_engine.GetItemAttrText(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'NOTIFY_LD_OWNR_MANAGER');

      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_sales_lead_id :' || l_sales_lead_id);
      END IF;

      -- Get Lead Details
       open c_get_lead_details(l_sales_lead_id);
       fetch c_get_lead_details into  l_assign_date, l_resource_id, l_group_id, l_person_id ;
       close c_get_lead_details;

      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_resource_id :' || l_resource_id);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_group_id :' || l_group_id);
      END IF;


                wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'NOTIFY_LEAD_OWNER',
                                      avalue   => l_notify_owner);


                wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'NOTIFY_LD_OWNR_MANAGER',
                                      avalue   => l_notify_manager);

             OPEN  c_lead_owner_fullname (l_resource_id);
             FETCH c_lead_owner_fullname into l_lead_owner_fullname;
             CLOSE c_lead_owner_fullname;


                wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'LEAD_OWNER',
                                   avalue   => l_lead_owner_fullname);


-- Send Notifications as per following Logic
-- First check if there is an fnd_user entry
-- if yes, add the user_name to adhoc role
-- if not, create adhoc user and add the addhoc user to adhoc role
-- Also in this case a notification to go out to AS_DEFAULT_RESOURCE_ID


     if l_notify_owner = 'Y' then

         -- Try to get lead owner's username from fnduser
          OPEN c_lead_owner (l_sales_lead_id);
          FETCH c_lead_owner INTO l_lead_owner_username;
          CLOSE c_lead_owner;


         if l_lead_owner_username is not null then
            l_notify_role_list := l_notify_role_list||','||l_lead_owner_username;

              wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_USERNAME',
                                avalue   => l_lead_owner_username);


         else
             -- if no fnd_user  record, then send email only
             -- need to create adhoc role. get per people info
             OPEN c_get_resource_info(l_resource_id);
             FETCH c_get_resource_info
             INTO l_own_source_id, l_own_source_name, l_own_source_email, l_lead_owner_username;
             CLOSE c_get_resource_info;

          -- create adhocuser
          	wf_directory.CreateAdHocUser(name => l_own_name,
                                       display_name => l_own_display_name,
                                       language => null,
                                       territory => null,
                                       description => 'Adhoc role for owner for lead:'||l_sales_lead_id,
                                       notification_preference => 'MAILHTML',
                                       email_address => l_own_source_email,
                                       fax => null,
                                       status => 'ACTIVE',
                                       expiration_date => null);


                l_notify_role_list := l_notify_role_list||','||l_own_name;

               wf_engine.SetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'LEAD_OWNER_USERNAME',
                                         avalue   => l_own_name);

             --
             -- in this case also send notification to AS_DEFAULT_RESOURCE_ID

                OPEN c_get_resource_info(l_default_resource_id);
                FETCH c_get_resource_info
                INTO l_own_source_id, l_own_source_name, l_own_source_email, l_source_username;
                CLOSE c_get_resource_info;

               if l_source_username is not null then
                l_notify_role_list := l_notify_role_list||','||l_source_username;
               end if;

            end if; -- if fnd user

      IF (AS_DEBUG_LOW_ON) THEN
         AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, '1' || l_notify_role_list);
      END IF;

     end if;  -- if notify_owner


    wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_RESOURCE_ID',
                                avalue   => l_resource_id);

/*    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_USERNAME',
                                --avalue   => l_lead_owner_username);
                                avalue   => l_own_name);

*/

    if l_notify_manager = 'Y' then
          -- Get manager username

      Open c_get_mgr_username (l_resource_id, l_group_id);
      loop
             fetch c_get_mgr_username into l_manager_username, l_mgr_resource_id;
             exit when c_get_mgr_username%NOTFOUND;

         if l_manager_username = l_lead_owner_username  then
                null;
         elsif l_manager_username is not null then
                select  instr(l_notify_role_list, l_manager_username) into l_number from dual;
                if l_number = 0 then
                    l_notify_role_list := l_notify_role_list||','||l_manager_username;
                else
                 null;
                end if;

                wf_engine.SetItemAttrText(itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LEAD_OWNER_MGR_USERNAME',
                                          avalue   => l_manager_username);

             --
         elsif l_manager_username is null then
                  -- get Mgr resource info
       		 OPEN c_get_resource_info(l_mgr_resource_id);
                 FETCH c_get_resource_info
                 into l_mgr_source_id, l_mgr_source_name, l_mgr_source_email,l_manager_username;
                 CLOSE c_get_resource_info;

              -- create adhoc user
                 wf_directory.CreateAdHocUser(name => l_mgr_name,
                                       display_name => l_mgr_display_name,
                                       language => null,
                                       territory => null,
                                       description => 'Adhoc role for Manager for lead:'||l_sales_lead_id,
                                       notification_preference => 'MAILHTML',
                                       email_address => l_mgr_source_email,
                                       fax => null,
                                       status => 'ACTIVE',
                                       expiration_date => null);


                  select  instr(l_notify_role_list, l_mgr_name) into l_number from dual;
                   if l_number = 0 then
                      l_notify_role_list := l_notify_role_list||','||l_mgr_name;
                   else
                       null;
                   end if;

                    wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_MGR_USERNAME',
                                avalue   => l_mgr_name);

          end if;

      end loop;
      close c_get_mgr_username;

       if l_mgr_resource_id is not null and l_mgr_resource_id <> 0 then

                   wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_MGR_RESOURCE_ID',
                                avalue   => l_mgr_resource_id);

/*
                 wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'LEAD_OWNER_MGR_USERNAME',
                                --avalue   => l_manager_username);
                                avalue   => l_mgr_name);
*/

       end if;
   end if; --l_notify_manager = Y

      l_notify_role_list := substr(l_notify_role_list,2);
      l_notify_role := 'AML_' || itemKey;

    IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, '8' || l_notify_role_list);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_notify_role :' || l_notify_role);
    END IF;

          -- Create Role

   wf_directory.RemoveUsersFromAdHocRole
     (role_name => l_notify_role,
      role_users => null);


 -- add new set of users
      wf_directory.AddUsersToAdHocRole
     (role_name => l_notify_role,
      role_users => l_notify_role_list);

 IF (AS_DEBUG_LOW_ON) THEN
  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'After calling adduserstoadhocrole :');
 END IF;


	wf_engine.SetItemAttrText (    ItemType =>   itemType,
				                    ItemKey  => itemKey,
                                    aname    => 'NOTIFY_ROLE',
                                    avalue   => l_notify_role);

 IF (AS_DEBUG_LOW_ON) THEN
  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'After setting notify role value :');
 END IF;

exception
when others then
  IF (AS_DEBUG_LOW_ON) THEN
     AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        SQLERRM);
  END IF;
raise;

end get_lead_owner;

END AML_MONITOR_WF;

/
