--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_025
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_025" AS
/* $Header: IGSADB6B.pls 120.2 2005/07/15 06:32:06 appldev ship $ */
/*
  ||  Created By : pkpatel
  ||  Created On : 12-NOV-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  || ssaleem          13_OCT_2003     Bug : 3130316
  ||                                  Logging is modified to include logging mechanism
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
  || sarakshi        12-Nov-2001      Added procedure prc_pe_felony_dtls,prc_pe_hearing_dtls,prc_pe_disciplinary_dtls
  || kumma           21-OCT-2002      Added one more parameter for disp_action_info to the Igs_Pe_Felony_Dtls_Pkg.insert_row
  ||				      and update_row in  PROCEDURE  crt_pe_felony_dtls , #2608360
  || npalanis         30_OCT-2002     Bug : 2608360
  ||                                  Trunc function added to crime date and nvl added for
  ||                                  disp_action_info in prc_pe_felony_dtls.
  || gmaheswa         1-Nov-2004      Bug : 3770362 removed code related to the effective dates(start_date , end_date)of housing status as they are obsoleted
  || pkpatel          29-Nov-204      Bug : 3770362 In the Load Cal validation of Housing status modified to TRUNC of sysdate
  ||				      (reverse chronological order - newest change first)
  || skpandey	      08-JUL-2005     Bug : 4327807
  ||				      Added a condition in exception section of crt_pe_felony_dtls after calling igs_pe_felony_dtls_pkg.update_row
  ||				      and igs_pe_felony_dtls_pkg.insert_row to set status and error code
*/
--
-- Starts procedure PRC_PE_HOUSE_STATUS
--
l_interface_run_id NUMBER;
l_var VARCHAR2(1000);

PROCEDURE prc_pe_house_status
(
	   P_SOURCE_TYPE_ID	IN	NUMBER,
	   P_BATCH_ID	IN	NUMBER )
