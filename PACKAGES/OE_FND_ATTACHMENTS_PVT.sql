--------------------------------------------------------
--  DDL for Package OE_FND_ATTACHMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FND_ATTACHMENTS_PVT" AUTHID CURRENT_USER as
/* $Header: OEXVATTS.pls 120.0.12010000.1 2008/07/25 07:58:26 appldev ship $ */

-- structure used to store attachment addition rule
TYPE Attachment_Rule_Rec_Type IS RECORD
(
    document_id			     number,
    group_number                   number,
    attribute_code			     varchar2(30),
    column_name                    varchar2(30),
    data_type 		          	varchar2(30),
    included_in_dSQL		     boolean default FALSE,
    include_in_Fetch               boolean default FALSE,
    required_value		     	varchar2(50),
    actual_value			     varchar2(50),
    rule_valid			     	boolean default FALSE
   );

TYPE Attachment_Rule_Tbl_Type IS TABLE OF Attachment_Rule_Rec_Type
INDEX BY BINARY_INTEGER;

--  Start of Comments
--  API name    Add_Attachments_Automatic
--  Type        Util
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
--   this procedure will evaluvate all attachment additions rules that
--   are defined on the enity(p_entity_name) and add all the qualified
--   documents as automatic attachments to the entity/pk?_values
--   the count of documents that are attached will be returned in
--   x_attachment_count.
--  End of Comments
---------------------------------------------------------------------
PROCEDURE Add_Attachments_Automatic
(
 p_api_version                      in   number,
 p_entity_name                      in   varchar2,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_commit						 in   varchar2 := fnd_api.G_FALSE,
x_attachment_count out nocopy number,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

);

--  Start of Comments
--  API name    Add_Attachment
--  Type        Util
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
--   this procedure will accept a document_id and attach it to the given
--   enity/pk?_values
--  End of Comments
---------------------------------------------------------------------
PROCEDURE Add_Attachment
(
 p_api_version				in   number,
 p_entity_name				in   varchar,
 p_pk1_value                  in   varchar2,
 p_pk2_value                  in   varchar2 default null,
 p_pk3_value                  in   varchar2 default null,
 p_pk4_value                  in   varchar2 default null,
 p_pk5_value                  in   varchar2 default null,
 p_automatic_flag			in   varchar2 default 'N',
 p_document_id				in   number,
 p_validate_flag			in   varchar2 default 'Y',
x_attachment_id out nocopy number,

x_return_status out nocopy varchar2,

x_msg_count out nocopy number,

x_msg_data out nocopy varchar2

);

--  Start of Comments
--  API name    Delete_Attachments
--  Type        PRIVATE
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
---------------------------------------------------------------------
PROCEDURE Delete_Attachments
(
 p_api_version                      in   number,
 p_entity_name                      in   varchar2,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_automatic_atchmts_only		 in   varchar2 default 'N',
x_return_status out nocopy varchar2

);

END oe_fnd_attachments_pvt;

/
