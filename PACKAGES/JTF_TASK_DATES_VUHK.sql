--------------------------------------------------------
--  DDL for Package JTF_TASK_DATES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_DATES_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtfttkds.pls 115.4 2002/12/04 23:42:26 cjang ship $ */



   PROCEDURE create_task_dates_pre (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
      x_return_status    OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_task_dates_post (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
      x_return_status    OUT NOCOPY      VARCHAR2
   );

    PROCEDURE update_task_dates_pre (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE update_task_dates_post (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    );

 PROCEDURE delete_task_dates_pre (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_task_dates_post (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

END;

 

/
