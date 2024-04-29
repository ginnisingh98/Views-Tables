--------------------------------------------------------
--  DDL for Package Body CS_AUTOGEN_TASK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_AUTOGEN_TASK_PVT" AS
/* $Header: csvatskb.pls 120.12.12010000.7 2010/01/06 07:07:54 sshilpam ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_AutoGen_Task_PVT';

-- 12.1.2 SR Task Enhancement project
-- Get the Planned End date based on the Profile
PROCEDURE Default_Planned_End_Date(p_respond_by IN DATE,
				   p_resolve_by IN DATE,
				   p_uom_code IN varchar2 DEFAULT FND_API.G_MISS_CHAR,
				   p_planned_effort IN Number DEFAULT FND_API.G_MISS_NUM,
				   x_planned_end_date OUT NOCOPY DATE) IS

   l_profile		Varchar2(50);
   l_profile_respond_by Number;
   l_planned_effort     Number;
   l_planned_end_date   Date;
BEGIN

    l_profile := fnd_profile.value('CS_SR_TSK_DEF_PLN_END_DT');
    l_profile_respond_by := To_number(fnd_profile.value('CS_SR_TASK_RESPOND_BY'));

    if nvl(l_profile,'RESP_BY') = 'RESP_BY' Then

       If p_respond_by is not null and p_respond_by >= Sysdate Then
          l_planned_end_date:= p_respond_by;

       ElsIf l_profile_respond_by is not null Then
          select sysdate + l_profile_respond_by into l_planned_end_date from dual;

       Elsif p_planned_effort is not null and p_uom_code is not null then
	  l_planned_end_date := okc_time_util_pub.get_enddate(Sysdate,p_uom_code,p_planned_effort);
       End If;

    Elsif l_profile = 'RESL_EFFORT' Then

       If  p_respond_by  is not null and p_respond_by >= Sysdate then
          l_planned_end_date := p_respond_by;

       Elsif p_resolve_by is not null and p_resolve_by >= Sysdate then
         IF p_planned_effort is not null and p_uom_code is not null then
            l_planned_effort := p_planned_effort * (-1);
	    l_planned_end_date := okc_time_util_pub.get_enddate(p_resolve_by,p_uom_code,l_planned_effort);

	 End IF;
       Elsif l_profile_respond_by is not null Then
          select sysdate + l_profile_respond_by into l_planned_end_date from dual;

       Elsif p_planned_effort is not null and p_uom_code is not null then
          l_planned_end_date := okc_time_util_pub.get_enddate(Sysdate,p_uom_code,p_planned_effort);

       End if;
    Elsif l_profile = 'RESL_BY' then
       If p_resolve_by is not null and p_resolve_by >= Sysdate then
          l_planned_end_date := p_resolve_by;

       elsif l_profile_respond_by is not null Then
          select sysdate + l_profile_respond_by  into l_planned_end_date from dual;

       Elsif p_planned_effort is not null and p_uom_code is not null then
          l_planned_end_date := okc_time_util_pub.get_enddate(Sysdate,p_uom_code,p_planned_effort);
       End if;
    End if;

    If l_planned_end_date < sysdate or l_planned_end_date is null then
       x_planned_end_date := SYSDATE;
    Else
       x_planned_end_date := l_planned_end_date;
    End IF;

End Default_Planned_End_Date;
-- End of 12.1.2 Project code

PROCEDURE Create_Task_From_Template
(
  P_task_template_group_owner	   IN		NUMBER,
  P_task_tmpl_group_owner_type     IN   	VARCHAR2,
  P_incident_id                    IN           NUMBER,
  P_service_request_rec		   IN	        Cs_ServiceRequest_PVT.Service_Request_rec_type,
  P_task_template_group_info	   IN		JTF_TASK_INST_TEMPLATES_PUB.task_template_group_info,
  P_task_template_tbl		   IN	        JTF_TASK_INST_TEMPLATES_PUB.task_template_info_tbl,
  X_field_service_task_created	   OUT NOCOPY	BOOLEAN,
  X_return_status		   OUT NOCOPY	VARCHAR2,
  X_msg_data                       OUT NOCOPY   VARCHAR2,
  X_msg_count                      OUT NOCOPY   NUMBER
  ) IS

  l_level_statement 		   VARCHAR2(240) := 'cs.plsql.cs_autogen_task_pvt.create_task_from_template';
  l_return_status   		   VARCHAR2(30) := 'S';
  l_commit          		   VARCHAR2(30) := fnd_api.g_false;
  l_init_msg_list   		   VARCHAR2(30) := fnd_api.g_false;
  l_owner_group_id  		   NUMBER ;
  l_owner_id        		   NUMBER ;
  l_owner_type      		   VARCHAR2(30) ;
  l_msg_count       		   NUMBER ;
  l_msg_data        		   VARCHAR2(240) ;
  l_task_rule       		   VARCHAR2(30) := null ;
  l_template_group_name 	   VARCHAR2(80);
  l_field_service_task_created     BOOLEAN     := FALSE;
  l_task_name                      VARCHAR2(240) := null;
  l_owner_group_type               VARCHAr2(240);

-- Variabkes to be passed to the JTF Create Task From emplate API

  l_task_template_group_info  JTF_TASK_INST_TEMPLATES_PUB.task_template_group_info := P_task_template_group_info ;
  l_task_template_tbl         JTF_TASK_INST_TEMPLATES_PUB.task_template_info_tbl    := P_task_template_tbl;
  l_task_contact_points_tbl JTF_TASK_INST_TEMPLATES_PUB.task_contact_points_tbl ;
  l_task_details_tbl          JTF_TASK_INST_TEMPLATES_PUB.task_details_tbl ;


-- Variabkes to be passed to the Task Auto Assignment API

  l_task_attribute_rec        CS_SR_TASK_AUTOASSIGN_PKG.Sr_Task_rec_type := null;
  l_service_request_pub_rec   CS_SERVICEREQUEST_PUB.Service_Request_Rec_Type ;

-- Exception declaraion

  e_AutoAssignment_Exception EXCEPTION ;
  e_party_site_exception     EXCEPTION ;
  e_Planned_effort_Exception EXCEPTION ;
  e_CreateTask_Exception     EXCEPTION ;

-- Cursor declareation

  -- Cursor to check task type

     CURSOR c_check_task_type (p_task_type_id IN NUMBER) IS
  	 SELECT RULE
	   FROM jtf_task_types_vl
	  WHERE task_type_id = p_task_type_id ;

  -- cursor to determine task template group name

     CURSOR c_get_tgt_name IS
     	  SELECT template_group_name
	    FROM jtf_task_temp_groups_vl
	   WHERE task_template_group_id =  l_task_template_group_info.task_template_group_id;


 -- Simplex
 -- local variable and exception declarations for Simplex Enhancement
 l_prof_val            VARCHAR(1);
 l_temp                NUMBER(30,6);
 l_api_name            VARCHAR2(100) := 'CS_AutoGen_Task_PVT.Create_Task_From_Template';
 l_conv_rate           NUMBER(30,6);
 l_conv_rate_day       NUMBER;
 l_planned_effort      NUMBER(30,6):= 0;
 l_text                VARCHAR2(240);

  e_date_pair_exception          EXCEPTION ;
  e_planned_effort_val_exception EXCEPTION ;
 -- end of Simplex

 l_owner_territory_id  NUMBER;
 l_profile_respond_by  NUMBER;  -- Bug 7281019

BEGIN

      -- Simplex
      -- Get the value for the profile option 'Service : Apply State Restriction on Tasks'
      -- to decide the enabling/disabling of task state restrictions

      FND_PROFILE.Get('CS_SR_ENABLE_TASK_STATE_RESTRICTIONS',l_prof_val);

      -- end Simplex

      -- Loop through the Task Template table

      FOR i IN 1..l_task_template_tbl.COUNT

          LOOP

             -- Get task owner

             IF (( l_task_template_tbl(i).owner_id IS NULL) OR (l_task_template_tbl(i).owner_type_code IS NULL) )  THEN

                IF ((p_task_template_group_owner IS NOT NULL) AND (p_task_tmpl_group_owner_type IS NOT NULL) )  THEN      -- Get owner if


	        -- Assign the passed owner to the task.

	      	    l_task_template_tbl(i).owner_type_code := p_task_tmpl_group_owner_type ;
		    l_task_template_tbl(i).owner_id        := p_task_template_group_owner;
	        ELSE

                -- Get owner else
	        -- Call Auto Owner Assignment API to get task owner


		    -- Initialize task rec


	            l_task_attribute_rec := NULL;

	            l_task_attribute_rec.TASK_ID               := null ;
	            l_task_attribute_rec.SERVICE_REQUEST_ID    := p_incident_id ;
	            l_task_attribute_rec.PARTY_ID              := p_service_request_rec.customer_id ;
	            l_task_attribute_rec.COUNTRY               := p_service_request_rec.incident_country;
	            l_task_attribute_rec.CITY                   := p_service_request_rec.incident_city ;
	            l_task_attribute_rec.POSTAL_CODE            := p_service_request_rec.incident_postal_code ;
	            l_task_attribute_rec.STATE                  := p_service_request_rec.incident_state ;
	            l_task_attribute_rec.AREA_CODE              := p_service_request_rec.incident_postal_code ;
	            l_task_attribute_rec.COUNTY                 := p_service_request_rec.incident_county ;
	            l_task_attribute_rec.PROVINCE               := p_service_request_rec.incident_province ;
	            l_task_attribute_rec.TASK_TYPE_ID           := l_task_template_tbl(i).task_type_id ;
	            l_task_attribute_rec.TASK_STATUS_ID         := l_task_template_tbl(i).task_status_id ;
	            l_task_attribute_rec.TASK_PRIORITY_ID       := l_task_template_tbl(i).task_priority_id ;
	            l_task_attribute_rec.INCIDENT_TYPE_ID       := p_service_request_rec.type_id;
	            l_task_attribute_rec.INCIDENT_SEVERITY_ID   := p_service_request_rec.severity_id;
	            l_task_attribute_rec.INCIDENT_URGENCY_ID    := p_service_request_rec.urgency_id;
	            l_task_attribute_rec.PROBLEM_CODE           := p_service_request_rec.problem_code;
	            l_task_attribute_rec.INCIDENT_STATUS_ID     := p_service_request_rec.status_id;
	            l_task_attribute_rec.PLATFORM_ID            := p_service_request_rec.platform_id;
	            l_task_attribute_rec.CUSTOMER_SITE_ID       := p_service_request_rec.customer_site_id;
	            l_task_attribute_rec.SR_CREATION_CHANNEL    := p_service_request_rec.sr_creation_channel;
	            l_task_attribute_rec.INVENTORY_ITEM_ID      := p_service_request_rec.inventory_item_id;
	            l_task_attribute_rec.ATTRIBUTE1             := l_task_template_tbl(i).attribute1 ;
	            l_task_attribute_rec.ATTRIBUTE2             := l_task_template_tbl(i).attribute2 ;
	            l_task_attribute_rec.ATTRIBUTE3             := l_task_template_tbl(i).attribute3 ;
	            l_task_attribute_rec.ATTRIBUTE4             := l_task_template_tbl(i).attribute4 ;
	            l_task_attribute_rec.ATTRIBUTE5             := l_task_template_tbl(i).attribute5 ;
	            l_task_attribute_rec.ATTRIBUTE6             := l_task_template_tbl(i).attribute6 ;
	            l_task_attribute_rec.ATTRIBUTE7             := l_task_template_tbl(i).attribute7 ;
	            l_task_attribute_rec.ATTRIBUTE8             := l_task_template_tbl(i).attribute8 ;
	            l_task_attribute_rec.ATTRIBUTE9             := l_task_template_tbl(i).attribute9 ;
	            l_task_attribute_rec.ATTRIBUTE10            := l_task_template_tbl(i).attribute10 ;
	            l_task_attribute_rec.ATTRIBUTE11            := l_task_template_tbl(i).attribute11 ;
	            l_task_attribute_rec.ATTRIBUTE12            := l_task_template_tbl(i).attribute12 ;
	            l_task_attribute_rec.ATTRIBUTE13            := l_task_template_tbl(i).attribute13 ;
	            l_task_attribute_rec.ATTRIBUTE14            := l_task_template_tbl(i).attribute14 ;
	            l_task_attribute_rec.ATTRIBUTE15            := l_task_template_tbl(i).attribute15 ;
	            l_task_attribute_rec.ORGANIZATION_ID        := p_service_request_rec.inventory_org_id ;

	            -- Following task parameters are not available

	            --l_task_attribute_rec.COMP_NAME_RANGE                VARCHAR2 ;
	            --l_task_attribute_rec.NUM_OF_EMPLOYEES               NUMBER,
	            --l_task_attribute_rec.SUPPORT_SITE_ID                NUMBER;

	            -- l_task_attribute_rec.SQUAL_NUM12                    NUMBER, --INVENTORY ITEM ID / SR PLATFORM
	            -- l_task_attribute_rec.SQUAL_NUM13                    NUMBER, --ORGANIZATION ID   / SR PLATFORM
		    -- l_task_attribute_rec.SQUAL_NUM14                    NUMBER, --CATEGORY ID       / SR PRODUCT
		    -- l_task_attribute_rec.SQUAL_NUM15                    NUMBER, --INVENTORY ITEM ID / SR PRODUCT
		    -- l_task_attribute_rec.SQUAL_NUM16                    NUMBER, --ORGANIZATION ID   / SR PRODUCT
		    -- l_task_attribute_rec.SQUAL_NUM17                    NUMBER, --SR GROUP OWNER
		    -- l_task_attribute_rec.SQUAL_NUM18                    NUMBER, --INVENTORY ITEM ID / CONTRACT SUPPORT SERVICE ITEM
		    -- l_task_attribute_rec.SQUAL_NUM19                    NUMBER, --ORGANIZATION ID   / CONTRACT SUPPORT SERVICE ITEM
		    -- l_task_attribute_rec.SQUAL_NUM30                    NUMBER, --SR LANGUAGE ... should use squal_char20 instead
		    -- l_task_attribute_rec.SQUAL_CHAR11                   VARCHAR2(360), --VIP CUSTOMERS
		    -- l_task_attribute_rec.SQUAL_CHAR12                   VARCHAR2(360), --SR PROBLEM CODE
		    -- l_task_attribute_rec.SQUAL_CHAR13                   VARCHAR2(360), --SR CUSTOMER CONTACT PREFERENCE
		    -- l_task_attribute_rec.SQUAL_CHAR20                   VARCHAR2(360),  --SR LANGUAGE ID for TERR REQ
		    -- l_task_attribute_rec.SQUAL_CHAR21                   VARCHAR2(360)   --SR Service Contract Coverage


                    -- Initialize OUT parameters

		       l_owner_group_id := null ;
		       l_owner_id       := null ;
		       l_owner_type     := null ;
		       l_return_status  := null ;


 		       CS_SR_TASK_AUTOASSIGN_PKG.Assign_Task_Resource
		   	  (p_api_version            => 1.0 ,
		   	   p_init_msg_list          => fnd_api.g_false ,
			   p_commit                 => l_commit ,
			   p_incident_id            => p_incident_id ,
			   p_task_attribute_rec     => l_task_attribute_rec ,
			   x_owner_group_id         => l_owner_group_id ,
                           x_group_type             => l_owner_group_type,
			   x_owner_type             => l_owner_type ,
			   x_owner_id               => l_owner_id ,
			   x_return_status          => l_return_status ,
                           x_territory_id           => l_owner_territory_id ,
			   x_msg_count              => x_msg_count ,
			   x_msg_data               => x_msg_data );


                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			   -- 12.1.3 Task enh proj
			   IF l_owner_id is null or l_owner_type is null Then
			      FND_PROFILE.Get('INC_DEFAULT_INCIDENT_TASK_OWNER', l_owner_id);
			      FND_PROFILE.Get('INC_DEFAULT_INCIDENT_TASK_OWNER_TYPE', l_owner_type);

			      l_task_template_tbl(i).owner_type_code        := l_owner_type ;
		   	      l_task_template_tbl(i).owner_id               := l_owner_id ;
			   End If;
			   If l_owner_id is null or l_owner_type is null Then
			   -- End Task Enh proj
		              l_task_name := null;
	  	              l_task_name := l_task_template_tbl(i).task_name;
		              RAISE e_AutoAssignment_Exception;
			   End If;
		        ELSE

		           -- Assign the derived owner to the task.
                              IF l_owner_id IS NOT NULL THEN
		   	         l_task_template_tbl(i).owner_type_code        := l_owner_type ;
		   	         l_task_template_tbl(i).owner_id               := l_owner_id ;
                                 l_task_template_group_info.owner_id           := l_owner_id;
                                 l_task_template_group_info.owner_type_code    := l_owner_type;
                                 l_task_template_group_info.owner_territory_id := l_owner_territory_id;
                              ELSIF l_owner_group_id IS NOT NULL THEN
                                 l_task_template_tbl(i).owner_type_code        := l_owner_group_type ;
                                 l_task_template_tbl(i).owner_id               := l_owner_group_id ;
                                 l_task_template_group_info.owner_id           := l_owner_id;
                                 l_task_template_group_info.owner_type_code    := l_owner_type;
                                 l_task_template_group_info.owner_territory_id := l_owner_territory_id;

                              ELSE
                                 RAISE e_AutoAssignment_Exception;
                              END IF ;

		        END IF ;
	        END IF ;      -- Get owner end if
             END IF ;

             -- Ensure that the incident location is passed for the field service tasks

              l_task_rule := null;

               OPEN c_check_task_type (l_task_template_tbl(i).task_type_id) ;
              FETCH c_check_task_type INTO l_task_rule ;
              CLOSE c_check_task_type ;

                IF NVL(l_task_rule,'XXXXX') = 'DISPATCH' THEN

                   IF p_service_request_rec.incident_location_id IS NULL THEN
                      RAISE e_party_site_exception ;
                   END IF ;

                END IF ;

	     -- Determine Planned Effort

                IF ((l_task_template_tbl(i).planned_effort IS NULL) AND (NVL(l_task_rule,'XXXX') = 'DISPATCH')) THEN
	           l_task_name := null;
	           l_task_name := l_task_template_tbl(i).task_name;


	           RAISE e_Planned_effort_Exception;
	        END IF ;


	     -- Determine Planned END Date and  Start Date
		-- Commented the code for 12.1.2 Project SR Task Enhancements
	           /* l_task_template_tbl(i).planned_start_date := sysdate ;

                   IF p_service_request_rec.obligation_date IS NULL THEN
		      -- Bug 7281019, Calculate the planned end date from the profile when respond by date is null
		      l_profile_respond_by := to_number(fnd_profile.value('CS_SR_TASK_RESPOND_BY'));
		      l_task_template_tbl(i).planned_end_date := sysdate + nvl(l_profile_respond_by,0);
                      --l_task_template_tbl(i).planned_end_date := sysdate ; -- NULL;
                   ELSIF (p_service_request_rec.obligation_date > sysdate) THEN
                      l_task_template_tbl(i).planned_end_date := sysdate +(p_service_request_rec.obligation_date -sysdate);
                   ELSE
                      l_task_template_tbl(i).planned_end_date := sysdate ;
                   END IF ;
	*/
	    -- Simplex
	      -- The below validations should be done every tasks in the task template group and
	      -- hence the validations are inside the loop

              -- Enable task state restrictions depending on the profile value
	      -- 'Service : Apply State Restriction on Tasks'
	      IF ( l_prof_val = 'Y') THEN
		  l_task_template_tbl(i).p_date_selected := 'D';
	      END IF;

             -- If the confirmation status is set as 'Confirmed'('C') in the task template group,
	     -- the Confirmation status should be set to 'Not Requried'('N'),
 	     IF ( l_task_template_tbl(i).task_confirmation_status = 'C') THEN
	        l_task_template_tbl(i).task_confirmation_status := 'N';
	     END IF ;

	     -- The palnned start date and planned end date should appear in pair.
	      -- If not,exception is thrown
              IF ( (  (l_task_template_tbl(i).planned_start_date IS NOT NULL AND
	              l_task_template_tbl(i).planned_start_date <> FND_API.G_MISS_DATE)
		      AND
		      (l_task_template_tbl(i).planned_end_date IS NULL OR
		      l_task_template_tbl(i).planned_end_date = FND_API.G_MISS_DATE)
		   )
		   OR
                   (  (l_task_template_tbl(i).planned_end_date IS NOT NULL AND
	               l_task_template_tbl(i).planned_end_date <> FND_API.G_MISS_DATE)
		       AND
		       (l_task_template_tbl(i).planned_start_date IS NULL OR
		        l_task_template_tbl(i).planned_start_date = FND_API.G_MISS_DATE)
		    )
		  )THEN

                   l_task_name := null;
	           l_task_name := l_task_template_tbl(i).task_name;

		   Raise e_date_pair_exception;
	      END IF;

	      -- end Simplex
          END LOOP ;    -- End loop for the task template table.


	  -- Call JTF API to create task from template.

             -- Initialize OUT parameters

   	        l_owner_group_id := null ;
	        l_owner_id       := null ;
	        l_owner_type     := null ;
	        l_return_status  := null ;

                JTF_TASK_INST_TEMPLATES_PUB.create_task_from_template
                       (p_api_version 			=> 1.0 ,
                        p_init_msg_list 		=> fnd_api.g_false ,
                        p_commit 			=> l_commit ,
                        p_task_template_group_info 	=> l_task_template_group_info,
                        p_task_templates_tbl 		=> l_task_template_tbl,
                        p_task_contact_points_tbl 	=> l_task_contact_points_tbl,
                        x_return_status 		=> l_return_status ,
                        x_msg_count 			=> x_msg_count ,
                        x_msg_data 			=> x_msg_data ,
                        x_task_details_tbl 		=> l_task_details_tbl);


	        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

		    RAISE e_CreateTask_Exception;
	        ELSE
	            x_return_status := FND_API.G_RET_STS_SUCCESS ;
	            x_field_service_task_created  := l_field_service_task_created  ;

	        END IF ;

