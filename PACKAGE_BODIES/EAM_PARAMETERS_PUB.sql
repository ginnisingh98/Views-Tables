--------------------------------------------------------
--  DDL for Package Body EAM_PARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PARAMETERS_PUB" AS
/* $Header: EAMPPRMB.pls 120.1 2005/06/17 01:57:35 appldev  $ */
-- Start of comments
--	API name 	: EAM_PARAMETERS_PUB
--	Type		: Public
--	Function	: insert_parameters, update_parameters
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	x.x
--				Changed....
--			  previous version	y.y
--				Changed....
--			  .
--			  .
--			  previous version	2.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_PARAMETERS_PUB';


/* for de-bugging */
 /*g_sr_no		number ;*/

PROCEDURE print_log(info varchar2) is
PRAGMA  AUTONOMOUS_TRANSACTION;
l_dummy number;
BEGIN
/*
if (g_sr_no is null or g_sr_no<0) then
		g_sr_no := 0;
	end if;

	g_sr_no := g_sr_no+1;

	INSERT into temp_isetup_api(msg,sr_no)
	VALUES (info,g_sr_no);

	commit;
*/
  FND_FILE.PUT_LINE(FND_FILE.LOG, info);

END;
-- There can be only one set of eam parameters for each unique organization_id.
-- This method is called only in the case of insertion.
FUNCTION validate_unique_org_id(p_organization_id in number)
      	return boolean is
        l_count number;
  BEGIN
        SELECT count(*) INTO l_count
	FROM   WIP_EAM_PARAMETERS
	WHERE  organization_id = p_organization_id;

        if l_count = 0
        then
            return false;
        else
            return true;
        end if;

END;

--funcation to validate if the provided lookup code is present forthe specified type.
FUNCTION validate_mfg_lookups(P_LOOKUP_TYPE IN VARCHAR2, P_LOOKUP_CODE in varchar2)
      	return boolean is
        l_count number;
  BEGIN
	if P_LOOKUP_TYPE = 'BOM_EAM_COST_CATEGORY' AND P_LOOKUP_CODE is null
        then
	        return false;
	elsif P_LOOKUP_CODE is null
	then
		return true;
        end if;

        SELECT count(*) INTO l_count
	FROM   mfg_lookups
	WHERE  lookup_type = P_LOOKUP_TYPE
	AND  lookup_code = P_LOOKUP_CODE;

        if l_count = 0
        then
            return false;
        else
            return true;
        end if;
END;

--function to validate the default cose element id
FUNCTION validate_cost_element_id(P_DEF_EAM_COST_ELEMENT_ID in number )
      	return boolean is
        l_count number;
  BEGIN
	if P_DEF_EAM_COST_ELEMENT_ID is null
        then
	        return false;
        end if;


        SELECT count(*) INTO l_count
	FROM   cst_eam_cost_elements
	WHERE  eam_cost_element_id = P_DEF_EAM_COST_ELEMENT_ID;

        if l_count = 0
        then
            return false;
        else
            return true;
        end if;
END;

--funciton to validate the wip entity class CLASS_TYPE = "Maintenance" <6>
FUNCTION validate_acnt_class(P_DEFAULT_EAM_CLASS in varchar2, P_ORGANIZATION_ID IN NUMBER)
      	return boolean is
        l_count number;
  BEGIN
  	if P_DEFAULT_EAM_CLASS is null
        then
	        return false;
        end if;

        SELECT count(*) INTO l_count
        from wip_accounting_classes
        where class_code = P_DEFAULT_EAM_CLASS
        and class_type = 6
        and organization_id = P_ORGANIZATION_ID;

        if l_count = 0
        then
            return false;
        else
            return true;
        end if;
END;

--VALIDATE THE ChartOfAccounts
FUNCTION validate_chart_of_accounts(P_MAINTENANCE_OFFSET_ACCOUNT in number,P_ORGANIZATION_ID IN NUMBER)
      	return boolean is
        l_count number;
	l_chart_of_accounts_id number;
  BEGIN

	if P_MAINTENANCE_OFFSET_ACCOUNT is null
        then
	        return false;
        end if;

	select chart_of_accounts_id into l_chart_of_accounts_id
	from gl_code_combinations
	where code_combination_id = P_MAINTENANCE_OFFSET_ACCOUNT;

	select count(*) into l_count
	from hr_organization_information hoi,
	gl_sets_of_books gsob
	where hoi.org_information_context = 'Accounting Information'
	and hoi.org_information1 = (gsob.set_of_books_id)
	and gsob.chart_of_accounts_id = l_chart_of_accounts_id
	and hoi.organization_id = P_ORGANIZATION_ID;

        if l_count = 0
        then
            return false;
        else
            return true;
        end if;
