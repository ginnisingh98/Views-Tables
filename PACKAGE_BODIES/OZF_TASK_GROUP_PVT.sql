--------------------------------------------------------
--  DDL for Package Body OZF_TASK_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TASK_GROUP_PVT" AS
/* $Header: ozfvttgb.pls 115.2 2003/11/13 06:45:20 anujgupt noship $ */
--

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OZF_TASK_GROUP_PVT';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'ozfvreab.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Create_task_group
--
-- PURPOSE
--    Create a task group code.
--
-- PARAMETERS
--    p_task_group   : the new record to be inserted
--    x_task_template_group_id  : return the task_template_group_id
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If task_template_group_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If task_template_group_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE  Create_task_group (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER

   ,p_task_group          	    IN     task_group_rec_type
   ,x_task_template_group_id         OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_task_group';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status      varchar2(30);
l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);
l_object_version_number  number := 1;
l_return_status     VARCHAR2(1);
--
l_task_template_group_id number;
l_task_group		task_group_rec_type := p_task_group;
l_active_flag	varchar2(1) := FND_API.G_TRUE;
l_reason_type_id number;
--
--Create this sequence in case and use in API
CURSOR reason_type_id_seq IS
SELECT ozf_reasons_s.nextval FROM DUAL;

BEGIN
	-- Standard begin of API savepoint
	SAVEPOINT  Create_task_group_PVT;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
		FND_MSG_PUB.Add;
	END IF;
	--Initialize message list if p_init_msg_list is TRUE.
	IF FND_API.To_Boolean (p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;
	-- Initialize API return status to sucess
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Validate task_group
	Validate_task_group (
     		p_api_version       => l_api_version,
	    	p_init_msg_list     => p_init_msg_list,
	 	p_validation_level  => p_validation_level,
		x_return_status     => l_return_status,
		x_msg_count         => x_msg_count,
		x_msg_data          => x_msg_data,
		p_task_group   	    => l_task_group
	);

  	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
  	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	BEGIN
	  JTF_TASK_TEMP_GROUP_PUB.CREATE_TASK_TEMPLATE_GROUP
  	  (
		P_API_VERSION => p_api_version,
		P_INIT_MSG_LIST => FND_API.G_FALSE,
		P_COMMIT => FND_API.G_FALSE,
		P_VALIDATE_LEVEL => p_validation_level,
 		P_TEMPLATE_GROUP_NAME => l_task_group.template_group_name,
    		P_SOURCE_OBJECT_TYPE_CODE => l_task_group.source_object_type_code,
		P_START_DATE_ACTIVE => l_task_group.start_date_active,
		P_END_DATE_ACTIVE => l_task_group.end_date_active,
		P_DESCRIPTION => l_task_group.description,
		P_ATTRIBUTE1 => l_task_group.attribute1,
		P_ATTRIBUTE2 => l_task_group.attribute2,
		P_ATTRIBUTE3 => l_task_group.attribute3,
		P_ATTRIBUTE4 => l_task_group.attribute4,
		P_ATTRIBUTE5 => l_task_group.attribute5,
		P_ATTRIBUTE6 => l_task_group.attribute6,
		P_ATTRIBUTE7 => l_task_group.attribute7,
		P_ATTRIBUTE8 => l_task_group.attribute8,
		P_ATTRIBUTE9 => l_task_group.attribute9,
		P_ATTRIBUTE10 => l_task_group.attribute10,
		P_ATTRIBUTE11 => l_task_group.attribute11,
		P_ATTRIBUTE12 => l_task_group.attribute12,
		P_ATTRIBUTE13 => l_task_group.attribute13,
		P_ATTRIBUTE14 => l_task_group.attribute14,
		P_ATTRIBUTE15 => l_task_group.attribute15,
		P_ATTRIBUTE_CATEGORY => l_task_group.attribute_category,
		X_RETURN_STATUS => x_return_status,
		X_MSG_COUNT => x_msg_count,
  		X_MSG_DATA => x_msg_data,
    		X_TASK_TEMPLATE_GROUP_ID => l_task_template_group_id
	  );
	EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

	-- Create Reason_Type and Reason_Code relationship
	--Create this sequence in case and use in API
        /*
	OPEN reason_type_id_seq;
		FETCH reason_type_id_seq INTO l_reason_type_id;
	CLOSE reason_type_id_seq;

	INSERT INTO ozf_reasons (
		reason_type_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		active_flag,
		reason_type,
		task_template_group_id
	)
	VALUES (
		l_reason_type_id,
		l_object_version_number,
		SYSDATE,
		NVL(FND_GLOBAL.user_id, -1),
		SYSDATE,
		NVL(FND_GLOBAL.user_id, -1),
		NVL(FND_GLOBAL.conc_login_id, -1),
		l_active_flag,
		l_task_group.reason_type,
		l_task_template_group_id
	);
        */

	-- assign reason code id to out param
	x_task_template_group_id := l_task_template_group_id;

	--Standard check of commit
	IF FND_API.To_Boolean ( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
		FND_MSG_PUB.Add;
	END IF;
	--Standard call to get message count and if count=1, get the message
	FND_MSG_PUB.Count_And_Get (
		p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data  => x_msg_data
	);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO  Create_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Create_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Create_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
--
END Create_task_group;
---------------------------------------------------------------------
-- PROCEDURE
--    Update_task_group
--
-- PURPOSE
--    Update a task_group code.
--
-- PARAMETERS
--    p_task_group   : the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE  Update_task_group (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT  NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER

   ,p_task_group          	     IN    task_group_rec_type
   ,x_object_version_number  OUT  NOCOPY NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Update_task_group';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status      varchar2(30);
l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);
l_object_version_number  number := 1;
l_return_status     VARCHAR2(1);
--
l_task_group 		task_group_rec_type := p_task_group;
l_reason_type 		varchar2(30);
--
CURSOR c_reason_type(cv_temp_group_id NUMBER) IS
select reason_type, object_version_number
from   ozf_reasons
where  task_template_group_id = cv_temp_group_id;

BEGIN

	-- Standard begin of API savepoint
	SAVEPOINT  Update_task_group_PVT;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
		FND_MSG_PUB.Add;
	END IF;

	--Initialize message list if p_init_msg_list is TRUE.
	IF FND_API.To_Boolean (p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;
	-- Initialize API return status to sucess
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
		Check_task_group_Items(
			p_task_group_rec        => p_task_group,
			p_validation_mode   => JTF_PLSQL_API.g_update,
			x_return_status     => l_return_status
		);

  		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
  		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	-- Replace g_miss_char/num/date with current column values
	Complete_task_group_Rec(
		p_task_group_rec        => p_task_group,
		x_complete_rec      => l_task_group
	);

	-- assign object version number
	l_object_version_number := l_task_group.object_version_number;

	BEGIN
	  JTF_TASK_TEMP_GROUP_PUB.UPDATE_TASK_TEMPLATE_GROUP
  	  (
		P_API_VERSION => p_api_version,
		P_INIT_MSG_LIST => FND_API.G_FALSE,
		P_COMMIT => FND_API.G_FALSE,
		P_VALIDATE_LEVEL => p_validation_level,
 		P_TASK_TEMPLATE_GROUP_ID => l_task_group.task_template_group_id,
 		P_TEMPLATE_GROUP_NAME => l_task_group.template_group_name,
    		P_SOURCE_OBJECT_TYPE_CODE => l_task_group.source_object_type_code,
		P_START_DATE_ACTIVE => l_task_group.start_date_active,
		P_END_DATE_ACTIVE => l_task_group.end_date_active,
		P_DESCRIPTION => l_task_group.description,
		P_ATTRIBUTE1 => l_task_group.attribute1,
		P_ATTRIBUTE2 => l_task_group.attribute2,
		P_ATTRIBUTE3 => l_task_group.attribute3,
		P_ATTRIBUTE4 => l_task_group.attribute4,
		P_ATTRIBUTE5 => l_task_group.attribute5,
		P_ATTRIBUTE6 => l_task_group.attribute6,
		P_ATTRIBUTE7 => l_task_group.attribute7,
		P_ATTRIBUTE8 => l_task_group.attribute8,
		P_ATTRIBUTE9 => l_task_group.attribute9,
		P_ATTRIBUTE10 => l_task_group.attribute10,
		P_ATTRIBUTE11 => l_task_group.attribute11,
		P_ATTRIBUTE12 => l_task_group.attribute12,
		P_ATTRIBUTE13 => l_task_group.attribute13,
		P_ATTRIBUTE14 => l_task_group.attribute14,
		P_ATTRIBUTE15 => l_task_group.attribute15,
		P_ATTRIBUTE_CATEGORY => l_task_group.attribute_category,
		X_RETURN_STATUS => x_return_status,
		X_MSG_COUNT => x_msg_count,
  		X_MSG_DATA => x_msg_data,
    		X_OBJECT_VERSION_NUMBER => l_object_version_number
	  );
	EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

	x_object_version_number := l_object_version_number;

        /*
	l_reason_type := l_task_group.reason_type;

  	OPEN c_reason_type(l_task_group.task_template_group_id);
  	  FETCH c_reason_type INTO l_reason_type, l_object_version_number;
  	  IF c_reason_type%NOTFOUND THEN
        	CLOSE c_reason_type;
        	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           	  FND_MESSAGE.set_name('OZF','OZF_API_RECORD_NOT_FOUND');
           	  FND_MSG_PUB.add;
        	END IF;
        	RAISE FND_API.g_exc_error;
  	  END IF;
  	CLOSE c_reason_type;

	-- Update the reason type if changed
	IF l_reason_type <> l_task_group.reason_type  THEN
	 UPDATE ozf_reasons
	 SET    REASON_TYPE = l_task_group.reason_type
	 ,      LAST_UPDATE_DATE = sysdate
	 ,      LAST_UPDATED_BY = NVL(FND_GLOBAL.user_id, -1)
	 ,      OBJECT_VERSION_NUMBER = l_object_version_number + 1
	 WHERE  TASK_TEMPLATE_GROUP_ID = l_task_group.task_template_group_id;
	END IF;
        */

	--Standard check of commit
	IF FND_API.To_Boolean ( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
		FND_MSG_PUB.Add;
	END IF;
	--Standard call to get message count and if count=1, get the message
	FND_MSG_PUB.Count_And_Get (
		p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data  => x_msg_data
	);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO  Update_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Update_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Update_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
--
END Update_task_group;
---------------------------------------------------------------------
-- PROCEDURE
--    Delete task_group
--
-- PURPOSE
--    Delete a task_group code.
--
-- PARAMETERS
--    p_task_template_group_id   : the record with new items.
--    p_object_version_number   : object version number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
----------------------------------------------------------------------
PROCEDURE  Delete_task_group (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT  NOCOPY VARCHAR2
   ,x_msg_data               OUT  NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER

   ,p_task_template_group_id  	     IN    NUMBER
   ,p_object_version_number  IN    NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Delete_task_group';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status      varchar2(30);
l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);
l_object_version_number  number := 1;

l_task_template_group_id       number;

CURSOR exist_task_group_csr(p_id in number) IS
select task_template_group_id
from   ozf_claims_all
where  task_template_group_id = p_id;

--
BEGIN
	-- Standard begin of API savepoint
	SAVEPOINT  Delete_task_group_PVT;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
		FND_MSG_PUB.Add;
	END IF;
	--Initialize message list if p_init_msg_list is TRUE.
	IF FND_API.To_Boolean (p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;
	-- Initialize API return status to sucess
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	OPEN exist_task_group_csr(p_task_template_group_id);
	   FETCH exist_task_group_csr INTO l_task_template_group_id;
	CLOSE exist_task_group_csr;

        IF l_task_template_group_id IS NOT NULL THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TASK_GROUP_USED');
            FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.g_exc_error;
	END IF;

 	BEGIN
	   l_object_version_number := p_object_version_number;
	  JTF_TASK_TEMP_GROUP_PUB.DELETE_TASK_TEMPLATE_GROUP
	  (
		P_API_VERSION => p_api_version,
		P_INIT_MSG_LIST => FND_API.G_FALSE,
		P_COMMIT => FND_API.G_FALSE,
		P_VALIDATE_LEVEL => p_validation_level,
 		P_TASK_TEMPLATE_GROUP_ID => p_task_template_group_id,
		X_RETURN_STATUS => x_return_status,
		X_MSG_COUNT => x_msg_count,
  		X_MSG_DATA => x_msg_data,
    		X_OBJECT_VERSION_NUMBER => l_object_version_number
	  );
	EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

	-- Remove Reason Type association
	-- CHECK Check to see if this should be deleted or made inactive
	DELETE FROM ozf_reasons
	WHERE  task_template_group_id = p_task_template_group_id;

	--Standard check of commit
	IF FND_API.To_Boolean ( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
		FND_MSG_PUB.Add;
	END IF;
	--Standard call to get message count and if count=1, get the message
	FND_MSG_PUB.Count_And_Get (
		p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data  => x_msg_data
	);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO  Delete_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Delete_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Delete_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
--
END Delete_task_group;
---------------------------------------------------------------
-- PROCEDURE
--    Get_task_group
--
-- PURPOSE
--    Get task_group code.
--
-- PARAMETERS
--    p_task_template_group_id   : the record with new items.
--    p_object_version_number   : object version number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
----------------------------------------------------------------------
PROCEDURE  Get_task_group (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_task_template_group_id 	     IN    NUMBER
   ,p_template_group_name    	     IN    VARCHAR2
   ,p_source_object_type_code IN   VARCHAR2
   ,p_start_date_active	     IN    DATE
   ,p_end_date_active	     IN    DATE
   ,p_sort_data		     IN    ozf_sort_data
   ,p_request_rec	     IN    ozf_request_rec_type
   ,x_return_rec	     OUT NOCOPY  ozf_return_rec_type
   ,x_task_group  	    	     OUT NOCOPY  task_group_tbl_type
   )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Get_task_group';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status      varchar2(30);
l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);
l_object_version_number  number := 1;

l_sort_data		JTF_TASK_TEMP_GROUP_PUB.SORT_DATA;
l_query_or_next_code 	varchar2(1) := 'Q';
l_start_pointer		number;
l_rec_wanted		number;
l_show_all		varchar2(1) := 'N'; --FND_API.G_FALSE;
l_template_group	JTF_TASK_TEMP_GROUP_PUB.TASK_TEMP_GROUP_TBL;
l_reason_type		varchar2(30);
--
CURSOR c_reason_type(cv_temp_group_id NUMBER) IS
select reason_type
from   ozf_reasons
where  task_template_group_id = cv_temp_group_id;

BEGIN
	-- Standard begin of API savepoint
	SAVEPOINT  Get_task_group_PVT;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
		FND_MSG_PUB.Add;
	END IF;
	--Initialize message list if p_init_msg_list is TRUE.
	IF FND_API.To_Boolean (p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;
	-- Initialize API return status to sucess
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	FOR i in 1..p_sort_data.count LOOP
	  l_sort_data(i).field_name := p_sort_data(i).field_name;
	  l_sort_data(i).asc_dsc_flag := p_sort_data(i).asc_dsc_flag;
	END LOOP;

	l_start_pointer := p_request_rec.start_record_position;
	l_rec_wanted := p_request_rec.records_requested;

	IF p_request_rec.records_requested = FND_API.G_MISS_NUM THEN
	  l_show_all := 'Y'; --FND_API.G_TRUE;
	END IF;

	JTF_TASK_TEMP_GROUP_PUB.GET_TASK_TEMPLATE_GROUP
 	(
		P_API_VERSION => p_api_version,
		P_INIT_MSG_LIST => FND_API.G_FALSE,
		P_COMMIT => FND_API.G_FALSE,
		P_VALIDATE_LEVEL => p_validation_level,
 		P_TASK_TEMPLATE_GROUP_ID => p_task_template_group_id,
 		P_TEMPLATE_GROUP_NAME => p_template_group_name,
 		P_SOURCE_OBJECT_TYPE_CODE => p_source_object_type_code,
 		P_START_DATE_ACTIVE => p_start_date_active,
 		P_END_DATE_ACTIVE => p_end_date_active,
 		P_SORT_DATA => l_sort_data,
 		P_QUERY_OR_NEXT_CODE  => l_query_or_next_code,
 		P_START_POINTER => l_start_pointer,
 		P_REC_WANTED => l_rec_wanted,
 		P_SHOW_ALL => l_show_all,
		X_RETURN_STATUS => x_return_status,
		X_MSG_COUNT => x_msg_count,
  		X_MSG_DATA => x_msg_data,
 		X_TASK_TEMPLATE_GROUP => l_template_group,
 		X_TOTAL_RETRIEVED => x_return_rec.total_record_count,
 		X_TOTAL_RETURNED => x_return_rec.returned_record_count
 	);
	x_return_rec.next_record_position :=
		l_start_pointer + x_return_rec.returned_record_count;
	x_task_group := task_group_tbl_type();
	FOR i in 1..l_template_group.count LOOP
	  x_task_group.extend;
          OPEN c_reason_type(l_template_group(i).task_template_group_id);
            FETCH c_reason_type INTO l_reason_type;
              IF c_reason_type%NOTFOUND THEN
                CLOSE c_reason_type;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.set_name('OZF','OZF_API_RECORD_NOT_FOUND');
                  FND_MSG_PUB.add;
                END IF;
                RAISE FND_API.g_exc_error;
              END IF;
          CLOSE c_reason_type;
	  x_task_group(i).task_template_group_id := l_template_group(i).task_template_group_id;
	  x_task_group(i).start_date_active := l_template_group(i).start_date_active;
	  x_task_group(i).end_date_active := l_template_group(i).end_date_active;
	  x_task_group(i).source_object_type_code :=
			l_template_group(i).source_object_type_code;
	  x_task_group(i).object_version_number :=
			l_template_group(i).object_version_number;
	  x_task_group(i).attribute_category :=
			l_template_group(i).attribute_category;
	  x_task_group(i).attribute1 := l_template_group(i).attribute1;
	  x_task_group(i).attribute2 := l_template_group(i).attribute2;
	  x_task_group(i).attribute3 := l_template_group(i).attribute3;
	  x_task_group(i).attribute4 := l_template_group(i).attribute4;
	  x_task_group(i).attribute5 := l_template_group(i).attribute5;
	  x_task_group(i).attribute6 := l_template_group(i).attribute6;
	  x_task_group(i).attribute7 := l_template_group(i).attribute7;
	  x_task_group(i).attribute8 := l_template_group(i).attribute8;
	  x_task_group(i).attribute9 := l_template_group(i).attribute9;
	  x_task_group(i).attribute10 := l_template_group(i).attribute10;
	  x_task_group(i).attribute11 := l_template_group(i).attribute11;
	  x_task_group(i).attribute12 := l_template_group(i).attribute12;
	  x_task_group(i).attribute13 := l_template_group(i).attribute13;
	  x_task_group(i).attribute14 := l_template_group(i).attribute14;
	  x_task_group(i).attribute15 := l_template_group(i).attribute15;
	  x_task_group(i).reason_type := l_reason_type;
	  x_task_group(i).template_group_name := l_template_group(i).template_group_name;
	  x_task_group(i).description := l_template_group(i).description;
	END LOOP;


	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
		FND_MSG_PUB.Add;
	END IF;
	--Standard call to get message count and if count=1, get the message
	FND_MSG_PUB.Count_And_Get (
		p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data  => x_msg_data
	);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO  Get_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Get_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Get_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
--
END Get_task_group;
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_task_group
--
-- PURPOSE
--    Validate a task_group code record.
--
-- PARAMETERS
--    p_task_group : the task_group code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_task_group (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,p_task_group        	    IN  task_group_rec_type
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_task_group';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status varchar2(30);
l_Error_Msg         varchar2(2000);
l_Error_Token       varchar2(80);
l_object_version_number  number := 1;
l_return_status     VARCHAR2(1);
--
l_task_group	task_group_rec_type := p_task_group;
BEGIN
	-- Standard begin of API savepoint
	SAVEPOINT  Validate_task_group_PVT;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
		FND_MSG_PUB.Add;
	END IF;
	--Initialize message list if p_init_msg_list is TRUE.
	IF FND_API.To_Boolean (p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;
	-- Initialize API return status to sucess
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
		Check_task_group_Items(
			p_task_group_rec        => p_task_group,
			p_validation_mode   => JTF_PLSQL_API.g_update,
			x_return_status     => l_return_status
		);

  		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
  		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;
/*
        Complete_task_group_Rec(
                p_task_group_rec        => p_task_group,
                x_complete_rec      => l_task_group
        );

	IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
		Check_task_group_Record(
			p_task_group_rec     => p_task_group,
			p_complete_rec   => l_task_group,
			x_return_status  => l_return_status
		);

  		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
  		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;
*/
	-- Debug Message
	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
		FND_MSG_PUB.Add;
	END IF;
	--Standard call to get message count and if count=1, get the message
	FND_MSG_PUB.Count_And_Get (
		p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data  => x_msg_data
	);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO  Validate_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Validate_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Validate_task_group_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
--
END Validate_task_group;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Req_Items
--
-- HISTORY
--    04/18/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_task_group_Req_Items(
   p_task_group_rec       IN  task_group_rec_type
  ,x_return_status    OUT NOCOPY VARCHAR2
)
IS
   l_source_object       VARCHAR2(30);
   l_start_date		    DATE;
   l_task_group_name     VARCHAR2(80);
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_start_date := p_task_group_rec.start_date_active;
   l_source_object := p_task_group_rec.source_object_type_code;
   l_task_group_name := p_task_group_rec.template_group_name;

   -- Check for null source object
   IF( (l_source_object IS NULL)
   OR (l_source_object = FND_API.G_MISS_CHAR) )
   THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_ACTION_NULL_SOURCEOBJ');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check for null task group name
   IF( (l_task_group_name IS NULL)
   OR (l_task_group_name = FND_API.G_MISS_CHAR) )
   THEN
	   FND_MESSAGE.Set_Name('OZF', 'OZF_ACTION_NULL_TASK_GROUPNAME');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check for null start date
   IF( (l_start_date IS NULL)
	OR (l_start_date = FND_API.G_MISS_DATE) )
   THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_ACTION_NULL_STDATE');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

END Check_task_group_Req_Items;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Uk_Items
--
-- HISTORY
--    04/18/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_task_group_Uk_Items(
   p_task_group_rec        IN  task_group_rec_type
  ,p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

END Check_task_group_Uk_Items;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Fk_Items
--
-- HISTORY
--    04/18/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_task_group_Fk_Items(
   p_task_group_rec        IN  task_group_rec_type
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- check other fk items

END Check_task_group_Fk_Items;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Lookup_Items
--
-- HISTORY
--    04/18/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_task_group_Lookup_Items(
   p_task_group_rec        IN  task_group_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- check other lookup codes

END Check_task_group_Lookup_Items;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Flag_Items
--
-- HISTORY
--    04/18/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_task_group_Flag_Items(
   p_task_group_rec        IN  task_group_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
END Check_task_group_Flag_Items;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, , flag items, domain constraints.
--
-- PARAMETERS
--    p_task_group_rec      : the record to be validated
---------------------------------------------------------------------
PROCEDURE Check_task_group_Items(
   p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,p_task_group_rec        IN  task_group_rec_type
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Check_task_group_Items';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status      varchar2(30);
l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);
l_object_version_number  number := 1;
--
BEGIN
   --
   Check_task_group_Req_Items(
      p_task_group_rec       => p_task_group_rec
     ,x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_task_group_Uk_Items(
      p_task_group_rec       => p_task_group_rec
     ,p_validation_mode  => p_validation_mode
     ,x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_task_group_Fk_Items(
      p_task_group_rec       => p_task_group_rec
     ,x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_task_group_Lookup_Items(
      p_task_group_rec       => p_task_group_rec
     ,x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_task_group_Flag_Items(
      p_task_group_rec       => p_task_group_rec
     ,x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   --
END Check_task_group_Items;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_task_group_rec  : the record to be validated; may contain attributes
--                    as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items have
--                    been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_task_group_Record(
   p_task_group_rec        IN   task_group_rec_type
  ,p_complete_rec      IN   task_group_rec_type := NULL
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Check_task_group_Record';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status      varchar2(30);
l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);
l_object_version_number  number := 1;
--
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

--
END Check_task_group_Record;
---------------------------------------------------------------------
-- PROCEDURE
--    Init_task_group_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_task_group_Rec (
   x_task_group_rec        OUT NOCOPY task_group_rec_type
)
IS
BEGIN
 --
 --
   RETURN;
END Init_task_group_Rec;
---------------------------------------------------------------------
-- PROCEDURE
--    Complete_task_group_Rec
--
-- PURPOSE
--    For Update_task_group, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--	 must pass task_template_group_id
-- PARAMETERS
--    p_task_group_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_task_group_Rec (
   p_task_group_rec        IN   task_group_rec_type
  ,x_complete_rec      OUT NOCOPY task_group_rec_type
)
IS

CURSOR c_task_group (cv_task_template_group_id NUMBER) IS
SELECT * FROM JTF_TASK_TEMP_GROUPS_VL
WHERE TASK_TEMPLATE_GROUP_ID = cv_task_template_group_id;

l_task_group_rec    c_task_group%ROWTYPE;

BEGIN

  x_complete_rec  := p_task_group_rec;

  OPEN c_task_group(p_task_group_rec.task_template_group_id);
  FETCH c_task_group INTO l_task_group_rec;
  IF c_task_group%NOTFOUND THEN
        CLOSE c_task_group;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('OZF','OZF_API_RECORD_NOT_FOUND');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_task_group;

  IF p_task_group_rec.start_date_active         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.start_date_active       := NULL;
  END IF;
  IF p_task_group_rec.start_date_active         IS NULL THEN
     x_complete_rec.start_date_active       := l_task_group_rec.start_date_active;
  END IF;

  IF p_task_group_rec.end_date_active    	    = FND_API.G_MISS_DATE  THEN
     x_complete_rec.end_date_active         := NULL;
  END IF;
  IF p_task_group_rec.end_date_active    	    IS NULL THEN
     x_complete_rec.end_date_active         := l_task_group_rec.end_date_active;
  END IF;

  IF p_task_group_rec.source_object_type_code   = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.source_object_type_code := NULL;
  END IF;
  IF p_task_group_rec.source_object_type_code   IS NULL THEN
     x_complete_rec.source_object_type_code := l_task_group_rec.source_object_type_code;
  END IF;
  IF p_task_group_rec.object_version_number     = FND_API.G_MISS_NUM  THEN
     x_complete_rec.object_version_number   := NULL;
  END IF;
  IF p_task_group_rec.object_version_number     IS NULL THEN
     x_complete_rec.object_version_number   := l_task_group_rec.object_version_number;
  END IF;
  IF p_task_group_rec.attribute_category        = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute_category      := NULL;
  END IF;
  IF p_task_group_rec.attribute_category        IS NULL THEN
     x_complete_rec.attribute_category      := l_task_group_rec.attribute_category;
  END IF;
  IF p_task_group_rec.attribute1                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute1              := NULL;
  END IF;
  IF p_task_group_rec.attribute1                IS NULL THEN
     x_complete_rec.attribute1              := l_task_group_rec.attribute1;
  END IF;
  IF p_task_group_rec.attribute2                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute2              := NULL;
  END IF;
  IF p_task_group_rec.attribute2                IS NULL THEN
     x_complete_rec.attribute2              := l_task_group_rec.attribute2;
  END IF;
  IF p_task_group_rec.attribute3                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute3              := NULL;
  END IF;
  IF p_task_group_rec.attribute3                IS NULL THEN
     x_complete_rec.attribute3              := l_task_group_rec.attribute3;
  END IF;
  IF p_task_group_rec.attribute4                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute4              := NULL;
  END IF;
  IF p_task_group_rec.attribute4                IS NULL THEN
     x_complete_rec.attribute4              := l_task_group_rec.attribute4;
  END IF;
  IF p_task_group_rec.attribute5                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute5              := NULL;
  END IF;
  IF p_task_group_rec.attribute5                IS NULL THEN
     x_complete_rec.attribute5              := l_task_group_rec.attribute5;
  END IF;
  IF p_task_group_rec.attribute6                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute6              := NULL;
  END IF;
  IF p_task_group_rec.attribute6                IS NULL THEN
     x_complete_rec.attribute6              := l_task_group_rec.attribute6;
  END IF;
  IF p_task_group_rec.attribute7                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute7              := NULL;
  END IF;
  IF p_task_group_rec.attribute7                IS NULL THEN
     x_complete_rec.attribute7              := l_task_group_rec.attribute7;
  END IF;
  IF p_task_group_rec.attribute8                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute8              := NULL;
  END IF;
  IF p_task_group_rec.attribute8                IS NULL THEN
     x_complete_rec.attribute8              := l_task_group_rec.attribute8;
  END IF;
  IF p_task_group_rec.attribute9                = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute9              := NULL;
  END IF;
  IF p_task_group_rec.attribute9                IS NULL THEN
     x_complete_rec.attribute9              := l_task_group_rec.attribute9;
  END IF;
  IF p_task_group_rec.attribute10               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute10             := NULL;
  END IF;
  IF p_task_group_rec.attribute10               IS NULL THEN
     x_complete_rec.attribute10             := l_task_group_rec.attribute10;
  END IF;
  IF p_task_group_rec.attribute11               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute11             := NULL;
  END IF;
  IF p_task_group_rec.attribute11               IS NULL THEN
     x_complete_rec.attribute11             := l_task_group_rec.attribute11;
  END IF;
  IF p_task_group_rec.attribute12               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute12             := NULL;
  END IF;
  IF p_task_group_rec.attribute12               IS NULL THEN
     x_complete_rec.attribute12             := l_task_group_rec.attribute12;
  END IF;
  IF p_task_group_rec.attribute13               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute13             := NULL;
  END IF;
  IF p_task_group_rec.attribute13               IS NULL THEN
     x_complete_rec.attribute13             := l_task_group_rec.attribute13;
  END IF;
  IF p_task_group_rec.attribute14               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute14             := NULL;
  END IF;
  IF p_task_group_rec.attribute14               IS NULL THEN
     x_complete_rec.attribute14             := l_task_group_rec.attribute14;
  END IF;
  IF p_task_group_rec.attribute15               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute15             := NULL;
  END IF;
  IF p_task_group_rec.attribute15               IS NULL THEN
     x_complete_rec.attribute15             := l_task_group_rec.attribute15;
  END IF;
  /*
  IF p_task_group_rec.reason_type               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.reason_type             := NULL;
  END IF;
  IF p_task_group_rec.reason_type               IS NULL THEN
     x_complete_rec.reason_type             := l_task_group_rec.reason_type;
  END IF;
  */
  IF p_task_group_rec.template_group_name               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.template_group_name             := NULL;
  END IF;
  IF p_task_group_rec.template_group_name               IS NULL THEN
     x_complete_rec.template_group_name             := l_task_group_rec.template_group_name;
  END IF;
  IF p_task_group_rec.description               = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.description             := NULL;
  END IF;
  IF p_task_group_rec.description               IS NULL THEN
     x_complete_rec.description             := l_task_group_rec.description;
  END IF;
END Complete_task_group_Rec;

END OZF_TASK_GROUP_PVT;

/
