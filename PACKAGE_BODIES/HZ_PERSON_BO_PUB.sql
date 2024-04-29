--------------------------------------------------------
--  DDL for Package Body HZ_PERSON_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PERSON_BO_PUB" AS
/*$Header: ARHBPPBB.pls 120.25.12010000.8 2009/10/28 18:03:20 awu ship $ */

  -- PRIVATE PROCEDURE assign_person_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from person business object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_person_obj         Person business object.
  --     p_person_id          Person ID.
  --     p_person_os          Person orig system.
  --     p_person_osr         Person orig system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_person_rec        Person plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_person_rec(
    p_person_obj                 IN            HZ_PERSON_BO,
    p_person_id                  IN            NUMBER,
    p_person_os                  IN            VARCHAR2,
    p_person_osr                 IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_person_rec                IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_person_lang_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from person language object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_person_lang_obj    Person language object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_person_lang_rec   Person language plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_person_lang_rec(
    p_person_lang_obj            IN            HZ_PERSON_LANG_OBJ,
    p_party_id                   IN            NUMBER,
    px_person_lang_rec           IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_education_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from education object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_education_obj      Education object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_education_rec     Education plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_education_rec(
    p_education_obj              IN            HZ_EDUCATION_OBJ,
    p_party_id                   IN            NUMBER,
    px_education_rec             IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_citizenship_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from citizenship object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_citizenship_obj    Citizenship object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_citizenship_rec   Citizenship plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_citizenship_rec(
    p_citizenship_obj            IN            HZ_CITIZENSHIP_OBJ,
    p_party_id                   IN            NUMBER,
    px_citizenship_rec           IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_employ_hist_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from employment history object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_employ_hist_obj    Employment history object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_employ_hist_rec   Employment history plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_employ_hist_rec(
    p_employ_hist_obj            IN            HZ_EMPLOY_HIST_BO,
    p_party_id                   IN            NUMBER,
    px_employ_hist_rec           IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_work_class_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from work class object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_work_class_obj     Work class object.
  --     p_employ_hist_id     Employment history ID.
  --   IN/OUT:
  --     px_work_class_rec    Work class plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_work_class_rec(
    p_work_class_obj             IN            HZ_WORK_CLASS_OBJ,
    p_employ_hist_id             IN            NUMBER,
    px_work_class_rec            IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_interest_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from person interest object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_work_class_obj     Person interest object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_person_interest_rec    Person interest plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_interest_rec(
    p_person_interest_obj        IN            HZ_PERSON_INTEREST_OBJ,
    p_party_id                   IN            NUMBER,
    px_person_interest_rec       IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE
  );

  -- PRIVATE PROCEDURE create_person_info
  --
  -- DESCRIPTION
  --     Create person information, such as language, education, citizenship,
  --     employment history and interest
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_language_obj       Person language object.
  --     p_education_obj      Education object.
  --     p_citizenship_obj    Citizenship object.
  --     p_employ_hist_obj    Employment history object.
  --     p_interest_obj       Person interest object.
  --     p_party_id           Party ID.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_person_info(
    p_language_obj               IN OUT NOCOPY HZ_PERSON_LANG_OBJ_TBL,
    p_education_obj              IN OUT NOCOPY HZ_EDUCATION_OBJ_TBL,
    p_citizenship_obj            IN OUT NOCOPY HZ_CITIZENSHIP_OBJ_TBL,
    p_employ_hist_obj            IN OUT NOCOPY HZ_EMPLOY_HIST_BO_TBL,
    p_interest_obj               IN OUT NOCOPY HZ_PERSON_INTEREST_OBJ_TBL,
    p_person_id                  IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PRIVATE PROCEDURE save_person_info
  --
  -- DESCRIPTION
  --     Create or update person information, such as language, education, citizenship,
  --     employment history and interest
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_language_obj       Person language object.
  --     p_education_obj      Education object.
  --     p_citizenship_obj    Citizenship object.
  --     p_employ_hist_obj    Employment history object.
  --     p_interest_obj       Person interest object.
  --     p_party_id           Party ID.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_person_info(
    p_language_obj               IN OUT NOCOPY HZ_PERSON_LANG_OBJ_TBL,
    p_education_obj              IN OUT NOCOPY HZ_EDUCATION_OBJ_TBL,
    p_citizenship_obj            IN OUT NOCOPY HZ_CITIZENSHIP_OBJ_TBL,
    p_employ_hist_obj            IN OUT NOCOPY HZ_EMPLOY_HIST_BO_TBL,
    p_interest_obj               IN OUT NOCOPY HZ_PERSON_INTEREST_OBJ_TBL,
    p_person_id                  IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PRIVATE PROCEDURE assign_person_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from person business object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_person_obj         Person business object.
  --     p_person_id          Person ID.
  --     p_person_os          Person orig system.
  --     p_person_osr         Person orig system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_person_rec        Person plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_person_rec(
    p_person_obj                 IN            HZ_PERSON_BO,
    p_person_id                  IN            NUMBER,
    p_person_os                  IN            VARCHAR2,
    p_person_osr                 IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_person_rec                IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE
  ) IS
  BEGIN
    px_person_rec.person_pre_name_adjunct := p_person_obj.person_pre_name_adjunct;
    px_person_rec.person_first_name := p_person_obj.person_first_name;
    px_person_rec.person_middle_name := p_person_obj.person_middle_name;
    px_person_rec.person_last_name := p_person_obj.person_last_name;
    px_person_rec.person_name_suffix := p_person_obj.person_name_suffix;
    px_person_rec.person_title := p_person_obj.person_title;
    px_person_rec.person_academic_title := p_person_obj.person_academic_title;
    px_person_rec.person_previous_last_name := p_person_obj.person_previous_last_name;
    px_person_rec.person_initials := p_person_obj.person_initials;
    px_person_rec.known_as  := p_person_obj.known_as;
    px_person_rec.known_as2 := p_person_obj.known_as2;
    px_person_rec.known_as3 := p_person_obj.known_as3;
    px_person_rec.known_as4 := p_person_obj.known_as4;
    px_person_rec.known_as5 := p_person_obj.known_as5;
    px_person_rec.person_name_phonetic := p_person_obj.person_name_phonetic;
    px_person_rec.person_first_name_phonetic := p_person_obj.person_first_name_phonetic;
    px_person_rec.person_last_name_phonetic := p_person_obj.person_last_name_phonetic;
    px_person_rec.middle_name_phonetic := p_person_obj.middle_name_phonetic;
    px_person_rec.tax_reference := p_person_obj.tax_reference;
    px_person_rec.jgzz_fiscal_code := p_person_obj.jgzz_fiscal_code;
    px_person_rec.person_iden_type := p_person_obj.person_iden_type;
    px_person_rec.person_identifier := p_person_obj.person_identifier;
    px_person_rec.date_of_birth := p_person_obj.date_of_birth;
    px_person_rec.place_of_birth := p_person_obj.place_of_birth;
    px_person_rec.date_of_death := p_person_obj.date_of_death;
    IF(p_person_obj.deceased_flag in ('Y','N')) THEN
      px_person_rec.deceased_flag := p_person_obj.deceased_flag;
    END IF;
    px_person_rec.gender := p_person_obj.gender;
    px_person_rec.declared_ethnicity := p_person_obj.declared_ethnicity;
    px_person_rec.marital_status := p_person_obj.marital_status;
    px_person_rec.marital_status_effective_date := p_person_obj.marital_status_eff_date;
    px_person_rec.personal_income := p_person_obj.personal_income;
    IF(p_person_obj.head_of_household_flag in ('Y','N')) THEN
      px_person_rec.head_of_household_flag := p_person_obj.head_of_household_flag;
    END IF;
    px_person_rec.household_income := p_person_obj.household_income;
    px_person_rec.household_size := p_person_obj.household_size;
    px_person_rec.rent_own_ind := p_person_obj.rent_own_ind;
    px_person_rec.last_known_gps:= p_person_obj.last_known_gps;
    px_person_rec.internal_flag:= p_person_obj.internal_flag;
    IF(p_create_or_update = 'C') THEN
      px_person_rec.party_rec.orig_system:= p_person_os;
      px_person_rec.party_rec.orig_system_reference:= p_person_osr;
      px_person_rec.created_by_module:= HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_person_rec.actual_content_source:= p_person_obj.actual_content_source;
    px_person_rec.party_rec.party_id:= p_person_id;
    px_person_rec.party_rec.party_number:= p_person_obj.party_number;
    px_person_rec.party_rec.validated_flag:= p_person_obj.validated_flag;
    IF(p_person_obj.status in ('A','I')) THEN
      px_person_rec.party_rec.status:= p_person_obj.status;
    END IF;
    px_person_rec.party_rec.category_code:= p_person_obj.category_code;
    px_person_rec.party_rec.salutation:= p_person_obj.salutation;
    px_person_rec.party_rec.attribute_category:= p_person_obj.attribute_category;
    px_person_rec.party_rec.attribute1:= p_person_obj.attribute1;
    px_person_rec.party_rec.attribute2:= p_person_obj.attribute2;
    px_person_rec.party_rec.attribute3:= p_person_obj.attribute3;
    px_person_rec.party_rec.attribute4:= p_person_obj.attribute4;
    px_person_rec.party_rec.attribute5:= p_person_obj.attribute5;
    px_person_rec.party_rec.attribute6:= p_person_obj.attribute6;
    px_person_rec.party_rec.attribute7:= p_person_obj.attribute7;
    px_person_rec.party_rec.attribute8:= p_person_obj.attribute8;
    px_person_rec.party_rec.attribute9:= p_person_obj.attribute9;
    px_person_rec.party_rec.attribute10:= p_person_obj.attribute10;
    px_person_rec.party_rec.attribute11:= p_person_obj.attribute11;
    px_person_rec.party_rec.attribute12:= p_person_obj.attribute12;
    px_person_rec.party_rec.attribute13:= p_person_obj.attribute13;
    px_person_rec.party_rec.attribute14:= p_person_obj.attribute14;
    px_person_rec.party_rec.attribute15:= p_person_obj.attribute15;
    px_person_rec.party_rec.attribute16:= p_person_obj.attribute16;
    px_person_rec.party_rec.attribute17:= p_person_obj.attribute17;
    px_person_rec.party_rec.attribute18:= p_person_obj.attribute18;
    px_person_rec.party_rec.attribute19:= p_person_obj.attribute19;
    px_person_rec.party_rec.attribute20:= p_person_obj.attribute20;
    px_person_rec.party_rec.attribute21:= p_person_obj.attribute21;
    px_person_rec.party_rec.attribute22:= p_person_obj.attribute22;
    px_person_rec.party_rec.attribute23:= p_person_obj.attribute23;
    px_person_rec.party_rec.attribute24:= p_person_obj.attribute24;
  END assign_person_rec;

  -- PRIVATE PROCEDURE assign_person_lang_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from person language object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_person_lang_obj    Person language object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_person_lang_rec   Person language plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_person_lang_rec(
    p_person_lang_obj            IN            HZ_PERSON_LANG_OBJ,
    p_party_id                   IN            NUMBER,
    px_person_lang_rec           IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE
  )IS
  BEGIN
    px_person_lang_rec.language_use_reference_id := p_person_lang_obj.language_use_reference_id;
    px_person_lang_rec.language_name             := p_person_lang_obj.language_name;
    px_person_lang_rec.party_id                  := p_party_id;
    IF(p_person_lang_obj.native_language in ('Y','N')) THEN
      px_person_lang_rec.native_language           := p_person_lang_obj.native_language;
    END IF;
    IF(p_person_lang_obj.primary_language_indicator in ('Y','N')) THEN
      px_person_lang_rec.primary_language_indicator:= p_person_lang_obj.primary_language_indicator;
    END IF;
    px_person_lang_rec.reads_level               := p_person_lang_obj.reads_level;
    px_person_lang_rec.speaks_level              := p_person_lang_obj.speaks_level;
    px_person_lang_rec.writes_level              := p_person_lang_obj.writes_level;
    px_person_lang_rec.spoken_comprehension_level:= p_person_lang_obj.spoken_comprehension_level;
    IF(p_person_lang_obj.status in ('A','I')) THEN
      px_person_lang_rec.status                    := p_person_lang_obj.status;
    END IF;
    px_person_lang_rec.created_by_module         := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_person_lang_rec;

  -- PRIVATE PROCEDURE assign_education_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from education object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_education_obj      Education object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_education_rec     Education plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_education_rec(
    p_education_obj              IN            HZ_EDUCATION_OBJ,
    p_party_id                   IN            NUMBER,
    px_education_rec             IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE
  )IS
  BEGIN
    px_education_rec.education_id:= p_education_obj.education_id;
    px_education_rec.party_id:= p_party_id;
    px_education_rec.course_major:= p_education_obj.course_major;
    px_education_rec.degree_received:= p_education_obj.degree_received;
    px_education_rec.start_date_attended:= p_education_obj.start_date_attended;
    px_education_rec.last_date_attended:= p_education_obj.last_date_attended;
    px_education_rec.school_attended_name:= p_education_obj.school_attended_name;
    px_education_rec.school_party_id:= p_education_obj.school_party_id;
    px_education_rec.type_of_school:= p_education_obj.type_of_school;
    IF(p_education_obj.status in ('A','I')) THEN
      px_education_rec.status:= p_education_obj.status;
    END IF;
    px_education_rec.created_by_module:= HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_education_rec;

  -- PRIVATE PROCEDURE assign_citizenship_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from citizenship object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_citizenship_obj    Citizenship object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_citizenship_rec   Citizenship plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_citizenship_rec(
    p_citizenship_obj            IN            HZ_CITIZENSHIP_OBJ,
    p_party_id                   IN            NUMBER,
    px_citizenship_rec           IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE
  )IS
  BEGIN
    px_citizenship_rec.citizenship_id := p_citizenship_obj.citizenship_id;
    px_citizenship_rec.party_id := p_party_id;
    px_citizenship_rec.birth_or_selected := p_citizenship_obj.birth_or_selected;
    px_citizenship_rec.country_code := p_citizenship_obj.country_code;
    px_citizenship_rec.date_recognized := p_citizenship_obj.date_recognized;
    px_citizenship_rec.date_disowned := p_citizenship_obj.date_disowned;
    px_citizenship_rec.end_date := p_citizenship_obj.end_date;
    px_citizenship_rec.document_type := p_citizenship_obj.document_type;
    px_citizenship_rec.document_reference := p_citizenship_obj.document_reference;
    IF(p_citizenship_obj.status in ('A','I')) THEN
      px_citizenship_rec.status := p_citizenship_obj.status;
    END IF;
    px_citizenship_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_citizenship_rec;

  -- PRIVATE PROCEDURE assign_employ_hist_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from employment history object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_employ_hist_obj    Employment history object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_employ_hist_rec   Employment history plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_employ_hist_rec(
    p_employ_hist_obj            IN            HZ_EMPLOY_HIST_BO,
    p_party_id                   IN            NUMBER,
    px_employ_hist_rec           IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE
  )IS
  BEGIN
    px_employ_hist_rec.employment_history_id := p_employ_hist_obj.employment_history_id;
    px_employ_hist_rec.party_id := p_party_id;
    px_employ_hist_rec.begin_date := p_employ_hist_obj.begin_date;
    px_employ_hist_rec.end_date := p_employ_hist_obj.end_date;
    px_employ_hist_rec.employment_type_code := p_employ_hist_obj.employment_type_code;
    px_employ_hist_rec.employed_as_title_code := p_employ_hist_obj.employed_as_title_code;
    px_employ_hist_rec.employed_as_title := p_employ_hist_obj.employed_as_title;
    px_employ_hist_rec.employed_by_name_company := p_employ_hist_obj.employed_by_name_company;
    px_employ_hist_rec.employed_by_party_id := p_employ_hist_obj.employed_by_party_id;
    px_employ_hist_rec.employed_by_division_name := p_employ_hist_obj.employed_by_division_name;
    px_employ_hist_rec.supervisor_name := p_employ_hist_obj.supervisor_name;
    px_employ_hist_rec.branch := p_employ_hist_obj.branch;
    px_employ_hist_rec.military_rank := p_employ_hist_obj.military_rank;
    px_employ_hist_rec.served := p_employ_hist_obj.served;
    px_employ_hist_rec.station := p_employ_hist_obj.station;
    px_employ_hist_rec.responsibility := p_employ_hist_obj.responsibility;
    px_employ_hist_rec.weekly_work_hours := p_employ_hist_obj.weekly_work_hours;
    px_employ_hist_rec.reason_for_leaving := p_employ_hist_obj.reason_for_leaving;
    px_employ_hist_rec.faculty_position_flag := p_employ_hist_obj.faculty_position_flag;
    px_employ_hist_rec.tenure_code := p_employ_hist_obj.tenure_code;
    px_employ_hist_rec.fraction_of_tenure := p_employ_hist_obj.fraction_of_tenure;
    px_employ_hist_rec.comments := p_employ_hist_obj.comments;
    IF(p_employ_hist_obj.status in ('A','I')) THEN
      px_employ_hist_rec.status := p_employ_hist_obj.status;
    END IF;
    px_employ_hist_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_employ_hist_rec;

  -- PRIVATE PROCEDURE assign_work_class_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from work class object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_work_class_obj     Work class object.
  --     p_employ_hist_id     Employment history ID.
  --   IN/OUT:
  --     px_work_class_rec    Work class plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_work_class_rec(
    p_work_class_obj             IN            HZ_WORK_CLASS_OBJ,
    p_employ_hist_id             IN            NUMBER,
    px_work_class_rec            IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE
  )IS
  BEGIN
    px_work_class_rec.work_class_id := p_work_class_obj.work_class_id;
    px_work_class_rec.level_of_experience := p_work_class_obj.level_of_experience;
    px_work_class_rec.work_class_name := p_work_class_obj.work_class_name;
    px_work_class_rec.employment_history_id := p_employ_hist_id;
    IF(p_work_class_obj.status in ('A','I')) THEN
      px_work_class_rec.status := p_work_class_obj.status;
    END IF;
    px_work_class_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_work_class_rec;

  -- PRIVATE PROCEDURE assign_interest_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from person interest object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_work_class_obj     Person interest object.
  --     p_party_id           Party ID.
  --   IN/OUT:
  --     px_person_interest_rec    Person interest plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_interest_rec(
    p_person_interest_obj        IN            HZ_PERSON_INTEREST_OBJ,
    p_party_id                   IN            NUMBER,
    px_person_interest_rec       IN OUT NOCOPY HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE
  )IS
  BEGIN
    px_person_interest_rec.person_interest_id := p_person_interest_obj.person_interest_id;
    px_person_interest_rec.level_of_interest := p_person_interest_obj.level_of_interest;
    px_person_interest_rec.party_id := p_party_id;
    px_person_interest_rec.level_of_participation := p_person_interest_obj.level_of_participation;
    px_person_interest_rec.interest_type_code := p_person_interest_obj.interest_type_code;
    px_person_interest_rec.comments := p_person_interest_obj.comments;
    IF(p_person_interest_obj.sport_indicator in ('Y','N')) THEN
      px_person_interest_rec.sport_indicator := p_person_interest_obj.sport_indicator;
    END IF;
    px_person_interest_rec.sub_interest_type_code := p_person_interest_obj.sub_interest_type_code;
    px_person_interest_rec.interest_name := p_person_interest_obj.interest_name;
    px_person_interest_rec.team := p_person_interest_obj.team;
    px_person_interest_rec.since := p_person_interest_obj.since;
    IF(p_person_interest_obj.status in ('A','I')) THEN
      px_person_interest_rec.status := p_person_interest_obj.status;
    END IF;
    px_person_interest_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_interest_rec;

  -- PROCEDURE do_create_person_bo
  --
  -- DESCRIPTION
  --     Create a person business object.
  PROCEDURE do_create_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN OUT NOCOPY HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30);
    l_person_rec               HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    l_profile_id               NUMBER;
    l_party_number             VARCHAR2(30);
    l_dummy_id                 NUMBER;
    l_valid_obj                BOOLEAN;
    l_bus_object               HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_errorcode                NUMBER;
    l_raise_event              BOOLEAN := FALSE;
    l_cbm                      VARCHAR2(30);
    l_event_id                 NUMBER;
    l_telex_objs               HZ_TELEX_CP_BO_TBL;
    l_edi_objs                 HZ_EDI_CP_BO_TBL;
    l_eft_objs                 HZ_EFT_CP_BO_TBL;
    l_party_search_rec 	       HZ_PARTY_SEARCH.PARTY_SEARCH_REC_TYPE;
    l_party_site_list          HZ_PARTY_SEARCH.PARTY_SITE_LIST;
    l_contact_list             HZ_PARTY_SEARCH.CONTACT_LIST;
    l_contact_point_list       HZ_PARTY_SEARCH.CONTACT_POINT_LIST;
    l_match_rule_id number;
    l_search_ctx_id NUMBER;
    l_num_matches NUMBER;
    l_party_id NUMBER;
    l_match_score NUMBER;
    l_tmp_score NUMBER;
    l_match_threshold NUMBER;
    l_automerge_threshold NUMBER;
    l_dup_batch_id NUMBER;
    l_dup_set_id NUMBER;
    l_request_id NUMBER;
    l_dup_batch_rec  HZ_DUP_PVT.DUP_BATCH_REC_TYPE;
    l_dup_set_rec    HZ_DUP_PVT.DUP_SET_REC_TYPE;
    l_dup_party_tbl  HZ_DUP_PVT.DUP_PARTY_TBL_TYPE;
    l_party_name     varchar2(360);
    l_overlap_merge_req_id NUMBER;
    l_object_version_number NUMBER;
    l_batch_id NUMBER;
    l_cpt_count NUMBER;

    cursor get_obj_version_csr(cp_dup_set_id number) is
		SELECT object_version_number
  		FROM   hz_dup_sets
  		WHERE  dup_set_id = cp_dup_set_id;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_person_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'PERSON',
        x_bus_object              => l_bus_object
      );

      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_person_bo_comp(
                       p_person_obj => p_person_obj,
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- find out if raise event at the end
      l_raise_event := HZ_PARTY_BO_PVT.is_raising_create_event(
                         p_obj_complete_flag => l_valid_obj);

      IF(l_raise_event) THEN
        -- get event_id and set global variable to event_id for
        -- BOT populate function
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_event_id
        FROM DUAL;
      END IF;
    ELSE
      l_raise_event := FALSE;
    END IF;

    x_person_id := p_person_obj.person_id;
    x_person_os := p_person_obj.orig_system;
    x_person_osr:= p_person_obj.orig_system_reference;

    -- check input person party id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_person_id,
      px_os              => x_person_os,
      px_osr             => x_person_osr,
      p_obj_type         => 'PERSON',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------------------
    -- Assign person and party record
    ---------------------------------
    assign_person_rec(
      p_person_obj  => p_person_obj,
      p_person_id   => x_person_id,
      p_person_os   => x_person_os,
      p_person_osr  => x_person_osr,
      px_person_rec => l_person_rec
    );

    HZ_PARTY_V2PUB.create_person(
      p_person_rec                => l_person_rec,
      x_party_id                  => x_person_id,
      x_party_number              => l_party_number,
      x_profile_id                => l_profile_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign person party_id
    p_person_obj.person_id := x_person_id;
    p_person_obj.party_number := l_party_number;
    --------------------------
    -- Create Person Ext Attrs
    --------------------------
    IF((p_person_obj.ext_attributes_objs IS NOT NULL) AND
       (p_person_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_person_obj.ext_attributes_objs,
        p_parent_obj_id             => l_profile_id,
        p_parent_obj_type           => 'PERSON',
        p_create_or_update          => 'C',
        x_return_status             => x_return_status,
        x_errorcode                 => l_errorcode,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Call party info v2pub api
    ----------------------------
    IF(((p_person_obj.language_objs IS NOT NULL) AND (p_person_obj.language_objs.COUNT > 0)) OR
       ((p_person_obj.education_objs IS NOT NULL) AND (p_person_obj.education_objs.COUNT > 0)) OR
       ((p_person_obj.citizenship_objs IS NOT NULL) AND (p_person_obj.citizenship_objs.COUNT > 0)) OR
       ((p_person_obj.employ_hist_objs IS NOT NULL) AND (p_person_obj.employ_hist_objs.COUNT > 0)) OR
       ((p_person_obj.interest_objs IS NOT NULL) AND (p_person_obj.interest_objs.COUNT > 0))) THEN
      create_person_info(
        p_language_obj              => p_person_obj.language_objs,
        p_education_obj             => p_person_obj.education_objs,
        p_citizenship_obj           => p_person_obj.citizenship_objs,
        p_employ_hist_obj           => p_person_obj.employ_hist_objs,
        p_interest_obj              => p_person_obj.interest_objs,
        p_person_id                 => x_person_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Party Preferences
    ----------------------------
    IF((p_person_obj.preference_objs IS NOT NULL) AND
       (p_person_obj.preference_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_party_preferences(
        p_party_pref_objs           => p_person_obj.preference_objs,
        p_party_id                  => x_person_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Contact Preferences
    ----------------------------
    IF((p_person_obj.contact_pref_objs IS NOT NULL) AND
       (p_person_obj.contact_pref_objs.COUNT > 0)) THEN
      HZ_CONTACT_PREFERENCE_BO_PVT.create_contact_preferences(
        p_cp_pref_objs           => p_person_obj.contact_pref_objs,
        p_contact_level_table_id => x_person_id,
        p_contact_level_table    => 'HZ_PARTIES',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Relationship api
    ----------------------------
    IF((p_person_obj.relationship_objs IS NOT NULL) AND
       (p_person_obj.relationship_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.create_relationships(
        p_rel_objs                  => p_person_obj.relationship_objs,
        p_subject_id                => x_person_id,
        p_subject_type              => 'PERSON',
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Classification api
    ----------------------------
    IF((p_person_obj.class_objs IS NOT NULL) AND
       (p_person_obj.class_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.create_classifications(
        p_code_assign_objs          => p_person_obj.class_objs,
        p_owner_table_name          => 'HZ_PARTIES',
        p_owner_table_id            => x_person_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    ----------------------------
    -- Create logical party site
    ----------------------------
    IF((p_person_obj.party_site_objs IS NOT NULL) AND
       (p_person_obj.party_site_objs.COUNT > 0)) THEN
      HZ_PARTY_SITE_BO_PVT.save_party_sites(
        p_ps_objs            => p_person_obj.party_site_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => x_person_id,
        p_parent_os          => x_person_os,
        p_parent_osr         => x_person_osr,
        p_parent_obj_type    => 'PERSON'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ------------------------
    -- Create contact points
    ------------------------
    IF(((p_person_obj.phone_objs IS NOT NULL) AND (p_person_obj.phone_objs.COUNT > 0)) OR
       ((p_person_obj.email_objs IS NOT NULL) AND (p_person_obj.email_objs.COUNT > 0)) OR
       ((p_person_obj.web_objs IS NOT NULL) AND (p_person_obj.web_objs.COUNT > 0)) OR
       ((p_person_obj.sms_objs IS NOT NULL) AND (p_person_obj.sms_objs.COUNT > 0))) THEN
      HZ_CONTACT_POINT_BO_PVT.save_contact_points(
        p_phone_objs         => p_person_obj.phone_objs,
        p_telex_objs         => l_telex_objs,
        p_email_objs         => p_person_obj.email_objs,
        p_web_objs           => p_person_obj.web_objs,
        p_edi_objs           => l_edi_objs,
        p_eft_objs           => l_eft_objs,
        p_sms_objs           => p_person_obj.sms_objs,
        p_owner_table_id     => x_person_id,
        p_owner_table_os     => x_person_os,
        p_owner_table_osr    => x_person_osr,
        p_parent_obj_type    => 'PERSON',
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ----------------------------
    -- Certifications
    ----------------------------
    IF((p_person_obj.certification_objs IS NOT NULL) AND
       (p_person_obj.certification_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.create_certifications(
        p_cert_objs                 => p_person_obj.certification_objs,
        p_party_id                  => x_person_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Financial Profiles
    ----------------------------
    IF((p_person_obj.financial_prof_objs IS NOT NULL) AND
       (p_person_obj.financial_prof_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.create_financial_profiles(
        p_fin_prof_objs             => p_person_obj.financial_prof_objs,
        p_party_id                  => x_person_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  ----------------------------------
  --  Party Usages -------
  ----------------------------------
   IF ((p_person_obj.party_usage_objs IS NOT NULL) AND
      (p_person_obj.party_usage_objs.COUNT > 0 )) THEN
       HZ_PARTY_BO_PVT.create_party_usage_assgmnt(
	   p_party_usg_objs				=> p_person_obj.party_usage_objs,
	   p_party_id					=> x_person_id,
	   x_return_status				=> x_return_status,
	   x_msg_count					=> x_msg_count,
	   x_msg_data					=> x_msg_data
	   );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    -- raise event
    IF(l_raise_event) THEN
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON',
        p_create_or_update => 'C',
        p_obj_source       => p_obj_source,
        p_event_id         => l_event_id
      );
    END IF;

  -- Enh: check if DQM is enabled
    if nvl(fnd_profile.value('HZ_BO_ENABLE_DQ'),'N') = 'Y'
    then
	-- call DQM search API

        l_match_rule_id := nvl(fnd_profile.value('HZ_BO_PERSON_MATCH_RULE'), 240); -- 240: new person match rule

        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'Enable DQ on Integration Services: START ',p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
      		hz_utility_v2pub.debug(p_message=>'Match Rule ID '||l_match_rule_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
		hz_utility_v2pub.debug(p_message=>'Newly Created Party Id: '||x_person_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        END IF;

	l_party_search_rec.JGZZ_FISCAL_CODE := l_person_rec.JGZZ_FISCAL_CODE;
  	l_party_search_rec.PARTY_ALL_NAMES := hz_format_pub.format_name(x_person_id)|| ' ' ||
						l_person_rec.KNOWN_AS|| ' ' ||
						l_person_rec.KNOWN_AS2|| ' ' ||
						l_person_rec.KNOWN_AS3|| ' ' ||
						l_person_rec.KNOWN_AS4|| ' ' ||
						l_person_rec.KNOWN_AS5;
  	l_party_search_rec.KNOWN_AS := l_person_rec.KNOWN_AS;
  	l_party_search_rec.KNOWN_AS2 := l_person_rec.KNOWN_AS2;
  	l_party_search_rec.KNOWN_AS3 := l_person_rec.KNOWN_AS3;
  	l_party_search_rec.KNOWN_AS4 := l_person_rec.KNOWN_AS4;
  	l_party_search_rec.KNOWN_AS5 := l_person_rec.KNOWN_AS5;
	l_party_search_rec.TAX_REFERENCE := l_person_rec.TAX_REFERENCE;
  	l_party_search_rec.CATEGORY_CODE := p_person_obj.CATEGORY_CODE;
  	l_party_search_rec.PARTY_NAME := hz_format_pub.format_name(x_person_id);
  	l_party_search_rec.PARTY_NUMBER := p_person_obj.PARTY_NUMBER;
  	l_party_search_rec.PARTY_TYPE := 'PERSON';
  	l_party_search_rec.STATUS := p_person_obj.STATUS;
  	l_party_search_rec.DATE_OF_BIRTH := l_person_rec.DATE_OF_BIRTH;
  	l_party_search_rec.DATE_OF_DEATH := l_person_rec.DATE_OF_DEATH;
  	l_party_search_rec.DECLARED_ETHNICITY := l_person_rec.DECLARED_ETHNICITY;
  	l_party_search_rec.GENDER := l_person_rec.GENDER;
  	l_party_search_rec.HEAD_OF_HOUSEHOLD_FLAG := l_person_rec.HEAD_OF_HOUSEHOLD_FLAG;
  	l_party_search_rec.HOUSEHOLD_INCOME := l_person_rec.HOUSEHOLD_INCOME;
  	l_party_search_rec.HOUSEHOLD_SIZE := l_person_rec.HOUSEHOLD_SIZE;
  	l_party_search_rec.LAST_KNOWN_GPS := l_person_rec.LAST_KNOWN_GPS;
  	l_party_search_rec.MARITAL_STATUS := l_person_rec.MARITAL_STATUS;
  	l_party_search_rec.MARITAL_STATUS_EFFECTIVE_DATE := l_person_rec.MARITAL_STATUS_EFFECTIVE_DATE;
  	l_party_search_rec.MIDDLE_NAME_PHONETIC := l_person_rec.MIDDLE_NAME_PHONETIC;
  	l_party_search_rec.PERSONAL_INCOME := l_person_rec.PERSONAL_INCOME;
  	l_party_search_rec.PERSON_ACADEMIC_TITLE := l_person_rec.PERSON_ACADEMIC_TITLE;
  	l_party_search_rec.PERSON_FIRST_NAME := l_person_rec.PERSON_FIRST_NAME;
  	l_party_search_rec.PERSON_FIRST_NAME_PHONETIC := l_person_rec.PERSON_FIRST_NAME_PHONETIC;
  	l_party_search_rec.PERSON_IDENTIFIER := l_person_rec.PERSON_IDENTIFIER;
  	l_party_search_rec.PERSON_IDEN_TYPE := l_person_rec.PERSON_IDEN_TYPE;
  	l_party_search_rec.PERSON_INITIALS := l_person_rec.PERSON_INITIALS;
  	l_party_search_rec.PERSON_LAST_NAME := l_person_rec.PERSON_LAST_NAME;
  	l_party_search_rec.PERSON_LAST_NAME_PHONETIC := l_person_rec.PERSON_LAST_NAME_PHONETIC;
  	l_party_search_rec.PERSON_MIDDLE_NAME := l_person_rec.PERSON_MIDDLE_NAME;
  	l_party_search_rec.PERSON_NAME := l_party_search_rec.PARTY_NAME;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'l_party_search_rec.PARTY_NAME(formatted):  '||l_party_search_rec.PARTY_NAME,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

        END IF;

  	l_party_search_rec.PERSON_NAME_PHONETIC := l_person_rec.PERSON_NAME_PHONETIC;
  	l_party_search_rec.PERSON_NAME_SUFFIX := l_person_rec.PERSON_NAME_SUFFIX;
  	l_party_search_rec.PERSON_PREVIOUS_LAST_NAME := l_person_rec.PERSON_PREVIOUS_LAST_NAME;
  	l_party_search_rec.PERSON_PRE_NAME_ADJUNCT := l_person_rec.PERSON_PRE_NAME_ADJUNCT;
  	l_party_search_rec.PERSON_TITLE := l_person_rec.PERSON_TITLE;
  	l_party_search_rec.PLACE_OF_BIRTH := l_person_rec.PLACE_OF_BIRTH;
	l_party_search_rec.PARTY_SOURCE_SYSTEM_REF := p_person_obj.orig_system|| ' ' ||p_person_obj.orig_system_reference||' ';

     IF((p_person_obj.party_site_objs IS NOT NULL) AND (p_person_obj.party_site_objs.COUNT > 0)) THEN

      for i in 1..p_person_obj.party_site_objs.COUNT loop
	l_party_site_list(i).ADDR_SOURCE_SYSTEM_REF := p_person_obj.party_site_objs(i).orig_system|| ' ' ||p_person_obj.party_site_objs(i).orig_system_reference||' ';
		l_party_site_list(i).address := p_person_obj.party_site_objs(i).location_obj.ADDRESS1|| ' ' ||
     					p_person_obj.party_site_objs(i).location_obj.ADDRESS2|| ' ' ||
     					p_person_obj.party_site_objs(i).location_obj.ADDRESS3|| ' ' ||
     					p_person_obj.party_site_objs(i).location_obj.ADDRESS4;

	l_party_site_list(i).ADDRESS1 := p_person_obj.party_site_objs(i).location_obj.ADDRESS1;
  	l_party_site_list(i).ADDRESS2 := p_person_obj.party_site_objs(i).location_obj.ADDRESS2;
  	l_party_site_list(i).ADDRESS3 := p_person_obj.party_site_objs(i).location_obj.ADDRESS3;
  	l_party_site_list(i).ADDRESS4 := p_person_obj.party_site_objs(i).location_obj.ADDRESS4;
  	l_party_site_list(i).ADDRESS_EFFECTIVE_DATE := p_person_obj.party_site_objs(i).location_obj.ADDRESS_EFFECTIVE_DATE;
  	l_party_site_list(i).ADDRESS_EXPIRATION_DATE := p_person_obj.party_site_objs(i).location_obj.ADDRESS_EXPIRATION_DATE;
  	l_party_site_list(i).ADDRESS_LINES_PHONETIC := p_person_obj.party_site_objs(i).location_obj.ADDRESS_LINES_PHONETIC;
  	l_party_site_list(i).CITY := p_person_obj.party_site_objs(i).location_obj.CITY;
  	l_party_site_list(i).CLLI_CODE := p_person_obj.party_site_objs(i).location_obj.CLLI_CODE;
  	l_party_site_list(i).COUNTRY := p_person_obj.party_site_objs(i).location_obj.COUNTRY;
  	l_party_site_list(i).COUNTY := p_person_obj.party_site_objs(i).location_obj.COUNTY;
  	l_party_site_list(i).LANGUAGE := p_person_obj.party_site_objs(i).LANGUAGE;
  	l_party_site_list(i).POSITION := p_person_obj.party_site_objs(i).location_obj.POSITION;
  	l_party_site_list(i).POSTAL_CODE := p_person_obj.party_site_objs(i).location_obj.POSTAL_CODE;
  	l_party_site_list(i).POSTAL_PLUS4_CODE := p_person_obj.party_site_objs(i).location_obj.POSTAL_PLUS4_CODE;
  	l_party_site_list(i).PROVINCE := p_person_obj.party_site_objs(i).location_obj.PROVINCE;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'l_party_site_list('||i||').address: '||l_party_site_list(i).ADDRESS,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
		hz_utility_v2pub.debug(p_message=>'l_party_site_list('||i||').postal_code: '||l_party_site_list(i).POSTAL_CODE,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        END IF;
  	l_party_site_list(i).SALES_TAX_GEOCODE := p_person_obj.party_site_objs(i).location_obj.SALES_TAX_GEOCODE;
  	l_party_site_list(i).SALES_TAX_INSIDE_CITY_LIMITS := p_person_obj.party_site_objs(i).location_obj.SALES_TAX_INSIDE_CITY_LIMITS;
  	l_party_site_list(i).STATE := p_person_obj.party_site_objs(i).location_obj.STATE;
  	l_party_site_list(i).IDENTIFYING_ADDRESS_FLAG := p_person_obj.party_site_objs(i).IDENTIFYING_ADDRESS_FLAG;
  	l_party_site_list(i).MAILSTOP := p_person_obj.party_site_objs(i).MAILSTOP;
  	l_party_site_list(i).PARTY_SITE_NAME := p_person_obj.party_site_objs(i).PARTY_SITE_NAME;
  	l_party_site_list(i).PARTY_SITE_NUMBER := p_person_obj.party_site_objs(i).PARTY_SITE_NUMBER;
  	l_party_site_list(i).STATUS := p_person_obj.party_site_objs(i).STATUS;
      end loop;
    end if;



     IF((p_person_obj.phone_objs IS NOT NULL) AND (p_person_obj.phone_objs.COUNT > 0))
     then
      for i in 1..p_person_obj.phone_objs.COUNT loop
	l_contact_point_list(i).CPT_SOURCE_SYSTEM_REF := p_person_obj.phone_objs(i).orig_system|| ' ' ||p_person_obj.phone_objs(i).orig_system_reference||' ';
        l_contact_point_list(i).CONTACT_POINT_TYPE := 'PHONE';
	l_contact_point_list(i).PRIMARY_FLAG := p_person_obj.phone_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(i).STATUS := p_person_obj.phone_objs(i).STATUS;
  	l_contact_point_list(i).CONTACT_POINT_PURPOSE := p_person_obj.phone_objs(i).CONTACT_POINT_PURPOSE;
  	l_contact_point_list(i).LAST_CONTACT_DT_TIME := p_person_obj.phone_objs(i).LAST_CONTACT_DT_TIME;
  	l_contact_point_list(i).PHONE_AREA_CODE := p_person_obj.phone_objs(i).PHONE_AREA_CODE;
  	l_contact_point_list(i).PHONE_CALLING_CALENDAR := p_person_obj.phone_objs(i).PHONE_CALLING_CALENDAR;
  	l_contact_point_list(i).PHONE_COUNTRY_CODE := p_person_obj.phone_objs(i).PHONE_COUNTRY_CODE;
  	l_contact_point_list(i).PHONE_EXTENSION := p_person_obj.phone_objs(i).PHONE_EXTENSION;
  	l_contact_point_list(i).PHONE_LINE_TYPE := p_person_obj.phone_objs(i).PHONE_LINE_TYPE;
  	l_contact_point_list(i).PHONE_NUMBER := p_person_obj.phone_objs(i).PHONE_NUMBER;
  	l_contact_point_list(i).PRIMARY_FLAG := p_person_obj.phone_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(i).RAW_PHONE_NUMBER := p_person_obj.phone_objs(i).RAW_PHONE_NUMBER;
  	l_contact_point_list(i).TELEPHONE_TYPE := p_person_obj.phone_objs(i).PHONE_LINE_TYPE;
  	l_contact_point_list(i).TIME_ZONE := p_person_obj.phone_objs(i).TIMEZONE_ID;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'l_contact_point_list('||i||')'||'.phone_number'||l_contact_point_list(i).PHONE_NUMBER,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        end if;
        -- Per DQM, flex_formatted_phone_number is the concate of country code, area code and phone number
        if p_person_obj.phone_objs(i).PHONE_NUMBER is not null
	then
 		l_contact_point_list(i).FLEX_FORMAT_PHONE_NUMBER := p_person_obj.phone_objs(i).PHONE_COUNTRY_CODE ||p_person_obj.phone_objs(i).PHONE_AREA_CODE||p_person_obj.phone_objs(i).PHONE_NUMBER;

	elsif l_contact_point_list(i).RAW_PHONE_NUMBER is not null
	then
		 hz_contact_point_v2pub.phone_format (
                                 p_raw_phone_number       => p_person_obj.phone_objs(i).RAW_PHONE_NUMBER,
                                 p_territory_code         => p_person_obj.phone_objs(i).PHONE_COUNTRY_CODE,
                                 x_formatted_phone_number => l_contact_point_list(i).FLEX_FORMAT_PHONE_NUMBER,
                                 x_phone_country_code     => l_contact_point_list(i).PHONE_COUNTRY_CODE,
                                 x_phone_area_code        => l_contact_point_list(i).PHONE_AREA_CODE,
                                 x_phone_number           => l_contact_point_list(i).PHONE_NUMBER,
                                 x_return_status          => x_return_status,
                                 x_msg_count              => x_msg_count,
                                 x_msg_data               => x_msg_data);
		 l_contact_point_list(i).FLEX_FORMAT_PHONE_NUMBER := l_contact_point_list(i).PHONE_COUNTRY_CODE ||l_contact_point_list(i).PHONE_AREA_CODE||l_contact_point_list(i).PHONE_NUMBER;

	end if;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'l_contact_point_list('||to_char(i)||').flex_format_phone_number: '||l_contact_point_list(i).FLEX_FORMAT_PHONE_NUMBER,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
		hz_utility_v2pub.debug(p_message=>'l_contact_point_list('||i||').phone_number(parsed): '||l_contact_point_list(i).PHONE_NUMBER,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        END IF;
       end loop;
     end if;

     l_cpt_count := l_contact_point_list.COUNT;

    IF((p_person_obj.email_objs IS NOT NULL) AND (p_person_obj.email_objs.COUNT > 0))
    then
      for i in 1..p_person_obj.email_objs.COUNT loop
	l_contact_point_list(l_cpt_count+i).CPT_SOURCE_SYSTEM_REF := p_person_obj.email_objs(i).orig_system|| ' ' ||p_person_obj.email_objs(i).orig_system_reference||' ';
        l_contact_point_list(l_cpt_count+i).CONTACT_POINT_TYPE := 'EMAIL';
	l_contact_point_list(l_cpt_count+i).PRIMARY_FLAG := p_person_obj.email_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(l_cpt_count+i).STATUS := p_person_obj.email_objs(i).STATUS;
  	l_contact_point_list(l_cpt_count+i).CONTACT_POINT_PURPOSE := p_person_obj.email_objs(i).CONTACT_POINT_PURPOSE;
	l_contact_point_list(l_cpt_count+i).EMAIL_ADDRESS := p_person_obj.email_objs(i).EMAIL_ADDRESS;
        l_contact_point_list(l_cpt_count+i).EMAIL_FORMAT := p_person_obj.email_objs(i).EMAIL_FORMAT;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'l_contact_point_list('||to_char(l_cpt_count+i)||')'||'.email_address'||l_contact_point_list(l_cpt_count+i).EMAIL_ADDRESS,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        end if;
      end loop;
    end if;

     l_cpt_count := l_contact_point_list.COUNT;

    IF((p_person_obj.web_objs IS NOT NULL) AND (p_person_obj.web_objs.COUNT > 0))
    then
      for i in 1..p_person_obj.web_objs.COUNT loop
	l_contact_point_list(l_cpt_count+i).CPT_SOURCE_SYSTEM_REF := p_person_obj.web_objs(i).orig_system|| ' ' ||p_person_obj.web_objs(i).orig_system_reference||' ';
        l_contact_point_list(l_cpt_count+i).CONTACT_POINT_TYPE := 'WEB';
	l_contact_point_list(l_cpt_count+i).PRIMARY_FLAG := p_person_obj.web_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(l_cpt_count+i).STATUS := p_person_obj.web_objs(i).STATUS;
  	l_contact_point_list(l_cpt_count+i).CONTACT_POINT_PURPOSE := p_person_obj.web_objs(i).CONTACT_POINT_PURPOSE;
	l_contact_point_list(l_cpt_count+i).URL := p_person_obj.web_objs(i).URL ;
  	l_contact_point_list(l_cpt_count+i).WEB_TYPE := p_person_obj.web_objs(i).WEB_TYPE;

      end loop;
    end if;

    l_cpt_count := l_contact_point_list.COUNT;

    IF((p_person_obj.sms_objs IS NOT NULL) AND (p_person_obj.sms_objs.COUNT > 0))
    then
      for i in 1..p_person_obj.sms_objs.COUNT loop
	l_contact_point_list(l_cpt_count+i).CPT_SOURCE_SYSTEM_REF := p_person_obj.sms_objs(i).orig_system|| ' ' ||p_person_obj.sms_objs(i).orig_system_reference||' ';
        l_contact_point_list(l_cpt_count+i).CONTACT_POINT_TYPE := 'SMS';
	l_contact_point_list(l_cpt_count+i).PRIMARY_FLAG := p_person_obj.sms_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(l_cpt_count+i).STATUS := p_person_obj.sms_objs(i).STATUS;
  	l_contact_point_list(l_cpt_count+i).CONTACT_POINT_PURPOSE := p_person_obj.sms_objs(i).CONTACT_POINT_PURPOSE;
      end loop;
    end if;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'Calling DQM API HZ_PARTY_SEARCH.find_persons ',p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SEARCH.find_persons Start time: '||TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'),p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
    END IF;

    HZ_PARTY_SEARCH.find_persons (
	     p_rule_id           => l_match_rule_id,
	     p_party_search_rec  => l_party_search_rec,
	     p_party_site_list   => l_party_site_list,
	     p_contact_list      => l_contact_list,
	     p_contact_point_list=> l_contact_point_list,
  	     p_restrict_sql      => null,
	     p_match_type        => null,
	     x_search_ctx_id     => l_search_ctx_id,
	     x_num_matches       => l_num_matches,
	     x_return_status     => x_return_status,
 	     x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data

    );

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SEARCH.find_persons end time: '||TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'),p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
     --   hz_utility_v2pub.debug(p_message=>'# of Matches: '||l_num_matches,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
 	hz_utility_v2pub.debug(p_message=>'return status of find_persons: '||x_return_status,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	hz_utility_v2pub.debug(p_message=>'search_ctx_id: '||l_search_ctx_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	if l_num_matches = 0
        then
          hz_utility_v2pub.debug(p_message=>'# of Matches: '||l_num_matches,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        end if;
    END IF;

   if l_num_matches > 0 then

	hz_dup_pvt.get_most_matching_party(p_search_ctx_id => l_search_ctx_id,
					p_new_party_id => x_person_id,
				       x_party_id => l_party_id,
				       x_match_score => l_match_score,
				       x_party_name => l_party_name);
     if l_party_id is null
     then
		 IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 	hz_utility_v2pub.debug(p_message=>'# of Matches: 0 ',p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
		 end if;
     else
         IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 	hz_utility_v2pub.debug(p_message=>'# of Matches: '||l_num_matches,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        	hz_utility_v2pub.debug(p_message=>'Most matching Party Id: '||l_party_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	        hz_utility_v2pub.debug(p_message=>'Most matching Party Name: '||l_party_name,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        	hz_utility_v2pub.debug(p_message=>'Match score: '||l_match_score,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
    	 END IF;

	hz_dup_pvt.get_match_rule_thresholds(p_match_rule_id => l_match_rule_id,
				    x_match_threshold => l_match_threshold,
				    x_automerge_threshold => l_automerge_threshold);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'Match Threshold: '||l_match_threshold,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        	hz_utility_v2pub.debug(p_message=>'Automerge Threshold: '||l_automerge_threshold,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

    	 END IF;

	if l_match_score >= l_match_threshold
	then
		hz_dup_pvt.validate_master_party_id(px_party_id => l_party_id,
					x_overlap_merge_req_id => l_overlap_merge_req_id);

		hz_utility_v2pub.debug(p_message=>'xx: Winner Party ID is changed. Overlapping Merge Req ID: '||l_overlap_merge_req_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
  	hz_utility_v2pub.debug(p_message=>'xx: Winner Party ID is changed. Party ID: '||l_party_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        	if l_overlap_merge_req_id is not null
		then
			l_tmp_score := l_match_score;
			begin
				SELECT score, party_name into l_match_score, l_party_name
				FROM hz_matched_parties_gt mpg, hz_parties p
				WHERE mpg.party_id = p.party_id
				and mpg.party_id = l_party_id
				and mpg.search_context_id = l_search_ctx_id
				and rownum = 1;
			 EXCEPTION
       				WHEN NO_DATA_FOUND THEN
				l_match_score := 0;
				IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_message=>'The changed party is not a duplicate with the newly created party' ,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
				end if;

			END;

 			IF l_match_score > 0 and fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_message=>'Winner Party ID is changed. Overlapping Merge Req ID: '||l_overlap_merge_req_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

        		hz_utility_v2pub.debug(p_message=>'Winner Party Id: '||l_party_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
			hz_utility_v2pub.debug(p_message=>'Winner Party Id match score: '||l_match_score,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
			end if;
    	        END IF;
	      if l_match_score >= l_match_threshold
	      then -- match score might get reset due to overlapping req, need to check this again.
		l_dup_batch_rec.dup_batch_name := l_party_name||'-'|| to_char(sysdate);
    		l_dup_batch_rec.match_rule_id := l_match_rule_id;
    		l_dup_batch_rec.application_id := 222;
    		l_dup_batch_rec.request_type := 'USER_ENTERED';
    		l_dup_batch_id := NULL;
    		l_dup_set_rec.winner_party_id := l_party_id;
    		l_dup_set_rec.status := 'SYSBATCH';
    		l_dup_set_rec.assigned_to_user_id := fnd_global.user_id;
		l_dup_set_rec.merge_type := 'PARTY_MERGE';

		l_dup_party_tbl(1).party_id := l_party_id;
      		l_dup_party_tbl(1).score := l_match_score;
      		l_dup_party_tbl(1).merge_flag := 'Y';

	 	l_dup_party_tbl(2).party_id := x_person_id; -- newly created person id
      		l_dup_party_tbl(2).score := 0;
      		l_dup_party_tbl(2).merge_flag := 'Y';

		HZ_DUP_PVT.create_dup_batch(
         	p_dup_batch_rec             => l_dup_batch_rec
        	,p_dup_set_rec               => l_dup_set_rec
        	,p_dup_party_tbl             => l_dup_party_tbl
        	,x_dup_batch_id              => l_dup_batch_id
        	,x_dup_set_id                => l_dup_set_id
        	,x_return_status             => x_return_status
        	,x_msg_count                 => x_msg_count
        	,x_msg_data                  => x_msg_data );


      		IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
      		END IF;

		IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        			hz_utility_v2pub.debug(p_message=>'Created dup batch: dup_set_id: '||l_dup_set_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

    	        END IF;


		if l_dup_set_id is not null
		then
		  if l_match_score < l_automerge_threshold -- create merge request
		  then
			hz_dup_pvt.submit_dup (
   					p_dup_set_id    => l_dup_set_id
  					,x_request_id    => l_request_id
  					,x_return_status => x_return_status
  					,x_msg_count     => x_msg_count
  					,x_msg_data      => x_msg_data);

		        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        				hz_utility_v2pub.debug(p_message=>'Merge Request Created with merge request id: '||l_dup_set_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        				hz_utility_v2pub.debug(p_message=>'Create Merge Request conc request id: '||l_request_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

			end if;
		  end if; --if l_match_score < l_automerge_threshold
		 end if; --if l_match_score >= l_match_threshold then

		  if l_match_score >= l_automerge_threshold
    		  then
				open get_obj_version_csr(l_dup_set_id);
				fetch get_obj_version_csr into l_object_version_number;
	        		close get_obj_version_csr;

				hz_merge_dup_pvt.Create_Merge_Batch(  -- need to create merge in real time.
  					p_dup_set_id    => l_dup_set_id,
  					p_default_mapping  => 'Y',
  					p_object_version_number => l_object_version_number,
  					x_merge_batch_id     => l_batch_id,
					x_return_status => x_return_status,
  					x_msg_count     => x_msg_count,
  					x_msg_data      => x_msg_data);


	            		--submit Party Merge concurrent program
                                     hz_merge_dup_pvt.submit_batch(
  					p_batch_id      => l_dup_set_id,
  					p_preview       => 'N',
  					x_request_id    => l_request_id,
  					x_return_status => x_return_status,
  					x_msg_count     => x_msg_count,
  					x_msg_data      => x_msg_data);
				IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_message=>'Party Merge request status: '||x_return_status,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        				hz_utility_v2pub.debug(p_message=>'Party Merge request submitted with conc request_id: '||l_request_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
                        	end if;

    	          end if; -- if l_match_score >= l_automerge_threshold
		end if; --if l_dup_set_id is not null
	end if;	-- if l_match_score >= l_match_threshold
      end if; -- if l_party_id = x_person_id
   end if;  -- if l_num_matches > 0 then
   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'Enable DQ on Integration Services: End ',p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
   end if;
end if;  -- if nvl(fnd_profile.value('HZ_BO_ENABLE_DQ'),'N') = 'Y'


    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_person_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_person_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_person_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_person_bo;

  PROCEDURE create_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  ) IS
    l_per_obj             HZ_PERSON_BO;
  BEGIN
    l_per_obj := p_person_obj;
    do_create_person_bo(
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_person_obj         => l_per_obj,
      p_created_by_module  => p_created_by_module,
      p_obj_source         => null,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_person_id          => x_person_id,
      x_person_os          => x_person_os,
      x_person_osr         => x_person_osr
    );
  END create_person_bo;

  PROCEDURE create_person_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := NULL,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_per_obj             HZ_PERSON_BO;
  BEGIN
    l_per_obj := p_person_obj;
    do_create_person_bo(
      p_init_msg_list      => FND_API.G_TRUE,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_person_obj         => l_per_obj,
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_person_id          => x_person_id,
      x_person_os          => x_person_os,
      x_person_osr         => x_person_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_per_obj;
    END IF;
  END create_person_bo;

  -- PROCEDURE do_update_person_bo
  --
  -- DESCRIPTION
  --     Update a person business object.
  PROCEDURE do_update_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_obj          IN OUT NOCOPY HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := NULL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30);
    l_person_rec               HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    l_create_update_flag       VARCHAR2(1);
    l_ovn                      NUMBER;
    l_dummy_id                 NUMBER;
    l_profile_id               NUMBER;
    l_errorcode                NUMBER;
    l_per_raise_event          BOOLEAN := FALSE;
    l_pc_raise_event           BOOLEAN := FALSE;
    l_cbm                      VARCHAR2(30);
    l_per_event_id             NUMBER;
    l_pc_event_id              NUMBER;
    l_telex_objs               HZ_TELEX_CP_BO_TBL;
    l_edi_objs                 HZ_EDI_CP_BO_TBL;
    l_eft_objs                 HZ_EFT_CP_BO_TBL;
    l_party_number             VARCHAR2(30);

    CURSOR get_ovn(l_party_id  NUMBER) IS
    SELECT p.object_version_number, p.party_number
    FROM HZ_PARTIES p
    WHERE p.party_id = l_party_id
    AND p.party_type = 'PERSON'
    AND p.status in ('A','I');

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_person_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_person_id := p_person_obj.person_id;
    x_person_os := p_person_obj.orig_system;
    x_person_osr:= p_person_obj.orig_system_reference;

    -- check input party_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_person_id,
      px_os              => x_person_os,
      px_osr             => x_person_osr,
      p_obj_type         => 'PERSON',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- must check after calling validate_ssm_id because
    -- if user pass os+osr and no id, validate_ssm_id will
    -- populate x_person_id based on os+osr
    -- find out if raise event at the end

    -- if this procedure is called from person cust bo, set l_raise_event to false
    -- otherwise, call is_raising_update_event
    IF(HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO IS NOT NULL) THEN
      l_per_raise_event := FALSE;
      l_pc_raise_event := FALSE;
    ELSE
      l_per_raise_event := HZ_PARTY_BO_PVT.is_raising_update_event(
                             p_party_id          => x_person_id,
                             p_bo_code           => 'PERSON'
                           );

      l_pc_raise_event := HZ_PARTY_BO_PVT.is_raising_update_event(
                            p_party_id          => x_person_id,
                            p_bo_code           => 'PERSON_CUST'
                          );

      IF(l_per_raise_event) THEN
        -- Get event_id for person
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_per_event_id
        FROM DUAL;
      END IF;

      IF(l_pc_raise_event) THEN
        -- Get event_id for person customer
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_pc_event_id
        FROM DUAL;
      END IF;
    END IF;

    OPEN get_ovn(x_person_id);
    FETCH get_ovn INTO l_ovn, l_party_number;
    CLOSE get_ovn;

    --------------------
    -- For Update Person
    --------------------
    -- Assign person record
    assign_person_rec(
      p_person_obj       => p_person_obj,
      p_person_id        => x_person_id,
      p_person_os        => x_person_os,
      p_person_osr       => x_person_osr,
      p_create_or_update => 'U',
      px_person_rec      => l_person_rec
    );

    HZ_PARTY_V2PUB.update_person(
      p_person_rec                => l_person_rec,
      p_party_object_version_number  => l_ovn,
      x_profile_id                => l_profile_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign person party_id
    p_person_obj.person_id := x_person_id;
    p_person_obj.party_number := l_party_number;
    --------------------------
    -- Create Person Ext Attrs
    --------------------------
    IF((p_person_obj.ext_attributes_objs IS NOT NULL) AND
       (p_person_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_person_obj.ext_attributes_objs,
        p_parent_obj_id             => l_profile_id,
        p_parent_obj_type           => 'PERSON',
        p_create_or_update          => 'U',
        x_return_status             => x_return_status,
        x_errorcode                 => l_errorcode,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ------------------
    -- For Person Info
    ------------------
    IF(((p_person_obj.language_objs IS NOT NULL) AND (p_person_obj.language_objs.COUNT > 0)) OR
       ((p_person_obj.education_objs IS NOT NULL) AND (p_person_obj.education_objs.COUNT > 0)) OR
       ((p_person_obj.citizenship_objs IS NOT NULL) AND (p_person_obj.citizenship_objs.COUNT > 0)) OR
       ((p_person_obj.employ_hist_objs IS NOT NULL) AND (p_person_obj.employ_hist_objs.COUNT > 0)) OR
       ((p_person_obj.interest_objs IS NOT NULL) AND (p_person_obj.interest_objs.COUNT > 0))) THEN
      save_person_info(
        p_language_obj       => p_person_obj.language_objs,
        p_education_obj      => p_person_obj.education_objs,
        p_citizenship_obj    => p_person_obj.citizenship_objs,
        p_employ_hist_obj    => p_person_obj.employ_hist_objs,
        p_interest_obj       => p_person_obj.interest_objs,
        p_person_id          => x_person_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Party Preferences
    ----------------------------
    IF((p_person_obj.preference_objs IS NOT NULL) AND
       (p_person_obj.preference_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_party_preferences(
        p_party_pref_objs           => p_person_obj.preference_objs,
        p_party_id                  => x_person_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Contact Preferences
    ----------------------------
    IF((p_person_obj.contact_pref_objs IS NOT NULL) AND
       (p_person_obj.contact_pref_objs.COUNT > 0)) THEN
      HZ_CONTACT_PREFERENCE_BO_PVT.save_contact_preferences(
        p_cp_pref_objs           => p_person_obj.contact_pref_objs,
        p_contact_level_table_id => x_person_id,
        p_contact_level_table    => 'HZ_PARTIES',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Relationship api
    ----------------------------
    IF((p_person_obj.relationship_objs IS NOT NULL) AND
       (p_person_obj.relationship_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_relationships(
        p_rel_objs                  => p_person_obj.relationship_objs,
        p_subject_id                => x_person_id,
        p_subject_type              => 'PERSON',
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Classification api
    ----------------------------
    IF((p_person_obj.class_objs IS NOT NULL) AND
       (p_person_obj.class_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_classifications(
        p_code_assign_objs          => p_person_obj.class_objs,
        p_owner_table_name          => 'HZ_PARTIES',
        p_owner_table_id            => x_person_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -----------------
    -- For Party Site
    -----------------
    IF((p_person_obj.party_site_objs IS NOT NULL) AND
       (p_person_obj.party_site_objs.COUNT > 0)) THEN
      HZ_PARTY_SITE_BO_PVT.save_party_sites(
        p_ps_objs            => p_person_obj.party_site_objs,
        p_create_update_flag => 'U',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => x_person_id,
        p_parent_os          => x_person_os,
        p_parent_osr         => x_person_osr,
        p_parent_obj_type    => 'PERSON'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ---------------------
    -- For Contact Points
    ---------------------
    IF(((p_person_obj.phone_objs IS NOT NULL) AND (p_person_obj.phone_objs.COUNT > 0)) OR
       ((p_person_obj.email_objs IS NOT NULL) AND (p_person_obj.email_objs.COUNT > 0)) OR
       ((p_person_obj.web_objs IS NOT NULL) AND (p_person_obj.web_objs.COUNT > 0)) OR
       ((p_person_obj.sms_objs IS NOT NULL) AND (p_person_obj.sms_objs.COUNT > 0))) THEN
      HZ_CONTACT_POINT_BO_PVT.save_contact_points(
        p_phone_objs         => p_person_obj.phone_objs,
        p_telex_objs         => l_telex_objs,
        p_email_objs         => p_person_obj.email_objs,
        p_web_objs           => p_person_obj.web_objs,
        p_edi_objs           => l_edi_objs,
        p_eft_objs           => l_eft_objs,
        p_sms_objs           => p_person_obj.sms_objs,
        p_owner_table_id     => x_person_id,
        p_owner_table_os     => x_person_os,
        p_owner_table_osr    => x_person_osr,
        p_parent_obj_type    => 'PERSON',
        p_create_update_flag => 'U',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ---------------------
    -- Certifications
    ---------------------
    IF((p_person_obj.certification_objs IS NOT NULL) AND
       (p_person_obj.certification_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_certifications(
        p_cert_objs          => p_person_obj.certification_objs,
        p_party_id           => x_person_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ---------------------
    -- Financial Profiles
    ---------------------
    IF((p_person_obj.financial_prof_objs IS NOT NULL) AND
       (p_person_obj.financial_prof_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_financial_profiles(
        p_fin_prof_objs      => p_person_obj.financial_prof_objs,
        p_party_id           => x_person_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------------
  --  Party Usages -------
  ----------------------------------
   IF ((p_person_obj.party_usage_objs IS NOT NULL) AND
      (p_person_obj.party_usage_objs.COUNT > 0 )) THEN
       HZ_PARTY_BO_PVT.save_party_usage_assgmnt(
	   p_party_usg_objs				=> p_person_obj.party_usage_objs,
	   p_party_id					=> x_person_id,
	   x_return_status				=> x_return_status,
	   x_msg_count					=> x_msg_count,
	   x_msg_data					=> x_msg_data
	   );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    -- raise update person event
    IF(l_per_raise_event) THEN
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON',
        p_create_or_update => 'U',
        p_obj_source       => p_obj_source,
        p_event_id         => l_per_event_id
      );
    END IF;

    IF(l_pc_raise_event) THEN
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON_CUST',
        p_create_or_update => 'U',
        p_obj_source       => p_obj_source,
        p_event_id         => l_pc_event_id
      );
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_person_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_person_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO do_update_person_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_person_bo;

  PROCEDURE update_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  ) IS
    l_per_obj             HZ_PERSON_BO;
  BEGIN
    l_per_obj := p_person_obj;
    do_update_person_bo(
      p_init_msg_list      => p_init_msg_list,
      p_person_obj         => l_per_obj,
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_person_id          => x_person_id,
      x_person_os          => x_person_os,
      x_person_osr         => x_person_osr
    );
  END update_person_bo;

  PROCEDURE update_person_bo(
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  )IS
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_per_obj         HZ_PERSON_BO;
  BEGIN
    l_per_obj := p_person_obj;
    do_update_person_bo(
      p_init_msg_list      => FND_API.G_TRUE,
      p_person_obj         => l_per_obj,
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_person_id          => x_person_id,
      x_person_os          => x_person_os,
      x_person_osr         => x_person_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_per_obj;
    END IF;
  END update_person_bo;

  -- PROCEDURE do_save_person_bo
  --
  -- DESCRIPTION
  --     Create or update a person business object.
  PROCEDURE do_save_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN OUT NOCOPY HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_person_id := p_person_obj.person_id;
    x_person_os := p_person_obj.orig_system;
    x_person_osr:= p_person_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_person_id,
                              p_entity_os      => x_person_os,
                              p_entity_osr     => x_person_osr,
                              p_entity_type    => 'HZ_PARTIES',
                              p_parent_id      => NULL,
                              p_parent_obj_type=> NULL);

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_person_bo(
        p_init_msg_list      => fnd_api.g_false,
        p_validate_bo_flag   => p_validate_bo_flag,
        p_person_obj         => p_person_obj,
        p_created_by_module  => p_created_by_module,
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        x_person_id          => x_person_id,
        x_person_os          => x_person_os,
        x_person_osr         => x_person_osr
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_person_bo(
        p_init_msg_list      => fnd_api.g_false,
        p_person_obj         => p_person_obj,
        p_created_by_module  => p_created_by_module,
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        x_person_id          => x_person_id,
        x_person_os          => x_person_os,
        x_person_osr         => x_person_osr
      );
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_person_bo;

  PROCEDURE save_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  ) IS
    l_per_obj             HZ_PERSON_BO;
  BEGIN
    l_per_obj := p_person_obj;
    do_save_person_bo(
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_person_obj         => l_per_obj,
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_person_id          => x_person_id,
      x_person_os          => x_person_os,
      x_person_osr         => x_person_osr
    );
  END save_person_bo;

  PROCEDURE save_person_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := NULL,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_per_obj             HZ_PERSON_BO;
  BEGIN
    l_per_obj := p_person_obj;
    do_save_person_bo(
      p_init_msg_list      => FND_API.G_TRUE,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_person_obj         => l_per_obj,
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_person_id          => x_person_id,
      x_person_os          => x_person_os,
      x_person_osr         => x_person_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_per_obj;
    END IF;
  END save_person_bo;

  -- PRIVATE PROCEDURE create_person_info
  --
  -- DESCRIPTION
  --     Create person information, such as language, education, citizenship,
  --     employment history and interest
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_language_obj       Person language object.
  --     p_education_obj      Education object.
  --     p_citizenship_obj    Citizenship object.
  --     p_employ_hist_obj    Employment history object.
  --     p_interest_obj       Person interest object.
  --     p_party_id           Party ID.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_person_info(
    p_language_obj               IN OUT NOCOPY HZ_PERSON_LANG_OBJ_TBL,
    p_education_obj              IN OUT NOCOPY HZ_EDUCATION_OBJ_TBL,
    p_citizenship_obj            IN OUT NOCOPY HZ_CITIZENSHIP_OBJ_TBL,
    p_employ_hist_obj            IN OUT NOCOPY HZ_EMPLOY_HIST_BO_TBL,
    p_interest_obj               IN OUT NOCOPY HZ_PERSON_INTEREST_OBJ_TBL,
    p_person_id                  IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_person_lang_rec     HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE;
    l_education_rec       HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE;
    l_citizenship_rec     HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE;
    l_employ_hist_rec     HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE;
    l_work_class_rec      HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE;
    l_interest_rec        HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE;
    l_dummy_id            NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_person_info_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_person_info(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --------------------------------
    -- Assign person language record
    --------------------------------
    IF(p_language_obj IS NOT NULL) THEN
    FOR i IN 1..p_language_obj.COUNT LOOP
      assign_person_lang_rec(
        p_person_lang_obj           => p_language_obj(i),
        p_party_id                  => p_person_id,
        px_person_lang_rec          => l_person_lang_rec
      );

      HZ_PERSON_INFO_V2PUB.create_person_language(
        p_person_language_rec       => l_person_lang_rec,
        x_language_use_reference_id => l_dummy_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Create Person Language - Error occurred at hz_person_bo_pub.create_person_info, person id: '||p_person_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PERSON_LANGUAGE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign person language_use_reference_id
      p_language_obj(i).language_use_reference_id := l_dummy_id;
    END LOOP;
    END IF;

    --------------------------
    -- Assign education record
    --------------------------
    IF(p_education_obj IS NOT NULL) THEN
    FOR i IN 1..p_education_obj.COUNT LOOP
      assign_education_rec(
        p_education_obj             => p_education_obj(i),
        p_party_id                  => p_person_id,
        px_education_rec            => l_education_rec
      );

      HZ_PERSON_INFO_V2PUB.create_education(
        p_education_rec             => l_education_rec,
        x_education_id              => l_dummy_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Create Education - Error occurred at hz_person_bo_pub.create_person_info, person id: '||p_person_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_EDUCATION');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign education_id
      p_education_obj(i).education_id := l_dummy_id;
    END LOOP;
    END IF;

    ----------------------------
    -- Assign citizenship record
    ----------------------------
    IF(p_citizenship_obj IS NOT NULL) THEN
    FOR i IN 1..p_citizenship_obj.COUNT LOOP
      assign_citizenship_rec(
        p_citizenship_obj           => p_citizenship_obj(i),
        p_party_id                  => p_person_id,
        px_citizenship_rec          => l_citizenship_rec
      );

      HZ_PERSON_INFO_V2PUB.create_citizenship(
        p_citizenship_rec           => l_citizenship_rec,
        x_citizenship_id            => l_dummy_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Create Citizenship - Error occurred at hz_person_bo_pub.create_person_info, person id: '||p_person_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CITIZENSHIP');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign citizenship_id
      p_citizenship_obj(i).citizenship_id := l_dummy_id;
    END LOOP;
    END IF;

    -----------------------------------
    -- Assign employment history record
    -----------------------------------
    IF(p_employ_hist_obj IS NOT NULL) THEN
    FOR i IN 1..p_employ_hist_obj.COUNT LOOP
      assign_employ_hist_rec(
        p_employ_hist_obj           => p_employ_hist_obj(i),
        p_party_id                  => p_person_id,
        px_employ_hist_rec          => l_employ_hist_rec
      );

      HZ_PERSON_INFO_V2PUB.create_employment_history(
        p_employment_history_rec    => l_employ_hist_rec,
        x_employment_history_id     => l_dummy_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Create Employment History - Error occurred at hz_person_bo_pub.create_person_info, person id: '||p_person_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
        FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_EMPLOYMENT_HISTORY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE

        -- assign employment_history_id
        p_employ_hist_obj(i).employment_history_id := l_dummy_id;

        -- Call work class v2api if employment history record is created successfully
        -------------------------------------------------
        -- Assign work class of employment history record
        -------------------------------------------------
        IF(p_employ_hist_obj(i).work_class_objs IS NOT NULL) THEN
        FOR j IN 1..p_employ_hist_obj(i).work_class_objs.COUNT LOOP
          assign_work_class_rec(
            p_work_class_obj            => p_employ_hist_obj(i).work_class_objs(j),
            p_employ_hist_id            => l_dummy_id,
            px_work_class_rec           => l_work_class_rec
          );

          HZ_PERSON_INFO_V2PUB.create_work_class(
            p_work_class_rec            => l_work_class_rec,
            x_work_class_id             => l_dummy_id,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Create Work Class - Error occurred at hz_person_bo_pub.create_person_info, employ_hist_id: '||l_dummy_id,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_WORK_CLASS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- assign work_class_id
          p_employ_hist_obj(i).work_class_objs(j).work_class_id := l_dummy_id;
        END LOOP;
        END IF;
      END IF;
    END LOOP;
    END IF;

    --------------------------------
    -- Assign person interest record
    --------------------------------
    IF(p_interest_obj IS NOT NULL) THEN
    FOR i IN 1..p_interest_obj.COUNT LOOP
      assign_interest_rec(
        p_person_interest_obj       => p_interest_obj(i),
        p_party_id                  => p_person_id,
        px_person_interest_rec      => l_interest_rec
      );

      HZ_PERSON_INFO_V2PUB.create_person_interest(
        p_person_interest_rec       => l_interest_rec,
        x_person_interest_id        => l_dummy_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Create Person Interest - Error occurred at hz_person_bo_pub.create_person_info, person id: '||p_person_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PERSON_INTEREST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign person_interest_id
      p_interest_obj(i).person_interest_id := l_dummy_id;
    END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_person_info(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_person_info_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_person_info(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_person_info_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_person_info(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_person_info_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_person_info(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_person_info;

  -- PRIVATE PROCEDURE save_person_info
  --
  -- DESCRIPTION
  --     Create or update person information, such as language, education, citizenship,
  --     employment history and interest
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_language_obj       Person language object.
  --     p_education_obj      Education object.
  --     p_citizenship_obj    Citizenship object.
  --     p_employ_hist_obj    Employment history object.
  --     p_interest_obj       Person interest object.
  --     p_party_id           Party ID.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_person_info(
    p_language_obj               IN OUT NOCOPY HZ_PERSON_LANG_OBJ_TBL,
    p_education_obj              IN OUT NOCOPY HZ_EDUCATION_OBJ_TBL,
    p_citizenship_obj            IN OUT NOCOPY HZ_CITIZENSHIP_OBJ_TBL,
    p_employ_hist_obj            IN OUT NOCOPY HZ_EMPLOY_HIST_BO_TBL,
    p_interest_obj               IN OUT NOCOPY HZ_PERSON_INTEREST_OBJ_TBL,
    p_person_id                  IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_person_lang_rec     HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE;
    l_education_rec       HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE;
    l_citizenship_rec     HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE;
    l_employ_hist_rec     HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE;
    l_work_class_rec      HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE;
    l_interest_rec        HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE;
    l_dummy_id            NUMBER;
    l_ovn                 NUMBER := NULL;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_person_info_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_person_info(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --------------------------------
    -- Create/Update person language
    --------------------------------
    IF(p_language_obj IS NOT NULL) THEN
    FOR i IN 1..p_language_obj.COUNT LOOP
      assign_person_lang_rec(
        p_person_lang_obj           => p_language_obj(i),
        p_party_id                  => p_person_id,
        px_person_lang_rec          => l_person_lang_rec
      );

      hz_registry_validate_bo_pvt.check_language_op(
        p_party_id              => p_person_id,
        px_language_use_ref_id  => l_person_lang_rec.language_use_reference_id,
        p_language_name         => l_person_lang_rec.language_name,
        x_object_version_number => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Person Language - Error occurred at hz_person_bo_pub.check_language_op, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PERSON_LANGUAGE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_PERSON_INFO_V2PUB.create_person_language(
          p_person_language_rec       => l_person_lang_rec,
          x_language_use_reference_id => l_dummy_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign person language_use_reference_id
        p_language_obj(i).language_use_reference_id := l_dummy_id;
      ELSE
        -- clean up created_by_module for update
        l_person_lang_rec.created_by_module := NULL;
        HZ_PERSON_INFO_V2PUB.update_person_language(
          p_person_language_rec       => l_person_lang_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign person language_use_reference_id
        p_language_obj(i).language_use_reference_id := l_person_lang_rec.language_use_reference_id;
      END IF;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Person Language - Error occurred at hz_person_bo_pub.save_person_info, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PERSON_LANGUAGE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    END IF;

    --------------------------
    -- Create/Update education
    --------------------------
    IF(p_education_obj IS NOT NULL) THEN
    FOR i IN 1..p_education_obj.COUNT LOOP
      assign_education_rec(
        p_education_obj             => p_education_obj(i),
        p_party_id                  => p_person_id,
        px_education_rec            => l_education_rec
      );

      hz_registry_validate_bo_pvt.check_education_op(
        p_party_id             => p_person_id,
        px_education_id        => l_education_rec.education_id,
        p_course_major         => l_education_rec.course_major,
        p_school_attended_name => l_education_rec.school_attended_name,
        p_degree_received      => l_education_rec.degree_received,
        x_object_version_number => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Education - Error occurred at hz_person_bo_pub.check_education_op, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_EDUCATION');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_PERSON_INFO_V2PUB.create_education(
          p_education_rec             => l_education_rec,
          x_education_id              => l_dummy_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign education_id
        p_education_obj(i).education_id := l_dummy_id;
      ELSE
        -- clean up created_by_module for update
        l_education_rec.created_by_module := NULL;
        HZ_PERSON_INFO_V2PUB.update_education(
          p_education_rec             => l_education_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign education_id
        p_education_obj(i).education_id := l_education_rec.education_id;
      END IF;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Education - Error occurred at hz_person_bo_pub.save_person_info, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_EDUCATION');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    END IF;

    ----------------------------
    -- Create/Update citizenship
    ----------------------------
    IF(p_citizenship_obj IS NOT NULL) THEN
    FOR i IN 1..p_citizenship_obj.COUNT LOOP
      assign_citizenship_rec(
        p_citizenship_obj           => p_citizenship_obj(i),
        p_party_id                  => p_person_id,
        px_citizenship_rec          => l_citizenship_rec
      );

      hz_registry_validate_bo_pvt.check_citizenship_op(
        p_party_id             => p_person_id,
        px_citizenship_id      => l_citizenship_rec.citizenship_id,
        p_country_code         => l_citizenship_rec.country_code,
        x_object_version_number => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Citizenship - Error occurred at hz_person_bo_pub.check_citizenship_op, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CITIZENSHIP');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_PERSON_INFO_V2PUB.create_citizenship(
          p_citizenship_rec           => l_citizenship_rec,
          x_citizenship_id            => l_dummy_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign citizenship_id
        p_citizenship_obj(i).citizenship_id := l_dummy_id;
      ELSE
        -- clean up created_by_module for update
        l_citizenship_rec.created_by_module := NULL;
        HZ_PERSON_INFO_V2PUB.update_citizenship(
          p_citizenship_rec           => l_citizenship_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign citizenship_id
        p_citizenship_obj(i).citizenship_id := l_citizenship_rec.citizenship_id;
      END IF;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Citizenship - Error occurred at hz_person_bo_pub.save_person_info, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CITIZENSHIP');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    END IF;

    -----------------------------------
    -- Create/Update employment history
    -----------------------------------
    IF(p_employ_hist_obj IS NOT NULL) THEN
    FOR i IN 1..p_employ_hist_obj.COUNT LOOP
      assign_employ_hist_rec(
        p_employ_hist_obj           => p_employ_hist_obj(i),
        p_party_id                  => p_person_id,
        px_employ_hist_rec          => l_employ_hist_rec
      );

      hz_registry_validate_bo_pvt.check_employ_hist_op(
        p_party_id             => p_person_id,
        px_emp_hist_id         => l_employ_hist_rec.employment_history_id,
        p_employed_by_name_company  => l_employ_hist_rec.employed_by_name_company,
        p_employed_as_title    => l_employ_hist_rec.employed_as_title,
        p_begin_date           => l_employ_hist_rec.begin_date,
        x_object_version_number => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Employment History - Error occurred at hz_person_bo_pub.check_employ_hist_op, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
        FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_EMPLOYMENT_HISTORY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_PERSON_INFO_V2PUB.create_employment_history(
          p_employment_history_rec    => l_employ_hist_rec,
          x_employment_history_id     => l_dummy_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign employment_history_id
        p_employ_hist_obj(i).employment_history_id := l_dummy_id;
      ELSE
        -- clean up created_by_module for update
        l_employ_hist_rec.created_by_module := NULL;
        HZ_PERSON_INFO_V2PUB.update_employment_history(
          p_employment_history_rec    => l_employ_hist_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );
        l_dummy_id := l_employ_hist_rec.employment_history_id;

        -- assign employment_history_id
        p_employ_hist_obj(i).employment_history_id := l_dummy_id;
      END IF;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Employment History - Error occurred at hz_person_bo_pub.save_person_info, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
        FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_EMPLOYMENT_HISTORY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        ---------------------------
        -- Create/Update work class
        ---------------------------
        IF(p_employ_hist_obj(i).work_class_objs IS NOT NULL) THEN
        FOR j IN 1..p_employ_hist_obj(i).work_class_objs.COUNT LOOP
          assign_work_class_rec(
            p_work_class_obj            => p_employ_hist_obj(i).work_class_objs(j),
            p_employ_hist_id            => l_dummy_id,
            px_work_class_rec           => l_work_class_rec
          );

          hz_registry_validate_bo_pvt.check_work_class_op(
            p_employ_hist_id      => l_dummy_id,
            px_work_class_id      => l_work_class_rec.work_class_id,
            p_work_class_name     => l_work_class_rec.work_class_name,
            x_object_version_number => l_ovn
          );

          IF(l_ovn = -1) THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save Work Class - Error occurred at hz_person_bo_pub.check_work_class_op, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
            FND_MSG_PUB.ADD;
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_WORK_CLASS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF(l_ovn IS NULL) THEN
            HZ_PERSON_INFO_V2PUB.create_work_class(
              p_work_class_rec            => l_work_class_rec,
              x_work_class_id             => l_dummy_id,
              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data
            );

            -- assign work_class_id
            p_employ_hist_obj(i).work_class_objs(j).work_class_id := l_dummy_id;
          ELSE
            -- clean up created_by_module for update
            l_work_class_rec.created_by_module := NULL;
            HZ_PERSON_INFO_V2PUB.update_work_class(
              p_work_class_rec            => l_work_class_rec,
              p_object_version_number     => l_ovn,
              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data
            );

           -- assign work_class_id
            p_employ_hist_obj(i).work_class_objs(j).work_class_id := l_work_class_rec.work_class_id;
          END IF;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save Work Class - Error occurred at hz_person_bo_pub.save_person_info, employ_hist_id: '||l_dummy_id||' '||' ovn:'||l_ovn,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_WORK_CLASS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
        END IF;
      END IF;
    END LOOP;
    END IF;

    -------------------------
    -- Create/Update interest
    -------------------------
    IF(p_interest_obj IS NOT NULL) THEN
    FOR i IN 1..p_interest_obj.COUNT LOOP
      assign_interest_rec(
        p_person_interest_obj       => p_interest_obj(i),
        p_party_id                  => p_person_id,
        px_person_interest_rec      => l_interest_rec
      );

      hz_registry_validate_bo_pvt.check_interest_op(
        p_party_id            => p_person_id,
        px_interest_id        => l_interest_rec.person_interest_id,
        p_interest_type_code  => l_interest_rec.interest_type_code,
        p_sub_interest_type_code  => l_interest_rec.sub_interest_type_code,
        p_interest_name       => l_interest_rec.interest_name,
        x_object_version_number => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Person Interest - Error occurred at hz_person_bo_pub.check_interest_op, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PERSON_INTEREST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_PERSON_INFO_V2PUB.create_person_interest(
          p_person_interest_rec       => l_interest_rec,
          x_person_interest_id        => l_dummy_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign person_interest_id
        p_interest_obj(i).person_interest_id := l_dummy_id;
      ELSE
        -- clean up created_by_module for update
        l_interest_rec.created_by_module := NULL;
        HZ_PERSON_INFO_V2PUB.update_person_interest(
          p_person_interest_rec       => l_interest_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign person_interest_id
        p_interest_obj(i).person_interest_id := l_interest_rec.person_interest_id;
      END IF;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Person Interest - Error occurred at hz_person_bo_pub.save_person_info, person id: '||p_person_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PERSON_INTEREST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_person_info(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_person_info_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_person_info(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_person_info_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_person_info(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_person_info_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_person_info(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_person_info;

  --------------------------------------
  --
  -- PROCEDURE get_person_bo
  --
  -- DESCRIPTION
  --     Get a logical person.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_person_id          Person ID.
  --     p_person_os          Person orig system.
  --     p_person_osr         Person orig system reference.
  --   OUT:
  --     x_person_obj         Logical person record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   10-JUN-2005   AWU                Created.
  --

/*
The Get Person API Procedure is a retrieval service that returns a full Person business object.
The user identifies a particular Person business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person business object is returned. The object consists of all data included within
the Person business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Party Site		N	Y		get_party_site_bo
Phone			N	Y		get_phone_bo
Email			N	Y		get_email_bo
Web			N	Y		get_web_bo
SMS			N	Y		get_sms_bo
Employment History	N	Y	Business Structure. Included entities:HZ_EMPLOYMENT_HISTORY, HZ_WORK_CLASS


To retrieve the appropriate embedded entities within the Person business object,
the Get procedure returns all records for the particular person from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Party,Person Profile	Y		N	HZ_PARTIES, HZ_PERSON_PROFILES
Person Preference	N		Y	HZ_PARTY_PREFERENCES
Relationship		N		Y	HZ_RELATIONSHIPS
Classification		N		Y	HZ_CODE_ASSIGNMENTS
Language		N		Y	HZ_PERSON_LANGUAGE
Education		N		Y	HZ_EDUCATION
Citizenship		N		Y	HZ_CITIZENSHIP
Interest		N		Y	HZ_PERSON_INTEREST
Certification		N		Y	HZ_CERTIFICATIONS
Financial Profile	N		Y	HZ_FINANCIAL_PROFILE
*/

PROCEDURE get_person_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_person_id		IN	NUMBER,
	p_person_os		IN	VARCHAR2,
	p_person_osr		IN	VARCHAR2,
	x_person_obj	  	OUT NOCOPY	HZ_PERSON_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_person_id  number;
  l_person_os  varchar2(30);
  l_person_osr varchar2(255);
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_person_id := p_person_id;
    	l_person_os := p_person_os;
    	l_person_osr := p_person_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_person_id,
      		px_os              => l_person_os,
      		px_osr             => l_person_osr,
      		p_obj_type         => 'PERSON',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_PERSON_BO_PVT.get_person_bo(
    		p_init_msg_list   => fnd_api.g_false,
    		p_person_id => l_person_id,
    		p_action_type	  => NULL,
    		x_person_obj => x_person_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_person_bo (
    p_person_id         IN      NUMBER,
    p_person_os         IN      VARCHAR2,
    p_person_osr        IN      VARCHAR2,
    x_person_obj        OUT NOCOPY      HZ_PERSON_BO,
    x_return_status     OUT NOCOPY      VARCHAR2,
    x_messages          OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
  ) is
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
  BEGIN
    get_person_bo(
      p_init_msg_list      => FND_API.G_TRUE,
      p_person_id          => p_person_id,
      p_person_os          => p_person_os,
      p_person_osr         => p_person_osr,
      x_person_obj         => x_person_obj,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_person_bo;

 --------------------------------------
  --
  -- PROCEDURE get_persons_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons created business event and
  --the procedure returns database objects of the type HZ_PERSON_BO for all of
  --the Person business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_obj        One or more created logical person.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   10-JUN-2005    AWU                Created.
  --



/*
The Get Persons Created procedure is a service to retrieve all of the Person business objects
whose creations have been captured by a logical business event. Each Persons Created
business event signifies that one or more Person business objects have been created.
The caller provides an identifier for the Persons Created business event and the procedure
returns all of the Person business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_BO_PVT.get_person_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_persons_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_debug_prefix              VARCHAR2(30) := '';
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'C',
			    p_bo_code => 'PERSON',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PERSON_BO_PVT.get_persons_created(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		x_person_objs  => x_person_objs,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_created (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_persons_created(
    p_event_id            IN            NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
  BEGIN
    get_persons_created(
      p_init_msg_list      => FND_API.G_TRUE,
      p_event_id           => p_event_id,
      x_person_objs        => x_person_objs,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_persons_created;

--------------------------------------
  --
  -- PROCEDURE get_persons_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons update business event and
  --the procedure returns database objects of the type HZ_PERSON_BO for all of
  --the Person business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   10-JUN-2005     AWU                Created.
  --



/*
The Get Persons Updated procedure is a service to retrieve all of the Person business objects whose updates have been
captured by the logical business event. Each Persons Updated business event signifies that one or more Person business
objects have been updated.
The caller provides an identifier for the Persons Update business event and the procedure returns database objects of the
type HZ_PERSON_BO for all of the Person business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure and
returns them to the caller.
*/

 PROCEDURE get_persons_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

l_debug_prefix              VARCHAR2(30) := '';
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'U',
			    p_bo_code => 'PERSON',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PERSON_BO_PVT.get_persons_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		x_person_objs  => x_person_objs,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_persons_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_persons_updated(
    p_event_id            IN            NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
  BEGIN
    get_persons_updated(
      p_init_msg_list      => FND_API.G_TRUE,
      p_event_id           => p_event_id,
      x_person_objs        => x_person_objs,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_persons_updated;

--------------------------------------
  --
  -- PROCEDURE get_person_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons update business event and person_id
  --the procedure returns one database object of the type HZ_PERSON_BO

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_id          Person identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   10-JUN-2005     AWU                Created.
  --



-- Get only one person object based on p_person_id and event_id

PROCEDURE get_person_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_id           IN           NUMBER,
    x_person_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_debug_prefix              VARCHAR2(30) := '';
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => p_person_id,
			    p_event_type => 'U',
			    p_bo_code => 'PERSON',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	HZ_EXTRACT_PERSON_BO_PVT.get_person_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
		p_person_id  => p_person_id,
    		x_person_obj  => x_person_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_person_bo_pub.get_person_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_person_updated(
    p_event_id            IN            NUMBER,
    p_person_id           IN           NUMBER,
    x_person_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
  BEGIN
    get_person_updated(
      p_init_msg_list      => FND_API.G_TRUE,
      p_event_id           => p_event_id,
      p_person_id          => p_person_id,
      x_person_obj         => x_person_obj,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_person_updated;

-- get TCA identifiers for create event
PROCEDURE get_ids_persons_created (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_person_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2

) is
l_debug_prefix              VARCHAR2(30) := '';

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_ids_persons_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'C',
			    p_bo_code => 'PERSON',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => x_person_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_ids_persons_created (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_persons_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_persons_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_persons_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


-- get TCA identifiers for update event
PROCEDURE get_ids_persons_updated (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_person_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) is
l_debug_prefix              VARCHAR2(30) := '';

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_ids_persons_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'U',
			    p_bo_code => 'PERSON',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => x_person_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_ids_persons_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_persons_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_persons_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_persons_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

END hz_person_bo_pub;

/
