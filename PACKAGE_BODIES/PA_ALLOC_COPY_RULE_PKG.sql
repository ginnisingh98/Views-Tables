--------------------------------------------------------
--  DDL for Package Body PA_ALLOC_COPY_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ALLOC_COPY_RULE_PKG" AS
/*  $Header: PAXALCRB.pls 120.2 2005/08/09 11:19:15 dlanka noship $ */
procedure COPY_RULE(p_rule_id in number
		,p_to_rule_name in varchar2
		,p_to_description in varchar2
        	,x_retcode out NOCOPY varchar2
	        ,x_errbuf  out NOCOPY varchar2)
as
Cursor c_rule IS
 select RULE_ID
	,RULE_NAME
	,ALLOCATION_METHOD
	,TARGET_EXP_TYPE_CLASS
	,TARGET_EXP_ORG_ID
	,TARGET_EXP_TYPE
	,TARGET_COST_TYPE
--	,CREATION_DATE
--	,CREATED_BY
--	,LAST_UPDATE_DATE
--	,LAST_UPDATED_BY
--	,LAST_UPDATE_LOGIN
	,DESCRIPTION
	,POOL_PERCENT
	,PERIOD_TYPE
	,SOURCE_AMOUNT_TYPE
	,SOURCE_BALANCE_CATEGORY
	,SOURCE_BALANCE_TYPE
	,ALLOC_RESOURCE_LIST_ID
	,AUTO_RELEASE_FLAG
	,IMP_WITH_EXCEPTION
	,DUP_TARGETS_FLAG
	,OFFSET_EXP_TYPE_CLASS
	,OFFSET_EXP_ORG_ID
	,OFFSET_EXP_TYPE
	,OFFSET_COST_TYPE
	,OFFSET_METHOD
	,OFFSET_PROJECT_ID
	,OFFSET_TASK_ID
	,BASIS_METHOD
	,BASIS_RELATIVE_PERIOD
	,BASIS_AMOUNT_TYPE
	,BASIS_BALANCE_CATEGORY
	,BASIS_BUDGET_TYPE_CODE
        ,BASIS_FIN_PLAN_TYPE_ID    /* added bug2619977 */
	,BASIS_BALANCE_TYPE
	,BASIS_RESOURCE_LIST_ID
	,SOURCE_EXTN_FLAG
	,TARGET_EXTN_FLAG
	,FIXED_AMOUNT
	,START_DATE_ACTIVE
	,END_DATE_ACTIVE
	,ORG_ID
	,ATTRIBUTE_CATEGORY
	,ATTRIBUTE1
	,ATTRIBUTE2
	,ATTRIBUTE3
	,ATTRIBUTE4
	,ATTRIBUTE5
	,ATTRIBUTE6
	,ATTRIBUTE7
	,ATTRIBUTE8
	,ATTRIBUTE9
	,ATTRIBUTE10
	,ATTRIBUTE11
	,ATTRIBUTE12
	,ATTRIBUTE13
	,ATTRIBUTE14
	,ATTRIBUTE15
	,BASIS_BUDGET_ENTRY_METHOD_CODE
, LIMIT_TARGET_PROJECTS_CODE
 /* FP.M : Allocation Impact : 3512552 */
, ALLOC_RESOURCE_STRUCT_TYPE
, BASIS_RESOURCE_STRUCT_TYPE
, ALLOC_RBS_VERSION
, BASIS_RBS_VERSION
from pa_alloc_rules_all
where rule_id = p_rule_id
for update of rule_name;

cursor Is_Rbs_Valid ( p_rbs_header_id In Number) Is
Select 'Y' From pa_rbs_headers_v
 Where RBS_HEADER_ID  = p_rbs_header_id
   and Trunc(Sysdate) <= nvl(EFFECTIVE_TO_DATE,Sysdate);

Cursor Is_Fin_Plan_Valid (p_fin_plan_type_id in Number) Is
Select 'Y' From Pa_Fin_Plan_Types_Vl
 Where FIN_PLAN_TYPE_ID = p_fin_plan_type_id
   And Trunc(Sysdate) <= NVL(END_DATE_ACTIVE,Sysdate);

Cursor Is_Budget_Valid (p_budget_type_code in Varchar2) Is
Select 'Y' From Pa_Budget_Types
 Where BUDGET_TYPE_CODE = p_budget_type_code
   And Trunc(Sysdate) <= Nvl( END_DATE_ACTIVE, Sysdate);

