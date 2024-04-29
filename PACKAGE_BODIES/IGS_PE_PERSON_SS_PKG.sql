--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERSON_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERSON_SS_PKG" AS
/* $Header: IGSPE10B.pls 120.24 2006/06/29 13:51:38 prbhardw ship $ */

/* +=======================================================================+
   |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
   |                         All rights reserved.                          |
   +=======================================================================+
   |  NAME                                                                 |
   |    IGSVTFPB.pls                                                       |
   |                                                                       |
   |  DESCRIPTION                                                          |
   |    This package provides service functions and procedures to          |
   |    print hte text file from the EDS system definition   .             |
   |                                                                       |
   |  NOTES                                                                |
   |                                                                       |
   |  DEPENDENCIES                                                         |
   |                                                                       |
   |  USAGE                                                                |
   |                                                                       |
   |  HISTORY                                                              |
   |    04-APR-2001  A Tereshenkov Created
   |    10dec-2002   ssawhney - removed the call to hz TBH and called HZ_PARTY_PUB instead.
   |   kumma     27-JUN-2003    2902713, Modified the update_privacy to not |
   |                            to call the delete if the row_id is null   |
   |   gmaheswa  10-Nov-2003    Bug 3223043 HZ.K Impact changes
   |                            Signature of Update_employment is changed, three
   |                            new columns are added.
   |   asbala    12-nov-03      3227107: address changes - signature of igs_pe_person_addr_pkg.insert_row and update_row changed
   |                            signature of igs_pe_person_ss_pkg.update_address now includes 3 new parameters
   |   ssaleem   11-dec-03      3311720: Problem with error message display in SS Pages
   |                            FND_MSG_PUB.initialize called in every procedure
   |   pkpatel   18-JUL-2005    Bug 4327807 (Person SS Enhancement)
   |                            Added new procedures and modify existing procedures as per the new enhancement
   |   gamheswa  24-Aug-05      Bug 4327807 (Person SS Enhancement) modified CREATEUPDATE_RELATIONSHIP
   |   pkpatel   9-sep-2005     Bug 4327807 (Person SS Enhancement)
   |                            Passed UPPER for Alternate ID.
   |   skpandey  21-SEP-2005    Bug: 3663505
   |                            Description: Added ATTRIBUTES 21 TO 24 TO STORE ADDITIONAL INFORMATION
   |   vredkar  03-OCT-2005    Added a cursor dup_addrs_cur in PROCEDURE Update_Usage
   |   vredkar  26-OCT-2005    Bug# 4692461. In Update_Person and  createupdate_pers_altid
   |                            if error message is IGS_PE_UNIQUE_PID then display  IGS_PE_UNIQUE_PID_SS
   |				Added a cursor c_alt_id_desc in the procedure createupdate_pers_altid to
   |                            retrieve value of alternate Id description for th given alternate Id type.
   |  pkpatel   12-Jan-2006     Bug 4937960
   |                            Modified cursors referring igs_pe_person and igs_pe_stat_v to refer base tables in
   |                            Update_Person, Createupdate_Relationship and update_biographic procedures
   |  pkpatel    8-Feb-2006     Bug 4869740 (Changed level to lvl in update_privacy)
   +=======================================================================+ */

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'IGS_PE_PERSON_SS_PKG';
g_prod             VARCHAR2(3)           := 'IGS';
g_debug_mode       BOOLEAN := FALSE;

apps_exception  EXCEPTION ;
PRAGMA EXCEPTION_INIT(apps_exception, -20001);

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
  p_start_date        IN   DATE,
  p_end_date          IN   DATE
)
IS

 l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Privacy';
 l_api_version        CONSTANT NUMBER         := 1.0;
 l_rowid              VARCHAR2(255);

 CURSOR c_rowid (cp_privacy_level_id NUMBER) IS
 SELECT rowid, ref_notes_id
 FROM IGS_PE_PRIV_LEVEL
 WHERE privacy_level_id = cp_privacy_level_id;

 CURSOR data_group_cur (cp_data_group_id NUMBER) IS
 SELECT data_group, lvl
 FROM igs_pe_data_groups
 WHERE data_group_id = p_data_group_id;

    l_data_group IGS_PE_DATA_GROUPS.data_group%TYPE;
    l_lvl IGS_PE_DATA_GROUPS.lvl%TYPE;
        l_ref_notes_id igs_pe_priv_level.ref_notes_id%TYPE;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Update_Privacy;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
-- Bug # 3311720
  FND_MSG_PUB.initialize;

  -- API body
  OPEN data_group_cur(p_data_group_id);
  FETCH data_group_cur INTO l_data_group,l_lvl;
  CLOSE data_group_cur;

  IF p_mode='UPDATE' THEN
     OPEN c_rowid (p_privacy_level_id);
     FETCH c_rowid INTO l_rowid, l_ref_notes_id;
     CLOSE c_rowid;
     igs_pe_priv_level_pkg.update_row(
        X_ROWID             =>  l_rowid,
        X_PRIVACY_LEVEL_ID  =>  p_privacy_level_id,
        X_PERSON_ID         =>  p_person_id ,
        X_DATA_GROUP        =>  l_data_group ,
        X_DATA_GROUP_ID     =>  p_data_group_id ,
        X_LVL               =>  l_lvl ,
        X_ACTION            =>  p_action,
        X_WHOM              =>  p_whom ,
        X_REF_NOTES_ID      =>  l_ref_notes_id,
        X_START_DATE        =>  p_start_date ,
        X_END_DATE          =>  p_end_date );
  ELSIF p_mode='INSERT' THEN
     igs_pe_priv_level_pkg.insert_row(
        X_ROWID             =>  l_rowid,
        X_PRIVACY_LEVEL_ID  =>  x_privacy_level_id,
        X_PERSON_ID         =>  p_person_id ,
        X_DATA_GROUP        =>  l_data_group ,
        X_DATA_GROUP_ID     =>  p_data_group_id ,
        X_LVL               =>  l_lvl ,
        X_ACTION            =>  p_action,
        X_WHOM              =>  p_whom ,
        X_REF_NOTES_ID      =>  null,
        X_START_DATE        =>  p_start_date ,
        X_END_DATE          =>  p_end_date );
  ELSIF p_mode='DELETE' THEN
     OPEN c_rowid(p_privacy_level_id);
     FETCH c_rowid INTO l_rowid, l_ref_notes_id;
     CLOSE c_rowid;
     --kumma, 2902713, Added the following IF clause , as row id could be null
     IF l_rowid IS NOT NULL THEN
          igs_pe_priv_level_pkg.delete_row(
               X_ROWID             =>  l_rowid);
     END IF;

  ELSIF p_mode='LOCK' THEN
     OPEN c_rowid(p_privacy_level_id);
     FETCH c_rowid INTO l_rowid, l_ref_notes_id;
     CLOSE c_rowid;

     Igs_Pe_Priv_Level_Pkg.Lock_Row (
        X_RowId              => l_rowid,
        X_Privacy_Level_Id   => p_privacy_level_id,
        X_Person_Id          => p_person_id,
        X_Data_Group         => l_data_group,
        X_Data_Group_Id      => p_data_group_id,
        X_Lvl                => l_lvl,
        X_Action             => p_action,
        X_Whom               => p_whom,
        X_Start_Date         => p_start_date,
        X_End_Date           => p_end_date,
        X_Ref_Notes_Id       => l_ref_notes_id
      );
  END IF;
  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );
EXCEPTION
    WHEN apps_exception THEN
     ROLLBACK TO Update_Privacy;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Privacy;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Privacy;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  WHEN OTHERS THEN
     ROLLBACK TO Update_Privacy;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
END Update_Privacy;

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
  p_birth_dt          IN   DATE,
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
  p_attribute21       IN   VARCHAR2,
  p_attribute22       IN   VARCHAR2,
  p_attribute23       IN   VARCHAR2,
  p_attribute24       IN   VARCHAR2
)
IS
l_message_name  VARCHAR2(30);
l_app           VARCHAR2(50);

CURSOR pref_id_cur IS
SELECT person_id_type, description, format_mask
FROM   igs_pe_person_id_typ
WHERE  preferred_ind ='Y';

pref_id_rec pref_id_cur%ROWTYPE;

CURSOR c_person(cp_person_id hz_parties.party_id%TYPE) IS
   SELECT p.rowid row_id,
          p.party_number person_number,
          p.person_last_name surname ,
          p.person_first_name given_names ,
          NULL staff_member_ind ,
          DECODE(pp.date_of_death,NULL,NVL(pd.deceased_ind,'N'),'Y') deceased_ind,
          pd.archive_exclusion_ind ,
          pd.archive_dt ,
          pd.purge_exclusion_ind ,
          pd.purge_dt ,
          pp.date_of_death deceased_date ,
          pd.proof_of_ins ,
          pd.proof_of_immu ,
          p.salutation ,
          pd.oracle_username ,
          NULL email_addr ,
          pd.level_of_qual level_of_qual_id ,
          pd.military_service_reg ,
          pd.veteran ,
          p.object_version_number
    FROM  hz_parties p,
          igs_pe_hz_parties pd,
          hz_person_profiles pp
    WHERE p.party_id = cp_person_id
    AND p.party_id  = pd.party_id (+)
    AND p.party_id = pp.party_id
    AND SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date,SYSDATE);

 l_return_status   VARCHAR2(1);
 l_msg_count       NUMBER;
 l_msg_data        VARCHAR(2000);
 l_date            DATE := sysdate;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Update_Person;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.initialize;
  -- API body
/* 1. Get the Preferred Person Id Type
   2. Retrieve current row values to be passed to the procedure.
   3. Call IGS_PE_PERSON_PKG.UPDATE_ROW procedure
*/

  FOR c_person_rec IN c_person(p_person_id) LOOP

    OPEN pref_id_cur;
        FETCH pref_id_cur INTO pref_id_rec;
        CLOSE pref_id_cur;

    igs_pe_person_pkg.update_row(
       x_last_update_date       => l_date,
       x_return_status          => l_return_status,
       x_msg_count              => l_msg_count,
       x_msg_data               => l_msg_data,
       x_rowid                  => c_person_rec.row_id,
       x_person_id              => p_person_id,
       x_person_number          => c_person_rec.person_number,
       x_surname                => c_person_rec.surname,
       x_middle_name            => p_middle_name,
       x_given_names            => c_person_rec.given_names,
       x_sex                    => p_sex,
       x_title                  => p_title,
       x_staff_member_ind       => c_person_rec.staff_member_ind,
       x_deceased_ind           => c_person_rec.deceased_ind,
       x_suffix                 => p_suffix,
       x_pre_name_adjunct       => p_pre_name_adjunct,
       x_archive_exclusion_ind  => c_person_rec.archive_exclusion_ind,
       x_archive_dt             => c_person_rec.archive_dt,
       x_purge_exclusion_ind    => c_person_rec.purge_exclusion_ind,
       x_purge_dt               => c_person_rec.purge_dt,
       x_deceased_date          => c_person_rec.deceased_date,
       x_proof_of_ins           => c_person_rec.proof_of_ins,
       x_proof_of_immu          => c_person_rec.proof_of_immu,
       x_birth_dt               => p_birth_dt,
       x_salutation             => c_person_rec.salutation,
       x_oracle_username        => c_person_rec.oracle_username,
       x_preferred_given_name   => p_preferred_name,
       x_email_addr             => c_person_rec.email_addr,
       x_level_of_qual_id       => c_person_rec.level_of_qual_id,
       x_military_service_reg   => c_person_rec.military_service_reg,
       x_veteran                => c_person_rec.veteran,
       x_hz_parties_ovn         => c_person_rec.object_version_number,
       x_attribute_category     => p_attribute_category,
       x_attribute1             => p_attribute1,
       x_attribute2             => p_attribute2,
       x_attribute3             => p_attribute3,
       x_attribute4             => p_attribute4,
       x_attribute5             => p_attribute5,
       x_attribute6             => p_attribute6,
       x_attribute7             => p_attribute7,
       x_attribute8             => p_attribute8,
       x_attribute9             => p_attribute9,
       x_attribute10            => p_attribute10,
       x_attribute11            => p_attribute11,
       x_attribute12            => p_attribute12,
       x_attribute13            => p_attribute13,
       x_attribute14            => p_attribute14,
       x_attribute15            => p_attribute15,
       x_attribute16            => p_attribute16,
       x_attribute17            => p_attribute17,
       x_attribute18            => p_attribute18,
       x_attribute19            => p_attribute19,
       x_attribute20            => p_attribute20,
       x_person_id_type         => pref_id_rec.person_id_type,
       x_api_person_id          => UPPER(p_api_person_id),
       x_attribute21            => p_attribute21,
       x_attribute22            => p_attribute22,
       x_attribute23            => p_attribute23,
       x_attribute24            => p_attribute24
       );
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
       END IF;
  END LOOP;
  -- End of API body.

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );
EXCEPTION
    WHEN apps_exception THEN
     ROLLBACK TO Update_Person;

        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

        IF l_message_name = 'IGS_PE_UNIQUE_PID' THEN
                FND_MSG_PUB.initialize ;
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_UNIQUE_PID_SS');
                FND_MESSAGE.SET_TOKEN('ALT_ID_DESC1', pref_id_rec.description);
		FND_MESSAGE.SET_TOKEN('ALT_ID_DESC2', pref_id_rec.description);
                IGS_GE_MSG_STACK.ADD;
        END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );

    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Person;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Person;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  WHEN OTHERS THEN
     ROLLBACK TO Update_Person;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
