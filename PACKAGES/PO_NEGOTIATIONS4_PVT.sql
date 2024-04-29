--------------------------------------------------------
--  DDL for Package PO_NEGOTIATIONS4_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NEGOTIATIONS4_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVNG4S.pls 115.2 2003/07/23 18:07:09 zxzhang noship $ */

PROCEDURE Split_RequisitionLines
(   p_api_version		IN		NUMBER			    ,
    p_init_msg_list		IN    		VARCHAR2  :=FND_API.G_FALSE ,
    p_commit			IN    		VARCHAR2  :=FND_API.G_FALSE ,
    x_return_status		OUT NOCOPY   	VARCHAR2  		    ,
    x_msg_count			OUT NOCOPY   	NUMBER   		    ,
    x_msg_data			OUT NOCOPY   	VARCHAR2 		    ,
    p_auction_header_id		IN  		NUMBER
);


PROCEDURE Consume_ReqDemandYesNo
(   itemtype        		IN 		varchar2	,
    itemkey         		IN 		varchar2	,
    actid           		IN 		number		,
    funcmode        		IN 		varchar2	,
    resultout       		OUT NOCOPY	varchar2
);


procedure Place_SourcingInfoOnReq
(   itemtype        		IN 		varchar2	,
    itemkey         		IN 		varchar2	,
    actid           		IN 		number		,
    funcmode        		IN 		varchar2	,
    resultout       		OUT NOCOPY 	varchar2
);


PROCEDURE Launch_CreateDocWF
(   ItemType                  	IN		varchar2	,
    ItemKey                   	IN		varchar2	,
    actid           		IN 		number		,
    funcmode        		IN 		varchar2	,
    resultout       		OUT NOCOPY 	varchar2
);

-- <FPI JFMIP Req Split START>
PROCEDURE HANDLE_FUNDS_REVERSAL
(   p_api_version		IN		NUMBER		,
    p_commit			IN    		VARCHAR2	,
    x_return_status		OUT NOCOPY   	VARCHAR2	,
    x_msg_count			OUT NOCOPY   	NUMBER		,
    x_msg_data			OUT NOCOPY   	VARCHAR2	,
    x_online_report_id		OUT NOCOPY	NUMBER
);

PROCEDURE HANDLE_FUNDS_REVERSAL
(   p_api_version		IN		NUMBER		,
    p_commit			IN    		VARCHAR2	,
    x_return_status		OUT NOCOPY   	VARCHAR2	,
    x_msg_count			OUT NOCOPY   	NUMBER		,
    x_msg_data			OUT NOCOPY   	VARCHAR2
);

PROCEDURE HANDLE_TAX_ADJUSTMENTS
(   p_api_version		IN		NUMBER		,
    p_commit			IN    		VARCHAR2	,
    x_return_status		OUT NOCOPY   	VARCHAR2	,
    x_msg_count			OUT NOCOPY   	NUMBER		,
    x_msg_data			OUT NOCOPY   	VARCHAR2
);
-- <FPI JFMIP Req Split END>

END PO_NEGOTIATIONS4_PVT;

 

/
