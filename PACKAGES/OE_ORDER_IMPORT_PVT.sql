--------------------------------------------------------
--  DDL for Package OE_ORDER_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_IMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVIMPS.pls 120.3.12010000.1 2008/07/25 08:03:42 appldev ship $ */

--  Start of Comments
--  API name    Order Import
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_ORDER_IMPORT_PVT';

TYPE Action_Rec_Type IS RECORD (
  orig_sys_line_ref                     varchar2(50)
, orig_sys_shipment_ref                 varchar2(50)
, action_code                           varchar2(30)
, entity_code                           varchar2(50)
, entity_id                             number
, hold_id                               number
, hold_type_code                       	varchar2(30)
, hold_type_id                        	number
, hold_until_date                       date
, release_reason_code                   varchar2(30)
, comments                              varchar2(2000)
, context                               varchar2(30)
, attribute1                            varchar2(240)
, attribute2                            varchar2(240)
, attribute3                            varchar2(240)
, attribute4                            varchar2(240)
, attribute5                            varchar2(240)
, attribute6                            varchar2(240)
, attribute7                            varchar2(240)
, attribute8                            varchar2(240)
, attribute9                            varchar2(240)
, attribute10                           varchar2(240)
, attribute11                           varchar2(240)
, attribute12                           varchar2(240)
, attribute13                           varchar2(240)
, attribute14                           varchar2(240)
, attribute15                           varchar2(240)
, request_id				number
, operation_code			varchar2(30)
, fulfillment_set_name                  varchar2(30)
, error_flag				varchar2(1)
, status_flag				varchar2(1)
, interface_status			varchar2(1000)
--myerrams, start, added the following fields for R12 Customer Acceptance Project
,char_param1                            varchar2(2000)
,char_param2                            varchar2(240)
,char_param3                            varchar2(240)
,char_param4                            varchar2(240)
,char_param5                            varchar2(240)
,date_param1                            date
,date_param2                            date
,date_param3                            date
,date_param4                            date
,date_param5                            date
--myerrams, end;
);

PROCEDURE Import_Order(
   p_request_id			IN  NUMBER   DEFAULT FND_API.G_MISS_NUM
  ,p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref      IN  VARCHAR2
  ,p_sold_to_org_id             IN  NUMBER   := NULL
  ,p_sold_to_org                IN  VARCHAR2 := NULL
  ,p_change_sequence      	IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  ,p_validate_only		IN  VARCHAR2 DEFAULT FND_API.G_FALSE
  ,p_init_msg_list		IN  VARCHAR2 DEFAULT FND_API.G_TRUE
  ,p_rtrim_data                 In  Varchar2 := 'N'
  ,p_org_id                     IN  NUMBER DEFAULT NULL
,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2
,p_validate_desc_flex in varchar2 default 'Y' -- bug4343612
);

END OE_ORDER_IMPORT_PVT;

/
