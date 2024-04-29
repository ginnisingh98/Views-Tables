--------------------------------------------------------
--  DDL for Package Body CN_SEAS_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SEAS_SCHEDULES_PVT" AS
-- $Header: cnvsschb.pls 115.6.115100.2 2004/05/20 22:14:03 sbadami ship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_SEAS_SCHEDULES_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvsschb.pls';


-- Start of comments
--    API name        : Create_Seas_Schedule
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_seas_schedules_tbl_type  IN      seas_schedules_tbl_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SEAS_SCHEDULES_PKG
--                      and CN_SEASONALITIES_PKG to insert rows into CN_SEAS_SCHEDULES
--                      and CN_SEASONALITIES after some validations.
--
-- End of comments


PROCEDURE Create_Seas_Schedule
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seas_schedules_rec_type IN     seas_schedules_rec_type,
   x_seas_schedule_id        OUT NOCOPY    NUMBER,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Seas_Schedule';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_error_code NUMBER;
      l_count NUMBER;
      l_start_date DATE;
      l_end_date   DATE;
      l_seas_schedule_id  NUMBER;
      l_cal_int_types NUMBER;

      CURSOR cn_seasonalities_cur(p_period_year NUMBER) IS
      SELECT cp.period_id,cp.period_name,ccpit.interval_number,ccpit.cal_per_int_type_id
      FROM cn_period_statuses cp,cn_cal_per_int_types ccpit
      WHERE period_year = p_period_year and cp.period_id = ccpit.cal_period_id and interval_type_id = -1002;


BEGIN
   --DBMS_OUTPUT.PUT_LINE('Starting Create_Seas_Schedule ...');
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Seas_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body

   -- ***********************
   --    VALIDATIONS
   -- ***********************

   -- Check if the inputs are valid.

   -- Check the SEASONALITY SCHEDULE NAME
   IF ( p_seas_schedules_rec_type.name is NULL ) OR
      ( p_seas_schedules_rec_type.name = fnd_api.g_miss_char )
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_REQ_PAR_MISSING');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check the SEASONALITY SCHEDULE DESCRIPTION
   IF ( p_seas_schedules_rec_type.DESCRIPTION is NULL ) OR
      ( p_seas_schedules_rec_type.DESCRIPTION = fnd_api.g_miss_char )
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_REQ_PAR_MISSING');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check already if this seas_schedule_name exists
   SELECT COUNT(*) INTO l_count FROM CN_SEAS_SCHEDULES WHERE UPPER(NAME) LIKE UPPER(p_seas_schedules_rec_type.name);
   -- Insert
   IF l_count > 0 THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_SEAS_NAME_EXISTS');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- INSERT TO BEGIN TO CN_SEAS_SCHEDULES
   -- Get the Max Date of End Date and Min of Start Date for this period Year.
   select min(start_date),max(end_date) into l_start_date,l_end_date
   from cn_period_statuses
   where period_year = p_seas_schedules_rec_type.period_year
   group by period_year;

   -- We can put some more error conditon checks for Start Date and End Date.
   -- Call the table handler to insert the row into CN_SEAS_SCHEDULES Table.
   CN_SEAS_SCHEDULES_pkg.insert_row (
     P_SEAS_SCHEDULE_ID => p_seas_schedules_rec_type.seas_schedule_id,
     P_NAME             => p_seas_schedules_rec_type.name,
     P_DESCRIPTION      => p_seas_schedules_rec_type.description,
     P_PERIOD_YEAR      => p_seas_schedules_rec_type.period_year,
     P_START_DATE       => l_start_date,
     P_END_DATE         => l_end_date,
     P_VALIDATION_STATUS => 'INVALID'
   );

   -- Select SEAS_SCHEDULE_ID just created to use it for insertion of
   -- rows into CN_SEASONALITIES.

   SELECT SEAS_SCHEDULE_ID INTO l_seas_schedule_id
   FROM CN_SEAS_SCHEDULES WHERE NAME like p_seas_schedules_rec_type.name;

   x_seas_schedule_id := l_seas_schedule_id;
   --DBMS_OUTPUT.PUT_LINE('Inserted Row and SEAS SCHEDULE ID is : ' || l_seas_schedule_id || 'About to get rows for ' || p_seas_schedules_rec_type.period_year);


   SELECT COUNT(*) INTO l_cal_int_types
      FROM cn_period_statuses cp,cn_cal_per_int_types ccpit
      WHERE period_year = p_seas_schedules_rec_type.period_year and cp.period_id = ccpit.cal_period_id and interval_type_id = -1002;

   IF (l_cal_int_types = 0) THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_SEAS_INTTYPE_NOTEXIST');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- Create a CURSOR OF VALUES FOR the Period and use table handler
   -- to insert rows into the CN_SEASONALITIES.
   FOR l_seas_sch IN cn_seasonalities_cur(p_seas_schedules_rec_type.period_year) LOOP
        --DBMS_OUTPUT.PUT_LINE('In the Loop');
        CN_SEASONALITIES_pkg.insert_row(
            P_SEASONALITY_ID    => -99,
            P_SEAS_SCHEDULE_ID  => l_seas_schedule_id,
            P_CAL_PER_INT_TYPE_ID => l_seas_sch.CAL_PER_INT_TYPE_ID,
            P_PERIOD_ID         => l_seas_sch.PERIOD_ID,
            P_PCT_SEASONALITY   => 0.0
        );
   END LOOP;

   --DBMS_OUTPUT.PUT_LINE('Created rows successfully in CN_SEASONALITIES');
   -- End of API body.
   << end_Create_Seas_Schedule >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Seas_Schedule  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Seas_Schedule ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Seas_Schedule ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
	 x_return_status := FND_API.G_RET_STS_ERROR ;
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	 END IF;
       ELSE
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Create_Seas_Schedule;


