--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_PRBLTY_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_PRBLTY_VAL_PKG" AS
/* $Header: IGSADB0B.pls 120.1 2006/01/16 20:23:44 rghosh noship $ */

          --Function to check for the duplicate record based on person_id, calculation_date and probability_type_code_id
          FUNCTION  duplicate_exist(p_person_id           igs_ad_recrt_pi_int.person_id%TYPE,
                                    p_calculation_date    igs_ad_recrt_pi_int.calculation_date%TYPE,
                                    p_prblty_type_code_id igs_ad_recrt_pi_int.prblty_type_code_id%TYPE)
          RETURN  VARCHAR2  IS
          /*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 03-AUG-2001
	  ||  Purpose : This function checks for the presence of duplicate records
	  ||            And accordingly returns 'Y' or 'N'
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	  */

          --Cursor to check for duplicate record
          CURSOR duplicate_check_cur  IS
          SELECT  'X'
          FROM   igs_ad_recruit_pi_v
          WHERE  person_id                = p_person_id  AND
                 TRUNC(calculation_date)  = TRUNC(p_calculation_date)  AND
                 probability_type_code_id = p_prblty_type_code_id;

          l_duplicate_exists  VARCHAR2(1);

          BEGIN
                 --If no duplicate record exists for that combination RETURN 'N',
                 --else return 'Y'
                 OPEN   duplicate_check_cur;
                 FETCH duplicate_check_cur  INTO  l_duplicate_exists;
                 IF duplicate_check_cur%NOTFOUND  THEN
                       CLOSE   duplicate_check_cur;
                       RETURN 'N';
                 END IF;
                 CLOSE  duplicate_check_cur;

                 RETURN  'Y';

            EXCEPTION
                 WHEN  OTHERS  THEN
                      IF duplicate_check_cur%ISOPEN  THEN
                              CLOSE  duplicate_check_cur;
                      END IF;
                      --return 'N' if any exception occurs to validate the whole record
                      RETURN 'N';

          END  duplicate_exist;

          --Procedure to validate the record
          --And assign corresponding 'error_code'  values to the OUT NOCOPY parameter

          PROCEDURE  val_prblty_value(prblty_val_rec  igs_ad_recrt_pi_int%ROWTYPE,
                                      p_error_code IN OUT NOCOPY igs_ad_recrt_pi_int.error_code%TYPE)
          IS
	           /*
		  ||  Created By : Prabhat.Patel@Oracle.com
		  ||  Created On : 03-AUG-2001
		  ||  Purpose : This is a privete procedure, which contains the validation for the
		  ||            Values in different fields in the Interface table
		  ||  Known limitations, enhancements or remarks :
		  ||  Change History :
		  ||  Who             When            What
		  ||  (reverse chronological order - newest change first)
         	  */
          	CURSOR  prblty_type_val_check_cur  IS
          	SELECT  'X'
          	FROM    igs_ad_code_classes  iacc
          	WHERE   iacc.code_id = prblty_val_rec.prblty_type_code_id  AND
                        iacc.class = 'PROB_TYPE';

          	CURSOR  prblty_source_val_check_cur  IS
          	SELECT  'X'
          	FROM    igs_ad_code_classes  iacc
          	WHERE   iacc.code_id = prblty_val_rec.prblty_source_code_id  AND
             	        iacc.class = 'PROB_SOURCE';

             	l_validity_check    VARCHAR2(1);
             	l_err_code          igs_ad_recrt_pi_int.error_code%TYPE;

          BEGIN

                --Validate each field. If validation fails RAISE NO_DATA_FOUND  exception and
                --And assign corresponding 'error_code'  values to the OUT NOCOPY parameter
                OPEN  prblty_type_val_check_cur;
                FETCH prblty_type_val_check_cur  INTO l_validity_check;
                     IF prblty_type_val_check_cur%NOTFOUND  THEN
                            l_err_code := 'E001';     -- 'E001' Validation failed for Probability Type Code Id
                            CLOSE  prblty_type_val_check_cur;
                            RAISE  NO_DATA_FOUND;
                     END IF;

                CLOSE prblty_type_val_check_cur;

                IF   prblty_val_rec.prblty_source_code_id IS NOT NULL THEN
                  OPEN  prblty_source_val_check_cur;
                  FETCH prblty_source_val_check_cur  INTO l_validity_check;
                       IF prblty_source_val_check_cur%NOTFOUND  THEN
                              l_err_code := 'E002';    -- 'E002' Validation failed for Probability Source Code Id
                              CLOSE  prblty_source_val_check_cur;
                              RAISE  NO_DATA_FOUND;
                       END IF;
                  CLOSE prblty_source_val_check_cur;
                END IF;

             EXCEPTION
                WHEN NO_DATA_FOUND  THEN
                    p_error_code := l_err_code;
          END  val_prblty_value;

          --The main procedure for processing
          PROCEDURE prc_prblty_value(
                             errbuf			OUT NOCOPY		VARCHAR2,
                             retcode			OUT NOCOPY		NUMBER,
                             p_prblty_val_batch_id      IN              igs_ad_recrt_pi_int.prblty_val_batch_id%TYPE
                             )
          IS
		          /*
			  ||  Created By : Prabhat.Patel@Oracle.com
			  ||  Created On : 03-AUG-2001
			  ||  Purpose : This is the driving procedure for the concurrent job
			  ||            'Import Probability Values'
			  ||  Known limitations, enhancements or remarks :
			  ||  Change History :
			  ||  Who             When            What
			  ||  (reverse chronological order - newest change first)
			  */

                        --User defined exception to skip the record for further processing whenever any error occurs
          		skip_this_record          EXCEPTION;
          		l_person_id               igs_ad_recrt_pi_int.person_id%TYPE;
          		l_error_code              igs_ad_recrt_pi_int.error_code%TYPE;
          		l_rowid                   ROWID;
          		l_probability_index_id    igs_ad_recruit_pi.probability_index_id%TYPE;
          		l_records_processed       NUMBER := 0;
          		l_exists                  VARCHAR2(1);

          		--Cursor to select all the records in pending status in the batch_id as given by the user
          		CURSOR  prblty_val_cur(c_prblty_val_batch_id igs_ad_recrt_pi_int.prblty_val_batch_id%TYPE) IS
          		SELECT   arpi.*
          		FROM     igs_ad_recrt_pi_int arpi
          		WHERE    arpi.prblty_val_batch_id = c_prblty_val_batch_id  AND
                   		 arpi.status = '2' ;  -- '2' pending

                   	--Cursor to find out NOCOPY the person ID based upon Alternate person ID and Person ID type
                   	--while the person ID IS NULL
                        CURSOR   alternate_person_id_cur(c_api_person_id  igs_ad_recrt_pi_int.api_person_id%TYPE,
                                               c_person_id_type igs_ad_recrt_pi_int.person_id_type%TYPE) IS
                        SELECT   pe_person_id
                        FROM     igs_pe_person_id_type_v
                        WHERE    api_person_id  = c_api_person_id   AND
                                 person_id_type = c_person_id_type ;

                        --Cursor to check whether the person is valid
                        CURSOR   person_id_cur(c_person_id igs_ad_recrt_pi_int.person_id%TYPE) IS
                        SELECT   'X'
                        FROM     HZ_PARTIES
                        WHERE    party_id = c_person_id;

                        prblty_val_rec  prblty_val_cur%ROWTYPE;

			l_gather_status       VARCHAR2(5);
			l_industry     VARCHAR2(5);
			l_schema       VARCHAR2(30);
			l_gather_return       BOOLEAN;
			l_owner        VARCHAR2(30);
           BEGIN
                        -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
                        igs_ge_gen_003.set_org_id(null);

			retcode := 0;

			-- Gather statistics for interface table
			-- by rrengara on 20-jan-2003 bug 2711176

			BEGIN
			  l_gather_return := fnd_installation.get_app_info('IGS', l_gather_status, l_industry, l_schema);
			  FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_RECRT_PI_INT_ALL', cascade => TRUE);
			EXCEPTION WHEN OTHERS THEN
				NULL;
			END;


                        --Open the cursor fetching all the records for processing
                        --Process the records one by one
                        OPEN     prblty_val_cur(p_prblty_val_batch_id);
                        LOOP

                        BEGIN

                        FETCH    prblty_val_cur  INTO  prblty_val_rec;
                        EXIT WHEN prblty_val_cur%NOTFOUND;

                                 l_records_processed := l_records_processed + 1;
                                 l_person_id := prblty_val_rec.person_id;

                                -- if person ID in the interface table is null then
                                -- find out NOCOPY the person ID based upon alternate person ID and person ID type
                                -- if it is not null find out NOCOPY whether its a valid person
                                IF l_person_id IS NULL THEN
                                      OPEN  alternate_person_id_cur(prblty_val_rec.api_person_id, prblty_val_rec.person_id_type);
                                      FETCH alternate_person_id_cur  INTO l_person_id;
                                      CLOSE alternate_person_id_cur;
                                ELSE
                                      OPEN   person_id_cur(prblty_val_rec.person_id) ;
                                      FETCH  person_id_cur  INTO  l_exists;
                                           IF person_id_cur%NOTFOUND  THEN
                                              CLOSE person_id_cur;
                                              UPDATE  igs_ad_recrt_pi_int
                                              SET     error_code = 'E007', -- 'E007' Invalid person
                                              status     = '3' ,           -- '3' Error
                                              match_ind  = NULL
                                              WHERE prblty_val_int_id = prblty_val_rec.prblty_val_int_id;

                                              l_error_code := 'E007';

                                              FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRBLTY_VALUE_ERROR');
                                              FND_MESSAGE.SET_TOKEN('PRBLTY_VAL_INT_ID',prblty_val_rec.prblty_val_int_id);
                                              FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_error_code);
                                              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                                              RAISE  skip_this_record;
                                           END IF;
                                      CLOSE  person_id_cur;
                                END IF;

                                --if the person_id could not be found then stop further processing of the record
                                --update the error_code and status accordingly
                                IF l_person_id IS NULL THEN
                                      UPDATE  igs_ad_recrt_pi_int
                                      SET     error_code = 'E006', -- 'E006' Insufficient Information of a person
                                      status     = '3' ,           -- '3' Error
                                      match_ind  = NULL
                                      WHERE prblty_val_int_id = prblty_val_rec.prblty_val_int_id;
                                      l_error_code := 'E006';

                                      FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRBLTY_VALUE_ERROR');
                                      FND_MESSAGE.SET_TOKEN('PRBLTY_VAL_INT_ID',prblty_val_rec.prblty_val_int_id);
                                      FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_error_code);
                                      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                                      RAISE  skip_this_record;
                                END IF;

                                --Check whether its a duplicate record
                                --If it is a duplicate record check the value in match_ind
                                --If match_ind = '21' then validate the record and import the values if validation is successful
                                --If match_ind <> '21' then update the record for the status = '3', error_code = 'E003' and match_ind = '23'
                                --If its not a duplicate record validate the record. If validation successful then import the record.
                                IF  duplicate_exist(l_person_id,prblty_val_rec.calculation_date,prblty_val_rec.prblty_type_code_id) = 'Y' THEN

                                      IF prblty_val_rec.match_ind = '21' THEN    -- '21' Match reviewed and to be imported

                                             --Call the private procedure for validation
                                             val_prblty_value(prblty_val_rec,l_error_code);

                                                        --If error_code is null, validation is successful
                                                        --Import the record by updating the OSS table with values from interface table
                                                        IF l_error_code  IS NULL  THEN
                                                           DECLARE
                                                                  CURSOR  null_hdlg_adm_recrt_pi_cur(c_person_id igs_ad_recrt_pi_int.person_id%TYPE,
                                                                                                     c_calculation_date igs_ad_recrt_pi_int.calculation_date%TYPE,
                                                                                                     c_prblty_type_code_id igs_ad_recrt_pi_int.prblty_type_code_id%TYPE)  IS
                                                                  SELECT   *
                                                                  FROM     igs_ad_recruit_pi_v
                                                                  WHERE    person_id = c_person_id  AND
                                                                           calculation_date  = c_calculation_date AND
                                                                           probability_type_code_id = c_prblty_type_code_id;

                                                                  null_hdlg_adm_recrt_pi_rec null_hdlg_adm_recrt_pi_cur%ROWTYPE;
                                                           BEGIN
                                                               OPEN null_hdlg_adm_recrt_pi_cur(l_person_id,prblty_val_rec.calculation_date,prblty_val_rec.prblty_type_code_id);
                                                               FETCH  null_hdlg_adm_recrt_pi_cur  INTO null_hdlg_adm_recrt_pi_rec;
                                                               CLOSE  null_hdlg_adm_recrt_pi_cur;

                                                              --Call the lock row of the OSS table TBH to check whether that particular record is locked
                                                              --If locked then it will throw an exception for nowait condition and the updation will be skipped.
                                                              igs_ad_recruit_pi_pkg.lock_row (
                                                                                              x_rowid                             => null_hdlg_adm_recrt_pi_rec.row_id,
                                                                                              x_probability_index_id              => null_hdlg_adm_recrt_pi_rec.probability_index_id,
                                                                                              x_person_id                         => null_hdlg_adm_recrt_pi_rec.person_id,
                                                                                              x_probability_type_code_id          => null_hdlg_adm_recrt_pi_rec.probability_type_code_id,
                                                                                              x_calculation_date                  => null_hdlg_adm_recrt_pi_rec.calculation_date,
                                                                                              x_probability_value                 => null_hdlg_adm_recrt_pi_rec.probability_value,
                                                                                              x_probability_source_code_id        => null_hdlg_adm_recrt_pi_rec.probability_source_code_id
                                                                                                );

                                                               igs_ad_recruit_pi_pkg.update_row (
											      x_mode                              => 'R',
											      x_rowid                             => null_hdlg_adm_recrt_pi_rec.row_id,
											      x_probability_index_id              => null_hdlg_adm_recrt_pi_rec.probability_index_id,
											      x_person_id                         => null_hdlg_adm_recrt_pi_rec.person_id,
											      x_probability_type_code_id          => null_hdlg_adm_recrt_pi_rec.probability_type_code_id,
											      x_calculation_date                  => null_hdlg_adm_recrt_pi_rec.calculation_date,
											      x_probability_value                 => NVL(prblty_val_rec.probability_value,null_hdlg_adm_recrt_pi_rec.probability_value),
											      x_probability_source_code_id        => NVL(prblty_val_rec.prblty_source_code_id,null_hdlg_adm_recrt_pi_rec.probability_source_code_id)
										       	        );

                                                                --If Updation is successful make the status '1'
                                                                --so that it can be deleted from interface table
                                                                UPDATE  igs_ad_recrt_pi_int
                                                                SET     error_code = NULL,
                                                                        status     = '1' , --'1' Complete
                                                                        match_ind  = NULL
                                                                WHERE prblty_val_int_id = prblty_val_rec.prblty_val_int_id;

                                                              EXCEPTION
                                                                WHEN OTHERS THEN

                                                                   --If Update is unsuccessful then make the status 'Error' with
                                                                   UPDATE  igs_ad_recrt_pi_int
                                                                   SET     error_code = 'E005', -- 'E005' Update failed
                                                                           status     = '3' ,
                                                                           match_ind  = NULL
                                                                   WHERE prblty_val_int_id = prblty_val_rec.prblty_val_int_id;

                                                                   l_error_code := 'E005';

                                                                   FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRBLTY_VALUE_ERROR');
                                                                   FND_MESSAGE.SET_TOKEN('PRBLTY_VAL_INT_ID',prblty_val_rec.prblty_val_int_id);
                                                                   FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_error_code);
                                                                   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                                                                   RAISE  skip_this_record;
                                                              END;

                                                        ELSE  -- Error_code is not NULL after validation.
                                                              -- Make the status 'Error' and error_code as obtained after validation
                                                                   UPDATE  igs_ad_recrt_pi_int
                                                                   SET     error_code = l_error_code,
                                                                           status     = '3' ,
                                                                           match_ind  = NULL
                                                                   WHERE prblty_val_int_id = prblty_val_rec.prblty_val_int_id;

                                                                   FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRBLTY_VALUE_ERROR');
                                                                   FND_MESSAGE.SET_TOKEN('PRBLTY_VAL_INT_ID',prblty_val_rec.prblty_val_int_id);
                                                                   FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_error_code);
                                                                   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                                                                   RAISE  skip_this_record;
                                                        END IF; --error_code comparision

                                                  ELSE  -- If match_ind <> '21' then make the status 'Error'
                                                        UPDATE  igs_ad_recrt_pi_int
                                                                   SET     error_code = 'E003', -- 'E003' Duplicate record found
                                                                           status     = '3' ,
                                                                           match_ind  = '23'  -- '23' Match to be reviewed, but there was no discrepancy and so retaining the existing
                                                                   WHERE prblty_val_int_id = prblty_val_rec.prblty_val_int_id;

                                                                   l_error_code := 'E003';

                                                                   FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRBLTY_VALUE_ERROR');
                                                                   FND_MESSAGE.SET_TOKEN('PRBLTY_VAL_INT_ID',prblty_val_rec.prblty_val_int_id);
                                                                   FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_error_code);
                                                                   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                                                                   RAISE  skip_this_record;


                                                 END IF; --match_ind comparision

                                    ELSE  --If its not a duplicate record
                                          -- do validation for the values in the record
                                             val_prblty_value(prblty_val_rec,l_error_code);

                                                        --if error_code is NULL, validation is successful
                                                        --import the record by creating a new record in OSS table taking values from Interface table
                                                        IF l_error_code  IS NULL  THEN
                                                           BEGIN

                                                               igs_ad_recruit_pi_pkg.insert_row (
											      x_mode                              => 'R',
											      x_rowid                             => l_rowid,
											      x_probability_index_id              => l_probability_index_id,
											      x_person_id                         => l_person_id,
											      x_probability_type_code_id          => prblty_val_rec.prblty_type_code_id,
											      x_calculation_date                  => prblty_val_rec.calculation_date,
											      x_probability_value                 => prblty_val_rec.probability_value,
											      x_probability_source_code_id        => prblty_val_rec.prblty_source_code_id
										       	        );

                                                                --If insertion is successful make the status '1'
                                                                --so that it can be deleted from Interface table
                                                                UPDATE  igs_ad_recrt_pi_int
                                                                SET     error_code = NULL,
                                                                        status     = '1' ,
                                                                        match_ind  = NULL
                                                                WHERE   prblty_val_int_id = prblty_val_rec.prblty_val_int_id;

                                                              EXCEPTION
                                                                WHEN OTHERS THEN
                                                                   --If insertion is unsuccessful make the status 'Error'
                                                                   UPDATE  igs_ad_recrt_pi_int
                                                                   SET     error_code = 'E004', -- 'E004' Insert failed
                                                                           status     = '3' ,
                                                                           match_ind  = NULL
                                                                   WHERE prblty_val_int_id = prblty_val_rec.prblty_val_int_id;

                                                                   l_error_code := 'E004';

                                                                   FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRBLTY_VALUE_ERROR');
                                                                   FND_MESSAGE.SET_TOKEN('PRBLTY_VAL_INT_ID',prblty_val_rec.prblty_val_int_id);
                                                                   FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_error_code);
                                                                   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                                                                   RAISE  skip_this_record;
                                                           END;
                                                         ELSE -- Error_code is not NULL after validation.
                                                              -- Make the status 'Error' and error_code as obtained after validation
                                                                   UPDATE  igs_ad_recrt_pi_int
                                                                   SET     error_code = l_error_code,
                                                                           status     = '3' ,
                                                                           match_ind  = NULL
                                                                   WHERE prblty_val_int_id = prblty_val_rec.prblty_val_int_id;

                                                                   FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRBLTY_VALUE_ERROR');
                                                                   FND_MESSAGE.SET_TOKEN('PRBLTY_VAL_INT_ID',prblty_val_rec.prblty_val_int_id);
                                                                   FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_error_code);
                                                                   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                                                                   RAISE  skip_this_record;
                                                         END IF; --error_code comparision

                                    END IF; --duplicate record check condition
                               EXCEPTION
                                     --Whenever any error occurs skip further processing of that record
                                     WHEN  skip_this_record THEN

                                        --refresh the variable after the processing of each record
                                        l_error_code := null;
                                        null;

                               END;--End of processing of one record
                      END LOOP; -- Start processing for the next record

                      --Delete all the records which have a status 'Complete' after the processing
                      DELETE
                      FROM igs_ad_recrt_pi_int
                      WHERE status = '1' AND
                            prblty_val_batch_id = p_prblty_val_batch_id;

                      --Display the no of records processed in the log File
                      FND_MESSAGE.SET_NAME('IGS','IGS_AD_TOT_REC_PRC');
                      FND_MESSAGE.SET_TOKEN('RCOUNT',l_records_processed);
                      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

                      EXCEPTION
                          WHEN  OTHERS   THEN
                          ROLLBACK;
                          RETCODE :=2;
                          errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                          igs_ge_msg_stack.conc_exception_hndl;

           END prc_prblty_value;

END igs_ad_imp_prblty_val_pkg;

/
