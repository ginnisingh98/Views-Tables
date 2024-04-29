--------------------------------------------------------
--  DDL for Package Body IGS_OR_INST_IMP_003_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_INST_IMP_003_PKG" AS
/* $Header: IGSOR16B.pls 120.4 2006/06/23 05:51:00 gmaheswa noship $ */
/***************************************************************
   Created By       :   mesriniv
   Date Created By  :   2001/07/12
   Purpose      :   This is the third part of
                                Import Institutions Package
   Known Limitations,Enhancements or Remarks

   Change History   :
      ENH Bug No           :  1872994
   ENH Desc             :  Modelling and Forcasting DLD- Institutions Build
   Who          When        What
   npalanis     10-JUN-2003        Bug:2923413 igs_pe_typ_instances_pkg
                                   calls modified for the new employment
                                   category column added in the table
   masehgal             19-Aug-2002     # 2502020  Removed validation for Phone Number already existing in OSS while importing institutions
                                        Removed Commented Code
   npalanis             16-feb-2002     In  cursor cur_get_oss_contacts customer_id is removed  and  org_party_id is added
                                        Cursor  rel_party_id_cur is added to get relationship party id
                                        Cursor  cur_get_lst_date  is modified to get last_update_date from HZ_ORG_CONTACT_ROLES table
                                        In Procedure process_contact_phones rel_party_id is passed as argument  instead of cust_acct_role_id
                                        In  Cursor cur_get_oss_phones reference to cust_acct_role_id  is removed  and  owner_table_id is used to pick the record
                                        In  igs_or_contacts_v.insert_row and  igs_or_contacts_v.update_row  all the attributes that references to customer are removed
                                        In  igs_or_phones_v.insert_row and  igs_or_phones_v.update_row  all the attributes that references to customer are removed
   pkpatel      25-OCT-2002  Bug No: 2613704
                             Modified stat_type_id to stat_type_cd
   pkpatel      3-JAn-2003    Bug 2730137
                              Added the validation for contact party id in process_institution_contacts
   ssawhney                  V2API OVN changes...igs_or_contacts + igs_or_phones.
   ssaleem      22-SEP-2003  The following changes were done for IGS.L
                             a) passed values for create method as 'CREATE_IMPORT'
                             b) In the WHEN OTHERS block, replaced FND_MESSAGE.GET with
                                FND_MESSAGE.PARSE_ENCODED
                             c) Removed the check for 'IGS_AD_EVAL_XST_NO_PROSPCT'
                             d) Error code 'E162' is replaced with 'E049'
                             c) FND_FILE.PUT_LINE method calls replaced with
                                logging mechanism using FND_LOG package
   gmaheswa	27-Jan-2006  Bug:4938278 : process_institution_address: Raise Address Change event at after processing address data of all persons.
   gmaheswa   22-Jun-06      Bug 5189180: in process_institution_address, if igs_pe_person_addr_pkg.insert_row returns return_status as 'W' then set erro code E022.
 ***************************************************************/

 PROCEDURE process_institution_notes(
  p_interface_id        IN      igs_or_inst_nts_int.interface_id%TYPE,
  p_party_id            IN      hz_parties.party_id%TYPE,
  p_party_number        IN      hz_parties.party_number%TYPE)

 /***************************************************************
   Created By       :   mesriniv
   Date Created By  :   2001/07/12
   Purpose      :   This is the third part of
                                Import Institutions Package
   Known Limitations,Enhancements or Remarks
    Change History  :
   ENH Bug No           :  1872994

   ENH Desc             :  Modelling and Forcasting DLD- Institutions Build
   Who          When        What
 ***************************************************************/
 AS
 l_insert_success              BOOLEAN;
 l_update_success              BOOLEAN;
 l_party_number                hz_parties.party_number%TYPE;
 l_dml_operation               VARCHAR2(10);
 l_row_id                      ROWID;
 l_org_note_seq                igs_or_inst_nts_int.org_note_sequence%TYPE;
 l_oss_rowid                   ROWID;
 l_val_fail_err_code           igs_or_inst_nts_int.error_code%TYPE;
 l_err_cd                      igs_or_inst_nts_int.error_code%TYPE;
 l_exists                      varchar2(1);
 SKIP_NOTE                     EXCEPTION;

 --Cursor to fetch the Interface Notes Records for the Interface Identifier
 CURSOR cur_get_int_notes(cp_interface_id igs_or_inst_nts_int.interface_id%TYPE,cp_status igs_or_inst_nts_int.status%TYPE) IS
    SELECT *
    FROM   igs_or_inst_nts_int
    WHERE  interface_id  =cp_interface_id
    AND    status        =cp_status;

 --Cursor to fetch the Notes records in OSS
 CURSOR cur_get_oss_notes(p_note_type    igs_or_org_notes.org_note_type%TYPE,
                          p_org_seq_num  igs_or_org_notes.org_note_sequence%TYPE,
                          cp_party_number hz_parties.party_number%TYPE
                         ) IS
    SELECT org_notes.rowid,org_notes.*
    FROM   igs_or_org_notes  org_notes
    WHERE  org_note_type      = p_note_type
    AND    org_structure_id   = cp_party_number
    AND    org_note_sequence  = p_org_seq_num ;

 oss_notes_rec    cur_get_oss_notes%ROWTYPE;

 --Cursor added for field level validation for ORG_NOTE_TYPE
    CURSOR c_val_note_type(p_org_note_type igs_or_inst_nts_int.org_note_type%TYPE,
                           cp_inst_flag    igs_or_org_note_type.inst_flag%TYPE) IS
    SELECT 'Y'
    FROM   igs_or_org_note_type
    WHERE  org_notes_type = p_org_note_type
    AND    inst_flag=cp_inst_flag;

 c_val_note_type_rec c_val_note_type%rowtype;

 --Procedure to update the Notes Interface Table
 PROCEDURE update_int_notes(p_int_notes_rec  igs_or_inst_nts_int%ROWTYPE,
                            p_err_cd igs_or_inst_nts_int.error_code%type)
 AS

  BEGIN

     --Since there is no Table Handler Direct Update on Table
     UPDATE igs_or_inst_nts_int
     SET    status    = p_int_notes_rec.status ,
            error_code = p_err_cd
     WHERE  interface_inst_notes_id = p_int_notes_rec.interface_inst_notes_id;

     --put this information about the failed record in the log file too
     IF p_int_notes_rec.status = '3' THEN
      IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_OR_INST_IMP_FAIL');
            FND_MESSAGE.SET_TOKEN('INT_ID', p_int_notes_rec.interface_inst_notes_id);
            FND_MESSAGE.SET_TOKEN('ERROR_CODE', p_err_cd);
            FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                         'igs.plsql.igs_or_inst_imp_003.process_institution_notes.' || p_err_cd,
                                         FND_MESSAGE.GET,NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
      END IF;
     END IF;
 END update_int_notes;

 BEGIN

     l_party_number := p_party_number;
     IF l_party_number IS NULL THEN
        RAISE NO_DATA_FOUND;
     END IF;

     --Iterate through the Interface Notes records
     FOR  int_notes_rec IN cur_get_int_notes(p_interface_id,'2') LOOP

          BEGIN
             l_insert_success:=FALSE;
             l_update_success:=FALSE;
             l_dml_operation :=NULL;

             --Save Point for every Interface Notes record
             SAVEPOINT notes;

             --Fetch the Notes records in OSS
             OPEN cur_get_oss_notes(int_notes_rec.org_note_type,int_notes_rec.org_note_sequence,l_party_number);
             FETCH cur_get_oss_notes INTO oss_notes_rec;

             IF cur_get_oss_notes%NOTFOUND THEN
                --validating data before inserting
                l_exists := NULL;
                OPEN c_val_note_type(int_notes_rec.org_note_type,'Y');
                FETCH c_val_note_type INTO l_exists;
                CLOSE c_val_note_type;

                IF l_exists = 'Y' THEN
                   l_dml_operation:='INSERT';
                   --Insert the Interface Records into OSS
                   l_row_id:=NULL;
                   l_org_note_seq:=NULL;
                   igs_or_org_notes_pkg.insert_row(
                             x_rowid               => l_row_id,
                             x_org_structure_id    => LTRIM(RTRIM(l_party_number)),
                             x_org_structure_type  => 'INSTITUTE',
                             x_org_note_sequence   => l_org_note_seq,
                             x_org_note_type       => int_notes_rec.org_note_type,
                             x_start_date          => int_notes_rec.start_date,
                             x_end_date            => int_notes_rec.end_date,
                             x_note_text           => int_notes_rec.note_text,
                             x_mode                => 'R'
                             );

                   l_insert_success:=TRUE;
                   l_val_fail_err_code:=NULL;
                ELSE
                   l_val_fail_err_code:='E018';
                   int_notes_rec.status :='3';
                   update_int_notes(int_notes_rec,l_val_fail_err_code);
                   RAISE SKIP_NOTE;
                END IF;


             --There is a duplicate record in OSS
             ELSE
                --Update the OSS record with new details
                l_exists := NULL;
                OPEN c_val_note_type(int_notes_rec.org_note_type,'Y');
                FETCH c_val_note_type INTO l_exists;
                CLOSE c_val_note_type;

                IF l_exists = 'Y' THEN
                   l_dml_operation:='UPDATE';
                   igs_or_org_notes_pkg.update_row(
                             x_rowid               =>oss_notes_rec.rowid,
                             x_org_structure_id    =>oss_notes_rec.org_structure_id,
                             x_org_structure_type  =>'INSTITUTE',
                             x_org_note_sequence   =>oss_notes_rec.org_note_sequence,
                             x_org_note_type       =>oss_notes_rec.org_note_type,
                             x_start_date          =>NVL(int_notes_rec.start_date,oss_notes_rec.start_date),
                             x_end_date            =>NVL(int_notes_rec.end_date,oss_notes_rec.end_date),
                             x_note_text           =>NVL(int_notes_rec.note_text,oss_notes_rec.note_text),
                             x_mode                =>'R'
                             );
                   l_update_success:=TRUE;
                   l_val_fail_err_code:=NULL;
                ELSE
                   l_val_fail_err_code:='E018';
                   int_notes_rec.status :='3';
                   update_int_notes(int_notes_rec,l_val_fail_err_code);
                   RAISE SKIP_NOTE;
                END IF;

             END IF;
             CLOSE cur_get_oss_notes;
             int_notes_rec.status :='1';
             --Update the Interface record status as SUCCESS
             update_int_notes(int_notes_rec,NULL);
          EXCEPTION
             WHEN SKIP_NOTE THEN
                IF cur_get_oss_notes%ISOPEN THEN
                   CLOSE cur_get_oss_notes;
                END IF;
                IF c_val_note_type%ISOPEN THEN
                   CLOSE c_val_note_type;
                END IF;

            WHEN OTHERS THEN
               IF cur_get_oss_notes%ISOPEN THEN
                  CLOSE cur_get_oss_notes;
               END IF;
               IF c_val_note_type%ISOPEN THEN
                  CLOSE c_val_note_type;
               END IF;
               IF l_dml_operation='INSERT' THEN
                  IF l_val_fail_err_code IS NULL THEN
                     l_err_cd:='E019';
                  ELSE
                     l_err_cd:=l_val_fail_err_code;
                  END IF;
               ELSIF l_dml_operation='UPDATE' THEN
                  IF l_val_fail_err_code IS NULL THEN
                     l_err_cd:='E020';
               ELSE
                  l_err_cd:=l_val_fail_err_code;
               END IF;
           END IF;
           int_notes_rec.status :='3';
           --Update the Interface record status as ERROR
           update_int_notes(int_notes_rec, l_err_cd);
         END;
     END LOOP;

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
     --log message that the party_id passed is Invalid, Party ID passed must be present in Hz_parties
        IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
            FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                         'igs.plsql.igs_or_inst_imp_003.process_institution_notes.nodatafound',
                                         'Invalid Party Id: '||p_party_id ||' ,Party ID passed must be present in HZ_parties' || SQLERRM,
                                         NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
        END IF;
     WHEN OTHERS THEN
       IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME','igs_or_inst_imp_003.process_institution_notes');

           FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                        'igs.plsql.igs_or_inst_imp_003.process_institution_notes.others',
                                        FND_MESSAGE.Get || '-' || SQLERRM,
                                        NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
 END process_institution_notes;


