--------------------------------------------------------
--  DDL for Package JTF_TASK_RECURRENCES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RECURRENCES_IUHK" AUTHID CURRENT_USER AS
/* $Header: jtfitkus.pls 115.6 2002/12/05 23:50:32 sachoudh ship $ */

 PROCEDURE create_task_recurrence_pre (
      p_task_recurrence_rec     in       jtf_task_recurrences_pub.task_recurrence_rec,
      x_return_status           OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_task_recurrence_post (
      p_task_recurrence_rec     in       jtf_task_recurrences_pub.task_recurrence_rec,
      x_return_status           OUT NOCOPY      VARCHAR2
   );

END;

 

/
