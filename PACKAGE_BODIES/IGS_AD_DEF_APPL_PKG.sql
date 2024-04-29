--------------------------------------------------------
--  DDL for Package Body IGS_AD_DEF_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_DEF_APPL_PKG" AS
/* $Header: IGSADC1B.pls 120.8 2006/05/29 12:25:04 apadegal ship $ */

FUNCTION get_person_number ( p_person_id hz_parties.party_id%TYPE ) RETURN VARCHAR2 IS

CURSOR c_person_num IS
        SELECT party_number
	FROM   hz_parties hp
	WHERE  hp.party_id = p_person_id;

lv_person_number      hz_parties.party_number%TYPE DEFAULT NULL;
BEGIN

      OPEN c_person_num;
      FETCH c_person_num INTO lv_person_number;
      CLOSE c_person_num;

      RETURN   lv_person_number;
END   get_person_number;

/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 06 AUG 2002

Purpose:
  To create deferred term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
nsinha          15-Nov-2002     Bug :2664410 - Release Of Build For Adcr049 - Alternate Application Id.
				* In Function handle_application:
				* Passed p_alt_appl_id parameter to igs_ad_gen_014.insert_adm_appl
*******************************************************************************/
PROCEDURE admp_val_offer_defer_term(
                                        errbuf out NOCOPY varchar2,
                                        retcode out NOCOPY number ,
                                        p_person_id hz_parties.party_id%TYPE,
                                        p_group_id igs_pe_persid_group.group_id%TYPE,
                                        p_nominated_course_cd  igs_ad_ps_appl.nominated_course_cd%TYPE,
                                        p_prev_acad_adm_cal  VARCHAR2,
                                        p_def_acad_adm_cal VARCHAR2,
                                        p_offer_dt   VARCHAR2,
                                        p_offer_response_dt VARCHAR2
                                     )  IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 06 SEP 2002

Purpose:
  To create deferred term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/

 -- Variable Declarations ----------------------------------------------------------------------------------------------------

 -- Resolve the parameters to get calendar types and sequence numbers
  p_prev_acad_cal_type          igs_ad_appl.acad_cal_type%TYPE          ;
  p_prev_acad_cal_seq_no        igs_ad_appl.acad_ci_sequence_number%TYPE;
  p_prev_adm_cal_type           igs_ad_appl.adm_cal_type%TYPE           ;
  p_prev_adm_cal_seq_no         igs_ad_appl.adm_ci_sequence_number%TYPE ;

  p_def_acad_cal_type           igs_ad_appl.acad_cal_type%TYPE          ;
  p_def_acad_cal_seq_no         igs_ad_appl.acad_ci_sequence_number%TYPE;
  p_def_adm_cal_type            igs_ad_appl.adm_cal_type%TYPE           ;
  p_def_adm_cal_seq_no          igs_ad_appl.adm_ci_sequence_number%TYPE ;

  l_offer_dt  igs_ad_ps_appl_inst.offer_dt%TYPE;
  l_offer_response_dt igs_ad_ps_appl_inst.offer_response_dt%TYPE;

  l_message_name VARCHAR2(1000);
  l_new_admission_appl_number igs_ad_appl.admission_appl_number%TYPE;
  l_new_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE;
  cst_deferral	CONSTANT 	VARCHAR2(9) := 'DEFERRAL';
  cst_approved  CONSTANT        VARCHAR2(9) := 'APPROVED';

  l_person_number hz_parties.party_number%TYPE;
  l_group_desc igs_pe_persid_group.description%TYPE;


  ---End Variable Declarations--------------------------------------------------------------------------------------------

  -------------Cursor Declarations ----------------------------------------------------------------------------------------


  CURSOR c_pernum_cur IS
  SELECT
    person_number
  FROM
    igs_pe_person_base_v
  WHERE
    person_id = p_person_id;


  CURSOR c_pergr_cur IS
  SELECT
    description
  FROM
    igs_pe_persid_group
  WHERE
    group_id = p_group_id;

-- Cursor for getting the alternade academic/admission code for a given academic/admission cal type and sequence number

CURSOR acad_adm_alt_code (
  p_acad_cal_type igs_ca_inst.cal_type%TYPE,
  p_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
  p_adm_cal_type igs_ca_inst.cal_type%TYPE,
  p_adm_ci_sequence_number igs_ca_inst.sequence_number%TYPE
) IS
SELECT c1.alternate_code||' / '||c2.alternate_code
FROM igs_ca_inst c1, igs_ca_inst c2
WHERE c1.cal_type = p_acad_cal_type
AND c1.sequence_number = p_acad_ci_sequence_number
AND c2.cal_type = p_adm_cal_type
AND c2.sequence_number = p_adm_ci_sequence_number;

cur_acad_adm_alt_code VARCHAR2(200);
def_acad_adm_alt_code VARCHAR2(200);

  -- Cursor to get the current application attributes -----
  CURSOR c_appl_inst(p_person_id hz_parties.party_id%TYPE) IS
  SELECT
     acai.*
  FROM
     igs_ad_appl aa,
     igs_ad_ps_appl_inst acai,  /* Replaced igs_ad_ps_appl_inst_aplinst_v with base tables Bug 3150054 */
     igs_ad_ofr_resp_stat  aous,
     igs_ad_ofrdfrmt_stat  aods
  WHERE
       aa.person_id = acai.person_id
       AND aa.admission_appl_number = acai.admission_appl_number
       AND acai.adm_offer_resp_status = aous.adm_offer_resp_status
       AND      aous.s_adm_offer_resp_status = cst_deferral
       AND      acai.def_acad_cal_type = NVL(p_def_acad_cal_type, acai.def_acad_cal_type)
       AND      acai.def_acad_ci_sequence_num = NVL(p_def_acad_cal_seq_no, acai.def_acad_ci_sequence_num)
       AND      acai.deferred_adm_cal_type = NVL(p_def_adm_cal_type, acai.deferred_adm_cal_type)
       AND      acai.deferred_adm_ci_sequence_num = NVL(p_def_adm_cal_seq_no, acai.deferred_adm_ci_sequence_num)
       AND      acai.def_term_adm_appl_num IS NULL
       AND      acai.def_appl_sequence_num IS NULL
       AND      acai.person_id = p_person_id
       AND      acai.nominated_course_cd = NVL (p_nominated_course_cd, acai.nominated_course_cd)
       AND      aa.acad_cal_type = NVL ( p_prev_acad_cal_type, aa.acad_cal_type)
       AND      aa.acad_ci_sequence_number = NVL ( p_prev_acad_cal_seq_no, aa.acad_ci_sequence_number)
       AND      NVL(acai.adm_cal_type,aa.adm_cal_type) = NVL( p_prev_adm_cal_type,  acai.adm_cal_type)
       AND      NVL(acai.adm_ci_sequence_number,aa.adm_ci_sequence_number) = NVL ( p_prev_adm_cal_seq_no, acai.adm_ci_sequence_number)
       AND      acai.adm_offer_dfrmnt_status   = aods.adm_offer_dfrmnt_status
       AND      aods.s_adm_offer_dfrmnt_status IN ('APPROVED','CONFIRM');


   c_appl_inst_rec c_appl_inst%ROWTYPE;

   CURSOR c_group_id(p_person_id  hz_parties.party_id%TYPE,p_group_id igs_pe_persid_group.group_id%TYPE)  IS
        SELECT 'X'
	FROM igs_pe_prsid_grp_mem
	WHERE  person_id = p_person_id
	AND group_id = p_group_id
  AND NVL(TRUNC(start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
  AND NVL(TRUNC(end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);

  l_exists VARCHAR2(1);
  -- pfotedar bug no. 3713735
  l_query VARCHAR2(1000);
  TYPE c_ref_cur_typ IS REF CURSOR;
  c_ref_cur c_ref_cur_typ;
  TYPE c_ref_cur_rec_typ IS RECORD (person_id NUMBER);
  c_ref_cur_rec c_ref_cur_rec_typ;

 -- for bug 5245277 and sql id 17651648
 l_status VARCHAR2(1);
 l_group_type IGS_PE_PERSID_GROUP_V.group_type%type;

  -- End cursor declarations -----------------------------------------------------------------------------------------------
BEGIN

  -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
  igs_ge_gen_003.set_org_id(null);

  p_prev_acad_cal_type     := rtrim (substr (p_prev_acad_adm_cal, 1,10));
  p_prev_acad_cal_seq_no   := IGS_GE_NUMBER.TO_NUM(substr(p_prev_acad_adm_cal, 13,7));
  p_prev_adm_cal_type      := rtrim (substr (p_prev_acad_adm_cal, 23,10));
  p_prev_adm_cal_seq_no    := IGS_GE_NUMBER.TO_NUM (substr (p_prev_acad_adm_cal, 35,7));
  p_def_acad_cal_type      := rtrim (substr (p_def_acad_adm_cal, 1,10));
  p_def_acad_cal_seq_no    := IGS_GE_NUMBER.TO_NUM (substr (p_def_acad_adm_cal, 13,7));
  p_def_adm_cal_type       := rtrim (substr (p_def_acad_adm_cal, 23,10));
  p_def_adm_cal_seq_no     := IGS_GE_NUMBER.TO_NUM(substr (p_def_acad_adm_cal, 35,7));

 -- Cursor for getting the person number --rghosh bug#2767294
  OPEN c_pernum_cur;
  FETCH c_pernum_cur INTO l_person_number;
  CLOSE c_pernum_cur;

  --Cursor for getting the person group --rghosh bug#2767294
  OPEN c_pergr_cur;
  FETCH c_pergr_cur INTO l_group_desc;
  CLOSE c_pergr_cur;

 -- added the following lines for displaying the parameters person number, person id group and program --rghosh bug #2767294
  FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Person Number',38) || ' : ' || l_person_number);
  FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Person ID Group' ,38) || ' : ' || l_group_desc);
  FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Program',38) || ' : ' || p_nominated_course_cd);

  IF p_prev_acad_adm_cal IS NOT NULL THEN
    OPEN acad_adm_alt_code( p_prev_acad_cal_type,
							     p_prev_acad_cal_seq_no,
							     p_prev_adm_cal_type,
							     p_prev_adm_cal_seq_no);
    FETCH acad_adm_alt_code INTO cur_acad_adm_alt_code;
    CLOSE acad_adm_alt_code;
  END IF;

  IF p_def_acad_adm_cal IS NOT NULL THEN
    OPEN acad_adm_alt_code(p_def_acad_cal_type,
                                                             p_def_acad_cal_seq_no,
							     p_def_adm_cal_type,
							     p_def_adm_cal_seq_no);
    FETCH acad_adm_alt_code INTO def_acad_adm_alt_code;
    CLOSE acad_adm_alt_code;
  END IF;

 FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Current Academic / Admission Calendar',38) || ' : ' || cur_acad_adm_alt_code );
 FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Deferred Academic / Admission Calendar',38) || ' : ' || def_acad_adm_alt_code );

 l_offer_dt := igs_ge_date.igsdate(p_offer_dt);
 l_offer_response_dt := igs_ge_date.igsdate(p_offer_response_dt);

 FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Offer Date',38) || ' : ' || l_offer_dt);
 FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Override Offer Response Date',38) || ' : ' || l_offer_response_dt);
 FND_FILE.PUT_LINE(FND_FILE.LOG,'');

  -- check whether the parameter combination passed is correct
  -- if user  gives both person group and person
 -- then it should check whether the person exists in that group
 -- if the person doesnot exists, it gives a message --rghosh bug#2767294

  IF (p_group_id IS NULL AND p_person_id IS NULL)THEN
    fnd_file.put_line(fnd_file.log, 'Application could not be created');
    fnd_file.put_line(fnd_file.log, 'Either Person Number or Person ID Group should be passed');
  ELSIF (p_group_id IS NOT NULL AND p_person_id IS NOT NULL) THEN
    OPEN c_group_id(p_person_id,p_group_id);
    FETCH c_group_id INTO l_exists;
    IF c_group_id%NOTFOUND THEN
      fnd_file.put_line(fnd_file.log, 'Application could not be created');
      fnd_file.put_line(fnd_file.log, 'Person does not exists in the Person ID Group');
    END IF;
    CLOSE c_group_id;
  END IF;

  -- If the user wants to do the process for list of persons
  -- use the record group he has given in the parameter and iterate on the list
  -- of persons in the group

  IF p_group_id IS NOT NULL THEN

    ---- begin  bug 5245277 for sql id 17651648
    l_query := IGS_PE_DYNAMIC_PERSID_GROUP.GET_DYNAMIC_SQL(p_group_id, l_status, l_group_type);

    IF (l_query IS NOT NULL AND l_status ='S')
    THEN
    ---- end   bug 5245277 for sql id 17651648


	    IF p_person_id IS NOT NULL THEN     --When p_group_id is not null and p_person_id is not null

		    l_query :=  l_query || ' and person_id = :2';  --bug 5245277 and sql id 17651648
		    OPEN c_ref_cur FOR l_query USING p_group_id, p_person_id;
	    ELSE        --When p_group_id is not null and p_person_id is null
		    OPEN c_ref_cur FOR l_query USING p_group_id;
	    END IF;
	    LOOP
	      FETCH c_ref_cur INTO c_ref_cur_rec;
	      EXIT WHEN c_ref_cur%NOTFOUND;
		  -- Find out NOCOPY the list applications
		  FOR c_appl_inst_rec IN c_appl_inst(c_ref_cur_rec.person_id) LOOP

		  -- UPDATE the log file with application details
		  fnd_file.put_line(fnd_file.log, 'Creating Deferred Application for ' );
		  fnd_file.put_line(fnd_file.log,RPAD( ' Person Number',29) || ' : ' || get_person_number(IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.person_id)));
		  fnd_file.put_line(fnd_file.log, RPAD(' Admission Application Number',29) || ' : '  || IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.admission_appl_number));
		  fnd_file.put_line(fnd_file.log, RPAD(' Nominated course Code',29) || ' : '  || c_appl_inst_rec.nominated_course_cd);
		  fnd_file.put_line(fnd_file.log, RPAD(' Sequence Number',29) || ' : '  || IGS_GE_NUMBER.TO_CANN( c_appl_inst_rec.sequence_number ));

		  --  Call cmn_handle_application which will create application, copying child record
		  -- changing the entry qualification status , completness status and offer validations and update the same

		  cmn_handle_application(
			p_person_id		   => c_ref_cur_rec.person_id,
			p_admission_appl_number    => c_appl_inst_rec.admission_appl_number,
			p_nominated_course_cd      => c_appl_inst_rec.nominated_course_cd,
			p_sequence_number          => c_appl_inst_rec.sequence_number,
			p_def_acad_cal_type        => c_appl_inst_rec.def_acad_cal_type ,
			p_def_acad_cal_seq_no      => c_appl_inst_rec.def_acad_ci_sequence_num,
			p_def_adm_cal_type         => c_appl_inst_rec.deferred_adm_cal_type,
			p_def_adm_cal_seq_no       => c_appl_inst_rec.deferred_adm_ci_sequence_num,
			p_offer_dt                  => l_offer_dt,
			p_offer_response_dt         => l_offer_response_dt);
		  END LOOP;  -- end loop for loop application instances
	   END LOOP;
    END IF; -- if l_query is not null and status  ='S'
  ELSE
    -- This case will come into picture if the user has given only Person Id
    -- Find out NOCOPY the list applications
    FOR c_appl_inst_rec IN c_appl_inst(p_person_id) LOOP
      fnd_file.put_line(fnd_file.log, 'Creating Deferred Application for ' );
      fnd_file.put_line(fnd_file.log, RPAD(' Person Number',29) || ' : ' || get_person_number(IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.person_id)));
      fnd_file.put_line(fnd_file.log, RPAD(' Admission Application Number',29) || ' : '  || IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.admission_appl_number));
      fnd_file.put_line(fnd_file.log, RPAD(' Nominated course Code',29) || ' : '  || c_appl_inst_rec.nominated_course_cd);
      fnd_file.put_line(fnd_file.log, RPAD(' Sequence Number',29) || ' : '  || IGS_GE_NUMBER.TO_CANN( c_appl_inst_rec.sequence_number ));
	--  Call cmn_hanlde_applicaiton which will create application, copying child record
	-- changing the entry qualification status , completness status and offer validations and update the same
	cmn_handle_application(
                p_person_id		   => p_person_id,
                p_admission_appl_number    => c_appl_inst_rec.admission_appl_number,
                p_nominated_course_cd      => c_appl_inst_rec.nominated_course_cd,
                p_sequence_number          => c_appl_inst_rec.sequence_number,
                p_def_acad_cal_type        => c_appl_inst_rec.def_acad_cal_type ,
                p_def_acad_cal_seq_no      => c_appl_inst_rec.def_acad_ci_sequence_num,
                p_def_adm_cal_type         => c_appl_inst_rec.deferred_adm_cal_type,
                p_def_adm_cal_seq_no       => c_appl_inst_rec.deferred_adm_ci_sequence_num,
                p_offer_dt                  => l_offer_dt,
                p_offer_response_dt         => l_offer_response_dt);
    END LOOP;  -- end loop list of application instances
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    retcode:=2;
    errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    Igs_Ge_Msg_Stack.conc_exception_hndl;
    RETURN;
