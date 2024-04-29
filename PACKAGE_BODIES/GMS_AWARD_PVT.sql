--------------------------------------------------------
--  DDL for Package Body GMS_AWARD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARD_PVT" AS
-- $Header: gmsawpvb.pls 120.4.12010000.3 2008/12/02 14:42:31 rrambati ship $

	-- To check on, whether to print debug messages in log file or not
	L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

	G_award_rec    		GMS_AWARDS_ALL%ROWTYPE ;
	g_api_version_number    CONSTANT NUMBER := 1.0;
	g_pkg_name  		CONSTANT VARCHAR2(30) := 'GMS_AWARD_PVT';
	e_ver_mismatch	    	EXCEPTION ;

        G_personnel_rec		GMS_PERSONNEL%ROWTYPE ;
	G_reference_number_rec 	GMS_REFERENCE_NUMBERS%ROWTYPE ;
	G_contact_rec  		GMS_AWARDS_CONTACTS%ROWTYPE    ;
	G_report_rec  		GMS_DEFAULT_REPORTS%ROWTYPE    ;
	G_notification_rec 	GMS_NOTIFICATIONS%ROWTYPE    ;

	G_gmsimpl_rec		GMS_IMPLEMENTATIONS_ALL%ROWTYPE ;
	G_term_condition_rec    GMS_AWARDS_TERMS_CONDITIONS%ROWTYPE ;
	G_installment_rec	GMS_INSTALLMENTS%ROWTYPE ;
	G_msg_count		NUMBER ;

	G_msg_data	    	varchar2(2000) ;
	G_calling_module	varchar2(30) ;
	G_product_code		varchar2(3) 	:= 'GMS' ;
	G_stage	    		varchar2(80) ;

	G_pub_msg_int		BOOLEAN ;

	-- ================
	-- Contacts details used to create
	-- billing contacts.
	-- ================

	TYPE billing_contact_type is RECORD
	(
		customer_id	NUMBER,
		bill_to_address_id	NUMBER,
		ship_to_address_id	NUMBER,
		bill_to_contact_id	NUMBER,
		ship_to_contact_id	NUMBER
	) ;

	G_bill_contact_rec 	billing_contact_type ;


	-- ==============
	-- get_implementation_record is a program unit created
	-- to populate implementation record.
	-- ==============
	PROCEDURE get_implementation_record is
	BEGIN
		-- +++ FETCH Implementations Record +++
		IF g_award_rec.org_id is NULL THEN
			select *
			  into G_gmsimpl_rec
			  from gms_implementations_all
			 where org_id is NULL ;

		ELSE
			select *
			  into G_gmsimpl_rec
			  from gms_implementations_all
			 where org_id  = g_award_rec.org_id ;
		END IF ;
	END get_implementation_record ;

	-- ===================================================
	-- Utility Functions
	-- ===================================================
	PROCEDURE reset_message_flag is
	begin
		G_pub_msg_int := FALSE ;
	END reset_message_flag;

	-- =======
	-- init_message_stack
	-- Call FND_MSG_PUB to initialize the message stack.
	-- =======

	PROCEDURE init_message_stack is
	begin
		IF G_pub_msg_int THEN
		   NULL ;
		ELSE
		   FND_MSG_PUB.Initialize;
		   G_pub_msg_int := TRUE ;
		END IF ;
	END init_message_stack ;

	-- =======
	-- add_message_to_stack
	-- This procedure add messages to the stack table.
	-- =======

	PROCEDURE add_message_to_stack( P_Label	IN Varchar2,
				    P_token1	IN varchar2 DEFAULT NULL,
				    P_val1	IN varchar2 DEFAULT NULL,
				    P_token2	IN varchar2 DEFAULT NULL,
				    P_val2	in varchar2 DEFAULT NULL,
				    P_token3	IN varchar2 DEFAULT NULL,
				    P_val3	in varchar2 DEFAULT NULL ) is
		L_return_status	varchar2(2000) ;
	BEGIN

		IF  P_label is not NULL THEN
			fnd_message.set_name( 'GMS', P_Label ) ;
		ELSE
			return ;
		END IF ;

		IF P_token1 is not NULL then
			fnd_message.set_token(P_token1, P_val1 ) ;
		END IF ;

		IF P_token2 is not NULL then
			fnd_message.set_token(P_token2, P_val2 ) ;
		END IF ;

		IF P_token3 is not NULL then
			fnd_message.set_token(P_token3, P_val3 ) ;
		END IF ;

		fnd_msg_pub.add ;

		FND_MSG_PUB.Count_And_Get
				(   p_count  =>	G_msg_count	,
				    p_data   =>	G_msg_data	);

		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('Stage :'||G_stage||' Label :'||p_label, 'C');
		END IF;


		IF FND_MSG_PUB.check_msg_level( NVL(G_msg_count,0) ) THEN
			Raise FND_API.G_EXC_ERROR  ;
		ELSE
			NULL ;
		END  IF;

	END add_message_to_stack ;

	-- -----------------------------------------------------------
	-- X_RETURN_STATUS : <S>uccess, [E] Business Rule Violation
	-- U - Unexpected Error
	-- P_TYPE := B - Business Validations, E- Exception
	-- ----------------------------------------------------------

	PROCEDURE set_return_status(X_return_status IN OUT NOCOPY VARCHAR2,
				 p_type in varchar2 DEFAULT 'B' ) is
	begin

		IF p_type = 'B' THEN

			IF NVL(X_return_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS then
			   X_return_status := FND_API.G_RET_STS_ERROR ;
			END IF ;
		ELSE

			IF NVL(X_return_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS then
			   X_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			END IF ;
		END IF ;
	END set_return_status ;

	-- ==========================
	-- End of the utility functions.
	-- ============================



	-- --------------------------------------------------
	-- Define local procedure references to create_award
	-- --------------------------------------------------
	PROCEDURE create_agreement	( p_agreement_id  OUT NOCOPY NUMBER ) ;
	PROCEDURE validate_award	( X_return_status IN OUT NOCOPY varchar2) ;
	PROCEDURE create_award_project 	( X_return_status IN OUT NOCOPY varchar2,
					  p_setup_award_project_id NUMBER) ;
	PROCEDURE insert_award_record ( X_return_status in out NOCOPY varchar2) ;

	PROCEDURE validate_award_quick_entry ( X_return_status IN OUT NOCOPY varchar2 ) ;

	-- ===============================================================================
	-- CREATE AWARD BEGINS HERE
	--
	-- Procedure 		:	Create Award
	-- Calling Module	:	gms_award_pub.create_award
	--				Proposal
	--				Thi API creates an award project and award.
	-- ===============================================================================
	PROCEDURE create_award( 	x_msg_count		IN OUT NOCOPY	NUMBER	,
					x_msg_data		IN OUT NOCOPY	varchar2,
					X_return_status		IN OUT NOCOPY	varchar2,
					X_row_id		OUT NOCOPY	VARCHAR2,
					X_award_id		OUT NOCOPY	NUMBER 	,
					p_calling_module	IN	VARCHAR2 ,
					p_api_version_number	IN	NUMBER	,
					p_award_rec		IN	GMS_AWARDS_ALL%ROWTYPE	 )
	IS
		L_contact_rec		GMS_AWARDS_CONTACTS%ROWTYPE ;
		L_personnel_rec         gms_personnel%ROWTYPE ;

		L_setup_award_project_id        NUMBER ;


		L_org_id		NUMBER ;

		L_api_name              varchar2(30) := 'GMS_AWARD_PVT.CREATE_AWARD';
		L_row_id		varchar2(45) ;

		l_validate		BOOLEAN := FALSE ;

		-- ---------
		-- Cursor decalred to find out NOCOPY award project exists for a
		-- operating unit.
		-- ---------

		-- Bug Fix 3056424
		-- Modifying the following cursor to pick up the award project template
		-- whose value is still having -999 after multi org conversion.
		-- Please refer to bug 2447491 for further information on this issue.
		-- The segment1 can be either having org_id or -999 concatenated.
		-- So the where clause is rewritten to reflect the same.
		-- End of fix 3056424.

		CURSOR c_awd_project is
			Select project_id
	     		  from PA_PROJECTS_ALL
	     		 where project_type  	= 'AWARD_PROJECT'
	     		   and template_flag 	= 'Y'
	     		   and (segment1 	= 'AWD_PROJ_-999'
	     		    or segment1 	= 'AWD_PROJ_'||TO_CHAR(L_org_id))
     			   and rownum		= 1;

                --Bug : 3455542 : Added by Sanjay Banerjee
		--Rewriting the cursor to use HZ tables instead of RA Tables :TCA Changes
                CURSOR C_verify_con_exists(p_customer_id number) IS
                 SELECT 'X'
	         FROM 	Hz_party_sites party_site,
			Hz_locations loc,
			Hz_cust_acct_sites_all acct_site,
	                hz_cust_site_uses     su
	        WHERE   acct_site.cust_acct_site_id   = su.cust_acct_site_id
	        AND     acct_site.party_site_id       = party_site.party_site_id
	        AND     loc.location_id               = party_site.location_id
	        AND     acct_site.cust_account_id     = p_customer_id
	        AND     Nvl(su.Status, 'A')           = 'A'
	        AND     su.Site_Use_Code             IN ( 'BILL_TO', 'SHIP_TO')
	        AND     su.primary_flag               = 'Y'
                AND     su.Contact_Id IS NOT NULL;
                    l_con_exists  VARCHAR2(1);

		-- ============
		-- Procedure Created to set the default values
		-- ============

		PROCEDURE set_award_default_values (  X_return_status  IN OUT NOCOPY varchar2 ) IS
		BEGIN
			g_award_rec.revenue_distribution_rule := NVL(g_award_rec.revenue_distribution_rule,'COST' ) ;
			g_award_rec.billing_distribution_rule := NVL(g_award_rec.billing_distribution_rule,'COST' ) ;
			g_award_rec.amount_type 	      := NVL(g_award_rec.amount_type,'PJTD' ) ;
			g_award_rec.boundary_code 	      := NVL(g_award_rec.boundary_code,'J' ) ;
			g_award_rec.fund_control_level_award  := NVL(g_award_rec.fund_control_level_award,'B' ) ;
			g_award_rec.fund_control_level_task   := NVL(g_award_rec.fund_control_level_task,'D' ) ;
			g_award_rec.fund_control_level_res_grp:= NVL(g_award_rec.fund_control_level_res_grp,'D' ) ;
			g_award_rec.fund_control_level_res    := NVL(g_award_rec.fund_control_level_res,'D' ) ;
			g_award_rec.hard_limit_flag 	      := NVL(g_award_rec.hard_limit_flag,'N' ) ;
			g_award_rec.billing_offset  	      := NVL(g_award_rec.billing_offset ,'0' ) ;
			g_award_rec.billing_format  	      := NVL(g_award_rec.billing_format ,'NO_PRINT' ) ;
			g_award_rec.budget_wf_enabled_flag    := NVL(g_award_rec.budget_wf_enabled_flag,'N' ) ;
			g_award_rec.hard_limit_flag    	      := NVL(g_award_rec.hard_limit_flag,'N' ) ;
			g_award_rec.invoice_limit_flag        := NVL(g_award_rec.invoice_limit_flag,'N' ) ; /*Bug 6642901*/

			IF g_award_rec.award_template_flag = 'DEFERRED' then
				g_award_rec.template_start_date_active := NULL ;
				g_award_rec.template_end_date_active   := NULL ;
			END IF ;

		END set_award_default_values ;

		-- +++++++++++++++++
		--
		-- Populates the billing contacts record
		-- group here.
		--
		PROCEDURE get_award_contacts( X_return_status	IN OUT NOCOPY varchar2 ) is

			l_customer_id 	NUMBER ;
			l_bill_to_adr	NUMBER ;
			l_ship_to_adr	NUMBER ;
			l_bill_to_cont	NUMBER ;
			l_ship_to_cont	NUMBER ;
			l_error		BOOLEAN ;

			l_usage_code    varchar2(10) ;

			--
			-- Cursor to fetch the contact details.
			--TCA Enhancement : Replaced ra_address_all, ra_site_uses
		CURSOR C_cust_info is
                                SELECT acct_site.cust_acct_site_id,
                                       su.Contact_Id
                                 FROM  hz_cust_acct_sites_all acct_site,
					hz_party_sites party_site,
					hz_locations loc,
                                        Hz_cust_site_uses     su
                                 Where  acct_site.cust_acct_site_id     = su.cust_acct_site_id
				   And  acct_site.cust_account_id 	= l_Customer_Id
				   And  acct_site.party_site_id		= party_site.party_site_id
				   And  loc.location_id			= party_site.location_id
                                   And  Nvl(su.Status, 'A') 		= 'A'
                                   And  su.Site_Use_Code    		= l_usage_code
                                   And  su.primary_flag     		= 'Y' ;
		BEGIN
			IF g_award_rec.billing_format = 'LOC' THEN
				l_customer_id	:= g_award_rec.bill_to_customer_id ;
				l_bill_to_adr	:= g_award_rec.loc_bill_to_address_id ;
				l_ship_to_adr	:= g_award_rec.loc_ship_to_address_id ;
			ELSE
				l_customer_id	:= g_award_rec.funding_source_id ;
				l_bill_to_adr	:= g_award_rec.bill_to_address_id ;
				l_ship_to_adr	:= g_award_rec.ship_to_address_id ;
			END IF ;

			l_usage_code	:= 'BILL_TO' ;

			open c_cust_info ;
			fetch c_cust_info into l_bill_to_adr, l_bill_to_cont ;

			IF c_cust_info%NOTFOUND THEN

				-- MSG : GMS_NO_BILL_TO_ADDRESS
				-- MSG : GMS_NO_BILL_TO_CONTACT
				-- -----------------------------
				add_message_to_stack( P_label => 'GMS_NO_BILL_TO_ADDRESS' ) ;
				-- add_message_to_stack( P_label => 'GMS_NO_BILL_TO_CONTACT' ) ;
				set_return_status( X_return_status, 'B') ;
				l_error := TRUE ;
			END IF ;
			close c_cust_info ;

			l_usage_code	:= 'SHIP_TO' ;

			open c_cust_info ;
			fetch c_cust_info into l_ship_to_adr, l_ship_to_cont ;

			IF c_cust_info%NOTFOUND THEN

				-- MSG : GMS_NO_SHIP_TO_ADDRESS
				-- MSG : GMS_NO_SHIP_TO_CONTACT
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_NO_SHIP_TO_ADDRESS' ) ;
				-- add_message_to_stack( P_label => 'GMS_NO_SHIP_TO_CONTACT' ) ;
				set_return_status( X_return_status, 'B') ;
				l_error := TRUE ;
			END IF ;
			close c_cust_info ;

			IF L_error THEN
				set_return_status( X_return_status, 'B') ;
			ELSE
                     --columns are used in creating gms_awards_contacts records.
			    G_bill_contact_rec.bill_to_contact_id 	:= l_bill_to_cont ;
			    G_bill_contact_rec.ship_to_contact_id 	:= l_ship_to_cont ;
			    G_bill_contact_rec.customer_id		:= l_customer_id ;
			    G_bill_contact_rec.bill_to_address_id 	:= l_bill_to_adr ;
			    G_bill_contact_rec.ship_to_address_id 	:= l_ship_to_adr ;
                      --Bug : 3455542 : Added by Sanjay Banerjee
                      --Following address columns are always ment for 'funding source'
                      --customers ( for both LOC and Non-LOC ). Please do not copy LOC
                      --address on these columns. Otherwise funding_source_id will go
                      --out of sync with bill_to_address_id and ship_to_address_id.

                     --columns are used while creating record in gms_awards table.
			   IF g_award_rec.billing_format = 'LOC' THEN

                              --now we need to fill correct address for 'funding source'
			      l_customer_id	:= g_award_rec.funding_source_id ;
			      l_bill_to_adr	:= g_award_rec.bill_to_address_id ;
			      l_ship_to_adr	:= g_award_rec.ship_to_address_id ;

			      l_usage_code	:= 'BILL_TO' ;

			      open c_cust_info ;
			      fetch c_cust_info into l_bill_to_adr, l_bill_to_cont ;

			      IF c_cust_info%NOTFOUND THEN

				 add_message_to_stack( P_label => 'GMS_NO_BILL_TO_ADDRESS' ) ;
				 set_return_status( X_return_status, 'B') ;
				 l_error := TRUE ;
			      END IF ;
			      close c_cust_info ;

			      l_usage_code	:= 'SHIP_TO' ;

			      open c_cust_info ;
			      fetch c_cust_info into l_ship_to_adr, l_ship_to_cont ;

			      IF c_cust_info%NOTFOUND THEN

				 add_message_to_stack( P_label => 'GMS_NO_SHIP_TO_ADDRESS' ) ;
				 set_return_status( X_return_status, 'B') ;
				 l_error := TRUE ;
			      END IF ;
			      close c_cust_info ;

			      IF L_error THEN
		                 set_return_status( X_return_status, 'B') ;
                              END IF;

			    END IF ; /* LOC */

                      g_award_rec.bill_to_address_id            := l_bill_to_adr ;
                      g_award_rec.ship_to_address_id            := l_ship_to_adr ;

			END IF ;

		END get_award_contacts ;
		-- ===== End of proc_get_contacts ====

		--
		-- Check Not Null columns values here.
		--
		PROCEDURE verify_award_required_columns( X_return_status IN OUT NOCOPY varchar2 ) IS

			l_error BOOLEAN ;
		BEGIN
			l_error := FALSE ;

			IF g_award_rec.award_template_flag  is NULL THEN
				-- =============
				-- MSG: AWARD_TERMPLATE_UNDEFINED
				-- --------------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_TEMPLATE_FLAG_NULL' ) ;
				l_error := TRUE ;

			END IF ;

			IF g_award_rec.award_short_name is NULL  THEN

				-- ---------------------------------
				-- MSG: AWARD_SHORT_NAME_NULL
				-- ---------------------------------
				l_error := TRUE ;
				add_message_to_stack( P_label => 'GMS_AWD_SHORT_NAME_NULL' ) ;
			END IF ;

			IF L_error THEN
				set_return_status(X_return_status, 'B') ;
			END IF ;

			IF g_award_rec.award_template_flag <> 'DEFERRED' THEN
			   return ;
		        END IF ;

			IF g_award_rec.award_full_name is NULL  THEN
				-- ------------------------------
				-- MSG: AWARD_FULL_NAME_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_FULL_NAME_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.funding_source_id is NULL  THEN
				-- ------------------------------
				-- MSG: FUNDING_SOURCE_ID_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_FUND_SOURCE_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.start_date_active is NULL  THEN
				-- ------------------------------
				-- MSG: START_DATE_ACTIVE_IS_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_START_DT_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.end_date_active is NULL  THEN
				-- ------------------------------
				-- MSG: END_DATE_ACTIVE_IS_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_END_DT_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.close_date is NULL  THEN
				-- ------------------------------
				-- MSG: CLOSE_DATE_ACTIVE_IS_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_CLOSE_DT_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.funding_source_award_number is NULL  THEN
				-- ------------------------------
				-- MSG: FUNDING_SOURCE_AWD_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_FUND_SOURCE_NUM_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.award_purpose_code is NULL  THEN
				-- ------------------------------
				-- MSG: AWARD_PURPOSE_CODE_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_PURPOSE_CODE_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.status is NULL  THEN
				-- ------------------------------
				-- MSG: AWARD_STATUS_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_STATUS_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.allowable_schedule_id is NULL  THEN
				-- ------------------------------
				-- MSG: ALLOWABILITY_SCH_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_ALLOWABLE_SCH_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.idc_schedule_id is NULL  THEN
				-- ------------------------------
				-- MSG: INDIRECT_SCH_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_INDIRECT_SCH_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.revenue_distribution_rule is NULL  THEN
				-- ------------------------------
				-- MSG: REV_DIST_RULE_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_REV_DIST_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.billing_distribution_rule is NULL  THEN
				-- ------------------------------
				-- MSG: WBILL_DIST_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_BILL_DIST_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.award_manager_id is NULL  THEN
				-- ------------------------------
				-- MSG: AWARD_MANAGER_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_MANAGER_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.amount_type is NULL  THEN
				-- ------------------------------
				-- MSG: AMOUNT_TYPE_NULL
				-- ------------------------------
				l_error := TRUE ;
				add_message_to_stack( P_label => 'GMS_AWD_AMOUNT_TYPE_NULL' ) ;
			END IF ;

			IF g_award_rec.boundary_code is NULL  THEN
				-- ------------------------------
				-- MSG: BOUNDARY_CODE_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_BOUNDARY_CODE_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.type is NULL  THEN
				-- ------------------------------
				-- MSG: TYPE_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_TYPE_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.award_organization_id is NULL  THEN
				-- ------------------------------
				-- MSG: AWARD_ORG_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_ORGANIZATION_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.billing_cycle_id is NULL  THEN
				-- ------------------------------
				-- MSG: BILLING_CYCLE_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_BILL_CYCLE_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.billing_term is NULL  THEN
				-- ------------------------------
				-- MSG: BILLING_TERM_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_AWD_BILL_TERM_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.labor_invoice_format_id is NULL  THEN
				-- ------------------------------
				-- MSG: LABOR_INV_FORMAT_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_LABOR_INV_FORMAT_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF g_award_rec.non_labor_invoice_format_id is NULL  THEN
				-- ------------------------------
				-- MSG: NON_LABOR_INV_FORMAT_NULL
				-- ------------------------------
				add_message_to_stack( P_label => 'GMS_NONLABOR_INV_FORMAT_NULL' ) ;
				l_error := TRUE ;
			END IF ;

			IF L_error THEN
				set_return_status(X_return_status, 'B') ;
			END IF ;
		END verify_award_required_columns ;

		-- ======
		-- End of verify_award_required_columns
		-- ======

	BEGIN
		-- Initialize the message stack.
		-- -----------------------------
		init_message_stack;

		G_msg_count	  := x_msg_count ;
		G_msg_data	  := x_MSG_DATA ;
		G_calling_module  := P_CALLING_MODULE ;

		-- ============
		-- Initialize the return status.
		-- ============

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS) not in
		   ( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN

		    X_return_status := FND_API.G_RET_STS_SUCCESS ;

		END IF ;


		SAVEPOINT save_award_pvt ;

		-- ===================================================
		-- Need to set global variables to use PA public APIs.
		-- ===================================================

		G_stage := 'pa_interface_utils_pub.set_global_info';

	/*	pa_interface_utils_pub.set_global_info(p_api_version_number => 1.0,
                                       p_responsibility_id => FND_GLOBAL.resp_id,
                                       p_user_id => FND_GLOBAL.user_id,
                                       p_resp_appl_id => FND_GLOBAL.resp_appl_id, -- Bug 2534915
                                       p_msg_count  => x_msg_count,
                                       p_msg_data  =>x_msg_data,
                                       p_return_status   => x_return_status);

		IF x_return_status <> 'S'  THEN

			 add_message_to_stack( 	P_label 	=> 	'GMS_SET_GLOBAL_INFO_FAILED');
			 set_return_status ( X_return_status, 'U') ;

		END IF;

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ; */


		G_stage := 'FND_API.Compatible_API_Call' ;

  		IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
						     p_api_version_number	,
						     l_api_name 	    	,
						     G_pkg_name 	    	)
		THEN
			RAISE e_ver_mismatch ;
		END IF ;

		-- Set the record to the global variable
		--
		G_stage := 'proc_set_record(P_AWARD_REC)' ;

		G_award_rec	:= p_award_rec ;

		-- =======
		-- Fetch gms implementations record.
		-- =======
		G_stage := 'get_implementation_record' ;
		get_implementation_record ;

		G_stage := 'set_award_default_values' ;
		set_award_default_values (  X_return_status ) ;

		-- =============
		-- Determine the award project ID
		-- =============
		L_org_id	:= g_award_rec.org_id ;
		G_stage := 'Award Project Check' ;

		open c_awd_project ;
		fetch c_awd_project into l_setup_award_project_id ;

		IF c_awd_project%NOTFOUND THEN
			-- MSG : AWARD_PROJECT_NOT_FOUND
			-- raise exit process

			add_message_to_stack( P_label => 'GMS_AWD_PRJ_MISSING' ) ;
			set_return_status ( X_return_status, 'B') ;
			close c_awd_project ;
			Raise fnd_api.g_exc_error ;

		END IF ;

		close c_awd_project ;

		-- =============
		-- Determine the Bill/SHIP contact details
		-- =============
		G_stage := 'Proc_get_contacts ' ;
		get_award_contacts (  X_return_status ) ;

		-- =============
		-- Check The required Columns
		-- =============
		G_stage := 'Proc_check_required ' ;
		verify_award_required_columns(  X_return_status ) ;

		-- =============
		-- Award Quick Entry field validations.
		-- =============
		G_stage := 'Proc_quick_entry_checks ' ;
	        validate_award_quick_entry( X_return_status ) ;

		G_stage := 'Proc_validate_award ' ;
		validate_award(  X_return_status  ) ;

		-- =================
		-- Make sure that X_return_status is success before continue.
		-- =================
		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS THEN

			Raise fnd_api.g_exc_error ;
		END IF ;

			-- ********* ERROR Return Here ********
		-- =======
		-- All the validations are done.
		-- Creating the records in the tables.
		-- =======

		G_stage := 'Create_award_project ' ;
	        create_award_project (   X_return_status, l_setup_award_project_id ) ;

		-- =================
		-- Make sure that X_return_status is success before continue.
		-- =================
		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS THEN

			-- ********* ERROR Return Here ********
			Raise fnd_api.g_exc_error ;
		END IF ;

		G_stage := 'Insert_award ' ;
		insert_award_record ( X_return_status ) ;

		-- =================
		-- Make sure that X_return_status is success before continue.
		-- =================
		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS THEN

			-- ********* ERROR Return Here ********
			Raise fnd_api.g_exc_error ;
		END IF ;

 		-- ===============================================
 		-- Create Award Manger Personnel
 		-- ===============================================
 		IF X_return_status = FND_API.G_RET_STS_SUCCESS THEN

		    gms_award_manager_pkg.insert_award_manager_id ( g_award_rec.award_id,
								    g_award_rec.award_manager_id,
								    g_award_rec.start_date_active ) ;
 		END IF ;

 		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS THEN
 			Raise fnd_api.g_exc_error ;
 		END IF ;

		-- =============
		-- Creating Billing /Shipping contacts for award creation in progress.
		-- =============

            --Bug : 3455542 : Added by Sanjay Banerjee
            -- GMS_CON_CONTACT_ID_NULL : Please enter a Contact ID for this award
            -- Above error should be raised ONLY when BILL_TO and SHIP_TO both addresses
            -- are blank. Also, there's no point calling create_contact when contact_id
            -- itself is blank.
            --
              OPEN  C_verify_con_exists(G_bill_contact_rec.customer_id);
              FETCH  C_verify_con_exists
              INTO   l_con_exists;
              CLOSE  C_verify_con_exists;

		L_contact_rec.award_id		:= g_award_rec.award_id ;
		L_contact_rec.contact_id	:= G_bill_contact_rec.bill_to_contact_id ;
		L_contact_rec.customer_id	:= G_bill_contact_rec.customer_id ;
		L_contact_rec.primary_flag	:= 'Y' ;
		L_contact_rec.usage_code	:= 'BILL_TO' ;
		L_contact_rec.last_update_date	:= g_award_rec.last_update_date ;
		L_contact_rec.last_updated_by	:= g_award_rec.last_updated_by ;
		L_contact_rec.creation_date	:= g_award_rec.creation_date ;
		L_contact_rec.created_by	:= g_award_rec.created_by ;
		L_contact_rec.last_update_login	:= g_award_rec.last_update_login ;

		G_stage := 'Create_contact BILL_TO ' ;

             --Bug : 3455542 : Added by Sanjay Banerjee
             --Call this procedure ONLY if :
             --    1. BILL_TO and SHIP_TO both are missing
             --        AND
             --    2. Contact_Id Is NOT NULL

             IF ( l_con_exists IS NOT NULL AND L_contact_rec.contact_id IS NOT NULL ) OR
                ( l_con_exists IS NULL AND L_contact_rec.contact_id IS NULL )
             THEN

		  create_contact(   x_msg_count
                              , x_msg_data
                              , x_return_status
                              , l_row_id
                              , p_calling_module
                              , p_api_version_number
                              , TRUE
                              , l_contact_rec
                            );

		   -- =================
		   -- Make sure that X_return_status is success before continue.
		   -- =================
		   IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS THEN
			-- ********* ERROR Return Here ********
			Raise fnd_api.g_exc_error ;
		   END IF;
             END IF;

		L_contact_rec.contact_id	:= G_bill_contact_rec.ship_to_contact_id ;
		L_contact_rec.customer_id	:= G_bill_contact_rec.customer_id ;
		L_contact_rec.primary_flag	:= 'Y' ;
		L_contact_rec.usage_code	:= 'SHIP_TO' ;

		G_stage := 'Create_contact SHIP_TO ' ;

            --Bug : 3455542 : Added by Sanjay Banerjee
              IF ( l_con_exists IS NOT NULL AND L_contact_rec.contact_id IS NOT NULL ) OR
                 ( l_con_exists IS NULL AND L_contact_rec.contact_id IS NULL )
              THEN

		     create_contact(  x_msg_count
                                , x_msg_data
                                , x_return_status
                                , l_row_id
                                , p_calling_module
                                , p_api_version_number
                                , TRUE
                                , l_contact_rec
                               );

		   -- =================
               -- Make sure that X_return_status is success before continue.
               -- =================
		    IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS THEN

			-- ********* ERROR Return Here ********
			Raise fnd_api.g_exc_error ;
		    END IF ;
              END IF ;
		reset_message_flag ;
		x_award_id	:= G_award_rec.award_id ;


		G_stage := 'Award Created Successfully' ;
	EXCEPTION
		WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;

		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO save_award_pvt ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;
		WHEN OTHERS THEN
			ROLLBACK TO save_award_pvt;
			X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.add_exc_msg
					( p_pkg_name		=> G_PKG_NAME
					, p_procedure_name	=> l_api_name	);
			FND_MSG_PUB.Count_And_Get
					(   p_count		=>	x_msg_count	,
					    p_data		=>	x_msg_data	);

	END create_award ;

	-- ===================End Of Create award Here ======================
	--
	-- Quick Entry Column Validations.
	-- Award form has quick entry columns, These columns must have values.
	-- We check here quick entry columns to make sure these columns has
	-- data values.
	--
	PROCEDURE validate_award_quick_entry( X_return_status IN OUT NOCOPY varchar2 ) is

		l_error		BOOLEAN := FALSE ;
		x_dummy		NUMBER ;
		l_sch_type      varchar2(1) ;

		-- +++++++ LOV Validations +++++++
		-- Funding Source LOV validations.
		-- TCA Changes : Replacing ra_customers with HZ tables
		CURSOR c_fund_src is
		SELECT  cust_account_id
                FROM 	hz_cust_accounts
                WHERE 	status = 'A'
                AND 	cust_account_id = g_award_rec.funding_source_id ;

		-- Lookup LOV validations
		--
		CURSOR c_lookups( p_lookup_type varchar2, p_code varchar2) is
			SELECT 1
			  FROM gms_lookups
			 WHERE lookup_type = p_lookup_type
			   and lookup_code = p_code ;

		-- Allowability Schedule LOV Validation
		CURSOR C_allowable_sch is
			SELECT 1
			  FROM gms_allowability_schedules
			 WHERE allowability_schedule_id = g_award_rec.allowable_schedule_id ;

		CURSOR C_idc_cost_sch is
			SELECT ind_rate_schedule_type
			  FROM pa_ind_rate_schedules
			 WHERE ind_rate_sch_id = g_award_rec.idc_schedule_id
			   and trunc(sysdate) between start_date_active and NVL(end_date_active, (SYSDATE+1)) ;

		  cursor C_billing_term is
			SELECT 1
			  FROM ra_terms
			 WHERE term_id = g_award_rec.billing_term ;


		  cursor C_invoice_format(x_formatID NUMBER,x_format varchar2 ) is
			SELECT 1
			  FROM pa_invoice_groups  inv_grp,
			       pa_invoice_formats inv_fmt
			 WHERE inv_grp.invoice_group_id = inv_fmt.invoice_group_id
			   and inv_fmt.invoice_format_id = x_formatID
			   and inv_grp.invoice_format_type = x_format ;

		  cursor C_awd_org is
			SELECT 1
			  FROM pa_organizations_lov_v
			 WHERE code = g_award_rec.award_organization_id ;

		  cursor C_billing_cycle is
			SELECT 1
			  FROM pa_billing_cycles
			 WHERE trunc(sysdate) between start_date_active and NVL( end_date_active, sysdate )
			   and billing_cycle_id = g_award_rec.billing_cycle_id ;

	BEGIN

		-- =====
		-- Validate award_template_flag
		-- =====
		IF g_award_rec.award_template_flag not in ('DEFERRED', 'IMMEDIATE' ) then

			-- =============
			-- MSG: AWARD_TERMPLATE_INVALID
			-- --------------------------------------
			add_message_to_stack( P_label => 'GMS_AWD_TEMPLATE_INVALID' ) ;
			l_error := TRUE ;

			-- Serious error ...
		END IF ;

		--
		-- Validate Funding source columns.
		--

		IF g_award_rec.funding_source_id is not NULL then
			open C_FUND_SRC ;
			fetch C_FUND_SRC into x_dummy ;

			IF C_FUND_SRC%NOTFOUND THEN
				 add_message_to_stack( P_label => 'GMS_FUND_SOURC_INVALID' ) ;
				 l_error := TRUE ;
			END IF ;

			CLOSE C_FUND_SRC ;
		END IF ;


		--
		-- Validate award purpose code.
		--

		IF g_award_rec.award_purpose_code is not NULL then
			open C_lookups( 'AWARD_PURPOSE_CODE', g_award_rec.award_purpose_code ) ;
			fetch C_lookups into x_dummy ;

			IF C_lookups%NOTFOUND THEN
    			 	add_message_to_stack( P_label => 'GMS_AWD_PURPOSE_CD_INVALID' ) ;
			     	l_error := TRUE ;
			END IF ;

			CLOSE C_lookups ;
		END IF ;

		--
		-- validate award status
		--

		IF g_award_rec.status is not NULL then
			open C_lookups( 'AWARD_STATUS', g_award_rec.status ) ;
			fetch C_lookups into x_dummy ;

			IF C_lookups%NOTFOUND THEN
    			 	add_message_to_stack( P_label => 'GMS_AWD_STATUS_INVALID' ) ;
			     	l_error := TRUE ;
			END IF ;

			CLOSE C_lookups ;
		END IF ;

		-- ------------------------------------------------
		-- Amount type boundary code validations.
		-- ------------------------------------------------
		IF g_award_rec.amount_type is not NULL then

			open C_lookups( 'AMOUNT_TYPE', g_award_rec.amount_type ) ;
			fetch C_lookups into x_dummy ;

			IF C_lookups%NOTFOUND THEN
    			 	add_message_to_stack( P_label => 'GMS_AWD_AMOUNT_TYPE_INVALID' ) ;
			     	l_error := TRUE ;
			END IF ;

			CLOSE C_lookups ;

			IF g_award_rec.amount_type = 'YTD' THEN
				IF NVL(g_award_rec.boundary_code,'P') not in ( 'P','Y' ) THEN
      			  		 add_message_to_stack( P_label => 'GMS_BOUNDARY_CD_YTD_INVALID' ) ;
			       		 l_error := TRUE ;
				END IF ;
			ELSIF g_award_rec.amount_type = 'PTD' THEN
				IF NVL(g_award_rec.boundary_code,'P') <> 'P' THEN
      			  		 add_message_to_stack( P_label => 'GMS_BOUNDARY_CD_PTD_INVALID' ) ;
			       		l_error := TRUE ;
				END IF ;
			END IF ;

		END IF ;

		--
		-- validate allowable expenditures
		--
		IF g_award_rec.allowable_schedule_id is not NULL then
			open C_allowable_sch ;
			fetch C_allowable_sch into x_dummy ;
			IF C_allowable_sch%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_AWD_ALLOWABLE_SCH_INVALID' ) ;
			        l_error := TRUE ;
			END IF ;
			CLOSE C_allowable_sch ;
		END IF ;

		--
		-- validate indirect cost schedule.
		--

		IF g_award_rec.idc_schedule_id is not NULL then
			open C_idc_cost_sch ;
			fetch C_idc_cost_sch into l_sch_type ;
			IF C_idc_cost_sch%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_IDC_SCH_INVALID' ) ;
			        l_error := TRUE ;
			END IF ;
			CLOSE C_idc_cost_sch ;
		END IF ;

		-- The provisional Schedule should have IDC_fixed_date NULL.
		IF NVL(l_sch_type,'F') = 'P' THEN
			IF g_award_rec.cost_ind_sch_fixed_date is not NULL THEN
				add_message_to_stack( P_label => 'GMS_IDC_FIXED_DATE_NOT_NULL' ) ;
				l_error := TRUE ;
			END IF ;
		END IF ;

		/*  Removed validation as requested by Ashish
		-- The firm Schedule should have IDC_fixed_date.
		IF NVL(l_sch_type,'F') = 'F' THEN
			IF g_award_rec.cost_ind_sch_fixed_date is  NULL THEN
				add_message_to_stack( P_label => 'GMS_IDC_FIXED_DATE_NULL' ) ;
				l_error := TRUE ;
			END IF ;
		END IF ;
		*/
		--
		-- Validate billing terms
		--
		IF g_award_rec.billing_term is not NULL then
			open C_billing_term ;
			fetch C_billing_term into x_dummy ;
			IF C_billing_term%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_BILL_TERM_INVALID' ) ;
			        l_error := TRUE ;
			END IF ;
			CLOSE C_billing_term ;
		END IF ;

		--
		-- validate labor invoice formats
		--
		IF g_award_rec.labor_invoice_format_id  is not NULL then
			open C_invoice_format(g_award_rec.labor_invoice_format_id, 'LABOR') ;
			fetch C_invoice_format into x_dummy ;
			IF C_invoice_format%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_LABOR_INV_FMT_INVALID' ) ;
			       	l_error := TRUE ;
			END IF ;
			CLOSE C_invoice_format ;
		END IF ;

		--
		-- validate non labor invoice formats.
		--
		IF g_award_rec.non_labor_invoice_format_id  is not NULL then
			open C_invoice_format(g_award_rec.non_labor_invoice_format_id, 'NON-LABOR') ;
			fetch C_invoice_format into x_dummy ;
			IF C_invoice_format%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_NONLABOR_INV_FMT_INVALID' ) ;
			       	l_error := TRUE ;
			END IF ;
			CLOSE C_invoice_format ;
		END IF ;

		--
		-- validate award organization
		--

		IF g_award_rec.award_organization_id  is not NULL then
			open C_awd_org ;
			fetch C_awd_org into x_dummy ;
			IF C_awd_org%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_AWD_ORG_INVALID' ) ;
			       	l_error := TRUE ;
			END IF ;
			CLOSE C_awd_org ;
		END IF ;

		--
		-- validate billing cycle.
		--

		IF g_award_rec.billing_cycle_id  is not NULL then
			open C_billing_cycle ;
			fetch C_billing_cycle into x_dummy ;

			IF C_billing_cycle%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_BILL_CYCLE_INVALID' ) ;
			       	l_error := TRUE ;
			END IF ;

			CLOSE C_billing_cycle ;

		END IF ;

		-- ===============================
		-- Validate FlexFields
		-- ===============================
		IF g_award_rec.attribute_category is not NULL THEN

			fnd_flex_descval.set_context_value(g_award_rec.attribute_category) ;

			fnd_flex_descval.set_column_value('ATTRIBUTE1',g_award_rec.attribute1) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE2',g_award_rec.attribute2) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE3',g_award_rec.attribute3) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE4',g_award_rec.attribute4) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE5',g_award_rec.attribute5) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE6',g_award_rec.attribute6) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE7',g_award_rec.attribute7) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE8',g_award_rec.attribute8) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE9',g_award_rec.attribute9) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE10',g_award_rec.attribute10) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE11',g_award_rec.attribute11) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE12',g_award_rec.attribute12) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE13',g_award_rec.attribute13) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE14',g_award_rec.attribute14) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE15',g_award_rec.attribute15) ;
         		fnd_flex_descval.set_column_value('ATTRIBUTE16',g_award_rec.attribute16) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE17',g_award_rec.attribute17) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE18',g_award_rec.attribute18) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE19',g_award_rec.attribute19) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE20',g_award_rec.attribute20) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE21',g_award_rec.attribute21) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE22',g_award_rec.attribute22) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE23',g_award_rec.attribute23) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE24',g_award_rec.attribute24) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE25',g_award_rec.attribute25) ;

			IF (FND_FLEX_DESCVAL.validate_desccols ('GMS' ,'GMS_AWARDS_DESC_FLEX')) then
				-- Validation Passed
				NULL ;
			ELSE
      			   	add_message_to_stack( P_label => 'GMS_AWD_FLEX_INVALID' ) ;
				fnd_msg_pub.add_exc_msg(p_pkg_name       => 'GMS_AWARD_PVT',
							p_procedure_name => 'CREATE_AWARD',
							p_error_text     => substr(FND_FLEX_DESCVAL.error_message,1,240)) ;
			       	l_error := TRUE ;

			END IF ;

		END IF ;

		-- ------------------
		-- End of flex fields validations.
		-- ------------------


		IF l_error THEN
			set_return_status(X_return_status,'B') ;
		END IF ;

		-- +++++++++++ billing dist rule validation ++++++++++

	END validate_award_quick_entry ;

	-- ======= End Of validate_award_quick_entry ======

	--
	-- award automatic numbering generates award number automatic.
	-- following function returns the valid award number.
	--

	FUNCTION func_get_award_num return number IS
		l_dummy	NUMBER ;
	begin

	       SELECT nvl(next_unique_identifier,0)
		     into l_dummy
		     FROM gms_unique_identifier_control
		    WHERE table_name = 'GMS_AWARDS'
		      FOR update of next_unique_identifier;

	       UPDATE gms_unique_identifier_control
		  SET next_unique_identifier = l_dummy + 1,
		      last_update_date       = trunc(sysdate) ,
		      last_updated_by        = 0
		WHERE table_name = 'GMS_AWARDS';

	       return l_dummy ;

	END func_get_award_num ;

	-- ==== End Of func_get_award_num ====


	-- +++++++++++++++++
	-- Validate Generic award validations. Here we validate
	-- Dates agains PA and GL periods
	-- Multiple columns related validations.
	-- Some Lov Validations
	-- Unique Coolumn Value validations.
	--
	PROCEDURE validate_award( 	X_return_status	IN out NOCOPY varchar2) IS

  		   x_dummy 		number := 0;
		   x_agreement_type	pa_agreement_types.agreement_type%TYPE ;
  		   x_awd_snm 		gms_awards_all.award_short_name%TYPE;
		   L_error		BOOLEAN := FALSE ;

       	  	   Project_Check  	NUMBER(2) := 0;

		   CURSOR C1 is
     			select decode(NAME, g_award_rec.award_number,1,2)
                          from PA_PROJECTS
      			 where ( NAME = g_award_rec.award_number
				 OR  SEGMENT1 = g_award_rec.award_number) ;

 		   cursor C_AWDNUM_DUP is
			select award_id
			  from gms_awards_all
			 where award_number = g_award_rec.award_number ;

 		   cursor C_AWDSNM_DUP is
			select award_id
			  from gms_awards_all
			 where award_SHORT_NAME = g_award_rec.award_short_name ;

                  /* Bug 2534936

		  cursor C_awd_manager is
			SELECT 1, gmsp.start_date_active, end_date_active
			  FROM per_assignments_f pera,
			       gms_personnel 	 gmsp
			 WHERE pera.person_id 	= g_award_rec.award_manager_id
			   and trunc(sysdate) between pera.effective_start_date
						  and pera.effective_end_date
			   and pera.primary_flag = 'Y'
			   and pera.person_id	 = gmsp.person_id
			   and gmsp.award_role   = 'AM'
			   and SYSDATE BETWEEN NVL (Start_Date_Active, SYSDATE-1)
				AND     NVL (End_Date_Active, SYSDATE+1)
			   and pera.assignment_type = 'E' ;

                  */

		  CURSOR c_awd_manager IS
                  SELECT 1
                  FROM   pa_implementations i,
                         pa_employees e,
                         per_assignments_f a
                  WHERE  e.business_group_id = i.business_group_id
                  AND    e.person_id = g_award_rec.award_manager_id
                  AND    a.person_id = e.person_id
                  AND    trunc(sysdate) BETWEEN a.effective_start_date AND a.effective_end_date
                  AND    a.primary_flag = 'Y'
                  AND    a.assignment_type = 'E';

		  cursor c_pa_period(x_date date) is
		    select count(*) from pa_periods pap
		     where  x_date between pap.start_date and pap.end_date ;

		  cursor c_gl_period(x_date date) is
			  select 1
                            from gl_period_statuses gps
			   where x_date between gps.start_date
                                            and gps.end_date
			     and gps.application_id = 101
			     and gps.set_of_books_id = (select set_of_books_id
                                                          from pa_implementations);

                         /* Bug# 3985020 : Commented
			  select count(*) from gl_period_statuses gps
			   where x_date between gps.start_date and gps.end_date
			     and    gps.application_id = 101
			     and    gps.set_of_books_id in (select set_of_books_id from pa_implementations_all);
                          */

		  cursor C_agreement is
			SELECT agreement_type
			  FROM pa_agreement_types
			 WHERE agreement_type = g_award_rec.type ;

