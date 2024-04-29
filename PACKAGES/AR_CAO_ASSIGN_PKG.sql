--------------------------------------------------------
--  DDL for Package AR_CAO_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CAO_ASSIGN_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCAOAS.pls 120.0.12010000.2 2008/11/21 15:36:16 rmanikan noship $*/

PROCEDURE assign_work_items( errbuf                OUT NOCOPY VARCHAR2,
                             retcode               OUT NOCOPY NUMBER,
                             p_operating_unit      IN NUMBER,
                             p_receipt_date_from   IN VARCHAR2,
                             p_receipt_date_to     IN VARCHAR2,
                             p_cust_prof_class     IN NUMBER,
                             p_max_num_workers     IN NUMBER,
                             p_worker_no           IN NUMBER);

FUNCTION check_access(user_id IN NUMBER,   valid_flag IN VARCHAR2) RETURN NUMBER;

END;

/