-- Start of comments
--    API name        : Update_Seas_Schedule
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_seas_schedules_tbl_type  IN      seas_schedules_tbl_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SEAS_SCHEDULES_PKG
--                      to update rows into CN_SEAS_SCHEDULES after some validations.
--
-- End of comments

PROCEDURE Update_Seas_Schedule
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seas_schedules_rec_type IN     seas_schedules_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Update_Seas_Schedule';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_error_code NUMBER;
      l_count NUMBER;
      l_validation_status VARCHAR2(30);
      l_start_date date;
      l_end_date date;
      l_srp_count NUMBER;

BEGIN
   --DBMS_OUTPUT.PUT_LINE('Update in progress');
    -- Standard Start of API savepoint
   SAVEPOINT   Update_Seas_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body

    select COUNT(*) INTO l_srp_count from cn_srp_role_dtls t1,cn_role_quota_cates t2,cn_srp_roles t3
    where t1.srp_role_id = t3.srp_role_id
    and t2.role_id = t3.role_id
    and t1.status not in ('PENDING')
    and t2.seas_schedule_id = p_seas_schedules_rec_type.seas_schedule_id;


    IF (l_srp_count > 0) THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_SEASONALITY_IN_USE');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
    END IF;

   -- ****************************
   -- VALIDATIONS/CHECK FOR NULLS
   -- ****************************
   -- Check the SEASONALITY SCHEDULE NAME
   IF ( p_seas_schedules_rec_type.name is NULL ) OR
      ( p_seas_schedules_rec_type.name = fnd_api.g_miss_char )
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_REQ_PAR_MISSING');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check the SEASONALITY SCHEDULE DESCRIPTION
   IF ( p_seas_schedules_rec_type.DESCRIPTION is NULL ) OR
      ( p_seas_schedules_rec_type.DESCRIPTION = fnd_api.g_miss_char )
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_REQ_PAR_MISSING');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check already if this seas_schedule_name exists
   SELECT COUNT(*) INTO l_count FROM CN_SEAS_SCHEDULES WHERE UPPER(NAME) LIKE UPPER(p_seas_schedules_rec_type.name) AND SEAS_SCHEDULE_ID <> p_seas_schedules_rec_type.seas_schedule_id;
   -- Insert
   IF l_count > 0 THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_SEAS_NAME_EXISTS');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --DBMS_OUTPUT.PUT_LINE('Update Validations done.');
   -- CALL THE UPDATE API
   -- l_validation_status := FND_API.G_MISS_CHAR;
   l_validation_status := p_seas_schedules_rec_type.validation_status;
   if ((l_validation_status <> 'VALID') AND (l_validation_status <> 'INVALID')) THEN
      l_validation_status := FND_API.G_MISS_CHAR;
   END IF;

   l_start_date := FND_API.G_MISS_DATE;
   l_end_date := FND_API.G_MISS_DATE;

   --DBMS_OUTPUT.PUT_LINE('SEAS ID : ' || p_seas_schedules_rec_type.seas_schedule_id);
   --DBMS_OUTPUT.PUT_LINE('NAME    : ' || p_seas_schedules_rec_type.name);
   --DBMS_OUTPUT.PUT_LINE('DESCRIPTION : ' || p_seas_schedules_rec_type.description);
   --DBMS_OUTPUT.PUT_LINE('PERIOD YEAR : ' || p_seas_schedules_rec_type.period_year);
   --DBMS_OUTPUT.PUT_LINE('START DATE : ' || p_seas_schedules_rec_type.start_date);
   --DBMS_OUTPUT.PUT_LINE('END DATE : ' || p_seas_schedules_rec_type.end_date);
   --DBMS_OUTPUT.PUT_LINE('OVN : ' || p_seas_schedules_rec_type.object_version_number);
   --DBMS_OUTPUT.PUT_LINE('VALIDATION STATUS : ' || l_validation_status);

   CN_SEAS_SCHEDULES_pkg.update_row
   (
     P_SEAS_SCHEDULE_ID  => p_seas_schedules_rec_type.seas_schedule_id,
     P_NAME              => p_seas_schedules_rec_type.name,
     P_DESCRIPTION       => p_seas_schedules_rec_type.description,
     P_PERIOD_YEAR       => p_seas_schedules_rec_type.period_year,
     P_START_DATE        => l_start_date,
     P_END_DATE          => l_end_date,
     P_VALIDATION_STATUS => l_validation_status,
     p_object_version_number => p_seas_schedules_rec_type.object_version_number
    );


   -- End of API body.
   << end_Update_Seas_Schedule >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Seas_Schedule  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Seas_Schedule ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Seas_Schedule ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
 	   x_return_status := FND_API.G_RET_STS_ERROR ;
   	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	   END IF;
       ELSE
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	   END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Update_Seas_Schedule;


