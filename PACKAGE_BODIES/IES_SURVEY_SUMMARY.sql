--------------------------------------------------------
--  DDL for Package Body IES_SURVEY_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_SURVEY_SUMMARY" AS
/* $Header: iessummb.pls 120.1 2005/06/16 11:15:48 appldev  $ */
/*==========================================================================+
 | PROCEDURES.                                                              |
 | Compute_Summary.                                                         |
 +==========================================================================*/


  --global package variables.
  g_sqlerrm varchar2(500);
  g_sqlcode varchar2(500);

  G_PKG_NAME      CONSTANT VARCHAR2(30):='IES_SURVEY_SUMMARY';
  G_FILE_NAME     CONSTANT VARCHAR2(12):='iessummb.pls';

----------------------------------------------------------------------------------------------------------
-- Procedure
--   Compute_Summary

-- PURPOSE
--   Summarize IES_QUESTION_DATA and IES_ANSWER_DATA
--
-- PARAMETERS
--  		survey_id - survey deployment
--		list_entry_id - list entry identifier
--		template_id - fulfillment template identifier
-- NOTES
-- created rrsundar 05/03/2000
---------------------------------------------------------------------------------------------------------
Procedure  Compute_Summary( p_deployment_id  in number    := NULL) is

  l_return_number NUMBER      := NULL;
  l_return_status VARCHAR2(1) := NULL;
  l_msg_count NUMBER          := NULL;
  l_msg_data  VARCHAR2(2000)  := NULL;
  l_cycle_id NUMBER := NULL;
  l_survey_id NUMBER := NULL;
  l_survey_cycle_id NUMBER := NULL;
  l_survey_deployment_id NUMBER := NULL;
  l_survey_status VARCHAR2(30) := NULL;
  l_deployment_status VARCHAR2(30) := NULL;
  l_survey_name VARCHAR2(240) := NULL;
  l_survey_cycle_name VARCHAR2(240) := NULL;
  l_media_type_code VARCHAR2(240) := NULL;
  l_list_header_id NUMBER := NULL;
  l_list_name VARCHAR2(240) := NULL;
  l_deployment_name VARCHAR2(240) := NULL;
  l_total_no_sent NUMBER := NULL;
  l_total_no_errors NUMBER := NULL;
  l_total_no_responses_recd NUMBER := NULL;
  l_total_no_abandoned NUMBER := NULL;
  l_total_no_aborted NUMBER := NULL;
  l_deploy_date DATE;
  l_response_end_date DATE;
  l_deployment_id NUMBER := NULL;

cursor cdepid is
   select survey_deployment_id
   from ies_svy_summary_stats_v
   where survey_deployment_id = p_deployment_id;