--Cursor for Source
Cursor c_source is
select  RULE_ID
 	, LINE_NUM
	, EXCLUDE_FLAG
--	, CREATED_BY
--	, CREATION_DATE
--	, LAST_UPDATE_DATE
--	, LAST_UPDATED_BY
--	, LAST_UPDATE_LOGIN
	, PROJECT_ORG_ID
	, TASK_ORG_ID
	, PROJECT_TYPE
	, CLASS_CATEGORY
	, CLASS_CODE
	, SERVICE_TYPE
	, PROJECT_ID
	, TASK_ID
from pa_alloc_source_lines
where rule_id = p_rule_id
for update of line_num;
--Cursor for Gl source
Cursor C_gl_source is
Select  RULE_ID
 	, LINE_NUM
	, SOURCE_CCID
	, SUBTRACT_FLAG
--	, CREATED_BY
--	, CREATION_DATE
--	, LAST_UPDATE_DATE
--	, LAST_UPDATED_BY
--	, LAST_UPDATE_LOGIN
	, SOURCE_PERCENT
from pa_alloc_gl_lines
where rule_id = p_rule_id
for update of line_num;
--cursor for Targets
Cursor c_target is
Select  RULE_ID
	, LINE_NUM
	, EXCLUDE_FLAG
--	, CREATED_BY
--	, CREATION_DATE
--	, LAST_UPDATE_DATE
--	, LAST_UPDATED_BY
--	, LAST_UPDATE_LOGIN
	, PROJECT_ORG_ID
	, TASK_ORG_ID
	, PROJECT_TYPE
	, CLASS_CATEGORY
	, CLASS_CODE
	, SERVICE_TYPE
	, PROJECT_ID
	, TASK_ID
	, BILLABLE_ONLY_FLAG
	, LINE_PERCENT
from pa_alloc_target_lines
where rule_id = p_rule_id
for update of line_num;
--Cursor for Resources
Cursor C_resources is
Select  RULE_ID
	, MEMBER_TYPE
	, RESOURCE_LIST_MEMBER_ID
	, EXCLUDE_FLAG
--	, CREATED_BY
--	, CREATION_DATE
--	, LAST_UPDATE_DATE
--	, LAST_UPDATED_BY
--	, LAST_UPDATE_LOGIN
	, TARGET_EXPND_TYPE
	, OFFSET_EXPND_TYPE
	, RESOURCE_PERCENTAGE
from pa_alloc_resources
where rule_id = p_rule_id
for update of member_type;
--Cursor to get the Rule ID
CURSOR C1 is Select pa_alloc_rules_s.nextval from sys.dual;
--Initialise the Std Who columns
G_created_by        number := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
G_last_updated_by   number := G_created_by;
G_last_update_login number := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1);
G_creation_date     Date   := trunc(sysdate);
G_last_update_date  Date   := trunc(sysdate);
G_rule_id		  number;
G_rowid		  varchar2(60);
/* Bug# 3643304. ALLOC RULE SHOULD HONOR RBS EFFECTIVE DATES */
G_Alloc_Rbs_Valid_Flag		Varchar2(1) := 'Y';
G_Alloc_Struct_Type			Varchar2(3) ;
G_ALLOC_RESOURCE_LIST_ID	Number;
G_Alloc_Rbs_Version_Id		Number;
/* Bug# 3643304. ALLOC RULE SHOULD HONOR RBS EFFECTIVE DATES */
G_Basis_Rbs_Valid_Flag		Varchar2(1) := 'Y';
G_Basis_Struct_Type			Varchar2(3) ;
G_BASIS_RESOURCE_LIST_ID    Number;
G_Basis_Rbs_Version_Id		Number;

/* Bug# 3678479. ALLOC RULE SHOULD HONOR FIN PLAN AND BUDGET EFFECTIVE DATES */
G_BUDGET_FIN_PLAN_VALID_FLAG Varchar2(1) := 'Y';
G_Fin_Plan_Type_Id			Number;
G_Budget_Type_Code		    VARCHAR (30) ;

BEGIN
--Get the latest rule ID
  open C1;
  fetch C1 into G_RULE_ID;
  close C1;
