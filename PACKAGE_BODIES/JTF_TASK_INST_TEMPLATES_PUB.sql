--------------------------------------------------------
--  DDL for Package Body JTF_TASK_INST_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_INST_TEMPLATES_PUB" AS
/* $Header: jtfpttmb.pls 115.6 2003/02/05 02:41:34 sachoudh ship $ */

  PROCEDURE create_task_from_template (
      p_api_version IN NUMBER,
      p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit IN VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_template_group_info IN task_template_group_info,
      p_task_templates_tbl IN task_template_info_tbl,
      p_task_contact_points_tbl IN task_contact_points_tbl,
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_task_details_tbl OUT NOCOPY task_details_tbl
   )
   IS
      l_api_version      CONSTANT NUMBER     := 1.0;
      l_api_name         CONSTANT VARCHAR2(30)
               := 'CREATE_TASK_FROM_TEMPLATE';
      l_found                       BOOLEAN;
      l_current_record              NUMBER;
      l_recurrence_rule_id        NUMBER;
      l_reccurence_generated      NUMBER;
      l_task_id                   NUMBER;
      l_dependent_on_task_id      NUMBER;
      l_dependency_id             NUMBER;
      l_source_object_type_code   jtf_objects_b.object_code%TYPE;
      l_resource_req_id           jtf_task_rsc_reqs.resource_req_id%TYPE;

      CURSOR c_task_depends (
         p_task_template_id IN NUMBER
      )
      IS
      SELECT task_id,
             dependent_on_task_id,
             dependency_type_code,
             adjustment_time,
             adjustment_time_uom,
             template_flag
        FROM jtf_task_depends d
       WHERE d.task_id = p_task_template_id
         AND template_flag = jtf_task_utl.g_yes;
   BEGIN
      SAVEPOINT create_tasks_template_pub;
      x_return_status := fnd_api.g_ret_sts_success;
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
        fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                'jtf_task_create_templates'
             )
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INCOMPATIBLE_API');
         fnd_message.set_token ('JTF_TASK_INCOMPATIBLE_API',l_api_name);
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Validate Template Group-------
      jtf_task_templates_utl.validate_task_template_group (
         p_task_template_group_id => p_task_template_group_info.task_template_group_id
      );
      -- Get source object code -----------------------
      BEGIN
         SELECT source_object_type_code
           INTO l_source_object_type_code
           FROM jtf_task_temp_groups_vl
          WHERE task_template_group_id = p_task_template_group_info.task_template_group_id;
      END;

      ------ Create Main Tasks.-------------------------
 	  IF (p_task_templates_tbl.COUNT = 0)
      THEN
         jtf_task_templates_utl.create_template_group_tasks (
           p_source_object_type_code => l_source_object_type_code,
           p_task_template_group_info => p_task_template_group_info,
           x_task_details_tbl => x_task_details_tbl,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
           x_return_status => x_return_status
         );

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

      ELSE   -- p_task_templates_tbl.COUNT <> 0
         FOR i IN 1 .. p_task_templates_tbl.COUNT
         LOOP
	            -- checking for duplicate templates
	            FOR j IN 1 .. x_task_details_tbl.COUNT
	            LOOP
	               IF (x_task_details_tbl (j).task_template_id =
	                     p_task_templates_tbl (i).task_template_id)
	               THEN
	                  fnd_message.set_name ('JTF', 'JTF_TASK_DUPLICATE_TEMP');
	                  fnd_message.set_token (
	                     'P_TASK_TEMP_ID',
	                     p_task_templates_tbl (i).task_template_id
	                  );
	                  fnd_msg_pub.add;
	                  RAISE fnd_api.g_exc_unexpected_error;
	               END IF;
	            END LOOP;
                -- Creating tasks.
                jtf_task_templates_utl.validate_create_template (
	                  p_task_template_info => p_task_templates_tbl (i),
	                  p_source_object_type_code => l_source_object_type_code,
	                  p_task_template_group_info => p_task_template_group_info,
	                  x_task_id => l_task_id,
	                  x_msg_count => x_msg_count,
	                  x_msg_data => x_msg_data,
	                  x_return_status => x_return_status
	             );

	            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	            THEN
	               RAISE fnd_api.g_exc_unexpected_error;
	            END IF;

	            x_task_details_tbl (i).task_id := l_task_id;
	            x_task_details_tbl (i).task_template_id := p_task_templates_tbl (i).task_template_id;

         END LOOP; -- i IN 1..p_task_templates_tbl.COUNT
      END IF;   -- .p_task_templates_tbl.COUNT = 0

      FOR i IN 1 .. x_task_details_tbl.COUNT
      LOOP
        -- calling task phones api
		jtf_task_templates_utl.create_task_phones (
            p_task_contact_points_tbl => p_task_contact_points_tbl,
            p_task_template_id => x_task_details_tbl (i).task_template_id,
            p_task_contact_id => x_task_details_tbl (i).task_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
         );

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         -- Resource Creation from Template
         jtf_task_templates_utl.validate_create_task_resource (
             p_task_template_id => x_task_details_tbl (i).task_template_id,
             p_task_id => x_task_details_tbl (i).task_id,
             x_resource_req_id => l_resource_req_id,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             x_return_status => x_return_status
         );

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         -- Create dependencies
         FOR task_depends IN c_task_depends (x_task_details_tbl (i).task_template_id)
         LOOP
            l_task_id := x_task_details_tbl (i).task_id;
            l_found := FALSE;
            l_current_record := 1;

            WHILE NOT l_found
            LOOP
               IF x_task_details_tbl (l_current_record).task_template_id =
                     task_depends.dependent_on_task_id
               THEN
                  l_found := TRUE;
                  l_dependent_on_task_id := x_task_details_tbl (l_current_record).task_id;
               ELSIF l_current_record = x_task_details_tbl.COUNT
               THEN
                  EXIT;
               END IF;

               l_current_record := l_current_record + 1;
            END LOOP;

            IF l_found
            THEN
               jtf_task_dependency_pvt.create_task_dependency (
                  p_api_version => 1.0,
                  p_init_msg_list => fnd_api.g_false,
                  p_commit => fnd_api.g_false,
                  p_task_id => l_task_id,
                  p_dependent_on_task_id => l_dependent_on_task_id,
                  p_dependency_type_code => task_depends.dependency_type_code,
                  p_template_flag => 'N',
                  p_adjustment_time => task_depends.adjustment_time,
                  p_adjustment_time_uom => task_depends.adjustment_time_uom,
                  x_dependency_id => l_dependency_id,
                  x_return_status => x_return_status,
                  x_msg_data => x_msg_data,
                  x_msg_count => x_msg_count
               );

               IF NOT (x_return_status = fnd_api.g_ret_sts_success)
               THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END IF;
         END LOOP;   -- end create dependencies

         ---- Creating recurrences
         BEGIN
            SELECT recurrence_rule_id
              INTO l_recurrence_rule_id
              FROM jtf_task_templates_vl
             WHERE task_template_id = x_task_details_tbl (i).task_template_id;
         END;

         IF l_recurrence_rule_id IS NOT NULL
         THEN
            l_task_id := x_task_details_tbl (i).task_id;
            jtf_task_templates_utl.validate_create_recur (
               p_recurrence_rule_id => l_recurrence_rule_id,
               p_task_id => l_task_id,
               x_reccurence_generated => l_reccurence_generated,
               x_return_status => x_return_status,
               x_msg_data => x_msg_data,
               x_msg_count => x_msg_count
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END LOOP;   -- end creating recurrences

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_tasks_template_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      WHEN OTHERS
      THEN
         ROLLBACK TO create_tasks_template_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;
END;

/