--Procedure to process the Contacts
 PROCEDURE process_institution_contacts(
           p_interface_id    IN      igs_or_inst_con_int.interface_id%TYPE,
           p_person_type     IN      igs_pe_person.party_type%TYPE,
           p_party_id        IN      hz_parties.party_id%TYPE)
/***************************************************************
   Created By       :   mesriniv
   Date Created By  :   2001/07/12
   Purpose      :   This is the third part of
                                Import Institutions Package
   Known Limitations,Enhancements or Remarks

   Change History   :
   ENH Bug No       :  1872994
   ENH Desc         :  Modelling and Forcasting DLD- Institutions Build
   Who          When          What
   masehgal     19-Aug-2002   # 2502020  Removed validation for Phone Number
                                        already existing in OSS
   pkpatel      3-JAn-2003    Bug 2730137
                              Added the validation for contact party id
   vskumar	31-May-2006   Xbuild3 performance related fix. changed cursor select stmt cur_get_oss_contacts.
 ***************************************************************/

 AS

 l_contact_id               hz_parties.party_id%TYPE;
 l_sys_refer                hz_parties.orig_system_reference%TYPE;
 l_last_update_date         DATE;
 l_party_last_update_date   DATE;
 l_org_cont_last_update_date    DATE;
 l_org_contact_id       igs_or_contacts_v.org_contact_id%TYPE;
 l_or_cont_id           igs_or_contacts_v.org_contact_id%TYPE;
 l_org_id               igs_pe_typ_instances_all.org_id%TYPE;
 l_instance_id          igs_pe_typ_instances.type_instance_id%TYPE;
 l_contact_point_id     igs_or_contacts_v.org_contact_id%TYPE;
 l_contact_number       igs_or_contacts_v.contact_number%TYPE;
 l_cont_dml_operation   VARCHAR2(10);
 l_lst_update_date      DATE;
 l_org_contact_role_id  igs_or_contacts_v.contact_id%TYPE;
 l_rel_party_id         igs_or_contacts_v.rel_party_id%TYPE;
 l_type_rowid           ROWID;
 l_cont_point_last_update_date  DATE;
 l_prel_last_update_date        DATE;
 l_rel_party_last_update_date   DATE;
 l_return_status        VARCHAR2(1000);
 l_msg_count            NUMBER;
 l_msg_data             VARCHAR2(1000);
 l_email_address        hz_contact_points.email_address%TYPE;
 SKIP_CONTACT           EXCEPTION;
 l_val_fail_err_cd      igs_or_inst_con_int.error_code%TYPE;
 l_exists               VARCHAR2(1);

  l_org_role_ovn       igs_or_contacts_v.org_role_ovn%TYPE;
  l_rel_ovn            igs_or_contacts_v.rel_ovn%TYPE;
  l_rel_party_ovn      igs_or_contacts_v.rel_party_ovn%TYPE;
  l_org_cont_ovn       igs_or_contacts_v.org_cont_ovn%TYPE;
  l_contact_point_ovn  hz_contact_points.object_version_number%TYPE;

 --Cursor to fetch the Pending Interface Contacts
 CURSOR cur_get_int_contacts(cp_interface_id igs_or_inst_con_int.interface_id%TYPE,
                             cp_status igs_or_inst_con_int.status%TYPE) IS
    SELECT *
    FROM   igs_or_inst_con_int
    WHERE  interface_id = cp_interface_id
    AND    status       = cp_status;

 --Cursor to check if such a Contact ID exists in OSS
 CURSOR cur_get_oss_contacts(p_contact_party_id  igs_or_inst_con_int.contact_party_id%TYPE,cp_party_id hz_parties.party_id%TYPE) IS
 SELECT org_conts.attribute_category, org_conts.attribute10, org_conts.attribute11, org_conts.attribute12,
	org_conts.attribute13, org_conts.attribute14, org_conts.attribute15, org_conts.attribute16,
	org_conts.attribute17, org_conts.attribute18, org_conts.attribute19, org_conts.attribute20,
	org_conts.attribute1, org_conts.attribute2, org_conts.attribute21, org_conts.attribute22,
	org_conts.attribute23, org_conts.attribute24, org_conts.attribute3, org_conts.attribute4,
	org_conts.attribute5, org_conts.attribute6, org_conts.attribute7, org_conts.attribute8,
	org_conts.attribute9, org_conts.contact_number, TO_NUMBER(NULL) contact_id, org_conts.mail_stop,
	org_conts.OBJECT_VERSION_NUMBER org_cont_ovn, org_conts.org_contact_id, TO_NUMBER(NULL) org_role_ovn,
	org_conts.title, rel.last_update_login, rel.last_updated_by, rel.OBJECT_VERSION_NUMBER rel_ovn,
	rel.PARTY_ID rel_party_id, rel.relationship_id, rel.status, rel.subject_id contact_party_id,
	hz.OBJECT_VERSION_NUMBER rel_party_ovn
FROM
	HZ_ORG_CONTACTS org_conts,
	HZ_RELATIONSHIPS rel,
	HZ_PARTIES hz
WHERE
	org_conts.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
AND	REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
AND	REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
AND	REL.DIRECTIONAL_FLAG = 'F'
AND	REL.RELATIONSHIP_TYPE ='CONTACT'
AND	REL.OBJECT_ID = hz.PARTY_ID
AND	REL.SUBJECT_ID = p_contact_party_id
AND	REL.OBJECT_ID = cp_party_id;

