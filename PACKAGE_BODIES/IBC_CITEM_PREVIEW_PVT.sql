--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_PREVIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_PREVIEW_PVT" as
/* $Header: ibcvcipb.pls 115.13 2004/04/09 00:09:20 srrangar ship $ */

PROCEDURE Get_Citem_Version (
	p_init_msg_list			IN	VARCHAR2,
	p_content_item_id		IN	NUMBER,
	p_latest_component_versions	IN	VARCHAR2,
	x_citem_version_id		OUT NOCOPY	NUMBER,
	x_version_number		OUT NOCOPY	NUMBER,
	x_start_date			OUT NOCOPY	DATE,
	x_end_date			OUT NOCOPY	DATE,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
	CURSOR Get_Latest_Version IS
	select CITEM_VERSION_ID, VERSION_NUMBER, START_DATE, END_DATE
	from IBC_CITEM_VERSIONS_B
	where CONTENT_ITEM_ID = p_content_item_id
	and VERSION_NUMBER = (select max(VERSION_NUMBER)
			      from IBC_CITEM_VERSIONS_B
			      where CONTENT_ITEM_ID = p_content_item_id);

	CURSOR Get_Latest_Approved_Version IS
	select CITEM_VERSION_ID, VERSION_NUMBER, START_DATE, END_DATE
	from IBC_CITEM_VERSIONS_B
	where CONTENT_ITEM_ID = p_content_item_id
	and VERSION_NUMBER = (select max(VERSION_NUMBER)
			      from IBC_CITEM_VERSIONS_B
			      where CONTENT_ITEM_ID = p_content_item_id
			      and CITEM_VERSION_STATUS = IBC_UTILITIES_PUB.G_STV_APPROVED);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_latest_component_versions = FND_API.G_TRUE) THEN
       OPEN Get_Latest_Version;
          FETCH Get_Latest_Version INTO x_citem_version_id, x_version_number,
					x_start_date, x_end_date;
       CLOSE Get_Latest_Version;
    ELSE
       OPEN Get_Latest_Approved_Version;
          FETCH Get_Latest_Approved_Version INTO x_citem_version_id, x_version_number,
						 x_start_date, x_end_date;
       CLOSE Get_Latest_Approved_Version;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (	p_count => x_msg_count,
					p_data  => x_msg_data);
END Get_Citem_Version;







PROCEDURE Preview_Citem_Xml (
	p_init_msg_list			IN	VARCHAR2,
	p_content_item_id		IN	NUMBER,
	p_citem_version_id		IN	NUMBER,
	p_lang_code			IN	VARCHAR2,
	p_version_number		IN	NUMBER,
	p_start_date			IN	DATE,
	p_end_date			IN	DATE,
	p_preview_mode			IN	VARCHAR2,
	p_xml_clob_loc			IN OUT	NOCOPY CLOB,
	p_num_levels			IN	NUMBER,
	x_num_levels_loaded		OUT NOCOPY	NUMBER,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
) AS
	l_version_number		NUMBER;
	l_start_date			DATE;
	l_end_date			DATE;
	l_content_type_code		IBC_CONTENT_ITEMS.CONTENT_TYPE_CODE%TYPE;
	l_item_reference_code		IBC_CONTENT_ITEMS.ITEM_REFERENCE_CODE%TYPE;
	l_encrypt_flag			VARCHAR2(1);

	l_content_item_name		IBC_CITEM_VERSIONS_TL.CONTENT_ITEM_NAME%TYPE;
	l_description			IBC_CITEM_VERSIONS_TL.DESCRIPTION%TYPE;
	l_attachment_attribute_code	IBC_CITEM_VERSIONS_TL.ATTACHMENT_ATTRIBUTE_CODE%TYPE;
	l_attachment_file_id		NUMBER;
	l_attachment_file_name		IBC_CITEM_VERSIONS_TL.ATTACHMENT_FILE_NAME%TYPE;
	l_attribute_file_id		NUMBER;
	l_default_mime_type		IBC_CITEM_VERSIONS_TL.DEFAULT_RENDITION_MIME_TYPE%TYPE;

	l_comp_content_item_id		NUMBER;
	l_comp_citem_version_id		NUMBER;
	l_comp_citem_version_number	NUMBER;
	l_comp_citem_start_date		DATE;
	l_comp_citem_end_date		DATE;
	l_tmp_num_levels		NUMBER;
	l_has_component_items		VARCHAR2(1) := FND_API.g_false;
	l_max_num_levels_loaded		NUMBER := 0;
