--------------------------------------------------------
--  DDL for Package Body WF_TASKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_TASKFLOW" AS
/* $Header: wfflob.pls 120.3 2007/08/14 09:45:07 dsardar ship $ */

-- Global Variables Declatration
gClob clob;
gUseClob boolean := false;
gClobInit boolean := false;
l_data varchar2(32000);
NL_CHAR varchar2 (1) := '
';

  --------------------- Private Procedure Declarations ----------------------

  PROCEDURE get_base_definition(x_parent_type  IN VARCHAR2,
                                x_parent_name  IN VARCHAR2,
                                x_base_type    IN VARCHAR2,
                                x_base_name    IN VARCHAR2,
                                x_start_date   IN DATE);

  PROCEDURE get_activity_definitions(x_base_type    IN VARCHAR2,
                                     x_base_name    IN VARCHAR2,
                                     x_base_version IN NUMBER,
                                     x_start_date   IN DATE);

  PROCEDURE get_transition_definitions(x_base_type    IN VARCHAR2,
                                       x_base_name    IN VARCHAR2,
                                       x_base_version IN NUMBER,
                                       x_start_date   IN DATE);

  PROCEDURE get_base_instance(x_item_type   IN VARCHAR2,
                              x_item_key    IN VARCHAR2,
                              x_parent_name IN VARCHAR2,
                              x_base_type   IN VARCHAR2,
                              x_base_name   IN VARCHAR2,
                              x_start_date  IN DATE);

  PROCEDURE get_activity_instances(x_item_type  IN VARCHAR2,
                                   x_item_key   IN VARCHAR2,
                                   x_base_type  IN VARCHAR2,
                                   x_base_name  IN VARCHAR2,
                                   x_start_date IN DATE);

  PROCEDURE get_transition_instances(x_item_type  IN VARCHAR2,
                                     x_item_key   IN VARCHAR2,
                                     x_base_type  IN VARCHAR2,
                                     x_base_name  IN VARCHAR2,
                                     x_start_date IN DATE);

  /*--------------------------------------------------------------------------
   * APPEND_CLOB_DATA
   *
   * Description:
   *   Called by APPEND_DATA
   *   Appends data to the Clob object
   *
   * Parameters:
   *   new_Data : Data to be appended
   *
   * Notes:
   *   To remove htp.p calls we have appended the data to a clob there by
   *   returning clob object
   *-------------------------------------------------------------------------*/

   procedure append_clob_data(newData in varchar2)
   is
   begin
     if (gUseClob) then
      if NOT (gClobInit) then
       dbms_lob.createTemporary(gClob, true, dbms_lob.session);
       dbms_lob.open(gClob, dbms_lob.lob_readwrite);
       gClobInit := true;
      end if;
      if (newData is not null) then
       dbms_lob.writeAppend(gClob, length(newData), newData);
     end if;
    end if;
   end;


   /*--------------------------------------------------------------------------
   * APPEND_DATA
   *
   * Description:
   *   Called by GET_FLOW_DEFINITION, GET_BASE_DEFINITION, GET_ACTIVITY_DEFINITION
   *   GET_TRANSITION_DEFINITION, GET_FLOW_INSTANCE, GET_BASE_INSTANCE,
   *    GET_ACTIVITY_INSTANCE, GET_TRANSITION_INSTANCE procedures.

   *   Appends data to the Clob object
   *
   * Parameters:
   *   new_Data : Data to be appended
   *
   * Notes:
   *   To remove htp.p calls we have appended the data to a clob there by
   *   returning clob object
   *-------------------------------------------------------------------------*/

   procedure append_data(newData in varchar2)
   is
   begin
    if (gUseClob) then
     append_clob_data(newData|| NL_CHAR);
    else
     if(newData is not null) then
      l_data := l_data || NL_CHAR || newData;
     end if;
    end if;
   end;

  /*--------------------------------------------------------------------------
   * GET_FLOW_DEFINITION
   *
   * Description:
   *   Public procedure.  Called by Java front-end (FlowDiagram.java).
   *   Get definitions of all process activities and transitions in the base
   *   process.
   *
   * Parameters:
   *   x_base_type   - Base item type, first part of id.
   *   x_base_name   - Base process name, second part of id.
   *   x_parent_type - Parent item type. Default to null.
   *   x_parent_name - Parent process_name. Default to null.
   *
   * Notes:
   *   x_parent_type and x_parent_name are used when the base process has
   *   a parent process of different item_type. Used when zooming-in a
   *   subprocess.
   *-------------------------------------------------------------------------*/
  FUNCTION get_flow_definition(
  x_base_type   VARCHAR2,
  x_base_name   VARCHAR2,
  x_parent_type VARCHAR2,
  x_parent_name VARCHAR2) RETURN CLOB IS

    temp_name      VARCHAR2(30) := '';
    parent_type    VARCHAR2(8) := '';
    parent_name    VARCHAR2(30) := '';
    parent_version NUMBER;
    start_date     DATE;
    base_version   NUMBER;
    res            BOOLEAN;

  BEGIN
    --dbms_output.enable(1000000);
    --dbms_output.put_line('get_flow_definition');
    start_date := SYSDATE;

    l_data := '';
    gUseClob := false; --for error messages only

    /*res := ICX_SEC.ValidateSession( c_validate_only => 'Y',
                                    c_update => FALSE);

    if (res = FALSE ) then
      wf_core.raise('WFSEC_NO_SESSION');
    end if; */

    IF (x_parent_type IS NULL OR x_parent_name IS NULL) THEN
      temp_name := 'ROOT';
    ELSE
      temp_name := x_parent_name;
    END IF;

    -- check whether parent information exists
    BEGIN
      SELECT DISTINCT wav.item_type, wav.name, wav.version
      INTO   parent_type, parent_name, parent_version
      FROM   wf_process_activities wpa,
             wf_activities wav
      WHERE  wpa.activity_item_type = x_base_type
      AND    wpa.activity_name = x_base_name
      AND    wav.item_type = wpa.process_item_type
      AND    wav.name = wpa.process_name
      AND    wav.name = temp_name
      AND    wav.begin_date <= start_date
      AND    (wav.end_date IS NULL
      OR     wav.end_date > start_date);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        append_data('ERROR:' || 'WFMON_PROCESS_NOT_FOUND');
        RETURN l_data;
      WHEN OTHERS THEN
        append_data('ERROR:' || 'WFMON_OTHER_ERROR');
        RETURN l_data;
    END;

    SELECT version
    INTO   base_version
    FROM   wf_activities
    WHERE  item_type = x_base_type
    AND    name = x_base_name
    AND    begin_date <= start_date
    AND    (end_date IS NULL
    OR     end_date > start_date);

    /* Set useClob here */
 	     gUseClob := true;

    IF (x_parent_type IS NULL OR x_parent_name IS NULL) THEN
      get_base_definition(x_base_type, 'ROOT',
                          x_base_type, x_base_name, start_date);
    ELSE
      get_base_definition(x_parent_type, x_parent_name,
                          x_base_type, x_base_name, start_date);
    END IF;

    get_activity_definitions(x_base_type, x_base_name, base_version,
                             start_date);

    get_transition_definitions(x_base_type, x_base_name, base_version,
                               start_date);

  --Resetting global variables here.
 	 gUseClob := false;
 	 gClobInit := false;
 	 return gClob;

  END get_flow_definition;

  /*--------------------------------------------------------------------------
   * GET_BASE_DEFINITION
   *
   * Description:
   *   Private procedure.  Called by get_flow_definition.
   *   Get definition of the base process activity.
   *
   * Parameters:
   *   x_parent_type  - Item type of the parent process.
   *   x_parent_name  - Name of the parent process.
   *   x_base_type    - Item type of the base process.
   *   x_base_name    - Name of the base process.
   *   x_start_date   - Begin date of the parent process.
   *
   * Notes:
   *   DECODE are used to replace null values so that each value is properly
   *   separated and the front-end knows how to interpret.
   *-------------------------------------------------------------------------*/
  PROCEDURE get_base_definition(x_parent_type  IN VARCHAR2,
                                x_parent_name  IN VARCHAR2,
                                x_base_type    IN VARCHAR2,
                                x_base_name    IN VARCHAR2,
                                x_start_date   IN DATE) IS

    CURSOR base_definition_cursor IS
      SELECT wav.item_type,
             wav.name,
             wav.display_name,
             wav.version,
             wav.type,
             wav.icon_name,
             wpa.instance_id,
             NVL(wpa.start_end,' ') start_end,
             DECODE(wpa.icon_geometry, '', '0,0', wpa.icon_geometry) geometry
      FROM   wf_process_activities wpa,
             wf_activities_vl wav,
             wf_activities wav2
      WHERE  wpa.process_item_type = x_parent_type  /* check parent activity */
      AND    wpa.process_name = x_parent_name
      AND    wav2.item_type = wpa.process_item_type
      AND    wav2.name = wpa.process_name
      AND    wav2.version = wpa.process_version
      AND    wav2.begin_date <= x_start_date
      AND    (wav2.end_date IS NULL
      OR     wav2.end_date > x_start_date)
      AND    wpa.activity_item_type = x_base_type   /* find base activity */
      AND    wpa.activity_name = x_base_name
      AND    wav.item_type = wpa.activity_item_type
      AND    wav.name = wpa.activity_name
      AND    wav.begin_date <= x_start_date
      AND    (wav.end_date IS NULL
      OR     wav.end_date > x_start_date);

    base base_definition_cursor%ROWTYPE;

    l_tab varchar2(30) := wf_core.local_chr(9);

  BEGIN
    /*dbms_output.put_line('get_base_definition:' ||
                   x_parent_type || ','||
                                x_parent_name || ',' ||
                                x_base_type   || ',' ||
                                x_base_name   || ',' ||
                                x_start_date); */


    OPEN base_definition_cursor;
    FETCH base_definition_cursor INTO base;
    IF (base_definition_cursor%NOTFOUND) THEN
      append_data('ERROR:' || 'WFMON_INVALID_PROCESS_DEF');
      RETURN;
    END IF;


    /* dbms_output.put_line('BASE: ' || base.item_type    || ', ' ||
                                     base.name         || ', ' ||
                                     base.display_name || ', ' ||
                                     base.version      || ', ' ||
                                     base.type         || ', ' ||
                                     base.icon_name    || ', ' ||
                                     base.instance_id  || ', ' ||
                                     base.start_end    || ', ' ||
                                     base.geometry); */


    append_data('BASE:' ||
          base.item_type    || l_tab ||
          base.name         || l_tab ||
          base.display_name || l_tab ||
          base.version      || l_tab ||
          base.type         || l_tab ||
          base.icon_name    || l_tab ||
          base.instance_id  || l_tab ||
          base.start_end    || l_tab ||
          base.geometry);

  END get_base_definition;

  /*--------------------------------------------------------------------------
   * GET_ACTIVITY_DEFINITIONS
   *
   * Description:
   *   Private procedure.  Called by get_flow_definition.
   *   Get definition of the all the activities in this process.
   *
   * Parameters:
   *   x_base_type    - Item type of the base process.
   *   x_base_name    - Name of the base process.
   *   x_base_version - Version of the base process.
   *   x_start_date   - Begin date of base's parent process.
   *
   * Notes:
   *   DECODE are used to replace null values so that each value is properly
   *   separated and the front-end knows how to interpret.
   *-------------------------------------------------------------------------*/
  PROCEDURE get_activity_definitions(x_base_type    IN VARCHAR2,
                                     x_base_name    IN VARCHAR2,
                                     x_base_version IN NUMBER,
                                     x_start_date   IN DATE) IS

    CURSOR activity_definitions_cursor IS
      SELECT wav.item_type,
             wav.name,
             wav.display_name,
             wav.version,
             wav.type,
             wav.icon_name,
             wpa.instance_id,
             NVL(wpa.start_end,' ') start_end,
             wpa.icon_geometry
      FROM   wf_process_activities wpa,
             wf_activities_vl wav,
             wf_activities wav2
      WHERE  wpa.process_item_type = x_base_type      /* check base activity */
      AND    wpa.process_name = x_base_name
      AND    wpa.process_version = x_base_version     /* must have version */
      AND    wav2.item_type = wpa.process_item_type
      AND    wav2.name = wpa.process_name
      AND    wav2.begin_date <= x_start_date
      AND    (wav2.end_date IS NULL
      OR     wav2.end_date > x_start_date)
      AND    wav.item_type = wpa.activity_item_type   /* find all activities */
      AND    wav.name = wpa.activity_name
      AND    wav.begin_date <= x_start_date
      AND    (wav.end_date IS NULL
      OR     wav.end_date > x_start_date);

    activity activity_definitions_cursor%ROWTYPE;

    l_tab varchar2(30) := wf_core.local_chr(9);

  BEGIN

    OPEN activity_definitions_cursor;
    LOOP
      FETCH activity_definitions_cursor INTO activity;
      EXIT WHEN activity_definitions_cursor%NOTFOUND;


      /* dbms_output.put_line('ACTIVITY: ' || activity.item_type    || ', ' ||
                                           activity.name         || ', ' ||
                                           activity.display_name || ', ' ||
                                           activity.version      || ', ' ||
                                           activity.type         || ', ' ||
                                           activity.icon_name    || ', ' ||
                                           activity.instance_id  || ', ' ||
                                           activity.start_end    || ', ' ||
                                           activity.icon_geometry); */


      append_data('ACTIVITY:' ||
            activity.item_type    || l_tab ||
            activity.name         || l_tab ||
            activity.display_name || l_tab ||
            activity.version      || l_tab ||
            activity.type         || l_tab ||
            activity.icon_name    || l_tab ||
            activity.instance_id  || l_tab ||
            activity.start_end    || l_tab ||
            activity.icon_geometry);
    END LOOP;

  END get_activity_definitions;

  /*--------------------------------------------------------------------------
   * GET_TRANSITION_DEFINITIONS
   *
   * Description:
   *   Private procedure.  Called by get_flow_definition.
   *   Get definition of the all the transitions between activities in the
   *   base process.
   *
   * Parameters:
   *   x_base_type    - Item type of the base process.
   *   x_base_name    - Name of the base process.
   *   x_base_version - Version of the base process.
   *   x_start_date   - Begin date of base's parent process.
   *
   * Notes:
   *   DECODE is used to replace null values so that each value is properly
   *   separated and the front-end knows how to interpret.
   *-------------------------------------------------------------------------*/
  PROCEDURE get_transition_definitions(x_base_type    IN VARCHAR2,
                                       x_base_name    IN VARCHAR2,
                                       x_base_version IN NUMBER,
                                       x_start_date   IN DATE) IS

    CURSOR transition_definitions_cursor IS
      SELECT wpa.icon_geometry from_icon,
             wpa.instance_id from_instance,
             DECODE(wf_core.activity_result(wav2.result_type,wat.result_code),
                    '*', ' ',
                    wf_core.activity_result(wav2.result_type,wat.result_code))
             label,
             wpa2.icon_geometry to_icon,
             wpa2.instance_id to_instance,
             wat.arrow_geometry
      FROM   wf_process_activities wpa,
             wf_activities_vl wav,
             wf_activities_vl wav2,
             wf_activity_transitions wat,
             wf_process_activities wpa2
      WHERE  wpa.process_item_type = x_base_type      /* check base activity */
      AND    wpa.process_name = x_base_name
      AND    wpa.process_version = x_base_version
      AND    wav.item_type = wpa.process_item_type
      AND    wav.name = wpa.process_name
      AND    wav.version = wpa.process_version
      AND    wav.begin_date <= x_start_date
      AND    (wav.end_date IS NULL
      OR     wav.end_date > x_start_date)
      AND    wav2.item_type = wpa.activity_item_type  /* check activities */
      AND    wav2.name = wpa.activity_name            /* get label */
      AND    wav2.begin_date <= x_start_date
      AND    (wav2.end_date IS NULL
      OR     wav2.end_date > x_start_date)
      AND    wat.from_process_activity = wpa.instance_id
      AND    wpa2.instance_id = wat.to_process_activity;

    transition transition_definitions_cursor%ROWTYPE;

    l_tab varchar2(30) := wf_core.local_chr(9);

  BEGIN

    OPEN transition_definitions_cursor;
    LOOP
      FETCH transition_definitions_cursor INTO transition;
      EXIT WHEN transition_definitions_cursor%NOTFOUND;

      /* dbms_output.put_line('TRANSITION: '|| transition.from_icon    || ', '||
                                            transition.from_instance|| ', '||
                                            transition.label        || ', '||
                                            transition.to_icon      || ', '||
                                            transition.to_instance  || ', '||
                                            transition.arrow_geometry); */


      append_data('TRANSITION:' ||
            transition.from_icon      || l_tab ||
            transition.from_instance  || l_tab ||
            transition.label          || l_tab ||
            transition.to_icon        || l_tab ||
            transition.to_instance    || l_tab ||
            transition.arrow_geometry);
    END LOOP;

  END get_transition_definitions;

  /*--------------------------------------------------------------------------
   * GET_FLOW_INSTANCE
   *
   * Description:
   *   Public procedure.  Called by Java front-end (FlowDiagram.java).
   *   Get defintions and state info of all process activities and transitions
   *   in the process instance.
   *
   * Parameters:
   *   x_item_type   - Item type for the process instance, first part of
   *                   instance id.
   *   x_item_key    - Item key for the process instance, second part of
   *                   instance id. For retrieving state info.
   *   x_parent_type - Parent item type, for retrieving base process
   *                   information. (A process of one item_type can contain
   *                   activities of other item_types.) Default to null.
   *   x_parent_name - Parent process_name, for retrieving base process
   *                   information. (A process of one item_type can contain
   *                   activities of other item_types.) Default to null.
   *   x_base_type   - Item type, first id of the process defintion. Default
   *                   to null.
   *   x_base_name   - Process name, second id of the process definition.
   *                   Default to null.
   *
   * Notes:
   *
   *-------------------------------------------------------------------------*/
  FUNCTION get_flow_instance(x_item_type   VARCHAR2,
                              x_item_key    VARCHAR2,
                              x_parent_type VARCHAR2,
                              x_parent_name VARCHAR2,
                              x_base_type   VARCHAR2,
                              x_base_name   VARCHAR2) RETURN CLOB IS

    base_name    VARCHAR(30) := '';
    base_version NUMBER;
    start_date   DATE;
    res            BOOLEAN;

  BEGIN

  l_data := '';
  gUseClob := false; --for error messages only

    --dbms_output.enable(1000000);
    --dbms_output.put_line('get_flow_instance');

    /*res := ICX_SEC.ValidateSession( c_validate_only => 'Y',
                                    c_update => FALSE);

    if (res = FALSE ) then
      wf_core.raise('WFSEC_NO_SESSION');
    end if; */

    BEGIN
      SELECT root_activity, root_activity_version, begin_date
      INTO   base_name, base_version, start_date
      FROM   wf_items
      WHERE  item_type = x_item_type
      AND    item_key = x_item_key;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        append_data('ERROR:' || 'WFMON_PROCESS_NOT_FOUND');
        RETURN l_data;
      WHEN OTHERS THEN
        append_data('ERROR:' || 'WFMON_OTHER_ERROR');
        RETURN l_data;
    END;

    /* Set useClob here */
    gUseClob := true;

    IF (x_parent_type IS NULL OR x_parent_name IS NULL OR
        x_base_type IS NULL OR x_base_name IS NULL) THEN
      get_base_instance(x_item_type, x_item_key, 'ROOT',
                        x_item_type, base_name, start_date);

      get_activity_instances(x_item_type, x_item_key,
                             x_item_type, base_name, start_date);

      get_transition_instances(x_item_type, x_item_key,
                               x_item_type, base_name, start_date);
    ELSE
      get_base_instance(x_parent_type, x_item_key, x_parent_name,
                        x_base_type, x_base_name, start_date);

      get_activity_instances(x_item_type, x_item_key,
                             x_base_type, x_base_name, start_date);

      get_transition_instances(x_item_type, x_item_key,
                               x_base_type, x_base_name, start_date);
    END IF;

    --Resetting global variables here.
    gUseClob := false;
    gClobInit := false;
    return gClob;

  END get_flow_instance;

  /*--------------------------------------------------------------------------
   * GET_BASE_INSTANCE
   *
   * Description:
   *   Private procedure.  Called by get_flow_instance.
   *   Get defintions and state info of the base activity in the instance of
   *   this process identified by  the item key.
   *
   * Parameters:
   *   x_item_type   - Item type of the parent process.
   *   x_item_key    - Item key that uniquely identifies the instance.
   *   x_parent_name - Name of the parent process.
   *   x_base_type   - Item type of the base activity.
   *   x_base_name   - Name of the base activity.
   *   x_start_date  - Begin date of the parent process.
   *
   * Notes:
   *   DECODE is used to replace null values so that each value is properly
   *   separated and the front-end knows how to interpret.
   *-------------------------------------------------------------------------*/
 PROCEDURE get_base_instance(x_item_type    IN VARCHAR2,
                             x_item_key     IN VARCHAR2,
                             x_parent_name  IN VARCHAR2,
                             x_base_type    IN VARCHAR2,
                             x_base_name    IN VARCHAR2,
                             x_start_date   IN DATE) IS

    CURSOR base_instance_cursor IS
      SELECT wav.item_type,
             wav.name,
             wav.display_name,
             wav.version,
             wav.type,
             wav.icon_name,
             wpa.instance_id,
             DECODE(wpa.start_end, '', ' ', wpa.start_end) start_end,
             DECODE(wpa.icon_geometry, '', '0,0', wpa.icon_geometry) geometry,
             DECODE(wf_core.activity_result(wav.result_type,wpa.default_result),
                    '', ' ',
                    wf_core.activity_result(wav.result_type,wpa.default_result))
             usage_result,
             DECODE(wias.activity_status, '', ' ', wias.activity_status)
             activity_status
      FROM   wf_process_activities wpa,
             wf_activities_vl wav,
             wf_activities_vl wav2,
             wf_item_activity_statuses wias
      WHERE  wpa.process_item_type = x_item_type    -- check parent activity
      AND    wpa.process_name = x_parent_name
      AND    wav2.item_type = wpa.process_item_type
      AND    wav2.name = wpa.process_name
      AND    wav2.version = wpa.process_version
      AND    wav2.begin_date <= x_start_date
      AND    (wav2.end_date IS NULL
      OR     wav2.end_date > x_start_date)
      AND    wpa.activity_item_type = x_base_type     -- find base activity
      AND    wpa.activity_name = x_base_name
      AND    wav.item_type = wpa.activity_item_type
      AND    wav.name = wpa.activity_name
      AND    wav.begin_date <= x_start_date
      AND    (wav.end_date IS NULL
      OR     wav.end_date > x_start_date)
      AND    wias.item_type (+) = x_item_type         -- find base status
      AND    wias.item_key (+) = x_item_key
      AND    wias.process_activity (+) = wpa.instance_id;

    base base_instance_cursor%ROWTYPE;

    l_tab varchar2(30) := wf_core.local_chr(9);

  BEGIN

    OPEN base_instance_cursor;
    FETCH base_instance_cursor INTO base;
    IF (base_instance_cursor%NOTFOUND) THEN
      append_data('ERROR:' || 'WFMON_INVALID_PROCESS_DEF');
      RETURN;
    END IF;

