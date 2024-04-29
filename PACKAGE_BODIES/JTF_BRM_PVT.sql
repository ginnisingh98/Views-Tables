--------------------------------------------------------
--  DDL for Package Body JTF_BRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_BRM_PVT" AS
/* $Header: jtfvbrmb.pls 120.2.12010000.2 2008/11/05 06:01:37 rkamasam ship $ */

-----------------------------------------------------------------------------
--
-- PROCEDURE selector
--
-- Determine which process to run.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - name of Workflow process to run
--
PROCEDURE selector
(
  itemtype  IN     VARCHAR2,
  itemkey   IN     VARCHAR2,
  actid     IN     NUMBER,
  funcmode  IN     VARCHAR2,
  result    IN OUT NOCOPY VARCHAR2
) IS
  --
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    result  := 'MONITOR_RULES';
    RETURN;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('JTF_BRM_PVT', 'SELECTOR',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END selector;
-----------------------------------------------------------------------------
--
-- FUNCTION init_monitor
--
-- Create an instance of the Business Rule Monitor, initialize it, and
-- start the instance.  Return TRUE if successful; otherwise return FALSE.
--
-- IN
--   itemkey     - key of the current item
--   uom_type    - unit of measure type for timer interval
--   uom_code    - unit of measure code for timer interval
--   timer_units - number of units for timer interval
-- OUT
--   TRUE        - success
--   FALSE       - failure
--
FUNCTION init_monitor
(
  itemkey        IN NUMBER,
  uom_type       IN VARCHAR2,
  uom_code       IN VARCHAR2,
  timer_units    IN NUMBER
) RETURN BOOLEAN IS
  --
  l_itemtype VARCHAR2(10) := 'JTFBRM';
  l_itemkey  VARCHAR2(100);
  l_admin    VARCHAR2(80) := FND_PROFILE.Value(name => 'JTF_BRM_WF_ADMINISTRATOR');

  --
BEGIN
  --
  IF itemkey IS NULL OR uom_type IS NULL OR
     uom_code IS NULL OR timer_units IS NULL OR
     l_admin IS NULL THEN
    RETURN FALSE;
  END IF;
  --
  l_itemkey := to_char(itemkey);
  --
  wf_engine.CreateProcess(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            process  => 'MONITOR_RULES');
  --
  wf_engine.SetItemAttrText(
      itemtype => l_itemtype,
      itemkey  => l_itemkey,
            aname    => 'WF_ADMINISTRATOR',
      avalue   => l_admin);
  --
  wf_engine.SetItemOwner(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            owner    => l_admin);
  --
  wf_engine.SetItemAttrText(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'UOM_TYPE',
            avalue   => uom_type);
  --
  wf_engine.SetItemAttrText(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'UOM_CODE',
            avalue   => uom_code);
  --
  wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'TIMER_UNITS',
            avalue   => timer_units);
  --
  wf_engine.SetItemAttrDate(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'MONITOR_START_TIME',
            avalue   => SYSDATE);
  --
  wf_engine.StartProcess(
            itemtype => l_itemtype,
            itemkey  => l_itemkey);
  --
  COMMIT;
  RETURN TRUE;
  --
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('JTF_BRM_PVT', 'INIT_MONITOR');
    raise;
