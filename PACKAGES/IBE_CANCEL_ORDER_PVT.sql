--------------------------------------------------------
--  DDL for Package IBE_CANCEL_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_CANCEL_ORDER_PVT" AUTHID CURRENT_USER as
/* $Header: IBECORDS.pls 115.5 2002/12/13 02:28:12 mannamra ship $ */
PROCEDURE CANCEL_ORDER (
    p_api_version       	   IN  NUMBER   := 1                  ,
    p_init_msg_list    		   IN  VARCHAR2 := FND_API.G_TRUE     ,
    p_commit                     IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_order_header_id            IN   NUMBER ,
    p_comments                   IN   VARCHAR2,
    p_reason_code                IN   VARCHAR2,
    P_Last_Updated_By            IN   NUMBER,
    P_Last_Update_Date           IN   DATE,
    P_Last_Update_Login          IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
END IBE_CANCEL_ORDER_PVT;

 

/
