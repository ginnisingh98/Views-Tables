--------------------------------------------------------
--  DDL for Package Body IBC_STYLESHEETS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_STYLESHEETS_GRP" as
/* $Header: ibcgsshb.pls 120.2 2005/12/29 04:59:26 hsaiyed noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBC_STYLESHEETS_GRP';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ibcgsshb.pls';

/***********************************************************************************
 *************************** Private Procedures ************************************
 ***********************************************************************************/

PROCEDURE Validate_StyleSheetItem (
	p_init_msg_list		IN	VARCHAR2,
	p_stylesheet_item_id	IN	NUMBER,
	x_live_citem_version_id	OUT	NOCOPY NUMBER,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_content_item_status	VARCHAR2(30);
--
	CURSOR Get_Citem IS
	select LIVE_CITEM_VERSION_ID, CONTENT_ITEM_STATUS
	from IBC_CONTENT_ITEMS
	where content_item_id = p_stylesheet_item_id;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN Get_Citem;
	FETCH Get_Citem INTO x_live_citem_version_id, l_content_item_status;
	-- check if p_content_item_id is valid
	IF Get_Citem%NOTFOUND THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.Set_Name('IBC', 'INVALID_STYLESHEET_ITEM_ID');
	       FND_MESSAGE.Set_token('STYLESHEET_ITEM_ID', p_stylesheet_item_id);
               FND_MSG_PUB.ADD;
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
    CLOSE Get_Citem;

    -- check if content_item_status is APPROVED
    IF (l_content_item_status IS NULL OR
	l_content_item_status <> IBC_UTILITIES_PUB.G_STI_APPROVED) THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.Set_Name('IBC', 'IBC_STYLESHEET_NOT_APPROVED');
	   FND_MESSAGE.Set_token('STYLESHEET_ITEM_ID', p_stylesheet_item_id);
	   FND_MSG_PUB.ADD;
	END IF;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Validate_StyleSheetItem;


PROCEDURE Validate_Start_End_Date (
	p_init_msg_list		IN	VARCHAR2,
	p_stylesheet_item_id	IN	NUMBER,
	p_stylesheet_version_id	IN	NUMBER,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_start_date	DATE;
	l_end_date	DATE;
--
	CURSOR Get_Citem_Version IS
	select START_DATE, END_DATE
	from IBC_CITEM_VERSIONS_B
	where CITEM_VERSION_ID = p_stylesheet_version_id;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN Get_Citem_Version;
	FETCH Get_Citem_Version INTO l_start_date, l_end_date;
    CLOSE Get_Citem_Version;

    -- Check Profile if availabe date is enforced
    IF (FND_PROFILE.Value('IBC_ENFORCE_AVAILABLE_DATE') IS NULL) OR
       (FND_PROFILE.Value('IBC_ENFORCE_AVAILABLE_DATE') = 'Y') THEN
       IF (NVL(l_start_date, SYSDATE) > SYSDATE) THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('IBC', 'IBC_STYLESHEET_NOT_AVAILABLE');
	     FND_MESSAGE.Set_token('STYLESHEET_ITEM_ID', p_stylesheet_item_id);
	     FND_MESSAGE.Set_token('START_DATE', l_start_date);
	     FND_MSG_PUB.ADD;
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- Check Profile if expiration date is enforced
    IF (FND_PROFILE.Value('IBC_ENFORCE_EXPIRATION_DATE') IS NULL) OR
       (FND_PROFILE.Value('IBC_ENFORCE_EXPIRATION_DATE') = 'Y') THEN
       IF (NVL(l_end_date, SYSDATE) < SYSDATE) THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('IBC', 'IBC_STYLESHEET_EXPIRED');
	     FND_MESSAGE.Set_token('STYLESHEET_ITEM_ID', p_stylesheet_item_id);
	     FND_MESSAGE.Set_token('END_DATE', l_end_date);
	     FND_MSG_PUB.ADD;
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Validate_Start_End_Date;



PROCEDURE Get_StyleSheet_Private (
	p_init_msg_list		IN	VARCHAR2,
	p_stylesheet_item_id	IN	NUMBER,
	p_stylesheet_label_code	IN	VARCHAR2,
	x_stylesheet		OUT	NOCOPY BLOB,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_live_citem_version_id NUMBER;
	l_citem_version_id	NUMBER;
--
	CURSOR Get_Citem_Ver_By_Label IS
	select citem_version_id
	from IBC_CITEM_VERSION_LABELS
	where label_code = p_stylesheet_label_code and
	      content_item_id = p_stylesheet_item_id;

	CURSOR Get_StyleSheet IS
	select f.FILE_DATA
	from FND_LOBS f, IBC_CITEM_VERSIONS_VL v
	where v.CITEM_VERSION_ID = l_citem_version_id
	and v.ATTACHMENT_FILE_ID = f.FILE_ID;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************
      Validate_StyleSheetItem (
		p_init_msg_list =>		p_init_msg_list,
		p_stylesheet_item_id =>		p_stylesheet_item_id,
		x_live_citem_version_id	=>	l_live_citem_version_id,
		x_return_status =>		x_return_status,
		x_msg_count =>			x_msg_count,
		x_msg_data =>			x_msg_data
      );
      -- Content Item requested is not valid
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;

	-- Check if there is a label for this content item
	IF (p_stylesheet_label_code is NULL) THEN
	   l_citem_version_id := l_live_citem_version_id;
	ELSE
           OPEN Get_Citem_Ver_By_Label;
	      FETCH Get_Citem_Ver_By_Label INTO l_citem_version_id;
	      -- Label doesn't exist for this content item id
	      IF (Get_Citem_Ver_By_Label%NOTFOUND) THEN
		-- Validate Label
		IF (Ibc_Validate_Pvt.isValidLabel(p_stylesheet_label_code) = FND_API.g_false) THEN
		   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		      FND_MESSAGE.Set_Name('IBC', 'INVALID_LABEL_CODE');
	              FND_MESSAGE.Set_token('LABEL_CODE', p_stylesheet_label_code);
                      FND_MSG_PUB.ADD;
	           END IF;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;
	        x_stylesheet := NULL;
		return;
	      END IF;
           CLOSE Get_Citem_Ver_By_Label;
	END IF;

        -- Check if stylesheet is available yet or expired
	Validate_Start_End_Date (
	   p_init_msg_list =>		p_init_msg_list,
	   p_stylesheet_item_id =>	p_stylesheet_item_id,
	   p_stylesheet_version_id =>	l_citem_version_id,
	   x_return_status =>		x_return_status,
           x_msg_count =>		x_msg_count,
           x_msg_data =>		x_msg_data
       );
       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Retrieve Stylesheet binary file
       OPEN Get_StyleSheet;
	   FETCH Get_StyleSheet INTO x_stylesheet;
       CLOSE Get_StyleSheet;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_StyleSheet_Private;



/***********************************************************************************
 *************************** Public Procedures *************************************
 ***********************************************************************************/

PROCEDURE Get_Approved_Default_StyleSht (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_content_item_id		IN	NUMBER,
	p_stylesheet_label_code		IN	VARCHAR2,
	x_stylesheet			OUT	NOCOPY BLOB,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(40)   := 'Get_Approved_Default_StyleSht';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_stylesheet_id		NUMBER;
--
	CURSOR Get_StyleSheet_Id IS
	select s.CONTENT_ITEM_ID
	from IBC_STYLESHEETS s, IBC_CONTENT_ITEMS i
	where i.CONTENT_ITEM_ID = p_content_item_id
        and i.CONTENT_TYPE_CODE = s.CONTENT_TYPE_CODE
	and s.DEFAULT_STYLESHEET_FLAG = FND_API.G_TRUE;

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

      OPEN Get_StyleSheet_Id;
	FETCH Get_StyleSheet_Id INTO l_stylesheet_id;
	-- check if default style sheet exists
	IF Get_StyleSheet_Id%NOTFOUND THEN
           x_stylesheet := NULL;
           return;
	END IF;
      CLOSE Get_StyleSheet_Id;

      Get_StyleSheet_Private (
	p_init_msg_list	=>		p_init_msg_list,
	p_stylesheet_item_id =>		l_stylesheet_id,
	p_stylesheet_label_code =>	p_stylesheet_label_code,
	x_stylesheet =>			x_stylesheet,
	x_return_status	=>		x_return_status,
        x_msg_count =>			x_msg_count,
        x_msg_data =>			x_msg_data
      );

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
END Get_Approved_Default_StyleSht;


PROCEDURE Get_Apprv_Default_StyleSht_Id(
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_content_item_id		IN	NUMBER,
	p_stylesheet_label_code		IN	VARCHAR2,
	x_stylesheet_id			OUT NOCOPY      NUMBER,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(40)   := 'Get_Apprv_Default_StyleSht_Id';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_stylesheet_id		NUMBER;
--
	CURSOR Get_StyleSheet_Id IS
	select s.CONTENT_ITEM_ID
	from IBC_STYLESHEETS s, IBC_CONTENT_ITEMS i
	where i.CONTENT_ITEM_ID = p_content_item_id
        and i.CONTENT_TYPE_CODE = s.CONTENT_TYPE_CODE
	and s.DEFAULT_STYLESHEET_FLAG = FND_API.G_TRUE;

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

      OPEN Get_StyleSheet_Id;
	FETCH Get_StyleSheet_Id INTO x_stylesheet_id;
	-- check if default style sheet exists
	IF Get_StyleSheet_Id%NOTFOUND THEN
           x_stylesheet_id := NULL;
           return;
	END IF;
      CLOSE Get_StyleSheet_Id;

      --******************* Real Logic End ***********************


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
END Get_Apprv_Default_StyleSht_Id;



PROCEDURE Get_Approved_StyleSheet (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_stylesheet_item_id		IN	NUMBER,
	p_stylesheet_label_code		IN	VARCHAR2,
	x_stylesheet			OUT	NOCOPY BLOB,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(40)   := 'Get_Approved_StyleSheet';
	l_api_version		CONSTANT NUMBER := 1.0;
--

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

      Get_StyleSheet_Private (
	p_init_msg_list	=>		p_init_msg_list,
	p_stylesheet_item_id =>		p_stylesheet_item_id,
	p_stylesheet_label_code =>	p_stylesheet_label_code,
	x_stylesheet =>			x_stylesheet,
	x_return_status	=>		x_return_status,
        x_msg_count =>			x_msg_count,
        x_msg_data =>			x_msg_data
      );

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
END Get_Approved_StyleSheet;



PROCEDURE Get_Approved_StyleSht_RC (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2,
	p_stylesheet_ref_code		IN	VARCHAR2,
	p_stylesheet_label_code		IN	VARCHAR2,
	x_stylesheet			OUT	NOCOPY BLOB,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(40)   := 'Get_Approved_StyleSht_RC';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_stylesheet_id		NUMBER;
--
	CURSOR Get_StyleSheet_Id IS
	select CONTENT_ITEM_ID
	from IBC_CONTENT_ITEMS
	where ITEM_REFERENCE_CODE = p_stylesheet_ref_code;

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

      OPEN Get_StyleSheet_Id;
	FETCH Get_StyleSheet_Id INTO l_stylesheet_id;
	IF Get_StyleSheet_Id%NOTFOUND THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.Set_Name('IBC', 'IBC_STYLESHT_RC_NOT_FOUND');
               FND_MESSAGE.Set_token('REF_CODE', p_stylesheet_ref_code);
               FND_MSG_PUB.ADD;
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
      CLOSE Get_StyleSheet_Id;

      Get_StyleSheet_Private (
	p_init_msg_list	=>		p_init_msg_list,
	p_stylesheet_item_id =>		l_stylesheet_id,
	p_stylesheet_label_code =>	p_stylesheet_label_code,
	x_stylesheet =>			x_stylesheet,
	x_return_status	=>		x_return_status,
        x_msg_count =>			x_msg_count,
        x_msg_data =>			x_msg_data
      );

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
END Get_Approved_StyleSht_RC;


-- -----------------------------------------------------------------
-- Return the stylesheets associated with the content type of the
-- given content item.
-- If there is no label-version mapping for a particular stylesheet,
-- or the stylesheet does not satisfy all the Runtimer delivery
-- requirement, that stylesheet item will NOT be included in the list returned.
-- -----------------------------------------------------------------
PROCEDURE Get_StyleSheet_Items (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id		IN	NUMBER,
	p_stylesheets_label_code	IN	VARCHAR2 DEFAULT NULL,
	x_stylesheet_item_clobs		OUT NOCOPY	JTF_CLOB_TABLE,
	x_stylesheet_item_ids		OUT NOCOPY	JTF_NUMBER_TABLE,
        x_stylesheet_lang_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status			OUT NOCOPY	VARCHAR2,
       	x_msg_count			OUT NOCOPY	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(40)   := 'Get_StyleSheet_Items';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_in_citem_ids		JTF_NUMBER_TABLE;
	l_in_labels		JTF_VARCHAR2_TABLE_100;
	l_in_lang_codes		JTF_VARCHAR2_TABLE_100;
--
	l_out_labels		JTF_VARCHAR2_TABLE_100;
--
	CURSOR Get_StyleSheet_Ids IS
	select s.CONTENT_ITEM_ID, p_stylesheets_label_code as LABEL,
	       userenv('LANG') as LANG
	from IBC_STYLESHEETS s, IBC_CONTENT_ITEMS i
	where i.CONTENT_ITEM_ID = p_content_item_id
        and i.CONTENT_TYPE_CODE = s.CONTENT_TYPE_CODE;

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

	-- // Bulk fetch stylesheet item ids, labels, lang codes into array.
	OPEN Get_StyleSheet_Ids;
	   FETCH Get_StyleSheet_Ids BULK COLLECT INTO l_in_citem_ids, l_in_labels, l_in_lang_codes;

	   -- // Validate p_content_item_id
	   IF (Get_StyleSheet_Ids%NOTFOUND) THEN
	      IF (Ibc_Validate_Pvt.isValidCitem(p_content_item_id) = FND_API.g_false) THEN
	         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('IBC', 'INVALID_CITEM_ID');
	            FND_MESSAGE.Set_token('CITEM_ID', p_content_item_id);
                    FND_MSG_PUB.ADD;
	         END IF;
	         RAISE FND_API.G_EXC_ERROR;
	      END IF;
           END IF;
	CLOSE Get_StyleSheet_Ids;

        -- // Call Load_Translated_Content_Items (do VALIDATE dates)
	IBC_CITEM_RUNTIME_PVT.Load_Translated_Content_Items (
	   p_init_msg_list	=>	p_init_msg_list
	   ,p_content_item_ids	=>	l_in_citem_ids
	   ,p_label_codes	=>	l_in_labels
	   ,p_lang_codes	=>	l_in_lang_codes
	   ,p_validate_dates	=>	FND_API.G_TRUE    -- // validate dates
	   ,x_clobs		=>	x_stylesheet_item_clobs
	   ,x_content_item_ids	=>	x_stylesheet_item_ids
	   ,x_label_codes	=>	l_out_labels
	   ,x_lang_codes	=>	x_stylesheet_lang_codes
	   ,x_return_status	=>	x_return_status
           ,x_msg_count		=>	x_msg_count
           ,x_msg_data		=>	x_msg_data
       );
       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- // List of stylesheets returned is 0, validate Label Code
       IF (x_stylesheet_item_ids.COUNT = 0) THEN
          IF (Ibc_Validate_Pvt.isValidLabel(p_stylesheets_label_code) = FND_API.g_false) THEN
	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('IBC', 'INVALID_LABEL_CODE');
	        FND_MESSAGE.Set_token('LABEL_CODE', p_stylesheets_label_code);
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
END Get_StyleSheet_Items;





END IBC_STYLESHEETS_GRP;

/