END init_monitor;
-----------------------------------------------------------------------------
--
-- PROCEDURE start_monitor
--
-- Set the START command and PROCESS_ID item attributes and update the
-- record in the JTF_BRM_PARAMETERS table to indicate the start of the
-- Business Rule Monitor.  The WORKFLOW_PROCESS_ID is set to be the same
-- as the itemkey.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:NOERROR
--               COMPLETE:NONCRITICAL
--               COMPLETE:CRITICAL
--
PROCEDURE start_monitor
(
  itemtype  IN     VARCHAR2,
  itemkey   IN     VARCHAR2,
  actid     IN     NUMBER,
  funcmode  IN     VARCHAR2,
  result    IN OUT NOCOPY VARCHAR2
) IS
  --
  l_api_version      NUMBER      := 1.0;
  l_init_msg_list    VARCHAR2(1) := fnd_api.g_true;
  l_commit           VARCHAR2(1) := fnd_api.g_false;
  l_validation_level NUMBER      := fnd_api.g_valid_level_full;
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_bp_rec           JTF_BRMParameter_PVT.BRM_Parameter_rec_type;
  l_found            BOOLEAN;
  --
  CURSOR c_parameters IS
    SELECT *
    FROM   jtf_brm_parameters
    WHERE  parameter_id = 1;
  --
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'SUBPROCESS_NAME',
              avalue   => 'START_MONITOR');
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'COMMAND_TYPE',
              avalue   => 'JTF_BRM_WF_COMMAND_TYPE');
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'COMMAND_CODE',
              avalue   => 'START');
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'COMMAND',
              avalue   => 'START');
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'PROCESS_ID',
              avalue   => itemkey);
    --
    -- Update columns in the JTF_BRM_PARAMETERS table to indicate
    -- the start of the Business Rule Monitor.  But first select the
    -- record so as not to overwrite good data.
    --
    OPEN  c_parameters;
    FETCH c_parameters INTO l_bp_rec;
    l_found := c_parameters%FOUND;
    CLOSE c_parameters;
    --
    IF NOT l_found THEN
      result := 'COMPLETE:CRITICAL';
      RETURN;
    END IF;
    --
    l_bp_rec.workflow_process_id   := itemkey;
    l_bp_rec.workflow_item_type    := 'JTFBRM';
    l_bp_rec.workflow_process_name := 'MONITOR_RULES';
    l_bp_rec.brm_wf_command_type   := 'JTF_BRM_WF_COMMAND_TYPE';
    l_bp_rec.brm_wf_command_code   := 'START';
    --
    JTF_BRMParameter_PVT.Update_BRMParameter(
      p_api_version      => l_api_version,
      p_init_msg_list    => l_init_msg_list,
      p_commit           => l_commit,
      p_validation_level => l_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_bp_rec           => l_bp_rec);
    --
    IF l_msg_count > 0 THEN
      result := 'COMPLETE:CRITICAL';
      RETURN;
    END IF;
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    IF c_parameters%ISOPEN THEN
      CLOSE c_parameters;
    END IF;
    wf_core.context('JTF_BRM_PVT', 'START_MONITOR',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END start_monitor;
-----------------------------------------------------------------------------
--
-- PROCEDURE calculate_interval
--
-- Get the number of hours or minutes for the timer interval and convert to
-- <days>.<fraction_of_a_day>.  Set the timer interval.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:NOERROR
--               COMPLETE:NONCRITICAL
--               COMPLETE:CRITICAL
--
PROCEDURE calculate_interval
(
  itemtype  IN     VARCHAR2,
  itemkey   IN     VARCHAR2,
  actid     IN     NUMBER,
  funcmode  IN     VARCHAR2,
  result    IN OUT NOCOPY VARCHAR2
) IS
  l_uom_type       fnd_lookups.lookup_type%TYPE;
  l_uom_code       fnd_lookups.lookup_code%TYPE;
  l_timer_units    NUMBER;
  l_timer_interval NUMBER;
  l_meaning        fnd_lookups.meaning%TYPE;
  l_conversion     NUMBER;
  l_found          BOOLEAN;
  l_now            DATE := SYSDATE;
  --
  CURSOR c_lookups(b_uom_type fnd_lookups.lookup_type%TYPE,
                   b_uom_code fnd_lookups.lookup_code%TYPE,
                   b_now      DATE) IS
    SELECT meaning
    FROM   fnd_lookups
    WHERE  lookup_type        = b_uom_type
    AND    lookup_code        = b_uom_code
    AND    enabled_flag       = 'Y'
    AND    start_date_active <= b_now
    AND    nvl(end_date_active, b_now) >= b_now;
  --
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'SUBPROCESS_NAME',
              avalue   => 'CALCULATE_INTERVAL');
    --
    -- Get the timer unit of measure, and the number of units.
    --
    l_uom_type := wf_engine.GetItemAttrText(
                            itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'UOM_TYPE');
    --
    l_uom_code := wf_engine.GetItemAttrText(
                            itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'UOM_CODE');
    --
    l_timer_units := wf_engine.GetItemAttrNumber(
                               itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'TIMER_UNITS');
    --
    IF l_uom_type IS NULL OR l_uom_code IS NULL OR l_timer_units IS NULL THEN
      result := 'COMPLETE:CRITICAL';
      RETURN;
    END IF;
    --
    OPEN  c_lookups(l_uom_type, l_uom_code, l_now);
    FETCH c_lookups
    INTO  l_meaning;
    l_found := c_lookups%FOUND;
    CLOSE c_lookups;
    --
    IF NOT l_found THEN
      result := 'COMPLETE:CRITICAL';
      RETURN;
    END IF;
    --
    -- Convert interval to days.
    --
    IF l_uom_code = 'HOURS' THEN
      l_timer_interval := l_timer_units / 24;
    ELSIF l_uom_code = 'MINUTES' THEN
      l_timer_interval := l_timer_units / 1440;
    ELSE
      result := 'COMPLETE:CRITICAL';
      RETURN;
    END IF;
    --
    wf_engine.SetItemAttrNumber(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'TIMER_INTERVAL',
              avalue   => l_timer_interval);
    --
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    IF c_lookups%ISOPEN THEN
      CLOSE c_lookups;
    END IF;
    wf_core.context('JTF_BRM_PVT', 'CALCULATE_INTERVAL',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END calculate_interval;
-----------------------------------------------------------------------------
--
-- FUNCTION get_activity_id
--
-- Return a unique ID for an activity.
--
FUNCTION get_activity_id RETURN NUMBER IS
  --
  CURSOR c_activity IS
    SELECT jtf_brm_activities_s.nextval
    FROM   DUAL;
  l_activity_id NUMBER;
  --
BEGIN
  OPEN   c_activity;
  FETCH  c_activity INTO l_activity_id;
  CLOSE  c_activity;
  RETURN l_activity_id;
EXCEPTION
  WHEN OTHERS THEN
    IF c_activity%ISOPEN THEN
      CLOSE c_activity;
    END IF;
END;
-----------------------------------------------------------------------------
--
-- PROCEDURE process_rules
--
-- Get the active business rules and process them.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:NOERROR
--               COMPLETE:NONCRITICAL
--               COMPLETE:CRITICAL
--
PROCEDURE process_rules
(
  itemtype  IN     VARCHAR2,
  itemkey   IN     VARCHAR2,
  actid     IN     NUMBER,
  funcmode  IN     VARCHAR2,
  result    IN OUT NOCOPY VARCHAR2
) IS
  CURSOR c_active_rules(b_now DATE) IS
    SELECT jbr.view_name,
           jbr.rule_id,
           jbp.rowid,
           jbp.workflow_item_type,
           jbp.workflow_process_name
    FROM   jtf_brm_processes jbp,
           jtf_brm_rules_vl  jbr
    WHERE  jbp.rule_id = jbr.rule_id
    AND    nvl(jbr.start_date_active, b_now + 1) <= b_now
    AND    nvl(jbr.end_date_active, b_now)       >= b_now
    AND    nvl(jbp.brm_uom_type,'JTF_BRM_UOM_TYPE')   = 'JTF_BRM_UOM_TYPE'
    AND    nvl(jbp.last_brm_check_date, b_now - 100) +
           (jbp.brm_check_interval / decode(jbp.brm_check_uom_code,
                                            'MINUTES', 1440,
                                            'HOURS', 24)) <= b_now
    AND    jbr.view_name IS NOT NULL
    and    jbp.workflow_item_type is not null;
  --
  TYPE cur_type IS REF CURSOR;
  c_object         cur_type;
  l_active_rules   c_active_rules%ROWTYPE;
  l_found          BOOLEAN;
  l_view           VARCHAR2(30);
  l_object_type    VARCHAR2(30);
  l_object_id      NUMBER;
  l_now            DATE := SYSDATE;
  l_query          VARCHAR2(1000);
  l_activity_id    NUMBER;
  l_save_threshold NUMBER;
  --
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'SUBPROCESS_NAME',
              avalue   => 'PROCESS_RULES');
    --
    wf_engine.SetItemAttrDate(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'PROCESS_RULES_START_TIME',
              avalue   => l_now);
    --
    FOR i in c_active_rules(l_now) LOOP
      --
      -- Set the time the rule was last checked.
      --
      -- Get the object_type and object_id for each object in each view
      -- and launch the appropriate Workflow activity.  The user-friendly
      -- key will be <object_type><object_id>, e.g., DF13579.
      --
      UPDATE jtf_brm_processes
      SET    last_brm_check_date = l_now
      WHERE  rowid = i.rowid;
      --
      l_query := 'SELECT object_type, object_id FROM ' || i.view_name;
      --
      OPEN c_object FOR l_query;
      LOOP
        FETCH c_object INTO l_object_type, l_object_id;
        EXIT WHEN c_object%NOTFOUND;
        --
        l_activity_id := get_activity_id;
        --
        -- Temporarily overriding the  defer threshold to make sure
        -- the process is executed in the background.
        --
        l_save_threshold := WF_ENGINE.threshold;
        WF_ENGINE.threshold := -1;
        --
        wf_engine.CreateProcess(
                  itemtype => i.workflow_item_type,
                  itemkey  => l_activity_id,
                  process  => i.workflow_process_name);
        --
        wf_engine.SetItemUserKey(
                  itemtype => i.workflow_item_type,
                  itemkey  => l_activity_id,
                  userkey  => l_object_type || to_char(l_object_id));
        --
        wf_engine.SetItemAttrText(
                  itemtype => i.workflow_item_type,
                  itemkey  => l_activity_id,
                  aname    => 'PROCESS_ID',
                  avalue   => itemkey);
        --
        wf_engine.SetItemAttrText(
                  itemtype => i.workflow_item_type,
                  itemkey  => l_activity_id,
                  aname    => 'SUBPROCESS_NAME',
                  avalue   => 'PROCESS_RULES');
        --
        wf_engine.SetItemAttrText(
                  itemtype => i.workflow_item_type,
                  itemkey  => l_activity_id,
                  aname    => 'OBJECT_TYPE',
                  avalue   => l_object_type);
        --
        wf_engine.SetItemAttrText(
                  itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'OBJECT_TYPE',
                  avalue   => l_object_type);
        --
        wf_engine.SetItemAttrNumber(
                  itemtype => i.workflow_item_type,
                  itemkey  => l_activity_id,
                  aname    => 'OBJECT_ID',
                  avalue   => l_object_id);
        --
        wf_engine.SetItemAttrNumber(
                  itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'OBJECT_ID',
                  avalue   => l_object_id);
        --
        wf_engine.SetItemAttrNumber(
                  itemtype => i.workflow_item_type,
                  itemkey  => l_activity_id,
                  aname    => 'RULE_ID',
                  avalue   => i.rule_id);
        --
        wf_engine.StartProcess(
                  itemtype => i.workflow_item_type,
                  itemkey  => l_activity_id);
        --
        -- Restoring the defer threshold
        --
        WF_ENGINE.threshold := l_save_threshold;

      END LOOP;
      CLOSE c_object;
    END LOOP;
    --
    wf_engine.SetItemAttrDate(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'PROCESS_RULES_STOP_TIME',
              avalue   => SYSDATE);
    --
    result  := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    IF c_object%ISOPEN THEN
      CLOSE c_object;
    END IF;
    wf_core.context('JTF_BRM_PVT', 'PROCESS_RULES',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END process_rules;
-----------------------------------------------------------------------------
--
-- PROCEDURE check_interval
--
-- Check the difference between the timer interval and the actual interval
-- needed to process the current set of active business rules.  A negative
-- difference stops the Business Rule Monitor so that the timer interval can
-- be increased.  No difference or a positive difference sets the time to
-- wait before the next set of rules is processed.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:NOERROR
--               COMPLETE:NONCRITICAL
--               COMPLETE:CRITICAL
--
PROCEDURE check_interval
(
  itemtype  IN         VARCHAR2,
  itemkey   IN         VARCHAR2,
  actid     IN         NUMBER,
  funcmode  IN         VARCHAR2,
  result    IN OUT NOCOPY     VARCHAR2
) IS
  l_start_time         DATE;
  l_timer_interval     NUMBER;
  l_difference         NUMBER;
  --
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'SUBPROCESS_NAME',
              avalue   => 'CHECK_INTERVAL');
    --
    -- Get the start time and the actual interval and compute the
    -- difference between the timer interval and the actual interval.
    --
    l_start_time := wf_engine.GetItemAttrDate(
                              itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'PROCESS_RULES_START_TIME');
    --
    l_timer_interval := wf_engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'TIMER_INTERVAL');
    --
    IF l_start_time IS NULL OR l_timer_interval is NULL THEN
      result := 'COMPLETE:NONCRITICAL';
      RETURN;
    END IF;
    --
    l_difference := l_timer_interval - (SYSDATE - l_start_time);
    --
    wf_engine.SetItemAttrNumber(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'INTERVAL_DIFF',
              avalue   => l_difference);
    --
    --  A negative difference stops the Business Rule Monitor so that the
    --  system administrator can increase the timer interval and restart it.
    --
    IF l_difference < 0 THEN
      result := 'COMPLETE:CRITICAL';
      RETURN;
    ELSE
      --
      -- Time allotted was enough or more than enough.  Set the time to wait
      -- before processing the next set of rules.
      --
      wf_engine.SetItemAttrNumber(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'WAIT_TIME',
                avalue   => l_difference);
      --
      result := 'COMPLETE:NOERROR';
      RETURN;
    END IF;
  END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('JTF_BRM_PVT', 'CHECK_INTERVAL',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END check_interval;
-----------------------------------------------------------------------------
--
-- PROCEDURE get_brm_command
--
-- Get the current Business Rule Monitor command.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:NOERROR
--               COMPLETE:NONCRITICAL
--               COMPLETE:CRITICAL
--
PROCEDURE get_brm_command
(
  itemtype  IN     VARCHAR2,
  itemkey   IN     VARCHAR2,
  actid     IN     NUMBER,
  funcmode  IN     VARCHAR2,
  result    IN OUT NOCOPY VARCHAR2
) IS
  l_command_type fnd_lookups.lookup_type%TYPE;
  l_command_code fnd_lookups.lookup_code%TYPE;
  l_meaning      fnd_lookups.meaning%TYPE;
  l_found        BOOLEAN;
  l_now          DATE := SYSDATE;
  --
  CURSOR c_command IS
    SELECT brm_wf_command_type, brm_wf_command_code
    FROM   jtf_brm_parameters
    WHERE  workflow_process_id = itemkey;
  --
  CURSOR c_lookups(b_command_type fnd_lookups.lookup_type%TYPE,
                   b_command_code fnd_lookups.lookup_code%TYPE,
                   b_now          DATE) IS
    SELECT meaning
    FROM   fnd_lookups
    WHERE  lookup_type        = b_command_type
    AND    lookup_code        = b_command_code
    AND    enabled_flag       = 'Y'
    AND    start_date_active <= b_now
    AND    nvl(end_date_active, b_now) >= b_now;
  --
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'SUBPROCESS_NAME',
              avalue   => 'GET_BRM_COMMAND');
    --
    OPEN  c_command;
    FETCH c_command
    INTO  l_command_type, l_command_code;
    l_found := c_command%FOUND;
    CLOSE c_command;
    --
    IF NOT l_found THEN
      result := 'COMPLETE:CRITICAL';
      RETURN;
    ELSE
      wf_engine.SetItemAttrText(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'COMMAND_TYPE',
                avalue   => l_command_type);
      --
      wf_engine.SetItemAttrText(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'COMMAND_CODE',
                avalue   => l_command_code);
      --
      OPEN  c_lookups(l_command_type, l_command_code, l_now);
      FETCH c_lookups INTO l_meaning;
      l_found := c_lookups%FOUND;
      CLOSE c_lookups;
      --
      IF NOT l_found THEN
        result := 'COMPLETE:CRITICAL';
      ELSE
        wf_engine.SetItemAttrText(
                  itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'COMMAND',
                  avalue   => l_meaning);
        result := 'COMPLETE:NOERROR';
      END IF;
      RETURN;
    END IF;
  END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE:NOERROR';
    return;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
    result := 'COMPLETE:NOERROR';
    RETURN;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    IF c_command%ISOPEN THEN
      CLOSE c_command;
    END IF;
    IF c_lookups%ISOPEN THEN
      CLOSE c_lookups;
    END IF;
    wf_core.context('JTF_BRM_PVT', 'GET_BRM_COMMAND',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END get_brm_command;
-----------------------------------------------------------------------------
--
-- PROCEDURE stop_monitor
--
-- Check if there is a request to stop the Business Rule Monitor.
-- If so, set the stop time for the process.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:T
--               COMPLETE:F
--
PROCEDURE stop_monitor
(
  itemtype  IN     VARCHAR2,
  itemkey   IN     VARCHAR2,
  actid     IN     NUMBER,
  funcmode  IN     VARCHAR2,
  result    IN OUT NOCOPY VARCHAR2
) IS
  l_command VARCHAR2(30);
  --
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    --
    wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'SUBPROCESS_NAME',
              avalue   => 'STOP_MONITOR');
    --
    l_command := wf_engine.GetItemAttrText(
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'COMMAND_CODE');
    --
    IF l_command = 'STOP' THEN
      wf_engine.SetItemAttrDate(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'MONITOR_STOP_TIME',
                avalue   => SYSDATE);
      --
      result := 'COMPLETE:T';
    ELSE
      result := 'COMPLETE:F';
    END IF;
    RETURN;
  END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE:F';
    RETURN;
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
    result := 'COMPLETE:T';
    RETURN;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('JTF_BRM_PVT', 'STOP_MONITOR',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END stop_monitor;
-----------------------------------------------------------------------------
--
-- PROCEDURE commit_wf
--
-- commits all runtime WF-data for the complete scan cycle and resets the
-- wf_savepoint. This will prevent the rollback segments from growing to
-- rediculous size
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:True
--               COMPLETE:False
--
PROCEDURE commit_wf(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN')
  THEN
    COMMIT;
    SAVEPOINT wf_savepoint;
    result := 'COMPLETE:T';
  ELSE
    result := 'COMPLETE:F';
  END IF;
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('JTF_BRM_PVT', 'COMMIT_WF',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END commit_wf;
-----------------------------------------------------------------------------

END JTF_BRM_PVT;

/
