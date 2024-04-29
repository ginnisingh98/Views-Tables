--------------------------------------------------------
--  DDL for Package OE_PORTAL_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PORTAL_ORDER" AUTHID CURRENT_USER AS
/* $Header: OEXPOBKS.pls 120.0 2005/05/31 23:45:50 appldev noship $ */
--  Procedure       Delete_Row
--

PROCEDURE Submit_Order
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_book_flag                     IN VARCHAR2 := 'N'
);
END Oe_Portal_Order;

 

/