-- Insert the Rule Information.
  FOR rule_rec IN C_rule
  LOOP
	/* Bug# 3643304. ALLOC RULE SHOULD HONOR RBS EFFECTIVE DATES */
	G_Alloc_Struct_Type			:= Rule_Rec.ALLOC_RESOURCE_STRUCT_TYPE ;
    G_ALLOC_RESOURCE_LIST_ID	:= Rule_Rec.ALLOC_RESOURCE_LIST_ID;
	G_Alloc_Rbs_Version_Id		:= Rule_Rec.Alloc_RBs_Version;
	If RULE_REC.ALLOC_RESOURCE_STRUCT_TYPE = 'RBS' Then
		Open Is_Rbs_Valid( Rule_Rec.ALLOC_RESOURCE_LIST_ID );
		Fetch Is_Rbs_Valid Into G_Alloc_Rbs_Valid_Flag;
		IF Is_Rbs_Valid%NOTFOUND Then
			G_Alloc_Struct_Type			:= Null;
		    G_ALLOC_RESOURCE_LIST_ID	:= Null;
			G_Alloc_Rbs_Version_Id		:= Null;
			G_Alloc_Rbs_Valid_Flag      := 'N';
			x_retcode := 'PA_AL_COPY_VAL_RBS';
		End If;
		Close Is_Rbs_Valid;
	End IF;
	G_BASIS_Struct_Type			:= Rule_Rec.BASIS_RESOURCE_STRUCT_TYPE ;
    G_BASIS_RESOURCE_LIST_ID	:= Rule_Rec.BASIS_RESOURCE_LIST_ID;
	G_BASIS_Rbs_Version_Id		:= Rule_Rec.BASIS_RBs_Version;
	If RULE_REC.BASIS_RESOURCE_STRUCT_TYPE = 'RBS' Then
		Open Is_Rbs_Valid(Rule_Rec.BASIS_RESOURCE_LIST_ID );
		Fetch Is_Rbs_Valid Into G_Basis_Rbs_Valid_Flag;
		IF Is_Rbs_Valid%NOTFOUND Then
			G_BASIS_Struct_Type			:= Null;
		    G_BASIS_RESOURCE_LIST_ID	:= Null;
			G_BASIS_Rbs_Version_Id		:= Null;
			G_Basis_Rbs_Valid_Flag      := 'N';
			x_retcode := 'PA_AL_COPY_VAL_RBS';
		End If;
		Close Is_Rbs_Valid;
	End IF;
	/* End of Bug# 3643304. ALLOC RULE SHOULD HONOR RBS EFFECTIVE DATES */

	/* Bug# 3678479. ALLOC RULE SHOULD HONOR FIN PLAN AND BUDGET EFFECTIVE DATES */

	If Rule_Rec.BASIS_BALANCE_CATEGORY = 'F' Then

		G_Fin_Plan_Type_Id := RULE_REC.BASIS_FIN_PLAN_TYPE_ID;
		Open Is_Fin_Plan_Valid ( G_Fin_Plan_Type_Id ) ;
		Fetch Is_Fin_Plan_Valid Into G_BUDGET_FIN_PLAN_VALID_FLAG ;

		If Is_Fin_Plan_Valid%NotFOund Then
			G_BUDGET_FIN_PLAN_VALID_FLAG := 'N';
			G_Fin_Plan_Type_Id := Null;
			x_retcode := 'PA_AL_COPY_VAL_RBS';
		End IF;

	Elsif Rule_Rec.BASIS_BALANCE_CATEGORY = 'B' Then

		G_Budget_Type_Code := RULE_REC.BASIS_BUDGET_TYPE_CODE;
		Open Is_Budget_Valid ( G_Budget_Type_Code ) ;
		Fetch Is_Budget_Valid Into G_BUDGET_FIN_PLAN_VALID_FLAG ;
		If Is_Budget_Valid%NotFOund Then
			G_BUDGET_FIN_PLAN_VALID_FLAG := 'N';
			G_Budget_Type_Code := Null;
			x_retcode := 'PA_AL_COPY_VAL_RBS';
		End IF;

	End If;

	/* End Of Bug# 3678479. ALLOC RULE SHOULD HONOR FIN PLAN AND BUDGET EFFECTIVE DATES */




    PA_ALLOC_RULES_ALL_PKG.INSERT_ROW
      ( G_ROWID 						,
  		G_RULE_ID 						,
  		P_TO_RULE_NAME 					,
  		P_TO_DESCRIPTION 				,
  		RULE_REC.POOL_PERCENT 			,
  		RULE_REC.PERIOD_TYPE 			,
  		RULE_REC.SOURCE_AMOUNT_TYPE 	,
  		RULE_REC.SOURCE_BALANCE_CATEGORY,
  		RULE_REC.SOURCE_BALANCE_TYPE 	,
  		G_ALLOC_RESOURCE_LIST_ID 		,
  		RULE_REC.AUTO_RELEASE_FLAG 		,
  		RULE_REC.ALLOCATION_METHOD 		,
  		RULE_REC.IMP_WITH_EXCEPTION 	,
  		RULE_REC.DUP_TARGETS_FLAG 		,
  		RULE_REC.TARGET_EXP_TYPE_CLASS 	,
  		RULE_REC.TARGET_EXP_ORG_ID 		,
  		RULE_REC.TARGET_EXP_TYPE 		,
  		RULE_REC.TARGET_COST_TYPE 		,
  		RULE_REC.OFFSET_EXP_TYPE_CLASS 	,
  		RULE_REC.OFFSET_EXP_ORG_ID 		,
  		RULE_REC.OFFSET_EXP_TYPE 		,
  		RULE_REC.OFFSET_COST_TYPE 		,
  		RULE_REC.OFFSET_METHOD 			,
  		RULE_REC.OFFSET_PROJECT_ID 		,
  		RULE_REC.OFFSET_TASK_ID 		,
  		RULE_REC.BASIS_METHOD 			,
  		RULE_REC.BASIS_RELATIVE_PERIOD 	,
  		RULE_REC.BASIS_AMOUNT_TYPE 		,
  		RULE_REC.BASIS_BALANCE_CATEGORY ,
  		G_Budget_Type_Code				, /* Bug# 3678479. ALLOC RULE SHOULD HONOR FIN PLAN AND BUDGET EFFECTIVE DATES */
  		RULE_REC.BASIS_BUDGET_ENTRY_METHOD_CODE ,
  		RULE_REC.BASIS_BALANCE_TYPE 	,
  		G_BASIS_RESOURCE_LIST_ID 		,
  		RULE_REC.SOURCE_EXTN_FLAG 		,
  		RULE_REC.TARGET_EXTN_FLAG 		,
  		RULE_REC.FIXED_AMOUNT 			,
  		RULE_REC.START_DATE_ACTIVE 		,
  		RULE_REC.END_DATE_ACTIVE 		,
  		RULE_REC.ATTRIBUTE_CATEGORY 	,
  		RULE_REC.ATTRIBUTE1 			,
  		RULE_REC.ATTRIBUTE2 			,
  		RULE_REC.ATTRIBUTE3 			,
  		RULE_REC.ATTRIBUTE4 			,
  		RULE_REC.ATTRIBUTE5 			,
  		RULE_REC.ATTRIBUTE6 			,
  		RULE_REC.ATTRIBUTE7 			,
  		RULE_REC.ATTRIBUTE8 			,
  		RULE_REC.ATTRIBUTE9 			,
  		RULE_REC.ATTRIBUTE10 	      	,
  		G_CREATION_DATE	      			,
  		G_CREATED_BY					,
  		G_LAST_UPDATE_DATE				,
  		G_LAST_UPDATED_BY				,
  		G_LAST_UPDATE_LOGIN	,
        RULE_REC.LIMIT_TARGET_PROJECTS_CODE	,
        G_Fin_Plan_Type_Id /* added bug 21619977 */  , /* Bug# 3678479. ALLOC RULE SHOULD HONOR FIN PLAN AND BUDGET EFFECTIVE DATES */
		/* FP.M : Allocation Impact : 3512552 */
		/* Bug# 3643304. ALLOC RULE SHOULD HONOR RBS EFFECTIVE DATES */
		G_Alloc_Struct_Type				,
		G_BASIS_Struct_Type				,
		G_Alloc_Rbs_Version_Id			,
		G_BASIS_Rbs_Version_Id			,
                RULE_REC.ORG_ID
		);
      END LOOP;
