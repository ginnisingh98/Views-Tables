--------------------------------------------------------
--  DDL for Package IGI_ITR_TIMEOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_TIMEOUT_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrxs.pls 120.4.12000000.1 2007/09/12 10:33:28 mbremkum ship $
--

  --
  --  Procedure find_services   /* Added  p_access_set_id to process service lines of all ledgers in a Data Access Set    */
  --

  PROCEDURE find_services(errbuf            OUT NOCOPY VARCHAR2,
                          retcode           OUT NOCOPY VARCHAR2,
                          p_set_of_books_id IN NUMBER,
   			   p_access_set_id IN NUMBER);
/* Code in "find_Services" has been moved to "find_ledger_services" */
 PROCEDURE find_ledger_services(errbuf            OUT NOCOPY VARCHAR2,
                          retcode           OUT NOCOPY VARCHAR2,
                          p_set_of_books_id IN NUMBER);

END IGI_ITR_TIMEOUT_PKG;

 

/
