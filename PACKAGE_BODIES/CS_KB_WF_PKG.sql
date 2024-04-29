--------------------------------------------------------
--  DDL for Package Body CS_KB_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_WF_PKG" AS
/* $Header: cskbwfb.pls 120.3.12010000.2 2008/09/10 04:52:05 mmaiya ship $ */


/****************************************************
-------------PACKAGE VARIABLES ----------------------
****************************************************/
  BAD_INFORMATION_SUPPLIED EXCEPTION;
  LOCK_SET_ERROR EXCEPTION;
  PERMISSION_ERROR EXCEPTION;


/****************************************************
-------------FUNCTIONS-------------------------------
****************************************************/


/**************************** Get Action *************************/
-- This function is used to get the action code of a flow_details_id
--
-- VARIABLES
-- g_flow_details_id
-- OUT: ActionCode or NULL
/*******************************************************************/

FUNCTION getAction(
    g_flow_details_id    IN  NUMBER
    )
    RETURN VARCHAR2
    IS
      returnValue VARCHAR2(10);
    BEGIN
	-- return NULL if g_flow_details_id doesn't match
        SELECT
            MAX(action)
        INTO
            returnValue
        FROM
	       cs_kb_wf_flow_details
        WHERE
          flow_details_id = g_flow_details_id;
        RETURN returnValue;
    END;


/**************************** Get Action Name *************************/
-- This function is used to get the action name given action lookup code
--
-- VARIABLES
-- IN: g_action, action code
-- OUT: action meaning
/**********************************************************************/

FUNCTION getActionName(
    g_action    IN  VARCHAR2
    )
    RETURN VARCHAR2
    IS
        returnValue CS_LOOKUPS.MEANING%TYPE;
    BEGIN
        SELECT
            MAX(MEANING)
        INTO
            returnValue
        FROM
            CS_LOOKUPS
        WHERE
            lookup_code = g_action
        AND
            lookup_type = 'CS_KB_INTERNAL_CODES';

        RETURN returnValue;
    END;

/**************************** Get Flow Id *************************/
-- This function is used to get the flow id of a flow_details_id
--
--
-- VARIABLES
-- g_flow_details_id
/*******************************************************************/

FUNCTION getFlowId(
    g_flow_details_id    IN  NUMBER
    )
    RETURN NUMBER
    IS
      returnValue NUMBER;
    BEGIN
        SELECT
            MAX(flow_id)
        INTO
            returnValue
        FROM
	       cs_kb_wf_flow_details
        WHERE
          flow_details_id = g_flow_details_id;
        RETURN returnValue;
    END;


/**************************** Get Status *****************/
-- This function is to get a status for display.  It will display
-- a translated sets_b.status or flow_details.step, according
-- to whether a step is available
--
--
-- VARIABLES
-- g_setId -- set Id
/*******************************************************************/

FUNCTION getStatus(
    g_setId    IN  NUMBER
    )
    RETURN VARCHAR2
    IS
        returnValue CS_LOOKUPS.MEANING%TYPE;
 BEGIN
        SELECT
            MAX(DECODE(B.STATUS,'NOT',LU2.MEANING,LU1.MEANING))
        INTO
            returnValue
        FROM
            cs_kb_sets_b B,
            cs_kb_wf_flow_details D,
            CS_LOOKUPS LU1,
            CS_LOOKUPS LU2
        WHERE
            B.flow_details_id = D.flow_details_id (+)
        AND
            B.status = LU1.lookup_code
        AND
	    D.STEP = LU2.lookup_code(+)
        AND
            LU1.lookup_type = 'CS_KB_INTERNAL_CODES'
        AND
            LU2.lookup_type(+) = 'CS_KB_STATUS'
        AND
            B.set_id = g_setId;

        RETURN returnValue;
 END;


/**************************** Get Step Group *****************/
-- This function is used to get the group id associated with a
-- specific step.
--
-- VARIABLES
-- g_flow_details_id
/*******************************************************************/

FUNCTION getStepGroup(
    g_flow_details_id IN NUMBER
    )
    RETURN NUMBER
    IS
        return_number NUMBER := 0;
    BEGIN
         -- MIN() is used to force a value to return and avoid NDF error
        SELECT
            MIN(GROUP_ID)
        INTO
            return_number
        FROM
            CS_KB_WF_FLOW_DETAILS
        WHERE
            FLOW_DETAILS_ID = g_flow_details_id;

        RETURN return_number;
     EXCEPTION
        WHEN OTHERS THEN
            return null;
     END getStepGroup;


/**************************** HAS PERMISSION *************************/
-- This function is used to determine if a specified user has permissions
-- to a specific Step.
--
-- This one does NOT have profile checking and is used internally mainly.
--
-- VARIABLES
-- h_Step = Step to check
-- h_set_id
/*******************************************************************/
FUNCTION hasPermission(
  h_flow_details_id  IN  NUMBER,
  h_user_id  IN  NUMBER
  )
  RETURN NUMBER
  IS
    gid NUMBER;
  BEGIN
    gid := getStepGroup(h_flow_details_id);
    IF (isMember(h_user_id,gid) = 1) THEN
        RETURN 1;
    END IF;
    RETURN 0;
  END hasPermission;


/**************************** HAS PERMISSION *************************/
-- This function is used to determine if a specified user has permissions
-- to a specific Step.
--
-- This one DOES have profile checking.
--
-- VARIABLES
-- h_Step = Step to check
-- h_user_id = the fnd_user user id
-- h_set_id
/*******************************************************************/
--FUNCTION hasPermission(
--  h_flow_details_id  IN  NUMBER,
--  h_user_id  IN  NUMBER,
--  h_set_id IN NUMBER
--  )
--  RETURN NUMBER
--  IS
--    gid NUMBER;
--  BEGIN
--    gid := getStepGroup(h_flow_details_id);
--    IF (isMember(h_user_id,gid) = 1) THEN
--        IF ((inCategory(h_user_id,h_set_id) = 1) OR (inProduct(h_user_id,h_set_id) = 1)) THEN
--            RETURN 1;
--        END IF;
--    END IF;
--    RETURN 0;
--  END hasPermission;


/**************************** IN CATEGORY *************************/
-- This function is used to determine if a specified user has permissions
-- to a specific Step.
--
-- VARIABLES
-- h_Step = Step to check
-- h_user_id = the fnd_user user id
--
/*******************************************************************/
FUNCTION inCategory(
  c_user_id  IN  NUMBER,
  c_set_id  IN  NUMBER
  )
  RETURN NUMBER
  IS
    CURSOR cats IS
     SELECT category_id
     FROM CS_KB_SET_CATEGORIES
     WHERE set_id = c_set_id;

    catId NUMBER;
    returnValue NUMBER := 0;
  BEGIN
    OPEN cats;
    LOOP
        -- Get values from cursor.
        FETCH cats INTO catId;
        EXIT WHEN cats%NOTFOUND;
        IF (CS_KB_PROFILES_PKG.isCategoryMember(c_user_id,catId) = 1) THEN
            returnValue := 1;
            EXIT;
        END IF;
    END LOOP;
    CLOSE cats;
    RETURN returnValue;

EXCEPTION
    WHEN OTHERS THEN
        CLOSE cats;
        RAISE;
END inCategory;


/**************************** IN PRODUCT *************************/
-- This function is used to determine if a user belongs to same
-- product as solution.
--
-- VARIABLES
-- c_user_id = Step to check
-- c_set_id = the fnd_user user id
--
/*******************************************************************/
FUNCTION inProduct(
  c_user_id  IN  NUMBER,
  c_set_id  IN  NUMBER
  )
  RETURN NUMBER
  IS
    CURSOR prods IS SELECT
                        product_id, product_org_id
                    FROM
                        cs_kb_set_products
                    WHERE
                        set_id = c_set_id;
    prodId NUMBER;
    prodOrgId NUMBER;
    returnValue NUMBER := 0;
  BEGIN
    OPEN prods;
    LOOP
        FETCH prods INTO prodId,prodOrgId;
        EXIT WHEN prods%NOTFOUND;

        IF (CS_KB_PROFILES_PKG.isProductMember(c_user_id,prodId,prodOrgId) = 1) THEN
            returnValue := 1;
            EXIT;
        END IF;
    END LOOP;
    CLOSE prods;
    RETURN returnValue;

