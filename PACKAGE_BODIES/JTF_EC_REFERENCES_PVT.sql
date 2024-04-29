--------------------------------------------------------
--  DDL for Package Body JTF_EC_REFERENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EC_REFERENCES_PVT" AS
/* $Header: jtfecreb.pls 115.19 2004/02/13 10:58:24 nselvam ship $ */
   g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_EC_REFERENCES_PVT';

   PROCEDURE create_references (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_escalation_id             IN       NUMBER DEFAULT NULL,
      p_escalation_number         IN       VARCHAR2 DEFAULT NULL,
      p_object_type_code          IN       VARCHAR2,
      p_object_name               IN       VARCHAR2,
      p_object_id                 IN       NUMBER,
      p_object_details            IN       VARCHAR2 DEFAULT NULL,
      p_reference_code            IN       VARCHAR2 DEFAULT NULL,
      p_usage                     IN       VARCHAR2 DEFAULT NULL,
      x_return_status             OUT NOCOPY     VARCHAR2,
      x_msg_data                  OUT NOCOPY     VARCHAR2,
      x_msg_count                 OUT NOCOPY     NUMBER,
      x_escalation_reference_id   OUT NOCOPY     NUMBER,
      p_attribute1                IN       VARCHAR2 DEFAULT null ,
      p_attribute2                IN       VARCHAR2 DEFAULT null ,
      p_attribute3                IN       VARCHAR2 DEFAULT null ,
      p_attribute4                IN       VARCHAR2 DEFAULT null ,
      p_attribute5                IN       VARCHAR2 DEFAULT null ,
      p_attribute6                IN       VARCHAR2 DEFAULT null ,
      p_attribute7                IN       VARCHAR2 DEFAULT null ,
      p_attribute8                IN       VARCHAR2 DEFAULT null ,
      p_attribute9                IN       VARCHAR2 DEFAULT null ,
      p_attribute10               IN       VARCHAR2 DEFAULT null ,
      p_attribute11               IN       VARCHAR2 DEFAULT null ,
      p_attribute12               IN       VARCHAR2 DEFAULT null ,
      p_attribute13               IN       VARCHAR2 DEFAULT null ,
      p_attribute14               IN       VARCHAR2 DEFAULT null ,
      p_attribute15               IN       VARCHAR2 DEFAULT null ,
      p_attribute_category        IN       VARCHAR2 DEFAULT null
   )
   IS
      l_api_version      CONSTANT NUMBER                       := 1.0;
      l_api_name         CONSTANT VARCHAR2(30)                 := 'CREATE_REFERENCES';
      l_escalation_reference_id   NUMBER;
      l_rowid                     ROWID;
      l_escalation_id             jtf_tasks_b.task_id%TYPE     := p_escalation_id;
      l_escalation_number         jtf_tasks_b.task_number%TYPE := p_escalation_number;
      x                           CHAR;
