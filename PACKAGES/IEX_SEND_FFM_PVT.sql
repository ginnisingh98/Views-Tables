--------------------------------------------------------
--  DDL for Package IEX_SEND_FFM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SEND_FFM_PVT" AUTHID CURRENT_USER as
/* $Header: iexvffms.pls 120.1 2004/10/28 20:30:17 clchang ship $ */
-- Start of Comments
-- Package name     : IEX_SEND_FFM_PVT
-- Purpose          : Calling Fullfillment
-- NOTE             :
-- History          :
--     03/20/2001 CLCHANG  Created.
-- End of Comments

TYPE content_rec_type is RECORD
(   Content_ID             NUMBER ,
    Media_Type             VARCHAR2(30) ,
    Request_Type           VARCHAR2(30) ,
    User_Note              VARCHAR2(1000),
    Document_Type          VARCHAR2(30) ,
    Email                  VARCHAR2(1000) ,
    Printer                VARCHAR2(1000) ,
    File_Path              VARCHAR2(1000) ,
    Fax                    VARCHAR2(1000)
);

TYPE content_tbl_type is table of content_rec_type
                      index by binary_integer;

G_MISS_CONTENT_REC content_rec_type;
G_MISS_CONTENT_TBL content_tbl_type;

-- a PLSQL Table may not contain a table or a record with composite fields.
-- So we use bind_cnt_tbl to count the num of bind vars for each content.
-- EX: bind_cnt_tbl(1) := 2 => content1 has 2 bind_vars
--                          => bind_var(1)&(2) are for content1 (content_tbl_type(1))
--     bind_cnt_tbl(2) := 1 => bind_var(3) is for content2 (content_tbl_type(2))
TYPE bind_cnt_tbl is table of NUMBER index by binary_integer;


G_MISS_VARCHAR_TBL JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;


-- *************************
--   Validation Procedures
-- *************************
PROCEDURE Validate_Media_Type
(
    P_Init_Msg_List              IN   VARCHAR2   ,
    P_Content_Tbl                IN   IEX_SEND_FFM_PVT.CONTENT_TBL_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);

-- **************************
--   Calling FFM APIs
-- **************************

--   API Name:  Send_FFM

PROCEDURE Send_FFM(
    P_Api_Version_Number     IN  NUMBER,
    P_Init_Msg_List          IN  VARCHAR2   ,
    P_Commit                 IN  VARCHAR2   ,
    p_Content_NM             IN  VARCHAR2,
    P_User_id                IN  NUMBER,
    P_Server_id              IN  NUMBER,
    P_Party_id               IN  NUMBER,
    p_Subject                IN  VARCHAR2 ,
    --
    P_Content_tbl            IN  IEX_SEND_FFM_PVT.CONTENT_TBL_TYPE,
    p_bind_var 		     IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
    p_bind_var_type 	     IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
    p_bind_val 		     IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
/*
    P_Content_ID             IN  NUMBER,
    P_Media_Type             IN  VARCHAR2,
    P_Request_Type           IN  VARCHAR2,
    P_User_Note              IN  VARCHAR2,
    P_Document_Type          IN  VARCHAR2,
    P_Subject                IN  VARCHAR2,
    P_Email                  IN  VARCHAR2,
    P_Printer                IN  VARCHAR2,
    P_File_Path              IN  VARCHAR2,
    P_Fax                    IN  VARCHAR2,
*/
    X_Request_ID             OUT NOCOPY NUMBER,
    X_Return_Status          OUT NOCOPY VARCHAR2,
    X_Msg_Count              OUT NOCOPY NUMBER,
    X_Msg_Data               OUT NOCOPY VARCHAR2
    );


End IEX_SEND_FFM_PVT;

 

/
