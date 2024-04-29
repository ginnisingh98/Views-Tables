--------------------------------------------------------
--  DDL for Package Body CSC_SERVICE_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_SERVICE_REQUEST_PVT" AS
/* $Header: cscvcsrb.pls 115.6 2003/01/04 00:56:53 akalidin noship $ */


/*************GLOBAL VARIABLES*************************/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSC_Service_Request_PVT' ;

/* ************************************************************************* *
 *              Forward Declaration of Local Procedures                      *
 *                                                                           *
 *   The following local procedures are called by the APIs in this package.  *
 *                                                                           *
 * ************************************************************************* */

--------------------------------------------------------------------------
-- Procedure Create_Service_Request
-- Description: Takes in the variables and calls the service request API
--   to create a service request.
--   On Success the service request number should be returned
-- Input Parameters
-- Out Parameters
-- service_request_number,
-- x_return_status, standard parameter for the return status
--------------------------------------------------------------------------

FUNCTION Create_Service_Request(
    p_api_version_number   IN  NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_string           OUT NOCOPY VARCHAR2,
    CUSTOMER_ID            IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    CUST_ACCOUNT_ID        IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    CUSTOMER_TYPE          IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    SERIAL_NUMBER          IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    TYPE_ID                IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    SUMMARY         	   IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    SEVERITY_ID            IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    URGENCY_ID             IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    NOTE_TYPE         	   IN  VARCHAR2      := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    NOTE         		   IN  VARCHAR2      := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    CONTACT_ID             IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    CONTACT_POINT_ID       IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    PRIMARY_FLAG           IN  VARCHAR2     := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    CONTACT_POINT_TYPE     IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    CONTACT_TYPE           IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    x_service_request_number out NOCOPY VARCHAR2
    ) return varchar2
    is
	-- Declare variables and record,table types
	l_return				varchar2(100);
	l_return_status		varchar2(50);
	l_msg_count			number;
	l_msg_data			varchar2(10000);
	l_request_id			number;
	l_request_number		varchar2(50);
	l_interaction_id		number;
	l_incident_id			number;
	l_incident_number		varchar2(100);
	l_individual_owner		NUMBER;
	l_individual_type		VARCHAR2(2000);
	l_group_owner			NUMBER;

	subtype r_service_request_rec_type is CS_SERVICEREQUEST_PVT.service_request_rec_type;
	r_service_request_rec	r_service_request_rec_type ;

	subtype t_notes_table_type is CS_SERVICEREQUEST_PVT.notes_table;
	t_notes_table 			t_notes_table_type;

	subtype t_contacts_table_type is CS_SERVICEREQUEST_PVT.contacts_table;
	t_contacts_table 		t_contacts_table_type;

	l_rec_count			number;
	l_msg_index_out		number;

	l_item_key			varchar2(100);
	l_return_Status_wkflw	varchar2(100);

	counter				number;
	l_workflow_process_id	number;
	mesg					varchar2(100);

	l_default_type_id			number;
	l_default_urgency_id		number;
	l_default_owner_id			number;
	l_default_severity_id		number;
	l_default_status_id			number;

	l_default_act_severity_id		number;
	l_default_act_assignee_id		number;
	l_default_act_type_id			number;

	l_default_type				varchar2(30) := null;
	l_default_type_cnt			number	 := 0;
	l_default_urgency			varchar2(30) := null;
	l_default_owner			varchar2(240) := null;
	l_default_severity			varchar2(30) := null;
	l_default_Status			varchar2(100);
	l_default_type_workflow		varchar2(30) := null;
	l_default_type_workflow_nm	varchar2(80) := null;

	l_default_incident_date			date;
	l_default_resource_type			varchar2(100);

	cursor C1(c_owner_id number) is
		select resource_type
		from cs_sr_owners_v
		where resource_id = c_owner_id;

    Begin
	-- Initialise the SR Rec

		l_return := 'SRFailure';

		cs_servicerequest_pvt.initialize_rec(r_service_request_rec);

		CS_SR_UTIL_PKG.Get_Default_values(
		p_default_type_id		=>  l_default_type_id,
		p_default_type			=>  l_default_type,
		p_default_type_workflow	=>  l_default_type_workflow,
		p_default_type_workflow_nm	=>  l_default_type_workflow_nm,
		p_default_type_cnt		=>  l_default_type_cnt,
		p_default_severity_id	=>  l_default_severity_id,
		p_default_severity 		=>  l_default_severity,
		p_default_urgency_id	=>  l_default_urgency_id,
		p_default_urgency 	=>  l_default_urgency,
		p_default_owner_id	=>  l_default_owner_id,
		p_default_owner 	=>  l_default_owner,
		p_default_status_id	=>  l_default_status_id,
		p_default_status 	=>  l_default_status);

		open C1(l_default_owner_id);
		fetch C1 into l_default_resourcE_type;
		close C1;


		-- Populate the values for the Rec

		r_service_request_rec.request_date	:= sysdate;
		r_service_request_rec.account_id	:= Cust_account_id ; -- <<??
		r_service_request_Rec.status_id	:= l_default_Status_id;

		if (type_id is null ) then
			r_service_request_Rec.type_id	:= l_default_type_id;
		else
			r_service_request_Rec.type_id	:= type_id;
		end if;

		if (severity_id is null ) then
			r_service_request_Rec.severity_id	:= l_default_severity_id;
		else
			r_service_request_Rec.severity_id	:= severity_id;
		end if;
		if (urgency_id is null ) then
			r_service_request_Rec.urgency_id	:= l_default_urgency_id;
		else
			r_service_request_Rec.urgency_id	:= urgency_id;
		end if;
		r_service_request_rec.closed_date	:= null;
		r_service_request_Rec.owner_id		:= l_default_owner_id;
		r_service_request_Rec.current_Serial_number := serial_number ;