-- ssawhney added OVN
 CURSOR email_cur (cp_rel_party_id  igs_or_contacts_v.rel_party_id%TYPE,
                   cp_contact_point_type hz_contact_points.contact_point_type%TYPE,
                   cp_owner_table_name hz_contact_points.owner_table_name%TYPE) IS
    SELECT email_address, contact_point_id, object_version_number
    FROM   hz_contact_points
    WHERE  owner_table_id = cp_rel_party_id
    AND    contact_point_type = cp_contact_point_type
    AND    owner_table_name = cp_owner_table_name;

 --cursor for field level validation of data , for TITLE field (tray)
 CURSOR c_val_contact_title(p_title igs_or_inst_con_int.title%TYPE,
                            cp_lookup_type fnd_lookup_values.lookup_type%TYPE,
                            cp_enabled_flag fnd_lookup_values.enabled_flag%TYPE) IS
    SELECT 'X'
    FROM   fnd_lookup_values
    WHERE  lookup_type = cp_lookup_type
    AND    lookup_code = p_title
    AND    enabled_flag = cp_enabled_flag
    AND    view_application_id = 222
    AND    security_group_id = 0
    AND    language = userenv('LANG');

 CURSOR check_person_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
 SELECT 'X'
 FROM   igs_pe_person_base_v
 WHERE  person_id = cp_person_id;

 oss_cont_rec           cur_get_oss_contacts%ROWTYPE;
 c_val_contact_title_rec  c_val_contact_title%ROWTYPE;

 --Procedure to Update the status of the Contact Id's Interface Record
 PROCEDURE update_int_contact(p_status                  igs_or_inst_con_int.status%TYPE,
                      p_interface_contacts_id   igs_or_inst_con_int.interface_contacts_id%TYPE,
                  p_contact_party_id        igs_or_inst_con_int.contact_party_id%TYPE,
                  p_err_code                igs_or_inst_con_int.error_code%TYPE,
                  p_err_text                igs_or_inst_con_int.error_text%TYPE
                 )

 AS

 BEGIN

    --Since there is no TBH direct Updation on Table
    UPDATE  igs_or_inst_con_int
    SET     status  = p_status ,
            error_code = p_err_code,
            error_text = p_err_text
    WHERE   interface_contacts_id   =p_interface_contacts_id;

    --put this information about the failed record in the log file too
    IF p_status ='3' THEN
       IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_OR_INST_IMP_FAIL');
           FND_MESSAGE.SET_TOKEN('INT_ID', p_interface_contacts_id);
           FND_MESSAGE.SET_TOKEN('ERROR_CODE', p_err_code);
           FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                        'igs.plsql.igs_or_inst_imp_003.update_int_contact.' || p_err_code,
                                        FND_MESSAGE.GET,
                                        NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
    END IF;

 END update_int_contact;

 --Associate the person type
 PROCEDURE  associate_persontype(p_interface_contacts_id igs_or_inst_con_int.interface_contacts_id%TYPE,
                         p_contact_party_id      igs_or_inst_con_int.contact_party_id%TYPE
                         ) IS

 l_person_type      igs_pe_typ_instances.person_type_code%TYPE;

 --Cursor to fetch person type
 CURSOR cur_person_type(cp_contact_party_id      igs_or_inst_con_int.contact_party_id%TYPE) IS
 SELECT  person_type_code
 FROM    igs_pe_typ_instances_all
 WHERE   person_id     = cp_contact_party_id AND
         SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);

 p_status           VARCHAR2(1);
 p_error_code       VARCHAR2(30);
 l_message_name VARCHAR2(30);
 l_app          VARCHAR2(50);

 BEGIN

   --Check if there is a Person Type for the Contact Id
   OPEN cur_person_type(p_contact_party_id);
   FETCH cur_person_type INTO l_person_type;

   --Associate the person type if not defined before.
   IF cur_person_type%NOTFOUND  THEN

      l_type_rowid:=NULL;
      l_instance_id:=NULL;

      --Create the person type for this contact id
      igs_pe_typ_instances_pkg.insert_row
         (
          x_rowid                 =>  l_type_rowid,
      x_person_id             =>  p_contact_party_id,
      x_course_cd             =>  NULL,
      x_type_instance_id      =>  l_instance_id,
      x_person_type_code      =>  p_person_type,
      x_cc_version_number     =>  NULL,
      x_funnel_status         =>  NULL,
      x_admission_appl_number =>  NULL,
      x_nominated_course_cd   =>  NULL,
      x_ncc_version_number    =>  NULL,
      x_sequence_number       =>  NULL,
      x_start_date        =>  TRUNC(SYSDATE),
      x_end_date          =>  NULL,
      x_create_method         =>  'CREATE_IMPORT',
      x_ended_by          =>  NULL,
      x_end_method        =>  NULL,
      x_mode          =>  'R',
      x_org_id        =>  l_org_id,
      x_emplmnt_category_code => NULL
      );
   END IF;
   CLOSE cur_person_type;
 EXCEPTION
   WHEN  OTHERS THEN
      CLOSE cur_person_type;
      --Rollback changes
      ROLLBACK TO contact;
      p_status := '3';

      IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN

        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
        -- The following code checks what message is returned from the API in case of an exception.
        -- It notes the message name and puts the same in the log file
        -- Added as per enhancement during Evaluate Applicant Qualifications and Make decisions build

        IF l_message_name = 'IGS_AD_PROSPCT_XST_NO_EVAL' THEN
           p_error_code := 'E049';
           -- write in log message that the evaluator already exists
           FND_MESSAGE.SET_NAME('IGS','IGS_AD_PROSPCT_XST_NO_EVAL');
           FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                        'igs.plsql.igs_or_inst_imp_003.associate_persontype.evalexst',
                                        FND_MESSAGE.Get || '-' || SQLERRM,
                                        NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);

        ELSE
           p_error_code := 'E049';
           -- Write the warning to log file --
           FND_MESSAGE.SET_NAME('IGS','IGS_OR_ERROR_PERSONTYPE');
           FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                        'igs.plsql.igs_or_inst_imp_003.associate_persontype.perstype',
                                        FND_MESSAGE.Get || '-' || SQLERRM,
                                        NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
        END IF;

      END IF;
      --Update the interface record status as 3
      --insert into chek values('a1');
      update_int_contact(p_status,p_interface_contacts_id,p_contact_party_id,p_error_code,NULL);
      RAISE SKIP_CONTACT;
 END  associate_persontype;

 --Process the Contact Phones
 PROCEDURE process_contact_phones( p_interface_cont_id    IN   igs_or_inst_cphn_int.interface_inst_cont_phone_id%TYPE,
                                   p_rel_party_id         IN   igs_or_contacts_v.rel_party_id%TYPE)
 /*
 || Change History
 ||
 || Who     When       What
 || ssawhney          OVN logic added. change to signature of IGS_OR_CONTACTS_V
*/
 AS
  l_insert_success             BOOLEAN;
  l_pty_id             hz_parties.party_id%TYPE;
  l_update_success             BOOLEAN;
  l_dml_operation              VARCHAR2(10);
  l_row_id                     ROWID;
  l_phone_id                   igs_or_phones_v.phone_id%TYPE;
  l_msg_cnt            NUMBER;
  l_msg_dt             VARCHAR2(1000);
  l_ret_status             VARCHAR2(1);
  l_last_update_date           DATE;
  l_orig_sys_ref           VARCHAR2(10);
  SKIP_PHONE               EXCEPTION;
  l_val_fail_err_cd            igs_or_inst_cphn_int.error_code%TYPE;
  l_ovn                hz_contact_points.object_version_number%TYPE;


  --Cursor to fetch the Phone information from Phone Interface Table for the Interface Identifier
  CURSOR cur_get_int_phones(cp_interface_cont_id igs_or_inst_cphn_int.interface_inst_cont_phone_id%TYPE,
                            cp_status igs_or_inst_cphn_int.status%TYPE) IS
     SELECT *
     FROM   igs_or_inst_cphn_int
     WHERE  interface_cont_id  =cp_interface_cont_id
     AND    status             =cp_status;

  int_phones_rec    cur_get_int_phones%ROWTYPE;

  --cursor for validating data before importing phones (tray)
  CURSOR c_val_phone(p_type igs_or_inst_cphn_int.type%TYPE,
                     cp_lookup_type fnd_lookup_values.lookup_type%TYPE,
                     cp_enabled_flag fnd_lookup_values.enabled_flag%TYPE) IS
     SELECT 'X'
     FROM   fnd_lookup_values
     WHERE  lookup_type = cp_lookup_type
     AND    lookup_code = p_type
     AND    enabled_flag = cp_enabled_flag
     AND    view_application_id = 222
     AND    security_group_id = 0
     AND    language = userenv('LANG');

  c_val_phone_rec c_val_phone%rowtype;

  CURSOR country_validate (p_country_code IGS_OR_INST_CPHN_INT.COUNTRY_CODE%TYPE)IS
     SELECT  phone_country_code
     FROM    fnd_territories_vl ter, hz_phone_country_codes hzc
     WHERE   ter.territory_code = hzc.territory_code
     AND     hzc.phone_country_code = p_country_code ;

  country_validate_rec country_validate%ROWTYPE;

  --Procedure to update the Phones Interface Table
  PROCEDURE update_int_phones(p_int_phones_rec  igs_or_inst_cphn_int%ROWTYPE,
                              p_err_cd igs_or_inst_cphn_int.error_code%TYPE,
                  p_err_text igs_or_inst_cphn_int.error_text%TYPE
                  )
  AS

  BEGIN

     --Since there is no Table Handler Direct Update on Table
     UPDATE igs_or_inst_cphn_int
     SET    status     = p_int_phones_rec.status,
            error_code = p_err_cd,
            error_text = p_err_text
     WHERE  interface_inst_cont_phone_id  = p_int_phones_rec.interface_inst_cont_phone_id;

     --put this information about the failed record in the log file too
     IF p_int_phones_rec.status='3' THEN
       IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_OR_INST_IMP_FAIL');
           FND_MESSAGE.SET_TOKEN('INT_ID', p_int_phones_rec.interface_inst_cont_phone_id);
           FND_MESSAGE.SET_TOKEN('ERROR_CODE', p_err_cd);
           FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                        'igs.plsql.igs_or_inst_imp_003.update_int_phones.' || p_err_cd,
                                        FND_MESSAGE.GET,
                                        NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
     END IF;
  END update_int_phones;


BEGIN --main proc begins

   --Iterate through the Interface Phones records
   FOR int_phones_rec IN cur_get_int_phones(p_interface_cont_id,'2') LOOP
       BEGIN
          l_insert_success    := FALSE;
          l_update_success    := FALSE;
          l_dml_operation     := NULL;
          l_msg_data          := NULL;
          l_ret_status        := NULL;
          l_msg_count         := NULL;
          l_last_update_date  := NULL;
          l_orig_sys_ref      := NULL;
          l_phone_id          := NULL;
          int_phones_rec.type := UPPER(int_phones_rec.type);

          --Create a save point
          SAVEPOINT phones;
          IF int_phones_rec.country_code IS NOT NULL THEN
             OPEN country_validate(int_phones_rec.country_code);
             FETCH country_validate INTO country_validate_rec;
             IF country_validate%NOTFOUND THEN
                CLOSE country_validate;
                l_val_fail_err_cd :='E050';
                int_phones_rec.status:='3';
                update_int_phones(int_phones_rec,l_val_fail_err_cd,NULL);
                RAISE SKIP_PHONE;
             END IF;
             CLOSE country_validate;
          END IF;

          -- Validate the phone "TYPE" before inserting
          OPEN c_val_phone(int_phones_rec.TYPE,'PHONE_LINE_TYPE','Y');
          FETCH c_val_phone into c_val_phone_rec;
          IF c_val_phone%FOUND THEN
             l_dml_operation:='INSERT';
             --Insert the Interface Records into OSS
             igs_or_phones_pkg.insert_row(
                                        X_Phone_Id              => l_phone_id,
                                        X_Last_Update_Date      => NULL,
                                        X_Last_Updated_By       => NULL,
                                        X_Creation_Date         => NULL,
                                        X_Created_By            => NULL,
                                        X_phone_number          => int_phones_rec.Phone_Number,
                                        X_status                => 'A',
                                        X_phone_type            => int_phones_rec.TYPE,
                                        X_Last_Update_Login     => NULL,
                                        X_Country_code          => int_phones_rec.country_Code,
                                        X_Area_Code             => int_phones_rec.area_code,
                                        X_Extension             => int_phones_rec.extension,
                                        X_Primary_Flag          =>  'N',
                                        X_Orig_System_Reference => l_orig_sys_ref,
                                        X_Attribute_Category    => int_phones_rec.attribute_category,
                                        X_Attribute1            => int_phones_rec.attribute1,
                                        X_Attribute2            => int_phones_rec.attribute2,
                                        X_Attribute3            => int_phones_rec.attribute3,
                                        X_Attribute4            => int_phones_rec.attribute4,
                                        X_Attribute5            => int_phones_rec.attribute5,
                                        X_Attribute6            => int_phones_rec.attribute6,
                                        X_Attribute7            => int_phones_rec.attribute7,
                                        X_Attribute8            => int_phones_rec.attribute8,
                                        X_Attribute9            => int_phones_rec.attribute9,
                                        X_Attribute10           => int_phones_rec.attribute10,
                                        X_Attribute11           => int_phones_rec.attribute11,
                                        X_Attribute12           => int_phones_rec.attribute12,
                                        X_Attribute13           => int_phones_rec.attribute13,
                                        X_Attribute14           => int_phones_rec.attribute14,
                                        X_Attribute15           => int_phones_rec.attribute15,
                                        X_Attribute16           => int_phones_rec.attribute16,
                                        X_Attribute17           => int_phones_rec.attribute17,
                                        X_Attribute18           => int_phones_rec.attribute18,
                                        X_Attribute19           => int_phones_rec.attribute19,
                                        X_Attribute20           => int_phones_rec.attribute20,
                                        x_party_id              => p_rel_party_id ,
                                        x_party_site_id         => NULL,
                                        x_msg_count             => l_msg_cnt,
                                        x_msg_data              => l_msg_dt,
                                        x_return_status         => l_ret_status,
                                        x_contact_point_ovn     => l_ovn
                                    );
             --Check if any error in Inserting.
             IF l_ret_status IN ('E','U') THEN
            --Error while inserting the Phone details

                l_val_fail_err_cd :='E047';
                int_phones_rec.status:='3';
                update_int_phones(int_phones_rec,l_val_fail_err_cd,NULL);

                IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
                  FND_MESSAGE.SET_NAME('IGS','IGS_OR_PHONEINSERT_ERROR');
                  FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                               'igs.plsql.igs_or_inst_imp_003.process_contact_phones.' || l_val_fail_err_cd,
                                                'contact phone id: ' || l_phone_id || '-' || FND_MESSAGE.GET || '-' || l_msg_dt,
                                                NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
                END IF;

                RAISE SKIP_PHONE;
             ELSE
                l_insert_success:=TRUE;
             END IF;
          ELSE
             l_val_fail_err_cd :='E026';
             int_phones_rec.status:='3';
             update_int_phones(int_phones_rec,l_val_fail_err_cd,NULL);
             RAISE SKIP_PHONE;
          END IF;
          CLOSE c_val_phone;

             int_phones_rec.status :='1';
             --Update the Interface record status as SUCCESS
             update_int_phones(int_phones_rec,NULL,NULL);

       EXCEPTION
          WHEN SKIP_PHONE THEN
             IF c_val_phone%ISOPEN THEN
                CLOSE c_val_phone;
             END IF;

             IF country_validate%ISOPEN THEN
                CLOSE country_validate;
             END IF;


          WHEN OTHERS THEN
             IF c_val_phone%ISOPEN THEN
                CLOSE c_val_phone;
             END IF;
             IF country_validate%ISOPEN THEN
                CLOSE country_validate;
             END IF;
             IF l_dml_operation='INSERT' THEN
                int_phones_rec.status :='3';
                update_int_phones(int_phones_rec,'E047',NULL);
             ELSIF l_dml_operation='UPDATE' THEN
                int_phones_rec.status :='3';
                update_int_phones(int_phones_rec,'E048',NULL);
             END IF;
             RAISE SKIP_PHONE;
          END;
       END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
        IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
            FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                         'igs.plsql.igs_or_inst_imp_003.process_contacts_phones.others',
                                         SQLERRM,
                                         NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
        END IF;

        APP_EXCEPTION.RAISE_EXCEPTION;
