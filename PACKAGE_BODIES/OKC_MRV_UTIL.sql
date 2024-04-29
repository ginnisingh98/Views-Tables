--------------------------------------------------------
--  DDL for Package Body OKC_MRV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_MRV_UTIL" 
/*$Header: OKCMRVUB.pls 120.0.12010000.6 2013/08/15 15:45:16 serukull noship $*/
AS

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
   g_fnd_app               CONSTANT VARCHAR2 (200) := okc_api.g_fnd_app;
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
   g_pkg_name              CONSTANT VARCHAR2 (200)
                                                  := 'OKC_K_ENTITY_LOCKS_GRP';
   g_app_name              CONSTANT VARCHAR2 (3)   := okc_api.g_app_name;
------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
   g_false                 CONSTANT VARCHAR2 (1)   := fnd_api.g_false;
   g_true                  CONSTANT VARCHAR2 (1)   := fnd_api.g_true;
   g_ret_sts_success       CONSTANT VARCHAR2 (1) := fnd_api.g_ret_sts_success;
   g_ret_sts_error         CONSTANT VARCHAR2 (1)   := fnd_api.g_ret_sts_error;
   g_ret_sts_unexp_error   CONSTANT VARCHAR2 (1)
                                             := fnd_api.g_ret_sts_unexp_error;
   g_unexpected_error      CONSTANT VARCHAR2 (200) := 'OKC_UNEXPECTED_ERROR';
   g_sqlerrm_token         CONSTANT VARCHAR2 (200) := 'ERROR_MESSAGE';
   g_sqlcode_token         CONSTANT VARCHAR2 (200) := 'ERROR_CODE';
   g_amend_code_deleted    CONSTANT VARCHAR2 (30)  := 'DELETED';
   g_amend_code_added      CONSTANT VARCHAR2 (30)  := 'ADDED';
   g_amend_code_updated    CONSTANT VARCHAR2 (30)  := 'UPDATED';
   g_stmt_level                     NUMBER         := fnd_log.level_statement;

/*==============================================================
   PRIVATE PROCEDURES
  =============================================================*/
FUNCTION get_uda_attr_desc_sql (
   p_pk1_value           NUMBER,
   p_pk2_value           NUMBER,
   p_data_type           VARCHAR2,
   p_appl_col_name       VARCHAR2,
   p_end_user_col_name   VARCHAR2,
   p_attr_group          VARCHAR2,
   p_attr_id             NUMBER
)
   RETURN VARCHAR2
IS
   -- p_application_id  number := 510;
   p_application_id    NUMBER;
   p_attr_group_type   VARCHAR2 (200)  := 'OKC_K_ART_VAR_EXT_ATTRS';
   p_object_name       VARCHAR2 (200)  := 'OKC_K_ART_VAR_EXT_B';
   p_pk1_column_name   VARCHAR2 (200)  := 'CAT_ID';
   p_pk2_column_name   VARCHAR2 (200)  := 'VARIABLE_CODE';
   p_pk3_column_name   VARCHAR2 (200)  := 'MAJOR_VERSION';

   /* This is changes as part of changes to MRV for adding class code and major version
   Since this particular function is always called in the context of OKC_K_ART_VAR_EXT_B,
   which before to this code change, particularly operates only on current version, it is
   safely assumed that this value can always be -99.
   */
   p_pk3_value           NUMBER := -99;

   l_sql               VARCHAR2 (1000);