--Insert Project SOurce Information
      FOR SRC_REC in C_Source
      LOOP
        PA_ALLOC_SOURCE_LINES_PKG.INSERT_ROW (
  		G_ROWID ,
  		G_RULE_ID ,
  		SRC_REC.LINE_NUM ,
  		SRC_REC.PROJECT_ORG_ID ,
  		SRC_REC.TASK_ORG_ID ,
  		SRC_REC.PROJECT_TYPE ,
  		SRC_REC.CLASS_CATEGORY ,
  		SRC_REC.CLASS_CODE ,
  		SRC_REC.SERVICE_TYPE ,
  		SRC_REC.PROJECT_ID ,
  		SRC_REC.TASK_ID ,
  		SRC_REC.EXCLUDE_FLAG ,
  		G_CREATED_BY,
  		G_CREATION_DATE	,
  		G_LAST_UPDATE_DATE,
  		G_LAST_UPDATED_BY	,
  		G_LAST_UPDATE_LOGIN	   );
       END LOOP;
--Insert GL Source Information
       FOR GL_REC IN C_GL_SOURCE
       LOOP
         INSERT INTO PA_ALLOC_GL_LINES
		( RULE_ID
 		, LINE_NUM
		, SOURCE_CCID
		, SUBTRACT_FLAG
		, CREATED_BY
		, CREATION_DATE
		, LAST_UPDATE_DATE
		, LAST_UPDATED_BY
		, LAST_UPDATE_LOGIN
		, SOURCE_PERCENT  )
          values
            ( G_RULE_ID
		, GL_REC.LINE_NUM
		, GL_REC.SOURCE_CCID
		, GL_REC.SUBTRACT_FLAG
		, G_CREATED_BY
		, G_CREATION_DATE
		, G_LAST_UPDATE_DATE
		, G_LAST_UPDATED_BY
		, G_LAST_UPDATE_LOGIN
		, GL_REC.SOURCE_PERCENT );
       END LOOP;  /* for C_GL_SOURCE  */
