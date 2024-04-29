--------------------------------------------------------
--  DDL for Package Body AST_UWQ_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_WRAPPER_PKG" AS
/* $Header: astugenb.pls 120.3 2005/08/30 22:28:20 appldev ship $ */

FUNCTION Convert_to_server_time(p_client_time IN date) return DATE
IS
l_client_tz_id      number;
l_server_tz_id      number;
l_msg_count         number;
l_msg_data          varchar2(2000);
l_start_tz_id       number;
l_end_tz_id         number;
l_status       varchar2(2);
s_GMT_dev      number;
e_GMT_dev      number;
x_server_time            date;

BEGIN

    l_client_tz_id :=   to_number(fnd_profile.value('CLIENT_TIMEZONE_ID'));
    l_server_tz_id :=   to_number(fnd_profile.value('SERVER_TIMEZONE_ID'));

    HZ_TIMEZONE_PUB.Get_Time(1.0, 'F', l_server_tz_id, l_client_tz_id,  p_client_time, x_server_time, l_status, l_msg_count, l_msg_data);

    return x_server_time;

END;


	PROCEDURE create_contact(
		p_admin_flag			IN	VARCHAR2,
		p_admin_group_id		IN	NUMBER,
		p_resource_id			IN	NUMBER,
		p_customer_id			IN	NUMBER,
		p_lead_id				IN	NUMBER,
		p_contact_party_id		IN	NUMBER,
		p_address_id			IN	NUMBER,
		x_return_status           OUT NOCOPY      VARCHAR2,
		x_msg_count               OUT NOCOPY      NUMBER,
		x_msg_data                OUT NOCOPY      VARCHAR2
	)
	IS
		l_admin_id    				  NUMBER := p_admin_group_id;
		v_lead_id             		  NUMBER := p_lead_id;
		v_contact_id 				  NUMBER;
		l_salesforce_id     		  NUMBER := p_resource_id;
		v_validation_level_full  	  NUMBER := 100;
		l_admin_flag  				  VARCHAR2(1) := nvl(p_admin_flag, 'N');
		v_true                   	  VARCHAR2(5)  := 'T';

		v_profile_tbl    			  AS_UTILITY_PUB.profile_tbl_type          := as_api_records_pkg.get_p_profile_tbl;
		v_contact_tbl    			  AS_OPPORTUNITY_PUB.contact_tbl_Type      := as_api_records_pkg.get_p_contact_tbl;
		v_contact_out_tbl 			  AS_OPPORTUNITY_PUB.contact_out_tbl_Type := as_api_records_pkg.get_p_contact_out_tbl;
		v_header_rec    			  AS_OPPORTUNITY_PUB.header_rec_Type        := as_api_records_pkg.get_p_header_rec;
	BEGIN
		v_header_rec.lead_id		  			:= v_lead_id;
		v_header_rec.last_update_date 	 		:= sysdate;

		v_contact_tbl(1).contact_party_id  		:= p_contact_party_id;
	--     v_contact_tbl(1).rank              := name_in('astopovw_header.role');
	--     v_contact_tbl(1).phone_id          := to_number(name_in('astopovw_header.phone_id'));
		v_contact_tbl(1).address_id        	  	:= p_address_id;
	--      v_contact_tbl(1).contact_id       := to_number(name_in('ASTOPOVW_HEADER.CONTACT_ID'));
		v_contact_tbl(1).lead_id            := v_lead_id;
		v_contact_tbl(1).customer_id        := p_customer_id;
--		v_contact_tbl(1).created_by       := p_created_by;
		v_contact_tbl(1).enabled_flag       := 'Y';
		v_contact_tbl(1).primary_contact_flag    := 'Y';

		AS_OPPORTUNITY_PUB.CREATE_CONTACTS(
		   p_api_version_number      => 2.0,
		   p_init_msg_list           => v_true,
		   p_commit                  => v_true,
		   p_validation_level        => v_validation_level_full,
		   p_identity_salesforce_id  => l_salesforce_id,
		   p_contact_tbl             => v_contact_tbl,
		   p_header_rec              => v_header_rec,
		   p_check_access_flag       => 'N',
		   p_admin_flag              => l_admin_flag,
		   p_admin_group_id          => l_admin_id,
		   p_partner_cont_party_id   => NULL,
		   p_profile_tbl             => v_profile_tbl,
		   x_contact_out_tbl         => v_contact_out_tbl,
		   x_return_status           => x_return_status,
		   x_msg_count               => x_msg_count,
		   x_msg_data                => x_msg_data
		);

        IF x_return_status <> 'S' THEN
          rollback;
		  return;
        END IF;

		EXCEPTION
	         WHEN OTHERS THEN
				 rollback;
				 return;
	END Create_Contact;

	PROCEDURE create_task (
		p_task_name               IN       VARCHAR2,
		p_task_type_name          IN       VARCHAR2,
		p_task_type_id            IN       NUMBER,
		p_description             IN       VARCHAR2,
		p_owner_id                IN	   	NUMBER,
		p_customer_id             IN       NUMBER,
		p_contact_id              IN       NUMBER,
		p_date_type			 IN	   	VARCHAR2,
		p_start_date    		 IN       DATE,
		p_end_date      		 IN       DATE,
		p_source_object_type_code IN       VARCHAR2,
		p_source_object_id        IN       NUMBER,
		p_source_object_name      IN       VARCHAR2,
		p_phone_id			 IN	   	NUMBER,
		p_address_id		  		IN	   	NUMBER,
		p_duration			 IN	   	NUMBER,
		p_duration_uom			 IN	   	VARCHAR2,
		p_called_node			 IN	   	VARCHAR2,
		x_return_status           OUT NOCOPY      VARCHAR2,
		x_msg_count               OUT NOCOPY      NUMBER,
		x_msg_data                OUT NOCOPY      VARCHAR2,
		x_task_id                 OUT NOCOPY      NUMBER
	)
	IS

	  l_counter                 BINARY_INTEGER := 0;
	  l_person_id				NUMBER;
  	  l_org_id				NUMBER;
	  l_address_id			NUMBER;
	  l_phone_id			NUMBER;
		l_task_contact_id              NUMBER;
		l_task_or_contact_party_id     NUMBER;
		l_task_phone_id                NUMBER;
		l_api_version			  	 NUMBER   	 := 1.0;
		l_timezone_id			  	 NUMBER 		 := fnd_profile.value('CLIENT_TIMEZONE_ID');
		l_task_status_id          	 NUMBER 		 := fnd_profile.value('JTF_TASK_DEFAULT_TASK_STATUS');
    	l_assigned_by_id          	 NUMBER 		 :=  FND_PROFILE.VALUE('USER_ID');
    	l_task_priority_id		  	 NUMBER 	   	 := fnd_profile.value('JTF_TASK_DEFAULT_TASK_PRIORITY');
		l_init_msg_list           	 VARCHAR2(5) 	 := 'T';
		l_commit                  	 VARCHAR2(5) 	 := 'T';
		l_task_status_name        	 VARCHAR2(30);
		l_date_type				 VARCHAR2(30);
    	l_task_priority_name	  	 VARCHAR2(30) ;
		l_task_phone_owner_table       VARCHAR2(30) 	 := 'JTF_TASKS_B' ;
    	l_owner_type_code   	  	 VARCHAR2(100);
    	l_assigned_by_name        	 VARCHAR2(100);
		l_source_object_name		 VARCHAR2(100);
    	l_owner_type_name    	  	 VARCHAR2(200);
		l_person_name		 VARCHAR2(100);
		l_org_name		 VARCHAR2(100);
		l_start_date	  	 DATE;
		l_end_date	  	 DATE;
		l_scheduled_start_date	  	 DATE;
		l_scheduled_end_date	  	 DATE;
		l_planned_start_date	  	 DATE;
		l_planned_end_date	   	  	 DATE;
		l_actual_start_date	   	  	 DATE;
		l_actual_end_date	   	  	 DATE;
		v_miss_task_assign_tbl     	 JTF_TASKS_PUB.TASK_ASSIGN_TBL;
		v_miss_task_depends_tbl    	 JTF_TASKS_PUB.TASK_DEPENDS_TBL;
		v_miss_task_rsrc_req_tbl   	 JTF_TASKS_PUB.TASK_RSRC_REQ_TBL;
		v_miss_task_refer_tbl      	 JTF_TASKS_PUB.TASK_REFER_TBL;
		v_miss_task_dates_tbl      	 JTF_TASKS_PUB.TASK_DATES_TBL;
		v_miss_task_notes_tbl      	 JTF_TASKS_PUB.TASK_NOTES_TBL;
		v_miss_task_recur_rec      	 JTF_TASKS_PUB.TASK_RECUR_REC;
		v_miss_task_contacts_tbl   	 JTF_TASKS_PUB.TASK_CONTACTS_TBL;
		v_task_refer_tbl           	 JTF_TASKS_PUB.TASK_REFER_TBL;

		--These variables are used for debugging.  To be removed
		l_count			 	 		   NUMBER;
		l_index			 	 		   NUMBER;
		my_message			 		   VARCHAR2(1000);


		CURSOR 	C_GetDefaultStatus(x_status_id Number) IS
		SELECT 	name
		FROM 	jtf_task_statuses_vl
		WHERE 	task_status_id = x_status_id
		AND 	trunc(sysdate) BETWEEN
				trunc(nvl(start_date_active, sysdate)) AND
				trunc(nvl(end_date_active, sysdate));

		CURSOR 	C_GetDefaultPriority(x_priority_id Number) IS
		SELECT 	name
		FROM 	jtf_task_priorities_vl
		WHERE 	task_priority_id = x_priority_id
		AND 	trunc(sysdate) BETWEEN
		     	trunc(nvl(start_date_active, sysdate)) AND
		     	trunc(nvl(end_date_active, sysdate));

		CURSOR 	Get_OwnerType IS
		SELECT 	object_code, name
		FROM 	jtf_objects_vl
		WHERE 	object_code in ( SELECT object_code FROM jtf_object_usages WHERE object_user_code = 'RESOURCES' )
		AND 	object_code = 'RS_EMPLOYEE';

		CURSOR 	C_GetUserName(x_user_id Number) is
		SELECT 	user_name
		FROM 	fnd_user
		WHERE 	user_id = x_user_id;

		CURSOR C_subject_and_object(x_party_id NUMBER) IS
		SELECT subject_id, object_id
		FROM   hz_relationships
		WHERE  party_id = x_party_id
		AND	   directional_flag = 'F'
		AND	   status = 'A';

		CURSOR C_Object_name(x_party_id NUMBER) IS
		SELECT party_name
		FROM   Hz_parties
		WHERE  party_id = x_party_id;

		CURSOR 	c_get_address_id (x_party_id NUMBER, x_location_id NUMBER) IS
		SELECT 	party_site_id
		FROM 	ast_locations_v
		WHERE 	party_id = x_party_id
		AND		location_id = x_location_id;

		CURSOR c_phone_id(x_owner_table_id number) IS
		SELECT contact_point_id
		FROM hz_contact_points
		WHERE owner_table_id = x_owner_table_id
		and owner_table_name = 'HZ_PARTIES'
		and contact_point_type = 'PHONE'
		and status = 'A'
		and primary_flag = 'Y';

	BEGIN
		l_date_type := upper(p_date_type);
          l_start_date := convert_to_server_time(p_start_date);
          l_end_date := convert_to_server_time(p_end_date);

		IF l_date_type = 'SCHEDULED' THEN
			l_scheduled_start_date := l_start_date;
			l_scheduled_end_date := l_end_date;
		ELSIF l_date_type = 'PLANNED' THEN
			l_planned_start_date := l_start_date;
			l_planned_end_date := l_end_date;
		ELSIF l_date_type = 'ACTUAL' THEN
			l_actual_start_date := l_start_date;
			l_actual_end_date := l_end_date;
		END IF;

		IF l_task_status_id IS NOT NULL THEN
			OPEN  C_GetDefaultStatus(l_task_status_id);
			FETCH C_GetDefaultStatus INTO l_task_status_name;
			CLOSE C_GetDefaultStatus;
		END IF;

		IF l_task_priority_id IS NOT NULL THEN
			OPEN C_GetDefaultPriority(l_task_priority_id);
			FETCH C_GetDefaultPriority INTO l_task_priority_name;
			CLOSE C_GetDefaultPriority;
		END IF;

		IF fnd_profile.value('JTF_TASK_DEFAULT_OWNER_TYPE') <> 'RS_EMPLOYEE' THEN
		     FND_MESSAGE.Set_Name('AST', 'AST_UWQ_IMPROPER_OWNER_TYPE');
		     FND_MSG_PUB.ADD;
		     x_return_status := FND_API.G_RET_STS_ERROR;
		--        x_msg_count := l_msg_count;
		--        x_msg_data  := l_msg_data;
		     RETURN;
		ELSE
		    OPEN Get_OwnerType;
		    FETCH Get_OwnerType INTO l_owner_type_code, l_owner_type_name;
		    CLOSE Get_OwnerType;
		END IF;

		IF (l_assigned_by_id IS NOT NULL) THEN
			OPEN C_GetUserName(l_assigned_by_id);
			FETCH C_GetUserName INTO l_assigned_by_name;
			CLOSE C_GetUserName;
		END IF;

		l_source_object_name := p_source_object_name;
		l_address_id		 := p_address_id;
		l_phone_id := p_phone_id;
		IF p_called_node = 'MLIST' THEN
 			IF p_address_id IS NOT NULL THEN
				OPEN c_get_address_id(p_source_object_id, p_address_id);
				FETCH c_get_address_id INTO l_address_id;
				CLOSE c_get_address_id;
			END IF;

			IF p_source_object_name IS NULL THEN
				OPEN C_Object_name(p_source_object_id);
				FETCH C_Object_name INTO l_source_object_name;
				CLOSE C_Object_name;
			END IF;

			/**Bug 2854526.  If phone_id is null, default it with primary_phone_id **/
