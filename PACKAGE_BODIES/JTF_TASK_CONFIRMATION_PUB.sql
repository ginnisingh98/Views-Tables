--------------------------------------------------------
--  DDL for Package Body JTF_TASK_CONFIRMATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_CONFIRMATION_PUB" AS
/* $Header: jtfptcfb.pls 120.2 2005/08/09 08:19:49 sbarat noship $ */
  g_pkg_name         CONSTANT VARCHAR2(30) := 'JTF_TASK_CONFIRMATION_PUB';

  /*Procedure used internally*/
  PROCEDURE SET_COUNTER_STATUS  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER,
    p_task_confirmation_status	IN  VARCHAR2,
	p_task_confirmation_counter	IN  NUMBER
  )
  IS
     l_api_version   CONSTANT NUMBER
                     := 1.0;
     l_api_name      CONSTANT VARCHAR2(30)
                     := 'SET_COUNTER_STATUS';

     l_conf_counter	NUMBER;
     l_ovn          NUMBER := p_object_version_number;

    Cursor C_Task Is
           Select * from jtf_tasks_vl
                    Where task_id=p_task_id;

    l_task  C_Task%Rowtype;

  BEGIN
      SAVEPOINT SET_COUNTER_STATUS;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      Open C_Task;
        Fetch C_Task Into l_task;
      Close C_Task;

      jtf_tasks_pvt.update_task (
         p_api_version               => 1.0,
         p_init_msg_list             => fnd_api.g_false,
         p_commit                    => fnd_api.g_false,
         p_object_version_number     => p_object_version_number,
         p_task_id                   => p_task_id,
         p_enable_workflow	       => jtf_task_utl.g_miss_char,
         p_abort_workflow	       => jtf_task_utl.g_miss_char,
	   p_change_mode		       => jtf_task_utl.g_miss_char,
	   p_free_busy_type   	       => jtf_task_utl.g_miss_char,
         p_task_confirmation_status	 =>  p_task_confirmation_status,
	   p_task_confirmation_counter =>  p_task_confirmation_counter,
	   p_task_split_flag           => jtf_task_utl.g_miss_char,
       -- p_child_position           => NULL,
       -- p_child_sequence_num       => NULL,
         x_return_status             => x_return_status,
         x_msg_count                 => x_msg_count,
         x_msg_data                  => x_msg_data,
         p_location_id               => l_task.location_id
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
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO SET_COUNTER_STATUS;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
     WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO SET_COUNTER_STATUS;
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
     WHEN OTHERS
      THEN
         ROLLBACK TO SET_COUNTER_STATUS;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

  END SET_COUNTER_STATUS;

  PROCEDURE RESET_COUNTER  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
  )
  IS
     l_api_version   CONSTANT NUMBER
                     := 1.0;
     l_api_name      CONSTANT VARCHAR2(30)
                     := 'RESET_COUNTER';
  BEGIN
    SAVEPOINT RESET_COUNTER;
    x_return_status := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean (p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    SET_COUNTER_STATUS
    (
      p_api_version           => p_api_version,
      p_init_msg_list         => p_init_msg_list,
      p_commit	              => p_commit,
      x_return_status         => x_return_status,
      x_msg_count	      => x_msg_count,
      x_msg_data	      => x_msg_data,
      p_object_version_number =>  p_object_version_number,
      p_task_id	              => p_task_id,
      p_task_confirmation_status  =>  jtf_task_utl.g_miss_char,
      p_task_confirmation_counter => 0
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
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO RESET_COUNTER;
         x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO RESET_COUNTER;
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO RESET_COUNTER;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

  END RESET_COUNTER;

  FUNCTION get_conf_counter (p_task_id IN NUMBER)
      RETURN NUMBER
   IS
      l_conf_counter	NUMBER;
   BEGIN
     SELECT nvl(task_confirmation_counter, 0)
     INTO   l_conf_counter
     FROM   jtf_tasks_b
     WHERE  task_id = p_task_id;

   RETURN l_conf_counter;
   EXCEPTION
      WHEN OTHERS
      THEN
      RETURN NULL;
   END;

  PROCEDURE INCREASE_COUNTER  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
  )
  IS
     l_api_version   CONSTANT NUMBER
                     := 1.0;
     l_api_name      CONSTANT VARCHAR2(30)
                     := 'RESET_COUNTER';
     l_conf_counter	NUMBER;
     l_ovn          NUMBER := p_object_version_number;

  BEGIN
      SAVEPOINT INCREASE_COUNTER;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    l_conf_counter := get_conf_counter (p_task_id);

    SET_COUNTER_STATUS
    (
      p_api_version	      => p_api_version,
      p_init_msg_list         => p_init_msg_list,
      p_commit	              => p_commit,
      x_return_status         => x_return_status,
      x_msg_count	      => x_msg_count,
      x_msg_data	      => x_msg_data,
      p_object_version_number =>  p_object_version_number,
      p_task_id	              => p_task_id,
      p_task_confirmation_status  => jtf_task_utl.g_miss_char,
      p_task_confirmation_counter => nvl(l_conf_counter,0) + 1
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
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO INCREASE_COUNTER;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO INCREASE_COUNTER;
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO INCREASE_COUNTER;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

  END INCREASE_COUNTER;

   PROCEDURE DECREASE_COUNTER  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
  )
  IS
     l_api_version   CONSTANT NUMBER
                     := 1.0;
     l_api_name      CONSTANT VARCHAR2(30)
                     := 'DECREASE_COUNTER';

     l_conf_counter	NUMBER;

  BEGIN
      SAVEPOINT DECREASE_COUNTER;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

     l_conf_counter := get_conf_counter (p_task_id);

     SET_COUNTER_STATUS
    (
    p_api_version	      => p_api_version,
	p_init_msg_list       => p_init_msg_list,
	p_commit	          => p_commit,
    x_return_status       => x_return_status,
	x_msg_count	          => x_msg_count,
	x_msg_data	          => x_msg_data,
    p_object_version_number =>  p_object_version_number,
    p_task_id	          => p_task_id,
    p_task_confirmation_status	=>  jtf_task_utl.g_miss_char,
	p_task_confirmation_counter => nvl(l_conf_counter,0) - 1
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
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO DECREASE_COUNTER;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO DECREASE_COUNTER;
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO DECREASE_COUNTER;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

  END DECREASE_COUNTER;

  PROCEDURE CHANGE_COUNTER_SIGN  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
  )
  IS
     l_api_version   CONSTANT NUMBER
                     := 1.0;
     l_api_name      CONSTANT VARCHAR2(30)
                     := 'CHANGE_COUNTER_SIGN';

     l_conf_counter	NUMBER;

  BEGIN
      SAVEPOINT CHANGE_COUNTER_SIGN;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

     l_conf_counter := get_conf_counter (p_task_id);

     SET_COUNTER_STATUS
    (
    p_api_version	      => p_api_version,
	p_init_msg_list       => p_init_msg_list,
	p_commit	          => p_commit,
    x_return_status       => x_return_status,
	x_msg_count	          => x_msg_count,
	x_msg_data	          => x_msg_data,
    p_object_version_number =>  p_object_version_number,
    p_task_id	          => p_task_id,
    p_task_confirmation_status	=>  jtf_task_utl.g_miss_char,
	p_task_confirmation_counter => nvl(l_conf_counter,0)*(-1)
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
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO CHANGE_COUNTER_SIGN;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
     WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO CHANGE_COUNTER_SIGN;
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
     WHEN OTHERS
      THEN
         ROLLBACK TO CHANGE_COUNTER_SIGN;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

  END CHANGE_COUNTER_SIGN;

  PROCEDURE RESET_CONFIRMATION_STATUS   (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
  )
  IS
     l_api_version   CONSTANT NUMBER
                     := 1.0;
     l_api_name      CONSTANT VARCHAR2(30)
                     := 'RESET_CONFIRMATION_STATUS';

    l_conf_counter	NUMBER;
    l_ovn          NUMBER := p_object_version_number;


  BEGIN
      SAVEPOINT RESET_CONFIRMATION_STATUS;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

     SET_COUNTER_STATUS
    (
    p_api_version	      => p_api_version,
	p_init_msg_list       => p_init_msg_list,
	p_commit	          => p_commit,
    x_return_status       => x_return_status,
	x_msg_count	          => x_msg_count,
	x_msg_data	          => x_msg_data,
    p_object_version_number =>  p_object_version_number,
    p_task_id	          => p_task_id,
    p_task_confirmation_status	=> 'N',
	p_task_confirmation_counter => 0
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
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO RESET_CONFIRMATION_STATUS;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
     WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO RESET_CONFIRMATION_STATUS;
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
     WHEN OTHERS
      THEN
         ROLLBACK TO RESET_CONFIRMATION_STATUS;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

  END RESET_CONFIRMATION_STATUS;

  PROCEDURE SET_CONFIRMATION_REQUIRED   (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
  )
  IS
     l_api_version   CONSTANT NUMBER
                     := 1.0;
     l_api_name      CONSTANT VARCHAR2(30)
                     := 'SET_CONFIRMATION_REQUIRED';

    l_conf_counter	NUMBER;
    l_ovn          NUMBER := p_object_version_number;


  BEGIN
      SAVEPOINT SET_CONFIRMATION_REQUIRED;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    SET_COUNTER_STATUS
    (
    p_api_version	      => p_api_version,
	p_init_msg_list       => p_init_msg_list,
	p_commit	          => p_commit,
    x_return_status       => x_return_status,
	x_msg_count	          => x_msg_count,
	x_msg_data	          => x_msg_data,
    p_object_version_number =>  p_object_version_number,
    p_task_id	          => p_task_id,
    p_task_confirmation_status	=> 'R',
	p_task_confirmation_counter => jtf_task_utl.g_miss_number
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
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO SET_CONFIRMATION_REQUIRED;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
     WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO SET_CONFIRMATION_REQUIRED;
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
     WHEN OTHERS
      THEN
         ROLLBACK TO SET_CONFIRMATION_REQUIRED;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

  END SET_CONFIRMATION_REQUIRED;

  PROCEDURE SET_CONFIRMATION_CONFIRMED   (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
  )
  IS
     l_api_version   CONSTANT NUMBER
                     := 1.0;
     l_api_name      CONSTANT VARCHAR2(30)
                     := 'SET_CONFIRMATION_CONFIRMED';

    l_conf_counter	NUMBER;


  BEGIN
      SAVEPOINT SET_CONFIRMATION_CONFIRMED;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

     l_conf_counter := get_conf_counter (p_task_id);

     SET_COUNTER_STATUS
    (
      p_api_version	          => p_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_commit	                  => p_commit,
      x_return_status             => x_return_status,
      x_msg_count	          => x_msg_count,
      x_msg_data	          => x_msg_data,
      p_object_version_number     =>  p_object_version_number,
      p_task_id	                  => p_task_id,
      p_task_confirmation_status  => 'C',
      p_task_confirmation_counter => nvl(l_conf_counter,0)
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
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO SET_CONFIRMATION_CONFIRMED;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO SET_CONFIRMATION_CONFIRMED;
         x_return_status := fnd_api.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO SET_CONFIRMATION_CONFIRMED;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );

  END SET_CONFIRMATION_CONFIRMED;

END;

/
