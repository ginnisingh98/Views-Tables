--------------------------------------------------------
--  DDL for Package PQP_HRTCA_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_HRTCA_INTEGRATION" AUTHID CURRENT_USER AS
/* $Header: pqphrtcaintg.pkh 120.0 2005/05/29 02:22:00 appldev noship $ */


  TYPE t_per_addr IS TABLE OF per_addresses%ROWTYPE INDEX BY Binary_Integer;
  g_per_addr_rec  t_per_addr;

  TYPE oss_pp_rec IS RECORD
    (pp_rowid             Rowid
    ,passport_id          Number(15)
    ,passport_cntry_code  Varchar2(30)
    ,passport_number      Varchar2(150)
    ,passport_expiry_date Date
    ,attribute_category   Varchar2(150)
    ,attribute1           Varchar2(150)
    ,attribute2           Varchar2(150)
    ,attribute3           Varchar2(150)
    ,attribute4           Varchar2(150)
    ,attribute5           Varchar2(150)
    ,attribute6           Varchar2(150)
    ,attribute7           Varchar2(150)
    ,attribute8           Varchar2(150)
    ,attribute9           Varchar2(150)
    ,attribute10          Varchar2(150)
    ,attribute11          Varchar2(150)
    ,attribute12          Varchar2(150)
    ,attribute13          Varchar2(150)
    ,attribute14          Varchar2(150)
    ,attribute15          Varchar2(150)
    ,attribute16          Varchar2(150)
    ,attribute17          Varchar2(150)
    ,attribute18          Varchar2(150)
    ,attribute19          Varchar2(150)
    ,attribute20          Varchar2(150)
    );
  TYPE oss_visa_rec IS RECORD
    (visa_rowid           ROWID
    ,visa_id              Number(15)
    ,visa_type            Varchar2(30)
    ,visa_number          Varchar2(30)
    ,visa_issue_date      Date
    ,visa_expiry_date     Date
    ,visa_category        Varchar2(30)
    ,visa_issuing_post    Varchar2(30)
    ,passport_id          Number(15)
    ,agent_org_unit_cd    Varchar2(30)
    ,agent_person_id      Number(15)
    ,agent_contact_name   Varchar2(80)
    ,visa_issuing_country Varchar2(30)
    ,attribute_category   Varchar2(30)
    ,attribute1           Varchar2(150)
    ,attribute2           Varchar2(150)
    ,attribute3           Varchar2(150)
    ,attribute4           Varchar2(150)
    ,attribute5           Varchar2(150)
    ,attribute6           Varchar2(150)
    ,attribute7           Varchar2(150)
    ,attribute8           Varchar2(150)
    ,attribute9           Varchar2(150)
    ,attribute10          Varchar2(150)
    ,attribute11          Varchar2(150)
    ,attribute12          Varchar2(150)
    ,attribute13          Varchar2(150)
    ,attribute14          Varchar2(150)
    ,attribute15          Varchar2(150)
    ,attribute16          Varchar2(150)
    ,attribute17          Varchar2(150)
    ,attribute18          Varchar2(150)
    ,attribute19          Varchar2(150)
    ,attribute20          Varchar2(150)
    );
  TYPE Visit_Hist_Rec IS RECORD
    (row_id               ROWID
    ,port_of_entry        Varchar2(150)
    ,port_of_entry_m      Varchar2(150)
    ,cntry_entry_form_num Varchar2(150)
    ,visa_id              Number(10)
    ,visa_type            Varchar2(150)
    ,visa_number          Varchar2(150)
    ,visa_issue_date      Date
    ,visa_expiry_date     Date
    ,visa_category        Varchar2(150)
    ,visa_issuing_post    Varchar2(150)
    ,passport_id          Number(10)
    ,visit_start_date     Date
    ,visit_end_date       Date
    );

