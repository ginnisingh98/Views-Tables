--------------------------------------------------------
--  DDL for Package JTF_TASK_ASSIGNMENTS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_ASSIGNMENTS_CUHK" AUTHID CURRENT_USER AS
/* $Header: jtfctkas.pls 115.7 2002/12/05 23:28:25 sachoudh ship $ */


   g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_TASK_ASSIGNMENT_CUHK';



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
