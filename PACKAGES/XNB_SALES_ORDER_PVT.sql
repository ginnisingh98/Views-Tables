--------------------------------------------------------
--  DDL for Package XNB_SALES_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNB_SALES_ORDER_PVT" AUTHID CURRENT_USER AS
/* $Header: XNBVPSOS.pls 120.2 2005/09/20 01:52:36 ksrikant noship $ */


   PROCEDURE check_noninvoiceable_item(	itemtype  IN VARCHAR2,
		 			itemkey   IN VARCHAR2,
		 			actid 	  IN NUMBER,
		 			funcmode  IN VARCHAR2,
					resultout OUT NOCOPY VARCHAR2);

    PROCEDURE publish_bill_to_address(	itemtype  IN VARCHAR2,
		 			itemkey   IN VARCHAR2,
		 			actid 	  IN NUMBER,
		 			funcmode  IN VARCHAR2,
					resultout OUT NOCOPY VARCHAR2);

    PROCEDURE get_bill_to_address
    (
    l_inv_to_org_id 	IN 	NUMBER ,
    l_party_id		OUT	NOCOPY NUMBER,
    l_account_id	OUT	NOCOPY NUMBER,
    l_party_number	OUT	NOCOPY VARCHAR2,
    l_party_name	OUT	NOCOPY VARCHAR2,
    l_account_number	OUT	NOCOPY VARCHAR2,
    l_account_name	OUT	NOCOPY VARCHAR2,
    l_bill_to_address	OUT	NOCOPY VARCHAR2,
    l_country		OUT	NOCOPY VARCHAR2,
    l_state		OUT	NOCOPY VARCHAR2,
    l_county		OUT	NOCOPY VARCHAR2,
    l_city		OUT	NOCOPY VARCHAR2,
    l_postal_code	OUT	NOCOPY VARCHAR2,
    x_result 		OUT	NOCOPY NUMBER
    );

        PROCEDURE create_sales_order
    (
	l_doc_id			IN 	NUMBER,
        l_party_id			IN	NUMBER,
        l_account_id			IN	NUMBER,
	l_party_number			IN	VARCHAR2,
    	l_party_name			IN 	VARCHAR2,
	l_account_number		IN	VARCHAR2,
	l_account_name			IN 	VARCHAR2,
    	l_bill_to_address		IN 	VARCHAR2,
    	l_country			IN 	VARCHAR2,
    	l_state				IN 	VARCHAR2,
    	l_county	 		IN 	VARCHAR2,
    	l_city		 		IN 	VARCHAR2,
    	l_postal_code			IN 	VARCHAR2,
    	l_primary_bill_to_flag		IN 	CHAR,
    	l_bill_to_owner_flag		IN 	CHAR,
    	x_result			OUT	NOCOPY NUMBER
    );

    PROCEDURE truncate_sales_order
    (
	    itemtype			IN VARCHAR2,
	    itemkey				IN VARCHAR2,
	    actid				IN NUMBER,
	    funcmode			IN VARCHAR2,
	    resultout			OUT NOCOPY VARCHAR2
    );

    PROCEDURE check_account
    (
	    itemtype			IN VARCHAR2,
	    itemkey				IN VARCHAR2,
	    actid				IN NUMBER,
	    funcmode			IN VARCHAR2,
	    resultout			OUT NOCOPY VARCHAR2
    );

    PROCEDURE return_install_at_addr
    (
        p_instance_id     in number,
        p_address_line    out nocopy varchar2,
        p_city            out nocopy varchar2,
        p_country         out nocopy varchar2,
        p_county          out nocopy varchar2,
        p_postal_code     out nocopy varchar2,
        p_state           out nocopy varchar2
    );

    PROCEDURE return_ship_to_address
    (
        p_ship_to_org_id     in number,
        p_address_line    out nocopy varchar2,
        p_city            out nocopy varchar2,
        p_country         out nocopy varchar2,
        p_county          out nocopy varchar2,
        p_postal_code     out nocopy varchar2,
        p_state           out nocopy varchar2
    );

    PROCEDURE publish_line_bill_to_address(	itemtype  IN VARCHAR2,
		 				itemkey   IN VARCHAR2,
		 				actid 	  IN NUMBER,
		 				funcmode  IN VARCHAR2,
						resultout OUT NOCOPY VARCHAR2);

PROCEDURE truncate_all_lines
    (
	    itemtype			IN VARCHAR2,
	    itemkey			IN VARCHAR2,
	    actid			IN NUMBER,
	    funcmode			IN VARCHAR2,
	    resultout			OUT NOCOPY VARCHAR2
    );

END xnb_sales_order_pvt;

 

/
