--------------------------------------------------------
--  DDL for Package Body PER_CKL_FYI_NOTIFICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CKL_FYI_NOTIFICATIONS" AS
  -- $Header: pecklnot.pkb 120.5 2006/10/19 13:24:46 sturlapa noship $
  --
  -- Spawn the FYI notification workflow
  --
  PROCEDURE start_wf_process(p_task_id            IN NUMBER
                            ,p_task_name          IN VARCHAR2
                            ,p_checklist_name     IN VARCHAR2
                            ,p_task_status        IN VARCHAR2
                            ,p_owner_name         IN VARCHAR2
                            ,p_performer_name     IN VARCHAR2
                            ,p_recipient          IN VARCHAR2
                            ,p_recipient_name     IN VARCHAR2
                            ,p_mandatory_flag     IN VARCHAR2
                            ,p_target_start_date  IN DATE
                            ,p_target_end_date    IN DATE
                            ,p_actual_start_date  IN DATE
                            ,p_actual_end_date    IN DATE
                            ,p_which_notification IN VARCHAR2
		            ,p_allocated_to       IN VARCHAR2
                            ) IS
    --
    l_proc      VARCHAR2(50);
    l_item_type VARCHAR2(8);
    l_item_key  VARCHAR2(240);
    l_process   VARCHAR2(30);
    l_user_key  VARCHAR2(240);
    --
    varname  Wf_Engine.NameTabTyp;
    varvalue Wf_Engine.TextTabTyp;
    numname  Wf_Engine.NameTabTyp;
    numvalue Wf_Engine.NumTabTyp;
    --
  BEGIN
    l_proc:= 'per_ckl_fyi_notifications.start_wf_process';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    --
    l_item_type := 'HRCKLFYI';
    l_item_key := 'ChecklistTask:'||p_task_id||':'||CURRENT_TIMESTAMP;
    l_process := 'CHECKLISTNOTIFIERPROCESS';
    l_user_key := l_item_key;
    --
    -- Initiate workflow process
    --
    Wf_Engine.CreateProcess(ItemType   => l_item_type
                           ,ItemKey    => l_item_key
                           ,Process    => l_process
                           ,User_Key   => l_user_key
                           ,Owner_Role => 'COREHR'
                           );
    --
    -- Set text item attributes
    --
    varname(1)  := 'TASK_NAME';
    varvalue(1) := p_task_name;
    varname(2)  := 'CHECKLIST_NAME';
    varvalue(2) := p_checklist_name;
    varname(3)  := 'TASK_STATUS';
    varvalue(3) := p_task_status;
    varname(4)  := 'OWNER';
    varvalue(4) := p_owner_name;
    varname(5)  := 'PERFORMER';
    varvalue(5) := p_performer_name;
    varname(6)  := 'MANDATORY';
    varvalue(6) := p_mandatory_flag;
    varname(7)  := 'RECIPIENT';
    varvalue(7) := p_recipient;
    varname(8)  := 'RECIPIENT_NAME';
    varvalue(8) := p_recipient_name;
    varname(9)  := 'WHICH_NOTIFICATION';
    varvalue(9) := p_which_notification;
    varname(10)  := 'ALLOCATED_TO';
    varvalue(10) := p_allocated_to;

    Wf_Engine.SetItemAttrTextArray(l_item_type
                                  ,l_item_key
                                  ,varname
                                  ,varvalue
                                  );
    --
    -- Set number item attributes
    --
    NULL;
    --
    -- Set date item attributes
    --
    Wf_Engine.SetItemAttrDate(itemtype => l_item_type
                             ,itemkey  => l_item_key
                             ,aname    => 'TARGET_START_DATE'
                             ,avalue   => p_target_start_date
                             );
    Wf_Engine.SetItemAttrDate(itemtype => l_item_type
                             ,itemkey  => l_item_key
                             ,aname    => 'TARGET_END_DATE'
                             ,avalue   => p_target_end_date
                             );
    Wf_Engine.SetItemAttrDate(itemtype => l_item_type
                             ,itemkey  => l_item_key
                             ,aname    => 'ACTUAL_START_DATE'
                             ,avalue   => p_actual_start_date
                             );
    Wf_Engine.SetItemAttrDate(itemtype => l_item_type
                             ,itemkey  => l_item_key
                             ,aname    => 'ACTUAL_END_DATE'
                             ,avalue   => p_actual_end_date
                             );
    --
    -- Start workflow process
    --
    Wf_Engine.StartProcess(ItemType => l_item_type
                          ,ItemKey  => l_item_key
                          );
    --
    COMMIT;
    --
    hr_utility.set_location('Leaving: '|| l_proc, 20);
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      hr_utility.set_location('Leaving: '|| l_proc, 30);
      hr_utility.set_location(SQLERRM, 35);
      RAISE;
  END start_wf_process;
  --
  PROCEDURE which_notification(itemtype  IN VARCHAR2
                              ,itemkey   IN VARCHAR2
                              ,actid     IN NUMBER
                              ,funcmode  IN VARCHAR2
                              ,resultout OUT NOCOPY VARCHAR2
                              ) IS
    --
    l_proc VARCHAR2(50);
    --
  BEGIN
    l_proc:= 'per_ckl_fyi_notifications.which_notification';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    --
    IF funcmode = 'RUN' THEN
      resultout := Wf_Engine.GetItemAttrText(itemtype => itemtype
                                            ,itemkey  => itemkey
                                            ,aname    => 'WHICH_NOTIFICATION'
                                            ,ignore_notfound => FALSE
                                            );
    END IF;
    --
    hr_utility.set_location('Leaving: '|| l_proc, 20);
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      hr_utility.set_location('Leaving: '|| l_proc, 30);
      hr_utility.set_location(SQLERRM, 35);
      RAISE;
  END which_notification;
  --
END per_ckl_fyi_notifications;

/
