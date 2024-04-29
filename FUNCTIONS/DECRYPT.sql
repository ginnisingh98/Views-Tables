--------------------------------------------------------
--  DDL for Function DECRYPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."DECRYPT" ( p_key IN VARCHAR2, p_value IN VARCHAR2 )
RETURN VARCHAR2
AS LANGUAGE JAVA
   NAME 'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(
        java.lang.String
        ,java.lang.String)
      return java.lang.String'
;

 

/
