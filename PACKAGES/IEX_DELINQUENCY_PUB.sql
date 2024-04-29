--------------------------------------------------------
--  DDL for Package IEX_DELINQUENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DELINQUENCY_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpdels.pls 120.5 2005/01/26 16:21:47 acaraujo ship $ */

-- clchang updated 03/12/2003 to add score_value in delinquency_rec_type (11.5.9)
-- clchang updated 04/21/2003 to add customer_site_use_id in delinquency_rec_type (11.5.10)

TYPE DELINQUENCY_REC_TYPE IS RECORD
(   DELINQUENCY_ID         NUMBER    ,
    LAST_UPDATE_DATE       DATE      ,
    LAST_UPDATED_BY        NUMBER    ,
    LAST_UPDATE_LOGIN      NUMBER    ,
    CREATION_DATE          DATE      ,
    CREATED_BY             NUMBER    ,
    PROGRAM_ID             NUMBER    ,
    OBJECT_VERSION_NUMBER  NUMBER    ,
    PARTY_CUST_ID          NUMBER    ,
    PARTY_CLIENT_ID        NUMBER    ,
    CUST_ACCOUNT_ID        NUMBER    ,
    CUSTOMER_SITE_USE_ID   NUMBER    ,
    TRANSACTION_ID         NUMBER    ,
    PAYMENT_SCHEDULE_ID    NUMBER    ,
    AGING_BUCKET_LINE_ID   NUMBER    ,
    CASE_ID                NUMBER    ,
    RESOURCE_ID            NUMBER    ,
    SCORE_VALUE            NUMBER    ,
    DUNN_YN                VARCHAR2(10) ,
    AUTOASSIGN_YN          VARCHAR2(10) ,
    STATUS                 VARCHAR2(30) ,
    CAMPAIGN_SCHED_ID      NUMBER
);

G_MISS_DELINQUENCY_REC        DELINQUENCY_REC_TYPE;

TYPE DELINQUENCY_TBL_TYPE  IS TABLE OF DELINQUENCY_REC_TYPE
                                INDEX BY BINARY_INTEGER;

  TYPE   t_del_id is TABLE of IEX_DELINQUENCIES.delinquency_id%TYPE;
  TYPE   t_del_status is TABLE of IEX_DELINQUENCIES.status%TYPE;
  TYPE   t_buf_status is TABLE of IEX_DELINQUENCIES.status%TYPE;

G_MISS_DELINQUENCY_TBL    DELINQUENCY_TBL_TYPE;
/*========================================================================+
|               Copyright (c) 2002 Oracle Corporation                     |
|                  Redwood Shores, California, USA                        |
|                       All rights reserved.                              |
+=========================================================================+
|                                                                         |
| FILENAME:                                                               |
|   iexpdels.pls                                                          |
| DESCRIPTION:                                                            |
|   Public API to create /update delinquencies                            |
| MODIFICATION HISTORY:                                                   |
+========================================================================*/

PROCEDURE CLEAR_DEL_BUFFERS(ERRBUF       OUT NOCOPY     VARCHAR2,
                            RETCODE      OUT NOCOPY     VARCHAR2);

PROCEDURE Close_Delinquencies(p_api_version         IN  NUMBER,
                              p_init_msg_list       IN  VARCHAR2,
                              p_payments_tbl        IN  IEX_PAYMENTS_BATCH_PUB.CL_INV_TBL_TYPE,
                              p_security_check      IN  VARCHAR2,
                              x_return_status       OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY NUMBER,
                              x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE MANAGE_DELINQUENCIES (ERRBUF       OUT NOCOPY VARCHAR2,
                                RETCODE      OUT NOCOPY VARCHAR2,
                                p_request_id IN  Number);

procedure SCORE_DELINQUENCIES (ERRBUF       OUT NOCOPY     VARCHAR2,
                               RETCODE      OUT NOCOPY     VARCHAR2,
                               p_request_id Number);



  /*------------------------------------------------------------------------

            11.5.7  Independent Delinquency Creation Process

  ------------------------------------------------------------------------ */
  PROCEDURE Create_Ind_Delinquency
       (p_api_version         IN  NUMBER    ,
            p_init_msg_list       IN  VARCHAR2,
            p_commit          IN  VARCHAR2,
            p_validation_level    IN  NUMBER   ,
            x_return_status       OUT NOCOPY VARCHAR2   ,
            x_msg_count           OUT NOCOPY NUMBER ,
            x_msg_data            OUT NOCOPY VARCHAR2   ,
        p_source_module   IN  VARCHAR2  ,
        p_party_id        IN  Number    ,
            p_object_code     IN  Varchar2  ,
            p_object_id_tbl       IN  IEX_UTILITIES.t_numbers,
            x_del_id_tbl      OUT NOCOPY IEX_UTILITIES.t_numbers);



  PROCEDURE SHOW_IN_UWQ(
        P_API_VERSION       IN      NUMBER,
        P_INIT_MSG_LIST     IN      VARCHAR2,
        P_COMMIT                IN      VARCHAR2,
        P_VALIDATION_LEVEL  IN      NUMBER,
        X_RETURN_STATUS     OUT NOCOPY     VARCHAR2,
        X_MSG_COUNT             OUT NOCOPY     NUMBER,
        X_MSG_DATA          OUT NOCOPY     VARCHAR2,
        P_DELINQUENCY_ID_TBL    IN DBMS_SQL.NUMBER_TABLE,
        P_UWQ_STATUS        IN  VARCHAR2,
        P_NO_DAYS           IN  NUMBER DEFAULT NULL);



  PROCEDURE CLOSE_DUNNINGS(ERRBUF       OUT NOCOPY VARCHAR2,
                           RETCODE      OUT NOCOPY VARCHAR2,
                           DUNNING_LEVEL Varchar2) ;

--
-- Begin - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
--
/*
|| Overview:  Clean up delinquency_buffers table this will use the batch size profile and do one request or all table
||
|| Parameter:  P_REQUEST is the request Id we need to delete, if it is -1 we delete the whole table
||
|| Source Tables:  None
||
|| Target Tables:  IEX_DEL_BUFFERS
||
|| Creation date:  01/25/05 3:29:PM
||
|| Major Modifications: when             who                what
||                      01/25/05         acaraujo            created
*/
PROCEDURE CLEAR_BUFFERS2(P_REQUEST    IN      NUMBER);

--
-- End - 01/24/2005 - Andre Araujo - This procedure uses a memory schema uses up all memory available for the session, changing it to chunks
--

END IEX_DELINQUENCY_PUB;


 

/
