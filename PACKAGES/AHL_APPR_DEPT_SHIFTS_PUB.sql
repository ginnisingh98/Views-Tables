--------------------------------------------------------
--  DDL for Package AHL_APPR_DEPT_SHIFTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_APPR_DEPT_SHIFTS_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPDSHS.pls 120.1 2007/12/05 23:12:38 rbhavsar ship $ */
TYPE APPR_DEPTSHIFT_REC IS RECORD
(
        AHL_DEPARTMENT_SHIFTS_ID                NUMBER,
        ORGANIZATION_ID                         NUMBER,
        ORGANIZATION_NAME                       VARCHAR2(240),
        OBJECT_VERSION_NUMBER                   NUMBER,
        LAST_UPDATE_DATE                        DATE,
        LAST_UPDATED_BY                         NUMBER,
        CREATION_DATE                           DATE,
        CREATED_BY                              NUMBER,
        LAST_UPDATE_LOGIN                       NUMBER,
        DEPARTMENT_ID                           NUMBER,
        DEPT_DESCRIPTION                        VARCHAR2(240),
        CALENDAR_CODE                           VARCHAR2(10),
        CALENDAR_DESCRIPTION                    VARCHAR2(240),
        BOM_WORKDAY_PATTERNS_ID                 NUMBER,
        SHIFT_NUM                               NUMBER,
        SEQ_NUM                                 NUMBER,
        SEQ_NAME                                VARCHAR2(240),
-- Added by rbhavsar on Nov 27, 2007 for ER 5854712
        SUBINVENTORY                            VARCHAR2(10),
        INV_LOCATOR_ID                          NUMBER,
        LOCATOR_SEGMENTS                        VARCHAR2(240),
-- End Changes by rbhavsar on Nov 27, 2007 for ER 5854712
        ATTRIBUTE_CATEGORY                      VARCHAR2(30),
        ATTRIBUTE1                              VARCHAR2(150),
        ATTRIBUTE2                              VARCHAR2(150),
        ATTRIBUTE3                              VARCHAR2(150),
        ATTRIBUTE4                              VARCHAR2(150),
        ATTRIBUTE5                              VARCHAR2(150),
        ATTRIBUTE6                              VARCHAR2(150),
        ATTRIBUTE7                              VARCHAR2(150),
        ATTRIBUTE8                              VARCHAR2(150),
        ATTRIBUTE9                              VARCHAR2(150),
        ATTRIBUTE10                             VARCHAR2(150),
        ATTRIBUTE11                             VARCHAR2(150),
        ATTRIBUTE12                             VARCHAR2(150),
        ATTRIBUTE13                             VARCHAR2(150),
        ATTRIBUTE14                             VARCHAR2(150),
        ATTRIBUTE15                             VARCHAR2(150),
        DML_OPERATION                           VARCHAR2(1):='N');


PROCEDURE CREATE_APPR_DEPT_SHIFTS
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT  NOCOPY     VARCHAR2,
 x_msg_count                    OUT  NOCOPY    NUMBER,
 x_msg_data                     OUT  NOCOPY    VARCHAR2,
 p_x_appr_deptshift_rec      IN  OUT NOCOPY APPR_DEPTSHIFT_REC
 );

PROCEDURE DELETE_APPR_DEPT_SHIFTS
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_x_appr_deptshift_rec      IN  OUT NOCOPY APPR_DEPTSHIFT_REC
 );
END AHL_APPR_DEPT_SHIFTS_PUB;

/
