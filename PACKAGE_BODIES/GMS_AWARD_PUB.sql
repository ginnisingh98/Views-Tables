--------------------------------------------------------
--  DDL for Package Body GMS_AWARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARD_PUB" AS
-- $Header: gmsawpbb.pls 120.2.12010000.2 2008/10/30 11:27:11 rrambati ship $

	G_PKG_NAME  	CONSTANT VARCHAR2(30) := 'GMS_AWARD_PUB';
	E_VER_MISMATCH	EXCEPTION ;

	G_msg_count		NUMBER ;
	G_msg_data		    varchar2(2000) ;
	G_calling_module	varchar2(30) ;
	G_product_code		varchar2(3) 	:= 'GMS' ;
	G_stage		    varchar2(80) ;

    	--
-- init_message_stack
-- init_message_stack Initialize the the error message PL/SQL
-- Table and set the context for the private Package.
-- This is called at the begining of the program unit.
--
	-- +++++++++++++
	PROCEDURE init_message_stack is
	BEGIN
		  gms_award_pvt.init_message_stack ;

	END init_message_stack ;

    	--
    	-- reset_message_flag
    	-- reset_message_flag set the context for the private Package.
    	-- This is called at the end of the program unit.
    	--
	-- ++++++++++++
	PROCEDURE reset_message_flag is
	BEGIN
		  gms_award_pvt.reset_message_flag ;

	END reset_message_flag ;

    	--
    	-- add_message_TO_STACK
    	-- add_message_to_stack - This is a private program unit
    	-- defined in this package to add error messages to
    	-- the PL/SQL message table.
    	-- This updates the G_msg_count after adding a message
    	-- to the message variable.
    	--

	-- +++++++++++++
	PROCEDURE add_message_to_stack( P_Label	IN Varchar2,
				    P_token1	IN varchar2 default NULL,
				    P_val1	IN varchar2 default NULL,
				    P_token2	IN varchar2 default NULL,
				    P_val2	in varchar2 default NULL,
				    P_token3	IN varchar2 default NULL,
				    P_val3	in varchar2 default NULL ) is
	BEGIN

		gms_award_pvt.add_message_to_stack(P_Label, P_token1, P_val1, P_token2, P_val2, P_token3, P_val3 ) ;


	END add_message_to_stack ;

	-- SET_RETURN_STATUS
    	-- This routine sets the return status for the failures.
	-- X_RETURN_STATUS : <S>uccess, [E] Business Rule Violation
	-- U - Unexpected Error
	-- P_TYPE := B - Business Validations, E- Exception
	--

	-- +++++++++++++
	PROCEDURE set_return_status(X_return_status IN OUT NOCOPY VARCHAR2,
				 p_type in varchar2 DEFAULT 'B' ) is
	begin
		gms_award_pvt.set_return_status( X_return_status, p_type  ) ;

	END set_return_status ;

    -- =====================================================
    -- Utility Functions for creating an award
    -- =====================================================

    --
    -- get_Funds_ctrl_code
    -- This is a function defined to return
    -- funds control code for the corresponding name.
    -- The code values are as follows
    -- B- ABSOLUTE
    -- D- ADVISORY
    -- N- NONE
    --
    FUNCTION get_Funds_ctrl_code( p_fctrl_name varchar2 )
    return varchar2 is
        l_dummy varchar2(1) ;
    begin
        IF p_fctrl_name = 'ABSOLUTE' THEN
            l_dummy := 'B' ;
        ELSIF p_fctrl_name = 'ADVISORY' THEN
            l_dummy := 'D' ;
        ELSIF p_fctrl_name = 'NONE' THEN
            l_dummy := 'N' ;
        END IF ;

        return l_dummy ;
    END  get_Funds_ctrl_code ;

    --
    -- proc_set_record
    -- This is a program unit defined to populate
    -- record group for the parameters supplied
    -- to the create_award API.
    --
    -- +++++++++++++
    PROCEDURE proc_set_record (
				 AWARD_NUMBER                IN VARCHAR2,
				 AWARD_SHORT_NAME            IN VARCHAR2,
				 AWARD_FULL_NAME             IN VARCHAR2,
				 FUNDING_SOURCE_ID           IN NUMBER,
				 START_DATE_ACTIVE           IN DATE,
				 END_DATE_ACTIVE             IN DATE,
				 CLOSE_DATE                  IN DATE,
				 FUNDING_SOURCE_AWARD_NUMBER IN VARCHAR2,
				 AWARD_PURPOSE_CODE          IN VARCHAR2,
				 STATUS                      IN VARCHAR2,
				 ALLOWABLE_SCHEDULE_ID       IN NUMBER,
				 IDC_SCHEDULE_ID             IN NUMBER,
				 REVENUE_DISTRIBUTION_RULE   IN VARCHAR2,
				 BILLING_DISTRIBUTION_RULE   IN VARCHAR2,
				 BILLING_FORMAT              IN VARCHAR2,
				 BILLING_TERM                IN NUMBER,
				 AWARD_PROJECT_ID            IN NUMBER,
				 AGREEMENT_ID                IN NUMBER,
				 AWARD_TEMPLATE_FLAG         IN VARCHAR2,
				 PREAWARD_DATE               IN DATE,
				 AWARD_MANAGER_ID            IN NUMBER,
				 AGENCY_SPECIFIC_FORM        IN VARCHAR2,
				 BILL_TO_CUSTOMER_ID         IN NUMBER,
				 TRANSACTION_NUMBER          IN VARCHAR2,
				 AMOUNT_TYPE                 IN VARCHAR2,
				 BOUNDARY_CODE               IN VARCHAR2,
				 FUND_CONTROL_LEVEL_AWARD    IN VARCHAR2,
				 FUND_CONTROL_LEVEL_TASK     IN VARCHAR2,
				 FUND_CONTROL_LEVEL_RES_GRP  IN VARCHAR2,
				 FUND_CONTROL_LEVEL_RES      IN VARCHAR2,
				 ATTRIBUTE_CATEGORY          IN VARCHAR2,
				 ATTRIBUTE1                  IN VARCHAR2,
				 ATTRIBUTE2                  IN VARCHAR2,
				 ATTRIBUTE3                  IN VARCHAR2,
				 ATTRIBUTE4                  IN VARCHAR2,
				 ATTRIBUTE5                  IN VARCHAR2,
				 ATTRIBUTE6                  IN VARCHAR2,
				 ATTRIBUTE7                  IN VARCHAR2,
				 ATTRIBUTE8                  IN VARCHAR2,
				 ATTRIBUTE9                  IN VARCHAR2,
				 ATTRIBUTE10                 IN VARCHAR2,
				 ATTRIBUTE11                 IN VARCHAR2,
				 ATTRIBUTE12                 IN VARCHAR2,
				 ATTRIBUTE13                 IN VARCHAR2,
				 ATTRIBUTE14                 IN VARCHAR2,
				 ATTRIBUTE15                 IN VARCHAR2,
				 TEMPLATE_START_DATE_ACTIVE  IN DATE,
				 TEMPLATE_END_DATE_ACTIVE    IN DATE,
				 TYPE                        IN VARCHAR2,
				 ORG_ID                      IN NUMBER,
				 COST_IND_SCH_FIXED_DATE     IN DATE,
				 LABOR_INVOICE_FORMAT_ID     IN NUMBER,
				 NON_LABOR_INVOICE_FORMAT_ID IN NUMBER,
				 BILL_TO_ADDRESS_ID          IN NUMBER,
				 SHIP_TO_ADDRESS_ID          IN NUMBER,
				 LOC_BILL_TO_ADDRESS_ID      IN NUMBER,
				 LOC_SHIP_TO_ADDRESS_ID      IN NUMBER,
				 AWARD_ORGANIZATION_ID       IN NUMBER,
				 HARD_LIMIT_FLAG             IN VARCHAR2,
                 INVOICE_LIMIT_FLAG          IN VARCHAR2, /*Bug 6642901*/
				 BILLING_OFFSET              IN NUMBER,
				 BILLING_CYCLE_ID            IN NUMBER,
				 BUDGET_WF_ENABLED_FLAG      IN VARCHAR2,
				 PROPOSAL_ID                 IN NUMBER,
				 AWARD_REC                  IN OUT NOCOPY gms_awards_all%ROWTYPE ) is
	BEGIN
		award_rec.AWARD_NUMBER                    	:=    AWARD_NUMBER                    ;
		award_rec.AWARD_SHORT_NAME                	:=    AWARD_SHORT_NAME                ;
		award_rec.AWARD_FULL_NAME                 	:=    AWARD_FULL_NAME                 ;
		award_rec.FUNDING_SOURCE_ID               	:=    FUNDING_SOURCE_ID               ;
		award_rec.START_DATE_ACTIVE               	:=    START_DATE_ACTIVE               ;
		award_rec.END_DATE_ACTIVE                 	:=    END_DATE_ACTIVE                 ;
		award_rec.CLOSE_DATE                      	:=    CLOSE_DATE                      ;
		award_rec.FUNDING_SOURCE_AWARD_NUMBER     	:=    FUNDING_SOURCE_AWARD_NUMBER     ;
		award_rec.AWARD_PURPOSE_CODE              	:=    AWARD_PURPOSE_CODE              ;
		award_rec.STATUS                          	:=    STATUS                          ;
		award_rec.ALLOWABLE_SCHEDULE_ID           	:=    ALLOWABLE_SCHEDULE_ID           ;
		award_rec.IDC_SCHEDULE_ID                 	:=    IDC_SCHEDULE_ID                 ;
		award_rec.REVENUE_DISTRIBUTION_RULE       	:=    REVENUE_DISTRIBUTION_RULE       ;
		award_rec.BILLING_DISTRIBUTION_RULE       	:=    BILLING_DISTRIBUTION_RULE       ;
		award_rec.BILLING_FORMAT                  	:=    BILLING_FORMAT                  ;
		award_rec.BILLING_TERM                    	:=    BILLING_TERM                    ;
		award_rec.AWARD_PROJECT_ID                	:=    AWARD_PROJECT_ID                ;
		award_rec.AGREEMENT_ID                    	:=    AGREEMENT_ID                    ;
		award_rec.AWARD_TEMPLATE_FLAG             	:=    AWARD_TEMPLATE_FLAG             ;
		award_rec.PREAWARD_DATE                   	:=    PREAWARD_DATE                   ;
		award_rec.AWARD_MANAGER_ID                	:=    AWARD_MANAGER_ID                ;
		award_rec.AGENCY_SPECIFIC_FORM            	:=    AGENCY_SPECIFIC_FORM            ;
		award_rec.BILL_TO_CUSTOMER_ID             	:=    BILL_TO_CUSTOMER_ID             ;
		award_rec.TRANSACTION_NUMBER              	:=    TRANSACTION_NUMBER              ;
		award_rec.AMOUNT_TYPE                     	:=    AMOUNT_TYPE                     ;
		award_rec.BOUNDARY_CODE                   	:=    BOUNDARY_CODE                   ;
		award_rec.FUND_CONTROL_LEVEL_AWARD        	:=    FUND_CONTROL_LEVEL_AWARD        ;
		award_rec.FUND_CONTROL_LEVEL_TASK         	:=    FUND_CONTROL_LEVEL_TASK         ;
		award_rec.FUND_CONTROL_LEVEL_RES_GRP      	:=    FUND_CONTROL_LEVEL_RES_GRP      ;
		award_rec.FUND_CONTROL_LEVEL_RES          	:=    FUND_CONTROL_LEVEL_RES          ;
		award_rec.ATTRIBUTE_CATEGORY              	:=    ATTRIBUTE_CATEGORY              ;
		award_rec.ATTRIBUTE1                      	:=    ATTRIBUTE1                      ;
		award_rec.ATTRIBUTE2                      	:=    ATTRIBUTE2                      ;
		award_rec.ATTRIBUTE3                      	:=    ATTRIBUTE3                      ;
		award_rec.ATTRIBUTE4                      	:=    ATTRIBUTE4                      ;
		award_rec.ATTRIBUTE5                      	:=    ATTRIBUTE5                      ;
		award_rec.ATTRIBUTE6                      	:=    ATTRIBUTE6                      ;
		award_rec.ATTRIBUTE7                      	:=    ATTRIBUTE7                      ;
		award_rec.ATTRIBUTE8                      	:=    ATTRIBUTE8                      ;
		award_rec.ATTRIBUTE9                      	:=    ATTRIBUTE9                      ;
		award_rec.ATTRIBUTE10                     	:=    ATTRIBUTE10                     ;
		award_rec.ATTRIBUTE11                     	:=    ATTRIBUTE11                     ;
		award_rec.ATTRIBUTE12                     	:=    ATTRIBUTE12                     ;
		award_rec.ATTRIBUTE13                     	:=    ATTRIBUTE13                     ;
		award_rec.ATTRIBUTE14                     	:=    ATTRIBUTE14                     ;
		award_rec.ATTRIBUTE15                     	:=    ATTRIBUTE15                     ;
		award_rec.TEMPLATE_START_DATE_ACTIVE      	:=    TEMPLATE_START_DATE_ACTIVE      ;
		award_rec.TEMPLATE_END_DATE_ACTIVE        	:=    TEMPLATE_END_DATE_ACTIVE        ;
		award_rec.TYPE                            	:=    TYPE                            ;
		award_rec.ORG_ID                          	:=    ORG_ID                          ;
		award_rec.COST_IND_SCH_FIXED_DATE         	:=    COST_IND_SCH_FIXED_DATE         ;
		award_rec.LABOR_INVOICE_FORMAT_ID         	:=    LABOR_INVOICE_FORMAT_ID         ;
		award_rec.NON_LABOR_INVOICE_FORMAT_ID     	:=    NON_LABOR_INVOICE_FORMAT_ID     ;
		award_rec.BILL_TO_ADDRESS_ID              	:=    BILL_TO_ADDRESS_ID              ;
		award_rec.SHIP_TO_ADDRESS_ID              	:=    SHIP_TO_ADDRESS_ID              ;
		award_rec.LOC_BILL_TO_ADDRESS_ID          	:=    LOC_BILL_TO_ADDRESS_ID          ;
		award_rec.LOC_SHIP_TO_ADDRESS_ID          	:=    LOC_SHIP_TO_ADDRESS_ID          ;
		award_rec.AWARD_ORGANIZATION_ID           	:=    AWARD_ORGANIZATION_ID           ;
		award_rec.HARD_LIMIT_FLAG                 	:=    HARD_LIMIT_FLAG                 ;
		award_rec.INVOICE_LIMIT_FLAG                 	:=    INVOICE_LIMIT_FLAG              ; /*Bug 6642901*/
		award_rec.BILLING_OFFSET                  	:=    BILLING_OFFSET                  ;
		award_rec.BILLING_CYCLE_ID                	:=    BILLING_CYCLE_ID                ;
		award_rec.BUDGET_WF_ENABLED_FLAG          	:=    BUDGET_WF_ENABLED_FLAG          ;
		award_rec.PROPOSAL_ID                     	:=    PROPOSAL_ID                     ;
	END proc_set_record ;
    -- ========================================================================================
    -- End of utility Functions/Procedures for award.
    -- ========================================================================================

    -- CREATE_AWARD
    -- Create award is a public API provided to create award
    -- into grants accounting. This is the API used to
    -- transfer Legacy system data into grants accounting.
    -- OUT NOCOPY Parameters meanings
    -- P_MSG_COUNT              :   Holds no. of messages in the global
    --                              message table.
    -- P_MSG_DATE               :   Holds the message code, if the API
    --                              returned only one error/warning message.
    -- X_return_status          :   The indicator of success/Failure
    --                              S- Success, E- and U- Failure
    -- p_award_id               :   The Award ID created.

    -- ===============================================================================
    -- CREATE_AWARD :
    -- Create award has all the parameters that we have in gms_awards_all table.
    -- The ID's in the table are replaced by corresponding value. Users must
    -- provide decode values instead of code values for certain arguments.
    -- X_return_status 	: 	S- Success,
    --				E- Business Rule Validation error
    --				U- Unexpected Error
    -- P_API_VERSION_NUMBER	:	1.0
    -- ===============================================================================
    -- +++++++++++++
    PROCEDURE	create_award(
				X_MSG_COUNT			OUT NOCOPY	NUMBER,
				X_MSG_DATA			OUT NOCOPY	VARCHAR2,
				X_return_status			OUT NOCOPY	VARCHAR2,
				X_AWARD_ID			OUT NOCOPY	NUMBER,
				P_CALLING_MODULE		IN	VARCHAR2,
				P_API_VERSION_NUMBER		IN	NUMBER,
				P_LAST_UPDATE_DATE		IN	DATE,
				P_LAST_UPDATED_BY		IN	NUMBER,
				P_CREATED_BY			IN	NUMBER,
				P_CREATION_DATE			IN	DATE,
				P_LAST_UPDATE_LOGIN		IN	NUMBER,
				P_AWARD_NUMBER			IN	VARCHAR2,
				P_AWARD_SHORT_NAME		IN	VARCHAR2,
				P_AWARD_FULL_NAME		IN	VARCHAR2,
				P_AWARD_START_DATE		IN	DATE,
				P_AWARD_END_DATE		IN	DATE,
				P_AWARD_CLOSE_DATE		IN	DATE,
				P_PREAWARD_DATE			IN	DATE,
				P_AWARD_PURPOSE_CODE		IN 	VARCHAR2,
				P_AWARD_STATUS_CODE		IN	VARCHAR2,
				P_AWARD_MANAGER_ID		IN	NUMBER,
				P_AWARD_ORGANIZATION_ID		IN	NUMBER,
				P_FUNDING_SOURCE_ID		IN	NUMBER,
				P_FUNDING_SOURCE_AWARD_NUM	IN	VARCHAR2,
				P_ALLOWABLE_SCHEDULE		IN	VARCHAR2,
				P_INDIRECT_SCHEDULE		IN	VARCHAR2,
				P_COST_IND_SCH_FIXED_DATE	IN	DATE,
				P_REVENUE_DISTRIBUTION_RULE	IN	VARCHAR2,
				P_BILLING_DISTRIBUTION_RULE	IN	VARCHAR2,
				P_BILLING_FORMAT		IN	VARCHAR2,
				P_BILLING_TERM_ID		IN	NUMBER,
				P_AGENCY_FORM			IN	VARCHAR2,
				P_BILL_TO_CUSTOMER_ID		IN	VARCHAR2,
				P_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2,
				P_NON_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2,
				P_BILL_TO_ADDRESS_ID		IN	NUMBER,
				P_SHIP_TO_ADDRESS_ID		IN	NUMBER,
				P_LOC_BILL_TO_ADDRESS_ID	IN	NUMBER,
				P_LOC_SHIP_TO_ADDRESS_ID	IN	NUMBER,
				P_HARD_LIMIT_FLAG		IN	VARCHAR2,
				P_INVOICE_LIMIT_FLAG		IN	VARCHAR2, /*Bug 6642901*/
				P_BILLING_OFFSET		IN	NUMBER,
				P_BILLING_CYCLE			IN	VARCHAR2,
				P_TRANSACTION_NUM		IN	VARCHAR2,
				P_AMOUNT_TYPE_CODE		IN	VARCHAR2,
				P_BOUNDARY_CODE			IN	VARCHAR2,
				P_FUNDS_CONTROL_AT_AWARD	IN	VARCHAR2,
				P_FUNDS_CONTROL_AT_TASK		IN	VARCHAR2,
				P_FUNDS_CONTROL_AT_RES_GROUP    IN	VARCHAR2,
				P_FUNDS_CONTROL_AT_RES	        IN	VARCHAR2,
				P_ATTRIBUTE_CATEGORY		IN	VARCHAR2,
				P_ATTRIBUTE1			IN	VARCHAR2,
				P_ATTRIBUTE2			IN	VARCHAR2,
				P_ATTRIBUTE3			IN	VARCHAR2,
				P_ATTRIBUTE4			IN	VARCHAR2,
				P_ATTRIBUTE5			IN	VARCHAR2,
				P_ATTRIBUTE6			IN	VARCHAR2,
				P_ATTRIBUTE7			IN	VARCHAR2,
				P_ATTRIBUTE8			IN	VARCHAR2,
				P_ATTRIBUTE9			IN	VARCHAR2,
				P_ATTRIBUTE10			IN	VARCHAR2,
				P_ATTRIBUTE11			IN	VARCHAR2,
				P_ATTRIBUTE12			IN	VARCHAR2,
				P_ATTRIBUTE13			IN	VARCHAR2,
				P_ATTRIBUTE14			IN	VARCHAR2,
				P_ATTRIBUTE15			IN	VARCHAR2,
				P_AGREEMENT_TYPE		IN	VARCHAR2,
				P_ORG_ID			    IN	NUMBER,
				P_WF_ENABLED_FLAG		IN	VARCHAR2,
				P_PROPOSAL_ID			IN	NUMBER ) IS


        l_api_name              varchar2(30) := 'GMS_AWARD_PUB.CREATE_AWARD';
        L_allow_schedule_id     gms_allowability_schedules.allowability_schedule_id%TYPE ;
        L_error                 BOOLEAN := FALSE ;

        L_IDC_schedule_type     pa_ind_rate_schedules.ind_rate_schedule_type%TYPE ;
        L_ind_rate_sch_id       pa_ind_rate_schedules.ind_rate_sch_id%TYPE ;

        L_award_rec             GMS_AWARDS_ALL%ROWTYPE ;
        L_award_id              GMS_AWARDS_ALL.AWARD_ID%TYPE ;

        L_billing_cycle_id      pa_billing_cycles.billing_cycle_id%TYPE ;
        L_fctrl_award           gms_awards_all.fund_control_level_award%TYPE;
        L_fctrl_task            gms_awards_all.fund_control_level_task%TYPE;
        L_fctrl_RGP             gms_awards_all.fund_control_level_res_grp%TYPE;
        L_fctrl_res             gms_awards_all.fund_control_level_res%TYPE;
	L_row_id		varchar2(45) ;
	l_default_org_id	GMS_AWARDS_ALL.ORG_ID%TYPE;
	MO_ORG_INVALID_EXCEPTION EXCEPTION;


        CURSOR C_BILL is
        SELECT billing_cycle_id
          FROM pa_billing_cycles
         WHERE trunc(sysdate) between start_date_active
           and NVL( end_date_active, sysdate )
	   and billing_cycle_name = P_BILLING_CYCLE ;

	CURSOR C_allowable_sch is
	SELECT allowability_schedule_id
	  FROM gms_allowability_schedules
	 WHERE allow_sch_name = P_ALLOWABLE_SCHEDULE ;

        CURSOR C_IDC_SCH is
            SELECT  ind_rate_sch_id,
                    ind_rate_schedule_type
              FROM pa_ind_rate_schedules
             WHERE ind_rate_sch_name = P_INDIRECT_SCHEDULE ;

    BEGIN
	G_stage := 'CREATE_AWARD_BEGINS' ;
       	init_message_stack  ;

	savepoint CREATE_AWARD_SAVE ;
	X_return_status	:= FND_API.G_RET_STS_SUCCESS;

        G_stage := 'FND_API.Compatible_API_Call' ;

    	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
		 	                     p_api_version_number	,
			                     l_api_name 	    	,
			                     G_PKG_NAME 	    	)
     	THEN
		--RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		RAISE e_ver_mismatch ;
	END IF ;

	--=============================
	-- Shared Service Enhancement
	--=============================
	G_stage := 'MOAC INIT';

	MO_GLOBAL.INIT('GMS');

	l_default_org_id := MO_GLOBAL.get_valid_org(p_org_id);

	IF l_default_org_id is null then
		FND_MESSAGE.SET_NAME ('MO',' MO_ORG_INVALID');
		RAISE MO_ORG_INVALID_EXCEPTION;
	END IF;


	-- ==============================
	-- Convert Names/Decode into ID's.
	-- ==============================
        G_stage := 'ID-NAME-CONV' ;

        IF P_ALLOWABLE_SCHEDULE is not NULL THEN
                OPEN C_allowable_sch ;
                FETCH C_allowable_sch into L_allow_schedule_id ;

                IF C_allowable_sch%NOTFOUND THEN
      		   	add_message_to_stack( P_label => 'GMS_AWD_ACD_INVALID' ) ;
		       	l_error := TRUE ;
                END IF ;

                CLOSE C_allowable_sch ;
        END IF ;

        IF P_INDIRECT_SCHEDULE is not NULL THEN
                OPEN C_IDC_SCH ;
                FETCH C_IDC_SCH into L_ind_rate_sch_id, L_IDC_schedule_type ;

                IF C_IDC_SCH%NOTFOUND THEN
      	   		add_message_to_stack( P_label => 'GMS_IDC_SCH_INVALID' ) ;
	   		l_error := TRUE ;
                END IF ;

                CLOSE C_IDC_SCH ;
         END IF ;

         IF P_billing_cycle is not NULL THEN
                OPEN C_bill ;
                FETCH C_bill into L_billing_cycle_id ;

                IF C_BILL%NOTFOUND THEN
		   add_message_to_stack( P_label => 'GMS_BILL_CYC_INVALID' ) ;
		   l_error := TRUE ;
                END IF ;

                CLOSE C_BILL ;
         END IF ;

	 IF NVL(P_FUNDS_CONTROL_AT_AWARD	, 'ABSOLUTE') not in ( 'ABSOLUTE', 'ADVISORY', 'NONE' )
         THEN
          		add_message_to_stack( P_label => 'GMS_FUNDS_CTRL_AWD_INVALID' ) ;
    			l_error := TRUE ;
          END IF ;

	  IF NVL(P_FUNDS_CONTROL_AT_TASK	, 'ABSOLUTE') not in ( 'ABSOLUTE', 'ADVISORY', 'NONE' )
          THEN
          		add_message_to_stack( P_label => 'GMS_FUNDS_CTRL_TASK_INVALID' ) ;
    			l_error := TRUE ;
          END IF ;

	  IF NVL(P_FUNDS_CONTROL_AT_RES_GROUP	, 'ABSOLUTE') not in ( 'ABSOLUTE', 'ADVISORY', 'NONE' )
          THEN
          		add_message_to_stack( P_label => 'GMS_FUNDS_CTRL_RGP_INVALID' ) ;
    			l_error := TRUE ;
          END IF ;

	  IF NVL(P_FUNDS_CONTROL_AT_RES	, 'ABSOLUTE') not in ( 'ABSOLUTE', 'ADVISORY', 'NONE' )
          THEN
          		add_message_to_stack( P_label => 'GMS_FUNDS_CTRL_RES_INVALID' ) ;
    			l_error := TRUE ;
          END IF ;

          L_fctrl_award := get_funds_ctrl_code(P_FUNDS_CONTROL_AT_AWARD ) ;
          L_fctrl_task  := get_funds_ctrl_code(P_FUNDS_CONTROL_AT_TASK ) ;
          L_fctrl_RGP   := get_funds_ctrl_code(P_FUNDS_CONTROL_AT_RES_GROUP ) ;
          L_fctrl_res   := get_funds_ctrl_code(P_FUNDS_CONTROL_AT_RES ) ;

          If l_error then
                set_return_status(X_return_status, 'B' ) ;
          END IF ;

          G_stage := 'SET RECORD PARAM' ;

          proc_set_record (
				 P_AWARD_NUMBER,
				 P_AWARD_SHORT_NAME,
				 P_AWARD_FULL_NAME,
				 P_FUNDING_SOURCE_ID,
				 P_AWARD_START_DATE,
				 P_AWARD_END_DATE,
				 P_AWARD_CLOSE_DATE,
				 P_FUNDING_SOURCE_AWARD_NUM,
				 P_AWARD_PURPOSE_CODE,
				 P_AWARD_STATUS_CODE,
				 L_allow_schedule_id,
				 L_ind_rate_sch_id,
				 P_REVENUE_DISTRIBUTION_RULE ,
				 P_BILLING_DISTRIBUTION_RULE ,
				 P_BILLING_FORMAT            ,
				 P_BILLING_TERM_ID           ,
				 NULL ,
				 NULL,
				 'DEFERRED',
				 P_PREAWARD_DATE,
				 P_AWARD_MANAGER_ID,
				 P_AGENCY_FORM,
				 P_BILL_TO_CUSTOMER_ID,
				 P_TRANSACTION_NUM ,
				 P_AMOUNT_TYPE_CODE,
				 P_BOUNDARY_CODE,
				 L_fctrl_award,
				 L_fctrl_task,
				 L_fctrl_rgp,
				 L_fctrl_res,
				 P_ATTRIBUTE_CATEGORY,
				 P_ATTRIBUTE1,
				 P_ATTRIBUTE2,
				 P_ATTRIBUTE3,
				 P_ATTRIBUTE4,
				 P_ATTRIBUTE5,
				 P_ATTRIBUTE6,
				 P_ATTRIBUTE7,
				 P_ATTRIBUTE8,
				 P_ATTRIBUTE9,
				 P_ATTRIBUTE10,
				 P_ATTRIBUTE11,
				 P_ATTRIBUTE12,
				 P_ATTRIBUTE13,
				 P_ATTRIBUTE14,
				 P_ATTRIBUTE15,
				 NULL,
				 NULL  ,
				 P_AGREEMENT_TYPE            ,
				 --P_ORG_ID                    ,
				 l_default_org_id,
				 P_COST_IND_SCH_FIXED_DATE   ,
				 P_LABOR_INVOICE_FORMAT_ID  ,
				 P_NON_LABOR_INVOICE_FORMAT_ID ,
				 P_BILL_TO_ADDRESS_ID   ,
				 P_SHIP_TO_ADDRESS_ID    ,
				 P_LOC_BILL_TO_ADDRESS_ID  ,
				 P_LOC_SHIP_TO_ADDRESS_ID  ,
				 P_AWARD_ORGANIZATION_ID,
				 P_HARD_LIMIT_FLAG     ,
				 P_INVOICE_LIMIT_FLAG     , /*Bug 6642901*/
				 P_BILLING_OFFSET      ,
				 L_billing_cycle_id,
				 P_WF_ENABLED_FLAG ,
				 P_PROPOSAL_ID ,
          		         L_AWARD_REC      ) ;

          l_award_rec.last_updated_by      := NVL(P_LAST_UPDATED_BY, fnd_global.user_id) ;
	  l_award_rec.last_update_date     := NVL(P_LAST_UPDATE_DATE, SYSDATE) ;
          l_award_rec.last_updated_by      := NVL(P_LAST_UPDATED_BY, fnd_global.user_id) ;
	  l_award_rec.created_by           := NVL(P_CREATED_BY, fnd_global.user_id ) ;
	  l_award_rec.creation_date        := NVL(P_CREATION_DATE, SYSDATE) ;
	  l_award_rec.last_update_login    := NVL(P_LAST_UPDATE_LOGIN, fnd_global.user_id ) ;
	  l_award_rec.award_number         := P_AWARD_NUMBER ;

          G_stage := 'gms_award_pvt.create_award' ;
	  gms_award_pvt.create_award( X_msg_count,
		                    X_MSG_DATA	,
		                    X_return_status	,
		                    L_ROW_ID	,
		                    X_AWARD_ID	,
		                    P_CALLING_MODULE,
		                    P_API_VERSION_NUMBER,
		                    L_AWARD_REC	) ;

          reset_message_flag ;
    EXCEPTION
	WHEN e_ver_mismatch THEN
         	add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH' ) ;
                set_return_status(X_return_status, 'B' ) ;
                X_msg_count := G_msg_count ;
                X_msg_data  := G_msg_data ;

	WHEN fnd_api.g_exc_error THEN
		ROLLBACK TO create_award_save ;
                set_return_status(X_return_status, 'B' ) ;
                X_msg_count := G_msg_count ;
                X_msg_data  := G_msg_data ;
	WHEN others THEN
		ROLLBACK TO create_award_save;
		X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
		FND_MSG_PUB.Count_And_Get
				(   p_count		=>	X_msg_count	,
				    p_data		=>	X_msg_data	);

	END create_award ;

	--===============================================================================
	-- COPY_AWARD :
	-- Copy award has all the parameters that we have in quick entry for award.
	-- The ID's in the table are replaced by corresponding value. Users must
	-- provide decode values instead of code values.
	-- X_return_status 	: 	S- Success,
	--				E- Business Rule Validation error
	--				U- Unexpected Error
	-- P_API_VERSION_NUMBER	:	1.0
	-- ===============================================================================
        -- +++++++++++++
	PROCEDURE	copy_award(
				X_MSG_COUNT			OUT NOCOPY	NUMBER,
				X_MSG_DATA			OUT NOCOPY	VARCHAR2,
				X_return_status			OUT NOCOPY	VARCHAR2,
				X_AWARD_ID			OUT NOCOPY	NUMBER,
				P_CALLING_MODULE		IN	VARCHAR2,
				P_API_VERSION_NUMBER		IN	NUMBER,
				P_AWARD_BASE_ID			IN	NUMBER,
				P_AWARD_NUMBER			IN	VARCHAR2,
				P_AWARD_SHORT_NAME		IN	VARCHAR2,
				P_AWARD_FULL_NAME		IN	VARCHAR2,
				P_AWARD_START_DATE		IN	DATE,
				P_AWARD_END_DATE		IN	DATE,
				P_AWARD_CLOSE_DATE		IN	DATE,
				P_PREAWARD_DATE			IN	DATE,
				P_AWARD_PURPOSE_CODE		IN 	VARCHAR2,
				P_AWARD_STATUS_CODE		IN	VARCHAR2,
				P_AWARD_MANAGER_ID		IN	NUMBER,
				P_AWARD_ORGANIZATION_ID		IN	NUMBER,
				P_FUNDING_SOURCE_ID		IN	NUMBER,
				P_FUNDING_SOURCE_AWARD_NUM	IN	VARCHAR2,
				P_ALLOWABLE_SCHEDULE		IN	VARCHAR2,
				P_INDIRECT_SCHEDULE		IN	VARCHAR2,
				P_COST_IND_SCH_FIXED_DATE	IN	DATE,
				P_REVENUE_DISTRIBUTION_RULE	IN	VARCHAR2,
				P_BILLING_DISTRIBUTION_RULE	IN	VARCHAR2,
				P_BILLING_TERM_ID		IN	NUMBER,
				P_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2,
				P_NON_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2,
				P_BILLING_CYCLE			IN	VARCHAR2,
				P_AMOUNT_TYPE_CODE		IN	VARCHAR2,
				P_BOUNDARY_CODE			IN	VARCHAR2,
				P_AGREEMENT_TYPE		IN	VARCHAR2,
				P_PROPOSAL_ID			IN	NUMBER  ) is
	BEGIN
		NULL ;
	END copy_award ;


	-- ===============================================================================
	-- CREATE_AWARD_INSTALLMENT :
	-- Create award installment  has all the parameters that we have in gms_awards_installment table.
	-- The ID's in the table are replaced by corresponding value. Users must
	-- provide decode values instead of code values.
	-- X_return_status 	: 	S- Success,
	--				E- Business Rule Validation error
	--				U- Unexpected Error
	-- P_API_VERSION_NUMBER	:	1.0
	-- ===============================================================================
        -- +++++++++++++
	PROCEDURE CREATE_INSTALLMENT
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_return_status            OUT NOCOPY     VARCHAR2 ,
			 X_INSTALLMENT_ID           OUT NOCOPY     NUMBER ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER,
			 P_LAST_UPDATE_DATE         IN      DATE   ,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE   ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_INSTALLMENT_NUMBER       IN      NUMBER ,
			 P_INSTALLMENT_TYPE_CODE    IN      VARCHAR2 ,
			 P_DESCRIPTION              IN      VARCHAR2  ,
			 P_ISSUE_DATE               IN      DATE ,
			 P_INSTALLMENT_START_DATE   IN      DATE ,
			 P_INSTALLMENT_END_DATE     IN      DATE ,
			 P_INSTALLMENT_CLOSE_DATE   IN      DATE  ,
			 P_ACTIVE_FLAG              IN      VARCHAR2 ,
			 P_BILLABLE_FLAG            IN      VARCHAR2 ,
			 P_DIRECT_COST              IN      NUMBER ,
			 P_INDIRECT_COST            IN      NUMBER ,
			 P_ATTRIBUTE_CATEGORY       IN      VARCHAR2 ,
			 P_ATTRIBUTE1               IN      VARCHAR2 ,
			 P_ATTRIBUTE2               IN      VARCHAR2 ,
			 P_ATTRIBUTE3               IN      VARCHAR2 ,
			 P_ATTRIBUTE4               IN      VARCHAR2 ,
			 P_ATTRIBUTE5               IN      VARCHAR2 ,
			 P_ATTRIBUTE6               IN      VARCHAR2 ,
			 P_ATTRIBUTE7               IN      VARCHAR2 ,
			 P_ATTRIBUTE8               IN      VARCHAR2 ,
			 P_ATTRIBUTE9               IN      VARCHAR2 ,
			 P_ATTRIBUTE10              IN      VARCHAR2 ,
			 P_ATTRIBUTE11              IN      VARCHAR2 ,
			 P_ATTRIBUTE12              IN      VARCHAR2 ,
			 P_ATTRIBUTE13              IN      VARCHAR2 ,
			 P_ATTRIBUTE14              IN      VARCHAR2 ,
			 P_ATTRIBUTE15              IN      VARCHAR2 ,
			 P_PROPOSAL_ID              IN      NUMBER
			)  IS
	BEGIN
		NULL ;
	END create_installment ;


	-- ==========================================================================================
	-- Personal or Award Roles are user defined positions or functions that people perform in
	-- activities funded by an award. Each Personnel or Award Role is linked to an individual
	-- Award .
	-- ==========================================================================================
        -- +++++++++++++
	PROCEDURE CREATE_PERSONNEL
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_return_status            OUT NOCOPY     VARCHAR2 ,
			 X_PERSONNEL_ID             OUT NOCOPY     NUMBER ,
			 P_CALLING_MODULE           IN      VARCHAR2  ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE         IN      DATE   ,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE  ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_AWARD_ROLE_CODE          IN      VARCHAR2 ,
			 P_PERSON_ID                IN      VARCHAR2 ,
			 P_START_DATE_ACTIVE        IN      DATE ,
			 P_END_DATE_ACTIVE          IN      DATE ,
			 P_REQUIRED_FLAG            IN      VARCHAR2
 			)IS
	BEGIN
			NULL ;
	END create_personnel ;


	-- ===========================================================================
	-- Award terms and conditions are stipulated by the Grantor that are indicated
	-- in an agreement or contract.
	-- ===========================================================================
        -- +++++++++++++
	PROCEDURE CREATE_TERM_CONDITION
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_return_status            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE             IN      DATE   ,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_CATEGORY_NAME            IN      VARCHAR2 ,
			 P_TERM_ID                IN      NUMBER ,
			 P_OPERAND                  IN      VARCHAR2 ,
			 P_VALUE                    IN      NUMBER
			) is
	BEGIN
			NULL ;
	END create_term_condition ;


	-- =============================================================================
	-- Reference Numbers are user defined values or characters assigned to an award
	-- for identification purposes.
	-- =============================================================================
	PROCEDURE CREATE_REFERENCE_NUMBER
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_return_status            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE	    IN      DATE,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_REFERENCE_TYPE           IN      VARCHAR2 ,
			 P_REFERENCE_VALUE          IN      VARCHAR2 ,
			 P_REQUIRED_FLAG	    IN      VARCHAR2
			) is
	BEGIN
		NULL ;
	END create_reference_number ;


	-- ==========================================================
	-- Create Contacts
	-- ==========================================================

	PROCEDURE CREATE_CONTACT
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE	    IN      DATE,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_CONTACT_ID               IN      NUMBER ,
			 P_PRIMARY_FLAG	            IN      VARCHAR2 ,
			 P_USAGE_CODE	            IN      VARCHAR2
			) IS
	BEGIN
		NULL ;
	END create_contact ;

	-- ==========================================================
	-- Create Reports
	-- ==========================================================
	PROCEDURE CREATE_REPORT
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            OUT NOCOPY     VARCHAR2 ,
			 X_DEFAULT_REPORT_ID        OUT NOCOPY     NUMBER ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE	    IN      DATE,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_REPORT_NAME              IN      VARCHAR2 ,
			 P_FREQUENCY_CODE                IN      VARCHAR2 ,
			 P_DUE_WITHIN_DAYS          IN      NUMBER ,
			 P_SITE_USE_ID	            IN      NUMBER ,
			 P_NUMBER_OF_COPIES         IN      NUMBER
			) IS
	BEGIN
		NULL ;
	END create_report ;



END GMS_AWARD_PUB ;

/
