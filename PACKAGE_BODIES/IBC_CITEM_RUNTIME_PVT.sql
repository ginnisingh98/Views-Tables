--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_RUNTIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_RUNTIME_PVT" as
/* $Header: ibcvcirb.pls 120.1.12000000.2 2007/06/21 05:23:36 rsatyava ship $ */


-- ******************************************************************************
-- ***** Validation APIs
-- ******************************************************************************

-- --------------------------------------------------------------
-- 1) Validates content item id being valid
-- 2) Validates content item is APPROVED
-- 3) Validates wd_restricted_flag is NOT TRUE
-- Return along the way:
--    * content type code
--    * item reference code
--    * live version id
-- --------------------------------------------------------------
PROCEDURE Validate_Citem (
	p_init_msg_list		IN	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	x_content_type_code	OUT	NOCOPY VARCHAR2,
	x_item_reference_code	OUT	NOCOPY VARCHAR2,
	x_live_citem_version_id	OUT	NOCOPY NUMBER,
	x_encrypt_flag		OUT	NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_wd_restricted_flag	IBC_CONTENT_ITEMS.WD_RESTRICTED_FLAG%TYPE;
	l_content_item_status	IBC_CONTENT_ITEMS.CONTENT_ITEM_STATUS%TYPE;
	l_parent_item_id	NUMBER;
--
	CURSOR Get_Citem IS
	select CONTENT_TYPE_CODE, ITEM_REFERENCE_CODE, WD_RESTRICTED_FLAG, LIVE_CITEM_VERSION_ID,
	       CONTENT_ITEM_STATUS, ENCRYPT_FLAG, PARENT_ITEM_ID
	from IBC_CONTENT_ITEMS
	where content_item_id = p_content_item_id;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN Get_Citem;
	FETCH Get_Citem INTO x_content_type_code, x_item_reference_code,
			     l_wd_restricted_flag, x_live_citem_version_id,
			     l_content_item_status, x_encrypt_flag,
			     l_parent_item_id;
	-- check if p_content_item_id is valid
	IF Get_Citem%NOTFOUND THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.Set_Name('IBC', 'INVALID_CITEM_ID');
	       FND_MESSAGE.Set_token('CITEM_ID', p_content_item_id);
               FND_MSG_PUB.ADD;
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
    CLOSE Get_Citem;

    -- check if content_item_status is APPROVED
    IF (l_content_item_status IS NULL OR
	l_content_item_status <> IBC_UTILITIES_PUB.G_STI_APPROVED) THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.Set_Name('IBC', 'CITEM_NOT_PUBLISHED');
	   -- FND_MESSAGE.Set_token('CITEM_ID', p_content_item_id);
	   FND_MESSAGE.Set_token('CITEM_NAME',IBC_UTILITIES_PVT.get_citem_name(p_content_item_id));
	   FND_MSG_PUB.ADD;
	END IF;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check if wd_restricted_flag is true
    IF (l_wd_restricted_flag = FND_API.G_TRUE) THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.Set_Name('IBC', 'CITEM_NOT_PUBLISHED');
	   -- FND_MESSAGE.Set_token('CITEM_ID', p_content_item_id);
	   FND_MESSAGE.Set_token('CITEM_NAME',IBC_UTILITIES_PVT.get_citem_name(p_content_item_id));
	   FND_MSG_PUB.ADD;
	END IF;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check if parent_item_id is not null (DECIDED NOT REQUIRED)
--    if (p_check_parent_item_id = FND_API.G_TRUE AND
--	l_parent_item_id is NOT NULL) THEN
--	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
--	   FND_MESSAGE.Set_Name('IBC', 'CITEM_IS_ONLY_COMPONENT');
--	   FND_MESSAGE.Set_token('CITEM_ID', p_content_item_id);
--	   FND_MSG_PUB.ADD;
--	END IF;
--	RAISE FND_API.G_EXC_ERROR;
--    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Validate_Citem;


-- --------------------------------------------------------------
-- 1) Validates content item version start date if enforced by
--    profile option, IBC_ENFORCE_AVAILABLE_DATE
-- 2) Validates content item version end date if enforced by
--    profile option, IBC_ENFORCE_EXPIRATION_DATE
--
-- Return along the way:
--    * item version number
--    * item version start date
--    * item version end date
-- --------------------------------------------------------------
PROCEDURE Validate_Start_End_Date (
	p_init_msg_list		IN	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_citem_version_id	IN	NUMBER,
	x_version_number	OUT NOCOPY	NUMBER,
	x_start_date		OUT NOCOPY	DATE,
	x_end_date		OUT NOCOPY	DATE,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	CURSOR Get_Citem_Version IS
	select START_DATE, END_DATE, VERSION_NUMBER
	from IBC_CITEM_VERSIONS_B
	where CITEM_VERSION_ID = p_citem_version_id;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN Get_Citem_Version;
	FETCH Get_Citem_Version INTO x_start_date, x_end_date, x_version_number;
    CLOSE Get_Citem_Version;

       -- Check Profile if availabe date is enforced
       IF (FND_PROFILE.Value('IBC_ENFORCE_AVAILABLE_DATE') IS NULL) OR
          (FND_PROFILE.Value('IBC_ENFORCE_AVAILABLE_DATE') = 'Y') THEN
          IF (NVL(x_start_date, SYSDATE) > SYSDATE) THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('IBC', 'CITEM_NOT_YET_AVAILABLE');
	        FND_MESSAGE.Set_token('CITEM_ID', p_content_item_id);
	        FND_MESSAGE.Set_token('START_DATE', x_start_date);
	        FND_MSG_PUB.ADD;
	     END IF;
	     RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       -- Check Profile if expiration date is enforced
       IF (FND_PROFILE.Value('IBC_ENFORCE_EXPIRATION_DATE') IS NULL) OR
          (FND_PROFILE.Value('IBC_ENFORCE_EXPIRATION_DATE') = 'Y') THEN
          IF (NVL(x_end_date, SYSDATE) < SYSDATE) THEN
	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('IBC', 'CITEM_EXPIRED');
	        FND_MESSAGE.Set_token('CITEM_ID', p_content_item_id);
	        FND_MESSAGE.Set_token('END_DATE', x_end_date);
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




-- ******************************************************************************
-- ***** Retrival APIs
-- ******************************************************************************

-- --------------------------------------------------------------
-- Get Content Item Meta data.
--    * If label is NOT NULL and there is not label-version mapping,
--      x_content_item_meta will be NULL and
--      x_item_found will be FALSE.
-- --------------------------------------------------------------
PROCEDURE Get_Citem_Meta (
	p_init_msg_list		IN	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2,
	x_content_item_meta	OUT	NOCOPY IBC_CITEM_RUNTIME_PUB.CONTENT_ITEM_META_REC,
	x_item_found		OUT NOCOPY	VARCHAR2,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_live_citem_version_id NUMBER;
	l_citem_version_id	NUMBER;
	l_default_mime_type     IBC_CITEM_VERSIONS_TL.DEFAULT_RENDITION_MIME_TYPE%TYPE;
	l_translation_status	IBC_CITEM_VERSIONS_TL.CITEM_TRANSLATION_STATUS%TYPE;
--
	-- // retrieve the labeled version id
	CURSOR Get_Citem_Ver_By_Label IS
	select citem_version_id
	from IBC_CITEM_VERSION_LABELS
	where label_code = p_label_code and
	      content_item_id = p_content_item_id;

	-- // retrieve the session language version translation
	CURSOR Get_Citem_Meta_Csr IS
	select CITEM_TRANSLATION_STATUS, CONTENT_ITEM_NAME, DESCRIPTION, DEFAULT_RENDITION_MIME_TYPE,
	       ATTACHMENT_FILE_NAME, ATTACHMENT_FILE_ID
	from IBC_CITEM_VERSIONS_TL
        where citem_version_id = l_citem_version_id
        and language = userenv('LANG');

	-- // retrieve the based language version translation
	CURSOR Get_Citem_Meta_BLang IS
	select t.CONTENT_ITEM_NAME, t.DESCRIPTION, t.DEFAULT_RENDITION_MIME_TYPE,
	       t.ATTACHMENT_FILE_NAME, t.ATTACHMENT_FILE_ID
	from IBC_CONTENT_ITEMS i, IBC_CITEM_VERSIONS_TL t
	where i.CONTENT_ITEM_ID = p_content_item_id
	and t.citem_version_id = l_citem_version_id
	and t.language = i.BASE_LANGUAGE;

	CURSOR Get_Rendition_Name IS
	SELECT NVL(DESCRIPTION, MEANING)
	FROM FND_LOOKUP_VALUES
	WHERE LOOKUP_TYPE = IBC_UTILITIES_PVT.G_REND_LOOKUP_TYPE
	AND LANGUAGE = userenv('LANG')
	AND LOOKUP_CODE = l_default_mime_type;

BEGIN
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_item_found := FND_API.G_TRUE;

	-- ******************** Real Logic *****************************
	Validate_Citem (
		p_init_msg_list =>		p_init_msg_list,
		p_content_item_id =>		p_content_item_id,
		x_content_type_code =>		x_content_item_meta.content_type_code,
		x_item_reference_code =>	x_content_item_meta.item_reference_code,
		x_live_citem_version_id	=>	l_live_citem_version_id,
		x_encrypt_flag =>		x_content_item_meta.encrypt_flag,
		x_return_status =>		x_return_status,
		x_msg_count =>			x_msg_count,
		x_msg_data =>			x_msg_data
	);
	-- Content Item requested is not valid
	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	x_content_item_meta.content_item_id := p_content_item_id;

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
		x_item_found := FND_API.G_FALSE;
	        x_content_item_meta := NULL;
		return;
	      END IF;
           CLOSE Get_Citem_Ver_By_Label;
	END IF;

	-- check start/end date
        Validate_Start_End_Date (
		p_init_msg_list =>		p_init_msg_list,
		p_content_item_id =>		p_content_item_id,
		p_citem_version_id =>		l_citem_version_id,
		x_version_number =>		x_content_item_meta.version_number,
		x_start_date =>			x_content_item_meta.available_date,
		x_end_date =>			x_content_item_meta.expiration_date,
		x_return_status =>		x_return_status,
		x_msg_count =>			x_msg_count,
		x_msg_data =>			x_msg_data
	);
	-- Start/End date not valid
	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- // Retrieve content item data (session language)
	OPEN Get_Citem_Meta_Csr;
	   FETCH Get_Citem_Meta_Csr INTO l_translation_status,
					 x_content_item_meta.content_item_name,
					 x_content_item_meta.description,
					 l_default_mime_type,
					 x_content_item_meta.attachment_file_name,
					 x_content_item_meta.attachment_file_id;
	CLOSE Get_Citem_Meta_Csr;

        -- // If translation status of session language is NOT APPROVED,
        -- // retrieve the based language.
	IF (l_translation_status <> 'APPROVED') THEN
	   OPEN Get_Citem_Meta_BLang;
	      FETCH Get_Citem_Meta_BLang INTO x_content_item_meta.content_item_name,
					      x_content_item_meta.description,
					      l_default_mime_type,
					      x_content_item_meta.attachment_file_name,
					      x_content_item_meta.attachment_file_id;
	   CLOSE Get_Citem_Meta_BLang;
        END IF;

	x_content_item_meta.default_mime_type := LOWER(l_default_mime_type);

	IF (l_default_mime_type IS NOT NULL) THEN
	   OPEN Get_Rendition_Name;
	   FETCH Get_Rendition_Name INTO x_content_item_meta.default_rendition_name;
	   IF Get_Rendition_Name%NOTFOUND THEN
	      CLOSE Get_Rendition_Name;
	      l_default_mime_type := IBC_UTILITIES_PVT.G_REND_UNKNOWN_MIME;
	      OPEN Get_Rendition_Name;
	         FETCH Get_Rendition_Name INTO x_content_item_meta.default_rendition_name;
	      CLOSE Get_Rendition_Name;
	   ELSE
	      CLOSE Get_Rendition_Name;
	   END IF;
	ELSE
	   x_content_item_meta.default_rendition_name := NULL;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Meta;


-- --------------------------------------------------------------
-- Get Content Item in XML.
--    * If label is NOT NULL and there is not label-version mapping,
--      p_xml_clob_loc will be NULL and
--	x_num_levels_loaded will be -1
-- --------------------------------------------------------------
PROCEDURE Get_Citem_Xml (
	p_init_msg_list		IN	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_xml_clob_loc		IN OUT	NOCOPY CLOB,
	p_num_levels		IN	NUMBER,
	p_label_code		IN	VARCHAR2,
	p_lang_code		IN	VARCHAR2,
	p_validate_dates	IN	VARCHAR2,
	x_num_levels_loaded	OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_content_type_code		IBC_CONTENT_ITEMS.CONTENT_TYPE_CODE%TYPE;
	l_item_reference_code		IBC_CONTENT_ITEMS.ITEM_REFERENCE_CODE%TYPE;
	l_live_citem_version_id		NUMBER;
	l_citem_version_id		NUMBER;
	l_encrypt_flag			VARCHAR2(1);

	l_version_number		NUMBER;
	l_start_date			DATE;
	l_end_date			DATE;

	l_translation_status		IBC_CITEM_VERSIONS_TL.CITEM_TRANSLATION_STATUS%TYPE;
	l_lang_code			VARCHAR2(4);

	l_content_item_name		IBC_CITEM_VERSIONS_TL.CONTENT_ITEM_NAME%TYPE;
	l_description			IBC_CITEM_VERSIONS_TL.DESCRIPTION%TYPE;
	l_attachment_attribute_code	IBC_CITEM_VERSIONS_TL.ATTACHMENT_ATTRIBUTE_CODE%TYPE;
	l_attachment_file_id		NUMBER;
	l_attachment_file_name		IBC_CITEM_VERSIONS_TL.ATTACHMENT_FILE_NAME%TYPE;
	l_attribute_file_id		NUMBER;
	l_default_mime_type		IBC_CITEM_VERSIONS_TL.DEFAULT_RENDITION_MIME_TYPE%TYPE;

	l_comp_content_item_id		NUMBER;
	l_tmp_num_levels		NUMBER;
	l_has_component_items		VARCHAR2(1) := FND_API.g_false;
	l_max_num_levels_loaded		NUMBER := 0;
--
	-- // Retrieve label version
	CURSOR Get_Citem_Ver_By_Label IS
	select citem_version_id
	from IBC_CITEM_VERSION_LABELS
	where label_code = p_label_code and
	content_item_id = p_content_item_id;

	CURSOR Get_Citem_Version IS
	select START_DATE, END_DATE, VERSION_NUMBER
	from IBC_CITEM_VERSIONS_B
	where CITEM_VERSION_ID = l_citem_version_id;

	-- // retrieve citem version in the specified language
	CURSOR Get_Citem_Meta_Csr IS
	select CITEM_TRANSLATION_STATUS, ATTRIBUTE_FILE_ID, CONTENT_ITEM_NAME, DESCRIPTION, ATTACHMENT_ATTRIBUTE_CODE,
	       ATTACHMENT_FILE_ID, ATTACHMENT_FILE_NAME, DEFAULT_RENDITION_MIME_TYPE
	from IBC_CITEM_VERSIONS_TL
        where citem_version_id = l_citem_version_id
        and language = nvl(p_lang_code, userenv('LANG'));

	-- // retrieve the based language version translation
	CURSOR Get_Citem_Meta_BLang IS
	select i.BASE_LANGUAGE, t.ATTRIBUTE_FILE_ID, t.CONTENT_ITEM_NAME, t.DESCRIPTION, t.ATTACHMENT_ATTRIBUTE_CODE,
	       t.ATTACHMENT_FILE_ID, t.ATTACHMENT_FILE_NAME, t.DEFAULT_RENDITION_MIME_TYPE
	from IBC_CONTENT_ITEMS i, IBC_CITEM_VERSIONS_TL t
	where i.CONTENT_ITEM_ID = p_content_item_id
	and t.citem_version_id = l_citem_version_id
	and t.language = i.BASE_LANGUAGE;

	CURSOR Get_Compound_Item_Ref IS
	select r.ATTRIBUTE_TYPE_CODE, r.CONTENT_ITEM_ID, c.ENCRYPT_FLAG
	from IBC_COMPOUND_RELATIONS r, IBC_CONTENT_ITEMS c
	where r.CITEM_VERSION_ID = l_citem_version_id
	and r.CONTENT_ITEM_ID = c.CONTENT_ITEM_ID
	order by r.SORT_ORDER;

BEGIN

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- **************** Real Logic Starts *****************

	Validate_Citem (
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
		-- Label is valid, but there is no mapping to this item, return NULL
	        p_xml_clob_loc := NULL;
		x_num_levels_loaded := -1;
		return;
	      END IF;
           CLOSE Get_Citem_Ver_By_Label;
	END IF;

	-- This is preloading, DO NOT validate DATES
	IF (p_validate_dates = FND_API.G_FALSE) THEN
	   OPEN Get_Citem_Version;
	      FETCH Get_Citem_Version INTO l_start_date,l_end_date,l_version_number;
	   CLOSE Get_Citem_Version;

	-- Not preloading, NEED to validate DATES
        ELSE
           Validate_Start_End_Date (
		p_init_msg_list =>		p_init_msg_list,
		p_content_item_id =>		p_content_item_id,
		p_citem_version_id =>		l_citem_version_id,
		x_version_number =>		l_version_number,
		x_start_date =>			l_start_date,
		x_end_date =>			l_end_date,
		x_return_status =>		x_return_status,
		x_msg_count =>			x_msg_count,
		x_msg_data =>			x_msg_data
	  );
	  -- Start/End date not valid
	  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
	END IF;

	-- // Retrieve Meta Data in specified language
	l_lang_code := p_label_code;
	OPEN Get_Citem_Meta_Csr;
	   FETCH Get_Citem_Meta_Csr INTO l_translation_status,
					 l_attribute_file_id, l_content_item_name, l_description,
					 l_attachment_attribute_code,
					 l_attachment_file_id,
					 l_attachment_file_name,
					 l_default_mime_type;
	   -- Not found, input LANGUAGE must be invalid (b/c version id already verified)
	   IF Get_Citem_Meta_Csr%NOTFOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name('IBC', 'INVALID_LANG_CODE');
	         FND_MESSAGE.Set_token('LANG_CODE', p_lang_code);
                 FND_MSG_PUB.ADD;
	      END IF;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
        CLOSE Get_Citem_Meta_Csr;

	-- // If translation status is not APPROVED, retrieve based language translation
	IF (l_translation_status <> 'APPROVED') THEN
	   OPEN Get_Citem_Meta_BLang;
              -- // bring in base language
	      FETCH Get_Citem_Meta_BLang INTO l_lang_code,
					      l_attribute_file_id, l_content_item_name, l_description,
					      l_attachment_attribute_code,
     					      l_attachment_file_id,
					      l_attachment_file_name,
					      l_default_mime_type;
	   CLOSE Get_Citem_Meta_BLang;
	END IF;

	-- // Openning Tags (Root + Renditions + Name + Description + Attachment)
	IBC_UTILITIES_PVT.Build_Citem_Open_Tags (
	   p_content_type_code	          =>  l_content_type_code
	   ,p_content_item_id		  =>  p_content_item_id
	   ,p_citem_version_id	          =>  l_citem_version_id
	   ,p_item_label		  =>  p_label_code
	   ,p_lang_code			  =>  l_lang_code    -- Renditions based on language used to retrieve item
	   ,p_version_number		  =>  l_version_number
	   ,p_start_date		  =>  l_start_date
	   ,p_end_date			  =>  l_end_date
	   ,p_item_reference_code	  =>  l_item_reference_code
	   ,p_encrypt_flag		  =>  l_encrypt_flag -- parent item encrypt flag
	   ,p_content_item_name           =>  l_content_item_name
	   ,p_description		  =>  l_description
	   ,p_attachment_attribute_code   =>  l_attachment_attribute_code
	   ,p_attachment_file_id	  =>  l_attachment_file_id
	   ,p_attachment_file_name	  =>  l_attachment_file_name
	   ,p_default_mime_type           =>  l_default_mime_type
	   ,p_is_preview		  =>  FND_API.G_FALSE
	   ,p_xml_clob_loc	          =>  p_xml_clob_loc
	);
	-- User defined primitive attributes
	IBC_UTILITIES_PVT.Build_Attribute_Bundle (
		p_file_id	=>	l_attribute_file_id,
		p_xml_clob_loc	=>	p_xml_clob_loc
	);

	-- Compound Item attributes
	IF (p_num_levels IS NULL OR p_num_levels > 0) THEN

	   -- compound items expanded
	   FOR compound_item_rec IN Get_Compound_Item_Ref LOOP
		l_has_component_items := FND_API.g_true;
		l_comp_content_item_id := compound_item_rec.content_item_id;

		IBC_UTILITIES_PVT.Build_Compound_Item_Open_Tag (
			p_attribute_type_code =>	compound_item_rec.attribute_type_code,
			p_content_item_id =>		l_comp_content_item_id,
			p_item_label =>			p_label_code,
		        p_encrypt_flag =>		compound_item_rec.encrypt_flag,
			p_xml_clob_loc =>		p_xml_clob_loc
		);

		l_tmp_num_levels := p_num_levels - 1;

		Get_Citem_Xml (
		   p_init_msg_list =>		p_init_msg_list,
		   p_content_item_id =>		l_comp_content_item_id,
		   p_xml_clob_loc =>		p_xml_clob_loc,
		   p_num_levels =>		l_tmp_num_levels,
		   p_label_code =>		p_label_code,
		   p_lang_code =>		p_lang_code,  -- components retrieved with requested language
		   p_validate_dates =>		p_validate_dates,
		   x_num_levels_loaded =>	x_num_levels_loaded,
		   x_return_status =>		x_return_status,
		   x_msg_count =>		x_msg_count,
		   x_msg_data =>		x_msg_data
		);
		-- nested compounded items not valid
		IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		-- check if component item is matched with label
		IF (p_xml_clob_loc is NULL) THEN
		   x_num_levels_loaded := -1;
		   return;
		END IF;

		IBC_UTILITIES_PVT.Build_Close_Tag (
			compound_item_rec.attribute_type_code,
			p_xml_clob_loc
		);

		-- update max num levels
		IF (x_num_levels_loaded > l_max_num_levels_loaded) THEN
		   l_max_num_levels_loaded := x_num_levels_loaded;
		END IF;
	   END LOOP;

	   -- set number of levels loaded
	   IF (l_has_component_items = FND_API.g_false) THEN
	      x_num_levels_loaded := 0;
	   ELSE
	      x_num_levels_loaded := l_max_num_levels_loaded + 1;
	   END IF;

	-- p_num_levels = 0
	ELSE
	   -- compound item references
	   IBC_UTILITIES_PVT.Build_Compound_Item_References (
		p_citem_version_id =>	l_citem_version_id,
		p_item_label =>		p_label_code,
		p_xml_clob_loc =>	p_xml_clob_loc
	   );
	   -- set number of levels loaded
	   x_num_levels_loaded := 0;

	END IF;

	-- Close Root Tag
	IBC_UTILITIES_PVT.Build_Close_Tag (
		l_content_type_code,	-- p_content_type_code IN VARCHAR2
		p_xml_clob_loc		-- p_xml_clob_loc IN OUT CLOB
	);
	-- **************** Real Logic Ends *****************
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Xml;




-- ******************************************************************************
-- ***** Cache Loading APIs
-- ******************************************************************************

PROCEDURE Bulk_Load (
	p_init_msg_list		IN	VARCHAR2,
	x_clobs			OUT NOCOPY	JTF_CLOB_TABLE,
	x_content_item_ids	OUT NOCOPY	JTF_NUMBER_TABLE,
	x_label_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_lang_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_citem_ids		JTF_NUMBER_TABLE;
	l_citem_ver_ids		JTF_NUMBER_TABLE;
	l_labels		JTF_VARCHAR2_TABLE_100;
--
	l_final_citem_ids	JTF_NUMBER_TABLE;
	l_final_labels		JTF_VARCHAR2_TABLE_100;
	l_final_lang_codes	JTF_VARCHAR2_TABLE_100;
--
	l_count			NUMBER := 1;
	l_final_count		NUMBER := 1;
	l_citem_version_id	NUMBER;
--
	CURSOR Get_Translated_Langs IS
	select LANGUAGE
	from IBC_CITEM_VERSIONS_TL
	where CITEM_VERSION_ID = l_citem_version_id
	and LANGUAGE = SOURCE_LANG;

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --******************* Real Logic Start *********************

	-- Call to get content items and versions to be loaded
	IBC_LOAD_CITEMS_PVT.Get_Citems_To_Be_Loaded (
	   x_content_item_ids	=>	l_citem_ids
	   ,x_citem_version_ids	=>	l_citem_ver_ids
	   ,x_label_codes	=>	l_labels
	);

	l_final_citem_ids := JTF_NUMBER_TABLE();
	l_final_labels := JTF_VARCHAR2_TABLE_100();
	l_final_lang_codes := JTF_VARCHAR2_TABLE_100();


	-- Find out what translated languages each version has
	WHILE (l_count <= l_citem_ver_ids.COUNT) LOOP
	   l_citem_version_id := l_citem_ver_ids(l_count);

           FOR lang_rec IN Get_Translated_Langs LOOP
	      l_final_citem_ids.EXTEND();
	      l_final_labels.EXTEND();
	      l_final_lang_codes.EXTEND();

	      l_final_citem_ids(l_final_count) := l_citem_ids(l_count);
	      l_final_labels(l_final_count) := l_labels(l_count);
	      l_final_lang_codes(l_final_count) := lang_rec.LANGUAGE;

	      l_final_count := l_final_count + 1;
	   END LOOP;

	   l_count := l_count + 1;
	END LOOP;

	-- Call Load_Translated_Content_Items (DOES NOT validate dates)
	Load_Translated_Content_Items (
	   p_init_msg_list	=>	p_init_msg_list
	   ,p_content_item_ids	=>	l_final_citem_ids
	   ,p_label_codes	=>	l_final_labels
	   ,p_lang_codes	=>	l_final_lang_codes
	   ,p_validate_dates	=>	FND_API.G_FALSE
	   ,x_clobs		=>	x_clobs
	   ,x_content_item_ids	=>	x_content_item_ids
	   ,x_label_codes	=>	x_label_codes
	   ,x_lang_codes	=>	x_lang_codes
	   ,x_return_status	=>	x_return_status
           ,x_msg_count		=>	x_msg_count
           ,x_msg_data		=>	x_msg_data
       );
	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

      --******************* Real Logic End ***********************
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Bulk_Load;



PROCEDURE Load_Translated_Content_Items (
	p_init_msg_list		IN	VARCHAR2,
	p_content_item_ids	IN	JTF_NUMBER_TABLE,
	p_label_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_lang_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_validate_dates	IN	VARCHAR2,
	x_clobs			OUT NOCOPY	JTF_CLOB_TABLE,
	x_content_item_ids	OUT NOCOPY	JTF_NUMBER_TABLE,
	x_label_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_lang_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_citem_id_count	NUMBER := 1;
	l_output_count		NUMBER := 1;
	l_tmp_clob		CLOB;
	l_num_levels_loaded	NUMBER;
--
	l_id			NUMBER;
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************
	x_clobs := JTF_CLOB_TABLE();
	x_content_item_ids := JTF_NUMBER_TABLE();
	x_label_codes := JTF_VARCHAR2_TABLE_100();
	x_lang_codes := JTF_VARCHAR2_TABLE_100();

	WHILE (l_citem_id_count <= p_content_item_ids.COUNT) LOOP
           ------------------------------------------------------
	   DBMS_LOB.CREATETEMPORARY(l_tmp_clob, TRUE);

	   --select IBC_TEST_CLOB2_S.NEXTVAL INTO l_id from DUAL;

           --SELECT DATA INTO l_tmp_clob
	   --FROM IBC_TEST_CLOB WHERE ID = l_id for update;
           ------------------------------------------------------

	   Get_Citem_Xml (
		p_init_msg_list =>	p_init_msg_list
		,p_content_item_id =>	p_content_item_ids(l_citem_id_count)
		,p_xml_clob_loc	=>	l_tmp_clob
		,p_num_levels =>	NULL              -- // Load DEEP
		,p_label_code =>	p_label_codes(l_citem_id_count)
		,p_lang_code =>		p_lang_codes(l_citem_id_count)
		,p_validate_dates =>	p_validate_dates
		,x_num_levels_loaded =>	l_num_levels_loaded
		,x_return_status =>	x_return_status
		,x_msg_count =>		x_msg_count
		,x_msg_data =>		x_msg_data
	   );
	   -- if NO Error AND Label does point to a version, add to result list
	   IF (x_return_status <> FND_API.G_RET_STS_ERROR AND
	       l_tmp_clob IS NOT NULL) THEN
	      x_clobs.EXTEND();
	      x_clobs(l_output_count) := l_tmp_clob;
	      x_content_item_ids.EXTEND();
	      x_content_item_ids(l_output_count) := p_content_item_ids(l_citem_id_count);
	      x_label_codes.EXTEND();
	      x_label_codes(l_output_count) := p_label_codes(l_citem_id_count);
	      x_lang_codes.EXTEND();
	      x_lang_codes(l_output_count) := p_lang_codes(l_citem_id_count);
	      l_output_count := l_output_count +1;
           END IF;

	   l_citem_id_count := l_citem_id_count + 1;
	END LOOP;

      --******************* Real Logic End *********************
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Load_Translated_Content_Items;




PROCEDURE Load_Citem_Version_Number (
	p_init_msg_list		IN	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2,
	x_version_number	OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_content_type_code		IBC_CONTENT_ITEMS.CONTENT_TYPE_CODE%TYPE;
	l_item_reference_code		IBC_CONTENT_ITEMS.ITEM_REFERENCE_CODE%TYPE;
	l_live_citem_version_id		NUMBER;
	l_citem_version_id		NUMBER;
	l_encrypt_flag			VARCHAR2(1);
-----
	CURSOR Get_Citem_Ver_By_Label IS
	select citem_version_id
	from IBC_CITEM_VERSION_LABELS
	where label_code = p_label_code and
	      content_item_id = p_content_item_id;

	CURSOR Get_Version_Number_Csr IS
	select VERSION_NUMBER
	from IBC_CITEM_VERSIONS_B
        where citem_version_id = l_citem_version_id;

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************
	Validate_Citem (
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
		x_version_number := -1;
		return;
	      END IF;
           CLOSE Get_Citem_Ver_By_Label;
	END IF;

	OPEN Get_Version_Number_Csr;
	   FETCH Get_Version_Number_Csr INTO x_version_number;
	CLOSE Get_Version_Number_Csr;

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
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Load_Citem_Version_Number;




PROCEDURE Load_Associations (
	p_init_msg_list			IN	VARCHAR2,
	p_association_type_code		IN    	VARCHAR2,
	p_associated_object_val1	IN	VARCHAR2,
	p_associated_object_val2	IN	VARCHAR2,
	p_associated_object_val3	IN	VARCHAR2,
	p_associated_object_val4	IN	VARCHAR2,
	p_associated_object_val5	IN	VARCHAR2,
	x_content_item_id_tbl		OUT NOCOPY	JTF_NUMBER_TABLE,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
	l_citem_count			NUMBER := 1;
-----
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
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --******************* Real Logic Start *********************

      x_content_item_id_tbl := JTF_NUMBER_TABLE();

      FOR citem_id_rec IN Get_Citems_By_Assoc LOOP
	 x_content_item_id_tbl.EXTEND();
	 x_content_item_id_tbl(l_citem_count) := citem_id_rec.content_item_id;
	 l_citem_count := l_citem_count + 1;
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
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Load_Associations;


-- --------------------------------------------------------------
-- Get a specific Content Item Version in XML
--      p_xml_clob_loc will be NULL and
--	x_num_levels_loaded will be -1
-- --------------------------------------------------------------

PROCEDURE Get_Citem_Xml (
	p_init_msg_list		IN	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_xml_clob_loc		IN OUT	NOCOPY CLOB,
	p_num_levels		IN	NUMBER,
	p_citem_version_id	IN	NUMBER,
	p_lang_code		IN	VARCHAR2,
	p_validate_dates	IN	VARCHAR2,
	x_num_levels_loaded	OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
) AS
	l_content_type_code		IBC_CONTENT_ITEMS.CONTENT_TYPE_CODE%TYPE;
	l_item_reference_code		IBC_CONTENT_ITEMS.ITEM_REFERENCE_CODE%TYPE;
	l_live_citem_version_id		NUMBER;
	l_citem_version_id		NUMBER;
	l_encrypt_flag			VARCHAR2(1);

	l_version_number		NUMBER;
	l_start_date			DATE;
	l_end_date			DATE;

	l_translation_status		IBC_CITEM_VERSIONS_TL.CITEM_TRANSLATION_STATUS%TYPE;
	l_lang_code			VARCHAR2(4);

	l_content_item_name		IBC_CITEM_VERSIONS_TL.CONTENT_ITEM_NAME%TYPE;
	l_description			IBC_CITEM_VERSIONS_TL.DESCRIPTION%TYPE;
	l_attachment_attribute_code	IBC_CITEM_VERSIONS_TL.ATTACHMENT_ATTRIBUTE_CODE%TYPE;
	l_attachment_file_id		NUMBER;
	l_attachment_file_name		IBC_CITEM_VERSIONS_TL.ATTACHMENT_FILE_NAME%TYPE;
	l_attribute_file_id		NUMBER;
	l_default_mime_type		IBC_CITEM_VERSIONS_TL.DEFAULT_RENDITION_MIME_TYPE%TYPE;

	l_comp_content_item_id		NUMBER;
	l_tmp_num_levels		NUMBER;
	l_has_component_items		VARCHAR2(1) := FND_API.g_false;
	l_max_num_levels_loaded		NUMBER := 0;

-- Retrive the Content Item Version details

	CURSOR Get_Citem_Version IS
	select START_DATE, END_DATE, VERSION_NUMBER
	from IBC_CITEM_VERSIONS_B
	where CITEM_VERSION_ID =p_citem_version_id;

	-- // retrieve citem version in the specified language
	CURSOR Get_Citem_Meta_Csr IS
	select CITEM_TRANSLATION_STATUS, ATTRIBUTE_FILE_ID, CONTENT_ITEM_NAME, DESCRIPTION, ATTACHMENT_ATTRIBUTE_CODE,
	       ATTACHMENT_FILE_ID, ATTACHMENT_FILE_NAME, DEFAULT_RENDITION_MIME_TYPE
	from IBC_CITEM_VERSIONS_TL
        where citem_version_id =p_citem_version_id
        and language = nvl(p_lang_code, userenv('LANG'));

	-- // retrieve the based language version translation
	CURSOR Get_Citem_Meta_BLang IS
	select i.BASE_LANGUAGE, t.ATTRIBUTE_FILE_ID, t.CONTENT_ITEM_NAME, t.DESCRIPTION, t.ATTACHMENT_ATTRIBUTE_CODE,
	       t.ATTACHMENT_FILE_ID, t.ATTACHMENT_FILE_NAME, t.DEFAULT_RENDITION_MIME_TYPE
	from IBC_CONTENT_ITEMS i, IBC_CITEM_VERSIONS_TL t
	where i.CONTENT_ITEM_ID = p_content_item_id
	and t.citem_version_id = p_citem_version_id
	and t.language = i.BASE_LANGUAGE;

	CURSOR Get_Compound_Item_Ref IS
	select r.ATTRIBUTE_TYPE_CODE, r.CONTENT_ITEM_ID, c.ENCRYPT_FLAG,
               nvl(SUBITEM_VERSION_ID, nvl(LIVE_CITEM_VERSION_ID, (select max(VERSION_NUMBER) from IBC_CITEM_VERSIONS_B where CONTENT_ITEM_ID = r.CONTENT_ITEM_ID))) child_version_id
	from IBC_COMPOUND_RELATIONS r, IBC_CONTENT_ITEMS c
	where r.CITEM_VERSION_ID =p_citem_version_id
	and r.CONTENT_ITEM_ID = c.CONTENT_ITEM_ID
	order by r.SORT_ORDER;

BEGIN

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- **************** Real Logic Starts *****************

	Validate_Citem (
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

	-- This is preloading, DO NOT validate DATES
	IF (p_validate_dates = FND_API.G_FALSE) THEN
	   OPEN Get_Citem_Version;
	      FETCH Get_Citem_Version INTO l_start_date,l_end_date,l_version_number;
	   CLOSE Get_Citem_Version;

	-- Not preloading, NEED to validate DATES
 ELSE
           Validate_Start_End_Date (
		p_init_msg_list =>		p_init_msg_list,
		p_content_item_id =>		p_content_item_id,
		p_citem_version_id =>		p_citem_version_id,
		x_version_number =>		l_version_number,
		x_start_date =>		l_start_date,
		x_end_date =>		l_end_date,
		x_return_status =>		x_return_status,
		x_msg_count =>		x_msg_count,
		x_msg_data =>		x_msg_data
	  );
	  -- Start/End date not valid
	  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
	END IF;

	-- // Retrieve Meta Data in specified language
-- // l_lang_code := p_label_code;
	OPEN Get_Citem_Meta_Csr;
	   FETCH Get_Citem_Meta_Csr INTO l_translation_status,
l_attribute_file_id, l_content_item_name, l_description,
					 l_attachment_attribute_code,
					 l_attachment_file_id,
					 l_attachment_file_name,
					 l_default_mime_type;
	   -- Not found, input LANGUAGE must be invalid (b/c version id already verified)
	   IF Get_Citem_Meta_Csr%NOTFOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name('IBC', 'INVALID_LANG_CODE');
	         FND_MESSAGE.Set_token('LANG_CODE', p_lang_code);
                 FND_MSG_PUB.ADD;
	      END IF;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
        CLOSE Get_Citem_Meta_Csr;

	-- // If translation status is not APPROVED, retrieve based language translation
	IF (l_translation_status <> 'APPROVED') THEN
	   OPEN Get_Citem_Meta_BLang;
              -- // bring in base language
	      FETCH Get_Citem_Meta_BLang INTO l_lang_code,
					      l_attribute_file_id, l_content_item_name, l_description,
					      l_attachment_attribute_code,
     					      l_attachment_file_id,
					      l_attachment_file_name,
					      l_default_mime_type;
	   CLOSE Get_Citem_Meta_BLang;
	END IF;

	-- // Openning Tags (Root + Renditions + Name + Description + Attachment)
	IBC_UTILITIES_PVT.Build_Citem_Open_Tags (
	   p_content_type_code	          =>  l_content_type_code
	   ,p_content_item_id		  =>  p_content_item_id
	   ,p_citem_version_id	          =>  p_citem_version_id
	   ,p_item_label		  =>  NULL
	   ,p_lang_code			  =>  l_lang_code    -- Renditions based on language used to retrieve item
	   ,p_version_number		  =>  l_version_number
	   ,p_start_date		  =>  l_start_date
	   ,p_end_date			  =>  l_end_date
	   ,p_item_reference_code	  =>  l_item_reference_code
	   ,p_encrypt_flag		  =>  l_encrypt_flag -- parent item encrypt flag
	   ,p_content_item_name           =>  l_content_item_name
	   ,p_description		  =>  l_description
	   ,p_attachment_attribute_code   =>  l_attachment_attribute_code
	   ,p_attachment_file_id	  =>  l_attachment_file_id
	   ,p_attachment_file_name	  =>  l_attachment_file_name
	   ,p_default_mime_type           =>  l_default_mime_type
	   ,p_is_preview		  =>  FND_API.G_FALSE
	   ,p_xml_clob_loc	          =>  p_xml_clob_loc
	);
	-- User defined primitive attributes
	IBC_UTILITIES_PVT.Build_Attribute_Bundle (
		p_file_id	=>	l_attribute_file_id,
		p_xml_clob_loc	=>	p_xml_clob_loc
	);

	-- Compound Item attributes
	IF (p_num_levels IS NULL OR p_num_levels > 0) THEN

	   -- compound items expanded
	   FOR compound_item_rec IN Get_Compound_Item_Ref LOOP
		l_has_component_items := FND_API.g_true;
		l_comp_content_item_id := compound_item_rec.content_item_id;

		IBC_UTILITIES_PVT.Build_Compound_Item_Open_Tag (
			p_attribute_type_code =>	compound_item_rec.attribute_type_code,
			p_content_item_id =>		l_comp_content_item_id,
			p_item_label =>			NULL,
		        p_encrypt_flag =>		compound_item_rec.encrypt_flag,
			p_xml_clob_loc =>		p_xml_clob_loc
		);

		l_tmp_num_levels := p_num_levels - 1;

		Get_Citem_Xml (
		   p_init_msg_list =>		p_init_msg_list,
		   p_content_item_id =>		l_comp_content_item_id,
		   p_xml_clob_loc =>		p_xml_clob_loc,
		   p_num_levels =>		l_tmp_num_levels,
		   p_citem_version_id =>        compound_item_rec.child_version_id,
		   p_lang_code =>		p_lang_code,  -- components retrieved with requested language
		   p_validate_dates =>		p_validate_dates,
		   x_num_levels_loaded =>	x_num_levels_loaded,
		   x_return_status =>		x_return_status,
		   x_msg_count =>		x_msg_count,
		   x_msg_data =>		x_msg_data
		);

		-- nested compounded items not valid
		IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		-- check if component item is matched with label
		IF (p_xml_clob_loc is NULL) THEN
		   x_num_levels_loaded := -1;
		   return;
		END IF;

		IBC_UTILITIES_PVT.Build_Close_Tag (
			compound_item_rec.attribute_type_code,
			p_xml_clob_loc
		);

		-- update max num levels
		IF (x_num_levels_loaded > l_max_num_levels_loaded) THEN
		   l_max_num_levels_loaded := x_num_levels_loaded;
		END IF;

	   END LOOP;

	   -- set number of levels loaded
	   IF (l_has_component_items = FND_API.g_false) THEN
	      x_num_levels_loaded := 0;
	   ELSE
	      x_num_levels_loaded := l_max_num_levels_loaded + 1;
	   END IF;

	-- p_num_levels = 0
	ELSE
	   -- compound item references
	   IBC_UTILITIES_PVT.Build_Compound_Item_References (
		p_citem_version_id =>	p_citem_version_id,
		p_item_label =>	NULL,
		p_xml_clob_loc =>	p_xml_clob_loc
	   );
	   -- set number of levels loaded
	   x_num_levels_loaded := 0;

	END IF;

	-- Close Root Tag
	IBC_UTILITIES_PVT.Build_Close_Tag (
		l_content_type_code,	-- p_content_type_code IN VARCHAR2
		p_xml_clob_loc		-- p_xml_clob_loc IN OUT CLOB
	);
	-- **************** Real Logic Ends *****************
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Xml;



END IBC_CITEM_RUNTIME_PVT;

/
