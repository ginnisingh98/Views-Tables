--------------------------------------------------------
--  DDL for Package Body OKC_ARTICLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTICLES_GRP" AS
/* $Header: OKCGARTB.pls 120.6.12010000.10 2013/08/19 07:37:31 kkolukul ship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
    G_GLOBAL_ORG_ID NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    G_profile_doc_seq VARCHAR2(1) :=  fnd_profile.value('UNIQUE:SEQ_NUMBERS');
    G_doc_category_code VARCHAR2(30) := substr(Fnd_Profile.Value('OKC_ARTICLE_DOC_SEQ_CATEGORY'),1,30) ;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ARTICLES_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';

  G_INVALID_VALUE              CONSTANT   varchar2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT   varchar2(200) := OKC_API.G_COL_NAME_TOKEN;
  -- MOAC
  --G_CURRENT_ORG_ID             NUMBER := -99;
  G_CURRENT_ORG_ID             NUMBER ;
  G_UNABLE_TO_RESERVE_REC      CONSTANT VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_DELETED;
  G_VAR_NOT_CLOSED             EXCEPTION;
  G_VAR_NOT_FOUND              EXCEPTION;
  G_VAR_NOT_FOUND_RET_STS     CONSTANT    varchar2(1) := 'V';
-- MOAC
/*
-- One Time fetch and cache the current Org.
  CURSOR CUR_ORG_CSR IS
        SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                                                   SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
        FROM DUAL;
*/

  ---------------------------------------
  -- PROCEDURE This API restores the variable tags from the clause text overwritten by the JAVA Parser.
 -- e.g. ;@ will be restored back to <@
  ---------------------------------------

  PROCEDURE special_char_decoders(
  p_temp_article_text IN OUT NOCOPY Varchar2
  ) IS

 Begin
   if  p_temp_article_text is not null  then
       p_temp_article_text :=
      replace(replace
    (p_temp_article_text,'@;','@>'),';@','<@');

    end if;
  end special_char_decoders;

 procedure check_length_n_append(
  p_append_str         IN VARCHAR2,
  p_xml_tag            IN VARCHAR2,
  p_art_text_with_tags IN OUT NOCOPY VARCHAR2,
  p_clob_large         IN OUT NOCOPY CLOB,
  x_return_status      OUT NOCOPY VARCHAR2
  ) IS

  l_check_length INTEGER;
  l_temp_article_text VARCHAR2(10000);
  p_art_str_w_tags_length INTEGER := 0;
  p_append_str_length INTEGER := 0;
  p_xml_tag_length INTEGER := 0;


 Begin

     if p_append_str is not null then
        -- changed the method call from length() to lengthb() to handle mutli byte chars
        -- bug 3697706
        p_append_str_length := lengthb(p_append_str);
        --dbms_output.put_line(' ***IN CHECK LENGTH 2** ' || 'p_append_str_length = ' || p_append_str_length);

     end if;
     if p_xml_tag is not null
     then
        -- changed the method call from length() to lengthb() to handle mutli byte chars
        -- bug 3697706
        p_xml_tag_length        :=  lengthb(p_xml_tag);
     end if;
     if p_art_text_with_tags is not null then
        -- changed the method call from length() to lengthb() to handle mutli byte chars
        -- bug 3697706
        p_art_str_w_tags_length := lengthb(p_art_text_with_tags);
     end if;
        l_check_length := p_art_str_w_tags_length + p_append_str_length + p_xml_tag_length ;

        -- dbms_output.put_line(' ***IN CHECK LENGTH 3** ' || 'l_check_length = --' || l_check_length);

     if (l_check_length < 10000) -- comparison in bytes
     then
        --dbms_output.put_line(' ***IN CHECK LENGTH  if combined sting is less than 4000 **');

        p_art_text_with_tags := p_art_text_with_tags || p_append_str || p_xml_tag;


     else
        l_check_length := p_art_str_w_tags_length + p_append_str_length;
        --dbms_output.put_line(' ***IN CHECK LENGTH  length without xmltag **' ||
--l_check_length );

        if (l_check_length >= 10000) -- comparison in bytes
        then
            if (p_art_str_w_tags_length > 0)
            then

           -- changed for Bug 3697706 using length() to get length in chars  instead of
           -- using the already calculated p_art_str_w_tags_length which is in bytes
                 --dbms_lob.writeappend ( p_clob_large, p_art_str_w_tags_length, p_art_text_with_tags);
                 dbms_lob.writeappend ( p_clob_large, length(p_art_text_with_tags), p_art_text_with_tags);

            end if;
        if (p_append_str_length > 0)
        then
           -- dbms_output.put_line(' ***IN CHECK LENGTH  writing into clob 111**');

           -- changed for Bug 3697706 using length() to get length in chars  instead of
           -- using the already calculated p_append_str_length which is in bytes
--           dbms_lob.writeappend ( p_clob_large, p_append_str_length, p_append_str);
           dbms_lob.writeappend ( p_clob_large, length(p_append_str), p_append_str);

        end if;
        else
           --dbms_output.put_line(' ***IN CHECK LENGTH  writing into clob 222**');

           -- changed for Bug 3697706 using length() to get length in chars  instead of
           -- using the already calculated l_check_length which is in bytes
           --dbms_lob.writeappend ( p_clob_large,l_check_length , (p_art_text_with_tags || p_append_str));
           dbms_lob.writeappend ( p_clob_large,length(p_art_text_with_tags || p_append_str) , (p_art_text_with_tags || p_append_str));

           --   dbms_output.put_line(' ***IN CHECK LENGTH  writing into clob 222**');

        end if ;
        p_art_text_with_tags := p_xml_tag;
      end if;

   EXCEPTION
    when OTHERS
     then
       begin
          x_return_status := G_RET_STS_UNEXP_ERROR;
           Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

       end;

  end check_length_n_append;




 procedure find_variables(
  p_extracted_var_name  IN VARCHAR2,
  p_intent         IN VARCHAR2,
  p_language       IN VARCHAR2,
  p_batch_number   IN VARCHAR2 DEFAULT NULL,
  x_variables_tbl  IN OUT NOCOPY variable_code_tbl_type,
  p_xml_tag        OUT NOCOPY VARCHAR,
  x_return_status  OUT NOCOPY VARCHAR
  ) IS

  G_VAR_NOT_CLOSED             EXCEPTION;
  G_VAR_NOT_FOUND              EXCEPTION;
  l_variable_code Varchar2(30);
  l_variable_type Varchar2(1);
  l_variable_name Varchar2(150);
  l_row_index INTEGER;
  l_var_in_table BOOLEAN := FALSE;
  l_variable_count INTEGER := 1;
  l_rownotfound BOOLEAN := FALSE;

  CURSOR get_variable_metadata_csr (cp_intent IN VARCHAR2,
                                    cp_language IN VARCHAR2 ,
                                    cp_extracted_var_name IN VARCHAR2) IS
  SELECT B.VARIABLE_CODE, B.variable_type, TL.variable_name
   FROM OKC_BUS_VARIABLES_TL TL, OKC_BUS_VARIABLES_B B
   WHERE B.VARIABLE_INTENT = cp_intent
     AND TL.LANGUAGE = cp_language
     AND TL.VARIABLE_NAME = cp_extracted_var_name
     AND DISABLED_YN <> 'Y'
     AND B.VARIABLE_CODE = TL.VARIABLE_CODE;

   -- Defined cursor for 4659659
   -- If p_batch_number is passed then for Import, variable validation should done from variable Interface table
   -- also if it does not exist in the production tables
  CURSOR get_var_imp_metadata_csr  (cp_intent IN VARCHAR2,
                                    cp_language IN VARCHAR2 ,
                                    cp_extracted_var_name IN VARCHAR2,
		                          cp_batch_number IN VARCHAR2) IS
    SELECT VARIABLE_CODE, variable_type, variable_name
    FROM OKC_VARIABLES_INTERFACE
    WHERE batch_number = cp_batch_number
      AND VARIABLE_INTENT   = cp_intent
      AND LANGUAGE = cp_language
      AND VARIABLE_NAME = cp_extracted_var_name
      AND DISABLED_YN <> 'Y'
      AND nvl(process_status,'X') not in ('E');

 Begin
       if p_extracted_var_name is null
        then
           --dbms_output.put_line(' how did it get into the loop ??   '|| p_extracted_var_name);

           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
        if p_extracted_var_name is not null
         then
          --dbms_output.put_line(' l_extracted_var_name  '|| p_extracted_var_name) ;
          okc_debug.log('100: In find variables : variable_name   ' || p_extracted_var_name
            || ' intent = ' || p_intent
            || ' language = ' || p_language , 2);
          OPEN get_variable_metadata_csr (p_intent,
                                          p_language,
                                          p_extracted_var_name);

          FETCH get_variable_metadata_csr INTO l_variable_code,l_variable_type,l_variable_name;

          l_rownotfound := get_variable_metadata_csr%NOTFOUND;
          CLOSE get_variable_metadata_csr;

          if l_rownotfound THEN
		   if p_batch_number is not NULL THEN
		     OPEN get_var_imp_metadata_csr (p_intent,
		                                    p_language,
		                                    p_extracted_var_name,
		                                    p_batch_number);
                FETCH get_var_imp_metadata_csr INTO l_variable_code,l_variable_type,l_variable_name;
	           l_rownotfound := get_var_imp_metadata_csr%NOTFOUND;
                CLOSE get_var_imp_metadata_csr;
                if l_rownotfound THEN
			     RAISE G_VAR_NOT_FOUND;
                end if;
           else
              RAISE G_VAR_NOT_FOUND;
           end if;
          end if;
          p_xml_tag := '<var name="';
          p_xml_tag := p_xml_tag || l_variable_code;
          p_xml_tag := p_xml_tag || '" type="';
          p_xml_tag := p_xml_tag || l_variable_type;
          p_xml_tag := p_xml_tag || '" meaning="';
          p_xml_tag := p_xml_tag || l_variable_name;
          p_xml_tag := p_xml_tag || '"/>';
          --dbms_output.put_line(' p_xml_tag  '|| p_xml_tag || ' length = ' ||
          --       length(p_xml_tag));

          if ( x_variables_tbl.Count = 0)
          then
             -- dbms_output.put_line(' when table count is 0 ' || l_variable_code);

             x_variables_tbl(l_variable_count) := l_variable_code;


          else
             l_row_index := x_variables_tbl.FIRST;
             LOOP
                 l_var_in_table := false ;
                  if ( (x_variables_tbl(l_row_index))  = l_variable_code ) then

                    l_var_in_table := true;
                    exit;
                  end if;
              EXIT WHEN (l_row_index = x_variables_tbl.LAST);
                l_row_index := x_variables_tbl.NEXT(l_row_index);
             END LOOP;

             if (l_var_in_table = false ) then
                 x_variables_tbl((x_variables_tbl.count) + 1) := l_variable_code;

                 --  dbms_output.put_line(' when variable not found in table ' || l_variable_code || ' table count ' || x_variables_tbl.count);

             end if;
           end if;
         end if;
      x_return_status := G_RET_STS_SUCCESS ;
   EXCEPTION
    when G_VAR_NOT_FOUND then
         --dbms_output.put_line(' VAR NOT FOUND 1 ');
          x_return_status :=   G_VAR_NOT_FOUND_RET_STS;
          OKC_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                  p_msg_name      => 'OKC_ART_VAR_NOT_FOUND',
                              p_token1       => 'VARIABLE',
                              p_token1_value => p_extracted_var_name
                  );


     WHEN OTHERS THEN
       --dbms_output.put_line(' VAR NOT FOUND  when others');
          x_return_status := G_RET_STS_UNEXP_ERROR;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

  end find_variables;


 PROCEDURE parse_n_replace_text(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_article_text                 IN OUT NOCOPY CLOB,
    p_dest_clob                    IN OUT NOCOPY CLOB,
    p_calling_mode                 IN VARCHAR2 ,
    p_batch_number                 IN VARCHAR2 DEFAULT NULL,     --Bug 4659659
    p_replace_text                 IN VARCHAR2 := 'N',
    p_article_intent               IN VARCHAR2,
    p_language                     IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_variables_tbl                OUT NOCOPY variable_code_tbl_type
   ) IS


    -- made changes for bug3697706 june 17th 2004
    -- changed l_max_read_amount to 3333 from 8000 to handle mutli byte chars
    -- l_xml_tag to 660 chars , l_temp_tag_unclosed to 450 chars

      l_art_text_with_tags  VARCHAR2(10000);
      --l_temp_art_text  VARCHAR2(10000) CHARACTER SET p_article_text%CHARSET;
      l_temp_art_text  VARCHAR2(10000);
      l_max_read_amount BINARY_INTEGER := 3333;
      l_article_text_length INTEGER;
      l_read_start_position INTEGER:= 1;
      --l_clob CLOB;
      --p_dest_clob CLOB;
      l_xml_tag Varchar2(660);
      l_xml_tag_length INTEGER;
      l_extracted_var_name VARCHAR2(450);
      l_tag_start_postion NUMBER := -99;
      l_tag_end_postion NUMBER := -99;
      l_temp_tag_unclosed Varchar2(450) := null;
      l_check_length INTEGER;
      l_amount_left_to_read Number := 0;
      l_tag_not_closed_read_more BOOLEAN := FALSE;
      p_dest_clob_length INTEGER;
      l_append_str Varchar2(10000);
      l_return_status Varchar2(1) := null;
      l_invalid_var_intent Varchar2(1) := null;

      l_chk_split  VARCHAR2(100);
      l_chk_max_read_amt BINARY_INTEGER := 2;


   BEGIN
      okc_debug.log('100: Entering parse_n_replace_text', 2);
      l_article_text_length :=  DBMS_LOB.GETLENGTH(p_article_text);
      l_amount_left_to_read  := l_article_text_length;
      --dbms_output.put_line('the lenght of the article text clob' || l_article_text_length);

      --DBMS_LOB.CREATETEMPORARY(l_clob,true);
      --DBMS_LOB.CREATETEMPORARY(p_dest_clob,true);
      --DBMS_LOB.COPY(l_clob, p_article_text, l_article_text_length, 1, 1);

  while (l_amount_left_to_read > 0 ) loop
         -- made changes for bug3697706 june 17th 2004 l_max_read_amount is set to 3333 instead of 8000
         -- the max size we are putting in our varchar2 is 10000 bytes i.e. max of 3333 chars in a tri-byte
         -- character set.
        l_max_read_amount  := 3333;

        if NOT (l_tag_not_closed_read_more)
         then
            -- made changes for bug3697706 june 17th 2004 checking for 3333 instead of 8000
            if l_amount_left_to_read > 3333
            then

             -- bug 12593967 starts
              dbms_lob.read (p_article_text, l_chk_max_read_amt, (l_read_start_position+l_max_read_amount-1), l_chk_split);-- dbms_lob returns in chars
              IF l_chk_split='[@' THEN
                l_max_read_amount := l_max_read_amount-1;
              END IF;
             -- bug 12593967 Ends

              dbms_lob.read (p_article_text, l_max_read_amount, l_read_start_position, l_temp_art_text);-- dbms_lob returns in chars
              --special_char_decoders(l_temp_art_text);
              --dbms_output.put_line(' read clob amount = ' || l_max_read_amount|| 'l_read_start_position = ' || l_read_start_position);

              l_read_start_position := l_read_start_position + l_max_read_amount; -- in chars

              l_amount_left_to_read := l_amount_left_to_read - l_max_read_amount; -- in chars
            -- made changes for bug3697706 june 17th 2004 checking for 3333 instead of 8000
            elsif l_amount_left_to_read < 3333 then
              --dbms_output.put_line(' if length to read is less than 4000');
              dbms_lob.read(p_article_text, l_amount_left_to_read, l_read_start_position, l_temp_art_text); -- in chars.
              --special_char_decoders(l_temp_art_text);
              l_amount_left_to_read := 0;
            end if;
         elsif l_tag_not_closed_read_more
         then
            --dbms_output.put_line(' if tag not closed');
             -- made changes for bug3697706 june 17th 2004 checking for 3333 instead of 8000
            if( (length(l_temp_tag_unclosed) + l_amount_left_to_read)< 3333) -- in chars
            then
              --dbms_output.put_line(' if tag not ***1 ');
              dbms_lob.read(p_article_text, l_amount_left_to_read, l_read_start_position, l_temp_art_text);
              --special_char_decoders(l_temp_art_text);
              l_temp_art_text := l_temp_tag_unclosed || l_temp_art_text;
              --dbms_output.put_line(' if tag not ***1  -- ' || l_amount_left_to_read ||'readstart' || l_read_start_position );

              l_amount_left_to_read := 0;
            elsif( (length(l_temp_tag_unclosed) + l_amount_left_to_read)> 3333)
            then
              l_max_read_amount := l_max_read_amount - length(l_temp_tag_unclosed);

              --dbms_output.put_line(' if tag not ***2 ');
              dbms_lob.read(p_article_text, l_max_read_amount , l_read_start_position, l_temp_art_text);
              --special_char_decoders(l_temp_art_text);
              l_temp_art_text := l_temp_tag_unclosed || l_temp_art_text;
              l_read_start_position := l_read_start_position + l_max_read_amount;

              l_amount_left_to_read := l_amount_left_to_read - l_max_read_amount;

            end if;
         end if;

       WHILE INSTR(l_temp_art_text,'[@',1,1) <> 0 LOOP
          l_tag_start_postion  :=  INSTR(l_temp_art_text,'[@',1,1);
          l_tag_end_postion    :=  INSTR(l_temp_art_text,'@]',1,1);

          if l_tag_end_postion = 0  and l_amount_left_to_read > 0 then
             l_tag_not_closed_read_more := true;
             exit;
          end if;
          if l_tag_end_postion = 0  and l_amount_left_to_read = 0  then
             raise G_VAR_NOT_CLOSED;
          end if;
          if l_tag_end_postion <> 0  then
             l_tag_not_closed_read_more := false;
             if (l_tag_end_postion - l_tag_start_postion)  > 150 then
                 l_extracted_var_name := SUBSTR(l_temp_art_text,(l_tag_start_postion+2),150 );
                 RAISE G_VAR_NOT_FOUND;
             end if;
             l_extracted_var_name := SUBSTR(l_temp_art_text,(l_tag_start_postion+2),(l_tag_end_postion - (l_tag_start_postion+2)) );

            find_variables(
            p_extracted_var_name  => l_extracted_var_name,
            p_intent              => p_article_intent,
            p_language            => p_language,
		  p_batch_number        => p_batch_number,
            x_variables_tbl       => x_variables_tbl,
            p_xml_tag             => l_xml_tag,
            x_return_status       => l_return_status) ;
               --dbms_output.put_line(' Calling module ret sts ' || l_return_status);

            IF (l_return_status = G_VAR_NOT_FOUND_RET_STS) THEN
                --dbms_output.put_line(' VAR NOT FOUND 2 ');
               l_xml_tag := SUBSTR(l_temp_art_text,l_tag_start_postion,((l_tag_end_postion+ 1 )- l_tag_start_postion));
               l_invalid_var_intent := G_VAR_NOT_FOUND_RET_STS;
            ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
            END IF;

          end if;
          if (l_art_text_with_tags is null and dbms_lob.getlength(p_dest_clob)
= 0 )then

             l_art_text_with_tags := SUBSTR(l_temp_art_text,1,(l_tag_start_postion - 1 ));

          else
             --dbms_output.put_line(' art text is not null 22');
             l_append_str :=  SUBSTR(l_temp_art_text,1,(l_tag_start_postion -1))
