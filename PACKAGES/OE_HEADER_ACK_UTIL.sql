--------------------------------------------------------
--  DDL for Package OE_HEADER_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HEADER_ACK_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUHAKS.pls 120.1 2006/03/29 16:46:34 spooruli noship $ */

PROCEDURE Insert_Row
(   p_header_rec              IN  OE_Order_Pub.Header_Rec_Type
,   p_header_val_rec          IN  OE_Order_Pub.Header_Val_Rec_Type
,   p_old_header_rec          IN  OE_Order_Pub.Header_Rec_Type
,   p_old_header_val_rec      IN  OE_Order_Pub.Header_Val_Rec_Type
,   p_reject_order            IN  VARCHAR2
,   p_ack_type                IN  VARCHAR2 := NULL
, x_return_status OUT NOCOPY VARCHAR2

);


Procedure Insert_Row
 ( p_header_rec               In   OE_Order_Pub.Header_Rec_Type,
   x_ack_type                 Out Nocopy Varchar2,
   x_return_status            Out Nocopy Varchar2
 );

PROCEDURE Delete_Row
(   p_header_id   	      IN  NUMBER,
    p_ack_type                In  Varchar2,
    p_orig_sys_document_ref   In  Varchar2 := NULL,
    p_sold_to_org_id          In  Number := NULL,
    p_sold_to_org             In  Varchar2 := NULL,
    p_change_sequence         In  Varchar2 := NULL,
    p_request_id              In  Number := NULL
);

END OE_Header_Ack_Util;

/
