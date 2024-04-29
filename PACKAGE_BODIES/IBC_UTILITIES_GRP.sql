--------------------------------------------------------
--  DDL for Package Body IBC_UTILITIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_UTILITIES_GRP" as
/* $Header: ibcgutlb.pls 115.2 2003/08/21 23:12:48 enunez noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBC_UTITILIES_GRP';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ibcgutlb.pls';

/***********************************************************************************
 *************************** Private Procedures ************************************
 ***********************************************************************************/

FUNCTION get_mime_type(p_file_type IN VARCHAR2) RETURN VARCHAR2
IS
  l_sc_position   NUMBER;
  l_result        VARCHAR2(256);
BEGIN

  l_sc_position := INSTR(p_file_type, ';');
  IF l_sc_position > 0 THEN
    l_result := UPPER(SUBSTR(p_file_type, 1, l_sc_position - 1));
  ELSE
    l_result := UPPER(p_file_type);
  END IF;

  RETURN l_result;
END get_mime_type;


/***********************************************************************************
 *************************** Public Procedures *************************************
 ***********************************************************************************/

-- --------------------------------------------------------------
-- Get_Rendition_File_Id
--
-- Valid content item id or citem version id must be given.  If
-- version id is given, the rendition returned will be for that
-- particular version.  If version id is not given and valid
-- content item id is given, the rendition returned will be for
-- the live version.
--
-- --------------------------------------------------------------
PROCEDURE Get_Rendition_File_Id (
 	p_api_version			  IN NUMBER    DEFAULT 1.0,
  p_init_msg_list	  IN VARCHAR2  DEFAULT FND_API.g_false,
  p_content_item_id IN NUMBER    DEFAULT NULL,
 	p_citem_ver_id		  IN	NUMBER    DEFAULT NULL,
  p_language        IN VARCHAR2  DEFAULT NULL,
  p_mime_type       IN VARCHAR2,
 	x_file_id      			OUT	NOCOPY NUMBER,
 	x_return_status			OUT NOCOPY VARCHAR2,
  x_msg_count			    OUT NOCOPY NUMBER,
  x_msg_data			     OUT NOCOPY VARCHAR2
) AS
        --******** local variable for standards **********
  l_api_name     CONSTANT VARCHAR2(40)   := 'get_rendition_file_id';
 	l_api_version		CONSTANT NUMBER := 1.0;
  --
  l_citem_ver_id NUMBER;
  l_language     VARCHAR2(30);
  l_mime_type    VARCHAR2(80);
	 l_file_id		    NUMBER;
  --
 	CURSOR Get_file_Id(p_civid IN NUMBER,
                     p_language IN VARCHAR2,
                     p_mime_type IN VARCHAR2)
  IS
 	SELECT file_id
   	FROM IBC_RENDITIONS
 	 WHERE citem_version_id = p_civid
     AND language = p_language
 	   AND mime_type = p_mime_type;

  CURSOR c_live_version(p_content_item_id IN NUMBER)
  IS
  SELECT live_citem_version_id
    FROM IBC_CONTENT_ITEMS
   WHERE content_item_id = p_content_item_id;

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

      IF p_language IS NULL THEN
        l_language := USERENV('LANG');
      ELSE
        l_language := p_language;
      END IF;

      IF p_citem_ver_id IS NULL THEN
        OPEN c_live_version(p_content_item_id);
        FETCH c_live_version INTO l_citem_ver_id;
        CLOSE c_live_version;
      ELSE
        l_citem_ver_id := p_citem_ver_id;
      END IF;

      IF p_mime_type IS NULL THEN
        SELECT default_rendition_mime_type
          INTO l_mime_type
          FROM ibc_citem_versions_tl
         WHERE citem_version_id = l_citem_ver_id
           AND language = l_language;
      ELSE
        l_mime_type := p_mime_type;
      END IF;

      -- checking version id
      IF l_citem_ver_id IS NULL OR
         IBC_VALIDATE_PVT.isValidCitemVer(l_citem_ver_id) = FND_API.g_false OR
         (p_content_item_id IS NOT NULL AND
          IBC_VALIDATE_PVT.isValidCitemVerForCitem(p_content_item_id,l_citem_ver_id) = FND_API.g_false)
      THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id/p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF IBC_VALIDATE_PVT.isvalidlanguage(l_language) = FND_API.g_false THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_language', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN Get_File_Id(l_citem_ver_id, l_language, l_mime_type);
      FETCH Get_File_Id INTO l_file_id;
     	-- check if default style sheet exists
     	IF Get_File_Id%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_language/p_mime_type', FALSE);
        FND_MSG_PUB.ADD;
        CLOSE Get_File_id;
        RAISE FND_API.G_EXC_ERROR;
     	END IF;
      CLOSE Get_File_Id;

      x_file_id := l_file_id;

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
END Get_Rendition_File_Id;

