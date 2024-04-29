--------------------------------------------------------
--  DDL for Package OE_UPDATE_LINE_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_UPDATE_LINE_ACK_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXULAUS.pls 120.0 2005/06/01 01:36:53 appldev noship $ */

G_PKG_NAME         VARCHAR2(30) := 'OE_Update_Line_Ack_Util';

PROCEDURE Update_Line_Ack(
   p_request_id			IN  NUMBER
  ,p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref  	IN  VARCHAR2
  ,p_orig_sys_line_ref  	IN  VARCHAR2
  ,p_orig_sys_shipment_ref  	IN  VARCHAR2
  ,p_change_sequence            IN  VARCHAR2
,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2

);

END OE_Update_Line_Ack_Util;

 

/