/* Fix for bug#3526419
Comment out the code here and moved it down as the phone number should be defaulted irrespective
of which node the task is created.
*/

/*
			IF l_phone_id IS NULL THEN
				OPEN c_phone_id(p_source_object_id);
				FETCH c_phone_id INTO l_phone_id;
				CLOSE c_phone_id;
			END IF;
*/
		END IF;

		/**Fix for bug#3526419.  If phone_id is null, default it with primary_phone_id **/
		if p_contact_id is not null then
			IF l_phone_id IS NULL THEN
				OPEN c_phone_id(p_contact_id);
				FETCH c_phone_id INTO l_phone_id;
				CLOSE c_phone_id;
			END IF;
		elsif p_contact_id is null then
			IF l_phone_id IS NULL THEN
				OPEN c_phone_id(p_customer_id);
				FETCH c_phone_id INTO l_phone_id;
				CLOSE c_phone_id;
			END IF;
		end if;

		JTF_TASKS_PUB.CREATE_TASK(
		  P_API_VERSION            		=> l_api_version,
		  P_INIT_MSG_LIST          		=> l_init_msg_list,
		  P_COMMIT                 		=> l_commit,
		  P_TASK_ID                		=> null,
		  P_TASK_NAME              		=> p_task_name,
		  P_TASK_TYPE_NAME         		=> p_task_type_name,
		  P_TASK_TYPE_ID           		=> p_task_type_id,
		  P_DESCRIPTION            		=> p_description,
		  P_TASK_STATUS_NAME       		=> l_task_status_name,
		  P_TASK_STATUS_ID         		=> l_task_status_id,
		  P_TASK_PRIORITY_NAME     		=> l_task_priority_name,
		  P_TASK_PRIORITY_ID       		=> l_task_priority_id,
		  P_OWNER_TYPE_NAME        		=> l_owner_type_name,
		  P_OWNER_TYPE_CODE        		=> l_owner_type_code,
		  P_OWNER_ID               		=> nvl(fnd_profile.value('JTF_TASK_DEFAULT_OWNER'),p_owner_id), --Bug # 3626890
		  P_OWNER_TERRITORY_ID     		=> null,
		  P_ASSIGNED_BY_NAME       		=> l_assigned_by_name,
		  P_ASSIGNED_BY_ID         		=> l_assigned_by_id,
		  P_CUSTOMER_NUMBER        		=> null,
		  P_CUSTOMER_ID            		=> p_customer_id,
		  P_CUST_ACCOUNT_NUMBER    		=> null,
		  P_CUST_ACCOUNT_ID        		=> null,
		  P_ADDRESS_ID             		=> l_address_id,
		  P_ADDRESS_NUMBER         		=> null,
		  P_PLANNED_START_DATE     		=> l_planned_start_date,
		  P_PLANNED_END_DATE       		=> l_planned_end_date,
		  P_SCHEDULED_START_DATE   		=> l_scheduled_start_date,
		  P_SCHEDULED_END_DATE     		=> l_scheduled_end_date,
		  P_ACTUAL_START_DATE      		=> l_actual_start_date,
		  P_ACTUAL_END_DATE        		=> l_actual_end_date,
		  P_TIMEZONE_ID            		=> l_timezone_id,
		  P_TIMEZONE_NAME          		=> null,
		  P_SOURCE_OBJECT_TYPE_CODE     	=> p_source_object_type_code,
		  P_SOURCE_OBJECT_ID            	=> p_source_object_id,
		  P_SOURCE_OBJECT_NAME          	=> l_source_object_name,
		  P_DURATION                    	=> p_duration,
		  P_DURATION_UOM                	=> p_duration_uom,
		  P_PLANNED_EFFORT              	=> null,
		  P_PLANNED_EFFORT_UOM          	=> null,
		  P_ACTUAL_EFFORT               	=> null,
		  P_ACTUAL_EFFORT_UOM           	=> null,
		  P_PERCENTAGE_COMPLETE         	=> null,
		  P_REASON_CODE                 	=> null,
		  P_PRIVATE_FLAG                	=> null,
		  P_PUBLISH_FLAG                	=> null,
		  P_RESTRICT_CLOSURE_FLAG       	=> null,
		  P_MULTI_BOOKED_FLAG           	=> null,
		  P_MILESTONE_FLAG              	=> null,
		  P_HOLIDAY_FLAG                	=> null,
		  P_BILLABLE_FLAG               	=> null,
		  P_BOUND_MODE_CODE             	=> null,
		  P_SOFT_BOUND_FLAG             	=> null,
		  P_WORKFLOW_PROCESS_ID         	=> null,
		  P_NOTIFICATION_FLAG           	=> null,
		  P_NOTIFICATION_PERIOD         	=> null,
		  P_NOTIFICATION_PERIOD_UOM     	=> null,
		  P_ALARM_START                 	=> null,
		  P_ALARM_START_UOM             	=> null,
		  P_ALARM_ON                    	=> null,
		  P_ALARM_COUNT                 	=> null,
		  P_ALARM_INTERVAL              	=> null,
		  P_ALARM_INTERVAL_UOM          	=> null,
		  P_PALM_FLAG                   	=> null,
		  P_WINCE_FLAG                  	=> null,
		  P_LAPTOP_FLAG                 	=> null,
		  P_DEVICE1_FLAG                	=> null,
		  P_DEVICE2_FLAG                	=> null,
		  P_DEVICE3_FLAG                	=> null,
		  P_COSTS                       	=> null,
		  P_CURRENCY_CODE               	=> null,
		  P_ESCALATION_LEVEL            	=> null,
		  p_task_assign_tbl        		=> v_miss_task_assign_tbl,
		  p_task_depends_tbl       		=> v_miss_task_depends_tbl,
		  p_task_rsrc_req_tbl      		=> v_miss_task_rsrc_req_tbl,
		  p_task_refer_tbl         		=> v_task_refer_tbl,
		  p_task_dates_tbl         		=> v_miss_task_dates_tbl,
		  p_task_notes_tbl         		=> v_miss_task_notes_tbl,
		  p_task_recur_rec         		=> v_miss_task_recur_rec,
		  p_task_contacts_tbl      		=> v_miss_task_contacts_tbl,
		  X_RETURN_STATUS          		=> x_return_status,
		  X_MSG_COUNT              		=> x_msg_count,
		  X_MSG_DATA               		=> x_msg_data,
		  X_TASK_ID                		=> x_task_id,
		  p_attribute_category			=> null
		);

		IF x_return_status in ('E','U') THEN
		 	ROLLBACK;
			RETURN;
	     ELSIF x_return_status = 'S' THEN
		 	l_task_or_contact_party_id := x_task_id;
	     END IF;

		IF x_task_id IS NOT NULL AND p_contact_id IS NOT NULL THEN
			JTF_TASK_CONTACTS_PUB.CREATE_TASK_CONTACTS (
				P_API_VERSION                 => l_api_version,
				P_INIT_MSG_LIST               => l_init_msg_list,
				P_COMMIT                      => l_commit,
				P_TASK_ID                     => x_task_id,
				P_TASK_NUMBER                 => NULL,
				P_CONTACT_ID                  => p_contact_id,
				P_CONTACT_TYPE_CODE           => 'CUST',
				p_ESCALATION_NOTIFY_FLAG      => NULL,
				P_ESCALATION_REQUESTER_FLAG   => NULL,
				X_TASK_CONTACT_ID             => l_task_contact_id,
				X_RETURN_STATUS               => x_return_status,
				X_MSG_DATA                    => x_msg_data,
				X_MSG_COUNT                   => x_msg_count,
				P_PRIMARY_FLAG                => 'Y'
			);

			IF x_return_status IN ('E','U') THEN
					ROLLBACK;
					RETURN;
			ELSE
					l_task_or_contact_party_id := l_task_contact_id;
			END IF;
		END IF;

		IF l_task_or_contact_party_id IS NOT NULL and l_phone_id IS NOT NULL THEN
			IF p_contact_id IS NOT NULL THEN
				l_task_phone_owner_table := 'JTF_TASK_CONTACTS';
			ELSE
				l_task_phone_owner_table := 'JTF_TASKS_B';
			END IF;

			JTF_TASK_PHONES_PUB.CREATE_TASK_PHONES (
				p_api_version            => l_api_version,
				p_init_msg_list          => l_init_msg_list,
				p_commit                 => l_commit,
				p_task_contact_id        => l_task_or_contact_party_id,
				p_phone_id               => l_phone_id,
				x_task_phone_id          => l_task_phone_id,
				x_return_status          => x_return_status,
				x_msg_data               => x_msg_data,
				x_msg_count              => x_msg_count,
				p_owner_table_name       => l_task_phone_owner_table,
				p_primary_flag           => 'Y'
			);

			IF x_return_status IN ('E','U') THEN
					ROLLBACK;
					RETURN;
			END IF;
		END IF;

		EXCEPTION
			  WHEN OTHERS THEN
			  	   ROLLBACK;
				   RAISE;
	END create_task;

	PROCEDURE add_context_to_table(
		p_counter 			IN	BINARY_INTEGER,
		p_context_id 			IN	NUMBER,
		p_context_type			IN	VARCHAR2,
		p_last_update_date 		IN	DATE,
		p_last_updated_by 		IN	NUMBER,
		p_last_update_login		IN	NUMBER,
		p_creation_date 		IN	DATE,
		p_created_by			IN	NUMBER
	)
	IS
	BEGIN
		g_jtf_note_contexts_tab(p_counter).note_context_type := p_context_type;
		g_jtf_note_contexts_tab(p_counter).note_context_type_id := p_context_id;
		g_jtf_note_contexts_tab(p_counter).last_update_date := p_last_update_date;
		g_jtf_note_contexts_tab(p_counter).last_updated_by := p_last_updated_by;
		g_jtf_note_contexts_tab(p_counter).last_update_login := p_last_update_login;
		g_jtf_note_contexts_tab(p_counter).creation_date := p_creation_date;
		g_jtf_note_contexts_tab(p_counter).created_by := p_created_by;
	END add_context_to_table;

	PROCEDURE create_note (
		p_source_object_id       IN	NUMBER,
		p_source_object_code     IN 	VARCHAR2,
		p_notes     			IN 	VARCHAR2,
		p_notes_detail			IN 	VARCHAR2,
		p_entered_by			IN 	NUMBER,
		p_entered_date			IN 	DATE,
		p_last_update_date		IN 	DATE,
		p_last_updated_by		IN 	NUMBER,
		p_creation_date		IN 	DATE,
		p_created_by			IN 	NUMBER,
		p_last_update_login		IN 	NUMBER,
		p_party_id			IN	NUMBER,
		x_jtf_note_id            OUT NOCOPY NUMBER,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY 	NUMBER,
		x_msg_data               OUT NOCOPY VARCHAR2
	)
	IS
		l_api_version			NUMBER 		:= 1.0;
		l_valid_level_full		NUMBER 		:= 100;
		l_contact_id			NUMBER;
		l_counter			NUMBER;
		l_cust_account_id 		NUMBER;
		l_subject_id			NUMBER;
		l_object_id			NUMBER;
		l_note_status			VARCHAR2(3) 	:= nvl(fnd_profile.value('JTF_NTS_NOTE_STATUS'),'I');
		l_init_msg_list          VARCHAR2(5) 	:= 'T';
		l_commit                 VARCHAR2(5) 	:= 'T';
		l_note_type			VARCHAR2(30) 	:= fnd_profile.value('AST_NOTES_DEFAULT_TYPE');

		l_count						  NUMBER;
		l_index						  NUMBER;
		my_message					  VARCHAR2(1000);

		CURSOR C_opp_contact (p_opp_id NUMBER) IS
		SELECT contact_party_id
		FROM as_lead_contacts
		WHERE lead_id = p_opp_id
		and primary_contact_flag = 'Y';

		CURSOR C_lead_contact (p_lead_id NUMBER) IS
		SELECT contact_party_id
		FROM as_sales_lead_contacts
		WHERE sales_lead_id = p_lead_id
		and primary_contact_flag = 'Y';

		CURSOR C_task_references(p_task_id NUMBER) IS
		SELECT distinct object_type_code, object_id
		FROM jtf_task_references_b
		WHERE task_id = p_task_id;

		l_task_ref_row C_task_references%ROWTYPE;

		CURSOR C_del_account(p_delinquency_id NUMBER) IS
		SELECT cust_account_id
		FROM iex_delinquencies
		WHERE delinquency_id = p_delinquency_id;

		CURSOR C_subject_and_object(p_party_id NUMBER) IS
		SELECT subject_id, object_id
		FROM   hz_relationships
		WHERE  party_id = p_party_id
		AND	   directional_flag = 'F'
		AND	   status = 'A';

	BEGIN
		g_jtf_note_contexts_tab.delete;
		l_counter := 0;
		IF p_source_object_code = 'OPPORTUNITY' THEN
			IF nvl(fnd_profile.value('AS_NOTES_OPP_CONTACT'),'N') = 'Y' THEN
				OPEN C_opp_contact(p_source_object_id);
				FETCH C_opp_contact into l_contact_id;
				IF C_opp_contact%FOUND THEN
					l_counter := l_counter + 1;
					add_context_to_table(l_counter, l_contact_id, 'PARTY',
						 p_last_update_date, p_last_updated_by, p_last_update_login,
						 p_creation_date, p_created_by);
				END IF;
				CLOSE C_opp_contact;
			END IF;

			IF nvl(fnd_profile.value('AS_NOTES_OPP_CUSTOMER'),'N') = 'Y' THEN
				l_counter := l_counter + 1;
				add_context_to_table(l_counter, p_party_id, 'PARTY',
						 p_last_update_date, p_last_updated_by, p_last_update_login,
						 p_creation_date, p_created_by);
			END IF;
		ELSIF p_source_object_code = 'LEAD' THEN
			IF nvl(fnd_profile.value('AS_NOTES_LEAD_CONTACT'),'N') = 'Y' THEN
				OPEN C_lead_contact(p_source_object_id);
				FETCH C_lead_contact into l_contact_id;
				IF C_lead_contact%FOUND THEN
					l_counter := l_counter + 1;
					add_context_to_table(l_counter, l_contact_id, 'PARTY',
						 p_last_update_date, p_last_updated_by, p_last_update_login,
						 p_creation_date, p_created_by);
				END IF;
				CLOSE C_lead_contact;
			END IF;
			IF nvl(fnd_profile.value('AS_NOTES_LEAD_CUSTOMER'),'N') = 'Y' THEN
				l_counter := l_counter + 1;
				add_context_to_table(l_counter, p_party_id, 'PARTY',
						 p_last_update_date, p_last_updated_by, p_last_update_login,
						 p_creation_date, p_created_by);
			END IF;
		ELSIF p_source_object_code = 'PARTY' THEN
			OPEN c_subject_and_object(p_source_object_id);
			FETCH c_subject_and_object INTO l_subject_id, l_object_id;
			IF c_subject_and_object%FOUND THEN
				IF nvl(fnd_profile.value('AS_NOTES_REL_OBJECT'),'N') = 'Y' THEN
					l_counter := l_counter + 1;
					add_context_to_table(l_counter, l_object_id, 'PARTY',
							 p_last_update_date, p_last_updated_by, p_last_update_login,
							 p_creation_date, p_created_by);
				END IF;
				IF nvl(fnd_profile.value('AS_NOTES_REL_SUBJECT'),'N') = 'Y' THEN
					l_counter := l_counter + 1;
					add_context_to_table(l_counter, l_subject_id, 'PARTY',
							 p_last_update_date, p_last_updated_by, p_last_update_login,
							 p_creation_date, p_created_by);
				END IF;
			END IF;
			CLOSE c_subject_and_object;
		ELSIF p_source_object_code = 'TASK' THEN
			FOR l_task_ref_row in C_task_references(p_source_object_id) LOOP
				l_counter := l_counter + 1;
				add_context_to_table(l_counter, l_task_ref_row.object_id, l_task_ref_row.object_type_code,
						 p_last_update_date, p_last_updated_by, p_last_update_login,
						 p_creation_date, p_created_by);
			END LOOP;
		ELSIF p_source_object_code = 'IEX_ACCOUNT' THEN
			l_counter := l_counter + 1;
			add_context_to_table(l_counter, p_party_id, 'PARTY',
						 p_last_update_date, p_last_updated_by, p_last_update_login,
						 p_creation_date, p_created_by);
		ELSIF p_source_object_code = 'IEX_DELINQUENCY' THEN
			l_counter := l_counter + 1;
			add_context_to_table(l_counter, p_party_id, 'PARTY',
						 p_last_update_date, p_last_updated_by, p_last_update_login,
						 p_creation_date, p_created_by);

			OPEN C_del_account(p_source_object_id);
			FETCH C_del_account into l_cust_account_id;
			IF C_del_account%FOUND THEN
				l_counter := l_counter + 1;
				add_context_to_table(l_counter, l_cust_account_id, 'IEX_ACCOUNT',
						 p_last_update_date, p_last_updated_by, p_last_update_login,
						 p_creation_date, p_created_by);
			END IF;
			CLOSE C_del_account;
		END IF;

		JTF_NOTES_PUB.CREATE_NOTE(
			P_API_VERSION            => l_api_version,
			P_INIT_MSG_LIST          => l_init_msg_list,
			P_COMMIT                 => l_commit,
			P_JTF_NOTE_ID            => null,
			P_VALIDATION_LEVEL       => l_valid_level_full,
			P_SOURCE_OBJECT_ID       => p_source_object_id,
			P_SOURCE_OBJECT_CODE     => p_source_object_code,
			P_NOTES                  => p_notes,
			P_NOTES_DETAIL           => p_notes_detail,
			P_ENTERED_BY             => p_entered_by,
			P_ENTERED_DATE           => p_entered_date,
			P_LAST_UPDATE_DATE       => p_last_update_date,
			P_LAST_UPDATED_BY        => p_last_updated_by,
			P_CREATION_DATE          => p_creation_date,
			P_CREATED_BY             => p_created_by,
			P_LAST_UPDATE_LOGIN      => p_last_update_login,
			X_JTF_NOTE_ID            => x_jtf_note_id,
			P_NOTE_TYPE              => l_note_type,
			P_NOTE_STATUS            => l_note_status,
			X_RETURN_STATUS          => x_return_status,
			X_MSG_COUNT              => x_msg_count,
			X_MSG_DATA               => x_msg_data,
			P_JTF_NOTE_CONTEXTS_TAB  => g_jtf_note_contexts_tab
		 );

		IF x_return_status in ('E','U') THEN
			ROLLBACK;
			  RETURN;
		END IF;

	EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				RAISE;
	END create_note;

	PROCEDURE header_rec_set (
		p_last_update_date 		IN 	DATE,
		p_lead_id 			IN 	NUMBER,
		p_lead_number 			IN 	VARCHAR2,
		p_description 			IN 	VARCHAR2,
		p_status_code 			IN 	VARCHAR2,
		p_source_promotion_id	IN 	NUMBER,
		p_customer_id			IN 	NUMBER,
		p_address_id			IN 	NUMBER,
		p_sales_stage_id		IN 	NUMBER,
		p_win_probability		IN 	NUMBER,
		p_total_amount			IN 	NUMBER,
		--New parameter added for R12 forecast amount enhancement
		p_total_revenue_forecast_amt	  IN 	   NUMBER,
		p_channel_code 		IN 	VARCHAR2,
		p_decision_date 		IN 	DATE,
		p_currency_code 		IN 	VARCHAR2,
		p_vehicle_response_code  IN   VARCHAR2,
		p_customer_budget        IN   NUMBER,

		 --Code commented for R12 Enhancement --Start
		/* p_close_competitor_code 	IN 	VARCHAR2,
		p_close_competitor_id 	IN 	NUMBER,
		p_close_competitor 		IN 	VARCHAR2, */
		 --Code commented for R12 Enhancement --End

		p_close_comment 		IN 	VARCHAR2,
		p_parent_project 		IN 	VARCHAR2,
		p_freeze_flag 			IN 	VARCHAR2,
		header_rec 			IN  OUT NOCOPY AS_OPPORTUNITY_PUB.Header_Rec_type
	)
	AS
		l_num					NUMBER 		:= AS_FOUNDATION_PUB.Get_Constant('FND_API.G_MISS_NUM');
		l_char					VARCHAR2(1) 	:= AS_FOUNDATION_PUB.Get_Constant('FND_API.G_MISS_CHAR');
		l_date					DATE 		:= AS_FOUNDATION_PUB.Get_Constant('FND_API.G_MISS_DATE');
		l_last_update_date	DATE;
		 --Code commented for R12 Enhancement --Start
		--l_close_competitor       VARCHAR2(4000);
		 --Code commented for R12 Enhancement --End
		l_sales_methodology_id         NUMBER :=  fnd_profile.value('AS_SALES_METHODOLOGY');  --  Updated by Sumita for bug # 4100911

		CURSOR c_close_comp(p_close_party_id in number) IS
		SELECT party_name
		FROM hz_parties
		WHERE party_id = p_close_party_id;
	BEGIN

		--To be removed once we are able to pass p_close_competitor
		--Code modified for R12 enhancement --Start
		/* if p_close_competitor_id is not null then
			OPEN c_close_comp(p_close_competitor_id);
			FETCH c_close_comp into l_close_competitor;
			CLOSE c_close_comp;
		end if;  */
		--Code modified for R12 enhancement --end

		l_last_update_date 						:= NVL(p_last_update_date, l_date);
		header_rec.lead_id 						:= NVL(p_lead_id, l_num);
		header_rec.description 					:= NVL(p_description, l_char);
		header_rec.status_code 					:= NVL(p_status_code, l_char);
		header_rec.lead_number 					:= NVL(p_lead_number, l_char );
		header_rec.source_promotion_id 			:= NVL(p_source_promotion_id, l_num);
		header_rec.customer_id                     	:= NVL(p_customer_id, l_num);
		header_rec.address_id                      	:= NVL(p_address_id, l_num);
		header_rec.sales_stage_id                  	:= NVL(p_sales_stage_id, l_num);
		header_rec.win_probability                 	:= NVL(p_win_probability, l_num);
          -- need not set this either for creation nor updation..jraj 9/5/03.
		--header_rec.total_amount                    	:= NVL(p_total_amount, l_num);
		header_rec.channel_code                    	:= NVL(p_channel_code, l_char);
		header_rec.decision_date                   	:= NVL(p_decision_date, l_date);
		header_rec.currency_code                   	:= NVL(p_currency_code, l_char);
		header_rec.vehicle_response_code           	:= NVL(p_vehicle_response_code, l_char);
		header_rec.customer_budget           	     := NVL(p_customer_budget, l_num);
		header_rec.close_reason                    	:= null;
		--Code modified for R12 enhancement --Start
	/*	header_rec.close_competitor_code           	:= NVL(p_close_competitor_code, l_char);
		header_rec.close_competitor_id             	:= NVL(p_close_competitor_id, l_num);
		header_rec.close_competitor                	:= NVL(l_close_competitor, l_char); */
		--Code modified for R12 enhancement --end
		header_rec.close_comment                   	:= NVL(p_close_comment, l_char);