AS
  /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 06-Jul-2001
  ||  Purpose : This procedure is for importing person Houseing Status Information.
  ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
  || npalanis        11-OCT-2002     bug - 2608360
  ||                                 igs_pe_code_classes is
  ||                                  removed due to transition of code
  ||                                 class to lookups , new columns added
  ||                                 for codes. the  tbh call are  modified accordingly
  ||  kumma           25-JUN-2002     In function validate_record replaced the class 'RESIDENCY_STTAUS'
  ||				      with 'TEACH_PEPRIOD_RESIDENCE' in cursor validate_teach_cur bug # 2423988
  ||  kumma                           Replaced the ref cursor type validatecur with 2 normal cursors
  ||				      validate_teach_cur and validate_cal , bug # 2423670
  ||  kumma           16-JUN-2002     Added validations for START_DATE to be not null, bug # 2423988
  ||  gmaheswa        1-nov-2004      calender type and sequence number can be of active/future load calender.
  ||				      Obsoleted start_date and end_date columns of igs_pe_housing_int and igs_pe_teach_periods_all
  ||				      Modified the duplicated record check to be based on cal_type and sequence_number of a person.
  */

  	l_rule VARCHAR2(1);
	l_error_code igs_pe_housing_int.error_code%TYPE;
	l_status     igs_pe_housing_int.status%TYPE;
        l_processed_records NUMBER(5) := 0;


       l_prog_label  VARCHAR2(100);
       l_label  VARCHAR2(100);
       l_debug_str VARCHAR2(2000);
       l_enable_log VARCHAR2(1);
       l_request_id NUMBER;


	--Pick up the records for processing from the Housing Status Interface Table
	CURSOR housing_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE)  IS
	SELECT ai.*, i.person_id
        FROM   	igs_pe_housing_int ai, igs_ad_interface_all i
        WHERE   ai.interface_id = i.interface_id AND
              	ai.status = '2' AND
                i.interface_run_id = cp_interface_run_id AND
		ai.interface_run_id = cp_interface_run_id;

       --Cursor to check whether the Record in Interface Table already exists in OSS table
       CURSOR dup_chk_housing_cur(cp_person_id                  igs_pe_teach_periods_all.person_id%TYPE,
                          	  cp_cal_type                   igs_pe_teach_periods_all.cal_type%TYPE,
				  cp_sequence_number            igs_pe_teach_periods_all.sequence_number%TYPE) IS
       SELECT p.rowid,p.*  -- selecting all fields of the interface table...
       FROM   igs_pe_teach_periods_all p
       WHERE  p.person_id = cp_person_id AND
              p.cal_type = cp_cal_type AND
	      p.sequence_number = cp_sequence_number;

        dup_chk_housing_rec    dup_chk_housing_cur%ROWTYPE;
      	housing_rec            housing_cur%ROWTYPE;

	-- Start Local Procedure crt_pe_house_status
  	PROCEDURE crt_pe_house_status(
        		p_housing_rec 	IN 	housing_cur%ROWTYPE
			 ) AS
		l_rowid VARCHAR2(25);
		l_teaching_period_id   igs_pe_teach_periods_all.teaching_period_id%TYPE;
		l_error_code 	       igs_pe_housing_int.error_code%TYPE;
		l_org_id               NUMBER(15);
 	BEGIN
		-- Call Log header
		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

			IF (l_request_id IS NULL) THEN
			    l_request_id := fnd_global.conc_request_id;
			END IF;

			l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_house_status.begin_crt_pe_house_status';
			l_debug_str :=  'igs_ad_imp_025.prc_pe_house_status.crt_pe_house_status';

			fnd_log.string_with_context( fnd_log.level_procedure,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
		END IF;


                l_org_id := igs_ge_gen_003.get_org_id;
		igs_pe_teach_periods_pkg.insert_row (
		                         x_rowid            => l_rowid,
			                 x_teaching_period_id  => l_teaching_period_id,
                                         x_person_id        => p_housing_rec.person_id,
                                         x_teach_period_resid_stat_cd  => p_housing_rec.teach_period_resid_stat_cd,
                                         x_cal_type         => p_housing_rec.cal_type,
                                         x_sequence_number  => p_housing_rec.sequence_number,
                                         x_mode             => 'R',
                                         x_org_id           => l_org_id
					);
		l_error_code := NULL;
		UPDATE igs_pe_housing_int
                SET    status     = '1',
                       error_code = l_error_code
                WHERE  interface_housing_id = p_housing_rec.interface_housing_id;

	EXCEPTION
		WHEN OTHERS THEN
  		    l_error_code := 'E109'; -- Person Housing Status Insertion Failed

	     	    UPDATE igs_pe_housing_int
                    SET    status     = '3',
                           error_code = l_error_code
                    WHERE  interface_housing_id = p_housing_rec.interface_housing_id;

    	            -- Call Log detail
                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	 		 IF (l_request_id IS NULL) THEN
			    l_request_id := fnd_global.conc_request_id;
			 END IF;
			 l_label := 'igs.plsql.igs_ad_imp_025.crt_pe_house_status.exception';

			 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			 fnd_message.set_token('INTERFACE_ID',p_housing_rec.interface_housing_id);
			 fnd_message.set_token('ERROR_CD',l_error_code);

			 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

			 fnd_log.string_with_context( fnd_log.level_exception,
			      			      l_label,
						      l_debug_str, NULL,
						      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
 		    END IF;

		    IF l_enable_log = 'Y' THEN
    			 igs_ad_imp_001.logerrormessage(p_housing_rec.interface_housing_id,l_error_code);
		    END IF;

	END crt_pe_house_status;
	-- END OF LOCAL PROCEDURE crt_pe_house_status

	-- Local procedure to update a record in the OSS table.
	PROCEDURE upd_pe_house_status(p_dup_rec IN dup_chk_housing_cur%ROWTYPE,
				   p_housing_rec IN housing_cur%ROWTYPE)
	/*
	||  Created By : gmaheswa
	||  Created On : 2/11/2004
	||  Purpose : Local procedure to update an existing housing record.
	||  Known limitations, enhancements or remarks :
	||  Change History :
	||  Who             When            What
	||  (reverse chronological order - newest change first)
	|| gmaheswa         2/11/2004         Created
	*/
	AS

	BEGIN
		igs_pe_teach_periods_pkg.update_row (
		        x_rowid                       => p_dup_rec.rowid,
		        x_teaching_period_id          => p_dup_rec.teaching_period_id,
		        x_person_id                   => NVL(p_dup_rec.person_id,housing_rec.person_id),
		        x_teach_period_resid_stat_cd  => NVL(p_housing_rec.teach_period_resid_stat_cd,p_dup_rec.teach_period_resid_stat_cd),
		        x_cal_type                    => NVL(p_dup_rec.cal_type,housing_rec.cal_type),
		        x_sequence_number             => NVL(p_dup_rec.sequence_number,housing_rec.sequence_number),
		        x_mode                        => 'R'
                );

	        UPDATE 	igs_pe_housing_int
		SET 	status = '1',
			error_code = NULL,
			match_ind = '18'  -- '18' Match occured and used import values
		WHERE 	interface_housing_id = p_housing_rec.interface_housing_id;

	EXCEPTION
		WHEN OTHERS THEN

		       UPDATE 	igs_pe_housing_int
                       SET      status = '3',
				error_code = 'E114'
		       WHERE 	interface_housing_id = p_housing_rec.interface_housing_id;

		       -- Call Log detail
		       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
		           IF (l_request_id IS NULL) THEN
		               l_request_id := fnd_global.conc_request_id;
	   		   END IF;
	  		   l_label := 'igs.plsql.igs_ad_imp_025.upd_pe_house_status.exception';

	  		   fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	          	   fnd_message.set_token('INTERFACE_ID',p_housing_rec.interface_housing_id);
	 		   fnd_message.set_token('ERROR_CD','E114');

	  		   l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;
	 		   fnd_log.string_with_context( fnd_log.level_exception,
	                  			        l_label,
						        l_debug_str, NULL,
							NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
		       END IF;

		       IF l_enable_log = 'Y' THEN
		           igs_ad_imp_001.logerrormessage(p_housing_rec.interface_housing_id,'E114');
		       END IF;
	END upd_pe_house_status; -- END OF LOCAL PROCEDURE upd_pe_priv_dtls

-- Start Local function Validate_Record
FUNCTION validate_record(p_housing_rec 	IN 	housing_cur%ROWTYPE,P_ACTION VARCHAR2)
	  RETURN BOOLEAN IS

	  CURSOR validate_cal(c_person_id igs_pe_person.person_id%TYPE,
			      c_cal_type igs_ca_inst.cal_type%TYPE,
			      c_seq_number igs_ca_inst.sequence_number%TYPE) IS
		SELECT 'X'
		FROM   igs_en_su_attempt_all sa
		WHERE  sa.person_id = c_person_id AND
		       sa.unit_attempt_status IN ('ENROLLED','UNCONFIRM') AND
		       sa.cal_type = c_cal_type AND
		       sa.ci_sequence_number = c_seq_number;

	  CURSOR validate_load_cal(c_cal_type igs_ca_inst.cal_type%TYPE,
				   c_seq_number igs_ca_inst.sequence_number%TYPE) IS
	        SELECT   'X'
		FROM IGS_CA_INST_ALL CA,
		     IGS_CA_TYPE TYP,
		     IGS_CA_STAT STAT
	        WHERE
		     TYP.CAL_TYPE = CA.CAL_TYPE   AND
		     TYP.S_CAL_CAT = 'LOAD' AND
		     CA.END_DT >= TRUNC(SYSDATE) AND
		     CA.CAL_STATUS = STAT.CAL_STATUS AND
		     STAT.S_CAL_STATUS = 'ACTIVE' AND
		     CA.CAL_TYPE = c_cal_type AND
		     CA.SEQUENCE_NUMBER = c_seq_number;


	  l_error_code	 igs_pe_housing_int.error_code%TYPE;
	  l_rec VARCHAR2(1);
BEGIN
    -- TEACH_PERIOD_RESID_STAT_CD
    IF NOT(igs_pe_pers_imp_001.validate_lookup_type_code('PE_TEA_PER_RES',p_housing_rec.teach_period_resid_stat_cd,8405))
    THEN
        l_error_code := 'E110'; -- Person Housing Status Validation Failed - Teaching Period Housing Status
        RAISE NO_DATA_FOUND;
    END IF;

    IF (P_ACTION = 'I') THEN

        -- CAL_TYPE and SEQUENCE_NUMBER
        IF (p_housing_rec.cal_type IS NULL OR p_housing_rec.sequence_number IS NULL) THEN
		  l_error_code := 'E112'; -- Person Housing Status Validation Failed - Calandar Type and Sequence Number are madatory
		  RAISE NO_DATA_FOUND;
        END IF;

        -- CAL_TYPE and SEQUENCE_NUMBER. Removed the NULL check, since NULL is alos an invalid value
        --calender type and sequence number must be a teaching calender in which the student has enrolled in or a active/future load calender
	OPEN validate_cal(p_housing_rec.person_id,p_housing_rec.cal_type,p_housing_rec.sequence_number);
	FETCH validate_cal INTO l_rec;

	IF  validate_cal%NOTFOUND THEN
	   OPEN validate_load_cal(p_housing_rec.cal_type,p_housing_rec.sequence_number);
	   FETCH validate_load_cal INTO l_rec;
	   IF validate_load_cal%NOTFOUND THEN
		l_error_code := 'E113'; -- Person Housing Status Validation Failed - Calandar Type and Sequence Number
		CLOSE validate_load_cal;
		CLOSE validate_cal;
		RAISE NO_DATA_FOUND;
	   ELSE
		l_error_code := NULL;
	        CLOSE validate_load_cal;
		CLOSE validate_cal;
	   END IF;
	ELSE
   	   l_error_code := NULL;
	   CLOSE validate_cal;
	END IF;

      END IF;

    RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		UPDATE igs_pe_housing_int
		SET    status     = '3',
		       error_code = l_error_code
		WHERE  interface_housing_id = p_housing_rec.interface_housing_id;

			-- Call Log detail

	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_house_status.exception_validate_record';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',p_housing_rec.interface_housing_id);
		 fnd_message.set_token('ERROR_CD',l_error_code);

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	       END IF;

	       IF l_enable_log = 'Y' THEN
		      igs_ad_imp_001.logerrormessage(p_housing_rec.interface_housing_id,l_error_code);
	       END IF;

	       RETURN FALSE;
END Validate_Record;
-- End Local function Validate_Record

BEGIN
        l_prog_label       := 'igs.plsql.igs_ad_imp_025.prc_pe_house_status';
        l_label            := 'igs.plsql.igs_ad_imp_025.prc_pe_house_status.';
        l_enable_log       := igs_ad_imp_001.g_enable_log;
        l_interface_run_id :=igs_ad_imp_001.g_interface_run_id; -- fetching the interface run ID from the AD imp process.
                                                           -- Every child records needs to be updated with this value.
  -- <nsidana 9/25/2003 Import process enhancements>
  -- fetch the rule before the loop.

  l_rule :=  igs_ad_imp_001.find_source_cat_rule(p_source_type_id=>P_SOURCE_TYPE_ID,p_category=>'PERSON_HOUSING_STATUS');

  -- 1. If the rule is E or I, and the match ind column is not null, update all the records to status 3 as they are invalids.

  IF ((l_rule='E') OR (l_rule='I')) THEN
      UPDATE igs_pe_housing_int phi
      SET status     = '3',
          error_code = 'E695'
      WHERE phi.status           = '2' AND
            phi.interface_run_id = l_interface_run_id AND
            phi.match_ind        IS NOT NULL;
  END IF;

  -- 2 . If rule is E and the match ind is null, we update the interface table for all duplicate records with status 1 and match ind 19.

  IF (l_rule = 'E') THEN
          UPDATE igs_pe_housing_int phi
          SET    status    = '1',
                 match_ind = '19'
          WHERE  phi.status           = '2' AND
                 phi.interface_run_id = l_interface_run_id AND
                 EXISTS
                 (SELECT 1
                  FROM igs_pe_teach_periods_all pi, igs_ad_interface_all ai
                  WHERE phi.interface_id = ai.interface_id AND
		        ai.interface_run_id = l_interface_run_id AND
                        ai.person_id = pi.person_id AND
                        UPPER(phi.cal_type) = pi.cal_type AND
          	        phi.sequence_number = pi.sequence_number);
  END IF;

  -- 3. If rule is R and the record status is 18,19,22,23 these records have been processed, but didn't get updated. Update them to 1

  IF (l_rule='R') THEN
          UPDATE igs_pe_housing_int phi
          SET status = '1'
          WHERE phi.status           = '2' AND
                phi.interface_run_id = l_interface_run_id AND
                phi.match_ind        IN ('18','19','22','23');
  END IF;

  -- 4. If rule is R and the match ind is not null and is neither 21 nor 25, update it to errored record.

  IF (l_rule = 'R') THEN
          UPDATE igs_pe_housing_int phi
          SET status = '3', error_code = 'E695'
          WHERE  phi.status = '2' AND
                 phi.interface_run_id = l_interface_run_id AND
                 (phi.match_ind IS NOT NULL AND phi.match_ind NOT IN ('21','25'));
  END IF;

  -- 5. If rule = 'R' and there is no discprepency in duplicate records, update them to status 1 and match ind 23.

  IF (l_rule ='R') THEN
          UPDATE igs_pe_housing_int phi
          SET status     = '1', match_ind  = '23'
          WHERE  phi.status            = '2' AND
                 phi.interface_run_id  = l_interface_run_id AND
                 phi.match_ind         IS NULL AND
                 EXISTS
                 (SELECT 1
                  FROM   igs_pe_teach_periods_all pi, igs_ad_interface_all ai
                  WHERE  phi.interface_id = ai.interface_id AND
		         ai.interface_run_id = l_interface_run_id AND
			 pi.person_id = ai.person_id AND
			 pi.TEACH_PERIOD_RESID_STAT_CD = UPPER(phi.TEACH_PERIOD_RESID_STAT_CD) AND
                  	 pi.cal_type = UPPER(phi.cal_type) AND
                  	 pi.sequence_number = phi.sequence_number
                    ) ;
  END IF;

  -- 6. If rule is R and there are still some records, they are the ones for which there is some discrepency existing. Update them to status 3
  -- and value from the OSS table.

  IF (l_rule ='R') THEN
          UPDATE igs_pe_housing_int phi
          SET status                  = 3,
              match_ind               = 20,
              dup_teaching_period_id  = (SELECT pi.teaching_period_id
                                         FROM igs_pe_teach_periods_all pi, igs_ad_interface_all ai
                                         WHERE ai.interface_id = phi.interface_id AND
					       ai.interface_run_id = l_interface_run_id AND
                                               ai.person_id        = pi.person_id AND
                                               UPPER(phi.cal_type) = pi.cal_type AND
                                               phi.sequence_number = pi.sequence_number AND
					       ROWNUM < 2)
          WHERE  phi.status='2' AND
                 phi.interface_run_id = l_interface_run_id AND
                 phi.match_ind IS NULL AND
                 EXISTS
                 (SELECT 1
                  FROM igs_pe_teach_periods_all pi, igs_ad_interface_all ai
                  WHERE ai.interface_run_id = l_interface_run_id AND
		        ai.interface_id = phi.interface_id AND
                        ai.person_id = pi.person_id AND
                        UPPER(phi.cal_type) = pi.cal_type AND
                        phi.sequence_number = pi.sequence_number
                   );
  END IF;

  -- process the remanining records.
  FOR housing_rec IN housing_cur(l_interface_run_id) LOOP
      housing_rec.teach_period_resid_stat_cd := UPPER(housing_rec.teach_period_resid_stat_cd);
      housing_rec.cal_type := UPPER(housing_rec.cal_type);

      l_processed_records := l_processed_records + 1;

      -- For each record picked up do the following :
      -- Check to see if the record already exists.
      dup_chk_housing_rec.teaching_period_id := NULL;
      OPEN  dup_chk_housing_cur(housing_rec.person_id,
        		        housing_rec.cal_type,
				housing_rec.sequence_number
				);
      FETCH dup_chk_housing_cur INTO dup_chk_housing_rec;
      CLOSE dup_chk_housing_cur;

      --If its a duplicate record find the source category rule for that Source Category.
      IF dup_chk_housing_rec.teaching_period_id IS NOT NULL THEN
          IF ((l_rule = 'I') OR ((l_rule = 'R') AND (housing_rec.match_ind = '21')))THEN
	    IF validate_record(housing_rec,'U') THEN
	          upd_pe_house_status(dup_chk_housing_rec,housing_rec);
	    END IF;
  	  END IF;
      ELSE	-- If its not a duplicate record then Create a new record in OSS
	  IF validate_record(housing_rec,'I') THEN
       		crt_pe_house_status(p_housing_rec => housing_rec);
	  END IF;
      END IF; -- Record existance in IGS_PE_TEACH_PERIODS check

      IF l_processed_records = 100 THEN
          COMMIT;
          l_processed_records := 0;
      END IF;
  END LOOP;
END prc_pe_house_status;


PROCEDURE  Prc_Pe_Felony_Dtls(
                   p_source_type_id     IN      NUMBER,
                   p_batch_id   IN      NUMBER ) AS
	/*
	  ||  Created By :Sarakshi
	  ||  Created On :12-Nov-2001
          ||  Purpose : This procedure is for importing Person Felony Details Information.
          ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
          || npalanis         22-JAN-2003     Bug : 2735882
          ||                                  Validation for birth date added
          || npalanis         6-JAN-2003      Bug : 2734697
          ||                                  code added to commit after import of every
          ||                                  100 records .New variable l_processed_records added
          || npalanis         23-DEC-2002    Bug : 2523488
          ||                                 check added to validate that crime date is not greater than sysdate
          || npalanis         30_OCT-2002      Bug : 2608360
          ||                                   Trunc function added to crime date and nvl added for
          ||                                   disp_action_info
        */

        l_prog_label  VARCHAR2(100);
        l_label  VARCHAR2(100);
        l_debug_str VARCHAR2(2000);
        l_enable_log VARCHAR2(1);
        l_request_id NUMBER;

	--Pick up the records for processing from the Felony Details Interface Table
        CURSOR felony_dtls_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
        SELECT ai.*, i.person_id
        FROM igs_pe_flny_dtl_int  ai,
	     igs_ad_interface_all     i
        WHERE   ai.interface_id  = i.interface_id
        AND     ai.status      =  '2'
        AND     ai.interface_run_id=cp_interface_run_id
	AND     i.interface_run_id = cp_interface_run_id;

        --Cursor to check whether the Record in Interface Table already exists in OSS table
        CURSOR dup_chk_cur ( felony_dtls_rec felony_dtls_cur%ROWTYPE)IS
        SELECT pf.rowid,pf.*  -- select all the feilds from the OSS table to avoid opening the cursor below.
        FROM igs_pe_felony_dtls pf
        WHERE person_id    = felony_dtls_rec.person_id
        AND   UPPER(crime_nature) = UPPER(felony_dtls_rec.crime_nature)
        AND   TRUNC(crime_date)   = TRUNC(felony_dtls_rec.crime_date);

        dup_chk_rec dup_chk_cur%ROWTYPE;

        l_rule       VARCHAR2(1);
        l_status     IGS_PE_FLNY_DTL_INT.status%TYPE;
        l_error_code IGS_PE_FLNY_DTL_INT.error_code%TYPE;
        l_processed_records NUMBER(5) := 0;
        l_message_name  VARCHAR2(30) := NULL;
        l_app           VARCHAR2(50) := NULL;

        -- Start of Local Procedure validate_felony_dtls
FUNCTION validate_felony_dtls(p_felony_dtls_cur    felony_dtls_cur%ROWTYPE) RETURN BOOLEAN IS
	 l_error_code IGS_PE_FLNY_DTL_INT.error_code%TYPE;
BEGIN

     -- Convict_Indicator Validation
     IF p_felony_dtls_cur.convict_ind NOT IN('Y','N') THEN
	l_error_code :='E115';
	RAISE NO_DATA_FOUND;
     END IF;

     -- Bug : 2523488
     -- check added to validate that crime date is not greater than sysdate
     IF p_felony_dtls_cur.crime_date > TRUNC(SYSDATE) THEN
	l_error_code :='E578';
	RAISE NO_DATA_FOUND;
     END IF;

     RETURN TRUE;
EXCEPTION
WHEN  NO_DATA_FOUND THEN
  IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(p_felony_dtls_cur.interface_felony_dtls_id,l_error_code,'IGS_PE_FLNY_DTL_INT');
  END IF;

  UPDATE igs_pe_flny_dtl_int
  SET status     = '3',
      error_code = l_error_code
  WHERE interface_felony_dtls_id = p_felony_dtls_cur.interface_felony_dtls_id;
  RETURN FALSE;
END validate_felony_dtls;
    -- End Local Validate_Felony_Dtls

        -- Start of local procedure crt_pe_felony_dtls
	-- kumma, added one more parameter to the Igs_Pe_Felony_Dtls_Pkg.insert_row, #2608360

PROCEDURE  crt_pe_felony_dtls( p_felony_dtls_rec     felony_dtls_cur%ROWTYPE,
			       p_status OUT NOCOPY VARCHAR2,
			       p_error_code OUT NOCOPY VARCHAR2) AS

l_rowid                VARCHAR2(25);
l_felony_dtls_id       IGS_PE_FELONY_DTLS.felony_details_id%TYPE;

BEGIN
     -- Call Log header

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

	IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	END IF;

	l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_felony_dtls.begin_crt_pe_felony_dtls';
	l_debug_str :=  'igs_ad_imp_025.crt_pe_felony_dtls';

	fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;
     Igs_Pe_Felony_Dtls_Pkg.insert_row (
       x_rowid             => l_rowid ,
       x_felony_details_id => l_felony_dtls_id,
       x_person_id         => p_felony_dtls_rec.person_id,
       x_crime_nature      => p_felony_dtls_rec.crime_nature,
       x_crime_date        => p_felony_dtls_rec.crime_date,
       x_convict_ind       => p_felony_dtls_rec.convict_ind,
       x_disp_action_info  => p_felony_dtls_rec.disp_action_info,
       x_mode              => 'R');

     p_status :='1';
     p_error_code :=NULL;

  EXCEPTION
    WHEN OTHERS THEN

            FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

           IF l_message_name = 'IGS_PE_INT_DT_LT_BRDT' THEN
             p_status     :='3';
             p_error_code := 'E579';

	   ELSIF l_message_name = 'IGS_PE_SS_FLNY_CANT_INSERT' THEN
             p_status     :='3';
             p_error_code := 'E167';
           ELSIF l_message_name = 'IGS_PE_SS_NO_CRMNL_CONVICT' THEN
	     p_status := '3';
	     p_error_code := 'E166';
	   ELSE
             p_status     :='3';
             p_error_code := 'E120';

	   IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_felony_dtls.exception_crt_pe_felony_dtls';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',p_felony_dtls_rec.interface_felony_dtls_id);
		 fnd_message.set_token('ERROR_CD',p_error_code);

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	   END IF;
         END IF;
	   IF l_enable_log = 'Y' THEN
		 igs_ad_imp_001.logerrormessage(p_felony_dtls_rec.interface_felony_dtls_id,p_error_code,'IGS_PE_FLNY_DTL_INT');
	   END IF;
        END crt_pe_felony_dtls;
        --
        -- End  of Local Procedure crt_pe_felony_dtls
        --Start of main procedure
BEGIN
        -- Call Log header
	l_prog_label := 'igs.plsql.igs_ad_imp_025.prc_pe_felony_dtls';
        l_label      := 'igs.plsql.igs_ad_imp_025.prc_pe_felony_dtls.';
        l_enable_log := igs_ad_imp_001.g_enable_log;
        l_interface_run_id:=igs_ad_imp_001.g_interface_run_id; -- fetching the interface run ID from the AD imp process.
                                                           -- Every child records needs to be updated with this value.

	IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		END IF;

		l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_felony_dtls.begin';
		l_debug_str :=  'igs_ad_imp_025.prc_pe_felony_dtls';

		fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	END IF;

        --<nsidana 9/25/2003 Import process enhancements>

        l_rule :=Igs_Ad_Imp_001.find_source_cat_rule(p_source_type_id,'PERSON_DISCIPLINARY_DTLS');


        -- 1. If the rule is E or I, and the match ind column is not null, update all the records to status 3 as they are invalids.

      IF ((l_rule='E') OR (l_rule='I')) THEN
        UPDATE igs_pe_flny_dtl_int pfi
        SET status     = '3',
            error_code = 'E695'
        WHERE pfi.status           = '2' AND
              pfi.interface_run_id = l_interface_run_id AND
              pfi.match_ind        IS NOT NULL;
      END IF;

       -- 2 . If rule is E and the match ind is null, we update the interface table for all duplicate records with status 1 and match ind 19.

      IF (l_rule = 'E') THEN
        UPDATE igs_pe_flny_dtl_int pfi
        SET status    = '1',
            match_ind = '19'
        WHERE pfi.status           = '2' AND
              pfi.interface_run_id = l_interface_run_id AND
              pfi.match_ind        IS NULL AND
              EXISTS (SELECT 1
                      FROM igs_pe_felony_dtls   pi,
                           igs_ad_interface_all aii
                      WHERE pfi.interface_id = aii.interface_id
			    AND     aii.interface_run_id = l_interface_run_id
			    AND     aii.person_id    = pi.person_id
			    AND     UPPER(pfi.crime_nature) =   UPPER(pi.crime_nature)
			    AND     TRUNC(pfi.crime_date)   =   TRUNC(pi.crime_date));
      END IF;

         -- 3. If rule is R and the record status is 18,19,22,23 these records have been processed, but didn't get updated. Update them to 1

      IF (l_rule='R') THEN
              UPDATE igs_pe_flny_dtl_int pfi
              SET status = 1
              WHERE pfi.status           = '2' AND
                   pfi.interface_run_id = l_interface_run_id AND
                   pfi.match_ind        IN ('18','19','22','23');
      END IF;

         -- 4. If rule is R and the match ind is not null and is neither 21 nor 25, update it to errored record.

      IF (l_rule = 'R') THEN
              UPDATE igs_pe_flny_dtl_int pfi
              SET status = 3,
                  error_code = 'E695'
              WHERE pfi.status = '2' AND
                     pfi.interface_run_id = l_interface_run_id AND
                     (pfi.match_ind IS NOT NULL AND pfi.match_ind NOT IN ('21','25'));
      END IF;

         -- 5. If rule = 'R' and there is no discprepency in duplicate records, update them to status 1 and match ind 23.

      IF (l_rule ='R') THEN
             UPDATE igs_pe_flny_dtl_int pfi
             SET status = '1',
                 match_ind = '23'
             WHERE pfi.status = '2' AND
                    pfi.interface_run_id = l_interface_run_id AND
                    pfi.match_ind IS NULL AND
                    EXISTS
                    (SELECT 1
                     FROM   igs_pe_felony_dtls pi,
                            igs_ad_interface_all aii
                     WHERE pfi.interface_id  = aii.interface_id
		        AND aii.interface_run_id = l_interface_run_id
                        AND     NVL(aii.person_id,-99)= NVL(pi.person_id,-99)
                        AND     UPPER(pfi.crime_nature) = UPPER(pi.crime_nature)
                        AND     TRUNC(pfi.crime_date) = TRUNC(pi.crime_date)
                        AND     UPPER(pfi.convict_ind) = UPPER(pi.convict_ind)
                        AND     NVL(UPPER(pfi.disp_action_info),'*!*')  = NVL(UPPER(pi.disp_action_info),'*!*')
                     );
      END IF;

         -- 6. If rule is R and there are still some records, they are the ones for which there is some discrepency existing. Update them to status 3
         -- and value from the OSS table.

      IF (l_rule ='R') THEN
             UPDATE igs_pe_flny_dtl_int pfi
             SET status='3',
                 match_ind='20',
                 dup_felony_details_id=(SELECT pi.FELONY_DETAILS_ID
                                        FROM    igs_pe_felony_dtls pi,
                                                igs_ad_interface_all aii
                                        WHERE pfi.interface_id    = aii.interface_id
					  AND aii.interface_run_id = l_interface_run_id
                                          AND     aii.person_id           = pi.person_id
                                          AND     UPPER(pfi.crime_nature) = UPPER(pi.crime_nature)
                                          AND     TRUNC(pfi.crime_date)   = TRUNC(pi.crime_date))
             WHERE  pfi.status='2' AND
                    pfi.interface_run_id = l_interface_run_id AND
                    pfi.match_ind IS NULL AND
                    EXISTS
                    (SELECT 1
                     FROM igs_pe_felony_dtls       pi,
                          igs_ad_interface_all     aii
                     WHERE pfi.interface_id    = aii.interface_id
		     AND aii.interface_run_id = l_interface_run_id
                     AND    aii.person_id = pi.person_id
                     AND     UPPER(pfi.crime_nature) = UPPER(pi.crime_nature)
                     AND     TRUNC(pfi.crime_date)   = TRUNC(pi.crime_date));

         END IF;

        -- Process the remaining records now...

        FOR felony_dtls_rec IN felony_dtls_cur(l_interface_run_id) LOOP

          l_processed_records := l_processed_records + 1;

          felony_dtls_rec.crime_date := TRUNC(felony_dtls_rec.crime_date);
          --Validate the record picked up from interface table
          IF validate_felony_dtls( felony_dtls_rec) THEN
             -- for every record check whether a corresponding row
             -- already exists in the table igs_pe_felony_dtls.
             dup_chk_rec.felony_details_id :=NULL;
             OPEN dup_chk_cur ( felony_dtls_rec );
             FETCH dup_chk_cur INTO dup_chk_rec;
             CLOSE dup_chk_cur;

             IF dup_chk_rec.felony_details_id IS NOT NULL  THEN
                --If its a duplicate record find the source category rule for that Source Category.

              IF l_rule = 'I' THEN
                  BEGIN
                        igs_pe_felony_dtls_pkg.update_row(
                            x_rowid            => dup_chk_rec.rowid,
                            x_felony_details_id=> dup_chk_rec.felony_details_id,
                            x_person_id        =>NVL( felony_dtls_rec.person_id,dup_chk_rec.person_id),
                            x_crime_nature     => dup_chk_rec.crime_nature,
                            x_crime_date       => dup_chk_rec.crime_date,
                            x_convict_ind      => felony_dtls_rec.convict_ind,
			    x_disp_action_info => nvl(felony_dtls_rec.disp_action_info,dup_chk_rec.disp_action_info),
                            x_mode             => 'R'
                            );
                        UPDATE igs_pe_flny_dtl_int
                        SET status = '1',
                            error_code=NULL,
                            match_ind='18'
                        WHERE interface_felony_dtls_id = felony_dtls_rec.interface_felony_dtls_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                             FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
                             IF l_message_name = 'IGS_PE_INT_DT_LT_BRDT' THEN
                                 l_status     :='3';
                                 l_error_code := 'E579';

			     ELSIF l_message_name = 'IGS_PE_SS_NO_CRMNL_CONVICT' THEN
				 l_status     :='3';
				 l_error_code := 'E166';

			     ELSE
                                 l_status     :='3';
                                 l_error_code := 'E121';
			     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

				 IF (l_request_id IS NULL) THEN
				    l_request_id := fnd_global.conc_request_id;
				 END IF;

				 l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_felony_dtls.exception';

				 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
				 fnd_message.set_token('INTERFACE_ID',felony_dtls_rec.interface_felony_dtls_id);
				 fnd_message.set_token('ERROR_CD',l_error_code);

				 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

				 fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			     END IF;
                             END IF;
   		             IF l_enable_log = 'Y' THEN
			            igs_ad_imp_001.logerrormessage(felony_dtls_rec.interface_felony_dtls_id,l_error_code,'IGS_PE_FLNY_DTL_INT');
		             END IF;

                             UPDATE igs_pe_flny_dtl_int
                             SET status     = l_status ,
                                 error_code = l_error_code
                             WHERE interface_felony_dtls_id = felony_dtls_rec.interface_felony_dtls_id;
                  END;
                ELSIF l_rule = 'R' THEN
                  IF felony_dtls_rec.match_ind = '21' THEN
                    BEGIN
                          igs_pe_felony_dtls_pkg.update_row(
                             x_rowid            => dup_chk_rec.rowid,
                             x_felony_details_id=> dup_chk_rec.felony_details_id,
                             x_person_id        =>NVL( dup_chk_rec.person_id,dup_chk_rec.person_id),
                             x_crime_nature     =>felony_dtls_rec.crime_nature,
                             x_crime_date       => felony_dtls_rec.crime_date,
                             x_convict_ind      => felony_dtls_rec.convict_ind,
			     x_disp_action_info => NVL(felony_dtls_rec.disp_action_info,dup_chk_rec.disp_action_info),
                             x_mode             => 'R'
                            );

                          UPDATE igs_pe_flny_dtl_int
                          SET status = '1',
                              match_ind='18',
                              error_code=NULL
                          WHERE interface_felony_dtls_id = felony_dtls_rec.interface_felony_dtls_id;
                   EXCEPTION
                   WHEN OTHERS THEN

		     FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

		     IF l_message_name = 'IGS_PE_INT_DT_LT_BRDT' THEN
			 l_status     :='3';
			 l_error_code := 'E579';

		     ELSIF l_message_name = 'IGS_PE_SS_NO_CRMNL_CONVICT' THEN
			 l_status     :='3';
			 l_error_code := 'E166';
		     ELSE
			 l_status     :='3';
			 l_error_code := 'E121';

			     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

				   IF (l_request_id IS NULL) THEN
				    l_request_id := fnd_global.conc_request_id;
				   END IF;

				   l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_felony_dtls.exception1';

				   fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
				   fnd_message.set_token('INTERFACE_ID',felony_dtls_rec.interface_felony_dtls_id);
				   fnd_message.set_token('ERROR_CD',l_error_code);

				   l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

				   fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			    END IF;
		     END IF;

		    IF l_enable_log = 'Y' THEN
			  igs_ad_imp_001.logerrormessage(felony_dtls_rec.interface_felony_dtls_id,l_error_code,'IGS_PE_FLNY_DTL_INT');
		    END IF;

		    UPDATE igs_pe_flny_dtl_int
		     SET status     = l_status ,
			 error_code = l_error_code
		     WHERE interface_felony_dtls_id = felony_dtls_rec.interface_felony_dtls_id;
                    END;
                  END IF; -- end if for match_ind = '21'
                END IF; -- end if for l_rule
              ELSE--Duplicate record does not exists
                 --Insert the record in the oss table
                 crt_pe_felony_dtls(
                                   p_felony_dtls_rec => felony_dtls_rec,
                                   p_status        =>l_status,
                                   p_error_code    =>l_error_code );
                 UPDATE igs_pe_flny_dtl_int
                 SET status     = l_status,
                     error_code = l_error_code
                 WHERE interface_felony_dtls_id = felony_dtls_rec.interface_felony_dtls_id;
              END IF;-- For Dup_cur
          END IF;--validate record

          IF l_processed_records = 100 THEN
             COMMIT;
             l_processed_records := 0;
          END IF;
        END LOOP;
END prc_pe_felony_dtls;
--
-- End of Main Procedure PRC_PE_FELONY_DTLS
--

PROCEDURE  Prc_Pe_Hearing_Dtls(
                   p_source_type_id     IN      NUMBER,
                   p_batch_id   IN      NUMBER ) AS
	/*
	  ||  Created By :Sarakshi
	  ||  Created On :12-Nov-2001
	  ||  Purpose : This procedure imports Person Hearing Details
	  ||            Bug no.2103692:Person Interface DLD
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
          || npalanis         22-JAN-2003     Bug : 2735882
          ||                                  Validation for birth date added
          || npalanis         6-JAN-2003      Bug : 2734697
          ||                                  code added to commit after import of every
          ||                                  100 records .New variable l_processed_records added
        */

	l_default_date DATE;

        l_prog_label  VARCHAR2(100);
        l_label  VARCHAR2(100);
        l_debug_str VARCHAR2(2000);
        l_enable_log VARCHAR2(1);
        l_request_id NUMBER;

	--Pick up the records for processing from the Hearing Details Interface Table
        CURSOR hearing_dtls_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
        SELECT ai.*, i.person_id
        FROM igs_pe_hear_dtl_int  ai,
             igs_ad_interface_all i
        WHERE ai.interface_id  = i.interface_id
        AND   ai.status        = '2'
        AND   ai.interface_run_id=cp_interface_run_id
	AND   i.interface_run_id = cp_interface_run_id;

        --Cursor to check whether the Record in Interface Table already exists in OSS table
        CURSOR dup_chk_cur ( hearing_dtls_rec hearing_dtls_cur%ROWTYPE)IS
        SELECT pd.rowid,pd.*  -- <nsidana 9/25/2003 Import process enhancements. Fetching all values here to avoid calling the cursor below.>
        FROM igs_pe_hearing_dtls pd
        WHERE person_id              = hearing_dtls_rec.person_id
        AND   UPPER(description)     = UPPER(hearing_dtls_rec.description)
        AND   NVL(TRUNC(start_date),l_default_date)= NVL(TRUNC(hearing_dtls_rec.start_date),l_default_date);
        dup_chk_rec dup_chk_cur%ROWTYPE;

        l_rule       VARCHAR2(1);
        l_status     IGS_PE_HEAR_DTL_INT.status%TYPE;
        l_error_code IGS_PE_HEAR_DTL_INT.error_code%TYPE;
        l_processed_records NUMBER(5) := 0;
        l_app VARCHAR2(50) := NULL;
        l_message_name VARCHAR2(30) := NULL;
        --
        -- Start of Local Procedure validate_hearing_dtls
        --
        FUNCTION  validate_hearing_dtls(p_hearing_dtls_cur  hearing_dtls_cur%ROWTYPE) RETURN BOOLEAN  IS
                  l_error_code IGS_PE_HEAR_DTL_INT.error_code%TYPE;
        BEGIN

             -- disp_file_ind Validation
             IF p_hearing_dtls_cur.dspl_file_ind NOT IN('Y','N') THEN
                l_error_code :='E116';
                RAISE NO_DATA_FOUND;
             END IF;
             -- acad_dism_ind Validation
             IF p_hearing_dtls_cur.acad_dism_ind NOT IN('Y','N') THEN
                l_error_code :='E117';
                RAISE NO_DATA_FOUND;
             END IF;
             -- non_acad_dism_ind Validation
             IF p_hearing_dtls_cur.non_acad_dism_ind NOT IN('Y','N') THEN
                l_error_code :='E118';
                RAISE NO_DATA_FOUND;
             END IF;
             --start_date / end_date validation
             IF (p_hearing_dtls_cur.start_date IS NOT NULL) AND ( p_hearing_dtls_cur.end_date IS NOT NULL) THEN
                IF p_hearing_dtls_cur.start_date > p_hearing_dtls_cur.end_date THEN
                   l_error_code :='E119';
                   RAISE NO_DATA_FOUND;
                END IF;
             END IF;

             RETURN TRUE;
        EXCEPTION
                WHEN  NO_DATA_FOUND THEN
                 IF l_enable_log = 'Y' THEN
		            igs_ad_imp_001.logerrormessage(p_hearing_dtls_cur.interface_hearing_dtls_id,l_error_code,'IGS_PE_HEAR_DTL_INT');
        		 END IF;

                  UPDATE igs_pe_hear_dtl_int
                  SET status     = '3',
                      error_code = l_error_code
                  WHERE interface_hearing_dtls_id = p_hearing_dtls_cur.interface_hearing_dtls_id;
                  RETURN FALSE;
        END validate_hearing_dtls;
        -- End Local Validate_Hearing_Dtls

        -- Start of local procedure crt_pe_hearing_dtls
        PROCEDURE  crt_pe_hearing_dtls
                ( p_hearing_dtls_rec     hearing_dtls_cur%ROWTYPE,
                  p_status OUT NOCOPY VARCHAR2,
                  p_error_code OUT NOCOPY VARCHAR2) AS

                  l_rowid                 VARCHAR2(25);
                  l_hearing_details_id    IGS_PE_HEARING_DTLS.hearing_details_id%TYPE;
        BEGIN

	      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		END IF;

		l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_hearing_dtls.begin_crt_pe_hearing_dtls';
		l_debug_str :=  'Igs_Ad_Imp_025.Prc_Pe_Hearing_Dtls.Crt_Pe_hearing_dtls';

		fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	      END IF;

              Igs_Pe_Hearing_Dtls_Pkg.insert_row (
                  x_rowid             => l_rowid ,
                  x_hearing_details_id=> l_hearing_details_id,
                  x_person_id         => p_hearing_dtls_rec.person_id,
                  x_description       => p_hearing_dtls_rec.description,
                  x_start_date        => p_hearing_dtls_rec.start_date,
                  x_end_date          => p_hearing_dtls_rec.end_date,
                  x_dspl_file_ind     => p_hearing_dtls_rec.dspl_file_ind,
                  x_acad_dism_ind     => p_hearing_dtls_rec.acad_dism_ind,
                  x_non_acad_dism_ind => p_hearing_dtls_rec.non_acad_dism_ind,
                  x_mode              => 'R'
              );
              p_status     :='1';
              p_error_code :=NULL;

        EXCEPTION
                WHEN OTHERS THEN

                  FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED,l_app,l_message_name);

                  IF l_message_name = 'IGS_AD_STRT_DT_LESS_BIRTH_DT' THEN
                     p_status     :='3';
                     p_error_code := 'E222';
                  ELSIF l_message_name = 'IGS_PE_CANT_SPECIFY_FROM_DATE' THEN
                     p_status     :='3';
                     p_error_code := 'E582';
                  ELSE
                     p_status     :='3';
                     p_error_code := 'E122';
			  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

				 IF (l_request_id IS NULL) THEN
				    l_request_id := fnd_global.conc_request_id;
				 END IF;

				 l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_hearing_dtls.exception_crt_pe_hearing_dtls';

				 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
				 fnd_message.set_token('INTERFACE_ID',p_hearing_dtls_rec.interface_hearing_dtls_id);
				 fnd_message.set_token('ERROR_CD',p_error_code);

				 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

				 fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			END IF;
                  END IF;
                IF l_enable_log = 'Y' THEN
		          igs_ad_imp_001.logerrormessage(p_hearing_dtls_rec.interface_hearing_dtls_id,p_error_code,'IGS_PE_HEAR_DTL_INT');
        		END IF;

        END crt_pe_hearing_dtls;
        --
        -- End  of Local Procedure
        --
