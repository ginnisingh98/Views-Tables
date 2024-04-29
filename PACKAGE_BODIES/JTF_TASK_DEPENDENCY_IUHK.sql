--------------------------------------------------------
--  DDL for Package Body JTF_TASK_DEPENDENCY_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_DEPENDENCY_IUHK" AS
/* $Header: jtfitkeb.pls 115.6 2002/12/05 23:47:57 sachoudh ship $ */

    PROCEDURE create_task_dependency_pre (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status              OUT NOCOPY      VARCHAR2
    )    is
    BEGIN
        null;
    END ;

    PROCEDURE create_task_dependency_post (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status              OUT NOCOPY      VARCHAR2
    )    is
    BEGIN
        null;
    END ;

    PROCEDURE update_task_dependency_pre (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status              OUT NOCOPY      VARCHAR2
    )    is
    BEGIN
        null;
    END ;

    PROCEDURE update_task_dependency_post (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status              OUT NOCOPY      VARCHAR2
    )    is
    BEGIN
        null;
    END ;



    PROCEDURE delete_task_dependency_pre (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status   OUT NOCOPY      VARCHAR2
    )    is
    BEGIN
        null;
    END ;

    PROCEDURE delete_task_dependency_post (
        p_task_dependency            in  jtf_task_dependency_pub.task_dependency_rec,
        x_return_status   OUT NOCOPY      VARCHAR2
    ) is
    BEGIN
        null;
    END ;
END;

/
