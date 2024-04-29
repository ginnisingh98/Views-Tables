--------------------------------------------------------
--  DDL for Package Body IBC_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_UTILITIES_PVT" AS
/* $Header: ibcvutlb.pls 120.5 2006/01/20 20:53:33 apulijal ship $ */

-- ---------------------------------------------------
-- ----------- PACKAGE VARIABLES ---------------------
-- ---------------------------------------------------
G_PKG_NAME          CONSTANT VARCHAR2(30):='IBC_Utilities_Pvt';
G_FILE_NAME         CONSTANT VARCHAR2(12):='ibcvutlb.pls';

G_APPL_ID           NUMBER := Fnd_Global.Prog_Appl_Id;
G_LOGIN_ID          NUMBER := Fnd_Global.Conc_Login_Id;
G_PROGRAM_ID        NUMBER := Fnd_Global.Conc_Program_Id;
G_USER_ID           NUMBER := Fnd_Global.User_Id;
G_REQUEST_ID        NUMBER := Fnd_Global.Conc_Request_Id;


/****************************************************
-------------FUNCTIONS--------------------------------------------------------------------------
****************************************************/

FUNCTION getEncoding
  RETURN VARCHAR2
IS
  CURSOR c_nls IS
  select value
  from nls_database_parameters
  where parameter = 'NLS_CHARACTERSET';

l_tmp nls_database_parameters.value%TYPE;

l_encoding VARCHAR2(100);

BEGIN

fnd_profile.GET('ICX_CLIENT_IANA_ENCODING', l_encoding );

RETURN l_encoding;

END getEncoding;

FUNCTION IBC_DECODE(l_base_date DATE, comp1 DATE, date1 DATE, date2 DATE)
  RETURN DATE
IS
BEGIN
    IF l_base_date = comp1 THEN
  RETURN date1;
    ELSE
  RETURN date2;
    END IF;
END IBC_DECODE;

