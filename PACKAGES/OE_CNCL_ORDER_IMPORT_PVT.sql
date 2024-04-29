--------------------------------------------------------
--  DDL for Package OE_CNCL_ORDER_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_ORDER_IMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVCIMS.pls 120.1 2005/07/18 11:13:10 sphatarp noship $ */

--  Start of Comments
--  API name    "Cancelled" Order Import
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_CNCL_ORDER_IMPORT_PVT';

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
, error_flag				varchar2(1)
, status_flag				varchar2(1)
, interface_status			varchar2(1000)
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
  ,p_org_id                     IN  NUMBER  DEFAULT NULL
  ,p_msg_count                  OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,p_msg_data                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,p_return_status              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

END OE_CNCL_ORDER_IMPORT_PVT;

 

/
