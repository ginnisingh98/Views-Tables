--------------------------------------------------------
--  DDL for Package Body OKC_NUMBER_SCHEME_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_NUMBER_SCHEME_GRP" AS
/* $Header: OKCGNSMB.pls 120.8 2006/10/05 23:30:51 ssivarap noship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_NUMBER_SCHEME_GRP';

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';

  G_NUMBER_SEQUENCE            CONSTANT   VARCHAR2(30)   :='NUMBER_SEQUENCE';
  G_LOWERCASE_ENG_ALPHABETS   CONSTANT   VARCHAR2(30)   :='LOWERCASE_ENG_ALPHABETS';
  G_UPPERCASE_ENG_ALPHABETS   CONSTANT   VARCHAR2(30)   :='UPPERCASE_ENG_ALPHABETS';

  G_UPPERCASE_ROMAN_NUMBER     CONSTANT   VARCHAR2(30)   :='UPPERCASE_ROMAN_NUMBER';
  G_LOWERCASE_ROMAN_NUMBER     CONSTANT   VARCHAR2(30)   :='LOWERCASE_ROMAN_NUMBER';

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;

  TYPE structure_rec_type IS RECORD (
      ID            NUMBER,
      Type          VARCHAR2(30),
      label         VARCHAR2(100)
   );

  TYPE structure_tbl_type IS TABLE OF structure_rec_type  INDEX BY BINARY_INTEGER;

  TYPE review_rec_type IS RECORD (
      review_upld_terms_id            NUMBER,
      object_id                           NUMBER,
      Type                                VARCHAR2(30),
      label                               VARCHAR2(100)
   );

  TYPE review_tbl_type IS TABLE OF review_rec_type  INDEX BY BINARY_INTEGER;

  l_structure_tbl   structure_tbl_type;
  l_review_tbl      review_tbl_type;

  l_lvl1_seq_code        VARCHAR2(30) := NULL;
  l_lvl2_seq_code        VARCHAR2(30) := NULL;
  l_lvl3_seq_code        VARCHAR2(30) := NULL;
  l_lvl4_seq_code        VARCHAR2(30) := NULL;
  l_lvl5_seq_code        VARCHAR2(30) := NULL;

  l_lvl1_sequence        NUMBER :=0;
  l_lvl2_sequence        NUMBER :=0;
  l_lvl3_sequence        NUMBER :=0;
  l_lvl4_sequence        NUMBER :=0;
  l_lvl5_sequence        NUMBER :=0;

  l_lvl1_concat_yn       VARCHAR2(1) := NULL;
  l_lvl2_concat_yn       VARCHAR2(1) := NULL;
  l_lvl3_concat_yn       VARCHAR2(1) := NULL;
  l_lvl4_concat_yn       VARCHAR2(1) := NULL;
  l_lvl5_concat_yn       VARCHAR2(1) := NULL;

--Bug 3663038 Used %type in declaration
  l_lvl1_end_char       OKC_NUMBER_SCHEME_DTLS.END_CHARACTER%TYPE := NULL;
  l_lvl2_end_char       OKC_NUMBER_SCHEME_DTLS.END_CHARACTER%TYPE := NULL;
  l_lvl3_end_char       OKC_NUMBER_SCHEME_DTLS.END_CHARACTER%TYPE := NULL;
  l_lvl4_end_char       OKC_NUMBER_SCHEME_DTLS.END_CHARACTER%TYPE := NULL;
  l_lvl5_end_char       OKC_NUMBER_SCHEME_DTLS.END_CHARACTER%TYPE := NULL;

  l_no_of_levels	NUMBER := 0;

  l_number_article_yn   VARCHAR2(1) :='Y';

/*
  API to conver numbers into excel like Cell numbers. Like 1 ==>A
                                                          27 ==> AA
                                                          28 ==> AB
                                                          52 ==> AZ
                                                          54 ==> BB
*/

 FUNCTION GETALPHABET(seq_number number,type varchar2) return varchar2 as
  l_floor number;
  l_mod number;
  l_out varchar2(10);
 begin
  l_floor := floor(seq_number/26);
  l_mod   := mod(seq_number,26);

  if l_floor > 0 and not(l_floor=1 and l_mod = 0) then

      Select GETALPHABET(Decode( l_mod,0,l_floor-1,l_floor),type) into l_out  from dual;

  end if;

  If l_mod=0 then
	   SELECT l_out||fnd_global.local_chr(26+decode(type,'L',96,'U',64))
            into l_out from dual;
	   return l_out;
  else
     SELECT  l_out||fnd_global.local_chr(l_mod+decode(type,'L',96,'U',64))
             into l_out from dual;
         return l_out;
  end if;
 end;

FUNCTION convert_to_roman(p_number IN INT) RETURN VARCHAR2 IS

out_roman varchar2(30);
left_over number;
thousand number;
five_hundred number;
hundred number;
fifty number;
tenth   number;
fifth   number;

begin
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('100: Inside convert_to_roman', 2);
         okc_debug.log('100: p_number : '||p_number, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '100: Inside convert_to_roman' );
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '100: p_number : '||p_number );
      END IF;

If p_number > 3999 then
   OKC_API.SET_MESSAGE('OKC','OKC_CANT_CONVERT_ROMAN');
   RAISE FND_API.G_EXC_ERROR ;

end if;

    thousand := floor(p_number/1000);
    left_over := mod(p_number,1000);
    five_hundred :=floor(left_over/500);
    left_over := mod(left_over,500);
    hundred  := floor(left_over/100);
    left_over := mod(left_over,100);
    fifty  := floor(left_over/50);
    left_over := mod(left_over,50);
    tenth  := floor(left_over/10);
    left_over := mod(left_over,10);
    fifth     :=  floor(left_over/5);
    left_over := mod(left_over,5);


    if  left_over < 4  then
          if left_over > 0 then
             for i in 1..left_over loop
                 out_roman := 'I'||out_roman;
             end loop;
          end if;

          if fifth > 0 then
             out_roman := 'V'||out_roman;
          end if;

   elsif left_over = 4 then

           if fifth > 0 then
             out_roman := 'IX';
            else
             out_roman := 'IV';
           end if;
   end if;

    if tenth < 4  then
        If tenth > 0  then
          for i in 1..tenth loop
            out_roman := 'X'||out_roman;
          end loop;
        end if;
           if fifty > 0 then
             out_roman := 'L'||out_roman;
           end if;
     elsif tenth = 4 then
             if fifty > 0 then
                 out_roman := 'XC'||out_roman;
             else
                 out_roman := 'XL'||out_roman;
             end if;
    end if;

   if hundred < 4  then
        If hundred > 0  then
          for i in 1..hundred loop
            out_roman := 'C'||out_roman;
          end loop;
        end if;
           if five_hundred > 0 then
             out_roman := 'D'||out_roman;
           end if;
     elsif hundred = 4 then
             if five_hundred > 0 then
                 out_roman := 'CM'||out_roman;
             else
                 out_roman := 'CD'||out_roman;
             end if;
    end if;
   If thousand < 4 then
        If thousand > 0  then
          for i in 1..thousand loop
            out_roman := 'M'||out_roman;
          end loop;
        end if;
   end if;

      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1000: Leaving convert_to_roman', 2);
         okc_debug.log('1000: out_roman : '||out_roman, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1000: Leaving convert_to_roman' );
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1000: out_roman : '||out_roman );
      END IF;

   return out_roman;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving convert_to_roman: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '300: Leaving convert_to_roman: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      raise;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving convert_to_roman: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '400: Leaving convert_to_roman: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;

      raise;


    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving convert_to_roman because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '500: Leaving convert_to_roman because of EXCEPTION: '||sqlerrm );
      END IF;

     raise;

