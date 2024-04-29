--------------------------------------------------------
--  DDL for Package Body IES_SVY_DPYLMENT_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_SVY_DPYLMENT_STATUS_PVT" AS
/* $Header: iesdpstb.pls 120.1 2005/06/16 11:14:29 appldev  $ */
----------------------------------------------------------------------------------------------------------
-- Procedure
--   Submit_Deployment

-- PURPOSE
--   Submit Deployment to Concurrent Manager at the specified_time.
--
-- PARAMETERS

-- NOTES
-- created rrsundar 05/03/2000
---------------------------------------------------------------------------------------------------------
Procedure  Update_Deployment_Status
(
    ERRBUF				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    RETCODE 				 OUT NOCOPY /* file.sql.39 change */ BINARY_INTEGER
) IS
  l_error_msg         	   VARCHAR2(2000);
  l_ret_code                NUMBER              := NULL ;
  l_dep_count                NUMBER              := 0;
  l_cycle_count                NUMBER              := 0;
  l_err_buf                 VARCHAR2(80)        := NULL ;

  CURSOR dep_c IS
  SELECT survey_deployment_id, isdv.survey_cycle_id , survey_id
  FROM ies_svy_deplyments_v isdv, ies_svy_cycles_v iscv
  WHERE response_end_date < sysdate
  and deployment_status_code = 'ACTIVE'
  and isdv.survey_cycle_id = iscv.survey_cycle_id
  FOR UPDATE of deployment_status_code;

begin
	SAVEPOINT update_deployment_status;

	for c1_rec in dep_c loop
		update ies_svy_deplyments_v
		set deployment_status_code = 'CLOSED'
		where survey_deployment_id = c1_rec.survey_deployment_id;

		SELECT count(*)
		INTO   l_dep_count
		FROM   ies_svy_deplyments_v
		WHERE  survey_cycle_id = c1_rec.survey_cycle_id
		AND    deployment_status_code = 'ACTIVE';

	     if (l_dep_count = 0)  then
			UPDATE ies_svy_cycles_v
			SET cycle_status_code = 'OPEN'
			WHERE survey_cycle_id = c1_rec.survey_cycle_id;
		end if;

		select count(*)
		INTO l_cycle_count
		FROM ies_svy_cycles_v
		WHERE survey_id = c1_rec.survey_id
		AND cycle_status_code = 'ACTIVE';

		if (l_cycle_count = 0) then
			UPDATE ies_svy_surveys_v
			SET survey_status_code = 'OPEN'
			WHERE survey_id = c1_rec.survey_id;
		end if;

	end loop;

exception
		when others  then
			FND_MESSAGE.SET_NAME('IES', 'IES_SVY_UPDATE_DEPLOY_STATUS');
		     l_error_msg := FND_MESSAGE.GET;
			fnd_file.put_line(fnd_file.log, l_error_msg);
			ERRBUF := l_error_msg;
			RETCODE := -1;
			rollback to update_deployment_status;
end Update_Deployment_Status;
end IES_SVY_DPYLMENT_STATUS_PVT;

/
