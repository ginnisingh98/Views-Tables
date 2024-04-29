--------------------------------------------------------
--  DDL for Package JTF_TASK_ASSIGNMENTS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_ASSIGNMENTS_IUHK" AUTHID CURRENT_USER AS
/* $Header: jtfitkas.pls 115.6 2002/11/13 20:08:36 cjang ship $ */



   g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_TASK_ASSIGNMENT_IUHK';



   PROCEDURE create_task_assignment_pre (
      x_return_status                OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_task_assignment_post (
      x_return_status                OUT NOCOPY      VARCHAR2
   );


   PROCEDURE delete_task_assignment_pre (
      x_return_status                OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_task_assignment_post (
      x_return_status                OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_task_assignment_pre (
      x_return_status                OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_task_assignment_post (
      x_return_status                OUT NOCOPY      VARCHAR2
   );


END;

 

/