END convert_to_roman;

FUNCTION get_numbering_seq(p_level NUMBER) return VARCHAR2 IS

l_number VARCHAR2(30);
l_lvl_sequence NUMBER;
l_vl_seq_code  VARCHAR2(30);
BEGIN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('100: Entering get_numbering_seq', 2);
         okc_debug.log('100: p_level : '||p_level, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '100: Entering get_numbering_seq' );
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '100: p_level : '||p_level );
      END IF;

Select decode(p_level,1,l_lvl1_seq_code,2,l_lvl2_seq_code,3,l_lvl3_seq_code,4,l_lvl4_seq_code,5,l_lvl5_seq_code,NULL)
INTO l_vl_seq_code from dual;

      /*IF (l_debug = 'Y') THEN
         okc_debug.log('150: l_vl_seq_code : '||l_vl_seq_code, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '150: l_vl_seq_code : '||l_vl_seq_code );
      END IF;

IF p_level = 1 THEN
   l_lvl1_sequence := l_lvl1_sequence+1;
   l_lvl_sequence  := l_lvl1_sequence;
ELSIF p_level = 2 THEN
   l_lvl2_sequence := l_lvl2_sequence+1;
   l_lvl_sequence := l_lvl2_sequence;
ELSIF p_level = 3 THEN
   l_lvl3_sequence := l_lvl3_sequence+1;
   l_lvl_sequence := l_lvl3_sequence;

ELSIF p_level = 4 THEN
   l_lvl4_sequence := l_lvl4_sequence+1;
   l_lvl_sequence := l_lvl4_sequence;

ELSIF p_level = 5 THEN
   l_lvl5_sequence := l_lvl5_sequence+1;
   l_lvl_sequence := l_lvl5_sequence;
ELSE
      l_lvl_sequence := NULL;
END IF;

      /*IF (l_debug = 'Y') THEN
         okc_debug.log('180: l_lvl_sequence : '||l_lvl_sequence, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '180: l_lvl_sequence : '||l_lvl_sequence );
      END IF;

IF l_vl_seq_code = G_NUMBER_SEQUENCE THEN
   l_number := l_lvl_sequence;
ELSIF l_vl_seq_code = G_UPPERCASE_ROMAN_NUMBER THEN
   l_number := upper(convert_to_roman(l_lvl_sequence));
ELSIF l_vl_seq_code = G_LOWERCASE_ROMAN_NUMBER THEN
   l_number := lower(convert_to_roman(l_lvl_sequence));
ELSIF l_vl_seq_code = G_LOWERCASE_ENG_ALPHABETS THEN
   l_number := getalphabet(l_lvl_sequence,'L');
ELSIF l_vl_seq_code = G_UPPERCASE_ENG_ALPHABETS THEN
         l_number := getalphabet(l_lvl_sequence,'U');
ELSE
   l_number := NULL;
END IF;


      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving  get_numbering_seq ', 2);
         okc_debug.log('300: l_number : '||l_number, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '300: Leaving  get_numbering_seq ' );
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '300: l_number : '||l_number );
      END IF;

return l_number;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   /*IF (l_debug = 'Y') THEN
        okc_debug.log('400: Leaving get_numbering_seq: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
    	   G_PKG_NAME, '400: Leaving get_numbering_seq: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
   END IF;

   raise;

WHEN OTHERS THEN
   /*IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving get_numbering_seq because of EXCEPTION: '||sqlerrm, 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
    	   G_PKG_NAME, '500: Leaving get_numbering_seq because of EXCEPTION: '||sqlerrm );
   END IF;

   raise;
END get_numbering_seq;


procedure section_numbering(p_doc_type varchar2,p_doc_id NUMBER,p_level NUMBER,p_parent_label VARCHAR2,p_scn_id NUMBER) IS

cursor l_get_child_csr IS
SELECT ID,'SECTION' TYPE,section_sequence display_sequence from okc_sections_b
where scn_id=p_scn_id
and   document_type=p_doc_type
and   document_id = p_doc_id
AND   nvl(amendment_operation_code,'?') <> 'DELETED'
AND   nvl(summary_amend_operation_code,'?') <> 'DELETED'
UNION
SELECT ID,'ARTICLE' TYPE,display_sequence display_sequence from okc_k_ARTICLES_b
where scn_id=p_scn_id
and   document_type=p_doc_type
and   document_id = p_doc_id
AND   nvl(amendment_operation_code,'?') <> 'DELETED'
AND   nvl(summary_amend_operation_code,'?') <> 'DELETED'
AND l_number_article_yn = 'Y'
Order by 3;

  l_concat_yn      VARCHAR2(30) := 'N';
  l_end_char       VARCHAR2(30) := NULL;
  l_label          Varchar2(30) := NULL;
  l_number         Varchar2(30) := NULL;
  l_next_parent_number Varchar2(30) := NULL;
  i               NUMBER;
BEGIN

  /*IF (l_debug = 'Y') THEN
    okc_debug.log('100: Entering  section_numbering ', 2);
    okc_debug.log('100: Parameters ', 2);
    okc_debug.log('100: p_doc_type : '||p_doc_type, 2);
    okc_debug.log('100: p_doc_id : '||p_doc_id, 2);
    okc_debug.log('100: p_level : '||p_level, 2);
    okc_debug.log('100: p_parent_label : '||p_parent_label, 2);
    okc_debug.log('100: p_scn_id : '||p_scn_id, 2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: Entering  section_numbering ' );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: Parameters ' );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_doc_type : '||p_doc_type );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_doc_id : '||p_doc_id );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_level : '||p_level );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_parent_label : '||p_parent_label );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_scn_id : '||p_scn_id );
  END IF;

select decode(p_level,1,NULL,2,l_lvl1_concat_yn,3,l_lvl2_concat_yn,4,l_lvl3_concat_yn,5,l_lvl4_concat_yn,'N'),
       decode(p_level,1,l_lvl1_end_char ,2,l_lvl2_end_char ,3,l_lvl3_end_char ,4,l_lvl4_end_char ,5,l_lvl5_end_char ,NULL)
into l_concat_yn ,l_end_char from dual;

  /*IF (l_debug = 'Y') THEN
    okc_debug.log('110: l_concat_yn : '||l_concat_yn, 2);
    okc_debug.log('110: l_end_char : '||l_end_char, 2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '110: l_concat_yn : '||l_concat_yn );
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '110: l_end_char : '||l_end_char );
  END IF;

FOR cr in l_get_child_csr LOOP
    l_number := get_numbering_seq(p_level);
    IF l_concat_yn='Y' THEN
       l_label := p_parent_label||'.'||l_number||l_end_char;
       l_next_parent_number := p_parent_label||'.'||l_number;
    ElSE
       l_label := l_number||l_end_char;
       l_next_parent_number := l_number;
    END IF;

    i := l_structure_tbl.count+1;
    l_structure_tbl(i).id := cr.id;
    l_structure_tbl(i).type := cr.type;
    l_structure_tbl(i).label := l_label;

     /*IF (l_debug = 'Y') THEN
       okc_debug.log('120: i : '||i, 2);
       okc_debug.log('120: l_structure_tbl(i).id : '||l_structure_tbl(i).id, 2);
       okc_debug.log('120: l_structure_tbl(i).type : '||l_structure_tbl(i).type, 2);
       okc_debug.log('120: l_structure_tbl(i).label : '||l_structure_tbl(i).label, 2);
     END IF;*/

     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '120: i : '||i );
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '120: l_structure_tbl(i).id : '||l_structure_tbl(i).id );
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '120: l_structure_tbl(i).type : '||l_structure_tbl(i).type );
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '120: l_structure_tbl(i).label : '||l_structure_tbl(i).label );
     END IF;

    IF cr.type='SECTION' THEN
       IF p_level = 1 THEN
          l_lvl2_sequence := 0;
       ELSIF p_level = 2 THEN
          l_lvl3_sequence := 0;
       ELSIF p_level = 3 THEN
          l_lvl4_sequence := 0;
        ELSIF p_level = 4 THEN
          l_lvl5_sequence := 0;
        ELSE
          NULL;
        END IF;

       IF l_no_of_levels > p_level then
         section_numbering(p_doc_type=>p_doc_type, p_doc_id => p_doc_id,p_level => p_level + 1,p_parent_label => l_next_parent_number,p_scn_id => cr.id) ;
       END IF;
    END IF;
