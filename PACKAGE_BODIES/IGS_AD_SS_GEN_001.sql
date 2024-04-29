--------------------------------------------------------
--  DDL for Package Body IGS_AD_SS_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SS_GEN_001" AS
  /* $Header: IGSADB8B.pls 120.36 2006/06/14 12:08:38 arvsrini ship $ */
  /******************************************************************
  Created By: tapash.ray
  Date Created By: 11-DEC-2002
  Purpose: Transfer API for transfer of data from SS Staging Table to IGS tables
  Known limitations,enhancements,remarks:
  Change History
  Who        When          What
  apadegal   21-Oct-2005   added set_adm_secur_on and set_adm_secur_off for enabling/disabling security for admin while app submission.
  abhiskum   25-Aug-2005   Added procedures DELETE_PERSTMT_ATTACHMENT_UP, ADD_PERSTMT_ATTACHMENT_UP for
                           Update Submitted Applications Page in SS Admin Flow; and
                           DELETE_PERSTMT_ATTACHMENT, ADD_PERSTMT_ATTACHMENT for Supporting Evidence Page
                           in SS Applicant Floe, for the IGS.M build
  abhiskum   21-Mar-2005  Removed call to Update_Appl_Ofres_Inst() in process_OneStop2 for Bug 4234911.
  pathipat   17-Jun-2003  Enh 2831587 FI210 Credit Card Fund Transfer build
                          Modified procedure update_ad_offer_resp_and_fee() and call to
                          igs_ad_app_req_pkg.insert_row in insert_application_fee()
   smadathi  29-Nov-2002  Enh#2584986.Modifications done in procedures update_ad_offer_resp_and_fee.
   vvutukur  26-Nov-2002  Enh#2584986.Modifications done in procedures update_ad_offer_resp_and_fee,
                          insert_application_fee.
   nshee     29-Aug-2002  Bug 2395510 added 6 columns as part of deferments build
   knag      29-OCT-2002  Bug 2647482 removed local procedure insert_acad_honors and its calls
   stammine  10-Jun-2005  Added procedures at for IGS.M build
  ******************************************************************/
   g_debug_level CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  --Fwd Declarations
  PROCEDURE logHeader(p_proc_name VARCHAR2, p_mode VARCHAR2);
  PROCEDURE logDetail(p_debug_msg VARCHAR2, p_mode VARCHAR2);
  FUNCTION create_application_detail
                             (p_person_id           IN igs_pe_typ_instances_all.person_id%TYPE,
                              p_adm_appl_number     IN igs_pe_typ_instances_all.admission_appl_number%TYPE,
                              p_ss_adm_appl_number IN NUMBER) RETURN BOOLEAN;
  FUNCTION create_application(p_appl_rec        IN igs_ss_adm_appl_stg%ROWTYPE,
                              p_message_name    OUT NOCOPY VARCHAR2,
                              p_return_status   OUT NOCOPY VARCHAR2,
                              p_adm_appl_number OUT NOCOPY NUMBER)
    RETURN BOOLEAN;
  FUNCTION create_program(p_appl_rec        IN igs_ss_adm_appl_stg%ROWTYPE,
                          p_message_name    OUT NOCOPY VARCHAR2,
                          p_return_status   OUT NOCOPY VARCHAR2,
                          p_adm_appl_number IN NUMBER) RETURN BOOLEAN;
  PROCEDURE update_person_type(p_sequence_number     IN igs_pe_typ_instances_all.sequence_number%TYPE,
                               p_nominated_course_cd IN igs_pe_typ_instances_all.nominated_course_cd%TYPE,
                               p_person_id           IN igs_pe_typ_instances_all.person_id%TYPE,
                               p_adm_appl_number     IN igs_pe_typ_instances_all.admission_appl_number%TYPE);
  --dhan
  PROCEDURE insert_othinst(p_person_id             IN NUMBER,
                           p_adm_appl_id           IN NUMBER,
                           p_admission_appl_number IN NUMBER);
  --dhan
  --modified insert_unit_set_dtls, doesn't have major code 1, 2  SS Bug 2622488
  PROCEDURE insert_unit_set_dtls(p_sequence_number     IN igs_ad_unit_sets.sequence_number%TYPE,
                                 p_nominated_course_cd IN igs_ad_unit_sets.nominated_course_cd%TYPE,
                                 p_person_id           IN igs_ad_unit_sets.person_id%TYPE,
                                 p_adm_appl_number     IN igs_ad_unit_sets.admission_appl_number%TYPE,
                                 p_ss_adm_appl_id      IN igs_ss_app_pgm_stg.ss_adm_appl_id%TYPE);
  --           ,p_unit_set_cd             IN igs_ad_unit_sets.unit_set_cd%TYPE
  --           ,p_ver_no                  IN igs_ad_unit_sets.version_number%TYPE);
  --added by nshee during build for Applicant-BOSS SS Bug 2622488
  PROCEDURE insert_acad_interest(p_person_id       IN igs_ad_acad_interest.person_id%TYPE,
                                 p_adm_appl_id     IN igs_ss_ad_acadin_stg.ss_adm_appl_id%TYPE,
                                 p_adm_appl_number IN igs_ad_acad_interest.admission_appl_number%TYPE);
  PROCEDURE insert_applicant_intent(p_person_id       IN igs_ad_app_intent.person_id%TYPE,
                                    p_adm_appl_id     IN igs_ss_ad_appint_stg.ss_adm_appl_id%TYPE,
                                    p_adm_appl_number IN igs_ad_app_intent.admission_appl_number%TYPE);
  PROCEDURE insert_spl_talent(p_person_id       IN igs_ad_spl_talents.person_id%TYPE,
                              p_adm_appl_id     IN igs_ss_ad_spltal_stg.ss_adm_appl_id%TYPE,
                              p_adm_appl_number IN igs_ad_spl_talents.admission_appl_number%TYPE);
  PROCEDURE insert_special_interest(p_person_id       IN igs_ad_spl_interests.person_id%TYPE,
                                    p_adm_appl_id     IN igs_ss_ad_splint_stg.ss_adm_appl_id%TYPE,
                                    p_adm_appl_number IN igs_ad_spl_interests.admission_appl_number%TYPE);
  --added by nshee during build for Applicant-BOSS SS Bug 2622488
  PROCEDURE insert_edugoal_details(p_person_id           IN igs_ad_edugoal.person_id%TYPE,
                                   p_adm_appl_number     IN igs_ad_edugoal.admission_appl_number%TYPE,
                                   p_ss_adm_appl_id      IN igs_ss_app_pgm_stg.ss_adm_appl_id%TYPE,
                                   p_nominated_course_cd IN igs_ad_edugoal.nominated_course_cd%TYPE,
                                   p_sequence_number     IN igs_ad_edugoal.sequence_number%TYPE); --this procedure has been modified, nshee Bug 2622488
  PROCEDURE transfer_attachment(p_person_id             IN IGS_SS_APPL_PERSTAT.person_id%TYPE,
                                p_ss_adm_appl_id        IN IGS_SS_APPL_PERSTAT.ss_adm_appl_id%TYPE,
                                p_admission_appl_number IN IGS_AD_APPL_PERSTAT.admission_appl_number%TYPE,
                                x_return_status         OUT NOCOPY VARCHAR2);
  -- Bug # 2389273 [ APPLICATION  FEE SAVED IN SS IS NOT SAVED TO FORMS ]
  --** added by nshee
  PROCEDURE insert_application_fee(p_person_id       IN igs_ad_app_req.person_id%TYPE,
                                   p_adm_appl_id     IN igs_ss_app_req_stg.ss_adm_appl_id%TYPE,
                                   p_adm_appl_number IN igs_ad_app_req.admission_appl_number%TYPE);
  --** end of addtion by nshee


  -- begin apadegal
 -- Procedure to set the admin security on
  PROCEDURE  set_adm_secur_on IS
  BEGIN
    IGS_AD_SS_GEN_001.g_admin_security_on := 'Y';
  END;
 -- proceudre to set the admin security off
  PROCEDURE  set_adm_secur_off IS
  BEGIN
    IGS_AD_SS_GEN_001.g_admin_security_on := 'N';
  END;
  -- end apadegal


  --Main Proc to transfer data from Staging to IGS tables.
  PROCEDURE transfer_data(x_person_id       IN NUMBER,
                          x_application_id  IN NUMBER,
                          x_message_name    OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          p_adm_appl_number OUT NOCOPY NUMBER) AS

    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1.Main Procedure for
               a.Creating an admission application
               b.Creating Programs for the Application Created.
             2.If transfer is successful , it returns a success indicator to the calling routine(SS Application in this case)
       3.In Case of failure, it returns a failed indicator.
       4.On Successful Transfer of data , deletes the Staging table Data.
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    *****************************************************************************************/

    l_message_name                VARCHAR2(2000);
    l_return_status               VARCHAR2(2);
    l_admission_appl_number       IGS_AD_APPL.admission_appl_number%TYPE;
    l_msg_index                   NUMBER;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    p_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

    --Cursor Declaration
    CURSOR c_adm_appl IS
      SELECT *
        FROM igs_ss_adm_appl_stg
       WHERE person_id = x_person_id
         AND ss_adm_appl_id = x_application_id;

    c_adm_appl_rec c_adm_appl%ROWTYPE;

  BEGIN
    logHeader('transfer_data', 'S');
    -- Set the G_CALLED_FROM to 'S' to skip the commit happening in Tracking item completion job
    IGS_AD_TI_COMP.G_CALLED_FROM := 'S';
    l_msg_index := IGS_GE_MSG_STACK.count_msg;

    OPEN c_adm_appl;
    FETCH c_adm_appl
      INTO c_adm_appl_rec;
    CLOSE c_adm_appl;
    SAVEPOINT sp_save_point1;
    c_adm_appl_rec.APPL_DATE := SYSDATE;
    IF create_application(p_appl_rec        => c_adm_appl_rec,
                          p_message_name    => l_message_name,
                          p_return_status   => l_return_status,
                          p_adm_appl_number => l_admission_appl_number) THEN
      IF create_program(p_appl_rec        => c_adm_appl_rec,
                        p_message_name    => l_message_name,
                        p_return_status   => l_return_status,
                        p_adm_appl_number => l_admission_appl_number) THEN
         IF create_application_detail(p_person_id         => c_adm_appl_rec.person_id,
                              p_adm_appl_number           => l_admission_appl_number,
                              p_ss_adm_appl_number        => c_adm_appl_rec.ss_adm_appl_id) THEN
         logDetail('create_program         ' || ' is successul ' ||
                  ' Person Id : ' ||
                  IGS_GE_NUMBER.TO_CANN(c_adm_appl_rec.person_id),
                  'S');
         END IF;

      ELSE
        --Program import failed, Set the message and return, in calling proc , check for ret_stat , if 'E' set message sent from here
        IF FND_MSG_PUB.Count_Msg < 1 AND  l_message_name IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('IGS', l_message_name);
          IGS_GE_MSG_STACK.ADD;
        END IF;
        x_message_name  := l_message_name;
        x_return_status := l_return_status;
        RETURN;
      END IF;
    ELSE
      --Application import failed, Set the message and return, in calling proc , check for ret_stat , if 'E' set message sent from here
      IF FND_MSG_PUB.Count_Msg < 1 AND   l_message_name IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('IGS', l_message_name);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      x_message_name  := l_message_name;
      x_return_status := l_return_status;
      RETURN;
    END IF;


    -- Removing the call from this procedure. Calling Explicitly in Terms and Detials page of Self Service
    /* delete_ss_appl_stg(x_message_name    => l_message_name,
                       x_return_status   => l_return_status,
                       p_adm_appl_number => x_application_id,
                       p_person_id       => x_person_id);
    */
    IF l_return_status NOT IN ('E') OR l_return_status IS NULL THEN
      x_return_status   := 'S'; --Indicate Success, To be used in Calling Proc , if Status = 'S' , then commit data.
      p_adm_appl_number := l_admission_appl_number; -- Return the Admission Application Number as OUT NOCOPY Parameter to the calling procedure
    END IF;
  EXCEPTION
    --Main Loop Exception
    WHEN OTHERS THEN
      logDetail('Exception from transfer_data, ' || SQLERRM, 'S');
      x_return_status := 'E';

      IF l_message_name <> 'IGS_SC_POLICY_EXCEPTION' AND l_message_name <> 'IGS_GE_UNHANDLED_EXP'  AND
          FND_MSG_PUB.Count_Msg < 1 THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.transfer_data -'||SQLERRM);
            IGS_GE_MSG_STACK.ADD;
            x_message_name := 'IGS_GE_UNHANDLED_EXP';
      END IF;
      App_Exception.Raise_Exception;
      --     App_Exception.Raise_Exception;  x_return_status is an OUT NOCOPY parameter and will not show the value set, for it if the exception is raised. So commenting out NOCOPY Bug# 2224624
  END transfer_data;

  --This Function Creates an Application and Returns TRUE if Application is created.
  FUNCTION create_application(p_appl_rec        IN igs_ss_adm_appl_stg%ROWTYPE,
                              p_message_name    OUT NOCOPY VARCHAR2,
                              p_return_status   OUT NOCOPY VARCHAR2,
                              p_adm_appl_number OUT NOCOPY NUMBER)
    RETURN BOOLEAN IS

    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1.Creates an admission application
             2.If Application Creation is successful ,returns boolean true
       3.In Case of failure, return boolean False.
       4.Flow:
         a.Check if Mandatory Params are Present
         b.Insert admission application, using Common API Call IGS_AD_GEN_014.insert_adm_appl
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    rrengara   11-jul-2002      Added UK Parameters choice_number and routre pref to insert_adm_appl procedure for bug 2448262 (D) and 2455053 (P)
    knag       21-Nov-2002   Added alt_appl_id param to call to insert_adm_appl for bug 2664410
    pbondugu  28-Mar-2003    Passed  funding_source as NULL   to procedure call IGS_AD_GEN_014.insert_adm_appl_prog_inst
    *****************************************************************************************/

    --Local Var Declaration
    l_message_name          VARCHAR2(2000);
    l_adm_appl_status       IGS_AD_APPL_STAT.adm_appl_status%TYPE;
    l_adm_fee_status        IGS_AD_FEE_STAT.adm_fee_status%TYPE;
    l_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE;

  BEGIN
    --Main Begin

    logHeader('create_application', 'S');

    ----------------------------------------
    -- Check if Mandatory Params are Present
    ----------------------------------------
    IF p_appl_rec.acad_cal_type IS NULL OR
       p_appl_rec.acad_cal_seq_number IS NULL OR
       p_appl_rec.adm_cal_type IS NULL OR
       p_appl_rec.adm_cal_seq_number IS NULL THEN

      p_message_name  := 'IGS_SS_SEM_NOT_SUFFICI';
      p_return_status := 'E';
      logDetail('Failed in Create Application, Insufficient Sem Args', 'S');
      RETURN FALSE;
    END IF;

    IF p_appl_rec.person_id IS NULL OR p_appl_rec.appl_date IS NULL THEN
      p_message_name  := 'IGS_SS_PERSDTLS_NOT_SUFFICI';
      p_return_status := 'E';
      logDetail('Failed in Create Application, Insufficient Pers Dtls',
                'S');
    END IF;

    ----------------------------------
    -- Insert admission application
    ----------------------------------
    l_adm_appl_status := Igs_Ad_Gen_008.ADMP_GET_SYS_AAS('RECEIVED');
    l_adm_fee_status  := Igs_Ad_Gen_009.ADMP_GET_SYS_AFS('NOT-APPLIC');

    logDetail('Before call to IGS_AD_GEN_014.insert_adm_appl', 'S');
    IF IGS_AD_GEN_014.insert_adm_appl( -- IF :1
                                      p_person_id                => p_appl_rec.person_id,
                                      p_appl_dt                  => p_appl_rec.appl_date,
                                      p_acad_cal_type            => p_appl_rec.acad_cal_type,
                                      p_acad_ci_sequence_number  => p_appl_rec.acad_cal_seq_number,
                                      p_adm_cal_type             => p_appl_rec.adm_cal_type,
                                      p_adm_ci_sequence_number   => p_appl_rec.adm_cal_seq_number,
                                      p_admission_cat            => p_appl_rec.admission_cat,
                                      p_s_admission_process_type => p_appl_rec.s_adm_process_type,
                                      p_adm_appl_status          => l_adm_appl_status,
                                      p_adm_fee_status           => l_adm_fee_status, --IN/OUT
                                      p_tac_appl_ind             => 'N',
                                      p_adm_appl_number          => l_admission_appl_number, --OUT
                                      p_message_name             => l_message_name, --OUT
                                      p_spcl_grp_1               => p_appl_rec.spcl_grp_1,
                                      p_spcl_grp_2               => p_appl_rec.spcl_grp_2,
                                      p_common_app               => NULL,
                                      p_application_type         => p_appl_rec.admission_application_type,
                                      p_choice_number            => null,
                                      p_routeb_pref              => NULL,
                                      p_alt_appl_id              => NULL,
                                      p_appl_fee_amt             => p_appl_rec.appl_fee_amt) =
       FALSE THEN

      ROLLBACK TO sp_save_point1;
      p_message_name  := l_message_name;
      p_return_status := 'E';
      logDetail('IGS_AD_GEN_014.insert_adm_appl Failed,Returned with FALSE and Message: ' ||
                l_message_name,
                'S');
      RETURN FALSE;
    ELSE

        p_adm_appl_number := l_admission_appl_number;
        p_return_status   := 'S';
        RETURN TRUE;
    END IF;

  EXCEPTION
    --Main Loop Exception
    WHEN OTHERS THEN
      p_return_status := 'E';
      logDetail('Exception from create_application, MAIN LOOP: ' || SQLERRM, 'S');

      IF l_message_name <> 'IGS_SC_POLICY_EXCEPTION' AND l_message_name <> 'IGS_GE_UNHANDLED_EXP'  AND
          FND_MSG_PUB.Count_Msg < 1 THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.create_application -'||SQLERRM);
            IGS_GE_MSG_STACK.ADD;
            p_message_name := 'IGS_GE_UNHANDLED_EXP';
      END IF;
      App_Exception.Raise_Exception;

  END create_application; --Main End

  --This Function Creates Program Application and Program Application Instance
  FUNCTION create_program(p_appl_rec        IN igs_ss_adm_appl_stg%ROWTYPE,
                          p_message_name    OUT NOCOPY VARCHAR2,
                          p_return_status   OUT NOCOPY VARCHAR2,
                          p_adm_appl_number IN NUMBER) RETURN BOOLEAN AS
    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1.Creates a program for Application Created
             2.If Program Creation/Import is successful ,returns boolean true
       3.In Case of failure, return boolean False.
       4.Flow:
         a.Insert Admission Program Application (IGS_AD_GEN_014.insert_adm_appl_prog)
         b.validate descriptive flexfield columns.
         c.Insert Admission Program Application Instance (IGS_AD_GEN_014.insert_adm_appl_prog_inst)
         d.Change Person Type To Applicant (update_person_type- Local Procedure Call)
         e.Insert Unit Set Details (Major First Choice/Major Second Choice) (insert_unit_set_dtls- Local Procedure Call)
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    *****************************************************************************************/

    --Local Variable Declarations
    l_message_name        VARCHAR2(2000);
    v_hecs_payment_option IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE;
    l_adm_fee_status      IGS_AD_FEE_STAT.adm_fee_status%TYPE;
    v_sequence_number     IGS_AD_PS_APPL_INST.sequence_number%TYPE;
    l_return_type         VARCHAR2(127);
    l_error_code          VARCHAR2(30);

    CURSOR c_admappl_pgm IS
      SELECT d.*, m.app_source_id
        FROM igs_ss_adm_appl_stg m, IGS_SS_APP_PGM_STG d
       WHERE m.ss_adm_appl_id = d.ss_adm_appl_id
         AND m.ss_adm_appl_id = p_appl_rec.ss_adm_appl_id
         AND m.person_id = p_appl_rec.person_id;
--Autoadmit
  l_error_text     VARCHAR2(2000);
  l_error_code1     NUMBER;
  BEGIN
    logHeader('create_program', 'S');

    FOR c_admappl_pgm_rec in c_admappl_pgm LOOP
      ----------------------------------------
      -- Insert Admission Program Application
      ----------------------------------------
      logDetail('Before call to IGS_AD_GEN_014.insert_adm_appl_prog', 'S');
      IF IGS_AD_GEN_014.insert_adm_appl_prog(p_person_id                   => p_appl_rec.person_id,
                                             p_adm_appl_number             => p_adm_appl_number,
                                             p_nominated_course_cd         => c_admappl_pgm_rec.nominated_course_cd,
                                             p_transfer_course_cd          => NULL,
                                             p_basis_for_admission_type    => NULL,
                                             p_admission_cd                => NULL,
                                             p_req_for_reconsideration_ind => 'N', -- (request for reconsideration indicator)
                                             p_req_for_adv_standing_ind    => 'N', -- (request for advanced standing indicator)
                                             p_message_name                => l_message_name) =
         FALSE THEN

        ROLLBACK TO sp_save_point1;
        p_message_name:= l_message_name;
        p_return_status := 'E';
        logDetail('IGS_AD_GEN_014.insert_adm_appl_prog Failed,Returned with FALSE and Message: ' ||
                  l_message_name,
                  'S');
        RETURN FALSE;
      END IF;
      v_hecs_payment_option := NULL;

      -----------------------------------------------------------
      --To validate descriptive flexfield columns.
      --Need to be modified after DAP, to add attributes 21 to 40
      --This call not needed as the data in DFF is already validated by the Page
      -----------------------------------------------------------
      /*logDetail('before call to IGS_AD_IMP_018.validate_desc_flex','S');
          IF NOT IGS_AD_IMP_018.validate_desc_flex_40_cols
                (     p_attribute_category  => c_admappl_pgm_rec.attribute_category,
              p_attribute1    => c_admappl_pgm_rec.attribute1,
              p_attribute2    => c_admappl_pgm_rec.attribute2,
              p_attribute3    => c_admappl_pgm_rec.attribute3,
              p_attribute4    => c_admappl_pgm_rec.attribute4,
              p_attribute5    => c_admappl_pgm_rec.attribute5,
              p_attribute6    => c_admappl_pgm_rec.attribute6,
              p_attribute7    => c_admappl_pgm_rec.attribute7,
              p_attribute8    => c_admappl_pgm_rec.attribute8,
              p_attribute9    => c_admappl_pgm_rec.attribute9,
              p_attribute10   => c_admappl_pgm_rec.attribute10,
              p_attribute11   => c_admappl_pgm_rec.attribute11,
              p_attribute12   => c_admappl_pgm_rec.attribute12,
              p_attribute13   => c_admappl_pgm_rec.attribute13,
              p_attribute14   => c_admappl_pgm_rec.attribute14,
              p_attribute15   => c_admappl_pgm_rec.attribute15,
              p_attribute16   => c_admappl_pgm_rec.attribute16,
              p_attribute17   => c_admappl_pgm_rec.attribute17,
              p_attribute18   => c_admappl_pgm_rec.attribute18,
              p_attribute19   => c_admappl_pgm_rec.attribute19,
              p_attribute20   => c_admappl_pgm_rec.attribute20,
                                      p_attribute21   => c_admappl_pgm_rec.attribute21,
              p_attribute22   => c_admappl_pgm_rec.attribute22,
                                      p_attribute23   => c_admappl_pgm_rec.attribute23,
              p_attribute24   => c_admappl_pgm_rec.attribute24,
              p_attribute25   => c_admappl_pgm_rec.attribute25,
              p_attribute26   => c_admappl_pgm_rec.attribute26,
              p_attribute27   => c_admappl_pgm_rec.attribute27,
              p_attribute28   => c_admappl_pgm_rec.attribute28,
              p_attribute29   => c_admappl_pgm_rec.attribute29,
              p_attribute30   => c_admappl_pgm_rec.attribute30,
              p_attribute31   => c_admappl_pgm_rec.attribute31,
              p_attribute32   => c_admappl_pgm_rec.attribute32,
              p_attribute33   => c_admappl_pgm_rec.attribute33,
              p_attribute34   => c_admappl_pgm_rec.attribute34,
              p_attribute35   => c_admappl_pgm_rec.attribute35,
              p_attribute36   => c_admappl_pgm_rec.attribute36,
              p_attribute37   => c_admappl_pgm_rec.attribute37,
              p_attribute38   => c_admappl_pgm_rec.attribute38,
              p_attribute39   => c_admappl_pgm_rec.attribute39,
              p_attribute40   => c_admappl_pgm_rec.attribute40,
              p_desc_flex_name  => 'IGS_SS_APP_PGM_STG_FLEX'
            ) THEN
          ROLLBACK TO sp_save_point1;
          p_message_name := 'IGS_AD_INVALID_DESC_FLEX';
          p_return_status := 'E';
          logDetail('IGS_AD_IMP_018.validate_desc_flex Failed,Returned with FALSE and Message: '  || p_message_name,'S');
            RETURN FALSE;
              END IF;
      */
      ------------------------------------------------
      -- Insert Admission Program Application Instance
      ------------------------------------------------
      l_adm_fee_status := Igs_Ad_Gen_009.ADMP_GET_SYS_AFS('NOT-APPLIC');

      -- Setting Person Mandatory Validations to False
      IGS_PE_GEN_004.SKIP_MAND_DATA_VAL;


      logDetail('before call to local proc insert_adm_appl_prog_inst', 'S');
      IF IGS_AD_GEN_014.insert_adm_appl_prog_inst(p_person_id                => p_appl_rec.person_id,
                                                  p_admission_appl_number    => p_adm_appl_number,
                                                  p_acad_cal_type            => p_appl_rec.acad_cal_type,
                                                  p_acad_ci_sequence_number  => p_appl_rec.acad_cal_seq_number,
                                                  p_adm_cal_type             => p_appl_rec.adm_cal_type,
                                                  p_adm_ci_sequence_number   => p_appl_rec.adm_cal_seq_number,
                                                  p_admission_cat            => p_appl_rec.admission_cat,
                                                  p_s_admission_process_type => p_appl_rec.s_adm_process_type,
                                                  p_appl_dt                  => p_appl_rec.appl_date,
                                                  p_adm_fee_status           => l_adm_fee_status,
                                                  p_preference_number        => c_admappl_pgm_rec.preference_number,
                                                  p_offer_dt                 => NULL,
                                                  p_offer_response_dt        => NULL,
                                                  p_course_cd                => c_admappl_pgm_rec.nominated_course_cd,
                                                  p_crv_version_number       => c_admappl_pgm_rec.crv_version_number,
                                                  p_location_cd              => c_admappl_pgm_rec.location_cd,
                                                  p_attendance_mode          => c_admappl_pgm_rec.attendance_mode,
                                                  p_attendance_type          => c_admappl_pgm_rec.attendance_type,
                                                  p_unit_set_cd              => c_admappl_pgm_rec.final_unit_set_cd, --earlier passed as null, build 2622488 nshee
                                                  p_us_version_number        => c_admappl_pgm_rec.final_unit_set_cd_ver, --earlier passed as null, build 2622488 nshee
                                                  p_fee_cat                  => NULL,
                                                  p_correspondence_cat       => NULL,
                                                  p_enrolment_cat            => NULL,
                                                  p_funding_source           => NULL,
                                                  p_edu_goal_prior_enroll    => c_admappl_pgm_rec.edu_goal_prior_enroll,
                                                  p_app_source_id            => c_admappl_pgm_rec.app_source_id,
                                                  p_apply_for_finaid         => c_admappl_pgm_rec.apply_for_finaid,
                                                  p_finaid_apply_date        => c_admappl_pgm_rec.finaid_apply_date,
                                                  p_attribute_category       => c_admappl_pgm_rec.attribute_category,
                                                  p_attribute1               => c_admappl_pgm_rec.attribute1,
                                                  p_attribute2               => c_admappl_pgm_rec.attribute2,
                                                  p_attribute3               => c_admappl_pgm_rec.attribute3,
                                                  p_attribute4               => c_admappl_pgm_rec.attribute4,
                                                  p_attribute5               => c_admappl_pgm_rec.attribute5,
                                                  p_attribute6               => c_admappl_pgm_rec.attribute6,
                                                  p_attribute7               => c_admappl_pgm_rec.attribute7,
                                                  p_attribute8               => c_admappl_pgm_rec.attribute8,
                                                  p_attribute9               => c_admappl_pgm_rec.attribute9,
                                                  p_attribute10              => c_admappl_pgm_rec.attribute10,
                                                  p_attribute11              => c_admappl_pgm_rec.attribute11,
                                                  p_attribute12              => c_admappl_pgm_rec.attribute12,
                                                  p_attribute13              => c_admappl_pgm_rec.attribute13,
                                                  p_attribute14              => c_admappl_pgm_rec.attribute14,
                                                  p_attribute15              => c_admappl_pgm_rec.attribute15,
                                                  p_attribute16              => c_admappl_pgm_rec.attribute16,
                                                  p_attribute17              => c_admappl_pgm_rec.attribute17,
                                                  p_attribute18              => c_admappl_pgm_rec.attribute18,
                                                  p_attribute19              => c_admappl_pgm_rec.attribute19,
                                                  p_attribute20              => c_admappl_pgm_rec.attribute20,
                                                  p_attribute21              => c_admappl_pgm_rec.attribute21,
                                                  p_attribute22              => c_admappl_pgm_rec.attribute22,
                                                  p_attribute23              => c_admappl_pgm_rec.attribute23,
                                                  p_attribute24              => c_admappl_pgm_rec.attribute24,
                                                  p_attribute25              => c_admappl_pgm_rec.attribute25,
                                                  p_attribute26              => c_admappl_pgm_rec.attribute26,
                                                  p_attribute27              => c_admappl_pgm_rec.attribute27,
                                                  p_attribute28              => c_admappl_pgm_rec.attribute28,
                                                  p_attribute29              => c_admappl_pgm_rec.attribute29,
                                                  p_attribute30              => c_admappl_pgm_rec.attribute30,
                                                  p_attribute31              => c_admappl_pgm_rec.attribute31,
                                                  p_attribute32              => c_admappl_pgm_rec.attribute32,
                                                  p_attribute33              => c_admappl_pgm_rec.attribute33,
                                                  p_attribute34              => c_admappl_pgm_rec.attribute34,
                                                  p_attribute35              => c_admappl_pgm_rec.attribute35,
                                                  p_attribute36              => c_admappl_pgm_rec.attribute36,
                                                  p_attribute37              => c_admappl_pgm_rec.attribute37,
                                                  p_attribute38              => c_admappl_pgm_rec.attribute38,
                                                  p_attribute39              => c_admappl_pgm_rec.attribute39,
                                                  p_attribute40              => c_admappl_pgm_rec.attribute40,
                                                  p_ss_application_id        => NULL,
                                                  p_sequence_number          => v_sequence_number,
                                                  p_return_type              => l_return_type,
                                                  p_error_code               => l_error_code,
                                                  p_message_name             => l_message_name,
                                                  p_entry_status             => c_admappl_pgm_rec.entry_status,
                                                  p_entry_level              => c_admappl_pgm_rec.entry_level,
                                                  p_sch_apl_to_id            => c_admappl_pgm_rec.sch_apl_to_id) =
         FALSE THEN

        ROLLBACK TO sp_save_point1;
        p_message_name  := l_message_name;
        p_return_status := 'E';
        logDetail('insert_adm_appl_prog_inst Failed,Returned with FALSE and Message: ' ||
                  l_message_name,
                  'S');
        RETURN FALSE;
      ELSE
        -- insert_adm_appl_prog_inst Returns with TRUE , since Program is transferred, rest of the processing can proceed.

        -----------------------------------------------------------------
        -- Insert Unit Set Details (Major First Choice/Major Second Choice)
        -----------------------------------------------------------------
        /*      IF c_admappl_pgm_rec.unit_set_1 IS NOT NULL THEN
            insert_unit_set_dtls(p_sequence_number     =>v_sequence_number
                                    ,p_nominated_course_cd   =>c_admappl_pgm_rec.nominated_course_cd
                    ,p_person_id             =>p_appl_rec.person_id
                  ,p_adm_appl_number       =>p_adm_appl_number
                  ,p_unit_set_cd           =>c_admappl_pgm_rec.unit_set_1
                  ,p_ver_no                =>c_admappl_pgm_rec.unit_set_1_ver_number);
              END IF;

        IF c_admappl_pgm_rec.unit_set_2 IS NOT NULL THEN
            insert_unit_set_dtls(p_sequence_number     =>v_sequence_number
                                    ,p_nominated_course_cd   =>c_admappl_pgm_rec.nominated_course_cd
                  ,p_person_id             =>p_appl_rec.person_id
                  ,p_adm_appl_number       =>p_adm_appl_number
                  ,p_unit_set_cd           =>c_admappl_pgm_rec.unit_set_2
                  ,p_ver_no                =>c_admappl_pgm_rec.unit_set_2_ver_number);
              END IF;*/ --not needed anymore since Major1, Major2 are obsolete. build 2622488
        ------------------------------------------------------------------
        -- Insert EduGoal Details (Post Enroll) For The Appl Prog Instance
        ------------------------------------------------------------------
        IF c_admappl_pgm_rec.nominated_course_cd IS NOT NULL AND
           v_sequence_number IS NOT NULL THEN
          insert_edugoal_details(p_person_id           => p_appl_rec.person_id,
                                 p_adm_appl_number     => p_adm_appl_number,
                                 p_ss_adm_appl_id      => c_admappl_pgm_rec.ss_adm_appl_id,
                                 p_nominated_course_cd => c_admappl_pgm_rec.nominated_course_cd,
                                 p_sequence_number     => v_sequence_number);
          insert_unit_set_dtls(p_person_id           => p_appl_rec.person_id,
                               p_adm_appl_number     => p_adm_appl_number,
                               p_nominated_course_cd => c_admappl_pgm_rec.nominated_course_cd,
                               p_sequence_number     => v_sequence_number,
                               p_ss_adm_appl_id      => c_admappl_pgm_rec.ss_adm_appl_id); --added this call build 2622488
        END IF;
