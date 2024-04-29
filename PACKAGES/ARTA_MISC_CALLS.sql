--------------------------------------------------------
--  DDL for Package ARTA_MISC_CALLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARTA_MISC_CALLS" AUTHID CURRENT_USER AS
/*$Header: ARTAESES.pls 120.0 2005/07/28 18:36:14 mantani noship $ */

 FUNCTION cpgr_check_pending_updates (
                cust_num VARCHAR2)
        RETURN NUMBER;

 FUNCTION cpgr_cred_synch_func (
                                cust_num VARCHAR2,
                                orgid NUMBER,
                                sobi NUMBER)
                        RETURN NUMBER;

PROCEDURE get_install(p_installid OUT NOCOPY VARCHAR2);

 FUNCTION  get_compno(
               Set_of_books_id NUMBER,
               in_stallid VARCHAR2)
             RETURN NUMBER;
END ARTA_MISC_CALLS;

 

/
