--------------------------------------------------------
--  DDL for Package XXAH_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_TERMS_PKG" AS

  FUNCTION pagebreak_needed(
     p_article_id          IN  NUMBER
    ,p_article_version_id  IN  NUMBER
  ) RETURN VARCHAR2;

END xxah_terms_pkg;
 

/