EXCEPTION
    WHEN OTHERS THEN
        CLOSE prods;
        RAISE;
END inProduct;


/**************************** isMember ********************************/
-- This function is used to determine if a specified user belongs
-- to a specified notification group.
--
-- INTERNAL USE MAINLY
--
-- VARIABLES
-- user_id = the fnd_user user id
-- group_id =
--
/*******************************************************************/
FUNCTION isMember(
  m_user_id IN NUMBER,
  m_group_id IN NUMBER
  )
  RETURN NUMBER
  IS
    m_temp NUMBER;
    return_value NUMBER;
  BEGIN
        SELECT
            min(fnd_user.user_id)
        INTO
            m_temp
        FROM
            fnd_user,
            jtf_rs_resource_extns,
            jtf_rs_group_members
        WHERE
            jtf_rs_group_members.resource_id=jtf_rs_resource_extns.resource_id
        AND
            fnd_user.user_id=m_user_id
        AND
            jtf_rs_group_members.group_id=m_group_id
 	AND jtf_rs_group_members.DELETE_FLAG <>'Y'
	AND jtf_rs_resource_extns.START_DATE_ACTIVE <= sysdate
	AND NVL(jtf_rs_resource_extns.END_DATE_ACTIVE, sysdate) >= sysdate
        AND (
                (jtf_rs_resource_extns.source_id = fnd_user.employee_id
             AND
                jtf_rs_resource_extns.category ='EMPLOYEE')
        OR
                (jtf_rs_resource_extns.source_id = fnd_user.customer_id
             AND
                jtf_rs_resource_extns.category ='PARTY'));


        -- set return value to TRUE if something is found.
        if (m_temp = m_user_id) THEN
            return_value := 1;
        ELSE
            return_value := 0;
        END IF;

        RETURN return_value;
  END isMember;

/**************************** CREATE WF PROCESS ********************************/
-- This is an internal procedure to create a process.
/*******************************************************************************/

PROCEDURE Create_Wf_Process(
  p_set_id          IN NUMBER,
  p_set_number      IN VARCHAR2,
  p_command         IN VARCHAR2,
  p_flow_details_id IN NUMBER,
  p_group_id        IN NUMBER,
  p_solution_title  IN VARCHAR2
  ) IS

    p_itemtype VARCHAR2(20) := 'CS_KB_W1';
    wf_process VARCHAR2(20) := 'WFPROCESS';
    p_itemkey VARCHAR(20) := p_set_id;
    x_step_code	varchar2(30);
    x_step_meaning   varchar2(80);
    l_pub VARCHAR2(2000);
    l_obs VARCHAR2(2000);


  BEGIN

  -- Create workflow process.
  WF_ENGINE.CreateProcess(p_itemtype, p_itemkey, wf_process);

  -- Set Attributes.
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'SETNO', p_set_number);
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'SETID', p_set_id);
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'COMMAND', p_command);
  IF (p_command = 'PUB') THEN
      l_pub := fnd_message.GET_STRING('CS','CS_KB_WF_PUB');
     WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey,
	'COMMAND_DISPLAY', l_pub); -- 'Published');
  ELSIF (p_command = 'OBS') THEN
     l_obs := fnd_message.GET_STRING('CS','CS_KB_WF_OBS');
     WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey,
	'COMMAND_DISPLAY', l_obs); --'Obsoleted');
  END IF;
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'LANGUAGE', FND_GLOBAL.CURRENT_LANGUAGE);

  IF (p_flow_details_id is not null) THEN
    WF_ENGINE.SetItemAttrNumber(p_itemtype, p_itemkey, 'FLOW_DETAILS_ID', p_flow_details_id);
    select step into x_step_code
    from cs_kb_wf_flow_details
    where flow_details_id = p_flow_details_id;

    SELECT MAX(MEANING)
    INTO x_step_meaning
    FROM CS_LOOKUPS
    WHERE lookup_code = x_step_code
    AND lookup_type = 'CS_KB_STATUS';

    WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'FLOWSTEP', x_step_meaning);

  END IF;

  IF (p_group_id is not null) THEN
    WF_ENGINE.SetItemAttrNumber(p_itemtype, p_itemkey, 'GROUPID', p_group_id);
  END IF;

  IF (p_solution_title is not null) THEN
    WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'SOLTITLE', p_solution_title);
  END IF;

  -- Start workflow process.
  wf_engine.StartProcess(p_itemtype, p_itemkey);

  EXCEPTION
    WHEN OTHERS THEN
        RAISE;
  END Create_Wf_Process;

/**************************** CREATE REJECT TO AUTHOR PROCESS ********************************/
-- This is an internal procedure to create a process to reject to author.
/*******************************************************************************/

PROCEDURE Create_Reject_Process(
  p_set_id          IN NUMBER,
  p_set_number      IN VARCHAR2,
  p_solution_title  IN VARCHAR2,
  p_author	    IN VARCHAR2
  ) IS

    p_itemtype VARCHAR2(20) := 'CS_KB_W1';
    wf_process VARCHAR2(20) := 'REJPROCESS';
    p_itemkey  VARCHAR(200) := to_char(p_set_id) || '-' || p_author; --7117561, 7047779

  BEGIN
  -- Create workflow process.
  WF_ENGINE.CreateProcess(p_itemtype, p_itemkey, wf_process);

  -- Set Attributes.
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'SETNO', p_set_number);
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'SETID', p_set_id);
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'LANGUAGE', FND_GLOBAL.CURRENT_LANGUAGE);
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'AUTHOR', p_author);

  -- Set the From field:
  WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'NOTFROM', FND_GLOBAL.User_Name);

  IF (p_solution_title is not null) THEN
    WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'SOLTITLE', p_solution_title);
  END IF;

  -- Start workflow process.
  wf_engine.StartProcess(p_itemtype, p_itemkey);

  EXCEPTION
    WHEN OTHERS THEN
        RAISE;
  END Create_Reject_Process;

/**************************** END WF *******************************************/
-- This procedure is basically an empty space to place any actions that are
-- desired to happen when a workflow step is complete.
-- Called within workflow
/*******************************************************************************/
PROCEDURE End_Wf(
  p_itemtype  IN VARCHAR2,
  p_itemkey   IN VARCHAR2,
  p_actid     IN NUMBER,
  p_funcmode  IN VARCHAR2,
  p_result    OUT NOCOPY VARCHAR2
  ) IS

  BEGIN
    -- Place anything here
    --COMMIT;
    null;
  END;

  /**************************** Expire Detail ********************/
-- This Procedure is used to "soft-delete" a detail line from the
-- cs_kb_wf_flow_details table
--
-- VARIABLES
-- p_flow_details_id
-- p_result: p_flow_details_id = completed successfully, -1 = error
/*******************************************************************/
PROCEDURE Expire_Detail(
  p_flow_details_id IN NUMBER,
  p_result OUT NOCOPY NUMBER
  )
  IS
    uid NUMBER := fnd_global.user_id;
    dt DATE := SYSDATE;
    BEGIN

        UPDATE CS_KB_WF_FLOW_DETAILS
        SET end_date = SYSDATE-1,
            last_updated_by = uid,
            last_update_date = dt
        WHERE
            flow_details_id = p_flow_details_id;

        --COMMIT;
        p_result := p_flow_details_id;
    EXCEPTION
        WHEN OTHERS THEN
            p_result := -1;
    END Expire_Detail;

