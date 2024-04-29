--------------------------------------------------------
--  DDL for Package Body CN_CW_WORKBENCH_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CW_WORKBENCH_UTILITY" AS
-- $Header: cnvcwutb.pls 120.1 2005/08/08 03:17 raramasa noship $

g_package  VARCHAR2(33)  := '   cn_workbench_utility.';


function get_go_to_task_image_name(p_org_id  in number)
  return varchar2 IS

  l_setup_task_status       varchar2(60);
  l_complete                varchar2(1):= 'N';
  l_image                   varchar2(200);

  CURSOR cn_setup_task_status (p_org_id number) IS
  SELECT setup_task_status
  FROM   CN_CW_SETUP_TASKS_VL
  where org_id=p_org_id and workbench_item_code='APPLICATION_PARAMETERS' and
  setup_task_code in('GENERAL_SETTINGS','GENERAL_LEDGER_SETTINGS');

  BEGIN
     FOR cn_task_status IN cn_setup_task_status(p_org_id)
     LOOP
     l_setup_task_status := NVL(cn_task_status.setup_task_status,'NOT_APPLICABLE') ;
     if l_setup_task_status = 'COMPLETED'  then
	l_complete := 'Y';
     else
	l_complete := 'N';
	exit;
     end if;
     end loop;

     if l_complete='Y' then
	     l_image := '/OA_MEDIA/takeaction_enabled.gif';
     else
       	     l_image := '/OA_MEDIA/takeaction_disabled.gif';
     end if;
     return l_image;



  exception
      when others then
      fnd_message.raise_error;
  end;

--------------------------------------------------------------------
  -- This function returns the required image location for the workbench
  -- items
--------------------------------------------------------------------

  function get_required_field (p_workbench_item_code  in   varchar2)
  return varchar2 is
  required_image varchar2(200);
  begin
	  if(p_workbench_item_code ='APPLICATION_PARAMETERS' or p_workbench_item_code='COLLECTION_CALC_TABLE_MAPPINGS' or
	  p_workbench_item_code='CALCULATION' or p_workbench_item_code='GENERAL_LEDGER' or
	  p_workbench_item_code='PROFILE' or p_workbench_item_code='CREATE_MAINTAIN_USERS' or
	  p_workbench_item_code='CREATE_MAINTAIN_RESOURCES' ) then
		  required_image:='/OA_MEDIA/requiredicon_status.gif';
		  return required_image;
	  else
	          return null;
	  end if;
  end;


  --------------------------------------------------------------------
  -- This function returns to status of the workbench items based upon the
  -- status of the tasks of the workbench items.
  --
  -- If any task is 'In Progress' then the main status will also be
  -- In Progress'.
  -- If any task is 'Complete' and no task is 'In Progress' then the
  -- main status will be 'Complete'.
  -- If all tasks are 'Not Applicable' then the main status will also
  -- be 'Not Applicable'.
  -- If all tasks are 'Not Started' then the main status will also
  -- be 'Not Started'
  --
  --------------------------------------------------------------------
  FUNCTION get_item_status_name (p_workbench_item_code  in   varchar2,
                                      p_org_id  in varchar2)
  return varchar2 IS

  CURSOR csr_setup_task_status (p_workbench_item_code varchar2,
                                p_org_id number) IS
  SELECT setup_task_status
  FROM   CN_CW_SETUP_TASKS_VL
  WHERE  workbench_item_code = p_workbench_item_code and org_id =p_org_id
  ORDER BY setup_task_status;

  l_proc                varchar2(72) := g_package || 'get_item_status_name';
  l_setup_task_status   varchar2(60);
  l_workbench_item_status varchar2(60);
  l_workbench_item_status_image varchar2(60);

  l_complete         varchar2(1):= 'N';
  l_in_progress      varchar2(1):= 'N';
  l_not_started      varchar2(1):= 'N';
  l_not_applicable   varchar2(1):= 'N';

  BEGIN

    --------------------------------------------------------------------
    -- If any task is 'In Progress' then the main status will also be
    -- In Progress'.
    -- If any task is 'Complete' and no task is 'In Progress' then the
    -- main status will be 'Complete'.
    -- If all tasks are 'Not Applicable' then the main status will also
    -- be 'Not Applicable'.
    -- If all tasks are 'Not Started' then the main status will also
    -- be 'No activity'
     --------------------------------------------------------------------

        FOR l_rec in csr_setup_task_status(p_workbench_item_code,
                                           p_org_id)
        LOOP
          l_setup_task_status := nvl(l_rec.setup_task_status,'NOTAPPLICABLE');
          if l_setup_task_status = 'COMPLETED' then
             l_complete := 'Y';
          elsif l_setup_task_status = 'INPROGRESS' then
             l_in_progress := 'Y';
	     exit;
          elsif l_setup_task_status = 'NOTSTARTED' then
             l_not_started := 'Y';
          elsif l_setup_task_status = 'NOTAPPLICABLE' then
             l_not_applicable := 'Y';
          else
            l_not_applicable := 'Y';
          end if;
        END LOOP;

        if (l_complete = 'Y' and
            l_in_progress = 'N' and
            l_not_started = 'N') then
            l_workbench_item_status_image := '/OA_MEDIA/completeind_status.gif';

	elsif (l_complete = 'N' and
            l_in_progress = 'N' and
            l_not_started = 'Y') then
            l_workbench_item_status_image := '/OA_MEDIA/notstartedind_status.gif';

	elsif (l_complete = 'N' and
             l_in_progress = 'N' and
             l_not_started = 'N') then
            l_workbench_item_status_image := '/OA_MEDIA/notapplicableind_status.gif';

	elsif (l_complete = 'Y' and
               l_not_started = 'Y') then
            l_workbench_item_status_image := '/OA_MEDIA/inprogressind_status.gif';

	elsif (l_in_progress = 'Y') then
            l_workbench_item_status_image := '/OA_MEDIA/inprogressind_status.gif';

	else
            l_workbench_item_status_image := '/OA_MEDIA/notapplicableind_status.gif';

    end if;

    return l_workbench_item_status_image;

    exception
    when others then
    fnd_message.raise_error;
  end;



END cn_cw_workbench_utility;

/