-- =============================================================================
-- ~ InsUpd_InHR_PassPort:
-- =============================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create the passport information for a given OSS
-- person based on the party_id in per_all_people_f.
--
-- Prerequisites:
--   Person must exits
--   Person Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   Business Group Id
--   p_person_id                    Yes  Number   per_all_people_f.person_id
--   p_party_id                     Yes  Number   per_all_people_f.party_id
--   p_effective_date               Yes  Date     Effective Date for the EIT
--   p_pp_error_code                Yes  Varchar2 returns the error code
--   p_passport_warning             Yes  Boolean  set to true when error occurs
-- Post Success:
--   The person extra info is created based on the passport information present
--   in OSS igs_pe_passport table.
--
-- Post Failure:
--   The API does not create the person extra info and sets the error code
--   and warning flag to TRUE.
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- =============================================================================
PROCEDURE InsUpd_InHR_PassPort
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_pp_error_code     OUT NOCOPY Varchar2
         ,p_passport_warning  OUT NOCOPY Boolean
        );
-- =============================================================================
-- InsUpd_InHR_Visa:
-- =============================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create the Visa information for a given OSS
-- person based on the party_id in per_all_people_f.
--
-- Prerequisites:
--   Person must exits
--   Person Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   Business Group Id
--   p_person_id                    Yes  Number   per_all_people_f.person_id
--   p_party_id                     Yes  Number   per_all_people_f.party_id
--   p_effective_date               Yes  Date     Effective Date for the EIT
--   p_visa_error_code              Yes  Varchar2 Returns the error code
--   p_visa_warning                 Yes  Boolean  Set to true when error occurs
-- Post Success:
--   The person extra info is created based on the Visa information present
--   in OSS igs_pe_visa table.
--
-- Post Failure:
--   The API does not create the person extra info and sets the error code
--   and warning flag to TRUE.
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- =============================================================================
PROCEDURE InsUpd_InHR_Visa
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_visa_error_code   OUT NOCOPY Varchar2
         ,p_visa_warning      OUT NOCOPY Boolean
          );
-- =============================================================================
-- InsUpd_InHR_Visit:
-- =============================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create the Visa Visit history for a given OSS
-- person based on the party_id in per_all_people_f.
--
-- Prerequisites:
--   Person must exits
--   Person Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   Business Group Id
--   p_person_id                    Yes  Number   per_all_people_f.person_id
--   p_party_id                     Yes  Number   per_all_people_f.party_id
--   p_effective_date               Yes  Date     Effective Date for the EIT
--   p_visit_error_code             Yes  Varchar2 Returns the error code
--   p_visit_warning                Yes  Boolean  Set to true when error occurs
-- Post Success:
--   The person extra info is created based on the Visa Visit history present
--   in OSS igs_pe_visit_histry_v view.
--
-- Post Failure:
--   The API does not create the person extra info and sets the error code
--   and warning flag to TRUE.
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- =============================================================================
PROCEDURE InsUpd_InHR_Visit
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_visit_error_code   OUT NOCOPY Varchar2
         ,p_visit_warning      OUT NOCOPY Boolean
          );
-- =============================================================================
-- InsUpd_InHR_OSSPerDtls:
-- =============================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create the OSS Person details for a given OSS
-- person based on the party_id in per_all_people_f.
--
-- Prerequisites:
--   Person must exits
--   Person Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   Business Group Id
--   p_person_id                    Yes  Number   per_all_people_f.person_id
--   p_party_id                     Yes  Number   per_all_people_f.party_id
--   p_effective_date               Yes  Date     Effective Date for the EIT
--   p_oss_error_code               Yes  Varchar2 Returns the error code
--   p_ossDtls_warning              Yes  Boolean  Set to true when error occurs
-- Post Success:
--   The person extra info is created based on the OSS Person details
--   in HZ_PARTIES, HZ_PERSON_PROFILES.
--
-- Post Failure:
--   The API does not create the person extra info and sets the error code
--   and warning flag to TRUE.
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- =============================================================================
PROCEDURE InsUpd_InHR_OSSPerDtls
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_oss_error_code    OUT NOCOPY Varchar2
         ,p_ossDtls_warning   OUT NOCOPY Boolean
          );