END admp_val_offer_defer_term;

PROCEDURE cmn_handle_application
      (
       p_person_id	hz_parties.party_id%TYPE,
       p_admission_appl_number  IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
       p_nominated_course_cd   IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
       p_sequence_number      IGS_AD_PS_APPL_INST.sequence_number%TYPE ,
       p_def_acad_cal_type    igs_ad_appl.acad_cal_type%TYPE ,
       p_def_acad_cal_seq_no   igs_ad_appl.acad_ci_sequence_number%TYPE,
       p_def_adm_cal_type      igs_ad_appl.adm_cal_type%TYPE,
       p_def_adm_cal_seq_no    igs_ad_appl.adm_ci_sequence_number%TYPE,
       p_offer_dt              igs_ad_ps_appl_inst.offer_dt%TYPE,
       p_offer_response_dt     igs_ad_ps_appl_inst.offer_response_dt%TYPE
       ) IS

 CURSOR cur_sys_offr_dfrmnt_status(p_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                                   p_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE,
				   p_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
				   p_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE) IS
 SELECT aods.s_adm_offer_dfrmnt_status
 FROM   igs_ad_ps_appl_inst apai,
        igs_ad_ofrdfrmt_stat_v aods
 WHERE  apai.person_id =p_person_id
   AND  apai.admission_appl_number =p_admission_appl_number
   AND  apai.nominated_course_cd =p_nominated_course_cd
   AND  apai.sequence_number =p_sequence_number
   AND  apai.adm_offer_dfrmnt_status = aods.adm_offer_dfrmnt_status ;

  l_message_name VARCHAR2(1000);
  l_new_admission_appl_number igs_ad_appl.admission_appl_number%TYPE;
  l_new_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE;
  l_s_adm_offer_dfrmnt_status igs_ad_ofrdfrmt_stat_v.s_adm_offer_dfrmnt_status%TYPE;

  v_start_dt DATE;

  CURSOR c_get_acad_cal_info(cp_person_id igs_ad_appl_all.person_id%TYPE,
                             cp_admission_appl_number igs_ad_appl_all.admission_appl_number%TYPE) IS
    SELECT acad_cal_type,acad_ci_sequence_number
    FROM igs_ad_appl_all
    WHERE person_id = cp_person_id
    AND admission_appl_number = cp_admission_appl_number;

  l_get_acad_cal_info c_get_acad_cal_info%ROWTYPE;

BEGIN
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To Create deferred term application , copy child records, copy entry and completness status , give offer with validation

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What

*******************************************************************************/
-- Set the save point here
-- Since when the application related transaction fails we need to rollback the transaction for that application
-- and it should proceed to the next record in the cursor
  SAVEPOINT sp_save_point1;

-- Call handle application
-- this procedure returns true if the application, application program and application instance insert is success
-- otherwise it returns FALSE.  This procedure also inserts the new application and instances for the deferred term
-- if the new application is created it returns the new admission application number and new sequence number as an
-- out NOCOPY parameter. This variables will be used for copying the child related records from the old to the new application
  IF handle_application(
          p_person_id                => p_person_id,
          p_admission_appl_number    => p_admission_appl_number,
          p_nominated_course_cd      => p_nominated_course_cd,
          p_sequence_number          => p_sequence_number,
          p_def_acad_cal_type        => p_def_acad_cal_type ,
          p_def_acad_cal_seq_no      => p_def_acad_cal_seq_no,
          p_def_adm_cal_type         => p_def_adm_cal_type,
          p_def_adm_cal_seq_no       => p_def_adm_cal_seq_no,
          p_new_admission_appl_number=> l_new_admission_appl_number,
          p_new_sequence_number      => l_new_sequence_number) THEN

          -- if the creation is successful then copy all the child records
          -- if any error occurs during copying of any of the child record
          -- rollback upto save point 1 and proceed the next record in the cursor
	  -- Note :  copy child records for future term application has been called
	  -- from here. Because same functionality is being done there also
	  -- If we pass p_process as 'D' , it will make all the fee details
	  -- record's applicant_fee_status to 'WAIVED'

    OPEN c_get_acad_cal_info(p_person_id,l_new_admission_appl_number);
    FETCH c_get_acad_cal_info INTO l_get_acad_cal_info;
    CLOSE c_get_acad_cal_info;


    v_start_dt := igs_en_gen_002.enrp_get_acad_comm(
                            l_get_acad_cal_info.acad_cal_type,
                            l_get_acad_cal_info.acad_ci_sequence_number,
                            p_person_id,
                            p_nominated_course_cd,
                            l_new_admission_appl_number,
                            p_nominated_course_cd,
                            l_new_sequence_number,
                            'Y');

    IF IGS_AD_VAL_ACAI_FTR_OFFER.copy_child_records(
          p_new_admission_appl_number      => l_new_admission_appl_number,
          p_new_sequence_number            => l_new_sequence_number,
          p_person_id                      => p_person_id,
          p_old_admission_appl_number      => p_admission_appl_number,
          p_old_sequence_number            => p_sequence_number,
          p_nominated_course_cd            => p_nominated_course_cd,
          p_start_dt                       => v_start_dt,
      	  p_process                        => 'D') THEN

      -- if all the validations and copying is successful then update the entry and doc status from old applicaiton to new future term
      IF copy_entrycomp_qual_status(p_person_id => p_person_id,
                                p_nominated_course_cd => p_nominated_course_cd,
                                p_admission_appl_number => p_admission_appl_number,
                                p_sequence_number => p_sequence_number,
                                p_new_admission_appl_number => l_new_admission_appl_number,
                                p_new_sequence_number => l_new_sequence_number ) THEN
        -- do the offer validation and update the out NOCOPY come status to offer
        IF validate_offer_validations(p_person_id       => p_person_id,
                                    p_nominated_course_cd       => p_nominated_course_cd,
                                    p_admission_appl_number     => l_new_admission_appl_number,
                                    p_sequence_number           => l_new_sequence_number,
                                    p_old_admission_appl_number => p_admission_appl_number,
                                    p_old_sequence_number       => p_sequence_number,
                                    p_offer_dt                  => p_offer_dt,
                                    p_offer_response_dt         => p_offer_response_dt,
                                    p_def_acad_cal_type         => p_def_acad_cal_type,
                                    p_def_acad_cal_seq_no       =>  p_def_acad_cal_seq_no,
                                    p_def_adm_cal_type          => p_def_adm_cal_type,
                                    p_def_adm_cal_seq_no        => p_def_adm_cal_seq_no,
                                    p_start_dt                  => v_start_dt
                                    ) THEN
					  OPEN   cur_sys_offr_dfrmnt_status(p_person_id,p_admission_appl_number,
									p_nominated_course_cd,p_sequence_number);
				    	  FETCH  cur_sys_offr_dfrmnt_status INTO l_s_adm_offer_dfrmnt_status;
					  CLOSE  cur_sys_offr_dfrmnt_status;
					  IF l_s_adm_offer_dfrmnt_status = 'CONFIRM' THEN
					       IF  NOT Update_offer_response_accepted(p_person_id       => p_person_id,
								    p_admission_appl_number     => l_new_admission_appl_number,
								    p_nominated_course_cd       => p_nominated_course_cd,
								    p_sequence_number           => l_new_sequence_number)
					       THEN

							ROLLBACK TO sp_save_point1;   -- to rollback, if response cannot be set to ACCEPTED
					       END IF;

					 END IF;
         ELSE
          ROLLBACK TO sp_save_point1;
        END IF;
      ELSE
        ROLLBACK TO sp_save_point1;
      END IF;
    ELSE  -- Else if the child record copy failed
      ROLLBACK TO sp_save_point1;
    END IF;  -- End if for Copy Child Records
  ELSE  -- Application Creation Failed
    ROLLBACK TO sp_save_point1;
  END IF;  -- End if for handle application
END cmn_handle_application;

FUNCTION handle_application(
                                        p_person_id hz_parties.party_id%TYPE,
                                        p_admission_appl_number igs_ad_appl.admission_appl_number%TYPE,
                                        p_nominated_course_cd  igs_ad_ps_appl.nominated_course_cd%TYPE,
                                        p_sequence_number  igs_ad_ps_appl_inst.sequence_number%TYPE,
                                        p_def_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                                        p_def_acad_cal_seq_no igs_ad_appl.acad_ci_sequence_number%TYPE,
                                        p_def_adm_cal_type igs_ad_appl.adm_cal_type%TYPE,
                                        p_def_adm_cal_seq_no igs_ad_appl.adm_ci_sequence_number%TYPE,
                                        p_new_admission_appl_number OUT NOCOPY igs_ad_appl.admission_appl_number%TYPE,
                                        p_new_sequence_number OUT NOCOPY igs_ad_ps_appl_inst.sequence_number%TYPE
                                    )  RETURN BOOLEAN IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To Create deferred term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
rboddu          04-OCT-2002     Creating application with Application_Type. Bug :2599457
nsinha          15-Nov-2002     Bug :2664410 - Release Of Build For Adcr049 - Alternate Application Id.
				* In Function handle_application:
				* Passed p_alt_appl_id parameter to igs_ad_gen_014.insert_adm_appl