Begin

    select iscv.survey_id,
	   issv.survey_name,
	   issv.survey_status_code,
	   isdv.survey_cycle_id,
	   iscv.survey_cycle_name,
	   isdv.media_type_code,
	   alsh.list_header_id,
	   isdv.deployment_status_code,
	   alsh.list_name,
	   isdv.deploy_date,
        isdv.response_end_date,
	   isdv.deployment_name
    into
	   l_survey_id,
	   l_survey_name,
	   l_survey_status,
	   l_survey_cycle_id,
	   l_survey_cycle_name,
	   l_media_type_code,
	   l_list_header_id,
	   l_deployment_status,
	   l_list_name,
	   l_deploy_date,
	   l_response_end_date,
	   l_deployment_name
    from ies_svy_deplyments_v isdv, ams_list_headers_all alsh, ies_svy_cycles_v iscv, ies_svy_surveys_v issv
    where isdv.survey_deployment_id = p_deployment_id
    and   isdv.list_header_id = alsh.list_header_id(+)
    and   isdv.survey_cycle_id = iscv.survey_cycle_id
    and   iscv.survey_id = issv.survey_id;


    select count(decode(response_status, 'COMPLETE', 1,0)),
		 count(decode(response_status, 'ABANDONED',1,0)),
		 count(decode(response_status, 'ABORTED', 1, 0))
    into
		 l_total_no_responses_recd,
    	 	 l_total_no_abandoned,
	 	 l_total_no_aborted
    from ies_svy_resp_entries_v
    where survey_deployment_id = p_deployment_id;


	select count(*),
		  sum(decode(error_code, 'YES', 1, 0))
	into
		l_total_no_sent,
		l_total_no_errors
	from ies_svy_list_entries_v
	where survey_deployment_id = p_deployment_id;

	if (l_total_no_sent is null) then
		l_total_no_sent := 0;
	end if;
	if (l_total_no_errors is null) then
		l_total_no_errors := 0;
	end if;

   open cdepid;
   fetch cdepid into l_deployment_id;
   if(cdepid%NOTFOUND)then
    close cdepid;
    			insert into ies_svy_summary_stats_v
				(survey_id,
				 survey_cycle_id,
				 survey_deployment_id,
				 survey_deployment_name,
				 survey_name,
				 survey_status,
				 survey_cycle_name,
				 media_type_code,
	 			 deploy_date,
				 response_end_date,
				 list_header_id,
				 deployment_status,
				 list_name,
				 object_version_number,
				 total_no_sent,
				 total_no_errors,
				 total_no_responses_recd,
				 total_abandoned,
				 total_aborted,
				 refresh_date,
				 f_deletedflag)
		      values
				(l_survey_id,
				 l_survey_cycle_id,
				 p_deployment_id,
				 l_deployment_name,
				 l_survey_name,
				 l_survey_status,
				 l_survey_cycle_name,
				 l_media_type_code,
				 l_deploy_date,
			         l_response_end_date,
				 l_list_header_id,
				 l_deployment_status,
				 l_list_name,
				 1,
				 nvl(l_total_no_sent,0),
				 nvl(l_total_no_errors,0),
				 nvl(l_total_no_responses_recd,0),
				 nvl(l_total_no_abandoned, 0),
				 nvl(l_total_no_aborted, 0),
				 sysdate,
				 null);

   else
	 update ies_svy_summary_stats_v
	  set total_no_sent = nvl(l_total_no_sent,0) ,
	      total_no_errors = nvl(l_total_no_errors,0),
	      total_no_responses_recd = nvl(l_total_no_responses_recd,0),
		 total_abandoned = nvl(l_total_no_abandoned,0),
		 total_aborted = nvl(l_total_no_aborted, 0),
	      refresh_date = sysdate
	 where survey_deployment_id = p_deployment_id;
	 close cdepid;
   end if;
End;


Procedure  Compute_Summary_Non_List( p_deployment_id  in number    := NULL) is

  l_return_number NUMBER      := NULL;
  l_return_status VARCHAR2(1) := NULL;
  l_msg_count NUMBER          := NULL;
  l_msg_data  VARCHAR2(2000)  := NULL;
  l_cycle_id NUMBER := NULL;
  l_survey_id NUMBER := NULL;
  l_survey_cycle_id NUMBER := NULL;
  l_survey_deployment_id NUMBER := NULL;
  l_survey_name VARCHAR2(240) := NULL;
  l_survey_cycle_name VARCHAR2(240) := NULL;
  l_survey_status VARCHAR2(30) := NULL;
  l_deployment_status VARCHAR2(30) := NULL;
  l_media_type_code VARCHAR2(240) := NULL;
  l_deployment_name VARCHAR2(240) := NULL;
  l_total_no_sent NUMBER := NULL;
  l_total_no_errors NUMBER := NULL;
  l_total_no_responses_recd NUMBER := NULL;
  l_total_no_abandoned NUMBER := NULL;
  l_total_no_aborted NUMBER := NULL;
  l_deploy_date DATE;
  l_response_end_date DATE;
  l_deployment_id NUMBER := NULL;

cursor cdepid is
   select survey_deployment_id
   from ies_svy_summary_stats_v
   where survey_deployment_id = p_deployment_id;