END Update_Person;

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
)
IS
 l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Phone';
 l_api_version        CONSTANT NUMBER         := 1.0;
 l_rowid              VARCHAR2(255);
 CURSOR c_contact(cp_contact_point_id NUMBER) IS
   SELECT  rowid ,
           attribute_category,
           last_update_date,
           attribute1 ,
           attribute2 ,
           attribute3 ,
           attribute4 ,
           attribute5 ,
           attribute6 ,
           attribute7 ,
           attribute8 ,
           attribute9 ,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           attribute16,
           attribute17,
           attribute18,
           attribute19,
           attribute20
     FROM hz_contact_points
    WHERE contact_point_id = cp_contact_point_id;

  l_contact_point_id hz_contact_points.contact_point_id%TYPE;
  l_object_version_number hz_contact_points.object_version_number%TYPE;
  l_date            DATE;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR(2000);
  l_phone_number    VARCHAR(2000);
  l_mode            VARCHAR2(10);

  CURSOR dup_email_cur(cp_person_id hz_contact_points.owner_table_id%TYPE,
                       cp_contact_point_type hz_contact_points.contact_point_type%TYPE,
                                   cp_owner_table_name hz_contact_points.owner_table_name%TYPE,
                                           cp_status hz_contact_points.status%TYPE,
                                           cp_email_address hz_contact_points.email_address%TYPE) IS
  SELECT contact_point_id, object_version_number
  FROM hz_contact_points
  WHERE owner_table_id = cp_person_id  AND
  contact_point_type = cp_contact_point_type AND
  owner_table_name = cp_owner_table_name AND
  status = cp_status AND
  UPPER(EMAIL_ADDRESS) = UPPER(cp_email_address);

  dup_email_rec dup_email_cur%ROWTYPE;

  CURSOR dup_phone_cur(cp_person_id hz_contact_points.owner_table_id%TYPE,
                       cp_contact_point_type hz_contact_points.contact_point_type%TYPE,
                                           cp_owner_table_name hz_contact_points.owner_table_name%TYPE,
                                           cp_status hz_contact_points.status%TYPE,
                                           cp_phone_number VARCHAR2) IS
  SELECT contact_point_id, object_version_number
  FROM hz_contact_points
  WHERE owner_table_id = cp_person_id  AND
  contact_point_type = cp_contact_point_type AND
  owner_table_name = cp_owner_table_name AND
  status = cp_status AND
  UPPER(phone_country_code||'-'||phone_area_code||'-'||phone_number||'-'||phone_extension) = UPPER(cp_phone_number);

  dup_phone_rec dup_phone_cur%ROWTYPE;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Update_Phone;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  FND_MSG_PUB.initialize;

  --  API body
  --  Retrive existing information to be passed to the API.
  --  Call IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKP procedure
  l_date := sysdate;
  l_mode := p_mode;
  l_contact_point_id := p_contact_point_id;
  l_object_version_number := p_contact_point_ovn;

  /*
   While inserting a new record check whether there is already an Inactive record witht the same details.
   If present then make that record Active. Else create a new record.
  */
  IF p_mode='INSERT' THEN
    IF (p_email_format IS NULL) THEN

           l_phone_number := p_phone_country_code||'-'||p_phone_area_code||'-'||p_phone_number||'-'||p_phone_extension;

             OPEN dup_phone_cur(p_person_id,'PHONE','HZ_PARTIES','I',l_phone_number);
                 FETCH dup_phone_cur INTO dup_phone_rec;
                 CLOSE dup_phone_cur;

                 IF dup_phone_rec.contact_point_id IS NOT NULL THEN
                   l_mode := 'UPDATE';
           l_contact_point_id := dup_phone_rec.contact_point_id;
           l_object_version_number := dup_phone_rec.object_version_number;
                 END IF;

        ELSE
             OPEN dup_email_cur(p_person_id,'EMAIL','HZ_PARTIES','I',p_email_address);
                 FETCH dup_email_cur INTO dup_email_rec;
                 CLOSE dup_email_cur;

                 IF dup_email_rec.contact_point_id IS NOT NULL THEN
                   l_mode := 'UPDATE';
           l_contact_point_id := dup_email_rec.contact_point_id;
           l_object_version_number := dup_email_rec.object_version_number;
                 END IF;
     END IF;
  END IF;


  IF l_mode ='UPDATE' THEN
    FOR c_contacs_rec IN c_contact(l_contact_point_id) LOOP
       l_rowid := c_contacs_rec.rowid;
       l_date  := c_contacs_rec.last_update_date;
       IF (p_email_format IS NULL) THEN -- Insert phone
         IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKP(
            p_action                 => 'UPDATE',
            p_rowid                  => l_rowid,
            p_status                 => p_status,
            p_owner_table_name       => 'HZ_PARTIES',
            p_owner_table_id         => p_person_id,
            P_primary_flag           => p_primary_flag,
            p_phone_country_code     => p_phone_country_code,
            p_phone_area_code        => p_phone_area_code,
            p_phone_number           => p_phone_number,
            p_phone_extension        => p_phone_extension,
            p_phone_line_type        => p_phone_line_type,
            p_return_status          => l_return_status,
            p_msg_data               => l_msg_data,
            p_last_update_date       => l_date,
            p_contact_point_id       => l_contact_point_id,
            p_contact_point_ovn      => l_object_version_number,
            p_attribute_category     => c_contacs_rec.attribute_category,
            p_attribute1             => c_contacs_rec.attribute1,
            p_attribute2             => c_contacs_rec.attribute2,
            p_attribute3             => c_contacs_rec.attribute3,
            p_attribute4             => c_contacs_rec.attribute4,
            p_attribute5             => c_contacs_rec.attribute5,
            p_attribute6             => c_contacs_rec.attribute6,
            p_attribute7             => c_contacs_rec.attribute7,
            p_attribute8             => c_contacs_rec.attribute8,
            p_attribute9             => c_contacs_rec.attribute9,
            p_attribute10            => c_contacs_rec.attribute10,
            p_attribute11            => c_contacs_rec.attribute11,
            p_attribute12            => c_contacs_rec.attribute12,
            p_attribute13            => c_contacs_rec.attribute13,
            p_attribute14            => c_contacs_rec.attribute14,
            p_attribute15            => c_contacs_rec.attribute15,
            p_attribute16            => c_contacs_rec.attribute16,
            p_attribute17            => c_contacs_rec.attribute17,
            p_attribute18            => c_contacs_rec.attribute18,
            p_attribute19            => c_contacs_rec.attribute19,
            p_attribute20            => c_contacs_rec.attribute20
         ) ;
       ELSE
         IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKE(
            p_action                 => 'UPDATE',
            p_rowid                  => l_rowid,
            p_status                 => p_status,
            p_owner_table_name       => 'HZ_PARTIES',
            p_owner_table_id         => p_person_id,
            P_primary_flag           => p_primary_flag,
            p_email_format           => p_email_format,
            p_email_address          => p_email_address,
            p_return_status          => l_return_status,
            p_msg_data               => l_msg_data,
            p_last_update_date       => l_date,
            p_contact_point_id       => l_contact_point_id,
            p_contact_point_ovn      => l_object_version_number,
            p_attribute_category     => c_contacs_rec.attribute_category,
            p_attribute1             => c_contacs_rec.attribute1,
            p_attribute2             => c_contacs_rec.attribute2,
            p_attribute3             => c_contacs_rec.attribute3,
            p_attribute4             => c_contacs_rec.attribute4,
            p_attribute5             => c_contacs_rec.attribute5,
            p_attribute6             => c_contacs_rec.attribute6,
            p_attribute7             => c_contacs_rec.attribute7,
            p_attribute8             => c_contacs_rec.attribute8,
            p_attribute9             => c_contacs_rec.attribute9,
            p_attribute10            => c_contacs_rec.attribute10,
            p_attribute11            => c_contacs_rec.attribute11,
            p_attribute12            => c_contacs_rec.attribute12,
            p_attribute13            => c_contacs_rec.attribute13,
            p_attribute14            => c_contacs_rec.attribute14,
            p_attribute15            => c_contacs_rec.attribute15,
            p_attribute16            => c_contacs_rec.attribute16,
            p_attribute17            => c_contacs_rec.attribute17,
            p_attribute18            => c_contacs_rec.attribute18,
            p_attribute19            => c_contacs_rec.attribute19,
            p_attribute20            => c_contacs_rec.attribute20
         ) ;
       END IF;
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
       END IF;
    END LOOP;
  ELSIF l_mode ='INSERT' THEN
      IF (p_email_format IS NULL) THEN -- Insert phone
         IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKP(
            p_action                 => 'INSERT',
            p_rowid                  => l_rowid ,
            p_status                 => p_status,
            p_owner_table_name       => 'HZ_PARTIES',
            p_owner_table_id         => p_person_id,
            P_primary_flag           => p_primary_flag,
            p_phone_country_code     => p_phone_country_code,
            p_phone_area_code        => p_phone_area_code,
            p_phone_number           => p_phone_number,
            p_phone_extension        => p_phone_extension,
            p_phone_line_type        => p_phone_line_type,
            p_return_status          => l_return_status,
            p_msg_data               => l_msg_data,
            p_last_update_date       => l_date,
            p_contact_point_id       => l_contact_point_id,
            p_contact_point_ovn      => p_contact_point_ovn
         ) ;
       ELSE
         IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKE(
            p_action                 => 'INSERT',
            p_rowid                  => l_rowid ,
            p_status                 => p_status,
            p_owner_table_name       => 'HZ_PARTIES',
            p_owner_table_id         => p_person_id,
            P_primary_flag           => p_primary_flag,
            p_email_format           => p_email_format,
            p_email_address          => p_email_address,
            p_return_status          => l_return_status,
            p_msg_data               => l_msg_data,
            p_last_update_date       => l_date,
            p_contact_point_id       => l_contact_point_id,
            p_contact_point_ovn      => p_contact_point_ovn
         ) ;
       END IF;
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
       END IF;
  END IF;
  x_id := l_contact_point_id;
  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );
EXCEPTION
    WHEN apps_exception THEN
     ROLLBACK TO Update_Phone;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Phone;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Person;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  WHEN OTHERS THEN
     ROLLBACK TO Update_Phone;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
END Update_Contact;

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
  p_status            IN   hz_party_sites.status%TYPE
)
IS

BEGIN
  -- Stubbed the procedure since we will be using the CPUI.
  NULL;
END Update_Address;

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
)
/*
   Created By           :       mesriniv
   Date Created By      :       2001/07/12
   Change History       :
   WHO           WHEN            WHAT
   pkpatel       15-MAR-2002     Bug no.2238946 :Added the parameter p_status in the call to igs_pe_party_site_use_pkg
*/
IS
 l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Usage';
 l_api_version        CONSTANT NUMBER         := 1.0;
 l_rowid              VARCHAR2(255);
 l_party_site_use_id  hz_party_site_uses.party_site_use_id%TYPE := p_party_site_use_id;
 l_party_site_id      hz_party_site_uses.party_site_id%TYPE     := p_party_site_id;
 l_site_use_id        igs_pe_partysiteuse_v.site_use_id%TYPE    := p_site_use_id;
 l_date               DATE :=sysdate;
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR(2000);
 l_mode               VARCHAR(10);

CURSOR dup_addrs_cur(cp_site_use_type hz_party_site_uses.site_use_type%TYPE,
                       cp_party_site_id hz_party_site_uses.party_site_id%TYPE,
                       cp_status hz_party_site_uses.status%TYPE
                     )IS

  SELECT party_site_use_id, object_version_number
  FROM HZ_PARTY_SITE_USES
  WHERE site_use_type = cp_site_use_type  AND
  party_site_id = cp_party_site_id AND
  status = cp_status;

  dup_addrs_rec dup_addrs_cur%ROWTYPE;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Update_Usage;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  FND_MSG_PUB.initialize;

  -- API body
  -- Retrieve current row values to be passed to the procedure.
  -- Call IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK procedure

    l_mode:= p_mode;

    IF p_mode='INSERT' THEN
             OPEN dup_addrs_cur(p_site_use_type,p_party_site_id,'I');
             FETCH dup_addrs_cur INTO dup_addrs_rec;
             CLOSE dup_addrs_cur;


             IF dup_addrs_rec.party_site_use_id IS NOT NULL THEN
                   l_mode := 'UPDATE';
                   l_party_site_use_id := dup_addrs_rec.party_site_use_id;
                   p_hz_party_site_use_ovn := dup_addrs_rec.object_version_number;
              END IF;
     END IF;

   igs_pe_party_site_use_pkg.hz_party_site_uses_ak(
            p_action                    => l_mode,
            p_rowid                     => l_rowid,
            p_party_site_use_id         => l_party_site_use_id,
            p_party_site_id             => l_party_site_id,
            p_site_use_type             => p_site_use_type,
            p_return_status             => l_return_status,
            p_msg_data                  => l_msg_data,
            p_last_update_date          => l_date,
            p_site_use_last_update_date => l_date,
            p_profile_last_update_date  => l_date,
            p_status                    => p_active,
            p_hz_party_site_use_ovn     => p_hz_party_site_use_ovn
);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     raise FND_API.G_EXC_ERROR;
  END IF;
  x_id := l_party_site_use_id;
  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );
EXCEPTION
    WHEN apps_exception THEN
     ROLLBACK TO Update_Usage;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Usage;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Usage;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  WHEN OTHERS THEN
     ROLLBACK TO Update_Usage;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
END Update_Usage;

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
)
IS
 l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Employment';
 l_api_version        CONSTANT NUMBER         := 1.0;
 l_rowid              VARCHAR2(255);
 l_employment_history_id  igs_ad_hz_emp_dtl.employment_history_id%TYPE := p_employment_history_id;
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER;
 l_msg_data           VARCHAR(2000);
 CURSOR c_rowid IS
  SELECT row_id ,
         contact,
         fraction_of_employment ,
         occupational_title_code,
         occupational_title ,
         branch ,
         military_rank,
         served ,
         station,
         reason_for_leaving,
         employed_by_party_id
   FROM igs_ad_emp_dtl
   WHERE employment_history_id = p_employment_history_id;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Update_Employment;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  FND_MSG_PUB.initialize;

  -- API body
  -- If mode='INSERT' call igs_ad_emp_dtl_pkg.INSERT_ROW
  -- If mode='UPDATE': retrieve current row values to be passed to the procedure and call igs_ad_emp_dtl_pkg.UPDATE_ROW
  -- If mode='DELETE' call igs_ad_emp_dtl_pkg.DELETE_ROW

  IF p_start_dt IS NOT NULL AND p_end_dt IS NOT NULL THEN
    IF p_start_dt > p_end_dt THEN
      FND_MESSAGE.SET_NAME ('IGS','IGS_GE_INVALID_DATE');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
  END IF;

  IF p_mode='UPDATE' THEN
     FOR c_rowid_rec IN c_rowid LOOP
       l_rowid := c_rowid_rec.row_id;
       igs_ad_emp_dtl_pkg.update_row(
            x_rowid                     => l_rowid,
            x_employment_history_id     => l_employment_history_id,
            x_person_id                 => p_person_id,
            x_start_dt                  => p_start_dt,
            x_end_dt                    => p_end_dt,
            x_type_of_employment        => p_type_of_employment,
            x_fraction_of_employment    => c_rowid_rec.fraction_of_employment,
            x_tenure_of_employment      => p_tenure_of_employment,
            x_position                  => p_position,
            x_occupational_title_code   => c_rowid_rec.occupational_title_code,
            x_occupational_title        => c_rowid_rec.occupational_title,
            x_weekly_work_hours         => p_weekly_work_hours,
            x_comments                  => p_comments,
            x_employer                  => p_employer,
            x_employed_by_division_name => p_employed_by_division_name,
            x_branch                    => c_rowid_rec.branch,
            x_military_rank             => c_rowid_rec.military_rank,
            x_served                    => c_rowid_rec.served,
            x_station                   => c_rowid_rec.station,
            x_contact                   => c_rowid_rec.contact,
            x_return_status             => l_return_status,
            x_object_version_number     => p_object_version_number,
                x_employed_by_party_id      => c_rowid_rec.employed_by_party_id,
                x_reason_for_leaving        => c_rowid_rec.reason_for_leaving,
            x_msg_data                  => l_msg_data );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
        END IF;
     END LOOP;
  ELSIF p_mode='INSERT' THEN
     igs_ad_emp_dtl_pkg.insert_row(
            x_rowid                     => l_rowid,
            x_employment_history_id     => l_employment_history_id,
            x_person_id                 => p_person_id,
            x_start_dt                  => p_start_dt,
            x_end_dt                    => p_end_dt,
            x_type_of_employment        => p_type_of_employment,
            x_fraction_of_employment    => '',
            x_tenure_of_employment      => p_tenure_of_employment,
            x_position                  => p_position,
            x_occupational_title_code   => '',
            x_occupational_title        => '',
            x_weekly_work_hours         => p_weekly_work_hours,
            x_comments                  => p_comments,
            x_employer                  => p_employer,
            x_employed_by_division_name => p_employed_by_division_name,
            x_branch                    => '',
            x_military_rank             => '',
            x_served                    => '',
            x_station                   => '',
            x_contact                   => '',
            x_return_status             => l_return_status,
            x_msg_data                  => l_msg_data,
            x_object_version_number     => p_object_version_number,
            x_employed_by_party_id      => p_employed_by_party_id,
            x_reason_for_leaving        => p_reason_for_leaving
            );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
        END IF;
  ELSIF p_mode='DELETE' THEN
     FOR c_rowid_rec IN c_rowid LOOP
       l_rowid := c_rowid_rec.row_id;
       igs_ad_emp_dtl_pkg.delete_row(
          x_rowid             =>  l_rowid);
     END LOOP;
  END IF;
  x_id := l_employment_history_id;
  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );
EXCEPTION
    WHEN apps_exception THEN
     ROLLBACK TO Update_Employment;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Employment;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Employment;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  WHEN OTHERS THEN
     ROLLBACK TO Update_Employment;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
