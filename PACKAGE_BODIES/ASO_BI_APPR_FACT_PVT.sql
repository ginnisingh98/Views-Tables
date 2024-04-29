--------------------------------------------------------
--  DDL for Package Body ASO_BI_APPR_FACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_APPR_FACT_PVT" AS
 /* $Header: asovbiapb.pls 120.3 2006/08/10 05:56:02 vselvapr noship $ */

 --procedure for the initial load of approval facts
 Procedure Appr_Init_Load
 As
 l_user_id number;
 l_login_id number;
 Begin

 BIS_COLLECTION_UTILITIES.Debug('Start populating the Approvals fact Table');

 l_user_id := FND_GLOBAL.user_id;
 l_login_id := FND_GLOBAL.login_id;
 --insert statement

	INSERT /*+ APPEND PARALLEL(FACT) */ INTO ASO_BI_APR_F FACT
	(
		QUOTE_NUMBER,
		QUOTE_VERSION,
		QUOTE_HEADER_ID,
		RESOURCE_ID,
		RESOURCE_GRP_ID,
		OBJECT_APPROVAL_ID,
		APPROVAL_INSTANCE_ID,
		APPROVAL_STATUS,
		NUM_APPROVERS,
		APR_START_DATE,
		APR_END_DATE,
		QA_END_DATE,
		QUOTE_CREATION_DATE,
		QUOTE_LAST_UPDATE_DATE,
		QUOTE_EXPIRATION_DATE,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    LAST_UPDATE_LOGIN
	)
  SELECT /*+ PARALLEL(QOT) PARALLEL(APR) PARALLEL(APRD) */
		QOT.Quote_Number,
		QOT.Quote_Version,
		QOT.Quote_header_id,
		QOT.Resource_id,
		QOT.Resource_grp_id,
		APR.Object_approval_id,
		APR.Approval_instance_id,
		APR.Approval_status,
		COUNT(*) NUM_APPROVERS,
		TRUNC(APR.Start_date)  Apr_start_date ,
		TRUNC(APR.End_date)  Apr_end_date ,
		TRUNC(APR.end_date)  QA_end_date,
		QOT.Quote_creation_date,
		QOT.Quote_last_update_date,
		QOT.Quote_expiration_date,
		SYSDATE,
		l_user_id,
		SYSDATE,
    l_user_id,
		l_login_id
		FROM  ASO_BI_QUOTE_HDRS_ALL QOT,
			ASO_APR_OBJ_APPROVALS APR,
			ASO_APR_APPROVAL_DETAILS APRD
		WHERE
			QOT.quote_header_id = APR.object_id
			AND APR.object_type = 'Quote'
			AND APRD.object_approval_id = APR.object_approval_id
               AND QOT.recurring_charge_flag = 'N'
               AND APR.approval_instance_id = (select max(approval_instance_id)
		                                     from ASO_APR_OBJ_APPROVALS A
                                               where A.Object_id = QOT.Quote_header_id)
		GROUP BY
			QOT.Quote_Number, QOT.Quote_Version,
			QOT.Quote_creation_date,QOT.Quote_last_update_date,
			QOT.Quote_header_id,
			QOT.Resource_id,QOT.Resource_grp_id,
			QOT.Quote_expiration_date,
			APR.Object_approval_id,APR.Approval_instance_id,APR.Approval_status,
			TRUNC(APR.Start_date),APR.End_date,TRUNC(NVL(APR.end_date, QOT.Quote_expiration_date));

  BIS_COLLECTION_UTILITIES.Debug('Done populating the Approvals fact Table:'||'Rowcount:'|| SQL%ROWCOUNT);

  COMMIT;

	end Appr_Init_Load;