--      Call The assign requirment procedure and admission tracking completion Procedure *** Autoadmit
-- This single process will call both the procedure
    IGS_AD_GEN_014.auto_assign_requirement(
                        p_person_id                 => p_appl_rec.person_id,
                        p_admission_appl_number     => p_adm_appl_number,
                        p_course_cd                 => c_admappl_pgm_rec.nominated_course_cd,
                        p_sequence_number           => v_sequence_number,
                        p_called_from         => 'SS',
                        p_error_text          => l_error_text,
                        p_error_code          => l_error_code1
    );

--Assign Qualification Types to application instance being submitted
   IGS_AD_GEN_014.assign_qual_type(p_person_id         => p_appl_rec.person_id,
                                 p_admission_appl_number     => p_adm_appl_number,
                                 p_course_cd => c_admappl_pgm_rec.nominated_course_cd,
                                 p_sequence_number     => v_sequence_number
   );
   igs_ad_wf_001.wf_raise_event(p_person_id => p_appl_rec.person_id,
                                p_raised_for => 'SAC',
                                p_admission_appl_number => p_adm_appl_number,
                                p_nominated_course_cd =>c_admappl_pgm_rec.nominated_course_cd,
                                p_sequence_number => v_sequence_number
                                 );

      END IF; -- insert_adm_appl_prog_inst IF ends.
    END LOOP; -- LOOP for Main Cursor Ends
    RETURN TRUE; -- Reaches Here Means That All The Programs For The Application Has Been Imported To OSS
  EXCEPTION
    --Main Exception
    WHEN OTHERS THEN
      p_return_status := 'E';
      logDetail('Exception from create_program, MAIN LOOP: ' || SQLERRM, 'S');

      IF l_message_name <> 'IGS_SC_POLICY_EXCEPTION' AND l_message_name <> 'IGS_GE_UNHANDLED_EXP' AND
          FND_MSG_PUB.Count_Msg < 1 THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.create_program -'||SQLERRM);
            IGS_GE_MSG_STACK.ADD;
            p_message_name := 'IGS_GE_UNHANDLED_EXP';
      END IF;
      App_Exception.Raise_Exception;

  END create_program;

  PROCEDURE update_person_type(p_sequence_number     IN igs_pe_typ_instances_all.sequence_number%TYPE,
                               p_nominated_course_cd IN igs_pe_typ_instances_all.nominated_course_cd%TYPE,
                               p_person_id           IN igs_pe_typ_instances_all.person_id%TYPE,
                               p_adm_appl_number     IN igs_pe_typ_instances_all.admission_appl_number%TYPE) AS

    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose:
            1. Updates Person Type to Applicant on Successful Import/Transfer of the Application/Prog/Prog Inst
      2. Flow:
              a.IGS_PE_TYP_INSTANCES_PKG.insert_row

    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    npalanis     10-JUN-2003    Bug:2923413 igs_pe_typ_instances_pkg.update_row call
                                modified for the new employment category column added in the table
    *****************************************************************************************/

    l_rowid            VARCHAR2(25);
    l_org_id           NUMBER(15);
    l_type_instance_id NUMBER;
    l_person_type_code IGS_PE_PERSON_TYPES.person_type_code%TYPE;

    CURSOR c_person_type_code(l_system_type IGS_PE_PERSON_TYPES.system_type%TYPE) IS
      SELECT person_type_code
        FROM igs_pe_person_types
       WHERE system_type = l_system_type;
   lv_mode VARCHAR2(1) DEFAULT 'R';
  BEGIN
    --Begin Local Loop 1
    logHeader('transfer_data', 'S');
    l_org_id := igs_ge_gen_003.get_org_id;

    OPEN c_person_type_code('APPLICANT');
    FETCH c_person_type_code
      INTO l_person_type_code;
    CLOSE c_person_type_code;
    logDetail('Before call to IGS_PE_TYP_INSTANCES_PKG.insert_row', 'S');

    -- Setting Person Mandatory Validations to False
    IGS_PE_GEN_004.SKIP_MAND_DATA_VAL;


    IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;

    IGS_PE_TYP_INSTANCES_PKG.insert_row(x_rowid                 => l_rowid,
                                        x_org_id                => l_org_id,
                                        x_person_id             => p_person_id,
                                        x_course_cd             => NULL,
                                        x_type_instance_id      => l_type_instance_id,
                                        x_person_type_code      => l_person_type_code,
                                        x_cc_version_number     => NULL,
                                        x_funnel_status         => NULL,
                                        x_admission_appl_number => p_adm_appl_number,
                                        x_nominated_course_cd   => p_nominated_course_cd, --c_admappl_pgm_rec.nominated_course_cd,
                                        x_ncc_version_number    => NULL,
                                        x_sequence_number       => p_sequence_number,
                                        x_start_date            => SYSDATE,
                                        x_end_date              => NULL,
                                        x_create_method         => 'CREATE_APPL_INSTANCE',
                                        x_ended_by              => NULL,
                                        x_end_method            => NULL,
                                        x_mode                  => lv_mode,  -- enable security for Admin
                                        x_emplmnt_category_code => null);
    logDetail('Person_type Changed to APPLICANT for the person', 'S');
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('inside update_person_type' ||
                'Exception from IGS_PE_TYP_INSTANCES_PKG.insert_row ' ||
                SQLERRM || 'person_id : ' ||
                IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.update_person_type -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END update_person_type;

  PROCEDURE insert_unit_set_dtls(p_sequence_number     IN igs_ad_unit_sets.sequence_number%TYPE,
                                 p_nominated_course_cd IN igs_ad_unit_sets.nominated_course_cd%TYPE,
                                 p_person_id           IN igs_ad_unit_sets.person_id%TYPE,
                                 p_adm_appl_number     IN igs_ad_unit_sets.admission_appl_number%TYPE,
                                 p_ss_adm_appl_id      IN igs_ss_app_pgm_stg.ss_adm_appl_id%TYPE) AS
    --           ,p_unit_set_cd             IN igs_ad_unit_sets.unit_set_cd%TYPE
    --           ,p_ver_no                  IN igs_ad_unit_sets.version_number%TYPE) AS
    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Inserts Unit Set Details (Major1/Major2)
             FLOW: IGS_AD_UNIT_SETS_PKG.insert_row
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    nshee      29-OCT-2002 Modified it, now it inserts data from desired unit sets and not the major1/major2.
    *****************************************************************************************/
    l_rowid       VARCHAR2(25);
    l_unit_set_id igs_ad_unit_sets.unit_set_id%TYPE;
    l_rank        igs_ad_unit_sets.rank%TYPE;
    lv_mode VARCHAR2(1) DEFAULT 'R';
    /*
    CURSOR c_nxt_rank IS
     SELECT MAX(rank), 0) + 1
     FROM igs_ad_unit_sets
     WHERE
     person_id    = p_person_id   AND
     admission_appl_number  = p_adm_appl_number AND
     nominated_course_cd  = p_nominated_course_cd;
    */

    CURSOR c_des_unit_sets IS
      SELECT unit_set_cd, version_number, rank
        FROM igs_ss_ad_unitse_stg
       WHERE ss_admappl_pgm_id =
             (SELECT ss_admappl_pgm_id
                FROM igs_ss_app_pgm_stg
               WHERE ss_adm_appl_id = p_ss_adm_appl_id --p_adm_appl_number
                 AND nominated_course_cd = p_nominated_course_cd
                 AND person_id = p_person_id);
  BEGIN
    logHeader('insert_unit_set_dtls', 'S');

    /*OPEN c_nxt_rank;
    FETCH c_nxt_rank INTO l_rank;
    CLOSE c_nxt_rank;*/

    FOR c_des_unit_sets_rec IN c_des_unit_sets LOOP
      IF c_des_unit_sets_rec.unit_set_cd IS NOT NULL THEN
        logDetail('Before call to IGS_AD_UNIT_SETS_PKG.insert_row', 'S');
        l_rowid       := '';
        l_unit_set_id := 0;


            IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
            THEN
              lv_mode := 'S';
            END IF;

        IGS_AD_UNIT_SETS_PKG.insert_row(x_rowid                 => l_rowid,
                                        x_unit_set_id           => l_unit_set_id,
                                        x_person_id             => p_person_id,
                                        x_admission_appl_number => p_adm_appl_number,
                                        x_nominated_course_cd   => p_nominated_course_cd,
                                        x_sequence_number       => p_sequence_number,
                                        x_unit_set_cd           => c_des_unit_sets_rec.unit_set_cd,
                                        x_version_number        => c_des_unit_sets_rec.version_number,
                                        x_rank                  => c_des_unit_sets_rec.rank,
                                        x_mode                  => lv_mode -- enable security for Admin
                                        );
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Inside insert_unit_set_dtls' ||
                'Exception from IGS_AD_UNIT_SETS_PKG.insert_row ' ||
                SQLERRM || 'person_id : ' ||
                IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_unit_set_dtls -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;

      App_Exception.Raise_Exception;
  END insert_unit_set_dtls;

  --added by nshee during build for Applicant-BOSS SS Bug 2622488
  PROCEDURE insert_acad_interest(p_person_id       IN igs_ad_acad_interest.person_id%TYPE,
                                 p_adm_appl_id     IN igs_ss_ad_acadin_stg.ss_adm_appl_id%TYPE,
                                 p_adm_appl_number IN igs_ad_acad_interest.admission_appl_number%TYPE) AS
    /*****************************************************************************************
    Created By: Nilotpal.Shee@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Inserts Academic Honors Details (For an Application)
             FLOW: IGS_AD_ACAD_HONORS_PKG.insert_row
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    *****************************************************************************************/

    l_rowid            VARCHAR2(25);
    l_acad_interest_id igs_ad_acad_interest.acad_interest_id%TYPE;
    lv_mode VARCHAR2(1) DEFAULT 'R';
    CURSOR c_acad_interest IS
      SELECT field_of_study
        FROM igs_ss_ad_acadin_stg
       WHERE ss_adm_appl_id = p_adm_appl_id;

  BEGIN
    logHeader('insert_acad_interest', 'S');
    FOR c_acad_interest_rec IN c_acad_interest LOOP
      IF c_acad_interest_rec.field_of_study IS NOT NULL THEN
        logDetail('Before call to IGS_AD_ACAD_INTEREST_PKG.insert_row',
                  'S');
        l_rowid            := '';
        l_acad_interest_id := 0;


            IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
            THEN
              lv_mode := 'S';
            END IF;


        IGS_AD_ACAD_INTEREST_PKG.insert_row(x_rowid                 => l_rowid,
                                            x_acad_interest_id      => l_acad_interest_id,
                                            x_person_id             => p_person_id,
                                            x_admission_appl_number => p_adm_appl_number,
                                            x_field_of_study        => c_acad_interest_rec.field_of_study,
                                            x_mode                  => lv_mode -- enable security for Admin
                                            );
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN

      logDetail('Inside insert_acad_interest' ||
                'Exception from IGS_AD_ACAD_INTEREST_PKG.insert_row ' ||
                SQLERRM || 'person_id : ' ||
                IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
         Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_acad_interest -'||SQLERRM);
         IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END insert_acad_interest;

  PROCEDURE insert_applicant_intent(p_person_id       IN igs_ad_app_intent.person_id%TYPE,
                                    p_adm_appl_id     IN igs_ss_ad_appint_stg.ss_adm_appl_id%TYPE,
                                    p_adm_appl_number IN igs_ad_app_intent.admission_appl_number%TYPE) AS
    /*****************************************************************************************
    Created By: Nilotpal.Shee@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Inserts Academic Honors Details (For an Application)
             FLOW: IGS_AD_ACAD_HONORS_PKG.insert_row
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    *****************************************************************************************/

    l_rowid         VARCHAR2(25);
    l_app_intent_id igs_ad_app_intent.app_intent_id%TYPE;
    lv_mode VARCHAR2(1) DEFAULT 'R';

    CURSOR c_applicant_intent IS
      SELECT intent_type_id
        FROM igs_ss_ad_appint_stg
       WHERE ss_adm_appl_id = p_adm_appl_id;

  BEGIN
    logHeader('insert_applicant_intent', 'S');
    FOR c_applicant_intent_rec IN c_applicant_intent LOOP
      IF c_applicant_intent_rec.intent_type_id IS NOT NULL THEN
        logDetail('Before call to IGS_AD_APP_INTENT_PKG.insert_row', 'S');
        l_rowid         := '';
        l_app_intent_id := 0;

         IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
            THEN
              lv_mode := 'S';
            END IF;
        IGS_AD_APP_INTENT_PKG.insert_row(x_rowid                 => l_rowid,
                                         x_app_intent_id         => l_app_intent_id,
                                         x_person_id             => p_person_id,
                                         x_admission_appl_number => p_adm_appl_number,
                                         x_intent_type_id        => c_applicant_intent_rec.intent_type_id,
                                         x_attribute_category    => NULL,
                                         x_attribute1            => NULL,
                                         x_attribute2            => NULL,
                                         x_attribute3            => NULL,
                                         x_attribute4            => NULL,
                                         x_attribute5            => NULL,
                                         x_attribute6            => NULL,
                                         x_attribute7            => NULL,
                                         x_attribute8            => NULL,
                                         x_attribute9            => NULL,
                                         x_attribute10           => NULL,
                                         x_attribute11           => NULL,
                                         x_attribute12           => NULL,
                                         x_attribute13           => NULL,
                                         x_attribute14           => NULL,
                                         x_attribute15           => NULL,
                                         x_attribute16           => NULL,
                                         x_attribute17           => NULL,
                                         x_attribute18           => NULL,
                                         x_attribute19           => NULL,
                                         x_attribute20           => NULL,
                                         x_mode                  => lv_mode -- enable security for Admin
                                         );
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Inside insert_applicant_intent' ||
                'Exception from IGS_AD_APP_INTENT_PKG.insert_row ' ||
                SQLERRM || 'person_id : ' ||
                IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_applicant_intent -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END insert_applicant_intent;

  PROCEDURE insert_spl_talent(p_person_id       IN igs_ad_spl_talents.person_id%TYPE,
                              p_adm_appl_id     IN igs_ss_ad_spltal_stg.ss_adm_appl_id%TYPE,
                              p_adm_appl_number IN igs_ad_spl_talents.admission_appl_number%TYPE) AS
    /*****************************************************************************************
    Created By: Nilotpal.Shee@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Inserts Academic Honors Details (For an Application)
             FLOW: IGS_AD_ACAD_HONORS_PKG.insert_row
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    *****************************************************************************************/

    l_rowid         VARCHAR2(25);
    l_spl_talent_id igs_ad_spl_talents.spl_talent_id%TYPE;
    lv_mode VARCHAR2(1) DEFAULT 'R';

    CURSOR c_spl_talent IS
      SELECT special_talent_type_id
        FROM igs_ss_ad_spltal_stg
       WHERE ss_adm_appl_id = p_adm_appl_id;

  BEGIN
    logHeader('insert_spl_talent', 'S');
    FOR c_spl_talent_rec IN c_spl_talent LOOP
      IF c_spl_talent_rec.special_talent_type_id IS NOT NULL THEN
        logDetail('Before call to IGS_AD_SPL_TALENTS_PKG.insert_row', 'S');
        l_rowid         := '';
        l_spl_talent_id := 0;


        IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
            THEN
              lv_mode := 'S';
            END IF;
        IGS_AD_SPL_TALENTS_PKG.insert_row(x_rowid                  => l_rowid,
                                          x_spl_talent_id          => l_spl_talent_id,
                                          x_person_id              => p_person_id,
                                          x_admission_appl_number  => p_adm_appl_number,
                                          x_special_talent_type_id => c_spl_talent_rec.special_talent_type_id,
                                          x_mode                  => lv_mode -- enable security for Admin
                                          );
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Inside insert_spl_talent' ||
                'Exception from IGS_AD_SPL_TALENTS_PKG.insert_row ' ||
                SQLERRM || 'person_id : ' ||
                IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_spl_talent -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END insert_spl_talent;

  PROCEDURE insert_special_interest(p_person_id       IN igs_ad_spl_interests.person_id%TYPE,
                                    p_adm_appl_id     IN igs_ss_ad_splint_stg.ss_adm_appl_id%TYPE,
                                    p_adm_appl_number IN igs_ad_spl_interests.admission_appl_number%TYPE) AS
    /*****************************************************************************************
    Created By: Nilotpal.Shee@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Inserts Academic Honors Details (For an Application)
             FLOW: IGS_AD_ACAD_HONORS_PKG.insert_row
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    *****************************************************************************************/
    l_rowid           VARCHAR2(25);
    l_spl_interest_id igs_ad_spl_interests.spl_interest_id%TYPE;
    lv_mode VARCHAR2(1) DEFAULT 'R';

    CURSOR c_special_interest IS
      SELECT special_interest_type_id
        FROM igs_ss_ad_splint_stg
       WHERE ss_adm_appl_id = p_adm_appl_id;

  BEGIN
    logHeader('insert_special_interest', 'S');
    FOR c_special_interest_rec IN c_special_interest LOOP
      IF c_special_interest_rec.special_interest_type_id IS NOT NULL THEN
        logDetail('Before call to  IGS_AD_SPL_INTERESTS_PKG.insert_row',
                  'S');
        l_rowid           := '';
        l_spl_interest_id := 0;

        IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
            THEN
              lv_mode := 'S';
            END IF;

        IGS_AD_SPL_INTERESTS_PKG.insert_row(x_rowid                    => l_rowid,
                                            x_spl_interest_id          => l_spl_interest_id,
                                            x_person_id                => p_person_id,
                                            x_admission_appl_number    => p_adm_appl_number,
                                            x_special_interest_type_id => c_special_interest_rec.special_interest_type_id,
                                            x_mode                  => lv_mode -- enable security for Admin
                                            );
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Inside insert_special_interest' ||
                'Exception from IGS_AD_SPL_INTERESTS_PKG.insert_row ' ||
                SQLERRM || 'person_id : ' ||
                IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_special_interest -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END insert_special_interest;
  --added by nshee during build for Applicant-BOSS SS Bug 2622488
  --dhan
  PROCEDURE insert_othinst(p_person_id             IN NUMBER,
                           p_adm_appl_id           IN NUMBER,
                           p_admission_appl_number IN NUMBER) AS
    l_rowid         VARCHAR2(25);
    l_other_inst_id IGS_AD_OTHER_INST.OTHER_INST_ID%TYPE;
     lv_mode VARCHAR2(1) DEFAULT 'R';

    CURSOR c_othinst IS
      SELECT othinst.ss_othins_id,
             othinst.ss_adm_appl_id,
             othinst.institution_code,
             i.name,
             othinst.new_institution
        FROM igs_ss_ad_othins_stg othinst,
             igs_ss_adm_appl_stg  appl,
             igs_or_institution   i,
             igs_pe_hz_parties    php
       WHERE othinst.ss_adm_appl_id = appl.ss_adm_appl_id
         AND othinst.institution_code = i.institution_cd
         AND othinst.institution_code = php.oss_org_unit_cd
         AND appl.person_id = p_person_id
         AND othinst.ss_adm_appl_id = p_adm_appl_id; -- p_admission_appl_number;

  BEGIN

   IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;

    FOR c_othinst_rec IN c_othinst LOOP
      l_rowid         := '';
      l_other_inst_id := 0;
      IGS_AD_OTHER_INST_PKG.insert_row(x_rowid                 => l_rowid,
                                       x_other_inst_id         => l_other_inst_id,
                                       x_person_id             => p_person_id,
                                       x_admission_appl_number => p_admission_appl_number,
                                       x_institution_code      => c_othinst_rec.institution_code,
                                       x_mode                  => lv_mode, -- enable security for Admin
                                       x_new_institution       => c_othinst_rec.new_institution);

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Inside insert_othinst' ||
                'Exception from IGS_AD_OTHER_INST_PKG.insert_row ' ||
                SQLERRM || 'person_id : ' ||
                IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_othinst -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END insert_othinst;
  --dhan
  PROCEDURE insert_edugoal_details(p_person_id           IN igs_ad_edugoal.person_id%TYPE,
                                   p_adm_appl_number     IN igs_ad_edugoal.admission_appl_number%TYPE,
                                   p_ss_adm_appl_id      IN igs_ss_app_pgm_stg.ss_adm_appl_id%TYPE,
                                   p_nominated_course_cd IN igs_ad_edugoal.nominated_course_cd%TYPE,
                                   p_sequence_number     IN igs_ad_edugoal.sequence_number%TYPE) AS
    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Inserts Post Educational Goal Details (For an Application Program Instance)
             FLOW: IGS_AD_EDUGOAL_PKG.insert_row
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    nshee     29-oct-2002 modified due to design change in build 2622488
    *****************************************************************************************/
    l_rowid           VARCHAR2(25);
    l_post_edugoal_id IGS_AD_EDUGOAL.post_edugoal_id%TYPE;
    lv_mode VARCHAR2(1) DEFAULT 'R';
    CURSOR c_postenroll_edu_goal IS
      SELECT edu_goal_id
        FROM igs_ss_ad_edugoa_stg
       WHERE ss_admappl_pgm_id =
             (SELECT ss_admappl_pgm_id
                FROM igs_ss_app_pgm_stg
               WHERE ss_adm_appl_id = p_ss_adm_appl_id -- p_adm_appl_number
                 AND nominated_course_cd = p_nominated_course_cd
                 AND person_id = p_person_id);
  BEGIN
    logHeader('insert_edugoal_details', 'S');

    IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;
    FOR c_postenroll_edu_goal_rec IN c_postenroll_edu_goal LOOP
      IF c_postenroll_edu_goal_rec.edu_goal_id IS NOT NULL THEN
        logDetail('Before call to IGS_AD_EDUGOAL_PKG.insert_row', 'S');

        l_rowid           := '';
        l_post_edugoal_id := 0;

        IGS_AD_EDUGOAL_PKG.insert_row(X_ROWID                 => l_rowid,
                                      X_POST_EDUGOAL_ID       => l_post_edugoal_id,
                                      X_PERSON_ID             => p_person_id,
                                      X_ADMISSION_APPL_NUMBER => p_adm_appl_number,
                                      X_NOMINATED_COURSE_CD   => p_nominated_course_cd,
                                      X_SEQUENCE_NUMBER       => p_sequence_number,
                                      X_EDU_GOAL_ID           => c_postenroll_edu_goal_rec.edu_goal_id,
                                      x_mode                  => lv_mode-- enable security for Admin
                                      );

      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('insert_edugoal_details' ||
                'Exception from IGS_AD_EDUGOAL_PKG.insert_row' || SQLERRM ||
                'person_id : ' || IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_edugoal_details -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END insert_edugoal_details;

  PROCEDURE insert_ss_appl_stg(x_message_name       OUT NOCOPY VARCHAR2,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               p_person_id          IN NUMBER,
                               p_application_type   IN VARCHAR2,
                               p_adm_appl_number    IN NUMBER,
                               p_admission_cat      IN VARCHAR2,
                               p_s_adm_process_type IN VARCHAR2,
                               p_login_id           IN NUMBER,
                               p_app_source_id      IN NUMBER) AS
    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Inserts record from Self Service Admissions form (New Application Screen)

    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    rboddu     17-FEB-2002   Added the parameter p_app_source_id. The same is inserted into the table.
                             Bug : 2224624
    *****************************************************************************************/

  BEGIN
    BEGIN
      INSERT INTO igs_ss_adm_appl_stg
        (ss_adm_appl_id,
         person_id,
         appl_date,
         admission_application_type,
         admission_cat,
         s_adm_process_type,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         app_source_id)
      VALUES
        (p_adm_appl_number,
         p_person_id,
         SYSDATE,
         p_application_type,
         p_admission_cat,
         p_s_adm_process_type,
         SYSDATE,
         p_login_id,
         SYSDATE,
         p_login_id,
         p_login_id,
         p_app_source_id);
      IF SQL%ROWCOUNT = 0 THEN
        x_return_status := 'E';
        x_message_name  := 'IGS_GE_UNHANDLED_EXP';
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
     logDetail('insert  igs_ss_adm_appl_stg' || SQLERRM ||
                'person_id : ' || IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      x_return_status := 'E';
      x_message_name  := 'IGS_GE_UNHANDLED_EXP';
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_ss_appl_stg -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END insert_ss_appl_stg;

  PROCEDURE insert_ss_appl_perstat_stg(p_return_status              OUT NOCOPY VARCHAR2,
                                       p_message_data               OUT NOCOPY VARCHAR2,
                                       p_person_id                  IN NUMBER,
                                       p_adm_appl_id                IN NUMBER,
                                       p_admission_application_type IN VARCHAR2,
                                       p_user_id                    IN NUMBER,
                                       p_date_received              IN DATE)
  /*****************************************************************************************
    Created By:
    Date Created :
    Purpose: 1. Inserts record from Self Service Admissions form (New Application Screen)

    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    rboddu    17-FEB-2002   Added the parameter p_date_received. The same is inserted into the table.
                             Bug : 2224624
    rboddu    05-mar-2003   Inserting the Date_Received as TRUNC(p_date_received). Bug: 2731445
    *****************************************************************************************/
   AS
    CURSOR c_perstat_types(l_admission_application_type IN VARCHAR2) IS
      SELECT persl_stat_type
        From igs_ad_aptyp_pestat
       WHERE admission_application_type = l_admission_application_type;
    l_stmt_count NUMBER;
  BEGIN
    SELECT COUNT(ss_perstat_id)
      INTO l_stmt_count
      FROM igs_ss_appl_perstat
     WHERE person_id = p_person_id
       AND ss_adm_appl_id = p_adm_appl_id;

    IF l_stmt_count = 0 THEN
      FOR c_perstat_types_data IN c_perstat_types(p_admission_application_type) LOOP
        BEGIN
          INSERT INTO igs_ss_appl_perstat
            (ss_perstat_id,
             person_id,
             ss_adm_appl_id,
             admission_application_type,
             persl_stat_type,
             date_received,
             created_by,
             creation_date,
             attach_exists,
             last_updated_by,
             last_update_date,
             last_update_login)
          VALUES
            (igs_ss_perstat_id_s.NEXTVAL,
             p_person_id,
             p_adm_appl_id,
             p_admission_application_type,
             c_perstat_types_data.persl_stat_type,
             TRUNC(p_date_received),
             p_user_id,
             SYSDATE,
             'N',
             p_user_id,
             SYSDATE,
             p_user_id);
          IF c_perstat_types%NOTFOUND THEN
            p_return_status := 'S';
            EXIT;
          END IF;
        END;
      END LOOP;
      p_return_status := 'S';
    ELSE
      p_return_status := 'S';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
     logDetail('insert  igs_ss_appl_perstat' || SQLERRM ||
                'person_id : ' || IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      p_return_status := 'E';
      p_message_data  := 'IGS_GE_UNHANDLED_EXP';
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_ss_appl_perstat_stg -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;
  END insert_ss_appl_perstat_stg;

  PROCEDURE delete_ss_appl_stg(x_message_name    OUT NOCOPY VARCHAR2,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               p_adm_appl_number IN NUMBER,
                               p_person_id       IN NUMBER) AS
    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Deletes record from staging tables if the Application  Creation is successful
             2. Also CAlled from SS Application Form to Delete an already Created Application

    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    tray       16-APR-02     added DML delete for deleting data from igs_ss_ad_sec_stat
                             after the application is transferred.
    *****************************************************************************************/

    l_message_name                VARCHAR2(2000);
    l_return_status               VARCHAR2(2);
    l_msg_index                   NUMBER;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    p_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

  BEGIN
      l_msg_index := IGS_GE_MSG_STACK.count_msg;

    BEGIN
      DELETE FROM igs_ss_ad_sec_stat
       WHERE person_id = p_person_id
         AND ss_adm_appl_id = p_adm_appl_number;

      DELETE FROM igs_ss_app_req_stg
       WHERE ss_adm_appl_id = p_adm_appl_number
         AND person_id = p_person_id;

      -- dvivekan
      -- deleting the per stmt rows not having attachments

      DELETE FROM igs_ss_appl_perstat
       WHERE ss_adm_appl_id = p_adm_appl_number
         AND person_id = p_person_id;

      --added by nshee during build for Applicant-BOSS SS Bug 2622488
      DELETE FROM igs_ss_ad_unitse_stg
       WHERE ss_admappl_pgm_id IN
             (SELECT ss_admappl_pgm_id
                FROM igs_ss_app_pgm_stg
               WHERE ss_adm_appl_id = p_adm_appl_number
                 AND person_id = p_person_id);

      DELETE FROM igs_ss_ad_edugoa_stg
       WHERE ss_admappl_pgm_id IN
             (SELECT ss_admappl_pgm_id
                FROM igs_ss_app_pgm_stg
               WHERE ss_adm_appl_id = p_adm_appl_number
                 AND person_id = p_person_id);

      DELETE FROM igs_ss_ad_acadin_stg
       WHERE ss_adm_appl_id = p_adm_appl_number;

      DELETE FROM igs_ss_ad_appint_stg
       WHERE ss_adm_appl_id = p_adm_appl_number;

      DELETE FROM igs_ss_ad_splint_stg
       WHERE ss_adm_appl_id = p_adm_appl_number;

      DELETE FROM igs_ss_ad_spltal_stg
       WHERE ss_adm_appl_id = p_adm_appl_number;
      --added by nshee during build for Applicant-BOSS SS Bug 2622488
      -- needs to include in the
      -- delete stg table records section
      DELETE FROM igs_ss_ad_othins_stg
       WHERE ss_adm_appl_id = p_adm_appl_number;
      --dhan
      DELETE FROM igs_ss_app_pgm_stg
       WHERE person_id = p_person_id
         AND ss_adm_appl_id = p_adm_appl_number;

      DELETE FROM igs_ss_adm_appl_stg
       WHERE ss_adm_appl_id = p_adm_appl_number
         AND person_id = p_person_id;

    END;
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Exception from delete_ss_appl_stg, ' || SQLERRM, 'S');
      x_return_status := 'E';
      x_message_name :=  'IGS_GE_UNHANDLED_EXP';
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.delete_ss_appl_stg -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;

  END delete_ss_appl_stg;

  --Procedure for transferring Personal Statements/Attachments
  PROCEDURE transfer_attachment(p_person_id             IN IGS_SS_APPL_PERSTAT.person_id%TYPE,
                                p_ss_adm_appl_id        IN IGS_SS_APPL_PERSTAT.ss_adm_appl_id%TYPE,
                                p_admission_appl_number IN IGS_AD_APPL_PERSTAT.admission_appl_number%TYPE,
                                x_return_status         OUT NOCOPY VARCHAR2) IS
    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 11-DEC-2001
    Purpose: 1. Deletes record from staging tables if the Application  Creation is successful
             2. Also CAlled from SS Application Form to Delete an already Created Application

    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    rboddu     17-FEB-2002   in IGS_AD_APPL_PERSTAT_PKG.Insert_Row, date_received is passed
                             NVL(c_ss_appl_perstat_rec.date_received,SYSDATE). Earlier it was just SYSDATE
                             Bug : 2224624
    rboddu     05-MAR-2003   Passing Received_Date as TRUNC(SYSDATE) if it's null in the SS Table. Bug: 2731445
    *****************************************************************************************/
    l_rowid           VARCHAR2(25);
    l_appl_perstat_id IGS_AD_APPL_PERSTAT.appl_perstat_id%TYPE;
    l_from_pk1_value  VARCHAR2(100);
    l_to_pk1_value    VARCHAR2(100);
    lv_mode VARCHAR2(1) DEFAULT 'R';

    CURSOR c_ss_appl_perstat IS
      SELECT ps.*
        FROM igs_ss_appl_perstat ps
       WHERE ps.ss_adm_appl_id = p_ss_adm_appl_id
         AND ps.person_id = p_person_id;

    CURSOR c_ad_appl_perstat IS
      SELECT APPL_PERSTAT_ID
        FROM igs_ad_appl_perstat
       WHERE person_id = p_person_id
         AND admission_appl_number = p_admission_appl_number;

    c_ss_appl_perstat_rec c_ss_appl_perstat%ROWTYPE;

  BEGIN

    IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;
    --
    OPEN c_ss_appl_perstat;
    LOOP
      FETCH c_ss_appl_perstat
        INTO c_ss_appl_perstat_rec; /*There is no way of ensuring that the student visited the personal statements page, if the personal statements page is not visited then no data will be there in the staging table ,
         and error will be caused , as per back office functionality application can be created without personal statement. So procedure should return status 'S' when there are no personal statement staging records */
      EXIT WHEN c_ss_appl_perstat%NOTFOUND;
      IF c_ss_appl_perstat_rec.ATTACH_EXISTS = 'Y' THEN
        BEGIN
          IGS_AD_APPL_PERSTAT_PKG.Insert_Row(x_rowid                 => l_rowid,
                                             x_appl_perstat_id       => l_appl_perstat_id,
                                             x_person_id             => c_ss_appl_perstat_rec.person_id,
                                             x_admission_appl_number => p_admission_appl_number,
                                             x_persl_stat_type       => c_ss_appl_perstat_rec.persl_stat_type,
                                             x_date_received         => NVL(c_ss_appl_perstat_rec.date_received,
                                                                            TRUNC(SYSDATE)), --If the date_received passed from Self Service is null then insert SYSDATE into OSS Table
                                             x_mode                  => lv_mode -- enable security for Admin
                                             );
          /* If insert is successful copy and delete the attachments to the IGS_AD_APPL_PERSTAT table */
          BEGIN

            -- bug 2407148 fix (transferring multiple personal statements)

            /*
            OPEN c_ad_appl_perstat;
                  LOOP
                  FETCH c_ad_appl_perstat INTO l_to_pk1_value;
                  EXIT WHEN c_ad_appl_perstat%NOTFOUND;
            */

            l_from_pk1_value := IGS_GE_NUMBER.TO_CANN(c_ss_appl_perstat_rec.SS_PERSTAT_ID);
            fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name         => 'IGS_SS_APPL_PERSTAT',
                                                         X_from_pk1_value           => l_from_pk1_value,
                                                         X_from_pk2_value           => NULL,
                                                         X_from_pk3_value           => NULL,
                                                         X_from_pk4_value           => NULL,
                                                         X_from_pk5_value           => NULL,
                                                         X_to_entity_name           => 'IGS_AD_APPL_PERSTAT',
                                                         X_to_pk1_value             => l_appl_perstat_id, -- l_to_pk1_value is not used bug 2407148 fix
                                                         X_to_pk2_value             => NULL,
                                                         X_to_pk3_value             => NULL,
                                                         X_to_pk4_value             => NULL,
                                                         X_to_pk5_value             => NULL,
                                                         X_created_by               => NULL,
                                                         X_last_update_login        => NULL,
                                                         X_program_application_id   => NULL,
                                                         X_program_id               => NULL,
                                                         X_request_id               => NULL,
                                                         X_automatically_added_flag => 'N');

            fnd_attached_documents2_pkg.delete_attachments(X_entity_name              => 'IGS_SS_APPL_PERSTAT',
                                                           X_pk1_value                => l_from_pk1_value,
                                                           X_pk2_value                => NULL,
                                                           X_pk3_value                => NULL,
                                                           X_pk4_value                => NULL,
                                                           X_pk5_value                => NULL,
                                                           X_delete_document_flag     => 'N',
                                                           X_automatically_added_flag => 'N');
            -- END LOOP;
            x_return_status := 'S';
          EXCEPTION
            WHEN OTHERS THEN
              /* If copy and delete is NOT successful */
              x_return_status := 'E';
          END;
          x_return_status := 'S';
        EXCEPTION
          WHEN OTHERS THEN
            /* If insert is NOT successful */
            x_return_status := 'E';
        END;
        DELETE FROM igs_ss_appl_perstat
         WHERE ss_perstat_id = c_ss_appl_perstat_rec.SS_PERSTAT_ID;
      END IF;

      IF x_return_status <> 'E' OR x_return_status IS NULL THEN
        x_return_status := 'S';
        /*Indicate Success, to be used in Calling Proc, if Status = 'S', then commit
        data */
      END IF;
    END LOOP;
    x_return_status := 'S';
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
      logDetail('Exception from transfer_attachment ' || SQLERRM, 'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.transfer_attachment -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;

      App_Exception.Raise_Exception;
  END transfer_attachment;

  --Procedure sent from HQ to be added
  -----------------------------------
  PROCEDURE get_acad_cal(p_adm_cal_type  IN igs_ca_type.cal_type%TYPE,
                         p_adm_seq       IN OUT NOCOPY igs_ca_inst.sequence_number%TYPE,
                         p_acad_cal_type OUT NOCOPY igs_ca_type.cal_type%TYPE,
                         p_acad_seq      OUT NOCOPY igs_ca_inst.sequence_number%TYPE) AS
    l_message  fnd_new_messages.message_name%TYPE;
    l_start_dt DATE;
    l_end_dt   DATE;
    l_out      VARCHAR2(2000);

    -- Cursor for getting the Calendar Sequence for the
    -- Calendar Type. The Calendar Instance Selected for this calendar
    -- should be the nearest one to the System Date
    CURSOR cur_sequence(cp_cal_type igs_ca_type.cal_type%TYPE) IS
      SELECT ci_adm.sequence_number  adm_sequence_number,
             ci_acad.cal_type        acad_cal_type,
             ci_acad.sequence_number acad_sequence_number
        FROM igs_ca_type     ct_adm,
             igs_ca_inst     ci_adm,
             igs_ca_stat     cs,
             igs_ca_inst_rel cir,
             igs_ca_inst     ci_acad,
             igs_ca_type     ct_acad
       WHERE ct_adm.cal_type = cp_cal_type
         AND ct_adm.cal_type = ci_adm.cal_type
         AND SYSDATE <= ci_adm.end_dt
         AND ct_adm.s_cal_cat = 'ADMISSION'
         AND ci_adm.cal_status = cs.cal_status
         AND cs.s_cal_status = 'ACTIVE'
         AND ci_adm.cal_type = cir.sub_cal_type
         AND ci_adm.sequence_number = cir.sub_ci_sequence_number
         AND ct_acad.cal_type = ci_acad.cal_type
         AND ci_acad.cal_type = cir.sup_cal_type
         AND ci_acad.sequence_number = cir.sup_ci_sequence_number
         AND ct_acad.s_cal_cat = 'ACADEMIC'
       ORDER BY ci_adm.end_dt;

    sequence_rec cur_sequence%ROWTYPE;
  BEGIN

    -- If the Admission Calendar Instance is not defined
    -- then derive the Admisssion Calendar Instance
    IF p_adm_seq IS NULL THEN
      OPEN cur_sequence(p_adm_cal_type);
      FETCH cur_sequence
        INTO sequence_rec;

      IF cur_sequence%NOTFOUND THEN
        fnd_message.set_name('IGS', 'IGS_AD_INQ_ADMCAL_SEQ_NOTDFN');
        fnd_message.set_token('CAL_TYPE', p_adm_cal_type);
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
      END IF;

      p_adm_seq       := sequence_rec.adm_sequence_number;
      p_acad_cal_type := sequence_rec.acad_cal_type;
      p_acad_seq      := sequence_rec.acad_sequence_number;
      CLOSE cur_sequence;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END get_acad_cal;

  ----------------------------------
  --Function Sent from HQ to be added
  ----------------------------------
  FUNCTION get_dflt_adm_cal RETURN VARCHAR2 IS
    CURSOR cur_adm_cal_conf IS
      SELECT inq_cal_type FROM igs_ad_cal_conf;

    l_inq_cal_type igs_ad_cal_conf.inq_cal_type%TYPE;

  BEGIN

    OPEN cur_adm_cal_conf;
    FETCH cur_adm_cal_conf
      INTO l_inq_cal_type;
    CLOSE cur_adm_cal_conf;
    RETURN(l_inq_cal_type);

  END get_dflt_adm_cal;
  ----------------------------------

  --This is a Debug Mode Proc, outputs which proc is being processed, to stop Debugging pass 'H' to p_mode param
  PROCEDURE logHeader(p_proc_name VARCHAR2, p_mode VARCHAR2) AS
  BEGIN
    IF p_mode = 'S' THEN
      --  FND_FILE.PUT_LINE(FND_FILE.LOG,p_proc_name);
      --  dbms_output.put_line('*****************Inside Proc: '||p_proc_name||'  **********************');
      null; --commented last  line for GSCC , uncomment when using logheader
    ELSIF p_mode = 'H' THEN
      NULL;
    END IF;
  END;

  --This is a Debug Mode Proc, outputs each call being processed, to stop Debugging pass 'H' to p_mode param
  PROCEDURE logDetail(p_debug_msg VARCHAR2, p_mode VARCHAR2) AS
  BEGIN
    IF p_mode = 'S' THEN
      -- FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_msg);
      --  dbms_output.put_line(p_debug_msg);
      null; --commented last  line for GSCC , uncomment when using logheader
    ELSIF p_mode = 'H' THEN
      NULL;
    END IF;
  END;

  -- Check to see if there exists any fee for this Application
  Procedure Check_FeeExists(p_person_id          IN igs_ad_appl_all.person_id%TYPE,
			    p_adm_appl_num       IN igs_ad_appl_all.admission_appl_number%TYPE,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_message_data       OUT NOCOPY VARCHAR2) AS

    l_fee_amount        NUMBER;
    l_msg_count         NUMBER;
    l_revenue_acct_code	igs_ad_app_req.REV_ACCOUNT_CD%TYPE;
    l_cash_acct_code	igs_ad_app_req.CASH_ACCOUNT_CD%TYPE;
    l_revenue_acct_ccid	igs_ad_app_req.REV_GL_CCID%TYPE;
    l_cash_acct_ccid	igs_ad_app_req.CASH_GL_CCID%TYPE;


  BEGIN

    -- check if application fee exists


    x_message_data := NULL;
    x_return_status := 'N';


    IGS_AD_SS_APPL_FEE_PKG.get_appl_type_fee_details(
         p_person_id             =>p_person_id,
         p_admission_appl_number =>p_adm_appl_num,
         appl_fee_amt            =>l_fee_amount,
         revenue_acct_code       =>l_revenue_acct_code,
         cash_acct_code          =>l_cash_acct_code,
         revenue_acct_ccid       =>l_revenue_acct_ccid,
         cash_acct_ccid          =>l_cash_acct_ccid,
         x_return_status         =>x_return_status,
         x_msg_count             =>l_msg_count,
         x_msg_data              =>x_message_data);

    IF l_fee_amount =0 THEN
	x_return_status := 'N';
    END IF;

    IF (l_fee_amount IS NOT NULL) AND (l_fee_amount > 0) THEN
      x_return_status := 'S';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
      x_message_data := 'IGS_GE_UNHANDLED_EXP';
      logDetail('Exception from Check_FeeExists ' || SQLERRM, 'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.Check_FeeExists -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;

  END Check_FeeExists;

  -- Check to see if the application is a one-stop type application
  Procedure Check_OneStop(p_person_id              IN NUMBER,
                          p_admission_cat          IN VARCHAR2,
                          p_admission_process_type IN VARCHAR2,
                          x_return_status          OUT NOCOPY VARCHAR2,
                          x_message_data           OUT NOCOPY VARCHAR2) AS

    l_accept                      VARCHAR2(1);
    l_offer                       VARCHAR2(1);
    l_one_stop                    VARCHAR2(1);
    l_msg_index                   NUMBER;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    p_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

    l_prog_label  VARCHAR2(100);
    l_label  VARCHAR2(500);
    l_debug_str VARCHAR2(4000);

  BEGIN

    l_prog_label := 'igs.plsql.igs_ad_ss_gen_001.Check_OneStop';
    l_label      := 'igs.plsql.igs_ad_ss_gen_001.Check_OneStop.start';

    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_debug_str := 'Starting values : Person ID  =' || p_person_id || 'Admission cat  ='||p_admission_cat ||
                   'sytem Admission process type  ='|| p_admission_process_type;
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
    END IF;


    Select 'X'
      Into l_accept
      From igs_ad_prcs_cat_step
     Where S_ADMISSION_STEP_TYPE = 'AUTO-ACCEPT'
       And ADMISSION_CAT = p_admission_cat
       And S_ADMISSION_PROCESS_TYPE = p_admission_process_type
       And STEP_GROUP_TYPE <> 'TRACK'; --2402377


        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ad_ss_gen_001.Check_OneStop.After_Auto_accept_Step_incl';
          l_debug_str := 'Auto Accept step is included for APC';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;

    Select 'X'
      Into l_offer
      From igs_ad_prcs_cat_step
     Where S_ADMISSION_STEP_TYPE = 'AUTO-OFFER'
       And ADMISSION_CAT = p_admission_cat
       And S_ADMISSION_PROCESS_TYPE = p_admission_process_type
       And STEP_GROUP_TYPE <> 'TRACK'; -- 2402377

        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ad_ss_gen_001.Check_OneStop.After_Auto_offer_Step_incl';
          l_debug_str := 'Auto Accept step is included for APC';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;

    -- If no record exists for that combination RETURN 'N',
    -- else return 'S'

    If (l_accept IS NOT NULL And l_offer IS NOT NULL) Then
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ad_ss_gen_001.Check_OneStop.One_Stop';
          l_debug_str := 'Its One Stop Application !';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;
      l_one_stop := 'Y';
    End If;

    If l_one_stop = 'Y' Then
      x_return_status := 'S';
    End If;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ad_ss_gen_001.Check_OneStop.No_data_found';
          l_debug_str := 'It Not An One Stop Application ';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;

      FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_ONESTOP_NO_DATA_FOUND');
      IGS_GE_MSG_STACK.ADD;
      x_return_status := 'N'; -- This is used to specify that application is not onestop
      x_message_data  := 'IGS_AD_ONESTOP_NO_DATA_FOUND';

    WHEN OTHERS THEN
        IF fnd_log.test(fnd_log.level_Exception,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ad_ss_gen_001.Check_OneStop.Exception_when_others';
          l_debug_str := 'In Exception- When Others block of Check_OneStop';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;

      x_return_status := 'E';
      x_message_data := 'IGS_GE_UNHANDLED_EXP';
      logDetail('Exception from Check_OneStop ' || SQLERRM, 'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.Check_OneStop -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;

  END Check_OneStop;

  -- This procedure will only be called if it is a one-stop application

  PROCEDURE Process_OneStop(p_admission_appl_number  IN NUMBER,
                            p_person_id              IN NUMBER,
                            p_admission_cat          IN VARCHAR2,
                            p_admission_process_type IN VARCHAR2,
                            p_role                   IN VARCHAR2,
                            x_return_status          OUT NOCOPY VARCHAR2,
                            x_message_data           OUT NOCOPY VARCHAR2) AS

    Cursor c_course IS
      Select NOMINATED_COURSE_CD, SEQUENCE_NUMBER
        From IGS_AD_PS_APPL_INST_ALL
       Where PERSON_ID = p_person_id
         And ADMISSION_APPL_NUMBER = p_admission_appl_number;

    l_one_stop                    VARCHAR2(1);
    c_course_rec                  c_course%ROWTYPE;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(1000);
    l_message_data                VARCHAR2(1000);
    l_msg_index                   NUMBER;
    p_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

    l_prog_label  VARCHAR2(100);
    l_label  VARCHAR2(500);
    l_debug_str VARCHAR2(4000);


  BEGIN

    l_prog_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop';
    l_label      := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.start';

    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
      l_debug_str := 'Starting values : Adm appl No ='|| p_admission_appl_number ||'Person ID  =' || p_person_id || 'Admission cat  ='||p_admission_cat ||
                   'sytem Admission process type  ='|| p_admission_process_type;
      fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
    END IF;


    -- Check whether the Admission Entry qualification status be updated
    -- to system admission entry qualification 'QUALIFIED' and whether
    -- the Admission Application status can be updated to 'SATISFIED'
    -- If Yes, then update them to the respective values
    x_return_status := 'E';
    Open c_course;

    LOOP

      FETCH c_course
        INTO c_course_rec;

      EXIT WHEN c_course%NOTFOUND;

      BEGIN

        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.Before_check_update_aeps_acs';
          l_debug_str := 'Beofore IGS_AD_SS_APPL_FEE_PKG.check_update_aeps_acs';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;

        IGS_AD_SS_APPL_FEE_PKG.check_update_aeps_acs(p_person_id,
                                                     p_admission_appl_number,
                                                     c_course_rec.nominated_course_cd,
                                                     c_course_rec.sequence_number,
                                                     l_return_status,
                                                     l_msg_count,
                                                     l_msg_data);

        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.After_check_update_aeps_acs_ret_Status';
          l_debug_str := 'After check_update_aeps_acs l_return_status: ' || l_return_status;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);

          l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.After_check_update_aeps_acs_msg_Data';
          l_debug_str := 'After check_update_aeps_acs l_msg_data: ' || l_msg_data;
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;

        IF l_return_status = 'E' THEN          ----check_update_aeps_acs return status
           IF p_role <>  'ADMIN' THEN
              l_msg_data :=  'IGS_AD_APPL_PRC_FAILED';
           END IF;
           FND_MESSAGE.SET_NAME('IGS', l_msg_data);
           IGS_GE_MSG_STACK.ADD;
	   x_return_status := 'E';
           x_message_data  := l_msg_data;
           RETURN;

        ELSIF l_return_status = 'S' THEN

          Update_Appl_Eqdo_Inst(p_person_id,
                                p_admission_appl_number,
                                c_course_rec.nominated_course_cd,
                                c_course_rec.sequence_number,
                                l_return_status,
                                l_message_data);


           IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
              l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.after_Update_Appl_Eqdo_Inst_ret_Stat';
              l_debug_str := 'After Update_Appl_Eqdo_Inst l_return_status: ' || l_return_status;
              fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);

              l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.After_Update_Appl_Eqdo_Inst_msg_Data';
              l_debug_str := 'After Update_Appl_Eqdo_Inst l_message_data: ' || l_message_data;
              fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);

           END IF;

           IF l_return_status = 'E' THEN              --- Update_Appl_Eqdo_Inst return status
              IF p_role <>  'ADMIN' THEN
	         IGS_GE_MSG_STACK.INITIALIZE; -- Remove all other messages from stack
                 l_msg_data :=  'IGS_AD_APPL_PRC_FAILED';
                 FND_MESSAGE.SET_NAME('IGS', l_msg_data);
                 IGS_GE_MSG_STACK.ADD;
              END IF;
              x_return_status := 'E';
              x_message_data  := l_msg_data;
              RETURN;

           ELSIF l_return_status = 'S' THEN
            -- check if an offer can be made for the application
            -- If Yes, then update the offer status to 'OFFER'

             IGS_AD_SS_APPL_FEE_PKG.check_offer_update(p_person_id,
                                                    p_admission_appl_number,
                                                    c_course_rec.nominated_course_cd,
                                                    c_course_rec.sequence_number,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

             IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
               l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.After_check_offer_update_return_Stat';
               l_debug_str := 'After check_offer_update l_return_status: ' || l_return_status;
               fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);

               l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.After_check_offer_update_Data_msg_Data';
               l_debug_str := 'After check_offer_update l_msg_data: ' || l_msg_data;
               fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
              END IF;

            IF l_return_status = 'E' THEN     -- check_offer_update return status
              IF p_role <>  'ADMIN' THEN
	        IGS_GE_MSG_STACK.INITIALIZE; -- Remove all other messages from stack
                l_msg_data :=  'IGS_AD_APPL_PRC_FAILED';
              END IF;
              FND_MESSAGE.SET_NAME('IGS', l_msg_data);
              IGS_GE_MSG_STACK.ADD;
	      x_return_status := 'E';
              x_message_data  := l_msg_data;
              RETURN;

            ELSIF l_return_status = 'S' THEN
               Update_Appl_Ofr_Inst(p_person_id,
                                 p_admission_appl_number,
                                 c_course_rec.nominated_course_cd,
                                 c_course_rec.sequence_number,
                                 l_return_status,
                                 l_message_data);

                 IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                    l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.After_Update_Appl_Ofr_Inst_ret_Stat';
                    l_debug_str := 'After Update_Appl_Ofr_Inst l_return_status: ' || l_return_status;
                    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);

                    l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.After_Update_Appl_Ofr_Inst_msg_Data';
                    l_debug_str := 'After Update_Appl_Ofr_Inst l_message_data: ' || l_message_data;
                    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                 END IF;

	         IF l_return_status = 'E' THEN     -- Update_Appl_Ofr_Inst return status
                   IF p_role <>  'ADMIN' THEN
                      IGS_GE_MSG_STACK.INITIALIZE; -- Remove all other messages from stack
                      l_message_data :=  'IGS_AD_APPL_PRC_FAILED';
                      FND_MESSAGE.SET_NAME('IGS', l_message_data);
                      IGS_GE_MSG_STACK.ADD;
                   END IF;
                   x_return_status := 'E';
                   x_message_data  := l_message_data;
                   RETURN;
                 END IF;       -- Update_Appl_Ofr_Inst return status

          END IF;  -- check_offer_update return status
         END IF;  --- Update_Appl_Eqdo_Inst return status
       END IF;  ----check_update_aeps_acs return status

      EXCEPTION
        WHEN OTHERS THEN
          IF FND_MSG_PUB.Count_Msg < 1 AND l_message_data IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('IGS', l_message_data);
            IGS_GE_MSG_STACK.ADD;
          END IF;
          x_return_status := 'E';
          x_message_data  := l_message_data;
      END;
    END LOOP;

    IF c_course%ISOPEN THEN
      CLOSE c_course;
    END IF;

    x_return_status := 'S';
    x_message_data := NULL;

  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Exception from Process_OneStop, ' || SQLERRM, 'S');
      x_return_status := 'E';
      IF p_role <>  'ADMIN' THEN
	 IGS_GE_MSG_STACK.INITIALIZE; -- Remove all other messages from stack
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APPL_PRC_FAILED');
         IGS_GE_MSG_STACK.ADD;
         x_message_data := 'IGS_AD_APPL_PRC_FAILED';
      ELSE
          IF FND_MSG_PUB.Count_Msg < 1 THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.Process_OneStop -'||SQLERRM);
            IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
          END IF;
         x_message_data := 'IGS_GE_UNHANDLED_EXP';
      END IF;
  END Process_OneStop;

  -- This procedure will update the Application fee details,
  -- Will check if it is a one-stop application, if yes,then
  -- check if the offer response can be made 'ACCEPTED' for the offer
  -- if Yes, then update the offer resp status to 'ACCEPTED'
  -- This procedure will be called from Student Finance page

  PROCEDURE update_ad_offer_resp_and_fee(p_person_id                   IN NUMBER,
                                         p_admission_appl_number       IN NUMBER,
                                         p_one_stop_ind                IN VARCHAR2,
                                         p_app_fee_amt                 IN NUMBER,
                                         p_authorization_number        IN VARCHAR2,
                                         x_return_status               OUT NOCOPY VARCHAR2,
                                         x_msg_count                   OUT NOCOPY NUMBER,
                                         x_msg_data                    OUT NOCOPY VARCHAR2,
                                         p_credit_card_code            IN VARCHAR2,
                                         p_credit_card_holder_name     IN VARCHAR2,
                                         p_credit_card_number          IN VARCHAR2,
                                         p_credit_card_expiration_date IN DATE,
                                         p_gl_date                     IN DATE,
                                         p_rev_gl_ccid                 IN NUMBER,
                                         p_cash_gl_ccid                IN NUMBER,
                                         p_rev_account_cd              IN VARCHAR2,
                                         p_cash_account_cd             IN VARCHAR2,
                                         p_credit_card_tangible_cd     IN VARCHAR2) AS
    /******************************************************************
    Created By:
    Date Created By:
    Purpose:
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    pathipat   17-Jun-2003   Enh 2831587 Credit Card Fund Transfer build
                             Added new parameter p_credit_card_tangible_cd
    smadathi   26-Nov-2002   Enh#2584986. Passed system date to parameter gl_date in the call to igs_ad_ss_appl_fee_pkg.upd_fee_details
    vvutukur   26-Nov-2002   Enh#2584986.Added 9 new parameters to this procedure(attributing to credit card details,                              Accounting information and the GL_DATE) as part of GL Interface Build.Passed sysdate
                             if gl_date parameter is null in the call to igs_ad_ss_appl_fee_pkg.upd_fee_details.
    schodava   24-Jul-2002   Bug # 2467918
           Application fee cannot be submitted
    knag       28-Oct-2002   Called func igs_ad_gen_003.get_core_or_optional_unit for bug 2647482
    ******************************************************************/

    CURSOR c_course IS
      Select NOMINATED_COURSE_CD, SEQUENCE_NUMBER
        From IGS_AD_PS_APPL_INST_ALL
       Where PERSON_ID = p_person_id
         And ADMISSION_APPL_NUMBER = p_admission_appl_number;

    --tray Bug 2405076
    CURSOR get_appl_dtl(cp_person_id igs_ad_appl.person_id%TYPE, cp_adm_appl_number igs_ad_appl.admission_appl_number%TYPE) IS
      SELECT acad_cal_type,
             acad_ci_sequence_number,
             admission_cat,
             s_admission_process_type
        FROM IGS_AD_APPL
       WHERE person_id = cp_person_id
         AND admission_appl_number = cp_adm_appl_number;
    get_appl_dtl_rec get_appl_dtl%ROWTYPE;

    --tray Bug 2405076
    CURSOR get_enr_cat(cp_adm_cat igs_en_cat_mapping.admission_cat%TYPE) IS
      SELECT enrolment_cat
        FROM igs_en_cat_mapping
       WHERE admission_cat = cp_adm_cat
         AND dflt_cat_ind = 'Y';
    get_enr_cat_rec get_enr_cat%ROWTYPE;

    l_one_stop      VARCHAR2(1);
    c_course_rec    c_course%ROWTYPE;
    l_return_status VARCHAR2(1);
    --l_adm_cat IGS_AD_APPL_ALL.ADMISSION_CAT%TYPE; changed to cursor now Bug 2405076
    --l_adm_proc_type IGS_AD_APPL_ALL. S_ADMISSION_PROCESS_TYPE%TYPE; changed to cursor now Bug 2405076
    l_msg_count    NUMBER;
    l_msg_data     VARCHAR2(1000);
    l_message_data VARCHAR2(1000);
    v_warn_level   VARCHAR2(10);
    v_message_name VARCHAR2(30);

  BEGIN
    l_return_status := 'E';
    x_return_status := 'E';

    igs_ad_ss_appl_fee_pkg.upd_fee_details(p_person_id                   => p_person_id,
                                           p_admission_appl_number       => p_admission_appl_number,
                                           p_app_fee_amt                 => p_app_fee_amt,
                                           p_authorization_number        => p_authorization_number,
                                           p_sys_fee_status              => 'PAID',
                                           p_sys_fee_type                => 'APPL_FEE',
                                           p_sys_fee_method              => 'CREDIT_CARD',
                                           x_return_status               => l_return_status,
                                           x_msg_count                   => l_msg_count,
                                           x_msg_data                    => l_msg_data,
                                           p_credit_card_code            => p_credit_card_code,
                                           p_credit_card_holder_name     => p_credit_card_holder_name,
                                           p_credit_card_number          => p_credit_card_number,
                                           p_credit_card_expiration_date => p_credit_card_expiration_date,
                                           p_gl_date                     => NVL(p_gl_date,
                                                                                TRUNC(SYSDATE)),
                                           p_rev_gl_ccid                 => p_rev_gl_ccid,
                                           p_cash_gl_ccid                => p_cash_gl_ccid,
                                           p_rev_account_cd              => p_rev_account_cd,
                                           p_cash_account_cd             => p_cash_account_cd,
                                           p_credit_card_tangible_cd     => p_credit_card_tangible_cd);
    -- For an application type other than 'One stop',
    -- this procedure returned a status of 'E', even if the above call to
    -- igs_ad_ss_appl_fee_pkg.upd_fee_details returned a success.
    -- This is corrected by equating the return status and message returned by the above
    -- call to the out NOCOPY variables x_return_status and x_msg_data

    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;

    --tray Bug 2405076
    OPEN get_appl_dtl(p_person_id, p_admission_appl_number);
    FETCH get_appl_dtl
      INTO get_appl_dtl_rec;
    CLOSE get_appl_dtl;

    IF (p_one_stop_ind IS NULL) THEN

      --tray: Select without cursor is not allowed, so changing this to cursor Bug 2405076
      /*
                      Select ADMISSION_CAT, S_ADMISSION_PROCESS_TYPE
                      Into l_adm_cat, l_adm_proc_type
                      From IGS_AD_APPL_ALL
                      Where person_id = p_person_id
                      And admission_appl_number = p_admission_appl_number;
      */
      Check_OneStop(p_person_id              => p_person_id,
                    p_admission_cat          => get_appl_dtl_rec.admission_cat,
                    p_admission_process_type => get_appl_dtl_rec.s_admission_process_type,
                    x_return_status          => l_one_stop,
                    x_message_data           => l_msg_data);

    END IF;

    IF (p_one_stop_ind IS NOT NULL AND p_one_stop_ind ='S') OR (l_one_stop = 'S') THEN

      OPEN c_course;
      LOOP
        FETCH c_course
          INTO c_course_rec;
        EXIT WHEN c_course%NOTFOUND;
        BEGIN
          IGS_AD_SS_APPL_FEE_PKG.check_offer_resp_update(p_person_id,
                                                         p_admission_appl_number,
                                                         c_course_rec.nominated_course_cd,
                                                         c_course_rec.sequence_number,
                                                         l_return_status,
                                                         l_msg_count,
                                                         l_msg_data);
          IF l_return_status = 'S' THEN
            --tray       pre enr process called Bug 2405076
            OPEN get_enr_cat(get_appl_dtl_rec.admission_cat);
            FETCH get_enr_cat
              INTO get_enr_cat_rec;
            CLOSE get_enr_cat;

            IF igs_ad_upd_initialise.perform_pre_enrol(p_person_id,
                                                       p_admission_appl_number,
                                                       c_course_rec.nominated_course_cd,
                                                       c_course_rec.sequence_number,
                                                       'Y', -- Confirm course indicator.
                                                       'Y', -- Perform eligibility check indicator.
                                                       v_message_name) =
               FALSE THEN
              x_return_status := 'E';
              x_msg_data      := 'IGS_AD_AUTO_ENR_FAILED'; --Supressing the error message from the Pre Enr process as per communication on bug2405076
            ELSE
              Update_Appl_Ofres_Inst(p_person_id,
                                     p_admission_appl_number,
                                     c_course_rec.nominated_course_cd,
                                     c_course_rec.sequence_number,
                                     l_return_status,
                                     l_message_data);
              x_return_status := 'S';
            END IF;
          END IF;
        EXCEPTION
          when others then
            x_return_status := 'E';
            x_msg_data      := l_message_data;
        END;
      END LOOP;
      CLOSE c_course;
    END IF;

    IF x_return_status <> 'E' THEN
      x_return_status := 'S';
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
      x_msg_data      := 'IGS_GE_UNHANDLED_EXP';
      IF FND_MSG_PUB.Count_Msg < 1 THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.update_ad_offer_resp_and_fee -'||SQLERRM);
	IGS_GE_MSG_STACK.ADD;
      END IF;
  END update_ad_offer_resp_and_fee;

  -- This procedure will only be called if it is a one-stop application

  PROCEDURE Process_OneStop2(p_admission_appl_number  IN NUMBER,
                             p_person_id              IN NUMBER,
                             p_admission_cat          IN VARCHAR2,
                             p_admission_process_type IN VARCHAR2,
			     p_role                   IN VARCHAR2,
                             x_return_status          OUT NOCOPY VARCHAR2,
                             x_msg_data               OUT NOCOPY VARCHAR2) AS
    /******************************************************************
    Created By:
    Date Created By:
    Purpose:
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    knag       28-Oct-2002   Called func igs_ad_gen_003.get_core_or_optional_unit for bug 2647482
    ******************************************************************/

    Cursor c_course IS
      Select NOMINATED_COURSE_CD, SEQUENCE_NUMBER
        From IGS_AD_PS_APPL_INST_ALL
       Where PERSON_ID = p_person_id
         And ADMISSION_APPL_NUMBER = p_admission_appl_number;

    --tray Bug 2405076
    CURSOR get_appl_dtl(cp_person_id igs_ad_appl.person_id%TYPE, cp_adm_appl_number igs_ad_appl.admission_appl_number%TYPE) IS
      SELECT acad_cal_type,
             acad_ci_sequence_number,
             admission_cat,
             s_admission_process_type
        FROM IGS_AD_APPL
       WHERE person_id = cp_person_id
         AND admission_appl_number = cp_adm_appl_number;
    get_appl_dtl_rec get_appl_dtl%ROWTYPE;

    --tray Bug 2405076
    CURSOR get_enr_cat(cp_adm_cat igs_en_cat_mapping.admission_cat%TYPE) IS
      SELECT enrolment_cat
        FROM igs_en_cat_mapping
       WHERE admission_cat = cp_adm_cat
         AND dflt_cat_ind = 'Y';
    get_enr_cat_rec get_enr_cat%ROWTYPE;

    l_one_stop                    VARCHAR2(1);
    c_course_rec                  c_course%ROWTYPE;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(1000);
    l_message_data                VARCHAR2(1000);
    v_warn_level                  VARCHAR2(10);
    v_message_name                VARCHAR2(30);
    l_msg_index                   NUMBER;
    p_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

    l_prog_label  VARCHAR2(100);
    l_label  VARCHAR2(500);
    l_debug_str VARCHAR2(4000);

  BEGIN

    l_prog_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop';
    l_label      := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop.start';


        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
          l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop2.start';
          l_debug_str := 'In Process_OneStop2 Start';
          fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
        END IF;

    -- Check whether the Admission offer resp status be updated
    -- to 'ACCEPTED', If Yes, then update them to the respective values
    x_return_status := 'E';
    x_msg_data := NULL;
    OPEN c_course;
    LOOP
      FETCH c_course
        INTO c_course_rec;
      EXIT WHEN c_course%NOTFOUND;
      BEGIN
        IF (FND_LOG.LEVEL_STATEMENT>= g_debug_level ) THEN
          FND_LOG.STRING(fnd_log.level_Statement, 'igs.patch.115.sql.igs_ad_ss_gen_001.Process_OneStop2 :', 'Before IGS_AD_SS_APPL_FEE_PKG.check_offer_resp_update');
        END IF;
        IGS_AD_SS_APPL_FEE_PKG.check_offer_resp_update(p_person_id,
                                                       p_admission_appl_number,
                                                       c_course_rec.nominated_course_cd,
                                                       c_course_rec.sequence_number,
                                                       l_return_status,
                                                       l_msg_count,
                                                       l_msg_data);


          IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
             l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop2.after_check_offer_resp_update_ret_Stat';
             l_debug_str := 'After IGS_AD_SS_APPL_FEE_PKG.check_offer_resp_update: l_return_status' || l_return_status;
             fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);

             l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop2.after_check_offer_resp_update_msg_data';
             l_debug_str := 'After IGS_AD_SS_APPL_FEE_PKG.check_offer_resp_update: l_msg_data' || l_msg_data;
             fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);

          END IF;

         IF l_return_status = 'E' THEN          ----check_offer_resp_update return status
             IF p_role <>  'ADMIN' THEN
                l_msg_data :=  'IGS_AD_APPL_PRC_FAILED';
             END IF;
             FND_MESSAGE.SET_NAME('IGS', l_msg_data);
             IGS_GE_MSG_STACK.ADD;
	     x_return_status := 'E';
             x_msg_data  := l_msg_data;
             RETURN;

         ELSIF l_return_status = 'S' Then
          --tray       pre enr process called Bug 2405076
            OPEN get_appl_dtl(p_person_id, p_admission_appl_number);
            FETCH get_appl_dtl
              INTO get_appl_dtl_rec;
             CLOSE get_appl_dtl;

            OPEN get_enr_cat(get_appl_dtl_rec.admission_cat);
            FETCH get_enr_cat
              INTO get_enr_cat_rec;
            CLOSE get_enr_cat;


            IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
               l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop2.beofore_perform_pre_enrol';
               l_debug_str := 'Before igs_ad_upd_initialise.perform_pre_enrol';
               fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
            END IF;


           IF igs_ad_upd_initialise.perform_pre_enrol(p_person_id,
                                                     p_admission_appl_number,
                                                     c_course_rec.nominated_course_cd,
                                                     c_course_rec.sequence_number,
                                                     'Y', -- Confirm course indicator.
                                                     'Y', -- Perform eligibility check indicator.
                                                     v_message_name) =
             FALSE THEN

               IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                 l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop2.after_a_perform_pre_enrol_failed';
                 l_debug_str := 'After igs_ad_upd_initialise.perform_pre_enrol Failed v_message_name ' || v_message_name;
                 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                END IF;

	       FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_AUTO_ENR_FAILED');
               IGS_GE_MSG_STACK.ADD;
               x_return_status := 'E';
               x_msg_data      := 'IGS_AD_AUTO_ENR_FAILED'; --Supressing the error message from the Pre Enr process as per communication on bug2405076
	       RETURN;
           ELSE

              IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                 l_label := 'igs.plsql.igs_ad_ss_gen_001.Process_OneStop2.after_a_perform_pre_enrol_success';
                 l_debug_str := 'igs_ad_upd_initialise.perform_pre_enrol Succesful';
                 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
               END IF;


            /*Commenting as part of Bug 4234911
            Update_Appl_Ofres_Inst( p_person_id,
                            p_admission_appl_number,
                            c_course_rec.nominated_course_cd,
                            c_course_rec.sequence_number,
                            l_return_status,
                            l_message_data );*/
            x_return_status := 'S';
          END IF;  -- igs_ad_upd_initialise.perform_pre_enrol

        END IF;  --- check_offer_resp_update return status
      END;
    END LOOP;

    IF c_course%ISOPEN THEN
       CLOSE c_course; --tray bug2405076 , earlier cursor was getting inside the LOOP :-(
    END IF;

    x_return_status := 'S';

  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Exception from Process_OneStop2, ' || SQLERRM, 'S');
      x_return_status := 'E';
      IF p_role <>  'ADMIN' THEN
	 IGS_GE_MSG_STACK.INITIALIZE; -- Remove all other messages from stack
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APPL_PRC_FAILED');
         IGS_GE_MSG_STACK.ADD;
         x_msg_data := 'IGS_AD_APPL_PRC_FAILED';
      ELSE
         IF FND_MSG_PUB.Count_Msg < 1 THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.Process_OneStop2 -'||SQLERRM);
           IGS_GE_MSG_STACK.ADD;
	   App_Exception.Raise_Exception;
         END IF;
         x_msg_data := 'IGS_GE_UNHANDLED_EXP';
      END IF;

  END Process_OneStop2;

  PROCEDURE Update_Appl_Eqdo_Inst(p_person_id             IN NUMBER,
                                  p_admission_appl_number IN NUMBER,
                                  p_nominated_course_cd   IN VARCHAR2,
                                  p_sequence_number       IN NUMBER,
                                  x_return_status         OUT NOCOPY VARCHAR2,
                                  x_message_data          OUT NOCOPY VARCHAR2) IS

    CURSOR c_upd_acai_eqdo(cp_person_id IGS_AD_PS_APPL_INST.person_id%TYPE,
             cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
             cp_nominated_course_cd IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
             cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE) IS
      SELECT ROWID, acai.*
        FROM IGS_AD_PS_APPL_INST acai
       WHERE acai.person_id = cp_person_id
         AND acai.admission_appl_number = cp_admission_appl_number
         AND acai.nominated_course_cd = cp_nominated_course_cd
         AND acai.sequence_number = cp_sequence_number
         FOR UPDATE OF acai.adm_doc_status, acai.adm_entry_qual_status NOWAIT;

    CURSOR c_admission_process_type(cp_person_id igs_ad_appl_all.person_id%TYPE,
              cp_admission_appl_number igs_ad_appl_all.admission_appl_number%TYPE) IS
      SELECT s_admission_process_type
        FROM igs_ad_appl_all
       WHERE person_id = cp_person_id
         AND admission_appl_number = cp_admission_appl_number;

    Rec_IGS_AD_PS_APPL_Inst c_upd_acai_eqdo%ROWTYPE;

    l_offer_adm_outcome_status IGS_AD_PS_APPL_INST_ALL.adm_outcome_status%TYPE;
    l_application_status       IGS_AD_PS_APPL_INST_ALL.adm_doc_status%TYPE;

    l_offer_resp_status      IGS_AD_PS_APPL_INST_ALL.adm_offer_resp_status%TYPE;
    l_entry_qual_status      IGS_AD_PS_APPL_INST_ALL.adm_entry_qual_status%TYPE;
    l_admission_process_type IGS_AD_APPL_ALL.s_admission_process_type%TYPE;
    lv_mode VARCHAR2(1) DEFAULT 'R';

    l_sc_encoded_text   VARCHAR2(4000);
    l_sc_msg_count NUMBER;
    l_sc_msg_index NUMBER;
    l_sc_app_short_name VARCHAR2(50);
    l_sc_message_name   VARCHAR2(50);

  BEGIN

    IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;


    -- hreddych 3419856 For a NON-AWARD Appl Type the Entry Qual Status and Appl Comp Status
    -- should be NOT-APPLIC
    OPEN c_admission_process_type(p_person_id, p_admission_appl_number);
    FETCH c_admission_process_type
      INTO l_admission_process_type;
    CLOSE c_admission_process_type;
    IF l_admission_process_type = 'NON-AWARD' THEN
      l_application_status := igs_ad_gen_009.admp_get_sys_ads('NOT-APPLIC');
      l_entry_qual_status  := igs_ad_gen_009.admp_get_sys_aeqs('NOT-APPLIC');
    ELSE
      l_application_status := igs_ad_gen_009.admp_get_sys_ads('SATISFIED');
      l_entry_qual_status  := igs_ad_gen_009.admp_get_sys_aeqs('QUALIFIED');
    END IF;

    OPEN c_upd_acai_eqdo(p_person_id,
                         p_admission_appl_number,
                         p_nominated_course_cd,
                         p_sequence_number);

    FETCH c_upd_acai_eqdo
      INTO Rec_IGS_AD_PS_APPL_Inst;

    --Commented for Bug Fix 2395667 Moved the code after TBH call :tray
    --         CLOSE c_upd_acai_eqdo;

    IF (c_upd_acai_eqdo%FOUND) THEN

      IGS_AD_PS_APPL_Inst_Pkg.UPDATE_ROW(X_ROWID                        => Rec_IGS_AD_PS_APPL_Inst.ROWID,
                                         X_PERSON_ID                    => Rec_IGS_AD_PS_APPL_Inst.PERSON_ID,
                                         X_ADMISSION_APPL_NUMBER        => Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER,
                                         X_NOMINATED_COURSE_CD          => Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD,
                                         X_SEQUENCE_NUMBER              => Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER,
                                         X_PREDICTED_GPA                => Rec_IGS_AD_PS_APPL_Inst.PREDICTED_GPA,
                                         X_ACADEMIC_INDEX               => Rec_IGS_AD_PS_APPL_Inst.ACADEMIC_INDEX,
                                         X_Adm_Cal_Type                 => Rec_IGS_AD_PS_APPL_Inst.ADM_CAL_TYPE,
                                         X_APP_FILE_LOCATION            => Rec_IGS_AD_PS_APPL_Inst.APP_FILE_LOCATION,
                                         X_Adm_Ci_Sequence_Number       => Rec_IGS_AD_PS_APPL_Inst.ADM_CI_SEQUENCE_NUMBER,
                                         X_COURSE_CD                    => Rec_IGS_AD_PS_APPL_Inst.COURSE_CD,
                                         X_APP_SOURCE_ID                => Rec_IGS_AD_PS_APPL_Inst.APP_SOURCE_ID,
                                         X_CRV_VERSION_NUMBER           => Rec_IGS_AD_PS_APPL_Inst.CRV_VERSION_NUMBER,
                                         X_Waitlist_Rank                => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Rank,
                                         X_Waitlist_Status              => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Status,
                                         X_LOCATION_CD                  => Rec_IGS_AD_PS_APPL_Inst.LOCATION_CD,
                                         X_Attent_Other_Inst_Cd         => Rec_IGS_AD_PS_APPL_Inst.Attent_Other_Inst_Cd,
                                         X_ATTENDANCE_MODE              => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_MODE,
                                         X_Edu_Goal_Prior_Enroll_Id     => Rec_IGS_AD_PS_APPL_Inst.Edu_Goal_Prior_Enroll_Id,
                                         X_ATTENDANCE_TYPE              => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_TYPE,
                                         X_Decision_Make_Id             => Rec_IGS_AD_PS_APPL_Inst.Decision_Make_Id,
                                         X_UNIT_SET_CD                  => Rec_IGS_AD_PS_APPL_Inst.UNIT_SET_CD,
                                         X_Decision_Date                => Rec_IGS_AD_PS_APPL_Inst.Decision_Date,
                                         X_Attribute_Category           => Rec_IGS_AD_PS_APPL_Inst.Attribute_Category,
                                         X_Attribute1                   => Rec_IGS_AD_PS_APPL_Inst.Attribute1,
                                         X_Attribute2                   => Rec_IGS_AD_PS_APPL_Inst.Attribute2,
                                         X_Attribute3                   => Rec_IGS_AD_PS_APPL_Inst.Attribute3,
                                         X_Attribute4                   => Rec_IGS_AD_PS_APPL_Inst.Attribute4,
                                         X_Attribute5                   => Rec_IGS_AD_PS_APPL_Inst.Attribute5,
                                         X_Attribute6                   => Rec_IGS_AD_PS_APPL_Inst.Attribute6,
                                         X_Attribute7                   => Rec_IGS_AD_PS_APPL_Inst.Attribute7,
                                         X_Attribute8                   => Rec_IGS_AD_PS_APPL_Inst.Attribute8,
                                         X_Attribute9                   => Rec_IGS_AD_PS_APPL_Inst.Attribute9,
                                         X_Attribute10                  => Rec_IGS_AD_PS_APPL_Inst.Attribute10,
                                         X_Attribute11                  => Rec_IGS_AD_PS_APPL_Inst.Attribute11,
                                         X_Attribute12                  => Rec_IGS_AD_PS_APPL_Inst.Attribute12,
                                         X_Attribute13                  => Rec_IGS_AD_PS_APPL_Inst.Attribute13,
                                         X_Attribute14                  => Rec_IGS_AD_PS_APPL_Inst.Attribute14,
                                         X_Attribute15                  => Rec_IGS_AD_PS_APPL_Inst.Attribute15,
                                         X_Attribute16                  => Rec_IGS_AD_PS_APPL_Inst.Attribute16,
                                         X_Attribute17                  => Rec_IGS_AD_PS_APPL_Inst.Attribute17,
                                         X_Attribute18                  => Rec_IGS_AD_PS_APPL_Inst.Attribute18,
                                         X_Attribute19                  => Rec_IGS_AD_PS_APPL_Inst.Attribute19,
                                         X_Attribute20                  => Rec_IGS_AD_PS_APPL_Inst.Attribute20,
                                         X_Decision_Reason_Id           => Rec_IGS_AD_PS_APPL_Inst.Decision_Reason_Id,
                                         X_US_VERSION_NUMBER            => Rec_IGS_AD_PS_APPL_Inst.US_VERSION_NUMBER,
                                         X_Decision_Notes               => Rec_IGS_AD_PS_APPL_Inst.Decision_Notes,
                                         X_Pending_Reason_Id            => Rec_IGS_AD_PS_APPL_Inst.Pending_Reason_Id,
                                         X_PREFERENCE_NUMBER            => Rec_IGS_AD_PS_APPL_Inst.PREFERENCE_NUMBER,
                                         X_ADM_DOC_STATUS               => l_application_status,
                                         X_ADM_ENTRY_QUAL_STATUS        => l_entry_qual_status,
                                         X_DEFICIENCY_IN_PREP           => Rec_IGS_AD_PS_APPL_Inst.DEFICIENCY_IN_PREP,
                                         X_LATE_ADM_FEE_STATUS          => Rec_IGS_AD_PS_APPL_Inst.LATE_ADM_FEE_STATUS,
                                         X_Spl_Consider_Comments        => Rec_IGS_AD_PS_APPL_Inst.Spl_Consider_Comments,
                                         X_Apply_For_Finaid             => Rec_IGS_AD_PS_APPL_Inst.Apply_For_Finaid,
                                         X_Finaid_Apply_Date            => Rec_IGS_AD_PS_APPL_Inst.Finaid_Apply_Date,
                                         X_ADM_OUTCOME_STATUS           => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS,
                                         X_ADM_OTCM_STAT_AUTH_PER_ID    => Rec_IGS_AD_PS_APPL_Inst.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                         X_ADM_OUTCOME_STATUS_AUTH_DT   => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_AUTH_DT,
                                         X_ADM_OUTCOME_STATUS_REASON    => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_REASON,
                                         X_OFFER_DT                     => Rec_IGS_AD_PS_APPL_Inst.OFFER_DT,
                                         X_Offer_Response_Dt            => Rec_IGS_AD_PS_APPL_Inst.OFFER_RESPONSE_DT,
                                         X_PRPSD_COMMENCEMENT_DT        => Rec_IGS_AD_PS_APPL_Inst.Prpsd_Commencement_Dt,
                                         X_ADM_CNDTNL_OFFER_STATUS      => Rec_IGS_AD_PS_APPL_Inst.ADM_CNDTNL_OFFER_STATUS,
                                         X_CNDTNL_OFFER_SATISFIED_DT    => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_SATISFIED_DT,
                                         X_CNDNL_OFR_MUST_BE_STSFD_IND  => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                         X_Adm_Offer_Resp_Status        => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_RESP_STATUS,
                                         X_Actual_Response_Dt           => Rec_IGS_AD_PS_APPL_Inst.ACTUAL_RESPONSE_DT,
                                         X_Adm_Offer_Dfrmnt_Status      => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_DFRMNT_STATUS,
                                         X_Deferred_Adm_Cal_Type        => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CAL_TYPE,
                                         X_Deferred_Adm_Ci_Sequence_Num => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                         X_Deferred_Tracking_Id         => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_TRACKING_ID,
                                         X_ASS_RANK                     => Rec_IGS_AD_PS_APPL_Inst.ASS_RANK,
                                         X_SECONDARY_ASS_RANK           => Rec_IGS_AD_PS_APPL_Inst.SECONDARY_ASS_RANK,
                                         X_INTR_ACCEPT_ADVICE_NUM       => Rec_IGS_AD_PS_APPL_Inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
                                         X_ASS_TRACKING_ID              => Rec_IGS_AD_PS_APPL_Inst.ASS_TRACKING_ID,
                                         X_FEE_CAT                      => Rec_IGS_AD_PS_APPL_Inst.FEE_CAT,
                                         X_HECS_PAYMENT_OPTION          => Rec_IGS_AD_PS_APPL_Inst.HECS_PAYMENT_OPTION,
                                         X_Expected_Completion_Yr       => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_YR,
                                         X_Expected_Completion_Perd     => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_PERD,
                                         X_CORRESPONDENCE_CAT           => Rec_IGS_AD_PS_APPL_Inst.CORRESPONDENCE_CAT,
                                         X_ENROLMENT_CAT                => Rec_IGS_AD_PS_APPL_Inst.ENROLMENT_CAT,
                                         X_FUNDING_SOURCE               => Rec_IGS_AD_PS_APPL_Inst.FUNDING_SOURCE,
                                         X_APPLICANT_ACPTNCE_CNDTN      => Rec_IGS_AD_PS_APPL_Inst.APPLICANT_ACPTNCE_CNDTN,
                                         X_CNDTNL_OFFER_CNDTN           => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_CNDTN,
                                         X_SS_APPLICATION_ID            => Rec_IGS_AD_PS_APPL_Inst.SS_APPLICATION_ID,
                                         X_SS_PWD                       => Rec_IGS_AD_PS_APPL_Inst.SS_PWD,
                                         X_AUTHORIZED_DT                => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZED_DT,
                                         X_AUTHORIZING_PERS_ID          => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZING_PERS_ID,
                                         X_IDX_CALC_DATE                => Rec_IGS_AD_PS_APPL_Inst.IDX_CALC_DATE,
                                         X_ENTRY_STATUS                 => Rec_IGS_AD_PS_APPL_Inst.ENTRY_STATUS,
                                         X_ENTRY_LEVEL                  => Rec_IGS_AD_PS_APPL_Inst.ENTRY_LEVEL,
                                         X_SCH_APL_TO_ID                => Rec_IGS_AD_PS_APPL_Inst.SCH_APL_TO_ID,
                                         X_MODE                         => lv_mode, -- enable security for Admin
                                         X_Attribute21                  => Rec_IGS_AD_PS_APPL_Inst.Attribute21,
                                         X_Attribute22                  => Rec_IGS_AD_PS_APPL_Inst.Attribute22,
                                         X_Attribute23                  => Rec_IGS_AD_PS_APPL_Inst.Attribute23,
                                         X_Attribute24                  => Rec_IGS_AD_PS_APPL_Inst.Attribute24,
                                         X_Attribute25                  => Rec_IGS_AD_PS_APPL_Inst.Attribute25,
                                         X_Attribute26                  => Rec_IGS_AD_PS_APPL_Inst.Attribute26,
                                         X_Attribute27                  => Rec_IGS_AD_PS_APPL_Inst.Attribute27,
                                         X_Attribute28                  => Rec_IGS_AD_PS_APPL_Inst.Attribute28,
                                         X_Attribute29                  => Rec_IGS_AD_PS_APPL_Inst.Attribute29,
                                         X_Attribute30                  => Rec_IGS_AD_PS_APPL_Inst.Attribute30,
                                         X_Attribute31                  => Rec_IGS_AD_PS_APPL_Inst.Attribute31,
                                         X_Attribute32                  => Rec_IGS_AD_PS_APPL_Inst.Attribute32,
                                         X_Attribute33                  => Rec_IGS_AD_PS_APPL_Inst.Attribute33,
                                         X_Attribute34                  => Rec_IGS_AD_PS_APPL_Inst.Attribute34,
                                         X_Attribute35                  => Rec_IGS_AD_PS_APPL_Inst.Attribute35,
                                         X_Attribute36                  => Rec_IGS_AD_PS_APPL_Inst.Attribute36,
                                         X_Attribute37                  => Rec_IGS_AD_PS_APPL_Inst.Attribute37,
                                         X_Attribute38                  => Rec_IGS_AD_PS_APPL_Inst.Attribute38,
                                         X_Attribute39                  => Rec_IGS_AD_PS_APPL_Inst.Attribute39,
                                         X_Attribute40                  => Rec_IGS_AD_PS_APPL_Inst.Attribute40,
                                         X_FUT_ACAD_CAL_TYPE            => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CAL_TYPE,
                                         X_FUT_ACAD_CI_SEQUENCE_NUMBER  => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
                                         X_FUT_ADM_CAL_TYPE             => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CAL_TYPE,
                                         X_FUT_ADM_CI_SEQUENCE_NUMBER   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CI_SEQUENCE_NUMBER,
                                         X_PREV_TERM_ADM_APPL_NUMBER    => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                         X_PREV_TERM_SEQUENCE_NUMBER    => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                         X_FUT_TERM_ADM_APPL_NUMBER     => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_ADM_APPL_NUMBER,
                                         X_FUT_TERM_SEQUENCE_NUMBER     => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_SEQUENCE_NUMBER,
                                         X_DEF_ACAD_CAL_TYPE            => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CAL_TYPE, --Bug 2395510
                                         X_DEF_ACAD_CI_SEQUENCE_NUM     => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                                         X_DEF_PREV_TERM_ADM_APPL_NUM   => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_TERM_ADM_APPL_NUM, --Bug 2395510
                                         X_DEF_PREV_APPL_SEQUENCE_NUM   => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_APPL_SEQUENCE_NUM, --Bug 2395510
                                         X_DEF_TERM_ADM_APPL_NUM        => Rec_IGS_AD_PS_APPL_Inst.DEF_TERM_ADM_APPL_NUM, --Bug 2395510
                                         X_DEF_APPL_SEQUENCE_NUM        => Rec_IGS_AD_PS_APPL_Inst.DEF_APPL_SEQUENCE_NUM, --Bug 2395510
                                         X_APPL_INST_STATUS             => Rec_IGS_AD_PS_APPL_Inst.appl_inst_status,
                                         x_ais_reason                   => Rec_IGS_AD_PS_APPL_Inst.ais_reason,
                                         x_decline_ofr_reason           => Rec_IGS_AD_PS_APPL_Inst.decline_ofr_reason
                                         );

      --                COMMIT;  --tray Bug 2405076 , not needed as the posted data is fine to work with , no need of commit
    END IF;

    IF c_upd_acai_eqdo%ISOPEN THEN
       CLOSE c_upd_acai_eqdo;
    END IF;
    x_return_status := 'S';
    x_message_data := NULL;
  EXCEPTION
    WHEN OTHERS THEN
       l_sc_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
       WHILE l_sc_msg_count <> 0 loop
          igs_ge_msg_stack.get(l_sc_msg_count, 'T', l_sc_encoded_text, l_sc_msg_index);
          fnd_message.parse_encoded(l_sc_encoded_text, l_sc_app_short_name, l_sc_message_name);
          IF l_sc_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_sc_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
                x_return_status := 'E';
		x_message_data := 'IGS_SC_POLICY_EXCEPTION';
		RETURN;
           END IF;
           l_sc_msg_count := l_sc_msg_count - 1;
        END LOOP;

       IF FND_MSG_PUB.Count_Msg < 1 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	  Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.Update_Appl_Eqdo_Inst -'||SQLERRM);
	  IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
        x_return_status := 'E';
        x_message_data  := 'IGS_GE_UNHANDLED_EXP';

  END Update_Appl_Eqdo_Inst;

  PROCEDURE Update_Appl_Ofr_Inst(p_person_id             IN NUMBER,
                                 p_admission_appl_number IN NUMBER,
                                 p_nominated_course_cd   IN VARCHAR2,
                                 p_sequence_number       IN NUMBER,
                                 x_return_status         OUT NOCOPY VARCHAR2,
                                 x_message_data          OUT NOCOPY VARCHAR2) IS

    CURSOR c_upd_acai_outcm(cp_person_id IGS_AD_PS_APPL_INST.person_id%TYPE,
              cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
              cp_nominated_course_cd IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
              cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE) IS
      SELECT ROWID, acai.*
        FROM IGS_AD_PS_APPL_INST acai
       WHERE acai.person_id = cp_person_id
         AND acai.admission_appl_number = cp_admission_appl_number
         AND acai.nominated_course_cd = cp_nominated_course_cd
         AND acai.sequence_number = cp_sequence_number
         FOR UPDATE OF acai.adm_outcome_status NOWAIT;

    Rec_IGS_AD_PS_APPL_Inst c_upd_acai_outcm%ROWTYPE;

    l_offer_adm_outcome_status IGS_AD_PS_APPL_INST_ALL.adm_outcome_status%TYPE;
    l_application_status       IGS_AD_PS_APPL_INST_ALL.adm_doc_status%TYPE;

    l_offer_resp_status IGS_AD_PS_APPL_INST_ALL.adm_offer_resp_status%TYPE;
    l_entry_qual_status IGS_AD_PS_APPL_INST_ALL.adm_entry_qual_status%TYPE;

    lv_mode VARCHAR2(1) DEFAULT 'R';

    l_sc_encoded_text   VARCHAR2(4000);
    l_sc_msg_count NUMBER;
    l_sc_msg_index NUMBER;
    l_sc_app_short_name VARCHAR2(50);
    l_sc_message_name   VARCHAR2(50);
  BEGIN

    IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;

    l_offer_adm_outcome_status := IGS_AD_GEN_009.ADMP_GET_SYS_AOS('OFFER');
    l_offer_resp_status        := IGS_AD_GEN_009.ADMP_GET_SYS_AORS('PENDING');

    OPEN c_upd_acai_outcm(p_person_id,
                          p_admission_appl_number,
                          p_nominated_course_cd,
                          p_sequence_number);

    FETCH c_upd_acai_outcm
      INTO Rec_IGS_AD_PS_APPL_Inst;

    --Commented for Bug Fix 2395667 Moved the code after TBH call :tray
    --          CLOSE c_upd_acai_outcm;

    IF (c_upd_acai_outcm%FOUND) THEN

      IGS_AD_PS_APPL_Inst_Pkg.UPDATE_ROW(X_ROWID                        => Rec_IGS_AD_PS_APPL_Inst.ROWID,
                                         X_PERSON_ID                    => Rec_IGS_AD_PS_APPL_Inst.PERSON_ID,
                                         X_ADMISSION_APPL_NUMBER        => Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER,
                                         X_NOMINATED_COURSE_CD          => Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD,
                                         X_SEQUENCE_NUMBER              => Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER,
                                         X_PREDICTED_GPA                => Rec_IGS_AD_PS_APPL_Inst.PREDICTED_GPA,
                                         X_ACADEMIC_INDEX               => Rec_IGS_AD_PS_APPL_Inst.ACADEMIC_INDEX,
                                         X_Adm_Cal_Type                 => Rec_IGS_AD_PS_APPL_Inst.ADM_CAL_TYPE,
                                         X_APP_FILE_LOCATION            => Rec_IGS_AD_PS_APPL_Inst.APP_FILE_LOCATION,
                                         X_Adm_Ci_Sequence_Number       => Rec_IGS_AD_PS_APPL_Inst.ADM_CI_SEQUENCE_NUMBER,
                                         X_COURSE_CD                    => Rec_IGS_AD_PS_APPL_Inst.COURSE_CD,
                                         X_APP_SOURCE_ID                => Rec_IGS_AD_PS_APPL_Inst.APP_SOURCE_ID,
                                         X_CRV_VERSION_NUMBER           => Rec_IGS_AD_PS_APPL_Inst.CRV_VERSION_NUMBER,
                                         X_Waitlist_Rank                => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Rank,
                                         X_Waitlist_Status              => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Status,
                                         X_LOCATION_CD                  => Rec_IGS_AD_PS_APPL_Inst.LOCATION_CD,
                                         X_Attent_Other_Inst_Cd         => Rec_IGS_AD_PS_APPL_Inst.Attent_Other_Inst_Cd,
                                         X_ATTENDANCE_MODE              => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_MODE,
                                         X_Edu_Goal_Prior_Enroll_Id     => Rec_IGS_AD_PS_APPL_Inst.Edu_Goal_Prior_Enroll_Id,
                                         X_ATTENDANCE_TYPE              => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_TYPE,
                                         X_Decision_Make_Id             => Rec_IGS_AD_PS_APPL_Inst.Decision_Make_Id,
                                         X_UNIT_SET_CD                  => Rec_IGS_AD_PS_APPL_Inst.UNIT_SET_CD,
                                         X_Decision_Date                => Rec_IGS_AD_PS_APPL_Inst.Decision_Date,
                                         X_Attribute_Category           => Rec_IGS_AD_PS_APPL_Inst.Attribute_Category,
                                         X_Attribute1                   => Rec_IGS_AD_PS_APPL_Inst.Attribute1,
                                         X_Attribute2                   => Rec_IGS_AD_PS_APPL_Inst.Attribute2,
                                         X_Attribute3                   => Rec_IGS_AD_PS_APPL_Inst.Attribute3,
                                         X_Attribute4                   => Rec_IGS_AD_PS_APPL_Inst.Attribute4,
                                         X_Attribute5                   => Rec_IGS_AD_PS_APPL_Inst.Attribute5,
                                         X_Attribute6                   => Rec_IGS_AD_PS_APPL_Inst.Attribute6,
                                         X_Attribute7                   => Rec_IGS_AD_PS_APPL_Inst.Attribute7,
                                         X_Attribute8                   => Rec_IGS_AD_PS_APPL_Inst.Attribute8,
                                         X_Attribute9                   => Rec_IGS_AD_PS_APPL_Inst.Attribute9,
                                         X_Attribute10                  => Rec_IGS_AD_PS_APPL_Inst.Attribute10,
                                         X_Attribute11                  => Rec_IGS_AD_PS_APPL_Inst.Attribute11,
                                         X_Attribute12                  => Rec_IGS_AD_PS_APPL_Inst.Attribute12,
                                         X_Attribute13                  => Rec_IGS_AD_PS_APPL_Inst.Attribute13,
                                         X_Attribute14                  => Rec_IGS_AD_PS_APPL_Inst.Attribute14,
                                         X_Attribute15                  => Rec_IGS_AD_PS_APPL_Inst.Attribute15,
                                         X_Attribute16                  => Rec_IGS_AD_PS_APPL_Inst.Attribute16,
                                         X_Attribute17                  => Rec_IGS_AD_PS_APPL_Inst.Attribute17,
                                         X_Attribute18                  => Rec_IGS_AD_PS_APPL_Inst.Attribute18,
                                         X_Attribute19                  => Rec_IGS_AD_PS_APPL_Inst.Attribute19,
                                         X_Attribute20                  => Rec_IGS_AD_PS_APPL_Inst.Attribute20,
                                         X_Decision_Reason_Id           => Rec_IGS_AD_PS_APPL_Inst.Decision_Reason_Id,
                                         X_US_VERSION_NUMBER            => Rec_IGS_AD_PS_APPL_Inst.US_VERSION_NUMBER,
                                         X_Decision_Notes               => Rec_IGS_AD_PS_APPL_Inst.Decision_Notes,
                                         X_Pending_Reason_Id            => Rec_IGS_AD_PS_APPL_Inst.Pending_Reason_Id,
                                         X_PREFERENCE_NUMBER            => Rec_IGS_AD_PS_APPL_Inst.PREFERENCE_NUMBER,
                                         X_ADM_DOC_STATUS               => Rec_IGS_AD_PS_APPL_Inst.ADM_DOC_STATUS,
                                         X_ADM_ENTRY_QUAL_STATUS        => Rec_IGS_AD_PS_APPL_Inst.ADM_ENTRY_QUAL_STATUS,
                                         X_DEFICIENCY_IN_PREP           => Rec_IGS_AD_PS_APPL_Inst.DEFICIENCY_IN_PREP,
                                         X_LATE_ADM_FEE_STATUS          => Rec_IGS_AD_PS_APPL_Inst.LATE_ADM_FEE_STATUS,
                                         X_Spl_Consider_Comments        => Rec_IGS_AD_PS_APPL_Inst.Spl_Consider_Comments,
                                         X_Apply_For_Finaid             => Rec_IGS_AD_PS_APPL_Inst.Apply_For_Finaid,
                                         X_Finaid_Apply_Date            => Rec_IGS_AD_PS_APPL_Inst.Finaid_Apply_Date,
                                         X_ADM_OUTCOME_STATUS           => l_offer_adm_outcome_status,
                                         X_ADM_OTCM_STAT_AUTH_PER_ID    => Rec_IGS_AD_PS_APPL_Inst.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                         X_ADM_OUTCOME_STATUS_AUTH_DT   => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_AUTH_DT,
                                         X_ADM_OUTCOME_STATUS_REASON    => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_REASON,
                                         X_OFFER_DT                     => SYSDATE,
                                         X_Offer_Response_Dt            => SYSDATE,
                                         X_PRPSD_COMMENCEMENT_DT        => Rec_IGS_AD_PS_APPL_Inst.Prpsd_Commencement_Dt,
                                         X_ADM_CNDTNL_OFFER_STATUS      => Rec_IGS_AD_PS_APPL_Inst.ADM_CNDTNL_OFFER_STATUS,
                                         X_CNDTNL_OFFER_SATISFIED_DT    => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_SATISFIED_DT,
                                         X_CNDNL_OFR_MUST_BE_STSFD_IND  => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                         X_Adm_Offer_Resp_Status        => l_offer_resp_status,
                                         X_Actual_Response_Dt           => Rec_IGS_AD_PS_APPL_Inst.ACTUAL_RESPONSE_DT,
                                         X_Adm_Offer_Dfrmnt_Status      => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_DFRMNT_STATUS,
                                         X_Deferred_Adm_Cal_Type        => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CAL_TYPE,
                                         X_Deferred_Adm_Ci_Sequence_Num => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                         X_Deferred_Tracking_Id         => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_TRACKING_ID,
                                         X_ASS_RANK                     => Rec_IGS_AD_PS_APPL_Inst.ASS_RANK,
                                         X_SECONDARY_ASS_RANK           => Rec_IGS_AD_PS_APPL_Inst.SECONDARY_ASS_RANK,
                                         X_INTR_ACCEPT_ADVICE_NUM       => Rec_IGS_AD_PS_APPL_Inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
                                         X_ASS_TRACKING_ID              => Rec_IGS_AD_PS_APPL_Inst.ASS_TRACKING_ID,
                                         X_FEE_CAT                      => Rec_IGS_AD_PS_APPL_Inst.FEE_CAT,
                                         X_HECS_PAYMENT_OPTION          => Rec_IGS_AD_PS_APPL_Inst.HECS_PAYMENT_OPTION,
                                         X_Expected_Completion_Yr       => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_YR,
                                         X_Expected_Completion_Perd     => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_PERD,
                                         X_CORRESPONDENCE_CAT           => Rec_IGS_AD_PS_APPL_Inst.CORRESPONDENCE_CAT,
                                         X_ENROLMENT_CAT                => Rec_IGS_AD_PS_APPL_Inst.ENROLMENT_CAT,
                                         X_FUNDING_SOURCE               => Rec_IGS_AD_PS_APPL_Inst.FUNDING_SOURCE,
                                         X_APPLICANT_ACPTNCE_CNDTN      => Rec_IGS_AD_PS_APPL_Inst.APPLICANT_ACPTNCE_CNDTN,
                                         X_CNDTNL_OFFER_CNDTN           => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_CNDTN,
                                         X_SS_APPLICATION_ID            => Rec_IGS_AD_PS_APPL_Inst.SS_APPLICATION_ID,
                                         X_SS_PWD                       => Rec_IGS_AD_PS_APPL_Inst.SS_PWD,
                                         X_AUTHORIZED_DT                => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZED_DT,
                                         X_AUTHORIZING_PERS_ID          => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZING_PERS_ID,
                                         X_IDX_CALC_DATE                => Rec_IGS_AD_PS_APPL_Inst.IDX_CALC_DATE,
                                         X_ENTRY_STATUS                 => Rec_IGS_AD_PS_APPL_Inst.ENTRY_STATUS,
                                         X_ENTRY_LEVEL                  => Rec_IGS_AD_PS_APPL_Inst.ENTRY_LEVEL,
                                         X_SCH_APL_TO_ID                => Rec_IGS_AD_PS_APPL_Inst.SCH_APL_TO_ID,
                                         X_MODE                         => lv_mode, -- enable security for Admin
                                         X_Attribute21                  => Rec_IGS_AD_PS_APPL_Inst.Attribute21,
                                         X_Attribute22                  => Rec_IGS_AD_PS_APPL_Inst.Attribute22,
                                         X_Attribute23                  => Rec_IGS_AD_PS_APPL_Inst.Attribute23,
                                         X_Attribute24                  => Rec_IGS_AD_PS_APPL_Inst.Attribute24,
                                         X_Attribute25                  => Rec_IGS_AD_PS_APPL_Inst.Attribute25,
                                         X_Attribute26                  => Rec_IGS_AD_PS_APPL_Inst.Attribute26,
                                         X_Attribute27                  => Rec_IGS_AD_PS_APPL_Inst.Attribute27,
                                         X_Attribute28                  => Rec_IGS_AD_PS_APPL_Inst.Attribute28,
                                         X_Attribute29                  => Rec_IGS_AD_PS_APPL_Inst.Attribute29,
                                         X_Attribute30                  => Rec_IGS_AD_PS_APPL_Inst.Attribute30,
                                         X_Attribute31                  => Rec_IGS_AD_PS_APPL_Inst.Attribute31,
                                         X_Attribute32                  => Rec_IGS_AD_PS_APPL_Inst.Attribute32,
                                         X_Attribute33                  => Rec_IGS_AD_PS_APPL_Inst.Attribute33,
                                         X_Attribute34                  => Rec_IGS_AD_PS_APPL_Inst.Attribute34,
                                         X_Attribute35                  => Rec_IGS_AD_PS_APPL_Inst.Attribute35,
                                         X_Attribute36                  => Rec_IGS_AD_PS_APPL_Inst.Attribute36,
                                         X_Attribute37                  => Rec_IGS_AD_PS_APPL_Inst.Attribute37,
                                         X_Attribute38                  => Rec_IGS_AD_PS_APPL_Inst.Attribute38,
                                         X_Attribute39                  => Rec_IGS_AD_PS_APPL_Inst.Attribute39,
                                         X_Attribute40                  => Rec_IGS_AD_PS_APPL_Inst.Attribute40,
                                         X_FUT_ACAD_CAL_TYPE            => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CAL_TYPE,
                                         X_FUT_ACAD_CI_SEQUENCE_NUMBER  => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
                                         X_FUT_ADM_CAL_TYPE             => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CAL_TYPE,
                                         X_FUT_ADM_CI_SEQUENCE_NUMBER   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CI_SEQUENCE_NUMBER,
                                         X_PREV_TERM_ADM_APPL_NUMBER    => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                         X_PREV_TERM_SEQUENCE_NUMBER    => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                         X_FUT_TERM_ADM_APPL_NUMBER     => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_ADM_APPL_NUMBER,
                                         X_FUT_TERM_SEQUENCE_NUMBER     => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_SEQUENCE_NUMBER,
                                         X_DEF_ACAD_CAL_TYPE            => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CAL_TYPE, --Bug 2395510
                                         X_DEF_ACAD_CI_SEQUENCE_NUM     => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                                         X_DEF_PREV_TERM_ADM_APPL_NUM   => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_TERM_ADM_APPL_NUM, --Bug 2395510
                                         X_DEF_PREV_APPL_SEQUENCE_NUM   => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_APPL_SEQUENCE_NUM, --Bug 2395510
                                         X_DEF_TERM_ADM_APPL_NUM        => Rec_IGS_AD_PS_APPL_Inst.DEF_TERM_ADM_APPL_NUM, --Bug 2395510
                                         X_DEF_APPL_SEQUENCE_NUM        => Rec_IGS_AD_PS_APPL_Inst.DEF_APPL_SEQUENCE_NUM, --Bug 2395510
                                         X_APPL_INST_STATUS             => Rec_IGS_AD_PS_APPL_Inst.appl_inst_status,
                                         x_ais_reason                   => Rec_IGS_AD_PS_APPL_Inst.ais_reason,
                                         x_decline_ofr_reason           => Rec_IGS_AD_PS_APPL_Inst.decline_ofr_reason
                                         );

      --COMMIT;
    END IF;

    IF c_upd_acai_outcm%ISOPEN THEN
       CLOSE c_upd_acai_outcm;
    END IF;
    x_return_status := 'S';
    x_message_data := NULL;
  EXCEPTION
    WHEN OTHERS THEN
       l_sc_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
       WHILE l_sc_msg_count <> 0 loop
          igs_ge_msg_stack.get(l_sc_msg_count, 'T', l_sc_encoded_text, l_sc_msg_index);
          fnd_message.parse_encoded(l_sc_encoded_text, l_sc_app_short_name, l_sc_message_name);
          IF l_sc_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_sc_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
                x_return_status := 'E';
		x_message_data := 'IGS_SC_POLICY_EXCEPTION';
		RETURN;
           END IF;
           l_sc_msg_count := l_sc_msg_count - 1;
        END LOOP;

        IF FND_MSG_PUB.Count_Msg < 1 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	  Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.Update_Appl_Ofr_Inst -'||SQLERRM);
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception;
        END IF;
        x_return_status := 'E';
        x_message_data  := 'IGS_GE_UNHANDLED_EXP';

  END Update_Appl_Ofr_Inst;

  PROCEDURE Update_Appl_Ofres_Inst(p_person_id             IN NUMBER,
                                   p_admission_appl_number IN NUMBER,
                                   p_nominated_course_cd   IN VARCHAR2,
                                   p_sequence_number       IN NUMBER,
                                   x_return_status         OUT NOCOPY VARCHAR2,
                                   x_message_data          OUT NOCOPY VARCHAR2) IS

    CURSOR c_upd_acai_resp(cp_person_id IGS_AD_PS_APPL_INST.person_id%TYPE,
                cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                cp_nominated_course_cd IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
                cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE) IS
      SELECT ROWID, acai.*
        FROM IGS_AD_PS_APPL_INST acai
       WHERE acai.person_id = cp_person_id
         AND acai.admission_appl_number = cp_admission_appl_number
         AND acai.nominated_course_cd = cp_nominated_course_cd
         AND acai.sequence_number = cp_sequence_number
         FOR UPDATE OF acai.ADM_OFFER_RESP_STATUS NOWAIT;

    Rec_IGS_AD_PS_APPL_Inst c_upd_acai_resp%ROWTYPE;

    l_offer_resp_status IGS_AD_PS_APPL_INST_ALL.adm_offer_resp_status%TYPE;

   lv_mode VARCHAR2(1) DEFAULT 'R';
  BEGIN

    IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;

    l_offer_resp_status := IGS_AD_GEN_009.ADMP_GET_SYS_AORS('ACCEPTED');

    OPEN c_upd_acai_resp(p_person_id,
                         p_admission_appl_number,
                         p_nominated_course_cd,
                         p_sequence_number);

    FETCH c_upd_acai_resp
      INTO Rec_IGS_AD_PS_APPL_Inst;

    --Commented for Bug Fix 2395667, Moved the code after TBH call :tray
    --         CLOSE c_upd_acai_resp;

    IF (c_upd_acai_resp%FOUND) THEN

      IGS_AD_PS_APPL_Inst_Pkg.UPDATE_ROW(X_ROWID                        => Rec_IGS_AD_PS_APPL_Inst.ROWID,
                                         X_PERSON_ID                    => Rec_IGS_AD_PS_APPL_Inst.PERSON_ID,
                                         X_ADMISSION_APPL_NUMBER        => Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER,
                                         X_NOMINATED_COURSE_CD          => Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD,
                                         X_SEQUENCE_NUMBER              => Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER,
                                         X_PREDICTED_GPA                => Rec_IGS_AD_PS_APPL_Inst.PREDICTED_GPA,
                                         X_ACADEMIC_INDEX               => Rec_IGS_AD_PS_APPL_Inst.ACADEMIC_INDEX,
                                         X_Adm_Cal_Type                 => Rec_IGS_AD_PS_APPL_Inst.ADM_CAL_TYPE,
                                         X_APP_FILE_LOCATION            => Rec_IGS_AD_PS_APPL_Inst.APP_FILE_LOCATION,
                                         X_Adm_Ci_Sequence_Number       => Rec_IGS_AD_PS_APPL_Inst.ADM_CI_SEQUENCE_NUMBER,
                                         X_COURSE_CD                    => Rec_IGS_AD_PS_APPL_Inst.COURSE_CD,
                                         X_APP_SOURCE_ID                => Rec_IGS_AD_PS_APPL_Inst.APP_SOURCE_ID,
                                         X_CRV_VERSION_NUMBER           => Rec_IGS_AD_PS_APPL_Inst.CRV_VERSION_NUMBER,
                                         X_Waitlist_Rank                => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Rank,
                                         X_Waitlist_Status              => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Status,
                                         X_LOCATION_CD                  => Rec_IGS_AD_PS_APPL_Inst.LOCATION_CD,
                                         X_Attent_Other_Inst_Cd         => Rec_IGS_AD_PS_APPL_Inst.Attent_Other_Inst_Cd,
                                         X_ATTENDANCE_MODE              => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_MODE,
                                         X_Edu_Goal_Prior_Enroll_Id     => Rec_IGS_AD_PS_APPL_Inst.Edu_Goal_Prior_Enroll_Id,
                                         X_ATTENDANCE_TYPE              => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_TYPE,
                                         X_Decision_Make_Id             => Rec_IGS_AD_PS_APPL_Inst.Decision_Make_Id,
                                         X_UNIT_SET_CD                  => Rec_IGS_AD_PS_APPL_Inst.UNIT_SET_CD,
                                         X_Decision_Date                => Rec_IGS_AD_PS_APPL_Inst.Decision_Date,
                                         X_Attribute_Category           => Rec_IGS_AD_PS_APPL_Inst.Attribute_Category,
                                         X_Attribute1                   => Rec_IGS_AD_PS_APPL_Inst.Attribute1,
                                         X_Attribute2                   => Rec_IGS_AD_PS_APPL_Inst.Attribute2,
                                         X_Attribute3                   => Rec_IGS_AD_PS_APPL_Inst.Attribute3,
                                         X_Attribute4                   => Rec_IGS_AD_PS_APPL_Inst.Attribute4,
                                         X_Attribute5                   => Rec_IGS_AD_PS_APPL_Inst.Attribute5,
                                         X_Attribute6                   => Rec_IGS_AD_PS_APPL_Inst.Attribute6,
                                         X_Attribute7                   => Rec_IGS_AD_PS_APPL_Inst.Attribute7,
                                         X_Attribute8                   => Rec_IGS_AD_PS_APPL_Inst.Attribute8,
                                         X_Attribute9                   => Rec_IGS_AD_PS_APPL_Inst.Attribute9,
                                         X_Attribute10                  => Rec_IGS_AD_PS_APPL_Inst.Attribute10,
                                         X_Attribute11                  => Rec_IGS_AD_PS_APPL_Inst.Attribute11,
                                         X_Attribute12                  => Rec_IGS_AD_PS_APPL_Inst.Attribute12,
                                         X_Attribute13                  => Rec_IGS_AD_PS_APPL_Inst.Attribute13,
                                         X_Attribute14                  => Rec_IGS_AD_PS_APPL_Inst.Attribute14,
                                         X_Attribute15                  => Rec_IGS_AD_PS_APPL_Inst.Attribute15,
                                         X_Attribute16                  => Rec_IGS_AD_PS_APPL_Inst.Attribute16,
                                         X_Attribute17                  => Rec_IGS_AD_PS_APPL_Inst.Attribute17,
                                         X_Attribute18                  => Rec_IGS_AD_PS_APPL_Inst.Attribute18,
                                         X_Attribute19                  => Rec_IGS_AD_PS_APPL_Inst.Attribute19,
                                         X_Attribute20                  => Rec_IGS_AD_PS_APPL_Inst.Attribute20,
                                         X_Decision_Reason_Id           => Rec_IGS_AD_PS_APPL_Inst.Decision_Reason_Id,
                                         X_US_VERSION_NUMBER            => Rec_IGS_AD_PS_APPL_Inst.US_VERSION_NUMBER,
                                         X_Decision_Notes               => Rec_IGS_AD_PS_APPL_Inst.Decision_Notes,
                                         X_Pending_Reason_Id            => Rec_IGS_AD_PS_APPL_Inst.Pending_Reason_Id,
                                         X_PREFERENCE_NUMBER            => Rec_IGS_AD_PS_APPL_Inst.PREFERENCE_NUMBER,
                                         X_ADM_DOC_STATUS               => Rec_IGS_AD_PS_APPL_Inst.ADM_DOC_STATUS,
                                         X_ADM_ENTRY_QUAL_STATUS        => Rec_IGS_AD_PS_APPL_Inst.ADM_ENTRY_QUAL_STATUS,
                                         X_DEFICIENCY_IN_PREP           => Rec_IGS_AD_PS_APPL_Inst.DEFICIENCY_IN_PREP,
                                         X_LATE_ADM_FEE_STATUS          => Rec_IGS_AD_PS_APPL_Inst.LATE_ADM_FEE_STATUS,
                                         X_Spl_Consider_Comments        => Rec_IGS_AD_PS_APPL_Inst.Spl_Consider_Comments,
                                         X_Apply_For_Finaid             => Rec_IGS_AD_PS_APPL_Inst.Apply_For_Finaid,
                                         X_Finaid_Apply_Date            => Rec_IGS_AD_PS_APPL_Inst.Finaid_Apply_Date,
                                         X_ADM_OUTCOME_STATUS           => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS,
                                         X_ADM_OTCM_STAT_AUTH_PER_ID    => Rec_IGS_AD_PS_APPL_Inst.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                         X_ADM_OUTCOME_STATUS_AUTH_DT   => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_AUTH_DT,
                                         X_ADM_OUTCOME_STATUS_REASON    => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_REASON,
                                         X_OFFER_DT                     => Rec_IGS_AD_PS_APPL_Inst.OFFER_DT,
                                         X_Offer_Response_Dt            => Rec_IGS_AD_PS_APPL_Inst.OFFER_RESPONSE_DT,
                                         X_PRPSD_COMMENCEMENT_DT        => Rec_IGS_AD_PS_APPL_Inst.Prpsd_Commencement_Dt,
                                         X_ADM_CNDTNL_OFFER_STATUS      => Rec_IGS_AD_PS_APPL_Inst.ADM_CNDTNL_OFFER_STATUS,
                                         X_CNDTNL_OFFER_SATISFIED_DT    => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_SATISFIED_DT,
                                         X_CNDNL_OFR_MUST_BE_STSFD_IND  => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                         X_Adm_Offer_Resp_Status        => l_offer_resp_status,
                                         X_Actual_Response_Dt           => SYSDATE,
                                         X_Adm_Offer_Dfrmnt_Status      => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_DFRMNT_STATUS,
                                         X_Deferred_Adm_Cal_Type        => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CAL_TYPE,
                                         X_Deferred_Adm_Ci_Sequence_Num => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                         X_Deferred_Tracking_Id         => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_TRACKING_ID,
                                         X_ASS_RANK                     => Rec_IGS_AD_PS_APPL_Inst.ASS_RANK,
                                         X_SECONDARY_ASS_RANK           => Rec_IGS_AD_PS_APPL_Inst.SECONDARY_ASS_RANK,
                                         X_INTR_ACCEPT_ADVICE_NUM       => Rec_IGS_AD_PS_APPL_Inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
                                         X_ASS_TRACKING_ID              => Rec_IGS_AD_PS_APPL_Inst.ASS_TRACKING_ID,
                                         X_FEE_CAT                      => Rec_IGS_AD_PS_APPL_Inst.FEE_CAT,
                                         X_HECS_PAYMENT_OPTION          => Rec_IGS_AD_PS_APPL_Inst.HECS_PAYMENT_OPTION,
                                         X_Expected_Completion_Yr       => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_YR,
                                         X_Expected_Completion_Perd     => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_PERD,
                                         X_CORRESPONDENCE_CAT           => Rec_IGS_AD_PS_APPL_Inst.CORRESPONDENCE_CAT,
                                         X_ENROLMENT_CAT                => Rec_IGS_AD_PS_APPL_Inst.ENROLMENT_CAT,
                                         X_FUNDING_SOURCE               => Rec_IGS_AD_PS_APPL_Inst.FUNDING_SOURCE,
                                         X_APPLICANT_ACPTNCE_CNDTN      => Rec_IGS_AD_PS_APPL_Inst.APPLICANT_ACPTNCE_CNDTN,
                                         X_CNDTNL_OFFER_CNDTN           => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_CNDTN,
                                         X_SS_APPLICATION_ID            => Rec_IGS_AD_PS_APPL_Inst.SS_APPLICATION_ID,
                                         X_SS_PWD                       => Rec_IGS_AD_PS_APPL_Inst.SS_PWD,
                                         X_AUTHORIZED_DT                => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZED_DT,
                                         X_AUTHORIZING_PERS_ID          => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZING_PERS_ID,
                                         X_IDX_CALC_DATE                => Rec_IGS_AD_PS_APPL_Inst.IDX_CALC_DATE,
                                         X_ENTRY_STATUS                 => Rec_IGS_AD_PS_APPL_Inst.ENTRY_STATUS,
                                         X_ENTRY_LEVEL                  => Rec_IGS_AD_PS_APPL_Inst.ENTRY_LEVEL,
                                         X_SCH_APL_TO_ID                => Rec_IGS_AD_PS_APPL_Inst.SCH_APL_TO_ID,
                                         X_MODE                         => lv_mode, -- enable security for Admin
                                         X_Attribute21                  => Rec_IGS_AD_PS_APPL_Inst.Attribute21,
                                         X_Attribute22                  => Rec_IGS_AD_PS_APPL_Inst.Attribute22,
                                         X_Attribute23                  => Rec_IGS_AD_PS_APPL_Inst.Attribute23,
                                         X_Attribute24                  => Rec_IGS_AD_PS_APPL_Inst.Attribute24,
                                         X_Attribute25                  => Rec_IGS_AD_PS_APPL_Inst.Attribute25,
                                         X_Attribute26                  => Rec_IGS_AD_PS_APPL_Inst.Attribute26,
                                         X_Attribute27                  => Rec_IGS_AD_PS_APPL_Inst.Attribute27,
                                         X_Attribute28                  => Rec_IGS_AD_PS_APPL_Inst.Attribute28,
                                         X_Attribute29                  => Rec_IGS_AD_PS_APPL_Inst.Attribute29,
                                         X_Attribute30                  => Rec_IGS_AD_PS_APPL_Inst.Attribute30,
                                         X_Attribute31                  => Rec_IGS_AD_PS_APPL_Inst.Attribute31,
                                         X_Attribute32                  => Rec_IGS_AD_PS_APPL_Inst.Attribute32,
                                         X_Attribute33                  => Rec_IGS_AD_PS_APPL_Inst.Attribute33,
                                         X_Attribute34                  => Rec_IGS_AD_PS_APPL_Inst.Attribute34,
                                         X_Attribute35                  => Rec_IGS_AD_PS_APPL_Inst.Attribute35,
                                         X_Attribute36                  => Rec_IGS_AD_PS_APPL_Inst.Attribute36,
                                         X_Attribute37                  => Rec_IGS_AD_PS_APPL_Inst.Attribute37,
                                         X_Attribute38                  => Rec_IGS_AD_PS_APPL_Inst.Attribute38,
                                         X_Attribute39                  => Rec_IGS_AD_PS_APPL_Inst.Attribute39,
                                         X_Attribute40                  => Rec_IGS_AD_PS_APPL_Inst.Attribute40,
                                         X_FUT_ACAD_CAL_TYPE            => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CAL_TYPE,
                                         X_FUT_ACAD_CI_SEQUENCE_NUMBER  => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
                                         X_FUT_ADM_CAL_TYPE             => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CAL_TYPE,
                                         X_FUT_ADM_CI_SEQUENCE_NUMBER   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CI_SEQUENCE_NUMBER,
                                         X_PREV_TERM_ADM_APPL_NUMBER    => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                         X_PREV_TERM_SEQUENCE_NUMBER    => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                         X_FUT_TERM_ADM_APPL_NUMBER     => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_ADM_APPL_NUMBER,
                                         X_FUT_TERM_SEQUENCE_NUMBER     => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_SEQUENCE_NUMBER,
                                         X_DEF_ACAD_CAL_TYPE            => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CAL_TYPE, --Bug 2395510
                                         X_DEF_ACAD_CI_SEQUENCE_NUM     => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                                         X_DEF_PREV_TERM_ADM_APPL_NUM   => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_TERM_ADM_APPL_NUM, --Bug 2395510
                                         X_DEF_PREV_APPL_SEQUENCE_NUM   => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_APPL_SEQUENCE_NUM, --Bug 2395510
                                         X_DEF_TERM_ADM_APPL_NUM        => Rec_IGS_AD_PS_APPL_Inst.DEF_TERM_ADM_APPL_NUM, --Bug 2395510
                                         X_DEF_APPL_SEQUENCE_NUM        => Rec_IGS_AD_PS_APPL_Inst.DEF_APPL_SEQUENCE_NUM, --Bug 2395510
                                         X_APPL_INST_STATUS             => Rec_IGS_AD_PS_APPL_Inst.appl_inst_status,
                                         X_AIS_REASON                   => Rec_IGS_AD_PS_APPL_Inst.ais_reason,
                                         X_DECLINE_OFR_REASON           => Rec_IGS_AD_PS_APPL_Inst.decline_ofr_reason

                                         );

      --  COMMIT;
    END IF;
    CLOSE c_upd_acai_resp;
    x_return_status := 'S';

  EXCEPTION
    WHEN others THEN
      x_return_status := 'E';
      x_message_data  := 'IGS_AD_OFFER_RESP_FAILED';
  END Update_Appl_ofres_Inst;

  PROCEDURE insert_appl_section_stat(x_message_name    OUT NOCOPY VARCHAR2,
                                     x_return_status   OUT NOCOPY VARCHAR2,
                                     p_person_id       IN NUMBER,
                                     p_adm_appl_number IN NUMBER,
                                     p_login_id        IN NUMBER) AS
    /*****************************************************************************************
    Created By: Tapash.Ray@oracle.com
    Date Created : 16-APR-2002
    Purpose: 1. Inserts record from Self Service Admissions form (New Application Screen).
             2. These Records are to be used in review and submit applications page as checklist items.
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    stammine   10-June-05    Modified the Cursor of Checklist values.
    *****************************************************************************************/

    CURSOR c_chklist(cp_ApplNum igs_ss_Adm_appl_stg.SS_ADM_APPL_ID%TYPE, cp_person_id igs_ss_Adm_appl_stg.PERSON_ID%TYPE) IS
      SELECT pgs.page_name section
        FROM igs_ad_ss_appl_pgs pgs
       WHERE pgs.admission_application_type =
             (SELECT admission_application_type
                FROM igs_ss_adm_appl_stg
               WHERE ss_adm_appl_id = cp_ApplNum)
         AND pgs.include_ind = 'Y'
         AND NOT EXISTS ( SELECT 'x'
        FROM igs_ss_ad_sec_stat
       WHERE person_id = cp_person_id
         AND ss_adm_appl_id = cp_ApplNum
         AND section = pgs.page_name);

  BEGIN
    FOR c_chklist_values_rec IN c_chklist(p_adm_appl_number, p_person_id) LOOP
      INSERT INTO IGS_SS_AD_SEC_STAT
        (SS_ADM_APPL_ID,
         PERSON_ID,
         SECTION,
         COMPLETION_STATUS,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN)
      VALUES
        (P_ADM_APPL_NUMBER,
         P_PERSON_ID,
         c_chklist_values_rec.section,
         'NOTSTARTED',
         P_LOGIN_ID,
         SYSDATE,
         SYSDATE,
         P_LOGIN_ID,
         P_LOGIN_ID);
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Count_Msg < 1 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	  Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_appl_section_stat -'||SQLERRM);
	  IGS_GE_MSG_STACK.ADD;
       END IF;
        x_return_status := 'E';
        x_message_name  := 'IGS_GE_UNHANDLED_EXP';
      App_Exception.Raise_Exception;

  END insert_appl_section_stat;

  -- Procedure added by tray
  -- Validates program instance in SS Appl
  PROCEDURE validate_prog_inst(p_course_cd                IN VARCHAR2,
                               p_crv_version_number       IN NUMBER,
                               p_location_cd              IN VARCHAR2,
                               p_attendance_mode          IN VARCHAR2,
                               p_attendance_type          IN VARCHAR2,
                               p_acad_cal_type            IN VARCHAR2,
                               p_acad_ci_sequence_number  IN NUMBER,
                               p_adm_cal_type             IN VARCHAR2,
                               p_adm_ci_sequence_number   IN NUMBER,
                               p_admission_cat            IN VARCHAR2,
                               p_s_admission_process_type IN VARCHAR2,
                               p_message_name             OUT NOCOPY VARCHAR2,
                               p_return_type              OUT NOCOPY VARCHAR2) IS
    CURSOR c_apcs IS
      SELECT s_admission_step_type, step_type_restriction_num
        FROM igs_ad_prcs_cat_step
       WHERE admission_cat = p_admission_cat
         AND s_admission_process_type = p_s_admission_process_type
         AND step_group_type <> 'TRACK';

    l_late_ind          VARCHAR2(1);
    v_apcs_late_app_ind VARCHAR2(127);
    lreader             BOOLEAN;
  BEGIN
    v_apcs_late_app_ind := 'N';

    FOR v_apcs_rec IN c_apcs LOOP
      IF (v_apcs_rec.s_admission_step_type = 'LATE-APP') THEN
        v_apcs_late_app_ind := 'Y';
      END IF;
    END LOOP;

    -------------------------------------------------------------------------------------

    -- Validate program offering patterns

    --------------------------------------------------------------------------------------

    lreader := igs_ad_val_acai.admp_val_acai_cop(p_course_cd,
                                                 p_crv_version_number,
                                                 p_location_cd,
                                                 p_attendance_mode,
                                                 p_attendance_type,
                                                 p_acad_cal_type,
                                                 p_acad_ci_sequence_number,
                                                 p_adm_cal_type,
                                                 p_adm_ci_sequence_number,
                                                 p_admission_cat,
                                                 p_s_admission_process_type,
                                                 'N',
                                                 TRUNC(SYSDATE),
                                                 v_apcs_late_app_ind,
                                                 'N',
                                                 p_message_name,
                                                 p_return_type,
                                                 l_late_ind);
  END validate_prog_inst;

  -- Bug # 2389273 [ APPLICATION  FEE SAVED IN SS IS NOT SAVED TO FORMS ]
  PROCEDURE insert_application_fee(p_person_id       IN igs_ad_app_req.person_id%TYPE,
                                   p_adm_appl_id     IN igs_ss_app_req_stg.ss_adm_appl_id%TYPE,
                                   p_adm_appl_number IN igs_ad_app_req.admission_appl_number%TYPE) AS
    /*----------------------------------------------------------------------------
    ||  Created By :
    ||  Created On :
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  pathipat        17-Jun-2003     Enh 2831587 - FI210 Credit Card Fund Transfer build
    ||                                  Added 3 new params in call to igs_ad_app_req_pkg.insert_row
    ||vvutukur   26-Nov-2002   Enh#2584986.Added 11 new parameters to the call to igs_ad_app_req_pkg.insert_row
    ||                         (attributing to credit card details,Accounting information and the GL_DATE)
    ||                         as part of GL Interface Build and passed NULL to all of them.
    ----------------------------------------------------------------------------*/

    l_rowid      VARCHAR2(25);
    l_app_req_id igs_ad_app_req.app_req_id%TYPE;

    CURSOR c_appl_fee IS
      SELECT ss_app_req_id,
             applicant_fee_type,
             applicant_fee_status,
             fee_date,
             fee_payment_method,
             fee_amount,
             reference_num
        FROM IGS_SS_APP_REQ_STG
       WHERE person_id = p_person_id
         AND ss_adm_appl_id = p_adm_appl_id;
   lv_mode VARCHAR2(1) DEFAULT 'R';
  BEGIN

    IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;
    logHeader('insert_application_fee', 'S');
    FOR c_appl_fee_rec IN c_appl_fee LOOP
      IF c_appl_fee_rec.ss_app_req_id IS NOT NULL THEN
        logDetail('Before call to IGS_AD_APP_REQ_PKG.insert_row', 'S');
        igs_ad_app_req_pkg.insert_row(x_rowid                       => l_rowid,
                                      x_app_req_id                  => l_app_req_id,
                                      x_person_id                   => p_person_id,
                                      x_admission_appl_number       => p_adm_appl_number,
                                      x_applicant_fee_type          => c_appl_fee_rec.applicant_fee_type,
                                      x_applicant_fee_status        => c_appl_fee_rec.applicant_fee_status,
                                      x_fee_date                    => c_appl_fee_rec.FEE_DATE,
                                      X_FEE_PAYMENT_METHOD          => c_appl_fee_rec.FEE_PAYMENT_METHOD,
                                      X_FEE_AMOUNT                  => c_appl_fee_rec.FEE_AMOUNT,
                                      X_REFERENCE_NUM               => c_appl_fee_rec.REFERENCE_NUM,
                                      x_mode                        => lv_mode, -- enable security for Admin
                                      x_credit_card_code            => NULL,
                                      x_credit_card_holder_name     => NULL,
                                      x_credit_card_number          => NULL,
                                      x_credit_card_expiration_date => NULL,
                                      x_rev_gl_ccid                 => NULL,
                                      x_cash_gl_ccid                => NULL,
                                      x_rev_account_cd              => NULL,
                                      x_cash_account_cd             => NULL,
                                      x_gl_date                     => NULL,
                                      x_gl_posted_date              => NULL,
                                      x_posting_control_id          => NULL,
                                      x_credit_card_tangible_cd     => NULL,
                                      x_credit_card_payee_cd        => NULL,
                                      x_credit_card_status_code     => NULL);

      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      logDetail('Inside insert_application_fee' ||
                'Exception from IGS_AD_APP_REQ_PKG.insert_row ' || SQLERRM ||
                'person_id : ' || IGS_GE_NUMBER.TO_CANN(p_person_id),
                'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	  Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.insert_application_fee -'||SQLERRM);
	  IGS_GE_MSG_STACK.ADD;
       END IF;
       App_Exception.Raise_Exception;

  END insert_application_fee;

  /*
  --------------------------------------------------------------------------------------------------
  --Function to get the major first choice and second choice to be displayed in the printable page
  -- Sent by Nagaraju from HQ to be added to the API
  --------------------------------------------------------------------------------------------------
  */
  FUNCTION get_major(p_person_id             IN igs_ad_ps_appl_inst.person_id%TYPE,
                     p_admission_appl_number IN igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                     p_nominated_course_cd   IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                     p_sequence_number       IN igs_ad_ps_appl_inst.sequence_number%TYPE,
                     p_rank                  IN igs_ad_unit_sets.rank%TYPE)
    RETURN VARCHAR2 IS
    CURSOR cur_adm_unit_sets(p_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                p_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                p_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                p_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE, p_rank igs_ad_unit_sets.rank%TYPE) IS
      SELECT u.title
        FROM igs_ad_unit_sets us, igs_en_unit_set u
       WHERE us.person_id = p_person_id
         AND us.admission_appl_number = p_admission_appl_number
         AND us.nominated_course_cd = p_nominated_course_cd
         AND us.sequence_number = p_sequence_number
         AND us.rank = p_rank
         AND us.unit_set_cd = u.unit_set_cd
         AND us.version_number = u.version_number;

    l_title igs_en_unit_set.title%TYPE;

  BEGIN

    OPEN cur_adm_unit_sets(p_person_id,
                           p_admission_appl_number,
                           p_nominated_course_cd,
                           p_sequence_number,
                           p_rank);
    FETCH cur_adm_unit_sets
      INTO l_title;
    CLOSE cur_adm_unit_sets;
    RETURN(l_title);
  END get_major;

  FUNCTION DATESTR(P_START_DATE DATE, P_END_DATE DATE, P_COMP_DATE DATE)
    RETURN VARCHAR2 IS
    P_FINAL_STRING VARCHAR2(2000);
  BEGIN

    IF P_START_DATE IS NOT NULL AND P_END_DATE IS NOT NULL THEN
      P_FINAL_STRING := IGS_GE_DATE.IGSCHAR(P_START_DATE) || ' - ' ||
                        IGS_GE_DATE.IGSCHAR(P_END_DATE);
    END IF;

    IF P_START_DATE IS NULL AND P_END_DATE IS NULL THEN
      IF P_COMP_DATE IS NULL THEN
        P_FINAL_STRING := ' - ';
      ELSE
        P_FINAL_STRING := ' - ' || IGS_GE_DATE.IGSCHAR(P_COMP_DATE);
      END IF;
    END IF;

    IF P_START_DATE IS NULL AND P_END_DATE IS NOT NULL THEN
      P_FINAL_STRING := ' - ' || IGS_GE_DATE.IGSCHAR(P_END_DATE);
    END IF;

    IF P_START_DATE IS NOT NULL AND P_END_DATE IS NULL THEN
      IF P_COMP_DATE IS NULL THEN
        P_FINAL_STRING := IGS_GE_DATE.IGSCHAR(P_START_DATE) || ' - ';
      ELSE
        P_FINAL_STRING := IGS_GE_DATE.IGSCHAR(P_START_DATE) || ' - ' ||
                          IGS_GE_DATE.IGSCHAR(P_COMP_DATE);
      END IF;
    END IF;

    RETURN P_FINAL_STRING;

  END DATESTR;

  FUNCTION getAltid(x_party_id number) RETURN VARCHAR2 IS
    /*----------------------------------------------------------------------------
    ||  Created By : stammine
    ||  Created On : 01-Oct-2004
    ||  Purpose :  Procedure specially designed to get the Concatenated list of Alternate Ids
    ||             in the FindPerson Page
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
        askapoor        31-JAN-05      Modified Cursor c_altpid definition to include validation
                                       Sysdate between start_dt and end_dt

    ----------------------------------------------------------------------------*/

    l_altid VARCHAR2(1000);

    CURSOR c_altpid(cp_pe_person_id number) is
      SELECT api_person_id, person_id_type
        FROM igs_pe_alt_pers_id api
       WHERE api.pe_person_id = cp_pe_person_id
         AND Sysdate between api.start_dt and nvl(api.end_dt, sysdate);

  BEGIN

    l_altid := NULL;

    FOR cv_caltpid in c_altpid(x_party_id) LOOP
      IF l_altid IS NOT NULL THEN
        l_altid := l_altid || '<BR>' || cv_caltpid.person_id_type || ' : ' ||
                   cv_caltpid.api_person_id;
      ELSE
        l_altid := cv_caltpid.person_id_type || ' : ' ||
                   cv_caltpid.api_person_id;
      END IF;
    END LOOP;

    RETURN l_altid;
  END getAltid;

  FUNCTION getApplid(x_party_id number) RETURN VARCHAR2 IS
    /*----------------------------------------------------------------------------
    ||  Created By : stammine
    ||  Created On : 01-Oct-2004
    ||  Purpose :  Procedure specially designed to get the Concatenated list of Application Ids
    ||             in the FindPerson Page
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ----------------------------------------------------------------------------*/

    l_applid VARCHAR2(1000);

    CURSOR c_applid(cp_person_id number) IS
      SELECT application_id
        FROM igs_ad_appl a
       WHERE a.person_id = cp_person_id;

  BEGIN
    l_applid := NULL;

    FOR cv_applid in c_applid(x_party_id) LOOP
      IF l_applid IS NOT NULL THEN
        l_applid := l_applid || '<BR>' || cv_applid.application_id;
      ELSE
        l_applid := cv_applid.application_id;
      END IF;
    END LOOP;
    RETURN l_applid;
  END getApplid;


  /* Added by stammine IGS.M */
  -- Local Procedure
  -- Concats the list of Incomplete Required Components and Incomplete Optional Components
  PROCEDURE concat_req_comps(p_req_flag  IN VARCHAR2,
                             p_req_comps IN OUT NOCOPY VARCHAR2,
                             p_opt_comps IN OUT NOCOPY VARCHAR2,
                             p_comp_desc IN VARCHAR2) AS
  BEGIN
    IF p_req_flag = 'Y' THEN
      IF p_req_comps IS NULL THEN
        p_req_comps := p_comp_desc;
      ELSE
        p_req_comps := p_req_comps || ', ' || p_comp_desc;
      END IF;
    ELSE
      IF p_opt_comps IS NULL THEN
        p_opt_comps := p_comp_desc;
      ELSE
        p_opt_comps := p_opt_comps || ', ' || p_comp_desc;
      END IF;
    END IF;
  END concat_req_comps;

  /* Added procedure which will update the checklist w.r.t Application type configuration. */

  PROCEDURE update_appl_section_stat(p_person_id       IN NUMBER,
                                     p_adm_appl_number IN NUMBER,
                                     p_page_Name       IN VARCHAR2,
                                     p_Appl_Type       IN VARCHAR2,
                                     x_message_name    OUT NOCOPY VARCHAR2,
                                     x_return_status   OUT NOCOPY VARCHAR2,
                                     x_mand_incomplete OUT NOCOPY VARCHAR2) AS
    /*****************************************************************************************
    Created By: stammine
    Date Created : 10-Jun-2005
    Purpose: Procedure to update the Checklist Status as per application Type configuration for an Application
    Known limitations,enhancements,remarks:
    Change History
    Who        When          What
    *****************************************************************************************/

    -- Cursor for Each Component to check for existance of the respective record
    --Personal Details { Basic Information - BASIC_INFO, Address- ADDRESS, Phone- PHONE, Email- EMAIL, Identification- ALT_ID
    --Address Details  { Other Names- OTHER_NAMES, Biographic- BIOGRAPHIC, Special Needs- SPECIAL_NEEDS,Privacy- PRIVACY
    --Further Details  { Relationships- RELATIONSHIPS, Felony- FELONY, Housing Status- HOUSING_STATUS, Health- HEALTH_INFO}

    -- Residency and Citizenship {Country of Residence- COUNTRY_RESIDENCE, Citizenship- CITIZENSHIP,Language- LANGUAGE, Domicile- DOMICILE}

    -- International Details {Country of Citizenship- COUNTRY_CITIZENSHIP, Visa- VISA, Passport- PASSPORT, Financial Verification- FIN_VER}

    -- Application Details  {Program Preferences- PROGRAM_PREF, Program Preference Details- PROG_PREF_DTLS,
    --                       Desired Majors/Minors- DESIRED_UNITS, Educational Goals- EDUC_GOALS, Financial Aid- FIN_AID}

    -- Education {High School- SECONDARY, College/University- POST_SECONDARY, Admission Test Results- ADM_TEST_RESULTS,
    --             Qualification Details- QUALIFICATION, Academic Honors- ACAD_HONORS}

    -- Supporting Information {Personal Statements- PERSONAL_STMTS, Supporting Information- SUPPORTING_INFO,
    --     Other Institutions Applied- OTHER_INST, Academic Interest- ACAD_INTEREST, Special Talents- SPECIAL_TALENTS,
    --     Extracurricular Activities- EXTRACUR_ACTIVITIES, Employment History- EMPLOYMENT_HIST}

    -- Basic Information - BASIC_INFO
    -- No validation

    -- Address - ADDRESS
    CURSOR c_addr(cp_person_id igs_ad_appl.person_id%TYPE, cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_ADDR_V addr, IGS_PE_PARTYSITEUSE_V use
       WHERE addr.PERSON_ID = cp_person_id
         AND addr.STATUS = 'A'
                 AND addr.party_site_id = use.party_site_id
                 AND use.site_use_type IN
                 (SELECT SS_Lookup_code
                FROM igs_ad_ss_lookups
               WHERE ss_lookup_type = 'SITE_USE_CODE'
                 AND admission_application_type = cp_ApplType
                 AND Closed_flag <>  'Y');

    -- Phone - PHONE
    CURSOR c_phone(cp_person_id igs_ad_appl.person_id%TYPE, cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
      SELECT 'x'
        FROM hz_contact_points
       WHERE CONTACT_POINT_TYPE = 'PHONE'
         AND OWNER_TABLE_NAME = 'HZ_PARTIES'
         AND STATUS = 'A'
         AND PHONE_LINE_TYPE IN
             (SELECT SS_Lookup_code
                FROM igs_ad_ss_lookups
               WHERE ss_lookup_type = 'PHONE_LINE_TYPE'
                 AND admission_application_type = cp_ApplType
                 AND Closed_flag <>  'Y')
         AND OWNER_TABLE_ID = cp_person_id;

    -- Email- EMAIL
    CURSOR c_email(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM hz_contact_points
       WHERE CONTACT_POINT_TYPE = 'EMAIL'
         AND OWNER_TABLE_NAME = 'HZ_PARTIES'
         AND STATUS = 'A'
         AND OWNER_TABLE_ID = cp_person_id;

    -- Identification- ALT_ID
    CURSOR c_altId(cp_person_id igs_ad_appl.person_id%TYPE, cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_ALT_PERS_ID
       WHERE PE_PERSON_ID = cp_person_id
         AND PERSON_ID_TYPE IN
             (SELECT SS_Lookup_code
                FROM igs_ad_ss_lookups
               WHERE ss_lookup_type = 'PERSON_ID_TYPE'
                 AND admission_application_type = cp_ApplType
                 AND Closed_flag <>  'Y')
        AND (END_DT IS NULL OR START_DT <> END_DT);

    -- Other Names- OTHER_NAMES
    CURSOR c_other_Names(cp_person_id igs_ad_appl.person_id%TYPE, cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_PERSON_ALIAS_V pon
       WHERE pon.PERSON_ID = cp_person_id
         AND ALIAS_TYPE IN
             (SELECT SS_Lookup_code
                FROM igs_ad_ss_lookups
               WHERE ss_lookup_type = 'PE_ALIAS_TYPE'
                 AND admission_application_type = cp_ApplType
                 AND Closed_flag <>  'Y');
  -- Ask PM for Date Check

    -- Biographic- BIOGRAPHIC
    -- check only in IGS_PE_RACE
   CURSOR c_race (cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_RACE race
       WHERE race.PERSON_ID = cp_person_id;

    -- Special Needs- SPECIAL_NEEDS
    CURSOR c_spl_Needs(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM IGS_PE_PERS_DISABLTY WHERE person_id = cp_person_id
         AND SYSDATE <= NVL(END_DATE,SYSDATE);

    -- Privacy- PRIVACY
    CURSOR c_privacy(cp_person_id igs_ad_appl.person_id%TYPE, cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_PRIV_LEVEL priv
       WHERE PERSON_ID = cp_person_id
         AND to_char(DATA_GROUP_ID) IN
             (SELECT SS_Lookup_code
                FROM igs_ad_ss_lookups
               WHERE ss_lookup_type = 'PRIVACY_PREF_DATA_GROUP'
                 AND admission_application_type = cp_ApplType
                 AND Closed_flag <>  'Y');

    -- Relationships- RELATIONSHIPS
    CURSOR c_relations(cp_person_id igs_ad_appl.person_id%TYPE, cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_HZ_REL_V rel
       WHERE rel.SUBJECT_ID = cp_person_id
         AND rel.SUBJECT_TYPE = 'PERSON'
         AND rel.OBJECT_TYPE = 'PERSON'
         AND rel.STATUS = 'A'
         AND SYSDATE BETWEEN rel.START_DATE AND NVL(rel.END_DATE, SYSDATE)
         AND  RELATIONSHIP_CODE IN
             (SELECT SS_Lookup_code
                FROM igs_ad_ss_lookups
               WHERE ss_lookup_type = 'PARTY_RELATIONS_TYPE'
                 AND admission_application_type = cp_ApplType
                 AND Closed_flag <>  'Y');

    -- Felony- FELONY
    CURSOR c_felony(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT FELONY_CONVICTED_FLAG
        FROM IGS_PE_HZ_PARTIES
       WHERE PARTY_ID = cp_person_id;

    -- Housing Status- HOUSING_STATUS
    CURSOR c_housing(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_TEACH_PERIODS_ALL
       WHERE person_id = cp_person_id;

    -- Health- HEALTH_INFO
    -- Health Insurance
    CURSOR c_health_insu(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM IGS_PE_HLTH_INS_ALL
      WHERE person_id = cp_person_id
      AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);

     -- Immunization
    CURSOR c_health_immu(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM IGS_PE_IMMU_DTLS WHERE person_id = cp_person_id
      AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);

    -- Applicant Citizenship- CITIZENSHIP
    -- None Dynamic Behaviour

    -- Country of Residence- COUNTRY_RESIDENCE
    CURSOR c_residence(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_EIT T
       WHERE T.INFORMATION_TYPE = 'PE_STAT_RES_COUNTRY'
         AND Person_id = cp_person_id;

    -- Language- LANGUAGE
    CURSOR c_lang(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM HZ_PERSON_LANGUAGE lang
       WHERE PARTY_ID = cp_person_id
         AND STATUS = 'A';

    -- Domicile- DOMICILE
    -- State of Residence
    CURSOR c_sor(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_EIT
       WHERE INFORMATION_TYPE = 'PE_STAT_RES_STATE'
         AND Person_id = cp_person_id;

    -- Voter Info
    CURSOR c_vinfo(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM IGS_PE_VOTE_INFO_ALL WHERE Person_id = cp_person_id;

    -- Income Tax
    CURSOR c_itax(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM IGS_PE_INCOME_TAX_ALL WHERE Person_id = cp_person_id;

    -- Military Service
    CURSOR c_military(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM IGS_PE_MIL_SERVICES_ALL WHERE Person_id = cp_person_id;

    -- Country of Citizenship- COUNTRY_CITIZENSHIP
    CURSOR c_citizenship(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM HZ_CITIZENSHIP cz
       WHERE cz.PARTY_ID = cp_person_id
         AND cz.STATUS = 'A';

    -- Visa- VISA
    CURSOR c_visa(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_VISIT_HISTRY_V visa
       WHERE visa.PERSON_ID = cp_person_id;

    -- Passport- PASSPORT
    CURSOR c_passport(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_PASSPORT pport
       WHERE pport.PERSON_ID = cp_person_id;

    -- Financial Verification- FIN_VER
    -- None

    -- Program Preferences- PROGRAM_PREF
    CURSOR c_prog_pref(cp_adm_appl_number IGS_SS_APP_PGM_STG.ss_adm_appl_id%TYPE) IS
      SELECT SS_ADMAPPL_PGM_ID, ATTENDANCE_TYPE,
             ATTENDANCE_MODE,
             NOMINATED_COURSE_CD
        FROM IGS_SS_APP_PGM_STG
       WHERE ss_adm_appl_id = cp_adm_appl_number;

    -- Program Preference Details- PROG_PREF_DTLS
    CURSOR c_prog_dtls(cp_adm_appl_number IGS_SS_APP_PGM_STG.ss_adm_appl_id%TYPE) IS
      SELECT SS_ADMAPPL_PGM_ID,
             ENTRY_STATUS,
             ENTRY_LEVEL,
             FINAL_UNIT_SET_CD,
             NOMINATED_COURSE_CD,
             SCH_APL_TO_ID
        FROM IGS_SS_APP_PGM_STG
       WHERE ss_adm_appl_id = cp_adm_appl_number;

    -- Desired Majors/Minors- DESIRED_UNITS
    CURSOR c_dunits(cp_ss_admappl_pgm igs_ss_ad_unitse_stg.ss_admappl_pgm_id%TYPE) IS
      SELECT 'x'
        FROM IGS_SS_AD_UNITSE_STG
       WHERE ss_admappl_pgm_id = cp_ss_admappl_pgm;

    -- Educational Goals- EDUC_GOALS
    CURSOR c_educ_goals(cp_ss_admappl_pgm igs_ss_ad_unitse_stg.ss_admappl_pgm_id%TYPE) IS
      SELECT 'x'
        FROM IGS_SS_AD_EDUGOA_STG
       WHERE ss_admappl_pgm_id = cp_ss_admappl_pgm;

    -- Financial Aid- FIN_AID
    CURSOR c_fin_aid(cp_adm_appl_number IGS_SS_APP_PGM_STG.ss_adm_appl_id%TYPE) IS
      SELECT APPLY_FOR_FINAID, FINAID_APPLY_DATE
        FROM IGS_SS_APP_PGM_STG
       WHERE ss_adm_appl_id = cp_adm_appl_number;

    -- High School- SECONDARY
    CURSOR c_sec(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM HZ_EDUCATION HE
       WHERE HE.PARTY_ID = cp_person_id
         AND HE.STATUS = 'A'
         AND EXISTS (SELECT 'X'
		     FROM IGS_OR_ORG_INST_TYPE_ALL
		     WHERE INSTITUTION_TYPE = DECODE (HE.SCHOOL_PARTY_ID, NULL, NULL,
		     (SELECT OI_INSTITUTION_TYPE
		      FROM IGS_PE_HZ_PARTIES
		      WHERE HE.SCHOOL_PARTY_ID = PARTY_ID
			    AND INST_ORG_IND = 'I'
		     )
		    )
	AND SYSTEM_INST_TYPE = 'SECONDARY');

    -- College/University- POST_SECONDARY
    CURSOR c_post_sec(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
        FROM HZ_EDUCATION HE
       WHERE HE.PARTY_ID = cp_person_id
         AND HE.STATUS = 'A'
         AND EXISTS (SELECT 'X'
			FROM IGS_OR_ORG_INST_TYPE_ALL
			WHERE INSTITUTION_TYPE = DECODE (HE.SCHOOL_PARTY_ID, NULL, NULL, (SELECT OI_INSTITUTION_TYPE
			FROM IGS_PE_HZ_PARTIES
			WHERE HE.SCHOOL_PARTY_ID = PARTY_ID
			AND INST_ORG_IND = 'I') )
			AND SYSTEM_INST_TYPE IN ('POST-SECONDARY', 'OTHER')
		    );

    -- Local College/University
    CURSOR c_local_post_sec(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x'
       FROM igs_en_stdnt_ps_att_all psattmpt
      WHERE psattmpt.person_id = cp_person_id
        AND psattmpt.course_attempt_status <> 'UNCONFIRM'
        AND((NVL(fnd_profile.VALUE('CAREER_MODEL_ENABLED'), 'N') = 'N')
	     OR(fnd_profile.VALUE('CAREER_MODEL_ENABLED') = 'Y' AND psattmpt.primary_program_type = 'PRIMARY'));


    -- Admission Test Results- ADM_TEST_RESULTS
    CURSOR c_test_rslts(cp_person_id igs_ad_appl.person_id%TYPE, cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
      SELECT 'x'
        FROM IGS_AD_TEST_RESULTS
       WHERE PERSON_ID = cp_person_id
         AND ADMISSION_TEST_TYPE IN
             (SELECT SS_Lookup_code
                FROM igs_ad_ss_lookups
               WHERE ss_lookup_type = 'ADMISSION_TEST_TYPE'
                 AND admission_application_type = cp_ApplType
                 AND Closed_flag <>  'Y');

    -- Qualification Details- QUALIFICATION
    CURSOR c_qual(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM IGS_UC_QUAL_DETS WHERE person_id = cp_person_id;

    -- Academic Honors- ACAD_HONORS
    CURSOR c_acad_hon(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM IGS_PE_ACAD_HONORS WHERE person_id = cp_person_id;

    -- Personal Statements- PERSONAL_STMTS
    -- Cursors c_perstat and c_perstat_group added by abhiskum
    CURSOR c_perstat(cp_person_id igs_ad_appl.person_id%TYPE,
                         cp_adm_appl_number IGS_SS_APP_PGM_STG.ss_adm_appl_id%TYPE,
                         cp_group_number IGS_AD_APTYP_PESTAT.group_number%TYPE) IS
        SELECT stg.persl_stat_type statement,
           DECODE(NVL(mandatory,'N'),'N','No','Yes') required,
           group_number,
           stg.SS_PERSTAT_ID SS_PERSTAT_ID,
           stg.attach_exists
        FROM  IGS_SS_APPL_PERSTAT stg,
             IGS_AD_APTYP_PESTAT  aptypperstat
        WHERE   stg.persl_Stat_type = aptypperstat.persl_Stat_type
        AND stg.admission_application_type = aptypperstat.admission_application_type
        AND stg.ss_Adm_appl_id = cp_adm_appl_number
        AND stg.PERSON_ID = cp_person_id
        AND group_number = cp_group_number ;

    CURSOR c_perstat_group(cp_person_id igs_ad_appl.person_id%TYPE,
                               cp_adm_appl_number IGS_SS_APP_PGM_STG.ss_adm_appl_id%TYPE,
                               cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
        SELECT
           group_name  statement,
           DECODE(NVL(group_required_flag,'N'),'N','No','Yes') required,
           group_number ,
           0 SS_PERSTAT_ID,
           null attach_exists,
           group_min
        FROM IGS_AD_PESTAT_GROUP
        WHERE group_number IN
          (SELECT distinct group_number FROM IGS_SS_APPL_PERSTAT stg, IGS_AD_APTYP_PESTAT setup
          WHERE setup.persl_Stat_type = stg.persl_Stat_type
          AND setup.admission_application_type = stg.admission_application_type
          AND stg.ss_Adm_appl_id = cp_adm_appl_number AND stg.PERSON_ID = cp_person_id )
        AND admission_application_type  = cp_ApplType
        AND NVL(GROUP_REQUIRED_FLAG,'N') = 'Y'
        UNION ALL
        SELECT
           stg.persl_stat_type statement,
           DECODE(NVL(mandatory,'N'),'N','No','Yes') required,
           -1 group_number,
           stg.SS_PERSTAT_ID SS_PERSTAT_ID,
           stg.attach_exists,
           0 group_min
        FROM  IGS_SS_APPL_PERSTAT stg,
             IGS_AD_APTYP_PESTAT  aptypperstat
        WHERE   stg.persl_Stat_type = aptypperstat.persl_Stat_type
        AND stg.admission_application_type = aptypperstat.admission_application_type
        AND group_number IS NULL
        AND stg.ss_Adm_appl_id = cp_adm_appl_number
        AND stg.PERSON_ID = cp_person_id ;

    -- Supporting Information- SUPPORTING_INFO
    CURSOR c_supp_info(cp_person_id igs_ad_appl.person_id%TYPE, cp_ApplType igs_ad_appl.APPLICATION_TYPE%TYPE) IS
      SELECT 'x'
        FROM IGS_PE_CREDENTIALS
       WHERE person_id = cp_person_id
         AND to_char(CREDENTIAL_TYPE_ID) IN
             (SELECT SS_Lookup_code
                FROM igs_ad_ss_lookups
               WHERE ss_lookup_type = 'CREDENTIAL_TYPE'
                 AND admission_application_type = cp_ApplType
                 AND Closed_flag <>  'Y');

    -- Other Institutions Applied- OTHER_INST
    CURSOR c_oth_inst(cp_Appl_Num IGS_SS_AD_OTHINS_STG.SS_ADM_APPL_ID%TYPE) IS
      SELECT 'x'
        FROM IGS_SS_AD_OTHINS_STG
       WHERE SS_ADM_APPL_ID = cp_Appl_Num;

    -- Academic Interest- ACAD_INTEREST
    CURSOR c_acad_int(cp_Appl_Num IGS_SS_AD_ACADIN_STG.SS_ADM_APPL_ID%TYPE) IS
      SELECT 'x'
        FROM IGS_SS_AD_ACADIN_STG
       WHERE SS_ADM_APPL_ID = cp_Appl_Num;

    -- Special Talents- SPECIAL_TALENTS
    CURSOR c_spl_tal(cp_Appl_Num IGS_SS_AD_SPLTAL_STG.SS_ADM_APPL_ID%TYPE) IS
      SELECT 'x'
        FROM IGS_SS_AD_SPLTAL_STG
       WHERE SS_ADM_APPL_ID = cp_Appl_Num;

    -- Extracurricular Activities- EXTRACUR_ACTIVITIES
    CURSOR c_ext_curr(cp_person_id igs_ad_appl.person_id%TYPE) IS
    SELECT 'x'
	FROM HZ_PERSON_INTEREST PI, IGS_AD_HZ_EXTRACURR_ACT HEA
	WHERE PI.PERSON_INTEREST_ID = HEA.PERSON_INTEREST_ID
	AND PI.PARTY_ID = cp_person_id;

    -- Employment History- EMPLOYMENT_HIST
    CURSOR c_emp_hist(cp_person_id igs_ad_appl.person_id%TYPE) IS
      SELECT 'x' FROM HZ_EMPLOYMENT_HISTORY WHERE party_id = cp_person_id;

    -- Cursor for selecting components for a given page.
    CURSOR c_pgcomps(cp_Appl_Type IGS_AD_SS_APPL_COMPS.Admission_application_type%TYPE, cp_page_Name IGS_AD_SS_APPL_COMPS.page_name%TYPE) IS
      SELECT Admission_application_type ApplType,
             page_name PageName,
             component_code Component,
             comp_disp_name ComponentDesc,
             required_flag
        FROM IGS_AD_SS_APPL_COMPS
       WHERE Admission_application_type = cp_Appl_Type
         AND page_name = cp_page_Name
         AND include_flag = 'Y';

    -- Cursor to check whether AppType has required components for a given page.
    CURSOR c_req_comps_exist(cp_Appl_Type IGS_AD_SS_APPL_COMPS.Admission_application_type%TYPE, cp_page_Name IGS_AD_SS_APPL_COMPS.page_name%TYPE) IS
      SELECT 'x'
        FROM IGS_AD_SS_APPL_COMPS
       WHERE Admission_application_type = cp_Appl_Type
         AND page_name = cp_page_Name
         AND include_flag = 'Y'
         AND required_flag = 'Y';


    lv_temp_rec       VARCHAR2(10);
    c_felony_rec      c_felony%ROWTYPE;
    c_prog_pref_rec   c_prog_pref%ROWTYPE;
    c_prog_dtls_rec   c_prog_dtls%ROWTYPE;

    c_fin_aid_rec     c_fin_aid%ROWTYPE;

    -- l_perstat_group_rec,l_perstat_rec,l_flag and l_perstat_count added by abhiskum
    -- for Personal Statements Validation
    l_perstat_group_rec c_perstat_group%ROWTYPE := NULL;
    l_perstat_rec c_perstat%ROWTYPE := NULL;
    l_flag VARCHAR2(1) := 'Y';
    l_perstat_count NUMBER;

    c_pgcomps_rec         c_pgcomps%ROWTYPE;
    c_req_comps_exist_rec c_req_comps_exist%ROWTYPE;
    l_comp_status         VARCHAR2(30);
    l_req_comps           VARCHAR2(2000);
    l_opt_comps           VARCHAR2(2000);
    finaidrecordfound  VARCHAR2(1);
    progpreffound      VARCHAR2(1);

    l_prog_label  VARCHAR2(100);
    l_label  VARCHAR2(500);
    l_debug_str VARCHAR2(4000);


  BEGIN

    l_prog_label := 'igs.plsql.igs_ad_ss_gen_001.update_appl_section_stat';
    l_label      := 'igs.plsql.igs_ad_ss_gen_001.update_appl_section_stat.start';


    -- Status Flag = Optional
    -- String Required_componets =  Null
    -- Open the cursor for the Included components list
    -- Loop thru the cursor and Concatenate the component_display name to Require_Componnents if the component doesn't have the record
    -- If the Required_components string is not null then Update the Checklist record with In-Progress Status and return the Required_Components String.
    -- If the Required_components string is null then Update the Checklist record with Completed Status and return Null.
    -- If there are no requied components in the given page Update the Checklist record with Optional Status and return Null.

    l_req_comps     := null;
    l_opt_comps     := null;
    x_return_status := 'S';


     FOR pgComps IN c_pgcomps(p_Appl_Type, p_page_Name)
     LOOP
      IF pgComps.Component = 'ADDRESS' THEN
             OPEN c_addr(p_person_id, p_Appl_Type);
             FETCH c_addr INTO lv_temp_rec;
             IF c_addr%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_addr%ISOPEN THEN
                CLOSE c_addr;
             END IF;

       ELSIF pgComps.Component = 'PHONE' THEN
             OPEN c_phone(p_person_id, p_Appl_Type);
             FETCH c_phone INTO lv_temp_rec;
             IF c_phone%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_phone%ISOPEN THEN
                CLOSE c_phone;
             END IF;

       ELSIF pgComps.Component = 'EMAIL' THEN
             OPEN c_email(p_person_id);
             FETCH c_email INTO lv_temp_rec;
             IF c_email%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_email%ISOPEN THEN
                CLOSE c_email;
             END IF;

       ELSIF pgComps.Component = 'ALT_ID' THEN
             OPEN c_altId(p_person_id, p_Appl_Type);
             FETCH c_altId INTO lv_temp_rec;
             IF c_altId%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_altId%ISOPEN THEN
                CLOSE c_altId;
             END IF;

       ELSIF pgComps.Component = 'OTHER_NAMES' THEN
             OPEN c_other_Names(p_person_id, p_Appl_Type);
             FETCH c_other_Names INTO lv_temp_rec;
             IF c_other_Names%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_other_Names%ISOPEN THEN
                CLOSE c_other_Names;
             END IF;

       ELSIF pgComps.Component = 'BIOGRAPHIC' THEN
             OPEN c_race(p_person_id);
             FETCH c_race INTO lv_temp_rec;
             IF c_race%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_race%ISOPEN THEN
                CLOSE c_race;
             END IF;

       ELSIF pgComps.Component = 'SPECIAL_NEEDS' THEN
             OPEN c_spl_Needs(p_person_id);
             FETCH c_spl_Needs INTO lv_temp_rec;
             IF c_spl_Needs%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_spl_Needs%ISOPEN THEN
                CLOSE c_spl_Needs;
             END IF;

       ELSIF pgComps.Component = 'PRIVACY' THEN
             OPEN c_privacy(p_person_id, p_Appl_Type);
             FETCH c_privacy INTO lv_temp_rec;
             IF c_privacy%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_privacy%ISOPEN THEN
                CLOSE c_privacy;
             END IF;

       ELSIF pgComps.Component = 'RELATIONSHIPS' THEN
             OPEN c_relations(p_person_id, p_Appl_Type);
             FETCH c_relations INTO lv_temp_rec;
             IF c_relations%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_relations%ISOPEN THEN
                CLOSE c_relations;
             END IF;

       ELSIF pgComps.Component = 'FELONY' THEN
             OPEN c_felony(p_person_id);
             FETCH c_felony INTO c_felony_rec;
             IF c_felony%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             ELSIF c_felony_rec.FELONY_CONVICTED_FLAG IS NULL THEN
                concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_felony%ISOPEN THEN
                CLOSE c_felony;
             END IF;

       ELSIF pgComps.Component = 'HOUSING_STATUS' THEN
             OPEN c_housing(p_person_id);
             FETCH c_housing INTO lv_temp_rec;
             IF c_housing%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_housing%ISOPEN THEN
                CLOSE c_housing;
             END IF;

       ELSIF pgComps.Component = 'HEALTH_INSU' THEN
             OPEN c_health_insu(p_person_id);
             FETCH c_health_insu INTO lv_temp_rec;
             IF c_health_insu%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_health_insu%ISOPEN THEN
                CLOSE c_health_insu;
             END IF;

       ELSIF pgComps.Component = 'HEALTH_IMMU' THEN
             OPEN c_health_immu(p_person_id);
             FETCH c_health_immu INTO lv_temp_rec;
             IF c_health_immu%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_health_immu%ISOPEN THEN
                CLOSE c_health_immu;
             END IF;

       ELSIF pgComps.Component = 'COUNTRY_RESIDENCE' THEN
             OPEN c_residence(p_person_id);
             FETCH c_residence INTO lv_temp_rec;
             IF c_residence%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_residence%ISOPEN THEN
                CLOSE c_residence;
             END IF;

       ELSIF pgComps.Component = 'LANGUAGE' THEN
             OPEN c_lang(p_person_id);
             FETCH c_lang INTO lv_temp_rec;
             IF c_lang%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_lang%ISOPEN THEN
                CLOSE c_lang;
             END IF;

       ELSIF pgComps.Component = 'STATE_RESI' THEN
             OPEN c_sor(p_person_id);
             FETCH c_sor INTO lv_temp_rec;
             IF c_sor%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_sor%ISOPEN THEN
                CLOSE c_sor;
             END IF;

       ELSIF pgComps.Component = 'VOTER_INFO' THEN
             OPEN c_vinfo(p_person_id);
             FETCH c_vinfo INTO lv_temp_rec;
             IF c_vinfo%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_vinfo%ISOPEN THEN
                CLOSE c_vinfo;
             END IF;

       ELSIF pgComps.Component = 'INCOME_TAX' THEN
             OPEN c_itax(p_person_id);
             FETCH c_itax INTO lv_temp_rec;
             IF c_itax%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_itax%ISOPEN THEN
                CLOSE c_itax;
             END IF;

      /* ELSIF pgComps.Component = 'MILITARY' THEN
             OPEN c_military(p_person_id);
             FETCH c_military INTO lv_temp_rec;
             IF c_military%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_military%ISOPEN THEN
                CLOSE c_military;
             END IF; */

       ELSIF pgComps.Component IN  ('COUNTRY_CITIZENSHIP','CITIZENSHIP') THEN
             OPEN c_citizenship(p_person_id);
             FETCH c_citizenship INTO lv_temp_rec;
             IF c_citizenship%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_citizenship%ISOPEN THEN
                CLOSE c_citizenship;
             END IF;

       ELSIF pgComps.Component = 'VISA' THEN
             OPEN c_visa(p_person_id);
             FETCH c_visa INTO lv_temp_rec;
             IF c_visa%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_visa%ISOPEN THEN
                CLOSE c_visa;
             END IF;

       ELSIF pgComps.Component = 'PASSPORT' THEN
             OPEN c_passport(p_person_id);
             FETCH c_passport INTO lv_temp_rec;
             IF c_passport%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_passport%ISOPEN THEN
                CLOSE c_passport;
             END IF;

       -- ELSIF pgComps.Component = 'FIN_VER' THEN
       -- None

       ELSIF pgComps.Component = 'PROGRAM_PREF' THEN
             OPEN c_prog_pref(p_adm_appl_number);
             FETCH c_prog_pref INTO c_prog_pref_rec;
             IF c_prog_pref%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_prog_pref%ISOPEN THEN
                CLOSE c_prog_pref;
             END IF;

    /*   ELSIF pgComps.Component = 'PROG_PREF_DTLS' THEN
             OPEN c_prog_dtls(p_adm_appl_number);
             FETCH c_prog_dtls INTO c_prog_dtls_rec;
             IF c_prog_dtls%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_prog_dtls%ISOPEN THEN
                CLOSE c_prog_dtls;
             END IF;
      */

       ELSIF pgComps.Component = 'DESIRED_UNITS' THEN
             progpreffound := 'N' ;
             FOR c_prog_pref_rec_desus IN c_prog_pref(p_adm_appl_number) LOOP
               progpreffound := 'Y';
               OPEN c_dunits(c_prog_pref_rec_desus.ss_admappl_pgm_id);
               FETCH c_dunits INTO lv_temp_rec;
                 IF c_dunits%NOTFOUND THEN
                   concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
                   CLOSE c_dunits;
                   EXIT;
                 END IF;
               IF c_dunits%ISOPEN THEN
                 CLOSE c_dunits;
               END IF;
               IF progpreffound = 'N' THEN
                   concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
               END IF;
             END LOOP;



       ELSIF pgComps.Component = 'EDUC_GOALS' THEN
             progpreffound := 'N' ;
             FOR c_prog_pref_rec_deedu IN c_prog_pref(p_adm_appl_number) LOOP
               progpreffound := 'Y';
               OPEN c_educ_goals(c_prog_pref_rec_deedu.ss_admappl_pgm_id);
               FETCH c_educ_goals INTO lv_temp_rec;
                 IF c_educ_goals%NOTFOUND THEN
                   concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
                   CLOSE c_educ_goals;
                   EXIT;
                 END IF;
               IF c_educ_goals%ISOPEN THEN
                 CLOSE c_educ_goals;
               END IF;
               IF progpreffound = 'N' THEN
                   concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
               END IF;
             END LOOP;

       ELSIF pgComps.Component = 'FIN_AID' THEN
             finaidrecordfound := 'N';
             FOR c_fin_aid_rec IN c_fin_aid(p_adm_appl_number) LOOP
               finaidrecordfound := 'Y';
                IF c_fin_aid_rec.apply_for_finaid IS NULL THEN
                  finaidrecordfound := 'N';
                  EXIT;
                END IF;
             END LOOP;

             IF finaidrecordfound ='N' THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;


       ELSIF pgComps.Component = 'SECONDARY' THEN
             OPEN c_sec(p_person_id);
             FETCH c_sec INTO lv_temp_rec;
             IF c_sec%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_sec%ISOPEN THEN
                CLOSE c_sec;
             END IF;

       ELSIF pgComps.Component = 'POST_SECONDARY' THEN
             OPEN c_post_sec(p_person_id);
             FETCH c_post_sec INTO lv_temp_rec;
             IF c_post_sec%NOTFOUND THEN
	        -- Check for program attempt in local institution.
	        OPEN c_local_post_sec(p_person_id);
                FETCH c_local_post_sec INTO lv_temp_rec;
                IF c_local_post_sec%NOTFOUND THEN
                    concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
                END IF;
                IF c_local_post_sec%ISOPEN THEN
                   CLOSE c_local_post_sec;
                END IF;
             END IF;
             IF c_post_sec%ISOPEN THEN
                CLOSE c_post_sec;
             END IF;

       ELSIF pgComps.Component = 'ADM_TEST_RESULTS' THEN
             OPEN c_test_rslts(p_person_id, p_Appl_Type);
             FETCH c_test_rslts INTO lv_temp_rec;
             IF c_test_rslts%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_test_rslts%ISOPEN THEN
                CLOSE c_test_rslts;
             END IF;

       ELSIF pgComps.Component = 'QUALIFICATION' THEN
             OPEN c_qual(p_person_id);
             FETCH c_qual INTO lv_temp_rec;
             IF c_qual%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_qual%ISOPEN THEN
                CLOSE c_qual;
             END IF;

       ELSIF pgComps.Component = 'ACAD_HONORS' THEN
             OPEN c_acad_hon(p_person_id);
             FETCH c_acad_hon INTO lv_temp_rec;
             IF c_acad_hon%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_acad_hon%ISOPEN THEN
                CLOSE c_acad_hon;
             END IF;

      ELSIF pgComps.Component = 'PERSONAL_STMTS' THEN
                IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                    l_debug_str := ' Validating Personal Statements Component';
                     fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                END IF;

                OPEN c_perstat_group(p_person_id,p_adm_appl_number,p_Appl_Type);
                LOOP
                      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                         l_debug_str := 'In c_perstat_group with p_person_id ->' || p_person_id || ',  p_adm_appl_number -> ' ||
                         p_adm_appl_number || ',   p_Appl_Type   -> ' || p_Appl_Type;
                         fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                      END IF;

                      FETCH c_perstat_group INTO l_perstat_group_rec;
                      EXIT WHEN c_perstat_group%NOTFOUND;
                      IF l_perstat_group_rec.group_number = -1 THEN

                        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                           l_debug_str := ' Personal Satement is not associated to Group with ss perstat id -> ' || l_perstat_group_rec.SS_PERSTAT_ID;
                           fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                        END IF;

                        IF (l_perstat_group_rec.required = 'Yes' AND l_perstat_group_rec.attach_exists = 'N') THEN
                                IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                                   l_debug_str := ' Personal Satement is Required but not provided -> ' ;
                                   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                                END IF;
                                l_flag := 'N';
                        END IF;
                      ELSE
                        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                           l_debug_str := ' Personal Satement Group ->   ' || l_perstat_group_rec.group_number;
                           fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                        END IF;

                        l_perstat_count := 0;
                        OPEN c_perstat(p_person_id,p_adm_appl_number,l_perstat_group_rec.group_number);
                        LOOP

                                FETCH c_perstat INTO l_perstat_rec;
                                EXIT WHEN c_perstat%NOTFOUND;

                                IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                                   l_debug_str := ' Personal Satements ID ->   ' || l_perstat_rec.SS_PERSTAT_ID ||
                                   'Presnt Count of statments for this group' ||  l_perstat_count;
                                   fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                                END IF;

                                IF (l_perstat_rec.attach_exists = 'Y') THEN
                                        l_perstat_count := l_perstat_count + 1;
                                ELSE
                                        IF l_perstat_rec.required = 'Yes'THEN
                                                l_flag := 'N';
                                        END IF;
                                END IF;
                        END LOOP;
                        CLOSE c_perstat;

                        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                           l_debug_str := ' Personal Satements count for  Group ->   ' || l_perstat_group_rec.group_number ||'  is  ' || l_perstat_count;
                           fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
                        END IF;

                        IF l_perstat_count < l_perstat_group_rec.group_min  THEN
                                l_flag := 'N';
                        END IF;
                      END IF;
                END LOOP;
                CLOSE c_perstat_group;

                IF l_flag = 'N' THEN
                    concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
                END IF;

       ELSIF pgComps.Component = 'SUPPORTING_INFO' THEN
             OPEN c_supp_info(p_person_id, p_Appl_Type);
             FETCH c_supp_info INTO lv_temp_rec;
             IF c_supp_info%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_supp_info%ISOPEN THEN
                CLOSE c_supp_info;
             END IF;

       ELSIF pgComps.Component = 'OTHER_INST' THEN
             OPEN c_oth_inst(p_adm_appl_number);
             FETCH c_oth_inst INTO lv_temp_rec;
             IF c_oth_inst%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_oth_inst%ISOPEN THEN
                CLOSE c_oth_inst;
             END IF;

       ELSIF pgComps.Component = 'ACAD_INTEREST' THEN
             OPEN c_acad_int(p_adm_appl_number);
             FETCH c_acad_int INTO lv_temp_rec;
             IF c_acad_int%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_acad_int%ISOPEN THEN
                CLOSE c_acad_int;
             END IF;

       ELSIF pgComps.Component = 'SPECIAL_TALENTS' THEN
             OPEN c_spl_tal(p_adm_appl_number);
             FETCH c_spl_tal INTO lv_temp_rec;
             IF c_spl_tal%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_spl_tal%ISOPEN THEN
                CLOSE c_spl_tal;
             END IF;

       ELSIF pgComps.Component = 'EXTRACUR_ACTIVITIES' THEN
             OPEN c_ext_curr(p_person_id);
             FETCH c_ext_curr INTO lv_temp_rec;
             IF c_ext_curr%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_ext_curr%ISOPEN THEN
                CLOSE c_ext_curr;
             END IF;

       ELSIF pgComps.Component = 'EMPLOYMENT_HIST' THEN
             OPEN c_emp_hist(p_person_id);
             FETCH c_emp_hist INTO lv_temp_rec;
             IF c_emp_hist%NOTFOUND THEN
               concat_req_comps(pgComps.required_flag, l_req_comps, l_opt_comps, pgComps.ComponentDesc);
             END IF;
             IF c_emp_hist%ISOPEN THEN
                CLOSE c_emp_hist;
             END IF;

       END IF;
     END LOOP;

     IF l_req_comps IS NOT NULL THEN
       l_comp_status:='INPROGRESS';
     ELSIF l_opt_comps IS NULL THEN
       l_comp_status:='COMPLETE';
     ELSE
        OPEN c_req_comps_exist(p_Appl_Type, p_page_Name);
        FETCH c_req_comps_exist INTO c_req_comps_exist_rec;
        IF c_req_comps_exist%NOTFOUND THEN
           l_comp_status:='OPTIONAL';
        ELSE
           l_comp_status:='COMPLETE';
        END IF;
     END IF;

      UPDATE  IGS_SS_AD_SEC_STAT
        SET COMPLETION_STATUS = l_comp_status
      WHERE  SS_ADM_APPL_ID = p_adm_appl_number
       AND PERSON_ID = p_person_id
       AND  SECTION = p_page_Name;

       x_mand_incomplete := l_req_comps;

     EXCEPTION
     WHEN OTHERS THEN
      IF c_perstat_group%ISOPEN THEN
        CLOSE c_perstat_group;
      END IF;
      IF c_perstat%ISOPEN THEN
        CLOSE c_perstat;
      END IF;
      logDetail( 'Exception from update of Application Status, '  || SQLERRM,'S');
      x_return_status:='E';
      x_message_name := 'IGS_GE_UNHANDLED_EXP';

      IF FND_MSG_PUB.Count_Msg < 1 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	  Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.update_appl_section_stat -'||SQLERRM);
	  IGS_GE_MSG_STACK.ADD;
       END IF;
  END update_appl_section_stat;


  /* Procedure which will Sync the checklist w.r.t Application type configuration. */
  PROCEDURE sync_appl_section_stat(p_person_id       IN NUMBER,
                                   p_adm_appl_number IN NUMBER,
                                   p_Appl_Type       IN VARCHAR2,
                                   p_login_id        IN NUMBER,
                                   x_message_name    OUT NOCOPY VARCHAR2,
                                   x_return_status   OUT NOCOPY VARCHAR2,
                                   x_max_Sections    OUT NOCOPY NUMBER) AS
/*****************************************************************************************
 Created By: stammine
 Date Created : 10-Jun-2005
 Purpose: 1. Inserts records from Self Service Admissions Application Type Configuration
             if any discrepancy exists with existing Status data and setup.
          2. Update the COMPLETION_STATUS with COMPLETE if COMPLETION_STATUS = ERROR.
          3. Returns the No. of Pages/Sections included for the Application Type.
       This is used to set the sMaxSection Session Variable - Used throughout the Application Create/Update flow.
 Known limitations,enhancements,remarks:
 Change History
 Who        When          What
*****************************************************************************************/
    CURSOR c_NoPgs(cp_ApplType igs_ss_Adm_appl_stg.ADMISSION_APPLICATION_TYPE%TYPE) IS
      SELECT count(*)
        FROM igs_ad_ss_appl_pgs
       WHERE admission_application_type = cp_ApplType
         AND include_ind = 'Y';

  BEGIN

    -- Inserts records from Self Service Admissions Application Type Configuration
    -- if any discrepancy exists with existing Status data and setup.
    insert_appl_section_stat(x_message_name,
                             x_return_status,
                             p_person_id,
                             p_adm_appl_number,
                             p_login_id);

    -- Update the COMPLETION_STATUS with COMPLETE if COMPLETION_STATUS = ERROR for person in Context.
    UPDATE IGS_SS_AD_SEC_STAT
       SET COMPLETION_STATUS = 'COMPLETE'
     WHERE SS_ADM_APPL_ID = p_adm_appl_number
       AND PERSON_ID = p_person_id
       AND COMPLETION_STATUS = 'ERROR';

    -- Returns the No. of Pages/Sections included for the Application Type.
    -- This is used to set the sMaxSection Session Variable - Used throughout the Application Create/Update flow.
    OPEN c_NoPgs(p_Appl_Type);
    FETCH c_NoPgs
      INTO x_max_Sections;
    IF c_NoPgs%ISOPEN THEN
      CLOSE c_NoPgs;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
      x_message_name  := 'IGS_GE_UNHANDLED_EXP';
      x_max_Sections  := 0;
      logDetail('Exception from sync_appl_section_stat: ' || SQLERRM, 'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	  Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.sync_appl_section_stat -'||SQLERRM);
	  IGS_GE_MSG_STACK.ADD;
       END IF;
      IF c_NoPgs%ISOPEN THEN
        CLOSE c_NoPgs;
      END IF;
  END sync_appl_section_stat;


PROCEDURE auto_assign_pgs_comps_terms(
  x_message_name       OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2,
  p_appl_type          IN VARCHAR2,
  p_admission_cat      IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2
  )
AS
/*****************************************************************************************
 Created By: stammine
 Date Created : 10-Jun-2005
 Purpose:  procedure which will create the records in following areas when Application Type is created
            Application Type pages
            Application Type page Components
            Terms and Conditions.
           Invoked when New application type is created.
 Known limitations,enhancements,remarks:
 Change History
 Who        When          What
*****************************************************************************************/
/* List of Cursors --
  -- Cursor To retrieve the SS Pages from Application Type Configuration Setup table.
  -- Cursor to retrieve the SS page Components from Application Type Configuration Setup table
*/

CURSOR cpcs (cp_admission_cat                IGS_AD_PRCS_CAT_STEP.admission_Cat%TYPE,
             cp_s_admission_process_type     IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE,
             cp_page_code                    IGS_AD_SS_APPL_CONF.page_code%TYPE,
             cp_comp_code                    IGS_AD_SS_APPL_CONF.component_code%TYPE) IS
              SELECT mandatory_step_ind  --, s_admission_step_type --, step_group_type
              FROM IGS_AD_PRCS_CAT_STEP
              WHERE admission_Cat = cp_admission_cat
              AND  s_admission_process_type = cp_s_admission_process_type
              AND s_admission_step_type = (SELECT apc_step FROM igs_ad_ss_appl_conf
                  WHERE page_code =  cp_page_code
                  AND component_code = cp_comp_code);

CURSOR cpgs IS
SELECT
  DISTINCT conf.page_code,
  lkv.meaning   page_desc
FROM igs_ad_ss_appl_conf conf,
     igs_lookup_values lkv
WHERE
  lkv.lookup_type = 'SS_APPL_SELFSERVICE_PAGES'
  AND  lkv.lookup_code = conf.page_code
  AND  lkv.ENABLED_FLAG = 'Y'
  AND  SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE) AND NVL(END_DATE_ACTIVE,SYSDATE) ;

CURSOR cpcomps (cp_page_code  IGS_AD_SS_APPL_CONF.page_code%TYPE)
IS
SELECT conf.page_code, conf.component_code,
lkv.meaning component_desc,
conf.include_flag, conf.apc_step
FROM IGS_AD_SS_APPL_CONF conf,
igs_lookup_values lkv
WHERE
  lkv.lookup_type = 'IGS_AD_SS_PG_COMPS'
  AND  lkv.lookup_code = conf.component_code
  AND  conf.page_code = cp_page_code
  AND  lkv.ENABLED_FLAG = 'Y'
  AND  SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE) AND NVL(END_DATE_ACTIVE,SYSDATE);

CURSOR c_app_pgs (cp_appl_type  igs_ad_ss_appl_pgs.admission_application_type%TYPE)
IS
SELECT page_name FROM igs_ad_ss_appl_pgs WHERE
admission_application_type = cp_appl_type;

lv_order             igs_ad_ss_appl_pgs.disp_order%type;
lv_rowid             VARCHAR2(25);
lv_mand_ind          VARCHAR2(1);
lv_cond_disp_name   igs_ad_ss_terms.COND_DISP_NAME%type;
lv_cond_disp_txt    igs_ad_ss_terms.COND_DISP_TEXT%type;
lv_incl_flag        igs_ad_ss_terms.INCLUDE_FLAG%type;
lv_req_flag         igs_ad_ss_appl_comps.required_flag%type;
lv_appl_type        igs_ad_ss_appl_typ.admission_application_type%TYPE;

BEGIN

lv_rowid := '';
lv_order := 0;
lv_mand_ind := 'N';
lv_cond_disp_name := NULL;
lv_cond_disp_txt  := NULL;
lv_incl_flag := 'N';

FOR cpgs_rec IN  cpgs
LOOP
 IF cpgs_rec.page_code='PERSONAL_INFO' THEN
   lv_order := 2;
 ELSIF cpgs_rec.page_code='ADDRESS_INFO' THEN
   lv_order := 4;
 ELSIF cpgs_rec.page_code='FURTHER_INFO' THEN
   lv_order := 6;
 ELSIF cpgs_rec.page_code='RESIDENCY_INFO' THEN
   lv_order := 8;
 ELSIF cpgs_rec.page_code='INTL_INFO' THEN
   lv_order := 10;
 ELSIF cpgs_rec.page_code='APPLICATION_INFO' THEN
   lv_order := 12;
 ELSIF cpgs_rec.page_code='EDUCATIONAL_INFO' THEN
   lv_order := 14;
 ELSIF cpgs_rec.page_code='PERSONAL_STATEMENTS' THEN
   lv_order := 16;
 END IF;
     lv_appl_type := p_appl_type;
     -- dbms_output.put_line('Satya - Before Inserting Page : '||cpgs_rec.page_code);
     igs_ad_ss_appl_pgs_pkg.add_row (
      x_mode                              => 'R',
      x_rowid                             => lv_rowid,
      x_admission_application_type        => lv_appl_type,
      x_page_name                         => cpgs_rec.page_code,
      x_include_ind                       => 'Y',
      x_required_ind                      => NULL,
      x_disp_order                        => lv_order,
      x_page_disp_name                    => cpgs_rec.page_desc
    );
    -- dbms_output.put_line('Satya - After Inserting Page : '||cpgs_rec.page_code);
END LOOP;

lv_rowid := '';

FOR cpgs_rec IN c_app_pgs(p_appl_type)
LOOP
 FOR cpcomps_rec IN cpcomps(cpgs_rec.page_name)
 LOOP

     IF cpcomps_rec.component_code IN ('BASIC_INFO','PROGRAM_PREF') THEN
       lv_req_flag := 'Y';
     ELSIF cpcomps_rec.include_flag <> 'Y' THEN
          lv_req_flag := 'N';
     ELSE
        OPEN cpcs(p_admission_cat, p_s_admission_process_type, cpcomps_rec.page_code, cpcomps_rec.component_code);
        FETCH cpcs INTO lv_mand_ind;

        IF cpcs%NOTFOUND OR cpcomps_rec.component_code IN ('FIN_VER','MILITARY') THEN
          lv_req_flag := 'N';
        ELSE
          lv_req_flag := lv_mand_ind;
        END IF;

        IF cpcs%ISOPEN THEN
           CLOSE cpcs;
        END IF;
     END IF;
     lv_appl_type := p_appl_type;

     -- dbms_output.put_line('Satya - Before Inserting component : '||cpcomps_rec.component_code);
     igs_ad_ss_appl_comps_pkg.add_row (
        x_mode                            => 'R',
        x_rowid                           => lv_rowid,
        x_admission_application_type      => lv_appl_type,
        x_page_name                       => cpcomps_rec.page_code,
        x_component_code                  => cpcomps_rec.component_code,
        x_comp_disp_name                  => cpcomps_rec.component_desc,
        x_include_flag                    => cpcomps_rec.include_flag,
        x_required_flag                   => lv_req_flag
        );

     -- dbms_output.put_line('Satya - After Inserting component : '||cpcomps_rec.component_code);
   END LOOP; -- Components
 END LOOP; -- Pages

-- Check if the Terms and Conditions exist in the table... If exists Donont modify.
-- Inserting Terms and Conditions
lv_rowid := '';
    FOR i IN 1 .. 10
    LOOP
      IF i = 1 then
       lv_cond_disp_name := FND_MESSAGE.GET_STRING('IGS','IGS_AD_SS_PRIVACY_STMT_HDR'); --'Privacy Statement'
--       lv_cond_disp_txt := FND_MESSAGE.GET_STRING('IGS','IGS_SS_PRIVACY_STMT');
       lv_incl_flag := 'Y';
      ELSIF i = 2 then
       lv_cond_disp_name := FND_MESSAGE.GET_STRING('IGS','IGS_AD_SS_VERIFY_STMT_HDR'); --'Verification Statement';
--       lv_cond_disp_txt := FND_MESSAGE.GET_STRING('IGS','IGS_SS_VERIFICATION_STMT');
       lv_incl_flag := 'Y';
     ELSE
      FND_MESSAGE.SET_NAME('IGS','IGS_AD_SS_COND_HDR');
      FND_MESSAGE.SET_TOKEN('COND_ID',i);
      lv_cond_disp_name := FND_MESSAGE.GET;
      lv_incl_flag := 'N';
     END IF;
      lv_appl_type := p_appl_type;
      lv_cond_disp_txt := NULL;

     -- dbms_output.put_line('Satya - Before Inserting Term  : '||lv_cond_disp_name);
      igs_ad_ss_terms_pkg.add_row(
        x_mode                            => 'R',
        x_rowid                           => lv_rowid,
        x_admission_application_type      => lv_appl_type,
        x_cond_id                         => i,
        x_cond_disp_name                  => lv_cond_disp_name,
        x_cond_disp_text                  => lv_cond_disp_txt,
        x_include_flag                    => lv_incl_flag
       );
     -- dbms_output.put_line('Satya - After Inserting Term  : '||lv_cond_disp_name);

    END LOOP;

     x_message_name   := 'S';
     x_return_status  := NULL;

EXCEPTION
WHEN OTHERS THEN
 x_return_status := 'E';
 x_message_name := 'IGS_GE_UNHANDLED_EXP';
 IF FND_MSG_PUB.Count_Msg < 1 THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
    Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.auto_assign_pgs_comps_terms -'||SQLERRM);
    IGS_GE_MSG_STACK.ADD;
 END IF;
END auto_assign_pgs_comps_terms;


/* Local function to check if component is included in an Application Type for a Page */
FUNCTION isPgCompIncluded
(
p_Appl_type    IGS_AD_SS_APPL_COMPS.Admission_application_type%TYPE,
p_page_code    IGS_AD_SS_APPL_COMPS.Page_name%TYPE,
p_comp_code    IGS_AD_SS_APPL_COMPS.component_code%TYPE
) RETURN BOOLEAN IS

CURSOR  sspc (cp_p_Appl_type     IGS_AD_SS_APPL_COMPS.Admission_application_type%TYPE,
              cp_page_code       IGS_AD_SS_APPL_COMPS.Page_name%TYPE,
              cp_comp_code       IGS_AD_SS_APPL_COMPS.component_code%TYPE             ) IS
             SELECT 'x'
             FROM IGS_AD_SS_APPL_COMPS
             WHERE Admission_application_type = cp_p_Appl_type
             AND Page_name = cp_page_code
             AND component_code = cp_comp_code
             AND Include_flag = 'Y';

 l_inc      VARCHAR2(1);
BEGIN

    OPEN sspc(p_Appl_type,p_page_code,p_comp_code);
    FETCH sspc INTO l_inc;
    IF (sspc%FOUND) THEN
      CLOSE sspc;
      RETURN(TRUE);
    ELSE
      CLOSE sspc;
      RETURN(FALSE);
    END IF;
END isPgCompIncluded;


PROCEDURE update_assign_pgs_comps( x_message_name             OUT NOCOPY VARCHAR2,
                                   x_return_status            OUT NOCOPY VARCHAR2,
                                   p_appl_type                IN VARCHAR2 DEFAULT NULL,
                                   p_admission_cat            IN VARCHAR2,
                                   p_s_admission_process_type IN VARCHAR2
                                   ) AS
/*****************************************************************************************
 Created By: stammine
 Date Created : 10-Jun-2005
 Purpose:  procedure which will update the records in following areas when Application Category
           is Changed for an Application Type:
            Application Type pages
            Application Type page Components
            Terms and Conditions.
           Invoked when existing application type is updated.
 Known limitations,enhancements,remarks:
 Change History
 Who        When          What
*****************************************************************************************/

  CURSOR cpcs(cp_admission_cat IGS_AD_PRCS_CAT_STEP_ALL.admission_Cat%TYPE,
              cp_s_admission_process_type IGS_AD_PRCS_CAT_STEP_ALL.s_admission_process_type%TYPE,
              cp_page_code IGS_AD_SS_APPL_CONF.page_code%TYPE,
              cp_comp_code IGS_AD_SS_APPL_CONF.component_code%TYPE) IS
    SELECT mandatory_step_ind, s_admission_step_type, step_group_type
      FROM IGS_AD_PRCS_CAT_STEP_ALL
     WHERE admission_Cat = cp_admission_cat
       AND s_admission_process_type = cp_s_admission_process_type
       AND s_admission_step_type =
           (SELECT apc_step
              FROM IGS_AD_SS_APPL_CONF
             WHERE page_code = cp_page_code
               AND component_code = cp_comp_code
               AND apc_step IS NOT NULL);

  CURSOR sspg_upd(cp_Admission_application_type IGS_AD_SS_APPL_PGS.Admission_application_type%TYPE) IS
    SELECT Admission_application_type, Page_name, Include_Ind
      FROM IGS_AD_SS_APPL_PGS
     WHERE Admission_application_type = cp_Admission_application_type;

  CURSOR sspc_upd(cp_Admission_application_type IGS_AD_SS_APPL_COMPS.Admission_application_type%TYPE, cp_page_code IGS_AD_SS_APPL_COMPS.Page_name%TYPE) IS
    SELECT Admission_application_type, Page_name,component_code, Include_flag, Required_flag
      FROM IGS_AD_SS_APPL_COMPS
     WHERE Admission_application_type = cp_Admission_application_type
       AND Page_name = cp_page_code;

  TYPE appl_type IS TABLE OF IGS_AD_SS_APPL_TYP.admission_application_type%TYPE  INDEX BY BINARY_INTEGER;
  appl_type_table  appl_type;

  TYPE ApplCurType IS REF CURSOR;
  ssat_cv   ApplCurType;

  lv_mand_ind      IGS_AD_PRCS_CAT_STEP_ALL.mandatory_step_ind%TYPE;
  lv_step          IGS_AD_PRCS_CAT_STEP_ALL.s_admission_step_type%TYPE;
  lv_step_grp      IGS_AD_PRCS_CAT_STEP_ALL.step_group_type%TYPE;
  lv_include_flag  IGS_AD_SS_APPL_COMPS.include_flag%TYPE;
  lv_required_flag IGS_AD_SS_APPL_COMPS.required_flag%TYPE;
  appl_type_count  NUMBER;

BEGIN

  appl_type_count := 0;

  IF p_appl_type IS NOT NULL THEN
     OPEN ssat_cv FOR
      SELECT admission_application_type
       FROM IGS_AD_SS_APPL_TYP
      WHERE
           admission_application_type = p_appl_type
       AND admission_cat = p_admission_cat
       AND s_admission_process_type = p_s_admission_process_type;
   ELSE
     OPEN ssat_cv FOR
      SELECT admission_application_type
       FROM IGS_AD_SS_APPL_TYP
      WHERE
       admission_cat = p_admission_cat
       AND s_admission_process_type = p_s_admission_process_type;
   END IF;

  FETCH ssat_cv BULK COLLECT INTO appl_type_table;
  IF ssat_cv%ISOPEN THEN
    CLOSE ssat_cv;
  END IF;

  appl_type_count := appl_type_table.COUNT;

  FOR i IN 1 .. appl_type_count    -- Application Type
   LOOP
    FOR appl_pgs_rec IN sspg_upd(appl_type_table(i)) -- page (Application Type)
     LOOP

      FOR appl_pg_comps_rec IN sspc_upd(appl_pgs_rec.Admission_application_type,
                                    appl_pgs_rec.Page_name) --each component (Application Type, page)
       LOOP

        IF appl_pg_comps_rec.component_code IN
           ('BASIC_INFO', 'PROGRAM_PREF') AND
           (appl_pg_comps_rec.include_flag <> 'Y' OR
           appl_pg_comps_rec.required_flag <> 'Y') THEN

      --   Upadate the compoents table with Required_ind = Y and Include_ind = Y for the page=component.page_name
      --    and component =component.comp_name

          UPDATE igs_ad_ss_appl_comps
             SET include_flag = 'Y' , required_flag = 'Y'
           WHERE Admission_application_type =
                 appl_pg_comps_rec.Admission_application_type
             AND page_name = appl_pg_comps_rec.page_name
             AND component_code = appl_pg_comps_rec.component_code;
        ELSE
          OPEN cpcs(p_admission_cat,
                    p_s_admission_process_type,
                    appl_pg_comps_rec.page_name,
                    appl_pg_comps_rec.component_code);
          FETCH cpcs
            INTO lv_mand_ind, lv_step, lv_step_grp;
          IF cpcs%FOUND THEN
            CLOSE cpcs;
            IF lv_step IN ('PER-ALTERNATE', 'PER-ALIASES', 'PER-SPLNEEDS') THEN
              IF appl_pg_comps_rec.page_name IN
                 ('PERSONAL_INFO', 'FURTHER_INFO') AND
                 appl_pg_comps_rec.Include_flag = 'Y' THEN
                IF appl_pg_comps_rec.Required_flag <> 'Y' THEN
                  --   Upadate the compoents table with Required_ind = Y for the page=component.page_name
                  --    and component =component.comp_name
                  UPDATE igs_ad_ss_appl_comps
                     SET required_flag = 'Y'
                   WHERE Admission_application_type =
                         appl_pg_comps_rec.Admission_application_type
                     AND page_name = appl_pg_comps_rec.page_name
                     AND component_code = appl_pg_comps_rec.component_code;

                END IF;

              ELSIF (appl_pg_comps_rec.page_name = 'PERSONAL_INFO'  AND
                     NOT isPgCompIncluded(appl_pg_comps_rec.Admission_application_type,'FURTHER_INFO',appl_pg_comps_rec.component_code))
                     THEN
                        UPDATE igs_ad_ss_appl_comps
                        SET include_flag = 'Y' , required_flag = 'Y'
                        WHERE Admission_application_type =
                              appl_pg_comps_rec.Admission_application_type
                        AND page_name = appl_pg_comps_rec.page_name
                        AND component_code = appl_pg_comps_rec.component_code;

                END IF;
            ELSIF lv_step = 'PER-ADDR' AND
                  appl_pg_comps_rec.component_code = 'ADDRESS' THEN
              IF appl_pg_comps_rec.page_name IN
                 ('PERSONAL_INFO', 'ADDRESS_INFO') AND
                 appl_pg_comps_rec.Include_flag = 'Y' THEN
                IF appl_pg_comps_rec.Required_flag <> 'Y' THEN

                 -- Upadate the compoents table with Required_ind = Y for the page=component.page_name
                 --  and component =component.comp_name and application_type = component.application_type

                   UPDATE igs_ad_ss_appl_comps
                     SET required_flag = 'Y'
                   WHERE Admission_application_type =
                         appl_pg_comps_rec.Admission_application_type
                     AND page_name = appl_pg_comps_rec.page_name
                     AND component_code = appl_pg_comps_rec.component_code;

                END IF;
              ELSIF (appl_pg_comps_rec.page_name = 'ADDRESS_INFO' AND
                     NOT isPgCompIncluded(appl_pg_comps_rec.Admission_application_type,'PERSONAL_INFO',appl_pg_comps_rec.component_code)) THEN

                        UPDATE igs_ad_ss_appl_comps
                        SET include_flag = 'Y' , required_flag = 'Y'
                        WHERE Admission_application_type =
                              appl_pg_comps_rec.Admission_application_type
                        AND page_name = appl_pg_comps_rec.page_name
                        AND component_code = appl_pg_comps_rec.component_code;
              END IF;

            ELSIF lv_mand_ind = 'Y' THEN
              IF appl_pg_comps_rec.include_flag <> 'Y' OR
                 appl_pg_comps_rec.required_flag <> 'Y' THEN

                   IF appl_pg_comps_rec.component_code IN ('MILITARY','FIN_VER') THEN
                      UPDATE igs_ad_ss_appl_comps
                      SET include_flag = 'Y' , required_flag = 'N'
                      WHERE Admission_application_type = appl_pg_comps_rec.Admission_application_type
                       AND page_name = appl_pg_comps_rec.page_name
                       AND component_code = appl_pg_comps_rec.component_code;
                   ELSE
                      UPDATE igs_ad_ss_appl_comps
                      SET include_flag = 'Y' , required_flag = 'Y'
                      WHERE Admission_application_type = appl_pg_comps_rec.Admission_application_type
                       AND page_name = appl_pg_comps_rec.page_name
                       AND component_code = appl_pg_comps_rec.component_code;
                   END IF;
              END IF;
            END IF;
          END IF;
        END IF;

         IF cpcs%ISOPEN THEN
           CLOSE cpcs;
         END IF;
        END LOOP; -- Components
      END LOOP; -- Pages
    END LOOP; -- Application Types


    -- Include the page if the component for the page is included.
    -- Update the pages table IGS_AD_SS_APPL_PGS set Include_ind = Y where application_type = page.application_type
    -- and page_name = page.page_name;
    FORALL i IN 1 .. appl_type_count
    UPDATE IGS_AD_SS_APPL_PGS pgs SET Include_ind = 'Y' WHERE
           pgs.ADMISSION_APPLICATION_TYPE = appl_type_table(i) AND
           EXISTS (SELECT 'x' FROM IGS_AD_SS_APPL_COMPS comps WHERE
            comps.ADMISSION_APPLICATION_TYPE = appl_type_table(i)
            AND comps.Page_name = pgs.page_name
            AND comps.Include_flag = 'Y');

        x_return_status := 'S';
        x_message_name  := NULL;

    EXCEPTION
     WHEN OTHERS THEN
        x_return_status := 'E';
        x_message_name  := SQLERRM;

END update_assign_pgs_comps;

PROCEDURE validate_prog_pref  (p_ss_adm_appl_id           IN NUMBER ,
                               p_course_cd                IN VARCHAR2,
                               p_crv_version_number       IN NUMBER,
                               p_location_cd              IN VARCHAR2,
                               p_attendance_mode          IN VARCHAR2,
                               p_attendance_type          IN VARCHAR2,
                               p_final_unit_set_cd        IN VARCHAR2,
                               p_us_version_number       IN NUMBER,
                               p_message_name             OUT NOCOPY VARCHAR2,
                               p_return_type              OUT NOCOPY VARCHAR2) IS
    /*----------------------------------------------------------------------------
    ||  Created By : pbondugu
    ||  Created On : 9-Aug-2005
    ||  Purpose :  For validating program preference record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ----------------------------------------------------------------------------*/

  CURSOR c_appl_Stg(cp_ss_adm_appl_id NUMBER) IS
  SELECT person_id, acad_cal_type, acad_cal_seq_number, adm_cal_type,
         adm_cal_seq_number , admission_cat, s_adm_process_type
  FROM igs_ss_adm_appl_stg
  WHERE ss_adm_appl_id = cp_ss_adm_appl_id;

  CURSOR c_apcs (cp_step_type VARCHAR2, cp_admission_cat VARCHAR2, cp_s_admission_process_type VARCHAR2) IS
  SELECT s_admission_step_type, step_type_restriction_num
  FROM igs_ad_prcs_cat_step
  WHERE admission_cat = cp_admission_cat
  AND s_admission_process_type = cp_s_admission_process_type
  AND s_admission_step_type = cp_step_type
  AND step_group_type <> 'TRACK';


  CURSOR c_acaiv (
                cp_person_id                    IGS_AD_PS_APPL_INST.person_id%TYPE,
                cp_course_cd                    IGS_AD_PS_APPL_INST.course_cd%TYPE,
                cp_location_cd                  IGS_AD_PS_APPL_INST.location_cd%TYPE,
                cp_attendance_mode              IGS_AD_PS_APPL_INST.attendance_mode%TYPE,
                cp_attendance_type              IGS_AD_PS_APPL_INST.attendance_type%TYPE,
                cp_unit_set_cd                  IGS_AD_PS_APPL_INST.unit_set_cd%TYPE,
                cp_us_version_number            IGS_AD_PS_APPL_INST.us_version_number%TYPE,
                cp_adm_cal_type                 IGS_AD_APPL.adm_cal_type%TYPE,
                cp_adm_ci_sequence_number       IGS_AD_APPL.adm_ci_sequence_number%TYPE) IS
        SELECT  'x'
        FROM    IGS_AD_APPL aav, IGS_AD_PS_APPL_INST acaiv
        WHERE    aav.person_id = acaiv.person_id AND
                aav.admission_appl_number = acaiv.admission_appl_number AND
                acaiv.person_id                 = cp_person_id AND
                acaiv.course_cd                 = cp_course_cd AND
                NVL(acaiv.location_cd,'NULL')   = NVL(cp_location_cd,'NULL') AND
                NVL(acaiv.attendance_mode,'NULL') = NVL(cp_attendance_mode,'NULL') AND
                NVL(acaiv.attendance_type,'NULL') = NVL(cp_attendance_type,'NULL') AND
                NVL(acaiv.unit_set_cd, 'NULL')  = NVL(cp_unit_set_cd, 'NULL') AND
                NVL(acaiv.us_version_number,0)  = NVL(cp_us_version_number,0) AND
                NVL(acaiv.adm_cal_type, aav.adm_cal_type) = cp_adm_cal_type AND
                NVL(acaiv.adm_ci_sequence_number, aav.adm_ci_sequence_number)
                    = cp_adm_ci_sequence_number AND
                -- Check for CANCELLED added for bug 2678766
                NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(acaiv.adm_outcome_status),'x') <> 'CANCELLED';


  apcs_rec c_apcs%ROWTYPE;

  appl_Stg_rec c_appl_Stg%ROWTYPE;
  l_unit_set_appl VARCHAR2(1);
  lSuccess boolean;

  BEGIN
       OPEN c_appl_Stg(p_ss_adm_appl_id);
       FETCH c_appl_Stg INTO appl_Stg_rec;
       IF c_appl_Stg%NOTFOUND THEN
          CLOSE c_appl_Stg;
          p_return_type := 'E';
          p_message_name := 'IGS_AD_APPL_NOT_FOUND';

          RETURN;
       END IF;

        -- Validate for a matching admission course application instance for the
        -- IGS_PE_PERSON in the same admission period.
        FOR v_acaiv_rec IN c_acaiv(
                appl_Stg_rec.person_id,
                p_course_cd,
                p_location_cd,
                p_attendance_mode,
                p_attendance_type,
                p_final_unit_set_cd,
                p_us_version_number,
                appl_Stg_rec.adm_cal_type,
                appl_Stg_rec.adm_cal_seq_number) LOOP
                p_message_name := 'IGS_AD_ANOTHER_ADMAPPL_EXISTS';
                p_return_type := 'E';
                RETURN;
        END LOOP;


          -- Late Application Validation is done here
          validate_prog_inst(p_course_cd                => p_course_cd,
                             p_crv_version_number       => p_crv_version_number,
                             p_location_cd              => p_location_cd,
                             p_attendance_mode          => p_attendance_mode,
                             p_attendance_type          => p_attendance_type,
                             p_acad_cal_type            => appl_Stg_rec.acad_cal_type,
                             p_acad_ci_sequence_number  => appl_Stg_rec.acad_cal_seq_number,
                             p_adm_cal_type             => appl_Stg_rec.adm_cal_type,
                             p_adm_ci_sequence_number   => appl_Stg_rec.adm_cal_seq_number,
                             p_admission_cat            => appl_Stg_rec.admission_cat,
                             p_s_admission_process_type => appl_Stg_rec.s_adm_process_type,
                             p_message_name             => p_message_name,
                             p_return_type              => p_return_type);
           IF  p_return_type = 'E' THEN
                 IF c_appl_Stg%ISOPEN THEN
                    CLOSE c_appl_Stg;
                 END IF;
              RETURN;
           END IF;


  lSuccess := igs_ad_val_acai.admp_val_aca_sca(
                  p_person_id                      => appl_Stg_rec.person_id,
                  p_course_cd                      => p_course_cd,
                  p_appl_dt                        => TRUNC(SYSDATE),
                  p_admission_cat                  => appl_Stg_rec.admission_cat,
                  p_s_admission_process_type       => appl_Stg_rec.s_adm_process_type,
                  p_fee_cat                        => NULL,
                  p_correspondence_cat             => NULL,
                  p_enrolment_cat                  => NULL,
                  p_offer_ind                      => 'N',
                  p_message_name                   => p_message_name,
                  p_return_type                    => p_return_type);

           IF  p_return_type = 'E' THEN
                 IF c_appl_Stg%ISOPEN THEN
                    CLOSE c_appl_Stg;
                 END IF;
              RETURN;
           END IF;

    OPEN c_apcs('UNIT-SET', appl_Stg_rec.admission_cat, appl_Stg_rec.s_adm_process_type);
    FETCH c_apcs INTO apcs_rec;
    CLOSE c_apcs;

    IF apcs_rec.s_admission_step_type IS NULL  THEN
       l_unit_set_appl := 'N';
    ELSE
       l_unit_set_appl := 'Y';
    END IF;

lSuccess := igs_ad_val_acai.admp_val_acai_us(
                  p_unit_set_cd                    => p_final_unit_set_cd,
                  p_us_version_number              => p_us_version_number,
                  p_course_cd                      => p_course_cd,
                  p_crv_version_number             => p_crv_version_number,
                  p_acad_cal_type                  => appl_Stg_rec.acad_cal_type,
                  p_location_cd                    => p_location_cd,
                  p_attendance_mode                => p_attendance_mode,
                  p_attendance_type                => p_attendance_type,
                  p_admission_cat                  => appl_Stg_rec.admission_cat,
                  p_offer_ind                      => 'N',
                  p_unit_set_appl                  => l_unit_set_appl,
                  p_message_name                   => p_message_name,
                  p_return_type                    => p_return_type);

           IF  p_return_type = 'E' THEN
                 p_message_name := 'IGS_AD_SS_INV_FINAL_US';
                 IF c_appl_Stg%ISOPEN THEN
                    CLOSE c_appl_Stg;
                 END IF;
                 RETURN;
           END IF;

          IF c_appl_Stg%ISOPEN THEN
            CLOSE c_appl_Stg;
          END IF;
  END  validate_prog_pref;


  PROCEDURE validate_unit_Set (p_ss_adm_appl_id           IN NUMBER ,
                               p_course_cd                    VARCHAR2,
                               p_crv_version_number           NUMBER,
                               p_location_cd                  VARCHAR2,
                               p_attendance_mode              VARCHAR2,
                               p_attendance_type              VARCHAR2,
                               p_unit_set_cd                  VARCHAR2,
                               p_us_version_number            NUMBER ,
                               p_message_name                 OUT NOCOPY VARCHAR2,
                               p_return_type                  OUT NOCOPY VARCHAR2) IS


  CURSOR c_appl_Stg(cp_ss_adm_appl_id NUMBER) IS
  SELECT person_id, acad_cal_type, acad_cal_seq_number, adm_cal_type,
         adm_cal_seq_number , admission_cat, s_adm_process_type
  FROM igs_ss_adm_appl_stg
  WHERE ss_adm_appl_id = cp_ss_adm_appl_id;

  CURSOR c_apcs (cp_step_type VARCHAR2, cp_admission_cat VARCHAR2, cp_s_admission_process_type VARCHAR2) IS
  SELECT s_admission_step_type, step_type_restriction_num
  FROM igs_ad_prcs_cat_step
  WHERE admission_cat = cp_admission_cat
  AND s_admission_process_type = cp_s_admission_process_type
  AND s_admission_step_type = cp_step_type
  AND step_group_type <> 'TRACK';


  apcs_rec c_apcs%ROWTYPE;

  appl_Stg_rec c_appl_Stg%ROWTYPE;
  l_unit_set_appl VARCHAR2(1);
  lSuccess boolean;


  BEGIN

       OPEN c_appl_Stg(p_ss_adm_appl_id);
       FETCH c_appl_Stg INTO appl_Stg_rec;
       IF c_appl_Stg%NOTFOUND THEN
          CLOSE c_appl_Stg;
          p_return_type := 'E';
          p_message_name := 'IGS_AD_APPL_NOT_FOUND';
          RETURN;
       END IF;

       lSuccess := igs_ad_val_acai.admp_val_acai_us(
                  p_unit_set_cd                    => p_unit_set_cd,
                  p_us_version_number              => p_us_version_number,
                  p_course_cd                      => p_course_cd,
                  p_crv_version_number             => p_crv_version_number,
                  p_acad_cal_type                  => appl_Stg_rec.acad_cal_type,
                  p_location_cd                    => p_location_cd,
                  p_attendance_mode                => p_attendance_mode,
                  p_attendance_type                => p_attendance_type,
                  p_admission_cat                  => appl_Stg_rec.admission_cat,
                  p_offer_ind                      => 'N',
                  p_unit_set_appl                  => l_unit_set_appl,
                  p_message_name                   => p_message_name,
                  p_return_type                    => p_return_type);

           IF  p_return_type = 'E' THEN
                 IF c_appl_Stg%ISOPEN THEN
                    CLOSE c_appl_Stg;
                 END IF;
                 RETURN;
           END IF;

          IF c_appl_Stg%ISOPEN THEN
            CLOSE c_appl_Stg;
          END IF;

  END validate_unit_Set;

PROCEDURE DELETE_PERSTMT_ATTACHMENT(p_document_id IN NUMBER,
                                    p_ss_perstat_id IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2
                                      ) AS
-- This method will be used to delete the Personal Statement Attachment record
-- from the tables FND_ATTCHED_DOCUMENTS, FND_DOCUMENTS and FND_LOBS.
BEGIN
    x_return_status := 'S';
    FND_DOCUMENTS_PKG.DELETE_ROW (
                            x_document_id     => p_document_id,
                            x_datatype_id     => 6,
                            delete_ref_Flag   => 'Y'
    );
    Update IGS_SS_APPL_PERSTAT SET  attach_exists ='N' WHERE SS_PERSTAT_ID = p_ss_perstat_id;
EXCEPTION
        WHEN OTHERS THEN
           x_return_status := 'E';

END DELETE_PERSTMT_ATTACHMENT;


PROCEDURE ADD_PERSTMT_ATTACHMENT(p_person_id IN NUMBER,
                                    P_SS_PERSTAT_ID IN NUMBER,
                                    p_file_name IN VARCHAR2,
                                    p_file_content_type IN VARCHAR2,
                                    p_file_format IN VARCHAR2,
                                    p_file_id OUT NOCOPY NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2
                                    )AS

        CURSOR cat_cur(cp_name VARCHAR2) IS
        SELECT category_id
        FROM fnd_document_categories_tl
        WHERE name = cp_name;

        l_fileid FND_LOBS.FILE_ID%TYPE;
        l_category_id FND_DOCUMENT_CATEGORIES_TL.category_id%TYPE;
BEGIN
        x_return_status := 'S';


        -- Insert data in the FND_LOBS table without the FILE_DATA.
        -- FILE_DATA would be updated from the Controller of the calling page since
        -- there is issue of passing BLOB data type to PL/SQL from OA Framework.
        SELECT FND_LOBS_S.NEXTVAL INTO l_fileid FROM dual;

        INSERT INTO FND_LOBS(
                          FILE_ID,
                          FILE_NAME,
                          FILE_CONTENT_TYPE,
                          UPLOAD_DATE,
                          EXPIRATION_DATE,
                          PROGRAM_NAME,
                          PROGRAM_TAG,
                          LANGUAGE,
                          ORACLE_CHARSET,
                          FILE_FORMAT) VALUES
                          (
                          l_fileid,
                          p_file_name,
                          p_file_content_type,
                          SYSDATE,
                          NULL,
                          NULL,
                          NULL,
                          USERENV('LANG'),
                          NULL,
                          p_file_format
        );

        p_file_id := l_fileid;

        OPEN cat_cur('CUSTOM1475');
        FETCH cat_cur INTO l_category_id;
        CLOSE cat_cur;

        FND_WEBATTCH.Add_Attachment (
                                seq_num                 => '1',
                                category_id             => l_category_id,
                                document_description    => NULL,
                                datatype_id             => 6,
                                text                    => NULL,
                                file_name               => p_file_name,
                                url                     => NULL,
                                function_name           => NULL,
                                entity_name             => 'IGS_SS_APPL_PERSTAT',
                                pk1_value               => P_SS_PERSTAT_ID,
                                pk2_value               => NULL,
                                pk3_value               => NULL,
                                pk4_value               => NULL,
                                pk5_value               => NULL,
                                media_id                => l_fileid,
                                user_id                 => FND_GLOBAL.USER_ID
        );

        Update IGS_SS_APPL_PERSTAT SET  attach_exists ='Y' WHERE SS_PERSTAT_ID = P_SS_PERSTAT_ID;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'E';

END ADD_PERSTMT_ATTACHMENT;

PROCEDURE DELETE_PERSTMT_ATTACHMENT_UP(p_document_id IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2
                                      ) AS
-- This method will be used to delete the Personal Statement Attachment record
-- from the tables FND_ATTCHED_DOCUMENTS, FND_DOCUMENTS and FND_LOBS.
BEGIN
    x_return_status := 'S';
    FND_DOCUMENTS_PKG.DELETE_ROW (
                            x_document_id     => p_document_id,
                            x_datatype_id     => 6,
                            delete_ref_Flag   => 'Y'
    );

EXCEPTION
        WHEN OTHERS THEN
           x_return_status := 'E';

END DELETE_PERSTMT_ATTACHMENT_UP;


PROCEDURE ADD_PERSTMT_ATTACHMENT_UP(p_person_id IN NUMBER,
                                    P_APPL_PERSTAT_ID IN NUMBER,
                                    p_file_name IN VARCHAR2,
                                    p_file_content_type IN VARCHAR2,
                                    p_file_format IN VARCHAR2,
                                    p_file_id OUT NOCOPY NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2
                                    )AS

        CURSOR cat_cur(cp_name VARCHAR2) IS
        SELECT category_id
        FROM fnd_document_categories_tl
        WHERE name = cp_name;

        l_fileid FND_LOBS.FILE_ID%TYPE;
        l_category_id FND_DOCUMENT_CATEGORIES_TL.category_id%TYPE;
BEGIN
        x_return_status := 'S';


        -- Insert data in the FND_LOBS table without the FILE_DATA.
        -- FILE_DATA would be updated from the Controller of the calling page since
        -- there is issue of passing BLOB data type to PL/SQL from OA Framework.
        SELECT FND_LOBS_S.NEXTVAL INTO l_fileid FROM dual;

        INSERT INTO FND_LOBS(
                          FILE_ID,
                          FILE_NAME,
                          FILE_CONTENT_TYPE,
                          UPLOAD_DATE,
                          EXPIRATION_DATE,
                          PROGRAM_NAME,
                          PROGRAM_TAG,
                          LANGUAGE,
                          ORACLE_CHARSET,
                          FILE_FORMAT) VALUES
                          (
                          l_fileid,
                          p_file_name,
                          p_file_content_type,
                          SYSDATE,
                          NULL,
                          NULL,
                          NULL,
                          USERENV('LANG'),
                          NULL,
                          p_file_format
        );

        p_file_id := l_fileid;

        OPEN cat_cur('CUSTOM1475');
        FETCH cat_cur INTO l_category_id;
        CLOSE cat_cur;

        FND_WEBATTCH.Add_Attachment (
                                seq_num                 => '1',
                                category_id             => l_category_id,
                                document_description    => NULL,
                                datatype_id             => 6,
                                text                    => NULL,
                                file_name               => p_file_name,
                                url                     => NULL,
                                function_name           => NULL,
                                entity_name             => 'IGS_AD_APPL_PERSTAT',
                                pk1_value               => P_APPL_PERSTAT_ID,
                                pk2_value               => NULL,
                                pk3_value               => NULL,
                                pk4_value               => NULL,
                                pk5_value               => NULL,
                                media_id                => l_fileid,
                                user_id                 => FND_GLOBAL.USER_ID
        );

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'E';

END ADD_PERSTMT_ATTACHMENT_UP;
-- PERSONAL_STMTS

/* Get Concatenated Enabled SS Lookup Code Descriptions for a given lookup type with given delimiter */
PROCEDURE get_ss_lookup_desc(p_application_type IN igs_ad_ss_lookups.admission_application_type%type,
                             p_lookup_type   IN igs_ad_ss_lookups.ss_lookup_type%TYPE,
                             p_delimiter     IN VARCHAR2,
                             x_message_name    OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2,
                             x_concat_desc     OUT NOCOPY VARCHAR2) AS

   CURSOR c_addr_purpose IS
      SELECT al.meaning      lookup_desc
        FROM AR_LOOKUPS al
       WHERE al.LOOKUP_TYPE = 'PARTY_SITE_USE_CODE'
         AND al.ENABLED_FLAG = 'Y'
         AND EXISTS (SELECT 1 FROM IGS_AD_SS_LOOKUPS sslkps
                    WHERE sslkps.SS_LOOKUP_TYPE = 'SITE_USE_CODE' AND
                    sslkps.admission_application_type = p_application_type AND
                    sslkps.ss_lookup_code = al.lookup_code AND
                    sslkps.closed_flag <> 'Y');

   CURSOR c_phone_type IS
      SELECT lv.meaning      lookup_desc
        FROM FND_LOOKUP_VALUES lv
       WHERE lv.LOOKUP_TYPE = 'PHONE_LINE_TYPE'
         AND lv.LANGUAGE(+) = USERENV('LANG')
         AND lv.VIEW_APPLICATION_ID = 222
         AND lv.SECURITY_GROUP_ID = 0
         AND lv.ENABLED_FLAG = 'Y'
         AND EXISTS
          (SELECT 1 FROM IGS_AD_SS_LOOKUPS sslkps
             WHERE sslkps.SS_LOOKUP_TYPE = 'PHONE_LINE_TYPE' AND
             sslkps.admission_application_type = p_application_type AND
             sslkps.ss_lookup_code = lv.lookup_code AND
	     sslkps.closed_flag <> 'Y');

   CURSOR c_person_id_type IS
      SELECT pit.description    lookup_desc
        FROM IGS_PE_PERSON_ID_TYP pit
       WHERE pit.closed_ind <> 'Y'
       AND EXISTS (SELECT 1 FROM IGS_AD_SS_LOOKUPS sslkps
               WHERE sslkps.SS_LOOKUP_TYPE = 'PERSON_ID_TYPE' AND
               sslkps.admission_application_type = p_application_type AND
               sslkps.ss_lookup_code = pit.person_id_type AND
	       sslkps.closed_flag <> 'Y');

   CURSOR c_relation_type IS
       SELECT lv.meaning      lookup_desc
        FROM FND_LOOKUP_VALUES lv,
             HZ_RELATIONSHIP_TYPES hz
       WHERE HZ.FORWARD_REL_CODE=lv.lookup_code
         AND hz.subject_type = 'PERSON'
         AND hz.object_type = 'PERSON'
         AND hz.status = 'A'
         AND lv.LOOKUP_TYPE = 'PARTY_RELATIONS_TYPE'
         AND lv.LANGUAGE(+) = USERENV('LANG')
         AND lv.VIEW_APPLICATION_ID = 222
         AND lv.SECURITY_GROUP_ID = 0
         AND lv.ENABLED_FLAG = 'Y'
         AND EXISTS (SELECT 1 FROM IGS_AD_SS_LOOKUPS sslkps
             WHERE sslkps.SS_LOOKUP_TYPE = 'PARTY_RELATIONS_TYPE' AND
             sslkps.admission_application_type = p_application_type AND
             sslkps.ss_lookup_code = lv.lookup_code AND
	     sslkps.closed_flag <> 'Y');

   CURSOR c_privacy_data IS
      SELECT pdg.description   lookup_desc
        FROM IGS_PE_DATA_GROUPS_ALL pdg
       WHERE pdg.closed_ind <> 'Y'
       AND EXISTS (SELECT 1 FROM IGS_AD_SS_LOOKUPS sslkps
          WHERE sslkps.ss_lookup_type = 'PRIVACY_PREF_DATA_GROUP' AND
            sslkps.admission_application_type = p_application_type AND
            sslkps.ss_lookup_code = to_char(pdg.data_group_id) AND
	    sslkps.closed_flag <> 'Y');

   CURSOR c_alias_type IS
      SELECT lv.meaning      lookup_desc
        FROM igs_lookup_values lv
       WHERE lv.LOOKUP_TYPE = 'PE_ALIAS_TYPE'
         AND lv.ENABLED_FLAG = 'Y'
         AND EXISTS (SELECT 1 FROM IGS_AD_SS_LOOKUPS sslkps
             WHERE sslkps.SS_LOOKUP_TYPE = 'PE_ALIAS_TYPE' AND
              sslkps.admission_application_type = p_application_type AND
              sslkps.ss_lookup_code = lv.lookup_code AND
              sslkps.closed_flag <> 'Y');

   CURSOR c_credential_type IS
      SELECT act.description        lookup_desc
        FROM IGS_AD_CRED_TYPES act
       WHERE act.closed_ind <> 'Y'
          AND EXISTS (SELECT 1 FROM IGS_AD_SS_LOOKUPS sslkps
          WHERE sslkps.ss_lookup_type = 'CREDENTIAL_TYPE' AND
             sslkps.admission_application_type =  p_application_type AND
             sslkps.ss_lookup_code = to_char(act.credential_type_id)  AND
             sslkps.closed_flag <> 'Y');

   CURSOR c_admission_test_type IS
      SELECT att.description         lookup_desc
        FROM IGS_AD_TEST_TYPE att
       WHERE att.closed_ind <> 'Y'
        AND EXISTS (SELECT 1 FROM IGS_AD_SS_LOOKUPS sslkps
          WHERE sslkps.SS_LOOKUP_TYPE = 'ADMISSION_TEST_TYPE' AND
             sslkps.admission_application_type = p_application_type AND
             sslkps.ss_lookup_code = att.admission_test_type AND
             sslkps.closed_flag <> 'Y');

   lv_desc   VARCHAR2(20000);

BEGIN

  lv_desc := NULL;
  IF p_lookup_type = 'SITE_USE_CODE' THEN
    FOR desc_rec IN c_addr_purpose
    LOOP
      IF lv_desc IS NULL THEN
        lv_desc := desc_rec.lookup_desc;
      ELSE
        lv_desc := lv_desc || p_delimiter || desc_rec.lookup_desc;
      END IF;
    END LOOP;

  ELSIF p_lookup_type = 'PHONE_LINE_TYPE' THEN
    FOR desc_rec IN c_phone_type
    LOOP
      IF lv_desc IS NULL THEN
        lv_desc := desc_rec.lookup_desc;
      ELSE
        lv_desc := lv_desc || p_delimiter || desc_rec.lookup_desc;
      END IF;
    END LOOP;

  ELSIF p_lookup_type = 'PERSON_ID_TYPE' THEN
    FOR desc_rec IN c_person_id_type
    LOOP
      IF lv_desc IS NULL THEN
        lv_desc := desc_rec.lookup_desc;
      ELSE
        lv_desc := lv_desc || p_delimiter || desc_rec.lookup_desc;
      END IF;
    END LOOP;

  ELSIF p_lookup_type = 'PARTY_RELATIONS_TYPE' THEN
    FOR desc_rec IN c_relation_type
    LOOP
      IF lv_desc IS NULL THEN
        lv_desc := desc_rec.lookup_desc;
      ELSE
        lv_desc := lv_desc || p_delimiter || desc_rec.lookup_desc;
      END IF;
    END LOOP;

  ELSIF p_lookup_type = 'PRIVACY_PREF_DATA_GROUP' THEN
    FOR desc_rec IN c_privacy_data
    LOOP
      IF lv_desc IS NULL THEN
        lv_desc := desc_rec.lookup_desc;
      ELSE
        lv_desc := lv_desc || p_delimiter || desc_rec.lookup_desc;
      END IF;
    END LOOP;

  ELSIF p_lookup_type = 'PE_ALIAS_TYPE' THEN
    FOR desc_rec IN c_alias_type
    LOOP
      IF lv_desc IS NULL THEN
        lv_desc := desc_rec.lookup_desc;
      ELSE
        lv_desc := lv_desc || p_delimiter || desc_rec.lookup_desc;
      END IF;
    END LOOP;

  ELSIF p_lookup_type = 'CREDENTIAL_TYPE' THEN
    FOR desc_rec IN c_credential_type
    LOOP
      IF lv_desc IS NULL THEN
        lv_desc := desc_rec.lookup_desc;
      ELSE
        lv_desc := lv_desc || p_delimiter || desc_rec.lookup_desc;
      END IF;
    END LOOP;

   ELSIF p_lookup_type = 'ADMISSION_TEST_TYPE' THEN
    FOR desc_rec IN c_admission_test_type
    LOOP
      IF lv_desc IS NULL THEN
        lv_desc := desc_rec.lookup_desc;
      ELSE
        lv_desc := lv_desc || p_delimiter || desc_rec.lookup_desc;
      END IF;
    END LOOP;

  END IF;

   x_return_status := 'S';
   x_message_name := NULL;
   x_concat_desc := lv_desc;

 EXCEPTION
     WHEN OTHERS THEN
      x_return_status := 'E';
      x_message_name := 'IGS_GE_UNHANDLED_EXP';
      x_concat_desc := NULL;
       IF FND_MSG_PUB.Count_Msg < 1 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	  Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.get_ss_lookup_desc -'||SQLERRM);
	  IGS_GE_MSG_STACK.ADD;
       END IF;
 END get_ss_lookup_desc;

PROCEDURE CHECK_INSTANCE_SECURITY( p_person_id       IN NUMBER,
                                   p_adm_appl_number IN NUMBER,
                                   x_return_status   OUT NOCOPY VARCHAR2,
                                   x_error_msg       OUT NOCOPY VARCHAR2) IS
CURSOR get_appl_inst_rowid(cp_person_id NUMBER,cp_admission_appl_number NUMBER) IS
SELECT ROWID
FROM IGS_AD_PS_APPL_INST_ALL
WHERE person_id = cp_person_id
AND ADMISSION_APPL_NUMBER = cp_admission_appl_number;

l_select_access BOOLEAN;
l_return_value BOOLEAN;
l_msg_data VARCHAR2(2000);
BEGIN
l_select_access := FALSE;
  FOR c_admappl_pgm_rec IN get_appl_inst_rowid(p_person_id,p_adm_appl_number) LOOP
       l_return_value := igs_sc_gen_001.check_sel_upd_del_security
                             ('IGS_AD_PS_APPL_INST_SV',
                             c_admappl_pgm_rec.rowid,
                             'S',
                             l_msg_data
                             );
       IF l_return_value THEN
           l_select_access := TRUE;
           EXIT;
       END IF;
   END LOOP;

   IF l_select_access THEN
   x_return_status := 'S';
   x_error_msg := NULL;
   ELSE
   x_return_status := 'E';
            IF l_msg_data IS NOT NULL THEN
            fnd_message.set_name( 'IGS', 'IGS_SC_PRE_CHECK_EXCEP');
            fnd_message.set_token('ERRM',l_msg_data);
            fnd_message.set_token('TABLE','IGS_AD_PS_APPL_INST_SV');
            fnd_message.set_token('OPERATION','SELECT');
            x_error_msg := 'IGS_SC_PRE_CHECK_EXCEP';
            ELSE
            fnd_message.set_name( 'IGS', 'IGS_SC_NO_ACCESS_PRIV');
            x_error_msg := 'IGS_SC_NO_ACCESS_PRIV';
            END IF;
            IGS_GE_MSG_STACK.ADD;
   END IF;

END CHECK_INSTANCE_SECURITY;

  FUNCTION create_application_detail
                             (p_person_id           IN igs_pe_typ_instances_all.person_id%TYPE,
                              p_adm_appl_number     IN igs_pe_typ_instances_all.admission_appl_number%TYPE,
                              p_ss_adm_appl_number IN NUMBER) RETURN BOOLEAN IS
 lRetStat VARCHAR2(1);
  BEGIN
  lRetStat := 'S';
      IF p_adm_appl_number IS NOT NULL THEN
        --added by nshee during build for Applicant-BOSS SS Bug 2622488
        insert_acad_interest(p_person_id       => p_person_id,
                             p_adm_appl_id     => p_ss_adm_appl_number,
                             p_adm_appl_number => p_adm_appl_number);
        insert_applicant_intent(p_person_id       => p_person_id,
                                p_adm_appl_id     => p_ss_adm_appl_number,
                                p_adm_appl_number => p_adm_appl_number);
        insert_spl_talent(p_person_id       => p_person_id,
                          p_adm_appl_id     => p_ss_adm_appl_number,
                          p_adm_appl_number => p_adm_appl_number);
        insert_special_interest(p_person_id       => p_person_id,
                                p_adm_appl_id     => p_ss_adm_appl_number,
                                p_adm_appl_number => p_adm_appl_number);
        --added by nshee during build for Applicant-BOSS SS Bug 2622488
        insert_othinst(p_person_id             => p_person_id,
                       p_adm_appl_id           => p_ss_adm_appl_number,
                       p_admission_appl_number => p_adm_appl_number);
        --dhan
        -- Bug # 2389273 [ APPLICATION  FEE SAVED IN SS IS NOT SAVED TO FORMS ]
        logheader('before inserting application_fee into IGS tables', 'S');
        insert_application_fee(p_person_id       => p_person_id,
                               p_adm_appl_id     => p_ss_adm_appl_number,
                               p_adm_appl_number => p_adm_appl_number);

      ------------------------------------------------------------------------------------
      -- Routine to transfer Personal Statements and Attachments from Staging to IGS Tables
      ------------------------------------------------------------------------------------
      transfer_attachment(p_person_id             => p_person_id,
                          p_ss_adm_appl_id        => p_ss_adm_appl_number,
                          p_admission_appl_number => p_adm_appl_number,
                          x_return_status         => lRetStat);
      END IF;


      IF lRetStat = 'S' THEN
        RETURN TRUE;
      ELSE
        ROLLBACK TO sp_save_point1;
        RETURN FALSE;
      END IF;
  EXCEPTION
    --Main Loop Exception
    WHEN OTHERS THEN
      logDetail('Exception from create_application_detail, MAIN LOOP: ' || SQLERRM, 'S');
      IF FND_MSG_PUB.Count_Msg < 1 THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_SS_GEN_001.create_application_detail -'||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
      END IF;
      App_Exception.Raise_Exception;

  END create_application_detail;

FUNCTION wf_submit_application_sub(p_subscription_guid IN RAW,
                        p_event IN OUT NOCOPY WF_EVENT_T) return varchar2
IS
     CURSOR c_pre_sub_uhk_prl IS
       SELECT  FND_PROFILE.VALUE('IGS_AD_PRESUB_APPL_UHK') value
       FROM dual;


    l_person_id	  NUMBER;
    l_ss_adm_appl_id NUMBER;
    l_return_status VARCHAR2(10);
    l_msg_data fnd_new_messages.message_text%TYPE;
    l_pre_sub_uhk_prl c_pre_sub_uhk_prl%ROWTYPE;
    l_msg_index                          NUMBER;
    l_hash_msg_name_text_type_tab        igs_ad_gen_016.g_msg_name_text_type_table;
    l_msg_count NUMBER;
    l_def_rule VARCHAR2(200);
BEGIN

    l_person_id := p_event.GetValueForParameter('P_PERSON_ID');
    l_ss_adm_appl_id := p_event.GetValueForParameter('P_SS_ADM_APPL_ID');
    l_return_status := p_event.GetValueForParameter('P_RETURN_STATUS');
    l_msg_data := NULL;

    OPEN c_pre_sub_uhk_prl;
    FETCH c_pre_sub_uhk_prl INTO l_pre_sub_uhk_prl;
    CLOSE c_pre_sub_uhk_prl;

    IF l_pre_sub_uhk_prl.value ='Y' THEN
       igs_ad_uhk_pre_create_appl_pkg.pre_submit_application (
         p_person_id     =>  l_person_id,
         p_ss_adm_appl_id => l_ss_adm_appl_id,
         p_return_status  => l_return_status,
         p_msg_data      =>  l_msg_data
       );

       p_event.AddParameterToList('P_RETURN_STATUS',l_return_status);
       p_event.AddParameterToList('P_MSG_DATA',l_msg_data);
    END IF;
    l_def_rule := WF_RULE.Default_Rule(p_subscription_guid,p_event);
    return 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    igs_ad_gen_016.extract_msg_from_stack (
             p_msg_at_index                => l_msg_index,
             p_return_status               => l_return_status,
             p_msg_count                   => l_msg_count,
             p_msg_data                    => l_msg_data,
             p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

    IF l_hash_msg_name_text_type_tab(l_msg_count - 1).name <> 'ORA' THEN
  	  l_return_status := 'E';
    ELSE
	  l_return_status := 'U';
    END IF;
    l_msg_data := l_hash_msg_name_text_type_tab(l_msg_count-1).text;
    p_event.AddParameterToList('P_RETURN_STATUS',l_return_status);
    p_event.AddParameterToList('P_MSG_DATA',l_msg_data);

    WF_CORE.CONTEXT('IGS_AD_SS_GEN_001','WF_SUBMIT_APPLICATION_SUB',p_event.getEventName(),p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    return 'ERROR';
END wf_submit_application_sub;

END IGS_AD_SS_GEN_001;

/
