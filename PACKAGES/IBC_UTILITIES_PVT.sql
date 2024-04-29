--------------------------------------------------------
--  DDL for Package IBC_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_UTILITIES_PVT" AUTHID CURRENT_USER as
/* $Header: ibcvutls.pls 120.5 2005/08/08 14:53:18 appldev ship $ */

-----------------------------------------
-- Global Variables
-----------------------------------------

-- Global variables for package type, used in Handle_Exceptions
G_PVT                     CONSTANT CHAR(4)  := '_PVT';
G_INT                     CONSTANT CHAR(4)  := '_INT';
G_PUB                     CONSTANT CHAR(4)  := '_PUB';

-- Global variables for Content Item XML Attributes
G_XML_ID                  CONSTANT CHAR(2)  := 'id';
G_XML_VERSION             CONSTANT CHAR(7)  := 'version';
G_XML_IRCODE              CONSTANT CHAR(6)  := 'ircode';
G_XML_REF                 CONSTANT CHAR(3)  := 'ref';
G_XML_URL                 CONSTANT CHAR(3)  := 'url';
G_XML_AVAIL               CONSTANT CHAR(9)  := 'available';
G_XML_EXPIRE              CONSTANT CHAR(10) := 'expiration';
G_XML_FILE                CONSTANT CHAR(4)  := 'file';
G_XML_MIME                CONSTANT CHAR(8)  := 'mimeType';
G_XML_DEFAULT_MIME        CONSTANT CHAR(15) := 'defaultMimeType';
G_XML_REND                CONSTANT CHAR(13) := 'renditionName';
G_XML_ENC                 CONSTANT CHAR(7)  := 'encrypt';

-- Global variables for Content Item XML URL parameters
G_XML_URL_FID             CONSTANT CHAR(6)  := 'fileId';
G_XML_URL_CID             CONSTANT CHAR(7)  := 'cItemId';
G_XML_URL_CVERID          CONSTANT CHAR(10) := 'cItemVerId';
G_XML_URL_LB              CONSTANT CHAR(5)  := 'label';
G_XML_URL_ENC             CONSTANT CHAR(7)  := 'encrypt';
G_XML_URL_LANG            CONSTANT CHAR(8)  := 'language';
G_XML_URL_MIME            CONSTANT CHAR(8)  := 'mimeType';

-- Global variables for Renditions
G_REND_LOOKUP_TYPE        CONSTANT CHAR(14)  := 'IBC_RENDITIONS';
G_REND_UNKNOWN_MIME       CONSTANT CHAR(17)  := 'UNKNOWN_MIME_TYPE';

-- Global variable for others exception
G_EXC_OTHERS              CONSTANT NUMBER   := 100;

-- audit action constants
G_ALA_COPY                CONSTANT CHAR(6) := 'COPY';
G_ALA_CREATE              CONSTANT CHAR(6) := 'CREATE';
G_ALA_UPDATE              CONSTANT CHAR(6) := 'UPDATE';
G_ALA_ARCHIVE             CONSTANT CHAR(7) := 'ARCHIVE';
G_ALA_REMOVE              CONSTANT CHAR(6) := 'REMOVE';
G_ALA_MOVE                CONSTANT CHAR(4) := 'MOVE';
G_ALA_REJECT              CONSTANT CHAR(6) := 'REJECT';
G_ALA_SUBMIT              CONSTANT CHAR(6) := 'SUBMIT';
G_ALA_UNARCHIVE           CONSTANT CHAR(9) := 'UNARCHIVE';
G_ALA_APPROVE             CONSTANT CHAR(7) := 'APPROVE';
G_ALA_STOP                CONSTANT CHAR(4) := 'STOP';

-- audit object constants
G_ALO_CONTENT_TYPE        CONSTANT CHAR(5) := 'CTYPE';
G_ALO_CONTENT_ITEM        CONSTANT CHAR(5) := 'CITEM';
G_ALO_CITEM_VERSION       CONSTANT CHAR(9) := 'CIVERSION';
G_ALO_ATTRIBUTE_BUNDLE    CONSTANT CHAR(7) := 'ABUNDLE';
G_ALO_ASSOCIATION         CONSTANT CHAR(5) := 'ASSOC';
G_ALO_COMPONENT           CONSTANT CHAR(4) := 'COMP';
G_ALO_LABEL               CONSTANT CHAR(5) := 'LABEL';


