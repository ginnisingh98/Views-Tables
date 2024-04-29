--------------------------------------------------------
--  DDL for Package Body XXAH_HXC_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_HXC_APPROVAL_PKG" 
/****************************************************************
 * Copyright Oracle Netherlands 2009
 *
 * PACKAGE       : XXAH_HXC_APPROVAL_PKG
 * DESCRIPTION   : Package with functions for customized
 *                 time approval HXCEMP workflow.
 * AUTHOR        : Kevin Bouwmeester
 *                 kevin.bouwmeester@oracle.com
 * CREATION DATE : 03-DEC-2009
 * HISTORY       : version 1.0 - 25-AUG-2008 - genesis
 *
 ****************************************************************/
IS

 gc_module_name CONSTANT VARCHAR2(50) := 'XXAH_APPROVAL_PKG';
 gc_logging_lvl CONSTANT NUMBER        := FND_LOG.LEVEL_STATEMENT;

 gc_wf_yes CONSTANT VARCHAR2(3) := 'Y';
 gc_wf_no  CONSTANT VARCHAR2(3) := 'N';

 gc_yes CONSTANT VARCHAR2(3) := 'Yes';
 gc_no  CONSTANT VARCHAR2(3) := 'No';

/****************************************************************
 * PROCEDURE     : flog
 * DESCRIPTION   : calling the fnd_log package
 * PARAMETERS    : p_proc_name : calling procedure name
 *                 p_message   : message to write to log
 ****************************************************************/
PROCEDURE flog
( p_proc_name IN VARCHAR2
, p_message   IN VARCHAR2
)
IS
BEGIN
  fnd_log.string
  ( log_level => gc_logging_lvl
  , module    => gc_module_name || '.' || p_proc_name
  , message   => p_message
  );
END;

/****************************************************************
 * PROCEDURE     : approval_needed
 * DESCRIPTION   : Check if the project is for administrative
 *                 purpose. If so, no project manager's time
 *                 approval is needed.
 * PARAMETERS    : p_itemtype  : item type (name) of calling wf
 *                 p_itemkey   : item key (instance) of calling wf
 *                 p_actid     : activity id of calling wf
 *                 p_funcmode  : function mode of calling wf
 *                 p_resultout : result back to calling wf
 ****************************************************************/
PROCEDURE approval_needed
( p_itemtype  IN VARCHAR2
, p_itemkey   IN VARCHAR2
, p_actid     IN NUMBER
, p_funcmode  IN VARCHAR2
, p_resultout IN OUT NOCOPY VARCHAR2
)
IS

  lc_proc_name CONSTANT VARCHAR(50) := 'approval_needed';

  l_app_bb_id       NUMBER;
  l_resource_id     NUMBER;
  l_pm_person_id    NUMBER;

  l_approval_needed BOOLEAN;

  no_approval_needed EXCEPTION;

  cursor c_project
  ( b_app_period_id HXC_AP_DETAIL_LINKS.application_period_id%TYPE
  )
  is
  select distinct tat.attribute1     project_id
  ,      nvl(ppc.class_code,'Yes')   time_approval_needed
  from   HXC_TIME_ATTRIBUTE_USAGES   tau
  ,      hxc_time_attributes         tat
  ,      HXC_AP_DETAIL_LINKS         adl
  ,      pa_project_classes          ppc
  where  tau.time_building_block_id  = adl.time_building_block_id
  and    tau.time_building_block_ovn = adl.time_building_block_ovn
  and    adl.application_period_id   = b_app_period_id
  and    tat.attribute_category      = 'PROJECTS'
  and    tau.time_attribute_id       = tat.time_attribute_id
  and    ppc.project_id (+)          = tat.attribute1
  and    ppc.class_category (+)      = 'Project Manager Time Approval'
  ;