-- Start of comments
--    API name        : Delete_Seas_Schedule
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      P_SEAS_SCHEDULE_ID    IN NUMBER       Required
--
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SEAS_SCHEDULES_PKG
--                      and CN_SEASONALITIES_PKG to delete rows into CN_SEAS_SCHEDULES
--                      and CN_SEASONALITIES after the validations are done.
--
-- End of comments

PROCEDURE Delete_Seas_Schedule
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   P_SEAS_SCHEDULE_ID        IN     cn_seas_schedules.seas_schedule_id%TYPE,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 )  IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Seas_Schedule';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_error_code NUMBER;
      l_seas_sch_id NUMBER;
      l_role_quota_cate_count NUMBER;
BEGIN
   --DBMS_OUTPUT.PUT_LINE('Delete in progress');
    -- Standard Start of API savepoint
   SAVEPOINT   Delete_Seas_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- API body
   l_seas_sch_id := P_SEAS_SCHEDULE_ID;
   -- ********************
   --   VALIDATION
   -- ********************
   -- Validations to be checked before we decide to delete the entries
   -- from CN_SEAS_SCHEDULES and CN_SEASONALITIES.
   SELECT COUNT(role_id) INTO l_role_quota_cate_count FROM CN_ROLE_QUOTA_CATES WHERE seas_schedule_id = P_SEAS_SCHEDULE_ID;

   IF (l_role_quota_cate_count > 0) THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	FND_MESSAGE.SET_NAME ('CN' , 'CN_SEAS_DEL_FAILED');
    	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Delete entries from CN_SEAS_SCHEDULES
   CN_SEAS_SCHEDULES_pkg.delete_row (P_SEAS_SCHEDULE_ID => l_seas_sch_id);

   -- Delete entries from CN_SEASONALITIES.
   CN_SEASONALITIES_pkg.delete_row (P_SEAS_SCHEDULE_ID => l_seas_sch_id);

   -- End of API body.
   << end_Delete_Seas_Schedule >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Seas_Schedule  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Seas_Schedule ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Seas_Schedule ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
 	   x_return_status := FND_API.G_RET_STS_ERROR ;
   	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	   END IF;
       ELSE
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	   END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Delete_Seas_Schedule;

-- Start of comments
--    API name        : Sum_Seas_Schedule
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      P_SEAS_SCHEDULE_ID    IN NUMBER       Required
--
--    OUT             : x_seas_schedule_sum       OUT    NUMBER,
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--
--    Version :         Current version       1.0
--
--
--
--    Notes           :  This procedures find the sum of seasonalities
-- End of comments

PROCEDURE Sum_Seas_Schedule
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seas_schedules_id       IN     NUMBER,
   x_seas_schedule_sum       OUT NOCOPY    NUMBER,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Sum_Seas_Schedule';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_error_code NUMBER;
      l_seas_schedule_id NUMBER;
      l_pct_seasonality NUMBER;

BEGIN
    -- Standard Start of API savepoint
   SAVEPOINT   Sum_Seas_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- API body
   select seas_schedule_id,sum(pct_seasonality) into l_seas_schedule_id,l_pct_seasonality
   from cn_seasonalities
   where seas_schedule_id = p_seas_schedules_id group by seas_schedule_id;

   x_seas_schedule_sum := l_pct_seasonality;

   -- End of API body.
   << end_Delete_Seas_Schedule >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Sum_Seas_Schedule  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Sum_Seas_Schedule ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Sum_Seas_Schedule ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
 	   x_return_status := FND_API.G_RET_STS_ERROR ;
   	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	   END IF;
       ELSE
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	   END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Sum_Seas_Schedule;

END cn_seas_schedules_pvt;

/