--		header_rec.end_user_customer_id            	:= null;
--		header_rec.end_user_address_id             	:= null;
--		header_rec.end_user_customer_name          	:= null;
		header_rec.parent_project                  	:= NVL(p_parent_project, l_char);

--		Updated by Sumita for bug # 4100911
		if  nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'),'N') = 'Y' and p_lead_id is NULL  then
		header_rec.sales_methodology_id            	 := NVL(l_sales_methodology_id,l_char);
		end if;

--		header_rec.sales_methodology_id            	:= null;
--		header_rec.offer_id                        	:= null;
		header_rec.last_update_date                	:= l_last_update_date;
--        header_rec.freeze_flag           	   		:= NVL(p_freeze_flag, l_char);
		/** commented by magesh the above one line for freeze flag for bug.3357959**/
--		header_rec.price_list_id               	    	:= null;

        header_rec.attribute_category           :=   FND_API.G_MISS_CHAR;
        header_rec.attribute1                   :=  FND_API.G_MISS_CHAR;
        header_rec.attribute2                   :=  FND_API.G_MISS_CHAR;
        header_rec.attribute3                   :=   FND_API.G_MISS_CHAR;
        header_rec.attribute4                   :=  FND_API.G_MISS_CHAR;
        header_rec.attribute5                   :=   FND_API.G_MISS_CHAR;
        header_rec.attribute6                   :=   FND_API.G_MISS_CHAR;
        header_rec.attribute7                   :=   FND_API.G_MISS_CHAR;
        header_rec.attribute8                   :=   FND_API.G_MISS_CHAR;
        header_rec.attribute9                   :=   FND_API.G_MISS_CHAR;
        header_rec.attribute10                  :=   FND_API.G_MISS_CHAR;
        header_rec.attribute11                  :=   FND_API.G_MISS_CHAR;
        header_rec.attribute12                  :=   FND_API.G_MISS_CHAR;
        header_rec.attribute13                  :=   FND_API.G_MISS_CHAR;
        header_rec.attribute14                  :=   FND_API.G_MISS_CHAR;
        header_rec.attribute15                  :=   FND_API.G_MISS_CHAR;
	--Code added for R12 Enhancement ---Start
	header_rec.TOTAL_REVENUE_OPP_FORECAST_AMT := NVL(p_total_revenue_forecast_amt, l_num);
	--Code added for R12 Enhancement ---End

	END header_rec_set;

	PROCEDURE create_opportunity (
		p_admin_flag			IN  VARCHAR2,
		p_admin_group_id		IN	NUMBER,
		p_resource_id			IN	NUMBER,
		p_last_update_date 		IN 	DATE,
		p_lead_id 			IN 	NUMBER,
		p_lead_number 			IN 	VARCHAR2,
		p_description 			IN 	VARCHAR2,
		p_status_code 			IN 	VARCHAR2,

	-- Added by Sumita on 10.14.2004 for bug # 3812865
		-- Adding source code as it is required while creating a lead if the profile OS: Source Code Required for Opportunity is set to 'yes' as we get the source
		-- code from the view defined for bali for marketing list but in case of personal node - contacts, list is generated from the universal search where we
		-- do not get the source code in the Bali.
		p_source_code       		IN	VARCHAR2,

		p_source_code_id       		IN	NUMBER,
        -- End Mod.
		p_customer_id			IN 	NUMBER,
		p_contact_party_id		IN 	NUMBER,
		p_address_id			IN 	NUMBER,
		p_sales_stage_id		IN 	NUMBER,
		p_win_probability		IN 	NUMBER,
		p_total_amount			IN 	NUMBER,
		p_total_revenue_forecast_amt	IN 	NUMBER,
		p_channel_code 		IN 	VARCHAR2,
		p_decision_date 		IN 	DATE,
		p_currency_code 		IN 	VARCHAR2,
		p_vehicle_response_code 	IN 	VARCHAR2,
		p_customer_budget 		IN 	NUMBER,

		 --Code commented for R12 Enhancement --Start
	/*	p_close_competitor_code 	IN 	VARCHAR2,
		p_close_competitor_id 	IN 	NUMBER,
		p_close_competitor 		IN 	VARCHAR2, */
		 --Code commented for R12 Enhancement --End

		p_close_comment 		IN 	VARCHAR2,
		p_parent_project 		IN 	VARCHAR2,
		p_freeze_flag 			IN 	VARCHAR2,
		p_salesgroup_id		IN	NUMBER,
		p_called_node		  	IN	VARCHAR2,
		p_action_key                        IN     VARCHAR2,
		x_return_status          OUT NOCOPY  VARCHAR2,
		x_msg_count              OUT NOCOPY  NUMBER,
		x_msg_data               OUT NOCOPY  VARCHAR2,
		x_lead_id                OUT NOCOPY  NUMBER
	)
	AS
		l_api_version             NUMBER := 2.0;
		l_valid_level_full        NUMBER := 100;
		l_address_id			NUMBER;
		l_address_profile		VARCHAR2(3) := FND_PROFILE.value('AST_WP_USE_ADDRESS_FOR_OPP');
		l_admin_flag  			VARCHAR2(1) := nvl(p_admin_flag, 'N');
		l_init_msg_list           VARCHAR2(5) := 'T';
		l_commit                  VARCHAR2(5) := 'T';
		header_rec           	 AS_OPPORTUNITY_PUB.Header_Rec_Type  := AS_API_RECORDS_PKG.get_p_header_rec;
		v_profile_tbl             AS_UTILITY_PUB.PROFILE_TBL_TYPE := AS_API_RECORDS_PKG.get_p_profile_tbl;
		l_vehicle_response_code   VARCHAR2(200) := nvl(p_vehicle_response_code, FND_PROFILE.value('AS_OPP_RESPONSE_CODE'));

	  -- Added by Sumita on 10.14.2004 for bug # 3812865
			l_source_promotion_id       NUMBER;
			l_action_key VARCHAR2(30) := p_action_key;
			s_source_code_id number;
         -- End Mod.

		l_count                   NUMBER;
		l_index                   NUMBER;
		my_message                VARCHAR2(1000);

		CURSOR 	c_get_primary_address_id IS
		SELECT 	party_site_id
		FROM 	hz_party_sites
		WHERE 	party_id = p_customer_id
		AND 	identifying_address_flag = 'Y'
		AND 	status = 'A';

		CURSOR 	c_get_address_id (x_party_id NUMBER, x_location_id NUMBER) IS
		SELECT 	party_site_id
		FROM 	ast_locations_v
		WHERE 	party_id = x_party_id
		AND		location_id = x_location_id;


	 -- Added by Sumita on 10.14.2004 for bug # 3812865
		-- Cursor c_source_prom_id is required for personal list - contact, so that source_code_id can be retrieved from source_code

		CURSOR c_source_prom_id (p_source_code VARCHAR2) IS
		SELECT source_code_id
		FROM Ams_source_codes
		WHERE source_code = p_source_code;

	 -- End Mod.
	/* Added for R12 */
	l_default_org_id   number;
	l_default_ou_name  varchar2(240);
	l_ou_count         number;
