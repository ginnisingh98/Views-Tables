--------------------------------------------------------
--  DDL for Package JTF_FM_OCM_REQUEST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_OCM_REQUEST_GRP" AUTHID CURRENT_USER AS
/* $Header: jtfgfmos.pls 120.2 2005/10/26 11:29:33 gjoby ship $*/

-- ------------------------------------------------------------------
-- Fulfillment Electronic Record
--added emailFormat flag on September 24th.
--if null is passed/value not passed, it should be interpreted as html.
-- ------------------------------------------------------------------
type fulfill_electronic_rec_type is record
 (  template_id     NUMBER,                -- used as p_template_id
    version_id      NUMBER,                -- used as p_version_id
    object_type     VARCHAR2(240),         -- used as object_type
    object_id       NUMBER,                -- used as object_id
    source_code     VARCHAR2(30),          -- used as source_code
    source_code_id  NUMBER,                -- used as source_code_id
    requestor_type  VARCHAR2(30),          -- ignore
    requestor_id    NUMBER,                -- used as user_id
    server_group    NUMBER,                --  used to pass server id
    schedule_date   DATE := SYSDATE,       -- ignore
    media_types     VARCHAR2(30) := 'E',   -- Default is 'E' for email.  other F for Fax, P for Print.
    archive         VARCHAR2(2)  := 'N',   -- ignore
    log_user_ih     VARCHAR2(2)  := 'N',   -- used as p_per_user_history
    request_type    VARCHAR2(30),          -- s/b 'P'hysical or 'E'lectronic used to branch
    language_code   VARCHAR2(4),           -- ignore
    profile_id      NUMBER,                -- ignore
    order_id        NUMBER,                -- ignore
    collateral_id   NUMBER,                -- ignore
    subject         VARCHAR2(4000),        -- first 250 chars as email subject
    party_id        JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE, -- Used for Test Requests
    email           JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE, -- Used for Test Requests
    fax             JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE, -- Used for Test Requests
    printer         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE, -- Used for Test Requests
    bind_values     JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE, -- Used to pass bind var name
    bind_names      JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE, -- Used to pass bind var value
    email_text      VARCHAR2(256),               -- ignore
    content_name    VARCHAR2(50),               -- ignore
    content_type    VARCHAR2(256),    -- ignore
    extended_header VARCHAR2(32767),  -- extended headers
    stop_list_bypass VARCHAR2(30),   -- Used to by pass server level setting for
    email_format      VARCHAR2(30) := 'BOTH'   --possible values null,TEXT,HTML,BOTH

 );


-- -----------------------------------------------------------------
-- Procedure Spec
-- -----------------------------------------------------------------
PROCEDURE create_fulfillment
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

END JTF_FM_OCM_REQUEST_GRP;

 

/