END LOOP;


      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving  section_numbering ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '300: Leaving  section_numbering ' );
      END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   /*IF (l_debug = 'Y') THEN
        okc_debug.log('400: Leaving section_numbering: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
	   G_PKG_NAME, '400: Leaving section_numbering: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
   END IF;

   raise;

WHEN OTHERS THEN
   /*IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving section_numbering because of EXCEPTION: '||sqlerrm, 2);
   END IF;*/

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
	   G_PKG_NAME, '500: Leaving section_numbering because of EXCEPTION: '||sqlerrm );
   END IF;

   raise;
END section_numbering;

PROCEDURE generate_preview(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_out_string                   OUT NOCOPY VARCHAR2,
    p_update_db                    IN  VARCHAR2 ,

    p_num_scheme_id                IN NUMBER
      ) IS
   Cursor l_num_sch_dtl_crs IS
   SELECT  decode(Num_Sequence_code, G_NUMBER_SEQUENCE,'1',G_LOWERCASE_ENG_ALPHABETS,'a',G_UPPERCASE_ENG_ALPHABETS,'A',G_LOWERCASE_ROMAN_NUMBER,'i',G_UPPERCASE_ROMAN_NUMBER,'I') label1,
           decode(Num_Sequence_code, G_NUMBER_SEQUENCE,'2',G_LOWERCASE_ENG_ALPHABETS,'b',G_UPPERCASE_ENG_ALPHABETS,'B',G_LOWERCASE_ROMAN_NUMBER,'ii',G_UPPERCASE_ROMAN_NUMBER,'II')label2,
           concatenation_yn,
           sequence_level,
           End_character
   FROM OKC_NUMBER_SCHEME_DTLS
   WHERE Num_scheme_Id = p_num_scheme_id
   order by Sequence_Level;

   l_out  Varchar2(2000) :=NULL;
   l_string  Varchar2(2000) :=NULL;
   l_concat_yn Varchar2(1);
   l_label  varchar2(30);
   l_api_name  Varchar2(30) :='generate_preview';
   l_api_version NUMBER :=1;
   k  NUMBER :=0;