/****************************************************
-------------FUNCTIONS--------------------------------------------------------------------------
****************************************************/
-- --------------------------------------------------------------
-- GET ENCODING
--
-- Used to get the internet character set encoding based on DB
-- character set.
-- --------------------------------------------------------------
FUNCTION getEncoding
        RETURN VARCHAR2;



FUNCTION IBC_DECODE(l_base_date  DATE, comp1   DATE,
        date1   DATE, date2   DATE)
RETURN DATE;


-- --------------------------------------------------------------
-- get_citem_name
--
-- Given content_item_id it returns content item name of
-- the last version for the current language
--
-- --------------------------------------------------------------
FUNCTION get_citem_name(p_content_item_id    IN   NUMBER)
RETURN VARCHAR2;

-- --------------------------------------------------------------
-- get_directory_name
--
-- Given directory_node_id it returns directory name
-- for the current language
--
-- --------------------------------------------------------------
FUNCTION get_directory_name(p_directory_node_id  IN   NUMBER)
RETURN VARCHAR2 ;

-- --------------------------------------------------------------
-- GET RESOURCE NAME
--
-- Used to get resource name by id
--
-- --------------------------------------------------------------
FUNCTION getResourceName(
    f_resource_id    IN   NUMBER
    ,f_resource_type IN   VARCHAR2
)
RETURN VARCHAR2;

-- --------------------------------------------------------------
-- GET DIRECTORY ID
--
-- Get Directory ID given a Directory Path and node type
--
-- --------------------------------------------------------------
FUNCTION get_directory_node_id(p_directory_path    IN   VARCHAR2,
                               p_node_type         IN   VARCHAR2)
RETURN VARCHAR2;

-- --------------------------------------------------------------
-- GET Content Item Keywords
--
-- Used to get content item keywords by content_item_id
--
-- --------------------------------------------------------------

FUNCTION getCItemKeyWords(
   pcItemId IN   NUMBER
)
RETURN VARCHAR2;

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
--                  p_language_code         IN   VARCHAR2
--                  p_language_description  OUT NOCOPY VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_Language_Description (
        p_language_code         IN   VARCHAR2
       ,p_language_description  OUT NOCOPY      VARCHAR2
);




--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Attribute_Bundle
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate the user-defined attributes of IBC output xml to the
--                 incoming CLOB.
--    Parameters :
--    IN         : p_file_id                    IN   NUMBER
--                 p_xml_clob_loc               IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Attribute_Bundle (
        p_file_id       IN       NUMBER,
        p_xml_clob_loc  IN OUT  NOCOPY CLOB
);




--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Citem_Open_Tag
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate the open tags of IBC output xml to the
--                 incoming CLOB. Information includes: version number,
--                 reference code. (Not including name, description,
--                 renditions).
--    Parameters :
--    IN         : p_content_type_code          IN      VARCHAR2
--                 p_content_item_id            IN      NUMBER
--                 p_version_number             IN      NUMBER
--                      DEFAULT 0
--                 p_item_reference_code        IN      VARCHAR2
--                 p_item_label                 IN      VARCHAR2
--                       DEFAULT NULL
--                 p_xml_clob_loc               IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Citem_Open_Tag (
        p_content_type_code             IN        VARCHAR2,
        p_content_item_id               IN        NUMBER,
        p_version_number                IN        NUMBER DEFAULT 0,
        p_item_reference_code           IN        VARCHAR2,
        p_item_label                    IN        VARCHAR2 DEFAULT NULL,
        p_xml_clob_loc                  IN OUT NOCOPY   CLOB
);




