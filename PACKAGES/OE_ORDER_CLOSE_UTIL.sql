--------------------------------------------------------
--  DDL for Package OE_ORDER_CLOSE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_CLOSE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUCLOS.pls 120.0.12000000.1 2007/01/16 22:01:58 appldev ship $ */

PROCEDURE CLOSE_ORDER
        (p_api_version_number           IN NUMBER
        ,p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE
        ,p_header_id                    IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

        );

PROCEDURE CLOSE_LINE
        (p_api_version_number           IN NUMBER
        ,p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE
        ,p_line_id                    	IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

        );

END OE_ORDER_CLOSE_UTIL;

 

/