END Update_Employment;

PROCEDURE Update_Emergency(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  x_id                OUT NOCOPY  NUMBER,
  p_mode              IN   VARCHAR2,
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
  p_rel_end           IN   VARCHAR2,
  p_hz_parties_ovn    IN OUT NOCOPY NUMBER,
  p_hz_rel_ovn        IN OUT NOCOPY NUMBER
)
IS
BEGIN
  NULL;
  -- Stubbed the procedure since its no longer used
END Update_Emergency;

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
  p_action            IN  VARCHAR2
)
IS
 l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Dates';
 l_api_version        CONSTANT NUMBER         := 1.0;
 l_rowid              VARCHAR2(255);

 CURSOR c_get_stdnt_ps_att_dtls(cp_person_id igs_en_stdnt_ps_att_all.person_id%TYPE,
                                cp_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE) IS
 SELECT *
 FROM igs_en_stdnt_ps_att
 WHERE person_id = cp_person_id AND
 course_cd = cp_course_cd;

-- l_stdnt_ps_attempt_dtls_rec c_get_stdnt_ps_att_dtls%ROWTYPE;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Update_Dates;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;

  IF P_ACTION = 'LOCK' THEN
     FOR l_stdnt_ps_attempt_dtls_rec IN c_get_stdnt_ps_att_dtls(p_person_id, p_course_cd) LOOP
        IGS_EN_STDNT_PS_ATT_PKG.LOCK_ROW(
                      X_ROWID                               => l_stdnt_ps_attempt_dtls_rec.row_id,
                      X_PERSON_ID                           => l_stdnt_ps_attempt_dtls_rec.PERSON_ID,
                      X_COURSE_CD                           => l_stdnt_ps_attempt_dtls_rec.COURSE_CD,
                      X_ADVANCED_STANDING_IND               => l_stdnt_ps_attempt_dtls_rec.ADVANCED_STANDING_IND,
                      X_FEE_CAT                             => l_stdnt_ps_attempt_dtls_rec.fee_cat,
                      X_CORRESPONDENCE_CAT                  => l_stdnt_ps_attempt_dtls_rec.correspondence_cat,
                      X_SELF_HELP_GROUP_IND                 => l_stdnt_ps_attempt_dtls_rec.SELF_HELP_GROUP_IND,
                      X_LOGICAL_DELETE_DT                   => l_stdnt_ps_attempt_dtls_rec.logical_delete_dt,
                      X_ADM_ADMISSION_APPL_NUMBER           => l_stdnt_ps_attempt_dtls_rec.adm_admission_appl_number,
                      X_ADM_NOMINATED_COURSE_CD             => l_stdnt_ps_attempt_dtls_rec.adm_nominated_course_cd,
                      X_ADM_SEQUENCE_NUMBER                 => l_stdnt_ps_attempt_dtls_rec.adm_sequence_number,
                      X_VERSION_NUMBER                      => l_stdnt_ps_attempt_dtls_rec.version_number,
                      X_CAL_TYPE                            => l_stdnt_ps_attempt_dtls_rec.cal_type,
                      X_LOCATION_CD                         => l_stdnt_ps_attempt_dtls_rec.location_cd,
                      X_ATTENDANCE_MODE                     => l_stdnt_ps_attempt_dtls_rec.attendance_mode,
                      X_ATTENDANCE_TYPE                     => l_stdnt_ps_attempt_dtls_rec.attendance_type,
                      X_COO_ID                              => l_stdnt_ps_attempt_dtls_rec.coo_id,
                      X_STUDENT_CONFIRMED_IND               => l_stdnt_ps_attempt_dtls_rec.student_confirmed_ind,
                      X_COMMENCEMENT_DT                     => l_stdnt_ps_attempt_dtls_rec.commencement_dt,
                      X_COURSE_ATTEMPT_STATUS               => l_stdnt_ps_attempt_dtls_rec.course_attempt_status,
                      X_PROGRESSION_STATUS                  => l_stdnt_ps_attempt_dtls_rec.PROGRESSION_STATUS,
                      X_DERIVED_ATT_TYPE                    => l_stdnt_ps_attempt_dtls_rec.DERIVED_ATT_TYPE,
                      X_DERIVED_ATT_MODE                    => l_stdnt_ps_attempt_dtls_rec.DERIVED_ATT_MODE,
                      X_PROVISIONAL_IND                     => l_stdnt_ps_attempt_dtls_rec.provisional_ind,
                      X_DISCONTINUED_DT                     => l_stdnt_ps_attempt_dtls_rec.DISCONTINUED_DT,
                      X_DISCONTINUATION_REASON_CD           => l_stdnt_ps_attempt_dtls_rec.DISCONTINUATION_REASON_CD,
                      X_LAPSED_DT                           => l_stdnt_ps_attempt_dtls_rec.LAPSED_DT,
                      X_FUNDING_SOURCE                      => l_stdnt_ps_attempt_dtls_rec.funding_source,
                      X_EXAM_LOCATION_CD                    => l_stdnt_ps_attempt_dtls_rec.EXAM_LOCATION_CD,
                      X_DERIVED_COMPLETION_YR               => l_stdnt_ps_attempt_dtls_rec.DERIVED_COMPLETION_YR,
                      X_DERIVED_COMPLETION_PERD             => l_stdnt_ps_attempt_dtls_rec.DERIVED_COMPLETION_PERD,
                      X_NOMINATED_COMPLETION_YR             => p_nom_year,
                      X_NOMINATED_COMPLETION_PERD           => p_nom_period,
                      X_RULE_CHECK_IND                      => l_stdnt_ps_attempt_dtls_rec.RULE_CHECK_IND,
                      X_WAIVE_OPTION_CHECK_IND              => l_stdnt_ps_attempt_dtls_rec.WAIVE_OPTION_CHECK_IND,
                      X_LAST_RULE_CHECK_DT                  => l_stdnt_ps_attempt_dtls_rec.LAST_RULE_CHECK_DT,
                      X_PUBLISH_OUTCOMES_IND                => l_stdnt_ps_attempt_dtls_rec.PUBLISH_OUTCOMES_IND,
                      X_COURSE_RQRMNT_COMPLETE_IND          => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNT_COMPLETE_IND,
                      X_COURSE_RQRMNTS_COMPLETE_DT          => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNTS_COMPLETE_DT,
                      X_S_COMPLETED_SOURCE_TYPE             => l_stdnt_ps_attempt_dtls_rec.S_COMPLETED_SOURCE_TYPE,
                      X_OVERRIDE_TIME_LIMITATION            => l_stdnt_ps_attempt_dtls_rec.OVERRIDE_TIME_LIMITATION,
                      x_last_date_of_attendance             => l_stdnt_ps_attempt_dtls_rec.last_date_of_attendance,
                      x_dropped_by                          => l_stdnt_ps_attempt_dtls_rec.dropped_by,
                      X_IGS_PR_CLASS_STD_ID                 => l_stdnt_ps_attempt_dtls_rec.igs_pr_class_std_id,
                      x_primary_program_type                => l_stdnt_ps_attempt_dtls_rec.primary_program_type,
                      x_primary_prog_type_source            => l_stdnt_ps_attempt_dtls_rec.primary_prog_type_source,
                      x_catalog_cal_type                    => l_stdnt_ps_attempt_dtls_rec.catalog_cal_type,
                      x_catalog_seq_num                     => l_stdnt_ps_attempt_dtls_rec.catalog_seq_num,
                      x_key_program                         => l_stdnt_ps_attempt_dtls_rec.key_program,
                      x_override_cmpl_dt                    => l_stdnt_ps_attempt_dtls_rec.override_cmpl_dt,
                      x_manual_ovr_cmpl_dt_ind              => l_stdnt_ps_attempt_dtls_rec.manual_ovr_cmpl_dt_ind,
                      X_ATTRIBUTE_CATEGORY                  => l_stdnt_ps_attempt_dtls_rec.attribute_category,
                      X_ATTRIBUTE1                          => l_stdnt_ps_attempt_dtls_rec.attribute1,
                      X_ATTRIBUTE2                          => l_stdnt_ps_attempt_dtls_rec.attribute2,
                      X_ATTRIBUTE3                          => l_stdnt_ps_attempt_dtls_rec.attribute3,
                      X_ATTRIBUTE4                          => l_stdnt_ps_attempt_dtls_rec.attribute4,
                      X_ATTRIBUTE5                          => l_stdnt_ps_attempt_dtls_rec.attribute5,
                      X_ATTRIBUTE6                          => l_stdnt_ps_attempt_dtls_rec.attribute6,
                      X_ATTRIBUTE7                          => l_stdnt_ps_attempt_dtls_rec.attribute7,
                      X_ATTRIBUTE8                          => l_stdnt_ps_attempt_dtls_rec.attribute8,
                      X_ATTRIBUTE9                          => l_stdnt_ps_attempt_dtls_rec.attribute9,
                      X_ATTRIBUTE10                         => l_stdnt_ps_attempt_dtls_rec.attribute10,
                      X_ATTRIBUTE11                         => l_stdnt_ps_attempt_dtls_rec.attribute11,
                      X_ATTRIBUTE12                         => l_stdnt_ps_attempt_dtls_rec.attribute12,
                      X_ATTRIBUTE13                         => l_stdnt_ps_attempt_dtls_rec.attribute13,
                      X_ATTRIBUTE14                         => l_stdnt_ps_attempt_dtls_rec.attribute14,
                      X_ATTRIBUTE15                         => l_stdnt_ps_attempt_dtls_rec.attribute15,
                      X_ATTRIBUTE16                         => l_stdnt_ps_attempt_dtls_rec.attribute16,
                      X_ATTRIBUTE17                         => l_stdnt_ps_attempt_dtls_rec.attribute17,
                      X_ATTRIBUTE18                         => l_stdnt_ps_attempt_dtls_rec.attribute18,
                      X_ATTRIBUTE19                         => l_stdnt_ps_attempt_dtls_rec.attribute19,
                      X_ATTRIBUTE20                         => l_stdnt_ps_attempt_dtls_rec.attribute20,
                      X_FUTURE_DATED_TRANS_FLAG             => l_stdnt_ps_attempt_dtls_rec.future_dated_trans_flag
                                          );
     END LOOP;
  ELSE
     -- API body
     --Update IGS_EN_STDNT_PS_ATT_ALL table.
     FOR l_stdnt_ps_attempt_dtls_rec IN c_get_stdnt_ps_att_dtls(p_person_id, p_course_cd) LOOP

        IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                      X_ROWID                               => l_stdnt_ps_attempt_dtls_rec.row_id,
                      X_PERSON_ID                           => l_stdnt_ps_attempt_dtls_rec.PERSON_ID,
                      X_COURSE_CD                           => l_stdnt_ps_attempt_dtls_rec.COURSE_CD,
                      X_ADVANCED_STANDING_IND               => l_stdnt_ps_attempt_dtls_rec.ADVANCED_STANDING_IND,
                      X_FEE_CAT                             => l_stdnt_ps_attempt_dtls_rec.fee_cat,
                      X_CORRESPONDENCE_CAT                  => l_stdnt_ps_attempt_dtls_rec.correspondence_cat,
                      X_SELF_HELP_GROUP_IND                 => l_stdnt_ps_attempt_dtls_rec.SELF_HELP_GROUP_IND,
                      X_LOGICAL_DELETE_DT                   => l_stdnt_ps_attempt_dtls_rec.logical_delete_dt,
                      X_ADM_ADMISSION_APPL_NUMBER           => l_stdnt_ps_attempt_dtls_rec.adm_admission_appl_number,
                      X_ADM_NOMINATED_COURSE_CD             => l_stdnt_ps_attempt_dtls_rec.adm_nominated_course_cd,
                      X_ADM_SEQUENCE_NUMBER                 => l_stdnt_ps_attempt_dtls_rec.adm_sequence_number,
                      X_VERSION_NUMBER                      => l_stdnt_ps_attempt_dtls_rec.version_number,
                      X_CAL_TYPE                            => l_stdnt_ps_attempt_dtls_rec.cal_type,
                      X_LOCATION_CD                         => l_stdnt_ps_attempt_dtls_rec.location_cd,
                      X_ATTENDANCE_MODE                     => l_stdnt_ps_attempt_dtls_rec.attendance_mode,
                      X_ATTENDANCE_TYPE                     => l_stdnt_ps_attempt_dtls_rec.attendance_type,
                      X_COO_ID                              => l_stdnt_ps_attempt_dtls_rec.coo_id,
                      X_STUDENT_CONFIRMED_IND               => l_stdnt_ps_attempt_dtls_rec.student_confirmed_ind,
                      X_COMMENCEMENT_DT                     => l_stdnt_ps_attempt_dtls_rec.commencement_dt,
                      X_COURSE_ATTEMPT_STATUS               => l_stdnt_ps_attempt_dtls_rec.course_attempt_status,
                      X_PROGRESSION_STATUS                  => l_stdnt_ps_attempt_dtls_rec.PROGRESSION_STATUS,
                      X_DERIVED_ATT_TYPE                    => l_stdnt_ps_attempt_dtls_rec.DERIVED_ATT_TYPE,
                      X_DERIVED_ATT_MODE                    => l_stdnt_ps_attempt_dtls_rec.DERIVED_ATT_MODE,
                      X_PROVISIONAL_IND                     => l_stdnt_ps_attempt_dtls_rec.provisional_ind,
                      X_DISCONTINUED_DT                     => l_stdnt_ps_attempt_dtls_rec.DISCONTINUED_DT,
                      X_DISCONTINUATION_REASON_CD           => l_stdnt_ps_attempt_dtls_rec.DISCONTINUATION_REASON_CD,
                      X_LAPSED_DT                           => l_stdnt_ps_attempt_dtls_rec.LAPSED_DT,
                      X_FUNDING_SOURCE                      => l_stdnt_ps_attempt_dtls_rec.funding_source,
                      X_EXAM_LOCATION_CD                    => l_stdnt_ps_attempt_dtls_rec.EXAM_LOCATION_CD,
                      X_DERIVED_COMPLETION_YR               => l_stdnt_ps_attempt_dtls_rec.DERIVED_COMPLETION_YR,
                      X_DERIVED_COMPLETION_PERD             => l_stdnt_ps_attempt_dtls_rec.DERIVED_COMPLETION_PERD,
                      X_NOMINATED_COMPLETION_YR             => p_nom_year,
                      X_NOMINATED_COMPLETION_PERD           => p_nom_period,
                      X_RULE_CHECK_IND                      => l_stdnt_ps_attempt_dtls_rec.RULE_CHECK_IND,
                      X_WAIVE_OPTION_CHECK_IND              => l_stdnt_ps_attempt_dtls_rec.WAIVE_OPTION_CHECK_IND,
                      X_LAST_RULE_CHECK_DT                  => l_stdnt_ps_attempt_dtls_rec.LAST_RULE_CHECK_DT,
                      X_PUBLISH_OUTCOMES_IND                => l_stdnt_ps_attempt_dtls_rec.PUBLISH_OUTCOMES_IND,
                      X_COURSE_RQRMNT_COMPLETE_IND          => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNT_COMPLETE_IND,
                      X_COURSE_RQRMNTS_COMPLETE_DT          => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNTS_COMPLETE_DT,
                      X_S_COMPLETED_SOURCE_TYPE             => l_stdnt_ps_attempt_dtls_rec.S_COMPLETED_SOURCE_TYPE,
                      X_OVERRIDE_TIME_LIMITATION            => l_stdnt_ps_attempt_dtls_rec.OVERRIDE_TIME_LIMITATION,
                      x_last_date_of_attendance             => l_stdnt_ps_attempt_dtls_rec.last_date_of_attendance,
                      x_dropped_by                          => l_stdnt_ps_attempt_dtls_rec.dropped_by,
                      X_IGS_PR_CLASS_STD_ID                 => l_stdnt_ps_attempt_dtls_rec.igs_pr_class_std_id,
                      x_primary_program_type                => l_stdnt_ps_attempt_dtls_rec.primary_program_type,
                      x_primary_prog_type_source            => l_stdnt_ps_attempt_dtls_rec.primary_prog_type_source,
                      x_catalog_cal_type                    => l_stdnt_ps_attempt_dtls_rec.catalog_cal_type,
                      x_catalog_seq_num                     => l_stdnt_ps_attempt_dtls_rec.catalog_seq_num,
                      x_key_program                         => l_stdnt_ps_attempt_dtls_rec.key_program,
                      x_override_cmpl_dt                    => l_stdnt_ps_attempt_dtls_rec.override_cmpl_dt,
                      x_manual_ovr_cmpl_dt_ind              => l_stdnt_ps_attempt_dtls_rec.manual_ovr_cmpl_dt_ind,
                      X_MODE                                =>  'R',
                      X_ATTRIBUTE_CATEGORY                  => l_stdnt_ps_attempt_dtls_rec.attribute_category,
                      X_ATTRIBUTE1                          => l_stdnt_ps_attempt_dtls_rec.attribute1,
                      X_ATTRIBUTE2                          => l_stdnt_ps_attempt_dtls_rec.attribute2,
                      X_ATTRIBUTE3                          => l_stdnt_ps_attempt_dtls_rec.attribute3,
                      X_ATTRIBUTE4                          => l_stdnt_ps_attempt_dtls_rec.attribute4,
                      X_ATTRIBUTE5                          => l_stdnt_ps_attempt_dtls_rec.attribute5,
                      X_ATTRIBUTE6                          => l_stdnt_ps_attempt_dtls_rec.attribute6,
                      X_ATTRIBUTE7                          => l_stdnt_ps_attempt_dtls_rec.attribute7,
                      X_ATTRIBUTE8                          => l_stdnt_ps_attempt_dtls_rec.attribute8,
                      X_ATTRIBUTE9                          => l_stdnt_ps_attempt_dtls_rec.attribute9,
                      X_ATTRIBUTE10                         => l_stdnt_ps_attempt_dtls_rec.attribute10,
                      X_ATTRIBUTE11                         => l_stdnt_ps_attempt_dtls_rec.attribute11,
                      X_ATTRIBUTE12                         => l_stdnt_ps_attempt_dtls_rec.attribute12,
                      X_ATTRIBUTE13                         => l_stdnt_ps_attempt_dtls_rec.attribute13,
                      X_ATTRIBUTE14                         => l_stdnt_ps_attempt_dtls_rec.attribute14,
                      X_ATTRIBUTE15                         => l_stdnt_ps_attempt_dtls_rec.attribute15,
                      X_ATTRIBUTE16                         => l_stdnt_ps_attempt_dtls_rec.attribute16,
                      X_ATTRIBUTE17                         => l_stdnt_ps_attempt_dtls_rec.attribute17,
                      X_ATTRIBUTE18                         => l_stdnt_ps_attempt_dtls_rec.attribute18,
                      X_ATTRIBUTE19                         => l_stdnt_ps_attempt_dtls_rec.attribute19,
                      X_ATTRIBUTE20                         => l_stdnt_ps_attempt_dtls_rec.attribute20,
                      X_FUTURE_DATED_TRANS_FLAG             => l_stdnt_ps_attempt_dtls_rec.future_dated_trans_flag
                                          );
     END LOOP;
  END IF;
    -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );
EXCEPTION
    WHEN apps_exception THEN
     ROLLBACK TO Update_Dates;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Dates;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Dates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  WHEN OTHERS THEN
     ROLLBACK TO Update_Dates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );
END Update_Dates;

FUNCTION Get_Relationship_type RETURN VARCHAR2  IS
BEGIN
  return 'CONTACT_OF';
END Get_Relationship_type;

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
  p_caller in varchar2
) IS

 l_person_rec_type Hz_Party_V2Pub.PERSON_REC_TYPE;
 l_party_rec_type Hz_Party_V2Pub.PARTY_REC_TYPE;
 v_party_last_update_date hz_person_profiles.last_update_date%TYPE;
 lv_perosn_profile_id hz_person_profiles.person_profile_id%TYPE;

  CURSOR pehz_cur (cp_person_id igs_pe_hz_parties.party_id%TYPE) IS
  SELECT pehz.ROWID, pehz.*
  FROM IGS_PE_HZ_PARTIES pehz
  WHERE party_id =  cp_person_id;

  tlinfo2 pehz_cur%ROWTYPE;

  CURSOR c_pe_stat (cp_person_id igs_pe_hz_parties.party_id%TYPE) IS
  SELECT
  p.rowid row_id,
  pp.person_profile_id,
  p.party_id person_id,
  p.party_number person_number,
  pp.effective_start_date,
  pp.effective_end_date,
  pp.declared_ethnicity ethnic_origin_id,
  pp.marital_status,
  pp.marital_status_effective_date,
  pp.internal_flag,
  sd.religion_cd religion,
  sd.next_to_kin,
  pp.place_of_birth,
  sd.socio_eco_cd socio_eco_status,
  sd.further_education_cd further_education,
  pp.household_size number_in_family,
  pp.household_income ann_family_income,
  sd.in_state_tuition,
  sd.tuition_st_date,
  sd.tuition_end_date,
  sd.matr_cal_type,
  sd.matr_sequence_number,
  sd.init_cal_type,
  sd.init_sequence_number,
  sd.recent_cal_type,
  sd.recent_sequence_number,
  sd.catalog_cal_type,
  sd.catalog_sequence_number,
  sd.attribute_category attribute_category,
  sd.attribute1 attribute1,
  sd.attribute2 attribute2,
  sd.attribute3 attribute3,
  sd.attribute4 attribute4,
  sd.attribute5 attribute5,
  sd.attribute6 attribute6,
  sd.attribute7 attribute7,
  sd.attribute8 attribute8,
  sd.attribute9 attribute9,
  sd.attribute10 attribute10,
  sd.attribute11 attribute11,
  sd.attribute12 attribute12,
  sd.attribute13 attribute13,
  sd.attribute14 attribute14,
  sd.attribute15 attribute15,
  sd.attribute16 attribute16,
  sd.attribute17 attribute17,
  sd.attribute18 attribute18,
  sd.attribute19 attribute19,
  sd.attribute20 attribute20,
  pp.global_attribute_category,
  pp.global_attribute1,
  pp.global_attribute2,
  pp.global_attribute3,
  pp.global_attribute4,
  pp.global_attribute5,
  pp.global_attribute6,
  pp.global_attribute7,
  pp.global_attribute8,
  pp.global_attribute9,
  pp.global_attribute10,
  pp.global_attribute11,
  pp.global_attribute12,
  pp.global_attribute13,
  pp.global_attribute14,
  pp.global_attribute15,
  pp.global_attribute16,
  pp.global_attribute17,
  pp.global_attribute18,
  pp.global_attribute19,
  pp.global_attribute20,
  pp.person_initials,
  pp.primary_contact_id,
  pp.personal_income,
  pp.head_of_household_flag,
  pp.content_source_type,
  pp.content_source_number,
  p.object_version_number object_version_number,
  sd.birth_cntry_resn_code
  FROM
  hz_person_profiles pp,
  igs_pe_stat_details sd,
  hz_parties p
  WHERE
  sd.person_id(+)  = p.party_id AND
  pp.party_id   = p.party_id AND
  SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date, SYSDATE) AND
  p.party_id = cp_person_id;

  cv_pe_stat c_pe_stat%ROWTYPE;

  CURSOR get_dob_dt_cur(cp_person_id igs_pe_passport.person_id%TYPE)
  IS
  SELECT birth_date
  FROM  igs_pe_person_base_v
  WHERE person_id = cp_person_id;

  l_birth_dt igs_pe_person_base_v.birth_date%TYPE;
  v_mar_dt  VARCHAR2(100);
  v_other_dt VARCHAR2(100);
  l_marital_date DATE;
  l_ethnicity igs_pe_stat_v.ethnic_origin%TYPE;
  l_religion igs_pe_stat_v.religion%TYPE;
BEGIN
  SAVEPOINT     Update_Biographic;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;

  -- API body

    IF p_marital_status_date IS NOT NULL THEN
          IF p_marital_status_date > TRUNC(SYSDATE) THEN
        FND_MESSAGE.SET_NAME ('IGS','IGS_PE_MAR_DT');
        v_mar_dt := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME ('IGS','IGS_PE_CURR_DT');
        v_other_dt := FND_MESSAGE.GET;

        FND_MESSAGE.SET_NAME ('IGS','IGS_PE_DT_VAL_FAIL');
        FND_MESSAGE.SET_TOKEN ('DATE1',v_other_dt);
        FND_MESSAGE.SET_TOKEN ('DATE2',v_mar_dt);
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
        END IF;

        OPEN get_dob_dt_cur(p_person_id);
    FETCH get_dob_dt_cur INTO l_birth_dt;
        CLOSE get_dob_dt_cur;

        IF l_birth_dt IS NOT NULL AND p_marital_status_date IS NOT NULL THEN
          IF l_birth_dt > p_marital_status_date THEN
        FND_MESSAGE.SET_NAME ('IGS','IGS_PE_MAR_DT');
        v_mar_dt := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME ('IGS','IGS_PE_BIRTH_DT');
        v_other_dt := FND_MESSAGE.GET;

        FND_MESSAGE.SET_NAME ('IGS','IGS_PE_DT_VAL_FAIL');
        FND_MESSAGE.SET_TOKEN ('DATE1',v_mar_dt);
        FND_MESSAGE.SET_TOKEN ('DATE2',v_other_dt);
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
        END IF;

        OPEN c_pe_stat(P_PERSON_ID);
        FETCH c_pe_stat INTO cv_pe_stat;
        CLOSE c_pe_stat;


 IF (p_caller = 'RELATIONSHIP_SS' AND NVL(cv_pe_stat.marital_status,'**') <> NVL(P_MARITAL_STATUS,'**')) OR
    (p_caller IS NULL) THEN

   IF cv_pe_stat.PERSON_ID IS NOT NULL THEN

        IF (p_caller = 'RELATIONSHIP_SS') THEN
         l_marital_date := cv_pe_stat.marital_status_effective_date;
         l_ethnicity := cv_pe_stat.ethnic_origin_id;
         l_religion := cv_pe_stat.religion;
        ELSE
         l_marital_date := P_MARITAL_STATUS_DATE;
         l_ethnicity := P_ETHNICITY;
         l_religion := P_RELIGION_CD;
        END IF;
        igs_pe_stat_pkg.update_row(
                x_action => 'UPDATE',
                x_rowid =>  cv_pe_stat.row_id,
                x_person_id =>  cv_pe_stat.person_id,
                x_ethnic_origin_id =>  l_ethnicity,
                x_marital_status =>  P_MARITAL_STATUS,
                x_marital_stat_effect_dt => l_marital_date,
                x_ann_family_income =>  cv_pe_stat.ann_family_income,
                x_number_in_family =>  cv_pe_stat.number_in_family,
                x_content_source_type =>  cv_pe_stat.content_source_type,
                x_internal_flag =>  cv_pe_stat.internal_flag,
                x_person_number =>  cv_pe_stat.person_number,
                x_effective_start_date =>  cv_pe_stat.effective_start_date,
                x_effective_end_date =>  cv_pe_stat.effective_end_date,
                x_ethnic_origin =>  NULL,
                x_religion =>  l_religion,
                x_next_to_kin =>  cv_pe_stat.next_to_kin,
                x_next_to_kin_meaning =>  NULL,
                x_place_of_birth =>  cv_pe_stat.place_of_birth,
                x_socio_eco_status =>  cv_pe_stat.socio_eco_status,
                x_socio_eco_status_desc =>  NULL,
                x_further_education =>  cv_pe_stat.further_education,
                x_further_education_desc =>  NULL,
                x_in_state_tuition =>  cv_pe_stat.in_state_tuition,
                x_tuition_st_date =>  cv_pe_stat.tuition_st_date,
                x_tuition_end_date =>  cv_pe_stat.tuition_end_date,
                x_person_initials =>  cv_pe_stat.person_initials,
                x_primary_contact_id =>  cv_pe_stat.primary_contact_id,
                x_personal_income =>  cv_pe_stat.personal_income,
                x_head_of_household_flag =>  cv_pe_stat.head_of_household_flag,
                x_content_source_number =>  cv_pe_stat.content_source_number,
                x_hz_parties_ovn => cv_pe_stat.object_version_number,
                x_attribute_category =>  cv_pe_stat.attribute_category,
                x_attribute1 =>  cv_pe_stat.attribute1,
                x_attribute2 =>  cv_pe_stat.attribute2,
                x_attribute3 =>  cv_pe_stat.attribute3,
                x_attribute4 =>  cv_pe_stat.attribute4,
                x_attribute5 =>  cv_pe_stat.attribute5,
                x_attribute6 =>  cv_pe_stat.attribute6,
                x_attribute7 =>  cv_pe_stat.attribute7,
                x_attribute8 =>  cv_pe_stat.attribute8,
                x_attribute9 =>  cv_pe_stat.attribute9,
                x_attribute10 =>  cv_pe_stat.attribute10,
                x_attribute11 =>  cv_pe_stat.attribute11,
                x_attribute12 =>  cv_pe_stat.attribute12,
                x_attribute13 =>  cv_pe_stat.attribute13,
                x_attribute14 =>  cv_pe_stat.attribute14,
                x_attribute15 =>  cv_pe_stat.attribute15,
                x_attribute16 =>  cv_pe_stat.attribute16,
                x_attribute17 =>  cv_pe_stat.attribute17,
                x_attribute18 =>  cv_pe_stat.attribute18,
                x_attribute19 =>  cv_pe_stat.attribute19,
                x_attribute20 =>  cv_pe_stat.attribute20,
                x_global_attribute_category =>  cv_pe_stat.global_attribute_category,
                x_global_attribute1 =>  cv_pe_stat.global_attribute1,
                x_global_attribute2 =>  cv_pe_stat.global_attribute2,
                x_global_attribute3 =>  cv_pe_stat.global_attribute3,
                x_global_attribute4 =>  cv_pe_stat.global_attribute4,
                x_global_attribute5 =>  cv_pe_stat.global_attribute5,
                x_global_attribute6 =>  cv_pe_stat.global_attribute6,
                x_global_attribute7 =>  cv_pe_stat.global_attribute7,
                x_global_attribute8 =>  cv_pe_stat.global_attribute8,
                x_global_attribute9 =>  cv_pe_stat.global_attribute9,
                x_global_attribute10=>  cv_pe_stat.global_attribute10,
                x_global_attribute11 =>  cv_pe_stat.global_attribute11,
                x_global_attribute12 =>  cv_pe_stat.global_attribute12,
                x_global_attribute13 =>  cv_pe_stat.global_attribute13,
                x_global_attribute14 =>  cv_pe_stat.global_attribute14,
                x_global_attribute15 =>  cv_pe_stat.global_attribute15,
                x_global_attribute16 =>  cv_pe_stat.global_attribute16,
                x_global_attribute17 =>  cv_pe_stat.global_attribute17,
                x_global_attribute18 =>  cv_pe_stat.global_attribute18,
                x_global_attribute19 =>  cv_pe_stat.global_attribute19,
                x_global_attribute20 =>  cv_pe_stat.global_attribute20,
                x_party_last_update_date =>  v_party_last_update_date,
                x_person_profile_id =>  lv_perosn_profile_id,
                x_matr_cal_type =>  cv_pe_stat.matr_cal_type,
                x_matr_sequence_number =>  cv_pe_stat.matr_sequence_number,
                x_init_cal_type =>  cv_pe_stat.init_cal_type,
                x_init_sequence_number =>  cv_pe_stat.init_sequence_number,
                x_recent_cal_type =>  cv_pe_stat.recent_cal_type,
                x_recent_sequence_number =>  cv_pe_stat.recent_sequence_number,
                x_catalog_cal_type =>  cv_pe_stat.catalog_cal_type,
                x_catalog_sequence_number =>  cv_pe_stat.catalog_sequence_number,
                z_return_status =>  p_return_status,
                z_msg_count =>  p_msg_count,
                z_msg_data =>  p_msg_data,
		x_birth_cntry_resn_code  => cv_pe_stat.birth_cntry_resn_code  --- prbhardw
            );

     END IF;
   END IF;

   IF (p_caller IS NULL) THEN
     IF p_return_status = 'S' THEN
          OPEN pehz_cur(p_person_id);
          FETCH pehz_cur INTO tlinfo2;

	  -- PRBHARDW  replaced update_row with add_row as part of BUG 5248350

           IGS_PE_HZ_PARTIES_PKG.ADD_ROW(
             X_ROWID                        => tlinfo2.ROWID,
             X_PARTY_ID                     => P_PERSON_ID,
             X_DECEASED_IND                 => tlinfo2.deceased_ind,
             X_ARCHIVE_EXCLUSION_IND        => tlinfo2.archive_exclusion_ind,
             X_ARCHIVE_DT                   => tlinfo2.archive_dt,
             X_PURGE_EXCLUSION_IND          => tlinfo2.purge_exclusion_ind,
             X_PURGE_DT                     => tlinfo2.purge_dt,
             X_ORACLE_USERNAME              => tlinfo2.oracle_username,
             X_PROOF_OF_INS                 => tlinfo2.proof_of_ins,
             X_PROOF_OF_IMMU                => tlinfo2.proof_of_immu,
             X_LEVEL_OF_QUAL                => tlinfo2.level_of_qual,
             X_MILITARY_SERVICE_REG         => tlinfo2.military_service_reg,
             X_VETERAN                      => P_VETERAN,
             X_INSTITUTION_CD               => tlinfo2.INSTITUTION_CD,
             X_OI_LOCAL_INSTITUTION_IND     => tlinfo2.OI_LOCAL_INSTITUTION_IND,
             X_OI_OS_IND                    => tlinfo2.OI_OS_IND,
             X_OI_GOVT_INSTITUTION_CD       => tlinfo2.OI_GOVT_INSTITUTION_CD,
             X_OI_INST_CONTROL_TYPE         => tlinfo2.OI_INST_CONTROL_TYPE,
             X_OI_INSTITUTION_TYPE          => tlinfo2.OI_INSTITUTION_TYPE,
             X_OI_INSTITUTION_STATUS        => tlinfo2.OI_INSTITUTION_STATUS,
             X_OU_START_DT                  => tlinfo2.OU_START_DT,
             X_OU_END_DT                    => tlinfo2.OU_END_DT,
             X_OU_MEMBER_TYPE               => tlinfo2.OU_MEMBER_TYPE,
             X_OU_ORG_STATUS                => tlinfo2.OU_ORG_STATUS,
             X_OU_ORG_TYPE                  => tlinfo2.OU_ORG_TYPE,
             X_INST_ORG_IND                 => tlinfo2.INST_ORG_IND,
             X_FUND_AUTHORIZATION           => tlinfo2.FUND_AUTHORIZATION,
             X_PE_INFO_VERIFY_TIME          => tlinfo2.PE_INFO_VERIFY_TIME,
             X_birth_city                   => p_birth_city,
             X_birth_country                => p_birth_country,
             X_MODE                         => 'R'
            );

	CLOSE pehz_cur;
     END IF;
   end if;
  -- End of API body.

  -- Standard call to get message count and if count is 1, get message info.

EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK TO Update_Biographic;
     p_return_status := FND_API.G_RET_STS_ERROR;
     p_msg_data := SQLERRM;
END Update_Biographic;

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
) IS
 l_message_name  VARCHAR2(30);
 l_app           VARCHAR2(50);
  CURSOR c_row_id(cp_pe_person_id igs_pe_alt_pers_id.pe_person_id%TYPE,
                  cp_api_person_id igs_pe_alt_pers_id.api_person_id%TYPE,
                                  cp_person_id_type igs_pe_alt_pers_id.person_id_type%TYPE,
                                  cp_start_dt igs_pe_alt_pers_id.start_dt%TYPE) IS
  SELECT rowid, api_person_id_uf
  FROM igs_pe_alt_pers_id
  WHERE pe_person_id = cp_pe_person_id AND
        api_person_id = cp_api_person_id AND
                person_id_type = cp_person_id_type AND
                start_dt       = cp_start_dt;

  CURSOR c_ins_row_id(cp_pe_person_id igs_pe_alt_pers_id.pe_person_id%TYPE,
                      cp_api_person_id igs_pe_alt_pers_id.api_person_id%TYPE,
                                  cp_person_id_type igs_pe_alt_pers_id.person_id_type%TYPE,
                                  cp_start_dt igs_pe_alt_pers_id.start_dt%TYPE) IS
  SELECT rowid
  FROM IGS_PE_ALT_PERS_ID
     where PE_PERSON_ID = cp_pe_person_id
     and API_PERSON_ID = cp_api_person_id
     and PERSON_ID_TYPE = cp_person_id_type
     and start_dt       = cp_start_dt
     and start_dt       = end_dt;

  l_rowid VARCHAR2(25) := NULL;
  l_Api_Person_Id_uf igs_pe_alt_pers_id.api_person_id_uf%TYPE;
  l_api_person_id  igs_pe_alt_pers_id.api_person_id%TYPE;

   CURSOR c_alt_id_desc(cp_alt_id_type in VARCHAR) IS
           SELECT description
           FROM   igs_pe_person_id_typ
           WHERE  person_id_type= cp_alt_id_type;

   l_alt_id_desc  igs_pe_person_id_typ.description%TYPE;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;

  l_api_person_id := UPPER(p_api_person_id);

  IF P_ACTION = 'INSERT' THEN
  /*
   Check whether there are any record with the same values entered and are logically deleted (start date = end date).
   If there is any record then insted of creating a new duplicate record, delete the existing record and create
   the new record.
  */

   OPEN c_ins_row_id(p_pe_person_id, l_api_person_id, p_person_id_type, p_start_dt);
   FETCH c_ins_row_id INTO l_rowid;
   CLOSE c_ins_row_id;

  IF l_rowid IS NOT NULL THEN
      igs_pe_alt_pers_id_pkg.delete_row(l_rowid,'R');
  END IF;

          l_rowid := NULL;

      igs_pe_alt_pers_id_pkg.insert_row(
        X_ROWID                     =>  l_rowid,
        X_PE_PERSON_ID              =>  P_PE_PERSON_ID,
        X_API_PERSON_ID             =>  l_api_person_id,
        X_API_PERSON_ID_UF          =>  NULL,
        X_PERSON_ID_TYPE            =>  P_PERSON_ID_TYPE,
        X_START_DT                  =>  P_START_DT,
        X_END_DT                    =>  P_END_DT,
        X_ATTRIBUTE_CATEGORY        =>  P_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1                =>  P_ATTRIBUTE1,
        X_ATTRIBUTE2                =>  P_ATTRIBUTE2,
        X_ATTRIBUTE3                =>  P_ATTRIBUTE3,
        X_ATTRIBUTE4                =>  P_ATTRIBUTE4,
        X_ATTRIBUTE5                =>  P_ATTRIBUTE5,
        X_ATTRIBUTE6                =>  P_ATTRIBUTE6,
        X_ATTRIBUTE7                =>  P_ATTRIBUTE7,
        X_ATTRIBUTE8                =>  P_ATTRIBUTE8,
        X_ATTRIBUTE9                =>  P_ATTRIBUTE9,
        X_ATTRIBUTE10               =>  P_ATTRIBUTE10,
        X_ATTRIBUTE11               =>  P_ATTRIBUTE11,
        X_ATTRIBUTE12               =>  P_ATTRIBUTE12,
        X_ATTRIBUTE13               =>  P_ATTRIBUTE13,
        X_ATTRIBUTE14               =>  P_ATTRIBUTE14,
        X_ATTRIBUTE15               =>  P_ATTRIBUTE15,
        X_ATTRIBUTE16               =>  P_ATTRIBUTE16,
        X_ATTRIBUTE17               =>  P_ATTRIBUTE17,
        X_ATTRIBUTE18               =>  P_ATTRIBUTE18,
        X_ATTRIBUTE19               =>  P_ATTRIBUTE19,
        X_ATTRIBUTE20               =>  P_ATTRIBUTE20,
        X_REGION_CD                 =>  P_REGION_CD,
        X_MODE                      =>  'R'
        );

  ELSIF P_ACTION='UPDATE' THEN
      OPEN c_row_id(p_pe_person_id, l_api_person_id, p_person_id_type, p_start_dt);
      FETCH c_row_id INTO l_rowid, l_Api_Person_Id_uf;
      CLOSE c_row_id;

    IGS_PE_ALT_PERS_ID_PKG.UPDATE_ROW(
        X_ROWID                 =>  l_rowid,
        X_PE_PERSON_ID          =>  P_PE_PERSON_ID,
        X_API_PERSON_ID         =>  l_api_person_id,
        X_API_PERSON_ID_UF      =>  NULL,
        X_PERSON_ID_TYPE        =>  P_PERSON_ID_TYPE,
        X_START_DT              =>  P_START_DT,
        X_END_DT                =>  P_END_DT,
        X_ATTRIBUTE_CATEGORY    =>  P_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1            =>  P_ATTRIBUTE1,
        X_ATTRIBUTE2            =>  P_ATTRIBUTE2,
        X_ATTRIBUTE3            =>  P_ATTRIBUTE3,
        X_ATTRIBUTE4            =>  P_ATTRIBUTE4,
        X_ATTRIBUTE5            =>  P_ATTRIBUTE5,
        X_ATTRIBUTE6            =>  P_ATTRIBUTE6,
        X_ATTRIBUTE7            =>  P_ATTRIBUTE7,
        X_ATTRIBUTE8            =>  P_ATTRIBUTE8,
        X_ATTRIBUTE9            =>  P_ATTRIBUTE9,
        X_ATTRIBUTE10           =>  P_ATTRIBUTE10,
        X_ATTRIBUTE11           =>  P_ATTRIBUTE11,
        X_ATTRIBUTE12           =>  P_ATTRIBUTE12,
        X_ATTRIBUTE13           =>  P_ATTRIBUTE13,
        X_ATTRIBUTE14           =>  P_ATTRIBUTE14,
        X_ATTRIBUTE15           =>  P_ATTRIBUTE15,
        X_ATTRIBUTE16           =>  P_ATTRIBUTE16,
        X_ATTRIBUTE17           =>  P_ATTRIBUTE17,
        X_ATTRIBUTE18           =>  P_ATTRIBUTE18,
        X_ATTRIBUTE19           =>  P_ATTRIBUTE19,
        X_ATTRIBUTE20           =>  P_ATTRIBUTE20,
        X_REGION_CD             =>  P_REGION_CD,
        X_MODE                  =>  'R'
    );

  ELSIF P_ACTION='LOCK' THEN
      OPEN c_row_id(p_pe_person_id, l_api_person_id, p_person_id_type, p_start_dt);
      FETCH c_row_id INTO l_rowid, l_Api_Person_Id_uf;
      CLOSE c_row_id;

        IGS_PE_ALT_PERS_ID_Pkg.Lock_Row (
          X_RowId                 =>  l_rowid,
          X_Pe_Person_Id          =>  p_pe_person_id,
          X_Api_Person_Id         =>  l_api_person_id,
          X_Api_Person_Id_uf      =>  l_Api_Person_Id_uf,
          X_Person_Id_Type        =>  p_person_id_type,
          X_Start_Dt              =>  p_start_dt,
          X_End_Dt                =>  p_end_dt,
          X_ATTRIBUTE_CATEGORY    =>  P_ATTRIBUTE_CATEGORY,
                  X_ATTRIBUTE1            =>  P_ATTRIBUTE1,
                  X_ATTRIBUTE2            =>  P_ATTRIBUTE2,
                  X_ATTRIBUTE3            =>  P_ATTRIBUTE3,
                  X_ATTRIBUTE4            =>  P_ATTRIBUTE4,
                  X_ATTRIBUTE5            =>  P_ATTRIBUTE5,
                  X_ATTRIBUTE6            =>  P_ATTRIBUTE6,
                  X_ATTRIBUTE7            =>  P_ATTRIBUTE7,
                  X_ATTRIBUTE8            =>  P_ATTRIBUTE8,
                  X_ATTRIBUTE9            =>  P_ATTRIBUTE9,
                  X_ATTRIBUTE10           =>  P_ATTRIBUTE10,
                  X_ATTRIBUTE11           =>  P_ATTRIBUTE11,
                  X_ATTRIBUTE12           =>  P_ATTRIBUTE12,
                  X_ATTRIBUTE13           =>  P_ATTRIBUTE13,
                  X_ATTRIBUTE14           =>  P_ATTRIBUTE14,
                  X_ATTRIBUTE15           =>  P_ATTRIBUTE15,
                  X_ATTRIBUTE16           =>  P_ATTRIBUTE16,
                  X_ATTRIBUTE17           =>  P_ATTRIBUTE17,
                  X_ATTRIBUTE18           =>  P_ATTRIBUTE18,
                  X_ATTRIBUTE19           =>  P_ATTRIBUTE19,
                  X_ATTRIBUTE20           =>  P_ATTRIBUTE20,
                  X_REGION_CD             =>  P_REGION_CD
        );

  END IF;

EXCEPTION
   WHEN OTHERS THEN
     -- To find the message name raised from the TBH
        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

        IF l_message_name = 'IGS_PE_UNIQUE_PID' THEN
                OPEN  c_alt_id_desc(P_PERSON_ID_TYPE);
                FETCH c_alt_id_desc INTO l_alt_id_desc;
                CLOSE c_alt_id_desc;

                FND_MSG_PUB.initialize ;
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_UNIQUE_PID_SS');
                FND_MESSAGE.SET_TOKEN('ALT_ID_DESC1', l_alt_id_desc);
		FND_MESSAGE.SET_TOKEN('ALT_ID_DESC2', l_alt_id_desc);
                IGS_GE_MSG_STACK.ADD;
        END IF;
        p_return_status := FND_API.G_RET_STS_ERROR;
        p_msg_data := SQLERRM;

END createupdate_pers_altid;