EXCEPTION
     WHEN e_AutoAssignment_Exception THEN
          OPEN c_get_tgt_name;
	  FETCH c_get_tgt_name INTO l_template_group_name ;
          CLOSE c_get_tgt_name;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
 		   	            p_data  => x_msg_data );
	  FND_MESSAGE.SET_NAME('CS','CS_SR_TSK_AUTO_ASSIGNMENT_FAIL');
          FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE_GROUP',l_template_group_name);
	  FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE',l_task_name);
          FND_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR ;
     WHEN e_party_site_exception THEN
          OPEN c_get_tgt_name;
	  FETCH c_get_tgt_name INTO l_template_group_name ;
          CLOSE c_get_tgt_name;
	  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
			            p_data  => x_msg_data );
	  FND_MESSAGE.SET_NAME('CS','CS_SR_TSK_INVALID_PARTY_SITE');
	  FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE_GROUP',l_template_group_name);
          FND_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR ;
     WHEN e_Planned_effort_Exception THEN
          OPEN c_get_tgt_name;
	  FETCH c_get_tgt_name INTO l_template_group_name ;
          CLOSE c_get_tgt_name;
	  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
		   	            p_data  => x_msg_data );
	  FND_MESSAGE.SET_NAME('CS','CS_SR_TSK_INVALID_PLANNED_EFRT');
	  FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE_GROUP',l_template_group_name);
	  FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE',l_task_name);
          FND_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR ;
     WHEN e_CreateTask_Exception THEN
          OPEN c_get_tgt_name;
          FETCH c_get_tgt_name INTO l_template_group_name ;
          CLOSE c_get_tgt_name;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
		   	            p_data  => x_msg_data );
          FND_MESSAGE.SET_NAME('CS','CS_SR_TSK_CREATE_TASK_FAILED');
          FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE_GROUP',l_template_group_name);
          FND_MSG_PUB.ADD;
          l_text := sqlcode||'-'||sqlerrm ;
	  x_return_status := FND_API.G_RET_STS_ERROR ;
     -- Simplex
     -- The following are the exceptions thrown as a part of the validations done
     -- for Task State Restrictions
     WHEN e_date_pair_exception THEN
          OPEN c_get_tgt_name;
          FETCH c_get_tgt_name INTO l_template_group_name ;
          CLOSE c_get_tgt_name;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
		   	            p_data  => x_msg_data );
          FND_MESSAGE.SET_NAME('CS','CS_DATE_PAIR_ERROR');
	  FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE_GROUP',l_template_group_name);
	  FND_MESSAGE.SET_TOKEN('API_NAME',l_api_name);
	  FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE',l_task_name);
          FND_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR ;
     WHEN e_planned_effort_val_exception THEN
          OPEN c_get_tgt_name;
          FETCH c_get_tgt_name INTO l_template_group_name ;
          CLOSE c_get_tgt_name;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
		   	            p_data  => x_msg_data );
          FND_MESSAGE.SET_NAME('CS','CS_PLANNED_EFFORT_VAL_ERROR');
	  FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE_GROUP',l_template_group_name);
	  FND_MESSAGE.SET_TOKEN('API_NAME',l_api_name);
	  FND_MESSAGE.SET_TOKEN('TASK_TEMPLATE',l_task_name);
          FND_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR ;
     -- end of simplex
     WHEN others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
          FND_MESSAGE.SET_TOKEN ('P_TEXT',l_level_statement ||'  - '||SQLERRM);
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
				    p_data  => x_msg_data);
	  x_return_status := FND_API.G_RET_STS_ERROR ;