-- --------------------------------------------------------------
-- get_citem_name
--
-- Given content_item_id it returns content item name of
-- the last version for the current language
--
-- --------------------------------------------------------------
FUNCTION get_citem_name(p_content_item_id    IN  NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_name(p_content_item_id NUMBER) IS
    SELECT content_item_name
      FROM ibc_citem_versions_tl
     WHERE citem_version_id = (SELECT citem_version_id
                                 FROM ibc_citem_versions_b civb
                                WHERE content_item_id = p_content_item_id
                                  AND version_number = (SELECT MAX(version_number)
                                                          FROM ibc_citem_versions_b civb2
                                                         WHERE civb2.content_item_id = civb.content_item_id)
                               )
      AND language = USERENV('lang');
  l_citem_name      IBC_CITEM_VERSIONS_TL.content_item_name%TYPE;
BEGIN
  OPEN c_name(p_content_item_id);
  FETCH c_name INTO l_citem_name;
  IF c_name%NOTFOUND THEN
    l_citem_name := NULL;
  END IF;
  CLOSE c_name;
  RETURN l_citem_name;
END get_citem_name;

-- --------------------------------------------------------------
-- get_directory_name
--
-- Given directory_node_id it returns directory name
-- for the current language
--
-- --------------------------------------------------------------
FUNCTION get_directory_name(p_directory_node_id    IN   NUMBER)
RETURN VARCHAR2
IS

  CURSOR c_name(p_directory_node_id NUMBER) IS
    SELECT directory_node_code
      FROM ibc_directory_nodes_b
     WHERE directory_node_id = p_directory_node_id;

  l_directory_name  IBC_DIRECTORY_NODES_B.directory_node_code%TYPE;

BEGIN

  OPEN c_name(p_directory_node_id);
  FETCH c_name INTO l_directory_name;
  IF c_name%NOTFOUND THEN
    l_directory_name := NULL;
  END IF;
  CLOSE c_name;

  RETURN l_directory_name;

END get_directory_name;

-- --------------------------------------------------------------
-- GET RESOURCE NAME
--
-- Used to get resource name by id
--
-- --------------------------------------------------------------
FUNCTION getResourceName(
    f_resource_id    IN    NUMBER
    ,f_resource_type IN   VARCHAR2
)
RETURN VARCHAR2
IS
    -- For performance issues, assuming all resource_types
    -- to be GROUPS, as they are the only one supported for
    -- 11.5.10 version
    CURSOR c_rn IS
        SELECT
            group_name resource_name
        FROM
            jtf_rs_groups_vl
        WHERE
            group_id = f_resource_id;

    temp JTF_RS_RESOURCE_EXTNS_TL.resource_name%TYPE;
BEGIN
    OPEN c_rn;
    FETCH c_rn INTO temp;

    IF (c_rn%NOTFOUND) THEN
        CLOSE c_rn;
        RETURN NULL;
    ELSE
        CLOSE c_rn;
        RETURN temp;
    END IF;
END;

-- --------------------------------------------------------------
-- GET DIRECTORY ID
--
-- Get Directory ID given a Directory Path and node type
--
-- --------------------------------------------------------------
FUNCTION get_directory_node_id(p_directory_path    IN   VARCHAR2,
                               p_node_type         IN   VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR c_dirid IS
        SELECT directory_node_id
          FROM ibc_directory_nodes_b
         WHERE directory_path = p_directory_path
           AND node_type = p_node_type;

    l_dirid  NUMBER;
BEGIN
  OPEN c_dirid;
  FETCH c_dirid INTO l_dirid;

  IF (c_dirid%NOTFOUND) THEN
    l_dirid := NULL;
  END IF;

  CLOSE c_dirid;

  RETURN l_dirid;

END;

-- --------------------------------------------------------------
-- GET Content Item Keywords
--
-- Used to get content item keywords by content_item_id
--
-- --------------------------------------------------------------
FUNCTION getCItemKeywords
(
    pcItemId    IN   NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_kw IS
        SELECT
            keyword
        FROM
            ibc_citem_keywords
        WHERE
            content_item_id=pcItemId;

    x_keywords VARCHAR2(4000);
    l_keyword  VARCHAR2(100);
    l_index    NUMBER :=0;
BEGIN
   OPEN c_kw;
         LOOP
             FETCH c_kw INTO l_keyword;

             EXIT WHEN c_kw%NOTFOUND;
             IF (l_index=0) THEN
                  x_keywords := l_keyword;
             ELSE
                  x_keywords := x_keywords||','||l_keyword;
             END IF;
             l_index :=l_index+1;
         END LOOP;
   CLOSE c_kw;
   RETURN x_keywords;
END;



/****************************************************
-------------PROCEDURES--------------------------------------------------------------------------
****************************************************/
--------------------------------------------------------------------------------
-- Start of comments
--    API name    : get_Language_Description
--    Type        : Private
--    Pre-reqs    : None
--    Description : This procedure takes in the language code and returns the
--                  corresponding language description
--    Parameters  :
--                  p_language_code         IN VARCHAR2
--                  p_language_description  OUT NOCOPY VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_Language_Description (p_language_code IN   VARCHAR2
                                   ,p_language_description OUT NOCOPY VARCHAR2
                                   ) IS
  -- Cursor : c_role_detail
  CURSOR c_language (cv_language_code IN VARCHAR2) IS
  SELECT description
    FROM fnd_languages_vl
   WHERE language_code = cv_language_code;
BEGIN
    -- Get the role detail
    OPEN c_language(p_language_code);
    FETCH c_language INTO p_language_description;
    CLOSE c_language;

EXCEPTION

    WHEN OTHERS THEN
      RAISE;

END Get_Language_Description;



--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Attribute_Bundle
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate the user-defined attributes of IBC output xml to the
--                 incoming CLOB.
--    Parameters :
--    IN         : p_file_id      IN  NUMBER
--       p_xml_clob_loc   IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Attribute_Bundle (
  p_file_id IN    NUMBER,
  p_xml_clob_loc  IN OUT NOCOPY CLOB
) AS
  xmlBlob_loc CLOB;
BEGIN
  IF (p_file_id IS NOT NULL) THEN
     SELECT attribute_bundle_data
      INTO xmlBlob_loc
       FROM IBC_ATTRIBUTE_BUNDLES
     WHERE attribute_bundle_id = p_file_id;

     DBMS_LOB.APPEND(dest_lob => p_xml_clob_loc, src_lob => xmlBlob_loc);
  END IF;

  -- If Content Item does not have user-defined primitive
  -- attributes, do nothing.

END Build_Attribute_Bundle;




PROCEDURE Build_Citem_Open_Tag (
  p_content_type_code   IN    VARCHAR2,
  p_content_item_id   IN    NUMBER,
  p_version_number    IN    NUMBER,
  p_item_reference_code   IN  VARCHAR2,
  p_item_label      IN    VARCHAR2,
  p_xml_clob_loc      IN OUT NOCOPY CLOB
) AS
  l_buffer            VARCHAR2(2000);
  l_item_reference_code   VARCHAR2(100) := '';
  l_item_label      VARCHAR2(120) := '';
BEGIN
  IF (p_item_reference_code IS NOT NULL) THEN
     l_item_reference_code := p_item_reference_code;
  END IF;
  IF (p_item_label IS NOT NULL) THEN
     l_item_label := Fnd_Global.local_chr(38) || 'amp;label=' || p_item_label;
  END IF;

  l_buffer := '<' || p_content_type_code || ' datatype="citem" ' ||
      G_XML_ID || '="' || p_content_item_id || '" ' ||
      G_XML_VERSION || '="' || p_version_number || '" ' ||
      G_XML_IRCODE || '="' || l_item_reference_code || '" ' ||
      G_XML_REF || '="f" ' ||
      G_XML_URL || '="' || Ibc_Utilities_Pub.G_CITEM_SERVLET_URL || 'cItemId=' || p_content_item_id || l_item_label || '">';

  DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_buffer), l_buffer);

END Build_Citem_Open_Tag;




--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Citem_Open_Tags
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Building content item xml open tags.
--------------------------------------------------------------------------------
PROCEDURE Build_Citem_Open_Tags (
  p_content_type_code   IN    VARCHAR2,
  p_content_item_id   IN    NUMBER,
  p_citem_version_id          IN    NUMBER,
  p_item_label      IN    VARCHAR2,
  p_lang_code     IN    VARCHAR2,
  p_version_number    IN    NUMBER,
  p_start_date      IN    DATE,
  p_end_date      IN    DATE,
  p_item_reference_code   IN    VARCHAR2,
  p_encrypt_flag      IN    VARCHAR2,
  p_content_item_name   IN    VARCHAR2,
  p_description     IN    VARCHAR2,
  p_attachment_attribute_code IN    VARCHAR2,
        p_attachment_file_id    IN    NUMBER,
        p_attachment_file_name    IN    VARCHAR2,
  p_default_mime_type   IN    VARCHAR2,
        p_is_preview      IN    VARCHAR2,
  p_xml_clob_loc      IN OUT NOCOPY CLOB
) AS
  l_buffer    VARCHAR2(9000);
  l_item_reference_code IBC_CONTENT_ITEMS.ITEM_REFERENCE_CODE%TYPE := '';
  l_item_label    VARCHAR2(120) := '';

  l_rendition_counter NUMBER := 1;
  l_mime_type   IBC_RENDITIONS.MIME_TYPE%TYPE;
  l_rendition_name  FND_LOOKUP_VALUES.DESCRIPTION%TYPE;
 --
        --// p_lang_code has taken translation approval into account
  CURSOR Get_Renditions IS
  SELECT file_id, file_name, mime_type, language
  FROM IBC_RENDITIONS
  WHERE CITEM_VERSION_ID = p_citem_version_id
  AND LANGUAGE = NVL(p_lang_code, USERENV('LANG'));

        --// p_lang_code has taken translation approval into account
  CURSOR Get_Rendition_Name IS
  SELECT NVL(DESCRIPTION, MEANING)
  FROM FND_LOOKUP_VALUES
  WHERE LOOKUP_TYPE = Ibc_Utilities_Pvt.G_REND_LOOKUP_TYPE
  AND LANGUAGE = NVL(p_lang_code, USERENV('LANG'))
  AND LOOKUP_CODE = l_mime_type;
BEGIN
  IF (p_item_reference_code IS NOT NULL) THEN
     l_item_reference_code := p_item_reference_code;
  END IF;
  IF (p_item_label IS NOT NULL) THEN
     l_item_label := Fnd_Global.local_chr(38) || 'amp;'|| G_XML_URL_LB ||'=' || p_item_label;
  END IF;

  -- // Append Open tag
  l_buffer := '<' || p_content_type_code || ' datatype="citem" ' ||
      G_XML_ID || '="' || p_content_item_id || '" ' ||
      G_XML_VERSION || '="' || p_version_number || '" ' ||
      G_XML_AVAIL || '="' || TO_CHAR(p_start_date, 'yyyy-mm-dd') || '" ' ||
      G_XML_EXPIRE || '="' || TO_CHAR(p_end_date, 'yyyy-mm-dd') || '" ' ||
      G_XML_IRCODE || '="' || l_item_reference_code || '" ' ||
      G_XML_REF || '="f" ' ||
      G_XML_ENC || '="' || LOWER(p_encrypt_flag) || '" ';
        -- // Preview Url
        IF (p_is_preview = FND_API.g_true) THEN
           l_buffer :=  l_buffer ||
                        G_XML_URL || '="' || Ibc_Utilities_Pub.G_PCITEM_SERVLET_URL || 'cItemId=' || p_content_item_id
                                          || Fnd_Global.local_chr(38) || 'amp;cItemVerId=' || p_citem_version_id ||
            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(p_encrypt_flag) ||
                                          '">';
        -- // Runtime Url
  ELSE
           l_buffer :=  l_buffer ||
      G_XML_URL || '="' || Ibc_Utilities_Pub.G_CITEM_SERVLET_URL || G_XML_URL_CID ||'='|| p_content_item_id ||
            l_item_label ||
            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(p_encrypt_flag) ||
                                          '">';
  END IF;

        -- // Rendition tags
  FOR rendition_rec IN Get_Renditions LOOP
    l_mime_type := rendition_rec.mime_type;
    OPEN Get_Rendition_Name;
    FETCH Get_Rendition_Name INTO l_rendition_name;
    IF Get_Rendition_Name%NOTFOUND THEN
       CLOSE Get_Rendition_Name;
       l_mime_type := Ibc_Utilities_Pvt.G_REND_UNKNOWN_MIME;
       OPEN Get_Rendition_Name;
                FETCH Get_Rendition_Name INTO l_rendition_name;
       CLOSE Get_Rendition_Name;
    ELSE
       CLOSE Get_Rendition_Name;
    END IF;

    l_buffer := l_buffer ||
      '<' || Ibc_Utilities_Pub.G_XML_REND_TAG || ' datatype="rendition" ' ||
      G_XML_ID || '="' || rendition_rec.file_id || '" ' ||
      G_XML_REF || '="t" ' ||
      G_XML_FILE || '="' || Replace_Special_Chars(rendition_rec.file_name) || '" ' ||
      G_XML_MIME || '="' || LOWER(rendition_rec.mime_type) || '" ' ||
      G_XML_REND || '="' || l_rendition_name || '" ';
    IF (p_default_mime_type = rendition_rec.mime_type) THEN
      l_buffer := l_buffer || G_XML_DEFAULT_MIME || '="t" ';
    END IF;
    l_buffer := l_buffer ||
--      G_XML_URL || '="' || Ibc_Utilities_Pub.G_SERVLET_URL || G_XML_URL_CID ||'='|| p_content_item_id ||
--            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_FID ||'='|| rendition_rec.file_id ||
--            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(p_encrypt_flag) ||
--            '" />';


      G_XML_URL || '="' || Ibc_Utilities_Pub.G_RENDITION_SERVLET_URL || G_XML_URL_CVERID ||'='|| p_citem_version_id ||
            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_LANG ||'='|| rendition_rec.language ||
            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_MIME ||'='|| rendition_rec.mime_type ||
            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(p_encrypt_flag) ||
            '" />';


    -- check if the concatenated string is going over the buffer size
    IF (l_rendition_counter = 5) THEN
      DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_buffer), l_buffer);
      l_buffer := '';
      l_rendition_counter := 1;
    ELSE
      l_rendition_counter := l_rendition_counter + 1;
    END IF;
  END LOOP;

        -- // Attachment Tag
  IF (p_attachment_file_id IS NOT NULL) THEN
     l_buffer := l_buffer ||
           '<' || p_attachment_attribute_code || ' datatype="attachment" ' ||
                 G_XML_ID || '="' || p_attachment_file_id || '" ' ||
           G_XML_REF || '="t" ' ||
           G_XML_FILE || '="' || p_attachment_file_name || '" ' ||
                       G_XML_URL || '="' || Ibc_Utilities_Pub.G_SERVLET_URL || G_XML_URL_CID ||'='|| p_content_item_id ||
           Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_FID ||'='|| p_attachment_file_id ||
           Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(p_encrypt_flag) ||
           '" />';
  END IF;

  -- // Name and Description tag
  l_buffer := l_buffer ||
              '<NAME datatype="string"><![CDATA[' || p_content_item_name || ']]></NAME>' ||
              '<DESCRIPTION datatype="string"><![CDATA[' || p_description || ']]></DESCRIPTION>';

  DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_buffer), l_buffer);

