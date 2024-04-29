--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_ADMIN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_ADMIN_GRP" AS
/* $Header: ibcgciab.pls 120.6 2005/11/09 04:06:19 sharma ship $ */

/*******************************************************************/
/**************************** VARIABLES ****************************/
/*******************************************************************/
G_COMMAND_CREATE     CHAR(1) := 'C';
G_COMMAND_UPDATE     CHAR(1) := 'U';
G_COMMAND_INCREMENT  CHAR(1) := 'I';
G_COMMAND_TRANSLATE  CHAR(1) := 'T';
G_COMMAND_NOTHING    CHAR(1) := 'N';
G_COMMAND_POST_APPROVAL_UPDATE     CHAR(1) := 'P';


/*******************************************************************/
/**************************** FUNCTIONS ****************************/
/*******************************************************************/
-- -------------------
-- ----- PRIVATE -----
-- -------------------

-- Function Conv_To_TblHandler created for STANDARD/perf change for
-- the use of G_MISS_xxx variables.

FUNCTION Conv_To_TblHandler(p_value IN DATE) RETURN DATE
IS
BEGIN
  IF p_value IS NULL THEN
    RETURN FND_API.G_MISS_DATE;
  ELSIF p_value = FND_API.G_MISS_DATE THEN
    RETURN NULL;
  ELSE
    RETURN p_value;
  END IF;
END;

-- Overloaded for Number
FUNCTION Conv_To_TblHandler(p_value IN NUMBER) RETURN NUMBER
IS
BEGIN
  IF p_value IS NULL THEN
    RETURN FND_API.G_MISS_NUM;
  ELSIF p_value = FND_API.G_MISS_NUM THEN
    RETURN NULL;
  ELSE
    RETURN p_value;
  END IF;
END;

-- Overloaded for VARCHAR2
FUNCTION Conv_To_TblHandler(p_value IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  IF p_value IS NULL THEN
    RETURN FND_API.G_MISS_CHAR;
  ELSIF p_value = FND_API.G_MISS_CHAR THEN
    RETURN NULL;
  ELSE
    RETURN p_value;
  END IF;
END;

-- --------------------------------------------------------------
-- EXIST_ITEM_REFERENCE_CODE
--
-- Given a reference code and a content item id will tell if
-- same reference code is being used already by another content item.
--
-- --------------------------------------------------------------
FUNCTION exist_item_reference_code(p_reference_code IN VARCHAR2,
                                   p_content_item_id IN NUMBER)
RETURN BOOLEAN
IS
  l_dummy    VARCHAR2(2);
  l_result   BOOLEAN;
  CURSOR chk_refcode IS
    SELECT 'X'
      FROM ibc_content_items
     WHERE content_item_id <> NVL(p_content_item_id, -1)
       AND item_reference_code = UPPER(p_reference_code);
BEGIN
  l_result := FALSE;
  OPEN chk_refcode;
  FETCH chk_refcode INTO l_dummy;
  l_result := chk_refcode%FOUND;
  CLOSE chk_refcode;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END exist_item_reference_code;

FUNCTION get_mime_type(p_file_type IN VARCHAR2) RETURN VARCHAR2
IS
 l_sc_position   NUMBER;
 l_result        VARCHAR2(256);
BEGIN
 --DBMS_OUTPUT.put_line('=>Get_Mime_Type');

 l_sc_position := INSTR(p_file_type, ';');
 IF l_sc_position > 0 THEN
   l_result := UPPER(SUBSTR(p_file_type, 1, l_sc_position - 1));
 ELSE
   l_result := UPPER(p_file_type);
 END IF;
 --DBMS_OUTPUT.put_line('<=Get_Mime_Type result:' || l_result);

--
-- The OCM upload process should be consistent in dealing with the MIME type for
-- an RTF document since there are more than one type of mime type associated with
-- RTF.
-- All RTF rendition will be stored as 'TEXT/RICHTEXT'
-- srrangar made this change to fix Bug# 3261798

IF l_result IN ('APPLICATION/RTF','APPLICATION/X-RTF','TEXT/RICHTEXT') THEN
  l_result := 'TEXT/RICHTEXT';
END IF;

--
 RETURN l_result;
END;

-- --------------------------------------------------------------
-- DELETE ATTRIBUTE BUNDLE
--
-- Used delete the attribute bundle.  This function does NOT edit
-- the information about the lob located in the ibc_citem_versions_tl table.
--
-- --------------------------------------------------------------
FUNCTION deleteAttributeBundle(
    f_citem_ver_id   IN  NUMBER
    ,f_language      IN  VARCHAR2 DEFAULT USERENV('LANG')
    ,f_log_action    IN  VARCHAR2 DEFAULT FND_API.g_true
)
RETURN VARCHAR2
IS
    old_file_id NUMBER;

    CURSOR c_bundle IS
        SELECT
            attribute_file_id
        FROM
            ibc_citem_versions_tl
        WHERE
            citem_version_id = f_citem_ver_id
        AND
            LANGUAGE = f_language;
BEGIN


 IF IBC_DEBUG_PVT.debug_enabled THEN
   IBC_DEBUG_PVT.start_process(
      p_proc_type  => 'FUNCTION',
      p_proc_name  => 'DeleteAttributeBundle',
      p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                        p_tag     => 'PARAMETERS',
                        p_parms   => JTF_VARCHAR2_TABLE_4000(
                                       'f_citem_ver_id', f_citem_ver_id,
                                       'f_language', f_language,
                                       'f_log_action', f_log_action
                                     )
                        )
   );
 END IF;
                                                                    --DBMS_OUTPUT.put_line('----- deleteAttributeBundle -----');
    OPEN c_bundle;
    FETCH c_bundle INTO old_file_id;


    IF (c_bundle%NOTFOUND) THEN
        -- attribute bundle does not exist!
        CLOSE c_bundle;
        RETURN FND_API.G_RET_STS_ERROR;
    ELSE
        -- bundle exists, now delete it (if it is not null)!
        IF (old_file_id IS NOT NULL) THEN
           DELETE
             FROM ibc_attribute_bundles
           WHERE attribute_bundle_id = old_file_id;

           -- Log it!
           IF ( f_log_action = FND_API.g_true) THEN
                                  --***************************************************
                                  --************ADDING TO AUDIT LOG********************
                                  --***************************************************
                                  Ibc_Utilities_Pvt.log_action(
                                      p_activity       => Ibc_Utilities_Pvt.G_ALA_REMOVE
                                      ,p_parent_value  => f_citem_ver_id
                                      ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ATTRIBUTE_BUNDLE
                                      ,p_object_value1 => old_file_id
                                      ,p_object_value2 => NULL
                                      ,p_object_value3 => NULL
                                      ,p_object_value4 => NULL
                                      ,p_object_value5 => NULL
                                      ,p_description   => 'Removing attribute bundle'
                                  );
                                  --***************************************************
           END IF; -- log action
        END IF; -- if not null
        CLOSE c_bundle;

        IF IBC_DEBUG_PVT.debug_enabled THEN
          IBC_DEBUG_PVT.end_process(
            IBC_DEBUG_PVT.make_parameter_list(
              p_tag    => 'OUTPUT',
              p_parms  => JTF_VARCHAR2_TABLE_4000(
                            '_RETURN', FND_API.G_RET_STS_SUCCESS
                          )
            )
          );
        END IF;

        RETURN FND_API.G_RET_STS_SUCCESS;
    END IF;
 EXCEPTION
   WHEN OTHERS THEN
     IF IBC_DEBUG_PVT.debug_enabled THEN
       IBC_DEBUG_PVT.end_process(
         IBC_DEBUG_PVT.make_parameter_list(
           p_tag    => 'OUTPUT',
           p_parms  => JTF_VARCHAR2_TABLE_4000(
                         '_RETURN', '*** EXCEPTION *** [' || SQLERRM || ']'
                       )
         )
       );
     END IF;
     RAISE;

 END;

-- --------------------------------------------------------------
-- GET ATTACHMENT ATTRIBUTE CODE
--
-- Used to get attachment attribute code from version id
--
-- --------------------------------------------------------------
FUNCTION getAttachAttribCode(
    f_citem_id   IN  NUMBER
)
RETURN VARCHAR2
IS
    temp IBC_ATTRIBUTE_TYPES_B.attribute_type_code%TYPE;

    CURSOR c_acode IS
    SELECT
        ibc_attribute_types_b.attribute_type_code
    FROM
      ibc_attribute_types_b
        ,ibc_content_items
    WHERE
        ibc_content_items.content_item_id = f_citem_id
    AND
        ibc_attribute_types_b.content_type_code = ibc_content_items.content_type_code
    AND
        ibc_attribute_types_b.data_type_code = Ibc_Utilities_Pub.G_DTC_ATTACHMENT;

BEGIN
                                                                   --DBMS_OUTPUT.put_line('----- getAttachAttribCode-----');
    OPEN c_acode;
    FETCH c_acode INTO temp;

    IF (c_acode%NOTFOUND) THEN
        -- no attribute code found
        CLOSE c_acode;
        RETURN NULL;
    ELSE
        -- code found!
        CLOSE c_acode;
        RETURN temp;
    END IF;
 END;

-- --------------------------------------------------------------
-- GET ATTACHMENT FILE NAME
--
-- --------------------------------------------------------------
FUNCTION getAttachFileName(
    f_file_id   IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_fname IS
    SELECT
        file_name
    FROM
        fnd_lobs
    WHERE
        file_id = f_file_id;

    temp FND_LOBS.file_name%TYPE;
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- getAttachFileName -----');
  OPEN c_fname;
  FETCH c_fname INTO temp;

  IF(c_fname%NOTFOUND) THEN
      -- no file name found
      CLOSE c_fname;
      RETURN NULL;
    ELSE
        -- found!
        CLOSE c_fname;
        RETURN temp;
    END IF;
 END;

-- --------------------------------------------------------------
-- GET ATTRIBUTE FILE ID
--
-- Used to get attribute file id of a specific item version
--
-- --------------------------------------------------------------
FUNCTION getAttribFID(
    f_citem_ver_id   IN  NUMBER
    ,f_language      IN  VARCHAR2 DEFAULT USERENV('LANG')
)
RETURN NUMBER
IS
    CURSOR c_afid IS
        SELECT
            attribute_file_id
        FROM
            ibc_citem_versions_tl
        WHERE
            citem_version_id = f_citem_ver_id
        AND
            LANGUAGE = f_language;

    temp NUMBER;
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- getAttribFID -----');
   OPEN c_afid;
   FETCH c_afid INTO temp;

   IF (c_afid%NOTFOUND) THEN
        -- not found!
        CLOSE c_afid;
        RETURN NULL;
   ELSE
        -- found!
        CLOSE c_afid;
        RETURN temp;
    END IF;
 END;


-- --------------------------------------------------------------
-- GET ATTRIBUTE TYPE NAME (Translated)
--
-- Get Attribute type name given content type code, attribute type code,
-- and language
--
-- --------------------------------------------------------------
FUNCTION Get_Attribute_Type_Name(
    p_content_type_code    IN VARCHAR2
    ,p_attribute_type_code IN VARCHAR2
    ,p_language            IN  VARCHAR2 DEFAULT USERENV('LANG')
)
RETURN VARCHAR2
IS
  l_result    VARCHAR2(80);
  CURSOR c_attribute_type IS
      SELECT attribute_type_name
        FROM ibc_attribute_types_tl
       WHERE content_type_code = p_content_type_code
         AND attribute_type_code = p_attribute_type_code
         AND LANGUAGE = p_language;

BEGIN

  l_result := NULL;
  OPEN c_attribute_type;
  FETCH c_attribute_type INTO l_result;
  CLOSE c_attribute_type;
  RETURN l_result;

END;

-- --------------------------------------------------------------
-- GET CONTENT ITEM STATUS
--
-- Used to get the status of the content item
--
-- --------------------------------------------------------------
FUNCTION getContentItemStatus(
    f_content_item_id  IN  NUMBER
) RETURN VARCHAR
IS
    CURSOR c_base IS
        SELECT
            content_item_status
        FROM
         ibc_content_items
        WHERE
            content_item_id = f_content_item_id;

    temp IBC_CONTENT_ITEMS.content_item_status%TYPE;
BEGIN
                                                                      --DBMS_OUTPUT.put_line('----- getBaseLanguage -----');

    OPEN c_base;
    FETCH c_base INTO temp;

    IF(c_base%NOTFOUND)THEN
        -- not found!
        CLOSE c_base;
        RETURN NULL;
    ELSE
        -- found!
        CLOSE c_base;
        RETURN temp;
    END IF;

 END;

-- --------------------------------------------------------------
-- GET BASE LANGUAGE
--
-- Used to get the version number of the content item
--
-- --------------------------------------------------------------
FUNCTION getBaseLanguage(
    f_content_item_id  IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_base IS
        SELECT
            base_language
        FROM
         ibc_content_items
        WHERE
            content_item_id = f_content_item_id;

    temp IBC_CONTENT_ITEMS.base_language%TYPE;
BEGIN
                                                                      --DBMS_OUTPUT.put_line('----- getBaseLanguage -----');

    OPEN c_base;
    FETCH c_base INTO temp;

    IF(c_base%NOTFOUND)THEN
        -- not found!
        CLOSE c_base;
        RETURN NULL;
    ELSE
        -- found!
        CLOSE c_base;
        RETURN temp;
    END IF;

 END;

-- --------------------------------------------------------------
-- GET CONTENT ITEM ID
--
-- Used to get content item id from version id
--
-- --------------------------------------------------------------
FUNCTION getCitemId(
    f_citem_version_id   IN  NUMBER
)
RETURN NUMBER
IS
    CURSOR c_item IS
        SELECT
            content_item_id
        FROM
          ibc_citem_versions_b
        WHERE
            citem_version_id = f_citem_version_id;

    temp NUMBER;
BEGIN
                                                                     --DBMS_OUTPUT.put_line('----- getCitemId -----');
    OPEN c_item;
    FETCH c_item INTO temp;

    IF (c_item%NOTFOUND) THEN
        -- not found!
        CLOSE c_item;
        RETURN NULL;
    ELSE
        -- found!
        CLOSE c_item;
        RETURN temp;
    END IF;
 END getCitemId;

-- --------------------------------------------------------------
-- GET MAX VERSION ID
--
-- Used to get the maximum content item version id for a content item
--
-- --------------------------------------------------------------
FUNCTION getMaxVersionId(
    f_content_item_id   IN  NUMBER
)
RETURN NUMBER
IS
    CURSOR c_maxv IS
        SELECT
          MAX(citem_version_id)
        FROM
          ibc_citem_versions_b
        WHERE
          content_item_id = f_content_item_id;

    temp NUMBER;
BEGIN
                                                                     --DBMS_OUTPUT.put_line('----- getMaxVersionId -----');
    OPEN c_maxv;
    FETCH c_maxv INTO temp;

    IF (c_maxv%NOTFOUND) THEN
        -- not found!
        CLOSE c_maxv;
        RETURN NULL;
    ELSE
        -- found!
        CLOSE c_maxv;
        RETURN temp;
    END IF;
 END;

-- --------------------------------------------------------------
-- HAS PERMISSION
--
-- Checks permissions to a content item
--
-- --------------------------------------------------------------
FUNCTION hasPermission(
    f_content_item_id   IN NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_perm IS
        SELECT
            locked_by_user_id
        FROM
            ibc_content_items
        WHERE
            content_item_id = f_content_item_id
        AND
            ( (locked_by_user_id IS NULL)
        OR
            (locked_by_user_id = FND_GLOBAL.user_id) );


    temp NUMBER;
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- hasPermission -----');
   -- checking locking first
  OPEN c_perm;
  FETCH c_perm INTO temp;

    IF (c_perm%NOTFOUND) THEN
        -- not found!
        CLOSE c_perm;
        RETURN FND_API.g_false;
    ELSE
        -- found!
        CLOSE c_perm;
        RETURN FND_API.g_true;
    END IF;
 END;

-- --------------------------------------------------------------
-- HAS ASSOCIATIONS
--
-- Checks if a content item has associations
--
-- --------------------------------------------------------------
FUNCTION Has_Associations(
    p_content_item_id   IN NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_check IS
       SELECT association_id
        FROM IBC_ASSOCIATIONS
       WHERE content_item_id = p_content_item_id;
    temp NUMBER;
BEGIN
  OPEN c_check;
  FETCH c_check INTO temp;

 IF (c_check%NOTFOUND) THEN
   -- not found!
   CLOSE c_check;
   RETURN FND_API.g_false;
 ELSE
   -- found!
   CLOSE c_check;
   RETURN FND_API.g_true;
 END IF;
END Has_Associations;


-- --------------------------------------------------------------
-- isItemaSubItem
--
-- Used to see if the item is a Sub-Item
--
-- --------------------------------------------------------------
FUNCTION isItemaSubItem(p_content_item_id IN NUMBER) RETURN BOOLEAN
IS
  l_dummy    VARCHAR2(2);
  l_result   BOOLEAN;
  CURSOR cur IS
    SELECT 'X'
      FROM ibc_compound_relations
     WHERE content_item_id = p_content_item_id;

BEGIN
  l_result := FALSE;
  OPEN cur;
  FETCH cur INTO l_dummy;
    l_result := cur%FOUND;
  CLOSE cur;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END isItemaSubItem;



-- --------------------------------------------------------------
-- HAS CATEGORIES
--
-- Checks if a content item has categories
--
-- --------------------------------------------------------------
FUNCTION Has_categories(
    p_content_item_id   IN NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_check IS
       SELECT content_item_node_id
        FROM IBC_CONTENT_ITEM_NODES
       WHERE content_item_id = p_content_item_id;
    temp NUMBER;
BEGIN
  OPEN c_check;
  FETCH c_check INTO temp;

 IF (c_check%NOTFOUND) THEN
   -- not found!
   CLOSE c_check;
   RETURN FND_API.g_false;
 ELSE
   -- found!
   CLOSE c_check;
   RETURN FND_API.g_true;
 END IF;
END Has_Categories;


-- --------------------------------------------------------------
-- IS_A_DEFAULT_STYLESHEET
--
-- Checks if a content item is a default stylesheet for any content type
--
-- --------------------------------------------------------------
FUNCTION Is_A_Default_Stylesheet(
    p_content_item_id   IN NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_check IS
       SELECT 'X'
        FROM IBC_STYLESHEETS
       WHERE content_item_id = p_content_item_id
         AND default_stylesheet_flag = FND_API.g_true;
    l_dummy VARCHAR2(1);
BEGIN
  OPEN c_check;
  FETCH c_check INTO l_dummy;

 IF (c_check%NOTFOUND) THEN
   -- not found!
   CLOSE c_check;
   RETURN FND_API.g_false;
 ELSE
   -- found!
   CLOSE c_check;
   RETURN FND_API.g_true;
 END IF;
END Is_A_Default_Stylesheet;

-- --------------------------------------------------------------
-- IS ITEM ADMINISTRATOR
--
-- Checks to see if user is creator or owner
--
-- --------------------------------------------------------------
FUNCTION isItemAdmin(
    f_content_item_id   IN NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_admin IS
        SELECT
            owner_resource_id
            ,owner_resource_type
            ,created_by
        FROM
            ibc_content_items
        WHERE
            content_item_id = f_content_item_id;


    ori NUMBER;
    ort IBC_CONTENT_ITEMS.owner_resource_type%TYPE;
    cby NUMBER;

BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- isItemAdmin-----');
   -- checking locking first
  OPEN c_admin;
  FETCH c_admin INTO ori,ort,cby;

    IF (c_admin%NOTFOUND) THEN
        -- not found!
        CLOSE c_admin;
        RETURN FND_API.g_false;
    -- if creator
    ELSIF (cby = FND_GLOBAL.user_id) THEN
        CLOSE c_admin;
        RETURN FND_API.g_true;
    -- if owner (USER_ID)
    ELSIF ort IS NULL
      AND ori = FND_GLOBAL.user_id
    THEN
        CLOSE c_admin;
        RETURN FND_API.g_true;
    -- if owner (Resource)
    ELSIF (IBC_UTILITIES_PVT.check_current_user(
                                 p_user_id         => NULL
                                 ,p_resource_id    => ori
                                 ,p_resource_type  => ort ) = 'TRUE') THEN
        CLOSE c_admin;
        RETURN FND_API.g_true;
    -- was not owner or creator
    ELSE
        CLOSE c_admin;
        RETURN FND_API.g_false;
    END IF;
 END;

-- --------------------------------------------------------------
-- IS CORRECT CONTENT TYPE
--
-- Used to get content item id from version id
--
-- --------------------------------------------------------------
FUNCTION isCorrectContentType(
     f_content_item_id     IN NUMBER
    ,f_content_type_code   IN VARCHAR2
    ,f_attribute_type_code IN VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_cct IS
        SELECT a.reference_code
          FROM ibc_attribute_types_b a,
               ibc_content_items b
         WHERE b.content_item_id = f_content_item_id
           AND b.content_type_code = a.content_type_code
           AND a.attribute_type_code = f_attribute_type_code
           AND a.reference_code = f_content_type_code;

    temp IBC_ATTRIBUTE_TYPES_B.reference_code%TYPE;
BEGIN
                                                                     --DBMS_OUTPUT.put_line('----- isCorrectContentType -----');
    OPEN c_cct;
    FETCH c_cct INTO temp;

    IF (c_cct%NOTFOUND) THEN
        -- not found!
        CLOSE c_cct;
        RETURN FND_API.g_false;
    ELSE
        -- found!
        CLOSE c_cct;
        RETURN FND_API.g_true;
    END IF;
 END;

-- --------------------------------------------------------------
-- GET DIRECTORY NODE
--
-- Used to check if the content item exists and to get the content
-- -- type code
--
-- --------------------------------------------------------------
FUNCTION getDirectoryNodeId(
    f_content_item_id  IN  NUMBER
)
RETURN NUMBER
IS
    CURSOR c_dir IS
        SELECT
           directory_node_id
        FROM
         ibc_content_items
        WHERE
            content_item_id = f_content_item_id;

    temp NUMBER;
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- getDirectoryNodeId -----');
    OPEN c_dir;
    FETCH c_dir INTO temp;

    IF(c_dir%NOTFOUND) THEN
        -- not found!
        CLOSE c_dir;
        RETURN NULL;
    ELSE
        -- found!
        CLOSE c_dir;
        RETURN temp;
    END IF;
END;

-- --------------------------------------------------------------
-- GET CONTENT TYPE
--
-- Used to check if the content item exists and to get the content
-- -- type code
--
-- --------------------------------------------------------------
FUNCTION getContentType(
    f_content_item_id  IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_ctype IS
        SELECT
           content_type_code
        FROM
         ibc_content_items
        WHERE
            content_item_id = f_content_item_id;

    temp IBC_CONTENT_TYPES_B.content_type_code%TYPE;
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- getContentType -----');
    OPEN c_ctype;
    FETCH c_ctype INTO temp;

    IF(c_ctype%NOTFOUND) THEN
        -- not found!
        CLOSE c_ctype;
        RETURN NULL;
    ELSE
        -- found!
        CLOSE c_ctype;
        RETURN temp;
    END IF;
END;

-- --------------------------------------------------------------
-- GET CONTENT TYPE by VERSION
--
-- Used to check if the content item exists and to get the content
-- -- type code
--
-- --------------------------------------------------------------
FUNCTION getContentTypeV(
    f_citem_ver_id  IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_ctypev IS
        SELECT
            ibc_content_items.content_type_code
        FROM
            ibc_content_items
          ,ibc_citem_versions_b
        WHERE
            ibc_citem_versions_b.content_item_id = ibc_content_items.content_item_id
        AND
            ibc_citem_versions_b.citem_version_id = f_citem_ver_id;
    temp IBC_CONTENT_TYPES_B.content_type_code%TYPE;
BEGIN
                                                                     --DBMS_OUTPUT.put_line('----- getContentTypeV -----');
    OPEN c_ctypev;
    FETCH c_ctypev INTO temp;

    IF(c_ctypev%NOTFOUND) THEN
        -- not found!
        CLOSE c_ctypev;
        RETURN NULL;
    ELSE
        -- found!
        CLOSE c_ctypev;
        RETURN temp;
    END IF;

 END;

-- --------------------------------------------------------------
-- GET MAX VERSION
--
-- Used to get the version number of the content item
--
-- --------------------------------------------------------------
FUNCTION getMaxVersion(
    f_content_item_id  IN  NUMBER
)
RETURN NUMBER
IS
    CURSOR c_max IS
        SELECT
            MAX(version_number)
        FROM
         ibc_citem_versions_b
        WHERE
            content_item_id = f_content_item_id;

    temp NUMBER;
BEGIN
                                                                      --DBMS_OUTPUT.put_line('----- getMaxVersion -----');

    OPEN c_max;
    FETCH c_max INTO temp;

    IF(c_max%NOTFOUND) THEN
        -- not found so set to 0 so when incremented it will be 1!
        temp := 0;
    END IF;

    CLOSE c_max;
    RETURN temp;

 END;

-- -------------------
-- ----- PUBLIC ------
-- -------------------

-- --------------------------------------------------------------
-- GET OBJECT VERSION NUMBER
--
-- Used to get attribute file id of a specific item version
--
-- --------------------------------------------------------------
FUNCTION getObjVerNum(
    f_citem_id   IN  NUMBER
)
RETURN NUMBER
IS
    CURSOR c_ovn IS
        SELECT
          object_version_number
        FROM
          ibc_content_items
        WHERE
          content_item_id = f_citem_id;

    temp NUMBER;
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- getObjVerNum -----');
  OPEN c_ovn;
  FETCH c_ovn INTO temp;

  IF (c_ovn%NOTFOUND) THEN
      CLOSE c_ovn;
      RETURN NULL;
  ELSE
      CLOSE c_ovn;
      RETURN temp;
  END IF;
 END;

/********************************************************************/
/**************************** PROCEDURES ****************************/
/********************************************************************/
-- -------------------
-- ----- PRIVATE -----
-- -------------------

-- --------------------------------------------------------------
-- CHANGE LOCK
--
-- --------------------------------------------------------------
PROCEDURE changeLock(
    f_content_item_id   IN  NUMBER
    ,f_new_lock  IN  NUMBER
)
IS
BEGIN
                                                                       --DBMS_OUTPUT.put_line('----- changeLock -----');
        UPDATE
            ibc_content_items
        SET
            locked_by_user_id = f_new_lock
        WHERE
            content_item_id = f_content_item_id;
END;

-- --------------------------------------------------------------
-- CREATE ATTRIBUTE BUNDLE
--
-- Used to get the arrays for an attribute bundle and create a clob
-- with that data.
-- --------------------------------------------------------------
 PROCEDURE create_attribute_bundle(
    px_attribute_bundle     IN OUT NOCOPY CLOB
    ,p_attribute_type_codes IN JTF_VARCHAR2_TABLE_100
    ,p_attributes           IN JTF_VARCHAR2_TABLE_32767
    ,p_ctype_code           IN VARCHAR2
    ,x_return_status        IN OUT NOCOPY VARCHAR2
)
IS
    counter NUMBER := 1; -- loop counter for tables
    qty_codes NUMBER; -- total quantity of attribute codes to process
    temp_text VARCHAR2(32767); -- max input size plus padding
    temp_attribute VARCHAR2(32767);
    att_size NUMBER; -- loop variable -- max size of attribute
    att_type IBC_ATTRIBUTE_TYPES_B.attribute_type_code%TYPE; -- loop variable -- type of attribute
    required NUMBER;
    cont_flag VARCHAR2(1);  -- continue flag

    CURSOR c_attribute_type(p_attribute_type_code IN VARCHAR2) IS
      SELECT data_type_code
             ,data_length
             ,min_instances
        FROM ibc_attribute_types_b
       WHERE attribute_type_code = p_attribute_type_code
         AND content_type_code = p_ctype_code;

BEGIN

 IF IBC_DEBUG_PVT.debug_enabled THEN
   IBC_DEBUG_PVT.start_process(
      p_proc_type  => 'PROCEDURE',
      p_proc_name  => 'Create_Attribute_Bundle',
      p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                        p_tag     => 'PARAMETERS',
                        p_parms   => JTF_VARCHAR2_TABLE_32767(
                                       'p_attribute_type_codes', IBC_DEBUG_PVT.make_list(p_attribute_type_codes),
                                       'p_attributes', IBC_DEBUG_PVT.make_list_VC32767(p_attributes),
                                       'p_ctype_code', p_ctype_code
                                     )
                        )
   );
 END IF;
                                                                         --DBMS_OUTPUT.put_line('----- create_attribute_bundle -----');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ((p_attribute_type_codes IS NOT NULL) AND (p_attributes IS NOT NULL)) THEN
        qty_codes := p_attribute_type_codes.COUNT;

        -- basic table/array validation (making sure that they are truly parallel)
        IF (qty_codes <> p_attributes.COUNT) THEN
           --DBMS_OUTPUT.put_line('EX - uneven attribute arrays');
           x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'ATTRIBUTE_ARRAY_ERROR');
           FND_MSG_PUB.ADD;
        ELSE
        -- loop for each record in the arrays
            LOOP
                cont_flag := FND_API.g_true;

                IF( (UPPER(p_attribute_type_codes(counter)) = 'NAME') OR (UPPER(p_attribute_type_codes(counter)) = 'DESCRIPTION') ) THEN
                    --DBMS_OUTPUT.put_line('EX - reserved type code');
                    cont_flag := FND_API.g_false;
                    FND_MESSAGE.Set_Name('IBC', 'RESERVED_TYPE_CODE_ERROR');
                    FND_MESSAGE.Set_Token('CODE', p_attribute_type_codes(counter), FALSE);
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF (cont_flag = FND_API.g_true) THEN
                    OPEN c_attribute_type(p_attribute_type_codes(counter));
                    FETCH c_attribute_type INTO att_type, att_size, required;
                    IF c_attribute_type%NOTFOUND THEN
                       cont_flag := FND_API.g_false;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       FND_MESSAGE.Set_Name('IBC', 'INVALID_ATT_TYPE');
                       FND_MESSAGE.Set_Token('TYPE_CODE', p_attribute_type_codes(counter));
                       FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE c_attribute_type;
                END IF;

                IF (cont_flag = FND_API.g_true) THEN
                    -- *********************************************
                    -- ********** DATATYPE VALIDATION **************
                    -- *********************************************


                    -- cleaning up inputted value
                    temp_attribute := TRIM(p_attributes(counter));

                    -- Checking primitive types only!
                    -- null allowed?
                    IF (temp_attribute IS NULL) THEN
                        IF (required > 0) THEN
                            FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_REQUIRED');
                            FND_MESSAGE.Set_Token('ATTRIBUTE_NAME', get_Attribute_type_name(p_ctype_code, p_attribute_type_codes(counter)), FALSE);
                            FND_MSG_PUB.ADD;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                    -- string length
                    ELSIF (att_type = IBC_UTILITIES_PUB.G_DTC_TEXT) THEN
                        IF (LENGTH(temp_attribute) > att_size) THEN
                            FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_DATA_LENGTH');
                            FND_MESSAGE.Set_Token('ATTRIBUTE_NAME', get_Attribute_type_name(p_ctype_code, p_attribute_type_codes(counter)), FALSE);
                            FND_MESSAGE.Set_Token('DATA_LENGTH', att_size);
                            FND_MSG_PUB.ADD;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                    -- number (decimal)
                    ELSIF (att_type = IBC_UTILITIES_PUB.G_DTC_NUMBER) THEN
                        IF (IBC_VALIDATE_PVT.isNumber(temp_attribute) = FND_API.g_false) THEN
                            FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_INVALID_NUMBER');
                            FND_MESSAGE.Set_Token('ATTRIBUTE_NAME', get_Attribute_type_name(p_ctype_code, p_attribute_type_codes(counter)), FALSE);
                            FND_MSG_PUB.ADD;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                    -- date (datetime)
                    ELSIF (att_type = IBC_UTILITIES_PUB.G_DTC_DATE) THEN
                        IF (IBC_VALIDATE_PVT.isDate(temp_attribute) = FND_API.g_false) THEN
                            FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_INVALID_DATE');
                            FND_MESSAGE.Set_Token('ATTRIBUTE_NAME', get_Attribute_type_name(p_ctype_code, p_attribute_type_codes(counter)), FALSE);
                            FND_MSG_PUB.ADD;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                    -- boolean
                    ELSIF (att_type = IBC_UTILITIES_PUB.G_DTC_BOOLEAN) THEN
                        IF (IBC_VALIDATE_PVT.isBoolean(temp_attribute) = FND_API.g_false) THEN
                            FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_INVALID_BOOLEAN');
                            FND_MESSAGE.Set_Token('ATTRIBUTE_NAME', get_Attribute_type_name(p_ctype_code, p_attribute_type_codes(counter)), FALSE);
                            FND_MSG_PUB.ADD;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                    -- boolean
                    ELSIF ( (att_type = IBC_UTILITIES_PUB.G_DTC_COMPONENT) OR (att_type = IBC_UTILITIES_PUB.G_DTC_ATTACHMENT) ) THEN
                        --DBMS_OUTPUT.put_line('EX - non primitive code');
                        FND_MESSAGE.Set_Name('IBC', 'NON_PRIM_ATTRIB_ERROR');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;

                    -- *********** TEMPORARILY STORING INFO IN TEMP LOB **********
                    -- only storing if an error has not yet been encountered
                    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                        -- Open TAG
                        -- Building xml string to be stored
                        IF (att_type NOT IN (IBC_UTILITIES_PUB.G_DTC_TEXT,
                                             IBC_UTILITIES_PUB.G_DTC_HTML,
                                             IBC_UTILITIES_PUB.G_DTC_URL))
                        THEN
                          -- If not TEXT or HTML or URL -> regular formatting
                          temp_text := '<'||p_attribute_type_codes(counter)||' datatype="'||att_type||'">';
                        ELSE
                          -- if TEXT, HTML or URL -> Enclose the content on a CDATA
                          temp_text := '<'||p_attribute_type_codes(counter)||' datatype="'||att_type||'">' ||
                                       '<![CDATA[';
                        END IF;
                        DBMS_LOB.writeappend(px_attribute_bundle, LENGTH(temp_text), temp_text);

                        -- Actual Attribute Value
                        IF (att_type = IBC_UTILITIES_PUB.G_DTC_DATE) THEN
                          BEGIN
                            -- Bug# 3625846
                            temp_text := FND_DATE.date_to_canonical(TO_DATE(p_attributes(counter),
                                            FND_PROFILE.value('ICX_DATE_FORMAT_MASK')));
                          EXCEPTION
                            WHEN OTHERS THEN
                            temp_text := FND_DATE.date_to_canonical(TO_DATE(p_attributes(counter),'RRRR-mm-dd'));

                          END;
                        ELSE
                          temp_text := p_attributes(counter);
                        END IF;

                        IF temp_text IS NOT NULL THEN
                          DBMS_LOB.writeappend(px_attribute_bundle, LENGTH(temp_text), temp_text);
                        END IF;

                        WHILE counter + 1 <= qty_codes AND
                              p_attribute_type_codes(counter) = p_attribute_type_codes(counter+1)
                        LOOP
                          IBC_DEBUG_PVT.debug_message('COUNTER=' || counter);
                          counter := counter + 1;
                          temp_text := p_attributes(counter);
                          IF temp_text IS NOT NULL THEN
                            DBMS_LOB.writeappend(px_attribute_bundle, LENGTH(temp_text), temp_text);
                          END IF;
                        END LOOP;

                        -- Close TAG
                        -- Building xml string to be stored
                        IF (att_type NOT IN (IBC_UTILITIES_PUB.G_DTC_TEXT,
                                             IBC_UTILITIES_PUB.G_DTC_HTML,
                                             IBC_UTILITIES_PUB.G_DTC_URL))
                        THEN
                          -- If not TEXT or HTML or URL -> regular formatting
                          temp_text := '</'||p_attribute_type_codes(counter)||'>';
                        ELSE
                          -- if TEXT, HTML or URL -> Enclose the content on a CDATA
                          temp_text := ']]>' ||
                                       '</'||p_attribute_type_codes(counter)||'>';
                        END IF;
                        -- writing to outgoing lob
                        DBMS_LOB.writeappend(px_attribute_bundle, LENGTH(temp_text), temp_text);
                    END IF;
                END IF; -- if continue flag ...

                EXIT WHEN counter = qty_codes;
                counter := counter + 1;
            END LOOP;
        END IF;
    END IF;

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('EX - CREATE ATTRIBUTE BUNDLE ERROR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_ERROR');
      FND_MESSAGE.set_token('SITUATION', 'CREATION');
      FND_MSG_PUB.ADD;
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
END;

-- --------------------------------------------------------------
-- COPY VERSION (INTERNAL)
--
--
-- --------------------------------------------------------------
PROCEDURE copy_version_int(
    p_language                  IN VARCHAR2
    ,p_new_citem_name   IN VARCHAR2
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
    new_citem_ver_id NUMBER;
    new_ver_num NUMBER;
    new_attrib_fid NUMBER;
    row_id  VARCHAR2(250);  -- required for use with table handlers

    o_ovn NUMBER;
    o_content_item_id NUMBER;
    o_start_date DATE;
    o_end_date DATE;
    o_name IBC_CITEM_VERSIONS_TL.content_item_name%TYPE;
    o_description IBC_CITEM_VERSIONS_TL.description%TYPE;
    o_attrib_fid  NUMBER;
    o_attach_fid NUMBER;
    o_attach_attrib_code IBC_CITEM_VERSIONS_TL.attachment_attribute_code%TYPE;
    o_source_lang IBC_CITEM_VERSIONS_TL.source_lang%TYPE;
    o_attach_fname IBC_CITEM_VERSIONS_TL.attachment_file_name%TYPE;
    o_default_rendition_mime_type IBC_CITEM_VERSIONS_TL.default_rendition_mime_type%TYPE;
    o_attrib_bundle CLOB;

    compound_id NUMBER; --temp holder of newly created compound id
    l_rendition_id NUMBER;

    CURSOR c_old_item IS
        SELECT
            citem_id
            ,NVL(p_new_citem_name,name) name --Added to ensure uniqueness of citem under folder
            ,version
            ,description
            ,start_date
            ,end_date
            ,attrib_fid
            ,attach_fid
            ,attach_file_name
            ,default_rendition_mime_type
            ,object_version_number
        FROM
            IBC_CITEMS_V
        WHERE
            citem_ver_id = px_citem_ver_id
        AND
            LANGUAGE = p_language;

    CURSOR c_abundle IS
        SELECT attribute_bundle_data file_data
          FROM IBC_ATTRIBUTE_BUNDLES
        WHERE attribute_bundle_id = o_attrib_fid;

   CURSOR c_components(p_citem_version_id NUMBER) IS
     SELECT content_item_id      ciid
            ,attribute_type_code atc
            ,content_type_code   ctc
            ,sort_order          sod
       FROM ibc_compound_relations
      WHERE citem_version_id = p_citem_version_id;

   CURSOR c_renditions(p_citem_version_id NUMBER,
                       p_language         VARCHAR2) IS
     SELECT LANGUAGE,
            file_id,
            file_name,
            mime_type
       FROM ibc_renditions
      WHERE citem_version_id = p_citem_version_id
        AND LANGUAGE = p_language;

BEGIN
                                                                       --DBMS_OUTPUT.put_line('----- copy version int -----');
  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.start_process(
       p_proc_type  => 'PROCEDURE',
       p_proc_name  => 'Copy_Version_Int',
       p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                         p_tag     => 'PARAMETERS',
                         p_parms   => JTF_VARCHAR2_TABLE_4000(
                                        'p_language', p_language,
                                        'px_content_item_id', px_content_item_id,
                                        'px_citem_ver_id', px_citem_ver_id,
                                        'px_object_version_number', px_object_version_number
                                      )
                         )
    );
  END IF;

    -- Setting initial state
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- populating the old values
    OPEN c_old_item;

    FETCH
        c_old_item
    INTO
        o_content_item_id
        ,o_name
        ,new_ver_num
        ,o_description
        ,o_start_date
        ,o_end_date
        ,o_attrib_fid
        ,o_attach_fid
        ,o_attach_fname
        ,o_default_rendition_mime_type
        ,o_ovn;

    IF (c_old_item%NOTFOUND) THEN
        CLOSE c_old_item;
        x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
       FND_MESSAGE.Set_Token('INPUT', 'content_item_version_id/language combination', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE c_old_item;

    IF (px_content_item_id IS NULL) THEN
        px_content_item_id := o_content_item_id;
    END IF;

    -- setting object version number if it was not provided
    IF (px_object_version_number IS NULL) THEN
        px_object_version_number := o_ovn;
    END IF;

    -- Fetching Attachment Attribute code
    o_attach_attrib_code := getAttachAttribCode(px_content_item_id);

    -- get version number
    new_ver_num := getMaxVersion(px_content_item_id);
    IF(new_ver_num IS NULL) THEN
        new_ver_num := 1;
    ELSE
        new_ver_num := new_ver_num + 1;
    END IF;


    -- insert attribute bundle -------------------------
    IF ( o_attrib_fid IS NOT NULL) THEN
        OPEN c_abundle;
        FETCH c_abundle INTO o_attrib_bundle;

        IF (c_abundle%NOTFOUND) THEN
            CLOSE c_abundle;
            --DBMS_OUTPUT.put_line('EX - old attribute bundle not found');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'INVALID_ATT_FILE_POINTER');
            FND_MESSAGE.Set_Token('CIVL',px_citem_ver_id, FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            -- adding data to fnd_lobs
            Ibc_Utilities_Pvt.insert_attribute_bundle(
                x_lob_file_id           => new_attrib_fid
                ,p_new_bundle           => o_attrib_bundle
                ,x_return_status        => x_return_status
            );
            CLOSE c_abundle;
        END IF;
    END IF;

    -- insert basic information -------------------------
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.put_line('insert base lang with citem_id '||px_content_item_id||' and citem_ver_id '||new_citem_ver_id|| 'and ovn '||px_object_version_number);

        -- new_citem_ver_id should always be null since a new version is created with EVERY copy
        -- ****RENDITIONS_WORK****
        IBC_CITEM_VERSIONS_PKG.insert_base_lang(
            x_rowid                         => row_id
            ,px_citem_version_id            => new_citem_ver_id
            ,p_content_item_id              => px_content_item_id
            ,p_version_number               => new_ver_num
            ,p_citem_version_status         => IBC_UTILITIES_PUB.G_STV_WORK_IN_PROGRESS
            ,p_start_date                   => o_start_date
            ,p_end_date                     => o_end_date
            ,px_object_version_number       => px_object_version_number
            ,p_attribute_file_id            => new_attrib_fid
            ,p_attachment_attribute_code    => o_attach_attrib_code
            ,p_attachment_file_id           => o_attach_fid
            ,p_content_item_name            => o_name
            ,p_attachment_file_name         => o_attach_fname
            ,p_default_rendition_mime_type  => o_default_rendition_mime_type
            ,p_description                  => o_description
            ,p_source_lang                  => p_language
        );

        -- Copying Translation rows from source version
        -- 11.5.10 enhancement (for PRP)
        INSERT INTO IBC_CITEM_VERSIONS_TL (
         CITEM_VERSION_ID,
         ATTRIBUTE_FILE_ID,
         ATTACHMENT_ATTRIBUTE_CODE,
         CONTENT_ITEM_NAME,
         ATTACHMENT_FILE_ID,
         ATTACHMENT_FILE_NAME,
         DESCRIPTION,
         DEFAULT_RENDITION_MIME_TYPE,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         LANGUAGE,
         SOURCE_LANG,
         CITEM_TRANSLATION_STATUS
       ) SELECT new_citem_ver_id,
                attribute_file_id,
                attachment_attribute_code,
                content_item_name,
                attachment_file_id,
                attachment_file_name,
                description,
                default_rendition_mime_type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                LANGUAGE,
                source_lang,
                IBC_UTILITIES_PUB.g_stv_work_in_progress
           FROM IBC_CITEM_VERSIONS_TL
          WHERE citem_version_id = px_citem_ver_id
            AND LANGUAGE <> p_language;

  --Bug Fix: 3623676
  Ibc_Citem_Versions_Pkg.POPULATE_ALL_ATTACHMENTS(new_citem_ver_id,p_language);

    END IF;

    -- insert renditions --------------------------------
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        FOR r_rendition IN c_renditions(px_citem_ver_id, p_language) LOOP
          l_rendition_id := NULL;
          IBC_RENDITIONS_PKG.insert_row(
            Px_rowid                   => row_id
            ,Px_RENDITION_ID          => l_rendition_id
            ,p_object_version_number => G_OBJ_VERSION_DEFAULT
            ,P_LANGUAGE                 => r_rendition.LANGUAGE
            ,P_FILE_ID                 => r_rendition.file_id
            ,P_FILE_NAME               => r_rendition.file_name
            ,P_CITEM_VERSION_ID       => new_citem_ver_id
            ,P_MIME_TYPE                => r_rendition.mime_type
          );
        END LOOP;

    END IF;


    -- insert components --------------------------------
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        FOR r_component IN c_components(px_citem_ver_id) LOOP
            --resetting id
            compound_id := NULL;

            IBC_COMPOUND_RELATIONS_PKG.insert_row(
                x_rowid                  => row_id
                ,px_compound_relation_id => compound_id
                ,p_content_item_id       => r_component.ciid
                ,p_attribute_type_code   => r_component.atc
                ,p_content_type_code     => r_component.ctc
                ,p_object_version_number => G_OBJ_VERSION_DEFAULT
                ,p_citem_version_id      => new_citem_ver_id
                ,p_sort_order            => r_component.sod
              );

        END LOOP;

    END IF;

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => px_content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => NULL
                                   );

                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_COPY
                                       ,p_parent_value  => px_content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => new_citem_ver_id
                                       ,p_object_value2 => p_language
                                       ,p_object_value3 => px_citem_ver_id
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Copied content item version'
                                   );
                                   --***************************************************
                                   --***************************************************

   END IF;

    -- setting version id for return
    px_citem_ver_id := new_citem_ver_id;

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'px_content_item_id', px_content_item_id,
                      'px_citem_ver_id', px_citem_ver_id,
                      'px_object_version_number', px_object_version_number,
                      'x_return_status', x_return_status,
                      'x_msg_count', x_msg_count,
                      'x_msg_data', x_msg_data
                    )
      )
    );
  END IF;

-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', '*** EXCEPTION *** [' || SQLERRM ||']'
                      )
        )
      );
    END IF;
    RAISE;

END;

-- --------------------------------------------------------------
-- GET ATTRIBUTE BUNDLE (INTERNAL)
--
-- Used to get the attribute bundle for updating/etc
--
--
--
-- --------------------------------------------------------------
PROCEDURE get_attribute_bundle_int(
    p_attrib_fid             IN NUMBER
    ,p_ctype_code            IN VARCHAR2
    ,p_language              IN VARCHAR2 DEFAULT USERENV('LANG')
    ,x_attribute_type_codes  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes            OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
    temp_bundle CLOB; -- temporary clob to hold text information while creating
    xml_parser  XMLPARSER.parser;
    dom_doc     XMLDOM.DOMDocument;
    dom_node_list   XMLDOM.DOMNodeList; -- base nodes
    att_node_list   XMLDOM.DOMNodeList; -- attribute nodes
    dom_node    XMLDOM.DOMNode; -- base node
    total_att_count NUMBER; -- temp variable to hold total count of attributes found
    temp_node_list  XMLDOM.DOMNodeList; -- temporary nodes for use inside creation loop
    temp_node XMLDOM.DOMNode;
    char_data XMLDOM.DOMCharacterData;
    counter NUMBER := 1; -- variable for return arrays(tables)

    CHUNKSIZE       CONSTANT NUMBER := 4000;
    l_res_buffer    VARCHAR2(32767);
    l_total_length  NUMBER;

    -- table variables
    attribute_type_codes  JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100();
    attribute_type_names  JTF_VARCHAR2_TABLE_300  := JTF_VARCHAR2_TABLE_300();
    attributes            JTF_VARCHAR2_TABLE_32767 := JTF_VARCHAR2_TABLE_32767();

    -- attribute loop variables
    atn IBC_ATTRIBUTE_TYPES_TL.attribute_type_name%TYPE;
    atc IBC_ATTRIBUTE_TYPES_TL.attribute_type_code%TYPE; -- loop variable for attribute type
    dtc IBC_ATTRIBUTE_TYPES_B.data_type_code%TYPE;

    -- XML encoding
    l_xml_encoding        VARCHAR2(80);
BEGIN

 IF IBC_DEBUG_PVT.debug_enabled THEN
   IBC_DEBUG_PVT.start_process(
      p_proc_type  => 'PROCEDURE',
      p_proc_name  => 'Get_Attribute_Bundle_Int',
      p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                        p_tag     => 'PARAMETERS',
                        p_parms   => JTF_VARCHAR2_TABLE_4000(
                                       'p_attrib_fid', p_attrib_fid,
                                       'p_ctype_code', p_ctype_code,
                                       'p_language', p_language
                                     )
                        )
   );
 END IF;


                                                                    --DBMS_OUTPUT.put_line('----- get_attribute_bundle_int -----');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --get attributes
    -- CREATING TEMP ATTRIBUTE BUNDLE
    DBMS_LOB.createtemporary(temp_bundle, TRUE, 2);

    -- Attaching encoding to XML based on DB character set
    l_xml_encoding := '<?xml version="1.0" encoding="'||
                      IBC_UTILITIES_PVT.getEncoding() ||
                      '"?>';
    DBMS_LOB.WRITEAPPEND(temp_bundle, LENGTH(l_xml_encoding), l_xml_encoding);

    -- BUILDING COMPLETE XML CLOB
    -- creating open tags
    Ibc_Utilities_Pvt.build_citem_open_tags (
      p_content_type_code    => p_ctype_code
      ,p_content_item_id     => -1
        ,p_item_reference_code => NULL
      ,p_root_tag_only_flag  => FND_API.g_false
        ,p_xml_clob_loc      => temp_bundle
    );

    Ibc_Utilities_Pvt.Build_Attribute_Bundle (
      p_file_id              => p_attrib_fid
        ,p_xml_clob_loc      => temp_bundle
    );

    -- creating close tags
    Ibc_Utilities_Pvt.build_close_tag (
      p_close_tag          => p_ctype_code
        ,p_xml_clob_loc      => temp_bundle
    );


    -- ************************** XML PARSER CREATION ***********************
    -- creating parser to parse temp clob
    xml_parser := XMLPARSER.newParser();
    XMLPARSER.parseClob(xml_parser, temp_bundle);
    -- getting document
    dom_doc := XMLPARSER.getDocument(xml_parser);
    -- getting base node
    --dom_node_list := XMLDOM.getElementsByTagName(dom_doc, p_ctype_code);
    --dom_node := XMLDOM.item(dom_node_list, 0);
    dom_node := XMLDOM.makeNode(XMLDOM.getDocumentElement(dom_doc));
    -- getting child nodes
    att_node_list := XMLDOM.getChildNodes(dom_node);
    total_att_count := XMLDOM.getLength(att_node_list);

--  Tracing output to show what nodes are available for this item
--  for i in 0..total_att_count-1 loop
--    --DBMS_OUTPUT.put_line(XMLDOM.getNodeName(XMLDOM.item(att_node_list, i)));
--  end loop;

    --  Loading attribute information
    FOR i IN 0..total_att_count-1 LOOP

        -- ignoring the built-in attributes
        IF ( (XMLDOM.getNodeName(XMLDOM.item(att_node_list, i)) <> 'NAME') AND
            (XMLDOM.getNodeName(XMLDOM.item(att_node_list, i)) <> 'DESCRIPTION') ) THEN
            attribute_type_codes.extend;
            attribute_type_names.extend;
            attributes.extend;
            atc := XMLDOM.getNodeName(XMLDOM.item(att_node_list, i));

            SELECT
                attl.attribute_type_name,
                atb.data_type_code
            INTO
                atn,
                dtc
            FROM
                IBC_ATTRIBUTE_TYPES_TL attl,
                IBC_ATTRIBUTE_TYPES_B atb
            WHERE
                atb.attribute_type_code = attl.attribute_type_code
            AND
                atb.content_type_code = attl.content_type_code
            AND
                attl.LANGUAGE = p_language
            AND
                attl.attribute_type_code = atc
            AND
                attl.content_type_code = p_ctype_code;

            attribute_type_codes(counter) := atc;
            attribute_type_names(counter) := atn;

            temp_node := XMLDOM.getFirstChild(XMLDOM.item(att_node_list, i));
            attributes(counter) := NULL;
            IF (NOT XMLDOM.isNull(temp_node)) THEN
               -- Reading Data from XML node thru char_Data because of 4K limitation
               -- Replacing: attributes(counter) := XMLDOM.getNodeValue(temp_node);
               char_data := XMLDOM.makecharacterdata(temp_node);
               l_total_length := XMLDOM.getlength(char_data);

               WHILE l_total_length > 0 LOOP

                 IF l_total_length > CHUNKSIZE THEN
                   l_res_buffer := XMLDOM.substringdata(char_data,XMLDOM.getlength(char_data) - l_total_length,CHUNKSIZE);
                 ELSE
                   l_res_buffer := XMLDOM.substringdata(char_data,XMLDOM.getlength(char_data) - l_total_length, l_total_length);
                 END IF;

                 l_total_length := l_total_length - LENGTH(l_res_buffer);
                 attributes(counter) := attributes(counter) || l_res_buffer;

                 -- Logic to split attribute values in case they exceed 32000 characters
                 IF l_total_length > 0 AND LENGTH(attributes(counter)) >= 32000 THEN
                   counter := counter + 1;
                   attribute_type_codes.extend;
                   attribute_type_names.extend;
                   attributes.extend;
                   attribute_type_codes(counter) := atc;
                   attribute_type_names(counter) := atn;
                   attributes(counter) := NULL;
                 END IF;

               END LOOP;

            END IF;

            -- Conversion from storage format (canonical) to client date format in case of Date
            -- Bug# 3625846
            IF attributes(counter) IS NOT NULL AND dtc = IBC_UTILITIES_PUB.G_DTC_DATE THEN
              BEGIN
                l_res_buffer := attributes(counter);
                attributes(counter) := TO_CHAR(FND_DATE.canonical_to_date(attributes(counter)),
                                           FND_PROFILE.value('ICX_DATE_FORMAT_MASK'));
          EXCEPTION
            WHEN OTHERS THEN
              attributes(counter) := l_res_buffer;
          END;
            END IF;

            counter := counter + 1;

        END IF;
   END LOOP;

    -- setting to return variables.  Sending null values if there were errors.
   IF (total_att_count > 0) THEN
        x_attribute_type_codes := attribute_type_codes;
        x_attribute_type_names := attribute_type_names;
        x_attributes := attributes;
   ELSE
        x_attribute_type_codes := NULL;
        x_attribute_type_names := NULL;
        x_attributes := NULL;
   END IF;

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_32767(
                      'x_attribute_type_codes', IBC_DEBUG_PVT.make_list(x_attribute_type_codes),
                      'x_attribute_type_names', IBC_DEBUG_PVT.make_list(x_attribute_type_names),
                      'x_attributes', IBC_DEBUG_PVT.make_list_VC32767(x_attributes),
                      'x_return_status', x_return_status
                    )
      )
    );
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('EX - GET ATTRIBUTE BUNDLE INT ERROR');
      x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_ERROR');
      FND_MESSAGE.set_token('SITUATION', 'CREATION');
      FND_MSG_PUB.ADD;

      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_32767(
                          'x_attribute_type_codes', IBC_DEBUG_PVT.make_list(x_attribute_type_codes),
                          'x_attribute_type_names', IBC_DEBUG_PVT.make_list(x_attribute_type_names),
                          'x_attributes', IBC_DEBUG_PVT.make_list_VC32767(x_attributes),
                          'x_return_status', x_return_status,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;

END;

-- --------------------------------------------------------------
-- INSERT ASSOCIATIONS (INTERNAL)
--
--
--
-- --------------------------------------------------------------
PROCEDURE insert_citem_associations_int(
    p_content_item_id           IN NUMBER
    ,p_citem_version_id         IN NUMBER
    ,p_assoc_type_codes         IN JTF_VARCHAR2_TABLE_100
    ,p_assoc_objects1           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects2           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects3           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects4           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects5           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_log_action               IN VARCHAR2 DEFAULT FND_API.g_true
    ,x_return_status            OUT NOCOPY VARCHAR2
)
IS
    qty_codes NUMBER;
    row_id  VARCHAR2(250);  -- required for use with table handlers
    insert_data CHAR(1); -- flag to tell if this association is okay to insert
    counter NUMBER := 1;
    -- flags to indicate if assoc_object arrays are null (as a whole)
    a2 VARCHAR2(300);
    a3 VARCHAR2(300);
    a4 VARCHAR2(300);
    a5 VARCHAR2(300);
    assoc_id NUMBER;

BEGIN

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.start_process(
       p_proc_type  => 'PROCEDURE',
       p_proc_name  => 'Insert_Citem_Associations_Int',
       p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                         p_tag     => 'PARAMETERS',
                         p_parms   => JTF_VARCHAR2_TABLE_4000(
                                        'p_content_item_id', p_content_item_id,
                                        'p_citem_version_id', p_citem_version_id,
                                        'p_assoc_type_codes', IBC_DEBUG_PVT.make_list(p_assoc_type_codes),
                                        'p_assoc_objects1', IBC_DEBUG_PVT.make_list(p_assoc_objects1),
                                        'p_assoc_objects2', IBC_DEBUG_PVT.make_list(p_assoc_objects2),
                                        'p_assoc_objects3', IBC_DEBUG_PVT.make_list(p_assoc_objects3),
                                        'p_assoc_objects4', IBC_DEBUG_PVT.make_list(p_assoc_objects4),
                                        'p_assoc_objects5', IBC_DEBUG_PVT.make_list(p_assoc_objects5),
                                        'p_log_action', p_log_action
                                      )
                         )
    );
  END IF;
                                                                    --DBMS_OUTPUT.put_line('----- insert_citem_associations_int -----');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    qty_codes := p_assoc_type_codes.COUNT;
    -- if any of the arrays are non-parallel, throw an error
    IF( (p_assoc_objects1.COUNT <> qty_codes) OR
      ( (p_assoc_objects2 IS NOT NULL) AND (p_assoc_objects2.COUNT <> qty_codes) ) OR
      ( (p_assoc_objects3 IS NOT NULL) AND (p_assoc_objects3.COUNT <> qty_codes) ) OR
      ( (p_assoc_objects4 IS NOT NULL) AND (p_assoc_objects4.COUNT <> qty_codes) ) OR
      ( (p_assoc_objects5 IS NOT NULL) AND (p_assoc_objects5.COUNT <> qty_codes) ) )  THEN
        --DBMS_OUTPUT.put_line('EX - improper (non-parallel) array');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'IMPROPER_ARRAY');
        FND_MSG_PUB.ADD;
    ELSE
        LOOP
            -- setting insert flag to true to start
            insert_data := FND_API.g_true;

            -- assoc type
            IF (IBC_VALIDATE_PVT.isValidAssocType(p_assoc_type_codes(counter)) = FND_API.g_false ) THEN
                --DBMS_OUTPUT.put_line('EX - assoc type');
                insert_data := FND_API.g_false;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('IBC', 'INVALID_ASSOC_TYPE_CODE');
                FND_MESSAGE.Set_Token('ASSOC_TYPE_CODE', p_assoc_type_codes(counter), FALSE);
                FND_MSG_PUB.ADD;
            END IF;

            -- is insert flag still true?
            IF (insert_data = FND_API.g_true) THEN
                -- resetting id
                assoc_id := NULL;

                -- setting temp values to avoid null value errors
                IF (p_assoc_objects2 IS NOT NULL) THEN
                    a2 := p_assoc_objects2(counter);
                ELSE
                    a2 := NULL;
                END IF;

                IF (p_assoc_objects3 IS NOT NULL) THEN
                    a3 := p_assoc_objects3(counter);
                ELSE
                    a3 := NULL;
                END IF;

                IF (p_assoc_objects4 IS NOT NULL) THEN
                    a4 := p_assoc_objects4(counter);
                ELSE
                    a4 := NULL;
                END IF;

                IF (p_assoc_objects5 IS NOT NULL) THEN
                    a5 := p_assoc_objects5(counter);
                ELSE
                    a5 := NULL;
                END IF;
                -- ACTUAL INSERT !!!
                Ibc_Associations_Pkg.insert_row (
                    px_association_id           => assoc_id
                    ,p_content_item_id          => p_content_item_id
                    ,p_citem_version_id         => p_citem_version_id
                    ,p_association_type_code  => p_assoc_type_codes(counter)
                    ,p_associated_object_val1   => p_assoc_objects1(counter)
                    ,p_associated_object_val2   => a2
                    ,p_associated_object_val3   => a3
                    ,p_associated_object_val4   => a4
                    ,p_associated_object_val5   => a5
                    ,p_object_version_number  => G_OBJ_VERSION_DEFAULT
                    ,x_rowid            => row_id
                );

                IF (p_log_action = FND_API.g_true) THEN

                                           --***************************************************
                                           --************ADDING TO AUDIT LOG********************
                                           --***************************************************
                                           Ibc_Utilities_Pvt.log_action(
                                               p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                               ,p_parent_value  => NULL
                                               ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                               ,p_object_value1 => p_content_item_id
                                               ,p_object_value2 => NULL
                                               ,p_object_value3 => NULL
                                               ,p_object_value4 => NULL
                                               ,p_object_value5 => NULL
                                               ,p_description   => 'Updated item'
                                           );
                                           Ibc_Utilities_Pvt.log_action(
                                               p_activity       => Ibc_Utilities_Pvt.G_ALA_CREATE
                                               ,p_parent_value  => p_content_item_id
                                               ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ASSOCIATION
                                               ,p_object_value1 => p_assoc_objects1(counter)
                                               ,p_object_value2 => a2
                                               ,p_object_value3 => a3
                                               ,p_object_value4 => a4
                                               ,p_object_value5 => a5
                                               ,p_description   => 'Created of type '|| p_assoc_type_codes(counter)||' with association id '||assoc_id
                                           );
                                           --***************************************************
                END IF;
            END IF;

        EXIT WHEN counter = qty_codes;
            counter := counter + 1;
        END LOOP;
    END IF;

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'x_return_status', x_return_status
                    )
      )
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'EXCEPTION', SQLERRM
                      )
        )
      );
    END IF;
