--------------------------------------------------------
--  DDL for Package Body PER_RI_WORKBENCH_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_WORKBENCH_UTILITY" as
/* $Header: perriwbu.pkb 120.0.12010000.2 2008/11/28 15:19:09 sbrahmad ship $ */

g_package  VARCHAR2(33)  := '   per_ri_workbench_utility.';

  --------------------------------------------------------------------
  -- This function returns to image name for the workbench_items which are
  --  FUNCTIONAL_AREA
  --------------------------------------------------------------------

FUNCTION get_go_to_task_image_name(p_workbench_item_code  in   varchar2,
                                   p_workbench_item_type  in varchar2)
  return varchar2 IS

  l_proc              varchar2(72) := g_package || 'get_wb_item_status';
  l_setu_task_status       varchar2(60);

  BEGIN
    hr_utility.set_location('Entering:'  || l_proc,10);

     if p_workbench_item_type = 'FUNCTIONAL_AREA' then
         return '/OA_MEDIA/takeaction_enabled.gif';
     else
        return NULL;
     end if;
    hr_utility.set_location('Leaving:'  || l_proc,20);

  EXCEPTION
    when others then
      hr_utility.set_location(l_proc,30);
      fnd_message.raise_error;
  END;

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
                                      p_workbench_item_type  in varchar2)
  return varchar2 IS

  CURSOR csr_setup_task_status (p_workbench_item_code varchar2,
                                p_workbench_item_type varchar2) IS
  SELECT DISTINCT setup_task_status
  FROM   per_ri_setup_tasks
  WHERE  workbench_item_code = p_workbench_item_code
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
    hr_utility.set_location('Entering:'  || l_proc,10);

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
    if p_workbench_item_type = 'FUNCTIONAL_AREA' then

        -- loop for all rows returned for SQL statement
        FOR l_rec in csr_setup_task_status(p_workbench_item_code,
                                           p_workbench_item_type)
        LOOP
          l_setup_task_status := nvl(l_rec.setup_task_status,'NOT_APPLICABLE');
          if l_setup_task_status = 'COMPLETE' then
             l_complete := 'Y';
          elsif l_setup_task_status = 'IN_PROGRESS' then
             l_in_progress := 'Y';
          elsif l_setup_task_status = 'NOT_STARTED' then
             l_not_started := 'Y';
          elsif l_setup_task_status = 'NOT_APPLICABLE' then
             l_not_applicable := 'Y';
          else
            l_not_applicable := 'Y';
          end if;
        END LOOP;
        if (l_complete = 'Y' and
            l_in_progress = 'N' and
            l_not_started = 'N' and
            (l_not_applicable = 'N' OR l_not_applicable = 'Y')) then
            l_workbench_item_status_image := '/OA_MEDIA/completeind_status.gif';
        elsif (l_complete = 'N' and
            l_in_progress = 'Y' and
            l_not_started = 'N' and
            (l_not_applicable = 'N' OR l_not_applicable = 'Y')) then
            l_workbench_item_status_image := '/OA_MEDIA/inprogressind_status.gif';
        elsif (l_complete = 'N' and
            l_in_progress = 'N' and
            l_not_started = 'Y' and
            (l_not_applicable = 'N' OR l_not_applicable = 'Y')) then
            l_workbench_item_status_image := '/OA_MEDIA/notstartedind_status.gif';
        elsif (l_complete = 'N' and
             l_in_progress = 'N' and
             l_not_started = 'N' and
             (l_not_applicable = 'N' OR l_not_applicable = 'Y')) then
            l_workbench_item_status_image := '/OA_MEDIA/notapplicableind_status.gif';
        -- If any task is 'In Progress' then the main status
        -- will also be 'In Progress'
        elsif (l_in_progress = 'Y' and
              (l_in_progress = 'N'   OR l_in_progress = 'Y') and
              (l_not_started = 'N'   OR l_not_started = 'Y') and
              (l_not_applicable = 'N'OR l_not_applicable = 'Y')) then
            l_workbench_item_status_image := '/OA_MEDIA/inprogressind_status.gif';
        elsif (l_complete = 'Y' and
               l_in_progress = 'Y' and
               (l_not_applicable = 'N' OR l_not_applicable = 'Y')) then
            l_workbench_item_status_image := '/OA_MEDIA/inprogressind_status.gif';
        elsif (l_complete = 'Y' and
               l_not_started = 'Y') then
            l_workbench_item_status_image := '/OA_MEDIA/inprogressind_status.gif';
        else
            l_workbench_item_status_image := '/OA_MEDIA/notapplicableind_status.gif';

       end if;
       hr_utility.set_location('Leaving:'  || l_proc,20);
       return l_workbench_item_status_image;
    else
       hr_utility.set_location('Leaving:'  || l_proc,30);
       return null;
    end if;
    EXCEPTION
    when others then
      hr_utility.set_location(l_proc,40);
      fnd_message.raise_error;
  END;

function get_item_notes_image (p_workbench_item_code  in   varchar2
                               ,p_workbench_item_type in varchar2)
  return varchar2 IS

  l_proc              varchar2(72) := g_package || 'get_wb_item_status';
  l_item_status       varchar2(60);

  BEGIN
    hr_utility.set_location('Entering:'  || l_proc,10);

     if p_workbench_item_type = 'FUNCTIONAL_AREA' then
        return '/OA_MEDIA/attachments_toggleattach.gif';
     else
        return NULL;
     end if;
  EXCEPTION
    when others then
      hr_utility.set_location(l_proc,30);
      fnd_message.raise_error;
  END get_item_notes_image;

----

function get_item_last_modified_date (p_workbench_item_code in   varchar2)
  return varchar2 IS

  CURSOR csr_modified_date (p_workbench_item_code varchar2) IS
  SELECT max(setup_task_last_modified_date)
  FROM   per_ri_setup_tasks
  WHERE  workbench_item_code = p_workbench_item_code;

  l_proc            varchar2(72) := g_package || 'get_item_last_modified_date';
  l_item_last_modified_date  varchar2(60);

  BEGIN
    hr_utility.set_location('Entering:'  || l_proc,10);

    open csr_modified_date(p_workbench_item_code);
    fetch csr_modified_date into l_item_last_modified_date;
    close csr_modified_date;
    if  l_item_last_modified_date is null then
        return null;
    else
       return l_item_last_modified_date;
    end if;
  END get_item_last_modified_date;
----

 --------------------------------------------------------------------------
 -- This function checks whether the function name passed is
 -- attached to the current responsibility
 -- The function expects either 'Per_Ri_Workbench_Items.WorkbenchItemCode'
 -- or 'Per_RI_Setup_tasks.Setup_task_code' as function name and
 -- item type (whether Workbench Item or Setup Task Item) as inputs
 --------------------------------------------------------------------------


function workbench_task_access_exist(fname varchar2,itemType number) return number is
  function_name varchar2(100);
  function_present boolean;
begin
  function_name := fname;
  if itemType = 1 then
  function_name := 'W_' || fname ;
  else
  function_name := 'S_' || fname ;
  end if;

  function_present := fnd_function.test(function_name , 'N');
  if function_present then
  return 1;
  else
  return 0;
  end if;
end workbench_task_access_exist;


END per_ri_workbench_utility;


/
