--------------------------------------------------------
--  DDL for Package JTF_TASK_WF_SUBSCRIBE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_WF_SUBSCRIBE_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftkwks.pls 115.1 2004/02/05 02:52:09 sachoudh noship $ */
   FUNCTION create_task_notif_subs (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
      )
      RETURN VARCHAR2;

   FUNCTION update_task_notif_subs (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
      )
      RETURN VARCHAR2;

   FUNCTION delete_task_notif_subs (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
      )
      RETURN VARCHAR2;

   FUNCTION create_assg_notif_subs (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
      )
      RETURN VARCHAR2;

   FUNCTION update_assg_notif_subs (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
      )
      RETURN VARCHAR2;

   FUNCTION delete_assg_notif_subs (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
      )
      RETURN VARCHAR2;

   FUNCTION compare_old_new_param (
      p_new_param   IN   VARCHAR2,
      p_old_param   IN   VARCHAR2
      )
      RETURN BOOLEAN;

   FUNCTION compare_old_new_param (
      p_new_param   IN   NUMBER,
      p_old_param   IN   NUMBER
      )
      RETURN BOOLEAN;

   FUNCTION compare_old_new_param (p_new_param IN DATE, p_old_param IN DATE)
      RETURN BOOLEAN;
END;

 

/
