--------------------------------------------------------
--  DDL for Package Body JTF_TASK_ASSIGNMENTS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_ASSIGNMENTS_IUHK" AS
/* $Header: jtfitkab.pls 115.6 2002/11/13 20:09:04 cjang ship $ */

   PROCEDURE create_task_assignment_pre (
      x_return_status                OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        jtf_task_utl.call_internal_hook( 'JTF_TASK_ASSIGNMENTS_PUB' , 'CREATE_TASK_ASSIGNMENT' , 'B' , x_return_status );
    END ;

   PROCEDURE create_task_assignment_post (
      x_return_status                OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        jtf_task_utl.call_internal_hook( 'JTF_TASK_ASSIGNMENTS_PUB' , 'CREATE_TASK_ASSIGNMENT' , 'A' , x_return_status );
    END ;


   PROCEDURE delete_task_assignment_pre (
      x_return_status                OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        jtf_task_utl.call_internal_hook( 'JTF_TASK_ASSIGNMENTS_PUB' , 'DELETE_TASK_ASSIGNMENT' , 'B' , x_return_status );
    END ;

   PROCEDURE delete_task_assignment_post (
      x_return_status                OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        jtf_task_utl.call_internal_hook( 'JTF_TASK_ASSIGNMENTS_PUB' , 'DELETE_TASK_ASSIGNMENT' , 'A' , x_return_status );
    END ;

   PROCEDURE update_task_assignment_pre (
      x_return_status                OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        jtf_task_utl.call_internal_hook( 'JTF_TASK_ASSIGNMENTS_PUB' , 'UPDATE_TASK_ASSIGNMENT' , 'B' , x_return_status );
    END ;

   PROCEDURE update_task_assignment_post (
      x_return_status                OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        jtf_task_utl.call_internal_hook( 'JTF_TASK_ASSIGNMENTS_PUB' , 'UPDATE_TASK_ASSIGNMENT' , 'A' , x_return_status );
    END ;


END;

/