END process_contact_phones;

BEGIN

     -- starting main procedure for import of contacts

     IF p_party_id IS NULL THEN
        RAISE NO_DATA_FOUND;
     END IF;

    --Fetch the records for processing
    FOR int_cont_rec IN cur_get_int_contacts(p_interface_id,'2') LOOP

        BEGIN

           l_cont_dml_operation  := NULL;
           l_return_status       :=NULL;
           l_msg_count           :=NULL;
           l_msg_data            :=NULL;
           int_cont_rec.title := UPPER(int_cont_rec.title);

           --Create a savepoint
           SAVEPOINT contact;

           l_exists := NULL;
           OPEN check_person_cur(int_cont_rec.contact_party_id);
                   FETCH check_person_cur INTO l_exists;
             IF check_person_cur%NOTFOUND THEN
                l_val_fail_err_cd :='E054';
                int_cont_rec.status:='3';
                update_int_contact(int_cont_rec.status,int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id,l_val_fail_err_cd,NULL);
                RAISE SKIP_CONTACT;
             END IF;
           CLOSE check_person_cur;

           --Fetch the Duplicate record from OSS if any
           OPEN cur_get_oss_contacts(int_cont_rec.contact_party_id,p_party_id);
           FETCH cur_get_oss_contacts INTO oss_cont_rec;

           --If the Contact Id is already existing  then go for update of record IF NO1
           IF cur_get_oss_contacts%FOUND THEN

              IF int_cont_rec.title IS NOT NULL THEN
                 OPEN c_val_contact_title(int_cont_rec.title,'CONTACT_TITLE','Y');
                 FETCH c_val_contact_title INTO c_val_contact_title_rec;
                 IF c_val_contact_title%NOTFOUND THEN
                    l_val_fail_err_cd :='E021';
                    int_cont_rec.status:='3';
                    update_int_contact(int_cont_rec.status,int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id,l_val_fail_err_cd,NULL);
                    RAISE SKIP_CONTACT;
                 END IF;
                 CLOSE c_val_contact_title;
              END IF;

              --update the existing details
              l_cont_dml_operation :='UPDATE';

              -- re initalise the variables before assigning
              l_contact_point_id := NULL;
              l_org_contact_role_id := NULL;

              -- ssawhney OVN modifications
              OPEN email_cur(  oss_cont_rec.rel_party_id,'EMAIL','HZ_PARTIES') ;
              FETCH email_cur INTO l_email_address , l_contact_point_id ,l_contact_point_ovn;
              CLOSE email_cur;

              l_org_contact_role_id :=  oss_cont_rec.contact_id;
              l_org_role_ovn   :=   oss_cont_rec.org_role_ovn   ;  -- P_ORG_ROLE_OVN
              l_rel_ovn        :=   oss_cont_rec.rel_ovn        ;  -- P_REL_OVN
              l_rel_party_ovn  :=   oss_cont_rec.rel_party_ovn  ;  -- P_REL_PARTY_OVN
              l_org_cont_ovn   :=   oss_cont_rec.org_cont_ovn   ;  -- P_ORG_CONT_OVN

              igs_or_contacts_pkg.update_row(
                 x_last_name                   => NULL,
                 x_last_updated_by             => oss_cont_rec.last_updated_by,
                 x_last_update_date            => l_lst_update_date,
                 x_party_last_update_date      => l_party_last_update_date,
                 x_org_cont_last_update_date   => l_org_cont_last_update_date,
                 x_cont_point_last_update_date => l_cont_point_last_update_date,
                 x_prel_last_update_date       => l_prel_last_update_date,
                 x_rel_party_last_update_date  => l_rel_party_last_update_date,
                 x_status                      => oss_cont_rec.status,
                 x_contact_key                 => NULL,
                 x_first_name                  => NULL,
                 x_job_title                   => NULL,
                 x_last_update_login           => oss_cont_rec.last_update_login,
                 x_mail_stop                   => NVL( int_cont_rec.mail_stop, oss_cont_rec.mail_stop),
                 x_title                       => NVL(int_cont_rec.title, oss_cont_rec.title),
                 x_attribute_category          => NVL( int_cont_rec.attribute_category,oss_cont_rec.attribute_category),
                 x_attribute1                  => NVL (int_cont_rec.attribute1,oss_cont_rec.attribute1),
                 x_attribute2                  => NVL (int_cont_rec.attribute2,oss_cont_rec.attribute2),
                 x_attribute3                  => NVL (int_cont_rec.attribute3,oss_cont_rec.attribute3),
                 x_attribute4                  => NVL (int_cont_rec.attribute4,oss_cont_rec.attribute4),
                 x_attribute5                  => NVL (int_cont_rec.attribute5,oss_cont_rec.attribute5),
                 x_attribute6                  => NVL (int_cont_rec.attribute6,oss_cont_rec.attribute6),
                 x_attribute7                  => NVL (int_cont_rec.attribute7,oss_cont_rec.attribute7),
                 x_attribute8                  => NVL (int_cont_rec.attribute8,oss_cont_rec.attribute8),
                 x_attribute9                  => NVL (int_cont_rec.attribute9,oss_cont_rec.attribute9),
                 x_attribute10                 => NVL (int_cont_rec.attribute10,oss_cont_rec.attribute10),
                 x_attribute11                 => NVL (int_cont_rec.attribute11,oss_cont_rec.attribute11),
                 x_attribute12                 => NVL (int_cont_rec.attribute12,oss_cont_rec.attribute12),
                 x_attribute13                 => NVL (int_cont_rec.attribute13,oss_cont_rec.attribute13),
                 x_attribute14                 => NVL (int_cont_rec.attribute14,oss_cont_rec.attribute14),
                 x_attribute15                 => NVL (int_cont_rec.attribute15,oss_cont_rec.attribute15),
                 x_attribute16                 => NVL (int_cont_rec.attribute16,oss_cont_rec.attribute16),
                 x_attribute17                 => NVL (int_cont_rec.attribute17,oss_cont_rec.attribute17),
                 x_attribute18                 => NVL (int_cont_rec.attribute18,oss_cont_rec.attribute18),
                 x_attribute19                 => NVL (int_cont_rec.attribute19,oss_cont_rec.attribute19),
                 x_attribute20                 => NVL (int_cont_rec.attribute20,oss_cont_rec.attribute20),
                 x_attribute21                 => oss_cont_rec.attribute21,        --There are only 20 Attributes in Interface
                 x_attribute22                 => oss_cont_rec.attribute22,
                 x_attribute23                 => oss_cont_rec.attribute23,
                 x_attribute24                 => oss_cont_rec.attribute24,
                 x_attribute25                 => NULL,
                 x_email_address               => NVL(int_cont_rec.email,l_email_address),
                 x_last_name_alt               => NULL,
                 x_first_name_alt              => NULL ,
                 x_contact_number              => oss_cont_rec.contact_number,
                 x_party_id                    => p_party_id,
                 x_party_site_id               => NULL ,
                 x_contact_party_id            => oss_cont_rec.contact_party_id ,
                 x_org_contact_id              => oss_cont_rec.org_contact_id,
                 x_contact_point_id            => l_contact_point_id,
                 x_org_contact_role_id         => l_org_contact_role_id,
                 x_party_relationship_id       => oss_cont_rec.relationship_id ,
                 x_return_status               => l_return_status,
                 x_msg_count                   => l_msg_count,
                 x_msg_data                    => l_msg_data,
                 x_rel_party_id                => oss_cont_rec.rel_party_id,
                 P_ORG_ROLE_OVN                => l_org_role_ovn,
                 P_REL_OVN                     => l_rel_ovn,
                 P_REL_PARTY_OVN               => l_rel_party_ovn,
                 P_ORG_CONT_OVN                => l_org_cont_ovn,
                 P_CONTACT_POINT_OVN           => l_contact_point_ovn
                 );
             l_rel_party_id    :=  oss_cont_rec.rel_party_id;

              --Check if any error in Updating.
              IF l_return_status IN ('E','U') THEN
                 --Error while updating the Contact Id
                 l_val_fail_err_cd :='E025';
                 int_cont_rec.status:='3';
                 Update_int_contact(int_cont_rec.status,int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id,l_val_fail_err_cd,NULL);

                 IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_OR_CONTUPDATE_ERROR');
                   FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                                'igs.plsql.igs_or_inst_imp_003.process_institution_contacts.' || l_val_fail_err_cd,
                                                FND_MESSAGE.GET || '-' || l_msg_data,
                                                NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
                 END IF;

                 RAISE SKIP_CONTACT;
              ELSE
                 --Assign values for uploading Phone details appropriately
                 l_or_cont_id :=oss_cont_rec.org_contact_id;
              END IF;

           --Elsif the Contact Id is not found creating a new contact
             ELSE
               IF int_cont_rec.title IS NOT NULL THEN
                  OPEN c_val_contact_title(int_cont_rec.title,'CONTACT_TITLE','Y');
                  FETCH c_val_contact_title INTO c_val_contact_title_rec;
                  IF c_val_contact_title%NOTFOUND THEN
                     l_val_fail_err_cd :='E021';
                     int_cont_rec.status:='3';
                     update_int_contact(int_cont_rec.status,int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id,l_val_fail_err_cd,NULL);
                     RAISE SKIP_CONTACT;
                  END IF;
                  CLOSE c_val_contact_title;
               END IF;

                l_cont_dml_operation  := 'INSERT';
                l_contact_id          :=  NULL;
                l_org_contact_role_id :=  NULL;
                l_org_role_ovn        :=  NULL;
                l_rel_ovn             :=  NULL;
                l_rel_party_ovn       :=  NULL;
                l_org_cont_ovn        :=  NULL;
                l_contact_point_ovn   :=  NULL;

               igs_or_contacts_pkg.insert_row
                       (
                        x_last_name                  => NULL,
                        x_orig_system_reference      => int_cont_rec.reference,
                        x_status                     => 'A',
                        x_contact_key                => NULL,
                        x_first_name              => NULL,
                        x_job_title               => NULL,
                        x_mail_stop               => int_cont_rec.mail_stop,
                        x_title                   => int_cont_rec.title,
                        x_attribute_category          => int_cont_rec.attribute_category,
                        x_attribute1                  => int_cont_rec.attribute1,
                        x_attribute2                  => int_cont_rec.attribute2,
                        x_attribute3                  => int_cont_rec.attribute3,
                        x_attribute4                  => int_cont_rec.attribute4,
                        x_attribute5                  => int_cont_rec.attribute5,
                        x_attribute6                  => int_cont_rec.attribute6,
                        x_attribute7                  => int_cont_rec.attribute7,
                        x_attribute8                  => int_cont_rec.attribute8,
                        x_attribute9                  => int_cont_rec.attribute9,
                        x_attribute10                 => int_cont_rec.attribute10,
                        x_attribute11                 => int_cont_rec.attribute11,
                        x_attribute12                 => int_cont_rec.attribute12,
                        x_attribute13                 => int_cont_rec.attribute13,
                        x_attribute14                 => int_cont_rec.attribute14,
                        x_attribute15                 => int_cont_rec.attribute15,
                        x_attribute16                 => int_cont_rec.attribute16,
                        x_attribute17                 => int_cont_rec.attribute17,
                        x_attribute18                 => int_cont_rec.attribute18,
                        x_attribute19                 => int_cont_rec.attribute19,
                        x_attribute20                 => int_cont_rec.attribute20,
                        x_attribute21                 => NULL,
                        x_attribute22                 => NULL,
                        x_attribute23                 => NULL,
                        x_attribute24                 => NULL,
                        x_attribute25                 => NULL,
                        x_email_address               => int_cont_rec.email,
                        x_last_name_alt               => NULL,
                        x_first_name_alt              => NULL ,
                        x_contact_number              => l_contact_number,
                        x_party_id                    => p_party_id ,
                        x_party_site_id               => NULL ,
                        x_contact_party_id            => int_cont_rec.contact_party_id ,
                        x_org_contact_id              => l_org_contact_id,
                        x_contact_point_id            => l_contact_point_id,
                        x_org_contact_role_id         => l_org_contact_role_id,
                        x_rel_party_id                => l_rel_party_id,
                        x_created_by              => NULL,
                        x_creation_date           => NULL,
                        x_updated_by              => NULL,
                        x_update_date             => NULL,
                        x_last_update_login       => NULL,
                        x_return_status               => l_return_status,
                        x_msg_count                   => l_msg_count,
                        x_msg_data                    => l_msg_data,
                        P_ORG_ROLE_OVN                => l_org_role_ovn,
                        P_REL_OVN                     => l_rel_ovn,
                        P_REL_PARTY_OVN               => l_rel_party_ovn,
                        P_ORG_CONT_OVN                => l_org_cont_ovn,
                        P_CONTACT_POINT_OVN           => l_contact_point_ovn
                     );


           --Check if any error in Inserting
               IF l_return_status IN ('E','U') THEN
                  --Error while Inserting the Contact Id
                  l_val_fail_err_cd :='E024';
                  int_cont_rec.status:='3';
                  Update_int_contact(int_cont_rec.status,int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id,l_val_fail_err_cd,NULL);

                  IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
                    FND_MESSAGE.SET_NAME('IGS','IGS_OR_CONTINSERT_ERROR');
                    FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                                 'igs.plsql.igs_or_inst_imp_003.process_institution_contacts.' || l_val_fail_err_cd ,
                                                 FND_MESSAGE.GET || '-' || l_msg_data,
                                                 NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
                  END IF;

                  RAISE SKIP_CONTACT;
               END IF;
           --Assign values to upload the Phone details appropriately
           l_or_cont_id:=l_org_contact_id;

           END IF;  --End of check for cur_get_oss_contacts found or not
           CLOSE cur_get_oss_contacts;

          --Associate the Person Type for the Contact ID
              associate_persontype(int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id);



      --Based on whether the Contact ID was updated or Inserted
          --Need to upload the Phone details
          process_contact_phones(int_cont_rec.interface_contacts_id,l_rel_party_id);

      --Irrespective of Errors or Complete in Contact Phones Information Update the Contact Info status as
      --1,Complete
           update_int_contact('1',int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id,NULL,NULL);

      EXCEPTION
         WHEN SKIP_CONTACT THEN
            IF c_val_contact_title%ISOPEN THEN
               CLOSE c_val_contact_title;
            END IF;
            IF cur_get_oss_contacts%ISOPEN THEN
               CLOSE cur_get_oss_contacts;
            END IF;
            IF check_person_cur%ISOPEN THEN
                           CLOSE check_person_cur;
                        END IF;

         WHEN  OTHERS THEN
            IF c_val_contact_title%ISOPEN THEN
               CLOSE c_val_contact_title;
            END IF;
         IF cur_get_oss_contacts%ISOPEN THEN
            CLOSE cur_get_oss_contacts;
         END IF;
         --Error while Updating the Contact Id
         IF l_cont_dml_operation='UPDATE' THEN
            update_int_contact('3',int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id,'E025',NULL);
         END IF;
         --Error while Inserting the Contact Id
         IF l_cont_dml_operation='INSERT' THEN
            update_int_contact('3',int_cont_rec.interface_contacts_id,int_cont_rec.contact_party_id,'E025',NULL);
         END IF;
      END;
    END LOOP;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          --log message that the party_id passed is , Party ID passed must be present in Hz_partie
          IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
             FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                          'igs.plsql.igs_or_inst_imp_003.process_institution_contacts.nodatafound',
                                          'Invalid Party Id: '||p_party_id ||' ,Party ID passed must be present in HZ_parties - ' || SQLERRM,
                                          NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
          END IF;
       WHEN OTHERS THEN
          IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
             FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                          'igs.plsql.igs_or_inst_imp_003.process_institution_contacts.others',
                                          SQLERRM,
                                          NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
          END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;
