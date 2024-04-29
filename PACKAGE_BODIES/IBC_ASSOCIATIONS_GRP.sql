--------------------------------------------------------
--  DDL for Package Body IBC_ASSOCIATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_ASSOCIATIONS_GRP" AS
/* $Header: ibcgassb.pls 115.15 2003/11/20 00:22:03 vicho ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBC_ASSOCIATIONS_GRP';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ibcgassb.pls';

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Create_Association
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Create an association mapping between an External object
--                 and a content item (optionally, a particular version).
--------------------------------------------------------------------------------
PROCEDURE Create_Association (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_commit			IN	VARCHAR2,
	p_assoc_type_code		IN	VARCHAR2,
	p_assoc_object1			IN	VARCHAR2,
	p_assoc_object2			IN	VARCHAR2,
	p_assoc_object3			IN	VARCHAR2,
	p_assoc_object4			IN	VARCHAR2,
	p_assoc_object5			IN	VARCHAR2,
	p_content_item_id		IN	NUMBER,
        p_citem_version_id              IN      NUMBER,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30) := 'Create_Association';
	l_api_version		CONSTANT NUMBER := 1.0;
	l_row_id		VARCHAR2(250);
--
	l_assoc_id			NUMBER;
--
	CURSOR Check_Duplicate_CItem IS
        SELECT association_id
	FROM IBC_ASSOCIATIONS
	WHERE association_type_code = p_assoc_type_code
        AND associated_object_val1 = p_assoc_object1
        AND NVL(associated_object_val2, '0') = NVL(p_assoc_object2, '0')
        AND NVL(associated_object_val3, '0') = NVL(p_assoc_object3, '0')
        AND NVL(associated_object_val4, '0') = NVL(p_assoc_object4, '0')
        AND NVL(associated_object_val5, '0') = NVL(p_assoc_object5, '0')
	AND content_item_id = p_content_item_id
	AND NVL(citem_version_id, '0') = NVL(p_citem_version_id, '0');

BEGIN
      -- ******************* Standard Begins *******************
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ASSOCIATIONS_PT;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
      THEN
           RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
          Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

       -- Check for Duplicates
       OPEN Check_Duplicate_CItem;
	    FETCH Check_Duplicate_CItem INTO l_assoc_id;
	    IF (Check_Duplicate_CItem%FOUND) THEN
	       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	          Fnd_Message.Set_Name('IBC', 'DUPLICATE_ASSOCIATION');
	          Fnd_Msg_Pub.ADD;
	       END IF;
	       CLOSE Check_Duplicate_CItem;
	       RAISE Fnd_Api.G_EXC_ERROR;
	    END IF;
       CLOSE Check_Duplicate_CItem;

       -- Validate Association Type
       IF (Ibc_Validate_Pvt.isValidAssocType(p_assoc_type_code) = Fnd_Api.g_false) THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_ASSOC_TYPE_CODE');
	       Fnd_Message.Set_token('ASSOC_TYPE_CODE', p_assoc_type_code);
	       Fnd_Msg_Pub.ADD;
	    END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- Validate Citem Id
       IF (Ibc_Validate_Pvt.isValidCitem(p_content_item_id) = Fnd_Api.g_false) THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_ID');
	       Fnd_Message.Set_token('CITEM_ID', p_content_item_id);
	       Fnd_Msg_Pub.ADD;
	    END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- Validate Citem version id
       IF (p_citem_version_id IS NOT NULL AND
          IBC_VALIDATE_PVT.isValidCitemVerForCitem(p_content_item_id, p_citem_version_id) = FND_API.g_false)
       THEN
	   IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      	      Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
	      Fnd_Message.Set_token('CITEM_VERSION_ID', p_citem_version_id);
	      Fnd_Msg_Pub.ADD;
	   END IF;
           RAISE Fnd_Api.G_EXC_ERROR;
       END IF;


       -- Insert into table
       l_assoc_id := NULL;
       Ibc_Associations_Pkg.insert_row (
	     px_association_id          => l_assoc_id
	    ,p_content_item_id          => p_content_item_id
            ,p_citem_version_id         => p_citem_version_id
	    ,p_association_type_code 	=> p_assoc_type_code
            ,p_associated_object_val1 	=> p_assoc_object1
            ,p_associated_object_val2 	=> p_assoc_object2
            ,p_associated_object_val3 	=> p_assoc_object3
            ,p_associated_object_val4 	=> p_assoc_object4
            ,p_associated_object_val5 	=> p_assoc_object5
            ,p_object_version_number 	=> G_OBJ_VERSION_DEFAULT
            ,x_rowid  			=> l_row_id
       );

       -- Log action
       Ibc_Utilities_Pvt.log_action(
             p_activity      => Ibc_Utilities_Pvt.G_ALA_CREATE
            ,p_parent_value  => p_content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ASSOCIATION
            ,p_object_value1 => p_assoc_object1
            ,p_object_value2 => p_assoc_object2
            ,p_object_value3 => p_assoc_object3
            ,p_object_value4 => p_assoc_object4
            ,p_object_value5 => p_assoc_object5
            ,p_description   => 'Created association of type: '|| p_assoc_type_code ||
                                ' with association id: '|| l_assoc_id ||
                                ' citem id: ' || p_content_item_id ||
                                ' citem version id: ' || p_citem_version_id
       );

      --******************* Real Logic End *********************
      -- Standard check of p_commit.
      IF (Fnd_Api.To_Boolean(p_commit)) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Create_Association;



--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Association
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Delete an association mapping between an External object
--		   and a content item.
--------------------------------------------------------------------------------
PROCEDURE Delete_Association (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_commit			IN	VARCHAR2,
	p_assoc_type_code		IN	VARCHAR2,
	p_assoc_object1			IN	VARCHAR2,
	p_assoc_object2			IN	VARCHAR2,
	p_assoc_object3			IN	VARCHAR2,
	p_assoc_object4			IN	VARCHAR2,
	p_assoc_object5			IN	VARCHAR2,
	p_content_item_id		IN	NUMBER,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Association';
	l_api_version		CONSTANT NUMBER := 1.0;
	l_row_id		VARCHAR2(250);
--
	l_assoc_id			NUMBER;
--
	CURSOR Check_Assoc IS
        SELECT association_id
	FROM IBC_ASSOCIATIONS
	WHERE association_type_code = p_assoc_type_code
        AND associated_object_val1 = p_assoc_object1
        AND NVL(associated_object_val2, '0') = NVL(p_assoc_object2, '0')
        AND NVL(associated_object_val3, '0') = NVL(p_assoc_object3, '0')
        AND NVL(associated_object_val4, '0') = NVL(p_assoc_object4, '0')
        AND NVL(associated_object_val5, '0') = NVL(p_assoc_object5, '0')
	AND content_item_id = p_content_item_id;

BEGIN
      -- ******************* Standard Begins *******************
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ASSOCIATIONS_PT;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
      THEN
           RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
          Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

       -- Check if association exists
       OPEN Check_Assoc;
	    FETCH Check_Assoc INTO l_assoc_id;
	    IF (Check_Assoc%NOTFOUND) THEN
	       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	          Fnd_Message.Set_Name('IBC', 'NO_ASSOCIATION_FOUND');
	          Fnd_Msg_Pub.ADD;
	       END IF;
	       CLOSE Check_Assoc;
	       RAISE Fnd_Api.G_EXC_ERROR;
	    END IF;
       CLOSE Check_Assoc;

       -- Delete Entry
       Ibc_Associations_Pkg.delete_row(
            p_association_id => l_assoc_id
       );

       -- Log Action
       Ibc_Utilities_Pvt.log_action(
            p_activity       => Ibc_Utilities_Pvt.G_ALA_REMOVE
            ,p_parent_value  => p_content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ASSOCIATION
            ,p_object_value1 => p_assoc_object1
            ,p_object_value2 => p_assoc_object2
            ,p_object_value3 => p_assoc_object3
            ,p_object_value4 => p_assoc_object4
            ,p_object_value5 => p_assoc_object5
            ,p_description   => 'Deleted association of type '|| p_assoc_type_code || ' and content item id ' || p_content_item_id
       );

      --******************* Real Logic End *********************
      -- Standard check of p_commit.
      IF (Fnd_Api.To_Boolean(p_commit)) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Delete_Association;


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Association
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Update an External object's association mapping with
--                 a content item (optionally, a particular version).
--------------------------------------------------------------------------------
PROCEDURE Update_Association (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_commit			IN	VARCHAR2,
	p_assoc_type_code		IN	VARCHAR2,
	p_assoc_object1			IN	VARCHAR2,
	p_assoc_object2			IN	VARCHAR2,
	p_assoc_object3			IN	VARCHAR2,
	p_assoc_object4			IN	VARCHAR2,
	p_assoc_object5			IN	VARCHAR2,
	p_old_citem_id			IN	NUMBER,
	p_new_citem_id			IN	NUMBER,
	p_new_citem_ver_id		IN	NUMBER,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30) := 'Update_Association';
	l_api_version		CONSTANT NUMBER := 1.0;
	l_row_id		VARCHAR2(250);
--
	l_assoc_id			NUMBER;
	l_content_item_id		NUMBER;
	l_tmp_id			NUMBER;
--
	CURSOR Check_Assoc IS
        SELECT association_id
	FROM IBC_ASSOCIATIONS
	WHERE association_type_code = p_assoc_type_code
        AND associated_object_val1 = p_assoc_object1
        AND NVL(associated_object_val2, '0') = NVL(p_assoc_object2, '0')
        AND NVL(associated_object_val3, '0') = NVL(p_assoc_object3, '0')
        AND NVL(associated_object_val4, '0') = NVL(p_assoc_object4, '0')
        AND NVL(associated_object_val5, '0') = NVL(p_assoc_object5, '0')
	AND content_item_id = l_content_item_id;

BEGIN
      -- ******************* Standard Begins *******************
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ASSOCIATIONS_PT;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
      THEN
           RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
          Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

       -- Check if OLD association mapping exists
       l_content_item_id := p_old_citem_id;
       OPEN Check_Assoc;
	    FETCH Check_Assoc INTO l_assoc_id;
	    IF (Check_Assoc%NOTFOUND) THEN
	       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	          Fnd_Message.Set_Name('IBC', 'NO_ASSOCIATION_FOUND');
	          Fnd_Msg_Pub.ADD;
	       END IF;
	       CLOSE Check_Assoc;
	       RAISE Fnd_Api.G_EXC_ERROR;
	    END IF;
       CLOSE Check_Assoc;

       IF (p_old_citem_id <> p_new_citem_id) THEN
	  -- Check for duplicates with new citem id
          l_content_item_id := p_new_citem_id;
          OPEN Check_Assoc;
	    FETCH Check_Assoc INTO l_tmp_id;
	    IF (Check_Assoc%FOUND) THEN
	       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	          Fnd_Message.Set_Name('IBC', 'DUPLICATE_ASSOCIATION');
	          Fnd_Msg_Pub.ADD;
	       END IF;
	       CLOSE Check_Assoc;
	       RAISE Fnd_Api.G_EXC_ERROR;
	    END IF;
          CLOSE Check_Assoc;

          -- Validate Citem Id
          IF (Ibc_Validate_Pvt.isValidCitem(p_new_citem_id) = Fnd_Api.g_false) THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_ID');
	       Fnd_Message.Set_token('CITEM_ID', p_new_citem_id);
	       Fnd_Msg_Pub.ADD;
	    END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
       END IF;

       -- Validate Citem version id
       IF (p_new_citem_ver_id IS NOT NULL AND
          IBC_VALIDATE_PVT.isValidCitemVerForCitem(p_new_citem_id, p_new_citem_ver_id) = FND_API.g_false)
       THEN
	   IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      	      Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
	      Fnd_Message.Set_token('CITEM_VERSION_ID', p_new_citem_ver_id);
	      Fnd_Msg_Pub.ADD;
	   END IF;
           RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- UPDATE row
       Ibc_Associations_Pkg.update_row (
	p_association_id		=>	l_assoc_id
	,p_content_item_id		=>	p_new_citem_id
	,p_citem_version_id		=>	p_new_citem_ver_id
       );

       -- Log Action
       Ibc_Utilities_Pvt.log_action(
            p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
            ,p_parent_value  => p_new_citem_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ASSOCIATION
            ,p_object_value1 => p_assoc_object1
            ,p_object_value2 => p_assoc_object2
            ,p_object_value3 => p_assoc_object3
            ,p_object_value4 => p_assoc_object4
            ,p_object_value5 => p_assoc_object5
            ,p_description   => 'Updated association of type '|| p_assoc_type_code ||
                                ' old citem id: ' || p_old_citem_id ||
				' new citem id: ' || p_new_citem_id ||
				' new version id: ' ||  p_new_citem_ver_id
       );

      --******************* Real Logic End *********************
      -- Standard check of p_commit.
      IF (Fnd_Api.To_Boolean(p_commit)) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Update_Association;













PROCEDURE Move_Associations (
	p_api_version			IN  NUMBER,
    p_init_msg_list			IN  VARCHAR2,
	p_commit				IN	VARCHAR2,
	p_old_content_item_ids	IN	JTF_NUMBER_TABLE,
	p_new_content_item_ids	IN	JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300,
	x_return_status			OUT NOCOPY VARCHAR2,
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2
) AS
BEGIN
  Move_Associations (
	p_api_version			=> p_api_version,
        p_init_msg_list			=> p_init_msg_list,
	p_commit			=> p_commit,
	p_old_content_item_ids		=> p_old_content_item_ids,
	p_new_content_item_ids		=> p_new_content_item_ids,
        p_old_citem_version_ids		=> JTF_NUMBER_TABLE(p_old_content_item_ids.count),
        p_new_citem_version_ids		=> JTF_NUMBER_TABLE(p_old_content_item_ids.count),
	p_assoc_type_codes		=> p_assoc_type_codes,
	p_assoc_objects1		=> p_assoc_objects1,
	p_assoc_objects2		=> p_assoc_objects2,
	p_assoc_objects3		=> p_assoc_objects3,
	p_assoc_objects4		=> p_assoc_objects4,
	p_assoc_objects5		=> p_assoc_objects5,
	x_return_status			=> x_return_status,
    x_msg_count				=> x_msg_count,
    x_msg_data				=> x_msg_data
  );
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Move_Associations;

PROCEDURE Move_Associations (
	p_api_version			IN  NUMBER,
    p_init_msg_list			IN  VARCHAR2,
	p_commit				IN	VARCHAR2,
	p_old_content_item_ids	IN	JTF_NUMBER_TABLE,
	p_new_content_item_ids	IN	JTF_NUMBER_TABLE,
    p_old_citem_version_ids IN  JTF_NUMBER_TABLE,
    p_new_citem_version_ids IN  JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300,
	x_return_status			OUT NOCOPY VARCHAR2,
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2
) AS
        --******** local variable for standards **********
    l_api_name          CONSTANT VARCHAR2(30)   := 'Move_Associations';
	l_api_version		CONSTANT NUMBER := 1.0;

	l_temp_array_length	NUMBER;
	l_content_item_id 	NUMBER;
	l_citem_version_id 	NUMBER;
	l_association_type_code VARCHAR2(100);

	l_assoc_id 				NUMBER;
	l_rowid	   				VARCHAR2(240);

--
-- Could not get this to work for some reason
--
-- CURSOR c1 IS
-- SELECT A.COLUMN_VALUE A_content_item_id
-- FROM TABLE(CAST(p_content_item_ids AS JTF_NUMBER_TABLE)) AS A
-- WHERE NOT EXISTS (SELECT NULL FROM IBC_CONTENT_ITEMS C
-- WHERE  a.column_value=c.content_item_id);
--

CURSOR cur_old_citem IS
SELECT A.COLUMN_VALUE content_item_id
FROM TABLE(CAST(p_old_content_item_ids AS JTF_NUMBER_TABLE)) A
MINUS
SELECT content_item_id FROM IBC_CONTENT_ITEMS C;

CURSOR cur_new_citem IS
SELECT A.COLUMN_VALUE content_item_id
FROM TABLE(CAST(p_new_content_item_ids AS JTF_NUMBER_TABLE)) A
MINUS
SELECT content_item_id FROM IBC_CONTENT_ITEMS C;

CURSOR cur_old_citem_version IS
SELECT A.COLUMN_VALUE citem_version_id
FROM TABLE(CAST(p_old_citem_version_ids AS JTF_NUMBER_TABLE)) A
MINUS
SELECT citem_version_id FROM IBC_CITEM_VERSIONS_B C;

CURSOR cur_new_citem_version IS
SELECT A.COLUMN_VALUE citem_version_id
FROM TABLE(CAST(p_new_citem_version_ids AS JTF_NUMBER_TABLE)) A
MINUS
SELECT citem_version_id FROM IBC_CITEM_VERSIONS_B C;


CURSOR cur_assoc IS
SELECT A.COLUMN_VALUE association_type_code
FROM TABLE(CAST(p_assoc_type_codes AS JTF_VARCHAR2_TABLE_100)) A
MINUS
SELECT association_type_code FROM IBC_ASSOCIATION_TYPES_B C;

BEGIN
      -- ******************* Standard Begins *******************
      -- Standard Start of API savepoint
      SAVEPOINT MOVE_ASSOCIATIONS_PT;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
      THEN
           RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
          Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      l_temp_array_length := p_old_content_item_ids.COUNT;
      IF ( (p_new_content_item_ids.COUNT <> l_temp_array_length) OR
	  	   (p_assoc_type_codes.COUNT <> l_temp_array_length) OR
           (p_assoc_objects1.COUNT <> l_temp_array_length) OR
           ( (p_assoc_objects2 IS NOT NULL) AND (p_assoc_objects2.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects3 IS NOT NULL) AND (p_assoc_objects3.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects4 IS NOT NULL) AND (p_assoc_objects4.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects5 IS NOT NULL) AND (p_assoc_objects5.COUNT <> l_temp_array_length) ) )  THEN
	IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	   Fnd_Message.Set_Name('IBC', 'IMPROPER_ARRAY');
	   Fnd_Msg_Pub.ADD;
	END IF;
	RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

         -- Validate Old Citem Id
		 --
        BEGIN

		l_content_item_id := NULL;

		OPEN cur_old_citem;
		FETCH cur_old_citem INTO l_content_item_id;
		CLOSE cur_old_citem;
		IF l_content_item_id IS NOT NULL THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_ID');
	       Fnd_Message.Set_token('CITEM_ID',l_content_item_id);
	       Fnd_Msg_Pub.ADD;
        END IF;
		   RAISE Fnd_Api.G_EXC_ERROR;
		END IF;

		END;

		-- Validate New Citem Id
		--
        BEGIN

		l_content_item_id := NULL;

		OPEN cur_new_citem;
		FETCH cur_new_citem INTO l_content_item_id;
		CLOSE cur_new_citem;
		IF l_content_item_id IS NOT NULL THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_ID');
	       Fnd_Message.Set_token('CITEM_ID',l_content_item_id);
	       Fnd_Msg_Pub.ADD;
        END IF;
		   RAISE Fnd_Api.G_EXC_ERROR;
		END IF;

		END;


         -- Validate Old Citem Version Id
		 --
        BEGIN

		l_citem_version_id := NULL;

		OPEN cur_old_citem_version;
		FETCH cur_old_citem_version INTO l_citem_version_id;
		CLOSE cur_old_citem_version;
		IF l_citem_version_id IS NOT NULL THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
	       Fnd_Message.Set_token('CITEM_VERSION_ID',l_citem_version_id);
	       Fnd_Msg_Pub.ADD;
        END IF;
		   RAISE Fnd_Api.G_EXC_ERROR;
		END IF;

		END;

		-- Validate New Citem Id
		--
        BEGIN

		l_citem_version_id := NULL;

		OPEN cur_new_citem_version;
		FETCH cur_new_citem_version INTO l_citem_version_id;
		CLOSE cur_new_citem_version;
		IF l_citem_version_id IS NOT NULL THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
	       Fnd_Message.Set_token('CITEM_VERSION_ID',l_citem_version_id);
	       Fnd_Msg_Pub.ADD;
        END IF;
		   RAISE Fnd_Api.G_EXC_ERROR;
		END IF;

		END;


        -- Validate Association Type
		--
		BEGIN

		l_association_type_code := NULL;

		OPEN cur_assoc;
		FETCH cur_assoc INTO l_association_type_code;
		CLOSE cur_assoc;

		IF (l_association_type_code IS NOT NULL) THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_ASSOC_TYPE_CODE');
	       Fnd_Message.Set_token('ASSOC_TYPE_CODE', l_association_type_code);
	       Fnd_Msg_Pub.ADD;
	    END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

		END;

-- 			   ,association_type_code 	 = p_assoc_type_codes(i)
--             ,associated_object_val1  = DECODE(p_assoc_objects1(i),NULL,associated_object_val1,p_assoc_objects1(i))
--             ,associated_object_val2  = DECODE(p_assoc_objects2(i),NULL,associated_object_val2,p_assoc_objects2(i))
--             ,associated_object_val3  = DECODE(p_assoc_objects3(i),NULL,associated_object_val3,p_assoc_objects3(i))
--             ,associated_object_val4  = DECODE(p_assoc_objects4(i),NULL,associated_object_val4,p_assoc_objects4(i))
--             ,associated_object_val5  = DECODE(p_assoc_objects5(i),NULL,associated_object_val5,p_assoc_objects5(i))
	--
	--  Update
	--
   	--DBMS_OUT NOCOPYPUT.put_line('Begin Successful....');

	FORALL i IN p_old_content_item_ids.FIRST..p_old_content_item_ids.LAST
	    DELETE FROM IBC_ASSOCIATIONS
		WHERE ROWID IN (
		SELECT A.ROWID FROM IBC_ASSOCIATIONS A,
		(
		-- The below Select Statement Returns all the rows that will be updated
		-- in the following Update Statement Which moves an Association from old_content_item_id
		-- to the New Content Item id.
		-- When moved if the New Content Item Id already has this association we don't want to error
		-- OUT NOCOPY but merge the two row. Which means we will have to delete one row.
		-- All the rows that r going to be updated
		-- Make sure that the new row is not a Duplicate in the table
		SELECT
          	 association_type_code
            ,associated_object_val1
            ,associated_object_val2
            ,associated_object_val3
            ,associated_object_val4
			,associated_object_val5
		  FROM IBC_ASSOCIATIONS
		  WHERE CONTENT_ITEM_ID    	 = p_old_content_item_ids(i)
          AND ((citem_version_id IS NULL AND p_old_citem_version_ids(i) IS NULL)
               OR
               (citem_version_id = p_old_citem_version_ids(i))
              )
		  AND association_type_code  = p_assoc_type_codes(i)
          AND (associated_object_val1 = p_assoc_objects1(i) OR DECODE(p_assoc_objects1(i),NULL,1) = 1)
          AND (associated_object_val2 = p_assoc_objects2(i) OR DECODE(p_assoc_objects1(i),NULL,1) = 1 OR DECODE(p_assoc_objects2(i),NULL,NVL(associated_object_val2,'1')) = '1')
          AND (associated_object_val3 = p_assoc_objects3(i)	OR DECODE(p_assoc_objects1(i),NULL,1) = 1 OR DECODE(p_assoc_objects3(i),NULL,NVL(associated_object_val3,'1')) = '1')
          AND (associated_object_val4 = p_assoc_objects4(i)	OR DECODE(p_assoc_objects1(i),NULL,1) = 1 OR DECODE(p_assoc_objects4(i),NULL,NVL(associated_object_val4,'1')) = '1')
          AND (associated_object_val5 = p_assoc_objects5(i)	OR DECODE(p_assoc_objects1(i),NULL,1) = 1 OR DECODE(p_assoc_objects5(i),NULL,NVL(associated_object_val5,'1')) = '1')
		  ) B
		  WHERE a.association_type_code = b.association_type_code
		  AND a.associated_object_val1 = b.associated_object_val1
          AND NVL(a.associated_object_val2,'1') =  NVL(b.associated_object_val2,'1')
          AND NVL(a.associated_object_val3,'1') =  NVL(b.associated_object_val3,'1')
          AND NVL(a.associated_object_val4,'1') =  NVL(b.associated_object_val4,'1')
          AND NVL(a.associated_object_val5,'1') =  NVL(b.associated_object_val5,'1')
		  AND a.CONTENT_ITEM_ID = p_new_content_item_ids(i)
          AND ((a.citem_version_id IS NULL AND p_new_citem_version_ids(i) IS NULL)
               OR
               (citem_version_id = p_new_citem_version_ids(i))
              )
		  -- By Mistake if the user passes the same old and new Content Item Id and citem ver id
		  -- then Delete should not happen.
		  AND NOT ( (p_new_content_item_ids(i) = p_old_content_item_ids(i)
                     AND
                     p_new_citem_version_ids(i) IS NULL AND p_old_citem_version_ids(i) IS NULL
                     )
                     OR
                     (p_new_content_item_ids(i) = p_old_content_item_ids(i)
                      AND
                      p_new_citem_version_ids(i) = p_old_citem_version_ids(i)
                     )
                   )
         );



    FORALL i IN p_old_content_item_ids.FIRST..p_old_content_item_ids.LAST
	    UPDATE IBC_ASSOCIATIONS SET
          	 CONTENT_ITEM_ID = p_new_content_item_ids(i)
            ,CITEM_VERSION_ID = p_new_citem_version_ids(i)
            ,OBJECT_VERSION_NUMBER 	 = 1
            ,LAST_UPDATE_DATE 	   	 = SYSDATE
            ,LAST_UPDATED_BY 	  	 = Fnd_Global.user_id
            ,LAST_UPDATE_LOGIN 	   	 = Fnd_Global.login_id
		  WHERE CONTENT_ITEM_ID    	 = p_old_content_item_ids(i)
          AND ((citem_version_id IS NULL AND p_old_citem_version_ids(i) IS NULL)
               OR
               (citem_version_id = p_old_citem_version_ids(i))
              )
		  AND association_type_code  = p_assoc_type_codes(i)
          AND (associated_object_val1 = p_assoc_objects1(i) OR DECODE(p_assoc_objects1(i),NULL,1) = 1)
          AND (associated_object_val2 = p_assoc_objects2(i) OR DECODE(p_assoc_objects1(i),NULL,1) = 1 OR DECODE(p_assoc_objects2(i),NULL,NVL(associated_object_val2,'1')) = '1')
          AND (associated_object_val3 = p_assoc_objects3(i)	OR DECODE(p_assoc_objects1(i),NULL,1) = 1 OR DECODE(p_assoc_objects3(i),NULL,NVL(associated_object_val3,'1')) = '1')
          AND (associated_object_val4 = p_assoc_objects4(i)	OR DECODE(p_assoc_objects1(i),NULL,1) = 1 OR DECODE(p_assoc_objects4(i),NULL,NVL(associated_object_val4,'1')) = '1')
          AND (associated_object_val5 = p_assoc_objects5(i)	OR DECODE(p_assoc_objects1(i),NULL,1) = 1 OR DECODE(p_assoc_objects5(i),NULL,NVL(associated_object_val5,'1')) = '1');

   	--DBMS_OUT NOCOPYPUT.put_line('Update Successful....');
	--Will insert them.

	BEGIN

	FOR i IN p_old_content_item_ids.FIRST..p_old_content_item_ids.LAST
		LOOP
		  IF SQL%BULK_ROWCOUNT(i) = 0 AND p_old_content_item_ids(i) IS NULL THEN
		  	 BEGIN

		   	  Ibc_Associations_Pkg.insert_row (
	     			  px_association_id          => l_assoc_id
	    			  ,p_content_item_id         => p_new_content_item_ids(i)
                      ,p_citem_version_id        => p_new_citem_version_ids(i)
	    			  ,p_association_type_code 	 => p_assoc_type_codes(i)
                      ,p_associated_object_val1  => p_assoc_objects1(i)
                      ,p_associated_object_val2  => p_assoc_objects2(i)
                      ,p_associated_object_val3  => p_assoc_objects3(i)
                      ,p_associated_object_val4  => p_assoc_objects4(i)
                      ,p_associated_object_val5  => p_assoc_objects5(i)
            		  ,p_object_version_number 	 => G_OBJ_VERSION_DEFAULT
            		  ,x_rowid  				 => l_rowid
					);
 				EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
						-- If the User tries to Insert a Duplicate
						-- this exception will be thrown 'cos there
						-- is a Unique Index.
						-- Ignore and proceed with the next Insert
 						NULL;
			 END;
		  END IF;
		END LOOP;
	END;


      --******************* Real Logic End *********************
      -- Standard check of p_commit.
      IF (Fnd_Api.To_Boolean(p_commit)) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      Fnd_Msg_Pub.Count_And_Get (p_count => x_msg_count,
								p_data  => x_msg_data);
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK TO MOVE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO MOVE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       ROLLBACK TO MOVE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Move_Associations;

PROCEDURE Create_Associations (
	p_api_version			IN  NUMBER,
    p_init_msg_list			IN  VARCHAR2,
	p_commit				IN	VARCHAR2,
	p_content_item_ids		IN	JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
BEGIN
  Create_Associations (
	p_api_version			=> p_api_version,
    p_init_msg_list			=> p_init_msg_list,
	p_commit				=> p_commit,
	p_content_item_ids		=> p_content_item_ids,
    p_citem_version_ids     => NULL,
	p_assoc_type_codes		=> p_assoc_type_codes,
	p_assoc_objects1		=> p_assoc_objects1,
	p_assoc_objects2		=> p_assoc_objects2,
	p_assoc_objects3		=> p_assoc_objects3,
	p_assoc_objects4		=> p_assoc_objects4,
	p_assoc_objects5		=> p_assoc_objects5,
	x_return_status			=> x_return_status,
    x_msg_count		  	    => x_msg_count,
    x_msg_data			    => x_msg_data
  );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Create_Associations;

PROCEDURE Create_Associations (
	p_api_version			IN  NUMBER,
        p_init_msg_list			IN  VARCHAR2,
	p_commit			IN	VARCHAR2,
	p_content_item_ids		IN	JTF_NUMBER_TABLE,
	p_citem_version_ids		IN  JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
    l_api_name              CONSTANT VARCHAR2(30)   := 'Create_Associations';
	l_api_version			CONSTANT NUMBER := 1.0;
	l_row_id				VARCHAR2(250);
--
    l_assoc_id				NUMBER;
	l_temp_array_length		NUMBER;
	l_count					NUMBER := 1;

	l_content_item_id		NUMBER;
    l_citem_version_id      NUMBER;
	l_assoc_type_code		VARCHAR2(100);
	l_assoc_object1			VARCHAR2(254);
	l_assoc_object2			VARCHAR2(254);
	l_assoc_object3			VARCHAR2(254);
	l_assoc_object4			VARCHAR2(254);
	l_assoc_object5			VARCHAR2(254);

BEGIN
      -- ******************* Standard Begins *******************
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ASSOCIATIONS_PT;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
      THEN
           RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
          Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      l_temp_array_length := p_content_item_ids.COUNT;
      IF ( (p_assoc_type_codes.COUNT <> l_temp_array_length) OR
           (p_assoc_objects1.COUNT <> l_temp_array_length) OR
           ( (p_assoc_objects2 IS NOT NULL) AND (p_assoc_objects2.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects3 IS NOT NULL) AND (p_assoc_objects3.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects4 IS NOT NULL) AND (p_assoc_objects4.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects5 IS NOT NULL) AND (p_assoc_objects5.COUNT <> l_temp_array_length) ) )  THEN
	IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	   Fnd_Message.Set_Name('IBC', 'IMPROPER_ARRAY');
	   Fnd_Msg_Pub.ADD;
	END IF;
	RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


   WHILE l_count <= l_temp_array_length LOOP
	 l_content_item_id := p_content_item_ids(l_count);
     l_citem_version_id := NULL;
     IF p_citem_version_ids IS NOT NULL THEN
       l_citem_version_id := p_citem_version_ids(l_count);
     END IF;
	 l_assoc_type_code := p_assoc_type_codes(l_count);
	 l_assoc_object1 := p_assoc_objects1(l_count);
	 l_assoc_object2 := NULL;
	 l_assoc_object3 := NULL;
	 l_assoc_object4 := NULL;
	 l_assoc_object5 := NULL;
	 IF (p_assoc_objects2 IS NOT NULL) THEN
	    l_assoc_object2 := p_assoc_objects2(l_count);
	 END IF;
	 IF (p_assoc_objects3 IS NOT NULL) THEN
	    l_assoc_object3 := p_assoc_objects3(l_count);
	 END IF;
	 IF (p_assoc_objects4 IS NOT NULL) THEN
	    l_assoc_object4 := p_assoc_objects4(l_count);
	 END IF;
	 IF (p_assoc_objects5 IS NOT NULL) THEN
	    l_assoc_object5 := p_assoc_objects5(l_count);
	 END IF;

         -- Validate Citem Id
         IF (Ibc_Validate_Pvt.isValidCitem(l_content_item_id) = Fnd_Api.g_false) THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_ID');
	       Fnd_Message.Set_token('CITEM_ID', l_content_item_id);
	       Fnd_Msg_Pub.ADD;
	    END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

         -- Validate citem version id
         IF l_citem_version_id IS NOT NULL AND
            IBC_VALIDATE_PVT.isValidCitemVerForCitem(l_content_item_id, l_citem_version_id) = FND_API.g_false
         THEN
	       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      	     Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
	         Fnd_Message.Set_token('CITEM_VERSION_ID', l_citem_version_id);
	         Fnd_Msg_Pub.ADD;
	       END IF;
           RAISE Fnd_Api.G_EXC_ERROR;
         END IF;



         -- Validate Association Type
         IF (Ibc_Validate_Pvt.isValidAssocType(l_assoc_type_code) = Fnd_Api.g_false) THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_ASSOC_TYPE_CODE');
	       Fnd_Message.Set_token('ASSOC_TYPE_CODE', l_assoc_type_code);
	       Fnd_Msg_Pub.ADD;
	    END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

	 -- Insert into table
	 l_assoc_id := NULL;
         Ibc_Associations_Pkg.insert_row (
	     px_association_id          => l_assoc_id
	    ,p_content_item_id          => l_content_item_id
        ,p_citem_version_id         => l_citem_version_id
	    ,p_association_type_code 	=> l_assoc_type_code
            ,p_associated_object_val1 	=> l_assoc_object1
            ,p_associated_object_val2 	=> l_assoc_object2
            ,p_associated_object_val3 	=> l_assoc_object3
            ,p_associated_object_val4 	=> l_assoc_object4
            ,p_associated_object_val5 	=> l_assoc_object5
            ,p_object_version_number 	=> G_OBJ_VERSION_DEFAULT
            ,x_rowid  			=> l_row_id
         );

	 -- Log action
         Ibc_Utilities_Pvt.log_action(
             p_activity      => Ibc_Utilities_Pvt.G_ALA_CREATE
            ,p_parent_value  => l_content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ASSOCIATION
            ,p_object_value1 => l_assoc_object1
            ,p_object_value2 => l_assoc_object2
            ,p_object_value3 => l_assoc_object3
            ,p_object_value4 => l_assoc_object4
            ,p_object_value5 => l_assoc_object5
            ,p_description   => 'Created of type '|| l_assoc_type_code ||' with association id '|| l_assoc_id
         );

	 l_count := l_count + 1;
      END LOOP;

      --******************* Real Logic End *********************
      -- Standard check of p_commit.
      IF (Fnd_Api.To_Boolean(p_commit)) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       ROLLBACK TO CREATE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Create_Associations;



PROCEDURE Delete_Associations (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_commit			IN	VARCHAR2,
	p_content_item_ids		IN	JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
BEGIN
  Delete_Associations (
	p_api_version			=> p_api_version,
    p_init_msg_list			=> p_init_msg_list,
	p_commit			    => p_commit,
	p_content_item_ids		=> p_content_item_ids,
    p_citem_version_ids     => NULL,
	p_assoc_type_codes		=> p_assoc_type_codes,
	p_assoc_objects1		=> p_assoc_objects1,
	p_assoc_objects2		=> p_assoc_objects2,
	p_assoc_objects3		=> p_assoc_objects3,
	p_assoc_objects4		=> p_assoc_objects4,
	p_assoc_objects5		=> p_assoc_objects5,
	x_return_status			=> x_return_status,
    x_msg_count		 	    => x_msg_count,
    x_msg_data			    => x_msg_data
  );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Delete_Associations;



PROCEDURE Delete_Associations (
	p_api_version			IN    	NUMBER,
    p_init_msg_list			IN    	VARCHAR2,
	p_commit			    IN	VARCHAR2,
	p_content_item_ids		IN	JTF_NUMBER_TABLE,
    p_citem_version_ids     IN  JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300,
	x_return_status			OUT NOCOPY   	VARCHAR2,
    x_msg_count			    OUT NOCOPY    	NUMBER,
    x_msg_data			    OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Delete_Associations';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_temp_array_length	NUMBER;
	l_count			NUMBER := 1;
	l_temp_assoc_id		NUMBER;

	l_content_item_id	NUMBER;
    l_citem_version_id  NUMBER;
	l_assoc_type_code	VARCHAR2(100);
	l_assoc_object1		VARCHAR2(254);
	l_assoc_object2		VARCHAR2(254);
	l_assoc_object3		VARCHAR2(254);
	l_assoc_object4		VARCHAR2(254);
	l_assoc_object5		VARCHAR2(254);
--
	CURSOR Get_Assoc_Id IS
        SELECT association_id
	FROM IBC_ASSOCIATIONS
        WHERE content_item_id = l_content_item_id
        AND ((citem_version_id IS NULL AND l_citem_version_id IS NULL) OR
             (citem_version_id = l_citem_version_id)
            )
        AND association_type_code = l_assoc_type_code
        AND associated_object_val1 = l_assoc_object1
        AND NVL(associated_object_val2, '0') = NVL(l_assoc_object2, '0')
        AND NVL(associated_object_val3, '0') = NVL(l_assoc_object3, '0')
        AND NVL(associated_object_val4, '0') = NVL(l_assoc_object4, '0')
        AND NVL(associated_object_val5, '0') = NVL(l_assoc_object5, '0');

BEGIN
      -- ******************* Standard Begins *******************
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_ASSOCIATIONS_PT;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
      THEN
           RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
          Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      l_temp_array_length := p_content_item_ids.COUNT;
      IF ( (p_assoc_type_codes.COUNT <> l_temp_array_length) OR
           (p_assoc_objects1.COUNT <> l_temp_array_length) OR
           ( (p_assoc_objects2 IS NOT NULL) AND (p_assoc_objects2.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects3 IS NOT NULL) AND (p_assoc_objects3.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects4 IS NOT NULL) AND (p_assoc_objects4.COUNT <> l_temp_array_length) ) OR
           ( (p_assoc_objects5 IS NOT NULL) AND (p_assoc_objects5.COUNT <> l_temp_array_length) ) )  THEN
	IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	   Fnd_Message.Set_Name('IBC', 'IMPROPER_ARRAY');
	   Fnd_Msg_Pub.ADD;
	END IF;
	RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      WHILE l_count <= l_temp_array_length LOOP

	 l_content_item_id := p_content_item_ids(l_count);
     l_citem_version_id := NULL;
     IF p_citem_version_ids IS NOT NULL THEN
       l_citem_version_id := p_citem_version_ids(l_count);
     END IF;
	 l_assoc_type_code := p_assoc_type_codes(l_count);
	 l_assoc_object1 := p_assoc_objects1(l_count);
	 l_assoc_object2 := NULL;
	 l_assoc_object3 := NULL;
	 l_assoc_object4 := NULL;
	 l_assoc_object5 := NULL;
	 IF (p_assoc_objects2 IS NOT NULL) THEN
	    l_assoc_object2 := p_assoc_objects2(l_count);
	 END IF;
	 IF (p_assoc_objects3 IS NOT NULL) THEN
	    l_assoc_object3 := p_assoc_objects3(l_count);
	 END IF;
	 IF (p_assoc_objects4 IS NOT NULL) THEN
	    l_assoc_object4 := p_assoc_objects4(l_count);
	 END IF;
	 IF (p_assoc_objects5 IS NOT NULL) THEN
	    l_assoc_object5 := p_assoc_objects5(l_count);
	 END IF;

	 OPEN Get_Assoc_Id;
	    FETCH Get_Assoc_Id INTO l_temp_assoc_id;
	    IF (Get_Assoc_Id%NOTFOUND) THEN
	       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	          Fnd_Message.Set_Name('IBC', 'NO_ASSOCIATION_FOUND');
	          Fnd_Msg_Pub.ADD;
	       END IF;
	       CLOSE Get_Assoc_Id;
	       RAISE Fnd_Api.G_EXC_ERROR;
	    END IF;
	 CLOSE Get_Assoc_Id;

	 -- Delete Entry
	 Ibc_Associations_Pkg.delete_row(
            p_association_id => l_temp_assoc_id
         );

	 -- Log Action
	 Ibc_Utilities_Pvt.log_action(
            p_activity       => Ibc_Utilities_Pvt.G_ALA_REMOVE
            ,p_parent_value  => l_content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ASSOCIATION
            ,p_object_value1 => l_assoc_object1
            ,p_object_value2 => l_assoc_object2
            ,p_object_value3 => l_assoc_object3
            ,p_object_value4 => l_assoc_object4
            ,p_object_value5 => l_assoc_object5
            ,p_description   => 'Deleting association of type '|| l_assoc_type_code
         );

	 l_count := l_count + 1;
      END LOOP;

      --******************* Real Logic End *********************
      -- Standard check of p_commit.
      IF (Fnd_Api.To_Boolean(p_commit)) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK TO DELETE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO DELETE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       ROLLBACK TO DELETE_ASSOCIATIONS_PT;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Delete_Associations;


PROCEDURE Get_Associations (
	p_api_version			IN    	NUMBER,
    p_init_msg_list			IN    	VARCHAR2,
	p_content_item_id		IN	NUMBER,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300,
	x_assoc_type_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_assoc_objects1		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects2		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects3		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects4		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects5		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_names			OUT NOCOPY	JTF_VARCHAR2_TABLE_4000,
	x_assoc_codes			OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
BEGIN
  Get_Associations (
	p_api_version			=> p_api_version,
    p_init_msg_list			=> p_init_msg_list,
	p_content_item_id		=> p_content_item_id,
    p_citem_version_id      => NULL,
	p_assoc_type_codes		=> p_assoc_type_codes,
	p_assoc_objects1		=> p_assoc_objects1,
	p_assoc_objects2		=> p_assoc_objects2,
	p_assoc_objects3		=> p_assoc_objects3,
	p_assoc_objects4		=> p_assoc_objects4,
	p_assoc_objects5		=> p_assoc_objects5,
	x_assoc_type_codes		=> x_assoc_type_codes,
	x_assoc_objects1		=> x_assoc_objects1,
	x_assoc_objects2		=> x_assoc_objects2,
	x_assoc_objects3		=> x_assoc_objects3,
	x_assoc_objects4		=> x_assoc_objects4,
	x_assoc_objects5		=> x_assoc_objects5,
	x_assoc_names			=> x_assoc_names,
	x_assoc_codes			=> x_assoc_codes,
	x_return_status			=> x_return_status,
    x_msg_count			    => x_msg_count,
    x_msg_data			    => x_msg_data
  );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Get_Associations;

PROCEDURE Get_Associations (
	p_api_version			IN    	NUMBER,
    p_init_msg_list			IN    	VARCHAR2,
	p_content_item_id		IN	NUMBER,
    p_citem_version_id      IN  NUMBER,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300,
	x_assoc_type_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_assoc_objects1		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects2		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects3		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects4		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects5		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_names			OUT NOCOPY	JTF_VARCHAR2_TABLE_4000,
	x_assoc_codes			OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Associations';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	pre_plsql_block		VARCHAR2(10) := 'BEGIN ';
	post_plsql_block	VARCHAR2(200) := '.Get_Object_Name(:at, :v1, :v2, :v3, :v4, :v5, :xn, :xc, :xret, :xmc, :md); END;';
	l_assoc_name		VARCHAR2(4000);
	l_assoc_code		VARCHAR2(100);

	l_count			NUMBER := 1;
	l_assoc_type_code	VARCHAR2(100) := NULL;
	l_callback_pkg		VARCHAR2(30);
	l_assoc_object2		VARCHAR2(254) := NULL;
	l_assoc_object3		VARCHAR2(254) := NULL;
	l_assoc_object4		VARCHAR2(254) := NULL;
	l_assoc_object5		VARCHAR2(254) := NULL;
--
	CURSOR Get_Assoc IS
	SELECT a.ASSOCIATION_TYPE_CODE, a.ASSOCIATED_OBJECT_VAL1, a.ASSOCIATED_OBJECT_VAL2,
	       a.ASSOCIATED_OBJECT_VAL3, a.ASSOCIATED_OBJECT_VAL4, a.ASSOCIATED_OBJECT_VAL5,
	       t.CALL_BACK_PKG
	FROM IBC_ASSOCIATIONS a, IBC_ASSOCIATION_TYPES_B t
	WHERE a.CONTENT_ITEM_ID = p_content_item_id AND
          ((a.citem_version_id IS NULL AND p_citem_version_id IS NULL)
           OR
           (a.citem_version_id = p_citem_version_id)) AND
	      a.ASSOCIATION_TYPE_CODE = t.ASSOCIATION_TYPE_CODE;

	CURSOR Get_CallBack IS
	SELECT CALL_BACK_PKG
	FROM IBC_ASSOCIATION_TYPES_B
	WHERE ASSOCIATION_TYPE_CODE = l_assoc_type_code;

BEGIN
      -- ******************* Standard Begins *******************
      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
      THEN
           RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
          Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      -- ******************* Real Logic Start *********************

      -- Validate Citem Id
      IF (p_content_item_id IS NOT NULL) THEN
         IF (Ibc_Validate_Pvt.isValidCitem(p_content_item_id) = Fnd_Api.g_false) THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_ID');
	       Fnd_Message.Set_token('CITEM_ID', p_content_item_id);
	       Fnd_Msg_Pub.ADD;
	    END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
      END IF;
      IF p_citem_version_id IS NOT NULL AND
         IBC_VALIDATE_PVT.isValidCitemVerForCitem(p_content_item_id, p_citem_version_id) = FND_API.g_false
      THEN
        IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
	       Fnd_Message.Set_token('CITEM_VERSION_ID', p_citem_version_id);
	       Fnd_Msg_Pub.ADD;
	    END IF;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


      -- Initialize OUT NOCOPYput parameters
      x_assoc_type_codes := JTF_VARCHAR2_TABLE_100();
      x_assoc_objects1 := JTF_VARCHAR2_TABLE_300();
      x_assoc_objects2 := JTF_VARCHAR2_TABLE_300();
      x_assoc_objects3 := JTF_VARCHAR2_TABLE_300();
      x_assoc_objects4 := JTF_VARCHAR2_TABLE_300();
      x_assoc_objects5 := JTF_VARCHAR2_TABLE_300();
      x_assoc_names := JTF_VARCHAR2_TABLE_4000();
      x_assoc_codes := JTF_VARCHAR2_TABLE_100();

      -- Retrieive Existing Associations
      FOR assoc_rec IN Get_Assoc LOOP
	 IF (assoc_rec.CALL_BACK_PKG IS NULL) THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	       Fnd_Message.Set_Name('IBC', 'IBC_CALL_BACK_PKG_IS_NULL');
	       Fnd_Message.Set_token('ASSOC_TYPE_CODE', assoc_rec.ASSOCIATION_TYPE_CODE);
	       Fnd_Msg_Pub.ADD;
	    END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

         BEGIN
	   -- Execute CallBack
           EXECUTE IMMEDIATE (pre_plsql_block || assoc_rec.CALL_BACK_PKG || post_plsql_block)
	    USING assoc_rec.ASSOCIATION_TYPE_CODE,
		  assoc_rec.ASSOCIATED_OBJECT_VAL1, assoc_rec.ASSOCIATED_OBJECT_VAL2,
		  assoc_rec.ASSOCIATED_OBJECT_VAL3, assoc_rec.ASSOCIATED_OBJECT_VAL4,
		  assoc_rec.ASSOCIATED_OBJECT_VAL5, OUT  l_assoc_name, OUT  l_assoc_code,
		  OUT x_return_status, OUT  x_msg_count, OUT  x_msg_data;
         EXCEPTION
            WHEN OTHERS THEN
               IF (SQLCODE = -6550) THEN
                  IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	             Fnd_Message.Set_Name('IBC', 'IBC_CALL_BACK_PKG_INVALID');
	             Fnd_Message.Set_token('CALL_BACK_PKG', assoc_rec.CALL_BACK_PKG);
	             Fnd_Msg_Pub.ADD;
	          END IF;
		  RAISE Fnd_Api.G_EXC_ERROR;
	       ELSE
		  RAISE;
	       END IF;
         END;

	 x_assoc_type_codes.EXTEND();
	 x_assoc_type_codes(l_count) := assoc_rec.ASSOCIATION_TYPE_CODE;
	 x_assoc_objects1.EXTEND();
	 x_assoc_objects1(l_count) := assoc_rec.ASSOCIATED_OBJECT_VAL1;
	 x_assoc_objects2.EXTEND();
	 x_assoc_objects2(l_count) := assoc_rec.ASSOCIATED_OBJECT_VAL2;
	 x_assoc_objects3.EXTEND();
	 x_assoc_objects3(l_count) := assoc_rec.ASSOCIATED_OBJECT_VAL3;
	 x_assoc_objects4.EXTEND();
	 x_assoc_objects4(l_count) := assoc_rec.ASSOCIATED_OBJECT_VAL4;
	 x_assoc_objects5.EXTEND();
	 x_assoc_objects5(l_count) := assoc_rec.ASSOCIATED_OBJECT_VAL5;
	 x_assoc_names.EXTEND();
	 x_assoc_names(l_count) := l_assoc_name;
	 x_assoc_codes.EXTEND();
	 x_assoc_codes(l_count) := l_assoc_code;

	 l_count := l_count + 1;
      END LOOP;

      -- Get Names/Codes for additional input associations
      IF (p_assoc_type_codes IS NOT NULL) THEN

         FOR i IN 1..p_assoc_type_codes.COUNT LOOP
            IF ((l_assoc_type_code IS NULL) OR (p_assoc_type_codes(i) <> l_assoc_type_code)) THEN
	       l_assoc_type_code := p_assoc_type_codes(i);
	       OPEN Get_CallBack;
	          FETCH Get_CallBack INTO l_callback_pkg;
	          IF (Get_CallBack%NOTFOUND) THEN
	             IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	                Fnd_Message.Set_Name('IBC', 'INVALID_ASSOC_TYPE_CODE');
	                Fnd_Message.Set_token('ASSOC_TYPE_CODE', l_assoc_type_code);
	                Fnd_Msg_Pub.ADD;
	             END IF;
                     RAISE Fnd_Api.G_EXC_ERROR;
	          END IF;
	          IF (l_callback_pkg IS NULL) THEN
	             IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	                Fnd_Message.Set_Name('IBC', 'IBC_CALL_BACK_PKG_IS_NULL');
	                Fnd_Message.Set_token('ASSOC_TYPE_CODE', l_assoc_type_code);
	                Fnd_Msg_Pub.ADD;
	             END IF;
                     RAISE Fnd_Api.G_EXC_ERROR;
                  END IF;
	       CLOSE Get_CallBack;
	    END IF;

	    IF (p_assoc_objects2 IS NOT NULL) THEN
	       l_assoc_object2 := p_assoc_objects2(i);
	    END IF;
	    IF (p_assoc_objects3 IS NOT NULL) THEN
	       l_assoc_object3 := p_assoc_objects3(i);
	    END IF;
	    IF (p_assoc_objects4 IS NOT NULL) THEN
	       l_assoc_object4 := p_assoc_objects4(i);
	    END IF;
	    IF (p_assoc_objects5 IS NOT NULL) THEN
	       l_assoc_object5 := p_assoc_objects5(i);
	    END IF;

	    BEGIN
	       -- Execute CallBack
               EXECUTE IMMEDIATE (pre_plsql_block || l_callback_pkg || post_plsql_block)
	        USING l_assoc_type_code,
		     p_assoc_objects1(i),  l_assoc_object2,
		     l_assoc_object3,  l_assoc_object4,
		     l_assoc_object5, OUT  l_assoc_name, OUT  l_assoc_code,
		     OUT  x_return_status, OUT x_msg_count, OUT x_msg_data;
            EXCEPTION
               WHEN OTHERS THEN
                  IF (SQLCODE = -6550) THEN
                     IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	                Fnd_Message.Set_Name('IBC', 'IBC_CALL_BACK_PKG_INVALID');
	                Fnd_Message.Set_token('CALL_BACK_PKG', l_callback_pkg);
	                Fnd_Msg_Pub.ADD;
	             END IF;
		     RAISE Fnd_Api.G_EXC_ERROR;
	          ELSE
		     RAISE;
	          END IF;
            END;

	    x_assoc_type_codes.EXTEND();
	    x_assoc_type_codes(l_count) := l_assoc_type_code;
	    x_assoc_objects1.EXTEND();
	    x_assoc_objects1(l_count) := p_assoc_objects1(i);
	    x_assoc_objects2.EXTEND();
	    x_assoc_objects2(l_count) := l_assoc_object2;
	    x_assoc_objects3.EXTEND();
	    x_assoc_objects3(l_count) := l_assoc_object3;
	    x_assoc_objects4.EXTEND();
	    x_assoc_objects4(l_count) := l_assoc_object4;
	    x_assoc_objects5.EXTEND();
	    x_assoc_objects5(l_count) := l_assoc_object5;
	    x_assoc_names.EXTEND();
	    x_assoc_names(l_count) := l_assoc_name;
	    x_assoc_codes.EXTEND();
	    x_assoc_codes(l_count) := l_assoc_code;

            l_count := l_count + 1;
         END LOOP;

      END IF;

      --******************* Real Logic End *********************

      -- Standard call to get message count and if count=1, get the message
      Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       Fnd_Msg_Pub.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Associations;

FUNCTION Get_Association_NameAndCode(p_content_item_id  IN NUMBER,
                                     p_citem_version_id IN NUMBER,
                                     p_assoc_type_code  IN VARCHAR2,
                                     p_assoc_object1    IN VARCHAR2,
                                     p_assoc_object2    IN VARCHAR2,
                                     p_assoc_object3    IN VARCHAR2,
                                     p_assoc_object4    IN VARCHAR2,
                                     p_assoc_object5    IN VARCHAR2
                                     )
RETURN VARCHAR2
IS
  l_assoc_name       VARCHAR2(300);
  l_assoc_code       VARCHAR2(80);
  l_result           VARCHAR2(300);
  l_return_status    VARCHAR2(30);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

  pre_plsql_block	 VARCHAR2(10) := 'BEGIN ';
  post_plsql_block	 VARCHAR2(200) := '.Get_Object_Name(:at, :v1, :v2, :v3, :v4, :v5, :xn, :xc, :xret, :xmc, :md); END;';

  CURSOR c_callback(p_assoc_type_code VARCHAR2) IS
    SELECT call_back_pkg
      FROM ibc_association_types_b
     WHERE association_type_code = p_assoc_type_code;

BEGIN

  l_result := NULL;

  FOR r_callback IN c_callback(p_assoc_type_code) LOOP

     BEGIN
	   -- Execute CallBack
       EXECUTE IMMEDIATE (pre_plsql_block || r_callback.CALL_BACK_PKG || post_plsql_block)
       USING p_assoc_type_code,
		     p_assoc_object1, p_assoc_object2,
		     p_assoc_object3, p_assoc_object4,
		     p_assoc_object5, OUT  l_assoc_name, OUT  l_assoc_code,
		     OUT l_return_status, OUT  l_msg_count, OUT  l_msg_data;
     EXCEPTION
       WHEN OTHERS THEN
          IF (SQLCODE = -6550) THEN
             IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	             Fnd_Message.Set_Name('IBC', 'IBC_CALL_BACK_PKG_INVALID');
	             Fnd_Message.Set_token('CALL_BACK_PKG', r_callback.CALL_BACK_PKG);
	             Fnd_Msg_Pub.ADD;
	          END IF;
		      RAISE Fnd_Api.G_EXC_ERROR;
	      ELSE
		    RAISE;
	      END IF;
     END;

  END LOOP;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*
    DBMS_OUTPUT.put_line('Errors FOUND '|| l_msg_data);
    for i in 0..l_msg_count loop
       DBMS_OUTPUT.put_line(FND_MSG_PUB.get(i,FND_API.G_FALSE));
    end loop;
    */
    l_result := NULL;
  ELSE
    l_result := l_assoc_code || '|' || l_assoc_name;
  END IF;

  RETURN l_result;

EXCEPTION
  WHEN OTHERS THEN
    l_result := NULL;
    RETURN l_result;

END Get_Association_NameAndCode;


END Ibc_Associations_Grp;

/
