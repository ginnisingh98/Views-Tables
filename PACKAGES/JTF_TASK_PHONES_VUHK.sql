--------------------------------------------------------
--  DDL for Package JTF_TASK_PHONES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_PHONES_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtfttkps.pls 115.4 2002/12/04 23:51:11 cjang ship $ */
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