END process_institution_contacts;

--Procedure to Upload the Institution Statistics
  PROCEDURE process_institution_statistics (
  p_interface_id        IN      igs_or_inst_stat_int.interface_id%TYPE,
  p_party_id            IN      hz_parties.party_id%TYPE)
/***************************************************************
   Created By       :   mesriniv
   Date Created By  :   2001/07/12
   Purpose      :   This is the third part of
                                Import Institutions Package
   Known Limitations,Enhancements or Remarks

   Change History   :
   ENH Bug No           :  1872994
   ENH Desc             :  Modelling and Forcasting DLD- Institutions Build
   Who          When        What
   pkpatel      25-OCT-2002  Bug No: 2613704
                             Modified stat_type_id to stat_type_cd
 ***************************************************************/
AS
  l_mast_insert_success   BOOLEAN;
  l_mast_dml_operation    VARCHAR2(10);

  l_det_insert_success    BOOLEAN;
  l_det_update_success    BOOLEAN;
  l_det_dml_operation     VARCHAR2(10);
  l_row_id                ROWID;
  l_inst_stat_id          igs_or_inst_stats.inst_stat_id%TYPE;
  l_det_row_id            ROWID;
  l_dtl_id                igs_or_inst_stat_dtl.inst_stat_dtl_id%TYPE;
  l_party_number          hz_parties.party_number%TYPE;

  SKIP_STAT_MAST          EXCEPTION;

  --Cursor to fetch the Interface Statistics Master Records for the Interface Identifier
  CURSOR cur_get_int_stat_master(cp_interface_id   igs_or_inst_stat_int.interface_id%TYPE,
                                 cp_status         igs_or_inst_stat_int.status%TYPE) IS
     SELECT *
     FROM   igs_or_inst_stat_int
     WHERE  interface_id  =cp_interface_id
     AND    status        =cp_status ;

  --Cursor to fetch the Interface Statistics Detail Records for this Statistics master record
  CURSOR cur_get_int_stat_det(p_int_stat_id  igs_or_inst_sdtl_int.interface_inst_stat_id%TYPE,
                              cp_status      igs_or_inst_sdtl_int.status%TYPE) IS
     SELECT sdtl.rowid,sdtl.*
     FROM   igs_or_inst_sdtl_int sdtl
     WHERE  interface_inst_stat_id = p_int_stat_id
     AND    status                 = cp_status;

  --Cursor to fetch the OSS Statistics Master Records for this Statistics Master Identifier
  --fetched from the Interface Table
  CURSOR cur_get_oss_stat_master(p_stat_type_cd  igs_or_inst_stat_int.stat_type_cd%TYPE,cp_party_id hz_parties.party_id%TYPE) IS
     SELECT *
     FROM   igs_or_inst_stats
     WHERE  stat_type_cd  =p_stat_type_cd
     AND    party_id      =cp_party_id;

  --Cursor to fetch the OSS Statistics Detail Records to check against the recently
  --inserted Detail record.
  CURSOR cur_get_oss_stat_det(p_int_stat_id  igs_or_inst_stat_dtl.inst_stat_id%TYPE,
                             p_year         igs_or_inst_sdtl_int.year%TYPE) IS
     SELECT sdtl.rowid,sdtl.*
     FROM   igs_or_inst_stat_dtl sdtl
     WHERE  sdtl.inst_stat_id         = p_int_stat_id
     AND    TO_CHAR(sdtl.year,'YYYY') = TO_CHAR(p_year,'YYYY');

  oss_stat_master_rec     cur_get_oss_stat_master%ROWTYPE;
  oss_stat_det_rec         cur_get_oss_stat_det%ROWTYPE;

  --cursor to do field level validation before importing data into statistics master
  CURSOR c_val_stat(p_stat_type_cd igs_or_inst_stat_int.stat_type_cd%TYPE,
                    cp_lookup_type igs_lookup_values.lookup_type%TYPE,
                    cp_enabled_flag igs_lookup_values.enabled_flag%TYPE) IS
     SELECT 'X'
     FROM   igs_lookup_values lkv
     WHERE  lkv.lookup_code = p_stat_type_cd
     AND    lkv.lookup_type= cp_lookup_type
     AND    enabled_flag = cp_enabled_flag;

  c_val_stat_rec c_val_stat%ROWTYPE;

  --Procedure to update the Statistics Master Interface Table
  PROCEDURE update_int_stat(p_int_stat_rec     igs_or_inst_stat_int%ROWTYPE)
  AS

  BEGIN

    UPDATE igs_or_inst_stat_int
    SET    status = p_int_stat_rec.status,
           error_code =p_int_stat_rec.error_code
    WHERE  interface_inst_stat_id  =p_int_stat_rec.interface_inst_stat_id;

    --put this information about the failed record in the log file too
    IF p_int_stat_rec.status='3' THEN
       IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_OR_INST_IMP_FAIL');
           FND_MESSAGE.SET_TOKEN('INT_ID', p_int_stat_rec.interface_inst_stat_id);
           FND_MESSAGE.SET_TOKEN('ERROR_CODE', p_int_stat_rec.error_code);
           FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                        'igs.plsql.igs_or_inst_imp_003.update_int_stat.' || p_int_stat_rec.error_code,
                                        FND_MESSAGE.GET,
                                        NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
    END IF;

 END update_int_stat;

 --Procedure to update the Statistics Detail Interface Table
 PROCEDURE update_int_stat_det(p_int_stat_det_rec     cur_get_int_stat_det%ROWTYPE)
 AS


 BEGIN

   UPDATE  igs_or_inst_sdtl_int
   SET     status = p_int_stat_det_rec.status,
           error_code = p_int_stat_det_rec.error_code
   WHERE   interface_inst_stat_dtl_id  = p_int_stat_det_rec.interface_inst_stat_dtl_id;

   --put this information about the failed record in the log file too
   IF p_int_stat_det_rec.status='3' THEN
      IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_OR_INST_IMP_FAIL');
          FND_MESSAGE.SET_TOKEN('INT_ID', p_int_stat_det_rec.interface_inst_stat_dtl_id);
          FND_MESSAGE.SET_TOKEN('ERROR_CODE', p_int_stat_det_rec.error_code);
          FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                       'igs.plsql.igs_or_inst_imp_003.update_int_stat_det.' || p_int_stat_det_rec.error_code,
                                       FND_MESSAGE.GET,
                                       NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
   END IF;

  END update_int_stat_det;

 --Procedure to display the error in when others exception
 PROCEDURE display_error(p_int_stat_master_rec        IN OUT NOCOPY  igs_or_inst_stat_int%ROWTYPE,
             p_int_stat_det_rec       IN OUT NOCOPY  cur_get_int_stat_det%ROWTYPE
             )
 AS

 BEGIN
    IF l_det_dml_operation='INSERT' THEN
       p_int_stat_det_rec.error_code := 'E030';
    ELSIF l_det_dml_operation='UPDATE' THEN
       p_int_stat_det_rec.error_code := 'E031';
    END IF;
    --Rollback changes
    ROLLBACK TO stat_mast;
    p_int_stat_det_rec.status :='3';

    --Update the Interface record status as ERROR
    update_int_stat_det(p_int_stat_det_rec);

    --Even if one Statistics detail record fails need to ROLLBACK and Update the statistics master record as ERROR
    p_int_stat_master_rec.status:='3';

    --Update the Master Interface Record as ERROR
    update_int_stat(p_int_stat_master_rec);

    --Process Next Master Record
    RAISE SKIP_STAT_MAST;
  END display_error;

 BEGIN

       IF p_party_id IS NULL THEN
           RAISE NO_DATA_FOUND;
       END IF;


      --Iterate through the Interface Master Stat records
      FOR int_stat_master_rec IN cur_get_int_stat_master(p_interface_id,'2') LOOP
          BEGIN
             l_mast_insert_success:=FALSE;
             l_mast_dml_operation :=NULL;

             l_det_insert_success:=FALSE;
             l_det_update_success:=FALSE;
             l_det_dml_operation :=NULL;

             --Create a Save Point for every Interface Record Fetched
         SAVEPOINT stat_mast;
         --Fetch the Statistics Master records in OSS for this Statistics Identifier
         OPEN cur_get_oss_stat_master(int_stat_master_rec.stat_type_cd,p_party_id);
         FETCH cur_get_oss_stat_master INTO oss_stat_master_rec;
         --If there are no OSS Stat Master records
         IF cur_get_oss_stat_master%NOTFOUND THEN
            l_mast_dml_operation:='INSERT';
        --Insert the Interface Records into OSS Master Stats
        l_inst_stat_id:=NULL;
        l_row_id      :=NULL;
        OPEN c_val_stat(int_stat_master_rec.stat_type_cd,'OR_INST_STAT_TYPE','Y');
        FETCH c_val_stat INTO c_val_stat_rec;
        IF c_val_stat%FOUND THEN
           igs_or_inst_stats_pkg.insert_row(
                             x_rowid               =>l_row_id,
                             x_inst_stat_id        =>l_inst_stat_id,
                             x_stat_type_cd        =>int_stat_master_rec.stat_type_cd,
                             x_party_id            =>p_party_id,
                             x_mode                =>'R'
                             );
                   l_mast_insert_success:=TRUE;
        ELSE
           int_stat_master_rec.status:='3';
           int_stat_master_rec.error_code:='E027';
           update_int_stat(int_stat_master_rec);
           RAISE SKIP_STAT_MAST;
        END IF;
        CLOSE c_val_stat;
        --For this Master Record Inserted Need to get Detail records if any and Insert into the
        --OSS Table

            --Fetch the Interface Detail Records
        FOR int_stat_det_rec IN cur_get_int_stat_det(int_stat_master_rec.interface_inst_stat_id,'2')  LOOP
            BEGIN
               l_det_insert_success:=FALSE;
               l_det_dml_operation:=NULL;
               --Check if there is already a Duplicate record available in OSS Detail.
               --First Time it will not be but successive Inserts could result in a Duplicate
               OPEN cur_get_oss_stat_det(l_inst_stat_id ,int_stat_det_rec.year);
               FETCH cur_get_oss_stat_det INTO oss_stat_det_rec;
               IF cur_get_oss_stat_det%NOTFOUND THEN
                  l_det_dml_operation:='INSERT';
                  l_dtl_id:=NULL;
                  l_det_row_id:=NULL;

                          --Insert the Detail Record
                          igs_or_inst_stat_dtl_pkg.insert_row(
                              x_rowid              =>  l_det_row_id,
                              x_inst_stat_dtl_id   =>  l_dtl_id,
                              x_inst_stat_id       =>  l_inst_stat_id,
                              x_year               =>  int_stat_det_rec.year  ,
                              x_value              =>  int_stat_det_rec.value,
                              x_mode               =>  'R'  );

                      l_det_insert_success:=TRUE;
               END IF;
               CLOSE cur_get_oss_stat_det;

               --After Successful Insert ,Update the detail rec status as COMPLETE
               --Even if a Duplicate Detail record is found then Update the
               --Status as  COMPLETE
               int_stat_det_rec.error_code:=NULL;
               int_stat_det_rec.status:='1';
               update_int_stat_det(int_stat_det_rec);

             EXCEPTION --Handle Exception for Every Detail Record
               WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
                  CLOSE cur_get_oss_stat_det;

                  IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
                     FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_LOCKED');
                     FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                                  'igs.plsql.igs_or_inst_imp_003.process_institution_statistics.recordlock1',
                                                  FND_MESSAGE.GET || '-' || SQLERRM,
                                                  NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
                  END IF;

                  ROLLBACK TO stat_mast;
                  RAISE SKIP_STAT_MAST;
               WHEN OTHERS THEN
                  CLOSE cur_get_oss_stat_master;
                  CLOSE cur_get_oss_stat_det;
                  display_error(int_stat_master_rec,int_stat_det_rec);
               END;
           END LOOP;   --Process Next Record in Detail Records Loop
        --Else if a Master Duplicate Record is found then
        ELSE
           --Updation of Statistics Master Record is not done.
           --Fetch the Detail Records for this Master Statistics
           FOR  int_stat_det_rec IN cur_get_int_stat_det(int_stat_master_rec.interface_inst_stat_id,'2')  LOOP
              BEGIN
                 l_det_insert_success:=FALSE;
                 l_det_dml_operation:=NULL;
             --Check if there is already a Duplicate record available in OSS Detail for the Interface Stat ID
             --and Year.
             OPEN cur_get_oss_stat_det(oss_stat_master_rec.inst_stat_id ,int_stat_det_rec.year);
             FETCH cur_get_oss_stat_det INTO oss_stat_det_rec;
             IF cur_get_oss_stat_det%NOTFOUND THEN
                l_dtl_id:=NULL;
                l_det_row_id:=NULL;
                l_det_dml_operation:='INSERT';
                --Insert the Detail Record
                igs_or_inst_stat_dtl_pkg.insert_row(
                              x_rowid              =>  l_det_row_id,
                              x_inst_stat_dtl_id   =>  l_dtl_id,
                              x_inst_stat_id       =>  oss_stat_master_rec.inst_stat_id,
                              x_year               =>  int_stat_det_rec.year  ,
                              x_value              =>  int_stat_det_rec.value
                              );
                            l_det_insert_success:=TRUE;
                --Duplicate Detail Record is Found so update with the Interface Record Details
             ELSIF cur_get_oss_stat_det%FOUND THEN
                l_det_dml_operation:='UPDATE';
                --Update the Detail Record
                igs_or_inst_stat_dtl_pkg.update_row(
                              x_rowid              =>  oss_stat_det_rec.rowid,
                              x_inst_stat_dtl_id   =>  oss_stat_det_rec.inst_stat_dtl_id,
                              x_inst_stat_id       =>  oss_stat_det_rec.inst_stat_id,
                              x_year               =>  oss_stat_det_rec.year  ,
                              x_value              =>  int_stat_det_rec.value
                          );

                            l_det_update_success:=TRUE;
             END IF;
             CLOSE cur_get_oss_stat_det;
             --After Successful Insert ,Update the detail rec status as COMPLETE
             --Even if a Duplicate Detail record is found then Update the
             --Status as COMPLETE
             int_stat_det_rec.status:='1';
             int_stat_det_rec.error_code:=NULL;
             update_int_stat_det(int_stat_det_rec);
                      --Handle Exception for every detail record processed
              EXCEPTION
                 WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
                  CLOSE cur_get_oss_stat_det;
                  IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
                     FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_LOCKED');
                     FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                                  'igs.plsql.igs_or_inst_imp_003.process_institution_statistics.recordlock2',
                                                  FND_MESSAGE.GET || '-' || SQLERRM,
                                                  NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
                  END IF;

                --Rollback changes
                ROLLBACK TO stat_mast;
                RAISE SKIP_STAT_MAST;
             WHEN OTHERS THEN
                CLOSE cur_get_oss_stat_master;
                CLOSE cur_get_oss_stat_det;
                display_error(int_stat_master_rec,int_stat_det_rec);
              END;
                   END LOOP;     --End of Detail Records in Interface
           END IF; --For Duplicate Check against Master Record
           CLOSE cur_get_oss_stat_master;

           --For every Master statistics record processed ,Display appropriate message and
           --Update the Status as COMPLETE

                   int_stat_master_rec.status:='1';
                   int_stat_master_rec.error_code:=NULL;
           --Update the Interface Record
           update_int_stat(int_stat_master_rec);

             --For every master record Handle the exception
         EXCEPTION
            WHEN SKIP_STAT_MAST THEN
           IF cur_get_oss_stat_master%ISOPEN THEN
              CLOSE cur_get_oss_stat_master;
           END IF;
           IF c_val_stat%ISOPEN THEN
              CLOSE c_val_stat;
           END IF;

            WHEN OTHERS THEN
           IF cur_get_oss_stat_master%ISOPEN THEN
              CLOSE cur_get_oss_stat_master;
           END IF;
           IF c_val_stat%ISOPEN THEN
              CLOSE c_val_stat;
           END IF;
           --Status is ERROR
           int_stat_master_rec.status:='3';
           int_stat_master_rec.error_code:='E028';
           --Update the Interface Record
           update_int_stat(int_stat_master_rec);
         END;
       END LOOP;  --For the Master Record

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        --log message that the party_id passed is Invalid, Party ID passed must be present in Hz_partie

        IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
          FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                       'igs.plsql.igs_or_inst_imp_003.process_institution_statistics.nodatafound',
                                       'Invalid Party Id: '||p_party_id ||' ,Party ID passed must be present in HZ_parties' || '-' || SQLERRM,
                                       NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
        END IF;

       WHEN OTHERS THEN
         IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME','igs_or_inst_imp_003.process_institution_statistics');
           FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                        'igs.plsql.igs_or_inst_imp_003.process_institution_statistics.others',
                                        FND_MESSAGE.GET || '-' || SQLERRM,
                                        NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
         END IF;

         APP_EXCEPTION.RAISE_EXCEPTION;
   END process_institution_statistics;


 --Procedure to process the Institution Addresses
 PROCEDURE process_institution_address (
  p_interface_id        IN      igs_or_adr_int.interface_id%TYPE,
  p_addr_usage          IN      igs_or_adrusge_int.site_use_code%TYPE,
  p_party_id            IN      hz_parties.party_id%TYPE)