PROCEDURE UPDATE_TEST_RESULT_DETAILS (
 P_TEST_SEGMENT_ID IN NUMBER,
 P_TEST_RESULT_ID IN NUMBER,
 P_TEST_SCORE IN NUMBER,
 P_RETURN_STATUS OUT NOCOPY VARCHAR2,
 P_MSG_COUNT OUT NOCOPY NUMBER,
 P_MSG_DATA    OUT NOCOPY VARCHAR2
 )
 IS
   l_rowid ROWID;
   l_tst_rslt_dtls_id igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%TYPE;
   l_action VARCHAR2(30);

   CURSOR record_info_cur (cp_test_results_id igs_ad_tst_rslt_dtls.test_results_id%TYPE,
                           cp_test_segment_id igs_ad_tst_rslt_dtls.test_segment_id%TYPE)
   IS
   SELECT rowid, rslt_dtl.*
   FROM igs_ad_tst_rslt_dtls rslt_dtl
   WHERE rslt_dtl.test_results_id = cp_test_results_id AND
         rslt_dtl.test_segment_id = cp_test_segment_id;

   CURSOR parent_cur(cp_test_results_id igs_ad_tst_rslt_dtls.test_results_id%TYPE)
   IS
   SELECT test_date
   FROM igs_ad_test_results
   WHERE test_results_id = cp_test_results_id;

   record_info_rec record_info_cur%ROWTYPE;
   l_test_date DATE;
 BEGIN
  P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;

  /*
    IF for the P_TEST_RESULT_ID and P_TEST_SEGMENT_ID combination there are no records,
        then if Test score is entered, INSERT should happen.
        If there is already a record and
        Test Score is passed NULL, then DELETE should happen.
        Test score is passed NOT NULL and its NOT equal to the database value then UPDATE should happen.
  */

  OPEN record_info_cur(P_TEST_RESULT_ID, P_TEST_SEGMENT_ID);
  FETCH record_info_cur INTO record_info_rec;
    IF record_info_cur%NOTFOUND THEN
          IF P_TEST_SCORE IS NOT NULL THEN
          l_action := 'INSERT';
      END IF;
        ELSE
          IF P_TEST_SCORE IS NULL THEN
          l_action := 'DELETE';
      ELSE
            IF record_info_rec.test_score IS NULL OR (P_TEST_SCORE <> record_info_rec.test_score) THEN
                  l_action := 'UPDATE';
                END IF;
          END IF;

        END IF;
  CLOSE record_info_cur;
/*
igs_pe_elearning_pkg.debug('P_TEST_SEGMENT_ID :'||P_TEST_SEGMENT_ID);
igs_pe_elearning_pkg.debug('P_TEST_RESULT_ID :'||P_TEST_RESULT_ID);
igs_pe_elearning_pkg.debug('P_TEST_SCORE :'||P_TEST_SCORE);
igs_pe_elearning_pkg.debug('l_action :'||l_action);
*/
  IF l_action = 'INSERT' THEN
      OPEN parent_cur(p_test_result_id);
          FETCH parent_cur INTO l_test_date;
          CLOSE parent_cur;

          IF l_test_date > TRUNC(SYSDATE) THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_SS_AD_SEG_NOT_IN_FUTURE');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
          END IF;

      igs_ad_tst_rslt_dtls_pkg.insert_row(
               X_ROWID                  =>  l_rowid,
           X_TST_RSLT_DTLS_ID       =>  l_tst_rslt_dtls_id,
           X_TEST_RESULTS_ID        =>  P_TEST_RESULT_ID,
           X_TEST_SEGMENT_ID        =>  P_TEST_SEGMENT_ID,
           X_TEST_SCORE             =>  P_TEST_SCORE,
           X_PERCENTILE             =>  NULL,
           X_NATIONAL_PERCENTILE    =>  NULL,
           X_STATE_PERCENTILE       =>  NULL,
           X_PERCENTILE_YEAR_RANK   =>  NULL,
           X_SCORE_BAND_LOWER       =>  NULL,
           X_SCORE_BAND_UPPER       =>  NULL,
           X_IRREGULARITY_CODE_ID   =>  NULL,
           X_ATTRIBUTE_CATEGORY     =>  NULL,
           X_ATTRIBUTE1             =>  NULL,
           X_ATTRIBUTE2             =>  NULL,
           X_ATTRIBUTE3             =>  NULL,
           X_ATTRIBUTE4             =>  NULL,
           X_ATTRIBUTE5             =>  NULL,
           X_ATTRIBUTE6             =>  NULL,
           X_ATTRIBUTE7             =>  NULL,
           X_ATTRIBUTE8             =>  NULL,
           X_ATTRIBUTE9             =>  NULL,
           X_ATTRIBUTE10             =>  NULL,
           X_ATTRIBUTE11             =>  NULL,
           X_ATTRIBUTE12             =>  NULL,
           X_ATTRIBUTE13             =>  NULL,
           X_ATTRIBUTE14             =>  NULL,
           X_ATTRIBUTE15             =>  NULL,
           X_ATTRIBUTE16             =>  NULL,
           X_ATTRIBUTE17             =>  NULL,
           X_ATTRIBUTE18             =>  NULL,
           X_ATTRIBUTE19             =>  NULL,
           X_ATTRIBUTE20             =>  NULL
                   );

  ELSIF l_action = 'UPDATE' THEN

      igs_ad_tst_rslt_dtls_pkg.update_row(
              X_ROWID                  => record_info_rec.ROWID,
              X_TST_RSLT_DTLS_ID       => record_info_rec.TST_RSLT_DTLS_ID,
              X_TEST_RESULTS_ID        => record_info_rec.TEST_RESULTS_ID,
              X_TEST_SEGMENT_ID        => record_info_rec.TEST_SEGMENT_ID,
              X_TEST_SCORE             => P_TEST_SCORE,
              X_PERCENTILE             => record_info_rec.PERCENTILE,
              X_NATIONAL_PERCENTILE    => record_info_rec.NATIONAL_PERCENTILE,
              X_STATE_PERCENTILE       => record_info_rec.STATE_PERCENTILE,
              X_PERCENTILE_YEAR_RANK   => record_info_rec.PERCENTILE_YEAR_RANK,
              X_SCORE_BAND_LOWER       =>  record_info_rec.SCORE_BAND_LOWER,
              X_SCORE_BAND_UPPER       =>  record_info_rec.SCORE_BAND_UPPER,
              X_IRREGULARITY_CODE_ID   =>  record_info_rec.IRREGULARITY_CODE_ID,
              X_ATTRIBUTE_CATEGORY     =>  record_info_rec.ATTRIBUTE_CATEGORY,
              X_ATTRIBUTE1             =>  record_info_rec.ATTRIBUTE1,
              X_ATTRIBUTE2             =>  record_info_rec.ATTRIBUTE2,
              X_ATTRIBUTE3             =>  record_info_rec.ATTRIBUTE3,
              X_ATTRIBUTE4             =>  record_info_rec.ATTRIBUTE4,
              X_ATTRIBUTE5             =>  record_info_rec.ATTRIBUTE5,
              X_ATTRIBUTE6             =>  record_info_rec.ATTRIBUTE6,
              X_ATTRIBUTE7             =>  record_info_rec.ATTRIBUTE7,
              X_ATTRIBUTE8             =>  record_info_rec.ATTRIBUTE8,
              X_ATTRIBUTE9             =>  record_info_rec.ATTRIBUTE9,
              X_ATTRIBUTE10             =>  record_info_rec.ATTRIBUTE10,
              X_ATTRIBUTE11             =>  record_info_rec.ATTRIBUTE11,
              X_ATTRIBUTE12             =>  record_info_rec.ATTRIBUTE12,
              X_ATTRIBUTE13             =>  record_info_rec.ATTRIBUTE13,
              X_ATTRIBUTE14             =>  record_info_rec.ATTRIBUTE14,
              X_ATTRIBUTE15             =>  record_info_rec.ATTRIBUTE15,
              X_ATTRIBUTE16             =>  record_info_rec.ATTRIBUTE16,
              X_ATTRIBUTE17             =>  record_info_rec.ATTRIBUTE17,
              X_ATTRIBUTE18             =>  record_info_rec.ATTRIBUTE18,
              X_ATTRIBUTE19             =>  record_info_rec.ATTRIBUTE19,
              X_ATTRIBUTE20             => record_info_rec.ATTRIBUTE20
                          );

  ELSIF l_action = 'DELETE' THEN

             igs_ad_tst_rslt_dtls_pkg.delete_row(
                              x_rowid => record_info_rec.ROWID
                     );
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
     p_msg_data := SQLERRM;
 END UPDATE_TEST_RESULT_DETAILS;

FUNCTION CHECK_DUPLICATE_LOC(
     p_country      IN  VARCHAR2,
     p_addr_line_1      IN VARCHAR2     ,
     p_addr_line_2      IN VARCHAR2     ,
     p_addr_line_3      IN VARCHAR2     ,
     p_addr_line_4      IN VARCHAR2     ,
     p_city                     IN VARCHAR2 ,
     p_state            IN VARCHAR2     ,
     p_province         IN VARCHAR2 ,
     p_county           IN VARCHAR2 ,
     p_postal_code      IN VARCHAR2     ,
     p_object_id    IN NUMBER
     ) RETURN BOOLEAN IS

         CURSOR c_dup_loc(cp_address VARCHAR2) IS
     SELECT 1
     FROM hz_locations hl, hz_party_sites hps
     WHERE hl.COUNTRY = p_country AND
     UPPER(hl.address1||'-'||hl.address2||'-'||hl.address3||'-'||hl.address4||'-'||hl.city||'-'||hl.state||'-'||
               hl.province||'-'||hl.county||'-'||hl.postal_code) = cp_address AND
           hl.location_id = hps.location_id and
           hps.party_id = p_object_id;

      loc_count NUMBER;
          l_concat_address VARCHAR2(4000);
    BEGIN
          l_concat_address := UPPER(p_addr_line_1||'-'||p_addr_line_2||'-'||p_addr_line_3||'-'||p_addr_line_4||'-'||
          p_city||'-'||p_state||'-'||p_province||'-'||p_county||'-'||p_postal_code);

        OPEN c_dup_loc(l_concat_address);
        FETCH c_dup_loc INTO loc_count;
        CLOSE c_dup_loc;

        IF loc_count = 1 THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
END check_duplicate_loc;

PROCEDURE CREATEUPDATE_RELATIONSHIP (
  P_MODE                        IN   VARCHAR2,
  P_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  P_MSG_COUNT                   OUT NOCOPY NUMBER,
  P_MSG_DATA                    OUT NOCOPY VARCHAR2,
  P_RELATIONSHIP_ID             IN OUT NOCOPY NUMBER,
  P_DIRECTIONAL_FLAG            IN VARCHAR2,
  P_SUBJECT_ID                  IN   NUMBER,
  P_OBJECT_ID                   IN OUT NOCOPY NUMBER,
  P_FIRST_NAME                  IN   VARCHAR2,
  P_LAST_NAME                   IN   VARCHAR2,
  P_MIDDLE_NAME                 IN   VARCHAR2,
  P_PREFERRED_NAME              IN   VARCHAR2,
  P_BIRTHDATE                   IN   DATE,
  P_PRE_NAME_ADJUNCT            IN   VARCHAR2,
  P_SUFFIX                      IN   VARCHAR2,
  P_TITLE                       IN   VARCHAR2,
  P_HZ_PARTIES_OVN              IN OUT NOCOPY NUMBER,
  P_HZ_REL_OVN                  IN OUT NOCOPY NUMBER,
  P_JOINT_MAILING               IN VARCHAR2,
  P_NEXT_OF_KIN                 IN VARCHAR2,
  P_EMERGENCY_CONTACT           IN VARCHAR2,
  P_DECEASED                    IN VARCHAR2,
  P_GENDER                      IN VARCHAR2,
  P_MARITAL_STATUS              IN VARCHAR2,
  P_REP_FACULTY                 IN VARCHAR2,
  P_REP_STAFF                   IN VARCHAR2,
  P_REP_STUDENT                 IN VARCHAR2,
  P_REP_ALUMNI                  IN VARCHAR2,
  P_REL_START_DATE              IN DATE,
  P_REL_END_DATE                IN DATE,
  P_REL_CODE                    IN VARCHAR2,
  P_COPY_PRIMARY_ADDR           IN VARCHAR2
) IS
  CURSOR c_existing_rel(cp_first_name VARCHAR2, cp_last_name VARCHAR2,cp_subject_id NUMBER,cp_rel_code VARCHAR2)IS
  SELECT hr.object_id, hr.relationship_id
  FROM   hz_parties hp, hz_relationships hr
  WHERE  UPPER(hp.person_first_name) = UPPER(cp_first_name)
  AND UPPER(hp.person_last_name) = UPPER(cp_last_name)
  AND hp.party_id = hr.object_id
  AND hr.subject_id = cp_subject_id
  AND hr.relationship_code = cp_rel_code
  AND SYSDATE NOT BETWEEN hr.start_date AND NVL(hr.end_date,SYSDATE);

  CURSOR c_person (cp_object_id NUMBER)IS
 SELECT
  p.rowid row_id,
  p.party_id person_id,
  p.party_number person_number,
  p.party_name person_name,
  NULL staff_member_ind,
  p.person_last_name surname,
  p.person_first_name given_names,
  p.person_middle_name middle_name,
  p.person_name_suffix suffix,
  p.person_pre_name_adjunct pre_name_adjunct,
  p.person_title title,
  p.email_address email_addr,
  p.salutation,
  p.known_as preferred_given_name,
  pd.proof_of_ins,
  pd.proof_of_immu,
  pd.level_of_qual level_of_qual_id,
  pd.military_service_reg,
  pd.veteran,
  DECODE(pp.date_of_death,NULL,NVL(pd.deceased_ind,'N'),'Y')  deceased_ind,
  pp.gender sex,
  pp.date_of_death deceased_date,
  pp.date_of_birth birth_dt,
  pd.archive_exclusion_ind,
  pd.archive_dt,
  pd.purge_exclusion_ind,
  pd.purge_dt,
  pd.fund_authorization,
  p.attribute_category,
  p.attribute1,
  p.attribute2,
  p.attribute3,
  p.attribute4,
  p.attribute5,
  p.attribute6,
  p.attribute7,
  p.attribute8,
  p.attribute9,
  p.attribute10,
  p.attribute11,
  p.attribute12,
  p.attribute13,
  p.attribute14,
  p.attribute15,
  p.attribute16,
  p.attribute17,
  p.attribute18,
  p.attribute19,
  p.attribute20,
  p.attribute21,
  p.attribute22,
  p.attribute23,
  p.attribute24,
  pd.oracle_username ,
  pd.birth_city,
  pd.birth_country,
  p.object_version_number,
  p.status,
  pd.felony_convicted_flag,
  p.last_update_date
  FROM
  hz_parties p,
  igs_pe_hz_parties pd,
  hz_person_profiles pp
  WHERE p.party_id = cp_object_id
  AND p.party_id  = pd.party_id (+)
  AND p.party_id = pp.party_id
  AND SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date,SYSDATE);

  CURSOR c_relationship(cp_relationship_id NUMBER, cp_directional_flag VARCHAR2) IS
  SELECT
    relationship_id          ,
    subject_id               ,
    subject_type             ,
    subject_table_name       ,
    object_id                ,
    object_type              ,
    object_table_name        ,
    party_id                 ,
    relationship_code        ,
    directional_flag         ,
    comments                 ,
    start_date               ,
    end_date                 ,
    status                   ,
    created_by               ,
    creation_date            ,
    last_updated_by          ,
    last_update_date         ,
    last_update_login        ,
    content_source_type      ,
    relationship_type        ,
    object_version_number    ,
    direction_code           ,
    percentage_ownership     ,
    actual_content_source
  FROM hz_relationships
  WHERE relationship_id = cp_relationship_id
  AND directional_flag = cp_directional_flag;

  CURSOR c_rel_code(cp_rel_code VARCHAR2) IS
  SELECT relationship_type
  FROM hz_relationship_types
  WHERE forward_rel_code = cp_rel_code;

  CURSOR c_primary(cp_subject_id NUMBER) IS
  SELECT 'X' ,prel.LAST_UPDATE_DATE
  FROM hz_relationships hrel,igs_pe_hz_rel prel
  WHERE hrel.relationship_id = prel.relationship_id
  AND hrel.directional_flag = prel.directional_flag
  AND hrel.subject_id = cp_subject_id
  AND prel.primary = 'Y';

  CURSOR c_secondary(cp_subject_id NUMBER) IS
  SELECT 'X' ,prel.LAST_UPDATE_DATE
  FROM hz_relationships hrel,igs_pe_hz_rel prel
  WHERE hrel.relationship_id = prel.relationship_id
  AND hrel.directional_flag = prel.directional_flag
  AND hrel.subject_id = cp_subject_id
  AND prel.secondary = 'Y';

  CURSOR c_location(cp_subject_id NUMBER) IS
  SELECT
     ihps.start_date start_dt,
     hps.party_site_id,
     ihps.end_date end_dt,
     hl.rowid,
     hl.location_id,
     hl.country country_cd,
     hl.address_style,
     hl.address1 addr_line_1,
     hl.address2 addr_line_2,
     hl.address3 addr_line_3,
     hl.address4 addr_line_4,
     hps.identifying_address_flag correspondence,
     hl.city,
     hl.state,
     hl.province,
     hl.county,
     hl.postal_code,
     hl.address_lines_phonetic,
     hl.delivery_point_code,
     hps.status
  FROM
     hz_locations hl,
     hz_party_sites hps,
     igs_pe_hz_pty_sites ihps
  WHERE hl.location_id = hps.location_id
  AND hps.party_id = cp_subject_id
  AND hps.identifying_address_flag = 'Y'
  AND hps.party_site_id = ihps.party_site_id(+);

  CURSOR c_site_detail (cp_party_site_id NUMBER) IS
  SELECT site_use_type
  FROM   hz_party_site_uses hps
  WHERE  hps.party_site_id = cp_party_site_id;

  CURSOR c_subject_party_name (cp_subject_id NUMBER) IS
  SELECT party_name
  FROM hz_parties
  WHERE party_id = cp_subject_id;

   rec_site_detail   c_site_detail%ROWTYPE;
   rec_relationship  c_relationship%ROWTYPE;

   l_object_id          NUMBER := -1;
   l_prim_flag          VARCHAR2(1):= NULL;
   l_sec_flag           VARCHAR2(1) := NULL;
   l_prim_last_updt_dt  DATE;
   l_sec_last_updt_dt   DATE;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR(2000);
   l_row_id             VARCHAR2(255);
   l_person_id          NUMBER;
   l_person_number      VARCHAR2(100);
   l_person             c_person%ROWTYPE;
   l_rel_end_dt         DATE;
   l_rel_type           VARCHAR2(100);
   l_party_rel_id       NUMBER;
   l_party_id           NUMBER;
   l_party_number       VARCHAR2(100);
   l_primary            VARCHAR2(1) := 'N';
   l_secondary          VARCHAR2(1) := 'N';
   l_last_update        DATE := TRUNC(SYSDATE);
   l_location_id        NUMBER;
   l_loc_rowid          VARCHAR2(25);
   rec_student_addr     c_location%ROWTYPE;
   l_party_site_ovn     hz_party_sites.object_version_number%TYPE;
   l_location_ovn       hz_locations.object_version_number%TYPE;
   l_hz_rel_ovn         hz_relationships.object_version_number%TYPE;
   l_party_site_id      NUMBER;
   l_last_update_date   DATE;
   l_party_site_use_rowid   VARCHAR2(25);
   l_party_site_use_id      NUMBER;
   l_site_use_id            NUMBER;
   l_site_last_update_date  DATE;
   l_profile_last_update_date   DATE;
   l_object_version_number      NUMBER;
   l_loc_exists   BOOLEAN;
   L_SUB_PARTY_NAME hz_parties.party_name%TYPE;

   err_msg_data varchar2(200);

   CURSOR IS_HR_PERSON(CP_PARTY_ID NUMBER) IS
   SELECT 'X'
   FROM PER_ALL_PEOPLE_F
   WHERE PARTY_ID = CP_PARTY_ID;
   L_FOUND VARCHAR2(1);

   l_relationship_id NUMBER;