pbondugu  28-Mar-2003    Passed  funding_source as NULL   to procedure call IGS_AD_GEN_014.insert_adm_appl_prog_inst
*******************************************************************************/
  -- Cursor Declarations-------------------------------------------------------------------
  -- Cursor to get the applications
  CURSOR c_appl_inst IS
  SELECT
    acai.*,
    aa.appl_dt, aa.admission_cat, aa.s_admission_process_type,
    aa.spcl_grp_1, aa.spcl_grp_2,aa.common_app,
    aa.adm_appl_status, aa.choice_number, aa.routeb_pref,
    aa.application_type, aa.adm_fee_status, aa.alt_appl_id,
    aa.acad_cal_type, aa.acad_ci_sequence_number,
    aca.admission_cd, aca.transfer_course_cd,
    aca.basis_for_admission_type,aca.req_for_reconsideration_ind,
    aca.req_for_adv_standing_ind,
    NVL(acai.adm_cal_type,aa.adm_cal_type) final_adm_cal_type,
    NVL(acai.adm_ci_sequence_number,aa.adm_ci_sequence_number) final_adm_ci_sequence_number
  FROM
    igs_ad_ps_appl_inst acai, /* Replaced igs_ad_ps_appl_inst_aplinst_v with base tables Bug 3150054 */
    igs_ad_appl aa,
    igs_ad_ps_appl aca
  WHERE
  acai.admission_appl_number = p_admission_appl_number
  AND acai.sequence_number = p_sequence_number
  AND acai.nominated_course_cd = p_nominated_course_cd
  AND aa.person_id = acai.person_id
  AND aa.admission_appl_number = acai.admission_appl_number
  AND acai.person_id = p_person_id
  AND aca.person_id = acai.person_id
  AND aca.admission_appl_number = acai.admission_appl_number
  AND aca.nominated_course_cd = acai.nominated_course_cd;


  CURSOR c_sys_def_appl_type(cp_adm_cat igs_ad_appl_all.admission_cat%TYPE,
                             cp_s_adm_prc_typ  igs_ad_appl_all.s_admission_process_type%TYPE
                             )
  IS
  SELECT admission_application_type
	FROM igs_ad_ss_appl_typ
	WHERE admission_cat = cp_adm_cat
  AND S_admission_process_type = cp_s_adm_prc_typ
  AND System_default = 'Y'
  AND NVL(closed_ind, 'N') <> 'Y';

  -----End cursor Declarations------------------------------------------------------------------

  -------------------Variable Declarations------------------------------------------------------
  l_message_name VARCHAR2(1000);
  l_adm_fee_status  igs_ad_appl.adm_fee_status%TYPE;
  l_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE;
  l_return_type  VARCHAR2(100);
  l_error_code  VARCHAR2(100);
  l_adm_appl_status igs_ad_appl.adm_appl_status%TYPE;
  l_admission_appl_number igs_ad_appl.admission_appl_number%TYPE;
  l_application_type igs_ad_appl_all.application_type%TYPE;
  ------------------- End Variable Declarations------------------------------------------------------
BEGIN
  FOR c_appl_inst_rec IN c_appl_inst LOOP

    l_application_type:= c_appl_inst_rec.application_type;
    --If Application Type of existing Deferred Application is NULL, then take the System Default Application Type
    -- And create the application with this application type. -- Added as part of 2599457
    IF l_application_type IS NULL THEN
      OPEN c_sys_def_appl_type(c_appl_inst_rec.admission_cat,c_appl_inst_rec.s_admission_process_type);
      FETCH c_sys_def_appl_type INTO l_application_type;
      CLOSE c_sys_def_appl_type;
    END IF;
    -- Create Admission application
    IF igs_ad_gen_014.insert_adm_appl(
      p_person_id                    => p_person_id,
      p_appl_dt                      => c_appl_inst_rec.appl_dt,
      p_acad_cal_type                => p_def_acad_cal_type ,
      p_acad_ci_sequence_number      => p_def_acad_cal_seq_no ,
      p_adm_cal_type                 => p_def_adm_cal_type ,
      p_adm_ci_sequence_number       => p_def_adm_cal_seq_no ,
      p_admission_cat                => c_appl_inst_rec.admission_cat,
      p_s_admission_process_type     => c_appl_inst_rec.s_admission_process_type,
      p_adm_appl_status              => igs_ad_gen_008.admp_get_sys_aas('RECEIVED'), -- Bug no 2744528 by rrengara
-- When ever we create an application it should be in received status
-- In case the deferred application has the single instance and the offer deferment status is confirmed
-- at save the appl processing status becomes complete.
-- So if the old processing status is passed to the new application, it will not create application with
-- complete status.
      p_adm_fee_status               => c_appl_inst_rec.adm_fee_status,  --IN/OUT
      p_tac_appl_ind                 => 'N',
      p_adm_appl_number              => l_admission_appl_number, --OUT
      p_message_name                 => l_message_name,  --OUT
      p_spcl_grp_1                   => c_appl_inst_rec.spcl_grp_1,
      p_spcl_grp_2                   => c_appl_inst_rec.spcl_grp_2,
      p_common_app                   => c_appl_inst_rec.common_app,
      p_application_type             => l_application_type, -- Added as part of 2599457
      p_choice_number                => c_appl_inst_rec.choice_number,
      p_routeb_pref                  => c_appl_inst_rec.routeb_pref,
      p_alt_appl_id                  => c_appl_inst_rec.alt_appl_id ) = FALSE THEN

      fnd_file.put_line(fnd_file.log, 'Application could not be created');
      fnd_message.set_name('IGS', l_message_name);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN FALSE;

    ELSE  -- Else for Application
      IF IGS_AD_GEN_014.insert_adm_appl_prog(
                p_person_id=> p_person_id,
                p_adm_appl_number=>l_admission_appl_number,
                p_nominated_course_cd=>p_nominated_course_cd,
                p_transfer_course_cd=>c_appl_inst_rec.transfer_course_cd,
                p_basis_for_admission_type=>c_appl_inst_rec.basis_for_admission_type,
                p_admission_cd=>c_appl_inst_rec.admission_cd,
                p_req_for_reconsideration_ind=> c_appl_inst_rec.req_for_reconsideration_ind,
                p_req_for_adv_standing_ind=> c_appl_inst_rec.req_for_adv_standing_ind,
                p_message_name => l_message_name) THEN

             -- Create Admission Application Porgram Instance
        IF IGS_AD_GEN_014.insert_adm_appl_prog_inst (
                p_person_id=>p_person_id,
                p_admission_appl_number=>l_admission_appl_number,
                p_acad_cal_type=>p_def_acad_cal_type,
                p_acad_ci_sequence_number=>p_def_acad_cal_seq_no ,
                p_adm_cal_type=>p_def_adm_cal_type ,
                p_adm_ci_sequence_number=>p_def_adm_cal_seq_no,
                p_admission_cat=>c_appl_inst_rec.admission_cat,
                p_s_admission_process_type=>c_appl_inst_rec.s_admission_process_type,
                p_appl_dt=>c_appl_inst_rec.appl_dt,
                p_adm_fee_status=>c_appl_inst_rec.adm_fee_status,
                p_preference_number=>c_appl_inst_rec.preference_number,
                p_offer_dt=>NULL,
                p_offer_response_dt=>NULL,
                p_course_cd=>c_appl_inst_rec.nominated_course_cd,
                p_crv_version_number=>c_appl_inst_rec.crv_version_number,
                p_location_cd=>c_appl_inst_rec.location_cd,
                p_attendance_mode=>c_appl_inst_rec.attendance_mode,
                p_attendance_type=>c_appl_inst_rec.attendance_type,
                p_unit_set_cd=>c_appl_inst_rec.unit_set_cd,
                p_us_version_number=>c_appl_inst_rec.us_version_number,
                p_fee_cat=>c_appl_inst_rec.fee_cat,
                p_correspondence_cat=>c_appl_inst_rec.correspondence_cat,
                p_enrolment_cat=>c_appl_inst_rec.enrolment_cat,
		            p_funding_source=>c_appl_inst_rec.funding_source,
                p_edu_goal_prior_enroll=>c_appl_inst_rec.edu_goal_prior_enroll_id,
                p_app_source_id=>c_appl_inst_rec.app_source_id,
                p_apply_for_finaid=>c_appl_inst_rec.apply_for_finaid,
                p_finaid_apply_date=>c_appl_inst_rec.finaid_apply_date,
                p_attribute_category=>c_appl_inst_rec.attribute_category,
                p_attribute1=>c_appl_inst_rec.attribute1,
                p_attribute2=>c_appl_inst_rec.attribute2,
                p_attribute3=>c_appl_inst_rec.attribute3,
                p_attribute4=>c_appl_inst_rec.attribute4,
                p_attribute5=>c_appl_inst_rec.attribute5,
                p_attribute6=>c_appl_inst_rec.attribute6,
                p_attribute7=>c_appl_inst_rec.attribute7,
                p_attribute8=>c_appl_inst_rec.attribute8,
                p_attribute9=>c_appl_inst_rec.attribute9,
                p_attribute10=>c_appl_inst_rec.attribute10,
                p_attribute11=>c_appl_inst_rec.attribute11,
                p_attribute12=>c_appl_inst_rec.attribute12,
                p_attribute13=>c_appl_inst_rec.attribute13,
                p_attribute14=>c_appl_inst_rec.attribute14,
                p_attribute15=>c_appl_inst_rec.attribute15,
                p_attribute16=>c_appl_inst_rec.attribute16,
                p_attribute17=>c_appl_inst_rec.attribute17,
                p_attribute18=>c_appl_inst_rec.attribute18,
                p_attribute19=>c_appl_inst_rec.attribute19,
                p_attribute20=>c_appl_inst_rec.attribute20,
                p_attribute21=>c_appl_inst_rec.attribute21,
                p_attribute22=>c_appl_inst_rec.attribute22,
                p_attribute23=>c_appl_inst_rec.attribute23,
                p_attribute24=>c_appl_inst_rec.attribute24,
                p_attribute25=>c_appl_inst_rec.attribute25,
                p_attribute26=>c_appl_inst_rec.attribute26,
                p_attribute27=>c_appl_inst_rec.attribute27,
                p_attribute28=>c_appl_inst_rec.attribute28,
                p_attribute29=>c_appl_inst_rec.attribute29,
                p_attribute30=>c_appl_inst_rec.attribute30,
                p_attribute31=>c_appl_inst_rec.attribute31,
                p_attribute32=>c_appl_inst_rec.attribute32,
                p_attribute33=>c_appl_inst_rec.attribute33,
                p_attribute34=>c_appl_inst_rec.attribute34,
                p_attribute35=>c_appl_inst_rec.attribute35,
                p_attribute36=>c_appl_inst_rec.attribute36,
                p_attribute37=>c_appl_inst_rec.attribute37,
                p_attribute38=>c_appl_inst_rec.attribute38,
                p_attribute39=>c_appl_inst_rec.attribute39,
                p_attribute40=>c_appl_inst_rec.attribute40,
                p_ss_application_id =>NULL,
                p_sequence_number   =>l_sequence_number,
                p_return_type       =>l_return_type,
                p_error_code        =>l_error_code,
                p_message_name      =>l_message_name,
                p_entry_status      =>c_appl_inst_rec.entry_status,
                p_entry_level       =>c_appl_inst_rec.entry_level,
                p_sch_apl_to_id     =>c_appl_inst_rec.sch_apl_to_id) THEN
                p_new_admission_appl_number := l_admission_appl_number;
                p_new_sequence_number := l_sequence_number;
                RETURN TRUE;
        ELSE  -- Else of Application Instance
          IF l_message_name  IN ('IGS_AD_NOMINATE_PRG_OFR_ENTRY', 'IGS_AD_NOMINATED_PRG_ENTRYPNT') THEN
            l_message_name := 'IGS_AD_CAL_PGM_NOT_OFFER';
            fnd_message.set_name('IGS', l_message_name);
            fnd_message.set_token('PGM', c_appl_inst_rec.nominated_course_cd);
            fnd_message.set_token('ALTCODE', c_appl_inst_rec.acad_cal_type || ',' || IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.acad_ci_sequence_number)
                                  || '/' || c_appl_inst_rec.final_adm_cal_type || ',' || IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.final_adm_ci_sequence_number) );
            fnd_file.put_line(fnd_file.log, 'Application could not be created');
	    fnd_file.put_line(fnd_file.log, fnd_message.get);
          ELSE
            fnd_file.put_line(fnd_file.log, 'Application could not be created');
            fnd_message.set_name('IGS', l_message_name);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
          END IF;
          RETURN FALSE;
        END IF;
        RETURN FALSE;
      ELSE  -- Else for Application Program
        fnd_file.put_line(fnd_file.log, 'Application could not be created');
        fnd_message.set_name('IGS', l_message_name);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        RETURN FALSE;
      END IF;
    END IF;
  END LOOP;
  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log, 'Exception From handle application log ' ||   l_message_name);
    RETURN FALSE;
END handle_application;

FUNCTION validate_offer_validations(p_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                    p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                    p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                    p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                    p_old_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                    p_old_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                    p_offer_dt igs_ad_ps_appl_inst.offer_dt%TYPE,
                                    p_offer_response_dt igs_ad_ps_appl_inst.offer_response_dt%TYPE,
                                    p_def_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                                    p_def_acad_cal_seq_no igs_ad_appl.acad_ci_sequence_number%TYPE,
                                    p_def_adm_cal_type igs_ad_appl.adm_cal_type%TYPE,
                                    p_def_adm_cal_seq_no igs_ad_appl.adm_ci_sequence_number%TYPE,
                                    p_start_dt DATE
                                    ) RETURN BOOLEAN IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 6 SEP 2002

