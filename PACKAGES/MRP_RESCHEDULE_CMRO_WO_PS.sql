--------------------------------------------------------
--  DDL for Package MRP_RESCHEDULE_CMRO_WO_PS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_RESCHEDULE_CMRO_WO_PS" AUTHID CURRENT_USER AS
/* $Header: MRPPSRELS.pls 120.4.12010000.2 2010/03/19 13:10:07 vsiyer noship $ */

TYPE WO_ORG_REC IS RECORD( WIP_ENTITY_ID NUMBER ,ORGANIZATION_ID NUMBER) ;
TYPE  JOBS_CUR_REC  IS RECORD(
                                SOURCE_CODE   VARCHAR2( 30 ),
                                SOURCE_LINE_ID   NUMBER ,
                                ORGANIZATION_ID   NUMBER ,
                                STATUS_TYPE   NUMBER ,
                                FIRST_UNIT_START_DATE   DATE ,
                                BOM_REVISION_DATE   DATE ,
                                ROUTING_REVISION_DATE   DATE ,
                                CLASS_CODE   VARCHAR2( 10 ) ,
                                JOB_NAME   VARCHAR2( 240 ) ,
                                FIRM_PLANNED_FLAG   NUMBER,
                                ALTERNATE_ROUTING_DESIGNATOR   VARCHAR2( 10 ),
                                ALTERNATE_BOM_DESIGNATOR   VARCHAR2( 10 ) ,
                                START_QUANTITY   NUMBER,
                                WIP_ENTITY_ID   NUMBER ,
                                SCHEDULE_GROUP_ID   NUMBER ,
                                PROJECT_ID   NUMBER ,
                                TASK_ID   NUMBER ,
                                END_ITEM_UNIT_NUMBER   VARCHAR2( 30 ) ,
                                HEADER_ID   NUMBER ,
                                LAST_UNIT_COMPLETION_DATE DATE,
                                ASSET_NUMBER   VARCHAR2( 30 ) ,
                                ASSET_GROUP_ID   NUMBER,
                                MAINTENANCE_OBJECT_ID   NUMBER,
                                MAINTENANCE_OBJECT_TYPE   NUMBER,
                                MAINTENANCE_OBJECT_SOURCE   NUMBER,
                                DATE_RELEASED   DATE,
                                OWNING_DEPARTMENT   NUMBER
                           );

TYPE  OP_CUR_REC  IS RECORD(
                               PARENT_HEADER_ID NUMBER,
                               WIP_ENTITY_ID   NUMBER,
                               ORGANIZATION_ID   NUMBER,
                               OPERATION_SEQ_NUM   NUMBER,
                               DEPARTMENT_ID   NUMBER,
                               DESCRIPTION   VARCHAR2( 240 ) ,
                               MINIMUM_TRANSFER_QUANTITY   NUMBER,
                               COUNT_POINT_TYPE   NUMBER,
                               BACKFLUSH_FLAG   NUMBER,
                               START_DATE   DATE,
                               COMPLETION_DATE   DATE
                             );
TYPE RES_CUR_REC IS RECORD(
                               PARENT_HEADER_ID NUMBER,
                               BATCH_ID   NUMBER  ,
	                    	   WIP_ENTITY_ID   NUMBER,
                               ORGANIZATION_ID   NUMBER,
                               OPERATION_SEQ_NUM   NUMBER,
                               RESOURCE_SEQ_NUM   NUMBER,
                               RESOURCE_ID_NEW NUMBER,
                               BASIS_TYPE   NUMBER,
                               USAGE_RATE_OR_AMOUNT   NUMBER,
                               SCHEDULED_FLAG   NUMBER,
                               ASSIGNED_UNITS   NUMBER,
                               AUTOCHARGE_TYPE   NUMBER,
                               START_DATE   DATE,
                               COMPLETION_DATE   DATE,
                               DEPARTMENT_ID   NUMBER,
                               FIRM_FLAG NUMBER
                          ) ;

TYPE MAT_CUR_REC IS RECORD(
                              PARENT_HEADER_ID NUMBER,
                              BATCH_ID   NUMBER,
                              WIP_ENTITY_ID   NUMBER,
                              ORGANIZATION_ID   NUMBER,
                              OPERATION_SEQ_NUM   NUMBER,
                              INVENTORY_ITEM_ID_NEW   NUMBER,
                              DEPARTMENT_ID   NUMBER,
                              WIP_SUPPLY_TYPE   NUMBER,
                              DATE_REQUIRED   DATE,
                              REQUIRED_QUANTITY   NUMBER
                          );

