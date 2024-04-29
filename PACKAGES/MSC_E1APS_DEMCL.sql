--------------------------------------------------------
--  DDL for Package MSC_E1APS_DEMCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_E1APS_DEMCL" AUTHID CURRENT_USER AS
                --# $Header: MSCE1DMS.pls 120.0.12010000.9 2009/08/26 13:18:02 nyellank noship $
                /*** GLOBAL VARIABLES ***/
                /*** PROCEDURES ***/
                /*
                * This procedure analyzes the given table
                */
        FUNCTION CALL_ODIEXE(scenario_name    IN VARCHAR2 ,
                             scenario_version IN VARCHAR2 ,
                             scenario_param   IN VARCHAR2 ,
                             wsurl            IN VARCHAR2)
                RETURN BOOLEAN;
        PROCEDURE DEM_PL_UOM(ERRBUF OUT NOCOPY  VARCHAR2 ,
                             RETCODE OUT NOCOPY VARCHAR2 ,
                             p_instance_id   IN      NUMBER ,
                             p_price_list IN      NUMBER ,
                             p_uom        IN      NUMBER);
        PROCEDURE DEM_SH(ERRBUF OUT NOCOPY        VARCHAR2,
                         RETCODE OUT NOCOPY       VARCHAR2,
                         p_instance_id IN            NUMBER,
                         p_auto_run IN            NUMBER );
        PROCEDURE DEM_PTP(ERRBUF OUT NOCOPY       VARCHAR2,
                          RETCODE OUT NOCOPY      VARCHAR2,
                          p_instance_id      IN           NUMBER,
                          p_list_price    IN           NUMBER,
                          p_item_cost     IN           NUMBER,
                          p_price_history IN           NUMBER);
        PROCEDURE PUB_PPR(ERRBUF OUT NOCOPY            VARCHAR2,
                          RETCODE OUT NOCOPY           VARCHAR2,
                          p_instance_id IN             NUMBER,
                          p_plan_id  IN                VARCHAR2,
                          p_purchase_plan IN           NUMBER,
                          p_deployment_plan IN         NUMBER,
                          p_detailed_production_plan IN NUMBER );
        PROCEDURE DEM_PUB_FSS(ERRBUF OUT NOCOPY        VARCHAR2,
                              RETCODE OUT NOCOPY       VARCHAR2,
                              p_instance_id IN            NUMBER );
        PROCEDURE DEM_PUB_PTP(ERRBUF OUT NOCOPY        VARCHAR2 ,
                              RETCODE OUT NOCOPY       VARCHAR2 ,
                              p_instance_id IN            NUMBER );
        PROCEDURE DEM_PUB_DSM(ERRBUF OUT NOCOPY        VARCHAR2 ,
                              RETCODE OUT NOCOPY       VARCHAR2 ,
                              p_instance_id   IN            NUMBER ,
                              p_pb_claims      IN            NUMBER ,
                              p_pb_dedu_dispos IN            NUMBER);
        END MSC_E1APS_DEMCL;

/
