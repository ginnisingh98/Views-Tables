--------------------------------------------------------
--  DDL for Package XXAH_POS_SUPP_PUB_JOB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_POS_SUPP_PUB_JOB_PKG" AUTHID CURRENT_USER AS

/****************************************************************************
*                           Identification
*                           ==============
* Name              : XXAH_POS_SUPP_PUB_JOB_PKG
* Description       : Package for RFC115 Problemen
                      ,address, salary
****************************************************************************
*                           Change History
*                           ==============
*  Date                Version        Done by
* 12-APR-2017       1.0         Sunil Thamke RFC115 Problemen
****************************************************************************/
    g_curr_supp_publish_event_id NUMBER := 0;

    PROCEDURE publish_supp_event_job(ERRBUFF            OUT NOCOPY VARCHAR2,
                                     RETCODE            OUT NOCOPY NUMBER,
                                      p_party_id   IN NUMBER);

    FUNCTION get_curr_supp_pub_event_id RETURN NUMBER;

END XXAH_POS_SUPP_PUB_JOB_PKG;

/
