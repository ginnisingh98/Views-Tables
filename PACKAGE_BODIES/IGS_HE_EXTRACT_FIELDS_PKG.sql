--------------------------------------------------------
--  DDL for Package Body IGS_HE_EXTRACT_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_EXTRACT_FIELDS_PKG" AS
/* $Header: IGSHE9CB.pls 120.14 2006/09/15 01:49:20 jtmathew noship $ */

   PROCEDURE write_to_log (p_message    IN VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedures writes onto the log file
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who                  When            What
   ***************************************************************/
   BEGIN

      Fnd_File.Put_Line(Fnd_File.Log, p_message);

   END write_to_log;


   PROCEDURE get_hesa_inst_id
          (p_hesa_inst_id           OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the HESA Institution Identfier.
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who                  When            What
   ***************************************************************/

   CURSOR c_get_instid IS
   SELECT ihp.oi_govt_institution_cd govt_institution_cd
   FROM   igs_pe_hz_parties  ihp,
          igs_or_inst_stat st
   WHERE  ihp.oi_institution_status = st.institution_status AND
          st.s_institution_status= 'ACTIVE' AND
          ihp.oi_local_institution_ind = 'Y' AND
          ihp.inst_org_ind = 'I' AND
          ihp.oi_govt_institution_cd IS NOT NULL;

   BEGIN
      OPEN  c_get_instid;
      FETCH c_get_instid INTO p_hesa_inst_id;
      CLOSE c_get_instid;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_get_instid%ISOPEN
          THEN
              CLOSE c_get_instid;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_hesa_inst_id');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_hesa_inst_id;


   PROCEDURE get_campus_id
          (p_location_cd           IN igs_en_stdnt_ps_att.location_cd%TYPE,
           p_campus_id             OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the HESA Campus Identifier
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who                  When            What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_LOC_CAMP_ASSOC';
      l_he_code_map_val.map2             := p_location_cd;

      IF p_location_cd IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_campus_id);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_campus_id');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_campus_id;


   PROCEDURE get_alt_pers_id
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_id_type               IN  igs_pe_alt_pers_id.person_id_type%TYPE,
           p_api_id                OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE
           ) IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Alternate Person Id
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who          When         What
     smaddali     11-dec-03    Modified for bug#3235753 , added 2 new parameters
     sjlaport     31-Jan-05    Modified cursor c_api for HE358 to ignore logically deleted records
   ***************************************************************/
   -- smaddali modified this cursor to get records which are effective in the HESA submission period, bug#3235753
   CURSOR c_api IS
   SELECT api_person_id
   FROM   igs_pe_alt_pers_id
   WHERE  pe_person_id   = p_person_id
   AND    person_id_type = p_id_type
   AND    Start_Dt <= p_enrl_end_dt
   AND    ( End_Dt IS NULL OR End_Dt >= p_enrl_start_dt )
   AND    (End_Dt IS NULL OR Start_Dt <> End_Dt)
   ORDER BY Start_Dt DESC;

   BEGIN
      OPEN  c_api;
      FETCH c_api INTO p_api_id;
      CLOSE c_api;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_alt_pers_id');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_alt_pers_id;


   PROCEDURE get_stdnt_id
          (p_person_id             IN  igs_en_stdnt_ps_att.person_id%TYPE,
           p_inst_id               IN  igs_or_institution.govt_institution_cd%TYPE,
           p_stdnt_id              OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE)

   IS
   /***************************************************************
    Created By           :
    Date Created By      :
    Purpose              : This procedure gets the HESA Student Identifier
    Known Limitations,Enhancements or Remarks:
    Change History       :
    Who       When         What
    Bayadav   24-OCT-2002  Modified this porcedure to get the api personid considering
                           the  person id type exisiting as a part of HEFD101(2636897)
    pmarada   30-May-03    Adding check digit for calculated student ID, bug 2986518
    smaddali  11-dec-03    Modified for bug#3235753 , added 2 new parameters
    smaddali  16-jan-04    Modified logic for creating HUSID record , bug#3371259
    ayedubat  12-05-04     Modified the procedure to consider, if HUSID alternate person ID record
                           overlapping the HESA submission period exist and it is closed for Bug, 3438701
    sjlaport  31-Jan-05    Modified cursors c_api, c_husid, c_future_husid and c_current_husid for HE358
                           to ignore logically deleted records
   ***************************************************************/

   CURSOR c_comdt  IS
   SELECT to_char(MIN(commencement_dt),'YY')
   FROM   igs_en_stdnt_ps_att
   WHERE  person_id = p_person_id;

   CURSOR c_sid IS
   SELECT igs_he_stdnt_id_s.nextval
   FROM   dual;

   --TO select all the alternate person id's with type in (UCASID,NMASID,SWASID,GTTRID)
   --Cursor to check number of person id types exisitng .
   -- smaddali modified this cursor to get records which are effective in the HESA submission period, bug#3235753
   CURSOR c_api IS
   SELECT api_person_id
   FROM   igs_pe_alt_pers_id
   WHERE  pe_person_id   = p_person_id
   AND    person_id_type IN ('UCASID','NMASID','SWASID','GTTRID')
   AND    Start_Dt <= p_enrl_end_dt
   AND    ( End_Dt IS NULL OR End_Dt >= p_enrl_start_dt )
   AND    (End_Dt IS NULL OR Start_Dt <> End_Dt);

   -- smaddali added these cursors for bug#3371259
   -- get the latest HUSID record for the person
   CURSOR c_husid IS
   SELECT api_person_id, start_dt, end_dt
   FROM   igs_pe_alt_pers_id
   WHERE  pe_person_id   = p_person_id
   AND    person_id_type = 'HUSID'
   AND    (end_dt IS NULL OR start_dt <> end_dt)
   ORDER BY start_dt DESC;
   c_husid_rec c_husid%ROWTYPE ;

   -- get the min start_dt of HUSID records which are starting after the Submission period end date
   CURSOR c_future_husid IS
   SELECT start_dt
   FROM   igs_pe_alt_pers_id
   WHERE  pe_person_id   = p_person_id
   AND    person_id_type = 'HUSID'
   AND    start_dt > p_enrl_end_dt
   AND    (end_dt IS NULL OR start_Dt <> end_Dt)
   ORDER BY start_dt ASC;
   c_future_husid_rec c_future_husid%ROWTYPE ;

   CURSOR current_husid_cur IS
     SELECT api_person_id, start_dt, end_dt
     FROM   igs_pe_alt_pers_id
     WHERE  pe_person_id   = p_person_id
     AND    person_id_type = 'HUSID'
     AND    start_dt <= p_enrl_end_dt
     AND    (end_dt IS NULL OR end_dt >= p_enrl_start_dt)
     AND    (end_dt IS NULL OR start_dt <> end_dt)
     ORDER BY start_dt DESC;
   current_husid_rec current_husid_cur%ROWTYPE;

   --sjlaport added for HE358 to check for logically deleted HUSID records
   CURSOR c_deleted_husid(cp_person_id igs_pe_alt_pers_id.pe_person_id%TYPE,
                          cp_api_person_id igs_pe_alt_pers_id.api_person_id%TYPE,
                          cp_start_dt igs_pe_alt_pers_id.start_dt%TYPE)  IS
      SELECT 'X'
      FROM   igs_pe_alt_pers_id
      WHERE  pe_person_id   = cp_person_id
      AND    api_person_id   = cp_api_person_id
      AND    start_dt = TRUNC(cp_start_dt)
      AND    person_id_type = 'HUSID'
      AND    start_dt = end_dt;

   c_deleted_husid_rec c_deleted_husid%ROWTYPE ;


   l_derive             BOOLEAN ;
   l_cre_husid          BOOLEAN ;
   l_cre_lat_husid      BOOLEAN ;
   l_start_dt           igs_pe_alt_pers_id.start_dt%TYPE ;
   l_end_dt            igs_pe_alt_pers_id.end_dt%TYPE ;

   l_stdnt_id                 igs_pe_alt_pers_id.api_person_id%TYPE;
   l_year                     VARCHAR2(2);
   l_sid                      VARCHAR2(30);
   l_index                    NUMBER := 0;
   l_chk_sum                  NUMBER := 0;
   l_chk_digit                NUMBER(2);
   l_api_rec                 c_api%ROWTYPE;

   TYPE fldwt IS TABLE OF NUMBER(2)
        INDEX BY binary_integer;
   l_fld_weight               fldwt;

   BEGIN
      l_stdnt_id  := NULL;
      l_derive    := FALSE;
      l_cre_husid := FALSE;
      l_cre_lat_husid := FALSE;

      -- Check if HUS ID already exists
      igs_he_extract_fields_pkg.get_alt_pers_id
          (p_person_id      =>  p_person_id,
           p_id_type        =>  'HUSID',
           p_api_id         =>  l_stdnt_id,
           p_enrl_start_dt  =>  p_enrl_start_dt,
           p_enrl_end_dt    =>  p_enrl_end_dt);

      IF l_stdnt_id IS NULL
      THEN
         -- smaddali added this code to check for past / future husid records before
         -- deriving new husid, bug#3371259
         -- check if there are any HUSIDs defined this person
         c_husid_rec            := NULL ;
         l_cre_husid            := TRUE;

         OPEN c_husid;
         FETCH c_husid INTO c_husid_rec;
         -- If the student has no HUSID's at all then derive the HUSID and create
         -- record with start_dt = Hesa submission start_dt and end_dt =  NULL
         IF c_husid%NOTFOUND THEN
            l_derive            := TRUE;
            l_start_dt          := p_enrl_start_dt;
            l_end_dt            :=  NULL ;
         -- If there exists a Past HUSID then derive a new HUSID because the old one maybe created incorrectly
         -- start_dt = end_dt of old husid+1 and end_dt = NULL
         ELSIF c_husid_rec.end_dt < p_enrl_start_dt THEN
             l_derive           := TRUE ;
             l_start_dt         := c_husid_rec.end_dt + 1;
             l_end_dt           :=  NULL ;
         -- If there exists a future HUSID then
         ELSIF  c_husid_rec.start_dt > p_enrl_end_dt THEN
         -- if the latest future record is open then donot derive a new HUSID but
         -- create a HUSID record with the api value of the latest furure record and
         -- start_dt = hesa submission start_dt and end_dt = start_dt of nearest future husid -1
             c_future_husid_rec := NULL;
             OPEN c_future_husid;
             FETCH c_future_husid INTO c_future_husid_rec ;
             CLOSE c_future_husid;
             IF c_husid_rec.end_dt IS NULL THEN
                 l_stdnt_id         := c_husid_rec.api_person_id ;
                 l_derive           := FALSE ;
                 l_start_dt         := p_enrl_start_dt;
                 l_end_dt           := c_future_husid_rec.start_dt - 1;
             ELSE
                 -- if future husid is closed then  derive a new HUSID  and
                 -- create a HUSID record with start_dt = hesa submission start_dt and
                 -- end_dt = start_dt of nearest future husid -1
                 -- Also create another HUSID record starting from latest furure record end_dt + 1 and end_dt = NULL
                 l_derive           := TRUE ;
                 l_start_dt         := p_enrl_start_dt;
                 l_end_dt           := c_future_husid_rec.start_dt - 1 ;
                 -- this flag indicates that an extra husid record needs to be created
                 l_cre_lat_husid    := TRUE;
             END IF ;
         ELSE
             -- This case will never arise because if the student has got some HUSID records which donot overlap with the submission period ,
             -- then the latest record must either have started after submission end date or must have Ended before the Submission start_dt
             --             |-------Submission period----------|
             -- |--past----|                                    |-----future1--| |-----future2----
             --  Anything other than these 2 cases is overlapping with the submission period in which case nothing needs to be done
             l_stdnt_id         := NULL ;
             l_derive           := FALSE ;
             l_start_dt         := NULL;
             l_end_dt           := NULL;
         END IF ;
         CLOSE c_husid;

      ELSE  -- Student Id exist, but closed with in the Reporting Period. Added for Bug, 3438701

         OPEN current_husid_cur;
         FETCH current_husid_cur INTO current_husid_rec;
         IF current_husid_cur%FOUND AND current_husid_rec.end_dt < p_enrl_end_dt THEN

           -- If future alternate person ID record does not exist (i.e. This is the latest record for all the period)
           OPEN c_future_husid;
           FETCH c_future_husid INTO c_future_husid_rec ;
           IF c_future_husid%NOTFOUND THEN

             l_cre_husid   := TRUE;
             l_derive      := TRUE;
             l_start_dt    := current_husid_rec.end_dt+1;
             l_end_dt      := NULL;

           -- Future Record exists after the HESA submission period
           -- Log the Message at the Execption Level
           ELSIF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

             fnd_message.set_name('IGS','IGS_HE_INVAL_HUSID_RECS_WARN');
             fnd_message.set_token('PERSON_NO',p_person_id );
             fnd_log.string(FND_LOG.LEVEL_EXCEPTION,'igs.plsql.igs_he_extract_fields_pkg.get_stdnt_id', fnd_message.get);

           END IF;
           CLOSE c_future_husid;

         END IF;
         CLOSE current_husid_cur;

      END IF; -- End of Student Id exist check

         IF l_derive THEN
                  OPEN c_api ;
                  FETCH c_api INTO l_stdnt_id ;
        --1
                     IF c_api%FOUND THEN
                             FETCH c_api INTO l_stdnt_id ;
        --2
                             IF c_api%ROWCOUNT >1 THEN
                                CLOSE c_api;
                                l_stdnt_id := NULL;
                 --IN case of more than one person id type
                  -- Check if UCAS ID already exists
                                  igs_he_extract_fields_pkg.get_alt_pers_id
                                  (p_person_id      =>  p_person_id,
                                   p_id_type        =>  'UCASID',
                                   p_api_id         =>  l_stdnt_id,
                                   p_enrl_start_dt  =>  p_enrl_start_dt,
                                   p_enrl_end_dt    =>  p_enrl_end_dt);

        --3
                                    -- Check if NMASID already exists
                                   IF l_stdnt_id IS NULL THEN
                                      igs_he_extract_fields_pkg.get_alt_pers_id
                                        (p_person_id      =>  p_person_id,
                                         p_id_type        =>  'NMASID',
                                         p_api_id         =>  l_stdnt_id,
                                         p_enrl_start_dt  =>  p_enrl_start_dt,
                                         p_enrl_end_dt    =>  p_enrl_end_dt);
        --4
                                    -- Check if GTTRID already exists
                                      IF l_stdnt_id IS NULL THEN
                                          igs_he_extract_fields_pkg.get_alt_pers_id
                                            (p_person_id      =>  p_person_id,
                                             p_id_type        =>  'GTTRID',
                                             p_api_id         =>  l_stdnt_id,
                                             p_enrl_start_dt  =>  p_enrl_start_dt,
                                             p_enrl_end_dt    =>  p_enrl_end_dt);
        --5
                                    -- Check if SWASID already exists
                                             IF l_stdnt_id IS NULL THEN
                                                  igs_he_extract_fields_pkg.get_alt_pers_id
                                                  (p_person_id      =>  p_person_id,
                                                   p_id_type        =>  'SWASID',
                                                   p_api_id         =>  l_stdnt_id,
                                                   p_enrl_start_dt  =>  p_enrl_start_dt,
                                                   p_enrl_end_dt    =>  p_enrl_end_dt);
        --5
                                               END IF;
        --4
                                        END IF;
        --3
                                      END IF;
        --2
                                  END IF;

                         ELSE
                               CLOSE c_api ;
        --1
                         END IF;
                         IF c_api%ISOPEN THEN
                           CLOSE c_api;
                         END IF;

                  -- If  it is still null, then compute it.
                  IF l_stdnt_id IS NOT NULL
                  THEN
                      l_stdnt_id := '0000' || LPAD(l_stdnt_id,8,'0');
                  ELSE
                       -- Get the year of commencement
                       OPEN  c_comdt;
                       FETCH c_comdt INTO l_year;
                       CLOSE c_comdt;

                       -- Get the unique student id
                       OPEN  c_sid;
                       FETCH c_sid INTO l_sid;
                       CLOSE c_sid;

                       l_stdnt_id := l_year ||
                                     Substr(to_char(p_inst_id + 1000),1,4)||
                                     LPAD(l_sid,6,'0');

                  END IF;
                       -- Calculate the check digit and add to student ID
                       -- Initialize Weights.
                       l_fld_weight(1)  := 1;
                       l_fld_weight(2)  := 3;
                       l_fld_weight(3)  := 7;
                       l_fld_weight(4)  := 9;
                       l_fld_weight(5)  := 1;
                       l_fld_weight(6)  := 3;
                       l_fld_weight(7)  := 7;
                       l_fld_weight(8)  := 9;
                       l_fld_weight(9)  := 1;
                       l_fld_weight(10) := 3;
                       l_fld_weight(11) := 7;
                       l_fld_weight(12) := 9;

                       -- Calculate Check Digit
                       FOR l_index IN 1 .. LENGTH(l_stdnt_id)
                       LOOP
                           l_chk_sum := l_chk_sum +
                                        (to_number(Substr(l_stdnt_id,l_index, 1)) *
                                        l_fld_weight(l_index));

                       END LOOP;

                       -- Check digit is 10  last digit of the check sum above
                       l_chk_digit := 10 - to_number(Substr(to_char(l_chk_sum),-1,1));

                       -- If l_chk_digit is 10, then set it to 0
                       IF l_chk_digit = 10
                       THEN
                           l_chk_digit := 0;
                       END IF;
                        --Add check digit to the Student ID
                       l_stdnt_id := l_stdnt_id || to_char(l_chk_digit);
          END IF; -- derive new husid or not

          -- If a value found, insert the HESA Id record
          -- smaddali modified this insert statement to create a record which
          -- starts and ends same as the HESA submission period so that there is no date overlapping failure
          IF l_stdnt_id IS NOT NULL AND l_cre_husid  THEN

              -- check for logically deleted records before inserting
              OPEN c_deleted_husid(p_person_id,l_stdnt_id,l_start_dt);
              FETCH c_deleted_husid INTO c_deleted_husid_rec;

              IF c_deleted_husid%FOUND THEN

                  CLOSE c_deleted_husid;

                  -- update existing record
                  UPDATE igs_pe_alt_pers_id
                  SET    end_dt = l_end_dt,
                         last_updated_by = Fnd_Global.user_id,
                         last_update_date = Sysdate,
                         last_update_login = Fnd_Global.login_id
                  WHERE  pe_person_id = p_person_id
                  AND    api_person_id = l_stdnt_id
                  AND    person_id_type = 'HUSID'
                  AND    start_dt = l_start_dt;

                  fnd_message.set_name('IGS','IGS_HE_DEL_REC_OPENED');
                  fnd_Message.Set_Token('PER_ID',p_person_id);
                  fnd_Message.Set_Token('ALT_PID',l_stdnt_id);
                  fnd_Message.Set_Token('PID_TYPE','HUSID');
                  fnd_Message.Set_Token('START_DT',TRUNC(l_start_dt));
                  fnd_file.put_line(fnd_file.log,fnd_message.get());

              ELSE

                  CLOSE c_deleted_husid;

                  INSERT INTO igs_pe_alt_pers_id
                     (pe_person_id,
                      api_person_id,
                      person_id_type,
                      start_dt,
                      end_dt,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login)
                  VALUES
                     (p_person_id,
                      l_stdnt_id,
                      'HUSID',
                      l_start_dt ,
                      l_end_dt ,
                      Fnd_Global.user_id,
                      Sysdate,
                      Fnd_Global.user_id,
                      Sysdate,
                      Fnd_Global.login_id);

              END IF;

              IF  l_cre_lat_husid   THEN

                  -- check for logically deleted records before inserting
                  OPEN c_deleted_husid(p_person_id,l_stdnt_id,c_husid_rec.end_dt + 1);
                  FETCH c_deleted_husid INTO c_deleted_husid_rec;

                  IF c_deleted_husid%FOUND THEN

                      CLOSE c_deleted_husid;

                      -- update existing record
                      UPDATE igs_pe_alt_pers_id
                      SET    end_dt = NULL,
                             last_updated_by = Fnd_Global.user_id,
                             last_update_date = Sysdate,
                             last_update_login = Fnd_Global.login_id
                      WHERE  pe_person_id = p_person_id
                      AND    api_person_id = l_stdnt_id
                      AND    person_id_type = 'HUSID'
                      AND    start_dt = c_husid_rec.end_dt + 1;

                      fnd_message.set_name('IGS','IGS_HE_DEL_REC_OPENED');
                      fnd_Message.Set_Token('PER_ID',p_person_id);
                      fnd_Message.Set_Token('ALT_PID',l_stdnt_id);
                      fnd_Message.Set_Token('PID_TYPE','HUSID');
                      fnd_Message.Set_Token('START_DT',TRUNC(c_husid_rec.end_dt + 1));
                      fnd_file.put_line(fnd_file.log,fnd_message.get());

                  ELSE

                      CLOSE c_deleted_husid;

                      INSERT INTO igs_pe_alt_pers_id
                             (pe_person_id,
                              api_person_id,
                              person_id_type,
                              start_dt,
                              end_dt,
                              created_by,
                              creation_date,
                              last_updated_by,
                              last_update_date,
                              last_update_login)
                          VALUES
                             (p_person_id,
                              l_stdnt_id,
                              'HUSID',
                              c_husid_rec.end_dt + 1 ,
                              NULL ,
                              Fnd_Global.user_id,
                              Sysdate,
                              Fnd_Global.user_id,
                              Sysdate,
                              Fnd_Global.login_id);

                  END IF;

              END IF ;
          END IF;

      p_stdnt_id := l_stdnt_id;

    EXCEPTION
    WHEN OTHERS
    THEN
          write_to_log(SQLERRM);
          IF c_comdt%ISOPEN
          THEN
              CLOSE c_comdt;
          END IF;
          IF c_api%ISOPEN
          THEN
              CLOSE c_api;
          END IF;
          IF c_deleted_husid%ISOPEN
          THEN
              CLOSE c_deleted_husid;
          END IF;
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_stdnt_id');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_stdnt_id;


   PROCEDURE get_fe_stdnt_mrker
          (p_spa_fe_stdnt_mrker    IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_fe_program_marker     IN  igs_he_st_prog.fe_program_marker%TYPE,
           p_funding_src           IN  igs_he_ex_rn_dat_fd.value%TYPE,
           p_fundability_cd        IN  igs_he_ex_rn_dat_fd.value%TYPE,
           p_oss_fe_stdnt_mrker    OUT NOCOPY VARCHAR2,
           p_hesa_fe_stdnt_mrker   OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the FE Student Marker
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE;
   l_oss_fe_stdnt_mrker            igs_he_code_map_val.map1%TYPE;

   BEGIN

      IF p_spa_fe_stdnt_mrker IS NULL
      THEN
          IF p_fe_program_marker IS NOT NULL AND p_funding_src IS NOT NULL AND
             p_fundability_cd IS NOT NULL
          THEN
          l_he_code_map_val.association_code := 'OSS_FESTUMK_ASSOC';
          l_he_code_map_val.map2             := p_fe_program_marker;
          l_he_code_map_val.map3             := p_funding_src;
          l_he_code_map_val.map4             := p_fundability_cd;
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_oss_fe_stdnt_mrker);
          END IF;
      ELSE
          l_oss_fe_stdnt_mrker :=  p_spa_fe_stdnt_mrker;
      END IF; -- Value for FE stdnt Marker exists

      -- Now get the HESA Equivalent value
      IF l_oss_fe_stdnt_mrker IS NOT NULL
      THEN
          l_he_code_map_val := NULL;
          l_he_code_map_val.association_code := 'OSS_HESA_FESTUMK_ASSOC';
          l_he_code_map_val.map2             := l_oss_fe_stdnt_mrker ;
          p_oss_fe_stdnt_mrker               := l_oss_fe_stdnt_mrker ;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_fe_stdnt_mrker);
      END IF; -- If OSS Value exists, get the HESA Value


      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_fe_stdnt_mrker');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_fe_stdnt_mrker;


   PROCEDURE get_funding_src
          (p_course_cd             IN  igs_ps_ver.course_cd%TYPE,
           p_version_number        IN  igs_ps_ver.version_number%TYPE,
           p_spa_fund_src          IN  igs_en_stdnt_ps_att.funding_source%TYPE,
           p_poous_fund_src        IN  igs_he_poous.funding_source%TYPE,
           p_oss_fund_src          OUT NOCOPY VARCHAR2,
           p_hesa_fund_src         OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Major Source of Funding
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali  25-Aug-03    Modified procedure to add new parameter p_poous_fund_src
                            and its logic for hefd208 bug #2717751
     jtmathew  01-Feb-05    Modified procedure to add new parameter p_spa_fund_src
                            and its logic for bug #3962575
     jtmathew  24-Mar-05    Modified procedure to check HESA code mapping first before
                            calling c_gov_fsrc for bug #4218148
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE;
   l_oss_fund_src                  igs_he_code_map_val.map1%TYPE;
   l_hesa_fund_src                 igs_he_ex_rn_dat_fd.value%TYPE;
   l_govt_fund_src                 igs_he_ex_rn_dat_fd.value%TYPE;

   CURSOR c_fsrc IS
   SELECT b.govt_funding_source,
          a.funding_source
   FROM   igs_fi_fnd_src_rstn a,
          igs_fi_fund_src     b
   WHERE  a.course_cd      = p_course_cd
   AND    a.version_number = p_version_number
   AND    a.dflt_ind       = 'Y'
   AND    a.funding_source = b.funding_source;

   -- smaddali added cursor for hefd208 build, bug#2717751
   -- to get the govt funding_source for the funding_source set up at Poous level
   CURSOR c_gov_fsrc(cp_fund_src igs_fi_fund_src.funding_source%TYPE)  IS
   SELECT govt_funding_source,
          funding_source
   FROM   igs_fi_fund_src
   WHERE  funding_source = cp_fund_src ;

   BEGIN

       IF p_spa_fund_src IS NOT NULL THEN
           l_oss_fund_src := p_spa_fund_src;

       ELSIF p_poous_fund_src IS NOT NULL THEN
           l_oss_fund_src := p_poous_fund_src;
       ELSE
           -- Retrieve funding_source at program funding source restriction
           OPEN  c_fsrc;
           FETCH c_fsrc INTO l_govt_fund_src, l_oss_fund_src;
           CLOSE c_fsrc;
       END IF;

       IF l_oss_fund_src IS NOT NULL THEN
           -- Get the HESA Equivalent value
           l_he_code_map_val := NULL;
           l_he_code_map_val.association_code := 'OSS_HESA_MSFUND_ASSOC';
           l_he_code_map_val.map2             := l_oss_fund_src;

           igs_he_extract2_pkg.get_map_values
                              (p_he_code_map_val   => l_he_code_map_val,
                               p_value_from        => 'MAP1',
                               p_return_value      => l_hesa_fund_src);

           IF l_hesa_fund_src IS NULL THEN

               IF l_govt_fund_src IS NULL THEN

                  -- If no HESA value get funding source from igs_fi_fund_src
                  OPEN  c_gov_fsrc(l_oss_fund_src) ;
                  FETCH c_gov_fsrc INTO l_hesa_fund_src,
                                        p_oss_fund_src;
                  CLOSE c_gov_fsrc;

               ELSE
                   l_hesa_fund_src := l_govt_fund_src;
               END IF;

           END IF;

           p_oss_fund_src := l_oss_fund_src;
           p_hesa_fund_src := LPAD(l_hesa_fund_src,2,'0');

       END IF;


   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_fsrc%ISOPEN
          THEN
              CLOSE c_fsrc;
          END IF;

          IF c_gov_fsrc%ISOPEN
          THEN
              CLOSE c_gov_fsrc;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_funding_src');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_funding_src;


   PROCEDURE get_fundability_cd
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_susa_fund_cd          IN  igs_he_en_susa.fundability_code%TYPE,
           p_spa_funding_source    IN  igs_en_stdnt_ps_att.funding_source%TYPE,
           p_poous_fund_cd         IN  igs_he_poous.fundability_cd%TYPE,
           p_prg_fund_cd           IN  igs_he_st_prog.fundability%TYPE,
           p_prg_funding_source    IN  igs_fi_fnd_src_rstn.funding_source%TYPE,
           p_oss_fund_cd           OUT NOCOPY VARCHAR2,
           p_hesa_fund_cd          OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Fundability Code
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali 11-Dec-03   Modified for bug#3235753 , added 2 new parameters
     anwest   09-Dec-04   Modified for HE356 - updated to accommodate
                          Term/Load calendar associated with residency
     jtmathew 23-May-06   Modified c_res_sts for bug 5210481
   ***************************************************************/

   -- smaddali modified this cursor for bug 2730388 to get only open code values
   -- smaddali modified this cursor for bug 2367167 to get records which are effective in the HESA submission period, bug#3235753
   -- anwest   modified this cursor for HE356 to get open and closed values and not restricted to OSS_RESIDENCY_OS
   -- jtmathew modified this cursor for bug 5210481 to remove igs_pe_res_dtls_v view
      CURSOR c_res_sts (cp_res_class_cd   VARCHAR2) IS
      SELECT peresdtls.residency_status_cd residency_status
        FROM igs_pe_res_dtls_all peresdtls,
             igs_lookup_values cc1,
             igs_lookup_values cc2,
             igs_ca_inst_all cainstall
       WHERE peresdtls.person_id = p_person_id
         AND peresdtls.residency_class_cd = cc1.lookup_code
         AND cc1.lookup_type = 'PE_RES_CLASS'
         AND peresdtls.residency_status_cd = cc2.lookup_code
         AND cc2.lookup_type = 'PE_RES_STATUS'
         AND peresdtls.residency_class_cd = cp_res_class_cd
         AND peresdtls.cal_type = cainstall.cal_type
         AND peresdtls.sequence_number = cainstall.sequence_number
         AND cainstall.start_dt <= p_enrl_end_dt
    ORDER BY cainstall.start_dt DESC;


   -- anwest 09-Dec-2004 HE356 - created this new cursor
   CURSOR cur_res_val (cp_res_stat_cd VARCHAR2) IS
        SELECT  'X'
        FROM    igs_he_code_values hecodeval
        WHERE   hecodeval.code_type = 'OSS_RESIDENCY_OS'
        AND     hecodeval.value = cp_res_stat_cd
        AND     NVL(hecodeval.closed_ind,'N')   = 'N' ;

   l_residency_status           igs_pe_res_dtls_v.residency_status%TYPE;
   l_oss_fund_cd                VARCHAR2(30);
   l_he_code_map_val            igs_he_code_map_val%ROWTYPE := NULL;
   l_res_class_cd               igs_pe_res_dtls_v.residency_class%TYPE;
   l_dummy                      VARCHAR2(1);

   BEGIN

      Fnd_Profile.Get('IGS_FI_RES_CLASS_ID', l_res_class_cd);

      -- anwest 09-Dec-2004 HE356 - check for residency statuses
      --                            and then determine if code
      --                            type of first record is
      --                            OSS_RESIDENCY_OS
      OPEN  c_res_sts(l_res_class_cd);
      FETCH c_res_sts INTO l_residency_status;
      IF c_res_sts%NOTFOUND THEN
        CLOSE c_res_sts;
      ELSE
        CLOSE c_res_sts;
        OPEN cur_res_val(l_residency_status);
        FETCH cur_res_val INTO l_dummy;
        IF cur_res_val%NOTFOUND THEN
                l_residency_status:= NULL;
        END IF;
        CLOSE cur_res_val;
      END IF;

      IF l_residency_status IS NOT NULL
      THEN
          -- bug 2366478 smaddali modified the code to set the value of field 65 as 2
          -- instead of setting the oss funding code as 2 and then finding out NOCOPY the corresponding hesa value
          p_hesa_fund_cd := '2';
      ELSE
          -- Use SUSA Fund Code
          l_oss_fund_cd := p_susa_fund_cd;

          IF l_oss_fund_cd IS NULL AND p_spa_funding_source IS NOT NULL
          THEN
              -- Get Fundability Code from Funding Source
              l_he_code_map_val                  := NULL;
              l_he_code_map_val.association_code := 'OSS_MSFUND_FUNDCODE_ASSOC';
              l_he_code_map_val.map2             := p_spa_funding_source;

              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_oss_fund_cd);
          END IF;

          IF l_oss_fund_cd IS NULL
          THEN
              -- Use POOUS fund Cd
              l_oss_fund_cd := p_poous_fund_cd;
          END IF;

          IF l_oss_fund_cd IS NULL
          THEN
              -- Use Program fund Cd
              l_oss_fund_cd := p_prg_fund_cd;
         END IF;

          IF l_oss_fund_cd IS NULL AND p_prg_funding_source IS NOT NULL
          THEN
              -- Use Program Funding Source to derive Fund Code
              l_he_code_map_val := NULL;
              l_he_code_map_val.association_code := 'OSS_MSFUND_FUNDCODE_ASSOC';
              l_he_code_map_val.map2             := p_prg_funding_source;

              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_oss_fund_cd);
          END IF;

          IF l_oss_fund_cd IS NOT NULL
          THEN
              p_oss_fund_cd := l_oss_fund_cd;

              l_he_code_map_val := NULL;
               l_he_code_map_val.association_code := 'OSS_HESA_FUNDCODE_ASSOC';
              l_he_code_map_val.map2             := l_oss_fund_cd;

              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_fund_cd);
          END IF; -- If OSS Value exists, get the HESA Value

      END IF; -- residency status is null

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_res_sts%ISOPEN
          THEN
              CLOSE c_res_sts;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_fundability_cd');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_fundability_cd;


   PROCEDURE get_fmly_name_on_16_bday
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_fmly_name             OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE )
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Family Name on 16th Birthday
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
   ***************************************************************/
   -- smaddali modified this cursor to get records which are effective in the HESA submission period, bug#3235753
   CURSOR c_fmly_nm IS
   SELECT surname
   FROM   igs_pe_person_alias_v
   WHERE  person_id = p_person_id
   AND    alias_type = 'SNAME16'
   AND    ( Start_Dt IS NULL OR Start_Dt <= p_enrl_end_dt )
   AND    ( End_Dt IS NULL OR End_Dt >= p_enrl_start_dt )
   ORDER BY Start_Dt DESC;

   BEGIN

      OPEN c_fmly_nm;
      FETCH c_fmly_nm INTO p_fmly_name;
      CLOSE c_fmly_nm;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_fmly_nm%ISOPEN
          THEN
              CLOSE c_fmly_nm;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_fmly_name_on_16_bday');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_fmly_name_on_16_bday;


   PROCEDURE get_gender
          (p_gender           IN  igs_pe_person.sex%TYPE,
           p_hesa_gender      OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Gender
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'UC_OSS_HE_GEN_ASSOC';
      l_he_code_map_val.map2             := p_gender;

      IF p_gender IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP3',
                                p_return_value      => p_hesa_gender);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_gender');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_gender;


   PROCEDURE get_domicile
          (p_ad_domicile           IN  igs_he_ad_dtl.domicile_cd%TYPE,
           p_spa_domicile          IN  igs_he_st_spa.domicile_cd%TYPE,
           p_hesa_domicile         OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Domicile for the Student
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

     l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'UC_OSS_HE_DOM_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_spa_domicile, p_ad_domicile) ;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP3',
                                p_return_value      => p_hesa_domicile);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_domicile');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_domicile;


   PROCEDURE get_nationality
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_nationality           OUT NOCOPY VARCHAR2,
           p_enrl_start_dt           IN  igs_he_submsn_header.enrolment_start_date%TYPE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Nationality
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali 11-dec-03   Modified for bug#3235753 , added 1 new parameter
   ***************************************************************/

  -- smaddali modified this cursor to get replace system date with HESA submission end date, bug#3235753
   CURSOR c_ntnl (p_hesa_code     VARCHAR2) IS
   SELECT b.map3
   FROM   igs_pe_citizenship_v a,
          igs_he_code_map_val b
   WHERE  a.party_id = p_person_id
   AND    Nvl(End_Date, p_enrl_start_dt) >= p_enrl_start_dt
   AND    b.map2     = a.country_code
   AND    b.map3     = Nvl(p_hesa_code, b.map3)
   AND    b.association_code = 'UC_OSS_HE_NAT_ASSOC'
   ORDER BY b.map3 DESC;

   l_nationality        VARCHAR2(30);
   l_hesa_cd            VARCHAR2(30);

   BEGIN

      l_hesa_cd := '2826';

      -- Check if there exists a country code as '2826' - 'UK'
      OPEN   c_ntnl (l_hesa_cd);
      FETCH  c_ntnl INTO l_nationality ;
      CLOSE  c_ntnl;

      IF l_nationality IS NULL
      THEN
          l_hesa_cd := NULL;
          OPEN   c_ntnl (l_hesa_cd);
          FETCH  c_ntnl INTO l_nationality ;
          CLOSE  c_ntnl;
      END IF;

      p_nationality := l_nationality;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_ntnl%ISOPEN
          THEN
              CLOSE c_ntnl;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_nationality');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_nationality;


  PROCEDURE get_ethnicity (
    p_person_id             IN  igs_pe_person.person_id%TYPE,
    p_oss_eth               IN  igs_pe_stat_v.ethnic_origin_id%TYPE,
    p_hesa_eth              OUT NOCOPY VARCHAR2)  IS
  /***************************************************************
   Created By           :
   Date Created By      :
   Purpose              : This procedure gets the Ethnicity
   Known Limitations,Enhancements or Remarks:
   Change History       :
   WHO       WHEN         WHAT
   AYEDUBAT  17-MAR-04    Modified the procedure to remove the parameter, p_domicile
                          and remove its reference as part of HEFD311 - July 2004
                          Changes enhancement bug, 2956444
  ***************************************************************/

  l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;

  BEGIN

    IF p_oss_eth IS NOT NULL THEN

      l_he_code_map_val.association_code := 'UC_OSS_HE_ETH_ASSOC';
      l_he_code_map_val.map2             := p_oss_eth;

      igs_he_extract2_pkg.get_map_values
                           (p_he_code_map_val   => l_he_code_map_val,
                            p_value_from        => 'MAP3',
                            p_return_value      => p_hesa_eth);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      write_to_log (SQLERRM);
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_ethnicity');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END get_ethnicity;


   PROCEDURE get_disablity_allow
          (p_oss_dis_allow         IN  igs_he_en_susa.disability_allow%TYPE,
           p_hesa_dis_allow        OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Disability Allowance
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   BEGIN

      l_he_code_map_val.association_code := 'OSS_HESA_DIS_ALLOW_ASSOC';
      l_he_code_map_val.map2             := p_oss_dis_allow;

      IF p_oss_dis_allow IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_dis_allow);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_disability_allow');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_disablity_allow;


   PROCEDURE get_disablity
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_disability            OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Disability
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
     jbaber   20-sep-04   Changes for HEFD350 - Stat changes for 2004/05
                          Use new mapping OSS_HESA_DISABILITY_ASSOC
     jbaber   18-oct-05   Ignore disabilities which map to HESA value NONE when
                          determining if student has multiple disabilities - bug 4584532
   ***************************************************************/

   -- smaddali modified this cursor to get records which are effective in the HESA submission period, bug#3235753
   CURSOR c_dis IS
   SELECT disability_type
   FROM   igs_pe_pers_disablty_v
   WHERE  person_id = p_person_id
   AND    ( Start_Date IS NULL OR Start_Date <= p_enrl_end_dt )
   AND    ( End_Date IS NULL OR End_Date >= p_enrl_start_dt )
   ORDER BY Start_Date DESC;

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_disability             igs_pe_pers_disablty_v.disability_type%TYPE;
   l_hesa_disability        igs_he_ex_rn_dat_fd.value%TYPE;

   BEGIN
      -- jbaber modified association code, HEFD350
      l_he_code_map_val.association_code := 'OSS_HESA_DISABILITY_ASSOC';
      p_disability := NULL;


      OPEN  c_dis;
      LOOP
          FETCH c_dis INTO l_disability;
          EXIT WHEN c_dis%NOTFOUND;

          l_he_code_map_val.map2 := l_disability;

          IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                             (p_he_code_map_val   => l_he_code_map_val,
                              p_value_from        => 'MAP1',
                              p_return_value      => l_hesa_disability);
          END IF;


          IF (p_disability IS NULL OR p_disability = '00') AND l_hesa_disability IS NOT NULL THEN
              -- Student has one disability or one which matches to NONE
              p_disability := l_hesa_disability;

          ELSIF l_hesa_disability <> '00' THEN
              -- Student has multiple disabilities which do not map to NONE
              p_disability := '08';
              EXIT;
          END IF;


      END LOOP;
      CLOSE c_dis;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_dis%ISOPEN
          THEN
              CLOSE c_dis;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_disability');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_disablity;


   PROCEDURE get_addnl_supp_band
          (p_oss_supp_band         IN  igs_he_en_susa.additional_sup_band%TYPE,
           p_hesa_supp_band        OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Additional Support Band
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   BEGIN

      l_he_code_map_val.association_code := 'OSS_HESA_SUP_BAND_ASSOC';
      l_he_code_map_val.map2             := p_oss_supp_band;

      IF p_oss_supp_band IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_supp_band);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_addnl_supp_band');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_addnl_supp_band;


   PROCEDURE get_yr_left_last_inst
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_com_dt                IN  DATE,
           p_hesa_gen_qaim         IN  VARCHAR2,
           p_ucasnum               IN  igs_pe_alt_pers_id.api_person_id%TYPE,
           p_year                  OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Year left last Institute
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     rbezawad  17-Sep-03    Modified the process to derive the  "Year left last institution" field from Academic History
                             rather than from Attendence Hisotry w.r.t. UCFD210 Build, Bug 289354.
   ***************************************************************/

   CURSOR c_yr IS
   SELECT MAX(TO_NUMBER(TO_CHAR(end_date,'YYYY')))
   FROM   igs_ad_acad_history_v
   WHERE  person_id = p_person_id
   AND    end_date < p_com_dt;

   l_end_date NUMBER(4);

   BEGIN

      l_end_date := NULL;
      OPEN  c_yr;
      FETCH c_yr INTO l_end_date;
      CLOSE c_yr;

      IF l_end_date IS NOT NULL THEN
        p_year := TO_CHAR(l_end_date);
      ELSE
        IF (SUBSTR(p_ucasnum,3,6) BETWEEN 1 AND 599999) AND ((p_hesa_gen_qaim BETWEEN 18 AND 52) OR (p_hesa_gen_qaim = 61 OR p_hesa_gen_qaim = 97)) THEN
          p_year := '9999';
        END IF;
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_yr%ISOPEN
          THEN
              CLOSE c_yr;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_yr_left_last_inst');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_yr_left_last_inst;


   PROCEDURE get_new_ent_to_he
          (p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_susa_new_ent_to_he    IN  igs_he_en_susa.new_he_entrant_cd%TYPE,
           p_yop                   IN  VARCHAR2,
           p_high_qual_on_ent      IN  igs_he_st_spa.highest_qual_on_entry%TYPE,
           p_domicile              IN  igs_he_st_spa.domicile_cd%TYPE,
           p_hesa_new_ent_to_he    OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the New Entrant to HE Code
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   BEGIN

--      IF p_fe_stdnt_mrker IS NOT NULL
      -- Amended for Bug 2353094
      IF p_fe_stdnt_mrker <> '2'
      THEN
          p_hesa_new_ent_to_he := NULL;
      ELSE
          IF p_susa_new_ent_to_he IS NOT NULL
          THEN
              -- smaddali corrected usage of map1 and map2 for bug 2728744
              l_he_code_map_val.association_code := 'OSS_HESA_HEENT_ASSOC';
              l_he_code_map_val.map1             :=  p_susa_new_ent_to_he;

              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP2',
                                p_return_value      => p_hesa_new_ent_to_he);

          ELSE
              -- SUSA New Ent to HE is null
              IF to_number(p_yop) > 1
              THEN
                  p_hesa_new_ent_to_he := '9';
              ELSE
                  -- smaddali modified 14 to 11 in the list for bug2353094
                  IF p_high_qual_on_ent IN ('01','03','04','10','11','15',
                                            '21','22','25','26','27','29')
                  OR (p_high_qual_on_ent IN ('02','05','16','23','24','28','30')
                  AND p_domicile IN ('3826','4826','5826', '6826', '7826','8826'))
                  THEN
                      p_hesa_new_ent_to_he := '4';
                  ELSE
                      p_hesa_new_ent_to_he := '1';
                  END IF;

              END IF; -- YOP > 1

          END IF; -- SUSA New Ent to HE is null
      END IF; -- FE Stdnt Marker is not null

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_new_ent_to_he');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_new_ent_to_he;


   PROCEDURE get_year_of_prog
          (p_unit_set_cd           IN  igs_he_en_susa.unit_set_cd%TYPE,
           p_year_of_prog          OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Year of Program
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   CURSOR c_yop IS
   SELECT sequence_no
   FROM   igs_ps_us_prenr_cfg
   WHERE  unit_set_cd = p_unit_set_cd;

   BEGIN

      OPEN  c_yop;
      FETCH c_yop INTO p_year_of_prog;
      CLOSE c_yop;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_yop%ISOPEN
          THEN
              CLOSE c_yop;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_year_of_prog');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_year_of_prog;


   PROCEDURE get_special_student
          (p_ad_special_student       IN  igs_he_ad_dtl.special_student_cd%TYPE,
           p_spa_special_student      IN  igs_he_st_spa.special_student%TYPE,
           p_oss_special_student      OUT NOCOPY VARCHAR2,
           p_hesa_special_student     OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Special Student Code for the Student
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_SPEC_STUD_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_spa_special_student, p_ad_special_student) ;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          p_oss_special_student      := l_he_code_map_val.map2;
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_special_student);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_special_student');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_special_student;


    PROCEDURE get_year_of_student
          (p_person_id              IN  igs_he_en_susa.person_id%TYPE,
           p_course_cd              IN  igs_he_en_susa.course_cd%TYPE,
           p_unit_set_cd            IN  igs_he_en_susa.unit_set_cd%TYPE,
           p_sequence_number        IN  igs_he_en_susa.sequence_number%TYPE,
           p_year_of_student        OUT NOCOPY VARCHAR2,
           p_enrl_end_dt            IN  DATE,
           p_susa_year_of_student   IN  igs_he_en_susa.year_stu%TYPE)
    IS
    /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure  gets the Year of the student
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who        When      What
     smaddali  24-Mar-03  Modified  for Build HEFD209 - Bug#2717755 , modified cursor c_yos to derive the acad_perds for
                          all the program attempts belonging to the current student instance number , so as to facilitate
                          manual transfers.
     smaddali             Added c_acad_cal and c_selection_dt cursors and modified cursor c_yos for HEFD209 build , bug#2717755
     smaddali  29-Oct-03  Modified procedure get_year_of_student to add 1 new parameter for bug#3224246
     jbaber    20-Sep-04  Changes for HEFD350 - Stat changes for 2004/05
                          Added new parameter p_yop_year_of_student. Use YoP year of student value if it exists.
     jbaber    04-Nov-04  Modified c_yos to discount future dated transfers as per HE354 - Program Transfer
     jbaber    15-Apr-05  Modified c_yos to include records where future_dated_trans_flag = N or S as per bug #4179106
     jchakrab  03-Feb-06  Modified c_yos to exclude academic calendar instances if its start date > the HESA reporting period end date.
   ***************************************************************/

   -- Get the academic calendar type and student instance number of the current program attempt.
   CURSOR c_acad_cal IS
   SELECT a.cal_type,b.student_inst_number
   FROM igs_en_stdnt_ps_att_all a , igs_he_st_spa_all b
   WHERE a.person_id = p_person_id AND
         a.course_cd = p_course_cd AND
         a.person_id = b.person_id AND
         a.course_cd = b.course_cd ;
   c_acad_cal_rec c_acad_cal%ROWTYPE;

   -- Get number of distinct academic calendar instances spanned by all the Unit attempts
   -- belonging to all the Program attempts of the student which have the
   -- same student instance number and calendar type as the current program .
   -- Here we are not counting program attempts in different calendar type because we are assuming
   -- that when the student is transfering into a program in a different calendar type then he will
   -- mandatorily transfer all his unit and unit set attempts , Thus they will be counted in the
   -- latest calendar.
   -- smaddali  29-oct-03  modified to add condition enrolled_dt <= p_enr_end_dt for bug#3224246
   CURSOR c_yos (p_student_inst_number igs_he_st_spa_all.student_inst_number%TYPE,
                 p_cal_type igs_en_stdnt_ps_att_all.cal_type%TYPE ) IS
   SELECT COUNT (DISTINCT cir.sup_ci_sequence_number || cir.sup_cal_type)
   FROM igs_he_st_spa_all spa ,
        igs_en_stdnt_ps_att sca,
        igs_en_su_attempt sua,
        igs_ca_inst_rel cir,
        igs_ca_inst_all ca
   WHERE  SPA.person_id                 = p_person_id and
       SPA.student_inst_number          = p_student_inst_number AND
       SCA.person_id                    = SPA.person_id AND
       SCA.course_cd                    = SPA.course_cd AND
       SCA.Cal_type                     = p_cal_type AND
       NVL(sca.future_dated_trans_flag,'N') IN ('N','S') AND
       SUA.person_id                    = SCA.person_id AND
       SUA.course_cd                    = SCA.course_cd AND
       SUA.unit_attempt_status          IN ('ENROLLED', 'COMPLETED', 'DISCONTIN') AND
       CIR.sub_cal_type                 = SUA.cal_type AND
       CIR.sub_ci_sequence_number       = SUA.ci_sequence_number AND
       CIR.sup_cal_type                 = SCA.cal_type  AND
       SUA.ci_start_dt                  <= p_enrl_end_dt AND
       CIR.sup_cal_type                 = CA.cal_type AND
       CIR.sup_ci_sequence_number       = CA.sequence_number AND
       CA.start_dt                      <= p_enrl_end_dt;

   BEGIN

      -- jbaber HEFD350 - Stat changes 2004/05
      -- Use Student YoP year of student if value exists.
      IF p_susa_year_of_student IS NOT NULL THEN
          p_year_of_student := p_susa_year_of_student;
      ELSE
          -- smaddali added the cursor code c_acad_cal for bug 2717755 , HEFD209 build
          -- Get the academic calendar type of the passed program attempt
          OPEN  c_acad_cal;
          FETCH c_acad_cal INTO c_acad_cal_rec;
          CLOSE c_acad_cal;

          OPEN  c_yos(c_acad_cal_rec.student_inst_number,c_acad_cal_rec.cal_type);
          FETCH c_yos INTO p_year_of_student;
          CLOSE c_yos;
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_yos%ISOPEN
          THEN
              CLOSE c_yos;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_year_of_student');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_year_of_student;


   PROCEDURE get_study_location
          (p_susa_study_location     IN  igs_he_en_susa.study_location%TYPE,
           p_poous_study_location    IN  igs_he_poous.location_of_study%TYPE,
           p_prg_study_location      IN  igs_he_st_prog.location_of_study%TYPE,
           p_oss_study_location      OUT NOCOPY VARCHAR2,
           p_hesa_study_location     OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Study Location for the Student
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_LOCSDY_ASSOC';
      l_he_code_map_val.map2             := Nvl(Nvl(p_susa_study_location,
                                                    p_poous_study_location),
                                                p_prg_study_location) ;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          p_oss_study_location := l_he_code_map_val.map2;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_study_location);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_study_location');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_study_location;



   PROCEDURE get_term_time_acc
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_susa_term_time_acc    IN  igs_he_en_susa.term_time_accom%TYPE,
           p_study_location        IN  VARCHAR2,
           p_hesa_term_time_acc    OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Term Time Accomodation
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali               Modified for bug# 2950834  , to add active = 'A' check in cursor c_addrus
     gmaheswa  14-Nov-03    Bug 3227107 , address changes. Modified c_address cursor to select active records.
     smaddali  11-dec-03    Modified for bug#3235753 , added 2 new parameters
     jtmathew  23-may-06    Modified c_addrus for bug 5210481
   ***************************************************************/

   -- smaddali modified this cursor for bug 2730388 to get only open code values
   -- smaddali modified this cursor for bug#2950834 to get only active partysiteuses
   -- smaddali modified this cursor to get records which are effective in the HESA submission period, bug#3235753
   -- jtmathew modified this cursor for bug 5210481 to remove igs_pe_addr_v view
   CURSOR c_addrus IS
   SELECT MAX( site_use_type)
     FROM igs_pe_partysiteuse_v a,
          hz_party_sites        b,
          igs_pe_hz_pty_sites   c,
          igs_he_code_values    d
    WHERE a.party_site_id  = b.party_site_id
      AND b.party_site_id = c.party_site_id(+)
      AND (b.status = 'A'
            AND ( c.Start_Date IS NULL OR c.Start_Date <= p_enrl_end_dt )
            AND ( c.End_Date IS NULL OR c.End_Date >= p_enrl_start_dt )
           )
      AND b.party_id = p_person_id
      AND d.code_type = 'TERM_TIME_ADDR'
      AND d.value     = a.site_use_type
      AND NVL(d.closed_ind,'N') = 'N'
      AND a.active  = 'A'
   ORDER BY c.Start_Date DESC;


   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_oss_term_time_acc      igs_he_en_susa.term_time_accom%TYPE;
   l_address_usage          igs_he_code_map_val.map1%TYPE;

   BEGIN

      IF p_susa_term_time_acc IS NOT NULL
      THEN
          l_oss_term_time_acc :=  p_susa_term_time_acc;
      ELSE
          -- Use Location of Study to get TTA
          l_he_code_map_val.association_code := 'OSS_TTA_LOCSDY_ASSOC';
          l_he_code_map_val.map2             := p_study_location;

          IF l_he_code_map_val.map2 IS NOT NULL
          THEN
              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_oss_term_time_acc);

          END IF;
      END IF;

      IF l_oss_term_time_acc IS NULL
      THEN
          -- Get the TTA from the Address Usage
          OPEN  c_addrus;
          FETCH c_addrus INTO l_address_usage;
          CLOSE c_addrus;

          IF l_address_usage IS NOT NULL
          THEN
              l_he_code_map_val                  := NULL;
              l_he_code_map_val.association_code := 'OSS_ADDRUS_TTA_ASSOC';
              l_he_code_map_val.map2             := l_address_usage;

              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_oss_term_time_acc);
          END IF;
      END IF;

      -- Now get the HESA equivalent value
      IF l_oss_term_time_acc IS NOT NULL
      THEN
          l_he_code_map_val                  := NULL;
          l_he_code_map_val.association_code := 'OSS_HESA_TTA_ASSOC';
          l_he_code_map_val.map2             := l_oss_term_time_acc;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_term_time_acc);
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_addrus%ISOPEN
          THEN
              CLOSE c_addrus;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_term_time_acc');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_term_time_acc;


   /***************************************************************
     Created By           : jtmathew
     Date Created By      : 28-Dec-2005
     Purpose              : This procedure retrieves the award conferral dates for a particular
                            submission. It will return the program level dates if defined, else
                            the program type level dates if defined, otherwise the HESA submission
                            reporting period dates.
                            it will use
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/
   PROCEDURE get_awd_conferral_dates
           (p_awd_table             IN  awd_table,
            p_submission_name       IN  igs_he_ext_run_dtls.submission_name%TYPE,
            p_search_prog           IN  BOOLEAN,
            p_search_prog_type      IN  BOOLEAN,
            p_course_cd             IN  igs_ps_ver_all.course_cd%TYPE,
            p_course_type           IN  igs_ps_ver_all.course_type%TYPE,
            p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
            p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
            p_awd_conf_start_dt     OUT NOCOPY igs_he_submsn_awd.award_start_date%TYPE,
            p_awd_conf_end_dt       OUT NOCOPY igs_he_submsn_awd.award_end_date%TYPE)
   IS
   BEGIN

        IF p_search_prog = FALSE and p_search_prog_type = FALSE THEN
            -- If award conferral dates are not defined at the program type level
            -- Use HESA Submission reporting period start and end dates
            -- Note: This condition will happen in most customer environments.
                p_awd_conf_start_dt := p_enrl_start_dt;
                p_awd_conf_end_dt   := p_enrl_end_dt;
                RETURN;
        END IF;

        IF p_search_prog = TRUE AND p_course_cd IS NOT NULL
        THEN
            -- get award conferral dates at the program level
            FOR i IN 1..p_awd_table.COUNT LOOP
                IF p_awd_table(i).type = 'PROGRAM' AND p_awd_table(i).key1 = p_course_cd
                THEN
                    p_awd_conf_start_dt := p_awd_table(i).award_start_date;
                    p_awd_conf_end_dt := p_awd_table(i).award_end_date;
                    EXIT;
                END IF;
            END LOOP;

        END IF;

        IF p_awd_conf_start_dt IS NULL
        THEN -- If award conferral dates are not defined at the program level

            IF p_search_prog_type = TRUE AND p_course_type IS NOT NULL
            THEN
                -- Get award conferral dates at the program type level
                FOR i IN 1..p_awd_table.COUNT LOOP
                    IF p_awd_table(i).type = 'PROGRAM_TYPE' AND p_awd_table(i).key1 = p_course_type
                    THEN
                        p_awd_conf_start_dt := p_awd_table(i).award_start_date;
                        p_awd_conf_end_dt := p_awd_table(i).award_end_date;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;

            IF p_awd_conf_start_dt IS NULL
            THEN
                -- Use HESA reporting period dates
                p_awd_conf_start_dt := p_enrl_start_dt;
                p_awd_conf_end_dt   := p_enrl_end_dt;
            END IF;

        END IF;

     EXCEPTION
     WHEN OTHERS
     THEN
         write_to_log (SQLERRM);
         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_awd_conferral_dates');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
   END get_awd_conferral_dates;

    PROCEDURE get_min_max_awd_dates
               (p_submission_name       IN  igs_he_submsn_header.submission_name%TYPE,
                p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
                p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
                p_min_start_dt          OUT NOCOPY igs_he_submsn_awd.award_start_date%TYPE,
                p_max_start_dt          OUT NOCOPY igs_he_submsn_awd.award_end_date%TYPE)
    IS
   /***************************************************************
     Created By           : jtmathew
     Date Created By      : 28-Dec-2005
     Purpose              : This procedure retrieves the broadest range of dates out of the
                            program type award conferral, program award conferral and HESA submission
                            reporting period dates.
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

      CURSOR c_get_min_awd_conf_dt (cp_type igs_he_submsn_awd.type%TYPE) IS
      SELECT min(award_start_date)
      FROM igs_he_submsn_awd
      WHERE submission_name = p_submission_name;

      CURSOR c_get_max_awd_conf_dt (cp_type igs_he_submsn_awd.type%TYPE) IS
      SELECT max(award_end_date)
      FROM igs_he_submsn_awd
      WHERE submission_name = p_submission_name;

      l_min_dt DATE;
      l_max_dt DATE;

    BEGIN

       OPEN c_get_min_awd_conf_dt(p_submission_name);
       FETCH c_get_min_awd_conf_dt INTO l_min_dt;
       CLOSE c_get_min_awd_conf_dt;

       OPEN c_get_max_awd_conf_dt(p_submission_name);
       FETCH c_get_max_awd_conf_dt INTO l_max_dt;
       CLOSE c_get_max_awd_conf_dt;

       p_min_start_dt := LEAST(p_enrl_start_dt, NVL(l_min_dt, p_enrl_start_dt));
       p_max_start_dt := GREATEST(p_enrl_end_dt, NVL(l_max_dt, p_enrl_end_dt));

       EXCEPTION
       WHEN OTHERS
       THEN
           write_to_log(SQLERRM);

           IF c_get_min_awd_conf_dt%ISOPEN
           THEN
               CLOSE c_get_min_awd_conf_dt;
           END IF;

           IF c_get_max_awd_conf_dt%ISOPEN
           THEN
               CLOSE c_get_max_awd_conf_dt;
           END IF;

           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_min_max_awd_dates');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;

    END get_min_max_awd_dates;


   PROCEDURE get_awd_dtls (p_submission_name  IN igs_he_submsn_awd.submission_name%TYPE,
                           p_awd_table        OUT NOCOPY awd_table,
                           p_search_prog      OUT NOCOPY BOOLEAN,
                           p_search_prog_type OUT NOCOPY BOOLEAN)
   IS
   /***************************************************************
     Created By           : jtmathew
     Date Created By      : 28-Dec-2005
     Purpose              : This procedure checks whether award details are
                            defined at the Program and Program Type levels
                            and stores the results in a temporary structure.
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/
      CURSOR c_get_awdcount (cp_type igs_he_submsn_awd.type%TYPE) IS
      SELECT 'X'
      FROM igs_he_submsn_awd
      WHERE submission_name = p_submission_name
      AND type = cp_type;

      CURSOR c_get_awd_dtls IS
      SELECT type, key1, award_start_date, award_end_date
      FROM igs_he_submsn_awd
      WHERE submission_name = p_submission_name
      ORDER BY type;

      l_dummy VARCHAR2(1);
      l_count NUMBER;

   BEGIN

      -- Check if there are any program award conferral date records for the submission
      OPEN c_get_awdcount('PROGRAM');
      FETCH c_get_awdcount INTO l_dummy;

      -- If there are any records, then mark p_search_prog as TRUE
      IF c_get_awdcount%FOUND THEN
        p_search_prog := TRUE;
      END IF;

      CLOSE c_get_awdcount;

      -- Check if there are any program type award conferral date records for the submission
      OPEN c_get_awdcount('PROGRAM_TYPE');
      FETCH c_get_awdcount INTO l_dummy;

      -- If there are any records, then mark p_search_prog_type as TRUE
      IF c_get_awdcount%FOUND THEN
        p_search_prog_type := TRUE;
      END IF;

      CLOSE c_get_awdcount;

      IF p_search_prog OR p_search_prog_type
      THEN

        l_count := 1;

        FOR awd_rec IN c_get_awd_dtls LOOP
           p_awd_table(l_count).type := awd_rec.type;
           p_awd_table(l_count).key1 := awd_rec.key1;
           p_awd_table(l_count).award_start_date := awd_rec.award_start_date;
           p_awd_table(l_count).award_end_date := awd_rec.award_end_date;
           l_count := l_count + 1;
        END LOOP;

      END IF;


      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          IF c_get_awdcount%ISOPEN
          THEN
              CLOSE c_get_awdcount;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_awd_dtls');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_awd_dtls;


   PROCEDURE get_rsn_inst_left
           (p_person_id              IN  igs_he_en_susa.person_id%TYPE,
            p_course_cd              IN  igs_he_en_susa.course_cd%TYPE,
            p_crs_req_comp_ind       IN  igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
            p_crs_req_comp_dt        IN  igs_en_stdnt_ps_att.course_rqrmnts_complete_dt%TYPE,
            p_disc_reason_cd         IN  igs_en_stdnt_ps_att.discontinuation_reason_cd%TYPE,
            p_disc_dt                IN  igs_en_stdnt_ps_att.discontinued_dt%TYPE,
            p_enrl_start_dt          IN  igs_he_submsn_header.enrolment_start_date%TYPE,
            p_enrl_end_dt            IN  igs_he_submsn_header.enrolment_end_date%TYPE,
            p_rsn_inst_left          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :
   Date Created By      :
   Purpose              :This procedure  gets the reason why the student left the institution
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who      When        What
   Bayadav  16-Dec-02   Included two new paramters and validation to check the value of conferral date at graduation level
                        and progression level  as a part of bug 2702100
   smaddali 03-Dec-03   Removed cursor c_gr_approval_status and its code for HECR210 program completion validation Build, bug#2874542
   jtmathew 07-Sep-06   Ensured that this field only gets derived when student
                        completes/discontinues during current reporting period.
 ***************************************************************/

     --To check if award  has been made      in progression
     -- smaddali added conndition a.complete_ind     = 'Y', for HECR210 build bug#2874542
     CURSOR c_pr_approval_status
     IS
     SELECT  COUNT(a.person_id)
     FROM    IGS_EN_SPA_AWD_AIM a
     WHERE   a.person_id = p_person_id
     AND     a.course_cd  = p_course_cd
     AND     a.conferral_date BETWEEN p_enrl_start_dt and p_enrl_end_dt
     AND     a.complete_ind     = 'Y';




   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;
   l_graduand_count                NUMBER := 0;

   BEGIN

      -- smaddali removed code checking if conferal date exists at graduand level,
      -- for HECR210 program completion validation build bug#2874542
      IF p_crs_req_comp_ind = 'Y' AND p_crs_req_comp_dt <= p_enrl_end_dt THEN
          --Check if the conferral_date exists at the progression level
               OPEN  c_pr_approval_status ;
               FETCH c_pr_approval_status INTO l_graduand_count;
               CLOSE c_pr_approval_status;
              --If exists then success
              IF l_graduand_count >= 1 THEN
              --Set 01 as Successful completion of course.
                   p_rsn_inst_left := '01';
              ELSE
               --Set 98 as completion of course but result unknowm as the conferral date is not set at any level
                  p_rsn_inst_left := '98';
              END IF;
     ELSIF p_disc_reason_cd IS NOT NULL AND p_disc_dt <= p_enrl_end_dt THEN

          l_he_code_map_val.association_code := 'OSS_HESA_RSNLEAVE_ASSOC';
          l_he_code_map_val.map2             :=  p_disc_reason_cd;

              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_rsn_inst_left);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_rsn_inst_left');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_rsn_inst_left;



   PROCEDURE get_completion_status
           (p_person_id             IN  igs_pe_person.person_id%TYPE,
            p_course_cd             IN  igs_he_st_spa.course_cd%TYPE ,
            p_susa_comp_status      IN  igs_he_en_susa.completion_status%TYPE,
            p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
            p_crs_req_comp_ind      IN  igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
            p_discont_date          IN igs_en_stdnt_ps_att.discontinued_dt%TYPE,
            p_hesa_comp_status      OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the completion status
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

      -- smaddali modified this cursor to check transfer table instead of stdnt_ps_att table for bug 2396174
     CURSOR c_chk_trn IS
     SELECT course_cd
     FROM   igs_ps_stdnt_trn
     WHERE  person_id       = p_person_id
     AND    transfer_course_cd = p_course_cd
     ORDER BY transfer_dt DESC ;

     -- smaddali added this cursor to get the student instance number of an spa record for bug 2396174
     CURSOR c_sin ( cp_course_cd igs_he_st_spa.course_cd%TYPE ) IS
     SELECT student_inst_number
     FROM igs_he_st_spa
     WHERE person_id = p_person_id
     AND course_cd = cp_course_cd ;

     l_he_code_map_val               igs_he_code_map_val%ROWTYPE  := NULL;
     l_to_course_cd                  igs_he_st_spa.course_cd%TYPE := NULL ;
     l_from_sin                      igs_he_st_spa.student_inst_number%TYPE := NULL ;
     l_to_sin                        igs_he_st_spa.student_inst_number%TYPE := NULL ;

   BEGIN
      IF p_fe_stdnt_mrker  IN ('1','3','4')
      THEN

          IF p_susa_comp_status IS NOT NULL
          THEN

              l_he_code_map_val.association_code := 'OSS_HESA_CSTAT_ASSOC';
              l_he_code_map_val.map2             :=  p_susa_comp_status ;

              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_comp_status);

          ELSE
              IF p_discont_date IS NULL
              AND p_crs_req_comp_ind = 'N'
              THEN
                  p_hesa_comp_status := '1';

              ELSIF p_crs_req_comp_ind = 'Y'
              THEN
                  p_hesa_comp_status := '2';

              ELSIF  p_discont_date IS NOT NULL
              THEN
                  --smaddali added this code for bug 2396174
                  -- Check if Student has transfered to any other course
                  OPEN  c_chk_trn;
                  FETCH c_chk_trn INTO l_to_course_cd ;
                  IF c_chk_trn%FOUND
                  THEN
                      -- Get the Student instance number of the current program attempt
                      OPEN c_sin(p_course_cd) ;
                      FETCH c_sin INTO l_from_sin ;
                      CLOSE c_sin ;
                      -- Get the student instance number of the New program attempt transfered into
                      OPEN c_sin( l_to_course_cd) ;
                      FETCH c_sin INTO l_to_sin ;
                      CLOSE c_sin ;

                      -- If student has transfered into a new qualification aim then completion status=4 else 3
                      IF l_from_sin <> l_to_sin THEN
                           p_hesa_comp_status := '4';
                      END IF;
                  --end bug 2396174
                  -- if student has simply discontinued from current program attempt then completion status = 3
                  ELSE
                      p_hesa_comp_status := '3';
                  END IF;
                  CLOSE c_chk_trn;

              END IF;

          END IF; -- SUSA Completion Status provided.
      END IF; -- FE Student Marker

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_chk_trn%ISOPEN
          THEN
              CLOSE c_chk_trn;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_completion_status');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_completion_status;



   PROCEDURE get_good_stand_mrkr
           (p_susa_good_st_mk       IN  igs_he_en_susa.good_stand_marker%TYPE,
            p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
            p_crs_req_comp_ind      IN  igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
            p_discont_date          IN igs_en_stdnt_ps_att.discontinued_dt%TYPE,
            p_hesa_good_st_mk       OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Good Standing Marker
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      IF p_fe_stdnt_mrker  IN ('1','3','4')
      THEN
          IF p_discont_date IS NULL
          AND p_crs_req_comp_ind = 'N'
          THEN
              p_hesa_good_st_mk := '9';

          ELSIF p_susa_good_st_mk IS NOT NULL
          THEN

              l_he_code_map_val.association_code := 'OSS_HESA_PROGRESS_ASSOC';
              l_he_code_map_val.map2             :=  p_susa_good_st_mk ;

              igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_good_st_mk);

          END IF;
      END IF; -- FE Student Marker

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_good_stand_mrkr');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_good_stand_mrkr;


   PROCEDURE get_qual_obtained
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
           p_oss_qual_obt1         OUT NOCOPY VARCHAR2,
           p_oss_qual_obt2         OUT NOCOPY VARCHAR2,
           p_hesa_qual_obt1        OUT NOCOPY VARCHAR2,
           p_hesa_qual_obt2        OUT NOCOPY VARCHAR2,
           p_classification        OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
   Created By           :
   Date Created By      :
   Purpose              :This procedure gets the value of Qualification Obtained Fields
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When               What
   Bayadav  16-DEC-02  Included two new paramters and validation to check the value of conferral date at graduation level and progression level  as a part of bug 2702117
   smaddali  5-dec-03  removed cursor c_gr_awd and its code for HECR210 program completion validation build, bug#2874542
 ***************************************************************/

   -- Get the award and grade details from the Program attempt awards
   CURSOR c_pr_awd IS
   SELECT a.award_cd,
          a.award_grade ,
          c.map1,
          a.grading_schema_cd
   FROM   igs_en_spa_awd_aim a  ,
          igs_he_code_map_val c
   WHERE  a.person_id           = p_person_id
   AND    a.course_cd           = p_course_cd
   AND    a.conferral_date BETWEEN p_enrl_start_dt and p_enrl_end_dt
   AND    a.complete_ind        ='Y'
   AND    a.award_cd            = c.map2
   AND    c.association_code    = 'OSS_HESA_AWD_ASSOC'
   ORDER BY c.map1 ASC;


   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_awd1                   igs_en_spa_awd_aim.award_cd%TYPE;
   l_awd2                   igs_en_spa_awd_aim.award_cd%TYPE;
   l_grade1                 igs_en_spa_awd_aim.award_grade%TYPE;
   l_grade2                 igs_en_spa_awd_aim.award_grade%TYPE;
   l_grading_schema1        igs_en_spa_awd_aim.grading_schema_cd%TYPE;
   l_grading_schema2        igs_en_spa_awd_aim.grading_schema_cd%TYPE;
   l_classification1        igs_he_code_map_val.map1%TYPE;
   l_classification2        igs_he_code_map_val.map1%TYPE;

   BEGIN
      -- smaddali removed code checking for graduand awards,
      -- for HECR210 program completion validation build, bug#2874542

        -- get the conferral date from progression level
         OPEN  c_pr_awd;
         -- Fetch first set of qualifications
         FETCH c_pr_awd INTO l_awd1,
                             l_grade1,
                             p_hesa_qual_obt1,
                             l_grading_schema1 ;

         IF c_pr_awd%FOUND THEN
               -- Fetch second set of qualifications
               FETCH c_pr_awd INTO l_awd2,
                              l_grade2,
                              p_hesa_qual_obt2 ,
                              l_grading_schema2 ;
         END IF;
         CLOSE c_pr_awd;

      -- smaddali modified the code for deriving HESA classification , for HECR210 build bug#2874542
      -- replaced OSS_HESA_HONORS_ASSOC with OSS_HESA_CLASS_ASSOC
      -- Get the HESA Classification code using the Qualification1 obtained using the Associtaion code OSS_HESA_CLASS_ASSOC

      IF l_grading_schema1      IS NOT NULL
      AND l_grade1              IS NOT NULL
      THEN
          -- get the classification using the Awards and honours level.
          l_he_code_map_val                  := NULL ;
          l_he_code_map_val.association_code := 'OSS_HESA_CLASS_ASSOC';
          l_he_code_map_val.map2             :=  l_grading_schema1 ;
          l_he_code_map_val.map3             :=  l_grade1 ;
          igs_he_extract2_pkg.get_map_values
                           (p_he_code_map_val   => l_he_code_map_val,
                            p_value_from        => 'MAP1',
                            p_return_value      => l_classification1);
      END IF;

      -- Get the HESA Classification code using the Qualification2 obtained using the Associtaion code OSS_HESA_CLASS_ASSOC
      IF l_grading_schema2      IS NOT NULL
      AND l_grade2              IS NOT NULL
      THEN
          -- get the classification using the Awards and honours level.
          l_he_code_map_val                  := NULL ;
          l_he_code_map_val.association_code := 'OSS_HESA_CLASS_ASSOC';
          l_he_code_map_val.map2             :=  l_grading_schema2 ;
          l_he_code_map_val.map3             :=  l_grade2 ;
          igs_he_extract2_pkg.get_map_values
                           (p_he_code_map_val   => l_he_code_map_val,
                            p_value_from        => 'MAP1',
                            p_return_value      => l_classification2);
      END IF;

      -- return oss award codes and classification
      p_oss_qual_obt1                    :=  l_awd1;
      p_oss_qual_obt2                    :=  l_awd2;
      -- Return the Least classification among classification 1 and 2 as the HESA value
      IF l_classification1 IS NULL OR l_classification2 IS NULL THEN
            p_classification                   :=  NVL(l_classification1,l_classification2) ;
      ELSE
            p_classification                   :=  LEAST(l_classification1,l_classification2) ;
      END IF ;



      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_pr_awd%ISOPEN
          THEN
              CLOSE c_pr_awd;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_qual_obtained ');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_qual_obtained ;


   PROCEDURE get_fe_qual_aim
            (p_spa_fe_qual_aim      IN  igs_he_st_spa.student_fe_qual_aim%TYPE,
             p_fe_stdnt_mrker       IN  igs_he_st_spa.fe_student_marker%TYPE,
             p_course_cd            IN  igs_he_st_spa.course_cd%TYPE,
             p_version_number       IN  igs_he_st_spa.version_number%TYPE,
             p_hesa_fe_qual_aim     OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets FE Qualification Aim
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smvk     03-Jun-2003   Bug # 2858436. Modified the cursor c_get_feq to select open program awards only.
     smaddali 29-jan-04     Bug#3360646  modified cursor c_get_feq to remove condition default_ind=Y
   ***************************************************************/

   CURSOR c_get_feq IS
   SELECT map1
   FROM   igs_ps_award , igs_he_code_map_val
   WHERE  course_cd      = p_course_cd
   AND    version_number = p_version_number
   AND    closed_ind     = 'N'
   AND    map2 = award_cd
   AND    association_code = 'OSS_HESA_FEQAIM_ASSOC'
   ORDER BY default_ind DESC , map1 ASC;

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

      IF p_fe_stdnt_mrker IN ('1','3','4')
      THEN
          IF p_spa_fe_qual_aim IS NULL
          THEN
              OPEN  c_get_feq;
              FETCH c_get_feq INTO p_hesa_fe_qual_aim;
              CLOSE c_get_feq;
          ELSE
              l_he_code_map_val.association_code := 'OSS_HESA_FEQAIM_ASSOC';
              l_he_code_map_val.map2             :=  p_spa_fe_qual_aim ;

              igs_he_extract2_pkg.get_map_values
                           (p_he_code_map_val   => l_he_code_map_val,
                            p_value_from        => 'MAP1',
                            p_return_value      => p_hesa_fe_qual_aim);

          END IF;

      END IF; -- FE Stdnt Marker

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_get_feq%ISOPEN
          THEN
              CLOSE c_get_feq;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_fe_qual_aim');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_fe_qual_aim;

   PROCEDURE get_qual_aim_sbj1
      (p_qual_aim_subj1       IN igs_he_st_spa.qual_aim_subj1%TYPE,
       p_qual_aim_subj2       IN igs_he_st_spa.qual_aim_subj2%TYPE,
       p_qual_aim_subj3       IN igs_he_st_spa.qual_aim_subj3%TYPE,
       p_oss_qualaim_sbj      IN igs_he_code_values.value%TYPE,
       p_hesa_qualaim_sbj     OUT NOCOPY igs_he_code_values.value%TYPE
       )
   IS
  /***************************************************************
    Created By           :       bayadav
    Date Created By      :       25-OCT-2002
    Purpose              :This procedure gets the value of HESA mapped qualification aim proportion for field 46
    Known Limitations,Enhancements or Remarks:
    Change History       :
    Who                  When            What
    Bayadav   25-OCT-02  Included new procedure  as a part  of HEFD101
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;
   BEGIN

      IF p_qual_aim_subj1 IS NOT NULL
      AND p_qual_aim_subj2 IS NULL
      AND p_qual_aim_subj3 IS NULL
      THEN -- Single
          p_hesa_qualaim_sbj := '0';
      ELSIF p_qual_aim_subj2 IS NOT NULL AND p_qual_aim_subj3 IS NULL
      THEN

        l_he_code_map_val.association_code := 'OSS_HESA_PROPORTION_ASSOC';
        l_he_code_map_val.map2             := p_oss_qualaim_sbj;

        IF l_he_code_map_val.map2 IS NOT NULL
        THEN
            igs_he_extract2_pkg.get_map_values
                                 (p_he_code_map_val   => l_he_code_map_val,
                                  p_value_from        => 'MAP1',
                                  p_return_value      => p_hesa_qualaim_sbj);

        END IF;

      ELSIF p_qual_aim_subj3 IS NOT NULL
      THEN -- Triple or more
         p_hesa_qualaim_sbj := '3';
      END IF;

       EXCEPTION
       WHEN OTHERS
       THEN
           write_to_log (SQLERRM);
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_qual_aim_sbj1');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;

   END get_qual_aim_sbj1;

   PROCEDURE get_qual_aim_sbj
          ( p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_subject1              OUT NOCOPY VARCHAR2,
           p_subject2              OUT NOCOPY VARCHAR2,
           p_subject3              OUT NOCOPY VARCHAR2,
           p_prop_ind              OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Subjects of Qualification Aim
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     jtmathew  02-Feb-06  Modified derivation to include values 0 and 3
   ***************************************************************/

   CURSOR c_sbj1 IS
   SELECT b.govt_field_of_study,
          a.percentage
   FROM   igs_ps_field_study a,
          igs_ps_fld_of_study b
   WHERE  a.course_cd       = p_course_cd
   AND    a.version_number  = p_version_number
   AND    a.major_field_ind = 'Y'
   AND    a.field_of_study  = b.field_of_study;

   CURSOR c_sbj23 IS
   SELECT b.govt_field_of_study,
          a.percentage
   FROM   igs_ps_field_study a,
          igs_ps_fld_of_study b
   WHERE  a.course_cd       = p_course_cd
   AND    a.version_number  = p_version_number
   AND    a.major_field_ind = 'N'
   AND    a.field_of_study  = b.field_of_study
   ORDER BY percentage DESC ;

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_percentage1            igs_ps_field_study.percentage%TYPE;
   l_percentage2            igs_ps_field_study.percentage%TYPE;
   l_percentage3            igs_ps_field_study.percentage%TYPE;

   BEGIN
      -- Get Subject 1, Major
      OPEN  c_sbj1;
      FETCH c_sbj1 INTO p_subject1,
                        l_percentage1;
      CLOSE c_sbj1;

      -- Get Subject 2
      OPEN  c_sbj23;
      FETCH c_sbj23 INTO p_subject2,
                         l_percentage2;
      -- Get Subject 3
      FETCH c_sbj23 INTO p_subject3,
                         l_percentage3;
      CLOSE c_sbj23;

      p_prop_ind := NULL;

      IF l_percentage1 IS NOT NULL
      AND l_percentage2 IS NULL
      AND l_percentage3 IS NULL
      THEN -- Single
          p_prop_ind := '0';
      ELSE
         IF l_percentage2 IS NOT NULL
         AND l_percentage3 IS NULL
         THEN
            IF l_percentage2 = 50
            THEN
                -- Balanced Combination
                p_prop_ind := '1';
            ELSE
                -- Major, Minor
                p_prop_ind := '2';
            END IF;
         ELSIF l_percentage3 IS NOT NULL
         THEN -- Triple or more
            p_prop_ind := '3';
         END IF;

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_sbj1%ISOPEN
          THEN
              CLOSE c_sbj1;
          END IF;

          IF c_sbj23%ISOPEN
          THEN
              CLOSE c_sbj23;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_qual_aim_sbj ');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_qual_aim_sbj;

   FUNCTION is_ucas_ftug (p_hesa_qual_aim     IN igs_he_ex_rn_dat_fd.value%TYPE,
                          p_hesa_commdate     IN igs_he_ex_rn_dat_fd.value%TYPE,
                          p_ucasnum           IN igs_he_ex_rn_dat_fd.value%TYPE,
                          p_min_commdate      IN DATE) RETURN BOOLEAN
   IS
   /***************************************************************
     Created By           : Jay Mathew
     Date Created By      : 15-Mar-2005
     Purpose              : This function checks whether a student is a UCAS (FTUG, NMAS or SWAS)
                            student. The criteria for returning true depends on the following:
                            The student's qual_aim must be between 18 and 52 or must equal
                            either 61 or 97. The student also has to have a commencement
                            date that is greater than p_min_commdate. Used by various tariff
                            level fields in both a student and combined return.
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/
   BEGIN

      RETURN (TO_DATE(p_hesa_commdate, 'DD/MM/YYYY') > p_min_commdate AND
             (p_hesa_qual_aim IN ('18', '19', '20', '21', '22', '23', '24', '25', '26', '27',
                                  '28', '29', '30', '31', '32', '33', '34', '35', '36', '37',
                                  '38', '39', '40', '41', '42', '43', '44', '45', '46', '47',
                                  '48', '49', '50', '51', '52') OR p_hesa_qual_aim IN ('61','97')) AND
              p_ucasnum >= 1 );

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.is_ucas_ftug');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END is_ucas_ftug;

   PROCEDURE limit_no_of_qual(p_field_number  IN NUMBER,
                              p_person_number IN igs_pe_person.person_number%TYPE,
                              p_course_cd     IN igs_he_st_spa.course_cd%TYPE,
                              p_hesa_qual     IN VARCHAR2,
                              p_no_of_qual    IN OUT NOCOPY  NUMBER)
   IS
   /***************************************************************
     Created By           :
     Date Created By      : 15-Mar-2005
     Purpose              : This procedure checks whether the number of qualifications for
                            a student at a particular qualification level is within the
                            range of values allowed (0 to 9). If p_no_of_qual exceeds the max
                            value which HESA currently specifies as 9, then the value is set
                            to l_max_no_of_qual and a warning message is logged.
     Pre-condition        : p_no_of_qual IS NOT NULL.
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/
   l_max_no_of_qual NUMBER;
   l_old_no_of_qual NUMBER; -- only necessary for logging

   BEGIN

       l_max_no_of_qual := 9;
       l_old_no_of_qual := p_no_of_qual;

       IF p_no_of_qual > l_max_no_of_qual
       THEN
           p_no_of_qual := l_max_no_of_qual;

           FND_MESSAGE.SET_NAME('IGS','IGS_HE_MAX_TARIFF');
           FND_MESSAGE.SET_TOKEN('FIELD_NUM', p_field_number);
           FND_MESSAGE.SET_TOKEN('PER_NUM', p_person_number);
           FND_MESSAGE.SET_TOKEN('OLD_NUM', l_old_no_of_qual);
           FND_MESSAGE.SET_TOKEN('COURSE_CD',p_course_cd);
           FND_MESSAGE.SET_TOKEN('FIELD_NAME',p_hesa_qual);
           FND_MESSAGE.SET_TOKEN('MAX_NUM',l_max_no_of_qual);
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());

       END IF;

       EXCEPTION
       WHEN OTHERS
       THEN
          write_to_log (SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.limit_no_of_qual');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END limit_no_of_qual;

   PROCEDURE limit_tariff_score(p_field_number  IN NUMBER,
                                p_person_number IN igs_pe_person.person_number%TYPE,
                                p_course_cd     IN igs_he_st_spa.course_cd%TYPE,
                                p_hesa_qual     IN VARCHAR2,
                                p_tariff_score  IN OUT NOCOPY igs_he_ex_rn_dat_fd.value%TYPE)
   IS
   /***************************************************************
     Created By           :
     Date Created By      : 15-Mar-2005
     Purpose              : This procedure checks whether the tariff score for a student at
                            a particular qualification level is within the range of values
                            allowed (0 to 998). If p_tariff_score exceeds the max
                            value which HESA currently specifies as 998, then the value is
                            set to l_max_tariff_score and a warning message is logged.
     Pre-condition        : p_tariff_score exists.
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/
   l_max_tariff_score NUMBER;
   l_old_tariff_score NUMBER; -- only necessary for logging

   BEGIN

       l_max_tariff_score := 998;
       l_old_tariff_score := TO_NUMBER(p_tariff_score);

       IF l_old_tariff_score > l_max_tariff_score
       THEN
           p_tariff_score := TO_CHAR(l_max_tariff_score);

           FND_MESSAGE.SET_NAME('IGS','IGS_HE_MAX_TARIFF');
           FND_MESSAGE.SET_TOKEN('FIELD_NUM', p_field_number);
           FND_MESSAGE.SET_TOKEN('PER_NUM', p_person_number);
           FND_MESSAGE.SET_TOKEN('OLD_NUM', l_old_tariff_score);
           FND_MESSAGE.SET_TOKEN('COURSE_CD',p_course_cd);
           FND_MESSAGE.SET_TOKEN('FIELD_NAME',p_hesa_qual);
           FND_MESSAGE.SET_TOKEN('MAX_NUM',l_max_tariff_score);
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());

       END IF;

       p_tariff_score := LPAD(p_tariff_score, 3, '0');

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.limit_tariff_score');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END limit_tariff_score;

   PROCEDURE get_gen_qual_aim
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_spa_gen_qaim          IN  igs_he_st_spa.student_qual_aim%TYPE,
           p_hesa_gen_qaim         OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
           p_awd_conf_start_dt     IN  igs_he_submsn_awd.award_start_date%TYPE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets General Qualification Aim of Student
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smvk     03-Jun-2003   Bug # 2858436. Modified the cursor c_prgawd to select open program awards only.
     smaddali 21-jan-04     Modified cursor c_prgawd and c_spawd for bug#3360646
   ***************************************************************/

   --smaddali modified this cursor for bug 2392702
   -- smaddali Modified for bug#3360646, to check for dates overlapping with submission period
   --     and to exclude awards which are conferred before the submission start_date
   CURSOR c_spawd IS
   SELECT map1
   FROM   igs_en_spa_awd_aim , igs_he_code_map_val
   WHERE  person_id = p_person_id
   AND    course_cd = p_course_cd
   AND    start_dt <= NVL(p_enrl_end_dt,start_dt)
   AND    ( end_dt IS NULL OR end_dt >= NVL(p_enrl_start_dt,end_dt) )
   AND    ( (complete_ind = 'Y' AND conferral_date >= NVL(p_awd_conf_start_dt,conferral_date) ) OR
              complete_ind = 'N'
          )
   AND    map2 = award_cd
   AND    association_code = 'OSS_HESA_AWD_ASSOC'
   ORDER BY map1 ASC ;

   --smaddali modified this cursor for bug 2392702
   -- smaddali Modified for bug#3360646, to remove default_ind=Y check and add default_ind in order by clause
   CURSOR c_prgawd IS
   SELECT map1
   FROM   igs_ps_award , igs_he_code_map_val
   WHERE  course_cd      = p_course_cd
   AND    version_number = p_version_number
   AND    closed_ind     = 'N'
   AND    map2 = award_cd
   AND    association_code = 'OSS_HESA_AWD_ASSOC'
   ORDER BY default_ind DESC, map1 ASC ;

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_oss_gen_qaim           igs_ps_award.award_cd%TYPE;

   BEGIN

      IF p_spa_gen_qaim IS NOT NULL
      THEN
          l_oss_gen_qaim := p_spa_gen_qaim;
             --smaddali added this code for bug 2392702
           -- If some value found, get HESA equivalent value
          l_he_code_map_val.association_code := 'OSS_HESA_AWD_ASSOC';
          l_he_code_map_val.map2             :=  l_oss_gen_qaim ;

          igs_he_extract2_pkg.get_map_values
                       (p_he_code_map_val   => l_he_code_map_val,
                        p_value_from        => 'MAP1',
                        p_return_value      => p_hesa_gen_qaim);

      ELSE

          OPEN  c_spawd;
          FETCH c_spawd INTO p_hesa_gen_qaim ;
          CLOSE c_spawd;

          IF p_hesa_gen_qaim IS NULL
          THEN
            -- If still null, use the one at Program Level
              OPEN  c_prgawd;
              FETCH c_prgawd INTO p_hesa_gen_qaim ;
              CLOSE c_prgawd;
          END IF;

      END IF;


      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_spawd%ISOPEN
          THEN
              CLOSE c_spawd;
          END IF;

          IF c_prgawd%ISOPEN
          THEN
              CLOSE c_prgawd;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_gen_qual_aim');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_gen_qual_aim;



   PROCEDURE get_awd_body_12
          (p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_awd1                  IN  VARCHAR2,
           p_awd2                  IN  VARCHAR2,
           p_awd_body1             OUT NOCOPY VARCHAR2,
           p_awd_body2             OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Awarding Bodies 1 and 2
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     JBaber    20-Sept-04   Changes for bug 3830986
     anwest    09-Jun-04    Changes for bug #4401841
   ***************************************************************/

   -- jbaber 20-Sept-04
   -- updated cursor to group by institution code and order by sum(percentage)
   -- this guarantees distinct institution codes ordered by the total % contribution
   -- anwest 09-Jun-05
   -- updated cursor for HZ_PARTIES.PARTY_NUMBER issue - bug #4401841
   CURSOR c_awdbdy (p_award_cd      VARCHAR2) IS
   SELECT ihpinst.oi_govt_institution_cd govt_institution_cd
   FROM   igs_ps_awd_own a,
          igs_pe_hz_parties  ihpou,
          igs_pe_hz_parties  ihpinst
   WHERE  a.course_cd          = p_course_cd
   AND    a.version_number     = p_version_number
   AND    a.award_cd           = p_award_cd
   AND    a.org_unit_cd        = ihpou.oss_org_unit_cd
   AND    ihpou.institution_cd = ihpinst.oss_org_unit_cd
   GROUP BY ihpinst.oi_govt_institution_cd
   ORDER BY SUM(a.percentage) DESC;

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   BEGIN

      OPEN  c_awdbdy (p_awd1);
      FETCH c_awdbdy INTO p_awd_body1;

      IF p_awd2 IS NULL
      THEN
          -- Use the next record in the cursor c_awdbdy
          FETCH c_awdbdy INTO p_awd_body2;
          CLOSE c_awdbdy;
      ELSE
          IF c_awdbdy%ISOPEN
          THEN
              CLOSE c_awdbdy;
          END IF;

          OPEN  c_awdbdy (p_awd2);
          FETCH c_awdbdy INTO p_awd_body2;
          CLOSE c_awdbdy;
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          IF c_awdbdy%ISOPEN
          THEN
              CLOSE c_awdbdy;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_awd_body_12');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_awd_body_12;



   PROCEDURE get_prog_length
          (p_spa_attendance_type   IN  igs_en_stdnt_ps_att.attendance_type%TYPE,
           p_ft_compl_time         IN  igs_ps_ver.std_ft_completion_time%TYPE,
           p_pt_compl_time         IN  igs_ps_ver.std_pt_completion_time%TYPE,
           p_length                OUT NOCOPY VARCHAR2,
           p_units                 OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Expected Length and Units of meausrement of length
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_length              NUMBER;
   l_year                NUMBER;
   l_months              NUMBER;
   l_weeks               NUMBER;

   BEGIN

      IF p_spa_attendance_type LIKE 'F%'
      THEN
          l_length := p_ft_compl_time;
      ELSE
          l_length := p_pt_compl_time;
      END IF;

      l_year := l_length / 10;

      IF l_year = ROUND(l_year)
      THEN
          -- Its a whole number so return the year
          p_length := l_year;
          p_units  := '1';
      ELSE
          l_months := l_year * 12;
          IF l_months = ROUND(l_months)
          THEN
              -- Months is a whole number, so return the months
              IF l_months < 99
              THEN
                  p_length := l_months;
                  p_units  := '2';
              ELSE
                  -- Return the Years
                  p_length := ROUND(l_year);
                  p_units  := '1';
              END IF; -- Months less than 99
          ELSE
              l_weeks := ROUND(l_year * 52);
              IF l_weeks < 99
              THEN
                  p_length := l_weeks;
                  p_units := '3';
              ELSE
                  p_length := ROUND(l_months);
                  p_units := '2';
              END IF;
          END IF; -- Months is a whole number
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_prog_length');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_prog_length;

   PROCEDURE get_teach_train_crs_id
          (p_prg_ttcid                IN  igs_he_st_prog.teacher_train_prog_id%TYPE,
           p_spa_ttcid                IN  igs_he_st_spa.teacher_train_prog_id%TYPE,
           p_hesa_ttcid               OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Teacher Training Course Identifier
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_TTCID_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_spa_ttcid, p_prg_ttcid) ;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_ttcid);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_teach_train_crs_id');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_teach_train_crs_id;


   PROCEDURE get_itt_phsc
          (p_prg_itt_phsc                IN  igs_he_st_prog.itt_phase%TYPE,
           p_spa_itt_phsc                IN  igs_he_st_spa.itt_phase%TYPE,
           p_hesa_itt_phsc               OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the ITT Phase / Scope
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_ITTPHSC_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_spa_itt_phsc, p_prg_itt_phsc) ;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_itt_phsc);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_itt_phsc');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_itt_phsc;


   PROCEDURE get_itt_mrker
          (p_prg_itt_mrker                IN  igs_he_st_prog.bilingual_itt_marker%TYPE,
           p_spa_itt_mrker                IN  igs_he_st_spa.bilingual_itt_marker%TYPE,
           p_hesa_itt_mrker               OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Billingual ITT Marker
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_BITTM_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_spa_itt_mrker, p_prg_itt_mrker) ;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_itt_mrker);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_itt_mrker');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_itt_mrker;



   PROCEDURE get_teach_qual_sect
          (p_oss_teach_qual_sect     IN  igs_he_st_prog.teaching_qual_sought_sector%TYPE,
           p_hesa_teach_qual_sect    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Teaching Qualification Sought Sector and Teaching Qualification Gained Sector
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_TQSEC_ASSOC';
      l_he_code_map_val.map2             := p_oss_teach_qual_sect;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_teach_qual_sect);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_teach_qual_sect');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_teach_qual_sect;



   PROCEDURE get_teach_qual_sbj
          (p_oss_teach_qual_sbj     IN  igs_he_st_prog.teaching_qual_sought_subj1%TYPE,
           p_hesa_teach_qual_sbj    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Teaching Qualification Sought Subject and Teaching Qualification Gained Subject
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_TQSUB123_ASSOC';
      l_he_code_map_val.map2             := p_oss_teach_qual_sbj;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_teach_qual_sbj);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_teach_qual_sbj');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_teach_qual_sbj;


   PROCEDURE get_fee_elig
           (p_person_id            IN  igs_pe_person.person_id%TYPE,
            p_susa_fee_elig        IN  igs_he_en_susa.fee_eligibility%TYPE,
            p_fe_stdnt_mrker       IN  igs_he_st_spa.fe_student_marker%TYPE,
            p_study_mode           IN  VARCHAR2,
            p_special_student      IN  VARCHAR2,
            p_hesa_fee_elig        OUT NOCOPY VARCHAR2,
            p_enrl_start_dt        IN  igs_he_submsn_header.enrolment_start_date%TYPE,
            p_enrl_end_dt          IN  igs_he_submsn_header.enrolment_end_date%TYPE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Fee Eligibility
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
     anwest   09-Dec-03   Modified for HE356 - updated to accommodate
                          Term/Load calendar associated with residency
     jtmathew 23-May-06   Modified c_res_sts for bug 5210481
   ***************************************************************/

   -- smaddali modified this cursor for bug 2367167 to get records which are effective in the HESA submission period, bug#3235753
   -- anwest   modified this cursor for HE356 to accommodate Term/Load Calendar for Residency Status
   -- jtmathew modified this cursor for bug 5210481 to remove igs_pe_res_dtls_v view
     CURSOR c_res_sts (cp_res_class_cd   VARCHAR2) IS
     SELECT peresdtls.residency_status_cd residency_status
       FROM igs_pe_res_dtls_all peresdtls,
            igs_lookup_values cc1,
            igs_lookup_values cc2,
            igs_ca_inst_all cainstall
      WHERE peresdtls.person_id = p_person_id
        AND peresdtls.residency_class_cd = cc1.lookup_code
        AND cc1.lookup_type = 'PE_RES_CLASS'
        AND peresdtls.residency_status_cd = cc2.lookup_code
        AND cc2.lookup_type = 'PE_RES_STATUS'
        AND peresdtls.residency_class_cd = cp_res_class_cd
        AND peresdtls.cal_type = cainstall.cal_type
        AND peresdtls.sequence_number = cainstall.sequence_number
        AND cainstall.start_dt <= p_enrl_end_dt
   ORDER BY cainstall.start_dt DESC;

   l_residency_status       igs_pe_res_dtls_v.residency_status%TYPE;
   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_oss_fee_elig           igs_he_code_map_val.map1%TYPE;
   l_res_class_cd           igs_pe_res_dtls_v.residency_class%TYPE;

   BEGIN

      IF p_susa_fee_elig IS NOT NULL
      THEN
          l_oss_fee_elig := p_susa_fee_elig;
      ELSE
          -- Get the Fee Eligibility using special student code.
          l_he_code_map_val.association_code := 'OSS_SPCSTU_FEEELIG_ASSOC';
          l_he_code_map_val.map2             := p_special_student;

          IF l_he_code_map_val.map2 IS NOT NULL
          THEN
              igs_he_extract2_pkg.get_map_values
                                   (p_he_code_map_val   => l_he_code_map_val,
                                    p_value_from        => 'MAP1',
                                    p_return_value      => l_oss_fee_elig);

          END IF;
      END IF;

      IF l_oss_fee_elig IS NULL
      THEN
          -- Try getting it using FE Student Marker
          l_he_code_map_val.association_code := 'OSS_FESTUMK_FEEELIG_ASSOC';
          l_he_code_map_val.map2             := p_fe_stdnt_mrker;

          IF l_he_code_map_val.map2 IS NOT NULL
          THEN
              igs_he_extract2_pkg.get_map_values
                                   (p_he_code_map_val   => l_he_code_map_val,
                                    p_value_from        => 'MAP1',
                                    p_return_value      => l_oss_fee_elig);

          END IF;
      END IF;

      IF l_oss_fee_elig IS NULL
      THEN
          -- Try getting it using Study Location
          l_he_code_map_val.association_code := 'OSS_MODE_FEEELIG_ASSOC';
          l_he_code_map_val.map2             := p_study_mode;

          IF l_he_code_map_val.map2 IS NOT NULL
          THEN
              igs_he_extract2_pkg.get_map_values
                                   (p_he_code_map_val   => l_he_code_map_val,
                                    p_value_from        => 'MAP1',
                                    p_return_value      => l_oss_fee_elig);

          END IF;
      END IF;

      IF l_oss_fee_elig IS NULL
      THEN
          -- Try getting it using residency Status / Fee Category
          Fnd_Profile.Get('IGS_FI_RES_CLASS_ID', l_res_class_cd);

          -- anwest HE356 - If residency statuses are returned get the mapped
          --                value of the first record
          OPEN  c_res_sts (l_res_class_cd);
          FETCH c_res_sts INTO l_residency_status;
          IF c_res_sts%NOTFOUND THEN
                CLOSE c_res_sts;
          ELSE
                CLOSE c_res_sts;
                l_he_code_map_val.association_code := 'OSS_FEECAT_FEEELIG_ASSOC';
                l_he_code_map_val.map2             := l_residency_status;
                igs_he_extract2_pkg.get_map_values
                        (p_he_code_map_val   => l_he_code_map_val,
                         p_value_from        => 'MAP1',
                         p_return_value      => l_oss_fee_elig);
          END IF;
      END IF;

      IF l_oss_fee_elig IS NOT NULL
      THEN
          -- We have a value, get the HESA equivalent

          l_he_code_map_val.association_code := 'OSS_HESA_FEEELIG_ASSOC';
          l_he_code_map_val.map2             := l_oss_fee_elig;

          igs_he_extract2_pkg.get_map_values
                                  (p_he_code_map_val   => l_he_code_map_val,
                                    p_value_from       => 'MAP1',
                                    p_return_value     => p_hesa_fee_elig);

      END IF;


      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_res_sts%ISOPEN
          THEN
              CLOSE c_res_sts;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_fee_elig');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_fee_elig;



   PROCEDURE get_fee_band
          (p_hesa_fee_elig     IN  igs_he_en_susa.fee_eligibility%TYPE,
           p_susa_fee_band     IN  igs_he_en_susa.fee_band%TYPE,
           p_poous_fee_band    IN  igs_he_poous.fee_band%TYPE,
           p_prg_fee_band      IN  igs_he_st_prog.fee_band%TYPE,
           p_hesa_fee_band     OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Fee Band
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     jtmathew  25-Jan-2006  Modifications for bug 4416467
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

      IF p_hesa_fee_elig = '2' THEN
        -- for all overseas students
        p_hesa_fee_band := '99';

      ELSE

          l_he_code_map_val.association_code := 'OSS_HESA_FEEBAND_ASSOC';
          l_he_code_map_val.map2             := Nvl(Nvl(p_susa_fee_band,
                                                        p_poous_fee_band),
                                                        p_prg_fee_band) ;

          IF l_he_code_map_val.map2 IS NOT NULL
          THEN
              igs_he_extract2_pkg.get_map_values
                                   (p_he_code_map_val   => l_he_code_map_val,
                                    p_value_from        => 'MAP1',
                                    p_return_value      => p_hesa_fee_band);

          END IF;

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_fee_band');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_fee_band;


   PROCEDURE get_amt_tuition_fees
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_cal_type              IN  igs_en_stdnt_ps_att.cal_type%TYPE,
           p_fe_prg_mrker          IN  igs_he_st_prog.fe_program_marker%TYPE,
           p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_oss_amt               OUT NOCOPY NUMBER,
           p_hesa_amt              OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Amount of tuition Fees
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When        What
     smaddali              Modified this procedure for bug 2716038
     dsridhar  10-Sep-03   Bug No: 2911678. Modified the cursor c_fees by replacing the
                           view igs_fi_fee_ass_debt_v with the view igs_fi_fee_as. This is done
                           as the view igs_fi_fee_ass_debt_v has performance issues and is being
                           obsoleted.
     smaddali  13-Oct-03   Modified procedure to add 2 new parameters and modified cursor c_fees for bug# 3179544
     jtmathew  04-Jul-06   Modifications for bug 5283519. Modified procedure to run for all students,
                           and also sets tuition fees to zero if c_fees returns NULL
   ***************************************************************/

   -- smaddali modified this cursor to remove the obsoleted table igs_fi_chg_mth_app reference
   -- as part of bug 2421778
   -- Bug No: 2911678. Replacing the view igs_fi_fee_ass_debt_v with the view igs_fi_fee_as.
   -- smaddali modified this cursor for bug#3179544 , filtering based on Submission periods
   CURSOR c_fees IS
   SELECT SUM(chg.transaction_amount) tuition_fees
   FROM igs_fi_fee_type ft, igs_fi_fee_as chg
   WHERE ft.s_fee_type = 'TUTNFEE'
      AND chg.person_id = p_person_id
      AND (chg.course_cd IS NULL OR chg.course_cd = p_course_cd)
      AND chg.fee_type = ft.fee_type
      AND (chg.effective_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt);

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_tuition_fees           NUMBER;

   l_hesa_feprmk    igs_he_code_map_val.map1%TYPE := NULL;

   BEGIN

          OPEN  c_fees;
          FETCH c_fees INTO l_tuition_fees;
          CLOSE c_fees;
          p_oss_amt  := l_tuition_fees;

          IF p_fe_prg_mrker IS NOT NULL
          THEN
          -- Get the HESA equivalent value for oss_feprmk ,
          -- smaddali added this conversion for bug 2716038
          l_he_code_map_val.association_code := 'OSS_HESA_FEPRMK_ASSOC';
          l_he_code_map_val.map2             := p_fe_prg_mrker;
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_hesa_feprmk);

          END IF;

      IF l_tuition_fees IS NULL THEN
        l_tuition_fees := 0;
        p_oss_amt := 0;
      END IF;

      IF l_hesa_feprmk IN ('A','W') THEN
        p_hesa_amt := l_hesa_feprmk ||LPAD(l_tuition_fees,5,0);
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_fees%ISOPEN
          THEN
              CLOSE c_fees;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_amt_tuition_fees');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_amt_tuition_fees;


   PROCEDURE get_maj_src_tu_fee
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE,
           p_special_stdnt         IN  VARCHAR2,
           p_study_mode            IN  VARCHAR2,
           p_amt_tu_fee            IN  NUMBER,
           p_susa_mstufee          IN  igs_he_en_susa.student_fee%TYPE,
           p_hesa_mstufee          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Major Source of Tuition Fees
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     rbezawad  08-Apr-03    Modified w.r.t. HECR009 Build - MSTUFEE derivation, Bug 2881348.
     rbezawad  24-Jun-03    Modified for Bug 2961802 - Back porting MNT bug fixes(2958935, 2958973)
                             1) Add the Closed Indicator check in cursors cur_slc_spnsr
                                and cur_slc_ld_cal when SLC code is retrived from Hesa Code Type: OSS_SLC_SPONSOR.
                             2) Modified procedure get_maj_src_tu_fee to handle the senario when Student who sponsored
                                by SLC don't have any SLC LEA Code defined.
     smaddali  11-dec-03    Modified for bug#3235753 , added 2 new parameters
     ayedubat  14-Jan-04    Modified the cursor, cur_spnsr to add a new condition
                            award_status IN ('ACCEPTED','OFFERED') for bug, 2911746
     sjlaport  31-Jan-05    Modified cursor cur_slc_lea_cd for HE358 to ignore logically deleted records
     jchakrab  02-Feb-06    Modified logic such that a value 98 is derived when tution fee amount=0
   ***************************************************************/

   --Query to get all Sponsor records for student within the given HESA reporting period.
   CURSOR cur_spnsr IS
     SELECT SUM (a.disb_net_amt) sponsor_amount,
            d.map1 sponsor
     FROM   igf_aw_awd_disb a,
            igf_aw_award b,
            igf_aw_fund_mast fmast,
            igf_ap_fa_base_rec c,
            igs_he_code_map_val d,
            igs_ca_inst ca
     WHERE  a.award_id = b.award_id
     AND    b.fund_id = fmast.fund_id
     AND    b.base_id = c.base_id
     AND    a.ld_cal_type = ca.cal_type
     AND    a.ld_sequence_number = ca.sequence_number
     AND    d.association_code = 'OSS_SPONSOR_MSTUFEE_ASSOC'
     AND    d.map2 = fmast.fund_code
     AND    c.person_id = p_person_id
     AND    a.fee_class = 'TUITION'
     AND    a.trans_type IN ('A' , 'P')
     AND    b.award_status IN ('ACCEPTED','OFFERED')
     AND    ca.start_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt
     GROUP BY d.map1
     ORDER BY sponsor_amount DESC, sponsor ASC;

   l_spnsr_rec       cur_spnsr%ROWTYPE ;

   --Query to get the fund amount sponsored by the SLC.
   CURSOR cur_slc_spnsr IS
     SELECT SUM (a.disb_net_amt) sponsor_amount,
            fmast.fund_code
     FROM   igf_aw_awd_disb a,
            igf_aw_award b,
            igf_aw_fund_mast fmast,
            igf_ap_fa_base_rec c,
            igs_he_code_values d,
            igs_ca_inst ca
     WHERE  a.award_id         = b.award_id
     AND    b.fund_id          = fmast.fund_id
     AND    b.base_id          = c.base_id
     AND    a.ld_cal_type      = ca.cal_type
     AND    a.ld_sequence_number = ca.sequence_number
     AND    d.code_type = 'OSS_SLC_SPONSOR'
     AND    d.value = fmast.fund_code
     AND    NVL(d.closed_ind, 'N') = 'N'
     AND    c.person_id        = p_person_id
     AND    a.fee_class        = 'TUITION'
     AND    a.trans_type IN ('A' , 'P')
     AND    ca.start_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt
     GROUP BY fmast.fund_code;

     l_slc_spnsr_rec cur_slc_spnsr%ROWTYPE;

     -- Get the SLC LEA Code
     -- smaddali modified this cursor to get records which are effective in the HESA submission period, bug#3235753
     CURSOR cur_slc_lea_cd IS
       SELECT SUBSTR (api.api_person_id,1,4)
       FROM   igs_pe_alt_pers_id_v api,
              igs_pe_person_id_typ pit
       WHERE  api.person_id_type = pit.Person_id_type
       AND    pit.s_person_id_type = 'SLC'
       AND    api.pe_person_id = p_person_id
       AND    NVL (api.start_dt, p_enrl_end_dt ) <= p_enrl_end_dt
       AND    NVL (api.end_dt, p_enrl_start_dt )   >= p_enrl_start_dt
       AND    (api.end_dt IS NULL OR api.start_dt <> api.end_dt)
       ORDER BY api.start_dt DESC;

     --Query to get Load Calendars of SLC sponsored fund
     CURSOR cur_slc_ld_cal IS
       SELECT DISTINCT a.ld_cal_type, a.ld_sequence_number
       FROM   igf_aw_awd_disb a,
              igf_aw_award b,
              igf_aw_fund_mast fmast,
              igf_ap_fa_base_rec c,
              igs_he_code_values d,
              igs_ca_inst ca
       WHERE  a.award_id         = b.award_id
       AND    b.fund_id          = fmast.fund_id
       AND    b.base_id          = c.base_id
       AND    a.ld_cal_type      = ca.cal_type
       AND    a.ld_sequence_number = ca.sequence_number
       AND    d.code_type = 'OSS_SLC_SPONSOR'
       AND    d.value = fmast.fund_code
       AND    NVL(d.closed_ind, 'N') = 'N'
       AND    c.person_id        = p_person_id
       AND    a.fee_class        = 'TUITION'
       AND    a.trans_type IN ('A' , 'P')
       AND    ca.start_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt;

     --Query to get the Invoice amount for the student tution fees
     CURSOR cur_inv_amt (cp_fee_cal_type igs_ca_inst.cal_type%TYPE,
                         cp_fee_ci_sequence_number igs_ca_inst.sequence_number%TYPE)
     IS
       SELECT NVL(SUM(inv.invoice_amount),0) invoice_amount
       FROM   igs_fi_inv_int inv,
              igs_fi_fee_type ft
       WHERE  inv.fee_type = ft.fee_type
       AND    person_id = p_person_id
       AND    inv.fee_cal_type = cp_fee_cal_type
       AND    inv.fee_ci_sequence_number =  cp_fee_ci_sequence_number
       AND    ft.s_fee_type = 'TUTNFEE';

     l_value           igs_he_ex_rn_dat_fd.value%TYPE;
     l_slc_lea_cd      igs_pe_alt_pers_id.api_person_id%TYPE;
     l_he_code_map_val igs_he_code_map_val%ROWTYPE;
     l_invoice_amt     igs_fi_inv_int.invoice_amount%TYPE;
     l_tot_invoice_amt igs_fi_inv_int.invoice_amount%TYPE;
     l_message_name    fnd_new_messages.message_name%TYPE;
     l_fee_cal_type    igs_ca_inst.cal_type%TYPE;
     l_fee_ci_sequence_number igs_ca_inst.sequence_number%TYPE;

   BEGIN

      l_value := NULL;
      l_he_code_map_val := NULL;

      IF p_susa_mstufee IS NOT NULL THEN
          -- Get the HESA equivalent value for SUSA MSTUFEE
          l_he_code_map_val.association_code := 'OSS_HESA_MSTUFEE_ASSOC';
          l_he_code_map_val.map2             := p_susa_mstufee;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_mstufee);

      ELSE

          IF p_special_stdnt IS NOT NULL THEN
            -- Get the HESA equivalent value Special Student
            l_he_code_map_val.association_code := 'HESA_SPCSTU_MSTUFEE_ASSOC';
            l_he_code_map_val.map2             := p_special_stdnt;
            igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_value);
          END IF;

          --Check if MSTUFEE is available at Special Student Level
          IF l_value IS NOT NULL THEN
              p_hesa_mstufee := l_value;
          ELSE

              IF p_study_mode IS NOT NULL THEN
                 -- Get the HESA equivalent value for Special Student
                 l_he_code_map_val.association_code := 'HESA_MODE_MSTUFEE_ASSOC';
                 l_he_code_map_val.map2             := p_study_mode;
                 igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_value);

              END IF;

              --Check if MSTUFEE is available at Mode of Study Level
              IF l_value IS NOT NULL THEN
                  p_hesa_mstufee := l_value;
              ELSE
                  --jchakrab added for 4873515
                  IF p_amt_tu_fee = 0 THEN
                      p_hesa_mstufee := '98';
                  ELSE

                      -- Get the Sponsor information
                      OPEN cur_spnsr ;
                      FETCH cur_spnsr INTO l_spnsr_rec ;

                      --If there are no Sponsor records available
                      IF cur_spnsr%NOTFOUND THEN
                          CLOSE cur_spnsr;
                          p_hesa_mstufee := '01';
                      ELSE
                          --When Sponsor records are available
                          CLOSE cur_spnsr;

                          --Get the SLC sponsor record information
                          OPEN cur_slc_spnsr;
                          FETCH cur_slc_spnsr INTO l_slc_spnsr_rec;

                          --If SLC Sponsor record exists.
                          IF cur_slc_spnsr%FOUND THEN

                              CLOSE cur_slc_spnsr;
                               --Get the SLC LEA Code i.e., First 4 characters of the SLC Student Identifier, which is Alternate Person ID with System Type "SLC".
                              OPEN cur_slc_lea_cd;
                              FETCH cur_slc_lea_cd INTO l_slc_lea_cd;

                              IF l_slc_lea_cd IS NOT NULL THEN
                                -- Get the HESA equivalent value for SLC LEA Code
                                l_he_code_map_val.association_code := 'OSS_HESA_SLCID_MSTUFEE_ASSOC';
                                l_he_code_map_val.map2             := l_slc_lea_cd;
                                igs_he_extract2_pkg.get_map_values
                                   (p_he_code_map_val   => l_he_code_map_val,
                                    p_value_from        => 'MAP1',
                                    p_return_value      => l_value);
                              END IF;
                              CLOSE cur_slc_lea_cd;

                              l_tot_invoice_amt := 0;
                              --To Calculate the total Invoice Amount.
                              FOR l_slc_ld_cal_rec IN cur_slc_ld_cal
                              LOOP
                                  --Derive the related Fee Calendar Instance for the passed Load Calendar Instance by using Student Finance API
                                  IF igs_fi_gen_001.finp_get_lfci_reln( p_cal_type               => l_slc_ld_cal_rec.ld_cal_type,
                                                                        p_ci_sequence_number     => l_slc_ld_cal_rec.ld_sequence_number,
                                                                        p_cal_category           => 'LOAD',
                                                                        p_ret_cal_type           => l_fee_cal_type,
                                                                        p_ret_ci_sequence_number => l_fee_ci_sequence_number,
                                                                        p_message_name           => l_message_name ) THEN
                                     l_invoice_amt := 0;

                                     --To get the invoice amount charged for the Tution Fee in the given Fee Calendar.
                                     OPEN cur_inv_amt(l_fee_cal_type, l_fee_ci_sequence_number);
                                     FETCH cur_inv_amt INTO l_invoice_amt;

                                     --Sum the amount to get the total Invoice amount charged for Tution Fee.
                                     l_tot_invoice_amt := l_tot_invoice_amt + l_invoice_amt;

                                     CLOSE cur_inv_amt;
                                  END IF;
                              END LOOP;

                              --Check if SLC pays full Tution Fee or not.
                              IF l_slc_spnsr_rec.sponsor_amount = l_tot_invoice_amt THEN
                                 p_hesa_mstufee := l_value;
                              ELSIF l_value = '02' THEN
                                 p_hesa_mstufee := '52';
                              ELSIF l_value = '03' THEN
                                 p_hesa_mstufee := '53';
                              ELSIF l_value = '04' THEN
                                 p_hesa_mstufee := '54';
                              END IF;

                          ELSE
                              --When Sponsors other than SLC exists.
                              CLOSE cur_slc_spnsr;
                              p_hesa_mstufee := l_spnsr_rec.sponsor;

                          END IF; --End of Check for SLC sponsor record exits. i.e., it pays tutuion fee or not

                      END IF ; -- End of Check for Sponsor Records of Student

                  END IF; -- End of check for tuition-fees = 0

              END IF;  -- End of Check for MSTUFEE at Mode of Study

          END IF; -- End of Check for MSTUFEE at Special Student

      END IF; -- End of check for SUSA Major Source of Tuition Fee is null.

   EXCEPTION
      WHEN OTHERS THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.GET_MAJ_SRC_TU_FEE - '||SQLERRM);
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_maj_src_tu_fee;



   PROCEDURE get_religion
          (p_oss_religion     IN  igs_pe_stat_v.religion%TYPE,
           p_hesa_religion    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Religion
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_RELIG_ASSOC';
      l_he_code_map_val.map2             := p_oss_religion;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_religion);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_religion');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_religion;



   PROCEDURE get_sldd_disc_prv
          (p_oss_sldd_disc_prv     IN  igs_he_en_susa.sldd_discrete_prov%TYPE,
           p_fe_stdnt_mrker        IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_hesa_sldd_disc_prv    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the SLDD Discrete Provision
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      IF p_fe_stdnt_mrker IN ('1','3','4')
      AND p_oss_sldd_disc_prv IS NOT NULL
      THEN
          l_he_code_map_val.association_code := 'OSS_HESA_ST13_ASSOC';
          l_he_code_map_val.map2             := p_oss_sldd_disc_prv;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_sldd_disc_prv);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_sldd_disc_prv');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_sldd_disc_prv;



   PROCEDURE get_non_payment_rsn
          (p_oss_non_payment_rsn     IN  igs_he_en_susa.non_payment_reason%TYPE,
           p_fe_stdnt_mrker          IN  igs_he_st_spa.fe_student_marker%TYPE,
           p_hesa_non_payment_rsn    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Non Payment Reason
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_NONPAY_ASSOC';
      l_he_code_map_val.map2             := p_oss_non_payment_rsn;
   IF p_fe_stdnt_mrker IN ('1','3','4') THEN
      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_non_payment_rsn);

      END IF;

  END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_non_payment_rsn');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_non_payment_rsn;


   PROCEDURE get_oth_teach_inst
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_program_calc          IN  igs_he_st_prog.program_calc%TYPE,
           p_susa_inst1            IN  igs_he_en_susa.teaching_inst1%TYPE,
           p_poous_inst1           IN  igs_he_poous.other_instit_teach1%TYPE,
           p_prog_inst1            IN  igs_he_st_prog.other_inst_prov_teaching1%TYPE,
           p_susa_inst2            IN  igs_he_en_susa.teaching_inst1%TYPE,
           p_poous_inst2           IN  igs_he_poous.other_instit_teach1%TYPE,
           p_prog_inst2            IN  igs_he_st_prog.other_inst_prov_teaching1%TYPE,
           p_hesa_inst1            OUT NOCOPY VARCHAR2,
           p_hesa_inst2            OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Other Institution Providing Teaching 1 and 2
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     anwest    09-Jun-04    Changes for bug #4401841
     jbaber   19-Jan-2006   Exclude flagged units for HE305 - Extract Improvements
   ***************************************************************/

   -- anwest 09-Jun-05
   -- updated cursor for HZ_PARTIES.PARTY_NUMBER issue - bug #4401841
   CURSOR c_inst (p_inst_cd     VARCHAR2) IS
   SELECT ihp.oi_govt_institution_cd govt_institution_cd
   FROM   igs_pe_hz_parties  ihp
   WHERE  ihp.oss_org_unit_cd = p_inst_cd;

   CURSOR c_un_inst IS
   SELECT  ihpinst.oi_govt_institution_cd govt_institution_cd
   FROM   igs_en_su_attempt  a,
          igs_ps_tch_resp    b,
          igs_pe_hz_parties ihpou,
          igs_pe_hz_parties ihpinst,
          igs_he_st_unt_vs_all hunt
   WHERE  a.course_cd      = p_course_cd
   AND    a.person_id      = p_person_id
   AND    b.unit_cd        = a.unit_cd
   AND    b.version_number = a.version_number
   AND    a.unit_cd        = hunt.unit_cd (+)
   AND    a.version_number = hunt.version_number (+)
   AND    NVL(hunt.exclude_flag, 'N') = 'N'
   AND    a.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
   AND    a.ci_start_dt  BETWEEN  p_enrl_start_dt  AND p_enrl_end_dt
   AND    b.org_unit_cd    = ihpou.oss_org_unit_cd
   AND    ihpou.institution_cd = ihpinst.oss_org_unit_cd
   AND    NVL(ihpinst.oi_local_institution_ind,'N') = 'N'
   ORDER BY b.percentage DESC;

   l_un_inst    c_un_inst%ROWTYPE := NULL  ;
   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_oss_inst               VARCHAR2(30);

   BEGIN

      IF p_program_calc = 'Y'
      THEN
          -- Program Based Calculations
          -- Get HESA value for Institute 1
          l_oss_inst := Nvl(Nvl(p_susa_inst1, p_poous_inst1), p_prog_inst1);
          OPEN c_inst (l_oss_inst);
          FETCH c_inst INTO p_hesa_inst1;
          CLOSE c_inst;

          -- Get HESA value for Institute 2
          l_oss_inst := NULL;
          l_oss_inst := Nvl(Nvl(p_susa_inst2, p_poous_inst2), p_prog_inst2);
          OPEN c_inst (l_oss_inst);
          FETCH c_inst INTO p_hesa_inst2;
          CLOSE c_inst;

      ELSE
          -- Unit Based Calculations
          OPEN  c_un_inst ;
          FETCH c_un_inst INTO p_hesa_inst1;
          --smaddali added this code to loop thru until a different institution is obtained for bug 2411691
          LOOP
            FETCH c_un_inst INTO l_un_inst;
            EXIT WHEN c_un_inst%NOTFOUND ;
            IF l_un_inst.govt_institution_cd <> p_hesa_inst1 THEN
                p_hesa_inst2 := l_un_inst.govt_institution_cd ;
                EXIT;
            END IF;
          END LOOP ;
          CLOSE c_un_inst;

      END IF; -- Program / unit based calculations

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_inst%ISOPEN
          THEN
              CLOSE c_inst;
          END IF;

          IF c_un_inst%ISOPEN
          THEN
              CLOSE c_un_inst;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_oth_teach_inst');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_oth_teach_inst;


   PROCEDURE get_prop_not_taught
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE,
           p_program_calc          IN  igs_he_st_prog.program_calc%TYPE,
           p_susa_prop             IN  igs_he_en_susa.pro_not_taught%TYPE,
           p_poous_prop            IN  igs_he_poous.prop_not_taught%TYPE,
           p_prog_prop             IN  igs_he_st_prog.prop_not_taught%TYPE,
           p_hesa_prop             OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Proportion not taught
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     sarakshi  27-Jun-2003  Enh#2930935,modified cursors c_other_inst_cp,c_total_cp such that enrolled
                            credit points are looked at unit section level if exists else at unit level
     smaddali               Modified cursor c_un_prop for bug 2411740
     smaddali               Added new parameters p_enrl_start_dt , p_enrl_end_dt for bug 2437081
     anwest    09-Jun-04    Changes for bug #4401841
     jbaber    19-Jan-2006  Exclude flagged units for HE305 - Extract Improvements
   ***************************************************************/

   --smaddali replaced the old cursor c_unt_prop with these two cursors c_other_inst_cp and c_total_cp
    -- for bug 2437081
   -- anwest 09-Jun-05
   -- updated cursor for HZ_PARTIES.PARTY_NUMBER issue - bug #4401841
   CURSOR c_other_inst_cp IS
   SELECT SUM( NVL(override_enrolled_cp,NVL(cps.enrolled_credit_points,e.enrolled_credit_points)) * b.percentage / 100 )  other_inst_cp
   FROM   igs_en_su_attempt  a,
          igs_ps_tch_resp    b,
          igs_pe_hz_parties ihpou,
          igs_pe_hz_parties ihpinst,
          igs_ps_unit_ver e,
          igs_ps_usec_cps cps,
          igs_he_st_unt_vs_all hunt
   WHERE  a.course_cd      = p_course_cd
   AND    a.person_id      = p_person_id
   AND    b.unit_cd        = a.unit_cd
   AND    b.version_number = a.version_number
   AND    b.org_unit_cd    = ihpou.oss_org_unit_cd
   AND    a.unit_cd        = hunt.unit_cd (+)
   AND    a.version_number = hunt.version_number (+)
   AND    NVL(hunt.exclude_flag, 'N') = 'N'
   AND    ihpou.institution_cd = ihpinst.oss_org_unit_cd
   AND    NVL(ihpinst.oi_local_institution_ind,'N') = 'N'
   AND    e.unit_cd = a.unit_cd
   AND    e.version_number = a.version_number
   AND    a.uoo_id = cps.uoo_id(+)
   AND    a.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
   AND    a.ci_start_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt ;

   CURSOR c_total_cp IS
   SELECT   SUM( NVL(override_enrolled_cp,NVL(cps.enrolled_credit_points,e.enrolled_credit_points))) Total_credit_points
   FROM   igs_en_su_attempt  a,
          igs_ps_unit_ver e,
          igs_ps_usec_cps cps,
          igs_he_st_unt_vs_all hunt
   WHERE  a.course_cd      = p_course_cd
   AND    a.person_id      = p_person_id
   AND    a.unit_cd        = hunt.unit_cd (+)
   AND    a.version_number = hunt.version_number (+)
   AND    NVL(hunt.exclude_flag, 'N') = 'N'
   AND    e.unit_cd = a.unit_cd
   AND    e.version_number = a.version_number
   AND    a.uoo_id = cps.uoo_id(+)
   AND    a.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
   AND    a.ci_start_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt ;

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_other_inst   c_other_inst_cp%ROWTYPE  ;
   l_total_cp     c_total_cp%ROWTYPE  ;

   BEGIN
   l_total_cp:= NULL;
    l_other_inst := NULL;

      IF p_program_calc = 'Y'
      THEN
          -- Program Based Calculations
          p_hesa_prop := Nvl(Nvl(p_susa_prop, p_poous_prop), p_prog_prop);

      ELSE
          -- Unit Based Calculations
          OPEN  c_other_inst_cp ;
          FETCH c_other_inst_cp INTO l_other_inst;
          CLOSE c_other_inst_cp;

          OPEN  c_total_cp ;
          FETCH c_total_cp INTO l_total_cp;
          CLOSE c_total_cp;

          -- smaddali added the condition that total_credit_points should not be 0 for bug 2716038
          IF l_total_cp.total_credit_points <> 0 THEN
              p_hesa_prop := (l_other_inst.other_inst_cp * 100 )/ l_total_cp.total_credit_points ;
          END IF ;

      END IF; -- Program / unit based calculations

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_other_inst_cp%ISOPEN
          THEN
              CLOSE c_other_inst_cp;
          END IF;

          IF c_total_cp%ISOPEN
          THEN
              CLOSE c_total_cp;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_prop_not_taught');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_prop_not_taught;



   PROCEDURE get_credit_trans_sch
          (p_oss_credit_trans_sch     IN  igs_he_st_prog.credit_transfer_scheme%TYPE,
           p_hesa_credit_trans_sch    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Credit Transfer Scheme
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     fmak      19-Jan-05    Modified association code reference from OSS_HESA_CRDSTCM_ASSOC
                            to OSS_HESA_CRDTSCM_ASSOC for bug 3842077
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- fmak modified for bug 3842077
      l_he_code_map_val.association_code := 'OSS_HESA_CRDTSCM_ASSOC';
      l_he_code_map_val.map2             := p_oss_credit_trans_sch;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_credit_trans_sch);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_credit_trans_sch');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_credit_trans_sch;



   PROCEDURE get_credit_level
          (p_susa_credit_level    IN igs_he_en_susa.credit_level1%TYPE ,
           p_poous_credit_level     IN  igs_he_poous.level_credit1%TYPE,
           p_hesa_credit_level    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the level of Credit
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When        What
     smaddali              Added extra parameter p_susa_credit_level for bug 2415879
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_LEVLCRD_ASSOC';
      l_he_code_map_val.map2             := NVL(p_susa_credit_level,p_poous_credit_level);

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_credit_level);

      END IF;

    EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_credit_level');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_credit_level;


   PROCEDURE get_credit_obtained
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_prog_calc             IN  igs_he_st_prog.program_calc%TYPE,
           p_susa_crd_pt1          IN  igs_he_en_susa.credit_pt_achieved1%TYPE,
           p_susa_crd_pt2          IN  igs_he_en_susa.credit_pt_achieved2%TYPE,
           p_susa_crd_pt3          IN  igs_he_en_susa.credit_pt_achieved3%TYPE,
           p_susa_crd_pt4          IN  igs_he_en_susa.credit_pt_achieved4%TYPE,
           p_susa_crd_lvl1         IN  igs_he_en_susa.credit_level_achieved1%TYPE,
           p_susa_crd_lvl2         IN  igs_he_en_susa.credit_level_achieved2%TYPE,
           p_susa_crd_lvl3         IN  igs_he_en_susa.credit_level_achieved3%TYPE,
           p_susa_crd_lvl4         IN  igs_he_en_susa.credit_level_achieved4%TYPE,
           p_no_crd_pt1            OUT NOCOPY VARCHAR2,
           p_no_crd_pt2            OUT NOCOPY VARCHAR2,
           p_no_crd_pt3            OUT NOCOPY VARCHAR2,
           p_no_crd_pt4            OUT NOCOPY VARCHAR2,
           p_lvl_crd_pt1           OUT NOCOPY VARCHAR2,
           p_lvl_crd_pt2           OUT NOCOPY VARCHAR2,
           p_lvl_crd_pt3           OUT NOCOPY VARCHAR2,
           p_lvl_crd_pt4           OUT NOCOPY VARCHAR2,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Number of Credit Points obtained, level of credit points obtained
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When        What
     sarakshi  27-Jun-2003 Enh#2930935,modified the cursor c_cp to include the usec level enrolled credit
                           points if exists else from the unit level
     smaddali              added extra parameter p_susa_credit_level for bug 2415879
     jbaber    20-Sep-2004 HEFD350 - Stat changes for 2004/05
                           Expanded to derive new fields CPOBTN3, CPOBTN4, LCPOBTN3 and LCPOBTN4
     jbaber    19-Jan-2006 Exclude flagged units for HE305 - Extract Improvements
   ***************************************************************/

   --smaddali modified this cursor to consider unit level credit points also for bug 2415811
   CURSOR c_cp IS
   SELECT  SUM( NVL(override_enrolled_cp,NVL(cps.enrolled_credit_points,b.enrolled_credit_points)) ) credit_points, b.unit_level
   FROM   igs_en_su_attempt a ,
          igs_ps_unit_ver   b,
          igs_ps_usec_cps cps,
          igs_he_st_unt_vs_all hunt
   WHERE  a.course_cd      = p_course_cd
   AND    a.person_id      = p_person_id
   AND    a.unit_cd        = b.unit_cd
   AND    a.version_number = b.version_number
   AND    a.unit_cd        = hunt.unit_cd (+)
   AND    a.version_number = hunt.version_number (+)
   AND    NVL(hunt.exclude_flag, 'N') = 'N'
   AND    a.uoo_id = cps.uoo_id(+)
   AND    a.unit_attempt_status = 'COMPLETED'
   AND    a.ci_start_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt
   GROUP BY b.unit_level
   ORDER BY credit_points DESC;

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_lvl1                   igs_ps_unit_ver.unit_level%TYPE;
   l_lvl2                   igs_ps_unit_ver.unit_level%TYPE;
   l_lvl3                   igs_ps_unit_ver.unit_level%TYPE;
   l_lvl4                   igs_ps_unit_ver.unit_level%TYPE;

   BEGIN
      IF p_prog_calc = 'N'
      THEN
          OPEN c_cp;
          FETCH c_cp INTO p_no_crd_pt1, l_lvl1;
          FETCH c_cp INTO p_no_crd_pt2, l_lvl2;
          FETCH c_cp INTO p_no_crd_pt3, l_lvl3;
          FETCH c_cp INTO p_no_crd_pt4, l_lvl4;
          CLOSE c_cp;

          -- Level of Credit Points obtained 1
          igs_he_extract_fields_pkg.get_credit_level
              (p_susa_credit_level   => NULL ,
               p_poous_credit_level     => l_lvl1,
               p_hesa_credit_level    => p_lvl_crd_pt1);

          -- Level of Credit Points obtained 2
          igs_he_extract_fields_pkg.get_credit_level
              (p_susa_credit_level   => NULL ,
               p_poous_credit_level     => l_lvl2,
               p_hesa_credit_level    => p_lvl_crd_pt2);

          -- Level of Credit Points obtained 3
          igs_he_extract_fields_pkg.get_credit_level
              (p_susa_credit_level   => NULL ,
               p_poous_credit_level     => l_lvl3,
               p_hesa_credit_level    => p_lvl_crd_pt3);

          -- Level of Credit Points obtained 4
          igs_he_extract_fields_pkg.get_credit_level
              (p_susa_credit_level   => NULL ,
               p_poous_credit_level     => l_lvl4,
               p_hesa_credit_level    => p_lvl_crd_pt4);

      ELSE
          -- Unit Based Calculations
          p_no_crd_pt1   := p_susa_crd_pt1;
          p_no_crd_pt2   := p_susa_crd_pt2;
          p_no_crd_pt3   := p_susa_crd_pt3;
          p_no_crd_pt4   := p_susa_crd_pt4;

          -- Level of Credit Points obtained 1
          igs_he_extract_fields_pkg.get_credit_level
              (p_susa_credit_level   => NULL ,
               p_poous_credit_level     => p_susa_crd_lvl1,
               p_hesa_credit_level    => p_lvl_crd_pt1);

          -- Level of Credit Points obtained 2
          igs_he_extract_fields_pkg.get_credit_level
              (p_susa_credit_level   => NULL ,
               p_poous_credit_level     => p_susa_crd_lvl2,
               p_hesa_credit_level    => p_lvl_crd_pt2);

          -- Level of Credit Points obtained 3
          igs_he_extract_fields_pkg.get_credit_level
              (p_susa_credit_level   => NULL ,
               p_poous_credit_level     => p_susa_crd_lvl3,
               p_hesa_credit_level    => p_lvl_crd_pt3);

          -- Level of Credit Points obtained 4
          igs_he_extract_fields_pkg.get_credit_level
              (p_susa_credit_level   => NULL ,
               p_poous_credit_level     => p_susa_crd_lvl4,
               p_hesa_credit_level    => p_lvl_crd_pt4);

      END IF ; -- Program / Unit Based calculations

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_cp%ISOPEN
          THEN
              CLOSE c_cp;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_credit_obtained');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_credit_obtained;


 PROCEDURE get_cost_centres
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_en_stdnt_ps_att.course_cd%TYPE,
           p_version_number        IN  igs_en_stdnt_ps_att.version_number%TYPE,
           p_unit_set_cd           IN  igs_he_poous.unit_set_cd%TYPE,
           p_us_version_number     IN  igs_he_poous.us_version_number%TYPE,
           p_cal_type              IN  igs_he_poous.cal_type%TYPE,
           p_attendance_mode       IN  igs_he_poous.attendance_mode%TYPE,
           p_attendance_type       IN  igs_he_poous.attendance_type%TYPE,
           p_location_cd           IN  igs_he_poous.location_cd%TYPE,
           p_program_calc          IN  igs_he_st_prog.program_calc%TYPE,
           p_unit_cd               IN  igs_he_st_unt_vs.unit_cd%TYPE,
           p_uv_version_number     IN  igs_he_st_unt_vs.version_number%TYPE,
           p_return_type           IN  VARCHAR2,
           p_cost_ctr_rec          IN OUT NOCOPY cc_rec,
           p_total_recs            OUT NOCOPY NUMBER,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE,
           p_sequence_number       IN  NUMBER,
           p_validation_country    IN  igs_he_submsn_header.validation_country%TYPE) IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Cost Centres, Subjects for each and their proportions.
                            This procedure is used for  Combined Return and Module Return
     Known Limitations,Enhancements or Remarks:
     Change History       :
     WHO       WHEN         WHAT
     smaddali               Bug 241745 modified the dynamic cursors for unit cost centres , to consider enrolled credit points as per the HLD
     smaddali               Modified procedure to remove use of enrolled_credit points ,for bug 2668966
     ayedubat 26-AUG-2003   Changed the the procedure to use the Cost Centers defined at
                            Program Level, Student Program Attempt Level and Student Unit Set Attempt Level
                            as  part of HE207FD - Override Cost Center Enhancement bug, 2717753
     jbaber   20-Sep-2004   Changes as per HEFD350 - Stat changes for 2004/05
                            Added p_validation_country parameter
     jbaber   27-Jan-2005   Changes as per HEFD355 - Org Unit Cost Center Link
     jbaber   19-Jan-2006   Exclude flagged units for HE305 - Extract Improvements
     jchakrab 21-Feb-2006   Modified for R12 Performance Enhs(4950293) - removed literal SQL
   ***************************************************************/

   l_sql_stmt               VARCHAR2(2000);
   l_index                  NUMBER;
   l_total_prop             NUMBER := 0;
   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_poous_cc               igs_he_poous_ou_cc%ROWTYPE;
   l_max_recs               NUMBER;

   TYPE cur_cc  IS REF CURSOR;
   c_cc  cur_cc;

   --smaddali added this cursor for bug 2417454 to get the govt code for oss field of study
   CURSOR c_field_of_study(p_subject  igs_he_poous_ou_cc.subject%TYPE) IS
   SELECT govt_field_of_study
   FROM   IGS_PS_FLD_OF_STUDY PFS
   WHERE  field_of_study = p_subject;

    -- Cost Centers at Student Unit Set Attempt Level
    CURSOR susa_cc_dtls_cur(cp_person_id IGS_HE_EN_SUSA_CC.person_id%TYPE,
                            cp_course_cd IGS_HE_EN_SUSA_CC.course_cd%TYPE,
                            cp_unit_set_cd IGS_HE_EN_SUSA_CC.unit_set_cd%TYPE,
                            cp_sequence_number IGS_HE_EN_SUSA_CC.sequence_number%TYPE) IS
      SELECT 'X'
      FROM IGS_HE_EN_SUSA_CC
      WHERE person_id = cp_person_id
        AND course_cd = cp_course_cd
        AND unit_set_cd = cp_unit_set_cd
        AND sequence_number = cp_sequence_number;

    -- Cost Centers at Student Program Attempt Level
    CURSOR spa_cc_dtls_cur(cp_person_id IGS_HE_ST_SPA_CC.person_id%TYPE,
                           cp_course_cd IGS_HE_ST_SPA_CC.course_cd%TYPE) IS
      SELECT 'X'
      FROM IGS_HE_ST_SPA_CC
      WHERE person_id = cp_person_id
        AND course_cd = cp_course_cd;

    -- Cost Centers at Program Offering Option Level
    CURSOR poo_cc_dtls_cur( cp_course_cd          IGS_HE_POOUS_OU_ALL.course_cd%TYPE,
                            cp_crv_version_number IGS_HE_POOUS_OU_ALL.crv_version_number%TYPE,
                            cp_unit_set_cd        IGS_HE_POOUS_OU_ALL.unit_set_cd%TYPE,
                            cp_us_version_number  IGS_HE_POOUS_OU_ALL.us_version_number%TYPE,
                            cp_cal_type           IGS_HE_POOUS_OU_ALL.cal_type%TYPE,
                            cp_attendance_mode    IGS_HE_POOUS_OU_ALL.attendance_mode%TYPE,
                            cp_attendance_type    IGS_HE_POOUS_OU_ALL.attendance_type%TYPE,
                            cp_location_cd        IGS_HE_POOUS_OU_ALL.location_cd%TYPE ) IS
      SELECT 'X'
      FROM IGS_HE_POOUS_OU_CC pocc,
           IGS_HE_POOUS_OU_ALL poou
      WHERE poou.hesa_poous_ou_id = pocc.hesa_poous_ou_id
        AND poou.course_cd = cp_course_cd
        AND poou.crv_version_number = cp_crv_version_number
        AND poou.unit_set_cd       = cp_unit_set_cd
        AND poou.us_version_number = cp_us_version_number
        AND poou.cal_type  = cp_cal_type
        AND poou.attendance_mode  = cp_attendance_mode
        AND poou.attendance_type  = cp_attendance_type
        AND poou.location_cd      = cp_location_cd;

     -- Cost Centers at POOUS / ORG Level
     CURSOR poo_org_cc_dtls_cur IS
      SELECT 'X'
      FROM
          igs_he_ou_cc org,
          igs_he_poous_ou_all poo
      WHERE
          org.org_unit_cd = poo.organization_unit
      AND poo.course_cd = p_course_cd
      AND poo.crv_version_number = p_version_number
      AND poo.unit_set_cd        = p_unit_set_cd
      AND poo.us_version_number  = p_us_version_number
      AND poo.cal_type           = p_cal_type
      AND poo.attendance_mode    = p_attendance_mode
      AND poo.attendance_type    = p_attendance_type
      AND poo.location_cd        = p_location_cd;


    -- Cost Centers at Program Version Level
    CURSOR prg_cc_dtls_cur( cp_course_cd      IGS_HE_PROG_OU_CC.course_cd%TYPE,
                            cp_version_number IGS_HE_PROG_OU_CC.version_number%TYPE) IS
      SELECT 'X'
      FROM
          IGS_HE_PROG_OU_CC pcc,
          IGS_PS_OWN pown
      WHERE
          pcc.course_cd = p_course_cd
      AND pcc.version_number = p_version_number
      AND pcc.course_cd = pown.course_cd
      AND pcc.version_number = pown.version_number
      AND pcc.org_unit_cd = pown.org_unit_cd;


    -- Cost Centers at Program / Org Level
    CURSOR prg_org_cc_dtls_cur IS
      SELECT 'X'
      FROM
          igs_he_ou_cc org,
          igs_ps_own ps
      WHERE
          org.org_unit_cd = ps.org_unit_cd
      AND ps.course_cd = p_course_cd
      AND ps.version_number = p_version_number;


    -- Cost Centers at Unit Level
    CURSOR unit_cc_dtls_cur IS
      SELECT 'X'
      FROM   igs_he_unt_ou_cc   a,
             igs_en_su_attempt_all b,
             igs_ps_tch_resp c,
             igs_he_st_unt_vs_all hunt
      WHERE  b.course_cd      = p_course_cd
      AND    b.person_id      = p_person_id
      AND    a.unit_cd        = b.unit_cd
      AND    a.version_number = b.version_number
      AND    b.unit_cd        = hunt.unit_cd (+)
      AND    b.version_number = hunt.version_number (+)
      AND    NVL(hunt.exclude_flag, 'N') = 'N'
      AND    b.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
      AND    c.unit_cd = a.unit_cd
      AND    c.version_number = a.version_number
      AND    c.org_unit_cd = a.org_unit_cd
      AND    b.ci_start_dt BETWEEN  p_enrl_start_dt  AND  p_enrl_end_dt;

    -- Cost Centers at Unit / Org  Level
    CURSOR unit_org_cc_dtls_cur IS
      SELECT 'X'
      FROM
          igs_he_ou_cc org,
          igs_ps_tch_resp ps,
          igs_en_su_attempt_all su
      WHERE
          org.org_unit_cd = ps.org_unit_cd
      AND ps.unit_cd = su.unit_cd
      AND ps.version_number = su.version_number
      AND su.person_id = p_person_id
      AND su.course_cd = p_course_cd
      AND su.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
      AND su.ci_start_dt BETWEEN  p_enrl_start_dt  AND  p_enrl_end_dt;

    -- Cost Centers at Module Level
    CURSOR module_cc_dtls_cur IS
      SELECT 'X'
      FROM   igs_he_unt_ou_cc ucc,
             igs_ps_tch_resp ptr
      WHERE  ucc.unit_cd = p_unit_cd
      AND    ucc.version_number = p_uv_version_number
      AND    ucc.unit_cd = ptr.unit_cd
      AND    ucc.version_number = ptr.version_number
      AND    ucc.org_unit_cd = ptr.org_unit_cd;

  -- Cost Centers at Module / Org  Level
   CURSOR module_org_cc_dtls_cur IS
     SELECT 'X'
     FROM   igs_he_ou_cc org,
            igs_ps_tch_resp ptr
     WHERE  ptr.unit_cd = p_unit_cd
     AND    ptr.version_number = p_uv_version_number
     AND    ptr.org_unit_cd = org.org_unit_cd;

    l_dummy VARCHAR2(1);

   BEGIN

      l_index      := 1;
      p_total_recs := 0;
      l_sql_stmt := NULL;

      IF  p_return_type IN ('S','C') AND p_program_calc = 'Y'   THEN

          -- Student Combined, Non Modular program
          -- get the 16 highest proportions from poous cost centres
          l_max_recs := 16;

          -- Check whether the Cost Center details are defined at Student Unit Set Attempt Level
          -- If Cost Centers are defined at this level
          OPEN susa_cc_dtls_cur( p_person_id, p_course_cd, p_unit_set_cd, p_sequence_number );
          FETCH susa_cc_dtls_cur INTO l_dummy;

          IF susa_cc_dtls_cur%FOUND THEN
            CLOSE susa_cc_dtls_cur;

            OPEN c_cc FOR
            SELECT cost_centre, subject, proportion
            FROM igs_he_en_susa_cc
            WHERE person_id = p_person_id
               AND course_cd = p_course_cd
               AND unit_set_cd = p_unit_set_cd
               AND sequence_number = p_sequence_number
            ORDER BY proportion DESC;

          ELSE /* If cost centers are not defined at student unit set attempt level */
            CLOSE susa_cc_dtls_cur;

            --Check whether the Cost Center details are defined at Student Program Attempt Level
            OPEN spa_cc_dtls_cur( p_person_id, p_course_cd );
            FETCH spa_cc_dtls_cur INTO l_dummy;

            IF spa_cc_dtls_cur%FOUND THEN
              CLOSE spa_cc_dtls_cur;

              OPEN c_cc FOR
              SELECT cost_centre, subject, proportion
              FROM igs_he_st_spa_cc
              WHERE person_id = p_person_id
              AND course_cd = p_course_cd
              ORDER BY proportion DESC;

            ELSE /* If cost centers are not defined at Student Program Attempt level */
              CLOSE spa_cc_dtls_cur;

              --Check whether the Cost Center details are defined at Program Offering Option Level
              OPEN poo_cc_dtls_cur( p_course_cd, p_version_number, p_unit_set_cd, p_us_version_number,
                                    p_cal_type, p_attendance_mode, p_attendance_type, p_location_cd );
              FETCH poo_cc_dtls_cur INTO l_dummy;

              IF poo_cc_dtls_cur%FOUND THEN
                CLOSE poo_cc_dtls_cur;

                OPEN c_cc FOR
                SELECT cost_centre, subject, SUM (pocc.proportion*NVL(poou.proportion,0)/100) proportion
                FROM igs_he_poous_ou_cc pocc,
                     igs_he_poous_ou_all poou
                WHERE poou.hesa_poous_ou_id = pocc.hesa_poous_ou_id
                      AND poou.course_cd = p_course_cd
                      AND poou.crv_version_number = p_version_number
                      AND poou.unit_set_cd = p_unit_set_cd
                      AND poou.us_version_number = p_us_version_number
                      AND poou.cal_type = p_cal_type
                      AND poou.attendance_mode = p_attendance_mode
                      AND poou.attendance_type = p_attendance_type
                      AND poou.location_cd = p_location_cd
                GROUP BY cost_centre, subject
                ORDER BY proportion DESC;

              ELSE /* If cost centers are not defined at Program Offering Option level */
                CLOSE poo_cc_dtls_cur;


                --Check whether the Cost Center details are defined at POOUS / Org Level
                OPEN poo_org_cc_dtls_cur;
                FETCH poo_org_cc_dtls_cur INTO l_dummy;

                IF poo_org_cc_dtls_cur%FOUND THEN
                  CLOSE poo_org_cc_dtls_cur;

                  OPEN c_cc FOR
                  SELECT org.cost_centre,
                         org.subject,
                         SUM((NVL(poo.proportion,0) * org.proportion / 100)) proportion
                  FROM igs_he_ou_cc org,
                       igs_he_poous_ou_all poo
                  WHERE org.org_unit_cd = poo.organization_unit
                        AND poo.course_cd = p_course_cd
                        AND poo.crv_version_number = p_version_number
                        AND poo.unit_set_cd = p_unit_set_cd
                        AND poo.us_version_number  = p_us_version_number
                        AND poo.cal_type = p_cal_type
                        AND poo.attendance_mode = p_attendance_mode
                        AND poo.attendance_type = p_attendance_type
                        AND poo.location_cd = p_location_cd
                  GROUP BY org.cost_centre, org.subject
                  ORDER BY proportion DESC;

                ELSE /* If cost centers are not defined at POOUS  / Org level */
                  CLOSE poo_org_cc_dtls_cur ;

                  --Check whether the Cost Center details are defined at Program Level
                  OPEN prg_cc_dtls_cur( p_course_cd, p_version_number );
                  FETCH prg_cc_dtls_cur INTO l_dummy;

                  IF prg_cc_dtls_cur%FOUND THEN
                    CLOSE prg_cc_dtls_cur;

                    OPEN c_cc FOR
                    SELECT cost_centre, subject, SUM(proportion*percentage/100) proportion
                    FROM igs_he_prog_ou_cc pcc,
                         igs_ps_own pown
                    WHERE pcc.course_cd = p_course_cd
                          AND pcc.version_number = p_version_number
                          AND pcc.course_cd = pown.course_cd
                          AND pcc.version_number = pown.version_number
                          AND pcc.org_unit_cd = pown.org_unit_cd
                    GROUP BY cost_centre, subject
                    ORDER BY proportion DESC;

                  ELSE /* If cost centers are not defined at Program level */
                    CLOSE prg_cc_dtls_cur;

                      --Check whether the Cost Center details are defined at Program Level
                      OPEN prg_org_cc_dtls_cur;
                      FETCH prg_org_cc_dtls_cur INTO l_dummy;

                      IF prg_org_cc_dtls_cur%FOUND THEN

                        OPEN c_cc FOR
                        SELECT org.cost_centre,
                               org.subject,
                               SUM(ps.percentage * org.proportion / 100) proportion
                        FROM igs_he_ou_cc org,
                             igs_ps_own ps
                        WHERE org.org_unit_cd = ps.org_unit_cd
                              AND ps.course_cd = p_course_cd
                              AND ps.version_number = p_version_number
                        GROUP BY org.cost_centre, org.subject
                        ORDER BY proportion DESC;

                      END IF;
                      CLOSE prg_org_cc_dtls_cur;

                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;

      ELSIF  p_return_type IN ('S','C')   AND    p_program_calc = 'N'   THEN

          --- Unit Based calculation , get 16 highest proportions from unit cost centres
          -- consider unique cost centre ,subject combinations only
          l_max_recs := 16;

          -- Check whether the Cost Center details are defined at Unit  Level
          -- If Cost Centers are defined at this level
          OPEN unit_cc_dtls_cur;
          FETCH unit_cc_dtls_cur INTO l_dummy;

          IF unit_cc_dtls_cur%FOUND THEN
            CLOSE unit_cc_dtls_cur;

            -- smaddali modified this cursor to include unit credit points and taking proportion of unit credit
            --points instead of directly the proportion field of cost centre
            OPEN c_cc FOR
            SELECT a.cost_centre,
                   a.subject,
                   SUM(proportion*percentage/100) proportion
            FROM   igs_he_unt_ou_cc   a,
                   igs_en_su_attempt_all b,
                   igs_ps_tch_resp c,
                   igs_he_st_unt_vs_all hunt
            WHERE  b.course_cd = p_course_cd
                   AND    b.person_id = p_person_id
                   AND    a.unit_cd = b.unit_cd
                   AND    a.version_number = b.version_number
                   AND    c.unit_cd = a.unit_cd
                   AND    c.version_number = a.version_number
                   AND    c.org_unit_cd = a.org_unit_cd
                   AND    b.unit_cd = hunt.unit_cd(+)
                   AND    b.version_number = hunt.version_number(+)
                   AND    NVL(hunt.exclude_flag, 'N') = 'N'
                   AND    b.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
                   AND    b.ci_start_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt
            GROUP BY a.cost_centre, a.subject
            ORDER BY proportion DESC;


          ELSE /* If cost centers are not defined at unit level */
            CLOSE unit_cc_dtls_cur;

            OPEN unit_org_cc_dtls_cur;
            FETCH unit_org_cc_dtls_cur INTO l_dummy;

            IF unit_org_cc_dtls_cur%FOUND THEN

              OPEN c_cc FOR
              SELECT org.cost_centre,
                     org.subject,
                     SUM(ps.percentage * org.proportion / 100) proportion
              FROM igs_he_ou_cc org,
                   igs_ps_tch_resp ps,
                   igs_en_su_attempt_all su
              WHERE org.org_unit_cd = ps.org_unit_cd
                    AND ps.unit_cd = su.unit_cd
                    AND ps.version_number = su.version_number
                    AND su.person_id = p_person_id
                    AND su.course_cd = p_course_cd
                    AND su.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
                    AND su.ci_start_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt
              GROUP BY org.cost_centre, org.subject
              ORDER BY proportion DESC;
            END IF;
            CLOSE unit_org_cc_dtls_cur;

          END IF;


      ELSIF  p_return_type = 'M'   THEN
          --- Module Return, get 2 highest proportions from unit cost centres
          -- jbaber - HEFD350 get 4 highest proportions if validation country is SCOTLAND
          IF p_validation_country IN ('SCOTLAND') THEN
              l_max_recs := 4;
          ELSE
              l_max_recs := 2;
          END IF;


          OPEN module_cc_dtls_cur;
          FETCH module_cc_dtls_cur INTO l_dummy;
          IF module_cc_dtls_cur%FOUND THEN

              CLOSE module_cc_dtls_cur;

              -- smaddali modified this cursor to include unit credit points and taking proportion of unit credit points
              -- instead of directly the proportion field of cost centre
              -- jbaber modified to use igs_he_unt_ou_cc
              OPEN c_cc FOR
              SELECT cost_centre,
                     subject,
                     SUM(proportion*percentage/100) proportion
              FROM   igs_he_unt_ou_cc ucc,
                     igs_ps_tch_resp ptr
              WHERE  ucc.unit_cd = p_unit_cd
                     AND ucc.version_number = p_uv_version_number
                     AND ucc.unit_cd = ptr.unit_cd
                     AND ucc.version_number = ptr.version_number
                     AND ucc.org_unit_cd = ptr.org_unit_cd
              GROUP BY cost_centre, subject
              ORDER BY proportion DESC;

          ELSE
              CLOSE module_cc_dtls_cur;

              OPEN module_org_cc_dtls_cur;
              FETCH module_org_cc_dtls_cur INTO l_dummy;

              IF module_org_cc_dtls_cur%FOUND THEN

                  OPEN c_cc FOR
                  SELECT cost_centre,
                         subject,
                         SUM(proportion*percentage/100) proportion
                  FROM   igs_he_ou_cc org,
                         igs_ps_tch_resp ptr
                  WHERE  ptr.unit_cd = p_unit_cd
                         AND ptr.version_number = p_uv_version_number
                         AND ptr.org_unit_cd = org.org_unit_cd
                  GROUP BY cost_centre, subject
                  ORDER BY proportion DESC;

              END IF;
              CLOSE module_org_cc_dtls_cur;

          END IF;
      END IF;

      -- Check whether the c_cc cursor has been opened for a query or its closed as no cost centers are defined
      IF c_cc%ISOPEN THEN

        LOOP
            FETCH c_cc INTO l_poous_cc.cost_centre,
                            l_poous_cc.subject,
                            l_poous_cc.proportion;
            EXIT WHEN c_cc%NOTFOUND OR l_index > l_max_recs ;

            l_he_code_map_val.association_code := 'OSS_HESA_COSTCN_ASSOC';
            l_he_code_map_val.map2             := l_poous_cc.cost_centre;

            igs_he_extract2_pkg.get_map_values
                                 (p_he_code_map_val   => l_he_code_map_val,
                                  p_value_from        => 'MAP1',
                                  p_return_value      => p_cost_ctr_rec.cost_centre(l_index));

             -- smaddali replaced the code using association code 'OSS_HESA_SBJ_ASSOC' with this cursor for bug 2417454
             OPEN  c_field_of_study(l_poous_cc.subject);
             FETCH c_field_of_study INTO p_cost_ctr_rec.subject(l_index)  ;
             CLOSE c_field_of_study;

             p_cost_ctr_rec.proportion(l_index)  := l_poous_cc.proportion;
             -- keep a total of the proportions
             l_total_prop := l_total_prop + l_poous_cc.proportion;
             l_index := l_index + 1;
        END LOOP;
        CLOSE c_cc;

      END IF;

      -- Decrease count as it would be one more than total recs
      l_index := l_index - 1;

      -- Apportion the proportions so that their sum will be 100
      FOR   i IN 1 .. l_index
      LOOP
              p_cost_ctr_rec.proportion(i) :=
                        (p_cost_ctr_rec.proportion(i) * 100 ) / l_total_prop;
      END LOOP;
      -- total cost centres found
      p_total_recs := l_index  ;

   EXCEPTION
      WHEN OTHERS  THEN
          write_to_log (SQLERRM);

          IF c_cc%ISOPEN    THEN
              CLOSE c_cc;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_cost_centres');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_cost_centres;

   PROCEDURE get_studies_susp
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_enrl_start_dt         IN  DATE,
           p_enrl_end_dt           IN  DATE,
           p_susp_act_std          OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Suspension of Active Studies flag
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     AYEDUBAT  29-04-04    Changed the cursor, c_susp to add a new condition to check
                           for approved intermissions, if approval is required for Bug, 3494224
     rnirwani  13-09-04    Changed the cursor, c_susp to exclude logically deleted intermission
                           records as per Bug# 3885804
     jbaber    30-11-04    Consider mutiple intermission records for bug# 4037237
                           Now calls isDormant function
   ***************************************************************/

   CURSOR c_susp IS
   SELECT start_dt,
          end_dt
   FROM   igs_en_stdnt_ps_intm spi
   WHERE  spi.person_id  =  p_person_id
   AND    spi.course_cd  =  p_course_cd
   AND    spi.start_dt <= p_enrl_end_dt
   AND    spi.end_dt  >= p_enrl_end_dt
   AND    spi.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
   AND    (spi.approved = 'Y' OR
          EXISTS( SELECT 1 FROM igs_en_intm_types
                  WHERE intermission_type = spi.intermission_type AND
                  appr_reqd_ind = 'N' ));

   CURSOR c_spa_dt IS
   SELECT commencement_dt,
          discontinued_dt,
          course_rqrmnts_complete_dt
   FROM   igs_en_stdnt_ps_att_all
   WHERE  person_id = p_person_id
   AND    course_cd = p_course_cd
   AND    version_number = p_version_number;

   l_spa_dt           c_spa_dt%ROWTYPE;

   l_intm_start_dt    DATE;
   l_intm_end_dt      DATE;

   BEGIN

      -- Return 1 if the student begins intermission during the reporting period
      -- and is intermitted during the reporting period end date.
      -- Student must not be dormant throughout entire period.
      -- Course requirements complete date and discontinued date must be greater than
      -- reporting period end date.

      IF isDormant
          (p_person_id        => p_person_id,
           p_course_cd        => p_course_cd,
           p_version_number   => p_version_number,
           p_enrl_start_dt    => p_enrl_start_dt,
           p_enrl_end_dt      => p_enrl_end_dt)
      THEN
          p_susp_act_std := NULL;
      ELSE

          OPEN c_spa_dt;
          FETCH c_spa_dt INTO l_spa_dt;
          CLOSE c_spa_dt;

          IF     (NVL(l_spa_dt.discontinued_dt, p_enrl_end_dt) < p_enrl_end_dt)
              OR (NVL(l_spa_dt.course_rqrmnts_complete_dt, p_enrl_end_dt) < p_enrl_end_dt)
          THEN
              p_susp_act_std := NULL;
          ELSE


             OPEN c_susp;
             FETCH c_susp INTO l_intm_start_dt,
                               l_intm_end_dt;

             IF c_susp%FOUND
             THEN
                 -- smaddali making p_susp_act_std =1 when student started intermission in the
                 -- submission period but did not complete within the submission period
                 -- and null otherwise, for bug#3306455
                 p_susp_act_std := '1';
             ELSE
                 p_susp_act_std := NULL;
             END IF;

             CLOSE c_susp ;

          END IF;

       END IF; -- isDormant


      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_susp%ISOPEN
          THEN
              CLOSE c_susp;
          END IF;

          IF c_spa_dt%ISOPEN
          THEN
              CLOSE c_susp;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_studies_susp');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_studies_susp;


   PROCEDURE get_pyr_type
          (p_oss_pyr_type     IN  igs_he_poous.type_of_year%TYPE,
           p_hesa_pyr_type    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the type of program year
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_TYPEYR_ASSOC';
      l_he_code_map_val.map2             := p_oss_pyr_type;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_pyr_type);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_pyr_type');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_pyr_type;


   PROCEDURE get_lvl_appl_to_fund
          (p_poous_lvl_appl_fund   IN  igs_he_poous.level_applicable_to_funding%TYPE,
           p_prg_lvl_appl_fund     IN  igs_he_st_prog.level_applicable_to_funding%TYPE,
           p_hesa_lvl_appl_fund    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Level applicable to HESA Funding Council
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_FUNDLEV_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_poous_lvl_appl_fund,
                                                p_prg_lvl_appl_fund);

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_lvl_appl_fund);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_lvl_appl_to_fund');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_lvl_appl_to_fund;


  PROCEDURE get_comp_pyr_study(
    p_susa_comp_pyr_study   IN  igs_he_en_susa.complete_pyr_study_cd%TYPE,
    p_fundlev               IN  VARCHAR2,
    p_spcstu                IN  VARCHAR2,
    p_notact                IN  VARCHAR2,
    p_mode                  IN  VARCHAR2,
    p_typeyr                IN  VARCHAR2,
    p_crse_rqr_complete_ind IN  igs_en_stdnt_ps_att.course_rqrmnt_complete_ind%TYPE,
    p_crse_req_complete_dt  IN  igs_en_stdnt_ps_att.course_rqrmnts_complete_dt%TYPE,
    p_disc_reason_cd        IN  igs_en_stdnt_ps_att.discontinuation_reason_cd%TYPE,
    p_discont_dt            IN  igs_en_stdnt_ps_att.discontinued_dt%TYPE,
    p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
    p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
    p_person_id             IN  igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd             IN  igs_en_stdnt_ps_att.course_cd%TYPE,
    p_hesa_comp_pyr_study   OUT NOCOPY VARCHAR2) IS
  /***************************************************************
   Created By           :
   Date Created By      :
   Purpose              : This procedure gets completion of year of program of study
   Known Limitations,Enhancements or Remarks:
   Change History       :
   WHO       WHEN       WHAT
  ayedubat  16-MAR-04  Changed the whole logic for FUNDCOMP field derivation as
                       part of HEFD311 - July 2004 Changes enhancement Bug, 2956444
  ayedubat  15-JUN-04  Changed the logic to derive the latest progression outcome
                       type for the student program attempt Bug, 3675471
  jtmathew  01-FEB-06  Modified procedure to return 1 if student completed requirements
                       of program before or during the HESA reporting period
  ***************************************************************/

    l_he_code_map_val IGS_HE_CODE_MAP_VAL%ROWTYPE := NULL;
    l_progression_out_type IGS_PR_STDNT_PR_OU.progression_outcome_type%TYPE;
    l_prev_start_dt    IGS_CA_INST.start_dt%TYPE;
    l_prev_applied_dt  IGS_PR_STDNT_PR_OU.applied_dt%TYPE;
    l_prev_decision_dt IGS_PR_STDNT_PR_OU.decision_dt%TYPE;
    l_minimum_date DATE;

    -- Cursor to fetch the STudent Progression Outcome Type
    CURSOR cur_prog_out_type (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                              cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE,
                              cp_enrl_start_dt igs_he_submsn_header.enrolment_start_date%TYPE,
                              cp_enrl_end_dt   igs_he_submsn_header.enrolment_end_date%TYPE) IS
    SELECT progression_outcome_type,ca.start_dt , spo.decision_dt, spo.applied_dt
    FROM IGS_PR_STDNT_PR_OU spo,
         IGS_CA_INST ca
    WHERE spo.person_id = cp_person_id  AND
          spo.course_cd = cp_course_cd  AND
          -- Select Approved Progression Outcomes
          spo.decision_status = 'APPROVED' AND
          -- Select Progression Outcome records that overlap the HESA reporting period
          spo.prg_cal_type = ca. cal_type                 AND
          spo.prg_ci_sequence_number = ca.sequence_number AND
          ca.start_dt  <= cp_enrl_end_dt                  AND
          ca.end_dt    >= cp_enrl_start_dt
    -- If multiple outcome types records exist overlapping the HESA reporting period then use the progression
    -- record with latest progression calendar.
    -- If there are multiple approved outcome types for the same Period that have been applied then
    -- use the one with the latest Applied date and
    -- If multiple approved outcome types exist for the same Period that have been applied and
    -- have the same applied Applied date use the one with the latest Decision Date
    ORDER BY ca.start_dt DESC, spo.applied_dt DESC, spo.decision_dt DESC;

  BEGIN

    -- If Value exists for the completion of program year field at
    -- Student Unit Set Attempt HESA details Level
    IF p_susa_comp_pyr_study IS NOT NULL THEN

      l_he_code_map_val := NULL;
      l_he_code_map_val.association_code := 'OSS_HESA_FUNDCOMP_ASSOC';
      l_he_code_map_val.map2             :=  p_susa_comp_pyr_study;

      igs_he_extract2_pkg.get_map_values(
        p_he_code_map_val   => l_he_code_map_val,
        p_value_from        => 'MAP1',
        p_return_value      => p_hesa_comp_pyr_study);

    ELSE

      -- If the value of the field 154 - Level Applicable to Funding Council HESES (FUNDLEV) is '99'
      IF  p_fundlev = '99' THEN
        p_hesa_comp_pyr_study := '9';

      ELSE

        -- To cater for reporting requirements for visiting and exchange students
        -- If value exists for the field 28 - Special Students (SPCSTU) then
        IF p_spcstu IS NOT NULL THEN

          -- Get HESA mapped value from the mapping between SPCSTU and FUNDCOMP
          l_he_code_map_val := NULL;
          l_he_code_map_val.association_code := 'HESA_FUNDCOMP_SPCSTU_ASSOC';
          l_he_code_map_val.map2 := p_spcstu;

          igs_he_extract2_pkg.get_map_values(
            p_he_code_map_val   => l_he_code_map_val,
            p_value_from        => 'MAP1',
            p_return_value      => p_hesa_comp_pyr_study);

        END IF;

        -- If no value derived and value exists for the field 152 - Suspension of Active Studies (NOTACT)
        -- and field 153 - Type of Programme year(TYPEYR) then
        -- To cater for reporting requirements for suspended students
        IF p_hesa_comp_pyr_study IS NULL AND p_notact IS NOT NULL AND p_typeyr IS NOT NULL THEN

          -- Get HESA mapped value from the mapping between NOTACT, TYPEYR and FUNDCOMP
          l_he_code_map_val := NULL;
          l_he_code_map_val.association_code := 'HESA_FUNDCOMP_NOTACT_ASSOC';
          l_he_code_map_val.map2 := p_typeyr;
          l_he_code_map_val.map3 := p_notact;

          igs_he_extract2_pkg.get_map_values(
            p_he_code_map_val   => l_he_code_map_val,
            p_value_from        => 'MAP1',
            p_return_value      => p_hesa_comp_pyr_study);

        END IF;

        -- If no value derived for the FUNDCOMP field and value exists for field 70 - MODE and 153 - TYPEYR
        -- To cater for reporting requirements for dormant students
        IF p_hesa_comp_pyr_study IS NULL AND p_mode IS NOT NULL AND p_typeyr IS NOT NULL THEN

          -- Get HESA mapped value from the mapping between MODE, TYPEYR and FUNDCOMP
          l_he_code_map_val := NULL;
          l_he_code_map_val.association_code := 'HESA_FUNDCOMP_MODE_ASSOC';
          l_he_code_map_val.map2 := p_typeyr;
          l_he_code_map_val.map3 := p_mode;

          igs_he_extract2_pkg.get_map_values(
            p_he_code_map_val   => l_he_code_map_val,
            p_value_from        => 'MAP1',
            p_return_value      => p_hesa_comp_pyr_study);

        END IF;

        -- If no value derived for the FUNDCOMP field then
        IF p_hesa_comp_pyr_study IS NULL THEN

          -- If student has completed requirements of program before or during the HESA reporting period
          IF p_crse_rqr_complete_ind = 'Y' AND
             p_crse_req_complete_dt <= p_enrl_end_dt  THEN

             p_hesa_comp_pyr_study := '1';

          -- If the student has left but has not completed the requirements of the program
          ELSIF p_typeyr IS NOT NULL THEN

            IF p_discont_dt IS NOT NULL THEN

              -- Get HESA mapped value from mapping between leaving reason, TYPEYR field and FUNDCOMP
              l_he_code_map_val := NULL;
              l_he_code_map_val.association_code := 'OSS_FUNDCOMP_RSNLEAVE_ASSOC';
              l_he_code_map_val.map2 := p_typeyr;
              l_he_code_map_val.map3 := p_disc_reason_cd;

              igs_he_extract2_pkg.get_map_values(
                p_he_code_map_val   => l_he_code_map_val,
                p_value_from        => 'MAP1',
                p_return_value      => p_hesa_comp_pyr_study);

            ELSE

              l_progression_out_type := NULL;
              l_prev_start_dt    := NULL;
              l_prev_applied_dt  := NULL;
              l_prev_decision_dt := NULL;
              l_minimum_date := igs_ge_date.igsdate('1900/01/01');

              FOR prog_out_type_rec IN cur_prog_out_type(p_person_id, p_course_cd, p_enrl_start_dt, p_enrl_end_dt) LOOP

                -- Compare the current row whether better then the previous row in the order by
                -- Calendar Start Date, Applied Date and Decision Date

                -- If the current Caledar Start Date is greater than the previous Calendar Start Date
                -- Then consider the current
                IF  NVL(l_prev_start_dt, l_minimum_date ) < NVL(prog_out_type_rec.start_dt, l_minimum_date ) THEN
                  l_progression_out_type := prog_out_type_rec.progression_outcome_type;

                -- If the Calendar Start Date is equal for both the records then
                -- Check for the Applied Date
                ELSIF NVL(l_prev_start_dt, l_minimum_date) = NVL(prog_out_type_rec.start_dt,l_minimum_date ) THEN

                  -- If the current Applied Date is greater than the previous Applied Date
                  IF  NVL(l_prev_applied_dt, l_minimum_date) < NVL(prog_out_type_rec.applied_dt,l_minimum_date ) THEN
                    l_progression_out_type := prog_out_type_rec.progression_outcome_type;

                  -- If the Applied Date is equal for both the records then
                  -- Check the Decision Date
                  ELSIF  NVL(l_prev_applied_dt,l_minimum_date ) = NVL(prog_out_type_rec.applied_dt,l_minimum_date ) THEN

                    IF  NVL(l_prev_decision_dt,l_minimum_date ) <=  NVL(prog_out_type_rec.decision_dt, l_minimum_date) THEN
                      l_progression_out_type := prog_out_type_rec.progression_outcome_type;
                    END IF;

                  END IF;

                END IF;

                -- Assigning the current record values
                l_prev_start_dt    := prog_out_type_rec.start_dt;
                l_prev_applied_dt  := prog_out_type_rec.applied_dt;
                l_prev_decision_dt := prog_out_type_rec.decision_dt;

              END LOOP;

              -- If a progression outcome type exists for the student program attempt then
              IF l_progression_out_type IS NOT NULL THEN

                -- GET HESA mapped value from the mapping between TYPEYR and progression outcome type to FUNDCOMP
                l_he_code_map_val := NULL;
                l_he_code_map_val.association_code := 'OSS_FUNDCOMP_PROGOUT_ASSOC';
                l_he_code_map_val.map2 := p_typeyr;
                l_he_code_map_val.map3 := l_progression_out_type;

                igs_he_extract2_pkg.get_map_values(
                  p_he_code_map_val   => l_he_code_map_val,
                  p_value_from        => 'MAP1',
                  p_return_value      => p_hesa_comp_pyr_study);

              ELSE

                -- student has not left and no progression outcome type exists,
                -- so the assumption is that the student has completed the year successfully
                -- Get HESA mapped value from the mapping between TYPEYR and FUNDCOMP
                l_he_code_map_val := NULL;
                l_he_code_map_val.association_code := 'OSS_FUNDCOMP_TYPEYR_ASSOC';
                l_he_code_map_val.map2 := p_typeyr;

                igs_he_extract2_pkg.get_map_values(
                  p_he_code_map_val   => l_he_code_map_val,
                  p_value_from        => 'MAP1',
                  p_return_value      => p_hesa_comp_pyr_study);

              END IF;

            END IF;

          END IF; --  p_typeyr IS NOT NULL

        END IF; -- p_hesa_comp_pyr_study IS NULL

      END IF; -- p_fundlev = '99'

    END IF; -- p_susa_comp_pyr_study IS NULL

  EXCEPTION
    WHEN OTHERS THEN
      write_to_log (SQLERRM);
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_comp_pyr_study');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END get_comp_pyr_study;



   PROCEDURE get_destination
          (p_oss_destination     IN  igs_he_st_spa.destination%TYPE,
           p_hesa_destination    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the destination
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_DESTIN_ASSOC';
      l_he_code_map_val.map2             := p_oss_destination;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_destination);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_destination');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_destination;



   PROCEDURE get_itt_outcome
          (p_oss_itt_outcome     IN   igs_he_st_spa.itt_prog_outcome%TYPE,
           p_teach_train_prg     IN   igs_he_st_spa.teacher_train_prog_id%TYPE,
           p_hesa_itt_outcome    OUT NOCOPY  VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Outcome of ITT Programme
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

      IF   p_oss_itt_outcome IS NOT NULL
      AND  p_teach_train_prg IN ('1','6','7')
      THEN
          l_he_code_map_val.association_code := 'OSS_HESA_OUTCOME_ASSOC';
          l_he_code_map_val.map2             := p_oss_itt_outcome;
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_itt_outcome);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_itt_outcome');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_itt_outcome;


   PROCEDURE get_ufi_place
          (p_oss_ufi_place     IN  igs_he_st_spa.ufi_place%TYPE,
           p_hesa_ufi_place    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the ufi place
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_UFI_ASSOC';
      l_he_code_map_val.map2             := p_oss_ufi_place;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_ufi_place);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_ufi_place');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_ufi_place;



   PROCEDURE get_franchising_activity
          (p_susa_franch_activity     IN  igs_he_en_susa.franchising_activity%TYPE,
           p_poous_franch_activity    IN  igs_he_poous.franchising_activity%TYPE,
           p_prog_franch_activity     IN  igs_he_st_prog.franchising_activity%TYPE,
           p_hesa_franch_activity     OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Franchising activity
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_FRAN_ASSOC';
      l_he_code_map_val.map2             := Nvl(Nvl(p_susa_franch_activity,
                                                    p_poous_franch_activity),
                                                p_prog_franch_activity);

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_franch_activity);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_franchising_activity');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_franchising_activity;



   PROCEDURE get_social_class_ind
          (p_spa_social_class_ind     IN  igs_he_st_spa.social_class_ind%TYPE,
           p_adm_social_class_ind     IN  igs_he_ad_dtl.social_class_cd%TYPE,
           p_hesa_social_class_ind    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Social Class Indicator
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'UC_OSS_HE_SOC_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_spa_social_class_ind,
                                                 p_adm_social_class_ind)  ;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP3',
                                p_return_value      => p_hesa_social_class_ind);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_social_class_ind');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_social_class_ind;



   PROCEDURE get_occupation_code
          (p_spa_occupation_code     IN  igs_he_st_spa.occupation_code%TYPE,
           p_hesa_occupation_code    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Occupation Codes
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'UC_OSS_HE_OCC_ASSOC';
      l_he_code_map_val.map2             := p_spa_occupation_code;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP3',
                                p_return_value      => p_hesa_occupation_code);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_occupation_code');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_occupation_code;



   PROCEDURE get_inst_last_attended
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_com_date              IN  DATE,
           p_inst_last_att         OUT NOCOPY VARCHAR2,
           p_enrl_start_dt igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt igs_he_submsn_header.enrolment_end_date%TYPE
           )

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets  the School / Inst Last attended.
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     rbezawad  17-Sep-03    Modified the process to derive the  "institution last Attended" field from Academic History
                             rather than from Attendence Hisotry w.r.t. UCFD210 Build, Bug 289354.
     AYEDUBAT  17-Oct-03   Added a logic to appened p_inst_last_att with 'H',
                           if it holds the govt_institution_cd value for bug, 3125475
     uudayapr  02-Dec-2003 ENH#3291662 modified get_inst_last_attended procedure added two new parameters  and also the cursor c_heinst
                              as a part of HECR212 -SSEDED ORGANIZATIONAL ALTERNATE IDENTIFIERS INTEGRATION build.
     jtmathew  21-Apr-2005  Modifications to c_inst for bug 4043591
     anwest    09-Jun-04    Changes for bug #4401841
     sjlaport  07-Jun-2005  Modifications for bug 4407917
   ***************************************************************/

   --Get the institute last attended from Academic History
   -- Modified the cusor to add a new condition, end_date IS NULL
   -- to fetch the record, even if end_date column is NULL for bug, 3125475

   CURSOR c_inst IS
   SELECT institution_code,
          NVL(end_date, TO_DATE('01-01-1500', 'DD-MM-YYYY')) end_date_al,
          creation_date
   FROM   igs_ad_acad_history_v
   WHERE  person_id    = p_person_id
   AND    (end_date IS NULL OR end_date < p_com_date)
   ORDER BY end_date_al DESC, creation_date DESC;

   -- MODIFIED THE CURSOR ASA  PART OF ENH#3291662 BUILD.
   CURSOR c_heinst (p_inst_cd         VARCHAR2 ) IS
   SELECT org_alternate_id
   FROM   igs_or_org_alt_ids oai,igs_or_org_alt_idtyp oait
   WHERE oai.org_structure_id = p_inst_cd
   AND    oai.org_structure_type = 'INSTITUTE'
   AND    oai.org_alternate_id_type = oait.org_alternate_id_type
   AND    oait.system_id_type = 'HESA_INST'
   AND    (       oai.start_date <= p_enrl_end_dt
                               AND
            (oai.end_date IS NULL OR oai.end_date >=p_enrl_start_dt)
          )
  ORDER BY oai.start_date DESC;

   -- anwest 09-Jun-05
   -- updated cursor for HZ_PARTIES.PARTY_NUMBER issue - bug #4401841
   CURSOR c_gvinst (p_inst_cd     VARCHAR2) IS
   SELECT ihp.oi_govt_institution_cd govt_institution_cd
   FROM   igs_pe_hz_parties  ihp
   WHERE  ihp.oss_org_unit_cd = p_inst_cd;

   l_oss_inst_cd   igs_ad_acad_history_v.institution_code%TYPE;
   l_year          DATE;
   l_creation_date DATE;
   l_org_alternate_id igs_or_org_alt_ids_v.org_alternate_id%TYPE;
   l_govt_institution_cd igs_pe_hz_parties.oi_govt_institution_cd%TYPE;
   l_he_code_map_val igs_he_code_map_val%ROWTYPE;

   BEGIN

      --Get the institute last attended from Academic History
      OPEN c_inst;
      FETCH c_inst INTO l_oss_inst_cd, l_year, l_creation_date;

      CLOSE c_inst;

      IF l_oss_inst_cd IS NOT NULL
      THEN
          --Get the the current alternate institution code with type "HESA_INST" for OSS institution code.
          OPEN c_heinst (p_inst_cd         => l_oss_inst_cd ) ;
          FETCH c_heinst INTO l_org_alternate_id;

          IF c_heinst%FOUND THEN
              p_inst_last_att := l_org_alternate_id;
          ELSE
              --Get the Government Institution Code for the Institution.
              OPEN c_gvinst (l_oss_inst_cd) ;
              FETCH c_gvinst INTO l_govt_institution_cd;
              CLOSE c_gvinst;
              IF l_govt_institution_cd IS NOT NULL THEN
                p_inst_last_att := l_govt_institution_cd;

                IF p_inst_last_att NOT IN ('4901', '4911', '4921', '4931', '4941') THEN

                    IF SUBSTR(p_inst_last_att,1,1) <> 'H' THEN
                      p_inst_last_att := 'H' || p_inst_last_att;
                    END IF;

                END IF;

              ELSE
                --Get the UCAS mapped value for the Institution Code if exists
                l_he_code_map_val := NULL ;
                l_he_code_map_val.association_code := 'UC_OSS_HE_INS_ASSOC';
                l_he_code_map_val.map2             := l_oss_inst_cd;
                igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      =>  p_inst_last_att);
                IF p_inst_last_att IS NOT NULL THEN
                  p_inst_last_att := 'U'||p_inst_last_att;
                END IF;
              END IF;
          END IF;

          CLOSE c_heinst;

      END IF; -- Institute Cd

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_inst%ISOPEN
          THEN
              CLOSE c_inst;
          END IF;

          IF c_heinst%ISOPEN
          THEN
              CLOSE c_heinst;
          END IF;

          IF c_gvinst%ISOPEN
          THEN
              CLOSE c_gvinst;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_inst_last_attended');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_inst_last_attended;



   PROCEDURE get_regulatory_body
          (p_course_cd               IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number          IN  igs_he_st_spa.version_number%TYPE,
           p_hesa_regulatory_body    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Regulatory Body
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   CURSOR c_regbdy IS
   SELECT reference_cd
   FROM   igs_ps_ref_cd
   WHERE  reference_cd_type = 'REGBODY'
   AND    course_cd         = p_course_cd
   AND    version_number    = p_version_number;

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      OPEN c_regbdy;
      FETCH c_regbdy INTO l_he_code_map_val.map2;
      CLOSE c_regbdy;

      l_he_code_map_val.association_code := 'OSS_HESA_REG_BODY_ASSOC';

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_regulatory_body);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_regulatory_body');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_regulatory_body;



   PROCEDURE get_nhs_fund_src
          (p_spa_nhs_fund_src     IN  igs_he_st_spa.nhs_funding_source%TYPE,
           p_prg_nhs_fund_src     IN  igs_he_st_spa.nhs_funding_source%TYPE,
           p_hesa_nhs_fund_src    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Source of NHS Funding
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_NHS_FUND_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_spa_nhs_fund_src,
                                                p_prg_nhs_fund_src);

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_nhs_fund_src);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_nhs_fund_src');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_nhs_fund_src;



   PROCEDURE get_nhs_employer
          (p_spa_nhs_employer     IN  igs_he_st_spa.nhs_employer%TYPE,
           p_hesa_nhs_employer    OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the NHS Employer
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
   ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_NHS_EMPLOY_ASSOC';
      l_he_code_map_val.map2             := p_spa_nhs_employer;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_nhs_employer);

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_nhs_employer');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_nhs_employer;


   PROCEDURE get_qual_dets
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_hesa_qual             IN  VARCHAR2,
           p_no_of_qual            OUT NOCOPY NUMBER,
           p_tariff_score          OUT NOCOPY NUMBER)
   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Number of Qualifications and Tariff Score
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali               Modified this cursor to take SUM of number_of_qual and tariff_score for bug 2671022
                            Get the sum of the number of qualifications and tariff score for all the OSS qualifications
                            mapped to the HESA qualification passed as a parameter.
     Bayadav  17-Feb-2003   Modified cursor c_qde  to consider new UCAS tariff tables for referring to set up instead of
                            refering to mapping tables as a part of UCAS tariff Build Bug #2717744
   ***************************************************************/

   CURSOR c_qdet IS
   SELECT SUM(number_of_qual),
          SUM(tariff_score)
   FROM   igs_he_st_spa_ut a,
          igs_he_ut_lvl_award b,
          igs_he_ut_calc_type c
   WHERE  a.person_id            = p_person_id
   AND    a.course_cd            = p_course_cd
   AND    b.Tariff_calc_type_cd  = c.Tariff_calc_type_cd
   AND    a.qualification_level  = b.award_cd
   AND    b.tariff_level_cd      = p_hesa_qual
   AND    b.closed_ind           = 'N'
   AND    c.External_calc_ind    = 'Y'
   And    c.closed_ind           = 'N';


   BEGIN
      OPEN  c_qdet;
      FETCH c_qdet INTO p_no_of_qual,
                        p_tariff_score ;
      CLOSE c_qdet;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_qdet%ISOPEN
          THEN
              CLOSE c_qdet;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_qual_dets');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_qual_dets;



   PROCEDURE get_module_dets
          (p_person_id            IN  igs_pe_person.person_id%TYPE,
           p_course_cd            IN  igs_en_stdnt_ps_att.course_cd%TYPE,
           p_version_number       IN  igs_en_stdnt_ps_att.version_number%TYPE,
           p_student_inst_number  IN  igs_he_st_spa.student_inst_number%TYPE,
           p_cal_type             IN  igs_en_stdnt_ps_att.cal_type%TYPE,
           p_enrl_start_dt        IN  DATE,
           p_enrl_end_dt          IN  DATE,
           p_offset_days          IN  NUMBER,
           p_module_rec           IN OUT NOCOPY mod_rec,
           p_total_recs           OUT NOCOPY NUMBER)

   IS
   /***************************************************************
   Created By             :
   Date Created By        :
   Purpose                : This procedure gets the Module Identifiers, the proportion of teaching in welsh for each and the result in each
   Known Limitations,Enhancements or Remarks:
   Change History :
   Who       When            What
   Bayadav   11-DEC-2002  As a part of  bug #2694623 Included validation in case the result type returned from assessemnt procedure
                             is NULL to return mi=odule result as 8 or 9
   smaddali  27-dec-2002  modified cursor c_mod to add condition that status in (enrolled,discontin,completed) ,bug 2702100
   smaddali  12-Mar-03    Modified cursor c_mod for performance issue , Bug#2839289 . Replaced Exists with a Union
   smaddali  27-Mar-03    Modified cursor c_mod for HEFD209, Bug#2717755 .
   knaraset  09-May-03    Modified cursor c_mod and c_outdt for multiple unit section build bug 2829262
   smaddali  23-Jun-03    Modified cursor c_mod,c_outdt for bug# 2950851,2950848 to get distinct units
   sarakshi  27-jun-03    Enh#2930935,modified cursor c_mod such that it picks up usec level enrolled
                          credit points if exists else from the unit level
   jbaber    19-Jan-06    Exclude flagged units for HE305 - Extract Improvements
   ***************************************************************/

   -- smaddali restructured the cursor for performance issue Bug#2839289
   -- smaddali replaced igs_as_suaai_v with igs_as_su_stmptout and added condition finalised_ind='Y' , Bug#2717755
   CURSOR c_mod IS
   SELECT DISTINCT a.unit_cd,
          a.version_number,
          d.prop_of_teaching_in_welsh,
          NVL(cps.enrolled_credit_points,b.enrolled_credit_points) enrolled_credit_point
    FROM  igs_en_su_attempt_all a,
          igs_ps_unit_ver_all   b,
          igs_he_st_spa_all     c,
          igs_he_st_unt_vs_all  d,
          igs_ps_usec_cps cps
    WHERE  a.unit_cd           = b.unit_cd
           AND    a.version_number    = b.version_number
           AND    c.person_id         = a.person_id
           AND    c.course_cd         = a.course_cd
           AND    c.student_inst_number = p_student_inst_number
           AND    b.unit_cd           = d.unit_cd
           AND    b.version_number    = d.version_number
           AND    a.person_id         = p_person_id
           AND    a.uoo_id = cps.uoo_id(+)
           AND    NVL(d.exclude_flag, 'N') = 'N'
           AND    a.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
           AND    a.ci_start_dt BETWEEN  p_enrl_start_dt AND p_enrl_end_dt
    UNION
    SELECT DISTINCT a.unit_cd,
          a.version_number,
          d.prop_of_teaching_in_welsh,
          NVL(cps.enrolled_credit_points,b.enrolled_credit_points) enrolled_credit_point
    FROM  igs_en_su_attempt_all a,
          igs_ps_unit_ver_all   b,
          igs_he_st_spa_all     c,
          igs_he_st_unt_vs_all  d,
          igs_as_su_stmptout e,
          igs_ps_usec_cps cps
    WHERE  a.unit_cd           = b.unit_cd
           AND    a.version_number    = b.version_number
           AND    c.person_id         = a.person_id
           AND    c.course_cd         = a.course_cd
           AND    c.student_inst_number = p_student_inst_number
           AND    b.unit_cd           = d.unit_cd
           AND    b.version_number    = d.version_number
           AND    a.person_id         = p_person_id
           AND    e.person_id          = a.person_id
           AND    e.course_cd          = a.course_cd
           AND    e.uoo_id            = a.uoo_id
           AND    a.uoo_id = cps.uoo_id(+)
           AND    e.outcome_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt
           AND    e.finalised_outcome_ind  = 'Y'
           AND    NVL(d.exclude_flag, 'N') = 'N'
           AND    a.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
   ORDER BY  enrolled_credit_point  DESC;

   CURSOR c_outdt (p_unit_cd igs_en_su_attempt.unit_cd%TYPE)
   IS
   SELECT sua.course_cd,
          sua.cal_type,
          sua.ci_sequence_number,
          sua.ci_end_dt,
          sua.unit_attempt_status,
          sua.no_assessment_ind,
          suo.outcome_dt,
          sua.uoo_id
   FROM   igs_as_su_stmptout suo,
          igs_en_su_attempt_all sua,
          igs_he_st_spa_all   spa
   WHERE  suo.person_id          = sua.person_id
   AND    suo.course_cd          = sua.course_cd
   AND    suo.uoo_id             = sua.uoo_id
   AND    sua.person_id          = spa.person_id
   AND    sua.course_cd          = spa.course_cd
   AND    spa.student_inst_number = p_student_inst_number
   AND    suo.outcome_dt BETWEEN p_enrl_start_dt AND p_enrl_end_dt
   AND    suo.unit_cd            = p_unit_cd
   AND    suo.person_id          = p_person_id
   AND    suo.finalised_outcome_ind  = 'Y'
   AND    sua.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
   ORDER BY suo.outcome_dt DESC ;
   c_outdt_rec c_outdt%ROWTYPE ;


   l_index                  NUMBER;
   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_grading_schema_cd      igs_as_suaai_v.grading_schema_cd%TYPE;
   l_gs_version_number      igs_as_suaai_v.gs_version_number%TYPE;
   l_grade                  igs_as_suaai_v.grade%TYPE;
   l_s_result_type          igs_as_grd_sch_grade.s_result_type%TYPE;

   BEGIN

      l_index      := 1;
      p_total_recs := 0;
      -- loop thru each distinct unit of this person among all his program attempts with same instance number
      FOR l_c_mod IN c_mod
      LOOP
          -- store the Unit cd ,version number and proportion of teaching in welsh in the array
          p_module_rec.module_id(l_index) := l_c_mod.unit_cd || '.' ||To_Char(l_c_mod.version_number);
          p_module_rec.prop_in_welsh(l_index) := l_c_mod.prop_of_teaching_in_welsh;


          -- get the latest outcome for this unit among all the program attempts of this person with the same student instance number
          c_outdt_rec := NULL ;
          OPEN c_outdt (l_c_mod.unit_cd);
          FETCH c_outdt INTO c_outdt_rec ;
          CLOSE c_outdt;

          l_s_result_type := NULL ;
          -- Get the result type , grading schema and grade for the identified unit attempt outcome for this person
          l_s_result_type := Igs_As_Gen_003.assp_get_sua_grade
                                  (p_person_id           => p_person_id,
                                   p_course_cd           => c_outdt_rec.course_cd,
                                   p_unit_cd             => l_c_mod.unit_cd,
                                   p_cal_type            => c_outdt_rec.cal_type,
                                   p_ci_sequence_number  => c_outdt_rec.ci_sequence_number,
                                   p_unit_attempt_status => c_outdt_rec.unit_attempt_status,
                                   p_finalised_ind       => 'Y',
                                   p_grading_schema_cd   => l_grading_schema_cd,
                                   p_gs_version_number   => l_gs_version_number,
                                   p_grade               => l_grade,
                                   p_uoo_id              => c_outdt_rec.uoo_id);

        --To check for result type.In case result type is NULL ,then whether that unit is assessible or not
        IF  l_s_result_type IS NULL THEN
                IF  c_outdt_rec.no_assessment_ind  = 'Y' THEN
                  p_module_rec.module_result(l_index) := 9;
                ELSE
                   p_module_rec.module_result(l_index) := 8;
                END IF;
        ELSE
           l_he_code_map_val := NULL ;
           l_he_code_map_val.association_code := 'GRADING_HESA_MODRES_ASSOC';
           l_he_code_map_val.map2             := l_grade;
           l_he_code_map_val.map3             := l_grading_schema_cd;
           igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      =>  p_module_rec.module_result(l_index));

           IF c_outdt_rec.ci_end_dt < p_enrl_start_dt
           AND c_outdt_rec.outcome_dt > p_enrl_start_dt
           THEN
                 IF p_module_rec.module_result(l_index) IS NOT NULL THEN
                       -- Late Result
                       -- smaddali initializing variable for bug 2950851
                       l_he_code_map_val := NULL ;
                       l_he_code_map_val.association_code := 'HESA_LATE_MODRES_ASSOC';
                       l_he_code_map_val.map2             := p_module_rec.module_result(l_index);
                       igs_he_extract2_pkg.get_map_values
                                       (p_he_code_map_val   => l_he_code_map_val,
                                        p_value_from        => 'MAP1',
                                        p_return_value      =>  p_module_rec.module_result(l_index) );
                 END IF ;
           END IF; -- Late result
        END IF; -- result type found

        l_index := l_index + 1;
        IF l_index > 16
        THEN
               -- We dont want more than 16 modules.
               EXIT;
        END IF;
      END LOOP;

      IF c_mod%ISOPEN
      THEN
          CLOSE c_mod;
      END IF;

      -- Decrease count as it would be one more than total recs
      l_index := l_index - 1;
      IF l_index > 16
      THEN
          -- total modules found more than 16
          p_total_recs := 16  ;
      ELSE
          -- total modules found <= 16
          p_total_recs := l_index  ;
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_module_dets');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_module_dets;



   PROCEDURE get_mode_of_study
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
           p_version_number        IN  igs_he_st_spa.version_number%TYPE,
           p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
           p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
           p_susa_study_mode       IN  igs_he_en_susa.study_mode%TYPE,
           p_poous_study_mode      IN  igs_he_poous.attendance_mode%TYPE,
           p_attendance_type       IN  igs_en_stdnt_ps_att.attendance_type%TYPE,
           p_mode_of_study         OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets Mode of Study
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     AYEDUBAT  29-04-04    Changed the cursor, c_drm to add a new condition to check
                           for approved intermissions, if approval is required for Bug, 3494224
     rnirwani  13-09-04    Changed the cursor, c_drm to exclude logically deleted intermission
                           records as per Bug# 3885804
     jbaber    30-11-04    Consider mutiple intermission records for bug# 4037237
                           Now calls isDormant function
     jbaber    26-01-06    Check if student is dormant even if source is susa or poous
   ***************************************************************/



   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_hesa_mode              igs_he_code_map_val.map1%TYPE;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_MODE_ASSOC';
      l_he_code_map_val.map2             := Nvl(p_susa_study_mode,
                                                p_poous_study_mode);

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_hesa_mode);

      ELSE
          l_he_code_map_val.association_code := 'OSS_HESA_ATTEND_MODE_ASSOC';
          l_he_code_map_val.map2             := p_attendance_type;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_hesa_mode);

      END IF; -- SPA / POOUS Study Mode check


      -- Check for Intermission
      IF NOT isDormant
              (p_person_id        => p_person_id,
               p_course_cd        => p_course_cd,
               p_version_number   => p_version_number,
               p_enrl_start_dt    => p_enrl_start_dt,
               p_enrl_end_dt      => p_enrl_end_dt)
       THEN
           p_mode_of_study := l_hesa_mode;

       ELSE
           -- Student Intermission exists
           IF l_hesa_mode IN ('01','02','12','13','14','23','24','25')
           THEN
               -- previously Full Time
               p_mode_of_study := '63';
           ELSE
               p_mode_of_study := '64';
           END IF;
       END IF;


      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_mode_of_study');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_mode_of_study;



   FUNCTION isDormant
           (p_person_id             IN  igs_pe_person.person_id%TYPE,
            p_course_cd             IN  igs_he_st_spa.course_cd%TYPE,
            p_version_number        IN  igs_he_st_spa.version_number%TYPE,
            p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
            p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE)
   RETURN BOOLEAN IS
   /***************************************************************
     Created By           : Jonathan Baber
     Date Created By      : 29th November 2004
     Purpose              : Determines if a student has been dormant over the reporting
                            period. Multiple intermission records are accounted for.
     Known Limitations,Enhancements or Remarks:
     Change History
     Who       When         What
     jbaber    29-Nov-04    Created
     jbaber    26-Jan-06    Student is dormant if l_end_dt < l_start_dt for bug 4459794
   ***************************************************************/

   CURSOR c_spa_dt IS
   SELECT commencement_dt,
          discontinued_dt,
          course_rqrmnts_complete_dt
   FROM   igs_en_stdnt_ps_att_all
   WHERE  person_id = p_person_id
     AND  course_cd = p_course_cd
     AND  version_number = p_version_number;

   CURSOR c_drm(cp_start_dt DATE, cp_end_dt DATE) IS
   SELECT start_dt,
          end_dt
   FROM   igs_en_stdnt_ps_intm spi
   WHERE  spi.person_id = p_person_id
     AND  spi.course_cd = p_course_cd
     AND  spi.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
     AND  spi.start_dt<= cp_end_dt
     AND  NVL(spi.end_dt,cp_end_dt) >=  cp_start_dt
     AND  (spi.approved = 'Y' OR
          EXISTS( SELECT 1 FROM igs_en_intm_types
                  WHERE intermission_type = spi.intermission_type AND
                  appr_reqd_ind = 'N' ))
   ORDER BY start_dt;

   l_spa_dt                 c_spa_dt%ROWTYPE;
   l_start_dt               DATE;
   l_end_dt                 DATE;
   l_full_intermission      BOOLEAN := FALSE;

   BEGIN

      -- Get course requirements complete, commencement and discontinued date
      OPEN c_spa_dt;
      FETCH c_spa_dt INTO l_spa_dt;
      CLOSE c_spa_dt;

      -- Start date is greatest of reporting start date and course commencement date
      l_start_dt := TRUNC(GREATEST(p_enrl_start_dt, NVL(l_spa_dt.commencement_dt,p_enrl_start_dt)));

      -- End date is least of reporting start date, course discontinued date and course requirements complete date
      l_end_dt := TRUNC(LEAST(p_enrl_end_dt, NVL(l_spa_dt.discontinued_dt,p_enrl_end_dt), NVL(l_spa_dt.course_rqrmnts_complete_dt,p_enrl_end_dt)));

      -- End date prior to start date implies course_rqrmnts_complete_dt or discontinue_dt is earlier than enrl_start_dt
      -- therefore student is dormant
      IF l_end_dt < l_start_dt THEN
          RETURN TRUE;
      END IF;

      -- Check for Intermission
      FOR v_drm IN c_drm(l_start_dt, l_end_dt)
      LOOP

          -- Record start date is AFTER period start date
          -- Therefor NOT full intermission
          IF v_drm.start_dt > l_start_dt THEN
              EXIT;
          END IF;

          -- Record end date is AFTER period end date
          -- Therefore IS full intermission
          IF v_drm.end_dt >= l_end_dt THEN
              l_full_intermission := TRUE;
              EXIT;
          END IF;

          l_start_dt := v_drm.end_dt+1;

      END LOOP;

      RETURN l_full_intermission;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_drm%ISOPEN
          THEN
              CLOSE c_drm;
          END IF;

          IF c_spa_dt%ISOPEN
      THEN
          CLOSE c_spa_dt;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.isDormant');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END isDormant;


   PROCEDURE get_mod_prop_fte
          (p_enrolled_credit_points   IN  igs_ps_unit_ver_v.enrolled_credit_points%TYPE,
           p_unit_level               IN  igs_ps_unit_ver_v.unit_level%TYPE,
           p_prop_of_fte              OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets the Proportion of FTE for Module Return
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When        What
     smaddali              Modified this procedure to check if l_annual_credit is a number before calculating fte , bug 2668966
     ***************************************************************/

   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_annual_credit          NUMBER;
   l_credit  igs_he_code_map_val.map1%TYPE ;

    NOT_NUMBER_EXCEP EXCEPTION ;

   BEGIN

      l_he_code_map_val.association_code := 'LEVEL_ANNUAL_CREDIT_ASSOC';
      l_he_code_map_val.map2             := p_unit_level;

      IF l_he_code_map_val.map2 IS NOT NULL
      THEN
          -- Get Annual Credit
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => l_credit);

          -- smaddali added the condition to check that l_annual_credit is a number field before calculating fte , bug 2668966
          BEGIN
              l_annual_credit := l_credit ;
          EXCEPTION
               WHEN VALUE_ERROR THEN
                RAISE NOT_NUMBER_EXCEP ;
          END ;

          p_prop_of_fte := (p_enrolled_credit_points / l_annual_credit) * 100;

      END IF;

      EXCEPTION
         WHEN NOT_NUMBER_EXCEP THEN
            NULL ;
         WHEN OTHERS THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_mod_prop_fte');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_mod_prop_fte;


   PROCEDURE get_mod_prop_not_taught
          (p_unit_cd               IN  igs_he_st_unt_vs.unit_cd%TYPE,
           p_version_number        IN  igs_he_st_unt_vs.version_number%TYPE,
           p_prop_not_taught       OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets  Proportion not taught by institution for a module
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     anwest    09-Jun-04    Changes for bug #4401841
   ***************************************************************/

   -- anwest 09-Jun-05
   -- updated cursor for HZ_PARTIES.PARTY_NUMBER issue - bug #4401841
   CURSOR c_perc IS
   SELECT SUM(percentage)
   FROM   igs_ps_tch_resp    a,
          igs_pe_hz_parties ihpou,
          igs_pe_hz_parties ihpinst
   WHERE  a.unit_cd        = p_unit_cd
   AND    a.version_number = p_version_number
   AND    a.org_unit_cd    = ihpou.oss_org_unit_cd
   AND    ihpou.institution_cd = ihpinst.oss_org_unit_cd
   AND    NVL(ihpinst.oi_local_institution_ind,'N') = 'N' ;

   BEGIN

      OPEN  c_perc ;
      FETCH c_perc INTO p_prop_not_taught;
      CLOSE c_perc ;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_perc%ISOPEN
          THEN
              CLOSE c_perc;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_mod_prop_not_taught');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_mod_prop_not_taught;



   PROCEDURE get_mod_oth_teach_inst
          (p_unit_cd               IN  igs_he_st_unt_vs.unit_cd%TYPE,
           p_version_number        IN  igs_he_st_unt_vs.version_number%TYPE,
           p_oth_teach_inst        OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets  Proportion Other Insitution Providing Teaching
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali               Modified local_institution_ind='Y' to 'N' for bug 2427601
     anwest    09-Jun-04    Changes for bug #4401841
   ***************************************************************/

   -- anwest 09-Jun-05
   -- updated cursor for HZ_PARTIES.PARTY_NUMBER issue - bug #4401841
   CURSOR c_oinst IS
   SELECT SUM(percentage) percentage,
          ihpinst.oi_govt_institution_cd govt_institution_cd
   FROM   igs_ps_tch_resp    a,
          igs_pe_hz_parties ihpou,
          igs_pe_hz_parties ihpinst
   WHERE  a.unit_cd        = p_unit_cd
   AND    a.version_number = p_version_number
   AND    a.org_unit_cd    = ihpou.oss_org_unit_cd
   AND    ihpou.institution_cd = ihpinst.oss_org_unit_cd
   AND    NVL(ihpinst.oi_local_institution_ind,'N') = 'N'
   GROUP BY ihpinst.oi_govt_institution_cd
   ORDER BY percentage DESC;

   l_percentage        NUMBER;

   BEGIN

      OPEN  c_oinst ;
      FETCH c_oinst INTO l_percentage,
                         p_oth_teach_inst;
      CLOSE c_oinst ;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          IF c_oinst%ISOPEN
          THEN
              CLOSE c_oinst;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_mod_oth_teach_inst');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_mod_oth_teach_inst;


   PROCEDURE get_pgce_class
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_pgce_class            OUT NOCOPY VARCHAR2)

   IS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              : This procedure gets PGCE classification of undergraduate degree
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smaddali               Modified this cursor for bug 2730388 to get only open code values
     smaddali   3-dec-03    Modified logic for HECR210 program completion validation build bug#2874542
   ***************************************************************/

   -- smaddali selecting grading_schema_cd for HECR210 build
   CURSOR c_pgce_cls IS
   SELECT a.approved_result, a.grading_schema_cd
   FROM   igs_uc_qual_dets a
   WHERE  a.person_id = p_person_id
   AND    EXISTS (SELECT 'X'
                  FROM   igs_he_code_values b
                  WHERE  b.value = a.exam_level
                  AND    b.code_type = 'OSS_QUAL_1ST_DEGREE'
                  AND    NVL(b.closed_ind,'N') = 'N' )
   ORDER BY a.year DESC;

   l_pgce_class             igs_he_code_map_val.map1%TYPE;
   l_he_code_map_val        igs_he_code_map_val%ROWTYPE := NULL;
   l_grading_schema         igs_uc_qual_dets.grading_schema_cd%TYPE;

   BEGIN

      OPEN c_pgce_cls ;
      FETCH c_pgce_cls INTO l_pgce_class, l_grading_schema;
      CLOSE c_pgce_cls;

      IF l_pgce_class IS NULL
      THEN
          p_pgce_class := '99';
      ELSE
          -- smaddali modified associarion code to OSS_HESA_CLASS_ASSOC for HECR210 build
          l_he_code_map_val.association_code := 'OSS_HESA_CLASS_ASSOC';
          l_he_code_map_val.map2             :=   l_grading_schema ;
          l_he_code_map_val.map3             :=   l_pgce_class ;

          igs_he_extract2_pkg.get_map_values
                           (p_he_code_map_val   => l_he_code_map_val,
                            p_value_from        => 'MAP1',
                            p_return_value      => p_pgce_class);
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_pgce_class');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END get_pgce_class;



  PROCEDURE get_commencement_dt
          ( p_hesa_commdate             IN  igs_he_st_spa_all.commencement_dt%TYPE ,
            p_enstdnt_commdate          IN  igs_en_stdnt_ps_att.commencement_dt%TYPE,
            p_person_id                 IN  igs_pe_person.person_id%TYPE ,
            p_course_cd                 IN  igs_he_st_spa_all.course_cd%TYPE,
            p_version_number            IN  igs_he_st_spa_all.version_number%TYPE,
            p_student_inst_number       IN  igs_he_st_spa_all.student_inst_number%TYPE,
            p_final_commdate            OUT NOCOPY igs_he_ex_rn_dat_fd.value%TYPE)

   IS
   /***************************************************************
     Created By           :  bayadav
     Date Created By      :  25-Mar-2002
     Purpose              :  This procedure gets the value of commencement date for combined/stduent field 26.
                             First IGS_HE_ST_SPA_ALL.commencement date is cinsidered.If NULL then it is checked if program transfer has taken palce
                             If yes ,then assign get the value of first program in chain for that person
                             (For the person having the same student instance number for the different program transfer are said to be in same chain)
                             and assign the corresponding IGS_EN_STDNT_PS_ATT.commencement_dt value to it
                             else if the program transfer has  not taken palce then get the IGS_EN_STDNT_PS_ATT.commencement_dt value
                             of course in context and assign it to field
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who                  When            What
     Bayadav   26-Mar-02  Included new procedure get_commencement_dt as a part  of HECR002(bug 2278825 )
     smaddali 24-mar-03 modified  for Build HEFD209 - Bug#2717755 , removed cursor c_course_trn and its code
   ***************************************************************/

  --Cursor to get the commencement date of the first porgram in chain for the context person from
  -- IGS_HE_ST_SPA having same instance number
  CURSOR  c_list_crs_trn IS
  SELECT  MIN(sca.commencement_dt) commencement_dt
  FROM    igs_en_stdnt_ps_att_all sca,
          igs_he_st_spa_all    hspa
  WHERE   hspa.person_id             = p_person_id
   AND  hspa.student_inst_number   = p_student_inst_number
   AND  sca.person_id              = hspa.person_id
   AND  sca.course_cd              = hspa.course_cd;

  l_list_crs_trn   c_list_crs_trn%ROWTYPE;
  BEGIN

    IF   p_hesa_commdate IS NOT NULL THEN
          -- Commencement Date
          p_final_commdate := To_Char(p_hesa_commdate,'DD/MM/YYYY');
    ELSE
             -- smaddali removed the code to check that a transfer record is present in the
             -- enrollment transfer table as part of HEFD209 build, bug#2717755
             --IF the program transfer has taken palce ,then get the commencement date of the
             -- first first program in chain
             OPEN c_list_crs_trn;
             FETCH c_list_crs_trn INTO l_list_crs_trn;
             IF    c_list_crs_trn%FOUND THEN
                           p_final_commdate := To_Char(l_list_crs_trn.commencement_dt,'DD/MM/YYYY');
             END IF;
             CLOSE  c_list_crs_trn ;
    END IF;
  EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_commencement_dt');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

  END get_commencement_dt;

PROCEDURE get_ucasnum(p_person_id               IN  igs_pe_person.person_id%TYPE,
                      p_ucasnum                 OUT NOCOPY igs_pe_alt_pers_id.api_person_id%TYPE,
                      p_enrl_start_dt           IN  igs_he_submsn_header.enrolment_start_date%TYPE,
                      p_enrl_end_dt             IN  igs_he_submsn_header.enrolment_end_date%TYPE)

IS
/***************************************************************
 Created By             : bayadav
 Date Created By        : 25-OCT-2002
 Purpose                : This procedure gets the value of ucas number for combined field 148
 Known Limitations,Enhancements or Remarks:
 Change History :
 Who                    When            What
 Bayadav   25-OCT-02  Included new procedure  as a part  of HEFD101
 bayadav   09-DEC-02  Inlcluded excpetion handling block in this as a part of a part of 2685091
 bayadav  12-DEC-02  Included l_stdnt_id not null check  as a part of a part of 2706787
 pmarada  30-May-03  If Student ID is not able to derive using UCASID then trying derive using
                     NMASID or GTTRID, or SWASID, bug 2986518
 smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
 ***************************************************************/

   l_stdnt_id                 igs_pe_alt_pers_id.api_person_id%TYPE;
   l_sid                      VARCHAR2(30);
   l_index                    NUMBER := 0;
   l_chk_sum                  NUMBER := 0;
   l_chk_digit                NUMBER(2);

   TYPE fldwt IS TABLE OF NUMBER(2)
        INDEX BY binary_integer;
   l_fld_weight               fldwt;

BEGIN
         --get the api_id from the UCASID
         -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
         igs_he_extract_fields_pkg.get_alt_pers_id
                     (p_person_id      =>  p_person_id,
                      p_id_type        =>  'UCASID',
                      p_api_id         =>  l_stdnt_id,
                      p_enrl_start_dt  =>  p_enrl_start_dt,
                      p_enrl_end_dt    =>  p_enrl_end_dt);

          -- If Student ID is not derived using UCASID the try to get the student id using NMASID
               IF l_stdnt_id IS NULL THEN           --0
                   igs_he_extract_fields_pkg.get_alt_pers_id
                         (p_person_id      =>  p_person_id,
                          p_id_type        =>  'NMASID',
                          p_api_id         =>  l_stdnt_id,
                          p_enrl_start_dt  =>  p_enrl_start_dt,
                          p_enrl_end_dt    =>  p_enrl_end_dt);

                -- If Student ID is not derived using UCASID or NMASID then try to get the student id using GTTRID
                  IF l_stdnt_id IS NULL THEN         --1
                     igs_he_extract_fields_pkg.get_alt_pers_id
                            (p_person_id      =>  p_person_id,
                             p_id_type        =>  'GTTRID',
                             p_api_id         =>  l_stdnt_id,
                             p_enrl_start_dt  =>  p_enrl_start_dt,
                             p_enrl_end_dt    =>  p_enrl_end_dt);

                   -- If Student ID is not derived using UCASID or NMASID or GTTRID then try to get the student id using SWASID
                      IF l_stdnt_id IS NULL THEN
                         igs_he_extract_fields_pkg.get_alt_pers_id
                                (p_person_id      =>  p_person_id,
                                 p_id_type        =>  'SWASID',
                                 p_api_id         =>  l_stdnt_id,
                                 p_enrl_start_dt  =>  p_enrl_start_dt,
                                 p_enrl_end_dt    =>  p_enrl_end_dt);
                       END IF;

                  END IF;    --1

               END IF;       --0

       --IF Student ID is less than 8 characters lpad with leading 0s
       IF l_stdnt_id IS NOT NULL THEN

            IF LENGTH(l_stdnt_id) < 8 THEN
               l_stdnt_id :=  LPAD(l_stdnt_id,8,'0');
            END IF;

               -- Initialize Weights.
               l_fld_weight(1)  := 1;
               l_fld_weight(2)  := 3;
               l_fld_weight(3)  := 7;
               l_fld_weight(4)  := 9;
               l_fld_weight(5)  := 1;
               l_fld_weight(6)  := 3;
               l_fld_weight(7)  := 7;
               l_fld_weight(8)  := 9;

               -- Calculate Check Digit
               FOR l_index IN 1 .. LENGTH(l_stdnt_id)
               LOOP
                   l_chk_sum := l_chk_sum +
                                (to_number(Substr(l_stdnt_id,l_index, 1)) *
                                l_fld_weight(l_index));
               END LOOP;

               -- Check digit is 10 - last digit of the check sum above
               l_chk_digit := 10 - to_number(Substr(to_char(l_chk_sum),-1,1));

               -- If l_chk_digit is 10, then set it to 0
               IF l_chk_digit = 10
               THEN
                   l_chk_digit := 0;
               END IF;

               -- Return the UCAS Number field value
               p_ucasnum := l_stdnt_id||to_char(l_chk_digit);
       END IF;

EXCEPTION
WHEN OTHERS THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_ucasnum');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

END get_ucasnum ;

PROCEDURE get_new_prog_length
          (p_spa_attendance_type   IN  igs_en_stdnt_ps_att.attendance_type%TYPE,
           p_program_length         IN igs_ps_ofr_opt_all.program_length%TYPE,
           p_program_length_measurement     IN igs_ps_ofr_opt_all.program_length_measurement%TYPE,
           p_length                OUT NOCOPY NUMBER,
           p_units                 OUT NOCOPY NUMBER)
IS
 /***************************************************************
   Created By           :       bayadav
   Date Created By      :       25-OCT-2002
   Purpose              :This procedure gets the value of program length(49) and unit of length 50
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
   Bayadav  26-Oct-2002 Included new procedure  as a part  of HEFD101(bug 2636897)
   Bayadav  20-Jan-2003 Corrected HOURS to 5  as a part of 2744808
   Jbaber   01-Feb-2005 Included checks for "NOT_APPLICABLE" for bug 3199529/4154993
 ***************************************************************/


   l_length              NUMBER(12,2);
   l_year                NUMBER(12,2);
   l_months              NUMBER(12,2);
   l_weeks               NUMBER(12,2);
   l_days                NUMBER(12,2);
   l_hours               NUMBER(12,2);
   --Decimal is required to capture the decimal values in case whle conversion
   l_program_length      NUMBER(12,2);
   l_program_length_measurement  igs_ps_ofr_opt_all.program_length_measurement%TYPE;
BEGIN


  -- Check for 'NOT_APPLICABLE'
  IF p_program_length_measurement = 'NOT_APPLICABLE' THEN

    -- length is 99, unit is 9
    p_length := 99;
    p_units := 9;

    RETURN;

  END IF;


        IF p_program_length_measurement  = 'MINUTES' THEN

  --Convert the program length to HOURS

    l_program_length :=  ROUND( (p_program_length/60) );
    l_program_length_measurement := 'HOURS';
  ELSIF  p_program_length_measurement  = '10TH OF A YEAR' THEN

  --Convert the program length to YEARS

    l_program_length :=   (p_program_length/10);
    l_program_length_measurement := 'YEAR';


  ELSE

    l_program_length :=   p_program_length;
    l_program_length_measurement := p_program_length_measurement;
  END IF;



        IF l_program_length_measurement = 'YEAR'
  THEN
  --Here we need to consider the decimal value as above in case of 10th of a year value is divided by 10 to get in YEAR
  --1
    IF  l_program_length  = ROUND(l_program_length)     THEN
 --It's a whole number so return the correpsonding unit of length and SPLENGTH
      p_length  := l_program_length;
      p_units := 1;



 --1
    ELSE
--No need to check for greater than 99 as it is for the larget unit so in case it is lessthan 99 and not inetger value need to convert it into smaller unit
--Converting it to MONTH as YEAR is not a whole number
      l_months  := (l_program_length *12);


-- Months is a whole number, so return the months
--Return the Years by rounding  as it greater than 99
--2
      IF l_months >99 THEN
--as on converting it is coming >99 so dont proceed further

         p_length := ROUND(l_program_length);
         p_units  := 1;
--2
      ELSE

-- Months less than 99
--3
       IF l_months = ROUND(l_months)                      THEN
           p_length := l_months;
           p_units := 2;
 --3
     ELSE
--Converted month is not a whole number ,so convert into 'weeks
        l_weeks := ROUND(l_program_length * 52);
--4
           IF l_weeks > 99                            THEN
              --value is greater then 99, so store it in the original unit of length

             p_length := ROUND(l_months);
             p_units := 2;
--4
          ELSE
--5
          IF l_weeks = ROUND(l_weeks) THEN
             p_length := l_weeks;
             p_units := 3;
--5
           ELSE
--Converted weeks is not a whole number ,so convert into days
           l_days := ROUND(l_program_length * 365);
--6

           IF l_weeks > 99                            THEN
                 p_length := ROUND(l_weeks);
                 p_units := 3;
--6
           ELSE
--7
             IF l_days = ROUND(l_days)           THEN

               p_length := l_days;
               p_units := 4;
  --7
             ELSE
--Converted days is not a whole number ,so convert into HOURS
                  l_hours := ROUND(l_program_length*365*12);
--8
                   IF l_hours < 99      THEN
                        p_length := l_hours;
                        p_units := 5;
--8
                   ELSE
                        p_length := ROUND(l_days);
                        p_units := 4    ;
--8
                    END IF;
--7
             END IF;
--6
          END IF ;
--5
     END IF;
--4
   END IF;
 --3
   END IF;
--2
   END IF;
--1
    END IF;

   END IF;





 IF l_program_length_measurement = 'MONTHS' THEN
 --Here we need not consider the decimal value as in PSP the program length  is a  integer column  and as  such
 --we are not converting the value set in PSP to any other value in case of MONTH unit
 --2
      IF l_program_length  < 99  THEN
           p_length := l_program_length ;
           P_units := 2;

--2
     ELSE
--Here we need not consider any case as YEAR is the biggest unit and it can not be converted further to bigger unit
         l_year := (l_program_length/12);
         p_length := ROUND(l_year);
         p_units :=   1;

--2
    END IF;
--1
   END IF;



--1
   IF l_program_length_measurement = 'WEEKS' THEN

--Here we need not consider the decimal value as in PSP the
--program length  is a  integer column  and as  such we are not converting the value set in PSP to any other value in case of WEEKS  unit


--2
       IF l_program_length  < 99  THEN
            p_length := l_program_length        ;
            p_units := 3;

--2
      ELSE
         l_months := (l_program_length*12)/52   ;


--3

--4
         IF l_months   < 99  THEN

           p_length := ROUND(l_months)  ;
           p_units :=  2;

--4
         ELSE
--as it is greater than 99 convert it to larger unit YEARS
            l_year := (l_program_length/52) ;

--We cannot check further for greater than 99 as YEAR is the largest unit
            p_length := ROUND(l_year);
            p_units :=  1;


--4

--3
     END IF;
--2
    END IF;
--1
  END IF;




--1
  IF L_program_length_measurement = 'DAYS' THEN
--Here we need not consider the decimal value as in PSP the
--program length  is a  integer column  and as  such we are not converting the value set in PSP to any other value in case of DAYS  unit
--2
       IF l_program_length  < 99  THEN
          p_length := ROUND(l_program_length)   ;
          P_units := 4;
--2
      ELSE
          l_weeks := (l_program_length/7)       ;
--3
            IF  l_weeks < 99 THEN

              p_length := ROUND(l_weeks)        ;
              p_units :=    3 ;
--3
            ELSE

              l_months := ((l_program_length*12)/(52*7));

--4
               IF l_months   < 99  THEN

                  p_length := ROUND(l_months) ;
                  p_units := 2  ;
--4
              ELSE
--as it is greater than 99 convert it to larger unit YEARS
                   l_year := (l_program_length/365) ;
--We cannot check further for greater than 99 as YEAR is the largest unit
                   p_length := ROUND(l_year);
                   p_units :=     1;
--4
               END IF;
--3
          END IF;
--2
        END IF;
--1
      END IF;





--1
   IF l_program_length_measurement = 'HOURS' THEN

--Here we will  consider the decimal value as above we have converted minutes to HOURS .
--But since HOURS is the smallest so we will round it off  in case it is integer
 --2
          IF l_program_length  < 99  THEN

             p_length  := ROUND(l_program_length);
             p_units :=  5;
--2
         ELSE
              l_days := (l_program_length /24);
--3

              IF (l_days  < 99)  THEN
--It is  less than 99 so return the correpsonding unit of length and SPLENGTH
                     p_length  := ROUND(l_days);
                     p_units :=   4 ;
--3
               ELSE
                    l_weeks := (l_program_length/(24*7));
--4
                    IF l_weeks  < 99  THEN
--It is less than 99 so return the correpsonding unit of length and SPLENGTH

                        p_length  := ROUND(l_weeks);
                        p_units :=      3;
--4
                    ELSE
                        l_months := (l_program_length/(14*52));
--5
                          IF l_months  < 99  THEN
--It's a whole number and less than 99 so return the correpsonding unit of length and SPLENGTH

                              p_length  := ROUND(l_months)       ;
                              p_units := 2      ;
--5
                         ELSE
                            l_year := (l_program_length/(7*24*52) ) ;
--As it is the largest unit  so will not check for whole number  so return the correpsonding unit of length and SPLENGTH
                             p_length  := ROUND(l_year);
                             p_units := 1;
--5
                        END IF;


--4
               END IF;

--3
             END IF;

--2
           END IF;

--1
         END IF;

EXCEPTION
WHEN OTHERS
THEN
          write_to_log (SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_new_prog_length');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

END get_new_prog_length;

PROCEDURE get_marital_status
       (p_oss_marital_status     IN  igs_pe_stat_v.marital_status%TYPE,
        p_hesa_marital_status    OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20-September-2004
  Purpose              : This procedure gets the marital status
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When         What
***************************************************************/

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_MARSTAT_ASSOC';
   l_he_code_map_val.map2             := p_oss_marital_status;

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_marital_status);

   END IF;

   EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_marital_status');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_marital_status;

PROCEDURE get_dependants
       (p_oss_dependants     IN  igs_he_st_spa.dependants_cd%TYPE,
        p_hesa_dependants    OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20-September-2004
  Purpose              : This procedure gets the dependants cd
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When         What
***************************************************************/

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_DEPEND_ASSOC';
   l_he_code_map_val.map2             := p_oss_dependants;

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_dependants);

   END IF;

   EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_dependants');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_dependants;


PROCEDURE get_enh_fund_elig
       (p_susa_enh_fund_elig    IN  igs_he_en_susa.enh_fund_elig_cd%TYPE ,
        p_spa_enh_fund_elig     IN  igs_he_st_spa.enh_fund_elig_cd%TYPE,
        p_hesa_enh_fund_elig    OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the eligibility for enhanced funding
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_ELIGENFD_ASSOC';
   l_he_code_map_val.map2             := NVL(p_susa_enh_fund_elig,p_spa_enh_fund_elig);

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_enh_fund_elig);

   END IF;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_enh_fund_elig');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_enh_fund_elig;


    PROCEDURE get_learn_dif
           (p_person_id             IN  igs_pe_person.person_id%TYPE,
            p_enrl_start_dt         IN  igs_he_submsn_header.enrolment_start_date%TYPE,
            p_enrl_end_dt           IN  igs_he_submsn_header.enrolment_end_date%TYPE,
            p_hesa_disability_type  OUT NOCOPY VARCHAR2)
    IS
    /***************************************************************
      Created By           : Jonathan Baber
      Date Created By      : 20 September 2004
      Purpose              : This procedure gets the learning difficulty
      Known Limitations,Enhancements or Remarks:
      Change History       :
      Who       When        What
    ***************************************************************/

    l_map1                          igs_he_code_map_val.map1%TYPE;

    CURSOR c_hesa_dis_types IS
    SELECT map1
    FROM igs_he_code_map_val a, igs_pe_pers_disablty b
    WHERE a.map2 = b.disability_type
    AND a.association_code = 'OSS_HESA_LEARNDIF_ASSOC'
    AND NOT NVL(b.start_date,  p_enrl_end_dt) >   p_enrl_end_dt
    AND NOT NVL(b.end_date,  p_enrl_start_dt) <   p_enrl_start_dt
    AND b.person_id = p_person_id
    GROUP BY map1;

    BEGIN

       OPEN c_hesa_dis_types;
       FETCH c_hesa_dis_types into l_map1;
       FETCH c_hesa_dis_types into l_map1;

       -- If more than one disability type exists return 90
       -- Otherwise return disability type
       IF (c_hesa_dis_types%FOUND) THEN
             p_hesa_disability_type := '90';
       ELSE
             p_hesa_disability_type := l_map1;
       END IF;

       CLOSE c_hesa_dis_types;

     EXCEPTION
       WHEN OTHERS
       THEN
           write_to_log (SQLERRM);
           IF c_hesa_dis_types%ISOPEN
           THEN
               CLOSE c_hesa_dis_types;
           END IF;
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_learn_dif');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
    END get_learn_dif;




PROCEDURE get_gov_init
       (p_spa_gov_initiatives_cd    IN  igs_he_st_spa.gov_initiatives_cd%TYPE,
        p_prog_gov_initiatives_cd   IN  igs_he_st_prog.gov_initiatives_cd%TYPE,
        p_hesa_gov_initiatives_cd   OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the government initiatives
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_GOVINIT_ASSOC';
   l_he_code_map_val.map2             := NVL(p_spa_gov_initiatives_cd,p_prog_gov_initiatives_cd);

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_gov_initiatives_cd);

       p_hesa_gov_initiatives_cd := p_hesa_gov_initiatives_cd || '99';

   END IF;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_gov_init');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_gov_init;

PROCEDURE get_units_completed
       (p_person_id              IN  igs_pe_person.person_id%TYPE,
        p_course_cd              IN  igs_ps_ver.course_cd%TYPE,
        p_enrl_end_dt            IN  igs_he_submsn_header.enrolment_end_date%TYPE,
        p_spa_units_completed    IN  igs_he_st_spa.units_completed%TYPE,
        p_hesa_units_completed   OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the number of completed units
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

-- This query counts the number of units completed by getting all the course codes
-- attempted by the student from the igs_he_st_spa table with the same student inst number
-- as the course given in the parameter p_course_cd.
-- The associated "COMPLETED' unit attempts are then selected where the outcome date is less
-- than or equal to the reporting period end date.
CURSOR c_unit_count IS
SELECT count(*)
FROM
       igs_en_su_attempt_all su, igs_as_su_stmptout_all suo1,
       igs_he_st_spa spa1, igs_he_st_spa spa2, igs_as_grd_sch_grade gsg
WHERE  su.person_id = suo1.person_id
AND    su.course_cd = suo1.course_cd
AND    su.unit_cd = suo1.unit_cd
AND    su.unit_attempt_status = 'COMPLETED'
AND    su.person_id = spa2.person_id
AND    su.course_cd = spa2.course_cd
AND    suo1.outcome_dt <= p_enrl_end_dt
AND    spa1.person_id = spa2.person_id
AND    spa1.student_inst_number = spa2.student_inst_number
AND    spa1.person_id = p_person_id
AND    spa1.course_cd = p_course_cd
AND    gsg.s_result_type = 'PASS'
AND    gsg.grading_schema_cd = suo1.grading_schema_cd
AND    gsg.grade = suo1.grade
AND    gsg.version_number = suo1.version_number
AND    suo1.outcome_dt IN
      (SELECT MAX(suo2.outcome_dt)
       FROM   igs_as_su_stmptout_all suo2
       WHERE  suo2.person_id = suo1.person_id
       AND    suo2.course_cd = suo1.course_cd
       AND    suo2.finalised_outcome_ind = 'Y'
       AND    suo2.unit_cd = suo1.unit_cd);

BEGIN

   IF p_spa_units_completed IS NOT NULL
   THEN
       p_hesa_units_completed := p_spa_units_completed;
   ELSE

       OPEN c_unit_count;
       FETCH c_unit_count INTO p_hesa_units_completed;
       CLOSE c_unit_count;

   END IF;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       IF c_unit_count%ISOPEN
       THEN
           CLOSE c_unit_count;
       END IF;
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_units_completed');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_units_completed;

PROCEDURE get_disadv_uplift_elig
       (p_spa_disadv_uplift_elig_cd    IN  igs_he_st_spa.disadv_uplift_elig_cd%TYPE,
        p_prog_disadv_uplift_elig_cd   IN  igs_he_st_prog.disadv_uplift_elig_cd%TYPE,
        p_hesa_disadv_uplift_elig_cd   OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the eligibility for disability uplift
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_ELIDISUP_ASSOC';
   l_he_code_map_val.map2             := NVL(p_spa_disadv_uplift_elig_cd,p_prog_disadv_uplift_elig_cd);

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_disadv_uplift_elig_cd);

   END IF;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_disadv_uplift_elig');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_disadv_uplift_elig;

PROCEDURE get_franch_out_arr
       (p_spa_franch_out_arr_cd    IN  igs_he_st_spa.franch_out_arr_cd%TYPE,
        p_prog_franch_out_arr_cd   IN  igs_he_st_prog.franch_out_arr_cd%TYPE,
        p_hesa_franch_out_arr_cd   OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the franchised out arrangements
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_FROUTARR_ASSOC';
   l_he_code_map_val.map2             := NVL(p_spa_franch_out_arr_cd,p_prog_franch_out_arr_cd );

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_franch_out_arr_cd);

   END IF;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_franch_out_arr');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_franch_out_arr;

PROCEDURE get_employer_role
       (p_spa_employer_role_cd   IN  igs_he_st_spa.employer_role_cd%TYPE,
        p_hesa_employer_role_cd  OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the employer role
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_EMPROLE_ASSOC';
   l_he_code_map_val.map2             := p_spa_employer_role_cd;

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_employer_role_cd);

   END IF;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_employer_role');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_employer_role;


PROCEDURE get_franchise_partner
       (p_spa_franch_partner_cd     IN  igs_he_st_spa.franch_partner_cd%TYPE,
        p_hesa_franch_partner_cd    OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the franchise partner
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_FRANPART_ASSOC';
   l_he_code_map_val.map2             := p_spa_franch_partner_cd;

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_franch_partner_cd);

   END IF;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_franchise_partner');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_franchise_partner;


PROCEDURE get_welsh_speaker_ind
       (p_person_id               IN  igs_pe_person.person_id%TYPE,
        p_hesa_welsh_speaker_ind  OUT NOCOPY VARCHAR2)
IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the welsh speaker indicator
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

CURSOR  c_lang IS
SELECT  speaks_level
FROM    igs_pe_languages_v
WHERE   party_id = p_person_id
AND     language_name = 'WS';

l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_WELSSP_ASSOC';

   OPEN c_lang;
   FETCH c_lang into l_he_code_map_val.map2;
   CLOSE c_lang;

   IF l_he_code_map_val.map2 IS NOT NULL
   THEN

       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_welsh_speaker_ind);

   END IF;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       IF c_lang%ISOPEN
       THEN
           CLOSE c_lang;
       END IF;
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_welsh_speaker_ind');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_welsh_speaker_ind;

PROCEDURE get_national_id
       (p_person_id          IN  igs_pe_person.person_id%TYPE,
        p_hesa_national_id1  OUT NOCOPY VARCHAR2,
        p_hesa_national_id2  OUT NOCOPY VARCHAR2)

IS
/***************************************************************
  Created By           : Jonathan Baber
  Date Created By      : 20 September 2004
  Purpose              : This procedure gets the national id 1 and 2
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
***************************************************************/

CURSOR  c_race IS
SELECT  race_cd
FROM    igs_pe_race
WHERE   person_id = p_person_id;


l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

BEGIN
   l_he_code_map_val.association_code := 'OSS_HESA_NATIOND_ASSOC';

   OPEN c_race;

   FETCH c_race into l_he_code_map_val.map2;
   If c_race%FOUND THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_national_id1);
   END IF;

   FETCH c_race into l_he_code_map_val.map2;
   If c_race%FOUND THEN
       igs_he_extract2_pkg.get_map_values
                            (p_he_code_map_val   => l_he_code_map_val,
                             p_value_from        => 'MAP1',
                             p_return_value      => p_hesa_national_id2);
   END IF;

   CLOSE c_race;

 EXCEPTION
   WHEN OTHERS
   THEN
       write_to_log (SQLERRM);
       IF c_race%ISOPEN
       THEN
          CLOSE c_race;
       END IF;
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_national_id');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END get_national_id;


-- anwest 19-Dec-05 Changes as per (4731723) HE360 - HESA REQUIREMENTS FOR 2005/06 REPORTING
PROCEDURE get_welsh_bacc_qual
       (p_person_id   IN igs_pe_person.person_id%TYPE,
        p_welsh_bacc  OUT NOCOPY VARCHAR2) IS

/******************************************************************************
  Created By           : Andrew West
  Date Created By      : 19 December 2005
  Purpose              : This procedure gets the Welsh Baccalaureate Advanced
                         Diploma qualification value
  Known Limitations,Enhancements or Remarks:
  Change History       :
  Who       When        What
******************************************************************************/

CURSOR c_welsh_bacc_qual IS
  SELECT 'X'
  FROM   igs_uc_qual_dets iuqd,
         igs_he_code_map_val ihcmv
  WHERE  iuqd.person_id = p_person_id
  AND    ihcmv.association_code = 'UCAS_OSS_AWD_ASSOC'
  AND    ihcmv.map1  = 'WB'
  AND    ihcmv.map2 = iuqd.exam_level;

CURSOR c_welsh_bacc_pass_grd IS
  SELECT  'X'
  FROM    igs_uc_qual_dets iuqd,
          igs_he_code_map_val ihcmv,
          igs_as_grd_sch_grade iagsg
  WHERE   iuqd.person_id = p_person_id
  AND     iuqd.exam_level = ihcmv.map2
  AND     iuqd.grading_schema_cd = iagsg.grading_schema_cd
  AND     iuqd.version_number = iagsg.version_number
  AND     iuqd.approved_result = iagsg.grade
  AND     iagsg.s_result_type = 'PASS'
  AND     ihcmv.association_code = 'UCAS_OSS_AWD_ASSOC'
  AND     ihcmv.map1  = 'WB';

l_dummy VARCHAR2(1);

BEGIN

  OPEN c_welsh_bacc_qual;
  FETCH c_welsh_bacc_qual INTO l_dummy;
  IF c_welsh_bacc_qual%FOUND THEN
    OPEN c_welsh_bacc_pass_grd;
    FETCH c_welsh_bacc_pass_grd INTO l_dummy;
    IF c_welsh_bacc_pass_grd%FOUND THEN
      p_welsh_bacc := '1';
    ELSE
      p_welsh_bacc := '2';
    END IF;
    CLOSE c_welsh_bacc_pass_grd;
  ELSE
    p_welsh_bacc := '3';
  END IF;
  CLOSE c_welsh_bacc_qual;

  EXCEPTION
   WHEN OTHERS THEN
      write_to_log (SQLERRM);
      IF c_welsh_bacc_qual%ISOPEN THEN
        CLOSE c_welsh_bacc_qual;
      END IF;
      IF c_welsh_bacc_pass_grd%ISOPEN THEN
        CLOSE c_welsh_bacc_pass_grd;
      END IF;
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_welsh_bacc_qual');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

END get_welsh_bacc_qual;


END igs_he_extract_fields_pkg;

/