exception
	when no_data_found then
		 return false;
	when others then
		 return false;
END;

PROCEDURE validate_boolean_flag(p_flag IN VARCHAR2, p_msg IN VARCHAR2)
is
begin
	if(p_flag is not null)
	then
	  if not EAM_COMMON_UTILITIES_PVT.validate_boolean_flag(p_flag)
  	    then
	      fnd_message.set_name('EAM', p_msg);
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	    end if;
	end if;
end;

PROCEDURE validate_org_eam_enabled(p_organization_id in number)
is
l_count number :=0;
begin
      select count(*) into l_count
      from mtl_parameters where
      organization_id = p_organization_id
      and NVL(eam_enabled_flag,'N') = 'Y';

      if l_count = 0
      then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_ORG_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
      end if;


end;

PROCEDURE VALIDATE_ASSET_FLAG(P_DEFAULT_ASSET_FLAG IN VARCHAR2)
IS
l_count NUMBER;
l_installed boolean;
l_indust varchar2(10);
l_cs_installed  varchar2(10);

BEGIN
        -- check if the flag is valid
	validate_boolean_flag(P_DEFAULT_ASSET_FLAG, 'EAM_PAR_INV_ASSET_FLAG');

	-- if valid and 'Y' validate for pn should be installed.
	if p_default_asset_flag = 'Y'
	then
		l_installed := fnd_installation.get(appl_id => 240,
						    dep_appl_id =>240,
						    status => l_cs_installed,
						    industry => l_indust);
		IF (l_installed = FALSE)
		THEN
		      fnd_message.set_name('EAM', 'EAM_WR_PN_NOT_INSTALLED');
		      fnd_msg_pub.add;
		      RAISE fnd_api.g_exc_error;
 	        END IF;
 	 end if;
END;

procedure VALIDATE_ROW_EXISTS(p_ORGANIZATION_ID in number,
                              p_create_flag in boolean)
is
        l_count number;
  BEGIN
        SELECT COUNT(*) INTO l_count
	FROM WIP_EAM_PARAMETERS
	WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;

        if (l_count = 0 and NOT p_create_flag)
        then
	      fnd_message.set_name('EAM', 'EAM_PARAM_REC_NOT_FOUND');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        elsif (l_count >0 and p_create_flag)
           then
	      fnd_message.set_name('EAM', 'EAM_PARAM_REC_EXISTS');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        end if;
END;