Begin
    select iscv.survey_cycle_id,
		iscv.survey_cycle_name,
		issv.survey_id,
		issv.survey_name,
		issv.survey_status_code,
	   	isdv.media_type_code,
	   	isdv.deploy_date,
       	isdv.response_end_date,
	   	isdv.deployment_name,
		isdv.deployment_status_code
    into   l_survey_cycle_id,
		l_survey_cycle_name,
		l_survey_id,
		l_survey_name,
		l_survey_status,
	     l_media_type_code,
	     l_deploy_date,
	     l_response_end_date,
	     l_deployment_name,
		l_deployment_status
    from ies_svy_deplyments_v isdv,
	    ies_svy_cycles_v iscv,
	    ies_svy_surveys_v issv
    where survey_deployment_id = p_deployment_id
    and   isdv.survey_cycle_id = iscv.survey_cycle_id
    and   iscv.survey_id = issv.survey_id;



    select count(decode(response_status, 'COMPLETE', 1,0)),
		 count(decode(response_status, 'ABANDONED',1,0)),
		 count(decode(response_status, 'ABORTED', 1, 0))
    into
		 l_total_no_responses_recd,
    	 	 l_total_no_abandoned,
	 	 l_total_no_aborted
    from ies_svy_resp_entries_v
    where survey_deployment_id = p_deployment_id;

   open cdepid;
   fetch cdepid into l_deployment_id;
   if(cdepid%NOTFOUND)then
    close cdepid;
    insert into ies_svy_summary_stats_v
	(survey_id,
	 survey_cycle_id,
	 survey_deployment_id,
	 survey_deployment_name,
	 deployment_status,
	 survey_name,
	 survey_status,
	 survey_cycle_name,
	 media_type_code,
	 deploy_date,
	 response_end_date,
	 object_version_number,
	 total_no_errors,
	 total_abandoned,
	 total_aborted,
	 total_no_responses_recd,
	 refresh_date,
	 f_deletedflag)
   values
	(l_survey_id,
	 l_survey_cycle_id,
	 p_deployment_id,
	 l_deployment_name,
	 l_deployment_status,
	 l_survey_name,
	 l_survey_status,
	 l_survey_cycle_name,
	 l_media_type_code,
	 l_deploy_date,
      l_response_end_date,
	 1,
	 nvl(l_total_no_errors,0),
	 nvl(l_total_no_abandoned, 0),
	 nvl(l_total_no_aborted, 0),
	 nvl(l_total_no_responses_recd,0),
	 sysdate,
	 null);

   else
	 update ies_svy_summary_stats_v
	  set total_no_sent = nvl(l_total_no_sent,0) ,
	      total_no_errors = nvl(l_total_no_errors,0),
	      total_no_responses_recd = nvl(l_total_no_responses_recd,0),
		 total_abandoned = nvl(l_total_no_abandoned,0),
		 total_aborted = nvl(l_total_no_aborted, 0),
	      refresh_date = sysdate
	 where survey_deployment_id = p_deployment_id;
	 close cdepid;
   end if;
   End;


Procedure  Summarize_Survey_Data(
			ERRBUF        OUT NOCOPY /* file.sql.39 change */ VARCHAR2         ,
			RETCODE       OUT NOCOPY /* file.sql.39 change */ BINARY_INTEGER        ,
			p_cycle_id      IN  NUMBER)
IS
l_error_msg		VARCHAR2(2000) := NULL;
l_retcode 		NUMBER := 0;
l_count 		NUMBER := 0;
l_flag		NUMBER := 0;

cursor deployments is
select survey_deployment_id,
	  list_header_id
from ies_svy_deplyments_v
where survey_cycle_id = p_cycle_id;

begin

		Check_Question_Type(p_error_msg => l_error_msg,
						p_retcode => l_retcode,
						p_cycle_id => p_cycle_id);

		if (l_retcode = -1) then
			fnd_file.put_line(fnd_file.log, l_error_msg);
			ERRBUF := l_error_msg;
			RETCODE := l_retcode;
			return;
		end if;


		Update_Question_Frequency(p_error_msg => l_error_msg,
							 p_retcode => l_retcode,
							 p_cycle_id => p_cycle_id);
		if (l_retcode = -1) then
			fnd_file.put_line(fnd_file.log, l_error_msg);
			ERRBUF := l_error_msg;
			RETCODE := l_retcode;
			return;
		end if;


		for dep_rec in deployments
		loop
			if (dep_rec.list_header_id is null) then
				Compute_Summary_Non_List(dep_rec.survey_deployment_id);
			else
			     l_flag := 1;
				Compute_Summary(dep_rec.survey_deployment_id);
			end if;
		end loop;

		if (l_flag = 1) then
			Update_List_Entry_Summ(p_error_msg => l_error_msg,
				p_retcode => l_retcode,
				p_cycle_id => p_cycle_id);
		end if;



		if (l_retcode = -1) then
					fnd_file.put_line(fnd_file.log, l_error_msg);
					ERRBUF := l_error_msg;
					RETCODE := l_retcode;
					return;
		end if;