BEGIN
    /*IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered generate_preview', 2);
       okc_debug.log('100: p_num_scheme_id : '||p_num_scheme_id, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Entered generate_preview' );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_num_scheme_id : '||p_num_scheme_id );
    END IF;

        -- Standard Start of API savepoint
    SAVEPOINT g_generate_preview;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

FOR i in 1..2 LOOP
    l_concat_yn := 'N';
    l_label       := NULL;
    l_string      := NULL;
    k             :=0;
   FOR cr IN l_num_sch_dtl_crs LOOP
           k:=k+1;

           SELECT
           decode(l_concat_yn,'Y',l_label||'.'||decode(k,1,decode(i,1,cr.label1,2,cr.label2,cr.label1),cr.label1),decode(k,1,decode(i,1,cr.label1,2,cr.label2,cr.label1),cr.label1))
          INTO l_label FROM DUAL;

            l_string :=l_label ||cr.end_character||' '||ltrim(rtrim(okc_util.decode_lookup('OKC_NUMBER_LEVEL',cr.sequence_level)));

            FOR i in 1..cr.sequence_level LOOP
                 l_string := '    '||l_string;
            END LOOP;

           l_string := l_string ||fnd_global.newline;
           l_concat_yn := cr.concatenation_yn;
           l_out := l_out||l_string;
    END LOOP;
END LOOP;
 x_out_string := l_out;

IF p_update_db=FND_API.G_TRUE THEN

   Update OKC_NUMBER_SCHEMES_B SET
         num_scheme_preview            = x_out_string,
         object_version_number         = object_version_number+1,
         creation_date                 = sysdate,
         created_by                    = Fnd_Global.User_Id,
         last_update_date              = sysdate,
         last_updated_by               = Fnd_Global.User_Id,
         last_update_login             = Fnd_Global.Login_Id
   WHERE  num_scheme_id         = p_num_scheme_id;
   Commit;

END IF;

      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving  generate_preview ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '300: Leaving generate_preview' );
      END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving generate_preview: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '2400: Leaving generate_preview: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      Rollback to g_generate_preview;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving generate_preview: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '2400: Leaving generate_preview: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      Rollback to g_generate_preview;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving generate_preview: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '2400: Leaving generate_preview: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      Rollback to g_generate_preview;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END generate_preview;

  PROCEDURE apply_numbering_scheme(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_num_scheme_id                IN NUMBER
      ) IS

  l_api_version   NUMBER :=1;
  l_api_name      VARCHAR2(30) := 'apply_numbering_scheme';

cursor l_get_child_csr IS
SELECT ID,section_sequence  from okc_sections_b
where document_type = p_doc_type
AND   document_id   = p_doc_id
AND SCN_ID IS NULL
AND    nvl(amendment_operation_code,'?') <> 'DELETED'
AND   nvl(summary_amend_operation_code,'?') <> 'DELETED'
Order by section_sequence;

cursor l_get_num_scheme IS
SELECT number_article_yn  from OKC_NUMBER_SCHEMES_B
where num_scheme_id=p_num_scheme_id;

cursor l_get_num_scheme_dtl IS
SELECT num_sequence_code,sequence_level,concatenation_yn,end_character  from OKC_NUMBER_SCHEME_DTLS
where num_scheme_id=p_num_scheme_id;

cursor l_get_usage_rec IS
SELECT template_id,object_version_number  from OKC_template_usages
where document_type=p_doc_type and document_id=p_doc_id;

CURSOR l_get_art_csr IS
SELECT id,object_version_number
FROM okc_k_articles_b
WHERE document_type=p_doc_type
AND document_id=p_doc_id
AND nvl(amendment_operation_code,'?') <> 'DELETED'
AND nvl(summary_amend_operation_code,'?') <> 'DELETED'
AND label is NOT NULL;

l_label          Varchar2(30) := NULL;
l_number         Varchar2(30) := NULL;
i                NUMBER;

CURSOR l_get_dtl_count IS
SELECT COUNT(*)
FROM OKC_NUMBER_SCHEME_DTLS
WHERE num_scheme_id=p_num_scheme_id;

l_dtl_count  NUMBER;


BEGIN

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('100: Entered apply_numbering_scheme', 2);
      okc_debug.log('100: Parameter List ', 2);
      okc_debug.log('100: p_api_version : '||p_api_version, 2);
      okc_debug.log('100: p_init_msg_list : '||p_init_msg_list, 2);
      okc_debug.log('100: p_commit : '||p_commit, 2);
      okc_debug.log('100: p_validate_commit  : '||p_validate_commit, 2);
      okc_debug.log('100: p_validation_string : '||p_validation_string , 2);
      okc_debug.log('100: p_doc_type : '||p_doc_type, 2);
      okc_debug.log('100: p_doc_id : '||p_doc_id, 2);
      okc_debug.log('100: p_num_scheme_id : '||p_num_scheme_id, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Entered apply_numbering_scheme' );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Parameter List ' );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_api_version : '||p_api_version );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_commit : '||p_commit );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_validate_commit  : '||p_validate_commit );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_validation_string : '||p_validation_string );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_doc_type : '||p_doc_type );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_doc_id : '||p_doc_id );
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_num_scheme_id : '||p_num_scheme_id );
    END IF;

    -- Initialize the global Structure Table bug 3200243
    l_structure_tbl.DELETE;

    -- Standard Start of API savepoint
    SAVEPOINT g_apply_numbering_scheme;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   IF FND_API.To_Boolean( p_validate_commit ) THEN

      IF  NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => p_doc_type,
                                         p_doc_id	 => p_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

             /*IF (l_debug = 'Y') THEN
                okc_debug.log('110: Issue with document header Record.Cannot commit', 2);
             END IF;*/

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
		 FND_LOG.STRING(G_PROC_LEVEL,
		     G_PKG_NAME, '110: Issue with document header Record.Cannot commit' );
	     END IF;
             RAISE FND_API.G_EXC_ERROR ;
         END IF;
   END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- if Count of Numbering Scheme Detail is 0 , then this is the no numbering scheme
-- in this case we need to remove the label from sections and articles table
  OPEN l_get_dtl_count;
    FETCH l_get_dtl_count INTO l_dtl_count;
  CLOSE l_get_dtl_count;

  l_no_of_levels := l_dtl_count;

  /*IF (l_debug = 'Y') THEN
     okc_debug.log('110: Numbering Scheme Detail Count : '||l_dtl_count,2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '110: Numbering Scheme Detail Count : '||l_dtl_count );
  END IF;

--IF l_dtl_count = 0 THEN
    -- do bulk update on sections and articles records
    -- update okc_sections_b
       UPDATE okc_sections_b
          SET label = NULL
       WHERE document_type = p_doc_type
         AND   document_id   = p_doc_id ;

    -- update okc_k_articles_b
       UPDATE okc_k_articles_b
          SET label = NULL
       WHERE document_type = p_doc_type
         AND   document_id   = p_doc_id ;

--ELSE
IF NVL(l_dtl_count,0) > 0 THEN
  -- dtl count > 0

  OPEN l_get_num_scheme ;
  FETCH l_get_num_scheme  INTO l_number_article_yn  ;
  IF l_get_num_scheme%NOTFOUND THEN
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_get_num_scheme ;

  /*IF (l_debug = 'Y') THEN
     okc_debug.log('120: l_number_article_yn : '||l_number_article_yn, 2);
  END IF;*/

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '120: l_number_article_yn : '||l_number_article_yn );
  END IF;

  FOR CR in l_get_num_scheme_dtl LOOP
   IF cr.sequence_level=1 THEN
      l_lvl1_seq_code  := cr.num_sequence_code;
      l_lvl1_concat_yn := cr.concatenation_yn;
      l_lvl1_end_char  := cr.end_character;
   ELSIF cr.sequence_level=2 THEN
      l_lvl2_seq_code  := cr.num_sequence_code;
      l_lvl2_concat_yn := cr.concatenation_yn;
      l_lvl2_end_char  := cr.end_character;
   ELSIF cr.sequence_level=3 THEN
      l_lvl3_seq_code  := cr.num_sequence_code;
      l_lvl3_concat_yn := cr.concatenation_yn;
      l_lvl3_end_char  := cr.end_character;
   ELSIF cr.sequence_level=4 THEN
      l_lvl4_seq_code  := cr.num_sequence_code;
      l_lvl4_concat_yn := cr.concatenation_yn;
      l_lvl4_end_char  := cr.end_character;
   ELSIF cr.sequence_level=5 THEN
      l_lvl5_seq_code  := cr.num_sequence_code;
      l_lvl5_concat_yn := cr.concatenation_yn;
      l_lvl5_end_char  := cr.end_character;
    END IF;

 END LOOP;

  /*IF (l_debug = 'Y') THEN
     okc_debug.log('130: Sequence Level 1  ', 2);
     okc_debug.log('130: l_lvl1_seq_code  : '||l_lvl1_seq_code, 2);
     okc_debug.log('130: l_lvl1_concat_yn : '||l_lvl1_concat_yn, 2);
     okc_debug.log('130: l_lvl1_end_char  : '||l_lvl1_end_char, 2);
     okc_debug.log('130: Sequence Level 2  ', 2);
     okc_debug.log('130: l_lvl2_seq_code  : '||l_lvl2_seq_code, 2);
     okc_debug.log('130: l_lvl2_concat_yn : '||l_lvl2_concat_yn, 2);
     okc_debug.log('130: l_lvl2_end_char  : '||l_lvl2_end_char, 2);
     okc_debug.log('130: Sequence Level 3  ', 2);
     okc_debug.log('130: l_lvl3_seq_code  : '||l_lvl3_seq_code, 2);
     okc_debug.log('130: l_lvl3_concat_yn : '||l_lvl3_concat_yn, 2);
     okc_debug.log('130: l_lvl3_end_char  : '||l_lvl3_end_char, 2);
     okc_debug.log('130: Sequence Level 4  ', 2);
     okc_debug.log('130: l_lvl4_seq_code  : '||l_lvl4_seq_code, 2);
     okc_debug.log('130: l_lvl4_concat_yn : '||l_lvl4_concat_yn, 2);
     okc_debug.log('130: l_lvl4_end_char  : '||l_lvl4_end_char, 2);
     okc_debug.log('130: Sequence Level 5  ', 2);
     okc_debug.log('130: l_lvl5_seq_code  : '||l_lvl5_seq_code, 2);
     okc_debug.log('130: l_lvl5_concat_yn : '||l_lvl5_concat_yn, 2);
     okc_debug.log('130: l_lvl5_end_char  : '||l_lvl5_end_char, 2);
  END IF;*/


  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 1  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl1_seq_code  : '||l_lvl1_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl1_concat_yn : '||l_lvl1_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl1_end_char  : '||l_lvl1_end_char);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 2  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl2_seq_code  : '||l_lvl2_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl2_concat_yn : '||l_lvl2_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl2_end_char  : '||l_lvl2_end_char);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 3  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl3_seq_code  : '||l_lvl3_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl3_concat_yn : '||l_lvl3_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl3_end_char  : '||l_lvl3_end_char);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 4  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl4_seq_code  : '||l_lvl4_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl4_concat_yn : '||l_lvl4_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl4_end_char  : '||l_lvl4_end_char);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 5  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl5_seq_code  : '||l_lvl5_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl5_concat_yn : '||l_lvl5_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl5_end_char  : '||l_lvl5_end_char);
  END IF;

  l_lvl1_sequence     :=0;
  l_lvl2_sequence     :=0;
  l_lvl3_sequence     :=0;
  l_lvl4_sequence     :=0;
  l_lvl5_sequence     :=0;

