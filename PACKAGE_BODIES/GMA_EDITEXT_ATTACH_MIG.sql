--------------------------------------------------------
--  DDL for Package Body GMA_EDITEXT_ATTACH_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_EDITEXT_ATTACH_MIG" AS
/* $Header: GMAEATHB.pls 120.3 2006/11/03 21:28:20 txdaniel noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_PKG_NAME     CONSTANT VARCHAR2(30) :='GMA_EDITEXT_ATTACH_MIG';
g_module_prefix  CONSTANT VARCHAR2(40) := g_pkg_name || '.';

-- All top API's should call Attachment_Main Procedure
PROCEDURE Attachment_Main(
    p_text_code              IN   VARCHAR2  default null,
    p_text_table_tl          IN   VARCHAR2  default null,
    p_sy_para_cds_table_name IN   VARCHAR2  default null,
    p_attach_form_short_name IN   VARCHAR2  default null,
    p_attach_table_name      IN   VARCHAR2  default null,
    p_attach_pk1_value       IN   VARCHAR2  default null,
    p_attach_pk2_value       IN   VARCHAR2  default null,
    p_attach_pk3_value       IN   VARCHAR2  default null,
    p_attach_pk4_value       IN   VARCHAR2  default null,
    p_attach_pk5_value       IN   VARCHAR2  default null
    )
IS

    l_api_name         CONSTANT VARCHAR2(30)   := 'Attachment_Main' ;
    l_api_version      CONSTANT NUMBER         := 1.0 ;
    l_progress         VARCHAR2(3) := '000';
    l_long_message     VARCHAR2(4000);

   CURSOR Cur_Paragraph(x_table_name varchar2)
   IS
                   SELECT
                         B.TABLE_NAME,
                         B.PARAGRAPH_CODE,
                         B.SUB_PARACODE,
                         B.PARA_DESC
                    FROM SY_PARA_CDS_VL B
                    WHERE B.TABLE_NAME=x_table_name;

   CURSOR Cur_Paragraph_Lang(x_table_name varchar2,
                             x_paragraph_code VARCHAR2,
                             x_sub_paracode VARCHAR2)
   IS
                   SELECT
                         T.LANG_CODE,
                         T.PARA_DESC,
                         T.SOURCE_LANG,
                         T.LANGUAGE
                    FROM SY_PARA_CDS_TL T, FND_LANGUAGES L
                    WHERE t.TABLE_NAME=x_table_name
                    AND t.paragraph_code = x_paragraph_code
                    AND t.sub_paracode = x_sub_paracode
                    AND t.language = l.language_code
                    ORDER BY installed_flag;

   l_attachment_function_id  fnd_attachment_functions.attachment_function_id%type;
   l_attached_document_id    fnd_documents.document_id%TYPE;
   l_document_id             fnd_documents.document_id%TYPE;
   l_media_id                NUMBER;
   l_Cur_Paragraph           Cur_Paragraph%rowtype;
   l_Document_exist          varchar2(10);
   l_file_name               VARCHAR2(240);
   l_para_count              PLS_INTEGER DEFAULT 0;
   l_paragraph_exists        BOOLEAN;
   l_seq_num                 PLS_INTEGER DEFAULT 0;
Begin
       -- First Check the if Attachment functionality is enabled/not and retreive funciton_id
       GMA_EDITEXT_ATTACH_MIG.Check_Fnd_Attachment_Defined
                                  (
                                    p_text_code              => p_text_code,
                                    p_sy_para_cds_table_name => p_sy_para_cds_table_name,
                                    p_form_short_name => p_attach_form_short_name,
                                    p_table_name      => p_attach_table_name     ,
                                    p_attachment_function_id => l_attachment_function_id
                                   );

       -- OPEN Cursor for All paragraphs for specific table eg: IC_ITEM_MST
       FOR rec in Cur_Paragraph(p_sy_para_cds_table_name)
       LOOP

         /* Create the document row only if the paragraph is associated */
         /* with the text code */
         Check_Text_Paragraph_Match (p_text_code       => p_text_code
                                    ,p_text_tl_table   => p_text_table_tl
                                    ,p_paragraph_code  => rec.paragraph_code
                                    ,p_sub_paracode    => rec.sub_paracode
                                    ,x_paragraph_exists=> l_paragraph_exists
                                    );

         IF l_paragraph_exists THEN


            l_para_count := l_para_count + 1;

            -- Enable all languages if not in FND_LANGUAGES
            GMA_EDITEXT_ATTACH_MIG.Fnd_Document_Set_Languages
                                 (
                                   p_text_code      => p_text_code,
                                   p_sy_para_cds_table_name => p_sy_para_cds_table_name,
                                   p_text_tl_table  => p_text_table_tl,
                                   p_paragraph_code => rec.paragraph_code,
                                   p_sub_paracode   => rec.sub_paracode
                                  );

           l_document_id:=null;

           -- Lets check if the document is already exist or not for all paragraphs with each Text code
           -- if exists then do not create otherwise create additional if any one is missing
          GMA_EDITEXT_ATTACH_MIG.Check_Fnd_Document_Exists
                                (
                                   p_text_tl_table          => p_text_table_tl,
                                   p_sy_para_cds_table_name => p_sy_para_cds_table_name,
                                   p_Text_code            => p_text_code,
                                   p_paragraph_code       => rec.paragraph_code,
                                   p_sub_paracode         => rec.sub_paracode,
                                   p_pk1_value            => p_attach_pk1_value,
                                   p_pk2_value            => p_attach_pk2_value,
                                   p_pk3_value            => p_attach_pk3_value,
                                   p_pk4_value            => p_attach_pk4_value,
                                   p_pk5_value            => p_attach_pk5_value,
                                   p_paragraph_count      => l_para_count,
                                   p_document_exist       => l_document_exist,
                                   p_file_name => l_file_name
                                                                 );
           -- Lets create the Attachment if does not exists
           IF l_document_exist='FALSE' then
             FOR lang_rec IN Cur_Paragraph_Lang(p_sy_para_cds_table_name,
                                                rec.paragraph_code,
                                                rec.sub_paracode)
             LOOP
                 l_media_id := NULL;
                 l_document_id := NULL;
                 l_seq_num := l_seq_num + 10;

                 -- Lets create the Attachment for all paragraphs with each Text code
                 GMA_EDITEXT_ATTACH_MIG.Create_Fnd_Document
                                 (
                                   p_text_code              => p_text_code,
                                   p_sy_para_cds_table_name => p_sy_para_cds_table_name,
                                   p_entity_name   => p_attach_table_name,
                                   p_pk1_value     => p_attach_pk1_value,
                                   p_pk2_value     => p_attach_pk2_value,
                                   p_pk3_value     => p_attach_pk3_value,
                                   p_pk4_value     => p_attach_pk4_value,
                                   p_pk5_value     => p_attach_pk5_value,
                                   p_file_name     => l_file_name,
                                   x_description   => rec.para_desc||' - '||lang_rec.language,
                                   x_attached_document_id => l_attached_document_id,
                                   x_document_id   => l_document_id,
                                   x_media_id      => l_media_id,
                                   p_attachment_function_id  => l_attachment_function_id,
                                   p_sequence_num  => l_seq_num
                                 );

                 GMA_EDITEXT_ATTACH_MIG.Create_Fnd_Short_Text
                                (
                                   p_text_tl_table          => p_text_table_tl,
                                   p_sy_para_cds_table_name => p_sy_para_cds_table_name,
                                   p_Text_code            => p_text_code,
                                   p_paragraph_code       => rec.paragraph_code,
                                   p_sub_paracode         => rec.sub_paracode,
                                   p_language             => lang_rec.language,
                                   p_attached_document_id => l_attached_document_id,
                                   p_document_id          => l_document_id,
                                   p_media_id             => l_media_id,
                                   p_pk1_value            => p_attach_pk1_value,
                                   p_pk2_value            => p_attach_pk2_value,
                                   p_pk3_value            => p_attach_pk3_value,
                                   p_pk4_value            => p_attach_pk4_value,
                                   p_pk5_value            => p_attach_pk5_value,
                                   p_paragraph_count      => Cur_Paragraph%rowcount
                                );

             END LOOP;

          END IF;

         END IF;

       END LOOP;

       If NOT(l_Paragraph_exists) AND (l_para_count = 0) Then

          -- When no pragraph exists insert the following message
	     FND_MESSAGE.SET_NAME('GMA', 'GMA_NO_PARAGRAPH_EXIST');
             FND_MESSAGE.SET_TOKEN('FORM_NAME',p_attach_form_short_name,FALSE);
             FND_MESSAGE.SET_TOKEN('TABLE_NAME',p_sy_para_cds_table_name,FALSE);
             FND_MSG_PUB.ADD;

       End if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;

      RAISE;