PROCEDURE insert_parameters
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,

	x_return_status			OUT NOCOPY VARCHAR2		  	,
	x_msg_count			OUT NOCOPY NUMBER			,
	x_msg_data			OUT NOCOPY VARCHAR2			,

	P_ORGANIZATION_ID		IN	NUMBER		,
	P_WORK_REQUEST_AUTO_APPROVE	IN	VARCHAR2	default 'N',
	P_DEF_MAINT_COST_CATEGORY	IN	NUMBER		,
	P_DEF_EAM_COST_ELEMENT_ID	IN	NUMBER		,
	P_WORK_REQ_EXTENDED_LOG_FLAG	IN	VARCHAR2	default 'Y',
	P_DEFAULT_EAM_CLASS		IN	VARCHAR2  	,
	P_EASY_WORK_ORDER_PREFIX	IN	VARCHAR2	default null,
	P_WORK_ORDER_PREFIX		IN	VARCHAR2	default null,
	P_SERIAL_NUMBER_ENABLED		IN	VARCHAR2	default 'Y',
	P_AUTO_FIRM_FLAG		IN	VARCHAR2	default 'Y',
	P_MAINTENANCE_OFFSET_ACCOUNT	IN	NUMBER		default null,
	P_MATERIAL_ISSUE_BY_MO		IN	VARCHAR2	default 'Y',
	P_DEFAULT_DEPARTMENT_ID		IN	NUMBER		default null,
	P_INVOICE_BILLABLE_ITEMS_ONLY	IN	VARCHAR2	default 'N',
	P_OVERRIDE_BILL_AMOUNT		IN	VARCHAR2	default null,
	P_BILLING_BASIS			IN	NUMBER		default null,
	P_BILLING_METHOD		IN	NUMBER		default null,
	P_DYNAMIC_BILLING_ACTIVITY	IN	VARCHAR2	default null,
        P_DEFAULT_ASSET_FLAG     	IN	VARCHAR2	default 'Y' ,
	P_PM_IGNORE_MISSED_WO		IN 	VARCHAR2 	default 'N',
	p_issue_zero_cost_flag		IN 	varchar2	default 'Y',
	p_WORK_REQUEST_ASSET_NUM_REQD   IN	varchar2 	default 'Y',
	P_EAM_WO_WORKFLOW_ENABLED	IN	VARCHAR2	default null,
	P_AUTO_FIRM_ON_CREATE		IN	VARCHAR2	default null
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_parameters';
	l_api_version           	CONSTANT NUMBER 		:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	INSERT_PARAMETERS;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

	-- verify that all "not null" params are provided
	if (P_DEF_MAINT_COST_CATEGORY is null
		or P_DEF_EAM_COST_ELEMENT_ID is null
        	or P_DEFAULT_EAM_CLASS is null)
	then
	      fnd_message.set_name('EAM', 'EAM_NOT_ENOUGH_PARAMS');
              fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
	end if;

	--ver eam enabled
	validate_org_eam_enabled(p_organization_id);

        --verify default cost cat
	if not validate_mfg_lookups('BOM_EAM_COST_CATEGORY', P_DEF_MAINT_COST_CATEGORY)
	then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_COST_CAT');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	--VALIDATE Billing_BASIS
	if not validate_mfg_lookups('EAM_BILLING_BASIS', P_BILLING_BASIS)
	then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_BILLING_BASIS');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	-- VALIDATE BILLING_METHOD
	if not validate_mfg_lookups('EAM_BILLING_METHOD', P_BILLING_METHOD)
	then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_BILLING_METHOD');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	--ver def cost element id
	if not validate_cost_element_id(P_DEF_EAM_COST_ELEMENT_ID )
	then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_CST_ELMNT_ID');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;
	--ver wip acnt class
	if not validate_acnt_class(P_DEFAULT_EAM_CLASS , P_ORGANIZATION_ID )
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_CLASS_CODE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;
	--ver maint offset acnt
	if not validate_chart_of_accounts(P_MAINTENANCE_OFFSET_ACCOUNT ,P_ORGANIZATION_ID )
	then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_CHART_ACNT');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	-- validate default dept id
	if (p_default_department_id is not null and not eam_common_utilities_pvt.validate_department_id(p_default_department_id, p_organization_id)) then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_DEPT_ID');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	--varifyflag values 'Y' or 'N'
	--WorkRequestAutoApprove
	validate_boolean_flag(P_WORK_REQUEST_AUTO_APPROVE, 'EAM_PAR_INV_WORK_REQ_AUTO_APPR');
	--WorkReqExtendedLogFlag
	validate_boolean_flag(P_WORK_REQ_EXTENDED_LOG_FLAG, 'EAM_PAR_INV_WORK_REQ_LOG_FLAG');
	--SerialNumberEnabled
	validate_boolean_flag(P_SERIAL_NUMBER_ENABLED, 'EAM_PAR_INV_SERIAL_NUM_ENABLED');
	--AutoFirmFlag
	validate_boolean_flag(P_AUTO_FIRM_FLAG, 'EAM_PAR_INV_AUTO_FIRM_FLAG');
	--MaterialIssueByMo
	validate_boolean_flag(P_MATERIAL_ISSUE_BY_MO, 'EAM_PAR_INV_ISSUE_BY_MO');
	--InvoiceBillableItemsOnly
	validate_boolean_flag(P_INVOICE_BILLABLE_ITEMS_ONLY, 'EAM_PAR_INV_INVOICE_BLBLE_FLG');

	-- pm_ignore_missed_wo
	validate_boolean_flag(P_PM_IGNORE_MISSED_WO, 'EAM_PAR_PM_IGNORE_FLAG');

	-- issue_zero_cost_flag
	validate_boolean_flag(p_issue_zero_cost_flag, 'EAM_PAR_ZERO_COST_FLAG');

	-- WORK_REQUEST_ASSET_NUM_REQD
	validate_boolean_flag(p_WORK_REQUEST_ASSET_NUM_REQD, 'EAM_WORK_REQUEST_ASSET_NUM_REQ');

	VALIDATE_ASSET_FLAG(P_DEFAULT_ASSET_FLAG);


        VALIDATE_ROW_EXISTS(P_ORGANIZATION_ID, TRUE);

	validate_boolean_flag(P_EAM_WO_WORKFLOW_ENABLED, 'EAM_WO_WORKFLOW_ENABLED');
	validate_boolean_flag(P_AUTO_FIRM_ON_CREATE, 'EAM_AUTO_FIRM_ON_CREATE');

        INSERT INTO WIP_EAM_PARAMETERS
        (
		ORGANIZATION_ID	,
		WORK_REQUEST_AUTO_APPROVE	,
		DEF_MAINT_COST_CATEGORY	,
		DEF_EAM_COST_ELEMENT_ID	,
		WORK_REQ_EXTENDED_LOG_FLAG	,
		DEFAULT_EAM_CLASS	,
		EASY_WORK_ORDER_PREFIX	,
		WORK_ORDER_PREFIX	,
		SERIAL_NUMBER_ENABLED	,
		AUTO_FIRM_FLAG	,
		MAINTENANCE_OFFSET_ACCOUNT	,
		--WIP_EAM_REQUEST_TYPE	,
		MATERIAL_ISSUE_BY_MO	,
		DEFAULT_DEPARTMENT_ID	,
		INVOICE_BILLABLE_ITEMS_ONLY	,
		OVERRIDE_BILL_AMOUNT	,
		BILLING_BASIS	,
		BILLING_METHOD	,
		DYNAMIC_BILLING_ACTIVITY	,
		DEFAULT_ASSET_FLAG	,
		PM_IGNORE_MISSED_WO,
		issue_zero_cost_flag,
		WORK_REQUEST_ASSET_NUM_REQD,

		CREATED_BY           ,
		CREATION_DATE       ,
		LAST_UPDATE_LOGIN  ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATED_BY,
		EAM_WO_WORKFLOW_ENABLED,
		AUTO_FIRM_ON_CREATE
	)
	VALUES
	(
		P_ORGANIZATION_ID	,
		P_WORK_REQUEST_AUTO_APPROVE	,
		P_DEF_MAINT_COST_CATEGORY	,
		P_DEF_EAM_COST_ELEMENT_ID	,
		P_WORK_REQ_EXTENDED_LOG_FLAG	,
		P_DEFAULT_EAM_CLASS	,
		P_EASY_WORK_ORDER_PREFIX	,
		P_WORK_ORDER_PREFIX	,
		P_SERIAL_NUMBER_ENABLED	,
		P_AUTO_FIRM_FLAG	,
		P_MAINTENANCE_OFFSET_ACCOUNT	,
		--P_WIP_EAM_REQUEST_TYPE	,
		P_MATERIAL_ISSUE_BY_MO	,
		P_DEFAULT_DEPARTMENT_ID	,
		P_INVOICE_BILLABLE_ITEMS_ONLY	,
		P_OVERRIDE_BILL_AMOUNT	,
		P_BILLING_BASIS	,
		P_BILLING_METHOD	,
		P_DYNAMIC_BILLING_ACTIVITY	,
		P_DEFAULT_ASSET_FLAG           ,
		P_PM_IGNORE_MISSED_WO,
		p_issue_zero_cost_flag,
		p_WORK_REQUEST_ASSET_NUM_REQD,
		fnd_global.user_id,
		sysdate,
		fnd_global.login_id,
		sysdate    ,
		fnd_global.user_id,
		P_EAM_WO_WORKFLOW_ENABLED,
		P_AUTO_FIRM_ON_CREATE
	);

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO INSERT_PARAMETERS;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSERT_PARAMETERS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO INSERT_PARAMETERS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END insert_parameters;