/***************************************************************
   Created By       :   mesriniv
   Date Created By  :   2001/07/12
   Purpose      :   This is the third part of
                                Import Institutions Package
   Known Limitations,Enhancements or Remarks

   Change History   :
   ENH Bug No           :  1872994
   ENH Desc             :  Modelling and Forcasting DLD- Institutions Build
   Who          When        What
   pkpatel      15-MAR-2002     Bug no.2238946 :Added the parameter p_status in the call to igs_pe_party_site_use_pkg
   asbala        12-nov-03       3227107: address changes - signature of igs_pe_person_addr_pkg.insert_row changed
 ***************************************************************/
AS
   l_addr_usage         igs_or_adrusge_int.site_use_code%TYPE;
   l_existing_usage     igs_or_adrusge_int.site_use_code%TYPE;
   l_location_id        hz_locations.location_id%TYPE;
   l_date       DATE;
   l_addr_success   BOOLEAN;
   l_addr_process   BOOLEAN := FALSE;

   l_usage_success  BOOLEAN;
   l_addr_dml           VARCHAR2(10);
   l_usage_dml      VARCHAR2(10);
   l_count              NUMBER;
   l_return_status      VARCHAR2(10);
   l_msg_data           VARCHAR2(1000);
   l_addr_row_id        VARCHAR2(25);
   l_usage_row_id       VARCHAR2(25);
   l_party_site_id      hz_party_sites.party_site_id%TYPE;
   l_party_site_use_id  igs_or_adrusge_int.interface_addrusage_id%TYPE;
   SKIP_ADDR            EXCEPTION;
   l_party_site_ovn hz_party_sites.object_version_number%TYPE;
   l_location_ovn hz_locations.object_version_number%TYPE;
   l_addr_warning	VARCHAR2(1) := 'N';
   --Cursor to fetch the Interface Address Master Records for the Interface Identifier
   CURSOR cur_get_int_addr(cp_interface_id  igs_or_adr_int.interface_id%TYPE,
                           cp_status igs_or_adr_int.status%TYPE) IS
      SELECT *
      FROM   igs_or_adr_int
      WHERE  interface_id  =cp_interface_id
      AND    status        = cp_status  ;

   --Cursor to get the Count of Address Usages from the Interface for an Address ID
   CURSOR cur_get_usage_count(p_int_addr_id  igs_or_adr_int.interface_addr_id%TYPE,
                              cp_status igs_or_adrusge_int.status%TYPE) IS
      SELECT COUNT(interface_addrusage_id)
      FROM   igs_or_adrusge_int
      WHERE  interface_addr_id = p_int_addr_id
      AND    status            = cp_status;

   --Cursor to fetch the Address Usage
   CURSOR cur_get_addr_usage(p_int_addr_id igs_or_adr_int.interface_addr_id%TYPE,
                             cp_status igs_or_adrusge_int.status%TYPE) IS
      SELECT UPPER(site_use_code)
      FROM   igs_or_adrusge_int
      WHERE  interface_addr_id = p_int_addr_id
      AND    status            = cp_status;

   --Cursor to check the Duplicate Address
   CURSOR cur_get_oss_addr(p_int_addr_rec  igs_or_adr_int%ROWTYPE,cp_party_id   hz_parties.party_id%TYPE) IS
      SELECT party_site_id
      FROM   hz_party_sites hp,
             hz_locations addr
      WHERE  hp.location_id            = addr.location_id
      AND    hp.party_id               = cp_party_id
      AND    NVL(addr.address1,' ')    = NVL(p_int_addr_rec.addr_line_1,' ')
      AND    NVL(addr.address2,' ')    = NVL(p_int_addr_rec.addr_line_2,' ')
      AND    NVL(addr.address3,' ')    = NVL(p_int_addr_rec.addr_line_3,' ')
      AND    NVL(addr.address4,' ')    = NVL(p_int_addr_rec.addr_line_4,' ')
      AND    NVL(addr.city,' ')        = NVL(p_int_addr_rec.city,' ')
      AND    NVL(addr.state,' ')       = NVL(p_int_addr_rec.state,' ')
      AND    NVL(addr.province,' ')    = NVL(p_int_addr_rec.province,' ')
      AND    NVL(addr.county,' ')      = NVL(p_int_addr_rec.county,' ')
      AND    NVL(addr.country,' ')     = NVL(p_int_addr_rec.country,' ')
      AND    NVL(addr.postal_code,' ') = NVL(p_int_addr_rec.postcode,' ');

   --Cursor to fetch the existing address usage
   CURSOR cur_get_usage(cp_party_site_id  hz_party_sites.party_site_id%TYPE,
                     cp_addr_usage     igs_or_adrusge_int.site_use_code%TYPE) IS
      SELECT site_use_type
      FROM   hz_party_site_uses
      WHERE  party_site_id  = cp_party_site_id
      AND    site_use_type  = cp_addr_usage;

   --cursor added to validate country field in address interface table
   CURSOR c_adr_val(p_country igs_or_adr_int.country%TYPE) IS
      SELECT 'X'
      FROM fnd_territories
      WHERE territory_code= p_country;

   c_adr_val_rec c_adr_val%ROWTYPE;

   --Procedure to update the Interface Address Status
   PROCEDURE update_address_int(p_interface_id igs_or_adr_int.interface_id%TYPE,
                                p_addr_id      igs_or_adr_int.interface_addr_id%TYPE,
                                p_status       igs_or_adr_int.status%TYPE,
                                p_err_cd       igs_or_adr_int.error_code%TYPE,
                                p_err_txt      igs_or_adr_int.error_text%TYPE,
                                p_which_tab    VARCHAR2)
   AS

    BEGIN
      --Update the status of address record
      IF p_which_tab IN ('adr','both')THEN
         UPDATE igs_or_adr_int
         SET    status           = p_status ,
                error_code = p_err_cd ,
                error_text = p_err_txt
         WHERE  interface_id     = p_interface_id
         AND    interface_addr_id= p_addr_id  ;

         --put this information about the failed record in the log file too
         IF p_status='3' THEN
            IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_OR_INST_IMP_FAIL');
              FND_MESSAGE.SET_TOKEN('INT_ID', p_addr_id);
              FND_MESSAGE.SET_TOKEN('ERROR_CODE', p_err_cd);
              FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                           'igs.plsql.igs_or_inst_imp_003.update_address_int.' || p_err_cd,
                                           FND_MESSAGE.GET,
                                           NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
            END IF;
         END IF;
      END IF;

      --Update the status of address usage record
      IF p_which_tab IN ('adr_usg','both')THEN
         UPDATE igs_or_adrusge_int
         SET    status           = p_status , error_code = p_err_cd , error_text = p_err_txt
         WHERE  interface_addr_id= p_addr_id;

         --put this information about the failed record in the log file too
         IF p_status='3' THEN
            IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_OR_INST_IMP_FAIL');
              FND_MESSAGE.SET_TOKEN('INT_ID', p_addr_id);
              FND_MESSAGE.SET_TOKEN('ERROR_CODE', p_err_cd);
              FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                           'igs.plsql.igs_or_inst_imp_003.update_address_int.' || p_err_cd,
                                           FND_MESSAGE.GET,
                                           NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
            END IF;
         END IF;

      END IF;

 END update_address_int;

 --Procedure to Insert the Address Usage for the address
