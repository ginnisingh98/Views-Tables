--------------------------------------------------------
--  DDL for Package WIP_RES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RES_UTIL" AUTHID CURRENT_USER AS
/* $Header: WIPURESS.pls 120.0.12010000.1 2008/07/24 05:20:14 appldev ship $ */

--  Attributes global constants

G_ACCT_PERIOD                 CONSTANT NUMBER := 1;
G_ACTIVITY                    CONSTANT NUMBER := 2;
G_ACTIVITY_NAME               CONSTANT NUMBER := 3;
G_ACTUAL_RESOURCE_RATE        CONSTANT NUMBER := 4;
G_ATTRIBUTE1                  CONSTANT NUMBER := 5;
G_ATTRIBUTE10                 CONSTANT NUMBER := 6;
G_ATTRIBUTE11                 CONSTANT NUMBER := 7;
G_ATTRIBUTE12                 CONSTANT NUMBER := 8;
G_ATTRIBUTE13                 CONSTANT NUMBER := 9;
G_ATTRIBUTE14                 CONSTANT NUMBER := 10;
G_ATTRIBUTE15                 CONSTANT NUMBER := 11;
G_ATTRIBUTE2                  CONSTANT NUMBER := 12;
G_ATTRIBUTE3                  CONSTANT NUMBER := 13;
G_ATTRIBUTE4                  CONSTANT NUMBER := 14;
G_ATTRIBUTE5                  CONSTANT NUMBER := 15;
G_ATTRIBUTE6                  CONSTANT NUMBER := 16;
G_ATTRIBUTE7                  CONSTANT NUMBER := 17;
G_ATTRIBUTE8                  CONSTANT NUMBER := 18;
G_ATTRIBUTE9                  CONSTANT NUMBER := 19;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 20;
G_AUTOCHARGE_TYPE             CONSTANT NUMBER := 21;
G_BASIS_TYPE                  CONSTANT NUMBER := 22;
G_COMPLETION_TRANSACTION      CONSTANT NUMBER := 23;
G_CREATED_BY                  CONSTANT NUMBER := 24;
G_CREATED_BY_NAME             CONSTANT NUMBER := 25;
G_CREATION_DATE               CONSTANT NUMBER := 26;
G_CURRENCY_ACTUAL_RSC_RATE    CONSTANT NUMBER := 27;
G_CURRENCY                    CONSTANT NUMBER := 28;
G_CURRENCY_CONVERSION_DATE    CONSTANT NUMBER := 29;
G_CURRENCY_CONVERSION_RATE    CONSTANT NUMBER := 30;
G_CURRENCY_CONVERSION_TYPE    CONSTANT NUMBER := 31;
G_DEPARTMENT_CODE             CONSTANT NUMBER := 32;
G_DEPARTMENT_ID               CONSTANT NUMBER := 33;
G_EMPLOYEE                    CONSTANT NUMBER := 34;
G_EMPLOYEE_NUM                CONSTANT NUMBER := 35;
G_ENTITY_TYPE                 CONSTANT NUMBER := 36;
G_GROUP                       CONSTANT NUMBER := 37;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 38;
G_LAST_UPDATED_BY_NAME        CONSTANT NUMBER := 39;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 40;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 41;
G_LINE_CODE                   CONSTANT NUMBER := 42;
G_LINE_ID                     CONSTANT NUMBER := 43;
G_MOVE_TRANSACTION            CONSTANT NUMBER := 44;
G_OPERATION_SEQ_NUM           CONSTANT NUMBER := 45;
G_ORGANIZATION_CODE           CONSTANT NUMBER := 46;
G_ORGANIZATION_ID             CONSTANT NUMBER := 47;
G_PO_HEADER                   CONSTANT NUMBER := 48;
G_PO_LINE                     CONSTANT NUMBER := 49;
G_PRIMARY_ITEM                CONSTANT NUMBER := 50;
G_PRIMARY_QUANTITY            CONSTANT NUMBER := 51;
G_PRIMARY_UOM                 CONSTANT NUMBER := 52;
G_PRIMARY_UOM_CLASS           CONSTANT NUMBER := 53;
G_PROCESS_PHASE               CONSTANT NUMBER := 54;
G_PROCESS_STATUS              CONSTANT NUMBER := 55;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 56;
G_PROGRAM                     CONSTANT NUMBER := 57;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 58;
G_PROJECT                     CONSTANT NUMBER := 59;
G_PROJECT_NUMBER              CONSTANT NUMBER := 60;
G_RCV_TRANSACTION             CONSTANT NUMBER := 61;
G_REASON                      CONSTANT NUMBER := 62;
G_REASON_NAME                 CONSTANT NUMBER := 63;
G_RECEIVING_ACCOUNT           CONSTANT NUMBER := 64;
G_REFERENCE                   CONSTANT NUMBER := 65;
G_REPETITIVE_SCHEDULE         CONSTANT NUMBER := 66;
G_REQUEST                     CONSTANT NUMBER := 67;
G_RESOURCE_CODE               CONSTANT NUMBER := 68;
G_RESOURCE_ID                 CONSTANT NUMBER := 69;
G_RESOURCE_SEQ_NUM            CONSTANT NUMBER := 70;
G_RESOURCE_TYPE               CONSTANT NUMBER := 71;
G_SOURCE                      CONSTANT NUMBER := 72;
G_SOURCE_LINE                 CONSTANT NUMBER := 73;
G_STANDARD_RATE               CONSTANT NUMBER := 74;
G_TASK                        CONSTANT NUMBER := 75;
G_TASK_NUMBER                 CONSTANT NUMBER := 76;
G_TRANSACTION_DATE            CONSTANT NUMBER := 77;
G_TRANSACTION                 CONSTANT NUMBER := 78;
G_TRANSACTION_QUANTITY        CONSTANT NUMBER := 79;
G_TRANSACTION_TYPE            CONSTANT NUMBER := 80;
G_TRANSACTION_UOM             CONSTANT NUMBER := 81;
G_USAGE_RATE_OR_AMOUNT        CONSTANT NUMBER := 82;
G_WIP_ENTITY                  CONSTANT NUMBER := 83;
G_WIP_ENTITY_NAME             CONSTANT NUMBER := 84;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 85;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
) RETURN WIP_Transaction_PUB.Res_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_po_header_id                  IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_po_header_id                  IN  NUMBER
) RETURN WIP_Transaction_PUB.Res_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_po_header_id                  IN  NUMBER :=
                                        NULL
,   p_dummy                         IN  VARCHAR2 :=
                                        NULL
) RETURN WIP_Transaction_PUB.Res_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   x_Res_rec                       OUT NOCOPY WIP_Transaction_PUB.Res_Rec_Type
);


PROCEDURE Print_record(p_Res_rec  IN WIP_Transaction_PUB.Res_Rec_Type);

END WIP_Res_Util;

/
