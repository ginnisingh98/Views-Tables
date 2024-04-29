--------------------------------------------------------
--  DDL for Package Body AMS_ACTDELVMETHOD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTDELVMETHOD_PVT" AS
/* $Header: amsvdlvb.pls 120.1 2005/06/15 01:42:02 appldev  $ */

-- NAME
--   AMS_ActDelvMethod_PVT
--
-- HISTORY
--	11/11/99 	rvaka	CREATED
--
G_PACKAGE_NAME	CONSTANT VARCHAR2(30):='AMS_ActDelvMethod_PVT';
G_FILE_NAME	CONSTANT VARCHAR2(12):='amsvdlvb.pls';
-- Debug mode
g_debug boolean := FALSE;
--g_debug boolean := TRUE;
--
-- Procedure and function declarations.
-- Start of Comments
--
-- NAME
--   Create_Act_DelvMethod
--
-- PURPOSE
--   This procedure is to create a Delivery Method record that satisfy caller needs
--
-- HISTORY
--   11/11/1999        rvaka            created
-- End of Comments

PROCEDURE Create_Act_DelvMethod
( p_api_version		IN     NUMBER,
  p_init_msg_list	IN     VARCHAR2		:= FND_API.G_FALSE,
  p_commit		IN     VARCHAR2		:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count	 OUT NOCOPY    NUMBER,
  x_msg_data	 OUT NOCOPY    VARCHAR2,
  p_act_DelvMethod_rec	IN     act_DelvMethod_rec_type,
  x_act_DelvMethod_id OUT NOCOPY    NUMBER
) IS
        l_api_name	CONSTANT VARCHAR2(30)  := 'Create_Act_DelvMethod';
        l_api_version	CONSTANT NUMBER        := 1.0;
	l_full_name     CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;
        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
        l_act_DelvMethod_rec	act_DelvMethod_rec_type := p_act_DelvMethod_rec;
        l_act_delivery_method_id	NUMBER;
	CURSOR C_act_delivery_method_id IS
	SELECT ams_act_delivery_methods_s.NEXTVAL
	FROM dual;
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Create_Act_DelvMethod_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PACKAGE_NAME)
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
        	FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
   ----------------------- validate -----------------------
   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
	Validate_Act_DelvMethod
	( p_api_version				=> 1.0
	  ,p_init_msg_list     			=> p_init_msg_list
	  ,p_validation_level	 		=> p_validation_level
	  ,x_return_status			=> l_return_status
	  ,x_msg_count				=> x_msg_count
	  ,x_msg_data				=> x_msg_data
	  ,p_act_DelvMethod_rec			=> l_act_DelvMethod_rec
	);
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
	THEN
		FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
		FND_MSG_PUB.add;
	END IF;
	-- If any errors happen abort API.
	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	--
	-- Get ID for activity delivery method from sequence.
	OPEN c_act_delivery_method_id;
	FETCH c_act_delivery_method_id INTO l_act_DelvMethod_rec.activity_delivery_method_id;
	CLOSE c_act_delivery_method_id;
	INSERT INTO AMS_ACT_DELIVERY_METHODS
	(activity_delivery_method_id,
	-- standard who columns
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	-- other columns
	object_version_number,
	act_delivery_method_used_by_id,
	arc_act_delivery_used_by,
	delivery_media_type_code,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15
	)
	VALUES
	(
	l_act_DelvMethod_rec.activity_delivery_method_id,
	-- standard who columns
	sysdate,
	FND_GLOBAL.User_Id,
	sysdate,
	FND_GLOBAL.User_Id,
	FND_GLOBAL.Conc_Login_Id,
	1,  -- object_version_number
	l_act_DelvMethod_rec.act_delivery_method_used_by_id,
	l_act_DelvMethod_rec.arc_act_delivery_used_by,
	l_act_DelvMethod_rec.delivery_media_type_code,
	l_act_DelvMethod_rec.attribute_category,
	l_act_DelvMethod_rec.attribute1,
	l_act_DelvMethod_rec.attribute2,
	l_act_DelvMethod_rec.attribute3,
	l_act_DelvMethod_rec.attribute4,
	l_act_DelvMethod_rec.attribute5,
	l_act_DelvMethod_rec.attribute6,
	l_act_DelvMethod_rec.attribute7,
	l_act_DelvMethod_rec.attribute8,
	l_act_DelvMethod_rec.attribute9,
	l_act_DelvMethod_rec.attribute10,
	l_act_DelvMethod_rec.attribute11,
	l_act_DelvMethod_rec.attribute12,
	l_act_DelvMethod_rec.attribute13,
	l_act_DelvMethod_rec.attribute14,
	l_act_DelvMethod_rec.attribute15
	);
	-- set OUT value
	x_act_delvmethod_id := l_act_DelvMethod_rec.activity_delivery_method_id;
    --
    -- END of API body.
    --
    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
		COMMIT WORK;
    END IF;
    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_AND_Get
    ( p_count		=>      x_msg_count,
      p_data		=>      x_msg_data,
      p_encoded		=>      FND_API.G_FALSE
    );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
	        ROLLBACK TO Create_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	        );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	        ROLLBACK TO Create_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	        );
        WHEN OTHERS THEN
	        ROLLBACK TO Create_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        	THEN
              		FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
	        END IF;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	        );
