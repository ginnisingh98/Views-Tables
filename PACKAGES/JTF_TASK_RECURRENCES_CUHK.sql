--------------------------------------------------------
--  DDL for Package JTF_TASK_RECURRENCES_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RECURRENCES_CUHK" AUTHID CURRENT_USER AS
/* $Header: jtfctkus.pls 115.6 2002/12/05 23:31:14 sachoudh ship $ */
   g_pkg_name             VARCHAR2(30) := 'JTF_TASK_RECURRENCES_PUB';

   creating_recurrences   BOOLEAN      := FALSE;

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