/**************************** Expire Flow ********************/
-- This Procedure is used to "soft-delete" a flow from the
-- cs_kb_wf_flows_b table
--
-- VARIABLES
-- p_flow_id
-- p_result: 1 = completed successfully, -1 = error
/*******************************************************************/
PROCEDURE Expire_Flow(
  p_flow_id IN NUMBER,
  p_result OUT NOCOPY NUMBER
  )
  IS
    uid NUMBER := fnd_global.user_id;
    dt DATE := SYSDATE;

    CURSOR CHECK_FLOW_EXITS (flowId NUMBER) IS
    SELECT count(*)
    FROM CS_KB_WF_FLOWS_B
    WHERE flow_id = flowId;

    CURSOR CHECK_DEFAULT_FLOWS (flowId NUMBER) IS
    SELECT count(*)
    FROM fnd_profile_options o,
         fnd_profile_option_values ov
    WHERE o.profile_option_name = 'CS_KB_DEFAULT_FLOW'
    AND o.profile_option_id = ov.profile_option_id
    AND ov.PROFILE_OPTION_VALUE = to_char(flowId)
    AND ov.application_id = 170;

    v_def_count NUMBER := 0;
    v_count     NUMBER := 0;

    BEGIN
      OPEN  CHECK_FLOW_EXITS(p_flow_id);
      FETCH CHECK_FLOW_EXITS INTO v_count;
      CLOSE CHECK_FLOW_EXITS;

      IF v_count = 1 THEN

        OPEN  CHECK_DEFAULT_FLOWS(p_flow_id);
        FETCH CHECK_DEFAULT_FLOWS INTO v_def_count;
        CLOSE CHECK_DEFAULT_FLOWS;

        IF v_def_count = 0 THEN

          UPDATE CS_KB_WF_FLOWS_B
          SET end_date = dt,
              last_updated_by = uid,
              last_update_date = dt
          WHERE
              flow_id = p_flow_id;

          p_result := 1;
        ELSE --Flow is set against a Prof Option, so cant end date
          p_result := -3;
        END IF;
      ELSE -- Invalid Flow id passed to api
        p_result := -1;
      END IF;

    EXCEPTION
        WHEN OTHERS THEN
            p_result := -2;
    END Expire_Flow;


  /**************************** Enable Flow ********************/
-- This Procedure is used to re-activate an End-Dated Flow
-- in the cs_kb_wf_flows_b table
--
-- VARIABLES
-- p_flow_id
-- p_result: 1 = completed successfully, -1 = error
/*******************************************************************/
  PROCEDURE Enable_Flow( p_flow_id IN NUMBER,
                         p_result  OUT NOCOPY NUMBER )  IS
   uid NUMBER := fnd_global.user_id;
   dt DATE := SYSDATE;

   CURSOR CHECK_FLOW_EXITS (flowId NUMBER) IS
   SELECT count(*)
   FROM CS_KB_WF_FLOWS_B
   WHERE flow_id = flowId;

   v_count     NUMBER := 0;

  BEGIN

   OPEN  CHECK_FLOW_EXITS(p_flow_id);
   FETCH CHECK_FLOW_EXITS INTO v_count;
   CLOSE CHECK_FLOW_EXITS;

   IF v_count = 1 THEN

     UPDATE CS_KB_WF_FLOWS_B
        SET end_date = null,
            last_updated_by = uid,
            last_update_date = dt
      WHERE flow_id = p_flow_id;

     p_result := 1;
   ELSE -- Invalid Flow id passed to api
     p_result := -1;
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
         p_result := -2;
  END Enable_Flow;

  /**************************** Get Actions ********************/
-- This Procedure is used to get a list of actions
--
-- VARIABLES
-- p_action_code = group ids
-- p_action_name = group names
/*******************************************************************/
PROCEDURE Get_Actions(
  p_action_code OUT NOCOPY JTF_VARCHAR2_TABLE_100,
  p_action_name OUT NOCOPY JTF_VARCHAR2_TABLE_100)
  IS
   l_resp_id number;
   l_application_id number := 170;
   l_region_code varchar2(30) := 'CS_KB_WF_ACTION';
   l_user_id number := fnd_global.user_id;
   region_name varchar2(50);
   empty_str         varchar2(30) := ' ';
   items_table jtf_region_pub.ak_region_items_table;
   code JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   name JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
  BEGIN

    l_resp_id :=  FND_PROFILE.VALUE_SPECIFIC(
                  'JTF_PROFILE_DEFAULT_RESPONSIBILITY',
                  l_user_id,
                  null,
                  null);

    jtf_region_pub.get_region(l_region_code,
                  l_application_id,
                  l_resp_id,
                  empty_str,
                  region_name,
                  empty_str,
                  items_table);
    FOR l in 1..items_table.count LOOP
    	name.extend;
    	name(l) := jtf_region_pub.get_region_item_name(
                              items_table(l).attribute_code,
                              l_region_code);
    END LOOP;

    code.extend;
    code(1) := 'NOT';
    code.extend;
    code(2) := 'PUB';
    code.extend;
    code(3) := 'OBS';

    p_action_code := code;
    p_action_name := name;
  EXCEPTION
	when others then
	-- return empty array
		p_action_code := code;
		p_action_name := name;

  END Get_Actions;



  /**************************** Get All Groups ********************/
-- This Procedure is used to get all groups ids and names so that
-- the GUI can populate a drop down list.
--
-- VARIABLES
-- p_group_id = group ids
-- p_group_name = group names
/*******************************************************************/
PROCEDURE Get_All_Groups(
  p_group_id        OUT NOCOPY JTF_NUMBER_TABLE,
  p_group_name      OUT NOCOPY JTF_VARCHAR2_TABLE_100
  )
  IS

  -- Create the table variables to hold returnable info.
  t_group_id JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  t_group_name JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

  -- Temp variables to use to populate table variables
  gi    NUMBER;
  gn    JTF_RS_GROUPS_TL.GROUP_NAME%TYPE;

  counter NUMBER := 1;

  CURSOR All_Groups IS
   SELECT g.GROUP_ID,
          g.GROUP_NAME
   FROM  JTF_RS_GROUPS_VL g,
         JTF_RS_GROUP_USAGES u
   WHERE g.GROUP_ID = u.GROUP_ID
   AND u.USAGE = 'ISUPPORT'
   AND NVL(g.END_DATE_ACTIVE, sysdate) >= sysdate
   ORDER BY g.GROUP_NAME;

  BEGIN
        OPEN All_Groups;
        LOOP

            -- Get values from cursor.
            FETCH All_Groups INTO gi,gn;
            EXIT WHEN All_Groups%NOTFOUND;

            -- Extending tables one.
            t_group_id.extend;
            t_group_name.extend;


            -- Setting table variables to value of temp variables
            t_group_id(counter) := gi;
            t_group_name(counter) := gn;

            -- Increment counter.
            counter := counter + 1;
        END LOOP;
        CLOSE All_Groups;

    p_group_id := t_group_id;
    p_group_name := t_group_name;

  EXCEPTION
    WHEN OTHERS THEN
        CLOSE All_Groups;
        RAISE;
  END;

/**************************** Get All Steps *****************/
-- This Procedure is used to get a list of all the available
-- steps.  This procedure is intended for use with the admin
-- pages used to set up flows.
--
-- WRAPPER FOR GET_STEP_LIST
--
-- VARIABLES
-- p_step = a list of all of the available step codes
-- p_step_names = a list of all the names that correspond to the
--                  above list of codes.
/*******************************************************************/

PROCEDURE Get_All_Steps(
    p_step          OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    p_step_names    OUT NOCOPY JTF_VARCHAR2_TABLE_100
    )
    IS
    BEGIN
        Get_Step_List(0,p_step,p_step_names);
    END Get_All_Steps;

