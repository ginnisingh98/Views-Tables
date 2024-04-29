--------------------------------------------------------
--  DDL for Package MSC_PURGE_LID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PURGE_LID" AUTHID CURRENT_USER AS
/*$Header: MSCPPURS.pls 120.1.12010000.4 2009/07/08 09:37:55 lsindhur ship $ */
-- ================== CONSTANTS =====================
  G_ST_EMPTY 			                   CONSTANT NUMBER:= 0;
  G_ST_PULLING                       CONSTANT NUMBER:= 1;
  G_ST_READY                         CONSTANT NUMBER:= 2;
  G_ST_COLLECTING                    CONSTANT NUMBER:= 3;
  G_ST_PURGING                       CONSTANT NUMBER:= 4;
  G_ST_PRE_PROCESSING                CONSTANT NUMBER:= 5;
  G_INS_OTHER                        CONSTANT NUMBER:= 3;
  G_INS_EXCH                         CONSTANT NUMBER:= 5;

  G_ERROR                            CONSTANT NUMBER:= 2;
  G_SUCCESS                          CONSTANT NUMBER:= 0;

  ----- CONSTANTS --------------------------------------------------------
  SYS_YES                           CONSTANT NUMBER := 1;
  SYS_NO                            CONSTANT NUMBER := 2;

type entity_list is TABLE OF varchar2(255) INDEX BY BINARY_INTEGER;

--  ================= Procedures ====================
  PROCEDURE PURGE_LID_TABLES(ERRBUF              OUT NOCOPY VARCHAR2,
                             RETCODE             OUT NOCOPY NUMBER,
                             p_instance_id       IN  NUMBER,
                             p_complete_refresh  IN  NUMBER     DEFAULT SYS_NO,
                             p_date              IN  VARCHAR2,
                             p_supply_flag       IN  NUMBER     DEFAULT SYS_NO,
                             p_demand_flag       IN  NUMBER     DEFAULT SYS_NO);


PROCEDURE PURGE_ODS_TABLES_DEL( p_instance_id     IN  NUMBER);

-- Added for purge_instance_plan_data, purge_instance_data and purge_plan_data

  TYPE tblTyp IS TABLE OF NUMBER;

  PROCEDURE PURGE_INSTANCE_DATA(  ERRBUF        OUT NOCOPY VARCHAR2,

                                  RETCODE       OUT NOCOPY NUMBER,

                                  pInstList     tblTyp);



  PROCEDURE PURGE_PLAN_DATA(  ERRBUF        OUT NOCOPY VARCHAR2,

                              RETCODE       OUT NOCOPY NUMBER,

                             pPlanList     tblTyp);



  PROCEDURE PURGE_INSTANCE_PLAN_DATA( ERRBUF        OUT NOCOPY VARCHAR2,

                                    RETCODE       OUT NOCOPY NUMBER,

                                    pInstanceId   NUMBER,

                                    pPlanId       NUMBER) ;

  PROCEDURE Purge_localid_table( pMode NUMBER,
                            pTable_name VARCHAR2,
                            pInstance_id NUMBER,
                            pPlan_id     NUMBER,
                            pWhereClause VARCHAR2
                            );

PROCEDURE PURGE_ODS_DATA(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               ppurgeglobalflag                   IN  NUMBER,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER   ,
               pATP_RULES_ENABLED                 IN  NUMBER   ,
               pBOM_ENABLED                       IN  NUMBER   ,
               pBOR_ENABLED                       IN  NUMBER   ,
               pCALENDAR_ENABLED                  IN  NUMBER   ,
               pDEMAND_CLASS_ENABLED              IN  NUMBER   ,
               pITEM_SUBST_ENABLED                IN  NUMBER   ,
               pFORECAST_ENABLED                  IN  NUMBER   ,
               pITEM_ENABLED                      IN  NUMBER   ,
               pKPI_BIS_ENABLED                   IN  NUMBER   ,
               pMDS_ENABLED                       IN  NUMBER   ,
               pMPS_ENABLED                       IN  NUMBER   ,
               pOH_ENABLED                        IN  NUMBER   ,
               pPARAMETER_ENABLED                 IN  NUMBER   ,
               pPLANNER_ENABLED                   IN  NUMBER   ,
               pPO_RECEIPTS_ENABLED               IN  NUMBER   ,
               pPROJECT_ENABLED                   IN  NUMBER   ,
               pPUR_REQ_PO_ENABLED                IN  NUMBER   ,
               pRESERVES_HARD_ENABLED             IN  NUMBER   ,
               pRESOURCE_NRA_ENABLED              IN  NUMBER   ,
               pSafeStock_ENABLED                 IN  NUMBER   ,
               pSalesOrder_ENABLED                IN  NUMBER   ,
               pSH_ENABLED                        IN  NUMBER   ,
               pSOURCING_ENABLED                  IN  NUMBER   ,
               pSUB_INV_ENABLED                   IN  NUMBER   ,
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER   ,
               pTP_ENABLED                        IN  NUMBER   ,
               pTRIP_ENABLED                      IN  NUMBER   ,
               pUNIT_NO_ENABLED                   IN  NUMBER   ,
               pUOM_ENABLED                       IN  NUMBER   ,
	             pUSER_COMPANY_ENABLED              IN  NUMBER   ,
               pUSER_SUPPLY_DEMAND                IN  NUMBER   ,
               pWIP_ENABLED                       IN  NUMBER   ,
               pSALES_CHANNEL_ENABLED             IN  NUMBER   ,
               pFISCAL_CALENDAR_ENABLED           IN  NUMBER   ,
               pINTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pEXTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pPAYBACK_DEMAND_SUPPLY_ENABLED     IN  NUMBER   ,
               pCURRENCY_CONVERSION_ENABLED	      IN  NUMBER   ,
               pDELIVERY_DETAILS_ENABLED	        IN  NUMBER
               ) ;

