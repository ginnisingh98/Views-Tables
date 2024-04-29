--------------------------------------------------------
--  DDL for Package RA_CUSTOMER_TEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RA_CUSTOMER_TEXT_PKG" AUTHID CURRENT_USER as
/*$Header: ARXCUTXS.pls 115.7 2002/12/04 17:09:05 simandal ship $*/

PROCEDURE update_text_addr (
                        Errbuf                  OUT NOCOPY VARCHAR2,
                        Retcode                 OUT NOCOPY VARCHAR2,
                        p_idx_cust_contacts     IN      VARCHAR2);

Procedure site_info2 (
   rid          IN              ROWID,
   site_lob     IN OUT NOCOPY   CLOB);

Procedure site_info (
   rid          IN              ROWID,
   site_char    IN OUT NOCOPY   VARCHAR2);
END RA_CUSTOMER_TEXT_PKG;

 

/

  GRANT EXECUTE ON "APPS"."RA_CUSTOMER_TEXT_PKG" TO "CTXSYS";