BEGIN
        l_default_date      := IGS_GE_DATE.IGSDATE('4712/12/31');
	l_prog_label        := 'igs.plsql.igs_ad_imp_025.prc_pe_hearing_dtls';
        l_label             := 'igs.plsql.igs_ad_imp_025.prc_pe_hearing_dtls.';
        l_enable_log        := igs_ad_imp_001.g_enable_log;
        l_interface_run_id  := igs_ad_imp_001.g_interface_run_id; -- fetching the interface run ID from the AD imp process.
                                                               -- Every child records needs to be updated with this value.

        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		END IF;

		l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_hearing_dtls.begin';
		l_debug_str :=  'Igs_Ad_Imp_025.Prc_Pe_Hearing_Dtls';

		fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	END IF;


        -- Fetching the Rule outside the loop.

        l_rule :=Igs_Ad_Imp_001.find_source_cat_rule(p_source_type_id,'PERSON_DISCIPLINARY_DTLS');


        -- 1. If the rule is E or I, and the match ind column is not null, update all the records to status 3 as they are invalids.

        IF ((l_rule='E') OR (l_rule='I')) THEN
            UPDATE igs_pe_hear_dtl_int pdi
            SET status     = '3',
                error_code = 'E695'
            WHERE pdi.status           = '2' AND
                  pdi.interface_run_id = l_interface_run_id AND
                  pdi.match_ind        IS NOT NULL;
        END IF;

       -- 2 . If rule is E and the match ind is null, we update the interface table for all duplicate records with status 1 and match ind 19.

        IF (l_rule = 'E') THEN
            UPDATE igs_pe_hear_dtl_int pdi
            SET    status    = '1',
                   match_ind = '19'
            WHERE  pdi.status           = '2' AND
                   pdi.interface_run_id = l_interface_run_id AND
                   EXISTS (SELECT 1
			    FROM igs_pe_hearing_dtls  pi,
				 igs_ad_interface_all aiii
			    WHERE     pdi.interface_id = aiii.interface_id
			      AND     aiii.interface_run_id = l_interface_run_id
			      AND     aiii.person_id = pi.person_id
			      AND     UPPER(pdi.description) = UPPER(pi.description)
			      AND     NVL(TRUNC(pdi.start_date),l_default_date) = NVL(TRUNC(pi.start_date),l_default_date)
			    );
        END IF;

         -- 3. If rule is R and the record status is 18,19,22,23 these records have been processed, but didn't get updated. Update them to 1

        IF (l_rule='R') THEN
              UPDATE igs_pe_hear_dtl_int pdi
              SET status = '1'
              WHERE pdi.status           = '2' AND
                   pdi.interface_run_id = l_interface_run_id AND
                   pdi.match_ind        IN ('18','19','22','23');
        END IF;


         -- 4. If rule is R and the match ind is not null and is neither 21 nor 25, update it to errored record.

        IF (l_rule = 'R') THEN
              UPDATE igs_pe_hear_dtl_int pdi
              SET status = '3',
                  error_code = 'E695'
              WHERE  pdi.status = '2' AND
                     pdi.interface_run_id = l_interface_run_id AND
                     (pdi.match_ind IS NOT NULL AND pdi.match_ind NOT IN ('21','25'));
        END IF;

         -- 5. If rule = 'R' and there is no discprepency in duplicate records, update them to status 1 and match ind 23.

        IF (l_rule ='R') THEN
             UPDATE igs_pe_hear_dtl_int pdi
             SET    status = '1',
                    match_ind = '23'
             WHERE  pdi.status = '2' AND
                    pdi.interface_run_id = l_interface_run_id AND
                    pdi.match_ind IS NULL AND
                    EXISTS (SELECT 1
			     FROM   igs_pe_hearing_dtls pi,
				    igs_ad_interface_all aiii
			     WHERE  NVL(pi.person_id,-99) = NVL(aiii.person_id,-99)
			     AND    pdi.interface_id = aiii.interface_id
			     AND    aiii.interface_run_id = l_interface_run_id
			     AND    UPPER(pi.description) = UPPER(pdi.description)
			     AND    NVL(TRUNC(pi.start_date),l_default_date)= NVL(TRUNC(pdi.start_date),l_default_date)
			     AND    NVL(TRUNC(pi.end_date),l_default_date)  = NVL(TRUNC(pdi.end_date),l_default_date)
			     AND    UPPER(pi.dspl_file_ind) = UPPER(pdi.dspl_file_ind)
			     AND    UPPER(pi.acad_dism_ind) = UPPER(pdi.acad_dism_ind)
			     AND    UPPER(pi.non_acad_dism_ind) = UPPER(pdi.non_acad_dism_ind));
         END IF;

         -- 6. If rule is R and there are still some records, they are the ones for which there is some discrepency existing. Update them to status 3
         -- and value from the OSS table.

         IF (l_rule ='R') THEN
             UPDATE igs_pe_hear_dtl_int pdi
             SET status = '3',
                 match_ind = '20',
                 dup_hearing_details_id=(SELECT pi.hearing_details_id
                                          FROM   igs_pe_hearing_dtls pi,
                                                 igs_ad_interface_all aiii
                                          WHERE  pdi.interface_id = aiii.interface_id
                    					  AND aiii.interface_run_id = l_interface_run_id
                                          AND aiii.person_id = pi.person_id
                                          AND UPPER(pdi.description) = UPPER(pi.description)
                                          AND NVL(TRUNC(pdi.start_date),l_default_date)= NVL(TRUNC(pi.start_date),l_default_date)
										  AND ROWNUM = 1)
             WHERE
                    pdi.status='2' AND
                    pdi.interface_run_id = l_interface_run_id AND
                    pdi.match_ind IS NULL AND
                    EXISTS (SELECT 1
  			        FROM igs_pe_hearing_dtls pi,
				         igs_ad_interface_all aiii
			         WHERE pdi.interface_id = aiii.interface_id
			         AND aiii.interface_run_id = l_interface_run_id
			         AND aiii.person_id = pi.person_id
			         AND UPPER(pdi.description) = UPPER(pi.description)
			         AND NVL(TRUNC(pdi.start_date),l_default_date)
			           = NVL(TRUNC(pi.start_date),l_default_date));
         END IF;

         -- Process the rest of the records now...

        FOR hearing_dtls_rec IN hearing_dtls_cur(l_interface_run_id) LOOP

           l_processed_records := l_processed_records + 1;
           hearing_dtls_rec.start_date := TRUNC(hearing_dtls_rec.start_date);
	   hearing_dtls_rec.end_date := TRUNC(hearing_dtls_rec.end_date);
	   hearing_dtls_rec.non_acad_dism_ind := UPPER(hearing_dtls_rec.non_acad_dism_ind);
	   hearing_dtls_rec.acad_dism_ind := UPPER(hearing_dtls_rec.acad_dism_ind);
	   hearing_dtls_rec.dspl_file_ind := UPPER(hearing_dtls_rec.dspl_file_ind);

	   IF validate_hearing_dtls(hearing_dtls_rec) THEN
              dup_chk_rec.hearing_details_id := NULL;
              OPEN dup_chk_cur (hearing_dtls_rec);
              FETCH dup_chk_cur INTO dup_chk_rec;
              CLOSE dup_chk_cur;
              IF dup_chk_rec.hearing_details_id IS NOT NULL  THEN
                --If its a duplicate record find the source category rule for that Source Category.
              IF l_rule = 'I' THEN
                  BEGIN
                       igs_pe_hearing_dtls_pkg.update_row(
                          x_rowid             => dup_chk_rec.rowid,
                          x_hearing_details_id=>dup_chk_rec.hearing_details_id,
                          x_person_id         => NVL(hearing_dtls_rec.person_id,dup_chk_rec.person_id),
                          x_description       => hearing_dtls_rec.description,
                          x_start_date        =>NVL( hearing_dtls_rec.start_date,dup_chk_rec.start_date),
                          x_end_date          => NVL(hearing_dtls_rec.end_date,dup_chk_rec.end_date),
                          x_dspl_file_ind     => hearing_dtls_rec.dspl_file_ind,
                          x_acad_dism_ind     => hearing_dtls_rec.acad_dism_ind,
                          x_non_acad_dism_ind => hearing_dtls_rec.non_acad_dism_ind,
                          x_mode              => 'R'
                         );
                       UPDATE igs_pe_hear_dtl_int
                       SET status = '1',
                           error_code=NULL,
                           match_ind='18'
                       WHERE interface_hearing_dtls_id = hearing_dtls_rec.interface_hearing_dtls_id;
                  EXCEPTION
                    WHEN OTHERS THEN

		      FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED,l_app,l_message_name);

		      IF l_message_name = 'IGS_AD_STRT_DT_LESS_BIRTH_DT' THEN
			l_status := '3' ;
			l_error_code  := 'E222';
		      ELSIF l_message_name = 'IGS_PE_CANT_SPECIFY_FROM_DATE' THEN
			l_status := '3' ;
			l_error_code  := 'E582';
		      ELSE
			l_status := '3' ;
			l_error_code  := 'E123';

			IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
 			 IF (l_request_id IS NULL) THEN
			    l_request_id := fnd_global.conc_request_id;
			 END IF;

			 l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_hearing_dtls.exception1';

			 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			 fnd_message.set_token('INTERFACE_ID',hearing_dtls_rec.interface_hearing_dtls_id);
			 fnd_message.set_token('ERROR_CD',l_error_code);

			 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

			 fnd_log.string_with_context( fnd_log.level_exception,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			END IF;
		      END IF;

		      IF l_enable_log = 'Y' THEN
			    igs_ad_imp_001.logerrormessage(hearing_dtls_rec.interface_hearing_dtls_id,l_error_code,'IGS_PE_HEAR_DTL_INT');
		      END IF;

                             UPDATE igs_pe_hear_dtl_int
                             SET status     = l_status,
                                 error_code = l_error_code
                             WHERE interface_hearing_dtls_id = hearing_dtls_rec.interface_hearing_dtls_id;
                  END;
                ELSIF l_rule = 'R' THEN
                  IF hearing_dtls_rec.match_ind = '21' THEN
                    BEGIN
                          igs_pe_hearing_dtls_pkg.update_row(
                             x_rowid             => dup_chk_rec.rowid,
                             x_hearing_details_id=>dup_chk_rec.hearing_details_id,
                             x_person_id         => NVL(hearing_dtls_rec.person_id,dup_chk_rec.person_id),
                             x_description       => hearing_dtls_rec.description,
                             x_start_date        =>NVL( hearing_dtls_rec.start_date,dup_chk_rec.start_date),
                             x_end_date          => NVL(hearing_dtls_rec.end_date,dup_chk_rec.end_date),
                             x_dspl_file_ind     => hearing_dtls_rec.dspl_file_ind,
                             x_acad_dism_ind     => hearing_dtls_rec.acad_dism_ind,
                             x_non_acad_dism_ind => hearing_dtls_rec.non_acad_dism_ind,
                             x_mode              => 'R'
                          );

                          UPDATE igs_pe_hear_dtl_int
                          SET status     = '1',
                              match_ind  = '18',
                              error_code = NULL
                          WHERE interface_hearing_dtls_id = hearing_dtls_rec.interface_hearing_dtls_id;
                    EXCEPTION
                      WHEN OTHERS THEN

                        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED,l_app,l_message_name);

                        IF l_message_name = 'IGS_AD_STRT_DT_LESS_BIRTH_DT' THEN
                                l_status := '3' ;
                                l_error_code  := 'E222';
                        ELSIF l_message_name = 'IGS_PE_CANT_SPECIFY_FROM_DATE' THEN
                                l_status := '3' ;
                                l_error_code  := 'E582';
                        ELSE
                                l_status := '3' ;
                                l_error_code  := 'E123';

				IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

					 IF (l_request_id IS NULL) THEN
					    l_request_id := fnd_global.conc_request_id;
					 END IF;

					 l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_hearing_dtls.exception2';

					 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
					 fnd_message.set_token('INTERFACE_ID',hearing_dtls_rec.interface_hearing_dtls_id);
					 fnd_message.set_token('ERROR_CD',l_error_code);

					 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

					 fnd_log.string_with_context( fnd_log.level_exception,
									  l_label,
									  l_debug_str, NULL,
									  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
				END IF;

                              END IF;

			      IF l_enable_log = 'Y' THEN
				     igs_ad_imp_001.logerrormessage(hearing_dtls_rec.interface_hearing_dtls_id,l_error_code,'IGS_PE_HEAR_DTL_INT');
			      END IF;


                             UPDATE igs_pe_hear_dtl_int
                             SET status     = l_status,
                                 error_code = l_error_code
                             WHERE interface_hearing_dtls_id = hearing_dtls_rec.interface_hearing_dtls_id;
                    END;
                  END IF; -- end if for match_ind = '21'
                END IF; -- end if for l_rule
              ELSE --Not a duplicate record
                 --Insert the record in the oss table
                 crt_pe_hearing_dtls(
                                     p_hearing_dtls_rec => hearing_dtls_rec,
                                     p_status         =>l_status,
                                     p_error_code     =>l_error_code );
                 UPDATE igs_pe_hear_dtl_int
                 SET status     = l_status,
                     error_code = l_error_code
                 WHERE interface_hearing_dtls_id = hearing_dtls_rec.interface_hearing_dtls_id;
              END IF; -- End If for Dup_cur
          END IF;--end of validate record

          IF l_processed_records = 100 THEN
             COMMIT;
             l_processed_records := 0;
          END IF;

        END LOOP;
END prc_pe_hearing_dtls;
--
-- End of Main Procedure PRC_PE_HEARING_DTLS

PROCEDURE  Prc_Pe_Disciplinary_Dtls(
                   p_source_type_id     IN      NUMBER,
                   p_batch_id   IN      NUMBER ) AS
	/*
	  ||  Created By :Sarakshi
	  ||  Created On :12-Nov-2001
	  ||  Purpose : This procedure invokes two procedure for importing felony details and hearing details
	  ||            Bug no.2103692:Person Interface DLD
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
        */
BEGIN
     Prc_Pe_Felony_Dtls(p_source_type_id,p_batch_id);
     Prc_Pe_Hearing_Dtls(p_source_type_id,p_batch_id);
END prc_pe_disciplinary_dtls;


PROCEDURE  prc_pe_race(
                   p_source_type_id     IN      NUMBER,
                   p_batch_id   IN      NUMBER ) AS
	/*
	  ||  Created By :pkpatel
	  ||  Created On :5-FEB-2003
	  ||  Purpose : Multiple Races TD (This procedure is to import data from interface table IGS_PE_RACE_INT to IGS_PE_RACE)
	  ||
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
    */

     l_prog_label  VARCHAR2(100);
     l_label  VARCHAR2(100);
     l_debug_str VARCHAR2(2000);
     l_enable_log VARCHAR2(1);
     l_request_id NUMBER;
     l_dup_race_cd VARCHAR2(30);
     l_processed_records NUMBER(5) := 0;
     l_dup_exists        VARCHAR2(1);
     l_rule              VARCHAR2(1);

    --Pick up the records for processing from the Races Interface Table
    CURSOR race_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT  ai.*,i.person_id
    FROM    igs_pe_race_int ai, igs_ad_interface_all i
    WHERE   ai.interface_id = i.interface_id AND
    	    ai.status = '2' AND
	    ai.interface_run_id=cp_interface_run_id AND
	    i.interface_run_id = cp_interface_run_id;

    --Cursor to check whether the Record in Interface Table already exists in OSS table
    CURSOR dup_chk_race_cur(cp_person_id igs_pe_race.person_id%TYPE, cp_race_cd   igs_pe_race.race_cd%TYPE) IS
    SELECT pr.race_cd
    FROM   igs_pe_race pr
    WHERE  pr.person_id = cp_person_id AND
           pr.race_cd   = cp_race_cd;

    -- Start Local Procedure crt_pe_race
PROCEDURE crt_pe_race(p_race_rec IN race_cur%ROWTYPE) AS
  l_rowid VARCHAR2(25);
BEGIN
	-- Call Log header
	IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		END IF;

		l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_race.begin_crt_pe_race';
		l_debug_str :=  'igs_ad_imp_025.prc_pe_race.crt_pe_race';

		fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	END IF;

	igs_pe_race_pkg.insert_row (
				x_rowid      => l_rowid,
			    x_person_id  => p_race_rec.person_id,
			    x_race_cd    => p_race_rec.race_cd,
			    x_mode       => 'R'
								);
	UPDATE igs_pe_race_int
        SET    status     = '1',
               error_code = NULL
        WHERE  interface_race_id = p_race_rec.interface_race_id;

	EXCEPTION
	    WHEN OTHERS THEN
	       -- Person Race Insertion Failed
	  UPDATE igs_pe_race_int
            SET    status     = '3',
                   error_code = 'E322'
            WHERE  interface_race_id = p_race_rec.interface_race_id;
			-- Call Log detail
            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_race.exception_crt_pe_race';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',p_race_rec.interface_race_id);
		 fnd_message.set_token('ERROR_CD','E322');

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	    END IF;

	    IF l_enable_log = 'Y' THEN
		 igs_ad_imp_001.logerrormessage(p_race_rec.interface_race_id,'E322','IGS_PE_RACE_INT');
	    END IF;