BEGIN
	l_address_id := p_address_id;

	if nvl(l_address_profile, 'N') = 'Y' then
		open c_get_primary_address_id;
		fetch c_get_primary_address_id into l_address_id;
		close c_get_primary_address_id;
	else
		IF p_customer_id IS NOT NULL AND p_address_id IS NOT NULL THEN
			OPEN c_get_address_id(p_customer_id, p_address_id);
			FETCH c_get_address_id INTO l_address_id;
			CLOSE c_get_address_id;
		END IF;
	end if;


    -- Added by Sumita on 10.14.2004 for bug # 3812865
		-- Cursor c_source_prom_id is required for personal list - contact, so that source_code_id can be retrieved from source_code
			 IF l_action_key = 'PLIST_CREATE_OPPORTUNITY' THEN
				IF p_source_code IS NOT NULL THEN
					OPEN c_source_prom_id(p_source_code);
					FETCH c_source_prom_id INTO l_source_promotion_id;
					CLOSE c_source_prom_id;
				END IF;
				s_source_code_id :=  l_source_promotion_id;
			ELSE
				s_source_code_id := p_source_code_id;
			END IF;
   -- End Mod.
	/* Added for R12 */
	MO_GLOBAL.INIT('AST');
	mo_utils.get_default_ou(l_default_org_id, l_default_ou_name, l_ou_count);
	header_rec.org_id := l_default_org_id;
	Header_Rec_Set(
		p_last_update_date,
		p_lead_id ,
		p_lead_number,
		p_description,
		p_status_code,
		s_source_code_id,
		p_customer_id,
		l_address_id,
		p_sales_stage_id,
		p_win_probability,
		p_total_amount,
		p_total_revenue_forecast_amt,
		p_channel_code,
		p_decision_date,
		p_currency_code,
		l_vehicle_response_code,
		p_customer_budget,
		 --Code commented for R12 Enhancement --Start
		/* p_close_competitor_code,
		p_close_competitor_id,
		p_close_competitor , */
		 --Code commented for R12 Enhancement --End
		p_close_comment,
		p_parent_project,
		p_freeze_flag ,
		header_rec
	);


	AS_OPPORTUNITY_PUB.Create_Opp_Header
	(
		p_api_version_number            => l_api_version,
		p_init_msg_list                 => l_init_msg_list,
		p_commit                        => l_commit,
		p_validation_level              => l_valid_level_full,
		p_header_rec                    => header_rec,
		p_check_access_flag             => 'N',
		p_admin_flag                    => l_admin_flag,
		p_admin_group_id                => p_admin_group_id,
		p_salesgroup_id          	  => p_salesgroup_id,
		p_identity_salesforce_id        => p_resource_id,
		p_profile_tbl                   => v_profile_tbl,
		p_partner_cont_party_id         => null,
		x_return_status                 => x_return_status,
		x_msg_count                     => x_msg_count,
		x_msg_data                      => x_msg_data,
		x_lead_id                       => x_lead_id
	);

	IF x_return_status IN ('E','U') THEN
		ROLLBACK;
		RETURN;
	END IF;

	IF p_contact_party_id IS NOT NULL THEN
	   ast_uwq_wrapper_pkg.create_contact(
			p_admin_flag			=> l_admin_flag,
			p_admin_group_id		=> p_admin_group_id,
			p_resource_id			=> p_resource_id,
			p_customer_id			=> p_customer_id,
			p_lead_id				=> x_lead_id,
			p_contact_party_id		=> p_contact_party_id,
			p_address_id			=> l_address_id,
			x_return_status         => x_return_status,
			x_msg_count             => x_msg_count,
			x_msg_data              => x_msg_data
		);

	END IF;

	EXCEPTION
		when OTHERS THEN
			ROLLBACK;
			RAISE;
	END create_opportunity;

	PROCEDURE create_lead (
		p_admin_group_id			IN	NUMBER,
		p_identity_salesforce_id		IN	NUMBER,
		p_status_code				IN	VARCHAR2,
		p_customer_id				IN	NUMBER,
		p_contact_party_id			IN	NUMBER,
		p_address_id				IN	NUMBER,
		p_admin_flag				IN	VARCHAR2,
		p_assign_to_salesforce_id   IN   NUMBER,
		p_assign_sales_group_id       IN   NUMBER,
		p_budget_status_code		IN	VARCHAR2,
		p_description				IN	VARCHAR2,

	-- Added by Sumita on 10.14.2004 for bug # 3812865
		-- Adding source code as it is required while creating a lead if the profile OS: Source Code Mandatory for Leads is set to 'yes' as we get the source
		-- code from the view defined for bali for marketing list but in case of personal node - contacts, list is generated from the universal search where we
		-- do not get the source code in the Bali.

		p_source_code       		IN	VARCHAR2,

		p_source_code_id       		IN	NUMBER,
        -- End Mod.
		p_lead_rank_id				IN	NUMBER,
		p_decision_timeframe_code	IN	VARCHAR2,
		p_initiating_contact_id		IN	NUMBER,
		p_phone_id					IN	NUMBER,
		p_called_node			  	IN	VARCHAR2,
		--sumita
		p_action_key                                 IN    VARCHAR2,

		x_sales_lead_id           OUT NOCOPY NUMBER,
		x_return_status           OUT NOCOPY VARCHAR2,
		x_msg_count               OUT NOCOPY NUMBER,
		x_msg_data                OUT NOCOPY VARCHAR2
	)
	AS
		l_last_update_date		    DATE;
		l_address_id				NUMBER;
		l_access_id					NUMBER;
		v_access_id					NUMBER;
		l_api_version             	NUMBER := 2.0;
		l_assign_to_person_id		NUMBER;
		l_assign_to_salesforce_id	NUMBER;
		l_assign_sales_group_id		NUMBER;
		l_validation_level       	NUMBER 		:=  NVL(FND_PROFILE.VALUE('AST_SL_DEBUG_VALID_LEVEL'),0);
		l_org_contact_id 			NUMBER;
		l_phone_id					NUMBER 		:= null;
		l_admin_flag  				VARCHAR2(1) := nvl(p_admin_flag, 'N');
		l_address_profile			VARCHAR2(3) := FND_PROFILE.value('AST_WP_USE_ADDRESS_FOR_LEAD');
		l_init_msg_list           	VARCHAR2(5) 	:= 'T';
		l_commit                  	VARCHAR2(5) 	:= 'F';
		l_channel_code				VARCHAR2(30) 	:= FND_PROFILE.VALUE('AS_DEFAULT_LEAD_CHANNEL');
		l_vehicle_response_code		VARCHAR2(30) 	:= FND_PROFILE.VALUE('AS_DEFAULT_LEAD_VEHICLE_RESPONSE_CODE');
		l_contact_role_code			VARCHAR2(30) 	:= FND_PROFILE.VALUE('AS_DEFAULT_CONTACT_ROLE');
		l_full_name					VARCHAR2(240);

		-- Added by Sumita on 10.14.2004 for bug # 3812865
		l_source_promotion_id       NUMBER;
		 -- End Mod.

		l_sales_lead_profile_tbl 	AS_UTILITY_PUB.profile_tbl_type;
		l_sales_lead_line_tbl 		AS_SALES_LEADS_PUB.sales_lead_line_tbl_type;
		l_sales_lead_rec 			AS_SALES_LEADS_PUB.sales_lead_rec_type;
		l_sales_lead_contact_tbl 	AS_SALES_LEADS_PUB.sales_lead_contact_tbl_type;
		l_sales_lead_contact_rec 	AS_SALES_LEADS_PUB.sales_lead_contact_rec_type;
		l_sales_lead_line_out_tbl	AS_SALES_LEADS_PUB.sales_lead_line_out_tbl_type;
		l_sales_lead_contact_out_tbl  AS_SALES_LEADS_PUB.sales_lead_cnt_out_tbl_type;
		G_Access_Rec_Type 			AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
		l_salesteam_rec  			as_access_pub.sales_team_rec_type:=as_api_records_pkg.get_p_sales_team_rec;

		-- Added by Sumita on 10.14.2004 for bug # 3812865
		l_action_key          varchar2(100) := p_action_key;
		-- End Mod.

		l_count                   NUMBER;
		l_index                   NUMBER;
		my_message                VARCHAR2(1000);


		CURSOR c_get_org_contact_id(X_PARTY_ID NUMBER) IS
		SELECT o.org_contact_id
		FROM   hz_relationships r,
		hz_org_contacts o
		WHERE  o.party_relationship_id = r.relationship_id
		AND    r.party_id = X_PARTY_ID
		AND    r.directional_flag = 'F';

		CURSOR c_phone_id(x_owner_table_id number) IS
		SELECT contact_point_id
		FROM hz_contact_points
		WHERE owner_table_id = x_owner_table_id
		and owner_table_name = 'HZ_PARTIES'
		and contact_point_type = 'PHONE'
		and primary_flag = 'Y';

		CURSOR C_GET_LEAD_NUMBER(p_sales_lead_id number) IS
		SELECT LEAD_NUMBER FROM AS_SALES_LEADS
		WHERE SALES_LEAD_ID = p_sales_lead_id;

		CURSOR C_RESOURCE(p_resource_id NUMBER) IS
		SELECT SOURCE_NAME, SOURCE_ID
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_resource_id;

		CURSOR 	c_get_primary_address_id IS
		SELECT 	party_site_id
		FROM 	hz_party_sites
		WHERE 	party_id = p_customer_id
		AND 	identifying_address_flag = 'Y'
		AND 	status = 'A';

		CURSOR 	c_get_address_id (x_party_id NUMBER, x_location_id NUMBER) IS
		SELECT 	party_site_id
		FROM 	ast_locations_v
		WHERE 	party_id = x_party_id
		AND		location_id = x_location_id;


	  -- Added by Sumita on 10.14.2004 for bug # 3812865
		-- Cursor c_source_prom_id is required for personal list - contact, so that source_code_id can be retrieved from source_code

		 CURSOR c_source_prom_id (p_source_code VARCHAR2) IS
	         SELECT source_code_id
		 FROM Ams_source_codes
                 WHERE source_code = p_source_code;

         -- End Mod.

	/**
		CURSOR 	c_get_access_id (x_sales_lead_id NUMBER) IS
		SELECT 	access_id, last_update_datE
		FROM 	as_accesses_all
		WHERE 	sales_lead_id = x_sales_lead_id;
	**/
	BEGIN
		IF (p_assign_to_salesforce_id IS NOT NULL) THEN
			OPEN c_resource(p_assign_to_salesforce_id);
			FETCH c_resource into l_full_name, l_assign_to_person_id;
			CLOSE c_resource;
		END IF;

		IF l_admin_flag = 'N' THEN
			l_assign_sales_group_id := p_assign_sales_group_id;
		END IF;

		l_address_id := p_address_id;
		IF nvl(l_address_profile, 'N') = 'Y' THEN
			OPEN c_get_primary_address_id;
			FETCH c_get_primary_address_id INTO l_address_id;
			CLOSE c_get_primary_address_id;
		ELSE
			IF p_customer_id IS NOT NULL AND p_address_id IS NOT NULL THEN
				OPEN c_get_address_id(p_customer_id, p_address_id);
				FETCH c_get_address_id INTO l_address_id;
				CLOSE c_get_address_id;
			END IF;
		END IF;


	 -- Added by Sumita on 10.14.2004 for bug # 3812865
		-- Cursor c_source_prom_id is required for personal list - contact, so that source_prom_id can be retrieved from source_code

		IF l_action_key = 'PLIST_CREATE_LEAD' THEN
			 IF p_source_code IS NOT NULL THEN
				OPEN c_source_prom_id(p_source_code);
				FETCH c_source_prom_id INTO l_source_promotion_id;
				CLOSE c_source_prom_id;
			END IF;
		END IF;

        -- End Mod.

		l_sales_lead_rec.status_code              := p_status_code;
		l_sales_lead_rec.customer_id              := p_customer_id;

		l_sales_lead_rec.address_id               := l_address_id;
		l_sales_lead_rec.assign_to_person_id      := l_assign_to_person_id;
		l_sales_lead_rec.assign_to_salesforce_id  := p_assign_to_salesforce_id;
		l_sales_lead_rec.assign_sales_group_id    := l_assign_sales_group_id;
		l_sales_lead_rec.channel_code             := l_channel_code;
		l_sales_lead_rec.close_reason	           := null;
		l_sales_lead_rec.reject_reason_code       := null;
		l_sales_lead_rec.budget_amount            := null;
		l_sales_lead_rec.budget_status_code       := p_budget_status_code;
		l_sales_lead_rec.currency_code            := null;
		l_sales_lead_rec.decision_timeframe_code  := p_decision_timeframe_code;
		l_sales_lead_rec.description              := p_description;


	  -- Added by Sumita on 10.14.2004 for bug # 3812865
		-- If condition is added so that if lead is created from the personal list - contacts, l_sales_lead_rec will store source_promotion_id from the
		-- cursor else it will get the value from the view directly
			IF l_action_key = 'PLIST_CREATE_LEAD' THEN
				l_sales_lead_rec.source_promotion_id      := l_source_promotion_id;
			ELSE
				l_sales_lead_rec.source_promotion_id      := p_source_code_id;
			END IF;
          -- End Mod.

		l_sales_lead_rec.offer_id                 := null;
		l_sales_lead_rec.parent_project           := null;
		l_sales_lead_rec.lead_rank_id             := p_lead_rank_id;
		l_sales_lead_rec.initiating_contact_id    := p_initiating_contact_id;	--check
		l_sales_lead_rec.urgent_flag              := null;
		l_sales_lead_rec.accept_flag              := null;
		l_sales_lead_rec.qualified_flag           := null;
		l_sales_lead_rec.vehicle_response_code    := l_vehicle_response_code;	--check

		l_sales_lead_contact_rec.enabled_flag := 'Y';
		l_sales_lead_contact_rec.customer_id := p_customer_id;
		l_sales_lead_contact_rec.address_id := l_address_id;

		IF l_sales_lead_contact_rec.contact_id is null and l_sales_lead_contact_rec.contact_party_id IS NOT NULL THEN
			Open c_get_org_contact_id(l_sales_lead_contact_rec.contact_party_id);
			FETCH c_get_org_contact_id into l_org_contact_id;
			if c_get_org_contact_id%FOUND THEN
				l_sales_lead_contact_rec.contact_id := l_org_contact_id;
			END IF;
			CLOSE c_get_org_contact_id;
		END IF;

		l_sales_lead_contact_rec.primary_contact_flag := 'Y';
		l_sales_lead_contact_rec.contact_party_id := p_contact_party_id;
		l_sales_lead_contact_rec.contact_role_code := l_contact_role_code;
		l_sales_lead_contact_rec.phone_id := p_phone_id;

		if l_sales_lead_contact_rec.phone_id is null and l_sales_lead_contact_rec.contact_party_id IS NOT NULL THEN
			Open c_phone_id(l_sales_lead_contact_rec.contact_party_id);
			FETCH c_phone_id into l_phone_id;
			if c_phone_id%FOUND THEN
				l_sales_lead_contact_rec.phone_id := l_phone_id;
			END IF;
			CLOSE c_phone_id;
		END IF;

		l_sales_lead_contact_rec.primary_contact_flag := 'Y';

		if (l_sales_lead_contact_rec.contact_party_id IS NOT NULL) THEN
			l_sales_lead_contact_tbl(1) := l_sales_lead_contact_rec;
		END IF;

		G_Access_Rec_Type.cust_access_profile_value  :=  nvl(FND_PROFILE.VALUE('AS_CUST_ACCESS'),'F');
		G_Access_Rec_Type.lead_access_profile_value  :=  nvl(FND_PROFILE.VALUE('AS_LEAD_ACCESS'),'F');
		G_Access_Rec_Type.opp_access_profile_value   :=  nvl(FND_PROFILE.VALUE('AS_OPP_ACCESS'),'F');
		G_Access_Rec_Type.mgr_update_profile_value   :=  nvl(FND_PROFILE.VALUE('AS_MGR_UPDATE'),'R');
		G_Access_Rec_Type.admin_update_profile_value :=  nvl(FND_PROFILE.VALUE('AS_ADMIN_UPDATE'),'R');

		l_sales_lead_profile_tbl(1).profile_name := 'AS_CUST_ACCESS';
		l_sales_lead_profile_tbl(1).profile_value := G_access_rec_type.cust_access_profile_value;
		l_sales_lead_profile_tbl(2).profile_name := 'AS_LEAD_ACCESS';
		l_sales_lead_profile_tbl(2).profile_value := G_access_rec_type.lead_access_profile_value;
		l_sales_lead_profile_tbl(3).profile_name := 'AS_OPP_ACCESS';
		l_sales_lead_profile_tbl(3).profile_value := G_access_rec_type.opp_access_profile_value;
		l_sales_lead_profile_tbl(4).profile_name := 'AS_MGR_UPDATE';
		l_sales_lead_profile_tbl(4).profile_value := G_access_rec_type.mgr_update_profile_value;
		l_sales_lead_profile_tbl(5).profile_name := 'AS_ADMIN_UPDATE';
		l_sales_lead_profile_tbl(5).profile_value := G_access_rec_type.admin_update_profile_value;

		AS_SALES_LEADS_PUB.create_sales_lead(
			 P_API_VERSION_NUMBER     => l_api_version
			,P_INIT_MSG_LIST          => l_init_msg_list
			,P_COMMIT                 => l_commit
			,P_VALIDATION_LEVEL       => l_validation_level
			,P_CHECK_ACCESS_FLAG      => 'N'
			,P_ADMIN_FLAG             => l_admin_flag
			,P_ADMIN_GROUP_ID         => p_admin_group_id
			,P_IDENTITY_SALESFORCE_ID => p_identity_salesforce_id
			,P_SALES_LEAD_PROFILE_TBL => l_sales_lead_profile_tbl
			,P_SALES_LEAD_REC         => l_sales_lead_rec
			,P_SALES_LEAD_LINE_TBL    => l_sales_lead_line_tbl
			,P_SALES_LEAD_CONTACT_TBL => l_sales_lead_contact_tbl
			,X_SALES_LEAD_ID          => x_sales_lead_id
			,X_RETURN_STATUS          => x_return_status
			,X_MSG_COUNT              => x_msg_count
			,X_MSG_DATA               => x_msg_data
			,X_SALES_LEAD_LINE_OUT_TBL=> l_sales_lead_line_out_tbl
			,X_SALES_LEAD_CNT_OUT_TBL => l_sales_lead_contact_out_tbl
		 );

		 IF x_return_status in ('E','U') THEN
			ROLLBACK;
		  	RETURN;
		END IF;

		/** Commenting out following lines.  Keep Flag (freeze_flag) should
		 be set to 'Y'.
			When we create a sales lead it is set to 'Y' by default.  To follow 11.5.7 logic freeze_flag was
			    explicitely set to 'N'. Now for the later releases we just have to comment out this
				part. **/