--Procedure for the incremental load of approval facts
 Procedure Appr_Incremental_Load
 As
 l_user_id number;
 l_login_id number;
 Begin

 BIS_COLLECTION_UTILITIES.Debug('Start populating the Approvals fact Table');

 l_user_id := FND_GLOBAL.user_id;
 l_login_id := FND_GLOBAL.login_id;

  --Delete the modified approvals
  DELETE FROM ASO_BI_APR_F FACT
  WHERE FACT.Quote_header_id IN (SELECT Quote_header_id FROM  ASO_BI_QUOTE_IDS);

  --insert statement
	INSERT INTO ASO_BI_APR_F
	(
		QUOTE_NUMBER,
		QUOTE_VERSION,
		QUOTE_HEADER_ID,
		RESOURCE_ID,
		RESOURCE_GRP_ID,
		OBJECT_APPROVAL_ID,
		APPROVAL_INSTANCE_ID,
		APPROVAL_STATUS,
		NUM_APPROVERS,
		APR_START_DATE,
		APR_END_DATE,
		QA_END_DATE,
		QUOTE_CREATION_DATE,
		QUOTE_LAST_UPDATE_DATE,
		QUOTE_EXPIRATION_DATE,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    LAST_UPDATE_LOGIN
	)
	SELECT
		QOT.Quote_Number,
		QOT.Quote_Version,
		QOT.Quote_header_id,
		QOT.Resource_id,
		QOT.Resource_grp_id,
		APR.Object_approval_id,
		APR.Approval_instance_id,
		APR.Approval_status,
		COUNT(*) NUM_APPROVERS,
		TRUNC(APR.Start_date)  Apr_start_date ,
		TRUNC(APR.End_date)  Apr_end_date ,
		TRUNC(APR.end_date)  QA_end_date,
		QOT.Quote_creation_date,
		QOT.Quote_last_update_date,
		QOT.Quote_expiration_date,
		SYSDATE,
		l_user_id,
		SYSDATE,
    l_user_id,
		l_login_id
		FROM  ASO_BI_QUOTE_HDRS_ALL QOT,
			ASO_APR_OBJ_APPROVALS APR,
			ASO_APR_APPROVAL_DETAILS APRD,
                  ASO_BI_QUOTE_IDS QID
		WHERE
			     QOT.quote_header_id = APR.object_id
			AND  APR.object_type = 'Quote'
			AND  QID.quote_header_id = APR.object_id
			AND  APRD.object_approval_id = APR.object_approval_id
                  AND  QOT.recurring_charge_flag = 'N'
               AND APR.approval_instance_id = (select max(approval_instance_id)
		                                     from ASO_APR_OBJ_APPROVALS A
                                               where A.Object_id = QOT.Quote_header_id)
		GROUP BY
			QOT.Quote_Number, QOT.Quote_Version,
			QOT.Quote_creation_date,QOT.Quote_last_update_date,
			QOT.Quote_header_id,
			QOT.Resource_id,QOT.Resource_grp_id,
			QOT.Quote_expiration_date,
			APR.Object_approval_id,APR.Approval_instance_id,APR.Approval_status,
			TRUNC(APR.Start_date),APR.End_date,TRUNC(NVL(APR.end_date, QOT.Quote_expiration_date));

   -- Added to fix bug 5413781
   --Delete the duplicate version of all quotes in ASO_BI_APR_F, retaining the latest version.
    	     delete from ASO_BI_APR_F a
		where a.quote_version < (select MAX(quote_version)
	                     		from ASO_BI_APR_F b
						  	where a.quote_number = b.quote_number);

  BIS_COLLECTION_UTILITIES.Debug('Done populating the Approvals fact Table:'||'Rowcount:'|| SQL%ROWCOUNT);

  COMMIT;


	end Appr_Incremental_Load;




 --for the initial load of aproval rules fact
 Procedure Rul_Init_load
 As
 l_user_id number;
 l_login_id number;
 Begin

 BIS_COLLECTION_UTILITIES.Debug('Start populating the Rules fact Table');

 l_user_id := FND_GLOBAL.user_id;
 l_login_id := FND_GLOBAL.login_id;

 --insert statement
	INSERT /*+ APPEND PARALLEL(FACT) */ INTO ASO_BI_APR_RUL_F FACT
	(
		QUOTE_NUMBER,
		QUOTE_VERSION,
		QUOTE_HEADER_ID,
		OBJECT_APPROVAL_ID,
		RESOURCE_ID,
		RESOURCE_GRP_ID,
		APPROVAL_STATUS,
		OAM_RULE_ID,
		QUOTE_CREATION_DATE,
		QUOTE_LAST_UPDATE_DATE,
		QUOTE_EXPIRATION_DATE,
		APR_START_DATE,
		APR_END_DATE,
		QA_END_DATE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
	)
	SELECT /*+ PARALLEL(APRF) PARALLEL(RUL) */
		APRF.Quote_Number,
		APRF.Quote_Version,
		APRF.Quote_header_id,
		APRF.Object_approval_id,
		APRF.Resource_id,
		APRF.Resource_grp_id,
		APRF.Approval_status,
		RUL.oam_rule_id,
		APRF.Quote_creation_date,
		APRF.Quote_last_update_date,
		APRF.Quote_expiration_date ,
		APRF.Apr_start_date ,
		APRF.Apr_end_date  ,
		APRF.apr_end_date,
		SYSDATE,
		l_user_id,
		SYSDATE,
		l_user_id,
		l_login_id
		FROM
			ASO_BI_APR_F APRF,
			ASO_APR_RULES RUL
		WHERE
			APRF.object_approval_id = RUL.object_approval_id;


  BIS_COLLECTION_UTILITIES.Debug('Done populating the Rules fact Table:'||'Rowcount:'|| SQL%ROWCOUNT);

  COMMIT;


	end Rul_Init_load;