--
	CURSOR Get_Citem IS
	select CONTENT_TYPE_CODE, ITEM_REFERENCE_CODE, ENCRYPT_FLAG
	from IBC_CONTENT_ITEMS
	where content_item_id = p_content_item_id;

	CURSOR Get_Version IS
	select VERSION_NUMBER, START_DATE, END_DATE
	from IBC_CITEM_VERSIONS_B
	where CITEM_VERSION_ID = p_citem_version_id;

	CURSOR Get_Citem_Meta_Csr IS
	select ATTRIBUTE_FILE_ID, CONTENT_ITEM_NAME, DESCRIPTION, ATTACHMENT_ATTRIBUTE_CODE,
               ATTACHMENT_FILE_ID, ATTACHMENT_FILE_NAME, DEFAULT_RENDITION_MIME_TYPE
	from IBC_CITEM_VERSIONS_TL
        where citem_version_id = p_citem_version_id
        and language = nvl(p_lang_code, userenv('LANG'));


	CURSOR Get_Compound_Item_Ref IS
	select r.ATTRIBUTE_TYPE_CODE, r.CONTENT_ITEM_ID,
	       r.SUBITEM_VERSION_ID, c.ENCRYPT_FLAG
	from IBC_COMPOUND_RELATIONS r, IBC_CONTENT_ITEMS c
	where r.CITEM_VERSION_ID = p_citem_version_id
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

	-- Retrieve Content Item
	OPEN Get_Citem;
	   FETCH Get_Citem INTO l_content_type_code, l_item_reference_code,l_encrypt_flag;
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

	-- Retrieve Meta Data
	OPEN Get_Citem_Meta_Csr;
	   FETCH Get_Citem_Meta_Csr INTO l_attribute_file_id, l_content_item_name, l_description,
					 l_attachment_attribute_code,
					 l_attachment_file_id,
					 l_attachment_file_name,
					 l_default_mime_type;
	   -- check if p_citem_version_id is valid
	   IF Get_Citem_Meta_Csr%NOTFOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
	         FND_MESSAGE.Set_token('CITEM_VERSION_ID', p_citem_version_id);
                 FND_MSG_PUB.ADD;
	      END IF;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	CLOSE Get_Citem_Meta_Csr;

	IF (p_version_number is NULL) THEN
	   OPEN Get_Version;
	      FETCH Get_Version INTO l_version_number, l_start_date,
			             l_end_date;
	   CLOSE Get_Version;
	ELSE
	   l_version_number := p_version_number;
	   l_start_date := p_start_date;
	   l_end_date := p_end_date;
	END IF;

	-- Openning Tags (Root + Renditions + Name + Description + Attachment)
	IBC_UTILITIES_PVT.Build_Citem_Open_Tags (
		p_content_type_code =>		l_content_type_code,
		p_content_item_id =>		p_content_item_id,
		p_citem_version_id =>		p_citem_version_id,
	        p_lang_code =>			p_lang_code,
		p_version_number =>		l_version_number,
		p_start_date =>			l_start_date,
		p_end_date =>			l_end_date,
		p_item_reference_code =>	l_item_reference_code,
		p_encrypt_flag =>		l_encrypt_flag,
		p_content_item_name =>		l_content_item_name,
		p_description =>		l_description,
		p_attachment_attribute_code =>	l_attachment_attribute_code,
		p_attachment_file_id =>		l_attachment_file_id,
		p_attachment_file_name =>	l_attachment_file_name,
		p_default_mime_type =>		l_default_mime_type,
		p_is_preview =>			FND_API.G_TRUE,
		p_xml_clob_loc =>		p_xml_clob_loc
	);
	-- User defined primitive attributes
	IBC_UTILITIES_PVT.Build_Attribute_Bundle (
		p_file_id =>			l_attribute_file_id,
		p_xml_clob_loc =>		p_xml_clob_loc
	);
	-- Compound Item attributes
	IF (p_num_levels IS NULL OR p_num_levels > 0) THEN

	   -- compound items expanded
	   FOR compound_item_rec IN Get_Compound_Item_Ref LOOP

		l_has_component_items := FND_API.g_true;
		l_comp_content_item_id := compound_item_rec.content_item_id;
		l_comp_citem_version_id := compound_item_rec.subitem_version_id;

		IF (p_preview_mode = IBC_CITEM_PREVIEW_GRP.G_LATEST_COMP_VERSIONS OR
                    (p_preview_mode = IBC_CITEM_PREVIEW_GRP.G_DEFAULT_COMP_VERSIONS AND
		    l_comp_citem_version_id is NULL)) THEN

		    -- if default versions specified, but value not set, also use latest versions.
		    Get_Citem_Version (
		       p_init_msg_list =>		p_init_msg_list,
		       p_content_item_id =>		l_comp_content_item_id,
		       p_latest_component_versions =>	FND_API.G_TRUE,
		       x_citem_version_id =>		l_comp_citem_version_id,
		       x_version_number =>		l_comp_citem_version_number,
		       x_start_date =>			l_comp_citem_start_date,
		       x_end_date =>			l_comp_citem_end_date,
		       x_return_status =>		x_return_status,
		       x_msg_count =>			x_msg_count,
		       x_msg_data =>			x_msg_data);
		ELSIF (p_preview_mode = IBC_CITEM_PREVIEW_GRP.G_LIVE_COMP_VERSIONS) THEN
		    Get_Citem_Version (
		       p_init_msg_list =>		p_init_msg_list,
		       p_content_item_id =>		l_comp_content_item_id,
		       p_latest_component_versions =>	FND_API.G_FALSE,
		       x_citem_version_id =>		l_comp_citem_version_id,
		       x_version_number =>		l_comp_citem_version_number,
		       x_start_date =>			l_comp_citem_start_date,
		       x_end_date =>			l_comp_citem_end_date,
		       x_return_status =>		x_return_status,
		       x_msg_count =>			x_msg_count,
		       x_msg_data =>			x_msg_data);
		END IF;

		--
		-- No matter what the mode is : if the Subitem_version_id
		-- is specified for the Compound Content Item, it should
		-- be picked up.
		-- Only when the SubItemVersionId is NULL then the mode should
		-- be looked at to decide whether Live Or Latest Versions must
		-- be shown.
		-- Bug#3378895 and Bug#3378875
		--
		IF compound_item_rec.subitem_version_id IS NOT NULL THEN
		   l_comp_citem_version_id := compound_item_rec.subitem_version_id;
		END IF;

		-- Siva Devaki 22-Jan-04
		-- Checking this condition to fix bug#3385548
		IF ( l_comp_citem_version_id IS NOT NULL ) THEN

 		    IBC_UTILITIES_PVT.Build_Preview_Cpnt_Open_Tag (
			p_attribute_type_code =>	compound_item_rec.attribute_type_code,
			p_content_item_id =>		l_comp_content_item_id,
			p_content_item_version_id =>	l_comp_citem_version_id,
			p_encrypt_flag =>		compound_item_rec.encrypt_flag,
			p_xml_clob_loc =>		p_xml_clob_loc
		    );
		    l_tmp_num_levels := p_num_levels - 1;
		    Preview_Citem_Xml (
			p_init_msg_list
			,l_comp_content_item_id
			,l_comp_citem_version_id
			,p_lang_code
			,l_comp_citem_version_number
			,l_comp_citem_start_date
			,l_comp_citem_end_date
			,p_preview_mode
			,p_xml_clob_loc
			,l_tmp_num_levels
			,x_num_levels_loaded
			,x_return_status
			,x_msg_count
			,x_msg_data
		    );
		    -- nested compounded items not valid
		    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		        RAISE FND_API.G_EXC_ERROR;
		    END IF;

		    IBC_UTILITIES_PVT.Build_Close_Tag (
			compound_item_rec.attribute_type_code,
			p_xml_clob_loc
		    );

		    -- update max num levels
		    IF (x_num_levels_loaded > l_max_num_levels_loaded) THEN
		        l_max_num_levels_loaded := x_num_levels_loaded;
		    END IF;

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
	   IBC_UTILITIES_PVT.Build_Preview_Cpnt_References (
		p_citem_version_id =>	p_citem_version_id,
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
END Preview_Citem_Xml;


END IBC_CITEM_PREVIEW_PVT;

/