END;

-- --------------------------------------------------------------
-- INSERT COMPONENT ITEMS (INTERNAL)
--
--
--
-- --------------------------------------------------------------
PROCEDURE insert_component_items_int(
    p_citem_ver_id              IN NUMBER
    ,p_content_item_id          IN NUMBER
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
    ,p_citem_ver_ids            IN JTF_NUMBER_TABLE DEFAULT NULL
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_ctype_code               IN VARCHAR2
    ,p_sort_order               IN JTF_NUMBER_TABLE DEFAULT NULL
    ,p_log_action               IN VARCHAR2 DEFAULT FND_API.g_true
    ,x_return_status            OUT NOCOPY VARCHAR2
)
IS
    qty_codes NUMBER;
    compound_id NUMBER;
    row_id  VARCHAR2(250);  -- required for use with table handlers
    -- flag to denote whether errors were found with this compound item
    insert_data CHAR(1);
    counter NUMBER := 1;
    sort_order NUMBER;
    temp NUMBER;
    l_subitem_version_id NUMBER;

    CURSOR c_comp_info(p_content_type VARCHAR2,
                       p_attribute_type VARCHAR2)
    IS
      SELECT default_value, updateable_flag
        FROM ibc_attribute_types_b
       WHERE content_type_code = p_content_type
         AND attribute_type_code = p_attribute_type;

BEGIN

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.start_process(
       p_proc_type  => 'PROCEDURE',
       p_proc_name  => 'insert_component_items_int',
       p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                         p_tag     => 'PARAMETERS',
                         p_parms   => JTF_VARCHAR2_TABLE_4000(
                                        'p_citem_ver_id', p_citem_ver_id,
                                        'p_content_item_id', p_content_item_id,
                                        'p_content_item_ids', IBC_DEBUG_PVT.make_list(p_content_item_ids),
                                        'p_citem_ver_ids', IBC_DEBUG_PVT.make_list(p_citem_ver_ids),
                                        'p_attribute_type_codes', IBC_DEBUG_PVT.make_list(p_attribute_type_codes),
                                        'p_ctype_code', p_ctype_code,
                                        'p_sort_order', IBC_DEBUG_PVT.make_list(p_sort_order),
                                        'p_log_action', p_log_action
                                      )
                         )
    );
  END IF;
                                                                    --DBMS_OUTPUT.put_line('----- insert_component_items_int -----');
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( (p_attribute_type_codes IS NOT NULL) AND (p_content_item_ids IS NOT NULL) ) THEN
        qty_codes := p_attribute_type_codes.COUNT;
        -- basic table/array validation
        IF ( (qty_codes <> p_content_item_ids.COUNT) OR ((p_sort_order IS NOT NULL) AND (qty_codes <> p_sort_order.COUNT)) ) THEN
            --DBMS_OUTPUT.put_line('EX - array count');
            x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name('IBC', 'COMPONENT_ARRAY_ERROR');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
        -- loop for each record

            LOOP
                -- setting insert flag to true to start
                insert_data := FND_API.g_true;

                -- content item
                IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_ids(counter)) = FND_API.g_false) THEN
                    --DBMS_OUTPUT.put_line('EX - content_item_id -- '||p_content_item_ids(counter) );
                    insert_data := FND_API.g_false;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
                    FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- citem version ids
                IF (insert_data = FND_API.g_true AND
                    p_citem_ver_ids IS NOT NULL AND
                    p_citem_ver_ids IS NOT NULL AND
                    p_citem_ver_ids(counter) NOT IN (0, -1, -999, FND_API.G_MISS_NUM) AND
                    IBC_VALIDATE_PVT.isValidCitemVerForCitem(p_content_item_ids(counter), p_citem_ver_ids(counter)) = FND_API.g_false)
                THEN
                    insert_data := FND_API.g_false;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
                    FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                 -- attribute type code
                IF ( (insert_data = FND_API.g_true) AND (IBC_VALIDATE_PVT.isValidAttrCode(p_attribute_type_codes(counter),p_ctype_code) = FND_API.g_false) ) THEN
                    --DBMS_OUTPUT.put_line('EX - attribute type');
                    insert_data := FND_API.g_false;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IBC', 'INVALID_ATT_TYPE');
                    FND_MESSAGE.Set_Token('TYPE_CODE', p_attribute_type_codes(counter), FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- correct content_type?
                IF (isCorrectContentType(p_content_item_id, getContentType(p_content_item_ids(counter)),p_attribute_type_codes(counter)) = FND_API.g_false) THEN
                    --DBMS_OUTPUT.put_line('EX - invalid content type for attribute');
                    insert_data := FND_API.g_false;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IBC', 'INVALID_ATT_TYPE');
                    FND_MESSAGE.Set_Token('TYPE_CODE', p_attribute_type_codes(counter), FALSE);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Changed Default Value for non-updateable component?
                FOR r_comp_info IN c_comp_info(p_ctype_code, p_attribute_type_codes(counter))
                LOOP
                  IF r_comp_info.updateable_flag = FND_API.g_false THEN
                    IF r_comp_info.default_value IS NOT NULL AND
                       TO_CHAR(p_content_item_ids(counter)) <> r_comp_info.default_value
                    THEN
                      insert_data := FND_API.g_false;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_NU_DEFAULT_VALUE');
                      FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                            get_attribute_type_name(p_ctype_code, p_attribute_type_codes(counter), USERENV('lang')), FALSE);
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
                  END IF;
                END LOOP;

                IF (insert_data = FND_API.g_true) THEN

                    -- determining if the content item id is reusable
                    SELECT
                        MIN(parent_item_id)
                    INTO
                        temp
                    FROM
                      ibc_content_items
                    WHERE
                        content_item_id = p_content_item_ids(counter);

                    IF( (temp IS NOT NULL) AND (temp <> p_content_item_id) ) THEN
                        --DBMS_OUTPUT.put_line('EX - parent item id');
                        insert_data := FND_API.g_false;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.Set_Name('IBC', 'UNUSABLE_COMPONENT');
                        FND_MESSAGE.Set_Token('COMPONENT',p_content_item_ids(counter), FALSE);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;

                -- is insert flag still true?
                IF (insert_data = FND_API.g_true) THEN
                  -- setting sort order in case of null value
                  IF ( (p_sort_order IS NULL) OR (p_sort_order(counter) IS NULL) ) THEN
                     sort_order := 1;
                  ELSE
                     sort_order := p_sort_order(counter);
                  END IF;

                  -- setting subitem component citem_ver_id
                  IF ( (p_citem_ver_ids IS NULL) OR (p_citem_ver_ids(counter) IS NULL)
                        OR (p_citem_ver_ids(counter) IN (0, -1, -999, FND_API.G_MISS_NUM)))
                  THEN
                     l_subitem_version_id := NULL;
                  ELSE
                     l_subitem_version_id := p_citem_ver_ids(counter);
                  END IF;


                  Ibc_Compound_Relations_Pkg.insert_row(
                    x_ROWID                  => row_id
                    ,px_COMPOUND_RELATION_ID => compound_id
                    ,p_CONTENT_ITEM_ID       => p_content_item_ids(counter)
                    ,p_ATTRIBUTE_TYPE_CODE   => p_attribute_type_codes(counter)
                    ,p_CONTENT_TYPE_CODE     => p_ctype_code
                    ,p_object_version_number => G_OBJ_VERSION_DEFAULT
                    ,p_CITEM_VERSION_ID      => p_citem_ver_id
                    ,p_SORT_ORDER            => sort_order
                    ,p_subitem_version_id    => l_subitem_version_id
                  );

                  IF (p_log_action = FND_API.g_true) THEN

                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => p_content_item_ids(counter)
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Updating version'
                                   );
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => p_content_item_ids(counter)
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => p_citem_ver_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Adding component'
                                   );
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_CREATE
                                       ,p_parent_value  => p_citem_ver_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_COMPONENT
                                       ,p_object_value1 => p_attribute_type_codes(counter)
                                       ,p_object_value2 => p_content_item_ids(counter)
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Adding new component with compound id: '||compound_id
                                   );
                                   --***************************************************
                   END IF;
                END IF;

            -- resetting compound id for next loop
            compound_id := NULL;

            EXIT WHEN counter = qty_codes;
                counter := counter + 1;
            END LOOP;
        END IF; -- if qty_codes ...
    END IF; -- if attribute_type_codes ...

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'x_return_status', x_return_status
                    )
      )
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', '*** EXCEPTION *** [' || SQLERRM || ']'
                      )
        )
      );
    END IF;
    RAISE;
END;

-- --------------------------------------------------------------
-- VALIDATE COMPONENTS (INTERNAL)
--
--
--
-- --------------------------------------------------------------
PROCEDURE validate_components(
   p_citem_version_id           IN NUMBER
   ,p_content_type_code         IN VARCHAR2
   ,p_attribute_type_code       IN VARCHAR2
   ,p_default_value             IN VARCHAR2
   ,p_updateable                IN VARCHAR2
   ,p_minimum                   IN NUMBER
   ,p_maximum                   IN NUMBER
   ,p_language                  IN VARCHAR2
   ,x_return_status             OUT NOCOPY VARCHAR2
)
IS
   temp NUMBER;
   counter NUMBER := 0;

   CURSOR c_components(p_attribute_type_code VARCHAR2,
                       p_content_type_code   VARCHAR2,
                       p_citem_version_id    NUMBER)
   IS
      SELECT content_item_id
        FROM ibc_compound_relations
       WHERE attribute_type_code = p_attribute_type_code
         AND content_Type_code = p_content_type_code
         AND citem_version_id = p_citem_version_id;

   citem_id NUMBER;
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- validate_components -----');
  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.start_process(
       p_proc_type  => 'PROCEDURE',
       p_proc_name  => 'Validate_Components',
       p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                         p_tag     => 'PARAMETERS',
                         p_parms   => JTF_VARCHAR2_TABLE_4000(
                                        'p_citem_version_id', p_citem_version_id,
                                        'p_content_type_code', p_content_type_code,
                                        'p_attribute_type_code', p_attribute_type_code,
                                        'p_default_value', p_default_value,
                                        'p_minimum', p_minimum,
                                        'p_maximum', p_maximum,
                                        'p_language', p_language
                                      )
                         )
    );
  END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- looping through all components of this attribute type
    OPEN c_components(p_attribute_type_code, p_content_type_code, p_citem_version_id);

    -- VALIDATION LOOP
    LOOP
        FETCH c_components INTO citem_id;
        EXIT WHEN c_components%NOTFOUND;

        IF (p_updateable = FND_API.g_false) THEN
          IF (p_default_value IS NOT NULL) THEN
              IF(TO_CHAR(citem_id) <> p_default_value) THEN
                  --DBMS_OUTPUT.put_line('EX - component default value');
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_NU_DEFAULT_VALUE');
                  FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                        get_attribute_type_name(p_content_type_code, p_attribute_type_code, p_language), FALSE);
                  FND_MSG_PUB.ADD;
              END IF;
          END IF;
        END IF;

        -- if it is required then check to see if it is approved!
        IF(p_minimum > 0) THEN
            IF (getContentItemStatus(citem_id) <> IBC_UTILITIES_PUB.G_STI_APPROVED) THEN
                --DBMS_OUTPUT.put_line('EX - component not approved');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('IBC', 'COMPONENT_APPROVAL_REQUIRED');
                FND_MESSAGE.Set_Token('CONTENT_ITEM_ID', citem_id, FALSE);
                FND_MSG_PUB.ADD;
            END IF;
        END IF;

        counter := counter + 1;
    END LOOP;
    -- clean up!
    CLOSE c_components;

    IF (counter < p_minimum) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF p_minimum = 1 THEN
          FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_REQUIRED');
          FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                get_attribute_type_name(p_content_type_code, p_attribute_type_code, p_language), FALSE);
          FND_MSG_PUB.ADD;
       ELSE
          FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_MIN_INSTANCES');
          FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                get_attribute_type_name(p_content_type_code, p_attribute_type_code, p_language), FALSE);
          FND_MESSAGE.Set_Token('MIN_INSTANCES', TO_CHAR(p_minimum), FALSE);
          FND_MSG_PUB.ADD;
       END IF;
    END IF;
    -- maxi
    IF ((p_maximum IS NOT NULL) AND (counter > p_maximum)) THEN
        --DBMS_OUTPUT.put_line('EX - component maximum');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_MAX_INSTANCES');
        FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                              get_attribute_type_name(p_content_type_code, p_attribute_type_code, p_language), FALSE);
        FND_MESSAGE.Set_Token('MAX_INSTANCES', TO_CHAR(p_maximum), FALSE);
        FND_MSG_PUB.ADD;
    END IF;

     --DBMS_OUTPUT.put_line('END OF COMPONENT VALIDATION');
  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'x_return_status', x_return_status
                    )
      )
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', '*** EXCEPTION *** [' || SQLERRM || ']'
                      )
        )
      );
    END IF;
    RAISE;


END;


-- --------------------------------------------------------------
-- VALIDATE ATTRIBUTE BUNDLE
--
-- Used validate attributes of a content item against the content type
--
-- ***** SQL variables are attribute types for content type
-- ***** xml parser variables are the actual data contained in attribute bundle
-- --------------------------------------------------------------
 PROCEDURE validate_attribute_bundle(
    p_attribute_bundle      IN CLOB
    ,p_citem_ver_id         IN NUMBER
    ,p_language             IN VARCHAR2 DEFAULT USERENV('LANG')
    ,x_return_status        OUT NOCOPY VARCHAR2
)
IS
    content_item_id NUMBER; --content item id
    ctype_code IBC_CONTENT_TYPES_B.content_type_code%TYPE; -- content type code
    citem_name IBC_CITEM_VERSIONS_TL.content_item_name%TYPE; -- content item name
    citem_desc IBC_CITEM_VERSIONS_TL.description%TYPE; -- content item description
    attach_file_id IBC_CITEM_VERSIONS_TL.attachment_file_id%TYPE;
    temp_bundle CLOB; -- temporary clob to hold text information while creating
    xml_parser  XMLPARSER.parser;
    dom_doc     XMLDOM.DOMDocument;
    dom_node_list   XMLDOM.DOMNodeList; -- base nodes
    att_node_list   XMLDOM.DOMNodeList; -- attribute nodes
    temp_node_list  XMLDOM.DOMNodeList; -- temporary nodes for use inside validation loop
    dom_node    XMLDOM.DOMNode; -- base node
    temp_node    XMLDOM.DOMNode; -- temp node for use inside validation loop
    valid_element_count NUMBER;  -- temp variable to hold count of how many valid elements found
    total_att_count NUMBER; -- temp variable to hold total count of attributes found

    -- used to loop through all the attributes
    CURSOR c_attributes(p_content_type_code IN VARCHAR2) IS
      SELECT attribute_type_code atc
             ,data_type_code dtc
             ,min_instances mini
             ,max_instances maxi
             ,reference_code rc
             ,default_value dv
             ,updateable_flag upd
             ,data_length dl
             ,flex_value_set_id vset
        FROM ibc_attribute_types_b
       WHERE content_type_code = p_content_type_code;

    CURSOR c_count_renditions IS
      SELECT COUNT(*)
        FROM IBC_RENDITIONS
        WHERE CITEM_VERSION_ID = p_citem_ver_id
          AND LANGUAGE = p_language;


    node_value VARCHAR2(32767);

    char_data XMLDOM.DOMCharacterData;
    CHUNKSIZE       CONSTANT NUMBER := 4000;
    l_res_buffer    VARCHAR2(32767);
    l_total_length  NUMBER;

    temp NUMBER;
    temp_desc IBC_CITEM_VERSIONS_TL.description%TYPE;
    return_status VARCHAR2(1);   -- hold temporary status so all errors can be found before error is thrown

    l_exists VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);

    l_xml_encoding VARCHAR2(80);