BEGIN
   -- Get application ID from fnd_application
   SELECT application_id
     INTO p_application_id
     FROM fnd_application
    WHERE application_short_name = 'OKC';

   IF (p_data_type = 'C' OR p_data_type = 'A')
   THEN
      l_sql :=
            ' EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet ( '
         || p_application_id
         || ','
         || ' null,  '
         || p_appl_col_name
         || ', null , '''
         || p_end_user_col_name
         || ''','''
         || p_attr_group_type
         || ''','''
         || p_attr_group
         || ''','
         || p_attr_id
         || ','''
         || p_object_name
         || ''','''
         || p_pk1_column_name
         || ''','
         || p_pk1_value
         || ','''
         || p_pk2_column_name
         || ''','
         || p_pk2_value
         || ','''
         || p_pk3_column_name
         || ''','
         || p_pk3_value

         || ') as '
         || p_end_user_col_name
         || '_DESC';
   ELSIF p_data_type = 'N'
   THEN
      l_sql :=
            ' EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet ( '
         || p_application_id
         || ','
         || ' null, null, '
         || p_appl_col_name
         || ', '''
         || p_end_user_col_name
         || ''','''
         || p_attr_group_type
         || ''','''
         || p_attr_group
         || ''','
         || p_attr_id
         || ','''
         || p_object_name
         || ''','''
         || p_pk1_column_name
         || ''','
         || p_pk1_value
         || ','''
         || p_pk2_column_name
         || ''','
         || p_pk2_value
         || ','''
         || p_pk3_column_name
         || ''','
         || p_pk3_value
         || ') as '
         || p_end_user_col_name
         || '_DESC';
   ELSIF (p_data_type = 'X' OR p_data_type = 'Y')
   THEN
      l_sql :=
            ' EGO_USER_ATTRS_DATA_PVT.Get_Attr_Disp_Val_From_VSet ( '
         || p_application_id
         || ','
         || p_appl_col_name
         || ' , null, null, '''
         || p_end_user_col_name
         || ''','''
         || p_attr_group_type
         || ''','''
         || p_attr_group
         || ''','
         || p_attr_id
         || ','''
         || p_object_name
         || ''','''
         || p_pk1_column_name
         || ''','
         || p_pk1_value
         || ','''
         || p_pk2_column_name
         || ''','
         || p_pk2_value
         || ','''
         || p_pk3_column_name
         || ''','
         || p_pk3_value
         || ') as '
         || p_end_user_col_name
         || '_DESC ';
   END IF;

   RETURN (l_sql);
END get_uda_attr_desc_sql;

/*==============================================================
   PUBLIC PROCEDURES
  =============================================================*/

PROCEDURE update_k_art_var (
   p_cat_id          IN   NUMBER,
   p_variable_code   IN   VARCHAR2,
   p_blobdata        IN   BLOB,
   p_type            IN   VARCHAR2,
   p_commit   in varchar2 default fnd_api.g_false
)
IS
   l_clob   CLOB;
BEGIN
   l_clob := okc_word_download_upload.blob_to_clob (p_blobdata);

   IF p_type = 'XML'
   THEN
      --
      UPDATE okc_k_art_variables
         SET mr_variable_xml = l_clob
       WHERE variable_code = p_variable_code AND cat_id = p_cat_id;
   ELSIF p_type = 'HTML'
   THEN
      UPDATE okc_k_art_variables
         SET mr_variable_html = l_clob
       WHERE variable_code = p_variable_code AND cat_id = p_cat_id;

   END IF;
    IF FND_API.To_Boolean( p_commit ) then
   COMMIT;
END IF;
EXCEPTION
 WHEN OTHERS THEN
   RAISE;
END update_k_art_var;

FUNCTION get_k_art_var (
   p_cat_id          IN   NUMBER,
   p_variable_code   IN   VARCHAR2,
   p_type            IN   VARCHAR2
)
   RETURN BLOB
IS
   l_clob   CLOB;
BEGIN
   IF p_type = 'HTML'
   THEN
      SELECT mr_variable_html
        INTO l_clob
        FROM okc_k_art_variables
       WHERE variable_code = p_variable_code AND cat_id = p_cat_id;

      RETURN (okc_word_download_upload.clob_to_blob (l_clob));
   ELSIF p_type = 'XML'
   THEN
      SELECT mr_variable_xml
        INTO l_clob
        FROM okc_k_art_variables
       WHERE variable_code = p_variable_code AND cat_id = p_cat_id;

      RETURN (okc_word_download_upload.clob_to_blob (l_clob));
   END IF;
EXCEPTION
 WHEN OTHERS THEN
   RAISE;
END get_k_art_var;


  FUNCTION  get_uda_attr_xml(p_cat_id  IN NUMBER,
                             p_VARIABLE_CODE IN VARCHAR2,
                             p_Attr_group_id IN NUMBER
                             ) RETURN CLOB
  IS
   CURSOR C_ATTR_GRP IS
    SELECT AG.DESCRIPTIVE_FLEX_CONTEXT_CODE ATTR_GROUP,
           AG.ATTR_GROUP_ID ATTR_GROUP_ID,
           AG.DESCRIPTIVE_FLEXFIELD_NAME DESC_FLEXFLD_NAME,
           AG.MULTI_ROW MULTI_ROW
    FROM  EGO_FND_DSC_FLX_CTX_EXT AG
    WHERE 1=1
    AND AG.DESCRIPTIVE_FLEXFIELD_NAME = 'OKC_K_ART_VAR_EXT_ATTRS'
    AND AG.ATTR_GROUP_ID  =  p_Attr_group_id
    ;

  CURSOR C_ATTR_MD(P_ATTR_GROUP VARCHAR2, P_DESC_FLEXFLD_NAME VARCHAR2)  IS
    SELECT   EFDFCE.ATTR_ID,
    EFDFCE.APPLICATION_COLUMN_NAME,
    FCU.END_USER_COLUMN_NAME,
    fcu.flex_value_set_id,
    EFDFCE.data_type
    FROM
      EGO_FND_DF_COL_USGS_EXT EFDFCE,
      FND_DESCR_FLEX_COLUMN_USAGES FCU
    WHERE EFDFCE.DESCRIPTIVE_FLEXFIELD_NAME = P_DESC_FLEXFLD_NAME
    AND EFDFCE.DESCRIPTIVE_FLEX_CONTEXT_CODE  = P_ATTR_GROUP
    AND FCU.DESCRIPTIVE_FLEX_CONTEXT_CODE = EFDFCE.DESCRIPTIVE_FLEX_CONTEXT_CODE
    AND FCU.DESCRIPTIVE_FLEXFIELD_NAME = EFDFCE.DESCRIPTIVE_FLEXFIELD_NAME
    AND FCU.APPLICATION_COLUMN_NAME = EFDFCE.APPLICATION_COLUMN_NAME
    AND FCU.DISPLAY_FLAG <> 'H';

  L_SQL VARCHAR2(32767);
  L_OP VARCHAR2(32767);
  L_ATTR_GRP NUMBER;
  L_CTR NUMBER;
  L_O_CTR NUMBER;
  l_uda_xml XMLTYPE;

 BEGIN

  L_O_CTR := 0;
  FOR REC IN C_ATTR_GRP LOOP
    IF REC.MULTI_ROW = 'Y' THEN
      IF L_O_CTR > 0 THEN
        L_SQL := L_SQL || ',' || '(select XMLElement("' || REC.ATTR_GROUP
                 || '", XMLAgg(XMLForest(' ;
      ELSE
        L_SQL := '(select XMLElement (  "VAR_VALUE" , XMLAgg( XMLElement("' || REC.ATTR_GROUP || '", XMLForest(';
      END IF;
    ELSE
      IF L_O_CTR > 0 THEN
        L_SQL := L_SQL || ',' || '(select XMLElement("' || REC.ATTR_GROUP
                  || '", XMLForest(' ;
      ELSE
        L_SQL := '(select XMLElement (  "VAR_VALUE" , XMLElement("' || REC.ATTR_GROUP || '", XMLForest(';
      END IF;
    END IF;
    L_CTR := 0 ;
    FOR R IN C_ATTR_MD(REC.ATTR_GROUP, REC.DESC_FLEXFLD_NAME) LOOP
        IF L_CTR = 0 THEN
          L_SQL := L_SQL || R.APPLICATION_COLUMN_NAME || ' as ' || R.END_USER_COLUMN_NAME;
        ELSE
          L_SQL := L_SQL || ',' || R.APPLICATION_COLUMN_NAME || ' as ' || R.END_USER_COLUMN_NAME;
        END IF;
        if r.flex_value_set_id is not null then
          if (r.data_type = 'C' or r.data_type = 'A' ) then
              l_sql := l_sql || ',' || get_uda_attr_desc_sql(
                                     p_cat_id,
                                     p_VARIABLE_CODE,
                                     r.data_type,
                                     r.application_column_name,
                                     r.end_user_column_name,
                                     rec.attr_group,
                                     r.ATTR_ID );
          end if;
        end if;
        L_CTR := L_CTR + 1;
    END LOOP;
    IF REC.MULTI_ROW = 'Y' THEN
      L_SQL := L_SQL || '))))';
    ELSE
      L_SQL := L_SQL || ' )))';
    END IF;
    L_SQL := L_SQL || ' from OKC_K_ART_VAR_EXT_VL where CAT_ID = ' ||
             p_cat_Id || ' AND VARIABLE_CODE = ' || p_VARIABLE_CODE ||
             ' and MAJOR_VERSION = -99 AND attr_group_id = ' || REC.ATTR_GROUP_ID || ')' ;
    L_O_CTR := L_O_CTR + 1;
  END LOOP;

  l_op := 'select  XMLConcat(' || l_sql || ')  from dual';
  execute immediate l_op into l_uda_xml;

  RETURN (l_uda_xml.getClobVal());
EXCEPTION
 WHEN OTHERS THEN
   RAISE;
END get_uda_attr_xml;


PROCEDURE update_uda_attr_xml (
   p_init_msg_list   IN VARCHAR2 ,
   p_cat_id          IN   NUMBER,
   p_variable_code   IN   VARCHAR2,
   p_attr_group_id   IN   NUMBER,
   p_mode            IN VARCHAR2 DEFAULT 'NORMAL',
   p_locking_enabled IN VARCHAR2 DEFAULT 'N',
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS

l_api_name varchar2(240) := 'update_uda_attr_xml';
BEGIN

  x_return_status := G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT g_update_uda_attr_xml_GRP;

  -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;


  -- for Mode = AMEND mark articles as amended
    IF p_mode='AMEND' THEN

      OKC_K_ARTICLES_GRP.update_article(
                                   p_api_version       =>1,
                                   p_init_msg_list     => FND_API.G_FALSE,
                                   p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                   p_validate_commit   => FND_API.G_FALSE,
                                   p_validation_string => NULL,
                                   p_commit            => FND_API.G_FALSE,
                                   p_mode              => p_mode,
                                   x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data,
                                   p_id                => p_cat_id,
                                   p_amendment_description => NULL,
                                   p_print_text_yn            =>NULL,
                                   p_object_version_number    => NULL,
                                   p_lock_terms_yn             => p_locking_enabled
                                     );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

    END IF;  -- mode = AMEND



   UPDATE okc_k_art_variables
      SET mr_variable_xml =
                 get_uda_attr_xml (p_cat_id, p_variable_code, p_attr_group_id)
    WHERE cat_id = p_cat_id AND variable_code = p_variable_code;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.STRING (g_stmt_level,g_pkg_name,'300: Leaving update_uda_attr_xml: OKC_API.G_EXCEPTION_ERROR Exception');
    END IF;

    ROLLBACK TO g_update_uda_attr_xml_GRP;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.STRING (g_stmt_level,g_pkg_name,'400: Leaving update_uda_attr_xml: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
    END IF;


    ROLLBACK TO g_update_uda_attr_xml_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.STRING (g_stmt_level,g_pkg_name,'500: Leaving update_uda_attr_xml: '||sqlerrm);
    END IF;

    OKC_API.SET_MESSAGE(
           p_app_name        => G_APP_NAME,
           p_msg_name        => G_UNEXPECTED_ERROR,
           p_token1	        => G_SQLCODE_TOKEN,
           p_token1_value    => SQLCODE,
           p_token2          => G_SQLERRM_TOKEN,
           p_token2_value    => SQLERRM);

    ROLLBACK TO g_update_uda_attr_xml_GRP;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END update_uda_attr_xml;

PROCEDURE checkdochasmrv (
   docid       IN              NUMBER,
   doctype     IN              VARCHAR2,
   dochasmrv   OUT NOCOPY      VARCHAR2
)
IS
BEGIN
   SELECT 'Y'
     INTO dochasmrv
     FROM okc_k_articles_b kart
    WHERE document_type = doctype
      AND document_id = docid
      AND EXISTS (
             SELECT 'Y'
               FROM okc_k_art_variables kvar, okc_bus_variables_b var
              WHERE 1 = 1
                AND kvar.cat_id = kart.ID
                AND kvar.variable_code = var.variable_code
                AND var.mrv_flag = 'Y')
      AND ROWNUM = 1;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      dochasmrv := 'N';
   WHEN OTHERS
   THEN
      dochasmrv := 'N';
END checkdochasmrv;



  PROCEDURE MRV_PRE_PROCESS(DocID IN NUMBER, DocType IN VARCHAR2 )
  IS
  l_doc_xml CLOB;

CURSOR multiRow_vars IS
SELECT '<var name="'||t2."varName"||'" type="'||t2."vartype"||'" meaning="'||t2."varMeaning"||'"/>' mrVar,
        xmltype('<html>'||Dbms_Lob.SubStr(MR_VARIABLE_HTML,dbms_lob.getLength(MR_VARIABLE_HTML),Dbms_Lob.InStr(MR_VARIABLE_HTML,'<head>'))).extract('//style/text()').getClobVal() mrStyle,
        xmltype('<html>'||Dbms_Lob.SubStr(MR_VARIABLE_HTML,dbms_lob.getLength(MR_VARIABLE_HTML),Dbms_Lob.InStr(MR_VARIABLE_HTML,'<head>'))).extract('//body/*|text()').getClobVal() mrBody
FROM okc_mrv_t t,
   xmltable('//SectionsArticlesToPrintVORow' PASSING xmltype('<dummy>'||regexp_replace(OKC_WORD_DOWNLOAD_UPLOAD.blob_to_clob(blob_data),'&nbsp;',' ')||'</dummy>')
             COLUMNS "artVersionId" NUMBER PATH '//SectionsArticlesToPrintVORow/ArticleVersionId/text()',
             "catId" NUMBER PATH '//SectionsArticlesToPrintVORow/CatId/text()')  t1,
   okc_article_versions av,
   xmltable('//var' PASSING xmltype('<dummy>'||regexp_replace(av.article_text,'&nbsp;',' ')||'</dummy>')
     COLUMNS "varName" VARCHAR2(30) PATH '//var/@name',
              "vartype" VARCHAR2(1) PATH '//var/@type',
              "varMeaning" VARCHAR2(30) PATH '//var/@meaning'
     ) t2,
     okc_k_art_variables akv
WHERE 1=1
AND av.article_version_id = t1."artVersionId"
AND akv.variable_code = t2."varName"
AND akv.cat_id = t1."catId"
AND dbms_lob.getLength(akv.MR_VARIABLE_HTML) > 0;

l_mrStyle CLOB;
l_mrBody  CLOB;
l_mrHtml  CLOB;
  BEGIN
 SELECT OKC_WORD_DOWNLOAD_UPLOAD.blob_to_clob(blob_data) INTO l_doc_xml
  FROM okc_mrv_t;

FOR l_mr_vars IN multiRow_vars LOOP
     l_mrBody := l_mr_vars.mrBody;
    --replace style tags
     l_mrStyle := '<DUMMY>'||regexp_replace(regexp_replace(regexp_replace(l_mr_vars.mrStyle,'\.c','<row1><class1> c'),'{','</class1><styleAttr>'),'}','</styleAttr></row1>')||'</DUMMY>';
     DECLARE
         CURSOR allClasses IS
         SELECT 'class="'||Trim(cl."className")||'"' srcStr,
                'style="'||Trim(cl."styleAttr")||'"' trgStr
         FROM    xmltable('//row1' PASSING xmltype(l_mrStyle)
         COLUMNS "className" VARCHAR2(10) PATH '//row1/class1/text()',
         "styleAttr" VARCHAR2(2000) PATH '//row1/styleAttr/text()') cl;

     BEGIN
          FOR l_allClasses IN allClasses LOOP
              l_mrBody := regexp_replace(l_mrBody,l_allClasses.srcStr,l_allClasses.trgStr);
          END LOOP;

     END;
                     l_doc_xml :=  regexp_replace(l_doc_xml,l_mr_vars.mrVar,l_mrBody,1,1);
END LOOP;


  UPDATE  okc_mrv_t
  SET blob_output = OKC_WORD_DOWNLOAD_UPLOAD.clob_to_blob(l_doc_xml)
  WHERE doc_id=  DocID
  AND doc_type =DocType;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END MRV_PRE_PROCESS;

  -- This function is called from view okc_bus_variables_search_v.
FUNCTION getattributegroupdispname (attrgroupid IN VARCHAR2)
   RETURN VARCHAR2
IS
   l_agdispname   VARCHAR2 (240);
BEGIN

   SELECT attr.attr_group_disp_name
     INTO l_agdispname
     FROM ego_attr_groups_v attr, fnd_application fa
    WHERE attr.attr_group_type = 'OKC_K_ART_VAR_EXT_ATTRS'
      AND fa.application_short_name = 'OKC'
      AND attr.application_id = fa.application_id
      AND attr.attr_group_id = TO_NUMBER (attrgroupid);

   RETURN l_agdispname;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END getattributegroupdispname;

FUNCTION gettemplatename (mrv_tmpl_code IN VARCHAR2)
   RETURN VARCHAR2
IS
   l_tmplname   VARCHAR2 (240);
BEGIN
   IF mrv_tmpl_code IS NULL
   THEN
      RETURN NULL;
   ELSE
      SELECT template_name
        INTO l_tmplname
        FROM xdo_templates_vl xtv
       WHERE xtv.template_code = mrv_tmpl_code AND xtv.ds_app_short_name(+) =
                                                                         'OKC';

      RETURN l_tmplname;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END gettemplatename;

PROCEDURE copy_variable_uda_data (
   p_from_cat_id          IN   NUMBER,
   p_from_variable_code   IN   VARCHAR2,
   p_to_cat_id            IN   NUMBER,
   p_to_variable_code     IN   VARCHAR2,
   x_return_status        OUT  NOCOPY VARCHAR2,
   x_msg_count            OUT  NOCOPY NUMBER,
   x_msg_data             OUT  NOCOPY VARCHAR2
)
IS
   l_api_name                    VARCHAR2 (30)    := 'copy_variable_uda_data';
   l_progress                    VARCHAR2 (3)                        := '000';
   l_object_id                   fnd_objects.object_id%TYPE;
   l_attr_group_type             VARCHAR2 (300);

   l_dtlevel_col_value_pairs     ego_col_name_value_pair_array;
   l_main_data_level_id          ego_data_level_b.data_level_id%TYPE;
   x_external_attr_value_pairs   ego_col_name_value_pair_table;
   x_errorcode                   NUMBER;
   from_pk_col_value_pairs       ego_col_name_value_pair_array;
   to_pk_col_value_pairs         ego_col_name_value_pair_array;
   x_pk1_col_name                VARCHAR2 (100);
   x_pk1_value                   NUMBER;
   x_pk2_col_name                VARCHAR2 (100);
   x_pk2_value                   NUMBER;


BEGIN
   x_pk1_col_name := 'CAT_ID';
   x_pk2_col_name := 'VARIABLE_CODE';
   x_pk1_value := p_from_cat_id;
   x_pk2_value := p_from_variable_code;
   from_pk_col_value_pairs :=
      ego_col_name_value_pair_array
                               (ego_col_name_value_pair_obj ('CAT_ID',
                                                             x_pk1_value
                                                            ),
                                ego_col_name_value_pair_obj ('VARIABLE_CODE',
                                                             x_pk2_value
                                                            ),
                                ego_col_name_value_pair_obj ('MAJOR_VERSION',
                                                             -99
                                                            )
                               );
   to_pk_col_value_pairs :=
      ego_col_name_value_pair_array
                              (ego_col_name_value_pair_obj ('CAT_ID',
                                                            p_to_cat_id
                                                           ),
                               ego_col_name_value_pair_obj ('VARIABLE_CODE',
                                                            p_to_variable_code
                                                           ),
                                ego_col_name_value_pair_obj ('MAJOR_VERSION',
                                                             -99
                                                            )
                              );

   BEGIN
      SELECT object_id
        INTO l_object_id
        FROM fnd_objects
       WHERE obj_name = 'OKC_K_ART_VARIABLES';

      SELECT data_level_id
        INTO l_main_data_level_id
        FROM ego_data_level_b
       WHERE attr_group_type = 'OKC_K_ART_VAR_EXT_ATTRS'
         AND DATA_LEVEL_NAME = 'CLAUSE_VARIABLES'
                                                        --  AND DATA_LEVEL_NAME LIKE '%CLAUSE%'
      ;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;


  /* l_dtlevel_col_value_pairs :=
      ego_col_name_value_pair_array (ego_col_name_value_pair_obj ('PK1_VALUE',
                                                                  NULL
                                                                 )
                                    );         */

   ego_user_attrs_data_pvt.copy_user_attrs_data
                  (p_api_version                      => 1.0,
                   p_application_id                   => 510,
                   p_object_id                        => l_object_id,
                   p_object_name                      => 'OKC_K_ART_VARIABLES',
                   p_old_pk_col_value_pairs           => from_pk_col_value_pairs,
                   p_old_data_level_id                => l_main_data_level_id,
                   --p_old_dtlevel_col_value_pairs      => l_dtlevel_col_value_pairs,
                   p_new_pk_col_value_pairs           => to_pk_col_value_pairs,
                   p_new_data_level_id                => l_main_data_level_id,
                   --p_new_dtlevel_col_value_pairs      => l_dtlevel_col_value_pairs,
                   p_commit                           => fnd_api.g_false,
                   x_return_status                    => x_return_status,
                   x_errorcode                        => x_errorcode,
                   x_msg_count                        => x_msg_count,
                   x_msg_data                         => x_msg_data
                  );

EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END copy_variable_uda_data;

PROCEDURE update_uda_attr_xml (
      p_cat_id          IN   NUMBER,
      p_variable_code   IN   VARCHAR2,
      p_attr_group_id   IN   NUMBER
   )
IS

BEGIN
   UPDATE okc_k_art_variables
      SET mr_variable_xml =
                 get_uda_attr_xml (p_cat_id, p_variable_code, p_attr_group_id)
    WHERE cat_id = p_cat_id AND variable_code = p_variable_code;
EXCEPTION
 WHEN OTHERS THEN
   RAISE;


END update_uda_attr_xml;

PROCEDURE Create_Association (
                p_api_version                   IN   NUMBER  := 1
              ,p_object_id                     IN   NUMBER DEFAULT NULL
              ,p_classification_code           IN   VARCHAR2
              ,p_data_level                    IN   VARCHAR2 DEFAULT NULL
              ,p_attr_group_id                 IN   NUMBER
              ,p_enabled_flag                  IN   VARCHAR2 DEFAULT 'Y'
              ,p_view_privilege_id             IN   NUMBER  DEFAULT NULL    --ignored for now
              ,p_edit_privilege_id             IN   NUMBER  DEFAULT NULL    --ignored for now
              ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
              ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
              ,x_association_id                OUT NOCOPY NUMBER
              ,x_return_status                 OUT NOCOPY VARCHAR2
              ,x_errorcode                     OUT NOCOPY NUMBER
              ,x_msg_count                     OUT NOCOPY NUMBER
              ,x_msg_data                      OUT NOCOPY VARCHAR2
        ) IS
        l_data_level varchar2(10);
        l_object_id NUMBER;
        l_api_name VARCHAR2(100) := 'okc_mrv_util.Create_Association' ;
BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, l_api_name,'100: ProcedureStarted');
  END IF;

  l_object_id := p_object_id;
  IF l_object_id IS NULL THEN
    SELECT object_id
      INTO l_object_id
      FROM fnd_objects
      WHERE OBJ_NAME = 'OKC_K_ART_VARIABLES'    ;
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, l_api_name,'110: object_id'||l_object_id);
  END IF;

  l_data_level :=  p_data_level;
  IF l_data_level IS NULL THEN
    SELECT data_level_id
      INTO l_data_level
      FROM ego_data_level_b
      WHERE attr_group_type='OKC_K_ART_VAR_EXT_ATTRS'
        AND data_level_name= 'CLAUSE_VARIABLES';
  END IF;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, l_api_name,'120: datalevel id'||l_data_level);
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, l_api_name,'130: calling EGO_EXT_FWK_PUB.Create_Association');
  END IF;

 EGO_EXT_FWK_PUB.Create_Association (
	  p_api_version         =>     p_api_version,
	  p_object_id           =>     l_object_id ,
	  p_classification_code =>     p_classification_code,
	  p_data_level          =>     l_data_level ,
	  p_attr_group_id       =>     p_attr_group_id,
	  p_enabled_flag        =>     p_enabled_flag,
	  p_view_privilege_id   =>     NULL ,
	  p_edit_privilege_id   =>     NULL ,
	  p_init_msg_list       =>     p_init_msg_list,
	  p_commit              =>     p_commit,
	  x_association_id      =>     x_association_id,
	  x_return_status       =>     x_return_status ,
	  x_errorcode           =>     x_errorcode ,
	  x_msg_count           =>     x_msg_count,
	  x_msg_data            =>     x_msg_data);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, l_api_name,'140: EGO_EXT_FWK_PUB.Create_Association completed in: '|| x_return_status);
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, l_api_name,'150: Procedure completed');
  END IF;

END  Create_Association;

END  okc_mrv_util;

/
