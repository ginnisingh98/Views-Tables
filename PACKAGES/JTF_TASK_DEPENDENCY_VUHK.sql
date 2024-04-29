--------------------------------------------------------
--  DDL for Package JTF_TASK_DEPENDENCY_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_DEPENDENCY_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtfttkes.pls 115.4 2002/12/04 23:43:51 cjang ship $ */

    PROCEDURE create_task_dependency_pre (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status              OUT NOCOPY      VARCHAR2
    );

    PROCEDURE create_task_dependency_post (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status              OUT NOCOPY      VARCHAR2
    );

    PROCEDURE update_task_dependency_pre (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status              OUT NOCOPY      VARCHAR2
    );

    PROCEDURE update_task_dependency_post (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status              OUT NOCOPY      VARCHAR2
    );



    PROCEDURE delete_task_dependency_pre (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status   OUT NOCOPY      VARCHAR2
    );

    PROCEDURE delete_task_dependency_post (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status   OUT NOCOPY      VARCHAR2
    );
END;

 

/