/**************************** GET FLOW DETAILS  *******************/
-- This procedure provides the details of a specific flow based on
-- the input.  This is used in the cskstat.jsp page.
-- VARIABLES:
--    p_flow_id (input to get results for)
--    p_flow_details_id - id that matches the sets_b table
--    p_order_num
--    p_step - this is the fnd lookup code
--    p_group_id - id of the jtf_group this is assigned to
--    p_action - NOT(NOTIFY),PUB(PUBLISH),OBS(OBSOLETE)
/*******************************************************************/
PROCEDURE Get_Flow_Details(
    p_flow_id IN NUMBER,
    p_flow_details_id OUT NOCOPY JTF_NUMBER_TABLE,
    p_order_num OUT NOCOPY JTF_NUMBER_TABLE,
    p_step OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    p_group_id OUT NOCOPY JTF_NUMBER_TABLE,
    p_action OUT NOCOPY JTF_VARCHAR2_TABLE_100
    )
    IS
    --tables to return
    t_flow_details_id JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    t_order_num JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    t_step JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
    t_group_id JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    t_action JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();


    CURSOR DETAILS_TABLE IS
        SELECT
            FD.FLOW_DETAILS_ID,
            FD.ORDER_NUM,
            FD.STEP,
            FD.GROUP_ID,
            FD.ACTION
        FROM
            CS_KB_WF_FLOW_DETAILS FD
        WHERE
            FLOW_ID = p_flow_id
        AND
            (BEGIN_DATE <= SYSDATE OR BEGIN_DATE IS NULL)
        AND
            (END_DATE >= SYSDATE OR END_DATE IS NULL)
        ORDER BY
            ORDER_NUM ASC;

    -- Temp variables.
    did CS_KB_WF_FLOW_DETAILS.flow_details_id%TYPE; -- temp flow details id.
    orn NUMBER; -- temp order number
    sta CS_KB_WF_FLOW_DETAILS.step%TYPE; -- temp step
    gid NUMBER; -- temp group id
    act CS_KB_WF_FLOW_DETAILS.action%TYPE; -- temp action
    counter NUMBER := 1;
BEGIN
    OPEN DETAILS_TABLE;
    LOOP

        -- Get values from cursor.
        FETCH DETAILS_TABLE INTO did,orn,sta,gid,act;
        EXIT WHEN DETAILS_TABLE%NOTFOUND;


            -- Extending tables one.
            t_flow_details_id.extend;
            t_order_num.extend;
            t_step.extend;
            t_group_id.extend;
            t_action.extend;


            -- Setting table variables to value of temp variables
            t_flow_details_id(counter) := did;
            t_order_num(counter) := orn;
            t_step(counter) := sta;
            t_group_id(counter) := gid;
            t_action(counter) := act;


            counter := counter + 1;
    END LOOP;
    CLOSE DETAILS_TABLE;

    p_flow_details_id := t_flow_details_id;
    p_order_num := t_order_num;
    p_step := t_step;
    p_group_id := t_group_id;
    p_action := t_action;

EXCEPTION
    WHEN OTHERS THEN
        CLOSE DETAILS_TABLE;
        RAISE;
END Get_Flow_Details;

/**************************** GET FLOWS  *************************/
-- This procedure provides the list of possible flows for the use
-- of the UI creating/editting flows
--
-- VARIABLES
-- p_flow_id (id that is needed when updates are made)
-- p_flow_name (name to display)
/*******************************************************************/
PROCEDURE Get_Flows(
    p_flow_id OUT NOCOPY JTF_NUMBER_TABLE,
    p_flow_name OUT NOCOPY JTF_VARCHAR2_TABLE_100
    )
    IS
    --tables to return
    t_flow_id JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    t_flow_name JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

    CURSOR FLOWS_TABLE IS
    select b.flow_id, t.name
    from cs_kb_wf_flows_b b,
         cs_kb_wf_flows_tl t
    where b.flow_id = t.flow_id
    and t.language = userenv('LANG')
    and exists (select flow_id from cs_kb_wf_flow_details d
                where d.flow_id = b.flow_id
                and sysdate between nvl(d.begin_date, sysdate-1)
                                and nvl(d.end_date, sysdate+1)
                )
    and sysdate < nvl(end_date, sysdate+1)
    ORDER BY t.NAME ASC;

    -- Temp variables.
    fid CS_KB_WF_FLOWS_TL.flow_id%TYPE; -- temp step.
    fna CS_KB_WF_FLOWS_TL.name%TYPE; -- temp name
    counter NUMBER := 1;
BEGIN
    OPEN FLOWS_TABLE;
    LOOP

        -- Get values from cursor.
        FETCH FLOWS_TABLE INTO fid,fna;
        EXIT WHEN FLOWS_TABLE%NOTFOUND;


            -- Extending tables one.
            t_flow_id.extend;
            t_flow_name.extend;

            -- Setting table variables to value of temp variables
            t_flow_id(counter) := fid;
            t_flow_name(counter) := fna;


            counter := counter + 1;
    END LOOP;
    CLOSE FLOWS_TABLE;

    p_flow_id := t_flow_id;
    p_flow_name := t_flow_name;

EXCEPTION
    WHEN OTHERS THEN
        CLOSE FLOWS_TABLE;
        RAISE;
END Get_Flows;

  /**************************** GET PERMISSIONS *****************/
-- Given a user_id and set_id, determine the level of permissions
-- that a user has to the solution.  This is mainly used with the
-- manual accept ability.
--
-- Results are as follows:
--                        0 = no permissions
--                        1 = can accept solution task (currently in wf)
--                        2 = user owns it.
-- VARIABLES
-- p_set_id.
-- p_user_id.
-- p_results.
/*******************************************************************/

PROCEDURE Get_Permissions(
    p_set_id  IN  NUMBER,
    p_user_id   IN  NUMBER,
    p_results   OUT NOCOPY NUMBER
    )
    IS
        lockedBy NUMBER;
        status VARCHAR2(10);
        fdid NUMBER; -- flow details id
        setNo VARCHAR2(30);
    BEGIN
         -- Getting information about the record
        CS_KB_SOLUTION_PVT.Get_Set_Details(p_set_id,setNo,status,fdid,lockedBy);

        -- If this user owns the item
        IF (lockedBy = p_user_id) THEN
            p_results := 2;
        -- If workflow owns this item
        ELSIF (lockedBy = -1) THEN
	    -- IF (hasPermission(fdid, p_user_id, p_set_id) = 1) THEN
	    -- lyao:remove p_set_id param so that it skipps the profile check
            IF (hasPermission(fdid, p_user_id) = 1) THEN
                p_results := 1;
            ELSE
                p_results := 0;
            END IF;
        ELSE
            p_results := 0;
        END IF;
END Get_Permissions;

/*********************************************************************
   for a published soln, it may have gone thru multiple workflows.
   Only people who belong to any of the resource groups of those
   workflows can see a CHECKOUT button.  When they click on this button,
   lock will be chcked. (p_results=1)
   Otherwise, no button. (p_results=0)
   If already locked_by this user, still show CHECK OUT.
************************************************************************/
PROCEDURE Get_Permissions_for_PUB_soln(
  p_set_number      IN  VARCHAR2,
  p_user_id         IN  NUMBER,
  p_results         OUT NOCOPY NUMBER ) IS

  -- cursor for all distinct  groups for all flows this solns has gone thru
  CURSOR groups IS
	SELECT DISTINCT details2.GROUP_ID
	FROM cs_kb_wf_flow_details details1,
	     cs_kb_wf_flow_details details2,
	     cs_kb_wf_flows_b flows,
	     cs_kb_sets_b sets
	WHERE
	     sets.SET_NUMBER = p_set_number
	AND  sets.FLOW_DETAILS_ID = details1.FLOW_DETAILS_ID
      	AND  details1.FLOW_ID = flows.FLOW_ID
	AND  flows.FLOW_ID = details2.FLOW_ID;

  x_group_id number;

BEGIN

  p_results := 0;

  OPEN groups;
  LOOP
     FETCH groups INTO x_group_id;
     EXIT WHEN groups%NOTFOUND;
     IF (isMember(p_user_id, x_group_id) = 1) THEN
        p_results := 1;
	EXIT;
     END IF;
  END LOOP;
  CLOSE groups;

EXCEPTION
  WHEN OTHERS THEN
 	p_results :=0;

END Get_Permissions_for_PUB_soln;


  /**************************** Get Step List *****************/
-- This Procedure is used to get a list of steps to be displayed
-- as drop-down list.
--
-- This procedure is for internal use... see wrappers
--
-- VARIABLES
-- p_restriction = 0: no restriction, 1: no actions besides NOT
-- p_step = a list of all of the available step codes
-- p_step_names = a list of all the names that correspond to the
--                  above list of codes.
/*******************************************************************/