--Insert Target Information
       FOR TGT_REC IN C_TARGET
       LOOP
           PA_ALLOC_TARGET_LINES_PKG.INSERT_ROW (
  		G_ROWID ,
  		G_RULE_ID ,
  		TGT_REC.LINE_NUM ,
  		TGT_REC.PROJECT_ORG_ID ,
  		TGT_REC.TASK_ORG_ID ,
  		TGT_REC.PROJECT_TYPE ,
  		TGT_REC.CLASS_CATEGORY ,
  		TGT_REC.CLASS_CODE ,
  		TGT_REC.SERVICE_TYPE ,
  		TGT_REC.PROJECT_ID ,
  		TGT_REC.TASK_ID ,
  		TGT_REC.EXCLUDE_FLAG ,
  		TGT_REC.BILLABLE_ONLY_FLAG ,
  		TGT_REC.LINE_PERCENT ,
  		G_CREATED_BY			,
  		G_CREATION_DATE		,
  		G_LAST_UPDATE_DATE		,
  		G_LAST_UPDATED_BY		,
  		G_LAST_UPDATE_LOGIN  );
       END LOOP; /* End for C_TARGET  */
--Insert Resource Information
       FOR RSR_REC IN C_RESOURCES
       LOOP
            /* Bug# 3643304. ALLOC RULE SHOULD HONOR RBS EFFECTIVE DATES */
			If (RSR_REC.MEMBER_TYPE = 'S' And G_Alloc_Rbs_Valid_Flag = 'Y' )
				Or
               (RSR_REC.MEMBER_TYPE = 'B' And G_Basis_Rbs_Valid_Flag = 'Y' )
			Then
				PA_ALLOC_RESOURCES_PKG.INSERT_ROW (
													G_ROWID				,
													G_RULE_ID			,
													RSR_REC.MEMBER_TYPE ,
													RSR_REC.RESOURCE_LIST_MEMBER_ID ,
													RSR_REC.EXCLUDE_FLAG,
													RSR_REC.TARGET_EXPND_TYPE ,
													RSR_REC.OFFSET_EXPND_TYPE ,
													RSR_REC.RESOURCE_PERCENTAGE ,
													G_CREATED_BY		,
													G_CREATION_DATE		,
													G_LAST_UPDATE_DATE	,
													G_LAST_UPDATED_BY	,
													G_LAST_UPDATE_LOGIN
												  );
			End If;
	  END LOOP;  /* End for C_RESOURCES */
   commit;
   EXCEPTION
        when others then
          x_retcode := SQLCODE;
          x_errbuf  := SQLERRM;
   END COPY_RULE;
END PA_ALLOC_COPY_RULE_PKG;

/
