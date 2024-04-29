--------------------------------------------------------
--  DDL for Package JTF_FM_OCM_REND_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_OCM_REND_REQ" AUTHID CURRENT_USER AS
/* $Header: jtfgfmrs.pls 115.2 2003/11/17 20:01:45 sxkrishn noship $*/

-- ------------------------------------------------------------------
-- Fulfillment Electronic Record
-- ------------------------------------------------------------------


-- -----------------------------------------------------------------
-- Procedure Spec
-- -----------------------------------------------------------------
PROCEDURE create_fulfillment_rendition
(
    p_init_msg_list	     IN	 VARCHAR2 := FND_API.G_FALSE,
    p_api_version            IN	 NUMBER,
    p_commit		     IN  VARCHAR2 := FND_API.G_FALSE,
    p_order_header_rec       IN  JTF_Fulfillment_PUB.ORDER_HEADER_REC_TYPE,
    p_order_line_tbl         IN  JTF_Fulfillment_PUB.ORDER_LINE_TBL_TYPE,
    p_fulfill_electronic_rec IN  JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE,
    p_request_type           IN  VARCHAR2,
    x_return_status	     OUT NOCOPY VARCHAR2,
    x_msg_count		     OUT NOCOPY NUMBER,
    x_msg_data		     OUT NOCOPY VARCHAR2,
    x_order_header_rec       OUT NOCOPY ASO_ORDER_INT.order_header_rec_type,
    x_request_history_id     OUT NOCOPY NUMBER
);

-- Refer to Bug # 3197952
PROCEDURE GET_OCM_REND_DETAILS
(  p_content_id            IN NUMBER,
   p_request_id            IN NUMBER,
   p_user_note             IN VARCHAR2,
   p_quantity              IN NUMBER,
   p_media_type            IN VARCHAR2,
   p_version               IN NUMBER,
   p_content_nm            IN VARCHAR2,
   p_email_format          IN VARCHAR2,
   x_citem_name            OUT NOCOPY VARCHAR2,
   x_query_id              OUT NOCOPY NUMBER ,
   x_html                  OUT NOCOPY VARCHAR2 ,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2

);

END JTF_FM_OCM_REND_REQ;

 

/
