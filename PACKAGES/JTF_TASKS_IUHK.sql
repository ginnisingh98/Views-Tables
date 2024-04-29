--------------------------------------------------------
--  DDL for Package JTF_TASKS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASKS_IUHK" AUTHID CURRENT_USER AS
/* $Header: jtfitkts.pls 115.6 2002/11/13 19:13:24 cjang ship $ */


    G_PKG_NAME      CONSTANT        VARCHAR2(30):='JTF_TASKS_IUHK';

    PROCEDURE create_task_pre (
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE create_task_post (
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE update_task_pre (
       x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE update_task_post (
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE delete_task_pre (
        x_return_status           OUT NOCOPY      VARCHAR2
    );

    PROCEDURE delete_task_post (
        x_return_status           OUT NOCOPY      VARCHAR2
    );



END;

 

/
