--------------------------------------------------------
--  DDL for Package Body XXAH_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_TERMS_PKG" AS

  FUNCTION pagebreak_needed(
     p_article_id          IN  NUMBER
    ,p_article_version_id  IN  NUMBER
  ) RETURN VARCHAR2
  IS
    CURSOR c_oav
    ( b_article_id         okc_article_versions.article_id%TYPE
    , b_article_version_id okc_article_versions.article_version_id%TYPE
    ) IS
      SELECT NVL(oavd.pagebreak_needed,'N')
      FROM   okc_article_versions oav
      ,      okc_article_versions_dfv oavd
      WHERE  oavd.row_id            = oav.ROWID
      AND    oav.article_id         = b_article_id
      AND    oav.article_version_id = b_article_version_id
      ;
    l_pagebreak_needed okc_article_versions_dfv.pagebreak_needed%TYPE := 'N';
  BEGIN
    IF  p_article_id         IS NOT NULL
    AND p_article_version_id IS NOT NULL
    THEN
      OPEN  c_oav ( p_article_id, p_article_version_id );
      FETCH c_oav INTO l_pagebreak_needed;
      CLOSE c_oav;
    END IF;

    RETURN (NVL(l_pagebreak_needed,'N'));
  EXCEPTION
    WHEN OTHERS THEN
      IF c_oav%ISOPEN THEN CLOSE c_oav; END IF;
      RETURN ('N');
  END pagebreak_needed;

END xxah_terms_pkg;

/
