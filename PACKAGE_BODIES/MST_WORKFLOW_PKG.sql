--------------------------------------------------------
--  DDL for Package Body MST_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_WORKFLOW_PKG" AS
/* $Header: MSTEXWFB.pls 115.5 2004/08/04 15:16:19 atsrivas noship $ */

  type number_tab_type is table of number index by binary_integer;
  type varchar2_tab_type is table of varchar2(500) index by binary_integer;

  p_log_message number := 1;

  procedure print_info(p_log_message in number, p_info_str in varchar2);


PROCEDURE launch_workflow (errbuf   out nocopy varchar2
                          ,retcode  out nocopy number
                          ,p_plan_id in number) IS

  cursor plan_cur (l_plan_id in NUMBER)
  is
  select compile_designator
  from mst_plans
  where plan_id = l_plan_id;

  l_compile_designator varchar2(100);
  l_message_prefix       varchar2(100);

  cursor StartWFProcess_cur (l_plan_id in NUMBER)
  is
  select med.exception_detail_id
       , med.exception_type
       , 'EXCEPTION_PROCESS1'
       , mst_wb_util.get_trip_tokenized_exception(med.plan_id, med.exception_detail_id, med.trip_id1, 1)
  from mst_excep_preferences mep
     , mst_exception_details med
  where mep.exception_type = med.exception_type
  and mep.user_id = -9999
  and mep.work_flow_item_type = '1' -- 1 stands for status:enabled
  and med.plan_id = l_plan_id;

  l_excep_det_id number;
  l_excep_type number;

  l_excep_det_id_tab number_tab_type;
  l_excep_type_tab   number_tab_type;

  l_workflow_process_tab varchar2_tab_type;
  l_message_tab          varchar2_tab_type;
BEGIN
  -- delete previously generated workflow notifications
  DeleteActivities(p_plan_id);

  open plan_cur(p_plan_id);
  fetch plan_cur into l_compile_designator;
  close plan_cur;

  fnd_message.set_name('MST','MST_STRING_PLAN');
  --fnd_message.get(l_message_prefix);
  l_message_prefix := fnd_message.get;

  open StartWFProcess_cur(p_plan_id);
  fetch StartWFProcess_cur bulk collect into l_excep_det_id_tab, l_excep_type_tab, l_workflow_process_tab, l_message_tab;
  close StartWFProcess_cur;

  if nvl(l_excep_type_tab.last,0) > 0 then
    for i in 1..l_excep_type_tab.last loop

      StartWFProcess('MSTEXPWF'
                    , to_char(p_plan_id) || '-' ||to_char(l_excep_det_id_tab(i))
                    , l_message_prefix||' '||l_compile_designator||': '||l_message_tab(i)
                    , l_workflow_process_tab(i));
    end loop;
  end if;
exception
  when others then
    errbuf := 'Error in MST_WORKFLOW_PKG.launch_workflow function SQL error: ' || sqlerrm;
--    dbms_output.put_line('inside Exception #'||sqlerrm);
    print_info(p_log_message, 'inside Exception #'||sqlerrm);
    retcode := 2;

END launch_workflow;

PROCEDURE StartWFProcess ( p_item_type         in varchar2 default null
		         , p_item_key	       in varchar2
                         , p_message           in varchar2
                         , p_workflow_process  in varchar2) is
BEGIN

  wf_engine.CreateProcess( itemtype => p_item_type
                         , itemkey  => p_item_key
   		         , process  => p_workflow_process);

  wf_engine.SetItemAttrText( itemtype => p_item_type
                           , itemkey  => p_item_key
                           , aname    => 'MST_MSG_BODY'
                           , avalue   => p_Message);

  wf_engine.SetItemAttrText( itemtype => p_item_type
                           , itemkey  => p_item_key
                           , aname    => 'MST_MSG_SUBJECT'
                           , avalue   => p_Message);

  wf_engine.StartProcess( itemtype => p_item_type
                        , itemkey  => p_item_key);

END StartWFProcess;



PROCEDURE Select_Planner( itemtype  in  varchar2
                        , itemkey   in  varchar2
                        , actid     in  number
                        , funcmode  in  varchar2
			, resultout out NOCOPY varchar2) is

  l_msg  varchar2(500);
  l_name varchar2(500);