--------------------------------------------------------------------------------
---------------------------------- NEW PROC ------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Citem_Open_Tags
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate the open tags of IBC output xml to the
--                 incoming CLOB.
--    Parameters :
--    IN         : p_content_type_code          IN      VARCHAR2
--                 p_content_item_id            IN      NUMBER
--                 p_citem_version_id           IN      NUMBER
--                 p_item_label                 IN      VARCHAR2
--                       DEFAULT NULL
--                 p_lang_code                  IN      VARCHAR2
--                       DEFAULT NULL
--                 p_version_number             IN      NUMBER
--                      DEFAULT 0
--                 p_start_date                 IN      DATE
--                 p_end_date                   IN      DATE
--                 p_item_reference_code        IN      VARCHAR2
--                 p_encrypt_flag               IN      VARCHAR2
--                 p_content_item_name          IN      VARCHAR2
--                 p_description                IN      VARCHAR2
--                 p_attachment_attribute_code  IN      VARCHAR2
--                      DEFAULT NULL
--                 p_attachment_file_id         IN      NUMBER
--                      DEFAULT NULL
--                 p_attachment_file_name       IN      VARCHAR2
--                      DEFAULT NULL
--                 p_default_mime_type          IN      VARCHAR2
--                      DEFAULT NULL
--                 p_is_preview                 IN      VARCHAR2
--                      DEFAULT FND_API.G_FALSE
--                 p_xml_clob_loc               IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Citem_Open_Tags (
        p_content_type_code             IN       VARCHAR2,
        p_content_item_id               IN       NUMBER,
        p_citem_version_id              IN       NUMBER,
        p_item_label                    IN       VARCHAR2 DEFAULT NULL,
        p_lang_code                     IN       VARCHAR2 DEFAULT NULL,
        p_version_number                IN       NUMBER DEFAULT 0,
        p_start_date                    IN       DATE,
        p_end_date                      IN       DATE,
        p_item_reference_code           IN       VARCHAR2,
        p_encrypt_flag                  IN       VARCHAR2,
        p_content_item_name             IN       VARCHAR2,
        p_description                   IN       VARCHAR2,
        p_attachment_attribute_code     IN       VARCHAR2 DEFAULT NULL,
        p_attachment_file_id            IN       NUMBER DEFAULT NULL,
        p_attachment_file_name          IN       VARCHAR2 DEFAULT NULL,
        p_default_mime_type             IN       VARCHAR2 DEFAULT NULL,
        p_is_preview                    IN       VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_xml_clob_loc                  IN OUT  NOCOPY  CLOB
);


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Citem_Open_Tags
--    Function   : This is for BACKWARD COMPATIBILITY for Admin Usage (Similar to above).
--------------------------------------------------------------------------------
PROCEDURE Build_Citem_Open_Tags (
        p_content_type_code             IN        VARCHAR2,
        p_content_item_id               IN        NUMBER,
        p_version_number                IN        NUMBER DEFAULT 0,
        p_item_reference_code           IN        VARCHAR2,
        p_content_item_name             IN        VARCHAR2 DEFAULT NULL,
        p_description                   IN        VARCHAR2 DEFAULT NULL,
        p_root_tag_only_flag            IN        VARCHAR2 DEFAULT FND_API.G_TRUE,
        p_xml_clob_loc                  IN OUT  NOCOPY CLOB
);