END Create_Act_DelvMethod;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Act_DelvMethod
--
-- PURPOSE
--   This procedure is to update a delivery method record that satisfy caller needs
--
-- HISTORY
--   11/11/1999        rvaka            created
-- End of Comments
PROCEDURE Update_Act_DelvMethod
( p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  p_act_DelvMethod_rec	IN	act_DelvMethod_rec_type
) IS
        l_api_name			CONSTANT VARCHAR2(30)  := 'Update_Act_DelvMethod';
        l_api_version			CONSTANT NUMBER        := 1.0;
        -- Status Local Variables
        l_return_status			VARCHAR2(1);  -- Return value from procedures
        l_act_DelvMethod_rec		act_DelvMethod_rec_type;
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Update_Act_DelvMethod_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PACKAGE_NAME)
        THEN
  		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
        	FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
	   complete_act_DelvMethod_rec(
		p_act_DelvMethod_rec,
		l_act_DelvMethod_rec
	   );
        -- Perform the database operation



   AMS_Utility_PVT.debug_message(l_api_name||': Calling check items');
	IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item
	THEN
		Validate_Act_DelvMethod_Items
		( p_act_DelvMethod_rec	=> l_act_DelvMethod_rec,
		  p_validation_mode 	=> JTF_PLSQL_API.g_update,
		  x_return_status		=> l_return_status
		);
		-- If any errors happen abort API.
		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;


	update AMS_ACT_DELIVERY_METHODS
	set
		last_update_date = sysdate
		,last_updated_by =  FND_GLOBAL.User_Id
		,last_update_login = FND_GLOBAL.Conc_Login_Id
		,object_version_number = l_act_DelvMethod_rec.object_version_number+1
		,act_delivery_method_used_by_id = l_act_DelvMethod_rec.act_delivery_method_used_by_id
		,arc_act_delivery_used_by = l_act_DelvMethod_rec.arc_act_delivery_used_by
		,delivery_media_type_code = l_act_DelvMethod_rec.delivery_media_type_code
		,attribute_category = l_act_DelvMethod_rec.attribute_category
		,attribute1 = l_act_DelvMethod_rec.attribute1
		,attribute2 = l_act_DelvMethod_rec.attribute2
		,attribute3 = l_act_DelvMethod_rec.attribute3
		,attribute4 = l_act_DelvMethod_rec.attribute4
		,attribute5 = l_act_DelvMethod_rec.attribute5
		,attribute6 = l_act_DelvMethod_rec.attribute6
		,attribute7 = l_act_DelvMethod_rec.attribute7
		,attribute8 = l_act_DelvMethod_rec.attribute8
		,attribute9 = l_act_DelvMethod_rec.attribute9
		,attribute10 = l_act_DelvMethod_rec.attribute10
		,attribute11 = l_act_DelvMethod_rec.attribute11
		,attribute12 = l_act_DelvMethod_rec.attribute12
		,attribute13 = l_act_DelvMethod_rec.attribute13
		,attribute14 = l_act_DelvMethod_rec.attribute14
		,attribute15 = l_act_DelvMethod_rec.attribute15
	where activity_delivery_method_id = l_act_DelvMethod_rec.activity_delivery_method_id
       and object_version_number = l_act_DelvMethod_rec.object_version_number;
	IF (SQL%NOTFOUND)
	THEN
		-- Error, check the msg level and added an error message to the
		-- API message list
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
       	        THEN -- MMSG
			FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
	       		FND_MSG_PUB.Add;
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
        --
        -- END of API body.
        --
        -- Standard check of p_commit.
        IF FND_API.To_Boolean ( p_commit )
        THEN
        	COMMIT WORK;
        END IF;
        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count	=>      x_msg_count,
	     p_data	=>      x_msg_data,
	     p_encoded	=>      FND_API.G_FALSE
        );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
	        ROLLBACK TO Update_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	        ROLLBACK TO Update_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
        WHEN OTHERS THEN
	        ROLLBACK TO Update_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        	THEN
              		FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
	        END IF;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       	  p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