BEGIN

  l_name := fnd_global.user_name;
  --l_name := 'MFG';
  --l_name := 'rshenwai@oracle.com';

  wf_engine.SetItemAttrText( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'PLANNER'
                           , avalue   => l_name);

  l_msg := GetPlannerMsgName;

  wf_engine.SetItemAttrText( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'MST_MESSAGE'
                           , avalue   => l_msg);

  resultout := 'COMPLETE:FOUND';

END Select_Planner;

FUNCTION GetPlannerMsgName
RETURN varchar2 IS
BEGIN

 return 'MST_MSG1';

END GetPlannerMsgName;

PROCEDURE DeleteActivities( arg_plan_id in number) IS

  CURSOR Cur_Delete_Activities (l_item_type in varchar2, l_plan_char in varchar2)
  IS
  SELECT wi.item_key
  FROM wf_items wi
  WHERE wi.item_type = l_item_type
  AND wi.item_key like l_plan_char;

  TYPE varchar2_tab_type IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  l_item_key_tab        varchar2_tab_type;
  l_item_type           varchar2(8);
  l_plan_char           varchar2(100);

BEGIN
  l_item_type := 'MSTEXPWF';
  l_plan_char := to_char(arg_plan_id) ||'-%';

  OPEN Cur_Delete_Activities (l_item_type,l_plan_char);
  FETCH Cur_Delete_Activities BULK COLLECT INTO l_item_key_tab;
  CLOSE Cur_Delete_Activities;

  IF NVL(l_item_key_tab.LAST,0) > 0 THEN
    FORALL i IN l_item_key_tab.FIRST..l_item_key_tab.LAST
    UPDATE wf_notifications wn
    SET wn.end_date = sysdate
    WHERE wn.group_id IN (SELECT wias.notification_id
                       FROM wf_item_activity_statuses wias
                       WHERE wias.item_type = l_item_type
                       AND wias.item_key = l_item_key_tab(i)
                       UNION ALL
                       SELECT wiah.notification_id
                       FROM wf_item_activity_statuses_h wiah
                       WHERE wiah.item_type = l_item_type
                       AND wiah.item_key = l_item_key_tab(i));

    FORALL i IN l_item_key_tab.FIRST..l_item_key_tab.LAST
    UPDATE wf_items wi
    SET wi.end_date = sysdate
    WHERE wi.item_type = l_item_type
    AND wi.item_key = l_item_key_tab(i);

    FORALL i IN l_item_key_tab.FIRST..l_item_key_tab.LAST
    UPDATE wf_item_activity_statuses wias
    SET wias.end_date = sysdate
    WHERE wias.item_type = l_item_type
    AND wias.item_key = l_item_key_tab(i);

    FORALL i IN l_item_key_tab.FIRST..l_item_key_tab.LAST
    UPDATE wf_item_activity_statuses_h wiah
    SET wiah.end_date = sysdate
    WHERE wiah.item_type = l_item_type
    AND wiah.item_key = l_item_key_tab(i);

    COMMIT;

    FOR i IN l_item_key_tab.FIRST..l_item_key_tab.LAST LOOP
      wf_purge.items(l_item_type,l_item_key_tab(i),sysdate); -- bug 3741028
    END LOOP;

    COMMIT;
  END IF;

EXCEPTION
  when others then
    print_info(p_log_message, 'Error in delete activities:'|| to_char(sqlcode) || ':' || substr(sqlerrm,1,100));
    ROLLBACK;
END DeleteActivities;

Procedure submit_workflow_request (p_request_id   OUT NOCOPY NUMBER
                                  ,p_plan_id      IN         NUMBER) IS
    l_errbuf  varchar2(1000);
    l_retcode number;
  begin
    p_request_id := fnd_request.submit_request('MST', 'MSTEXPWF', null, null, false, p_plan_id);
    if p_request_id = 0 then
      l_errbuf := fnd_message.get;
    else
      commit;
    end if;

Exception
  when others then
--    dbms_output.put_line('Error in Submitting Request: '||substr(sqlerrm,1,100));
    print_info(p_log_message, 'Error in Submitting Request: '||substr(sqlerrm,1,100));
    return;
END submit_workflow_request;

  procedure print_info(p_log_message in number, p_info_str in varchar2) is
  begin
    if p_log_message = 1 then
      fnd_file.put_line(fnd_file.log, p_info_str);
      --dbms_output.put_line(p_info_str);
      --abc123pro(p_info_str);
    end if;
  end print_info;

END MST_WORKFLOW_PKG;

/
