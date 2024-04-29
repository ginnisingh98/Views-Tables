--------------------------------------------------------
--  DDL for Package Body EBS_DRT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EBS_DRT_UTILS" AS
/* $Header: ebdrtutl.pkb 120.0.12010000.3 2020/03/13 11:19:14 ktithy noship $ */

FUNCTION GET_FULL_NAME
  (p_person_id   IN number
  ,p_entity_type IN varchar2) RETURN varchar2 IS

  l_full_name varchar2(2000) DEFAULT '';

BEGIN
  IF p_entity_type = 'HR' THEN

    SELECT  full_name
    INTO    l_full_name
    FROM    per_all_people_f
    WHERE   person_id = p_person_id
    AND     trunc (sysdate) BETWEEN effective_start_date
                            AND     effective_end_date;

	ELSIF p_entity_type = 'FND' THEN

    SELECT  user_name
    INTO    l_full_name
    FROM    fnd_user
    WHERE   user_id = p_person_id;

	ELSIF p_entity_type = 'TCA' THEN

    SELECT  party_name
    INTO    l_full_name
    FROM    hz_parties
    WHERE   party_id = p_person_id;

  END IF;

  RETURN l_full_name;
END GET_FULL_NAME;

PROCEDURE ENTITY_CHECK_CONSTRAINTS
    (CHK_DRC_BATCH IN  EBS_DRT_REMOVAL_REC) IS

	l_batch_id	number;
	l_full_name varchar2(2000);

CURSOR c_batch IS
  SELECT  per_drt_person_batch_s.nextval
  FROM    dual;

CURSOR c_removal_id
  (p_person_id IN number
  ,p_entity_type IN varchar2) IS
  SELECT  removal_id
  FROM    per_drt_person_data_removals
  WHERE   person_id = p_person_id
  AND     entity_type = p_entity_type;


CURSOR c_drc_batch(p_batch_id number) IS
  SELECT  *
  FROM    PER_DRT_PERSON_BATCH where operation_type = 'CONSTRAINT' and batch_id = p_batch_id;

	l_removal_id number(15);
	l_process_tbl 			per_drt_pkg.result_tbl_type;
	l_error number(10) := 0;
	l_warning number(10) := 0;


BEGIN

		/* Insert the table into Removals table with operation type as CONSTRAINT */
		for i in 1..chk_drc_batch.count loop

			l_removal_id := null;

			open c_removal_id(chk_drc_batch (i).person_id,chk_drc_batch (i).person_type);
			fetch c_removal_id into l_removal_id;
			close c_removal_id;

			if (l_removal_id is null) then

					l_full_name := get_full_name(chk_drc_batch (i).person_id,chk_drc_batch (i).person_type);
					INSERT
					INTO    per_drt_person_data_removals
					        (removal_id
					        ,person_id
					        ,entity_type
					        ,full_name
					        ,status)
					VALUES
					        (per_drt_person_batch_s.nextval
					        ,chk_drc_batch (i).person_id
					        ,chk_drc_batch (i).person_type
					        ,l_full_name
					        ,'Check Constraints');

			end if;

		end loop;

		l_removal_id := null;

		/* Create a batch_id */
		open c_batch;
		fetch c_batch into l_batch_id;
		close c_batch;

		/* Insert the table into DB stage table with operation type as CONSTRAINT */
		forall i in 1..chk_drc_batch.count
			INSERT
			INTO    per_drt_person_batch(BATCH_ID,PERSON_ID,ENTITY_TYPE,OPERATION_TYPE)
			VALUES
			        (l_batch_id
			        ,chk_drc_batch (i).person_id
			        ,chk_drc_batch (i).person_type
			        ,'CONSTRAINT');

	/* Loop through the CONSTRAINT batch */
	for drc_person in c_drc_batch(l_batch_id)
	loop


		/* Get the removal_id for the person_id and entity_type */
							open c_removal_id(drc_person.person_id,drc_person.entity_type);
							fetch c_removal_id into l_removal_id;
							close c_removal_id;

								fnd_file.put_line(fnd_file.log, 'CONSTRAINT :: person_id :' || drc_person.person_id );
								fnd_file.put_line(fnd_file.log, 'CONSTRAINT :: entity_type :' || drc_person.entity_type );
								fnd_file.put_line(fnd_file.log, 'CONSTRAINT :: Removal ID :' || l_removal_id );

		dbms_output.put_line('CONSTRAINTS_CHECK :: person_id :' || drc_person.person_id || ':: entity_type :' || drc_person.entity_type || ':: Removal ID :' || l_removal_id );


		/* Run the DRC batch for the person and the dependents */
		ebs_drt_pkg.drc_results(drc_person.person_id,drc_person.entity_type,l_error,l_warning,l_process_tbl);

		/* Remove the constraints from the DB table if there are any for the removal_id */
		delete from PER_DRT_PERSON_CONSTRAINTS where removal_id = l_removal_id;

		/* Loop through the constraints and insert to the DB Table */
		forall i in 1..l_process_tbl.count
			insert into PER_DRT_PERSON_CONSTRAINTS
			(CONSTRAINT_ID
			,REMOVAL_ID
			,PERSON_ID
			,ENTITY_TYPE
			,CONSTRAINT_TYPE
			,MESSAGE_NAME
			,MSG_APPLICATION_ID)
			values
			(PER_DRT_PERSON_CONSTRAINTS_s.nextval
			,l_removal_id
			,l_process_tbl(i).person_id
			,l_process_tbl(i).entity_type
			,l_process_tbl(i).status
			,l_process_tbl(i).msgcode
			,l_process_tbl(i).msgaplid);

		/* Count the number of error and warnings, update the counts to the table */
			if l_error > 0 then
					update PER_DRT_PERSON_DATA_REMOVALS
						set ERROR_COUNT = l_error,
								WARNING_COUNT = l_warning ,
								STATUS = 'Errors Exist',
								last_run_date = sysdate
						where removal_id = l_removal_id;

			elsif l_warning > 0 then
					update PER_DRT_PERSON_DATA_REMOVALS
						set ERROR_COUNT = l_error,
								WARNING_COUNT = l_warning ,
								STATUS = 'Warnings Exist',
								last_run_date = sysdate
						where removal_id = l_removal_id;

			else
					update PER_DRT_PERSON_DATA_REMOVALS
						set ERROR_COUNT = l_error,
								WARNING_COUNT = l_warning ,
								last_run_date = sysdate
						where removal_id = l_removal_id;

			end if;

	end loop;

	/* Delete from DB stage table with operation type as CONSTRAINT Process done*/
	DELETE FROM PER_DRT_PERSON_BATCH where operation_type = 'CONSTRAINT'  and batch_id = l_batch_id;

  EXCEPTION
    WHEN others THEN
	/* Delete from DB stage table with operation type as CONSTRAINT an error occured*/
			DELETE FROM PER_DRT_PERSON_BATCH where operation_type = 'CONSTRAINT'  and batch_id = l_batch_id;


