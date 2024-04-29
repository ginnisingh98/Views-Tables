--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_PVT" as
/* $Header: csfvdbfb.pls 120.29.12010000.11 2010/03/18 06:37:19 hhaugeru ship $ */

-- Start of Comments
-- Package name     : CSF_DEBRIEF_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_DEBRIEF_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csfvdbfb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_UPDATE          NUMBER := 1;
G_CREATE          NUMBER := 2;

Procedure validate_start_end(p_labor_start_time           date,
                             p_labor_end_time             date,
                             p_debrief_header_id          NUMBER,
                             P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                             X_Return_Status              OUT NOCOPY  VARCHAR2,
                             X_Msg_Count                  OUT NOCOPY  NUMBER,
    	                     X_Msg_Data                   OUT NOCOPY  VARCHAR2) IS

    l_service_request_date date;

     Cursor get_service_request_date IS
     select nvl(incident_occurred_date,incident_date)
     from  jtf_task_assignments jta , cs_incidents_all cia, jtf_tasks_b jtb,
           csf_debrief_headers cdh
     where jta.task_assignment_id = cdh.task_assignment_id
     and jtb.task_id = jta.task_id
     and cia.incident_id = jtb.source_object_id
     and jtb.source_object_type_code = 'SR'
     and cdh.debrief_header_id = p_debrief_header_id;

