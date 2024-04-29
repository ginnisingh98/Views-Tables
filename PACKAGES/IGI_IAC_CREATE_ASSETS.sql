--------------------------------------------------------
--  DDL for Package IGI_IAC_CREATE_ASSETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_CREATE_ASSETS" AUTHID CURRENT_USER AS
-- $Header: igiiacas.pls 120.4.12000000.1 2007/08/01 16:13:21 npandya ship $

PROCEDURE log(p_mesg VARCHAR2);
/*
-- Process Create Assets
*/

PROCEDURE get_assets
                   ( errbuf              OUT NOCOPY VARCHAR2
                   , retcode             OUT NOCOPY NUMBER
                   , p_revaluation_id    IN NUMBER
                   , p_book_type_code    IN VARCHAR2
                   , p_revaluation_date  IN DATE
                    ) ;

END;

 

/