-- --------------------------------------------------------------
-- Get_accessible_content_items
--
-- --------------------------------------------------------------
PROCEDURE Get_Accessible_Content_Items (
 	p_api_version			    IN NUMBER,
  p_init_msg_list	    IN VARCHAR2,
  p_user_id           IN NUMBER,
  p_language          IN VARCHAR2,
  p_permission_code   IN VARCHAR2,
  p_directory_node_id IN NUMBER,
  p_path_pattern      IN VARCHAR2,
  p_include_subdirs   IN VARCHAR2,
  x_citem_ids         OUT NOCOPY JTF_NUMBER_TABLE,
  x_citem_names       OUT NOCOPY JTF_VARCHAR2_TABLE_100,
 	x_return_status			  OUT NOCOPY VARCHAR2,
  x_msg_count			      OUT NOCOPY NUMBER,
  x_msg_data			       OUT NOCOPY VARCHAR2
)
IS

  CURSOR c_dirpath(p_directory_node_id NUMBER)
  IS SELECT directory_path
       FROM ibc_directory_nodes_b
      WHERE directory_node_id = p_directory_node_id;

  CURSOR c_items(p_language          VARCHAR2,
                 p_security_flag     VARCHAR2,
                 p_user_id           NUMBER,
                 p_permission_code   VARCHAR2,
                 p_path_pattern      VARCHAR2)
  IS
    SELECT content_item_id
     FROM ibc_citem_permissions_v citems,
          ibc_directory_nodes_b   dirnodes
    WHERE citems.permission_code IN ('ALL_ALLOWED', p_permission_code)
      AND citems.user_id = p_user_id
      AND citems.security_flag = p_security_flag
      AND citems.directory_node_id = dirnodes.directory_node_id
      AND dirnodes.directory_path LIKE NVL(p_path_pattern, '%')
      AND dirnodes.node_type = 'WD';

  CURSOR c_item_name(p_content_item_id NUMBER,
                     p_language        VARCHAR2)
  IS
    SELECT MAX(civtl.content_item_name)
      FROM ibc_citem_versions_b civb,
           ibc_citem_versions_tl civtl
     WHERE civb.content_item_id = p_content_item_id
       AND civb.citem_version_id = civtl.citem_version_id
       AND language = p_language;

  --******** local variable for standards **********
  l_api_name     CONSTANT VARCHAR2(40)   := 'Get_Accessible_Content_Items';
 	l_api_version		CONSTANT NUMBER := 1.0;
  --
  l_user_id       NUMBER;
  l_dirpath       VARCHAR2(3000);
  l_security_flag VARCHAR2(30);

  TYPE t_num_tbl IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  l_result              t_num_tbl;
  l_count               NUMBER;

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

  IF p_user_id IS NOT NULL THEN
    l_user_id := p_user_id;
  ELSE
    l_user_id := FND_GLOBAL.user_id;
  END IF;

  l_security_flag := Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999);

  IF p_directory_node_id IS NOT NULL THEN
    OPEN c_dirpath(p_directory_node_id);
    FETCH c_dirpath INTO l_dirpath;
    IF c_dirpath%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
      FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_dirpath;
  ELSE
    l_dirpath := p_path_pattern;
  END IF;

  IF p_include_subdirs = FND_API.g_true THEN
    l_dirpath := l_dirpath || '%';
  END IF;

  l_count := 0;
  FOR r_items IN c_items(p_language        => NVL(p_language, USERENV('lang')),
                         p_security_flag   => l_security_flag,
                         p_user_id         => l_user_id,
                         p_permission_code => p_permission_code,
                         p_path_pattern    => l_dirpath)
  LOOP
    l_count := l_count + 1;
    l_result(l_count) := r_items.content_item_id;
  END LOOP;

  IF l_count > 0 THEN
    x_citem_ids := JTF_NUMBER_TABLE();
    x_citem_names := JTF_VARCHAR2_TABLE_100();
    x_citem_ids.extend(l_count);
    x_citem_names.extend(l_count);
    FOR I IN 1..l_count LOOP
      x_citem_ids(I)   := l_result(I);
      OPEN c_item_name(l_result(I), NVL(p_language, USERENV('lang')));
      FETCH c_item_name INTO x_citem_names(I);
      CLOSE c_item_name;
    END LOOP;
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
END Get_Accessible_Content_Items;

