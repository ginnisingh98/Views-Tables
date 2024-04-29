--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMPLATES_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMPLATES_UTL" AUTHID CURRENT_USER AS
/* $Header: jtfptuts.pls 120.1.12000000.1 2007/01/18 16:34:42 appldev ship $ */

   PROCEDURE validate_task_template_group (
      p_task_template_group_id IN NUMBER
   );

   PROCEDURE validate_create_template (
      p_task_template_info IN jtf_task_inst_templates_pub.task_template_info,
      p_source_object_type_code IN jtf_objects_b.object_code%TYPE,
      p_task_template_group_info IN jtf_task_inst_templates_pub.task_template_group_info,
      x_task_id OUT NOCOPY NUMBER,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   );

   PROCEDURE validate_create_task_resource (
      p_task_template_id IN NUMBER,
      p_task_id IN NUMBER,
      x_resource_req_id OUT NOCOPY jtf_task_rsc_reqs.resource_req_id%TYPE,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   );

   PROCEDURE validate_create_recur (
      p_recurrence_rule_id IN NUMBER,
      p_task_id IN NUMBER,
      x_reccurence_generated OUT NOCOPY NUMBER,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   );

   PROCEDURE create_task_phones (
      p_task_contact_points_tbl IN jtf_task_inst_templates_pub.task_contact_points_tbl,
      p_task_template_id IN NUMBER,
      p_task_contact_id IN NUMBER,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   );

   PROCEDURE create_template_group_tasks (
      p_source_object_type_code IN jtf_objects_b.object_code%TYPE,
      p_task_template_group_info IN jtf_task_inst_templates_pub.task_template_group_info,
      x_task_details_tbl OUT NOCOPY jtf_task_inst_templates_pub.task_details_tbl,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   );

END;

 

/
