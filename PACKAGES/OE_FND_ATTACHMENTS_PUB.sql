--------------------------------------------------------
--  DDL for Package OE_FND_ATTACHMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FND_ATTACHMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPATTS.pls 120.0 2005/06/01 01:17:45 appldev noship $ */
-- document data types
G_DATATYPE_SHORT_TEXT   constant number:= 1;
G_DATATYPE_LONG_TEXT    constant number:= 2;
G_DATATYPE_IMAGE        constant number:= 3;
G_DATATYPE_OLE_OBJECT   constant number:= 4;
G_DATATYPE_WEB_PAGE     constant number:= 5;

-- document security types
G_SECURITY_TYPE_ORG   constant number := 1;
G_SECURITY_TYPE_SOB   constant number := 2;
G_SECURITY_TYPE_BU    constant number := 3;
G_SECURITY_TYPE_NONE  constant number := 4;

-- api process flags
G_RETURN_ON_ERROR	   constant  varchar2(20) := 'RETURN_ON_ERROR';
G_CONTINUE_ON_ERROR  constant  varchar2(20) := 'CONTINUE_ON_ERROR';
-------------------------------------------------------

--  Start of Comments
--  API name    Add_Attachments_Automatic
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Add_Attachments_Automatic
(
 p_api_version                      in   number,
 p_entity_name                      in   varchar2,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_commit					in   varchar2 default fnd_api.G_FALSE,
 x_attachment_count                 out NOCOPY /* file.sql.39 change */  number,
 x_return_status                    out NOCOPY /* file.sql.39 change */  varchar2,
 x_msg_count                        out NOCOPY /* file.sql.39 change */  number,
 x_msg_data                         out NOCOPY /* file.sql.39 change */  varchar2
);
-------------------------------------------------------

--  Start of Comments
--  API name    Add_Attachment
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Add_Attachment
(
 p_api_version				in   number,
 p_entity_name				in   varchar,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_automatic_flag				in   varchar2 default 'N',
 p_commit					in   varchar2 default fnd_api.G_FALSE,
 p_document_id				in   number,
 x_attachment_id				out NOCOPY /* file.sql.39 change */  number,
 x_return_status                    out NOCOPY /* file.sql.39 change */  varchar2,
 x_msg_count                        out NOCOPY /* file.sql.39 change */  number,
 x_msg_data                         out NOCOPY /* file.sql.39 change */  varchar2
);


TYPE Documet_Rec_Type IS RECORD
(
    document_id           number,
    datatype_id           number,
    content_short_text    varchar2(2000),
    category_id           number,
    security_type         number default G_SECURITY_TYPE_NONE,
    security_id		  number default NULL,
    publish_flag          varchar2(1)  default 'Y',
    image_type            varchar2(10) default NULL,
    storage_type          number 	   default NULL,
    usage_type            varchar2(1),
    language              varchar2(30),
    description           varchar2(255),
    file_name             varchar2(255) default NULL,
    start_date_active     date default sysdate,
    end_date_active       date default null,
    attachment_id		  number
);

TYPE Documet_Tbl_Type IS TABLE OF Documet_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Start of Comments
--  API name    Add_Attachments
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


PROCEDURE Add_Attachments
(
 p_api_version                      in   number,
 p_entity_name                      in   varchar2,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_process_flag				in   varchar2 default G_RETURN_ON_ERROR,
 p_automatic_attachment			in   varchar2 default 'N',
 p_commit					in   varchar2 default fnd_api.G_FALSE,
 p_document_tbl   		      in out NOCOPY /* file.sql.39 change */ Documet_Tbl_Type,
 x_return_status                    out NOCOPY /* file.sql.39 change */  varchar2,
 x_msg_count                        out NOCOPY /* file.sql.39 change */  number,
 x_msg_data                         out NOCOPY /* file.sql.39 change */  varchar2
);

-------------------------------------
--  Start of Comments
--  API name    Create_Short_Text_Document
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


PROCEDURE Create_Short_Text_Document
(
 p_api_version                      in   number,
 p_document_text				in   varchar2,
 p_document_category                in   number,
 p_document_description			in   varchar2,
 p_language					in   varchar2 default null,
 p_security_type                    in   number default G_SECURITY_TYPE_NONE,
 p_security_id                      in   number default null,
 p_publish_flag                     in   varchar2 default 'Y',
 p_usage_type                       in   varchar2,
 p_start_date_active			in   date default sysdate,
 p_end_date_active			in   date default null,
 p_commit					in   varchar2 default fnd_api.G_FALSE,
 x_document_id                      out NOCOPY /* file.sql.39 change */  number,
 x_return_status                    out NOCOPY /* file.sql.39 change */  varchar2,
 x_msg_count                        out NOCOPY /* file.sql.39 change */  number,
 x_msg_data                         out NOCOPY /* file.sql.39 change */  varchar2
);
----------------------------------------
TYPE Copy_Attachments_Rec_Type IS RECORD
(   from_entity_name              varchar2(30),
    from_pk1_value                varchar2(30),
    from_pk2_value                varchar2(30) default null,
    from_pk3_value                varchar2(30) default null,
    from_pk4_value                varchar2(30) default null,
    from_pk5_value                varchar2(30) default null,
    to_entity_name                varchar2(30),
    to_pk1_value                  varchar2(30),
    to_pk2_value                  varchar2(30) default null,
    to_pk3_value                  varchar2(30) default null,
    to_pk4_value                  varchar2(30) default null,
    to_pk5_value                  varchar2(30) default null
);

TYPE Copy_Attachments_Tbl_Type IS TABLE OF Copy_Attachments_Rec_Type
    INDEX BY BINARY_INTEGER;

-------------------------------------
--  Start of Comments
--  API name    Copy_Attachments
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


PROCEDURE Copy_Attachments
(
 p_api_version                      in   number,
 p_copy_attachments_tbl             in   Copy_Attachments_Tbl_Type
);

END oe_fnd_attachments_pub;


 

/
