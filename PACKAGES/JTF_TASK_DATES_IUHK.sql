--------------------------------------------------------
--  DDL for Package JTF_TASK_DATES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_DATES_IUHK" AUTHID CURRENT_USER AS
/* $Header: jtfitkds.pls 115.6 2002/12/05 23:47:35 sachoudh ship $ */



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