FOR cr in l_get_child_csr LOOP

    l_number := get_numbering_seq(p_level => 1);

     /*IF (l_debug = 'Y') THEN
        okc_debug.log('140: l_number : '||l_number, 2);
     END IF;*/

     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '140: l_number : '||l_number );
     END IF;

    l_label := l_number||l_lvl1_end_char;

     /*IF (l_debug = 'Y') THEN
        okc_debug.log('150: l_label : '||l_label, 2);
     END IF;*/

     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '150: l_label : '||l_label );
     END IF;

    i := l_structure_tbl.count+1;
    l_structure_tbl(i).id := cr.id;
    l_structure_tbl(i).type := 'SECTION';
    l_structure_tbl(i).label := l_label;

    l_lvl2_sequence := 0;

    IF l_no_of_levels > 1 THEN
      section_numbering(p_doc_type=>p_doc_type, p_doc_id => p_doc_id,p_level => 2,p_parent_label => l_number,p_scn_id => cr.id) ;
    END IF;

END LOOP;

     /*IF (l_debug = 'Y') THEN
        okc_debug.log('160: Count of l_structure_tbl : '||l_structure_tbl.count, 2);
     END IF;*/

     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '160: Count of l_structure_tbl : '||l_structure_tbl.count );
     END IF;

IF l_structure_tbl.count > 0 THEN
   For k in l_structure_tbl.FIRST..l_structure_tbl.LAST LOOP
            IF l_structure_tbl(k).type ='SECTION' THEN

                     /*IF (l_debug = 'Y') THEN
                        okc_debug.log('170: Calling OKC_TERMS_SECTIONS_GRP.update_section', 2);
                        okc_debug.log('170: l_structure_tbl(k).id : '||l_structure_tbl(k).id, 2);
                        okc_debug.log('170: l_structure_tbl(k).label : '||l_structure_tbl(k).label, 2);
                     END IF;*/

		     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
  		         FND_LOG.STRING(G_PROC_LEVEL,
		             G_PKG_NAME, '170: Calling OKC_TERMS_SECTIONS_GRP.update_section' );
  		         FND_LOG.STRING(G_PROC_LEVEL,
		             G_PKG_NAME, '170: l_structure_tbl(k).id : '||l_structure_tbl(k).id );
  		         FND_LOG.STRING(G_PROC_LEVEL,
		             G_PKG_NAME, '170: l_structure_tbl(k).label : '||l_structure_tbl(k).label );
		     END IF;

                  OKC_TERMS_SECTIONS_GRP.update_section(
                                     p_api_version  => 1,
                                     p_init_msg_list => FND_API.G_FALSE,
                                     p_mode          => 'NORMAL',
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_id            => l_structure_tbl(k).id,
                                     p_label         => l_structure_tbl(k).label,
                                     p_object_version_number  => NULL
                                                   );

                     /*IF (l_debug = 'Y') THEN
                      okc_debug.log('170: After Calling OKC_TERMS_SECTIONS_GRP.update_section x_return_status : '||x_return_status, 2);
                     END IF;*/

			 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
			     FND_LOG.STRING(G_PROC_LEVEL,
			         G_PKG_NAME, '170: After Calling OKC_TERMS_SECTIONS_GRP.update_section x_return_status : '||x_return_status );
			 END IF;

                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                       RAISE FND_API.G_EXC_ERROR ;
                  END IF;
            ELSIF  l_structure_tbl(k).type ='ARTICLE' THEN

                     /*IF (l_debug = 'Y') THEN
                        okc_debug.log('180: Calling OKC_K_ARTICLES_GRP.update_article', 2);
                        okc_debug.log('180: l_structure_tbl(k).id : '||l_structure_tbl(k).id, 2);
                        okc_debug.log('180: l_structure_tbl(k).label : '||l_structure_tbl(k).label, 2);
                     END IF;*/

			 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
			     FND_LOG.STRING(G_PROC_LEVEL,
			         G_PKG_NAME, '180: Calling OKC_K_ARTICLES_GRP.update_article');
			     FND_LOG.STRING(G_PROC_LEVEL,
			         G_PKG_NAME, '180: l_structure_tbl(k).id : '||l_structure_tbl(k).id);
			     FND_LOG.STRING(G_PROC_LEVEL,
			         G_PKG_NAME, '180: l_structure_tbl(k).label : '||l_structure_tbl(k).label);
			 END IF;

                  OKC_K_ARTICLES_GRP.update_article(
                                     p_api_version  => 1,
                                     p_init_msg_list => FND_API.G_FALSE,
                                     p_mode          => 'NORMAL',
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_id            => l_structure_tbl(k).id,
                                     p_label         => l_structure_tbl(k).label,
                                     p_object_version_number  => NULL
                                                   );
                     /*IF (l_debug = 'Y') THEN
                      okc_debug.log('180: After Calling OKC_TERMS_SECTIONS_GRP.update_section x_return_status : '||x_return_status, 2);
                     END IF;*/

		     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
			     FND_LOG.STRING(G_PROC_LEVEL,
			         G_PKG_NAME, '180: After Calling OKC_TERMS_SECTIONS_GRP.update_section x_return_status : '||x_return_status );
			 END IF;

                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                       RAISE FND_API.G_EXC_ERROR ;
                  END IF;
            END IF;
   END LOOP;
 END IF; -- l_structure_tbl.count > 0

 /******* Not needed as all the labels are being updated in the begining itself
 IF l_number_article_yn <>'Y' THEN
   -- if any articles are already numbered, make label to null
   FOR cr in l_get_art_csr LOOP
                     OKC_K_ARTICLES_GRP.update_article(
                                     p_api_version  => 1,
                                     p_init_msg_list => FND_API.G_FALSE,
                                     p_mode          => 'NORMAL',
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_id            => cr.id,
                                     p_label         => OKC_API.G_MISS_CHAR,
                                     p_object_version_number  => cr.object_version_number
                                                   );

                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                       RAISE FND_API.G_EXC_ERROR ;
                  END IF;

   END LOOP;
 END IF; -- l_number_article_yn <>'Y'
 ***********/

