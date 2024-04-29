--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_DISP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_DISP_PVT" AS
/* $Header: OKCVTERMSDISPB.pls 120.0.12010000.2 2009/09/22 09:06:57 harchand ship $ */
  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  G_GLOBAL_TEMP_LOADED         VARCHAR2(1) := 'N';

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNABLE_TO_RESERVE_REC      CONSTANT VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_DELETED;
  G_RECORD_CHANGED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_DISP_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

--==================== INTERNAL PROCEDURES ============================

FUNCTION get_terms_display_order
                             ( p_terms_id  IN NUMBER,
                              p_terms_type IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_display_order VARCHAR2(2000);
  CURSOR l_get_display_order IS
    SELECT terms_display_order
    FROM okc_terms_artsec_disp_temp
    WHERE terms_id = p_terms_id
    AND terms_type = p_terms_type
    AND processed_flag = 'Y';

BEGIN

  OPEN l_get_display_order;
  FETCH l_get_display_order INTO l_display_order;
  CLOSE l_get_display_order;

  RETURN l_display_order;

END;

PROCEDURE populate_temp_tab
(
  p_document_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_run_id IN VARCHAR2) IS
  pragma AUTONOMOUS_TRANSACTION;
  l_max_level NUMBER := 1;
  l_display_order NUMBER := 1;
  l_parent_disp_order VARCHAR2(2000) := '0';
  l_old_parent_id NUMBER := 0;


  CURSOR l_lvl1_scn_csr IS
     SELECT document_id,
             document_type,
             terms_type,
             terms_id,
             parent_id,
             terms_display_sequence,
             terms_display_level,
             LPAD(ROWNUM,5,'0') disp_order,
             'Y',
             runid
     FROM    okc_terms_artsec_disp_temp
    WHERE  document_id = p_document_id
    AND    document_type = p_document_type
    AND    processed_flag = 'N'
    AND    parent_id IS null
    AND    terms_type = 'SECTION'
    ORDER BY terms_display_sequence ;


  CURSOR l_terms_csr
               ( lc_document_id IN NUMBER,
                 lc_document_type IN VARCHAR2,
                 lc_level IN NUMBER) IS
    SELECT document_id,
           document_type,
           terms_type,
           terms_id,
           parent_id,
           terms_display_level,
           terms_display_sequence,
           runid
   FROM    okc_terms_artsec_disp_temp t
    WHERE  document_id = lc_document_id
    AND    document_type = lc_document_type
    AND    processed_flag = 'N'
    AND    exists (SELECT 1
                   FROM okc_terms_artsec_disp_temp t1
                   WHERE t1.terms_type = 'SECTION'
                   AND t1.terms_id = t.parent_id
                   AND t1.document_id = lc_document_id
                   AND t1.document_type = lc_document_type
                   AND t1.terms_display_level = lc_level)
    ORDER BY parent_id,terms_display_sequence;

   CURSOR l_max_levels_csr (
                       lc_document_id IN NUMBER,
                       lc_document_type IN VARCHAR2) IS
     SELECT NVL(MAX(terms_display_level),0)
     FROM okc_terms_artsec_disp_temp
     WHERE  document_id = lc_document_id
     AND    document_type = lc_document_type
     AND    processed_flag = 'N';

BEGIN

  DELETE FROM okc_terms_artsec_disp_temp
  WHERE document_id = p_document_id
  AND document_type = p_document_type;

  INSERT INTO okc_terms_artsec_disp_temp
  (document_id,
   document_type,
   terms_type,
   terms_id,
   parent_id,
   terms_display_sequence,
   terms_display_level,
   terms_display_order,
   processed_flag,
   runid
  )
  (select document_id,
          document_type,
          'SECTION',
          id,
          scn_id,
          section_sequence,
          level,
          '',
          'N',
          p_run_id
   from okc_sections_b
   where document_id = p_document_id
   and document_type = p_document_type
   connect by prior id = scn_id
   start with scn_id is null
   and document_id = p_document_id
   and document_type = p_document_type);

  INSERT INTO okc_terms_artsec_disp_temp
  (document_id,
   document_type,
   terms_type,
   terms_id,
   parent_id,
   terms_display_sequence,
   terms_display_level,
   terms_display_order,
   processed_flag,
   runid
  )
  (select document_id,
          document_type,
          'ARTICLE',
          id,
          scn_id,
          display_sequence,
          null,
          '',
          'N',
          p_run_id
   from okc_k_articles_b
   where document_id = p_document_id
   and document_type = p_document_type);

    OPEN l_max_levels_csr(p_document_id,
                        p_document_type);
    FETCH l_max_levels_csr INTO l_max_level;
    CLOSE l_max_levels_csr;

    /***************************************
     insert into okc_terms_artsec_disp_temp
     (document_id,
      document_type,
      terms_type,
      terms_id,
      parent_id,
      terms_display_sequence,
      terms_display_level,
      terms_display_order,
      processed_flag
     )
     SELECT document_id,
             document_type,
             terms_type,
             terms_id,
             parent_id,
             terms_display_sequence,
             terms_display_level,
             LPAD(ROWNUM,5,'0'),
             'Y'
     FROM    okc_terms_artsec_disp_temp
    WHERE  document_id = p_document_id
    AND    document_type = p_document_type
    AND    processed_flag = 'N'
    AND    parent_id IS null
    AND    terms_type = 'SECTION'
    ORDER BY terms_display_sequence ;
    **********************************/

    l_display_order := 1;

    FOR rec in l_lvl1_scn_csr LOOP
     insert into okc_terms_artsec_disp_temp
     (document_id,
      document_type,
      terms_type,
      terms_id,
      parent_id,
      terms_display_sequence,
      terms_display_level,
      terms_display_order,
      processed_flag,
      runid
     )
     VALUES
     ( rec.document_id,
             rec.document_type,
             rec.terms_type,
             rec.terms_id,
             rec.parent_id,
             rec.terms_display_sequence,
             rec.terms_display_level,
             LPAD(l_display_order,5,'0'),
             'Y',
             rec.runid);
    l_display_order := l_display_order + 1;


    END LOOP;

    l_display_order := 1;


    FOR i in 1..l_max_level LOOP

      FOR rec in l_terms_csr(p_document_id,p_document_type,i) LOOP

        l_display_order := l_display_order + 1;


        IF l_old_parent_id <> rec.parent_id THEN
          l_display_order := 1;
          l_parent_disp_order :=
                       get_terms_display_order
                             ( p_terms_type => 'SECTION',
                               p_terms_id => rec.parent_id);
          l_old_parent_id := rec.parent_id;
        END IF;

             insert into okc_terms_artsec_disp_temp
             ( document_id,
               document_type,
               terms_type,
               terms_id,
               parent_id,
               terms_display_sequence,
               terms_display_level,
               terms_display_order,
               processed_flag,
               runid
              )
             VALUES
             ( rec.document_id,
               rec.document_type,
               rec.terms_type,
               rec.terms_id,
               rec.parent_id,
               rec.terms_display_sequence,
               rec.terms_display_level,
               l_parent_disp_order||'.'||LPAD(l_display_order,5,'0'),
               'Y',
               rec.runid
              );


      END LOOP;


    END LOOP;
    DELETE FROM okc_terms_artsec_disp_temp
    WHERE document_id = p_document_id
    AND document_type = p_document_type
    AND processed_flag = 'N';
  commit;
END;

FUNCTION get_terms_display_order
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

    p_document_id       IN  NUMBER,
    p_document_type     IN  VARCHAR2,
    p_terms_type        IN  VARCHAR2,
    p_terms_id          IN  NUMBER,
    p_run_id            IN  VARCHAR2
) RETURN VARCHAR2 IS
  l_terms_display_order VARCHAR2(2000);
  l_global_temp_loaded VARCHAR2(1) := 'N';
  CURSOR l_global_temp_csr IS
    SELECT '1'
    FROM OKC_TERMS_ARTSEC_DISP_TEMP
    WHERE document_type = p_document_type
    AND document_id = p_document_id
    AND runid = p_run_id;
