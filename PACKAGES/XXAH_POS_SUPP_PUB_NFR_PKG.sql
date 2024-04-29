--------------------------------------------------------
--  DDL for Package XXAH_POS_SUPP_PUB_NFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_POS_SUPP_PUB_NFR_PKG" AUTHID CURRENT_USER AS

/****************************************************************************
*                           Identification
*                           ==============
* Name              : XXAH_POS_SUPP_PUB_NFR_PKG
* Description       : Package for NFR bulk suppliers pulish
****************************************************************************
*                           Change History
*                           ==============
*  Date                Version        Done by   Description
* 12-SEP-2019       1.0         Menaka          RFC132
****************************************************************************/
    g_curr_supp_publish_event_id NUMBER := 0;

    PROCEDURE publish_supp_event_job(ERRBUFF            OUT NOCOPY VARCHAR2,
                                     RETCODE            OUT NOCOPY NUMBER,
                                      p_party_id   IN NUMBER);

    FUNCTION get_curr_supp_pub_event_id RETURN NUMBER;

END XXAH_POS_SUPP_PUB_NFR_PKG;

/