END Build_Citem_Open_Tags;




--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Citem_Open_Tags
--    Function   : This is for BACKWARD COMPATIBILITY for Admin Usage (Similar to above).
--------------------------------------------------------------------------------
PROCEDURE Build_Citem_Open_Tags (
  p_content_type_code   IN    VARCHAR2,
  p_content_item_id   IN    NUMBER,
  p_version_number    IN    NUMBER,
  p_item_reference_code   IN    VARCHAR2,
  p_content_item_name   IN    VARCHAR2,
  p_description     IN    VARCHAR2,
  p_root_tag_only_flag    IN    VARCHAR2,
  p_xml_clob_loc      IN OUT NOCOPY CLOB
) AS
  l_buffer    VARCHAR2(5000);
  l_item_reference_code VARCHAR2(100) := '';
BEGIN
  IF (p_item_reference_code IS NOT NULL) THEN
     l_item_reference_code := p_item_reference_code;
  END IF;

  l_buffer := '<' || p_content_type_code || ' datatype="citem" ' ||
      G_XML_ID || '="' || p_content_item_id || '" ' ||
      G_XML_VERSION || '="' || p_version_number || '" ' ||
      G_XML_IRCODE || '="' || l_item_reference_code || '" ' ||
      G_XML_REF || '="f" ' ||
      '>';

  -- Include Name, Description and Attachment tags
  IF (p_root_tag_only_flag = Fnd_Api.G_FALSE) THEN
     l_buffer :=  l_buffer ||
      '<NAME datatype="string"><![CDATA[' ||
      p_content_item_name ||
      ']]></NAME>' ||
      '<DESCRIPTION datatype="string"><![CDATA[' ||
      p_description ||
      ']]></DESCRIPTION>';
  END IF;

  DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_buffer), l_buffer);

END Build_Citem_Open_Tags;








PROCEDURE Build_Close_Tag (
  p_close_tag   IN    VARCHAR2,
  p_xml_clob_loc    IN OUT NOCOPY CLOB
) AS
  l_buffer  VARCHAR2(250);
BEGIN
  l_buffer := '</' || p_close_tag || '>';

  DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_buffer), l_buffer);

END Build_Close_Tag;








PROCEDURE Build_Compound_Item_Open_Tag (
  p_attribute_type_code IN    VARCHAR2,
  p_content_item_id IN    NUMBER,
  p_item_label    IN    VARCHAR2,
  p_encrypt_flag    IN    VARCHAR2,
  p_xml_clob_loc    IN OUT NOCOPY CLOB
) AS
  l_buffer    VARCHAR2(300);
  l_item_label    VARCHAR2(100) := '';
BEGIN
  IF (p_item_label IS NOT NULL) THEN
     l_item_label := Fnd_Global.local_chr(38) || 'amp;label=' || p_item_label;
  END IF;

  l_buffer := '<' || p_attribute_type_code || ' datatype="component" ' ||
      G_XML_ID || '="' || p_content_item_id || '" ' ||
      G_XML_REF || '="f" ' ||
      G_XML_URL || '="' || Ibc_Utilities_Pub.G_CITEM_SERVLET_URL || G_XML_URL_CID ||'='|| p_content_item_id ||
            l_item_label ||
            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(p_encrypt_flag) ||
                                          '">';

  DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_buffer), l_buffer);

END Build_Compound_Item_Open_Tag;


PROCEDURE Build_Preview_Cpnt_Open_Tag (
  p_attribute_type_code   IN    VARCHAR2,
  p_content_item_id   IN    NUMBER,
  p_content_item_version_id IN    NUMBER,
  p_encrypt_flag      IN    VARCHAR2,
  p_xml_clob_loc      IN OUT  NOCOPY CLOB
) AS
  l_buffer    VARCHAR2(300);
BEGIN
  l_buffer := '<' || p_attribute_type_code || ' datatype="component" ' ||
      G_XML_ID || '="' || p_content_item_id || '" ' ||
      G_XML_REF || '="f" ' ||
      G_XML_URL || '="' || Ibc_Utilities_Pub.G_PCITEM_SERVLET_URL || G_XML_URL_CID ||'='|| p_content_item_id ||
            Fnd_Global.local_chr(38) || 'amp;cItemVerId=' || p_content_item_version_id ||
            Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(p_encrypt_flag) ||
                                          '">';

  DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_buffer), l_buffer);

