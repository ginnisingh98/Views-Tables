--------------------------------------------------------
--  DDL for Package IGS_PE_PERSON_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERSON_SS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPE10S.pls 120.3 2005/09/22 23:51:39 appldev ship $ */

/*  +=======================================================================+
    |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
    |                         All rights reserved.                          |
    +=======================================================================+
    who       when            what
    gmaheswa  10-Nov-2003     Bug 3223043 HZ.K Impact Changes .
                              Added 3 new columns to update_employment
    asbala    12-nov-03       3227107: address changes - signature of igs_pe_person_addr_pkg.insert_row and update_row changed
		              signature of igs_pe_person_ss_pkg.update_address now includes 3 new parameters
  --skpandey  21-SEP-2005     Bug: 3663505
  --                          Description: Added ATTRIBUTES 21 TO 24 TO STORE ADDITIONAL INFORMATION
*/

PROCEDURE Update_Privacy(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  x_privacy_level_id  OUT NOCOPY  NUMBER,
  p_mode           IN   VARCHAR2,
  p_person_id         IN   NUMBER,
  p_privacy_level_id  IN   NUMBER,
  p_data_group_id     IN   NUMBER,
  p_data_group        IN   VARCHAR2,
  p_lvl               IN   VARCHAR2,
  p_action            IN   VARCHAR2,
  p_whom              IN   VARCHAR2,
  p_start_date	      IN   DATE,
  p_end_date          IN   DATE
);


PROCEDURE Update_Person(
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  p_person_id         IN   NUMBER,
  p_suffix            IN   VARCHAR2,
  p_middle_name       IN   VARCHAR2,
  p_pre_name_adjunct  IN   VARCHAR2,
  p_sex               IN   VARCHAR2,
  p_title             IN   VARCHAR2,
  p_birth_dt	      IN   DATE,
  p_preferred_name    IN   VARCHAR2,
  p_api_person_id     IN   VARCHAR2,
  p_hz_parties_ovn    IN OUT NOCOPY NUMBER,
  p_attribute_category IN  VARCHAR2,
  p_attribute1        IN   VARCHAR2,
  p_attribute2        IN   VARCHAR2,
  p_attribute3        IN   VARCHAR2,
  p_attribute4        IN   VARCHAR2,
  p_attribute5        IN   VARCHAR2,
  p_attribute6        IN   VARCHAR2,
  p_attribute7        IN   VARCHAR2,
  p_attribute8        IN   VARCHAR2,
  p_attribute9        IN   VARCHAR2,
  p_attribute10       IN   VARCHAR2,
  p_attribute11       IN   VARCHAR2,
  p_attribute12       IN   VARCHAR2,
  p_attribute13       IN   VARCHAR2,
  p_attribute14       IN   VARCHAR2,
  p_attribute15       IN   VARCHAR2,
  p_attribute16       IN   VARCHAR2,
  p_attribute17       IN   VARCHAR2,
  p_attribute18       IN   VARCHAR2,
  p_attribute19       IN   VARCHAR2,
  p_attribute20       IN   VARCHAR2,
  p_attribute21       IN   VARCHAR2 DEFAULT NULL,
  p_attribute22       IN   VARCHAR2 DEFAULT NULL,
  p_attribute23       IN   VARCHAR2 DEFAULT NULL,
  p_attribute24       IN   VARCHAR2 DEFAULT NULL
);

PROCEDURE Update_Contact(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  x_id                OUT NOCOPY  NUMBER,
  p_mode               IN   VARCHAR2,
  p_person_id          IN   NUMBER,
  p_contact_point_id   IN   NUMBER,
  p_contact_point_ovn  IN OUT NOCOPY NUMBER,
  p_status             IN   VARCHAR2,
  p_primary_flag       IN   VARCHAR2,
  p_phone_area_code    IN   VARCHAR2,
  p_phone_country_code IN   VARCHAR2,
  p_phone_number       IN   VARCHAR2,
  p_phone_extension    IN   VARCHAR2,
  p_phone_line_type    IN   VARCHAR2,
  p_email_format       IN   VARCHAR2,
  p_email_address      IN   VARCHAR2
);