-- --------------------------------------------------------------
-- Get_citem_stylesheets
--
-- --------------------------------------------------------------
PROCEDURE Get_Citem_Stylesheets (
 	p_api_version			  IN NUMBER    DEFAULT 1.0,
  p_init_msg_list	  IN VARCHAR2  DEFAULT FND_API.g_false,
  p_content_item_id IN NUMBER,
  p_language        IN VARCHAR2  DEFAULT NULL,
  x_citem_ids       OUT NOCOPY JTF_NUMBER_TABLE,
  x_citem_names     OUT NOCOPY JTF_VARCHAR2_TABLE_100,
 	x_return_status			OUT NOCOPY VARCHAR2,
  x_msg_count			    OUT NOCOPY NUMBER,
  x_msg_data			     OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_items(p_content_item_id NUMBER)
  IS
    SELECT stlshts.content_item_id
      FROM ibc_content_items citems,
           ibc_stylesheets stlshts
     WHERE citems.content_type_code = stlshts.content_type_code
       AND citems.content_item_id = p_content_item_id;

  CURSOR c_item_name(p_content_item_id NUMBER,
                     p_language        VARCHAR2)
  IS
    SELECT MAX(civtl.content_item_name)
      FROM ibc_citem_versions_b civb,
           ibc_citem_versions_tl civtl
     WHERE civb.content_item_id = p_content_item_id
       AND civb.citem_version_id = civtl.citem_version_id
       AND language = p_language;

  --******** local variable for standards **********
  l_api_name     CONSTANT VARCHAR2(40)   := 'Get_Citem_Stylesheets';
  l_api_version		CONSTANT NUMBER := 1.0;
  --
  l_user_id       NUMBER;
  l_dirpath       VARCHAR2(3000);
  l_security_flag VARCHAR2(30);

  TYPE t_num_tbl IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  l_result              t_num_tbl;
  l_count               NUMBER;

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

  l_count := 0;
  FOR r_items IN c_items(p_content_item_id)
  LOOP
    l_count := l_count + 1;
    l_result(l_count) := r_items.content_item_id;
  END LOOP;

  IF l_count > 0 THEN
    x_citem_ids := JTF_NUMBER_TABLE();
    x_citem_names := JTF_VARCHAR2_TABLE_100();
    x_citem_ids.extend(l_count);
    x_citem_names.extend(l_count);
    FOR I IN 1..l_count LOOP
      x_citem_ids(I)   := l_result(I);
      OPEN c_item_name(l_result(I), NVL(p_language, USERENV('lang')));
      FETCH c_item_name INTO x_citem_names(I);
      CLOSE c_item_name;
    END LOOP;
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
END Get_citem_Stylesheets;


END IBC_UTILITIES_GRP;

/