BEGIN

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.start_process(
       p_proc_type  => 'PROCEDURE',
       p_proc_name  => 'Validate_Attribute_Bundle',
       p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                         p_tag     => 'PARAMETERS',
                         p_parms   => JTF_VARCHAR2_TABLE_4000(
                                        'p_citem_ver_id', p_citem_ver_id,
                                        'p_language', p_language
                                      )
                         )
    );
  END IF;
                                                                    --DBMS_OUTPUT.put_line('----- validate_attribute_bundle -----');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- getting citem, ctype, attribute information for use in checking
    SELECT
        ibc_content_items.content_type_code
        ,ibc_content_items.content_item_id
        ,ibc_citem_versions_tl.content_item_name
        ,ibc_citem_versions_tl.description
        ,ibc_citem_versions_tl.attachment_file_id
    INTO
        ctype_code
        ,content_item_id
        ,citem_name
        ,citem_desc
        ,attach_file_id
    FROM
        ibc_citem_versions_b
        ,ibc_citem_versions_tl
        ,ibc_content_items
    WHERE
        ibc_content_items.content_item_id = ibc_citem_versions_b.content_item_id
    AND
        ibc_citem_versions_b.citem_version_id = ibc_citem_versions_tl.citem_version_id
    AND
        ibc_citem_versions_tl.LANGUAGE = p_language
    AND
        ibc_citem_versions_b.citem_version_id = p_citem_ver_id;

    -- CREATING TEMP ATTRIBUTE BUNDLE
    DBMS_LOB.createtemporary(temp_bundle, TRUE, 2);

    -- BUILDING COMPLETE XML CLOB

    -- Attaching encoding to XML based on DB character set
    l_xml_encoding := '<?xml version="1.0" encoding="'||
                      IBC_UTILITIES_PVT.getEncoding() ||
                      '"?>';
    DBMS_LOB.WRITEAPPEND(temp_bundle, LENGTH(l_xml_encoding), l_xml_encoding);

    -- creating open tags
    Ibc_Utilities_Pvt.build_citem_open_tags (
     p_content_type_code     => ctype_code
     ,p_content_item_id      => content_item_id
    ,p_item_reference_code  => NULL
     ,p_content_item_name    => citem_name
     ,p_description          => citem_desc
     ,p_root_tag_only_flag   => FND_API.g_false
     ,p_xml_clob_loc       => temp_bundle
     );

    --appending given clob
    DBMS_LOB.APPEND (
       dest_lob                 => temp_bundle
       ,src_lob                 => p_attribute_bundle
    );


    -- creating close tags
    Ibc_Utilities_Pvt.build_close_tag (
     p_close_tag           => ctype_code
     ,p_xml_clob_loc       => temp_bundle
    );

    -- ************************** XML PARSER CREATION ***********************
    -- creating parser to parse temp clob
    xml_parser := XMLPARSER.newParser();
    XMLPARSER.parseClob(xml_parser, temp_bundle);
    -- getting document
    dom_doc := XMLPARSER.getDocument(xml_parser);
    -- getting base node
    --dom_node_list := XMLDOM.getElementsByTagName(dom_doc, ctype_code);
    --dom_node := XMLDOM.item(dom_node_list, 0);
    dom_node := XMLDOM.makeNode(XMLDOM.getDocumentElement(dom_doc));
    -- getting child nodes
    att_node_list := XMLDOM.getChildNodes(dom_node);
    total_att_count := XMLDOM.getLength(att_node_list);

    -- Tracing output of XML content
    --IF IBC_DEBUG_PVT.debug_enabled THEN
    --  DECLARE
    --    l_clob_len NUMBER;
    --    l_buffer   VARCHAR2(10000);
    --  BEGIN
    --    l_clob_len := DBMS_LOB.getlength(temp_bundle);
    --    IBC_DEBUG_PVT.debug_message('CLOBLEN=' || l_clob_len);
    --    DBMS_LOB.read(temp_bundle, l_clob_len, 1, l_buffer);
    --    IBC_DEBUG_PVT.debug_message(l_buffer);
    --  EXCEPTION
    --    WHEN OTHERS THEN
    --      NULL;
    --  END;
    --END IF;

--  Tracing output to show what nodes are available for this item
--  for i in 0..total_att_count-1 loop
--    --DBMS_OUTPUT.put_line(XMLDOM.getNodeName(XMLDOM.item(att_node_list, i)));
--  end loop;

    -- VALIDATION LOOP
    FOR r_attribute IN c_attributes(ctype_code) LOOP

        -- check description datatype code...
        IF(r_attribute.atc = 'DESCRIPTION') THEN
            --... but only if it is required
            IF(r_attribute.mini > 0) THEN
                SELECT
                    description
                INTO
                    temp_desc
                FROM
                    ibc_citem_versions_tl
                WHERE
                    citem_version_id = p_citem_ver_id
                AND
                    LANGUAGE = p_language;

                IF (temp_desc IS NULL) THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_REQUIRED');
                    FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                          get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
            END IF;

        -- do not check if the data type code is a component...
        ELSIF(r_attribute.dtc = Ibc_Utilities_Pub.G_DTC_COMPONENT) THEN
            validate_components(
                p_citem_version_id           => p_citem_ver_id
                ,p_content_type_code         => ctype_code
                ,p_attribute_type_code       => r_attribute.atc
                ,p_default_value             => r_attribute.dv
                ,p_updateable                => r_attribute.upd
                ,p_minimum                   => r_attribute.mini
                ,p_maximum                   => r_attribute.maxi
                ,p_language                  => p_language
                ,x_return_status             => return_status
            );

            -- setting return error
            IF (return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        -- making sure attachments only appear once
        ELSIF(r_attribute.dtc = Ibc_Utilities_Pub.G_DTC_ATTACHMENT) THEN

            -- No more renditions support for attachments.
            -- IF attachment valid_element_count = 1 ELSE 0
            IF attach_file_id IS NOT NULL THEN
              valid_element_count := 1;
            ELSE
              valid_element_count := 0;
            END IF;

            -- mini
            IF (valid_element_count < r_attribute.mini) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF r_attribute.mini = 1 THEN
                    FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_REQUIRED');
                    FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                          get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
                    FND_MSG_PUB.ADD;
                ELSE
                    FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_MIN_INSTANCES');
                    FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                          get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
                    FND_MESSAGE.Set_Token('MIN_INSTANCES', TO_CHAR(r_attribute.mini), FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
            END IF;


            -- maxi
            IF (valid_element_count > r_attribute.maxi) THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_MAX_INSTANCES');
               FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                     get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
               FND_MESSAGE.Set_Token('MAX_INSTANCES', TO_CHAR(r_attribute.maxi), FALSE);
               FND_MSG_PUB.ADD;
            END IF;

        ELSE
            -- ** validate each column of attribute **
            -- attribute type code -- (reference)

            -- data type code -- (validated on insert)

            -- finding and counting all the elements that are of this attribute type
            temp_node_list := XMLDOM.getChildrenByTagName(XMLDOM.makeElement(dom_node), r_attribute.atc);
            valid_element_count := XMLDOM.getLength(temp_node_list);

            -- mini
            IF (valid_element_count < r_attribute.mini) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF r_attribute.mini = 1 THEN
                    FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_REQUIRED');
                    FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                          get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
                    FND_MSG_PUB.ADD;
                ELSE
                    FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_MIN_INSTANCES');
                    FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                          get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
                    FND_MESSAGE.Set_Token('MIN_INSTANCES', TO_CHAR(r_attribute.mini), FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
            END IF;

            -- maxi
            IF ((r_attribute.maxi IS NOT NULL) AND (valid_element_count > r_attribute.maxi)) THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_MAX_INSTANCES');
               FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                     get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
               FND_MESSAGE.Set_Token('MAX_INSTANCES', TO_CHAR(r_attribute.maxi), FALSE);
               FND_MSG_PUB.ADD;
            END IF;

            -- looping through all elements this type to check size and value (vs. default)
            FOR i IN 0..valid_element_count-1 LOOP

                -- getting node value
                temp_node := XMLDOM.getFirstChild(XMLDOM.item(temp_node_list, i));

                node_value := NULL;
                IF (NOT XMLDOM.isNull(temp_node)) THEN
                   -- Reading Data from XML node thru char_Data because of 4K limitation
                   -- Replacing: node_value := XMLDOM.getNodeValue(temp_node);
                   char_data := XMLDOM.makecharacterdata(temp_node);
                   l_total_length := XMLDOM.getlength(char_data);

                   WHILE l_total_length > 0 LOOP

                     IF l_total_length > CHUNKSIZE THEN
                       l_res_buffer := XMLDOM.substringdata(char_data,XMLDOM.getlength(char_data) - l_total_length,CHUNKSIZE);
                     ELSE
                       l_res_buffer := XMLDOM.substringdata(char_data,XMLDOM.getlength(char_data) - l_total_length, l_total_length);
                     END IF;

                     l_total_length := l_total_length - LENGTH(l_res_buffer);

                     IF LENGTH(node_value) + LENGTH(l_res_buffer) > 32767 THEN
                       node_value := node_value || l_res_buffer;
                     END IF;

                   END LOOP;

                END IF;

                -- size
                IF (r_attribute.dtc = 'string') THEN
                    IF(LENGTH(node_value) > NVL(r_attribute.dl, 32767)) THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_DATA_LENGTH');
                        FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                              get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
                        FND_MESSAGE.Set_Token('DATA_LENGTH', TO_CHAR(NVL(r_attribute.dl, 32767)), FALSE);
                        FND_MSG_PUB.ADD;
                    END IF;
                END IF;

                -- updateable
                IF (r_attribute.upd = FND_API.g_false) THEN
                    -- checking to see if value is the same as the default value
                    IF (r_attribute.dv <> node_value) THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_NU_DEFAULT_VALUE');
                        FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                              get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
                        FND_MSG_PUB.ADD;
                    END IF;
                END IF;

                -- Validate against ValueSet
                IF (node_value IS NOT NULL AND r_attribute.vset IS NOT NULL) THEN
                  IBC_CTYPE_PVT.Is_Valid_Flex_Value(
                    P_Api_Version_Number    => 1
                    ,P_Init_Msg_List        => FND_API.g_false
                    ,p_flex_value_set_id    => r_attribute.vset
                    ,p_flex_value_code      => node_value
                    ,x_exists               => l_exists
                    ,X_Return_Status        => x_return_status
                    ,X_Msg_Count             => l_msg_count
                    ,X_Msg_Data             => l_msg_data
                  );
                  IF l_exists = FND_API.g_false THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IBC', 'IBC_VALATTR_NOT_IN_VSET');
                    FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',
                                          get_attribute_type_name(ctype_code, r_attribute.atc, p_language), FALSE);
                    FND_MSG_PUB.ADD;
                  END IF;
                END IF;

            END LOOP; -- end for loop
        END IF;
    END LOOP;

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'x_return_status', x_return_status
                    )
      )
    );
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        --DBMS_OUTPUT.put_line('EX - bundle validation --others--');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_ERROR');
        FND_MESSAGE.set_token('SITUATION', 'VALIDATION');
        FND_MSG_PUB.ADD;

        IF IBC_DEBUG_PVT.debug_enabled THEN
          IBC_DEBUG_PVT.end_process(
            IBC_DEBUG_PVT.make_parameter_list(
              p_tag    => 'OUTPUT',
              p_parms  => JTF_VARCHAR2_TABLE_4000(
                            'x_return_status', '*** EXCEPTION *** [' || SQLERRM || ']'
                          )
            )
          );
        END IF;
END;

-- --------------------------------------------------------------
-- GET CITEM INFO
--
-- --------------------------------------------------------------
PROCEDURE get_citem_info(
    p_citem_ver_id              IN NUMBER
    ,x_content_item_id          OUT NOCOPY NUMBER
    ,x_ctype_code               OUT NOCOPY VARCHAR2
    ,x_object_version_number    OUT NOCOPY NUMBER
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'get_citem_info';        --|**|
--******************* END REQUIRED VARIABLES ***************************
BEGIN
    --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
    SELECT
        IBC_CONTENT_ITEMS.content_item_id
        ,IBC_CONTENT_ITEMS.content_type_code
        ,IBC_CONTENT_ITEMS.object_version_number
    INTO
        x_content_item_id
        ,x_ctype_code
        ,x_object_version_number
    FROM
        ibc_content_items
        ,ibc_citem_versions_b
    WHERE
        IBC_CONTENT_ITEMS.content_item_id = IBC_CITEM_VERSIONS_B.content_item_id
    AND
        IBC_CITEM_VERSIONS_B.citem_version_id = p_citem_ver_id;
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
      RAISE;
END;

-- --------------------------------------------------------------
-- APPROVE CONTENT ITEM VERSION (INTERNAL)
--
-- Used to move a content item version to the status of approved.
--
-- --------------------------------------------------------------
PROCEDURE approve_citem_version_int(
    p_citem_ver_id              IN NUMBER
    ,p_content_item_id          IN NUMBER
    ,p_base_lang                IN VARCHAR2
    ,p_log_action               IN VARCHAR2 DEFAULT FND_API.g_true
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'approve_citem_version_int';--|**|
--******************* END REQUIRED VARIABLES ***************************
    content_item_name IBC_CITEM_VERSIONS_TL.content_item_name%TYPE;
    description IBC_CITEM_VERSIONS_TL.description%TYPE;
    version_number IBC_CITEM_VERSIONS_B.version_number%TYPE;
    start_date DATE;
    end_date DATE;
    ovn NUMBER;
    attach_fid NUMBER;
    attrib_fid NUMBER;
    attach_code IBC_CITEM_VERSIONS_TL.attachment_attribute_code%TYPE;
    attach_fname IBC_CITEM_VERSIONS_TL.attachment_file_name%TYPE;
    default_rendition_mime_type  IBC_CITEM_VERSIONS_TL.default_rendition_mime_type%TYPE;
    temp_bundle CLOB;
    temp NUMBER;

    CURSOR info IS
        SELECT
           IBC_CONTENT_ITEMS.object_version_number
           ,IBC_CITEM_VERSIONS_B.version_number
           ,IBC_CITEM_VERSIONS_B.start_date
           ,IBC_CITEM_VERSIONS_B.end_date
           ,IBC_CITEM_VERSIONS_TL.attribute_file_id
           ,IBC_CITEM_VERSIONS_TL.attachment_file_id
           ,IBC_CITEM_VERSIONS_TL.content_item_name
           ,IBC_CITEM_VERSIONS_TL.description
           ,IBC_CITEM_VERSIONS_TL.attachment_file_name
           ,IBC_CITEM_VERSIONS_TL.default_rendition_mime_type
           ,IBC_CITEM_VERSIONS_TL.attachment_attribute_code
        FROM
           IBC_CONTENT_ITEMS
           ,IBC_CITEM_VERSIONS_B
           ,IBC_CITEM_VERSIONS_TL
        WHERE
           IBC_CONTENT_ITEMS.content_item_id = IBC_CITEM_VERSIONS_B.content_item_id
        AND
           IBC_CITEM_VERSIONS_B.citem_version_id = IBC_CITEM_VERSIONS_TL.citem_version_id
        AND
           IBC_CITEM_VERSIONS_TL.citem_version_id = p_citem_ver_id
        AND
           IBC_CITEM_VERSIONS_TL.LANGUAGE = p_base_lang;

   l_rendition_id NUMBER;
   row_id  VARCHAR2(250);

   CURSOR c_base_renditions(cv_citem_version_id NUMBER
                           ,cv_language         VARCHAR2
                           )IS
     SELECT file_id
           ,file_name
           ,mime_type
       FROM ibc_renditions
      WHERE citem_version_id = cv_citem_version_id
        AND LANGUAGE = cv_language;

   CURSOR c_populate_rend(cv_citem_version_id NUMBER
                         ,cv_language         VARCHAR2) IS
     SELECT CIVTL.LANGUAGE
       FROM ibc_citem_versions_tl CIVTL
      WHERE CIVTL.citem_version_id = cv_citem_version_id
        AND CIVTL.LANGUAGE <> cv_language;

BEGIN

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.start_process(
       p_proc_type  => 'PROCEDURE',
       p_proc_name  => 'Approve_Citem_Version_Int',
       p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                         p_tag     => 'PARAMETERS',
                         p_parms   => JTF_VARCHAR2_TABLE_4000(
                                        'p_citem_ver_id', p_citem_ver_id,
                                        'p_content_item_id', p_content_item_id,
                                        'p_base_lang', p_base_lang,
                                        'p_log_action', p_log_action,
                                        'px_object_version_number', px_object_version_number
                                      )
                         )
    );
  END IF;

    --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    temp := p_citem_ver_id;

    -- CREATING TEMP ATTRIBUTE BUNDLE
    DBMS_LOB.createtemporary(temp_bundle, TRUE, 2);

    OPEN info;
    FETCH info
    INTO ovn,version_number,start_date,end_date,attrib_fid,attach_fid,
         content_item_name,description,attach_fname,
         default_rendition_mime_type,attach_code;

    IF(info%NOTFOUND) THEN
        --DBMS_OUTPUT.put_line('EX - NO DATA FOUND FOR CREATED ITEM!');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'GENERL_ERROR');
        FND_MSG_PUB.ADD;
    END IF;

    CLOSE info;


  -- building full XML  if the bundle is present
    IF ( (attrib_fid IS NOT NULL) AND (x_return_status IS NOT NULL) ) THEN
        Ibc_Utilities_Pvt.build_attribute_bundle (
           p_file_id       => attrib_fid
          ,p_xml_clob_loc  => temp_bundle
        );
        -- VALIDATION
        validate_attribute_bundle(
            p_attribute_bundle  => temp_bundle
            ,p_citem_ver_id     => p_citem_ver_id
            ,p_language         => p_base_lang
            ,x_return_status    => x_return_status
        );
    END IF;


    -- doing actual updates
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.put_line('APPROVING VERSION');
        -- update version status
        Ibc_Citem_Versions_Pkg.update_row(
            p_CITEM_VERSION_ID          => p_citem_ver_id
            ,p_content_item_id          => p_content_item_id
            ,p_CITEM_VERSION_STATUS     => Ibc_Utilities_Pub.G_STV_APPROVED
            ,P_SOURCE_LANG              => p_base_lang
            ,px_object_version_number   => px_object_version_number
            ,p_citem_translation_status => Ibc_Utilities_Pub.G_STV_APPROVED
        );

        --DBMS_OUTPUT.put_line('APPROVING ITEM');
        -- set live version if this is base language
        Ibc_Content_Items_Pkg.update_row (
            p_CONTENT_ITEM_ID     => p_content_item_id
            ,p_LIVE_CITEM_VERSION_ID  => p_citem_ver_id
            ,p_CONTENT_ITEM_STATUS    => Ibc_Utilities_Pub.G_STI_APPROVED
            ,p_LOCKED_BY_USER_ID    => FND_API.G_MISS_NUM       -- Updated for STANDARD/perf change of G_MISS_xxx
            ,px_object_version_number => px_object_version_number
        );

        --DBMS_OUTPUT.put_line('POPULATING ALL LANGS');
        -- populating all the other languages
        -- ****RENDITIONS_WORK****
        Ibc_Citem_Versions_Pkg.populate_all_lang (
            p_CITEM_VERSION_ID             => temp
            ,p_CONTENT_ITEM_ID             => p_content_item_id
            ,p_VERSION_NUMBER              => version_number
            ,p_CITEM_VERSION_STATUS        => Ibc_Utilities_Pub.G_STV_APPROVED
            ,p_START_DATE                  => start_date
            ,p_END_DATE                    => end_date
            ,p_OBJECT_VERSION_NUMBER       => ovn
            ,p_ATTRIBUTE_FILE_ID           => attrib_fid
            ,p_ATTACHMENT_ATTRIBUTE_CODE   => attach_code
            ,P_SOURCE_LANG                    => p_base_lang
            ,p_ATTACHMENT_FILE_ID          => attach_fid
            ,p_CONTENT_ITEM_NAME           => content_item_name
            ,p_ATTACHMENT_FILE_NAME        => attach_fname
            ,p_DEFAULT_RENDITION_MIME_TYPE => default_rendition_mime_type
            ,p_DESCRIPTION                 => description
            ,p_CITEM_TRANSLATION_STATUS    => 'INPROGRESS'
        );


        -- Default the renditions for the base language
        -- Bug Fix: 3416463
        FOR cr_populate_ren IN c_populate_rend(p_citem_ver_id,p_base_lang) LOOP
          FOR cr_base_ren IN c_base_renditions(p_citem_ver_id,p_base_lang) LOOP
              l_rendition_id := NULL;
              ibc_renditions_pkg.insert_row(
                 px_rowid                => row_id
                ,px_rendition_id         => l_rendition_id
                ,p_object_version_number => G_OBJ_VERSION_DEFAULT
                ,p_language              => cr_populate_ren.LANGUAGE
                ,p_file_id               => cr_base_ren.file_id
                ,p_file_name             => cr_base_ren.file_name
                ,p_citem_version_id      => p_citem_ver_id
                ,p_mime_type             => cr_base_ren.mime_type
                );
          END LOOP;
        END LOOP;

        -- only logging if requested
        IF (p_log_action = FND_API.g_true) THEN
                               --***************************************************
                               --************ADDING TO AUDIT LOG********************
                               --***************************************************
                               Ibc_Utilities_Pvt.log_action(
                                   p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                   ,p_parent_value  => NULL
                                   ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                   ,p_object_value1 => p_content_item_id
                                   ,p_object_value2 => NULL
                                   ,p_object_value3 => NULL
                                   ,p_object_value4 => NULL
                                   ,p_object_value5 => NULL
                                   ,p_description   => 'Setting status to APPROVED and setting live version id'
                               );
                               --***************************************************
                               Ibc_Utilities_Pvt.log_action(
                                   p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                   ,p_parent_value  => p_content_item_id
                                   ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                   ,p_object_value1 => p_citem_ver_id
                                   ,p_object_value2 => NULL
                                   ,p_object_value3 => NULL
                                   ,p_object_value4 => NULL
                                   ,p_object_value5 => NULL
                                   ,p_description   => 'APPROVING'
                               );
                               --***************************************************
        END IF;

   ELSE
        --DBMS_OUTPUT.put_line('EX - Approval error');
        x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'APPROVAL_ERROR');
        FND_MSG_PUB.ADD;
  END IF;

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'px_object_version_number', px_object_version_number,
                      'x_return_status', x_return_status
                    )
      )
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', '*** EXCEPTION *** [' || SQLERRM || ']'
                      )
        )
      );
    END IF;
    RAISE;

END;

-- --------------------------------------------------------------
-- VERSION ENGINE
--
-- Used determine what to do with inputted content item data
--
-- Version Engine Logic
-- ** resolution points
-- ++ this point should not be able to be reached
--
-- Content Item Version = NULL?
--     YES --> Is Content Item = NULL?
--         YES -- Does content type exist?
--             YES --> Create new content item and version.                                    **
--             NO --> ERROR... ITEM MUST BE CREATED WITH VALID CONTENT TYPE                    **
--         NO  --> Content Item exist?
--             YES --> Is this language = base language?
--                 YES --> Create a new version with incremented version number!               **
--                 NO  --> ERROR... CANNOT TRANSLATE ITEM WITHOUT VERSION ID                   **
--             NO --> ERROR... CANNOT CREATE FROM NON-EXISTING ITEM                            **
--     NO  --> Does this version exist?
--         YES -->  Is it approved?
--             YES --> Is it the same language?
--                 YES --> ERROR... CANNOT UPDATE APPROVED ITEM!!                              **
--                 NO  --> Replace translation with this translation!                          **
--             NO  --> Update version with this new data!                                      **
--         NO  --> ERROR... CANNOT RESOLVE CONTENT ITEM VERSION ID!                            **
-- --------------------------------------------------------------
PROCEDURE version_engine(
    px_content_item_id          IN OUT NOCOPY NUMBER
    ,p_citem_ver_id             IN NUMBER
    ,p_ctype_code               IN VARCHAR2
    ,p_language                 IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_item_command             OUT NOCOPY CHAR
    ,x_version_command          OUT NOCOPY CHAR
    ,x_base_lang                OUT NOCOPY VARCHAR2
)
IS

--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'version_enginet';         --|**|
--******************* END REQUIRED VARIABLES ***************************
BEGIN

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.start_process(
       p_proc_type  => 'PROCEDURE',
       p_proc_name  => 'Version_Engine',
       p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                         p_tag     => 'PARAMETERS',
                         p_parms   => JTF_VARCHAR2_TABLE_4000(
                                        'px_content_item_id', px_content_item_id,
                                        'p_citem_ver_id', p_citem_ver_id,
                                        'p_ctype_code', p_ctype_code,
                                        'p_language', p_language
                                      )
                         )
    );
  END IF;

    --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_item_command := G_COMMAND_NOTHING;
    x_version_command := G_COMMAND_NOTHING;
    x_base_lang := USERENV('LANG');

-- Content Item Version = NULL?
    IF (p_citem_ver_id IS NULL) THEN
--     YES --> Is Content Item = NULL?
        IF (px_content_item_id IS NULL) THEN
--        YES -- Does content type exist?
            -- miss_char will NOT work here!
            IF (IBC_VALIDATE_PVT.isValidCType(p_ctype_code) = FND_API.g_true) THEN
--             YES --> Create new content item and version.
                -- create new item and version
                x_item_command := G_COMMAND_CREATE;
                x_version_command := G_COMMAND_CREATE;
                x_base_lang := p_language;
            ELSE
--             NO --> ERROR... ITEM MUST BE CREATED WITH VALID CONTENT TYPE
                --DBMS_OUTPUT.put_line('EX - ctype_code');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
                FND_MESSAGE.Set_Token('INPUT', 'p_ctype_code', FALSE);
                FND_MSG_PUB.ADD;
            END IF;
        ELSE
--         NO  --> Content Item exist?
            IF (IBC_VALIDATE_PVT.isValidCitem(px_content_item_id) = FND_API.g_true)  THEN
--              YES --> Is this language = base language?
                x_base_lang := getBaseLanguage(px_content_item_id);
                IF (x_base_lang = p_language) THEN
--                 YES --> Create a new version with incremented version number!               **
                     -- only update item if it needs it
                    x_item_command := G_COMMAND_UPDATE;
                    x_version_command := G_COMMAND_INCREMENT;
                ELSE
--                 NO  --> ERROR... CANNOT TRANSLATE ITEM WITHOUT VERSION ID                   **
                    --DBMS_OUTPUT.put_line('EX - translation without version id');
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IBC', 'TRANS_WITHOUT_VERSION_ID');
                    FND_MSG_PUB.ADD;
               END IF;
            ELSE
--             NO --> ERROR... CANNOT CREATE FROM NON-EXISTING ITEM
                --DBMS_OUTPUT.put_line('EX - content_item_id');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
                FND_MESSAGE.Set_Token('INPUT', 'px_content_item_id', FALSE);
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    ELSE
--     NO  --> Does this version exist?
        IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_true) THEN
            -- making sure that a valid value exists for content item id
            px_content_item_id := getCitemId(p_citem_ver_id);
            x_base_lang := getBaseLanguage(px_content_item_id);
--          YES -->  Is it approved?
            IF (IBC_VALIDATE_PVT.isApproved(p_citem_ver_id) = FND_API.g_true) THEN
--              YES --> Is it the same language?
                IF (x_base_lang = p_language) THEN
                    -- DBMS_OUTPUT.put_line('EX - content_item_id');
                    -- x_return_status := FND_API.G_RET_STS_ERROR;
                    -- FND_MESSAGE.Set_Name('IBC', 'UPDATE_APPROVED_ITEM_ERROR');
                    -- FND_MSG_PUB.ADD;
		    -- In R12 some of the metadata of an Item can be updated
		    -- post-approval
		    --
                    x_item_command := G_COMMAND_POST_APPROVAL_UPDATE;
                    x_version_command := G_COMMAND_POST_APPROVAL_UPDATE;
                ELSE
--                 NO  --> Replace translation with this translation!                          **
                    -- item cannot be updated at translation time!!
                    x_item_command := G_COMMAND_NOTHING;
                    x_version_command := G_COMMAND_TRANSLATE;
                END IF;
            ELSE
                IF (x_base_lang <> p_language) THEN
                    --DBMS_OUTPUT.put_line('EX - trans of non approved item');
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IBC', 'TRANS_NON_APPROVED_ITEM');
                    FND_MSG_PUB.ADD;
                ELSE
                    x_item_command := G_COMMAND_UPDATE;
                    x_version_command := G_COMMAND_UPDATE;
                END IF;
            END IF;
        ELSE
--         NO  --> ERROR... CANNOT RESOLVE CONTENT ITEM VERSION ID!                            **
            --DBMS_OUTPUT.put_line('EX - content_item_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'px_content_item_id', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'x_return_status', x_return_status,
                      'x_item_command', x_item_command,
                      'x_version_command', x_version_command,
                      'x_base_lang', x_base_lang
                    )
      )
    );
  END IF;


EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('EX - version engine general error');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'VERSION_ENGINE_ERROR');
      FND_MSG_PUB.ADD;
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          '_RETURN', '*** EXCEPTION *** [' || SQLERRM || ']',
                          'x_return_status', x_return_status,
                          'x_item_command', x_item_command,
                          'x_version_command', x_version_command,
                          'x_base_lang', x_base_lang
                        )
          )
        );
      END IF;
END;

-- -------------------
-- ----- PUBLIC ****************************************************************************************************************************
-- -------------------