END Create_Task_From_Template;



PROCEDURE Get_Task_Template_Group
(
	p_api_version				IN		NUMBER,
	p_init_msg_list				IN		VARCHAR2 DEFAULT fnd_api.g_false,
	p_commit				IN		VARCHAR2 DEFAULT fnd_api.g_false,
	p_validation_level			IN		NUMBER   DEFAULT fnd_api.g_valid_level_full,
	p_task_template_search_rec		IN		CS_AutoGen_Task_PVT.task_template_search_rec_type,
	x_task_template_group_tbl		OUT NOCOPY	CS_AutoGen_Task_PVT.task_template_group_tbl_type,
	x_return_status				OUT NOCOPY	VARCHAR2,
	x_msg_count				OUT NOCOPY	NUMBER,
	x_msg_data				OUT NOCOPY	VARCHAR2
)
IS

  l_api_name                  		CONSTANT VARCHAR2(30) := 'Get_Task_Template_Group';
  l_api_name_full             		CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

  l_api_version               		CONSTANT NUMBER := 1.0;

  l_all_attrs_passed			BOOLEAN;

  Cursor c_search_rules
  Is
  Select *
  From cs_sr_tsk_tmpl_seq_rules
  Where active_flag = 'Y'
  Order by search_sequence;

  -- Cursor modified to check equality between database column and parameter value only if parameter value has been passed
  --anmukher -- 08/27/03