;

          end if;
          check_length_n_append(
            p_append_str          => l_append_str,
            p_xml_tag             => l_xml_tag,
            p_art_text_with_tags  => l_art_text_with_tags,
            p_clob_large          => p_dest_clob,
            x_return_status       => x_return_status);

            l_temp_art_text := SUBSTR(l_temp_art_text,(l_tag_end_postion + 2));
        END LOOP ;

        if (l_tag_not_closed_read_more) then
           l_append_str := SUBSTR(l_temp_art_text,1,(l_tag_start_postion -1));
           l_xml_tag    :=  null;
           l_temp_tag_unclosed :=    SUBSTR(l_temp_art_text,l_tag_start_postion)
;

        else
           l_append_str :=  l_temp_art_text;
           l_xml_tag    :=  null;

        end if;
        check_length_n_append(
            p_append_str          => l_append_str,
            p_xml_tag             => l_xml_tag,
            p_art_text_with_tags  => l_art_text_with_tags,
            p_clob_large          => p_dest_clob,
             x_return_status       => x_return_status);
     End Loop;

    l_check_length := length(l_art_text_with_tags);
    --dbms_output.put_line(' lessthat 4000  - 66');
    if (l_check_length > 0) then
      --dbms_output.put_line(' flushing into clob ');
      dbms_lob.writeappend ( p_dest_clob, l_check_length, l_art_text_with_tags);

    end if;
    --dbms_output.put_line(' here 99');


     if (l_invalid_var_intent = G_VAR_NOT_FOUND_RET_STS) then
        --dbms_output.put_line(' VAR NOT FOUND 3 ');
       x_return_status := G_RET_STS_ERROR;
     elsif ((not (nvl(l_return_status,'S') = G_VAR_NOT_FOUND_RET_STS) )
               and (p_replace_text = 'Y') ) then
        p_dest_clob_length :=  DBMS_LOB.GETLENGTH(p_dest_clob);
        if (p_calling_mode = 'CALLED_FROM_CREATE_UPDATE') then
        --  DBMS_LOB.COPY(p_article_text, p_dest_clob, p_dest_clob_length, 1, 1);
        --  DBMS_LOB.TRIM(p_article_text,p_dest_clob_length);
          x_return_status := G_RET_STS_SUCCESS;
        else
          x_return_status := G_RET_STS_SUCCESS;
        end if;
    else
        x_return_status := G_RET_STS_SUCCESS;
    end if;

    --dbms_lob.freetemporary(l_clob);
    --dbms_lob.freetemporary(p_dest_clob);
    okc_debug.log('100: Leaving parse_n_replace_text', 2);
    EXCEPTION
    WHEN  G_VAR_NOT_FOUND then
         --dbms_output.put_line(' VAR NOT FOUND 1 ');
          x_return_status :=   G_VAR_NOT_FOUND_RET_STS;
          OKC_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
            p_msg_name      => 'OKC_ART_VAR_NOT_FOUND',
                              p_token1       => 'VARIABLE',
                              p_token1_value => l_extracted_var_name
                  );
    WHEN NO_DATA_FOUND
    THEN
       BEGIN
         x_return_status := G_RET_STS_ERROR;
         OKC_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                 p_msg_name      => 'OKC_ART_VAR_NOT_FOUND'
                 );

       END;
     when G_VAR_NOT_CLOSED
     then
          x_return_status := G_RET_STS_ERROR;
          OKC_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                   p_msg_name      => 'OKC_ART_VAR_NOT_CLOSED'
                   );
     WHEN OTHERS
     THEN
          x_return_status := G_RET_STS_UNEXP_ERROR;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
   END parse_n_replace_text;


  ---------------------------------------
  -- PROCEDURE This is the Autogeneration API  --
  ---------------------------------------
  -- If the profile option should be refreshed then
  -- please set p_seq_type_info_only as 'Y'
  PROCEDURE GET_ARTICLE_SEQ_NUMBER
       (p_article_number          IN VARCHAR2 := NULL,
        p_seq_type_info_only      IN VARCHAR2 := 'N',
        p_org_id                  IN NUMBER,
        x_article_number          OUT NOCOPY VARCHAR2,
        x_doc_sequence_type       OUT NOCOPY VARCHAR2,
        x_return_status           OUT NOCOPY VARCHAR2
        ) IS
  l_doc_sequence_value    NUMBER;
  l_doc_sequence_id       NUMBER;
  l_set_Of_Books_id       NUMBER;
  l_org_id                NUMBER;
  l_doc_category_code     FND_DOC_SEQUENCE_CATEGORIES.CODE%TYPE;
  l_seqassid              FND_DOC_SEQUENCE_ASSIGNMENTS.DOC_SEQUENCE_ASSIGNMENT_ID%TYPE;
  l_Trx_Date            DATE;
  l_db_sequence_name      FND_DOCUMENT_SEQUENCES.DB_SEQUENCE_NAME%TYPE;
  l_doc_sequence_type   FND_DOCUMENT_SEQUENCES.TYPE%TYPE;
  l_doc_sequence_name     FND_DOCUMENT_SEQUENCES.NAME%TYPE;
  l_Prd_Tbl_Name          FND_DOCUMENT_SEQUENCES.TABLE_NAME%TYPE;
  l_Aud_Tbl_Name    FND_DOCUMENT_SEQUENCES.AUDIT_TABLE_NAME%TYPE;
  l_Msg_Flag          FND_DOCUMENT_SEQUENCES.MESSAGE_FLAG%TYPE;
  l_result    NUMBER;



       CURSOR l_get_sob_csr (cp_org_id IN NUMBER ) IS
         SELECT OI2.ORG_INFORMATION3 SET_OF_BOOKS_ID
           FROM HR_ORGANIZATION_INFORMATION OI1,
                HR_ORGANIZATION_INFORMATION OI2,
                HR_ALL_ORGANIZATION_UNITS OU
          WHERE OI1.ORGANIZATION_ID = OU.ORGANIZATION_ID AND
                OI2.ORGANIZATION_ID = OU.ORGANIZATION_ID AND
                OI1.ORG_INFORMATION_CONTEXT = 'CLASS' AND
                OI2.ORG_INFORMATION_CONTEXT = 'Operating Unit Information' AND
                OI1.ORG_INFORMATION1 = 'OPERATING_UNIT'AND
                OI1.ORGANIZATION_ID = cp_org_id
                ;

       CURSOR l_ensure_unique_csr (cp_article_number IN VARCHAR2, cp_org_id IN NUMBER ) IS
         SELECT ARTICLE_NUMBER
           FROM OKC_ARTICLES_ALL
          WHERE ARTICLE_NUMBER = cp_article_number
            AND ORG_ID = cp_org_id
            AND ROWNUM < 2;

   -- Added for Bug 4643332
   -- Need to get the Seq Category from EIT instead from Profile
   CURSOR l_clause_seq_csr (cp_org_id  IN NUMBER) IS
     SELECT ORG_INFORMATION8 CLAUSE_SEQ
            --nvl(ORG_INFORMATION8,'-99') CLAUSE_SEQ
       FROM HR_ORGANIZATION_INFORMATION
      WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
        AND ORGANIZATION_ID  = cp_org_id
      ;

    l_row_notfound    BOOLEAN := FALSE;
    l_row_notfound1   BOOLEAN := FALSE;
    l_article_number OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE := NULL;

    BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --Bug 3832007: p_req_type_info_only is 'Y' only when it's called from UI
    --for the rest of case (migration, import, create_article api), cached value will match
    --with session context that API is called
    --For performance, following steps are executed only when this is called from UI
    --as user may change responsibility or org frequently during same session
    IF p_seq_type_info_only = 'Y' THEN
      G_profile_doc_seq :=  fnd_profile.value('UNIQUE:SEQ_NUMBERS');
      G_doc_category_code := substr(Fnd_Profile.Value('OKC_ARTICLE_DOC_SEQ_CATEGORY'),1,30) ;
	 -- MOAC
	 G_CURRENT_ORG_ID := mo_global.get_current_org_id();
	/*
      OPEN cur_org_csr;
      FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
      CLOSE cur_org_csr;
	*/
    END IF;

    IF G_profile_doc_seq = 'N' Then
        x_article_number := p_article_number;
        x_doc_sequence_type := G_profile_doc_seq;
        return;
    END IF;

--  This is for other cases
-- Need to derive the set of books for the org in order to derive the sequence
--
-- MOAC
    if p_org_id IS NOT NULL Then
       l_org_id := p_org_id;
    else
       if G_CURRENT_ORG_ID IS NULL Then
	     Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
          RAISE FND_API.G_EXC_ERROR ;
       else
	     l_org_id := G_CURRENT_ORG_ID;
	  end if;
    end if;
/*
    IF p_org_id is NULL THEN
        l_org_id := G_CURRENT_ORG_ID;
    ELSE
        l_org_id := p_org_id;
    END IF;
*/
    --dbms_output.put_line('P Org Id:'|| p_org_id);
    --dbms_output.put_line('Current Org Id:'|| G_CURRENT_ORG_ID);
    OPEN l_get_sob_csr (l_org_id);
    FETCH l_get_sob_csr into l_set_of_books_id;
    l_row_notfound := l_get_sob_csr%NOTFOUND;
    CLOSE l_get_sob_csr;
    IF l_row_notfound THEN
       Okc_Api.Set_Message(G_APP_NAME,'OKC_ART_INV_SOB_ID');
       RAISE FND_API.G_EXC_ERROR ;
    END IF;
    l_row_notfound    := FALSE;
    -- New changes for MOAC Bug 4643332
    -- get seq id from EIT
    OPEN l_clause_seq_csr (l_org_id);
    FETCH l_clause_seq_csr into l_doc_category_code;
    l_row_notfound1 := l_clause_seq_csr%NOTFOUND;
    CLOSE l_clause_seq_csr;
    IF l_row_notfound1 THEN
       Okc_Api.Set_Message(G_APP_NAME,'OKC_ART_SEQ_CAT_NOT_DEFINED');
       RAISE FND_API.G_EXC_ERROR ;
    END IF;
    l_row_notfound1    := FALSE;
    --l_doc_category_code := G_DOC_CATEGORY_CODE; -- Commented for new changes for MOAC
    --dbms_output.put_line('Org Id:'||p_org_id||'CAT: '||l_doc_category_code||'SOB: '||l_set_of_books_id);
    l_result :=   fnd_seqnum.get_seq_info(
                                         app_id   =>  510 ,
                                         cat_code   =>  l_doc_category_code,
                                         sob_id   =>  l_set_of_books_id,
                                         met_code =>  NULL,
                                         trx_date =>  sysdate,
                                         docseq_id  =>  l_doc_sequence_id,
                                         docseq_type  =>  l_doc_sequence_type,
                                         docseq_name  =>  l_doc_sequence_name,
                                         db_seq_name  =>  l_db_sequence_name,
                                         seq_ass_id =>  l_seqassid,
                                         prd_tab_name =>  l_Prd_Tbl_Name,
                                         aud_tab_name =>  l_Aud_Tbl_Name,
                                         msg_flag =>  l_msg_flag,
                                         suppress_error =>  'N' ,
                                         suppress_warn  =>  'Y'
                                  );
     x_doc_sequence_type := l_doc_sequence_type;
     --dbms_output.put_line('Info result is: '|| l_result ||'*'|| l_doc_sequence_type);
     IF l_result <>  FND_SEQNUM.SEQSUCC   THEN
        /* Commented following IF - Bug 3542035 , This IF is not reqd */
        --IF l_result = FND_SEQNUM.NOTUSED THEN
          OKC_API.set_message(G_APP_NAME,'OKC_ART_MISS_DOC_SEQ');
        --END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF p_seq_type_info_only = 'Y' THEN
           return;
     END IF;