END ENTITY_CHECK_CONSTRAINTS;


PROCEDURE ENTITY_REMOVE
    (CHK_DRC_BATCH IN  EBS_DRT_REMOVAL_REC,
			OVERRIDE_WARNINGS IN varchar2 DEFAULT 'N') IS

	l_batch_id	number;
	l_full_name varchar2(2000);

CURSOR c_batch IS
  SELECT  per_drt_person_batch_s.nextval
  FROM    dual;


CURSOR c_remove_batch(p_batch_id number) IS
  SELECT  *
  FROM    PER_DRT_PERSON_BATCH where operation_type = 'REMOVE' and batch_id = p_batch_id;

	l_removal_id number(15);
  l_process_code varchar2(1);

	p_errbuf varchar2(2000);
	p_retcode number(15);
	l_count number(15);
	l_warning_count number(15);

BEGIN

		/* Create a batch_id */
		open c_batch;
		fetch c_batch into l_batch_id;
		close c_batch;

		/* Insert the table into DB stage table with operation type as REMOVE */
		for i in 1..chk_drc_batch.count loop

		l_count := 0;


		SELECT count(*) into l_count FROM PER_DRT_PERSON_DATA_REMOVALS
		WHERE   person_id = chk_drc_batch (i).person_id
		AND     entity_type = chk_drc_batch (i).person_type
		AND     ERROR_COUNT = 0;

		SELECT count(*) into l_warning_count FROM PER_DRT_PERSON_DATA_REMOVALS
		WHERE   person_id = chk_drc_batch (i).person_id
		AND     entity_type = chk_drc_batch (i).person_type
		AND     WARNING_COUNT = 0;

		if (l_count > 0 AND (l_warning_count > 0 OR OVERRIDE_WARNINGS = 'Y')) then

			INSERT
			INTO    per_drt_person_batch(BATCH_ID,PERSON_ID,ENTITY_TYPE,OPERATION_TYPE)
			VALUES
			        (l_batch_id
			        ,chk_drc_batch (i).person_id
			        ,chk_drc_batch (i).person_type
			        ,'REMOVE');

		else

		fnd_file.put_line(fnd_file.log, 'CHECK_CONSTRAINTS Not Executed or Errors/Warnings Exist For person_id ::' || chk_drc_batch (i).person_id  || ':: entity_type :' || chk_drc_batch (i).person_type);
		dbms_output.put_line('CHECK_CONSTRAINTS Not Executed or Errors/Warnings Exist For person_id ::' || chk_drc_batch (i).person_id  || ':: entity_type :' || chk_drc_batch (i).person_type);

		end if;

		end loop;

		ebs_drt_pkg.submit_remove_request(errbuf => p_errbuf,
																retcode => p_retcode,
																p_batch_id => l_batch_id);

  EXCEPTION
    WHEN others THEN
	/* Delete from DB stage table with operation type as REMOVE */
			DELETE FROM PER_DRT_PERSON_BATCH where operation_type = 'REMOVE'  and batch_id = l_batch_id;


END ENTITY_REMOVE;

END EBS_DRT_UTILS;

/