/*
    dbms_output.put_line('BASE: ' || base.item_type     || ', ' ||
                                     base.name          || ', ' ||
                                     base.display_name  || ', ' ||
                                     base.version       || ', ' ||
                                     base.type          || ', ' ||
                                     base.icon_name     || ', ' ||
                                     base.instance_id   || ', ' ||
                                     base.start_end     || ', ' ||
                                     base.geometry      || ', ' ||
                                     base.usage_result  || ', ' ||
                                     base.activity_status);
*/

    append_data('BASE:' ||
          base.item_type     || l_tab ||
          base.name          || l_tab ||
          base.display_name  || l_tab ||
          base.version       || l_tab ||
          base.type          || l_tab ||
          base.icon_name     || l_tab ||
          base.instance_id   || l_tab ||
          base.start_end     || l_tab ||
          base.geometry      || l_tab ||
          base.usage_result  || l_tab ||
          base.activity_status);

  END get_base_instance;

  /*--------------------------------------------------------------------------
   * GET_ACTIVITY_INSTANCES
   *
   * Description:
   *   Private procedure.  Called by get_flow_instance.
   *   Get defintions and state info of all the activities in the instance of
   *   the process identified by the item key.
   *
   * Parameters:
   *   x_item_type   - Item type of the parent process.
   *   x_item_key    - Item key that uniquely identifies the instance.
   *   x_base_type   - Item type of the base activity.
   *   x_base_name   - Name of the base activity.
   *   x_start_date  - Begin date of the parent process.
   *
   * Notes:
   *   DECODE is used to replace null values so that each value is properly
   *   separated and the front-end knows how to interpret.
   *-------------------------------------------------------------------------*/
  PROCEDURE get_activity_instances(x_item_type    IN VARCHAR2,
                                   x_item_key     IN VARCHAR2,
                                   x_base_type    IN VARCHAR2,
                                   x_base_name    IN VARCHAR2,
                                   x_start_date   IN DATE) IS

    CURSOR activity_instances_cursor IS
      SELECT wav.item_type,
             wav.name,
             wav.display_name,
             wav.version,
             wav.type,
             wav.icon_name,
             wpa.instance_id,
             DECODE(wpa.start_end, '', ' ', wpa.start_end) start_end,
             wpa.icon_geometry,
             DECODE(wf_core.activity_result(wav.result_type, wpa.default_result),
                    '', ' ',
                    wf_core.activity_result(wav.result_type, wpa.default_result))
             usage_result,
             DECODE(wias.activity_status, '', ' ', wias.activity_status)
             activity_status
      FROM   wf_process_activities wpa,
             wf_activities_vl wav,
             wf_activities_vl wav2,
             wf_item_activity_statuses wias
      WHERE  wpa.process_item_type = x_base_type      /* check base activity */
      AND    wpa.process_name = x_base_name
      AND    wav2.item_type = wpa.process_item_type
      AND    wav2.name = wpa.process_name
      AND    wav2.begin_date <= x_start_date
      AND    (wav2.end_date IS NULL
      OR     wav2.end_date > x_start_date)
      AND    wav2.version = wpa.process_version
      AND    wav.item_type = wpa.activity_item_type   /* find all activities */
      AND    wav.name = wpa.activity_name
      AND    wav.begin_date <= x_start_date
      AND    (wav.end_date IS NULL
      OR     wav.end_date > x_start_date)
      AND    wias.item_type (+) = x_item_type        /* find activity status */
      AND    wias.item_key (+) = x_item_key
      AND    wias.process_activity (+) = wpa.instance_id;

    activity activity_instances_cursor%ROWTYPE;

    l_tab varchar2(30) := wf_core.local_chr(9);

  BEGIN

    OPEN activity_instances_cursor;
    LOOP
      FETCH activity_instances_cursor INTO activity;
      EXIT WHEN activity_instances_cursor%NOTFOUND;

