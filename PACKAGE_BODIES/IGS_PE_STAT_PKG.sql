--------------------------------------------------------
--  DDL for Package Body IGS_PE_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_STAT_PKG" AS
/* $Header: IGSNI48B.pls 120.2 2006/02/17 06:53:22 gmaheswa ship $ */
------------------------------------------------------------------
-- Change History

--
-- Bug ID : 2000408
-- who      when          what
--sbaliga    6-May-2002    Modified Insert_row and Update_row as part of #2338473
-- CDCRUZ   Sep 24,2002   New Col's added for
--                        Person DLD
--  Columns Added     - MATR_CAL_TYPE/MATR_SEQUENCE_NUMBER/INIT_CAL_TYPE/INIT_SEQUENCE_NUMBER
--                      RECENT_CAL_TYPE/RECENT_SEQUENCE_NUMBER/CATALOG_CAL_TYPE/CATALOG_SEQUENCE_NUMBER
--bayadav   31-Jan-2002   Added one DFF in IGS_PE_STAT_DETAILS and DFF columns in IGS_AD_STAT_INT table.
--                        Due to which 1)Using the columns attribute1 to attribute20  parameters of this TBH
--                       to transfer the data from IGS_AD_STAT_INT DFF columns to IGS_PE_STAT_DETAILS
--                        DFF columns
--                       2)Changing the earlier use of these parameters  attribute1 to attribute20 for HZ table to NULL .Bug number:2203778
--bayadav   6-Feb-2002   Removed seven columns from igs_pe_stat_details_pkg call as a aprt of bug:2203778
--                       1 Person_profile_id 2 acad_dismissal 3 non_acad_dismissal 4 resid_stat_id 5 criminal_convict 6 country_cd3 7 state_of_residence
--                       and added Person_id
------------------------------------------------------------------

  l_rowid VARCHAR2(25);
  old_references igs_pe_stat_v%ROWTYPE;
  new_references igs_pe_stat_v%ROWTYPE;
  Y_RETURN_STATUS VARCHAR2(1);
  Z_RETURN_STATUS VARCHAR2(1);
  Y_MSG_DATA VARCHAR2(2000);
  Y_PROFILE_ID igs_pe_stat_v.person_profile_id%TYPE;
  Z_PROFILE_ID igs_pe_stat_v.person_profile_id%TYPE;
  XXX_ROWID VARCHAR2(25);
  Y_MSG_COUNT NUMBER;
  Z_MSG_COUNT NUMBER;
  Z_MSG_DATA VARCHAR2(2000);
  PROCEDURE Set_Column_Values (
             X_action               IN VARCHAR2 ,--DEFAULT NULL,
             X_ROWID                IN OUT NOCOPY VARCHAR2 ,
             X_PERSON_ID            IN NUMBER ,--DEFAULT NULL,
             X_ETHNIC_ORIGIN_ID         IN  VARCHAR2,-- DEFAULT NULL,
             X_MARITAL_STATUS       IN VARCHAR2 ,--DEFAULT NULL,
             X_MARITAL_STAT_EFFECT_DT   IN DATE ,-- DEFAULT NULL,
             X_ANN_FAMILY_INCOME        IN NUMBER ,--DEFAULT NULL,
             X_NUMBER_IN_FAMILY         IN NUMBER ,--DEFAULT NULL,
             X_CONTENT_SOURCE_TYPE      IN VARCHAR2 ,--DEFAULT NULL,
             X_INTERNAL_FLAG            IN VARCHAR2 ,--DEFAULT NULL,
             X_PERSON_NUMBER            IN VARCHAR2 ,-- DEFAULT NULL,
             X_EFFECTIVE_START_DATE     IN DATE ,--DEFAULT NULL,
             X_effective_end_date       IN DATE ,--DEFAULT NULL,
             X_ethnic_origin            IN VARCHAR2,-- DEFAULT NULL,
             X_religion             IN VARCHAR2,-- DEFAULT NULL,
             X_next_to_kin              IN VARCHAR2,-- DEFAULT NULL,
             X_next_to_kin_meaning      IN VARCHAR2 ,-- DEFAULT NULL,
             X_place_of_birth       IN VARCHAR2 ,--DEFAULT NULL,
             X_socio_eco_status         IN VARCHAR2,-- DEFAULT NULL,
           X_socio_eco_status_desc      IN VARCHAR2,-- DEFAULT NULL,
             X_further_education        IN VARCHAR2,-- DEFAULT NULL,
             X_further_education_desc   IN VARCHAR2,-- DEFAULT NULL,
             X_in_state_tuition         IN VARCHAR2,-- DEFAULT NULL,
             X_tuition_st_Date          IN DATE ,--DEFAULT NULL,
             X_tuition_end_date         IN DATE ,-- DEFAULT NULL,
             X_person_initials      IN VARCHAR2 ,--DEFAULT NULL,
             X_primary_contact_id       IN NUMBER ,--DEFAULT NULL,
             X_personal_income      IN NUMBER ,--DEFAULT NULL,
             X_head_of_household_flag   IN VARCHAR2 ,--DEFAULT NULL,
             X_content_source_number    IN VARCHAR2 ,--DEFAULT NULL,
         x_hz_parties_ovn           IN NUMBER,
             X_ATTRIBUTE_CATEGORY       IN VARCHAR2,-- DEFAULT NULL,
             X_ATTRIBUTE1           IN VARCHAR2 ,-- DEFAULT NULL,
             X_ATTRIBUTE2           IN VARCHAR2 ,--DEFAULT NULL,
             X_ATTRIBUTE3           IN VARCHAR2 ,--DEFAULT NULL,
             X_ATTRIBUTE4           IN VARCHAR2 ,--DEFAULT NULL,
             X_ATTRIBUTE5           IN VARCHAR2 ,--DEFAULT NULL,
             X_ATTRIBUTE6           IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE7           IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE8           IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE9           IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE10          IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE11              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE12              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE13              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE14              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE15              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE16              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE17              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE18              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE19              IN VARCHAR2 ,--DEFAULT NULL,
         X_ATTRIBUTE20              IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE_CATEGORY    IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE1        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE2        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE3        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE4        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE5        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE6        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE7        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE8        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE9        IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE10       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE11       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE12       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE13       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE14       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE15       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE16       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE17       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE18       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE19       IN VARCHAR2 ,--DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE20       IN VARCHAR2 ,--DEFAULT NULL,
         X_PARTY_LAST_UPDATE_DATE   IN OUT NOCOPY DATE ,
         X_PERSON_PROFILE_ID        IN OUT NOCOPY NUMBER ,
         X_MATR_CAL_TYPE            IN     VARCHAR2  ,--  DEFAULT NULL ,
         X_MATR_SEQUENCE_NUMBER     IN     NUMBER    ,--  DEFAULT NULL,
         X_INIT_CAL_TYPE            IN     VARCHAR2  ,--  DEFAULT NULL ,
         X_INIT_SEQUENCE_NUMBER     IN     NUMBER     ,-- DEFAULT NULL,
         X_RECENT_CAL_TYPE          IN     VARCHAR2  ,--  DEFAULT NULL ,
         X_RECENT_SEQUENCE_NUMBER   IN     NUMBER     ,-- DEFAULT NULL,
         X_CATALOG_CAL_TYPE         IN     VARCHAR2  ,--  DEFAULT NULL ,
         X_CATALOG_SEQUENCE_NUMBER  IN     NUMBER     ,-- DEFAULT NULL,
         Z_RETURN_STATUS            OUT NOCOPY VARCHAR2 ,
         Z_MSG_COUNT                OUT NOCOPY NUMBER ,
         Z_MSG_DATA                 OUT NOCOPY VARCHAR2,
	 X_BIRTH_CNTRY_RESN_CODE    IN     VARCHAR2 --DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : svisweas
  Date Created By :23-MAY-2000
  Purpose : TO SET COLUMN VALUES
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svisweas  26-may-2000 get_fk_igs_lookups_view procedure from tbh.
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_STAT_V
      WHERE    ROW_ID = X_rowid;
  BEGIN
    l_rowid := X_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (X_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      APP_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
             new_references.PERSON_ID           := X_PERSON_ID;
             new_references.ETHNIC_ORIGIN_ID        := X_ETHNIC_ORIGIN_ID;
             new_references.MARITAL_STATUS      := X_MARITAL_STATUS;
             new_references.MARITAL_STATUS_EFFECTIVE_DATE   := X_MARITAL_STAT_EFFECT_DT;
             new_references.ANN_FAMILY_INCOME       :=X_ANN_FAMILY_INCOME;
             new_references.NUMBER_IN_FAMILY        :=X_NUMBER_IN_FAMILY;
             new_references.CONTENT_SOURCE_TYPE     :=X_CONTENT_SOURCE_TYPE;
             new_references.INTERNAL_FLAG           :=X_INTERNAL_FLAG;
             new_references.PERSON_NUMBER           :=X_PERSON_NUMBER;
             new_references.EFFECTIVE_START_DATE    :=X_EFFECTIVE_START_DATE;
             new_references.effective_end_date      :=X_EFFECTIVE_END_DATE;
             new_references.ethnic_origin           :=X_ETHNIC_ORIGIN;
             new_references.religion            :=X_RELIGION;
             new_references.next_to_kin             :=X_NEXT_TO_KIN;
             new_references.next_to_kin_meaning     := X_NEXT_TO_KIN_MEANING;
             new_references.place_of_birth          :=X_PLACE_OF_BIRTH;
             new_references.socio_eco_status        :=X_SOCIO_ECO_STATUS;
           new_references.socio_eco_status_desc     :=X_SOCIO_ECO_STATUS_DESC;
             new_references.further_education       :=X_FURTHER_EDUCATION;
             new_references.further_education_desc      :=X_FURTHER_EDUCATION_DESC;
             new_references.in_state_tuition        :=X_IN_STATE_TUITION;
             new_references.tuition_st_Date         :=X_TUITION_ST_DATE;
             new_references.tuition_end_date        :=X_TUITION_END_DATE;
             new_references.person_initials         :=X_PERSON_INITIALS;
             new_references.primary_contact_id      :=X_PRIMARY_CONTACT_ID;
             new_references.personal_income         :=X_PERSONAL_INCOME;
             new_references.head_of_household_flag  :=X_HEAD_OF_HOUSEHOLD_FLAG;
             new_references.content_source_number   :=X_CONTENT_SOURCE_NUMBER;
         new_references.object_version_number       :=X_HZ_PARTIES_OVN;
             new_references.ATTRIBUTE_CATEGORY      :=X_ATTRIBUTE_CATEGORY;
             new_references.ATTRIBUTE1          :=X_ATTRIBUTE1;
             new_references.ATTRIBUTE2          :=X_ATTRIBUTE2;
             new_references.ATTRIBUTE3          :=X_ATTRIBUTE3;
             new_references.ATTRIBUTE4          :=X_ATTRIBUTE4;
             new_references.ATTRIBUTE5              :=X_ATTRIBUTE5;
             new_references.ATTRIBUTE6              :=X_ATTRIBUTE6;
         new_references.ATTRIBUTE7              :=X_ATTRIBUTE7;
         new_references.ATTRIBUTE8              :=X_ATTRIBUTE8;
         new_references.ATTRIBUTE9          :=X_ATTRIBUTE9;
         new_references.ATTRIBUTE10             :=X_ATTRIBUTE10;
         new_references.ATTRIBUTE11             :=X_ATTRIBUTE11;
         new_references.ATTRIBUTE12             :=X_ATTRIBUTE12;
         new_references.ATTRIBUTE13             :=X_ATTRIBUTE13;
         new_references.ATTRIBUTE14             :=X_ATTRIBUTE14;
         new_references.ATTRIBUTE15             :=X_ATTRIBUTE15;
         new_references.ATTRIBUTE16             :=X_ATTRIBUTE16;
         new_references.ATTRIBUTE17             :=X_ATTRIBUTE17;
         new_references.ATTRIBUTE18             :=X_ATTRIBUTE18;
         new_references.ATTRIBUTE19             :=X_ATTRIBUTE19;
         new_references.ATTRIBUTE20             :=X_ATTRIBUTE20;
         new_references.GLOBAL_ATTRIBUTE_CATEGORY   :=X_GLOBAL_ATTRIBUTE_CATEGORY;
         new_references.GLOBAL_ATTRIBUTE1         :=X_GLOBAL_ATTRIBUTE1;
         new_references.GLOBAL_ATTRIBUTE2         :=X_GLOBAL_ATTRIBUTE2;
         new_references.GLOBAL_ATTRIBUTE3         :=X_GLOBAL_ATTRIBUTE3;
         new_references.GLOBAL_ATTRIBUTE4       :=X_GLOBAL_ATTRIBUTE4;
         new_references.GLOBAL_ATTRIBUTE5       :=X_GLOBAL_ATTRIBUTE5;
         new_references.GLOBAL_ATTRIBUTE6       :=X_GLOBAL_ATTRIBUTE6;
         new_references.GLOBAL_ATTRIBUTE7       :=X_GLOBAL_ATTRIBUTE7;
         new_references.GLOBAL_ATTRIBUTE8       :=X_GLOBAL_ATTRIBUTE8;
         new_references.GLOBAL_ATTRIBUTE9       :=X_GLOBAL_ATTRIBUTE9;
         new_references.GLOBAL_ATTRIBUTE10      :=X_GLOBAL_ATTRIBUTE10;
         new_references.GLOBAL_ATTRIBUTE11          :=X_GLOBAL_ATTRIBUTE11;
         new_references.GLOBAL_ATTRIBUTE12          :=X_GLOBAL_ATTRIBUTE12;
         new_references.GLOBAL_ATTRIBUTE13          :=X_GLOBAL_ATTRIBUTE13;
           new_references. GLOBAL_ATTRIBUTE14       :=X_GLOBAL_ATTRIBUTE14;
         new_references.GLOBAL_ATTRIBUTE15          :=X_GLOBAL_ATTRIBUTE15;
         new_references.GLOBAL_ATTRIBUTE16      :=X_GLOBAL_ATTRIBUTE16;
         new_references.GLOBAL_ATTRIBUTE17          :=X_GLOBAL_ATTRIBUTE17;
         new_references.GLOBAL_ATTRIBUTE18          :=X_GLOBAL_ATTRIBUTE18;
         new_references.GLOBAL_ATTRIBUTE19          :=X_GLOBAL_ATTRIBUTE19;
         new_references.GLOBAL_ATTRIBUTE20          :=X_GLOBAL_ATTRIBUTE20;
	 new_references.matr_cal_type               := X_MATR_CAL_TYPE ;
	 new_references.matr_sequence_number        := X_MATR_SEQUENCE_NUMBER ;
	 new_references.init_cal_type               := X_INIT_CAL_TYPE ;
	 new_references.init_sequence_number        := X_INIT_SEQUENCE_NUMBER ;
	 new_references.recent_cal_type             := X_RECENT_CAL_TYPE ;
	 new_references.recent_sequence_number      := X_RECENT_SEQUENCE_NUMBER ;
	 new_references.catalog_cal_type            := X_CATALOG_CAL_TYPE ;
	 new_references.catalog_sequence_number     := X_CATALOG_SEQUENCE_NUMBER ;
	 new_references.birth_cntry_resn_code       := X_BIRTH_CNTRY_RESN_CODE;

        -- new_references.PARTY_LAST_UPDATE_DATE    :=X_PARTY_LAST_UPDATE_DATE;
       --  new_references.PROFILE_ID            :=Z_PROFILE_ID;
/*           new_references.RETURN_STATUS
         new_references.MSG_COUNT
         new_references.MSG_DATA            */
-- END OF POPULATION
  END Set_Column_Values;

  PROCEDURE Before_DML (
             X_action               IN VARCHAR2,-- DEFAULT NULL,
             X_ROWID                IN OUT NOCOPY VARCHAR2 ,
             X_PERSON_ID            IN NUMBER ,--DEFAULT NULL,
             X_ETHNIC_ORIGIN_ID         IN  VARCHAR2 ,--DEFAULT NULL,
             X_MARITAL_STATUS       IN VARCHAR2 ,--DEFAULT NULL,
             X_MARITAL_STAT_EFFECT_DT   IN DATE ,-- DEFAULT NULL,
             X_ANN_FAMILY_INCOME        IN NUMBER,-- DEFAULT NULL,
             X_NUMBER_IN_FAMILY         IN NUMBER,-- DEFAULT NULL,
             X_CONTENT_SOURCE_TYPE      IN VARCHAR2 ,--DEFAULT NULL,
             X_INTERNAL_FLAG            IN VARCHAR2,-- DEFAULT NULL,
             X_PERSON_NUMBER            IN VARCHAR2,--  DEFAULT NULL,
             X_EFFECTIVE_START_DATE     IN DATE,-- DEFAULT NULL,
             X_effective_end_date       IN DATE ,--DEFAULT NULL,
             X_ethnic_origin            IN VARCHAR2,-- DEFAULT NULL,
             X_religion             IN VARCHAR2,-- DEFAULT NULL,
             X_next_to_kin              IN VARCHAR2,-- DEFAULT NULL,
             X_next_to_kin_meaning      IN VARCHAR2,-- DEFAULT NULL,
             X_place_of_birth       IN VARCHAR2,-- DEFAULT NULL,
             X_socio_eco_status         IN VARCHAR2,-- DEFAULT NULL,
           X_socio_eco_status_desc      IN VARCHAR2,-- DEFAULT NULL,
             X_further_education        IN VARCHAR2,-- DEFAULT NULL,
             X_further_education_desc   IN VARCHAR2,-- DEFAULT NULL,
             X_in_state_tuition         IN VARCHAR2,-- DEFAULT NULL,
             X_tuition_st_Date          IN DATE,-- DEFAULT NULL,
             X_tuition_end_date         IN DATE,--  DEFAULT NULL,
             X_person_initials      IN VARCHAR2,-- DEFAULT NULL,
             X_primary_contact_id       IN NUMBER,-- DEFAULT NULL,
             X_personal_income      IN NUMBER,-- DEFAULT NULL,
             X_head_of_household_flag   IN VARCHAR2,-- DEFAULT NULL,
             X_content_source_number    IN VARCHAR2,-- DEFAULT NULL,
         x_hz_parties_ovn           IN NUMBER,
             X_ATTRIBUTE_CATEGORY       IN VARCHAR2,-- DEFAULT NULL,
             X_ATTRIBUTE1           IN VARCHAR2,--  DEFAULT NULL,
             X_ATTRIBUTE2           IN VARCHAR2,-- DEFAULT NULL,
             X_ATTRIBUTE3           IN VARCHAR2,-- DEFAULT NULL,
             X_ATTRIBUTE4           IN VARCHAR2,-- DEFAULT NULL,
             X_ATTRIBUTE5           IN VARCHAR2,-- DEFAULT NULL,
             X_ATTRIBUTE6           IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE7           IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE8           IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE9           IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE10          IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE11              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE12              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE13              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE14              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE15              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE16              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE17              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE18              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE19              IN VARCHAR2,-- DEFAULT NULL,
         X_ATTRIBUTE20              IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE_CATEGORY    IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE1        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE2        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE3        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE4        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE5        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE6        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE7        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE8        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE9        IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE10       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE11       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE12       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE13       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE14       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE15       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE16       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE17       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE18       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE19       IN VARCHAR2,-- DEFAULT NULL,
         X_GLOBAL_ATTRIBUTE20       IN VARCHAR2,-- DEFAULT NULL,
             X_MATR_CAL_TYPE                     IN     VARCHAR2,--    DEFAULT NULL ,
             X_MATR_SEQUENCE_NUMBER              IN     NUMBER  ,--    DEFAULT NULL,
             X_INIT_CAL_TYPE                     IN     VARCHAR2,--    DEFAULT NULL ,
             X_INIT_SEQUENCE_NUMBER             IN     NUMBER   ,--   DEFAULT NULL,
             X_RECENT_CAL_TYPE                   IN     VARCHAR2,--    DEFAULT NULL ,
             X_RECENT_SEQUENCE_NUMBER           IN     NUMBER   ,--   DEFAULT NULL,
             X_CATALOG_CAL_TYPE                  IN     VARCHAR2,--    DEFAULT NULL ,
             X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER   ,--   DEFAULT NULL,
         X_PARTY_LAST_UPDATE_DATE   IN OUT NOCOPY DATE ,
         X_PERSON_PROFILE_ID        IN OUT NOCOPY NUMBER,
	 X_BIRTH_CNTRY_RESN_CODE	    IN VARCHAR2

  ) AS
  /*************************************************************
  Created By : svisweas
  Date Created By :23-MAY-2000
  Purpose : TO VALIDATE BEFORE DML
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svisweas  26-may-2000 get_fk_igs_lookups_view procedure from tbh.
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    Set_Column_Values (
             X_action,
             X_ROWID,
             X_PERSON_ID,
             X_ETHNIC_ORIGIN_ID,
             X_MARITAL_STATUS ,
             X_MARITAL_STAT_EFFECT_DT,
             X_ANN_FAMILY_INCOME ,
             X_NUMBER_IN_FAMILY  ,
             X_CONTENT_SOURCE_TYPE ,
             X_INTERNAL_FLAG    ,
             X_PERSON_NUMBER    ,
             X_EFFECTIVE_START_DATE,
             X_effective_end_date ,
             X_ethnic_origin    ,
             X_religion     ,
             X_next_to_kin          ,
             X_next_to_kin_meaning  ,
             X_place_of_birth   ,
             X_socio_eco_status     ,
           X_socio_eco_status_desc ,
             X_further_education    ,
             X_further_education_desc,
             X_in_state_tuition     ,
             X_tuition_st_Date      ,
             X_tuition_end_date     ,
             X_person_initials  ,
             X_primary_contact_id   ,
             X_personal_income  ,
             X_head_of_household_flag,
             X_content_source_number ,
         x_hz_parties_ovn,
             X_ATTRIBUTE_CATEGORY   ,
             X_ATTRIBUTE1       ,
             X_ATTRIBUTE2       ,
             X_ATTRIBUTE3       ,
             X_ATTRIBUTE4       ,
             X_ATTRIBUTE5       ,
             X_ATTRIBUTE6       ,
         X_ATTRIBUTE7       ,
         X_ATTRIBUTE8       ,
         X_ATTRIBUTE9       ,
         X_ATTRIBUTE10      ,
         X_ATTRIBUTE11          ,
         X_ATTRIBUTE12          ,
         X_ATTRIBUTE13          ,
         X_ATTRIBUTE14          ,
         X_ATTRIBUTE15          ,
         X_ATTRIBUTE16          ,
         X_ATTRIBUTE17          ,
         X_ATTRIBUTE18          ,
         X_ATTRIBUTE19          ,
         X_ATTRIBUTE20          ,
         X_GLOBAL_ATTRIBUTE_CATEGORY,
         X_GLOBAL_ATTRIBUTE1    ,
         X_GLOBAL_ATTRIBUTE2    ,
         X_GLOBAL_ATTRIBUTE3    ,
         X_GLOBAL_ATTRIBUTE4    ,
         X_GLOBAL_ATTRIBUTE5    ,
         X_GLOBAL_ATTRIBUTE6    ,
         X_GLOBAL_ATTRIBUTE7    ,
         X_GLOBAL_ATTRIBUTE8    ,
         X_GLOBAL_ATTRIBUTE9    ,
         X_GLOBAL_ATTRIBUTE10   ,
         X_GLOBAL_ATTRIBUTE11   ,
         X_GLOBAL_ATTRIBUTE12   ,
         X_GLOBAL_ATTRIBUTE13   ,
         X_GLOBAL_ATTRIBUTE14   ,
         X_GLOBAL_ATTRIBUTE15   ,
         X_GLOBAL_ATTRIBUTE16   ,
         X_GLOBAL_ATTRIBUTE17   ,
         X_GLOBAL_ATTRIBUTE18   ,
         X_GLOBAL_ATTRIBUTE19   ,
         X_GLOBAL_ATTRIBUTE20   ,
         X_PARTY_LAST_UPDATE_DATE ,
         X_PERSON_PROFILE_ID        ,
             X_MATR_CAL_TYPE,
             X_MATR_SEQUENCE_NUMBER,
             X_INIT_CAL_TYPE,
             X_INIT_SEQUENCE_NUMBER,
             X_RECENT_CAL_TYPE,
             X_RECENT_SEQUENCE_NUMBER,
             X_CATALOG_CAL_TYPE,
             X_CATALOG_SEQUENCE_NUMBER,
         Z_RETURN_STATUS        ,
         Z_MSG_COUNT            ,
         Z_MSG_DATA         ,
	 X_BIRTH_CNTRY_RESN_CODE
    );
    IF (X_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      NULL;

    ELSIF (X_action = 'UPDATE') THEN
     NULL;
    ELSIF (X_action = 'VALIDATE_INSERT') THEN
     -- Call all the procedures related to Before Insert.
      NULL;
    ELSIF (X_action = 'VALIDATE_UPDATE') THEN
      NULL;
    END IF;
  END Before_DML;
 PROCEDURE INSERT_ROW (
             X_action               IN VARCHAR2 ,
             X_ROWID                IN OUT NOCOPY VARCHAR2,
             X_PERSON_ID            IN NUMBER ,
             X_ETHNIC_ORIGIN_ID         IN  VARCHAR2 ,
             X_MARITAL_STATUS       IN VARCHAR2 ,
             X_MARITAL_STAT_EFFECT_DT   IN DATE  ,
             X_ANN_FAMILY_INCOME        IN NUMBER ,
             X_NUMBER_IN_FAMILY         IN NUMBER ,
             X_CONTENT_SOURCE_TYPE      IN VARCHAR2 ,
             X_INTERNAL_FLAG            IN VARCHAR2 ,
             X_PERSON_NUMBER            IN VARCHAR2 ,
             X_EFFECTIVE_START_DATE     IN DATE ,
             X_effective_end_date       IN DATE ,
             X_ethnic_origin            IN VARCHAR2 ,
             X_religion             IN VARCHAR2 ,
             X_next_to_kin              IN VARCHAR2 ,
             X_next_to_kin_meaning      IN VARCHAR2 ,
             X_place_of_birth       IN VARCHAR2 ,
             X_socio_eco_status         IN VARCHAR2 ,
           X_socio_eco_status_desc      IN VARCHAR2 ,
             X_further_education        IN VARCHAR2 ,
             X_further_education_desc   IN VARCHAR2 ,
             X_in_state_tuition         IN VARCHAR2 ,
             X_tuition_st_Date          IN DATE ,
             X_tuition_end_date         IN DATE  ,
             X_person_initials      IN VARCHAR2,
             X_primary_contact_id       IN NUMBER ,
             X_personal_income      IN NUMBER ,
             X_head_of_household_flag   IN VARCHAR2 ,
             X_content_source_number    IN VARCHAR2 ,
         x_hz_parties_ovn           IN OUT NOCOPY NUMBER,
             X_ATTRIBUTE_CATEGORY       IN VARCHAR2 ,
             X_ATTRIBUTE1           IN VARCHAR2 ,
             X_ATTRIBUTE2           IN VARCHAR2 ,
             X_ATTRIBUTE3           IN VARCHAR2 ,
             X_ATTRIBUTE4           IN VARCHAR2 ,
             X_ATTRIBUTE5           IN VARCHAR2 ,
             X_ATTRIBUTE6           IN VARCHAR2 ,
         X_ATTRIBUTE7           IN VARCHAR2 ,
         X_ATTRIBUTE8           IN VARCHAR2 ,
         X_ATTRIBUTE9           IN VARCHAR2 ,
         X_ATTRIBUTE10          IN VARCHAR2 ,
         X_ATTRIBUTE11              IN VARCHAR2 ,
         X_ATTRIBUTE12              IN VARCHAR2 ,
         X_ATTRIBUTE13              IN VARCHAR2 ,
         X_ATTRIBUTE14              IN VARCHAR2 ,
         X_ATTRIBUTE15              IN VARCHAR2 ,
         X_ATTRIBUTE16              IN VARCHAR2 ,
         X_ATTRIBUTE17              IN VARCHAR2 ,
         X_ATTRIBUTE18              IN VARCHAR2 ,
         X_ATTRIBUTE19              IN VARCHAR2 ,
         X_ATTRIBUTE20              IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE_CATEGORY    IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE1        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE2        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE3        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE4        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE5        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE6        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE7        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE8        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE9        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE10       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE11       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE12       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE13       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE14       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE15       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE16       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE17       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE18       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE19       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE20       IN VARCHAR2 ,
         X_PARTY_LAST_UPDATE_DATE   IN OUT NOCOPY DATE ,
         X_PERSON_PROFILE_ID          IN OUT NOCOPY NUMBER ,
         X_MATR_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
         X_MATR_SEQUENCE_NUMBER              IN     NUMBER    ,--  DEFAULT NULL,
         X_INIT_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
         X_INIT_SEQUENCE_NUMBER             IN     NUMBER     ,-- DEFAULT NULL,
         X_RECENT_CAL_TYPE                   IN     VARCHAR2  ,--  DEFAULT NULL ,
         X_RECENT_SEQUENCE_NUMBER           IN     NUMBER     ,-- DEFAULT NULL,
         X_CATALOG_CAL_TYPE                  IN     VARCHAR2  ,--  DEFAULT NULL ,
         X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER     ,-- DEFAULT NULL,
         Z_RETURN_STATUS            OUT NOCOPY VARCHAR2 ,
         Z_MSG_COUNT                OUT NOCOPY NUMBER ,
         Z_MSG_DATA                 OUT NOCOPY VARCHAR2 ,
	 X_BIRTH_CNTRY_RESN_CODE    IN VARCHAR2
) AS
  /*************************************************************
  Created By : svisweas
  Date Created By :23-MAY-2000
  Purpose : TO VALIDATE INSERT ROW
  Know limitations, enhancements or remarks
  Change History
 Who             When            What
 --sbaliga  7-May-2002  Modified code as part of#2338473
 --bayadav   31-Jan-2002   Added one DFF in IGS_PE_STAT_DETAILS and DFF columns in IGS_AD_STAT_INT table.
 --                        Due to which 1)Using the columns attribute1 to attribute20  parameters of this TBH
 --                        to transfer the data from IGS_AD_STAT_INT DFF columns to IGS_PE_STAT_DETAILS DFF columns
 --                        2)Changing the earlier use of these parameters  attribute1 to attribute20 for HZ table to NULL.Bug number:2203778
 --pkpatel  27-JUN-2003    Bug 3019813(Made the Hz_Party_v2Pub.update_person call only while HZ related attrubures are modified)
  svisweas  26-may-2000 get_fk_igs_lookups_view procedure from tbh.
  (reverse chronological order - newest change first)
  ***************************************************************/
    LV_INIT_MSG_LIST VARCHAR2(1) ;
    LV_COMMIT VARCHAR2(1) ;
    LV_LAST_UPDATE_DATE DATE ;
    LV_PARTY_LAST_UPDATE_DATE DATE;
    LV_PROFILE_ID NUMBER;
    LV_PERSON_REC_TYPE   Hz_Party_V2Pub.PERSON_REC_TYPE;
    LV_PARTY_REC_TYPE    Hz_Party_V2Pub.PARTY_REC_TYPE;
    l_tmp_var1          VARCHAR2(2000);
    l_tmp_var           VARCHAR2(2000);
    l_default_date      DATE := igs_ge_date.igsdate('9999/01/01');
    l_default_value     VARCHAR2(1) := 'X';

    lvRowID VARCHAR2(25);

         BEGIN
   Before_DML(
           X_action=>'INSERT',
             X_rowid                      => XXX_ROWID,
             X_PERSON_ID            => X_PERSON_ID,
             X_ETHNIC_ORIGIN_ID         => X_ETHNIC_ORIGIN_ID,
             X_MARITAL_STATUS       => X_MARITAL_STATUS,
             X_MARITAL_STAT_EFFECT_DT   => X_MARITAL_STAT_EFFECT_DT,
             X_ANN_FAMILY_INCOME        =>X_ANN_FAMILY_INCOME,
             X_NUMBER_IN_FAMILY         =>X_NUMBER_IN_FAMILY,
             X_CONTENT_SOURCE_TYPE      =>X_CONTENT_SOURCE_TYPE,
             X_INTERNAL_FLAG            =>X_INTERNAL_FLAG,
             X_PERSON_NUMBER            =>X_PERSON_NUMBER,
             X_EFFECTIVE_START_DATE     =>X_EFFECTIVE_START_DATE,
             X_effective_end_date       =>X_EFFECTIVE_END_DATE,
             X_ethnic_origin            =>X_ETHNIC_ORIGIN,
             X_religion             =>X_RELIGION,
             X_next_to_kin              =>X_NEXT_TO_KIN,
             X_next_to_kin_meaning      => X_NEXT_TO_KIN_MEANING,
             X_place_of_birth       =>X_PLACE_OF_BIRTH,
             X_socio_eco_status         =>X_SOCIO_ECO_STATUS,
           X_socio_eco_status_desc      =>X_SOCIO_ECO_STATUS_DESC,
             X_further_education        =>X_FURTHER_EDUCATION,
             X_further_education_desc   =>X_FURTHER_EDUCATION_DESC,
             X_in_state_tuition         =>X_IN_STATE_TUITION,
             X_tuition_st_Date          =>X_TUITION_ST_DATE,
             X_tuition_end_date         =>X_TUITION_END_DATE,
             X_person_initials      =>X_PERSON_INITIALS,
             X_primary_contact_id       =>X_PRIMARY_CONTACT_ID,
             X_personal_income      =>X_PERSONAL_INCOME,
             X_head_of_household_flag   =>X_HEAD_OF_HOUSEHOLD_FLAG,
             X_content_source_number    =>X_CONTENT_SOURCE_NUMBER,
         x_hz_parties_ovn           =>X_HZ_PARTIES_OVN,
             X_ATTRIBUTE_CATEGORY       =>X_ATTRIBUTE_CATEGORY,
             X_ATTRIBUTE1           =>X_ATTRIBUTE1,
             X_ATTRIBUTE2           =>X_ATTRIBUTE2,
             X_ATTRIBUTE3           =>X_ATTRIBUTE3,
             X_ATTRIBUTE4           =>X_ATTRIBUTE4,
             X_ATTRIBUTE5           =>X_ATTRIBUTE5,
             X_ATTRIBUTE6           =>X_ATTRIBUTE6,
           X_ATTRIBUTE7             =>X_ATTRIBUTE7,
           X_ATTRIBUTE8             =>X_ATTRIBUTE8,
         X_ATTRIBUTE9           =>X_ATTRIBUTE9,
         X_ATTRIBUTE10          =>X_ATTRIBUTE10,
         X_ATTRIBUTE11              =>X_ATTRIBUTE11,
         X_ATTRIBUTE12              =>X_ATTRIBUTE12,
         X_ATTRIBUTE13              =>X_ATTRIBUTE13,
         X_ATTRIBUTE14              =>X_ATTRIBUTE14,
         X_ATTRIBUTE15              =>X_ATTRIBUTE15,
         X_ATTRIBUTE16              =>X_ATTRIBUTE16,
         X_ATTRIBUTE17              =>X_ATTRIBUTE17,
         X_ATTRIBUTE18              =>X_ATTRIBUTE18,
         X_ATTRIBUTE19              =>X_ATTRIBUTE19,
         X_ATTRIBUTE20              =>X_ATTRIBUTE20,
         X_GLOBAL_ATTRIBUTE_CATEGORY    =>X_GLOBAL_ATTRIBUTE_CATEGORY,
         X_GLOBAL_ATTRIBUTE1          =>X_GLOBAL_ATTRIBUTE1,
         X_GLOBAL_ATTRIBUTE2          =>X_GLOBAL_ATTRIBUTE2,
         X_GLOBAL_ATTRIBUTE3          =>X_GLOBAL_ATTRIBUTE3,
         X_GLOBAL_ATTRIBUTE4        =>X_GLOBAL_ATTRIBUTE4,
         X_GLOBAL_ATTRIBUTE5        =>X_GLOBAL_ATTRIBUTE5,
         X_GLOBAL_ATTRIBUTE6        =>X_GLOBAL_ATTRIBUTE6,
         X_GLOBAL_ATTRIBUTE7        =>X_GLOBAL_ATTRIBUTE7,
         X_GLOBAL_ATTRIBUTE8            =>X_GLOBAL_ATTRIBUTE8,
         X_GLOBAL_ATTRIBUTE9        =>X_GLOBAL_ATTRIBUTE9,
         X_GLOBAL_ATTRIBUTE10       =>X_GLOBAL_ATTRIBUTE10,
         X_GLOBAL_ATTRIBUTE11       =>X_GLOBAL_ATTRIBUTE11,
         X_GLOBAL_ATTRIBUTE12       =>X_GLOBAL_ATTRIBUTE12,
         X_GLOBAL_ATTRIBUTE13       =>X_GLOBAL_ATTRIBUTE13,
            X_GLOBAL_ATTRIBUTE14        =>X_GLOBAL_ATTRIBUTE14,
         X_GLOBAL_ATTRIBUTE15       =>X_GLOBAL_ATTRIBUTE15,
         X_GLOBAL_ATTRIBUTE16       =>X_GLOBAL_ATTRIBUTE16,
         X_GLOBAL_ATTRIBUTE17       =>X_GLOBAL_ATTRIBUTE17,
         X_GLOBAL_ATTRIBUTE18       =>X_GLOBAL_ATTRIBUTE18,
         X_GLOBAL_ATTRIBUTE19       =>X_GLOBAL_ATTRIBUTE19,
         X_GLOBAL_ATTRIBUTE20       =>X_GLOBAL_ATTRIBUTE20,
             X_MATR_CAL_TYPE                     => X_MATR_CAL_TYPE,
             X_MATR_SEQUENCE_NUMBER              => X_MATR_SEQUENCE_NUMBER,
             X_INIT_CAL_TYPE                     => X_INIT_CAL_TYPE,
             X_INIT_SEQUENCE_NUMBER             => X_INIT_SEQUENCE_NUMBER,
             X_RECENT_CAL_TYPE                   => X_RECENT_CAL_TYPE,
             X_RECENT_SEQUENCE_NUMBER           => X_RECENT_SEQUENCE_NUMBER,
             X_CATALOG_CAL_TYPE                  => X_CATALOG_CAL_TYPE,
             X_CATALOG_SEQUENCE_NUMBER          => X_CATALOG_SEQUENCE_NUMBER,
         X_PARTY_LAST_UPDATE_DATE   =>X_PARTY_LAST_UPDATE_DATE,
         X_PERSON_PROFILE_ID        =>X_PERSON_PROFILE_ID,
	 X_BIRTH_CNTRY_RESN_CODE    =>X_BIRTH_CNTRY_RESN_CODE);


     -- initialize the party record

     LV_PERSON_REC_TYPE.PARTY_REC.PARTY_ID      := X_PERSON_ID;
     LV_PERSON_REC_TYPE.DECLARED_ETHNICITY      := NVL(X_ETHNIC_ORIGIN_ID,FND_API.G_MISS_CHAR);
     LV_PERSON_REC_TYPE.MARITAL_STATUS          := NVL(X_MARITAL_STATUS , FND_API.G_MISS_CHAR);
     LV_PERSON_REC_TYPE.MARITAL_STATUS_EFFECTIVE_DATE   := NVL(X_MARITAL_STAT_EFFECT_DT ,FND_API.G_MISS_DATE);
     LV_PERSON_REC_TYPE.HOUSEHOLD_INCOME        := NVL(X_ANN_FAMILY_INCOME,FND_API.G_MISS_NUM);
     LV_PERSON_REC_TYPE.HOUSEHOLD_SIZE          := NVL(X_NUMBER_IN_FAMILY,FND_API.G_MISS_NUM);
     LV_PERSON_REC_TYPE.PLACE_OF_BIRTH          := NVL(X_PLACE_OF_BIRTH,FND_API.G_MISS_CHAR);
     LV_PERSON_REC_TYPE.CONTENT_SOURCE_TYPE         := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
     LV_PERSON_REC_TYPE.INTERNAL_FLAG           := NVL(X_INTERNAL_FLAG , FND_API.G_MISS_CHAR);

     -- do not initialise the attribute 1.20 and do not pass global attributes 1.20

      IF X_ACTION ='INSERT' THEN


      -- ssawhney : v2api uptake.
        IF ( NVL(old_references.ethnic_origin_id,l_default_value) <> NVL(new_references.ethnic_origin_id,l_default_value) OR
             NVL(old_references.marital_status,l_default_value) <> NVL(new_references.marital_status,l_default_value) OR
             NVL(old_references.marital_status_effective_date,l_default_date) <> NVL(new_references.marital_status_effective_date,l_default_date) OR
             NVL(old_references.place_of_birth,l_default_value) <> NVL(new_references.place_of_birth,l_default_value)) THEN

                     Hz_Party_v2Pub.update_person(
                      p_party_object_version_number  => x_hz_parties_ovn,
                      P_PERSON_REC => LV_PERSON_REC_TYPE,
                      X_PROFILE_ID => Z_PROFILE_ID,
                      X_RETURN_STATUS => Z_RETURN_STATUS,
                      X_MSG_COUNT =>Z_MSG_COUNT,
                      X_MSG_DATA => Z_MSG_DATA
                    );
       ELSE
		  Z_RETURN_STATUS := 'S';
       END IF;
     END IF;

   IF Z_RETURN_STATUS IN ('E' , 'U') THEN
     fnd_message.set_name ('AR',Y_MSG_DATA);
     --Code added by sbaliga as part of #2338473
     IF z_msg_count > 1 THEN
        FOR i IN 1..z_msg_count  LOOP
          l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
        END LOOP;
        z_msg_data := l_tmp_var1;
      END IF;

       RETURN;
      ELSIF Z_RETURN_STATUS = 'S' OR Z_RETURN_STATUS IS NULL THEN

      --ssawhney :
      -- removed this check as its always going to pass, so no use keeping it as
      -- z_prof will never be same as x_per prof and x_per prof will always be null
      -- IF Z_PROFILE_ID <> X_PERSON_PROFILE_ID  OR X_PERSON_PROFILE_ID IS NULL THEN

      Igs_Pe_Stat_Details_Pkg.insert_row (
      x_rowid                             => lvRowID,
      x_person_id                         => X_PERSON_ID,
      x_effective_start_date              => x_effective_start_date,
      x_effective_end_date                => x_effective_end_date,
      x_religion_cd                       => x_religion,
      x_socio_eco_cd                      => X_socio_eco_status,
      x_next_to_kin                       => x_next_to_kin,
      x_in_state_tuition                  => x_in_state_tuition,
      x_tuition_st_date                   => x_tuition_st_date,
      x_tuition_end_date                  => x_tuition_end_date,
      x_further_education_cd                 => x_further_education,
      X_MATR_CAL_TYPE                     => X_MATR_CAL_TYPE,
      X_MATR_SEQUENCE_NUMBER              => X_MATR_SEQUENCE_NUMBER,
      X_INIT_CAL_TYPE                     => X_INIT_CAL_TYPE,
      X_INIT_SEQUENCE_NUMBER             => X_INIT_SEQUENCE_NUMBER,
      X_RECENT_CAL_TYPE                   => X_RECENT_CAL_TYPE,
      X_RECENT_SEQUENCE_NUMBER           => X_RECENT_SEQUENCE_NUMBER,
      X_CATALOG_CAL_TYPE                  => X_CATALOG_CAL_TYPE,
      X_CATALOG_SEQUENCE_NUMBER          => X_CATALOG_SEQUENCE_NUMBER,
      X_MODE                              =>  'R'  ,
      X_ATTRIBUTE_CATEGORY      => X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1          => X_ATTRIBUTE1,
      X_ATTRIBUTE2              => X_ATTRIBUTE2,
      X_ATTRIBUTE3              => X_ATTRIBUTE3,
      X_ATTRIBUTE4              => X_ATTRIBUTE4,
      X_ATTRIBUTE5              => X_ATTRIBUTE5,
      X_ATTRIBUTE6              =>  X_ATTRIBUTE6,
      X_ATTRIBUTE7              =>  X_ATTRIBUTE7,
      X_ATTRIBUTE8              => X_ATTRIBUTE8,
      X_ATTRIBUTE9              => X_ATTRIBUTE9,
      X_ATTRIBUTE10             => X_ATTRIBUTE10,
      X_ATTRIBUTE11             =>  X_ATTRIBUTE11,
      X_ATTRIBUTE12             =>  X_ATTRIBUTE12,
      X_ATTRIBUTE13             =>  X_ATTRIBUTE13,
      X_ATTRIBUTE14             =>  X_ATTRIBUTE14,
      X_ATTRIBUTE15             =>  X_ATTRIBUTE15,
      X_ATTRIBUTE16             =>  X_ATTRIBUTE16,
      X_ATTRIBUTE17             =>  X_ATTRIBUTE17,
      X_ATTRIBUTE18             =>  X_ATTRIBUTE18,
      X_ATTRIBUTE19             =>  X_ATTRIBUTE19,
      X_ATTRIBUTE20             =>  X_ATTRIBUTE20,
      X_BIRTH_CNTRY_RESN_CODE   =>  X_BIRTH_CNTRY_RESN_CODE);


   -- END IF;
 END IF;
-- ssawhney : dontknow why these are commented.
-- X_PERSON_PROFILE_ID := Z_PROFILE_ID;
-- X_ROWID := XXX_ROWID;
 END Insert_Row;
----------here i am calling  the api and my procedure
  PROCEDURE UPDATE_ROW (
             X_action               IN VARCHAR2 ,
             X_ROWID                IN VARCHAR2 ,
             X_PERSON_ID            IN NUMBER ,
             X_ETHNIC_ORIGIN_ID         IN  VARCHAR2 ,
             X_MARITAL_STATUS       IN VARCHAR2 ,
             X_MARITAL_STAT_EFFECT_DT   IN DATE  ,
             X_ANN_FAMILY_INCOME        IN NUMBER ,
             X_NUMBER_IN_FAMILY         IN NUMBER ,
             X_CONTENT_SOURCE_TYPE      IN VARCHAR2 ,
             X_INTERNAL_FLAG            IN VARCHAR2 ,
             X_PERSON_NUMBER            IN VARCHAR2 ,
             X_EFFECTIVE_START_DATE     IN DATE ,
             X_effective_end_date       IN DATE ,
             X_ethnic_origin            IN VARCHAR2 ,
             X_religion             IN VARCHAR2 ,
             X_next_to_kin              IN VARCHAR2 ,
             X_next_to_kin_meaning      IN VARCHAR2 ,
             X_place_of_birth       IN VARCHAR2 ,
             X_socio_eco_status         IN VARCHAR2 ,
           X_socio_eco_status_desc      IN VARCHAR2 ,
             X_further_education        IN VARCHAR2 ,
             X_further_education_desc   IN VARCHAR2 ,
             X_in_state_tuition         IN VARCHAR2 ,
             X_tuition_st_Date          IN DATE ,
             X_tuition_end_date         IN DATE  ,
             X_person_initials      IN VARCHAR2,
             X_primary_contact_id       IN NUMBER ,
             X_personal_income      IN NUMBER ,
             X_head_of_household_flag   IN VARCHAR2 ,
             X_content_source_number    IN VARCHAR2 ,
             x_hz_parties_ovn IN OUT NOCOPY NUMBER,
             X_ATTRIBUTE_CATEGORY       IN VARCHAR2 ,
             X_ATTRIBUTE1           IN VARCHAR2 ,
             X_ATTRIBUTE2           IN VARCHAR2 ,
             X_ATTRIBUTE3           IN VARCHAR2 ,
             X_ATTRIBUTE4           IN VARCHAR2 ,
             X_ATTRIBUTE5           IN VARCHAR2 ,
             X_ATTRIBUTE6           IN VARCHAR2 ,
         X_ATTRIBUTE7           IN VARCHAR2 ,
         X_ATTRIBUTE8           IN VARCHAR2 ,
         X_ATTRIBUTE9           IN VARCHAR2 ,
         X_ATTRIBUTE10          IN VARCHAR2 ,
         X_ATTRIBUTE11              IN VARCHAR2 ,
         X_ATTRIBUTE12              IN VARCHAR2 ,
         X_ATTRIBUTE13              IN VARCHAR2 ,
         X_ATTRIBUTE14              IN VARCHAR2 ,
         X_ATTRIBUTE15              IN VARCHAR2 ,
         X_ATTRIBUTE16              IN VARCHAR2 ,
         X_ATTRIBUTE17              IN VARCHAR2 ,
         X_ATTRIBUTE18              IN VARCHAR2 ,
         X_ATTRIBUTE19              IN VARCHAR2 ,
         X_ATTRIBUTE20              IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE_CATEGORY    IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE1        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE2        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE3        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE4        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE5        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE6        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE7        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE8        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE9        IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE10       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE11       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE12       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE13       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE14       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE15       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE16       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE17       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE18       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE19       IN VARCHAR2 ,
         X_GLOBAL_ATTRIBUTE20       IN VARCHAR2 ,
         X_PARTY_LAST_UPDATE_DATE   IN OUT NOCOPY DATE ,
         X_PERSON_PROFILE_ID        IN OUT NOCOPY NUMBER ,
             X_MATR_CAL_TYPE                     IN     VARCHAR2 ,--   DEFAULT NULL ,
             X_MATR_SEQUENCE_NUMBER              IN     NUMBER   ,--   DEFAULT NULL,
             X_INIT_CAL_TYPE                     IN     VARCHAR2 ,--   DEFAULT NULL ,
             X_INIT_SEQUENCE_NUMBER             IN     NUMBER    ,--  DEFAULT NULL,
             X_RECENT_CAL_TYPE                   IN     VARCHAR2 ,--   DEFAULT NULL ,
             X_RECENT_SEQUENCE_NUMBER           IN     NUMBER    ,--  DEFAULT NULL,
             X_CATALOG_CAL_TYPE                  IN     VARCHAR2 ,--   DEFAULT NULL ,
             X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER    ,--  DEFAULT NULL,
         Z_RETURN_STATUS            OUT NOCOPY VARCHAR2 ,
         Z_MSG_COUNT                OUT NOCOPY NUMBER ,
         Z_MSG_DATA                 OUT NOCOPY VARCHAR2,
	 X_BIRTH_CNTRY_RESN_CODE    IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : svisweas
  Date Created By :23-MAY-2000
  Purpose : TO VALIDATE UPDATE ROW
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  --sbaliga     7-May-2002  Added code as part of #2338473
 --bayadav   31-Jan-2002   Added one DFF in IGS_PE_STAT_DETAILS and DFF columns in IGS_AD_STAT_INT table.
 --                        Due to which 1)Using the columns attribute1 to attribute20  parameters of this TBH
 --                        to transfer the data from IGS_AD_STAT_INT DFF columns to IGS_PE_STAT_DETAILS DFF columns
 --                        2)Changing the earlier use of these parameters  attribute1 to attribute20 for HZ table to NULL.Bug number:2203778
  svisweas   26-may-2000     get_fk_igs_lookups_view procedure from tbh.
 --pkpatel  27-JUN-2003    Bug 3019813(Made the Hz_Party_v2Pub.update_person call only while HZ related attrubures are modified)
  (reverse chronological order - newest change first)
  ***************************************************************/
    LV_INIT_MSG_LIST VARCHAR2(1);
    LV_COMMIT VARCHAR2(1);
    LV_LAST_UPDATE_DATE DATE ;
    LV_PARTY_LAST_UPDATE_DATE DATE;
    LV_PROFILE_ID NUMBER;
    lvRowId     VARCHAR2(25);
    l_tmp_var1          VARCHAR2(2000);
    l_tmp_var          VARCHAR2(2000);

    l_default_date      DATE := igs_ge_date.igsdate('9999/01/01');
    l_default_value     VARCHAR2(1) := 'X';

    LV_PERSON_REC_TYPE   Hz_Party_V2Pub.PERSON_REC_TYPE;
    LV_PARTY_REC_TYPE Hz_Party_V2Pub.PARTY_REC_TYPE;
          CURSOR party_cur IS
          SELECT hp.last_update_date , xx.effective_start_date
          FROM hz_person_profiles xx ,
               hz_parties  hp
          WHERE xx.party_id = X_person_id AND
                hp.party_id  = xx.party_id AND
          TRUNC(SYSDATE) BETWEEN TRUNC(xx.effective_start_date) AND
           NVL(xx.effective_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'));


    CURSOR c_profile IS
    SELECT rowid
        FROM IGS_PE_STAT_DETAILS
        WHERE person_id = X_PERSON_ID;

   profile_rec  c_profile%ROWTYPE;
   l_effective_Start_date DATE;

 BEGIN
   XXX_ROWID := X_ROWID;
   Before_DML(
         X_action               =>'UPDATE',
         X_rowid                =>XXX_ROWID,
             X_PERSON_ID            => X_PERSON_ID,
             X_ETHNIC_ORIGIN_ID         => X_ETHNIC_ORIGIN_ID,
             X_MARITAL_STATUS       => X_MARITAL_STATUS,
             X_MARITAL_STAT_EFFECT_DT   =>X_MARITAL_STAT_EFFECT_DT,
             X_ANN_FAMILY_INCOME        =>X_ANN_FAMILY_INCOME,
             X_NUMBER_IN_FAMILY         =>X_NUMBER_IN_FAMILY,
             X_CONTENT_SOURCE_TYPE      =>X_CONTENT_SOURCE_TYPE,
             X_INTERNAL_FLAG            =>X_INTERNAL_FLAG,
             X_PERSON_NUMBER            =>X_PERSON_NUMBER,
             X_EFFECTIVE_START_DATE     =>X_EFFECTIVE_START_DATE,
             X_effective_end_date       =>X_EFFECTIVE_END_DATE,
             X_ethnic_origin            =>X_ETHNIC_ORIGIN,
             X_religion             =>X_RELIGION,
             X_next_to_kin              =>X_NEXT_TO_KIN,
             X_next_to_kin_meaning      => X_NEXT_TO_KIN_MEANING,
             X_place_of_birth       =>X_PLACE_OF_BIRTH,
             X_socio_eco_status         =>X_SOCIO_ECO_STATUS,
         X_socio_eco_status_desc    =>X_SOCIO_ECO_STATUS_DESC,
             X_further_education        =>X_FURTHER_EDUCATION,
             X_further_education_desc   =>X_FURTHER_EDUCATION_DESC,
             X_in_state_tuition         =>X_IN_STATE_TUITION,
             X_tuition_st_Date          =>X_TUITION_ST_DATE,
             X_tuition_end_date         =>X_TUITION_END_DATE,
             X_person_initials      =>X_PERSON_INITIALS,
             X_primary_contact_id       =>X_PRIMARY_CONTACT_ID,
             X_personal_income      =>X_PERSONAL_INCOME,
             X_head_of_household_flag   =>X_HEAD_OF_HOUSEHOLD_FLAG,
             X_content_source_number    =>X_CONTENT_SOURCE_NUMBER,
             x_hz_parties_ovn  => X_HZ_PARTIES_OVN,
             X_ATTRIBUTE_CATEGORY       =>X_ATTRIBUTE_CATEGORY,
             X_ATTRIBUTE1           =>X_ATTRIBUTE1,
             X_ATTRIBUTE2           =>X_ATTRIBUTE2,
             X_ATTRIBUTE3           =>X_ATTRIBUTE3,
             X_ATTRIBUTE4           =>X_ATTRIBUTE4,
             X_ATTRIBUTE5           =>X_ATTRIBUTE5,
             X_ATTRIBUTE6           =>X_ATTRIBUTE6,
         X_ATTRIBUTE7           =>X_ATTRIBUTE7,
         X_ATTRIBUTE8           =>X_ATTRIBUTE8,
         X_ATTRIBUTE9           =>X_ATTRIBUTE9,
         X_ATTRIBUTE10          =>X_ATTRIBUTE10,
         X_ATTRIBUTE11              =>X_ATTRIBUTE11,
         X_ATTRIBUTE12              =>X_ATTRIBUTE12,
         X_ATTRIBUTE13              =>X_ATTRIBUTE13,
         X_ATTRIBUTE14              =>X_ATTRIBUTE14,
         X_ATTRIBUTE15              =>X_ATTRIBUTE15,
         X_ATTRIBUTE16              =>X_ATTRIBUTE16,
         X_ATTRIBUTE17              =>X_ATTRIBUTE17,
         X_ATTRIBUTE18              =>X_ATTRIBUTE18,
         X_ATTRIBUTE19              =>X_ATTRIBUTE19,
         X_ATTRIBUTE20              =>X_ATTRIBUTE20,
         X_GLOBAL_ATTRIBUTE_CATEGORY    =>X_GLOBAL_ATTRIBUTE_CATEGORY,
         X_GLOBAL_ATTRIBUTE1          =>X_GLOBAL_ATTRIBUTE1,
         X_GLOBAL_ATTRIBUTE2          =>X_GLOBAL_ATTRIBUTE2,
         X_GLOBAL_ATTRIBUTE3          =>X_GLOBAL_ATTRIBUTE3,
         X_GLOBAL_ATTRIBUTE4        =>X_GLOBAL_ATTRIBUTE4,
         X_GLOBAL_ATTRIBUTE5        =>X_GLOBAL_ATTRIBUTE5,
         X_GLOBAL_ATTRIBUTE6        =>X_GLOBAL_ATTRIBUTE6,
         X_GLOBAL_ATTRIBUTE7        =>X_GLOBAL_ATTRIBUTE7,
         X_GLOBAL_ATTRIBUTE8            =>X_GLOBAL_ATTRIBUTE8,
         X_GLOBAL_ATTRIBUTE9        =>X_GLOBAL_ATTRIBUTE9,
         X_GLOBAL_ATTRIBUTE10       =>X_GLOBAL_ATTRIBUTE10,
         X_GLOBAL_ATTRIBUTE11       =>X_GLOBAL_ATTRIBUTE11,
         X_GLOBAL_ATTRIBUTE12       =>X_GLOBAL_ATTRIBUTE12,
         X_GLOBAL_ATTRIBUTE13       =>X_GLOBAL_ATTRIBUTE13,
             X_GLOBAL_ATTRIBUTE14       =>X_GLOBAL_ATTRIBUTE14,
         X_GLOBAL_ATTRIBUTE15       =>X_GLOBAL_ATTRIBUTE15,
         X_GLOBAL_ATTRIBUTE16       =>X_GLOBAL_ATTRIBUTE16,
         X_GLOBAL_ATTRIBUTE17       =>X_GLOBAL_ATTRIBUTE17,
         X_GLOBAL_ATTRIBUTE18       =>X_GLOBAL_ATTRIBUTE18,
         X_GLOBAL_ATTRIBUTE19       =>X_GLOBAL_ATTRIBUTE19,
         X_GLOBAL_ATTRIBUTE20       =>X_GLOBAL_ATTRIBUTE20,
             X_MATR_CAL_TYPE                     => X_MATR_CAL_TYPE,
             X_MATR_SEQUENCE_NUMBER              => X_MATR_SEQUENCE_NUMBER,
             X_INIT_CAL_TYPE                     => X_INIT_CAL_TYPE,
             X_INIT_SEQUENCE_NUMBER             => X_INIT_SEQUENCE_NUMBER,
             X_RECENT_CAL_TYPE                   => X_RECENT_CAL_TYPE,
             X_RECENT_SEQUENCE_NUMBER           => X_RECENT_SEQUENCE_NUMBER,
             X_CATALOG_CAL_TYPE                  => X_CATALOG_CAL_TYPE,
             X_CATALOG_SEQUENCE_NUMBER          => X_CATALOG_SEQUENCE_NUMBER,
         X_PARTY_LAST_UPDATE_DATE   =>X_PARTY_LAST_UPDATE_DATE,
         X_PERSON_PROFILE_ID        =>X_PERSON_PROFILE_ID,
	 X_BIRTH_CNTRY_RESN_CODE    => X_BIRTH_CNTRY_RESN_CODE
          );
         OPEN Party_cur;
         FETCH party_cur INTO LV_PARTY_LAST_UPDATE_DATE, l_effective_start_date;
         CLOSE PARTY_CUR;


         LV_PERSON_REC_TYPE.PARTY_REC.PARTY_ID      := X_PERSON_ID;
         LV_PERSON_REC_TYPE.DECLARED_ETHNICITY      := NVL(X_ETHNIC_ORIGIN_ID,FND_API.G_MISS_CHAR);
         LV_PERSON_REC_TYPE.MARITAL_STATUS          := NVL(X_MARITAL_STATUS , FND_API.G_MISS_CHAR);
         LV_PERSON_REC_TYPE.MARITAL_STATUS_EFFECTIVE_DATE   := NVL(X_MARITAL_STAT_EFFECT_DT ,FND_API.G_MISS_DATE);
         LV_PERSON_REC_TYPE.HOUSEHOLD_INCOME        := NVL(X_ANN_FAMILY_INCOME,FND_API.G_MISS_NUM);
         LV_PERSON_REC_TYPE.HOUSEHOLD_SIZE          := NVL(X_NUMBER_IN_FAMILY,FND_API.G_MISS_NUM);
         LV_PERSON_REC_TYPE.PLACE_OF_BIRTH          := NVL(X_PLACE_OF_BIRTH,FND_API.G_MISS_CHAR);
         LV_PERSON_REC_TYPE.CONTENT_SOURCE_TYPE         := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
         LV_PERSON_REC_TYPE.INTERNAL_FLAG           := NVL(X_INTERNAL_FLAG , FND_API.G_MISS_CHAR);


      IF X_ACTION ='UPDATE' THEN

        IF ( NVL(old_references.ethnic_origin_id,l_default_value) <> NVL(new_references.ethnic_origin_id,l_default_value) OR
             NVL(old_references.marital_status,l_default_value) <> NVL(new_references.marital_status,l_default_value) OR
             NVL(old_references.marital_status_effective_date,l_default_date) <> NVL(new_references.marital_status_effective_date,l_default_date) OR
             NVL(old_references.place_of_birth,l_default_value) <> NVL(new_references.place_of_birth,l_default_value)) THEN

                 Hz_Party_V2Pub.update_person(
                  p_party_object_version_number  =>  x_hz_parties_ovn ,
                  P_PERSON_REC          => LV_PERSON_REC_TYPE,
                  X_PROFILE_ID          => Z_PROFILE_ID,
                  X_RETURN_STATUS       => Z_RETURN_STATUS,
                  X_MSG_COUNT           =>Z_MSG_COUNT,
                  X_MSG_DATA            => Z_MSG_DATA
                );
        ELSE
		  Z_RETURN_STATUS := 'S';
        END IF;

     END IF;

     IF Z_RETURN_STATUS IN ('E' , 'U') THEN
     -- fnd_message.set_name ('AR', Y_MSG_DATA);
     --Code added by sbaliga as part of #2338473
       IF z_msg_count > 1 THEN
          FOR i IN 1..z_msg_count  LOOP
          l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
          END LOOP;
          z_msg_data := l_tmp_var1;
       END IF;

     RETURN;
     ELSIF Z_RETURN_STATUS = 'S' OR Z_RETURN_STATUS IS NULL THEN

    --ssawhney :
      -- removed this check as its always going to pass, so no use keeping it as
      -- PK IS NOW CHANGED
      -- IF Z_PROFILE_ID = X_PERSON_PROFILE_ID OR Z_PROFILE_ID IS NULL THEN remove this check as PK now changed
      -- fetching the details in the cursor
      -- even the rowid of the update is changed.

       OPEN c_profile;
       FETCH c_profile INTO profile_rec;
       IF c_profile%FOUND THEN

         Igs_Pe_Stat_Details_Pkg.update_row (
         x_rowid                             => profile_rec.rowid,  -- xxx_rowid,
         x_person_id                         => X_PERSON_ID,
         x_effective_start_date              => NVL(x_effective_start_date, l_effective_start_date),
         x_effective_end_date                => x_effective_end_date,
         x_religion_cd                       => x_religion,
         x_socio_eco_cd                      => x_socio_eco_status,
         x_next_to_kin                       => x_next_to_kin,
         x_in_state_tuition                  => x_in_state_tuition,
         x_tuition_st_date                   => x_tuition_st_date,
         x_tuition_end_date                  => x_tuition_end_date,
         x_further_education_cd                 => x_further_education,
         X_MATR_CAL_TYPE                     => X_MATR_CAL_TYPE,
         X_MATR_SEQUENCE_NUMBER              => X_MATR_SEQUENCE_NUMBER,
         X_INIT_CAL_TYPE                     => X_INIT_CAL_TYPE,
         X_INIT_SEQUENCE_NUMBER             => X_INIT_SEQUENCE_NUMBER,
         X_RECENT_CAL_TYPE                   => X_RECENT_CAL_TYPE,
         X_RECENT_SEQUENCE_NUMBER           => X_RECENT_SEQUENCE_NUMBER,
         X_CATALOG_CAL_TYPE                  => X_CATALOG_CAL_TYPE,
         X_CATALOG_SEQUENCE_NUMBER          => X_CATALOG_SEQUENCE_NUMBER,
         X_MODE                              =>  'R' ,
         X_ATTRIBUTE_CATEGORY       => X_ATTRIBUTE_CATEGORY,
         X_ATTRIBUTE1           => X_ATTRIBUTE1,
         X_ATTRIBUTE2               => X_ATTRIBUTE2,
         X_ATTRIBUTE3               => X_ATTRIBUTE3,
         X_ATTRIBUTE4               => X_ATTRIBUTE4,
         X_ATTRIBUTE5               => X_ATTRIBUTE5,
         X_ATTRIBUTE6               =>  X_ATTRIBUTE6,
         X_ATTRIBUTE7               =>  X_ATTRIBUTE7,
         X_ATTRIBUTE8           => X_ATTRIBUTE8,
         X_ATTRIBUTE9           => X_ATTRIBUTE9,
         X_ATTRIBUTE10              => X_ATTRIBUTE10,
         X_ATTRIBUTE11          =>  X_ATTRIBUTE11,
         X_ATTRIBUTE12          =>  X_ATTRIBUTE12,
         X_ATTRIBUTE13          =>  X_ATTRIBUTE13,
         X_ATTRIBUTE14          =>  X_ATTRIBUTE14,
         X_ATTRIBUTE15          =>  X_ATTRIBUTE15,
         X_ATTRIBUTE16          =>  X_ATTRIBUTE16,
         X_ATTRIBUTE17          =>  X_ATTRIBUTE17,
         X_ATTRIBUTE18              =>  X_ATTRIBUTE18,
         X_ATTRIBUTE19          =>  X_ATTRIBUTE19,
         X_ATTRIBUTE20          =>  X_ATTRIBUTE20,
	 X_BIRTH_CNTRY_RESN_CODE => X_BIRTH_CNTRY_RESN_CODE);



        ELSE   -- if profile not found then


       XXX_rowid := NULL;

       Igs_Pe_Stat_Details_Pkg.insert_row (
           x_rowid                             => lvRowID,
           x_person_id                         => X_PERSON_ID,
           x_effective_start_date              =>  NVL(x_effective_start_date, l_effective_start_date),
           x_effective_end_date                => x_effective_end_date,
           x_religion_cd                       => x_religion,
           x_socio_eco_cd                      => x_socio_eco_status,
           x_next_to_kin                       => x_next_to_kin,
           x_in_state_tuition                  => x_in_state_tuition,
           x_tuition_st_date                   => x_tuition_st_date,
           x_tuition_end_date                  => x_tuition_end_date,
           x_further_education_cd                 => x_further_education,
           X_MATR_CAL_TYPE                     => X_MATR_CAL_TYPE,
           X_MATR_SEQUENCE_NUMBER              => X_MATR_SEQUENCE_NUMBER,
           X_INIT_CAL_TYPE                     => X_INIT_CAL_TYPE,
           X_INIT_SEQUENCE_NUMBER             => X_INIT_SEQUENCE_NUMBER,
           X_RECENT_CAL_TYPE                   => X_RECENT_CAL_TYPE,
           X_RECENT_SEQUENCE_NUMBER           => X_RECENT_SEQUENCE_NUMBER,
           X_CATALOG_CAL_TYPE                  => X_CATALOG_CAL_TYPE,
           X_CATALOG_SEQUENCE_NUMBER          => X_CATALOG_SEQUENCE_NUMBER,
           X_MODE                              =>  'R' ,
           X_ATTRIBUTE_CATEGORY         => X_ATTRIBUTE_CATEGORY,
           X_ATTRIBUTE1         => X_ATTRIBUTE1,
           X_ATTRIBUTE2                 => X_ATTRIBUTE2,
           X_ATTRIBUTE3                 => X_ATTRIBUTE3,
           X_ATTRIBUTE4                 => X_ATTRIBUTE4,
           X_ATTRIBUTE5                 => X_ATTRIBUTE5,
           X_ATTRIBUTE6                 =>  X_ATTRIBUTE6,
           X_ATTRIBUTE7                 =>  X_ATTRIBUTE7,
           X_ATTRIBUTE8             => X_ATTRIBUTE8,
           X_ATTRIBUTE9             => X_ATTRIBUTE9,
           X_ATTRIBUTE10            => X_ATTRIBUTE10,
           X_ATTRIBUTE11            =>  X_ATTRIBUTE11,
           X_ATTRIBUTE12            =>  X_ATTRIBUTE12,
           X_ATTRIBUTE13            =>  X_ATTRIBUTE13,
           X_ATTRIBUTE14            =>  X_ATTRIBUTE14,
           X_ATTRIBUTE15            =>  X_ATTRIBUTE15,
           X_ATTRIBUTE16            =>  X_ATTRIBUTE16,
           X_ATTRIBUTE17            =>  X_ATTRIBUTE17,
           X_ATTRIBUTE18                =>  X_ATTRIBUTE18,
           X_ATTRIBUTE19            =>  X_ATTRIBUTE19,
           X_ATTRIBUTE20            =>  X_ATTRIBUTE20,
	   X_BIRTH_CNTRY_RESN_CODE  => X_BIRTH_CNTRY_RESN_CODE);
        END IF;

       IF c_profile%ISOPEN THEN
         close c_profile;
       END IF;
       --ELSE -- if x_person_profile_id and z_person_profile_id dont match then also insert
       --END IF;
   END IF; -- return status
END UPDATE_ROW;
END Igs_Pe_Stat_Pkg;

/