BEGIN
  /****
  IF G_GLOBAL_TEMP_LOADED = 'N' THEN
    populate_temp_tab(p_document_id => p_document_id,
                      p_document_type => p_document_type);
    G_GLOBAL_TEMP_LOADED := 'Y';
  END IF;
  *****/

  OPEN l_global_temp_csr;
  FETCH l_global_temp_csr INTO l_global_temp_loaded;
  IF l_global_temp_csr%NOTFOUND THEN
            populate_temp_tab(p_document_id => p_document_id,
                      p_document_type => p_document_type,
                      p_run_id => p_run_id);
  END IF;
  CLOSE l_global_temp_csr;

  l_terms_display_order := get_terms_display_order
                             ( p_terms_type => p_terms_type,
                               p_terms_id => p_terms_id);

  RETURN l_terms_display_order;
END;


FUNCTION get_terms_structure_level
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

    p_document_id       IN  NUMBER,
    p_document_type     IN  VARCHAR2,
    p_terms_type        IN  VARCHAR2,
    p_terms_id          IN  NUMBER,
    p_run_id            IN  VARCHAR2
) RETURN NUMBER IS
  l_terms_display_order VARCHAR2(2000) := 0;
  l_global_temp_loaded VARCHAR2(1) := 'N';
  l_terms_structure_level number := 0;
  CURSOR l_global_temp_csr IS
    SELECT '1'
    FROM OKC_TERMS_ARTSEC_DISP_TEMP
    WHERE document_type = p_document_type
    AND document_id = p_document_id;
BEGIN
  /****
  IF G_GLOBAL_TEMP_LOADED = 'N' THEN
    populate_temp_tab(p_document_id => p_document_id,
                      p_document_type => p_document_type);
    G_GLOBAL_TEMP_LOADED := 'Y';
  END IF;
  *****/

  l_terms_display_order := get_terms_display_order(
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,

    p_document_id  => p_document_id,
    p_document_type   => p_document_type,
    p_terms_type  => p_terms_type,
    p_terms_id    => p_terms_id,
    p_run_id      => p_run_id
                              );

  IF LENGTH(l_terms_display_order) <= 5 THEN
    l_terms_structure_level := 1;
  ELSE
    l_terms_structure_level :=  (((length(l_terms_display_order)-5)/6)+1);
  END IF;


  RETURN l_terms_structure_level;
END;

END OKC_TERMS_DISP_PVT;

/
