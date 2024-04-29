--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_PUB_JOB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_PUB_JOB_PKG" AUTHID CURRENT_USER AS
   /* $Header: POSSPPBJS.pls 120.0.12010000.2 2010/02/08 14:18:59 ntungare noship $ */

    g_curr_supp_publish_event_id NUMBER := 0;

    PROCEDURE publish_supp_event_job(ERRBUFF			OUT NOCOPY VARCHAR2,
                                     RETCODE			OUT NOCOPY NUMBER,
                                     p_from_date IN VARCHAR2,
                                     p_to_date IN VARCHAR2,
                                     p_hours       IN NUMBER);

    FUNCTION get_curr_supp_pub_event_id RETURN NUMBER;

END pos_supplier_pub_job_pkg;

/
