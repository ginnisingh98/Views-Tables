--------------------------------------------------------
--  DDL for Package Body AMS_ACTCATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTCATEGORY_PVT" as
/*$Header: amsvactb.pls 120.1 2005/06/15 01:31:45 appldev  $*/

-- NAME
--   AMS_ActCategory_PVT
--
-- HISTORY
--	11/8/99 	sugupta	CREATED
--
G_PACKAGE_NAME	CONSTANT VARCHAR2(30):='AMS_ActCategory_PVT';
G_FILE_NAME	CONSTANT VARCHAR2(12):='amsvactb.pls';

-- Debug mode
g_debug boolean := FALSE;
--g_debug boolean := TRUE;

--
-- Procedure and function declarations.

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Create_Act_Category
--
-- PURPOSE
--   This procedure is to create a category record that satisfy caller needs
--
-- HISTORY
--   11/8/1999        sugupta            created
-- End of Comments

PROCEDURE Create_Act_Category
( p_api_version		IN     NUMBER,
  p_init_msg_list	IN     VARCHAR2		:= FND_API.G_FALSE,
  p_commit		IN     VARCHAR2		:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count	 OUT NOCOPY    NUMBER,
  x_msg_data	 OUT NOCOPY    VARCHAR2,

  p_act_category_rec	IN     act_category_rec_type,
  x_act_category_id OUT NOCOPY    NUMBER
) IS

        l_api_name	CONSTANT VARCHAR2(30)  := 'Create_Act_Category';
        l_api_version	CONSTANT NUMBER        := 1.0;
	l_full_name     CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;

        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
        l_act_category_rec	act_category_rec_type := p_act_category_rec;

        l_act_category_id	NUMBER;

	CURSOR C_act_category_id IS
	SELECT ams_act_categories_s.NEXTVAL
	FROM dual;

  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Create_Act_Category_PVT;

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

	Validate_Act_Category
	( p_api_version				=> 1.0
	  ,p_init_msg_list     			=> p_init_msg_list
	  ,p_validation_level	 		=> p_validation_level
	  ,x_return_status			=> l_return_status
	  ,x_msg_count				=> x_msg_count
	  ,x_msg_data				=> x_msg_data

	  ,p_act_category_rec			=> l_act_category_rec
	);

	-- If any errors happen abort API.
	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--
	-- Get ID for activity category from sequence.
	OPEN c_act_category_id;
	FETCH c_act_category_id INTO l_act_category_rec.activity_category_id;
	CLOSE c_act_category_id;


	INSERT INTO AMS_ACT_CATEGORIES
	(activity_category_id,

	-- standard who columns
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,

	-- other columns
	object_version_number,
	act_category_used_by_id,
	arc_act_category_used_by,
	category_id,

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
	l_act_category_rec.activity_category_id,

	-- standard who columns
	sysdate,
	FND_GLOBAL.User_Id,
	sysdate,
	FND_GLOBAL.User_Id,
	FND_GLOBAL.Conc_Login_Id,

	1,  -- object_version_number
	l_act_category_rec.act_category_used_by_id,
	l_act_category_rec.arc_act_category_used_by,
	l_act_category_rec.category_id,

	l_act_category_rec.attribute_category,
	l_act_category_rec.attribute1,
	l_act_category_rec.attribute2,
	l_act_category_rec.attribute3,
	l_act_category_rec.attribute4,
	l_act_category_rec.attribute5,
	l_act_category_rec.attribute6,
	l_act_category_rec.attribute7,
	l_act_category_rec.attribute8,
	l_act_category_rec.attribute9,
	l_act_category_rec.attribute10,
	l_act_category_rec.attribute11,
	l_act_category_rec.attribute12,
	l_act_category_rec.attribute13,
	l_act_category_rec.attribute14,
	l_act_category_rec.attribute15

	);

	-- set OUT value
	x_act_category_id := l_act_category_rec.activity_category_id;

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

	        ROLLBACK TO Create_Act_Category_PVT;
        	x_return_status := FND_API.G_RET_STS_ERROR ;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	        );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	        ROLLBACK TO Create_Act_Category_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	        );


        WHEN OTHERS THEN

	        ROLLBACK TO Create_Act_Category_PVT;
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

END Create_Act_Category;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Act_Category
--
-- PURPOSE
--   This procedure is to update a category record that satisfy caller needs
--
-- HISTORY
--   11/8/1999        sugupta            created
-- End of Comments