PROCEDURE Get_Step_List(
    p_restriction   IN  NUMBER,
    p_step          OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    p_step_names    OUT NOCOPY JTF_VARCHAR2_TABLE_100
    )
    IS

    -- Create the table variables to hold returnable info.
    t_step JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
    t_step_names JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

    steps INTEGER;
    cursorReturn INTEGER;

    SQL1 VARCHAR2(1000) := 'SELECT DISTINCT CS_LOOKUPS.LOOKUP_CODE, CS_LOOKUPS.MEANING FROM CS_LOOKUPS ';
    SQL2 VARCHAR2(1000) := ' WHERE CS_LOOKUPS.LOOKUP_TYPE = :T AND  TRUNC(SYSDATE) BETWEEN Trunc(NVL(start_date_active,sysdate)) AND Trunc(NVL(end_date_active,sysdate)) AND enabled_flag = ''Y'''; --5198112
    SQL3 VARCHAR2(100) := ' ORDER BY CS_LOOKUPS.MEANING ';

    -- Temp variables.
    st CS_LOOKUPS.LOOKUP_CODE%TYPE; -- temp step.
    na CS_LOOKUPS.MEANING%TYPE; -- temp names

    -- Counter variable.
    counter NUMBER := 1;

    BEGIN

        IF(p_restriction = 1) THEN
           SQL1 := SQL1 || ' ,CS_KB_WF_FLOW_DETAILS ';
           SQL2 := SQL2 || ' AND CS_KB_WF_FLOW_DETAILS.STEP = CS_LOOKUPS.LOOKUP_CODE AND CS_KB_WF_FLOW_DETAILS.ACTION = :N ';
         END IF;
            -- open and parse statement
        steps := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(steps, SQL1||SQL2||SQL3, DBMS_SQL.V7);
        DBMS_SQL.BIND_VARIABLE(steps,':T', 'CS_KB_STATUS');

        IF(p_restriction = 1) THEN
            DBMS_SQL.BIND_VARIABLE(steps,':N', 'NOT');
        END IF;

         -- Define output variables
        DBMS_SQL.DEFINE_COLUMN(steps, 1, st,100);
        DBMS_SQL.DEFINE_COLUMN(steps, 2, na,100);


      --Execute cursor
        cursorReturn := DBMS_SQL.EXECUTE(steps);


    /******* LOOPING ********************/

    LOOP
        IF DBMS_SQL.FETCH_ROWS(steps) = 0 THEN
            EXIT;
        END IF;
        -- Loading variables with column values
        DBMS_SQL.COLUMN_VALUE(steps, 1, st);
        DBMS_SQL.COLUMN_VALUE(steps, 2, na);

        -- Extending tables one.
        t_step.extend;
        t_step_names.extend;

        -- Setting table variables to value of temp variables
        t_step(counter) := st;
        t_step_names(counter) := na;

           -- Increment counter.
        counter := counter + 1;
     END LOOP;
     DBMS_SQL.CLOSE_CURSOR(steps);

     IF (p_restriction = 1) THEN
        t_step.extend;
        t_step_names.extend;
        t_step(counter) := 'REJ';
        t_step_names(counter) := getActionName('REJ');
	counter := counter + 1;

        t_step.extend;
        t_step_names.extend;
        t_step(counter) := 'SAV';
        t_step_names(counter) := getActionName('SAV');
     END IF;

     -- set OUT variables.
     p_step := t_step;
     p_step_names := t_step_names;
 EXCEPTION
    WHEN OTHERS THEN
        IF (steps is not null) THEN
            DBMS_SQL.CLOSE_CURSOR(steps);
        END IF;
        RAISE;
    END Get_Step_List;

PROCEDURE Get_Next_Step(
  p_flow_details_id IN NUMBER,
  p_next_details_id OUT NOCOPY NUMBER
) IS
x_flow_id  NUMBER;
x_order_num NUMBER;
x_next_order_num NUMBER;

BEGIN
    x_flow_id := getFlowId(p_flow_details_id);

    select order_num
    into x_order_num
    from CS_KB_WF_FLOW_DETAILS
    where FLOW_DETAILS_ID = p_flow_details_id;


    select  MIN(order_num)
    into x_next_order_num
    from CS_KB_WF_FLOW_DETAILS
    where flow_id = x_flow_id
    and  (BEGIN_DATE <= SYSDATE OR BEGIN_DATE IS NULL)
    and  (END_DATE >= SYSDATE OR END_DATE IS NULL)
    and order_num > x_order_num;

    select flow_details_id
    into p_next_details_id
    from CS_KB_WF_FLOW_DETAILS
    where flow_id = x_flow_id
    and  (BEGIN_DATE <= SYSDATE OR BEGIN_DATE IS NULL)
    and  (END_DATE >= SYSDATE OR END_DATE IS NULL)
    and  order_num = x_next_order_num;


EXCEPTION
    WHEN OTHERS THEN
    p_next_details_id := -1;

END Get_Next_Step;

FUNCTION Is_Step_Disabled ( P_FLOW_ID NUMBER,
                            P_FLOW_DETAILS_ID NUMBER,
                            P_FLOW_DETAILS_ORDER NUMBER,
                            P_CURRENT_FLOW_DETAILS_ID NUMBER) RETURN VARCHAR2
IS

 CURSOR Get_First_Step IS
  SELECT Flow_Details_Id
  FROM CS_KB_WF_FLOW_DETAILS
  WHERE Flow_id = P_FLOW_ID
  AND sysdate between nvl(begin_date, sysdate-1)
                  and nvl(end_date, sysdate+1)
  AND Order_Num = ( SELECT min(order_num)
                    FROM CS_KB_WF_FLOW_DETAILS
                    WHERE Flow_id = P_FLOW_ID
                    AND sysdate between nvl(begin_date, sysdate-1)
                                    and nvl(end_date, sysdate+1) );

 CURSOR Get_Current_Detail_Order IS
  SELECT order_num
  FROM CS_KB_WF_FLOW_DETAILS
  WHERE FLOW_DETAILS_ID = P_CURRENT_FLOW_DETAILS_ID
  AND  (BEGIN_DATE <= SYSDATE OR BEGIN_DATE IS NULL)
  AND  (END_DATE >= SYSDATE OR END_DATE IS NULL);


 l_current_step  NUMBER;
 l_current_order NUMBER;
 l_next_step     NUMBER;
 l_first_step    NUMBER;

 Disabled   VARCHAR2(1) := 'Y';
 Enabled    VARCHAR2(1) := 'N';
 l_return VARCHAR2(1);

BEGIN
 l_return := Disabled;

 IF P_CURRENT_FLOW_DETAILS_ID is not null THEN
 --dbms_output.put_line('Current Step Id is not null');
   -- Check if current step is still active, if Yes return Order Number
   OPEN  Get_Current_Detail_Order;
   FETCH Get_Current_Detail_Order INTO l_current_order;
   CLOSE Get_Current_Detail_Order;

 --dbms_output.put_line('Current Step Order='||l_current_order);
   IF l_current_order IS NOT NULL THEN
     -- Current Step is still active

     IF l_current_order >= P_FLOW_DETAILS_ORDER THEN

       -- Grant this step as submitable
       RETURN Enabled;

     ELSE -- Step is beyond current current flow position

       -- If next step then it is submitable
       CS_KB_WF_PKG.Get_Next_Step( p_flow_details_id => P_CURRENT_FLOW_DETAILS_ID,
                                   p_next_details_id => l_next_step);

       IF l_next_step = P_FLOW_DETAILS_ID THEN
         -- Grant this step as submitable
         RETURN Enabled;
       ELSE
         RETURN Disabled;
       END IF;

     END IF;

   ELSE -- The Current Flow Step is Inactive

     -- If this is the first Step then enable
     OPEN  Get_First_Step;
     FETCH Get_First_Step INTO l_first_step;
     CLOSE Get_First_Step;

       IF P_FLOW_DETAILS_ID = l_first_step THEN
         -- Grant this step as submitable
         RETURN Enabled;
       ELSE
         RETURN Disabled;
       END IF;

   END IF;

 ELSE --current step is null
   --dbms_output.put_line('Current Step Id is null');
   RETURN Disabled;
 END IF;

 RETURN l_return;

END Is_Step_Disabled;


PROCEDURE Get_Prev_Step(
  p_flow_details_id IN NUMBER,
  p_next_details_id OUT NOCOPY NUMBER
) IS
x_flow_id  NUMBER;
x_order_num NUMBER;
x_prev_order_num NUMBER;