End Attachment_Main;

-- Procedure to check if Attachment functionality is defined or not
PROCEDURE Check_Fnd_Attachment_Defined(
    p_text_code              IN   VARCHAR2  default null,
    p_sy_para_cds_table_name in   VARCHAR2  default null,
    p_form_short_name        IN   VARCHAR2  default null,
    p_table_name             IN   VARCHAR2  default null,
    p_attachment_function_id OUT NOCOPY NUMBER
    )
Is
    l_attachment_function_id fnd_attachment_functions.attachment_function_id%type;
    l_api_name               CONSTANT VARCHAR2(30)   := 'Check_Fnd_Attachment_Defined' ;
    l_api_version            CONSTANT NUMBER         := 1.0 ;
    l_progress               VARCHAR2(3) := '000';
    l_long_message           VARCHAR2(4000);

Begin
        -- Validating the attachment functionality for given form and table
        SELECT  attachment_function_id
          into l_attachment_function_id
        FROM fnd_attachment_functions
        WHERE attachment_function_id
              in(SELECT attachment_function_id
                    from fnd_attachment_blocks
                 WHERE attachment_blk_id
                       in(SELECT attachment_Blk_id
                            from fnd_attachment_blk_entities
                          WHERE data_object_code
                                in(SELECT data_object_code
                                     from fnd_document_entities
                                   WHERE UPPER(table_name) in(p_table_name)
                                   )
                         )
                 )
        AND upper(FUNCTION_NAME)=p_form_short_name
        AND FUNCTION_TYPE='O';

        --When returns something then pass back the attachment_function_id
        p_attachment_function_id:=l_attachment_function_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- if no attachment functionality is assigned, then stop further text migration processing
        p_attachment_function_id:=-1;

       FND_MESSAGE.SET_NAME('GMA','GMA_ATTACHMENT_NOT_EXISTS');
       FND_MESSAGE.SET_TOKEN('FORM_NAME',p_form_short_name,FALSE);
       FND_MESSAGE.SET_TOKEN('ATTACHMENT_ID',p_attachment_function_id,FALSE);
       FND_MSG_PUB.ADD;

       Raise;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;

     RAISE;