END crt_pe_race;

    -- Local function validate_race_record
FUNCTION validate_race_record(p_race_rec 	IN 	race_cur%ROWTYPE)
	  RETURN BOOLEAN IS

l_exists VARCHAR2(1);
l_error_code igs_pe_race_int.error_code%TYPE;
BEGIN
		-- Call Log header

      IF NOT(igs_pe_pers_imp_001.validate_lookup_type_code('PE_RACE',p_race_rec.race_cd,8405))
      THEN
			   l_error_code := 'E580';
			   RAISE NO_DATA_FOUND;
      END IF;
       -- CLOSE check_race;

       --</nsidana 9/24/2003>

      RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN

	   UPDATE igs_pe_race_int
	   SET    status     = '3',
		  error_code = l_error_code
	   WHERE  interface_race_id = p_race_rec.interface_race_id;

			-- Call Log detail

	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_race.exception_validate_race_record';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',p_race_rec.interface_race_id);
		 fnd_message.set_token('ERROR_CD',l_error_code);

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	       END IF;

	       IF l_enable_log = 'Y' THEN
		     igs_ad_imp_001.logerrormessage(p_race_rec.interface_race_id,l_error_code,'IGS_PE_RACE_INT');
	       END IF;

	       RETURN FALSE;
END validate_race_record;
-- end of local procedure
-- start of main procedure prc_race
BEGIN

   l_prog_label := 'igs.plsql.igs_ad_imp_025.p_race_rec';
   l_label      := 'igs.plsql.igs_ad_imp_025.p_race_rec.';
   l_enable_log := igs_ad_imp_001.g_enable_log;
   l_interface_run_id:=igs_ad_imp_001.g_interface_run_id; -- fetching the interface run ID from the AD imp process.
                                                           -- Every child records needs to be updated with this value.

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

	IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	END IF;

	l_label := 'igs.plsql.igs_ad_imp_025.prc_pe_race.begin';
	l_debug_str :=  'igs_ad_imp_025.prc_pe_race';

	fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
   END IF;

   -- <nsidana 9/25/2003 Import process enhancements.>
    -- Fetching the discrepency rule before the loop.

    l_rule := igs_ad_imp_001.find_source_cat_rule(p_source_type_id, 'PERSON_TYPE');

    -- Update all the duplicate records with status 1 and match_ind 18

    UPDATE igs_pe_race_int  pri
    SET status='1',
        match_ind='18'
    WHERE pri.status='2'
         AND pri.interface_run_id = l_interface_run_id
         AND EXISTS
            (SELECT 1
             FROM igs_pe_race pr,
                  igs_ad_interface_all ai
             WHERE  pri.interface_id=ai.interface_id
	     AND    ai.interface_run_id = l_interface_run_id
             AND    pr.person_id=ai.person_id
             AND    UPPER(pri.race_cd)=UPPER(pr.race_cd)
            );


    FOR race_rec IN race_cur(l_interface_run_id) LOOP

      l_processed_records := l_processed_records + 1;
      race_rec.race_cd := UPPER(race_rec.race_cd);

        -- duplicate check is required to ensure that two duplicate records from
	    -- the interface table donot get inserted into the OSS table
      l_dup_race_cd := NULL;

	  OPEN dup_chk_race_cur(race_rec.person_id, race_rec.race_cd);
      FETCH dup_chk_race_cur INTO l_dup_race_cd;
      CLOSE dup_chk_race_cur;

	  IF l_dup_race_cd IS NULL THEN
    	IF validate_race_record(race_rec) THEN
          crt_pe_race(race_rec);
        END IF;
      ELSE
        UPDATE igs_pe_race_int
	    SET status = '1',
	        match_ind = '18'
    	WHERE interface_race_id = race_rec.interface_race_id;
      END IF;

        IF l_processed_records = 100 THEN
          COMMIT;
          l_processed_records := 0;
        END IF;
    END LOOP;