/**
		OPEN c_get_access_id (x_sales_lead_id);
		FETCH c_get_access_id INTO l_access_id, l_last_update_date;
		CLOSE c_get_access_id;

		--Updating SalesTeam to set Keep Flag (freeze_flag) to 'N'

		l_salesteam_rec.access_id          := l_access_id;
		l_salesteam_rec.sales_group_id 	   := l_assign_sales_group_id;
		l_salesteam_rec.freeze_flag        := 'N';
--		l_salesteam_rec.last_update_date   := sysdate;
		l_salesteam_rec.last_update_date   := l_last_update_date;
		l_salesteam_rec.customer_id 	   := p_customer_id;
		l_salesteam_rec.sales_lead_id 	   := x_sales_lead_id;
		l_salesteam_rec.salesforce_id 	   := p_assign_to_salesforce_id;
		l_salesteam_rec.person_id 		   := l_assign_to_person_id;
		l_salesteam_rec.address_id 		   := p_address_id;

		AS_ACCESS_PUB.Update_SalesTeam
		(
			p_api_version_number 	   => l_api_version,
			p_init_msg_list      	   => l_init_msg_list,
			p_commit             	   => l_commit,
			p_validation_level   	   => l_validation_level,
			p_access_profile_rec 	   => G_Access_Rec_Type,
			p_check_access_flag  	   => 'Y',
			p_admin_flag         	   => l_admin_flag,
			p_admin_group_id     	   => p_admin_group_id,
			p_identity_salesforce_id   => p_identity_salesforce_id,
			p_sales_team_rec       	   => l_salesteam_rec,
			x_return_status      	   => x_return_status,
			x_msg_count          	   => x_msg_count,
			x_msg_data           	   => x_msg_data,
			x_access_id          	   => v_access_id
		);

		IF x_return_status <> 'S' THEN
			ROLLBACK;
		 	RETURN;
		END IF;
**/
	/** Adding this to fix bug 2918647.  We should call Lead_Process_After_Create
	    after create_sales_lead.
	**/
	AS_SALES_LEADS_PUB.Lead_Process_After_Create(
		 P_Api_Version_Number      => l_api_version
		,P_Init_Msg_List           => l_init_msg_list
		,P_Commit                  => l_commit
		,P_Validation_Level        => l_validation_level
		,P_check_access_flag       => 'N'
		,P_admin_flag              => l_admin_flag
		,P_Admin_Group_Id          => p_admin_group_id
		,P_identity_salesforce_id  => p_identity_salesforce_id
		,P_SalesGroup_Id       => l_assign_sales_group_id
		,P_Sales_Lead_Id           => x_sales_lead_id
		,X_Return_Status           => x_return_status
		,X_Msg_Count               => x_msg_count
		,X_Msg_Data                => x_msg_data
		);

    if x_return_status not in ('W','S') then
			rollback;
			return;
	end if;

	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			RAISE;
	END create_lead;

     PROCEDURE update_lead (
          p_sales_lead_id               IN   NUMBER    := FND_API.G_MISS_NUM,
          p_admin_group_id              IN   NUMBER    := FND_API.G_MISS_NUM,
          p_identity_salesforce_id      IN   NUMBER    := FND_API.G_MISS_NUM,
		p_last_update_date            IN      DATE,
          p_status_code                 IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_customer_id                 IN   NUMBER    := FND_API.G_MISS_NUM,
          p_address_id                  IN   NUMBER    := FND_API.G_MISS_NUM,
          p_assign_to_salesforce_id     IN   NUMBER    := FND_API.G_MISS_NUM,
          p_admin_flag                  IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_assign_sales_group_id       IN   NUMBER    := FND_API.G_MISS_NUM,
          p_budget_status_code          IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_description                 IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_source_promotion_id         IN   NUMBER    := FND_API.G_MISS_NUM,
          p_lead_rank_id                IN   NUMBER    := FND_API.G_MISS_NUM,
          p_decision_timeframe_code     IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_initiating_contact_id       IN   NUMBER    := FND_API.G_MISS_NUM,
          p_accept_flag                 IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_qualified_flag              IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_phone_id                    IN   NUMBER    := FND_API.G_MISS_NUM,
          p_close_reason_code           IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          p_called_node                 IN   VARCHAR2  := FND_API.G_MISS_CHAR,
          x_return_status           OUT NOCOPY VARCHAR2,
          x_msg_count               OUT NOCOPY NUMBER,
          x_msg_data                OUT NOCOPY VARCHAR2
     )
	IS
		l_api_version             	NUMBER := 2.0;
		l_validation_level       	NUMBER :=  NVL(FND_PROFILE.VALUE('AST_SL_DEBUG_VALID_LEVEL'),0);
		l_assign_sales_group_id 		NUMBER;
		l_assign_to_person_id		NUMBER;
		l_admin_flag  				  VARCHAR2(1) := nvl(p_admin_flag, 'N');
		l_init_msg_list           	VARCHAR2(5) := 'T';
		l_commit                  	VARCHAR2(5) := 'T';
		l_channel_code              	VARCHAR2(30) := FND_PROFILE.VALUE('AS_DEFAULT_LEAD_CHANNEL');
		l_vehicle_response_code     	VARCHAR2(30) := FND_PROFILE.VALUE('AS_DEFAULT_LEAD_VEHICLE_RESPONSE_CODE');
		l_sales_lead_profile_tbl 	AS_UTILITY_PUB.profile_tbl_type;
		l_sales_lead_line_tbl 		AS_SALES_LEADS_PUB.sales_lead_line_tbl_type;
		l_sales_lead_rec 			AS_SALES_LEADS_PUB.sales_lead_rec_type := AS_API_RECORDS_PKG.get_p_sales_lead_rec;
		l_sales_lead_contact_tbl 	AS_SALES_LEADS_PUB.sales_lead_contact_tbl_type;
		l_sales_lead_line_out_tbl	AS_SALES_LEADS_PUB.sales_lead_line_out_tbl_type;

		G_Access_Rec_Type 			AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;

		l_count                   NUMBER;
		l_index                   NUMBER;
		my_message                VARCHAR2(1000);

		CURSOR C_RESOURCE(p_resource_id NUMBER) is
		SELECT SOURCE_ID
		FROM JTF_RS_RESOURCE_EXTNS
		WHERE RESOURCE_ID = p_resource_id;
	BEGIN


		IF (p_assign_to_salesforce_id IS NOT NULL) THEN
		    OPEN c_resource(p_assign_to_salesforce_id);
		    FETCH c_resource into l_assign_to_person_id;
		    CLOSE c_resource;
		END IF;


		IF l_admin_flag = 'N' THEN
			l_assign_sales_group_id := p_assign_sales_group_id;
		END IF;

		l_sales_lead_rec.sales_lead_id            := p_sales_lead_id;
		l_sales_lead_rec.status_code              := p_status_code;
		l_sales_lead_rec.customer_id              := p_customer_id;
