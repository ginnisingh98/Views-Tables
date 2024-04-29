--------------------------------------------------------
--  DDL for Package PER_CKL_FYI_NOTIFICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CKL_FYI_NOTIFICATIONS" AUTHID CURRENT_USER AS
   -- $Header: pecklnot.pkh 120.4 2006/10/20 07:26:15 sturlapa noship $
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
                             );
   --
   -- Check which notification to send
   --
   PROCEDURE which_notification(itemtype  IN VARCHAR2
                               ,itemkey   IN VARCHAR2
                               ,actid     IN NUMBER
                               ,funcmode  IN VARCHAR2
                               ,resultout OUT NOCOPY VARCHAR2
                               );
   --
END per_ckl_fyi_notifications;

 

/