END prc_pe_race;

PROCEDURE prc_priv_dtls (
			P_SOURCE_TYPE_ID   IN	NUMBER,
			P_BATCH_ID	   IN	NUMBER )
/*
||  Created By : nsidana
||  Created On : 9/7/2004
||  Purpose : This procedure is for importing person privacy details.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
|| nsidana          9/7/2004         Created
*/

IS
	l_rule              VARCHAR2(1);
	l_error_code        igs_pe_privacy_int.error_code%TYPE;
	l_status            igs_pe_privacy_int.status%TYPE;
	l_default_date      DATE;
	l_processed_records NUMBER(5) := 0;

	l_prog_label        VARCHAR2(100);
	l_label             VARCHAR2(100);
	l_debug_str         VARCHAR2(2000);
	l_enable_log        VARCHAR2(1);
	l_request_id        NUMBER;
        l_app               VARCHAR2(50);
        l_message_name      VARCHAR2(30);
	l_grp_id            igs_pe_priv_level.data_group_id%TYPE;
	l_lvl               igs_pe_priv_level.lvl%TYPE;

	--Pick up the records for processing from the privacy details interface table.
	CURSOR privacy_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE)
	IS
	SELECT ai.*, i.person_id
        FROM   igs_pe_privacy_int ai,
	       igs_ad_interface_all i
        WHERE  ai.interface_id     = i.interface_id AND
               ai.status           = '2' AND
               i.interface_run_id  = cp_interface_run_id AND
	       ai.interface_run_id = cp_interface_run_id;

       --Cursor to check whether the record in interface table already exists in OSS table
       CURSOR chk_dup_privacy_cur(cp_person_id   igs_pe_priv_level.person_id%TYPE,
                                  cp_data_group  igs_pe_priv_level.data_group%TYPE,
                                  cp_start_dt    igs_pe_priv_level.start_date%TYPE)
       IS
       SELECT p.rowid, p.*
       FROM   igs_pe_priv_level p
       WHERE  p.person_id                  = cp_person_id AND
              p.data_group = cp_data_group AND
              p.start_date = cp_start_dt;

	privacy_cur_rec            privacy_cur%ROWTYPE;
	chk_dup_privacy_cur_rec    chk_dup_privacy_cur%ROWTYPE;

	-- Local procedure crt_pe_priv_dtls for inserting new records in the OSS table.
  	PROCEDURE crt_pe_priv_dtls(p_priv_rec 	IN 	privacy_cur%ROWTYPE,
	                           p_grp_id     IN      igs_pe_priv_level.data_group_id%TYPE)
	/*
	||  Created By : nsidana
	||  Created On : 9/7/2004
	||  Purpose : Local procedure to create a new privacy record.
	||  Known limitations, enhancements or remarks :
	||  Change History :
	||  Who             When            What
	||  (reverse chronological order - newest change first)
	|| nsidana          9/7/2004         Created
	*/
	AS
		l_rowid                    VARCHAR2(25);
		l_privacy_level_id         igs_pe_priv_level.privacy_level_id%TYPE;
		l_error_code 	           igs_pe_privacy_int.error_code%TYPE;
		l_org_id                   NUMBER(15);

	BEGIN
	        SAVEPOINT before_insert;
		-- Call log header
 		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

			IF (l_request_id IS NULL) THEN
			    l_request_id := fnd_global.conc_request_id;
			END IF;

			l_label := 'igs.plsql.igs_ad_imp_025.prc_priv_dtls.begin_crt_pe_priv_dtls';
			l_debug_str :=  'igs_ad_imp_025.prc_priv_dtls.crt_pe_priv_dtls';

			fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
		END IF;

		igs_pe_priv_level_pkg.insert_row(
  						 x_rowid               => l_rowid,
					         x_privacy_level_id    => l_privacy_level_id,
					         x_person_id           => p_priv_rec.person_id,
					         x_data_group          => p_priv_rec.data_group,
					         x_data_group_id       => p_grp_id,
					         x_lvl                 => null,
					         x_action              => p_priv_rec.action_code,
					         x_whom                => p_priv_rec.to_whom_code,
					         x_ref_notes_id        => null,
					         x_start_date          => p_priv_rec.start_date,
					         x_end_date            => p_priv_rec.end_date,
 					         x_mode                => 'R'
					        );
                 -- Update interface table for successful insertion.
		l_error_code := NULL;
 		UPDATE igs_pe_privacy_int
                SET    status     = '1',
                       error_code = l_error_code
                WHERE  interface_privacy_id = p_priv_rec.interface_privacy_id;
 	EXCEPTION
	WHEN OTHERS THEN
    	        ROLLBACK TO before_insert;
 		-- Catch the exceptions from TBH if any.
		FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

		IF (l_message_name = 'IGS_PE_FROM_DT_GRT_TO_DATE')
		THEN
		  l_error_code := 'E406';
		ELSIF (l_message_name = 'IGS_FI_ST_NOT_LT_CURRDT')
		THEN
		  l_error_code := 'E352';
		ELSIF (l_message_name = 'IGS_PE_PRIV_DT_OVERLAP')
		THEN
		  l_error_code := 'E228';
		ELSE
		  l_error_code := 'E322';	 -- Person privacy details record insertion failed.
		END IF;
 		UPDATE igs_pe_privacy_int
		SET    status     = '3',
		       error_code = l_error_code
		WHERE  interface_privacy_id = p_priv_rec.interface_privacy_id;

		-- Call Log detail
	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_025.crt_pe_priv_dtls.exception';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',p_priv_rec.interface_privacy_id);
		 fnd_message.set_token('ERROR_CD',l_error_code);

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str,NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	       END IF;

	       IF l_enable_log = 'Y' THEN
		 igs_ad_imp_001.logerrormessage(p_priv_rec.interface_privacy_id,l_error_code);
	       END IF;

	END crt_pe_priv_dtls;  -- End of local procedure to create privacy record.

        -- Local procedure to update a record in the OSS table.
	PROCEDURE upd_pe_priv_dtls(p_oss_rec IN chk_dup_privacy_cur%ROWTYPE,
				   p_int_rec IN privacy_cur%ROWTYPE)
	/*
	||  Created By : nsidana
	||  Created On : 9/7/2004
	||  Purpose : Local procedure to update an existing privacy record.
	||  Known limitations, enhancements or remarks :
	||  Change History :
	||  Who             When            What
	||  (reverse chronological order - newest change first)
	|| nsidana          9/7/2004         Created
	*/
	AS

	BEGIN
  	  SAVEPOINT before_update;

 	  igs_pe_priv_level_pkg.update_row (x_rowid		=> p_oss_rec.rowid,
					  x_privacy_level_id    => p_oss_rec.privacy_level_id,
					  x_person_id		=> p_oss_rec.person_id,
					  x_data_group		=> p_oss_rec.data_group,
					  x_data_group_id	=> p_oss_rec.data_group_id,
					  x_lvl			=> p_oss_rec.lvl,
					  x_action		=> p_int_rec.action_code,
					  x_whom		=> p_int_rec.to_whom_code,
					  x_ref_notes_id	=> p_oss_rec.ref_notes_id,
					  x_start_date		=> p_oss_rec.start_date,
					  x_end_date            => NVL(p_int_rec.end_date,p_oss_rec.end_date),
					  x_mode                => 'R'
					  );
 	  l_error_code := NULL;
 	  l_status := '1';
	  UPDATE igs_pe_privacy_int
	  SET 	 status = l_status,
		 error_code = l_error_code,
		 match_ind = '18'             -- '18' Match occured and used import values
	  WHERE  interface_privacy_id = p_int_rec.interface_privacy_id;
 	EXCEPTION
	WHEN OTHERS THEN
	  ROLLBACK TO before_update;

 	  -- Catch the exceptions from TBH if any.
	  FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

	  IF (l_message_name = 'IGS_PE_FROM_DT_GRT_TO_DATE')
	  THEN
	    l_error_code := 'E406';
	  ELSIF (l_message_name = 'IGS_FI_ST_NOT_LT_CURRDT')
	  THEN
	    l_error_code := 'E352';
	  ELSIF (l_message_name = 'IGS_PE_PRIV_DT_OVERLAP')
	  THEN
	    l_error_code := 'E228';
	  ELSE
	    l_error_code := 'E014';
	  END IF;
 	  UPDATE igs_pe_privacy_int
	  SET status     = '3',
	      error_code = l_error_code
	  WHERE interface_id = p_int_rec.interface_privacy_id;
 	  -- Call Log detail

	  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	    IF (l_request_id IS NULL) THEN
	      l_request_id := fnd_global.conc_request_id;
	    END IF;

	    l_label := 'igs.plsql.igs_ad_imp_025.prc_priv_dtls.exception1';

	    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	    fnd_message.set_token('INTERFACE_ID',p_int_rec.interface_privacy_id);
	    fnd_message.set_token('ERROR_CD',l_error_code);

	    l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

	    fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	  END IF;

	  IF l_enable_log = 'Y' THEN
	    igs_ad_imp_001.logerrormessage(p_int_rec.interface_privacy_id,l_error_code);
	  END IF;
	END upd_pe_priv_dtls;

	-- Local function to validate the record in the interfce table.
	FUNCTION validate_record(p_priv_rec IN  privacy_cur%ROWTYPE,
	                         p_mode     IN  VARCHAR2,
	                         p_group_id OUT NOCOPY igs_pe_priv_level.data_group_id%TYPE)
	RETURN BOOLEAN
	/*
	||  Created By : nsidana
	||  Created On : 9/7/2004
	||  Purpose : Local function to validate the privacy record.
	||  Known limitations, enhancements or remarks :
	||  Change History :
	||  Who             When            What
	||  (reverse chronological order - newest change first)
	|| nsidana          9/7/2004         Created
	*/
	IS
		CURSOR chk_data_group_for_ins(cp_data_group igs_pe_priv_level.data_group%TYPE)
		IS
		SELECT lvl, data_group_id
		FROM   igs_pe_data_groups
		WHERE  data_group =  cp_data_group AND
   		       closed_ind = 'N';

		CURSOR chk_data_group_for_upd(cp_data_group igs_pe_priv_level.data_group%TYPE)
		IS
		SELECT lvl, data_group_id
		FROM   igs_pe_data_groups
		WHERE  data_group = cp_data_group;

		CURSOR chk_to_whom_code(cp_person_id privacy_cur_rec.person_id%TYPE,cp_to_whom_code privacy_cur_rec.to_whom_code%TYPE)
		IS
         	SELECT 1
		FROM FND_LOOKUP_VALUES L,
		HZ_RELATIONSHIPS R
		WHERE L.LOOKUP_CODE = R.RELATIONSHIP_CODE AND
		L.LOOKUP_TYPE = 'PARTY_RELATIONS_TYPE' AND
		L.LANGUAGE = USERENV('LANG') AND
		L.VIEW_APPLICATION_ID = 222 AND
		L.SECURITY_GROUP_ID = 0 AND
		R.STATUS ='A' AND
		R.RELATIONSHIP_CODE = cp_to_whom_code AND
		R.SUBJECT_ID = cp_person_id;

   	        l_error_code	 igs_pe_privacy_int.error_code%TYPE;
		l_rec VARCHAR2(1);
		l_exists NUMBER;
		chk_data_group_for_ins_rec chk_data_group_for_ins%ROWTYPE;
		chk_data_group_for_upd_rec chk_data_group_for_upd%ROWTYPE;

	BEGIN

	--1.) Check a valid data group. Consider closed ones as invalid for Insert mode and valid for update mode.
 		IF ( p_mode = 'I') THEN

		   OPEN chk_data_group_for_ins(p_priv_rec.data_group);
		   FETCH chk_data_group_for_ins INTO chk_data_group_for_ins_rec;

		   IF (chk_data_group_for_ins%NOTFOUND) THEN
 		      l_error_code := 'E351'; -- not a valid data group code.
		      CLOSE chk_data_group_for_ins;
		      RAISE NO_DATA_FOUND;
		   ELSE
		     p_group_id := chk_data_group_for_ins_rec.data_group_id;
		   END IF;
		   CLOSE chk_data_group_for_ins;

		ELSIF (p_mode = 'U' ) THEN
 		   OPEN chk_data_group_for_upd(p_priv_rec.data_group);
		   FETCH chk_data_group_for_upd INTO chk_data_group_for_upd_rec;

		   IF (chk_data_group_for_upd%NOTFOUND) THEN
 		      l_error_code := 'E351'; -- not a valid data group code.
		      CLOSE chk_data_group_for_upd;
		      RAISE NO_DATA_FOUND;
		   END IF;
		   CLOSE chk_data_group_for_upd;

		END IF;

        --2.) Check the action code be a valid lookup code.
 	   IF (NOT igs_pe_pers_imp_001.validate_lookup_type_code('PERSON_PRIVACY_ACTION',p_priv_rec.action_code,8405)) THEN
 	      l_error_code := 'E353';  -- not a valid ACTION_CODE
	      RAISE NO_DATA_FOUND;
	   END IF;

       --3.) Validate TO_WHOM_CODE column in the interface table. Call igs_pe_pers_imp_001.validate_lookup_type_code. If not validated, check in HZ_RELATIONSHIPS.

       IF (NOT igs_pe_pers_imp_001.validate_lookup_type_code('PERSON_PRIVACY_RELEASE',p_priv_rec.to_whom_code,8405))
       THEN
         l_exists := null;
         OPEN chk_to_whom_code(p_priv_rec.person_id,p_priv_rec.to_whom_code);
         FETCH chk_to_whom_code INTO l_exists;
         CLOSE chk_to_whom_code;
         IF (l_exists IS NULL)
         THEN
	   l_error_code := 'E354'; -- not a valid TO_WHOM relation.
	   RAISE NO_DATA_FOUND;
         END IF;
       END IF;

	--4.) Need to handle the following in the EXCPETION section of insert_row and update_row. These will be caught in the exception secion of the insert_row and update_row calls.
	--E406 : IGS_PE_FROM_DT_GRT_TO_DATE :Start date not greater than end date.
	--E352 : IGS_FI_ST_NOT_LT_CURRDT : Start date not less than current date.
        --E228 : IGS_PE_PRIV_DT_OVERLAP : Overlap validation.
 	RETURN TRUE;

	EXCEPTION
	WHEN OTHERS THEN
 		UPDATE igs_pe_privacy_int
		SET    status     = '3',
		       error_code = l_error_code
		WHERE  interface_privacy_id = p_priv_rec.interface_privacy_id;

		-- Call Log detail

	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_025.prc_priv_dtls.exception_validate_record';
		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',p_priv_rec.interface_privacy_id);
		 fnd_message.set_token('ERROR_CD',l_error_code);
		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;
		 fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));

	       END IF;

	       IF l_enable_log = 'Y' THEN
		  igs_ad_imp_001.logerrormessage(p_priv_rec.interface_privacy_id,l_error_code);
	       END IF;
 	       RETURN FALSE;

	END validate_record; -- End of local function.

