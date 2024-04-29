--------------------------------------------------------
--  DDL for Package WIP_FLOWSCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FLOWSCHEDULE_UTIL" AUTHID CURRENT_USER AS
/* $Header: WIPUFLOS.pls 115.7 2002/11/29 18:45:40 simishra ship $ */

--  Attributes global constants

G_ALTERNATE_BOM_DESIGNATOR    CONSTANT NUMBER := 1;
G_ALTERNATE_ROUT_DESIGNATOR   CONSTANT NUMBER := 2;
G_ATTRIBUTE1                  CONSTANT NUMBER := 3;
G_ATTRIBUTE10                 CONSTANT NUMBER := 4;
G_ATTRIBUTE11                 CONSTANT NUMBER := 5;
G_ATTRIBUTE12                 CONSTANT NUMBER := 6;
G_ATTRIBUTE13                 CONSTANT NUMBER := 7;
G_ATTRIBUTE14                 CONSTANT NUMBER := 8;
G_ATTRIBUTE15                 CONSTANT NUMBER := 9;
G_ATTRIBUTE2                  CONSTANT NUMBER := 10;
G_ATTRIBUTE3                  CONSTANT NUMBER := 11;
G_ATTRIBUTE4                  CONSTANT NUMBER := 12;
G_ATTRIBUTE5                  CONSTANT NUMBER := 13;
G_ATTRIBUTE6                  CONSTANT NUMBER := 14;
G_ATTRIBUTE7                  CONSTANT NUMBER := 15;
G_ATTRIBUTE8                  CONSTANT NUMBER := 16;
G_ATTRIBUTE9                  CONSTANT NUMBER := 17;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 18;
G_BOM_REVISION                CONSTANT NUMBER := 19;
G_BOM_REVISION_DATE           CONSTANT NUMBER := 20;
G_BUILD_SEQUENCE              CONSTANT NUMBER := 21;
G_CLASS                       CONSTANT NUMBER := 22;
G_COMPLETION_LOCATOR          CONSTANT NUMBER := 23;
G_COMPLETION_SUBINVENTORY     CONSTANT NUMBER := 24;
G_CREATED_BY                  CONSTANT NUMBER := 25;
G_CREATION_DATE               CONSTANT NUMBER := 26;
G_DATE_CLOSED                 CONSTANT NUMBER := 27;
G_DEMAND_CLASS                CONSTANT NUMBER := 28;
G_DEMAND_SOURCE_DELIVERY      CONSTANT NUMBER := 29;
G_DEMAND_SOURCE_HEADER        CONSTANT NUMBER := 30;
G_DEMAND_SOURCE_LINE          CONSTANT NUMBER := 31;
G_DEMAND_SOURCE_TYPE          CONSTANT NUMBER := 32;
G_KANBAN_CARD                 CONSTANT NUMBER := 33;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 34;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 35;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 36;
G_LINE                        CONSTANT NUMBER := 37;
G_MATERIAL_ACCOUNT            CONSTANT NUMBER := 38;
G_MATERIAL_OVERHEAD_ACCOUNT   CONSTANT NUMBER := 39;
G_MATERIAL_VARIANCE_ACCOUNT   CONSTANT NUMBER := 40;
G_MPS_NET_QUANTITY            CONSTANT NUMBER := 41;
G_MPS_SCHEDULED_CPL_DATE      CONSTANT NUMBER := 42;
G_ORGANIZATION                CONSTANT NUMBER := 43;
G_OSP_ACCOUNT                 CONSTANT NUMBER := 44;
G_OSP_VARIANCE_ACCOUNT        CONSTANT NUMBER := 45;
G_OVERHEAD_ACCOUNT            CONSTANT NUMBER := 46;
G_OVERHEAD_VARIANCE_ACCOUNT   CONSTANT NUMBER := 47;
G_PLANNED_QUANTITY            CONSTANT NUMBER := 48;
G_PRIMARY_ITEM                CONSTANT NUMBER := 49;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 50;
G_PROGRAM                     CONSTANT NUMBER := 51;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 52;
G_PROJECT                     CONSTANT NUMBER := 53;
G_QUANTITY_COMPLETED          CONSTANT NUMBER := 54;
G_REQUEST                     CONSTANT NUMBER := 55;
G_RESOURCE_ACCOUNT            CONSTANT NUMBER := 56;
G_RESOURCE_VARIANCE_ACCOUNT   CONSTANT NUMBER := 57;
G_ROUTING_REVISION            CONSTANT NUMBER := 58;
G_ROUTING_REVISION_DATE       CONSTANT NUMBER := 59;
G_SCHEDULED_COMPLETION_DATE   CONSTANT NUMBER := 60;
G_SCHEDULED                   CONSTANT NUMBER := 61;
G_SCHEDULED_START_DATE        CONSTANT NUMBER := 62;
G_SCHEDULE_GROUP              CONSTANT NUMBER := 63;
G_SCHEDULE_NUMBER             CONSTANT NUMBER := 64;
G_STATUS                      CONSTANT NUMBER := 65;
G_STD_COST_ADJ_ACCOUNT        CONSTANT NUMBER := 66;
G_TASK                        CONSTANT NUMBER := 67;
G_WIP_ENTITY                  CONSTANT NUMBER := 68;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 69;


--  Function Complete_Record

FUNCTION Complete_Record
(   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
,   p_old_FlowSchedule_rec          IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
,   p_ForceCopy                     IN  BOOLEAN := FALSE
) RETURN WIP_Work_Order_PUB.Flowschedule_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
) RETURN WIP_Work_Order_PUB.Flowschedule_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_schedule_number               IN  VARCHAR2
);

--  Function Query_Row

FUNCTION Query_Row
(   p_schedule_number               IN  VARCHAR2
) RETURN WIP_Work_Order_PUB.Flowschedule_Rec_Type;

FUNCTION Query_Row
(   p_wip_entity_id               IN  NUMBER
) RETURN WIP_Work_Order_PUB.Flowschedule_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_schedule_number               IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_wip_entity_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN WIP_Work_Order_PUB.Flowschedule_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
,   x_FlowSchedule_rec              OUT NOCOPY WIP_Work_Order_PUB.Flowschedule_Rec_Type
);


FUNCTION Compare( p_FlowSchedule_rec1   IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type,
                  p_FlowSchedule_rec2   IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type)
RETURN BOOLEAN;


PROCEDURE dprintf(p_FlowSchedule_rec    IN WIP_Work_Order_PUB.FlowSchedule_Rec_Type);

END WIP_Flowschedule_Util;

 

/
