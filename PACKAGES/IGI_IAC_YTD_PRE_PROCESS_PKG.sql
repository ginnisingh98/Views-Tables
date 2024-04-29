--------------------------------------------------------
--  DDL for Package IGI_IAC_YTD_PRE_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_YTD_PRE_PROCESS_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiapys.pls 120.3.12000000.1 2007/08/01 16:16:27 npandya noship $
   PROCEDURE POPULATE_IAC_FA_DEPRN_DATA ( errbuf      OUT NOCOPY   VARCHAR2
                          		, retcode     OUT NOCOPY   NUMBER
                          		, p_book_type_code IN    VARCHAR2
                          		, p_calling_mode   IN    VARCHAR2);
END IGI_IAC_YTD_PRE_PROCESS_PKG;

 

/