--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Close_Tag
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate the closing tags of IBC output xml to the
--                 incoming CLOB.
--    Parameters :
--    IN         : p_close_tag                  IN      VARCHAR2
--                 p_xml_clob_loc               IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Close_Tag (
        p_close_tag             IN        VARCHAR2,
        p_xml_clob_loc          IN OUT  NOCOPY CLOB
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Compound_Item_Open_Tag
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate open attribute tag for a commpounded
--                 to the incoming CLOB.
--    Parameters :
--    IN         : p_attribute_type_code        IN      VARCHAR2
--                 p_content_item_id            IN      NUMBER
--                 p_item_label                 IN      VARCHAR2
--                       DEFAULT NULL
--                 p_encrypt_flag               IN      VARCHAR2
--                 p_xml_clob_loc               IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Compound_Item_Open_Tag (
        p_attribute_type_code   IN        VARCHAR2,
        p_content_item_id       IN        NUMBER,
        p_item_label            IN        VARCHAR2 DEFAULT NULL,
        p_encrypt_flag          IN        VARCHAR2,
        p_xml_clob_loc          IN OUT   NOCOPY CLOB
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Preview_Cpnt_Open_Tag
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate open attribute tag for a component item
--                 to the incoming CLOB. The Url attribute of the open tag
--                 refers to the Preview Jsp (IBC_UTILITIES_PUB.G_PCITEM_SERVLET_URL)
--                 with both content item id and content item version id as parameters.
--    Parameters :
--    IN         : p_attribute_type_code        IN      VARCHAR2
--                 p_content_item_id            IN      NUMBER
--                 p_content_item_version_id    IN      NUMBER
--                 p_encrypt_flag               IN      VARCHAR2
--                 p_xml_clob_loc               IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Preview_Cpnt_Open_Tag (
        p_attribute_type_code           IN        VARCHAR2,
        p_content_item_id               IN        NUMBER,
        p_content_item_version_id       IN        NUMBER,
        p_encrypt_flag                  IN        VARCHAR2,
        p_xml_clob_loc                  IN OUT   NOCOPY CLOB
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Compound_Item_References
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate all the compounded item references of
--                 the content item to the incoming CLOB.
--    Parameters :
--    IN         : p_citem_version_id           IN      NUMBER
--                 p_item_label                 IN      VARCHAR2
--                       DEFAULT NULL
--                 p_xml_clob_loc               IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Compound_Item_References (
        p_citem_version_id      IN        NUMBER,
        p_item_label            IN        VARCHAR2 DEFAULT NULL,
        p_xml_clob_loc          IN OUT  NOCOPY CLOB
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Build_Preview_Cpnt_References
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Concatenate all the compounded item references of
--                 the content item to the incoming CLOB. All the Urls of
--                 the references will refer to the Preview Jsp (IBC_UTILITIES_PUB.G_PCITEM_SERVLET_URL)
--                 with both content item id and content item version id as parameters.
--    Parameters :
--    IN         : p_citem_version_id           IN      NUMBER
--                 p_xml_clob_loc               IN OUT  NOCOPY CLOB
--------------------------------------------------------------------------------
PROCEDURE Build_Preview_Cpnt_References (
        p_citem_version_id      IN        NUMBER,
        p_xml_clob_loc          IN OUT   NOCOPY CLOB
);


PROCEDURE Get_Messages (p_message_count IN    NUMBER,
                        x_msgs          OUT NOCOPY VARCHAR2);

PROCEDURE Handle_Exceptions(
                P_API_NAME        IN    VARCHAR2,
                P_PKG_NAME        IN    VARCHAR2,
                P_EXCEPTION_LEVEL IN    NUMBER   DEFAULT NULL,
                P_SQLCODE         IN    NUMBER   DEFAULT NULL,
                P_SQLERRM         IN    VARCHAR2 DEFAULT NULL,
                P_PACKAGE_TYPE    IN    VARCHAR2,
                X_MSG_COUNT       OUT  NOCOPY NUMBER,
                X_MSG_DATA        OUT  NOCOPY VARCHAR2,
                X_RETURN_STATUS   OUT  NOCOPY VARCHAR2
);

PROCEDURE Handle_Ret_Status(p_return_Status     VARCHAR2);

PROCEDURE insert_attachment(
    x_file_id           OUT NOCOPY  NUMBER
    ,p_file_data        IN   BLOB
    ,p_file_name        IN   VARCHAR2
    ,p_mime_type        IN   VARCHAR2
    ,p_file_format      IN   VARCHAR2
    ,p_program_tag      IN   VARCHAR2 DEFAULT NULL
    ,x_return_status    OUT NOCOPY VARCHAR2
);

PROCEDURE insert_attribute_bundle(
   x_lob_file_id        OUT NOCOPY NUMBER
   ,p_new_bundle        IN   CLOB
   ,x_return_status     OUT NOCOPY VARCHAR2
);



PROCEDURE log_action(
  p_activity       IN   VARCHAR2
  ,p_parent_value  IN   VARCHAR2
  ,p_object_type   IN   VARCHAR2
  ,p_object_value1 IN   VARCHAR2
  ,p_object_value2 IN   VARCHAR2 DEFAULT NULL
  ,p_object_value3 IN   VARCHAR2 DEFAULT NULL
  ,p_object_value4 IN   VARCHAR2 DEFAULT NULL
  ,p_object_value5 IN   VARCHAR2 DEFAULT NULL
  ,p_description   IN   VARCHAR2 DEFAULT NULL
);



PROCEDURE touch_attribute_bundle(
   x_lob_file_id OUT NOCOPY NUMBER
   ,p_exp_date IN   DATE DEFAULT NULL
   ,p_program_tag IN   VARCHAR2 DEFAULT NULL
   ,x_return_status OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Post Insert Attach
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Is called from FNDGFU as Call Back pkg. for
--                 Attachment file type.
--                 the content item to the incoming CLOB.
--    Parameters :
--    IN         : p_file_id            IN      NUMBER
--------------------------------------------------------------------------------
PROCEDURE post_insert_attach(p_file_id IN   NUMBER);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Post Insert Attrib
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Is called from FNDGFU as Call Back pkg. for
--                 Attachment file type.
--                 the content item to the incoming CLOB.
--    Parameters :
--    IN         : p_file_id            IN      NUMBER
-------------------------------------------------------------------------------
PROCEDURE post_insert_attrib(p_file_id IN   NUMBER);


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
      ,p_current_user_id    IN   NUMBER    DEFAULT NULL
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(Check_Current_User, WNDS, WNPS);

  ---------------------------------------------------------
  -- FUNCTION: g_true
  -- DESCRIPTION: Returns FND_API.g_true, it's useful
  --              to access the value from SQL stmts
  ---------------------------------------------------------
  FUNCTION g_true RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(g_true, WNDS, WNPS, TRUST);

  ---------------------------------------------------------
  -- FUNCTION: g_false
  -- DESCRIPTION: Returns FND_API.g_false, it's useful
  --              to access the value from SQL stmts
  ---------------------------------------------------------
  FUNCTION g_false RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(g_false, WNDS, WNPS, TRUST);

  ---------------------------------------------------------
  -- FUNCTION: Is_Name_Already_Used
  -- DESCRIPTION: Returns TRUE/FALSE, if the name
  --              is already used by a different item or
  --              directory.
  ---------------------------------------------------------
  FUNCTION Is_Name_Already_Used(p_dir_node_id         IN   NUMBER,
                                p_name                IN   VARCHAR2,
                                p_language            IN   VARCHAR2,
                                p_chk_content_item_id IN   NUMBER DEFAULT NULL,
                                p_chk_dir_node_id     IN   NUMBER DEFAULT NULL,
                                x_object_type         OUT NOCOPY VARCHAR2,
                                x_object_id           OUT NOCOPY NUMBER
                               )
  RETURN BOOLEAN;

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Create_Autonomous_renditions
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Called from Content Item Screens/AM to create an autonomous
--                 Transaction for FND LOBS
-------------------------------------------------------------------------------
PROCEDURE Create_Autonomous_Upload(p_file_name      IN    VARCHAR2,
                                       p_mime_type      IN    VARCHAR2,
                                       p_file_format    IN    VARCHAR2,
                                       p_program_tag    IN    VARCHAR2,
                                       x_return_status  OUT  NOCOPY VARCHAR2,
                                       x_file_id        OUT  NOCOPY NUMBER
                                       );

--PRAGMA AUTONOMOUS_TRANSACTION;


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
                         );


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : getAttachclob
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns the CLOB from FND_LOBS for the attachment files
--
-------------------------------------------------------------------------------
FUNCTION getAttachclob (p_file_id   NUMBER) RETURN CLOB;

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Replace_Special_Chars
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns the VARCHAR2
--
-------------------------------------------------------------------------------
FUNCTION Replace_Special_Chars (p_string IN VARCHAR2) RETURN VARCHAR2;

END Ibc_Utilities_Pvt;

 

/
