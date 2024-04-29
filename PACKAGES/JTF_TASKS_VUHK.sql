--------------------------------------------------------
--  DDL for Package JTF_TASKS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASKS_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtfttkts.pls 115.5 2002/12/04 23:55:06 cjang ship $ */


    G_PKG_NAME      CONSTANT        VARCHAR2(30):='JTF_TASKS_CUHK';

    PROCEDURE create_task_pre (
        p_task_rec                in       jtf_tasks_pub.task_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE create_task_post (
        p_task_rec                in       jtf_tasks_pub.task_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE update_task_pre (
        p_task_rec                in       jtf_tasks_pub.task_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE update_task_post (
        p_task_rec                in       jtf_tasks_pub.task_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE delete_task_pre (
        p_task_rec                in       jtf_tasks_pub.task_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE delete_task_post (
        p_task_rec                in       jtf_tasks_pub.task_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    );



END;

 

/
