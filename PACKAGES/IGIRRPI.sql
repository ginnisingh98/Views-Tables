--------------------------------------------------------
--  DDL for Package IGIRRPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRRPI" AUTHID CURRENT_USER AS
-- $Header: igirrpis.pls 120.3.12000000.1 2007/08/31 05:53:24 mbremkum ship $
   PROCEDURE AUTO_INVOICE ( errbuf      OUT NOCOPY   VARCHAR2
                          , retcode     OUT NOCOPY   NUMBER
                          , p_run_date1 IN    VARCHAR2
                          , p_set_of_books_id NUMBER
                          , p_batch_source_id NUMBER
                          , p_debug_mode IN VARCHAR2 DEFAULT 'N'
                          );
END IGIRRPI;

 

/
