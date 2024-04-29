--------------------------------------------------------
--  DDL for Package IEX_WRITEOFF_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WRITEOFF_OBJECTS_PVT" AUTHID CURRENT_USER as
/* $Header: iexvwobs.pls 120.1 2007/10/31 12:29:32 ehuh ship $ */
-- Start of Comments
-- Package name     : IEX_WRITEOFF_OBJECTS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME              CONSTANT VARCHAR2(200) := 'IEX_WRITEOFF_OBJECTS_PVT';
 G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_DEFAULT_NUM_REC_FETCH CONSTANT NUMBER := 30;
 G_YES                   CONSTANT VARCHAR2(1) := 'Y';
 G_NO                    CONSTANT VARCHAR2(1) := 'N';
------------------------------------------------------------------------------


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE writeoff_obj_rec_type IS RECORD
(
       WRITEOFF_OBJECT_ID              NUMBER ,
       WRITEOFF_ID                     NUMBER ,
       OBJECT_VERSION_NUMBER           NUMBER ,
       CONTRACT_ID                     NUMBER ,
       CONS_INVOICE_ID                 NUMBER ,
       CONS_INVOICE_LINE_ID            NUMBER ,
       TRANSACTION_ID                  NUMBER ,
       ADJUSTMENT_AMOUNT               NUMBER ,
       ADJUSTMENT_REASON_CODE          VARCHAR2(30) ,
       RECEVIABLES_ADJUSTMENT_ID       NUMBER ,
       REQUEST_ID                      NUMBER ,
       PROGRAM_APPLICATION_ID          NUMBER ,
       PROGRAM_ID                      NUMBER ,
       PROGRAM_UPDATE_DATE             DATE ,
       ATTRIBUTE_CATEGORY              VARCHAR2(240) ,
       ATTRIBUTE1                      VARCHAR2(240) ,
       ATTRIBUTE2                      VARCHAR2(240) ,
       ATTRIBUTE3                      VARCHAR2(240) ,
       ATTRIBUTE4                      VARCHAR2(240) ,
       ATTRIBUTE5                      VARCHAR2(240) ,
       ATTRIBUTE6                      VARCHAR2(240) ,
       ATTRIBUTE7                      VARCHAR2(240) ,
       ATTRIBUTE8                      VARCHAR2(240) ,
       ATTRIBUTE9                      VARCHAR2(240) ,
       ATTRIBUTE10                     VARCHAR2(240) ,
       ATTRIBUTE11                     VARCHAR2(240) ,
       ATTRIBUTE12                     VARCHAR2(240) ,
       ATTRIBUTE13                     VARCHAR2(240) ,
       ATTRIBUTE14                     VARCHAR2(240) ,
       ATTRIBUTE15                     VARCHAR2(240) ,
       CREATED_BY                      NUMBER ,
       CREATION_DATE                   DATE ,
       LAST_UPDATED_BY                 NUMBER ,
       LAST_UPDATE_DATE                DATE ,
       LAST_UPDATE_LOGIN               NUMBER,
       WRITEOFF_STATUS                 VARCHAR2(15),
       WRITEOFF_TYPE_ID                NUMBER,
       WRITEOFF_TYPE                   VARCHAR2(50),
       customer_trx_id                 number,
       customer_trx_line_id            number);

G_MISS_writeoff_obj_rec          writeoff_obj_rec_type;
TYPE  writeoff_obj_tbl_Type      IS TABLE OF writeoff_obj_rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_writeoff_obj_tbl          writeoff_obj_tbl_Type;

PROCEDURE create_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_writeoff_obj_rec           IN   writeoff_obj_rec_type,
    X_writeoff_object_id         OUT  NOCOPY NUMBER
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2
    );

PROCEDURE update_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_writeoff_obj_rec           IN    writeoff_obj_rec_type,
    x_return_status              OUT  NOCOPY VARCHAR2
    ,x_msg_count                  OUT  NOCOPY NUMBER
    ,x_msg_data                   OUT  NOCOPY VARCHAR2
    ,XO_OBJECT_VERSION_NUMBER     OUT  NOCOPY NUMBER
    );

PROCEDURE  delete_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_writeoff_object_id         IN   NUMBER ,
    x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2

    );


End IEX_WRITEOFF_OBJECTS_PVT;

/