-----		r_service_request_Rec.problem_code  	:= problem_code ;

		r_service_request_rec.summary		:= Summary ; -- <<??
		r_service_request_rec.caller_type	:= customer_type ; -- <<??
		r_service_request_rec.customer_id       := Customer_id; -- <<??

		r_service_request_rec.resource_type 	:= l_default_resource_type ;

		-- This line were added for 1159 service request API change
		r_service_request_rec.creation_program_code 	:= 'CSCCCQSR.SCR' ;
		r_service_request_rec.last_update_program_code 	:= 'CSCCCQSR.SCR' ;

		t_notes_table(1).note_type		:= note_type ;--<< ??
		t_notes_table(1).note			:= note ;--<< ??

		-- Contacts info..
		t_contacts_table(1).party_id		:= contact_id ; --<<??
		t_contacts_table(1).contact_point_id	:= contact_point_id ; --<<??
		t_contacts_table(1).contact_point_type	:= contact_point_type; --<<??
		t_contacts_table(1).contact_type	:= contact_type; --<<??
		t_contacts_table(1).primary_flag	:= primary_flag; --<<??


	-- Create the SR

		CS_SERVICEREQUEST_PVT.Create_serviceRequest(
		p_api_version		=> 3,
		p_init_msg_list	=> csc_core_utils_pvt.g_true,
		p_commit			=> csc_core_utils_pvt.g_true,
		p_validation_level	=> csc_core_utils_pvt.g_valid_level_none,
		x_return_Status	=> l_return_Status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		p_resp_appl_id		=> null,
		p_resp_id		=> null,
		p_user_id		=> FND_GLOBAL.USER_ID,
		p_login_id	=> FND_GLOBAL.CONC_LOGIN_ID,
		p_org_id		=> null,
		p_request_id		=> null,
		p_request_number	=> null,
		p_service_request_rec	=> r_service_request_Rec,
		p_notes			=> t_notes_table,
		p_contacts		=> t_contacts_table,
		x_request_id		=> l_incident_id,
		x_request_number	=> l_incident_number,
		x_interaction_id	=> l_interaction_id,
		x_workflow_process_id	=> l_workflow_process_id,
		x_individual_owner	=> l_individual_owner,
		x_individual_type	=> l_individual_type,
		x_group_owner		=> l_group_owner
		);

		x_return_Status := l_return_Status;

		if (l_return_status = csc_core_utils_pvt.g_ret_sts_success) then
			x_service_request_number := l_incident_number;
			l_return := 'SRSuccess';
			return l_return;
		else
      		IF ( FND_MSG_PUB.Count_Msg > 0) THEN
        		FOR i in 1..FND_MSG_PUB.Count_Msg
        		LOOP

          		FND_MSG_PUB.Get(p_msg_index 	=> i,
                        p_encoded 		=> 'F',
                        p_data 		=> x_msg_string,
                        p_msg_index_out => l_msg_index_out );

	      		--dbms_output.put_line(substr(x_msg_string,1,1000));

        		END LOOP;
			end if;
			l_return := 'SRFailure';
			return l_return;
		end if;

    End Create_Service_Request ;

END CSC_Service_Request_Pvt;

/