END Update_Act_DelvMethod;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Delete_Act_DelvMethod
--
-- PURPOSE
--   This procedure is to delete a delivery method record that satisfy caller needs
--
-- HISTORY
--   11/11/1999        rvaka            created
-- End of Comments
PROCEDURE Delete_Act_DelvMethod
( p_api_version		IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN     VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,
  p_act_DelvMethod_id		IN     NUMBER,
  p_object_version       IN     NUMBER
) IS
        l_api_name		CONSTANT VARCHAR2(30)  := 'Delete_Act_DelvMethod';
        l_api_version	CONSTANT NUMBER        := 1.0;
        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
        l_act_delivery_method_id	NUMBER := p_act_DelvMethod_id;
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Delete_Act_DelvMethod_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PACKAGE_NAME)
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
        	FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        -- Perform the database operation
		-- Delete header data
		DELETE FROM AMS_ACT_DELIVERY_METHODS
		WHERE  activity_delivery_method_id = l_act_delivery_method_id
		  and  object_version_number = p_object_version;
		IF SQL%NOTFOUND THEN
		--
		-- Add error message to API message list.
		--
			IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
				FND_MSG_PUB.add;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
        --
        -- END of API body.
        --
        -- Standard check of p_commit.
        IF FND_API.To_Boolean ( p_commit )
        THEN
        	COMMIT WORK;
        END IF;
        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count	=>      x_msg_count,
          p_data	=>      x_msg_data,
	  p_encoded	=>      FND_API.G_FALSE
        );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
	        ROLLBACK TO Delete_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count  	=>      x_msg_count,
	       p_data	     =>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	        ROLLBACK TO Delete_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
        WHEN OTHERS THEN
	        ROLLBACK TO Delete_Act_DelvMethod_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        	THEN
              		FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
	        END IF;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
END Delete_Act_DelvMethod;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Lock_Act_DelvMethod
--
-- PURPOSE
--   This procedure is to lock a delivery method record that satisfy caller needs
--
-- HISTORY
--   11/11/1999        rvaka            created
-- End of Comments

PROCEDURE Lock_Act_DelvMethod
( p_api_version			IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level		IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,
  p_act_DelvMethod_id 	IN     NUMBER,
  p_object_version	        IN     NUMBER
) IS
        l_api_name		CONSTANT VARCHAR2(30)  := 'Lock_Act_DelvMethod';
        l_api_version	CONSTANT NUMBER        := 1.0;
        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
        l_act_delivery_method_id	NUMBER;
	CURSOR c_act_delivery_method IS
    	SELECT activity_delivery_method_id
          FROM AMS_ACT_DELIVERY_METHODS
	 WHERE activity_delivery_method_id = p_act_delvmethod_id
	   and object_version_number = p_object_version
	   FOR UPDATE of activity_delivery_method_id NOWAIT;
  BEGIN
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PACKAGE_NAME)
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
        	FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        -- Perform the database operation
	OPEN c_act_delivery_method;
	FETCH c_act_delivery_method INTO l_act_delivery_method_id;
	IF (c_act_delivery_method%NOTFOUND) THEN
	CLOSE c_act_delivery_method;
		-- Error, check the msg level and added an error message to the
		-- API message list
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
       	        THEN -- MMSG
			FND_MESSAGE.Set_Name('AMS', 'AMS_API_RECORD_NOT_FOUND');
			FND_MSG_PUB.Add;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE c_act_delivery_method;
        --
        -- END of API body.
        --
        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count	=>      x_msg_count,
          p_data	=>      x_msg_data,
	     p_encoded	=>      FND_API.G_FALSE
        );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
        WHEN AMS_Utility_PVT.resource_locked THEN
      	x_return_status := FND_API.g_ret_sts_error;
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
             FND_MSG_PUB.add;
          END IF;
  	        FND_MSG_PUB.Count_AND_Get
                ( p_count	=>      x_msg_count,
                  p_data		=>      x_msg_data,
		  	   p_encoded	=>      FND_API.G_FALSE
                );
        WHEN OTHERS THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        	THEN
              		FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
	        END IF;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		       p_data	=>      x_msg_data,
		  p_encoded	=>	FND_API.G_FALSE
	     );