--for the incremental load of aproval rules fact
 Procedure Rul_Incremental_load
 As
 l_user_id number;
 l_login_id number;
 Begin

 BIS_COLLECTION_UTILITIES.Debug('Start populating the Rules fact Table');

 l_user_id := FND_GLOBAL.user_id;
 l_login_id := FND_GLOBAL.login_id;

  --Delete the modified approvals
  DELETE FROM ASO_BI_APR_RUL_F FACT
  WHERE FACT.Quote_header_id IN (SELECT Quote_header_id FROM  ASO_BI_QUOTE_IDS);

  --insert statement
	INSERT INTO ASO_BI_APR_RUL_F
	(
		QUOTE_NUMBER,
		QUOTE_VERSION,
		QUOTE_HEADER_ID,
		OBJECT_APPROVAL_ID,
		RESOURCE_ID,
		RESOURCE_GRP_ID,
		APPROVAL_STATUS,
		OAM_RULE_ID,
		QUOTE_CREATION_DATE,
		QUOTE_LAST_UPDATE_DATE,
		QUOTE_EXPIRATION_DATE,
		APR_START_DATE,
		APR_END_DATE,
		QA_END_DATE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
	)
	SELECT
		APRF.Quote_Number,
		APRF.Quote_Version,
		APRF.Quote_header_id,
		APRF.Object_approval_id,
		APRF.Resource_id,
		APRF.Resource_grp_id,
		APRF.Approval_status,
		RUL.oam_rule_id,
		APRF.Quote_creation_date,
		APRF.Quote_last_update_date,
		APRF.Quote_expiration_date ,
		APRF.Apr_start_date ,
		APRF.Apr_end_date  ,
		APRF.apr_end_date,
		SYSDATE,
		l_user_id,
		SYSDATE,
		l_user_id,
		l_login_id
		FROM
			ASO_BI_APR_F APRF,
			ASO_APR_RULES RUL,
      ASO_BI_QUOTE_IDS QID
		WHERE
			APRF.Object_approval_id = RUL.Object_approval_id
      AND QID.Quote_header_id = APRF.Quote_header_id;


  BIS_COLLECTION_UTILITIES.Debug('Done populating the Rules fact Table:'||'Rowcount:'|| SQL%ROWCOUNT);

  COMMIT;

	END Rul_Incremental_load;


END ASO_BI_APPR_FACT_PVT ;

/
