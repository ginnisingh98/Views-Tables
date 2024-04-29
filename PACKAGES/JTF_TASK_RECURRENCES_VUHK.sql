--------------------------------------------------------
--  DDL for Package JTF_TASK_RECURRENCES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RECURRENCES_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtfttkus.pls 115.4 2002/12/04 23:56:45 cjang ship $ */

PROCEDURE create_task_recurrence_pre (
      p_task_recurrence_rec     in       jtf_task_recurrences_pub.task_recurrence_rec,
      x_return_status           OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_task_recurrence_post (
      p_task_recurrence_rec     in       jtf_task_recurrences_pub.task_recurrence_rec,
      x_return_status           OUT NOCOPY     VARCHAR2
   );


END;

 

/
