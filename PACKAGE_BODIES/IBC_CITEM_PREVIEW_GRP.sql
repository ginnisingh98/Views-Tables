--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_PREVIEW_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_PREVIEW_GRP" as
/* $Header: ibcgcipb.pls 115.7 2003/11/13 21:07:43 vicho ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBC_CITEM_PREVIEW_GRP';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ibcgcipb.pls';



PROCEDURE Preview_Citem_Basic_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_citem_version_id	IN	NUMBER,
	p_lang_code		IN	VARCHAR2,
	x_return_status        	OUT NOCOPY VARCHAR2,
        x_msg_count            	OUT NOCOPY NUMBER,
        x_msg_data             	OUT NOCOPY VARCHAR2,
	x_content_item_xml	OUT NOCOPY CLOB
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Preview_Citem_Basic_Xml';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_latest_component_versions	VARCHAR2(1) := FND_API.G_TRUE;
	x_num_levels_loaded		NUMBER;
	l_xml_encoding			VARCHAR2(50);
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

      IBC_CITEM_PREVIEW_PVT.Preview_Citem_Xml (
	p_init_msg_list =>	p_init_msg_list,
	p_content_item_id =>	p_content_item_id,
	p_citem_version_id =>	p_citem_version_id,
	p_lang_code =>		p_lang_code,
	p_xml_clob_loc =>	x_content_item_xml,
	p_num_levels =>		0,
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
END Preview_Citem_Basic_Xml;




PROCEDURE Preview_Citem_Deep_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2,
	p_content_item_id	IN	NUMBER,
	p_citem_version_id	IN	NUMBER,
	p_lang_code		IN	VARCHAR2,
	p_preview_mode		IN	VARCHAR2,
	x_return_status        	OUT NOCOPY VARCHAR2,
        x_msg_count            	OUT NOCOPY NUMBER,
        x_msg_data             	OUT NOCOPY VARCHAR2,
	x_content_item_xml	OUT NOCOPY CLOB,
	x_num_levels_loaded	OUT NOCOPY NUMBER
) AS
        --******** local variable for standards **********
        l_api_name              CONSTANT VARCHAR2(30)   := 'Preview_Citem_Deep_Xml';
	l_api_version		CONSTANT NUMBER := 1.0;
--
	l_xml_encoding			VARCHAR2(50);
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

      IBC_CITEM_PREVIEW_PVT.Preview_Citem_Xml (
	p_init_msg_list =>	p_init_msg_list,
	p_content_item_id =>	p_content_item_id,
	p_citem_version_id =>	p_citem_version_id,
	p_lang_code =>		p_lang_code,
	p_version_number =>	NULL,
	p_start_date =>		NULL,
	p_end_date =>		NULL,
	p_preview_mode =>	p_preview_mode,
	p_xml_clob_loc =>	x_content_item_xml,
	p_num_levels =>		NULL,
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
END Preview_Citem_Deep_Xml;


END IBC_CITEM_PREVIEW_GRP;

/