-- =============================================================================
-- ~ InsUpd_OSS_PassPort: Insert or update Passport details in OSS
-- =============================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create/update the Passport details in OSS when
-- a Passport info. is being created/updated in HRMS for a person who is also a
-- OSS Person, based on the Person EIT PQP_OSS_PERSON_DETAILS and
-- Synchronize OSS Data, must equal to Y. This API is called from the Row-Handler
-- hook for the table per_people_extra_info.
--
-- Prerequisites:
--   Person must exits
--   Person Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  Number   per_all_people_f.person_id
--   p_party_id                     Yes  Number   per_all_people_f.party_id
--   p_action                       Yes  Date     Effective Date for the EIT
--   p_pei_info_rec_old             Yes  per_people_extra_info%ROWTYPE
--   p_pei_info_rec_new             Yes  per_people_extra_info%ROWTYPE
-- Post Success:
--   The passport details for the OSS person is created/updated based on the
--   old and new value for the Person EIT in HRMS
--
-- Post Failure:
--   The API does not create the person passport details and will raise the
--   corresponding OSS error to the user.
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- =============================================================================
PROCEDURE InsUpd_OSS_PassPort
         (p_person_id        IN Number
         ,p_party_id         IN Number
         ,p_action           IN Varchar2
         ,p_pei_info_rec_old IN per_people_extra_info%ROWTYPE
         ,p_pei_info_rec_new IN per_people_extra_info%ROWTYPE
         );
-- ===========================================================================
-- ~ InsUpd_OSS_Visa: Insert or update Visa details in OSS
-- ===========================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create/update the Visa details in OSS when
-- a Visit info. is being created/updated in HRMS for a person who is also a
-- OSS Person, based on the Person EIT PQP_OSS_PERSON_DETAILS and
-- Synchronize OSS Data, must equal to Y. This API is called from the Row-Handler
-- hook for the table per_people_extra_info.
--
-- Prerequisites:
--   Person must exits
--   Person Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  Number   per_all_people_f.person_id
--   p_party_id                     Yes  Number   per_all_people_f.party_id
--   p_action                       Yes  Date     Effective Date for the EIT
--   p_pei_info_rec_old             Yes  per_people_extra_info%ROWTYPE
--   p_pei_info_rec_new             Yes  per_people_extra_info%ROWTYPE
-- Post Success:
--   The Visa details for the OSS person is created/updated based on the
--   old and new value for the Person Visa EIT in HRMS
--
-- Post Failure:
--   The API does not create the person Visa details and will raise the
--   corresponding OSS error to the user.
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- =============================================================================
PROCEDURE InsUpd_OSS_Visa
         (p_person_id        IN Number
         ,p_party_id         IN Number
         ,p_action           IN Varchar2
         ,p_pei_info_rec_old IN per_people_extra_info%ROWTYPE
         ,p_pei_info_rec_new IN per_people_extra_info%ROWTYPE
         );
-- =============================================================================
-- ~ InsUpd_OSS_VisitHstry: Insert or update Visa details in OSS
-- =============================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create/update the Visa Visit history in OSS when
-- a Visit history info. is being created/updated in HRMS for a person who is
-- also an OSS Person, based on the Person EIT PQP_OSS_PERSON_DETAILS and
-- Synchronize OSS Data, must equal to Y. This API is called from the Row-Handler
-- hook for the table per_people_extra_info.
--
-- Prerequisites:
--   Person must exits
--   Person Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  Number   per_all_people_f.person_id
--   p_party_id                     Yes  Number   per_all_people_f.party_id
--   p_action                       Yes  Date     Effective Date for the EIT
--   p_pei_info_rec_old             Yes  per_people_extra_info%ROWTYPE
--   p_pei_info_rec_new             Yes  per_people_extra_info%ROWTYPE
-- Post Success:
--   The Visa Visit history details for the OSS person is created/updated based
--   on the old and new value for the Person Visa EIT in HRMS
--
-- Post Failure:
--   The API does not create the person Visa Visit history details and will
--   raise the corresponding OSS error to the user.
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- =============================================================================
PROCEDURE InsUpd_OSS_VisitHistory
         (p_person_id        IN Number
         ,p_party_id         IN Number
         ,p_action           IN Varchar2
         ,p_pei_info_rec_old IN per_people_extra_info%ROWTYPE
         ,p_pei_info_rec_new IN per_people_extra_info%ROWTYPE
         );
