--------------------------------------------------------
--  DDL for Package WIP_REPSCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_REPSCHEDULE_UTIL" AUTHID CURRENT_USER AS
/* $Header: WIPUWRSS.pls 115.7 2002/11/29 13:32:56 simishra ship $ */

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
G_COMMON_BOM_SEQUENCE         CONSTANT NUMBER := 21;
G_COMMON_ROUT_SEQUENCE        CONSTANT NUMBER := 22;
G_CREATED_BY                  CONSTANT NUMBER := 23;
G_CREATION_DATE               CONSTANT NUMBER := 24;
G_DAILY_PRODUCTION_RATE       CONSTANT NUMBER := 25;
G_DATE_CLOSED                 CONSTANT NUMBER := 26;
G_DATE_RELEASED               CONSTANT NUMBER := 27;
G_DEMAND_CLASS                CONSTANT NUMBER := 28;
G_DESCRIPTION                 CONSTANT NUMBER := 29;
G_FIRM_PLANNED                CONSTANT NUMBER := 30;
G_FIRST_UNIT_CPL_DATE         CONSTANT NUMBER := 31;
G_FIRST_UNIT_START_DATE       CONSTANT NUMBER := 32;
G_LAST_UNIT_CPL_DATE          CONSTANT NUMBER := 33;
G_LAST_UNIT_START_DATE        CONSTANT NUMBER := 34;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 35;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 36;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 37;
G_LINE                        CONSTANT NUMBER := 38;
G_MATERIAL_ACCOUNT            CONSTANT NUMBER := 39;
G_MATERIAL_OVERHEAD_ACCOUNT   CONSTANT NUMBER := 40;
G_MATERIAL_VARIANCE_ACCOUNT   CONSTANT NUMBER := 41;
G_ORGANIZATION                CONSTANT NUMBER := 42;
G_OSP_ACCOUNT                 CONSTANT NUMBER := 43;
G_OSP_VARIANCE_ACCOUNT        CONSTANT NUMBER := 44;
G_OVERHEAD_ACCOUNT            CONSTANT NUMBER := 45;
G_OVERHEAD_VARIANCE_ACCOUNT   CONSTANT NUMBER := 46;
G_PROCESSING_WORK_DAYS        CONSTANT NUMBER := 47;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 48;
G_PROGRAM                     CONSTANT NUMBER := 49;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 50;
G_QUANTITY_COMPLETED          CONSTANT NUMBER := 51;
G_REPETITIVE_SCHEDULE         CONSTANT NUMBER := 52;
G_REQUEST                     CONSTANT NUMBER := 53;
G_RESOURCE_ACCOUNT            CONSTANT NUMBER := 54;
G_RESOURCE_VARIANCE_ACCOUNT   CONSTANT NUMBER := 55;
G_ROUTING_REVISION            CONSTANT NUMBER := 56;
G_ROUTING_REVISION_DATE       CONSTANT NUMBER := 57;
G_STATUS_TYPE                 CONSTANT NUMBER := 58;
G_WIP_ENTITY                  CONSTANT NUMBER := 59;
G_KANBAN_CARD                 CONSTANT NUMBER := 60;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 61;


--  Function Complete_Record

FUNCTION Complete_Record
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   p_old_RepSchedule_rec           IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   p_ForceCopy                     IN  BOOLEAN := NULL
) RETURN WIP_Work_Order_PUB.Repschedule_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
) RETURN WIP_Work_Order_PUB.Repschedule_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_repetitive_schedule_id        IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_repetitive_schedule_id        IN  NUMBER
) RETURN WIP_Work_Order_PUB.Repschedule_Rec_Type;

FUNCTION Query_Row
(   p_wip_entity_id        IN  NUMBER
) RETURN WIP_Work_Order_PUB.Repschedule_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_repetitive_schedule_id        IN  NUMBER :=
                                        NULL
,   p_wip_entity_id                 IN  NUMBER :=
                                        NULL
) RETURN WIP_Work_Order_PUB.Repschedule_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   x_RepSchedule_rec               OUT NOCOPY WIP_Work_Order_PUB.Repschedule_Rec_Type
);

FUNCTION Compare
(   p_RepSchedule_rec1              IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   p_RepSchedule_rec2              IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
) RETURN Boolean;

PROCEDURE dprintf
(   p_RepSchedule_rec              IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
);

END WIP_Repschedule_Util;

 

/