--Created for BES enh 2660883
   l_esc_ref_rec       jtf_ec_references_pvt.Esc_Ref_rec;

   BEGIN
      SAVEPOINT create_references_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -----
      -----  Validate escaltion
      -----
      jtf_task_utl.validate_task (
         x_return_status => x_return_status,
         p_task_id => l_escalation_id,
         p_task_number => l_escalation_number,
         x_task_id => l_escalation_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_escalation_id IS NULL
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ----
      ----
      ----
      ----
      IF p_reference_code IS NOT NULL
      THEN
         IF jtf_task_utl.validate_lookup (
               'JTF_TASK_REFERENCE_CODES',
               p_reference_code,
               'Escalation Reference Code (JTF_TASK_REFERENCE_CODES)'
            )
         THEN
            NULL;
         ELSE
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      jtf_task_references_pub.create_references (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_task_id => l_escalation_id,
         p_object_type_code => p_object_type_code,
         p_object_name => p_object_name,
         p_object_id => p_object_id,
         p_object_details => p_object_details,
         p_reference_code => p_reference_code,
         p_usage => p_usage,
         x_return_status => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count,
         x_task_reference_id => x_escalation_reference_id,
	 p_attribute1    =>     p_attribute1,
	 p_attribute2    =>     p_attribute2,
	 p_attribute3    =>     p_attribute3,
	 p_attribute4    =>     p_attribute4,
	 p_attribute5    =>     p_attribute5,
	 p_attribute6    =>     p_attribute6,
	 p_attribute7    =>     p_attribute7,
	 p_attribute8    =>     p_attribute8,
	 p_attribute9    =>     p_attribute9,
	 p_attribute10    =>    p_attribute10,
	 p_attribute11    =>    p_attribute11,
	 p_attribute12    =>    p_attribute12,
	 p_attribute13    =>    p_attribute13,
	 p_attribute14    =>     p_attribute14,
	 p_attribute15    =>     p_attribute15,
         p_attribute_category  => p_attribute_category
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

--Created for BES enh 2660883
    begin

        l_esc_ref_rec.task_reference_id          := x_escalation_reference_id;
        l_esc_ref_rec.object_type_code       := p_object_type_code;
        l_esc_ref_rec.reference_code       := p_reference_code;
        l_esc_ref_rec.object_id       := p_object_id;
-- Added for Bug # 3385990
	l_esc_ref_rec.task_id         := l_escalation_id;

       jtf_esc_wf_events_pvt.publish_create_escRef
              (p_esc_ref_rec              => l_esc_ref_rec);

    EXCEPTION when others then
       null;
    END;
--End BES enh 2660883

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_references_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN NO_DATA_FOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_NAME');
         fnd_message.set_token ('P_OBJECT_TYPE_CODE', p_object_type_code);
         fnd_message.set_token ('P_OBJECT_NAME', p_object_name);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

/*   PROCEDURE lock_references (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_escalation_reference_id   IN       NUMBER,
      p_object_version_number IN   NUMBER,
      x_return_status     OUT      VARCHAR2,
      x_msg_data          OUT      VARCHAR2,
      x_msg_count         OUT      NUMBER
   )  ;
*/
   PROCEDURE update_references (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number     IN OUT NOCOPY  NUMBER,
      p_escalation_reference_id   IN       NUMBER,
      p_object_type_code          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_object_name               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_object_id                 IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_object_details            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_reference_code            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_usage                     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      x_return_status             OUT NOCOPY     VARCHAR2,
      x_msg_data                  OUT NOCOPY     VARCHAR2,
      x_msg_count                 OUT NOCOPY     NUMBER,
      p_attribute1                IN       VARCHAR2 DEFAULT null ,
      p_attribute2                IN       VARCHAR2 DEFAULT null ,
      p_attribute3                IN       VARCHAR2 DEFAULT null ,
      p_attribute4                IN       VARCHAR2 DEFAULT null ,
      p_attribute5                IN       VARCHAR2 DEFAULT null ,
      p_attribute6                IN       VARCHAR2 DEFAULT null ,
      p_attribute7                IN       VARCHAR2 DEFAULT null ,
      p_attribute8                IN       VARCHAR2 DEFAULT null ,
      p_attribute9                IN       VARCHAR2 DEFAULT null ,
      p_attribute10               IN       VARCHAR2 DEFAULT null ,
      p_attribute11               IN       VARCHAR2 DEFAULT null ,
      p_attribute12               IN       VARCHAR2 DEFAULT null ,
      p_attribute13               IN       VARCHAR2 DEFAULT null ,
      p_attribute14               IN       VARCHAR2 DEFAULT null ,
      p_attribute15               IN       VARCHAR2 DEFAULT null ,
      p_attribute_category        IN       VARCHAR2 DEFAULT null,
      p_task_id			  IN       NUMBER DEFAULT fnd_api.g_miss_num
   )
   IS
      l_api_version   CONSTANT NUMBER                                        := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'UPDATE_REFERENCES';
      l_task_reference_id      jtf_task_references_vl.task_reference_id%TYPE
               := p_escalation_reference_id;

      CURSOR c_escalation_reference
      IS
         SELECT 1 x
           FROM jtf_task_references_vl
          WHERE task_reference_id = p_escalation_reference_id;

      escalation_reference     c_escalation_reference%ROWTYPE;
      x                        CHAR;
--Created for BES enh 2660883
   l_esc_ref_rec_old       jtf_ec_references_pvt.Esc_Ref_rec;
   l_esc_ref_rec_new       jtf_ec_references_pvt.Esc_Ref_rec;

-- Added Task_ID for Bug # 3385990
      CURSOR c_ref_orig (reference_id IN NUMBER) IS
         SELECT REFERENCE_CODE , OBJECT_TYPE_CODE , OBJECT_ID, TASK_ID
           FROM JTF_TASK_REFERENCES_B
          WHERE task_reference_id = reference_id;

      rec_ref_orig    c_ref_orig%ROWTYPE;

   BEGIN


      SAVEPOINT update_references_pub;

      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF p_escalation_reference_id IS NULL
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_REFER');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_escalation_reference;
      FETCH c_escalation_reference INTO escalation_reference;


      IF c_escalation_reference%NOTFOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_REFER');
         fnd_message.set_token ('P_TASK_REFERENCE_ID', p_escalation_reference_id);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -----
      -----  checking each source doc. should have only one escalation.
      -----  ( other than the given escalation ).
      BEGIN
         SELECT 1
           INTO x
           FROM jtf_tasks_vl tasks,
                jtf_task_references_vl reference,
                jtf_task_statuses_vl status
          WHERE reference.task_reference_id <> p_escalation_reference_id
            AND tasks.task_id = reference.task_id
            AND tasks.task_type_id = jtf_ec_pub.g_escalation_type_id
            AND reference.object_type_code = p_object_type_code
            AND reference.object_id = p_object_id
            AND tasks.task_status_id = status.task_status_id
            AND status.closed_flag = 'Y';

         fnd_message.set_name ('JTF', 'JTF_EC_DUPLICATE_ESCALATION');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN TOO_MANY_ROWS
         THEN
            fnd_message.set_name ('JTF', 'JTF_EC_DUPLICATE_ESCALATION');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
      END;

--Created for BES enh 2660883
-- Code moved here to get the old values
    begin
        OPEN c_ref_orig (p_escalation_reference_id);
        FETCH c_ref_orig INTO rec_ref_orig;
        CLOSE c_ref_orig;

        l_esc_ref_rec_old.task_reference_id          := p_escalation_reference_id;
        l_esc_ref_rec_old.object_type_code       := rec_ref_orig.object_type_code;
        l_esc_ref_rec_old.reference_code       := rec_ref_orig.reference_code;
        l_esc_ref_rec_old.object_id       := rec_ref_orig.object_id;
-- Added for Bug # 3385990
	l_esc_ref_rec_old.task_id         := rec_ref_orig.task_id;

--
        l_esc_ref_rec_new.task_reference_id          := p_escalation_reference_id;
        l_esc_ref_rec_new.object_type_code       := p_object_type_code;
        l_esc_ref_rec_new.reference_code       := p_reference_code;
        l_esc_ref_rec_new.object_id       := p_object_id;
-- Added for Bug # 3385990
	l_esc_ref_rec_new.task_id         := p_task_id;
-- End of moved code

      jtf_task_references_pub.update_references (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_object_version_number => p_object_version_number,
         p_task_reference_id => p_escalation_reference_id,
         p_object_type_code => p_object_type_code,
         p_object_name => p_object_name,
         p_object_id => p_object_id,
         p_object_details => p_object_details,
         p_reference_code => p_reference_code,
         p_usage => NULL,
         x_return_status => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count,
	 p_attribute1    =>     p_attribute1,
	 p_attribute2    =>     p_attribute2,
	 p_attribute3    =>     p_attribute3,
	 p_attribute4    =>     p_attribute4,
	 p_attribute5    =>     p_attribute5,
	 p_attribute6    =>     p_attribute6,
	 p_attribute7    =>     p_attribute7,
	 p_attribute8    =>     p_attribute8,
	 p_attribute9    =>     p_attribute9,
	 p_attribute10    =>    p_attribute10,
	 p_attribute11    =>    p_attribute11,
	 p_attribute12    =>    p_attribute12,
	 p_attribute13    =>    p_attribute13,
	 p_attribute14    =>     p_attribute14,
	 p_attribute15    =>     p_attribute15,
         p_attribute_category  => p_attribute_category
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


      jtf_esc_wf_events_pvt.publish_update_escRef
                      (P_ESC_REF_REC_OLD	  => 	l_esc_ref_rec_old,
                       P_ESC_REF_REC_NEW	  => 	l_esc_ref_rec_new);

    EXCEPTION when others then
       null;
    END;
--End BES enh 2660883

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_references_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN NO_DATA_FOUND
      THEN
         ROLLBACK TO update_references_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_NAME');
         fnd_message.set_token ('P_OBJECT_TYPE_CODE', p_object_type_code);
         fnd_message.set_token ('P_OBJECT_NAME', p_object_name);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
         ROLLBACK TO update_references_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

   ---------
   ---------
   ---- start of delete_references
   ---------
   ---------
   PROCEDURE delete_references (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number     IN       NUMBER,
      p_escalation_reference_id   IN       NUMBER,
      x_return_status             OUT NOCOPY     VARCHAR2,
      x_msg_data                  OUT NOCOPY     VARCHAR2,
      x_msg_count                 OUT NOCOPY     NUMBER
   )
   IS
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_REFERENCE';

--Created for BES enh 2660883
   l_esc_ref_rec       jtf_ec_references_pvt.Esc_Ref_rec;

-- Added Task_ID for Bug # 3385990
      CURSOR c_ref_orig (reference_id IN NUMBER) IS
         SELECT REFERENCE_CODE, OBJECT_TYPE_CODE, OBJECT_ID, TASK_ID
           FROM JTF_TASK_REFERENCES_B
          WHERE task_reference_id = reference_id;

      rec_ref_orig    c_ref_orig%ROWTYPE;

   BEGIN
      SAVEPOINT delete_task_reference_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

--Created for BES enh 2660883
        OPEN c_ref_orig (p_escalation_reference_id);
        FETCH c_ref_orig INTO rec_ref_orig;
        CLOSE c_ref_orig;
--end

      jtf_task_references_pvt.delete_references (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_object_version_number => p_object_version_number,
         p_task_reference_id => p_escalation_reference_id,
         x_return_status => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

--Created for BES enh 2660883
    begin

        l_esc_ref_rec.task_reference_id          := p_escalation_reference_id;
        l_esc_ref_rec.object_type_code       := rec_ref_orig.object_type_code;
        l_esc_ref_rec.reference_code       := rec_ref_orig.reference_code;
        l_esc_ref_rec.object_id       := rec_ref_orig.object_id;
-- Added for Bug # 3385990
	l_esc_ref_rec.task_id         := rec_ref_orig.task_id;

       jtf_esc_wf_events_pvt.publish_delete_escRef
              (p_esc_ref_rec              => l_esc_ref_rec);

    EXCEPTION when others then
       null;
    END;
--End BES enh 2660883
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_task_reference_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_task_reference_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

END;

/
