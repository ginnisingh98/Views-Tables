--------------------------------------------------------
--  DDL for Package XXAH_PROFORMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_PROFORMA" IS
  PROCEDURE Terminate_proforma(errbuf VARCHAR2
                              ,retcode NUMBER
                              ,p_number_of_days NUMBER);
END xxah_proforma;

/
