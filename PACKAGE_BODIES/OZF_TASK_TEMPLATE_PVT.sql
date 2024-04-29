--------------------------------------------------------
--  DDL for Package Body OZF_TASK_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TASK_TEMPLATE_PVT" AS
/* $Header: ozfvtteb.pls 115.2 2003/11/19 08:24:38 upoluri noship $ */
--

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OZF_TASK_TEMPLATE_PVT';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'ozfvtteb.pls';


---------------------------------------------------------------------
-- PROCEDURE
--    Create_TaskTemplate
--
-- PURPOSE
--    Create a task  template.
--
-- PARAMETERS
--    p_insert_reason   : the new record to be inserted
--    x_reason_code_id  : return the reason_code_id of the new reason code
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE  Create_TaskTemplate (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_task_template          IN    ozf_task_template_tbl_type
   ,x_task_template_id       OUT   NOCOPY ozf_number_tbl_type
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_TaskTemplate';
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
	-- Standard begin of API savepoint
	SAVEPOINT  Create_TaskTemplate_PVT;
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

	x_task_template_id := ozf_number_tbl_type();
 	BEGIN
	  FOR i in 1..p_task_template.count LOOP
	    x_task_template_id.extend;
	    JTF_TASK_TEMPLATES_PUB.CREATE_TASK
	    (
		P_API_VERSION => p_api_version,
		P_INIT_MSG_LIST => FND_API.G_FALSE,
		P_COMMIT => FND_API.G_FALSE,
		P_TASK_GROUP_ID => p_task_template(i).reason_code_id,
		P_TASK_NAME => p_task_template(i).task_name,
		P_TASK_TYPE_ID => p_task_template(i).task_type_id,
		P_DESCRIPTION => p_task_template(i).description,
		P_TASK_STATUS_ID => p_task_template(i).task_status_id,
		P_TASK_PRIORITY_ID => p_task_template(i).task_priority_id,
		P_DURATION => p_task_template(i).duration,
		P_DURATION_UOM => p_task_template(i).duration_uom,
		X_RETURN_STATUS => x_return_status,
		X_MSG_COUNT => x_msg_count,
  		X_MSG_DATA => x_msg_data,
		X_TASK_ID => x_task_template_id(i)
	    );
	    -- CHECK to see if we require this flag
      	    --p_multi_booked_flag         IN       VARCHAR2 DEFAULT NULL,
	  END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

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
		ROLLBACK TO  Create_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Create_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Create_TaskTemplate_PVT;
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
END Create_TaskTemplate;
---------------------------------------------------------------------
-- PROCEDURE
--    Update_TaskTemplate
--
-- PURPOSE
--    Update task template.
--
-- PARAMETERS
--    p_task_template   : the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE  Update_TaskTemplate (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT  NOCOPY VARCHAR2
   ,x_msg_data               OUT  NOCOPY VARCHAR2
   ,x_msg_count              OUT  NOCOPY NUMBER

   ,p_task_template          IN    ozf_task_template_tbl_type
   ,x_object_version_number  OUT  NOCOPY ozf_number_tbl_type
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Update_TaskTemplate';
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
	-- Standard begin of API savepoint
	SAVEPOINT  Update_TaskTemplate_PVT;
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

 	BEGIN
	  x_object_version_number := ozf_number_tbl_type();
	  FOR i in 1..p_task_template.count LOOP
	    x_object_version_number.extend;
	    x_object_version_number(i) := p_task_template(i).object_version_number;
	    JTF_TASK_TEMPLATES_PUB.UPDATE_TASK
	    (
		P_API_VERSION => p_api_version,
		P_INIT_MSG_LIST => FND_API.G_FALSE,
		P_COMMIT => FND_API.G_FALSE,
		P_OBJECT_VERSION_NUMBER => x_object_version_number(i),
		P_TASK_ID => p_task_template(i).task_template_id,
		P_TASK_NUMBER => p_task_template(i).task_number,
		P_TASK_GROUP_ID => p_task_template(i).reason_code_id,
		P_TASK_NAME => p_task_template(i).task_name,
		P_TASK_TYPE_ID => p_task_template(i).task_type_id,
		P_DESCRIPTION => p_task_template(i).description,
		P_TASK_STATUS_ID => p_task_template(i).task_status_id,
		P_TASK_PRIORITY_ID => p_task_template(i).task_priority_id,
		P_DURATION => p_task_template(i).duration,
		P_DURATION_UOM => p_task_template(i).duration_uom,
		X_RETURN_STATUS => x_return_status,
		X_MSG_COUNT => x_msg_count,
  		X_MSG_DATA => x_msg_data
	    );
	  END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

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
		ROLLBACK TO  Update_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Update_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Update_TaskTemplate_PVT;
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
END Update_TaskTemplate;
---------------------------------------------------------------------
-- PROCEDURE
--    Delete_TaskTemplate
--
-- PURPOSE
--    Delete a task template.
--
-- PARAMETERS
--    p_task_template_id   :  template to be deleted
--    p_object_version_number   : object version number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
----------------------------------------------------------------------
PROCEDURE  Delete_TaskTemplate (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER

   ,p_task_template_id       IN    ozf_number_tbl_type
   ,p_object_version_number  IN    ozf_number_tbl_type
   )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Delete_TaskTemplate';
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
	-- Standard begin of API savepoint
	SAVEPOINT  Delete_TaskTemplate_PVT;
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

	IF p_task_template_id.count <> p_object_version_number.count THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 	FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_INCONSISTANT_TASK_RECORDS');
	 	FND_MSG_PUB.Add;
	  END IF;
	END IF;

 	BEGIN
	  FOR i in 1..p_task_template_id.count LOOP
	    JTF_TASK_TEMPLATES_PUB.DELETE_TASK
	    (
		P_API_VERSION => p_api_version,
		P_INIT_MSG_LIST => FND_API.G_FALSE,
		P_COMMIT => FND_API.G_FALSE,
		P_OBJECT_VERSION_NUMBER => p_object_version_number(i),
		P_TASK_ID => p_task_template_id(i),
		X_RETURN_STATUS => x_return_status,
		X_MSG_COUNT => x_msg_count,
  		X_MSG_DATA => x_msg_data
	    );
	    --P_TASK_NUMBER => p_task_number,
	  END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

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
		ROLLBACK TO  Delete_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Delete_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Delete_TaskTemplate_PVT;
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
END Delete_TaskTemplate;
---------------------------------------------------------------------
-- PROCEDURE
--    Get_TaskTemplate
--
-- PURPOSE
--    Get task template.
--
-- PARAMETERS
--    p_task_group_id   :  template to be deleted
--
-- NOTES
--    1. Raise exception if the task group id doesn't exist.
----------------------------------------------------------------------
PROCEDURE  Get_TaskTemplate (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER

   ,p_reason_code_id         IN    NUMBER
   ,x_task_template  	     OUT NOCOPY ozf_task_template_tbl_type
   )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Get_TaskTemplate';
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
l_rec_count 	number := 1;

CURSOR c_tasks (cv_task_group_id NUMBER) IS
SELECT  JTT.TASK_TEMPLATE_ID
, 	JTT.TASK_NAME
, 	JTT.DESCRIPTION
, 	JTT.TASK_GROUP_ID
,	JTG.TEMPLATE_GROUP_NAME
, 	JTT.TASK_NUMBER
, 	JTT.TASK_TYPE_ID
,	JTY.NAME
, 	JTT.TASK_STATUS_ID
,	JTS.NAME
, 	JTT.TASK_PRIORITY_ID
,	JTP.NAME
, 	JTT.DURATION
, 	JTT.DURATION_UOM
, 	JTT.OBJECT_VERSION_NUMBER
, 	JTT.ATTRIBUTE_CATEGORY
, 	JTT.ATTRIBUTE1
, 	JTT.ATTRIBUTE2
, 	JTT.ATTRIBUTE3
, 	JTT.ATTRIBUTE4
, 	JTT.ATTRIBUTE5
, 	JTT.ATTRIBUTE6
, 	JTT.ATTRIBUTE7
, 	JTT.ATTRIBUTE8
, 	JTT.ATTRIBUTE9
, 	JTT.ATTRIBUTE10
, 	JTT.ATTRIBUTE11
, 	JTT.ATTRIBUTE12
, 	JTT.ATTRIBUTE13
, 	JTT.ATTRIBUTE14
, 	JTT.ATTRIBUTE15
FROM 	JTF_TASK_TEMPLATES_VL JTT
,	JTF_TASK_TEMP_GROUPS_VL JTG
,	JTF_TASK_TYPES_VL JTY
,	JTF_TASK_STATUSES_VL JTS
,	JTF_TASK_PRIORITIES_VL JTP
WHERE	JTT.TASK_GROUP_ID = cv_task_group_id
AND	JTT.TASK_GROUP_ID = JTG.TASK_TEMPLATE_GROUP_ID
AND	JTT.TASK_TYPE_ID = JTY.TASK_TYPE_ID
AND	JTT.TASK_STATUS_ID = JTS.TASK_STATUS_ID
AND	JTT.TASK_PRIORITY_ID = JTP.TASK_PRIORITY_ID;

BEGIN
	-- Standard begin of API savepoint
	SAVEPOINT  Get_TaskTemplate_PVT;
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

	x_task_template := ozf_task_template_tbl_type();
	OPEN c_tasks(p_reason_code_id);
	  LOOP
		x_task_template.extend;
	  	FETCH c_tasks INTO x_task_template(l_rec_count);
		EXIT WHEN c_tasks%NOTFOUND;
		l_rec_count := l_rec_count + 1;
	  END LOOP;
	CLOSE c_tasks;

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
		ROLLBACK TO  Get_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Get_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Get_TaskTemplate_PVT;
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
END Get_TaskTemplate;
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_TaskTemplate
--
-- PURPOSE
--    Validate a reason code record.
--
-- PARAMETERS
--    p_validate_reason : the reason code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_TaskTemplate (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,p_task_template          IN  ozf_task_template_rec_type
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_TaskTemplate';
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
l_task_template	ozf_task_template_rec_type := p_task_template;
BEGIN
	-- Standard begin of API savepoint
	SAVEPOINT  Validate_TaskTemplate_PVT;
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
		Check_TaskTemplate_Items(
			p_task_template_rec => p_task_template,
			p_validation_mode   => JTF_PLSQL_API.g_update,
			x_return_status     => l_return_status
		);

  		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
  		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

        Complete_TaskTemplate_Rec(
                p_task_template_rec => p_task_template,
                x_complete_rec      => l_task_template
        );

	IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
		Check_TaskTemplate_Record(
			p_task_template_rec => p_task_template,
			p_complete_rec   => l_task_template,
			x_return_status  => l_return_status
		);

  		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
  		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
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
		ROLLBACK TO  Validate_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  Validate_TaskTemplate_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO  Validate_TaskTemplate_PVT;
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
END Validate_TaskTemplate;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_TaskTemplate_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, , flag items, domain constraints.
--
-- PARAMETERS
--    p_task_template_rec      : the record to be validated
---------------------------------------------------------------------
PROCEDURE Check_TaskTemplate_Items(
   p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,p_task_template_rec IN  ozf_task_template_rec_type
)
IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_TaskTemplate_Record
--
-- PURPOSE
--    Check the task template level business rules.
--
-- PARAMETERS
--    p_task_template_rec  : the record to be validated; may contain attributes
--                    as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items have
--                    been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_TaskTemplate_Record(
   p_task_template_rec IN   ozf_task_template_rec_type
  ,p_complete_rec      IN   ozf_task_template_rec_type := NULL
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END;
---------------------------------------------------------------------
-- PROCEDURE
--    Init_TaskTemplate_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Reason_Rec (
   x_task_template_rec      OUT  NOCOPY ozf_task_template_rec_type
)
IS
BEGIN
 --
   RETURN;
END;
---------------------------------------------------------------------
-- PROCEDURE
--    Complete_TaskTemplate_Rec
--
-- PURPOSE
--    For Update_Reason, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_task_template_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_TaskTemplate_Rec (
   p_task_template_rec IN   ozf_task_template_rec_type
  ,x_complete_rec      OUT NOCOPY ozf_task_template_rec_type
)
IS

l_task_template_rec    ozf_task_template_rec_type;

CURSOR c_task_template (cv_task_template_id NUMBER) IS
SELECT  JTT.TASK_TEMPLATE_ID
,       JTT.TASK_NAME
,       JTT.DESCRIPTION
,       JTT.TASK_GROUP_ID
,       JTG.TEMPLATE_GROUP_NAME
,       JTT.TASK_NUMBER
,       JTT.TASK_TYPE_ID
,       JTY.NAME
,       JTT.TASK_STATUS_ID
,       JTS.NAME
,       JTT.TASK_PRIORITY_ID
,       JTP.NAME
,       JTT.DURATION
,       JTT.DURATION_UOM
,       JTT.OBJECT_VERSION_NUMBER
,       JTT.ATTRIBUTE_CATEGORY
,       JTT.ATTRIBUTE1
,       JTT.ATTRIBUTE2
,       JTT.ATTRIBUTE3
,       JTT.ATTRIBUTE4
,       JTT.ATTRIBUTE5
,       JTT.ATTRIBUTE6
,       JTT.ATTRIBUTE7
,       JTT.ATTRIBUTE8
,       JTT.ATTRIBUTE9
,       JTT.ATTRIBUTE10
,       JTT.ATTRIBUTE11
,       JTT.ATTRIBUTE12
,       JTT.ATTRIBUTE13
,       JTT.ATTRIBUTE14
,       JTT.ATTRIBUTE15
FROM    JTF_TASK_TEMPLATES_VL JTT
,       JTF_TASK_TEMP_GROUPS_VL JTG
,       JTF_TASK_TYPES_VL JTY
,       JTF_TASK_STATUSES_VL JTS
,       JTF_TASK_PRIORITIES_VL JTP
WHERE   JTT.TASK_TEMPLATE_ID = cv_task_template_id
AND     JTT.TASK_GROUP_ID = JTG.TASK_TEMPLATE_GROUP_ID
AND     JTT.TASK_TYPE_ID = JTY.TASK_TYPE_ID
AND     JTT.TASK_STATUS_ID = JTS.TASK_STATUS_ID
AND     JTT.TASK_PRIORITY_ID = JTP.TASK_PRIORITY_ID;

BEGIN

  x_complete_rec  := p_task_template_rec;

  OPEN c_task_template(p_task_template_rec.task_template_id);
  FETCH c_task_template INTO l_task_template_rec;
  IF c_task_template%NOTFOUND THEN
        CLOSE c_task_template;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('OZF','OZF_API_RECORD_NOT_FOUND');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_task_template;

  IF p_task_template_rec.task_name 	= FND_API.G_MISS_CHAR  THEN
     x_complete_rec.task_name   	:= NULL;
  END IF;
  IF p_task_template_rec.task_name 	IS NULL THEN
     x_complete_rec.task_name   	:= l_task_template_rec.task_name;
  END IF;
  IF p_task_template_rec.description    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.description     	:= NULL;
  END IF;
  IF p_task_template_rec.description    IS NULL THEN
     x_complete_rec.description     	:= l_task_template_rec.description;
  END IF;
  IF p_task_template_rec.reason_code_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.reason_code_id      := NULL;
  END IF;
  IF p_task_template_rec.reason_code_id IS NULL THEN
     x_complete_rec.reason_code_id      := l_task_template_rec.reason_code_id;
  END IF;
  IF p_task_template_rec.reason_code    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.reason_code         := NULL;
  END IF;
  IF p_task_template_rec.reason_code    IS NULL THEN
     x_complete_rec.reason_code         := l_task_template_rec.reason_code;
  END IF;
  IF p_task_template_rec.task_number    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.task_number       	:= NULL;
  END IF;
  IF p_task_template_rec.task_number    IS NULL THEN
     x_complete_rec.task_number       	:= l_task_template_rec.task_number;
  END IF;
  IF p_task_template_rec.task_type_id   = FND_API.G_MISS_NUM  THEN
     x_complete_rec.task_type_id       	:= NULL;
  END IF;
  IF p_task_template_rec.task_type_id   IS NULL THEN
     x_complete_rec.task_type_id       	:= l_task_template_rec.task_type_id;
  END IF;
  IF p_task_template_rec.task_type_name = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.task_type_name    	:= NULL;
  END IF;
  IF p_task_template_rec.task_type_name IS NULL THEN
     x_complete_rec.task_type_name    	:= l_task_template_rec.task_type_name;
  END IF;
  IF p_task_template_rec.task_status_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.task_status_id      := NULL;
  END IF;
  IF p_task_template_rec.task_status_id IS NULL THEN
     x_complete_rec.task_status_id      := l_task_template_rec.task_status_id;
  END IF;
  IF p_task_template_rec.task_status_name = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.task_status_name  	:= NULL;
  END IF;
  IF p_task_template_rec.task_status_name IS NULL THEN
     x_complete_rec.task_status_name  	:= l_task_template_rec.task_status_name;
  END IF;
  IF p_task_template_rec.task_priority_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.task_priority_id     := NULL;
  END IF;
  IF p_task_template_rec.task_priority_id IS NULL THEN
     x_complete_rec.task_priority_id     := l_task_template_rec.task_priority_id;
  END IF;
  IF p_task_template_rec.task_priority_name = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.task_priority_name 	:= NULL;
  END IF;
  IF p_task_template_rec.task_priority_name IS NULL THEN
     x_complete_rec.task_priority_name 	:= l_task_template_rec.task_priority_name;
  END IF;
  IF p_task_template_rec.object_version_number  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.object_version_number := NULL;
  END IF;
  IF p_task_template_rec.object_version_number  IS NULL THEN
     x_complete_rec.object_version_number := l_task_template_rec.object_version_number;
  END IF;
  IF p_task_template_rec.attribute_category     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute_category  := NULL;
  END IF;
  IF p_task_template_rec.attribute_category     IS NULL THEN
     x_complete_rec.attribute_category  := l_task_template_rec.attribute_category;
  END IF;
  IF p_task_template_rec.attribute1     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute1          := NULL;
  END IF;
  IF p_task_template_rec.attribute1     IS NULL THEN
     x_complete_rec.attribute1          := l_task_template_rec.attribute1;
  END IF;
  IF p_task_template_rec.attribute2     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute2          := NULL;
  END IF;
  IF p_task_template_rec.attribute2     IS NULL THEN
     x_complete_rec.attribute2          := l_task_template_rec.attribute2;
  END IF;
  IF p_task_template_rec.attribute3     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute3          := NULL;
  END IF;
  IF p_task_template_rec.attribute3     IS NULL THEN
     x_complete_rec.attribute3          := l_task_template_rec.attribute3;
  END IF;
  IF p_task_template_rec.attribute4     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute4          := NULL;
  END IF;
  IF p_task_template_rec.attribute4     IS NULL THEN
     x_complete_rec.attribute4          := l_task_template_rec.attribute4;
  END IF;
  IF p_task_template_rec.attribute5     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute5          := NULL;
  END IF;
  IF p_task_template_rec.attribute5     IS NULL THEN
     x_complete_rec.attribute5          := l_task_template_rec.attribute5;
  END IF;
  IF p_task_template_rec.attribute6     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute6          := NULL;
  END IF;
  IF p_task_template_rec.attribute6     IS NULL THEN
     x_complete_rec.attribute6          := l_task_template_rec.attribute6;
  END IF;
  IF p_task_template_rec.attribute7     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute7          := NULL;
  END IF;
  IF p_task_template_rec.attribute7     IS NULL THEN
     x_complete_rec.attribute7          := l_task_template_rec.attribute7;
  END IF;
  IF p_task_template_rec.attribute8     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute8          := NULL;
  END IF;
  IF p_task_template_rec.attribute8     IS NULL THEN
     x_complete_rec.attribute8          := l_task_template_rec.attribute8;
  END IF;
  IF p_task_template_rec.attribute9     = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute9          := NULL;
  END IF;
  IF p_task_template_rec.attribute9     IS NULL THEN
     x_complete_rec.attribute9          := l_task_template_rec.attribute9;
  END IF;
  IF p_task_template_rec.attribute10    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute10         := NULL;
  END IF;
  IF p_task_template_rec.attribute10    IS NULL THEN
     x_complete_rec.attribute10         := l_task_template_rec.attribute10;
  END IF;
  IF p_task_template_rec.attribute11    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute11         := NULL;
  END IF;
  IF p_task_template_rec.attribute11    IS NULL THEN
     x_complete_rec.attribute11         := l_task_template_rec.attribute11;
  END IF;
  IF p_task_template_rec.attribute12    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute12         := NULL;
  END IF;
  IF p_task_template_rec.attribute12    IS NULL THEN
     x_complete_rec.attribute12         := l_task_template_rec.attribute12;
  END IF;
  IF p_task_template_rec.attribute13    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute13         := NULL;
  END IF;
  IF p_task_template_rec.attribute13    IS NULL THEN
     x_complete_rec.attribute13         := l_task_template_rec.attribute13;
  END IF;
  IF p_task_template_rec.attribute14    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute14         := NULL;
  END IF;
  IF p_task_template_rec.attribute14    IS NULL THEN
     x_complete_rec.attribute14         := l_task_template_rec.attribute14;
  END IF;
  IF p_task_template_rec.attribute15    = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute15         := NULL;
  END IF;
  IF p_task_template_rec.attribute15    IS NULL THEN
     x_complete_rec.attribute15         := l_task_template_rec.attribute15;
  END IF;
  --
END Complete_TaskTemplate_Rec;


END OZF_TASK_TEMPLATE_PVT;


/
