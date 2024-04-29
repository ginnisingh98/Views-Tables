--------------------------------------------------------
--  DDL for Package WIP_DISCRETEJOB_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DISCRETEJOB_UTIL" AUTHID CURRENT_USER AS
/* $Header: WIPUWDJS.pls 120.3 2005/10/24 17:15:39 sjchen ship $ */

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
G_BOM_REFERENCE               CONSTANT NUMBER := 19;
G_BOM_REVISION                CONSTANT NUMBER := 20;
G_BOM_REVISION_DATE           CONSTANT NUMBER := 21;
G_BUILD_SEQUENCE              CONSTANT NUMBER := 22;
G_CLASS                       CONSTANT NUMBER := 23;
G_COMMON_BOM_SEQUENCE         CONSTANT NUMBER := 24;
G_COMMON_ROUT_SEQUENCE        CONSTANT NUMBER := 25;
G_COMPLETION_LOCATOR          CONSTANT NUMBER := 26;
G_COMPLETION_SUBINVENTORY     CONSTANT NUMBER := 27;
G_CREATED_BY                  CONSTANT NUMBER := 28;
G_CREATION_DATE               CONSTANT NUMBER := 29;
G_DATE_CLOSED                 CONSTANT NUMBER := 30;
G_DATE_COMPLETED              CONSTANT NUMBER := 31;
G_DATE_RELEASED               CONSTANT NUMBER := 32;
G_DEMAND_CLASS                CONSTANT NUMBER := 33;
G_DESCRIPTION                 CONSTANT NUMBER := 34;
G_FIRM_PLANNED                CONSTANT NUMBER := 35;
G_JOB_TYPE                    CONSTANT NUMBER := 36;
G_KANBAN_CARD                 CONSTANT NUMBER := 37;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 38;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 39;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 40;
G_LINE                        CONSTANT NUMBER := 41;
G_LOT_NUMBER                  CONSTANT NUMBER := 42;
G_MATERIAL_ACCOUNT            CONSTANT NUMBER := 43;
G_MATERIAL_OVERHEAD_ACCOUNT   CONSTANT NUMBER := 44;
G_MATERIAL_VARIANCE_ACCOUNT   CONSTANT NUMBER := 45;
G_MPS_NET_QUANTITY            CONSTANT NUMBER := 46;
G_MPS_SCHEDULED_CPL_DATE      CONSTANT NUMBER := 47;
G_NET_QUANTITY                CONSTANT NUMBER := 48;
G_ORGANIZATION                CONSTANT NUMBER := 49;
G_OSP_ACCOUNT                 CONSTANT NUMBER := 50;
G_OSP_VARIANCE_ACCOUNT        CONSTANT NUMBER := 51;
G_OVERCPL_TOLERANCE_TYPE      CONSTANT NUMBER := 52;
G_OVERCPL_TOLERANCE_VALUE     CONSTANT NUMBER := 53;
G_OVERHEAD_ACCOUNT            CONSTANT NUMBER := 54;
G_OVERHEAD_VARIANCE_ACCOUNT   CONSTANT NUMBER := 55;
G_PRIMARY_ITEM                CONSTANT NUMBER := 56;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 57;
G_PROGRAM                     CONSTANT NUMBER := 58;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 59;
G_PROJECT_COSTED              CONSTANT NUMBER := 60;
G_PROJECT                     CONSTANT NUMBER := 61;
G_QUANTITY_COMPLETED          CONSTANT NUMBER := 62;
G_QUANTITY_SCRAPPED           CONSTANT NUMBER := 63;
G_REQUEST                     CONSTANT NUMBER := 64;
G_RESOURCE_ACCOUNT            CONSTANT NUMBER := 65;
G_RESOURCE_VARIANCE_ACCOUNT   CONSTANT NUMBER := 66;
G_ROUTING_REFERENCE           CONSTANT NUMBER := 67;
G_ROUTING_REVISION            CONSTANT NUMBER := 68;
G_ROUTING_REVISION_DATE       CONSTANT NUMBER := 69;
G_SCHEDULED_COMPLETION_DATE   CONSTANT NUMBER := 70;
G_SCHEDULED_START_DATE        CONSTANT NUMBER := 71;
G_SCHEDULE_GROUP              CONSTANT NUMBER := 72;
G_SOURCE                      CONSTANT NUMBER := 73;
G_SOURCE_LINE                 CONSTANT NUMBER := 74;
G_START_QUANTITY              CONSTANT NUMBER := 75;
G_STATUS_TYPE                 CONSTANT NUMBER := 76;
G_STD_COST_ADJ_ACCOUNT        CONSTANT NUMBER := 77;
G_TASK                        CONSTANT NUMBER := 78;
G_WIP_ENTITY                  CONSTANT NUMBER := 79;
G_WIP_SUPPLY_TYPE             CONSTANT NUMBER := 80;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 81;

--  Procedure Clear_Dependent_Attr

--  Function Complete_Record

FUNCTION Complete_Record
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
,   p_old_DiscreteJob_rec           IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
,   p_ForceCopy                     IN BOOLEAN := NULL
) RETURN WIP_Work_Order_PUB.Discretejob_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
) RETURN WIP_Work_Order_PUB.Discretejob_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_wip_entity_id                 IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_wip_entity_id                 IN  NUMBER
) RETURN WIP_Work_Order_PUB.Discretejob_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_wip_entity_id                 IN  NUMBER :=
                                        NULL
) RETURN WIP_Work_Order_PUB.Discretejob_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
,   x_DiscreteJob_rec               OUT NOCOPY WIP_Work_Order_PUB.Discretejob_Rec_Type
);

FUNCTION Compare
(  p_DiscreteJob_rec1               IN WIP_Work_Order_PUB.Discretejob_Rec_Type
,  p_DiscreteJob_rec2               IN WIP_Work_Order_PUB.Discretejob_Rec_Type
) RETURN BOOLEAN;

PROCEDURE dprintf
( p_DiscreteJob_rec    IN WIP_Work_Order_PUB.Discretejob_Rec_Type);

/**
 * Update miscellaneous details.
 */
PROCEDURE update_job_details(p_org_id IN NUMBER,
                             p_wip_entity_id IN NUMBER,
                             p_due_date IN DATE,
                             p_line_id IN NUMBER,
                             p_schedule_group_id IN NUMBER,
                             p_build_sequence IN NUMBER,
                             p_expedited IN VARCHAR2,
                             p_initialize IN VARCHAR2,
                             x_err_msg OUT NOCOPY VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2);


END WIP_Discretejob_Util;

 

/