BEGIN
    x_flow_id := getFlowId(p_flow_details_id);

    select order_num
    into x_order_num
    from CS_KB_WF_FLOW_DETAILS
    where FLOW_DETAILS_ID = p_flow_details_id;


    select  MAX(order_num)
    into x_prev_order_num
    from CS_KB_WF_FLOW_DETAILS
    where flow_id = x_flow_id
    and  (BEGIN_DATE <= SYSDATE OR BEGIN_DATE IS NULL)
    and  (END_DATE >= SYSDATE OR END_DATE IS NULL)
    and order_num < x_order_num;

    select flow_details_id
    into p_next_details_id
    from CS_KB_WF_FLOW_DETAILS
    where flow_id = x_flow_id
    and  order_num = x_prev_order_num;


EXCEPTION
    WHEN OTHERS THEN
    p_next_details_id := -1;

END Get_Prev_Step;

/**************************** INSERT DETAIL  **********************/
-- This procedure provides the ability to add a new flow
--
-- VARIABLES
--  p_flow_id
--  p_order_num
--  p_step
--  p_group_id
--  p_action
--  p_flow_details_id: flow_details_id or -1 if failed.
/*******************************************************************/

PROCEDURE Insert_Detail(
  p_flow_id IN NUMBER,
  p_order_num IN NUMBER,
  p_step IN VARCHAR2,
  p_group_id IN NUMBER,
  p_action IN VARCHAR2,
  p_flow_details_id OUT NOCOPY NUMBER
  )
  IS
    --temp vars
    uid NUMBER := fnd_global.user_id;
    dt DATE := SYSDATE;
  BEGIN

    -- Get next available details id number
    SELECT
        cs_kb_wf_flow_details_s.NextVal
    INTO
       p_flow_details_id
    FROM
       DUAL;

    -- Insert data
    INSERT INTO CS_KB_WF_FLOW_DETAILS(flow_details_id,
                                         flow_id,
                                         step,
                                         order_num,
                                         action,
                                         group_id,
                                         created_by,
                                         creation_date,
                                         last_updated_by,
                                         last_update_date)
                                  VALUES(p_flow_details_id,
                                         p_flow_id,
                                         p_step,
                                         p_order_num,
                                         p_action,
                                         p_group_id,
                                         uid,
                                         dt,
                                         uid,
                                         dt);

    --COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
        p_flow_details_id := -1;
  END Insert_Detail;

/**************************** INSERT FLOW  *************************/
-- This procedure provides the ability to add a new flow
--
-- VARIABLES
-- p_flow_name (name to display)
-- p_flow_id (the new id, -1 if already taken or other error)
-- 	bug 1966494: -3 for duplicated flow name
/*******************************************************************/
PROCEDURE Insert_Flow(
    p_flow_name IN VARCHAR2,
    p_flow_id OUT NOCOPY NUMBER
    ) IS
        --temp vars
        uid NUMBER := fnd_global.user_id;
        dt DATE := SYSDATE;
	x_count number;
BEGIN

  SELECT count(1)
  INTO x_count
  FROM CS_KB_WF_FLOWS_B b, CS_KB_WF_FLOWS_TL tl
  WHERE b.FLOW_ID = tl.FLOW_ID
  AND tl.NAME = p_flow_name
  AND tl.LANGUAGE = FND_GLOBAL.CURRENT_LANGUAGE;

  --check for duplicated flow name
  IF (x_count > 0) THEN
	p_flow_id := -3;
  ELSE
        SELECT
             cs_kb_wf_flows_s.NextVal
        INTO
            p_flow_id
        FROM
            DUAL;

        INSERT INTO CS_KB_WF_FLOWS_B(flow_id,created_by,creation_date,
		last_updated_by,last_update_date)
        VALUES(p_flow_id,uid,dt,uid,dt);

        INSERT INTO CS_KB_WF_FLOWS_TL (flow_id,
                                          name,
                                          creation_date,
                                          created_by,
                                          last_update_date,
                                          last_update_login,
                                          last_updated_by,
                                          language,
                                          source_lang)
                                   SELECT p_flow_id,
                                          p_flow_name,
                                          dt,
                                          uid,
                                          dt,
                                          uid,
                                          uid,
                                          l.language_code,
                                          USERENV('LANG')
                                   FROM fnd_languages l
                                   WHERE l.installed_flag IN ('I', 'B')
                                   AND NOT EXISTS
                                       (SELECT NULL
                                        FROM CS_KB_WF_FLOWS_TL t
                                        WHERE t.flow_id = p_flow_id
                                        AND t.language = l.language_code);


  END IF;

EXCEPTION
  WHEN OTHERS THEN
        p_flow_id := -1;
END Insert_Flow;

/**************************** START WF ***************************/
-- This procedure is used start the workflow process.  It is used
-- regarless if the solution is in the wf process yet or ready to be
-- published.
--
-- THIS ONE IS CALLED EXTERNALLY!
--
-- NOTES
-- If users want to skip any workflow and want to publish the solutions
-- directly, we go go directly to publish step, two conditions must be present:
-- 1) p_set_id must have a valid value (max set_id for set_number)
-- 2) p_new_step must be null (nowhere to send it to)
-- If both values are null, it will throw an error.  If there is a value
-- for p_set_id when p_new_step is not null, it will be ignored.
--
-- VARIABLES
-- p_set_number
-- p_set_id: NULL unless need to go directly to publish
-- p_new_step: flow details id of new step to move to.  NULL if need
--             to go directly to publish
-- p_result: 1 if all fine, 0 if no permissions, -1 if general error,
--           -2 bad input information, -3 general error in Post_pub_obs
-- INTERNAL VARS
-- p_command = cs_kb_wf_flow_details.action
--
/*******************************************************************/
PROCEDURE Start_wf(
  p_set_number  IN VARCHAR2,
  p_set_id      IN NUMBER ,
  p_new_step    IN NUMBER ,
  p_results     OUT NOCOPY NUMBER,
  p_errormsg    OUT NOCOPY VARCHAR2
  ) IS

  solution_title CS_KB_SETS_TL.NAME%TYPE;
  p_group_id NUMBER;
  p_command VARCHAR2(30);
  p_locked_by NUMBER;
  current_id NUMBER;
  user_id NUMBER := fnd_global.user_id;
  set_id NUMBER := p_set_id;
  x_original_author_id FND_USER.USER_ID%TYPE;
  x_author		FND_USER.USER_NAME%TYPE;
  x_new_step number;

  BEGIN

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_WF_PKG.Start_Wf.begin',
                   ' Current User='||user_id||' Step='||p_new_step);
  END IF;

    IF (p_new_step is null) THEN
      IF (p_set_id is null) THEN
        RAISE BAD_INFORMATION_SUPPLIED;
      ELSE

         IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.CS_KB_WF_PKG.Start_Wf',
                          'Direct Publish - '||p_set_id);
         END IF;

	    -- no step, intepreted as workflow disabled. Publish directly.
	    -- do NOT kick off workflow
        p_command := 'PUB';
	    p_locked_by := null;
        set_id := CS_KB_SOLUTION_PVT.clone_solution(p_set_number,
                                      p_command, p_new_step, p_locked_by);

      END IF;
    ELSE

      current_id := CS_KB_SOLUTION_PVT.locked_by(p_set_id);

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.CS_KB_WF_PKG.Start_Wf',
                       'Standard Flow Submission. Current Lock - '||current_id);
      END IF;

      -- If lock is not held by anyone, by workflow, by the current user,
      IF ((current_id is null) or (current_id = -1) or (current_id = user_id)) THEN

        -- check whether it is Rejected to Author
	    IF (p_new_step = -999) THEN
		  p_command := 'REJ';
		  x_new_step := null;
	    ELSE
          p_command := getAction(p_new_step);
		  p_group_id := getstepGroup(p_new_step);
		  x_new_step := p_new_step;
	    END IF;

	    -- Determine locked_by for each command
	    IF (p_command = 'NOT') THEN
	      p_locked_by := -1;
	    ELSIF (p_command = 'REJ') THEN
		  -- set locked by last updater
		  -- 7117561
		  SELECT created_by
                  INTO   x_original_author_id
                  FROM   cs_kb_sets_b
                  WHERE  set_id = ( SELECT MAX(set_id)       -- Bug fix: 7159784 - made it max(set_id) to get the last updater
                                    FROM   cs_kb_sets_b
                                    WHERE  set_number = p_set_number
                                    AND    status = 'SAV' --Bugfix7228667 - Added the Status to change the Locked by
                                   ) ;
		  -- 7117561
          p_locked_by := x_original_author_id;
	    ELSE
		  -- PUB/OBS
		  p_locked_by := null;
	    END IF;

        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.CS_KB_WF_PKG.Start_Wf',
                         'Before Clone - '||p_set_number||' - '
                                          ||p_command||' - '
                                          ||x_new_step||' - '
                                          ||p_locked_by);
        END IF;

        -- clone solution
        set_id := CS_KB_SOLUTION_PVT.clone_solution(p_set_number,
					p_command, x_new_step, p_locked_by);

      ELSE
	    -- someone forced a lock on it
        RAISE PERMISSION_ERROR;
      END IF;

	  -- Send notifications
	  solution_title := CS_KB_SOLUTION_PVT.get_solution_title(p_set_id);

	  IF (p_command <> 'REJ') THEN
        Create_Wf_Process(set_id,p_set_number, p_command, p_new_step,
                          p_group_id, solution_title );
	  ELSE
	    /*select user_name
	    into x_author
	    from fnd_user
	    where user_id = x_original_author_id;*/
	    FOR get_user IN --Bugfix7117561 -  get the users to whom we need to send notifications
            (
               SELECT DISTINCT user_id, user_name
               FROM
                  (
                     SELECT user_id, user_name
                     FROM   cs_kb_sets_b a, fnd_user b
                     WHERE  set_id IN (
                                       SELECT MIN(set_id)
                                       FROM   cs_kb_sets_b
                                       WHERE  set_number = p_set_number
                                      )
                     AND    a.created_by = b.user_id
                     UNION
                     SELECT user_id, user_name
                     FROM   cs_kb_sets_b a, fnd_user b
                     WHERE  set_id IN (
                                       SELECT MAX(set_id)   --Bug fix:7159784 - made it max(set_id) to get the last updater
                                       FROM   cs_kb_sets_b
                                       WHERE  set_number = p_set_number AND
                                            status     = 'SAV'    --Bug fix:7228667
                                       )
                     AND    a.created_by = b.user_id
                  )
            )
	    LOOP

               IF (CS_KB_SECURITY_PVT.IS_COMPLETE_SOLUTION_VISIBLE(x_original_author_id,set_id)= 'TRUE') THEN

                   Create_Reject_Process(set_id,p_set_number, solution_title, get_user.user_name);
               END IF;
	    END LOOP;
	  END IF;

    END IF;

    p_results := 1;
    p_errormsg := null;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_WF_PKG.Start_Wf.end',
                   'Status=Success');
  END IF;

