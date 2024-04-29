--------------------------------------------------------
--  DDL for Package CSE_FAC_INSERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_FAC_INSERVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEFPISS.pls 120.3.12010000.1 2008/07/30 05:17:43 appldev ship $ */

  G_MISS_CHAR               CONSTANT    VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_NUM                CONSTANT    NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_DATE               CONSTANT    DATE        := FND_API.G_MISS_DATE;
  G_RET_STS_SUCCESS        CONSTANT    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR        CONSTANT    VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR ;
  G_False                   CONSTANT    VARCHAR2(1) := FND_API.G_FALSE;
  G_True                    CONSTANT    VARCHAR2(1) := FND_API.G_TRUE;
  G_VALID_LEVEL_FULL     CONSTANT    NUMBER := FND_API.G_VALID_LEVEL_FULL;
  G_API_NAME                CONSTANT    VARCHAR2(28):= 'CSE_FAC_PROJ_ITEM_IN_SVC_PKG';

  PROCEDURE create_expitem(
    X_Return_Status        OUT NOCOPY   VARCHAR2,
    X_Error_Message        OUT NOCOPY   VARCHAR2,
    P_Project_Num          IN  VARCHAR2 DEFAULT NULL,
    P_Task_Num             IN  VARCHAR2 DEFAULT NULL,
    P_conc_request_id      IN  NUMBER   DEFAULT NULL);

  PROCEDURE update_units(
    X_Return_Status        OUT NOCOPY   VARCHAR2,
    X_Error_Message        OUT NOCOPY   VARCHAR2,
    p_conc_request_id      IN  NUMBER   DEFAULT NULL);

  PROCEDURE create_pa_asset_headers(
    errbuf              OUT nocopy varchar2,
    retcode             OUT nocopy number,
    p_project_id     IN            number,
    p_task_id        IN            number,
    p_conc_request_id   IN         NUMBER := null);

END cse_fac_inservice_pkg;

/
