--------------------------------------------------------
--  DDL for Package Body ITA_BIZ_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_BIZ_EVENTS_PVT" as
/*$Header: itapbevb.pls 120.0 2005/05/31 16:38:47 appldev noship $*/


procedure GENERATE_ITEM_KEY(
  X_NEXT_VALUE in out nocopy VARCHAR2)
is

  l_next_value      number;
  l_procedure_name  varchar2(30) := 'GENERATE_ITEM_KEY';

begin

  select ITA_WORKFLOW_S.nextval
  into   l_next_value
  from   dual;

  x_next_value := to_char(l_next_value);

exception
  when OTHERS then
    if (SQLCODE <> -20001) then
      FND_MESSAGE.SET_NAME('AR', 'HZ_CRUSR_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
      FND_MSG_PUB.ADD;
    end if;
    APP_EXCEPTION.RAISE_EXCEPTION;

end GENERATE_ITEM_KEY;


function RAISE_CHANGE_EVENT(
  P_APPLICATION_ID VARCHAR2,
  P_TABLE_NAME VARCHAR2,
  P_ROW_ID VARCHAR2)
return VARCHAR2 is

  l_item_key        WF_ITEMS.ITEM_KEY%type;
  l_parameter_list  WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

begin

  generate_item_key(x_next_value => l_item_key);

  WF_EVENT.addParameterToList(
    p_name => 'APPLICATION_ID',
    p_value => p_application_id,
    p_parameterlist => l_parameter_list);

  WF_EVENT.addParameterToList(
    p_name => 'TABLE_NAME',
    p_value => p_table_name,
    p_parameterlist => l_parameter_list);

  WF_EVENT.addParameterToList(
    p_name => 'ROW_ID',
    p_value => p_row_id,
    p_parameterlist => l_parameter_list);

  WF_EVENT.raise(
    p_event_name => 'oracle.apps.ita.setup.record',
    p_event_key => l_item_key,
    p_parameters => l_parameter_list);

  return l_item_key;

exception when OTHERS then raise;

end RAISE_CHANGE_EVENT;


end ITA_BIZ_EVENTS_PVT;

/
