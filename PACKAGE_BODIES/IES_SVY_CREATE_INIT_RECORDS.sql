--------------------------------------------------------
--  DDL for Package Body IES_SVY_CREATE_INIT_RECORDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_SVY_CREATE_INIT_RECORDS" AS
/* $Header: iescrirb.pls 120.1 2006/02/28 12:00:54 prkotha noship $ */
----------------------------------------------------------------------------------------------------------
-- Procedure
--   Create_Initial_Ques_Freq

-- PURPOSE
--   Create Initial Rows in the question frequency table
--
-- PARAMETERS
--  		deployment_id - survey deployment
-- NOTES
-- created rrsundar 05/17/2001
---------------------------------------------------------------------------------------------------------
PROCEDURE CREATE_INITIAL_QUES_FREQ
(
     p_deployment_id     IN  NUMBER
) IS
     l_errbuf 	         VARCHAR2(2000);
     l_retcode		 NUMBER;
     l_error_msg	VARCHAR2(2000);

BEGIN
        SAVEPOINT Create_Initial_Freq;
        INSERT INTO ies_svy_ques_data_v(
                         survey_name,
                         survey_id,
					cycle_name,
					survey_cycle_id,
                         survey_deployment_id,
                         deployment_name,
                         dscript_id,
                         dscript_name,
                         panel_id,
                         panel_name,
                         question_id,
                         question_name,
					question_type,
					question_order,
                         lookup_id,
                         answer_id,
					answer_order,
                         answer_value,
                         answer_display_value,
                         ANSWER_COUNT)
                        (
                        SELECT  issv.survey_name,
                                        issv.survey_id,
								iscv.survey_cycle_name,
								iscv.survey_cycle_id,
                                        isdv.survey_deployment_id,
                                        isdv.deployment_name,
                                        issv.dscript_id,
                                        ids.dscript_name,
                                        ip.panel_id,
                                        ip.panel_label,
                                        iq.question_id,
                                        iq.question_label,
								iqt.question_type,
								iq.question_order,
                                        il.lookup_id,
                                        ia.answer_id,
								ia.answer_order,
                                        ia.answer_value,
                                        ia.answer_display_value,
                                        0 answer_count
                     from    ies_svy_surveys_v issv,
                     	    ies_svy_cycles_v iscv,
                             ies_svy_deplyments_v isdv,
                             ies_deployed_scripts ids,
                             ies_panels ip,
                             ies_questions iq,
					    ies_question_types iqt,
                             ies_lookups il,
                             ies_answers ia
                        WHERE issv.dscript_id = ids.dscript_id
				    AND ids.active_status = 1
                        AND ids.dscript_id = ip.dscript_id
				    AND ip.active_status = 1
                        AND ip.panel_id = iq.panel_id
				    AND iq.active_status = 1
                        AND iq.lookup_id is not null
                        AND iq.lookup_id = il.lookup_id
				    AND iq.question_type_id = iqt.question_type_id
                        AND il.lookup_id = ia.lookup_id
				    AND ia.active_status = 1
                        AND isdv.survey_cycle_id = iscv.survey_cycle_id
                        AND iscv.survey_id = issv.survey_id
                        AND isdv.survey_deployment_id = p_deployment_id
                        UNION
                        SELECT  issv.survey_name,
                                        issv.survey_id,
								iscv.survey_cycle_name,
								iscv.survey_cycle_id,
                                        isdv.survey_deployment_id,
                                        isdv.deployment_name,
                                        issv.dscript_id,
                                        ids.dscript_name,
                                        ip.panel_id,
                                        ip.panel_label,
                                        iq.question_id,
                                        iq.question_label,
								iqt.question_type,
								iq.question_order,
                                        iq.lookup_id,
                                        0 answer_id,
								0 answer_order,
                                        ' ' answer_value,
                                        ' ' answer_display_value,
                                        0 answer_count
                                        from ies_svy_surveys_v issv,
                                        ies_svy_cycles_v iscv,
                                        ies_svy_deplyments_v isdv,
                                        ies_deployed_scripts ids,
                                        ies_panels ip,
                                        ies_questions iq,
								ies_question_types iqt
                        WHERE issv.dscript_id = ids.dscript_id
                        AND ids.dscript_id = ip.dscript_id
				    AND ids.active_status = 1
                        AND ip.panel_id = iq.panel_id
				    AND ip.active_status = 1
                        AND not exists (select '*' from ies_answers where ies_answers.lookup_id = iq.lookup_id )
				    AND iq.question_type_id = iqt.question_type_id
				    AND iq.active_status = 1
                        AND isdv.survey_cycle_id = iscv.survey_cycle_id
                        AND isdv.survey_deployment_id = p_deployment_id
                        AND iscv.survey_id = issv.survey_id);