-- --------------------------------------------------------------
-- APPROVE CONTENT ITEM
--
-- Used to move a content item version to the status of approved.
--
-- --------------------------------------------------------------
PROCEDURE approve_item(
    p_citem_ver_id              IN NUMBER
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'approve_citem_version';   --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    content_item_id NUMBER;
    -- variable used to determine whether to update live_version_id
    base_lang IBC_CONTENT_ITEMS.base_language%TYPE;
    temp NUMBER;
    dir_id NUMBER;
    l_dummy   VARCHAR2(1);

    CURSOR c_component_not_status (p_citem_ver_id IN NUMBER,
                                   p_status IN VARCHAR2)
    IS
      SELECT 'X'
       FROM ibc_citem_versions_b a,
            ibc_compound_relations b,
            ibc_content_items c
      WHERE a.citem_version_id = b.citem_version_id
        AND b.content_item_id = c.content_item_id
        AND a.citem_version_id = p_citem_ver_id
        AND c.content_item_status <> p_status;


BEGIN
--DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_approve_item;                                --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Approve_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

    -- checking version id
    IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - p_citem_ver_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- getting content item id and base language
    SELECT
        ibc_content_items.content_item_id
        ,ibc_content_items.base_language
        ,ibc_content_items.directory_node_id
    INTO
        content_item_id
        ,base_lang
        ,dir_id
    FROM
        ibc_content_items
        ,ibc_citem_versions_b
    WHERE
        ibc_content_items.content_item_id = ibc_citem_versions_b.content_item_id
    AND
       ibc_citem_versions_b.citem_version_id = p_citem_ver_id;

    -- ***************PERMISSION CHECK**********************************
    IF (hasPermission(content_item_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - no lock permissions');
        x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- ***************/PERMISSION CHECK**********************************


    -- **************CHECKING IF APPROVAL IS ALLOWED ******************
    -- can be approved if source lang is already approved or if this is the source lang
    SELECT
        MIN(ibc_citem_versions_b.citem_version_id)
    INTO
        temp
    FROM
       ibc_citem_versions_b
        ,ibc_citem_versions_tl
    WHERE
        (
            (
                ibc_citem_versions_tl.LANGUAGE = ibc_citem_versions_tl.source_lang
                    AND
                ibc_citem_versions_b.citem_version_status = Ibc_Utilities_Pub.G_STV_APPROVED
             )
         OR
             ibc_citem_versions_tl.source_lang = base_lang
         )
        AND
           ibc_citem_versions_b.citem_version_id = ibc_citem_versions_tl.citem_version_id
        AND
           ibc_citem_versions_b.citem_version_id = p_citem_ver_id;


    IF (temp IS NULL) THEN
        --DBMS_OUTPUT.put_line('EX - version cannot be approved');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'APPROVAL_NOT_ALLOWED');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Can be approved if in case of having components they are already approved.
    OPEN c_component_not_status(p_citem_ver_id, IBC_UTILITIES_PUB.G_STV_APPROVED);
    FETCH c_component_not_status INTO l_dummy;
    IF (c_component_not_status%FOUND) THEN
      CLOSE c_component_not_status;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'COMPONENT_APPROVAL_REQUIRED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_component_not_status;


-- *** VALIDATION OF VALUES ******
     -- version id
    IF (p_citem_ver_id IS NULL) THEN
        --DBMS_OUTPUT.put_line('EX - citem_ver_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'IBC_INPUT_REQUIRED');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- CALLING ACTUAL APPROVAL ROUTINE
    approve_citem_version_int(
      p_citem_ver_id              => p_citem_ver_id
      ,p_content_item_id          => content_item_id
      ,p_base_lang                => base_lang
      ,p_log_action               => FND_API.g_true
      ,px_object_version_number   => px_object_version_number
      ,x_return_status            => x_return_status
    );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'px_object_version_number', px_object_version_number,
                      'x_return_status', x_return_status,
                      'x_msg_count', x_msg_count,
                      'x_msg_data', x_msg_data
                    )
      )
    );
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_approve_item;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_approve_item;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_approve_item;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- ARCHIVE ITEM
--
-- Used to move content item to archived status
--
--
--
-- --------------------------------------------------------------
PROCEDURE archive_item(
    p_content_item_id           IN NUMBER
    ,p_cascaded_flag            IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'archive_item';            --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
   dir_id NUMBER;
   l_created_by    NUMBER;

   CURSOR c_creator(p_content_item_id NUMBER) IS
     SELECT created_by
       FROM ibc_content_items
      WHERE content_item_id = p_content_item_id;

BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_archive_item;                                --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Archive_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_content_item_id', p_content_item_id,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

    -- citem validation
    IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false ) THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Version Status validation
    -- If any content item version is in a submitted status then the Content Item
    -- cannot be archived
    IF (isCitemVerInPassedStatus(p_content_item_id,IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL))THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'IBC_ITEM_INVALID_FOR_ARCHIVE');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Item Locking Validation
    -- If the content item is not locked by the Current User then it cannot be archived
    IF NOT (isItemLockedByCurrentUser(p_content_item_id))THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'IBC_UNLOCK_NOT_ALLOW_MSG');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- If it has associations it will raise an error
    IF (Has_Associations(p_content_item_id) = FND_API.g_true) THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'IBC_NOARCHIVE_ASSOC_EXIST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Item Sub Item Validation
    -- If the content item is Used as Sub Item then it cannot be archived
    -- srrangar made this change to Fix Bug#3346690
    --
    IF (isItemaSubItem(p_content_item_id))THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'IBC_SUBITEM_INVALID_TO_ARCHIVE');

       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- If already archived then raise error
    IF (getContentItemStatus(p_content_item_id)
        IN (Ibc_Utilities_Pub.G_STI_ARCHIVED, Ibc_Utilities_Pub.G_STI_ARCHIVED_CASCADE))
    THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'IBC_CITEM_ALREADY_ARCHIVED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;



    -- If it has categories it will raise an error
    IF (Has_Categories(p_content_item_id) = FND_API.g_true) THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'IBC_NOARCHIVE_CATEGORIES_EXIST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- If it is default stylesheet raise error
    IF (Is_A_Default_Stylesheet(p_content_item_id) = FND_API.g_true) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'IBC_NOARCHIVE_DFLT_STYLESHEET');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_creator(p_content_item_id);
    FETCH c_creator INTO l_created_by;

    -- It is a Seeded Item it cannot be archived (Fix for bug# 3614353)
    IF (l_created_by = 1) THEN
        CLOSE c_creator;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'IBC_NOARCHIVE_SEED_ITEM');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE c_creator;

    dir_id := getDirectoryNodeId(p_content_item_id);
    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => p_content_item_id                                        --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    -- Actual update
    IF p_cascaded_flag = FND_API.g_false THEN
      Ibc_Content_Items_Pkg.update_row (
        p_content_item_id         => p_content_item_id
        ,p_content_item_status    => Ibc_Utilities_Pub.G_STI_ARCHIVED
        ,p_locked_by_user_id      => FND_API.G_MISS_NUM    -- Updated for STANDARD/perf change of G_MISS_xxx
        ,px_object_version_number => px_object_version_number
      );
    ELSE
      Ibc_Content_Items_Pkg.update_row (
        p_content_item_id         => p_content_item_id
        ,p_content_item_status    => Ibc_Utilities_Pub.G_STI_ARCHIVED_CASCADE
        ,p_locked_by_user_id      => FND_API.G_MISS_NUM    -- Updated for STANDARD/perf change of G_MISS_xxx
        ,px_object_version_number => px_object_version_number
      );
    END IF;


                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_ARCHIVE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => p_content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Archiving item'
                                   );
                                   --***************************************************

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );


  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'px_object_version_number', px_object_version_number,
                      'x_return_status', x_return_status,
                      'x_msg_count', x_msg_count,
                      'x_msg_data', x_msg_data
                    )
      )
    );
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_archive_item;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_archive_item;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_archive_item;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- CHANGE STATUS
--  It changes status of a particular version. It will not allow
--  changes to approved versions.  NOTE: archiving of versions is
--  not currently supported even though status CODE exists.
-- --------------------------------------------------------------
PROCEDURE change_status(
    p_citem_ver_id              IN NUMBER
    ,p_new_status               IN VARCHAR2
    ,p_language                 IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'change_status';--|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
   content_item_id NUMBER;
   ctype_code IBC_CONTENT_TYPES_B.content_type_code%TYPE;
   dir_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_change_status;                               --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Change_Status',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_new_status', p_new_status,
                                          'p_language', p_language,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

    -- checking version id
    IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - p_citem_ver_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- checking if valid status
    IF (IBC_VALIDATE_PVT.isValidStatus(p_new_status) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - p_status');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_status', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     IF (IBC_VALIDATE_PVT.isApproved(p_citem_ver_id) = FND_API.g_true) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'UPDATE_APPROVED_ITEM_ERROR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    content_item_id := getCitemId(p_citem_ver_id);
    ctype_code := getContentType(content_item_id);
    dir_id := getDirectoryNodeId(content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(content_item_id) = FND_API.g_false) THEN                                         --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(content_item_id) = FND_API.g_false) THEN                                         --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false
            AND
            (p_new_status NOT IN (Ibc_Utilities_Pub.G_STV_APPROVED, IBC_UTILITIES_PUB.G_STV_REJECTED)
             OR
             IBC_DATA_SECURITY_PVT.has_permission(                                                     --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_APPROVE'                                          --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                              --|*|
             )
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************


    IF (p_new_status = Ibc_Utilities_Pub.G_STV_APPROVED ) THEN
        approve_item(
            p_citem_ver_id              => p_citem_ver_id
            ,p_api_version_number       => p_api_version_number
            ,px_object_version_number   => px_object_version_number
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
        );
    ELSE

        --DBMS_OUTPUT.put_line('sending to update row with civid/ciid/stat/lang/ovn :'||p_citem_ver_id||' / '||content_item_id||' / '||p_new_status||' / '||p_language||' / '||px_object_version_number);
        -- update version status
        Ibc_Citem_Versions_Pkg.update_row(
            p_CITEM_VERSION_ID          => p_citem_ver_id
            ,p_content_item_id        => content_item_id
            ,p_CITEM_VERSION_STATUS   => p_new_status
            ,P_SOURCE_LANG            => p_language
            ,px_object_version_number => px_object_version_number
        );


                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Updating version'
                                   );

                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => p_citem_ver_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Updating version'
                                   );
                                   --***************************************************
        IF p_new_status = IBC_UTILITIES_PUB.G_STV_APPROVED THEN
          Ibc_Utilities_Pvt.log_action(
            p_activity       => Ibc_Utilities_Pvt.G_ALA_APPROVE
            ,p_parent_value  => content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
            ,p_object_value1 => p_citem_ver_id
            ,p_object_value2 => NULL
            ,p_object_value3 => NULL
            ,p_object_value4 => NULL
            ,p_object_value5 => NULL
            ,p_description   => 'Approved'
          );
        ELSIF p_new_status = IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL THEN
          Ibc_Utilities_Pvt.log_action(
            p_activity       => Ibc_Utilities_Pvt.G_ALA_SUBMIT
            ,p_parent_value  => content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
            ,p_object_value1 => p_citem_ver_id
            ,p_object_value2 => NULL
            ,p_object_value3 => NULL
            ,p_object_value4 => NULL
            ,p_object_value5 => NULL
            ,p_description   => 'Submitted for Approval'
          );
        ELSIF p_new_status = IBC_UTILITIES_PUB.G_STV_REJECTED THEN
          Ibc_Utilities_Pvt.log_action(
            p_activity       => Ibc_Utilities_Pvt.G_ALA_REJECT
            ,p_parent_value  => content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
            ,p_object_value1 => p_citem_ver_id
            ,p_object_value2 => NULL
            ,p_object_value3 => NULL
            ,p_object_value4 => NULL
            ,p_object_value5 => NULL
            ,p_description   => 'Rejected'
          );
        ELSIF p_new_status = IBC_UTILITIES_PUB.G_STV_ARCHIVED THEN
          Ibc_Utilities_Pvt.log_action(
            p_activity       => Ibc_Utilities_Pvt.G_ALA_ARCHIVE
            ,p_parent_value  => content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
            ,p_object_value1 => p_citem_ver_id
            ,p_object_value2 => NULL
            ,p_object_value3 => NULL
            ,p_object_value4 => NULL
            ,p_object_value5 => NULL
            ,p_description   => 'Archived'
          );
        END IF;


    END IF;

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'px_object_version_number', px_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_change_status;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_change_status;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_change_status;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- COPY ITEM
--
-- Valid content item id or citem version id must be given.  If
-- version id is given, a copy will be made of that version.  If version
-- id is not given and valid content item id is given, a copy of the
-- newest version of that item will be created.
--
-- Both in/out variables will be populated with the newly created info.
--
-- --------------------------------------------------------------
-----------------------------------------------------------------
-- 11.5.10 Requirement Content Item Name must be unique with in a Folder
-- While Copying a Content Item accept the Name of the New Content Item as a
-- parameter.
------------------------------------------------------------------
PROCEDURE copy_item(
    p_item_reference_code       IN VARCHAR2
    ,p_new_citem_name   IN VARCHAR2
    ,p_directory_node_id        IN NUMBER
    ,p_language                 IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'copy_item';               --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    row_id  VARCHAR2(250);  -- required for use with table handlers
    lang IBC_CITEM_VERSIONS_TL.LANGUAGE%TYPE;
    new_citem_id NUMBER;
    new_citem_ver_id NUMBER;
    l_new_citem_name  VARCHAR2(240) := p_new_citem_name;

    o_ctype_code IBC_CONTENT_ITEMS.content_type_code%TYPE;
    o_dir_node NUMBER;
    o_parent_id NUMBER;
    o_wd_flag IBC_CONTENT_ITEMS.wd_restricted_flag%TYPE;
    o_trans_flag IBC_CONTENT_ITEMS.translation_required_flag%TYPE;

    CURSOR c_old_item IS
        SELECT
            content_type_code
            ,directory_node_id
            ,parent_item_id
            ,wd_restricted_flag
            ,translation_required_flag
        FROM
            IBC_CONTENT_ITEMS
        WHERE
            content_item_id = px_content_item_id;

    /*
    -- sanshuma : 25-NOV-2004 : commenting out copy associations to fix bug#4020980.

    associations VARCHAR2(1000) := 'SELECT
                                        association_type_code
                                        ,associated_object_val1
                                        ,associated_object_val2
                                        ,associated_object_val3
                                        ,associated_object_val4
                                        ,associated_object_val5
                                        ,citem_version_id
                                    FROM
                                        IBC_ASSOCIATIONS
                                    WHERE
                                        content_item_id = :CID
                                      AND (
                                        (citem_version_id IS NULL) OR
                                        (citem_version_id = :CIVID)
                                          )
                                    ';
   cursor_id INTEGER;  -- dynamic sql variable
   cursor_return INTEGER; -- dynamic sql variable

   atc IBC_ASSOCIATIONS.association_type_code%TYPE; -- temp loop association type code
   aov1 IBC_ASSOCIATIONS.associated_object_val1%TYPE; -- temp loop associated object code
   aov2 IBC_ASSOCIATIONS.associated_object_val2%TYPE; -- temp loop associated object code
   aov3 IBC_ASSOCIATIONS.associated_object_val3%TYPE; -- temp loop associated object code
   aov4 IBC_ASSOCIATIONS.associated_object_val4%TYPE; -- temp loop associated object code
   aov5 IBC_ASSOCIATIONS.associated_object_val5%TYPE; -- temp loop associated object code
   civid IBC_ASSOCIATIONS.citem_version_id%TYPE; -- temp loop for citem version id

   assoc_id NUMBER; --temp holder of newly created association id

   */


    CURSOR c_keywords(p_content_item_id NUMBER) IS
      SELECT keyword
        FROM ibc_citem_keywords
       WHERE content_item_id = p_content_item_id;

BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_copy_item;                                   --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
      ,p_api_version_number                                    --|**|
      ,l_api_name                                              --|**|
      ,G_PKG_NAME                                              --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Copy_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_item_reference_code', p_item_reference_code,
                                          'p_directory_node_id', p_directory_node_id,
                                          'p_language', p_language,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_content_item_id', px_content_item_id,
                                          'px_citem_ver_id', px_citem_ver_id,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

   IF (px_object_version_number IS NULL) THEN
      px_object_version_number := 1;
   END IF;

   -- Filling in version id if non-existent
   IF ( (px_citem_ver_id IS NULL) OR (IBC_VALIDATE_PVT.isValidCitemVer(px_citem_ver_id) = FND_API.g_false) ) THEN
       IF (px_content_item_id IS NULL) THEN
         --DBMS_OUTPUT.put_line('EX - content_item_id');
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'IBC_INPUT_REQUIRED');
         FND_MESSAGE.Set_Token('INPUT', 'px_content_item_id', FALSE);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- getting item that needs to be copied
       IF (IBC_VALIDATE_PVT.isValidCitem(px_content_item_id) = FND_API.g_false) THEN
         --DBMS_OUTPUT.put_line('EX - content_item_id');
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
         FND_MESSAGE.Set_Token('INPUT', 'px_content_item_id', FALSE);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       px_citem_ver_id := getMaxVersionId(px_content_item_id);
   ELSE
      -- using derived content item id to make sure that it is valid regardless if it were provided
      px_content_item_id := getCitemId(px_citem_ver_id);
   END IF;


   -- Validating uniqueness for item_reference_code
   IF exist_item_reference_code(p_item_reference_code, NULL) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('IBC', 'IBC_DUPLICATE_ITEM_REF_CODE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

    OPEN c_old_item;

    FETCH
        c_old_item
    INTO
        o_ctype_code
        ,o_dir_node
        ,o_parent_id
        ,o_wd_flag
        ,o_trans_flag;

    IF(c_old_item%NOTFOUND) THEN
        CLOSE c_old_item;
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- setting language variable
    IF (p_language IS NULL) THEN
        lang := USERENV('LANG');
    ELSE
        lang := p_language;
    END IF;

--
-- srrangar added this code to fix bug#3351929
-- User should have Manage Item Privs on the Folder to be able to
-- Copy the Item.
--

             -- ***************PERMISSION CHECK*********************************************************************
             IF( IBC_DATA_SECURITY_PVT.has_permission(                                                          --|*|
                         p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')    --|*|
                         ,p_instance_pk1_value    => NULL                                                       --|*|
                         ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                         ,p_container_pk1_value   => NVL(p_directory_node_id, o_dir_node)                                          --|*|
                         ,p_permission_code       => 'CITEM_EDIT'                                               --|*|
                         ,p_current_user_id       => FND_GLOBAL.user_id                                         --|*|
                         ) = FND_API.g_false                                                                    --|*|
                   ) THEN                                                                                       --|*|
                  --DBMS_OUTPUT.put_line('EX - no permissions');                                                --|*|
                  x_return_status := FND_API.G_RET_STS_ERROR;                                                   --|*|
                   FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                         --|*|
                  FND_MSG_PUB.ADD;                                                                              --|*|
                  RAISE FND_API.G_EXC_ERROR;                                                                    --|*|
               END IF;                                                                                            --|*|
               -- ***************PERMISSION CHECK*********************************************************************


    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    -- ******* GOT INFO, NOW CREATE! ************************************
        IBC_CONTENT_ITEMS_PKG.insert_row(
           x_rowid                      => row_id
           ,px_content_item_id          => new_citem_id
           ,p_content_type_code         => o_ctype_code
           ,p_item_reference_code       => p_item_reference_code
           ,p_directory_node_id         => NVL(p_directory_node_id, o_dir_node)
           ,p_live_citem_version_id     => NULL
           ,p_content_item_status       => IBC_UTILITIES_PUB.G_STI_PENDING
           ,p_locked_by_user_id         => NULL
           ,p_wd_restricted_flag        => o_wd_flag
           ,p_base_language             => lang
           ,p_translation_required_flag => o_trans_flag
           ,p_owner_resource_id         => FND_GLOBAL.USER_ID
           ,p_owner_resource_type       => 'USER'
           ,p_application_id            => NULL
           ,p_parent_item_id            => NULL
           ,p_request_id                => NULL
           ,p_object_version_number     => px_object_version_number
        );

     -- ******* COPY VERSION ********************************************
         copy_version_int(
            p_language                  => lang
      ,p_new_citem_name   => l_new_citem_name
            ,px_content_item_id         => new_citem_id
            ,px_citem_ver_id            => px_citem_ver_id
            ,px_object_version_number   => px_object_version_number
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
         );

    -- ***** COPY KEYWORDS ********************************************
        FOR r_keyword IN c_keywords(px_content_item_id) LOOP
          IBC_CITEM_KEYWORDS_PKG.insert_row(
            x_rowid                  => row_id
            ,p_content_item_id       => new_citem_id
            ,p_keyword               => r_keyword.keyword
            ,p_object_version_number => 1
         );
        END LOOP;


    -- ******* COPY ASSOCIATIONS ********************************************

        /*
        -- sanshuma : 25-NOV-2004 : commenting out copy associations to fix bug#4020980.

        -- looping through all components of this attribute type
        cursor_id := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cursor_id,associations, DBMS_SQL.V7);
        -- bind variables
        DBMS_SQL.BIND_VARIABLE(cursor_id,':CID',px_content_item_id);
        DBMS_SQL.BIND_VARIABLE(cursor_id,':CIVID',px_citem_ver_id);
        -- define output variables
        DBMS_SQL.DEFINE_COLUMN(cursor_id, 1, atc, 100);
        DBMS_SQL.DEFINE_COLUMN(cursor_id, 2, aov1, 254);
        DBMS_SQL.DEFINE_COLUMN(cursor_id, 3, aov2, 254);
        DBMS_SQL.DEFINE_COLUMN(cursor_id, 4, aov3, 254);
        DBMS_SQL.DEFINE_COLUMN(cursor_id, 5, aov4, 254);
        DBMS_SQL.DEFINE_COLUMN(cursor_id, 6, aov5, 254);

        -- executing cursor
        cursor_return := DBMS_SQL.EXECUTE(cursor_id);

        -- VALIDATION LOOP
        LOOP
            IF (DBMS_SQL.FETCH_ROWS(cursor_id) = 0) THEN
                EXIT;
            END IF;

            --resetting id
            assoc_id := null;

            -- loading column values
            DBMS_SQL.COLUMN_VALUE(cursor_id, 1, atc);
            DBMS_SQL.COLUMN_VALUE(cursor_id, 2, aov1);
            DBMS_SQL.COLUMN_VALUE(cursor_id, 3, aov2);
            DBMS_SQL.COLUMN_VALUE(cursor_id, 4, aov3);
            DBMS_SQL.COLUMN_VALUE(cursor_id, 5, aov4);
            DBMS_SQL.COLUMN_VALUE(cursor_id, 6, aov5);
            DBMS_SQL.COLUMN_VALUE(cursor_id, 7, civid);


            IF civid IS NOT NULL THEN
              civid := px_citem_ver_id;
            END IF;

            -- copying every row
            Ibc_Associations_Pkg.insert_row (
                px_association_id           => assoc_id
                ,p_content_item_id          => new_citem_id
                ,p_citem_version_id         => civid
                ,p_association_type_code  => atc
                ,p_associated_object_val1   => aov1
                ,p_associated_object_val2   => aov2
                ,p_associated_object_val3   => aov3
                ,p_associated_object_val4   => aov4
                ,p_associated_object_val5   => aov5
                ,p_object_version_number  => G_OBJ_VERSION_DEFAULT
                ,x_rowid            => row_id
            );


        END LOOP;
        -- clean up!
        DBMS_SQL.CLOSE_CURSOR(cursor_id);

        */

    END IF;  -- END ASSOCIATION COPYING

    -- setting value for return
    px_content_item_id := new_citem_id;

    -- COMMIT?
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      IF (p_commit = FND_API.g_true) THEN
        COMMIT;
      END IF;
    ELSIF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'px_content_item_id', px_content_item_id,
                      'px_citem_ver_id', px_citem_ver_id,
                      'px_object_version_number', px_object_version_number,
                      'x_return_status', x_return_status,
                      'x_msg_count', x_msg_count,
                      'x_msg_data', x_msg_data
                    )
      )
    );
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_copy_item;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_content_item_id', px_content_item_id,
                          'px_citem_ver_id', px_citem_ver_id,
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_copy_item;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_content_item_id', px_content_item_id,
                          'px_citem_ver_id', px_citem_ver_id,
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_copy_item;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_content_item_id', px_content_item_id,
                          'px_citem_ver_id', px_citem_ver_id,
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- COPY ITEM
-- --------------------------------------------------------------
-- Overloaded New Content Item Name is not passed for backward compatibility
--
PROCEDURE copy_item(
    p_item_reference_code       IN VARCHAR2
    ,p_directory_node_id        IN NUMBER
    ,p_language                 IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS

BEGIN
  copy_item(
    p_item_reference_code     => p_item_reference_code
    ,p_new_citem_name       => NULL
    ,p_directory_node_id      => p_directory_node_id
    ,p_language               => p_language
    ,p_commit                 => p_commit
    ,p_api_version_number     => p_api_version_number
    ,p_init_msg_list          => p_init_msg_list
    ,px_content_item_id       => px_content_item_id
    ,px_citem_ver_id          => px_citem_ver_id
    ,px_object_version_number => px_object_version_number
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

-- Overloaded: No directory node id passed
PROCEDURE copy_item(
    p_item_reference_code       IN VARCHAR2
    ,p_language                 IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
BEGIN
  copy_item(
    p_item_reference_code     => p_item_reference_code
    ,p_directory_node_id      => NULL
    ,p_language               => p_language
    ,p_commit                 => p_commit
    ,p_api_version_number     => p_api_version_number
    ,p_init_msg_list          => p_init_msg_list
    ,px_content_item_id       => px_content_item_id
    ,px_citem_ver_id          => px_citem_ver_id
    ,px_object_version_number => px_object_version_number
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END copy_item;

-- --------------------------------------------------------------
-- COPY VERSION
--
-- Valid content item id or citem version id must be given.  If
-- version id is given, a copy will be made of that version.  If version
-- id is not given and valid content item id is given, a copy of the
-- newest version of that item will be created.
--
-- Both in/out variables will be populated with the newly created info.
--
-- If both variables are given, the content item id is assumed to be
-- the new one for it...  in this case, object version number should
-- be null.
-- --------------------------------------------------------------
PROCEDURE copy_version(
    p_language                  IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'copy_version';            --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    lang IBC_CITEM_VERSIONS_TL.LANGUAGE%TYPE;

BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_copy_version;                                --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

   IF IBC_DEBUG_PVT.debug_enabled THEN
     IBC_DEBUG_PVT.start_process(
        p_proc_type  => 'PROCEDURE',
        p_proc_name  => 'Copy_Version',
        p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                          p_tag     => 'PARAMETERS',
                          p_parms   => JTF_VARCHAR2_TABLE_4000(
                                         'p_language', p_language,
                                         'p_commit', p_commit,
                                         'p_api_version_number', p_api_version_number,
                                         'p_init_msg_list', p_init_msg_list,
                                         'px_content_item_id', px_content_item_id,
                                         'px_citem_ver_id', px_citem_ver_id,
                                         'px_object_version_number', px_object_version_number
                                       )
                          )
     );
   END IF;

   -- Filling in version id if non-existent
   IF ( (px_citem_ver_id IS NULL) OR (IBC_VALIDATE_PVT.isValidCitemVer(px_citem_ver_id) = FND_API.g_false) ) THEN
       -- getting item that needs to be copied
       IF ( (px_content_item_id IS NULL) OR (IBC_VALIDATE_PVT.isValidCitem(px_content_item_id) = FND_API.g_false) ) THEN
         --DBMS_OUTPUT.put_line('EX - content_item_id');
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
         FND_MESSAGE.Set_Token('INPUT', 'px_content_item_id/px_citem_ver_id combination', FALSE);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
           px_citem_ver_id := getMaxVersionId(px_content_item_id);
       END IF;
   ELSE
      -- using derived content item id to make sure that it is valid regardless if it were provided
      px_content_item_id := getCitemId(px_citem_ver_id);
   END IF;

    -- setting language variable
    IF (p_language IS NULL) THEN
        lang := USERENV('LANG');
    ELSE
        lang := p_language;
    END IF;

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      copy_version_int(
         p_language                  => lang
   ,p_new_citem_name       => NULL
         ,px_content_item_id         => px_content_item_id
         ,px_citem_ver_id            => px_citem_ver_id
         ,px_object_version_number   => px_object_version_number
         ,x_return_status            => x_return_status
         ,x_msg_count                => x_msg_count
         ,x_msg_data                 => x_msg_data
      );
   END IF;

    -- COMMIT?
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      IF (p_commit = FND_API.g_true) THEN
        COMMIT;
      END IF;
    ELSIF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'px_content_item_id', px_content_item_id,
                        'px_citem_ver_id', px_citem_ver_id,
                        'px_object_version_number', px_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_copy_version;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_content_item_id', px_content_item_id,
                          'px_citem_ver_id', px_citem_ver_id,
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_copy_version;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_content_item_id', px_content_item_id,
                          'px_citem_ver_id', px_citem_ver_id,
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_copy_version;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'px_content_item_id', px_content_item_id,
                          'px_citem_ver_id', px_citem_ver_id,
                          'px_object_version_number', px_object_version_number,
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- DELETE COMPONENT
--
-- Used to remove a component item from a content item.
--
--
--
-- --------------------------------------------------------------
PROCEDURE delete_component(
    p_attribute_type_code       IN VARCHAR2
    ,p_citem_ver_id             IN NUMBER
    ,p_content_item_id          IN NUMBER
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'update_citem_association';--|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
   temp NUMBER;
   content_item_id NUMBER;
   ctype_code IBC_CONTENT_TYPES_B.content_type_code%TYPE;
   dir_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_delete_component;                            --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Delete_Component',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_attribute_type_code', p_attribute_type_code,
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_content_item_id', p_content_item_id,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

-- *** VALIDATION OF VALUES ******
   -- version id
   IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
     --DBMS_OUTPUT.put_line('EX - citem_ver_id');
     x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
     FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- citem
   IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false ) THEN
     --DBMS_OUTPUT.put_line('EX - content_item_id');
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
     FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   content_item_id := getCitemId(p_citem_ver_id);
   ctype_code := getContentType(content_item_id);
   dir_id := getDirectoryNodeId(content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(content_item_id) = FND_API.g_false) THEN                                         --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    SELECT
      MIN(compound_relation_id)
    INTO
      temp
    FROM
      ibc_compound_relations
    WHERE
      content_item_id = content_item_id
    AND
      content_type_code = ctype_code
    AND
      attribute_type_code = p_attribute_type_code
    AND
      content_item_id = p_content_item_id
    AND
      citem_version_id = p_citem_ver_id;

    IF (temp IS NULL) THEN
      --DBMS_OUTPUT.put_line('EX - unable to find compound relationship');
      x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('IBC', 'INVALID_COMPOUND_RELATIONSHIP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      Ibc_Compound_Relations_Pkg.delete_row(temp);
                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Updating version'
                                   );
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => p_citem_ver_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Removing component'
                                   );
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_REMOVE
                                       ,p_parent_value  => p_citem_ver_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_COMPONENT
                                       ,p_object_value1 => p_attribute_type_code
                                       ,p_object_value2 => ctype_code
                                       ,p_object_value3 => content_item_id
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Removing component: '|| p_content_item_id
                                   );
                                   --***************************************************
    END IF;

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'x_return_status', x_return_status,
                      'x_msg_count', x_msg_count,
                      'x_msg_data', x_msg_data
                    )
      )
    );
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_delete_component;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_delete_component;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_delete_component;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- DELETE ASSOCIATION
--
--
-- --------------------------------------------------------------
PROCEDURE delete_association(
    p_content_item_id           IN NUMBER
    ,p_association_type_code    IN VARCHAR2
    ,p_associated_object_val1   IN VARCHAR2
    ,p_associated_object_val2   IN VARCHAR2
    ,p_associated_object_val3   IN VARCHAR2
    ,p_associated_object_val4   IN VARCHAR2
    ,p_associated_object_val5   IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'delete_citem_association';--|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    -- used to loop through all the attributes
    A_LIST VARCHAR2(4000) := 'SELECT
                                association_id
                            FROM
                                ibc_associations
                            WHERE
                                content_item_id = :CITEM
                            AND
                                association_type_code = :ACODE
                            AND
                                associated_object_val1 = :VAL1';

    cursor_id INTEGER;  -- dynamic sql variable
    cursor_return INTEGER; -- dynamic sql variable
    aid NUMBER;  -- temp variable to hold the association number
    counter NUMBER := 0;
    dir_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_delete_association;                          --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Delete_Association',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_content_item_id', p_content_item_id,
                                          'p_association_type_code', p_association_type_code,
                                          'p_associated_object_val1', p_associated_object_val1,
                                          'p_associated_object_val2', p_associated_object_val2,
                                          'p_associated_object_val3', p_associated_object_val3,
                                          'p_associated_object_val4', p_associated_object_val4,
                                          'p_associated_object_val5', p_associated_object_val5,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

    -- citem validation
    IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false ) THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   dir_id := getDirectoryNodeId(p_content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => p_content_item_id                                        --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

      -- insert components --------------------------------
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        -- BUILDING QUERY
        IF (p_associated_object_val2 IS NOT NULL) THEN
            A_LIST := A_LIST || ' AND associated_object_val2 = :VAL2';
        ELSE
            A_LIST := A_LIST || ' AND associated_object_val2 is null';
        END IF;

        IF (p_associated_object_val3 IS NOT NULL) THEN
            A_LIST := A_LIST || ' AND associated_object_val3 = :VAL3';
        ELSE
            A_LIST := A_LIST || ' AND associated_object_val3 is null';
        END IF;

        IF (p_associated_object_val4 IS NOT NULL) THEN
            A_LIST := A_LIST || ' AND associated_object_val4 = :VAL4';
        ELSE
            A_LIST := A_LIST || ' AND associated_object_val4 is null';
        END IF;

        IF (p_associated_object_val5 IS NOT NULL) THEN
            A_LIST := A_LIST || ' AND associated_object_val5 = :VAL5';
        ELSE
            A_LIST := A_LIST || ' AND associated_object_val5 is null';
        END IF;
        -- FINISHED BUILDING QUERY


        -- OPENING CURSOR
        cursor_id := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cursor_id, A_LIST, DBMS_SQL.V7);

        -- SETTING BIND VARIABLES
        DBMS_SQL.BIND_VARIABLE(cursor_id,':ACODE',p_association_type_code);
        DBMS_SQL.BIND_VARIABLE(cursor_id,':CITEM',p_content_item_id);
        DBMS_SQL.BIND_VARIABLE(cursor_id,':VAL1',p_associated_object_val1);

        -- SETTING REMAINING BIND VARIABLES ACCORDING TO IF THEY ARE USED OR NOT
        IF (p_associated_object_val2 IS NOT NULL) THEN
            DBMS_SQL.BIND_VARIABLE(cursor_id,':VAL2',p_associated_object_val2);
        END IF;
        IF (p_associated_object_val3 IS NOT NULL) THEN
            DBMS_SQL.BIND_VARIABLE(cursor_id,':VAL3',p_associated_object_val3);
        END IF;
        IF (p_associated_object_val4 IS NOT NULL) THEN
            DBMS_SQL.BIND_VARIABLE(cursor_id,':VAL4',p_associated_object_val4);
        END IF;
        IF (p_associated_object_val5 IS NOT NULL) THEN
            DBMS_SQL.BIND_VARIABLE(cursor_id,':VAL5',p_associated_object_val5);
        END IF;

        -- DEFINING OUTPUT VARIABLE
        DBMS_SQL.DEFINE_COLUMN(cursor_id, 1, aid);

        -- executing cursor
        cursor_return := DBMS_SQL.EXECUTE(cursor_id);

        -- LOOPING FOR EACH ASSOCIATION FOUND MATCHING CRITERIA
        LOOP
            IF (DBMS_SQL.FETCH_ROWS(cursor_id) = 0) THEN
                EXIT;
            END IF;

            -- setting flag that at least one was found
            counter := counter+1;

            -- loading column values
            DBMS_SQL.COLUMN_VALUE(cursor_id, 1, aid);

             Ibc_Associations_Pkg.delete_row(
                 p_association_id           => aid
             );

                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => p_content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Updating item'
                                   );
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_REMOVE
                                       ,p_parent_value  => p_content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ASSOCIATION
                                       ,p_object_value1 => p_associated_object_val1
                                       ,p_object_value2 => p_associated_object_val2
                                       ,p_object_value3 => p_associated_object_val3
                                       ,p_object_value4 => p_associated_object_val4
                                       ,p_object_value5 => p_associated_object_val5
                                       ,p_description   => 'Deleting association of type '|| p_association_type_code
                                   );
                                   --***************************************************

        END LOOP;
        -- clean up!
        DBMS_SQL.CLOSE_CURSOR(cursor_id);

    END IF;

    IF (counter = 0) THEN
        --DBMS_OUTPUT.put_line('EX - no association found to delete');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'NO_ASSOCIATION_FOUND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --DBMS_OUTPUT.put_line(counter||' association(s) deleted');

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_delete_association;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_delete_association;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_delete_association;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- GET ATTRIBUTE BUNDLE
--
-- Used to get the attribute bundle for updating/etc
--
-- --------------------------------------------------------------
PROCEDURE get_attribute_bundle(
    p_citem_ver_id           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,p_api_version_number    IN NUMBER
    ,x_attribute_type_codes  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes            OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_object_version_number OUT NOCOPY NUMBER
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  L_API_NAME CONSTANT VARCHAR2(30) := 'get_attribute_bundle';    --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************

    attribute_fid NUMBER; --variable to returned attribute bundle id
    return_status CHAR(1); -- variable to check from returning procedures
    ctype_code IBC_CONTENT_TYPES_B.content_type_code%TYPE;
    content_item_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Get_Attribute_Bundle',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_init_msg_list', p_init_msg_list,
                                          'p_api_version_number', p_api_version_number
                                        )
                           )
      );
    END IF;

    -- checking for valid inputs and throwing exception if invalid
    IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - CITEM_VER_ID');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    attribute_fid := getAttribFID(p_citem_ver_id);
    -- if there is no attribute bundle
    IF (attribute_fid IS NULL) THEN
        --DBMS_OUTPUT.put_line('EX - no attribute');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'IBC_BUNDLE_NOT_EXISTING');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    get_citem_info(
        p_citem_ver_id          => p_citem_ver_id
        ,x_content_item_id      => content_item_id
        ,x_ctype_code           => ctype_code
        ,x_object_version_number=> x_object_version_number
    );


    -- if there is no content type code
    IF (ctype_code IS NULL) THEN
        --DBMS_OUTPUT.put_line('EX - getContentTypeV');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'UNABLE_TO_IDENTIFY_CTYPE');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF(x_return_status <> FND_API.G_RET_STS_ERROR) THEN
        get_attribute_bundle_int(
            p_attrib_fid             => attribute_fid
            ,p_ctype_code            => ctype_code
            ,x_attribute_type_codes  => x_attribute_type_codes
            ,x_attribute_type_names  => x_attribute_type_names
            ,x_attributes            => x_attributes
            ,x_return_status       => x_return_status
        );
    END IF;

    IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
        --DBMS_OUTPUT.put_line('EX - get_attribute_bundle_int');
        x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_ERROR');
        FND_MESSAGE.Set_Token('SITUATION', 'get_attribute_bundle_int', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_32767(
                      'x_attribute_type_codes', IBC_DEBUG_PVT.make_list(x_attribute_type_codes),
                      'x_attribute_type_names', IBC_DEBUG_PVT.make_list(x_attribute_type_names),
                      'x_attributes', IBC_DEBUG_PVT.make_list_VC32767(x_attributes),
                      'x_return_status', x_return_status,
                      'x_msg_count', x_msg_count,
                      'x_msg_data', x_msg_data
                    )
      )
    );
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_32767(
                          'x_attribute_type_codes', IBC_DEBUG_PVT.make_list(x_attribute_type_codes),
                          'x_attribute_type_names', IBC_DEBUG_PVT.make_list(x_attribute_type_names),
                          'x_attributes', IBC_DEBUG_PVT.make_list_VC32767(x_attributes),
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_32767(
                          'x_attribute_type_codes', IBC_DEBUG_PVT.make_list(x_attribute_type_codes),
                          'x_attribute_type_names', IBC_DEBUG_PVT.make_list(x_attribute_type_names),
                          'x_attributes', IBC_DEBUG_PVT.make_list_VC32767(x_attributes),
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_32767(
                          'x_attribute_type_codes', IBC_DEBUG_PVT.make_list(x_attribute_type_codes),
                          'x_attribute_type_names', IBC_DEBUG_PVT.make_list(x_attribute_type_names),
                          'x_attributes', IBC_DEBUG_PVT.make_list_VC32767(x_attributes),
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- GET ATTRIBUTE BUNDLE
--
-- Overloaded to support old 4k limit for attribute values
--
-- --------------------------------------------------------------
PROCEDURE get_attribute_bundle(
    p_citem_ver_id           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,p_api_version_number    IN NUMBER
    ,x_attribute_type_codes  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes            OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_object_version_number OUT NOCOPY NUMBER
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  l_tmp_attributes      JTF_VARCHAR2_TABLE_32767;
BEGIN

  get_attribute_bundle(
    p_citem_ver_id           => p_citem_ver_id
    ,p_init_msg_list         => p_init_msg_list
    ,p_api_version_number    => p_api_version_number
    ,x_attribute_type_codes  => x_attribute_type_codes
    ,x_attribute_type_names  => x_attribute_type_names
    ,x_attributes            => l_tmp_attributes
    ,x_object_version_number => x_object_version_number
    ,x_return_status         => x_return_status
    ,x_msg_count             => x_msg_count
    ,x_msg_data              => x_msg_data
  );

  IF l_tmp_attributes IS NOT NULL AND l_tmp_attributes.COUNT > 0 THEN
    x_attributes := JTF_VARCHAR2_TABLE_4000();
    x_attributes.extend(l_tmp_attributes.COUNT);
    FOR I IN 1..l_tmp_attributes.COUNT LOOP
      x_attributes(I) := l_tmp_attributes(I);
    END LOOP;
  END IF;

-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get_attribute_bundle;

-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- Used to get info to display on update page
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_skip_security          IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  L_API_NAME CONSTANT VARCHAR2(30) := 'get_trans_item';         --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************

    attribute_fid NUMBER; --variable to returned attribute bundle id

    l_default_rendition_mime_type VARCHAR2(80);

    l_index INTEGER := 1; -- counter for component loop
    return_status CHAR(1);
    lang IBC_CITEM_VERSIONS_TL.LANGUAGE%TYPE;

    CURSOR c_Rendition_Name(p_mime_type VARCHAR2, p_language VARCHAR2) IS
      SELECT MEANING
        FROM FND_LOOKUP_VALUES
        WHERE LOOKUP_TYPE = IBC_UTILITIES_PVT.G_REND_LOOKUP_TYPE
          AND LANGUAGE = p_language
          AND LOOKUP_CODE = p_mime_type;


    CURSOR c_components(p_citem_version_id NUMBER,
                        p_language         VARCHAR2)
    IS
      SELECT ibc_compound_relations.content_item_id      ciid
             ,ibc_content_items.owner_resource_id        orid
             ,ibc_content_items.owner_resource_type      ort
             ,ibc_compound_relations.attribute_type_code atc
             ,ibc_citem_versions_tl.content_item_name    cin
             ,ibc_compound_relations.sort_order          sor
             ,ibc_compound_relations.subitem_version_id  svid
        FROM ibc_compound_relations
             ,ibc_content_items
             ,ibc_citem_versions_b b1
             ,ibc_citem_versions_tl
       WHERE b1.citem_version_id = ibc_citem_versions_tl.citem_version_id
         AND b1.content_item_id = ibc_content_items.content_item_id
         AND ibc_content_items.content_item_id = ibc_compound_relations.content_item_id
         AND b1.version_number = (SELECT MAX(b2.version_number)
                                    FROM ibc_citem_versions_b b2
                                   WHERE b1.content_item_id = b2.content_item_id
                                 )
         AND ibc_citem_versions_tl.LANGUAGE = p_language
         AND ibc_compound_relations.citem_version_id = p_citem_version_id
       ORDER BY ibc_compound_relations.sort_order;

    CURSOR c_renditions(p_citem_version_id NUMBER,
                        p_language         VARCHAR2)
    IS
      SELECT file_id, file_name, mime_type
        FROM ibc_renditions
       WHERE citem_version_id = p_citem_version_id
         AND LANGUAGE = p_language;

    CURSOR c_keywords(p_content_item_id NUMBER) IS
      SELECT keyword
        FROM ibc_citem_keywords
       WHERE content_item_id = p_content_item_id;

    CURSOR c_lob(p_file_id NUMBER) IS
      SELECT file_name, file_content_type
        FROM fnd_lobs
       WHERE file_id = p_file_id;

BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
         L_API_VERSION_NUMBER                                     --|**|
      ,p_api_version_number                                    --|**|
      ,L_API_NAME                                              --|**|
      ,G_PKG_NAME                                              --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Get_Trans_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_language', p_language,
                                          'p_skip_security', p_skip_security,
                                          'p_init_msg_list', p_init_msg_list,
                                          'p_api_version_number', p_api_version_number
                                        )
                           )
      );
    END IF;

    -- checking for valid inputs and throwing exception if invalid
     -- validating item information
    IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - CITEM_VER_ID');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_language IS NULL) THEN
        lang := USERENV('LANG');
    ELSE
        lang := p_language;
    END IF;

     -- validating language
    IF (IBC_VALIDATE_PVT.isValidLanguage(lang) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - LANGUAGE');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_language', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

-- getting most items from a view

    SELECT
        citem_id
        ,name
        ,version
        ,dir_node_id
        ,dir_node_name
        ,dir_node_code
        ,item_status
        ,version_status
        ,description
        ,ctype_code
        ,ctype_name
        ,start_date
        ,end_date
        ,owner
        ,owner_type
        ,ref_code
        ,trans_required
        ,parent_id
        ,locked_by
        ,wd_restricted
        ,attrib_fid
        ,attach_fid
        ,attach_file_name
        ,default_rendition_mime_type
        ,object_version_number
        ,created_by
        ,creation_date
        ,last_updated_by
        ,last_update_date
    INTO
        x_content_item_id
        ,x_citem_name
        ,x_citem_version
        ,x_dir_node_id
        ,x_dir_node_name
        ,x_dir_node_code
        ,x_item_status
        ,x_version_status
        ,x_citem_description
        ,x_ctype_code
        ,x_ctype_name
        ,x_start_date
        ,x_end_date
        ,x_owner_resource_id
        ,x_owner_resource_type
        ,x_reference_code
        ,x_trans_required
        ,x_parent_item_id
        ,x_locked_by
        ,x_wd_restricted
        ,attribute_fid
        ,x_attach_file_id
        ,x_attach_file_name
        ,l_default_rendition_mime_type
        ,x_object_version_number
        ,x_created_by
        ,x_creation_date
        ,x_last_updated_by
        ,x_last_update_date
    FROM
        IBC_CITEMS_V
    WHERE
        citem_ver_id = p_citem_ver_id
    AND
        LANGUAGE = lang;

    IF( NVL(p_skip_security, FND_API.g_false) = FND_API.g_false AND
        IBC_DATA_SECURITY_PVT.has_permission(                                                        --|*|
                p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                ,p_instance_pk1_value    => x_content_item_id                                        --|*|
                ,p_permission_code       => 'CITEM_READ'                                             --|*|
                ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                ,p_container_pk1_value   => x_dir_node_id                                            --|*|
                ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                ) = FND_API.g_false                                                                  --|*|
       ) THEN IF                                                                                     --|*|

  IBC_DATA_SECURITY_PVT.has_permission(
    p_instance_object_id  => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')
    ,p_instance_pk1_value    => x_content_item_id
    ,p_permission_code      => 'CITEM_EDIT'
    ,p_container_object_id  =>
    IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE'),
    p_container_pk1_value  => x_dir_node_id,
    p_current_user_id      => FND_GLOBAL.user_id ) = FND_API.g_false  THEN

          --DBMS_OUTPUT.put_line('EX - no permissions');                                       --|*|
          x_return_status := FND_API.G_RET_STS_ERROR;                                          --|*|
          FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                              --|*|
          FND_MSG_PUB.ADD;                                                                     --|*|
          RAISE FND_API.G_EXC_ERROR;                                                           --|*|
        END IF;                                                                                      --|*|
    END IF;                                                                                          --|*|


    IF(attribute_fid IS NOT NULL) THEN
        --getting attribute bundle
        get_attribute_bundle_int(
             p_attrib_fid             => attribute_fid
            ,p_language              => lang -- p_language Bug Fix: 3848499
            ,p_ctype_code            => x_ctype_code
            ,x_attribute_type_codes  => x_attribute_type_codes
            ,x_attribute_type_names  => x_attribute_type_names
            ,x_attributes            => x_attributes
            ,x_return_status       => return_status
        );
        -- checking to see if there was an error
        IF(return_status = FND_API.G_RET_STS_ERROR) THEN
            --DBMS_OUTPUT.put_line('EX - get_attribute_bundle_int');
            x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_ERROR');
            FND_MESSAGE.Set_Token('SITUATION', 'get_attribute_bundle_int', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- Attachment Information
    OPEN c_lob(x_attach_file_id);
    FETCH c_lob INTO x_attach_file_name, x_attach_mime_type;
    CLOSE c_lob;
    x_attach_mime_type := GET_MIME_TYPE(x_attach_mime_type);

    OPEN c_Rendition_Name(x_attach_mime_type, lang);
    FETCH c_Rendition_Name INTO x_attach_mime_name;
    IF c_Rendition_Name%NOTFOUND THEN
      CLOSE c_Rendition_Name;
      OPEN c_Rendition_Name(IBC_UTILITIES_PVT.G_REND_UNKNOWN_MIME, lang);
      FETCH c_Rendition_Name INTO x_attach_mime_name;
    END IF;
    CLOSE c_Rendition_Name;


    -- Loading renditions information
    FOR r_rendition IN c_renditions(p_citem_ver_id, lang) LOOP
      l_index := c_renditions%ROWCOUNT;
      -- Allocate
      IF l_index = 1 THEN
        x_rendition_file_ids   := JTF_NUMBER_TABLE();
        x_rendition_file_names := JTF_VARCHAR2_TABLE_300();
        x_rendition_mime_types := JTF_VARCHAR2_TABLE_100();
        x_rendition_mime_names := JTF_VARCHAR2_TABLE_100();
      END IF;

      -- Extend
      x_rendition_file_ids.extend;
      x_rendition_file_names.extend;
      x_rendition_mime_types.extend;
      x_rendition_mime_names.extend;

      -- Assign
      x_rendition_file_ids(l_index)   := r_rendition.file_id;
      x_rendition_file_names(l_index) := r_rendition.file_name;
      x_rendition_mime_types(l_index) := r_rendition.mime_type;

      OPEN c_Rendition_Name(r_rendition.mime_type, lang);
      FETCH c_Rendition_Name INTO x_rendition_mime_names(l_index);
      IF c_Rendition_Name%NOTFOUND THEN
        CLOSE c_Rendition_Name;
        OPEN c_Rendition_Name(IBC_UTILITIES_PVT.G_REND_UNKNOWN_MIME, lang);
        FETCH c_Rendition_Name INTO x_rendition_mime_names(l_index);
      END IF;
      CLOSE c_Rendition_Name;

      -- Default Rendition logic  -- it now should be based on MIME_TYPE
      IF r_rendition.mime_type = l_default_rendition_mime_type THEN
        x_default_rendition := l_index;
      END IF;

    END LOOP;

    -- If not default rendition defaulting it to first in the list
    IF x_default_rendition IS NULL AND x_rendition_file_ids IS NOT NULL
    THEN
      x_default_rendition := 1;
    END IF;



    -- Loading component information
    FOR r_component IN c_components(p_citem_ver_id, lang) LOOP
      l_index := c_components%ROWCOUNT;
      -- Allocate
      IF l_index = 1 THEN
        x_component_citems       := JTF_NUMBER_TABLE();
        x_component_citem_ver_ids := JTF_NUMBER_TABLE();
        x_component_attrib_types := JTF_VARCHAR2_TABLE_100();
        x_component_citem_names  := JTF_VARCHAR2_TABLE_300();
        x_component_sort_orders  := JTF_NUMBER_TABLE();
        x_component_owner_ids    := JTF_NUMBER_TABLE();
        x_component_owner_types  := JTF_VARCHAR2_TABLE_100();
      END IF;

      -- Extend
      x_component_citems.extend;
      x_component_citem_ver_ids.extend;
      x_component_owner_ids.extend;
      x_component_owner_types.extend;
      x_component_attrib_types.extend;
      x_component_citem_names.extend;
      x_component_sort_orders.extend;

      -- Assign
      x_component_citems(l_index)       := r_component.ciid;
      x_component_citem_ver_ids(l_index) := r_component.svid;
      x_component_owner_ids(l_index)    := r_component.orid;
      x_component_owner_types(l_index)  := r_component.ort;
      x_component_attrib_types(l_index) := r_component.atc;
      x_component_citem_names(l_index)  := r_component.cin;
      x_component_sort_orders(l_index)  := r_component.sor;

    END LOOP;

    -- Keywords loading
    FOR r_keyword IN c_keywords(x_content_item_id) LOOP
      l_index := c_keywords%ROWCOUNT;
      IF l_index = 1 THEN
        x_keywords := JTF_VARCHAR2_TABLE_100();
      END IF;
      x_keywords.extend;
      x_keywords(l_index) := r_keyword.keyword;
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_32767(
                        'x_content_item_id', x_content_item_id,
                        'x_citem_name', x_citem_name,
                        'x_citem_version', x_citem_version,
                        'x_dir_node_id', x_dir_node_id,
                        'x_dir_node_name', x_dir_node_name,
                        'x_dir_node_code', x_dir_node_code,
                        'x_item_status', x_item_status,
                        'x_version_status', x_version_status,
                        'x_citem_description', x_citem_description,
                        'x_ctype_code', x_ctype_code,
                        'x_ctype_name', x_ctype_name,
                        'x_start_date', TO_CHAR(x_start_date, 'YYYYMMDD HH24:MI:SS'),
                        'x_end_date', TO_CHAR(x_end_date, 'YYYYMMDD HH24:MI:SS'),
                        'x_owner_resource_id', x_owner_resource_id,
                        'x_owner_resource_type', x_owner_resource_type,
                        'x_reference_code', x_reference_code,
                        'x_trans_required', x_trans_required,
                        'x_parent_item_id', x_parent_item_id,
                        'x_locked_by', x_locked_by,
                        'x_wd_restricted', x_wd_restricted,
                        'x_attach_file_id', x_attach_file_id,
                        'x_attach_file_name', x_attach_file_name,
                        'x_attach_mime_type', x_attach_mime_type,
                        'x_attach_mime_name', x_attach_mime_name,
                        'x_rendition_file_ids', IBC_DEBUG_PVT.make_list(x_rendition_file_ids),
                        'x_rendition_file_names', IBC_DEBUG_PVT.make_list(x_rendition_file_names),
                        'x_rendition_mime_types', IBC_DEBUG_PVT.make_list(x_rendition_mime_types),
                        'x_rendition_mime_names', IBC_DEBUG_PVT.make_list(x_rendition_mime_names),
                        'x_default_rendition', x_default_rendition,
                        'x_object_version_number', x_object_version_number,
                        'x_created_by', x_created_by,
                        'x_creation_date', TO_CHAR(x_creation_date, 'YYYYMMDD HH24:MI:SS'),
                        'x_last_updated_by', x_last_updated_by,
                        'x_attribute_type_codes', IBC_DEBUG_PVT.make_list(x_attribute_type_codes),
                        'x_attribute_type_names', IBC_DEBUG_PVT.make_list(x_attribute_type_names),
                        'x_attributes', IBC_DEBUG_PVT.make_list_VC32767(x_attributes),
                        'x_component_citems', IBC_DEBUG_PVT.make_list(x_component_citems),
                        'x_component_citem_ver_ids', IBC_DEBUG_PVT.make_list(x_component_citem_ver_ids),
                        'x_component_attrib_types', IBC_DEBUG_PVT.make_list(x_component_attrib_types),
                        'x_component_citem_names', IBC_DEBUG_PVT.make_list(x_component_citem_names),
                        'x_component_owner_ids', IBC_DEBUG_PVT.make_list(x_component_owner_ids),
                        'x_component_owner_types', IBC_DEBUG_PVT.make_list(x_component_owner_types),
                        'x_component_sort_orders', IBC_DEBUG_PVT.make_list(x_component_sort_orders),
                        'x_keywords', IBC_DEBUG_PVT.make_list(x_keywords),
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END get_trans_item;

-- Overloaded to support the addition of skip_security
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
BEGIN
  get_trans_item(
    p_citem_ver_id            => p_citem_ver_id
    ,p_language               => p_language
    ,p_init_msg_list          => p_init_msg_list
    ,p_skip_security          => FND_API.g_false
    ,p_api_version_number     => p_api_version_number
    ,x_content_item_id        => x_content_item_id
    ,x_citem_name             => x_citem_name
    ,x_citem_version          => x_citem_version
    ,x_dir_node_id            => x_dir_node_id
    ,x_dir_node_name          => x_dir_node_name
    ,x_dir_node_code          => x_dir_node_code
    ,x_item_status            => x_item_status
    ,x_version_status         => x_version_status
    ,x_citem_description      => x_citem_description
    ,x_ctype_code             => x_ctype_code
    ,x_ctype_name             => x_ctype_name
    ,x_start_date             => x_start_date
    ,x_end_date               => x_end_date
    ,x_owner_resource_id      => x_owner_resource_id
    ,x_owner_resource_type    => x_owner_resource_type
    ,x_reference_code         => x_reference_code
    ,x_trans_required         => x_trans_required
    ,x_parent_item_id         => x_parent_item_id
    ,x_locked_by              => x_locked_by
    ,x_wd_restricted          => x_wd_restricted
    ,x_attach_file_id         => x_attach_file_id
    ,x_attach_file_name       => x_attach_file_name
    ,x_attach_mime_type       => x_attach_mime_type
    ,x_attach_mime_name       => x_attach_mime_name
    ,x_rendition_file_ids     => x_rendition_file_ids
    ,x_rendition_file_names   => x_rendition_file_names
    ,x_rendition_mime_types   => x_rendition_mime_types
    ,x_rendition_mime_names   => x_rendition_mime_names
    ,x_default_rendition      => x_default_rendition
    ,x_object_version_number  => x_object_version_number
    ,x_created_by             => x_created_by
    ,x_creation_date          => x_creation_date
    ,x_last_updated_by        => x_last_updated_by
    ,x_last_update_date       => x_last_update_date
    ,x_attribute_type_codes   => x_attribute_type_codes
    ,x_attribute_type_names   => x_attribute_type_names
    ,x_attributes             => x_attributes
    ,x_component_citems       => x_component_citems
    ,x_component_citem_ver_ids => x_component_citem_ver_ids
    ,x_component_attrib_types => x_component_attrib_types
    ,x_component_citem_names  => x_component_citem_names
    ,x_component_owner_ids    => x_component_owner_ids
    ,x_component_owner_types  => x_component_owner_types
    ,x_component_sort_orders  => x_component_sort_orders
    ,x_keywords               => x_keywords
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );

-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_trans_item;

-- Overloaded to support old 4K limit for attribute values
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_tmp_attributes    JTF_VARCHAR2_TABLE_32767;
BEGIN
  get_trans_item(
    p_citem_ver_id            => p_citem_ver_id
    ,p_language               => p_language
    ,p_init_msg_list          => p_init_msg_list
    ,p_api_version_number     => p_api_version_number
    ,x_content_item_id        => x_content_item_id
    ,x_citem_name             => x_citem_name
    ,x_citem_version          => x_citem_version
    ,x_dir_node_id            => x_dir_node_id
    ,x_dir_node_name          => x_dir_node_name
    ,x_dir_node_code          => x_dir_node_code
    ,x_item_status            => x_item_status
    ,x_version_status         => x_version_status
    ,x_citem_description      => x_citem_description
    ,x_ctype_code             => x_ctype_code
    ,x_ctype_name             => x_ctype_name
    ,x_start_date             => x_start_date
    ,x_end_date               => x_end_date
    ,x_owner_resource_id      => x_owner_resource_id
    ,x_owner_resource_type    => x_owner_resource_type
    ,x_reference_code         => x_reference_code
    ,x_trans_required         => x_trans_required
    ,x_parent_item_id         => x_parent_item_id
    ,x_locked_by              => x_locked_by
    ,x_wd_restricted          => x_wd_restricted
    ,x_attach_file_id         => x_attach_file_id
    ,x_attach_file_name       => x_attach_file_name
    ,x_attach_mime_type       => x_attach_mime_type
    ,x_attach_mime_name       => x_attach_mime_name
    ,x_rendition_file_ids     => x_rendition_file_ids
    ,x_rendition_file_names   => x_rendition_file_names
    ,x_rendition_mime_types   => x_rendition_mime_types
    ,x_rendition_mime_names   => x_rendition_mime_names
    ,x_default_rendition      => x_default_rendition
    ,x_object_version_number  => x_object_version_number
    ,x_created_by             => x_created_by
    ,x_creation_date          => x_creation_date
    ,x_last_updated_by        => x_last_updated_by
    ,x_last_update_date       => x_last_update_date
    ,x_attribute_type_codes   => x_attribute_type_codes
    ,x_attribute_type_names   => x_attribute_type_names
    ,x_attributes             => l_tmp_attributes
    ,x_component_citems       => x_component_citems
    ,x_component_citem_ver_ids => x_component_citem_ver_ids
    ,x_component_attrib_types => x_component_attrib_types
    ,x_component_citem_names  => x_component_citem_names
    ,x_component_owner_ids    => x_component_owner_ids
    ,x_component_owner_types  => x_component_owner_types
    ,x_component_sort_orders  => x_component_sort_orders
    ,x_keywords               => x_keywords
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );

  IF l_tmp_attributes IS NOT NULL AND l_tmp_attributes.COUNT > 0 THEN
    x_attributes := JTF_VARCHAR2_TABLE_4000();
    x_attributes.extend(l_tmp_attributes.COUNT);
    FOR I IN 1..l_tmp_attributes.COUNT LOOP
      x_attributes(I) := l_tmp_attributes(I);
    END LOOP;
  END IF;

-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get_trans_item;


-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- Used to get info to display on update page
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_attach_file_id   NUMBER;
  l_attach_file_name VARCHAR2(240);
  l_attach_mime_type VARCHAR2(80);
  l_attach_mime_name VARCHAR2(80);

  l_norend_file_ids   JTF_NUMBER_TABLE;
  l_norend_file_names JTF_VARCHAR2_TABLE_300;
  l_norend_mime_types JTF_VARCHAR2_TABLE_100;
  l_norend_mime_names JTF_VARCHAR2_TABLE_100;
BEGIN
  get_trans_item(
    p_citem_ver_id            => p_citem_ver_id
    ,p_language               => p_language
    ,p_init_msg_list          => p_init_msg_list
    ,p_api_version_number     => p_api_version_number
    ,x_content_item_id        => x_content_item_id
    ,x_citem_name             => x_citem_name
    ,x_citem_version          => x_citem_version
    ,x_dir_node_id            => x_dir_node_id
    ,x_dir_node_name          => x_dir_node_name
    ,x_dir_node_code          => x_dir_node_code
    ,x_item_status            => x_item_status
    ,x_version_status         => x_version_status
    ,x_citem_description      => x_citem_description
    ,x_ctype_code             => x_ctype_code
    ,x_ctype_name             => x_ctype_name
    ,x_start_date             => x_start_date
    ,x_end_date               => x_end_date
    ,x_owner_resource_id      => x_owner_resource_id
    ,x_owner_resource_type    => x_owner_resource_type
    ,x_reference_code         => x_reference_code
    ,x_trans_required         => x_trans_required
    ,x_parent_item_id         => x_parent_item_id
    ,x_locked_by              => x_locked_by
    ,x_wd_restricted          => x_wd_restricted
    ,x_attach_file_id         => l_attach_file_id
    ,x_attach_file_name       => l_attach_file_name
    ,x_attach_mime_type       => l_attach_mime_type
    ,x_attach_mime_name       => l_attach_mime_name
    ,x_rendition_file_ids     => l_norend_file_ids
    ,x_rendition_file_names   => l_norend_file_names
    ,x_rendition_mime_types   => l_norend_mime_types
    ,x_rendition_mime_names   => l_norend_mime_names
    ,x_default_rendition      => x_default_rendition
    ,x_object_version_number  => x_object_version_number
    ,x_created_by             => x_created_by
    ,x_creation_date          => x_creation_date
    ,x_last_updated_by        => x_last_updated_by
    ,x_last_update_date       => x_last_update_date
    ,x_attribute_type_codes   => x_attribute_type_codes
    ,x_attribute_type_names   => x_attribute_type_names
    ,x_attributes             => x_attributes
    ,x_component_citems       => x_component_citems
    ,x_component_citem_ver_ids => x_component_citem_ver_ids
    ,x_component_attrib_types => x_component_attrib_types
    ,x_component_citem_names  => x_component_citem_names
    ,x_component_owner_ids    => x_component_owner_ids
    ,x_component_owner_types  => x_component_owner_types
    ,x_component_sort_orders  => x_component_sort_orders
    ,x_keywords               => x_keywords
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );

  IF l_attach_file_id IS NOT NULL THEN
    x_attach_file_ids   := JTF_NUMBER_TABLE();
    x_attach_file_names := JTF_VARCHAR2_TABLE_300();
    x_attach_mime_types := JTF_VARCHAR2_TABLE_100();
    x_attach_mime_names := JTF_VARCHAR2_TABLE_100();

    x_attach_file_ids.extend();
    x_attach_file_names.extend();
    x_attach_mime_types.extend();
    x_attach_mime_names.extend();

    x_attach_file_ids(1)   := l_attach_file_id;
    x_attach_file_names(1) := l_attach_file_name;
    x_attach_mime_types(1) := l_attach_mime_type;
    x_attach_mime_names(1) := l_attach_mime_name;
  END IF;

-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_trans_item;

PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_component_citem_ver_ids JTF_NUMBER_TABLE;
BEGIN

  get_trans_item(
    p_citem_ver_id            => p_citem_ver_id
    ,p_language               => p_language
    ,p_init_msg_list          => p_init_msg_list
    ,p_api_version_number     => p_api_version_number
    ,x_content_item_id        => x_content_item_id
    ,x_citem_name             => x_citem_name
    ,x_citem_version          => x_citem_version
    ,x_dir_node_id            => x_dir_node_id
    ,x_dir_node_name          => x_dir_node_name
    ,x_dir_node_code          => x_dir_node_code
    ,x_item_status            => x_item_status
    ,x_version_status         => x_version_status
    ,x_citem_description      => x_citem_description
    ,x_ctype_code             => x_ctype_code
    ,x_ctype_name             => x_ctype_name
    ,x_start_date             => x_start_date
    ,x_end_date               => x_end_date
    ,x_owner_resource_id      => x_owner_resource_id
    ,x_owner_resource_type    => x_owner_resource_type
    ,x_reference_code         => x_reference_code
    ,x_trans_required         => x_trans_required
    ,x_parent_item_id         => x_parent_item_id
    ,x_locked_by              => x_locked_by
    ,x_wd_restricted          => x_wd_restricted
    ,x_attach_file_ids        => x_attach_file_ids
    ,x_attach_file_names      => x_attach_file_names
    ,x_attach_mime_types      => x_attach_mime_types
    ,x_attach_mime_names      => x_attach_mime_names
    ,x_default_rendition      => x_default_rendition
    ,x_object_version_number  => x_object_version_number
    ,x_created_by             => x_created_by
    ,x_creation_date          => x_creation_date
    ,x_last_updated_by        => x_last_updated_by
    ,x_last_update_date       => x_last_update_date
    ,x_attribute_type_codes   => x_attribute_type_codes
    ,x_attribute_type_names   => x_attribute_type_names
    ,x_attributes             => x_attributes
    ,x_component_citems       => x_component_citems
    ,x_component_citem_ver_ids => l_component_citem_ver_ids
    ,x_component_attrib_types => x_component_attrib_types
    ,x_component_citem_names  => x_component_citem_names
    ,x_component_owner_ids    => x_component_owner_ids
    ,x_component_owner_types  => x_component_owner_types
    ,x_component_sort_orders  => x_component_sort_orders
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Get_Trans_Item;

PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_keywords JTF_VARCHAR2_TABLE_100;
BEGIN

  get_trans_item(
    p_citem_ver_id            => p_citem_ver_id
    ,p_language               => p_language
    ,p_init_msg_list          => p_init_msg_list
    ,p_api_version_number     => p_api_version_number
    ,x_content_item_id        => x_content_item_id
    ,x_citem_name             => x_citem_name
    ,x_citem_version          => x_citem_version
    ,x_dir_node_id            => x_dir_node_id
    ,x_dir_node_name          => x_dir_node_name
    ,x_dir_node_code          => x_dir_node_code
    ,x_item_status            => x_item_status
    ,x_version_status         => x_version_status
    ,x_citem_description      => x_citem_description
    ,x_ctype_code             => x_ctype_code
    ,x_ctype_name             => x_ctype_name
    ,x_start_date             => x_start_date
    ,x_end_date               => x_end_date
    ,x_owner_resource_id      => x_owner_resource_id
    ,x_owner_resource_type    => x_owner_resource_type
    ,x_reference_code         => x_reference_code
    ,x_trans_required         => x_trans_required
    ,x_parent_item_id         => x_parent_item_id
    ,x_locked_by              => x_locked_by
    ,x_wd_restricted          => x_wd_restricted
    ,x_attach_file_ids        => x_attach_file_ids
    ,x_attach_file_names      => x_attach_file_names
    ,x_attach_mime_types      => x_attach_mime_types
    ,x_attach_mime_names      => x_attach_mime_names
    ,x_default_rendition      => x_default_rendition
    ,x_object_version_number  => x_object_version_number
    ,x_created_by             => x_created_by
    ,x_creation_date          => x_creation_date
    ,x_last_updated_by        => x_last_updated_by
    ,x_last_update_date       => x_last_update_date
    ,x_attribute_type_codes   => x_attribute_type_codes
    ,x_attribute_type_names   => x_attribute_type_names
    ,x_attributes             => x_attributes
    ,x_component_citems       => x_component_citems
    ,x_component_citem_ver_ids => x_component_citem_ver_ids
    ,x_component_attrib_types => x_component_attrib_types
    ,x_component_citem_names  => x_component_citem_names
    ,x_component_owner_ids    => x_component_owner_ids
    ,x_component_owner_types  => x_component_owner_types
    ,x_component_sort_orders  => x_component_sort_orders
    ,x_keywords               => l_keywords
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Get_Trans_Item;

-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- Used to get info to display on update page
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_attach_file_ids        JTF_NUMBER_TABLE;
  l_attach_file_names      JTF_VARCHAR2_TABLE_300;
  l_attach_mime_types      JTF_VARCHAR2_TABLE_100;
  l_attach_mime_names      JTF_VARCHAR2_TABLE_100;
  l_default_rendition      NUMBER;
BEGIN
   get_trans_item(
       p_citem_ver_id            => p_citem_ver_id
       ,p_language               => p_language           -- Changed on Nov-22 during tests with Mona.
       ,p_init_msg_list          => p_init_msg_list
       ,p_api_version_number     => p_api_version_number
       ,x_content_item_id        => x_content_item_id
       ,x_citem_name             =>x_citem_name
       ,x_citem_version          =>x_citem_version
       ,x_dir_node_id            =>x_dir_node_id
       ,x_dir_node_name          =>x_dir_node_name
       ,x_dir_node_code          =>x_dir_node_code
       ,x_item_status            =>x_item_status
       ,x_version_status         =>x_version_status
       ,x_citem_description      =>x_citem_description
       ,x_ctype_code             =>x_ctype_code
       ,x_ctype_name             =>x_ctype_name
       ,x_start_date             =>x_start_date
       ,x_end_date               =>x_end_date
       ,x_owner_resource_id      =>x_owner_resource_id
       ,x_owner_resource_type    =>x_owner_resource_type
       ,x_reference_code         =>x_reference_code
       ,x_trans_required         =>x_trans_required
       ,x_parent_item_id         =>x_parent_item_id
       ,x_locked_by              =>x_locked_by
       ,x_wd_restricted          =>x_wd_restricted
       ,x_attach_file_ids        =>l_attach_file_ids
       ,x_attach_file_names      =>l_attach_file_names
       ,x_attach_mime_types      =>l_attach_mime_types
       ,x_attach_mime_names      =>l_attach_mime_names
       ,x_default_rendition      =>l_default_rendition
       ,x_object_version_number  =>x_object_version_number
       ,x_created_by             =>x_created_by
       ,x_creation_date          =>x_creation_date
       ,x_last_updated_by        =>x_last_updated_by
       ,x_last_update_date       =>x_last_update_date
       ,x_attribute_type_codes   =>x_attribute_type_codes
       ,x_attribute_type_names   =>x_attribute_type_names
       ,x_attributes             =>x_attributes
       ,x_component_citems       =>x_component_citems
       ,x_component_attrib_types =>x_component_attrib_types
       ,x_component_citem_names  =>x_component_citem_names
       ,x_component_owner_ids    =>x_component_owner_ids
       ,x_component_owner_types  =>x_component_owner_types
       ,x_component_sort_orders  =>x_component_sort_orders
       ,x_return_status          =>x_return_status
       ,x_msg_count              =>x_msg_count
       ,x_msg_data               =>x_msg_data
   );
   IF l_attach_file_ids IS NOT NULL THEN
     x_attach_file_id   := l_attach_file_ids(l_default_rendition);
     x_attach_file_name := l_attach_file_names(l_default_rendition);
   END IF;
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_trans_item;

-- --------------------------------------------------------------
-- GET CONTENT ITEM (FOR UPDATE)
--
-- Used to get info to display on update page
--
-- --------------------------------------------------------------
PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- get_item -----');
   get_trans_item(
       p_citem_ver_id            => p_citem_ver_id
       ,p_language               => NULL
       ,p_init_msg_list          => p_init_msg_list
       ,p_api_version_number     => p_api_version_number
       ,x_content_item_id        => x_content_item_id
       ,x_citem_name             =>x_citem_name
       ,x_citem_version          =>x_citem_version
       ,x_dir_node_id            =>x_dir_node_id
       ,x_dir_node_name          =>x_dir_node_name
       ,x_dir_node_code          =>x_dir_node_code
       ,x_item_status            =>x_item_status
       ,x_version_status         =>x_version_status
       ,x_citem_description      =>x_citem_description
       ,x_ctype_code             =>x_ctype_code
       ,x_ctype_name             =>x_ctype_name
       ,x_start_date             =>x_start_date
       ,x_end_date               =>x_end_date
       ,x_owner_resource_id      =>x_owner_resource_id
       ,x_owner_resource_type    =>x_owner_resource_type
       ,x_reference_code         =>x_reference_code
       ,x_trans_required         =>x_trans_required
       ,x_parent_item_id         =>x_parent_item_id
       ,x_locked_by              =>x_locked_by
       ,x_wd_restricted          =>x_wd_restricted
       ,x_attach_file_id         =>x_attach_file_id
       ,x_attach_file_name       =>x_attach_file_name
       ,x_object_version_number  =>x_object_version_number
       ,x_created_by             =>x_created_by
       ,x_creation_date          =>x_creation_date
       ,x_last_updated_by        =>x_last_updated_by
       ,x_last_update_date       =>x_last_update_date
       ,x_attribute_type_codes   =>x_attribute_type_codes
       ,x_attribute_type_names   =>x_attribute_type_names
       ,x_attributes             =>x_attributes
       ,x_component_citems       =>x_component_citems
       ,x_component_attrib_types =>x_component_attrib_types
       ,x_component_citem_names  =>x_component_citem_names
       ,x_component_owner_ids    =>x_component_owner_ids
       ,x_component_owner_types  =>x_component_owner_types
       ,x_component_sort_orders  =>x_component_sort_orders
       ,x_return_status          =>x_return_status
       ,x_msg_count              =>x_msg_count
       ,x_msg_data               =>x_msg_data
   );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_item;

PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- get_item -----');
   get_trans_item(
       p_citem_ver_id            => p_citem_ver_id
       ,p_language               => NULL
       ,p_init_msg_list          => p_init_msg_list
       ,p_api_version_number     => p_api_version_number
       ,x_content_item_id        => x_content_item_id
       ,x_citem_name             =>x_citem_name
       ,x_citem_version          =>x_citem_version
       ,x_dir_node_id            =>x_dir_node_id
       ,x_dir_node_name          =>x_dir_node_name
       ,x_dir_node_code          =>x_dir_node_code
       ,x_item_status            =>x_item_status
       ,x_version_status         =>x_version_status
       ,x_citem_description      =>x_citem_description
       ,x_ctype_code             =>x_ctype_code
       ,x_ctype_name             =>x_ctype_name
       ,x_start_date             =>x_start_date
       ,x_end_date               =>x_end_date
       ,x_owner_resource_id      =>x_owner_resource_id
       ,x_owner_resource_type    =>x_owner_resource_type
       ,x_reference_code         =>x_reference_code
       ,x_trans_required         =>x_trans_required
       ,x_parent_item_id         =>x_parent_item_id
       ,x_locked_by              =>x_locked_by
       ,x_wd_restricted          =>x_wd_restricted
       ,x_attach_file_ids        =>x_attach_file_ids
       ,x_attach_file_names      =>x_attach_file_names
       ,x_attach_mime_types      =>x_attach_mime_types
       ,x_attach_mime_names      =>x_attach_mime_names
       ,x_default_rendition      =>x_default_rendition
       ,x_object_version_number  =>x_object_version_number
       ,x_created_by             =>x_created_by
       ,x_creation_date          =>x_creation_date
       ,x_last_updated_by        =>x_last_updated_by
       ,x_last_update_date       =>x_last_update_date
       ,x_attribute_type_codes   =>x_attribute_type_codes
       ,x_attribute_type_names   =>x_attribute_type_names
       ,x_attributes             =>x_attributes
       ,x_component_citems       =>x_component_citems
       ,x_component_attrib_types =>x_component_attrib_types
       ,x_component_citem_names  =>x_component_citem_names
       ,x_component_owner_ids    =>x_component_owner_ids
       ,x_component_owner_types  =>x_component_owner_types
       ,x_component_sort_orders  =>x_component_sort_orders
       ,x_return_status          =>x_return_status
       ,x_msg_count              =>x_msg_count
       ,x_msg_data               =>x_msg_data
   );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_item;

PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- get_item -----');
   get_trans_item(
       p_citem_ver_id            => p_citem_ver_id
       ,p_language               => NULL
       ,p_init_msg_list          => p_init_msg_list
       ,p_api_version_number     => p_api_version_number
       ,x_content_item_id        => x_content_item_id
       ,x_citem_name             =>x_citem_name
       ,x_citem_version          =>x_citem_version
       ,x_dir_node_id            =>x_dir_node_id
       ,x_dir_node_name          =>x_dir_node_name
       ,x_dir_node_code          =>x_dir_node_code
       ,x_item_status            =>x_item_status
       ,x_version_status         =>x_version_status
       ,x_citem_description      =>x_citem_description
       ,x_ctype_code             =>x_ctype_code
       ,x_ctype_name             =>x_ctype_name
       ,x_start_date             =>x_start_date
       ,x_end_date               =>x_end_date
       ,x_owner_resource_id      =>x_owner_resource_id
       ,x_owner_resource_type    =>x_owner_resource_type
       ,x_reference_code         =>x_reference_code
       ,x_trans_required         =>x_trans_required
       ,x_parent_item_id         =>x_parent_item_id
       ,x_locked_by              =>x_locked_by
       ,x_wd_restricted          =>x_wd_restricted
       ,x_attach_file_ids        =>x_attach_file_ids
       ,x_attach_file_names      =>x_attach_file_names
       ,x_attach_mime_types      =>x_attach_mime_types
       ,x_attach_mime_names      =>x_attach_mime_names
       ,x_default_rendition      =>x_default_rendition
       ,x_object_version_number  =>x_object_version_number
       ,x_created_by             =>x_created_by
       ,x_creation_date          =>x_creation_date
       ,x_last_updated_by        =>x_last_updated_by
       ,x_last_update_date       =>x_last_update_date
       ,x_attribute_type_codes   =>x_attribute_type_codes
       ,x_attribute_type_names   =>x_attribute_type_names
       ,x_attributes             =>x_attributes
       ,x_component_citems       =>x_component_citems
       ,x_component_citem_ver_ids => x_component_citem_ver_ids
       ,x_component_attrib_types =>x_component_attrib_types
       ,x_component_citem_names  =>x_component_citem_names
       ,x_component_owner_ids    =>x_component_owner_ids
       ,x_component_owner_types  =>x_component_owner_types
       ,x_component_sort_orders  =>x_component_sort_orders
       ,x_return_status          =>x_return_status
       ,x_msg_count              =>x_msg_count
       ,x_msg_data               =>x_msg_data
   );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_item;

PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- get_item -----');
   get_trans_item(
       p_citem_ver_id            => p_citem_ver_id
       ,p_language               => NULL
       ,p_init_msg_list          => p_init_msg_list
       ,p_api_version_number     => p_api_version_number
       ,x_content_item_id        => x_content_item_id
       ,x_citem_name             =>x_citem_name
       ,x_citem_version          =>x_citem_version
       ,x_dir_node_id            =>x_dir_node_id
       ,x_dir_node_name          =>x_dir_node_name
       ,x_dir_node_code          =>x_dir_node_code
       ,x_item_status            =>x_item_status
       ,x_version_status         =>x_version_status
       ,x_citem_description      =>x_citem_description
       ,x_ctype_code             =>x_ctype_code
       ,x_ctype_name             =>x_ctype_name
       ,x_start_date             =>x_start_date
       ,x_end_date               =>x_end_date
       ,x_owner_resource_id      =>x_owner_resource_id
       ,x_owner_resource_type    =>x_owner_resource_type
       ,x_reference_code         =>x_reference_code
       ,x_trans_required         =>x_trans_required
       ,x_parent_item_id         =>x_parent_item_id
       ,x_locked_by              =>x_locked_by
       ,x_wd_restricted          =>x_wd_restricted
       ,x_attach_file_ids        =>x_attach_file_ids
       ,x_attach_file_names      =>x_attach_file_names
       ,x_attach_mime_types      =>x_attach_mime_types
       ,x_attach_mime_names      =>x_attach_mime_names
       ,x_default_rendition      =>x_default_rendition
       ,x_object_version_number  =>x_object_version_number
       ,x_created_by             =>x_created_by
       ,x_creation_date          =>x_creation_date
       ,x_last_updated_by        =>x_last_updated_by
       ,x_last_update_date       =>x_last_update_date
       ,x_attribute_type_codes   =>x_attribute_type_codes
       ,x_attribute_type_names   =>x_attribute_type_names
       ,x_attributes             =>x_attributes
       ,x_component_citems       =>x_component_citems
       ,x_component_citem_ver_ids => x_component_citem_ver_ids
       ,x_component_attrib_types =>x_component_attrib_types
       ,x_component_citem_names  =>x_component_citem_names
       ,x_component_owner_ids    =>x_component_owner_ids
       ,x_component_owner_types  =>x_component_owner_types
       ,x_component_sort_orders  =>x_component_sort_orders
       ,x_keywords               => x_keywords
       ,x_return_status          =>x_return_status
       ,x_msg_count              =>x_msg_count
       ,x_msg_data               =>x_msg_data
   );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_item;


PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
) IS
BEGIN
  get_trans_item(
    p_citem_ver_id            => p_citem_ver_id
    ,p_language               => NULL
    ,p_init_msg_list          => p_init_msg_list
    ,p_api_version_number     => p_api_version_number
    ,x_content_item_id        => x_content_item_id
    ,x_citem_name             => x_citem_name
    ,x_citem_version          => x_citem_version
    ,x_dir_node_id            => x_dir_node_id
    ,x_dir_node_name          => x_dir_node_name
    ,x_dir_node_code          => x_dir_node_code
    ,x_item_status            => x_item_status
    ,x_version_status         => x_version_status
    ,x_citem_description      => x_citem_description
    ,x_ctype_code             => x_ctype_code
    ,x_ctype_name             => x_ctype_name
    ,x_start_date             => x_start_date
    ,x_end_date               => x_end_date
    ,x_owner_resource_id      => x_owner_resource_id
    ,x_owner_resource_type    => x_owner_resource_type
    ,x_reference_code         => x_reference_code
    ,x_trans_required         => x_trans_required
    ,x_parent_item_id         => x_parent_item_id
    ,x_locked_by              => x_locked_by
    ,x_wd_restricted          => x_wd_restricted
    ,x_attach_file_id         => x_attach_file_id
    ,x_attach_file_name       => x_attach_file_name
    ,x_attach_mime_type       => x_attach_mime_type
    ,x_attach_mime_name       => x_attach_mime_name
    ,x_rendition_file_ids     => x_rendition_file_ids
    ,x_rendition_file_names   => x_rendition_file_names
    ,x_rendition_mime_types   => x_rendition_mime_types
    ,x_rendition_mime_names   => x_rendition_mime_names
    ,x_default_rendition      => x_default_rendition
    ,x_object_version_number  => x_object_version_number
    ,x_created_by             => x_created_by
    ,x_creation_date          => x_creation_date
    ,x_last_updated_by        => x_last_updated_by
    ,x_last_update_date       => x_last_update_date
    ,x_attribute_type_codes   => x_attribute_type_codes
    ,x_attribute_type_names   => x_attribute_type_names
    ,x_attributes             => x_attributes
    ,x_component_citems       => x_component_citems
    ,x_component_citem_ver_ids => x_component_citem_ver_ids
    ,x_component_attrib_types => x_component_attrib_types
    ,x_component_citem_names  => x_component_citem_names
    ,x_component_owner_ids    => x_component_owner_ids
    ,x_component_owner_types  => x_component_owner_types
    ,x_component_sort_orders  => x_component_sort_orders
    ,x_keywords               => x_keywords
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_item;


PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
) IS
BEGIN
  get_trans_item(
    p_citem_ver_id            => p_citem_ver_id
    ,p_language               => NULL
    ,p_init_msg_list          => p_init_msg_list
    ,p_api_version_number     => p_api_version_number
    ,x_content_item_id        => x_content_item_id
    ,x_citem_name             => x_citem_name
    ,x_citem_version          => x_citem_version
    ,x_dir_node_id            => x_dir_node_id
    ,x_dir_node_name          => x_dir_node_name
    ,x_dir_node_code          => x_dir_node_code
    ,x_item_status            => x_item_status
    ,x_version_status         => x_version_status
    ,x_citem_description      => x_citem_description
    ,x_ctype_code             => x_ctype_code
    ,x_ctype_name             => x_ctype_name
    ,x_start_date             => x_start_date
    ,x_end_date               => x_end_date
    ,x_owner_resource_id      => x_owner_resource_id
    ,x_owner_resource_type    => x_owner_resource_type
    ,x_reference_code         => x_reference_code
    ,x_trans_required         => x_trans_required
    ,x_parent_item_id         => x_parent_item_id
    ,x_locked_by              => x_locked_by
    ,x_wd_restricted          => x_wd_restricted
    ,x_attach_file_id         => x_attach_file_id
    ,x_attach_file_name       => x_attach_file_name
    ,x_attach_mime_type       => x_attach_mime_type
    ,x_attach_mime_name       => x_attach_mime_name
    ,x_rendition_file_ids     => x_rendition_file_ids
    ,x_rendition_file_names   => x_rendition_file_names
    ,x_rendition_mime_types   => x_rendition_mime_types
    ,x_rendition_mime_names   => x_rendition_mime_names
    ,x_default_rendition      => x_default_rendition
    ,x_object_version_number  => x_object_version_number
    ,x_created_by             => x_created_by
    ,x_creation_date          => x_creation_date
    ,x_last_updated_by        => x_last_updated_by
    ,x_last_update_date       => x_last_update_date
    ,x_attribute_type_codes   => x_attribute_type_codes
    ,x_attribute_type_names   => x_attribute_type_names
    ,x_attributes             => x_attributes
    ,x_component_citems       => x_component_citems
    ,x_component_citem_ver_ids => x_component_citem_ver_ids
    ,x_component_attrib_types => x_component_attrib_types
    ,x_component_citem_names  => x_component_citem_names
    ,x_component_owner_ids    => x_component_owner_ids
    ,x_component_owner_types  => x_component_owner_types
    ,x_component_sort_orders  => x_component_sort_orders
    ,x_keywords               => x_keywords
    ,x_return_status          => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
  );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_item;




-- --------------------------------------------------------------
-- INSERT component ITEMS
--
-- Used to populate component content type information
--
-- --------------------------------------------------------------
PROCEDURE insert_components(
    p_citem_ver_id              IN NUMBER
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
    ,p_citem_ver_ids            IN JTF_NUMBER_TABLE
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_sort_order               IN JTF_NUMBER_TABLE
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'insert_component_items';  --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************

    qty_codes NUMBER;
    row_id  VARCHAR2(250);  -- required for use with table handlers
    -- flag to denote whether errors were found with this compound item
    insert_data CHAR(1);
    counter NUMBER := 1;
    sort_order NUMBER;
    content_item_id NUMBER;
    ctype_code IBC_CONTENT_TYPES_B.content_type_code%TYPE;
    dir_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
  SAVEPOINT svpt_insert_components;
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_insert_components;                           --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Insert_Components',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_content_item_ids', IBC_DEBUG_PVT.make_list(p_content_item_ids),
                                          'p_attribute_type_codes', IBC_DEBUG_PVT.make_list(p_attribute_type_codes),
                                          'p_sort_order', IBC_DEBUG_PVT.make_list(p_sort_order),
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

-- *** VALIDATION OF VALUES ******
     -- version id
    IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - citem_ver_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    content_item_id := getCitemId(p_citem_ver_id);
    dir_id := getDirectoryNodeId(content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(content_item_id) = FND_API.g_false) THEN                                         --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(content_item_id) = FND_API.g_false) THEN                                         --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    ctype_code := getContentType(content_item_id);
    -- if there is no content type code
    IF (ctype_code IS NULL) THEN
        --DBMS_OUTPUT.put_line('EX - getContentTypeV');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'UNABLE_TO_IDENTIFY_CTYPE');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- ACTUAL INSERTION OF COMPONENTS
    insert_component_items_int(
       p_citem_ver_id              => p_citem_ver_id
       ,p_content_item_id          => content_item_id
       ,p_content_item_ids         => p_content_item_ids
       ,p_citem_ver_ids            => p_citem_ver_ids
       ,p_attribute_type_codes     => p_attribute_type_codes
       ,p_ctype_code               => ctype_code
       ,p_sort_order               => p_sort_order
       ,p_log_action               => FND_API.g_true
       ,x_return_status            => x_return_status
    );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        --DBMS_OUTPUT.put_line('EX - inserting component items');
        -- raise errors from inner procedure
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_insert_components;
      --DBMS_OUTPUT.put_line('Expected Error');
       Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_insert_components;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_insert_components;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data,
                        'EXCEPTION', SQLERRM
                      )
        )
      );
    END IF;
 END;

-- --------------------------------------------------------------
-- INSERT component ITEMS
--
-- Used to populate component content type information
-- Overloaded - no subitem citem_ver_ids
-- --------------------------------------------------------------
PROCEDURE insert_components(
    p_citem_ver_id              IN NUMBER
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_sort_order               IN JTF_NUMBER_TABLE
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
BEGIN
  insert_components(
    p_citem_ver_id              => p_citem_ver_id
    ,p_content_item_ids         => p_content_item_ids
    ,p_citem_ver_ids            => NULL
    ,p_attribute_type_codes     => p_attribute_type_codes
    ,p_sort_order               => p_sort_order
    ,p_commit                   => p_commit
    ,p_api_version_number       => p_api_version_number
    ,p_init_msg_list            => p_init_msg_list
    ,x_return_status            => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
  );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_components;

-- --------------------------------------------------------------
-- INSERT ASSOCIATIONS
--
-- Used to populate tables containing association information/Links
--
-- --------------------------------------------------------------

PROCEDURE insert_associations(
    p_content_item_id           IN NUMBER
    ,p_assoc_type_codes         IN JTF_VARCHAR2_TABLE_100
    ,p_assoc_objects1           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects2           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects3           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects4           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects5           IN JTF_VARCHAR2_TABLE_300
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
BEGIN
  insert_associations(
    p_content_item_id           => p_content_item_id
    ,p_citem_version_id         => NULL
    ,p_assoc_type_codes         => p_assoc_type_codes
    ,p_assoc_objects1           => p_assoc_objects1
    ,p_assoc_objects2           => p_assoc_objects2
    ,p_assoc_objects3           => p_assoc_objects3
    ,p_assoc_objects4           => p_assoc_objects4
    ,p_assoc_objects5           => p_assoc_objects5
    ,p_commit                   => p_commit
    ,p_api_version_number       => p_api_version_number
    ,p_init_msg_list            => p_init_msg_list
    ,x_return_status            => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
  );
END insert_associations;

PROCEDURE insert_associations(
    p_content_item_id           IN NUMBER
    ,p_citem_version_id         IN NUMBER
    ,p_assoc_type_codes         IN JTF_VARCHAR2_TABLE_100
    ,p_assoc_objects1           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects2           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects3           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects4           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects5           IN JTF_VARCHAR2_TABLE_300
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'insert_citem_association';--|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************

   dir_id NUMBER;

BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_insert_associations;                         --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Insert_Associations',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_content_item_id', p_content_item_id,
                                          'p_citem_version_id', p_citem_version_id,
                                          'p_assoc_type_codes', IBC_DEBUG_PVT.make_list(p_assoc_type_codes),
                                          'p_assoc_objects1', IBC_DEBUG_PVT.make_list(p_assoc_objects1),
                                          'p_assoc_objects2', IBC_DEBUG_PVT.make_list(p_assoc_objects2),
                                          'p_assoc_objects3', IBC_DEBUG_PVT.make_list(p_assoc_objects3),
                                          'p_assoc_objects4', IBC_DEBUG_PVT.make_list(p_assoc_objects4),
                                          'p_assoc_objects5', IBC_DEBUG_PVT.make_list(p_assoc_objects5),
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

    -- citem
    IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false ) THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_citem_version_id IS NOT NULL AND
        IBC_VALIDATE_PVT.isValidCitemVerForCitem(p_content_item_id, p_citem_version_id) = FND_API.g_false)
    THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id/p_citem_version_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assoc type
    IF (p_assoc_type_codes IS NULL) THEN
        --DBMS_OUTPUT.put_line('EX - assoc type');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'IBC_INPUT_REQUIRED');
        FND_MESSAGE.Set_Token('INPUT', 'p_assoc_type_code', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- associated object 1
    IF (p_assoc_objects1 IS NULL) THEN
        --DBMS_OUTPUT.put_line('EX - p_assoc_object1');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'IBC_INPUT_REQUIRED');
        FND_MESSAGE.Set_Token('INPUT', 'p_assoc_object1', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


   dir_id := getDirectoryNodeId(p_content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => p_content_item_id                                        --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    -- only attempt insert if no errors were found
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        insert_citem_associations_int(
           p_content_item_id    => p_content_item_id
           ,p_citem_version_id  => p_citem_version_id
           ,p_assoc_type_codes  => p_assoc_type_codes
           ,p_assoc_objects1    => p_assoc_objects1
           ,p_assoc_objects2    => p_assoc_objects2
           ,p_assoc_objects3    => p_assoc_objects3
           ,p_assoc_objects4    => p_assoc_objects4
           ,p_assoc_objects5    => p_assoc_objects5
           ,p_log_action        => FND_API.g_true
           ,x_return_status     => x_return_status
        );
    END IF;


    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_insert_associations;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_insert_associations;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_insert_associations;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data,
                        'EXCEPTION', SQLERRM
                      )
        )
      );
    END IF;
 END;

