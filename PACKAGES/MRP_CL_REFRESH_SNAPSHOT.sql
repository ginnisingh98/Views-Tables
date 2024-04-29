--------------------------------------------------------
--  DDL for Package MRP_CL_REFRESH_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_CL_REFRESH_SNAPSHOT" AUTHID CURRENT_USER AS -- specification
/* $Header: MRPCLEAS.pls 120.6.12010000.2 2008/10/06 08:16:01 sbyerram ship $ */

  TYPE SnapTblTyp IS TABLE OF VARCHAR2(30);
  G_MSC_DEBUG   VARCHAR2(1) := NVL(FND_PROFILE.Value('MRP_DEBUG'),'N');
  v_explode_ato VARCHAR2(1) := NVL(FND_PROFILE.Value('MRP_EXPLODE_ATO'),'Y');
  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   SYS_INCR                      CONSTANT NUMBER := 3; -- incr refresh in continous collections
   SYS_TGT                       CONSTANT NUMBER := 4; -- targeted refresh in continous collections

   G_COLLECTIONS                CONSTANT NUMBER := 1;
   G_MANUAL                     CONSTANT NUMBER := 2;

   G_NORMAL_COMPLETION		CONSTANT NUMBER := 1;
   G_PENDING_INACTIVE		CONSTANT NUMBER := 2;
   G_OTHERS			CONSTANT NUMBER := 3;

   ASL_YES_RETAIN_CP		CONSTANT NUMBER :=3;

 ----- PARAMETERS --------------------------------------------------------

   v_debug                     BOOLEAN := FALSE;

   v_cp_enabled                NUMBER;

   v_lrn                       NUMBER;
   v_request_id                NUMBER;
   v_refresh_type              VARCHAR2(1);
   v_oh_sn_flag                NUMBER;

   v_refresh_number            NUMBER:= 0;

   --  ================= Procedures ====================

   FUNCTION SETUP_SOURCE_OBJECTS  RETURN BOOLEAN ;
   PROCEDURE REFRESH_SNAPSHOT(
                      ERRBUF             OUT NOCOPY VARCHAR2,
                      RETCODE            OUT NOCOPY NUMBER,
                      p_user_name        IN  VARCHAR2,
                      p_resp_name        IN  VARCHAR2,
                      p_application_name IN  VARCHAR2,
                      p_refresh_type     IN  VARCHAR2 := 'C',
                      o_request_id       OUT NOCOPY NUMBER,
                      pInstance_ID               IN  NUMBER,
                      pInstance_Code     IN  VARCHAR2,
                      pa2m_dblink        IN  VARCHAR2);

   PROCEDURE WAIT_FOR_REQUEST(
                      p_timeout          IN  NUMBER,
                      o_retcode          OUT NOCOPY NUMBER);

   PROCEDURE WAIT_FOR_REQUEST(
                      p_request_id in number,
                      p_timeout          IN  NUMBER,
                      o_retcode          OUT NOCOPY NUMBER);

PROCEDURE check_MV_cont_ref_type(p_MV_name   in  varchar2,
                                 p_entity_lrn    in  number,
                                 entity_flag     OUT NOCOPY  number,
                                 p_ad_table_name in  varchar2,
                                 p_org_str       in  varchar2,
                                 p_coll_thresh   in  number,
                                 p_last_tgt_cont_coll_time  in  date,
                                 p_ret_code      OUT NOCOPY number,
                                 p_err_buf       OUT NOCOPY varchar2);

PROCEDURE check_entity_cont_ref_type(p_entity_name   in  varchar2,
                                     p_entity_lrn    in  number,
                                     entity_flag     OUT NOCOPY  number,
                                     p_org_str       in  varchar2,
                                     p_coll_thresh   in  number,
                                     p_last_tgt_cont_coll_time  in  date,
                                     p_ret_code      OUT NOCOPY number,
                                     p_err_buf       OUT NOCOPY varchar2);

PROCEDURE REFRESH_SINGLE_SNAPSHOT(
                      ERRBUF            OUT NOCOPY VARCHAR2,
                      RETCODE           OUT NOCOPY NUMBER,
                      pREFRESH_MODE      IN  NUMBER,
                      pSNAPSHOT_NAME     IN  VARCHAR2,
                      pDEGREE            IN  NUMBER,
                      pCURRENT_LRN       IN  NUMBER default -1,
                      p_NUMBER_OF_ROWS   IN  NUMBER default 0);

  /* added this procedure for the new conc program defn of Refresh Snapshots */
   PROCEDURE REFRESH_SNAPSHOT(
                      ERRBUF		 OUT NOCOPY VARCHAR2,
	              RETCODE		 OUT NOCOPY NUMBER,
                      pREFRESH_MODE      IN  NUMBER,
                      pSNAPSHOT_NAME     IN  VARCHAR2,
                      pNUMBER_OF_ROWS    IN  NUMBER,
                      pDEGREE            IN  NUMBER,
                      pCP_ENABLED              IN  NUMBER default MSC_UTIL.SYS_YES,
                      pREFRESH_TYPE            IN  VARCHAR2 default 'C',
                      pCALLING_MODULE    IN  NUMBER DEFAULT G_MANUAL,
                      pINSTANCE_ID       IN  NUMBER DEFAULT NULL,
                      pINSTANCE_CODE     IN  VARCHAR2 DEFAULT NULL,
                      pA2M_DBLINK        IN  VARCHAR2 DEFAULT NULL);

   PROCEDURE DROP_SNAPSHOT(
                      ERRBUF		 OUT NOCOPY VARCHAR2,
	              RETCODE		 OUT NOCOPY NUMBER,
                      p_snapshot_str     IN  VARCHAR2);

   PROCEDURE LOG_DEBUG( pBUFF                     IN  VARCHAR2);

   PROCEDURE LOG_ERROR(  pBUFF                   IN  VARCHAR2);


   PROCEDURE PURGE_OBSOLETE_DATA;

      /* -- Added this procedure to accept application_id instead of application_name */

   PROCEDURE REFRESH_SNAPSHOT(
                      ERRBUF             OUT NOCOPY VARCHAR2,
                      RETCODE            OUT NOCOPY NUMBER,
                      p_user_name        IN  VARCHAR2,
                      p_resp_name        IN  VARCHAR2,
                      p_application_name IN  VARCHAR2,
		      p_refresh_type	 IN  VARCHAR2 := 'C',
                      o_request_id       OUT NOCOPY NUMBER,
                      pInstance_ID               IN  NUMBER,
                      pInstance_Code     IN  VARCHAR2,
                      pa2m_dblink        IN  VARCHAR2,
                      p_application_id   IN  NUMBER);
  /* bug 5959340*/
  PROCEDURE CREATE_SOURCE_VIEWS(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER);

  /* bug 5959340*/
  PROCEDURE CREATE_SOURCE_TRIGGERS(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER);

END MRP_CL_REFRESH_SNAPSHOT;

/