END IF; -- detail count is 0 i.e no numbering scheme





IF p_doc_type='TEMPLATE' THEN

       /*IF (l_debug = 'Y') THEN
           okc_debug.log('300: p_doc_type = TEMPLATE', 2);
           okc_debug.log('300: OKC_TERMS_TEMPLATES_GRP.update_template', 2);
       END IF;*/

       IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
           FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '300: p_doc_type = TEMPLATE' );
           FND_LOG.STRING(G_PROC_LEVEL,
               G_PKG_NAME, '300: OKC_TERMS_TEMPLATES_GRP.update_template' );
       END IF;

    OKC_TERMS_TEMPLATES_GRP.update_template(
                             p_api_version   => 1,
                             p_init_msg_list => FND_API.G_FALSE,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_template_name => NULL,
                             p_template_id   => p_doc_id,
                             p_working_copy_flag =>NULL,
                             p_intent                  =>NULL,
                             p_status_code             =>NULL,
                             p_start_date              =>NULL,
                             p_end_date                =>NULL,
                             p_global_flag             =>NULL,
                             p_parent_template_id      =>NULL,
                             p_print_template_id       =>NULL,
                             p_contract_expert_enabled =>NULL,
                             p_template_model_id       =>NULL,
                             p_instruction_text        =>NULL,
                             p_tmpl_numbering_scheme   =>p_num_scheme_id,
                             p_description             =>NULL,
                             p_org_id                  => NULL,
                             p_object_version_number   => NULL
                             );

                  /*IF (l_debug = 'Y') THEN
                     okc_debug.log('300: After Call to OKC_TERMS_TEMPLATES_GRP.update_template x_return_status : '||x_return_status, 2);
                  END IF;*/

		  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
		      FND_LOG.STRING(G_PROC_LEVEL,
	                  G_PKG_NAME, '300: After Call to OKC_TERMS_TEMPLATES_GRP.update_template x_return_status : '||x_return_status );
		  END IF;

                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                       RAISE FND_API.G_EXC_ERROR ;
                  END IF;


ELSE
  FOR cr in l_get_usage_rec LOOP

-- Updating usage rec with numbering scheme
       /*IF (l_debug = 'Y') THEN
           okc_debug.log('400: OKC_TEMPLATE_USAGES_GRP.update_template_usages', 2);
       END IF;*/

       IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
           FND_LOG.STRING(G_PROC_LEVEL,
	       G_PKG_NAME, '400: OKC_TEMPLATE_USAGES_GRP.update_template_usages' );
	END IF;

     OKC_TEMPLATE_USAGES_GRP.update_template_usages(
                          p_api_version  =>1,
                          p_init_msg_list => FND_API.G_FALSE,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_document_type => p_doc_type,
                          p_document_id   => p_doc_id,
                          p_template_id   => cr.template_id,
                          p_doc_numbering_scheme=>p_num_scheme_id ,
                          p_document_number        =>NULL,
                          p_article_effective_date => NULL,
                          p_config_header_id       =>NULL,
                          p_config_revision_number =>NULL,
                          p_valid_config_yn        =>NULL,
                          p_object_version_number  =>cr.object_version_number
                          );

       /*IF (l_debug = 'Y') THEN
           okc_debug.log('400: After Call to OKC_TEMPLATE_USAGES_GRP.update_template_usages x_return_status : '||x_return_status, 2);
       END IF;*/

       IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	   FND_LOG.STRING(G_PROC_LEVEL,
	       G_PKG_NAME, '400: After Call to OKC_TEMPLATE_USAGES_GRP.update_template_usages x_return_status : '||x_return_status );
       END IF;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
      END IF;
   EXIT;
 END LOOP;
END IF;

     -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving apply_numbering_scheme', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '2000: Leaving apply_numbering_scheme' );
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving apply_numbering_scheme: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '2400: Leaving apply_numbering_scheme: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      ROLLBACK TO g_apply_numbering_scheme;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving apply_numbering_scheme: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '2400: Leaving apply_numbering_scheme: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      ROLLBACK TO g_apply_numbering_scheme;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving apply_numbering_scheme: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
   	      G_PKG_NAME, '2400: Leaving apply_numbering_scheme: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      ROLLBACK TO g_apply_numbering_scheme;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END apply_numbering_scheme;


  FUNCTION Ok_To_Delete(
    p_num_scheme_id         IN NUMBER
   ) RETURN VARCHAR2 IS
    CURSOR used_in_tmpl_crs IS
     SELECT 'N' from OKC_TERMS_TEMPLATES_ALL
      WHERE TMPL_NUMBERING_SCHEME=p_num_scheme_id;
    CURSOR used_in_doc_crs IS -- it's required index on DOC_NUMBERING_SCHEME column
     SELECT 'N' from OKC_TEMPLATE_USAGES_V
      WHERE DOC_NUMBERING_SCHEME=p_num_scheme_id;
     l_ret VARCHAR2(1) := 'Y';
   BEGIN
    OPEN used_in_tmpl_crs;
    FETCH used_in_tmpl_crs INTO l_ret;
    CLOSE used_in_tmpl_crs;
    IF l_ret='Y' THEN
      OPEN used_in_doc_crs;
      FETCH used_in_doc_crs INTO l_ret;
      CLOSE used_in_doc_crs;
    END IF;
    RETURN l_ret;
   EXCEPTION
    WHEN OTHERS THEN
     IF used_in_tmpl_crs%ISOPEN THEN
       CLOSE used_in_tmpl_crs;
     END IF;
     IF used_in_doc_crs%ISOPEN THEN
       CLOSE used_in_doc_crs;
     END IF;
     RETURN NULL;
  END Ok_To_Delete;