END Lock_Act_DelvMethod;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_DelvMethod
--
-- PURPOSE
--   This procedure is to validate an activity delivery method record
--
-- HISTORY
--   11/11/1999        rvaka            created
-- End of Comments
PROCEDURE Validate_Act_DelvMethod
( p_api_version		IN     NUMBER,
  p_init_msg_list	IN     VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count	 OUT NOCOPY    NUMBER,
  x_msg_data	 OUT NOCOPY    VARCHAR2,
  p_act_DelvMethod_rec	IN     act_DelvMethod_rec_type
) IS
        l_api_name	CONSTANT VARCHAR2(30)  := 'Validate_Act_DelvMethod';
        l_api_version	CONSTANT NUMBER        := 1.0;
	l_full_name     CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;
        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
        l_act_DelvMethod_rec	act_DelvMethod_rec_type := p_act_DelvMethod_rec;
        l_default_act_DelvMethod_rec	act_DelvMethod_rec_type;
	l_act_delivery_method_id	NUMBER;
  BEGIN
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PACKAGE_NAME)
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
        	FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
   AMS_Utility_PVT.debug_message(l_full_name||': check items');
	IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item
	THEN
		Validate_Act_DelvMethod_Items
		( p_act_DelvMethod_rec	=> l_act_DelvMethod_rec,
		  p_validation_mode 	=> JTF_PLSQL_API.g_create,
		  x_return_status		=> l_return_status
		);
		-- If any errors happen abort API.
		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	-- Perform cross attribute validation and missing attribute checks. Record
	-- level validation.
   AMS_Utility_PVT.debug_message(l_full_name||': check record level');
	IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record
	THEN
		Validate_Act_DelvMethod_Record(
		  p_act_DelvMethod_rec          => l_act_DelvMethod_rec,
		  x_return_status     		=> l_return_status
		);
		-- If any errors happen abort API.
		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;
        --
        -- END of API body.
        --
   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
        WHEN OTHERS THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        	THEN
              		FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
	        END IF;
	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );
END Validate_Act_DelvMethod;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_DelvMethod_Items
--
-- PURPOSE
--   This procedure is to validate Delivery Method items
-- End of Comments
PROCEDURE Validate_Act_DelvMethod_Items
( p_act_DelvMethod_rec	IN	act_DelvMethod_rec_type,
  p_validation_mode		IN	VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status	 OUT NOCOPY VARCHAR2
) IS
	l_table_name	VARCHAR2(30);
	l_pk_name	VARCHAR2(30);
	l_pk_value	VARCHAR2(30);
