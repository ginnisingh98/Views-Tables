--------------------------------------------------------
--  DDL for Package HR_APPLICANT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peaplbsi.pkh 120.1 2005/10/25 00:28 risgupta noship $ */
--
-- These procedures are for internal use. Only by Development.
-- -------------------------------------------------------------------------- +
-- |--------------------< create_applicant_anytime >------------------------- |
-- -------------------------------------------------------------------------- +
-- This creates an application with default information and transforms
-- an existing person into an applicant.
--
-- To create a new person as an applicant then use the
-- hr_applicant_api.create_applicant() API
--
procedure create_applicant_anytime
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_applicant_number              in out nocopy varchar2
  ,p_per_object_version_number     in out nocopy number
  ,p_vacancy_id                    in     number
  ,p_person_type_id                in     number
  ,p_assignment_status_type_id     in     number
  ,p_application_id                   out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy DATE
  ,p_appl_override_warning            OUT NOCOPY boolean
  );
-- ------------------------------------------------------------------------- +
-- --------------------< override_future_applications >--------------------- |
-- ------------------------------------------------------------------------- +
-- Returns 'Y' if future applications exist; otherwise returns 'N'
--
FUNCTION override_future_applications
   (p_person_id      IN NUMBER
   ,p_effective_date IN DATE
   )  RETURN VARCHAR2;
-- ------------------------------------------------------------------------- +
-- --------------------< future_apl_asg_exist >----------------------------- |
-- ------------------------------------------------------------------------- +
-- Returns 'Y' if future applicant assignments exist; otherwise returns 'N'
--
FUNCTION future_apl_asg_exist
   (p_person_id         IN NUMBER
   ,p_effective_date    IN DATE
   ,p_application_id    IN NUMBER
   ) RETURN VARCHAR2;
-- ------------------------------------------------------------------------- +
-- -----------------------< Update_PER_PTU_Records >------------------------ |
-- ------------------------------------------------------------------------- +
-- Updates the Person and PTU records when tranforming the person into an
-- applicant.
--
PROCEDURE Update_PER_PTU_Records
   (p_business_group_id         IN number
   ,p_person_id                 IN number
   ,p_effective_date            IN date
   ,p_applicant_number          IN varchar2
   ,p_APL_person_type_id        IN number
   ,p_per_effective_start_date  out nocopy date
   ,p_per_effective_end_date    out nocopy DATE
   ,p_per_object_version_number in out nocopy number -- BUG4081676
   );

-- ------------------------------------------------------------------------- +
-- -----------------------< Update_PER_PTU_to_EX_APL >---------------------- |
-- ------------------------------------------------------------------------- +
-- Updates the Person and PTU records when tranforming the person into an
-- ex-applicant.
--
PROCEDURE Update_PER_PTU_to_EX_APL
   (p_business_group_id         IN number
   ,p_person_id                 IN number
   ,p_effective_date            IN date
   ,p_person_type_id            IN number
   ,p_per_effective_start_date  out nocopy date
   ,p_per_effective_end_date    out nocopy DATE
   );

-- ------------------------------------------------------------------------- +
-- ---------------------< Upd_person_EX_APL_and_APL >----------------------- |
-- ------------------------------------------------------------------------- +
-- Updates the Person and PTU records when tranforming the person into an
-- ex-applicant and applicant.
--
PROCEDURE Upd_person_EX_APL_and_APL
   (p_business_group_id         IN number
   ,p_person_id                 IN number
   ,p_ex_apl_effective_date     IN date   -- date person becomes EX_APL
   ,p_apl_effective_date        IN date   -- date person becomes APL
   ,p_per_effective_start_date  out nocopy date
   ,p_per_effective_end_date    out nocopy DATE
   );
-- -------------------------------------------------------------------------- +
-- |--------------------< Update_APL_Assignments >--------------------------- |
-- -------------------------------------------------------------------------- +
-- Updates the applicant assignments to reflect new application ID
--
PROCEDURE Update_APL_Assignments
   (p_business_group_id         IN number
   ,p_old_application_id        IN number
   ,p_new_application_id        IN number
   );

-- -------------------------------------------------------------------------- +
-- |----------------------< create_application >----------------------------- |
-- -------------------------------------------------------------------------- +
-- Creates the application based on current status of the person.
--
PROCEDURE Create_Application
          (p_application_id            OUT nocopy   number
          ,p_business_group_id         IN           number
          ,p_person_id                 IN           number
          ,p_effective_date            IN           date
          ,p_date_received             OUT nocopy   date
          ,p_object_version_number     OUT nocopy   number
          ,p_appl_override_warning     OUT nocopy   boolean
          ,p_validate_df_flex          IN           boolean default true -- bug 4689836
          ) ;
--
-- ------------------------------------------------------------------------ +
-- -------------------< generate_applicant_number >------------------------ |
-- ------------------------------------------------------------------------ +
procedure generate_applicant_number
  (p_business_group_id  IN  NUMBER
  ,p_person_id          IN  NUMBER
  ,p_effective_date     IN  DATE
  ,p_party_id           IN  NUMBER
  ,p_date_of_birth      IN  DATE
  ,p_start_date         IN  DATE
  ,p_applicant_number   IN OUT NOCOPY VARCHAR2);
--
end hr_applicant_internal;

 

/
