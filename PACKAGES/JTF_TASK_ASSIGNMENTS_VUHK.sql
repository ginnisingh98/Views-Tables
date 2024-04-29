--------------------------------------------------------
--  DDL for Package JTF_TASK_ASSIGNMENTS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_ASSIGNMENTS_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtfttkas.pls 115.5 2002/12/04 23:40:34 cjang ship $ */



   g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_TASK_ASSIGNMENT_VUHK';



   PROCEDURE create_task_assignment_pre (
      p_task_assignment_rec          IN       jtf_task_assignments_pub.task_assignments_rec,
      x_return_status                OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_task_assignment_post (
      p_task_assignment_rec          IN       jtf_task_assignments_pub.task_assignments_rec,
      x_return_status                OUT NOCOPY      VARCHAR2
   );


   PROCEDURE delete_task_assignment_pre (
      p_task_assignment_rec          IN       jtf_task_assignments_pub.task_assignments_rec,
      x_return_status                OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_task_assignment_post (
      p_task_assignment_rec          IN       jtf_task_assignments_pub.task_assignments_rec,
      x_return_status                OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_task_assignment_pre (
      p_task_assignment_rec          IN       jtf_task_assignments_pub.task_assignments_rec,
      x_return_status                OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_task_assignment_post (
      p_task_assignment_rec          IN       jtf_task_assignments_pub.task_assignments_rec,
      x_return_status                OUT NOCOPY      VARCHAR2
   );


END;

 

/