procedure review_section_numbering(
      p_doc_type varchar2,
      p_doc_id NUMBER,
      p_level NUMBER,
      p_parent_label VARCHAR2,
      p_review_upld_terms_id NUMBER) IS

cursor l_get_child_csr IS
SELECT review_upld_terms_id,
       object_type TYPE,
	  display_seq,
	  object_id
from okc_review_upld_terms
where new_parent_id=p_review_upld_terms_id
and   document_type=p_doc_type
and   document_id = p_doc_id
and   (object_type = 'SECTION'
      OR (object_type = 'ARTICLE'
         and   l_number_article_yn = 'Y'))
/***********
UNION
SELECT review_upld_terms_id,'ARTICLE' TYPE,display_seq, object_id from okc_review_upld_terms
where new_parent_id=p_review_upld_terms_id
and   document_type=p_doc_type
and   document_id = p_doc_id
and   object_type = 'ARTICLE'
*********/
Order by 3;

  l_concat_yn      VARCHAR2(30) := 'N';
  l_end_char       VARCHAR2(30) := NULL;
  l_label          Varchar2(30) := NULL;
  l_number         Varchar2(30) := NULL;
  l_next_parent_number Varchar2(30) := NULL;
  i               NUMBER;
BEGIN

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: Entering  review_section_numbering ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: Parameters ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_doc_type : '||p_doc_type);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_doc_id : '||p_doc_id);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_level : '||p_level);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: p_parent_label : '||p_parent_label);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '100: review_upld_terms_id : '||p_review_upld_terms_id);
  END IF;

select decode(p_level,1,NULL,2,l_lvl1_concat_yn,3,l_lvl2_concat_yn,4,l_lvl3_concat_yn,5,l_lvl4_concat_yn,'N'),
       decode(p_level,1,l_lvl1_end_char ,2,l_lvl2_end_char ,3,l_lvl3_end_char ,4,l_lvl4_end_char ,5,l_lvl5_end_char ,NULL)
into l_concat_yn ,l_end_char from dual;

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '110: l_concat_yn : '||l_concat_yn );
      FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '110: l_end_char : '||l_end_char );
  END IF;

FOR cr in l_get_child_csr LOOP
    l_number := get_numbering_seq(p_level);
    IF l_concat_yn='Y' THEN
       l_label := p_parent_label||'.'||l_number||l_end_char;
       l_next_parent_number := p_parent_label||'.'||l_number;
    ElSE
       l_label := l_number||l_end_char;
       l_next_parent_number := l_number;
    END IF;

    i := l_review_tbl.count+1;
    l_review_tbl(i).review_upld_terms_id := cr.review_upld_terms_id;
    l_review_tbl(i).type := cr.type;
    l_review_tbl(i).label := l_label;

     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '120: i : '||i);
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '120: l_review_tbl(i).id : '||l_review_tbl(i).review_upld_terms_id);
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '120: l_review_tbl(i).type : '||l_review_tbl(i).type);
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '120: l_review_tbl(i).label : '||l_review_tbl(i).label);
     END IF;

    IF cr.type='SECTION' THEN
       IF p_level = 1 THEN
          l_lvl2_sequence := 0;
       ELSIF p_level = 2 THEN
          l_lvl3_sequence := 0;
       ELSIF p_level = 3 THEN
          l_lvl4_sequence := 0;
        ELSIF p_level = 4 THEN
          l_lvl5_sequence := 0;
        ELSE
          NULL;
        END IF;

       IF l_no_of_levels > p_level then
         review_section_numbering(p_doc_type=>p_doc_type,
	                             p_doc_id => p_doc_id,
						    p_level => p_level + 1,
						    p_parent_label => l_next_parent_number,
						    p_review_upld_terms_id => cr.review_upld_terms_id) ;
       END IF;
    END IF;
END LOOP;

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '300: Leaving  review_section_numbering ' );
      END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
   	   G_PKG_NAME, '400: Leaving review_section_numbering: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
   END IF;

   raise;

WHEN OTHERS THEN

   IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_EXCP_LEVEL,
   	   G_PKG_NAME, '500: Leaving review_section_numbering because of EXCEPTION: '||sqlerrm);
   END IF;

   raise;
END review_section_numbering;


PROCEDURE apply_num_scheme_4_Review(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_num_scheme_id                IN NUMBER
      ) IS

  l_api_version   NUMBER :=1;
  l_api_name      VARCHAR2(30) := 'apply_num_scheme_4_Review';

cursor l_get_child_csr IS
SELECT review_upld_terms_id,display_seq, object_id
from okc_review_upld_terms
where document_type = p_doc_type
AND   document_id   = p_doc_id
AND   object_type = 'SECTION'
--and (action <> 'DELETED' OR action is null)
AND new_parent_id = (select review_upld_terms_id
                     from okc_review_upld_terms rt
				 where rt.document_type = p_doc_type
				 and rt.document_id = p_doc_id
				 and rt.object_type = p_doc_type
				 and rt.object_id = p_doc_id)
Order by display_seq;

cursor l_get_num_scheme IS
SELECT number_article_yn  from OKC_NUMBER_SCHEMES_B
where num_scheme_id=p_num_scheme_id;

cursor l_get_num_scheme_dtl IS
SELECT num_sequence_code,sequence_level,concatenation_yn,end_character  from OKC_NUMBER_SCHEME_DTLS
where num_scheme_id=p_num_scheme_id;



CURSOR l_get_art_csr IS
SELECT review_upld_terms_id,object_version_number, object_id
FROM okc_review_upld_terms
WHERE document_type=p_doc_type
AND document_id=p_doc_id
AND   object_type = 'ARTICLE'
and action <> 'DELETED';

l_label          Varchar2(30) := NULL;
l_number         Varchar2(30) := NULL;
i                NUMBER;

CURSOR l_get_dtl_count IS
SELECT COUNT(*)
FROM OKC_NUMBER_SCHEME_DTLS
WHERE num_scheme_id=p_num_scheme_id;

l_dtl_count  NUMBER;