BEGIN
        --  Initialize API/Procedure return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
 -- Check required parameters
     IF  (p_act_DelvMethod_rec.ACT_DELIVERY_METHOD_USED_BY_ID = FND_API.G_MISS_NUM OR
         p_act_DelvMethod_rec.ACT_DELIVERY_METHOD_USED_BY_ID IS NULL)
     THEN
          -- missing required fields
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
               FND_MESSAGE.set_name('AMS', 'AMS_ACT_DLV_NO_USEDBYID');
               FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          -- If any error happens abort API.
           RETURN;
     END IF;
     -- ARC_ACT_DELIVERY_USED_BY
     IF (p_act_DelvMethod_rec.ARC_ACT_DELIVERY_USED_BY = FND_API.G_MISS_CHAR OR
         p_act_DelvMethod_rec.ARC_ACT_DELIVERY_USED_BY IS NULL)
     THEN
          -- missing required fields
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
               FND_MESSAGE.set_name('AMS', 'AMS_ACT_DLV_NO_USEDBY');
               FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          -- If any error happens abort API.
           RETURN;
     END IF;
     IF  (p_act_DelvMethod_rec.delivery_media_type_code = FND_API.G_MISS_CHAR OR
         p_act_DelvMethod_rec.delivery_media_type_code IS NULL)
     THEN
          -- missing required fields
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
               FND_MESSAGE.set_name('AMS', 'AMS_ACT_DLV_NO_DELV_MEDIA');
               FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          -- If any error happens abort API.
           RETURN;
     END IF;
  --   Validate uniqueness
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_act_DelvMethod_rec.activity_delivery_method_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
                'ams_act_delivery_methods',
                    'activity_delivery_method_id = ' ||  p_act_DelvMethod_rec.activity_delivery_method_id
               ) = FND_API.g_false
          THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_DLV_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
	--
	-- Begin Validate Referential
	--
        -- Check FK parameter: ACT_DELIVERY_METHOD_USED_BY_ID #1
	IF p_act_DelvMethod_rec.ACT_DELIVERY_METHOD_USED_BY_ID <> FND_API.g_miss_num
	THEN
		IF p_act_DelvMethod_rec.ARC_ACT_DELIVERY_USED_BY = 'EVEH' THEN
		   l_table_name := 'AMS_EVENT_HEADERS_VL';
		   l_pk_name := 'EVENT_HEADER_ID';
		    l_pk_value := p_act_DelvMethod_rec.ACT_DELIVERY_METHOD_USED_BY_ID;
		    AMS_Utility_PVT.debug_message(l_pk_value ||': insert B');
			IF AMS_Utility_PVT.Check_FK_Exists (
			p_table_name		=> l_table_name
			,p_pk_name		=> l_pk_name
			,p_pk_value		=> l_pk_value
			) = FND_API.G_FALSE
			THEN
				IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
				THEN
					FND_MESSAGE.set_name('AMS', 'AMS_ACT_DLV_INVALID_REFERENCE');
					FND_MSG_PUB.add;
				END IF;
				x_return_status := FND_API.G_RET_STS_ERROR;
				-- If any errors happen abort API/Procedure.
				RETURN;
			END IF;  -- check_fk_exists
	       END IF;
	END IF;

--   check for lookups....
   IF p_act_DelvMethod_rec.arc_act_delivery_used_by <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_act_DelvMethod_rec.arc_act_delivery_used_by
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_DLV_BAD_SYS_ARC');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   IF p_act_DelvMethod_rec.delivery_media_type_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_DELIVERY_MEDIA_TYPE',
            p_lookup_code => p_act_DelvMethod_rec.DELIVERY_MEDIA_TYPE_CODE
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_DLV_BAD_DELV_MEDIA');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
-- check for flags...no flags.
END Validate_Act_DelvMethod_Items;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_DelvMethod_Record
--
-- PURPOSE
--   This procedure is to validate delivery method record
--
-- NOTES
-- End of Comments
PROCEDURE Validate_Act_DelvMethod_Record(
  p_act_DelvMethod_rec	IN	act_DelvMethod_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
) IS
        l_api_name		CONSTANT VARCHAR2(30)  := 'Validate_Act_DelvMethod_Record';
        l_api_version		CONSTANT NUMBER        := 1.0;
        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
  BEGIN
	-- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
					     l_api_version,
					     l_api_name,
					     G_PACKAGE_NAME)
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
        -- API body
	NULL;
        --
        -- END of API body.
        --
END Validate_Act_DelvMethod_Record;
---------------------------------------------------------------------
-- PROCEDURE
--    init_act_DelvMethod_rec
--
-- HISTORY
--    07/26/2000  sugupta  Create.
---------------------------------------------------------------------
PROCEDURE init_act_DelvMethod_rec(
   x_act_DelvMethod_rec  OUT NOCOPY  act_DelvMethod_rec_type
)
IS
BEGIN

     x_act_DelvMethod_rec.ACTIVITY_DELIVERY_METHOD_ID := FND_API.g_miss_num;
     x_act_DelvMethod_rec.last_update_date := FND_API.g_miss_date;
     x_act_DelvMethod_rec.last_updated_by := FND_API.g_miss_num;
     x_act_DelvMethod_rec.creation_date := FND_API.g_miss_date;
     x_act_DelvMethod_rec.created_by := FND_API.g_miss_num;
     x_act_DelvMethod_rec.last_update_login := FND_API.g_miss_num;
     x_act_DelvMethod_rec.object_version_number := FND_API.g_miss_num;
     x_act_DelvMethod_rec.ACT_DELIVERY_METHOD_USED_BY_ID := FND_API.g_miss_num;
     x_act_DelvMethod_rec.ARC_ACT_DELIVERY_USED_BY := FND_API.g_miss_char;
     x_act_DelvMethod_rec.DELIVERY_MEDIA_TYPE_CODE := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute_category := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute1 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute2 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute3 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute4 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute5 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute6 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute7 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute8 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute9 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute10 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute11 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute12 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute13 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute14 := FND_API.g_miss_char;
     x_act_DelvMethod_rec.attribute15 := FND_API.g_miss_char;