BEGIN
  FND_MSG_PUB.initialize;
  SAVEPOINT CreateUpdate_Relationship;
  P_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  OPEN c_existing_rel(p_first_name,p_last_name,p_subject_id,p_rel_code);
  FETCH c_existing_rel INTO l_object_id, l_relationship_id;
  CLOSE c_existing_rel;

  IF l_object_id IS NULL THEN
     l_object_id := -1;
  END IF;


  IF P_MODE = 'INSERT' AND l_object_id = -1 THEN

    OPEN c_rel_code(p_rel_code);
    FETCH c_rel_code INTO l_rel_type;
    CLOSE c_rel_code;

    IGS_PE_PERSON_PKG.INSERT_ROW (
        X_MSG_COUNT                    => P_MSG_COUNT,
        X_MSG_DATA                     => p_msg_data,
        X_RETURN_STATUS                => l_return_status,
        X_ROWID                        => l_row_id,
        X_PERSON_ID                    => P_OBJECT_ID,
        X_PERSON_NUMBER                => l_person_number,
        X_SURNAME                      => P_LAST_NAME,
        X_MIDDLE_NAME                  => P_MIDDLE_NAME,
        X_GIVEN_NAMES                  => P_FIRST_NAME,
        X_SEX                          => P_GENDER,
        X_TITLE                        => P_TITLE,
        X_STAFF_MEMBER_IND             => 'N',
        X_DECEASED_IND                 => P_DECEASED,
        X_SUFFIX                       => P_SUFFIX,
        X_PRE_NAME_ADJUNCT             => P_PRE_NAME_ADJUNCT,
        X_ARCHIVE_EXCLUSION_IND        => NULL,
        X_ARCHIVE_DT                   => NULL,
        X_PURGE_EXCLUSION_IND          => NULL,
        X_PURGE_DT                     => NULL,
        X_DECEASED_DATE                => NULL,
        X_PROOF_OF_INS                 => NULL,
        X_PROOF_OF_IMMU                => NULL,
        X_BIRTH_DT                     => P_BIRTHDATE,
        X_SALUTATION                   => P_JOINT_MAILING,
        X_ORACLE_USERNAME              => NULL,
        X_PREFERRED_GIVEN_NAME         => P_PREFERRED_NAME,
        X_EMAIL_ADDR                   => NULL,
        X_LEVEL_OF_QUAL_ID             => NULL,
        X_MILITARY_SERVICE_REG         => NULL,
        X_VETERAN                      => NULL,
        X_HZ_PARTIES_OVN               => P_HZ_PARTIES_OVN,
        X_ATTRIBUTE_CATEGORY           => NULL,
        X_ATTRIBUTE1                   => NULL,
        X_ATTRIBUTE2                   => NULL,
        X_ATTRIBUTE3                   => NULL,
        X_ATTRIBUTE4                   => NULL,
        X_ATTRIBUTE5                   => NULL,
        X_ATTRIBUTE6                   => NULL,
        X_ATTRIBUTE7                   => NULL,
        X_ATTRIBUTE8                   => NULL,
        X_ATTRIBUTE9                   => NULL,
        X_ATTRIBUTE10                  => NULL,
        X_ATTRIBUTE11                  => NULL,
        X_ATTRIBUTE12                  => NULL,
        X_ATTRIBUTE13                  => NULL,
        X_ATTRIBUTE14                  => NULL,
        X_ATTRIBUTE15                  => NULL,
        X_ATTRIBUTE16                  => NULL,
        X_ATTRIBUTE17                  => NULL,
        X_ATTRIBUTE18                  => NULL,
        X_ATTRIBUTE19                  => NULL,
        X_ATTRIBUTE20                  => NULL,
        X_PERSON_ID_TYPE               => NULL,
        X_API_PERSON_ID                => NULL,
        X_STATUS                       => 'A',
        X_ATTRIBUTE21                  => NULL,
        X_ATTRIBUTE22                  => NULL,
        X_ATTRIBUTE23                  => NULL,
        X_ATTRIBUTE24                  => NULL
        );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE_BIOGRAPHIC(
        P_PERSON_ID                 => P_OBJECT_ID,
        P_ETHNICITY                 => NULL,
        P_MARITAL_STATUS            => P_MARITAL_STATUS,
        P_MARITAL_STATUS_DATE       => NULL,
        P_BIRTH_CITY                => NULL,
        P_BIRTH_COUNTRY             => NULL,
        P_VETERAN                   => NULL,
        P_RELIGION_CD               => NULL,
        P_HZ_OVN                    => P_HZ_PARTIES_OVN,
        P_RETURN_STATUS             => l_return_status,
        P_MSG_COUNT                 => P_MSG_COUNT,
        P_MSG_DATA                  => l_msg_data,
        P_CALLER                    => 'RELATIONSHIP_SS'
        );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF P_JOINT_MAILING = 'Y' THEN
        l_primary := 'N';
        l_secondary := 'N';
        OPEN c_primary(p_subject_id);
        FETCH c_primary INTO l_prim_flag,l_prim_last_updt_dt;
        CLOSE c_primary;
        IF l_prim_flag IS NULL THEN
             l_primary    := 'Y';
        ELSE
             OPEN c_secondary(p_subject_id);
             FETCH c_secondary INTO l_sec_flag,l_sec_last_updt_dt;
             CLOSE c_secondary;

             IF l_sec_flag IS NULL THEN
                 l_secondary := 'Y';
             ELSE -- Primary,Secondary Relationships exists
                 IF l_prim_last_updt_dt >= l_sec_last_updt_dt THEN
                     l_secondary := 'Y';
                 ELSE
                     l_primary := 'Y';
                 END IF;
             END IF;
        END IF;
    END IF;

    IF P_COPY_PRIMARY_ADDR = 'Y' THEN
        OPEN c_location(p_subject_id);
        FETCH c_location INTO rec_student_addr;
        IF c_location%FOUND THEN
                 CLOSE c_location;
                 IGS_PE_PERSON_ADDR_PKG.INSERT_ROW(
                                p_action                   =>'INSERT',
                                p_rowid                    => l_loc_rowid,
                                p_location_id              => l_location_id,
                                p_start_dt                 => rec_student_addr.START_DT,
                                p_end_dt                   => rec_student_addr.END_DT,
                                p_country                  => rec_student_addr.COUNTRY_CD,
                                p_address_style            => rec_student_addr.ADDRESS_STYLE,
                                p_addr_line_1              => rec_student_addr.ADDR_LINE_1,
                                p_addr_line_2              => rec_student_addr.ADDR_LINE_2,
                                p_addr_line_3              => rec_student_addr.ADDR_LINE_3,
                                p_addr_line_4              => rec_student_addr.ADDR_LINE_4,
                                p_date_last_verified       => NULL,
                                p_correspondence           => rec_student_addr.CORRESPONDENCE,
                                p_city                     => rec_student_addr.CITY,
                                p_state                    => rec_student_addr.STATE,
                                p_province                 => rec_student_addr.PROVINCE,
                                p_county                   => rec_student_addr.COUNTY,
                                p_postal_code              => rec_student_addr.POSTAL_CODE,
                                p_address_lines_phonetic   => rec_student_addr.address_lines_phonetic,
                                p_delivery_point_code      => rec_student_addr.delivery_point_code,
                                p_other_details_1          => NULL,
                                p_other_details_2          => NULL,
                                p_other_details_3          => NULL,
                                l_return_status            => l_return_status  ,
                                l_msg_data                 => p_msg_data,
                                p_party_id                 => p_object_id,
                                p_party_site_id            => l_party_site_id,
                                p_party_type               => 'PERSON',
                                p_last_update_date         => l_last_update_date        ,
                                p_party_site_ovn           => l_party_site_ovn,
                                p_location_ovn             => l_location_ovn,
                                p_status                   => rec_student_addr.status
                   );
                 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 FOR rec_site_detail IN c_site_detail(rec_student_addr.party_site_id)
                 LOOP
                     l_party_site_use_id := NULL;
                     IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
                               p_action                     => 'INSERT',
                                p_rowid                     => l_party_site_use_rowid,
                                p_party_site_use_id         => l_party_site_use_id,
                                p_party_site_id             => l_party_site_id,
                                p_site_use_type             => rec_site_detail.site_use_type,
                                p_return_status             => l_return_status,
                                p_msg_data                  => p_msg_data,
                                p_last_update_date          => l_last_update_date,
                                p_site_use_last_update_date => l_site_last_update_date,
                                p_profile_last_update_date  => l_profile_last_update_date,
                                p_status                    => 'A',
                                P_HZ_PARTY_SITE_USE_OVN     => l_object_version_number
                    );
                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;
                  END LOOP;
        ELSE
              CLOSE c_location;
              -- THROW a error saying that there is no primary address defined
              OPEN c_subject_party_name(p_subject_id);
              FETCH c_subject_party_name INTO l_sub_party_name;
              CLOSE c_subject_party_name;

              FND_MESSAGE.SET_NAME('IGS','IGS_PE_SS_NO_PRIM_ADDR');
              FND_MESSAGE.SET_TOKEN('SUBJECT_NAME',l_sub_party_name);
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
      END IF;
    END IF; --P_COPY_PRIMARY_ADDR = 'Y'

    IGS_PE_RELATIONSHIPS_PKG.CREATUPDATE_PARTY_RELATIONSHIP(
                P_ACTION                       => 'INSERT',
                P_SUBJECT_ID                   => P_SUBJECT_ID,
                P_OBJECT_ID                    => P_OBJECT_ID,
                P_PARTY_RELATIONSHIP_TYPE      => l_rel_type,
                P_RELATIONSHIP_CODE            => P_REL_CODE,
                P_COMMENTS                     => NULL,
                P_START_DATE                   => NVL(P_REL_START_DATE,TRUNC(SYSDATE)),
                P_END_DATE                     => P_REL_END_DATE,
                P_LAST_UPDATE_DATE             => l_last_update,
                P_RETURN_STATUS                => l_return_status,
                P_MSG_COUNT                    => p_msg_count,
                P_MSG_DATA                     => p_msg_data,
                P_PARTY_RELATIONSHIP_ID        => P_RELATIONSHIP_ID,
                P_PARTY_ID                     => l_party_id,
                P_PARTY_NUMBER                 => l_party_number,
                P_CALLER                       => 'NOT_FAMILY',
                P_OBJECT_VERSION_NUMBER        => P_HZ_REL_OVN,
                P_PRIMARY                      => l_primary,
                P_SECONDARY                    => l_secondary,
                P_JOINT_SALUTATION             => P_JOINT_MAILING,
                P_NEXT_TO_KIN                  => P_NEXT_OF_KIN,
                P_REP_FACULTY                  => P_REP_FACULTY,
                P_REP_STAFF                    => P_REP_STAFF,
                P_REP_STUDENT                  => P_REP_STUDENT,
                P_REP_ALUMNI                   => P_REP_ALUMNI,
                P_DIRECTIONAL_FLAG             => P_DIRECTIONAL_FLAG,
                P_EMERGENCY_CONTACT_FLAG       => P_EMERGENCY_CONTACT
            );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF (P_MODE = 'UPDATE') OR (P_MODE = 'INSERT' AND l_object_id <> -1) THEN
         --update mode called.

         IF P_MODE = 'UPDATE' THEN
            l_rel_end_dt := P_REL_END_DATE;
            l_relationship_id := P_RELATIONSHIP_ID;
         END IF;

         IF P_MODE = 'INSERT' THEN
            l_rel_end_dt := TO_DATE('4712/12/31','YYYY/MM/DD');
            p_object_id := l_object_id;
         END IF;

         OPEN c_person(p_object_id);
         FETCH c_person INTO l_person;
         CLOSE c_person;

         p_hz_parties_ovn := l_person.object_version_number;

         IF (P_MODE = 'INSERT') THEN
            OPEN IS_HR_PERSON(p_object_id);
            FETCH IS_HR_PERSON INTO L_FOUND;
            CLOSE IS_HR_PERSON;
         END IF;
         IF L_FOUND IS NULL THEN
            IGS_PE_PERSON_PKG.UPDATE_ROW (
                X_LAST_UPDATE_DATE             => l_person.LAST_UPDATE_DATE,
                X_MSG_COUNT                    => P_MSG_COUNT,
                X_MSG_DATA                     => p_msg_data,
                X_RETURN_STATUS                => l_return_status,
                X_ROWID                        => l_person.row_id,
                X_PERSON_ID                    => p_object_id,
                X_PERSON_NUMBER                => l_person.person_number,
                X_SURNAME                      => P_LAST_NAME,
                X_MIDDLE_NAME                  => l_person.middle_name,
                X_GIVEN_NAMES                  => P_FIRST_NAME,
                X_SEX                          => P_GENDER,
                X_TITLE                        => P_TITLE,
                X_STAFF_MEMBER_IND             => l_person.STAFF_MEMBER_IND,
                X_DECEASED_IND                 => P_DECEASED,
                X_SUFFIX                       => P_SUFFIX,
                X_PRE_NAME_ADJUNCT             => P_PRE_NAME_ADJUNCT,
                X_ARCHIVE_EXCLUSION_IND        => l_person.ARCHIVE_EXCLUSION_IND,
                X_ARCHIVE_DT                   => l_person.ARCHIVE_DT,
                X_PURGE_EXCLUSION_IND          => l_person.PURGE_EXCLUSION_IND,
                X_PURGE_DT                     => l_person.PURGE_DT,
                X_DECEASED_DATE                => l_person.DECEASED_DATE,
                X_PROOF_OF_INS                 => l_person.PROOF_OF_INS,
                X_PROOF_OF_IMMU                => l_person.PROOF_OF_IMMU,
                X_BIRTH_DT                     => P_BIRTHDATE,
                X_SALUTATION                   => l_person.salutation,
                X_ORACLE_USERNAME              => l_person.ORACLE_USERNAME,
                X_PREFERRED_GIVEN_NAME         => P_PREFERRED_NAME,
                X_EMAIL_ADDR                   => l_person.EMAIL_ADDR,
                X_LEVEL_OF_QUAL_ID             => l_person.LEVEL_OF_QUAL_ID,
                X_MILITARY_SERVICE_REG         => l_person.MILITARY_SERVICE_REG,
                X_VETERAN                      => l_person.VETERAN,
                X_HZ_PARTIES_OVN               => P_HZ_PARTIES_OVN,
                X_ATTRIBUTE_CATEGORY           => l_person.ATTRIBUTE_CATEGORY,
                X_ATTRIBUTE1                   => l_person.ATTRIBUTE1,
                X_ATTRIBUTE2                   => l_person.ATTRIBUTE2,
                X_ATTRIBUTE3                   => l_person.ATTRIBUTE3,
                X_ATTRIBUTE4                   => l_person.ATTRIBUTE4,
                X_ATTRIBUTE5                   => l_person.ATTRIBUTE5,
                X_ATTRIBUTE6                   => l_person.ATTRIBUTE6,
                X_ATTRIBUTE7                   => l_person.ATTRIBUTE7,
                X_ATTRIBUTE8                   => l_person.ATTRIBUTE8,
                X_ATTRIBUTE9                   => l_person.ATTRIBUTE9,
                X_ATTRIBUTE10                  => l_person.ATTRIBUTE10,
                X_ATTRIBUTE11                  => l_person.ATTRIBUTE11,
                X_ATTRIBUTE12                  => l_person.ATTRIBUTE12,
                X_ATTRIBUTE13                  => l_person.ATTRIBUTE13,
                X_ATTRIBUTE14                  => l_person.ATTRIBUTE14,
                X_ATTRIBUTE15                  => l_person.ATTRIBUTE15,
                X_ATTRIBUTE16                  => l_person.ATTRIBUTE16,
                X_ATTRIBUTE17                  => l_person.ATTRIBUTE17,
                X_ATTRIBUTE18                  => l_person.ATTRIBUTE18,
                X_ATTRIBUTE19                  => l_person.ATTRIBUTE19,
                X_ATTRIBUTE20                  => l_person.ATTRIBUTE20,
                X_PERSON_ID_TYPE               => NULL,
                X_API_PERSON_ID                => NULL,
                X_STATUS                       => l_person.STATUS,
                X_ATTRIBUTE21                  => l_person.ATTRIBUTE21,
                X_ATTRIBUTE22                  => l_person.ATTRIBUTE22,
                X_ATTRIBUTE23                  => l_person.ATTRIBUTE23,
                X_ATTRIBUTE24                  => l_person.ATTRIBUTE24
            );
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

           UPDATE_BIOGRAPHIC(
              P_PERSON_ID                   => P_OBJECT_ID,
              P_ETHNICITY                   => NULL,
              P_MARITAL_STATUS              => P_MARITAL_STATUS,
              P_MARITAL_STATUS_DATE         => NULL,
              P_BIRTH_CITY                  => NULL,
              P_BIRTH_COUNTRY               => NULL,
              P_VETERAN                     => NULL,
              P_RELIGION_CD                 => NULL,
              P_HZ_OVN                      => P_HZ_PARTIES_OVN,
              P_RETURN_STATUS               => l_return_status,
              P_MSG_COUNT                   => P_MSG_COUNT,
              P_MSG_DATA                    => p_msg_data,
              P_CALLER                      => 'RELATIONSHIP_SS'
          );
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          err_msg_data :='IGS_PE_HR_PERS_RELATION';
        END IF;

        OPEN c_relationship(l_relationship_id,p_directional_flag);
        FETCH c_relationship INTO rec_relationship;
        CLOSE c_relationship;

        l_last_update := TRUNC(SYSDATE);
        l_hz_rel_ovn := rec_relationship.OBJECT_VERSION_NUMBER;

        IF P_JOINT_MAILING = 'Y' THEN
           OPEN c_primary(p_subject_id);
           FETCH c_primary INTO l_prim_flag,l_prim_last_updt_dt;
           CLOSE c_primary;
           IF l_prim_flag IS NULL THEN -- Primary Relationship does not exists
              l_primary    := 'Y';
           ELSE -- Primary Relationship exists
              OPEN c_secondary(p_subject_id);
              FETCH c_secondary INTO l_sec_flag,l_sec_last_updt_dt;
              CLOSE c_secondary;
              IF l_sec_flag IS NULL THEN -- Primary Relationship does not exists
                  l_secondary := 'Y';
              ELSE -- Primary,Secondary Relationships exists
                 IF l_prim_last_updt_dt >= l_sec_last_updt_dt THEN
                     l_secondary := 'Y';
                 ELSE
                     l_primary := 'Y';
                 END IF;
              END IF;
           END IF;
        END IF;

        IF P_MODE = 'INSERT' THEN
            P_RELATIONSHIP_ID := rec_relationship.RELATIONSHIP_ID;
            P_HZ_REL_OVN := l_hz_rel_ovn;
        END IF;
        IGS_PE_RELATIONSHIPS_PKG.CREATUPDATE_PARTY_RELATIONSHIP(
                P_ACTION                       => 'UPDATE',
                P_SUBJECT_ID                   => P_SUBJECT_ID,
                P_OBJECT_ID                    => p_object_id,
                P_PARTY_RELATIONSHIP_TYPE      => rec_relationship.RELATIONSHIP_TYPE,
                P_RELATIONSHIP_CODE            => rec_relationship.RELATIONSHIP_CODE,
                P_COMMENTS                     => rec_relationship.COMMENTS,
                P_START_DATE                   => rec_relationship.START_DATE,
                P_END_DATE                     => l_rel_end_dt,
                P_LAST_UPDATE_DATE             => l_last_update,
                P_RETURN_STATUS                => l_return_status,
                P_MSG_COUNT                    => p_msg_count,
                P_MSG_DATA                     => p_msg_data,
                P_PARTY_RELATIONSHIP_ID        => P_RELATIONSHIP_ID,
                P_PARTY_ID                     => rec_relationship.PARTY_ID,
                P_PARTY_NUMBER                 => l_party_number,
                P_CALLER                       => 'NOT_FAMILY',
                P_OBJECT_VERSION_NUMBER        => l_hz_rel_ovn,
                P_PRIMARY                      => l_primary,
                P_SECONDARY                    => l_secondary,
                P_JOINT_SALUTATION             => P_JOINT_MAILING,
                P_NEXT_TO_KIN                  => P_NEXT_OF_KIN,
                P_REP_FACULTY                  => P_REP_FACULTY,
                P_REP_STAFF                    => P_REP_STAFF,
                P_REP_STUDENT                  => P_REP_STUDENT,
                P_REP_ALUMNI                   => P_REP_ALUMNI,
                P_DIRECTIONAL_FLAG             => P_DIRECTIONAL_FLAG,
                P_EMERGENCY_CONTACT_FLAG       => P_EMERGENCY_CONTACT
            );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF P_COPY_PRIMARY_ADDR = 'Y' THEN

             OPEN c_location(p_subject_id);
             FETCH c_location INTO rec_student_addr;
             IF C_LOCATION%NOTFOUND THEN
                  CLOSE c_location;
                  -- THROW a error saying that there is no primary address defined
                  OPEN c_subject_party_name(p_subject_id);
                  FETCH c_subject_party_name INTO l_sub_party_name;
                  CLOSE c_subject_party_name;

                  FND_MESSAGE.SET_NAME('IGS','IGS_PE_SS_NO_PRIM_ADDR');
                  FND_MESSAGE.SET_TOKEN('SUBJECT_NAME',l_sub_party_name);
                  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
              ELSE
                  CLOSE c_location;
                  l_loc_exists :=  CHECK_DUPLICATE_LOC(
                                        p_country      => rec_student_addr.COUNTRY_CD,
                                        p_addr_line_1  => rec_student_addr.ADDR_LINE_1,
                                        p_addr_line_2  => rec_student_addr.ADDR_LINE_2,
                                        p_addr_line_3  => rec_student_addr.ADDR_LINE_3,
                                        p_addr_line_4  => rec_student_addr.ADDR_LINE_4,
                                        p_city         => rec_student_addr.CITY,
                                        p_state        => rec_student_addr.STATE,
                                        p_province     => rec_student_addr.PROVINCE,
                                        p_county       => rec_student_addr.COUNTY,
                                        p_postal_code  => rec_student_addr.POSTAL_CODE,
                                        p_object_id    => p_object_id
                                        );

                 IF (NOT l_loc_exists) THEN
                    IGS_PE_PERSON_ADDR_PKG.INSERT_ROW(
                                p_action                   =>'INSERT',
                                p_rowid                    => l_row_id,
                                p_location_id              => l_location_id,
                                p_start_dt                 => rec_student_addr.START_DT,
                                p_end_dt                   => rec_student_addr.END_DT,
                                p_country                  => rec_student_addr.COUNTRY_CD,
                                p_address_style            => rec_student_addr.ADDRESS_STYLE,
                                p_addr_line_1              => rec_student_addr.ADDR_LINE_1,
                                p_addr_line_2              => rec_student_addr.ADDR_LINE_2,
                                p_addr_line_3              => rec_student_addr.ADDR_LINE_3,
                                p_addr_line_4              => rec_student_addr.ADDR_LINE_4,
                                p_date_last_verified       => NULL,
                                p_correspondence           => rec_student_addr.CORRESPONDENCE,
                                p_city                     => rec_student_addr.CITY,
                                p_state                    => rec_student_addr.STATE,
                                p_province                 => rec_student_addr.PROVINCE,
                                p_county                   => rec_student_addr.COUNTY,
                                p_postal_code              => rec_student_addr.POSTAL_CODE,
                                p_address_lines_phonetic   => rec_student_addr.address_lines_phonetic,
                                p_delivery_point_code      => rec_student_addr.delivery_point_code,
                                p_other_details_1          => NULL,
                                p_other_details_2          => NULL,
                                p_other_details_3          => NULL,
                                l_return_status            => l_return_status  ,
                                l_msg_data                 => p_msg_data,
                                p_party_id                 => p_object_id,
                                p_party_site_id            => l_party_site_id,
                                p_party_type               => 'PERSON',
                                p_last_update_date         => l_last_update_date        ,
                                p_party_site_ovn           => l_party_site_ovn,
                                p_location_ovn             => l_location_ovn,
                                p_status                   => rec_student_addr.status
                    );
                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    FOR rec_site_detail IN c_site_detail(rec_student_addr.party_site_id)
                    LOOP
                      l_party_site_use_id := NULL;
                      IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
                                p_action                          => 'INSERT',
                                p_rowid                           => l_party_site_use_rowid,
                                p_party_site_use_id               => l_party_site_use_id,
                                p_party_site_id                   => l_party_site_id,
                                p_site_use_type                   => rec_site_detail.site_use_type,
                                p_return_status                   => l_return_status,
                                p_msg_data                        => p_msg_data,
                                p_last_update_date                => l_last_update_date,
                                p_site_use_last_update_date       => l_site_last_update_date,
                                p_profile_last_update_date        => l_profile_last_update_date,
                                p_status                          => 'A',
                                P_HZ_PARTY_SITE_USE_OVN           => l_object_version_number
                      );
                      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                           RAISE FND_API.G_EXC_ERROR;
                      END IF;
                    END LOOP;
                END IF;
            END IF;
        END IF; --P_COPY_PRIMARY_ADDR = 'Y'
  --Delete Functionality Starts
  ELSIF P_MODE = 'DELETE' THEN
          OPEN c_relationship(p_relationship_id,p_directional_flag);
          FETCH c_relationship INTO rec_relationship;
          CLOSE c_relationship;
          l_last_update := TRUNC(SYSDATE);
          l_hz_rel_ovn := rec_relationship.OBJECT_VERSION_NUMBER;

          IGS_PE_RELATIONSHIPS_PKG.CREATUPDATE_PARTY_RELATIONSHIP(
                P_ACTION                       => 'UPDATE',
                P_SUBJECT_ID                   => P_SUBJECT_ID,
                P_OBJECT_ID                    => P_OBJECT_ID,
                P_PARTY_RELATIONSHIP_TYPE      => rec_relationship.RELATIONSHIP_TYPE,
                P_RELATIONSHIP_CODE            => rec_relationship.RELATIONSHIP_CODE,
                P_COMMENTS                     => rec_relationship.COMMENTS,
                P_START_DATE                   => rec_relationship.START_DATE,
                P_END_DATE                     => TRUNC(SYSDATE),
                P_LAST_UPDATE_DATE             => l_last_update,
                P_RETURN_STATUS                => l_return_status,
                P_MSG_COUNT                    => p_msg_count,
                P_MSG_DATA                     => p_msg_data,
                P_PARTY_RELATIONSHIP_ID        => rec_relationship.RELATIONSHIP_ID,
                P_PARTY_ID                     => rec_relationship.PARTY_ID,
                P_PARTY_NUMBER                 => l_party_number,
                P_CALLER                       => 'NOT_FAMILY',
                P_OBJECT_VERSION_NUMBER        => l_hz_rel_ovn,
                P_PRIMARY                      => 'N',
                P_SECONDARY                    => 'N',
                P_JOINT_SALUTATION             => P_JOINT_MAILING,
                P_NEXT_TO_KIN                  => P_NEXT_OF_KIN,
                P_REP_FACULTY                  => P_REP_FACULTY,
                P_REP_STAFF                    => P_REP_STAFF,
                P_REP_STUDENT                  => P_REP_STUDENT,
                P_REP_ALUMNI                   => P_REP_ALUMNI,
                P_DIRECTIONAL_FLAG             => P_DIRECTIONAL_FLAG
            );
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
  -- Delete functionality ends
  END IF; --(P_MODE = 'UPDATE') or (P_MODE = 'INSERT' and l_object_id <> -1)

  p_msg_data := err_msg_data;
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK TO CreateUpdate_Relationship;
     p_return_status := FND_API.G_RET_STS_ERROR;
     p_msg_data := SQLERRM;
END createupdate_relationship;

END IGS_PE_PERSON_SS_PKG;

/
