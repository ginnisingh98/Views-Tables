--------------------------------------------------------
--  DDL for Package OTA_CME_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CME_UTIL" AUTHID CURRENT_USER AS
/* $Header: otcmewrs.pkh 120.4.12010000.2 2008/11/07 09:26:39 pekasi ship $ */

-- ---------------------------------------------------------------------------
-- |----------------------< get_enrl_status_on_update >-----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    During cme update set's the enrollment status and date_status changed as
--    the out parameters for the class in the order A P W R C
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_activity_version_id
--    p_cert_prd_enrollment_id
--
--  Post Success:
--    Enrollment status, date_status changed is set as out parameters
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ----------------------------------------------------------------------------
PROCEDURE get_enrl_status_on_update(p_activity_version_id    IN ota_activity_versions.activity_version_id%TYPE,
                               p_cert_prd_enrollment_id  IN ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
			       p_booking_status_type     OUT NOCOPY ota_booking_status_types.type%TYPE,
                               p_date_status_changed     OUT NOCOPY ota_delegate_bookings.date_status_changed%TYPE);


-- ---------------------------------------------------------------------------
-- |----------------------< calculate_cme_status >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_code
-- Called while creating/updating a cert member enrollment with member
-- status not equal to 'PLANNED' to determine the exact status based on
-- enrollments falling under it
--
--  Prerequisites:
--
--  In Arguments:
--    p_activity_version_id
--    p_cert_prd_enrollment_id
--    p_mode, either 'C' as create or 'U' as update
--
--  Post Success:
--    Member status is returned to calling unit
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE calculate_cme_status(p_activity_version_id      IN ota_activity_versions.activity_version_id%TYPE,
                               p_cert_prd_enrollment_id   IN ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
                               p_mode                     IN VARCHAR2,
                               p_member_status_code       OUT nocopy VARCHAR2,
                               p_completion_date          OUT nocopy DATE);

-- ---------------------------------------------------------------------------
-- |----------------------< update_cme_status            >-------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    when Enrollment status to an event changes the CME's status attached to the
--  event also changes.
--  Called from ota_tdb_api_upd2.update_enrollment and ota_tdb_api_ins2.create_enrollment
--  Prerequisites:
--
--
--  In Arguments:
--    p_event_id
--    p_person_id
--
--  Post Success:
--    The attached CME's status is updated
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE update_cme_status (p_event_id          IN ota_events.event_id%TYPE,
                                        p_person_id         IN ota_cert_enrollments.person_id%TYPE,
               				p_contact_id        IN ota_cert_enrollments.contact_id%TYPE,
                                        p_cert_prd_enrollment_ids OUT NOCOPY varchar2);


--  ---------------------------------------------------------------------------
--  |----------------------< Update_cpe_status >------------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_code
-- Called while creating/updating a cert member enrollment with member
-- status not equal to 'PLANNED' to determine the exact status based on
-- enrollments falling under it
--
--  Prerequisites:
--
--  In Arguments:
--    p_cert_mbr_enrollment_id
--    p_completion_date
--
--  Post Success:
--    Member status is returned to calling unit
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ---------------------------------------------------------------------------
Procedure Update_cpe_status
          (p_cert_mbr_enrollment_id     IN ota_cert_mbr_enrollments.cert_mbr_enrollment_id%TYPE
           ,p_cert_prd_enrollment_id     OUT NOCOPY varchar2
           ,p_completion_date in date default sysdate);

-- ---------------------------------------------------------------------------
-- |----------------------< update_cme_status            >-------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    when Enrollment status to an event changes the CME's status attached to the
--  event also changes.
--  Called from ota_tdb_api_upd2.update_enrollment and ota_tdb_api_ins2.create_enrollment
--  Prerequisites:
--
--
--  In Arguments:
--    p_cert_mbr_enrollment_id
--
--  Post Success:
--    The attached CME's status is updated
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE update_cme_status (p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type);

-- ---------------------------------------------------------------------------
-- |----------------------< chk_if_cme_exists            >-------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks whether there are learners who have enrolled in the certification member.
--    If there are no enrollments, then the component may be removed from the certification.
--  Prerequisites:
--
--
--  In Arguments:
--    p_cmb_id
--
--
--  Post Failure:
--
--
--  Access Status:
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_if_cme_exists (p_cmb_id    IN     ota_certification_members.certification_member_id%TYPE
   , p_return_status OUT  NOCOPY VARCHAR2);


-- ---------------------------------------------------------------------------
-- |----------------------< refresh_cme            >-------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--  This procedure will check for any newly added and end dated courses since
--  last cert unsubscribe, creates cme record for new courses and update cme
--  member_status_code for end dated courses.
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_cert_prd_enrollment_id
--
--
--  Post Failure:
--
--
--  Access Status:
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure refresh_cme(p_cert_prd_enrollment_id in ota_cert_mbr_enrollments.cert_prd_enrollment_id%type);

Function chk_active_cme_enrl(p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2;


END OTA_CME_UTIL;

/