--		l_sales_lead_rec.address_id               := p_address_id;
		l_sales_lead_rec.last_update_date         := p_last_update_date;
		l_sales_lead_rec.assign_to_person_id      := l_assign_to_person_id;
		l_sales_lead_rec.assign_to_salesforce_id  := p_assign_to_salesforce_id;
		l_sales_lead_rec.assign_sales_group_id    := l_assign_sales_group_id;
--		l_sales_lead_rec.channel_code             := l_channel_code;
    		l_sales_lead_rec.close_reason	           := p_close_reason_code;
--    l_sales_lead_rec.reject_reason_code       := p_reject_reason_code;
--    l_sales_lead_rec.budget_amount            := p_budget_amount;
	    l_sales_lead_rec.budget_status_code       := p_budget_status_code;
--    l_sales_lead_rec.currency_code            := p_currency_code;
	    l_sales_lead_rec.decision_timeframe_code  := p_decision_timeframe_code;
	    l_sales_lead_rec.description              := p_description;
--	    l_sales_lead_rec.source_promotion_id      := p_source_promotion_id;
--    l_sales_lead_rec.offer_id                 := p_offer_id;
--    l_sales_lead_rec.parent_project           := p_parent_project;
	    l_sales_lead_rec.lead_rank_id             := p_lead_rank_id;
	    l_sales_lead_rec.initiating_contact_id    := p_initiating_contact_id;	--
--    l_sales_lead_rec.urgent_flag              := p_urgent_flag;
	    l_sales_lead_rec.accept_flag              := p_accept_flag;
	    l_sales_lead_rec.qualified_flag           := p_qualified_flag;