Purpose:
  To validate and update the outcome status to Offer

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
rrengara        30-oct-2002     Build core vs optional Bug 2647482 Pre enrollment's parameter unit set has been called with the function api
apadegal        06-oct-2005     Retruned false if pre-enrollment process fails
*******************************************************************************/
-- Cursor Declarations ----------------------------------------------------------------------------

  CURSOR c_appl_inst_old_cur IS
  SELECT
    apai.*
  FROM
    igs_ad_ps_appl_inst apai
  WHERE
    apai.person_id   = p_person_id
    AND apai.admission_appl_number  =  p_old_admission_appl_number
    AND apai.nominated_course_cd     =   p_nominated_course_cd
    AND apai.sequence_number   = p_old_sequence_number;

 c_appl_inst_old_rec c_appl_inst_old_cur%ROWTYPE;


  CURSOR c_appl_offer_cur IS
  SELECT
    acai.*,
    aa.appl_dt, aa.admission_cat, aa.s_admission_process_type,
    aa.spcl_grp_1, aa.spcl_grp_2,aa.common_app,
    aa.adm_appl_status, aa.choice_number, aa.routeb_pref,
    aa.application_type, aa.adm_fee_status, aa.alt_appl_id,
    aa.acad_cal_type, aa.acad_ci_sequence_number,
    NVL(acai.adm_cal_type,aa.adm_cal_type) final_adm_cal_type,
    NVL(acai.adm_ci_sequence_number,aa.adm_ci_sequence_number) final_adm_ci_sequence_number

  FROM
    igs_ad_ps_appl_inst acai, /* Replaced igs_ad_ps_appl_inst_aplinst_v with igs_ad_ps_appl_inst Bug 3150054 */
    igs_ad_appl aa
  WHERE
    acai.person_id = p_person_id
    AND acai.nominated_course_cd = p_nominated_course_cd
    AND acai.sequence_number = p_sequence_number
    AND acai.admission_appl_number = p_admission_appl_number
    AND aa.person_id = acai.person_id
    AND aa.admission_appl_number = acai.admission_appl_number;

  CURSOR c_admcat_cur IS
  SELECT
    admission_cat, s_admission_process_type, appl_dt
  FROM
    igs_ad_appl
  WHERE
    person_id = p_person_id AND
    admission_appl_number = p_admission_appl_number;

  c_admcat_rec c_admcat_cur%ROWTYPE;

  CURSOR c_apcs_cur (
        cp_admission_cat              igs_ad_prcs_cat_step.admission_cat%TYPE,
        cp_s_admission_process_type   igs_ad_prcs_cat_step.s_admission_process_type%TYPE
            )
  IS
  SELECT
    s_admission_step_type, step_type_restriction_num
  FROM
    igs_ad_prcs_cat_step
  WHERE
    admission_cat = cp_admission_cat
    AND s_admission_process_type = cp_s_admission_process_type
    AND step_group_type <> 'TRACK';

  CURSOR c_upd_acai_cur IS
  SELECT
    ROWID, APAI.*
  FROM
    igs_ad_ps_appl_inst apai
  WHERE
    apai.person_id   = p_person_id
    AND apai.admission_appl_number  =  p_admission_appl_number
    AND apai.nominated_course_cd     =   p_nominated_course_cd
    AND apai.sequence_number   = p_sequence_number;
 -- End Cursor Declarations ----------------------------------------------------------------------------

 -- Variable Declarations -------------------------------------------------------------------------------

  l_offer_response_dt  igs_ad_ps_appl_inst.offer_response_dt%TYPE;
  v_pref_allowed_ind               VARCHAR2 (1);
  v_pref_limit                     NUMBER;
  v_cond_offer_doc_allowed_ind     VARCHAR2 (1);
  v_cond_offer_fee_allowed_ind     VARCHAR2 (1);
  v_cond_offer_ass_allowed_ind     VARCHAR2 (1);
  v_late_appl_allowed_ind          VARCHAR2 (1);
  v_late_fees_required_ind         VARCHAR2 (1);
  v_fees_required_ind              VARCHAR2 (1);
  v_override_outcome_allowed_ind   VARCHAR2 (1);
  v_set_outcome_allowed_ind        VARCHAR2 (1);
  v_mult_offer_allowed_ind         VARCHAR2 (1);
  v_multi_offer_limit              NUMBER;
  v_unit_set_appl_ind              VARCHAR2 (1);
  v_check_person_encumb            VARCHAR2 (1);
  v_check_course_encumb            VARCHAR2 (1);
  v_deferral_allowed_ind           VARCHAR2 (1);
  v_pre_enrol_ind                  VARCHAR2 (1);
  v_warn_level  VARCHAR2(10);
  v_message_name VARCHAR2(100);
  l_adm_cat IGS_AD_APPL.admission_cat%TYPE;
  l_s_adm_process_type IGS_AD_APPL.s_admission_process_type%TYPE;
  l_appl_dt  IGS_AD_APPL.appl_dt%TYPE;
  cst_offer			CONSTANT 	VARCHAR2(9) := 'OFFER';
  cst_received			CONSTANT 	VARCHAR2(9) := 'RECEIVED';
  cst_pending			CONSTANT 	VARCHAR2(9) := 'PENDING';
  -- End Variable Declarations -------------------------------------------------------------------------------

