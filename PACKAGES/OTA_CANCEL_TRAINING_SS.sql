--------------------------------------------------------
--  DDL for Package OTA_CANCEL_TRAINING_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CANCEL_TRAINING_SS" AUTHID CURRENT_USER AS
/* $Header: otssctrn.pkh 115.5 2002/11/29 06:48:37 dbatra noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------<create_enroll_wf_process>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to set the item attributes in workflow.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_item_key
--   p_item_type
--   p_person_id
--   p_event_title
--   p_course_start_date
--   p_course_end_date
-- Out Arguments:
--   x_return_status
--   x_msg_data
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE create_enroll_wf_process
          (x_return_status      OUT NOCOPY VARCHAR2,
           x_msg_data           OUT NOCOPY VARCHAR2,
           p_item_key       	IN wf_items.item_key%TYPE,
           p_item_type          IN wf_items.item_type%TYPE,
           p_person_id          IN number default NULL,
           p_event_title        IN ota_events.title%TYPE,
           p_course_start_date  IN ota_events.course_start_date%TYPE,
           p_course_end_date    IN ota_events.course_end_date%TYPE,
           p_version_name IN ota_activity_versions.Version_name%TYPE );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< cancel_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be called from the View Enrollment Details Screen on pressing 'Submit'.
--
--   This procedure will be used to call the cancel the enrollment Id passed in and
--   update the Enrollment with the Cancellation details.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_init_msg_list
--   p_booking_id
--   p_event_id
--   p_person_id
--   p_booking_status_type_id
--   p_cancel_reason
--   p_username
--   p_waitlist_size
--   p_item_key
--   p_item_type
--
-- Out Arguments:
--   x_return_status
--   x_msg_count
--   x_msg_data
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE cancel_enrollment
                        (p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_booking_id IN NUMBER,
                         p_event_id IN NUMBER,
                         p_person_id IN NUMBER,
                         p_booking_status_type_id IN NUMBER,
                         p_cancel_reason IN VARCHAR2,
                         p_username IN VARCHAR2,
                         p_waitlist_size IN NUMBER,
                         p_item_key IN VARCHAR2 DEFAULT NULL,
                         p_item_type IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information_category IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information1 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information2 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information3 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information4 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information5 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information6 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information7 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information8 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information9 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information10 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information11 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information12 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information13 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information14 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information15 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information16 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information17 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information18 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information19 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information20 IN VARCHAR2 DEFAULT NULL
                         );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_booking_status_comments >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: get the comments from the booking history table for the
-- booking_id and booking_status_type_id passed in as parameters.
--
--

FUNCTION get_booking_status_comments(p_booking_id IN NUMBER,
                                     p_booking_status_type_id IN NUMBER) RETURN VARCHAR2;
--

END ota_cancel_training_ss;

 

/
