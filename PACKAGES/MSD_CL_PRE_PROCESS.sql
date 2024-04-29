--------------------------------------------------------
--  DDL for Package MSD_CL_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CL_PRE_PROCESS" AUTHID CURRENT_USER AS -- specification
/* $Header: MSDCLPPS.pls 120.3 2007/09/07 09:22:43 abhikuma ship $ */

  ----- CONSTANTS ------------------------------------------------
  G_ERROR          CONSTANT   NUMBER := 2;
  G_WARNING        CONSTANT   NUMBER := 1;

  NULL_CHAR        CONSTANT VARCHAR2(6) := '-23453';
  NULL_VALUE       CONSTANT   NUMBER := -23453;

  SYS_YES                                 CONSTANT NUMBER := 1;
  SYS_NO                                  CONSTANT NUMBER := 2;

  G_NEW_REQUEST         CONSTANT NUMBER :=0; -- new request
  G_DP_LV_REQ_DATA      CONSTANT NUMBER :=2; -- DP Level Values sub-request
  G_DP_CS_REQ_DATA      CONSTANT NUMBER :=3; -- DP custom stream sub-request
  G_NO_PLAN_PERCENTAGE  CONSTANT NUMBER :=1; -- Profile option choice 1 for profile MSD_PLANNING_PERCENTAGE.
  G_INS_OTHER           CONSTANT NUMBER :=3; -- Legacy Instance Type

  -- Calling module --------------------------------------------------

   G_APS                                  CONSTANT NUMBER := 1;
   G_DP                                   CONSTANT NUMBER := 2;

  ----- GLobal Variable -------------------------------------------------
   v_link                                         NUMBER;

  -- ================== Process Flag ===================
   G_NEW                                   CONSTANT NUMBER := 1;
   G_IN_PROCESS                            CONSTANT NUMBER := 2;
   G_ERROR_FLG                             CONSTANT NUMBER := 3;
   G_VALID                                 CONSTANT NUMBER := 5;

   G_BUCKET_TYPE                          CONSTANT NUMBER := 1;
   G_MFG_CAL                              CONSTANT NUMBER := 2;
   G_FISCAL_CAL                           CONSTANT NUMBER := 3;
   G_COMPOSITE_CAL                        CONSTANT NUMBER := 4;



   G_SEV3_ERROR                           CONSTANT NUMBER := 3;
   G_SEV_ERROR                            CONSTANT NUMBER := 1;

  --========================PROCEDURES=================
  PROCEDURE  LOAD_ORG_CUST (ERRBUF          OUT NOCOPY VARCHAR,
                            RETCODE         OUT NOCOPY NUMBER,
                            p_instance_id  IN NUMBER,
                            p_batch_id     IN NUMBER);


  PROCEDURE LOAD_ITEMS     (ERRBUF          OUT NOCOPY VARCHAR,
                            RETCODE         OUT NOCOPY NUMBER,
                            p_instance_id  IN NUMBER,
                            p_batch_id     IN NUMBER);

  PROCEDURE LOAD_CATEGORY  (ERRBUF          OUT NOCOPY VARCHAR,
                            RETCODE         OUT NOCOPY NUMBER,
                            p_instance_id  IN NUMBER,
                            p_batch_id     IN NUMBER,
                            p_link         IN NUMBER);

  PROCEDURE LOAD_SITE      (ERRBUF          OUT NOCOPY VARCHAR,
                            RETCODE         OUT NOCOPY NUMBER,
                            p_instance_id  IN NUMBER,
                            p_batch_id     IN NUMBER);


  PROCEDURE LOAD_LEVEL_VALUE (ERRBUF          OUT NOCOPY VARCHAR,
                             RETCODE         OUT NOCOPY NUMBER,
                             p_instance_code IN VARCHAR,
                             p_instance_id   IN NUMBER,
                             p_batch_id      IN NUMBER);

  PROCEDURE LOAD_LEVEL_ASSOC( ERRBUF          OUT NOCOPY VARCHAR,
                              RETCODE         OUT NOCOPY VARCHAR,
                              p_instance_code IN VARCHAR,
                              p_instance_id   IN NUMBER,
                              p_batch_id      IN NUMBER);


  PROCEDURE LOAD_BOOKING_DATA(ERRBUF          OUT NOCOPY VARCHAR,
                              RETCODE         OUT NOCOPY NUMBER,
                              p_instance_code IN VARCHAR,
                              p_instance_id   IN NUMBER,
                              p_batch_id      IN NUMBER);


  PROCEDURE LOAD_SHIPMENT_DATA(ERRBUF          OUT NOCOPY VARCHAR,
                               RETCODE         OUT NOCOPY NUMBER,
                               p_instance_code IN VARCHAR,
                               p_instance_id   IN NUMBER,
                               p_batch_id      IN NUMBER);

  PROCEDURE LOAD_MFG_FORECAST(ERRBUF          OUT NOCOPY VARCHAR,
                              RETCODE         OUT NOCOPY NUMBER,
                              p_instance_code IN VARCHAR,
                              p_instance_id   IN NUMBER,
                              p_batch_id      IN NUMBER);

  PROCEDURE LOAD_MFG_TIME (ERRBUF            OUT NOCOPY VARCHAR,
                           RETCODE           OUT  NOCOPY NUMBER,
                           p_instance_id     IN NUMBER,
                           p_calendar_code   IN VARCHAR);

  PROCEDURE LOAD_FISCAL_TIME (ERRBUF          OUT NOCOPY VARCHAR,
                              RETCODE         OUT NOCOPY NUMBER,
                              p_instance_code IN VARCHAR,
                              p_instance_id   IN NUMBER);

  PROCEDURE LOAD_COMPOSITE_TIME (ERRBUF          OUT NOCOPY VARCHAR,
                                 RETCODE         OUT NOCOPY NUMBER,
                                 p_instance_code IN VARCHAR,
                                 p_instance_id   IN NUMBER);

  PROCEDURE LOAD_CURRENCY_CONV (ERRBUF          OUT NOCOPY VARCHAR,
                                RETCODE         OUT NOCOPY NUMBER,
                                p_instance_code IN VARCHAR,
                                p_instance_id   IN NUMBER,
                                p_batch_id      IN NUMBER);

  PROCEDURE LOAD_CS_DATA (ERRBUF          OUT NOCOPY VARCHAR,
                          RETCODE         OUT NOCOPY NUMBER,
                          p_instance_code IN VARCHAR,
                          p_instance_id   IN NUMBER,
                          p_batch_id      IN NUMBER);

  PROCEDURE LOAD_PRICE_LIST (ERRBUF          OUT NOCOPY VARCHAR,
                             RETCODE         OUT NOCOPY NUMBER,
                             p_instance_code IN VARCHAR,
                             p_instance_id   IN NUMBER,
                             p_batch_id      IN NUMBER);


  PROCEDURE LOAD_UOM_CONV (ERRBUF          OUT NOCOPY VARCHAR,
                           RETCODE         OUT NOCOPY NUMBER,
                           p_instance_code IN VARCHAR,
                           p_instance_id   IN NUMBER,
                           p_batch_id      IN NUMBER);


  PROCEDURE LOAD_SETUP_PARAMETER(ERRBUF          OUT NOCOPY VARCHAR,
                                 RETCODE         OUT NOCOPY NUMBER,
                                 p_instance_code IN VARCHAR,
                                 p_instance_id   IN NUMBER);

   PROCEDURE LOAD_ITEM_RELATIONSHIP ( p_instance_code IN VARCHAR,
                                      p_instance_id   IN NUMBER );

   PROCEDURE LOAD_LEVEL_ORG_ASSCNS ( p_instance_code IN VARCHAR,
                                     p_instance_id   IN NUMBER );

   PROCEDURE LOAD_DEMAND_CLASS  (ERRBUF          OUT NOCOPY VARCHAR,
                                 RETCODE         OUT NOCOPY NUMBER,
                                 p_instance_code IN VARCHAR,
                                 p_instance_id   IN NUMBER,
                                 p_batch_id      IN NUMBER );


   PROCEDURE  LAUNCH_PULL_PROGRAM(ERRBUF  OUT  NOCOPY VARCHAR2,
                       RETCODE            OUT  NOCOPY NUMBER,
                       p_instance_id      IN   NUMBER ,
                       p_request_id       IN   NUMBER ,
                       p_launch_lvalue    IN   NUMBER DEFAULT SYS_NO,
                       p_launch_booking   IN   NUMBER DEFAULT SYS_NO,
                       p_launch_shipment  IN   NUMBER DEFAULT SYS_NO,
                       p_launch_forecast  IN   NUMBER DEFAULT SYS_NO,
                       p_launch_time      IN   NUMBER DEFAULT SYS_NO,
                       p_launch_pricing   IN   NUMBER DEFAULT SYS_NO,
                       p_launch_curr_conv IN   NUMBER DEFAULT SYS_NO,
                       p_launch_uom_conv  IN   NUMBER DEFAULT SYS_NO,
                       p_launch_cs_data   IN   NUMBER DEFAULT SYS_NO,
                       p_cs_refresh       IN   NUMBER DEFAULT SYS_NO) ;

     PROCEDURE LAUNCH_MONITOR( ERRBUF                OUT NOCOPY VARCHAR2,
                             RETCODE               OUT NOCOPY NUMBER,
                             p_instance_id         IN  NUMBER,
                             p_timeout             IN  NUMBER DEFAULT 1440,
                             p_batch_size          IN  NUMBER DEFAULT 1000,
                             p_total_worker_num    IN  NUMBER DEFAULT 3,
                             p_ascp_ins_dummy      IN  VARCHAR2 DEFAULT NULL,
                             p_dummy1              IN  VARCHAR2 DEFAULT NULL,
                             p_dummy2              IN  VARCHAR2 DEFAULT NULL,
                             p_cal_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_dmd_class_enabled   IN  NUMBER DEFAULT SYS_YES,
                             p_tp_enabled          IN  NUMBER DEFAULT SYS_YES,
                             p_list_price_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_ctg_enabled         IN  NUMBER DEFAULT SYS_YES,
                             p_item_enabled        IN  NUMBER DEFAULT SYS_YES,
                             p_item_cat_enabled    IN  NUMBER DEFAULT SYS_YES,
                             p_rollup_dummy        IN  VARCHAR2 DEFAULT NULL,
                             p_item_rollup         IN  NUMBER DEFAULT SYS_YES,
                             p_bom_enabled         IN  NUMBER DEFAULT SYS_YES,
                             p_uom_enabled         IN  NUMBER DEFAULT SYS_YES,
                             p_uom_conv_enabled    IN  NUMBER DEFAULT SYS_NO ,
                             p_curr_conv_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_setup_enabled       IN  NUMBER DEFAULT SYS_NO,
                             p_fiscal_cal_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_comp_cal_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_level_value_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_level_assoc_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_booking_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_shipment_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_mfg_fct_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_cs_data_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_cs_dummy            IN  VARCHAR2 DEFAULT NULL,
                             p_cs_refresh          IN  NUMBER DEFAULT SYS_NO,
                             p_parent_request_id   IN  NUMBER DEFAULT -1,
                             p_calling_module      IN  NUMBER DEFAULT G_DP);

      PROCEDURE LAUNCH_DELETE_DUPLICATES(ERRBUF OUT NOCOPY VARCHAR2,
                                         RETCODE OUT NOCOPY NUMBER,
                                          p_instance_id IN NUMBER);

 END MSD_CL_PRE_PROCESS;


/