-- =============================================================================
-- ~ InsUpd_Asg_Extra_info: Insert, Update or Delete Assignment Extra Info.
-- =============================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create/update/delete the Assignment Extra Info.
-- for a given assignment.
--
-- Prerequisites:
--   Person must a valid assignment.
--   Assignment Extra Information Type must be a valid one.
--
-- In Parameters:
--   Name                   Reqd Type     Description
--   p_assignment_id         Yes  Number   per_all_assignments_f.assignment_id
--   p_business_group_id     Yes  Number   per_all_assignments_f.business_group_id
--   p_validate              Yes  Boolean
--   p_action                Yes  Varchar2
--   p_extra_info_rec        Yes  per_assignment_extra_info%ROWTYPE
--
-- Post Success:
--   The Assignment Extra Information for the person is created/updated based
--   on the value of p_action(INSERT,UPDATE,DELETE) and the values must be
--   populated for the record structure.
--
-- Post Failure:
--   The API does not create/update/delete the assignment extra info type and
--   raises the corresponding error to the user.
--
-- Access Status:
--   Private.
-- =============================================================================
PROCEDURE InsUpd_Asg_Extra_info
         (p_assignment_id     IN Number
         ,p_business_group_id IN Number
         ,p_validate          IN Boolean DEFAULT FALSE
         ,p_action            IN Varchar2
         ,p_extra_info_rec    IN OUT NOCOPY per_assignment_extra_info%ROWTYPE
          );
-- =============================================================================
-- ~ InsUpd_Per_Extra_info: Insert, Update or Delete Person Extra Information
-- =============================================================================
-- {Start Of Comments}
--
-- Description: Use this API to create/update/delete the Person Extra Info.
-- for a given person id.
--
-- Prerequisites:
--   Person must a valid assignment.
--   Assignment Extra Information Type must be a valid one.
--
-- In Parameters:
--   Name                    Reqd Type     Description
--   p_person_id              Yes  Number   per_all_people_f.person_id
--   p_business_group_id      Yes  Number   per_all_people_f.business_group_id
--   p_validate               Yes  Boolean  Default false
--   p_action                 Yes  Varchar2 INSERT, UPDATE, DELETE
--   p_extra_info_rec         Yes  per_people_extra_info%ROWTYPE
-- Post Success:
--   The Person Extra Information for the person is created/updated/deleted
--   based on the value of p_action(INSERT,UPDATE,DELETE) and the values must be
--   populated for the record structure.
--
-- Post Failure:
--   The API does not create/update/delete the Person extra info type and
--   raises the corresponding error to the user.
-- Access Status:
--   Private.
-- =============================================================================
PROCEDURE InsUpd_Per_Extra_info
          (p_person_id         IN Number
          ,p_business_group_id IN Number
          ,p_validate          IN Boolean DEFAULT FALSE
          ,p_action            IN Varchar2
          ,p_extra_info_rec    IN OUT NOCOPY per_people_extra_info%ROWTYPE
           );
-- =============================================================================
-- ~ InsUpd_SIT_info:
-- =============================================================================
PROCEDURE InsUpd_SIT_info
         (p_person_id             IN Number
         ,p_business_group_id     IN Number
         ,p_validate              IN Boolean DEFAULT FALSE
         ,p_effective_date        IN Date
         ,p_action                IN Varchar2
         ,p_analysis_criteria_rec IN OUT NOCOPY per_analysis_criteria%ROWTYPE
         ,p_analyses_rec          IN OUT NOCOPY per_person_analyses%ROWTYPE
          );