END Build_Preview_Cpnt_Open_Tag;







PROCEDURE Build_Compound_Item_References (
  p_citem_version_id  IN    NUMBER,
  p_item_label    IN    VARCHAR2,
  p_xml_clob_loc    IN OUT NOCOPY CLOB
) AS
  l_total_buffer      VARCHAR2(2500) := '';
  l_buffer      VARCHAR2(250);
  l_compound_count    NUMBER := 1;
  l_item_label      VARCHAR2(100) := '';
--
  CURSOR Get_Compound_Item_Ref IS
  SELECT r.ATTRIBUTE_TYPE_CODE, r.CONTENT_ITEM_ID, c.ENCRYPT_FLAG
  FROM IBC_COMPOUND_RELATIONS r, IBC_CONTENT_ITEMS c
  WHERE r.CITEM_VERSION_ID = p_citem_version_id
  AND r.CONTENT_ITEM_ID = c.CONTENT_ITEM_ID
  ORDER BY r.SORT_ORDER;
BEGIN
  IF (p_item_label IS NOT NULL) THEN
     l_item_label := Fnd_Global.local_chr(38) || 'amp;label=' || p_item_label;
  END IF;

  FOR compound_item_rec IN Get_Compound_Item_Ref LOOP
    l_buffer := '<' || compound_item_rec.attribute_type_code || ' datatype="component" ' ||
          G_XML_ID || '="' || compound_item_rec.content_item_id || '" ' ||
          G_XML_REF || '="t" ' ||
          G_XML_URL || '="' || Ibc_Utilities_Pub.G_CITEM_SERVLET_URL || G_XML_URL_CID ||'='|| compound_item_rec.content_item_id ||
                l_item_label ||
                Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(compound_item_rec.encrypt_flag) ||
                                              '" />';

    l_total_buffer := l_total_buffer || l_buffer;

    IF (l_compound_count = 10) THEN
       DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_total_buffer), l_total_buffer);
       l_total_buffer := '';
       l_compound_count := 1;
    END IF;

    l_compound_count := l_compound_count + 1;
  END LOOP;
  IF (l_compound_count > 1) THEN
    DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_total_buffer), l_total_buffer);
  END IF;

END Build_Compound_Item_References;


PROCEDURE Build_Preview_Cpnt_References (
  p_citem_version_id  IN    NUMBER,
  p_xml_clob_loc    IN OUT  NOCOPY CLOB
) AS
  l_total_buffer      VARCHAR2(2500) := '';
  l_buffer      VARCHAR2(250);
  l_compound_count    NUMBER := 1;
  l_component_item_id   NUMBER;
  l_component_version_id    NUMBER;
--
  CURSOR Get_Compound_Item_Ref IS
  SELECT r.ATTRIBUTE_TYPE_CODE, r.CONTENT_ITEM_ID, c.ENCRYPT_FLAG
  FROM IBC_COMPOUND_RELATIONS r, IBC_CONTENT_ITEMS c
  WHERE r.CITEM_VERSION_ID = p_citem_version_id
  AND r.CONTENT_ITEM_ID = c.CONTENT_ITEM_ID
  ORDER BY r.SORT_ORDER;

  CURSOR Get_Cpnt_Latest_Version IS
  SELECT CITEM_VERSION_ID
  FROM IBC_CITEM_VERSIONS_B
  WHERE CONTENT_ITEM_ID = l_component_item_id
  AND VERSION_NUMBER = (SELECT MAX(VERSION_NUMBER)
            FROM IBC_CITEM_VERSIONS_B
            WHERE CONTENT_ITEM_ID = l_component_item_id);
BEGIN
  -- Loop through each component item
  FOR compound_item_rec IN Get_Compound_Item_Ref LOOP
    l_component_item_id := compound_item_rec.content_item_id;
    -- Get the version id of the latest component item version
          OPEN Get_Cpnt_Latest_Version;
       FETCH Get_Cpnt_Latest_Version INTO l_component_version_id;
    CLOSE Get_Cpnt_Latest_Version;

    l_buffer := '<' || compound_item_rec.attribute_type_code || ' datatype="component" ' ||
        G_XML_ID || '="' || l_component_item_id || '" ' ||
        G_XML_REF || '="t" ' ||
        G_XML_URL || '="' || Ibc_Utilities_Pub.G_PCITEM_SERVLET_URL || G_XML_URL_CID ||'='|| l_component_item_id ||
                Fnd_Global.local_chr(38) || 'amp;cItemVerId=' || l_component_version_id ||
                Fnd_Global.local_chr(38) ||'amp;'|| G_XML_URL_ENC ||'='|| LOWER(compound_item_rec.encrypt_flag) ||
                '" />';
    l_total_buffer := l_total_buffer || l_buffer;

    IF (l_compound_count = 10) THEN
       DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_total_buffer), l_total_buffer);
       l_total_buffer := '';
       l_compound_count := 1;
    END IF;

    l_compound_count := l_compound_count + 1;
  END LOOP;
  IF (l_compound_count > 1) THEN
    DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, LENGTH(l_total_buffer), l_total_buffer);
  END IF;

END Build_Preview_Cpnt_References;










PROCEDURE Get_Messages (
p_message_count IN    NUMBER,
x_msgs          OUT NOCOPY VARCHAR2)
IS
      l_msg_list        VARCHAR2(2000) := '
';
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(20) ;
      l_message_name    VARCHAR2(30) ;

      l_id              NUMBER;
      l_message_num     NUMBER;

   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(2000);

      CURSOR Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      CURSOR Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          AND   msg.application_id = x_id
          AND   lng.LANGUAGE_CODE = msg.language_code
          AND   lng.language_id = x_lang_id;
