--------------------------------------------------------
--  DDL for Package Body ARTA_MISC_CALLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARTA_MISC_CALLS" AS
/* $Header: ARTAESEB.pls 120.0 2005/07/28 18:36:39 mantani noship $ */
FUNCTION cpgr_check_pending_updates (
                cust_num VARCHAR2)
        RETURN NUMBER IS
/* $Header: ARTAESEB.pls 120.0 2005/07/28 18:36:39 mantani noship $ */
        BEGIN
                RETURN (0);
END cpgr_check_pending_updates;

FUNCTION cpgr_cred_synch_func (
                                cust_num VARCHAR2,
                                orgid NUMBER,
                                sobi NUMBER)
                        RETURN NUMBER IS
/* $Header: ARTAESEB.pls 120.0 2005/07/28 18:36:39 mantani noship $ */
        BEGIN
             RETURN 0;
        END cpgr_cred_synch_func;

PROCEDURE get_install(p_installid OUT NOCOPY VARCHAR2) IS
/* $Header: ARTAESEB.pls 120.0 2005/07/28 18:36:39 mantani noship $ */
BEGIN
        p_installid := '0';
END get_install;

FUNCTION  get_compno(
               Set_of_books_id NUMBER,
               in_stallid VARCHAR2)
             RETURN NUMBER IS
/* $Header: ARTAESEB.pls 120.0 2005/07/28 18:36:39 mantani noship $ */
   BEGIN
      RETURN (0);
END get_compno;


END ARTA_MISC_CALLS;

/
