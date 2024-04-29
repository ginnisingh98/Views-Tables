--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_ECODATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_ECODATA" as
/* $Header: BOMDGCNB.pls 120.1 2007/12/26 09:46:11 vggarg noship $ */
PROCEDURE init is
BEGIN
null;
END init;

PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;

PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                        report OUT NOCOPY JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 num_rows   NUMBER;
 row_limit   NUMBER;
 l_item_id   NUMBER;
 l_org_id    NUMBER;
 l_eco_name  VARCHAR2(10);
 l_eco_exists  NUMBER;
 l_mco_exists  NUMBER;
 l_org_exists	NUMBER;
 l_ret_status      BOOLEAN;
 l_status          VARCHAR2 (1);
 l_industry        VARCHAR2 (1);
 l_oracle_schema   VARCHAR2 (30);

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

 /*Initializing local vars */
 row_limit :=1000; /* Set Row Limit to 1000 (i.e.) Max Number of records to be fetched by each sql*/
 l_org_exists :=0; /* Initialize to zero */

-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_eco_name := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ChangeNotice', inputs);

/* l_org_id is NOT a mandatory input. If it is not entered, then run the scripts for all orgs.
   However if a value is entered for org_id, then validate it for existence. */

If l_org_id is not null Then /* validate if input org_id exists*/
	Begin
		select 1 into l_org_exists
		from   mtl_parameters
		where  organization_id=l_org_id;
	Exception
	When others Then
		l_org_exists :=0;
		JTF_DIAGNOSTIC_COREAPI.errorprint('Invalid Organization Id');
		JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please either provide a valid value for the Organization Id or leave it blank. ');
		statusStr := 'FAILURE';
		isFatal := 'TRUE';
		fixInfo := ' Please review the error message below and take corrective action. ';
		errStr  := ' Invalid value for input field Organization Id ';

		report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
		reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	End;

	If l_org_exists=0 Then
		Return;
	End If;
End If; /* End of l_org_id is not null */

/* Input ECO/MCO name is mandatory.*/
If l_eco_name is NULL then
	JTF_DIAGNOSTIC_COREAPI.Errorprint('Input ECO Name is mandatory.');
	JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please provide a valid value for the ECO Name.');
	statusStr := 'FAILURE';
	isFatal	  := 'TRUE';
	fixInfo   := ' Please review the error message below and take corrective action. ';
	errStr    :=' Invalid value for input field ECO Name. It is a mandatory input. ';

	report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	Return;