PROCEDURE insert_addr_usage(p_interface_id igs_or_adr_int.interface_id%TYPE,
                            p_int_addr_id  igs_or_adr_int.interface_addr_id%TYPE)
 AS

   --cursor added to validate if the site use code in interface table is present in fnd_lookups
   CURSOR c_val_addr_usage(p_site_use_code igs_or_adrusge_int.site_use_code%TYPE,
                           cp_lookup_typ fnd_lookup_values.lookup_type%TYPE,
                           cp_enabled_flag fnd_lookup_values.enabled_flag%TYPE) IS
      SELECT 'X'
      FROM fnd_lookup_values
      WHERE lookup_type= cp_lookup_typ
      AND   lookup_code = p_site_use_code
      AND   enabled_flag = cp_enabled_flag
      AND   view_application_id = 222
      AND   security_group_id = 0
      AND   language = userenv('LANG');

   c_val_addr_usage_rec c_val_addr_usage%ROWTYPE;
   l_object_version_number NUMBER;
 BEGIN

     l_return_status:=NULL;
     l_msg_data     :=NULL;
     l_date         :=NULL;
     l_party_site_use_id:=NULL;

     OPEN c_val_addr_usage(l_addr_usage,'PARTY_SITE_USE_CODE','Y');
     FETCH c_val_addr_usage INTO c_val_addr_usage_rec;

     IF c_val_addr_usage%FOUND THEN
        igs_pe_party_site_use_pkg.hz_party_site_uses_ak(
             p_action                      => 'INSERT',
             p_rowid                       => l_usage_row_id,
             p_party_site_use_id           => l_party_site_use_id,
             p_party_site_id               => l_party_site_id,
             p_site_use_type               => l_addr_usage,
             p_status                      => 'A',
             p_return_status               => l_return_status,
             p_msg_data                    => l_msg_data,
             p_last_update_date            => l_date,
             p_site_use_last_update_date   => l_date,
             p_profile_last_update_date    => l_date,
             p_hz_party_site_use_ovn       => l_object_version_number
           );

        IF l_return_status IN ('E','U') THEN
               --Error while associating the Address Usage with the Address

               IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
                 FND_MESSAGE.SET_NAME('IGS','IGS_OR_USG_INSERT');
                 FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                              'igs.plsql.igs_or_inst_imp_003.insert_addr_usage.fail',
                                              FND_MESSAGE.GET || '-' || l_msg_data,
                                              NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
               END IF;

           --Error in Address Record Status
           CLOSE c_val_addr_usage;
           update_address_int(p_interface_id,p_int_addr_id,'3', 'E057',l_msg_data,'both');
           RAISE SKIP_ADDR;
       END IF;
     ELSE
        update_address_int(p_interface_id,p_int_addr_id,'3','E033',NULL,'both');
        CLOSE c_val_addr_usage;
                RAISE SKIP_ADDR;
     END IF;
     CLOSE c_val_addr_usage;
  END insert_addr_usage;

  BEGIN

       IF p_party_id IS NULL THEN
         RAISE NO_DATA_FOUND;
       END IF;

        --Iterate through the Interface Address records
    FOR int_addr_rec IN cur_get_int_addr(p_interface_id,'2') LOOP

            BEGIN
           l_addr_success :=FALSE;
           l_usage_success:=FALSE;
           l_addr_dml:=NULL;
           l_usage_dml:=NULL;
           l_addr_warning := 'N';

           int_addr_rec.country := UPPER(int_addr_rec.country);
           int_addr_rec.correspondence_flag := UPPER(int_addr_rec.correspondence_flag);

              --Create a Save Point for every Interface Record Fetched
          SAVEPOINT address;
          l_count:= 0;   --Since the count of address usages would be different for different addresses

          --Count the No.of Address Usages for this Address
          OPEN cur_get_usage_count(int_addr_rec.interface_addr_id,'2');
          FETCH cur_get_usage_count INTO l_count;
          CLOSE cur_get_usage_count;

              IF l_count = 1 THEN
             --Fetch the Address Usage
                         OPEN cur_get_addr_usage(int_addr_rec.interface_addr_id,'2');
                         FETCH cur_get_addr_usage INTO l_addr_usage;
                                 CLOSE cur_get_addr_usage;

              ELSIF l_count =0 THEN
                --Check if the Parameter is Not NULL
                            IF p_addr_usage IS NULL  THEN
                           --Mark this record as ERROR
                                   --p_address_usage not specified
                           --Update Record as ERROR
                                   update_address_int(p_interface_id,int_addr_rec.interface_addr_id,'3','E034',NULL,'both');
                           RAISE SKIP_ADDR;
                ELSIF p_addr_usage IS NOT NULL THEN
                               l_addr_usage:=p_addr_usage;
                    END IF;

             ELSIF l_count > 1 THEN
                --Only one  address usage should be specified for the an address
        --Error in Address Record Status
                update_address_int(p_interface_id,int_addr_rec.interface_addr_id,'3','E035',NULL,'both');
                        RAISE SKIP_ADDR;
                        END IF;  --End of check for Count

                l_party_site_id := NULL;  --Since the Party Site Id would be different for different addresses

               --Check for Duplicate OSS Address
           OPEN  cur_get_oss_addr(int_addr_rec,p_party_id);
           FETCH cur_get_oss_addr INTO l_party_site_id;
           CLOSE cur_get_oss_addr;

              --There is no such Address
          IF l_party_site_id IS NULL THEN
             --Address has to be created in OSS
         l_addr_dml    := 'INSERT';
         l_addr_row_id := NULL;
         l_location_id := NULL;
         l_return_status := NULL;
         l_msg_data    := NULL;

         OPEN c_adr_val(int_addr_rec.country);
         FETCH c_adr_val into c_adr_val_rec;

         IF c_adr_val%FOUND THEN
            igs_pe_person_addr_pkg.insert_row
                       (
                    p_action                 => 'R',
                    p_rowid                  => l_addr_row_id,
                    p_location_id            => l_location_id,
                    p_start_dt               => int_addr_rec.start_date,
                    p_end_dt                 => int_addr_rec.end_date,
                    p_country                => int_addr_rec.country,
                    p_address_style          => NULL,
                    p_addr_line_1            => int_addr_rec.addr_line_1 ,
                    p_addr_line_2            => int_addr_rec.addr_line_2,
                    p_addr_line_3            => int_addr_rec.addr_line_3 ,
                    p_addr_line_4            => int_addr_rec.addr_line_4  ,
                    p_date_last_verified     => int_addr_rec.date_last_verified,
                    p_correspondence         => int_addr_rec.correspondence_flag ,
                    p_city                   => int_addr_rec.city,
                    p_state                  => int_addr_rec.state,
                    p_province               => int_addr_rec.province,
                    p_county                 => int_addr_rec.county  ,
                    p_postal_code            => int_addr_rec.postcode,
                    p_address_lines_phonetic => NULL,
                    p_delivery_point_code    => int_addr_rec.delivery_point_code,
                    p_other_details_1        => int_addr_rec.other_details_1,
                    p_other_details_2        => int_addr_rec.other_details_2,
                    p_other_details_3        => int_addr_rec.other_details_3,
                    l_return_status          => l_return_status,
                    l_msg_data               => l_msg_data,
                    p_party_id               => p_party_id,
                    p_party_site_id          => l_party_site_id,
                    p_party_type             => 'ORGANIZATION',
                    p_last_update_date       => l_date,
                    p_party_site_ovn         => l_party_site_ovn,
                    p_location_ovn           => l_location_ovn,
                    p_status                 => 'A'
                  );

                    IF l_return_status IN ('E','U') THEN
                       IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
                         FND_MESSAGE.SET_NAME('IGS','IGS_OR_ADDR_NO_INSERT');
                         FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                                      'igs.plsql.igs_or_inst_imp_003.process_institution_address.addrins',
                                                      FND_MESSAGE.GET || '-' || l_msg_data,
                                                      NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
                       END IF;

                       ROLLBACK TO address;
                       --Error in Address Record Status
                       update_address_int(p_interface_id,int_addr_rec.interface_addr_id,'3','E036',l_msg_data,'adr');
                       RAISE SKIP_ADDR;
                    ELSE
                       IF l_return_status = 'W' THEN
			       l_addr_warning := 'Y';
			       IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
				 FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
							      'igs.plsql.igs_or_inst_imp_003.process_institution_address.addrins',
							      'Warning: '|| '-' ||l_msg_data,
							      NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
			       END IF;
			       --Error in Address Record Status
			       update_address_int(p_interface_id,int_addr_rec.interface_addr_id,'4','E022',l_msg_data,'adr');
		       END IF;

		       --Set Insert address as TRUE if inserted
                       l_addr_success:=TRUE;
                       --To indicate that Usage is Inserted
                       l_usage_dml:='INSERT';
                       --Associate the Address Usage with the Inserted Address
                       insert_addr_usage(int_addr_rec.interface_id,int_addr_rec.interface_addr_id);
                       --Set the Insert as SUCCESS
                       l_usage_success:=TRUE;
		       --Set Address of person is processed flag
		       l_addr_process := TRUE;

                    END IF;
              ELSE
                update_address_int(p_interface_id,int_addr_rec.interface_addr_id,'3','E032',NULL,'adr');
                RAISE SKIP_ADDR;

              END IF;
              CLOSE c_adr_val;

                 --There is an Address existing in HZ Locations for this Party ID
         ELSIF   l_party_site_id IS NOT NULL THEN
            --Need to Check if the Address Usage is already associated for this
            --address.Otherwise we need to create an association

            --Fetch the Address Usage for this existing Address
            l_existing_usage:=NULL;
            OPEN cur_get_usage( l_party_site_id,l_addr_usage);
            FETCH cur_get_usage INTO l_existing_usage;
            CLOSE cur_get_usage;

                    --There is no Address Usage for this party_site_id
            IF l_existing_usage IS NULL THEN
               --To indicate that Usage is Inserted
               l_usage_dml:='INSERT';

               --Associate the incoming address usage for the party_site_id
               insert_addr_usage(int_addr_rec.interface_id,int_addr_rec.interface_addr_id);
               l_usage_success:=TRUE;
            END IF;
         END IF;
         --After all the successful processing is over.Update the Interface addr and address usage
         --status to 1
	 IF l_addr_warning = 'N' THEN
             update_address_int(p_interface_id,int_addr_rec.interface_addr_id,'1',NULL,NULL,'both');
         END IF;

            EXCEPTION
           WHEN SKIP_ADDR THEN
              IF  c_adr_val%ISOPEN THEN
              CLOSE c_adr_val;
          END IF;
           WHEN OTHERS THEN
              IF l_addr_dml='INSERT' AND NOT l_addr_success THEN
             --Error has occurred while inserting address
             update_address_int(p_interface_id,int_addr_rec.interface_addr_id,'3','E036',NULL,'adr');
          END IF;

               IF l_usage_dml='INSERT' AND NOT l_usage_success THEN
              --Error has occurred while inserting address usage
          update_address_int(p_interface_id,int_addr_rec.interface_addr_id,'3','E038',NULL,'adr_usg');
           END IF;
           ROLLBACK TO address;
       END;
      END LOOP;

      IF (l_addr_process) THEN
	  --populate IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS table with party id to generate notification at the end of process
	  IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS(NVL(IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS.LAST,0)+1) := p_party_id;
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --log message that the party_id passed is Invalid, Party ID passed must be present in Hz_partie
        IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
            FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                         'igs.plsql.igs_or_inst_imp_003.process_institution_address.nodatafound',
                                         'Invalid Party Id: '||p_party_id ||' ,Party ID passed must be present in HZ_parties - ' || SQLERRM,
                                         NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
        END IF;
     WHEN OTHERS THEN
        IF (igs_or_inst_imp_001.gb_write_exception_log3) THEN
            FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                         'igs.plsql.igs_or_inst_imp_003.process_institution_address.others',
                                         SQLERRM,
                                         NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
   END process_institution_address;

END igs_or_inst_imp_003_pkg;

/
