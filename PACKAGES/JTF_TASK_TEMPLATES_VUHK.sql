--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMPLATES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMPLATES_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtfttkms.pls 115.4 2002/12/04 23:47:46 cjang ship $ */


 PROCEDURE create_task_pre (
  p_task_templates            in jtf_task_templates_pub.task_template_rec,
   x_return_status             OUT NOCOPY      VARCHAR2
 );

  PROCEDURE create_task_post (
   p_task_templates            in jtf_task_templates_pub.task_template_rec,
    x_return_status             OUT NOCOPY      VARCHAR2
  );

   PROCEDURE update_task_pre (
    p_task_templates            in jtf_task_templates_pub.task_template_rec,
x_return_status             OUT NOCOPY      VARCHAR2
   );

    PROCEDURE update_task_post (
p_task_templates            in jtf_task_templates_pub.task_template_rec,
 x_return_status             OUT NOCOPY      VARCHAR2
    );

PROCEDURE delete_task_pre (
 p_task_templates            in jtf_task_templates_pub.task_template_rec,
  x_return_status             OUT NOCOPY      VARCHAR2
);

 PROCEDURE delete_task_post (
  p_task_templates            in jtf_task_templates_pub.task_template_rec,
   x_return_status             OUT NOCOPY      VARCHAR2
 );

END;

 

/