EXCEPTION
	WHEN OTHERS THEN
		ERRBUF := l_error_msg;
		RETCODE := l_retcode;

END Summarize_Survey_Data;

/*==========================================================================+
 | PROCEDURES.                                                              |
 | Update_Question_Frequency.                                               |
 | Updates the Summary data for List Based Surveys					 |
 +==========================================================================*/

Procedure Update_Question_Frequency
(
    p_error_msg OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_retcode 	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
    p_cycle_id      IN  NUMBER
) IS

  l_error_msg         	   	VARCHAR2(2000);
  l_ret_code                	NUMBER              := 0;

    CURSOR anscountfree_cur IS
    		SELECT
			issv.survey_id,
			isdv.survey_deployment_id,
			ids.dscript_id,
			iq.panel_id,
			iqd.question_id,
			iqd.lookup_id,
			0 answer_id,
			count(decode(question_type, 'Checkbox', (decode(freeform_string, '1', 1, '0', 0)), 1)) answer_count
		FROM
			ies_svy_resp_entries_v isre,
			ies_svy_deplyments_v isdv,
			ies_svy_cycles_v iscv,
			ies_svy_surveys_v issv,
			ies_deployed_scripts ids,
			ies_question_data iqd,
			ies_questions iq,
			ies_question_types iqt,
			ies_panels ip
		WHERE iscv.survey_cycle_id = P_CYCLE_ID
		AND	isre.survey_deployment_id = isdv.survey_deployment_id
		AND 	isdv.survey_cycle_id = iscv.survey_cycle_id
		AND 	iscv.survey_id = issv.survey_id
		AND 	issv.dscript_id = ids.dscript_id
		AND  ids.active_status = 1
		AND 	iqd.transaction_id = isre.transaction_id
		AND 	iqd.question_id = iq.question_id
		AND  iq.active_status = 1
		AND  iq.question_type_id = iqt.question_type_id
		AND  iqt.question_type in ('Checkbox', 'Text Entry', 'Text Area')
		AND 	iq.panel_id = ip.panel_id
		AND  ip.active_status = 1
		AND 	iqd.answer_id is null
		GROUP BY
			issv.survey_id,
			isdv.survey_deployment_id,
			ids.dscript_id,
			iq.panel_id,
			iqd.question_id,
			iqd.lookup_id,
			answer_id;

    CURSOR anscount_cur IS
	    	select
			issv.survey_id,
			isdv.survey_deployment_id,
			ids.dscript_id,
			iq.panel_id,
			iqd.question_id,
			iqd.lookup_id,
			ia.answer_id,
			count(decode(question_type, 'Checkbox', (decode(freeform_string, '1', 1, '0', 0)), 1)) answer_count
		from
			ies_svy_resp_entries_v isre,
			ies_svy_deplyments_v isdv,
			ies_svy_cycles_v iscv,
			ies_svy_surveys_v issv,
			ies_deployed_scripts ids,
			ies_question_data iqd,
			ies_questions iq,
			ies_question_types iqt,
			ies_panels ip,
			ies_answers ia
		where   iscv.survey_cycle_id = P_CYCLE_ID
		and	isre.survey_deployment_id = isdv.survey_deployment_id
		and 	isdv.survey_cycle_id = iscv.survey_cycle_id
		and 	iscv.survey_id = issv.survey_id
		and 	issv.dscript_id = ids.dscript_id
		and  ids.active_status = 1
		and 	iqd.transaction_id = isre.transaction_id
		and 	iqd.question_id = iq.question_id
		and  iq.active_status = 1
		and  iq.question_type_id = iqt.question_type_id
		AND  iqt.question_type in ('Checkbox Group', 'Radio Button', 'Dropdown', 'Multiselect List')
		and 	iq.panel_id = ip.panel_id
		and  ip.active_status = 1
		and 	iqd.answer_id = ia.answer_id
		and 	iqd.answer_id is not null
		GROUP BY
			issv.survey_id,
			isdv.survey_deployment_id,
			ids.dscript_id,
			iq.panel_id,
			iqd.question_id,
			iqd.lookup_id,
			ia.answer_id;