BEGIN -- Main procedure for importing privacy details.

	  l_default_date := IGS_GE_DATE.IGSDATE('4712/12/31');
          l_prog_label := 'igs.plsql.igs_ad_imp_025.prc_priv_dtls';
          l_label      := 'igs.plsql.igs_ad_imp_025.prc_priv_dtls.';
          l_enable_log := igs_ad_imp_001.g_enable_log;
          l_interface_run_id:=igs_ad_imp_001.g_interface_run_id; -- fetching the interface run ID from the AD imp process.

          l_rule :=  igs_ad_imp_001.find_source_cat_rule(p_source_type_id=>P_SOURCE_TYPE_ID,p_category=>'PRIVACY_DETAILS');

          -- 1. If the rule is E or I, and the match ind column is not null, update all the records to status 3 as they are invalids.

	  IF ((l_rule='E') OR (l_rule='I')) THEN
	      UPDATE igs_pe_privacy_int phi
	      SET status     = '3',
		  error_code = 'E695'
	      WHERE phi.status           = '2' AND
		    phi.interface_run_id = l_interface_run_id AND
		    phi.match_ind        IS NOT NULL;
	  END IF;

	     -- 2 . If rule is E and the match ind is null, we update the interface table for all duplicate records with status 1 and match ind 19.

	  IF (l_rule = 'E') THEN
		  UPDATE igs_pe_privacy_int phi
		  SET    status    = '1',
			 match_ind = '19'
		  WHERE  phi.status           = '2' AND
			 phi.interface_run_id = l_interface_run_id AND
			 EXISTS
			 (SELECT 1
			  FROM igs_pe_priv_level pi, igs_ad_interface_all ai
			  WHERE phi.interface_id = ai.interface_id AND
				ai.interface_run_id = l_interface_run_id AND
				ai.person_id = pi.person_id AND
				pi.data_group = UPPER(phi.data_group) AND
				TRUNC(phi.start_date) = pi.start_date);
	  END IF;

	       -- 3. If rule is R and the record status is 18,19,22,23 these records have been processed, but didn't get updated. Update them to 1

	       IF (l_rule='R') THEN
		    UPDATE igs_pe_privacy_int phi
		    SET status = '1'
		    WHERE phi.status           = '2' AND
			 phi.interface_run_id = l_interface_run_id AND
			 phi.match_ind        IN ('18','19','22','23');
	       END IF;

	       -- 4. If rule is R and the match ind is not null and is neither 21 nor 25, update it to errored record.

	       IF (l_rule = 'R') THEN
		    UPDATE igs_pe_privacy_int phi
		    SET status = '3', error_code = 'E695'
		    WHERE  phi.status = '2' AND
			   phi.interface_run_id = l_interface_run_id AND
			   (phi.match_ind IS NOT NULL AND phi.match_ind NOT IN ('21','25'));
	       END IF;

	       -- 5. If rule = 'R' and there is no discprepency in duplicate records, update them to status 1 and match ind 23.

	       IF (l_rule ='R') THEN
		   UPDATE igs_pe_privacy_int phi
		   SET status     = '1', match_ind  = '23'
		   WHERE  phi.status            = '2' AND
			  phi.interface_run_id  = l_interface_run_id AND
			  phi.match_ind         IS NULL AND
			  EXISTS
			  (SELECT 1
			   FROM   igs_pe_priv_level pi, igs_ad_interface_all ai
			   WHERE  phi.interface_id = ai.interface_id AND
				  ai.interface_run_id = l_interface_run_id AND
				  pi.person_id        = ai.person_id AND
				  pi.data_group       = UPPER(phi.data_group) AND
				  pi.action           = UPPER(phi.action_code) AND
				  pi.whom             = UPPER(phi.to_whom_code) AND
				  pi.start_date       = TRUNC(phi.start_date) AND
				  NVL(TRUNC(pi.end_date), l_default_date) = NVL(TRUNC(phi.end_date),l_default_date)
			   ) ;
	       END IF;

	       -- 6. If rule is R and there are still some records, they are the ones for which there is some discrepency existing. Update them to status 3
	       -- and value from the OSS table.

	       IF (l_rule ='R') THEN
 		   UPDATE igs_pe_privacy_int phi
		   SET status                  = 3,
		       match_ind               = 20,
		       dup_privacy_level_id    = (SELECT pi.privacy_level_id
						  FROM igs_pe_priv_level pi, igs_ad_interface_all ai
						  WHERE ai.interface_id = phi.interface_id AND
							ai.interface_run_id = l_interface_run_id AND
							ai.person_id        = pi.person_id AND
							UPPER(phi.data_group) = pi.data_group AND
							TRUNC(phi.start_date) = pi.start_date)
		   WHERE  phi.status='2' AND
			  phi.interface_run_id = l_interface_run_id AND
			  phi.match_ind IS NULL AND
			  EXISTS
			  (SELECT 1
			   FROM igs_pe_priv_level pi, igs_ad_interface_all ai
			   WHERE ai.interface_run_id = l_interface_run_id AND
				ai.interface_id = phi.interface_id AND
				ai.person_id = pi.person_id AND
				UPPER(phi.data_group) = pi.data_group AND
				TRUNC(phi.start_date) = pi.start_date
			  );
 	       END IF;

       -- process the remanining records.
      FOR privacy_cur_rec IN privacy_cur(l_interface_run_id)
      LOOP
          privacy_cur_rec.start_date := TRUNC(privacy_cur_rec.start_date);
    	  privacy_cur_rec.end_date :=   TRUNC(privacy_cur_rec.end_date);
          privacy_cur_rec.data_group := UPPER(privacy_cur_rec.data_group);
          privacy_cur_rec.action_code := UPPER(privacy_cur_rec.action_code);
          privacy_cur_rec.to_whom_code := UPPER(privacy_cur_rec.to_whom_code);

          l_processed_records := l_processed_records + 1;

	  chk_dup_privacy_cur_rec.privacy_level_id := NULL;

	  OPEN  chk_dup_privacy_cur(privacy_cur_rec.person_id,privacy_cur_rec.data_group,privacy_cur_rec.start_date);
	  FETCH chk_dup_privacy_cur INTO chk_dup_privacy_cur_rec;
	  CLOSE chk_dup_privacy_cur;

	  IF (chk_dup_privacy_cur_rec.privacy_level_id IS NOT NULL) -- Matching record exists.
	  THEN
    	    IF  ((l_rule = 'I') OR ((l_rule = 'R') AND (privacy_cur_rec.match_ind = '21')))
	    THEN
 	      IF validate_record(privacy_cur_rec,'U',l_grp_id) THEN
                 upd_pe_priv_dtls(p_oss_rec => chk_dup_privacy_cur_rec,p_int_rec => privacy_cur_rec);
	      END IF; -- end for validate for update
	    END IF;

	  ELSE -- matching record does not exists.

	    -- validate and insert new.
	    IF validate_record(privacy_cur_rec,'I',l_grp_id) THEN
 	      crt_pe_priv_dtls(p_priv_rec => privacy_cur_rec, p_grp_id => l_grp_id);
	    END IF;

	  END IF; -- for duplicate record check.

	  IF l_processed_records = 100 THEN
	     COMMIT;
	     l_processed_records := 0;
	  END IF;
      END LOOP;
END prc_priv_dtls;

END igs_ad_imp_025;

/
