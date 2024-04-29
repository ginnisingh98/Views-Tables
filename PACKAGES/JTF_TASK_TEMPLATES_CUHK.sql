--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMPLATES_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMPLATES_CUHK" AUTHID CURRENT_USER AS
/* $Header: jtfctkms.pls 115.6 2002/12/05 23:30:03 sachoudh ship $ */


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