BEGIN
	SAVEPOINT Create_Summary;

	FOR anscountfree_rec IN anscountfree_cur LOOP
		UPDATE ies_svy_ques_data_v
	   		SET ANSWER_COUNT = anscountfree_rec.answer_count
	   	where 	survey_id = anscountfree_rec.survey_id
	   	and 	survey_deployment_id = anscountfree_rec.survey_deployment_id
	   	and	dscript_id = anscountfree_rec.dscript_id
		and	panel_id = anscountfree_rec.panel_id
		and	question_id = anscountfree_rec.question_id
		and 	answer_id = anscountfree_rec.answer_id
		and	lookup_id = anscountfree_rec.lookup_id;
	END LOOP;

	FOR anscount_rec IN anscount_cur LOOP
		UPDATE ies_svy_ques_data_v
	   		SET ANSWER_COUNT = anscount_rec.answer_count
	   	where 	survey_id = anscount_rec.survey_id
	   	and 	survey_deployment_id = anscount_rec.survey_deployment_id
	   	and	dscript_id = anscount_rec.dscript_id
		and	panel_id = anscount_rec.panel_id
		and	question_id = anscount_rec.question_id
		and	lookup_id = anscount_rec.lookup_id
		and	answer_id = anscount_rec.answer_id;
	END LOOP;
EXCEPTION
		WHEN OTHERS  THEN
			FND_MESSAGE.SET_NAME('IES', 'IES_SVY_UPDATE_DEPLOY_STATUS');
		        l_error_msg := FND_MESSAGE.GET;
			   fnd_file.put_line(fnd_file.log, l_error_msg);
			p_error_msg := l_error_msg;
			p_retcode := -1;
			ROLLBACK TO Create_Summary;
END Update_Question_Frequency;


Procedure Check_Question_Type
(
    p_error_msg OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_retcode 	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
    p_cycle_id      IN  NUMBER
) IS

  l_error_msg         	   	VARCHAR2(2000);
  l_ret_code                	NUMBER              := 0;
  l_ques_type_count			NUMBER 			:= 0;

BEGIN

SELECT count(question_id)
INTO   l_ques_type_count
FROM   IES_SVY_SURVEYS_V a,
	  IES_SVY_CYCLES_V b,
	  IES_DEPLOYED_SCRIPTS c,
	  IES_PANELS d,
	  IES_QUESTIONS e
WHERE  b.survey_cycle_id = p_cycle_id
AND    a.survey_id = b.survey_id
AND    a.dscript_id = c.dscript_id
AND    c.active_status = 1
AND    c.dscript_id = d.dscript_id
AND    d.active_status = 1
AND    d.panel_id = e.panel_id
AND    e.question_type_id is not null
AND    e.active_status = 1;

IF (l_ques_type_count = 0) THEN
	FND_MESSAGE.SET_NAME('IES', 'IES_SVY_QUESTION_TYPE_ERROR');
	l_error_msg := FND_MESSAGE.GET;
	fnd_file.put_line(fnd_file.log, l_error_msg);
	p_error_msg := l_error_msg;
	p_retcode := -1;
ELSE
	p_retcode := 0;
END IF;

END Check_Question_Type;



/*==========================================================================+
 | PROCEDURES.                                                              |
 | Update_List_Entry_Summ.                                                  |
 | Updates the Summary data for List Based Surveys					 |
 +==========================================================================*/

