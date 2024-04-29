--------------------------------------------------------
--  DDL for Package IBC_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: ibcvvlds.pls 115.15 2003/10/10 18:43:51 svatsa ship $ */

-----------------------------------------
-- Global Variables
-----------------------------------------
-- ************************************************************
-- The following global variables is used in validation procedures
-- -> validation_mode
-- ************************************************************
G_CREATE  VARCHAR2(30) := 'CREATE';
G_UPDATE  VARCHAR2(30) := 'UPDATE';


-----------------------------------------
-- FUNCTIONS
-----------------------------------------
-- --------------------------------------------------------------
-- IS APPROVED
--
-- Checks to see if content item version is approved
--
-- --------------------------------------------------------------
FUNCTION isApproved(
    f_citem_ver_id   IN  NUMBER
)
RETURN VARCHAR2;


-- --------------------------------------------------------------
-- IS APPROVED ITEM
--
-- Checks to see if content item version is approved
--
-- --------------------------------------------------------------
FUNCTION isApprovedItem(
    f_citem_id  IN  NUMBER
)
RETURN VARCHAR2;


 -- --------------------------------------------------------------
-- IS BOOLEAN
--
-- Used to check if item is boolean
--
-- --------------------------------------------------------------
FUNCTION isBoolean(
    f_boolean  IN  VARCHAR2
)
RETURN VARCHAR2;

-- --------------------------------------------------------------
-- IS DATE
--
-- Used to check if a string is actually a date
--
-- --------------------------------------------------------------
FUNCTION isDate(
    f_date   IN  VARCHAR2
)
RETURN VARCHAR2;


-- --------------------------------------------------------------
-- IS NUMBER
--
-- Used to check if a string is actually a number
--
-- --------------------------------------------------------------
FUNCTION isNumber(
    f_number   IN  VARCHAR2
)
RETURN VARCHAR2;


-- --------------------------------------------------------------
-- IS VALID ASSOCIATION
--
-- Used to check if the association exists
--
-- --------------------------------------------------------------
FUNCTION isValidAssoc(
    f_assoc_id IN VARCHAR2
)
RETURN VARCHAR2;



-- --------------------------------------------------------------
-- IS VALID ASSOCIATION TYPE CODE
--
-- Used to check if the association type code exists
--
-- --------------------------------------------------------------
FUNCTION isValidAssocType(
    f_assoc_code IN VARCHAR2
)
RETURN VARCHAR2;



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
RETURN VARCHAR2;


-- --------------------------------------------------------------
-- IS VALID ATTACHMENT
--
-- Used to check if the attachment exists
--
-- --------------------------------------------------------------
FUNCTION isValidAttachment(
    f_attach_id IN VARCHAR2
)
RETURN VARCHAR2;



-- --------------------------------------------------------------
-- IS VALID CITEM
--
-- Used to check if the content item version exists
--
-- --------------------------------------------------------------
FUNCTION isValidCitem(
    f_citem_id   IN  VARCHAR2
)
RETURN VARCHAR2;



-- --------------------------------------------------------------
-- IS VALID CITEM VERSION
--
-- Used to check if the content item exists
--
-- --------------------------------------------------------------
FUNCTION isValidCitemVer(
    f_citem_ver_id   IN  VARCHAR2
)
RETURN VARCHAR2;

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
RETURN VARCHAR2;

-- --------------------------------------------------------------
-- IS VALID LANGUAGE
--
-- Used to check if specified language exists in FND_LANGUAGES
--
-- --------------------------------------------------------------
FUNCTION isValidLanguage(
    p_language   IN  VARCHAR2
)
RETURN VARCHAR2;


-- --------------------------------------------------------------
-- IS VALID CTYPE
--
-- Used to check if the content type code exists
--
-- --------------------------------------------------------------
FUNCTION isValidCType(
    f_ctype_code   IN  VARCHAR2
)
RETURN VARCHAR2;


-- --------------------------------------------------------------
-- IS VALID DIRECTORY NODE
--
-- Used to check if the directory node exists
--
-- --------------------------------------------------------------
FUNCTION isValidDirNode(
    f_node_id   IN  NUMBER
)
RETURN VARCHAR2;


 -- --------------------------------------------------------------
-- IS VALID LOB
--
-- Used to check if the lob exists in fnd_lobs
--
-- --------------------------------------------------------------
FUNCTION isValidLob(
    f_lob_id   IN  NUMBER
)
RETURN VARCHAR2;


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
RETURN VARCHAR2;

-- --------------------------------------------------------------
-- IS VALID USER
--
-- Used to check if the user exists in FND_USER
--
-- --------------------------------------------------------------
FUNCTION isValidUser(
    f_user_id    IN  NUMBER
)
RETURN VARCHAR2;


 -- --------------------------------------------------------------
-- IS VALID STATUS
--
-- Used to check if the status code exists
--
-- --------------------------------------------------------------
FUNCTION isValidStatus(
    f_status  IN  VARCHAR2
)
RETURN VARCHAR2;


 -- --------------------------------------------------------------
-- IS VALID LABEL
--
-- Used to check if the label exists
--
-- --------------------------------------------------------------
FUNCTION isValidLabel(
    f_label  IN  VARCHAR2
)
RETURN VARCHAR2;



-----------------------------------------
-- PROCEDURES
-----------------------------------------
--

PROCEDURE Validate_NotNULL_NUMBER (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2);

PROCEDURE Validate_NotNULL_VARCHAR2 (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2);


PROCEDURE  Validate_Content_Type_Status (
   	p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_Content_Type_Status	IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2);

PROCEDURE  Validate_appl_short_name (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_appl_short_name		IN 		VARCHAR2,
		x_application_id		OUT NOCOPY 	NUMBER,
		X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2);

PROCEDURE  Validate_application_id (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_application_id		IN 		NUMBER,
		X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2);

PROCEDURE  Validate_Content_Type_Code (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_Content_type_Code		IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2);


PROCEDURE  Validate_Data_Type_Code (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_Data_type_Code		IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2);

PROCEDURE  Validate_Default_value (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
		p_data_type_code 		IN 		VARCHAR2,
   		p_Default_value			IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2);

PROCEDURE  Validate_Reference_Code (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
		p_data_type_code 		IN 		VARCHAR2,
   		p_Reference_Code		IN 		VARCHAR2,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2);

PROCEDURE  Validate_Min_Max_Instances (
   		p_init_msg_list			IN 		VARCHAR2 := FND_API.G_FALSE,
   		p_Max_Instances			IN 		NUMBER,
		p_Min_Instances			IN 		NUMBER,
    	X_Return_Status         OUT NOCOPY   	VARCHAR2,
   		X_Msg_Count             OUT NOCOPY   	NUMBER,
    	X_Msg_Data              OUT NOCOPY   	VARCHAR2);


PROCEDURE	Validate_Resource (
        		p_init_msg_list	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        		p_resource_id	IN NUMBER,
        		p_resource_type IN VARCHAR2,
        		x_return_status OUT NOCOPY VARCHAR2,
                x_msg_count     OUT NOCOPY NUMBER,
                x_msg_data      OUT NOCOPY VARCHAR2);

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
RETURN VARCHAR2;

-- --------------------------------------------------------------
-- IBC_VALIDATE_PVT.getItemBaseLanguage
--
-- Get the base language for the content item
--
-- --------------------------------------------------------------
FUNCTION getItemBaseLanguage(f_content_item_id IN NUMBER)
RETURN VARCHAR2;


END Ibc_Validate_Pvt;


 

/