EXCEPTION
  WHEN PERMISSION_ERROR THEN

    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_WF_PKG.Start_Wf.EXCEPTION.Permission_Error',
                     ' Locking User='||Current_id||
                     ' Current User='||User_Id);
    END IF;

    p_results := 0;
    p_errormsg := 'No permission error';
  WHEN BAD_INFORMATION_SUPPLIED THEN

    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_WF_PKG.Start_Wf.EXCEPTION.Bad_Info',
                     ' New Step='||p_new_step||
                     ' Set Id='||p_set_id);
    END IF;

    p_results := -2;
    p_errormsg := 'Bad information supplied';
  WHEN OTHERS THEN

    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_WF_PKG.Start_Wf.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;

    p_results := -1;
    p_errormsg := SQLERRM;
END Start_wf;



/**************************** START WF PROCESSING ******************/
-- This procedure is used start the workflow process.  It is used
-- regarless if the solution is in the wf process yet or ready to be
-- published. Always called by workflow node
/*******************************************************************/
PROCEDURE Start_wf_processing(
  p_itemtype  IN VARCHAR2,
  p_itemkey   IN VARCHAR2,
  p_actid     IN NUMBER,
  p_funcmode  IN VARCHAR2,
  p_result    OUT NOCOPY VARCHAR2
  ) IS

 command VARCHAR2(30) := WF_ENGINE.GetItemAttrText(p_itemtype,p_itemkey,'COMMAND');
 set_id NUMBER := WF_ENGINE.GetItemAttrNumber(p_itemtype,p_itemkey,'SETID');
 l_group_id NUMBER := WF_ENGINE.GetItemAttrNumber(p_itemtype,p_itemkey,'GROUPID');

 adhoc_role VARCHAR2(320);
 adhoc_role_name VARCHAR2(360);

 CURSOR GET_GROUP_NAME (v_group_id NUMBER) IS
  SELECT GROUP_NAME
  FROM   JTF_RS_GROUPS_VL
  WHERE  GROUP_ID = v_group_id;


 CURSOR Get_Group_Members (v_group_id IN NUMBER) IS
  SELECT DISTINCT
         fnd_user.user_name,
         fnd_user.user_id
  FROM fnd_user,
       jtf_rs_resource_extns,
       jtf_rs_group_members
  WHERE jtf_rs_group_members.resource_id=jtf_rs_resource_extns.resource_id
  AND jtf_rs_group_members.group_id = v_group_id
  AND jtf_rs_group_members.DELETE_FLAG <> 'Y'
  AND jtf_rs_resource_extns.START_DATE_ACTIVE <= sysdate
  AND NVL(jtf_rs_resource_extns.END_DATE_ACTIVE, sysdate) >= sysdate
  AND( ( jtf_rs_resource_extns.source_id = fnd_user.employee_id
         AND jtf_rs_resource_extns.category = 'EMPLOYEE' )
      OR (jtf_rs_resource_extns.source_id = fnd_user.customer_id
          AND jtf_rs_resource_extns.category = 'PARTY' )
      );

BEGIN

 -- Loading process type name
 WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'PROCTYPENAME', getActionName(command));

 OPEN  GET_GROUP_NAME (l_group_id);
 FETCH GET_GROUP_NAME INTO adhoc_role_name;
 CLOSE GET_GROUP_NAME;

 IF adhoc_role_name IS NULL THEN
   adhoc_role := NULL;
 ELSE
   adhoc_role := 'SOLNID'||to_char(set_id)||'-'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS');
   --Bug 3588397 - USE OF SYSTIMESTAMP IS NOT COMPATABLE WITH 8.1.7
   --adhoc_role := 'SOLNID'||to_char(set_id)||'-'||TO_CHAR(SYSTIMESTAMP,'DDMMYYYYHH24MISSFF1');
 END IF;

 WF_DIRECTORY.CREATEADHOCROLE(adhoc_role,adhoc_role_name,null,null,null,'MAILHTML',null,null,null,'ACTIVE',sysdate+365);

 WF_ENGINE.SetItemAttrText(p_itemtype,p_itemkey,'RECIPIENTGROUP',adhoc_role);

 FOR Users IN Get_Group_Members (l_group_id) LOOP

   IF ((inCategory(Users.user_id,set_id) = 1) OR
       (inProduct(Users.user_id,set_id) = 1)) THEN
     -- Check if user can view the 'Complete' Solution
     IF (CS_KB_SECURITY_PVT.IS_COMPLETE_SOLUTION_VISIBLE(Users.user_id,set_id)= 'TRUE') THEN
       WF_DIRECTORY.ADDUSERSTOADHOCROLE(adhoc_role, Users.user_name);
     END IF;

   END IF;

 END LOOP;

 -- Set the From field:
 WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'NOTFROM', FND_GLOBAL.User_Name);

 -- Send workflow down correct path according to command determined.
 IF (command = 'PUB') OR (command = 'OBS') THEN
   p_result := 'COMPLETE:PUB_OBS';
 ELSE
   p_result := 'COMPLETE:NOTIFY';
 END IF;

EXCEPTION
WHEN BAD_INFORMATION_SUPPLIED THEN
  wf_engine.SetItemAttrNumber(p_itemtype,p_itemkey,'TRACKING','NO VALID COMMAND FOUND');
  RAISE;
