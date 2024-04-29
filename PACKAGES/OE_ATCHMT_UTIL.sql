--------------------------------------------------------
--  DDL for Package OE_ATCHMT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ATCHMT_UTIL" AUTHID CURRENT_USER as
/* $Header: OEXUATTS.pls 120.0 2005/06/01 00:53:03 appldev noship $ */

-- Document Entities - corresponds to data_object_code in fnd_document_entities
-- and oe_ak_objects_ext table
G_DOC_ENTITY_ORDER_HEADER     constant varchar2(30) := 'OE_ORDER_HEADERS';
G_DOC_ENTITY_ORDER_LINE  	constant varchar2(30) := 'OE_ORDER_LINES';

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

--  Start of Comments
--  API name    Apply_Automatic_Attachments
--  Type        Util
--
--  Parameters
--	p_entity_code	: entity to which automatic attachments are to be applied
--					(OE_GLOBALS.G_ENTITY_HEADER/OE_GLOBALS.G_ENTITY_LINE)
--	p_entity_id	: primary key value for the entity (header_id/line_id)
--	p_is_user_action	: if 'N', then apply attachments only if profile
--					  	OE_APPLY_AUTOMATIC_ATCHMT = 'Y' and no messages are
--						added after attachments are applied
--					  if 'Y', then apply attachments irrespective of the
--						profile and add information messages after
--						attachments are applied.
-- 	x_return_status	: standard API return status
--
--  Notes
--
--  End of Comments
------------------------------------------
PROCEDURE Apply_Automatic_Attachments
(
 p_init_msg_list				in   varchar2 default fnd_api.g_false,
 p_entity_code                     in   varchar2,
 p_entity_id                       in   number,
 p_is_user_action				in   varchar2 default 'Y',
x_attachment_count out nocopy number,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

);
------------------------------------------


--  Start of Comments
--  API name    Delete_Attachments
--  Type        Util
--
--  Parameters
--	p_entity_code	: entity for which attachments are to be deleted
--					(OE_GLOBALS.G_ENTITY_HEADER/OE_GLOBALS.G_ENTITY_LINE)
--	p_entity_id	: primary key value for the entity (header_id/line_id)
-- 	x_return_status	: standard API return status
--
--  Notes
--
--  End of Comments
------------------------------------------
PROCEDURE Delete_Attachments
(
 p_entity_code					in   varchar2,
 p_entity_id					in	number,
x_return_status out nocopy varchar2

);
------------------------------------------


--  Start of Comments
--  API name    Copy_Attachments
--  Type        Util
--
--  Parameters
--	p_entity_code	: copy attachments for this entity
--					(OE_GLOBALS.G_ENTITY_HEADER/OE_GLOBALS.G_ENTITY_LINE)
--	p_from_entity_id	: PK value of entity to be copied FROM (header_id/line_id)
--	p_to_entity_id		: PK value of entity to be copied TO (header_id/line_id)
--	p_manual_attachments_only	: if 'Y' only the manual attachments on	the
--						FROM entity will be copied else ALL are copied
-- 	x_return_status	: standard API return status
--  End of Comments
------------------------------------------
PROCEDURE Copy_Attachments
(
 p_entity_code			in   varchar2,
 p_from_entity_id		in   number ,
 p_to_entity_id		in  	number ,
 p_manual_attachments_only		in   varchar2 default 'N',
x_return_status out nocopy varchar2

);
------------------------------------------


--  Start of Comments
--  API name    Add_Attachment
--  Type        Uitl
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
------------------------------------
PROCEDURE Add_Attachment
(
 p_api_version		in   number,
 p_entity_code  		in   varchar2,
 p_entity_id	  	in   number,
 p_document_desc    	in   varchar2 default null,
 p_document_text  	in   varchar2 default null,
 p_category_id  		in   number   default null,
 p_document_id   		in   number default null,
x_attachment_id out nocopy number,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

);
------------------------------------


END OE_Atchmt_UTIL;

 

/