Exception
WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IES', 'IES_SVY_INIT_QUES_FREQ_ERROR');
        l_error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_error_msg);
        l_ERRBUF := l_error_msg;
        l_RETCODE := -1;
        ROLLBACK to Create_Initial_Freq;


END CREATE_INITIAL_QUES_FREQ;

----------------------------------------------------------------------------------------------------------
-- Procedure
--   Create_Initial_List_Summary
-- PURPOSE  Create Initial Rows in List Summary
--
--
-- PARAMETERS
--		deployment_id - survey deployment
-- NOTES
-- created rrsundar 05/17/2001
---------------------------------------------------------------------------------------------------------
PROCEDURE CREATE_INITIAL_LIST_SUMMARY
(
    p_deployment_id     IN  NUMBER
) IS
     l_errbuf 	         VARCHAR2(2000);
     l_retcode		 NUMBER;
     l_error_msg	VARCHAR2(2000);
BEGIN
        SAVEPOINT Create_List_Summary;


                INSERT INTO ies_svy_list_summary_v
                        (survey_id,
                         survey_name,
                         survey_cycle_id,
                         survey_cycle_name,
                         survey_deployment_id,
                         deployment_name,
			 		target_response_percent,
			 		list_header_id,
					list_name,
					response_date,
					no_sent,
                         no_responses,
					no_errors)
                ( SELECT
                      issv.survey_id,
                      issv.survey_name,
                      isdv.survey_cycle_id,
                      iscv.survey_cycle_name,
                      islev.survey_deployment_id,
                      isdv.deployment_name,
		      	  isdv.min_responses_for_close,
		      	  ialh.list_header_id,
				  ialh.list_name,
				  null,
				  count(islev.survey_list_entry_id),
                      0,
				  0
                  FROM
                      ies_svy_list_entries_v islev,
                      ies_svy_cycles_v iscv,
                      ies_svy_deplyments_v isdv,
                      ies_svy_surveys_v  issv,
				  ams_list_headers_all ialh,
				  ams_list_entries iale
                  WHERE isdv.survey_deployment_id = p_deployment_id
                  AND islev.survey_deployment_id = isdv.survey_deployment_id
                  AND isdv.survey_cycle_id = iscv.survey_cycle_id
                  AND iscv.survey_id = issv.survey_id
			   AND islev.list_entry_id = iale.list_entry_id
			   AND iale.list_header_id = ialh.list_header_id
			   GROUP BY
			   issv.survey_id,
			   issv.survey_name,
			   isdv.survey_cycle_id,
			   iscv.survey_cycle_name,
			   islev.survey_deployment_id,
			   isdv.deployment_name,
			   isdv.min_responses_for_close,
			   ialh.list_header_id,
			   ialh.list_name,
			   null,
			   0,
			   0
			   );
Exception
WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IES', 'IES_SVY_INIT_LIST_SUMM_ERROR');
        l_error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_error_msg);
        l_ERRBUF := l_error_msg;
        l_RETCODE := -1;
        ROLLBACK TO Create_List_Summary;

END CREATE_INITIAL_LIST_SUMMARY;

----------------------------------------------------------------------------------------------------------
-- Procedure
--   CREATE_INITIAL_RECORDS

-- PURPOSE
--   Create Initial Records in Summary Tables.
--
-- PARAMETERS
--  		deployment_id - survey deployment
-- NOTES
-- created vacharya 05/17/2001
---------------------------------------------------------------------------------------------------------

   PROCEDURE  CREATE_INITIAL_RECORDS(
 --  errbuf 		OUT VARCHAR2    ,
 --  retcode		OUT NUMBER      ,
   p_deployment_id      IN  NUMBER
   )
  IS
  l_error_msg	VARCHAR2(2000);
  l_list_header_id  NUMBER;
  l_count  NUMBER := 0;
   BEGIN
        SAVEPOINT CREATE_INITIAL_RECORDS;

	Create_Initial_Ques_Freq(p_deployment_id);

	BEGIN
	SELECT list_header_id
	INTO	l_list_header_id
	  FROM ies_svy_deplyments_all
	     WHERE SURVEY_DEPLOYMENT_ID = p_deployment_id;
        EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE;
     END;


	select 1 into l_count
	from ies_svy_deplyments_v
	where survey_deployment_id = p_deployment_id;

	if (l_count > 0) then
		Create_Initial_List_Summary(p_deployment_id);
	end if;

     EXCEPTION
     WHEN OTHERS THEN
     		FND_MESSAGE.SET_NAME('IES', 'IES_SVY_ERROR_UPDT_INIT_TABLE');
     		l_error_msg := FND_MESSAGE.GET;
     		fnd_file.put_line(fnd_file.log, l_error_msg);
            --    ERRBUF := l_error_msg;
            --    RETCODE := -1;
        	ROLLBACK TO CREATE_INITIAL_RECORDS;

  END CREATE_INITIAL_RECORDS;
END IES_SVY_CREATE_INIT_RECORDS;

/