-- --------------------------------------------------------------
-- INSERT CONTENT ITEM (MINIMUM)
--
-- Used for the creation of a new content item.
--
-- --------------------------------------------------------------
PROCEDURE insert_minimum_item(
    p_ctype_code              IN VARCHAR2
    ,p_citem_name             IN VARCHAR2
    ,p_citem_description      IN VARCHAR2
    ,p_lock_flag              IN VARCHAR2
    ,p_dir_node_id            IN NUMBER
    ,p_commit                 IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,px_content_item_id       IN OUT NOCOPY NUMBER
    ,px_object_version_number IN OUT NOCOPY NUMBER
    ,x_citem_ver_id           OUT NOCOPY NUMBER
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'insert_minimum_item';      --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    row_id  VARCHAR2(250);  -- required for use with table handlers
    locked_by NUMBER;  -- variable used to set locked_by column (logic needed)
    status IBC_CONTENT_ITEMS.content_item_status%TYPE := Ibc_Utilities_Pub.G_STI_PENDING;
    current_version NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_insert_minimum_item;                         --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Insert_Minimum_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_ctype_code', p_ctype_code,
                                          'p_citem_name', p_citem_name,
                                          'p_citem_description', p_citem_description,
                                          'p_lock_flag', p_lock_flag,
                                          'p_dir_node_id', p_dir_node_id,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_content_item_id', px_content_item_id,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

    IF(px_object_version_number IS NULL) THEN
        px_object_version_number := 1;
    END IF;

    -- checking for valid inputs and throwing exception if invalid
    -- content item name
    IF (p_citem_name IS NULL) THEN
        --DBMS_OUTPUT.put_line('EX - citem name');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'IBC_INPUT_REQUIRED');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_name', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (LENGTH(p_citem_name) > 240) THEN
        --DBMS_OUTPUT.put_line('EX - citem name');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_name', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- content item description
    IF ( (p_citem_description IS NOT NULL) AND (LENGTH(p_citem_description) > 2000) )THEN
        --DBMS_OUTPUT.put_line('EX - citem description');
        x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_description', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- content type
    IF (IBC_VALIDATE_PVT.isValidCType(p_ctype_code) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - ctype code');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_ctype_code', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- directory nodes
    IF ( (p_dir_node_id <> Ibc_Utilities_Pub.G_COMMON_DIR_NODE) AND (IBC_VALIDATE_PVT.isValidDirNode(p_dir_node_id) = FND_API.g_false) ) THEN
        --DBMS_OUTPUT.put_line('EX - dir_node_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_dir_node_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- checking if versioning is necessary
    IF (px_content_item_id IS NOT NULL) THEN
        IF (IBC_VALIDATE_PVT.isValidCitem(px_content_item_id) = FND_API.g_false)  THEN
            --DBMS_OUTPUT.put_line('EX - content_item_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'px_content_item_id', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            -- NEW VERSION NEEDS TO BE CREATED!!

          -- ***************PERMISSION CHECK*********************************************************************
          IF (hasPermission(px_content_item_id) = FND_API.g_false) THEN                                      --|*|
              --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
              x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
             FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
              FND_MSG_PUB.ADD;                                                                               --|*|
              RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
          ELSIF(isItemAdmin(px_content_item_id) = FND_API.g_false) THEN                                      --|*|
             IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                        p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                        ,p_instance_pk1_value    => px_content_item_id                                       --|*|
                        ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                        ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                        ,p_container_pk1_value   => p_dir_node_id                                            --|*|
                        ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                        ) = FND_API.g_false                                                                  --|*|
                  ) THEN                                                                                     --|*|
                 --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
                 x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
               FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
                 FND_MSG_PUB.ADD;                                                                            --|*|
                 RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
            END IF;                                                                                          --|*|
          END IF;                                                                                            --|*|
          -- ***************PERMISSION CHECK*********************************************************************

            current_version := getMaxVersion(px_content_item_id) + 1;
        END IF;
    ELSE
        -- CREATING BRAND SPANKING NEW ITEM!!!!!!!!
       -- ***************PERMISSION CHECK*********************************************************************
      IF( IBC_DATA_SECURITY_PVT.has_permission(                                                          --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')    --|*|
                  ,p_instance_pk1_value    => NULL                                                       --|*|
                  ,p_container_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value    => p_dir_node_id                                             --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                               --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                         --|*|
                  ) = FND_API.g_false                                                                    --|*|
            ) THEN                                                                                       --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                                --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                   --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                         --|*|
           FND_MSG_PUB.ADD;                                                                              --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                    --|*|
       END IF;                                                                                           --|*|
       -- ***************PERMISSION CHECK*********************************************************************
        current_version := 1;
    END IF;

    -- setting locked_by info
    IF (p_lock_flag = FND_API.g_true) THEN
        locked_by := FND_GLOBAL.user_id;
    ELSE
        locked_by := NULL;
    END IF;

    IF (px_content_item_id IS NULL) THEN
        -- create new content item
        -- inserting new row into ibc_content_items
        Ibc_Content_Items_Pkg.insert_row(
            x_rowid                      => row_id
            ,px_content_item_id          => px_content_item_id
            ,p_content_type_code         => p_ctype_code
            ,p_item_reference_code       => NULL
            ,p_directory_node_id         => p_dir_node_id
            ,p_live_citem_version_id     => NULL
            ,p_content_item_status       => status
            ,p_locked_by_user_id         => locked_by
            ,p_wd_restricted_flag        => FND_API.g_false
            ,p_base_language             => USERENV('LANG')
            ,p_translation_required_flag => FND_API.g_false
            ,p_owner_resource_id         => FND_GLOBAL.USER_ID
            ,p_owner_resource_type       => 'USER'
            ,p_application_id            => NULL
            ,p_parent_item_id            => NULL
            ,p_request_id                => NULL
            ,p_object_version_number     => G_OBJ_VERSION_DEFAULT
         );

                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_CREATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => px_content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => NULL
                                   );
                                   --***************************************************
                                   --***************************************************
    END IF;


    -- inserting new row into ibc_citem_versions
    Ibc_Citem_Versions_Pkg.insert_base_lang(
        x_rowid                      => row_id
        ,px_citem_version_id         => x_citem_ver_id
        ,p_content_item_id           => px_content_item_id
        ,p_version_number            => current_version
        ,p_citem_version_status      => status
        ,p_start_date                => NULL
        ,p_end_date                  => NULL
        ,px_object_version_number    => px_object_version_number
        ,p_attribute_file_id         => NULL
        ,p_attachment_file_id        => NULL
        ,p_attachment_attribute_code => NULL
        ,p_content_item_name         => p_citem_name
        ,p_attachment_file_name      => NULL
        ,p_description               => p_citem_description
     );

    -- adding item heading if the log was skipped earlier
     IF (current_version <> 1) THEN
                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_CREATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => px_content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => NULL
                                   );
                                   --***************************************************
                                   --***************************************************
    END IF;
                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_CREATE
                                       ,p_parent_value  => px_content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => x_citem_ver_id
                                       ,p_object_value2 => USERENV('LANG')
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => NULL
                                   );
                                   --***************************************************
                                   --***************************************************
    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'px_content_item_id', px_content_item_id,
                        'px_object_version_number', px_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_insert_minimum_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_insert_minimum_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_insert_minimum_item;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- LOCK CONTENT ITEM