BEGIN
		X_Return_Status := FND_API.G_RET_STS_SUCCESS;
        open  get_service_request_date;
        fetch get_service_request_date INTO l_service_request_date;
        close get_service_request_date;

        If (p_labor_start_time IS NOT NULL
            and p_labor_end_time IS NOT NULL
            and p_labor_start_time <> FND_API.g_miss_date
            and p_labor_end_time <> FND_API.g_miss_date
            AND  p_labor_start_time > p_labor_end_time) THEN
                X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_LABOR_START_DATE_ERR');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;
        If p_labor_start_time IS NOT NULL
            and p_labor_start_time <> FND_API.g_miss_date
           and trunc(fnd_timezones_pvt.adjust_datetime(p_labor_start_time,
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID'))))
             > trunc(fnd_timezones_pvt.adjust_datetime(sysdate,
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')))) THEN
                X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSFW_SERVICE_DATE');
             fnd_message.set_token('P_SR_DATE',to_char(fnd_timezones_pvt.adjust_datetime(l_service_request_date,
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID'))),'DD-Mon-RRRR HH24:MI'));
             fnd_message.set_token('P_SYSTEM_DATE',to_char(trunc(fnd_timezones_pvt.adjust_datetime(sysdate,
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')))),'DD-Mon-RRRR')||' 23:59');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;
        If p_labor_end_time IS NOT NULL
            and p_labor_end_time <> FND_API.g_miss_date
           and trunc(fnd_timezones_pvt.adjust_datetime(p_labor_end_time,
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID'))))
             > trunc(fnd_timezones_pvt.adjust_datetime(sysdate,
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')))) THEN
                X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSFW_SERVICE_DATE_END');
             fnd_message.set_token('P_SR_DATE',to_char(fnd_timezones_pvt.adjust_datetime(l_service_request_date,
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID'))),'DD-Mon-RRRR HH24:MI'));
             fnd_message.set_token('P_SYSTEM_DATE',to_char(trunc(fnd_timezones_pvt.adjust_datetime(sysdate,
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')))),'DD-Mon-RRRR')||' 23:59');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;

         If (p_labor_start_time IS NOT NULL
            and p_labor_start_time <> FND_API.g_miss_date
            and p_labor_start_time < l_service_request_date) THEN
                X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSFW_SERVICE_DATE');
             fnd_message.set_token('P_SR_DATE',to_char(fnd_timezones_pvt.adjust_datetime(l_service_request_date,
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID'))),'DD-Mon-RRRR HH24:MI'));
             fnd_message.set_token('P_SYSTEM_DATE',to_char(trunc(fnd_timezones_pvt.adjust_datetime(sysdate,
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')))),'DD-Mon-RRRR')||' 23:59');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;
        If (p_labor_end_time IS NOT NULL
            and p_labor_end_time <> FND_API.g_miss_date
            and p_labor_end_time < l_service_request_date) THEN
                X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSFW_SERVICE_DATE_END');
             fnd_message.set_token('P_SR_DATE',to_char(fnd_timezones_pvt.adjust_datetime(l_service_request_date,
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID'))),'DD-Mon-RRRR HH24:MI'));
             fnd_message.set_token('P_SYSTEM_DATE',to_char(trunc(fnd_timezones_pvt.adjust_datetime(sysdate,
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')))),'DD-Mon-RRRR')||' 23:59');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;
END;

PROCEDURE Create_debrief(
    P_Api_Version_Number	IN   NUMBER,
    P_Init_Msg_List        	IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit               	IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_DEBRIEF_Rec     	   	IN   DEBRIEF_Rec_Type  := G_MISS_DEBRIEF_REC,
    P_DEBRIEF_LINE_tbl          IN   DEBRIEF_LINE_tbl_type
								:= G_MISS_DEBRIEF_LINE_tbl,
    X_DEBRIEF_HEADER_ID    	OUT NOCOPY  NUMBER,
    X_Return_Status        	OUT NOCOPY  VARCHAR2,
    X_Msg_Count            	OUT NOCOPY  NUMBER,
    X_Msg_Data            	OUT NOCOPY  VARCHAR2
    )
IS
        G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
        G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
	l_row_id		    varchar2(100) := null;
	l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Debrief';
	l_api_version_number        CONSTANT NUMBER   := 1.0;
	l_return_status             VARCHAR2(1);
	l_count                     NUMBER :=  p_Debrief_line_tbl.count;
	l_DEBRIEF_HEADER_ID             NUMBER;
	l_service_date		 date;
	l_debrief_number         varchar2(50);
	l_interaction_rec       	JTF_IH_PUB.INTERACTION_REC_TYPE;
	l_activity_rec           	JTF_IH_PUB.ACTIVITY_REC_TYPE;
	l_resource_id           number;
	l_task_id               number;
	l_party_id              number;
	l_task_assignment_id 	number ;
	l_cust_account_id      	number;
	l_msg_count            	number;
	l_msg_data              varchar2(2000);
	l_interaction_id       	number;
	l_activity_id           number;
	x                       number;
	l_msg_index_out         number;
	l_source_object_type_code varchar2(30);
	errbuf                  Varchar2(1000);
	retcode                 Number;
	l_Unit_Of_Measure_For_Hr varchar2(3);
	l_oject_version_number  NUMBER;
	l_actual_travel_duration NUMBER;
	l_resource_type_code    VARCHAR2(30);
    l_task_object_version   NUMBER := null;
    l_task_status_id        NUMBER := null;

	cursor c_source_object_type_code (p_task_assignment_id number) is
           select jtv.source_object_type_code
           from   jtf_tasks_vl jtv,
                  jtf_task_assignments_v jta
           where  jta.task_assignment_id = p_task_assignment_id
           and    jta.task_id            = jtv.task_id;

    cursor c_task_assgin_object_version is
    select jta.object_version_number, jta.resource_type_code, jta.resource_id
    from   jtf_task_assignments jta
    where  jta.task_assignment_id = p_debrief_rec.TASK_ASSIGNMENT_ID;

BEGIN


      -- Standard Start of API savepoint

      SAVEPOINT CREATE_DEBRIEF_HEADER_PVT;
      -- Standard call to check for call compatibility.

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


		 -- Debug Message
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
           THEN
               FND_MESSAGE.Set_Name('CSF', l_api_name);
               FND_MESSAGE.Set_Token ('INFO', G_PKG_NAME, FALSE);
               FND_MSG_PUB.Add;

           END IF;

      -- Initialize API return status to SUCCESS
      X_Return_Status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************

        -- Virendra Singh 03/24/2000 check whether Header record is missing
        if IS_DEBRIEF_HEADER_REC_MISSING(P_DEBRIEF_REC) then

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                fnd_message.set_name('CSF', 'CSF_DEBRIEF_MISSING_HEADER');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        end if;
          -- Invoke validation procedures

     IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN

          Validate_DEBRIEF_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => G_CREATE,
              p_DEBRIEF_DATE            => P_DEBRIEF_Rec.DEBRIEF_DATE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
      	    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	        x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
          END IF;

	   Validate_Task_Assignment_Id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => G_CREATE,
              p_Task_Assignment_Id     => P_DEBRIEF_Rec.Task_Assignment_Id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
           END IF;
      END IF;
      -- Debug Message
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
           THEN
               FND_MESSAGE.Set_Name('CSF', l_api_name);
               FND_MESSAGE.Set_Token ('INFO', G_PKG_NAME, FALSE);
               FND_MSG_PUB.Add;
           END IF;

      -- Invoke table handler(debrief_Insert_Row)


        l_debrief_header_id  := p_debrief_rec.debrief_header_id;
        l_debrief_number     := p_debrief_rec.debrief_number;

        if (l_debrief_header_id<>FND_API.G_MISS_NUM) and (l_debrief_header_id is not NULL) then
            begin
                select 1 into x
                from CSF_DEBRIEF_HEADERS
                where DEBRIEF_HEADER_ID = l_DEBRIEF_HEADER_ID ;

                fnd_message.set_name('CSF', 'CSF_DEBRIEF_INVALID_HEADER');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            exception
                when no_data_found then
                    null ;
                when too_many_rows then
                    fnd_message.set_name('CSF', 'CSF_DEBRIEF_INVALID_HEADER');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
            end ;


            if (l_debrief_number <>FND_API.G_MISS_CHAR) and (l_debrief_number is not null) then
               null;
            else
                SELECT CSF_DEBRIEF_HEADERS_S2.nextval
                INTO l_debrief_number
                FROM dual;
            end if;
        ELSE
            SELECT CSF_DEBRIEF_HEADERS_S1.nextval
              INTO l_debrief_header_id
              FROM dual;
              if (l_debrief_number <>FND_API.G_MISS_CHAR) and (l_debrief_number is not null) then
                  null;
              else
                  SELECT CSF_DEBRIEF_HEADERS_S2.nextval
                  INTO l_debrief_number
                  FROM dual;
              end if;
        END IF;
        X_DEBRIEF_HEADER_ID:=l_debrief_header_id;
        validate_travel_times(p_debrief_rec.TRAVEL_START_TIME,
                               p_debrief_rec.TRAVEL_END_TIME,
                               p_debrief_rec.task_assignment_id,
                               fnd_api.g_false,
                               X_Return_Status,
                               X_Msg_Count,
                               X_Msg_Data);
        if  X_Return_Status  <> FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;

        open c_task_assgin_object_version ;
        fetch c_task_assgin_object_version INTO l_oject_version_number,
                                                l_resource_type_code,
                                                l_resource_id;
        CLOSE c_task_assgin_object_version ;

        l_unit_of_measure_for_hr := fnd_profile.value('CSF_UOM_HOURS');
        IF  (p_debrief_rec.TRAVEL_START_TIME  IS NOT NULL AND p_debrief_rec.TRAVEL_START_TIME <> FND_API.G_MISS_DATE)
          AND (p_debrief_rec.TRAVEL_END_TIME IS NOT NULL AND p_debrief_rec.TRAVEL_END_TIME  <> FND_API.G_MISS_DATE)
          THEN
            l_actual_travel_duration := round ((p_debrief_rec.TRAVEL_END_TIME - p_debrief_rec.TRAVEL_START_TIME) * 24,2);
        END IF;
        if  (p_debrief_rec.TRAVEL_DISTANCE_IN_KM IS NOT NULL AND p_debrief_rec.TRAVEL_DISTANCE_IN_KM<> FND_API.G_MISS_NUM) THEN
               csf_task_assignments_pub.update_task_assignment(
          p_api_version                => 1.0,
          x_return_status              => x_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_Data,
          p_task_assignment_id         => p_debrief_rec.task_assignment_id,
          p_object_version_number      => l_oject_version_number,
          p_actual_travel_distance     => p_debrief_rec.TRAVEL_DISTANCE_IN_KM ,
          p_actual_travel_duration     => l_actual_travel_duration,
          p_actual_travel_duration_uom => l_unit_of_measure_for_hr,
          p_resource_type_code         => l_resource_type_code,
          p_resource_id                => l_resource_id,
          x_task_object_version_number => l_task_object_version,
          x_task_status_id             => l_task_status_id);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;
      	csf_debrief_headers_pkg.Insert_Row(
            PX_DEBRIEF_HEADER_ID		=> l_debrief_header_id,
            P_DEBRIEF_NUMBER		=> l_debrief_number,
    	    P_DEBRIEF_DATE		    => p_debrief_rec.debrief_date,
            P_DEBRIEF_STATUS_ID  	=> p_debrief_rec.DEBRIEF_STATUS_ID,
            P_TASK_ASSIGNMENT_ID	=> p_debrief_rec.TASK_ASSIGNMENT_ID,
            P_CREATED_BY  		    => nvl(p_debrief_rec.created_by,G_USER_ID),
            P_CREATION_DATE  		=> nvl(p_debrief_rec.creation_date,SYSDATE),
            P_LAST_UPDATED_BY  		=> nvl(p_debrief_rec.last_updated_by,G_USER_ID),
            P_LAST_UPDATE_DATE  	=> nvl(p_debrief_rec.last_update_date,SYSDATE),
            P_LAST_UPDATE_LOGIN  	=> nvl(p_debrief_rec.last_update_login,G_LOGIN_ID),
            P_ATTRIBUTE1  		    => p_debrief_rec.ATTRIBUTE1 ,
            P_ATTRIBUTE2  		    => p_debrief_rec.ATTRIBUTE2 ,
            P_ATTRIBUTE3  		    => p_debrief_rec.ATTRIBUTE3 ,
            P_ATTRIBUTE4  		    => p_debrief_rec.ATTRIBUTE4 ,
            P_ATTRIBUTE5  		    => p_debrief_rec.ATTRIBUTE5 ,
            P_ATTRIBUTE6  		    => p_debrief_rec.ATTRIBUTE6 ,
            P_ATTRIBUTE7  		    => p_debrief_rec.ATTRIBUTE7 ,
            P_ATTRIBUTE8  		    => p_debrief_rec.ATTRIBUTE8 ,
            P_ATTRIBUTE9  		    => p_debrief_rec.ATTRIBUTE9 ,
            P_ATTRIBUTE10  		    => p_debrief_rec.ATTRIBUTE10 ,
            P_ATTRIBUTE11  		    => p_debrief_rec.ATTRIBUTE11 ,
            P_ATTRIBUTE12  		    => p_debrief_rec.ATTRIBUTE12 ,
            P_ATTRIBUTE13  		    => p_debrief_rec.ATTRIBUTE13 ,
            P_ATTRIBUTE14  		    => p_debrief_rec.ATTRIBUTE14,
            P_ATTRIBUTE15  		    => p_debrief_rec.ATTRIBUTE15,
            P_ATTRIBUTE_CATEGORY  	=> p_debrief_rec.ATTRIBUTE_CATEGORY,
            p_object_version_number => p_debrief_rec.object_version_number,
            p_TRAVEL_START_TIME     =>p_debrief_rec.TRAVEL_START_TIME,
            p_TRAVEL_END_TIME       =>p_debrief_rec.TRAVEL_END_TIME,
            p_TRAVEL_DISTANCE_IN_KM =>p_debrief_rec.TRAVEL_DISTANCE_IN_KM
            );

     --Virendra Singh 03/28/2000 commented out
   -- create Interaction  04/06/2000
  /*CSF_DEBRIEF_PVT.Create_Interaction (P_Api_Version_Number         =>1.0,
                       P_Init_Msg_List              =>FND_API.G_FALSE,
                       P_Commit                     =>FND_API.G_FALSE,
                       P_TASK_ASSIGNMENT_ID         =>P_DEBRIEF_REC.TASK_ASSIGNMENT_ID,
                       P_DEBRIEF_HEADER_ID             =>l_debrief_header_id,
                       P_MEDIA_ID                   =>29386,
                       P_ACTION_ID                  =>22,
                       X_RETURN_STATUS              =>l_return_status,
                       X_Msg_Count                  =>X_MSG_COUNT,
                       X_Msg_Data                   =>X_MSG_DATA);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  */
  open c_source_object_type_code (p_debrief_rec.TASK_ASSIGNMENT_ID);
  fetch c_source_object_type_code into l_source_object_type_code;
  close c_source_object_type_code;

  IF P_DEBRIEF_LINE_TBL.count > 0 then
    	CSF_DEBRIEF_PVT.Create_debrief_lines(
   	 P_Api_Version_Number  	=> 1.0 ,
    	P_Init_Msg_List       	=> FND_API.G_FALSE,
    	P_Commit              	=> FND_API.G_FALSE,
   	 P_Upd_tskassgnstatus      =>   NULL,
    	P_Task_Assignment_status  =>  NULL,
    	p_validation_level    	=> FND_API.G_VALID_LEVEL_FULL,
    	P_DEBRIEF_line_tbl 		=> p_DEBRIEF_line_tbl,
    	P_DEBRIEF_HEADER_ID       => l_DEBRIEF_HEADER_ID,
    	P_SOURCE_OBJECT_TYPE_CODE => l_source_object_type_code,
    	X_Return_Status       	=> l_Return_Status,
    	X_Msg_Count           	=> X_Msg_Count,
    	X_Msg_Data            	=> X_Msg_Data
    	);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


      -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		    ROLLBACK TO CREATE_DEBRIEF_HEADER_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ROLLBACK TO  CREATE_DEBRIEF_HEADER_PVT;

              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

          WHEN OTHERS THEN
		    ROLLBACK TO  CREATE_DEBRIEF_HEADER_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				IF FND_MSG_PUB.Check_Msg_Level
					 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			     THEN
				   FND_MSG_PUB.Add_Exc_Msg (
                   	 G_PKG_NAME
                  	,L_API_NAME );
				 END IF;

				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

End Create_debrief;


-----------------------------------------------------------------------------------------------------------
PROCEDURE Update_debrief(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER        := FND_API.G_VALID_LEVEL_FULL,
    P_DEBRIEF_Rec     		 IN   DEBRIEF_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS


G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_api_name                CONSTANT VARCHAR2(30) := 'Update_debrief';
l_api_version_number      CONSTANT NUMBER   := 1.0;

-- Local Variables

l_ref_DEBRIEF_rec  CSF_DEBRIEF_PVT.DEBRIEF_Rec_Type;
l_tar_DEBRIEF_rec  CSF_DEBRIEF_PVT.DEBRIEF_Rec_Type := p_debrief_rec;
l_rowid  ROWID;
x_row_id  varchar2(100) := null;
l_task_assignment_id   number;
l_assignment_status_id  number;
l_actual_start_date     date;
l_actual_end_date       date;
l_debrief_header_id     number;
l_counter               number;
l_Unit_Of_Measure_For_Hr varchar2(3);
	l_oject_version_number  NUMBER;
	l_actual_travel_duration NUMBER;
	l_resource_type_code varchar2(30) := null;
	l_resource_id        number := null;
    l_task_object_version number := null;
    l_task_status_id      number := null;

    cursor c_task_assgin_object_version is
  select jta.object_version_number,
         jta.resource_type_code,
         jta.resource_id
  from   jtf_task_assignments jta
  where  jta.task_assignment_id = p_debrief_rec.TASK_ASSIGNMENT_ID;

 BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_DEBRIEF_PVT;
      -- Standard call to check for call compatibility.

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_debrief_header_id:=l_tar_DEBRIEF_rec.Debrief_header_id;
        -- Virendra Singh 03/27/2000 check whether Debrief_Header_ID is not null or missging
        if  (l_debrief_header_id =FND_API.G_MISS_NUM) or (l_debrief_header_id is NULL ) then
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                fnd_message.set_name('CSF', 'CSF_DEBRIEF_MISSING_HEADER');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        end if;
          -- Invoke validation procedures


       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN

           IF (l_tar_debrief_rec.DEBRIEF_DATE <> FND_API.G_MISS_DATE) then
              Validate_DEBRIEF_DATE(
                p_init_msg_list          => FND_API.G_FALSE,
                p_validation_mode        => G_CREATE,
                p_DEBRIEF_DATE            => P_DEBRIEF_Rec.DEBRIEF_DATE,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data);
      	       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	          x_return_status := fnd_api.g_ret_sts_unexp_error;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
           END If;

           IF (l_tar_DEBRIEF_rec.task_assignment_id <>FND_API.G_MISS_NUM)  then
	       Validate_Task_Assignment_Id(
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_validation_mode        => G_CREATE,
                 p_Task_Assignment_Id     => P_DEBRIEF_Rec.Task_Assignment_Id,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  RAISE fnd_api.g_exc_unexpected_error;
              END IF;
           END IF;
      END IF;


             validate_travel_times(p_debrief_rec.TRAVEL_START_TIME,
                               p_debrief_rec.TRAVEL_END_TIME,
                               p_debrief_rec.task_assignment_id,
                               fnd_api.g_false,
                               X_Return_Status,
                               X_Msg_Count,
                               X_Msg_Data);
        if  X_Return_Status  <> FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;

        open c_task_assgin_object_version ;
        fetch c_task_assgin_object_version INTO l_oject_version_number,
                                                l_resource_type_code,
                                                l_resource_id;
        CLOSE c_task_assgin_object_version ;

        l_actual_travel_duration := FND_API.G_MISS_NUM;
        IF  (p_debrief_rec.TRAVEL_START_TIME  IS NOT NULL AND p_debrief_rec.TRAVEL_START_TIME <> FND_API.G_MISS_DATE)
          AND (p_debrief_rec.TRAVEL_END_TIME IS NOT NULL AND p_debrief_rec.TRAVEL_END_TIME  <> FND_API.G_MISS_DATE)
          THEN
            l_actual_travel_duration := round ((p_debrief_rec.TRAVEL_END_TIME - p_debrief_rec.TRAVEL_START_TIME) * 24,2);
            l_unit_of_measure_for_hr := fnd_profile.value('CSF_UOM_HOURS');
        END IF;


        if  (p_debrief_rec.TRAVEL_DISTANCE_IN_KM IS NOT NULL AND p_debrief_rec.TRAVEL_DISTANCE_IN_KM<> FND_API.G_MISS_NUM)
             OR ( l_actual_travel_duration IS NOT NULL AND l_actual_travel_duration <> FND_API.G_MISS_NUM ) THEN
          csf_task_assignments_pub.update_task_assignment(
            p_api_version                 => 1.0,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_Data,
            p_task_assignment_id          => p_debrief_rec.task_assignment_id,
            p_object_version_number       => l_oject_version_number,
            p_actual_travel_distance      => p_debrief_rec.TRAVEL_DISTANCE_IN_KM ,
            p_actual_travel_duration      => l_actual_travel_duration,
            p_actual_travel_duration_uom  => l_unit_of_measure_for_hr,
            p_resource_type_code          => l_resource_type_code,
            p_resource_id                 => l_resource_id,
            x_task_object_version_number  => l_task_object_version,
            x_task_status_id              => l_task_status_id);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;


     CSF_DEBRIEF_HEADERS_PKG.Update_Row(
        P_DEBRIEF_HEADER_ID	    => p_debrief_rec.DEBRIEF_HEADER_ID,
		P_DEBRIEF_NUMBER	    => p_debrief_rec.DEBRIEF_NUMBER ,
		P_DEBRIEF_DATE		    => p_debrief_rec.DEBRIEF_DATE,
		P_DEBRIEF_STATUS_ID  	=> p_debrief_rec.DEBRIEF_STATUS_ID  ,
		P_TASK_ASSIGNMENT_ID	=> p_debrief_rec.TASK_ASSIGNMENT_ID,
		P_CREATED_BY  		    => p_debrief_rec.CREATED_BY,
		P_CREATION_DATE  	    => p_debrief_rec.CREATION_DATE,
		P_LAST_UPDATED_BY  	    => nvl(p_debrief_rec.last_updated_by,g_user_id),
        P_LAST_UPDATE_DATE  	=> nvl(p_debrief_Rec.last_update_date,sysdate),
        P_LAST_UPDATE_LOGIN  	=> nvl(p_debrief_rec.last_update_login,g_login_id),
        P_ATTRIBUTE1  		    => p_debrief_rec.ATTRIBUTE1 ,
        P_ATTRIBUTE2  		    => p_debrief_rec.ATTRIBUTE2 ,
        P_ATTRIBUTE3  		    => p_debrief_rec.ATTRIBUTE3 ,
        P_ATTRIBUTE4  		    => p_debrief_rec.ATTRIBUTE4 ,
        P_ATTRIBUTE5  		    => p_debrief_rec.ATTRIBUTE5 ,
        P_ATTRIBUTE6  		    => p_debrief_rec.ATTRIBUTE6 ,
        P_ATTRIBUTE7  		    => p_debrief_rec.ATTRIBUTE7 ,
        P_ATTRIBUTE8  		    => p_debrief_rec.ATTRIBUTE8 ,
        P_ATTRIBUTE9  		    => p_debrief_rec.ATTRIBUTE9 ,
        P_ATTRIBUTE10  		    => p_debrief_rec.ATTRIBUTE10 ,
        P_ATTRIBUTE11  		    => p_debrief_rec.ATTRIBUTE11 ,
        P_ATTRIBUTE12  		    => p_debrief_rec.ATTRIBUTE12 ,
        P_ATTRIBUTE13  		    => p_debrief_rec.ATTRIBUTE13 ,
        P_ATTRIBUTE14  		    => p_debrief_rec.ATTRIBUTE14,
        P_ATTRIBUTE15  		    => p_debrief_rec.ATTRIBUTE15,
	    P_ATTRIBUTE_CATEGORY  	=> p_debrief_rec.ATTRIBUTE_CATEGORY,
	    p_object_version_number => p_debrief_rec.object_version_number,
        p_TRAVEL_START_TIME     =>p_debrief_rec.TRAVEL_START_TIME,
        p_TRAVEL_END_TIME       =>p_debrief_rec.TRAVEL_END_TIME,
        p_TRAVEL_DISTANCE_IN_KM =>p_debrief_rec.TRAVEL_DISTANCE_IN_KM);

   --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

          WHEN OTHERS THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				IF FND_MSG_PUB.Check_Msg_Level
					 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			     THEN
				   FND_MSG_PUB.Add_Exc_Msg (
                   	 G_PKG_NAME
                  	,L_API_NAME );
				 END IF;

				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

End Update_debrief;
-- *******************

-- ********************* Worked till here

-- Lead Lines Starts from here

PROCEDURE Validate_Task_Assignment_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Validation_mode            IN   VARCHAR2,
    	P_TASK_Assignment_ID         IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_name   varchar2(30) := 'Create Debrief' ;
 cursor c is
 select 1
 from JTF_TASK_ASSIGNMENTS
 where TASK_ASSIGNMENT_ID=P_TASK_ASSIGNMENT_ID;

 l_dummy    number;
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
     -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_task_assignment_id is NULL OR p_task_assignment_id = FND_API.G_MISS_NUM) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_INVALID_TA_ID');
              FND_MSG_PUB.ADD;
          END IF;
      ELSE
          open c;
          fetch c into l_dummy;
          if c%notfound then
             close c;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
               FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_INVALID_TA_ID');
               FND_MSG_PUB.ADD;
             END IF;
           else
             close c;
           end if;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Task_assignment_ID;


PROCEDURE Validate_Debrief_Date (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Validation_mode            IN   VARCHAR2,
    	P_Debrief_Date	            IN   DATE,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   varchar2(30) := 'Create Debrief' ;
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (p_debrief_date is NULL OR p_debrief_date = FND_API.G_MISS_DATE) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_DEBRIEF_DATE');
              FND_MSG_PUB.ADD;
          END IF;
       END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_Debrief_Date;

Function debrief_type(p_debrief_line_rec debrief_line_rec_type)
    return varchar2 is

  l_debrief_type        varchar2(3);
  l_valid_org           number := fnd_profile.value('CS_INV_VALIDATION_ORG');

  cursor c_debrief_type is
  select billing_category
  from   cs_billing_type_categories cbtc,
         mtl_system_items_b msib
  where  inventory_item_id = p_debrief_line_rec.inventory_item_id
  and    organization_id = l_valid_org  -- changed for bug 4259770
--   nvl(p_debrief_line_rec.issuing_inventory_org_id,    p_debrief_line_rec.receiving_inventory_org_id)
  and    material_billable_flag = billing_type;

begin

  open  c_debrief_type;
  fetch c_debrief_type into l_debrief_type;
  close c_debrief_type;

  if nvl(p_debrief_line_rec.inventory_item_id,fnd_api.g_miss_num) = fnd_api.g_miss_num then
    l_debrief_type := 'L';
  end if;

  return l_debrief_type;

end;

Function IS_DEBRIEF_HEADER_REC_MISSING(P_DEBRIEF_REC    DEBRIEF_REC_TYPE) Return BOOLEAN is
BEGIN
  if P_DEBRIEF_REC.DEBRIEF_HEADER_ID <> FND_API.G_MISS_NUM then
     Return FALSE;
  elsif P_DEBRIEF_REC.DEBRIEF_NUMBER <>FND_API.G_MISS_CHAR then
     Return FALSE;
  elsif P_DEBRIEF_REC.DEBRIEF_DATE  <>FND_API.G_MISS_DATE then
     Return FALSE;
  elsif P_DEBRIEF_REC.DEBRIEF_STATUS_ID  <>FND_API.G_MISS_NUM then
     Return FALSE;
  elsif P_DEBRIEF_REC.TASK_ASSIGNMENT_ID  <>FND_API.G_MISS_NUM then
     Return FALSE;
  elsif P_DEBRIEF_REC.CREATED_BY          <>FND_API.G_MISS_NUM then
     Return FALSE;
  elsif P_DEBRIEF_REC.CREATION_DATE        <>FND_API.G_MISS_DATE then
     Return FALSE;
  elsif P_DEBRIEF_REC.LAST_UPDATED_BY        <>FND_API.G_MISS_NUM then
     Return FALSE;
  elsif P_DEBRIEF_REC.LAST_UPDATE_DATE        <>FND_API.G_MISS_DATE then
     Return FALSE;
   elsif P_DEBRIEF_REC.LAST_UPDATE_LOGIN        <>FND_API.G_MISS_NUM then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE1              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE2              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE3              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE4              <>FND_API.G_MISS_CHAR then
     Return FALSE;
    elsif P_DEBRIEF_REC.ATTRIBUTE5              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE6              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE7             <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE8              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE9              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE10              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE11              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE12              <>FND_API.G_MISS_CHAR then
     Return FALSE;
    elsif P_DEBRIEF_REC.ATTRIBUTE13              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE14              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE15              <>FND_API.G_MISS_CHAR then
     Return FALSE;
   elsif P_DEBRIEF_REC.ATTRIBUTE_CATEGORY       <>FND_API.G_MISS_CHAR then
     Return FALSE;
   else
     return TRUE;
   end if;
 End Is_DEBRIEF_HEADER_REC_MISSING;












PROCEDURE Create_debrief_lines(
	P_Api_Version_Number         IN   NUMBER,
    	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
        P_Upd_tskassgnstatus         IN   VARCHAR2     ,
        P_Task_Assignment_status     IN   VARCHAR2     ,
    	p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    	P_DEBRIEF_LINE_tbl           IN   DEBRIEF_LINE_tbl_type,
								-- DEFAULT G_MISS_DEBRIEF_LINE_tbl,
    	P_DEBRIEF_HEADER_ID          IN   NUMBER ,
    	P_SOURCE_OBJECT_TYPE_CODE    IN   VARCHAR2,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
  G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
   l_api_name                CONSTANT VARCHAR2(30) := 'Create_debrief_lines';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   x_row_id		varchar2(100)  := 100;
  l_request_id                 number;
  l_call_cp                    varchar2(1);
  l_count                  NUMBER     := p_debrief_line_tbl.count;
  p_DEBRIEF_LINE_rec       debrief_line_rec_type;
  X_DEBRIEF_LINE_ID         Number;
  z_debrief_line_number     number;
  z_start_date		   date;
  z_end_date		   date;
  z_debrief_header_id       number;
  z_task_assignment_id	   number;
  z_resource_id		   number;
  z_location		   mdsys.sdo_geometry;
  z_debrief_line_id 	   number;
  z_object_version_number   NUMBER;
  l_object_version_number   number;
  l_task_id                 number;
  l_task_assignment_id      number;
  l_assignment_status_id    number;
  closed_assignment_count   number;
  l_debrief_line_id         number;
  x                         number;
  l_business_process_id	   number;
  l_billing_type             cs_txn_billing_types.billing_type%type;
  l_task_object_version_number number;
  l_task_status_id          number;
  l_task_status_name        varchar2(200);
  xx_labor_start_date      date;
  xx_labor_end_date        date;
  l_cp_status_id            number;
  l_cp_status              varchar2(30);
  l_return_reason_code     varchar2(30) ;
  l_hr_uom                 varchar2(100) := fnd_profile.value('CSF_UOM_HOURS');
  l_quantity               number;
  l_line_order_category_code varchar2(30);
  l_transaction_type_id      number;
  l_debrief_type	   varchar2(1);
  l_resource_id         number;
  l_resource_type       varchar2(240);
  l_task_number         number;
  l_debrief_number      number;

  cursor c_status(p_debrief_header_id number) is
  select greatest(nvl(rejected_flag,'N'),
                  nvl(completed_flag,'N'),
                  nvl(closed_flag,'N'),
                  nvl(cancelled_flag,'N'))
  from   jtf_task_statuses_b jtsb,
         jtf_task_assignments jta,
         csf_debrief_headers cdh
  where  cdh.debrief_header_id = p_debrief_header_id
  and    jta.task_assignment_id = cdh.task_assignment_id
  and    jtsb.task_status_id = jta.assignment_status_id;

  cursor c_cp_status(p_transaction_type_id number) is
  	 select ctst.src_status_id
  	 from   csi_txn_sub_types ctst ,
         cs_transaction_types_vl  cttv
         where ctst.cs_transaction_type_id = cttv.transaction_type_id
         and    cttv.transaction_type_id = p_transaction_type_id;

  cursor c_cp_status_notnull (p_cp_status varchar2) is
         select instance_status_id
         from   csi_instance_statuses
         where  name = p_cp_status;

  cursor labor_uom(p_inventory_item_id number) is
  select primary_uom_code
  from   mtl_system_items_b
  where  inventory_item_id = p_inventory_item_id;

  cursor c_txn_billing_type_id (p_txn_billing_type_id number) is
  	select ctbt.billing_type,
               cttv.line_order_category_code,
               cttv.transaction_type_id
  	from   cs_transaction_types_vl cttv,
               cs_txn_billing_types ctbt
  	where  ctbt.txn_billing_type_id = p_txn_billing_type_id
  	and    ctbt.transaction_type_id = cttv.transaction_type_id;

  cursor c_transaction_type_id (p_transaction_type_id number,
                                p_inventory_item_id   number) is
         select ctbt.billing_type,
                cttv.line_order_category_code
         from   cs_transaction_types_vl cttv,
                cs_txn_billing_types    ctbt,
                mtl_system_items_b_kfv  msibk
         where  cttv.transaction_type_id     = p_transaction_type_id
            	and cttv.transaction_type_id     = ctbt.transaction_type_id
            	and ctbt.billing_type            = msibk.material_billable_flag
            	and msibk.inventory_item_id      = p_inventory_item_id;


BEGIN

      z_debrief_line_number  :=   	p_debrief_line_tbl(1).debrief_line_number  ;

      -- Standard Start of API savepoint

      SAVEPOINT CREATE_DEBRIEF_LINE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     FOR l_curr_row  in 1..l_count
       LOOP
         BEGIN
            z_debrief_line_number   :=  p_debrief_line_tbl(l_curr_row).debrief_line_number  ;
            z_debrief_line_id	    :=	p_debrief_line_tbl(l_curr_row).debrief_line_id ;
            z_debrief_header_id	    :=	p_debrief_line_tbl(l_curr_row).debrief_header_id ;
            z_start_date	    :=	p_debrief_line_tbl(l_curr_row).labor_start_date;
	    z_end_date		    :=	p_debrief_line_tbl(l_curr_row).labor_end_date;

	    p_debrief_line_rec.DEBRIEF_LINE_ID  		:= 	p_debrief_line_tbl(l_curr_row).DEBRIEF_LINE_ID ;
	    p_debrief_line_rec.DEBRIEF_HEADER_ID  		:= 	p_debrief_line_tbl(l_curr_row).DEBRIEF_HEADER_ID;
	    p_debrief_line_rec.DEBRIEF_LINE_NUMBER		:=	p_debrief_line_tbl(l_curr_row).DEBRIEF_LINE_NUMBER;
	    p_debrief_line_rec.SERVICE_DATE              	:=	p_debrief_line_tbl(l_curr_row).SERVICE_DATE    ;
	    p_debrief_line_rec.BUSINESS_PROCESS_ID        	:=    p_debrief_line_tbl(l_curr_row).BUSINESS_PROCESS_ID    ;
	    p_debrief_line_rec.TXN_BILLING_TYPE_ID        	:=    p_debrief_line_tbl(l_curr_row).TXN_BILLING_TYPE_ID    ;
	    p_debrief_line_rec.INVENTORY_ITEM_ID           	:=    p_debrief_line_tbl(l_curr_row).INVENTORY_ITEM_ID     ;
        p_debrief_line_rec.INSTANCE_ID           	:=    p_debrief_line_tbl(l_curr_row).INSTANCE_ID     ;
	    p_debrief_line_rec.ISSUING_INVENTORY_ORG_ID    	:=    p_debrief_line_tbl(l_curr_row).ISSUING_INVENTORY_ORG_ID  ;
	    p_debrief_line_rec.RECEIVING_INVENTORY_ORG_ID   :=    p_debrief_line_tbl(l_curr_row).RECEIVING_INVENTORY_ORG_ID ;
	    p_debrief_line_rec.ISSUING_SUB_INVENTORY_CODE   :=    p_debrief_line_tbl(l_curr_row).ISSUING_SUB_INVENTORY_CODE ;
	    p_debrief_line_rec.RECEIVING_SUB_INVENTORY_CODE :=    p_debrief_line_tbl(l_curr_row).RECEIVING_SUB_INVENTORY_CODE ;
	    p_debrief_line_rec.ISSUING_LOCATOR_ID           :=    p_debrief_line_tbl(l_curr_row).ISSUING_LOCATOR_ID          ;
	    p_debrief_line_rec.RECEIVING_LOCATOR_ID         := 	p_debrief_line_tbl(l_curr_row).RECEIVING_LOCATOR_ID        ;
	    p_debrief_line_rec.PARENT_PRODUCT_ID            :=	p_debrief_line_tbl(l_curr_row).PARENT_PRODUCT_ID           ;
	    p_debrief_line_rec.REMOVED_PRODUCT_ID           :=	p_debrief_line_tbl(l_curr_row).REMOVED_PRODUCT_ID          ;
	    p_debrief_line_rec.STATUS_OF_RECEIVED_PART      :=	p_debrief_line_tbl(l_curr_row).STATUS_OF_RECEIVED_PART     ;
	    p_debrief_line_rec.ITEM_SERIAL_NUMBER           :=    p_debrief_line_tbl(l_curr_row).ITEM_SERIAL_NUMBER          ;
	    p_debrief_line_rec.ITEM_REVISION                :=	p_debrief_line_tbl(l_curr_row).ITEM_REVISION           ;
	    p_debrief_line_rec.ITEM_LOTNUMBER               := 	p_debrief_line_tbl(l_curr_row).ITEM_LOTNUMBER ;
	    p_debrief_line_rec.UOM_CODE                     := 	p_debrief_line_tbl(l_curr_row).UOM_CODE       ;
	    p_debrief_line_rec.QUANTITY                     :=   	p_debrief_line_tbl(l_curr_row).QUANTITY       ;
	    p_debrief_line_rec.RMA_HEADER_ID                :=	p_debrief_line_tbl(l_curr_row).RMA_HEADER_ID  ;
	    p_debrief_line_rec.DISPOSITION_CODE             :=	p_debrief_line_tbl(l_curr_row).DISPOSITION_CODE       ;
	    p_debrief_line_rec.MATERIAL_REASON_CODE         :=	p_debrief_line_tbl(l_curr_row).MATERIAL_REASON_CODE        ;
	    p_debrief_line_rec.LABOR_REASON_CODE            :=	p_debrief_line_tbl(l_curr_row).LABOR_REASON_CODE   ;
	    p_debrief_line_rec.EXPENSE_REASON_CODE          :=    p_debrief_line_tbl(l_curr_row).EXPENSE_REASON_CODE         ;
	    p_debrief_line_rec.LABOR_START_DATE             :=    p_debrief_line_tbl(l_curr_row).LABOR_START_DATE            ;
	    p_debrief_line_rec.LABOR_END_DATE               :=	p_debrief_line_tbl(l_curr_row).LABOR_END_DATE              ;
	    p_debrief_line_rec.STARTING_MILEAGE             :=	p_debrief_line_tbl(l_curr_row).STARTING_MILEAGE            ;
	    p_debrief_line_rec.ENDING_MILEAGE               := 	p_debrief_line_tbl(l_curr_row).ENDING_MILEAGE ;
	    p_debrief_line_rec.EXPENSE_AMOUNT               :=	p_debrief_line_tbl(l_curr_row).EXPENSE_AMOUNT ;
	    p_debrief_line_rec.CURRENCY_CODE               	:=   	p_debrief_line_tbl(l_curr_row).CURRENCY_CODE;
	    p_debrief_line_rec.DEBRIEF_LINE_STATUS_ID      	:=	p_debrief_line_tbl(l_curr_row).DEBRIEF_LINE_STATUS_ID     ;
	    p_debrief_line_rec.CHANNEL_CODE                	:=	p_debrief_line_tbl(l_curr_row).CHANNEL_CODE               ;
	    p_debrief_line_rec.CHARGE_UPLOAD_STATUS        	:=	p_debrief_line_tbl(l_curr_row).CHARGE_UPLOAD_STATUS       ;
	    p_debrief_line_rec.CHARGE_UPLOAD_MSG_CODE      	:=	p_debrief_line_tbl(l_curr_row).CHARGE_UPLOAD_MSG_CODE     ;
	    p_debrief_line_rec.CHARGE_UPLOAD_MESSAGE       	:=	p_debrief_line_tbl(l_curr_row).CHARGE_UPLOAD_MESSAGE      ;
	    p_debrief_line_rec.IB_UPDATE_STATUS            	:=	p_debrief_line_tbl(l_curr_row).IB_UPDATE_STATUS          ;
            p_debrief_line_rec.IB_UPDATE_MSG_CODE          	:=	p_debrief_line_tbl(l_curr_row).IB_UPDATE_MSG_CODE         ;
	    p_debrief_line_rec.IB_UPDATE_MESSAGE           	:= 	p_debrief_line_tbl(l_curr_row).IB_UPDATE_MESSAGE          ;
            p_debrief_line_rec.SPARE_UPDATE_STATUS         	:=	p_debrief_line_tbl(l_curr_row).SPARE_UPDATE_STATUS        ;
	    p_debrief_line_rec.SPARE_UPDATE_MSG_CODE       	:=   	p_debrief_line_tbl(l_curr_row).SPARE_UPDATE_MSG_CODE      ;
	    p_debrief_line_rec.SPARE_UPDATE_MESSAGE       	:= 	p_debrief_line_tbl(l_curr_row).SPARE_UPDATE_MESSAGE       ;
	    p_debrief_line_rec.LAST_UPDATE_DATE  		:= 	nvl(p_debrief_line_tbl(l_curr_row).last_update_date,SYSDATE);
            p_debrief_line_rec.LAST_UPDATED_BY  		:= 	nvl(p_debrief_line_tbl(l_curr_row).last_updated_by,G_USER_ID);
            p_debrief_line_rec.CREATION_DATE  			:= 	nvl(p_debrief_line_tbl(l_curr_row).creation_date,SYSDATE);
            p_debrief_line_rec.CREATED_BY 			:= 	nvl(p_debrief_line_tbl(l_curr_row).created_by,G_USER_ID);
	    p_debrief_line_rec.LAST_UPDATE_LOGIN  		:= 	nvl(p_debrief_line_tbl(l_curr_row).last_update_login,G_LOGIN_ID);
	    p_debrief_line_rec.ATTRIBUTE_CATEGORY  		:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE_CATEGORY;
	    p_debrief_line_rec.ATTRIBUTE1  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE1;
	    p_debrief_line_rec.ATTRIBUTE2  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE2;
	    p_debrief_line_rec.ATTRIBUTE3  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE3;
	    p_debrief_line_rec.ATTRIBUTE4  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE4;
	    p_debrief_line_rec.ATTRIBUTE5  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE5;
	    p_debrief_line_rec.ATTRIBUTE6  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE6;
	    p_debrief_line_rec.ATTRIBUTE7  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE7;
	    p_debrief_line_rec.ATTRIBUTE8  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE8;
	    p_debrief_line_rec.ATTRIBUTE9  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE9;
	    p_debrief_line_rec.ATTRIBUTE10  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE10;
	    p_debrief_line_rec.ATTRIBUTE11  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE11;
	    p_debrief_line_rec.ATTRIBUTE12  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE12;
	    p_debrief_line_rec.ATTRIBUTE13  			:=	p_debrief_line_tbl(l_curr_row).ATTRIBUTE13;
	    p_debrief_line_rec.ATTRIBUTE14  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE14;
	    p_debrief_line_rec.ATTRIBUTE15  			:= 	p_debrief_line_tbl(l_curr_row).ATTRIBUTE15;
	    p_debrief_line_rec.TRANSACTION_TYPE_ID              :=      P_debrief_line_tbl(l_curr_row).TRANSACTION_TYPE_ID;
        p_debrief_line_rec.RETURN_DATE              	:=	p_debrief_line_tbl(l_curr_row).RETURN_DATE    ;
	    p_debrief_line_rec.debrief_header_id  	        := 	p_debrief_header_id;

	   l_debrief_type := debrief_type(p_debrief_line_rec);

       if p_debrief_line_rec.issuing_inventory_org_id = fnd_api.g_miss_num then
         p_debrief_line_rec.issuing_inventory_org_id := null;
       end if;
       if p_debrief_line_rec.receiving_inventory_org_id = fnd_api.g_miss_num then
         p_debrief_line_rec.receiving_inventory_org_id := null;
       end if;

       IF (p_DEBRIEF_LINE_REC.CHANNEL_CODE <> 'CSF_PORTAL') THEN
	    --if transaction_type_id is passed, we will save that
	    --if transaction_type_id is not passed => we will find it from txn_billing_type_id

	    --in both cases we have to find billing_type + line_order_category_code in order to know if we should default return reason or not.

	    IF (p_debrief_line_tbl(l_curr_row).TRANSACTION_TYPE_ID is null)
	       or (p_debrief_line_tbl(l_curr_row).TRANSACTION_TYPE_ID = fnd_api.g_miss_num)
	      Then
	         open c_txn_billing_type_id (p_debrief_line_rec.txn_billing_type_id);
	         fetch c_txn_billing_type_id into l_billing_type, l_line_order_category_code, l_transaction_type_id;
	         close c_txn_billing_type_id;
	         p_debrief_line_rec.transaction_type_id := l_transaction_type_id;
	        Else
	         open  c_transaction_type_id (p_debrief_line_rec.transaction_type_id, p_debrief_line_rec.inventory_item_id);
	         fetch c_transaction_type_id into l_billing_type, l_line_order_category_code;
	         close c_transaction_type_id;
	    End If;


	    IF (p_debrief_line_tbl(l_curr_row).RETURN_REASON_CODE is null)
	       or (p_debrief_line_tbl(l_curr_row).RETURN_REASON_CODE = fnd_api.g_miss_char) Then
	             --------------------------------------------------------------
            	       if nvl(l_billing_type, fnd_api.g_miss_char) <>'M'
               		 Then l_return_reason_code := fnd_api.g_miss_char;
               		 else if l_line_order_category_code = 'RETURN'
                                Then l_return_reason_code := fnd_profile.value('CSF_RETURN_REASON');
                               Else l_return_reason_code := fnd_api.g_miss_char;
                              End If;
                        End If;
            	--------------------------------------------------------------
	        P_debrief_line_rec.RETURN_REASON_CODE := l_return_reason_code;
	      else
	       P_debrief_line_rec.RETURN_REASON_CODE  	        := 	p_debrief_line_tbl(l_curr_row).RETURN_REASON_CODE;
	    End If;




            l_cp_status := p_debrief_line_rec.STATUS_OF_RECEIVED_PART;
            if (l_cp_status is null or l_cp_status=FND_API.G_MISS_CHAR) then
                open  c_cp_status(p_debrief_line_tbl(l_curr_row).TRANSACTION_TYPE_ID);
                fetch c_cp_status into l_cp_status_id;
                close c_cp_status;
              else
                open c_cp_status_notnull (l_cp_status);
                fetch c_cp_status_notnull into l_cp_status_id;
                close c_cp_status_notnull;
            end if;
           if l_debrief_type = 'E' and
              nvl(p_debrief_line_rec.expense_amount,fnd_api.g_miss_num) <> fnd_api.g_miss_num then
             p_debrief_line_rec.UOM_CODE := null;
             P_DEBRIEF_LINE_Rec.quantity := null;
           end if;
           if l_debrief_type = 'L' then
              -- Fixed bug 1286592
             if nvl(p_DEBRIEF_LINE_rec.labor_start_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
                xx_labor_start_date := NULL;
             else
               xx_labor_start_date := p_DEBRIEF_LINE_rec.labor_start_date;
               -- If this is a labor line, ignore what is passed, get primary uom
               open  labor_uom(p_debrief_line_rec.inventory_item_id);
               fetch labor_uom into p_debrief_line_rec.UOM_CODE;
               close labor_uom;
            end if;
            if nvl(p_DEBRIEF_LINE_rec.labor_end_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
               xx_labor_end_date := NULL;
            else
               xx_labor_end_date := p_DEBRIEF_LINE_rec.labor_end_date;
            end if;

--we should calculate quantity based on start time and end time

            if nvl(p_debrief_line_rec.uom_code,fnd_api.g_miss_char) = fnd_api.g_miss_char then

              p_debrief_line_rec.uom_code := fnd_profile.value('CSF_LABOR_DEBRIEF_DEFAULT_UOM');
            end if;
            if nvl(p_DEBRIEF_LINE_rec.quantity,fnd_api.g_miss_num) = fnd_api.g_miss_num then

              l_quantity := (p_debrief_line_rec.LABOR_END_DATE - p_debrief_line_rec.LABOR_START_DATE);
              if p_debrief_line_rec.UOM_CODE <> l_hr_uom and l_quantity is not null then

                l_quantity  := inv_convert.inv_um_convert(
                  p_debrief_line_rec.INVENTORY_ITEM_ID,
                  20,
                  l_quantity*24,
                  l_hr_uom,
                  p_debrief_line_rec.UOM_CODE ,
                  null,
                  null);
              else

                l_quantity := l_quantity * 24;
              end if;
              l_quantity    := nvl(l_quantity,0);
              p_DEBRIEF_LINE_rec.QUANTITY := round(l_quantity,2);
            end if;

            if nvl(p_DEBRIEF_LINE_rec.labor_start_date,fnd_api.g_miss_date) = fnd_api.g_miss_date then

              if p_debrief_line_rec.UOM_CODE <> l_hr_uom then

                l_quantity  := inv_convert.inv_um_convert(
                  p_debrief_line_rec.INVENTORY_ITEM_ID,
                  20,
                  p_DEBRIEF_LINE_rec.quantity,
                  p_debrief_line_rec.UOM_CODE ,
                  l_hr_uom,
                  null,
                  null);
              else

                l_quantity := p_DEBRIEF_LINE_rec.quantity;
              end if;
              if nvl(p_DEBRIEF_LINE_rec.labor_end_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date then

                xx_labor_start_date := p_DEBRIEF_LINE_rec.labor_end_date - l_quantity/24;
              end if;
            end if;

            if nvl(p_DEBRIEF_LINE_rec.labor_end_date,fnd_api.g_miss_date) = fnd_api.g_miss_date or
               (nvl(p_debrief_line_rec.labor_start_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date and
               nvl(p_debrief_line_rec.quantity,fnd_api.g_miss_num) <> fnd_api.g_miss_num) then

              if p_debrief_line_rec.UOM_CODE <> l_hr_uom then

                l_quantity  := inv_convert.inv_um_convert(
                  p_debrief_line_rec.INVENTORY_ITEM_ID,
                  20,
                  p_DEBRIEF_LINE_rec.quantity,
                  p_debrief_line_rec.UOM_CODE ,
                  l_hr_uom,
                  null,
                  null);
              else

                l_quantity := p_DEBRIEF_LINE_rec.quantity;
              end if;

              if nvl(p_DEBRIEF_LINE_rec.labor_start_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date then

                xx_labor_end_date := p_DEBRIEF_LINE_rec.labor_start_date + l_quantity/24;
              end if;
            end if;
            if nvl(p_debrief_line_rec.channel_code,'a') not in ('CSF_LAPTOP','CSF_PALM') then
              validate_start_end(xx_labor_start_date,
                               xx_labor_end_date,
                               p_debrief_line_rec.debrief_header_id,
                               fnd_api.g_false,
                               X_Return_Status,
                               X_Msg_Count,
                               X_Msg_Data);
              if x_return_status <> fnd_api.g_ret_sts_success then
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                raise fnd_api.g_exc_unexpected_error;
              end if;
            end if;
          end if;

     	    IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN

              if l_debrief_type = 'M' then
                validate_subinventory_code(
                  p_init_msg_list     => fnd_api.g_false,
                  p_organization_id   => nvl(p_debrief_line_rec.issuing_inventory_org_id,p_debrief_line_rec.receiving_inventory_org_id),
                  p_subinventory_code => nvl(p_debrief_line_rec.issuing_sub_inventory_code,p_debrief_line_rec.receiving_sub_inventory_code),
                  x_return_status     => x_return_status,
                  x_msg_count         => x_msg_count,
                  x_msg_data          => x_msg_data);

                if x_return_status <> fnd_api.g_ret_sts_success then
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  raise fnd_api.g_exc_unexpected_error;
                end if;
              end if;

                Validate_Service_Date (
	         P_Init_Msg_List               =>FND_API.G_FALSE,
    		 P_Service_Date	               =>p_debrief_line_rec.Service_Date,
    		 X_Return_Status               =>x_return_status,
    		 X_Msg_Count                   =>x_msg_count,
    		 X_Msg_Data                    =>x_msg_data);
                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	            x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                 END IF;

            if nvl(p_debrief_line_rec.inventory_item_id,fnd_api.g_miss_num) =
               fnd_api.g_miss_num and l_debrief_type = 'L' then
               if nvl(p_debrief_line_rec.labor_start_date,fnd_api.g_miss_date) = fnd_api.g_miss_date and
                  nvl(p_debrief_line_rec.labor_end_date,fnd_api.g_miss_date) = fnd_api.g_miss_date then
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_LABOR_DATES_ITEM');
                   FND_MSG_PUB.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_error;
               end if;
            else
               Validate_Inventory_Item_ID (
		P_Init_Msg_List               => FND_API.G_FALSE,
                p_organization_id   => nvl(p_debrief_line_rec.issuing_inventory_org_id,p_debrief_line_rec.receiving_inventory_org_id),
    		P_Inventory_Item_ID	      =>p_debrief_line_rec.Inventory_Item_ID,
    		X_Return_Status               =>x_return_status,
    		X_Msg_Count                   =>x_msg_count,
    		X_Msg_Data                    =>x_msg_data);
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	            x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                Validate_Instance_ID (
		P_Init_Msg_List               => FND_API.G_FALSE,
    		P_Instance_ID	      =>p_debrief_line_rec.Instance_ID,
    		X_Return_Status               =>x_return_status,
    		X_Msg_Count                   =>x_msg_count,
    		X_Msg_Data                    =>x_msg_data);
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	            x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
             end if;

	       Validate_Debrief_Header_ID (
		P_Init_Msg_List               => FND_API.G_FALSE,
    		P_Debrief_Header_ID	      =>p_debrief_line_rec.Debrief_Header_ID,
    		X_Return_Status               =>x_return_status,
    		X_Msg_Count                   =>x_msg_count,
    		X_Msg_Data                    =>x_msg_data);
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	            x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

               Validate_BUSINESS_PROCESS_ID (
		P_Init_Msg_List               => FND_API.G_FALSE,
    		P_BUSINESS_PROCESS_ID         =>p_debrief_line_rec.BUSINESS_PROCESS_ID,
    		X_Return_Status               =>x_return_status,
    		X_Msg_Count                   =>x_msg_count,
    		X_Msg_Data                    =>x_msg_data);
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	            x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
               Validate_TRANSACTION_TYPE_ID (
		P_Init_Msg_List               => FND_API.G_FALSE,
    		P_TRANSACTION_TYPE_ID         =>p_debrief_line_rec.transaction_type_id,
    		X_Return_Status               =>x_return_status,
    		X_Msg_Count                   =>x_msg_count,
    		X_Msg_Data                    =>x_msg_data);
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	            x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

            END IF;


            l_debrief_line_id  := p_debrief_line_rec.debrief_line_id;
            if (l_debrief_line_id<>FND_API.G_MISS_NUM) and (l_debrief_line_id is not NULL) then
               begin
                  select 1 into x
                  from CSF_DEBRIEF_LINES
                  where DEBRIEF_LINE_ID = l_DEBRIEF_LINE_ID ;

                  fnd_message.set_name('CSF', 'CSF_DEBRIEF_INVALID_LINE_ID');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  RAISE fnd_api.g_exc_unexpected_error;
               exception
                when no_data_found then
                    null ;
                when too_many_rows then
                    fnd_message.set_name('CSF', 'CSF_DEBRIEF_INVALID_LINE_ID');
                    fnd_msg_pub.add;
                    x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
               end ;
           ELSE

              SELECT CSF_DEBRIEF_LINES_S.nextval
              INTO l_debrief_line_id
              FROM dual;
          END IF;

           -- Invoke table handler(debrief_Line_Insert_Row)
	   csf_debrief_lines_pkg.INSERT_ROW(
	  px_DEBRIEF_LINE_ID  			    =>  l_debrief_line_id,
	  p_DEBRIEF_HEADER_ID  			    => 	p_DEBRIEF_LINE_rec.DEBRIEF_HEADER_ID,
	  p_DEBRIEF_LINE_NUMBER			    =>	p_DEBRIEF_LINE_rec.DEBRIEF_LINE_NUMBER,
	  p_SERVICE_DATE                            =>	p_DEBRIEF_LINE_rec.SERVICE_DATE          ,
	  p_BUSINESS_PROCESS_ID               	    =>  p_DEBRIEF_LINE_rec.BUSINESS_PROCESS_ID   ,
	  p_TXN_BILLING_TYPE_ID               	    =>  p_DEBRIEF_LINE_rec.TXN_BILLING_TYPE_ID   ,
	  p_INVENTORY_ITEM_ID                 	    =>  p_DEBRIEF_LINE_rec.INVENTORY_ITEM_ID     ,
	  p_INSTANCE_ID                 	    =>  p_DEBRIEF_LINE_rec.INSTANCE_ID     ,
	  p_ISSUING_INVENTORY_ORG_ID                =>  p_DEBRIEF_LINE_rec.ISSUING_INVENTORY_ORG_ID,
	  p_RECEIVING_INVENTORY_ORG_ID              =>  p_DEBRIEF_LINE_rec.RECEIVING_INVENTORY_ORG_ID,
	  p_ISSUING_SUB_INVENTORY_CODE              =>  p_DEBRIEF_LINE_rec.ISSUING_SUB_INVENTORY_CODE,
	  p_RECEIVING_SUB_INVENTORY_CODE            =>  p_DEBRIEF_LINE_rec.RECEIVING_SUB_INVENTORY_CODE,
	  p_ISSUING_LOCATOR_ID                      =>  p_DEBRIEF_LINE_rec.ISSUING_LOCATOR_ID          ,
	  p_RECEIVING_LOCATOR_ID                    => 	p_DEBRIEF_LINE_rec.RECEIVING_LOCATOR_ID        ,
	  p_PARENT_PRODUCT_ID                       =>	p_DEBRIEF_LINE_rec.PARENT_PRODUCT_ID           ,
	  p_REMOVED_PRODUCT_ID                      =>	p_DEBRIEF_LINE_rec.REMOVED_PRODUCT_ID          ,
	  p_STATUS_OF_RECEIVED_PART                 =>	l_cp_status_id     ,
	  p_ITEM_SERIAL_NUMBER                      =>  p_DEBRIEF_LINE_rec.ITEM_SERIAL_NUMBER          ,
	  p_ITEM_REVISION                           =>	p_DEBRIEF_LINE_rec.ITEM_REVISION               ,
	  p_ITEM_LOTNUMBER                          => 	p_DEBRIEF_LINE_rec.ITEM_LOTNUMBER              ,
	  p_UOM_CODE                                => 	p_DEBRIEF_LINE_rec.UOM_CODE                    ,
	  p_QUANTITY                                =>  p_DEBRIEF_LINE_rec.QUANTITY                    ,
	  p_RMA_HEADER_ID                           =>	p_DEBRIEF_LINE_rec.RMA_HEADER_ID               ,
	  p_DISPOSITION_CODE                        =>	p_DEBRIEF_LINE_rec.DISPOSITION_CODE            ,
	  p_MATERIAL_REASON_CODE                    =>	p_DEBRIEF_LINE_rec.MATERIAL_REASON_CODE        ,
	  p_LABOR_REASON_CODE                       =>	p_DEBRIEF_LINE_rec.LABOR_REASON_CODE           ,
	  p_EXPENSE_REASON_CODE                     =>  p_DEBRIEF_LINE_rec.EXPENSE_REASON_CODE         ,
	  p_LABOR_START_DATE                        =>   trunc(xx_labor_start_date,'MI'),
	  p_LABOR_END_DATE                          =>	trunc(xx_labor_end_date,'MI'),
	  p_STARTING_MILEAGE                        =>	p_DEBRIEF_LINE_rec.STARTING_MILEAGE            ,
	  p_ENDING_MILEAGE                	    => 	p_DEBRIEF_LINE_rec.ENDING_MILEAGE              ,
	  p_EXPENSE_AMOUNT               	    =>	p_DEBRIEF_LINE_rec.EXPENSE_AMOUNT              ,
	  p_CURRENCY_CODE                	    =>   	p_DEBRIEF_LINE_rec.CURRENCY_CODE               ,
	  p_DEBRIEF_LINE_STATUS_ID                   =>	p_DEBRIEF_LINE_rec.DEBRIEF_LINE_STATUS_ID      ,
      p_RETURN_REASON_CODE                       => P_debrief_line_rec.RETURN_REASON_CODE                            ,
	  p_CHANNEL_CODE                	=>	p_DEBRIEF_LINE_rec.CHANNEL_CODE,
	  p_CHARGE_UPLOAD_STATUS                	=>	p_DEBRIEF_LINE_rec.CHARGE_UPLOAD_STATUS        ,
	  p_CHARGE_UPLOAD_MSG_CODE             	=>	p_DEBRIEF_LINE_rec.CHARGE_UPLOAD_MSG_CODE      ,
	  p_CHARGE_UPLOAD_MESSAGE               	=>	p_DEBRIEF_LINE_rec.CHARGE_UPLOAD_MESSAGE       ,
	  p_IB_UPDATE_STATUS                    	=>	p_DEBRIEF_LINE_rec.IB_UPDATE_STATUS            ,
	  p_IB_UPDATE_MSG_CODE                  	=>	p_DEBRIEF_LINE_rec.IB_UPDATE_MSG_CODE          ,
	  p_IB_UPDATE_MESSAGE                   	=> 	p_DEBRIEF_LINE_rec.IB_UPDATE_MESSAGE           ,
	  p_SPARE_UPDATE_STATUS                 	=>	p_DEBRIEF_LINE_rec.SPARE_UPDATE_STATUS         ,
	  p_SPARE_UPDATE_MSG_CODE               	=>   	p_DEBRIEF_LINE_rec.SPARE_UPDATE_MSG_CODE       ,
	  p_SPARE_UPDATE_MESSAGE               	=> 	p_DEBRIEF_LINE_rec.SPARE_UPDATE_MESSAGE           ,
	  p_CREATED_BY 					=> 	nvl(p_debrief_line_rec.created_by,G_USER_ID),
	  p_CREATION_DATE  					=> 	nvl(p_debrief_line_rec.creation_date,SYSDATE),
	  p_LAST_UPDATED_BY  				=> 	nvl(p_debrief_line_rec.last_updated_by,G_USER_ID),
	  p_LAST_UPDATE_DATE  				=> 	nvl(p_debrief_line_rec.last_update_date,SYSDATE),
	  p_LAST_UPDATE_LOGIN  				=> 	nvl(p_debrief_line_rec.last_update_login,G_LOGIN_ID),
	  p_ATTRIBUTE1  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE1,
	  p_ATTRIBUTE2  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE2,
	  p_ATTRIBUTE3  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE3,
	  p_ATTRIBUTE4  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE4,
	  p_ATTRIBUTE5  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE5,
	  p_ATTRIBUTE6  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE6,
	  p_ATTRIBUTE7  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE7,
	  p_ATTRIBUTE8  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE8,
	  p_ATTRIBUTE9  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE9,
	  p_ATTRIBUTE10  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE10,
	  p_ATTRIBUTE11  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE11,
	  p_ATTRIBUTE12  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE12,
	  p_ATTRIBUTE13  					=>	p_DEBRIEF_LINE_rec.ATTRIBUTE13,
	  p_ATTRIBUTE14  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE14,
	  p_ATTRIBUTE15  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE15,
	  p_ATTRIBUTE_CATEGORY  				=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE_CATEGORY,
	  p_TRANSACTION_TYPE_ID           		        =>      P_DEBRIEF_LINE_REC.TRANSACTION_TYPE_ID,
      p_RETURN_DATE           		        =>      P_DEBRIEF_LINE_REC.RETURN_DATE
          );

	  -- Calling the Update Resource Location API to Update Resource's Locatio

      IF (l_Debrief_type = 'L') THEN
      BEGIN
       SELECT jta.resource_type_code,
              jta.resource_id
       INTO l_resource_type,
            l_resource_id
       FROM jtf_task_Assignments jta, csf_Debrief_headers cdh
       WHERE jta.task_Assignment_id = cdh.task_assignment_id
       AND cdh.debrief_header_id = p_debrief_line_rec.DEBRIEF_HEADER_ID;
      EXCEPTION
        when no_data_found then
          null;
      END;
       VALIDATE_LABOR_TIMES (
        P_Init_Msg_List       => null,
        P_api_version_number  => 1.0,
        p_resource_type_code  => l_Resource_type,
        p_resource_id         => l_resource_id,
        p_debrief_line_id     => p_debrief_line_rec.debrief_line_id,
        p_labor_start_date    => p_debrief_line_rec.labor_start_date,
        p_labor_end_date      => p_Debrief_line_rec.labor_end_date,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_debrief_number      => l_debrief_number,
        x_task_number         => l_task_number
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.Set_Name('CSF', 'CSF_OVERLAP_LABOR_LINE');
          FND_MSG_PUB.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
       END IF;
--Update actual times for task and task assignment
      if l_debrief_type = 'L' then
        update_task_actuals(p_debrief_line_rec.debrief_header_id, -- modified for bug 3748610
                            x_return_status,
                            x_msg_count,
                            x_msg_data);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      end if;
          if l_debrief_type='L' then
             Begin
	        select		 jta.resource_id,
	  			 loc.geometry
	  	into		 z_resource_id,
	 			 z_location
	  	from    	 csf_debrief_lines     cdl,
       	 	        	 csf_debrief_headers csf,
 				 jtf_task_assignments jta,
		       		 jtf_tasks_b    jtb,
		       		 hz_party_sites p,
		       		 hz_locations   loc
		where  		csf.debrief_header_id	   =   p_debrief_line_rec.debrief_header_id
		and     	debrief_line_id   	   =   l_debrief_line_id
		and		csf.debrief_header_id      =   cdl.debrief_header_id
		and		jta.task_assignment_id	   =   csf.task_assignment_id
		and		jta.task_id		   =   jtb.task_id
		and		jtb.address_id		   =   p.party_site_id
		and		p.location_id		   =   loc.location_id;
	  	select 	 max(actual_start_date)
	  	into	 z_start_date
	 	 from 	 jtf_task_assignments
	  	where    resource_id = z_resource_id;

	  	IF p_debrief_line_rec.labor_start_date > z_start_date then
   	  		select 	object_version_number
  			into	z_object_version_number
   			from	jtf_rs_resource_extns
   			where	resource_id	= z_resource_id;

 	/*		jtf_rs_resource_pub.update_resource
    			(P_API_VERSION 	=> 1,
    		 	P_INIT_MSG_LIST 	=> fnd_api.g_false,
    		 	P_COMMIT 		=> fnd_api.g_false,
    		 	P_RESOURCE_ID 	=> z_resource_id,
    			 P_RESOURCE_NUMBER	=> null,
    	 		P_LOCATION 		=> z_location,
    			 P_object_version_num =>  z_object_version_number,
     		 	X_RETURN_STATUS      =>  x_return_status,
    	 		X_MSG_COUNT          =>  x_msg_count,
    	 		X_MSG_DATA           =>  x_msg_data);
                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           Raise   FND_API.G_EXC_ERROR;
                        END IF;
*/
                END IF;
            Exception
             When NO_DATA_FOUND then
             NULL;
            End;
         End if;
	-- Calling the Update Task Assignment API Location API to Update Resource's Location

	if  P_Upd_tskassgnstatus = 'Y' then

	     BEGIN
	        Validate_Task_Assignment_Satus(
                   P_Api_Version_Number         =>1.0,
                   P_Init_Msg_List              => FND_API.G_FALSE,
                   P_Commit                     => FND_API.G_FALSE,
                   P_Task_Assignment_status     =>P_Task_Assignment_status,
                   X_TA_STATUS_ID               =>l_assignment_status_id,
                   X_Return_Status              =>X_Return_Status,
                   X_Msg_Count                  =>X_MSG_COUNT,
                   X_Msg_Data                   =>X_MSG_DATA);
                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;


	           select  jta.task_assignment_id,
       			  jta.object_version_number,
       			  jta.task_id
 		   into    l_task_assignment_id,
       			  l_object_version_number,
       			  l_task_id
 		   from    jtf_task_assignments jta,
   	 	          csf_debrief_headers csf
 		   where    csf.task_assignment_id     = jta.task_assignment_id
		   and      csf.debrief_header_id      = p_debrief_line_rec.debrief_header_id;


		  CSF_TASK_ASSIGNMENTS_PUB.UPDATE_ASSIGNMENT_STATUS(
		 P_API_VERSION                 =>1.0            ,
 	         P_INIT_MSG_LIST               =>FND_API.G_FALSE,
 	         P_COMMIT                      =>FND_API.G_FALSE,
                 X_RETURN_STATUS               =>x_return_status,
                 X_MSG_COUNT                   =>x_msg_count,
                 X_MSG_DATA                    =>x_msg_data,
                 P_TASK_ASSIGNMENT_ID          =>l_task_assignment_id,
                 P_ASSIGNMENT_STATUS_ID        =>l_assignment_status_id,
                 P_OBJECT_VERSION_NUMBER       =>l_object_version_number,
                 P_UPDATE_TASK                 =>'T',
                 X_TASK_OBJECT_VERSION_NUMBER  =>l_task_object_version_number,
                 X_TASK_STATUS_ID              =>l_task_status_id);
                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;

            EXCEPTION
               WHEN OTHERS THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_UPDATE_TASK_ASSIGNMENT');
                  FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END;
          end if;
      END IF;
     END;
   END LOOP;

   IF (p_DEBRIEF_LINE_REC.CHANNEL_CODE <> 'CSF_PORTAL') THEN
-- Call concurrent program if assignment status is completed,closed,rejected,canceled
   open  c_status(p_debrief_line_rec.debrief_header_id);
   fetch c_status into l_call_cp;
   close c_status;
   if nvl(l_call_cp,'N') = 'Y' then
     l_request_id := fnd_request.submit_request(
                       'CSF',
                       'CSFUPDATE',
                       'CSF:Update Debrief Lines',
                       null,
                       FALSE,
                       1.0,
                       p_debrief_line_rec.debrief_header_id);
   end if;
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
        COMMIT WORK;
   END IF;

   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
    );

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_DEBRIEF_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
          P_COUNT => X_MSG_COUNT
         ,P_DATA  => X_MSG_DATA);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  CREATE_DEBRIEF_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
      P_COUNT => X_MSG_COUNT
      ,P_DATA  => X_MSG_DATA);
   WHEN OTHERS THEN
      ROLLBACK TO  CREATE_DEBRIEF_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
	FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME ,L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get (
      P_COUNT => X_MSG_COUNT
     ,P_DATA  => X_MSG_DATA);
End Create_debrief_lines;

-- **********

PROCEDURE Validate_Task_Assignment_Satus(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    P_Task_Assignment_status     IN   VARCHAR2  ,
    X_TA_STATUS_ID             OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS

  Cursor validate_ta_status is
  select task_status_id
  from jtf_task_statuses_vl
  where name=P_Task_Assignment_status;

 BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (P_Task_Assignment_status is NULL OR P_Task_Assignment_status = FND_API.G_MISS_CHAR) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_TA_STATUS');
                FND_MSG_PUB.ADD;
             END IF;
      ELSE
          open validate_ta_status;
          fetch validate_ta_status into X_TA_STATUS_ID;
          if validate_ta_status%notfound then
               close validate_ta_status ;
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_TAvalvav_STATUS');
                  FND_MSG_PUB.ADD;
               END IF;
          end if;
          close validate_ta_status ;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END  Validate_Task_Assignment_Satus;
-- **********

PROCEDURE Update_debrief_line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    P_Upd_tskassgnstatus         IN VARCHAR2   ,
    P_Task_Assignment_status     IN VARCHAR2  ,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_DEBRIEF_LINE_Rec           IN OUT NOCOPY  DEBRIEF_LINE_Rec_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS

 G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
 G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
 l_hr_uom                 varchar2(100) := fnd_profile.value('CSF_UOM_HOURS');
 l_quantity               number;
 l_cp_status_id            number;
 l_cp_status              varchar2(30);
 l_request_id                 number;
 l_call_cp                    varchar2(1);

  cursor c_status(p_debrief_header_id number) is
  select greatest(nvl(rejected_flag,'N'),
                  nvl(completed_flag,'N'),
                  nvl(closed_flag,'N'),
                  nvl(cancelled_flag,'N'))
  from   jtf_task_statuses_b jtsb,
         jtf_task_assignments jta,
         csf_debrief_headers cdh
  where  cdh.debrief_header_id = p_debrief_header_id
  and    jta.task_assignment_id = cdh.task_assignment_id
  and    jtsb.task_status_id = jta.assignment_status_id;

-- Virendra Singh 03/21/2000
-- cursor to get CHARGE_UPLOAD_STATUS
cursor GET_CHARGE_UPLOAD_STATUS (P_DEBRIEF_LINE_ID  NUMBER) is
  select CHARGE_UPLOAD_STATUS,
	 IB_UPDATE_STATUS,
	 SPARE_UPDATE_STATUS,
	 labor_start_date
  from   CSF_DEBRIEF_LINES
  where  DEBRIEF_LINE_ID=P_DEBRIEF_LINE_ID;


cursor c_cp_status(p_transaction_type_id number) is
  	 select ctst.src_status_id
  	 from   csi_txn_sub_types ctst ,
         cs_transaction_types_vl  cttv
         where  ctst.cs_transaction_type_id = cttv.transaction_type_id
         and    cttv.transaction_type_id = p_transaction_type_id;

cursor c_cp_status_notnull (p_cp_status varchar2) is
         select instance_status_id
         from   csi_instance_statuses
         where  name = p_cp_status;


l_api_name                CONSTANT VARCHAR2(30) := 'Update_debrief_line';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_debrief_line_rec      CSF_DEBRIEF_PVT.DEBRIEF_LINE_REC_TYPE;
z_debrief_line_number number;
z_start_date		date;
z_end_date			date;
z_debrief_header_id    	number;
z_task_assignment_id	number;
z_resource_id		number;
z_location			mdsys.sdo_geometry;
z_debrief_line_id 	number;
 z_object_version_number  NUMBER;
l_object_version_number   number;
l_task_id                 number;
l_task_assignment_id      number;
l_assignment_status_id    number;
closed_assignment_count  number;
l_charge_upload_status   varchar2(30);
L_DEBRIEF_LINE_ID        number;
l_business_process_id	number;
l_billing_type           cs_txn_billing_types.billing_type%type;
l_task_object_version_number number;
l_task_status_id          number;
l_task_status_name        varchar2(200);
l_data                    varchar2(500);
l_msg_index_out           number;
l_ib_upload_status        varchar2(30);
l_spare_upload_status     varchar2(30);
l_return_reason_code      varchar2(30) ;
l_uom_code		  varchar2(30);
l_labor_start_date	  date;
l_debrief_type            varchar2(1);
l_issuing_inventory_org_id            number:= null;
l_receiving_inventory_org_id          number:= null;

cursor labor_uom(p_inventory_item_id number) is
select primary_uom_code
from   mtl_system_items_b
where  inventory_item_id = p_inventory_item_id;

cursor c_uom_code is
select uom_code
from   csf_debrief_lines cdl
where  debrief_line_id = P_DEBRIEF_LINE_Rec.debrief_line_id;

BEGIN
  l_debrief_type := debrief_type(p_debrief_line_rec);

  l_issuing_inventory_org_id := p_debrief_line_rec.issuing_inventory_org_id;
  l_receiving_inventory_org_id := p_debrief_line_rec.receiving_inventory_org_id;
  if p_debrief_line_rec.issuing_inventory_org_id = fnd_api.g_miss_num then
    l_issuing_inventory_org_id := null;
  end if;
  if p_debrief_line_rec.receiving_inventory_org_id = fnd_api.g_miss_num then
    l_receiving_inventory_org_id := null;
  end if;

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_DEBRIEF_LINE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Virendra Singh 03/21/2000
      -- fetch charge upload status and check if its already upload
      -- then don't update debrief lines
      l_debrief_line_id:=p_debrief_line_rec.debrief_line_id;
      open GET_CHARGE_UPLOAD_STATUS(l_DEBRIEF_LINE_ID);
      fetch GET_CHARGE_UPLOAD_STATUS into l_charge_upload_status, l_ib_upload_status, l_spare_upload_status, l_labor_start_date;
      if GET_CHARGE_UPLOAD_STATUS%notfound then
           close GET_CHARGE_UPLOAD_STATUS;
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_INVALID_LINE_ID');
               FND_MSG_PUB.Add;

           END IF;
           raise FND_API.G_EXC_ERROR;
      end if;
      close GET_CHARGE_UPLOAD_STATUS;
      l_cp_status := p_debrief_line_rec.STATUS_OF_RECEIVED_PART;
            if (l_cp_status is null or l_cp_status=FND_API.G_MISS_CHAR) then
                open  c_cp_status(p_debrief_line_rec.TXN_BILLING_TYPE_ID);
                fetch c_cp_status into l_cp_status_id;
                close c_cp_status;
              else
                open c_cp_status_notnull (l_cp_status);
                fetch c_cp_status_notnull into l_cp_status_id;
                close c_cp_status_notnull;
            end if;
      IF l_charge_upload_status='SUCCEEDED' or
         l_ib_upload_status    ='SUCCEEDED' or
         l_spare_upload_status ='SUCCEEDED'    then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
           THEN
               FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_CHARGE_UPLOADED');
               FND_MSG_PUB.Add;
               x_return_status := 'E';
           END IF;
      ELSE
         IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
            THEN
             IF (p_debrief_line_rec.Service_Date<> FND_API.G_MISS_DATE) then
                  Validate_Service_Date (
	           P_Init_Msg_List               =>FND_API.G_FALSE,
    		   P_Service_Date	               =>p_debrief_line_rec.Service_Date,
    		   X_Return_Status               =>x_return_status,
    		   X_Msg_Count                   =>x_msg_count,
    		   X_Msg_Data                    =>x_msg_data);
                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	              x_return_status := fnd_api.g_ret_sts_unexp_error;
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;
              END IF;
              IF nvl(P_DEBRIEF_LINE_REC.Inventory_Item_ID,fnd_api.g_miss_num)= FND_API.G_MISS_NUM and l_debrief_type = 'L' then
                if nvl(p_debrief_line_rec.labor_start_date,fnd_api.g_miss_date) = fnd_api.g_miss_date and
                   nvl(p_debrief_line_rec.labor_end_date,fnd_api.g_miss_date) = fnd_api.g_miss_date then
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_LABOR_DATES_ITEM');
                    FND_MSG_PUB.ADD;
                  END IF;
                  RAISE fnd_api.g_exc_error;
                end if;
              else
              Validate_Inventory_Item_ID (
		  P_Init_Msg_List               => FND_API.G_FALSE,
                  p_organization_id   => nvl(l_issuing_inventory_org_id,l_receiving_inventory_org_id),
    		  P_Inventory_Item_ID	        =>p_debrief_line_rec.Inventory_Item_ID,
    		  X_Return_Status               =>x_return_status,
    		  X_Msg_Count                   =>x_msg_count,
    		  X_Msg_Data                    =>x_msg_data);
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	              x_return_status := fnd_api.g_ret_sts_unexp_error;
                      RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
               END IF;
               IF (P_DEBRIEF_LINE_REC.DEBRIEF_HEADER_ID <>FND_API.G_MISS_NUM)  THEN
	          Validate_Debrief_Header_ID (
		  P_Init_Msg_List               => FND_API.G_FALSE,
    		  P_Debrief_Header_ID	      =>p_debrief_line_rec.Debrief_Header_ID,
    		  X_Return_Status               =>x_return_status,
    		  X_Msg_Count                   =>x_msg_count,
    		  X_Msg_Data                    =>x_msg_data);
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	              x_return_status := fnd_api.g_ret_sts_unexp_error;
                      RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
                END IF;
              IF (P_DEBRIEF_LINE_REC.BUSINESS_PROCESS_ID <> FND_API.G_MISS_NUM)  THEN
                 Validate_BUSINESS_PROCESS_ID (
		  P_Init_Msg_List               => FND_API.G_FALSE,
    		  P_BUSINESS_PROCESS_ID         =>p_debrief_line_rec.BUSINESS_PROCESS_ID,
    		  X_Return_Status               =>x_return_status,
    		  X_Msg_Count                   =>x_msg_count,
    		  X_Msg_Data                    =>x_msg_data);
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	              x_return_status := fnd_api.g_ret_sts_unexp_error;
                      RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
               END IF;
              IF (P_DEBRIEF_LINE_REC.TXN_BILLING_TYPE_ID <> FND_API.G_MISS_NUM)  THEN
                 Validate_TRANSACTION_TYPE_ID (
		  P_Init_Msg_List               => FND_API.G_FALSE,
    		  P_TRANSACTION_TYPE_ID         =>p_debrief_line_rec.transaction_type_id,
    		  X_Return_Status               =>x_return_status,
    		  X_Msg_Count                   =>x_msg_count,
    		  X_Msg_Data                    =>x_msg_data);
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	              x_return_status := fnd_api.g_ret_sts_unexp_error;
                      RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
               END IF;
            END IF;
-- Fixed bug 1286592
-- For labor lines ignore the UOM passed from
    l_uom_code := p_debrief_line_rec.uom_code;
    if l_labor_start_date is not null then
       open  labor_uom(p_debrief_line_rec.inventory_item_id);
       fetch labor_uom into l_uom_code;
       close labor_uom;
    end if;
    if l_debrief_type = 'E' and nvl(p_debrief_line_rec.expense_amount,fnd_api.g_miss_num) <> fnd_api.g_miss_num then
      p_debrief_line_rec.UOM_CODE := null;
      P_DEBRIEF_LINE_Rec.quantity := null;
    end if;
    if l_debrief_type = 'L' then
  --we should calculate quantity based on start time and end time
  --we should calculate quantity based on start time and end time
            if nvl(p_debrief_line_rec.uom_code,fnd_api.g_miss_char) = fnd_api.g_miss_char then
              open  c_uom_code;
              fetch c_uom_code into l_uom_code;
              close c_uom_code;
--              p_debrief_line_rec.uom_code := fnd_profile.value('CSF_LABOR_DEBRIEF_DEFAULT_UOM');
            end if;
            if nvl(p_DEBRIEF_LINE_rec.quantity,fnd_api.g_miss_num) = fnd_api.g_miss_num then
              l_quantity := (p_debrief_line_rec.LABOR_END_DATE - p_debrief_line_rec.LABOR_START_DATE);
              if l_uom_code <> l_hr_uom and l_quantity is not null then
                l_quantity  := inv_convert.inv_um_convert(
                  p_debrief_line_rec.INVENTORY_ITEM_ID,
                  20,
                  l_quantity*24,
                  l_hr_uom,
                  l_uom_code ,
                  null,
                  null);
              else
                l_quantity := l_quantity * 24;
              end if;
              l_quantity    := round(nvl(l_quantity,0),2);
              p_DEBRIEF_LINE_rec.QUANTITY := round(l_quantity,2);
            end if;

            if nvl(p_DEBRIEF_LINE_rec.labor_start_date,fnd_api.g_miss_date) = fnd_api.g_miss_date then
              if l_uom_code <> l_hr_uom then
                l_quantity  := inv_convert.inv_um_convert(
                  p_debrief_line_rec.INVENTORY_ITEM_ID,
                  20,
                  p_DEBRIEF_LINE_rec.quantity,
                  l_uom_code ,
                  l_hr_uom,
                  null,
                  null);
              else
                l_quantity := p_DEBRIEF_LINE_rec.quantity;
              end if;
              if nvl(p_DEBRIEF_LINE_rec.labor_end_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date then
                p_debrief_line_rec.labor_start_date := p_DEBRIEF_LINE_rec.labor_end_date - l_quantity/24;
              end if;
            end if;

            if nvl(p_DEBRIEF_LINE_rec.labor_end_date,fnd_api.g_miss_date) = fnd_api.g_miss_date or
               (nvl(p_debrief_line_rec.labor_start_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date and
               nvl(P_DEBRIEF_LINE_Rec.quantity,fnd_api.g_miss_num) <> fnd_api.g_miss_num ) then
              if l_uom_code <> l_hr_uom then
                l_quantity  := inv_convert.inv_um_convert(
                  p_debrief_line_rec.INVENTORY_ITEM_ID,
                  20,
                  p_DEBRIEF_LINE_rec.quantity,
                  l_uom_code ,
                  l_hr_uom,
                  null,
                  null);
              else
                l_quantity := p_DEBRIEF_LINE_rec.quantity;
              end if;
              if nvl(p_DEBRIEF_LINE_rec.labor_start_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date then
                p_debrief_line_rec.labor_end_date := p_DEBRIEF_LINE_rec.labor_start_date + l_quantity/24;
              end if;
            end if;

           if nvl(p_debrief_line_rec.channel_code,'a') not in ('CSF_LAPTOP','CSF_PALM') then
             validate_start_end(p_debrief_line_rec.labor_start_date,
                               p_debrief_line_rec.labor_end_date,
                               p_debrief_line_rec.debrief_header_id,
                               fnd_api.g_false,
                               X_Return_Status,
                               X_Msg_Count,
                               X_Msg_Data);
             if x_return_status <> fnd_api.g_ret_sts_success then
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               raise fnd_api.g_exc_unexpected_error;
             end if;
           end if;
            if nvl(l_uom_code,fnd_api.g_miss_char) = fnd_api.g_miss_char then
              p_debrief_line_rec.uom_code := fnd_profile.value('CSF_LABOR_DEBRIEF_DEFAULT_UOM');
            end if;
          end if;

      ----
      csf_debrief_lines_pkg.update_ROW(
	  p_DEBRIEF_LINE_ID  			    =>  p_DEBRIEF_LINE_rec.debrief_line_id,
	  p_DEBRIEF_HEADER_ID  			    => 	p_DEBRIEF_LINE_rec.DEBRIEF_HEADER_ID,
	  p_DEBRIEF_LINE_NUMBER			    =>	p_DEBRIEF_LINE_rec.DEBRIEF_LINE_NUMBER,
	  p_SERVICE_DATE                            =>	p_DEBRIEF_LINE_rec.SERVICE_DATE          ,
	  p_BUSINESS_PROCESS_ID               	    =>  p_DEBRIEF_LINE_rec.BUSINESS_PROCESS_ID   ,
	  p_TXN_BILLING_TYPE_ID               	    =>  p_DEBRIEF_LINE_rec.TXN_BILLING_TYPE_ID   ,
	  p_INVENTORY_ITEM_ID                 	    =>  p_DEBRIEF_LINE_rec.INVENTORY_ITEM_ID     ,
      p_INSTANCE_ID                 	        =>  p_DEBRIEF_LINE_rec.INSTANCE_ID     ,
	  p_ISSUING_INVENTORY_ORG_ID                =>  p_DEBRIEF_LINE_rec.ISSUING_INVENTORY_ORG_ID,
	  p_RECEIVING_INVENTORY_ORG_ID              =>  p_DEBRIEF_LINE_rec.RECEIVING_INVENTORY_ORG_ID,
	  p_ISSUING_SUB_INVENTORY_CODE              =>  p_DEBRIEF_LINE_rec.ISSUING_SUB_INVENTORY_CODE,
	  p_RECEIVING_SUB_INVENTORY_CODE            =>  p_DEBRIEF_LINE_rec.RECEIVING_SUB_INVENTORY_CODE,
	  p_ISSUING_LOCATOR_ID                      =>  p_DEBRIEF_LINE_rec.ISSUING_LOCATOR_ID          ,
	  p_RECEIVING_LOCATOR_ID                    => 	p_DEBRIEF_LINE_rec.RECEIVING_LOCATOR_ID        ,
	  p_PARENT_PRODUCT_ID                       =>	p_DEBRIEF_LINE_rec.PARENT_PRODUCT_ID           ,
	  p_REMOVED_PRODUCT_ID                      =>	p_DEBRIEF_LINE_rec.REMOVED_PRODUCT_ID          ,
	  p_STATUS_OF_RECEIVED_PART                 =>	l_cp_status_id,
	  p_ITEM_SERIAL_NUMBER                      =>  p_DEBRIEF_LINE_rec.ITEM_SERIAL_NUMBER          ,
	  p_ITEM_REVISION                           =>	p_DEBRIEF_LINE_rec.ITEM_REVISION               ,
	  p_ITEM_LOTNUMBER                          => 	p_DEBRIEF_LINE_rec.ITEM_LOTNUMBER              ,
	  p_UOM_CODE                                => 	p_debrief_line_rec.uom_code                    ,
	  p_QUANTITY                                =>  P_DEBRIEF_LINE_Rec.quantity                  ,
	  p_RMA_HEADER_ID                           =>	p_DEBRIEF_LINE_rec.RMA_HEADER_ID               ,
	  p_DISPOSITION_CODE                        =>	p_DEBRIEF_LINE_rec.DISPOSITION_CODE            ,
	  p_MATERIAL_REASON_CODE                    =>	p_DEBRIEF_LINE_rec.MATERIAL_REASON_CODE        ,
	  p_LABOR_REASON_CODE                       =>	p_DEBRIEF_LINE_rec.LABOR_REASON_CODE           ,
	  p_EXPENSE_REASON_CODE                     =>  p_DEBRIEF_LINE_rec.EXPENSE_REASON_CODE         ,
	  p_LABOR_START_DATE                        =>  trunc(p_DEBRIEF_LINE_rec.labor_start_date,'MI'),
	  p_LABOR_END_DATE                          =>	trunc(p_DEBRIEF_LINE_rec.labor_end_date,'MI'),
	  p_STARTING_MILEAGE                        =>	p_DEBRIEF_LINE_rec.STARTING_MILEAGE            ,
	  p_ENDING_MILEAGE                	        => 	p_DEBRIEF_LINE_rec.ENDING_MILEAGE              ,
	  p_EXPENSE_AMOUNT               	        =>	p_DEBRIEF_LINE_rec.EXPENSE_AMOUNT              ,
	  p_CURRENCY_CODE                	        =>   	p_DEBRIEF_LINE_rec.CURRENCY_CODE               ,
	  p_DEBRIEF_LINE_STATUS_ID                  =>	p_DEBRIEF_LINE_rec.DEBRIEF_LINE_STATUS_ID      ,
      p_return_reason_code                      =>  p_debrief_line_rec.return_reason_code,
	  p_CHANNEL_CODE                	        =>p_DEBRIEF_LINE_rec.CHANNEL_CODE,
	  p_CHARGE_UPLOAD_STATUS                	=>	p_DEBRIEF_LINE_rec.CHARGE_UPLOAD_STATUS        ,
	  p_CHARGE_UPLOAD_MSG_CODE             	    =>	p_DEBRIEF_LINE_rec.CHARGE_UPLOAD_MSG_CODE      ,
	  p_CHARGE_UPLOAD_MESSAGE               	=>	p_DEBRIEF_LINE_rec.CHARGE_UPLOAD_MESSAGE       ,
	  p_IB_UPDATE_STATUS                    	=>	p_DEBRIEF_LINE_rec.IB_UPDATE_STATUS            ,
	  p_IB_UPDATE_MSG_CODE                  	=>	p_DEBRIEF_LINE_rec.IB_UPDATE_MSG_CODE          ,
	  p_IB_UPDATE_MESSAGE                   	=> 	p_DEBRIEF_LINE_rec.IB_UPDATE_MESSAGE           ,
	  p_SPARE_UPDATE_STATUS                 	=>	p_DEBRIEF_LINE_rec.SPARE_UPDATE_STATUS         ,
	  p_SPARE_UPDATE_MSG_CODE               	=>   	p_DEBRIEF_LINE_rec.SPARE_UPDATE_MSG_CODE       ,
	  p_SPARE_UPDATE_MESSAGE                  	=> 	p_DEBRIEF_LINE_rec.SPARE_UPDATE_MESSAGE           ,
	  p_CREATED_BY 					    => 	p_debrief_line_rec.created_by,
	  p_CREATION_DATE  					=> p_debrief_line_rec.creation_date,
	  p_LAST_UPDATED_BY  				=> 	nvl(p_debrief_line_rec.last_updated_by,g_user_id),
	  p_LAST_UPDATE_DATE  				=> 	nvl(p_debrief_line_rec.last_update_date,sysdate),
	  p_LAST_UPDATE_LOGIN  				=> 	nvl(p_debrief_line_rec.last_update_login,g_login_id),
	  p_ATTRIBUTE1  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE1,
	  p_ATTRIBUTE2  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE2,
	  p_ATTRIBUTE3  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE3,
	  p_ATTRIBUTE4  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE4,
	  p_ATTRIBUTE5  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE5,
	  p_ATTRIBUTE6  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE6,
	  p_ATTRIBUTE7  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE7,
	  p_ATTRIBUTE8  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE8,
	  p_ATTRIBUTE9  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE9,
	  p_ATTRIBUTE10  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE10,
	  p_ATTRIBUTE11  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE11,
	  p_ATTRIBUTE12  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE12,
	  p_ATTRIBUTE13  					=>	p_DEBRIEF_LINE_rec.ATTRIBUTE13,
	  p_ATTRIBUTE14  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE14,
	  p_ATTRIBUTE15  					=> 	p_DEBRIEF_LINE_rec.ATTRIBUTE15,
	  p_ATTRIBUTE_CATEGORY  			        =>      p_DEBRIEF_LINE_rec.ATTRIBUTE_CATEGORY,
	  P_TRANSACTION_TYPE_ID    		   		=>      P_DEBRIEF_LINE_REC.TRANSACTION_TYPE_ID,
      p_RETURN_DATE                            =>	p_DEBRIEF_LINE_rec.RETURN_DATE
	  );

--Update actual times for task and task assignment
      if l_debrief_type = 'L' then
        update_task_actuals(p_debrief_line_rec.debrief_header_id, -- modified for bug 3748610
                            x_return_status,
                            x_msg_count,
                            x_msg_data);
      end if;

	-- Calling the Update Resource Location API to Update Resource's Locatio
          if l_debrief_type='L' then
             Begin
	        select		 jta.resource_id,
	  			 loc.geometry
	  	into		 z_resource_id,
	 			 z_location
	  	from    	 csf_debrief_lines     cdl,
       	 	        	 csf_debrief_headers csf,
 				 jtf_task_assignments jta,
		       		 jtf_tasks_b    jtb,
		       		 hz_party_sites p,
		       		 hz_locations   loc
		where  		csf.debrief_header_id	   =   l_debrief_line_rec.debrief_header_id
		and     	debrief_line_id   	   =   l_debrief_line_id
		and		csf.debrief_header_id      =   cdl.debrief_header_id
		and		jta.task_assignment_id	   =   csf.task_assignment_id
		and		jta.task_id		   =   jtb.task_id
		and		jtb.address_id		   =   p.party_site_id
		and		p.location_id		   =   loc.location_id;

	  	select 	 max(actual_start_date)
	  	into	 z_start_date
	 	 from 	 jtf_task_assignments
	  	where    resource_id = z_resource_id;

	  	IF p_debrief_line_rec.labor_start_date > z_start_date then
   	  		select 	object_version_number
  			into	z_object_version_number
   			from	jtf_rs_resource_extns
   			where	resource_id	= z_resource_id;


 		/*	jtf_rs_resource_pub.update_resource
    			(P_API_VERSION 	=> 1,
    		 	P_INIT_MSG_LIST 	=> fnd_api.g_false,
    		 	P_COMMIT 		=> fnd_api.g_false,
    		 	P_RESOURCE_ID 	=> z_resource_id,
    			 P_RESOURCE_NUMBER	=> null,
    	 		P_LOCATION 		=> z_location,
    			 P_object_version_num =>  z_object_version_number,
     		 	X_RETURN_STATUS      =>  x_return_status,
    	 		X_MSG_COUNT          =>  x_msg_count,
    	 		X_MSG_DATA           =>  x_msg_data);
                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           Raise   FND_API.G_EXC_ERROR;
                        END IF;
*/
                END IF;

            Exception
             When NO_DATA_FOUND then
             NULL;
            End;
         End if;
	-- Calling the Update Task Assignment API Location API to Update Resource's Location

	if  P_Upd_tskassgnstatus = 'Y' then

	     BEGIN
	        Validate_Task_Assignment_Satus(
                   P_Api_Version_Number         =>1.0,
                   P_Init_Msg_List              => FND_API.G_FALSE,
                   P_Commit                     => FND_API.G_FALSE,
                   P_Task_Assignment_status     =>P_Task_Assignment_status,
                   X_TA_STATUS_ID               =>l_assignment_status_id,
                   X_Return_Status              =>X_Return_Status,
                   X_Msg_Count                  =>X_MSG_COUNT,
                   X_Msg_Data                   =>X_MSG_DATA);
                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;

	           select  jta.task_assignment_id,
       			  jta.object_version_number,
       			  jta.task_id
 		   into    l_task_assignment_id,
       			  l_object_version_number,
       			  l_task_id
 		   from    jtf_task_assignments jta,
   	 	          csf_debrief_headers csf
 		   where    csf.task_assignment_id     = jta.task_assignment_id
		   and      csf.debrief_header_id      = p_debrief_line_rec.debrief_header_id;


		  CSF_TASK_ASSIGNMENTS_PUB.UPDATE_ASSIGNMENT_STATUS(
		 P_API_VERSION                 =>1.0            ,
 	         P_INIT_MSG_LIST               =>FND_API.G_FALSE,
 	         P_COMMIT                      =>FND_API.G_FALSE,
                 X_RETURN_STATUS               =>x_return_status,
                 X_MSG_COUNT                   =>x_msg_count,
                 X_MSG_DATA                    =>x_msg_data,
                 P_TASK_ASSIGNMENT_ID          =>l_task_assignment_id,
                 P_ASSIGNMENT_STATUS_ID        =>l_assignment_status_id,
                 P_OBJECT_VERSION_NUMBER       =>l_object_version_number,
                 P_UPDATE_TASK                 =>'T',
                 X_TASK_OBJECT_VERSION_NUMBER  =>l_task_object_version_number,
                 X_TASK_STATUS_ID              =>l_task_status_id);
                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;

            EXCEPTION
            WHEN OTHERS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_UPDATE_TASK_ASSIGNMENT');
                  FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
            END;
          end if;

-- Call concurrent program if assignment status is completed,closed,rejected,canceled
   open  c_status(p_debrief_line_rec.debrief_header_id);
   fetch c_status into l_call_cp;
   close c_status;
   if nvl(l_call_cp,'N') = 'Y' then
     l_request_id := fnd_request.submit_request(
                       'CSF',
                       'CSFUPDATE',
                       'CSF:Update Debrief Lines',
                       null,
                       FALSE,
                       1.0,
                       p_debrief_line_rec.debrief_header_id);
   end if;

     	 -- Standard check for p_commit
     	 IF FND_API.to_Boolean( p_commit )
      	THEN
         	 COMMIT WORK;
     	 END IF;

     	 -- Debug Message
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
         THEN
               FND_MESSAGE.Set_Name('CSF', l_api_name);
               FND_MESSAGE.Set_Token ('INFO', G_PKG_NAME, FALSE);
               FND_MSG_PUB.Add;
           END IF;

   	   -- Standard call to get message count and if count is 1, get message info.
     	 FND_MSG_PUB.Count_And_Get
      	(  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
     	 );
 end if;  -- if charge_upload_status='INTERFACED'
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_LINE_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_LINE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

          WHEN OTHERS THEN
		    ROLLBACK TO  UPDATE_DEBRIEF_LINE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				IF FND_MSG_PUB.Check_Msg_Level
					 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			     THEN
				   FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME ,L_API_NAME );
				 END IF;

				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

End Update_debrief_line;


PROCEDURE Validate_Service_Date (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Service_Date	             IN   DATE,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (p_service_date is NULL OR p_service_date = FND_API.G_MISS_DATE) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('CSF', 'CSF_DEBRIEF_SERVICE_DATE');
                FND_MSG_PUB.ADD;
             END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Service_Date;

PROCEDURE validate_subinventory_code (
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	p_organization_id            IN   number,
        p_subinventory_code          in   varchar2,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  l_organization_code                varchar2(30) := null;
  l_subinventory_code                varchar2(30) := null;

  cursor c_subinventory_code is
  select mp.organization_code,
         msi.secondary_inventory_name
  from   mtl_secondary_inventories msi,
         mtl_parameters mp
  where  mp.organization_id = p_organization_id
  and    msi.organization_id = mp.organization_id
  and    secondary_inventory_name = p_subinventory_code;

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      open  c_subinventory_code;
      fetch c_subinventory_code into l_organization_code,l_subinventory_code;
      close c_subinventory_code;
      IF l_subinventory_code is NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('CSP', 'CSP_INVALID_ORG_SUBINV');
          FND_MESSAGE.set_token('ORG',l_organization_code,TRUE);
          FND_MESSAGE.set_token('SUBINV',l_subinventory_code,TRUE);
          FND_MSG_PUB.ADD;
        END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

END validate_subinventory_code;

PROCEDURE Validate_Inventory_Item_ID (
  P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
  p_organization_id            IN   NUMBER,
  P_Inventory_Item_ID	       IN   NUMBER,
  X_Return_Status              OUT NOCOPY  VARCHAR2,
  X_Msg_Count                  OUT NOCOPY  NUMBER,
  X_Msg_Data                   OUT NOCOPY  VARCHAR2) IS

  l_inventory_item_id         number;
  cursor c_inventory_item is
  select msib.inventory_item_id
  from   mtl_system_items_b msib,cs_billing_type_categories cbtc
  where  msib.organization_id = nvl(p_organization_id,fnd_profile.value('CS_INV_VALIDATION_ORG'))
  and    msib.inventory_item_id = p_inventory_item_id
  and    msib.material_billable_flag = cbtc.billing_type;

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_inventory_item_id := null;
      open  c_inventory_item;
      fetch c_inventory_item into l_inventory_item_id;
      close c_inventory_item;
      IF l_inventory_item_id is null THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_INVENTORY_ITEM_ID');
                FND_MSG_PUB.ADD;
          END IF;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Inventory_Item_ID;

PROCEDURE Validate_Instance_ID (
	P_Init_Msg_List                  IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Instance_ID                IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
 l_dummy  number;

 cursor get_INSTANCE_ID is
 select 1
 from csi_item_instances
 where INSTANCE_ID=P_INSTANCE_ID;

 Begin

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (p_instance_id is NOT NULL and  p_instance_id <> FND_API.G_MISS_NUM ) THEN
             open get_instance_id;
             fetch get_instance_id into l_dummy;
             if get_instance_id%notfound then
                close get_instance_id;
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_INSTANCE_ID');
                   FND_MSG_PUB.ADD;
                 END IF;
             end if;
             close get_instance_id;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_Instance_ID;

PROCEDURE Validate_Debrief_Header_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Debrief_Header_ID	     IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
 l_dummy number;
 cursor validate_header_id is
 select 1
 from csf_debrief_headers
 where debrief_header_id=p_debrief_header_id;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (P_DEBRIEF_HEADER_ID is NULL OR P_DEBRIEF_HEADER_ID = FND_API.G_MISS_NUM) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_HEADER_ID');
             FND_MSG_PUB.ADD;
           END IF;
      ELSE
          open validate_header_id;
          fetch validate_header_id into l_dummy;
          if validate_header_id%notfound then
--             close validate_header_id;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_HEADER_ID');
                FND_MSG_PUB.ADD;
             END IF;
          end if;
          close validate_header_id ;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEBRIEF_HEADER_ID;



PROCEDURE Validate_DEBRIEF_LINE_NUMBER (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_Validation_mode            IN   VARCHAR2,
    	P_DEBRIEF_LINE_NUMBER         IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_name   varchar2(30) := 'Create Debrief Line' ;
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = G_CREATE) THEN
           IF (p_debrief_line_number is NULL OR p_debrief_line_number = FND_API.G_MISS_NUM ) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSIF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSF', l_api_name);
              FND_MESSAGE.Set_Token('COLUMN', 'DEBRIEF_LINE_NUMBER', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DEBRIEF_LINE_NUMBER;

PROCEDURE Validate_BUSINESS_PROCESS_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_BUSINESS_PROCESS_ID        IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
 l_dummy  number;
 cursor get_BUSINESS_PROCESS_ID is
 select 1
 from cs_business_processes
 where BUSINESS_PROCESS_ID=P_BUSINESS_PROCESS_ID;
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (p_business_process_id is NULL OR p_business_process_id = FND_API.G_MISS_NUM ) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_BUS_PROCESS_ID');
             FND_MSG_PUB.ADD;
           END IF;
      ELSE
             open get_business_process_id;
             fetch get_business_process_id into l_dummy;
             if get_business_process_id%notfound then
                close get_business_process_id;
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_BUS_PROCESS_ID');
                   FND_MSG_PUB.ADD;
                 END IF;
             end if;
             close get_business_process_id;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_BUSINESS_PROCESS_ID;
PROCEDURE Validate_TRANSACTION_TYPE_ID (
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    	P_TRANSACTION_TYPE_ID        IN   NUMBER,
    	X_Return_Status              OUT NOCOPY  VARCHAR2,
    	X_Msg_Count                  OUT NOCOPY  NUMBER,
    	X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
 l_dummy  number;
 cursor get_transaction_type_id is
 select 1
 from cs_transaction_types vl
 where transaction_type_id=P_Transaction_type_id;
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (p_transaction_type_id is NULL OR p_transaction_type_id = FND_API.G_MISS_NUM ) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_TXN_BILLING_TYP_ID');
             FND_MSG_PUB.ADD;
           END IF;
      ELSE
             open get_transaction_type_id;
             fetch get_transaction_type_id into l_dummy;
             if get_transaction_type_id%notfound then
                close get_transaction_type_id;
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_TXN_BILLING_TYP_ID');
                   FND_MSG_PUB.ADD;
                 END IF;
             end if;
             close get_transaction_type_id;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_TRANSACTION_TYPE_ID;


Procedure CREATE_INTERACTION(P_Api_Version_Number         IN   NUMBER,
                              P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                              P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
                              P_TASK_ASSIGNMENT_ID         IN   NUMBER,
                              P_DEBRIEF_HEADER_ID          IN   NUMBER,
                              P_MEDIA_ID                   IN   NUMBER,
                              P_ACTION_ID                  IN   NUMBER,
                              X_RETURN_STATUS              OUT NOCOPY  VARCHAR2,
                              X_Msg_Count                  OUT NOCOPY  NUMBER,
                              X_Msg_Data                   OUT NOCOPY  VARCHAR2) is

  l_api_version_number  number :=1.0;
  l_api_name            varchar2(50):='CREATE_INTERACTION';
  l_interaction_rec     JTF_IH_PUB.Interaction_Rec_Type;
  l_activity_rec        JTF_IH_PUB.Activity_Rec_Type;
  l_task_id             number;
  l_party_id            number;
  l_cust_account_id     number;
  l_resource_id         number;
  l_msg_count           number;
  l_msg_data            varchar2(200);
  l_return_status       varchar2(20);
  l_interaction_id      number;
  l_activity_id         number;
  l_msg_index_out       number;
Begin
        -- Standard Start of API savepoint
      SAVEPOINT CREATE_INTERACTION;
      -- Standard call to check for call compatibility.

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       select jtb.task_id,
	       jtb.customer_id,
	       jtb.cust_account_id,
               jta.resource_id
	into   l_task_id,
	       l_party_id,
	       l_cust_account_id,
               l_resource_id
       from 	 jtf_task_assignments jta,
		 jtf_tasks_b  jtb
       where  jta.task_id   = jtb.task_id
       and    jta.task_assignment_id  =  P_task_assignment_id;

	-- Virendra Singh 03/21/2000
	-- Initialize interaction record

	l_interaction_rec.handler_id      := 747;
	l_interaction_rec.outcome_id      := 7;
	l_interaction_rec.resource_id     := l_resource_id;
	l_interaction_rec.party_id        := l_party_id;
       -- open interaction
	jtf_ih_pub.Open_Interaction(
	  p_api_version		        => 1.0,
	  p_init_msg_list		=> FND_API.G_TRUE,
	  p_commit			=> FND_API.G_FALSE,
	  p_user_id                     => G_USER_ID,
	  x_return_status		=>l_return_status,
	  x_msg_count		        =>l_msg_count,
	  x_msg_data		        =>l_msg_data,
    	  p_interaction_rec 	        =>l_interaction_rec,
	  x_interaction_id 		=>l_interaction_id  );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        FND_MSG_PUB.GET(P_MSG_INDEX=>1,
                     P_ENCODED=>'F',
                     p_data=>l_msg_data,
                     p_MSG_index_out=>l_msg_index_out);

          -- Initialise activity record
	l_activity_rec.cust_account_id   :=l_cust_account_id;
	l_activity_rec.task_id 	         :=l_task_id;
	l_activity_rec.doc_id            :=P_debrief_header_id;
	l_activity_rec.doc_ref           :='DEBRIEF_HEADER';
        l_activity_rec.media_id          :=P_MEDIA_ID;
        l_activity_rec.action_item_id    :='FSR';
	l_activity_rec.interaction_id    :=l_interaction_id;
	l_activity_rec.outcome_id        :=7 ;
	l_activity_rec.action_id         :=P_ACTION_ID;
        l_return_status:=NULL;
      -- add activity
	jtf_ih_pub.add_activity(
          p_api_version		        => 1.0,
	  p_init_msg_list		=> FND_API.G_FALSE,
	  p_commit			=> FND_API.G_FALSE,
	  p_user_id                     =>G_USER_ID,
	  x_return_status		=>l_return_status,
	  x_msg_count		        =>l_msg_count,
	  x_msg_data		        =>l_msg_data,
	  p_activity_rec                =>l_activity_rec,
	  x_activity_id                 =>l_activity_id);
         if l_return_status<>FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;
         -- close interaction
          l_return_status:=NULL;
          jtf_ih_pub.Close_Interaction(
	  p_api_version		        => 1.0,
	  p_init_msg_list		=> FND_API.G_FALSE,
	  p_commit			=> FND_API.G_FALSE,
	  p_user_id                     => G_USER_ID,
	  x_return_status		=>l_return_status,
	  x_msg_count		        =>l_msg_count,
	  x_msg_data		        =>l_msg_data,
    	  p_interaction_rec 	        =>l_interaction_rec );

          if l_return_status<>FND_API.G_RET_STS_SUCCESS then
             raise FND_API.G_EXC_ERROR;
          end if;
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
	      ROLLBACK TO  CREATE_INTERACTION;
              x_return_status := FND_API.G_RET_STS_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ROLLBACK TO  CREATE_INTERACTION;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				 FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

          WHEN OTHERS THEN
              ROLLBACK TO  CREATE_INTERACTION;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,L_API_NAME);
	      END IF;
              FND_MSG_PUB.Count_And_Get (
                   P_COUNT => X_MSG_COUNT
                  ,P_DATA  => X_MSG_DATA);

END;

PROCEDURE UPDATE_TASK_ACTUAL_DATES (
      p_task_id                      IN NUMBER,
      p_actual_start_date            IN DATE,
      p_actual_end_date              IN DATE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2
  ) IS
  l_version number;
  cursor c_version is
         SELECT OBJECT_VERSION_NUMBER
         FROM JTF_TASKS_VL
         WHERE TASK_ID = p_task_id;
  BEGIN
  OPEN C_VERSION;
  FETCH C_VERSION INTO l_version;
  CLOSE C_VERSION;


  csf_tasks_pub.update_task (
      p_api_version                  => 1.0,
      p_object_version_number        => l_version,
      p_task_id                      => p_task_id,
      p_actual_start_date            => p_actual_start_date,
      p_actual_end_date              => p_actual_end_date,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data
  ) ;



  END;

procedure update_actual_times (
  p_task_assignment_id    in number,
  x_return_status         out nocopy varchar2,
  x_msg_count             out nocopy number,
  x_msg_data              out nocopy varchar2) IS

  cursor c_actual_times is
  select max(cdh.debrief_header_id),
         min(cdl.labor_start_date),
         max(cdl.labor_end_date)
  from   csf_debrief_headers cdh,
         csf_debrief_lines cdl
  where  cdh.task_assignment_id = p_task_assignment_id
  and    cdl.debrief_header_id = cdh.debrief_header_id
  and    cdl.labor_start_date is not null
  and    cdl.labor_end_date is not null;

  cursor c_Debrief_header_for_cleanup is
  select cdh.debrief_header_id
  from   csf_debrief_headers cdh,jtf_task_assignments jta
  where  cdh.task_assignment_id = jta.task_assignment_id
  and jta.task_assignment_id =p_task_assignment_id
  and (jta.actual_start_date is not null
  or  jta.actual_end_date is not null
  or  jta.actual_effort is not null);

  l_debrief_header_id       number;
  l_labor_start_date        date;
  l_labor_end_date          date;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  open  c_actual_times;
  fetch c_actual_times into l_debrief_header_id,
                            l_labor_start_date,
                            l_labor_end_date;
  close c_actual_times;

  if l_debrief_header_id is null then
   open  c_Debrief_header_for_cleanup;
   fetch c_Debrief_header_for_cleanup into l_debrief_header_id;

   close c_Debrief_header_for_cleanup;
  end if;
  if l_debrief_header_id is not null then
    update_task_actuals(l_debrief_header_id,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);
  end if;
end;

procedure update_actual_times (
  p_debrief_header_id     in number,
  p_start_date            in date,
  p_end_date              in date,
  x_return_status         out nocopy varchar2,
  x_msg_count             out nocopy number,
  x_msg_data              out nocopy varchar2) IS

  l_task_id              number := null;
  l_task_assignment_id   number := null;
  l_start_date           date   := null;
  l_end_date             date   := null;
  l_object_version       number := null;
  l_resource_type_code   varchar2(30) := null;
  l_resource_id          number := null;
  l_task_object_version  number := null;
  l_task_status_id       number := null;

  cursor c_task_assignment is
  select task_id,
         jta.task_assignment_id,
         least(nvl(actual_start_date,p_start_date),
               nvl(p_start_date,fnd_api.g_miss_date)),
         greatest(nvl(actual_end_date,p_end_date),
               nvl(p_end_date,fnd_api.g_miss_date)),
         jta.object_version_number,
         jta.resource_type_code,
         jta.resource_id
  from   jtf_task_assignments jta,
         csf_debrief_headers cdh
  where  debrief_header_id = p_debrief_header_id
  and    jta.task_assignment_id = cdh.task_assignment_id
  and    (nvl(actual_start_date,p_start_date) >=
          nvl(p_start_date,actual_start_date)
       or nvl(actual_end_date,p_end_date) <=
          nvl(p_end_date,actual_end_date));

  cursor c_task is
  select least(nvl(actual_start_date,p_start_date),
               nvl(p_start_date,fnd_api.g_miss_date)),
         greatest(nvl(actual_end_date,p_end_date),
               nvl(p_end_date,fnd_api.g_miss_date)),
         object_version_number
  from   jtf_tasks_b
  where  task_id = l_task_id
  and    (nvl(actual_start_date,p_start_date) >=
          nvl(p_start_date,actual_start_date)
       or nvl(actual_end_date,p_end_date) <=
          nvl(p_end_date,actual_end_date));

BEGIN
-- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  open  c_task_assignment;
  fetch c_task_assignment into l_task_id,
                               l_task_assignment_id,
                               l_start_date,
                               l_end_date,
                               l_object_version,
                               l_resource_type_code,
                               l_resource_id;
  close c_task_assignment;

  if l_object_version is not null then
    csf_task_assignments_pub.update_task_assignment (
      p_api_version                  => 1.0,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_task_assignment_id           => l_task_assignment_id,
      p_object_version_number        => l_object_version,
      p_actual_start_date            => l_start_date,
      p_actual_end_date              => l_end_date,
      p_resource_type_code           => l_resource_type_code,
      p_resource_id                  => l_resource_id,
      x_task_object_version_number   => l_task_object_version,
      x_task_status_id               => l_task_status_id);

      l_object_version := null;

      open  c_task;
      fetch c_task into l_start_date,l_end_date,l_object_version;
      close c_task;

      if l_object_version is not null then
        csf_tasks_pub.update_task (
          p_api_version                  => 1.0,
          p_object_version_number        => l_object_version,
          p_task_id                      => l_task_id,
          p_actual_start_date            => l_start_date,
          p_actual_end_date              => l_end_date,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data) ;
      end if;
  end if;

END;
PROCEDURE VALIDATE_COUNTERS (
      P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
      p_task_id         in number,
      p_incident_id        in number,
      x_return_status              out nocopy varchar2,
      x_msg_count                  out nocopy number,
      x_msg_data                   out nocopy varchar2
  ) is
l_count number;
l_count2 number;
cursor c_counter is
  select count(*)  --cs_ctr.name, cs_ctr_v.value_timestamp
  from cs_incidents_all_b ci_all,
    cs_counter_groups  cs_grp,
    cs_counters        cs_ctr,
    cs_counter_values  cs_ctr_v,
    jtf_tasks_b        jt_b
  where ci_all.incident_id = p_incident_id
  and ci_all.customer_product_id = cs_grp.source_object_id
  and cs_grp.source_object_code = 'CP'
  and cs_ctr.type = 'REGULAR'
  and cs_ctr.counter_group_id = cs_grp.counter_group_id
  and cs_ctr_v.counter_id(+)= cs_ctr.counter_id
  and jt_b.task_id  = p_task_id
  and nvl(cs_ctr_v.value_timestamp,jt_b.creation_date - 1) < least(jt_b.creation_date,sysdate); -- changed for bug 3558815

cursor c_counter2 is
  Select count(*) from
cs_incidents_all_b ci_all,
cs_counter_groups cs_grp,
cs_counters cs_ctr,
cs_counter_values cs_ctr_v,
jtf_tasks_b jt_b
where ci_all.incident_id = p_incident_id
 and ci_all.customer_product_id = cs_grp.source_object_id
 and cs_grp.source_object_code = 'CP'
 and cs_ctr.type = 'REGULAR'
 and cs_ctr.counter_group_id = cs_grp.counter_group_id
 and cs_ctr_v.counter_id = cs_ctr.counter_id
 and jt_b.task_id = p_task_id
 and cs_ctr_v.value_timestamp between jt_b.creation_date and sysdate ; -- changed for bug 3558815

begin

  open c_counter;
  fetch c_counter into l_count;
  close c_counter;

  if l_count > 0 then
	open c_counter2;
        fetch c_counter2 into l_count2;
        close c_counter2;
  end if;

  if l_count = 0 Then
	x_return_status := 'S' ;
        x_msg_data := 'Is not needed to enter counters now';
   else
	if l_count2 = 0 Then
	  x_return_status := 'E';
          x_msg_data := 'Counters should be entered';
        end if;
   end if;
end;


PROCEDURE VALIDATE_LABOR_TIMES (
      P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
      P_api_version_number         In  number,
      p_resource_type_code         in  Varchar2,
      p_resource_id                in  Number,
      p_debrief_line_id            in  Number,
      p_labor_start_date           in  Date,
      p_labor_end_date             in  Date,
      x_return_status              out nocopy varchar2,
      x_msg_count                  out nocopy number,
      x_msg_data                   out nocopy varchar2,
      x_debrief_number             out nocopy number,
      x_task_number                out nocopy varchar2
  ) is


l_labor_start_date  date;
l_labor_end_date    date;
l_profile           varchar2(10) := fnd_profile.value('CSF_DEBRIEF_OVERLAPPING_LABOR');

cursor c_val is
Select cdh.debrief_number,
       cdl.labor_start_date,
       cdl.labor_end_date,
       jtb.task_number
from   csf_debrief_lines cdl,
       csf_debrief_headers cdh,
       jtf_task_assignments jta ,
       jtf_tasks_b jtb
where  cdh.debrief_header_id = cdl.debrief_header_id
and    jta.task_assignment_id = cdh.task_assignment_id
and    cdl.labor_start_date is not null
and    ((p_debrief_line_id is not null
and    cdl.debrief_line_id <> p_debrief_line_id)
or     (p_debrief_line_id is null))
and    jta.resource_type_code = p_resource_type_code
and    jta.resource_id = p_resource_id
and    jtb.task_id = jta.task_id
and    (p_labor_start_date >= cdl.labor_start_date and p_labor_start_date < cdl.labor_end_date
     or p_labor_end_date   > cdl.labor_start_date and p_labor_end_date   < cdl.labor_end_date
     or cdl.labor_start_date > p_labor_start_date and cdl.labor_start_date < p_labor_end_date
     or cdl.labor_end_date   > p_labor_start_date and cdl.labor_end_date   < p_labor_end_date);


begin

if l_profile ='N' Then --not allowed, needs to be checked

    open c_val;
    fetch c_val into x_debrief_number,
                     l_labor_start_date,
                     l_labor_end_date,
                     x_task_number;

    if c_val%notfound Then x_return_status := 'S' ;
                           x_msg_data := 'Overlapping is not allowed and there are no labor lines overlapping';
        else x_return_status :='E';
        x_msg_data := 'Overlapping is not allowed and there are labor lines overlapping';
    end if;
    close c_val;
   ELSE x_return_status:='S';
        x_msg_data := 'Overlapping is allowed. There might be overlapping lines';

end if;


end;

PROCEDURE TASK_ASSIGNMENT_PRE_UPDATE(x_return_status out nocopy varchar2)  is
   l_task_assignment_id number := null;
   l_old_resource_type  varchar2(100) := null;
   l_old_resource_id    number := null;
   l_new_resource_type  varchar2(100) := null;
   l_new_resource_id    number := null;
   l_debrief_header_id  number := null;
 begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_task_assignment_id :=
JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_assignment_id;
   l_new_resource_id :=
JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.resource_id;
   l_new_resource_type :=
JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.resource_type_code;

   select cdh.debrief_header_id,resource_type_code,resource_id
   into   l_debrief_header_id,l_old_resource_type,l_old_resource_id
   from   csf_debrief_headers cdh,jtf_task_assignments jta,csf_debrief_lines cdl
   where  jta.task_assignment_id = l_task_assignment_id
   and    cdl.debrief_header_id = cdh.debrief_header_id
   and    cdh.task_assignment_id = jta.task_assignment_id;

   if l_debrief_header_id is not null then
     if l_old_resource_type <> l_new_resource_type or
        l_old_resource_id <> l_new_resource_id then
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_EXISTS');
       FND_MSG_PUB.ADD;
     end if;
   end if;

   exception
   when others then
     null;
end;

PROCEDURE TASK_ASSIGNMENT_PRE_DELETE(x_return_status out nocopy varchar2)  is
   l_task_assignment_id number := null;
   l_debrief_header_id  number := null;
 begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_task_assignment_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_assignment_id;
   select debrief_header_id
   into   l_debrief_header_id
   from   csf_debrief_headers
   where  task_assignment_id = l_task_assignment_id;

   if l_debrief_header_id is not null then
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_EXISTS');
     FND_MSG_PUB.ADD;
   end if;

   exception
   when others then
     null;
end;

PROCEDURE TASK_ASSIGNMENT_POST_UPDATE(x_return_status out nocopy varchar2) is
  l_msg_data            varchar(2000);
  l_msg_count           number;
  l_return_status       varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  l_travel_start_date   date;
  l_travel_end_date     date;
  l_travel_exists       varchar2(1);
  l_working_start_date  date;
  l_working_end_date    date;
  l_working_exists      varchar2(1);
  l_debrief_header_id   number;
  l_record_counter      number := 1;
  l_task_assignment_id  number;
  l_transaction_type_id number;
  l_business_process_id number;
  l_resource_type_code  varchar2(60);
  l_resource_id         number;
  l_assignment_status_id number;
  l_working_flag        varchar2(1);
  l_travel_flag         varchar2(1);
  l_task_id             number;
  l_task_type_rule      varchar2(60);
  l_any_working_task    varchar2(1) := 'N';

  l_debrief_header csf_debrief_pub.debrief_rec_type;
  l_debrief_line  csf_debrief_pub.debrief_line_tbl_type;

  cursor c_header_id(p_task_assignment_id number) is
  select debrief_header_id
  from   csf_debrief_headers
  where  task_assignment_id = p_task_assignment_id;

  cursor c_travel_exists(p_task_assignment_id number) is
  select 'Y'
  from   csf_debrief_headers cdh,
         csf_debrief_lines cdl,
         cs_transaction_types ctt,
         cs_txn_billing_types ctbt
  where  cdh.task_assignment_id = p_task_assignment_id
  and    cdl.debrief_header_id = cdh.debrief_header_id
  and    ctt.transaction_type_id = cdl.transaction_type_id
  and    ctbt.transaction_type_id = ctt.transaction_type_id
  and    ctbt.billing_type = 'L'
  and    ctt.travel_flag = 'Y';

  cursor c_working_exists(p_task_assignment_id number) is
  select 'Y'
  from   csf_debrief_headers cdh,
         csf_debrief_lines cdl,
         cs_transaction_types ctt,
         cs_txn_billing_types ctbt
  where  cdh.task_assignment_id = p_task_assignment_id
  and    cdl.debrief_header_id = cdh.debrief_header_id
  and    ctt.transaction_type_id = cdl.transaction_type_id
  and    ctbt.transaction_type_id = ctt.transaction_type_id
  and    ctbt.billing_type = 'L'
  and    nvl(ctt.travel_flag,'N') = 'N';

  cursor c_audit_travel(p_task_assignment_id number) is
  select jtsbold.travel_flag old_travel_flag,
         jtsbnew.travel_flag new_travel_flag,
         jtaab.creation_date
  from   jtf_task_assignments_audit_b jtaab,
         jtf_task_statuses_b jtsbnew,
         jtf_task_statuses_b jtsbold
  where  jtsbold.task_status_id = jtaab.old_assignment_status_id
  and    jtsbnew.task_status_id = jtaab.new_assignment_status_id
  and    jtaab.old_assignment_status_id <> jtaab.new_assignment_status_id
  and    jtaab.assignment_id = p_task_assignment_id
  order by jtaab.creation_date desc;

  cursor c_audit_working(p_task_assignment_id number) is
  select jtsbold.working_flag old_working_flag,
         jtsbnew.working_flag new_working_flag,
         jtaab.creation_date
  from   jtf_task_assignments_audit_b jtaab,
         jtf_task_statuses_b jtsbnew,
         jtf_task_statuses_b jtsbold
  where  jtsbold.task_status_id = jtaab.old_assignment_status_id
  and    jtsbnew.task_status_id = jtaab.new_assignment_status_id
  and    jtaab.old_assignment_status_id <> jtaab.new_assignment_status_id
  and    jtaab.assignment_id = p_task_assignment_id
  order by jtaab.creation_date desc;

  cursor c_working_flag is
  select working_flag,travel_flag
  from   jtf_task_statuses_b
  where  task_status_id = l_assignment_status_id;

  cursor c_task_type_rule is
  select jttb.rule
  from   jtf_task_types_b jttb,
         jtf_tasks_b jtb
  where  jtb.task_id = l_task_id
  and    jttb.task_type_id = jtb.task_type_id;

  cursor c_any_working_task is
  select 'Y'
  from   jtf_task_assignments jta,
         jtf_task_statuses_b jtsb
  where  assignee_role = 'ASSIGNEE'
  and    resource_type_code = l_resource_type_code
  and    resource_id = l_resource_id
  and    jtsb.task_status_id = jta.assignment_status_id
  and    (working_flag = 'Y' or travel_flag = 'Y');

begin
 l_task_id :=
   JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_id;
 open  c_task_type_rule;
 fetch c_task_type_rule into l_task_type_rule;
 close c_task_type_rule;
 if l_task_type_rule = 'DISPATCH' then
  l_task_assignment_id :=
   JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_assignment_id;

  l_resource_type_code :=
    JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.resource_type_code;
  l_resource_id :=
    JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.resource_id;
  l_assignment_status_id :=
    JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.assignment_status_id;

  open  c_working_flag;
  fetch c_working_flag into l_working_flag,l_travel_flag;
  close c_working_flag;
  if nvl(l_working_flag,'N') = 'Y' or nvl(l_travel_flag,'N') = 'Y' then
    update csp_planning_parameters cpp
    set    hz_location_id =
    (select hps.location_id
     from   hz_party_sites hps,
            jtf_tasks_b jtb,
            jtf_task_assignments jta
     where  hps.party_site_id = jtb.address_id
     and    jta.task_id = jtb.task_id
     and    jta.task_assignment_id = l_task_assignment_id)
    where   cpp.stocking_site_type = 'TECHNICIAN'
    and     (cpp.organization_id,cpp.secondary_inventory) in
    (select csi.organization_id,
            csi.secondary_inventory_name
     from   csp_sec_inventories csi
     where  csi.owner_resource_type = l_resource_type_code
     and    csi.owner_resource_id = l_resource_id);
  else
    open  c_any_working_task;
    fetch c_any_working_task into l_any_working_task;
    close c_any_working_task;
    if l_any_working_task = 'N' then
      update csp_planning_parameters cpp
      set    hz_location_id =
      (select min(hps.location_id)
       from hz_party_sites hps, csp_rs_cust_relations crcr,
hz_cust_acct_sites_all hcasa,hz_cust_site_uses_all hcsua
       where crcr.customer_id = hcasa.cust_account_id
       and   hcasa.party_site_id = hps.party_site_id
       and   crcr.resource_type = l_resource_type_code
       and   crcr.resource_id = l_resource_id
       and   hcsua.site_use_code = 'SHIP_TO'
       and   hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
       and   hcsua.primary_flag = 'Y'
       and   hcsua.status = 'A')
      where   cpp.stocking_site_type = 'TECHNICIAN'
      and     (cpp.organization_id,cpp.secondary_inventory) in
      (select csi.organization_id,
              csi.secondary_inventory_name
       from   csp_sec_inventories csi
       where  csi.owner_resource_type = l_resource_type_code
       and    csi.owner_resource_id = l_resource_id);
    end if;
  end if;

  if fnd_profile.value('CSF_DEFAULT_LABOR_DEBRIEF_DATETIME') = 'STATUS' then
    open  c_travel_exists(l_task_assignment_id);
    fetch c_travel_exists into l_travel_exists;
    close c_travel_exists;
    l_travel_exists := nvl(l_travel_exists,'N');
    if l_travel_exists = 'N' then
      for cr in c_audit_travel(l_task_assignment_id) loop
        if cr.old_travel_flag = 'Y' then
          l_travel_end_date := cr.creation_date;
        elsif cr.new_travel_flag = 'Y' then
          l_travel_start_date := cr.creation_date;
          exit;
        end if;
      end loop;
    end if;
    open  c_working_exists(l_task_assignment_id);
    fetch c_working_exists into l_working_exists;
    close c_working_exists;
    l_working_exists := nvl(l_working_exists,'N');
    if l_working_exists = 'N' then
      for cr in c_audit_working(l_task_assignment_id) loop
        if cr.old_working_flag = 'Y' then
          l_working_end_date := cr.creation_date;
        elsif cr.new_working_flag = 'Y' then
          l_working_start_date := cr.creation_date;
          exit;
        end if;
      end loop;
    end if;
    open  c_header_id(l_task_assignment_id);
    fetch c_header_id into l_debrief_header_id;
    close c_header_id;

    if l_travel_start_date is not null and l_travel_end_date is not null then
      l_business_process_id :=
        fnd_profile.value('CSF:DEFAULT DEBRIEF BUSINESS PROCESS');
      l_transaction_type_id :=
        fnd_profile.value('CSF_DEBRIEF_TRAVEL_SAC');
      l_debrief_line(l_record_counter).debrief_header_id := l_debrief_header_id;
      l_debrief_line(l_record_counter).service_date := l_travel_end_date;
      l_debrief_line(l_record_counter).labor_start_date := l_travel_start_date;
      l_debrief_line(l_record_counter).labor_end_date := l_travel_end_date;
      l_debrief_line(l_record_counter).created_by := fnd_global.user_id;
      l_debrief_line(l_record_counter).creation_date := sysdate;
      l_debrief_line(l_record_counter).last_updated_by := fnd_global.user_id;
      l_debrief_line(l_record_counter).last_update_date := sysdate;
      l_debrief_line(l_record_counter).last_update_login := fnd_global.user_id;
      l_debrief_line(l_record_counter).business_process_id :=
        l_business_process_id;
      l_debrief_line(l_record_counter).transaction_type_id :=
        l_transaction_type_id;
      l_record_counter := l_record_counter + 1;
    end if;
    if l_working_start_date is not null and l_working_end_date is not null then
      l_business_process_id :=
        fnd_profile.value('CSF:DEFAULT DEBRIEF BUSINESS PROCESS');
      l_transaction_type_id :=
        fnd_profile.value('CSF_DEBRIEF_LABOR_SAC');
      l_debrief_line(l_record_counter).debrief_header_id := l_debrief_header_id;
      l_debrief_line(l_record_counter).service_date := l_working_end_date;
      l_debrief_line(l_record_counter).labor_start_date := l_working_start_date;
      l_debrief_line(l_record_counter).labor_end_date := l_working_end_date;
      l_debrief_line(l_record_counter).created_by := fnd_global.user_id;
      l_debrief_line(l_record_counter).creation_date := sysdate;
      l_debrief_line(l_record_counter).last_updated_by := fnd_global.user_id;
      l_debrief_line(l_record_counter).last_update_date := sysdate;
      l_debrief_line(l_record_counter).last_update_login := fnd_global.user_id;
      l_debrief_line(l_record_counter).business_process_id :=
        l_business_process_id;
      l_debrief_line(l_record_counter).transaction_type_id :=
        l_transaction_type_id;
      l_record_counter := l_record_counter + 1;
    end if;
    if l_record_counter > 1 then
      if l_debrief_header_id is null then
        l_debrief_header.task_assignment_id := l_task_assignment_id;
        csf_debrief_pub.create_debrief(
          p_api_version_number     => 1.0,
          p_debrief_rec            => l_debrief_header,
          p_debrief_line_tbl       => l_debrief_line,
          x_debrief_header_id      => l_debrief_header_id,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data);
      else
        csf_debrief_pub.create_debrief_lines(
          p_api_version_number         => 1.0,
          p_debrief_line_tbl           => l_debrief_line,
          p_debrief_header_id          => l_debrief_header_id,
          p_source_object_type_code    => null,
          x_return_status              => l_return_status,
          x_msg_count                  => l_msg_count,
          x_msg_data                   => l_msg_data);
      end if;
    end if;
  end if;
 end if;
 x_return_status := l_return_status;
end;

function labor_auto_create(
            p_task_assignment_id in number)
  return varchar2 is

  cursor c_labor_auto_create is
  select decode(fnd_profile.value('CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'),
         'STATUS',jtsb.working_flag,'N')
  from   jtf_task_assignments_audit_b jtaab,
         jtf_task_statuses_b jtsb
  where  jtsb.task_status_id = jtaab.new_assignment_status_id
  and    jtaab.assignment_id = p_task_assignment_id
  and    jtsb.working_flag = 'Y';

  l_working_flag varchar2(1) := null;

begin
  open  c_labor_auto_create;
  fetch c_labor_auto_create into l_working_flag;
  close c_labor_auto_create;
  return nvl(l_working_flag,'N');
end;

PROCEDURE CLOSE_DEBRIEF (
            p_task_assignment_id   in         number,
            x_return_status        out nocopy varchar2,
            x_msg_count            out nocopy number,
            x_msg_data             out nocopy varchar2) IS

  l_processed_flag                 csf_debrief_headers.processed_flag%type;

  cursor get_debrief_status is
  select nvl(cdh.processed_flag,'PENDING')
  from   csf_debrief_headers cdh,
         csf_debrief_lines cdl
  where  cdh.task_assignment_id = p_task_assignment_id
  and    cdh.debrief_header_id = cdl.debrief_header_id;

BEGIN
  FND_MSG_PUB.initialize;
-- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  open  get_debrief_status;
  fetch get_debrief_status into l_processed_flag;
  close get_debrief_status;
  if nvl(l_processed_flag,'COMPLETED') = 'COMPLETED' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  else
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CSF','CSF_DEBRIEF_PENDING');
    FND_MSG_PUB.ADD;
  end if;
-- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);
END CLOSE_DEBRIEF;

procedure update_task_actuals (
  p_debrief_header_id     in number,
  x_return_status         out nocopy varchar2,
  x_msg_count             out nocopy number,
  x_msg_data              out nocopy varchar2) IS

  l_task_id              number := null;
  l_parent_task_id       number := null;
  l_task_assignment_id   number := null;
  l_start_date           date   := null;
  l_end_date             date   := null;
  l_start_date_ret       date   := null;
  l_end_date_ret         date   := null;
  l_object_version       number := null;
  l_debrief_line_id      number := null;
  l_organization_id      number := cs_std.get_item_valdn_orgzn_id;
  l_task_object_version  number := null;
  l_task_status_id       number := null;
  l_resource_type_code   varchar2(30) := null;
  l_resource_id          number := null;

  cursor c_task_assgin_object_version is
  select task_id, jta.task_assignment_id, jta.object_version_number,
         jta.resource_type_code, jta.resource_id
  from   jtf_task_assignments jta,
         csf_debrief_headers cdh
  where  jta.task_assignment_id = cdh.task_assignment_id
  and    cdh.debrief_header_id = p_debrief_header_id;

  cursor c_task_object_version is
  select parent_task_id,object_version_number
  from   jtf_tasks_b
  where  task_id = l_task_id ;

  cursor c_parent_task_object_version is
  select object_version_number
  from   jtf_tasks_b
  where  task_id = l_parent_task_id ;

  cursor c_task_assignment is
  select min(labor_start_date),
         max(labor_end_date),
         min(debrief_line_id)
  from   csf_debrief_lab_lines_v cdl,
         cs_transaction_types ctt
  where  cdl.debrief_header_id = p_debrief_header_id
  and    cdl.transaction_type_id = ctt.transaction_type_id
  and    ctt.line_order_category_code = 'ORDER';

  cursor c_task_assignment_return (p_start_date_order IN date, p_end_date_order IN date) is
  select min(labor_start_date),
         max(labor_end_date),
         min(debrief_line_id)
  from   csf_debrief_lab_lines_v cdl,
         cs_transaction_types ctt
  where  cdl.debrief_header_id = p_debrief_header_id
  and    cdl.transaction_type_id = ctt.transaction_type_id
  and    ctt.line_order_category_code = 'RETURN'
  and    cdl.labor_start_date between p_start_date_order and p_end_date_order
  and    cdl.labor_end_date between p_start_date_order and p_end_date_order;

  cursor c_task is
  select min(labor_start_date),
         max(labor_end_date),
         min(debrief_line_id)
  from   csf_debrief_lab_lines_v cdl,
         csf_debrief_headers cdh,
         jtf_task_assignments jta,
         cs_transaction_types ctt
  where  jta.task_id = l_task_id
  and    jta.task_assignment_id = cdh.task_assignment_id
  and    cdh.debrief_header_id = cdl.debrief_header_id
  and    cdl.transaction_type_id = ctt.transaction_type_id
  and    ctt.line_order_category_code = 'ORDER';

  cursor c_task_return (p_start_date_order IN date, p_end_date_order IN date) is
  select min(labor_start_date),
         max(labor_end_date),
         min(debrief_line_id)
  from   csf_debrief_lab_lines_v cdl,
         csf_debrief_headers cdh,
         jtf_task_assignments jta,
         cs_transaction_types ctt
  where  jta.task_id = l_task_id
  and    jta.task_assignment_id = cdh.task_assignment_id
  and    cdh.debrief_header_id = cdl.debrief_header_id
  and    cdl.transaction_type_id = ctt.transaction_type_id
  and    ctt.line_order_category_code = 'RETURN'
  and    cdl.labor_start_date between p_start_date_order and p_end_date_order
  and    cdl.labor_end_date between p_start_date_order and p_end_date_order;

  cursor c_parent_task is
  select min(labor_start_date),
         max(labor_end_date)
  from   csf_debrief_lines cdl,
         csf_debrief_headers cdh,
         jtf_task_assignments jta,
         jtf_tasks_b jtb,
         cs_transaction_types ctt
  where  jtb.parent_task_id = l_parent_task_id
  and    jta.task_id = jtb.task_id
  and    jta.task_assignment_id = cdh.task_assignment_id
  and    cdh.debrief_header_id = cdl.debrief_header_id
  and    cdl.transaction_type_id = ctt.transaction_type_id
  and    ctt.line_order_category_code = 'ORDER';

  cursor c_parent_task_return (p_start_date_order IN date, p_end_date_order IN date) is
  select min(labor_start_date),
         max(labor_end_date)
  from   csf_debrief_lines cdl,
         csf_debrief_headers cdh,
         jtf_task_assignments jta,
         jtf_tasks_b jtb,
         cs_transaction_types ctt
  where  jtb.parent_task_id = l_parent_task_id
  and    jta.task_id = jtb.task_id
  and    jta.task_assignment_id = cdh.task_assignment_id
  and    cdh.debrief_header_id = cdl.debrief_header_id
  and    cdl.transaction_type_id = ctt.transaction_type_id
  and    ctt.line_order_category_code = 'RETURN'
  and    cdl.labor_start_date between p_start_date_order and p_end_date_order
  and    cdl.labor_end_date between p_start_date_order and p_end_date_order;


---- added for bug 3629886 starts ---------------------------------------------------

  -- bug # 6960521
  -- substract RETURN type line's duration from total
  cursor c_task_assignment_dur is
    select uom_code, quantity
    from   jtf_task_assignments jta,
           csf_debrief_headers cdh,
           csf_debrief_lines cdl,
           cs_transaction_types ctt
    where  cdh.debrief_header_id = cdl.debrief_header_id
    and    jta.task_assignment_id = cdh.task_assignment_id
    and    cdh.debrief_header_id = p_debrief_header_id
    and    cdl.transaction_type_id = ctt.transaction_type_id
    and    ctt.line_order_category_code = 'ORDER'
    and    (cdl.inventory_item_id in
                (select msib.inventory_item_id
                 from   mtl_system_items_b msib
                 where  msib.organization_id = l_organization_id
                 and    msib.inventory_item_id = cdl.inventory_item_id
                 and    msib.material_billable_flag = 'L')
            or
            cdl.inventory_item_id is null)
    union all
    select uom_code, (quantity * -1)
        from   jtf_task_assignments jta,
               csf_debrief_headers cdh,
               csf_debrief_lines cdl,
               cs_transaction_types ctt
        where  cdh.debrief_header_id = cdl.debrief_header_id
        and    jta.task_assignment_id = cdh.task_assignment_id
        and    cdh.debrief_header_id = p_debrief_header_id
        and    cdl.transaction_type_id = ctt.transaction_type_id
        and    ctt.line_order_category_code = 'RETURN'
        and    (cdl.inventory_item_id in
                    (select msib.inventory_item_id
                     from   mtl_system_items_b msib
                     where  msib.organization_id = l_organization_id
                     and    msib.inventory_item_id = cdl.inventory_item_id
                     and    msib.material_billable_flag = 'L')
                or
                cdl.inventory_item_id is null);

  cursor c_task_dur is
    select uom_code, quantity
    from   csf_debrief_lines cdl,
           csf_debrief_headers cdh,
           jtf_task_assignments jta,
           jtf_tasks_b jtb,
           cs_transaction_types ctt
    where  cdh.debrief_header_id = cdl.debrief_header_id
    and    jta.task_assignment_id = cdh.task_assignment_id
    and    cdl.transaction_type_id = ctt.transaction_type_id
    and    ctt.line_order_category_code = 'ORDER'
    and    jtb.task_id = jta.task_id
    and    jtb.task_id = l_task_id
    and    (cdl.inventory_item_id in
                (select msib.inventory_item_id
                 from   mtl_system_items_b msib
                 where  msib.organization_id = l_organization_id
                 and    msib.inventory_item_id = cdl.inventory_item_id
                 and    msib.material_billable_flag = 'L')
            or
            cdl.inventory_item_id is null)
    union all
    select uom_code, (quantity * -1)
    from   csf_debrief_lines cdl,
           csf_debrief_headers cdh,
           jtf_task_assignments jta,
           jtf_tasks_b jtb,
           cs_transaction_types ctt
    where  cdh.debrief_header_id = cdl.debrief_header_id
    and    jta.task_assignment_id = cdh.task_assignment_id
    and    cdl.transaction_type_id = ctt.transaction_type_id
    and    ctt.line_order_category_code = 'RETURN'
    and    jtb.task_id = jta.task_id
    and    jtb.task_id = l_task_id
    and    (cdl.inventory_item_id in
                (select msib.inventory_item_id
                 from   mtl_system_items_b msib
                 where  msib.organization_id = l_organization_id
                 and    msib.inventory_item_id = cdl.inventory_item_id
                 and    msib.material_billable_flag = 'L')
            or
            cdl.inventory_item_id is null);

  cursor c_parent_task_dur is
    select uom_code, quantity
    from   csf_debrief_lines cdl,
           csf_debrief_headers cdh,
           jtf_task_assignments jta,
           jtf_tasks_b jtb,
           cs_transaction_types ctt
    where  cdh.debrief_header_id = cdl.debrief_header_id
    and    jta.task_assignment_id = cdh.task_assignment_id
    and    cdl.transaction_type_id = ctt.transaction_type_id
    and    ctt.line_order_category_code = 'ORDER'
    and    jtb.task_id = jta.task_id
    and    jtb.parent_task_id = l_parent_task_id
    and    (cdl.inventory_item_id in
                (select msib.inventory_item_id
                 from   mtl_system_items_b msib
                 where  msib.organization_id = l_organization_id
                 and    msib.inventory_item_id = cdl.inventory_item_id
                 and    msib.material_billable_flag = 'L')
            or
            cdl.inventory_item_id is null)
    union all
    select uom_code, (quantity * -1)
    from   csf_debrief_lines cdl,
           csf_debrief_headers cdh,
           jtf_task_assignments jta,
           jtf_tasks_b jtb,
           cs_transaction_types ctt
    where  cdh.debrief_header_id = cdl.debrief_header_id
    and    jta.task_assignment_id = cdh.task_assignment_id
    and    cdl.transaction_type_id = ctt.transaction_type_id
    and    ctt.line_order_category_code = 'RETURN'
    and    jtb.task_id = jta.task_id
    and    jtb.parent_task_id = l_parent_task_id
    and    (cdl.inventory_item_id in
                (select msib.inventory_item_id
                 from   mtl_system_items_b msib
                 where  msib.organization_id = l_organization_id
                 and    msib.inventory_item_id = cdl.inventory_item_id
                 and    msib.material_billable_flag = 'L')
            or
            cdl.inventory_item_id is null);


    l_uom_code          varchar2(3);
    l_duration          number := 0;
    l_duration_sum      number := 0;


    cursor c_hours_uom is
    select fnd_profile.value('CSF_UOM_HOURS')
    from    dual;

    l_uom   varchar2(3);
    l_t_uom   varchar2(3);

---- added for bug 3629886 ends ------------------------------------------------------

BEGIN
-- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  open  c_task_assgin_object_version;
  fetch c_task_assgin_object_version into l_task_id, l_task_assignment_id, l_object_version,
                                          l_resource_type_code, l_resource_id ;
  close c_task_assgin_object_version;

  open  c_task_assignment;
  fetch c_task_assignment into l_start_date,l_end_date,l_debrief_line_id;

  if l_debrief_line_id is null then
    l_start_date := null;
    l_end_date := null;
  else
    l_start_date := nvl(l_start_date,fnd_api.g_miss_date);
    l_end_date := nvl(l_end_date,fnd_api.g_miss_date);

    -- bug # 6960521
    open c_task_assignment_return(l_start_date, l_end_date);
    fetch c_task_assignment_return into l_start_date_ret, l_end_date_ret, l_debrief_line_id;
    if(l_debrief_line_id is not null) then

      if (l_start_date_ret = l_start_date) and (l_end_date_ret <= l_end_date) then
        l_start_date := l_end_date_ret;
      end if;

      if (l_end_date_ret = l_end_date) and (l_start_date_ret >= l_start_date) then
        l_end_date := l_start_date_ret;
      end if;

    end if;
    close c_task_assignment_return;

  end if;
  close c_task_assignment;

---- added for bug 3629886 starts -------------------------------------------------------

  open c_hours_uom;
  fetch c_hours_uom into l_uom;
  close c_hours_uom;

   l_duration_sum := 0;
   l_duration := 0;
   l_t_uom := l_uom;

  open c_task_assignment_dur;
  loop
    fetch c_task_assignment_dur into l_uom_code, l_duration;

    if l_uom_code <> l_uom then
        l_duration := inv_convert.inv_um_convert
                        ( item_id      => 0
                        , precision    => null
                        , from_quantity => l_duration
                        , from_unit    => l_uom_code
                        , to_unit      => l_uom
                        , from_name    => null
                        , to_name      => null );
    end if;

    exit when c_task_assignment_dur%notfound;
    l_duration_sum := l_duration_sum +  l_duration ;

  end loop;
  close c_task_assignment_dur;
  l_duration_sum := round(l_duration_sum,2);
  if nvl(l_duration_sum,0) = 0 then
   l_duration_sum := null;
   l_t_uom := null;
  end if;

---- added for bug 3629886 ends -----------------------------------------------------------

  if l_object_version is not null then

    csf_task_assignments_pub.update_task_assignment (
      p_api_version                  => 1.0,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_task_assignment_id           => l_task_assignment_id,
      p_object_version_number        => l_object_version,
      p_actual_start_date            => l_start_date,
      p_actual_end_date              => l_end_date,
      p_actual_effort                => l_duration_sum,  -- added for bug 3629886
      p_actual_effort_uom            => l_t_uom,	 -- added for bug 3629886
      p_resource_type_code           => l_resource_type_code,
      p_resource_id                  => l_resource_id,
      x_task_object_version_number   => l_task_object_version,
      x_task_status_id               => l_task_status_id);

      l_object_version := null;

      open  c_task_object_version;
      fetch c_task_object_version into l_parent_task_id,l_object_version;
      close c_task_object_version;

      open  c_task;
      fetch c_task into l_start_date,l_end_date,l_debrief_line_id;
      if l_debrief_line_id is null then
        l_start_date := null;
        l_end_date := null;
      else
        l_start_date := nvl(l_start_date,fnd_api.g_miss_date);
        l_end_date := nvl(l_end_date,fnd_api.g_miss_date);

        -- bug # 6960521
        open c_task_return(l_start_date, l_end_date);
        fetch c_task_return into l_start_date_ret, l_end_date_ret, l_debrief_line_id;
        if(l_debrief_line_id is not null) then

          if (l_start_date_ret = l_start_date) and (l_end_date_ret <= l_end_date) then
            l_start_date := l_end_date_ret;
          end if;

          if (l_end_date_ret = l_end_date) and (l_start_date_ret >= l_start_date) then
            l_end_date := l_start_date_ret;
          end if;

        end if;
        close c_task_return;

      end if;
      close c_task;

---- added for bug 3629886 starts ------------------------------------------------------

   l_duration_sum := 0;
   l_duration := 0;
   l_t_uom := l_uom;

  open c_task_dur;
  loop
    fetch c_task_dur into l_uom_code, l_duration;

    if l_uom_code <> l_uom then
        l_duration := inv_convert.inv_um_convert
                        ( item_id      => 0
                        , precision    => null
                        , from_quantity => l_duration
                        , from_unit    => l_uom_code
                        , to_unit      => l_uom
                        , from_name    => null
                        , to_name      => null );
    end if;

    exit when c_task_dur%notfound;
    l_duration_sum := l_duration_sum +  l_duration ;

  end loop;
  close c_task_dur;
  l_duration_sum := round(l_duration_sum,2);
  if nvl(l_duration_sum,0) = 0 then
   l_duration_sum := null;
   l_t_uom := null;
  end if;

---- added for bug 3629886 ends ----------------------------------------------------------

      if l_object_version is not null then
        csf_tasks_pub.update_task (
          p_api_version                  => 1.0,
          p_object_version_number        => l_object_version,
          p_task_id                      => l_task_id,
          p_actual_start_date            => l_start_date,
          p_actual_end_date              => l_end_date,
      	  p_actual_effort                => l_duration_sum,  	-- added for bug 3629886
      	  p_actual_effort_uom            => l_t_uom,		-- added for bug 3629886
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data) ;

      end if;


    if nvl(l_parent_task_id,-1) <> -1 then
      l_object_version := null;

      open  c_parent_task_object_version;
      fetch c_parent_task_object_version into l_object_version;
      close c_parent_task_object_version;

      open  c_parent_task;
      fetch c_parent_task into l_start_date,l_end_date;
      close c_parent_task;

      -- bug # 6960521
      open c_parent_task_return(l_start_date, l_end_date);
      fetch c_parent_task_return into l_start_date_ret, l_end_date_ret;
      if (l_start_date_ret = l_start_date) and (l_end_date_ret <= l_end_date) then
        l_start_date := l_end_date_ret;
      end if;

      if (l_end_date_ret = l_end_date) and (l_start_date_ret >= l_start_date) then
        l_end_date := l_start_date_ret;
      end if;
      close c_parent_task_return;


   l_duration_sum := 0;
   l_duration := 0;
   l_t_uom := l_uom;

  open c_parent_task_dur;
  loop
    fetch c_parent_task_dur into l_uom_code, l_duration;

    if l_uom_code <> l_uom then
        l_duration := inv_convert.inv_um_convert
                        ( item_id      => 0
                        , precision    => null
                        , from_quantity => l_duration
                        , from_unit    => l_uom_code
                        , to_unit      => l_uom
                        , from_name    => null
                        , to_name      => null );
    end if;

    exit when c_parent_task_dur%notfound;
    l_duration_sum := l_duration_sum +  l_duration ;

  end loop;
  close c_parent_task_dur;

  if nvl(l_duration_sum,0) = 0 then
   l_duration_sum := null;
   l_t_uom := null;
  end if;


      if l_object_version is not null then
        csf_tasks_pub.update_task (
          p_api_version                  => 1.0,
          p_object_version_number        => l_object_version,
          p_task_id                      => l_parent_task_id,
          p_actual_start_date            => l_start_date,
          p_actual_end_date              => l_end_date,
      	  p_actual_effort                => l_duration_sum,  	-- added for bug 3629886
      	  p_actual_effort_uom            => l_t_uom,		-- added for bug 3629886
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data) ;
      end if;
    end if;
  end if;

END;


Procedure validate_travel_times(p_actual_travel_start_time date,
                                p_actual_travel_end_time  date,
                                p_task_assignment_id       NUMBER,
                                P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                               	X_Return_Status              OUT NOCOPY  VARCHAR2,
                                X_Msg_Count                  OUT NOCOPY  NUMBER,
    	                        X_Msg_Data                   OUT NOCOPY  VARCHAR2) IS

    l_service_request_date date;

     Cursor get_service_request_date IS
     select nvl(incident_occurred_date,incident_date)
     from  jtf_task_assignments jta , cs_incidents_all cia, jtf_tasks_b jtb
     where jta.task_assignment_id = p_task_assignment_id
     and jtb.task_id = jta.task_id
     and cia.incident_id = jtb.source_object_id
     and jtb.source_object_type_code = 'SR';

BEGIN
		X_Return_Status := FND_API.G_RET_STS_SUCCESS;
        open get_service_request_date;
        fetch get_service_request_date INTO l_service_request_date;
        close get_service_request_date;

        If (p_actual_travel_start_time IS NULL
            or  p_actual_travel_start_time = FND_API.g_miss_date)
            and (p_actual_travel_end_time <> FND_API.g_miss_date
            and p_actual_travel_end_time IS NOT NULL) THEN
            X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_TRAVEL_START_TIME');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;

        If (p_actual_travel_start_time IS NOT NULL
            and p_actual_travel_end_time IS NOT NULL
            and p_actual_travel_start_time <> FND_API.g_miss_date
            and p_actual_travel_end_time <> FND_API.g_miss_date
            AND  p_actual_travel_start_time > p_actual_travel_end_time) THEN
                X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_TRAVEL_START_AFTER_END');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;

        If p_actual_travel_start_time IS NOT NULL
           and p_actual_travel_start_time <> FND_API.g_miss_date
           and trunc(fnd_timezones_pvt.adjust_datetime(p_actual_travel_start_time,
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID'))))
             > trunc(fnd_timezones_pvt.adjust_datetime(sysdate,
                                                       fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')),
                                                       fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')))) THEN
              X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_TRAVEL_START_CURR_DATE');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;
         If p_actual_travel_end_time IS NOT NULL
            and p_actual_travel_end_time <> FND_API.g_miss_date
            and trunc(fnd_timezones_pvt.adjust_datetime(p_actual_travel_end_time,
                                                        fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')),
                                                        fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID'))))
              > trunc(fnd_timezones_pvt.adjust_datetime(sysdate,
                                                        fnd_timezones.get_code(fnd_profile.value('SERVER_TIMEZONE_ID')),
                                                        fnd_timezones.get_code(fnd_profile.value('CLIENT_TIMEZONE_ID')))) THEN
             X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_TRAVEL_END_CURR_DATE');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;

         If (p_actual_travel_start_time IS NOT NULL
            and p_actual_travel_start_time <> FND_API.g_miss_date
            and p_actual_travel_start_time < l_service_request_date) THEN
                X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_TRAVEL_START_SR_DATE');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;
        If (p_actual_travel_end_time IS NOT NULL
            and p_actual_travel_end_time <> FND_API.g_miss_date
            and p_actual_travel_end_time < l_service_request_date) THEN
                X_Return_Status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('CSF','CSF_TRAVEL_END_SR_DATE');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;
END;

END CSF_DEBRIEF_PVT;

/