BEGIN

  v_pref_allowed_ind              := 'N';
  v_cond_offer_doc_allowed_ind    := 'N';
  v_cond_offer_fee_allowed_ind    := 'N';
  v_cond_offer_ass_allowed_ind    := 'N';
  v_late_appl_allowed_ind         := 'N';
  v_late_fees_required_ind        := 'N';
  v_fees_required_ind             := 'N';
  v_override_outcome_allowed_ind  := 'N';
  v_set_outcome_allowed_ind       := 'N';
  v_mult_offer_allowed_ind        := 'N';
  v_unit_set_appl_ind             := 'N';
  v_check_person_encumb           := 'N';
  v_check_course_encumb           := 'N';
  v_deferral_allowed_ind          := 'N';
  v_pre_enrol_ind                 := 'N';

  FOR c_appl_offer_rec IN c_appl_offer_cur LOOP
    OPEN c_admcat_cur;
    FETCH c_admcat_cur INTO l_adm_cat, l_s_adm_process_type, l_appl_dt;
    CLOSE c_admcat_cur;

    -- This cursor has to be opened to copy the decision related values to the new application

    OPEN c_appl_inst_old_cur;
    FETCH c_appl_inst_old_cur INTO c_appl_inst_old_rec;
    CLOSE c_appl_inst_old_cur;
    --
    -- Determine the admission process category steps.
    --
    FOR l_c_apcs_rec IN c_apcs_cur (
      l_adm_cat,
      l_s_adm_process_type)  LOOP
      IF l_c_apcs_rec.s_admission_step_type = 'CHKCENCUMB' THEN
        v_check_course_encumb := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'CHKPENCUMB' THEN
        v_check_person_encumb := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'PREF-LIMIT'  THEN
        v_pref_allowed_ind := 'Y';
        v_pref_limit := l_c_apcs_rec.step_type_restriction_num;

      ELSIF l_c_apcs_rec.s_admission_step_type = 'DOC-COND'  THEN
        v_cond_offer_doc_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'FEE-COND' THEN
        v_cond_offer_fee_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'ASSES-COND' THEN
        v_cond_offer_ass_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'LATE-APP' THEN
        v_late_appl_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'LATE-FEE' THEN
        v_late_fees_required_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'APP-FEE' THEN
        v_fees_required_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'OVERRIDE-O'  THEN
        v_override_outcome_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'SET-OTCOME' THEN
        v_set_outcome_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'MULTI-OFF'  THEN
        v_mult_offer_allowed_ind := 'Y';
        v_multi_offer_limit := l_c_apcs_rec.step_type_restriction_num;

      ELSIF l_c_apcs_rec.s_admission_step_type = 'UNIT-SET' THEN
        v_unit_set_appl_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'DEFER' THEN
        v_deferral_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'PRE-ENROL' THEN
        v_pre_enrol_ind := 'Y';
      END IF;
    END LOOP;
    IF IGS_AD_VAL_ACAI.admp_val_offer_dt (
                        p_offer_dt,
                        igs_ad_gen_009.admp_get_sys_aos(cst_offer),
                        c_appl_offer_rec.adm_cal_type,
                        c_appl_offer_rec.adm_ci_sequence_number,
                        v_message_name) = FALSE THEN
         fnd_message.set_name('IGS', v_message_name);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;
     -- calculate the offer response date if the user doesn't passes the value
    IF p_offer_response_dt IS NULL THEN

      -- Calculate the Offer response date by calling the following procedure
      l_offer_response_dt := IGS_AD_GEN_007.ADMP_GET_RESP_DT (
                                c_appl_offer_rec.course_cd,
                                c_appl_offer_rec.crv_version_number,
                                c_appl_offer_rec.acad_cal_type,
                                c_appl_offer_rec.location_cd,
                                c_appl_offer_rec.attendance_mode,
                                c_appl_offer_rec.attendance_type,
                                l_adm_cat,
                                l_s_adm_process_type,
                                c_appl_offer_rec.adm_cal_type,
                                c_appl_offer_rec.adm_ci_sequence_number,
                                p_offer_dt );
    ELSE
      l_offer_response_dt := p_offer_response_dt;
    END IF;

    IF l_offer_response_dt IS NOT NULL THEN
      IF l_offer_response_dt < p_offer_dt THEN
         fnd_message.set_name('IGS', 'IGS_AD_OFR_RSPDT_GE_OFRDT');
         fnd_file.put_line(fnd_file.log, 'Application could not be created');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
	      RETURN FALSE;
      END IF;
    END IF;

    IF igs_ad_val_acai_status.admp_val_acai_aos (
               c_appl_offer_rec.person_id,
               c_appl_offer_rec.admission_appl_number,
               c_appl_offer_rec.nominated_course_cd,
               c_appl_offer_rec.sequence_number,
               c_appl_offer_rec.course_cd,
               c_appl_offer_rec.crv_version_number,
               c_appl_offer_rec.location_cd,
               c_appl_offer_rec.attendance_mode,
               c_appl_offer_rec.attendance_type,
               c_appl_offer_rec.unit_set_cd,
               c_appl_offer_rec.us_version_number,
               c_appl_offer_rec.acad_cal_type,
               c_appl_offer_rec.acad_ci_sequence_number,
               c_appl_offer_rec.adm_cal_type,
               c_appl_offer_rec.adm_ci_sequence_number,
               l_adm_cat,
               l_s_adm_process_type,
               l_appl_dt,
               c_appl_offer_rec.fee_cat,
               c_appl_offer_rec.correspondence_cat,
               c_appl_offer_rec.enrolment_cat,
               igs_ad_gen_009.admp_get_sys_aos(cst_offer),
               c_appl_offer_rec.adm_outcome_status,
               c_appl_offer_rec.adm_doc_status,
               c_appl_offer_rec.adm_fee_status,
               IGS_AD_GEN_008.ADMP_GET_SAFS(c_appl_inst_old_rec.late_adm_fee_status), -- passing the user defined late adm fee status of the old application instead of 'RECEIVED' (bug#3011405 , rghosh)
               c_appl_offer_rec.adm_cndtnl_offer_status,
               c_appl_offer_rec.adm_entry_qual_status,
               igs_ad_gen_009.admp_get_sys_aors(cst_pending),
               c_appl_offer_rec.adm_offer_resp_status,  --old
               c_appl_offer_rec.adm_outcome_status_auth_dt,
               v_set_outcome_allowed_ind,
               v_cond_offer_ass_allowed_ind,
               v_cond_offer_fee_allowed_ind,
               v_cond_offer_doc_allowed_ind,
               v_late_appl_allowed_ind,
               v_fees_required_ind,
               v_mult_offer_allowed_ind,
               v_multi_offer_limit,
               v_pref_allowed_ind,
               v_unit_set_appl_ind,
               v_check_person_encumb,
               v_check_course_encumb,
               'FORM',
               v_message_name
            ) THEN

      FOR c_upd_acai_rec IN c_upd_acai_cur LOOP

        -- Offer validations is successful then update the offer
        Igs_Ad_Ps_Appl_Inst_Pkg.UPDATE_ROW (
                                x_rowid                         => c_upd_acai_rec.row_id ,
                                x_person_id                     => c_upd_acai_rec.person_id ,
                                x_admission_appl_number         => c_upd_acai_rec.admission_appl_number ,
                                x_nominated_course_cd           => c_upd_acai_rec.nominated_course_cd ,
                                x_sequence_number               => c_upd_acai_rec.sequence_number ,
                                x_predicted_gpa                 => c_appl_inst_old_rec.predicted_gpa ,
                                x_academic_index                => c_appl_inst_old_rec.academic_index,
                                x_adm_cal_type                  => c_upd_acai_rec.adm_cal_type ,
                                x_app_file_location             => c_upd_acai_rec.app_file_location ,
                                x_adm_ci_sequence_number        => c_upd_acai_rec.adm_ci_sequence_number ,
                                x_course_cd                     => c_upd_acai_rec.course_cd ,
                                x_app_source_id                 => c_upd_acai_rec.app_source_id ,
                                x_crv_version_number            => c_upd_acai_rec.crv_version_number ,
                                x_waitlist_rank                 => c_upd_acai_rec.waitlist_rank,
                                x_waitlist_status               => c_upd_acai_rec.waitlist_status,
                                x_location_cd                   => c_upd_acai_rec.location_cd ,
                                x_attent_other_inst_cd          => c_upd_acai_rec.attent_other_inst_cd,
                                x_attendance_mode               => c_upd_acai_rec.attendance_mode ,
                                x_edu_goal_prior_enroll_id      => c_upd_acai_rec.edu_goal_prior_enroll_id,
                                x_attendance_type               => c_upd_acai_rec.attendance_type ,
                                x_decision_make_id              => c_appl_inst_old_rec.decision_make_id,
                                x_unit_set_cd                   => c_upd_acai_rec.unit_set_cd ,
                                x_decision_date                 => c_appl_inst_old_rec.decision_date,
                                x_attribute_category            => c_upd_acai_rec.attribute_category,
                                x_attribute1                    => c_upd_acai_rec.attribute1,
                                x_attribute2                    => c_upd_acai_rec.attribute2,
                                x_attribute3                    => c_upd_acai_rec.attribute3,
                                x_attribute4                    => c_upd_acai_rec.attribute4,
                                x_attribute5                    => c_upd_acai_rec.attribute5,
                                x_attribute6                    => c_upd_acai_rec.attribute6,
                                x_attribute7                    => c_upd_acai_rec.attribute7,
                                x_attribute8                    => c_upd_acai_rec.attribute8,
                                x_attribute9                    => c_upd_acai_rec.attribute9,
                                x_attribute10                   => c_upd_acai_rec.attribute10,
                                x_attribute11                   => c_upd_acai_rec.attribute11,
                                x_attribute12                   => c_upd_acai_rec.attribute12,
                                x_attribute13                   => c_upd_acai_rec.attribute13,
                                x_attribute14                   => c_upd_acai_rec.attribute14,
                                x_attribute15                   => c_upd_acai_rec.attribute15,
                                x_attribute16                   => c_upd_acai_rec.attribute16,
                                x_attribute17                   => c_upd_acai_rec.attribute17,
                                x_attribute18                   => c_upd_acai_rec.attribute18,
                                x_attribute19                   => c_upd_acai_rec.attribute19,
                                x_attribute20                   => c_upd_acai_rec.attribute20,
                                x_decision_reason_id            => c_appl_inst_old_rec.decision_reason_id,
                                x_us_version_number             => c_upd_acai_rec.us_version_number ,
                                x_decision_notes                => c_appl_inst_old_rec.decision_notes,
                                x_pending_reason_id             => c_upd_acai_rec.pending_reason_id,
                                x_preference_number             => c_upd_acai_rec.preference_number ,
                                x_adm_doc_status                => c_upd_acai_rec.adm_doc_status ,
                                x_adm_entry_qual_status         => c_upd_acai_rec.adm_entry_qual_status,
                                x_deficiency_in_prep            => c_upd_acai_rec.deficiency_in_prep ,
                                x_late_adm_fee_status           => c_appl_inst_old_rec.late_adm_fee_status , -- passing the user defined late adm fee status of the old application instead of 'RECEIVED' (bug#3011405 , rghosh)
                                x_spl_consider_comments         => c_upd_acai_rec.spl_consider_comments,
                                x_adm_outcome_status            => c_appl_inst_old_rec.adm_outcome_status,
                                x_adm_otcm_stat_auth_per_id     => c_upd_acai_rec.adm_otcm_status_auth_person_id ,
                                x_adm_outcome_status_auth_dt    => c_upd_acai_rec.adm_outcome_status_auth_dt ,
                                x_adm_outcome_status_reason     => c_upd_acai_rec.adm_outcome_status_reason ,
                                x_offer_dt                      => p_offer_dt,
                                x_offer_response_dt             => l_offer_response_dt,
                                x_prpsd_commencement_dt         => p_start_dt,
                                x_adm_cndtnl_offer_status       => c_appl_inst_old_rec.adm_cndtnl_offer_status ,
                                x_cndtnl_offer_satisfied_dt     => c_appl_inst_old_rec.cndtnl_offer_satisfied_dt ,
                                x_cndnl_ofr_must_be_stsfd_ind   => c_appl_inst_old_rec.cndtnl_offer_must_be_stsfd_ind ,
                                x_adm_offer_resp_status         => igs_ad_gen_009.admp_get_sys_aors(cst_pending),
                                x_actual_response_dt            => c_upd_acai_rec.actual_response_dt ,
                                x_adm_offer_dfrmnt_status       => c_upd_acai_rec.adm_offer_dfrmnt_status ,
                                x_deferred_adm_cal_type         => c_upd_acai_rec.deferred_adm_cal_type,
                                x_deferred_adm_ci_sequence_num  => c_upd_acai_rec.deferred_adm_ci_sequence_num  ,
                                x_deferred_tracking_id          => c_upd_acai_rec.deferred_tracking_id ,
                                x_ass_rank                      => c_upd_acai_rec.ass_rank ,
                                x_secondary_ass_rank            => c_upd_acai_rec.secondary_ass_rank ,
                                x_intr_accept_advice_num        => c_upd_acai_rec.intrntnl_acceptance_advice_num  ,
                                x_ass_tracking_id               => c_upd_acai_rec.ass_tracking_id ,
                                x_fee_cat                       => c_upd_acai_rec.fee_cat ,
                                x_hecs_payment_option           => c_upd_acai_rec.hecs_payment_option ,
                                x_expected_completion_yr        => c_upd_acai_rec.expected_completion_yr ,
                                x_expected_completion_perd      => c_upd_acai_rec.expected_completion_perd ,
                                x_correspondence_cat            => c_upd_acai_rec.correspondence_cat ,
                                x_enrolment_cat                 => c_upd_acai_rec.enrolment_cat ,
                                x_funding_source                => c_upd_acai_rec.funding_source ,
                                x_applicant_acptnce_cndtn       => c_upd_acai_rec.applicant_acptnce_cndtn ,
                                x_cndtnl_offer_cndtn            => c_upd_acai_rec.cndtnl_offer_cndtn ,
                                x_ss_application_id             => c_upd_acai_rec.ss_application_id,
                                x_ss_pwd                        => c_upd_acai_rec.ss_pwd,
                                x_authorized_dt                 => c_upd_acai_rec.authorized_dt,
                                x_authorizing_pers_id           => c_upd_acai_rec.authorizing_pers_id ,
                                x_idx_calc_date                 => c_appl_inst_old_rec.idx_calc_date,
                                x_mode                          => 'R',
                                x_fut_acad_cal_type             => NULL,--p_fut_acad_cal_type,
                                x_fut_acad_ci_sequence_number   => NULL,--p_fut_acad_cal_seq_no,
                                x_fut_adm_cal_type              => NULL,--p_fut_adm_cal_type,
                                x_fut_adm_ci_sequence_number    => NULL,--p_fut_adm_cal_seq_no ,
                                x_prev_term_adm_appl_number     => c_upd_acai_rec.previous_term_adm_appl_number,
                                x_prev_term_sequence_number     => c_upd_acai_rec.previous_term_sequence_number,
                                x_fut_term_adm_appl_number      => c_upd_acai_rec.future_term_adm_appl_number,
                                x_fut_term_sequence_number      => c_upd_acai_rec.future_term_sequence_number,
                        				x_def_acad_cal_type            => c_upd_acai_rec.def_acad_cal_type,
                								x_def_acad_ci_sequence_num      => c_upd_acai_rec.def_acad_ci_sequence_num,
                								x_def_prev_term_adm_appl_num   => p_old_admission_appl_number,
                								x_def_prev_appl_sequence_num  => p_old_sequence_number,
                								x_def_term_adm_appl_num   => c_upd_acai_rec.def_term_adm_appl_num,
                								x_def_appl_sequence_num   => c_upd_acai_rec.def_appl_sequence_num,
                						-- Added entry Status, entry level and school applying id and fin aid columns here for Bug 2631843
                						-- by rrengara on 2-DEC-2002
                		x_entry_status                  => c_appl_inst_old_rec.entry_status,
                		x_entry_level                   => c_appl_inst_old_rec.entry_level,
                		x_sch_apl_to_id                 => c_appl_inst_old_rec.sch_apl_to_id,
                		x_apply_for_finaid              => c_appl_inst_old_rec.apply_for_finaid,
                		x_finaid_apply_date             => c_appl_inst_old_rec.finaid_apply_date,
				x_appl_inst_status		=> c_appl_inst_old_rec.appl_inst_status,
				x_ais_reason			=> c_appl_inst_old_rec.ais_reason,
				x_decline_ofr_reason		=> c_appl_inst_old_rec.decline_ofr_reason
                		);
      END LOOP;

      -- Run the pre-enrollment process
      IF v_pre_enrol_ind = 'Y' THEN
        -- Validate the Enrollment Category mapping
        IF IGS_AD_VAL_ACAI.admp_val_acai_ec (
                         l_adm_cat,
                         c_appl_offer_rec.enrolment_cat,
                         v_message_name) = FALSE THEN
          fnd_message.set_name('IGS', v_message_name);
          fnd_file.put_line(fnd_file.log, 'Application could not be created');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RETURN FALSE;
        END IF;

      	-- rrengara
        -- on 28-oct-2002 for Build Core Vs optional Bug 2647482
      	-- get the unit set mapping by calling the apc for the application
      	-- then pass the value to the Pre-enrollment procedure for the parameter p_units_indicator

        IF igs_ad_upd_initialise.perform_pre_enrol(
             c_appl_offer_rec.person_id,
             c_appl_offer_rec.admission_appl_number,
             c_appl_offer_rec.nominated_course_cd,
             c_appl_offer_rec.sequence_number,
             'N',                     -- Confirm course indicator.
             'N',                     -- Perform eligibility check indicator.
             v_message_name) = FALSE THEN
          fnd_message.set_name('IGS', v_message_name);
          fnd_file.put_line(fnd_file.log, 'Application could not be created');  -- added - apadegal adtd001 igs.m
          fnd_file.put_line(fnd_file.log, fnd_message.get);
	  RETURN FALSE;								-- added - apadegal adtd001 igs.m
        END IF;
      END IF;  -- PRE-ENROLL IND = 'Y'
    ELSE
      IF v_message_name  IN ('IGS_AD_NOMINATE_PRG_OFR_ENTRY', 'IGS_AD_NOMINATED_PRG_ENTRYPNT') THEN
        v_message_name := 'IGS_AD_CAL_PGM_NOT_OFFER';
        fnd_message.set_name('IGS', v_message_name);
        fnd_message.set_token('PGM', c_appl_offer_rec.nominated_course_cd);
        fnd_message.set_token('ALTCODE', c_appl_offer_rec.acad_cal_type || ',' || IGS_GE_NUMBER.TO_CANN(c_appl_offer_rec.acad_ci_sequence_number)
                              || '/' || c_appl_offer_rec.final_adm_cal_type || ',' || IGS_GE_NUMBER.TO_CANN(c_appl_offer_rec.final_adm_ci_sequence_number) );
        fnd_file.put_line(fnd_file.log, 'Application could not be created');
	      fnd_file.put_line(fnd_file.log, fnd_message.get);
      ELSE
        fnd_file.put_line(fnd_file.log, 'Application could not be created');
        fnd_message.set_name('IGS', v_message_name);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
      END IF;
      RETURN FALSE;
    END IF;
  END LOOP;
  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log, 'Error from validate_offer_validations: '  || SQLERRM);
  fnd_file.put_line(fnd_file.log, 'Person Number : ' || get_person_number(IGS_GE_NUMBER.TO_CANN(p_person_id)));
  fnd_file.put_line(fnd_file.log, 'Admission Appl Number : ' || IGS_GE_NUMBER.TO_CANN(p_admission_appl_number));
  fnd_file.put_line(fnd_file.log, 'Nominated Course Code : ' || p_nominated_course_cd);
  fnd_file.put_line(fnd_file.log, 'Sequence Number : ' || p_sequence_number);
  RETURN FALSE;
END validate_offer_validations;

FUNCTION copy_entrycomp_qual_status(p_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                p_new_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                p_new_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE ) RETURN BOOLEAN IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 06 SEP 2002

Purpose:
  To update entry qualification status and compleness status

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
  CURSOR c_upd_acai_new_cur IS
  SELECT
    apai.*
  FROM
    igs_ad_ps_appl_inst apai
  WHERE
    apai.person_id   = p_person_id
    AND apai.admission_appl_number  =  p_new_admission_appl_number
    AND apai.nominated_course_cd     =   p_nominated_course_cd
    AND apai.sequence_number   = p_new_sequence_number;


  CURSOR c_upd_acai_old_cur IS
  SELECT
    apai.*
  FROM
    igs_ad_ps_appl_inst apai
  WHERE
    apai.person_id   = p_person_id
    AND apai.admission_appl_number  =  p_admission_appl_number
    AND apai.nominated_course_cd     =   p_nominated_course_cd
    AND apai.sequence_number   = p_sequence_number;

  cst_received			CONSTANT 	VARCHAR2(9) := 'RECEIVED';

BEGIN

  -- This procedure updates only entry qualification status from old to new future term application
  FOR c_upd_acai_old_rec IN c_upd_acai_old_cur LOOP
    FOR c_upd_acai_new_rec IN c_upd_acai_new_cur LOOP
      Igs_Ad_Ps_Appl_Inst_Pkg.UPDATE_ROW (
                                x_rowid                         => c_upd_acai_new_rec.row_id ,
                                x_person_id                     => c_upd_acai_new_rec.person_id ,
                                x_admission_appl_number         => c_upd_acai_new_rec.admission_appl_number ,
                                x_nominated_course_cd           => c_upd_acai_new_rec.nominated_course_cd ,
                                x_sequence_number               => c_upd_acai_new_rec.sequence_number ,
                                x_predicted_gpa                 => c_upd_acai_new_rec.predicted_gpa ,
                                x_academic_index                => c_upd_acai_old_rec.academic_index,
                                x_adm_cal_type                  => c_upd_acai_new_rec.adm_cal_type ,
                                x_app_file_location             => c_upd_acai_old_rec.app_file_location ,
                                x_adm_ci_sequence_number        => c_upd_acai_new_rec.adm_ci_sequence_number ,
                                x_course_cd                     => c_upd_acai_new_rec.course_cd ,
                                x_app_source_id                 => c_upd_acai_new_rec.app_source_id ,
                                x_crv_version_number            => c_upd_acai_new_rec.crv_version_number ,
                                x_waitlist_rank                 => c_upd_acai_new_rec.waitlist_rank,
                                x_waitlist_status               => c_upd_acai_new_rec.waitlist_status,
                                x_location_cd                   => c_upd_acai_new_rec.location_cd ,
                                x_attent_other_inst_cd          => c_upd_acai_old_rec.attent_other_inst_cd,
                                x_attendance_mode               => c_upd_acai_new_rec.attendance_mode ,
                                x_edu_goal_prior_enroll_id      => c_upd_acai_new_rec.edu_goal_prior_enroll_id,
                                x_attendance_type               => c_upd_acai_new_rec.attendance_type ,
                                x_decision_make_id              => c_upd_acai_new_rec.decision_make_id,
                                x_unit_set_cd                   => c_upd_acai_new_rec.unit_set_cd ,
                                x_decision_date                 => c_upd_acai_new_rec.decision_date,
                                x_attribute_category            => c_upd_acai_new_rec.attribute_category,
                                x_attribute1                    => c_upd_acai_new_rec.attribute1,
                                x_attribute2                    => c_upd_acai_new_rec.attribute2,
                                x_attribute3                    => c_upd_acai_new_rec.attribute3,
                                x_attribute4                    => c_upd_acai_new_rec.attribute4,
                                x_attribute5                    => c_upd_acai_new_rec.attribute5,
                                x_attribute6                    => c_upd_acai_new_rec.attribute6,
                                x_attribute7                    => c_upd_acai_new_rec.attribute7,
                                x_attribute8                    => c_upd_acai_new_rec.attribute8,
                                x_attribute9                    => c_upd_acai_new_rec.attribute9,
                                x_attribute10                   => c_upd_acai_new_rec.attribute10,
                                x_attribute11                   => c_upd_acai_new_rec.attribute11,
                                x_attribute12                   => c_upd_acai_new_rec.attribute12,
                                x_attribute13                   => c_upd_acai_new_rec.attribute13,
                                x_attribute14                   => c_upd_acai_new_rec.attribute14,
                                x_attribute15                   => c_upd_acai_new_rec.attribute15,
                                x_attribute16                   => c_upd_acai_new_rec.attribute16,
                                x_attribute17                   => c_upd_acai_new_rec.attribute17,
                                x_attribute18                   => c_upd_acai_new_rec.attribute18,
                                x_attribute19                   => c_upd_acai_new_rec.attribute19,
                                x_attribute20                   => c_upd_acai_new_rec.attribute20,
                                x_decision_reason_id            => c_upd_acai_new_rec.decision_reason_id,
                                x_us_version_number             => c_upd_acai_new_rec.us_version_number ,
                                x_decision_notes                => c_upd_acai_new_rec.decision_notes,
                                x_pending_reason_id             => c_upd_acai_new_rec.pending_reason_id,
                                x_preference_number             => c_upd_acai_new_rec.preference_number ,
                                x_adm_doc_status                => c_upd_acai_old_rec.adm_doc_status ,   -- updating doc status
                                x_adm_entry_qual_status         => c_upd_acai_old_rec.adm_entry_qual_status,  -- updating entry qualification status
                                x_deficiency_in_prep            => c_upd_acai_new_rec.deficiency_in_prep ,
                                x_late_adm_fee_status           => c_upd_acai_old_rec.late_adm_fee_status, -- passing the user defined late adm fee status of the old application instead of 'RECEIVED' (bug#3011405 , rghosh)
                                x_spl_consider_comments         => c_upd_acai_new_rec.spl_consider_comments,
                                x_adm_outcome_status            => c_upd_acai_new_rec.adm_outcome_status,
                                x_adm_otcm_stat_auth_per_id     => c_upd_acai_new_rec.adm_otcm_status_auth_person_id,
                                x_adm_outcome_status_auth_dt    => c_upd_acai_new_rec.adm_outcome_status_auth_dt,
                                x_adm_outcome_status_reason     => c_upd_acai_new_rec.adm_outcome_status_reason,
                                x_offer_dt                      => c_upd_acai_new_rec.offer_dt,
                                x_offer_response_dt             => c_upd_acai_new_rec.offer_response_dt,
                                x_prpsd_commencement_dt         => c_upd_acai_new_rec.prpsd_commencement_dt,
                                x_adm_cndtnl_offer_status       => c_upd_acai_new_rec.adm_cndtnl_offer_status,
                                x_cndtnl_offer_satisfied_dt     => c_upd_acai_new_rec.cndtnl_offer_satisfied_dt,
                                x_cndnl_ofr_must_be_stsfd_ind   => c_upd_acai_new_rec.cndtnl_offer_must_be_stsfd_ind,
                                x_adm_offer_resp_status         => c_upd_acai_new_rec.adm_offer_resp_status,
                                x_actual_response_dt            => c_upd_acai_new_rec.actual_response_dt,
                                x_adm_offer_dfrmnt_status       => c_upd_acai_new_rec.adm_offer_dfrmnt_status ,
                                x_deferred_adm_cal_type         => c_upd_acai_new_rec.deferred_adm_cal_type,
                                x_deferred_adm_ci_sequence_num  => c_upd_acai_new_rec.deferred_adm_ci_sequence_num  ,
                                x_deferred_tracking_id          => c_upd_acai_old_rec.deferred_tracking_id ,
                                x_ass_rank                      => c_upd_acai_old_rec.ass_rank ,
                                x_secondary_ass_rank            => c_upd_acai_new_rec.secondary_ass_rank ,
                                x_intr_accept_advice_num        => c_upd_acai_new_rec.intrntnl_acceptance_advice_num  ,
                                x_ass_tracking_id               => c_upd_acai_old_rec.ass_tracking_id ,
                                x_fee_cat                       => c_upd_acai_new_rec.fee_cat ,
                                x_hecs_payment_option           => c_upd_acai_new_rec.hecs_payment_option ,
                                x_expected_completion_yr        => c_upd_acai_old_rec.expected_completion_yr, --c_upd_acai_new_rec.expected_completion_yr ,
                                x_expected_completion_perd      => c_upd_acai_old_rec.expected_completion_perd, --c_upd_acai_new_rec.expected_completion_perd ,
                                x_correspondence_cat            => c_upd_acai_new_rec.correspondence_cat ,
                                x_enrolment_cat                 => c_upd_acai_new_rec.enrolment_cat ,
                                x_funding_source                => c_upd_acai_old_rec.funding_source ,
                                x_applicant_acptnce_cndtn       => c_upd_acai_new_rec.applicant_acptnce_cndtn ,
                                x_cndtnl_offer_cndtn            => c_upd_acai_new_rec.cndtnl_offer_cndtn ,
                                x_ss_application_id            => c_upd_acai_new_rec.ss_application_id,
                                x_ss_pwd                       => NULL,
                                x_authorized_dt                => c_upd_acai_new_rec.authorized_dt,
                                x_authorizing_pers_id          => c_upd_acai_new_rec.authorizing_pers_id ,
                                x_idx_calc_date                => c_upd_acai_new_rec.idx_calc_date,
                                x_mode                          => 'R',
                                x_fut_acad_cal_type             => c_upd_acai_new_rec.future_acad_cal_type,
                                x_fut_acad_ci_sequence_number   => c_upd_acai_new_rec.future_acad_ci_sequence_number,
                                x_fut_adm_cal_type              => c_upd_acai_new_rec.future_adm_cal_type,
                                x_fut_adm_ci_sequence_number    => c_upd_acai_new_rec.future_adm_ci_sequence_number  ,
                                x_prev_term_adm_appl_number     => c_upd_acai_new_rec.previous_term_adm_appl_number,
                                x_prev_term_sequence_number     => c_upd_acai_new_rec.previous_term_sequence_number,
                                x_fut_term_adm_appl_number      => c_upd_acai_new_rec.future_term_adm_appl_number,
                                x_fut_term_sequence_number      => c_upd_acai_new_rec.future_term_sequence_number,
				x_def_acad_cal_type            => c_upd_acai_new_rec.def_acad_cal_type,
				x_def_acad_ci_sequence_num      => c_upd_acai_new_rec.def_acad_ci_sequence_num,
				x_def_prev_term_adm_appl_num   => c_upd_acai_new_rec.def_prev_term_adm_appl_num,
				x_def_prev_appl_sequence_num  => c_upd_acai_new_rec.def_prev_appl_sequence_num,
				x_def_term_adm_appl_num   => c_upd_acai_new_rec.def_term_adm_appl_num,
				x_def_appl_sequence_num   => c_upd_acai_new_rec.def_appl_sequence_num,
			-- Added entry Status, entry level and school applying id and fin aid columns here for Bug 2631843
 		        -- by rrengara on 2-DEC-2002
				x_entry_status                  => c_upd_acai_old_rec.entry_status,
				x_entry_level                   => c_upd_acai_old_rec.entry_level,
				x_sch_apl_to_id                 => c_upd_acai_old_rec.sch_apl_to_id,
				x_apply_for_finaid              => c_upd_acai_old_rec.apply_for_finaid,
				x_finaid_apply_date             => c_upd_acai_old_rec.finaid_apply_date,
				x_appl_inst_status		=> c_upd_acai_old_rec.appl_inst_status,
				x_ais_reason			=> c_upd_acai_old_rec.ais_reason,
				x_decline_ofr_reason		=> c_upd_acai_old_rec.decline_ofr_reason
				);

              -- Also update the future application number in the old application number for link
              Igs_Ad_Ps_Appl_Inst_Pkg.UPDATE_ROW (
                                x_rowid                         => c_upd_acai_old_rec.row_id ,
                                x_person_id                     => c_upd_acai_old_rec.person_id ,
                                x_admission_appl_number         => c_upd_acai_old_rec.admission_appl_number ,
                                x_nominated_course_cd           => c_upd_acai_old_rec.nominated_course_cd ,
                                x_sequence_number               => c_upd_acai_old_rec.sequence_number ,
                                x_predicted_gpa                 => c_upd_acai_old_rec.predicted_gpa ,
                                x_academic_index                => c_upd_acai_old_rec.academic_index,
                                x_adm_cal_type                  => c_upd_acai_old_rec.adm_cal_type ,
                                x_app_file_location             => c_upd_acai_old_rec.app_file_location ,
                                x_adm_ci_sequence_number        => c_upd_acai_old_rec.adm_ci_sequence_number ,
                                x_course_cd                     => c_upd_acai_old_rec.course_cd ,
                                x_app_source_id                 => c_upd_acai_old_rec.app_source_id ,
                                x_crv_version_number            => c_upd_acai_old_rec.crv_version_number ,
                                x_waitlist_rank                 => c_upd_acai_old_rec.waitlist_rank,
                                x_waitlist_status               => c_upd_acai_old_rec.waitlist_status,
                                x_location_cd                   => c_upd_acai_old_rec.location_cd ,
                                x_attent_other_inst_cd          => c_upd_acai_old_rec.attent_other_inst_cd,
                                x_attendance_mode               => c_upd_acai_old_rec.attendance_mode ,
                                x_edu_goal_prior_enroll_id      => c_upd_acai_old_rec.edu_goal_prior_enroll_id,
                                x_attendance_type               => c_upd_acai_old_rec.attendance_type ,
                                x_decision_make_id              => c_upd_acai_old_rec.decision_make_id,
                                x_unit_set_cd                   => c_upd_acai_old_rec.unit_set_cd ,
                                x_decision_date                 => c_upd_acai_old_rec.decision_date,
                                x_attribute_category            => c_upd_acai_old_rec.attribute_category,
                                x_attribute1                    => c_upd_acai_old_rec.attribute1,
                                x_attribute2                    => c_upd_acai_old_rec.attribute2,
                                x_attribute3                    => c_upd_acai_old_rec.attribute3,
                                x_attribute4                    => c_upd_acai_old_rec.attribute4,
                                x_attribute5                    => c_upd_acai_old_rec.attribute5,
                                x_attribute6                    => c_upd_acai_old_rec.attribute6,
                                x_attribute7                    => c_upd_acai_old_rec.attribute7,
                                x_attribute8                    => c_upd_acai_old_rec.attribute8,
                                x_attribute9                    => c_upd_acai_old_rec.attribute9,
                                x_attribute10                   => c_upd_acai_old_rec.attribute10,
                                x_attribute11                   => c_upd_acai_old_rec.attribute11,
                                x_attribute12                   => c_upd_acai_old_rec.attribute12,
                                x_attribute13                   => c_upd_acai_old_rec.attribute13,
                                x_attribute14                   => c_upd_acai_old_rec.attribute14,
                                x_attribute15                   => c_upd_acai_old_rec.attribute15,
                                x_attribute16                   => c_upd_acai_old_rec.attribute16,
                                x_attribute17                   => c_upd_acai_old_rec.attribute17,
                                x_attribute18                   => c_upd_acai_old_rec.attribute18,
                                x_attribute19                   => c_upd_acai_old_rec.attribute19,
                                x_attribute20                   => c_upd_acai_old_rec.attribute20,
                                x_decision_reason_id            => c_upd_acai_old_rec.decision_reason_id,
                                x_us_version_number             => c_upd_acai_old_rec.us_version_number ,
                                x_decision_notes                => c_upd_acai_old_rec.decision_notes,
                                x_pending_reason_id             => c_upd_acai_old_rec.pending_reason_id,
                                x_preference_number             => c_upd_acai_old_rec.preference_number ,
                                x_adm_doc_status                => c_upd_acai_old_rec.adm_doc_status ,   -- updating doc status
                                x_adm_entry_qual_status         => c_upd_acai_old_rec.adm_entry_qual_status,  -- updating entry qualification status
                                x_deficiency_in_prep            => c_upd_acai_old_rec.deficiency_in_prep ,
                                x_late_adm_fee_status           => c_upd_acai_old_rec.late_adm_fee_status ,
                                x_spl_consider_comments         => c_upd_acai_old_rec.spl_consider_comments,
                                x_adm_outcome_status            => c_upd_acai_old_rec.adm_outcome_status,
                                x_adm_otcm_stat_auth_per_id     => c_upd_acai_old_rec.adm_otcm_status_auth_person_id,
                                x_adm_outcome_status_auth_dt    => c_upd_acai_old_rec.adm_outcome_status_auth_dt,
                                x_adm_outcome_status_reason     => c_upd_acai_old_rec.adm_outcome_status_reason,
                                x_offer_dt                      => c_upd_acai_old_rec.offer_dt,
                                x_offer_response_dt             => c_upd_acai_old_rec.offer_response_dt,
                                x_prpsd_commencement_dt         => c_upd_acai_old_rec.prpsd_commencement_dt,
                                x_adm_cndtnl_offer_status       => c_upd_acai_old_rec.adm_cndtnl_offer_status,
                                x_cndtnl_offer_satisfied_dt     => c_upd_acai_old_rec.cndtnl_offer_satisfied_dt,
                                x_cndnl_ofr_must_be_stsfd_ind   => c_upd_acai_old_rec.cndtnl_offer_must_be_stsfd_ind,
                                x_adm_offer_resp_status         => c_upd_acai_old_rec.adm_offer_resp_status,
                                x_actual_response_dt            => c_upd_acai_old_rec.actual_response_dt,
                                x_adm_offer_dfrmnt_status       => c_upd_acai_old_rec.adm_offer_dfrmnt_status ,
                                x_deferred_adm_cal_type         => c_upd_acai_old_rec.deferred_adm_cal_type,
                                x_deferred_adm_ci_sequence_num  => c_upd_acai_old_rec.deferred_adm_ci_sequence_num  ,
                                x_deferred_tracking_id          => c_upd_acai_old_rec.deferred_tracking_id ,
                                x_ass_rank                      => c_upd_acai_old_rec.ass_rank ,
                                x_secondary_ass_rank            => c_upd_acai_old_rec.secondary_ass_rank ,
                                x_intr_accept_advice_num        => c_upd_acai_old_rec.intrntnl_acceptance_advice_num  ,
                                x_ass_tracking_id               => c_upd_acai_old_rec.ass_tracking_id ,
                                x_fee_cat                       => c_upd_acai_old_rec.fee_cat ,
                                x_hecs_payment_option           => c_upd_acai_old_rec.hecs_payment_option ,
                                x_expected_completion_yr        => c_upd_acai_old_rec.expected_completion_yr ,
                                x_expected_completion_perd      => c_upd_acai_old_rec.expected_completion_perd ,
                                x_correspondence_cat            => c_upd_acai_old_rec.correspondence_cat ,
                                x_enrolment_cat                 => c_upd_acai_old_rec.enrolment_cat ,
                                x_funding_source                => c_upd_acai_old_rec.funding_source ,
                                x_applicant_acptnce_cndtn       => c_upd_acai_old_rec.applicant_acptnce_cndtn ,
                                x_cndtnl_offer_cndtn            => c_upd_acai_old_rec.cndtnl_offer_cndtn ,
                                x_ss_application_id            => c_upd_acai_old_rec.ss_application_id,
                                x_ss_pwd                       => c_upd_acai_old_rec.ss_pwd,
                                x_authorized_dt                => c_upd_acai_old_rec.authorized_dt,
                                x_authorizing_pers_id          => c_upd_acai_old_rec.authorizing_pers_id ,
                                x_idx_calc_date                => c_upd_acai_old_rec.idx_calc_date,
                                x_mode                          => 'R',
                                x_fut_acad_cal_type             => c_upd_acai_old_rec.future_acad_cal_type,
                                x_fut_acad_ci_sequence_number   => c_upd_acai_old_rec.future_acad_ci_sequence_number,
                                x_fut_adm_cal_type              => c_upd_acai_old_rec.future_adm_cal_type,
                                x_fut_adm_ci_sequence_number    => c_upd_acai_old_rec.future_adm_ci_sequence_number  ,
                                x_prev_term_adm_appl_number     => c_upd_acai_old_rec.previous_term_adm_appl_number,
                                x_prev_term_sequence_number     => c_upd_acai_old_rec.previous_term_sequence_number,
                                x_fut_term_adm_appl_number      => c_upd_acai_old_rec.future_term_adm_appl_number,
                                x_fut_term_sequence_number      => c_upd_acai_old_rec.future_term_sequence_number,
				x_def_acad_cal_type            => c_upd_acai_old_rec.def_acad_cal_type,
				x_def_acad_ci_sequence_num      =>c_upd_acai_old_rec.def_acad_ci_sequence_num,
				x_def_prev_term_adm_appl_num   => c_upd_acai_old_rec.def_prev_term_adm_appl_num,
				x_def_prev_appl_sequence_num  => c_upd_acai_old_rec.def_prev_appl_sequence_num,
				x_def_term_adm_appl_num   => p_new_admission_appl_number,
				x_def_appl_sequence_num   =>  p_new_sequence_number,
			-- Added entry Status, entry level and school applying id and fin aid columns here for Bug 2631843
		        -- by rrengara on 2-DEC-2002
				x_entry_status                  => c_upd_acai_old_rec.entry_status,
				x_entry_level                   => c_upd_acai_old_rec.entry_level,
				x_sch_apl_to_id                 => c_upd_acai_old_rec.sch_apl_to_id,
				x_apply_for_finaid              => c_upd_acai_old_rec.apply_for_finaid,
				x_finaid_apply_date             => c_upd_acai_old_rec.finaid_apply_date,
				x_appl_inst_status		=> c_upd_acai_old_rec.appl_inst_status,
				x_ais_reason			=> c_upd_acai_old_rec.ais_reason,
				x_decline_ofr_reason		=> c_upd_acai_old_rec.decline_ofr_reason
				);
    END LOOP;
  END LOOP;
  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log, 'Error from copy_entrycomp_qual_status: '  || SQLERRM);
  fnd_file.put_line(fnd_file.log, 'Person Number : ' || get_person_number(IGS_GE_NUMBER.TO_CANN(p_person_id)));
  fnd_file.put_line(fnd_file.log, 'Admission Appl Number : ' || IGS_GE_NUMBER.TO_CANN(p_admission_appl_number));
  fnd_file.put_line(fnd_file.log, 'Nominated Course Code : ' || p_nominated_course_cd);
  fnd_file.put_line(fnd_file.log, 'Sequence Number : ' || p_sequence_number);
  RETURN FALSE;
END copy_entrycomp_qual_status;


 FUNCTION Update_offer_response_accepted (p_person_id  HZ_PARTIES.party_id%TYPE,
                                            p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                            p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                            p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE) RETURN BOOLEAN IS
/*******************************************************************************
Created by  : hreddych
Date created: 16 OCT 2002

Purpose:
  To update the Offer response status of the new application to 'ACCEPTED'
  if the offer deferment status of the old application is 'CONFIRM'
  and to initiate the pre-enrollments Process.

Change History: (who, when, what: )
Who             When            What
apadegal        06-oct-2005     Changed from procedure to function, to return false, if any thing fails
                                Retruned false if pre-enrollment process fails
*******************************************************************************/

  -- Cursor Declarations-------------------------------------------------------------------
 CURSOR   cur_appl_details (p_person_id Igs_Ad_Ps_Appl_Inst.person_id%TYPE,
                            p_admission_appl_number Igs_Ad_Ps_Appl_Inst.admission_appl_number%TYPE,
		            p_nominated_course_cd Igs_Ad_Ps_Appl_Inst.nominated_course_cd%TYPE,
			    p_sequence_number Igs_Ad_Ps_Appl_Inst.sequence_number%TYPE ) IS
  SELECT  apai.*, apai.rowid
  FROM    igs_ad_ps_appl_inst apai  /* Replaced igs_ad_ps_appl_inst_aplinst_v with base tables Bug 3150054 */
  WHERE   apai.person_id   = p_person_id
    AND   apai.admission_appl_number  =  p_admission_appl_number
    AND   apai.nominated_course_cd     =   p_nominated_course_cd
    AND   apai.sequence_number   = p_sequence_number;

 CURSOR   cur_application_details (p_person_id Igs_Ad_Ps_Appl_Inst.person_id%TYPE,
                                   p_admission_appl_number Igs_Ad_Ps_Appl_Inst.admission_appl_number%TYPE,
		                   p_nominated_course_cd Igs_Ad_Ps_Appl_Inst.nominated_course_cd%TYPE,
			           p_sequence_number Igs_Ad_Ps_Appl_Inst.sequence_number%TYPE ) IS
  SELECT  apai.*
  FROM    igs_ad_ps_appl_inst apai
  WHERE   apai.person_id   = p_person_id
    AND   apai.admission_appl_number  =  p_admission_appl_number
    AND   apai.nominated_course_cd     =   p_nominated_course_cd
    AND   apai.sequence_number   = p_sequence_number;

  CURSOR cur_adm_offer_resp_status IS
  SELECT adm_offer_resp_status
  FROM   igs_ad_ofr_resp_stat
  WHERE  s_adm_offer_resp_status ='ACCEPTED'
  AND    system_default_ind ='Y';

  -----End cursor Declarations------------------------------------------------------------------

  -------------------Variable Declarations------------------------------------------------------
  l_adm_offer_resp_status         Igs_Ad_Ps_Appl_Inst.adm_offer_resp_status%TYPE;
  cur_appl_details_rec            cur_appl_details%ROWTYPE;
  cur_application_details_rec     cur_application_details%ROWTYPE;
  v_message_name                  VARCHAR2(100);
  v_warn_level                    VARCHAR2(10);
  ------------------- End Variable Declarations------------------------------------------------------
BEGIN

      OPEN  cur_adm_offer_resp_status ;
      FETCH cur_adm_offer_resp_status INTO l_adm_offer_resp_status;
      CLOSE cur_adm_offer_resp_status;

      OPEN cur_appl_details (p_person_id,
			     p_admission_appl_number,
			     p_nominated_course_cd,
			     p_sequence_number);
      FETCH cur_appl_details INTO cur_appl_details_rec;
      CLOSE cur_appl_details;


 igs_ad_ps_appl_inst_pkg.update_row (
       X_ROWID                         => cur_appl_details_rec.ROWID                        ,
       x_PERSON_ID                     => cur_appl_details_rec.PERSON_ID                     ,
       x_ADMISSION_APPL_NUMBER         => cur_appl_details_rec.ADMISSION_APPL_NUMBER         ,
       x_NOMINATED_COURSE_CD           => cur_appl_details_rec.NOMINATED_COURSE_CD           ,
       x_SEQUENCE_NUMBER               => cur_appl_details_rec.SEQUENCE_NUMBER               ,
       x_PREDICTED_GPA                 => cur_appl_details_rec.PREDICTED_GPA                 ,
       x_ACADEMIC_INDEX                => cur_appl_details_rec.ACADEMIC_INDEX                ,
       x_ADM_CAL_TYPE                  => cur_appl_details_rec.ADM_CAL_TYPE                  ,
       x_APP_FILE_LOCATION             => cur_appl_details_rec.APP_FILE_LOCATION             ,
       x_ADM_CI_SEQUENCE_NUMBER        => cur_appl_details_rec.ADM_CI_SEQUENCE_NUMBER        ,
       x_COURSE_CD                     => cur_appl_details_rec.COURSE_CD                     ,
       x_APP_SOURCE_ID                 => cur_appl_details_rec.APP_SOURCE_ID                 ,
       x_CRV_VERSION_NUMBER            => cur_appl_details_rec.CRV_VERSION_NUMBER            ,
       x_WAITLIST_RANK                 => cur_appl_details_rec.WAITLIST_RANK                 ,
       x_LOCATION_CD                   => cur_appl_details_rec.LOCATION_CD                   ,
       x_ATTENT_OTHER_INST_CD          => cur_appl_details_rec.ATTENT_OTHER_INST_CD          ,
       x_ATTENDANCE_MODE               => cur_appl_details_rec.ATTENDANCE_MODE               ,
       x_EDU_GOAL_PRIOR_ENROLL_ID      => cur_appl_details_rec.EDU_GOAL_PRIOR_ENROLL_ID      ,
       x_ATTENDANCE_TYPE               => cur_appl_details_rec.ATTENDANCE_TYPE               ,
       x_DECISION_MAKE_ID              => cur_appl_details_rec.DECISION_MAKE_ID              ,
       x_UNIT_SET_CD                   => cur_appl_details_rec.UNIT_SET_CD                   ,
       x_DECISION_DATE                 => cur_appl_details_rec.DECISION_DATE                 ,
       x_ATTRIBUTE_CATEGORY            => cur_appl_details_rec.ATTRIBUTE_CATEGORY            ,
       x_ATTRIBUTE1                    => cur_appl_details_rec.ATTRIBUTE1                    ,
       x_ATTRIBUTE2                    => cur_appl_details_rec.ATTRIBUTE2                    ,
       x_ATTRIBUTE3                    => cur_appl_details_rec.ATTRIBUTE3                    ,
       x_ATTRIBUTE4                    => cur_appl_details_rec.ATTRIBUTE4                    ,
       x_ATTRIBUTE5                    => cur_appl_details_rec.ATTRIBUTE5                    ,
       x_ATTRIBUTE6                    => cur_appl_details_rec.ATTRIBUTE6                    ,
       x_ATTRIBUTE7                    => cur_appl_details_rec.ATTRIBUTE7                    ,
       x_ATTRIBUTE8                    => cur_appl_details_rec.ATTRIBUTE8                    ,
       x_ATTRIBUTE9                    => cur_appl_details_rec.ATTRIBUTE9                    ,
       x_ATTRIBUTE10                   => cur_appl_details_rec.ATTRIBUTE10                   ,
       x_ATTRIBUTE11                   => cur_appl_details_rec.ATTRIBUTE11                   ,
       x_ATTRIBUTE12                   => cur_appl_details_rec.ATTRIBUTE12                   ,
       x_ATTRIBUTE13                   => cur_appl_details_rec.ATTRIBUTE13                   ,
       x_ATTRIBUTE14                   => cur_appl_details_rec.ATTRIBUTE14                   ,
       x_ATTRIBUTE15                   => cur_appl_details_rec.ATTRIBUTE15                   ,
       x_ATTRIBUTE16                   => cur_appl_details_rec.ATTRIBUTE16                   ,
       x_ATTRIBUTE17                   => cur_appl_details_rec.ATTRIBUTE17                   ,
       x_ATTRIBUTE18                   => cur_appl_details_rec.ATTRIBUTE18                   ,
       x_ATTRIBUTE19                   => cur_appl_details_rec.ATTRIBUTE19                   ,
       x_ATTRIBUTE20                   => cur_appl_details_rec.ATTRIBUTE20                   ,
       x_DECISION_REASON_ID            => cur_appl_details_rec.DECISION_REASON_ID            ,
       x_US_VERSION_NUMBER             => cur_appl_details_rec.US_VERSION_NUMBER             ,
       x_DECISION_NOTES                => cur_appl_details_rec.DECISION_NOTES                ,
       x_PENDING_REASON_ID             => cur_appl_details_rec.PENDING_REASON_ID             ,
       x_PREFERENCE_NUMBER             => cur_appl_details_rec.PREFERENCE_NUMBER             ,
       x_ADM_DOC_STATUS                => cur_appl_details_rec.ADM_DOC_STATUS                ,
       x_ADM_ENTRY_QUAL_STATUS         => cur_appl_details_rec.ADM_ENTRY_QUAL_STATUS         ,
       x_DEFICIENCY_IN_PREP            => cur_appl_details_rec.DEFICIENCY_IN_PREP            ,
       x_LATE_ADM_FEE_STATUS           => cur_appl_details_rec.LATE_ADM_FEE_STATUS           ,
       x_SPL_CONSIDER_COMMENTS         => cur_appl_details_rec.SPL_CONSIDER_COMMENTS         ,
       x_APPLY_FOR_FINAID              => cur_appl_details_rec.APPLY_FOR_FINAID              ,
       x_FINAID_APPLY_DATE             => cur_appl_details_rec.FINAID_APPLY_DATE             ,
       x_ADM_OUTCOME_STATUS            => cur_appl_details_rec.ADM_OUTCOME_STATUS            ,
       x_ADM_OTCM_STAT_AUTH_PER_ID     => cur_appl_details_rec.ADM_OTCM_STATUS_AUTH_PERSON_ID,
       x_ADM_OUTCOME_STATUS_AUTH_DT    => cur_appl_details_rec.ADM_OUTCOME_STATUS_AUTH_DT    ,
       x_ADM_OUTCOME_STATUS_REASON     => cur_appl_details_rec.ADM_OUTCOME_STATUS_REASON     ,
       x_OFFER_DT                      => cur_appl_details_rec.OFFER_DT                      ,
       x_OFFER_RESPONSE_DT             => cur_appl_details_rec.OFFER_RESPONSE_DT             ,
       x_PRPSD_COMMENCEMENT_DT         => cur_appl_details_rec.PRPSD_COMMENCEMENT_DT         ,
       x_ADM_CNDTNL_OFFER_STATUS       => cur_appl_details_rec.ADM_CNDTNL_OFFER_STATUS       ,
       x_CNDTNL_OFFER_SATISFIED_DT     => cur_appl_details_rec.CNDTNL_OFFER_SATISFIED_DT     ,
       x_CNDNL_OFR_MUST_BE_STSFD_IND   => cur_appl_details_rec.CNDTNL_OFFER_MUST_BE_STSFD_IND   ,
       x_ADM_OFFER_RESP_STATUS         => l_adm_offer_resp_status                            ,
       x_ACTUAL_RESPONSE_DT            => TRUNC(SYSDATE)            ,
       x_ADM_OFFER_DFRMNT_STATUS       => cur_appl_details_rec.ADM_OFFER_DFRMNT_STATUS       ,
       x_DEFERRED_ADM_CAL_TYPE         => cur_appl_details_rec.DEFERRED_ADM_CAL_TYPE         ,
       x_DEFERRED_ADM_CI_SEQUENCE_NUM  => cur_appl_details_rec.DEFERRED_ADM_CI_SEQUENCE_NUM  ,
       x_DEFERRED_TRACKING_ID          => cur_appl_details_rec.DEFERRED_TRACKING_ID          ,
       x_ASS_RANK                      => cur_appl_details_rec.ASS_RANK                      ,
       x_SECONDARY_ASS_RANK            => cur_appl_details_rec.SECONDARY_ASS_RANK            ,
       X_INTR_ACCEPT_ADVICE_NUM        => cur_appl_details_rec.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
       x_ASS_TRACKING_ID               => cur_appl_details_rec.ASS_TRACKING_ID               ,
       x_FEE_CAT                       => cur_appl_details_rec.FEE_CAT                       ,
       x_HECS_PAYMENT_OPTION           => cur_appl_details_rec.HECS_PAYMENT_OPTION           ,
       x_EXPECTED_COMPLETION_YR        => cur_appl_details_rec.EXPECTED_COMPLETION_YR        ,
       x_EXPECTED_COMPLETION_PERD      => cur_appl_details_rec.EXPECTED_COMPLETION_PERD      ,
       x_CORRESPONDENCE_CAT            => cur_appl_details_rec.CORRESPONDENCE_CAT            ,
       x_ENROLMENT_CAT                 => cur_appl_details_rec.ENROLMENT_CAT                 ,
       x_FUNDING_SOURCE                => cur_appl_details_rec.FUNDING_SOURCE                ,
       x_APPLICANT_ACPTNCE_CNDTN       => cur_appl_details_rec.APPLICANT_ACPTNCE_CNDTN       ,
       x_CNDTNL_OFFER_CNDTN            => cur_appl_details_rec.CNDTNL_OFFER_CNDTN            ,
      X_MODE                           => 'R'                           ,
      X_SS_APPLICATION_ID              => cur_appl_details_rec.SS_APPLICATION_ID              ,
      X_SS_PWD                         => cur_appl_details_rec.SS_PWD                         ,
      X_AUTHORIZED_DT                  => cur_appl_details_rec.AUTHORIZED_DT                  ,
      X_AUTHORIZING_PERS_ID            => cur_appl_details_rec.AUTHORIZING_PERS_ID            ,
       x_entry_status                  => cur_appl_details_rec.entry_status                  ,
       x_entry_level                   => cur_appl_details_rec.entry_level                   ,
       x_sch_apl_to_id                 => cur_appl_details_rec.sch_apl_to_id                 ,
      x_idx_calc_date                  => cur_appl_details_rec.idx_calc_date                  ,
      X_WAITLIST_STATUS                => cur_appl_details_rec.WAITLIST_STATUS                ,
      x_attribute21                    => cur_appl_details_rec.attribute21                    ,
      x_attribute22                    => cur_appl_details_rec.attribute22                    ,
      x_attribute23                    => cur_appl_details_rec.attribute23                    ,
      x_attribute24                    => cur_appl_details_rec.attribute24                    ,
      x_attribute25                    => cur_appl_details_rec.attribute25                    ,
      x_attribute26                    => cur_appl_details_rec.attribute26                    ,
      x_attribute27                    => cur_appl_details_rec.attribute27                    ,
      x_attribute28                    => cur_appl_details_rec.attribute28                    ,
      x_attribute29                    => cur_appl_details_rec.attribute29                    ,
      x_attribute30                    => cur_appl_details_rec.attribute30                    ,
      x_attribute31                    => cur_appl_details_rec.attribute31                    ,
      x_attribute32                    => cur_appl_details_rec.attribute32                    ,
      x_attribute33                    => cur_appl_details_rec.attribute33                    ,
      x_attribute34                    => cur_appl_details_rec.attribute34                    ,
      x_attribute35                    => cur_appl_details_rec.attribute35                    ,
      x_attribute36                    => cur_appl_details_rec.attribute36                    ,
      x_attribute37                    => cur_appl_details_rec.attribute37                    ,
      x_attribute38                    => cur_appl_details_rec.attribute38                    ,
      x_attribute39                    => cur_appl_details_rec.attribute39                    ,
      x_attribute40                    => cur_appl_details_rec.attribute40                    ,
      x_fut_acad_cal_type              => cur_appl_details_rec.future_acad_cal_type              ,
      x_fut_acad_ci_sequence_number    => cur_appl_details_rec.future_acad_ci_sequence_number    ,
      x_fut_adm_cal_type               => cur_appl_details_rec.future_adm_cal_type               ,
      x_fut_adm_ci_sequence_number     => cur_appl_details_rec.future_adm_ci_sequence_number     ,
      x_prev_term_adm_appl_number      => cur_appl_details_rec.previous_term_adm_appl_number      ,
      x_prev_term_sequence_number      => cur_appl_details_rec.previous_term_sequence_number      ,
      x_fut_term_adm_appl_number       => cur_appl_details_rec.future_term_adm_appl_number       ,
      x_fut_term_sequence_number       => cur_appl_details_rec.future_term_sequence_number       ,
      x_def_acad_cal_type              => cur_appl_details_rec.def_acad_cal_type              ,
      x_def_acad_ci_sequence_num       => cur_appl_details_rec.def_acad_ci_sequence_num       ,
      x_def_prev_term_adm_appl_num     => cur_appl_details_rec.def_prev_term_adm_appl_num     ,
      x_def_prev_appl_sequence_num     => cur_appl_details_rec.def_prev_appl_sequence_num     ,
      x_def_term_adm_appl_num          => cur_appl_details_rec.def_term_adm_appl_num          ,
      x_def_appl_sequence_num          => cur_appl_details_rec.def_appl_sequence_num	      ,
      x_appl_inst_status	       => cur_appl_details_rec.appl_inst_status,
      x_ais_reason		       => cur_appl_details_rec.ais_reason,
      x_decline_ofr_reason	       => cur_appl_details_rec.decline_ofr_reason

      );


      OPEN cur_application_details (p_person_id,
			     p_admission_appl_number,
			     p_nominated_course_cd,
			     p_sequence_number);
     FETCH cur_application_details INTO cur_application_details_rec;
     CLOSE cur_application_details;

     	-- rrengara
	-- on 28-oct-2002 for Build Core Vs optional Bug 2647482
	-- get the unit set mapping by calling the apc for the application
	-- then pass the value to the Pre-enrollment procedure for the parameter p_units_indicator


          IF igs_ad_upd_initialise.perform_pre_enrol(
               cur_application_details_rec.person_id,
               cur_application_details_rec.admission_appl_number,
               cur_application_details_rec.nominated_course_cd,
               cur_application_details_rec.sequence_number,
               'Y',                     -- Confirm course indicator.
               'Y',                     -- Perform eligibility check indicator.
               v_message_name) = FALSE THEN
            fnd_message.set_name('IGS', v_message_name);
            fnd_file.put_line(fnd_file.log, 'Application could not be created');  -- added - apadegal adtd001 igs.m
            fnd_file.put_line(fnd_file.log, fnd_message.get);
	    RETURN FALSE ;   -- added - apadegal adtd001 igs.m
          END IF;

	  RETURN TRUE;					      -- added - apadegal adtd001 igs.m

 EXCEPTION WHEN OTHERS THEN
--    fnd_file.put_line(fnd_file.log, 'Exception From Update offer response log ' ||   v_message_name);

    -- begin - apadegal adtd001 igs.m
    fnd_file.put_line(fnd_file.log, 'Exception From Update offer response log ' ||   SQLERRM);
    RETURN FALSE;
    -- end - apadegal adtd001 igs.m
 END update_offer_response_accepted;

END igs_ad_def_appl_pkg;

/
