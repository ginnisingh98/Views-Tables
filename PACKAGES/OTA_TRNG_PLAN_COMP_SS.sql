--------------------------------------------------------
--  DDL for Package OTA_TRNG_PLAN_COMP_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRNG_PLAN_COMP_SS" AUTHID CURRENT_USER AS
/* $Header: ottpmwrs.pkh 115.6 2004/03/03 05:16:54 rdola noship $ */

--  ---------------------------------------------------------------------------
--  |----------------------< Update_tpc_sshr_change >--------------------------|
--  ---------------------------------------------------------------------------
--

Procedure Update_tpc_sshr_change(
p_training_plan_member_id  ota_training_plan_members.training_plan_member_id%type,
p_person_id  ota_training_plans.person_id%type,
p_mode varchar2);
--  ---------------------------------------------------------------------------
--  |----------------------< Update_tp_tpc_change >--------------------------|
--  ---------------------------------------------------------------------------
--
-- This procedure will get called only when a tpc is Cancelled

Procedure Update_tp_tpc_change
(p_training_plan_member_id ota_training_plan_members.training_plan_member_id%type);

Procedure Update_tp_tpc_change
(p_training_plan_member_id ota_training_plan_members.training_plan_member_id%type,
 p_learning_path_ids OUT NOCOPY varchar2);

-- ---------------------------------------------------------------------------
-- |----------------------< update_tpc_enroll_status_chg >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    when Enrollment status to an event changes the TPC's status attached to the
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
--    The attached TPC's status is updated
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE update_tpc_enroll_status_chg (p_event_id  IN ota_events.event_id%TYPE,
                                        p_person_id IN ota_training_plans.person_id%TYPE,
					-- Modified for Bug#3479186
  				        p_contact_id IN ota_training_plans.contact_id%TYPE,
                                        p_learning_path_ids OUT NOCOPY varchar2);


-- ---------------------------------------------------------------------------
-- |----------------------< update_tpc_evt_date_change >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Training plan member status is updated when an event date is changed
--  called from ota_evt_upd.upd
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_event_id
--
--
--  Post Success:
--    The TPC's status is updated
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE update_tpc_evt_change (p_event_id IN ota_events.event_id%TYPE,
                                 p_course_start_date IN ota_events.course_start_date%TYPE,
                                 p_course_end_date IN ota_events.course_end_date%TYPE);


-- ----------------------------------------------------------------------------
-- ---------------------------< validate_TPC >-----------------------------
-- ----------------------------------------------------------------------------
Procedure validate_tpc
(  p_mode in varchar2
  ,p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     date
  ,p_business_group_id            IN     number
  ,p_training_plan_id             IN     number
  ,p_activity_version_id          IN     NUMBER    DEFAULT NULL
  ,p_activity_definition_id       IN     NUMBER    DEFAULT NULL
  ,p_member_status_type_id        IN     VARCHAR2
  ,p_target_completion_date       IN     date      DEFAULT NULL
  ,p_attribute_category           IN     VARCHAR2  DEFAULT NULL
  ,p_attribute1                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute2                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute3                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute4                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute5                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute6                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute7                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute8                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute9                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute10                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute11                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute12                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute13                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute14                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute15                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute16                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute17                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute18                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute19                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute20                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute21                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute22                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute23                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute24                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute25                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute26                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute27                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute28                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute29                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute30                  IN     VARCHAR2  DEFAULT NULL
  ,p_assignment_id                IN     NUMBER    DEFAULT NULL
  ,p_source_id                    IN     NUMBER    DEFAULT NULL
  ,p_source_function              IN     VARCHAR2  DEFAULT NULL
  ,p_cancellation_reason          IN     VARCHAR2  DEFAULT NULL
  ,p_earliest_start_date          IN     date      DEFAULT NULL
  ,p_training_plan_member_id      IN     number
  ,p_creator_person_id            IN    number
  ,p_object_version_NUMBER        IN OUT NOCOPY number
  ,p_return_status                OUT NOCOPY VARCHAR2);




END ota_trng_plan_comp_ss;


 

/