/*
  Cursor c_task_template_grp
  (p_incident_type_id	NUMBER,
   p_organization_id	NUMBER,
   p_inventory_item_id	NUMBER,
   p_category_id	NUMBER,
   p_problem_code	VARCHAR2,
   p_null_num		NUMBER,
   p_null_char		VARCHAR2,
   p_num		NUMBER,
   p_char		VARCHAR2)
  Is
  Select task_template_group_id
  From cs_sr_tsk_tmpl_gp_map
  Where decode(p_incident_type_id, p_null_num, p_num, incident_type_id)  =  nvl(p_incident_type_id, p_num)
  And decode(p_organization_id, p_null_num, p_num, organization_id)      =  nvl(p_organization_id, p_num)
  And decode(p_inventory_item_id, p_null_num, p_num, inventory_item_id)  =  nvl(p_inventory_item_id, p_num)
  And decode(p_category_id, p_null_num, p_num, category_id)              =  nvl(p_category_id, p_num)
  And decode(p_problem_code, p_null_char, p_char, problem_code)          =  nvl(p_problem_code, p_char);
*/

  -- Cursor re-written --anmukher --10/13/03
  Cursor c_task_template_grp
  (p_incident_type_id	NUMBER,
   p_organization_id	NUMBER,
   p_inventory_item_id	NUMBER,
   p_category_id	NUMBER,
   p_problem_code	VARCHAR2,
   p_num		NUMBER,
   p_char		VARCHAR2)
  Is
  Select gp.task_template_group_id
    From cs_sr_tsk_tmpl_gp_map gp,
         jtf_task_temp_groups_vl jtf
   Where nvl(gp.incident_type_id, p_num)    =  nvl(p_incident_type_id, p_num)
     And nvl(gp.organization_id, p_num)     =  nvl(p_organization_id, p_num)
     And nvl(gp.inventory_item_id, p_num)   =  nvl(p_inventory_item_id, p_num)
     And nvl(gp.category_id, p_num)         =  nvl(p_category_id, p_num)
     And nvl(gp.problem_code, p_char)       =  nvl(p_problem_code, p_char)
     AND TRUNC(sysdate) BETWEEN TRUNC(NVL(gp.start_date,sysdate)) AND TRUNC(NVL(gp.end_date,sysdate))
     AND jtf.task_template_group_id         =  gp.task_template_group_id
     AND TRUNC(sysdate) BETWEEN TRUNC(NVL(jtf.start_date_active,sysdate)) AND TRUNC(NVL(jtf.end_date_active,sysdate));

  Cursor c_category
  (p_category_set_id	NUMBER)
  Is
  SELECT category_id
  FROM mtl_item_categories
  WHERE organization_id = p_task_template_search_rec.organization_id
  AND inventory_item_id = p_task_template_search_rec.inventory_item_id
  AND category_set_id = p_category_set_id;

  l_search_rules_rec			c_search_rules%rowtype;

  l_task_template_grp_rec		c_task_template_grp%rowtype;

  l_category_id				NUMBER := NULL;

  l_category_set_id			NUMBER := NULL;

  l_tbl_index				BINARY_INTEGER := 0;