-- =============================================================================
-- ~ Chk_Address_Style: Returns the address style to use based on the bus. group
-- ==================== legislation code and address country code of the TCA
-- ~ hz_locations.country. The [XX]_GLB address is used when a particular
-- ~ localization is not installed. In case the Address DDF does not have that
-- ~ country as context, then the GENERIC address style is returned.
-- =============================================================================
FUNCTION Chk_Address_Style
        (p_leg_code    IN Varchar2
        ,p_HZ_country  IN Varchar2
         ) RETURN Varchar2;

FUNCTION Chk_Address_Style
        (p_party_id    IN Number
        ,p_bus_grp_id  IN Number
         ) RETURN Varchar2;

FUNCTION Chk_Address_Style
        (p_leg_code          IN Varchar2
        ,p_HZ_country        IN Varchar2
        ,p_location_id       IN Number
        ,p_party_id          IN Number   DEFAULT NULL
        ,p_effective_date    IN Date     DEFAULT NULL
        ,p_business_group_id IN Number   DEFAULT NULL
        ,p_primary_flag      IN Varchar2 DEFAULT NULL
        ,p_party_site_id     IN Number   DEFAULT NULL
        ) RETURN Varchar2;

-- =============================================================================
-- ~ Get_Concat_HR_Address: Returns valid HR Address ina concat. string
-- =============================================================================
FUNCTION Get_Concat_HR_Address
        (p_location_id       IN Number
        ,p_party_id          IN Number   DEFAULT NULL
        ,p_effective_date    IN Date     DEFAULT NULL
        ,p_business_group_id IN Number   DEFAULT NULL
        ,p_primary_flag      IN Varchar2 DEFAULT NULL
        ,p_party_site_id     IN Number   DEFAULT NULL
         ) RETURN Varchar2;

FUNCTION Get_Segment
        (p_hzlocation_id      IN Number
        ,p_party_id           IN Number
        ,p_business_group_id  IN Number
        ,p_seg_name           IN Varchar2
        ) RETURN Varchar2;

-- =============================================================================
-- ~ Create_Address_TCA_To_HR:
-- =============================================================================
PROCEDURE Create_Address_TCA_To_HR
         (p_validate                IN Boolean  DEFAULT FALSE
         ,p_effective_date          IN Date
         ,p_party_id                IN Number
         ,p_business_group_id       IN Number   DEFAULT NULL
         ,p_party_site_id           IN Number   DEFAULT NULL
         ,p_style                   IN Varchar2 DEFAULT NULL
         ,p_location_id             IN Number   DEFAULT NULL
         ,p_pradd_ovlapval_override IN Boolean  DEFAULT FALSE
         ,p_validate_county         IN Boolean  DEFAULT TRUE
         ,p_primary_flag            IN Varchar2 DEFAULT 'Y'
         ,p_address_type            IN Varchar2 DEFAULT NULL
         ,p_overide_TCA_Mapping     IN Varchar2 DEFAULT 'N'
         --,p_HZ_Location_Rec         IN Hz_Location_V2pub.Location_Rec_Type DEFAULT NULL
         -- Out Variable from HR
         ,p_HR_address_id            OUT NOCOPY Number
         ,p_HR_object_version_number OUT NOCOPY Number
          );
