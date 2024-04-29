--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_UH_TST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_UH_TST_PKG" AS
/* $Header: IGSADA5B.pls 115.12 2003/11/04 08:43:39 rghosh ship $ */

PROCEDURE imp_convt_tst_scrs(
  errbuf		OUT NOCOPY VARCHAR2,
  retcode		OUT NOCOPY NUMBER,
  p_group_id		IN  NUMBER,
  p_org_id		IN NUMBER
) IS

v_session_id NUMBER;


CURSOR c_person_cur(cp_group_id NUMBER) IS
SELECT pgm.person_id
FROM   igs_pe_prsid_grp_mem pgm
WHERE  pgm.group_id = cp_group_id AND
NVL(TRUNC(pgm.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE) AND
NVL(TRUNC(pgm.end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);

l_gather_status       VARCHAR2(5);
l_industry     VARCHAR2(5);
l_schema       VARCHAR2(30);
l_gather_return       BOOLEAN;
l_owner        VARCHAR2(30);


BEGIN

  -- Gather statistics for interface table
  -- by rrengara on 20-jan-2003 bug 2711176

  BEGIN
    l_gather_return := fnd_installation.get_app_info('IGS', l_gather_status, l_industry, l_schema);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_TSTRST_UH_INT', cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_TSTDTL_UH_INT', cascade => TRUE);
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;

	-- Issue a savepoint for the purpose of rolling back of transaction
	SAVEPOINT impuhtst;

  -- To populate org_id
  igs_ge_gen_003.set_org_id(p_org_id);

  -- Initialize the retcode
  retcode := 0;

  -- Process the person records based on the group id entered in the
  -- parameters

  FOR c_person_rec IN c_person_cur(p_group_id)  LOOP
	-- Call the user hook
	igs_ad_tstuh_call_pkg.call_user_hook
	(
		c_person_rec.person_id,
		v_session_id
	);
	-- Call the procedure transfer into OSS only if above call was successful
	IF v_session_id IS NOT NULL THEN
		transfer_int_oss (
			p_session_id => v_session_id,
			p_person_id => c_person_rec.person_id
				);

	END IF;
  END LOOP;
  FND_FILE.PUT_LINE ( FND_FILE.LOG, FND_MESSAGE.GET_STRING( 'IGS', 'IGS_AD_CONV_TEST_SUCCESS'));
  EXCEPTION

    WHEN OTHERS THEN

      -- Rollback the transaction
      ROLLBACK TO impuhtst;

      retcode := 2;

      -- Handle the standard igs-message stack
      igs_ge_msg_stack.conc_exception_hndl;

END imp_convt_tst_scrs;

PROCEDURE transfer_int_oss
(
	p_person_id	IN NUMBER,
	p_session_id	IN NUMBER
) IS
/*
	This procedure imports the records from the interface tables
		1. IGS_AD_TSTRST_UH_INT ( Test Results Interface table)
		2. IGS_AD_TSTDTL_UH_INT ( Test Results Details Interface table)
	into the corresponding OSS tables viz.,
		1. IGS_AD_TEST_RESULTS ( Test results system table)
		2. IGS_AD_TST_RSLT_DTLS ( Test Results Details system table)
*/
	--
	-- DLD_adsr_Test_Scores
	-- 2.  Create cursor C_TST_CUR for the step 1 . Use the following query
	--
	CURSOR c_tst_cur IS
	SELECT
		*
	FROM
		igs_ad_tstrst_uh_int
	WHERE
		PERSON_ID  = p_person_id AND
		SESSION_ID = p_session_id AND
		STATUS = '2';

	CURSOR c_test_scores IS
        SELECT SUM(B.TEST_SCORE) FROM IGS_AD_TSTRST_UH_INT A,IGS_AD_TSTDTL_UH_INT B
        WHERE A.INTERFACE_TST_ID = B.INTERFACE_TST_ID
        AND A.PERSON_ID = p_person_id
        AND A.SESSION_ID = p_session_id
        AND B.TEST_SEGMENT_ID IN (SELECT TEST_SEGMENT_ID
                           FROM   IGS_AD_TEST_SEGMENTS
			   WHERE  INCLUDE_IN_COMP_SCORE ='Y'
			   AND ADMISSION_TEST_TYPE IN
				( SELECT distinct admission_test_type
                                  FROM IGS_AD_TEST_RESULTS
                                  WHERE person_id = p_person_id));
	--
	-- DLD_adsr_Test_Scores
	-- 6. Get the corresponding SCORE_TYPE for the C_TST_CUR.TEST_TYPE and
	-- store it in L_SCORE_TYPE from the table IGS_AD_TEST_TYPE
	--
	CURSOR c_score_typ_cur (cp_test_type VARCHAR2) IS
	SELECT
		score_type
	FROM
		igs_ad_test_type
	WHERE
		admission_test_type = cp_test_type;

	c_score_typ_rec c_score_typ_cur%ROWTYPE;

	--
	-- DLD_adsr_Test_Scores
	-- IF  X_ACTIVE_IND is Y THEN
	-- Make all other  Test Types which is same as the test type C_TST_CUR.TEST_TYPE to  Active N
	-- in the table IGS_AD_TEST_RESULTS.
	-- Use the following query
	--
	CURSOR c_other_test_cur ( cp_test_type VARCHAR2, cp_test_results_id NUMBER) IS
	SELECT
		a.rowid, a.*
	FROM
		igs_ad_test_results a
	WHERE
		person_id = p_person_id  AND
		admission_test_type = cp_test_type AND
		active_ind = 'Y' AND
		test_results_id <> cp_test_results_id;

	l_error_code IGS_AD_TSTRST_UH_INT.ERROR_CODE%TYPE;
	l_status IGS_AD_TSTRST_UH_INT.STATUS%TYPE;
	l_tst_rowid VARCHAR2(25);
	l_tstdtl_rowid VARCHAR2(25);
	l_test_results_id NUMBER(15);
	l_tst_rslt_dtls_id NUMBER(15);
	l_test_scores NUMBER(15);

	l_return_status BOOLEAN;


	--
	-- Start of local Procedure imp_chld_test_details
	--
	PROCEDURE imp_chld_test_details
	(
		p_interface_tst_id IN NUMBER,
		p_return_status OUT NOCOPY BOOLEAN
	) IS

		--
		-- DLD_adsr_Test_Scores
		-- 8.  Create  Cursor  C_TSTDTL_CUR with the following SELECT statement in order to import
		-- all the test segments for the imported test type
		--
		CURSOR c_tstdtl_cur ( cp_interface_tst_id NUMBER) IS
		SELECT
			*
		FROM
			igs_ad_tstdtl_uh_int
		WHERE
			interface_tst_id = cp_interface_tst_id;
	BEGIN
		FOR c_tstdtl_rec IN c_tstdtl_cur ( p_interface_tst_id) LOOP
			igs_ad_tst_rslt_dtls_pkg.insert_row
			(
				X_ROWID                        => l_tstdtl_rowid,
				X_TST_RSLT_DTLS_ID             => l_tst_rslt_dtls_id,
				X_TEST_RESULTS_ID              => l_test_results_id,
				X_TEST_SEGMENT_ID              => c_tstdtl_rec.test_segment_id,
				X_TEST_SCORE                   => c_tstdtl_rec.test_score,
				X_PERCENTILE                   => NULL,
				X_NATIONAL_PERCENTILE          => NULL,
				X_STATE_PERCENTILE             => NULL,
				X_PERCENTILE_YEAR_RANK         => NULL,
				X_SCORE_BAND_LOWER             => NULL,
				X_SCORE_BAND_UPPER             => NULL,
				X_IRREGULARITY_CODE_ID         => NULL,
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
				X_MODE                         => 'R'
			);
		END LOOP;
		p_return_status := TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			p_return_status := FALSE;
	END imp_chld_test_details;
	--
	-- End of Local Procedure imp_chld_test_details
	--

--
-- Start of Procedure transfer_int_oss
--
BEGIN
OPEN c_test_scores;
FETCH c_test_scores INTO l_test_scores;
CLOSE c_test_scores;
	--
	-- Loop through the test results interface records
	--
	FOR c_tst_rec IN c_tst_cur LOOP
		l_error_code := NULL;
		--
		-- Setting the savepoint before_tsttype for the transaction to be
		-- rolled out NOCOPY in case of any error occuring while importing the test type
		-- master record or test result detail record.
		--
		SAVEPOINT before_tsttype;
		-- Outer Begin
		BEGIN
			--
			-- Open the score type cursor and get the corresponding score type
			--
			OPEN c_score_typ_cur ( c_tst_rec.test_type);
			FETCH c_score_typ_cur INTO c_score_typ_rec;
			CLOSE c_score_typ_cur;
			IF c_score_typ_rec.score_type IS NOT NULL THEN
				-- Insert master begin
				BEGIN
					--
					-- DLD_adsr_Test_Scores
					-- 7.            Call IGS_AD_TEST_RESULTS.INSERT_ROW(
					--
					igs_ad_test_results_pkg.insert_row
					(
						X_ROWID                        => l_tst_rowid,
						X_TEST_RESULTS_ID              => l_test_results_id,
						X_PERSON_ID                    => c_tst_rec.person_id,
						X_ADMISSION_TEST_TYPE          => c_tst_rec.test_type,
						X_TEST_DATE                    => c_tst_rec.test_date,
						X_SCORE_REPORT_DATE            => NULL,
						X_EDU_LEVEL_ID                 => NULL,
						X_SCORE_TYPE                   => c_score_typ_rec.score_type,
						X_SCORE_SOURCE_ID              => NULL,
						X_NON_STANDARD_ADMIN           => NULL,
						X_COMP_TEST_SCORE              => l_test_scores,
						X_SPECIAL_CODE                 => NULL,
						X_REGISTRATION_NUMBER          => NULL,
						X_GRADE_ID                     => NULL,
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
						X_MODE                         => 'R',
						X_ACTIVE_IND                   => c_tst_rec.active_ind
					);
				EXCEPTION
					WHEN OTHERS THEN
						l_error_code := 'E002';
						FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Insertion of Test Result record failed '
									|| ' Person ID :: ' || IGS_GE_NUMBER.TO_CANN ( p_person_id)
									|| ' INTERFACE_TST_ID :: ' || IGS_GE_NUMBER.TO_CANN ( c_tst_rec.interface_tst_id) );
				-- Insert Master End
				END;
				IF l_error_code IS NULL THEN
					--
					-- After successful insertion of the master record Check if the active ind is 'Y'
					-- If 'y' then update the other test results records with same admission_test_type
					-- to 'N'
					--
					IF c_tst_rec.active_ind = 'Y' THEN
						FOR c_other_test_rec IN c_other_test_cur ( c_tst_rec.test_type, l_test_results_id) LOOP
						-- Update Active Ind Begin
						BEGIN
							igs_ad_test_results_pkg.update_row
							(
								X_ROWID                        => c_other_test_rec.rowid,
								X_TEST_RESULTS_ID              => c_other_test_rec.test_results_id,
								X_PERSON_ID                    => c_other_test_rec.person_id,
								X_ADMISSION_TEST_TYPE          => c_other_test_rec.admission_test_type,
								X_TEST_DATE                    => c_other_test_rec.test_date,
								X_SCORE_REPORT_DATE            => c_other_test_rec.score_report_date,
								X_EDU_LEVEL_ID                 => c_other_test_rec.edu_level_id,
								X_SCORE_TYPE                   => c_other_test_rec.score_type,
								X_SCORE_SOURCE_ID              => c_other_test_rec.score_source_id,
								X_NON_STANDARD_ADMIN           => c_other_test_rec.non_standard_admin,
								X_COMP_TEST_SCORE              => c_other_test_rec.comp_test_score,
								X_SPECIAL_CODE                 => c_other_test_rec.special_code,
								X_REGISTRATION_NUMBER          => c_other_test_rec.registration_number,
								X_GRADE_ID                     => c_other_test_rec.grade_id,
								X_ATTRIBUTE_CATEGORY           => c_other_test_rec.attribute_category,
								X_ATTRIBUTE1                   => c_other_test_rec.attribute1,
								X_ATTRIBUTE2                   => c_other_test_rec.attribute2,
								X_ATTRIBUTE3                   => c_other_test_rec.attribute3,
								X_ATTRIBUTE4                   => c_other_test_rec.attribute4,
								X_ATTRIBUTE5                   => c_other_test_rec.attribute5,
								X_ATTRIBUTE6                   => c_other_test_rec.attribute6,
								X_ATTRIBUTE7                   => c_other_test_rec.attribute7,
								X_ATTRIBUTE8                   => c_other_test_rec.attribute8,
								X_ATTRIBUTE9                   => c_other_test_rec.attribute9,
								X_ATTRIBUTE10                  => c_other_test_rec.attribute10,
								X_ATTRIBUTE11                  => c_other_test_rec.attribute11,
								X_ATTRIBUTE12                  => c_other_test_rec.attribute12,
								X_ATTRIBUTE13                  => c_other_test_rec.attribute13,
								X_ATTRIBUTE14                  => c_other_test_rec.attribute14,
								X_ATTRIBUTE15                  => c_other_test_rec.attribute15,
								X_ATTRIBUTE16                  => c_other_test_rec.attribute16,
								X_ATTRIBUTE17                  => c_other_test_rec.attribute17,
								X_ATTRIBUTE18                  => c_other_test_rec.attribute18,
								X_ATTRIBUTE19                  => c_other_test_rec.attribute19,
								X_ATTRIBUTE20                  => c_other_test_rec.attribute20,
								X_MODE                         => 'R',
								X_ACTIVE_IND                   => 'N' -- This field alone is updated
							);
						EXCEPTION
							WHEN OTHERS THEN
								l_error_code := 'E004'; -- Active Indicator Update failed
								FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Active Indicator Update failed '
											|| ' Person ID :: ' || IGS_GE_NUMBER.TO_CANN ( p_person_id)
											|| ' INTERFACE_TST_ID :: ' || IGS_GE_NUMBER.TO_CANN ( c_tst_rec.interface_tst_id) );

						-- Update Active Ind End
						END;
						END LOOP;
					END IF;
				END IF;
				--
				-- After successful insertion of the master record insert the
				-- child records into the result details table
				--
				IF l_error_code IS NULL THEN
					imp_chld_test_details ( P_RETURN_STATUS => l_return_status, P_INTERFACE_TST_ID => c_tst_rec.interface_tst_id);
				END IF;
				IF NOT l_return_status THEN
					l_error_code := 'E003'; -- Insertion of child record failed
					FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Insertion of child record failed '
									|| ' Person ID :: ' || IGS_GE_NUMBER.TO_CANN ( p_person_id)
									|| ' INTERFACE_TST_ID :: ' || IGS_GE_NUMBER.TO_CANN ( c_tst_rec.interface_tst_id) );

				END IF;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				l_error_code := 'E005'; -- Test Score Import Failed
				FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Test Score Import Failed '
									|| ' Person ID :: ' || IGS_GE_NUMBER.TO_CANN ( p_person_id)
									|| ' INTERFACE_TST_ID :: ' || IGS_GE_NUMBER.TO_CANN ( c_tst_rec.interface_tst_id) );
		-- Outer End
		END;
	IF l_error_code IS NULL THEN
		DELETE FROM
			igs_ad_tstdtl_uh_int
		WHERE
			interface_tst_id = c_tst_rec.interface_tst_id;

		DELETE FROM
			igs_ad_tstrst_uh_int
		WHERE
			interface_tst_id = c_tst_rec.interface_tst_id;
	ELSE
		ROLLBACK TO before_tsttype;
		UPDATE
			igs_ad_tstrst_uh_int
		SET
			status = '3',
			error_code = l_error_code
		WHERE
			interface_tst_id = c_tst_rec.interface_tst_id;
	END IF;
END LOOP;
END transfer_int_oss;

END IGS_AD_IMP_UH_TST_PKG;

/
