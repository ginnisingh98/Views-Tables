--------------------------------------------------------
--  DDL for Package JTF_TASK_PHONES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_PHONES_IUHK" AUTHID CURRENT_USER AS
/* $Header: jtfitkps.pls 115.6 2002/12/05 23:49:45 sachoudh ship $ */
   PROCEDURE create_task_phones_pre (
      p_task_phones_rec   IN       jtf_task_phones_pub.task_phones_rec,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_task_phones_post (
      p_task_phones_rec   IN       jtf_task_phones_pub.task_phones_rec,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_task_phones_pre (
      p_task_phones_rec   IN       jtf_task_phones_pub.task_phones_rec,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_task_phones_post (
      p_task_phones_rec   IN       jtf_task_phones_pub.task_phones_rec,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_task_phones_pre (
      p_task_phones_rec   IN       jtf_task_phones_pub.task_phones_rec,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_task_phones_post (
      p_task_phones_rec   IN       jtf_task_phones_pub.task_phones_rec,
      x_return_status     OUT NOCOPY      VARCHAR2
   );
END;

 

/