--
--
-- --------------------------------------------------------------
PROCEDURE lock_item(
    p_content_item_id           IN NUMBER
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,x_citem_version_id         OUT NOCOPY NUMBER
    ,x_object_version_number    OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'lock_content_item';       --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
   dir_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_lock_item;                                 --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Lock_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_content_item_id', p_content_item_id,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

    -- citem validation
    IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false ) THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    dir_id := getDirectoryNodeId(p_content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => p_content_item_id                                        --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    changeLock(p_content_item_id,FND_GLOBAL.user_id);

    -- getting object version number
    x_object_version_number := getObjVerNum(p_content_item_id);

    x_citem_version_id := getMaxVersionId(p_content_item_id);


    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_citem_version_id', x_citem_version_id,
                        'x_object_version_number', x_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_lock_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
     END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_lock_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
     END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_lock_item;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
     END IF;
 END;

-- --------------------------------------------------------------
-- PRE VALIDATE ITEM
--
-- Used to validate an item before it is ready to be approved.
--
-- --------------------------------------------------------------
PROCEDURE pre_validate_item(
    p_citem_ver_id              IN NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'pre_validate_item';--|**|
--******************* END REQUIRED VARIABLES ***************************
    file_id NUMBER;
    base_language VARCHAR2(30);
    -- temporary clob used to hold attribute bundle while it is being validated
    temp_bundle CLOB;
BEGIN

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Pre_Validate_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_citem_ver_id', p_citem_ver_id
                                        )
                           )
      );
    END IF;

     --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- CREATING TEMP ATTRIBUTE BUNDLE
    DBMS_LOB.createtemporary(temp_bundle, TRUE, 2);

    -- getting file_id of actual attribute bundle
    SELECT
        MIN(civtl.attribute_file_id), ci.base_language
    INTO
        file_id,
        base_language
    FROM
        ibc_citem_versions_tl civtl,
        ibc_citem_versions_b civb,
        ibc_content_items    ci
    WHERE
        civb.content_item_id = ci.content_item_id
    AND
        civb.citem_version_id = p_citem_ver_id
    AND
        civtl.citem_version_id = civb.citem_version_id
    AND
        civtl.LANGUAGE = ci.base_language -- Updated by Edward to fix bug# 3405512 re: USERENV('LANG');
    GROUP BY ci.base_language;

  -- building full XML  if the bundle is present
    IF (file_id IS NOT NULL) THEN
        Ibc_Utilities_Pvt.build_attribute_bundle (
           p_file_id       => file_id
          ,p_xml_clob_loc => temp_bundle
        );
    END IF;

    -- VALIDATION
    validate_attribute_bundle(
        p_attribute_bundle  => temp_bundle
        ,p_citem_ver_id     => p_citem_ver_id
        ,p_language         => base_language
        ,x_return_status    => x_return_status
    );
    IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- SET CONTENT ITEM (ATTRIBUTE BUNDLE)
--
-- Used for the creation of a new content item attributes or updating
-- the existing attributes.  Updating is actually replacement unless
-- it is a new version.
--
-- --------------------------------------------------------------
PROCEDURE set_attribute_bundle(
    p_citem_ver_id              IN NUMBER
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_attributes               IN JTF_VARCHAR2_TABLE_32767
    ,p_remove_old               IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'set_citem_att_bundle';    --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    ctype_code IBC_CONTENT_TYPES_B.content_type_code%TYPE; -- content type code
    bundle_text CLOB; -- tempory blob
    file_id NUMBER; -- pointer to actual FND_LOB location
    old_file_id NUMBER;
    return_status CHAR(1);
    content_item_id NUMBER;
    dir_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_set_attribute_bundle;                        --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Set_Attribute_Bundle',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_32767(
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_attribute_type_codes', IBC_DEBUG_PVT.make_list(p_attribute_type_codes),
                                          'p_attributes', IBC_DEBUG_PVT.make_list_VC32767(p_attributes),
                                          'p_remove_old', p_remove_old,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

--******************* INPUT VALIDATION ************
     -- validating item information
    IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - citem_ver_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (IBC_VALIDATE_PVT.isApproved(p_citem_ver_id) = FND_API.g_true) THEN
        --DBMS_OUTPUT.put_line('EX - updating approved');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'UPDATE_APPROVED_ITEM_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    content_item_id := getCitemId(p_citem_ver_id);

    dir_id := getDirectoryNodeId(content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(content_item_id) = FND_API.g_false) THEN                                         --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(content_item_id) = FND_API.g_false) THEN                                         --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    ctype_code := getContentType(getCitemId(p_citem_ver_id));


    -- creating temporary lob
    DBMS_LOB.createtemporary(bundle_text, TRUE, 2);

    create_attribute_bundle(
        px_attribute_bundle      => bundle_text
        ,p_attribute_type_codes  => p_attribute_type_codes
        ,p_attributes            => p_attributes
        ,p_ctype_code            => ctype_code
        ,x_return_status         => return_status
    );

--**************** STORING INFO TO DB ***********
    -- Inserting temp lob into fnd_lobs
    IF (return_status = FND_API.G_RET_STS_SUCCESS) THEN
        -- removing old bundle if requested (this is fine because no sharing
        -- has occured yet due to fact that the item is not published.
        IF (p_remove_old = FND_API.g_true) THEN
            return_status := deleteAttributeBundle(p_citem_ver_id);
        END IF;

        -- adding data to fnd_lobs
      Ibc_Utilities_Pvt.insert_attribute_bundle(
         x_lob_file_id           => file_id
         ,p_new_bundle           => bundle_text
         ,x_return_status        => return_status
        );

        -- raise exception if error occured while in utilities procedure
      IF (return_status = FND_API.G_RET_STS_ERROR) THEN
         --DBMS_OUTPUT.put_line('EX - inserting attribute bundle');
         x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_INSERT_ERROR');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         -- adding attribute bundle file id to citem version if bundle went in correctly
         Ibc_Citem_Versions_Pkg.update_row(
            p_citem_version_id         => p_citem_ver_id
            ,p_content_item_id         => content_item_id
            ,p_attribute_file_id       => file_id
            ,px_object_version_number  => px_object_version_number
         );

                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Altering content item version'
                                   );
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => p_citem_ver_id
                                       ,p_object_value2 => USERENV('LANG')
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Altering attribute bundle'
                                   );
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_CREATE
                                       ,p_parent_value  => p_citem_ver_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_ATTRIBUTE_BUNDLE
                                       ,p_object_value1 => file_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => NULL
                                   );
                                   --***************************************************
                                   --***************************************************
      END IF;
    ELSE
        --DBMS_OUTPUT.put_line('EX - creating attribute bundle');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_CREATION_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'px_object_version_number', px_object_version_number,
                      'x_return_status', x_return_status,
                      'x_msg_count', x_msg_count,
                      'x_msg_data', x_msg_data
                    )
      )
    );
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_set_attribute_bundle;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_set_attribute_bundle;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_set_attribute_bundle;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- Overloaded to support old 4K limit on attribute values
PROCEDURE set_attribute_bundle(
    p_citem_ver_id              IN NUMBER
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_attributes               IN JTF_VARCHAR2_TABLE_4000
    ,p_remove_old               IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_tmp_attributes JTF_VARCHAR2_TABLE_32767;
BEGIN

  IF p_attributes IS NOT NULL AND p_attributes.COUNT > 0 THEN
    l_tmp_attributes := JTF_VARCHAR2_TABLE_32767();
    l_tmp_attributes.extend(p_attributes.COUNT);
    FOR I IN 1..p_attributes.COUNT LOOP
      l_tmp_attributes(I) := p_attributes(I);
    END LOOP;
  ELSE
    l_tmp_attributes := NULL;
  END IF;

  set_attribute_bundle(
    p_citem_ver_id              => p_citem_ver_id
    ,p_attribute_type_codes     => p_attribute_type_codes
    ,p_attributes               => l_tmp_attributes
    ,p_remove_old               => p_remove_old
    ,p_commit                   => p_commit
    ,p_api_version_number       => p_api_version_number
    ,p_init_msg_list            => p_init_msg_list
    ,px_object_version_number   => px_object_version_number
    ,x_return_status            => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
  );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END set_attribute_bundle;

-- --------------------------------------------------------------
-- SET CONTENT ITEM (ATTACHMENT)
--
-- Used to add/remove an attachment to existing content_item
-- This only works for default rendition.
--
-- --------------------------------------------------------------
PROCEDURE set_attachment(
    p_citem_ver_id              IN NUMBER
    ,p_attach_file_id           IN NUMBER
    ,p_language                 IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'set_citem_attachment';    --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    att_file_name IBC_CITEM_VERSIONS_TL.attachment_file_name%TYPE;
    att_type_code IBC_ATTRIBUTE_TYPES_B.data_type_code%TYPE;
    l_attach_rendition_mtype FND_LOBS.file_content_type%TYPE;
    l_current_attachment_file_id NUMBER;
    content_item_id NUMBER;
    dir_id NUMBER;
    l_row_id       ROWID;
    l_rendition_id NUMBER;

    CURSOR c_lob(p_file_id NUMBER) IS
      SELECT file_name, file_content_type
        FROM fnd_lobs
       WHERE file_id = p_file_id;

BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_set_attachment;                              --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Set_Attachment',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_attach_file_id', p_attach_file_id,
                                          'p_language', p_language,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

-- *** VALIDATION OF VALUES ******
     -- version id
    IF ( (p_citem_ver_id IS NULL) OR (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) ) THEN
        --DBMS_OUTPUT.put_line('EX - citem_ver_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- validating language
    IF (IBC_VALIDATE_PVT.isValidLanguage(p_language) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - LANGUAGE');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_language', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ((IBC_VALIDATE_PVT.getItemBaseLanguage(getCitemId(p_citem_ver_id))) = p_language) THEN
      IF (IBC_VALIDATE_PVT.isApproved(p_citem_ver_id) = FND_API.g_true) THEN
        --DBMS_OUTPUT.put_line('EX - updating approved');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'UPDATE_APPROVED_ITEM_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      IF (IBC_VALIDATE_PVT.isTranslationApproved(p_citem_ver_id,p_language) = FND_API.g_true) THEN
        --DBMS_OUTPUT.put_line('EX - updating approved translation');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'UPDATE_APPROVED_ITEM_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;



   content_item_id := getCitemId(p_citem_ver_id);

   SELECT attachment_file_id
     INTO l_current_attachment_file_id
     FROM ibc_citem_versions_tl
    WHERE citem_version_id = p_citem_ver_id;

    -- attachment
    -- if attachment given
    IF (p_attach_file_id IS NOT NULL) THEN
        -- check to see if attachment is valid
        IF (IBC_VALIDATE_PVT.isValidAttachment(p_attach_file_id) = FND_API.g_false)  THEN
            --DBMS_OUTPUT.put_line('EX - p_attach_file_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_attach_file_id', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        -- if valid then get additional attachment info
        ELSE
            OPEN c_lob(p_attach_file_id);
            FETCH c_lob INTO att_file_name, l_attach_rendition_mtype;
            CLOSE c_lob;
            l_attach_rendition_mtype := GET_MIME_TYPE(l_attach_rendition_mtype);
            att_type_code := getAttachAttribCode(content_item_id);

            -- check to see if code is valid since it is required for runtime
            IF(att_type_code IS NULL) THEN
                --DBMS_OUTPUT.put_line('EX - attachment attcode does not exist');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('IBC', 'INVALID_ATTACH_ATTR_TYPE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        -- Delete default rendition
        DELETE FROM ibc_renditions
         WHERE citem_version_id = p_citem_ver_id
           AND LANGUAGE = p_language
           AND file_id = l_current_attachment_file_id;

        END IF;
    ELSE
        -- if no valid attachment given then give null values for other attachment attributes
        att_file_name := NULL;
        att_type_code := NULL;
        l_attach_rendition_mtype := NULL;
        -- Delete all renditions for particular language
        DELETE FROM ibc_renditions
         WHERE citem_version_id = p_citem_ver_id
           AND LANGUAGE = p_language;
    END IF;

    dir_id := getDirectoryNodeId(content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(content_item_id) = FND_API.g_false) THEN                                         --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                          --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(content_item_id) = FND_API.g_false) THEN                                         --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                       --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    -- Adding data
        -- ****RENDITIONS_WORK****
    Ibc_Citem_Versions_Pkg.update_row (
        p_citem_version_id             => p_citem_ver_id
        ,p_content_item_id             => content_item_id
        ,p_attachment_file_id          => Conv_To_TblHandler(p_attach_file_id) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_attachment_file_name        => Conv_To_TblHandler(att_file_name) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_attachment_attribute_code   => Conv_To_TblHandler(att_type_code) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_default_rendition_mime_type => Conv_To_TblHandler(l_attach_rendition_mtype) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,px_object_version_number      => px_object_version_number
    );

                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Altering content item version'
                                   );
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => p_citem_ver_id
                                       ,p_object_value2 => USERENV('LANG')
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Altering attachment:'||p_attach_file_id
                                   );
                                   --***************************************************
                                   --***************************************************

     IF p_attach_file_id IS NOT NULL THEN
      l_rendition_id := NULL;
      IBC_RENDITIONS_PKG.insert_row(
        Px_rowid                   => l_row_id
        ,Px_RENDITION_ID          => l_rendition_id
        ,p_object_version_number => G_OBJ_VERSION_DEFAULT
        ,P_LANGUAGE                 => p_language
        ,P_FILE_ID                 => Conv_To_TblHandler(p_attach_file_id) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,P_FILE_NAME               => Conv_To_TblHandler(att_file_name) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,P_CITEM_VERSION_ID       => p_citem_ver_id
        ,P_MIME_TYPE                => Conv_To_TblHandler(l_attach_rendition_mtype) -- Updated for STANDARD/perf change of G_MISS_xxx
      );
    END IF;


    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'px_object_version_number', px_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_set_attachment;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_set_attachment;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_set_attachment;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- SET CONTENT ITEM (META)
--
--
-- --------------------------------------------------------------
PROCEDURE set_citem_meta(
    p_content_item_id           IN NUMBER
    ,p_dir_node_id              IN NUMBER
    ,p_trans_required           IN VARCHAR2
    ,p_owner_resource_id        IN NUMBER
    ,p_owner_resource_type      IN VARCHAR2
    ,p_parent_item_id           IN NUMBER
    ,p_wd_restricted            IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_init_msg_list            IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'set_citem_meta';          --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    directory_node		NUMBER;
    p_new_owner_resource_type	VARCHAR2(11);
    p_new_owner_resource_id	NUMBER;

BEGIN
   --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_set_citem_meta;                              --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Set_Citem_Meta',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_content_item_id', p_content_item_id,
                                          'p_dir_node_id', p_dir_node_id,
                                          'p_trans_required', p_trans_required,
                                          'p_owner_resource_id', p_owner_resource_id,
                                          'p_owner_resource_type', p_owner_resource_type,
                                          'p_parent_item_id', p_parent_item_id,
                                          'p_wd_restricted', p_wd_restricted,
                                          'p_commit', p_commit,
                                          'p_init_msg_list', p_init_msg_list,
                                          'p_api_version_number', p_api_version_number,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

-- *** VALIDATION OF VALUES ******
     -- item id
    IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - citem_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (IBC_VALIDATE_PVT.isApprovedItem(p_content_item_id) = FND_API.g_true) THEN
        --DBMS_OUTPUT.put_line('EX - updating approved');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'UPDATE_APPROVED_ITEM_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_dir_node_id IS NOT NULL) THEN
        IF ( (p_dir_node_id <> FND_API.g_miss_num) AND (IBC_VALIDATE_PVT.isValidDirNode(p_dir_node_id) = FND_API.g_false) ) THEN
            --DBMS_OUTPUT.put_line('EX - dir_node_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_dir_node_id', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            directory_node := p_dir_node_id;
        END IF;
    ELSE
        directory_node := Ibc_Utilities_Pub.G_COMMON_DIR_NODE;
    END IF;

    -- trans required
    IF ( (p_trans_required <> FND_API.g_false) AND (p_trans_required <> FND_API.g_true) AND (p_trans_required <> FND_API.g_miss_char) ) THEN
        --DBMS_OUTPUT.put_line('EX - trans_required');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_trans_required', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- parent item id
    IF ( (p_parent_item_id <> FND_API.g_miss_num) AND (IBC_VALIDATE_PVT.isValidCitem(p_parent_item_id) = FND_API.g_false)) THEN
        --DBMS_OUTPUT.put_line('EX - parent item id');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_parent_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- wd restricted
    IF ( (p_wd_restricted <> FND_API.g_miss_char) AND (IBC_VALIDATE_PVT.isBoolean(p_wd_restricted) = FND_API.g_false) ) THEN
        --DBMS_OUTPUT.put_line('EX - wd_restricted');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_wd_restricted', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- resource id

    IF ( (p_owner_resource_id IS NOT NULL) AND
         (p_owner_resource_id <> FND_API.G_MISS_NUM) )
    THEN
	p_new_owner_resource_id := p_owner_resource_id;

       IF (p_owner_resource_type IS NULL OR
           p_owner_resource_type = FND_API.G_MISS_CHAR) THEN
           p_new_owner_resource_type := 'USER';
       ELSE
           p_new_owner_resource_type := p_owner_resource_type;
       END IF;
    ELSE  -- user does not pass resource_id default to login user id
	 p_new_owner_resource_id   := FND_GLOBAL.user_id;
	 p_new_owner_resource_type := 'USER';
    END IF;


    IF (IBC_VALIDATE_PVT.isValidResource(p_new_owner_resource_id,p_new_owner_resource_type) = FND_API.g_false) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
          FND_MESSAGE.Set_Token('INPUT', 'p_owner_resource_id/p_owner_resource_type<' || p_new_owner_resource_id||':'||p_new_owner_resource_type||'>', FALSE);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(p_content_item_id) = FND_API.g_false) THEN                                      --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                           --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                   --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                       --|*|
        FND_MSG_PUB.ADD;                                                                              --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                    --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                      --|*|
      IF (IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
               p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')    --|*|
               ,p_instance_pk1_value    => p_content_item_id                                          --|*|
               ,p_permission_code       => 'CITEM_EDIT'                                               --|*|
               ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')  --|*|
               ,p_container_pk1_value   => directory_node                                             --|*|
               ,p_current_user_id       => FND_GLOBAL.user_id                                         --|*|
               ) = FND_API.g_false                                                                    --|*|
          ) THEN                                                                                      --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                             --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                    --|*|
           FND_MSG_PUB.ADD;                                                                           --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                 --|*|
      END IF;                                                                                         --|*|
    END IF;                                                                                           --|*|
    -- ***************PERMISSION CHECK*********************************************************************

-- *** UPDATING DATA IN DB *********
-- Updating Content Item
    Ibc_Content_Items_Pkg.update_row (
        p_content_item_id            => p_content_item_id
        ,p_directory_node_id         => Conv_To_TblHandler(directory_node) -- Update for STANDARD/perf change of G_MISS_xxx
        ,p_wd_restricted_flag        => Conv_To_TblHandler(p_wd_restricted) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_translation_required_flag => Conv_To_TblHandler(p_trans_required) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_owner_resource_id         => Conv_To_TblHandler(p_new_owner_resource_id) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_owner_resource_type       => Conv_To_TblHandler(p_new_owner_resource_type) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_parent_item_id            => Conv_To_TblHandler(p_parent_item_id) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,px_object_version_number    => px_object_version_number
    );
                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => p_content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Altering content item meta data'
                                   );
                                   --***************************************************
                                   --***************************************************

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'px_object_version_number', px_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_set_citem_meta;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_set_citem_meta;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_set_citem_meta;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- SET LIVE VERSION
--
-- Set Live Version
--
-- --------------------------------------------------------------
PROCEDURE Set_Live_Version(
    p_content_item_id           IN NUMBER
    ,p_citem_ver_id             IN NUMBER
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS

  --******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'Set_Live_Version';  --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
  --******************* END REQUIRED VARIABLES ***************************

  l_dummy                    VARCHAR2(2);
  l_dir_id                   NUMBER;

  CURSOR c_chk_citem (p_content_item_id NUMBER,
                      p_citem_ver_id    NUMBER)
  IS
  SELECT 'X'
    FROM IBC_CONTENT_ITEMS CITEM,
         IBC_CITEM_VERSIONS_B CIVER
   WHERE CITEM.content_item_id = CIVER.content_item_id
     AND CITEM.content_item_id = p_content_item_id
     AND CIVER.citem_version_id = p_citem_ver_id;


BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_set_live_version;                            --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Set_Live_Version',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_content_item_id', p_content_item_id,
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

-- *** VALIDATION OF VALUES ******

     -- content item id
    IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
      FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (IBC_VALIDATE_PVT.isApprovedItem(p_content_item_id) = FND_API.g_false) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
      FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (IBC_VALIDATE_PVT.isapproved(p_citem_ver_id) = FND_API.g_false) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
      FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_chk_citem(p_content_item_id, p_citem_ver_id);
    FETCH c_chk_citem INTO l_dummy;
    IF c_chk_citem%NOTFOUND THEN
      CLOSE c_chk_citem;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
      FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      CLOSE c_chk_citem;
    END IF;

    l_dir_id := getDirectoryNodeId(p_content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(p_content_item_id) = FND_API.g_false) THEN                                         --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                         --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => p_content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => l_dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
           FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    Ibc_Content_Items_Pkg.update_row (
      p_CONTENT_ITEM_ID     => p_content_item_id
      ,p_LIVE_CITEM_VERSION_ID  => p_citem_ver_id
      ,px_object_version_number => px_object_version_number
    );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        -- raise errors from inner procedure
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_set_live_version;
      --DBMS_OUTPUT.put_line('Expected Error');
       Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
       );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_set_live_version;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_set_live_version;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data,
                        'EXCEPTION', SQLERRM
                      )
        )
      );
    END IF;
  END;