PROCEDURE  UPDATE_LIST_ENTRY_SUMM
(
    p_error_msg		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_retcode			 OUT NOCOPY /* file.sql.39 change */ NUMBER,
    p_cycle_id      	 IN  NUMBER
) IS

  l_error_msg         	   	VARCHAR2(2000);
  l_ret_code                	NUMBER              := 0;
  l_exist_flag 			NUMBER 			:= 0;

  CURSOR replist_cur IS
		SELECT
		      issv.survey_id,
		      issv.survey_name,
		      isdv.survey_cycle_id,
		      iscv.survey_cycle_name,
		      isrv.survey_deployment_id,
		      isdv.deployment_name,
		      trunc(isrv.response_collected_date) response_collected_date,
			 iale.list_header_id,
			 ialh.list_name,
		      count(distinct isrv.survey_list_entry_id) no_of_responses
		  FROM
		      ies_svy_resp_entries_v isrv,
		      ies_svy_list_entries_v islev,
		      ies_svy_cycles_v iscv,
		      ies_svy_deplyments_v isdv,
		      ies_svy_surveys_v  issv,
			 ies_ams_list_entries_v iale,
			 ies_ams_list_headers_v ialh
		  WHERE iscv.survey_cycle_id = P_CYCLE_ID
		  AND isrv.survey_list_entry_id = islev.survey_list_entry_id
		  AND isrv.survey_deployment_id = isdv.survey_deployment_id
		  AND isdv.survey_cycle_id = iscv.survey_cycle_id
		  AND iscv.survey_id = issv.survey_id
		  AND islev.list_entry_id = iale.list_entry_id
		  AND iale.list_header_id = ialh.list_header_id
		  GROUP BY
		      iale.list_header_id,
		      ialh.list_name,
		      trunc(isrv.response_collected_date),
		      isdv.deployment_name,
		      isrv.survey_deployment_id,
		      iscv.survey_cycle_name,
		      isdv.survey_cycle_id,
		      issv.survey_name,
		      issv.survey_id;
BEGIN

-- The purpose of this procedure is to create a record to list the no_sent and target_response
-- percent in the summary table with a null response date for each list that is used in a
-- deployment in a survey.


	SAVEPOINT List_Response;


	FOR replist_rec IN replist_cur LOOP
		begin
			select 1
			INTO  l_exist_flag
			FROM  ies_svy_list_summary_v
			WHERE list_header_id = replist_rec.list_header_id
			and	survey_deployment_id  = replist_rec.survey_deployment_id
			and  response_date = replist_rec.response_collected_date
			and	survey_cycle_id  = replist_rec.survey_cycle_id
			and	survey_id  = replist_rec.survey_id;
		exception
			WHEN NO_DATA_FOUND THEN
				l_exist_flag := 0;
		end;

		if l_exist_flag = 0 then
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
				values
				(replist_rec.survey_id,
				replist_rec.survey_name,
				replist_rec.survey_cycle_id,
				replist_rec.survey_cycle_name,
				replist_rec.survey_deployment_id,
				replist_rec.deployment_name,
				0,
				replist_rec.list_header_id,
				replist_rec.list_name,
				replist_rec.response_collected_date,
				0,
				replist_rec.no_of_responses,
				0);
		else
				update ies_svy_list_summary_v
				set no_responses = replist_rec.no_of_responses
				WHERE
					list_header_id = replist_rec.list_header_id
					and	survey_deployment_id  = replist_rec.survey_deployment_id
					and  response_date = replist_rec.response_collected_date
					and	survey_cycle_id  = replist_rec.survey_cycle_id
					and	survey_id  = replist_rec.survey_id;
				l_exist_flag := 0;
		end if;
	END LOOP;
EXCEPTION
		WHEN OTHERS  THEN
			FND_MESSAGE.SET_NAME('IES', 'IES_SVY_UPDATE_DEPLOY_STATUS');
		     l_error_msg := FND_MESSAGE.GET;
			fnd_file.put_line(fnd_file.log, l_error_msg);
			p_error_msg := l_error_msg;
			p_retcode := -1;
			ROLLBACK TO List_Response;
END UPDATE_LIST_ENTRY_SUMM;

END IES_SURVEY_SUMMARY;

/
