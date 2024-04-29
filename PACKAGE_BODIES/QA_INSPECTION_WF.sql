--------------------------------------------------------
--  DDL for Package Body QA_INSPECTION_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_INSPECTION_WF" AS
/* $Header: qainswfb.pls 115.3 2002/11/27 19:14:36 jezheng ship $ */

FUNCTION raise_frequency_change_event (
    p_process_code IN VARCHAR2,
    p_description IN VARCHAR2,
    p_inspection_plan IN VARCHAR2,
    p_from_frequency IN VARCHAR2,
    p_to_frequency IN VARCHAR2,
    p_criteria IN VARCHAR2,
    p_role_name IN VARCHAR2) RETURN NUMBER IS

    l_itemtype varchar2(30);
    l_process_name VARCHAR2(30);
    l_itemkey  NUMBER;
    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();

    CURSOR c IS
        SELECT qa_ss_notify_workflow_s.nextval FROM dual;

BEGIN

    l_itemtype     := 'QASKPFRQ';
    l_process_name := 'QASKPFRQ';

    OPEN c;
    FETCH c INTO l_itemkey;
    CLOSE c;

    wf_event.addParameterToList(p_name => 'PROCESS_CODE',
        p_value => p_process_code,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'DESCRIPTION',
        p_value => p_description,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'INSPECTION_PLAN',
        p_value => p_inspection_plan,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'FROM_FREQUENCY',
        p_value => p_from_frequency,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'TO_FREQUENCY',
        p_value => p_to_frequency,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'CRITERIA',
        p_value => p_criteria,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'SUPERVISOR',
        p_value => p_role_name,
        p_parameterlist => l_parameter_list);

    wf_event.raise(
        p_event_name     => 'QA SKIPLOT FREQUENCY CHANGE',
        p_event_key      => l_itemkey,
        p_parameters     => l_parameter_list);

    RETURN l_itemkey;

END raise_frequency_change_event;


FUNCTION raise_reduced_inspection_event (
    p_lot_information IN VARCHAR2,
    p_inspection_date DATE,
    p_plan_name IN VARCHAR2,
    p_role_name IN VARCHAR2) RETURN NUMBER IS

    l_itemtype varchar2(30);
    l_process_name VARCHAR2(30);
    l_itemkey  NUMBER;
    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();

    CURSOR c IS
        SELECT qa_ss_notify_workflow_s.nextval FROM dual;

BEGIN

    l_itemtype     := 'QASPINSP';
    l_process_name := 'QASPINSP';

    OPEN c;
    FETCH c INTO l_itemkey;
    CLOSE c;

    wf_event.addParameterToList(p_name => 'LOT_INFORMATION',
        p_value => p_lot_information,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'PLAN_NAME',
        p_value => p_plan_name,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'INSPECTION_DATE',
        p_value => p_inspection_date,
        p_parameterlist => l_parameter_list);

    wf_event.addParameterToList(p_name => 'SUPERVISOR',
        p_value => p_role_name,
        p_parameterlist => l_parameter_list);

    wf_event.raise(
        p_event_name     => 'QA SAMPLING REDUCED INSPECTION',
        p_event_key      => l_itemkey,
        p_parameters     => l_parameter_list);

    RETURN l_itemkey;

END raise_reduced_inspection_event;

END qa_inspection_wf;

/