-- Debashis. Added exists clause. Removed rownum.
		  CURSOR C_fnd_user is
		   select 1 from dual where exists (
		   select user_id
		     from fnd_user
		    where employee_id = g_award_rec.award_manager_id);
		 --     and rownum = 1 ;
	BEGIN
		-- +++ Check Automatic Number validations +++
		IF G_gmsimpl_rec.user_defined_award_num_code = 'A'
		and g_award_rec.award_number is not NULL THEN

			-- ERROR Automatic Numbering issue.
			-- Question Do we need to override
			-- This or raise an error.
      			add_message_to_stack( P_label => 'GMS_AWD_NUMBER_NOT_NULL' ) ;
			l_error := TRUE ;

		ELSIF G_gmsimpl_rec.user_defined_award_num_code = 'A'
		  AND g_award_rec.award_number is NULL THEN

			g_award_rec.award_number := func_get_award_num ;
		END IF ;

		IF g_award_rec.award_number is NULL THEN

			-- ------------------------------
			-- MSG: AWARD_NUMBER_NULL
			-- ------------------------------
			l_error := TRUE ;
			add_message_to_stack( P_label => 'GMS_AWD_NUMBER_NULL' ) ;
		END IF ;

		BEGIN
			IF g_award_rec.award_number is not NULL THEN

				IF  G_gmsimpl_rec.user_defined_award_num_code = 'M'
				and G_gmsimpl_rec.manual_award_num_type = 'NUMERIC'
				THEN
					g_award_rec.award_number := to_number(g_award_rec.award_number) ;
				END IF ;

			END IF ;
		EXCEPTION
			when VALUE_ERROR THEN
				-- ERROR ( Award Number should be NUMERIC.
			    add_message_to_stack( P_label => 'GMS_AWD_NUMBER_NOT_NUMERIC' ) ;
			    l_error := TRUE ;
		END ;


		-- ========================
		-- Award number is invalid. So we can not
		-- continue award number further checks.
		-- ========================
		IF not l_error then
			open C1 ;
			fetch C1 into project_check ;
			close C1 ;

			If Project_Check = 1 then
				add_message_to_stack( P_label => 'GMS_AWD_PRJNAME_EXISTS' ) ;
				l_error := TRUE ;
			ELSIF Project_Check = 2 THEN

				add_message_to_stack( P_label => 'GMS_AWD_PRJNUM_EXISTS' ) ;
				l_error := TRUE ;
			END IF ;
		END IF ;

		-- +++++++++++ award Number Validations ++++++++++
		open C_AWDNUM_DUP ;
		fetch C_AWDNUM_DUP into x_dummy ;
		close C_AWDNUM_DUP ;

		IF x_dummy > 0 THEN
			-- ERROR (GMS_AWD_NUMBER_DUP) ;
			-- MSG : Duplicate Award Number
			-- ----------------------------
			add_message_to_stack( P_label => 'GMS_AWD_NUMBER_DUP' ) ;
			l_error := TRUE ;
		END IF ;
		x_dummy := 0 ;

		--open C_AWDSNM_DUP ;
		--fetch C_AWDSNM_DUP into x_AWD_SNM ;
		--IF C_AWDSNM_DUP%FOUND THEN
			-- ERROR (GMS_AWD_NUMBER_DUP) ;
			-- MSG : Duplicate Award Number
			-- ----------------------------
		--	add_message_to_stack( P_label => 'GMS_AWD_SHORT_NAME_DUP' ) ;
		--	l_error := TRUE ;
		--END IF ;
		--close C_AWDSNM_DUP ;


		-- ++++++++++  Validate LOV data ++++++++++++++++
		IF g_award_rec.award_manager_id is not NULL then
			open C_awd_manager ;
			fetch C_awd_manager into x_dummy; -- Bug 2534936

			IF C_awd_manager%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_AWD_MANAGER_INVALID' ) ;
		       		l_error := TRUE ;
			END IF ;
			CLOSE C_awd_manager ;
		END IF ;

		-- ==================
		-- Award manager must be FND_USER for budget_wf_enabled_flag
		-- ================

		IF G_award_rec.budget_wf_enabled_flag = 'Y' THEN
			open c_fnd_user ;
			fetch c_fnd_user into x_dummy ;
			IF c_fnd_user%NOTFOUND then
      			   	add_message_to_stack( P_label => 'GMS_AWD_MGR_NOT_FND_USER' ) ;
		       		l_error := TRUE ;
			end if ;
			close c_fnd_user ;
		END IF ;

		IF G_award_rec.budget_wf_enabled_flag NOT IN ( 'Y', 'N' ) THEN
			  add_message_to_stack( P_label => 'GMS_AWD_WORKFLOW_FLAG_INVALID') ;
			  l_error := TRUE ;
		END IF ;


		IF g_award_rec.type  is not NULL then
			open C_agreement ;
			fetch C_agreement into x_agreement_type ;
			IF C_agreement%NOTFOUND THEN
      			   	add_message_to_stack( P_label => 'GMS_AGREEMENT_TYPE_INVALID' ) ;
			       	l_error := TRUE ;
			END IF ;
			CLOSE C_agreement ;
		END IF ;


		IF g_award_rec.billing_format = 'LOC' and
		   g_award_rec.bill_to_customer_id is NULL
		THEN

			-- ERROR 'Bill to customer ID is missing.
      			add_message_to_stack( P_label => 'GMS_NO_BILL_TO_CUST_LOC' ) ;
			l_error := TRUE ;
		END IF ;

 		-- =======
 		-- Billing Format Validations
 		-- =======
 		IF NVL(g_award_rec.billing_format,'LOC') NOT IN
 		   ( 'NO_PRINT', 'PRINT_INVOICE', 'LOC', 'AGENCY','EDI' ) THEN
 				add_message_to_stack( P_label => 'GMS_BILLING_FORMAT_INVALID' ) ;
 				l_error := TRUE ;
 		END IF ;

 		IF NVL(g_award_rec.billing_format,'EDI') <> 'EDI'
 		     and g_award_rec.transaction_number is not NULL THEN
 			add_message_to_stack( P_label => 'GMS_TRANS_NUMBER_NULL' ) ;
 			l_error := TRUE ;
 		END IF ;

 		IF NVL(g_award_rec.billing_format,'LOC') <> 'LOC'
 		     and g_award_rec.bill_to_customer_id is not NULL THEN
 			add_message_to_stack( P_label => 'GMS_BILL_TO_CUSTLOC_NULL' ) ;
 			l_error := TRUE ;
 		END IF ;

 		IF NVL(g_award_rec.billing_format,'AGENCY') <> 'AGENCY'
 		     and g_award_rec.agency_specific_form is not NULL THEN
 			add_message_to_stack( P_label => 'GMS_AGENCY_FORM_NULL' ) ;
 			l_error := TRUE ;
 		END IF ;

		-- ++++++++++ Check PA periods ++++++++++++++++++
		open C_pa_period(g_award_rec.start_date_active) ;
		fetch C_pa_period into x_dummy ;
		close c_pa_period ;

		IF x_dummy  = 0 THEN
			-- ERROR GMS_AWD_DATE_EXZ_PA_DATE
			add_message_to_stack( P_label => 'GMS_AWD_START_DATE_NOT_PAPRD' ) ;
			l_error := TRUE ;
		END IF ;
		x_dummy := 0 ;

		open C_pa_period(g_award_rec.end_date_active) ;
		fetch C_pa_period into x_dummy ;
		close c_pa_period ;
		IF x_dummy  = 0 THEN
			add_message_to_stack( P_label => 'GMS_AWD_END_DATE_NOT_PAPRD' ) ;
			l_error := TRUE ;
		END IF ;

		x_dummy := 0 ;
/* commented the close_date validation against open pa periods for bug 7603285*/
		/*open C_pa_period(g_award_rec.close_date) ;
		fetch C_pa_period into x_dummy ;
		close c_pa_period ;
		IF x_dummy  = 0 THEN
			add_message_to_stack( P_label => 'GMS_AWD_CLOSE_DATE_NOT_PAPRD' ) ;
			l_error := TRUE ;
		END IF ;

		x_dummy := 0 ; */


		IF g_award_rec.preaward_date is not NULL THEN

			open C_pa_period(g_award_rec.preaward_date) ;
			fetch C_pa_period into x_dummy ;
			close c_pa_period ;
			IF x_dummy  = 0 THEN
				--ERROR  GMS_AWD_DATE_EXZ_PA_DATE
				add_message_to_stack( P_label => 'GMS_AWD_PRE_DATE_NOT_PAPRD' ) ;
				l_error := TRUE ;
			END IF ;

			open c_gl_period(g_award_rec.preaward_date) ;
			fetch c_gl_period into x_dummy ;
			close c_gl_period ;

                        --Bug# 3985020 : Added NVL as aggregate function count was removed.
			IF nvl(x_dummy,0)  = 0 THEN
				--ERROR  GMS_AWD_DATE_EXZ_GL_DAT
				add_message_to_stack( P_label => 'GMS_AWD_PRE_DATE_NOT_GL' ) ;
				l_error := TRUE ;
			END IF ;
			x_dummy := 0 ;
		END IF ;

		-- ++++++++++ Check GL periods ++++++++++++++++++

		open c_gl_period(g_award_rec.start_date_active) ;
		fetch c_gl_period into x_dummy ;
		close c_gl_period ;
                --Bug# 3985020 : Added NVL as aggregate function count was removed.
		IF nvl(x_dummy,0)  = 0 THEN
			--ERROR  GMS_AWD_DATE_EXZ_GL_DAT
          		add_message_to_stack( P_label => 'GMS_AWD_START_DATE_NOT_GL' ) ;
    			l_error := TRUE ;
		END IF ;
		x_dummy := 0 ;

		open C_gl_period(g_award_rec.end_date_active) ;
		fetch C_gl_period into x_dummy ;
		close c_gl_period ;
                --Bug# 3985020 : Added NVL as aggregate function count was removed.
		IF nvl(x_dummy,0) = 0 THEN
			--ERROR  GMS_AWD_DATE_EXZ_GL_DAT
          		add_message_to_stack( P_label => 'GMS_AWD_END_DATE_NOT_GL' ) ;
    			l_error := TRUE ;
		END IF ;
		x_dummy := 0 ;

		/* commented the close_date validation against open GL periods for bug 7603285*/
		/*open c_gl_period(g_award_rec.close_date) ;
		fetch c_gl_period into x_dummy ;
		close c_gl_period ;
                --Bug# 3985020 : Added NVL as aggregate function count was removed.
		IF nvl(x_dummy,0) = 0 THEN
			--ERROR  GMS_AWD_DATE_EXZ_GL_DAT
          		add_message_to_stack( P_label => 'GMS_AWD_CLOSE_DATE_NOT_GL' ) ;
    			l_error := TRUE ;
		END IF ;
		x_dummy := 0 ;*/

		IF NVL(g_award_rec.fund_control_level_award,'B') not in ('B','D','N' )
		THEN
			add_message_to_stack( P_label => 'GMS_FUNDS_CTRL_AWD_INVALID' ) ;
			l_error := TRUE ;
		END IF ;

		IF NVL(g_award_rec.fund_control_level_task, 'B' ) not in ('B','D','N' )
		THEN
			add_message_to_stack( P_label => 'GMS_FUNDS_CTRL_TASK_INVALID' ) ;
			l_error := TRUE ;
		END IF ;

		IF NVL(g_award_rec.fund_control_level_res_grp, 'B' ) not in ('B','D','N' )
		THEN
			add_message_to_stack( P_label => 'GMS_FUNDS_CTRL_RGP_INVALID' ) ;
			l_error := TRUE ;
		END IF ;

		IF NVL(g_award_rec.fund_control_level_res, 'B' ) not in ('B','D','N' )
		THEN
          		add_message_to_stack( P_label => 'GMS_FUNDS_CTRL_RES_INVALID' ) ;
    			l_error := TRUE ;
		END IF ;

		IF g_award_rec.billing_distribution_rule not in ('COST', 'EVENT' ) THEN
			add_message_to_stack( P_label => 'GMS_BILL_DIST_RULE_INVALID' ) ;
			l_error := TRUE ;
		END IF ;

		IF g_award_rec.revenue_distribution_rule not in ('COST', 'EVENT' ) THEN
			add_message_to_stack( P_label => 'GMS_REV_DIST_RULE_INVALID' ) ;
			l_error := TRUE ;
		END IF ;

		IF g_award_rec.billing_distribution_rule = 'COST'
		   and g_award_rec.revenue_distribution_rule = 'EVENT' THEN

		   -- ERROR ( GMS_DISTRIBUTION_RULE_CONFLICT )
          		add_message_to_stack( P_label => 'GMS_DISTRIBUTION_RULE_CONFLICT' ) ;
    			l_error := TRUE ;
		END IF ;

		-- +++++++++++ Date Validations +++++++++++++++

		IF g_award_rec.preaward_date is not NULL
		and g_award_rec.start_date_active is not NULL
		and g_award_rec.start_date_active < g_award_rec.preaward_date THEN

			-- ERROR ( GMS_START_DATE_AFTER_PREAWARD )
          		add_message_to_stack( P_label => 'GMS_START_DATE_AFTER_PREAWARD' ) ;
    			l_error := TRUE ;
		END IF ;

		IF g_award_rec.start_date_active is not NULL
		and g_award_rec.end_date_active is not NULL
		and g_award_rec.start_date_active > g_award_rec.end_date_active THEN

			-- ERROR ( GMS_END_DATE_BEFORE_START_DATE )
          		add_message_to_stack( P_label => 'GMS_END_DATE_BEFORE_START_DATE' ) ;
    			l_error := TRUE ;
		END IF ;


		IF g_award_rec.end_date_active is not NULL
		and g_award_rec.close_date is not NULL
		and g_award_rec.end_date_active > g_award_rec.close_date THEN

			-- ERROR ( GMS_CLOSE_DATE_BEFORE_END_DATE )
          		add_message_to_stack( P_label => 'GMS_CLOSE_DATE_BEFORE_END_DATE' ) ;
    			l_error := TRUE ;

		END IF ;

		IF g_award_rec.billing_offset < 0 THEN
          		add_message_to_stack( P_label => 'GMS_BILL_OFFSET_INVALID' ) ;
    			l_error := TRUE ;
		END IF ;
		IF l_error THEN
		   set_return_status(X_return_status,'B') ;
		END IF ;

	END validate_award ;

	-- ====================
	-- create_agreement
	-- Following procedure create an agreement for award creation in
	-- progress.
	--Shared Service Enhancement : Added ORG_ID in the pa_agreements_pkg.insert_row
	-- ====================
	PROCEDURE create_agreement(p_agreement_id OUT NOCOPY NUMBER ) is

		L_row_id	varchar2(30) ;
		L_agreement_id	NUMBER ;
	BEGIN

   		PA_AGREEMENTS_PKG.INSERT_ROW(
		 			 X_ROWID        		=>	L_Row_Id,
					 X_AGREEMENT_ID			=>	L_Agreement_Id,
					 X_CUSTOMER_ID     		=>	g_award_rec.funding_source_id, --G_bill_contact_rec.customer_id, bug 3076921
					 X_AGREEMENT_NUM   		=>	g_award_rec.award_number,
					 X_AGREEMENT_TYPE  		=>	g_award_rec.type,
					 X_LAST_UPDATE_DATE		=>	sysdate,
					 X_LAST_UPDATED_BY  		=>	g_award_rec.last_updated_by,
					 X_CREATION_DATE    		=>	sysdate,
					 X_CREATED_BY       		=>	g_award_rec.created_by,
					 X_LAST_UPDATE_LOGIN		=>	g_award_rec.last_update_login,
					 X_OWNED_BY_PERSON_ID		=>	g_award_rec.award_manager_id,
					 X_TERM_ID          		=> 	g_award_rec.billing_term,
					 X_REVENUE_LIMIT_FLAG		=>	nvl(g_award_rec.hard_limit_flag, 'N'),	-- Bug 2464841 : Changed 'Y'to'N'
					 X_AMOUNT            		=>	0,
					 X_DESCRIPTION       		=>	NULL,
					 X_EXPIRATION_DATE   		=>	g_award_rec.close_date,
					 X_ATTRIBUTE_CATEGORY		=>	NULL,
					 X_ATTRIBUTE1        		=>	NULL,
					 X_ATTRIBUTE2        		=>	NULL,
					 X_ATTRIBUTE3        		=>	NULL,
					 X_ATTRIBUTE4        		=>	NULL,
					 X_ATTRIBUTE5       		=>	NULL,
					 X_ATTRIBUTE6       		=>	NULL,
					 X_ATTRIBUTE7       		=>	NULL,
					 X_ATTRIBUTE8       		=>	NULL,
					 X_ATTRIBUTE9       		=>	NULL,
					 X_ATTRIBUTE10    	  	=>	NULL,
					 X_TEMPLATE_FLAG    		=>	NULL,
					 X_PM_AGREEMENT_REFERENCE 	=> 	NULL,
					 X_PM_PRODUCT_CODE  		=>	NULL,
					-- Bug 2464841 : Added parameters for 11.5 PA-J certification.
					 X_OWNING_ORGANIZATION_ID	=>	NULL,
					 X_AGREEMENT_CURRENCY_CODE      =>      pa_currency.get_currency_code,
			          X_INVOICE_LIMIT_FLAG		=>	nvl(g_award_rec.invoice_limit_flag, 'N'), /*Bug 6642901*/
					 X_ORG_ID			=>	g_award_rec.org_id
					 );

         	P_Agreement_Id := L_Agreement_Id;
	END create_agreement;

	-- +++++++++++++++++
	PROCEDURE insert_award_record ( X_return_status in out NOCOPY varchar2) IS

		l_row_id	varchar2(50) ;
		L_agreement_id		NUMBER ;
	BEGIN
		select gms_awards_s.NEXTVAL
		  into g_award_rec.award_id
		  from DUAL ;

		create_agreement(L_agreement_id )   ;

		g_award_rec.agreement_id	:= L_agreement_id ;

		INSERT into gms_awards_all
			(
			 AWARD_ID                        ,
			 AWARD_NUMBER                    ,
			 LAST_UPDATE_DATE                ,
			 LAST_UPDATED_BY                 ,
			 CREATION_DATE                   ,
			 CREATED_BY                      ,
			 LAST_UPDATE_LOGIN               ,
			 AWARD_SHORT_NAME                ,
			 AWARD_FULL_NAME                 ,
			 FUNDING_SOURCE_ID               ,
			 START_DATE_ACTIVE               ,
			 END_DATE_ACTIVE                 ,
			 CLOSE_DATE                      ,
			 FUNDING_SOURCE_AWARD_NUMBER     ,
			 AWARD_PURPOSE_CODE              ,
			 STATUS                          ,
			 ALLOWABLE_SCHEDULE_ID           ,
			 IDC_SCHEDULE_ID                 ,
			 REVENUE_DISTRIBUTION_RULE       ,
			 BILLING_FREQUENCY               ,
			 BILLING_DISTRIBUTION_RULE       ,
			 BILLING_FORMAT                  ,
			 BILLING_TERM                    ,
			 AWARD_PROJECT_ID                ,
			 AGREEMENT_ID                    ,
			 AWARD_TEMPLATE_FLAG             ,
			 PREAWARD_DATE                   ,
			 AWARD_MANAGER_ID                ,
			 REQUEST_ID                      ,
			 PROGRAM_APPLICATION_ID          ,
			 PROGRAM_ID                      ,
			 PROGRAM_UPDATE_DATE             ,
			 AGENCY_SPECIFIC_FORM            ,
			 BILL_TO_CUSTOMER_ID             ,
			 TRANSACTION_NUMBER              ,
			 AMOUNT_TYPE                     ,
			 BOUNDARY_CODE                   ,
			 FUND_CONTROL_LEVEL_AWARD        ,
			 FUND_CONTROL_LEVEL_TASK         ,
			 FUND_CONTROL_LEVEL_RES_GRP      ,
			 FUND_CONTROL_LEVEL_RES          ,
			 ATTRIBUTE_CATEGORY              ,
			 ATTRIBUTE1                      ,
			 ATTRIBUTE2                      ,
			 ATTRIBUTE3                      ,
			 ATTRIBUTE4                      ,
			 ATTRIBUTE5                      ,
			 ATTRIBUTE6                      ,
			 ATTRIBUTE7                      ,
			 ATTRIBUTE8                      ,
			 ATTRIBUTE9                      ,
			 ATTRIBUTE10                     ,
			 ATTRIBUTE11                     ,
			 ATTRIBUTE12                     ,
			 ATTRIBUTE13                     ,
			 ATTRIBUTE14                     ,
			 ATTRIBUTE15                     ,
         		 ATTRIBUTE16                     ,
			 ATTRIBUTE17                     ,
			 ATTRIBUTE18                     ,
			 ATTRIBUTE19                     ,
			 ATTRIBUTE20                     ,
			 ATTRIBUTE21                     ,
			 ATTRIBUTE22                     ,
			 ATTRIBUTE23                     ,
			 ATTRIBUTE24                     ,
			 ATTRIBUTE25                     ,
			 TEMPLATE_START_DATE_ACTIVE      ,
			 TEMPLATE_END_DATE_ACTIVE        ,
			 TYPE                            ,
			 ORG_ID                          ,
			 COST_IND_SCH_FIXED_DATE         ,
			 LABOR_INVOICE_FORMAT_ID         ,
			 NON_LABOR_INVOICE_FORMAT_ID     ,
			 BILL_TO_ADDRESS_ID              ,
			 SHIP_TO_ADDRESS_ID              ,
			 LOC_BILL_TO_ADDRESS_ID          ,
			 LOC_SHIP_TO_ADDRESS_ID          ,
			 AWARD_ORGANIZATION_ID           ,
			 HARD_LIMIT_FLAG                 ,
			 INVOICE_LIMIT_FLAG              , /*Bug 6642901*/
			 BILLING_OFFSET                  ,
			 BILLING_CYCLE_ID                ,
			 PROPOSAL_ID			 ,
			 BUDGET_WF_ENABLED_FLAG
			)
		values
			(
			g_award_rec.AWARD_ID                        ,
			g_award_rec.AWARD_NUMBER                    ,
			g_award_rec.LAST_UPDATE_DATE                ,
			g_award_rec.LAST_UPDATED_BY                 ,
			g_award_rec.CREATION_DATE                   ,
			g_award_rec.CREATED_BY                      ,
			g_award_rec.LAST_UPDATE_LOGIN               ,
			g_award_rec.AWARD_SHORT_NAME                ,
			g_award_rec.AWARD_FULL_NAME                 ,
			g_award_rec.FUNDING_SOURCE_ID               ,
			g_award_rec.START_DATE_ACTIVE               ,
			g_award_rec.END_DATE_ACTIVE                 ,
			g_award_rec.CLOSE_DATE                      ,
			g_award_rec.FUNDING_SOURCE_AWARD_NUMBER     ,
			g_award_rec.AWARD_PURPOSE_CODE              ,
			g_award_rec.STATUS                          ,
			g_award_rec.ALLOWABLE_SCHEDULE_ID           ,
			g_award_rec.IDC_SCHEDULE_ID                 ,
			g_award_rec.REVENUE_DISTRIBUTION_RULE       ,
			g_award_rec.BILLING_FREQUENCY               ,
			g_award_rec.BILLING_DISTRIBUTION_RULE       ,
			g_award_rec.BILLING_FORMAT                  ,
			g_award_rec.BILLING_TERM                    ,
			g_award_rec.AWARD_PROJECT_ID                ,
			g_award_rec.AGREEMENT_ID                    ,
			g_award_rec.AWARD_TEMPLATE_FLAG             ,
			g_award_rec.PREAWARD_DATE                   ,
			g_award_rec.AWARD_MANAGER_ID                ,
			g_award_rec.REQUEST_ID                      ,
			g_award_rec.PROGRAM_APPLICATION_ID          ,
			g_award_rec.PROGRAM_ID                      ,
			g_award_rec.PROGRAM_UPDATE_DATE             ,
			g_award_rec.AGENCY_SPECIFIC_FORM            ,
			g_award_rec.BILL_TO_CUSTOMER_ID             ,
			g_award_rec.TRANSACTION_NUMBER              ,
			g_award_rec.AMOUNT_TYPE                     ,
			g_award_rec.BOUNDARY_CODE                   ,
			g_award_rec.FUND_CONTROL_LEVEL_AWARD        ,
			g_award_rec.FUND_CONTROL_LEVEL_TASK         ,
			g_award_rec.FUND_CONTROL_LEVEL_RES_GRP      ,
			g_award_rec.FUND_CONTROL_LEVEL_RES          ,
			g_award_rec.ATTRIBUTE_CATEGORY              ,
			g_award_rec.ATTRIBUTE1                      ,
			g_award_rec.ATTRIBUTE2                      ,
			g_award_rec.ATTRIBUTE3                      ,
			g_award_rec.ATTRIBUTE4                      ,
			g_award_rec.ATTRIBUTE5                      ,
			g_award_rec.ATTRIBUTE6                      ,
			g_award_rec.ATTRIBUTE7                      ,
			g_award_rec.ATTRIBUTE8                      ,
			g_award_rec.ATTRIBUTE9                      ,
			g_award_rec.ATTRIBUTE10                     ,
			g_award_rec.ATTRIBUTE11                     ,
			g_award_rec.ATTRIBUTE12                     ,
			g_award_rec.ATTRIBUTE13                     ,
			g_award_rec.ATTRIBUTE14                     ,
			g_award_rec.ATTRIBUTE15                     ,
          		g_award_rec.ATTRIBUTE16                     ,
			g_award_rec.ATTRIBUTE17                     ,
			g_award_rec.ATTRIBUTE18                     ,
			g_award_rec.ATTRIBUTE19                     ,
			g_award_rec.ATTRIBUTE20                     ,
			g_award_rec.ATTRIBUTE21                     ,
			g_award_rec.ATTRIBUTE22                     ,
			g_award_rec.ATTRIBUTE23                     ,
			g_award_rec.ATTRIBUTE24                     ,
			g_award_rec.ATTRIBUTE25                     ,
			g_award_rec.TEMPLATE_START_DATE_ACTIVE      ,
			g_award_rec.TEMPLATE_END_DATE_ACTIVE        ,
			g_award_rec.TYPE                            ,
			g_award_rec.ORG_ID                          ,
			g_award_rec.COST_IND_SCH_FIXED_DATE         ,
			g_award_rec.LABOR_INVOICE_FORMAT_ID         ,
			g_award_rec.NON_LABOR_INVOICE_FORMAT_ID     ,
			g_award_rec.BILL_TO_ADDRESS_ID              ,
			g_award_rec.SHIP_TO_ADDRESS_ID              ,
			g_award_rec.LOC_BILL_TO_ADDRESS_ID          ,
			g_award_rec.LOC_SHIP_TO_ADDRESS_ID          ,
			g_award_rec.AWARD_ORGANIZATION_ID           ,
			g_award_rec.HARD_LIMIT_FLAG                 ,
			g_award_rec.INVOICE_LIMIT_FLAG              , /*Bug 6642901*/
			g_award_rec.BILLING_OFFSET                  ,
			g_award_rec.BILLING_CYCLE_ID                ,
			g_award_rec.proposal_id			    ,
			g_award_rec.BUDGET_WF_ENABLED_FLAG
		);
	END insert_award_record ;
 --**************************************************************
 -- Bug Fix for Bug 3076921
 -- The following procedure verifies the existence of a structure
 -- for the award project template. If it exists, the same project structure is
 -- used to copy to the newly created award project, If not the following procedure
 -- creates a structure for the award project template.
 -- The structure for the award project template is mandatory from PA.K onwards
 -- as project creates structure for every project template and uses the same
 -- to create a structure while creating a new project, which is copied from
 -- the template.
 --***************************************************************
 PROCEDURE CREATE_AWD_PROJ_TEMPLATE_STRUC(X_award_project_id IN Number,
                                          X_return_status  OUT NOCOPY VARCHAR2 ) IS

 l_struct_exists varchar2(1) := 'N';
 l_awd_proj_temp pa_projects_all%rowtype;
 l_msg_count NUMBER;
 l_msg_data VARCHAR2(2000);
 l_return_status VARCHAR2(1);


 CURSOR c_awd_proj_temp is
     Select * from pa_projects_all
     where project_id = x_award_project_id;

 CURSOR c_struc_exists is
     Select 'Y' from pa_proj_elements
     where project_id = x_award_project_id;

 Begin
 -- Verify whether a structure is already existing for the award project template.

  Open c_struc_exists;
  Fetch c_struc_exists into l_struct_exists;
  Close c_struc_exists;

  If l_struct_exists = 'N' then

    -- Fetch the award project record.
  open c_awd_proj_temp;
  fetch c_awd_proj_temp into l_awd_proj_temp;
  close c_awd_proj_temp;

    -- Create structure for the award project template.

    PA_PROJ_TASK_STRUC_PUB.CREATE_DEFAULT_STRUCTURE(
              p_dest_project_id         => x_award_project_id
             ,p_dest_project_name       => l_awd_proj_temp.name
             ,p_dest_project_number     => l_awd_proj_temp.segment1
             ,p_dest_description        => l_awd_proj_temp.description
             ,p_struc_type              => 'FINANCIAL' --creating only financial structure
             ,x_msg_count               => l_msg_count
             ,x_msg_data                => l_msg_data
             ,x_return_status           => l_return_status  );


                   IF l_Return_Status <> 'S' then
                                RAISE FND_API.G_EXC_ERROR;
                   END IF;

    -- Create Options for the award project template.
       insert into pa_project_options
      (project_id,
       option_code,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login)
     select
       x_award_project_id,
       option_code,
       SYSDATE,
       fnd_global.user_id,
       SYSDATE ,
       fnd_global.user_id,
       fnd_global.login_id
     from pa_options
      where option_code not in ( 'STRUCTURES', 'STRUCTURES_SS' );

    -- Create structure for the award project template's task.

          PA_PROJ_TASK_STRUC_PUB.CREATE_DEFAULT_TASK_STRUCTURE(
              p_project_id         => x_award_project_id
             ,p_struc_type         => 'FINANCIAL'
             ,x_msg_count          => l_msg_count
             ,x_msg_data           => l_msg_data
             ,x_return_status      => l_return_status  );

  end if;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR then
     X_return_status := l_return_status;

   WHEN OTHERS then
     X_return_status := l_return_status;

 End CREATE_AWD_PROJ_TEMPLATE_STRUC;

 --**************************************************************
-- Bug FIx 3076921
 -- For the PA.K rollup patch certification we started making use of the customer account relationship feature.
 -- From now on we will store the bill_to_customer_id i.e LOC customer id of an award in the bill_to_customer_id
 -- column of the pa_project_customers.
 -- We will not update teh record with the latest, by overriding the existing customer_id.
 -- For this the columns bill_to_customer_id and ship_to_customer_id need to be defined as overridable.
 -- This change can be done in the implementaitons form, but that forces us to come up with a data fix
 -- for the existing implementations. So adding that check before creating an award. Thus we dont need any
 -- data fix script and all the changes will be centralized in the multi funding package.

 Procedure MARK_FIELDS_AS_OVERRIDABLE(x_award_project_id IN NUMBER,
                                      x_field_name IN VARCHAR2,
 				      x_return_status OUT NOCOPY VARCHAR2) IS
 CURSOR c_bill_to_customer_overridable IS
    SELECT project_id
     FROM  pa_project_copy_overrides
    WHERE  project_id = x_award_project_id
      AND  field_name = x_field_name;

 l_project_id NUMBER;
 l_msg_count NUMBER;
 l_msg_data VARCHAR2(2000);
 l_return_status VARCHAR2(1);

 BEGIN

    OPEN c_bill_to_customer_overridable;
    FETCH c_bill_to_customer_overridable INTO l_project_id;
    CLOSE c_bill_to_customer_overridable;

    IF l_project_id IS NULL AND x_field_name = 'BILL_TO_CUSTOMER' THEN
       PA_PROJ_TEMPLATE_SETUP_PUB.ADD_QUICK_ENTRY_FIELD( p_api_version       => 1.0,
  							p_init_msg_list	    => FND_API.G_TRUE,
  							p_commit	    => FND_API.G_FALSE,
  							p_validate_only	    => FND_API.G_FALSE,
  							p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
  							p_calling_module    => 'FORM',
  							p_debug_mode	    => 'N',
  							p_max_msg_count	    => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  							p_project_id	    => x_award_project_id,
  							p_sort_order	    => 70,
  							p_field_name	    => 'BILL_TO_CUSTOMER',
  							p_field_meaning	    => 'Bill To Customer Name',
  							p_specification	    => 'Primary',
  							p_limiting_value    => 'Primary',
  							p_prompt	    => 'Bill To Customer Name',
  							p_required_flag	    => 'N',
  							x_return_status	    =>  l_return_status,
  							x_msg_count	    =>  l_msg_count,
  							x_msg_data	    =>  l_msg_data);


                   IF l_Return_Status < 'S' then
                                RAISE FND_API.G_EXC_ERROR;
                   END IF;

   END IF;


    IF l_project_id IS NULL AND x_field_name = 'SHIP_TO_CUSTOMER' THEN
       PA_PROJ_TEMPLATE_SETUP_PUB.ADD_QUICK_ENTRY_FIELD( p_api_version       => 1.0,
                                                         p_init_msg_list     => FND_API.G_TRUE,
                                                         p_commit            => FND_API.G_FALSE,
                                                         p_validate_only     => FND_API.G_FALSE,
                                                         p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                                         p_calling_module    => 'FORM',
                                                         p_debug_mode        => 'N',
                                                         p_max_msg_count     => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                                         p_project_id        => x_award_project_id,
                                                         p_sort_order        => 80,
                                                         p_field_name        => 'SHIP_TO_CUSTOMER',
                                                         p_field_meaning     => 'Ship To Customer Name',
                                                         p_specification     => 'Primary',
                                                         p_limiting_value    => 'Primary',
                                                         p_prompt            => 'Ship To Customer Name',
                                                         p_required_flag     => 'N',
                                                         x_return_status     =>  l_return_status,
                                                         x_msg_count         =>  l_msg_count,
                                                         x_msg_data          =>  l_msg_data);


                   IF l_Return_Status < 'S' then
                                RAISE FND_API.G_EXC_ERROR;
                   END IF;

   END IF;
   EXCEPTION
   WHEN FND_API.G_EXC_ERROR then
     X_Return_Status := l_return_status;

   WHEN OTHERS then
     X_Return_Status := l_return_status;
 END MARK_FIELDS_AS_OVERRIDABLE;
 -- End of Bug Fix for Bug 3076921

	-- +++++++++++++++++
	PROCEDURE create_award_project (   X_return_status 		IN out NOCOPY varchar2,
					   p_setup_award_project_id 	IN     NUMBER) is

		L_Err_Code  	  	  VARCHAR2(1) 	:= NULL;
		L_Project_IN_REC          PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
		L_Project_OUT_REC         PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;
		L_Key_Members_IN_REC      PA_PROJECT_PUB.PROJECT_ROLE_REC_TYPE;
		L_Tasks_IN_REC            PA_PROJECT_PUB.TASK_IN_REC_TYPE;

		L_Key_Members_IN_TBL      PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
		L_Class_Categories_IN_TBL PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;
		L_Tasks_In_TBL            PA_PROJECT_PUB.TASK_IN_TBL_TYPE;
		L_Tasks_Out_TBL           PA_PROJECT_PUB.TASK_OUT_TBL_TYPE;
		L_default_org_id	  NUMBER ;

		L_Workflow_Started	  varchar2(1) ;

                /*** Bug 3576717 **/
		L_Deliverable_IN_TBL          PA_PROJECT_PUB.DELIVERABLE_IN_TBL_TYPE;
		L_Deliverable_Action_IN_TBL   PA_PROJECT_PUB.ACTION_IN_TBL_TYPE;

		-- BUG 3650374
		--L_Deliverable_OUT_TBL         PA_PROJECT_PUB.DELIVERABLE_OUT_TBL_TYPE;
		--L_Deliverable_Action_OUT_TBL  PA_PROJECT_PUB.ACTION_OUT_TBL_TYPE;

	Begin
           -- Bug Fix for Bug 3076921
           -- Need to verify and create a structure for the award project template.
           -- by calling the CREATE_AWD_PROJ_TEMPLATE_STRUC.

           CREATE_AWD_PROJ_TEMPLATE_STRUC(x_award_project_id => p_setup_award_project_id,
                                          x_return_status => x_return_status);

           IF X_Return_Status <> 'S' THEN
              RETURN;
           END IF;

           MARK_FIELDS_AS_OVERRIDABLE(x_award_project_id => p_setup_award_project_id,
				   x_field_name => 'BILL_TO_CUSTOMER',
				   x_return_status => x_return_status );

           IF X_Return_Status <> 'S' THEN
              RETURN;
           END IF;

	   MARK_FIELDS_AS_OVERRIDABLE(x_award_project_id =>p_setup_award_project_id ,
				   x_field_name => 'SHIP_TO_CUSTOMER',
				   x_return_status => x_return_status );

           IF X_Return_Status <> 'S' THEN
              RETURN;
           END IF;

           -- End of Bug Fix for Bug 3076921
    	   L_default_org_id 				 := g_award_rec.org_id ;
	   G_Product_Code 				 := 'GMS';

	   L_Project_IN_REC.PM_PROJECT_REFERENCE         := g_award_rec.award_number ;
	   L_Project_IN_REC.PA_PROJECT_NUMBER            := g_award_rec.award_number ;
	   L_Project_IN_REC.PROJECT_NAME                 := g_award_rec.award_number ;
	   L_Project_IN_REC.CREATED_FROM_PROJECT_ID      := p_setup_award_project_id;
	   L_Project_IN_REC.CARRYING_OUT_ORGANIZATION_ID := g_award_rec.award_organization_id;
	   L_Project_IN_REC.START_DATE                   := g_award_rec.start_date_active;
	   L_Project_IN_REC.COMPLETION_DATE              := g_award_rec.end_date_active ;

	   L_Project_IN_REC.DISTRIBUTION_RULE            := 'EVENT/EVENT';
	   L_Project_IN_REC.PROJECT_RELATIONSHIP_CODE    := 'PRIMARY';
	   L_Project_IN_REC.PROJECT_CURRENCY_CODE   	 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

	   L_Project_IN_REC.CUSTOMER_ID                  := g_award_rec.funding_source_id ; --bug 3076921
          -- Bug Fix 3076921. Load the Table
          L_PROJECT_IN_REC.BILL_TO_CUSTOMER_ID := G_bill_contact_rec.customer_id;
          L_PROJECT_IN_REC.SHIP_TO_CUSTOMER_ID := G_bill_contact_rec.customer_id;


	   L_Key_Members_IN_REC.PERSON_ID                :=  g_award_rec.award_manager_id ;
	   L_Key_Members_IN_REC.PROJECT_ROLE_TYPE        := 'PROJECT MANAGER';
	   L_Key_Members_IN_REC.START_DATE               := g_award_rec.start_date_active; -- Bug 2534936
	   L_Key_Members_IN_REC.END_DATE                 := g_award_rec.end_date_active; -- Bug 2534936

	   L_Tasks_IN_REC.task_name            := g_award_rec.award_number||'-'||'Tsk1'; --L_Task_Name;
	   L_Tasks_IN_REC.TASK_START_DATE      := g_award_rec.start_date_active;
	   L_Tasks_IN_REC.TASK_COMPLETION_DATE := g_award_rec.end_date_active;
	   L_Tasks_IN_REC.pa_task_number       := g_award_rec.award_number||'-'||'T1';    --L_Task_Number;
	   L_Tasks_IN_REC.cost_ind_rate_sch_id := g_award_rec.IDC_Schedule_Id;
	   L_Tasks_IN_REC.pm_task_reference    := g_award_rec.award_number;
	   L_Tasks_IN_REC.chargeable_flag      := 'N';

	   L_Tasks_In_TBL(1) 		       := L_Tasks_IN_REC;
	   L_Key_Members_IN_TBL(1) 	       := L_Key_Members_IN_REC;

	   PA_PROJECT_PUB.CREATE_PROJECT(p_api_version_number 	  => 1.0,
					 p_init_msg_list 	  => 'F',
					 p_msg_count 		  => G_msg_count,
					 p_msg_data 		  => G_Msg_Data,
					 p_return_status 	  => X_Return_Status,
					 p_project_in 		  => L_Project_IN_REC,
					 p_project_out 		  => L_Project_OUT_REC,
					 p_pm_product_code 	  => G_Product_Code,
					 p_key_members 		  => L_Key_Members_IN_TBL,
					 p_class_categories 	  => L_Class_Categories_IN_TBL,
					 p_tasks_in 		  => L_Tasks_IN_TBL,
					 p_tasks_out 		  => L_Tasks_OUT_TBL,
					 p_workflow_started 	  => L_Workflow_Started,
					 P_commit 		  => FND_API.G_FALSE,
                                     /** Bug 3576717 **/
		                         P_deliverables_in        => L_Deliverable_IN_TBL,
		                         --P_deliverables_out       => L_Deliverable_OUT_TBL, (3650374)
		                         P_deliverable_actions_in => L_Deliverable_Action_IN_TBL
		                         --P_deliverable_actions_out=> L_Deliverable_Action_OUT_TBL (3650374)
					);
	  IF X_Return_Status <> FND_API.G_RET_STS_SUCCESS then

		-- -------------------------------------------------
		-- Create award project failed So return to the create
		-- award. Failure status is allready set by
		-- project pub API.
		-- -------------------------------------------------
		return ;
	  ELSE
	       L_Err_Code          	     := X_Return_Status;
	       g_award_rec.award_project_id  := L_Project_OUT_REC.PA_PROJECT_ID;
	  END IF;

	  --
	  -- Update projects for additional informations.

	  --

	  Update PA_PROJECTS_ALL
	    set cost_ind_rate_sch_id		= g_award_rec.IDC_Schedule_Id,
		cost_ind_sch_fixed_date 	= g_award_rec.cost_ind_sch_fixed_date,
		labor_invoice_format_id 	= g_award_rec.Labor_Invoice_Format_Id,
		non_labor_invoice_format_Id  	= g_award_rec.Non_Labor_Invoice_Format_Id,
		name				= g_award_rec.award_number,
		segment1			= g_award_rec.award_number,
		billing_cycle_id             	= g_award_rec.Billing_Cycle_Id,
		billing_offset               	= NVL(g_award_rec.Billing_Offset,0) ,
		last_update_date             	= sysdate,
		last_updated_by              	= fnd_global.user_id,
		last_update_login            	= fnd_global.login_id
	  where project_id = g_award_rec.award_project_id ;

	  --
	  -- Update project customers.
	  --

	    update PA_PROJECT_Customers
	       set BILL_TO_ADDRESS_ID = NVL(g_award_rec.bill_To_Address_Id, bill_TO_ADDRESS_ID ),
		   SHIP_TO_ADDRESS_ID = NVL(g_award_rec.Ship_To_Address_Id, SHIP_TO_ADDRESS_ID )
		   ,LAST_UPDATE_DATE  = SYSDATE
		   ,LAST_UPDATED_BY   = fnd_global.user_id
		   ,LAST_UPDATE_LOGIN = fnd_global.login_id
	     where project_id   = g_award_rec.award_project_id
	       and customer_id  = L_Project_IN_REC.CUSTOMER_ID ;

	END CREATE_AWARD_PROJECT;

	-------------------------------------------------------------------------
	-- CREATE AWARD_PROJECT ENDS HERE
	-------------------------------------------------------------------------


	-- ===============================================================================
	-- COPY_AWARD :
	-- Copy award has all the parameters that we have in quick entry for award.
	-- The ID's in the table are replaced by corresponding value. Users must
	-- provide decode values instead of code values.
	-- P_return_status 	: 	S- Success,
	--				E- Business Rule Validation error
	--				U- Unexpected Error
	-- P_API_VERSION_NUMBER	:	1.0
	-- ===============================================================================
	-- How Copy award works
	-- Copy award has two calling points
	-- 1. Public API
	-- 2. Oracle internal sources
	-- Copy award rely on independent components of the award api.
	-- The independant components are as follows :
	-- A. Create_award
	-- B. Create_contacts
	-- C. Create_personnel
	-- D. Create_reference_numbers
	-- E. Create_notifications.
	-- F. create_terms_and_conditions.
	-- Copy AWARD integrate other components together and create award and
	-- other dependent child records.
	-- The parameters passed may be null. Only parameters that has value
	-- will be overwritten to the base award columns.
	-- ================================================================================
	PROCEDURE	COPY_AWARD(
				X_MSG_COUNT			IN OUT NOCOPY	NUMBER,
				X_MSG_DATA			IN OUT NOCOPY	VARCHAR2,
				X_return_status		      	IN OUT NOCOPY	VARCHAR2,
				P_AWARD_NUMBER			IN OUT NOCOPY	VARCHAR2 ,
				X_AWARD_ID		      	OUT NOCOPY	NUMBER,
				P_CALLING_MODULE	  	IN	VARCHAR2,
				P_API_VERSION_NUMBER	  	IN	NUMBER,
				P_AWARD_BASE_ID			IN	NUMBER,
				P_AWARD_SHORT_NAME		IN	VARCHAR2 	DEFAULT NULL,
				P_AWARD_FULL_NAME		IN	VARCHAR2 	DEFAULT NULL,
				P_AWARD_START_DATE 		IN	DATE 		DEFAULT NULL,
				P_AWARD_END_DATE 		IN	DATE 		DEFAULT NULL,
				P_AWARD_CLOSE_DATE		IN	DATE 		DEFAULT NULL,
				P_PREAWARD_DATE			IN	DATE 		DEFAULT NULL,
				P_AWARD_PURPOSE_CODE		IN 	VARCHAR2 	DEFAULT NULL,
				P_AWARD_STATUS_CODE		IN	VARCHAR2 	DEFAULT NULL,
				P_AWARD_MANAGER_ID		IN	NUMBER 		DEFAULT NULL,
				P_AWARD_ORGANIZATION_ID		IN	NUMBER 		DEFAULT NULL,
				P_FUNDING_SOURCE_ID		IN	NUMBER 		DEFAULT NULL,
				P_FUNDING_SOURCE_AWARD_NUM	IN	VARCHAR2 	DEFAULT NULL,
				P_ALLOWABLE_SCHEDULE_ID		IN	VARCHAR2 	DEFAULT NULL,
				P_INDIRECT_SCHEDULE_ID		IN	VARCHAR2 	DEFAULT NULL,
				P_COST_IND_SCH_FIXED_DATE	IN	DATE 		DEFAULT NULL,
				P_REVENUE_DISTRIBUTION_RULE	IN	VARCHAR2 	DEFAULT NULL,
				P_BILLING_DISTRIBUTION_RULE	IN	VARCHAR2 	DEFAULT NULL,
				P_BILLING_TERM_ID		IN	NUMBER 		DEFAULT NULL,
				P_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2 	DEFAULT NULL,
				P_NON_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2 	DEFAULT NULL,
				P_BILLING_CYCLE_ID		IN	VARCHAR2 	DEFAULT NULL,
				P_AMOUNT_TYPE_CODE		IN	VARCHAR2 	DEFAULT NULL,
				P_BOUNDARY_CODE			IN	VARCHAR2 	DEFAULT NULL,
				P_AGREEMENT_TYPE		IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE_CATEGORY		IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE1			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE2			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE3			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE4			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE5			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE6			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE7			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE8			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE9			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE10			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE11			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE12			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE13			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE14			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE15			IN	VARCHAR2	DEFAULT NULL,
           			P_ATTRIBUTE16			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE17			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE18			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE19			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE20			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE21			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE22			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE23			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE24			IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE25			IN	VARCHAR2	DEFAULT NULL,
				P_PROPOSAL_ID			IN	NUMBER   	DEFAULT NULL)  IS

	L_api_name              varchar2(30) := 'GMS_AWARD_PVT.COPY_AWARD';
        l_award_rec             gms_awards_all%ROWTYPE ;

        l_awards_contacts     gms_awards_contacts%ROWTYPE ;
        l_report_rec          gms_default_reports%ROWTYPE ;
        l_refnum_rec          gms_reference_numbers%ROWTYPE ;
	l_personnel_rec	      gms_personnel%ROWTYPE ;
	l_termscond_rec       gms_awards_terms_conditions%ROWTYPE ;

	l_base_fund_src_id    gms_awards_all.funding_source_id%TYPE ;

	l_default_report_id   NUMBER ;
	l_term_id	      NUMBER ;

	l_validate	      BOOLEAN := FALSE ;
	l_row_id	      varchar2(45) ;

	-- =========
	-- c_award
	-- Fetch the source award record.
	-- This will give us the details of the rest of the columns
	-- to copy award.
	-- =========
        cursor c_award is
            select *
              from gms_awards_all
             where award_id  = p_award_base_id ;

	-- ======
	-- gms_awards_contacts
	-- Copy Contacts cursor.
	-- ======
	-- Bug 2244805. Copy all contacts not just primary contacts
        cursor c_award_contacts is
        select *
          from  gms_awards_contacts
         where award_id = p_award_base_id;
        --   and primary_flag <> 'Y'  Bug 2244805
	--   and l_base_fund_src_id = g_award_rec.funding_source_id ; -- Bug 2244805

	 -- ======
	 -- c_default_reports
	 -- Copu Reports cursor.
	 -- ======

         cursor c_default_reports is
         select *
           from  gms_default_reports
          where award_id = p_award_base_id
	   and l_base_fund_src_id = g_award_rec.funding_source_id ;

	 -- ======
	 -- c_gms_personnel
	 -- Copy c_gms_personnel cursor
	 -- ======
        cursor c_gms_personnel is
        select *
          from  gms_personnel
         where award_id = p_award_base_id
           and   award_role <> 'AM';

	 -- ======
	 -- c_reference_numbers
	 -- Copy c_reference_numbers cursor.
	 -- ======
        cursor c_reference_numbers is
        select *
          from  gms_reference_numbers
         where award_id = p_award_base_id;

	 -- ======
	 -- c_terms_conditions
	 -- Copy Terms and conditions cursor.
	 -- ======
	cursor c_terms_conditions is
	select *
	  from  gms_awards_terms_conditions
	 where award_id = p_award_base_id;

    -- ========================================
    -- copy award Main Logic.
    -- ========================================
    BEGIN
		-- Initialize the message stack.
		-- -----------------------------
		init_message_stack ;

		G_msg_count	  := X_msg_count ;
		G_msg_data	  := X_MSG_DATA ;
		G_calling_module  := P_CALLING_MODULE ;

		-- ============
		-- Initialize the return status.
		-- ============
		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS) not in
		   ( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN

		    X_return_status := FND_API.G_RET_STS_SUCCESS ;

		END IF ;

		SAVEPOINT copy_award_pvt ;

		G_stage := 'FND_API.Compatible_API_Call' ;

  		IF NOT FND_API.Compatible_API_Call (  g_api_version_number	,
				                      p_api_version_number	,
				                      l_api_name 	    	,
				                      G_pkg_name 	    	)
		THEN
			RAISE e_ver_mismatch ;
		END IF ;

		G_stage := 'AWARD RECORD' ;


		-- ======
		-- fetch Base record here.
		-- ======

		OPEN C_AWARD ;
		FETCH C_AWARD into L_AWARD_REC ;
		close c_award ;

	   	l_base_fund_src_id := l_award_rec.funding_source_id ;
		-- ======
		-- Override Columns
		-- ======

		--
		-- Currently we only create award and not
		-- template. So this is understood
		-- award_template_flag must be DEFERRED
		--
		l_award_rec.award_template_flag := 'DEFERRED' ;
		l_award_rec.award_id            := NULL ;
		l_award_rec.award_project_id    := NULL ;


		-- ========
		-- Override logic
		-- We look for not null arguments and
		-- copy them to base award columns.
		-- Calling program will provide us columns
		-- that should be copied to base award columns
		-- ========

		-- IF p_award_number is not NULL then -- Bug 2652716
		    l_award_rec.award_number := p_award_number ;
		-- end if ;

		if P_AWARD_SHORT_NAME is not null then
		    l_award_rec.award_short_name := P_AWARD_SHORT_NAME ;
		end if ;

		IF P_AWARD_FULL_NAME is not null then
		    l_award_rec.AWARD_FULL_NAME := P_AWARD_FULL_NAME ;
		end if ;

		IF P_AWARD_START_DATE is not null then
		    l_award_rec.start_date_active := P_AWARD_START_DATE ;
		end if ;

		IF P_AWARD_END_DATE is not null then
		    l_award_rec.end_date_active := P_AWARD_END_DATE ;
		end if ;

		IF P_AWARD_CLOSE_DATE is not NULL then
		    l_award_rec.CLOSE_DATE := P_AWARD_CLOSE_DATE ;
		end if ;
		IF P_PREAWARD_DATE is not NULL then
		    l_award_rec.PREAWARD_DATE := P_PREAWARD_DATE ;
		end if ;

		IF P_AWARD_PURPOSE_CODE is not null then
		    l_award_rec.AWARD_PURPOSE_CODE := P_AWARD_PURPOSE_CODE ;
		end if ;
		IF P_AWARD_STATUS_CODE is not NULL then
		    l_award_rec.STATUS := P_AWARD_STATUS_CODE ;
		end if ;

		if P_AWARD_MANAGER_ID is not null then
		    l_award_rec.AWARD_MANAGER_ID := P_AWARD_MANAGER_ID ;
		end if ;

		IF P_AWARD_ORGANIZATION_ID is not null then
		    l_award_rec.AWARD_ORGANIZATION_ID := P_AWARD_ORGANIZATION_ID ;
		end if ;

		IF P_FUNDING_SOURCE_ID is not null then
		    l_award_rec.FUNDING_SOURCE_ID := P_FUNDING_SOURCE_ID ;
		end if ;

		IF P_FUNDING_SOURCE_AWARD_NUM is not null then
		   l_award_rec.funding_source_award_number := P_FUNDING_SOURCE_AWARD_NUM ;
		end if ;

		IF P_ALLOWABLE_SCHEDULE_ID is not null then
		    l_award_rec.allowable_schedule_id := P_ALLOWABLE_SCHEDULE_ID ;
		end if ;

		IF P_INDIRECT_SCHEDULE_ID is not null then
		    l_award_rec.idc_schedule_id := P_INDIRECT_SCHEDULE_ID ;
		end if ;

		IF P_COST_IND_SCH_FIXED_DATE is not null then
		    l_award_rec.COST_IND_SCH_FIXED_DATE := P_COST_IND_SCH_FIXED_DATE ;
		end if ;

		IF  P_REVENUE_DISTRIBUTION_RULE is not null then
		    l_award_rec.REVENUE_DISTRIBUTION_RULE := P_REVENUE_DISTRIBUTION_RULE ;
		end if ;

		IF P_BILLING_DISTRIBUTION_RULE is not null then
		    l_award_rec.BILLING_DISTRIBUTION_RULE := P_BILLING_DISTRIBUTION_RULE ;
		end if ;

		IF P_BILLING_TERM_ID is not null then
		    l_award_rec.BILLING_TERM := P_BILLING_TERM_ID ;
		end if ;

		IF P_LABOR_INVOICE_FORMAT_ID is not null then
		    l_award_rec.LABOR_INVOICE_FORMAT_ID := P_LABOR_INVOICE_FORMAT_ID ;
		end if ;

		IF P_NON_LABOR_INVOICE_FORMAT_ID is not null then
		    l_award_rec.NON_LABOR_INVOICE_FORMAT_ID := P_NON_LABOR_INVOICE_FORMAT_ID ;
		end if ;

		if P_BILLING_CYCLE_ID is not null then
		    l_award_rec.BILLING_CYCLE_ID := P_BILLING_CYCLE_ID ;
		end if ;

		IF P_AMOUNT_TYPE_CODE is not null then
		    l_award_rec.AMOUNT_TYPE := P_AMOUNT_TYPE_CODE ;
		end if ;

		IF  P_BOUNDARY_CODE is not null then
		    l_award_rec.BOUNDARY_CODE := P_BOUNDARY_CODE ;
		end if ;

		IF P_AGREEMENT_TYPE is not null then
		    l_award_rec.TYPE := P_AGREEMENT_TYPE ;
		end if ;

		IF P_PROPOSAL_ID is not null then
		    l_award_rec.PROPOSAL_ID := P_PROPOSAL_ID ;
		end if ;

		-- =====
		-- Override columns done.
		-- =====

		-- ==========================
		-- Populate flexfields column
		-- ==========================
		IF P_ATTRIBUTE_CATEGORY is not null then
			l_award_rec.ATTRIBUTE_CATEGORY := P_ATTRIBUTE_CATEGORY ;
		END IF ;

		IF p_attribute1 is not null then
			l_award_rec.attribute1 := P_ATTRIBUTE1 ;
		end if ;

		IF p_attribute2 is not null then
			l_award_rec.attribute2 := P_ATTRIBUTE2 ;
		end if ;

		IF p_attribute3 is not null then
			l_award_rec.attribute3 := P_ATTRIBUTE3 ;
		end if ;

		IF p_attribute4 is not null then
			l_award_rec.attribute4 := P_ATTRIBUTE4 ;
		end if ;

		IF p_attribute5 is not null then
			l_award_rec.attribute5 := P_ATTRIBUTE5 ;
		end if ;

		IF p_attribute6 is not null then
			l_award_rec.attribute6 := P_ATTRIBUTE6 ;
		end if ;

		IF p_attribute7 is not null then
			l_award_rec.attribute7 := P_ATTRIBUTE7 ;
		end if ;

		IF p_attribute8 is not null then
			l_award_rec.attribute8 := P_ATTRIBUTE8 ;
		end if ;

		IF p_attribute9 is not null then
			l_award_rec.attribute9 := P_ATTRIBUTE9 ;
		end if ;

		IF p_attribute10 is not null then
			l_award_rec.attribute10 := P_ATTRIBUTE10 ;
		end if ;

		IF p_attribute11 is not null then
			l_award_rec.attribute11 := P_ATTRIBUTE11 ;
		end if ;

		IF p_attribute12 is not null then
			l_award_rec.attribute12 := P_ATTRIBUTE12 ;
		end if ;

		IF p_attribute13 is not null then
			l_award_rec.attribute13 := P_ATTRIBUTE13 ;
		end if ;

		IF p_attribute14 is not null then
			l_award_rec.attribute14 := P_ATTRIBUTE14 ;
		end if ;

		IF p_attribute15 is not null then
			l_award_rec.attribute15 := P_ATTRIBUTE15 ;
		end if ;
        	IF p_attribute16 is not null then
			l_award_rec.attribute16 := P_ATTRIBUTE16 ;
		end if ;

		IF p_attribute17 is not null then
			l_award_rec.attribute17 := P_ATTRIBUTE17 ;
		end if ;
		IF p_attribute18 is not null then
			l_award_rec.attribute18 := P_ATTRIBUTE18 ;
		end if ;
		IF p_attribute19 is not null then
			l_award_rec.attribute19 := P_ATTRIBUTE19 ;
		end if ;
		IF p_attribute20 is not null then
			l_award_rec.attribute20 := P_ATTRIBUTE20 ;
		end if ;
		IF p_attribute21 is not null then
			l_award_rec.attribute21 := P_ATTRIBUTE21 ;
		end if ;
		IF p_attribute22 is not null then
			l_award_rec.attribute22 := P_ATTRIBUTE22 ;
		end if ;
		IF p_attribute23 is not null then
			l_award_rec.attribute23 := P_ATTRIBUTE23 ;
		end if ;
		IF p_attribute24 is not null then
			l_award_rec.attribute24 := P_ATTRIBUTE24 ;
		end if ;
		IF p_attribute25 is not null then
			l_award_rec.attribute25 := P_ATTRIBUTE25 ;
		end if ;


		--
		-- Create award 1st.
		-- We use our create_award program unit
		-- to create award .
		--

		G_stage := 'gms_award_pvt.create_award' ;

		create_award( X_msg_count,
		              X_MSG_DATA	,
		              X_return_status	,
		              L_ROW_ID	,
		              X_AWARD_ID	,
		              P_CALLING_MODULE,
		              P_API_VERSION_NUMBER,
		              L_AWARD_REC	) ;

		-- =================
		-- Make sure that X_return_status is success before continue.
		-- =================
		IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN

			-- ********* ERROR Return Here ********
			Raise fnd_api.g_exc_error ;
		END IF ;

		p_award_number := g_award_rec.award_number ;

		G_stage := 'Copy Contacts begins ' ;

		-- ========
		-- Copy Award Contacts Now
		-- ========

		-- Bug 2244805 Added if condition and delete statement
	        -- Requirement: If funding source has changed from funding source in base award
	        -- then award contacts (bill to and ship to only) should be taken from receivables.
	        -- If funding source has not changed from funding source in base award, then simply
	        -- copy ALL contacts from the base award (not from receivables)
	        --
	        -- The bill to and ship to contacts are created (based on default contacts in receivables)
	        -- during create_award. Therefore, if the funding source has changed, then there is no need
	        -- to copy any more contacts. If on the other hand, the funding source has not changed from
	        -- that existing in the base award, we first delete the default contacts created from
	        -- receivables by create_award and then copy contacts existing in the base award.

    --Bug : 3455542 : Commented by Sanjay Banerjee
    --create_award procedure is alredy creating contacts, removing these contacts and re-creating
    --does not make sense. Also, create_contact is not just a copy procedure, it does the validation too.
    --We need to create contacts based on the funding_source given. Even if the funding source is same,
    --as before, we have to query to get the latest bill_to and ship_to address_ids.
    --
    /*****
    if (l_base_fund_src_id = g_award_rec.funding_source_id) then

        delete from gms_awards_contacts
        where award_id = g_award_rec.award_id;

		for l_rec in c_award_contacts
		LOOP
		    l_awards_contacts.award_id          := g_award_rec.award_id ;
		    l_awards_contacts.contact_id        := l_rec.contact_id ;
		    l_awards_contacts.primary_flag      := l_rec.primary_flag ;
		    l_awards_contacts.customer_id       := l_rec.customer_id ;
		    l_awards_contacts.usage_code        := l_rec.usage_code ;
		    l_awards_contacts.last_update_date  := SYSDATE ;
		    l_awards_contacts.last_updated_by   := l_rec.last_updated_by ;
		    l_awards_contacts.creation_date     := SYSDATE ;
		    l_awards_contacts.created_by        := l_rec.created_by ;
		    l_awards_contacts.last_update_login := l_rec.last_update_login ;

		     -- Create Contacts ...
		     --- ================
		     G_stage := 'Copy Contacts :'||l_rec.contact_id||' '||l_rec.customer_id||' '
						 ||l_rec.usage_code ;
		     create_contact ( x_msg_count,
				      x_msg_data,
				      x_return_status,
				      l_row_id,
				      p_calling_module,
				      p_api_version_number,
				      l_validate,
				      l_awards_contacts);

		     -- =================
		     -- Make sure that X_return_status is success before continue.
		     -- =================
		     IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
			Raise fnd_api.g_exc_error ;
		     END IF ;

		END LOOP ;
        end if;
        *****/
		-- =========
		-- Copy Default Reports
		-- =========
		G_stage := 'Copy Default reports begins' ;

		 for L_REC in c_default_reports
		 LOOP
		    l_report_rec 			:= l_rec ;
		    l_report_rec.default_report_id      := l_rec.default_report_id ;
		    l_report_rec.report_template_id     := l_rec.report_template_id ;
		    l_report_rec.award_id               := g_award_rec.award_id ;
		    l_report_rec.last_update_date       := l_rec.last_update_date ;
		    l_report_rec.last_updated_by        := l_rec.last_updated_by ;
		    l_report_rec.creation_date          := l_rec.creation_date ;
		    l_report_rec.created_by             := l_rec.created_by ;
		    l_report_rec.last_update_login      := l_rec.last_update_login ;
		    l_report_rec.frequency              := l_rec.frequency ;
		    l_report_rec.due_within_days        := l_rec.due_within_days ;
		    l_report_rec.site_use_id            := l_rec.site_use_id ;
		    l_report_rec.copy_number            := l_rec.copy_number;
		    l_report_rec.request_id             := l_rec.request_id ;
		    l_report_rec.program_application_id := l_rec.program_application_id;
		    l_report_rec.program_id             := l_rec.program_id ;
		    l_report_rec.program_update_date    := l_rec.program_update_date ;
		    l_report_rec.attribute_category     := l_rec.attribute_category ;
		    l_report_rec.attribute1             := l_rec.attribute1 ;
		    l_report_rec.attribute2             := l_rec.attribute2 ;
		    l_report_rec.attribute3             := l_rec.attribute3 ;
		    l_report_rec.attribute4             := l_rec.attribute4 ;
		    l_report_rec.attribute5             := l_rec.attribute5 ;
		    l_report_rec.attribute6             := l_rec.attribute6 ;
		    l_report_rec.attribute7             := l_rec.attribute7 ;
		    l_report_rec.attribute8             := l_rec.attribute8 ;
		    l_report_rec.attribute9             := l_rec.attribute9 ;
		    l_report_rec.attribute10            := l_rec.attribute10 ;
		    l_report_rec.attribute11            := l_rec.attribute11 ;
		    l_report_rec.attribute12            := l_rec.attribute12 ;
		    l_report_rec.attribute13            := l_rec.attribute13 ;
		    l_report_rec.attribute14            := l_rec.attribute14 ;
		    l_report_rec.attribute15            := l_rec.attribute15 ;

		    create_report ( x_msg_count,
				    x_msg_data,
				    x_return_status,
				    l_default_report_id,
				    l_row_id,
				    p_calling_module,
				    p_api_version_number,
				    l_validate,
				    l_report_rec ) ;

		     G_stage := 'Copy Reports :'||l_default_report_id ;

		     -- =================
		     -- Make sure that X_return_status is success before continue.
		     -- =================
		     IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
			Raise fnd_api.g_exc_error ;
		     END IF ;

		 END LOOP ;

		G_stage := 'Copy Personnel starts here' ;

		-- =====
		-- Copy Personnel Details
		-- =====
		FOR L_REC in c_gms_personnel LOOP

		    l_personnel_rec.award_id            := g_award_rec.award_id ;
		    l_personnel_rec.person_id           := l_rec.person_id  ;
		    l_personnel_rec.award_role          := l_rec.award_role  ;
		    l_personnel_rec.last_update_date    := SYSDATE  ;
		    l_personnel_rec.last_updated_by     := l_rec.last_updated_by  ;
		    l_personnel_rec.creation_date       := l_rec.creation_date  ;
		    l_personnel_rec.created_by          := l_rec.created_by  ;
		    l_personnel_rec.last_update_login   := l_rec.last_update_login  ;
		    l_personnel_rec.start_date_active   := l_rec.start_date_active  ;
		    l_personnel_rec.end_date_active     := l_rec.end_date_active  ;
		    l_personnel_rec.personnel_id        := l_rec.personnel_id  ;
		    l_personnel_rec.required_flag       := l_rec.required_flag  ;
		    --l_personnel_rec.project_party_id    := l_rec.project_party_id  ;

		    G_stage := 'Copy Personnel :'||l_rec.person_id||' '||l_rec.award_role ;

		    create_personnel ( x_msg_count,
				       x_msg_data,
				       x_return_status,
				       l_row_id,
				       p_calling_module,
				       p_api_version_number,
				       l_validate,
				       l_personnel_rec ) ;

		     -- =================
		     -- Make sure that X_return_status is success before continue.
		     -- =================
		     IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
			Raise fnd_api.g_exc_error ;
		     END IF ;

		END LOOP ;

		-- =====
		-- Copy Reference Numbers
		-- =====

		g_stage := 'Copy Reference Numbers begins here ' ;

		FOR l_rec in c_reference_numbers LOOP

		    l_refnum_rec.award_id           := g_award_rec.award_id ;
		    l_refnum_rec.type               := l_rec.type ;
		    l_refnum_rec.last_update_date   := l_rec.last_update_date ;
		    l_refnum_rec.last_updated_by    := l_rec.last_updated_by ;
		    l_refnum_rec.creation_date      := l_rec.creation_date ;
		    l_refnum_rec.created_by         := l_rec.created_by ;
		    l_refnum_rec.last_update_login  := l_rec.last_update_login ;
		    l_refnum_rec.value              := l_rec.value ;
		    l_refnum_rec.required_flag      := l_rec.required_flag ;

		    G_stage := 'Copy reference Number :'||l_refnum_rec.type||' '||l_refnum_rec.value ;

		    create_reference_number ( x_msg_count,
					      x_msg_data,
					      x_return_status,
					      l_row_id,
					      p_calling_module,
					      p_api_version_number,
					      l_validate,
					      l_refnum_rec ) ;
		     -- =================
		     -- Make sure that X_return_status is success before continue.
		     -- =================
		     IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
			Raise fnd_api.g_exc_error ;
		     END IF ;

		END LOOP ;

		-- =====
		-- Copy Terms and conditions.
		-- =====

		FOR l_rec in c_terms_conditions LOOP
		    l_termscond_rec.award_id            := g_award_rec.award_id ;
		    l_termscond_rec.category_id         := l_rec.category_id ;
		    l_termscond_rec.term_id             := l_rec.term_id ;
		    l_termscond_rec.last_update_date    := l_rec.last_update_date ;
		    l_termscond_rec.last_updated_by     := l_rec.last_updated_by ;
		    l_termscond_rec.creation_date       := l_rec.creation_date ;
		    l_termscond_rec.created_by          := l_rec.created_by ;
		    l_termscond_rec.last_update_login   := l_rec.last_update_login ;
		    l_termscond_rec.operand             := l_rec.operand ;
		    l_termscond_rec.value               := l_rec.value ;

		    create_term_condition ( x_msg_count,
					    x_msg_data,
					    x_return_status,
				            -- Removed this parameter as we don't return this value.
					    -- l_term_id,
					    l_row_id,
					    p_calling_module,
					    p_api_version_number,
					    l_validate,
					    l_termscond_rec ) ;
		     -- =================
		     -- Make sure that X_return_status is success before continue.
		     -- =================
		     IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
			Raise fnd_api.g_exc_error ;
		     END IF ;

		END LOOP ;

		--
		-- Create Personnel Records.
		--
		--

		-- =================
		-- Make sure that X_return_status is success before continue.
		-- =================
		IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
			Raise fnd_api.g_exc_error ;
		END IF ;

		reset_message_flag ;

		G_stage := 'Award Copied Successfully' ;
	EXCEPTION
		WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;

		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO copy_award_pvt ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;
		WHEN OTHERS THEN
			ROLLBACK TO copy_award_pvt ;
			X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			FND_MSG_PUB.add_exc_msg ( p_pkg_name		=> G_PKG_NAME
					, p_procedure_name	=> l_api_name	);
			FND_MSG_PUB.Count_And_Get
					(   p_count		=>	x_msg_count	,
					    p_data		=>	x_msg_data	);

    END COPY_AWARD ;

	-- +++++++++++++++++


	-- ===========================================================
	-- Create Installments.
	-- ===========================================================

	PROCEDURE CREATE_INSTALLMENT
			(x_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 x_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_return_status            IN OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 X_INSTALLMENT_ID           OUT NOCOPY     NUMBER ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER,
			 P_validate                 IN      BOOLEAN DEFAULT TRUE ,
			 P_INSTALLMENT_REC          IN      GMS_INSTALLMENTS%ROWTYPE
			)  IS

		l_award_start_date_active		DATE ;
		l_award_end_date_active			DATE ;
		l_award_close_date			DATE ;
		l_dummy					VARCHAR2(1) ;
		l_rowid				VARCHAR2(45) ;
   		l_api_name			VARCHAR2(30) := 'CREATE_INSTALLMENT';


		CURSOR l_installment_type_csr (p_installment_type IN VARCHAR2 ) IS
		SELECT 'X'
		FROM gms_lookups
		WHERE lookup_type = 'INSTALLMENT_TYPE'
		AND lookup_code = p_installment_type ;

		-- This is to check the uniqueness of the reference number for that award.
		CURSOR l_installment_num_csr(p_installment_num IN VARCHAR2 ,p_award_id IN NUMBER ) IS
		SELECT 'X'
		FROM gms_installments
		WHERE installment_num = p_installment_num
		AND award_id = p_award_id ;

		CURSOR l_award_rec_csr(p_award_id IN NUMBER ) IS
		SELECT start_date_active , end_date_active,close_date
		FROM gms_awards_all
		WHERE award_id = p_award_id ;


		PROCEDURE check_installment_required (p_validate IN BOOLEAN ,
							X_return_status  IN OUT NOCOPY VARCHAR2 ) IS
			l_error		BOOLEAN ;

		BEGIN
			IF not p_validate then
		   	return ;
			end if ;

			l_error := FALSE ;

			IF G_installment_rec.Award_Id IS NULL THEN
			 -- ------------------------------
			 -- MSG: AWARD_ID_NULL
			 -- ------------------------------
       		         l_error := TRUE ;
       		         add_message_to_stack( P_label => 'GMS_AWD_ID_MISSING' ) ;

               		END IF ;

                	IF g_installment_rec.installment_num IS NULL  THEN
                      		-- ------------------------------
                       		-- MSG: INSTALLEMNT_NUM_IS_NULL
				-- ------------------------------
                       		add_message_to_stack( P_label => 'GMS_INST_NUMBER_NULL' ) ;
                       		l_error := TRUE ;
               		END IF ;

                	IF g_installment_rec.type IS NULL  THEN
                      		-- ------------------------------
                       		-- MSG: INSTALLMENT_TYPE_IS_NULL
				-- ------------------------------
                       		add_message_to_stack( P_label => 'GMS_AWD_INST_TYPE_MISSING' ) ;
                       		l_error := TRUE ;
               		END IF ;

                	IF g_installment_rec.start_date_active IS NULL  THEN
                      		-- ------------------------------
                       		-- MSG: INSTALLMENT_START_DATE_ACTIVE IS NULL
				-- ------------------------------
                       		add_message_to_stack( P_label => 'GMS_INST_START_DATE_NULL' ) ;
                       		l_error := TRUE ;
               		END IF ;

                	IF g_installment_rec.end_date_active IS NULL  THEN
                      		-- ------------------------------
                       		-- MSG: INSTALLMENT_END_DATE_ACTIVE IS NULL
				-- ------------------------------
                       		add_message_to_stack( P_label => 'GMS_INST_END_DATE_NULL' ) ;
                       		l_error := TRUE ;
               		END IF ;

                	IF g_installment_rec.close_date IS NULL  THEN
                      		-- ------------------------------
                       		-- MSG: INSTALLMENT_CLOSE_DATE IS NULL
				-- -----------------------------
                       		add_message_to_stack( P_label => 'GMS_INST_CLOSE_DATE_NULL' ) ;
                       		l_error := TRUE ;
               		END IF ;

                        IF g_installment_rec.direct_cost IS NOT NULL AND
                         g_installment_rec.direct_cost <=  0  THEN
                                add_message_to_stack( P_label => 'GMS_INST_DIR_COST_NOT_GT_ZERO' ) ;
                                l_error := TRUE ;
                        END IF ;

			-- This validation is NOT required as -ve values also are accepted for indirect_cost.
                       /* IF g_installment_rec.indirect_cost IS NOT NULL AND
                         g_installment_rec.indirect_cost <=  0  THEN
                                add_message_to_stack( P_label => 'GMS_INST_IND_COST_NOT_GT_ZERO' ) ;
                                l_error := TRUE ;
                        END IF ; */

		-- ===============================
		-- Validate FlexFields
		-- ===============================
		IF g_installment_rec.attribute_category is not NULL THEN

			fnd_flex_descval.set_context_value(g_installment_rec.attribute_category) ;

			fnd_flex_descval.set_column_value('ATTRIBUTE1',g_installment_rec.attribute1) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE2',g_installment_rec.attribute2) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE3',g_installment_rec.attribute3) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE4',g_installment_rec.attribute4) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE5',g_installment_rec.attribute5) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE6',g_installment_rec.attribute6) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE7',g_installment_rec.attribute7) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE8',g_installment_rec.attribute8) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE9',g_installment_rec.attribute9) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE10',g_installment_rec.attribute10) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE11',g_installment_rec.attribute11) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE12',g_installment_rec.attribute12) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE13',g_installment_rec.attribute13) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE14',g_installment_rec.attribute14) ;
			fnd_flex_descval.set_column_value('ATTRIBUTE15',g_installment_rec.attribute15) ;

			IF (FND_FLEX_DESCVAL.validate_desccols ('GMS' ,'GMS_AWARDS_DESC_FLEX')) then
				-- Validation Passed
				NULL ;
			ELSE
      			   	add_message_to_stack( P_label => 'GMS_AWD_FLEX_INVALID' ) ;
				fnd_msg_pub.add_exc_msg(p_pkg_name       => 'GMS_AWARD_PVT',
							p_procedure_name => 'CREATE_INSTALLMENT',
							p_error_text     => substr(FND_FLEX_DESCVAL.error_message,1,240)) ;
			       	l_error := TRUE ;

			END IF ;

		END IF ;

		-- ------------------------------
		-- End of flex fields validations.
		-- ------------------------------


                	IF L_error THEN
			 	set_return_status ( X_return_status, 'B') ;
			END IF ;
		END check_installment_required ;

		BEGIN

                -- Initialize the message stack.
                -- -----------------------------
                init_message_stack;

                G_msg_count      := X_msg_count ;
                G_msg_data       := X_MSG_DATA ;
                G_calling_module := P_CALLING_MODULE ;

                -- ============
                -- Initialize the return status.
                -- ============
                IF NVL(x_return_status , FND_API.G_RET_STS_SUCCESS) NOT IN
                ( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN
                    x_return_status := FND_API.G_RET_STS_SUCCESS ;
                END IF ;

                SAVEPOINT create_installment_pvt ;

                G_stage := 'FND_API.Compatible_API_Call' ;

                IF NOT FND_API.Compatible_API_Call ( g_api_version_number       ,
                                                     p_api_version_number       ,
                                                     l_api_name                 ,
                                                     G_pkg_name                 ) THEN
                RAISE e_ver_mismatch ;
                END IF ;


		G_installment_rec := p_installment_rec ;

		check_installment_required(p_validate,x_return_status) ;

		IF G_installment_rec.award_id IS NOT NULL THEN
			OPEN l_award_rec_csr(G_installment_rec.award_id ) ;
			FETCH l_award_rec_csr
			INTO l_award_start_date_active , l_award_end_date_active, l_award_close_date ;

			IF l_award_rec_csr%NOTFOUND THEN
                	 	add_message_to_stack( P_label => 'GMS_AWD_NOT_EXISTS' ) ;
                       	 	set_return_status ( X_return_status, 'B') ;
			END IF ;
			CLOSE l_award_rec_csr ;

			OPEN l_installment_num_csr (G_installment_rec.installment_num,G_installment_rec.award_id );
			FETCH l_installment_num_csr INTO l_dummy ;

			-- This is to check the uniqueness of the reference number for that award.
			-- Changed as part of testing.

			IF l_installment_num_csr%FOUND THEN
                	 	add_message_to_stack( P_label => 'GMS_INST_NUMBER_INVALID' ) ;
                       	 	set_return_status ( X_return_status, 'B') ;
			END IF ;
			CLOSE l_installment_num_csr ;

		END IF ;

			OPEN l_installment_type_csr (G_installment_rec.type );
			FETCH l_installment_type_csr INTO l_dummy ;
			IF l_installment_type_csr%NOTFOUND THEN
                	 	add_message_to_stack( P_label => 'GMS_INST_TYPE_INVALID' ) ;
                       	 	set_return_status ( X_return_status, 'B') ;
			END IF ;
			CLOSE l_installment_type_csr ;



                G_stage := 'FND_API.Verify_Instal_start_date_with_Award_start_date';

		IF 	G_installment_rec.start_date_active IS NOT NULL
			and l_award_start_date_active IS NOT NULL
			and G_installment_rec.start_date_active < l_award_start_date_active THEN
                		add_message_to_stack( P_label => 'GMS_INS_ST_DATE_BF_AWD_ST_DATE') ;
                       		set_return_status ( X_return_status, 'B') ;
		END IF ;


                G_stage := 'FND_API.Verify_Instal_start_date_with_Instal_end_date';

   		IF 	G_installment_rec.start_date_active IS NOT NULL
      			and G_installment_rec.end_date_active IS NOT NULL
      			and G_installment_rec.start_date_active > G_installment_rec.end_date_active THEN
                 		add_message_to_stack( P_label => 'GMS_INST_ENDATE_BEF_INS_STDATE');
                      	 	set_return_status ( X_return_status, 'B') ;
		END IF ;

                G_stage := 'FND_API.Verify_Instal_end_date_with_Award_end_date';

  		IF 	G_installment_rec.start_date_active IS NOT NULL
      			and G_installment_rec.end_date_active IS NOT NULL
      			and G_installment_rec.end_date_active > l_award_end_date_active THEN
                		add_message_to_stack( P_label =>'GMS_INS_ENDATE_AFTER_AWENDATE');
                       		set_return_status ( X_return_status, 'B') ;
		END IF ;

                G_stage := 'FND_API.Verify_Instal_end_date_with_Instal_close_date';

  		IF 	G_installment_rec.end_date_active IS NOT NULL
		      	and G_installment_rec.close_date IS NOT NULL
      			and G_installment_rec.end_date_active > G_installment_rec.close_date THEN
                		add_message_to_stack( P_label => 'GMS_INS_CLOSEDATE_BEF_ENDDATE') ;
                       		set_return_status ( X_return_status, 'B') ;
		END IF ;

                G_stage := 'FND_API.Verify_Instal_close_date_with_Award_close_date';

		IF  	G_installment_rec.close_date IS NOT NULL
		     	and l_award_close_date is NOT NULL
     			and G_installment_rec.close_date > l_award_close_date THEN
                		add_message_to_stack( P_label => 'GMS_INS_CL_DATE_>_AWD_CL_DATE') ;
                       		set_return_status ( X_return_status, 'B') ;
		END IF ;

		-- If the return_status <> g_ret_sts_success then we don't proceed with the Inserts.

	        IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
       		         RAISE FND_API.G_EXC_ERROR;
       		END IF ;


		SELECT gms_installments_s.nextval
		INTO   G_installment_rec.installment_id
		FROM   dual;

                G_stage := 'FND_API.Create_Installment' ;

		 gms_installments_pkg.insert_row(
  				  X_ROWID => l_rowid,
				  X_INSTALLMENT_ID => G_installment_rec.installment_id,
				  X_INSTALLMENT_NUM => G_installment_rec.installment_num,
				  X_AWARD_ID => G_installment_rec.award_id,
				  X_START_DATE_ACTIVE => G_installment_rec.start_date_active,
				  X_END_DATE_ACTIVE => G_installment_rec.end_date_active,
				  X_CLOSE_DATE => G_installment_rec.close_date,
				  X_DIRECT_COST => G_installment_rec.direct_cost,
				  X_INDIRECT_COST => G_installment_rec.indirect_cost,
				  X_ACTIVE_FLAG => G_installment_rec.active_flag,
				  X_BILLABLE_FLAG => G_installment_rec.billable_flag,
				  X_TYPE => G_installment_rec.type,
				  X_ISSUE_DATE => G_installment_rec.issue_date,
				  X_DESCRIPTION => G_installment_rec.description,
				  X_ATTRIBUTE_CATEGORY =>G_installment_rec.attribute_category,
				  X_ATTRIBUTE1 =>G_installment_rec.attribute1,
				  X_ATTRIBUTE2 =>G_installment_rec.attribute2,
				  X_ATTRIBUTE3 =>G_installment_rec.attribute3,
				  X_ATTRIBUTE4 =>G_installment_rec.attribute4,
				  X_ATTRIBUTE5 =>G_installment_rec.attribute5,
				  X_ATTRIBUTE6 =>G_installment_rec.attribute6,
				  X_ATTRIBUTE7 =>G_installment_rec.attribute7,
				  X_ATTRIBUTE8 =>G_installment_rec.attribute8,
				  X_ATTRIBUTE9 =>G_installment_rec.attribute9,
				  X_ATTRIBUTE10 =>G_installment_rec.attribute10,
				  X_ATTRIBUTE11 =>G_installment_rec.attribute11,
				  X_ATTRIBUTE12 =>G_installment_rec.attribute12,
				  X_ATTRIBUTE13 =>G_installment_rec.attribute13,
				  X_ATTRIBUTE14 =>G_installment_rec.attribute14,
				  X_ATTRIBUTE15 =>G_installment_rec.attribute15,
				  X_MODE => 'R'  );

                G_stage := 'FND_API.Create_Notification' ;

  		IF G_installment_rec.active_flag = 'Y' THEN
		   gms_wf_pkg.init_installment_wf(x_installment_id=> G_installment_rec.installment_id ,
						  x_award_id 	  => G_installment_rec.award_id);
 	        END IF ;

		-- ===================================================
                -- Fix for bug 2231131. - Installment Id not returned.
                -- ===================================================

                X_INSTALLMENT_ID := G_installment_rec.installment_id ;

		G_installment_rec := NULL ;	 -- Resetting the record varible.

		G_stage := 'Installment Created Successfully' ;

        EXCEPTION
                WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
                        set_return_status(X_return_status, 'B' ) ;
                        x_msg_count := G_msg_count ;
                        x_msg_data  := G_msg_data ;

                WHEN FND_API.G_EXC_ERROR THEN
			G_installment_rec := NULL ;	 -- Resetting the record vaarible.
                        ROLLBACK TO create_installment_pvt ;
                        set_return_status(X_return_status, 'B' ) ;
                        x_msg_count := G_msg_count ;
                        x_msg_data  := G_msg_data ;
                WHEN OTHERS THEN
			G_installment_rec := NULL ;	 -- Resetting the record vaarible.
                        ROLLBACK TO create_installment_pvt ;
                        X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        FND_MSG_PUB.add_exc_msg
                                        ( p_pkg_name            => G_PKG_NAME
                                        , p_procedure_name      => l_api_name   );

                        FND_MSG_PUB.Count_And_Get
                                        (   p_count             =>      x_msg_count     ,
                                            p_data              =>      x_msg_data      );



	END CREATE_INSTALLMENT ;

	-- ----------------------------------------------------------------------------
	-- This procedure will create Award Personnel which is used to name and describe
	-- the award roles and to specify the effective dates.
	-- ----------------------------------------------------------------------------

	PROCEDURE CREATE_PERSONNEL
			(x_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 x_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_return_status            IN OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2  ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_validate                 IN      BOOLEAN DEFAULT TRUE ,
			 P_PERSONNEL_REC            IN      GMS_PERSONNEL%ROWTYPE
 			) IS

		l_api_name			VARCHAR2(30) := 'CREATE_PERSONNEL';
		l_start_date_active  		gms_personnel.start_date_active%TYPE := NULL ;
		l_end_date_active 		gms_personnel.end_date_active%TYPE := NULL ;
		l_award_project_id 		gms_awards_all.award_project_id%TYPE := NULL ;
		l_award_template_flag 		gms_awards_all.award_template_flag%TYPE := NULL ;
		l_budget_wf_enabled_flag 	gms_awards_all.budget_wf_enabled_flag%TYPE := NULL ;
		l_rowid				varchar2(45) ;


		l_error_code 			VARCHAR2(2000) ;
		l_error_stage			VARCHAR2(2000) ;
		l_dummy				VARCHAR2(1) ;

		-- This Cursor is used to validate whether the specific person_id (employee_id)
		-- is a SYSTEM user or not by checking whether he has any valid assignments between
		-- the specific dates.

		CURSOR l_full_name_csr(p_person_id IN NUMBER ) IS
		SELECT 'X'
		from pa_employees p  ,
		fnd_user u
		WHERE
		EXISTS (SELECT null FROM per_assignments_f a
			WHERE p.person_id = a.person_id
			AND TRUNC(SYSDATE) BETWEEN a.effective_start_date AND a.effective_end_date
			AND a.primary_flag = 'Y'
			AND a.assignment_type = 'E')
		AND p.person_id = u.employee_id(+)
		AND p.person_id = p_person_id ;

		-- To validate the incoming award_role parameter.

		CURSOR l_award_role_csr(p_award_role IN VARCHAR2 ) IS
		SELECT 'X'
		FROM gms_lookups g
		WHERE lookup_type = 'AWARD_ROLE'
		AND g.lookup_code = p_award_role
		AND trunc(sysdate) BETWEEN start_date_active AND nvl(end_date_active,trunc(sysdate)) ;

		CURSOR l_rec_csr(p_award_id IN NUMBER ) IS
		SELECT start_date_active,budget_wf_enabled_flag , award_template_flag,
		award_project_id , end_date_active
		FROM gms_awards_all
		WHERE award_id = p_award_id ;

	-- ===============================================================

	PROCEDURE Verify_dates(	p_validate 		IN BOOLEAN ,
				X_return_status 	IN OUT NOCOPY VARCHAR2  ) IS
	BEGIN
           IF not p_validate then
               	return ;
           end if ;

	   -- verify date range
	   IF (	G_personnel_rec.start_date_active IS NOT NULL AND
	  	G_personnel_rec.end_date_active IS NOT NULL AND
             	G_personnel_rec.start_date_active > G_personnel_rec.end_date_active ) THEN

                  add_message_to_stack( P_label => ('GMS_PER_DATES_INVALID') );
		  set_return_status ( X_return_status, 'B') ;
	   END IF;
	END Verify_dates ;

	-- -------------------------------------------------------------------------------

	PROCEDURE Verify_User_Status (p_validate IN BOOLEAN , X_return_status IN OUT NOCOPY VARCHAR2 ) IS

		CURSOR l_valid_user_csr IS
		SELECT user_id
		FROM fnd_user
		WHERE employee_id = G_personnel_rec.person_id ;

		l_user_id	 NUMBER ;

	BEGIN
                IF not p_validate then
                   return ;
                 end if ;

	   	IF l_budget_wf_enabled_flag = 'Y' THEN

			OPEN l_valid_user_csr ;
			FETCH l_valid_user_csr INTO l_user_id ;
			IF l_valid_user_csr%NOTFOUND THEN
				IF G_personnel_rec.award_role ='AM' then
                               		add_message_to_stack( P_label => ('GMS_FND_USER_NOT_CREATED'));
			 		set_return_status ( X_return_status, 'B') ;
				ELSE
                               		add_message_to_stack( P_label => ('GMS_WARN_NOT_FND_USER'));
			 		set_return_status ( X_return_status, 'B') ;
		              	END IF ;
		 	END IF ;	-- End if for l_valid_user_csr

			CLOSE l_valid_user_csr ;

		 END IF ;    		-- End if for l_budget_wf_enabled_flag
	END Verify_User_Status ;

	-- ==============================================================================================

	-- The purpose of this validation is that when we are creating another manager
	-- for the award the dates should not overlap. We can create more than one manager
	-- without overlaping the dates.

	PROCEDURE Verify_Award_Manager_Dates(p_validate IN BOOLEAN , X_return_status IN OUT NOCOPY VARCHAR2 ) IS

	 	CURSOR l_award_manager_csr is
		 SELECT start_date_active, end_date_active
		 FROM 	gms_personnel
		 WHERE  award_id = G_personnel_rec.award_id
		 AND	award_role = 'AM'
		 ORDER BY start_date_active;

	BEGIN
                IF not p_validate then
                   RETURN ;
                END IF ;

		-- =================================================
		-- Only award Manager validations are required here.
		-- =================================================
		IF G_personnel_rec.award_role <>  'AM' then
		   return ;
		END IF ;

		-- ===============================================
		-- Award Manager validations starts here.
		-- ==============================================

	  	FOR rec_award_manager IN  l_award_manager_csr LOOP
  		    IF rec_award_manager.end_date_active IS NULL  THEN

		   	IF G_personnel_rec.end_date_active IS NULL THEN
                              	add_message_to_stack( P_label => ('GMS_AW_INVALID_MANAGER_DATES') );
			 	set_return_status ( X_return_status, 'B') ;
		    	END IF; -- end if for G_personnel_rec.end_date_active

		     END IF; -- End if for rec_award_manager.end_date_active

		     IF (G_personnel_rec.start_date_active  	>= rec_award_manager.start_date_active
			    AND G_personnel_rec.start_date_active  	<=  nvl(rec_award_manager.end_date_active
									, G_personnel_rec.end_date_active))
			OR (G_personnel_rec.end_date_active  	<=  nvl(rec_award_manager.end_date_active,
									G_personnel_rec.end_date_active)
			    AND  G_personnel_rec.end_date_active 	>= rec_award_manager.start_date_active)
			OR (G_personnel_rec.start_date_active  	<=  rec_award_manager.start_date_active
			    AND  G_personnel_rec.end_date_active 	>= nvl(rec_award_manager.end_date_active, 										G_personnel_rec.end_date_active)) THEN

                       	       			add_message_to_stack( P_label => ('GMS_AW_INVALID_MANAGER_DATES') );
			 			set_return_status ( X_return_status, 'B') ;

    		     END IF; --  end if for G_personnel_rec.start_date_active

  		END LOOP;

    	END Verify_Award_Manager_Dates ;

	-- -------------------------------------------------------------------------------

	PROCEDURE check_personnel_required (p_validate IN BOOLEAN ,X_return_status IN OUT NOCOPY VARCHAR2 ) IS

		l_error		BOOLEAN ;
		BEGIN
                       IF not p_validate then
                           return ;
                        end if ;

			l_error := FALSE ;

			IF G_personnel_rec.award_id IS NULL THEN
       		                 l_error := TRUE ;
       		                 add_message_to_stack( P_label => 'GMS_AWD_ID_NULL' ) ;
       		        END IF ;

			IF G_personnel_rec.person_id IS NULL THEN
       		                 l_error := TRUE ;
       		                 add_message_to_stack( P_label => 'GMS_PERSON_ID_NULL' ) ;
       		        END IF ;

			IF G_personnel_rec.award_role IS NULL THEN
       		                 l_error := TRUE ;
       		                 add_message_to_stack( P_label => 'GMS_AWD_ROLE_NULL' ) ;
       		        END IF ;


			IF l_error THEN
			   set_return_status ( X_return_status, 'B') ;
			END IF ;
        END check_personnel_required ;
	-- ------------------------------------------------------------------------------------------

	PROCEDURE Create_Pa_Key_Member ( p_validate IN BOOLEAN , X_return_status IN OUT NOCOPY VARCHAR2 ) IS

		v_null_number        NUMBER;
		v_null_char          VARCHAR2(255);
		v_null_date          DATE;
		x_msg_count          NUMBER;
		x_msg_data           VARCHAR2(255);
		x_role_type_id	NUMBER;
		l_wf_type            VARCHAR2(250);
		l_wf_item_type       VARCHAR2(250);
		l_wf_process         VARCHAR2(250);
		l_assignment_id      NUMBER;
 		l_party_id 		NUMBER;

	BEGIN

			PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY
				( P_API_VERSION        		=> 1.0
				, P_INIT_MSG_LIST     		=> NULL
				, P_COMMIT            		=> NULL
				, P_VALIDATE_ONLY     		=> NULL
				, P_VALIDATION_LEVEL  		=> 100
				, P_DEBUG_MODE        		=> 'N'
				, P_OBJECT_ID         		=> l_award_project_id
				, P_OBJECT_TYPE       		=> 'PA_PROJECTS'
				, P_PROJECT_ROLE_ID   		=> 1
				, P_PROJECT_ROLE_TYPE  		=> 'PROJECT MANAGER'
				, P_RESOURCE_TYPE_ID  		=> 101
				, P_RESOURCE_SOURCE_ID 		=> G_personnel_rec.person_id
				, P_RESOURCE_NAME      		=> v_null_char
				, P_START_DATE_ACTIVE  		=> G_personnel_rec.start_date_active
				, P_SCHEDULED_FLAG     		=> 'N'
				, P_CALLING_MODULE         	=>'FORM'
				, P_PROJECT_ID             	=> l_award_project_id
				, P_PROJECT_END_DATE       	=> l_end_date_active
				, P_END_DATE_ACTIVE        	=> G_personnel_rec.end_date_active
				, X_PROJECT_PARTY_ID       	=> l_party_id
				, X_RESOURCE_ID            	=> v_null_number
				, X_WF_TYPE                	=> l_wf_type
				, X_WF_ITEM_TYPE           	=> l_wf_item_type
				, X_WF_PROCESS             	=> l_wf_process
				, X_ASSIGNMENT_ID          	=> l_assignment_id
				, X_RETURN_STATUS          	=> x_return_status
				, X_MSG_COUNT              	=> x_msg_count
				, X_MSG_DATA               	=> x_msg_data
				);


			IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
				 set_return_status ( X_return_status, 'B') ;

			END IF ;
	END Create_Pa_Key_Member ;
	-- -----------------------------------------------------------------------------------------------


	BEGIN
		-- ----------------------------
                -- Initialize the message stack.
                -- -----------------------------
                init_message_stack;

                G_msg_count      := x_msg_count ;
                G_msg_data       := x_MSG_DATA ;
                G_calling_module := P_CALLING_MODULE ;

                -- =============================
                -- Initialize the return status.
                -- =============================
                IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS) NOT IN
                ( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN
                    X_return_status := FND_API.G_RET_STS_SUCCESS ;
                END IF ;

                SAVEPOINT create_personnel_pvt ;

                G_stage := 'FND_API.Compatible_API_Call' ;

                IF NOT FND_API.Compatible_API_Call ( g_api_version_number       ,
                                                     p_api_version_number       ,
                                                     l_api_name                 ,
                                                     G_pkg_name                 )
                THEN
                                RAISE e_ver_mismatch ;
                END IF ;

		G_personnel_rec := P_personnel_rec ;

                G_stage := 'proc_check_required' ;

		check_personnel_required   (p_validate , X_return_status ) ;

		 IF p_validate THEN

			OPEN l_full_name_csr(G_personnel_rec.person_id );
			FETCH l_full_name_csr into l_dummy ;

			IF l_full_name_csr%NOTFOUND THEN
                        	add_message_to_stack( P_label => 'GMS_AWD_PERSON_ID_INVALID' ) ;
                        	set_return_status ( X_return_status, 'B') ;
			END IF ;
			CLOSE l_full_name_csr ;

			OPEN l_award_role_csr(G_personnel_rec.award_role );
			FETCH l_award_role_csr  into l_dummy ;

			IF l_award_role_csr%NOTFOUND THEN
                        	add_message_to_stack( P_label => 'GMS_AWD_ROLE_INVALID' ) ;
                        	set_return_status ( X_return_status, 'B') ;
			END IF ;
			CLOSE l_award_role_csr ;
		 END IF ; -- end if for p_validate .

		IF G_personnel_rec.award_id IS NOT NULL THEN
		OPEN l_rec_csr(G_personnel_rec.award_id ) ;
		FETCH l_rec_csr INTO l_start_date_active,l_budget_wf_enabled_flag ,
					     l_award_template_flag , l_award_project_id , l_end_date_active ;

		IF l_rec_csr%NOTFOUND THEN
                	 add_message_to_stack( P_label => 'GMS_AWD_NOT_EXISTS' ) ;
                       	 set_return_status ( X_return_status, 'B') ;
		END IF ;
		CLOSE l_rec_csr ;
		END IF ;

                -- =========================================================
                -- Make sure that X_return_status is success before continue.
                -- =========================================================
                IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
                      	 Raise fnd_api.g_exc_error ;
                END IF ;

		-- ==================================================================
		-- If the Start_Date_Active is NULL for PERSONNEL record then take the
		-- Award_Start_Date_Active as the PERSONNEL Start_Date_Active .
		-- ==================================================================

		If G_personnel_rec.start_date_active IS NULL THEN
			G_personnel_rec.start_date_active := l_start_date_active ;
		END IF ;

                G_stage := 'FND_API.Check_Start_Date_Active' ;
		Verify_dates(p_validate , X_return_status ) ;

                G_stage := 'FND_API.Verify_Award_Manager_Dates' ;
		Verify_Award_Manager_Dates (p_validate , X_return_status) ;

                G_stage := 'FND_API.Verify_User_Status' ;
		Verify_User_Status(p_validate , X_return_status) ;


		IF G_personnel_rec.award_role = 'AM'AND l_award_template_flag = 'DEFERRED' THEN

			G_stage := 'FND_API.Create_Pa_Key_Member' ;
			Create_Pa_Key_Member( p_validate , X_return_status ) ;
		END IF ;

	        IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
       		         RAISE FND_API.G_EXC_ERROR;
       		 END IF ;


		SELECT gms_personnel_s.nextval
		INTO G_personnel_rec.personnel_id
		FROM DUAL ;

                G_stage := 'FND_API.Create_Personnel_Record' ;
		gms_personnel_pkg.insert_row
				( x_rowid 		=> L_rowid,
				  x_personnel_id	=> G_personnel_rec.personnel_id,
				  x_award_id 		=> G_personnel_rec.award_id,
				  x_person_id 		=> G_personnel_rec.person_id,
				  x_award_role 		=> G_personnel_rec.award_role,
				  x_start_date_active 	=> G_personnel_rec.start_date_active,
				  x_end_date_active 	=> G_personnel_rec.end_date_active,
				  x_required_flag 	=> G_personnel_rec.required_flag,
				  x_mode 		=> 'R'
				 );

                G_stage := 'FND_API.Create_Person_Events' ;
		gms_notification_pkg.crt_default_person_events
				( p_award_id  		=> G_personnel_rec.award_id,
				  p_person_id 		=> G_personnel_rec.person_id,
				  x_err_code 		=> l_error_code,
				  x_err_stage 		=> l_error_stage
			 	);
		G_personnel_rec := NULL ;	 -- Resetting the record vaarible.


		G_stage := 'Personnel Created Successfully' ;
        EXCEPTION
                WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
                        set_return_status(X_return_status, 'B' ) ;
                        x_msg_count := G_msg_count ;
                        x_msg_data  := G_msg_data ;

                WHEN FND_API.G_EXC_ERROR THEN
			G_personnel_rec := NULL ;	 -- Resetting the record vaarible.
                        ROLLBACK TO create_personnel_pvt ;
                        set_return_status(X_return_status, 'B' ) ;
                        x_msg_count := G_msg_count ;
                        x_msg_data  := G_msg_data ;
                WHEN OTHERS THEN
			G_personnel_rec := NULL ;	 -- Resetting the record vaarible.
                        ROLLBACK TO create_personnel_pvt;
                        X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        FND_MSG_PUB.add_exc_msg
                                        ( p_pkg_name            => G_PKG_NAME
                                        , p_procedure_name      => l_api_name   );
                        FND_MSG_PUB.Count_And_Get
                                        (   p_count             =>      x_msg_count     ,
                                            p_data              =>      x_msg_data      );



	END CREATE_PERSONNEL ;


	-- ========================================================================
	-- Create Terms and conditions.
	-- ========================================================================
	PROCEDURE CREATE_TERM_CONDITION
			(X_MSG_COUNT                IN 	OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 IN 	OUT NOCOPY     VARCHAR2 ,
			 X_return_status            IN 	OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            	OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           	IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       	IN      NUMBER ,
			 P_validate                 	IN      BOOLEAN DEFAULT TRUE ,
			 P_AWARD_TERM_CONDITION_REC     IN      GMS_AWARDS_TERMS_CONDITIONS%ROWTYPE
			) IS

		l_award_start_date_active 	DATE ;
		l_award_end_date_active		DATE ;
     		l_api_name			VARCHAR2(30) := 'CREATE_TERM_CONDITION';
		l_dummy				VARCHAR2(1) ;
		l_rowid				varchar2(45) ;

		-- =======================================================================
		-- This is to check the uniqueness of the award_id + term_id + category_id
		-- before creating the term and condition .
		-- =======================================================================

		CURSOR l_check_duplicate_csr IS
		SELECT 'X'
		FROM gms_awards_terms_conditions
		WHERE award_id = G_term_condition_rec.award_id
		AND  category_id = G_term_condition_rec.category_id
		AND  term_id = G_term_condition_rec.term_id ;

		-- ===========================================================================================
		-- This cursor is used to verify whether the incoming category exists or  not( LOV validation ).
		-- ===========================================================================================

		CURSOR l_category_id_csr IS
		SELECT 'X'
		FROM gms_tc_categories
		WHERE category_id = G_term_condition_rec.category_id ;

		-- ===========================================================================================
		-- This cursor is used to verify whether the incoming term_id exists or not for the specific
		-- category_id ( LOV validation ).
		-- ===========================================================================================
		CURSOR l_term_id_csr IS
		SELECT 'X'
		FROM gms_terms_conditions tc1
		WHERE tc1.category_id = G_term_condition_rec.category_id
		and term_id not in (select term_id from gms_terms_conditions tc
					where
				      (
					(tc.start_date_active > l_award_start_date_active
					and tc.start_date_active > l_award_end_date_active
					and tc.start_date_active is not null and tc.end_date_active is not null)
					or
					(tc.end_date_active < l_award_start_date_active
					and tc.end_date_active < l_award_end_date_active
					and tc.start_date_active is not null
					and tc.end_date_active is not null)
					or
					( tc.start_date_active is null
					and tc.end_date_active < l_award_start_date_active
					and tc.end_date_active is not null)
					or
				 	(tc.end_date_active is null
				  	and tc.start_date_active > l_award_end_date_active
					and tc.start_date_active is not null)
			             )
         		           ) ;
		-- ========================================================================
		-- This cursor is used to retrived the start_date and end_date for an Award.
		-- ========================================================================

		CURSOR l_award_rec_csr IS
		SELECT start_date_active,end_date_active
		FROM gms_awards_all
		WHERE award_id = G_term_condition_rec.award_id ;

		-- =======================================================================================
		-- This procedure will verify whehter all the NOT NULL columns have values or not.
		-- This needs to be checked here as we don't do any validation in the PUB.
		-- If the call is coming from PVT i.e p_validate is FALSE then we don't do this validation.
		-- =======================================================================================

                PROCEDURE check_term_cond_required (p_validate IN BOOLEAN ,
							x_return_status IN OUT NOCOPY VARCHAR2 ) IS
		l_error		BOOLEAN ;

		BEGIN
		IF not p_validate then
		   return ;
		end if ;

		l_error := FALSE ;

		IF G_term_condition_rec.Award_Id IS NULL THEN
       		         l_error := TRUE ;
       		         add_message_to_stack( P_label => 'GMS_AWD_ID_MISSING' ) ;

               	END IF ;

                IF G_term_condition_rec.category_id IS NULL  THEN
                       	add_message_to_stack( P_label => 'GMS_TERM_CON_CATEGORY_NULL' ) ;
                       	l_error := TRUE ;
               	END IF ;
                IF G_term_condition_rec.term_id IS NULL  THEN
                       	add_message_to_stack( P_label => 'GMS_TERM_ID_NULL' ) ;
                       	l_error := TRUE ;
               	END IF ;

                IF L_error THEN
			 set_return_status ( X_return_status, 'B') ;
                END IF ;
        	END check_term_cond_required ;
		-- --------------------------------------------------------------------------

		BEGIN

		-- =============================
                -- Initialize the message stack.
		-- =============================

                init_message_stack;

                G_msg_count      := X_msg_count ;
                G_msg_data       := X_MSG_DATA ;
                G_calling_module := P_CALLING_MODULE ;

                -- ============================
                -- Initialize the return status.
                -- ============================
                IF NVL(x_return_status , FND_API.G_RET_STS_SUCCESS) NOT IN
                ( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN
                    x_return_status := FND_API.G_RET_STS_SUCCESS ;
                END IF ;

                SAVEPOINT create_award_term_cond_pvt ;

                G_stage := 'FND_API.Compatible_API_Call' ;

                IF NOT FND_API.Compatible_API_Call ( g_api_version_number       ,
                                                     p_api_version_number       ,
                                                     l_api_name                 ,
                                                     G_pkg_name                 ) THEN
                RAISE e_ver_mismatch ;
                END IF ;

		G_term_condition_rec := p_award_term_condition_rec ;
                G_stage := 'proc_check_required_for_term_condition' ;

                check_term_cond_required (p_validate , x_return_status ) ;

		IF G_term_condition_rec.award_id IS NOT NULL THEN
			OPEN l_award_rec_csr ;
			FETCH l_award_rec_csr INTO l_award_start_date_active,l_award_end_date_active ;
				IF l_award_rec_csr%NOTFOUND THEN
                      	 		add_message_to_stack( P_label => 'GMS_AWD_NOT_EXISTS' ) ;
                                	set_return_status ( x_return_status, 'B') ;
                                END IF ;
                        CLOSE l_award_rec_csr ;
		END IF ;

                 IF p_validate THEN  -- i.e the call is from PUB package .
		-- The following are all LOV validations.
                        OPEN l_category_id_csr  ;
                        FETCH l_category_id_csr INTO l_dummy ;
                                IF l_category_id_csr%NOTFOUND THEN
                                        add_message_to_stack( P_label => 'GMS_AWD_CATEGORY_NAME_INVALID' ) ;
                                        set_return_status ( x_return_status, 'B') ;
                                END IF ;
                        CLOSE l_category_id_csr ;

                        OPEN l_term_id_csr ;
                        FETCH l_term_id_csr INTO l_dummy ;
                                IF l_term_id_csr%NOTFOUND THEN
                                        add_message_to_stack( P_label => 'GMS_TERM_NAME_INVALID' ) ;
                                        set_return_status ( x_return_status, 'B') ;
                                END IF ;
                        CLOSE l_term_id_csr ;
			-- =============================================================================
			-- This is to check the uniqueness of the award_id + term_id + category_id before
			-- creating the term and condition .
			-- =============================================================================

			OPEN l_check_duplicate_csr ;
			FETCH l_check_duplicate_csr INTO l_dummy ;
				IF  l_check_duplicate_csr%FOUND THEN
                                        add_message_to_stack( P_label => 'GMS_AWARD_TERM_CATEGORY_DUP' ) ;
                                        set_return_status ( x_return_status, 'B') ;
                                END IF ;
			CLOSE l_check_duplicate_csr ;

                 END IF ;  -- end if for p_validate.

                        IF NVL(x_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
                                RAISE fnd_api.g_exc_error ;
                        END IF ; -- end if for nvl(x_return_status) .

                        G_stage := 'FND_API.Creating_Award_term_condition_record ' ;
			gms_awards_tc_pkg.insert_row
						( X_ROWID 	=> l_rowid,
  						  X_AWARD_ID 	=> G_term_condition_rec.award_id,
						  X_CATEGORY_ID => G_term_condition_rec.category_id,
						  X_TERM_ID 	=> G_term_condition_rec.term_id,
						  X_OPERAND 	=> G_term_condition_rec.operand,
						  X_VALUE 	=> G_term_condition_rec.value,
						  X_MODE 	=> 'R'
						) ;
		G_term_condition_rec := NULL ;	 -- Resetting the record vaarible.

               	G_stage := 'FND_API.Succefully_created_award_term_condition' ;


        EXCEPTION
                WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
                        set_return_status(x_return_status, 'B' ) ;
                        X_msg_count := G_msg_count ;
                        X_msg_data  := G_msg_data ;

                WHEN FND_API.G_EXC_ERROR THEN
			G_term_condition_rec := NULL ;	 -- Resetting the record vaarible.
                        ROLLBACK TO create_award_term_cond_pvt ;
                        set_return_status(x_return_status, 'B' ) ;
                        X_msg_count := G_msg_count ;
                        X_msg_data  := G_msg_data ;
                WHEN OTHERS THEN
			G_term_condition_rec := NULL ;	 -- Resetting the record vaarible.
                        ROLLBACK TO create_award_term_cond_pvt ;
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        FND_MSG_PUB.add_exc_msg
                                        ( p_pkg_name            => G_PKG_NAME
                                        , p_procedure_name      => l_api_name   );
                        FND_MSG_PUB.Count_And_Get
                                        (   p_count             =>      X_msg_count     ,
                                            p_data              =>      X_msg_data      );


	end CREATE_TERM_CONDITION ;

	-- ========================================================================
	-- This procedure will create references as needed for each Award withe
	-- effective Start Date and End Dates .
	-- ========================================================================
	PROCEDURE CREATE_REFERENCE_NUMBER
			(x_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 x_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_return_status            IN OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_validate                 IN      BOOLEAN DEFAULT TRUE ,
			 P_REFERENCE_NUMBER_REC     IN      GMS_REFERENCE_NUMBERS%ROWTYPE
			) IS

			-- This Cursor is used to validate the incoming TYPE parameter
			-- with the lookup_code. It it doesn't exist then we raise an error
			-- and exit the procedure .

			CURSOR l_lookup_csr IS
			SELECT 'X'
			FROM gms_lookups
			WHERE lookup_type = 'REFERENCE_NUMBER'
			AND  lookup_code = G_reference_number_rec.type ;

			-- ==============================================================================
			-- This is to check whether the award_id and reference_type combination is unique .
			-- Here reference_type corresponds to the Lookup_code in the gms_looups table.
			-- ==============================================================================

			CURSOR l_duplicate_ref_type IS
			SELECT 'X'
			FROM gms_reference_numbers
			WHERE award_id = G_reference_number_rec.award_id
			AND type =  G_reference_number_rec.type ;

			l_api_name	VARCHAR2(30) := 'CREATE_PERSONNEL';
			l_dummy		VARCHAR2(1) ;
			l_rowid		varchar2(45) ;
		-- ========================================================================
		-- This procedure will check all the required values .
		-- ========================================================================

		PROCEDURE check_reference_required (p_validate IN BOOLEAN ,
							X_return_status  IN OUT NOCOPY VARCHAR2 ) IS
		l_error		BOOLEAN ;

		BEGIN
		IF not p_validate then
		   return ;
		end if ;

		l_error := FALSE ;

		IF G_reference_number_rec.Award_Id IS NULL THEN
       		         l_error := TRUE ;
       		         add_message_to_stack( P_label => 'GMS_AWD_ID_MISSING' ) ;

               	END IF ;

                IF g_reference_number_rec.type IS NULL  THEN
                       	add_message_to_stack( P_label => 'GMS_REF_TYPE_NULL' ) ;
                       	l_error := TRUE ;
               	END IF ;

                IF L_error THEN
			 set_return_status ( X_return_status, 'B') ;
                END IF ;
        	END check_reference_required ;
		-- -------------------------------------

		BEGIN

                -- Initialize the message stack.
                -- -----------------------------
                init_message_stack;

                G_msg_count      := x_msg_count ;
                G_msg_data       := x_MSG_DATA ;
                G_calling_module := P_CALLING_MODULE ;

                -- =============================
                -- Initialize the return status.
                -- =============================
                IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS) NOT IN
                ( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN
                    X_return_status := FND_API.G_RET_STS_SUCCESS ;
                END IF ;

                SAVEPOINT create_reference_number_pvt ;

                G_stage := 'FND_API.Compatible_API_Call' ;

                IF NOT FND_API.Compatible_API_Call ( g_api_version_number       ,
                                                     p_api_version_number       ,
                                                     l_api_name                 ,
                                                     G_pkg_name                 ) THEN
			RAISE e_ver_mismatch ;
                END IF ;

		G_reference_number_rec := p_reference_number_rec ;

                G_stage := 'proc_check_required' ;
		check_reference_required (p_validate , X_return_status ) ;

		IF p_validate THEN  -- i.e the call is from PUB package .
		-- Following are all LOV validations.

			OPEN l_lookup_csr ;
			FETCH l_lookup_csr INTO l_dummy ;
			IF l_lookup_csr%NOTFOUND THEN
                       		add_message_to_stack( P_label => 'GMS_AWD_INVALID_REFERENCE_TYPE' ) ;
                       		set_return_status ( X_return_status, 'B') ;
			END IF ;
			CLOSE l_lookup_csr ;

			-- ==============================================================================
			-- This is to check whether the award_id and reference_type combination is unique .
			-- ==============================================================================

			OPEN l_duplicate_ref_type ;
			FETCH l_duplicate_ref_type INTO l_dummy ;
			IF l_duplicate_ref_type%FOUND THEN
                       		add_message_to_stack( P_label => 'GMS_DUP_REFERENCE_TYPE' ) ;
                       		set_return_status ( X_return_status, 'B') ;
			END IF ;
			CLOSE l_duplicate_ref_type ;
		END IF ;  -- end if for p_validate.

			-- ==============================================================================
			-- Here we check whether the return_staus <> FND_API.G_RET_STS_SUCCESS because of
			-- any above validations . If it is that means some error has happened and we don't
			-- insert the record but the control go to exception section.
			-- ==============================================================================

               		IF NVL(X_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
                        	RAISE fnd_api.g_exc_error ;
               		END IF ; -- end if for nvl(X_return_status) .

		-- Creating the Reference_number Record .

                G_stage := 'FND_API.Creating_reference_number' ;
		gms_reference_numbers_pkg.insert_row
				        	( x_rowid 	=> l_rowid,
						x_award_id 	=> G_reference_number_rec.award_id,
						x_type 		=> G_reference_number_rec.type,
						x_value		=> G_reference_number_rec.value,
						x_required_flag => G_reference_number_rec.required_flag,
						x_mode 		=> 'R'
						);
		G_reference_number_rec := NULL ;	 -- Resetting the record vaarible.


               	G_stage := 'FND_API.Succefully_created_reference_number ' ;

        EXCEPTION
                WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
                        set_return_status(X_return_status, 'B' ) ;
                        x_msg_count := G_msg_count ;
                        x_msg_data  := G_msg_data ;

                WHEN FND_API.G_EXC_ERROR THEN
			G_reference_number_rec := NULL ;	 -- Resetting the record vaarible.
                        ROLLBACK TO create_reference_number_pvt ;
                        set_return_status(X_return_status, 'B' ) ;
                        x_msg_count := G_msg_count ;
                        x_msg_data  := G_msg_data ;
                WHEN OTHERS THEN
			G_reference_number_rec := NULL ;	 -- Resetting the record vaarible.
                        ROLLBACK TO create_reference_number_pvt ;
                        X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        FND_MSG_PUB.add_exc_msg
                                        ( p_pkg_name            => G_PKG_NAME
                                        , p_procedure_name      => l_api_name   );
                        FND_MSG_PUB.Count_And_Get
                                        (   p_count             =>      x_msg_count     ,
                                            p_data              =>      x_msg_data      );

	END CREATE_REFERENCE_NUMBER ;

	-- ========================================================================
	-- Create Contact
	-- ========================================================================

	PROCEDURE CREATE_CONTACT
			(X_MSG_COUNT                IN OUT NOCOPY     	NUMBER ,
			 X_MSG_DATA                 IN OUT NOCOPY     	VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     	VARCHAR2 ,
			 X_ROW_ID	               OUT NOCOPY     	VARCHAR2 ,
			 P_CALLING_MODULE           IN      	VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      	NUMBER ,
			 P_VALIDATE		    IN      	BOOLEAN default TRUE,
			 P_CONTACT_REC             IN      	GMS_AWARDS_CONTACTS%ROWTYPE
			)
	IS
--TCA enhancement : Changing RA tables with HZ tables
		CURSOR	l_valid_award_csr	IS
		SELECT	award_id,award_project_id
		FROM	gms_awards_all
		WHERE	award_id   =  G_contact_rec.award_id;

		CURSOR l_valid_contact_csr	IS
		SELECT	'X'
	 	FROM	gms_awards_all	ga,
			Hz_cust_account_roles acct_roles
		WHERE	ga.award_id  =	G_contact_rec.award_id
	AND	decode(ga.billing_format,'LOC',ga.bill_to_customer_id,ga.funding_source_id)=acct_roles.cust_account_id
                AND     acct_roles.cust_account_role_id = G_contact_rec.contact_id;


                CURSOR l_valid_usage_csr        IS
                SELECT  'X'
                FROM    	hz_cust_site_uses a,
                        	Hz_cust_acct_sites b,
                       	 	ar_lookups c,
                        	gms_awards_all ga
                WHERE   	a.cust_acct_site_id = b.cust_acct_site_id
                AND   	b.cust_account_id = decode(ga.billing_format,'LOC',ga.bill_to_customer_id,ga.funding_source_id)
                AND     	c.lookup_type       = 'SITE_USE_CODE'
                AND     	c.lookup_code       = g_contact_rec.usage_code;

		CURSOR l_dup_usage_csr	IS
		SELECT 'X'
		FROM	gms_awards_contacts
    		WHERE 	award_id =   G_contact_rec.award_id
    		AND   	contact_id =   G_contact_rec.contact_id  -- Bug 2672027
    		AND  	customer_id = G_contact_rec.customer_id
    		AND  	usage_code = G_contact_rec.usage_code;

		l_api_name varchar2(30) := 'CREATE_CONTACT' ;
		l_award_project_id	NUMBER ;
		l_award_id		NUMBER ;
		l_rowid			VARCHAR2(45) ;
		l_contact		VARCHAR2(1);
		l_usage			VARCHAR2(1);
		l_dup_usage		VARCHAR2(1);

	BEGIN

		-- =============================
		-- Initialize the Message Stack.
		-- =============================

		init_message_stack;

		G_msg_count	  := x_msg_count ;
		G_msg_data	  := x_MSG_DATA ;
		G_calling_module := P_CALLING_MODULE ;

		-- =============================
		-- Initialize the return status.
		-- =============================

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS) not in
		( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN
		    X_return_status := FND_API.G_RET_STS_SUCCESS ;
		END IF ;

		-- =========================
		-- Establish the Save Point.
		-- =========================

		SAVEPOINT create_contact_pvt ;

		-- ==============================================================
		-- Compare the caller version number to the API version number in
		-- order to detect incompatible API calls.
		-- ==============================================================

		G_stage := 'FND_API.Compatible_API_Call' ;

  		IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
						     p_api_version_number	,
						     l_api_name 	    	,
						     G_pkg_name 	    	)
		THEN
				RAISE e_ver_mismatch ;
		END IF ;

		-- =============================================
		-- Check for required columns for Create Contact
		-- =============================================

                G_stage := 'procedure_check_contact_required_columns' ;

		G_contact_rec	:= P_contact_rec;

		IF G_contact_rec.award_id IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_AWD_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_contact_rec.contact_id IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_CON_CONTACT_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_contact_rec.customer_id IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_CON_CUSTOMER_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_contact_rec.usage_code IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_CON_USAGE_CODE_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_contact_rec.primary_flag IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_CON_PRIMARY_FLAG_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_contact_rec.primary_flag NOT IN ('Y','N') THEN
       			add_message_to_stack( P_label => 'GMS_CON_INVALID_PRIMARY_FLAG' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		-- ===================================================================
		-- Need to make sure that the return status is success from the above
		-- validations. There is no point in doing further validations as the
		-- required columns donot have values. So we raise an Error.
		-- ===================================================================

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- ======================================================================
		-- Verify the contacts for validity by cross checking with funding source
		-- ======================================================================

                G_stage := 'create_contact.Verify_Award';

                OPEN l_valid_award_csr ;
                FETCH l_valid_award_csr INTO l_award_id,l_award_project_id;

                IF l_award_id IS NULL THEN
                         add_message_to_stack( P_label  =>      'GMS_FND_INVALID_AWARD' ) ;
                         set_return_status ( X_return_status, 'B') ;
                 END IF;

                CLOSE l_valid_award_csr ;

		G_stage := 'create_contact.Verify_Contact;' ;

		OPEN	l_valid_contact_csr;
		FETCH	l_valid_contact_csr	INTO	l_contact;

		IF 	l_valid_contact_csr%NOTFOUND	THEN
			 add_message_to_stack( P_label => 'GMS_CON_CONTACT_INVLAID' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		CLOSE 	l_valid_contact_csr;

		-- ============================================================
		-- Verify the usage for validity by cross checking with lookups
		-- ===========================================================

		G_stage := 'create_contact.Verify_Usage;' ;

		OPEN	l_valid_usage_csr;
		FETCH	l_valid_usage_csr	INTO	l_usage;

		IF 	l_valid_usage_csr%NOTFOUND	THEN
			 add_message_to_stack( P_label => 'GMS_CON_USAGE_INVALID' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		CLOSE 	l_valid_usage_csr;

		-- ============================================================================
		-- Verify the duplicate usage of contacts for a given award, customer and usage.
		-- ============================================================================

		G_stage := 'create_contact.Verify_Duplicate_Usage;' ;

		OPEN l_dup_usage_csr ;
		FETCH l_dup_usage_csr INTO l_dup_usage;

		IF l_dup_usage_csr%FOUND THEN
			 add_message_to_stack( P_label => 'GMS_CON_AWD_USAGE_DUP' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		CLOSE l_dup_usage_csr ;


		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;


		-- ===========================================================================================
		-- Updating pa_project_contacts for Award Project customer id for primary bill to and ship to
		-- ===========================================================================================

		IF	(G_contact_rec.primary_flag = 'Y')   THEN
			IF	(G_contact_rec.usage_code = 'BILL_TO') or (G_contact_rec.usage_code = 'SHIP_TO' )  THEN
				IF	l_award_project_id	IS NOT NULL  THEN

	    				UPDATE 	pa_project_contacts
	       				SET 	contact_id	      	= 	DECODE(project_contact_type_code,
									'BILLING', (G_contact_rec.Contact_id),
									'SHIPPING',(G_contact_rec.Contact_id),
									contact_id ),
	       	   				last_update_date  	= 	SYSDATE,
		   				last_updated_by   	= 	fnd_global.user_id,
		   				last_update_login 	= 	fnd_global.login_id
	     				WHERE 	project_id   		= 	l_award_project_id
	       				AND 	customer_id  		= 	G_contact_rec.customer_id;
				END IF;
			END IF;
		END IF;

		-- ========================================
		-- Calling Table Handler to Insert the Row.
		-- ========================================

		G_stage := 'gms_awards_contacts_pkg.insert_row' ;

		gms_awards_contacts_pkg.insert_row
				(	x_rowid		=>	L_rowid,
					x_award_id	=>	G_contact_rec.award_id,
					x_customer_id	=>	G_contact_rec.customer_id,
					x_contact_id	=>	G_contact_rec.contact_id,
					x_mode		=>	'R',
					x_primary_flag	=>	G_contact_rec.primary_flag,
					x_usage_code	=>	G_contact_rec.usage_code
				);

		G_stage := 'contact Created Successfully' ;

	EXCEPTION

		WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;

		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO create_contact_pvt ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;
		WHEN OTHERS THEN
			ROLLBACK TO create_contact_pvt;
			X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.add_exc_msg
					( p_pkg_name		=> G_PKG_NAME
					, p_procedure_name	=> l_api_name	);
			FND_MSG_PUB.Count_And_Get
					(   p_count		=>	x_msg_count	,
					    p_data		=>	x_msg_data	);

	END CREATE_CONTACT ;

	-- ========================================================================
	-- Create Report
	-- ========================================================================

	PROCEDURE CREATE_REPORT
			(x_MSG_COUNT                IN OUT NOCOPY     	NUMBER ,
			 x_MSG_DATA                 IN OUT NOCOPY     	VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     	VARCHAR2 ,
			 X_DEFAULT_REPORT_ID        IN OUT NOCOPY     	NUMBER ,
			 X_ROW_ID	               OUT NOCOPY     	VARCHAR2 ,
			 P_CALLING_MODULE           IN      	VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      	NUMBER ,
			 P_VALIDATE		    IN      	BOOLEAN default TRUE,
			 P_REPORT_REC              IN      	GMS_DEFAULT_REPORTS%ROWTYPE
			)
	IS

		CURSOR l_dup_reports_csr	IS
		SELECT 'X'
		FROM	gms_default_reports
    		WHERE 	award_id =   G_report_rec.award_id
    		AND  	report_template_id = G_report_rec.report_template_id;

		CURSOR l_valid_frequency_csr	IS
		SELECT 'X'
		FROM	gms_lookups
		WHERE	lookup_type = 'REPORT_FREQUENCY'
		AND	lookup_code = G_report_rec.frequency;

		CURSOR l_valid_site_code_csr	IS
		SELECT 'X'
                FROM    hz_cust_site_uses a,
                        Hz_cust_acct_sites b,
                        ar_lookups c,
                        gms_awards_all d
		WHERE   a.cust_acct_site_id = b. cust_acct_site_id
                AND     b. cust_account_id  = d.funding_source_id
                AND     d.award_id 	    = G_report_rec.award_id
                AND     c.lookup_type 	    = 'SITE_USE_CODE'
                AND     c.lookup_code       = a.site_use_code
                AND     a.site_use_id       = G_report_rec.site_use_id;

		l_api_name 		VARCHAR2(30) := 'CREATE_REPORT' ;
		l_error_code 		VARCHAR2(2000) ;
		l_error_stage		VARCHAR2(2000) ;
		l_rowid			VARCHAR2(45) ;
		l_dup_report		VARCHAR2(1);
		l_valid_frequency	VARCHAR2(1);
		l_valid_site_code	VARCHAR2(1);


	BEGIN

		-- =============================
		-- Initialize the Message Stack.
		-- =============================

		init_message_stack;

		G_msg_count	  := x_msg_count ;
		G_msg_data	  := x_MSG_DATA ;
		G_calling_module := P_CALLING_MODULE ;

		-- ============================
		-- Initialize the return status.
		-- ============================

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS) not in
		( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN
		    X_return_status := FND_API.G_RET_STS_SUCCESS ;
		END IF ;

		-- =========================
		-- Establish the Save Point.
		-- =========================

		SAVEPOINT create_report_pvt ;

		-- ==============================================================
		-- Compare the caller version number to the API version number in
		-- order to detect incompatible API calls.
		-- ==============================================================

		G_stage := 'FND_API.Compatible_API_Call' ;

  		IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
						     p_api_version_number	,
						     l_api_name 	    	,
						     G_pkg_name 	    	)
		THEN
				RAISE e_ver_mismatch ;
		END IF ;

		-- ============================================
		-- Check for required columns for Create Report
		-- ============================================

                G_stage := 'procedure_check_report_required_columns' ;

		G_report_rec	:= P_report_rec;

		IF G_report_rec.award_id IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_AWD_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_report_rec.report_template_id IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_REPORT_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_report_rec.frequency IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_REP_FREQUENCY_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_report_rec.due_within_days IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_REP_DUE_DAYS_NULL');
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF (G_report_rec.due_within_days < 0) THEN
       			add_message_to_stack( P_label => 'GMS_REP_DUE_DAYS_NEG');
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_report_rec.copy_number IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_REP_COPY_NUM_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF (G_report_rec.copy_number < 0) THEN
       			add_message_to_stack( P_label => 'GMS_REP_COPY_NUM_NEG');
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		-- ===================================================================
		-- Need to make sure that the return status is success from the above
		-- validations. There is no point in doing further validations as the
		-- required columns donot have values. So we raise an Error.
		-- ===================================================================

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- =================================
		-- Verify the frequency for validity
		-- =================================

		G_stage := 'create_report.Verify_frequency' ;

		OPEN l_valid_frequency_csr ;
		FETCH l_valid_frequency_csr INTO l_valid_frequency;

		IF l_valid_frequency_csr%NOTFOUND THEN
			 add_message_to_stack( P_label => 'GMS_REP_FREQUENCY_INVALID' ) ;
			 set_return_status ( X_return_status, 'B') ;
                 END IF;

		CLOSE l_valid_frequency_csr ;


		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- =====================================
		-- Verify the Site Use Code for validity
		-- =====================================

		G_stage := 'create_report.Verify_site_code';

		IF G_report_rec.site_use_id IS NOT NULL THEN

			OPEN l_valid_site_code_csr ;
			FETCH l_valid_site_code_csr INTO l_valid_site_code;

			IF l_valid_site_code_csr%NOTFOUND THEN
			 	add_message_to_stack( P_label => 'GMS_REP_SITE_USE_ID_INVALID' ) ;
			 	set_return_status ( X_return_status, 'B') ;
                 	END IF;

			CLOSE l_valid_site_code_csr ;

		END IF;

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- ==============================================
		-- Verify the duplicate reports for a given award
		-- ==============================================

		G_stage := 'create_report.Verify_duplicate_reports' ;

		OPEN l_dup_reports_csr ;
		FETCH l_dup_reports_csr INTO l_dup_report;

		IF l_dup_reports_csr%FOUND THEN
			 add_message_to_stack( P_label => 'GMS_REP_AWD_REPORT_DUP' ) ;
			 set_return_status ( X_return_status, 'B') ;
                 END IF;

		CLOSE l_dup_reports_csr ;


		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- ==================================================
		-- Sequence number is required for default report id.
		-- ==================================================

		G_stage := 'gms_default_reports_pkg.insert_row' ;

		SELECT 	gms_default_reports_s.nextval
		INTO 	G_report_rec.default_report_id
		FROM 	dual ;

		-- ========================================
		-- Calling Table Handler to Insert the Row.
		-- ========================================

		gms_default_reports_pkg.insert_row(
  				X_ROWID => l_rowid,
  				X_DEFAULT_REPORT_ID => G_report_rec.default_report_id,
  				X_REPORT_TEMPLATE_ID => G_report_rec.report_template_id,
  				X_AWARD_ID => G_report_rec.award_id,
  				X_FREQUENCY => G_report_rec.frequency,
  				X_DUE_WITHIN_DAYS => G_report_rec.due_within_days,
  				X_SITE_USE_ID => G_report_rec.site_use_id,
  				X_COPY_NUMBER => G_report_rec.copy_number,
  				X_ATTRIBUTE_CATEGORY => '',
  				X_ATTRIBUTE1 => '',
  				X_ATTRIBUTE2 => '',
  				X_ATTRIBUTE3 => '',
  				X_ATTRIBUTE4 => '',
  				X_ATTRIBUTE5 => '',
  				X_ATTRIBUTE6 => '',
  				X_ATTRIBUTE7 => '',
  				X_ATTRIBUTE8 => '',
  				X_ATTRIBUTE9 => '',
  				X_ATTRIBUTE10 => '',
  				X_ATTRIBUTE11 => '',
  				X_ATTRIBUTE12 => '',
  				X_ATTRIBUTE13 => '',
  				X_ATTRIBUTE14 => '',
  				X_ATTRIBUTE15 => '',
  				X_MODE =>  'R'
  				);

		-- =====================================
		-- Creating Notification for the report.
		-- =====================================

		G_stage := 'gms_notification_pkg.crt_default_report_events';

		-- ========================================
		-- Calling Table Handler to Insert the Row.
		-- ========================================

		gms_notification_pkg.crt_default_report_events(
				P_AWARD_ID  => G_report_rec.award_id,
  				P_REPORT_TEMPLATE_ID => G_report_rec.report_template_id,
				x_err_code =>l_error_code,
  				x_err_stage =>l_error_stage
  				);

		IF l_error_code <> 0 THEN

		-- ==========================================================================================
		-- Using l_error_stage returned by the above call,so as not to mask up the returned message.
		-- ==========================================================================================

			 add_message_to_stack( 	P_label => l_error_stage );
			 set_return_status ( X_return_status, 'B') ;

		END IF;

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		X_DEFAULT_REPORT_ID := G_report_rec.default_report_id ;
		G_stage := 'Report Created Successfully' ;

	EXCEPTION

		WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;

		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO create_report_pvt ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;
		WHEN OTHERS THEN
			ROLLBACK TO create_report_pvt;
			X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.add_exc_msg
					( p_pkg_name		=> G_PKG_NAME
					, p_procedure_name	=> l_api_name	);
			FND_MSG_PUB.Count_And_Get
					(   p_count		=>	x_msg_count	,
					    p_data		=>	x_msg_data	);

	end CREATE_REPORT ;

	-- ========================================================================
	-- Create Notification
	-- ========================================================================

	PROCEDURE CREATE_NOTIFICATION
			(x_MSG_COUNT                IN OUT NOCOPY     	NUMBER ,
			 x_MSG_DATA                 IN OUT NOCOPY     	VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     	VARCHAR2 ,
			 X_ROW_ID	               OUT NOCOPY     	VARCHAR2 ,
			 P_CALLING_MODULE           IN      	VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      	NUMBER ,
			 P_VALIDATE		    IN      	BOOLEAN default TRUE,
			 P_NOTIFICATION_REC         IN      	GMS_NOTIFICATIONS%ROWTYPE
			)
	IS

		CURSOR l_dup_event_csr	IS
		SELECT 'X'
		FROM	gms_notifications
    		WHERE 	award_id =   G_notification_rec.award_id
    		AND  	event_type = G_notification_rec.event_type
		AND	user_id  = G_notification_rec.user_id;

		CURSOR l_default_report_csr(x_report_template_id NUMBER)	IS
		SELECT 'X'
		FROM	gms_default_reports
    		WHERE 	award_id =   G_notification_rec.award_id
    		AND  	report_template_id = x_report_template_id;

		CURSOR l_report_csr(x_report_template_id NUMBER)	IS
		SELECT 'X'
		FROM	gms_reports gr,
			gms_installments gi
    		WHERE 	gi.award_id =   G_notification_rec.award_id
		AND	gi.installment_id  = gr.installment_id
    		AND  	gr.report_template_id = x_report_template_id;

		l_api_name varchar2(30) := 'CREATE_NOTIFICATION' ;
		l_error_code 			VARCHAR2(2000) ;
		l_error_stage			VARCHAR2(2000) ;
		l_rowid			varchar2(45) ;
		l_dup_event	VARCHAR2(1);
		l_default_report	VARCHAR2(1);
		l_report	VARCHAR2(1);
		l_report_template_id 	NUMBER;
		l_length 	NUMBER;

	BEGIN
		init_message_stack;

		G_msg_count	  := x_msg_count ;
		G_msg_data	  := x_MSG_DATA ;
		G_calling_module := P_CALLING_MODULE ;

		-- ============
		-- Initialize the return status.
		-- ============

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS) not in
		( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN
		    X_return_status := FND_API.G_RET_STS_SUCCESS ;
		END IF ;

		SAVEPOINT create_notification_pvt ;

		G_stage := 'FND_API.Compatible_API_Call' ;

  		IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
						     p_api_version_number	,
						     l_api_name 	    	,
						     G_pkg_name 	    	)
		THEN
				RAISE e_ver_mismatch ;
		END IF ;

		G_notification_rec	:= P_notification_rec;

		-- ==================================================
		-- Check for required columns for Create Notification
		-- ==================================================

                G_stage := 'procedure_check_notification_required_columns' ;

		IF G_notification_rec.award_id IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_AWD_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_notification_rec.event_type IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_NTF_EVENT_TYPE_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF G_notification_rec.user_id IS NULL THEN
       			add_message_to_stack( P_label => 'GMS_NTF_USER_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		-- ===================================================================
		-- Need to make sure that the return status is success from the above
		-- validations. There is no point in doing further validations as the
		-- required columns donot have values. So we raise an Error.
		-- ===================================================================

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- =============================================
		-- Verify the duplicate events for a given award
		-- =============================================

		G_stage := 'create_notification.Verify_duplicate_events' ;

			OPEN l_dup_event_csr ;
			FETCH l_dup_event_csr INTO l_dup_event;

			IF l_dup_event_csr%FOUND THEN
				 add_message_to_stack( P_label => 'GMS_NTF_AWD _EVENT_DUP' ) ;
				 set_return_status ( X_return_status, 'B') ;
                        END IF;
			CLOSE l_dup_event_csr ;


		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;


		G_stage := 'create_notification.Verify_report_existence' ;


		-- ==============================================================================
		-- Verify the existence of report for a given award if the event type is a report
		-- ==============================================================================

		IF    substr(G_notification_rec.event_type,1,6) = 'REPORT'  THEN

			l_length := length(G_notification_rec.event_type);
			l_report_template_id := substr(G_notification_rec.event_type,7,l_length);

			OPEN l_default_report_csr(l_report_template_id) ;
			FETCH l_default_report_csr INTO l_default_report;

			IF l_default_report_csr%NOTFOUND THEN
				OPEN l_report_csr(l_report_template_id) ;
				FETCH l_report_csr INTO l_report;
					IF l_report_csr%NOTFOUND THEN
				 		add_message_to_stack( P_label => 'GMS_NTF_AWD_REP_NOT_EXIST' ) ;
				 		set_return_status ( X_return_status, 'B') ;
                        		END IF;
                        END IF;
			CLOSE l_default_report_csr ;

			IF  l_report_csr%ISOPEN THEN
			CLOSE l_dup_event_csr ;
			END IF;

		END IF;
		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		G_stage := 'gms_notification_pkg.insert_row' ;

		gms_notification_pkg.insert_row(
  				X_ROWID => l_rowid,
  				X_AWARD_ID => G_notification_rec.award_id,
  				X_EVENT_TYPE => G_notification_rec.event_type,
  				X_USER_ID => G_notification_rec.user_id
  				);


		G_stage := 'Notification Created Successfully' ;

	EXCEPTION
		WHEN E_VER_MISMATCH THEN
			add_message_to_stack( P_label => 'GMS_API_VER_MISMATCH',
					      p_token1 => 'SUPVER',
					      P_VAL1 => g_api_version_number) ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;

		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO create_notification_pvt ;
			set_return_status(X_return_status, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;
		WHEN OTHERS THEN
			ROLLBACK TO create_notification_pvt;
			X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.add_exc_msg
					( p_pkg_name		=> G_PKG_NAME
					, p_procedure_name	=> l_api_name	);
			FND_MSG_PUB.Count_And_Get
					(   p_count		=>	x_msg_count	,
					    p_data		=>	x_msg_data	);

	END CREATE_NOTIFICATION ;

	-- ========================================================================
	-- Add Funding
	-- ========================================================================

	PROCEDURE ADD_FUNDING
			(X_MSG_COUNT                IN OUT NOCOPY     	NUMBER ,
			 X_MSG_DATA                 IN OUT NOCOPY     	VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     	VARCHAR2 ,
			 X_GMS_PROJECT_FUNDING_ID   IN OUT NOCOPY     	NUMBER ,
			 X_ROW_ID	               OUT NOCOPY     	VARCHAR2 ,
			 P_CALLING_MODULE           IN      	VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      	NUMBER ,
			 P_AWARD_ID		    IN		NUMBER,
			 P_INSTALLMENT_ID	    IN		NUMBER,
			 P_PROJECT_ID		    IN		NUMBER,
			 P_TASK_ID		    IN		NUMBER,
			 P_AMOUNT		    IN		NUMBER,
			 P_FUNDING_DATE		    IN		DATE
			)
	IS

		CURSOR	l_valid_award_csr	IS
		SELECT	*
		FROM	gms_awards_all
		WHERE	award_id  =  P_AWARD_ID;

		CURSOR l_valid_installment_csr	IS
		SELECT 	*
		FROM	gms_installments
    		WHERE 	award_id =   P_AWARD_ID
    		AND  	installment_id = P_INSTALLMENT_ID;

		CURSOR l_valid_project_csr	IS
		SELECT 	p.project_status_code,
			pt.project_type_class_code,
			pt.sponsored_flag,
			p.template_flag,
			p.start_date,
			p.closed_date
		FROM 	pa_projects_all p,
			pa_project_types_all pt
		WHERE  	p.project_id = P_PROJECT_ID
		AND	pt.project_type = p.project_type
                And     p.org_id = pt.org_id                /* For Bug  5414832*/
		AND 	pt.sponsored_flag='Y' ;


		CURSOR l_valid_task_csr	IS
		SELECT 'X'
		FROM 	pa_tasks
		WHERE 	project_id = P_project_id
		AND	task_id = P_task_id
		AND	task_id = top_task_id;

		CURSOR 	l_invalid_funding_level_csr IS
		SELECT  'X'
		FROM	gms_installments i,
                        gms_summary_project_fundings f
		WHERE	i.award_id = p_award_id
                AND     f.installment_id = i.installment_id
		AND	project_id = p_project_id
		AND	((task_id is null and p_task_id is not null) OR
                        (task_id is not null and p_task_id is null));

		CURSOR 	l_existing_funding_amount_csr IS
		SELECT  task_id,total_funding_amount
		FROM	gms_summary_project_fundings gspf
		WHERE	installment_id = P_installment_id
		AND	project_id = P_project_id
		AND	NVL(task_id,-99) = NVL(P_task_id,-99);


		l_api_name 			VARCHAR2(30) := 'ADD_FUNDING' ;
		l_error_code 			VARCHAR2(2000) ;
		l_app_name 			VARCHAR2(10) ;
		l_error_stage			VARCHAR2(2000) ;
		l_return_code 			VARCHAR2(1);
		l_errbuf 			VARCHAR2(2000);
		l_rowid				VARCHAR2(45) ;
		l_funding_level 		VARCHAR2(1) := 'P' ;
		l_project_status_code		VARCHAR2(60);
                l_project_type_class_code	VARCHAR2(60);
                l_sponsored_flag		VARCHAR2(1);
                l_template_flag			VARCHAR2(1);
                l_project_start_date		DATE;
                l_project_closed_date		DATE;
		l_valid_task			VARCHAR2(1);
		l_invalid_funding_level		VARCHAR2(1);
		l_task_id			NUMBER;
		l_existing_funding_amount 	NUMBER;
		l_total_installment_amount 	NUMBER;
		l_total_funding_amount 		NUMBER;
		l_project_funding_id 		NUMBER;
		l_installment_rec		GMS_INSTALLMENTS%ROWTYPE;
		l_award_rec			GMS_AWARDS_ALL%ROWTYPE;




	BEGIN
		init_message_stack;

		G_msg_count	  := X_MSG_COUNT ;
		G_msg_data	  := X_MSG_DATA ;
		G_calling_module  := P_CALLING_MODULE ;

		-- ============================
		-- Initialize the return status.
		-- ============================

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS) not in
		( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR  ) THEN
		    X_return_status := FND_API.G_RET_STS_SUCCESS ;
		END IF ;

		SAVEPOINT add_funding_pvt ;

		-- ===================================================
		-- Need to set global variables to use PA public APIs.
		-- ===================================================

		G_stage := 'pa_interface_utils_pub.set_global_info';

		pa_interface_utils_pub.set_global_info(p_api_version_number => 1.0,
                                       p_responsibility_id => FND_GLOBAL.resp_id,
                                       p_user_id => FND_GLOBAL.user_id,
                                       p_resp_appl_id => FND_GLOBAL.resp_appl_id, -- Bug 2534915
                                       p_msg_count  => x_msg_count,
                                       p_msg_data  =>x_msg_data,
                                       p_return_status   => x_return_status);

		IF x_return_status <> 'S'  THEN

			 add_message_to_stack( 	P_label 	=> 	'GMS_SET_GLOBAL_INFO_FAILED');
			 set_return_status ( X_return_status, 'U') ;

		END IF;

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		G_stage := 'FND_API.Compatible_API_Call' ;

  		IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
						     p_api_version_number	,
						     l_api_name 	    	,
						     G_pkg_name 	    	)
		THEN
				RAISE e_ver_mismatch ;
		END IF ;

		-- ===================================================================
		-- Check for required columns for Add Funding
		-- Award Id should NOT be NULL.
		-- Installment Id should NOT be NULL.
		-- Project Id should NOT be NULL.
		-- Amount should NOT be NULL.
		-- Amount should NOT be NEGATIVE.
		-- Project Funding Date should NOT be NULL.
		-- ===================================================================

		IF P_AWARD_ID IS NULL THEN
       			add_message_to_stack( P_label 	=> 	'GMS_AWD_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF P_INSTALLMENT_ID IS NULL THEN
       			add_message_to_stack( P_label 	=> 	'GMS_FND_INST_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF P_PROJECT_ID IS NULL THEN
       			add_message_to_stack( P_label 	=> 	'GMS_FND_PROJECT_ID_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF P_AMOUNT IS NULL THEN
       			add_message_to_stack( P_label 	=> 	'GMS_FND_AMOUNT_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF P_AMOUNT < 0 THEN
       			add_message_to_stack( P_label 	=> 	'GMS_FND_AMOUNT_NEG' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF P_FUNDING_DATE IS NULL THEN
       			add_message_to_stack( P_label 	=> 	'GMS_FND_DATE_NULL' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		-- ===================================================================
		-- Need to make sure that the return status is success from the above
		-- validations. There is no point in doing further validations as the
		-- required columns donot have values. So we raise an Error.
		-- ===================================================================

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- ===================================================================
		-- Check for the Award Validity
		--
		-- We check whether the award is an existing award or not. We dont need
		-- to validate the award status. Funding is done from an award with any
		-- status like Closed,At Risk, On Hold, Active etc.
		-- ===================================================================

		G_stage := 'add_funding.Verify_Award';

		OPEN l_valid_award_csr ;
		FETCH l_valid_award_csr INTO l_award_rec;

		IF l_valid_award_csr%NOTFOUND THEN
			 add_message_to_stack( P_label 	=> 	'GMS_AWD_NOT_EXISTS' ) ;
			 set_return_status ( X_return_status, 'B') ;
                 END IF;

		CLOSE l_valid_award_csr ;

		-- ===================================================================
		-- Check for the Installment Validity
		-- We check for the installment existance in the database, so it is a
		-- valid installment, and we check the active flag also, as project
		-- funding can be done from active installments only.
		-- ===================================================================

		G_stage := 'add_funding.Verify_Installment';

		OPEN l_valid_installment_csr ;
		FETCH l_valid_installment_csr INTO l_installment_rec;

		IF l_valid_installment_csr%NOTFOUND THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_INSTALL_ID_INVALID' ) ;
			 set_return_status ( X_return_status, 'B') ;
                 END IF;

		CLOSE l_valid_installment_csr ;

		IF l_installment_rec.active_flag  <> 'Y'  THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_INSTALL_INACTIVE' ) ;
			 set_return_status ( X_return_status, 'B') ;
                 END IF;


		-- ===================================================================
		-- Check for the Project Validity
		-- We do the following validations to make sure that the project is a
		-- valid one for project funding.
		-- The project should be defined in the system.
		-- The Project Type Class should be INDIRECT or CAPITAL
		-- The Project Status should NOT be CLOSED or UNAPPROVED
		-- The Project should not end before the Installment Start Date
		-- The Project should not start after the Installment End Date
		-- ===================================================================

		G_stage := 'add_funding.Verify_project';

		OPEN  l_valid_project_csr;
		FETCH l_valid_project_csr INTO 	l_project_status_code,
						l_project_type_class_code,
						l_sponsored_flag,
						l_template_flag,
						l_project_start_date,
						l_project_closed_date;

		IF l_valid_project_csr%NOTFOUND THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_PROJECT_ID_INVALID' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		CLOSE l_valid_project_csr ;

		IF  l_project_status_code IN ('CLOSED','UNAPPROVED')  THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_PROJ_STATUS_INVALID' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		IF  l_project_type_class_code NOT IN ('INDIRECT', 'CAPITAL')  THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_PROJ_TYPE_INVALID' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		IF  l_sponsored_flag <> 'Y' THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_NOT_SPONSORED_PROJ' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		IF  l_template_flag = 'Y' THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_PROJ_TEMPLATE' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		IF  NVL(l_project_closed_date,l_installment_rec.close_date) < l_installment_rec.start_date_active THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_PROJ_CLOSED' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;

		IF  l_project_start_date  > l_installment_rec.end_date_active  THEN
			 add_message_to_stack( P_label 	=> 	'GMS_FND_PROJ_NOT_STARTED' ) ;
			 set_return_status ( X_return_status, 'B') ;
                END IF;


		-- ==============================================================================
		-- Determining the Funding Level
		-- We select task id, funding amount from gms_summary_project_fundings table
		-- We default the Project Funding Level to 'P' means Project Level.
		-- If the cursor did not find any record, then it would be 'F' meaning First Time
		-- time funding. If the select returns a Task Id then it would be Task Level
		-- Funding.
		-- ==============================================================================

                G_stage := 'Add_funding.Getting Funding Level' ;

		OPEN l_existing_funding_amount_csr;
		FETCH l_existing_funding_amount_csr  INTO  l_task_id,
						           l_existing_funding_amount;
		IF  l_existing_funding_amount_csr%NOTFOUND THEN
			l_funding_level := 'F';
		END IF;

		CLOSE l_existing_funding_amount_csr;

		IF l_task_id IS NOT NULL THEN
			l_funding_level := 'T';
		END IF;


		-- ============================================================
		-- Check for Task Id required or not. If the funding level is T
		-- Task Id becomes mandatory. If the funding level is P task Id
		-- should be null. If funding level is F meaning this is the
		-- first time funding so we need not worry even if task id passed
		-- or null
		-- ============================================================

                -- Bug 2381094

                G_stage := 'Add_funding.Validating Funding Level' ;

		OPEN  l_invalid_funding_level_csr;
		FETCH l_invalid_funding_level_csr  INTO  l_invalid_funding_level;

                IF l_invalid_funding_level_csr%FOUND THEN

			if P_task_id IS NOT NULL THEN
       			   add_message_to_stack( P_label => 'GMS_FND_PROJ_LVL_FUND');
                        else
       			   add_message_to_stack( P_label => 'GMS_FND_TASK_LVL_FUND');
			end if;

	 		set_return_status ( X_return_status, 'B') ;

                END IF;

		CLOSE l_invalid_funding_level_csr;


		-- =================================================================
		-- Check for the Task validity. Task need to be validated
		-- only when the task id is required, i.e if the funding
		-- level is in 'P' or 'F' then we need task id also. If it is
		-- passed then we need to validate it.
		-- ==================================================================

		IF l_funding_level <> 'P' and p_task_id IS NOT NULL then

			G_stage := 'add_funding.Verify_Task';

			OPEN l_valid_task_csr ;
			FETCH l_valid_task_csr INTO l_valid_task;

			IF l_valid_task_csr%NOTFOUND THEN
			 	add_message_to_stack( P_label 	=> 	'GMS_FND_TASK_INVALID' ) ;
			 	set_return_status ( X_return_status, 'B') ;
                 	END IF;

			CLOSE l_valid_task_csr ;

		END IF;

		-- ===================================================================
		-- Check for the Project Funding Date Validity
		-- The Project FUnding Date should NOT be NULL.
		-- This is done at the beginning.
		-- The Project Funding Date should be with Pre Award Date,if exists  or
		--  Award Start Date and Award Close Date.
		-- ===================================================================

		IF (P_FUNDING_DATE < NVL(l_award_rec.preaward_date,l_award_rec.start_date_active)) OR
		   (P_FUNDING_DATE > l_award_rec.close_date) THEN
			 	add_message_to_stack( P_label 	=> 	'GMS_FND_FUND_DATE_INVALID' ) ;
			 	set_return_status ( X_return_status, 'B') ;
               	END IF;

		-- ==================================================================
		-- Amount Check
		--
		-- The Amount check will be done in the following ways
		-- 1) The Funding Amount should not be negative
		--    This is done at the beginning
		-- 2) The total funding Amount for all the projects and
		--    Tasks for the given Installment should not exceed
		--    Total Installment Amount
		-- 3) The total funding amount for the project and task and
		--    Installment should not go below the budgeted amount
		--
		--   We are not doing the budget amount validation as
		--   ADD_FUNDING is supposed to increase the funding amount
		--   always. When negative amounts are considered fro Project
		--   Funding then we need to do the above validation also.
		-- ==================================================================

		-- ============================================
		-- Validate  the amount with installment amount
		-- ============================================

		G_stage := 'Add_funding.Verify_amount_with_installment' ;

		l_total_installment_amount := l_installment_rec.direct_cost + l_installment_rec.indirect_cost;

		l_total_funding_amount :=  NVL(l_existing_funding_amount,0) + P_Amount;

		IF l_total_funding_amount  >  l_total_installment_amount   THEN
       			add_message_to_stack( P_label 		=> 	'GMS_FUNDING_AMOUNT_EXCEEDED' ) ;
	 		set_return_status ( X_return_status, 'B') ;
       		END IF ;

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- ======================================================
		-- Sequence number is required for gms_project_funding_id
		-- ======================================================

		G_stage := 'gms_project_fundings_pkg.insert_row' ;

		SELECT 	gms_project_fundings_s.nextval
  		INTO   	x_gms_project_funding_id
  		FROM   dual;

		GMS_PROJECT_FUNDINGS_PKG.INSERT_ROW(
  				X_ROWID 			=> 	l_rowid,
  				X_GMS_PROJECT_FUNDING_ID 	=> 	x_gms_project_funding_id,
  				X_PROJECT_FUNDING_ID 		=> 	l_project_funding_id,
  				X_PROJECT_ID 			=> 	P_project_id,
  				X_TASK_ID 			=> 	P_task_id,
  				X_INSTALLMENT_ID 		=> 	P_installment_id,
  				X_FUNDING_AMOUNT 		=> 	P_amount,
  				X_DATE_ALLOCATED 		=> 	P_funding_date,
  				X_MODE 				=> 	'R'
  				);

		-- ================================================================
		-- GMS_SUMMARY_PROJECT_FUNDINGS need to be updated with this amount
		-- if this project and task and installment combination exists or
		-- this need to be inserted.
		-- ================================================================

		G_stage := 'gms_summary_project_fundings.create_funding' ;

		GMS_SUMM_FUNDING_PKG.CREATE_GMS_SUMMARY_FUNDING(
				X_INSTALLMENT_ID 		=> 	P_installment_id,
				X_PROJECT_ID 			=> 	P_project_id,
				X_TASK_ID 			=> 	P_task_id,
				X_FUNDING_AMOUNT 		=> 	P_amount,
				RETCODE          		=> 	l_return_code,
				ERRBUF           		=> 	l_errbuf
				);


		IF l_return_code <> 'S'  THEN

			 add_message_to_stack( 	P_label 	=> 	'GMS_FND_SUMMARY_CRT_FAILED');
			 set_return_status ( X_return_status, 'B') ;

		END IF;

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		-- ============================================================
		-- PA_PROJECT_FUNDINGS and PA_SUMMARY_PROJECT_FUNDINGS
		-- need to be updated with this information. The revenue budget
		-- for the award project need to be re built with the updated
		-- amounts.
		-- =============================================================

		G_stage := 'gms_multi_funding.create_award_funding' ;

		GMS_MULTI_FUNDING.CREATE_AWARD_FUNDING(
 				X_INSTALLMENT_ID 		=> 	P_installment_id,
 				X_ALLOCATED_AMOUNT 		=> 	P_amount,
 				X_DATE_ALLOCATED 		=> 	P_funding_date,
 				X_GMS_PROJECT_FUNDING_ID  	=> 	x_gms_project_funding_id,
 				X_PROJECT_FUNDING_ID 		=> 	l_project_funding_id,
 				X_APP_SHORT_NAME 		=> 	l_app_name,
 				X_MSG_COUNT 			=> 	x_msg_count,
 				ERRBUF  			=> 	l_errbuf,
 				RETCODE  			=> 	l_return_code
				);

		IF l_return_code <> 'S'  THEN

			 add_message_to_stack( 	P_LABEL => 'GMS_FND_AWD_FND_FAILED');
			 set_return_status ( X_RETURN_STATUS, 'B') ;

		END IF;

		IF NVL(X_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS then
			RAISE FND_API.G_EXC_ERROR;
		END IF ;

		G_stage := 'At the End of the ADD_FUNDING';

	EXCEPTION
		WHEN E_VER_MISMATCH THEN
			add_message_to_stack(
				P_LABEL 			=> 	'GMS_API_VER_MISMATCH',
			      	P_TOKEN1 			=> 	'SUPVER',
			      	P_VAL1 				=> 	g_api_version_number) ;
			set_return_status(X_RETURN_STATUS, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;

		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO add_funding_pvt ;
			set_return_status(X_RETURN_STATUS, 'B' ) ;
			x_msg_count := G_msg_count ;
			x_msg_data  := G_msg_data ;
		WHEN OTHERS THEN
			ROLLBACK TO add_funding_pvt;
			X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.add_exc_msg
					( P_PKG_NAME		=> 	G_PKG_NAME
					, P_PROCEDURE_NAME	=> 	l_api_name	);
			FND_MSG_PUB.Count_And_Get
					(   P_COUNT		=>	x_msg_count	,
					    P_DATA		=>	x_msg_data	);

	END ADD_FUNDING;
END GMS_AWARD_PVT ;

/