WHEN OTHERS THEN
  wf_engine.SetItemAttrNumber(p_itemtype,p_itemkey,'TRACKING','Unspecified error in Start_wf_processing procedure');
  RAISE;
END Start_wf_processing;


/**************************** UPDATE DETAIL  *************************/
-- This procedure provides the ability to add a new flow
--
-- VARIABLES
-- p_flow_details_id - provided when a list of details is requested
-- p_order_num
-- p_step
-- p_group_id
-- p_action
-- p_result: p_flow_details_id = completed successfully, 0 = completed but nothing was
--           updated,  -1 = error
/*******************************************************************/
PROCEDURE Update_Detail(
    p_flow_details_id IN NUMBER,
    p_order_num       IN NUMBER,
    p_step            IN VARCHAR2,
    p_group_id        IN NUMBER,
    p_action          IN VARCHAR2,
    p_result          OUT NOCOPY NUMBER
)
IS
    uid NUMBER := fnd_global.user_id;
    dt DATE := SYSDATE;
    temp NUMBER; --temp variable to see if id exists

    BEGIN
        -- MIN() is used to force a value to return and avoid NDF error
        SELECT
            MIN(flow_details_id)
        INTO
            temp
        FROM
            cs_kb_wf_flow_details
        WHERE
            flow_details_id = p_flow_details_id;

        IF(temp is not null) THEN
            UPDATE CS_KB_WF_FLOW_DETAILS
            SET order_num = p_order_num,
                step = p_step,
                group_id = p_group_id,
                action = p_action,
                last_updated_by = uid,
                last_update_date = dt
            WHERE
                flow_details_id = p_flow_details_id;

            p_result := p_flow_details_id;
        ELSE
            p_result := 0;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_result := -1;
    END Update_Detail;






/**************************** UPDATE DETAIL ADMIN ******************/
-- This procedure is a wrapper for both update and insert procedures
-- to be used by the admin pages.
--
-- VARIABLES
-- p_flow_details_id - provided when a list of details is requested
-- p_order_num
-- p_step
-- p_group_id
-- p_action
-- p_result: flow_details_id OR -1 = error
/*******************************************************************/

PROCEDURE Update_Detail_Admin(
    p_flow_details_id IN NUMBER,
    p_flow_id         IN NUMBER,
    p_order_num       IN NUMBER,
    p_step            IN VARCHAR2,
    p_group_id        IN NUMBER,
    p_action          IN VARCHAR2,
    p_flag            IN VARCHAR2,
    p_result          OUT NOCOPY NUMBER
 ) IS
    result NUMBER;
 BEGIN

    -- DELETE
    IF (p_flag = 'DELETE') THEN
        Expire_Detail(p_flow_details_id, result);
    ELSE
        -- IF NOT A DELETE THEN LOOK FOR OTHER ACTION
        -- INSERT
        IF (p_flow_details_id = -2 ) THEN
            Insert_Detail(p_flow_id, p_order_num, p_step, p_group_id, p_action, result);
        -- UPDATE
        ELSE
            Update_Detail(p_flow_details_id, p_order_num, p_step, p_group_id, p_action, result);
        END IF;
    END IF;

    p_result := result;
 END Update_Detail_Admin;






/**************************** UPDATE FLOW  *************************/
-- This procedure provides the ability to add a new flow
--
-- VARIABLES
-- p_flow_id
-- p_flow_name (name to display)
-- p_result: 1 = completed successfully, 0 = completed but nothing was
--           updated,  -1 = error, -3=duplicated file name
/*******************************************************************/
PROCEDURE Update_Flow(
    p_flow_id IN NUMBER,
    p_flow_name IN VARCHAR2,
    p_result    OUT NOCOPY NUMBER
    ) IS
        uid NUMBER := fnd_global.user_id;
        dt DATE := SYSDATE;
        temp NUMBER;
	x_count number;
BEGIN

  SELECT count(1)
  INTO x_count
  FROM CS_KB_WF_FLOWS_B b, CS_KB_WF_FLOWS_TL tl
  WHERE b.FLOW_ID = tl.FLOW_ID
  AND b.FLOW_ID <> p_flow_id
  AND tl.NAME = p_flow_name
  AND tl.LANGUAGE = FND_GLOBAL.CURRENT_LANGUAGE;

  --check for duplicated flow name
  IF (x_count > 0) THEN
        p_result := -3;
  ELSE
         -- MIN() is used to force a value to return and avoid NDF error
        SELECT
            MIN(flow_id)
        INTO
            temp
        FROM
            cs_kb_wf_flows_tl
        WHERE
            flow_id = p_flow_id;

        IF(temp is not null) THEN
            UPDATE CS_KB_WF_FLOWS_TL
                SET name = p_flow_name,
                    last_updated_by = uid,
                    last_update_date = dt,

                    source_lang = USERENV('LANG')

                WHERE
                    flow_id = p_flow_id
                AND USERENV('LANG') IN (language, source_lang);

                    --language = FND_GLOBAL.CURRENT_LANGUAGE;

            UPDATE CS_KB_WF_FLOWS_B
                SET last_updated_by = uid,
                    last_update_date = dt
                WHERE
                    flow_id = p_flow_id;

            p_result := 1;
        ELSE
            p_result := 0;
        END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
        RAISE;
            p_result := -1;
END Update_Flow;

/**************************** UPDATE FLOW ADMIN ********************/
-- This procedure is a wrapper of both insert and update functionality
-- designed for the admin pages
--
-- VARIABLES
-- p_flow_id
-- p_flow_name (name to display)
-- p_result: flow_id OR -1 = error, OR -3 = duplicated flow name
/*******************************************************************/

   PROCEDURE Update_Flow_Admin(
    p_flow_id IN NUMBER,
    p_flow_name IN VARCHAR2,
    p_result    OUT NOCOPY NUMBER
    )
    IS
        result NUMBER;
    BEGIN
        -- INSERT, result is new flow_id or -1/-3
        IF (p_flow_id is null) THEN
            Insert_Flow(p_flow_name, result);

        -- UPDATE, result is 0/1/-1/-3
        ELSE
            Update_Flow(p_flow_id, p_flow_name, result);
        END IF;

        IF ((result = 0) OR (result = 1)) THEN
            p_result := p_flow_id;
        ELSE
            p_result := result;
        END IF;
    END Update_Flow_admin;


PROCEDURE Add_Language IS

BEGIN

  DELETE FROM CS_KB_WF_FLOWS_TL t
  WHERE NOT EXISTS
    (SELECT NULL
    FROM CS_KB_WF_FLOWS_B b
    WHERE b.flow_id = t.flow_id
    );

  UPDATE CS_KB_WF_FLOWS_TL T SET (
      name,
      description
    ) = (SELECT
      b.name,
      b.description
    FROM CS_KB_WF_FLOWS_TL b
    WHERE b.flow_id = t.flow_id
    AND b.language = t.source_lang)
  WHERE (
      t.flow_id,
      t.language
  ) IN (SELECT
      subt.flow_id,
      subt.language
    FROM CS_KB_WF_FLOWS_TL subb, CS_KB_WF_FLOWS_TL subt
    WHERE subb.flow_id = subt.flow_id
    AND subb.language = subt.source_lang
    AND (subb.name <> subt.name
      OR (subb.name IS NULL AND subt.name IS NOT NULL)
      OR (subb.name IS not NULL AND subt.name IS NULL)
      OR subb.description <> subt.description
      OR (subb.description IS NULL AND subt.description IS NOT NULL)
      OR (subb.description IS NOT NULL AND subt.description IS NULL)
  ));

  INSERT INTO CS_KB_WF_FLOWS_TL (
    flow_id,
    name,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_update_login,
    last_updated_by,
    language,
    source_lang
  ) SELECT
    b.flow_id,
    b.name,
    b.description,
    b.creation_date,
    b.created_by,
    b.last_update_date,
    b.last_update_login,
    b.last_updated_by,
    l.language_code,
    b.source_lang
  FROM CS_KB_WF_FLOWS_TL b, fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND b.language = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM CS_KB_WF_FLOWS_TL t
    WHERE t.flow_id = b.flow_id
    AND t.language = l.language_code);

END Add_Language;

-- Package Body CS_KB_WF
END;

/