TYPE RES_INST_CUR_REC IS RECORD(
                              PARENT_HEADER_ID NUMBER,
                              BATCH_ID NUMBER,
                              WIP_ENTITY_ID NUMBER,
                              ORGANIZATION_ID NUMBER,
                              OPERATION_SEQ_NUM NUMBER,
                              RESOURCE_SEQ_NUM NUMBER,
                              RESOURCE_INSTANCE_ID NUMBER,
                              SERIAL_NUMBER VARCHAR2(30),
                              START_DATE DATE,
                              COMPLETION_DATE DATE);

TYPE RES_USAGE_CUR_REC IS RECORD(
                              PARENT_HEADER_ID NUMBER,
                              BATCH_ID NUMBER,
                              WIP_ENTITY_ID NUMBER,
                              ORGANIZATION_ID NUMBER,
                              OPERATION_SEQ_NUM NUMBER,
                              RESOURCE_SEQ_NUM NUMBER,
                              START_DATE DATE,
                              COMPLETION_DATE DATE,
                              ASSIGNED_UNITS NUMBER,
                              RESOURCE_INSTANCE_ID NUMBER,
                              SERIAL_NUMBER VARCHAR2(30));

TYPE JOBS_CUR_TBL_TYPE IS TABLE OF JOBS_CUR_REC INDEX BY BINARY_INTEGER ;
TYPE WO_ORG_TBL IS TABLE OF WO_ORG_REC  INDEX BY BINARY_INTEGER ;
TYPE OP_CUR_TBL_TYPE  IS TABLE OF OP_CUR_REC INDEX BY BINARY_INTEGER ;
TYPE RES_CUR_TBL_TYPE IS TABLE OF RES_CUR_REC INDEX BY BINARY_INTEGER ;
TYPE MAT_CUR_TBL_TYPE IS TABLE OF MAT_CUR_REC INDEX BY BINARY_INTEGER ;
TYPE RES_INST_CUR_TBL_TYPE IS TABLE OF RES_INST_CUR_REC INDEX BY BINARY_INTEGER;
TYPE RES_USAGE_CUR_TBL_TYPE IS TABLE OF RES_USAGE_CUR_REC INDEX BY BINARY_INTEGER;

TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type

    PROCEDURE  RESCHEDULE_CMRO_WO
              (
                ERRBUF OUT NOCOPY VARCHAR2
                ,RETCODE OUT  NOCOPY VARCHAR2
                ,P_DBLINK IN VARCHAR2
                ,P_GROUP_ID IN NUMBER
                ,P_SR_INSTANCE_ID IN NUMBER
              );

    PROCEDURE  Process_Single_WO
              (
                 V_WIP_ENTITY_ID IN NUMBER
                ,V_ORGANIZATION_ID IN NUMBER
              );

    PROCEDURE GET_WO_DETAIL
              (
                V_WIP_ENTITY_ID IN NUMBER, V_ORGANIZATION_ID IN NUMBER
                ,L_EAM_WO_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_WO_TBL_TYPE
              );

    PROCEDURE GET_OP_DETAIL (V_WIP_ENTITY_ID IN NUMBER ,
                       V_ORGANIZATION_ID IN NUMBER ,
                       L_EAM_OP_TBL OUT  NOCOPY EAM_PROCESS_WO_PUB.EAM_OP_TBL_TYPE
                      );
    PROCEDURE GET_RES_DETAIL(V_WIP_ENTITY_ID IN NUMBER ,
                             V_ORGANIZATION_ID IN NUMBER ,
                         L_EAM_RES_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_RES_TBL_TYPE
                      );

    PROCEDURE GET_MAT_DETAIL(V_WIP_ENTITY_ID IN NUMBER ,V_ORGANIZATION_ID IN NUMBER,
          L_EAM_MAT_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_MAT_REQ_TBL_TYPE ) ;


    PROCEDURE   POPULATE_MISSING_DETAILS( V_WIP_ENTITY_ID IN NUMBER ,
                              V_ORGANIZATION_ID IN NUMBER,
                              P_JOB_START_DATE IN DATE
                              );


    PROCEDURE GET_RES_INST_DETAIL(V_WIP_ENTITY_ID IN NUMBER ,
                                 V_ORGANIZATION_ID IN NUMBER,
              L_EAM_RES_INST_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_RES_INST_TBL_TYPE);

    PROCEDURE GET_RES_USAGE_DETAIL(V_WIP_ENTITY_ID IN NUMBER ,
                                   V_ORGANIZATION_ID IN NUMBER,
             L_EAM_RES_USAGE_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_RES_USAGE_TBL_TYPE);

END MRP_RESCHEDULE_CMRO_WO_PS;

/
