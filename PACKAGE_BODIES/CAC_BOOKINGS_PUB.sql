--------------------------------------------------------
--  DDL for Package Body CAC_BOOKINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_BOOKINGS_PUB" AS
/* $Header: cacpttbb.pls 120.3 2005/07/29 12:19:11 sbarat noship $ */

   PROCEDURE create_booking (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit             IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_booking_rec        IN              cac_bookings_pub.booking_type,
      x_booking_id         OUT NOCOPY      NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER
               := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'CREATE_BOOKING';
	  l_booking_type_rec 	cac_bookings_pub.booking_type := p_booking_rec;

   BEGIN
      SAVEPOINT create_bookings_pub;
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

      -- Booking Rules...

	  validate_booking (
       p_booking_rec   => l_booking_type_rec,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
     );

    jtf_tasks_pvt.create_task (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_task_name => l_booking_type_rec.booking_subject,
         p_task_type_id => l_booking_type_rec.booking_type_id,
         p_description  => l_booking_type_rec.description,
         p_task_status_id => l_booking_type_rec.booking_status_id,
         p_owner_type_code => l_booking_type_rec.resource_type_code,
         p_owner_id => l_booking_type_rec.resource_id,
         p_source_object_type_code => l_booking_type_rec.source_object_type_code,
         p_source_object_id => l_booking_type_rec.source_object_id,
         p_scheduled_start_date => l_booking_type_rec.start_date,
         p_scheduled_end_date => l_booking_type_rec.end_date,
         p_date_selected => 'S',
		 p_show_on_calendar => 'Y',
		 p_entity           => 'BOOKING',
		 p_free_busy_type => l_booking_type_rec.freebusytype,
         p_enable_workflow	    => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
         p_abort_workflow	    => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
         p_reference_flag => 'N',
         p_task_confirmation_status => NULL,
         p_task_confirmation_counter => NULL,
         p_task_split_flag  => NULL,
		 x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_task_id => x_booking_id
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
         ROLLBACK TO create_bookings_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_bookings_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE update_booking (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit             IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_booking_rec        IN              cac_bookings_pub.booking_type,
      p_object_version_number   IN         NUMBER ,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )

   IS
      l_api_version   CONSTANT NUMBER
               := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'UPDATE_BOOKING';
	  l_ovn          NUMBER := p_object_version_number;
	  l_booking_type_rec 	cac_bookings_pub.booking_type := p_booking_rec;

   BEGIN
      SAVEPOINT update_bookings_pub;
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

      -- Booking Rules...
	  -- For booking scheduled dates are populated --'

	 IF (l_booking_type_rec.booking_id = fnd_api.g_miss_num
	     OR l_booking_type_rec.booking_id IS NULL)
	 THEN
	    fnd_message.set_name ('CAC', 'CAC_BOOKING_MISSING_TASK');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_unexpected_error;
     ELSE

		jtf_task_utl.validate_task (
		    p_task_id => l_booking_type_rec.booking_id,
		    p_task_number => NULL,
		    x_task_id => l_booking_type_rec.booking_id,
		    x_return_status => x_return_status
		);

		 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
		 THEN
		    x_return_status := fnd_api.g_ret_sts_unexp_error;
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;

      END IF;

	  -- Booking Rules...

	  validate_booking (
       p_booking_rec   => l_booking_type_rec,
	   x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
     );


	 jtf_tasks_pvt.update_task (
         p_api_version    => 1.0,
         p_init_msg_list  => fnd_api.g_false,
         p_commit         => fnd_api.g_false,
         p_object_version_number => l_ovn,
         p_task_id        => l_booking_type_rec.booking_id,
         p_task_name      => l_booking_type_rec.booking_subject,
         p_task_type_id   => l_booking_type_rec.booking_type_id,
         p_description    => l_booking_type_rec.description,
         p_owner_type_code => l_booking_type_rec.resource_type_code,
         p_owner_id        => l_booking_type_rec.resource_id,
         p_source_object_type_code => l_booking_type_rec.source_object_type_code,
         p_source_object_id => l_booking_type_rec.source_object_id,
         p_scheduled_start_date => l_booking_type_rec.start_date,
         p_scheduled_end_date => l_booking_type_rec.end_date,
         p_show_on_calendar => 'Y',
		 p_date_selected    => 'S',
		 p_free_busy_type   => l_booking_type_rec.freebusytype,
         p_enable_workflow	  => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
	     p_abort_workflow	  => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
	     p_change_mode	      => JTF_TASK_REPEAT_APPT_PVT.G_ONE,
         p_task_confirmation_status	=> NULL,
         p_task_confirmation_counter	=> NULL,
         p_task_split_flag         =>  NULL,
		 x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
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
         ROLLBACK TO update_bookings_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_bookings_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;


   PROCEDURE validate_booking (
       p_booking_rec        IN              cac_bookings_pub.booking_type,
	   x_return_status      OUT NOCOPY      VARCHAR2,
       x_msg_count          OUT NOCOPY      NUMBER,
       x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_booking_type_rec 	cac_bookings_pub.booking_type := p_booking_rec;

   BEGIN
     -- For booking scheduled dates are populated --'
      IF (l_booking_type_rec.start_date IS NULL)
      THEN
         fnd_message.set_name ('CAC', 'CAC_BOOKING_NULL_START_DATE');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_booking_type_rec.end_date IS NULL)
      THEN
         fnd_message.set_name ('CAC', 'CAC_BOOKING_NULL_END_DATE');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

	  --Validations

       jtf_task_utl.validate_task_type (
		 p_task_type_id =>  l_booking_type_rec.booking_type_id,
		 p_task_type_name => NULL,
		 x_return_status => x_return_status,
		 x_task_type_id => l_booking_type_rec.booking_type_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
		 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_booking_type_rec.booking_type_id IS NULL
      THEN
	     fnd_message.set_name ('CAC', 'CAC_BOOKING_MISSING_TASK_TYPE');
		 fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

      /* jtf_task_utl.validate_task_status (
	     p_task_status_id => l_booking_type_rec.booking_status_id,
	     p_task_status_name => NULL,
	     p_validation_type => 'TASK',
	     x_return_status => x_return_status,
	     x_task_status_id => l_booking_type_rec.booking_status_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
		 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_booking_type_rec.booking_status_id IS NULL
      THEN
	     fnd_message.set_name ('CAC', 'CAC_BOOKING_MISSING_TASK_STATUS');
		 fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
	  END IF; */

	   jtf_task_utl.validate_dates (
		 p_date_tag => jtf_task_utl.get_translated_lookup (
				  'JTF_TASK_TRANSLATED_MESSAGES',
				  'SCHEDULED'
			       ),
		 p_start_date => l_booking_type_rec.start_date,
		 p_end_date => l_booking_type_rec.end_date,
		 x_return_status => x_return_status
      );

	  IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
		RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

	  -- Validate Source Object Type Code --

       jtf_task_utl.validate_object_type
		(
		p_object_code => l_booking_type_rec.source_object_type_code,
		p_object_type_name => NULL,
		p_object_type_tag => 'Source',
		p_object_usage => 'BOOKING',
		x_return_status => x_return_status ,
		x_object_code => l_booking_type_rec.source_object_type_code
		);

	  -- Validate Owner --
	  -- this will be changed to validate_booking_resource ..

      IF l_booking_type_rec.resource_id IS NULL
      THEN
		 fnd_message.set_name ('CAC', 'BKG_INVALID_RESOURCE_ID');
		 fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

      IF l_booking_type_rec.resource_type_code IS NULL
      THEN
		 fnd_message.set_name ('CAC', 'BKG_INVALID_RESOURCE_TYPE_CODE');
		 fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

	  jtf_task_utl.validate_task_owner (
		 p_owner_type_code => l_booking_type_rec.resource_type_code,
		 p_owner_type_name => NULL,
		 p_owner_id => l_booking_type_rec.resource_id,
		 x_return_status => x_return_status,
		 x_owner_id => l_booking_type_rec.resource_id,
		 x_owner_type_code => l_booking_type_rec.resource_type_code
	  );


	  IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
		 fnd_message.set_name ('JTF', 'BKG_INVALID_RESOURCE');
		 fnd_msg_pub.add;
		 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

	 --	include booking usage here,,
	/* jtf_task_utl.validate_source_object (
	    p_object_code => l_booking_type_rec.source_object_type_code,
	    p_object_id =>   l_booking_type_rec.source_object_id,
	    p_object_name => NULL,
	    x_return_status => x_return_status
	 );

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	 END IF; */

     -- Validate freebusytype ..
     IF  l_booking_type_rec.freebusytype NOT IN
         ('FREE','BUSY','FREE_BUSY_TENTATIVE')
     THEN
         fnd_message.set_name ('CAC', 'CAC_BOOKING_INVALID_TYPE');
		 fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;


   END;

   PROCEDURE delete_booking (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_booking_id      IN              NUMBER,
	  p_object_version_number   IN      NUMBER ,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER
               := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'DELETE_BOOKING';
      l_task_id                jtf_tasks_b.task_id%TYPE
               := p_booking_id;

	  l_ovn    NUMBER
	           := p_object_version_number;

   BEGIN
      SAVEPOINT delete_bookings_pub;
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

     IF (l_task_id = fnd_api.g_miss_num)
	     OR (l_task_id IS NULL)
	 THEN
	    fnd_message.set_name ('CAC', 'CAC_BOOKING_MISSING_TASK');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_unexpected_error;
     END IF;


      jtf_tasks_pvt.delete_task (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_object_version_number => l_ovn,
         p_task_id => l_task_id,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
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
         ROLLBACK TO delete_bookings_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_bookings_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

END;

/