/* Added for passing NULLs if attribute is not part of search rule
   --anmukher --10/13/03
*/

  l_incident_type_id			NUMBER;

  l_organization_id			NUMBER;

  l_inventory_item_id			NUMBER;

  l_problem_code			VARCHAR2(30);

Begin

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
						l_api_name, G_PKG_NAME) THEN
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get all active search rules
  open c_search_rules;

  fetch c_search_rules into l_search_rules_rec;

  While c_search_rules%found
  Loop

    --Initialize all local variables used for fetching group templates to NULL --anmukher
    l_category_id		:= NULL;
    l_incident_type_id		:= NULL;
    l_organization_id		:= NULL;
    l_inventory_item_id		:= NULL;
    l_problem_code		:= NULL;

    -- Check if search rule contains product category and if product category has been passed
    If (instr(l_search_rules_rec.search_rule_code, 'C') > 0 And p_task_template_search_rec.category_id IS NOT NULL)
    -- Or if search rule does not contain product category
    Or (instr(l_search_rules_rec.search_rule_code, 'C') = 0) Then

        -- Check if all search attributes have been passed
        -- First assume that all relevant attributes
        -- (those that are part of the search rule) have been passed
        l_all_attrs_passed := TRUE;

        -- Check for SR Type
        If (instr(l_search_rules_rec.search_rule_code, 'T') > 0
         And p_task_template_search_rec.incident_type_id IS NULL) Then
          l_all_attrs_passed := FALSE;
        End If;

        -- Check for Problem Code
        If (instr(l_search_rules_rec.search_rule_code, 'P') > 0
         And p_task_template_search_rec.problem_code IS NULL) Then
          l_all_attrs_passed := FALSE;
        End If;

        -- Check for Product
        If (instr(l_search_rules_rec.search_rule_code, 'I') > 0
         And ( p_task_template_search_rec.inventory_item_id IS NULL OR p_task_template_search_rec.organization_id IS NULL) ) Then
          l_all_attrs_passed := FALSE;
        End If;

        -- Populate the local variables if attribute is part of search rule and has been passed
        --anmukher --10/13/03
        IF (instr(l_search_rules_rec.search_rule_code, 'C') > 0 And p_task_template_search_rec.category_id IS NOT NULL) THEN
          l_category_id		:= p_task_template_search_rec.category_id;
        END IF;

        IF (instr(l_search_rules_rec.search_rule_code, 'T') > 0 And p_task_template_search_rec.incident_type_id IS NOT NULL) THEN
          l_incident_type_id	:= p_task_template_search_rec.incident_type_id;
        END IF;

        IF (instr(l_search_rules_rec.search_rule_code, 'P') > 0 And p_task_template_search_rec.problem_code IS NOT NULL) THEN
          l_problem_code	:= p_task_template_search_rec.problem_code;
        END IF;

        IF (instr(l_search_rules_rec.search_rule_code, 'I') > 0 And (p_task_template_search_rec.inventory_item_id IS NOT NULL AND p_task_template_search_rec.organization_id IS NOT NULL)) THEN
          l_inventory_item_id	:= p_task_template_search_rec.inventory_item_id;
          l_organization_id	:= p_task_template_search_rec.organization_id;
        END IF;

        If l_all_attrs_passed = TRUE Then
          /*
          open c_task_template_grp
          (p_task_template_search_rec.incident_type_id,
           p_task_template_search_rec.organization_id,
           p_task_template_search_rec.inventory_item_id,
           p_task_template_search_rec.category_id,
           p_task_template_search_rec.problem_code,
           NULL,
           NULL,
           -99,
           'AA');
          */
          -- anmukher --10/13/03
          open c_task_template_grp
          (l_incident_type_id,
           l_organization_id,
           l_inventory_item_id,
           l_category_id,
           l_problem_code,
           -99,
           '@@');

          fetch c_task_template_grp into l_task_template_grp_rec;

          while c_task_template_grp%found
          Loop
            x_task_template_group_tbl(l_tbl_index).task_template_group_id := l_task_template_grp_rec.task_template_group_id;

            l_tbl_index := l_tbl_index + 1;
            fetch c_task_template_grp into l_task_template_grp_rec;
          end loop; -- c_task_template_grp%found

          close c_task_template_grp;

        end if; -- If l_all_attrs_passed = TRUE

    -- Check if product is passed and derive product category from product
    -- if search rule contains product category (but category has not been passed)
    ELSIF (instr(l_search_rules_rec.search_rule_code, 'C') > 0 And p_task_template_search_rec.category_id IS NULL)
    AND (p_task_template_search_rec.inventory_item_id IS NOT NULL)
    AND (p_task_template_search_rec.organization_id IS NOT NULL) Then

      -- Check if all search attributes have been passed
      -- First assume that all relevant attributes
      -- (those that are part of the search rule) have been passed
      l_all_attrs_passed := TRUE;

      -- Check for SR Type
      If (instr(l_search_rules_rec.search_rule_code, 'T') > 0
       And p_task_template_search_rec.incident_type_id IS NULL) Then
        l_all_attrs_passed := FALSE;
      End If;

      -- Check for Problem Code
      If (instr(l_search_rules_rec.search_rule_code, 'P') > 0
       And p_task_template_search_rec.problem_code IS NULL) Then
        l_all_attrs_passed := FALSE;
      End If;

        -- Populate the local variables if attribute is part of search rule and has been passed
        -- No need to populate category id since it is being fetched from cursor
        --anmukher --10/13/03
        IF (instr(l_search_rules_rec.search_rule_code, 'T') > 0 And p_task_template_search_rec.incident_type_id IS NOT NULL) THEN
          l_incident_type_id	:= p_task_template_search_rec.incident_type_id;
        END IF;

        IF (instr(l_search_rules_rec.search_rule_code, 'P') > 0 And p_task_template_search_rec.problem_code IS NOT NULL) THEN
          l_problem_code	:= p_task_template_search_rec.problem_code;
        END IF;

        IF (instr(l_search_rules_rec.search_rule_code, 'I') > 0 And (p_task_template_search_rec.inventory_item_id IS NOT NULL AND p_task_template_search_rec.organization_id IS NOT NULL)) THEN
          l_inventory_item_id	:= p_task_template_search_rec.inventory_item_id;
          l_organization_id	:= p_task_template_search_rec.organization_id;
        END IF;

      If l_all_attrs_passed = TRUE Then

        -- Get the category set from the relevant site-level profile
        l_category_set_id := fnd_profile.value('CS_SR_DEFAULT_CATEGORY_SET');

        for l_category_rec in c_category(l_category_set_id)
        loop
          /*
          open c_task_template_grp
          (p_task_template_search_rec.incident_type_id,
           p_task_template_search_rec.organization_id,
           p_task_template_search_rec.inventory_item_id,
           l_category_rec.category_id,
           p_task_template_search_rec.problem_code,
           NULL,
           NULL,
           -99,
           'AA');
          */
          --anmukher --10/13/03
          open c_task_template_grp
          (l_incident_type_id,
           l_organization_id,
           l_inventory_item_id,
           l_category_rec.category_id,
           l_problem_code,
           -99,
           '@@');

          fetch c_task_template_grp into l_task_template_grp_rec;

          while c_task_template_grp%found
          Loop
            x_task_template_group_tbl(l_tbl_index).task_template_group_id := l_task_template_grp_rec.task_template_group_id;

            l_tbl_index := l_tbl_index + 1;
            fetch c_task_template_grp into l_task_template_grp_rec;
          end loop; -- c_task_template_grp%found

          close c_task_template_grp;

        end loop; -- for l_category_rec in c_category(l_category_set_id)

      end if; -- If l_all_attrs_passed = TRUE Then

    end if; -- If (instr(l_search_rules_rec.search_rule_code, 'C') > 0 And p_task_template_search_rec.category_id IS NOT NULL)

  -- If task template groups have been found then exit the loop, otherwise look for the next search rule
  If l_tbl_index > 0 Then
    exit;
  Else
    fetch c_search_rules into l_search_rules_rec;
  End If;

  end loop; -- While c_search_rules%found

  close c_search_rules;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      If c_task_template_grp%IsOpen Then
        close c_task_template_grp;
      End If;
      If c_search_rules%IsOpen Then
        close c_search_rules;
      End If;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END Get_Task_Template_Group;