PROCEDURE Update_Act_Category
( p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,

  p_act_category_rec	IN	act_category_rec_type
) IS
        l_api_name			CONSTANT VARCHAR2(30)  := 'Update_Act_Category';
        l_api_version			CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status			VARCHAR2(1);  -- Return value from procedures
        l_act_category_rec		act_category_rec_type;

  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Update_Act_Category_PVT;

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
	   complete_act_category_rec(
		p_act_category_rec,
		l_act_category_rec
	   );

        -- Perform the database operation

	Validate_Act_Category
	( p_api_version		=> 1.0
	  ,p_init_msg_list		=> p_init_msg_list
	  ,p_validation_level	=> p_validation_level
	  ,x_return_status		=> l_return_status
	  ,x_msg_count			=> x_msg_count
	  ,x_msg_data			=> x_msg_data
	  ,p_act_category_rec	=> l_act_category_rec
	);

	-- If any errors happen abort API.
	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	update AMS_ACT_CATEGORIES
	set
		last_update_date = sysdate
		,last_updated_by =  FND_GLOBAL.User_Id
		,last_update_login = FND_GLOBAL.Conc_Login_Id

		,object_version_number = l_act_category_rec.object_version_number+1
		,act_category_used_by_id = l_act_category_rec.act_category_used_by_id
		,arc_act_category_used_by = l_act_category_rec.arc_act_category_used_by
		,category_id = l_act_category_rec.activity_category_id
		,attribute_category = l_act_category_rec.attribute_category
		,attribute1 = l_act_category_rec.attribute1
		,attribute2 = l_act_category_rec.attribute2
		,attribute3 = l_act_category_rec.attribute3
		,attribute4 = l_act_category_rec.attribute4
		,attribute5 = l_act_category_rec.attribute5
		,attribute6 = l_act_category_rec.attribute6
		,attribute7 = l_act_category_rec.attribute7
		,attribute8 = l_act_category_rec.attribute8
		,attribute9 = l_act_category_rec.attribute9
		,attribute10 = l_act_category_rec.attribute10
		,attribute11 = l_act_category_rec.attribute11
		,attribute12 = l_act_category_rec.attribute12
		,attribute13 = l_act_category_rec.attribute13
		,attribute14 = l_act_category_rec.attribute14
		,attribute15 = l_act_category_rec.attribute15

	where activity_category_id = l_act_category_rec.activity_category_id
       and object_version_number = l_act_category_rec.object_version_number;

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

	        ROLLBACK TO Update_Act_Category_PVT;
        	x_return_status := FND_API.G_RET_STS_ERROR ;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	        ROLLBACK TO Update_Act_Category_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );


        WHEN OTHERS THEN

	        ROLLBACK TO Update_Act_Category_PVT;
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

END Update_Act_Category;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Delete_Act_Category
--
-- PURPOSE
--   This procedure is to delete a category record that satisfy caller needs
--
-- HISTORY
--   11/8/1999        sugupta            created
-- End of Comments

PROCEDURE Delete_Act_Category
( p_api_version		IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN     VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,

  p_act_category_id		IN     NUMBER,
  p_object_version       IN     NUMBER
) IS

        l_api_name		CONSTANT VARCHAR2(30)  := 'Delete_Act_Category';
        l_api_version	CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
        l_act_category_id	NUMBER := p_act_category_id;
  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Delete_Act_Category_PVT;

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
		DELETE FROM AMS_ACT_CATEGORIES
		WHERE  activity_category_id = l_act_category_id
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

	        ROLLBACK TO Delete_Act_Category_PVT;
        	x_return_status := FND_API.G_RET_STS_ERROR ;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count  	=>      x_msg_count,
	       p_data	     =>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	        ROLLBACK TO Delete_Act_Category_PVT;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	        FND_MSG_PUB.Count_AND_Get
        	( p_count	=>      x_msg_count,
	       p_data	=>      x_msg_data,
		  p_encoded	=>      FND_API.G_FALSE
	     );


        WHEN OTHERS THEN

	        ROLLBACK TO Delete_Act_Category_PVT;
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

END Delete_Act_Category;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Lock_Act_Category
--
-- PURPOSE
--   This procedure is to lock a category record that satisfy caller needs
--
-- HISTORY
--   11/8/1999        sugupta            created
-- End of Comments

PROCEDURE Lock_Act_Category
( p_api_version		IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level	IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,

  p_act_category_id 	IN     NUMBER,
  p_object_version       IN     NUMBER
) IS

        l_api_name		CONSTANT VARCHAR2(30)  := 'Lock_Act_Category';
        l_api_version	CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
        l_act_category_id	NUMBER;

	CURSOR c_act_category IS
    	SELECT activity_category_id
          FROM AMS_ACT_CATEGORIES
	 WHERE activity_category_id = p_act_category_id
	   and object_version_number = p_object_version
	   FOR UPDATE of activity_category_id NOWAIT;

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
	OPEN c_act_category;
	FETCH c_act_category INTO l_act_category_id;
	IF (c_act_category%NOTFOUND) THEN
	CLOSE c_act_category;
		-- Error, check the msg level and added an error message to the
		-- API message list
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
       	        THEN -- MMSG

			FND_MESSAGE.Set_Name('AMS', 'AMS_API_RECORD_NOT_FOUND');
			FND_MSG_PUB.Add;
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	END IF;

	CLOSE c_act_category;

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

