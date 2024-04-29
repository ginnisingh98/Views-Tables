--------------------------------------------------------
--  DDL for Package IGI_CIS2007_CERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_CERT_PKG" AUTHID CURRENT_USER AS
-- $Header: igipuprs.pls 120.0.12000000.1 2007/07/13 07:05:59 vensubra noship $
   Procedure Update_Rates(
      errbuf       OUT NOCOPY VARCHAR2,
      retcode      OUT NOCOPY NUMBER,
      p_tax_id     IN NUMBER,
      p_group_id   IN NUMBER );
END IGI_CIS2007_CERT_PKG;

 

/
