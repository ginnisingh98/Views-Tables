--------------------------------------------------------
--  DDL for Package OE_DEALS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEALS_UTIL" AUTHID CURRENT_USER as
/* $Header: OEXUDLSS.pls 120.5.12010000.1 2008/07/25 07:55:35 appldev ship $ */

FUNCTION Validate_Config(p_header_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION IS_WF_Activity(p_header_id IN NUMBER)
RETURN BOOLEAN;

--Bug 6870738 STARTS
FUNCTION HAS_SAVED_REQUEST( p_header_id IN NUMBER
                          , p_instance_id IN NUMBER
                          )
RETURN VARCHAR2;
--Bug 6870738 ends

PROCEDURE Get_Deal_Info
			( p_header_id	IN 	NUMBER
			, x_deal_status OUT NOCOPY VARCHAR2
			, x_deal_id 	OUT NOCOPY NUMBER
			) ;

PROCEDURE Complete_Compliance_Eligible
			( p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE
			, p_header_id			IN 	NUMBER
			, p_accept			IN VARCHAR2
			, p_item_type 			IN VARCHAR2
--			, x_response_id			OUT NOCOPY NUMBER
			, x_return_status OUT NOCOPY VARCHAR2
			, x_msg_count OUT NOCOPY NUMBER
			, x_msg_data OUT NOCOPY VARCHAR2
			) ;

PROCEDURE COMPLIANCE_CHECK(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);


PROCEDURE Call_Process_Order (
    p_header_id IN NUMBER
    ,x_return_status  OUT NOCOPY varchar2
);

PROCEDURE Update_Order_with_Deal
			( p_header_id			IN 	NUMBER
			, p_item_type IN VARCHAR2
			, x_return_status OUT NOCOPY VARCHAR2
			, x_msg_count OUT NOCOPY NUMBER
			, x_msg_data OUT NOCOPY VARCHAR2
			) ;

PROCEDURE CALL_DEALS_API(
           p_header_id         in NUMBER,
           p_updatable_flag    IN varchar2,
           x_redirect_function out nocopy varchar2,
           x_is_deal_compliant out nocopy varchar2,
           x_rules_desc        out nocopy varchar2,
           x_return_status     out nocopy varchar2,
           x_msg_data          out nocopy varchar2);



Procedure Update_OM_with_deal(
         source_id in number,
         source_ref_id in number,
         event in varchar2,
         x_return_status out nocopy varchar2,
         x_message_name  out nocopy varchar2);


/*PROCEDURE Open_Deal
			( p_header_id			IN 	NUMBER
			, p_item_type IN VARCHAR2
			, x_return_status OUT NOCOPY VARCHAR2
			, x_msg_count OUT NOCOPY NUMBER
			, x_msg_data OUT NOCOPY VARCHAR2
			) ;
*/
END OE_DEALS_UTIL;

/
