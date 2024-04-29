--------------------------------------------------------
--  DDL for Package Body EDR_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_DRT_PKG" AS
/* $Header: EDRDRCB.pls 120.0.12010000.8 2018/06/05 05:27:23 maychen noship $ */



 PROCEDURE EDR_FND_DRC
  (PERSON_ID       IN         NUMBER,
   RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE
)
 AS

  l_proc_name           VARCHAR2(72):='EDR_DRT_PKG.EDR_FND_DRC';
  l_user_id             NUMBER;
  N                     NUMBER := 0;
  l_user_name           FND_USER.USER_NAME%TYPE;
  l_count               NUMBER;
  L_DEBUG       				BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <=
                              FND_LOG.LEVEL_EVENT;
  l_emp_id  						NUMBER;
  l_ORIG_SYSTEM VARCHAR2(240);

BEGIN

	l_user_id := person_id;

	IF L_DEBUG THEN
		fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name,
		'Start EDR_DRT_PKG.EDR_FND_DRC for current FND USER_ID:' || l_user_id );
	END IF;
  --get fnd user_name

  BEGIN
	  SELECT USER_NAME, EMPLOYEE_ID
	  	INTO l_user_name,  l_emp_id
	  FROM FND_USER
	  WHERE USER_ID = l_user_id;


  EXCEPTION
		when no_data_found then

			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'INVALID PERSON_ID' );
			END IF;

			return;
 	END;

  edr_ctx_pkg.set_secure_attr;

  l_count := 0;

  --step0, checking pending signature on EDR_PSIG_DETAILS table and raise Error Message

  select count(1) into l_count
  from EDR_PSIG_DETAILS s
  where s.signature_status = 'PENDING'
  AND user_name = l_user_name
  AND exists
  	(select 1 from EDR_PSIG_DOCUMENTS epd
  		where s.document_id = epd.document_id
  		AND epd.PSIG_STATUS = 'PENDING'
  		)
  AND rownum=1;

  IF l_count > 0 THEN

	  per_drt_pkg.add_to_results(
	    person_id     => l_user_id,
	    entity_type   => 'FND',
	    status        => 'E',
	    msgcode       => 'EDR_GDPR_DRC_ERROR',
	    msgaplid      => 709,
	    RESULT_TBL    => RESULT_TBL
		);
		N := RESULT_TBL.COUNT ;

		IF L_DEBUG THEN
			fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
			|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode) );
		END IF;
	END IF;



  --step1, checking on table EDR_ESIGNATURES, col user_name

	 IF N = 0  THEN
		select count(1)
			into l_count
		from EDR_ESIGNATURES
		where user_name = l_user_name
			and rownum=1;


		IF l_count > 0 THEN

		  per_drt_pkg.add_to_results(
		    person_id     => l_user_id,
		    entity_type   => 'FND',
		    status        => 'W',
		    msgcode       => 'EDR_GDPR_DRC_ERROR',
		    msgaplid      => 709,
		    RESULT_TBL    => RESULT_TBL
			);
			N := RESULT_TBL.COUNT ;

			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode) );
			END IF;

		ELSE

		  --step2, checking on table EDR_ESIGNATURES, col ORIGINAL_RECIPIENT

			select count(1)
				into l_count
			from EDR_ESIGNATURES
			where ORIGINAL_RECIPIENT = l_user_name
				and rownum=1;

			IF l_count > 0 THEN
				per_drt_pkg.add_to_results(
			    person_id     => l_user_id,
			    entity_type   => 'FND',
			    status        => 'W',
			    msgcode       => 'EDR_GDPR_DRC_ERROR',
			    msgaplid      => 709,
			    RESULT_TBL    => RESULT_TBL
				);
				N := RESULT_TBL.COUNT ;

				IF L_DEBUG THEN
					fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
					|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
				END IF;

			ELSE
				--step3, checking on table EDR_ESIGNATURES, col SIGNATURE_OVERRIDING_COMMENTS

				--current fnd user is not associated to hr person, matching the fnd description
				IF l_emp_id iS NULL THEN

					select count(1)
						into l_count
					from EDR_ESIGNATURES
					where SIGNATURE_OVERRIDING_COMMENTS like '%' || l_user_name || '%'
						AND rownum=1;

					IF l_count > 0 THEN

						per_drt_pkg.add_to_results(
					    person_id     => l_user_id,
					    entity_type   => 'FND',
					    status        => 'W',
					    msgcode       => 'EDR_GDPR_DRC_ERROR',
					    msgaplid      => 709,
					    RESULT_TBL    => RESULT_TBL
						);
						N := RESULT_TBL.COUNT ;

						IF L_DEBUG THEN
							fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
							|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
						END IF;

					END IF;

				END IF;

			END IF;

		END IF;

	END IF;
  --checking on table EDR_PSIG_DETAILS (constraint:4,5,6,7)
  IF N = 0  THEN
    --step4, checking on table EDR_PSIG_DETAILS, col: user_name

	  select count(1)
	  	into l_count
		from EDR_PSIG_DETAILS
		where user_name = l_user_name
		and rownum=1;


		IF l_count > 0 THEN
			per_drt_pkg.add_to_results(
		    person_id     => l_user_id,
		    entity_type   => 'FND',
		    status        => 'W',
		    msgcode       => 'EDR_GDPR_DRC_ERROR',
		    msgaplid      => 709,
		    RESULT_TBL    => RESULT_TBL
			);
			N := RESULT_TBL.COUNT ;

			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
			END IF;

		ELSE
			--step5, checking on table EDR_PSIG_DETAILS, col: ORIGINAL_RECIPIENT
			select count(1)
				into l_count
			from EDR_PSIG_DETAILS
			where ORIGINAL_RECIPIENT = l_user_name
				and rownum=1;

			IF l_count > 0 THEN
				per_drt_pkg.add_to_results(
			    person_id     => l_user_id,
			    entity_type   => 'FND',
			    status        => 'W',
			    msgcode       => 'EDR_GDPR_DRC_ERROR',
			    msgaplid      => 709,
			    RESULT_TBL    => RESULT_TBL
				);
				N := RESULT_TBL.COUNT ;

				IF L_DEBUG THEN
					fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
					|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
				END IF;


			ELSE
				--step6, checking on table EDR_PSIG_DETAILS, col: USER_DISPLAY_NAME
				--FOR FND_USR type orig system, the user_display_name is same as user_name

				IF l_emp_id iS NULL THEN
				  select count(1)
						into l_count
					from EDR_PSIG_DETAILS
					where USER_DISPLAY_NAME = l_user_name
					 AND  ORIG_SYSTEM = 'FND_USR'
						and rownum=1;

					IF l_count > 0 THEN
						per_drt_pkg.add_to_results(
					    person_id     => l_user_id,
					    entity_type   => 'FND',
					    status        => 'W',
					    msgcode       => 'EDR_GDPR_DRC_ERROR',
					    msgaplid      => 709,
					    RESULT_TBL    => RESULT_TBL
						);
						N := RESULT_TBL.COUNT ;

						IF L_DEBUG THEN
							fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
							|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
						END IF;

					ELSE
						 --step7, checking on table EDR_PSIG_DETAILS, col: SIGNATURE_OVERRIDING_COMMENTS
					--current fnd user is not associated to hr person, matching with l_uesr_name
						select count(1)
							into l_count
						from EDR_PSIG_DETAILS
						where SIGNATURE_OVERRIDING_COMMENTS like '%' || l_user_name || '%'
						  AND ORIG_SYSTEM = 'FND_USR'
							and rownum=1;

						IF l_count > 0 THEN

							per_drt_pkg.add_to_results(
						    person_id     => l_user_id,
						    entity_type   => 'FND',
						    status        => 'W',
						    msgcode       => 'EDR_GDPR_DRC_ERROR',
						    msgaplid      => 709,
						    RESULT_TBL    => RESULT_TBL
							);
							N := RESULT_TBL.COUNT ;

							IF L_DEBUG THEN
								fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
								|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
							END IF;

						END IF; --l_count > 0

				 	END IF; --end l_count >0

				END IF;  --IF  l_emp_id IS NULL

			END IF; --l_count>0

		END IF;  --l_count>0

	END IF; --N= 0


  --checking on table EDR_PSIG_DOCUMENTS (constraint 8,9)
	IF N = 0  THEN
   --step8, checking on table EDR_PSIG_DOCUMENTS, Col: DOCUMENT_REQUESTER

	  select count(1)
	  	into l_count
		from EDR_PSIG_DOCUMENTS
		where DOCUMENT_REQUESTER = l_user_name
		and rownum=1;


		IF l_count > 0 THEN

			per_drt_pkg.add_to_results(
		    person_id     => l_user_id,
		    entity_type   => 'FND',
		    status        => 'W',
		    msgcode       => 'EDR_GDPR_DRC_ERROR',
		    msgaplid      => 709,
		    RESULT_TBL    => RESULT_TBL
			);
			N := RESULT_TBL.COUNT ;

			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
			END IF;
		ELSE
		--step9, checking on table EDR_PSIG_DOCUMENTS, Col: DOC_REQ_DISP_NAME
			IF l_emp_id iS NULL THEN

				select count(1)
					into l_count
				from EDR_PSIG_DOCUMENTS
				where DOC_REQ_DISP_NAME = l_user_name
					and rownum=1;

				IF l_count > 0 THEN

					per_drt_pkg.add_to_results(
				    person_id     => l_user_id,
				    entity_type   => 'FND',
				    status        => 'W',
				    msgcode       => 'EDR_GDPR_DRC_ERROR',
				    msgaplid      => 709,
				    RESULT_TBL    => RESULT_TBL
					);
					N := RESULT_TBL.COUNT ;

					IF L_DEBUG THEN
						fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
						|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
					END IF;

				END IF; --l_count >0

			END IF; --l_emp_id is NULL

		END IF; -- l_count >0
	END IF; --N=0


	IF N = 0   THEN
   --step 10 , checking on table EDR_PROCESS_ERECORDS_T, Col: REQUESTER

	  select count(1) into l_count
		from EDR_PROCESS_ERECORDS_T
		where REQUESTER = l_user_name
		and rownum=1;


		IF l_count > 0 THEN

			per_drt_pkg.add_to_results(
		    person_id     => l_user_id,
		    entity_type   => 'FND',
		    status        => 'W',
		    msgcode       => 'EDR_GDPR_DRC_ERROR',
		    msgaplid      => 709,
		    RESULT_TBL    => RESULT_TBL
			);
			N := RESULT_TBL.COUNT ;

			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
			END IF;

		END IF;

	END IF;

  IF N = 0  THEN
   --step10, checking on table EDR_PSIG_PRINT_HISTORY, Col: PRINT_REQUESTED_BY

	  select count(1) into l_count
		from EDR_PSIG_PRINT_HISTORY
		where PRINT_REQUESTED_BY = l_user_name
		and rownum=1;


		IF l_count > 0 THEN

			per_drt_pkg.add_to_results(
		    person_id     => l_user_id,
		    entity_type   => 'FND',
		    status        => 'W',
		    msgcode       => 'EDR_GDPR_DRC_ERROR',
		    msgaplid      => 709,
		    RESULT_TBL    => RESULT_TBL
			);
			N := RESULT_TBL.COUNT ;

			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
			END IF;
		ELSE
 	   --step11, checking on table EDR_PSIG_PRINT_HISTORY, Col: PRINT_REQUESTED_BY

			IF l_emp_id iS NULL THEN

				select count(1)
					 into l_count
				from EDR_PSIG_PRINT_HISTORY
					where USER_DISPLAY_NAME = l_user_name
							AND ORIG_SYSTEM = 'FND_USR'
							AND rownum=1;


				IF l_count > 0 THEN

					per_drt_pkg.add_to_results(
					  person_id     => l_user_id,
					  entity_type   => 'FND',
					  status        => 'W',
					  msgcode       => 'EDR_GDPR_DRC_ERROR',
					  msgaplid      => 709,
					  RESULT_TBL    => RESULT_TBL
					);
					N := RESULT_TBL.COUNT ;

					IF L_DEBUG THEN
						fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
						|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
					END IF;

				END IF;

			END IF;

		END IF;
	END IF;

	edr_ctx_pkg.unset_secure_attr;
	-- IF THERE IS NO error or warning:
	IF N = 0 THEN

		per_drt_pkg.add_to_results(
	    person_id     => l_user_id,
	    entity_type   => 'FND',
	    status        => 'S',
	    msgcode       => NULL,
	    msgaplid      => NULL,
	    RESULT_TBL    => RESULT_TBL
		);
		N := RESULT_TBL.COUNT ;
		IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
			|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
		END IF;

	END IF ;

	IF L_DEBUG THEN
		fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name,
	 		'Completed EDR_FND_DRC for current FND USER_ID:' || l_user_id || ': USER_NAME: ' || l_user_name);
	END IF;