-- =============================================================================
-- ~ Update_Address_TCA_To_HR
-- =============================================================================
PROCEDURE Update_Address_TCA_To_HR
         (p_validate                IN Boolean  DEFAULT FALSE
         ,p_effective_date          IN Date
         ,p_party_id                IN Number
         ,p_business_group_id       IN Number   DEFAULT NULL
         ,p_party_site_id           IN Number   DEFAULT NULL
         ,p_style                   IN Varchar2 DEFAULT NULL
         ,p_location_id             IN Number   DEFAULT NULL
         ,p_pradd_ovlapval_override IN Boolean  DEFAULT FALSE
         ,p_validate_county         IN Boolean  DEFAULT TRUE
         ,p_primary_flag            IN Varchar2 DEFAULT 'Y'
         ,p_address_type            IN Varchar2 DEFAULT NULL
         ,p_overide_TCA_Mapping     IN Varchar2 DEFAULT 'N'
         --,p_HZ_Location_Rec         IN Hz_Location_V2pub.Location_Rec_Type DEFAULT NULL
         -- Out Variable from HR
         ,p_HR_object_version_number IN OUT NOCOPY Number
          );
-- =============================================================================
-- Create_Address_HR_To_TCA: The API needs to be called only when a student
-- ======================== exists in HR as an employee and his address from
-- TCA needs to be created in HR.
-- Parameters
-- ==========
-- (a) IN
-- ======
--   (1) p_person_id           : Person_id from per_addresses table
--   (2) p_effective_date      : Effective date is the session date when the
--                               Address migration is to be done.
--   (3) p_party_id            : The Student party_id from hz_parties
--   (4) p_party_type          : Deafult to PERSON for Students
--   (5) p_action              : Default to INSERT i.e. creates a new record
--   (6) p_status              : Defalut to A = Active
--   (7) p_start_date          : Start Date of the address record. This is only
--                               specific to OSS and stores in the table
--                               igs_pe_hz_pty_sites.
--   (8) p_start_date          : End Date of the address record. This is only
--                               specific to OSS and stores in the table
--                               igs_pe_hz_pty_sites.
--   (9) p_country             : Two Char country code as in fnd_territories
--   (10) p_address_style      : Address Style if different from the country cd
--   (11) p_primary_add_flag   : Indicates the address is primary one.
--   (12) p_overide_HR_Address : If set to Y it would make use of records
--                               p_HZ_Location_Rec, p_HZ_Party_Site_Rec to
--                               Create the address for the party in TCA.
-- (b) In Out Variables
-- ====================
--   (1) p_location_id         : hz_locations.location_id
--   (2) p_party_site_id       : hz_party_sites.party_site_id
--   (3) p_last_update_date    : hz_locations.last_update_date
--   (4) p_party_site_ovn      : hz_party_sites.object_version_number
--   (5) p_location_ovn        : hz_locations.object_version_number
--   (6) p_rowid               : hz_locations.row_id
-- (c) Out Variables
-- =================
--   (1) p_return_status       : Return Status
--   (2) p_msg_data            : Message text in case of single error.
--
-- =============================================================================
PROCEDURE Create_Address_HR_To_TCA
         (p_business_group_id      IN Number
         ,p_person_id              IN Number
         ,p_party_id               IN Number
         ,p_address_id             IN Number
         ,p_effective_date         IN Date
         ,p_per_addr_rec_new       IN per_addresses%ROWTYPE
         -- TCA
         ,p_party_type             IN Varchar2
         ,p_action                 IN Varchar2
         ,p_status                 IN hz_party_sites.status%TYPE
         -- In Out Variables
         ,p_location_id            IN OUT NOCOPY Number
         ,p_party_site_id          IN OUT NOCOPY Number
         ,p_last_update_date       IN OUT NOCOPY Date
         ,p_party_site_ovn         IN OUT NOCOPY Number
         ,p_location_ovn           IN OUT NOCOPY Number
         ,p_rowid                  IN OUT NOCOPY Varchar2
         -- Out Variables
         ,p_return_status          OUT NOCOPY Varchar2
         ,p_msg_data               OUT NOCOPY Varchar2
         );