Else /*Validate if the input eco/mco name exists */
	l_eco_exists := 0;
	l_mco_exists := 0;

	/* Verify if the input corresponds to an existing Eco */
	Begin
		Select 1 into l_eco_exists
		from dual
		where exists (select 1
		from eng_engineering_changes
		where change_notice=l_eco_name
		and   organization_id=nvl(l_org_id,organization_id));
	Exception
		When no_data_found then
			l_eco_exists :=0;
		When others then
			null;
	End;

	/* Verify if the input corresponds to an existing MCO (Mass Change Order) */
	Begin
		Select 1 into l_mco_exists
		from  dual
		where exists (select 1
		from  eng_eng_changes_interface
		where change_notice=l_eco_name
		and   organization_id=nvl(l_org_id,organization_id));
	Exception
		When no_data_found then
			l_mco_exists :=0;
		When others then
			null;
	End;


	If (l_eco_exists = 0) and (l_mco_exists = 0) Then /* no eco or mco exists */
		JTF_DIAGNOSTIC_COREAPI.errorprint('Invalid combination of ECO Name and Organization.');
		JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please provide valid values for the ECO Name and Organization Id. ');
		statusStr := 'FAILURE';
		isFatal	  := 'TRUE';
		fixInfo   := ' Please review the error message below and take corrective action. ';
		errStr    := ' Invalid values for input fields ECO Name and/or Organization Id. ';

		report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
		reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
		Return;

	Elsif l_eco_exists =1 Then /* run the scripts if the ECO is exists */

	/* Get the application installation info. References to Data Dictionary Objects without schema name
	included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
	as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

	l_ret_status :=      fnd_installation.get_app_info ('ENG'
		                           , l_status
			                   , l_industry
				           , l_oracle_schema
					    );
	/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

	/* SQL to fetch ECO Header Details */
	sqltxt := 'SELECT ' ||
	'	      EEC.CHANGE_NOTICE		 	 "CHANGE NOTICE"	 				      '||
	'	     ,MP1.ORGANIZATION_CODE 	 	 "ORGANIZATION CODE"		 			      '||
	'	     ,EEC.ORGANIZATION_ID		 "ORGANIZATION ID"					      '||
	'	     ,EEC.DESCRIPTION			 "DESCRIPTION"			 	 		      '||
	'	     ,to_char(EEC.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE"		      '||
	'	     ,EEC.LAST_UPDATED_BY		 "LAST UPDATED BY"		 			      '||
	'	     ,to_char(EEC.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE"		 	      '||
	'	     ,EEC.CREATED_BY			 "CREATED BY"			 			      '||
	'	     ,EEC.LAST_UPDATE_LOGIN		 "LAST UPDATE LOGIN"		 			      '||
	'	     ,ECSVL.STATUS_NAME			 "STATUS"						      '||
	'	     ,EEC.STATUS_TYPE			 "STATUS TYPE"						      '||
	'	     ,to_char(EEC.INITIATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "INITIATION DATE"		      '||
	'	     ,to_char(EEC.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE"		      '||
	'	     ,to_char(EEC.CANCELLATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "CANCELLATION DATE"		      '||
	'	     ,EEC.CANCELLATION_COMMENTS	 "CANCELLATION COMMENTS"					      '||
	'	     ,ECOT.CHANGE_ORDER_TYPE		 "CHANGE ORDER TYPE"					      '||
	'	     ,EEC.CHANGE_ORDER_TYPE_ID		 "CHANGE ORDER TYPE ID"					      '||
	'	     ,EEC.REASON_CODE			 "REASON CODE"						      '||
	'	     ,ECR.DESCRIPTION			 "Reason Code Description"				      '||
	'	     ,EEC.PRIORITY_CODE		 	 "PRIORITY CODE"					      '||
	'	     ,ECP.DESCRIPTION 	 		 "Priority Code Description"		 		      '||
	'	     ,EEC.ESTIMATED_ENG_COST	 	"ESTIMATED ENG COST"		 			      '||
	'	     ,EEC.ESTIMATED_MFG_COST	 	"ESTIMATED MFG COST"		 			      '||
	'	     ,EEC.REQUESTOR_ID			 "REQUESTOR ID"		 				      '||
	'	     ,EEC.ATTRIBUTE_CATEGORY	 	"ATTRIBUTE CATEGORY"		 			      '||
	'	     ,EEC.ATTRIBUTE1			 "ATTRIBUTE1"			 			      '||
	'	     ,EEC.ATTRIBUTE2			 "ATTRIBUTE2"			 			      '||
	'	     ,EEC.ATTRIBUTE3			 "ATTRIBUTE3"			 			      '||
	'	     ,EEC.ATTRIBUTE4			 "ATTRIBUTE4"			 			      '||
	'	     ,EEC.ATTRIBUTE5			 "ATTRIBUTE5"			 			      '||
	'	     ,EEC.ATTRIBUTE6			 "ATTRIBUTE6"			 			      '||
	'	     ,EEC.ATTRIBUTE7			 "ATTRIBUTE7"			 			      '||
	'	     ,EEC.ATTRIBUTE8			 "ATTRIBUTE8"			 			      '||
	'	     ,EEC.ATTRIBUTE9			 "ATTRIBUTE9"			 			      '||
	'	     ,EEC.ATTRIBUTE10			 "ATTRIBUTE10"			 			      '||
	'	     ,EEC.ATTRIBUTE11			 "ATTRIBUTE11"			 			      '||
	'	     ,EEC.ATTRIBUTE12			 "ATTRIBUTE12"			 			      '||
	'	     ,EEC.ATTRIBUTE13			 "ATTRIBUTE13"			 			      '||
	'	     ,EEC.ATTRIBUTE14			 "ATTRIBUTE14"			 			      '||
	'	     ,EEC.ATTRIBUTE15			 "ATTRIBUTE15"			 			      '||
	'	     ,EEC.REQUEST_ID			 "REQUEST ID"			 			      '||
	'	     ,EEC.PROGRAM_APPLICATION_ID "PROGRAM APPLICATION ID"	 				      '||
	'	     ,EEC.PROGRAM_ID			 "PROGRAM ID"			 			      '||
	'	     ,to_char(EEC.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"			'||
	'	     ,DECODE(MLU_AST.MEANING,null,null,								      '||
	'		(MLU_AST.MEANING || '' ('' || EEC.APPROVAL_STATUS_TYPE || '')'')) "APPROVAL STATUS"	      '||
	'	     ,to_char(EEC.APPROVAL_DATE,''DD-MON-YYYY HH24:MI:SS'') "APPROVAL DATE"				'||
	'	     ,EEAL.APPROVAL_LIST_NAME		 "APPROVAL LIST NAME"						'||
	'	     ,EEC.APPROVAL_LIST_ID		 "APPROVAL LIST ID"						'||
	'	     ,EEAL.DESCRIPTION  		 "APPROVAL LIST DESCRIPTION"				      '||
	'	     ,to_char(EEC.APPROVAL_REQUEST_DATE,''DD-MON-YYYY HH24:MI:SS'') "APPROVAL REQUEST DATE"		'||
	'	     ,EEC.RESPONSIBLE_ORGANIZATION_ID	 "RESPONSIBLE ORGANIZATION ID"				      '||
	'	     ,HOU.NAME 				 "ECO DEPARTMENT"					      '||
	'	     ,EEC.DDF_CONTEXT			 "DDF CONTEXT"						      '||
	'	     ,PPA.PROJECT_NAME 			 "PROJECT NAME"						      '||
	'	     ,PPA.PROJECT_NUMBER 		 "PROJECT NUMBER"		 			      '||
	'	     ,EEC.PROJECT_ID			 "PROJECT ID"						      '||
	'	     ,PT.TASK_NAME			 "TASK NAME"						      '||
	'	     ,PT.TASK_NUMBER			 "TASK NUMBER"						      '||
	'	     ,EEC.TASK_ID	 		 "TASK ID"						      '||
	'	     ,EEC.ORIGINAL_SYSTEM_REFERENCE	 "ORIGINAL SYSTEM REFERENCE"			 	      '||
	'	     ,EEC.HIERARCHY_FLAG	 	 "HIERARCHY FLAG"		 			      '||
	'	     ,EEC.ORGANIZATION_HIERARCHY 	 "ORGANIZATION HIERARCHY"	 			      '||
	'	     ,EEC.HIERARCHY_ID			 "HIERARCHY ID"		 				      '||
	'	     ,EEC.CHANGE_MGMT_TYPE_CODE	 	 "CHANGE MGMT TYPE CODE"	 			      '||
	'	     ,EEC.ASSIGNEE_ID			 "ASSIGNEE ID"			 			      '||
	'	     ,to_char(EEC.NEED_BY_DATE,''DD-MON-YYYY HH24:MI:SS'') "NEED BY DATE"		 		'||
	'	     ,EEC.INTERNAL_USE_ONLY		 "INTERNAL USE ONLY"		 			      '||
	'	     ,EEC.SOURCE_TYPE_CODE		 "SOURCE TYPE CODE"		 			      '||
	'	     ,EEC.SOURCE_ID		 	 "SOURCE ID"			 			      '||
	'	     ,EEC.SOURCE_NAME		 	 "SOURCE NAME"			 			      '||
	'	     ,EEC.EFFORT		 	 "EFFORT"			 			      '||
	'	     ,EEC.CHANGE_NAME			 "CHANGE NAME"			 			      '||
	'	     ,EEC.CHANGE_ID		 	 "CHANGE ID"			 			      '||
	'	     ,EEC.ROUTE_ID		 	 "ROUTE ID"						      '||
	'	     ,EEC.CHANGE_NOTICE_PREFIX		"CHANGE NOTICE PREFIX"	 				      '||
	'	     ,EEC.CHANGE_NOTICE_NUMBER		"CHANGE NOTICE NUMBER"	 				      '||
	'	     ,EEC.OLD_REQUESTOR_ID		 "OLD REQUESTOR ID"		 			      '||
	'	     ,EEC.STATUS_CODE			 "STATUS CODE"			 			      '||
	'	     ,EEC.RESOLUTION			 "RESOLUTION"			 			      '||
	'	     ,EEC.CLASSIFICATION_ID		 "CLASSIFICATION ID"		 			      '||
	'	     ,EEC.PLM_OR_ERP_CHANGE		 "PLM OR ERP CHANGE"		 			      '||
	'	     ,to_char(EEC.EXPIRATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "EXPIRATION DATE"		 		'||
	'	     ,EEC.PROMOTE_STATUS_CODE		"PROMOTE STATUS CODE" 		 			      '||
	'	     ,EEC.IMPLEMENTATION_REQ_ID		"IMPLEMENTATION REQ ID" 		 			      '||
	'	 FROM      eng_engineering_changes eec								      '||
	'		 , eng_change_order_types_v ecot					 		      '||
	'		 , MTL_PARAMETERS MP1									      '||
	'		 , ENG_CHANGE_REASONS ECR								      '||
	'		 , ENG_CHANGE_PRIORITIES ECP								      '||
	'		 , ENG_ECN_APPROVAL_LISTS EEAL								      '||
	'		 , ENG_CHANGE_STATUSES_VL ECSVL								      '||
	'		 , PJM_PROJECTS_V PPA									      '||
	'		 , PA_TASKS PT										      '||
	'		 , HR_ORGANIZATION_UNITS HOU								      '||
	'		 , MFG_LOOKUPS MLU_AST						 			      '||
	'	WHERE 1=1			     					 			      '||
	'	AND   EEC.ORGANIZATION_ID = MP1.ORGANIZATION_ID							      '||
	'	AND	  EEC.CHANGE_ORDER_TYPE_ID = ECOT.CHANGE_ORDER_TYPE_ID					      '||
	'	AND   EEC.STATUS_TYPE = ECSVL.STATUS_CODE(+) 							      '||
	'	AND   EEC.REASON_CODE = ECR.ENG_CHANGE_REASON_CODE(+) 						      '||
	'	AND   ECR.ORGANIZATION_ID(+) = -1 								      '||
	'	AND   EEC.PRIORITY_CODE = ECP.ENG_CHANGE_PRIORITY_CODE(+) 					      '||
	'	AND   ECP.ORGANIZATION_ID(+) = -1								      '||
	'	AND   EEC.APPROVAL_LIST_ID = EEAL.APPROVAL_LIST_ID(+) 						      '||
	'	AND   EEC.APPROVAL_STATUS_TYPE = MLU_AST.LOOKUP_CODE(+) 					      '||
	'	AND   MLU_AST.LOOKUP_TYPE = ''ENG_ECN_APPROVAL_STATUS'' 					      '||
	'	AND   ECOT.CHANGE_MGMT_TYPE_CODE =EEC.CHANGE_MGMT_TYPE_CODE 					      '||
	'	AND   EEC.CHANGE_MGMT_TYPE_CODE=''CHANGE_ORDER'' 	     					      '||
	'	AND   EEC.PROJECT_ID = PPA.PROJECT_ID(+) 							      '||
	'	AND   EEC.PROJECT_ID = PT.PROJECT_ID(+) 							      '||
	'	AND   EEC.TASK_ID = PT.TASK_ID(+)								      '||
	'	AND   EEC.RESPONSIBLE_ORGANIZATION_ID = HOU.ORGANIZATION_ID(+)   				      '||
	'	and  eec.change_notice =		   '''||l_eco_name||'''						';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and eec.organization_id =  '||l_org_id;
	end if;
	sqltxt :=sqltxt||' and rownum <   '||row_limit;
   	sqltxt :=sqltxt||' order by mp1.organization_code	';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Eco Headers ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

	/* End of ECO header details*/

	/* SQL to fetch Eco Revised Items Details */
	sqltxt := 'SELECT ' ||
	'	       ERI.CHANGE_NOTICE		   "CHANGE NOTICE"				    '||
	'	      ,MP1.ORGANIZATION_CODE    	   "ORGANIZATION CODE"		    		    '||
	'	      ,ERI.ORGANIZATION_ID		   "ORGANIZATION ID"		    		    '||
	'	      ,MIF1.PADDED_ITEM_NUMBER	   	   "REVISED ITEM NUMBER"	       		    '||
	'	      ,ERI.REVISED_ITEM_ID		   "REVISED ITEM ID"				    '||
	'	      ,ERI.REVISED_ITEM_SEQUENCE_ID	   "REVISED ITEM SEQUENCE ID"	 		    '||
	'	      ,to_char(ERI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE"	'||
	'	      ,ERI.LAST_UPDATED_BY		   "LAST UPDATED BY"		    		    '||
	'	      ,to_char(ERI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "CREATION DATE"	'||
	'	      ,ERI.CREATED_BY			   "CREATED BY"		    			    '||
	'	      ,ERI.LAST_UPDATE_LOGIN		   "LAST UPDATE LOGIN"		    		    '||
	'	      ,to_char(ERI.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE"	'||
	'	      ,ERI.DESCRIPTIVE_TEXT		   "DESCRIPTIVE TEXT"		    		    '||
	'	      ,to_char(ERI.CANCELLATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CANCELLATION DATE"	    '||
	'	      ,ERI.CANCEL_COMMENTS		   "CANCEL COMMENTS"		    		    '||
	'	      ,ERI.DISPOSITION_TYPE		   "DISPOSITION TYPE"		    		    '||
	'	      ,ERI.NEW_ITEM_REVISION		   "NEW ITEM REVISION"		    		    '||
	'	      ,to_char(ERI.AUTO_IMPLEMENT_DATE,''DD-MON-YYYY HH24:MI:SS'') "AUTO IMPLEMENT DATE"	'||
	'	      ,to_char(ERI.EARLY_SCHEDULE_DATE,''DD-MON-YYYY HH24:MI:SS'') "EARLY SCHEDULE DATE"	'||
	'	      ,ERI.ATTRIBUTE_CATEGORY		   "ATTRIBUTE CATEGORY"	    			    '||
	'	      ,ERI.ATTRIBUTE1			   "ATTRIBUTE1"		    			    '||
	'	      ,ERI.ATTRIBUTE2			   "ATTRIBUTE2"		    			    '||
	'	      ,ERI.ATTRIBUTE3			   "ATTRIBUTE3"		    			    '||
	'	      ,ERI.ATTRIBUTE4			   "ATTRIBUTE4"		    			    '||
	'	      ,ERI.ATTRIBUTE5			   "ATTRIBUTE5"		    			    '||
	'	      ,ERI.ATTRIBUTE6			   "ATTRIBUTE6"		    			    '||
	'	      ,ERI.ATTRIBUTE7			   "ATTRIBUTE7"		    			    '||
	'	      ,ERI.ATTRIBUTE8			   "ATTRIBUTE8"		    			    '||
	'	      ,ERI.ATTRIBUTE9			   "ATTRIBUTE9"		    			    '||
	'	      ,ERI.ATTRIBUTE10			   "ATTRIBUTE10"		    		    '||
	'	      ,ERI.ATTRIBUTE11			   "ATTRIBUTE11"		    		    '||
	'	      ,ERI.ATTRIBUTE12			   "ATTRIBUTE12"		    		    '||
	'	      ,ERI.ATTRIBUTE13			   "ATTRIBUTE13"		    		    '||
	'	      ,ERI.ATTRIBUTE14			   "ATTRIBUTE14"		    		    '||
	'	      ,ERI.ATTRIBUTE15			   "ATTRIBUTE15"		    		    '||
	'	      ,ECSVL.STATUS_NAME		   "STATUS"					    '||
	'	      ,ERI.STATUS_TYPE			   "STATUS TYPE"				    '||
	'	      ,to_char(ERI.SCHEDULED_DATE,''DD-MON-YYYY HH24:MI:SS'') "SCHEDULED DATE"		    '||
	'	      ,ERI.BILL_SEQUENCE_ID		   "BILL SEQUENCE ID"		    		    '||
	'	      ,DECODE(ERI.MRP_ACTIVE,null,null,1,''Yes (1)'',2,''No (2)'',			    '||
	'			''OTHER ('' || ERI.MRP_ACTIVE || '')'') "MRP ACTIVE"		    	    '||
	'	      ,ERI.REQUEST_ID			   "REQUEST ID"		    			    '||
	'	      ,ERI.PROGRAM_APPLICATION_ID	   	   "PROGRAM APPLICATION ID"	    	    '||
	'	      ,ERI.PROGRAM_ID			   "PROGRAM ID"		    			    '||
	'	      ,to_char(ERI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"    '||
	'	      ,DECODE(ERI.UPDATE_WIP,null,null,1,''Yes (1)'',2,''No (2)'',			    '||
	'			''OTHER ('' || ERI.UPDATE_WIP || '')'') "UPDATE WIP"			    '||
	'	      ,DECODE(ERI.USE_UP,null,null,1,''Yes (1)'',2,''No (2)'',				    '||
	'			''OTHER ('' || ERI.USE_UP || '')'') "USE UP"				    '||
	'	      ,MIF2.PADDED_ITEM_NUMBER	   "USE UP ITEM NUMBER"					    '||
	'	      ,ERI.USE_UP_ITEM_ID		   	   "USE UP ITEM ID"		    	    '||
	'	      ,ERI.USE_UP_PLAN_NAME		   "USE UP PLAN NAME"		    		    '||
	'	      ,ERI.FROM_END_ITEM_UNIT_NUMBER	   "FROM END ITEM UNIT NUMBER"	    		    '||
	'	      ,ERI.ORIGINAL_SYSTEM_REFERENCE	   "ORIGINAL SYSTEM REFERENCE"	    		    '||
	'	      ,ERI.FROM_WIP_ENTITY_ID		   "FROM WIP ENTITY ID"	    			    '||
	'	      ,ERI.TO_WIP_ENTITY_ID		   "TO WIP ENTITY ID"		    		    '||
	'	      ,ERI.FROM_CUM_QTY			   "FROM CUM QTY"		    		    '||
	'	      ,ERI.LOT_NUMBER			   "LOT NUMBER"		    			    '||
	'	      ,ERI.CFM_ROUTING_FLAG		   "CFM ROUTING FLAG"		    		    '||
	'	      ,ERI.COMPLETION_SUBINVENTORY	   "COMPLETION SUBINVENTORY"	    		    '||
	'	      ,ERI.COMPLETION_LOCATOR_ID	   "COMPLETION LOCATOR ID"	    		    '||
	'	      ,ERI.MIXED_MODEL_MAP_FLAG		   "MIXED MODEL MAP FLAG"	    		    '||
	'	      ,ERI.PRIORITY			   "PRIORITY"			    		    '||
	'	      ,DECODE(ERI.CTP_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',			    '||
	'			''OTHER ('' || ERI.CTP_FLAG || '')'') "CTP FLAG"			    '||
	'	      ,ERI.ROUTING_SEQUENCE_ID		   "ROUTING SEQUENCE ID"	    		    '||
	'	      ,ERI.NEW_ROUTING_REVISION		   "NEW ROUTING REVISION"	    		    '||
	'	      ,ERI.ROUTING_COMMENT		   "ROUTING COMMENT"		    		    '||
	'	      ,DECODE(ERI.ECO_FOR_PRODUCTION,null,null,1,''Yes (1)'',2,''No (2)'',		    '||
	'			''OTHER ('' || ERI.ECO_FOR_PRODUCTION || '')'') "ECO FOR PRODUCTION"  	    '||
	'	      ,ERI.DESIGNATOR_SELECTION_TYPE	   "DESIGNATOR SELECTION TYPE"	    		    '||
	'	      ,ERI.ALTERNATE_BOM_DESIGNATOR	   "ALTERNATE BOM DESIGNATOR"	    		    '||
	'	      ,ERI.TRANSFER_OR_COPY		   "TRANSFER OR COPY"		    		    '||
	'	      ,ERI.TRANSFER_OR_COPY_ITEM	   "TRANSFER OR COPY ITEM"	    		    '||
	'	      ,ERI.TRANSFER_OR_COPY_BILL	   "TRANSFER OR COPY BILL"	    		    '||
	'	      ,ERI.TRANSFER_OR_COPY_ROUTING	   "TRANSFER OR COPY ROUTING"	    		    '||
	'	      ,ERI.COPY_TO_ITEM			   "COPY TO ITEM"		    		    '||
	'	      ,ERI.COPY_TO_ITEM_DESC		   "COPY TO ITEM DESC"		    		    '||
	'	      ,ERI.IMPLEMENTED_ONLY		   "IMPLEMENTED ONLY"		    		    '||
	'	      ,ERI.SELECTION_OPTION		   "SELECTION OPTION"		    		    '||
	'	      ,to_char(ERI.SELECTION_DATE,''DD-MON-YYYY HH24:MI:SS'') "SELECTION DATE"		    '||
	'	      ,ERI.SELECTION_UNIT_NUMBER	   "SELECTION UNIT NUMBER"	    		    '||
	'	      ,ERI.CONCATENATED_COPY_SEGMENTS	   "CONCATENATED COPY SEGMENTS"    		    '||
	'	      ,ERI.CHANGE_ID			   "CHANGE ID"			    		    '||
	'	      ,ERI.NEW_ITEM_REVISION_ID		   "NEW ITEM REVISION ID"	    		    '||
	'	      ,ERI.CURRENT_ITEM_REVISION_ID	   "CURRENT ITEM REVISION ID"	    		    '||
	'	      ,ERI.CURRENT_LIFECYCLE_STATE_ID	   "CURRENT LIFECYCLE STATE ID"    		    '||
	'	      ,ERI.NEW_LIFECYCLE_STATE_ID	   "NEW LIFECYCLE STATE ID"	    		    '||
	'	      ,ERI.STATUS_CODE			   "STATUS CODE"		    		    '||
	'	      ,ERI.FROM_END_ITEM_ID		   "FROM END ITEM ID"		    		    '||
	'	      ,ERI.FROM_END_ITEM_REV_ID		   "FROM END ITEM REV ID"	    		    '||
	'	      ,ERI.FROM_END_ITEM_STRC_REV_ID	   "FROM END ITEM STRC REV ID"	    		    '||
	'	      ,ERI.ENABLE_ITEM_IN_LOCAL_ORG	   "ENABLE ITEM IN LOCAL ORG"	    		    '||
	'	      ,ERI.CREATE_BOM_IN_LOCAL_ORG	   "CREATE BOM IN LOCAL ORG"	    		    '||
	'	      ,ERI.CURRENT_STRUCTURE_REV_ID	   "CURRENT STRUCTURE REV ID"	    		    '||
	'	      ,ERI.NEW_STRUCTURE_REVISION	   "NEW STRUCTURE REVISION"	    		    '||
	'	      ,ERI.PARENT_REVISED_ITEM_SEQ_ID	   "PARENT REVISED ITEM SEQ ID"    		    '||
	'	      ,ERI.PLAN_LEVEL			   "PLAN LEVEL"			    		    '||
	'	      ,ERI.NEW_REVISION_LABEL	   "NEW REVISION LABEL"			    		    '||
	'	      ,ERI.NEW_REVISION_REASON	   "NEW REVISION REASON"			    		    '||
	'	      ,ERI.NEW_REV_DESCRIPTION	   "NEW REV DESCRIPTION"			    		    '||
	'	      ,ERI.IMPLEMENTATION_REQ_ID	   "IMPLEMENTATION REQ ID"			    		    '||
	'	FROM    ENG_REVISED_ITEMS ERI					    			    '||
	'		 ,MTL_ITEM_FLEXFIELDS MIF1							    '||
	'		 ,MTL_ITEM_FLEXFIELDS MIF2						    	    '||
	'		 ,MTL_PARAMETERS MP1								    '||
	'		 ,ENG_CHANGE_STATUSES_VL ECSVL	   					    	    '||
	'	  WHERE 1=1			    					    		    '||
	'		AND ERI.ORGANIZATION_ID = MP1.ORGANIZATION_ID			    		    '||
	'		AND ERI.REVISED_ITEM_ID = MIF1.INVENTORY_ITEM_ID		    		    '||
	'		AND ERI.ORGANIZATION_ID = MIF1.ORGANIZATION_ID					    '||
	'		AND ERI.USE_UP_ITEM_ID 	= MIF2.INVENTORY_ITEM_ID(+)				    '||
	'		AND ERI.ORGANIZATION_ID = MIF2.ORGANIZATION_ID(+)				    '||
	'		AND ERI.STATUS_TYPE 	= ECSVL.STATUS_CODE(+)			    		    '||
	'		AND eri.change_notice =	 '''||l_eco_name||'''					';

	if l_org_id is not null then
		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
	end if;
	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number,eri.revised_item_sequence_id';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Eco Revised Items ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr:= 'SUCCESS';
	isFatal := 'FALSE';


	/* End of ECO Revised Items Details*/

	l_ret_status := fnd_installation.get_app_info ('BOM'
						   , l_status
						   , l_industry
						   , l_oracle_schema
						    );
	/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

	/* SQL to fetch revised components from bom_components_b table*/
   sqltxt := ' 		SELECT eri.change_notice "CHANGE NOTICE"								'||
		 ' 		,MP1.ORGANIZATION_CODE 	   "ORGANIZATION CODE" 							'||
		 ' 		,eri.organization_id	     	   "ORGANIZATION ID"							'||
		 ' 		,MIF1.PADDED_ITEM_NUMBER	   "REVISED ITEM NUMBER"		  				'||
		 ' 		,eri.revised_item_id	     	   "REVISED ITEM ID"							'||
		 ' 		,eri.REVISED_ITEM_SEQUENCE_ID     "REVISED ITEM SEQUENCE ID"  					'||
		 ' 		,BCB.OPERATION_SEQ_NUM            "OPERATION SEQ NUM"						'||
  		 ' 		,MIF2.PADDED_ITEM_NUMBER	    "COMPONENT ITEM NUMBER"		           			'||
		 ' 		,BCB.COMPONENT_ITEM_ID            "COMPONENT ITEM ID"						'||
		 ' 		,BCB.COMPONENT_SEQUENCE_ID       "COMPONENT SEQUENCE ID"         					'||
		 ' 		,to_char(BCB.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE "         		'||
		 ' 		,BCB.LAST_UPDATED_BY              "LAST UPDATED BY"           					'||
		 ' 		,to_char(BCB.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')  "CREATION DATE"             			'||
		 ' 		,BCB.CREATED_BY                   "CREATED BY"             						'||
		 ' 		,BCB.LAST_UPDATE_LOGIN            "LAST UPDATE LOGIN"          					'||
		 ' 		,BCB.ITEM_NUM                     "ITEM NUM"             						'||
		 ' 		,BCB.COMPONENT_QUANTITY           "COMPONENT QUANTITY"         					'||
		 ' 		,BCB.COMPONENT_YIELD_FACTOR       "COMPONENT YIELD FACTOR"     					'||
		 ' 		,BCB.COMPONENT_REMARKS            "COMPONENT REMARKS"          					'||
		 ' 		,to_char(BCB.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')  "EFFECTIVITY DATE "          		'||
		 ' 		,BCB.CHANGE_NOTICE                "CHANGE NOTICE"             					'||
		 ' 		,to_char(BCB.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'')"IMPLEMENTATION DATE"        		'||
		 ' 		,to_char(BCB.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'')       "DISABLE DATE"             		'||
		 ' 		,BCB.ATTRIBUTE_CATEGORY           "ATTRIBUTE CATEGORY"         					'||
		 ' 		,BCB.ATTRIBUTE1                   "ATTRIBUTE1"             						'||
		 ' 		,BCB.ATTRIBUTE2                   "ATTRIBUTE2"             						'||
		 ' 		,BCB.ATTRIBUTE3                   "ATTRIBUTE3"             						'||
		 ' 		,BCB.ATTRIBUTE4                   "ATTRIBUTE4"             						'||
		 ' 		,BCB.ATTRIBUTE5                   "ATTRIBUTE5"             						'||
		 ' 		,BCB.ATTRIBUTE6                   "ATTRIBUTE6"             						'||
		 ' 		,BCB.ATTRIBUTE7                   "ATTRIBUTE7"             						'||
		 ' 		,BCB.ATTRIBUTE8                   "ATTRIBUTE8"             						'||
		 ' 		,BCB.ATTRIBUTE9                   "ATTRIBUTE9"             						'||
		 ' 		,BCB.ATTRIBUTE10                  "ATTRIBUTE10"             						'||
		 ' 		,BCB.ATTRIBUTE11                  "ATTRIBUTE11"             						'||
		 ' 		,BCB.ATTRIBUTE12                  "ATTRIBUTE12"             						'||
		 ' 		,BCB.ATTRIBUTE13                  "ATTRIBUTE13"             						'||
		 ' 		,BCB.ATTRIBUTE14                  "ATTRIBUTE14"             						'||
		 ' 		,BCB.ATTRIBUTE15                  "ATTRIBUTE15"             						'||
		 ' 		,BCB.PLANNING_FACTOR              "PLANNING FACTOR"            					'||
		 ' 		,DECODE(BCB.QUANTITY_RELATED,null,null,1,''Yes (1)'',2,''No (2)'',					'||
		 ' 			''OTHER ('' || BCB.QUANTITY_RELATED || '')'') "QUANTITY RELATED"		             	'||
		 ' 		,DECODE(MLU_SO.MEANING,null,null,									'||
		 ' 			(MLU_SO.MEANING || '' ('' || BCB.SO_BASIS || '')'')) "SO BASIS"					'||
          	 ' 		,DECODE(BCB.OPTIONAL,null,null,1,''Yes (1)'',2,''No (2)'',						'||
          	 ' 			''OTHER ('' || BCB.OPTIONAL || '')'') "OPTIONAL"						'||
		 ' 		,DECODE(BCB.MUTUALLY_EXCLUSIVE_OPTIONS,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		 ' 			''OTHER ('' || BCB.MUTUALLY_EXCLUSIVE_OPTIONS || '')'') "MUTUALLY EXCLUSIVE OPTIONS"     	'||
          	 ' 		,DECODE(BCB.INCLUDE_IN_COST_ROLLUP,null,null,1,''Yes (1)'',2,''No (2)'',				'||
          	 ' 			''OTHER ('' || BCB.INCLUDE_IN_COST_ROLLUP || '')'') "INCLUDE IN COST ROLLUP"		    	'||
		 ' 		,DECODE(BCB.CHECK_ATP,null,null,1,''Yes (1)'',2,''No (2)'',						'||
		 ' 			''OTHER ('' || BCB.CHECK_ATP || '')'') "CHECK ATP"						'||
		 ' 		,DECODE(BCB.SHIPPING_ALLOWED,null,null,1,''Yes (1)'',2,''No (2)'',					'||
		 ' 			''OTHER ('' || BCB.SHIPPING_ALLOWED || '')'') "SHIPPING ALLOWED"				'||
		 ' 		,DECODE(BCB.REQUIRED_TO_SHIP,null,null,1,''Yes (1)'',2,''No (2)'',					'||
		 ' 			''OTHER ('' || BCB.REQUIRED_TO_SHIP || '')'') "REQUIRED TO SHIP"		  		'||
		 ' 		,DECODE(BCB.REQUIRED_FOR_REVENUE,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		 ' 			''OTHER ('' || BCB.REQUIRED_FOR_REVENUE || '')'') "REQUIRED FOR REVENUE"		       	'||
		 ' 		,DECODE(BCB.INCLUDE_ON_SHIP_DOCS,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		 ' 			''OTHER ('' || BCB.INCLUDE_ON_SHIP_DOCS || '')'') "INCLUDE ON SHIP DOCS"		       	'||
		 ' 		,DECODE(BCB.INCLUDE_ON_BILL_DOCS,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		 ' 			''OTHER ('' || BCB.INCLUDE_ON_BILL_DOCS || '')'') "INCLUDE ON BILL DOCS"		       	'||
		 ' 		,BCB.LOW_QUANTITY                  "LOW QUANTITY"             					'||
		 ' 		,BCB.HIGH_QUANTITY                 "HIGH QUANTITY"							'||
		 ' 		,DECODE(MLU_ACD.MEANING,null,null,									'||
		 ' 			(MLU_ACD.MEANING || '' ('' || BCB.ACD_TYPE || '')'')) "ACD TYPE"  				'||
		 ' 		,BCB.OLD_COMPONENT_SEQUENCE_ID     "OLD COMPONENT SEQUENCE ID"  					'||
		 ' 		,BCB.COMPONENT_SEQUENCE_ID         "COMPONENT SEQUENCE ID"      					'||
		 ' 		,BCB.BILL_SEQUENCE_ID              "BILL SEQUENCE ID"           					'||
		 ' 		,BCB.REQUEST_ID                    "REQUEST ID"             						'||
		 ' 		,BCB.PROGRAM_APPLICATION_ID        "PROGRAM APPLICATION ID"     					'||
		 ' 		,BCB.PROGRAM_ID                    "PROGRAM ID"             						'||
		 ' 		,to_char(BCB.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')  "PROGRAM UPDATE DATE"			'||
		 ' 		,DECODE(MLU_WIP.MEANING,null,null,									'||
		 ' 			(MLU_WIP.MEANING || '' ('' || BCB.WIP_SUPPLY_TYPE || '')'')) "WIP SUPPLY TYPE"			'||
		 ' 		,DECODE(BCB.PICK_COMPONENTS,null,null,1,''Yes (1)'',2,''No (2)'',					'||
		 ' 			''OTHER ('' || BCB.PICK_COMPONENTS || '')'') "PICK COMPONENTS"				    	'||
		 ' 		,BCB.SUPPLY_SUBINVENTORY           "SUPPLY SUBINVENTORY"        					'||
		 ' 		,BCB.SUPPLY_LOCATOR_ID             "SUPPLY LOCATOR ID"          					'||
		 ' 		,BCB.OPERATION_LEAD_TIME_PERCENT   "OPERATION LEAD TIME PERCENT"					'||
		 ' 		,BCB.COST_FACTOR                   "COST FACTOR" 							'||
		 ' 		,DECODE(MLU_BIT.MEANING,null,null,									'||
		 ' 			(MLU_BIT.MEANING || '' ('' || BCB.BOM_ITEM_TYPE || '')'')) "BOM ITEM TYPE"			'||
		 ' 		,BCB.FROM_END_ITEM_UNIT_NUMBER     "FROM END ITEM UNIT NUMBER"  					'||
		 ' 		,BCB.TO_END_ITEM_UNIT_NUMBER       "TO END ITEM UNIT NUMBER"						'||
		 ' 		,DECODE(ascii(BCB.ORIGINAL_SYSTEM_REFERENCE),''0'',							'||
		 ' 			''**NULL CHAR**'',BCB.ORIGINAL_SYSTEM_REFERENCE) "ORIGINAL SYSTEM REFERENCE"			'||
		 ' 		,DECODE(BCB.ECO_FOR_PRODUCTION,null,null,1,''Yes (1)'',2,''No (2)'',					'||
		 ' 			''OTHER ('' || BCB.ECO_FOR_PRODUCTION || '')'') "ECO FOR PRODUCTION"		  	        '||
		 ' 		,BCB.ENFORCE_INT_REQUIREMENTS      "ENFORCE INT REQUIREMENTS"   					'||
		 ' 		,BCB.COMPONENT_ITEM_REVISION_ID    "COMPONENT ITEM REVISION ID" 					'||
		 ' 		,BCB.DELETE_GROUP_NAME             "DELETE GROUP NAME"          					'||
		 ' 		,BCB.DG_DESCRIPTION                "DG DESCRIPTION"             					'||
		 ' 		,BCB.OPTIONAL_ON_MODEL             "OPTIONAL ON MODEL"          					'||
		 ' 		,BCB.PARENT_BILL_SEQ_ID            "PARENT BILL SEQ ID"         					'||
		 ' 		,BCB.MODEL_COMP_SEQ_ID             "MODEL COMP SEQ ID"          					'||
		 ' 		,BCB.PLAN_LEVEL                    "PLAN LEVEL"             						'||
		 ' 		,BCB.FROM_BILL_REVISION_ID         "FROM BILL REVISION ID"      					'||
		 ' 		,BCB.TO_BILL_REVISION_ID           "TO BILL REVISION ID"        					'||
		 ' 		,BCB.AUTO_REQUEST_MATERIAL         "AUTO REQUEST MATERIAL"      			'||
		 ' 		,BCB.SUGGESTED_VENDOR_NAME         "SUGGESTED VENDOR NAME"      					'||
		 ' 		,BCB.VENDOR_ID                     "VENDOR ID"             						'||
		 ' 		,BCB.UNIT_PRICE                    "UNIT PRICE"             						'||
		 ' 		,BCB.OBJ_NAME                      "OBJ NAME"             						'||
		 ' 		,BCB.PK1_VALUE                     "PK1 VALUE"             						'||
		 ' 		,BCB.PK2_VALUE                     "PK2 VALUE"             						'||
		 ' 		,BCB.PK3_VALUE                     "PK3 VALUE"             						'||
		 ' 		,BCB.PK4_VALUE                     "PK4 VALUE"             						'||
		 ' 		,BCB.PK5_VALUE                     "PK5 VALUE"             						'||
		'	FROM  	BOM_COMPONENTS_B BCB, 									'||
		'		  	ENG_REVISED_ITEMS ERI,										'||
		'		  	MTL_PARAMETERS MP1,										'||
		'          		MTL_ITEM_FLEXFIELDS MIF1,									'||
		'          		MTL_ITEM_FLEXFIELDS MIF2,									'||
		'          		MFG_LOOKUPS MLU_SO,										'||
		'			MFG_LOOKUPS MLU_ACD,										'||
		'		 	MFG_LOOKUPS MLU_WIP,										'||
		'		 	MFG_LOOKUPS MLU_BIT										'||
		'	WHERE 		1=1												'||
		'	AND 		BCB.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID 					'||
		'	AND 		ERI.REVISED_ITEM_ID = MIF1.INVENTORY_ITEM_ID							'||
		'  	AND 		ERI.ORGANIZATION_ID = MIF1.ORGANIZATION_ID							'||
		'	AND 		BCB.COMPONENT_ITEM_ID = MIF2.INVENTORY_ITEM_ID							'||
		'	AND 		ERI.ORGANIZATION_ID = MP1.ORGANIZATION_ID							'||
		'	and 		MP1.ORGANIZATION_ID = MIF2.ORGANIZATION_ID							'||
		'	and 		BCB.SO_BASIS=MLU_SO.LOOKUP_CODE(+) AND ''BOM_SO_BASIS''=MLU_SO.LOOKUP_TYPE(+)		 	'||
		'	AND 		BCB.ACD_TYPE=MLU_ACD.LOOKUP_CODE(+) AND ''ECG_ACTION''=MLU_ACD.LOOKUP_TYPE(+)		 	'||
		'	AND 		BCB.WIP_SUPPLY_TYPE=MLU_WIP.LOOKUP_CODE(+) AND ''WIP_SUPPLY''=MLU_WIP.LOOKUP_TYPE(+)	 	'||
		'	AND 		BCB.BOM_ITEM_TYPE=MLU_BIT.LOOKUP_CODE(+) AND ''BOM_ITEM_TYPE''=MLU_BIT.LOOKUP_TYPE(+)	 	'||
		'	AND		eri.change_notice =		   '''||l_eco_name||'''						';

	if l_org_id is not null then
		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
	end if;
	sqltxt :=sqltxt||' and rownum <   '||row_limit;
   	sqltxt :=sqltxt||' order by mp1.organization_code,mif1.padded_item_number,eri.revised_item_sequence_id, '||
			 ' BCB.operation_seq_num, BCB.item_num';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Revised Components ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr:= 'SUCCESS';
	isFatal := 'FALSE';

	   sqltxt := ' 		SELECT eri.change_notice "CHANGE NOTICE"								'||
		 ' 		,MP1.ORGANIZATION_CODE 	   "ORGANIZATION CODE" 							'||
		 ' 		,eri.organization_id	     	   "ORGANIZATION ID"							'||
		 ' 		,MIF1.PADDED_ITEM_NUMBER	   "REVISED ITEM NUMBER"		  				'||
		 ' 		,BCB.FROM_END_ITEM_REV_ID          "FROM END ITEM REV ID"       					'||
		 ' 		,BCB.TO_END_ITEM_REV_ID            "TO END ITEM REV ID"         					'||
		 ' 		,BCB.OVERLAPPING_CHANGES           "OVERLAPPING CHANGES"        					'||
		 ' 		,BCB.FROM_OBJECT_REVISION_ID       "FROM OBJECT REVISION ID"    					'||
		 ' 		,BCB.FROM_MINOR_REVISION_ID        "FROM MINOR REVISION ID"     					'||
		 ' 		,BCB.TO_OBJECT_REVISION_ID         "TO OBJECT REVISION ID"      					'||
		 ' 		,BCB.TO_MINOR_REVISION_ID          "TO MINOR REVISION ID"       					'||
		 ' 		,BCB.FROM_END_ITEM_MINOR_REV_ID    "FROM END ITEM MINOR REV ID" 					'||
		 ' 		,BCB.TO_END_ITEM_MINOR_REV_ID      "TO END ITEM MINOR REV ID"   					'||
		 ' 		,BCB.COMPONENT_MINOR_REVISION_ID   "COMPONENT MINOR REVISION ID"					'||
		 ' 		,BCB.FROM_STRUCTURE_REVISION_CODE  "FROM STRUCTURE REVISION CODE"					'||
		 ' 		,BCB.TO_STRUCTURE_REVISION_CODE    "TO STRUCTURE REVISION CODE" 					'||
		 ' 		,BCB.FROM_END_ITEM_STRC_REV_ID     "FROM END ITEM STRC REV ID"  					'||
		 ' 		,BCB.TO_END_ITEM_STRC_REV_ID       "TO END ITEM STRC REV ID"     					'||
		 ' 		,BCB.BASIS_TYPE					"BASIS TYPE"     					'||
		'		,BCB.COMMON_COMPONENT_SEQUENCE_ID					"COMMON COMPONENT SEQUENCE ID"  '||
		'	FROM  	BOM_COMPONENTS_B BCB, 									'||
		'		  	ENG_REVISED_ITEMS ERI,										'||
		'		  	MTL_PARAMETERS MP1,										'||
		'          		MTL_ITEM_FLEXFIELDS MIF1,									'||
		'          		MTL_ITEM_FLEXFIELDS MIF2,									'||
		'          		MFG_LOOKUPS MLU_SO,										'||
		'			MFG_LOOKUPS MLU_ACD,										'||
		'		 	MFG_LOOKUPS MLU_WIP,										'||
		'		 	MFG_LOOKUPS MLU_BIT										'||
		'	WHERE 		1=1												'||
		'	AND 		BCB.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID 					'||
		'	AND 		ERI.REVISED_ITEM_ID = MIF1.INVENTORY_ITEM_ID							'||
		'  	AND 		ERI.ORGANIZATION_ID = MIF1.ORGANIZATION_ID							'||
		'	AND 		BCB.COMPONENT_ITEM_ID = MIF2.INVENTORY_ITEM_ID							'||
		'	AND 		ERI.ORGANIZATION_ID = MP1.ORGANIZATION_ID							'||
		'	and 		MP1.ORGANIZATION_ID = MIF2.ORGANIZATION_ID							'||
		'	and 		BCB.SO_BASIS=MLU_SO.LOOKUP_CODE(+) AND ''BOM_SO_BASIS''=MLU_SO.LOOKUP_TYPE(+)		 	'||
		'	AND 		BCB.ACD_TYPE=MLU_ACD.LOOKUP_CODE(+) AND ''ECG_ACTION''=MLU_ACD.LOOKUP_TYPE(+)		 	'||
		'	AND 		BCB.WIP_SUPPLY_TYPE=MLU_WIP.LOOKUP_CODE(+) AND ''WIP_SUPPLY''=MLU_WIP.LOOKUP_TYPE(+)	 	'||
		'	AND 		BCB.BOM_ITEM_TYPE=MLU_BIT.LOOKUP_CODE(+) AND ''BOM_ITEM_TYPE''=MLU_BIT.LOOKUP_TYPE(+)	 	'||
		'	AND		eri.change_notice =		   '''||l_eco_name||'''						';

	if l_org_id is not null then
		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
	end if;
	sqltxt :=sqltxt||' and rownum <   '||row_limit;
   	sqltxt :=sqltxt||' order by mp1.organization_code,mif1.padded_item_number,eri.revised_item_sequence_id, '||
			 ' BCB.operation_seq_num, BCB.item_num';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Revised Components (Contd 1..) ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr:= 'SUCCESS';
	isFatal := 'FALSE';

	/* End of revised components from bom components b */

	/* SQL to fetch reference designators from bom_reference_designators table*/
	sqltxt := '	SELECT	 ERI.CHANGE_NOTICE "CHANGE NOTICE"						'||
		'		,MP1.ORGANIZATION_CODE 	     		"ORGANIZATION CODE"		      '||
		'		,ERI.ORGANIZATION_ID	     	     "ORGANIZATION ID"			      '||
		'		,MIF1.PADDED_ITEM_NUMBER	  	"REVISED ITEM NUMBER"	      		'||
		'		,ERI.REVISED_ITEM_ID	             "REVISED ITEM ID"			      '||
		'		,ERI.REVISED_ITEM_SEQUENCE_ID	     "REVISED ITEM SEQUENCE ID"	      	  	'||
		'		,MIF2.PADDED_ITEM_NUMBER	        "COMPONENT ITEM NUMBER"	      		'||
		'		,BCB.COMPONENT_ITEM_ID 		     "COMPONENT ITEM ID"		      '||
		'		,BCB.COMPONENT_SEQUENCE_ID 	     "COMPONENT SEQUENCE ID"		      '||
		'		,BRD.COMPONENT_REFERENCE_DESIGNATOR   "COMPONENT REFERENCE DESIGNATOR"	      '||
		'		,to_char(BRD.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')  "LAST UPDATE DATE" '||
		'		,BRD.LAST_UPDATED_BY                  "LAST UPDATED BY"                       '||
		'		,to_char(BRD.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')  "CREATION DATE"       '||
		'		,BRD.CREATED_BY                       "CREATED BY"                            '||
		'		,BRD.LAST_UPDATE_LOGIN                "LAST UPDATE LOGIN"                     '||
		'		,BRD.REF_DESIGNATOR_COMMENT           "REF DESIGNATOR COMMENT"                '||
		'		,BRD.CHANGE_NOTICE                    "CHANGE NOTICE"                         '||
 		'		,DECODE(BRD.ACD_TYPE,null,null,1,''Add (1)'',2,''Change (2)'',3,''Delete (3)'',	'||
 		'			''OTHER('' || BRD.ACD_TYPE || '')'') "ACD TYPE"				'||
		'		,BRD.REQUEST_ID                       "REQUEST ID"                            '||
		'		,BRD.PROGRAM_APPLICATION_ID           "PROGRAM APPLICATION ID"                '||
		'		,BRD.PROGRAM_ID                       "PROGRAM ID"                            '||
		'		,to_char(BRD.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE" '||
		'		,BRD.ATTRIBUTE_CATEGORY               "ATTRIBUTE CATEGORY"                    '||
		'		,BRD.ATTRIBUTE1                       "ATTRIBUTE1"                            '||
		'		,BRD.ATTRIBUTE2                       "ATTRIBUTE2"                            '||
		'		,BRD.ATTRIBUTE3                       "ATTRIBUTE3"                            '||
		'		,BRD.ATTRIBUTE4                       "ATTRIBUTE4"                            '||
		'		,BRD.ATTRIBUTE5                       "ATTRIBUTE5"                            '||
		'		,BRD.ATTRIBUTE6                       "ATTRIBUTE6"                            '||
		'		,BRD.ATTRIBUTE7                       "ATTRIBUTE7"                            '||
		'		,BRD.ATTRIBUTE8                       "ATTRIBUTE8"                            '||
		'		,BRD.ATTRIBUTE9                       "ATTRIBUTE9"                            '||
		'		,BRD.ATTRIBUTE10                      "ATTRIBUTE10"                           '||
		'		,BRD.ATTRIBUTE11                      "ATTRIBUTE11"                           '||
		'		,BRD.ATTRIBUTE12                      "ATTRIBUTE12"                           '||
		'		,BRD.ATTRIBUTE13                      "ATTRIBUTE13"                           '||
		'		,BRD.ATTRIBUTE14                      "ATTRIBUTE14"                           '||
		'		,BRD.ATTRIBUTE15                      "ATTRIBUTE15"                           '||
		'		,BRD.ORIGINAL_SYSTEM_REFERENCE        "ORIGINAL SYSTEM REFERENCE"	      '||
		'		,BRD.COMMON_COMPONENT_SEQUENCE_ID        "COMMON COMPONENT SEQUENCE ID"	      '||
		'	FROM   	 BOM_REFERENCE_DESIGNATORS BRD 					      		'||
		'	       	,BOM_COMPONENTS_B BCB					      		'||
		'	       	,ENG_REVISED_ITEMS ERI						      		'||
		'	       	,MTL_PARAMETERS MP1						      		'||
        	'    	       	,MTL_ITEM_FLEXFIELDS MIF1					      		'||
  		'               ,MTL_ITEM_FLEXFIELDS MIF2							'||
		'	WHERE 	 1=1								      		'||
		'	AND	 BCB.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID	      		'||
		'	AND    	 BRD.COMPONENT_SEQUENCE_ID= BCB.COMPONENT_SEQUENCE_ID	      		       '||
		'	AND	 ERI.ORGANIZATION_ID 	 = MP1.ORGANIZATION_ID		      		       '||
		'	AND 	 ERI.REVISED_ITEM_ID 	 = MIF1.INVENTORY_ITEM_ID	      		       '||
  		'	AND 	 ERI.ORGANIZATION_ID 	 = MIF1.ORGANIZATION_ID		      		       '||
  		'	AND	 BCB.COMPONENT_ITEM_ID 	 = MIF2.INVENTORY_ITEM_ID	      		       '||
		'	AND	 MP1.ORGANIZATION_ID 	 = MIF2.ORGANIZATION_ID		      		       '||
		'       AND      eri.change_notice =		'''||l_eco_name||'''				';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by mp1.organization_code,mif1.padded_item_number,eri.revised_item_sequence_id,	'||
				 ' BCB.operation_seq_num, BCB.item_num,mif2.padded_item_number, BCB.component_sequence_id,'||
				 ' brd.component_reference_designator';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Reference Designators on Eco Revised Components ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of reference designators from bom_reference_designators  */

	/* SQL to fetch substitute components from Bom_substitute_components table*/
	 sqltxt := ' SELECT	 ERI.CHANGE_NOTICE "CHANGE NOTICE"						'||
		'		,MP1.ORGANIZATION_CODE 	     		"ORGANIZATION CODE"			 '||
		'		,ERI.ORGANIZATION_ID	     	     	"ORGANIZATION ID"			 '||
		'		,MIF1.PADDED_ITEM_NUMBER	  	"REVISED ITEM NUMBER"	      		 '||
		'		,ERI.REVISED_ITEM_ID	             	"REVISED ITEM ID"			 '||
		'		,ERI.REVISED_ITEM_SEQUENCE_ID	     	"REVISED ITEM SEQUENCE ID"	      	 '||
		'		,MIF2.PADDED_ITEM_NUMBER	        "COMPONENT ITEM NUMBER"	      		 '||
		'		,BCB.COMPONENT_ITEM_ID 		     	"COMPONENT ITEM ID"			 '||
		'		,BCB.COMPONENT_SEQUENCE_ID 	     	"COMPONENT SEQUENCE ID"			 '||
		'		,MIF3.PADDED_ITEM_NUMBER                "SUBSTITUTE ITEM NUMBER"		 '||
		'		,BSCO.SUBSTITUTE_COMPONENT_ID	    	"SUBSTITUTE COMPONENT ID"		 '||
		'		,to_char(BSCO.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE"    '||
		'		,BSCO.LAST_UPDATED_BY                	"LAST UPDATED BY"          		 '||
		'		,to_char(BSCO.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE"          '||
		'		,BSCO.CREATED_BY                     	"CREATED BY"               		 '||
		'		,BSCO.LAST_UPDATE_LOGIN              	"LAST UPDATE LOGIN"        		 '||
		'		,NVL(BSCO.SUBSTITUTE_ITEM_QUANTITY,0)	"SUBSTITUTE ITEM QUANTITY" 		 '||
		'		,DECODE(MLU_ACD.MEANING,null,null, 						 '||
		'			(MLU_ACD.MEANING || '' ('' || BSCO.ACD_TYPE || '')'')) "ACD TYPE"	 '||
		'		,BSCO.CHANGE_NOTICE                   	"CHANGE NOTICE"            		 '||
		'		,BSCO.REQUEST_ID                    	"REQUEST ID"             		 '||
		'		,BSCO.PROGRAM_APPLICATION_ID        	"PROGRAM APPLICATION ID" 		 '||
		'		,BSCO.PROGRAM_ID                    	"PROGRAM ID"             		 '||
		'		,to_char(BSCO.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE" '||
		'		,BSCO.ATTRIBUTE_CATEGORY            	"ATTRIBUTE CATEGORY"     		 '||
		'		,BSCO.ATTRIBUTE1                    	"ATTRIBUTE1"             		 '||
		'		,BSCO.ATTRIBUTE2                    	"ATTRIBUTE2"             		 '||
		'		,BSCO.ATTRIBUTE3                    	"ATTRIBUTE3"             		 '||
		'		,BSCO.ATTRIBUTE4                    	"ATTRIBUTE4"             		 '||
		'		,BSCO.ATTRIBUTE5                    	"ATTRIBUTE5"             		 '||
		'		,BSCO.ATTRIBUTE6                    	"ATTRIBUTE6"             		 '||
		'		,BSCO.ATTRIBUTE7                    	"ATTRIBUTE7"             		 '||
		'		,BSCO.ATTRIBUTE8                    	"ATTRIBUTE8"             		 '||
		'		,BSCO.ATTRIBUTE9                    	"ATTRIBUTE9"             		 '||
		'		,BSCO.ATTRIBUTE10                   	"ATTRIBUTE10"            		 '||
		'		,BSCO.ATTRIBUTE11                   	"ATTRIBUTE11"            		 '||
		'		,BSCO.ATTRIBUTE12                   	"ATTRIBUTE12"            		 '||
		'		,BSCO.ATTRIBUTE13                   	"ATTRIBUTE13"            		 '||
		'		,BSCO.ATTRIBUTE14                   	"ATTRIBUTE14"            		 '||
		'		,BSCO.ATTRIBUTE15                   	"ATTRIBUTE15"            		 '||
		'		,BSCO.ORIGINAL_SYSTEM_REFERENCE     	"ORIGINAL SYSTEM REFERENCE"		 '||
		'		,BSCO.ENFORCE_INT_REQUIREMENTS      	"ENFORCE INT REQUIREMENTS"		 '||
		'		,BSCO.COMMON_COMPONENT_SEQUENCE_ID      	"COMMON COMPONENT SEQUENCE ID"		 '||
		'	FROM 	 ENG_REVISED_ITEMS ERI								 '||
		'		,BOM_COMPONENTS_B BCB 							 '||
		'		,BOM_SUBSTITUTE_COMPONENTS BSCO							 '||
		'		,MTL_PARAMETERS MP1								 '||
		'		,MTL_ITEM_FLEXFIELDS MIF1							 '||
		'		,MTL_ITEM_FLEXFIELDS MIF2							 '||
		'		,MTL_ITEM_FLEXFIELDS MIF3							 '||
		'		,MFG_LOOKUPS MLU_ACD								 '||
		'	WHERE 	 1=1										 '||
		'	AND	 BCB.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID	      		 '||
		'	AND  	 BSCO.COMPONENT_SEQUENCE_ID= BCB.COMPONENT_SEQUENCE_ID				 '||
		'	AND	 ERI.ORGANIZATION_ID 	 = MP1.ORGANIZATION_ID		      		    	 '||
		'	AND	 ERI.REVISED_ITEM_ID 	 = MIF1.INVENTORY_ITEM_ID	      		       	 '||
		'	AND	 ERI.ORGANIZATION_ID 	 = MIF1.ORGANIZATION_ID		      		       	 '||
		'	AND	 BCB.COMPONENT_ITEM_ID 	 = MIF2.INVENTORY_ITEM_ID	      		       	 '||
		'	AND	 ERI.ORGANIZATION_ID 	 = MIF2.ORGANIZATION_ID		      		      	 '||
		'	AND	 BSCO.SUBSTITUTE_COMPONENT_ID = MIF3.INVENTORY_ITEM_ID	      		       	 '||
		'	AND	 ERI.ORGANIZATION_ID 	 = MIF3.ORGANIZATION_ID					 '||
		'	AND	 BSCO.ACD_TYPE = MLU_ACD.LOOKUP_CODE(+)						 '||
		'	AND	 ''ECG_ACTION''=MLU_ACD.LOOKUP_TYPE(+)						 '||
		'       AND      eri.change_notice            =		'''||l_eco_name||'''			';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by mp1.organization_code,mif1.padded_item_number, eri.revised_item_sequence_id, '||
				 ' BCB.operation_seq_num, BCB.item_num,mif2.padded_item_number, BCB.component_sequence_id,'||
				 ' bsco.substitute_component_id';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Substitute Components on Eco Revised Components');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of substitute components from Bom_substitute_components */

	/* SQL to fetch revised operations from Bom_Operation_Sequences table*/
	 sqltxt :=	' SELECT	   ERI.CHANGE_NOTICE		    "CHANGE NOTICE"								'||
			'	 	  ,MP1.ORGANIZATION_CODE	     "ORGANIZATION CODE"							'||
			'		  ,ERI.ORGANIZATION_ID	     	     "ORGANIZATION ID"								'||
			'		  ,MIF1.PADDED_ITEM_NUMBER	     "REVISED ITEM NUMBER"							'||
			'		  ,ERI.REVISED_ITEM_ID	             "REVISED ITEM ID"								'||
			'		  ,BOS.REVISED_ITEM_SEQUENCE_ID      "REVISED ITEM SEQUENCE ID"							'||
			'		  ,BOS.OPERATION_SEQUENCE_ID         "OPERATION SEQUENCE ID"							'||
			'		  ,BOS.ROUTING_SEQUENCE_ID           "ROUTING SEQUENCE ID"							'||
			'		  ,BOS.OPERATION_SEQ_NUM             "OPERATION SEQ NUM"							'||
			'		  ,to_char(BOS.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE "					'||
			'		  ,BOS.LAST_UPDATED_BY               "LAST UPDATED BY"								'||
			'		  ,to_char(BOS.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')    "CREATION DATE"					'||
			'		  ,BOS.CREATED_BY                    "CREATED BY"								'||
			'		  ,BOS.LAST_UPDATE_LOGIN             "LAST UPDATE LOGIN"							'||
			'		  ,BOS.STANDARD_OPERATION_ID         "STANDARD OPERATION ID"							'||
			'		  ,BOS.DEPARTMENT_ID                 "DEPARTMENT ID"								'||
			'		  ,BOS.OPERATION_LEAD_TIME_PERCENT   "OPERATION LEAD TIME PERCENT"						'||
			'		  ,BOS.MINIMUM_TRANSFER_QUANTITY     "MINIMUM TRANSFER QUANTITY"						'||
			'		  ,DECODE(MLU_BCPT.MEANING,null,null,										'||
			'		  	(MLU_BCPT.MEANING || '' ('' || BOS.COUNT_POINT_TYPE || '')'')) "Count Point Type"			'||
			'		  ,BOS.OPERATION_DESCRIPTION         "OPERATION DESCRIPTION"							'||
			'		  ,to_char(BOS.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVITY DATE"					'||
			'		  ,to_char(BOS.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'')     "DISABLE DATE"					'||
			'		  ,DECODE(BOS.BACKFLUSH_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',						'||
			'			''OTHER ('' || BOS.BACKFLUSH_FLAG || '')'') "Backflush Flag"						'||
			'		  ,DECODE(BOS.OPTION_DEPENDENT_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',					'||
			'			''OTHER ('' || BOS.OPTION_DEPENDENT_FLAG || '')'') "Option Dependent Flag"				'||
			'	          ,BOS.ATTRIBUTE_CATEGORY            "ATTRIBUTE CATEGORY "							'||
			'		  ,BOS.ATTRIBUTE1                    "ATTRIBUTE1"								'||
			'		  ,BOS.ATTRIBUTE2                    "ATTRIBUTE2"								'||
			'		  ,BOS.ATTRIBUTE3                    "ATTRIBUTE3"								'||
			'		  ,BOS.ATTRIBUTE4                    "ATTRIBUTE4"								'||
			'		  ,BOS.ATTRIBUTE5                    "ATTRIBUTE5"								'||
			'		  ,BOS.ATTRIBUTE6                    "ATTRIBUTE6"								'||
			'		  ,BOS.ATTRIBUTE7                    "ATTRIBUTE7"								'||
			'		  ,BOS.ATTRIBUTE8                    "ATTRIBUTE8"								'||
			'		  ,BOS.ATTRIBUTE9                    "ATTRIBUTE9"								'||
			'		  ,BOS.ATTRIBUTE10                   "ATTRIBUTE10"								'||
			'		  ,BOS.ATTRIBUTE11                   "ATTRIBUTE11"								'||
			'		  ,BOS.ATTRIBUTE12                   "ATTRIBUTE12"								'||
			'		  ,BOS.ATTRIBUTE13                   "ATTRIBUTE13"								'||
			'		  ,BOS.ATTRIBUTE14                   "ATTRIBUTE14"								'||
			'		  ,BOS.ATTRIBUTE15                   "ATTRIBUTE15"								'||
			'		  ,BOS.REQUEST_ID                    "REQUEST ID"								'||
			'		  ,BOS.PROGRAM_APPLICATION_ID        "PROGRAM APPLICATION ID"							'||
			'		  ,BOS.PROGRAM_ID                    "PROGRAM ID"								'||
			'		  ,to_char(BOS.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"				'||
			'		  ,DECODE(MLU_OPT.MEANING,null,null,										'||
			'			(MLU_OPT.MEANING || '' ('' || BOS.OPERATION_TYPE || '')'')) "Operation Type"				'||
			'		  ,DECODE(BOS.REFERENCE_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',						'||
			'			''OTHER ('' || BOS.REFERENCE_FLAG || '')'') 		"Reference Flag"				'||
			'		  ,BOS.PROCESS_OP_SEQ_ID             "PROCESS OP SEQ ID"							'||
			'		  ,BOS.LINE_OP_SEQ_ID                "LINE OP SEQ ID"								'||
			'		  ,BOS.YIELD                         "YIELD"									'||
			'		  ,BOS.CUMULATIVE_YIELD              "CUMULATIVE YIELD"								'||
			'		  ,BOS.REVERSE_CUMULATIVE_YIELD      "REVERSE CUMULATIVE YIELD"							'||
			'		  ,BOS.LABOR_TIME_CALC               "LABOR TIME CALC"								'||
			'		  ,BOS.MACHINE_TIME_CALC             "MACHINE TIME CALC"							'||
			'		  ,BOS.TOTAL_TIME_CALC               "TOTAL TIME CALC"								'||
			'		  ,BOS.LABOR_TIME_USER               "LABOR TIME USER"								'||
			'		  ,BOS.MACHINE_TIME_USER             "MACHINE TIME USER"							'||
			'		  ,BOS.TOTAL_TIME_USER               "TOTAL TIME USER"								'||
			'		  ,BOS.NET_PLANNING_PERCENT          "NET PLANNING PERCENT "							'||
			'		  ,BOS.X_COORDINATE                  "X COORDINATE"								'||
			'		  ,BOS.Y_COORDINATE                  "Y COORDINATE"								'||
			'		  ,DECODE(BOS.INCLUDE_IN_ROLLUP,null,null,1,''Yes (1)'',2,''No (2)'',						'||
			'			''OTHER ('' || BOS.INCLUDE_IN_ROLLUP || '')'')  "INCLUDE IN ROLLUP"					'||
			'		  ,DECODE(BOS.OPERATION_YIELD_ENABLED,null,null,1,''Yes (1)'',2,''No (2)'',					'||
			'			''OTHER ('' || BOS.OPERATION_YIELD_ENABLED || '')'')    "OPERATION YIELD ENABLED"			'||
			'		  ,BOS.OLD_OPERATION_SEQUENCE_ID     "OLD OPERATION SEQUENCE ID"						'||
			'		  ,DECODE(BOS.ACD_TYPE,null,null,1,''Add (1)'',2,''Change (2)'',3,''Delete (3)'',				'||
			'			''OTHER ('' || BOS.ACD_TYPE || '')'')  "ACD TYPE"							'||
			'		  ,BOS.ORIGINAL_SYSTEM_REFERENCE     "ORIGINAL SYSTEM REFERENCE"						'||
			'		  ,BOS.CHANGE_NOTICE                 "CHANGE NOTICE"								'||
			'		  ,to_char(BOS.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE"				'||
			'		  ,DECODE(BOS.ECO_FOR_PRODUCTION,null,null,1,''Yes (1)'',2,''No (2)'',						'||
			'			''OTHER ('' || BOS.ECO_FOR_PRODUCTION || '')'')  "ECO FOR PRODUCTION "					'||
			'		  ,DECODE(MLU_SHT.MEANING,null,null,										'||
			'			(MLU_SHT.MEANING || '' ('' || BOS.SHUTDOWN_TYPE || '')''))  "SHUTDOWN TYPE"				'||
			'	          ,BOS.ACTUAL_IPK                    "ACTUAL IPK"								'||
			'		  ,BOS.CRITICAL_TO_QUALITY           "CRITICAL TO QUALITY"							'||
			'		  ,BOS.VALUE_ADDED                   "VALUE ADDED"								'||
			'		  ,BOS.MACHINE_PROCESS_EFFICIENCY    "MACHINE PROCESS EFFICIENCY"						'||
			'		  ,BOS.LABOR_PROCESS_EFFICIENCY      "LABOR PROCESS EFFICIENCY"							'||
			'		  ,BOS.TOTAL_PROCESS_EFFICIENCY      "TOTAL PROCESS EFFICIENCY"							'||
			'		  ,BOS.LONG_DESCRIPTION              "LONG DESCRIPTION"								'||
			'		  ,BOS.CONFIG_ROUTING_ID             "CONFIG ROUTING ID"							'||
			'		  ,BOS.MODEL_OP_SEQ_ID               "MODEL OP SEQ ID"							'||
			'		  ,BOS.LOWEST_ACCEPTABLE_YIELD               "LOWEST ACCEPTABLE YIELD"				'||
			'		  ,BOS.USE_ORG_SETTINGS               "USE ORG SETTINGS"							'||
			'		  ,BOS.QUEUE_MANDATORY_FLAG               "QUEUE MANDATORY FLAG"					'||
			'		  ,BOS.RUN_MANDATORY_FLAG               "RUN MANDATORY FLAG"						'||
			'		  ,BOS.TO_MOVE_MANDATORY_FLAG               "TO MOVE MANDATORY FLAG"				'||
			'		  ,BOS.SHOW_NEXT_OP_BY_DEFAULT               "SHOW NEXT OP BY DEFAULT"			'||
			'		  ,BOS.SHOW_SCRAP_CODE               "SHOW SCRAP CODE"							'||
			'		  ,BOS.SHOW_LOT_ATTRIB               "SHOW LOT ATTRIB"							'||
			'		  ,BOS.TRACK_MULTIPLE_RES_USAGE_DATES               "TRACK MULTIPLE RES USAGE DATES"	'||
			'	FROM   		 eng_revised_items eri											'||
			'			,bom_operation_sequences bos										'||
			'			,mtl_parameters	mp1											'||
			'			,MTL_ITEM_FLEXFIELDS MIF1										'||
			'			,MFG_LOOKUPS MLU_BCPT											'||
			'			,MFG_LOOKUPS MLU_OPT											'||
			'			,MFG_LOOKUPS MLU_SHT		  									'||
			'	WHERE		1=1													'||
			'	AND    		bos.revised_item_sequence_id = eri.revised_item_sequence_id						'||
			'	AND		eri.organization_id	= mp1.organization_id								'||
			'	AND	 	ERI.REVISED_ITEM_ID 	 = MIF1.INVENTORY_ITEM_ID							'||
			'	AND	 	ERI.ORGANIZATION_ID 	 = MIF1.ORGANIZATION_ID								'||
			'	AND  		bos.count_point_type=mlu_bcpt.lookup_code(+) and ''BOM_COUNT_POINT_TYPE''=mlu_bcpt.lookup_type(+)	'||
			'	AND  		bos.operation_type=mlu_opt.lookup_code(+) and ''BOM_OPERATION_TYPE''=mlu_opt.lookup_type(+)		'||
			'	AND  		bos.shutdown_type=mlu_sht.lookup_code(+) and ''BOM_EAM_SHUTDOWN_TYPE''=mlu_sht.lookup_type(+)		'||
			'	AND		eri.change_notice            =	'''||l_eco_name||'''							';

			if l_org_id is not null then
				sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
			end if;
			sqltxt :=sqltxt||' and rownum <   '||row_limit;
			sqltxt :=sqltxt||' order by mp1.organization_code,mif1.padded_item_number, '||
					 ' eri.revised_item_sequence_id, bos.operation_seq_num	    ';

			num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Revised Operations ');
			If (num_rows = row_limit -1 ) Then
				JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
			End If;
			statusStr:= 'SUCCESS';
			isFatal := 'FALSE';

	/* End of revised operations from Bom_Operation_Sequences */

	/* SQL to fetch resources on revised operations from bom_operation_resources table*/
		 sqltxt := ' SELECT ERI.CHANGE_NOTICE				"CHANGE NOTICE"							'||
		'	 	  ,MP1.ORGANIZATION_CODE		     	"ORGANIZATION CODE"						'||
		'		  ,ERI.ORGANIZATION_ID	     	     		"ORGANIZATION ID"					       '||
		'		  ,MIF1.PADDED_ITEM_NUMBER	     		"REVISED ITEM NUMBER"					       '||
		'		  ,ERI.REVISED_ITEM_ID	             		"REVISED ITEM ID"					       '||
		'		  ,ERI.REVISED_ITEM_SEQUENCE_ID			"REVISED ITEM SEQUENCE ID"				       '||
		'		  ,BOS.OPERATION_SEQ_NUM             		"OPERATION SEQ NUM"					       '||
		'		  ,BOS.OPERATION_SEQUENCE_ID        		"OPERATION SEQUENCE ID"					       '||
		'		  ,BOS.ROUTING_SEQUENCE_ID           		"ROUTING SEQUENCE ID"					       '||
		'		  ,BORE.OPERATION_SEQUENCE_ID            	"OPERATION SEQUENCE ID"					       '||
		'		  ,BORE.RESOURCE_SEQ_NUM                 	"RESOURCE SEQ NUM"					       '||
		'		  ,BR.RESOURCE_CODE				"RESOURCE CODE"						       '||
		'		  ,BORE.RESOURCE_ID                      	"RESOURCE ID"						       '||
		'		  ,BR.DESCRIPTION				"RESOURCE DESCRIPTION"					       '||
		'		  ,BORE.ACTIVITY_ID                      	"ACTIVITY ID"						       '||
		'		  ,DECODE(BORE.STANDARD_RATE_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',					       '||
		'			''OTHER ('' || BORE.STANDARD_RATE_FLAG || '')'')    "STANDARD RATE FLAG"			       '||
		'		  ,BORE.ASSIGNED_UNITS                   	"ASSIGNED UNITS"					       '||
		'		  ,BORE.USAGE_RATE_OR_AMOUNT             	"USAGE RATE OR AMOUNT"					       '||
		'		  ,BORE.USAGE_RATE_OR_AMOUNT_INVERSE     	"USAGE RATE OR AMOUNT INVERSE"				       '||
		'		  ,DECODE(MLU_BT.MEANING,null,null,									       '||
		'			(MLU_BT.MEANING || '' ('' || BORE.BASIS_TYPE || '')''))	"BASIS TYPE"				       '||
		'		  ,DECODE(MLU_SF.MEANING,null,null,									       '||
		'			(MLU_SF.MEANING || '' ('' || BORE.SCHEDULE_FLAG || '')''))  "SCHEDULE FLAG"			       '||
		'		  ,to_char(BORE.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')      "LAST UPDATE DATE"				'||
		'		  ,BORE.LAST_UPDATED_BY                  	"LAST UPDATED BY"					       '||
		'		  ,to_char(BORE.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')  "CREATION DATE"					'||
		'		  ,BORE.CREATED_BY                       	"CREATED BY"						       '||
		'		  ,BORE.LAST_UPDATE_LOGIN                	"LAST UPDATE LOGIN"					       '||
		'		  ,BORE.RESOURCE_OFFSET_PERCENT          	"RESOURCE OFFSET PERCENT"				       '||
		'		  ,DECODE(MLU_ACT.MEANING,null,null,									       '||
		'			(MLU_ACT.MEANING || '' ('' || BORE.AUTOCHARGE_TYPE || '')'')) "AUTOCHARGE TYPE"			       '||
		'		  ,BORE.ATTRIBUTE_CATEGORY               	"ATTRIBUTE CATEGORY"					       '||
		'		  ,BORE.ATTRIBUTE1                       	"ATTRIBUTE1"						       '||
		'		  ,BORE.ATTRIBUTE2                       	"ATTRIBUTE2"						       '||
		'		  ,BORE.ATTRIBUTE3                       	"ATTRIBUTE3"						       '||
		'		  ,BORE.ATTRIBUTE4                       	"ATTRIBUTE4"						       '||
		'		  ,BORE.ATTRIBUTE5                       	"ATTRIBUTE5"						       '||
		'		  ,BORE.ATTRIBUTE6                       	"ATTRIBUTE6"						       '||
		'		  ,BORE.ATTRIBUTE7                       	"ATTRIBUTE7"						       '||
		'		  ,BORE.ATTRIBUTE8                       	"ATTRIBUTE8"						       '||
		'		  ,BORE.ATTRIBUTE9                       	"ATTRIBUTE9"						       '||
		'		  ,BORE.ATTRIBUTE10                      	"ATTRIBUTE10"						       '||
		'		  ,BORE.ATTRIBUTE11                      	"ATTRIBUTE11"						       '||
		'		  ,BORE.ATTRIBUTE12                      	"ATTRIBUTE12"						       '||
		'		  ,BORE.ATTRIBUTE13                      	"ATTRIBUTE13"						       '||
		'		  ,BORE.ATTRIBUTE14                      	"ATTRIBUTE14"						       '||
		'		  ,BORE.ATTRIBUTE15                      	"ATTRIBUTE15"						       '||
		'		  ,BORE.REQUEST_ID                       	"REQUEST ID"						       '||
		'		  ,BORE.PROGRAM_APPLICATION_ID           	"PROGRAM APPLICATION ID"				       '||
		'		  ,BORE.PROGRAM_ID                       	"PROGRAM ID"						       '||
		'		  ,to_char(BORE.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"				'||
		'		  ,BORE.SCHEDULE_SEQ_NUM                 	"SCHEDULE SEQ NUM"					       '||
		'		  ,BORE.SUBSTITUTE_GROUP_NUM             	"SUBSTITUTE GROUP NUM"					       '||
		'		  ,DECODE(BORE.PRINCIPLE_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',					       '||
		'			''OTHER ('' || BORE.PRINCIPLE_FLAG || '')'')   	"PRINCIPLE FLAG"				       '||
		'		  ,BORE.SETUP_ID                         	"SETUP ID"						       '||
		'		  ,BORE.CHANGE_NOTICE                    	"CHANGE NOTICE"						       '||
		'		  ,DECODE(BORE.ACD_TYPE,null,null,1,''Add (1)'',2,''Change (2)'',3,''Delete (3)'',			       '||
		'			''OTHER ('' || BORE.ACD_TYPE || '')'')   	"ACD TYPE"					       '||
		'		  ,BORE.ORIGINAL_SYSTEM_REFERENCE        	"ORIGINAL SYSTEM REFERENCE"				       '||
		'	FROM   	  eng_revised_items eri											       '||
		'		, bom_operation_sequences bos										       '||
		'		, bom_operation_resources bore										       '||
		'		, bom_resources	br												'||
		'		, MTL_PARAMETERS MP1											       '||
		'		, MTL_ITEM_FLEXFIELDS MIF1										       '||
		'		, MFG_LOOKUPS MLU_BT, MFG_LOOKUPS MLU_SF								       '||
		'	 	, MFG_LOOKUPS MLU_ACT											       '||
		'	WHERE 	  1=1													       '||
		'	AND   	  bos.revised_item_sequence_id = eri.revised_item_sequence_id						       '||
		'	AND    	  bore.operation_sequence_id   = bos.operation_sequence_id						       '||
		'	AND	  eri.organization_id	= mp1.organization_id									'||
		'	AND	  ERI.REVISED_ITEM_ID 	 = MIF1.INVENTORY_ITEM_ID								'||
		'	AND	  ERI.ORGANIZATION_ID 	 = MIF1.ORGANIZATION_ID									'||
		'	AND 	  bore.resource_id	= br.resource_id									'||
		'	AND 	  BORE.BASIS_TYPE=MLU_BT.LOOKUP_CODE(+) AND ''CST_BASIS''=MLU_BT.LOOKUP_TYPE(+)				       '||
		'	AND 	  BORE.SCHEDULE_FLAG=MLU_SF.LOOKUP_CODE(+) AND ''BOM_RESOURCE_SCHEDULE_TYPE''=MLU_SF.LOOKUP_TYPE(+)	       '||
		'	AND 	  BORE.AUTOCHARGE_TYPE=MLU_ACT.LOOKUP_CODE(+) AND ''BOM_AUTOCHARGE_TYPE''=MLU_ACT.LOOKUP_TYPE(+)	       '||
		'	AND	  eri.change_notice            =	'''||l_eco_name||'''							';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by mp1.organization_code,mif1.padded_item_number, eri.revised_item_sequence_id,'||
				 ' bos.operation_seq_num, bore.resource_seq_num, br.resource_code ';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Resources on Eco Revised Operations ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of resources on revised operations  from bom_operation_resources table*/

	/* Fetch eco revisions from eng_change_order_revisions table*/
		 sqltxt := ' SELECT '||
			'	   ECOR.CHANGE_NOTICE	       		"CHANGE NOTICE"		 	'||
			'	  ,MP1.ORGANIZATION_CODE	     	"ORGANIZATION CODE"		'||
			'	  ,ECOR.ORGANIZATION_ID	       		"ORGANIZATION ID"		'||
			'	  ,ECOR.REVISION		       	"REVISION"			'||
			'	  ,ECOR.REVISION_ID		        "REVISION ID"			'||
			'	  ,to_char(ECOR.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE"	'||
			'	  ,ECOR.LAST_UPDATED_BY	       		"LAST UPDATED BY"		'||
			'	  ,to_char(ECOR.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE"	'||
			'	  ,ECOR.CREATED_BY		        "CREATED BY"			'||
			'	  ,ECOR.LAST_UPDATE_LOGIN	        "LAST UPDATE LOGIN"		'||
			'	  ,ECOR.COMMENTS		       	"COMMENTS"			'||
			'	  ,ECOR.ATTRIBUTE_CATEGORY	       "ATTRIBUTE CATEGORY"		'||
			'	  ,ECOR.ATTRIBUTE1		       "ATTRIBUTE1"			'||
			'	  ,ECOR.ATTRIBUTE2		       "ATTRIBUTE2"			'||
			'	  ,ECOR.ATTRIBUTE3		       "ATTRIBUTE3"			'||
			'	  ,ECOR.ATTRIBUTE4		       "ATTRIBUTE4"			'||
			'	  ,ECOR.ATTRIBUTE5		       "ATTRIBUTE5"			'||
			'	  ,ECOR.ATTRIBUTE6		       "ATTRIBUTE6"			'||
			'	  ,ECOR.ATTRIBUTE7		       "ATTRIBUTE7"			'||
			'	  ,ECOR.ATTRIBUTE8		       "ATTRIBUTE8"			'||
			'	  ,ECOR.ATTRIBUTE9		       "ATTRIBUTE9"			'||
			'	  ,ECOR.ATTRIBUTE10		       "ATTRIBUTE10"			'||
			'	  ,ECOR.ATTRIBUTE11		       "ATTRIBUTE11"			'||
			'	  ,ECOR.ATTRIBUTE12		       "ATTRIBUTE12"			'||
			'	  ,ECOR.ATTRIBUTE13		       "ATTRIBUTE13"			'||
			'	  ,ECOR.ATTRIBUTE14		       "ATTRIBUTE14"			'||
			'	  ,ECOR.ATTRIBUTE15		       "ATTRIBUTE15"			'||
			'	  ,ECOR.PROGRAM_APPLICATION_ID     	"PROGRAM APPLICATION ID"	'||
			'	  ,ECOR.PROGRAM_ID		       "PROGRAM ID"			'||
			'	  ,to_char(ECOR.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "PROGRAM UPDATE DATE"	'||
			'	  ,ECOR.REQUEST_ID		       "REQUEST ID"			'||
			'	  ,ECOR.ORIGINAL_SYSTEM_REFERENCE  	"ORIGINAL SYSTEM REFERENCE"	'||
			'	  ,ECOR.CHANGE_ID		       "CHANGE ID"			'||
			'	  ,to_char(ECOR.START_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "START DATE"	'||
			'	  ,to_char(ECOR.END_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "END DATE"	'||
			'	FROM   	 eng_change_order_revisions ecor				'||
			'		,mtl_parameters	mp1						'||
			'	WHERE 	1=1			 					'||
			'	AND	ecor.organization_id	= mp1.organization_id			'||
			'	AND     ecor.change_notice            =	'''||l_eco_name||'''		';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and ecor.organization_id =  '||l_org_id;
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by mp1.organization_code,ecor.revision		';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Revisions');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of eco revisions from eng_change_order_revisions table*/

	/* Fetch records from eco schedule history from eng_current_scheduled_dates table*/
		 sqltxt := '	SELECT	 									 '||
			'	 	 ECSD.CHANGE_NOTICE			"CHANGE NOTICE"			 '||
			'	 	,MP1.ORGANIZATION_CODE			"ORGANIZATION CODE"		 '||
			'	 	,ECSD.ORGANIZATION_ID			"ORGANIZATION ID"		 '||
			'	 	,MIF1.PADDED_ITEM_NUMBER		"REVISED ITEM NUMBER"		 '||
			'	 	,ECSD.REVISED_ITEM_ID			"REVISED ITEM ID"		 '||
			'	 	,to_char(ECSD.SCHEDULED_DATE,''DD-MON-YYYY HH24:MI:SS'') "SCHEDULED DATE"'||
			'	 	,to_char(ECSD.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE" '||
			'	 	,ECSD.LAST_UPDATED_BY			"LAST UPDATED BY"		 '||
			'	 	,to_char(ECSD.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE"	 '||
			'	 	,ECSD.CREATED_BY			"CREATED BY"			 '||
			'	 	,ECSD.LAST_UPDATE_LOGIN			"LAST UPDATE LOGIN"		 '||
			'	 	,ECSD.SCHEDULE_ID			"SCHEDULE ID"		  	 '||
			'	 	,ECSD.EMPLOYEE_ID			"EMPLOYEE ID"		  	 '||
			'	 	,ECSD.COMMENTS				"COMMENTS"			 '||
			'	 	,ECSD.REQUEST_ID			"REQUEST ID"			 '||
			'	 	,ECSD.PROGRAM_APPLICATION_ID		"PROGRAM APPLICATION ID"	 '||
			'	 	,ECSD.PROGRAM_ID			"PROGRAM ID"			 '||
			'	 	,to_char(ECSD.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE" '||
			'	 	,ECSD.REVISED_ITEM_SEQUENCE_ID		"REVISED ITEM SEQUENCE ID"	 '||
			'	 	,ECSD.ORIGINAL_SYSTEM_REFERENCE		"ORIGINAL SYSTEM REFERENCE"	 '||
			'	 	,ECSD.CHANGE_ID				"CHANGE ID"			 '||
			'	 	,ECSD.OLD_EMPLOYEE_ID			"OLD EMPLOYEE ID"		 '||
			'	 FROM  	 ENG_CURRENT_SCHEDULED_DATES ECSD 				 	 '||
			'	 		,MTL_PARAMETERS MP1						 '||
			'	 		,MTL_ITEM_FLEXFIELDS MIF1 					 '||
			'	 WHERE 	1=1		  							 '||
			'	 AND 	MP1.ORGANIZATION_ID  = ECSD.ORGANIZATION_ID				 '||
			'        AND 	ECSD.REVISED_ITEM_ID = MIF1.INVENTORY_ITEM_ID		    	 	 '||
			' 	 AND 	ECSD.ORGANIZATION_ID = MIF1.ORGANIZATION_ID 				 '||
			'	 AND    ecsd.change_notice            =	'''||l_eco_name||'''			';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and ecsd.organization_id =  '||l_org_id;
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by mp1.organization_code,			   '||
				 ' mif1.padded_item_number, ecsd.scheduled_date		   ';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Schedule History ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of eco schedule history from eng_current_scheduled_dates table*/


	/* SQL to fetch routing revisions of revised_items from mtl_rtg_item_revisions table*/
	sqltxt := '	SELECT   ERI.CHANGE_NOTICE		 "CHANGE NOTICE"		  '||
		'		,MP1.ORGANIZATION_CODE		"ORGANIZATION CODE"		  '||
		'		,ERI.ORGANIZATION_ID	     	"ORGANIZATION ID"		  '||
		'		,MIF1.PADDED_ITEM_NUMBER	"REVISED ITEM NUMBER"		  '||
		'		,ERI.REVISED_ITEM_ID	        "REVISED ITEM ID"		  '||
		'		,MRIR.REVISED_ITEM_SEQUENCE_ID   "REVISED ITEM SEQUENCE ID"	  '||
		'		,MRIR.PROCESS_REVISION		"PROCESS REVISION"	     	  '||
		'		,to_char(MRIR.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE" '||
		'		,MRIR.LAST_UPDATED_BY		"LAST UPDATED BY"	      	  '||
		'		,to_char(MRIR.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE"	'||
		'		,MRIR.CREATED_BY		"CREATED BY"		   	  '||
		'		,MRIR.LAST_UPDATE_LOGIN		"LAST UPDATE LOGIN"	   	  '||
		'		,MRIR.CHANGE_NOTICE		"CHANGE NOTICE"	      		  '||
		'		,to_char(MRIR.ECN_INITIATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"ECN INITIATION DATE"  	  '||
		'		,to_char(MRIR.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"IMPLEMENTATION DATE"  	  '||
		'		,MRIR.IMPLEMENTED_SERIAL_NUMBER	"IMPLEMENTED SERIAL NUMBER" 	  '||
		'		,to_char(MRIR.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVITY DATE"	 '||
		'		,MRIR.ATTRIBUTE_CATEGORY	"ATTRIBUTE CATEGORY"	     	  '||
		'		,MRIR.ATTRIBUTE1		"ATTRIBUTE1"		     	  '||
		'		,MRIR.ATTRIBUTE2		"ATTRIBUTE2"		     	  '||
		'		,MRIR.ATTRIBUTE3		"ATTRIBUTE3"		     	  '||
		'		,MRIR.ATTRIBUTE4		"ATTRIBUTE4"		     	  '||
		'		,MRIR.ATTRIBUTE5		"ATTRIBUTE5"		     	  '||
		'		,MRIR.ATTRIBUTE6		"ATTRIBUTE6"		     	  '||
		'		,MRIR.ATTRIBUTE7		"ATTRIBUTE7"		     	  '||
		'		,MRIR.ATTRIBUTE8		"ATTRIBUTE8"		     	  '||
		'		,MRIR.ATTRIBUTE9		"ATTRIBUTE9"		     	  '||
		'		,MRIR.ATTRIBUTE10		"ATTRIBUTE10"		     	  '||
		'		,MRIR.ATTRIBUTE11		"ATTRIBUTE11"		     	  '||
		'		,MRIR.ATTRIBUTE12		"ATTRIBUTE12"		     	  '||
		'		,MRIR.ATTRIBUTE13		"ATTRIBUTE13"		     	  '||
		'		,MRIR.ATTRIBUTE14		"ATTRIBUTE14"		     	  '||
		'		,MRIR.ATTRIBUTE15		"ATTRIBUTE15"		     	  '||
		'		,MRIR.REQUEST_ID		"REQUEST ID"		     	  '||
		'		,MRIR.PROGRAM_APPLICATION_ID	"PROGRAM APPLICATION ID"    	  '||
		'		,MRIR.PROGRAM_ID		"PROGRAM ID"		     	  '||
		'		,to_char(MRIR.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"PROGRAM UPDATE DATE" 	  '||
		'	from  	 eng_revised_items eri						  '||
		'		,mtl_rtg_item_revisions mrir					  '||
		'		,MTL_PARAMETERS MP1						  '||
		'		,MTL_ITEM_FLEXFIELDS MIF1					  '||
		'	where 	1=1								  '||
		'	and	mrir.inventory_item_id = eri.revised_item_id			  '||
		'	and   	mrir.organization_id = eri.organization_id			  '||
		'	and  	mrir.inventory_item_id=  mif1.inventory_item_id		     	  '||
		'	and  	mrir.organization_id =   mif1.organization_id		     	  '||
		'	and  	mif1.organization_id =   mp1.organization_id			  '||
		'	AND     eri.change_notice =		'''||l_eco_name||'''		 ';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by mp1.organization_code,mif1.padded_item_number,eri.revised_item_sequence_id,mrir.process_revision';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Routing Revisions of Revised Items');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of routing revisions of revised_items  */

	/* Start of Scripts to fetch ECO Workflow related data */

	/* Fetch details of the notifications fired from an eco */
		 sqltxt :='  SELECT    	'||
			'    WFI.ITEM_TYPE 	 	"Item Type" 		'||
			'   ,WFI.ITEM_KEY 		"Item Key" 		'||
			'   ,WFN.NOTIFICATION_ID 	"Notification Id" 	'||
			'   ,WFN.STATUS 		"Status" 		'||
			'   ,to_char(WFI.BEGIN_DATE,''DD-MON-YYYY HH24:MI:SS'')	"Begin Date" '||
			'    FROM  WF_ITEMS WFI,WF_NOTIFICATIONS WFN 		'||
			'    WHERE WFI.ITEM_KEY =substr(WFN.context,instr(WFN.context,'':'',1)+1, (instr(WFN.context,'':'',-1,1) - instr(WFN.context,'':'',1)-1)) '||
			'    AND   WFN.MESSAGE_TYPE = ''ECO_APP'' 		'||
			'    AND   WFI.ITEM_TYPE = ''ECO_APP'' 			';

		if l_org_id is not null then
		   sqltxt :=sqltxt||' AND SUBSTR(WFI.ITEM_KEY,1,(instr(WFI.ITEM_KEY,''-'',-1,1)-1)) = '''||l_eco_name||'-'||l_org_id||'''	 ';
		else
		   sqltxt :=sqltxt||' AND SUBSTR(WFI.ITEM_KEY,1,(instr(WFI.ITEM_KEY,''-'',-3,1)-1)) = '''||l_eco_name||'''  ';
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by WFI.ITEM_KEY, WFN.NOTIFICATION_ID,WFN.STATUS ';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Eco Workflow Notifications ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr := 'SUCCESS';
		isFatal := 'FALSE';

	/* End of details of the notifications fired from an eco */

	/* Fetch details of the notification results fired from an eco */
	 sqltxt :='  SELECT	'||
			'    WFNA.NAME 									"Name" 			'||
			'   ,WFNA.NUMBER_VALUE 				"Number Value"		'||
			'   ,WFNA.TEXT_VALUE 					"Text Value"		'||
			'   ,to_char(WFNA.DATE_VALUE,''DD-MON-YYYY HH24:MI:SS'') "Date Value"		'||
			'   ,WFI.ITEM_KEY 					"Item Key"		'||
			'   ,WFN.NOTIFICATION_ID 				"Notification Id"	'||
			'   ,WFN.GROUP_ID 					"Group Id"		'||
			'   ,WFN.MESSAGE_TYPE 					"Message Type"		'||
			'   ,WFN.MESSAGE_NAME 					"Message Name"		'||
			'   ,WFN.RECIPIENT_ROLE 				"Recipient Role"	'||
			'   ,WFN.STATUS 					"Status" 		'||
			'   ,WFN.ACCESS_KEY 					"Access Key" 		'||
			'   ,WFN.MAIL_STATUS 					"Mail Status" 		'||
			'   ,WFN.PRIORITY 					"Priority" 		'||
			'   ,to_char(WFN.BEGIN_DATE,''DD-MON-YYYY HH24:MI:SS'')	"Begin Date" 		'||
			'   ,to_char(WFN.END_DATE,''DD-MON-YYYY HH24:MI:SS'') 	"End Date" 		'||
			'   ,to_char(WFN.DUE_DATE,''DD-MON-YYYY HH24:MI:SS'') 	"Due Date" 		'||
			'   ,WFN.RESPONDER 					"Responder" 		'||
			'   ,WFN.USER_COMMENT 					"User Comment" 		'||
		        '   ,WFN.CALLBACK 					"Callback"		'||
			'   ,WFN.CONTEXT 					"Context"		'||
			'   ,WFN.ORIGINAL_RECIPIENT 				"Original Recipient"	'||
			'   ,WFN.FROM_USER 					"From User"		'||
			'   ,WFN.TO_USER 					"To User"		'||
			'   ,WFN.SUBJECT 					"Subject"		'||
			'   ,WFN.LANGUAGE 					"Language"		'||
			'   ,WFN.MORE_INFO_ROLE 				"More Info Role"	'||
			'   ,WFN.FROM_ROLE 					"From Role"		'||
			'   ,WFN.SECURITY_GROUP_ID 				"Security Group Id"	'||
			'   ,WFN.USER_KEY 						"User Key"	'||
			'   ,WFN.ITEM_KEY 						"Item Key"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE1		"Protected Text Attribute1"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE2		"Protected Text Attribute2"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE3		"Protected Text Attribute3"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE4		"Protected Text Attribute4"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE5		"Protected Text Attribute5"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE6		"Protected Text Attribute6"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE7		"Protected Text Attribute7"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE8		"Protected Text Attribute8"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE9		"Protected Text Attribute9"	'||
			'   ,WFN.PROTECTED_TEXT_ATTRIBUTE10		"Protected Text Attribute10"	'||
			'   ,WFN.PROTECTED_FORM_ATTRIBUTE1		"Protected Form Attribute1"	'||
			'   ,WFN.PROTECTED_FORM_ATTRIBUTE2		"Protected Form Attribute2"	'||
			'   ,WFN.PROTECTED_FORM_ATTRIBUTE3		"Protected Form Attribute3"	'||
			'   ,WFN.PROTECTED_FORM_ATTRIBUTE4		"Protected Form Attribute4"	'||
			'   ,WFN.PROTECTED_FORM_ATTRIBUTE5		"Protected Form Attribute5"	'||
			'   ,WFN.PROTECTED_URL_ATTRIBUTE1		"Protected Url Attribute1"	'||
			'   ,WFN.PROTECTED_URL_ATTRIBUTE2		"Protected Url Attribute2"	'||
			'   ,WFN.PROTECTED_URL_ATTRIBUTE3		"Protected Url Attribute3"	'||
			'   ,WFN.PROTECTED_URL_ATTRIBUTE4		"Protected Url Attribute4"	'||
			'   ,WFN.PROTECTED_URL_ATTRIBUTE5		"Protected Url Attribute5"	'||
			'   ,to_char(WFN.PROTECTED_DATE_ATTRIBUTE1,''DD-MON-YYYY HH24:MI:SS'')		"Protected Date Attribute1"	'||
			'   ,to_char(WFN.PROTECTED_DATE_ATTRIBUTE2,''DD-MON-YYYY HH24:MI:SS'')		"Protected Date Attribute2"	'||
			'   ,to_char(WFN.PROTECTED_DATE_ATTRIBUTE3,''DD-MON-YYYY HH24:MI:SS'')		"Protected Date Attribute3"	'||
			'   ,to_char(WFN.PROTECTED_DATE_ATTRIBUTE4,''DD-MON-YYYY HH24:MI:SS'')		"Protected Date Attribute4"	'||
			'   ,to_char(WFN.PROTECTED_DATE_ATTRIBUTE5,''DD-MON-YYYY HH24:MI:SS'')		"Protected Date Attribute5"	'||
			'   ,WFN.PROTECTED_NUMBER_ATTRIBUTE1		"Protected Number Attribute1"	'||
			'   ,WFN.PROTECTED_NUMBER_ATTRIBUTE2		"Protected Number Attribute2"	'||
			'   ,WFN.PROTECTED_NUMBER_ATTRIBUTE3		"Protected Number Attribute3"	'||
			'   ,WFN.PROTECTED_NUMBER_ATTRIBUTE4		"Protected Number Attribute4"	'||
			'   ,WFN.PROTECTED_NUMBER_ATTRIBUTE5		"Protected Number Attribute5"	'||
			'   ,WFN.TEXT_ATTRIBUTE1					"Text  Attribute1"				'||
			'   ,WFN.TEXT_ATTRIBUTE2					"Text  Attribute2"				'||
			'   ,WFN.TEXT_ATTRIBUTE3					"Text  Attribute3"				'||
			'   ,WFN.TEXT_ATTRIBUTE4					"Text  Attribute4"				'||
			'   ,WFN.TEXT_ATTRIBUTE5					"Text  Attribute5"				'||
			'   ,WFN.TEXT_ATTRIBUTE6					"Text  Attribute6"				'||
			'   ,WFN.TEXT_ATTRIBUTE7					"Text  Attribute7"				'||
			'   ,WFN.TEXT_ATTRIBUTE8					"Text  Attribute8"				'||
			'   ,WFN.TEXT_ATTRIBUTE9					"Text  Attribute9"				'||
			'   ,WFN.TEXT_ATTRIBUTE10					"Text  Attribute10"				'||
			'   ,WFN.FORM_ATTRIBUTE1					"Form  Attribute1"				'||
			'   ,WFN.FORM_ATTRIBUTE2					"Form  Attribute2"				'||
			'   ,WFN.FORM_ATTRIBUTE3					"Form  Attribute3"				'||
			'   ,WFN.FORM_ATTRIBUTE4					"Form  Attribute4"				'||
			'   ,WFN.FORM_ATTRIBUTE5					"Form  Attribute5"				'||
			'   ,WFN.URL_ATTRIBUTE1	 					"URL  Attribute1"				'||
			'   ,WFN.URL_ATTRIBUTE2	 					"URL  Attribute2"				'||
			'   ,WFN.URL_ATTRIBUTE3	 					"URL  Attribute3"				'||
			'   ,WFN.URL_ATTRIBUTE4	 					"URL  Attribute4"				'||
			'   ,WFN.URL_ATTRIBUTE5	 					"URL  Attribute5"				'||
			'   ,to_char(WFN.DATE_ATTRIBUTE1,''DD-MON-YYYY HH24:MI:SS'') 					"Date  Attribute1"				'||
			'   ,to_char(WFN.DATE_ATTRIBUTE2,''DD-MON-YYYY HH24:MI:SS'') 					"Date  Attribute2"				'||
			'   ,to_char(WFN.DATE_ATTRIBUTE3,''DD-MON-YYYY HH24:MI:SS'') 					"Date  Attribute3"				'||
			'   ,to_char(WFN.DATE_ATTRIBUTE4,''DD-MON-YYYY HH24:MI:SS'') 					"Date  Attribute4"				'||
			'   ,to_char(WFN.DATE_ATTRIBUTE5,''DD-MON-YYYY HH24:MI:SS'') 					"Date  Attribute5"				'||
			'   ,WFN.NUMBER_ATTRIBUTE1 					"Number  Attribute1"			'||
			'   ,WFN.NUMBER_ATTRIBUTE2 					"Number  Attribute2"			'||
			'   ,WFN.NUMBER_ATTRIBUTE3 					"Number  Attribute3"			'||
			'   ,WFN.NUMBER_ATTRIBUTE4 					"Number  Attribute4"			'||
			'   ,WFN.NUMBER_ATTRIBUTE5 					"Number  Attribute5"			'||
			'    FROM									'||
			'    WF_NOTIFICATIONS WFN							'||
			'   ,WF_NOTIFICATION_ATTRIBUTES WFNA						'||
			'   ,WF_ITEMS WFI								'||
			'    WHERE									'||
			'    WFI.ITEM_KEY = substr(WFN.context,instr(WFN.context,'':'',1)+1, (instr(WFN.context,'':'',-1,1) - instr(WFN.context,'':'',1)-1)) '||
			'    AND 									'||
			'    WFN.MESSAGE_TYPE = ''ECO_APP''						'||
		        '    AND 									'||
			'    WFI.ITEM_TYPE  = ''ECO_APP''						'||
			'    AND 									'||
			'    WFN.notification_id = WFNA.notification_id					'||
			'    AND 									'||
			'    WFNA.name = ''RESULT''							';

		if l_org_id is not null then
		   sqltxt :=sqltxt||' AND SUBSTR(WFI.ITEM_KEY,1,(instr(WFI.ITEM_KEY,''-'',-1,1)-1)) = '''||l_eco_name||'-'||l_org_id||''' ';
		else
		   sqltxt :=sqltxt||' AND SUBSTR(WFI.ITEM_KEY,1,(instr(WFI.ITEM_KEY,''-'',-3,1)-1)) = '''||l_eco_name||'''  ';
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by WFI.ITEM_KEY, WFN.NOTIFICATION_ID,WFN.STATUS ';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Eco Workflow Notification Results ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr := 'SUCCESS';
		isFatal := 'FALSE';


	/* End of details of the notification results fired from an eco */

	/* Fetch records from eng_ecn_approvers_v  view about the ECO Approvers .*/
		 sqltxt :=' SELECT '||
			'    EECV.CHANGE_NOTICE			"CHANGE NOTICE",		'||
			'    MP1.ORGANIZATION_CODE		"ORGANIZATION CODE",		'||
			'    EECV.ORGANIZATION_ID		"ORGANIZATION ID",		'||
			'    EEAL.APPROVAL_LIST_NAME		"APPROVAL LIST NAME",		'||
			'    EEAL.APPROVAL_LIST_ID		"APPROVAL LIST ID",		'||
			'    EEAL.DESCRIPTION			"DESCRIPTION (List)",		'||
			'    to_char(EEAL.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'') "DISABLE DATE (List)", '||
			'    EEAV.APPROVER_NAME			"APPROVER NAME",		'||
			'    EEAV.SEQUENCE1			"SEQUENCE1",			'||
			'    EEAV.SEQUENCE2			"SEQUENCE2",			'||
			'    EEAV.DESCRIPTION			"DESCRIPTION (Approver)",	'||
			'    to_char(EEAV.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'') "DISABLE DATE (Approver)",'||
			'    EEAV.EMPLOYEE_ID			"EMPLOYEE ID"			'||
			'    from   eng_engineering_changes_v eecv,				'||
			'	    eng_ecn_approval_lists eeal, eng_ecn_approvers_v eeav,	'||
			'	    mtl_parameters mp1						'||
			'    where  eecv.approval_list_id=eeal.approval_list_id			'||
			'    and    eeal.approval_list_id=eeav.approval_list_id			'||
			'    and    eecv.organization_id = mp1.organization_id			'||
			'    and    eecv.change_notice='''||l_eco_name||'''			';

			if l_org_id is not null then
				sqltxt :=sqltxt||' and eecv.organization_id =  '||l_org_id;
			end if;
		 sqltxt :=sqltxt||' and rownum <   '||row_limit;
		 sqltxt :=sqltxt||' order by mp1.organization_code, eeal.approval_list_name,	'||
				  ' eeav.approver_name	';

		 num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Approvers ');
		 If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		 End If;
		 statusStr:= 'SUCCESS';
		 isFatal := 'FALSE';

	/* End of records from eng_ecn_approvers_v  view about the ECO Approvers .*/

	/* Fetch records from wf_roles table about the ECO Approvers Roles.*/
		 sqltxt :=' SELECT '||
			'     EECV.CHANGE_NOTICE		"CHANGE NOTICE"			'||
			'    ,MP1.ORGANIZATION_CODE		"ORGANIZATION CODE"		'||
			'    ,EECV.ORGANIZATION_ID		"ORGANIZATION ID"		'||
			'    ,EECV.APPROVAL_LIST_NAME		"APPROVAL LIST NAME"		'||
			'    ,EECV.APPROVAL_LIST_ID		"APPROVAL LIST ID"		'||
			'    ,WFR.NAME				"ROLE NAME"			'||
			'    ,WFR.DISPLAY_NAME			"DISPLAY NAME"			'||
			'    ,WFR.DESCRIPTION			"DESCRIPTION"			'||
			'    ,WFR.NOTIFICATION_PREFERENCE	"NOTIFICATION PREFERENCE"	'||
			'    ,WFR.LANGUAGE			"LANGUAGE"			'||
			'    ,WFR.TERRITORY			"TERRITORY"			'||
			'    ,WFR.EMAIL_ADDRESS			"EMAIL ADDRESS"			'||
			'    ,WFR.FAX				"FAX"				'||
			'    ,WFR.ORIG_SYSTEM			"ORIG SYSTEM"			'||
			'    ,WFR.ORIG_SYSTEM_ID		"ORIG SYSTEM ID"		'||
			'    ,to_char(WFR.START_DATE,''DD-MON-YYYY HH24:MI:SS'') "START DATE"	'||
			'    ,WFR.STATUS			"STATUS"			'||
			'    ,to_char(WFR.EXPIRATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "EXPIRATION DATE"	'||
			'    ,WFR.PARTITION_ID			"PARTITION ID"			'||
			'    from   eng_engineering_changes_v eecv,				'||
			'	    eng_ecn_approval_lists eeal, wf_roles wfr,			'||
			'	    mtl_parameters mp1						'||
			'    where  eecv.approval_list_id=eeal.approval_list_id			'||
			'    and    eeal.approval_list_id=wfr.orig_system_id			'||
			'    and    wfr.orig_system=''ENG_LIST''				'||
			'    and    eecv.organization_id = mp1.organization_id			'||
			'    and    eecv.change_notice='''||l_eco_name||'''			';

			if l_org_id is not null then
				sqltxt :=sqltxt||' and eecv.organization_id =  '||l_org_id;
			end if;
		 sqltxt :=sqltxt||' and rownum <   '||row_limit;
		 sqltxt :=sqltxt||' order by mp1.organization_code, wfr.display_name	';

		 num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Workflow Approver Roles (from wf_roles view) ');
		 If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		 End If;
		 statusStr:= 'SUCCESS';
		 isFatal := 'FALSE';

	/* End of records from wf_roles table about the ECO Approvers Roles*/


	/* Fetch records from wf_users table about the ECO Approvers (users on an approval list).*/
		 sqltxt :=' SELECT '||
			'     EECV.CHANGE_NOTICE		"CHANGE NOTICE"			'||
			'    ,MP1.ORGANIZATION_CODE		"ORGANIZATION CODE"		'||
			'    ,EECV.ORGANIZATION_ID		"ORGANIZATION ID"		'||
			'    ,EECV.APPROVAL_LIST_NAME		"APPROVAL LIST NAME"		'||
			'    ,EECV.APPROVAL_LIST_ID		"APPROVAL LIST ID"		'||
			'    ,WFU.NAME				"USER NAME"			'||
			'    ,WFU.DISPLAY_NAME			"DISPLAY NAME"			'||
			'    ,WFU.DESCRIPTION			"DESCRIPTION"			'||
			'    ,WFU.NOTIFICATION_PREFERENCE	"NOTIFICATION PREFERENCE"	'||
			'    ,WFU.LANGUAGE			"LANGUAGE"			'||
			'    ,WFU.TERRITORY			"TERRITORY"			'||
			'    ,WFU.EMAIL_ADDRESS			"EMAIL ADDRESS"			'||
			'    ,WFU.FAX				"FAX"				'||
			'    ,WFU.ORIG_SYSTEM			"ORIG SYSTEM"			'||
			'    ,WFU.ORIG_SYSTEM_ID		"ORIG SYSTEM ID"		'||
			'    ,to_char(WFU.START_DATE,''DD-MON-YYYY HH24:MI:SS'')"START DATE"	'||
			'    ,WFU.STATUS			"STATUS"			'||
			'    ,to_char(WFU.EXPIRATION_DATE,''DD-MON-YYYY HH24:MI:SS'')"EXPIRATION DATE"	'||
			'    ,WFU.PARTITION_ID			"PARTITION ID"			'||
			'    from   eng_engineering_changes_v eecv,				'||
			'	    eng_ecn_approvers_v eea , wf_users wfu,			'||
			'	    mtl_parameters mp1						'||
			'    where  eecv.approval_list_id=eea.approval_list_id			'||
			'    and    eea.employee_id=wfu.orig_system_id				'||
			'    and    eecv.organization_id = mp1.organization_id			'||
			'    and    eecv.change_notice='''||l_eco_name||'''			';

			if l_org_id is not null then
				sqltxt :=sqltxt||' and eecv.organization_id =  '||l_org_id;
			end if;
		 sqltxt :=sqltxt||' and rownum <   '||row_limit;
		 sqltxt :=sqltxt||' order by mp1.organization_code, wfu.display_name	';

		 num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Workflow Approvers  (from wf_users view) ');
		 If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		 End If;
		 statusStr:= 'SUCCESS';
		 isFatal := 'FALSE';
	/* End of records from wf_users table about the ECO Approvers.*/


	/* Fetch records from wf_user_roles table about the association between users and roles (users on an approval list).*/
		 sqltxt :=' SELECT '||
			'     EECV.CHANGE_NOTICE		"CHANGE NOTICE"			'||
			'    ,MP1.ORGANIZATION_CODE		"ORGANIZATION CODE"		'||
			'    ,EECV.ORGANIZATION_ID		"ORGANIZATION ID"		'||
			'    ,EECV.APPROVAL_LIST_NAME		"APPROVAL LIST NAME"		'||
			'    ,EECV.APPROVAL_LIST_ID		"APPROVAL LIST ID"		'||
			'    ,EEAV.APPROVER_NAME		"APPROVER NAME"			'||
			'    ,WFUR.USER_NAME			"USER NAME"			'||
			'    ,WFUR.ROLE_NAME			"ROLE NAME"			'||
			'    ,WFUR.USER_ORIG_SYSTEM		"USER ORIG SYSTEM"		'||
			'    ,WFUR.USER_ORIG_SYSTEM_ID		"USER ORIG SYSTEM ID"		'||
			'    ,WFUR.ROLE_ORIG_SYSTEM		"ROLE ORIG SYSTEM"		'||
			'    ,WFUR.ROLE_ORIG_SYSTEM_ID		"ROLE ORIG SYSTEM ID"		'||
			'    ,to_char(WFUR.START_DATE,''DD-MON-YYYY HH24:MI:SS'') "START DATE"	'||
			'    ,to_char(WFUR.EXPIRATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "EXPIRATION DATE"'||
			'    ,WFUR.PARTITION_ID					"PARTITION ID"		'||
			'    ,WFUR.ASSIGNMENT_REASON		"ASSIGNMENT REASON"		'||
			'from   wf_user_roles wfur, eng_ecn_approvers_v eeav,			'||
			'	eng_engineering_changes_v eecv,					'||
			'	    mtl_parameters mp1						'||
			'where  wfur.user_orig_system_id=eeav.employee_id			'||
			'and    wfur.role_orig_system_id=eeav.approval_list_id			'||
			'and    wfur.role_orig_system=''ENG_LIST''				'||
			'and    eeav.approval_list_id= eecv.approval_list_id			'||
			'and    eecv.organization_id = mp1.organization_id			'||
			'and    eecv.change_notice='''||l_eco_name||'''				';

			if l_org_id is not null then
				sqltxt :=sqltxt||' and eecv.organization_id =  '||l_org_id;
			end if;
		 sqltxt :=sqltxt||' and rownum <   '||row_limit;
		 sqltxt :=sqltxt||' order by mp1.organization_code, wfur.user_name, wfur.role_name ';

		 num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Association between WF Users, Roles(from wf_user_roles view) ');
		 If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		 End If;
		 statusStr:= 'SUCCESS';
		 isFatal := 'FALSE';
	/* End of records from wf_user_roles table */


	/* SQL to fetch organization hierarchy structure*/
	sqltxt := ' SELECT EEC.CHANGE_NOTICE			"CHANGE NOTICE"				'||
		'	,MP1.ORGANIZATION_CODE			"ORGANIZATION CODE"			'||
		'	,EEC.ORGANIZATION_ID	     		"ORGANIZATION ID"			'||
	  	'	,OS.NAME	  	 		"Org Hierarchy Name"			'||
		'	,OSV.VERSION_NUMBER	 	  	"Version Number"			'||
		'	,to_char(OSV.DATE_FROM,''DD-MON-YYYY HH24:MI:SS'') "Date From"			'||
		'	,to_char(OSV.DATE_TO,''DD-MON-YYYY HH24:MI:SS'') "Date To"			'||
		'	,OSE.D_PARENT_NAME			"D Parent Name"				'||
		'	,OSE.D_CHILD_NAME			"D Child Name"				'||
		'	,OSE.ORGANIZATION_ID_PARENT		"Organization Id Parent"		'||
		'	,OSE.ORGANIZATION_ID_CHILD		"Organization Id Child"			'||
		'	,OSE.BUSINESS_GROUP_ID			"Business Group Id"			'||
		'	,OSE.ORG_STRUCTURE_ELEMENT_ID		"Org Structure Element Id"		'||
		'	,OSE.ORG_STRUCTURE_VERSION_ID		"Org Structure Version Id"		'||
		'	,OSE.POSITION_CONTROL_ENABLED_FLAG 	"Position Control Enabled Flag" 	'||
		'	FROM PER_ORGANIZATION_STRUCTURES OS						'||
		'	    ,PER_ORG_STRUCTURE_VERSIONS OSV						'||
		'	    ,PER_ORG_STRUCTURE_ELEMENTS_V OSE						'||
		'	    ,ENG_ENGINEERING_CHANGES     EEC						'||
		'	    ,mtl_parameters mp1								'||
		'	WHERE 1=1									'||
		'	AND OS.ORGANIZATION_STRUCTURE_ID = OSV.ORGANIZATION_STRUCTURE_ID		'||
		'	AND  OSV.ORG_STRUCTURE_VERSION_ID = OSE.ORG_STRUCTURE_VERSION_ID		'||
		'	AND  OS.NAME = EEC.ORGANIZATION_HIERARCHY 					'||
		'	AND  eec.organization_id = mp1.organization_id					'||
	        '       AND  eec.change_notice    =	'''||l_eco_name||'''				';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eec.organization_id =  '||l_org_id;
		end if;
		sqltxt :=sqltxt||' and rownum <   '||row_limit;
   		sqltxt :=sqltxt||' order by mp1.organization_code, osv.version_number,ose.d_child_name';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Organization Hierarchy Structure ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of SQL to fetch organization hierarchy structure*/

	/* SQL to fetch use_up details of revised items*/
	sqltxt :='	SELECT 	MP.ORGANIZATION_CODE 		  		"Org Code"			'||
		'		,MBP.ITEM 					"Item"				'||
		'		,MBP.PLAN_NAME 				  	"Plan Name"			'||
		'		,to_char(MBP.COMPLETION_DATE,''DD-MON-YYYY HH24:MI:SS'') "Completion Date"	'||
		'		,to_char(MBP.USE_UP_DATE,''DD-MON-YYYY HH24:MI:SS'') "Use Up Date"		'||
		'		,MBP.ITEM_ID					"Item Id"			'||
		'		,MBP.ORGANIZATION_ID				"Org Id"			'||
		'	FROM   	MRP_BOM_PLAN_NAME_LOV_V MBP							'||
		'		,MTL_PARAMETERS MP								'||
		'	WHERE MBP.ORGANIZATION_ID = MP.ORGANIZATION_ID(+)					'||
		'	AND ( MBP.Organization_Id, MBP.Item_Id) in						'||
		'		(										'||
		'		 SELECT  eri.organization_id, BCB.component_item_id				'||
		'		 FROM    eng_revised_items eri							'||
		'			,bom_inventory_components BCB						'||
		'		 WHERE 	1=1									'||
		'		 AND	eri.bill_sequence_id = BCB.bill_sequence_id				'||
		'		 AND	nvl(BCB.acd_type,1) != 3						'||
		'		 AND	trunc(BCB.effectivity_date) <= mbp.use_up_date				'||
		'		 AND	nvl(BCB.disable_date, mbp.use_up_date + 1) > mbp.use_up_date		'||
		'		 AND	BCB.implementation_date is NOT NULL					'||
		'		 AND	eri.change_notice = 	'''||l_eco_name||'''				';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
		end if;


	sqltxt :=sqltxt||' UNION										'||
		'		 SELECT eri.organization_id, bbom.assembly_item_id				'||
		'		 FROM 	eng_revised_items eri							'||
		'			,bom_bill_of_materials bbom						'||
		'		 WHERE	1=1   									'||
		'		 AND	eri.revised_item_id = bbom.assembly_item_id				'||
		'		 AND	eri.organization_id = bbom.organization_id				'||
		'		 AND	eri.bill_sequence_id= bbom.bill_sequence_id				'||
		'		 AND	eri.change_notice = 	'''||l_eco_name||'''				';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
		end if;

	sqltxt :=sqltxt||' )and rownum <   '||row_limit||
		'	order by mp.organization_code, mbp.item, mbp.plan_name, mbp.use_up_date			';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Eco Revised Items Use Up Details ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';
	/* End of SQL to fetch use_up details of revised items*/

 <<l_test_end>>
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/>This data collection script completed as expected <BR/>');
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

 Elsif l_mco_exists =1 Then /* run these scripts if the MCO is exists */

 	/* SQL to fetch mass change order details */
	/* Get the application installation info. References to Data Dictionary Objects without schema name
	included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
	as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

	l_ret_status :=      fnd_installation.get_app_info ('ENG'
		                           , l_status
			                   , l_industry
				           , l_oracle_schema
					    );
	/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

	sqltxt :='SELECT											'||
	'		 EECIV.CHANGE_NOTICE 			"Mass Change Number"				'||
	'		,MP.ORGANIZATION_CODE 			"Org Code"					'||
	'		,EECIV.ORGANIZATION_ID			"Org Id"					'||
	'		,EECIV.CHANGE_ORDER_TYPE 		"Change Order Type"				'||
	'		,EECIV.DESCRIPTION 			"Description"					'||
	'		,DECODE(ERIIV.INCREMENT_REV,null,null,1,''Yes (1)'',2,''No (2)'',			'||
	'			''OTHER ('' || ERIIV.INCREMENT_REV || '')'') "Increment Rev"			'||
	'		,ERIIV.FROM_END_ITEM_UNIT_NUMBER 	"From End Item Unit Number"			'||
	'		,DECODE(ERIIV.UPDATE_WIP,null,null,1,''Yes (1)'',2,''No (2)'',				'||
	'			''OTHER ('' || ERIIV.UPDATE_WIP || '')'') "Update Wip"				'||
	'		,ERIIV.CATEGORY_SET_NAME 		"Category Set Name"				'||
	'		,ERIIV.CATEGORY_FROM 			"Category From"					'||
	'		,ERIIV.CATEGORY_TO 			"Category To"					'||
	'		,ERIIV.ITEM_FROM 			"Item From"					'||
	'		,ERIIV.ITEM_TO 				"Item To"					'||
	'		,ERIIV.ALTERNATE_SELECTION_CODE 	"Alternate Selection Code"			'||
	'		,ERIIV.ALTERNATE_BOM_DESIGNATOR 	"Alternate Bom Designator"			'||
	'		,ERIIV.BASE_ITEM_ID 			"Base Item Id"					'||
	'		,ERIIV.ITEM_TYPE 			"Item Type"					'||
	'		,ERIIV.ORGANIZATION_ID 			"Org Id"					'||
	'		,to_char(ERIIV.SCHEDULED_DATE,''DD-MON-YYYY HH24:MI:SS'') "Scheduled Date"		'||
	'		,DECODE(ERIIV.MRP_ACTIVE,null,null,1,''Yes (1)'',2,''No (2)'',				'||
	'			''OTHER ('' || ERIIV.MRP_ACTIVE || '')'') "Mrp Active"				'||
	'		,DECODE(ERIIV.USE_UP,null,null,1,''Yes (1)'',2,''No (2)'',				'||
	'			''OTHER ('' || ERIIV.USE_UP || '')'') "Use Up"					'||
	'		,ERIIV.USE_UP_ITEM_ID "Use Up Item Id"							'||
	'		,ERIIV.REVISED_ITEM_SEQUENCE_ID 	"Revised Item Sequence Id"			'||
	'		,ERIIV.CATEGORY_SET_ID 			"Category Set Id"				'||
	'		,ERIIV.STRUCTURE_ID 			"Structure Id"					'||
	'		,ERIIV.DDF_CONTEXT 			"Ddf Context"					'||
	'		,ERIIV.USE_UP_PLAN_NAME 		"Use Up Plan Name"				'||
	'		,ERIIV.USE_UP_ITEM_DESCRIPTION 		"Use Up Item Description"			'||
	'		,ERIIV.BASE_DESCRIPTION 		"Base Description"				'||
	'		,ERIIV.ITEM_TYPE_NAME 			"Item Type Name"				'||
	'		,to_char(ERIIV.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "Last Update Date"		'||
	'		,ERIIV.LAST_UPDATED_BY 			"Last Updated By"				'||
	'		,to_char(ERIIV.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "Creation Date"		'||
	'		,ERIIV.CREATED_BY 			"Created By"					'||
	'		,ERIIV.LAST_UPDATE_LOGIN 		"Last Update Login"				'||
	'	FROM												'||
	'		 ENG_ENG_CHANGES_INTERFACE_V EECIV							'||
	'		,ENG_REVISED_ITEMS_INTERFACE_V ERIIV							'||
	'		,MTL_PARAMETERS MP									'||
	'	WHERE												'||
	'		EECIV.CHANGE_NOTICE =  ERIIV.CHANGE_NOTICE						'||
	'	AND	EECIV.ORGANIZATION_ID = ERIIV.ORGANIZATION_ID						'||
	'	AND	EECIV.ORGANIZATION_ID = MP.ORGANIZATION_ID						'||
	'	AND	EECIV.change_notice = 	'''||l_eco_name||'''						';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eeciv.organization_id =  '||l_org_id;
		end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit||
		'	order by mp.organization_code	';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Mass Change Orders ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of SQL to fetch mass change order details */

	/* SQL to fetch component changes on mass change orders */
	sqltxt :='SELECT												'||
	'		 ERI.CHANGE_NOTICE "Mass Change Number"								'||
	'		,MP.ORGANIZATION_CODE "Org Code"								'||
	'		,ERI.ORGANIZATION_ID "Org Id"									   '||
	'		,MIF.ITEM_NUMBER "Item"										   '||
	'		,BICO.OPERATION_SEQ_NUM "Operation Seq Num"							   '||
	'		,BICO.COMPONENT_ITEM_ID "Component Item Id"							   '||
	'		,BICO.ITEM_NUM "Item Num"									   '||
	'		,BICO.COMPONENT_QUANTITY "Component Qty"							   '||
	'		,BICO.COMPONENT_YIELD_FACTOR "Component Yield Factor"						   '||
	'		,to_char(BICO.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'') "Disable Date"				   '||
	'		,BICO.PLANNING_FACTOR "Planning Factor"								   '||
	'		,DECODE(BICO.QUANTITY_RELATED,null,null,1,''Yes (1)'',2,''No (2)'',				   '||
	'			''OTHER ('' || BICO.QUANTITY_RELATED || '')'') "Qty Related"				   '||
	'		,BICO.SO_BASIS "So Basis"									   '||
	'		,DECODE(BICO.OPTIONAL,null,null,1,''Yes (1)'',2,''No (2)'',					   '||
	'			''OTHER ('' || BICO.OPTIONAL || '')'') "Optional"					   '||
	'		,DECODE(BICO.MUTUALLY_EXCLUSIVE_OPTIONS,null,null,1,''Yes (1)'',2,''No (2)'',			   '||
	'			''OTHER ('' || BICO.MUTUALLY_EXCLUSIVE_OPTIONS || '')'') "Mutually Exclusive Options"	   '||
	'		,DECODE(BICO.INCLUDE_IN_COST_ROLLUP,null,null,1,''Yes (1)'',2,''No (2)'',			   '||
	'			''OTHER ('' || BICO.INCLUDE_IN_COST_ROLLUP || '')'') "Include In Cost Rollup"		   '||
	'		,DECODE(BICO.CHECK_ATP,null,null,1,''Yes (1)'',2,''No (2)'',					   '||
	'			''OTHER ('' || BICO.CHECK_ATP || '')'') "Check Atp"					   '||
	'		,DECODE(BICO.SHIPPING_ALLOWED,null,null,1,''Yes (1)'',2,''No (2)'',				   '||
	'			''OTHER ('' || BICO.SHIPPING_ALLOWED || '')'') "Shipping Allowed"			   '||
	'		,DECODE(BICO.REQUIRED_TO_SHIP,null,null,1,''Yes (1)'',2,''No (2)'',				   '||
	'			''OTHER ('' || BICO.REQUIRED_TO_SHIP || '')'') "Required To Ship"			   '||
	'		,DECODE(BICO.REQUIRED_FOR_REVENUE,null,null,1,''Yes (1)'',2,''No (2)'',				   '||
	'			''OTHER ('' || BICO.REQUIRED_FOR_REVENUE || '')'') "Required For Revenue"		   '||
	'		,DECODE(BICO.INCLUDE_ON_SHIP_DOCS,null,null,1,''Yes (1)'',2,''No (2)'',				   '||
	'			''OTHER ('' || BICO.INCLUDE_ON_SHIP_DOCS || '')'') "Include On Ship Docs"		   '||
	'		,DECODE(BICO.INCLUDE_ON_BILL_DOCS,null,null,1,''Yes (1)'',2,''No (2)'',				   '||
	'			''OTHER ('' || BICO.INCLUDE_ON_BILL_DOCS || '')'') "Include On Bill Docs"		   '||
	'		,BICO.LOW_QUANTITY "Low Qty"									   '||
	'		,BICO.HIGH_QUANTITY "High Qty"									   '||
	'		,DECODE(BICO.ACD_TYPE,null,null,1,''Add (1)'',2,''Change (2)'',3,''Delete (3)'',		   '||
	'			''Other ('' || BICO.ACD_TYPE || '')'') "Acd Type"					   '||
	'		,BICO.OLD_COMPONENT_SEQUENCE_ID "Old Component Sequence Id"					   '||
	'		,BICO.COMPONENT_SEQUENCE_ID "Component Sequence Id"						   '||
	'		,BICO.WIP_SUPPLY_TYPE "Wip Supply Type"								   '||
	'		,BICO.SUPPLY_SUBINVENTORY "Supply Subinv"							   '||
	'		,BICO.SUPPLY_LOCATOR_ID "Supply Locator Id"							   '||
	'		,BICO.REVISED_ITEM_SEQUENCE_ID "Revised Item Sequence Id"					   '||
	'		,BICO.COST_FACTOR "Cost Factor"									   '||
	'		,BICO.DDF_CONTEXT1 "Ddf Context1"								   '||
	'		,BICO.DDF_CONTEXT2 "Ddf Context2"								   '||
	'		,BICO.DESCRIPTION "Description"									   '||
	'		,BICO.PRIMARY_UOM_CODE "Primary Uom Code"							   '||
	'		,DECODE(MLU_BIT.MEANING,null,null,								   '||
	' 			(MLU_BIT.MEANING || '' ('' || BICO.BOM_ITEM_TYPE || '')'')) "BOM ITEM TYPE"		   '||
	'		,BICO.ATP_COMPONENTS_FLAG "Atp Components Flag"							   '||
	'		,BICO.REPLENISH_TO_ORDER_FLAG "Replenish To Order Flag"						   '||
	'		,BICO.DEFAULT_SHIPPABLE "Default Shippable"							   '||
	'		,BICO.DEFAULT_COST_ROLLUP "Default Cost Rollup"							   '||
	'		,BICO.DEFAULT_WIP_SUPPLY_TYPE "Default Wip Supply Type"						   '||
	'		,BICO.DEFAULT_SUPPLY_LOCATOR_ID "Default Supply Locator Id"					   '||
	'		,BICO.DEFAULT_SUPPLY_SUBINVENTORY "Default Supply Subinv"					   '||
	'		,BICO.DEFAULT_CHECK_ATP "Default Check Atp"							   '||
	'		,BICO.ITEM_LOCATOR_CONTROL "Item Locator Control"						   '||
	'		,BICO.RESTRICT_LOCATORS_FLAG "Restrict Locators Flag"						   '||
	'		,BICO.RESTRICT_SUBINVENTORIES_FLAG "Restrict Subinventories Flag"				   '||
	'		,BICO.INVENTORY_ASSET_FLAG "Inv Asset Flag"							   '||
	'		,BICO.SHIPPABLE_ITEM_FLAG "Shippable Item Flag"							   '||
	'		,BICO.REVISION "Rev"										   '||
	'		,BICO.ITEM_TYPE_NAME "Item Type Name"								   '||
	'		,BICO.ACD_TYPE_NAME "Acd Type Name"								   '||
	'		,BICO.SUPPLY_TYPE		"Supply Type"									   '||
	'		,BICO.BASIS_TYPE		 "Basis Type"									   '||
	'		,BICO.TO_END_ITEM_UNIT_NUMBER "To End Item Unit Number"						   '||
	'		,to_char(BICO.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "Last Update Date"			   '||
	'		,BICO.LAST_UPDATED_BY "Last Updated By"								   '||
	'		,to_char(BICO.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "Creation Date"				   '||
	'		,BICO.CREATED_BY "Created By"									   '||
	'		,BICO.LAST_UPDATE_LOGIN "Last Update Login"							   '||
	'		,BICO.REQUEST_ID "Request Id"									   '||
	'		,BICO.PROGRAM_APPLICATION_ID "Program Application Id"						   '||
	'		,BICO.PROGRAM_ID "Program Id"									   '||
	'		,to_char(BICO.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "Program Update Date"		   '||
	'	FROM													   '||
	'		BOM_INV_COMPS_INTERFACE_V BICO									   '||
	'		,ENG_REVISED_ITEMS_INTERFACE ERI								   '||
	'		,MTL_PARAMETERS MP										   '||
	'		,MTL_ITEM_FLEXFIELDS MIF									   '||
	'		,MFG_LOOKUPS MLU_BIT										   '||
	'	WHERE	1=1												   '||
	'	AND	BICO.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID					   '||
	'	AND 	ERI.ORGANIZATION_ID = MP.ORGANIZATION_ID							   '||
	'	AND 	ERI.ORGANIZATION_ID = MIF.ORGANIZATION_ID							   '||
	'	AND 	BICO.COMPONENT_ITEM_ID = MIF.INVENTORY_ITEM_ID							   '||
	'	AND 	BICO.BOM_ITEM_TYPE=MLU_BIT.LOOKUP_CODE(+) AND ''BOM_ITEM_TYPE''=MLU_BIT.LOOKUP_TYPE(+)		   '||
	'	AND	ERI.change_notice = 	'''||l_eco_name||'''							   ';

		if l_org_id is not null then
	   		sqltxt :=sqltxt||' and eri.organization_id =  '||l_org_id;
		end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit||
		'	order by mp.organization_code,mif.item_number,bico.operation_seq_num,bico.item_num	';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Component Changes on Mass Change Orders ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr:= 'SUCCESS';
		isFatal := 'FALSE';

	/* End of SQL to fetch component changes on mass change orders */

 <<l_test_end>>
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/>This data collection script completed as expected <BR/>');
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

 End If; /* if l_eco_exists != 0 or l_mco_exists !=0 */

 End If; /* if l_eco_name is not null */

 EXCEPTION
 when others then
     JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('If this error repeats, please contact Oracle Support Services');
     statusStr := 'FAILURE';
     errStr := sqlerrm ||' occurred in script. ';
     fixInfo := 'Unexpected Exception in BOMDGCNB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'ECO Data Collection';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' This data collection script collects data about ECO Details.  <BR/>
	     Input for field ChangeNotice is mandatory. ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'ECO Data Collection';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;


PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL) IS
  tempOutput JTF_DIAG_OUTPUTTBL;
BEGIN
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
  outputValues := tempOutput;
EXCEPTION
 when others then
 outputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
END getOutputValues;


PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ChangeNotice','LOV-oracle.apps.bom.diag.lov.ECOLov'); -- Lov name modified to ChangeNotice for bug 6412260
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.bom.diag.lov.OrganizationLov'); -- Lov name modified to OrgId for bug 6412260
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_ECODATA;

/