END Lock_Act_Category;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Category
--
-- PURPOSE
--   This procedure is to validate an activity category record
--
-- HISTORY
--   11/8/1999        sugupta            created
-- End of Comments

PROCEDURE Validate_Act_Category
( p_api_version		IN     NUMBER,
  p_init_msg_list	IN     VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count	 OUT NOCOPY    NUMBER,
  x_msg_data	 OUT NOCOPY    VARCHAR2,

  p_act_category_rec	IN     act_category_rec_type
) IS

        l_api_name	CONSTANT VARCHAR2(30)  := 'Validate_Act_Category';
        l_api_version	CONSTANT NUMBER        := 1.0;
	l_full_name     CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;

        -- Status Local Variables
        l_return_status		VARCHAR2(1);  -- Return value from procedures
        l_act_category_rec	act_category_rec_type := p_act_category_rec;
        l_default_act_cty_rec	act_category_rec_type;
	l_act_category_id	NUMBER;
	l_dummy   NUMBER;

	CURSOR c_act_ctg_id_exists(ctg_id_in IN NUMBER,
						  arc_used_by in VARCHAR2,
						  arc_used_id_in in NUMBER) IS
        SELECT 1 from dual WHERE EXISTS(select 1 FROM AMS_ACT_CATEGORIES
		WHERE category_id = ctg_id_in
		and ARC_ACT_CATEGORY_USED_BY = arc_used_by
		and ACT_CATEGORY_USED_BY_ID = arc_used_id_in);


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

		Validate_Act_Cty_Items
		( p_act_category_rec	=> l_act_category_rec,
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

		Validate_Act_Cty_Record(
		  p_act_category_rec          => l_act_category_rec,
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

-- some logic
   open c_act_ctg_id_exists(p_act_category_rec.CATEGORY_ID,
					   p_act_category_rec.ARC_ACT_CATEGORY_USED_BY,
					   p_act_category_rec.ACT_CATEGORY_USED_BY_ID);
   fetch c_act_ctg_id_exists into l_dummy;
   close c_act_ctg_id_exists;
   IF l_dummy = 1 THEN
     IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name ('AMS', 'AMS_CTG_ACT_DUP');
        FND_MSG_PUB.add;
     END IF;
     x_return_status := FND_API.g_ret_sts_error;
     RETURN;
   END IF;
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

END Validate_Act_Category;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Cty_Items
--
-- PURPOSE
--   This procedure is to validate category items
-- End of Comments

PROCEDURE Validate_Act_Cty_Items
( p_act_category_rec	IN	act_category_rec_type,
  p_validation_mode		IN	VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status	 OUT NOCOPY VARCHAR2
) IS

	l_dummy  NUMBER;
	l_table_name	VARCHAR2(30);
	l_pk_name	VARCHAR2(30);
	l_pk_value	VARCHAR2(30);

	CURSOR c_act_ctg_id_exists(ctg_id_in IN NUMBER,
						  obj_ver_in IN NUMBER,
						  arc_used_by in VARCHAR2,
						  arc_used_id_in in NUMBER) IS
        SELECT 1 from dual WHERE EXISTS(select 1 FROM AMS_ACT_CATEGORIES
		WHERE category_id = ctg_id_in
		and object_version_number = obj_ver_in
		and ARC_ACT_CATEGORY_USED_BY = arc_used_by
		and ACT_CATEGORY_USED_BY_ID = arc_used_id_in);

BEGIN
        --  Initialize API/Procedure return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Check required parameters

     IF  (p_act_category_rec.ACT_CATEGORY_USED_BY_ID = FND_API.G_MISS_NUM OR
         p_act_category_rec.ACT_CATEGORY_USED_BY_ID IS NULL)
     THEN
          -- missing required fields
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
               FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_NO_USEDBYID');
               FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;

          -- If any error happens abort API.
           RETURN;
     END IF;

     -- ARC_ACT_CATEGORY_USED_BY

     IF (p_act_category_rec.ARC_ACT_CATEGORY_USED_BY = FND_API.G_MISS_CHAR OR
         p_act_category_rec.ARC_ACT_CATEGORY_USED_BY IS NULL)
     THEN
          -- missing required fields
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
               FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_NO_USEDBY');
               FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;

          -- If any error happens abort API.
           RETURN;
     END IF;

     IF  (p_act_category_rec.CATEGORY_ID = FND_API.G_MISS_NUM OR
         p_act_category_rec.CATEGORY_ID IS NULL)
     THEN

          -- missing required fields
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
               FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_NO_CATEGORY_ID');
               FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;

          -- If any error happens abort API.
           RETURN;
     END IF;

  --   Validate uniqueness
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_act_category_rec.activity_category_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
                'ams_act_categories',
                    'activity_category_id = ' ||  p_act_category_rec.activity_category_id
               ) = FND_API.g_false
          THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

	--
	-- Begin Validate Referential
	--
	/* code for chenging ACT_CATEGORY_USED_BY_ID is wrong rewritten by mukumar
	   on 04/10/2001
        -- Check FK parameter: ACT_CATEGORY_USED_BY_ID #1
	IF p_act_category_rec.ACT_CATEGORY_USED_BY_ID <> FND_API.g_miss_num
	THEN
		l_table_name := 'AMS_ACT_CATEGORIES';
		l_pk_name := 'ACT_CATEGORY_USED_BY_ID';
		l_pk_value := p_act_category_rec.ACT_CATEGORY_USED_BY_ID;

		IF AMS_Utility_PVT.Check_FK_Exists (
		 p_table_name		=> l_table_name
		 ,p_pk_name		=> l_pk_name
		 ,p_pk_value		=> l_pk_value
		) = FND_API.G_FALSE
		THEN
			IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_INVALID_EVEH_REF');
				FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.G_RET_STS_ERROR;
			-- If any errors happen abort API/Procedure.
			RETURN;

		END IF;  -- check_fk_exists
	END IF;

        -- Check FK parameter: ACT_CATEGORY_USED_BY_ID #3
	IF p_act_category_rec.ACT_CATEGORY_USED_BY_ID <> FND_API.g_miss_num
	THEN
		l_table_name := 'AMS_ACT_CATEGORIES';
		l_pk_name := 'ACT_CATEGORY_USED_BY_ID';
		l_pk_value := p_act_category_rec.ACT_CATEGORY_USED_BY_ID;

		IF AMS_Utility_PVT.Check_FK_Exists (
		 p_table_name			=> l_table_name
		 ,p_pk_name			=> l_pk_name
		 ,p_pk_value			=> l_pk_value
		) = FND_API.G_FALSE
		THEN
			IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_INVALID_EVEO_REF');
				FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.G_RET_STS_ERROR;
			-- If any errors happen abort API/Procedure.
			RETURN;

		END IF;  -- check_fk_exists
	END IF;
 */
	IF p_act_category_rec.ACT_CATEGORY_USED_BY_ID <> FND_API.g_miss_num
	THEN
		if(p_act_category_rec.ARC_ACT_CATEGORY_USED_BY = 'EVEH') THEN
			l_table_name := 'AMS_EVENT_HEADERS_ALL_B';
			l_pk_name := 'EVENT_HEADER_ID';
			l_pk_value := p_act_category_rec.ACT_CATEGORY_USED_BY_ID;
		elsif(p_act_category_rec.ARC_ACT_CATEGORY_USED_BY = 'EVEO' OR p_act_category_rec.ARC_ACT_CATEGORY_USED_BY = 'EONE') THEN
			l_table_name := 'AMS_EVENT_OFFERS_ALL_B';
			l_pk_name := 'EVENT_OFFER_ID';
			l_pk_value := p_act_category_rec.ACT_CATEGORY_USED_BY_ID;
		else
			IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_BAD_USEDBY');
				FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.G_RET_STS_ERROR;
			-- If any errors happen abort API/Procedure.
			RETURN;
		end if;
		IF AMS_Utility_PVT.Check_FK_Exists (
		 p_table_name		=> l_table_name
		 ,p_pk_name		=> l_pk_name
		 ,p_pk_value		=> l_pk_value
		) = FND_API.G_FALSE
		THEN
			IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_INVALID_EVEH_REF');
				FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.G_RET_STS_ERROR;
			-- If any errors happen abort API/Procedure.
			RETURN;

		END IF;  -- check_fk_exists
	END IF;
        -- Check FK parameter: CATEGORY_ID
	IF p_act_category_rec.CATEGORY_ID <> FND_API.g_miss_num
	THEN
		l_table_name := 'AMS_CATEGORIES_B';
		l_pk_name := 'CATEGORY_ID';
		l_pk_value := p_act_category_rec.CATEGORY_ID;

		IF AMS_Utility_PVT.Check_FK_Exists (
		 p_table_name			=> l_table_name
		 ,p_pk_name			=> l_pk_name
		 ,p_pk_value			=> l_pk_value
		) = FND_API.G_FALSE
		THEN
			IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_INVALID_CAT_REF');
				FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.G_RET_STS_ERROR;
			-- If any errors happen abort API/Procedure.
			RETURN;

		END IF;  -- check_fk_exists
	END IF;

--   check for lookups....

   IF p_act_category_rec.arc_act_category_used_by <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_act_category_rec.arc_act_category_used_by
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_CAT_BAD_USEDBY');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

-- check for flags...no flags.
-- some logic
   open c_act_ctg_id_exists(TO_NUMBER(p_act_category_rec.CATEGORY_ID),
					   TO_NUMBER(p_act_category_rec.OBJECT_VERSION_NUMBER),
					   p_act_category_rec.ARC_ACT_CATEGORY_USED_BY,
					   TO_NUMBER(p_act_category_rec.ACT_CATEGORY_USED_BY_ID));
   fetch c_act_ctg_id_exists into l_dummy;
   close c_act_ctg_id_exists;
   IF l_dummy = 1 THEN
     IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name ('AMS', 'AMS_CTG_ACT_DUP');
        FND_MSG_PUB.add;
     END IF;
     x_return_status := FND_API.g_ret_sts_error;
     RETURN;
   END IF;
END Validate_Act_Cty_Items;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Cty_Record
--
-- PURPOSE
--   This procedure is to validate category record
--
-- NOTES
-- End of Comments

PROCEDURE Validate_Act_Cty_Record(
  p_act_category_rec	IN	act_category_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
) IS
        l_api_name		CONSTANT VARCHAR2(30)  := 'Validate_Act_Cty_Record';
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
END Validate_Act_Cty_Record;

PROCEDURE complete_act_category_rec(
	p_act_category_rec  IN    act_category_rec_type,
	x_act_category_rec  OUT NOCOPY   act_category_rec_type
) IS

	CURSOR c_cat IS
	SELECT *
	FROM ams_act_categories
	WHERE activity_category_id = p_act_category_rec.activity_category_id;

	l_act_category_rec c_cat%ROWTYPE;

BEGIN

	x_act_category_rec  :=  p_act_category_rec;

	OPEN c_cat;
	FETCH c_cat INTO l_act_category_rec;
	IF c_cat%NOTFOUND THEN
		CLOSE c_cat;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
     END IF;
     CLOSE c_cat;

	IF p_act_category_rec.ACT_CATEGORY_USED_BY_ID = FND_API.g_miss_num THEN
	   x_act_category_rec.ACT_CATEGORY_USED_BY_ID := l_act_category_rec.ACT_CATEGORY_USED_BY_ID;
     END IF;
	IF p_act_category_rec.ARC_ACT_CATEGORY_USED_BY = FND_API.g_miss_char THEN
	   x_act_category_rec.ARC_ACT_CATEGORY_USED_BY := l_act_category_rec.ARC_ACT_CATEGORY_USED_BY;
     END IF;
	IF p_act_category_rec.CATEGORY_ID = FND_API.g_miss_num THEN
	   x_act_category_rec.CATEGORY_ID := l_act_category_rec.CATEGORY_ID;
     END IF;
	IF p_act_category_rec.ATTRIBUTE_CATEGORY = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE_CATEGORY := l_act_category_rec.ATTRIBUTE_CATEGORY;
     END IF;
	IF p_act_category_rec.ATTRIBUTE1 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE1 := l_act_category_rec.ATTRIBUTE1;
     END IF;
	IF p_act_category_rec.ATTRIBUTE2 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE2 := l_act_category_rec.ATTRIBUTE2;
     END IF;
	IF p_act_category_rec.ATTRIBUTE3 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE3 := l_act_category_rec.ATTRIBUTE3;
     END IF;
	IF p_act_category_rec.ATTRIBUTE4 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE4 := l_act_category_rec.ATTRIBUTE4;
     END IF;
	IF p_act_category_rec.ATTRIBUTE5 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE5 := l_act_category_rec.ATTRIBUTE5;
     END IF;
	IF p_act_category_rec.ATTRIBUTE6 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE6 := l_act_category_rec.ATTRIBUTE6;
     END IF;
	IF p_act_category_rec.ATTRIBUTE7 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE7 := l_act_category_rec.ATTRIBUTE7;
     END IF;
	IF p_act_category_rec.ATTRIBUTE8 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE8 := l_act_category_rec.ATTRIBUTE8;
     END IF;
	IF p_act_category_rec.ATTRIBUTE9 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE9 := l_act_category_rec.ATTRIBUTE9;
     END IF;
	IF p_act_category_rec.ATTRIBUTE10 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE10 := l_act_category_rec.ATTRIBUTE10;
     END IF;

	IF p_act_category_rec.ATTRIBUTE11 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE11 := l_act_category_rec.ATTRIBUTE11;
     END IF;
	IF p_act_category_rec.ATTRIBUTE11 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE11 := l_act_category_rec.ATTRIBUTE11;
     END IF;
	IF p_act_category_rec.ATTRIBUTE12 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE12 := l_act_category_rec.ATTRIBUTE12;
     END IF;
	IF p_act_category_rec.ATTRIBUTE13 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE13 := l_act_category_rec.ATTRIBUTE13;
     END IF;
	IF p_act_category_rec.ATTRIBUTE14 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE14 := l_act_category_rec.ATTRIBUTE14;
     END IF;
	IF p_act_category_rec.ATTRIBUTE15 = FND_API.g_miss_char THEN
	   x_act_category_rec.ATTRIBUTE15 := l_act_category_rec.ATTRIBUTE15;
     END IF;

END complete_act_category_rec;

/*********************** server side TEST CASE ***************************/

-- Start of Comments
--
-- NAME
--   Unit_Test_Insert
--   Unit_Test_Delete
--   Unit_Test_Update
--   Unit_Test_Lock
--
-- PURPOSE
--   These procedures are to test each procedure that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   11/13/1999        sugupta            created
-- End of Comments

--********************************************************
/* 0614
PROCEDURE Unit_Test_Insert
IS

	-- local variables
	l_act_category_rec		AMS_CATEGORIES_VL%ROWTYPE;
        l_return_status			VARCHAR2(1);
        l_msg_count			NUMBER;
        l_msg_data			VARCHAR2(200);
        l_category_id			AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

	l_category_req_item_rec		category_validate_rec_type;
        l_Category_validate_item_rec	category_validate_rec_type;
        l_Category_default_item_rec	category_validate_rec_type;
        l_Category_validate_row_rec	category_validate_rec_type;

  BEGIN

-- turned on debug mode
IF AMS_ActCategory_PVT.g_debug = TRUE THEN

	l_category_rec.CATEGORY_ID := 1234;
	l_category_rec.ARC_CATEGORY_CREATED_FOR := 'hung';
	l_category_rec.CATEGORY_NAME := 'sugupta_category';


        AMS_ActCategory_PVT.Create_Category (
         p_api_version			=> 1.0 -- p_api_version
        ,p_init_msg_list		=> FND_API.G_FALSE
        ,p_commit			=> FND_API.G_FALSE
        ,p_validation_level		=> FND_API.G_VALID_LEVEL_FULL
        ,x_return_status		=> l_return_status
        ,x_msg_count			=> l_msg_count
        ,x_msg_data			=> l_msg_data

	,p_PK				=> FND_API.G_TRUE
	,p_default			=> FND_API.G_TRUE
        ,p_Category_req_item_rec	=> l_Category_req_item_rec
        ,p_Category_validate_item_rec	=> l_Category_validate_item_rec
        ,p_Category_default_item_rec	=> l_Category_default_item_rec
        ,p_Category_validate_row_rec	=> l_Category_validate_row_rec
        ,p_category_rec			=> l_category_rec
        ,x_category_id			=> l_category_id
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	ELSE
		commit work;
        END IF;

	NULL;

ELSE
END IF;


END Unit_Test_Insert;

--********************************************************

PROCEDURE Unit_Test_Delete
IS

	-- local variables
	l_category_rec		AMS_CATEGORIES_VL%ROWTYPE;
        l_return_status		VARCHAR2(1);
        l_msg_count		NUMBER;
        l_msg_data		VARCHAR2(200);
        l_category_id		AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

	l_Category_req_item_rec		category_validate_rec_type;
        l_Category_validate_item_rec	category_validate_rec_type;
        l_Category_default_item_rec	category_validate_rec_type;
        l_Category_validate_row_rec	category_validate_rec_type;

BEGIN

-- turned on debug mode
IF AMS_ActCategory_PVT.g_debug = TRUE
THEN

	l_category_rec.category_id := 1234;


        AMS_ActCategory_PVT.Delete_Category (
         p_api_version		=> 1.0 -- p_api_version
        ,p_init_msg_list	=> FND_API.G_FALSE
        ,p_commit		=> FND_API.G_FALSE
        ,p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec		=> l_category_rec

        ,x_return_status	=> l_return_status
        ,x_msg_count		=> l_msg_count
        ,x_msg_data		=> l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	ELSE
		commit work;
        END IF;

	NULL;

ELSE
END IF;


END Unit_Test_Delete;


--********************************************************

PROCEDURE Unit_Test_Update
IS

	-- local variables
	l_category_rec		AMS_CATEGORIES_VL%ROWTYPE;
        l_return_status		VARCHAR2(1);
        l_msg_count		NUMBER;
        l_msg_data		VARCHAR2(200);
        l_category_id		AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

	l_Category_req_item_rec		category_validate_rec_type;
        l_Category_validate_item_rec	category_validate_rec_type;
        l_Category_default_item_rec	category_validate_rec_type;
        l_Category_validate_row_rec	category_validate_rec_type;

	cursor C(my_category_id NUMBER) is
	select *
	  from AMS_CATEGORIES_VL
	 WHERE CATEGORY_ID = my_category_id;
  BEGIN

-- turned on debug mode
IF AMS_ActCategory_PVT.g_debug = TRUE
THEN

	l_category_id := 1234;
	OPEN C(l_category_id);
	FETCH C INTO l_category_rec;

	l_category_rec.NOTES := 'NOTES UPDATED1';

        AMS_ActCategory_PVT.Update_Category (
         p_api_version		=> 1.0 -- p_api_version
        ,p_init_msg_list	=> FND_API.G_FALSE
        ,p_commit		=> FND_API.G_FALSE
        ,p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec		=> l_category_rec

        ,x_return_status	=> l_return_status
        ,x_msg_count		=> l_msg_count
        ,x_msg_data		=> l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
	ELSE
		commit work;
        END IF;

	NULL;

ELSE
END IF;


END Unit_Test_Update;


--********************************************************


PROCEDURE Unit_Test_Lock
IS

	-- local variables
	l_category_rec		AMS_CATEGORIES_VL%ROWTYPE;
        l_return_status		VARCHAR2(1);
        l_msg_count		NUMBER;
        l_msg_data		VARCHAR2(200);
        l_category_id		AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

	l_Category_req_item_rec		category_validate_rec_type;
        l_Category_validate_item_rec	category_validate_rec_type;
        l_Category_default_item_rec	category_validate_rec_type;
        l_Category_validate_row_rec	category_validate_rec_type;


	cursor C(my_category_id NUMBER) is
	 select * from AMS_CATEGORIES_B WHERE CATEGORY_ID = my_category_id;
  BEGIN

-- turned on debug mode
IF AMS_ActCategory_PVT.g_debug = TRUE
THEN

	l_category_rec.category_id := 1234;
	l_category_rec.NOTES := 'server side test';

        AMS_ActCategory_PVT.Lock_Category (
         p_api_version		=> 1.0 -- p_api_version
        ,p_init_msg_list	=> FND_API.G_FALSE
        ,p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec		=> l_category_rec

        ,x_return_status	=> l_return_status
        ,x_msg_count		=> l_msg_count
        ,x_msg_data		=> l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  		--RAISE FND_API.G_EXC_ERROR;
        END IF;

	NULL;

ELSE
END IF;


END Unit_Test_Lock;

*********************** server side TEST CASE *****************************************

-- Start of Comments
--
-- NAME
--   Unit_Test_Act_Insert
--   Unit_Test_Act_Delete
--   Unit_Test_Act_Update
--   Unit_Test_Act_Lock
--
-- PURPOSE
--   This procedure is to test each procedure that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   11/8/1999        sugupta            created
-- End of Comments

PROCEDURE Unit_Test_Act_Insert
is

	-- local variables
	l_act_category_rec		act_category_rec_type;
	l_return_status		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(200);
	l_act_category_id		AMS_ACT_CATEGORIES.ACTIVITY_CATEGORY_ID%TYPE;

	l_act_cty_validate_item_rec	Act_category_validate_rec_type;
	l_act_cty_default_item_rec	Act_category_validate_rec_type;
	l_act_cty_validate_row_rec	Act_category_validate_rec_type;

  BEGIN

	-- turned on debug mode
    IF AMS_ActCategory_PVT.G_DEBUG = TRUE THEN

-- Insert case 1

	l_act_category_rec.ACTIVITY_CATEGORY_ID := 1234;
	l_act_category_rec.ACT_CATEGORY_USED_BY_ID := 1000;
	l_act_category_rec.ARC_ACT_CATEGORY_USED_BY := 1000;
	l_act_category_rec.CATEGORY_ID := 1234;


	AMS_ActCategory_PVT.Create_Act_Category (
	p_api_version			=> 1.0 -- p_api_version
	,p_init_msg_list		=> FND_API.G_FALSE
	,p_commit			=> FND_API.G_FALSE
	,p_validation_level		=> FND_API.G_VALID_LEVEL_FULL
	,x_return_status		=> l_return_status
	,x_msg_count			=> l_msg_count
	,x_msg_data			=> l_msg_data

	,p_PK				=> FND_API.G_TRUE
	,p_default			=> FND_API.G_TRUE
	,p_Category_req_item_rec	=> l_act_category_req_item_rec
	,p_Category_validate_item_rec	=> l_act_cty_validate_item_rec
	,p_Category_default_item_rec	=> l_act_cty_default_item_rec
	,p_Category_validate_row_rec	=> l_act_cty_validate_row_rec
	,p_category_rec			=> l_act_category_rec
	,x_act_category_id		=> l_act_category_id
	);

	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
	ELSE
		commit work;
	END IF;

	null;

    ELSE
    END IF;

END Unit_Test_Act_Insert;


PROCEDURE Unit_Test_Act_Delete
is

	-- local variables
	l_act_category_rec		act_category_rec_type;
	l_return_status		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(200);
	l_act_category_id		AMS_ACT_CATEGORIES.ACTIVITY_CATEGORY_ID%TYPE;

	l_act_category_req_item_rec	act_category_validate_rec_type;
	l_act_cty_validate_item_rec	act_category_validate_rec_type;
	l_act_cty_default_item_rec	act_category_validate_rec_type;
	l_act_cty_validate_row_rec	act_category_validate_rec_type;

  BEGIN

	-- turned on debug mode
    IF AMS_ActCategory_PVT.G_DEBUG = TRUE THEN


-- Delete test case 1
	l_act_category_rec.activity_category_id := 1234;
        AMS_ActCategory_PVT.Delete_Act_Category (
         p_api_version          => 1.0 -- p_api_version
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_commit               => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec		=> l_act_category_rec

        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	ELSE
		commit work;
		end if;

	null;

    ELSE
    END IF;

END Unit_Test_Act_Delete;



PROCEDURE Unit_Test_Act_Update
is

	-- local variables
	l_act_category_rec		act_category_rec_type;
	l_return_status		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(200);
	l_act_category_id		AMS_ACT_CATEGORIES.ACTIVITY_CATEGORY_ID%TYPE;

	l_act_category_req_item_rec	act_category_validate_rec_type;
	l_act_cty_validate_item_rec	act_category_validate_rec_type;
	l_act_cty_default_item_rec	act_category_validate_rec_type;
	l_act_cty_validate_row_rec	act_category_validate_rec_type;

	CURSOR C(my_act_category_id NUMBER) is
	SELECT *
	  FROM AMS_ACT_CATEGORIES
	 WHERE ACTIVITY_CATEGORY_ID = my_act_category_id;

  BEGIN

	-- turned on debug mode
    IF AMS_ActCategory_PVT.G_DEBUG = TRUE THEN


-- Update test case 1

	l_act_category_id := 1234;
	OPEN C(l_act_category_id);
	FETCH C INTO l_act_category_rec;

	l_act_category_rec.ATTRIBUTE1 := 'ATTRIBUTE1 UPDATED1';

        AMS_ActCategory_PVT.Update_Act_Category (
         p_api_version		=> 1.0 -- p_api_version
        ,p_init_msg_list	=> FND_API.G_FALSE
        ,p_commit		=> FND_API.G_FALSE
        ,p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec		=> l_act_category_rec

        ,x_return_status	=> l_return_status
        ,x_msg_count		=> l_msg_count
        ,x_msg_data		=> l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
	ELSE
		commit work;
        END IF;
	CLOSE C;

	null;

    ELSE
    END IF;

END Unit_Test_Act_Update;


PROCEDURE Unit_Test_Act_Lock
is

	-- local variables
	l_act_category_rec		act_category_rec_type;
	l_return_status		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(200);
	l_act_category_id		AMS_ACT_CATEGORIES.ACTIVITY_CATEGORY_ID%TYPE;

	l_act_category_req_item_rec	act_category_validate_rec_type;
	l_act_cty_validate_item_rec	act_category_validate_rec_type;
	l_act_cty_default_item_rec	act_category_validate_rec_type;
	l_act_cty_validate_row_rec	act_category_validate_rec_type;

  BEGIN

	-- turned on debug mode
    IF AMS_ActCategory_PVT.G_DEBUG = TRUE THEN


-- Lock test case 1

	l_act_category_rec.activity_category_id := 1234;

        AMS_ActCategory_PVT.Lock_Act_Category (
         p_api_version          => 1.0 -- p_api_version
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec		=> l_act_category_rec

        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
  		--RAISE FND_API.G_EXC_ERROR;
        END IF;


	null;

    ELSE
    END IF;

END Unit_Test_Act_Lock;
*/--0614
END AMS_ActCategory_PVT;

/