-- =============================================================================
-- Update_Address_HR_To_TCA: The API needs to be called only when a student
-- ======================== exists in HR as an employee and his address from
-- TCA needs to be created in HR.
-- Parameters
-- ==========
-- (a) IN
-- ======
--   (1) p_person_id           : Person_id from per_addresses table
--   (2) p_effective_date      : Effective date is the session date when the
--                               Address migration is to be done.
--   (3) p_party_id            : The Student party_id from hz_parties
--   (4) p_party_type          : Deafult to PERSON for Students
--   (5) p_action              : Default to UPDATE i.e. updates existing record
--   (6) p_status              : Defalut to A = Active
--   (7) p_start_date          : Start Date of the address record. This is only
--                               specific to OSS and stores in the table
--                               igs_pe_hz_pty_sites.
--   (8) p_start_date          : End Date of the address record. This is only
--                               specific to OSS and stores in the table
--                               igs_pe_hz_pty_sites.
--   (9) p_country             : Two Char country code as in fnd_territories
--   (10) p_address_style      : Address Style if different from the country cd
--   (11) p_primary_add_flag   : Indicates the address is primary one.
--   (12) p_overide_HR_Address : If set to Y it would make use of records
--                               p_HZ_Location_Rec, p_HZ_Party_Site_Rec to
--                               Create the address for the party in TCA.
-- (b) In Out Variables
-- ====================
--   (1) p_location_id         : hz_locations.location_id
--   (2) p_party_site_id       : hz_party_sites.party_site_id
--   (3) p_last_update_date    : hz_locations.last_update_date
--   (4) p_party_site_ovn      : hz_party_sites.object_version_number
--   (5) p_location_ovn        : hz_locations.object_version_number
--   (6) p_rowid               : hz_locations.row_id
-- (c) Out Variables
-- =================
--   (1) p_return_status       : Return Status
--   (2) p_msg_data            : Message text in case of single error.
--
-- =============================================================================
PROCEDURE Update_Address_HR_To_TCA
         (p_business_group_id      IN Number
         ,p_person_id              IN Number
         ,p_party_id               IN Number
         ,p_address_id             IN Number
         ,p_effective_date         IN Date
         ,p_per_addr_rec_new       IN per_addresses%ROWTYPE
         ,p_per_addr_rec_old       IN per_addresses%ROWTYPE
         -- TCA
         ,p_party_type             IN Varchar2 DEFAULT 'PERSON'
         ,p_action                 IN Varchar2 DEFAULT 'UPDATE'
         ,p_status                 IN Varchar2 DEFAULT 'A'
         -- In Out Variables
         ,p_location_id            IN OUT NOCOPY Number
         ,p_party_site_id          IN OUT NOCOPY Number
         ,p_last_update_date       IN OUT NOCOPY Date
         ,p_party_site_ovn         IN OUT NOCOPY Number
         ,p_location_ovn           IN OUT NOCOPY Number
         ,p_rowid                  IN OUT NOCOPY Varchar2
         -- Out Variables
         ,p_return_status          OUT NOCOPY Varchar2
         ,p_msg_data               OUT NOCOPY Varchar2
         );
-- =============================================================================
-- Person_Address_API:
-- =============================================================================
PROCEDURE Person_Address_API
         (p_HR_Address_Rec           IN OUT NOCOPY Per_Addresses%ROWTYPE
         ,p_validate                 IN Boolean  DEFAULT FALSE
         ,p_action                   IN Varchar2 DEFAULT 'CREATE'
         ,p_effective_date           IN Date
         ,p_pradd_ovlapval_override  IN Boolean  DEFAULT FALSE
         ,p_validate_county          IN Boolean  DEFAULT TRUE
         ,p_primary_flag             IN Varchar2 DEFAULT 'Y'
         ,p_HR_address_id            OUT NOCOPY Number
         ,p_HR_object_version_number OUT NOCOPY Number);

-- =============================================================================
-- ~ Chk_OSS_Install: Check to see if the OSS product is installed or not. This
-- ~ check is req. before launching the student search page.
-- =============================================================================
Function Chk_OSS_Install
         Return Varchar2;

END PQP_HRTCA_Integration;

 

/
