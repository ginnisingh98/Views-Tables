--------------------------------------------------------
--  DDL for Package OE_PORTAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PORTAL_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUPORS.pls 120.0 2005/05/31 23:51:50 appldev noship $ */

PROCEDURE get_values
(   p_header_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   x_header_val_rec_type         OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Val_Rec_Type
);

PROCEDURE lines
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_line_tbl                    IN OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type
,   p_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE set_header_cache
(   p_header_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
);

PROCEDURE process_requests_and_notify
(   p_return_status                 OUT NOCOPY VARCHAR2
 );

PROCEDURE get_header
    (
     p_header_id IN NUMBER,
     x_header_rec                    OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.HEADER_Rec_Type
    );
PROCEDURE get_line
    (
     p_line_id IN NUMBER,
     x_line_rec                    OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Rec_Type
    );

END OE_Portal_Util;

 

/