PROCEDURE PURGE_ODS_LEG_DATA(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               ppurgelocalidflag                        IN NUMBER,
               ppurgeglobalflag                      IN NUMBER,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER   ,
               pATP_RULES_ENABLED                 IN  NUMBER   ,
               pBOM_ENABLED                       IN  NUMBER   ,
               pRESOURCE_ENABLED                  IN  NUMBER   ,
               pROUTING_ENABLED                   IN  NUMBER   ,
               pOPERATION_ENABLED                 IN  NUMBER   ,
               pBOR_ENABLED                       IN  NUMBER   ,
               pCALENDAR_ENABLED                  IN  NUMBER   ,
               pCALENDAR_ASSIGN_ENABLED           IN  NUMBER   ,
               pDEMAND_CLASS_ENABLED              IN  NUMBER   ,
               pITEM_SUBST_ENABLED                IN  NUMBER   ,
               pDESIGNATORS_ENABLED               IN  NUMBER   ,
               pFORECAST_ENABLED                  IN  NUMBER   ,
               pITEM_ENABLED                      IN  NUMBER   ,
               pITEM_CATEGORIES_ENABLED           IN  NUMBER   ,
               pCATEGORY_SETS_ENABLED             IN  NUMBER   ,
               pKPI_BIS_ENABLED                   IN  NUMBER   ,
               pMDS_ENABLED                       IN  NUMBER   ,
               pMPS_ENABLED                       IN  NUMBER   ,
               pOH_ENABLED                        IN  NUMBER   ,
               pPARAMETER_ENABLED                 IN  NUMBER   ,
               pPLANNER_ENABLED                   IN  NUMBER   ,
               pPO_RECEIPTS_ENABLED               IN  NUMBER   ,
               pPROJECT_ENABLED                   IN  NUMBER   ,
               pPUR_REQ_PO_ENABLED                IN  NUMBER   ,
               pRESERVES_HARD_ENABLED             IN  NUMBER   ,
               pRESOURCE_NRA_ENABLED              IN  NUMBER   ,
               pSafeStock_ENABLED                 IN  NUMBER   ,
               pSalesOrder_ENABLED                IN  NUMBER   ,
               pSH_ENABLED                        IN  NUMBER   ,
               pSHIP_METHOD_ENABLED               IN  NUMBER   ,
               pSOURCING_ENABLED                  IN  NUMBER   ,
               pSUB_INV_ENABLED                   IN  NUMBER   ,
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER   ,
               pTP_ENABLED                        IN  NUMBER   ,
               pTRIP_ENABLED                      IN  NUMBER   ,
               pUNIT_NO_ENABLED                   IN  NUMBER   ,
               pUOM_ENABLED                       IN  NUMBER   ,
               pUOM_CONVERSIONS_ENABLED           IN  NUMBER   ,
               pUSER_COMPANY_ENABLED              IN  NUMBER   ,
               pUSER_DEMAND                       IN  NUMBER   ,
               pUSER_SUPPLY                       IN  NUMBER   ,
               pWIP_ENABLED                       IN  NUMBER   ,
               pSALES_CHANNEL_ENABLED             IN  NUMBER   ,
               pFISCAL_CALENDAR_ENABLED           IN  NUMBER   ,
               pINTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pEXTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pPAYBACK_DEMAND_SUPPLY_ENABLED     IN  NUMBER   ,
               pCURRENCY_CONVERSION_ENABLED       IN  NUMBER   ,
               pDELIVERY_DETAILS_ENABLED          IN  NUMBER
               ) ;

PROCEDURE PURGE_INST_ENTITY_ODS_DATA (
            pINSTANCE_ID                       IN  NUMBER,
            parray                             IN entity_list,
            ppurgelocalidflag                  IN NUMBER,
            ppurgeglobalflag                   IN NUMBER,
            pstatusflag                      OUT NOCOPY NUMBER
              );

END MSC_PURGE_LID;

/
