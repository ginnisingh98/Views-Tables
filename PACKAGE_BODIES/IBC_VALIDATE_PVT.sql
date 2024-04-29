--------------------------------------------------------
--  DDL for Package Body IBC_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_VALIDATE_PVT" AS
/* $Header: ibcvvldb.pls 120.2 2005/08/24 12:21:17 appldev ship $ */

/****************************************************
-------------PACKAGE VARIABLES -------------------------------------------------------------------------
****************************************************/




/****************************************************
-------------FUNCTIONS--------------------------------------------------------------------------
****************************************************/
-- --------------------------------------------------------------
-- IS APPROVED
--
-- Checks to see if content item version is approved
--
-- --------------------------------------------------------------
FUNCTION isApproved(
    f_citem_ver_id   IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_app IS
        SELECT
            citem_version_id
        FROM
            ibc_citem_versions_b
        WHERE
            citem_version_id = f_citem_ver_id
        AND
            citem_version_status = IBC_UTILITIES_PUB.G_STV_APPROVED;

    temp NUMBER;
BEGIN
    open c_app;
    fetch c_app into temp;

    if (c_app%NOTFOUND) then
        close c_app;
        RETURN FND_API.g_false;
    else
        close c_app;
        RETURN FND_API.g_true;
    end if;
 END;




-- --------------------------------------------------------------
-- IS APPROVED ITEM
--
-- Checks to see if content item version is approved
--
-- --------------------------------------------------------------
FUNCTION isApprovedItem(
    f_citem_id  IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_appi IS
        SELECT
            content_item_id
        FROM
            ibc_content_items
        WHERE
            content_item_id = f_citem_id
        AND
            content_item_status = IBC_UTILITIES_PUB.G_STI_APPROVED;

    temp NUMBER;
BEGIN
    open c_appi;
    fetch c_appi into temp;

    if (c_appi%NOTFOUND) then
        close c_appi;
        RETURN FND_API.g_false;
    else
        close c_appi;
        RETURN FND_API.g_true;
    end if;
 END;


 -- --------------------------------------------------------------
-- IS BOOLEAN
--
-- Used to check if item is boolean
--
-- --------------------------------------------------------------
FUNCTION isBoolean(
    f_boolean  IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
    IF ( (f_boolean = 'F') OR (f_boolean = 'T') ) THEN
        RETURN FND_API.g_true;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isBoolean;







-- --------------------------------------------------------------
-- IS DATE
--
-- Used to check if a string is actually a date
--
-- --------------------------------------------------------------
FUNCTION isDate(
    f_date   IN  VARCHAR2
)
RETURN VARCHAR2
IS
    temp DATE;
BEGIN


    IF (f_date IS NOT NULL) THEN
        BEGIN
          temp := TO_DATE(f_date, FND_DATE.user_mask);
        EXCEPTION
          WHEN OTHERS THEN
		  	BEGIN
            temp := TO_DATE(f_date, Fnd_Profile.value('ICX_DATE_FORMAT_MASK'));
			EXCEPTION
          	    WHEN OTHERS THEN
					temp := TO_DATE(f_date,'RRRR-mm-dd');
			END;

        END;
        RETURN Fnd_Api.g_true;
    ELSE
        RETURN Fnd_Api.g_false;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN Fnd_Api.g_false;
END isDate;





-- --------------------------------------------------------------
-- IS NUMBER
--
-- Used to check if a string is actually a number
--
-- --------------------------------------------------------------
FUNCTION isNumber(
    f_number   IN  VARCHAR2
)
RETURN VARCHAR2
IS
    temp NUMBER;
BEGIN
    if (f_number is not null) then
        temp := TO_NUMBER(f_number);
        RETURN FND_API.g_true;
    else
        RETURN FND_API.g_false;
    end if;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.g_false;
END isNumber;




-- --------------------------------------------------------------
-- IS VALID ASSOCIATION
--
-- Used to check if the association exists
--
-- --------------------------------------------------------------
FUNCTION isValidAssoc(
    f_assoc_id IN VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_assoc IS
        SELECT
            association_id
        FROM
            ibc_associations
        WHERE
            association_id = f_assoc_id;

    temp NUMBER;
BEGIN
    IF (f_assoc_id is not null) THEN
    	OPEN c_assoc;
    	FETCH c_assoc INTO temp;

        IF (c_assoc%NOTFOUND) THEN
	        CLOSE c_assoc;
	        RETURN FND_API.g_false;
	    ELSE
	        CLOSE c_assoc;
            RETURN FND_API.g_false;
        END IF;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidAssoc;




-- --------------------------------------------------------------
-- IS VALID ATTACHMENT
--
-- Used to check if the attachment exists
--
-- --------------------------------------------------------------
FUNCTION isValidAttachment(
    f_attach_id IN VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_attach IS
        SELECT
            file_id
        FROM
    	    fnd_lobs
        WHERE
            file_id = f_attach_id;

    temp NUMBER;
BEGIN
    IF (f_attach_id is not null) then
        OPEN c_attach;
        FETCH c_attach INTO temp;

        IF (c_attach%NOTFOUND) THEN
            CLOSE c_attach;
            RETURN FND_API.g_false;
        ELSE
            CLOSE c_attach;
            RETURN FND_API.g_true;
        END IF;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidAttachment;



-- --------------------------------------------------------------
-- IS VALID ASSOCIATION TYPE CODE
--
-- Used to check if the association type code exists
--
-- --------------------------------------------------------------
FUNCTION isValidAssocType(
    f_assoc_code IN VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_assoc IS
        SELECT
            association_type_code
        FROM
	       ibc_association_types_b
        WHERE
            association_type_code = f_assoc_code;

    temp IBC_ASSOCIATION_TYPES_B.association_type_code%TYPE;
BEGIN
    IF (f_assoc_code IS NOT NULL) THEN
        open c_assoc;
        fetch c_assoc into temp;

        if (c_assoc%NOTFOUND) then
            close c_assoc;
            RETURN FND_API.g_false;
        else
            close c_assoc;
            RETURN FND_API.g_true;
        end if;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidAssocType;




-- --------------------------------------------------------------
-- IS VALID ATTRIBUTE CODE
--
-- Used to check if the directory node exists
--
-- --------------------------------------------------------------
FUNCTION isValidAttrCode(
    f_attr_type_code IN VARCHAR2
    ,f_ctype_code IN VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_acode IS
        SELECT
            attribute_type_code
        FROM
	       ibc_attribute_types_b
        WHERE
            attribute_type_code = f_attr_type_code
        AND
            content_type_code = f_ctype_code;

    temp IBC_ATTRIBUTE_TYPES_B.attribute_type_code%TYPE;
BEGIN
    IF (f_attr_type_code IS NOT NULL) THEN
        open c_acode;
        fetch c_acode into temp;

        if (c_acode%NOTFOUND) then
            CLOSE c_acode;
            RETURN FND_API.g_false;
        else
            CLOSE c_acode;
            RETURN FND_API.g_true;
        end if;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidAttrCode;




-- --------------------------------------------------------------
-- IS VALID CITEM VERSION
--
-- Used to check if the content item version exists
--
-- --------------------------------------------------------------
FUNCTION isValidCitemVer(
    f_citem_ver_id   IN  VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_verid IS
        SELECT
            citem_version_id
        FROM
	       ibc_citem_versions_b
        WHERE
            citem_version_id = f_citem_ver_id;

    temp NUMBER;
BEGIN
    IF (f_citem_ver_id IS NOT NULL) THEN
        open c_verid;
        fetch c_verid into temp;

        if (c_verid%NOTFOUND) then
            close c_verid;
            RETURN FND_API.g_false;
        else
            close c_verid;
            RETURN FND_API.g_true;
        end if;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidCitemVer;



-- --------------------------------------------------------------
-- IS VALID CITEM VERSION FOR CITEM
--
-- Used to check if the citem version id is valid and belongs to
-- a particular content item.
--
-- --------------------------------------------------------------
FUNCTION isValidCitemVerForCitem (
    f_citem_id   IN  VARCHAR2
    ,f_citem_ver_id   IN  VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_verid IS
        SELECT citem_version_id
          FROM ibc_citem_versions_b
         WHERE content_item_id = f_citem_id
           AND citem_version_id = f_citem_ver_id;
    temp NUMBER;
BEGIN
    IF (f_citem_ver_id IS NOT NULL) THEN
        open c_verid;
        fetch c_verid into temp;

        if (c_verid%NOTFOUND) then
            close c_verid;
            RETURN FND_API.g_false;
        else
            close c_verid;
            RETURN FND_API.g_true;
        end if;
    ELSE
        RETURN FND_API.g_false;
    END IF;
END isValidCitemVerForCitem;



-- --------------------------------------------------------------
-- IS VALID CITEM
--
-- Used to check if the content item exists
--
-- --------------------------------------------------------------
FUNCTION isValidCitem(
    f_citem_id   IN  VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_citem IS
        SELECT
            content_item_id
        FROM
	       ibc_content_items
        WHERE
            content_item_id = f_citem_id;

    temp NUMBER;
BEGIN
    IF (f_citem_id IS NOT NULL) THEN
        open c_citem;
        fetch c_citem into temp;

        IF (c_citem%NOTFOUND) THEN
            close c_citem;
            RETURN FND_API.g_false;
        ELSE
            close c_citem;
            RETURN FND_API.g_true;
        END IF;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidCitem;


-- --------------------------------------------------------------
-- IS VALID LANGUAGE
--
-- Used to check if specified language exists in FND_LANGUAGES
--
-- --------------------------------------------------------------
FUNCTION isValidLanguage(
    p_language   IN  VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_language IS
        SELECT 'X'
          FROM fnd_languages
         WHERE language_code = p_language;

    l_dummy VARCHAR2(1);
BEGIN
    IF (p_language IS NOT NULL) THEN
        open c_language;
        fetch c_language into l_dummy;

        IF (c_language%NOTFOUND) THEN
            close c_language;
            RETURN FND_API.g_false;
        ELSE
            close c_language;
            RETURN FND_API.g_true;
        END IF;
    ELSE
        RETURN FND_API.g_true;
    END IF;
 END isValidLanguage;


-- --------------------------------------------------------------
-- IS VALID CTYPE
--
-- Used to check if the content type code exists
--
-- --------------------------------------------------------------
FUNCTION isValidCType(
    f_ctype_code   IN  VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_ctype IS
        SELECT
            content_type_code
        FROM
	       ibc_content_types_b
        WHERE
            content_type_code = f_ctype_code;

    temp IBC_CONTENT_TYPES_B.content_type_code%TYPE;
BEGIN
    IF (f_ctype_code IS NOT NULL) THEN
        open c_ctype;
        fetch c_ctype into temp;

        IF(c_ctype%NOTFOUND) THEN
            CLOSE c_ctype;
            RETURN FND_API.g_false;
        ELSE
            CLOSE c_ctype;
            RETURN FND_API.g_true;
        END IF;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidCType;



-- --------------------------------------------------------------
-- IS VALID DIRECTORY NODE
--
-- Used to check if the directory node exists
--
-- --------------------------------------------------------------
FUNCTION isValidDirNode(
    f_node_id   IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_dnode IS
        SELECT
           directory_node_id
        FROM
	       ibc_directory_nodes_b
        WHERE
            directory_node_id = f_node_id;

    temp NUMBER;
BEGIN
    IF (f_node_id IS NOT NULL) THEN
        OPEN c_dnode;
        fetch c_dnode into temp;

        IF(c_dnode%NOTFOUND) THEN
            CLOSE c_dnode;
            RETURN FND_API.g_false;
        ELSE
            CLOSE c_dnode;
            RETURN FND_API.g_true;
        END IF;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidDirNode;





 -- --------------------------------------------------------------
-- IS VALID LOB
--
-- Used to check if the lob exists in fnd_lobs
--
-- --------------------------------------------------------------
FUNCTION isValidLob(
    f_lob_id   IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_lob IS
        SELECT
           file_id
        FROM
	       fnd_lobs
        WHERE
            file_id = f_lob_id;

    temp NUMBER;
BEGIN
    IF (f_lob_id IS NOT NULL) THEN
        open c_lob;
        fetch c_lob into temp;

        IF(c_lob%NOTFOUND) THEN
            CLOSE c_lob;
            RETURN FND_API.g_false;
        ELSE
            CLOSE c_lob;
            RETURN FND_API.g_true;
        END IF;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidLob;


-- --------------------------------------------------------------
-- IS VALID RESOURCE
--
-- Used to check if the resource exists
--
-- --------------------------------------------------------------
FUNCTION isValidResource(
    f_resource_id    IN  NUMBER
    ,f_resource_type IN VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_resource IS
        SELECT resource_id
          FROM jtf_rs_all_resources_vl
         WHERE resource_id = f_resource_id
           AND resource_type = f_resource_type;

    temp number;

    CURSOR c_user IS
        SELECT user_id
          FROM FND_USER
         WHERE user_id = f_resource_id;

BEGIN

    if (f_resource_id IS NULL or f_resource_type IS NULL) then
        RETURN FND_API.g_false;
    end if;

    if (UPPER(f_resource_type) = 'USER') then
        open c_user;
        fetch c_user into temp;

        if (c_user%NOTFOUND) then
            close c_user;
            RETURN FND_API.g_false;
        else
            close c_user;
            RETURN FND_API.g_true;
        end if;
    else
        open c_resource;
        fetch c_resource into temp;

        if (c_resource%NOTFOUND) then
            close c_resource;
            RETURN FND_API.g_false;
        else
            close c_resource;
            RETURN FND_API.g_true;
        end if;
    end if;
END isValidResource;


-- --------------------------------------------------------------
-- IS VALID USER
--
-- Used to check if the user exists in FND_USER
--
-- --------------------------------------------------------------
FUNCTION isValidUser(
    f_user_id    IN  NUMBER
)
RETURN VARCHAR2
IS
    CURSOR c_user IS
        SELECT user_id
          FROM FND_USER
         WHERE user_id = f_user_id;
    temp number;
BEGIN
    if (f_user_id is not null) then
        open c_user;
        fetch c_user into temp;

        if (c_user%NOTFOUND) then
            close c_user;
            RETURN FND_API.g_false;
        else
            close c_user;
            RETURN FND_API.g_true;
        end if;
    else
        RETURN FND_API.g_false;
    end if;
 END isValidUser;



 -- --------------------------------------------------------------
-- IS VALID STATUS
--
-- Used to check if the status
--
-- --------------------------------------------------------------
FUNCTION isValidStatus(
    f_status  IN  VARCHAR2
)
RETURN VARCHAR2
IS
    temp VARCHAR2(30);
BEGIN

    if ( (f_status = IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL)   or
         (f_status = IBC_UTILITIES_PUB.G_STV_APPROVED)              or
         (f_status = IBC_UTILITIES_PUB.G_STV_ARCHIVED)              or
         (f_status = IBC_UTILITIES_PUB.G_STV_WORK_IN_PROGRESS)      or
         (f_status = IBC_UTILITIES_PUB.G_STV_REJECTED) )            then

        RETURN FND_API.g_true;
     else
        RETURN FND_API.g_false;
     end if;
 END isValidStatus;



 -- --------------------------------------------------------------
-- IS VALID LABEL
--
-- Used to check if the label exists
--
-- --------------------------------------------------------------
FUNCTION isValidLabel(
    f_label  IN  VARCHAR2
)
RETURN VARCHAR2
IS
    CURSOR c_label IS
        SELECT
            LABEL_CODE
        FROM
	        IBC_LABELS_B
        WHERE
            LABEL_CODE = f_label;

    temp IBC_LABELS_B.label_code%TYPE;
BEGIN
    IF (f_label IS NOT NULL) THEN
        open c_label;
        fetch c_label into temp;

        IF(c_label%NOTFOUND) THEN
            CLOSE c_label;
            RETURN FND_API.g_false;
        ELSE
            CLOSE c_label;
            RETURN FND_API.g_true;
        END IF;
    ELSE
        RETURN FND_API.g_false;
    END IF;
 END isValidLabel;



/****************************************************
-------------PROCEDURES--------------------------------------------------------------------------
****************************************************/


PROCEDURE Validate_NotNULL_NUMBER (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2)
IS
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_notnull_column IS NULL OR p_notnull_column = FND_API.G_MISS_NUM) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('IBC', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', p_column_name, FALSE);
            FND_MSG_PUB.ADD;
	END IF;
    END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_NotNULL_NUMBER;


PROCEDURE Validate_NotNULL_VARCHAR2 (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2)
IS
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_notnull_column IS NULL OR p_notnull_column = FND_API.G_MISS_CHAR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('IBC', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', p_column_name, FALSE);
            FND_MSG_PUB.ADD;
	END IF;
    END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_NotNULL_VARCHAR2;


PROCEDURE  Validate_Content_Type_Status (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_Content_Type_Status	IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2)
IS

 CURSOR C_Content_Type_Status IS
 SELECT lookup_code
 FROM   ibc_lookups lk
 WHERE  lookup_type = 'IBC_CTYPE_STATUS'
 AND    lookup_code = p_Content_Type_Status;

 l_Content_Type_Status   VARCHAR2(30);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Content_Type_Status IS NOT NULL AND  p_Content_Type_Status <> FND_API.G_MISS_CHAR) THEN
    	OPEN C_Content_Type_Status;
    	FETCH C_Content_Type_Status INTO l_Content_Type_Status;
            IF (C_Content_Type_Status%NOTFOUND) THEN
    	    CLOSE C_Content_Type_Status;
    	    x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	           FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
                   FND_MESSAGE.Set_Token('COLUMN', 'CONTENT_TYPE_STATUS', FALSE);
                   FND_MSG_PUB.ADD;
    	    	END IF;
            ELSE
    	    CLOSE C_Content_Type_Status;
    		END IF;
    END IF;

END Validate_Content_Type_Status;

PROCEDURE  Validate_appl_short_name (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_appl_short_name		IN 		VARCHAR2,
		x_application_id		OUT NOCOPY 	NUMBER,
		X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2)
IS
CURSOR  C_Get_Appl_Id (x_short_name VARCHAR2) IS
SELECT  application_id
FROM    fnd_application_vl
WHERE   application_short_name = x_short_name;

BEGIN


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_appl_short_name IS NOT NULL AND p_appl_short_name <> FND_API.G_MISS_CHAR) THEN
    	OPEN C_Get_Appl_Id (p_appl_short_name);
    	FETCH C_Get_Appl_Id INTO x_application_id;
            IF (C_Get_Appl_Id%NOTFOUND) THEN
    	    CLOSE C_Get_Appl_Id;
    	    x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	           FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
                   FND_MESSAGE.Set_Token('COLUMN', 'APPLICATION SHORT NAME', FALSE);
                   FND_MSG_PUB.ADD;
    	    	END IF;
            ELSE
    	    CLOSE C_Get_Appl_Id;
    		END IF;
    END IF;

END Validate_appl_short_name;


PROCEDURE  Validate_application_id (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_application_id		IN 		NUMBER,
		X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2)
IS
CURSOR  C_Get_Appl_Id IS
SELECT  application_id
FROM    fnd_application_vl
WHERE   application_id = p_application_id;

l_temp NUMBER;

BEGIN


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_application_id IS NOT NULL AND p_application_id <> FND_API.G_MISS_NUM) THEN
    	OPEN C_Get_Appl_Id;
    	FETCH C_Get_Appl_Id INTO l_temp;
            IF (C_Get_Appl_Id%NOTFOUND) THEN
    	    CLOSE C_Get_Appl_Id;
    	    x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	           FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
                   FND_MESSAGE.Set_Token('COLUMN', 'APPLICATION ID', FALSE);
                   FND_MSG_PUB.ADD;
    	    	END IF;
            ELSE
    	    CLOSE C_Get_Appl_Id;
    		END IF;
    END IF;

END Validate_application_id;


PROCEDURE  Validate_Content_Type_Code (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_Content_type_Code		IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2)
IS
CURSOR  C_CType_Code IS
SELECT  '1'
FROM    ibc_content_types_vl
WHERE   content_type_code = p_content_type_code;

l_temp	CHAR(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Content_type_Code IS NOT NULL AND p_Content_type_Code <> FND_API.G_MISS_CHAR) THEN
    	OPEN C_CType_Code;
    	FETCH C_CType_Code INTO l_temp;
            IF (C_CType_Code%NOTFOUND) THEN
    	    CLOSE C_CType_Code;
    	    x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	           FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
                   FND_MESSAGE.Set_Token('COLUMN', 'CONTENT TYPE CODE', FALSE);
                   FND_MSG_PUB.ADD;
    	    	END IF;
            ELSE
    	    CLOSE C_CType_Code;
    		END IF;
    END IF;

END Validate_Content_Type_Code;


PROCEDURE  Validate_Data_Type_Code (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_Data_type_Code		IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2)
IS
 CURSOR C_Data_type_Code IS
 SELECT lookup_code
 FROM   ibc_lookups lk
 WHERE  lookup_type = 'IBC_ATTRIBUTE_DATA_TYPE'
 AND    lookup_code = p_Data_type_Code;

 l_Data_type_Code   VARCHAR2(30);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Data Type Code cannot be NULL
    IF (p_Data_type_Code IS NOT NULL AND p_Data_type_Code <> FND_API.G_MISS_CHAR) THEN
    	OPEN C_Data_type_Code;
    	FETCH C_Data_type_Code INTO l_Data_type_Code;
            IF (C_Data_type_Code%NOTFOUND) THEN
    	    CLOSE C_Data_type_Code;
    	    x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	           FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
                   FND_MESSAGE.Set_Token('COLUMN', 'DATA_TYPE_CODE', FALSE);
                   FND_MSG_PUB.ADD;
    	    	END IF;
            ELSE
    	    CLOSE C_Data_type_Code;
    		END IF;
    END IF;

END Validate_Data_Type_Code;


PROCEDURE  Validate_Default_value (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
		p_data_type_code 		IN 		VARCHAR2,
   		p_Default_value			IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2)
IS

BEGIN


-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;


IF (p_Default_value IS NULL OR p_Default_value = FND_API.G_MISS_CHAR) THEN
   RETURN;
END IF;

-- Check for valid Default_value is NOT NULL
IF p_data_type_code = 'string' THEN
NULL;

ELSIF p_data_type_code = 'html' THEN
NULL;

ELSIF p_data_type_code = 'decimal'	THEN
NULL;

ELSIF p_data_type_code = 'dateTime'	THEN
NULL;

ELSIF p_data_type_code = 'url'	THEN
NULL;

ELSIF p_data_type_code = 'boolean'	THEN
NULL;

ELSIF p_data_type_code = 'component'	THEN
	  DECLARE
	   CURSOR C_content_item_id IS
       SELECT content_item_id
       FROM   ibc_content_items
       WHERE  content_item_id = TO_NUMBER(p_default_value);

	   l_content_item_id 	  NUMBER;
	  BEGIN
         OPEN C_content_item_id;
         FETCH C_content_item_id INTO l_content_item_id;
         IF (C_content_item_id%NOTFOUND) THEN
         CLOSE C_content_item_id;
         x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
               FND_MESSAGE.Set_Token('COLUMN', 'DEFAULT VALUE', FALSE);
               FND_MSG_PUB.ADD;
         END IF;
         ELSE
         CLOSE C_content_item_id;
         END IF;

	  END;

ELSIF p_data_type_code = 'attachment'		THEN
	  DECLARE
	   CURSOR C_file_id IS
       SELECT file_id
       FROM   fnd_lobs
       WHERE  file_id = p_default_value;

	   l_file_id 	  NUMBER;
	  BEGIN
         OPEN C_file_id;
         FETCH C_file_id INTO l_file_id;
         IF (C_file_id%NOTFOUND) THEN
         CLOSE C_file_id;
         x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
               FND_MESSAGE.Set_Token('COLUMN', 'DEFAULT VALUE', FALSE);
               FND_MSG_PUB.ADD;
         END IF;
         ELSE
         CLOSE C_file_id;
         END IF;

	  END;

END IF;

END Validate_Default_value;

PROCEDURE  Validate_Reference_Code (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
		p_data_type_code 		IN 		VARCHAR2,
   		p_Reference_Code		IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2)
IS
BEGIN
-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_data_type_code = 'component' THEN

-- For CITEM the reference code must refer to a valid Content Type Code
    IF (p_reference_code IS NULL OR p_reference_code = FND_API.G_MISS_CHAR) THEN
	   	    x_return_status := FND_API.G_RET_STS_ERROR;
	ELSE

        Validate_Content_Type_Code (
           		p_init_msg_list			=> p_init_msg_list,
           		p_Content_type_Code		=> p_reference_code,
            	X_Return_Status         => X_Return_Status,
           		X_Msg_Count             => X_Msg_Count,
            	X_Msg_Data              => X_Msg_Data);
	END IF;

ELSE
	IF (p_reference_code IS NOT NULL AND p_reference_code <> FND_API.G_MISS_CHAR) THEN
	   	    x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END IF;

    IF 	X_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
       FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
       FND_MESSAGE.Set_Token('COLUMN', 'Reference Code', FALSE);
       FND_MSG_PUB.ADD;
    END IF;

END Validate_Reference_Code;

PROCEDURE  Validate_Min_Max_Instances (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_Max_Instances			IN 		NUMBER,
		p_Min_Instances			IN 		NUMBER,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2)
IS
BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Max Instance cannot be greater than Min Instances
    IF (p_MAX_Instances < 1 OR p_min_instances < 0 OR NVL(p_Max_Instances,p_Min_Instances+1) < p_Min_Instances ) THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
           	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  	           FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
               FND_MESSAGE.Set_Token('COLUMN','MAX Instances', FALSE);
               FND_MSG_PUB.ADD;
	   		END IF;
	END IF;

END Validate_Min_Max_Instances;

PROCEDURE	Validate_Resource (
        		p_init_msg_list	IN VARCHAR2,
        		p_resource_id	IN NUMBER,
        		p_resource_type IN VARCHAR2,
        		x_return_status OUT NOCOPY VARCHAR2,
                x_msg_count     OUT NOCOPY NUMBER,
                x_msg_data      OUT NOCOPY VARCHAR2)
IS

 -- For performance issues assuming only GROUPS to be valid
 -- and not using jtf_rs_all_resources_vl but jtf_rs_groups_vl
 CURSOR C_jtf_resources IS
 SELECT '1'
   FROM JTF_RS_GROUPS_VL
  WHERE group_id = p_resource_id;

 l_tmp CHAR(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_resource_id IS NOT NULL AND  p_resource_id <> FND_API.G_MISS_NUM) THEN
    	OPEN C_jtf_resources;
    	FETCH C_jtf_resources INTO l_tmp;
            IF (C_jtf_resources%NOTFOUND) THEN
    	    CLOSE C_jtf_resources;
    	    x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    	           FND_MESSAGE.Set_Name('IBC', 'API_INVALID_ID');
                   FND_MESSAGE.Set_Token('COLUMN', 'RESOURCE_ID', FALSE);
                   FND_MSG_PUB.ADD;
    	    	END IF;
            ELSE
    	    CLOSE C_jtf_resources;
    		END IF;
	END IF;

END Validate_Resource;

/****************************************************
-------------FUNCTIONS--------------------------------------------------------------------------
****************************************************/
-- --------------------------------------------------------------
-- IBC_VALIDATE_PVT.isTranslationApproved
--
-- Checks to see if content item version translation is approved
--
-- --------------------------------------------------------------
FUNCTION isTranslationApproved(f_citem_ver_id IN NUMBER
                              ,f_language     IN VARCHAR2
                              )
RETURN VARCHAR2
IS
    CURSOR c_app IS
        SELECT
            citem_version_id
        FROM
            ibc_citem_versions_tl
        WHERE
            citem_version_id = f_citem_ver_id
        AND language = f_language
        AND citem_translation_status = IBC_UTILITIES_PUB.G_STV_APPROVED;

    temp NUMBER;
BEGIN
    open c_app;
    fetch c_app into temp;

    if (c_app%NOTFOUND) then
        close c_app;
        RETURN FND_API.g_false;
    else
        close c_app;
        RETURN FND_API.g_true;
    end if;
 END isTranslationApproved;


-- --------------------------------------------------------------
-- IBC_VALIDATE_PVT.getItemBaseLanguage
--
-- Get the base language for the content item
--
-- --------------------------------------------------------------
FUNCTION getItemBaseLanguage(f_content_item_id IN NUMBER)
RETURN VARCHAR2
IS
    CURSOR c_app IS
        SELECT
            base_language
        FROM
            ibc_content_items
        WHERE
            content_item_id = f_content_item_id;

    temp VARCHAR2(35);
BEGIN
    open c_app;
    fetch c_app into temp;

    if (c_app%NOTFOUND) then
        close c_app;
        RETURN 'XXX';
    else
        close c_app;
        RETURN temp;
    end if;
 END getItemBaseLanguage;


END Ibc_Validate_Pvt;

/