BEGIN
      FOR l_count IN 1..NVL(p_message_count,0) LOOP
          l_temp_msg := Fnd_Msg_Pub.get(Fnd_Msg_Pub.g_next, Fnd_Api.g_true);
          Fnd_Message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id INTO l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;
          IF l_id IS NOT NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        TO_NUMBER(NVL(Fnd_Profile.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num INTO l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := Fnd_Msg_Pub.get(Fnd_Msg_Pub.g_previous, Fnd_Api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || TO_CHAR(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        Fnd_Msg_Pub.get(Fnd_Msg_Pub.g_first, Fnd_Api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        Fnd_Msg_Pub.get(Fnd_Msg_Pub.g_next, Fnd_Api.g_false);
          END IF;

          l_msg_list := l_msg_list || '
';
    EXIT WHEN LENGTH(l_msg_list) > 2000;
      END LOOP;

      x_msgs := SUBSTR(l_msg_list, 0, 2000);

END Get_Messages;












PROCEDURE Handle_Exceptions(
                P_API_NAME        IN    VARCHAR2,
                P_PKG_NAME        IN    VARCHAR2,
                P_EXCEPTION_LEVEL IN    NUMBER,
                P_SQLCODE         IN    NUMBER,
                P_SQLERRM         IN    VARCHAR2,
                P_PACKAGE_TYPE    IN    VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA        OUT NOCOPY VARCHAR2,
          X_RETURN_STATUS   OUT NOCOPY VARCHAR2)
IS
l_api_name    VARCHAR2(30);
l_len_sqlerrm NUMBER ;
i NUMBER := 1;

BEGIN

--DBMS_OUTPUT.PUT_LINE('*******EXCEPTION*******');
--DBMS_OUTPUT.PUT_LINE('API_NAME = '|| P_API_NAME);
--DBMS_OUTPUT.PUT_LINE('SQL_CODE = '|| P_SQLCODE );
--DBMS_OUTPUT.PUT_LINE('ERROR_M = '|| P_SQLERRM);
    l_api_name := UPPER(p_api_name);


    -- DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || p_package_type);

  IF p_exception_level = Fnd_Msg_Pub.G_MSG_LVL_ERROR
    THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_msg_count := Fnd_Msg_Pub.Count_msg();
        x_msg_data  := Fnd_Msg_Pub.get(Fnd_Msg_Pub.G_FIRST);
    ELSIF p_exception_level = Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
    THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := Fnd_Msg_Pub.Count_msg();
        x_msg_data  := Fnd_Msg_Pub.get(Fnd_Msg_Pub.G_FIRST);
    ELSIF p_exception_level = G_EXC_OTHERS
    THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

        Fnd_Message.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        Fnd_Message.Set_token('PKG_NAME' , p_pkg_name);
        Fnd_Message.Set_token('API_NAME' , p_api_name);
        Fnd_Msg_Pub.ADD;

        l_len_sqlerrm := LENGTH(P_SQLERRM) ;
        WHILE l_len_sqlerrm >= i LOOP
          Fnd_Message.Set_Name('IBC', 'IBC_SQLERRM');
          Fnd_Message.Set_token('ERR_TEXT' , SUBSTR(P_SQLERRM,i,240));
          i := i + 240;
          Fnd_Msg_Pub.ADD;
        END LOOP;

        x_msg_count := Fnd_Msg_Pub.Count_msg();
        x_msg_data  := Fnd_Msg_Pub.get(Fnd_Msg_Pub.G_FIRST);

    END IF;

END Handle_Exceptions;










PROCEDURE Handle_Ret_Status(p_return_Status     VARCHAR2)
IS
BEGIN
  IF p_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  ELSIF p_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

END Handle_Ret_Status;











/**************************** INSERT ATTACHMENT *******************/
-- This procedure is used to insert new attachments
--
-- This procedure does not commit the action.
--
-- VARIABLES *Required
-- *p_file_id = fnd_lob file_id that will be assigned to this object
-- *p_file_data = the attachment
-- *p_file_name = name of the file being added
-- *p_mime_type = this is equivalent to p_file_content_type of the
-- -- fnd_lobs table, but is not used with that name to avoid confusion.
-- *p_file_format = only two(2) valid formats: 'text','binary'
--  p_program_tag IN VARCHAR2 DEFAULT NULL
/*******************************************************************/
PROCEDURE insert_attachment(
    x_file_id        OUT NOCOPY NUMBER
    ,p_file_data     IN    BLOB
    ,p_file_name     IN    VARCHAR2
    ,p_mime_type     IN    VARCHAR2
    ,p_file_format   IN    VARCHAR2
    ,p_program_tag   IN   VARCHAR2
    ,x_return_status OUT NOCOPY VARCHAR2
)
IS
    l_api_name CONSTANT VARCHAR2(30) := 'insert_attachment';
BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- *** VALIDATION OF VALUES ******
     -- file format
    IF ((p_file_format <> 'text') AND (p_file_format <> 'binary')) THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.Set_Name('IBC', 'BAD_INPUT_VALUE');
        Fnd_Message.Set_Token('INPUT', 'p_file_format', FALSE);
        Fnd_Msg_Pub.ADD;
    END IF;
     -- mime type
    IF (p_mime_type IS NULL) THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.Set_Name('IBC', 'BAD_INPUT_VALUE');
        Fnd_Message.Set_Token('INPUT', 'p_mime_type', FALSE);
        Fnd_Msg_Pub.ADD;
    END IF;

    -- Getting next fnd_lobs sequence number
    SELECT
    fnd_lobs_s.NEXTVAL
  INTO
    x_file_id
  FROM
    dual;

   INSERT INTO fnd_lobs(
     file_id
     ,file_name
     ,file_content_type
     ,file_data
      ,upload_date
      ,expiration_date
      ,program_name
      ,program_tag
     ,file_format
   )VALUES(
     x_file_id
     ,p_file_name
     ,p_mime_type
     ,p_file_data
      ,SYSDATE
      ,NULL
      ,NULL
      ,p_program_tag
     ,p_file_format
  );

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.Set_Name('IBC', 'LOB_INSERT_ERROR');
        Fnd_Msg_Pub.ADD;
END;





/************ LOG ACTION *******************************/


PROCEDURE log_action(
  p_activity       IN   VARCHAR2
  ,p_parent_value  IN   VARCHAR2
  ,p_object_type   IN   VARCHAR2
  ,p_object_value1 IN   VARCHAR2
  ,p_object_value2 IN   VARCHAR2
  ,p_object_value3 IN   VARCHAR2
  ,p_object_value4 IN   VARCHAR2
  ,p_object_value5 IN   VARCHAR2
  ,p_description   IN   VARCHAR2
)
IS
   temp_rowid  VARCHAR2(100);
   audit_log_id NUMBER;
BEGIN
   Ibc_Audit_Logs_Pkg.insert_row(
      px_audit_log_id            => audit_log_id
      ,p_activity                => p_activity
      ,p_parent_value            => p_parent_value
      ,p_user_id                 => Fnd_Global.user_id
      ,p_time_stamp              => SYSDATE
      ,p_object_type             => p_object_type
      ,p_object_value1           => p_object_value1
      ,p_object_value2           => p_object_value2
      ,p_object_value3           => p_object_value3
      ,p_object_value4           => p_object_value4
      ,p_object_value5           => p_object_value5
      ,p_description             => p_description
      ,p_object_version_number   => 1
      ,x_rowid                   => temp_rowid
   );
END;






/**************************** INSERT ATTRIBUTE BUNDLE ***************/
-- This procedure is used to create new attribute bundles
--
-- This procedure does not commit the action.
--
-- VARIABLES
-- file_id = file id in fnd_lobs given to the lob created.
/*******************************************************************/
PROCEDURE insert_attribute_bundle(
   x_lob_file_id OUT NOCOPY NUMBER
   ,p_new_bundle IN   CLOB
   ,x_return_status OUT NOCOPY VARCHAR2
)
IS
    l_api_name CONSTANT VARCHAR2(30) := 'insert_attribute_bundle';

BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- Getting next fnd_lobs sequence number
    SELECT  ibc_attribute_bundles_s1.NEXTVAL
      INTO x_lob_file_id
      FROM dual;

   INSERT INTO IBC_ATTRIBUTE_BUNDLES(
      attribute_bundle_id
     ,attribute_bundle_data
     ,created_by
     ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
   )VALUES(
     x_lob_file_id
     ,p_new_bundle
    ,FND_GLOBAL.user_id
    ,SYSDATE
    ,FND_GLOBAL.user_id
    ,SYSDATE
    ,FND_GLOBAL.login_id
    ,1
    );
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.Set_Name('IBC', 'LOB_INSERT_ERROR');
        Fnd_Msg_Pub.ADD;
END;






/**************************** TOUCH ATTRIBUTE BUNDLE ***************/
-- This procedure is used to create the attribute bundle before its
-- usage.
--
-- This procedure does not commit the action.
--
-- VARIABLES
-- new_blob = prepared data to be added to fnd_lobs, it also returns a reference
--            to the blob for further additions.
-- exp_date = expiration date to set with data (DEFAULT is NULL).
-- program_tag = VARCHAR2(32) to store added info about blob.
-- file_id = file id in fnd_lobs given to the lob created.
/*******************************************************************/
PROCEDURE touch_attribute_bundle(
   x_lob_file_id OUT NOCOPY NUMBER
   ,p_exp_date IN   DATE
   ,p_program_tag IN   VARCHAR2
   ,x_return_status OUT NOCOPY VARCHAR2
)
IS
    l_api_name CONSTANT VARCHAR2(30) := 'touch_attribute_bundle';
BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- Getting next fnd_lobs sequence number
    SELECT
    fnd_lobs_s.NEXTVAL
  INTO
    x_lob_file_id
  FROM
    dual;

    -- Reserving empty blob with meta-data
    INSERT INTO fnd_lobs(
     file_id,
     file_name,
     file_content_type,
     file_data,
       upload_date,
       expiration_date,
       program_name,
       program_tag,
     file_format)
   VALUES(
     x_lob_file_id,
     'ibc_attributes',
     'text/plain',
     EMPTY_BLOB(),
       SYSDATE,
       p_exp_date,
       'CONTENT_ITEM',
       p_program_tag,
     'text');

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.Set_Name('IBC', 'LOB_INSERT_ERROR');
        Fnd_Msg_Pub.ADD;
END;


  -- ----------------------------------------------------
  -- FUNCTION: Check_Current_User
  -- DESCRIPTION:
  -- Given either user_id or (srch) resource id and type
  -- (mutually exclusive) returns 'TRUE' if it's current user
  -- (in case p_user_id was passed) or current resource exists
  --  in a resource id and type (usally a group).
  -- It's useful to know if a resource is
  -- included in a resource group.
  -- ----------------------------------------------------
  FUNCTION Check_Current_User(
      p_user_id             IN   NUMBER
      ,p_resource_id        IN   NUMBER
      ,p_resource_type      IN   VARCHAR2
      ,p_current_user_id    IN   NUMBER
  ) RETURN VARCHAR2 IS
    l_result               VARCHAR2(30);
    l_dummy                VARCHAR2(2);
    l_current_user_id      NUMBER;

    CURSOR Check_Group(p_user_id IN NUMBER, p_group_id IN NUMBER) IS
      SELECT 'X'
        FROM jtf_rs_groups_denorm rsgroup,
             jtf_rs_group_members rsmember,
             jtf_rs_resource_extns rsextn
       WHERE parent_group_id = p_group_id
         AND rsgroup.group_id = rsmember.group_id
         AND rsmember.delete_flag = 'N'
         AND rsextn.resource_id = rsmember.resource_id
         AND rsextn.user_id = p_user_id;

    CURSOR Check_Individual(p_user_id IN NUMBER, p_resource_id IN NUMBER) IS
      SELECT 'X'
        FROM jtf_rs_resource_extns
       WHERE resource_id = p_resource_id
         AND user_id = p_user_id;

    CURSOR Check_Responsibility(p_user_id IN NUMBER, p_resp_id IN NUMBER) IS
      SELECT 'X'
        FROM fnd_user_resp_groups
       WHERE user_id = p_user_id
         AND responsibility_id = p_resp_id;

  BEGIN
    l_result := 'FALSE';
    l_current_user_id := NVL(p_current_user_id, Fnd_Global.user_id);
    IF p_user_id IS NOT NULL THEN
      IF p_user_id = l_current_user_id THEN
        l_result := 'TRUE';
      END IF;
    ELSE
      IF p_resource_type IN ('GROUP', 'RS_GROUP') THEN
        OPEN Check_Group(l_current_user_id, p_resource_id);
        FETCH Check_Group INTO l_dummy;
        IF Check_Group%FOUND THEN
          l_result := 'TRUE';
        END IF;
        CLOSE Check_Group;
      ELSIF p_resource_type = 'RESPONSIBILITY' THEN
        IF l_current_user_id = FND_GLOBAL.user_id THEN
          IF p_resource_id = FND_GLOBAL.resp_id THEN
            l_result := 'TRUE';
          END IF;
        ELSE
          OPEN Check_Responsibility(l_current_user_id, p_resource_id);
          FETCH Check_Responsibility INTO l_dummy;
          IF Check_Responsibility%FOUND THEN
            l_result := 'TRUE';
          END IF;
          CLOSE Check_Responsibility;
        END IF;
      ELSE
        OPEN Check_Individual(l_current_user_id, p_resource_id);
        FETCH Check_Individual INTO l_dummy;
        IF Check_Individual%FOUND THEN
          l_result := 'TRUE';
        END IF;
        CLOSE Check_Individual;
      END IF;
    END IF;
    RETURN l_result;
  END Check_Current_User;


/**************************** POST INSERT ***************/
-- This procedure is used to recreate the references of the file_id
-- used in ibc_citem_version_tl table. Called from FNDGFU
-- usage.
--
-- This procedure does not commit the action.
--
-- VARIABLES
-- file_id = file id in returned after FNDGFU inserts the file into
-- FND_LOB
/*******************************************************************/
PROCEDURE post_insert(p_file_id  IN   NUMBER,
              p_file_type IN   VARCHAR2)
IS
CURSOR CUR_FND_LOBS
IS
SELECT
  file_id,
  file_name,
  file_content_type,
  file_data,
  upload_date,
  expiration_date,
  program_name,
  program_tag,
  file_format,
  LANGUAGE
FROM
  FND_LOBS
WHERE
  file_id = p_file_id;

CURSOR CUR_CITEM_REN(p_citem_version_id IN NUMBER)
IS
SELECT   rendition_id, citem.citem_version_id,  citem.LANGUAGE,
  default_rendition_mime_type,
  attachment_file_id
FROM
  IBC_RENDITIONS ren,
  ibc_citem_versions_tl citem
WHERE
  citem.citem_version_id   = ren.citem_version_id(+)  AND
  citem.LANGUAGE         = ren.LANGUAGE(+)  AND
  NVL(default_rendition_mime_type,' ') = NVL(mime_type,' ')
  AND citem.citem_version_id = p_citem_version_id;

fnd_lobs_rec    CUR_FND_LOBS%ROWTYPE;

l_citem_version_id  NUMBER;
l_language    VARCHAR2(4);
l_file_name   VARCHAR2(100);
l_app_name    VARCHAR2(10);


l_old_file_id      NUMBER := NULL;

BEGIN

OPEN CUR_FND_LOBS;
FETCH CUR_FND_LOBS INTO fnd_lobs_rec;

l_citem_version_id := SUBSTR(FND_LOBS_REC.program_tag,INSTR(FND_LOBS_REC.program_tag,':',1)+1);
l_app_name       := UPPER(SUBSTR(FND_LOBS_REC.program_tag,1,INSTR(FND_LOBS_REC.program_tag,':',1)-1));
l_language       := FND_LOBS_REC.LANGUAGE;
l_file_name      := SUBSTR(FND_LOBS_REC.file_name,INSTR(FND_LOBS_REC.file_name,'/',-1)+1);


CLOSE CUR_FND_LOBS;

--
-- The below was added to remove any existing attribute files ids or
-- attachment file_ids
-- from FND_LOBS after the content item is loaded from seed. FNDGFU will
-- always insert new files and this file_id will be replaced with the new ones.
-- select the file_id to removed from the fnd lobs
-- Later after the update is done make sure that the file is not referenced any where.
--

BEGIN
  SELECT DECODE(p_file_type,'ATTRIB',ATTRIBUTE_FILE_ID,'ATTACH',ATTACHMENT_FILE_ID) file_id
  INTO l_old_file_id
  FROM  ibc_citem_versions_tl A
  WHERE a.citem_version_id = l_citem_version_id
  AND A.LANGUAGE = USERENV('LANG');
EXCEPTION WHEN OTHERS THEN
  NULL;
END;


UPDATE IBC_CITEM_VERSIONS_TL SET
ATTRIBUTE_FILE_ID   =DECODE(p_file_type,'ATTRIB',p_file_id,ATTRIBUTE_FILE_ID)
,ATTACHMENT_FILE_ID =DECODE(p_file_type,'ATTACH',p_file_id,ATTACHMENT_FILE_ID)
,last_update_date =SYSDATE
WHERE CITEM_VERSION_ID IN   (
SELECT
  b.citem_version_id
FROM
  ibc_citem_versions_tl a,
  ibc_citem_versions_tl b
WHERE
  a.citem_version_id  = l_citem_version_id AND
  NVL(a.attachment_file_id, 0) = NVL(DECODE(p_file_type,'ATTACH',b.attachment_file_id,a.attachment_file_id), 0) AND
  a.attribute_file_id =  DECODE(p_file_type,'ATTRIB',b.attribute_file_id,a.attribute_file_id)    AND
  a.LANGUAGE = b.LANGUAGE    AND
  a.LANGUAGE = l_language)
AND USERENV('LANG') IN (LANGUAGE, source_lang);


IF p_file_type='ATTACH' THEN

  UPDATE FND_LOBS
  SET file_name = (SELECT attachment_file_name FROM ibc_citem_versions_tl
               WHERE attachment_file_id=p_file_id AND ROWNUM=1)
  WHERE file_id = p_file_id;

       BEGIN

     FOR i_rec IN CUR_CITEM_REN(l_citem_version_id)

     LOOP

       Ibc_Renditions_Pkg.LOAD_ROW (
          P_RENDITION_ID    => i_rec.RENDITION_ID
         ,P_LANGUAGE      => i_rec.LANGUAGE
         ,P_FILE_ID       => i_rec.attachment_file_id
         ,P_FILE_NAME     => NULL
         ,P_CITEM_VERSION_ID  => l_CITEM_VERSION_ID
         ,P_mime_type     => i_rec.default_rendition_mime_type
         ,p_OWNER         => 'SEED'
       );


     END LOOP;

       END;

ELSIF p_file_type='ATTRIB' THEN

  UPDATE FND_LOBS
  SET file_name = l_file_name
  WHERE file_id = p_file_id;

END IF;

DELETE FROM fnd_lobs
WHERE file_id = l_old_file_id
AND NOT EXISTS (SELECT NULL FROM ibc_citem_versions_tl
WHERE DECODE(p_file_type,'ATTRIB',ATTRIBUTE_FILE_ID,'ATTACH',ATTACHMENT_FILE_ID) = l_old_file_id);


COMMIT;


END post_insert;


PROCEDURE post_insert_attach(p_file_id IN   NUMBER)
IS

BEGIN
post_insert(p_file_id => p_file_id
      ,p_file_type => 'ATTACH');

END post_insert_attach;


PROCEDURE post_insert_attrib(p_file_id IN   NUMBER)
IS
BEGIN
post_insert(p_file_id => p_file_id
      ,p_file_type => 'ATTRIB');
END post_insert_attrib;

  ---------------------------------------------------------
  -- FUNCTION: g_true
  -- DESCRIPTION: Returns FND_API.g_true, it's useful
  --              to access the value from SQL stmts
  ---------------------------------------------------------
  FUNCTION g_true RETURN VARCHAR2 IS
  BEGIN
    RETURN Fnd_Api.g_true;
  END g_true;

  ---------------------------------------------------------
  -- FUNCTION: g_false
  -- DESCRIPTION: Returns FND_API.g_false, it's useful
  --              to access the value from SQL stmts
  ---------------------------------------------------------
  FUNCTION g_false RETURN VARCHAR2 IS
  BEGIN
    RETURN Fnd_Api.g_false;
  END g_false;

  ---------------------------------------------------------
  -- FUNCTION: Is_Name_Already_Used
  -- DESCRIPTION: Returns TRUE/FALSE, if the name
  --              is already used by a different item or
  --              directory.
  ---------------------------------------------------------
  FUNCTION Is_Name_Already_Used(p_dir_node_id         IN   NUMBER,
                                p_name                IN   VARCHAR2,
                                p_language            IN   VARCHAR2,
                                p_chk_content_item_id IN   NUMBER,
                                p_chk_dir_node_id     IN   NUMBER,
                                x_object_type         OUT NOCOPY VARCHAR2,
                                x_object_id           OUT NOCOPY NUMBER
                               )
  RETURN BOOLEAN
  IS
    l_result      BOOLEAN;
    l_dir_node_id NUMBER;
    l_dummy       VARCHAR2(1);
    l_hidden_flag VARCHAR2(1);

    CURSOR c_dir_info(p_dir_node_id NUMBER) IS
      SELECT hidden_flag
        FROM ibc_directory_nodes_b
       WHERE directory_node_id = p_dir_node_id;

    CURSOR c_chk_name IS
      SELECT 'CITEM', civb.content_item_id
        FROM ibc_citem_versions_b  civb,
             ibc_citem_versions_tl civtl
       WHERE civb.citem_version_id = civtl.citem_version_id
         AND language = NVL(p_language, USERENV('lang'))
         AND civb.content_item_id <> NVL(p_chk_content_item_id, -1)
         AND EXISTS (SELECT 'X'
                       FROM ibc_content_items
                      WHERE directory_node_id = l_dir_node_id
                        AND content_item_id = civb.content_item_id
                    )
         AND UPPER(civtl.content_item_name) = UPPER(p_name)
      UNION
      SELECT 'DIRNODE', dirnodeb.directory_node_id
        FROM ibc_directory_nodes_b dirnodeb,
             ibc_directory_node_rels dirrel
       WHERE dirnodeb.directory_node_id = dirrel.child_dir_node_id
         AND dirrel.parent_dir_node_id = l_dir_node_id
         AND dirnodeb.directory_node_id <> NVL(p_chk_dir_node_id, -1)
         AND UPPER(dirnodeb.directory_node_code) = UPPER(p_name)
      ;

  BEGIN
    l_result := FALSE;

    l_dir_node_id := p_dir_node_id;

    IF l_dir_node_id IS NULL THEN
      IF p_chk_dir_node_id IS NOT NULL THEN
        SELECT parent_dir_node_id
          INTO l_dir_node_id
          FROM ibc_directory_node_rels
         WHERE child_dir_node_id = p_chk_dir_node_id;
      ELSIF p_chk_content_item_id IS NOT NULL THEN
        SELECT directory_node_id
          INTO l_dir_node_id
          FROM ibc_content_items
         WHERE content_item_id = p_chk_content_item_id;
      END IF;
    END IF;

    OPEN c_dir_info(l_dir_node_id);
    FETCH c_dir_info INTO l_hidden_flag;
    CLOSE c_dir_info;

    -- Only checking uniqueness in non-hidden folders
    IF NVL(l_hidden_flag, 'N') = 'N' OR
       p_chk_dir_node_id IS NOT NULL
    THEN
      OPEN c_chk_name;
      FETCH c_chk_name INTO x_object_type, x_object_id;
      l_result := c_chk_name%FOUND;
      CLOSE c_chk_name;
    END IF;

    RETURN l_result;
  EXCEPTION
    WHEN OTHERS THEN
      x_object_type := NULL;
      x_object_id   := NULL;
      RETURN FALSE;

  END Is_Name_Already_Used;

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Create_Autonomous_renditions
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Called from Content Item Screens/AM to create an autonomous
--       Transaction for FND LOBS
-------------------------------------------------------------------------------
PROCEDURE Create_Autonomous_Upload( p_file_name     IN     VARCHAR2,
                                 p_mime_type     IN     VARCHAR2,
           p_file_format   IN     VARCHAR2,
           p_program_tag   IN     VARCHAR2,
           x_return_status OUT    NOCOPY VARCHAR2,
           x_file_id     OUT    NOCOPY NUMBER
               )
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
     -- Getting next fnd_lobs sequence number
SELECT
  fnd_lobs_s.NEXTVAL   INTO    x_file_id
FROM
  dual;

   INSERT INTO fnd_lobs(
    file_id
    ,file_name
    ,file_content_type
    ,file_data
    ,upload_date
    ,expiration_date
    ,program_name
    ,program_tag
    ,file_format
   )VALUES(
    x_file_id
    ,p_file_name
    ,p_mime_type
    ,EMPTY_BLOB()
    ,SYSDATE
    ,NULL
    ,NULL
    ,p_program_tag
    ,p_file_format
 );

COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
     Fnd_Message.Set_Name('IBC', 'LOB_INSERT_ERROR');
        Fnd_Msg_Pub.ADD;

END Create_Autonomous_Upload;

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : get_object_name
--    Type       : Private
--    Pre-reqs   : None
--    Function   : called from associations package to get name and code for
--                 product_associations
-------------------------------------------------------------------------------
PROCEDURE Get_Object_Name(p_assoc_type_code IN   VARCHAR2,
                          p_assoc_object_val1 IN   VARCHAR2,
                          p_assoc_object_val2 IN   VARCHAR2,
                          p_assoc_object_val3 IN   VARCHAR2,
                          p_assoc_object_val4 IN   VARCHAR2,
                          p_assoc_object_val5 IN   VARCHAR2,
                          x_assoc_name        OUT NOCOPY VARCHAR2,
                          x_assoc_code        OUT NOCOPY VARCHAR2,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2
                         )
IS
  CURSOR c_product_info IS
    SELECT description  assoc_name,
           concatenated_segments assoc_code
      FROM mtl_system_items_vl
      WHERE organization_id = p_assoc_object_val1
       AND inventory_item_id = p_assoc_object_val2;

--   CURSOR c_product_category_info IS
--     SELECT CATEGORY_DESC  assoc_name,
--            CONCAT_CAT_PARENTAGE assoc_code
--       FROM ENI_PROD_DEN_HRCHY_PARENTS_V
--       WHERE CATEGORY_ID = p_assoc_object_val2
--        AND CATEGORY_SET_ID = p_assoc_object_val1;

  l_assoc_name   VARCHAR2(200);
  l_assoc_code   VARCHAR2(80);

  l_pcatquery VARCHAR2(1000) := 'SELECT CATEGORY_DESC  assoc_name,CONCAT_CAT_PARENTAGE assoc_code FROM ENI_PROD_DEN_HRCHY_PARENTS_V WHERE CATEGORY_ID = :p_assoc_object_val2 AND CATEGORY_SET_ID = :p_assoc_object_val1';

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF (p_assoc_type_code = 'IBC_PRODUCT') THEN
    OPEN c_product_info;
    FETCH c_product_info INTO l_assoc_name, l_assoc_code;
    CLOSE c_product_info;
    x_assoc_name := l_assoc_name;
    x_assoc_code := l_assoc_code;

  ELSIF (p_assoc_type_code = 'IBC_PRODUCT_CATEGORY') THEN

    -- This is written using dynamic SQL to prevent dependency on ENI when OCM is
        -- is installed in an environment prior to 11.5.10.
        EXECUTE IMMEDIATE l_pcatquery INTO x_assoc_name, x_assoc_code USING p_assoc_object_val2,p_assoc_object_val1;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
END Get_Object_Name;

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : getAttachclob
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns the CLOB from FND_LOBS for the attachment files
--
-------------------------------------------------------------------------------
FUNCTION getAttachclob (p_file_id   NUMBER) RETURN CLOB IS
  l_xmlblob   BLOB;
  l_xmlclob   CLOB;
  l_rawBuffer RAW(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_chunksize INTEGER;
  l_totalLen  INTEGER;
  l_offset    INTEGER := 1;
  l_attrib_id NUMBER;
  l_return_status VARCHAR2(30);
BEGIN

    l_amount := 32767;
    l_offset := 1;

    DBMS_LOB.createtemporary(l_xmlclob, TRUE, 2);

    SELECT file_data
      INTO l_xmlblob
      FROM FND_LOBS
     WHERE file_id = p_file_id;

    l_totalLen := DBMS_LOB.GETLENGTH(l_xmlblob);
    l_chunksize := DBMS_LOB.GETCHUNKSIZE(l_xmlblob);
    IF (l_chunksize < 32767) THEN
      l_amount := (32767 / l_chunksize) * l_chunksize;
    END IF;

    WHILE l_totalLen >= l_amount LOOP
       DBMS_LOB.READ(l_xmlblob, l_amount, l_offset, l_rawBuffer);
       DBMS_LOB.WRITEAPPEND(l_xmlclob, LENGTH(utl_raw.cast_to_varchar2(l_rawBuffer)), utl_raw.cast_to_varchar2(l_rawBuffer));
       l_totalLen := l_totalLen - l_amount;
       l_offset := l_offset + l_amount;
    END LOOP;

    IF l_totalLen > 0 THEN
      DBMS_LOB.READ(l_xmlblob, l_totalLen, l_offset, l_rawBuffer);
      DBMS_LOB.WRITEAPPEND(l_xmlclob, LENGTH(utl_raw.cast_to_varchar2(l_rawBuffer)), utl_raw.cast_to_varchar2(l_rawBuffer));
    END IF;


RETURN l_xmlclob;

END getAttachCLOB;

FUNCTION Replace_Special_Chars (p_string IN VARCHAR2) RETURN VARCHAR2 IS

    l_pos NUMBER;
	l_string VARCHAR2(32767);

BEGIN
         l_string := p_string;
	 l_pos := INSTR(l_string, '&');

	 IF l_pos <> 0 THEN
		 l_string := REPLACE( p_string, '&', Fnd_Global.local_chr(38) ||'amp;');
	 END IF;

	 RETURN l_string;

END Replace_Special_Chars;

END Ibc_Utilities_Pvt;

/
