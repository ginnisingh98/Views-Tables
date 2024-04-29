--------------------------------------------------------
--  DDL for Package JTF_TASKS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASKS_CUHK" AUTHID CURRENT_USER AS
/* $Header: jtfctkts.pls 115.7 2002/12/05 23:31:01 sachoudh ship $ */


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