END EDR_FND_DRC;


 PROCEDURE EDR_HR_DRC
  (PERSON_ID       IN         NUMBER,  --HR Person Id
   RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE
)
 AS

  l_proc_name           VARCHAR2(72):='EDR_DRT_PKG.EDR_HR_DRC';
  l_person_id           NUMBER;
  N                     NUMBER := 0;
  l_user_display_name   VARCHAR2(240);
  l_count               NUMBER := 0;
  L_DEBUG        BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <=
                              FND_LOG.LEVEL_EVENT;

BEGIN


  l_person_id := person_id;

  IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name,
	 	'Start EDR_HR_DRC for current HR PERSON_ID:' || l_person_id );
	END IF;



  --get user display name

  BEGIN
  SELECT
    global_name
    INTO l_user_display_name
	FROM
	    per_people_f
	WHERE
	    person_id = l_person_id
	AND /* bug 27879954*/
	    ROWNUM = 1
	ORDER BY
    effective_start_date DESC	 ;

	EXCEPTION
	  when no_data_found then

			per_drt_pkg.add_to_results(
				person_id     => l_person_id,
				entity_type   => 'HR',
				status        => 'W',
				msgcode       => 'EDR_INVALID_PERSONID',
				msgaplid      => 709,
				RESULT_TBL    => RESULT_TBL
			);
	 		N := RESULT_TBL.COUNT ;

			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;

			END IF;

			return;
 	end;


 	edr_ctx_pkg.set_secure_attr;

 	  --step1, checking on table EDR_ESIGNATURES, col:SIGNATURE_OVERRIDING_COMMENTS,
 	  ---"Delegated: From Copeland, Sandra To Williams, Steve "

	select count(1)
		into l_count
	from EDR_ESIGNATURES
	where SIGNATURE_OVERRIDING_COMMENTS like '%' || l_user_display_name || '%'
		and rownum=1;

	IF l_count > 0 THEN

		per_drt_pkg.add_to_results(
			person_id     => l_person_id,
			entity_type   => 'HR',
			status        => 'W',
			msgcode       => 'EDR_GDPR_DRC_ERROR',
			msgaplid      => 709,
			RESULT_TBL    => RESULT_TBL
		);
		N := RESULT_TBL.COUNT ;

		IF L_DEBUG THEN
			fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
			|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
		END IF;

	END IF;

  --step 2, checking on table EDR_PSIG_DETAILS, col:USER_DISPLAY_NAME

	IF N = 0 THEN
	  select count(1) into l_count
		from EDR_PSIG_DETAILS
		where USER_DISPLAY_NAME = l_user_display_name
		AND ORIG_SYSTEM = 'PER'
		and rownum=1;


		IF l_count > 0 THEN

			per_drt_pkg.add_to_results(
				person_id     => l_person_id,
				entity_type   => 'HR',
				status        => 'W',
				msgcode       => 'EDR_GDPR_DRC_ERROR',
				msgaplid      => 709,
				RESULT_TBL    => RESULT_TBL
				);
			N := RESULT_TBL.COUNT ;


			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
			END IF;

	 	ELSE
	 	 --step 3, checking on table EDR_PSIG_DETAILS, col:SIGNATURE_OVERRIDING_COMMENTS
	 		select count(1)
				into l_count
			from EDR_PSIG_DETAILS
			where SIGNATURE_OVERRIDING_COMMENTS like '%' || l_user_display_name || '%'
			  AND ORIG_SYSTEM = 'PER'
				and rownum=1;

			IF l_count > 0 THEN
				per_drt_pkg.add_to_results(
					person_id     => l_person_id,
					entity_type   => 'HR',
					status        => 'W',
					msgcode       => 'EDR_GDPR_DRC_ERROR',
					msgaplid      => 709,
					RESULT_TBL    => RESULT_TBL
				);
				N := RESULT_TBL.COUNT ;

				IF L_DEBUG THEN
					fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
					|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
				END IF;

			END IF;

		END IF;

	END IF;

 IF N = 0 THEN
 --step4, checking on table EDR_PSIG_DOCUMENTS, col: DOC_REQ_DISP_NAME

	  select count(1) into l_count
			from EDR_PSIG_DOCUMENTS
			where DOC_REQ_DISP_NAME = l_user_display_name
			and rownum=1;


		IF l_count > 0 THEN
				per_drt_pkg.add_to_results(
					person_id     => l_person_id,
					entity_type   => 'HR',
					status        => 'W',
					msgcode       => 'EDR_GDPR_DRC_ERROR',
					msgaplid      => 709,
					RESULT_TBL    => RESULT_TBL
				);
				N := RESULT_TBL.COUNT ;

				IF L_DEBUG THEN
					fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
						|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
				END IF;

		END IF;
 	END IF;



 --step5, checking on table EDR_PSIG_PRINT_HISTORY, COL: USER_DISPLAY_NAME

	IF N = 0 THEN
		select count(1) into l_count
		from EDR_PSIG_PRINT_HISTORY
		where USER_DISPLAY_NAME  = l_user_display_name
		AND ORIG_SYSTEM = 'PER'
		and rownum=1;

		IF l_count > 0 THEN

			per_drt_pkg.add_to_results(
				person_id     => l_person_id,
				entity_type   => 'HR',
				status        => 'W',
				msgcode       => 'EDR_GDPR_DRC_ERROR',
				msgaplid      => 709,
				RESULT_TBL    => RESULT_TBL
			);
			N := RESULT_TBL.COUNT ;

			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
					|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
				END IF;

		END IF;
	END IF;

	edr_ctx_pkg.unset_secure_attr;

	-- IF THERE IS NO error:
	IF N = 0 THEN

		per_drt_pkg.add_to_results(
			person_id     => l_person_id,
			entity_type   => 'HR',
			status        => 'S',
			msgcode       => NULL,
			msgaplid      => NULL,
			RESULT_TBL    => RESULT_TBL
		);
		N := RESULT_TBL.COUNT ;

		IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' || FND_MESSAGE.GET_STRING('EDR',RESULT_TBL(N).msgcode)) ;
		END IF;


	END IF ;

	IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name,
	 	'Completed EDR_FND_DRC for current HR PERSON_ID:' || l_person_id || ': Person Name: ' || l_user_display_name);
	END IF;



END EDR_HR_DRC;

END EDR_DRT_PKG;

/