-- --------------------------------------------------------------
-- SET CONTENT ITEM VERSION (META)
--
--
-- --------------------------------------------------------------
PROCEDURE set_version_meta(
    p_citem_ver_id              IN NUMBER
    ,p_citem_name               IN VARCHAR2
    ,p_citem_description        IN VARCHAR2
    ,p_start_date               IN DATE
    ,p_end_date                 IN DATE
    ,p_commit                   IN VARCHAR2
    ,p_init_msg_list            IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'set_citem_version_meta';  --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    content_item_id    NUMBER;
    directory_node NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_set_version_meta;                            --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Set_Version_Metal',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_citem_ver_id', p_citem_ver_id,
                                          'p_citem_name', p_citem_name,
                                          'p_citem_description', p_citem_description,
                                          'p_start_date', TO_CHAR(p_start_date, 'YYYYMMDD HH24:MI:SS'),
                                          'p_end_date', TO_CHAR(p_end_date, 'YYYYMMDD HH24:MI:SS'),
                                          'p_commit', p_commit,
                                          'p_init_msg_list', p_init_msg_list,
                                          'p_api_version_number', p_api_version_number,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

-- *** VALIDATION OF VALUES ******
     -- item id
    IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - citem_ver_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (IBC_VALIDATE_PVT.isApproved(p_citem_ver_id) = FND_API.g_true) THEN
        --DBMS_OUTPUT.put_line('EX - updating approved');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'UPDATE_APPROVED_ITEM_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    content_item_id := getCitemId(p_citem_ver_id);

    -- validating content item id
    IF (content_item_id IS NULL) THEN
       --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'CONTENT_ITEM_NOT_FOUND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- checking for valid inputs and throwing exception if invalid
    -- content item name
    IF ( (p_citem_name IS NULL) OR (LENGTH(p_citem_name) > 240) )THEN
        --DBMS_OUTPUT.put_line('EX - citem name');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_name', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- content item description
    IF ( (p_citem_description IS NOT NULL) AND (p_citem_description <> FND_API.G_MISS_CHAR) AND (LENGTH(p_citem_description) > 2000) )THEN
        --DBMS_OUTPUT.put_line('EX - citem description');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_description', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(content_item_id) = FND_API.g_false) THEN                                         --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                           --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(content_item_id) = FND_API.g_false) THEN                                         --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => directory_node                                           --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

-- Updating Content Item Version
    Ibc_Citem_Versions_Pkg.update_row (
        p_citem_version_id           => p_citem_ver_id
        ,p_content_item_id           => content_item_id
        ,p_start_date                => Conv_To_TblHandler(p_start_date) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_end_date                  => Conv_To_TblHandler(p_end_date) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_content_item_name         => Conv_To_TblHandler(p_citem_name) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,p_description               => Conv_To_TblHandler(p_citem_description) -- Updated for STANDARD/perf change of G_MISS_xxx
        ,px_object_version_number    => px_object_version_number
    );


                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Altering content item version'
                                   );

                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => p_citem_ver_id
                                       ,p_object_value2 => USERENV('LANG')
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Altering version meta data'
                                   );
                                   --***************************************************
                                   --***************************************************

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'px_object_version_number', px_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_set_version_meta;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_set_version_meta;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_set_version_meta;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- UNARCHIVE ITEM
--
--
--
-- --------------------------------------------------------------
PROCEDURE unarchive_item(
    p_content_item_id           IN NUMBER
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'unarchive_item';          --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
    new_status IBC_CONTENT_ITEMS.content_item_status%TYPE;
    base_lang IBC_CONTENT_ITEMS.base_language%TYPE;
    citem_version_id NUMBER;
    locked_by NUMBER;
    temp NUMBER;
    dir_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_unarchive_item;                              --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Unarchive_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_content_item_id', p_content_item_id,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

    -- citem validation
    IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false ) THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (getContentItemStatus(p_content_item_id)
        NOT IN (IBC_UTILITIES_PUB.G_STI_ARCHIVED, IBC_UTILITIES_PUB.G_STI_ARCHIVED_CASCADE))
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('IBC', 'IBC_CITEM_NOT_ARCHIVED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- getting information about the given content item
    SELECT
        content_item_id
        ,live_citem_version_id
        ,base_language
        ,locked_by_user_id
        ,directory_node_id
    INTO
        temp
        ,citem_version_id
        ,base_lang
        ,locked_by
        ,dir_id
    FROM
        ibc_content_items
    WHERE
        content_item_id = p_content_item_id;

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => p_content_item_id                                        --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    -- which status was it previously in?
    IF (citem_version_id IS NULL) THEN
        -- since there was no live version id, it was PENDING
        new_status := Ibc_Utilities_Pub.G_STI_PENDING;
    ELSE
        -- was approved
        new_status := Ibc_Utilities_Pub.G_STI_APPROVED;

        -- reapprove live version to make sure that is still valid
        approve_citem_version_int(
            p_citem_ver_id              => citem_version_id
            ,p_content_item_id          => p_content_item_id
            ,p_base_lang                => base_lang
            ,px_object_version_number   => px_object_version_number
            ,x_return_status            => x_return_status
        );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            --DBMS_OUTPUT.put_line('EX - no permissions');
            x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('IBC', 'CANNOT_REVERT_STATUS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- Actual changing of status if made it to this point
    Ibc_Content_Items_Pkg.update_row (
        p_content_item_id         => p_content_item_id
        ,p_content_item_status    => new_status
        ,p_locked_by_user_id      => FND_API.G_MISS_NUM -- Updated for STANDARD/perf change of G_MISS_xxx
        ,px_object_version_number => px_object_version_number
    );

                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UNARCHIVE
                                       ,p_parent_value  => NULL
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                       ,p_object_value1 => p_content_item_id
                                       ,p_object_value2 => NULL
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Unarchiving item'
                                   );
                                   --***************************************************


    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'px_object_version_number', px_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_unarchive_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_unarchive_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_unarchive_item;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

-- --------------------------------------------------------------
-- UNLOCK CONTENT ITEM
--
--
-- --------------------------------------------------------------
PROCEDURE unlock_item(
    p_content_item_id           IN NUMBER
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
--******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'unlock_content_item';     --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT; --|**|
--******************* END REQUIRED VARIABLES ***************************
   dir_id NUMBER;
BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_unlock_item;                                 --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
         ,p_api_version_number                                 --|**|
         ,l_api_name                                           --|**|
         ,G_PKG_NAME                                           --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Unlock_Item',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_content_item_id', p_content_item_id,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

    -- citem validation
    IF (IBC_VALIDATE_PVT.isValidCitem(p_content_item_id) = FND_API.g_false ) THEN
        --DBMS_OUTPUT.put_line('EX - content_item_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_content_item_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    dir_id := getDirectoryNodeId(p_content_item_id);
    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(p_content_item_id) = FND_API.g_false) THEN                                       --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => p_content_item_id                                        --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

    -- ACTUAL UNLOCKING!
    UPDATE
      ibc_content_items
    SET
      locked_by_user_id = NULL
    WHERE
      content_item_id = p_content_item_id;

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_unlock_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_unlock_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_unlock_item;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;


-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
--
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
      p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_32767
       ,p_attach_file_id            IN NUMBER
       ,p_item_renditions           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_citem_ver_ids   IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_keywords                  IN JTF_VARCHAR2_TABLE_100
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
)IS
 --******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'upsert_item_full';         --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT;  --|**|
--******************* END REQUIRED VARIABLES ****************************
    row_id  VARCHAR2(250);  -- required for use with table handlers
    locked_by NUMBER; -- locked_by value to be determined from attributes and logic
    attach_code IBC_CITEM_VERSIONS_TL.attachment_attribute_code%TYPE;
    l_attach_file_name        IBC_CITEM_VERSIONS_TL.attachment_file_name%TYPE;
    l_attach_rendition_mtype  IBC_CITEM_VERSIONS_TL.default_rendition_mime_type%TYPE;
    l_dummy_attach_file_name        IBC_CITEM_VERSIONS_TL.attachment_file_name%TYPE;
    l_dummy_attach_rendition_mtype  IBC_CITEM_VERSIONS_TL.default_rendition_mime_type%TYPE;
    p_object_ver_num NUMBER := 1; -- object version number (static since this is insert only)
    l_rendition_id  NUMBER;
    bundle_text CLOB; -- tempory blob
    bundle_file_id NUMBER; -- pointer to actual FND_LOB location
    -- status used when creating not using approved until it passes without any errors
    bulk_status IBC_CONTENT_ITEMS.content_item_status%TYPE;
    purge_old VARCHAR2(1) := FND_API.g_true;
    current_version NUMBER := 1;
    tempfid NUMBER;
    directory_node NUMBER;
    return_status CHAR(1);
    lang IBC_CITEM_VERSIONS_TL.LANGUAGE%TYPE;
    base_lang IBC_CITEM_VERSIONS_TL.LANGUAGE%TYPE;
    temp VARCHAR2(10); -- throw away variable
    do_item CHAR(1);
    do_version CHAR(1);
    perm_code  JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100();
    p_new_owner_resource_type VARCHAR2(11);
    p_new_owner_resource_id   NUMBER;


    CURSOR c_lob(p_file_id NUMBER) IS
      SELECT file_name, file_content_type
        FROM fnd_lobs
       WHERE file_id = p_file_id;

BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_upsert_item;                                 --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
         L_API_VERSION_NUMBER                                     --|**|
      ,p_api_version_number                                    --|**|
      ,L_API_NAME                                              --|**|
      ,G_PKG_NAME                                              --|**|
      )THEN                                                       --|**|
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Begin Upsert_Item_Full',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_32767(
                                          'p_ctype_code', p_ctype_code,
                                          'p_citem_name', p_citem_name,
                                          'p_citem_description', p_citem_description,
                                          'p_dir_node_id', p_dir_node_id,
                                          'p_owner_resource_id', p_owner_resource_id,
                                          'p_owner_resource_type', p_owner_resource_type,
                                          'p_reference_code', p_reference_code,
                                          'p_trans_required', p_trans_required,
                                          'p_parent_item_id', p_parent_item_id,
                                          'p_lock_flag', p_lock_flag,
                                          'p_wd_restricted', p_wd_restricted,
                                          'p_start_date', TO_CHAR(p_start_date, 'YYYYMMDD HH24:MI:SS'),
                                          'p_end_date',   TO_CHAR(p_end_date, 'YYYYMMDD HH24:MI:SS'),
                                          'p_attribute_type_codes', IBC_DEBUG_PVT.make_list(p_attribute_type_codes),
                                          'p_attributes', IBC_DEBUG_PVT.make_list_VC32767(p_attributes),
                                          'p_attach_file_id', p_attach_file_id,
                                          'p_item_renditions', IBC_DEBUG_PVT.make_list(p_item_renditions),
                                          'p_default_rendition', p_default_rendition,
                                          'p_component_citems', IBC_DEBUG_PVT.make_list(p_component_citems),
                                          'p_component_citem_ver_ids', IBC_DEBUG_PVT.make_list(p_component_citem_Ver_ids),
                                          'p_component_atypes', IBC_DEBUG_PVT.make_list(p_component_atypes),
                                          'p_sort_order', IBC_DEBUG_PVT.make_list(p_sort_order),
                                          'p_keywords', IBC_DEBUG_PVT.make_list(p_keywords),
                                          'p_status', p_status,
                                          'p_log_action', p_log_action,
                                          'p_language', p_language,
                                          'p_update', p_update,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_content_item_id', px_content_item_id,
                                          'px_citem_ver_id', px_citem_ver_id,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;

-- INITIALIZING DEFAULTS -----------------------------------------------
    IF (px_object_version_number IS NULL) THEN
        px_object_version_number := 1;
    END IF;

    IF (p_language IS NULL) THEN
        lang := USERENV('LANG');
    ELSE
        lang := p_language;
    END IF;

    -- setting temporary status
    IF (p_status = Ibc_Utilities_Pub.G_STV_APPROVED) THEN
        bulk_status := Ibc_Utilities_Pub.G_STV_SUBMIT_FOR_APPROVAL;
    ELSE
        bulk_status := p_status;
    END IF;

    IF (p_dir_node_id IS NULL) THEN
        directory_node := Ibc_Utilities_Pub.G_COMMON_DIR_NODE;
    ELSE
        directory_node := p_dir_node_id;
    END IF;
-- --------------------------------------------------------------------



-- DETERMINING WHAT NEEDS TO BE DONE ----------------------------------

    version_engine(
        px_content_item_id  => px_content_item_id
        ,p_citem_ver_id     => px_citem_ver_id
        ,p_ctype_code       => p_ctype_code
        ,p_language         => lang
        ,x_return_status    => x_return_status
        ,x_item_command     => do_item
        ,x_version_command  => do_version
        ,x_base_lang        => base_lang
    );
-- --------------------------------------------------------------------

  --DBMS_OUTPUT.put_line('Item command = '|| do_item);
  --DBMS_OUTPUT.put_line('Version command = '|| do_version);


    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

-- VALIDATION OF INPUT VALUES ------------------------------------------

      -------------------------------------
      -- VALIDATION -----------------------
      -------------------------------------
        -- content item name
        IF (p_citem_name IS NULL) THEN
            --DBMS_OUTPUT.put_line('EX - citem_name');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'IBC_INPUT_REQUIRED');
            FND_MESSAGE.Set_Token('INPUT', 'p_citem_name', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (LENGTH(p_citem_name) > 240) THEN
            --DBMS_OUTPUT.put_line('EX - citem_name');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_citem_name', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- directory nodes
        IF ( (p_dir_node_id <> Ibc_Utilities_Pub.G_COMMON_DIR_NODE) AND
             (p_dir_node_id <> FND_API.G_MISS_NUM) AND
             (IBC_VALIDATE_PVT.isValidDirNode(p_dir_node_id) = FND_API.g_false) ) THEN
            --DBMS_OUTPUT.put_line('EX - dir_node_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_dir_node_id', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- p_status
        IF (IBC_VALIDATE_PVT.isValidStatus(p_status) = FND_API.g_false) THEN
            --DBMS_OUTPUT.put_line('EX - p_status');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_status', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- content item description
        IF ( (p_citem_description IS NOT NULL) AND (p_citem_description <> FND_API.G_MISS_CHAR) AND (LENGTH(p_citem_description) > 2000) )THEN
            --DBMS_OUTPUT.put_line('EX - citem_description');
            x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_citem_description', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- reference code
        IF ( (p_reference_code <> FND_API.G_MISS_CHAR) AND (p_reference_code IS NOT NULL) AND (LENGTH(p_reference_code) > 100) )THEN
            --DBMS_OUTPUT.put_line('EX - reference_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_reference_code', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- p_trans_required
        IF (IBC_VALIDATE_PVT.isBoolean(p_trans_required) = FND_API.g_false) THEN
            --DBMS_OUTPUT.put_line('EX - p_trans req');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_trans_required', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- parent item id
        IF ( (p_parent_item_id <> FND_API.g_miss_num) AND (IBC_VALIDATE_PVT.isValidCitem(p_parent_item_id) = FND_API.g_false)) THEN
            --DBMS_OUTPUT.put_line('EX - parent item id');
            x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_parent_item_id', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- p_lock_flag
        IF (IBC_VALIDATE_PVT.isBoolean(p_lock_flag) = FND_API.g_false) THEN
            --DBMS_OUTPUT.put_line('EX - p_lock_flag');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_lock_flag', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- p_wd_restricted
        IF (IBC_VALIDATE_PVT.isBoolean(p_wd_restricted) = FND_API.g_false) THEN
            --DBMS_OUTPUT.put_line('EX - p_wd_restricted');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'p_wd_restricted', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Validating uniqueness for item_reference_code
        IF exist_item_reference_code(p_reference_code, px_content_item_id) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('IBC', 'IBC_DUPLICATE_ITEM_REF_CODE');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

	    -- resource id
	    IF ( (p_owner_resource_id IS NOT NULL) AND
		 (p_owner_resource_id <> FND_API.G_MISS_NUM) )
	    THEN
		p_new_owner_resource_id := p_owner_resource_id;

	       IF (p_owner_resource_type IS NULL OR
		   p_owner_resource_type = FND_API.G_MISS_CHAR) THEN
		   p_new_owner_resource_type := 'USER';
	       ELSE
		   p_new_owner_resource_type := p_owner_resource_type;
	       END IF;
	    ELSE  -- user does not pass resource_id default to login user id
		 p_new_owner_resource_id   := FND_GLOBAL.user_id;
		 p_new_owner_resource_type := 'USER';
	    END IF;


           IF (IBC_VALIDATE_PVT.isValidResource(p_new_owner_resource_id,p_new_owner_resource_type) = FND_API.g_false) THEN
              --DBMS_OUTPUT.put_line('EX - invalid resource id');
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
	      FND_MESSAGE.Set_Token('INPUT', 'p_owner_resource_id/p_owner_resource_type<' || p_new_owner_resource_id||':'||p_new_owner_resource_type||'>', FALSE);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
            END IF;


        -- Default rendition
        IF (p_default_rendition IS NOT NULL AND
            p_item_renditions IS NOT NULL AND
            p_default_rendition > p_item_renditions.COUNT)
            OR
            (p_default_rendition IS NOT NULL AND
             p_item_renditions IS NULL OR
             p_default_rendition < 1)
        THEN
          --DBMS_OUTPUT.put_line('EX - invalid default rendition');
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
          FND_MESSAGE.Set_Token('INPUT', 'p_default_rendition', FALSE);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- setting locked_by info
        IF (p_lock_flag = FND_API.g_true) THEN
            locked_by := FND_GLOBAL.user_id;
        ELSE
            locked_by := NULL;
        END IF;

-- --------------------------------------------------------------------



-- MAIN CONTENT ITEM ADJUSTMENTS --------------------------------------

        -- INSERT -----------------------------------------------------
        IF (do_item = G_COMMAND_CREATE) THEN
             -- ***************PERMISSION CHECK*********************************************************************
             IF( IBC_DATA_SECURITY_PVT.has_permission(                                                          --|*|
                         p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')    --|*|
                         ,p_instance_pk1_value    => NULL                                                       --|*|
                         ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                         ,p_container_pk1_value   => directory_node                                            --|*|
                         ,p_permission_code       => 'CITEM_EDIT'                                               --|*|
                         ,p_current_user_id       => FND_GLOBAL.user_id                                         --|*|
                         ) = FND_API.g_false                                                                    --|*|
                   ) THEN                                                                                       --|*|
                  --DBMS_OUTPUT.put_line('EX - no permissions');                                                --|*|
                  x_return_status := FND_API.G_RET_STS_ERROR;                                                   --|*|
                   FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                         --|*|
                  FND_MSG_PUB.ADD;                                                                              --|*|
                  RAISE FND_API.G_EXC_ERROR;                                                                    --|*|
               END IF;                                                                                            --|*|
               -- ***************PERMISSION CHECK*********************************************************************

            --DBMS_OUTPUT.put_line('ITEM - INSERT ROW');
             Ibc_Content_Items_Pkg.insert_row(
                x_ROWID                 => row_id
                ,px_CONTENT_ITEM_ID     => px_content_item_id
                ,p_CONTENT_TYPE_CODE    => p_ctype_code
                ,p_ITEM_REFERENCE_CODE  => p_reference_code
                ,p_DIRECTORY_NODE_ID    => directory_node
                ,p_LIVE_CITEM_VERSION_ID => NULL
                ,p_CONTENT_ITEM_STATUS  => Ibc_Utilities_Pub.G_STI_PENDING
                ,p_LOCKED_BY_USER_ID    => locked_by
                ,p_WD_RESTRICTED_FLAG   => p_wd_restricted
                ,p_BASE_LANGUAGE        => lang
                ,p_TRANSLATION_REQUIRED_FLAG => p_trans_required
                ,p_OWNER_RESOURCE_ID    => p_new_owner_resource_id
                ,p_OWNER_RESOURCE_TYPE  => p_new_owner_resource_type
                ,p_APPLICATION_ID       => NULL
                ,p_PARENT_ITEM_ID       => p_parent_item_id
                ,p_REQUEST_ID           => NULL
                ,p_object_version_number => px_object_version_number
            );

            IF(p_log_action = FND_API.g_true) THEN
                                       --***************************************************
                                       --************ADDING TO AUDIT LOG********************
                                       --***************************************************
                                       Ibc_Utilities_Pvt.log_action(
                                           p_activity       => Ibc_Utilities_Pvt.G_ALA_CREATE
                                           ,p_parent_value  => NULL
                                           ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                           ,p_object_value1 => px_content_item_id
                                           ,p_object_value2 => NULL
                                           ,p_object_value3 => NULL
                                           ,p_object_value4 => NULL
                                           ,p_object_value5 => NULL
                                           ,p_description   => 'Creating new content item with upsert api'
                                       );
                                       --***************************************************
            END IF;
        END IF;


        -- UPDATE -----------------------------------------------------
        IF (do_item IN (G_COMMAND_UPDATE,G_COMMAND_POST_APPROVAL_UPDATE)) THEN
             -- ***************PERMISSION CHECK*********************************************************************
             IF (hasPermission(px_content_item_id) = FND_API.g_false) THEN                                     --|*|
                 --DBMS_OUTPUT.put_line('EX - no lock permissions');                                             --|*|
                 x_return_status := FND_API.G_RET_STS_ERROR;                                                   --|*|
                 FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                       --|*|
                 FND_MSG_PUB.ADD;                                                                              --|*|
                 RAISE FND_API.G_EXC_ERROR;                                                                    --|*|                                                                 --|*|
             END IF;                                                                                           --|*|
             -- ***************PERMISSION CHECK*********************************************************************

            --DBMS_OUTPUT.put_line('ITEM - UPDATE ROW');
            Ibc_Content_Items_Pkg.update_row(
                p_CONTENT_ITEM_ID            => px_content_item_id
                ,p_ITEM_REFERENCE_CODE       => Conv_To_TblHandler(p_reference_code) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,p_DIRECTORY_NODE_ID         => Conv_To_TblHandler(directory_node) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,p_LOCKED_BY_USER_ID         => Conv_To_TblHandler(locked_by) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,p_WD_RESTRICTED_FLAG        => Conv_To_TblHandler(p_wd_restricted) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,p_TRANSLATION_REQUIRED_FLAG => Conv_To_TblHandler(p_trans_required) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,p_OWNER_RESOURCE_ID         => Conv_To_TblHandler(p_new_owner_resource_id) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,p_OWNER_RESOURCE_TYPE        => Conv_To_TblHandler(p_new_owner_resource_type) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,p_PARENT_ITEM_ID            => Conv_To_TblHandler(p_parent_item_id) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,px_object_version_number    => px_object_version_number
              );

            --DBMS_OUTPUT.put_line('ITEM - ROW UPDATED');

            IF(p_log_action = FND_API.g_true) THEN
                                       --***************************************************
                                       --************ADDING TO AUDIT LOG********************
                                       --***************************************************
                                       Ibc_Utilities_Pvt.log_action(
                                           p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                           ,p_parent_value  => NULL
                                           ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
                                           ,p_object_value1 => px_content_item_id
                                           ,p_object_value2 => NULL
                                           ,p_object_value3 => NULL
                                           ,p_object_value4 => NULL
                                           ,p_object_value5 => NULL
                                           ,p_description   => 'Updating content item with upsert api'
                                       );
                                       --***************************************************
            END IF;
         END IF;
    END IF;
-- --------------------------------------------------------------------

 --
 -- There is no way to delete all the renditions. This may not be the best way
 -- to achive this solution, when u pass a NULL all the renditions will be deleted
 -- If u don't want to do anything with the rendition then u must query and pass
 -- the rendition object back as it exists in the database.
 -- this was added to solve the Bug#
 -- Addition of this code snippet will not have any problem with our UI as we always
 -- requery and pass the same rendition object back.
 -- srrangar added
 --
  IF ((p_item_renditions IS NULL) AND
     (do_version <> G_COMMAND_POST_APPROVAL_UPDATE)) THEN

    -- Delete all existing renditions
    DELETE FROM ibc_renditions
    WHERE citem_version_id = px_citem_ver_id
    AND LANGUAGE = lang;

 END IF;
 --
 -- End of the code snippet.
 --


  -----------------------------------------------------------------
    -- Default Attachment/Rendition logic and Validation ------------
    -----------------------------------------------------------------
  IF ((p_item_renditions IS NOT NULL) AND
     (do_version <> G_COMMAND_POST_APPROVAL_UPDATE)) THEN

    -- Delete existing renditions
    DELETE FROM ibc_renditions
     WHERE citem_version_id = px_citem_ver_id
       AND LANGUAGE = lang;

    FOR I IN 1..p_item_renditions.COUNT LOOP
      IF (IBC_VALIDATE_PVT.isValidAttachment(p_item_renditions(I)) = FND_API.g_false) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_item_renditions', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF I = NVL(p_default_rendition, 1) THEN
        OPEN c_lob(p_item_renditions(I));
        FETCH c_lob INTO l_dummy_attach_file_name, l_attach_rendition_mtype;
        CLOSE c_lob;
        l_attach_rendition_mtype := GET_MIME_TYPE(l_attach_rendition_mtype);
      END IF;
    END LOOP;
  END IF;

  IF ((p_attach_file_id IS NOT NULL) AND
      (do_version <> G_COMMAND_POST_APPROVAL_UPDATE)) THEN

    IF (IBC_VALIDATE_PVT.isValidAttachment(p_attach_file_id) = FND_API.g_false) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
      FND_MESSAGE.Set_Token('INPUT', 'p_attach_file_id', FALSE);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    attach_code := getAttachAttribCode(px_content_item_id);
    IF ( attach_code IS NULL) THEN
      --DBMS_OUTPUT.put_line('EX - attachment attribute code');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'INVALID_ATTACH_ATTR_TYPE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_lob(p_attach_file_id);
    FETCH c_lob INTO l_attach_file_name, l_dummy_attach_rendition_mtype;
    CLOSE c_lob;

  END IF;

    -------------------------------------
    -- ATTRIBUTE BUNDLE -----------------
    -------------------------------------
    -- determine if there is an attribute bundle or not and if this action should be taken at all
    IF ( (p_attribute_type_codes IS NOT NULL) AND
	 (p_attributes IS NOT NULL) AND
	 (x_return_status = FND_API.G_RET_STS_SUCCESS) AND
	 (do_version <> G_COMMAND_POST_APPROVAL_UPDATE) ) THEN
        -- creating temporary lob
        DBMS_LOB.createtemporary(bundle_text, TRUE, 2);
        create_attribute_bundle(
            px_attribute_bundle     => bundle_text
            ,p_attribute_type_codes => p_attribute_type_codes
            ,p_attributes           => p_attributes
            ,p_ctype_code           => p_ctype_code
            ,x_return_status        => x_return_status
        );
        --**************** STORING INFO TO DB ***********
        -- Inserting temp lob into fnd_lobs
        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

            -- adding data to fnd_lobs
            Ibc_Utilities_Pvt.insert_attribute_bundle(
                x_lob_file_id       => bundle_file_id
                ,p_new_bundle         => bundle_text
                ,x_return_status    => x_return_status
            );

            -- raise exception if error occured while in utilities procedure
            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                --DBMS_OUTPUT.put_line('EX - inserting attribute bundle');
                x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_ERROR');
                FND_MESSAGE.set_token('SITUATION', 'Insertion');
                FND_MSG_PUB.ADD;
            END IF;
        ELSE
            --DBMS_OUTPUT.put_line('EX - creating attribute bundle');
            x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('IBC', 'A_BUNDLE_ERROR');
            FND_MESSAGE.set_token('SITUATION', 'Creation');
            FND_MSG_PUB.ADD;
        END IF;
    -- no attributes given
    ELSE
        bundle_file_id := NULL;
    END IF;


IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN


-- MAIN VERSION ADJUSTMENTS -------------------------------------------

        -- INCREMENT -----------------------------------------------------
        IF (do_version = G_COMMAND_INCREMENT) THEN
            current_version := getMaxVersion(px_content_item_id) + 1;
        END IF;


        -- INSERT -----------------------------------------------------
        IF ( (do_version = G_COMMAND_CREATE) OR (do_version = G_COMMAND_INCREMENT) ) THEN
            -- inserting new row into ibc_citem_versions

            --DBMS_OUTPUT.put_line('VERSION - INSERT BASE LANG');

        -- ****RENDITIONS_WORK****
            Ibc_Citem_Versions_Pkg.insert_base_lang(
                X_ROWID                        => row_id
                ,PX_CITEM_VERSION_ID           => px_citem_ver_id
                ,P_CONTENT_ITEM_ID             => px_content_item_id
                ,P_VERSION_NUMBER              => current_version
                ,P_CITEM_VERSION_STATUS        => bulk_status
                ,P_START_DATE                  => p_start_date
                ,P_END_DATE                    => p_end_date
                ,P_ATTRIBUTE_FILE_ID           => bundle_file_id
                ,P_ATTACHMENT_FILE_ID          => p_attach_file_id
                ,P_ATTACHMENT_FILE_NAME        => l_attach_file_name
                ,P_DEFAULT_RENDITION_MIME_TYPE => l_attach_rendition_mtype
                ,P_ATTACHMENT_ATTRIBUTE_CODE   => attach_code
                ,P_SOURCE_LANG                 => lang
                ,P_CONTENT_ITEM_NAME           => p_citem_name
                ,P_DESCRIPTION                 => p_citem_description
                ,PX_OBJECT_VERSION_NUMBER      => px_object_version_number
            );
            IF(p_log_action = FND_API.g_true) THEN
                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_CREATE
                                       ,p_parent_value  => px_content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => px_citem_ver_id
                                       ,p_object_value2 => lang
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Creating new content item version with upsert api'
                                   );
                                   --***************************************************
            END IF;
        END IF;

        IF (do_version = G_COMMAND_TRANSLATE) AND
           getAttribFID(px_citem_ver_id, base_lang) <> getAttribFID(px_citem_ver_id, lang)
        THEN
            x_return_status := deleteAttributeBundle(
                                    f_citem_ver_id  => px_citem_ver_id
                                    ,f_language     => lang
                                    ,f_log_action   => p_log_action
                               );
        END IF;


        --
	-- BEGIN UPDATE OF CONTENT VERSION -----------------------------------------
	--
        IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND
             (do_version IN (G_COMMAND_UPDATE,G_COMMAND_TRANSLATE))) THEN

            -- set type of permission check
            IF (do_version = G_COMMAND_TRANSLATE) THEN
		perm_code.extend;
		perm_code(1) := 'CITEM_TRANSLATE';
               bulk_status := Fnd_Api.G_MISS_CHAR;
            ELSE
               perm_code.extend;
	       perm_code(1) := 'CITEM_EDIT';
            END IF;


             -- ***************PERMISSION CHECK*********************************************************************
             IF(isItemAdmin(px_content_item_id) = FND_API.g_false) THEN                                         --|*|
                IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                           p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                           ,p_instance_pk1_value    => px_content_item_id                                       --|*|
                           ,p_permission_code       => perm_code(1)                                                --|*|
                           ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                           ,p_container_pk1_value   => directory_node                                           --|*|
                           ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                           ) = FND_API.g_false                                                                  --|*|
                     ) THEN                                                                                     --|*|
                    --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
                    x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
                   FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
                    FND_MSG_PUB.ADD;                                                                            --|*|
                    RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
               END IF;                                                                                          --|*|
             END IF;                                                                                            --|*|
             -- ***************PERMISSION CHECK*********************************************************************

            --DBMS_OUTPUT.put_line('VERSION - UPDATE ROW');
            -- updating row in ibc_citem_versions
        -- ****RENDITIONS_WORK****
            Ibc_Citem_Versions_Pkg.update_row(
                P_CITEM_VERSION_ID             => px_citem_ver_id
                ,P_CONTENT_ITEM_ID             => px_content_item_id
                ,P_SOURCE_LANG                 => lang
                ,P_CITEM_VERSION_STATUS        => Conv_To_TblHandler(bulk_status) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_START_DATE                  => Conv_To_TblHandler(p_start_date) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_END_DATE                    => Conv_To_TblHandler(p_end_date) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_ATTRIBUTE_FILE_ID           => Conv_To_TblHandler(bundle_file_id) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_ATTACHMENT_FILE_ID          => Conv_To_TblHandler(p_attach_file_id) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_ATTACHMENT_FILE_NAME        => Conv_To_TblHandler(l_attach_file_name) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_DEFAULT_RENDITION_MIME_TYPE => Conv_To_TblHandler(l_attach_rendition_mtype) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_ATTACHMENT_ATTRIBUTE_CODE   => Conv_To_TblHandler(attach_code) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_CONTENT_ITEM_NAME           => Conv_To_TblHandler(p_citem_name) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_DESCRIPTION                 => Conv_To_TblHandler(p_citem_description) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,PX_OBJECT_VERSION_NUMBER      => px_object_version_number
            );
            IF(p_log_action = FND_API.g_true) THEN
                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => px_content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => px_citem_ver_id
                                       ,p_object_value2 => lang
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Updating content item version with upsert api'
                                   );
                                   --***************************************************
            END IF;
        END IF;	-- END UPDATE OF CONTENT VERSION -----------------------------------------

        --
	-- BEGIN UPDATE POST APPROVAL OF VERSION -----------------------------------------
	--
        IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND
             (do_version IN (G_COMMAND_POST_APPROVAL_UPDATE))) THEN

            -- set type of permission check
            IF (do_version = G_COMMAND_POST_APPROVAL_UPDATE) THEN
               perm_code.extend;
	       perm_code(1) := 'CITEM_EDIT';
	       perm_code.extend;
	       perm_code(2) := 'CITEM_APPROVE';
            END IF;


	     -- For Update post approval user must have Edit as well
	     -- as approve permission
	     --
	     FOR i IN perm_code.FIRST..perm_code.LAST
	     LOOP
             -- ***************PERMISSION CHECK*********************************************************************
            -- IF(isItemAdmin(px_content_item_id) = FND_API.g_false) THEN                                         --|*|
                IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                           p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                           ,p_instance_pk1_value    => px_content_item_id                                       --|*|
                           ,p_permission_code       => perm_code(i)                                                --|*|
                           ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                           ,p_container_pk1_value   => directory_node                                           --|*|
                           ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                           ) = FND_API.g_false                                                                  --|*|
                     ) THEN                                                                                     --|*|
                    --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
                    x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
                    IF ( perm_code(i) = 'CITEM_EDIT')  THEN                                                     --|*|
			FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                 --|*|
		    END IF;                                                                                     --|*|
                    IF ( perm_code(i) = 'CITEM_APPROVE')  THEN                                                  --|*|
			FND_MESSAGE.Set_Name('IBC', 'NO_APPROVE_ITEM_PRIV');                                    --|*|
		    END IF;                                                                                     --|*|
														--|*|
		    FND_MSG_PUB.ADD;                                                                            --|*|
                    RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
               END IF;                                                                                          --|*|
            -- END IF;                                                                                          --|*|
             -- ***************PERMISSION CHECK*********************************************************************
	     END LOOP;

            --DBMS_OUTPUT.put_line('VERSION - UPDATE POST APPROVAL ROW');
            --updating row in ibc_citem_versions
            Ibc_Citem_Versions_Pkg.update_row(
                P_CITEM_VERSION_ID             => px_citem_ver_id
                ,P_CONTENT_ITEM_ID             => px_content_item_id
                ,P_SOURCE_LANG                 => lang
                ,P_CONTENT_ITEM_NAME           => Conv_To_TblHandler(p_citem_name) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,P_DESCRIPTION                 => Conv_To_TblHandler(p_citem_description) -- Updated for STANDARD/perf change of G_MISS_xxx
                ,PX_OBJECT_VERSION_NUMBER      => px_object_version_number
            );
            IF(p_log_action = FND_API.g_true) THEN
                                   --***************************************************
                                   --************ADDING TO AUDIT LOG********************
                                   --***************************************************
                                   Ibc_Utilities_Pvt.log_action(
                                       p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
                                       ,p_parent_value  => px_content_item_id
                                       ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
                                       ,p_object_value1 => px_citem_ver_id
                                       ,p_object_value2 => lang
                                       ,p_object_value3 => NULL
                                       ,p_object_value4 => NULL
                                       ,p_object_value5 => NULL
                                       ,p_description   => 'Updating of content item version post approval with upsert api'
                                   );
                                   --***************************************************
            END IF;
        END IF;	-- END UPDATE POST APPROVAL OF VERSION ----------------------------------
    END IF;
-- --------------------------------------------------------------------

  -- Renditions -------
  IF (p_item_renditions IS NOT NULL AND
     do_version <> G_COMMAND_POST_APPROVAL_UPDATE) THEN
    -- Insert all renditions
    FOR I IN 1..p_item_renditions.COUNT LOOP

      -- The default rendition will be handle by IBC_CIEM_VERSIONS_PKG
      -- Here only the non-default renditions will be inserted.
      OPEN c_lob(p_item_renditions(I));
      FETCH c_lob INTO l_attach_file_name, l_attach_rendition_mtype;
      CLOSE c_lob;
      l_attach_rendition_mtype := GET_MIME_TYPE(l_attach_rendition_mtype);

      l_rendition_id := NULL;
      IBC_RENDITIONS_PKG.insert_row(
        Px_rowid                   => row_id
        ,Px_RENDITION_ID          => l_rendition_id
        ,p_object_version_number => G_OBJ_VERSION_DEFAULT
        ,P_LANGUAGE                 => lang
        ,P_FILE_ID                 => p_item_renditions(I)
        ,P_FILE_NAME               => l_attach_file_name
        ,P_CITEM_VERSION_ID       => px_citem_ver_id
        ,P_MIME_TYPE                => l_attach_rendition_mtype
      );

    END LOOP;
  END IF;

    ----------------------------------
    -- COMPONENT ITEMS ---------------
    ----------------------------------
   IF ( (p_component_citems IS NOT NULL) AND (p_component_atypes IS NOT NULL) AND
        (p_component_citems.COUNT > 0) AND (p_component_atypes.COUNT > 0) AND
        (x_return_status = FND_API.G_RET_STS_SUCCESS) ) THEN
      --DBMS_OUTPUT.put_line('COMPONENTS');
      IF ( (do_version = G_COMMAND_UPDATE) AND (p_update = FND_API.g_true) ) THEN
      --delete all components before adding new ones!
      --DBMS_OUTPUT.put_line('DELETING OLD COMPONENTS');
         DELETE FROM
            ibc_compound_relations
         WHERE
            citem_version_id = px_citem_ver_id;
      END IF;

      IF (do_version <> G_COMMAND_TRANSLATE AND
	  do_version <> G_COMMAND_POST_APPROVAL_UPDATE	AND
          p_component_citems(1) <> 0) THEN
         -- translations cannot update components.
         insert_component_items_int(
            p_citem_ver_id          => px_citem_ver_id
            ,p_content_item_id      => px_content_item_id
            ,p_content_item_ids     => p_component_citems
            ,p_citem_ver_ids        => p_component_citem_ver_ids
            ,p_attribute_type_codes => p_component_atypes
            ,p_ctype_code           => p_ctype_code
            ,p_sort_order           => p_sort_order
            ,p_log_action           => p_log_action
            ,x_return_status      => x_return_status
         );
      END IF;
    END IF;

  ----------------------------------
  -- Content Item Keywords ---------
  ----------------------------------
  -- It will always remove the existing keywords and then insert the new ones
  -- On Update
  IF ((do_version IN (G_COMMAND_UPDATE,G_COMMAND_POST_APPROVAL_UPDATE)) AND
     (p_update = FND_API.g_true) ) THEN
    DELETE
      FROM ibc_citem_keywords
     WHERE content_item_id = px_content_item_id;
  END IF;

   IF ( (p_keywords IS NOT NULL)
         AND
         (x_return_status = FND_API.G_RET_STS_SUCCESS)
      )
      THEN
     FOR I IN 1..p_keywords.COUNT LOOP
       IBC_CITEM_KEYWORDS_PKG.insert_row(
         x_rowid                  => row_id
         ,p_content_item_id       => px_content_item_id
         ,p_keyword               => p_keywords(I)
         ,p_object_version_number => 1
       );
     END LOOP;
   END IF;



    -------------------------------------
    -- APPROVE --------------------------
    -------------------------------------
    IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND
	 (p_status = Ibc_Utilities_Pub.G_STV_APPROVED) AND
	 (do_version NOT IN (G_COMMAND_TRANSLATE,G_COMMAND_POST_APPROVAL_UPDATE))) THEN
        approve_citem_version_int(
            p_citem_ver_id              => px_citem_ver_id
            ,p_content_item_id          => px_content_item_id
            ,p_base_lang                => base_lang
            ,p_log_action               => p_log_action
            ,px_object_version_number   => px_object_version_number
            ,x_return_status            => x_return_status
        );
    END IF;

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

    ---------------------------------------
    -- SEND NOTIFICATIONS TO TRANSLATOR---
    ---------------------------------------
    IF ((p_trans_required = FND_API.g_true) AND (x_return_status = FND_API.G_RET_STS_SUCCESS) AND
	 (do_version = G_COMMAND_POST_APPROVAL_UPDATE)) THEN
       IBC_CITEM_WORKFLOW_PVT.Notify_Translator(p_content_item_id  => px_content_item_id );
    END IF;


    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );




    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'End Upsert_Item_Full',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_32767(
                                          'p_ctype_code', p_ctype_code,
                                          'p_citem_name', p_citem_name,
                                          'p_citem_description', p_citem_description,
                                          'p_dir_node_id', p_dir_node_id,
                                          'p_owner_resource_id', p_owner_resource_id,
                                          'p_owner_resource_type', p_owner_resource_type,
                                          'p_reference_code', p_reference_code,
                                          'p_trans_required', p_trans_required,
                                          'p_parent_item_id', p_parent_item_id,
                                          'p_lock_flag', p_lock_flag,
                                          'p_wd_restricted', p_wd_restricted,
                                          'p_start_date', TO_CHAR(p_start_date, 'YYYYMMDD HH24:MI:SS'),
                                          'p_end_date',   TO_CHAR(p_end_date, 'YYYYMMDD HH24:MI:SS'),
                                          'p_attribute_type_codes', IBC_DEBUG_PVT.make_list(p_attribute_type_codes),
                                          'p_attributes', IBC_DEBUG_PVT.make_list_VC32767(p_attributes),
                                          'p_attach_file_id', p_attach_file_id,
                                          'p_item_renditions', IBC_DEBUG_PVT.make_list(p_item_renditions),
                                          'p_default_rendition', p_default_rendition,
                                          'p_component_citems', IBC_DEBUG_PVT.make_list(p_component_citems),
                                          'p_component_citem_ver_ids', IBC_DEBUG_PVT.make_list(p_component_citem_Ver_ids),
                                          'p_component_atypes', IBC_DEBUG_PVT.make_list(p_component_atypes),
                                          'p_sort_order', IBC_DEBUG_PVT.make_list(p_sort_order),
                                          'p_keywords', IBC_DEBUG_PVT.make_list(p_keywords),
                                          'p_status', p_status,
                                          'p_log_action', p_log_action,
                                          'p_language', p_language,
                                          'p_update', p_update,
                                          'p_commit', p_commit,
                                          'p_api_version_number', p_api_version_number,
                                          'p_init_msg_list', p_init_msg_list,
                                          'px_content_item_id', px_content_item_id,
                                          'px_citem_ver_id', px_citem_ver_id,
                                          'px_object_version_number', px_object_version_number
                                        )
                           )
      );
    END IF;


    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'px_content_item_id', px_content_item_id,
                        'px_citem_ver_id', px_citem_ver_id,
                        'px_object_version_number', px_object_version_number,
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_upsert_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_upsert_item;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_upsert_item;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END upsert_item_full;

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
--  Overloaded - for backwards compatibility support of 4K limit
--               for attr values
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
      p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_id            IN NUMBER
       ,p_item_renditions           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_citem_ver_ids   IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_keywords                  IN JTF_VARCHAR2_TABLE_100
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
)IS
  l_tmp_attributes   JTF_VARCHAR2_TABLE_32767;