End Check_Fnd_Attachment_Defined;

-- Procedure to check if Attachment documents already exists or not
PROCEDURE Check_Fnd_Document_Exists
                             (
                                p_text_tl_table          IN VARCHAR2  default null,
                                p_sy_para_cds_table_name IN VARCHAR2  default null,
                                p_text_code              IN VARCHAR2,
                                p_paragraph_code         IN VARCHAR2,
                                p_sub_paracode           IN NUMBER,
                                p_pk1_value              IN VARCHAR2 Default null,
                                p_pk2_value              IN VARCHAR2 Default null,
                                p_pk3_value              IN VARCHAR2 Default null,
                                p_pk4_value              IN VARCHAR2 Default null,
                                p_pk5_value              IN VARCHAR2 Default null,
                                p_paragraph_count        IN NUMBER Default null,
                                p_document_exist         OUT NOCOPY VARCHAR2,
                                p_file_name OUT NOCOPY VARCHAR2
                              )
IS
    l_api_name         CONSTANT VARCHAR2(30)   := 'Check_Fnd_Document_Exists' ;
    l_api_version      CONSTANT NUMBER         := 1.0 ;
    l_progress         VARCHAR2(3) := '000';
    l_long_message     VARCHAR2(4000);

   CURSOR cur_paragraph(x_table_name varchar2,
                        x_paragraph_code in varchar2,
                        x_sub_paracode in number)
   is
          SELECT
                  L.LANGUAGE_CODE,
                  B.PARAGRAPH_CODE,
                  B.SUB_PARACODE,
                  B.PARA_DESC,
                  B.language
          FROM SY_PARA_CDS_TL B, FND_LANGUAGES L
          WHERE L.INSTALLED_FLAG IN ('B')
            AND B.PARAGRAPH_CODE=x_paragraph_code
            AND B.SUB_PARACODE=x_sub_paracode
            AND B.TABLE_NAME=x_table_name  --'IC_ITEM_MST'
            AND B.LANGUAGE=L.LANGUAGE_CODE;

  CURSOR cur_fnd_documents(x_filename in varchar2)
   is
          SELECT
                  DOCUMENT_ID,
                  FILE_NAME,
                  MEDIA_ID
          FROM FND_DOCUMENTS
          WHERE FILE_NAME=x_filename;

   l_flag varchar2(10):='FALSE';
   l_filename varchar2(2000);

Begin

  -- Lets validate the filename through Cursor Paragraph and sub_paracode
   FOR crec IN Cur_Paragraph( p_sy_para_cds_table_name,
                              p_paragraph_code,
                              p_sub_paracode)
   LOOP

      -- Lets define the attachment filename as unique for each language into FND_DOCUMENTS_TL table
      l_filename:=p_text_code||'.'||crec.language;


            if nvl(p_pk1_value,'N')<>'N' then
                  l_filename:=l_filename||'.'||p_pk1_value;
            end if;
            if nvl(p_pk2_value,'N')<>'N' then
                  l_filename:=l_filename||'.'||p_pk2_value;
            end if;
            if nvl(p_pk3_value,'N')<>'N' then
                  l_filename:=l_filename||'.'||p_pk3_value;
            end if;
            if nvl(p_pk4_value,'N')<>'N' then
                  l_filename:=l_filename||'.'||p_pk4_value;
            end if;
            if nvl(p_pk5_value,'N')<>'N' then
                  l_filename:=l_filename||'.'||p_pk5_value;
            end if;

            l_filename:=l_filename||'.'||p_paragraph_count;
            p_file_name := l_filename;
            -- Lets validate the filename through Cursor
            for rec IN Cur_fnd_documents(l_filename)
            loop

                    -- Lets validate the filename is already present or not
                    l_flag:='TRUE';
                    l_long_message:= 'Paragraph_Code='||crec.paragraph_code||
                                           ' Sub_Paracode='||crec.sub_paracode||
                                           ' Para_Desc='||crec.para_desc||
                                           ' Document_Id='||rec.DOCUMENT_ID||
                                           ' File_Name='||rec.FILE_NAME||
                                           ' Media_ID='||rec.MEDIA_ID||
                                           ' Language='||crec.LANGUAGE||
                                           ' ... Document Already Exist in FND_DOCUMENTS_TL (Cannot Create).';


                    fnd_file.put_line(fnd_file.log,l_long_message);
                    fnd_file.put_line(fnd_file.output,l_long_message);
                    exit;
             end loop;

    END LOOP;

    -- if filename is already present for any language then assume that it is already creatd earlier
    p_document_exist:=l_flag;