BEGIN

  flog(lc_proc_name, 'begin');


  l_app_bb_id := wf_engine.GETITEMATTRNUMBER( itemtype        => p_itemtype
                                            , itemkey         => p_itemkey
                                            , aname           => 'APP_BB_ID'
                                            , ignore_notfound => TRUE
                                            );

  l_resource_id := wf_engine.GETITEMATTRNUMBER( itemtype        => p_itemtype
                                              , itemkey         => p_itemkey
                                              , aname           => 'RESOURCE_ID'
                                              , ignore_notfound => TRUE
                                              );

  flog(lc_proc_name, 'l_app__bb_id: ' || l_app_bb_id);

  -- Loop through all the projects on the application period. Save if
  -- there is at least one application period that needs PM approval.

  l_approval_needed := FALSE;

  FOR  r_project IN c_project(l_app_bb_id)
  LOOP

       flog(lc_proc_name, 'Project id: ' || r_project.project_id || ' found on appl. period.');
     l_pm_person_id := PA_OTC_API.GetProjectManager(r_project.project_id);
     IF r_project.time_approval_needed = gc_yes
     THEN
       flog(lc_proc_name, 'Timecard approval is needed.');
       l_approval_needed := TRUE;
     END IF;
  END LOOP;

  -- CHECK 1: Is there a project on the application period that needs approval?
  IF NOT l_approval_needed
  THEN
    flog(lc_proc_name, 'There is no project on appl. period that needs approval.');
    RAISE no_approval_needed;
  END IF;

  -- CHECK 2: Is the approver not the same as timecard submitter?
  IF l_resource_id = l_pm_person_id
  THEN
    flog(lc_proc_name, 'Approver is same person a timecard submitter');
    RAISE no_approval_needed;
  END IF;

  -- Application period passed 2 checks, PM approval is needed.
  p_resultout := gc_wf_yes;

EXCEPTION
  WHEN no_approval_needed
  THEN
    -- Because the admin projects don't need pm's approval,
    -- they are autoapproved. The workflow will continue to
    -- the auto-approve step.
    p_resultout := gc_wf_no;
  WHEN OTHERS
   THEN
    -- Exception occurred. By default, PM approval is needed.
    p_resultout := gc_wf_yes;
    flog(lc_proc_name, 'exception: ' || SQLCODE || ' - ' || SQLERRM);
END approval_needed;

/****************************************************************
 * PROCEDURE     : approve_timecards
 * DESCRIPTION   : For timecards older than a specific date and the
 *                 approver a specific projectmanager, autoapprove the
 *                 still un-approved timecards.
 * PARAMETERS    : p_errbuf       : error buffer for concurrent program
 *                 p_retcode      : return code for concurrent program
 *                 p_pm_person_id : project manager person id
 *                 p_from_date    : date from which older timecards are to
 *                                  be autoapproved
 ****************************************************************/
PROCEDURE approve_timecards
( p_errbuf         IN OUT VARCHAR2  -- OUTPUT LOG
, p_retcode        IN OUT VARCHAR2  -- 0=SUCCESS, 1=WARNING, 2=ERROR
, p_pm_person_id   IN NUMBER
, p_from_date      IN VARCHAR2
)
IS
  CURSOR c_item_keys
  ( b_pm_person_id IN NUMBER
  , b_from_date    IN DATE
  )
  IS
  select wf.item_key
  ,      app_start_date.date_value timecard_start_date
  ,      app_end_date.date_value   timecard_end_date
  ,      owner.text_value          timecard_owner
  ,      resource_id.number_value  approver_person_id
  ,      pep.full_name             approver_full_name
  ,      tcsum.approval_status
  from   wf_items                  wf
  ,      wf_item_attribute_values  app_start_date
  ,      wf_item_attribute_values  app_end_date
  ,      wf_item_attribute_values  resource_id
  ,      wf_item_attribute_values  owner
  ,      wf_item_attribute_values  tc_bb_id
  ,      wf_item_attribute_values  tc_bb_ovn
  ,      per_all_people_f          pep
  ,      hxc_timecard_summary      tcsum
  where  wf.item_type = 'HXCEMP'
  and    wf.root_activity = 'HXC_APPLY_NOTIFY'
  and    app_start_date.item_type = wf.item_type
  and    app_start_date.item_key = wf.item_key
  and    app_start_date.name = 'APP_START_DATE'
  and    app_end_date.item_type = wf.item_type
  and    app_end_date.item_key = wf.item_key
  and    app_end_date.name = 'APP_END_DATE'
  and    resource_id.item_type = wf.item_type
  and    resource_id.item_key = wf.item_key
  and    resource_id.name = 'APR_PERSON_ID'
  and    owner.item_type = wf.item_type
  and    owner.item_key = wf.item_key
  and    owner.name = 'TC_FROM_ROLE'
  and    tc_bb_id.item_type = wf.item_type
  and    tc_bb_id.item_key = wf.item_key
  and    tc_bb_id.name = 'TC_BLD_BLK_ID'
  and    tc_bb_ovn.item_type = wf.item_type
  and    tc_bb_ovn.item_key = wf.item_key
  and    tc_bb_ovn.name = 'TC_BLD_BLK_OVN'
  and    tc_bb_id.number_value = tcsum.timecard_id
  and    tc_bb_ovn.number_value = tcsum.timecard_ovn
  and    tcsum.approval_status = 'SUBMITTED'
  and    pep.person_id = resource_id.number_value
  and    trunc(sysdate) between pep.effective_start_date and nvl(pep.effective_end_date, SYSDATE+1)
  -- only when workflow still running
  and    wf_fwkmon.getitemstatus('HXCEMP', wf.item_key, wf.end_date, wf.root_activity, wf.root_activity_version) = 'ACTIVE'
  -- parameters
  and    resource_id.number_value = nvl(b_pm_person_id, resource_id.number_value)
  and    app_start_date.date_value <= nvl(b_from_date, app_start_date.date_value)
  ;

  l_counter       NUMBER;
  l_pm_full_name  per_all_people_f.full_name%TYPE;
  l_from_date     DATE;