/*
      dbms_output.put_line('ACTIVITY: ' || activity.item_type     || ', ' ||
                                           activity.name          || ', ' ||
                                           activity.display_name  || ', ' ||
                                           activity.version       || ', ' ||
                                           activity.type          || ', ' ||
                                           activity.icon_name     || ', ' ||
                                           activity.instance_id   || ', ' ||
                                           activity.start_end     || ', ' ||
                                           activity.icon_geometry || ', ' ||
                                           activity.usage_result  || ', ' ||
                                           activity.activity_status);
*/

      append_data('ACTIVITY:' ||
            activity.item_type     || l_tab ||
            activity.name          || l_tab ||
            activity.display_name  || l_tab ||
            activity.version       || l_tab ||
            activity.type          || l_tab ||
            activity.icon_name     || l_tab ||
            activity.instance_id   || l_tab ||
            activity.start_end     || l_tab ||
            activity.icon_geometry || l_tab ||
            activity.usage_result  || l_tab ||
            activity.activity_status);
    END LOOP;

  END get_activity_instances;

  /*--------------------------------------------------------------------------
   * GET_TRAINSITION_INSTANCES
   *
   * Description:
   *   Private procedure.  Called by get_flow_instance.
   *   Get defintions and state info of all transitions in the instance of
   *   the process identified by the item key.
   *
   * Parameters:
   *   x_item_type   - Item type of the parent process.
   *   x_item_key    - Item key that uniquely identifies the instance.
   *   x_base_type   - Item type of the base activity.
   *   x_base_name   - Name of the base activity.
   *   x_start_date  - Begin date of the parent process.
   *
   * Notes:
   *   We first find all the activities in the process and then use their
   *   instance id to look up the transitions associated with the process
   *   instance.
   *   DECODE is used to replace null values so that each value is properly
   *   separated and the front-end knows how to interpret.
   *-------------------------------------------------------------------------*/
  PROCEDURE get_transition_instances(x_item_type  IN VARCHAR2,
                                     x_item_key   IN VARCHAR2,
                                     x_base_type  IN VARCHAR2,
                                     x_base_name  IN VARCHAR2,
                                     x_start_date IN DATE) IS

    CURSOR transition_instances_cursor IS
      SELECT wpa.icon_geometry from_icon,
             wpa.instance_id   from_instance,
             DECODE(wf_core.activity_result(wav2.result_type,wat.result_code),
                    '*',' ',
                    wf_core.activity_result(wav2.result_type,wat.result_code))
             label,
             wpa2.icon_geometry to_icon,
             wpa2.instance_id  to_instance,
             wat.arrow_geometry,
             wl.lookup_code visited                /* transition status  */
      FROM   wf_process_activities wpa,
             wf_activities_vl wav,
             wf_activities_vl wav2,
             wf_activity_transitions wat,
             wf_process_activities wpa2,
             wf_item_activity_statuses wias,
             wf_lookups wl
      WHERE  wpa.process_item_type = x_base_type     /* check base activity */
      AND    wpa.process_name = x_base_name
      AND    wav.item_type = wpa.process_item_type
      AND    wav.name = wpa.process_name
      AND    wav.version = wpa.process_version
      AND    wav.begin_date <= x_start_date
      AND    (wav.end_date IS NULL
      OR     wav.end_date > x_start_date)
      AND    wav2.item_type = wpa.activity_item_type   /* check activities */
      AND    wav2.name = wpa.activity_name
      AND    wav2.begin_date <= x_start_date
      AND    (wav2.end_date IS NULL
      OR     wav2.end_date > x_start_date)
      AND    wat.from_process_activity = wpa.instance_id
      AND    wpa2.instance_id = wat.to_process_activity
      AND    wias.item_type (+) = x_item_type          /* find status */
      AND    wias.item_key (+) = x_item_key
      AND    wias.process_activity (+) = wpa.instance_id
      AND    wl.lookup_type = 'WFSTD_BOOLEAN'
      AND    ((wias.activity_status = 'COMPLETE'
      AND    (wat.result_code = wias.activity_result_code
      OR     wat.result_code = '*'
      AND    NOT EXISTS (SELECT NULL
                         FROM   wf_activity_transitions
                         WHERE  from_process_activity = wpa.instance_id
                         AND    result_code = wias.activity_result_code))
      AND    wl.lookup_code = 'T')
      OR     (NOT (wias.activity_status = 'COMPLETE'
      AND    (wat.result_code = wias.activity_result_code
      OR     wat.result_code = '*'
      AND    NOT EXISTS (SELECT NULL
                         FROM   wf_activity_transitions
                         WHERE  from_process_activity = wpa.instance_id
                         AND    result_code = wias.activity_result_code)))
      OR     wias.activity_status IS NULL)          /* end of OR (NOT... */
      AND    wl.lookup_code = 'F');

    transition transition_instances_cursor%ROWTYPE;

    l_tab varchar2(30) := wf_core.local_chr(9);

  BEGIN

    OPEN transition_instances_cursor;
    LOOP
      FETCH transition_instances_cursor INTO transition;
      EXIT WHEN transition_instances_cursor%NOTFOUND;