EXCEPTION
   WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;
     RAISE;

End Check_Fnd_Document_Exists;

-- Procedure to get the PK12345 column names for Attachment defined in APPS dev resp
-- This procedure is for external use and can be used to find the pk columns
PROCEDURE Get_Fnd_Attachment_Blk_PK(
                                p_text_code       IN   VARCHAR2  default null,
                                p_sy_para_cds_table_name in   VARCHAR2  default null,
                                p_form_short_name IN   VARCHAR2  default null,
                                p_table_name      IN   VARCHAR2  default null,
                                p_attachment_function_id IN NUMBER,
                                p_pk1_value     OUT NOCOPY VARCHAR2,
                                p_pk2_value     OUT NOCOPY VARCHAR2 ,
                                p_pk3_value     OUT NOCOPY VARCHAR2 ,
                                p_pk4_value     OUT NOCOPY VARCHAR2 ,
                                p_pk5_value     OUT NOCOPY VARCHAR2
    )
Is
    l_pk1_field    fnd_attachment_blk_entities.pk1_field%type;
    l_pk2_field    fnd_attachment_blk_entities.pk2_field%type;
    l_pk3_field    fnd_attachment_blk_entities.pk3_field%type;
    l_pk4_field    fnd_attachment_blk_entities.pk4_field%type;
    l_pk5_field    fnd_attachment_blk_entities.pk5_field%type;

    l_api_name         CONSTANT VARCHAR2(30)   := 'Get_Fnd_Attachment_Blk_PK' ;
    l_api_version      CONSTANT NUMBER         := 1.0 ;
    l_progress	       VARCHAR2(3) := '000';
    l_long_message     VARCHAR2(4000);
Begin

        -- Validate and get the PK12345 for the attachment block
        select PK1_FIELD,
               PK2_FIELD,
               PK3_FIELD,
               PK4_FIELD,
               PK5_FIELD
        into   p_pk1_value,
               p_pk2_value,
               p_pk3_value,
               p_pk4_value,
               p_pk5_value
        from  fnd_attachment_blk_entities
        where data_object_code=p_table_name
        and   attachment_blk_id=
                    (SELECT attachment_blk_id
                     FROM fnd_attachment_blocks
                     WHERE attachment_function_id=p_attachment_function_id
                     AND   block_name=p_table_name);

EXCEPTION
   WHEN NO_DATA_FOUND THEN

      -- if no PK columns defined for attachment functionality then ignore
       FND_MESSAGE.SET_NAME('GMA','GMA_ATTACH_COL_NOT_EXISTS');
       FND_MESSAGE.SET_TOKEN('FORM_NAME',p_form_short_name,FALSE);
       FND_MESSAGE.SET_TOKEN('pk1_value',p_pk1_value,FALSE);
       FND_MESSAGE.SET_TOKEN('pk2_value',p_pk2_value,FALSE);
       FND_MESSAGE.SET_TOKEN('pk3_value',p_pk3_value,FALSE);
       FND_MESSAGE.SET_TOKEN('pk4_value',p_pk4_value,FALSE);
       FND_MESSAGE.SET_TOKEN('pk5_value',p_pk5_value,FALSE);
       FND_MSG_PUB.ADD;


  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;

      RAISE;


End Get_Fnd_Attachment_Blk_PK;

-- Procedure to Set the languages in FND_LANGUAGE if not installed
PROCEDURE Fnd_Document_set_languages
                              (
                                p_text_code       in NUMBER Default null,
                                p_sy_para_cds_table_name in VARCHAR2  default null,
                                p_text_tl_table   in VARCHAR2 Default null,
                                p_paragraph_code  in VARCHAR2 Default null,
                                p_sub_paracode    in Number Default null
                               )
IS
   l_api_name         CONSTANT VARCHAR2(30)   := 'Fnd_Document_set_languages' ;
   l_api_version      CONSTANT NUMBER         := 1.0 ;
   l_progress         VARCHAR2(3) := '000';
   l_long_message     VARCHAR2(4000);

   l_sql_stmt         VARCHAR2(3200);
   l_sql_stmt1        VARCHAR2(3200);
   l_cursor           INTEGER := NULL;
   l_rows_processed   INTEGER := NULL;

   l_language        varchar2(6);
   l_paragraph_code  varchar2(4);
   l_sub_paracode    number(5);
   l_lang_code       varchar2(4);
   l_total_rows      number(5);
