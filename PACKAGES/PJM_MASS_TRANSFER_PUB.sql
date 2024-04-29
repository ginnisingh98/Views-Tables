--------------------------------------------------------
--  DDL for Package PJM_MASS_TRANSFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_MASS_TRANSFER_PUB" AUTHID CURRENT_USER AS
/* $Header: PJMMXFRS.pls 115.5 2002/10/29 20:13:46 alaw noship $ */

--
-- Transfer Modes
--
G_TXFR_MODE_ALL_ITEMS   NUMBER := 1;
G_TXFR_MODE_ONE_ITEM    NUMBER := 2;
G_TXFR_MODE_CATEGORY    NUMBER := 3;

--
-- Process Modes
--
G_PROC_MODE_ONLINE      NUMBER := 1;
G_PROC_MODE_IMMEDIATE   NUMBER := 2;
G_PROC_MODE_BACKGROUND  NUMBER := 3;
G_PROC_MODE_FORMLEVEL   NUMBER := 4;

--
-- Record Types
--
TYPE DFF_Rec_Type IS RECORD
( Category   mtl_transactions_interface.attribute_category%TYPE := NULL
, Attr1      mtl_transactions_interface.attribute1%TYPE         := NULL
, Attr2      mtl_transactions_interface.attribute2%TYPE         := NULL
, Attr3      mtl_transactions_interface.attribute3%TYPE         := NULL
, Attr4      mtl_transactions_interface.attribute4%TYPE         := NULL
, Attr5      mtl_transactions_interface.attribute5%TYPE         := NULL
, Attr6      mtl_transactions_interface.attribute6%TYPE         := NULL
, Attr7      mtl_transactions_interface.attribute7%TYPE         := NULL
, Attr8      mtl_transactions_interface.attribute8%TYPE         := NULL
, Attr9      mtl_transactions_interface.attribute9%TYPE         := NULL
, Attr10     mtl_transactions_interface.attribute10%TYPE        := NULL
, Attr11     mtl_transactions_interface.attribute11%TYPE        := NULL
, Attr12     mtl_transactions_interface.attribute12%TYPE        := NULL
, Attr13     mtl_transactions_interface.attribute13%TYPE        := NULL
, Attr14     mtl_transactions_interface.attribute14%TYPE        := NULL
, Attr15     mtl_transactions_interface.attribute15%TYPE        := NULL
);

--
-- Functions and Procedures
--
PROCEDURE Transfer
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2 DEFAULT FND_API.G_TRUE
, P_commit                  IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, X_Return_Status           OUT NOCOPY    VARCHAR2
, X_Msg_Count               OUT NOCOPY    NUMBER
, X_Msg_Data                OUT NOCOPY    VARCHAR2
, P_Process_Mode            IN            NUMBER
, P_Transfer_Mode           IN            NUMBER
, P_Txn_Header_ID           IN            NUMBER
, P_Organization_ID         IN            NUMBER
, P_Item_ID                 IN            NUMBER
, P_Category_Set_ID         IN            NUMBER
, P_Category_ID             IN            NUMBER
, P_From_Project_ID         IN            NUMBER
, P_From_Task_ID            IN            NUMBER
, P_To_Project_ID           IN            NUMBER
, P_To_Task_ID              IN            NUMBER
, P_Txn_Date                IN            DATE
, P_Acct_Period_ID          IN            NUMBER
, P_Txn_Reason_ID           IN            NUMBER
, P_Txn_Reference           IN            VARCHAR2
, P_DFF                     IN            DFF_Rec_Type
, X_Txn_Header_ID           OUT NOCOPY    NUMBER
, X_Txn_Count               OUT NOCOPY    NUMBER
);


PROCEDURE Item_Transfer
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2 DEFAULT FND_API.G_TRUE
, P_commit                  IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, X_Return_Status           OUT NOCOPY    VARCHAR2
, X_Msg_Count               OUT NOCOPY    NUMBER
, X_Msg_Data                OUT NOCOPY    VARCHAR2
, P_Process_Mode            IN            NUMBER
, P_Txn_Header_ID           IN            NUMBER
, P_Organization_ID         IN            NUMBER
, P_Item_ID                 IN            NUMBER
, P_From_Project_ID         IN            NUMBER
, P_From_Task_ID            IN            NUMBER
, P_To_Project_ID           IN            NUMBER
, P_To_Task_ID              IN            NUMBER
, P_Txn_Date                IN            DATE
, P_Acct_Period_ID          IN            NUMBER
, P_Txn_Reason_ID           IN            NUMBER
, P_Txn_Reference           IN            VARCHAR2
, P_DFF                     IN            DFF_Rec_Type
, X_Txn_Header_ID           OUT NOCOPY    NUMBER
, X_Txn_Count               OUT NOCOPY    NUMBER
);


PROCEDURE Mass_Transfer
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2 DEFAULT FND_API.G_TRUE
, P_commit                  IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, X_Return_Status           OUT NOCOPY    VARCHAR2
, X_Msg_Count               OUT NOCOPY    NUMBER
, X_Msg_Data                OUT NOCOPY    VARCHAR2
, P_Transfer_ID             IN            NUMBER
, X_Txn_Header_ID           OUT NOCOPY    NUMBER
, X_Txn_Count               OUT NOCOPY    NUMBER
, X_Request_ID              OUT NOCOPY    NUMBER
);

END PJM_MASS_TRANSFER_PUB;

 

/