PROCEDURE Auto_Generate_Tasks
(
    p_api_version                       IN           NUMBER,
    p_init_msg_list                     IN           VARCHAR2     DEFAULT fnd_api.g_false,
    p_commit                            IN           VARCHAR2     DEFAULT fnd_api.g_false,
    p_validation_level                  IN           NUMBER       DEFAULT fnd_api.g_valid_level_full,
    p_incident_id                       IN           NUMBER,
    p_service_request_rec               IN           Cs_ServiceRequest_PVT.Service_Request_rec_type,
    p_task_template_group_owner         IN           NUMBER,
    p_task_tmpl_group_owner_type    IN           VARCHAR2,
    p_task_template_group_rec           IN           JTF_TASK_INST_TEMPLATES_PUB.task_template_group_info,
    p_task_template_table               IN           JTF_TASK_INST_TEMPLATES_PUB.task_template_info_tbl,
    x_auto_task_gen_rec                 OUT  NOCOPY  Cs_AutoGen_Task_PVT.auto_task_gen_rec_type,
    x_return_status                     OUT  NOCOPY  VARCHAR2,
    x_msg_count                         OUT  NOCOPY  NUMBER,
    x_msg_data                          OUT  NOCOPY  VARCHAR2
    )
IS

  l_api_name                  		CONSTANT VARCHAR2(30) := 'Auto_Generate_Tasks';
  l_api_name_full             		CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

  l_api_version               		CONSTANT NUMBER := 1.0;

  l_field_service_task_created		BOOLEAN;
  l_return_status			VARCHAR2(30);

  l_task_template_search_rec		CS_AutoGen_Task_PVT.Task_Template_Search_Rec_Type;
  l_task_template_group_tbl		Cs_AutoGen_Task_PVT.Task_Template_Group_Tbl_Type;
  l_task_template_table			JTF_TASK_INST_TEMPLATES_PUB.task_template_info_tbl;
  l_task_template_group_rec		JTF_TASK_INST_TEMPLATES_PUB.task_template_group_info;
  l_task_template_group_owner		NUMBER := NULL;
  l_task_tmpl_group_owner_type	        VARCHAR2(240) := NULL;

  l_tbl_index				BINARY_INTEGER := 0;
  l_tbl_ind				BINARY_INTEGER := 0;
  l_find_task_tmpl			BOOLEAN := FALSE;
  l_call_create_task_api		BOOLEAN := FALSE;

  l_planned_uom_value                     varchar2(30); -- 12.1.2 SHACHOUD
  l_planned_effort_value                  number; -- 12.1.2 SHACHOUD

  Cursor c_get_task_templates (p_task_template_group_id NUMBER)
  Is
  Select *
  From Jtf_Task_Templates_vl
  Where Task_Group_Id = p_task_template_group_id
  And nvl(deleted_flag,'N') = 'N'; -- Bug 6429514

  Cursor c_get_task_tmpl_grp_info (p_task_template_group_id NUMBER)
  Is
  Select *
  From Jtf_Task_Temp_Groups_vl
  Where Task_Template_Group_Id = p_task_template_group_id;

  l_get_task_tmpl_grp_info_rec		c_get_task_tmpl_grp_info%ROWTYPE;

  l_task_tmpl_groups_found		VARCHAR2(500) := ' - ';

  Many_Task_Tmpl_Found			EXCEPTION;

  Task_Creation_Failed			EXCEPTION;
  l_planned_end_date			DATE; -- 12.1.2 SR Task Enhancement Project