Begin



   -- Lets define dynamic SQL stmt for languages
   l_sql_stmt := 'SELECT DISTINCT language,
                         paragraph_code,
                         sub_paracode,
                         lang_code
                  FROM  '||P_text_tl_table||'
                  WHERE text_code=:P_text_code
                  AND   paragraph_code=:P_paragraph_code
                  AND   sub_paracode=:P_sub_paracode
                  ORDER BY LANGUAGE';

   -- Lets define dynamic SQL stmt for languages
   l_sql_stmt1 := 'SELECT filename,
                  FROM  FND_DOCUMENT_TL
                  WHERE filename=:P_filename
                  AND   language=:P_language';

   l_cursor := DBMS_SQL.OPEN_CURSOR;

   DBMS_SQL.PARSE( l_cursor, l_sql_stmt , DBMS_SQL.NATIVE );

   DBMS_SQL.BIND_VARIABLE(l_cursor,'P_text_code'      ,P_text_code);
   DBMS_SQL.BIND_VARIABLE(l_cursor,'P_paragraph_code' ,P_paragraph_code );
   DBMS_SQL.BIND_VARIABLE(l_cursor,'P_sub_paracode'   ,P_sub_paracode );

   DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_language,6);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 2, l_paragraph_code,4);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 3, l_sub_paracode);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 4, l_lang_code,4);

   l_rows_processed := DBMS_SQL.EXECUTE(l_cursor);

   loop

   IF ( DBMS_SQL.FETCH_ROWS(l_cursor) > 0 ) THEN

      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_language);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_paragraph_code);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 3, l_sub_paracode);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 4, l_lang_code);

        UPDATE FND_LANGUAGES
              set installed_flag='I'
        WHERE
             language_code=l_language
        AND  installed_flag not in('I','B');


   ELSE
      l_language        := NULL;
      l_paragraph_code  := NULL;
      l_sub_paracode    := NULL;
      l_lang_code       := NULL;
      exit;
   END IF;

   end loop;

   DBMS_SQL.CLOSE_CURSOR(l_cursor);