-- Continue with the rest if article number is also desired


    IF ( x_doc_sequence_type <> 'M')  THEN
       l_result := fnd_seqnum.get_seq_val(
                                         app_id        => 510,
                                         cat_code      =>  l_doc_category_code,
                                         sob_id        =>  l_set_of_books_id,
                                         met_code      =>  null,
                                         trx_date      =>  sysdate,
                                         seq_val       =>  l_doc_sequence_value,
                                         docseq_id    =>  l_doc_sequence_id);
     --dbms_output.put_line('Number result is: '|| to_char(l_result) ||'*'|| l_doc_sequence_value);
        IF l_result <>  0   THEN
        RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_article_number := TO_CHAR(l_doc_sequence_value);
    END IF;
        OPEN l_ensure_unique_csr (x_article_number, l_org_id);
        FETCH l_ensure_unique_csr into l_article_number;
        l_row_notfound := l_ensure_unique_csr%NOTFOUND;
        CLOSE l_ensure_unique_csr;
        IF l_row_notfound THEN
           NULL;   -- dups do not exist.
        ELSE
           Okc_Api.Set_Message(G_APP_NAME,'OKC_ART_ART_NUM_EXIST');
           RAISE FND_API.G_EXC_ERROR ;
        END IF;
     ELSIF (x_doc_sequence_type = 'M') THEN
       x_article_number := p_article_number;
     END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving get article number: OKC_API.G_EXCEPTION_ERROR Exception', 2);
         --dbms_output.put_line('2400: Leaving get article number: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
     WHEN OTHERS THEN
          /*------------------------------------------+
                |  No document assignment was found.       |
                |  Generate an error if document numbering |
                |  is mandatory.                           |
          +------------------------------------------*/
         --dbms_output.put_line('Get_Doc_Seq: ' || 'no_data_found raised'||G_profile_doc_seq);
   IF   (G_profile_doc_seq = 'A' ) THEN
      OKC_API.Set_Message( 'FND','UNIQUE-ALWAYS USED');
   END IF;
         x_return_status := G_RET_STS_ERROR;
         IF l_get_sob_csr%ISOPEN THEN
            CLOSE l_get_sob_csr;
         END IF;
         IF l_ensure_unique_csr%ISOPEN THEN
            CLOSE l_ensure_unique_csr;
         END IF;

   END GET_ARTICLE_SEQ_NUMBER;

-- The following is a private API and should not be called by itself.
  ---------------------------------------------------------------------------
  -- PROCEDURE delete_article_version
  ---------------------------------------------------------------------------
  PROCEDURE delete_article_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_version_id         IN NUMBER,
    p_standard_yn                IN VARCHAR2 := 'Y',
    p_only_version               IN VARCHAR2 := 'T',
    p_adoption_type              IN VARCHAR2 := NULL,
    p_object_version_number      IN NUMBER := NULL
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_object_version_number         NUMBER := NULL;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_delete_article_version';
    l_row_notfound                BOOLEAN := FALSE;


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Entered delete_article_version', 2);
    END IF;
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id() ;
    /*
    OPEN cur_org_csr;
    FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
    CLOSE cur_org_csr;
    */

    -- Standard Start of API savepoint
    SAVEPOINT g_delete_article_version_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Deleting A Row
    --------------------------------------------
    OKC_ARTICLE_VERSIONS_PVT.Delete_Row(
      x_return_status              =>   x_return_status,
      p_article_version_id         => p_article_version_id,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

-- Do not support Simple API for variable deletion or update. This is the only
-- API from which this will be called.


    DELETE FROM OKC_ARTICLE_VARIABLES
      WHERE ARTICLE_VERSION_ID = p_article_version_id;

-- If a local article version is deleted the attached global article version
-- becomes available in the adoption table with adoption type as "AVAILABLE".
-- However this is only in case of LOCALIZATION of local article versions.
-- In the case of a local article version being created as a new version
-- from a prior version we delete the adoption row for this version.

-- MOAC
   IF G_CURRENT_ORG_ID IS NULL Then
      Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF (G_CURRENT_ORG_ID = G_GLOBAL_ORG_ID OR
        G_CURRENT_ORG_ID = -99 OR
        G_GLOBAL_ORG_ID = -99 ) THEN
        NULL;
   ELSIF p_standard_yn = 'Y' AND
      p_adoption_type <> 'LOCAL' Then
      OKC_ADOPTIONS_GRP.DELETE_LOCAL_ADOPTION_DETAILS(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_only_local_version          => p_only_version,
         p_local_article_version_id    => p_article_version_id,
         p_local_org_id                 => G_CURRENT_ORG_ID
        );
   END IF;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
    -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

   IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving delete_article_version', 2);
   END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving delete_article_version: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_delete_article_version_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2500: Leaving delete_article_version: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_delete_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2600: Leaving delete_article_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_delete_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END delete_article_version;

  PROCEDURE validate_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_earlier_adoption_type           OUT NOCOPY VARCHAR2,
    x_earlier_version_id           OUT NOCOPY NUMBER,
    x_earlier_version_number     OUT NOCOPY NUMBER,

    -- Article Attributes
    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    -- Article Version Attributes
    p_article_version_id         IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text             IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
--Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
    p_article_text_in_word       IN BLOB DEFAULT NULL,
    --CLM
    p_variable_code                IN VARCHAR2 DEFAULT NULL
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_validate_article';
    l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_article_status              OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered validate_article', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_validate_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Article Validation
    --------------------------------------------
    OKC_ARTICLES_ALL_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      p_import_action              => p_import_action,
      x_return_status              => l_return_status,
      p_article_id                 => p_article_id,
      p_article_title              => p_article_title,
      p_org_id                     => p_org_id,
      p_article_number             => p_article_number,
      p_standard_yn                => p_standard_yn,
      p_article_intent             => p_article_intent,
      p_article_language           => p_article_language,
      p_article_type               => p_article_type,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2

    );
  --dbms_output.put_line('API Art Msg data:' || x_msg_data);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    --------------------------------------------
    -- Calling Simple API for Article Version Validation
    --------------------------------------------
  -- UIs may be returning EXPIRED status (derived) from VOs.
    IF p_article_status = 'EXPIRED' THEN
       l_article_status := 'APPROVED';
    ELSE
       l_article_status := p_article_status;
    END IF;
    OKC_ARTICLE_VERSIONS_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      p_import_action              => p_import_action,
      x_return_status              => x_return_status,
      x_earlier_adoption_type         => x_earlier_adoption_type,
      x_earlier_version_id         => x_earlier_version_id,
      x_earlier_version_number         => x_earlier_version_number,
      p_article_version_id         => p_article_version_id,
      p_article_id                 => p_article_id,
      p_article_version_number     => p_article_version_number,
      p_article_text               => p_article_text,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => l_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
--Clause Editing
      p_edited_in_word             => p_edited_in_word,
      p_article_text_in_word       => p_article_text_in_word,
--clm
      p_variable_code              => p_variable_code
      );
  --dbms_output.put_line('API Ver Msg data:' || x_msg_data);
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    x_return_status := l_return_status;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving validate_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Validate_Article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_validate_article_GRP;
      l_return_status := G_RET_STS_ERROR ;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );
  --dbms_output.put_line('Msg data2:' || x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Validate_Article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_validate_article_GRP;
      l_return_status := G_RET_STS_UNEXP_ERROR ;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Validate_Article because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_validate_article_GRP;
      l_return_status := G_RET_STS_UNEXP_ERROR ;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END validate_article;

  -------------------------------------
  -- PROCEDURE create_article
  -------------------------------------
  PROCEDURE create_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_article_title              IN VARCHAR2,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
    x_article_id                 OUT NOCOPY NUMBER,
    x_article_number             OUT NOCOPY VARCHAR2,
    -- Article Version Attributes
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text             IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
    p_v_orig_system_reference_code IN VARCHAR2,
    p_v_orig_system_reference_id1  IN VARCHAR2,
    p_v_orig_system_reference_id2  IN VARCHAR2,
    p_global_article_version_id    IN NUMBER := NULL,
--Clause Editing
    p_edited_in_word               IN VARCHAR2 DEFAULT 'N',
    p_article_text_in_word         IN BLOB DEFAULT NULL,
    --CLM
    p_variable_code                IN VARCHAR2 DEFAULT NULL,
    x_article_version_id         OUT NOCOPY NUMBER
  ) IS

    l_api_version                CONSTANT NUMBER := 1;
    l_api_name                   CONSTANT VARCHAR2(30) := 'g_create_article';
    l_object_version_number      OKC_ARTICLES_ALL.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_doc_sequence_type          VARCHAR2(1);
    l_article_number             OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;
    l_created_by                 OKC_ARTICLES_ALL.CREATED_BY%TYPE;
    l_creation_date              OKC_ARTICLES_ALL.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_ARTICLES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_ARTICLES_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_ARTICLES_ALL.LAST_UPDATE_DATE%TYPE;
  BEGIN

       --dbms_output.put_line('600: Entered create_article from copy');
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered create_article', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_create_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
       --dbms_output.put_line('600: Entered create_article NOT Compatible');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id();
   /*
    OPEN cur_org_csr;
    FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
    CLOSE cur_org_csr;
    */

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       --dbms_output.put_line('600: Entered create_article message init');
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
       --dbms_output.put_line('600: Entered create_article from copy status is'||x_return_status);
-- MOAC
   IF G_CURRENT_ORG_ID IS NULL Then
      Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

  -- Fix for bug# 5158268. The variable l_article_number should be initialized with p_article_number
      l_article_number := p_article_number;
-- Generate article_number for articles based on autonumbering is required or not
    IF p_standard_yn = 'Y' Then
      G_doc_category_code  := substr(Fnd_Profile.Value('OKC_ARTICLE_DOC_SEQ_CATEGORY'),1,30) ;
      G_profile_doc_seq :=  fnd_profile.value('UNIQUE:SEQ_NUMBERS');
      GET_ARTICLE_SEQ_NUMBER
       (p_article_number => p_article_number,
        p_seq_type_info_only      => 'N',
        p_org_id  => G_CURRENT_ORG_ID,
        x_article_number => l_article_number,
        x_doc_sequence_type => l_doc_sequence_type,
        x_return_status => x_return_status);

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
    END IF;
    --------------------------------------------
    -- Calling Simple API for Creating Article Row
    --------------------------------------------
    OKC_ARTICLES_ALL_PVT.Insert_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_article_title              => p_article_title,
      p_org_id                     => G_CURRENT_ORG_ID,
      p_article_number             => l_article_number,
      p_standard_yn                => p_standard_yn,
      p_article_intent             => p_article_intent,
      p_article_language           => p_article_language,
      p_article_type               => p_article_type,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_cz_transfer_status_flag    => p_cz_transfer_status_flag,
      x_article_number             => x_article_number,
      x_article_id                 => x_article_id
    );
--dbms_output.put_line('In Create - x_article_id is '||x_article_id);
--dbms_output.put_line('In Create - x_return_status is '||x_return_status);
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    --------------------------------------------
    -- Calling Group API for Creating Article Version Row
    --------------------------------------------
  Create_Article_Version(
    p_api_version                => p_api_version,
    p_init_msg_list              => p_init_msg_list,
    p_validation_level           => p_validation_level,
    p_commit                     => p_commit,
    p_global_article_version_id  => p_global_article_version_id,
    p_article_intent             => p_article_intent,
    p_standard_yn                => p_standard_yn,

    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,

    p_article_id                 => x_article_id,
    p_article_text               => p_article_text,
    p_provision_yn               => p_provision_yn,
    p_insert_by_reference        => p_insert_by_reference,
    p_lock_text                  => p_lock_text,
    p_global_yn                  => p_global_yn,
    p_article_language           => p_article_language,
    p_orig_system_reference_code => p_v_orig_system_reference_code,
    p_orig_system_reference_id1  => p_v_orig_system_reference_id1,
    p_orig_system_reference_id2  => p_v_orig_system_reference_id2,
    p_article_status             => p_article_status,
    p_sav_release                => p_sav_release,
    p_start_date                 => p_start_date,
    p_end_date                   => p_end_date,
    p_std_article_version_id     => p_std_article_version_id,
    p_display_name               => p_display_name,
    p_translated_yn              => p_translated_yn,
    p_article_description        => p_article_description,
    p_date_approved              => p_date_approved,
    p_default_section            => p_default_section,
    p_reference_source           => p_reference_source,
    p_reference_text             => p_reference_text,
    p_additional_instructions    => p_additional_instructions,
    p_variation_description      => p_variation_description,
    p_date_published             => p_date_published,
    p_attribute_category         => p_attribute_category,
    p_attribute1                 => p_attribute1,
    p_attribute2                 => p_attribute2,
    p_attribute3                 => p_attribute3,
    p_attribute4                 => p_attribute4,
    p_attribute5                 => p_attribute5,
    p_attribute6                 => p_attribute6,
    p_attribute7                 => p_attribute7,
    p_attribute8                 => p_attribute8,
    p_attribute9                 => p_attribute9,
    p_attribute10                => p_attribute10,
    p_attribute11                => p_attribute11,
    p_attribute12                => p_attribute12,
    p_attribute13                => p_attribute13,
    p_attribute14                => p_attribute14,
    p_attribute15                => p_attribute15,
--Clause Editing
    p_edited_in_word             => p_edited_in_word,
    p_article_text_in_word       => p_article_text_in_word,
    --clm
    p_variable_code              => p_variable_code,

    x_article_version_id         => x_article_version_id

  ) ;