BEGIN
   -- Declare a savepoint to rollback to in case of errors in task creation.
   -- API standard start of API saveponit

      SAVEPOINT CS_AutoGen_Task_PVT ;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
						l_api_name, G_PKG_NAME) THEN
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_task_template_group_owner	:= p_task_template_group_owner;
   l_task_tmpl_group_owner_type := p_task_tmpl_group_owner_type;

   -- Check if task template group is provided
   If p_task_template_group_rec.task_template_group_id IS NOT NULL Then

     -- Populate the local variables with the passed values
     -- These local variables will be passed to the Create Task From Template API later
     l_task_template_group_rec	:= p_task_template_group_rec;

     -- Check if any task templates are passed
     If p_task_template_table.count > 0 Then
       l_task_template_table		:= p_task_template_table;

       -- Set flag to Call Create Task from Template API to TRUE
       l_call_create_task_api := TRUE;

      Else
        -- Set flag to determine task templates from task template group to TRUE
        l_find_task_tmpl := TRUE;

      End If; -- If p_task_template_table.count > 0

      -- Check if the following attributes are passed. If not, populate them with their default values.

      l_task_template_group_rec.source_object_id	:= p_incident_id ;
      l_task_template_group_rec.source_object_name	:= 'Service Request'; -- this object name is used in jtf_objects_vl for object code 'SR'
      l_task_template_group_rec.cust_account_id		:= nvl(p_service_request_rec.account_id,l_task_template_group_rec.cust_account_id);
      l_task_template_group_rec.customer_id		:= nvl(p_service_request_rec.customer_id,l_task_template_group_rec.customer_id);

   Else

      -- Populate the task template search rec type to be passed to the Get Task Template Group API
      l_task_template_search_rec.incident_type_id	:= p_service_request_rec.type_id;
      l_task_template_search_rec.organization_id	:= p_service_request_rec.inventory_org_id;
      l_task_template_search_rec.inventory_item_id	:= p_service_request_rec.inventory_item_id;
      l_task_template_search_rec.category_id		:= p_service_request_rec.category_id;
      l_task_template_search_rec.problem_code		:= p_service_request_rec.problem_code;

      -- Determine the task template group by calling the Get Task Template Group API


      CS_Autogen_Task_PVT.Get_Task_Template_Group
      (  p_api_version			=>	1.0,
         p_init_msg_list		=>	fnd_api.g_false,
         p_commit			=>	p_commit,
         p_validation_level		=>	p_validation_level,
         p_task_template_search_rec	=>	l_task_template_search_rec,
         x_task_template_group_tbl	=>	l_task_template_group_tbl,
         x_return_status		=>	l_return_status,
         x_msg_count			=>	x_msg_count,
         x_msg_data			=>	x_msg_data
       );


       If (l_return_status = FND_API.G_RET_STS_ERROR) Then
         Raise FND_API.G_EXC_ERROR;
       Elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) Then
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
       End If;

       -- Check the number of task template groups returned by the Get Task Template Group API
       -- If l_task_template_group_tbl.count > 0 Then
         While l_tbl_index < l_task_template_group_tbl.count
         Loop
           -- Retrieve the Task Template Group Information
           Open c_get_task_tmpl_grp_info (l_task_template_group_tbl(l_tbl_index).task_template_group_id);
           Fetch c_get_task_tmpl_grp_info Into l_get_task_tmpl_grp_info_rec;
           -- Populate local record type variable to be passed to Create Task From Template API with the Task Template Group Information
           If c_get_task_tmpl_grp_info%FOUND Then
             l_task_template_group_rec.task_template_group_id	:= l_get_task_tmpl_grp_info_rec.task_template_group_id;
             l_task_template_group_rec.source_object_id	:= p_incident_id;
             l_task_template_group_rec.source_object_name	:= 'Service Request'; -- this object name is used in jtf_objects_vl for object code 'SR'
             l_task_template_group_rec.cust_account_id		:= p_service_request_rec.account_id;
             l_task_template_group_rec.customer_id		:= p_service_request_rec.customer_id;
             l_task_template_group_rec.attribute1		:= l_get_task_tmpl_grp_info_rec.attribute1;
             l_task_template_group_rec.attribute2		:= l_get_task_tmpl_grp_info_rec.attribute2;
             l_task_template_group_rec.attribute3		:= l_get_task_tmpl_grp_info_rec.attribute3;
             l_task_template_group_rec.attribute4		:= l_get_task_tmpl_grp_info_rec.attribute4;
             l_task_template_group_rec.attribute5		:= l_get_task_tmpl_grp_info_rec.attribute5;
             l_task_template_group_rec.attribute6		:= l_get_task_tmpl_grp_info_rec.attribute6;
             l_task_template_group_rec.attribute7		:= l_get_task_tmpl_grp_info_rec.attribute7;
             l_task_template_group_rec.attribute8		:= l_get_task_tmpl_grp_info_rec.attribute8;
             l_task_template_group_rec.attribute9		:= l_get_task_tmpl_grp_info_rec.attribute9;
             l_task_template_group_rec.attribute10		:= l_get_task_tmpl_grp_info_rec.attribute10;
             l_task_template_group_rec.attribute11		:= l_get_task_tmpl_grp_info_rec.attribute11;
             l_task_template_group_rec.attribute12		:= l_get_task_tmpl_grp_info_rec.attribute12;
             l_task_template_group_rec.attribute13		:= l_get_task_tmpl_grp_info_rec.attribute13;
             l_task_template_group_rec.attribute14		:= l_get_task_tmpl_grp_info_rec.attribute14;
             l_task_template_group_rec.attribute15		:= l_get_task_tmpl_grp_info_rec.attribute15;
             l_task_template_group_rec.attribute_category	:= l_get_task_tmpl_grp_info_rec.attribute_category;

             IF p_service_request_rec.incident_location_type = 'HZ_PARTY_SITE' THEN
                l_task_template_group_rec.address_id  := p_service_request_rec.incident_location_id;
             ELSIF  p_service_request_rec.incident_location_type = 'HZ_LOCATION' THEN
                l_task_template_group_rec.customer_id := null;
                l_task_template_group_rec.address_id  := null;
                l_task_template_group_rec.location_id :=  p_service_request_rec.incident_location_id;
             END IF ;


             -- Concatenate the task template group name to the local variable to be returned with error message if multiple templates are found
             -- Add a comma at the end of the concatenated string if there are multiple template groups
             If l_tbl_index > 0 Then
               l_task_tmpl_groups_found			:= l_task_tmpl_groups_found || ', ';
             End If; -- If l_tbl_index > 0

             l_task_tmpl_groups_found			:= l_task_tmpl_groups_found || l_get_task_tmpl_grp_info_rec.template_group_name;

           End If; -- If c_get_task_tmpl_grp_info%FOUND
           -- Increment the table index (which is also a counter for number of task templates found) by 1
           l_tbl_index := l_tbl_index + 1;
           -- Close the cursor
           Close c_get_task_tmpl_grp_info;
         End Loop;

       -- End If; -- If l_task_template_group_tbl.count > 0

       If l_tbl_index = 0 Then
       -- No task template groups are found
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_auto_task_gen_rec.auto_task_gen_attempted := FALSE;

       Elsif l_tbl_index > 1 Then
         -- Multiple task template groups are found
         -- Modified error handling logic --anmukher --08/22/03
         x_auto_task_gen_rec.auto_task_gen_attempted := TRUE;
         Raise Many_Task_Tmpl_Found;

       Elsif l_tbl_index = 1 Then
       -- Only one task template group is found
       -- Set flag to determine task templates from task template group to TRUE
         l_find_task_tmpl := TRUE;

       End If; -- If l_tbl_index = 0

   End If; -- If p_task_template_group_rec.task_template_group_id IS NOT NULL

   If l_find_task_tmpl = TRUE Then

     -- Need to determine the task templates based on the task template group
     -- l_tbl_index := 0; -- l_tbl_index is the index for l_task_template_group_tbl, l_tbl_ind is the index for l_task_template_table

     -- Open cursor (in For Loop) to retrieve the task templates
     l_tbl_ind := 1 ;

     For l_task_tmpl_rec IN c_get_task_templates (l_task_template_group_rec.task_template_group_id)
     Loop

       -- Populate the local table type variable which will be passed to the Create Task from template API
       l_task_template_table(l_tbl_ind).task_template_id 	:= l_task_tmpl_rec.task_template_id;
       l_task_template_table(l_tbl_ind).task_name		:= l_task_tmpl_rec.task_name;
       l_task_template_table(l_tbl_ind).description		:= l_task_tmpl_rec.description;
       l_task_template_table(l_tbl_ind).task_type_id		:= l_task_tmpl_rec.task_type_id;
       l_task_template_table(l_tbl_ind).task_status_id		:= l_task_tmpl_rec.task_status_id;
       l_task_template_table(l_tbl_ind).task_priority_id	:= l_task_tmpl_rec.task_priority_id;
       l_task_template_table(l_tbl_ind).duration		:= l_task_tmpl_rec.duration;
       l_task_template_table(l_tbl_ind).duration_uom		:= l_task_tmpl_rec.duration_uom;
       l_task_template_table(l_tbl_ind).planned_effort		:= l_task_tmpl_rec.planned_effort;
       l_task_template_table(l_tbl_ind).planned_effort_uom	:= l_task_tmpl_rec.planned_effort_uom;
       l_task_template_table(l_tbl_ind).private_flag		:= l_task_tmpl_rec.private_flag;
       l_task_template_table(l_tbl_ind).restrict_closure_flag	:= l_task_tmpl_rec.restrict_closure_flag;
       l_task_template_table(l_tbl_ind).attribute1		:= l_task_tmpl_rec.attribute1;
       l_task_template_table(l_tbl_ind).attribute2		:= l_task_tmpl_rec.attribute2;
       l_task_template_table(l_tbl_ind).attribute3		:= l_task_tmpl_rec.attribute3;
       l_task_template_table(l_tbl_ind).attribute4		:= l_task_tmpl_rec.attribute4;
       l_task_template_table(l_tbl_ind).attribute5		:= l_task_tmpl_rec.attribute5;
       l_task_template_table(l_tbl_ind).attribute6		:= l_task_tmpl_rec.attribute6;
       l_task_template_table(l_tbl_ind).attribute7		:= l_task_tmpl_rec.attribute7;
       l_task_template_table(l_tbl_ind).attribute8		:= l_task_tmpl_rec.attribute8;
       l_task_template_table(l_tbl_ind).attribute9		:= l_task_tmpl_rec.attribute9;
       l_task_template_table(l_tbl_ind).attribute10		:= l_task_tmpl_rec.attribute10;
       l_task_template_table(l_tbl_ind).attribute11		:= l_task_tmpl_rec.attribute11;
       l_task_template_table(l_tbl_ind).attribute12		:= l_task_tmpl_rec.attribute12;
       l_task_template_table(l_tbl_ind).attribute13		:= l_task_tmpl_rec.attribute13;
       l_task_template_table(l_tbl_ind).attribute14		:= l_task_tmpl_rec.attribute14;
       l_task_template_table(l_tbl_ind).attribute15		:= l_task_tmpl_rec.attribute15;
       l_task_template_table(l_tbl_ind).attribute_category	:= l_task_tmpl_rec.attribute_category;
       l_task_template_table(l_tbl_ind).enable_workflow         := 'Y';

        -- Simplex
        -- Get the value of the confirmation status for all the task types in the task template group
        -- This value is used for validation in create_task_from_template procedure

         l_task_template_table(l_tbl_ind).task_confirmation_status     := l_task_tmpl_rec.task_confirmation_status;

        -- end Simplex

	-- 12.1.2 SR Task Enhancement project
	-- Get the Planned End date based on the Profile
	l_planned_uom_value := l_task_template_table(l_tbl_ind).planned_effort_uom;
        l_planned_effort_value := l_task_template_table(l_tbl_ind).planned_effort;

         if ( l_planned_uom_value = 'DAY') then
          l_planned_effort_value := l_planned_effort_value +1;
         end if;

	 CS_AutoGen_Task_PVT.Default_Planned_End_Date(p_service_request_rec.obligation_date,
						      p_service_request_rec.exp_resolution_date,
						      l_planned_uom_value,
						      l_planned_effort_value,
						      l_planned_end_date);

	l_task_template_table(l_tbl_ind).planned_start_date := sysdate;
	l_task_template_table(l_tbl_ind).planned_end_date   := l_planned_end_date;
	-- End of 12.1.2 project code

       -- Increment the pl/sql table index by 1
       l_tbl_ind := l_tbl_ind + 1;

     End Loop; -- For l_task_tmpl_rec IN c_get_task_templates (l_task_template_group_rec.task_template_group_id)

     -- Check if any task templates have been retrieved
     If l_tbl_ind > 0 Then
       -- Set flag to Call Create Task from Template API to TRUE
       l_call_create_task_api := TRUE;
     Else
       -- If no task templates are retrieved, then set the task generation attempted flag to FALSE
       x_auto_task_gen_rec.auto_task_gen_attempted := FALSE;
     End If; -- If l_tbl_ind > 0

   End If; -- If l_find_task_tmpl = TRUE

   -- Check if call to Create Task From Template should be made
   If (l_call_create_task_api = TRUE) Then


      -- Call API to create task from template
      Create_Task_From_Template
      ( p_task_template_group_owner	=>	l_task_template_group_owner,
        p_task_tmpl_group_owner_type    =>      l_task_tmpl_group_owner_type,
        p_incident_id                   =>      p_incident_id ,
        p_service_request_rec		=>	p_service_request_rec,
        p_task_template_group_info	=>	l_task_template_group_rec,
        p_task_template_tbl		=>	l_task_template_table,
        x_field_service_task_created	=>	l_field_service_task_created,
        x_return_status			=>	l_return_status,
        x_msg_count			=>	x_msg_count,
        x_msg_data			=>	x_msg_data
      );


      If (l_return_status = FND_API.G_RET_STS_SUCCESS) Then
        x_return_status					:= l_return_status;
        x_auto_task_gen_rec.auto_task_gen_attempted	:= TRUE;
        x_auto_task_gen_rec.field_service_task_created	:= l_field_service_task_created;
      -- Modified error handling logic --anmukher --08/22/03
      Elsif (l_return_status = FND_API.G_RET_STS_ERROR) OR (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) Then
        x_auto_task_gen_rec.auto_task_gen_attempted	:= TRUE;
        Raise Task_Creation_Failed;
      End If;

   End If; -- If (l_call_create_task_api = TRUE)

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

 -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK to CS_AutoGen_Task_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK to CS_AutoGen_Task_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   -- Added new exception handler for mutiple template group error --anmukher -- 08/22/03
   WHEN Many_Task_Tmpl_Found THEN
       ROLLBACK to CS_AutoGen_Task_PVT ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME ('CS', 'CS_SR_TGT_MULTIPLE_TGT_ERROR');
       FND_MESSAGE.SET_TOKEN ('TASK_GROUP_TEMPLATES',l_task_tmpl_groups_found);
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get(
       p_count => x_msg_count,
       p_data  => x_msg_data);

   -- Added new exception handler for auto task creation failure with single template group --anmukher -- 08/22/03
   WHEN Task_Creation_Failed THEN
       ROLLBACK to CS_AutoGen_Task_PVT ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Message commented out since Create_Task_From_Template API is already
       -- stacking specific error message on failure --anmukher --10/30/2003
       /*
       FND_MESSAGE.SET_NAME ('CS', 'CS_SR_TGT_SINGLE_TGT_ERROR');
       FND_MESSAGE.SET_TOKEN ('TASK_TEMPLATE_GROUP',l_task_tmpl_groups_found);
       FND_MSG_PUB.ADD;
       */
       FND_MSG_PUB.Count_And_Get(
       p_count => x_msg_count,
       p_data  => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK to CS_AutoGen_Task_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      If c_get_task_tmpl_grp_info%IsOpen Then
        close c_get_task_tmpl_grp_info;
      End If;
      If c_get_task_templates%IsOpen Then
        close c_get_task_templates;
      End If;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END Auto_Generate_Tasks;


FUNCTION Get_Task_Template_Status
 ( p_start_date     IN DATE ,
   p_end_date       IN DATE ) RETURN VARCHAR2 IS

l_status   VARCHAR2(40) ;

BEGIN
   IF ((TRUNC(sysdate) >= TRUNC(NVL(p_start_date,sysdate))) AND
       (TRUNC(sysdate) <= TRUNC(NVL(p_end_date,sysdate)))) THEN

       l_status := 'Active';

       SELECT meaning
         INTO l_status
         FROM cs_lookups
        WHERE lookup_type = 'CS_SR_TSK_TMPL_STATUS_DISP'
          AND lookup_code = 'ACTIVE' ;
   ELSE
       l_status := 'Inactive';

       SELECT meaning
         INTO l_status
         FROM cs_lookups
        WHERE lookup_type = 'CS_SR_TSK_TMPL_STATUS_DISP'
          AND lookup_code = 'INACTIVE' ;
   END IF;

RETURN l_status ;

EXCEPTION
     WHEN others THEN
          return l_status ;
END Get_Task_Template_Status;



END CS_AutoGen_Task_PVT;

/
