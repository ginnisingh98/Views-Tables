--------------------------------------------------------
--  DDL for Package OE_ORDER_BOOK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_BOOK_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUBOKS.pls 120.1.12010000.1 2008/07/25 07:54:48 appldev ship $ */

PROCEDURE Check_Booking_Holds
		(p_header_id	 	IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

		);

PROCEDURE BOOK_ORDER
        (p_api_version_number           IN NUMBER
        ,p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE
        ,p_header_id                    IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

        );

PROCEDURE Complete_Book_Eligible
        (p_api_version_number           IN NUMBER
        ,p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE
        ,p_header_id                    IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

        );

PROCEDURE Book_Multiple_Orders
        (p_api_version_number           IN NUMBER
        ,p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE
        ,p_header_id_list               IN OE_GLOBALS.Selected_Record_Tbl
        ,p_header_count                 IN NUMBER
,x_error_count OUT NOCOPY NUMBER

,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

        );

END OE_ORDER_BOOK_UTIL;

/