Exception
  WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;


      IF DBMS_SQL.IS_OPEN(l_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(l_cursor);
      END IF;

      RAISE;

End Fnd_Document_Set_Languages;

-- Procedure to define the common category for all attachment accross OPM
-- If category exists it uses otherwise it creates
PROCEDURE Get_Fnd_Attachment_Category
              (
                p_text_code        IN   VARCHAR2  default null,
                p_sy_para_cds_table_name in VARCHAR2 default null,
                p_category_name    IN   VARCHAR2  default 'OPM_MIGRATED_TEXT',
                p_user_name        IN   VARCHAR2  default 'GMA Migration Text',
                p_category_exists  OUT NOCOPY NUMBER,
                p_category_id      OUT NOCOPY NUMBER
              )
IS

    l_api_name         CONSTANT VARCHAR2(30)   := 'Get_Fnd_Attachment_Category' ;
    l_api_version      CONSTANT NUMBER         := 1.0 ;
    l_progress         VARCHAR2(3) := '000';
    l_long_message     VARCHAR2(4000);

  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(30)
     INDEX BY BINARY_INTEGER;

    l_Rowid                            VARCHAR2(200);
    l_sysdate                          DATE := SYSDATE;
    l_application_id                   NUMBER :=550;    -- GMA
    l_attribute1_value                 VARCHAR2(2000);
    l_attribute2_value                 VARCHAR2(2000);
    l_attribute3_value                 VARCHAR2(2000);
    l_attribute4_value                 VARCHAR2(2000);
    l_attribute5_value                 VARCHAR2(2000);
    l_attribute6_value                 VARCHAR2(2000);
    l_attribute7_value                 VARCHAR2(2000);
    l_attribute8_value                 VARCHAR2(2000);
    l_attribute9_value                 VARCHAR2(2000);
    l_attribute10_value                VARCHAR2(2000);
    l_attribute11_value                VARCHAR2(2000);
    l_attribute12_value                VARCHAR2(2000);
    l_attribute13_value                VARCHAR2(2000);
    l_attribute14_value                VARCHAR2(2000);
    l_attribute15_value                VARCHAR2(2000);
    l_name_tbl                         VARCHAR_TBL_TYPE;
    l_value_tbl                        VARCHAR_TBL_TYPE;
    l_user_name                        fnd_document_categories_tl.user_name%TYPE :=p_user_name;
    l_dummy                            VARCHAR2(1);
    l_category_id                      NUMBER := 0;

    l_user_id 		number := 0 ;

Begin

      -- Get category Id from fnd_document_categories.
    SELECT category_id,
           application_id
    INTO   l_category_id,
           l_application_id
    FROM   fnd_document_categories_vl
    WHERE  user_name = p_user_name;

    p_category_exists:=1;
    p_category_id:=l_category_id;

       -- Insert message in FND_LOG_MESSAGE through external GMA common Logging


--    fnd_file.put_line(fnd_file.log,l_long_message);
--    fnd_file.put_line(fnd_file.output,l_long_message);

EXCEPTION
      WHEN NO_DATA_FOUND THEN

      -- Get category id from a sequence.
      SELECT fnd_document_categories_s.nextval
      INTO l_category_id
      FROM dual;

       -- Call fnd's package to create the Category
       fnd_doc_categories_pkg.insert_row
       (
          X_ROWID               => l_Rowid,
          X_CATEGORY_ID         => l_category_id,
          X_APPLICATION_ID      => l_application_id,
          X_NAME                => p_category_name,
          X_START_DATE_ACTIVE   => null,
          X_END_DATE_ACTIVE     => null,
          X_ATTRIBUTE_CATEGORY  => null,
          X_ATTRIBUTE1          => l_attribute1_value,
          X_ATTRIBUTE2          => l_attribute2_value,
          X_ATTRIBUTE3          => l_attribute3_value,
          X_ATTRIBUTE4          => l_attribute4_value,
          X_ATTRIBUTE5          => l_attribute5_value,
          X_ATTRIBUTE6          => l_attribute6_value,
          X_ATTRIBUTE7          => l_attribute7_value,
          X_ATTRIBUTE8          => l_attribute8_value,
          X_ATTRIBUTE9          => l_attribute9_value,
          X_ATTRIBUTE10         => l_attribute10_value,
          X_ATTRIBUTE11         => l_attribute11_value,
          X_ATTRIBUTE12         => l_attribute12_value,
          X_ATTRIBUTE13         => l_attribute13_value,
          X_ATTRIBUTE14         => l_attribute14_value,
          X_ATTRIBUTE15         => l_attribute15_value,
          X_DEFAULT_DATATYPE_ID => 1,    -- Short Text
          X_USER_NAME           => l_user_name,
          X_CREATION_DATE       => l_sysdate,
          X_CREATED_BY          => FND_GLOBAL.login_id,
          X_LAST_UPDATE_DATE    => l_sysdate,
          X_LAST_UPDATED_BY     => FND_GLOBAL.login_id,
          X_LAST_UPDATE_LOGIN   => FND_GLOBAL.login_id);

          p_category_exists:=-1;
          p_category_id:=l_category_id;

          FND_MESSAGE.SET_NAME('GMA','GMA_CATEGORY_CREATED');
          FND_MESSAGE.SET_TOKEN('category_name',p_category_name,FALSE);
	  FND_MESSAGE.SET_TOKEN('category_id',l_category_id,FALSE);
          FND_MSG_PUB.ADD;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;

      RAISE;

End Get_Fnd_Attachment_Category;

-- Procedure to find/create the Category usuage which is needed for every category
PROCEDURE Get_Fnd_Category_Usage(
                                 p_text_code                IN   VARCHAR2  default null,
                                 p_sy_para_cds_table_name  in VARCHAR2  default null,
                                 p_category_id              IN  NUMBER,
                                 p_attachment_function_id   IN  NUMBER,
                                 p_category_usage_exists    OUT NOCOPY NUMBER
    )
IS
    l_api_name         CONSTANT VARCHAR2(30)   := 'Get_Fnd_Category_Usage' ;
    l_api_version      CONSTANT NUMBER         := 1.0 ;
    l_progress         VARCHAR2(3) := '000';
    l_long_message     VARCHAR2(4000);

    l_sysdate                   DATE := SYSDATE;
    l_doc_category_usage_id     NUMBER := 0;
    l_user_id 		        number := 0 ;

Begin

     -- Get category Id from fnd_document_categories.
     select doc_category_usage_id
     INTO l_doc_category_usage_id
     from   fnd_doc_category_usages
     WHERE  category_id = p_category_id
     and  attachment_function_id=p_attachment_function_id;

     p_category_usage_exists:=1;

EXCEPTION
WHEN NO_DATA_FOUND THEN

      -- Get category id from a sequence.
      select fnd_doc_category_usages_s.nextval
      into   l_doc_category_usage_id
      from   dual;

      INSERT INTO FND_DOC_CATEGORY_USAGES
             (DOC_CATEGORY_USAGE_ID,
              CATEGORY_ID,
              ATTACHMENT_FUNCTION_ID,
              ENABLED_FLAG,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN)
      VALUES (l_doc_category_usage_id,
              p_category_id,
              p_attachment_function_id,
              'Y',
               l_sysdate,
               l_user_id,
               l_sysdate,
               l_user_id,
               l_user_id);

        p_category_usage_exists:=-1;
      FND_MESSAGE.SET_NAME('GMA','GMA_CATEGORY_USAGE_ID_CREATED');
      FND_MESSAGE.SET_TOKEN('category_usage_id',l_doc_category_usage_id,FALSE);
      FND_MESSAGE.SET_TOKEN('category_id',p_category_id,FALSE);
      FND_MSG_PUB.ADD;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;

      RAISE;

End Get_Fnd_Category_Usage;

-- Procedure to create the attachment document for all languages
PROCEDURE Create_Fnd_Document(
                                p_text_code     IN VARCHAR2  default null,
                                p_sy_para_cds_table_name in VARCHAR2  default null,
                                p_entity_name   in VARCHAR2 Default 'GMA Migration',
                                p_pk1_value     in VARCHAR2 Default null,
                                p_pk2_value     in VARCHAR2 Default null,
                                p_pk3_value     in VARCHAR2 Default null,
                                p_pk4_value     in VARCHAR2 Default null,
                                p_pk5_value     in VARCHAR2 Default null,
                                x_description   in VARCHAR2 Default null,
                                p_file_name     IN VARCHAR2 DEFAULT NULL,
                                x_attached_document_id   IN OUT NOCOPY NUMBER,
                                x_document_id   IN OUT NOCOPY NUMBER,
                                x_media_id   IN OUT NOCOPY NUMBER,
                                p_attachment_function_id  in  NUMBER,
                                p_sequence_num  IN NUMBER
                             )
IS
   l_api_name         CONSTANT VARCHAR2(30)   := 'Create_Fnd_Document' ;
   l_api_version      CONSTANT NUMBER         := 1.0 ;
   l_progress         VARCHAR2(3) := '000';
   l_long_message     VARCHAR2(4000);


   l_new_attachment_id    NUMBER;
   l_row_id               VARCHAR2(30);
   l_current_date         DATE := sysdate;
   l_attachment_function_id  fnd_attachment_functions.attachment_function_id%type;
   l_attached_document_id fnd_documents.document_id%TYPE;
   l_create_Attached_Doc boolean := true;
   l_dummy fnd_documents.document_id%TYPE;

   CURSOR c_attached_doc_id IS
      SELECT FND_ATTACHED_DOCUMENTS_S.nextval
      FROM dual;

   CURSOR c_attached_doc_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM FND_ATTACHED_DOCUMENTS
      WHERE document_id = l_id;

  l_category_name   fnd_document_categories_tl.name%TYPE:='OPM_MIGRATED_TEXT';
  l_user_name       fnd_document_categories_tl.user_name%TYPE:='GMA Migration Text';
  l_category_exists fnd_document_categories_tl.category_id%TYPE;
  l_category_id     fnd_document_categories_tl.category_id%TYPE;
  l_category_usage_exists fnd_document_categories_tl.category_id%TYPE;

Begin


    -- Get the GMA migration attachment category
       Get_Fnd_Attachment_Category(p_text_code,
                                   p_sy_para_cds_table_name,
                                   l_category_name,
                                   l_user_name,
                                   l_category_exists,
                                   l_category_id
                                   );

    -- Get the GMA migration attachment category usage for the category
       Get_Fnd_Category_Usage(p_text_code,
                              p_sy_para_cds_table_name,
                              l_category_id,
                              p_attachment_function_id,
                              l_category_usage_exists
                              );

            -- Validating the attachment functionality for given form and table
	    --  IF p_Fnd_Attachment_rec.attached_DOCUMENT_ID IS NULL THEN
            LOOP
                l_dummy := NULL;
                OPEN c_attached_doc_id;
                FETCH c_attached_doc_id INTO l_attached_document_ID;
                CLOSE c_attached_doc_id;

                OPEN c_attached_doc_id_exists(l_attached_document_ID);
                FETCH c_attached_doc_id_exists INTO l_dummy;
                CLOSE c_attached_doc_id_exists;
                EXIT WHEN l_dummy IS NULL;
            END LOOP;

            x_attached_document_id := l_attached_document_id;

	   /* Populate FND Attachments */
	   fnd_attached_documents_pkg.Insert_Row
	   (  x_rowid                     => l_row_id,
	      X_attached_document_id      => l_attached_document_ID,
	      X_document_id               => x_document_ID,
	      X_creation_date             => sysdate,
	      X_created_by                => FND_GLOBAL.USER_ID,
	      X_last_update_date          => sysdate,
	      X_last_updated_by           => FND_GLOBAL.USER_ID,
	      X_last_update_login         => FND_GLOBAL.CONC_LOGIN_ID,
	      X_seq_num                   => p_sequence_num,
	      X_entity_name               => p_entity_name,      --'GMA Migration',
	      x_column1                   => null,
	      X_pk1_value                 => p_pk1_value,
	      X_pk2_value                 => p_pk2_value,
	      X_pk3_value                 => p_pk3_value,
	      X_pk4_value                 => p_pk4_value,
	      X_pk5_value                 => p_pk5_value,
	      X_automatically_added_flag  => 'N',
	      X_datatype_id               => 1,
	      X_category_id               => l_category_id,
	      X_security_type             => 1,
	      X_publish_flag              => 'Y',
	      X_usage_type                => 'O',   --  May be changed as checked for attachment
	      X_language                  => null,
              X_description               => x_description,   --'General Text',
          X_file_name                 => p_file_name,
	      X_media_id                  => x_media_id,
	      X_doc_attribute_Category    => null,
	      X_doc_attribute1            => null,
	      X_doc_attribute2            => null,
	      X_doc_attribute3            => null,
	      X_doc_attribute4            => null,
	      X_doc_attribute5            => null,
	      X_doc_attribute6            => null,
	      X_doc_attribute7            => null,
	      X_doc_attribute8            => null,
	      X_doc_attribute9            => null,
	      X_doc_attribute10           => null,
	      X_doc_attribute11           => null,
	      X_doc_attribute12           => null,
	      X_doc_attribute13           => null,
	      X_doc_attribute14           => null,
	      X_doc_attribute15           => null
	   );

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;

      RAISE;

End Create_Fnd_Document;

-- Procedure which creates the actual text for attachments as unique to each language
PROCEDURE Create_Fnd_Short_Text
                             (
                                p_text_tl_table          IN VARCHAR2  default null,
                                p_sy_para_cds_table_name IN VARCHAR2  default null,
                                p_text_code              IN VARCHAR2,
                                p_paragraph_code         IN VARCHAR2,
                                p_sub_paracode           IN NUMBER,
                                p_language               IN VARCHAR2,
                                p_attached_document_id   IN OUT NOCOPY NUMBER,
                                p_document_id            IN OUT NOCOPY NUMBER,
                                p_media_id               IN OUT NOCOPY NUMBER,
                                p_pk1_value              in VARCHAR2 Default null,
                                p_pk2_value              in VARCHAR2 Default null,
                                p_pk3_value              in VARCHAR2 Default null,
                                p_pk4_value              in VARCHAR2 Default null,
                                p_pk5_value              in VARCHAR2 Default null,
                                p_paragraph_count        in NUMBER Default null
                             )
IS

   l_api_name         CONSTANT VARCHAR2(30)   := 'Create_Fnd_Short_Text' ;
   l_api_version      CONSTANT NUMBER         := 1.0 ;
   l_progress         VARCHAR2(3) := '000';
   l_long_message     VARCHAR2(4000);

   l_row_id                VARCHAR2(30);
   l_current_date          DATE := sysdate;
   l_attached_document_id  fnd_documents.document_id%TYPE;
   l_document_ID           fnd_documents.document_id%TYPE;

  l_file_id   number;
  l_long_text long;
  l_text      ic_text_tbl_tl.text%type;
  l_flag      varchar2(6):='FALSE';

  l_text_tl          VARCHAR2(70);
  l_sql_stmt         VARCHAR2(3200);
  l_cursor           INTEGER := NULL;
  l_rows_processed   INTEGER := NULL;

Begin
    -- Get the GMA migratio attachment category
   l_file_id:=p_media_id;

   l_long_text:=null;

   l_flag:='FALSE';

   l_cursor := DBMS_SQL.OPEN_CURSOR;

   -- Lets define dynamic sql for attachment text
   l_sql_stmt := 'SELECT text '||
                 ' FROM   '  || p_text_tl_table ||
                 ' WHERE  text_code=     :x_Text_Code     '||
                 ' AND    paragraph_code=:x_paragraph_code'||
                 ' AND    sub_paracode=  :x_sub_paracode  '||
                 ' AND    language=      :x_language      '||
                 ' AND    line_no>-1'     ||
                 ' ORDER BY line_no';

    DBMS_SQL.PARSE( l_cursor, l_sql_stmt , DBMS_SQL.NATIVE );

    -- Lets define dynamic sql bind variables
    DBMS_SQL.BIND_VARIABLE(l_cursor,'x_Text_Code'      ,P_text_code);
    DBMS_SQL.BIND_VARIABLE(l_cursor,'x_paragraph_code' ,P_paragraph_code );
    DBMS_SQL.BIND_VARIABLE(l_cursor,'x_sub_paracode', P_sub_paracode );
    DBMS_SQL.BIND_VARIABLE(l_cursor,'x_language',P_language );

    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_text_tl,70);

    l_rows_processed := DBMS_SQL.EXECUTE(l_cursor);

    loop

      IF ( DBMS_SQL.FETCH_ROWS(l_cursor) > 0 ) THEN
        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_text_tl);
        l_long_text:=l_long_text||l_text_tl;
        l_flag:='TRUE';
      ELSE
        exit;
      END IF;

    end loop;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    if l_flag='TRUE' then
      -- if true then insert the attachment into fnd_documents_long_text table
      INSERT INTO
       fnd_documents_short_text
       (
          MEDIA_ID,
          APP_SOURCE_VERSION,
          SHORT_TEXT
        )
       VALUES
       (
          l_file_id,
          NULL,
          l_long_text
        );

    end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;
    RAISE;