--	    l_sales_lead_rec.vehicle_response_code    := l_vehicle_response_code;

		G_Access_Rec_Type.cust_access_profile_value  :=  nvl(FND_PROFILE.VALUE('AS_CUST_ACCESS'),'F');
		G_Access_Rec_Type.lead_access_profile_value  :=  nvl(FND_PROFILE.VALUE('AS_LEAD_ACCESS'),'F');
		G_Access_Rec_Type.opp_access_profile_value   :=  nvl(FND_PROFILE.VALUE('AS_OPP_ACCESS'),'F');
		G_Access_Rec_Type.mgr_update_profile_value   :=  nvl(FND_PROFILE.VALUE('AS_MGR_UPDATE'),'R');
		G_Access_Rec_Type.admin_update_profile_value :=  nvl(FND_PROFILE.VALUE('AS_ADMIN_UPDATE'),'R');

	l_sales_lead_profile_tbl(1).profile_name := 'AS_CUST_ACCESS';
	l_sales_lead_profile_tbl(1).profile_value := G_access_rec_type.cust_access_profile_value;
	l_sales_lead_profile_tbl(2).profile_name := 'AS_LEAD_ACCESS';
	l_sales_lead_profile_tbl(2).profile_value := G_access_rec_type.lead_access_profile_value;
	l_sales_lead_profile_tbl(3).profile_name := 'AS_OPP_ACCESS';
	l_sales_lead_profile_tbl(3).profile_value := G_access_rec_type.opp_access_profile_value;
	l_sales_lead_profile_tbl(4).profile_name := 'AS_MGR_UPDATE';
	l_sales_lead_profile_tbl(4).profile_value := G_access_rec_type.mgr_update_profile_value;
	l_sales_lead_profile_tbl(5).profile_name := 'AS_ADMIN_UPDATE';
	l_sales_lead_profile_tbl(5).profile_value := G_access_rec_type.admin_update_profile_value;

     AS_SALES_LEADS_PUB.update_sales_lead(
           P_API_VERSION_NUMBER     => l_api_version
          ,P_INIT_MSG_LIST          => l_init_msg_list
          ,P_COMMIT                 => l_commit
          ,P_VALIDATION_LEVEL       => l_validation_level
          ,P_CHECK_ACCESS_FLAG      => 'N'
          ,P_ADMIN_FLAG             => l_admin_flag
          ,P_ADMIN_GROUP_ID         => p_admin_group_id
          ,P_IDENTITY_SALESFORCE_ID => p_identity_salesforce_id
          ,P_SALES_LEAD_PROFILE_TBL => l_sales_lead_profile_tbl
          ,P_SALES_LEAD_REC         => l_sales_lead_rec
          ,X_RETURN_STATUS          => x_return_status
          ,X_MSG_COUNT              => x_msg_count
          ,X_MSG_DATA               => x_msg_data
      );

      if x_return_status in ('E','U') THEN
          rollback;
		RETURN;
     END IF;

	/** Adding this to fix bug 2918647.  We should call Lead_Process_After_Update
	    after update_sales_lead.
	**/
	AS_SALES_LEADS_PUB.Lead_Process_After_Update(
		 P_Api_Version_Number      => l_api_version
		,P_Init_Msg_List           => l_init_msg_list
		,P_Commit                  => l_commit
		,P_Validation_Level        => l_validation_level
		,P_check_access_flag       => 'N'
		,P_admin_flag              => l_admin_flag
		,P_Admin_Group_Id          => p_admin_group_id
		,P_identity_salesforce_id  => p_identity_salesforce_id
		,P_SalesGroup_Id       => l_assign_sales_group_id
		,P_Sales_Lead_Id           => p_sales_lead_id
		,X_Return_Status           => x_return_status
		,X_Msg_Count               => x_msg_count
		,X_Msg_Data                => x_msg_data
		);

    if x_return_status not in ('W','S') then
			rollback;
			return;
	end if;

	exception
			  when OTHERS THEN
			  	   rollback;
				   RAISE;
END;

	PROCEDURE create_opp_for_lead (
		p_admin_flag	 	IN	  VARCHAR2,
		p_sales_lead_id		IN	NUMBER,
		p_resource_id		IN	NUMBER,
		p_salesgroup_id		IN	NUMBER,
		p_called_node		IN	VARCHAR2,
		x_app_launch	 OUT NOCOPY VARCHAR2,
		x_return_status     OUT NOCOPY  VARCHAR2,
		x_msg_count         OUT NOCOPY  NUMBER,
		x_msg_data          OUT NOCOPY  VARCHAR2,
		x_opportunity_id    OUT NOCOPY NUMBER
	)
	as
		l_api_version             	NUMBER := 2.0;
		l_admin_flag  				  VARCHAR2(1) := nvl(p_admin_flag, 'N');
		l_init_msg_list           	VARCHAR2(5) := 'T';
		l_commit                  	VARCHAR2(5) := 'T';
		l_validation_level        	NUMBER :=  NVL(FND_PROFILE.VALUE('AST_SL_DEBUG_VALID_LEVEL'),0);
		l_opp_status        		VARCHAR2(30) := nvl(FND_PROFILE.value('AS_OPP_STATUS'), null);
		l_query_string 				varchar2(200);
		l_Sales_Lead_Profile_Tbl 	AS_UTILITY_PUB.Profile_Tbl_Type;
		G_Access_Rec_Type 			AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;

		l_count                   NUMBER;
		l_index                   NUMBER;
		my_message                VARCHAR2(1000);
	BEGIN
	  /*
	  	Check if there are any potential matching opportunities.
		If No, call create_opportunity_for_lead else
		launch ASTSLTOP
	  */
	x_app_launch := 'N';
	l_query_string := null;
	get_potential_opportunity (p_sales_lead_id, l_admin_flag, null, p_resource_id, l_query_string);

	if l_query_string is not null then
		x_return_status := 'S';
		x_app_launch := 'Y';
		return;
	else
		x_app_launch := 'N';
	end if;

	G_Access_Rec_Type.cust_access_profile_value  :=  nvl(FND_PROFILE.VALUE('AS_CUST_ACCESS'),'F');
	G_Access_Rec_Type.lead_access_profile_value  :=  nvl(FND_PROFILE.VALUE('AS_LEAD_ACCESS'),'F');
	G_Access_Rec_Type.opp_access_profile_value   :=  nvl(FND_PROFILE.VALUE('AS_OPP_ACCESS'),'F');
	G_Access_Rec_Type.mgr_update_profile_value   :=  nvl(FND_PROFILE.VALUE('AS_MGR_UPDATE'),'R');
	G_Access_Rec_Type.admin_update_profile_value :=  nvl(FND_PROFILE.VALUE('AS_ADMIN_UPDATE'),'R');

		l_sales_lead_profile_tbl(1).profile_name := 'AS_CUST_ACCESS';
		l_sales_lead_profile_tbl(1).profile_value := G_access_rec_type.cust_access_profile_value;
		l_sales_lead_profile_tbl(2).profile_name := 'AS_LEAD_ACCESS';
		l_sales_lead_profile_tbl(2).profile_value := G_access_rec_type.lead_access_profile_value;
		l_sales_lead_profile_tbl(3).profile_name := 'AS_OPP_ACCESS';
		l_sales_lead_profile_tbl(3).profile_value := G_access_rec_type.opp_access_profile_value;
		l_sales_lead_profile_tbl(4).profile_name := 'AS_MGR_UPDATE';
		l_sales_lead_profile_tbl(4).profile_value := G_access_rec_type.mgr_update_profile_value;
		l_sales_lead_profile_tbl(5).profile_name := 'AS_ADMIN_UPDATE';
		l_sales_lead_profile_tbl(5).profile_value := G_access_rec_type.admin_update_profile_value;

		AS_SALES_LEADS_PUB.Create_Opportunity_For_Lead(
			p_api_version_NUMBER     => l_api_version
			,p_init_msg_list          => l_init_msg_list
			,p_commit                 => l_commit
			,p_validation_level       => l_validation_level
			,P_Check_Access_Flag      => 'Y'
			,P_Admin_Flag             => l_admin_flag
			,P_Admin_Group_Id         => null
			,P_identity_salesforce_id => p_resource_id
			,P_identity_salesgroup_id => p_salesgroup_id
			,P_Sales_Lead_Profile_Tbl => l_Sales_Lead_Profile_Tbl
			,P_SALES_LEAD_ID          => p_sales_lead_id
			,P_Opp_Status             => l_opp_status
			,x_return_status          => x_return_status
			,x_msg_count              => x_msg_count
			,x_msg_data               => x_msg_data
			,x_opportunity_id         => x_opportunity_id
		);

		if x_return_status in ('E','U') THEN
			rollback;
			RETURN;
		END IF;

	exception
			  when OTHERS THEN
			  	   rollback;
				   RAISE;
	end create_opp_for_lead;

	PROCEDURE reassign_lead (
		p_admin_flag			IN	VARCHAR2,
		p_admin_group_id		IN	NUMBER,
		p_default_group_id		IN	NUMBER,
		p_person_id				IN	NUMBER,	 --global.ast_person_id
		p_resource_id			IN	NUMBER,
		p_sales_lead_id			IN	NUMBER,
		p_new_salesforce_id		IN	NUMBER,
		p_last_update_date      IN  DATE,
		p_new_sales_group_id	IN	NUMBER,
		p_new_owner_id			IN	NUMBER,	--person_id of new owner
		p_called_node			IN	VARCHAR2,
		x_return_status      OUT NOCOPY  VARCHAR2,
		x_msg_count          OUT NOCOPY  NUMBER,
		x_msg_data           OUT NOCOPY  VARCHAR2
	)
	as
		l_old_access_id		 NUMBER; --remove
		l_api_version             NUMBER := 2.0;
		l_access_flag 			  VARCHAR2(1);
		l_admin_flag  			VARCHAR2(1) := nvl(p_admin_flag, 'N');
		l_init_msg_list           VARCHAR2(5) := 'T';
		l_commit                  VARCHAR2(5) := 'T';
		l_message_name 			  VARCHAR2(100);
		l_validation_level    	  CONSTANT NUMBER := NVL(FND_PROFILE.VALUE('AST_SL_DEBUG_VALID_LEVEL'),0);
		G_Access_Rec_Type 			AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;

		l_count                   NUMBER;
		l_index                   NUMBER;
		my_message                VARCHAR2(1000);
	BEGIN
	/** Check if the user has access to change owner **/
	/**
	    Commenting out the validation part as this is being done in the calling procedure.
	    Procedure LLIST_REASSIGN_LEAD in astulacb.pls
	**/
	/**
	l_message_name := 'AST_NO_LEAD_OWNR_CHANGE_ACCESS';
	l_access_flag := nvl(fnd_profile.value('AS_ALLOW_CHANGE_LEAD_OWNER'),'N');

	if (l_access_flag <> 'Y') then
		if (p_sales_lead_id is not null) then
			G_Access_Rec_Type.cust_access_profile_value  :=  nvl(FND_PROFILE.VALUE('AS_CUST_ACCESS'),'F');
			G_Access_Rec_Type.lead_access_profile_value  :=  nvl(FND_PROFILE.VALUE('AS_LEAD_ACCESS'),'F');
			G_Access_Rec_Type.opp_access_profile_value   :=  nvl(FND_PROFILE.VALUE('AS_OPP_ACCESS'),'F');
			G_Access_Rec_Type.mgr_update_profile_value   :=  nvl(FND_PROFILE.VALUE('AS_MGR_UPDATE'),'R');
				G_Access_Rec_Type.admin_update_profile_value :=  nvl(FND_PROFILE.VALUE('AS_ADMIN_UPDATE'),'R');

			AS_ACCESS_PVT.has_LeadOwnerAccess(
				p_api_version_Number     => 2.0,
				p_init_msg_list          => 'N',
				p_validation_level  => 100,
				p_access_profile_rec     => G_Access_Rec_Type,
				p_admin_flag        => p_admin_flag,
				p_admin_group_id    => p_admin_group_id,
				p_person_id         => p_person_id,
				p_sales_lead_id          => p_sales_lead_Id,
				p_check_access_flag => 'Y',
				p_identity_salesforce_id => p_resource_id,
				p_partner_cont_party_id => NULL,
				x_return_status          => x_return_status,
				x_msg_count         => x_msg_count,
				x_msg_data          => x_msg_data,
				x_update_access_flag     => l_access_flag
			);
		end if;

		if (l_access_flag <> 'Y') then
				x_return_status := 'E';
				FND_MSG_PUB.INITIALIZE;
				FND_MESSAGE.Set_Name('AST',l_message_name);
				FND_MSG_PUB.ADD;
				return;
		end if;
	end if;
	**/


	/**
	   Update the sales lead by assigning it to new owner.  Then call
	   Rebuild_Lead_Sales_Team to insert a row into as_accesses_all if needed.
	**/
		ast_uwq_wrapper_pkg.update_lead(
				p_sales_lead_id			=> p_sales_lead_id,
				p_admin_group_id		=> p_admin_group_id,
				p_identity_salesforce_id	=> p_resource_id,
				p_last_update_date         => p_last_update_date,
				p_assign_to_salesforce_id	=> p_new_salesforce_id,
				p_admin_flag				=> l_admin_flag,
				p_assign_sales_group_id		=> p_new_sales_group_id,
				x_return_status      => x_return_status,
				x_msg_count          => x_msg_count,
				x_msg_data           => x_msg_data
		);

		IF x_return_status <> 'S' THEN
				rollback;
				return;
		END IF;
	END reassign_lead;


	PROCEDURE get_potential_opportunity (
			p_sales_lead_id 	IN	  NUMBER,
			p_admin_flag		IN	  VARCHAR2,
			p_admin_group_id	IN	  NUMBER,
			p_resource_id		IN	  NUMBER,
			x_query_string  OUT NOCOPY   varchar2
	)
	AS
	l_api_version       	NUMBER := 2.0;
	l_msg_count         	NUMBER;
	l_opp_id            	NUMBER;
	l_index             	NUMBER;
	l_admin_id    			NUMBER;
	l_sales_lead_id 		NUMBER;
	l_admin_flag  			VARCHAR2(1) := nvl(p_admin_flag, 'N');
	l_init_msg_list     	VARCHAR2(5) := 'T';
	l_commit            	VARCHAR2(10) := 'F';
	l_return_status     	VARCHAR2(10);
	l_msg_data          	VARCHAR2(2000);
	l_Sales_Lead_Profile_Tbl AS_UTILITY_PUB.Profile_Tbl_Type;
	l_sales_lead_rec         AS_SALES_LEADS_PUB.SALES_LEAD_rec_type := AS_API_RECORDS_PKG.Get_P_Sales_Lead_Rec;
	l_header_tbl             AS_OPPORTUNITY_PUB.HEADER_TBL_TYPE := AS_API_RECORDS_PKG.Get_P_Header_Tbl;
	l_purchase_tbl           AS_OPPORTUNITY_PUB.LINE_TBL_TYPE := AS_API_RECORDS_PKG.Get_P_Line_Tbl;

	l_validation_level    	CONSTANT NUMBER := NVL(FND_PROFILE.VALUE('AST_SL_DEBUG_VALID_LEVEL'),0);
	G_Access_Rec_Type 		AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;

	CURSOR 	c_lead_info (p_sales_lead_id NUMBER) is
	SELECT 	customer_id, source_promotion_id
	FROM 	as_sales_leads
	WHERE 	sales_lead_id = p_sales_lead_id;

	BEGIN
		l_sales_lead_id := p_sales_lead_id;

		if l_admin_flag = 'Y' then
			l_admin_id := p_admin_group_id;
		else
			l_admin_id := null;
		end if;

		open c_lead_info(l_sales_lead_id);
		fetch c_lead_info into l_sales_lead_rec.customer_id, l_sales_lead_rec.source_promotion_id;
		close c_lead_info;

		l_sales_lead_profile_tbl(1).profile_name := 'AS_CUST_ACCESS';
		l_sales_lead_profile_tbl(1).profile_value := G_Access_Rec_Type.cust_access_profile_value;
		l_sales_lead_profile_tbl(2).profile_name := 'AS_LEAD_ACCESS';
		l_sales_lead_profile_tbl(2).profile_value := G_Access_Rec_Type.lead_access_profile_value;
		l_sales_lead_profile_tbl(3).profile_name := 'AS_OPP_ACCESS';
		l_sales_lead_profile_tbl(3).profile_value := G_Access_Rec_Type.opp_access_profile_value;
		l_sales_lead_profile_tbl(4).profile_name := 'AS_MGR_UPDATE';
		l_sales_lead_profile_tbl(4).profile_value := G_Access_Rec_Type.mgr_update_profile_value;
		l_sales_lead_profile_tbl(5).profile_name := 'AS_ADMIN_UPDATE';
		l_sales_lead_profile_tbl(5).profile_value := G_Access_Rec_Type.admin_update_profile_value;

		/** 11.5.7 should use AS_SALES_LEADS_PUB.Get_Potential_Opportunity **/

		AS_LINK_LEAD_OPP_PUB.Get_Potential_Opportunity(
		p_api_version_NUMBER     => l_api_version
		,p_init_msg_list          => l_init_msg_list
		,p_commit                 => l_commit
		,p_validation_level       => l_validation_level
		,P_Check_Access_Flag      => 'Y'
		,P_Admin_Flag             => l_admin_flag
		,P_Admin_Group_Id         => l_admin_id
		,P_identity_salesforce_id => p_resource_id
		,P_Sales_Lead_Profile_Tbl => l_Sales_Lead_Profile_Tbl
		,P_SALES_LEAD_rec         => l_sales_lead_rec
		,x_return_status          => l_return_status
		,x_msg_count              => l_msg_count
		,x_msg_data               => l_msg_data
		,x_opportunity_tbl        => l_header_tbl
		,x_opp_lines_tbl          => l_purchase_tbl );

		IF l_return_status = 'S' THEN
			IF l_header_tbl.count > 0 THEN  -- Matching Opportunity exists
				x_query_string := 'Matching Opportunity exists';
			ELSE
				x_query_string := null;
			END IF;
		ELSE
				x_query_string := null;
		END IF;
	END Get_Potential_Opportunity;

	PROCEDURE update_opportunity (
		p_admin_flag			IN  VARCHAR2,
		p_admin_group_id		IN	NUMBER,
		p_resource_id			IN	NUMBER,
		p_last_update_date 		IN 	DATE,
		p_lead_id 				IN 	NUMBER,
		p_lead_number 			IN 	VARCHAR2,
		p_description 			IN 	VARCHAR2,
		p_status_code 			IN 	VARCHAR2,
		p_close_reason_code		IN	VARCHAR2,
		p_source_promotion_id	IN 	   	NUMBER,
		p_customer_id			IN 	NUMBER,
		p_contact_party_id		IN 	NUMBER,
		p_address_id			IN 	NUMBER,
		p_sales_stage_id		IN 	NUMBER,
		p_win_probability		IN 	NUMBER,
		p_total_amount			IN 	NUMBER,
		p_total_revenue_forecast_amt	IN 	NUMBER, --added for R12
		p_channel_code 		IN 	VARCHAR2,
		p_decision_date 		IN 	DATE,
		p_currency_code 		IN 	VARCHAR2,
		p_vehicle_response_code  IN   VARCHAR2,
		p_customer_budget        IN   NUMBER,
		 --Code commented for R12 Enhancement --Start
		/* p_close_competitor_code 	IN 	VARCHAR2,
		p_close_competitor_id 	IN 	NUMBER,
		p_close_competitor 		IN 	VARCHAR2, */
		 --Code commented for R12 Enhancement --End

		p_close_comment 		IN 	VARCHAR2,
		p_parent_project 		IN 	VARCHAR2,
		p_freeze_flag 			IN 	VARCHAR2,
		p_called_node		  	IN	VARCHAR2,
		x_return_status          OUT NOCOPY  VARCHAR2,
		x_msg_count              OUT NOCOPY  NUMBER,
		x_msg_data               OUT NOCOPY  VARCHAR2,
		x_lead_id                OUT NOCOPY  NUMBER
	)
	AS
		l_api_version            NUMBER := 2.0;
		l_valid_level_full       NUMBER := 100;
		l_address_profile		VARCHAR2(3) := FND_PROFILE.value('AST_WP_USE_ADDRESS_FOR_OPP');
		l_admin_flag  			VARCHAR2(1) := nvl(p_admin_flag, 'N');
		l_init_msg_list          VARCHAR2(5) := 'T';
		l_commit                 VARCHAR2(5) := 'T';
		header_rec           	AS_OPPORTUNITY_PUB.Header_Rec_Type  := AS_API_RECORDS_PKG.get_p_header_rec;
		v_profile_tbl            AS_UTILITY_PUB.PROFILE_TBL_TYPE := AS_API_RECORDS_PKG.get_p_profile_tbl;

		l_count                   NUMBER;
		l_index                   NUMBER;
		my_message                VARCHAR2(1000);

		l_commit_BE              VARCHAR2(5) := 'F';
		x_event_key              VARCHAR2(240);