--dbms_output.put_line('In Create - x_article_version_id is '||x_article_version_id);
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Leaving create_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('800: Leaving create_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving create_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1000: Leaving create_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_create_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END create_article;
  ---------------------------------------------------------------------------
  -- PROCEDURE lock_article
  ---------------------------------------------------------------------------
  PROCEDURE lock_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_id                   IN NUMBER,
    p_article_version_id           IN NUMBER,
    p_object_version_number        IN NUMBER := NULL
   ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_lock_article';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Entered lock_article', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_lock_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Locking A Row
    --------------------------------------------
    OKC_ARTICLES_ALL_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_article_id                 => p_article_id,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    Lock_Article_Version(
    p_api_version                  => p_api_version ,
    p_init_msg_list                => p_init_msg_list,

    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,

    p_article_version_id           => p_article_version_id,
    p_object_version_number        => p_object_version_number
   );

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1200: Leaving lock_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1300: Leaving lock_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_lock_article_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1400: Leaving lock_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_lock_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1500: Leaving lock_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_lock_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END lock_article;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_article
  ---------------------------------------------------------------------------
  PROCEDURE update_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
    p_object_version_number      IN NUMBER   := NULL,
    -- Article Version Attributes
    p_article_version_id         IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text             IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_v_orig_system_reference_code IN VARCHAR2,
    p_v_orig_system_reference_id1  IN VARCHAR2,
    p_v_orig_system_reference_id2  IN VARCHAR2,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
    p_v_object_version_number    IN NUMBER := NULL,
--Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
    p_article_text_in_word       IN BLOB DEFAULT NULL,
    --CLM
    p_variable_code              IN VARCHAR2 DEFAULT NULL
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_update_article';
    l_article_intent               OKC_ARTICLES_ALL.ARTICLE_INTENT%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Entered update_article', 2);
       okc_debug.log('1700: Locking row', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id() ;
    /*
    OPEN cur_org_csr;
    FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
    CLOSE cur_org_csr;
    */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- MOAC
   IF G_CURRENT_ORG_ID IS NULL Then
      Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

    --------------------------------------------
    -- Calling Simple API for Updating A Row
    --------------------------------------------
    OKC_ARTICLES_ALL_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      x_article_intent              => l_article_intent,
      p_article_id                 => p_article_id,
      p_article_title              => p_article_title,
      p_org_id                     => G_CURRENT_ORG_ID,
      p_article_number             => p_article_number,
      p_standard_yn                => p_standard_yn,
      p_article_intent             => p_article_intent,
      p_article_language           => p_article_language,
      p_article_type               => p_article_type,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_cz_transfer_status_flag    => p_cz_transfer_status_flag,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    --dbms_output.put_line('After:'||p_article_language);

    Update_Article_Version(
      p_api_version                  => p_api_version ,
      p_init_msg_list                => p_init_msg_list,
      p_validation_level             => p_validation_level,
      p_commit                       => p_commit,
      p_article_intent               => l_article_intent,

      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,

      p_article_version_id         => p_article_version_id,
      p_article_id                 => p_article_id,
      p_orig_system_reference_code => p_v_orig_system_reference_code,
      p_orig_system_reference_id1  => p_v_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_v_orig_system_reference_id2,
      p_article_text               => p_article_text,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => p_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text             => p_reference_text,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_object_version_number      => p_v_object_version_number,
--Clause Editing
      p_edited_in_word             => p_edited_in_word,
      p_article_text_in_word       => p_article_text_in_word,
      --clm
      p_variable_code              => p_variable_code
      );

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1800: Leaving update_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1900: Leaving update_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_update_article_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2000: Leaving update_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_update_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2100: Leaving update_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_update_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END update_article;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_article
  ---------------------------------------------------------------------------
  PROCEDURE delete_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_version_id         IN NUMBER,
    p_object_version_number      IN NUMBER := NULL
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_delete_article';
    l_status                       VARCHAR2(30) ;
    l_standard_yn                  VARCHAR2(1) ;
    l_only_version                 VARCHAR2(1) := 'T';
    l_adoption_type                OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;
    l_dummy1                       VARCHAR2(1) := '?';

    Cursor l_status_csr (cp_article_id IN NUMBER,
                         cp_article_version_id IN NUMBER) IS
            SELECT article_status,standard_yn, adoption_type
            FROM okc_article_versions av,okc_articles_all aa
            WHERE  aa.article_id = av.article_id
            AND    av.article_id = cp_article_id
            AND    av.article_version_id = cp_article_version_id;


    CURSOR l_only_version_csr(cp_article_id IN NUMBER,
                              cp_article_version_id IN NUMBER) IS
     SELECT 'F'
         FROM OKC_ARTICLE_VERSIONS A
     WHERE A.ARTICLE_ID = cp_article_id
       AND A.ARTICLE_VERSION_ID <> cp_article_version_id
       AND rownum < 2 ;

    CURSOR l_template_csr (cp_article_id IN NUMBER) is
            SELECT '1' from OKC_K_ARTICLES_B
            WHERE sav_sae_id = cp_article_id
            AND   document_type = 'TEMPLATE';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Entered delete_article', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_delete_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    OPEN l_status_csr (p_article_id, p_article_version_id);
    FETCH l_status_csr INTO l_status,l_standard_yn, l_adoption_type;
    CLOSE l_status_csr;

    IF l_standard_yn = 'Y' THEN
       IF l_status NOT IN ( 'DRAFT','REJECTED') THEN
          IF (l_debug = 'Y') THEN
             Okc_Debug.Log('2200: - Article Status is not Draft or Rejected,It cannot be deleted',2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_DEL_INV_STATUS');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          OPEN l_only_version_csr (p_article_id, p_article_version_id);
          FETCH l_only_version_csr INTO l_only_version;
          CLOSE l_only_version_csr;
          --dbms_output.put_line('Only version available:' || l_only_version ||
          --                           p_article_id ||'*'||p_article_version_id);
          IF l_only_version = 'T'  THEN
            IF (l_debug = 'Y') THEN
                Okc_Debug.Log('2200: - Article Version is the only version',2);
            END IF;
            OPEN l_template_csr (p_article_id);
            FETCH l_template_csr INTO l_dummy1;
            CLOSE l_template_csr;
          --dbms_output.put_line('Used in Template:' || l_dummy1);
            IF l_dummy1 = '1'  THEN
              IF (l_debug = 'Y') THEN
                Okc_Debug.Log('2200: - Article Version is already Used in the Templates',2);
              END IF;
              Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_USED_IN_TEMPL');
              x_return_status := G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;
		  ELSE -- Check if it used in any of the Rules (Bug 3971186)
		    IF (OKC_XPRT_UTIL_PVT.ok_to_delete_clause(p_article_id) = 'N') THEN
                 IF (l_debug = 'Y') THEN
                   Okc_Debug.Log('2200: - Article Version is already Used in the Rules',2);
                 END IF;
                 Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_USED_IN_RULES');
                 x_return_status := G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 OKC_ARTICLES_ALL_PVT.Delete_Row(
                   x_return_status              =>   x_return_status,
                   p_article_id                 => p_article_id,
                   p_object_version_number      => NULL
                   );
                 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR ;
                 END IF;
                 DELETE FROM OKC_ARTICLE_RELATNS_ALL -- delete all relationships
                 WHERE source_article_id = p_article_id OR
                       target_article_id = p_article_id;
                 DELETE FROM OKC_FOLDER_CONTENTS -- delete all folder contents
                 WHERE member_id = p_article_id ;
              END IF;
            END IF;
         END IF;
       END IF;
    ELSE -- in the case of non standard articles
       OKC_ARTICLES_ALL_PVT.Delete_Row(
          x_return_status              =>   x_return_status,
          p_article_id                 => p_article_id,
          p_object_version_number      => NULL
          );
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
       END IF;
    END IF;
    Delete_Article_Version(
      p_api_version                  => p_api_version ,
      p_init_msg_list                => p_init_msg_list,
      p_commit                       => p_commit,
      p_standard_yn                  => l_standard_yn,
      p_adoption_type                => l_adoption_type,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_article_version_id         => p_article_version_id,
      p_only_version               => l_only_version,
      p_object_version_number      => p_object_version_number
      );

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving delete_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving delete_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      IF l_status_csr%ISOPEN THEN
         CLOSE l_status_csr;
      END IF;
      IF l_only_version_csr%ISOPEN THEN
         CLOSE l_only_version_csr;
      END IF;
      IF l_template_csr%ISOPEN THEN
         CLOSE l_template_csr;
      END IF;
      ROLLBACK TO g_delete_article_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2500: Leaving delete_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      IF l_status_csr%ISOPEN THEN
         CLOSE l_status_csr;
      END IF;
      IF l_only_version_csr%ISOPEN THEN
         CLOSE l_only_version_csr;
      END IF;
      IF l_template_csr%ISOPEN THEN
         CLOSE l_template_csr;
      END IF;
      ROLLBACK TO g_delete_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2600: Leaving delete_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_status_csr%ISOPEN THEN
         CLOSE l_status_csr;
      END IF;
      IF l_only_version_csr%ISOPEN THEN
         CLOSE l_only_version_csr;
      END IF;
      IF l_template_csr%ISOPEN THEN
         CLOSE l_template_csr;
      END IF;
      ROLLBACK TO g_delete_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END delete_article;

  ---------------------------------------
  -- PROCEDURE validate_article_version  --
  ---------------------------------------
  PROCEDURE validate_article_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_earlier_version_id         OUT NOCOPY NUMBER,
    x_earlier_version_number         OUT NOCOPY NUMBER,
    x_earlier_adoption_type          OUT NOCOPY VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2 ,
    p_orig_system_reference_id1  IN VARCHAR2 ,
    p_orig_system_reference_id2  IN VARCHAR2 ,
    p_additional_instructions    IN VARCHAR2 ,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
--Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
    p_article_text_in_word       IN BLOB DEFAULT NULL,
    p_variable_code              IN VARCHAR2 DEFAULT NULL
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_validate_article_version';
    l_earlier_adoption_type       OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered validate_article_version', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_validate_article_version_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Article Version Validation
    --------------------------------------------
    OKC_ARTICLE_VERSIONS_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      p_import_action              => p_import_action,
      x_return_status              => x_return_status,
      x_earlier_adoption_type         => x_earlier_adoption_type,
      x_earlier_version_id         => x_earlier_version_id,
      x_earlier_version_number         => x_earlier_version_number,
      p_article_version_id         => p_article_version_id,
      p_article_id                 => p_article_id,
      p_article_version_number     => p_article_version_number,
      p_article_text               => p_article_text,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => p_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_object_version_number      => NULL,
--Clause Editing
      p_edited_in_word             => p_edited_in_word,
      p_article_text_in_word       => p_article_text_in_word,
      --clm
      p_variable_code              => p_variable_code
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving validate_article_version', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Validate_article_version: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_validate_article_version_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Validate_article_version: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_validate_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Validate_article_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_validate_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END validate_article_version;

  -------------------------------------
  -- PROCEDURE Create_article_version
  -------------------------------------
  PROCEDURE create_article_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_article_intent               IN VARCHAR2 := NULL,
    p_standard_yn                  IN VARCHAR2 := 'Y',
    p_global_article_version_id    IN NUMBER := NULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,

    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
--Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
    p_article_text_in_word       IN BLOB DEFAULT NULL,
    --clm
    p_variable_code              IN VARCHAR2 DEFAULT NULL,

    x_article_version_id         OUT NOCOPY NUMBER

  ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_create_article_version';
    l_object_version_number       OKC_ARTICLE_VERSIONS.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_created_by                  OKC_ARTICLE_VERSIONS.CREATED_BY%TYPE;
    l_creation_date               OKC_ARTICLE_VERSIONS.CREATION_DATE%TYPE;
    l_last_updated_by             OKC_ARTICLE_VERSIONS.LAST_UPDATED_BY%TYPE;
    l_last_update_login           OKC_ARTICLE_VERSIONS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date            OKC_ARTICLE_VERSIONS.LAST_UPDATE_DATE%TYPE;
    l_adoption_type               OKC_ARTICLE_ADOPTIONS.ADOPTION_TYPE%TYPE;
    l_earlier_adoption_type       OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;
    l_variable_code_tbl           variable_code_tbl_type;
    l_org_id                      NUMBER;
    l_global_article_version_id   NUMBER;
    l_global_version_id_out       NUMBER;
    l_local_org_id                NUMBER;
    l_local_article_version_id    NUMBER;
    l_earlier_version_id          NUMBER;
    l_row_notfound                BOOLEAN := TRUE;
    l_rowid                       ROWID;
    l_article_text                CLOB;
    l_article_status               OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE;
    i                             NUMBER := 0;
    l_clob CLOB;
    -- Bug 3917777
    l_user_id NUMBER := FND_GLOBAL.USER_ID;
    l_login_id NUMBER := FND_GLOBAL.LOGIN_ID;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered create_article_version', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_create_article_version_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id() ;
    /*
    OPEN cur_org_csr;
    FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
    CLOSE cur_org_csr;
    */
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- MOAC
       IF G_CURRENT_ORG_ID IS NULL Then
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
          RAISE FND_API.G_EXC_ERROR ;
   END IF;

  l_article_text := p_article_text;
  DBMS_LOB.CREATETEMPORARY(l_clob,true);
  parse_n_replace_text(
    p_api_version                  => p_api_version,
    p_init_msg_list                => p_init_msg_list,
    p_article_text                 => l_article_text,
    p_dest_clob                    => l_clob,
    p_calling_mode                 => 'CALLED_FROM_CREATE_UPDATE',
    p_replace_text                 => 'Y',
    p_article_intent               => p_article_intent,
    p_language                     => USERENV('LANG'),
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    x_variables_tbl                => l_variable_code_tbl
   ) ;
   --dbms_lob.freetemporary(l_clob);
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
  -- UIs may be returning EXPIRED status (derived) from VOs.
    IF p_article_status = 'EXPIRED' THEN
       l_article_status := 'APPROVED';
    ELSE
       l_article_status := p_article_status;
    END IF;

    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
    OKC_ARTICLE_VERSIONS_PVT.Insert_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_article_id                 => p_article_id,
      p_article_text               => l_clob,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => l_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_current_org_id             => G_CURRENT_ORG_ID,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
--Clause Editing
      p_edited_in_word             => p_edited_in_word,
      p_article_text_in_word       => p_article_text_in_word,
      --clm
      p_variable_code              => p_variable_code,
      x_earlier_adoption_type      => l_earlier_adoption_type,
      x_earlier_version_id         => l_earlier_version_id,
      x_article_version_id         => x_article_version_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

-- Parse through the Article text, replace and extract the variables

-- This is the only API that does DML of article variables. No need for
-- a simple API.

    i := 0;
    IF (l_variable_code_tbl.COUNT > 0) THEN
      FORALL i IN l_variable_code_tbl.FIRST..l_variable_code_tbl.LAST
       INSERT INTO OKC_ARTICLE_VARIABLES
         (
         ARTICLE_VERSION_ID    ,
         VARIABLE_CODE         ,
         OBJECT_VERSION_NUMBER ,
         CREATED_BY            ,
         CREATION_DATE         ,
         LAST_UPDATE_DATE      ,
         LAST_UPDATED_BY       ,
         LAST_UPDATE_LOGIN
         )
        VALUES
         (
          x_article_version_id,
          l_variable_code_tbl(i),
          1.0,
          l_user_id,
          sysdate,
          sysdate,
          l_user_id,
          l_login_id
          );
    END IF;

-- Adoption row should not be created if the global/local org is -99 and
-- if the global org = local org
-- Adoption rows are not applicable for NON Standard Articles
-- Global Article Version Id will be passed for "Localize" cases
-- In the case of new version creation, global article version id will not be
-- passed. The system will evaluate the creation of adoption based on the
-- adoption row created from an earlier version.

    --dbms_output.put_line('Global Org Id: '||G_GLOBAL_ORG_ID ||'* Current Org Id: '||G_CURRENT_ORG_ID);
-- MOAC
   IF G_CURRENT_ORG_ID IS NULL Then
      Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

    IF (G_CURRENT_ORG_ID = G_GLOBAL_ORG_ID OR
        G_CURRENT_ORG_ID = -99 OR
        G_GLOBAL_ORG_ID = -99 ) THEN
       NULL;
    ELSIF p_standard_yn = 'Y'  AND
       nvl(l_earlier_adoption_type,'X') <> 'LOCAL' THEN
       OKC_ADOPTIONS_GRP.CREATE_LOCAL_ADOPTION_DETAILS
       (
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         p_validation_level         => p_validation_level,
         x_adoption_type                => l_adoption_type,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_article_status              => p_article_status,
         p_earlier_local_version_id   => l_earlier_version_id,
         p_local_article_version_id    => x_article_version_id,
         p_global_article_version_id    => p_global_article_version_id,
         p_local_org_id                 => G_CURRENT_ORG_ID
        );
    --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
    --------------------------------------------

    -- Update denormalized adoption type in article versions table
    -- No need to call the update API as the row is still locked and it will be an overhead

       UPDATE OKC_ARTICLE_VERSIONS
          SET adoption_type = nvl(l_adoption_type, 'LOCAL')
       WHERE article_version_id = x_article_version_id;
    END IF;

    /*kkolukul: CLM changes*/
    -- Create Article section mappings based on variable name
    -- Insert at one shot ..

    INSERT INTO OKC_ART_VAR_SECTIONS
         (
          VARIABLE_CODE,
          VARIABLE_VALUE_ID,
          VARIABLE_VALUE,
          ARTICLE_ID,
          SCN_CODE,
          ARTICLE_VERSION_ID,
          CREATED_BY            ,
         CREATION_DATE         ,
         LAST_UPDATE_DATE      ,
         LAST_UPDATED_BY       ,
         LAST_UPDATE_LOGIN
)
    SELECT
          VARIABLE_CODE,
          VARIABLE_VALUE_ID,
          VARIABLE_VALUE,
          p_article_id,
          SCN_CODE,
          x_article_version_id,
          l_User_Id,
          sysdate,
          sysdate,
          l_User_Id,
          l_login_Id
    FROM OKC_ART_VAR_SECTIONS
    WHERE ARTICLE_VERSION_ID = l_earlier_version_id;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    ---------------------------------------------

    --end CLM Changes.

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Leaving create_article_version', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('800: Leaving create_article_version: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_create_article_version_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving create_article_version: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_create_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1000: Leaving create_article_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_create_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END create_article_version;
  ---------------------------------------------------------------------------
  -- PROCEDURE lock_article_version
  ---------------------------------------------------------------------------
  PROCEDURE lock_article_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_version_id         IN NUMBER,
    p_object_version_number      IN NUMBER := NULL
   ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_lock_article_version';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Entered lock_article_version', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_lock_article_version_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Locking A Row
    --------------------------------------------
    OKC_ARTICLE_VERSIONS_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_article_version_id         => p_article_version_id,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1200: Leaving lock_article_version', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1300: Leaving lock_article_version: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_lock_article_version_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1400: Leaving lock_article_version: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_lock_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1500: Leaving lock_article_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_lock_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END lock_article_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_article_variables ---- will be called in update article versions
  ---------------------------------------------------------------------------

    PROCEDURE update_article_variables (
      p_article_version_id IN NUMBER,
      p_variable_code_tbl IN variable_code_tbl_type,
      p_do_dml         IN VARCHAR2 := 'Y',
      x_variables_to_insert_tbl OUT NOCOPY variable_code_tbl_type,
      x_variables_to_delete_tbl OUT NOCOPY variable_code_tbl_type,
      x_return_status  OUT NOCOPY VARCHAR2) IS

       i number := 0;
       j number := 0;
       l number := 0;
       k number := 0;
       l_existing_variables_tbl     variable_code_tbl_type;
       l_variable_found              VARCHAR2(1) := 'F';
       -- Bug 3917777
       l_user_id NUMBER := FND_GLOBAL.USER_ID;
       l_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

       CURSOR existing_art_variable_csr (cp_article_version_id IN NUMBER) IS
          SELECT VARIABLE_CODE FROM OKC_ARTICLE_VARIABLES
             WHERE ARTICLE_VERSION_ID = cp_article_version_id;
       BEGIN
          IF (l_debug = 'Y') THEN
             okc_debug.log('1750: Entered update_article_variables', 2);
          END IF;
          OPEN  existing_art_variable_csr(p_article_version_id);
          FETCH existing_art_variable_csr BULK COLLECT INTO l_existing_variables_tbl;
          CLOSE  existing_art_variable_csr;
          IF p_variable_code_tbl.COUNT = 0 AND
             l_existing_variables_tbl.COUNT = 0 Then
             NULL;
          ELSIF p_variable_code_tbl.COUNT > 0 THEN
             FOR i IN p_variable_code_tbl.FIRST..p_variable_code_tbl.LAST LOOP
               l_variable_found := 'F';
               IF l_existing_variables_tbl.COUNT > 0 THEN
                 FOR j IN l_existing_variables_tbl.FIRST..l_existing_variables_tbl.LAST LOOP
                   IF p_variable_code_tbl(i) = l_existing_variables_tbl(j) then
                      l_variable_found := 'T';
                      l_existing_variables_tbl(j) := NULL;
                      exit;
                   END IF;
                 END LOOP;
               END IF;
               IF l_variable_found = 'F' Then
                 x_variables_to_insert_tbl(k) := p_variable_code_tbl(i);
                 k := k + 1;
               END IF;
             END LOOP;
          END IF;
          k := 0;
          IF l_existing_variables_tbl.COUNT > 0 THEN
            FOR j IN l_existing_variables_tbl.FIRST..l_existing_variables_tbl.LAST LOOP
               IF l_existing_variables_tbl(j) IS NOT NULL then
                 x_variables_to_delete_tbl(k) := l_existing_variables_tbl(j);
                 k := k + 1;
               END IF;
            END LOOP;
          ELSE
            x_variables_to_delete_tbl := l_existing_variables_tbl;
          END IF;
          IF p_do_dml = 'Y' THEN
            IF x_variables_to_insert_tbl.COUNT > 0 Then
              FORALL i in x_variables_to_insert_tbl.FIRST .. x_variables_to_insert_tbl.LAST
               INSERT INTO OKC_ARTICLE_VARIABLES
                 (
                 ARTICLE_VERSION_ID    ,
                 VARIABLE_CODE         ,
                 OBJECT_VERSION_NUMBER ,
                 CREATED_BY            ,
                 CREATION_DATE         ,
                 LAST_UPDATE_DATE      ,
                 LAST_UPDATED_BY       ,
                 LAST_UPDATE_LOGIN
                 )
                VALUES
                (
                 p_article_version_id,
                 x_variables_to_insert_tbl(i),
                 1.0,
                 l_user_id,
                 sysdate,
                 sysdate,
                 l_user_id,
                 l_login_id
                 );
            END IF;

            IF x_variables_to_delete_tbl.COUNT > 0 Then
              FORALL i in x_variables_to_delete_tbl.FIRST .. x_variables_to_delete_tbl.LAST
                DELETE FROM OKC_ARTICLE_VARIABLES
                 WHERE VARIABLE_CODE = x_variables_to_delete_tbl(i)
                 AND ARTICLE_VERSION_ID = p_article_version_id;
            END IF;
          END IF;

          IF (l_debug = 'Y') THEN
           Okc_Debug.Log('1750: Leaving Update Article variables successfully', 2);
          END IF;
          x_return_status := G_RET_STS_SUCCESS;

   EXCEPTION

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1750: Leaving update_article_variables because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF existing_art_variable_csr%ISOPEN THEN
        CLOSE existing_art_variable_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;

    END;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_article_version
  ---------------------------------------------------------------------------
  PROCEDURE update_article_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2  := NULL,
    p_orig_system_reference_id1  IN VARCHAR2  := NULL,
    p_orig_system_reference_id2  IN VARCHAR2  := NULL,
    p_additional_instructions    IN VARCHAR2  := NULL,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
    p_object_version_number      IN NUMBER := NULL,
--Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
    p_article_text_in_word       IN BLOB DEFAULT NULL,
    --clm
    p_variable_code              IN VARCHAR2 DEFAULT NULL
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_update_article_version';
    l_earlier_version_id           NUMBER;
    l_article_id                   NUMBER;
    l_article_text                 CLOB;
    l_article_status               OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE;
    l_variable_code_tbl           variable_code_tbl_type;
    l_variables_to_insert_tbl  variable_code_tbl_type;
    l_variables_to_delete_tbl  variable_code_tbl_type;
    l_clob CLOB;
-- The following procedure is private to this API and will be used to update the variables for the articles
-- It will perform the following:
-- 1. Delete the existing variables no longer used
-- 2. Create any new variables that do not exist in OKC_ARTICLE_VARIABLES
-- BULK approach was considered for better performance with manipulation using PL/SQL arrays
-- Other approach could be use of temp tables
-- Easiest approach would have been is to bulk delete and bulk insert all article variables but maynot perform
-- as efficiently


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Entered update_article_version', 2);
       okc_debug.log('1700: Locking row', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_article_version_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Parse through the Article text, replace and extract the variables
-- Parsing is an expensive process and should be done only if the text has changed and if the article is in Draft or
-- Rejected Status
-- Expecting UIs to detect a change in text and setting p_article_text only if it has changed. Else pass this as NULL
-- Parsing is DONE only if the status is = DRAFT, REJECTED as article text
-- cannot be updated in any other status

  l_article_status := p_article_status;
  l_article_text := p_article_text;

-- nvl added to cater to non-standard articles. Std Articles will never be of NULL status

  IF p_article_text is NOT NULL AND
    nvl(l_article_status,'DRAFT') IN ('DRAFT','REJECTED') THEN
     DBMS_LOB.CREATETEMPORARY(l_clob,true);
  parse_n_replace_text(
    p_api_version                  => p_api_version,
    p_init_msg_list                => p_init_msg_list,
    p_article_text                 => l_article_text,
    p_dest_clob                    => l_clob,
    p_calling_mode                 => 'CALLED_FROM_CREATE_UPDATE',
    p_replace_text                 => 'Y',
    p_article_intent               => p_article_intent,
    p_language                     => USERENV('LANG'),
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    x_variables_tbl                => l_variable_code_tbl
   ) ;
   --dbms_lob.freetemporary(l_clob);
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
  END IF;
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id() ;
    /*
    OPEN cur_org_csr;
    FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
    CLOSE cur_org_csr;
    */
    --------------------------------------------
    -- Calling Simple API for Updating A Row
    --------------------------------------------
  -- UIs may be returning EXPIRED status (derived) from VOs.
    IF p_article_status = 'EXPIRED' THEN
       l_article_status := 'APPROVED';
    ELSE
       l_article_status := p_article_status;
    END IF;

    -- MOAC
       IF G_CURRENT_ORG_ID IS NULL Then
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
          RAISE FND_API.G_EXC_ERROR ;
   END IF;

    OKC_ARTICLE_VERSIONS_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_article_version_id         => p_article_version_id,
      p_article_id                 => p_article_id,
      p_article_version_number     => NULL,
      p_article_text               => l_clob,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => l_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_current_org_id             => G_CURRENT_ORG_ID,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_object_version_number      => p_object_version_number,
--Clause Editing
      p_edited_in_word             => p_edited_in_word,
      p_article_text_in_word       => p_article_text_in_word,
      --clm
      p_variable_code              => p_variable_code,
      x_article_status             => l_article_status,
      x_article_id                 => l_article_id,
      x_earlier_version_id         => l_earlier_version_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
  IF p_article_text is NOT NULL AND
    nvl(l_article_status,'DRAFT') IN ('DRAFT','REJECTED') THEN
    update_article_variables (p_article_version_id => p_article_version_id,
                              p_variable_code_tbl => l_variable_code_tbl,
                              p_do_dml => 'Y',
                              x_variables_to_insert_tbl => l_variables_to_insert_tbl,
                              x_variables_to_delete_tbl => l_variables_to_delete_tbl,
                              x_return_status => x_return_status);
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
  END IF;
  IF l_article_status = 'APPROVED' THEN
      UPDATE OKC_ARTICLES_ALL
        SET cz_transfer_status_flag = 'R'
        WHERE ARTICLE_ID = l_article_id;
  END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
      okc_debug.log('1800: Leaving update_article_version', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('1900: Leaving update_article_version: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_update_article_version_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2000: Leaving update_article_version: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_update_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2100: Leaving update_article_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_update_article_version_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END update_article_version;


  ---------------------------------------------------------------------------
  -- PROCEDURE copy_article
  ---------------------------------------------------------------------------
  PROCEDURE copy_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    p_article_version_id           IN NUMBER,
    p_new_article_title            IN VARCHAR2 := NULL,
    p_new_article_number           IN VARCHAR2 := NULL,
    p_create_standard_yn           IN VARCHAR2 := 'N',
    p_copy_relationship_yn           IN VARCHAR2 := 'N',
    p_copy_folder_assoc_yn           IN VARCHAR2 := 'N',

    x_article_version_id           OUT NOCOPY NUMBER,
    x_article_id                   OUT NOCOPY NUMBER,
    x_article_number               OUT NOCOPY VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    ) IS
    -- Article Attributes
    l_article_id                  OKC_ARTICLES_ALL.ARTICLE_ID%TYPE ;
    l_org_id                      OKC_ARTICLES_ALL.ORG_ID%TYPE ;
    l_article_number              OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE ;
    l_old_article_number              OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE ;
    l_article_title               OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE ;
    l_object_version_number       OKC_ARTICLES_ALL.OBJECT_VERSION_NUMBER%TYPE ;
    l_standard_yn                 OKC_ARTICLES_ALL.STANDARD_YN%TYPE;
    l_article_intent              OKC_ARTICLES_ALL.ARTICLE_INTENT%TYPE;
    l_article_language            OKC_ARTICLES_ALL.ARTICLE_LANGUAGE%TYPE;
    l_article_type                OKC_ARTICLES_ALL.ARTICLE_TYPE%TYPE;
    l_doc_sequence_type           VARCHAR2(1);
    l_orig_system_reference_code  OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
    l_orig_system_reference_id1   OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
    l_orig_system_reference_id2   OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
    l_cz_transfer_status_flag     OKC_ARTICLES_ALL.CZ_TRANSFER_STATUS_FLAG%TYPE;
    l_program_id                  OKC_ARTICLES_ALL.PROGRAM_ID%TYPE ;
    l_program_login_id            OKC_ARTICLES_ALL.PROGRAM_LOGIN_ID%TYPE ;
    l_program_application_id      OKC_ARTICLES_ALL.PROGRAM_APPLICATION_ID%TYPE ;
    l_request_id                  OKC_ARTICLES_ALL.REQUEST_ID%TYPE ;
    l_attribute_category          OKC_ARTICLES_ALL.ATTRIBUTE_CATEGORY%TYPE;
    l_attribute1                  OKC_ARTICLES_ALL.ATTRIBUTE1%TYPE;
    l_attribute2                  OKC_ARTICLES_ALL.ATTRIBUTE2%TYPE;
    l_attribute3                  OKC_ARTICLES_ALL.ATTRIBUTE3%TYPE;
    l_attribute4                  OKC_ARTICLES_ALL.ATTRIBUTE4%TYPE;
    l_attribute5                  OKC_ARTICLES_ALL.ATTRIBUTE5%TYPE;
    l_attribute6                  OKC_ARTICLES_ALL.ATTRIBUTE6%TYPE;
    l_attribute7                  OKC_ARTICLES_ALL.ATTRIBUTE7%TYPE;
    l_attribute8                  OKC_ARTICLES_ALL.ATTRIBUTE8%TYPE;
    l_attribute9                  OKC_ARTICLES_ALL.ATTRIBUTE9%TYPE;
    l_attribute10                 OKC_ARTICLES_ALL.ATTRIBUTE10%TYPE;
    l_attribute11                 OKC_ARTICLES_ALL.ATTRIBUTE11%TYPE;
    l_attribute12                 OKC_ARTICLES_ALL.ATTRIBUTE12%TYPE;
    l_attribute13                 OKC_ARTICLES_ALL.ATTRIBUTE13%TYPE;
    l_attribute14                 OKC_ARTICLES_ALL.ATTRIBUTE14%TYPE;
    l_attribute15                 OKC_ARTICLES_ALL.ATTRIBUTE15%TYPE;
    l_created_by                  OKC_ARTICLES_ALL.CREATED_BY%TYPE;
    l_creation_date               OKC_ARTICLES_ALL.CREATION_DATE%TYPE;
    l_last_update_date            OKC_ARTICLES_ALL.LAST_UPDATE_DATE%TYPE;
    l_last_updated_by             OKC_ARTICLES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login           OKC_ARTICLES_ALL.LAST_UPDATE_LOGIN%TYPE;

    -- Article Version Attributes
    lv_article_version_id          OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE ;
    lv_article_version_number      OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE ;
    lv_object_version_number       OKC_ARTICLE_VERSIONS.OBJECT_VERSION_NUMBER%TYPE ;
    lv_article_id                  OKC_ARTICLE_VERSIONS.ARTICLE_ID%TYPE ;
    lv_article_text                OKC_ARTICLE_VERSIONS.ARTICLE_TEXT%TYPE;
    lv_provision_yn                OKC_ARTICLE_VERSIONS.PROVISION_YN%TYPE;
    lv_insert_by_reference         OKC_ARTICLE_VERSIONS.INSERT_BY_REFERENCE%TYPE;
    lv_lock_text                   OKC_ARTICLE_VERSIONS.LOCK_TEXT%TYPE;
    lv_global_yn                   OKC_ARTICLE_VERSIONS.GLOBAL_YN%TYPE;
    lv_article_language            OKC_ARTICLE_VERSIONS.ARTICLE_LANGUAGE%TYPE ;
    lv_article_status              OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE;
    lv_sav_release                 OKC_ARTICLE_VERSIONS.SAV_RELEASE%TYPE;
    lv_start_date                  OKC_ARTICLE_VERSIONS.START_DATE%TYPE ;
    lv_end_date                    OKC_ARTICLE_VERSIONS.END_DATE%TYPE;
    lv_std_article_version_id      OKC_ARTICLE_VERSIONS.STD_ARTICLE_VERSION_ID%TYPE ;
    lv_display_name                OKC_ARTICLE_VERSIONS.DISPLAY_NAME%TYPE;
    lv_translated_yn               OKC_ARTICLE_VERSIONS.TRANSLATED_YN%TYPE;
    lv_article_description         OKC_ARTICLE_VERSIONS.ARTICLE_DESCRIPTION%TYPE;
    lv_date_approved               OKC_ARTICLE_VERSIONS.DATE_APPROVED%TYPE;
    lv_default_section             OKC_ARTICLE_VERSIONS.DEFAULT_SECTION%TYPE;
    lv_reference_source            OKC_ARTICLE_VERSIONS.REFERENCE_SOURCE%TYPE;
    lv_reference_text              OKC_ARTICLE_VERSIONS.REFERENCE_TEXT%TYPE;
    lv_additional_instructions     OKC_ARTICLE_VERSIONS.ADDITIONAL_INSTRUCTIONS%TYPE;
    lv_variation_description       OKC_ARTICLE_VERSIONS.VARIATION_DESCRIPTION%TYPE;
    lv_date_published              OKC_ARTICLE_VERSIONS.DATE_PUBLISHED%TYPE;
    lv_orig_system_reference_code  OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
    lv_orig_system_reference_id1   OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
    lv_orig_system_reference_id2   OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
    lv_program_id                  OKC_ARTICLE_VERSIONS.PROGRAM_ID%TYPE ;
    lv_program_login_id            OKC_ARTICLE_VERSIONS.PROGRAM_LOGIN_ID%TYPE ;
    lv_program_application_id      OKC_ARTICLE_VERSIONS.PROGRAM_APPLICATION_ID%TYPE ;
    lv_request_id                  OKC_ARTICLE_VERSIONS.REQUEST_ID%TYPE ;
    lv_attribute_category          OKC_ARTICLE_VERSIONS.ATTRIBUTE_CATEGORY%TYPE;
    lv_attribute1                  OKC_ARTICLE_VERSIONS.ATTRIBUTE1%TYPE;
    lv_attribute2                  OKC_ARTICLE_VERSIONS.ATTRIBUTE2%TYPE;
    lv_attribute3                  OKC_ARTICLE_VERSIONS.ATTRIBUTE3%TYPE;
    lv_attribute4                  OKC_ARTICLE_VERSIONS.ATTRIBUTE4%TYPE;
    lv_attribute5                  OKC_ARTICLE_VERSIONS.ATTRIBUTE5%TYPE;
    lv_attribute6                  OKC_ARTICLE_VERSIONS.ATTRIBUTE6%TYPE;
    lv_attribute7                  OKC_ARTICLE_VERSIONS.ATTRIBUTE7%TYPE;
    lv_attribute8                  OKC_ARTICLE_VERSIONS.ATTRIBUTE8%TYPE;
    lv_attribute9                  OKC_ARTICLE_VERSIONS.ATTRIBUTE9%TYPE;
    lv_attribute10                 OKC_ARTICLE_VERSIONS.ATTRIBUTE10%TYPE;
    lv_attribute11                 OKC_ARTICLE_VERSIONS.ATTRIBUTE11%TYPE;
    lv_attribute12                 OKC_ARTICLE_VERSIONS.ATTRIBUTE12%TYPE;
    lv_attribute13                 OKC_ARTICLE_VERSIONS.ATTRIBUTE13%TYPE;
    lv_attribute14                 OKC_ARTICLE_VERSIONS.ATTRIBUTE14%TYPE;
    lv_attribute15                 OKC_ARTICLE_VERSIONS.ATTRIBUTE15%TYPE;
    lv_created_by                  OKC_ARTICLE_VERSIONS.CREATED_BY%TYPE;
    lv_creation_date               OKC_ARTICLE_VERSIONS.CREATION_DATE%TYPE;
    lv_last_update_date            OKC_ARTICLE_VERSIONS.LAST_UPDATE_DATE%TYPE;
    lv_last_updated_by             OKC_ARTICLE_VERSIONS.LAST_UPDATED_BY%TYPE;
    lv_last_update_login           OKC_ARTICLE_VERSIONS.LAST_UPDATE_LOGIN%TYPE;
--Clause Editing
    lv_edited_in_word              OKC_ARTICLE_VERSIONS.EDITED_IN_WORD%TYPE;
    lv_article_text_in_word        OKC_ARTICLE_VERSIONS.ARTICLE_TEXT_IN_WORD%TYPE;
    --CLM
    lv_variable_code               OKC_ARTICLE_VERSIONS.VARIABLE_CODE%TYPE;

    l_p_standard_yn   VARCHAR2(1);
    l_p_article_id    NUMBER;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version   CONSTANT NUMBER := 1;
    l_api_name      CONSTANT VARCHAR2(30) := 'g_copy_article';
    l_p_org_id        NUMBER;
    l_earlier_version_id          NUMBER;
    l_earlier_adoption_type          OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;
--    TYPE l_source_article_id_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.SOURCE_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_target_article_id_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.TARGET_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_relationship_type_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.RELATIONSHIP_TYPE%TYPE INDEX BY BINARY_INTEGER ;

--    l_source_article_id_tbl   l_source_article_id_list ;
    l_target_article_id_tbl   l_target_article_id_list ;
    l_relationship_type_tbl   l_relationship_type_list ;
    i NUMBER := 0;

    CURSOR l_article_csr (cp_article_version_id IN NUMBER) is
    SELECT aa.standard_yn,av.article_id
    FROM   OKC_ARTICLES_ALL aa,OKC_ARTICLE_VERSIONS av
    WHERE  aa.ARTICLE_ID = av.ARTICLE_ID
    AND    av.ARTICLE_VERSION_ID = cp_article_version_id;

    CURSOR l_relationship_csr (cp_article_id IN NUMBER,
                               cp_org_id IN NUMBER) IS
    SELECT
          TARGET_ARTICLE_ID,
          RELATIONSHIP_TYPE
    FROM OKC_ARTICLE_RELATNS_ALL
     WHERE source_article_id = cp_article_id
       AND org_id = cp_org_id;

    l_user_id NUMBER := FND_GLOBAL.USER_ID;
    l_login_id NUMBER := FND_GLOBAL.LOGIN_ID;
  BEGIN
    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('2700: Entered Copy_Articles ', 2);
    END IF;
      --dbms_output.put_line('2700: Entered Copy_Articles ');

    -- Standard Start of API savepoint
    SAVEPOINT g_copy_article_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id() ;
    /*
    OPEN cur_org_csr;
    FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
    CLOSE cur_org_csr;
    */
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
      --dbms_output.put_line('2700: Before Cursor Entered Copy_Articles ');

-- Insert into ... select would have been faster but we need to validate as well


    OPEN  l_article_csr(p_article_version_id);
    FETCH l_article_csr INTO l_p_standard_yn, l_p_article_id;
    CLOSE l_article_csr;

    IF l_p_article_id IS NOT NULL THEN
    -- Get Current Database values for Article

      --dbms_output.put_line('2700: Before Get_Rec1 ');
      l_return_status := OKC_ARTICLES_ALL_PVT.Get_Rec(
        p_article_id                 => l_p_article_id,
        x_article_title              => l_article_title,
        x_org_id                     => l_org_id,
        x_article_number             => l_old_article_number,
        x_standard_yn                => l_standard_yn,
        x_article_intent             => l_article_intent,
        x_article_language           => l_article_language,
        x_article_type               => l_article_type,
        x_orig_system_reference_code => l_orig_system_reference_code,
        x_orig_system_reference_id1  => l_orig_system_reference_id1,
        x_orig_system_reference_id2  => l_orig_system_reference_id2,
        x_cz_transfer_status_flag    => l_cz_transfer_status_flag,
        x_program_id                 => l_program_id,
        x_program_login_id           => l_program_login_id,
        x_program_application_id     => l_program_application_id,
        x_request_id                 => l_request_id,
        x_attribute_category         => l_attribute_category,
        x_attribute1                 => l_attribute1,
        x_attribute2                 => l_attribute2,
        x_attribute3                 => l_attribute3,
        x_attribute4                 => l_attribute4,
        x_attribute5                 => l_attribute5,
        x_attribute6                 => l_attribute6,
        x_attribute7                 => l_attribute7,
        x_attribute8                 => l_attribute8,
        x_attribute9                 => l_attribute9,
        x_attribute10                => l_attribute10,
        x_attribute11                => l_attribute11,
        x_attribute12                => l_attribute12,
        x_attribute13                => l_attribute13,
        x_attribute14                => l_attribute14,
        x_attribute15                => l_attribute15,
        x_object_version_number      => l_object_version_number,
        x_created_by                 => l_created_by,
        x_creation_date              => l_creation_date,
        x_last_updated_by            => l_last_updated_by,
        x_last_update_login          => l_last_update_login,
        x_last_update_date           => l_last_update_date
      );
       --------------------------------------------
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
       --------------------------------------------
      END IF;

      IF( p_article_version_id IS NOT NULL ) THEN
      -- Get current database values for article version
        --dbms_output.put_line('l_return_status is2 '||l_return_status);
       l_return_status := OKC_ARTICLE_VERSIONS_PVT.Get_Rec(
        p_article_version_id         => p_article_version_id,
        x_article_id                 => lv_article_id,
        x_article_version_number     => lv_article_version_number,
        x_article_text               => lv_article_text,
        x_provision_yn               => lv_provision_yn,
        x_insert_by_reference        => lv_insert_by_reference,
        x_lock_text                  => lv_lock_text,
        x_global_yn                  => lv_global_yn,
        x_article_language           => lv_article_language,
        x_article_status             => lv_article_status,
        x_sav_release                => lv_sav_release,
        x_start_date                 => lv_start_date,
        x_end_date                   => lv_end_date,
        x_std_article_version_id     => lv_std_article_version_id,
        x_display_name               => lv_display_name,
        x_translated_yn              => lv_translated_yn,
        x_article_description        => lv_article_description,
        x_date_approved              => lv_date_approved,
        x_default_section            => lv_default_section,
        x_reference_source           => lv_reference_source,
        x_reference_text           => lv_reference_text,
        x_orig_system_reference_code => lv_orig_system_reference_code,
        x_orig_system_reference_id1  => lv_orig_system_reference_id1,
        x_orig_system_reference_id2  => lv_orig_system_reference_id2,
        x_additional_instructions    => lv_additional_instructions,
        x_variation_description      => lv_variation_description,
        x_date_published             => lv_date_published,
        x_program_id                 => lv_program_id,
        x_program_login_id           => lv_program_login_id,
        x_program_application_id     => lv_program_application_id,
        x_request_id                 => lv_request_id,
        x_attribute_category         => lv_attribute_category,
        x_attribute1                 => lv_attribute1,
        x_attribute2                 => lv_attribute2,
        x_attribute3                 => lv_attribute3,
        x_attribute4                 => lv_attribute4,
        x_attribute5                 => lv_attribute5,
        x_attribute6                 => lv_attribute6,
        x_attribute7                 => lv_attribute7,
        x_attribute8                 => lv_attribute8,
        x_attribute9                 => lv_attribute9,
        x_attribute10                => lv_attribute10,
        x_attribute11                => lv_attribute11,
        x_attribute12                => lv_attribute12,
        x_attribute13                => lv_attribute13,
        x_attribute14                => lv_attribute14,
        x_attribute15                => lv_attribute15,
        x_object_version_number      => lv_object_version_number,
--Clause Editing
        x_edited_in_word             => lv_edited_in_word,
        x_article_text_in_word       => lv_article_text_in_word,
        x_created_by                 => lv_created_by,
        x_creation_date              => lv_creation_date,
        x_last_updated_by            => lv_last_updated_by,
        x_last_update_login          => lv_last_update_login,
        x_last_update_date           => lv_last_update_date,
        x_variable_code              => lv_variable_code    --clm
      );
       --------------------------------------------
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
       --------------------------------------------
      END IF;
      -- Copying Articles
      -- Setting the Attributes depending upon whether it is standard or non-standard article
     IF l_p_standard_yn = 'Y' THEN

-- Bug#3680325 i.e. start date is greatest of sysdate, start date and end date is always null
-- Bug#3826123 i.e. start date should be truncated

        lv_start_date := trunc(greatest(SYSDATE, lv_start_date));
        lv_end_date := NULL;

-- end bug fix#3680325
        lv_article_status := 'DRAFT';
        l_cz_transfer_status_flag := 'N';
        G_profile_doc_seq:=fnd_profile.value('UNIQUE:SEQ_NUMBERS');
        G_doc_category_code  := substr(Fnd_Profile.Value('OKC_ARTICLE_DOC_SEQ_CATEGORY'),1,30) ;

        -- MOAC
	   IF G_CURRENT_ORG_ID IS NULL Then
	      Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
	      RAISE FND_API.G_EXC_ERROR ;
        END IF;

        GET_ARTICLE_SEQ_NUMBER
          (p_article_number => p_new_article_number,
           p_seq_type_info_only      => 'N',
           p_org_id   => G_CURRENT_ORG_ID,
           x_article_number => l_article_number,
           x_doc_sequence_type => l_doc_sequence_type,
           x_return_status => x_return_status);

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        IF l_article_number IS NULL THEN
          l_article_number := nvl(p_new_article_number, l_old_article_number);
        END IF;
        IF G_CURRENT_ORG_ID <> G_GLOBAL_ORG_ID THEN
          lv_global_yn := 'N';
        END IF;
     ELSE        --IF l_p_standard_yn = 'Y' THEN
        lv_start_date := NULL;
        lv_article_status := NULL;
        l_cz_transfer_status_flag := NULL;
        lv_end_date := NULL;
	   -- Bug 5506276 - Added below logic to retain the article number for non-std articles
	   l_article_number := l_old_article_number;
     END IF;

     lv_date_approved := NULL;
     l_orig_system_reference_code := 'OKCART';
     l_orig_system_reference_id1 := to_char(l_p_article_id);
     lv_orig_system_reference_code := 'OKCARTV';
     lv_orig_system_reference_id1 := to_char(p_article_version_id);

        --dbms_output.put_line('Before Create Article ');
     OKC_ARTICLES_ALL_PVT.Insert_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_article_title              => nvl(p_new_article_title,l_article_title),
      p_org_id                     => G_CURRENT_ORG_ID,
      p_article_number             => l_article_number,
      p_standard_yn                => p_create_standard_yn,
      p_article_intent             => l_article_intent,
      p_article_language           => l_article_language,
      p_article_type               => l_article_type,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_cz_transfer_status_flag    => l_cz_transfer_status_flag,
      p_attribute_category         => l_attribute_category,
      p_attribute1                 => l_attribute1,
      p_attribute2                 => l_attribute2,
      p_attribute3                 => l_attribute3,
      p_attribute4                 => l_attribute4,
      p_attribute5                 => l_attribute5,
      p_attribute6                 => l_attribute6,
      p_attribute7                 => l_attribute7,
      p_attribute8                 => l_attribute8,
      p_attribute9                 => l_attribute9,
      p_attribute10                => l_attribute10,
      p_attribute11                => l_attribute11,
      p_attribute12                => l_attribute12,
      p_attribute13                => l_attribute13,
      p_attribute14                => l_attribute14,
      p_attribute15                => l_attribute15,
      x_article_number             => x_article_number,
      x_article_id                 => x_article_id
    );
        --dbms_output.put_line('After Create Article status is '||x_return_status);
        --dbms_output.put_line('x_article_id is '||x_article_id);
        --dbms_output.put_line('x_article_version_id is '||x_article_version_id);
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    OKC_ARTICLE_VERSIONS_PVT.Insert_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_article_id                 => x_article_id,
      p_article_text               => lv_article_text,
      p_provision_yn               => lv_provision_yn,
      p_insert_by_reference        => lv_insert_by_reference,
      p_lock_text                  => lv_lock_text,
      p_global_yn                  => lv_global_yn,
      p_article_language           => lv_article_language,
      p_article_status             => lv_article_status,
      p_sav_release                => lv_sav_release,
      p_start_date                 => lv_start_date,
      p_end_date                   => lv_end_date,
      p_std_article_version_id     => lv_std_article_version_id,
      p_display_name               => lv_display_name,
      p_translated_yn              => lv_translated_yn,
      p_article_description        => lv_article_description,
      p_date_approved              => NULL,
      p_default_section            => lv_default_section,
      p_reference_source           => lv_reference_source,
      p_reference_text           => lv_reference_text,
      p_orig_system_reference_code => lv_orig_system_reference_code,
      p_orig_system_reference_id1  => lv_orig_system_reference_id1,
      p_orig_system_reference_id2  => lv_orig_system_reference_id2,
      p_additional_instructions    => lv_additional_instructions,
      p_variation_description      => lv_variation_description,
      p_date_published             => NULL,
      p_current_org_id             => G_CURRENT_ORG_ID,
      p_attribute_category         => lv_attribute_category,
      p_attribute1                 => lv_attribute1,
      p_attribute2                 => lv_attribute2,
      p_attribute3                 => lv_attribute3,
      p_attribute4                 => lv_attribute4,
      p_attribute5                 => lv_attribute5,
      p_attribute6                 => lv_attribute6,
      p_attribute7                 => lv_attribute7,
      p_attribute8                 => lv_attribute8,
      p_attribute9                 => lv_attribute9,
      p_attribute10                => lv_attribute10,
      p_attribute11                => lv_attribute11,
      p_attribute12                => lv_attribute12,
      p_attribute13                => lv_attribute13,
      p_attribute14                => lv_attribute14,
      p_attribute15                => lv_attribute15,
--Clause Editing
      p_edited_in_word             => lv_edited_in_word,
      p_article_text_in_word       => lv_article_text_in_word,
      --clm
      p_variable_code              => lv_variable_code,
      x_earlier_adoption_type      => l_earlier_adoption_type,
      x_earlier_version_id         => l_earlier_version_id,
      x_article_version_id         => x_article_version_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
-- Create Article Variables
-- Insert at one shot .. This is much efficient than calling the create article version and parse out the variables

    INSERT INTO OKC_ARTICLE_VARIABLES
         (
         ARTICLE_VERSION_ID    ,
         VARIABLE_CODE         ,
         OBJECT_VERSION_NUMBER ,
         CREATED_BY            ,
         CREATION_DATE         ,
         LAST_UPDATE_DATE      ,
         LAST_UPDATED_BY       ,
         LAST_UPDATE_LOGIN
         )
    SELECT
          x_article_version_id,
          VARIABLE_CODE,
          1.0,
          l_user_id,
          sysdate,
          sysdate,
          l_user_id,
          l_login_id
    FROM OKC_ARTICLE_VARIABLES
    WHERE ARTICLE_VERSION_ID = p_article_version_id;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    if p_copy_relationship_yn = 'Y' THEN
       OPEN l_relationship_csr(l_p_article_id, G_CURRENT_ORG_ID);
       LOOP
         BEGIN
         FETCH l_relationship_csr BULK COLLECT INTO
                                                  l_target_article_id_tbl,
                                                  l_relationship_type_tbl;
         i := 0;
         EXIT WHEN l_target_article_id_tbl.COUNT = 0;
--         dbms_output.put_line('Total Rel Found: '||l_target_article_id_tbl.cOUNT);
         FORALL i IN l_target_article_id_tbl.FIRST..l_target_article_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_RELATNS_ALL
             (
              SOURCE_ARTICLE_ID,
              TARGET_ARTICLE_ID,
              ORG_ID,
              RELATIONSHIP_TYPE,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE
              )
            VALUES
              (
              x_article_id,
              l_target_article_id_tbl(i),
              G_CURRENT_ORG_ID,
              l_relationship_type_tbl(i),
              1.0,
              l_User_Id,
              sysdate,
              l_User_Id,
              l_login_Id,
              sysdate
              );

-- Revert the target and source article ids.
         FORALL i IN l_target_article_id_tbl.FIRST..l_target_article_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_RELATNS_ALL
             (
              SOURCE_ARTICLE_ID,
              TARGET_ARTICLE_ID,
              ORG_ID,
              RELATIONSHIP_TYPE,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE
              )
            VALUES
              (
              l_target_article_id_tbl(i),
              x_article_id,
              G_CURRENT_ORG_ID,
              l_relationship_type_tbl(i),
              1.0,
              l_User_Id,
              sysdate,
              l_User_Id,
              l_login_Id,
              sysdate
              );

         l_target_article_id_tbl.DELETE;
         l_relationship_type_tbl.DELETE;
       EXIT WHEN l_relationship_csr%NOTFOUND;
       EXCEPTION
         WHEN OTHERS THEN
           Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
           x_return_status := G_RET_STS_UNEXP_ERROR ;
           exit;
       END;
     END LOOP; -- main cursor loop
     CLOSE l_relationship_csr;
       --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
       --------------------------------------------
    END IF;
    IF p_copy_folder_assoc_yn = 'Y' THEN
      INSERT INTO OKC_FOLDER_CONTENTS
        (
          MEMBER_ID             ,
          FOLDER_ID            ,
          OBJECT_VERSION_NUMBER,
          CREATED_BY           ,
          CREATION_DATE        ,
          LAST_UPDATE_DATE     ,
          LAST_UPDATED_BY      ,
          LAST_UPDATE_LOGIN
        )
      SELECT
          x_article_id,
          folder_id,
          1.0,
          l_User_Id,
          sysdate,
          sysdate,
          l_User_Id,
          l_login_Id
      FROM OKC_FOLDER_CONTENTS mem
      WHERE MEMBER_ID = l_p_article_id
       AND exists
         (select 1 from okc_folders_all_b fold where
           fold.org_id = G_CURRENT_ORG_ID
           and fold.folder_id = mem.folder_id);

    END IF;

    /*kkolukul: CLM changes*/
    -- Create Article section mappings based on variable name
    -- Insert at one shot ..

    INSERT INTO OKC_ART_VAR_SECTIONS
         (
          VARIABLE_CODE,
          VARIABLE_VALUE_ID,
          VARIABLE_VALUE,
          ARTICLE_ID,
          SCN_CODE,
          ARTICLE_VERSION_ID,
          CREATED_BY           ,
          CREATION_DATE        ,
          LAST_UPDATE_DATE     ,
          LAST_UPDATED_BY      ,
          LAST_UPDATE_LOGIN
)
    SELECT
          VARIABLE_CODE,
          VARIABLE_VALUE_ID,
          VARIABLE_VALUE,
          x_article_id,
          SCN_CODE,
          x_article_version_id,
          l_User_Id,
          sysdate,
          sysdate,
          l_User_Id,
          l_login_Id

    FROM OKC_ART_VAR_SECTIONS
    WHERE ARTICLE_VERSION_ID = p_article_version_id;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    ----------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('2800: Leaving copy_article', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2900: Leaving copy_article: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_copy_article_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('3000: Leaving copy_article: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_copy_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('3100: Leaving copy_article because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_copy_article_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END copy_article;

  PROCEDURE get_local_article_id
    (
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_local_org_id                 IN NUMBER,
    p_src_article_id        IN OUT NOCOPY NUMBER,
    p_tar_article_id        IN OUT NOCOPY NUMBER
    ) IS
   CURSOR l_local_article_csr(cp_article_id IN NUMBER,
                                cp_local_org_id IN NUMBER) IS
      SELECT V2.article_id FROM OKC_ARTICLE_ADOPTIONS AA,
             OKC_ARTICLE_VERSIONS V1 ,
             OKC_ARTICLE_VERSIONS V2
       WHERE V1.ARTICLE_VERSION_ID = AA.GLOBAL_ARTICLE_VERSION_ID
         AND V2.ARTICLE_VERSION_ID = AA.LOCAL_ARTICLE_VERSION_ID
         AND V1.ARTICLE_ID = cp_article_id
         AND AA.LOCAL_ORG_ID = cp_local_org_id
         AND AA.ADOPTION_TYPE = 'LOCALIZED'
         AND V2.ARTICLE_STATUS = 'APPROVED'
         AND NVL(V2.END_DATE, SYSDATE+1) > SYSDATE
         AND rownum < 2
    UNION ALL
       SELECT V1.article_id FROM OKC_ARTICLE_ADOPTIONS AA,
                          OKC_ARTICLE_VERSIONS V1
        WHERE V1.ARTICLE_VERSION_ID = AA.GLOBAL_ARTICLE_VERSION_ID
          AND V1.ARTICLE_ID = cp_article_id
          AND AA.LOCAL_ORG_ID = cp_local_org_id
          AND AA.ADOPTION_TYPE = 'ADOPTED'
          AND AA.ADOPTION_STATUS = 'APPROVED'
          AND rownum < 2;

    cursor l_rel_exist_csr (cp_src_article_id IN NUMBER,
                          cp_tar_article_id IN NUMBER,
                          cp_local_org_id IN NUMBER) IS
       SELECT '1' FROM OKC_ARTICLE_RELATNS_ALL
        WHERE source_article_id = cp_src_article_id
         AND  target_article_id = cp_tar_article_id
         AND  org_id = cp_local_org_id;
    l_src_local_article_id NUMBER;
    l_tar_local_article_id NUMBER;
    l_rownotfound BOOLEAN := FALSE;
    l_dummy VARCHAR2(1) := '?';
  BEGIN
     x_return_status := G_RET_STS_SUCCESS;
     OPEN l_local_article_csr(p_src_article_id, p_local_org_id);
     FETCH l_local_article_csr INTO l_src_local_article_id;
     l_rownotfound := l_local_article_csr%NOTFOUND;
     CLOSE l_local_article_csr;
     IF l_rownotfound THEN
       p_src_article_id := NULL;
       p_tar_article_id := NULL;
       return;
     END IF;
    l_rownotfound := FALSE;
    OPEN l_local_article_csr(p_tar_article_id, p_local_org_id);
    FETCH l_local_article_csr INTO l_tar_local_article_id;
    l_rownotfound := l_local_article_csr%NOTFOUND;
    CLOSE l_local_article_csr;
    IF l_rownotfound THEN
      p_src_article_id := NULL;
      p_tar_article_id := NULL;
      return;
    END IF;
-- The following check ensures that the source and target are adopted as is
-- i.e. no localization done. In that case we do not need to check if relationsh-- ip exists as the main pgm already does this.
    if l_tar_local_article_id = p_tar_article_id AND
       l_src_local_article_id = p_src_article_id THEN
       return;
    end if;
    l_rownotfound := FALSE;
    OPEN l_rel_exist_csr(l_src_local_article_id,
                       l_tar_local_article_id,
                       p_local_org_id);
    FETCH l_rel_exist_csr INTO l_dummy;
    l_rownotfound := l_rel_exist_csr%NOTFOUND;
    CLOSE l_rel_exist_csr;

    IF l_rownotfound THEN
      p_src_article_id := l_src_local_article_id;
      p_tar_article_id := l_tar_local_article_id;
    ELSE
      p_src_article_id := NULL;
      p_tar_article_id := NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 'Y') THEN
         okc_debug.log('500: Leaving get local article id EXCEPTION: '||sqlerrm, 2);
       END IF;
       IF l_local_article_csr%ISOPEN THEN
           CLOSE l_local_article_csr;
       END IF;
       IF l_rel_exist_csr%ISOPEN THEN
          CLOSE l_rel_exist_csr;
       END IF;
       x_return_status := G_RET_STS_UNEXP_ERROR ;

  END get_local_article_id;

  PROCEDURE check_adopted
    (
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_local_org_id                 IN NUMBER,
    p_src_article_id        IN OUT NOCOPY NUMBER,
    p_tar_article_id        IN OUT NOCOPY NUMBER
    ) IS
   CURSOR l_local_article_csr(cp_src_article_id IN NUMBER,
                              cp_tar_article_id IN NUMBER,
                              cp_local_org_id IN NUMBER) IS
       SELECT '1'  FROM OKC_ARTICLE_ADOPTIONS AA1,
                        OKC_ARTICLE_VERSIONS V1,
                        OKC_ARTICLE_ADOPTIONS AA2,
                        OKC_ARTICLE_VERSIONS V2
        WHERE V1.ARTICLE_VERSION_ID = AA1.GLOBAL_ARTICLE_VERSION_ID
          AND V1.ARTICLE_ID = cp_src_article_id
          AND AA1.LOCAL_ORG_ID = cp_local_org_id
          AND AA1.ADOPTION_TYPE = 'ADOPTED'
          AND V2.ARTICLE_VERSION_ID = AA2.GLOBAL_ARTICLE_VERSION_ID
          AND V2.ARTICLE_ID = cp_tar_article_id
          AND AA2.LOCAL_ORG_ID = AA1.LOCAL_ORG_ID
          AND AA2.ADOPTION_TYPE = 'ADOPTED'
          AND NOT EXISTS
            (
                   SELECT '1' FROM OKC_ARTICLE_RELATNS_ALL
                    WHERE source_article_id = V1.ARTICLE_ID
                     AND  target_article_id = V2.ARTICLE_ID
                     AND  org_id = AA1.LOCAL_ORG_ID
            );

    l_src_local_article_id NUMBER;
    l_tar_local_article_id NUMBER;
    l_rownotfound BOOLEAN := FALSE;
    l_dummy VARCHAR2(1) := '?';
  BEGIN
     x_return_status := G_RET_STS_SUCCESS;
     OPEN l_local_article_csr(p_src_article_id, p_tar_article_id, p_local_org_id);
     FETCH l_local_article_csr INTO l_dummy;
     l_rownotfound := l_local_article_csr%NOTFOUND;
     CLOSE l_local_article_csr;
     IF l_rownotfound THEN
       p_src_article_id := NULL;
       p_tar_article_id := NULL;
       return;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 'Y') THEN
         okc_debug.log('500: Leaving check adopted.. EXCEPTION: '||sqlerrm, 2);
       END IF;
       IF l_local_article_csr%ISOPEN THEN
           CLOSE l_local_article_csr;
       END IF;
       x_return_status := G_RET_STS_UNEXP_ERROR ;

  END check_adopted;

  PROCEDURE AUTO_ADOPT_RELATIONSHIPS
    (
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fetchsize                    IN NUMBER,
    p_relationship_type            IN VARCHAR2,
    p_src_global_article_id        IN NUMBER,
    p_tar_global_article_id        IN NUMBER
    ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_auto_adopt_relationship';
    l_dummy                       VARCHAR2(1) := '?';
    l_rowfound                    BOOLEAN := FALSE;
    l_local_article_version_id    NUMBER;
    i    NUMBER := 0;
    j    NUMBER := 0;
    l_return_status               VARCHAR2(1);
    l_GLOBAL_ORG_ID NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    TYPE l_org_id_list         IS TABLE OF HR_ORGANIZATION_INFORMATION.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_notifier_list  IS TABLE OF HR_ORGANIZATION_INFORMATION.ORG_INFORMATION2%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_adoption_status_list  IS TABLE OF OKC_ARTICLE_ADOPTIONS.ADOPTION_STATUS%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_source_article_id_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.SOURCE_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_target_article_id_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.TARGET_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_adoption_type_list  IS TABLE OF OKC_ARTICLE_ADOPTIONS.ADOPTION_TYPE%TYPE INDEX BY BINARY_INTEGER;

    l_source_article_id_tbl   l_source_article_id_list ;
    l_target_article_id_tbl   l_target_article_id_list ;


    l_org_id_tbl l_org_id_list;
    l_adoption_type_tbl l_adoption_type_list;
    l_notifier_tbl  l_notifier_list;

   CURSOR l_org_info_csr (cp_src_global_article_id IN NUMBER,
                          cp_tar_global_article_id IN NUMBER,
                          cp_relationship_type IN VARCHAR2) IS
     SELECT ORGANIZATION_ID,
            decode(nvl(ORG_INFORMATION1,'N'),'N','AVAILABLE','Y','ADOPTED') ADOPTION_TYPE ,
            ORG_INFORMATION2

       FROM HR_ORGANIZATION_INFORMATION
      WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
        AND ORGANIZATION_ID <> G_GLOBAL_ORG_ID
        AND NOT EXISTS
        (
          SELECT '1'
          FROM OKC_ARTICLE_RELATNS_ALL R1
          WHERE R1.SOURCE_ARTICLE_ID = cp_src_global_article_id AND
             R1.TARGET_ARTICLE_ID = cp_tar_global_article_id AND
             R1.RELATIONSHIP_TYPE = cp_relationship_type AND
             R1.ORG_ID = ORGANIZATION_ID
      );

   CURSOR l_approved_csr (cp_src_global_article_id IN NUMBER,
                          cp_tar_global_article_id IN NUMBER) IS
    SELECT '1'
      FROM OKC_ARTICLES_ALL A, OKC_ARTICLES_ALL B
     WHERE A.ARTICLE_ID = cp_src_global_article_id
      AND  B.ARTICLE_ID = cp_tar_global_article_id
      AND EXISTS
           (SELECT 1 FROM OKC_ARTICLE_VERSIONS V
            WHERE V.ARTICLE_ID = B.ARTICLE_ID
              AND V.GLOBAL_YN = 'Y'
              AND V.ARTICLE_STATUS = 'APPROVED'
              AND NVL(V.END_DATE,SYSDATE + 1) > SYSDATE
             )
      AND EXISTS
           (SELECT 1 FROM OKC_ARTICLE_VERSIONS V1
            WHERE V1.ARTICLE_ID = A.ARTICLE_ID
              AND V1.GLOBAL_YN = 'Y'
              AND V1.ARTICLE_STATUS = 'APPROVED'
              AND NVL(V1.END_DATE,SYSDATE + 1) > SYSDATE
             );

    l_user_id NUMBER := FND_GLOBAL.USER_ID;
    l_login_id NUMBER := FND_GLOBAL.LOGIN_ID;
    l_src_local_article_id NUMBER;
    l_tar_local_article_id NUMBER;
    l_rownotfound BOOLEAN := FALSE;

  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered auto adopt relationship', 2);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --dbms_output.put_line('Global org is: '|| l_global_org_id);
    OPEN l_approved_csr (p_src_global_article_id, p_tar_global_article_id);
    FETCH l_approved_csr INTO l_dummy;
    l_rownotfound := l_approved_csr%NOTFOUND;
    CLOSE l_approved_csr;
    IF l_rownotfound THEN
       return;
    END IF;
    OPEN l_org_info_csr (p_src_global_article_id,
                         p_tar_global_article_id,
                         p_relationship_type);
    LOOP
      BEGIN
       FETCH l_org_info_csr BULK COLLECT INTO l_org_id_tbl, l_adoption_type_tbl, l_notifier_tbl LIMIT p_fetchsize;
       i := 0;
      --dbms_output.put_line('Cursor fetched rows: '||l_org_id_tbl.COUNT);
       EXIT WHEN l_org_id_tbl.COUNT = 0;
       FOR i in 1..l_org_id_tbl.COUNT LOOP
         l_source_article_id_tbl(i) := p_src_global_article_id;
         l_target_article_id_tbl(i) := p_tar_global_article_id;
      --dbms_output.put_line('Cursor fetched adoption type: '|| l_adoption_type_tbl(i)||'*'||l_org_id_tbl(i)||'*'|| l_source_article_id_tbl(i)|| '*'||l_target_article_id_tbl(i));
         IF l_adoption_type_tbl(i) <> 'ADOPTED' Then
            check_adopted
              (
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_local_org_id   => l_org_id_tbl(i),
               p_src_article_id => l_source_article_id_tbl(i),
               p_tar_article_id => l_target_article_id_tbl(i)
              );
-- Removed after discusssion between dev and PM on 10/30 to adopte relationships only for adopted and not localized.
/*
            get_local_article_id
              (
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_local_org_id   => l_org_id_tbl(i),
               p_src_article_id => l_source_article_id_tbl(i),
               p_tar_article_id => l_target_article_id_tbl(i)
              );
*/
      --dbms_output.put_line('After getlocal article id: '|| l_adoption_type_tbl(i)||'*'||l_org_id_tbl(i)||'*'|| l_source_article_id_tbl(i)|| '*'||l_target_article_id_tbl(i));
            IF x_return_status <> G_RET_STS_SUCCESS THEN
              exit;
            END IF;
         END IF;
       END LOOP;
       IF x_return_status <> G_RET_STS_SUCCESS THEN
           exit;
       END IF;

       FORALL j IN l_org_id_tbl.FIRST..l_org_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_RELATNS_ALL
             (
              SOURCE_ARTICLE_ID,
              TARGET_ARTICLE_ID,
              ORG_ID,
              RELATIONSHIP_TYPE,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE
              )
            SELECT
              l_source_article_id_tbl(j),
              l_target_article_id_tbl(j),
              l_org_id_tbl(j),
              p_relationship_type,
              1.0,
              l_User_Id,
              sysdate,
              l_User_Id,
              l_login_Id,
              sysdate
            FROM DUAL
            WHERE l_source_article_id_tbl(j) IS NOT NULL;

-- Revert the target and source article ids.

       FORALL j IN l_org_id_tbl.FIRST..l_org_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_RELATNS_ALL
             (
              SOURCE_ARTICLE_ID,
              TARGET_ARTICLE_ID,
              ORG_ID,
              RELATIONSHIP_TYPE,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE
             )
          SELECT
              l_target_article_id_tbl(j),
              l_source_article_id_tbl(j),
              l_org_id_tbl(j),
              p_relationship_type,
              1.0,
              l_User_Id,
              sysdate,
              l_User_Id,
              l_Login_Id,
              sysdate
          FROM DUAL
          WHERE l_source_article_id_tbl(j) IS NOT NULL;
      l_target_article_id_tbl.DELETE;
      l_source_article_id_tbl.DELETE;
      l_org_id_tbl.DELETE;
      l_adoption_type_tbl.DELETE;
      l_notifier_tbl.DELETE;
    EXIT WHEN l_org_info_csr%NOTFOUND;
    EXCEPTION
      WHEN OTHERS THEN
        --dbms_output.put_line(sqlerrm);
         Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
        x_return_status := G_RET_STS_UNEXP_ERROR ;
        exit;
    END;
  END LOOP; -- main cursor loop
  CLOSE l_org_info_csr;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Auto_Adoption: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Auto_Adoption: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      IF l_org_info_csr%ISOPEN THEN
         CLOSE l_org_info_csr;
      END IF;
      IF l_approved_csr%ISOPEN THEN
         CLOSE l_approved_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Auto_Adoption because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_org_info_csr%ISOPEN THEN
         CLOSE l_org_info_csr;
      END IF;
      IF l_approved_csr%ISOPEN THEN
         CLOSE l_approved_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

  END AUTO_ADOPT_RELATIONSHIPS;
  -------------------------------------
  -- PROCEDURE create article relationship
  -------------------------------------
  PROCEDURE create_article_relationship(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2
  ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_lock_row';
    l_object_version_number OKC_ARTICLE_RELATNS_ALL.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_created_by            OKC_ARTICLE_RELATNS_ALL.CREATED_BY%TYPE;
    l_creation_date         OKC_ARTICLE_RELATNS_ALL.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_ARTICLE_RELATNS_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_DATE%TYPE;
    l_source_article_id     NUMBER;
    l_target_article_id     NUMBER;
    l_org_id                NUMBER;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered insert_row', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_insert_row_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
   --dbms_output.put_line('Insrting...with src/target: '||p_source_article_id||'*'||p_target_article_id);
    OKC_ARTICLE_RELATIONSHIPS_PVT.Insert_Row(
      p_validation_level           =>   p_validation_level,
      x_return_status              =>   x_return_status,
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
      p_relationship_type     => p_relationship_type,
      x_source_article_id     => l_source_article_id,
      x_target_article_id     => l_target_article_id,
      x_org_id                => l_org_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    -- Create opposite row by flipping the source and target for the relationship
    --------------------------------------------
   --dbms_output.put_line('Insrting. Reverse ..with src/target: '||p_target_article_id||'*'||p_source_article_id);
    OKC_ARTICLE_RELATIONSHIPS_PVT.Insert_Row(
      p_validation_level           =>   p_validation_level,
      x_return_status              =>   x_return_status,
      p_source_article_id     => p_target_article_id,
      p_target_article_id     => p_source_article_id,
      p_org_id                => p_org_id,
      p_relationship_type     => p_relationship_type,
      x_source_article_id     => l_source_article_id,
      x_target_article_id     => l_target_article_id,
      x_org_id                => l_org_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

-- Trigger autoadoption of relationships for all orgs if a global org has created a relationship between two
-- global articles.

    IF p_org_id = G_GLOBAL_ORG_ID AND p_org_id <> -99 THEN
       --dbms_output.put_line('Calling....Adopt Rel');
       AUTO_ADOPT_RELATIONSHIPS
          (
           x_return_status                => x_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_fetchsize                    => 100,
           p_src_global_article_id        => p_source_article_id,
           p_tar_global_article_id        => p_target_article_id,
           p_relationship_type            => p_relationship_type);
    --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
    --------------------------------------------
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Leaving insert_row', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('800: Leaving insert_row: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving insert_row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1000: Leaving insert_row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END create_article_relationship;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_article_relationship
  ---------------------------------------------------------------------------
  PROCEDURE DELETE_AUTO_ADOPTED_RELATIONS
    (
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fetchsize                    IN NUMBER,
    p_source_global_article_id     IN NUMBER,
    p_target_global_article_id     IN NUMBER
    ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_auto_adoption';
    j    NUMBER := 0;
    l_GLOBAL_ORG_ID NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    TYPE l_org_id_list         IS TABLE OF HR_ORGANIZATION_INFORMATION.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_article_number_list IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_source_article_id_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.SOURCE_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_target_article_id_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.TARGET_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;

    l_article_number_tbl   l_article_number_list ;
    l_source_article_id_tbl   l_source_article_id_list ;
    l_target_article_id_tbl   l_target_article_id_list ;
    l_org_id_tbl l_org_id_list;
    l_firsttime  BOOLEAN := TRUE;

   CURSOR l_relationship_csr (cp_source_global_article_id IN NUMBER,
                              cp_target_global_article_id IN NUMBER) IS
     SELECT source_article_id, target_article_id, org_id
       FROM OKC_ARTICLE_RELATNS_ALL REL
     WHERE source_article_id = cp_source_global_article_id
       AND target_article_id = cp_target_global_article_id;
/*
       AND exists
          ( SELECT '1'
            FROM HR_ORGANIZATION_INFORMATION
           WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
             AND ORGANIZATION_ID = rel.org_id
             AND ORG_INFORMATION1 = 'Y');
*/

  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered create_adoption', 2);
    END IF;

    -- Standard Start of API savepoint
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --dbms_output.put_line('Global org is: '|| l_global_org_id);
    OPEN l_relationship_csr (p_source_global_article_id, p_target_global_article_id);
    LOOP
       FETCH l_relationship_csr BULK COLLECT INTO l_source_article_id_tbl,
                                                  l_target_article_id_tbl,
                                                  l_org_id_tbl
       LIMIT p_fetchsize;

-- Also include the global article data

       if l_firsttime THEN
          l_source_article_id_tbl(l_source_article_id_tbl.COUNT+1) := p_source_global_article_id;
          l_target_article_id_tbl(l_target_article_id_tbl.COUNT+1) := p_target_global_article_id;
          l_org_id_tbl(l_org_id_tbl.COUNT+1) := G_GLOBAL_ORG_ID;
          l_firsttime := FALSE;
       end if;
       EXIT WHEN l_source_article_id_tbl.COUNT = 0;
       j := 0;
       FORALL j IN l_source_article_id_tbl.FIRST..l_source_article_id_tbl.LAST
           DELETE FROM OKC_ARTICLE_RELATNS_ALL
             WHERE source_article_id = l_source_article_id_tbl(j) AND
                   target_article_id = l_target_article_id_tbl(j) AND
                   org_id = l_org_id_tbl(j);

-- Revert the target and source article ids.
       j := 0;
       FORALL j IN l_source_article_id_tbl.FIRST..l_source_article_id_tbl.LAST
           DELETE FROM OKC_ARTICLE_RELATNS_ALL
             WHERE target_article_id = l_source_article_id_tbl(j) AND
                   source_article_id = l_target_article_id_tbl(j) AND
                   org_id = l_org_id_tbl(j);


       l_org_id_tbl.DELETE;
       l_source_article_id_tbl.DELETE;
       l_target_article_id_tbl.DELETE;
       EXIT WHEN l_relationship_csr%NOTFOUND;
     END LOOP; -- relationship csr fetch
     CLOSE l_relationship_csr;
     EXCEPTION
        WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Auto_Adoption because of EXCEPTION: '||sqlerrm, 2);
             END IF;
             IF l_relationship_csr%ISOPEN THEN
                CLOSE l_relationship_csr;
             END IF;

             x_return_status := G_RET_STS_UNEXP_ERROR ;
  END  DELETE_AUTO_ADOPTED_RELATIONS;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_article_relationship
  ---------------------------------------------------------------------------

  PROCEDURE delete_article_relationship(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_object_version_number IN NUMBER := NULL
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_delete_row';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Entered delete_row', 2);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_delete_row_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Deleting A Row
    --------------------------------------------
    IF p_org_id <> G_GLOBAL_ORG_ID THEN
       OKC_ARTICLE_RELATIONSHIPS_PVT.Delete_Row(
         x_return_status              =>   x_return_status,
         p_source_article_id     => p_source_article_id,
         p_target_article_id     => p_target_article_id,
         p_org_id                => p_org_id,
         p_object_version_number => p_object_version_number
       );
       --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;
       --------------------------------------------
       --------------------------------------------
       -- Delete the opposite row by flipping the source and target for the relationship
       --------------------------------------------
       OKC_ARTICLE_RELATIONSHIPS_PVT.Delete_Row(
         x_return_status              =>   x_return_status,
         p_source_article_id     => p_target_article_id,
         p_target_article_id     => p_source_article_id,
         p_org_id                => p_org_id,
         p_object_version_number => p_object_version_number
       );
       --------------------------------------------
    ELSE
--       For global article relationship deletion delete all similar relationships for all orgs
--       including those adopted naturally or not.

       DELETE FROM OKC_ARTICLE_RELATNS_ALL
         WHERE SOURCE_ARTICLE_ID = p_source_article_id
           AND TARGET_ARTICLE_ID = p_target_article_id;

       DELETE FROM OKC_ARTICLE_RELATNS_ALL
         WHERE SOURCE_ARTICLE_ID = p_target_article_id
           AND TARGET_ARTICLE_ID = p_source_article_id;
/*
       DELETE_AUTO_ADOPTED_RELATIONS
          (
           x_return_status => x_return_status,
           x_msg_count  => x_msg_data,
           x_msg_data   => x_msg_data,
           p_fetchsize  => 100,
           p_source_global_article_id => p_source_article_id,
           p_target_global_article_id => p_target_article_id
           ) ;
*/
    END IF;
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving delete_row', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving delete_Row: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2500: Leaving delete_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('2600: Leaving delete_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

  END delete_article_relationship;

-- Bug#3722445: The following API will be used by the Update Article UI to check if future approved versions exist
-- in which case, the UI will prevent further update to end date.

  PROCEDURE later_approved_exists
   (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_article_id                   IN NUMBER,
    p_start_date                   IN DATE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_yes_no                       OUT NOCOPY VARCHAR2)
   IS
   l_yes_no                      VARCHAR2(1) := 'N';
   l_api_version                 CONSTANT NUMBER := 1;
   l_api_name                    CONSTANT VARCHAR2(30) := 'g_later_approved_exists';

   CURSOR l_highest_version_csr(cp_article_id IN NUMBER,
                                cp_start_date IN DATE) IS
    select
       'Y'
    from
       okc_article_versions av
    where
       av.article_id = cp_article_id and
       av.start_date > cp_start_date and
       av.article_status in ( 'APPROVED', 'HOLD') and
       rownum < 2;
   BEGIN
    x_yes_no := 'N';
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
     OPEN  l_highest_version_csr(p_article_id, p_start_date);
     FETCH l_highest_version_csr  INTO l_yes_no ;
     IF  l_highest_version_csr%NOTFOUND THEN
       l_yes_no := 'N';
     END IF;
     CLOSE  l_highest_version_csr;
     x_yes_no := l_yes_no;
     FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );
     EXCEPTION
       WHEN OTHERS THEN
          IF  l_highest_version_csr%ISOPEN Then
             close  l_highest_version_csr;
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,p_encoded=> 'F',  p_data => x_msg_data );

   END later_approved_exists;
-- MOAC
/*
  BEGIN
       OPEN cur_org_csr;
       FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
       CLOSE cur_org_csr;
*/

END OKC_ARTICLES_GRP;

/