BEGIN

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Entered apply_num_scheme_4_Review');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: Parameter List ');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_api_version : '||p_api_version);
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_init_msg_list : '||p_init_msg_list);
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_commit : '||p_commit);
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_validate_commit  : '||p_validate_commit);
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_validation_string : '||p_validation_string);
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_doc_type : '||p_doc_type);
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_doc_id : '||p_doc_id);
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '100: p_num_scheme_id : '||p_num_scheme_id);
    END IF;

    -- Initialize the global Structure Table
    l_review_tbl.DELETE;

    -- Standard Start of API savepoint
    SAVEPOINT g_apply_num_scheme_4_Review;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   IF FND_API.To_Boolean( p_validate_commit ) THEN

      IF  NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => p_doc_type,
                                         p_doc_id	 => p_doc_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
		 FND_LOG.STRING(G_PROC_LEVEL,
                     G_PKG_NAME, '110: Issue with document header Record.Cannot commit' );
	     END IF;
             RAISE FND_API.G_EXC_ERROR ;
         END IF;
   END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if Count of Numbering Scheme Detail is 0 , then this is the no numbering scheme
  -- in this case we need to remove the label from sections and articles table
  OPEN l_get_dtl_count;
    FETCH l_get_dtl_count INTO l_dtl_count;
  CLOSE l_get_dtl_count;

  l_no_of_levels := l_dtl_count;

  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '110: Numbering Scheme Detail Count : '||l_dtl_count );
  END IF;

  UPDATE okc_review_upld_terms
       SET label = NULL
       WHERE document_type = p_doc_type
       AND   document_id   = p_doc_id ;

  IF NVL(l_dtl_count,0) > 0 THEN
  -- dtl count > 0

    OPEN l_get_num_scheme ;
    FETCH l_get_num_scheme  INTO l_number_article_yn  ;
    IF l_get_num_scheme%NOTFOUND THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_get_num_scheme ;


    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '120: l_number_article_yn : '||l_number_article_yn );
    END IF;

    FOR CR in l_get_num_scheme_dtl LOOP
     IF cr.sequence_level=1 THEN
        l_lvl1_seq_code  := cr.num_sequence_code;
        l_lvl1_concat_yn := cr.concatenation_yn;
        l_lvl1_end_char  := cr.end_character;
     ELSIF cr.sequence_level=2 THEN
        l_lvl2_seq_code  := cr.num_sequence_code;
        l_lvl2_concat_yn := cr.concatenation_yn;
        l_lvl2_end_char  := cr.end_character;
     ELSIF cr.sequence_level=3 THEN
        l_lvl3_seq_code  := cr.num_sequence_code;
        l_lvl3_concat_yn := cr.concatenation_yn;
        l_lvl3_end_char  := cr.end_character;
     ELSIF cr.sequence_level=4 THEN
        l_lvl4_seq_code  := cr.num_sequence_code;
        l_lvl4_concat_yn := cr.concatenation_yn;
        l_lvl4_end_char  := cr.end_character;
     ELSIF cr.sequence_level=5 THEN
        l_lvl5_seq_code  := cr.num_sequence_code;
        l_lvl5_concat_yn := cr.concatenation_yn;
        l_lvl5_end_char  := cr.end_character;
      END IF;
    END LOOP;


  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 1  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl1_seq_code  : '||l_lvl1_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl1_concat_yn : '||l_lvl1_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl1_end_char  : '||l_lvl1_end_char);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 2  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl2_seq_code  : '||l_lvl2_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl2_concat_yn : '||l_lvl2_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl2_end_char  : '||l_lvl2_end_char);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 3  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl3_seq_code  : '||l_lvl3_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl3_concat_yn : '||l_lvl3_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl3_end_char  : '||l_lvl3_end_char);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 4  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl4_seq_code  : '||l_lvl4_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl4_concat_yn : '||l_lvl4_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl4_end_char  : '||l_lvl4_end_char);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: Sequence Level 5  ');
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl5_seq_code  : '||l_lvl5_seq_code);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl5_concat_yn : '||l_lvl5_concat_yn);
      FND_LOG.STRING(G_PROC_LEVEL,
          G_PKG_NAME, '130: l_lvl5_end_char  : '||l_lvl5_end_char);
  END IF;

  l_lvl1_sequence     :=0;
  l_lvl2_sequence     :=0;
  l_lvl3_sequence     :=0;
  l_lvl4_sequence     :=0;
  l_lvl5_sequence     :=0;

FOR cr in l_get_child_csr LOOP

    l_number := get_numbering_seq(p_level => 1);


     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '140: l_number : '||l_number );
     END IF;

    l_label := l_number||l_lvl1_end_char;


     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '150: l_label : '||l_label );
     END IF;

    i := l_review_tbl.count+1;
    l_review_tbl(i).review_upld_terms_id := cr.review_upld_terms_id;
    l_review_tbl(i).object_id := cr.object_id;
    l_review_tbl(i).type := 'SECTION';
    l_review_tbl(i).label := l_label;

    l_lvl2_sequence := 0;

    IF l_no_of_levels > 1 THEN
      review_section_numbering(p_doc_type=>p_doc_type,
	                          p_doc_id => p_doc_id,
						 p_level => 2,
						 p_parent_label => l_number,
						 p_review_upld_terms_id => cr.review_upld_terms_id) ;
    END IF;

END LOOP;

     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '160: Count of l_review_tbl : '||l_review_tbl.count );
     END IF;


IF l_review_tbl.count > 0 THEN
   For k in l_review_tbl.FIRST..l_review_tbl.LAST LOOP

		 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
		     FND_LOG.STRING(G_PROC_LEVEL,
       		         G_PKG_NAME, '170: Calling OKC_REVIEW_UPLD_TERMS_PVT.update_row');
		     FND_LOG.STRING(G_PROC_LEVEL,
       		         G_PKG_NAME, '170: l_review_tbl(k).id : '||l_review_tbl(k).review_upld_terms_id);
		     FND_LOG.STRING(G_PROC_LEVEL,
       		         G_PKG_NAME, '170: l_review_tbl(k).label : '||l_review_tbl(k).label);
		 END IF;

                 OKC_REVIEW_UPLD_TERMS_PVT.update_row(
                                     x_return_status => x_return_status,
                                     p_review_upld_terms_id  => l_review_tbl(k).review_upld_terms_id,
                                     p_label         => l_review_tbl(k).label,
                                     p_object_version_number  => NULL);

			 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
				 FND_LOG.STRING(G_PROC_LEVEL,
			         G_PKG_NAME, '170: After Calling OKC_REVIEW_UPLD_TERMS_PVT.update_row x_return_status : '||x_return_status );
			 END IF;

                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                       RAISE FND_API.G_EXC_ERROR ;
                  END IF;
   END LOOP;
 END IF; -- l_review_tbl.count > 0
END IF; -- detail count is 0 i.e no numbering scheme

     -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '2000: Leaving apply_num_scheme_4_Review' );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '2400: Leaving apply_num_scheme_4_Review: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      ROLLBACK TO g_apply_num_scheme_4_Review;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '2400: Leaving apply_num_scheme_4_Review: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      ROLLBACK TO g_apply_num_scheme_4_Review;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving apply_num_scheme_4_Review: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '2400: Leaving apply_num_scheme_4_Review: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      ROLLBACK TO g_apply_num_scheme_4_Review;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END apply_num_scheme_4_Review;


END OKC_NUMBER_SCHEME_GRP;

/
