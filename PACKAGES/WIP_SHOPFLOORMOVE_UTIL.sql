--------------------------------------------------------
--  DDL for Package WIP_SHOPFLOORMOVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SHOPFLOORMOVE_UTIL" AUTHID CURRENT_USER AS
/* $Header: WIPUSFMS.pls 115.6 2002/12/03 11:16:28 simishra ship $ */

--  Attributes global constants

G_ACCT_PERIOD                 CONSTANT NUMBER := 1;
G_ATTRIBUTE1                  CONSTANT NUMBER := 2;
G_ATTRIBUTE10                 CONSTANT NUMBER := 3;
G_ATTRIBUTE11                 CONSTANT NUMBER := 4;
G_ATTRIBUTE12                 CONSTANT NUMBER := 5;
G_ATTRIBUTE13                 CONSTANT NUMBER := 6;
G_ATTRIBUTE14                 CONSTANT NUMBER := 7;
G_ATTRIBUTE15                 CONSTANT NUMBER := 8;
G_ATTRIBUTE2                  CONSTANT NUMBER := 9;
G_ATTRIBUTE3                  CONSTANT NUMBER := 10;
G_ATTRIBUTE4                  CONSTANT NUMBER := 11;
G_ATTRIBUTE5                  CONSTANT NUMBER := 12;
G_ATTRIBUTE6                  CONSTANT NUMBER := 13;
G_ATTRIBUTE7                  CONSTANT NUMBER := 14;
G_ATTRIBUTE8                  CONSTANT NUMBER := 15;
G_ATTRIBUTE9                  CONSTANT NUMBER := 16;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATED_BY_NAME             CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_ENTITY_TYPE                 CONSTANT NUMBER := 21;
G_FM_DEPARTMENT_CODE          CONSTANT NUMBER := 22;
G_FM_DEPARTMENT_ID            CONSTANT NUMBER := 23;
G_FM_INTRAOP_STEP_TYPE        CONSTANT NUMBER := 24;
G_FM_OPERATION                CONSTANT NUMBER := 25;
G_FM_OPERATION_SEQ_NUM        CONSTANT NUMBER := 26;
G_GROUP                       CONSTANT NUMBER := 27;
G_KANBAN_CARD                 CONSTANT NUMBER := 28;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 30;
G_LAST_UPDATED_BY_NAME        CONSTANT NUMBER := 31;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 32;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 33;
G_LINE_CODE                   CONSTANT NUMBER := 34;
G_LINE_ID                     CONSTANT NUMBER := 35;
G_ORGANIZATION_CODE           CONSTANT NUMBER := 36;
G_ORGANIZATION_ID             CONSTANT NUMBER := 37;
G_OVERCOMPLETION              CONSTANT NUMBER := 38;
G_OVERCPL_PRIMARY_QTY         CONSTANT NUMBER := 39;
G_OVERCPL_TRANSACTION         CONSTANT NUMBER := 40;
G_OVERCPL_TRANSACTION_QTY     CONSTANT NUMBER := 41;
G_OVERMOVE_TXN_QTY            CONSTANT NUMBER := 42;
G_PRIMARY_ITEM                CONSTANT NUMBER := 43;
G_PRIMARY_QUANTITY            CONSTANT NUMBER := 44;
G_PRIMARY_UOM                 CONSTANT NUMBER := 45;
G_PROCESS_PHASE               CONSTANT NUMBER := 46;
G_PROCESS_STATUS              CONSTANT NUMBER := 47;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 48;
G_PROGRAM                     CONSTANT NUMBER := 49;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 50;
G_QA_COLLECTION               CONSTANT NUMBER := 51;
G_REASON                      CONSTANT NUMBER := 52;
G_REASON_NAME                 CONSTANT NUMBER := 53;
G_REFERENCE                   CONSTANT NUMBER := 54;
G_REPETITIVE_SCHEDULE         CONSTANT NUMBER := 55;
G_REQUEST                     CONSTANT NUMBER := 56;
G_SCRAP_ACCOUNT               CONSTANT NUMBER := 57;
G_SOURCE                      CONSTANT NUMBER := 58;
G_SOURCE_LINE                 CONSTANT NUMBER := 59;
G_TO_DEPARTMENT_CODE          CONSTANT NUMBER := 60;
G_TO_DEPARTMENT_ID            CONSTANT NUMBER := 61;
G_TO_INTRAOP_STEP_TYPE        CONSTANT NUMBER := 62;
G_TO_OPERATION                CONSTANT NUMBER := 63;
G_TO_OPERATION_SEQ_NUM        CONSTANT NUMBER := 64;
G_TRANSACTION_DATE            CONSTANT NUMBER := 65;
G_TRANSACTION                 CONSTANT NUMBER := 66;
G_TRANSACTION_LINK            CONSTANT NUMBER := 67;
G_TRANSACTION_QUANTITY        CONSTANT NUMBER := 68;
G_TRANSACTION_TYPE            CONSTANT NUMBER := 69;
G_TRANSACTION_UOM             CONSTANT NUMBER := 70;
G_WIP_ENTITY                  CONSTANT NUMBER := 71;
G_WIP_ENTITY_NAME             CONSTANT NUMBER := 72;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 73;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_old_ShopFloorMove_rec         IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
) RETURN WIP_Transaction_PUB.Shopfloormove_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
) RETURN WIP_Transaction_PUB.Shopfloormove_Rec_Type;

--  Procedure Update_Row


--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_transaction_id                IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_transaction_id                IN  NUMBER
) RETURN WIP_Transaction_PUB.Shopfloormove_Rec_Type;

--  Function Query_Rows

FUNCTION Query_Rows
(   p_transaction_id                IN  NUMBER :=
                                        NULL
,   p_dummy                         IN  VARCHAR2 :=
                                        NULL
) RETURN WIP_Transaction_PUB.Shopfloormove_Tbl_Type;
--

--  Procedure       lock_Row
--


PROCEDURE print_record(p_ShopFloorMove_rec IN WIP_Transaction_PUB.ShopFloorMove_Rec_Type);

END WIP_Shopfloormove_Util;

 

/