PROCEDURE update_parameters
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,

	x_return_status			OUT NOCOPY VARCHAR2		  	,
	x_msg_count			OUT NOCOPY NUMBER				,
	x_msg_data			OUT NOCOPY VARCHAR2			,
	P_ORGANIZATION_ID		IN	NUMBER		,
	P_WORK_REQUEST_AUTO_APPROVE	IN	VARCHAR2	default 'N',
	P_DEF_MAINT_COST_CATEGORY	IN	NUMBER		,
	P_DEF_EAM_COST_ELEMENT_ID	IN	NUMBER		,
	P_WORK_REQ_EXTENDED_LOG_FLAG	IN	VARCHAR2	default 'Y',
	P_DEFAULT_EAM_CLASS		IN	VARCHAR2  	,
	P_EASY_WORK_ORDER_PREFIX	IN	VARCHAR2	default null,
	P_WORK_ORDER_PREFIX		IN	VARCHAR2	default null,
	P_SERIAL_NUMBER_ENABLED		IN	VARCHAR2	default 'Y',
	P_AUTO_FIRM_FLAG		IN	VARCHAR2	default 'Y',
	P_MAINTENANCE_OFFSET_ACCOUNT	IN	NUMBER		default null,
	P_MATERIAL_ISSUE_BY_MO		IN	VARCHAR2	default 'Y',
	P_DEFAULT_DEPARTMENT_ID		IN	NUMBER		default null,
	P_INVOICE_BILLABLE_ITEMS_ONLY	IN	VARCHAR2	default 'N',
	P_OVERRIDE_BILL_AMOUNT		IN	VARCHAR2	default null,
	P_BILLING_BASIS			IN	NUMBER		default null,
	P_BILLING_METHOD		IN	NUMBER		default null,
	P_DYNAMIC_BILLING_ACTIVITY	IN	VARCHAR2	default null,
        P_DEFAULT_ASSET_FLAG     	IN	VARCHAR2	default 'Y' ,
	P_PM_IGNORE_MISSED_WO		IN 	VARCHAR2 	default 'N',
	p_issue_zero_cost_flag		IN 	varchar2	default 'Y',
	p_WORK_REQUEST_ASSET_NUM_REQD	IN	varchar2	default 'Y',
	P_EAM_WO_WORKFLOW_ENABLED	IN	VARCHAR2	default null,
	P_AUTO_FIRM_ON_CREATE		IN	VARCHAR2	default null
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Update_parameters';
	l_api_version           	CONSTANT NUMBER 		:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	UPDATE_PARAMETERS;
    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

	-- verify that all "not null" params are provided
	if (P_DEF_MAINT_COST_CATEGORY is null
		or P_DEF_EAM_COST_ELEMENT_ID is null
        	or P_DEFAULT_EAM_CLASS is null)
	then
	      fnd_message.set_name('EAM', 'EAM_NOT_ENOUGH_PARAMS');
              fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
	end if;

	--ver eam enabled
	validate_org_eam_enabled(p_organization_id);

	if not validate_mfg_lookups('BOM_EAM_COST_CATEGORY', P_DEF_MAINT_COST_CATEGORY)
	then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_COST_CAT');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	if not validate_cost_element_id(P_DEF_EAM_COST_ELEMENT_ID )
	then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_CST_ELMNT_ID');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;
	if not validate_acnt_class(P_DEFAULT_EAM_CLASS , P_ORGANIZATION_ID )
	then
	      fnd_message.set_name('EAM', 'EAM_ABO_INVALID_CLASS_CODE');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	if not validate_chart_of_accounts(P_MAINTENANCE_OFFSET_ACCOUNT ,P_ORGANIZATION_ID )
	then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_CHART_ACNT');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	-- validate default dept id
	if (p_default_department_id is not null and not eam_common_utilities_pvt.validate_department_id(p_default_department_id, p_organization_id)) then
	      fnd_message.set_name('EAM', 'EAM_PAR_INVALID_DEPT_ID');
              fnd_msg_pub.add;
	      RAISE FND_API.G_EXC_ERROR;
	end if;

	--varifyflag values 'Y' or 'N'
	--WorkRequestAutoApprove
	validate_boolean_flag(P_WORK_REQUEST_AUTO_APPROVE, 'EAM_PAR_INV_WORK_REQ_AUTO_APPR');
	--WorkReqExtendedLogFlag
	validate_boolean_flag(P_WORK_REQ_EXTENDED_LOG_FLAG, 'EAM_PAR_INV_WORK_REQ_LOG_FLAG');
	--SerialNumberEnabled
	validate_boolean_flag(P_SERIAL_NUMBER_ENABLED, 'EAM_PAR_INV_SERIAL_NUM_ENABLED');
	--AutoFirmFlag
	validate_boolean_flag(P_AUTO_FIRM_FLAG, 'EAM_PAR_INV_AUTO_FIRM_FLAG');
	--MaterialIssueByMo
	validate_boolean_flag(P_MATERIAL_ISSUE_BY_MO, 'EAM_PAR_INV_ISSUE_BY_MO');
	--InvoiceBillableItemsOnly
	validate_boolean_flag(P_INVOICE_BILLABLE_ITEMS_ONLY, 'EAM_PAR_INV_INVOICE_BLBLE_FLG');

	-- issue_zero_cost_flag
	validate_boolean_flag(p_issue_zero_cost_flag, 'EAM_PAR_ZERO_COST_FLAG');

	-- WORK_REQUEST_ASSET_NUM_REQD
	validate_boolean_flag(p_WORK_REQUEST_ASSET_NUM_REQD, 'EAM_WORK_REQUEST_ASSET_NUM_REQ');

	VALIDATE_ASSET_FLAG(P_DEFAULT_ASSET_FLAG);

        VALIDATE_ROW_EXISTS(P_ORGANIZATION_ID, FALSE);

	validate_boolean_flag(P_EAM_WO_WORKFLOW_ENABLED, 'EAM_WO_WORKFLOW_ENABLED');
	validate_boolean_flag(P_AUTO_FIRM_ON_CREATE, 'EAM_AUTO_FIRM_ON_CREATE');


        UPDATE WIP_EAM_PARAMETERS
        SET
