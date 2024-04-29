--------------------------------------------------------
--  DDL for Package JTF_TASK_DEPENDENCY_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_DEPENDENCY_IUHK" AUTHID CURRENT_USER AS
/* $Header: jtfitkes.pls 115.6 2002/12/05 23:48:15 sachoudh ship $ */

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