END init_act_DelvMethod_rec;

PROCEDURE complete_act_DelvMethod_rec(
	p_act_DelvMethod_rec  IN    act_DelvMethod_rec_type,
	x_act_DelvMethod_rec  OUT NOCOPY   act_DelvMethod_rec_type
) IS
	CURSOR c_dlv IS
	SELECT *
	FROM ams_act_delivery_methods
	WHERE activity_delivery_method_id = p_act_DelvMethod_rec.activity_delivery_method_id;
	l_act_DelvMethod_rec c_dlv%ROWTYPE;
BEGIN
	x_act_DelvMethod_rec  :=  p_act_DelvMethod_rec;
	OPEN c_dlv;
	FETCH c_dlv INTO l_act_DelvMethod_rec;
	IF c_dlv%NOTFOUND THEN
		CLOSE c_dlv;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
     END IF;
     CLOSE c_dlv;
	IF p_act_DelvMethod_rec.ACT_DELIVERY_METHOD_USED_BY_ID = FND_API.g_miss_num THEN
	   x_act_DelvMethod_rec.ACT_DELIVERY_METHOD_USED_BY_ID :=l_act_DelvMethod_rec.ACT_DELIVERY_METHOD_USED_BY_ID;
     END IF;
	IF p_act_DelvMethod_rec.ARC_ACT_DELIVERY_USED_BY = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ARC_ACT_DELIVERY_USED_BY := l_act_DelvMethod_rec.ARC_ACT_DELIVERY_USED_BY;
     END IF;
	IF p_act_DelvMethod_rec.delivery_media_type_code = FND_API.g_miss_CHAR THEN
	   x_act_DelvMethod_rec.delivery_media_type_code := l_act_DelvMethod_rec.delivery_media_type_code;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE_CATEGORY = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE_CATEGORY := l_act_DelvMethod_rec.ATTRIBUTE_CATEGORY;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE1 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE1 := l_act_DelvMethod_rec.ATTRIBUTE1;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE2 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE2 := l_act_DelvMethod_rec.ATTRIBUTE2;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE3 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE3 := l_act_DelvMethod_rec.ATTRIBUTE3;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE4 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE4 := l_act_DelvMethod_rec.ATTRIBUTE4;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE5 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE5 := l_act_DelvMethod_rec.ATTRIBUTE5;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE6 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE6 := l_act_DelvMethod_rec.ATTRIBUTE6;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE7 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE7 := l_act_DelvMethod_rec.ATTRIBUTE7;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE8 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE8 := l_act_DelvMethod_rec.ATTRIBUTE8;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE9 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE9 := l_act_DelvMethod_rec.ATTRIBUTE9;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE10 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE10 := l_act_DelvMethod_rec.ATTRIBUTE10;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE11 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE11 := l_act_DelvMethod_rec.ATTRIBUTE11;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE11 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE11 := l_act_DelvMethod_rec.ATTRIBUTE11;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE12 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE12 := l_act_DelvMethod_rec.ATTRIBUTE12;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE13 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE13 := l_act_DelvMethod_rec.ATTRIBUTE13;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE14 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE14 := l_act_DelvMethod_rec.ATTRIBUTE14;
     END IF;
	IF p_act_DelvMethod_rec.ATTRIBUTE15 = FND_API.g_miss_char THEN
	   x_act_DelvMethod_rec.ATTRIBUTE15 := l_act_DelvMethod_rec.ATTRIBUTE15;
     END IF;
END complete_act_DelvMethod_rec;
END AMS_ActDelvMethod_PVT;

/