BEGIN

  IF p_pm_person_id IS NOT NULL
  THEN
    SELECT full_name
    INTO   l_pm_full_name
    FROM   per_all_people_f
    WHERE  person_id = p_pm_person_id
    AND    TRUNC(SYSDATE) BETWEEN effective_start_date AND NVL(effective_end_date, SYSDATE+1)
    ;
  END IF;

  IF p_from_date IS NOT NULL
  THEN
    l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  fnd_file.put_line(fnd_file.output, 'XXAH: Timesheet Approval Concurrent Program');
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, 'Started at: ' || to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, 'Parameters:');
  fnd_file.put_line(fnd_file.output, '---------------------------------------');
  IF l_from_date IS NULL
  THEN
    fnd_file.put_line(fnd_file.output, 'Timecards older than: ' || 'All');
  ELSE
    fnd_file.put_line(fnd_file.output, 'Timecards older than: ' || to_char(l_from_date,'DD-MON-YYYY'));
  END IF;
  fnd_file.put_line(fnd_file.output, 'Projectmanager      : ' || NVL(l_pm_full_name, 'All'));
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, 'Autoapproved the following timecards.');
  fnd_file.put_line(fnd_file.output, ' ');

  fnd_file.put_line(fnd_file.output,RPAD('Owner User' , 25, ' ')
                             ||' '||RPAD('Start Date' , 12, ' ')
                             ||' '||RPAD('End Date' , 12, ' ')
                             ||' '||RPAD('Approver'   , 25, ' '));

  fnd_file.put_line(fnd_file.output,RPAD('-' , 25, '-')
                             ||' '||RPAD('-' , 12, '-')
                             ||' '||RPAD('-' , 12, '-')
                             ||' '||RPAD('-' , 25, '-'));

  l_counter := 0;

  FOR r_item_key IN c_item_keys(p_pm_person_id, l_from_date)
  LOOP
    l_counter := l_counter + 1;

    -- Auto approve the timecard
    WF_ENGINE.COMPLETEACTIVITY
    ( 'HXCEMP'
    , r_item_key.item_key
    , 'TC_APR_NOTIFICATION'
    , 'APPROVED'
    );

    fnd_file.put_line(fnd_file.output,RPAD(r_item_key.timecard_owner , 25, ' ')
                               ||' '||RPAD(r_item_key.timecard_start_date , 12, ' ')
                               ||' '||RPAD(r_item_key.timecard_end_date , 12, ' ')
                               ||' '||RPAD(r_item_key.approver_full_name , 25, ' '));

  END LOOP;

  IF l_counter = 0
  THEN
    fnd_file.put_line(fnd_file.output,'No timecards autoapproved');
  END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    p_retcode := 2;
    p_errbuf  := SQLERRM;

END approve_timecards;

END XXAH_HXC_APPROVAL_PKG;

/
