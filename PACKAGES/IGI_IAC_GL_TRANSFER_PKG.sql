--------------------------------------------------------
--  DDL for Package IGI_IAC_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_GL_TRANSFER_PKG" AUTHID CURRENT_USER as
-- $Header: igiiatgs.pls 120.5.12000000.1 2007/08/01 16:19:25 npandya ship $
--

  --
  --  Procedure iac_transfer_to_gl
  --

  PROCEDURE iac_transfer_to_gl(errbuf            OUT NOCOPY VARCHAR2,
                               retcode           OUT NOCOPY NUMBER,
                               p_book_type_code  IN  VARCHAR2,
                               p_period          IN  VARCHAR2,
                               p_import_journals IN  VARCHAR2,
                               p_summary         IN  VARCHAR2);



END IGI_IAC_GL_TRANSFER_PKG;

 

/