End Create_Fnd_Short_Text;


-- Procedure to check if text has been defined for the give paragraph
-- code for the given text code.
PROCEDURE Check_Text_Paragraph_Match
                              (
                                p_text_code        IN NUMBER,
                                p_text_tl_table    IN VARCHAR2,
                                p_paragraph_code   IN VARCHAR2,
                                p_sub_paracode     IN NUMBER,
                                x_paragraph_exists OUT NOCOPY BOOLEAN
                               )
IS
   l_api_name         CONSTANT VARCHAR2(30)   := 'Check_Text_Paragraph_Match' ;

   l_sql_stmt         VARCHAR2(3200);

  -- REF cursor definition
  TYPE REF_CUR is REF CURSOR;
  l_ref_cur REF_CUR;

  l_exists PLS_INTEGER;
Begin

   -- Lets initialize the paragraph exists flag to FALSE
   x_paragraph_exists := FALSE;

   -- Lets define dynamic SQL stmt for checking the paragraph
   l_sql_stmt := ' SELECT 1 '||
                 ' FROM  '||P_text_tl_table||
                 ' WHERE text_code=:1 '||
                 ' AND   paragraph_code=:2 '||
                 ' AND   sub_paracode=:3';

   OPEN l_ref_cur FOR l_sql_stmt using P_text_code, P_paragraph_code, P_sub_paracode;
   FETCH l_ref_cur INTO l_exists;
   IF l_ref_cur%FOUND THEN
     x_paragraph_exists := TRUE;
   END IF;
   CLOSE l_ref_cur;

Exception
  WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME('FND', 'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME', 'GMA_EDITEXT_ATTACH_MIG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME', l_api_name);
    FND_MSG_PUB.ADD;

    RAISE;

End Check_Text_Paragraph_Match;

END GMA_EDITEXT_ATTACH_MIG;

/
