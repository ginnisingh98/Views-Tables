--------------------------------------------------------
--  DDL for Package Body IGI_IAC_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_GL_TRANSFER_PKG" as
-- $Header: igiiatgb.pls 120.10.12000000.2 2007/11/28 14:47:45 pakumare ship $
--
--  ********************************************************************
--   Procedure iac_transfer_to_gl
--  *********************************************************************
--

   /* IAC transfer to GL process
   **
   */


   PROCEDURE iac_transfer_to_gl(errbuf            OUT NOCOPY VARCHAR2,
                                retcode           OUT NOCOPY NUMBER,
                                p_book_type_code  IN  VARCHAR2,
                                p_period          IN  VARCHAR2,
                                p_import_journals IN  VARCHAR2,
                                p_summary         IN  VARCHAR2)

   IS

   BEGIN
         return;
   END iac_transfer_to_gl;

END IGI_IAC_GL_TRANSFER_PKG;

/
