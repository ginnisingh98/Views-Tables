--------------------------------------------------------
--  DDL for Package CAC_BOOKINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_BOOKINGS_PUB" AUTHID CURRENT_USER AS
/* $Header: cacpttbs.pls 120.1 2005/06/10 20:13:52 rhshriva noship $ */

  g_pkg_name   CONSTANT VARCHAR2(30)	      := 'cac_bookings_pub';

  TYPE booking_type IS RECORD (
        booking_id                NUMBER := NULL,
        resource_type_code        jtf_objects_b.object_code%TYPE,
        resource_id               jtf_tasks_b.owner_id%TYPE,
        start_date                jtf_tasks_b.scheduled_start_date%TYPE,
        end_date                  jtf_tasks_b.scheduled_end_date%TYPE,
        booking_type_id           jtf_tasks_b.task_type_id%TYPE,
        booking_status_id         jtf_tasks_b.task_status_id%TYPE,
        source_object_type_code   jtf_tasks_b.source_object_type_code%TYPE,
        source_object_id          jtf_tasks_b.source_object_id%TYPE,
        booking_subject           jtf_tasks_tl.task_name%TYPE,
        freebusytype              VARCHAR2(30)  DEFAULT 'BUSY',
        description               jtf_tasks_tl.description%type
   );


   PROCEDURE create_booking (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit             IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_booking_rec        IN              cac_bookings_pub.booking_type,
      x_booking_id         OUT NOCOPY      NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_booking (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit             IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_booking_rec        IN              cac_bookings_pub.booking_type,
      p_object_version_number   IN         NUMBER ,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   );

    PROCEDURE validate_booking (
       p_booking_rec        IN              cac_bookings_pub.booking_type,
	   x_return_status      OUT NOCOPY      VARCHAR2,
       x_msg_count          OUT NOCOPY      NUMBER,
       x_msg_data           OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_booking (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_booking_id      IN              NUMBER,
	  p_object_version_number   IN      NUMBER ,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );


END;

 

/