PROCEDURE Update_Address(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  x_id                OUT NOCOPY  NUMBER,
  p_mode              IN   VARCHAR2,
  p_person_id         IN   NUMBER,
  p_location_id       IN   NUMBER,
  p_start_dt          IN   DATE,
  p_end_dt            IN   DATE,
  p_party_site_id     IN   NUMBER,
  p_addr_line_1       IN   VARCHAR2,
  p_addr_line_2       IN   VARCHAR2,
  p_addr_line_3       IN   VARCHAR2,
  p_addr_line_4       IN   VARCHAR2,
  p_city              IN   VARCHAR2,
  p_state             IN   VARCHAR2,
  p_province          IN   VARCHAR2,
  p_county            IN   VARCHAR2,
  p_country           IN   VARCHAR2,
  p_country_cd        IN   VARCHAR2,
  p_postal_code       IN   VARCHAR2,
  p_ident_addr_flag   IN   VARCHAR2,
  p_location_ovn      IN OUT NOCOPY hz_locations.object_version_number%TYPE,
  p_party_site_ovn    IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
  p_status	      IN   hz_party_sites.status%TYPE
);




PROCEDURE Update_Usage(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  x_id                OUT NOCOPY  NUMBER,
  p_mode              IN   VARCHAR2,
  p_party_site_use_id IN   NUMBER,
  p_party_site_id     IN   NUMBER,
  p_site_use_type     IN   VARCHAR2,
  p_location          IN   VARCHAR2,
  p_site_use_id       IN   NUMBER,
  p_active            IN   VARCHAR2,
  p_hz_party_site_use_ovn IN OUT NOCOPY NUMBER
);


PROCEDURE Update_Employment(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  x_id                OUT NOCOPY  NUMBER,
  p_mode                  IN   VARCHAR2,
  p_person_id             IN   NUMBER,
  p_employment_history_id IN   NUMBER,
  p_start_dt              IN   DATE,
  p_end_dt                IN   DATE,
  p_position              IN   VARCHAR2,
  p_weekly_work_hours     IN   NUMBER,
  p_comments              IN   VARCHAR2,
  p_employer              IN   VARCHAR2,
  p_employed_by_division_name IN   VARCHAR2,
  p_object_version_number IN OUT NOCOPY NUMBER,
  p_employed_by_party_id  IN   NUMBER,
  p_reason_for_leaving    IN   VARCHAR2,
  p_type_of_employment    IN   VARCHAR2,
  p_tenure_of_employment  IN   VARCHAR2
);


PROCEDURE Update_Emergency(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  x_id                OUT NOCOPY  NUMBER,
  p_mode           IN   VARCHAR2,
  p_em_person_id      IN   NUMBER,
  p_person_id         IN   NUMBER,
  p_given_name        IN   VARCHAR2,
  p_surname           IN   VARCHAR2,
  p_middle_name       IN   VARCHAR2,
  p_preferred_name    IN   VARCHAR2,
  p_birthdate         IN   DATE,
  p_pre_name_adjunct  IN   VARCHAR2,
  p_suffix            IN   VARCHAR2,
  p_title             IN   VARCHAR2,
  p_rel_end           IN   VARCHAR2 DEFAULT 'N',
  p_hz_parties_ovn    IN OUT NOCOPY NUMBER,
  p_hz_rel_ovn        IN  OUT NOCOPY NUMBER
);



PROCEDURE Update_Dates(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  p_person_id         IN   NUMBER,
  p_course_cd         IN   VARCHAR2,
  p_version_number    IN   NUMBER,
  p_nom_year          IN   VARCHAR2,
  p_nom_period        IN   VARCHAR2,
  p_action	      IN   VARCHAR2
);

FUNCTION Get_Relationship_type
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_Relationship_type,WNDS,RNDS,WNPS,RNPS);

PROCEDURE Update_Biographic (
  P_PERSON_ID   IN NUMBER,
  P_ETHNICITY   IN VARCHAR2,
  P_MARITAL_STATUS IN VARCHAR2,
  P_MARITAL_STATUS_DATE IN DATE,
  P_BIRTH_CITY  IN VARCHAR2,
  P_BIRTH_COUNTRY IN VARCHAR2,
  P_VETERAN     IN VARCHAR2,
  P_RELIGION_CD IN VARCHAR2,
  P_HZ_OVN  IN NUMBER,
  P_RETURN_STATUS  OUT NOCOPY VARCHAR2,
  P_MSG_COUNT      OUT NOCOPY NUMBER,
  P_MSG_DATA       OUT NOCOPY VARCHAR2,
  P_CALLER		   IN VARCHAR2 default null
);

