--------------------------------------------------------
--  DDL for Package MSC_E1APS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_E1APS_UTIL" AUTHID CURRENT_USER AS
                --# $Header: MSCE1ULS.pls 120.0.12010000.11 2009/08/26 13:13:49 nyellank noship $

        /* Contants */

        COL_PLAN_DATA         CONSTANT NUMBER := 1;
        PUB_PLAN_RES          CONSTANT NUMBER := 2;
        COL_SALES_HST         CONSTANT NUMBER := 3;
        COL_PRC_UOM           CONSTANT NUMBER := 4;
        PUB_FCST              CONSTANT NUMBER := 5;
        COL_PTP_DATA          CONSTANT NUMBER := 6;
        PUB_PTP_RES           CONSTANT NUMBER := 7;
        COL_DSM_DATA          CONSTANT NUMBER := 8;
        PUB_DSM_RES           CONSTANT NUMBER := 9;

        /*Consants for Demantra workflow*/

        DEM_SUCCESS         CONSTANT NUMBER := 0;
        DEM_WARNING         CONSTANT NUMBER := 1;
        DEM_FAILURE         CONSTANT NUMBER := 2;


        FUNCTION MSC_E1APS_ODIScenarioExecute ( ScenarioName    IN VARCHAR2,
                                                ScenarioVersion IN VARCHAR2,
                                                ScenarioParam   IN VARCHAR2,
                                                WsUrl           IN VARCHAR2 )
                RETURN VARCHAR2;
        FUNCTION MSC_E1APS_ODIInitialize ( WsUrl IN VARCHAR2,
                                           BaseDate INTEGER )
                RETURN VARCHAR2;
        PROCEDURE DEM_WORKFLOW(errbuf OUT NOCOPY           VARCHAR2 ,
                               retcode OUT NOCOPY          VARCHAR2 ,
                               l_wf_lookup_code IN         VARCHAR2 ,
                               process_id OUT NOCOPY       VARCHAR2 ,
                               p_user_id IN                NUMBER);
        FUNCTION PUBLISH_DEM_WORKFLOW(ERRBUF OUT NOCOPY   VARCHAR2 ,
                                       RETCODE OUT NOCOPY  VARCHAR2 ,
                                       p_instance_id    IN NUMBER   ,
                                       l_wf_lookup_code IN VARCHAR2 ,
                                       scenario_name    IN VARCHAR2 ,
                                       p_user_id        IN NUMBER)
              RETURN NUMBER;
        END MSC_E1APS_UTIL;

/