BEGIN

  IF p_attributes IS NOT NULL AND p_attributes.COUNT > 0 THEN
    l_tmp_attributes := JTF_VARCHAR2_TABLE_32767();
    l_tmp_attributes.extend(p_attributes.COUNT);
    FOR I IN 1..p_attributes.COUNT LOOP
      l_tmp_attributes(I) := p_attributes(I);
    END LOOP;
  END IF;

  upsert_item_full(
        p_ctype_code                => p_ctype_code
       ,p_citem_name                => p_citem_name
       ,p_citem_description         => p_citem_description
       ,p_dir_node_id               => p_dir_node_id
       ,p_owner_resource_id         => p_owner_resource_id
       ,p_owner_resource_type       => p_owner_resource_type
       ,p_reference_code            => p_reference_code
       ,p_trans_required            => p_trans_required
       ,p_parent_item_id            => p_parent_item_id
       ,p_lock_flag                 => p_lock_flag
       ,p_wd_restricted             => p_wd_restricted
       ,p_start_date                => p_start_date
       ,p_end_date                  => p_end_date
       ,p_attribute_type_codes      => p_attribute_type_codes
       ,p_attributes                => l_tmp_attributes
       ,p_attach_file_id            => p_attach_file_id
       ,p_item_renditions           => p_item_renditions
       ,p_default_rendition         => p_default_rendition
       ,p_component_citems          => p_component_citems
       ,p_component_citem_ver_ids   => p_component_citem_ver_ids
       ,p_component_atypes          => p_component_atypes
       ,p_sort_order                => p_sort_order
       ,p_keywords                  => p_keywords
       ,p_status                    => p_status
       ,p_log_action                => p_log_action
       ,p_language                  => p_language
       ,p_update                    => p_update
       ,p_commit                    => p_commit
       ,p_api_version_number        => p_api_version_number
       ,p_init_msg_list             => p_init_msg_list
       ,px_content_item_id          => px_content_item_id
       ,px_citem_ver_id             => px_citem_ver_id
       ,px_object_version_number    => px_object_version_number
       ,x_return_status             => x_return_status
       ,x_msg_count                 => x_msg_count
       ,x_msg_data                  => x_msg_data
  );

-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END upsert_item_full;

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
--  Overloaded - Backwards compatible for "old" attachment renditions
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
      p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_ids           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_citem_ver_ids   IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_keywords                  IN JTF_VARCHAR2_TABLE_100
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
) IS
   l_attach_file_id  NUMBER;
BEGIN
  IF p_attach_file_ids IS NOT NULL THEN
    l_attach_file_id := p_attach_file_ids(1);
  END IF;
  upsert_item_full(
     p_ctype_code                 => p_ctype_code
    ,p_citem_name                => p_citem_name
    ,p_citem_description         => p_citem_description
    ,p_dir_node_id               => p_dir_node_id
    ,p_owner_resource_id         => p_owner_resource_id
    ,p_owner_resource_type       => p_owner_resource_type
    ,p_reference_code            => p_reference_code
    ,p_trans_required            => p_trans_required
    ,p_parent_item_id            => p_parent_item_id
    ,p_lock_flag                 => p_lock_flag
    ,p_wd_restricted             => p_wd_restricted
    ,p_start_date                => p_start_date
    ,p_end_date                  => p_end_date
    ,p_attribute_type_codes      => p_attribute_type_codes
    ,p_attributes                => p_attributes
    ,p_attach_file_id            => l_attach_file_id
    ,p_item_renditions           => NULL
    ,p_default_rendition         => NULL
    ,p_component_citems          => p_component_citems
    ,p_component_citem_ver_ids   => p_component_citem_ver_ids
    ,p_component_atypes          => p_component_atypes
    ,p_sort_order                => p_sort_order
    ,p_keywords                  => p_keywords
    ,p_status                    => p_status
    ,p_log_action                => p_log_action
    ,p_language                  => p_language
    ,p_update                    => p_update
    ,p_commit                    => p_commit
    ,p_api_version_number        => p_api_version_number
    ,p_init_msg_list             => p_init_msg_list
    ,px_content_item_id          => px_content_item_id
    ,px_citem_ver_id             => px_citem_ver_id
    ,px_object_version_number    => px_object_version_number
    ,x_return_status             => x_return_status
    ,x_msg_count                 => x_msg_count
    ,x_msg_data                  => x_msg_data
  );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END upsert_item_full;

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
-- Overloaded - No access to keywords
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
      p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_ids           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_citem_ver_ids   IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
)IS
BEGIN
  upsert_item_full(
      p_ctype_code                 => p_ctype_code
     ,p_citem_name                => p_citem_name
     ,p_citem_description         => p_citem_description
     ,p_dir_node_id               => p_dir_node_id
     ,p_owner_resource_id         => p_owner_resource_id
     ,p_owner_resource_type       => p_owner_resource_type
     ,p_reference_code            => p_reference_code
     ,p_trans_required            => p_trans_required
     ,p_parent_item_id            => p_parent_item_id
     ,p_lock_flag                 => p_lock_flag
     ,p_wd_restricted             => p_wd_restricted
     ,p_start_date                => p_start_date
     ,p_end_date                  => p_end_date
     ,p_attribute_type_codes      => p_attribute_type_codes
     ,p_attributes                => p_attributes
     ,p_attach_file_ids           => p_attach_file_ids
     ,p_default_rendition         => p_default_rendition
     ,p_component_citems          => p_component_citems
     ,p_component_citem_ver_ids   => p_component_citem_ver_ids
     ,p_component_atypes          => p_component_atypes
     ,p_sort_order                => p_sort_order
     ,p_keywords                  => NULL
     ,p_status                    => p_status
     ,p_log_action                => p_log_action
     ,p_language                  => p_language
     ,p_update                    => p_update
     ,p_commit                    => p_commit
     ,p_api_version_number        => p_api_version_number
     ,p_init_msg_list             => p_init_msg_list
     ,px_content_item_id          => px_content_item_id
     ,px_citem_ver_id             => px_citem_ver_id
     ,px_object_version_number    => px_object_version_number
     ,x_return_status             => x_return_status
     ,x_msg_count                 => x_msg_count
     ,x_msg_data                  => x_msg_data
  );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END upsert_item_full;

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
-- Overloaded - No access to component subitem versions
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
      p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_ids           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
)IS
BEGIN
  upsert_item_full(
      p_ctype_code                 => p_ctype_code
     ,p_citem_name                => p_citem_name
     ,p_citem_description         => p_citem_description
     ,p_dir_node_id               => p_dir_node_id
     ,p_owner_resource_id         => p_owner_resource_id
     ,p_owner_resource_type       => p_owner_resource_type
     ,p_reference_code            => p_reference_code
     ,p_trans_required            => p_trans_required
     ,p_parent_item_id            => p_parent_item_id
     ,p_lock_flag                 => p_lock_flag
     ,p_wd_restricted             => p_wd_restricted
     ,p_start_date                => p_start_date
     ,p_end_date                  => p_end_date
     ,p_attribute_type_codes      => p_attribute_type_codes
     ,p_attributes                => p_attributes
     ,p_attach_file_ids           => p_attach_file_ids
     ,p_default_rendition         => p_default_rendition
     ,p_component_citems          => p_component_citems
     ,p_component_citem_ver_ids   => NULL
     ,p_component_atypes          => p_component_atypes
     ,p_sort_order                => p_sort_order
     ,p_status                    => p_status
     ,p_log_action                => p_log_action
     ,p_language                  => p_language
     ,p_update                    => p_update
     ,p_commit                    => p_commit
     ,p_api_version_number        => p_api_version_number
     ,p_init_msg_list             => p_init_msg_list
     ,px_content_item_id          => px_content_item_id
     ,px_citem_ver_id             => px_citem_ver_id
     ,px_object_version_number    => px_object_version_number
     ,x_return_status             => x_return_status
     ,x_msg_count                 => x_msg_count
     ,x_msg_data                  => x_msg_data
  );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END upsert_item_full;

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--  Wrapper - for no renditions use.
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
      p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_id            IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
) IS
   l_attach_file_ids           JTF_NUMBER_TABLE;
   l_default_rendition         NUMBER;
BEGIN
   --DBMS_OUTPUT.put_line('----- upsert_item -----');
   IF p_attach_file_id IS NOT NULL THEN
     l_attach_file_ids   := JTF_NUMBER_TABLE();
     l_attach_file_ids.extend;
     l_attach_file_ids(1) := p_attach_file_id;
     l_default_rendition := 1;
   END IF;
   upsert_item_full(
        p_ctype_code                 => p_ctype_code
       ,p_citem_name                => p_citem_name
       ,p_citem_description         => p_citem_description
       ,p_dir_node_id               => p_dir_node_id
       ,p_owner_resource_id         => p_owner_resource_id
       ,p_owner_resource_type       => p_owner_resource_type
       ,p_reference_code            => p_reference_code
       ,p_trans_required            => p_trans_required
       ,p_parent_item_id            => p_parent_item_id
       ,p_lock_flag                 => p_lock_flag
       ,p_wd_restricted             => p_wd_restricted
       ,p_start_date                => p_start_date
       ,p_end_date                  => p_end_date
       ,p_attribute_type_codes      => p_attribute_type_codes
       ,p_attributes                => p_attributes
       ,p_attach_file_ids           => l_attach_file_ids
       ,p_default_rendition         => l_default_rendition
       ,p_component_citems          => p_component_citems
       ,p_component_atypes          => p_component_atypes
       ,p_sort_order                => p_sort_order
       ,p_status                    => p_status
       ,p_log_action                => p_log_action
       ,p_language                  => p_language
       ,p_update                    => p_update
       ,p_commit                    => p_commit
       ,p_api_version_number        => p_api_version_number
       ,p_init_msg_list             => p_init_msg_list
       ,px_content_item_id          => px_content_item_id
       ,px_citem_ver_id             => px_citem_ver_id
       ,px_object_version_number    => px_object_version_number
       ,x_return_status             => x_return_status
       ,x_msg_count                 => x_msg_count
       ,x_msg_data                  => x_msg_data
   );
-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;


-- --------------------------------------------------------------
-- UPSERT ITEM
--
-- Just a wrapper for upsert_item_full
-- --------------------------------------------------------------
PROCEDURE upsert_item(
        p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_id            IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
)IS
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- upsert_item -----');
   upsert_item_full(
        p_ctype_code                 => p_ctype_code
       ,p_citem_name                => p_citem_name
       ,p_citem_description         => p_citem_description
       ,p_dir_node_id               => p_dir_node_id
       ,p_owner_resource_id         => p_owner_resource_id
       ,p_owner_resource_type       => p_owner_resource_type
       ,p_reference_code            => p_reference_code
       ,p_trans_required            => p_trans_required
       ,p_parent_item_id            => p_parent_item_id
       ,p_lock_flag                 => p_lock_flag
       ,p_wd_restricted             => p_wd_restricted
       ,p_start_date                => p_start_date
       ,p_end_date                  => p_end_date
       ,p_attribute_type_codes      => p_attribute_type_codes
       ,p_attributes                => p_attributes
       ,p_attach_file_id            => p_attach_file_id
       ,p_component_citems          => p_component_citems
       ,p_component_atypes          => p_component_atypes
       ,p_sort_order                => p_sort_order
       ,p_status                    => p_status
       ,p_log_action                => p_log_action
       ,p_language                  => p_language
       ,p_commit                    => p_commit
       ,p_api_version_number        => p_api_version_number
       ,p_init_msg_list             => p_init_msg_list
       ,px_content_item_id          => px_content_item_id
       ,px_citem_ver_id             => px_citem_ver_id
       ,px_object_version_number    => px_object_version_number
       ,x_return_status             => x_return_status
       ,x_msg_count                 => x_msg_count
       ,x_msg_data                  => x_msg_data
   );

-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
   RAISE;
END;

-- --------------------------------------------------------------
-- UPSERT ITEM
--
-- Just a wrapper for upsert_item_full
-- --------------------------------------------------------------
PROCEDURE upsert_item(
        p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_ids           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
)IS
BEGIN
                                                                    --DBMS_OUTPUT.put_line('----- upsert_item -----');
   upsert_item_full(
        p_ctype_code                 => p_ctype_code
       ,p_citem_name                => p_citem_name
       ,p_citem_description         => p_citem_description
       ,p_dir_node_id               => p_dir_node_id
       ,p_owner_resource_id         => p_owner_resource_id
       ,p_owner_resource_type       => p_owner_resource_type
       ,p_reference_code            => p_reference_code
       ,p_trans_required            => p_trans_required
       ,p_parent_item_id            => p_parent_item_id
       ,p_lock_flag                 => p_lock_flag
       ,p_wd_restricted             => p_wd_restricted
       ,p_start_date                => p_start_date
       ,p_end_date                  => p_end_date
       ,p_attribute_type_codes      => p_attribute_type_codes
       ,p_attributes                => p_attributes
       ,p_attach_file_ids           => p_attach_file_ids
       ,p_default_rendition         => p_default_rendition
       ,p_component_citems          => p_component_citems
       ,p_component_atypes          => p_component_atypes
       ,p_sort_order                => p_sort_order
       ,p_status                    => p_status
       ,p_log_action                => p_log_action
       ,p_language                  => p_language
       ,p_commit                    => p_commit
       ,p_api_version_number        => p_api_version_number
       ,p_init_msg_list             => p_init_msg_list
       ,px_content_item_id          => px_content_item_id
       ,px_citem_ver_id             => px_citem_ver_id
       ,px_object_version_number    => px_object_version_number
       ,x_return_status             => x_return_status
       ,x_msg_count                 => x_msg_count
       ,x_msg_data                  => x_msg_data
   );

-- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

-- --------------------------------------------------------------
-- HARD DELETE ITEM VERSIONS
--
-- --------------------------------------------------------------
PROCEDURE hard_delete_item_versions(
      p_api_version   IN NUMBER
      ,p_init_msg_list    IN VARCHAR2
      ,p_commit     IN VARCHAR2
      ,p_citem_version_ids  IN  JTF_NUMBER_TABLE
      ,x_return_status   OUT NOCOPY VARCHAR2
      ,x_msg_count   OUT NOCOPY NUMBER
      ,x_msg_data  OUT NOCOPY VARCHAR2
) AS
        --******** local variable for standards **********
 --******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'hard_delete_item_versions';--|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT;  --|**|
--******************* END REQUIRED VARIABLES ****************************
--
  l_citem_version_id  NUMBER;
  l_citem_version_status  IBC_CITEM_VERSIONS_B.citem_version_status%TYPE;
  l_citem_version_attr_id NUMBER;
  l_content_item_id NUMBER;
  l_directory_node_id NUMBER;

  l_tmp_content_item_id NUMBER;
  l_log_item_flag   VARCHAR2(1) := FND_API.g_false;
--
  CURSOR Get_Item_Version_Detail IS
     SELECT
        CITEM_VERSION_STATUS
        ,ATTRIBUTE_FILE_ID
     FROM
        IBC_CITEM_VERSIONS_VL
     WHERE
        CITEM_VERSION_ID = l_citem_version_id;

BEGIN
      --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
      -- ******************* Standard Begins *******************
      -- Standard Start of API savepoint
      SAVEPOINT HARD_DELETE_ITEM_VERSIONS_PT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
    l_api_version_number,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
      THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --******************* Real Logic Start *********************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Hard_Delete_Item_Versions',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_api_version', p_api_version,
                                          'p_init_msg_list', p_init_msg_list,
                                          'p_commit', p_commit,
                                          'p_citem_version_ids', IBC_DEBUG_PVT.make_list(p_citem_version_ids)
                                        )
                           )
      );
    END IF;

    FOR i IN 1..p_citem_version_ids.COUNT LOOP
           l_citem_version_id := p_citem_version_ids(i);
     OPEN Get_Item_Version_Detail;
     FETCH Get_Item_Version_Detail INTO l_citem_version_status, l_citem_version_attr_id;
     -- Check if content item version id is valid
     IF (Get_Item_Version_Detail%NOTFOUND) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
            FND_MESSAGE.Set_token('CITEM_VERSION_ID', l_citem_version_id);
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE Get_Item_Version_Detail;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE Get_Item_Version_Detail;

           -- error checking
     IF ( (l_citem_version_status = IBC_UTILITIES_PUB.G_STV_APPROVED) OR
        (l_citem_version_status = IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL) ) THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('IBC', 'INVALID_HARD_DELETE');
                FND_MESSAGE.Set_token('CITEM_VERSION_ID', l_citem_version_id);
                FND_MSG_PUB.ADD;
             END IF;
             -- possibly: not raising exception here, and raising it at end so full list of problematic items is created???
             RAISE FND_API.G_EXC_ERROR;
     END IF;

           l_tmp_content_item_id := getCitemId(l_citem_version_id);
     IF (l_tmp_content_item_id <> l_content_item_id) THEN
        l_content_item_id := l_tmp_content_item_id;
        l_log_item_flag := FND_API.g_true;

        l_directory_node_id := getDirectoryNodeId(l_content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(l_content_item_id) = FND_API.g_false) THEN                                       --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
       FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                        --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(l_content_item_id) = FND_API.g_false) THEN                                       --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => l_content_item_id                                        --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => l_directory_node_id                                      --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

     END IF; -- End checking if this version belongs to the same content item

    -- Delete version
    Ibc_Citem_Versions_Pkg.DELETE_ROW(l_citem_version_id);

    -- Delete Renditions
    DELETE FROM ibc_renditions WHERE citem_Version_id = l_citem_version_id;

    -- Delete Attribute bundle
    DELETE FROM IBC_ATTRIBUTE_BUNDLES WHERE attribute_bundle_id = l_citem_version_attr_id;

    -- Delete compound relations
    DELETE FROM IBC_COMPOUND_RELATIONS WHERE CITEM_VERSION_ID = l_citem_version_id;

        --***************************************************
        --************ADDING TO AUDIT LOG********************
        --***************************************************
        Ibc_Utilities_Pvt.log_action(
           p_activity       => Ibc_Utilities_Pvt.G_ALA_REMOVE
           ,p_parent_value  => l_content_item_id
           ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
           ,p_object_value1 => l_citem_version_id
           ,p_object_value2 => NULL
           ,p_object_value3 => NULL
           ,p_object_value4 => NULL
           ,p_object_value5 => NULL
           ,p_description   => 'Hard deleting content item version'
        );

  IF (l_log_item_flag = FND_API.g_true) THEN
           Ibc_Utilities_Pvt.log_action(
              p_activity       => Ibc_Utilities_Pvt.G_ALA_UPDATE
              ,p_parent_value  => NULL
              ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
              ,p_object_value1 => l_content_item_id
              ,p_object_value2 => NULL
              ,p_object_value3 => NULL
              ,p_object_value4 => NULL
              ,p_object_value5 => NULL
              ,p_description   => 'Updating content item (hard-deleting its versions)'
           );
  END IF;
  l_log_item_flag := FND_API.g_false;
        --***************************************************

    END LOOP;



     --******************* Real Logic End *********************

     -- Standard check of p_commit.
     IF( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
         COMMIT;
     END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(
          p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );

      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
     ROLLBACK TO HARD_DELETE_ITEM_VERSIONS_PT;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO HARD_DELETE_ITEM_VERSIONS_PT;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO HARD_DELETE_ITEM_VERSIONS_PT;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;

PROCEDURE hard_delete_items (
  p_api_version     IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2,
  p_commit            IN  VARCHAR2,
  p_content_item_ids   IN JTF_NUMBER_TABLE,
  x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
) AS
 --******************* BEGIN REQUIRED VARIABLES *************************
  l_api_name CONSTANT VARCHAR2(30) := 'hard_delete_items';        --|**|
  l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT;  --|**|
--******************* END REQUIRED VARIABLES ****************************

--
  l_citem_id    NUMBER;
  l_directory_node_id NUMBER;
--
  CURSOR Get_Item_Versions IS
     SELECT CITEM_VERSION_ID, ATTRIBUTE_FILE_ID
     FROM IBC_CITEM_VERSIONS_VL
     WHERE CONTENT_ITEM_ID = l_citem_id;

BEGIN
      --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
      -- ******************* Standard Begins *******************
      -- Standard Start of API savepoint
      SAVEPOINT HARD_DELETE_ITEMS_PT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
    l_api_version_number,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
      THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --******************* Real Logic Start *********************

      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.start_process(
           p_proc_type  => 'PROCEDURE',
           p_proc_name  => 'Hard_Delete_Items',
           p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                             p_tag     => 'PARAMETERS',
                             p_parms   => JTF_VARCHAR2_TABLE_4000(
                                            'p_api_version', p_api_version,
                                            'p_init_msg_list', p_init_msg_list,
                                            'p_commit', p_commit,
                                            'p_content_item_ids', IBC_DEBUG_PVT.make_list(p_content_item_ids)
                                          )
                             )
        );
      END IF;

      FOR i IN 1..p_content_item_ids.COUNT LOOP
         l_citem_id := p_content_item_ids(i);

         IF IBC_VALIDATE_PVT.isvalidcitem(l_citem_id) = FND_API.g_false THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
            FND_MESSAGE.Set_Token('INPUT', 'content_item_id:[' || l_citem_id || ']', FALSE);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;


         l_directory_node_id := getDirectoryNodeId(l_citem_id);

         --sanshuma : 01/10/2004 : Changed p_permission_code from CITEM_DELETE to CITEM_EDIT
   -- ***************PERMISSION CHECK*********************************************************************
        IF(isItemAdmin(l_citem_id) = FND_API.g_false) THEN                                                   --|*|
           IF( IBC_DATA_SECURITY_PVT.has_permission(                                                         --|*|
                        p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                        ,p_instance_pk1_value    => l_citem_id                                               --|*|
                        ,p_permission_code       => 'CITEM_EDIT'                                           --|*|
                        ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                        ,p_container_pk1_value   => l_directory_node_id                                      --|*|
                        ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                        ) = FND_API.g_false                                                                  --|*|
                  ) THEN                                                                                     --|*|
                 --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
                 x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
               FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                     --|*|
                 FND_MSG_PUB.ADD;                                                                            --|*|
                 -- possibly wait until end to raise exception so all errors can be loaded in message list???--|*|
                 RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
           END IF;                                                                                           --|*|
        END IF;                                                                                              --|*|
       -- ***************PERMISSION CHECK**********************************************************************

        FOR citem_version_rec IN Get_Item_Versions LOOP
           -- Delete version
           Ibc_Citem_Versions_Pkg.DELETE_ROW(citem_version_rec.CITEM_VERSION_ID);

          -- Delete Renditions
          DELETE FROM ibc_renditions WHERE citem_version_id = citem_version_Rec.citem_version_id;

           -- Delete Attribute bundle
           DELETE FROM IBC_ATTRIBUTE_BUNDLES WHERE attribute_bundle_id = citem_version_rec.ATTRIBUTE_FILE_ID;

           -- Delete compound relations
           DELETE FROM IBC_COMPOUND_RELATIONS WHERE CITEM_VERSION_ID = citem_version_rec.CITEM_VERSION_ID;
         END LOOP;

        -- Delete citem keywords
        DELETE FROM ibc_citem_keywords WHERE CONTENT_ITEM_ID = l_citem_id;

         -- Delete itself from being a child (this should not be needed,
         -- if UI disable deletion of children items)
         DELETE FROM IBC_COMPOUND_RELATIONS WHERE CONTENT_ITEM_ID = l_citem_id;

         -- Delete itself
         DELETE FROM IBC_CONTENT_ITEMS WHERE CONTENT_ITEM_ID = l_citem_id;

         -- Delete from Version Labels
         DELETE FROM IBC_CITEM_VERSION_LABELS WHERE CONTENT_ITEM_ID = l_citem_id;

         -- Delete from Associations
         DELETE FROM IBC_ASSOCIATIONS WHERE CONTENT_ITEM_ID = l_citem_id;

        --***************************************************
        --************ADDING TO AUDIT LOG********************
        --***************************************************
        Ibc_Utilities_Pvt.log_action(
           p_activity       => Ibc_Utilities_Pvt.G_ALA_REMOVE
           ,p_parent_value  => NULL
           ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CONTENT_ITEM
           ,p_object_value1 => l_citem_id
           ,p_object_value2 => NULL
           ,p_object_value3 => NULL
           ,p_object_value4 => NULL
           ,p_object_value5 => NULL
           ,p_description   => 'Hard deleting content item'
        );

       END LOOP;

      --******************* Real Logic End *********************
     -- Standard check of p_commit.
     IF((x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
         COMMIT;
     END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(
          p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );




      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
     ROLLBACK TO HARD_DELETE_ITEMS_PT;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO HARD_DELETE_ITEMS_PT;
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO HARD_DELETE_ITEMS_PT;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name           => L_API_NAME
         ,p_pkg_name          => G_PKG_NAME
         ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
         ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
         ,p_sqlcode           => SQLCODE
         ,p_sqlerrm           => SQLERRM
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
 END;


-- --------------------------------------------------------------
-- IBC_CITEM_ADMIN_GRP.CHANGE_TRANSLATION_STATUS
--  It changes status of a particular version. It will not allow
--  changes to approved versions.  NOTE: archiving of versions is
--  not currently supported even though status CODE exists.
-- --------------------------------------------------------------
PROCEDURE Change_Translation_Status(
     p_citem_ver_id             IN NUMBER
    ,p_new_status               IN VARCHAR2
    ,p_language                 IN VARCHAR2
    ,p_commit                   IN VARCHAR2
    ,p_api_version_number       IN NUMBER
    ,p_init_msg_list            IN VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    ) IS
--******************* BEGIN REQUIRED VARIABLES *************************
 l_api_name CONSTANT VARCHAR2(30) := 'Change_Translation_Status'; --|**|
 l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT;   --|**|
--******************* END REQUIRED VARIABLES ***************************
   content_item_id NUMBER;
   ctype_code IBC_CONTENT_TYPES_B.content_type_code%TYPE;
   dir_id NUMBER;
   l_description VARCHAR2(50);
   l_activity    VARCHAR2(50);

   l_return_status          VARCHAR2(30);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);

BEGIN
  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
--******************* BEGIN REQUIRED AREA ******************************
      SAVEPOINT svpt_change_status;                               --|**|
      IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
        FND_MSG_PUB.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT FND_API.Compatible_API_Call (                        --|**|
                l_api_version_number                              --|**|
      ,p_api_version_number                                       --|**|
      ,l_api_name                                                 --|**|
      ,G_PKG_NAME                                                 --|**|
      )THEN                                                       --|**|
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                       --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
--******************* END REQUIRED AREA ********************************

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
          p_proc_type  => 'PROCEDURE'
         ,p_proc_name  => 'Change_Translation_Status'
         ,p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                            p_tag     => 'PARAMETERS'
                           ,p_parms   => JTF_VARCHAR2_TABLE_4000(
                                            'p_citem_ver_id', p_citem_ver_id
                                           ,'p_new_status', p_new_status
                                           ,'p_language', p_language
                                           ,'p_commit', p_commit
                                           ,'p_api_version_number', p_api_version_number
                                           ,'p_init_msg_list', p_init_msg_list
                                           ,'px_object_version_number', px_object_version_number
                                           )
                                         )
         );
    END IF;

    -- checking version id
    IF (IBC_VALIDATE_PVT.isValidCitemVer(p_citem_ver_id) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - p_citem_ver_id');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_citem_ver_id', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- checking if valid status
    IF (IBC_VALIDATE_PVT.isValidStatus(p_new_status) = FND_API.g_false) THEN
        --DBMS_OUTPUT.put_line('EX - p_status');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'p_status', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/*
     IF (IBC_VALIDATE_PVT.isApproved(p_citem_ver_id) = FND_API.g_true) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'UPDATE_APPROVED_ITEM_ERROR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
*/

     IF (IBC_VALIDATE_PVT.isTranslationApproved(p_citem_ver_id
                                               ,p_language
                                               ) = FND_API.g_true) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'IBC_TRANSLATION_UPDATE_ERROR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    content_item_id := getCitemId(p_citem_ver_id);
    ctype_code := getContentType(content_item_id);
    dir_id := getDirectoryNodeId(content_item_id);

    -- ***************PERMISSION CHECK*********************************************************************
    IF (hasPermission(content_item_id) = FND_API.g_false) THEN                                         --|*|
        --DBMS_OUTPUT.put_line('EX - no lock permissions');                                            --|*|
        x_return_status := FND_API.G_RET_STS_ERROR;                                                    --|*|
      FND_MESSAGE.Set_Name('IBC', 'INVALID_LOCK_PERMISSION');                                          --|*|
        FND_MSG_PUB.ADD;                                                                               --|*|
        RAISE FND_API.G_EXC_ERROR;                                                                     --|*|
    ELSIF(isItemAdmin(content_item_id) = FND_API.g_false) THEN                                         --|*|
       IF( IBC_DATA_SECURITY_PVT.has_permission(                                                       --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_EDIT'                                             --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
            AND                                                                                        --|*|
            (p_new_status NOT IN (Ibc_Utilities_Pub.G_STV_APPROVED, IBC_UTILITIES_PUB.G_STV_REJECTED)  --|*|
             OR                                                                                        --|*|
             IBC_DATA_SECURITY_PVT.has_permission(                                                     --|*|
                  p_instance_object_id     => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')  --|*|
                  ,p_instance_pk1_value    => content_item_id                                          --|*|
                  ,p_permission_code       => 'CITEM_APPROVE'                                          --|*|
                  ,p_container_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')--|*|
                  ,p_container_pk1_value   => dir_id                                                   --|*|
                  ,p_current_user_id       => FND_GLOBAL.user_id                                       --|*|
                  ) = FND_API.g_false                                                                  --|*|
             )                                                                                         --|*|
            ) THEN                                                                                     --|*|
           --DBMS_OUTPUT.put_line('EX - no permissions');                                              --|*|
           x_return_status := FND_API.G_RET_STS_ERROR;                                                 --|*|
         FND_MESSAGE.Set_Name('IBC', 'INSUFFICIENT_PRIVILEGES');                                       --|*|
           FND_MSG_PUB.ADD;                                                                            --|*|
           RAISE FND_API.G_EXC_ERROR;                                                                  --|*|
      END IF;                                                                                          --|*|
    END IF;                                                                                            --|*|
    -- ***************PERMISSION CHECK*********************************************************************

        px_object_version_number := NULL;
        -- update version status
        Ibc_Citem_Versions_Pkg.update_row(
             p_CITEM_VERSION_ID         => p_citem_ver_id
            ,p_content_item_id          => content_item_id
            ,p_citem_translation_status => p_new_status
            ,P_SOURCE_LANG              => p_language
            ,px_object_version_number   => px_object_version_number
            );


           --***************************************************
           --************ADDING TO AUDIT LOG********************
           --***************************************************

        l_description := 'Updating version';
        l_activity    := Ibc_Utilities_Pvt.G_ALA_UPDATE;

           Ibc_Utilities_Pvt.log_action(
                p_activity      => l_activity
               ,p_parent_value  => content_item_id
               ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
               ,p_object_value1 => p_citem_ver_id
               ,p_object_value2 => NULL
               ,p_object_value3 => NULL
               ,p_object_value4 => NULL
               ,p_object_value5 => NULL
               ,p_description   => l_description
           );

        IF p_new_status = IBC_UTILITIES_PUB.G_STV_APPROVED THEN
          l_description := 'Approved';
          l_activity := Ibc_Utilities_Pvt.G_ALA_APPROVE;
        ELSIF p_new_status = IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL THEN
          l_description := 'Submitted for Approval';
          l_activity := Ibc_Utilities_Pvt.G_ALA_SUBMIT;
        ELSIF p_new_status = IBC_UTILITIES_PUB.G_STV_REJECTED THEN
          l_description := 'Rejected';
          l_activity := Ibc_Utilities_Pvt.G_ALA_REJECT;
        ELSIF p_new_status = IBC_UTILITIES_PUB.G_STV_ARCHIVED THEN
          l_description := 'Archived';
          l_activity := Ibc_Utilities_Pvt.G_ALA_ARCHIVE;
        END IF;

          Ibc_Utilities_Pvt.log_action(
             p_activity      => l_activity
            ,p_parent_value  => content_item_id
            ,p_object_type   => Ibc_Utilities_Pvt.G_ALO_CITEM_VERSION
            ,p_object_value1 => p_citem_ver_id
            ,p_object_value2 => NULL
            ,p_object_value3 => NULL
            ,p_object_value4 => NULL
            ,p_object_value5 => NULL
            ,p_description   => l_description
          );
/*
          --UI Logging
          IBC_AUDIT_LOG_GRP.log_action(
             p_activity             => l_activity
            ,p_object_type          => IBC_AUDIT_LOG_GRP.G_CITEM_VERSION
            ,p_object_value1        => p_citem_ver_id
            ,p_object_value2        => p_language
            ,p_parent_value         => getCitemId(p_citem_ver_id)
            ,p_message_application  => 'IBC'
            ,p_message_name         => 'IBC_TRANS_LOG_MSG'
            ,p_extra_info2_type     => IBC_AUDIT_LOG_GRP.G_EI_LOOKUP
            ,p_extra_info2_ref_type => 'IBC_CITEM_VERSION_STATUS'
            ,p_extra_info2_value    => p_new_status
            --,p_commit               => FND_API.g_true
            ,p_init_msg_list        => FND_API.g_true
            ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data
          );
*/

    -- COMMIT?
    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) AND (p_commit = FND_API.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count
       ,p_data  => x_msg_data
       );

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
                 p_tag    => 'OUTPUT'
                ,p_parms  => JTF_VARCHAR2_TABLE_4000(
                               'px_object_version_number', px_object_version_number
                              ,'x_return_status', x_return_status
                              ,'x_msg_count', x_msg_count
                              ,'x_msg_data', x_msg_data
                              )
                )
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_change_status;
      --DBMS_OUTPUT.put_line('Expected Error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name          => L_API_NAME
        ,p_pkg_name          => G_PKG_NAME
        ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
        ,p_sqlcode           => SQLCODE
        ,p_sqlerrm           => SQLERRM
        ,x_msg_count         => x_msg_count
        ,x_msg_data          => x_msg_data
        ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                           'px_object_version_number', px_object_version_number
                          ,'x_return_status', x_return_status
                          ,'x_msg_count', x_msg_count
                          ,'x_msg_data', x_msg_data
                          )
                        )
        );
      END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_change_status;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
         p_api_name          => L_API_NAME
        ,p_pkg_name          => G_PKG_NAME
        ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
        ,p_sqlcode           => SQLCODE
        ,p_sqlerrm           => SQLERRM
        ,x_msg_count         => x_msg_count
        ,x_msg_data          => x_msg_data
        ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                           'px_object_version_number', px_object_version_number
                          ,'x_return_status', x_return_status
                          ,'x_msg_count', x_msg_count
                          ,'x_msg_data', x_msg_data
                          )
          )
        );
      END IF;
  WHEN OTHERS THEN
      ROLLBACK TO svpt_change_status;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
         p_api_name          => L_API_NAME
        ,p_pkg_name          => G_PKG_NAME
        ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
        ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
        ,p_sqlcode           => SQLCODE
        ,p_sqlerrm           => SQLERRM
        ,x_msg_count         => x_msg_count
        ,x_msg_data          => x_msg_data
        ,x_return_status     => x_return_status
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                           'px_object_version_number', px_object_version_number
                          ,'x_return_status', x_return_status
                          ,'x_msg_count', x_msg_count
                          ,'x_msg_data', x_msg_data
                          ,'EXCEPTION', SQLERRM
                          )
          )
        );
      END IF;
 END Change_Translation_Status;



-- --------------------------------------------------------------
-- isCitemVerInPassedStatus
--
-- Used to see if any item version exists for the passed
-- item version status
--
-- --------------------------------------------------------------
FUNCTION isCitemVerInPassedStatus(
                                  p_content_item_id      IN NUMBER
                                 ,p_citem_version_status IN VARCHAR2
                                 ) RETURN BOOLEAN
IS
  l_dummy    VARCHAR2(2);
  l_result   BOOLEAN;
  CURSOR cur IS
    SELECT 'X'
      FROM ibc_citem_versions_b
     WHERE content_item_id = p_content_item_id
       AND citem_version_status = p_citem_version_status;
BEGIN
  l_result := FALSE;
  OPEN cur;
  FETCH cur INTO l_dummy;
    l_result := cur%FOUND;
  CLOSE cur;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END isCitemVerInPassedStatus;


-- --------------------------------------------------------------
-- isItemLockedByCurrentUser
--
-- Used to see if the item is locked by the current user
--
-- --------------------------------------------------------------
FUNCTION isItemLockedByCurrentUser(p_content_item_id IN NUMBER) RETURN BOOLEAN
IS
  l_dummy    VARCHAR2(2);
  l_result   BOOLEAN;
  CURSOR cur IS
    SELECT 'X'
      FROM ibc_content_items
     WHERE content_item_id = p_content_item_id
       AND NVL(locked_by_user_id,FND_GLOBAL.user_id) = FND_GLOBAL.user_id;
BEGIN
  l_result := FALSE;
  OPEN cur;
  FETCH cur INTO l_dummy;
    l_result := cur%FOUND;
  CLOSE cur;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END isItemLockedByCurrentUser;

END; -- Package Body IBC_CITEM_ADMIN_GRP

/
