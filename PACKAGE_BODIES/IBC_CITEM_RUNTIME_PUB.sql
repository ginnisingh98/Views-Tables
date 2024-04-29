--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_RUNTIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_RUNTIME_PUB" as
/* $Header: ibcpcirb.pls 120.0 2005/05/27 15:06:21 appldev noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBC_CITEM_RUNTIME_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ibcpcirb.pls';


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citems_Meta_By_Assoc
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a list of content items with their meta-data
--		   based on association.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_association_type_code	IN  VARCHAR2  Required
--		   p_associated_object_val1	IN  VARCHAR2  Required
--		   p_associated_object_val2	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val3	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val4	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val5	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_meta_tbl	OUT CONTENT_ITEM_META_TBL
--------------------------------------------------------------------------------
PROCEDURE Get_Citems_Meta_By_Assoc (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_association_type_code		IN    	VARCHAR2,
	p_associated_object_val1	IN	VARCHAR2,
	p_associated_object_val2	IN	VARCHAR2,
	p_associated_object_val3	IN	VARCHAR2,
	p_associated_object_val4	IN	VARCHAR2,
	p_associated_object_val5	IN	VARCHAR2,
	p_label_code			IN	VARCHAR2,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2,
	x_content_item_meta_tbl		OUT NOCOPY CONTENT_ITEM_META_TBL
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Citems_Meta_By_Assoc';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_citem_count		NUMBER := 1;
	l_citem_meta_rec	Content_Item_Meta_Rec;
	l_item_found		VARCHAR2(1) := FND_API.G_TRUE;
--
	CURSOR Get_Citems_By_Assoc IS
	select CONTENT_ITEM_ID
	from IBC_ASSOCIATIONS
	where ASSOCIATION_TYPE_CODE = p_association_type_code
        and ASSOCIATED_OBJECT_VAL1 = p_associated_object_val1
	and NVL(ASSOCIATED_OBJECT_VAL2, '0') = NVL(p_associated_object_val2, '0')
	and NVL(ASSOCIATED_OBJECT_VAL3, '0') = NVL(p_associated_object_val3, '0')
	and NVL(ASSOCIATED_OBJECT_VAL4, '0') = NVL(p_associated_object_val4, '0')
	and NVL(ASSOCIATED_OBJECT_VAL5, '0') = NVL(p_associated_object_val5, '0');

BEGIN
      -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
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

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      x_content_item_meta_tbl := CONTENT_ITEM_META_TBL();

      FOR citem_id_rec IN Get_Citems_By_Assoc LOOP

	IBC_CITEM_RUNTIME_PVT.Get_Citem_Meta(	p_init_msg_list,
						citem_id_rec.content_item_id,
						p_label_code,
						l_citem_meta_rec,
						l_item_found,
						x_return_status,
						x_msg_count,
						x_msg_data);
	-- Content Item is not valid
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	  RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF (l_item_found = FND_API.G_TRUE) THEN
	   x_content_item_meta_tbl.EXTEND();
	   x_content_item_meta_tbl(l_citem_count) := l_citem_meta_rec;
	   l_citem_count := l_citem_count + 1;
	END IF;

      END LOOP;

      -- If no matches, check if p_association_type_code is valid
      IF (l_citem_count = 1) THEN
	IF (Ibc_Validate_Pvt.isValidAssocType(p_association_type_code) = FND_API.g_false) THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.Set_Name('IBC', 'INVALID_ASSOC_TYPE_CODE');
	       FND_MESSAGE.Set_token('ASSOC_TYPE_CODE', p_association_type_code);
               FND_MSG_PUB.ADD;
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
      END IF;

      --******************* Real Logic End ***********************

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citems_Meta_By_Assoc;


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citems_Meta_By_Assoc_Ctyp
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a list of content items with their meta-data
--		   based on association and content type.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_association_type_code	IN  VARCHAR2  Required
--		   p_associated_object_val1	IN  VARCHAR2  Required
--		   p_associated_object_val2	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val3	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val4	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val5	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_content_type_code		IN  VARCHAR2  Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_meta_tbl	OUT CONTENT_ITEM_META_TBL
--------------------------------------------------------------------------------
PROCEDURE Get_Citems_Meta_By_Assoc_Ctyp (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_association_type_code		IN    	VARCHAR2,
	p_associated_object_val1	IN	VARCHAR2,
	p_associated_object_val2	IN	VARCHAR2,
	p_associated_object_val3	IN	VARCHAR2,
	p_associated_object_val4	IN	VARCHAR2,
	p_associated_object_val5	IN	VARCHAR2,
	p_content_type_code		IN    	VARCHAR2,
	p_label_code			IN	VARCHAR2,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2,
	x_content_item_meta_tbl		OUT NOCOPY CONTENT_ITEM_META_TBL
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Citems_Meta_By_Assoc_Ctype';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_citem_count		NUMBER := 1;
	l_citem_meta_rec	Content_Item_Meta_Rec;
        l_item_found		VARCHAR2(1) := FND_API.g_true;
	l_invalid_input		VARCHAR2(1) := FND_API.g_false;
--
	CURSOR Get_Citems_By_Assoc_Ctype IS
	select c.CONTENT_ITEM_ID
	from IBC_ASSOCIATIONS a, IBC_CONTENT_ITEMS c
	where a.ASSOCIATION_TYPE_CODE = p_association_type_code
        and a.ASSOCIATED_OBJECT_VAL1 = p_associated_object_val1
	and NVL(a.ASSOCIATED_OBJECT_VAL2, '0') = NVL(p_associated_object_val2, '0')
	and NVL(a.ASSOCIATED_OBJECT_VAL3, '0') = NVL(p_associated_object_val3, '0')
	and NVL(a.ASSOCIATED_OBJECT_VAL4, '0') = NVL(p_associated_object_val4, '0')
	and NVL(a.ASSOCIATED_OBJECT_VAL5, '0') = NVL(p_associated_object_val5, '0')
	and a.CONTENT_ITEM_ID = c.CONTENT_ITEM_ID
	and c.CONTENT_TYPE_CODE = p_content_type_code;

BEGIN
      -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
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

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      x_content_item_meta_tbl := CONTENT_ITEM_META_TBL();

      FOR citem_id_rec IN Get_Citems_By_Assoc_Ctype LOOP

	IBC_CITEM_RUNTIME_PVT.Get_Citem_Meta(	p_init_msg_list,
						citem_id_rec.content_item_id,
						p_label_code,
						l_citem_meta_rec,
					        l_item_found,
						x_return_status,
						x_msg_count,
						x_msg_data);
	-- Content Item is not valid
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	  RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF (l_item_found = FND_API.G_TRUE) THEN
	   x_content_item_meta_tbl.EXTEND();
	   x_content_item_meta_tbl(l_citem_count) := l_citem_meta_rec;
	   l_citem_count := l_citem_count + 1;
	END IF;

      END LOOP;

      -- If no matches, check if p_association_type_code, p_content_type_code are valid
      IF (l_citem_count = 1) THEN
	IF (Ibc_Validate_Pvt.isValidAssocType(p_association_type_code) = FND_API.g_false) THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.Set_Name('IBC', 'INVALID_ASSOC_TYPE_CODE');
	       FND_MESSAGE.Set_token('ASSOC_TYPE_CODE', p_association_type_code);
               FND_MSG_PUB.ADD;
	   END IF;
	   l_invalid_input := FND_API.g_true;
	END IF;
	IF (Ibc_Validate_Pvt.isValidCType(p_content_type_code) = FND_API.g_false) THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.Set_Name('IBC', 'INVALID_CONTENT_TYPE_CODE');
	       FND_MESSAGE.Set_token('CONTENT_TYPE_CODE', p_content_type_code);
               FND_MSG_PUB.ADD;
	   END IF;
	   l_invalid_input := FND_API.g_true;
	END IF;
	IF (l_invalid_input = FND_API.g_true) THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
      END IF;

      --******************* Real Logic End ***********************

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citems_Meta_By_Assoc_Ctyp;



--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citems_Meta
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a list of content items with their meta-data
--		   based on the given list of content item ids.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_ids		IN  CONTENT_ITEM_ID_TBL Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_meta_tbl	OUT CONTENT_ITEM_META_TBL
--------------------------------------------------------------------------------
PROCEDURE Get_Citems_Meta (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2,
	p_content_item_ids	IN	CONTENT_ITEM_ID_TBL,
	p_label_code		IN	VARCHAR2,
	x_return_status        	OUT NOCOPY   	VARCHAR2,
        x_msg_count            	OUT NOCOPY    	NUMBER,
        x_msg_data             	OUT NOCOPY   	VARCHAR2,
	x_content_item_meta_tbl	OUT NOCOPY CONTENT_ITEM_META_TBL
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Citems_Meta';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_citem_count 		NUMBER := 1;
	l_citem_id_count	NUMBER := 1;
	l_citem_meta_rec	Content_Item_Meta_Rec;
	l_item_found		VARCHAR2(1) := FND_API.G_TRUE;

BEGIN
      -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
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

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      x_content_item_meta_tbl := CONTENT_ITEM_META_TBL();

      -- Validate each content item id passed in
      WHILE l_citem_id_count <= p_content_item_ids.COUNT LOOP

	IBC_CITEM_RUNTIME_PVT.Get_Citem_Meta(	p_init_msg_list,
						p_content_item_ids(l_citem_id_count),
						p_label_code,
						l_citem_meta_rec,
						l_item_found,
						x_return_status,
						x_msg_count,
						x_msg_data);
	-- Content item is not valid
	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF (l_item_found = FND_API.G_TRUE) THEN
	   x_content_item_meta_tbl.EXTEND();
	   x_content_item_meta_tbl(l_citem_count) := l_citem_meta_rec;
	   l_citem_count := l_citem_count + 1;
	END IF;

	l_citem_id_count := l_citem_id_count + 1;
      END LOOP;

      --******************* Real Logic End *********************

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citems_Meta;


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Meta
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with just the meta-data.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_meta		OUT CONTENT_ITEM_META_REC
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Meta (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2,
	x_return_status        	OUT NOCOPY   	VARCHAR2,
        x_msg_count            	OUT NOCOPY    	NUMBER,
        x_msg_data             	OUT NOCOPY   	VARCHAR2,
	x_content_item_meta	OUT NOCOPY CONTENT_ITEM_META_REC
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30) := 'Get_Citem_Meta';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_item_found		VARCHAR2(1) := FND_API.G_TRUE;

BEGIN
      -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
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

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      IBC_CITEM_RUNTIME_PVT.Get_Citem_Meta(	p_init_msg_list,
						p_content_item_id,
						p_label_code,
						x_content_item_meta,
						l_item_found,
						x_return_status,
						x_msg_count,
						x_msg_data);
      -- Content Item is not valid
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      --******************* Real Logic End *********************

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Meta;


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Basic
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with basic data.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_basic		OUT CONTENT_ITEM_BASIC_REC
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Basic (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_content_item_id		IN	NUMBER,
	p_label_code			IN	VARCHAR2,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2,
	x_content_item_basic		OUT NOCOPY CONTENT_ITEM_BASIC_REC
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Citem_Basic';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_live_citem_version_id		NUMBER;
	l_citem_version_id		NUMBER;
	l_content_type_code		VARCHAR2(100);
	l_item_reference_code		VARCHAR2(100);
	l_encrypt_flag			VARCHAR2(1);

	l_attribute_file_id		NUMBER;
	l_attribute_bundle		CLOB := NULL;
	l_mime_type			VARCHAR2(30);
	l_count				NUMBER := 1;
--
	CURSOR Get_Citem_Ver_By_Label IS
	select citem_version_id
	from IBC_CITEM_VERSION_LABELS
	where label_code = p_label_code and
	      content_item_id = p_content_item_id;

	CURSOR Get_Citem_Meta_Csr IS
	select ATTRIBUTE_FILE_ID, CONTENT_ITEM_NAME, DESCRIPTION,
	       DEFAULT_RENDITION_MIME_TYPE, ATTACHMENT_FILE_NAME, ATTACHMENT_FILE_ID
	from IBC_CITEM_VERSIONS_TL
        where citem_version_id = l_citem_version_id
        and language = userenv('LANG');

	CURSOR Get_Renditions IS
	select FILE_ID, FILE_NAME, MIME_TYPE
	from IBC_RENDITIONS
	where citem_version_id = l_citem_version_id and
        language = userenv('LANG');

	CURSOR Get_Rendition_Name IS
	SELECT NVL(DESCRIPTION, MEANING)
	FROM FND_LOOKUP_VALUES
	WHERE LOOKUP_TYPE = IBC_UTILITIES_PVT.G_REND_LOOKUP_TYPE
	AND LANGUAGE = userenv('LANG')
	AND LOOKUP_CODE = l_mime_type;

	CURSOR Get_Compound_Item_Ref IS
	select ATTRIBUTE_TYPE_CODE, CONTENT_ITEM_ID
	from IBC_COMPOUND_RELATIONS
	where CITEM_VERSION_ID = l_citem_version_id
	order by SORT_ORDER;

BEGIN
      -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
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

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

	IBC_CITEM_RUNTIME_PVT.Validate_Citem (
		p_init_msg_list =>		p_init_msg_list,
		p_content_item_id =>		p_content_item_id,
		x_content_type_code =>		l_content_type_code,
		x_item_reference_code =>	l_item_reference_code,
		x_live_citem_version_id	=>	l_live_citem_version_id,
		x_encrypt_flag =>		l_encrypt_flag,
		x_return_status =>		x_return_status,
		x_msg_count =>			x_msg_count,
		x_msg_data =>			x_msg_data
	);
	-- Content Item requested is not valid
	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	x_content_item_basic.content_item_id := p_content_item_id;
	x_content_item_basic.content_type_code := l_content_type_code;
	x_content_item_basic.item_reference_code := l_item_reference_code;
	x_content_item_basic.encrypt_flag := l_encrypt_flag;

	-- Check if there is a label for this content item
	IF (p_label_code is NULL) THEN
	   l_citem_version_id := l_live_citem_version_id;
	ELSE
           OPEN Get_Citem_Ver_By_Label;
	      FETCH Get_Citem_Ver_By_Label INTO l_citem_version_id;
	      -- Label doesn't exist for this content item id
	      IF (Get_Citem_Ver_By_Label%NOTFOUND) THEN
		-- Validate Label
		IF (Ibc_Validate_Pvt.isValidLabel(p_label_code) = FND_API.g_false) THEN
		   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		      FND_MESSAGE.Set_Name('IBC', 'INVALID_LABEL_CODE');
	              FND_MESSAGE.Set_token('LABEL_CODE', p_label_code);
                      FND_MSG_PUB.ADD;
	           END IF;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;
	        x_content_item_basic := NULL;
		return;
	      END IF;
           CLOSE Get_Citem_Ver_By_Label;
	END IF;

	-- check start/end date
        IBC_CITEM_RUNTIME_PVT.Validate_Start_End_Date (
		p_init_msg_list =>		p_init_msg_list,
		p_content_item_id =>		p_content_item_id,
		p_citem_version_id =>		l_citem_version_id,
	        x_version_number =>		x_content_item_basic.version_number,
		x_start_date =>			x_content_item_basic.available_date,
		x_end_date =>			x_content_item_basic.expiration_date,
		x_return_status =>		x_return_status,
		x_msg_count =>			x_msg_count,
		x_msg_data =>			x_msg_data
	);
	-- Start/End date not valid
	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Retrieve content item meta-data
	OPEN Get_Citem_Meta_Csr;
	   FETCH Get_Citem_Meta_Csr INTO l_attribute_file_id,
					 x_content_item_basic.content_item_name,
					 x_content_item_basic.description,
                                         l_mime_type,
					 x_content_item_basic.attachment_file_name,
					 x_content_item_basic.attachment_file_id;
        CLOSE Get_Citem_Meta_Csr;

	x_content_item_basic.default_mime_type := LOWER(l_mime_type);
	-- Retrieve default rendition name
	IF (l_mime_type IS NOT NULL) THEN
	   OPEN Get_Rendition_Name;
	   FETCH Get_Rendition_Name INTO x_content_item_basic.default_rendition_name;
	   IF Get_Rendition_Name%NOTFOUND THEN
	      CLOSE Get_Rendition_Name;
	      l_mime_type := IBC_UTILITIES_PVT.G_REND_UNKNOWN_MIME;
	      OPEN Get_Rendition_Name;
	         FETCH Get_Rendition_Name INTO x_content_item_basic.default_rendition_name;
	      CLOSE Get_Rendition_Name;
	   ELSE
	      CLOSE Get_Rendition_Name;
	   END IF;
	ELSE
	   x_content_item_basic.default_rendition_name := NULL;
	END IF;

        -- Retrieve renditions info
        x_content_item_basic.rendition_file_names := Rendition_File_Name_Tbl();
	x_content_item_basic.rendition_file_ids := Rendition_File_Id_Tbl();
	x_content_item_basic.rendition_mime_types := Rendition_Mime_Type_Tbl();
        x_content_item_basic.rendition_names := Rendition_Name_Tbl();
        FOR rendition_rec IN Get_Renditions LOOP
           x_content_item_basic.rendition_file_names.EXTEND();
	   x_content_item_basic.rendition_file_ids.EXTEND();
	   x_content_item_basic.rendition_mime_types.EXTEND();
           x_content_item_basic.rendition_names.EXTEND();

	   x_content_item_basic.rendition_file_names(l_count) := rendition_rec.file_name;
	   x_content_item_basic.rendition_file_ids(l_count) := rendition_rec.file_id;
	   x_content_item_basic.rendition_mime_types(l_count) := LOWER(rendition_rec.mime_type);

	   l_mime_type := rendition_rec.mime_type;
	   OPEN Get_Rendition_Name;
	   FETCH Get_Rendition_Name INTO x_content_item_basic.rendition_names(l_count);
	   IF Get_Rendition_Name%NOTFOUND THEN
	      CLOSE Get_Rendition_Name;
	      l_mime_type := IBC_UTILITIES_PVT.G_REND_UNKNOWN_MIME;
	      OPEN Get_Rendition_Name;
	         FETCH Get_Rendition_Name INTO x_content_item_basic.rendition_names(l_count);
	      CLOSE Get_Rendition_Name;
	   ELSE
	      CLOSE Get_Rendition_Name;
	   END IF;

	   l_count := l_count + 1;
        END LOOP;

	-- Retrieve attribute bundle and build output xml
	IF (l_attribute_file_id is NULL) THEN
	   x_content_item_basic.attribute_bundle := NULL;
	ELSE
	   DBMS_LOB.CREATETEMPORARY(l_attribute_bundle, TRUE);
           IBC_UTILITIES_PVT.Build_Citem_Open_Tag (
		p_content_type_code	=>  l_content_type_code
		,p_content_item_id	=>  p_content_item_id
		,p_version_number	=>  x_content_item_basic.version_number
		,p_item_reference_code	=>  l_item_reference_code
		,p_item_label		=>  p_label_code
		,p_xml_clob_loc		=>  l_attribute_bundle
	   );
	   IBC_UTILITIES_PVT.Build_Attribute_Bundle (
		l_attribute_file_id,	-- p_file_id IN NUMBER
		l_attribute_bundle	-- p_xml_clob_loc IN OUT CLOB
	   );
	   IBC_UTILITIES_PVT.Build_Close_Tag (
		l_content_type_code,	-- p_close_tag IN VARCHAR2
		l_attribute_bundle	-- p_xml_clob_loc IN OUT CLOB
	   );
	   x_content_item_basic.attribute_bundle := l_attribute_bundle;
	END IF;

	-- Retrieve compounded items
	x_content_item_basic.comp_item_attrib_tcodes := Comp_Item_Attrib_Tcode_Tbl();
	x_content_item_basic.comp_item_citem_ids := Comp_Item_Citem_Id_Tbl();
        l_count := 1;
	FOR compound_item_rec IN Get_Compound_Item_Ref LOOP
	   x_content_item_basic.comp_item_attrib_tcodes.EXTEND();
	   x_content_item_basic.comp_item_citem_ids.EXTEND();

	   x_content_item_basic.comp_item_attrib_tcodes(l_count) := compound_item_rec.attribute_type_code;
	   x_content_item_basic.comp_item_citem_ids(l_count) := compound_item_rec.content_item_id;

	   l_count := l_count + 1;
        END LOOP;

      --******************* Real Logic End *********************

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Basic;



--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Basic_Xml
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with basic data as an XML Document.
--		   The item's compounded items are returned as references in
--		   the Xml.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_xml		OUT CLOB
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Basic_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2,
	x_return_status        	OUT NOCOPY   	VARCHAR2,
        x_msg_count            	OUT NOCOPY    	NUMBER,
        x_msg_data             	OUT NOCOPY   	VARCHAR2,
	x_content_item_xml	OUT NOCOPY CLOB
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Citem_Basic_Xml';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	x_num_levels_loaded	NUMBER;
	l_xml_encoding		VARCHAR2(50);
BEGIN
      -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
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

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      DBMS_LOB.CREATETEMPORARY(x_content_item_xml, TRUE);

      l_xml_encoding := '<?xml version="1.0" encoding="'||
                        IBC_UTILITIES_PVT.getEncoding() ||
                        '"?>';
      DBMS_LOB.WRITEAPPEND(x_content_item_xml, LENGTH(l_xml_encoding), l_xml_encoding);

      IBC_CITEM_RUNTIME_PVT.Get_Citem_Xml (
	p_init_msg_list =>	p_init_msg_list,	-- p_init_msg_list IN VARCHAR2
	p_content_item_id =>	p_content_item_id,	-- p_content_item_id IN NUMBER
	p_xml_clob_loc =>	x_content_item_xml,	-- p_xml_clob_loc IN OUT CLOB
	p_num_levels =>		0,			-- p_num_levels IN NUMBER
	p_label_code =>		p_label_code,		-- p_label_code IN VARCHAR2
	p_validate_dates =>	FND_API.G_TRUE,		-- p_validate_dates
	x_num_levels_loaded =>	x_num_levels_loaded,
	x_return_status =>	x_return_status,
	x_msg_count =>		x_msg_count,
	x_msg_data =>		x_msg_data
      );
      -- Content Item is not valid
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      --******************* Real Logic End *********************

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Basic_Xml;


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Deep_Xml
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with full data as an XML Document.
--		   The item's component items are fully expanded in
--		   the Xml rather than as references. If the item's component
--		   in turn has some other components, they will be fully expanded
--		   also.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_xml		OUT CLOB
--		   x_num_levels_loaded		OUT NUMBER
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Deep_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2,
	x_return_status        	OUT NOCOPY VARCHAR2,
        x_msg_count            	OUT NOCOPY NUMBER,
        x_msg_data             	OUT NOCOPY VARCHAR2,
	x_content_item_xml	OUT NOCOPY CLOB,
	x_num_levels_loaded	OUT NOCOPY NUMBER
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Citem_Deep_Xml';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_xml_encoding		VARCHAR2(50);
BEGIN
      -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
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

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      DBMS_LOB.CREATETEMPORARY(x_content_item_xml, TRUE);

      l_xml_encoding := '<?xml version="1.0" encoding="'||
                        IBC_UTILITIES_PVT.getEncoding() ||
                        '"?>';
      DBMS_LOB.WRITEAPPEND(x_content_item_xml, LENGTH(l_xml_encoding), l_xml_encoding);

      IBC_CITEM_RUNTIME_PVT.Get_Citem_Xml (
	p_init_msg_list =>	p_init_msg_list,	-- p_init_msg_list IN VARCHAR2
	p_content_item_id =>	p_content_item_id,	-- p_content_item_id IN NUMBER
	p_xml_clob_loc =>	x_content_item_xml,	-- p_xml_clob_loc IN OUT CLOB
	p_num_levels =>		NULL,			-- p_num_levels IN NUMBER
	p_label_code =>		p_label_code,		-- p_label_code IN VARCHAR2
	p_validate_dates =>	FND_API.G_TRUE,		-- p_validate_dates
	x_num_levels_loaded =>	x_num_levels_loaded,
	x_return_status =>	x_return_status,
	x_msg_count =>		x_msg_count,
	x_msg_data =>		x_msg_data
      );
      -- Content Item is not valid
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      --******************* Real Logic End *********************

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Deep_Xml;


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Deep_Xml
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with full data as an XML Document.
--		   This returns a specific content item version
--		   The item's component items are fully expanded in
--		   the Xml rather than as references. If the item's component
--		   in turn has some other components, they will be fully expanded
--		   also.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_citem_version_id		IN  NUMBER    Required
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_xml		OUT CLOB
--		   x_num_levels_loaded		OUT NUMBER
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Deep_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_citem_version_id 	IN	NUMBER,
	x_return_status        	OUT NOCOPY VARCHAR2,
        x_msg_count            	OUT NOCOPY NUMBER,
        x_msg_data             	OUT NOCOPY VARCHAR2,
	x_content_item_xml	OUT NOCOPY CLOB,
	x_num_levels_loaded	OUT NOCOPY NUMBER
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Citem_Deep_Xml';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_xml_encoding		VARCHAR2(50);
BEGIN
      -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
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

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      DBMS_LOB.CREATETEMPORARY(x_content_item_xml, TRUE);

      l_xml_encoding := '<?xml version="1.0" encoding="'||
                        IBC_UTILITIES_PVT.getEncoding() ||
                        '"?>';
      DBMS_LOB.WRITEAPPEND(x_content_item_xml, LENGTH(l_xml_encoding), l_xml_encoding);

      IBC_CITEM_RUNTIME_PVT.Get_Citem_Xml (
	p_init_msg_list =>	p_init_msg_list,	-- p_init_msg_list IN VARCHAR2
	p_content_item_id =>	p_content_item_id,	-- p_content_item_id IN NUMBER
	p_xml_clob_loc =>	x_content_item_xml,	-- p_xml_clob_loc IN OUT CLOB
	p_num_levels =>	NULL,-- p_num_levels IN NUMBER
	p_citem_version_id  =>	p_citem_version_id, -- p_citem_version_id IN NUMBER
	p_validate_dates =>	FND_API.G_TRUE,	-- p_validate_dates
	x_num_levels_loaded =>x_num_levels_loaded,
	x_return_status =>x_return_status,
	x_msg_count =>x_msg_count,
	x_msg_data =>x_msg_data
      );
      -- Content Item is not valid
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      --******************* Real Logic End *********************

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Deep_Xml;


END IBC_CITEM_RUNTIME_PUB;

/