--		ORGANIZATION_ID		=	P_ORGANIZATION_ID	,
		WORK_REQUEST_AUTO_APPROVE	=	P_WORK_REQUEST_AUTO_APPROVE	,
		DEF_MAINT_COST_CATEGORY	=	P_DEF_MAINT_COST_CATEGORY	,
		DEF_EAM_COST_ELEMENT_ID	=	P_DEF_EAM_COST_ELEMENT_ID	,
		WORK_REQ_EXTENDED_LOG_FLAG      =	P_WORK_REQ_EXTENDED_LOG_FLAG	,
		DEFAULT_EAM_CLASS	=	P_DEFAULT_EAM_CLASS	,
		EASY_WORK_ORDER_PREFIX	=	P_EASY_WORK_ORDER_PREFIX	,
		WORK_ORDER_PREFIX	=	P_WORK_ORDER_PREFIX	,
		SERIAL_NUMBER_ENABLED	=	P_SERIAL_NUMBER_ENABLED	,
		AUTO_FIRM_FLAG		=	P_AUTO_FIRM_FLAG	,
		MAINTENANCE_OFFSET_ACCOUNT	=	P_MAINTENANCE_OFFSET_ACCOUNT	,
		--WIP_EAM_REQUEST_TYPE	=	P_WIP_EAM_REQUEST_TYPE	,
		MATERIAL_ISSUE_BY_MO	=	P_MATERIAL_ISSUE_BY_MO	,
		DEFAULT_DEPARTMENT_ID	=	P_DEFAULT_DEPARTMENT_ID	,
		INVOICE_BILLABLE_ITEMS_ONLY	=	P_INVOICE_BILLABLE_ITEMS_ONLY	,
		OVERRIDE_BILL_AMOUNT	=	P_OVERRIDE_BILL_AMOUNT	,
		BILLING_BASIS		=	P_BILLING_BASIS	,
		BILLING_METHOD		=	P_BILLING_METHOD	,
		DYNAMIC_BILLING_ACTIVITY=	P_DYNAMIC_BILLING_ACTIVITY	,
		DEFAULT_ASSET_FLAG    	= 	P_DEFAULT_ASSET_FLAG	,
		PM_IGNORE_MISSED_WO 	= 	p_pm_ignore_missed_wo,
		issue_zero_cost_flag	=	p_issue_zero_cost_flag,
		WORK_REQUEST_ASSET_NUM_REQD =	p_WORK_REQUEST_ASSET_NUM_REQD,

		LAST_UPDATE_LOGIN	=	fnd_global.login_id	,
		LAST_UPDATE_DATE	=	sysdate	,
		LAST_UPDATED_BY		=	fnd_global.user_id,
		EAM_WO_WORKFLOW_ENABLED	=	P_EAM_WO_WORKFLOW_ENABLED,
		AUTO_FIRM_ON_CREATE	=	P_AUTO_FIRM_ON_CREATE

	WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_PARAMETERS;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_PARAMETERS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_PARAMETERS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END update_parameters;


END EAM_PARAMETERS_PUB;

/
