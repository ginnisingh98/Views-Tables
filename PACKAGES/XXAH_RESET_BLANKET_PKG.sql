--------------------------------------------------------
--  DDL for Package XXAH_RESET_BLANKET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_RESET_BLANKET_PKG" 
AS
PROCEDURE reset_blanket(
    errbuf                  IN OUT VARCHAR2
  , retcode                 IN OUT VARCHAR2
  , p_blanket_nr              IN VARCHAR2
  );
END XXAH_RESET_BLANKET_PKG;
 

/