/*
      dbms_output.put_line('TRANSITION: '|| transition.from_icon     || ', '||
                                            transition.from_instance || ', '||
                                            transition.label         || ', '||
                                            transition.to_icon       || ', '||
                                            transition.to_instance   || ', '||
                                            transition.arrow_geometry|| ', '||
                                            transition.visited);
*/

      append_data('TRANSITION:' ||
            transition.from_icon      || l_tab ||
            transition.from_instance  || l_tab ||
            transition.label          || l_tab ||
            transition.to_icon        || l_tab ||
            transition.to_instance    || l_tab ||
            transition.arrow_geometry || l_tab ||
            transition.visited);
    END LOOP;

  END get_transition_instances;

  /*--------------------------------------------------------------------------
   * GET_TRANSLATIONS
   *
   * Description:
   *   Public Function.  Called by Java front-end (FlowDiagram.java).
   *   Given a name list concatenated with '^', parse the list and return
   *   an html page of translated list with the same order.
   *
   * Parameters:
   *   x_name_list   -  List of names to be translated, concatenated with an
   *                    agreed delimiter. Currently "^" is used.
   *
   * Notes:
   *
   *-------------------------------------------------------------------------*/
  FUNCTION get_translations(x_name_list VARCHAR2) RETURN VARCHAR2 IS

    labels      VARCHAR2(3000) := x_name_list;
    translated  VARCHAR2(4096) := '';
    break_point NUMBER := 0;
    len         NUMBER := 0;
    total       NUMBER := 1;
    token       VARCHAR2(240);
    temp        VARCHAR2(30);
    res            BOOLEAN;

  BEGIN

   l_data := 'LABELS:';

    --dbms_output.enable(1000000);
    --dbms_output.put_line('get_translations: ' || x_name_list);

    /*res := ICX_SEC.ValidateSession( c_validate_only => 'Y',
                                    c_update => FALSE);

    if (res = FALSE ) then
      wf_core.raise('WFSEC_NO_SESSION');
    end if;*/

    SELECT LENGTH(x_name_list) INTO temp FROM DUAL;
    len := TO_NUMBER(temp);

    LOOP
      SELECT INSTR(x_name_list, '^', total) INTO temp FROM DUAL;

      break_point := TO_NUMBER(temp);
      SELECT SUBSTR(x_name_list, total, break_point - total) INTO token
      FROM DUAL;

      --dbms_output.put_line('token=' || token);

      translated := translated ||
                        SUBSTR(wf_core.translate(token),1, 40) || wf_core.local_chr(9);

      EXIT WHEN (break_point = len);
      total := break_point + 1;

    END LOOP;

    -- appending translater data to l_data
   l_data := l_data || translated;

   return l_data || NL_CHAR;

  END get_translations;

END WF_TASKFLOW;

/