PROCEDURE CREATEUPDATE_PERS_ALTID (
 P_ACTION         IN         VARCHAR2,
 P_PE_PERSON_ID     IN NUMBER,
 P_API_PERSON_ID   IN VARCHAR2,
 P_PERSON_ID_TYPE IN VARCHAR2,
 P_START_DT         IN     DATE,
 P_END_DT         IN          DATE,
 P_ATTRIBUTE_CATEGORY IN VARCHAR2,
 P_ATTRIBUTE1     IN VARCHAR2,
 P_ATTRIBUTE2     IN VARCHAR2,
 P_ATTRIBUTE3     IN VARCHAR2,
 P_ATTRIBUTE4     IN VARCHAR2,
 P_ATTRIBUTE5     IN VARCHAR2,
 P_ATTRIBUTE6     IN VARCHAR2,
 P_ATTRIBUTE7     IN VARCHAR2,
 P_ATTRIBUTE8     IN VARCHAR2,
 P_ATTRIBUTE9     IN VARCHAR2,
 P_ATTRIBUTE10     IN VARCHAR2,
 P_ATTRIBUTE11     IN VARCHAR2,
 P_ATTRIBUTE12     IN VARCHAR2,
 P_ATTRIBUTE13     IN VARCHAR2,
 P_ATTRIBUTE14     IN VARCHAR2,
 P_ATTRIBUTE15     IN VARCHAR2,
 P_ATTRIBUTE16     IN VARCHAR2,
 P_ATTRIBUTE17     IN VARCHAR2,
 P_ATTRIBUTE18     IN VARCHAR2,
 P_ATTRIBUTE19     IN VARCHAR2,
 P_ATTRIBUTE20     IN VARCHAR2,
 P_REGION_CD         IN VARCHAR2,
 P_RETURN_STATUS OUT NOCOPY VARCHAR2,
 P_MSG_COUNT OUT NOCOPY NUMBER,
 P_MSG_DATA    OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_TEST_RESULT_DETAILS (
 P_TEST_SEGMENT_ID IN NUMBER,
 P_TEST_RESULT_ID IN NUMBER,
 P_TEST_SCORE IN NUMBER,
 P_RETURN_STATUS OUT NOCOPY VARCHAR2,
 P_MSG_COUNT OUT NOCOPY NUMBER,
 P_MSG_DATA    OUT NOCOPY VARCHAR2
 );

PROCEDURE CREATEUPDATE_RELATIONSHIP (
  P_MODE                       IN   VARCHAR2,
  P_RETURN_STATUS   OUT NOCOPY VARCHAR2,
  P_MSG_COUNT           OUT NOCOPY NUMBER,
  P_MSG_DATA              OUT NOCOPY VARCHAR2,
  P_RELATIONSHIP_ID IN OUT NOCOPY NUMBER,
  P_DIRECTIONAL_FLAG IN VARCHAR2,
  P_SUBJECT_ID           IN   NUMBER,
  P_OBJECT_ID          IN OUT NOCOPY NUMBER,
  P_FIRST_NAME         IN   VARCHAR2,
  P_LAST_NAME          IN   VARCHAR2,
  P_MIDDLE_NAME    IN   VARCHAR2,
  P_PREFERRED_NAME    IN   VARCHAR2,
  P_BIRTHDATE           IN   DATE,
  P_PRE_NAME_ADJUNCT IN   VARCHAR2,
  P_SUFFIX            IN   VARCHAR2,
  P_TITLE               IN   VARCHAR2,
  P_HZ_PARTIES_OVN    IN OUT NOCOPY NUMBER,
  P_HZ_REL_OVN             IN OUT NOCOPY NUMBER,
  P_JOINT_MAILING IN VARCHAR2,
  P_NEXT_OF_KIN     IN VARCHAR2,
  P_EMERGENCY_CONTACT IN VARCHAR2,
  P_DECEASED           IN VARCHAR2,
  P_GENDER                IN VARCHAR2,
  P_MARITAL_STATUS IN VARCHAR2,
  P_REP_FACULTY        IN VARCHAR2,
  P_REP_STAFF               IN VARCHAR2,
  P_REP_STUDENT        IN VARCHAR2,
  P_REP_ALUMNI          IN VARCHAR2,
  P_REL_START_DATE IN DATE,
  P_REL_END_DATE     IN DATE,
  P_REL_CODE               IN VARCHAR2,
  P_COPY_PRIMARY_ADDR IN VARCHAR2
);



END IGS_PE_PERSON_SS_PKG;

 

/