BEGIN


	Header_Rec_Set(
		p_last_update_date,
		p_lead_id ,
		p_lead_number,
		p_description,
		p_status_code,
		p_source_promotion_id,
		p_customer_id,
		p_address_id,
		p_sales_stage_id,
		p_win_probability,
		p_total_amount,
		p_total_revenue_forecast_amt, --added for R12
		p_channel_code,
		p_decision_date,
		p_currency_code,
		p_vehicle_response_code,
		p_customer_budget,
		 --Code commented for R12 Enhancement --Start
	/*	p_close_competitor_code,
		p_close_competitor_id,
		p_close_competitor , */
		 --Code commented for R12 Enhancement --End
		p_close_comment,
		p_parent_project,
		p_freeze_flag ,
		header_rec
	);

	header_rec.close_reason := p_close_reason_code;

	-- the following call added for Buiness event by subabu(bug#3499750)
	AS_BUSINESS_EVENT_PUB.before_Oppty_update(
	    p_api_version_number      => l_api_version,
	    p_init_msg_list=>l_init_msg_list,
	    p_commit=>l_commit_BE,
	    p_validation_level=>l_valid_level_full,
	    p_lead_id=>p_lead_id,
	    x_return_status=>x_return_status,
	    x_msg_count=>x_msg_count,
	    x_msg_data=>x_msg_data,
	    x_event_key=>x_event_key);
	AS_OPPORTUNITY_PUB.Update_Opp_Header
	(
		p_api_version_number            => l_api_version,
		p_init_msg_list                 => l_init_msg_list,
		p_commit                        => l_commit,
		p_validation_level              => l_valid_level_full,
		p_header_rec                    => header_rec,
		p_check_access_flag             => 'N',
		p_admin_flag                    => l_admin_flag,
		p_admin_group_id                => p_admin_group_id,
		p_identity_salesforce_id        => p_resource_id,
		p_profile_tbl                   => v_profile_tbl,
		p_partner_cont_party_id         => null,
		x_return_status                 => x_return_status,
		x_msg_count                     => x_msg_count,
		x_msg_data                      => x_msg_data,
		x_lead_id                       => x_lead_id
	);

	IF x_return_status IN ('E','U') THEN
		ROLLBACK;
		RETURN;
	END IF;
       -- the following call added for Buiness event by subabu(bug#3499750)
       if x_event_key is not null then /* Added for Bug#3522912 */
		AS_BUSINESS_EVENT_PUB.Update_oppty_post_event(
		p_api_version_number      => l_api_version,
		p_init_msg_list=>l_init_msg_list,
		p_commit=>l_commit,
		p_validation_level=>l_valid_level_full,
		p_lead_id=>p_lead_id,
		p_event_key=>x_event_key,
		x_return_status=>x_return_status,
		x_msg_count=>x_msg_count,
		x_msg_data=>x_msg_data);
	end if;

/**
	if x_return_status in ('E','U') then
		l_count := FND_MSG_PUB.Count_Msg;
		dbms_output.put_line('Update Opp: There are ' || l_count || ' messages.');
		FOR l_index IN 1..l_count LOOP
			my_message := FND_MSG_PUB.Get(
			p_msg_index   =>  l_index,
			p_encoded     =>  FND_API.G_FALSE);
			dbms_output.put_line(substr(my_message,1,255));
		END LOOP;

		rollback;
		return;
	end if;
**/
	EXCEPTION
		when OTHERS THEN
			ROLLBACK;
			RAISE;
	END update_opportunity;

END ast_uwq_wrapper_pkg;

/
