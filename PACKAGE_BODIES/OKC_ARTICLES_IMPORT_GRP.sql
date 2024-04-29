--------------------------------------------------------
--  DDL for Package Body OKC_ARTICLES_IMPORT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTICLES_IMPORT_GRP" AS
/* $Header: OKCGAIMB.pls 120.16.12010000.19 2012/07/20 14:45:40 serukull ship $ */

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  -- global array for temporary clob
  g_temp_clob_tbl              article_txt_tbl_type:= article_txt_tbl_type();

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200)   := OKC_API.G_FND_APP;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200)   := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200)   := OKC_API.G_COL_NAME_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ARTICLES_IMPORT_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_GLOBAL_ORG_ID              NUMBER     := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
  -- MOAC
  -- G_CURRENT_ORG_ID             NUMBER     := -99;
  G_CURRENT_ORG_ID             NUMBER     ;
  G_FETCHSIZE_LIMIT            NUMBER     := 300;

-- For Error
   TYPE list_err_batch_process_id      IS TABLE OF OKC_ART_INT_ERRORS.BATCH_PROCESS_ID%TYPE INDEX BY BINARY_INTEGER ;
   TYPE list_err_interface_id          IS TABLE OF OKC_ART_INT_ERRORS.INTERFACE_ID%TYPE INDEX BY BINARY_INTEGER ;
   TYPE list_err_article_title         IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_TITLE%TYPE INDEX BY BINARY_INTEGER ;
   TYPE list_err_error_number          IS TABLE OF OKC_ART_INT_ERRORS.ERROR_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
   TYPE list_err_object_version_number IS TABLE OF OKC_ART_INT_ERRORS.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
   TYPE list_err_error_type            IS TABLE OF OKC_ART_INT_ERRORS.ERROR_TYPE%TYPE INDEX BY BINARY_INTEGER ;
   TYPE list_err_error_description     IS TABLE OF OKC_ART_INT_ERRORS.ERROR_DESCRIPTION%TYPE INDEX BY BINARY_INTEGER ;
   TYPE list_err_entity                IS TABLE OF OKC_ART_INT_ERRORS.ENTITY%TYPE INDEX BY BINARY_INTEGER ;

   err_batch_process_id_tbl             list_err_batch_process_id ;
   err_interface_id_tbl                 list_err_interface_id ;
   err_article_title_tbl                list_err_article_title ;
   err_error_number_tbl                 list_err_error_number ;
   err_object_version_number_tbl        list_err_object_version_number ;
   err_error_type_tbl                   list_err_error_type ;
   err_error_description_tbl            list_err_error_description ;
   err_entity_tbl                       list_err_entity ;

-- MOAC
/*
-- One Time fetch and cache the current Org.
  CURSOR CUR_ORG_CSR IS
        SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                                                   SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
        FROM DUAL;
*/

/*===================================================
 | Private Functions
 +==================================================*/

 FUNCTION is_number(p_string IN VARCHAR2)
 RETURN BOOLEAN IS
    val NUMBER;
 BEGIN
    val := TO_NUMBER(p_string);
    RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
    RETURN FALSE;
 END is_number;

 FUNCTION is_date(p_string IN VARCHAR2)
 RETURN BOOLEAN IS
    val DATE;
 BEGIN
   val := TO_DATE(p_string,'YYYY/MM/DD');
    RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
    RETURN FALSE;
 END is_date;

 FUNCTION is_datetime(p_string IN VARCHAR2)
 RETURN BOOLEAN IS
    val DATE;
 BEGIN
   val := TO_DATE(p_string,'YYYY/MM/DD HH24:MI:SS');
    RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
    RETURN FALSE;
 END is_datetime;

 FUNCTION is_value_valid(p_format_type IN VARCHAR2,
                         p_string      IN VARCHAR2)
 RETURN BOOLEAN IS
    val Boolean;
 BEGIN
   IF p_format_type = 'N' THEN
      IF is_number(p_string) THEN
	    RETURN TRUE;
      ELSE
	    RETURN FALSE;
      END IF;
   ELSIF p_format_type = 'C' THEN
      val := is_date(nvl(p_string,'XX'));
      IF val = FALSE THEN
	    RETURN TRUE;
      ELSE
	    RETURN FALSE;
      END IF;
   ELSIF p_format_type = 'X' THEN
      IF is_date(p_string) THEN
	    RETURN TRUE;
      ELSE
	    RETURN FALSE;
      END IF;
   ELSIF p_format_type = 'Y' THEN
      IF is_datetime(p_string) THEN
	    RETURN TRUE;
      ELSE
	    RETURN FALSE;
      END IF;
   ELSE
	    RETURN FALSE;
   END IF;
 EXCEPTION
    WHEN OTHERS THEN
    RETURN FALSE;
 END is_value_valid;

/*===================================================
 | Prints summary of the run in cuncurrent output new for XML Import
 +==================================================*/

  PROCEDURE new_wrap_up( p_batch_number   IN VARCHAR2,
	                    p_entity         IN VARCHAR2,
                         p_batch_procs_id IN NUMBER
				   ) IS

    CURSOR get_info_csr IS
	 SELECT
	       total_rows_processed,total_rows_failed,
	       f.meaning entity_meaning
	 FROM OKC_ART_INT_BATPROCS_ALL a,
	      fnd_lookups f
      WHERE UPPER(a.entity) = f.lookup_code
      and   f.lookup_type = 'OKC_ARTICLE_IMPORT_ENTITY'
	 and   a.batch_process_id = p_batch_procs_id
	 and   a.batch_number = p_batch_number
	 and   a.entity = p_entity
	 and   rownum =1;

  BEGIN
     FND_MSG_PUB.initialize;


     FOR get_info_rec in get_info_csr LOOP
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_IMP_OUT1',
                        p_token1       => 'ENTITY',
                        p_token1_value => get_info_rec.entity_meaning,
                        p_token2       => 'TOTAL_ROWS',
                        p_token2_value => get_info_rec.total_rows_processed,
                        p_token3       => 'TOTAL_SUCCESS',
                        p_token3_value => get_info_rec.total_rows_processed-get_info_rec.total_rows_failed,
                        p_token4       => 'TOTAL_FAILED',
                        p_token4_value => get_info_rec.total_rows_failed);

     END LOOP;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));

      FND_MSG_PUB.initialize;
     commit;
   END new_wrap_up;


/*===================================================
 | Prints error report in cuncurrent output for XML based Clause Import
 +==================================================*/
  PROCEDURE post_wrap_up(p_batch_number IN VARCHAR2,
                         p_entity       IN VARCHAR2,
					p_batch_procs_id   IN NUMBER
				) IS
    CURSOR get_art_info_csr IS
    SELECT a.interface_id,a.entity,error_description,
           b.article_title,b.article_number,
		 hr.name org_name
    from okc_art_int_errors a,okc_art_interface_all b,
         hr_organization_units hr
    where a.interface_id = b.interface_id
    and b.org_id = hr.organization_id
    and b.batch_number = p_batch_number
    and a.batch_process_id = p_batch_procs_id
    and a.entity = p_entity
    and a.entity = 'CLAUSE';

    CURSOR get_var_info_csr IS
    SELECT a.interface_id,a.entity,error_description,
           b.variable_code,b.variable_name
    from okc_art_int_errors a,okc_variables_interface b
    where a.interface_id = b.interface_id
    and b.batch_number = p_batch_number
    and a.batch_process_id = p_batch_procs_id
    and a.entity = p_entity
    and a.entity = 'VARIABLE';

    CURSOR get_val_info_csr IS
    SELECT a.interface_id,a.entity,error_description,
           b.flex_value,b.flex_value_set_name
    from okc_art_int_errors a,okc_vs_values_interface b
    where a.interface_id = b.interface_id
    and b.batch_number = p_batch_number
    and a.batch_process_id = p_batch_procs_id
    and a.entity = p_entity
    and a.entity = 'VALUE';

    CURSOR get_vs_info_csr IS
    SELECT a.interface_id,a.entity,error_description,
           b.flex_value_set_name
    from okc_art_int_errors a,okc_valuesets_interface b
    where a.interface_id = b.interface_id
    and b.batch_number = p_batch_number
    and a.batch_process_id = p_batch_procs_id
    and a.entity = p_entity
    and a.entity = 'VALUESET';

    CURSOR get_rel_info_csr IS
    SELECT a.interface_id,a.entity,error_description,
           b.source_article_title,b.target_article_title,relationship_type,
		 hr.name org_name
    from okc_art_int_errors a,okc_art_rels_interface b,
         hr_organization_units hr
    where a.interface_id = b.interface_id
    and b.batch_number = p_batch_number
    and a.batch_process_id = p_batch_procs_id
    and b.org_id = hr.organization_id
    and a.entity = p_entity
    and a.entity = 'RELATIONSHIP';


    cur_inf_id NUMBER :=0;
    l_insert_errors_exception     EXCEPTION;
    l_insert_errors_error         CONSTANT VARCHAR2(1) := 'X';
BEGIN
IF p_entity = 'VARIABLE' THEN
    FOR get_var_info_rec in get_var_info_csr LOOP
			IF cur_inf_id < 1 THEN
               FND_MSG_PUB.initialize;
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_HDR_VAR');
			  cur_inf_id := cur_inf_id + 1;
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;
               END IF;

               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_OUT_VAR',
                p_token1       => 'INTERFACE_ID',
                p_token1_value => get_var_info_rec.interface_id,
                p_token2       => 'VAR_NAME',
                p_token2_value => get_var_info_rec.variable_name,
                p_token3       => 'ERR_MSG',
                p_token3_value => get_var_info_rec.error_description);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;

    END LOOP;
ELSIF p_entity = 'VALUESET' THEN
    FOR get_vs_info_rec in get_vs_info_csr LOOP
			IF cur_inf_id < 1 THEN
               FND_MSG_PUB.initialize;
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_HDR_VS');
			  cur_inf_id := cur_inf_id + 1;
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;
               END IF;

               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_OUT_VS',
                p_token1       => 'INTERFACE_ID',
                p_token1_value => get_vs_info_rec.interface_id,
                p_token2       => 'VS_NAME',
                p_token2_value => get_vs_info_rec.flex_value_set_name,
                p_token3       => 'ERR_MSG',
                p_token3_value => get_vs_info_rec.error_description);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;

    END LOOP;
ELSIF p_entity = 'RELATIONSHIP' THEN
    FOR get_rel_info_rec in get_rel_info_csr LOOP
			IF cur_inf_id < 1 THEN
               FND_MSG_PUB.initialize;
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_HDR_REL');
			  cur_inf_id := cur_inf_id + 1;
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;
               END IF;

               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_OUT_REL',
                p_token1       => 'INTERFACE_ID',
                p_token1_value => get_rel_info_rec.interface_id,
                p_token2       => 'ARTICLE_TITLE1',
                p_token2_value => get_rel_info_rec.source_article_title,
                p_token3       => 'ARTICLE_TITLE2',
                p_token3_value => get_rel_info_rec.target_article_title,
                p_token4       => 'REL_TYPE',
                p_token4_value => get_rel_info_rec.relationship_type,
                p_token5       => 'OPER_UNIT',
                p_token5_value => get_rel_info_rec.org_name,
                p_token6       => 'ERR_MSG',
                p_token6_value => get_rel_info_rec.error_description);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;

    END LOOP;
ELSIF p_entity = 'VALUE' THEN
    FOR get_val_info_rec in get_val_info_csr LOOP
			IF cur_inf_id < 1 THEN
               FND_MSG_PUB.initialize;
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_HDR_VAL');
			  cur_inf_id := cur_inf_id + 1;
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;
               END IF;

               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_OUT_VAL',
                p_token1       => 'INTERFACE_ID',
                p_token1_value => get_val_info_rec.interface_id,
                p_token2       => 'VAL',
                p_token2_value => get_val_info_rec.flex_value,
                p_token3       => 'VS_NAME',
                p_token3_value => get_val_info_rec.flex_value_set_name,
                p_token4       => 'ERR_MSG',
                p_token4_value => get_val_info_rec.error_description);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;

    END LOOP;
ELSIF p_entity = 'CLAUSE' THEN

    FOR get_art_info_rec in get_art_info_csr LOOP

			IF cur_inf_id < 1 THEN
               FND_MSG_PUB.initialize;
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_HDR_CLAUSE');
			  cur_inf_id := cur_inf_id + 1;
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
                FND_MSG_PUB.initialize;

               END IF;

               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_OUT_CLAUSE',
                p_token1       => 'INTERFACE_ID',
                p_token1_value => get_art_info_rec.interface_id,
                p_token2       => 'ARTICLE_TITLE',
                p_token2_value => get_art_info_rec.article_title,
                p_token3       => 'ARTICLE_NUMBER',
                p_token3_value => get_art_info_rec.article_number,
                p_token4       => 'OPER_UNIT',
                p_token4_value => get_art_info_rec.org_name,
                p_token5       => 'ERR_MSG',
                p_token5_value => get_art_info_rec.error_description);

                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
                FND_MSG_PUB.initialize;
    END LOOP;
END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving post_wrap_up because of EXCEPTION: '||sqlerrm, 2);
     END IF;
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

   END post_wrap_up;

/*===================================================
 | Prints Header in cuncurrent output for XML based Clause Import
 +==================================================*/

  PROCEDURE pre_wrap_up(p_validate_only IN VARCHAR2,
                        p_batch_number  IN VARCHAR2,
				    p_batch_procs_id   IN NUMBER
				) IS
    l_validate_meaning VARCHAR2(80);
    l_import_src_meaning VARCHAR2(1);

    CURSOR lookup_meaning_csr (cp_code IN VARCHAR2) IS
      SELECT meaning
      FROM   fnd_lookups
      WHERE  lookup_type = 'OKC_YN' and lookup_code = cp_code;

    CURSOR import_src_csr IS
      SELECT import_source
	 FROM   OKC_ART_INT_BATPROCS_ALL
	 WHERE batch_process_id = p_batch_procs_id
	 and   batch_number = p_batch_number
	 and   rownum =1;

    -- FOR XML Based CLause Import
    CURSOR get_info_csr IS
	 SELECT a.source_file_name,
	        nvl(hr.name,' ') org_name,
		   --to_char( a.start_date,'DD-MON-YYYY HH24:MI:SS') start_date,
		   fnd_date.date_to_displaydt( a.start_date, FND_DATE.calendar_aware_alt) start_date,
	        f.meaning validate_meaning,
		   nvl(f1.meaning,' ') global_flag_meaning,
		   nvl(f2.meaning,' ') status_meaning
	 FROM OKC_ART_INT_BATPROCS_ALL a,
	      fnd_lookups f,fnd_lookups f1,fnd_lookups f2,hr_organization_units hr
      WHERE a.validate_only_yn = f.lookup_code
      and   f.lookup_type = 'OKC_YN'
      and   a.global_flag = f1.lookup_code (+)
      and   f1.lookup_type (+)= 'OKC_YN'
      and   a.clause_Status = f2.lookup_code (+)
      and   f2.lookup_type (+) = 'OKC_ARTICLE_STATUS'
	 and   a.org_id = hr.organization_id (+)
	 and   a.batch_process_id = p_batch_procs_id
	 and   batch_number = p_batch_number
	 and   a.import_source IS NOT NULL
	 and   rownum =1;

    -- For Non-XML Based Clause Import (Old Import)
    CURSOR get_old_info_csr IS
	 SELECT
		   fnd_date.date_to_displaydt( a.start_date, FND_DATE.calendar_aware_alt) start_date,
	        f.meaning validate_meaning,a.fetch_size
	 FROM OKC_ART_INT_BATPROCS_ALL a,
	      fnd_lookups f
      WHERE a.validate_only_yn = f.lookup_code
      and   f.lookup_type = 'OKC_YN'
	 and   a.batch_process_id = p_batch_procs_id
	 and   a.batch_number = p_batch_number
	 and   a.import_source IS  NULL
	 and   rownum =1;


  BEGIN
     FND_MSG_PUB.initialize;

     --initialize validate_meaning with p_validate_only
     --and fetch the translated lookup meaning for this
	/*
     l_validate_meaning    := p_validate_only;

     OPEN lookup_meaning_csr(p_validate_only);
     FETCH lookup_meaning_csr INTO l_validate_meaning;
     CLOSE lookup_meaning_csr;
	*/
	-- Get the Import Source to find out whether it is XML Based Import or not
	-- Based on that show the Output Layout Header
     OPEN import_src_csr;
     FETCH import_src_csr INTO l_import_src_meaning;
     CLOSE import_src_csr;

     IF  l_import_src_meaning is  not null THEN
     FOR get_info_rec in get_info_csr LOOP
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_IMP_HDR',
                        p_token1       => 'BATCH_NUMBER',
                        p_token1_value => p_batch_number,
				    p_token2       => 'DATE',
				    p_token2_value  => get_info_rec.start_date,
                        p_token3       => 'FILE_NAME',
                        p_token3_value => get_info_rec.source_file_name,
                        p_token4       => 'OPER_UNIT',
                        p_token4_value => get_info_rec.org_name,
                        p_token5       => 'GC_IND',
                        p_token5_value => get_info_rec.global_flag_meaning,
                        p_token6       => 'C_STATUS',
                        p_token6_value => get_info_rec.status_meaning,
                        p_token7       => 'VALIDATE_ONLY',
                        p_token7_value => get_info_rec.validate_meaning
				    );
     END LOOP;
	ELSE
     FOR get_old_info_rec in get_old_info_csr LOOP
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_IMP_HDR1',
                        p_token1       => 'BATCH_NUMBER',
                        p_token1_value => p_batch_number,
				    p_token2       => 'DATE',
				    p_token2_value  => get_old_info_rec.start_date,
                        p_token3       => 'VALIDATE_ONLY',
                        p_token3_value => get_old_info_rec.validate_meaning,
                        p_token4       => 'C_SIZE',
                        p_token4_value => get_old_info_rec.fetch_size
				    );
     END LOOP;

	END IF;
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));

     FND_MSG_PUB.initialize;
     commit;
   END pre_wrap_up;

/*===================================================
 | PROCEDURE conc. program for purge interface table
 +==================================================*/
 PROCEDURE conc_purge_interface (errbuf           OUT NOCOPY VARCHAR2,
                                 retcode          OUT NOCOPY VARCHAR2,
                                 p_start_date     IN VARCHAR2,
                                 p_end_date       IN VARCHAR2,
                                 p_process_status IN VARCHAR2,
                                 p_batch_number   IN VARCHAR2
                                 ) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'conc_purge_interface';
  l_api_version     CONSTANT VARCHAR2(30) := 1.0;
  l_start_date      DATE;
  l_end_date        DATE;

  l_check_access                 VARCHAR2(1);

  Cursor Pur_org_csr IS
  SELECT DISTINCT a.org_id org_id,nvl(hr.name,' ') org_name
  FROM okc_art_interface_all a,hr_organization_units hr
  WHERE a.org_id IS NOT NULL
  AND batch_number = p_batch_number
  AND a.org_id = hr.organization_id(+)
  UNION ALL
  SELECT DISTINCT a.org_id org_id,nvl(hr.name,' ') org_name
  FROM okc_art_rels_interface a,hr_organization_units hr
  WHERE a.org_id IS NOT NULL
  AND batch_number = p_batch_number
  AND a.org_id = hr.organization_id(+)
  AND NOT EXISTS
  (SELECT 1 FROM okc_art_interface_all b
   WHERE  a.org_id = b.org_id
   AND    b.batch_number = p_batch_number);

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_api_name);
     okc_debug.Log('10: Entering ',2);
  END IF;

  mo_global.set_policy_context('M', NULL);

  FOR rec in Pur_org_csr LOOP
  -- Check Access and report error
  l_check_access := mo_global.check_access(p_org_id => rec.org_id);
  IF l_check_access = 'Y' THEN
  -- MOAC
  mo_global.set_policy_context('S', rec.org_id);
  G_CURRENT_ORG_ID := rec.org_id;

  --Initialize the return code
  retcode := 0;
  -- MOAC
  --G_CURRENT_ORG_ID := mo_global.get_current_org_id();
  /*
  OPEN cur_org_csr;
  FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
  CLOSE cur_org_csr;
  */

  IF G_CURRENT_ORG_ID IS NULL THEN
     Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_start_date := nvl(fnd_date.canonical_to_date(p_start_date),
                      to_date('01-01-0001', 'DD-MM-YYYY'));
  l_end_date := nvl(fnd_date.canonical_to_date(p_end_date), sysdate+1);


  IF (     p_end_date is NULL
       AND p_start_date is NULL
       AND p_process_status is NULL
       AND p_batch_number is NULL)  THEN
     Okc_Api.Set_Message(p_app_name    => G_APP_NAME,
                         p_msg_name    => 'OKC_ART_WARN_PUR_ALL_DELETED');
     DELETE FROM OKC_ART_INT_ERRORS
            WHERE batch_process_id in
                            ( SELECT batch_process_id
                              FROM OKC_ART_INT_BATPROCS_ALL
                              WHERE org_id = G_CURRENT_ORG_ID
                                AND batch_number in
                                   (SELECT batch_number
                                    FROM OKC_ART_INTERFACE_ALL
                                    WHERE org_id = G_CURRENT_ORG_ID));

     DELETE FROM OKC_ART_INTERFACE_ALL
        WHERE org_id = G_CURRENT_ORG_ID;

     -- Below Added for FAR/DFAR Content Import
     DELETE FROM OKC_VARIABLES_INTERFACE ;
     DELETE FROM OKC_ART_RELS_INTERFACE
        WHERE org_id = G_CURRENT_ORG_ID ;
     DELETE FROM OKC_VALUESETS_INTERFACE ;
     DELETE FROM OKC_VS_VALUES_INTERFACE ;

  ELSE
      DELETE FROM OKC_ART_INT_ERRORS
          WHERE interface_id in ( SELECT interface_id
                                  FROM  OKC_ART_INTERFACE_ALL
                                  WHERE last_update_date >= trunc(l_start_date)
                                  AND last_update_date <= l_end_date
                                  AND (batch_number = p_batch_number OR p_batch_number IS NULL)
                                  AND (process_status = p_process_status OR p_process_status IS NULL)
                                  AND org_id = G_CURRENT_ORG_ID);
      DELETE FROM OKC_ART_INTERFACE_ALL
            WHERE last_update_date >= trunc(l_start_date)
            AND last_update_date <= l_end_date
            AND (batch_number = p_batch_number OR p_batch_number IS NULL)
            AND (process_status = p_process_status OR p_process_status IS NULL)
            AND org_id = G_CURRENT_ORG_ID;

     -- Below Added for FAR/DFAR Content Import
      DELETE FROM OKC_VARIABLES_INTERFACE
            WHERE last_update_date >= trunc(l_start_date)
            AND last_update_date <= l_end_date
            AND (batch_number = p_batch_number OR p_batch_number IS NULL)
            AND (process_status = p_process_status OR p_process_status IS NULL)
            ;
      DELETE FROM OKC_ART_RELS_INTERFACE
            WHERE last_update_date >= trunc(l_start_date)
            AND last_update_date <= l_end_date
            AND (batch_number = p_batch_number OR p_batch_number IS NULL)
            AND (process_status = p_process_status OR p_process_status IS NULL)
            AND org_id = G_CURRENT_ORG_ID;
      DELETE FROM OKC_VALUESETS_INTERFACE
            WHERE last_update_date >= trunc(l_start_date)
            AND last_update_date <= l_end_date
            AND (batch_number = p_batch_number OR p_batch_number IS NULL)
            AND (process_status = p_process_status OR p_process_status IS NULL)
            ;
      DELETE FROM OKC_VS_VALUES_INTERFACE
            WHERE last_update_date >= trunc(l_start_date)
            AND last_update_date <= l_end_date
            AND (batch_number = p_batch_number OR p_batch_number IS NULL)
            AND (process_status = p_process_status OR p_process_status IS NULL)
            ;
      -- this will clean the remaining error not related to interface_id
      -- such as SQL exception etc.
      DELETE FROM OKC_ART_INT_ERRORS
            WHERE batch_process_id in ( SELECT batch_process_id
                                        FROM OKC_ART_INT_BATPROCS_ALL
                                        WHERE org_id = G_CURRENT_ORG_ID
                                         AND batch_number not in
                                          (SELECT batch_number
                                           FROM OKC_ART_INTERFACE_ALL
                                           WHERE org_id = G_CURRENT_ORG_ID));

  END IF;

  COMMIT;

  END IF;
  END LOOP;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      retcode := 2;
      errbuf  := substr(sqlerrm,1,200);
      IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('3000: Leaving ',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OTHERS THEN
        retcode := 2;
        errbuf  := substr(sqlerrm,1,200);
        rollback;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving due to an Unexpected Exception',2);
           okc_debug.Reset_Indentation;
        END IF;
 END conc_purge_interface;


/*===================================================
 | PROCEDURE conc. program wrapper for import_articles
 +==================================================*/
 PROCEDURE conc_import_articles (
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,

                                 p_batch_procs_id IN NUMBER,
                                 p_batch_number   IN VARCHAR2,
                                 p_validate_only  IN VARCHAR2,
                                 p_fetchsize      IN NUMBER
                                 ) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'conc_import_articles';
  l_api_version     CONSTANT VARCHAR2(30) := 1.0;
  l_return_status            VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(1000);
  l_init_msg_list            VARCHAR2(3) := 'F';
  l_user_id                  NUMBER;
  l_login_id                 NUMBER;
  l_program_id               OKC_ART_INTERFACE_ALL.PROGRAM_ID%TYPE;
  l_program_login_id         OKC_ART_INTERFACE_ALL.PROGRAM_LOGIN_ID%TYPE;
  l_program_appl_id          OKC_ART_INTERFACE_ALL.PROGRAM_APPLICATION_ID%TYPE;
  l_request_id               OKC_ART_INTERFACE_ALL.REQUEST_ID%TYPE;
  l_batch_process_id         NUMBER;
  lc_batch_process_id        NUMBER;
  l_first_time               VARCHAR2(1) := 'Y';
  l_wrap_up                  VARCHAR2(1) := 'Y';
  l_tot_art_rows_processed       NUMBER := 0;
  l_tot_art_rows_failed          NUMBER := 0;
  l_tot_art_rows_warned          NUMBER := 0;
  l_part_art_rows_processed      NUMBER := 0;
  l_part_art_rows_failed         NUMBER := 0;
  l_part_art_rows_warned         NUMBER := 0;
  l_tot_rel_rows_processed       NUMBER := 0;
  l_tot_rel_rows_failed          NUMBER := 0;
  l_tot_rel_rows_warned          NUMBER := 0;
  l_part_rel_rows_processed      NUMBER := 0;
  l_part_rel_rows_failed         NUMBER := 0;
  l_part_rel_rows_warned         NUMBER := 0;

  SUBTYPE entity IS OKC_ART_INT_BATPROCS_ALL.ENTITY%TYPE;

 TYPE entity_tbl_type IS TABLE OF entity;
 l_entity_tbl_type    entity_tbl_type;


  l_check_access                 VARCHAR2(1);

  Cursor Org_csr IS
  SELECT DISTINCT a.org_id org_id,nvl(hr.name,' ') org_name
  FROM okc_art_interface_all a,hr_organization_units hr
  WHERE a.org_id IS NOT NULL
  AND batch_number = p_batch_number
  AND a.org_id = hr.organization_id(+)
  UNION ALL
  SELECT DISTINCT a.org_id org_id,nvl(hr.name,' ') org_name
  FROM okc_art_rels_interface a,hr_organization_units hr
  WHERE a.org_id IS NOT NULL
  AND batch_number = p_batch_number
  AND a.org_id = hr.organization_id(+)
  AND NOT EXISTS
  (SELECT 1 FROM okc_art_interface_all b
   WHERE  a.org_id = b.org_id
   AND    b.batch_number = p_batch_number);


  BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_api_name);
     okc_debug.Log('10: Entering ',2);
  END IF;

  mo_global.set_policy_context('M', NULL);

  FOR rec in Org_Csr LOOP
  -- Check Access and report error
  l_check_access := mo_global.check_access(p_org_id => rec.org_id);
  IF l_check_access = 'Y' THEN
  -- MOAC
  mo_global.set_policy_context('S', rec.org_id);
  G_CURRENT_ORG_ID := rec.org_id;


  --IF G_CURRENT_ORG_ID IS NULL THEN
  --   Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
  --	RAISE FND_API.G_EXC_ERROR;
  --END IF;
------------------------------------------------------------------------
-- Create a batch process id and an initial row for process statistics
-------------------------------------------------------------------------
  IF l_first_time = 'Y' then
    l_user_id  := Fnd_Global.user_id;
    l_login_id := Fnd_Global.login_id;
    l_return_status := G_RET_STS_SUCCESS;

    IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
     l_program_id := NULL;
    ELSE
     l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
    END IF;

    IF FND_GLOBAL.CONC_LOGIN_ID = -1 THEN
     l_program_login_id := NULL;
    ELSE
     l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    END IF;

    IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
     l_program_appl_id := NULL;
    ELSE
     l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
    END IF;

    IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
     l_request_id := NULL;
    ELSE
     l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
    END IF;


    IF p_batch_procs_id = 0 THEN
       -- Need to initialize the record for each entity
       l_entity_tbl_type := entity_tbl_type('Clause','Variable','Relationship','Valueset','Value');
	  -- Generate batch_process_id
	  SELECT
       OKC_ART_INT_BATPROCS_ALL_S1.nextval into lc_batch_process_id
	  FROM DUAL;

    FOR i IN 1..l_entity_tbl_type.LAST LOOP

    INSERT INTO OKC_ART_INT_BATPROCS_ALL
      (
      BATCH_PROCESS_ID,
      OBJECT_VERSION_NUMBER,
      BATCH_NUMBER,
      ORG_ID,
      VALIDATE_ONLY_YN,
      FETCH_SIZE,
      START_DATE,
      END_DATE,
      TOTAL_ROWS_PROCESSED,
      TOTAL_ROWS_FAILED,
      TOTAL_ROWS_WARNED,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      PROGRAM_ID,
      PROGRAM_LOGIN_ID,
      PROGRAM_APPLICATION_ID,
      REQUEST_ID,
	 ENTITY
      )
    VALUES
      (
       lc_batch_process_id,
       1.0,
       p_batch_number,
       G_CURRENT_ORG_ID,
       p_validate_only,
       p_fetchsize,
       sysdate,
       NULL,
       NULL,
       NULL,
       NULL,
       l_user_id,
       sysdate,
       sysdate,
       l_user_id,
       l_login_id,
       l_program_id,
       l_program_login_id,
       l_program_appl_id,
       l_request_id   ,
	  l_entity_tbl_type(i)
      ) returning BATCH_PROCESS_ID INTO l_batch_process_id;
    commit;

    END LOOP;
    l_entity_tbl_type.delete;

  ELSE
    l_batch_process_id := p_batch_procs_id;
  END IF;

  IF l_wrap_up = 'Y' THEN
  pre_wrap_up(p_validate_only,p_batch_number,l_batch_process_id);
  l_wrap_up := 'N' ;
  END IF;

  BEGIN
    OKC_ARTICLES_IMPORT_GRP.import_fnd_flex_value_sets(
                              x_return_status  => l_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_batch_procs_id => l_batch_process_id,
                              p_batch_number   => p_batch_number,
                              p_validate_only  => p_validate_only,
                              p_fetchsize      => p_fetchsize );


  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving conc_import_articles',2);
     okc_debug.Reset_Indentation;
  END IF;
  x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('3000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
       END IF;
       FND_MSG_PUB.initialize;
       IF (l_debug = 'Y') THEN
         okc_debug.Log('4000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
       END IF;

   WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
        END IF;
        FND_MSG_PUB.initialize;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving conc_import_articles',2);
           okc_debug.Reset_Indentation;
        END IF;
  END ;
  BEGIN
    OKC_ARTICLES_IMPORT_GRP.import_fnd_flex_values(
                              x_return_status  => l_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_batch_procs_id => l_batch_process_id,
                              p_batch_number   => p_batch_number,
                              p_validate_only  => p_validate_only,
                              p_fetchsize      => p_fetchsize );


  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving conc_import_articles',2);
     okc_debug.Reset_Indentation;
  END IF;
  x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('3000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
       END IF;
       FND_MSG_PUB.initialize;
       IF (l_debug = 'Y') THEN
         okc_debug.Log('4000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
       END IF;

   WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
        END IF;
        FND_MSG_PUB.initialize;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving conc_import_articles',2);
           okc_debug.Reset_Indentation;
        END IF;
  END ;
  BEGIN
    OKC_ARTICLES_IMPORT_GRP.import_variables(
                              x_return_status  => l_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_batch_procs_id => l_batch_process_id,
                              p_batch_number   => p_batch_number,
                              p_validate_only  => p_validate_only,
                              p_fetchsize      => p_fetchsize );


  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving conc_import_articles',2);
     okc_debug.Reset_Indentation;
  END IF;
  x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('3000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
       END IF;
       FND_MSG_PUB.initialize;
       IF (l_debug = 'Y') THEN
         okc_debug.Log('4000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
       END IF;

   WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
        END IF;
        FND_MSG_PUB.initialize;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving conc_import_articles',2);
           okc_debug.Reset_Indentation;
        END IF;
  END ;
  END IF;  -- If l_first_time = 'Y'
  BEGIN
    l_part_art_rows_processed      := 0;
    l_part_art_rows_failed         := 0;
    l_part_art_rows_warned         := 0;
    OKC_ARTICLES_IMPORT_GRP.import_articles(
                              x_return_status  => l_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_batch_procs_id => l_batch_process_id,
                              p_batch_number   => p_batch_number,
                              p_validate_only  => p_validate_only,
                              p_fetchsize      => p_fetchsize,
						p_rows_processed => l_part_art_rows_processed,
						p_rows_failed    => l_part_art_rows_failed,
						p_rows_warned    => l_part_art_rows_warned);

    l_tot_art_rows_processed       := l_tot_art_rows_processed + l_part_art_rows_processed;
    l_tot_art_rows_failed          := l_tot_art_rows_failed + l_part_art_rows_failed;
    l_tot_art_rows_warned          := l_tot_art_rows_warned + l_part_art_rows_warned;



  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving conc_import_articles',2);
     okc_debug.Reset_Indentation;
  END IF;
  x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('3000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
       END IF;
       FND_MSG_PUB.initialize;
       IF (l_debug = 'Y') THEN
         okc_debug.Log('4000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
       END IF;

   WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
        END IF;
        FND_MSG_PUB.initialize;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving conc_import_articles',2);
           okc_debug.Reset_Indentation;
        END IF;
  END ;
  BEGIN
    l_part_rel_rows_processed      := 0;
    l_part_rel_rows_failed         := 0;
    l_part_rel_rows_warned         := 0;
    OKC_ARTICLES_IMPORT_GRP.import_relationships(
                              x_return_status  => l_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_batch_procs_id => l_batch_process_id,
                              p_batch_number   => p_batch_number,
                              p_validate_only  => p_validate_only,
                              p_fetchsize      => p_fetchsize,
						p_rows_processed => l_part_rel_rows_processed,
						p_rows_failed    => l_part_rel_rows_failed,
						p_rows_warned    => l_part_rel_rows_warned);

    l_tot_rel_rows_processed       := l_tot_rel_rows_processed + l_part_rel_rows_processed;
    l_tot_rel_rows_failed          := l_tot_rel_rows_failed + l_part_rel_rows_failed;
    l_tot_rel_rows_warned          := l_tot_rel_rows_warned + l_part_rel_rows_warned;


  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving conc_import_articles',2);
     okc_debug.Reset_Indentation;
  END IF;
  x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('3000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
       END IF;
       FND_MSG_PUB.initialize;
       IF (l_debug = 'Y') THEN
         okc_debug.Log('4000: Leaving conc_import_articles',2);
         okc_debug.Reset_Indentation;
       END IF;

   WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
        END IF;
        FND_MSG_PUB.initialize;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving conc_import_articles',2);
           okc_debug.Reset_Indentation;
        END IF;
  END ;
  l_first_time := 'N';
  ELSE
  IF l_wrap_up = 'Y' THEN
  pre_wrap_up(p_validate_only,p_batch_number,p_batch_procs_id);
  l_wrap_up := 'N';
  END IF;
     FND_MSG_PUB.initialize;
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_NOT_VALID_ORG',
                        p_token1       => 'ORG_NAME',
                        p_token1_value => rec.org_name);
     FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));

     FND_MSG_PUB.initialize;
     commit;

  END IF;
  END LOOP;

  --Update Batch Process Table with the clause related process counts
  UPDATE OKC_ART_INT_BATPROCS_ALL
  SET
  TOTAL_ROWS_PROCESSED       = l_tot_art_rows_processed,
  TOTAL_ROWS_FAILED          = l_tot_art_rows_failed,
  TOTAL_ROWS_WARNED          = l_tot_art_rows_warned,
  END_DATE                   = SYSDATE,
  PROGRAM_ID                 = l_program_id,
  REQUEST_ID                 = l_request_id,
  PROGRAM_LOGIN_ID           = l_program_login_id,
  PROGRAM_APPLICATION_ID     = l_program_appl_id,
  OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
  LAST_UPDATED_BY            = l_user_id,
  LAST_UPDATE_LOGIN          = l_login_id,
  LAST_UPDATE_DATE           = SYSDATE
  WHERE
  BATCH_PROCESS_ID  = l_batch_process_id
  AND ENTITY = 'Clause';

  --Update Batch Process Table with the relationship related counts
  UPDATE OKC_ART_INT_BATPROCS_ALL
  SET
  TOTAL_ROWS_PROCESSED       = l_tot_rel_rows_processed,
  TOTAL_ROWS_FAILED          = l_tot_rel_rows_failed,
  TOTAL_ROWS_WARNED          = l_tot_rel_rows_warned,
  END_DATE                   = SYSDATE,
  PROGRAM_ID                 = l_program_id,
  REQUEST_ID                 = l_request_id,
  PROGRAM_LOGIN_ID           = l_program_login_id,
  PROGRAM_APPLICATION_ID     = l_program_appl_id,
  OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
  LAST_UPDATED_BY            = l_user_id,
  LAST_UPDATE_LOGIN          = l_login_id,
  LAST_UPDATE_DATE           = SYSDATE
  WHERE
  BATCH_PROCESS_ID  = l_batch_process_id
  AND ENTITY = 'Relationship' ;

      new_wrap_up(p_batch_number,'Clause',l_batch_process_id);
      new_wrap_up(p_batch_number,'Relationship',l_batch_process_id);
      new_wrap_up(p_batch_number,'Variable',l_batch_process_id);
      new_wrap_up(p_batch_number,'Valueset',l_batch_process_id);
      new_wrap_up(p_batch_number,'Value',l_batch_process_id);
      FND_MSG_PUB.initialize;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_IMP_ERR');

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));

      FND_MSG_PUB.initialize;
      post_wrap_up(p_batch_number,'CLAUSE',l_batch_process_id);
      post_wrap_up(p_batch_number,'RELATIONSHIP',l_batch_process_id);
      post_wrap_up(p_batch_number,'VARIABLE',l_batch_process_id);
      post_wrap_up(p_batch_number,'VALUESET',l_batch_process_id);
      post_wrap_up(p_batch_number,'VALUE',l_batch_process_id);

      FND_MSG_PUB.initialize;
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_IMP_OUT_EOR');

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));

      FND_MSG_PUB.initialize;
 END conc_import_articles;

/*===================================================
 | Get Sequence Number for New Article or New Version
 +==================================================*/

  FUNCTION Get_Seq_Id (
    p_object_type               IN VARCHAR2,
    x_object_id                 OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_art_csr IS
       SELECT OKC_ARTICLES_ALL_S1.NEXTVAL FROM DUAL;
    CURSOR l_ver_csr IS
       SELECT OKC_ARTICLE_VERSIONS_S1.NEXTVAL FROM DUAL;
  BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF p_object_type = 'ART' THEN
      OPEN l_art_csr;
      FETCH l_art_csr INTO x_object_id                ;
      IF l_art_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE l_art_csr;
    ELSIF p_object_type = 'VER' THEN
      OPEN l_ver_csr;
      FETCH l_ver_csr INTO x_object_id                ;
      IF l_ver_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE l_ver_csr;
    END IF;

    IF (l_debug = 'Y') THEN
     Okc_Debug.Log('200: Leaving get_seq_id', 2);
    END IF;
    RETURN G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('300: Leaving get_seq_id because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF l_art_csr%ISOPEN THEN
        CLOSE l_art_csr;
      END IF;
      IF l_ver_csr%ISOPEN THEN
        CLOSE l_ver_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Seq_Id;


/*=====================================================================
| PROCEDURE insert_error_array
| This procedure will insert the error array built by build_error_array
+====================================================================*/
PROCEDURE insert_error_array(
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2
)IS
  l_user_id                  NUMBER;
  l_login_id                 NUMBER;
  l_program_id               OKC_ART_INT_ERRORS.PROGRAM_ID%TYPE;
  l_program_login_id         OKC_ART_INT_ERRORS.PROGRAM_LOGIN_ID%TYPE;
  l_program_appl_id          OKC_ART_INT_ERRORS.PROGRAM_APPLICATION_ID%TYPE;
  l_request_id               OKC_ART_INT_ERRORS.REQUEST_ID%TYPE;
  i_err NUMBER :=0;
  cur_inf_id NUMBER :=0;
  cur_inf_id1 NUMBER :=0;
    l_insert_errors_exception     EXCEPTION;
    l_insert_errors_error         CONSTANT VARCHAR2(1) := 'X';
BEGIN
    l_user_id  := Fnd_Global.user_id;
    l_login_id := Fnd_Global.login_id;

    IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
     l_program_id := NULL;
    ELSE
     l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
    END IF;

    IF FND_GLOBAL.CONC_LOGIN_ID = -1 THEN
     l_program_login_id := NULL;
    ELSE
     l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    END IF;

    IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
     l_program_appl_id := NULL;
    ELSE
     l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
    END IF;

    IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
     l_request_id := NULL;
    ELSE
     l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
    END IF;

  IF ( err_batch_process_id_tbl.COUNT > 0) THEN
       FOR i_err in err_batch_process_id_tbl.FIRST
                    .. err_batch_process_id_tbl.LAST LOOP


         INSERT INTO OKC_ART_INT_ERRORS
          (
            BATCH_PROCESS_ID,
            INTERFACE_ID,
            ERROR_NUMBER,
            OBJECT_VERSION_NUMBER,
            ERROR_TYPE,
            ERROR_DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            PROGRAM_ID,
            PROGRAM_LOGIN_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
		  ENTITY
          )
        VALUES
          (
            err_batch_process_id_tbl(i_err),
            err_interface_id_tbl(i_err),
            err_error_number_tbl(i_err),
            err_object_version_number_tbl(i_err),
            err_error_type_tbl(i_err),
            err_error_description_tbl(i_err),
            l_user_id,
            sysdate,
            sysdate,
            l_user_id,
            l_login_id,
            l_program_id,
            l_program_login_id,
            l_program_appl_id,
            l_request_id,
            err_entity_tbl(i_err)
         );


	    -- End Added for XML Based Clause Import

           IF cur_inf_id <> err_interface_id_tbl(i_err) THEN
               cur_inf_id := err_interface_id_tbl(i_err);
               FND_MSG_PUB.initialize;
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_LOG_HEADER',
                p_token1       => 'ENTITY',
                p_token1_value => err_entity_tbl(i_err),
                p_token2       => 'ARTICLE_TITLE',
                p_token2_value => err_article_title_tbl(i_err),
                p_token3       => 'INTERFACE_ID',
                p_token3_value => err_interface_id_tbl(i_err));
                FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
               FND_MSG_PUB.initialize;
           END IF;
           FND_FILE.PUT_LINE(FND_FILE.LOG, err_error_description_tbl(i_err));
           FND_FILE.PUT_LINE(FND_FILE.LOG, '');

       END LOOP;
    END IF;
    --recycle it
    err_batch_process_id_tbl.DELETE;
    err_article_title_tbl.DELETE;
    err_interface_id_tbl.DELETE;
    err_error_number_tbl.DELETE;
    err_object_version_number_tbl.DELETE;
    err_error_type_tbl.DELETE;
    err_entity_tbl.DELETE;
    err_error_description_tbl.DELETE;

EXCEPTION
   WHEN OTHERS THEN
     IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving insert_error_array because of EXCEPTION: '||sqlerrm, 2);
     END IF;
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

   x_return_status := l_insert_errors_error;

END insert_error_array;

/*=====================================================================
 | PROCEDURE build_error_array
 |
 | This internal procedure will build the error array
 | from the fnd message stack
 +====================================================================*/

PROCEDURE build_error_array(
    p_msg_data                     IN VARCHAR2 := NULL,
    p_context                      IN VARCHAR2,
    p_batch_process_id             IN NUMBER,
    p_interface_id                 IN NUMBER,
    p_article_title                IN VARCHAR2 := NULL,
    p_error_type                   IN VARCHAR2,
    p_entity                       IN VARCHAR2
) IS
  l_error_index              NUMBER          := 1;
  l_return_status            VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(1000);
BEGIN
    IF FND_MSG_PUB.Count_Msg >= 1 Then
      FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
       err_batch_process_id_tbl(l_error_index) :=   p_batch_process_id;
       err_interface_id_tbl(l_error_index) :=  p_interface_id ;
       err_article_title_tbl(l_error_index) := p_article_title ;
       err_error_number_tbl(l_error_index) :=  l_error_index ;
       err_object_version_number_tbl(l_error_index) :=  1.0 ;
       err_error_type_tbl(l_error_index) :=   p_error_type ;
       err_entity_tbl(l_error_index) :=   p_entity ;
     --err_error_description_tbl(l_error_index) :=   p_context ||':'|| FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE );
       err_error_description_tbl(l_error_index) :=   FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE );
       l_error_index := l_error_index + 1;
      END LOOP;
    ELSE IF p_msg_data is not NULL Then
      err_batch_process_id_tbl(l_error_index) :=   p_batch_process_id;
      err_interface_id_tbl(l_error_index) :=  p_interface_id ;
      err_article_title_tbl(l_error_index) := p_article_title;
      err_error_number_tbl(l_error_index) :=  l_error_index ;
      err_object_version_number_tbl(l_error_index) :=  1.0 ;
      err_error_type_tbl(l_error_index) :=   p_error_type ;
      err_entity_tbl(l_error_index) :=   p_entity ;
      err_error_description_tbl(l_error_index) :=   p_msg_data;
      l_error_index := l_error_index + 1;
      END IF;
    END IF;

    insert_error_array(
     x_return_status => l_return_status,
     x_msg_count     => l_msg_count,
     x_msg_data      => l_msg_data
    );

  FND_MSG_PUB.initialize;
END build_error_array;


/*===================================================
 | Get build array message and rest of Fnd Message stack
 | and print it in Concurrent Log
 |
 | This would be a last step to print error messages
 | If err vararray has data, then it means it was not
 | pushed into database, so it should be printed in concurrent
 | output with remaining data in fnd message stack.
 +==================================================*/

  PROCEDURE get_print_msgs_stack(p_msg_data IN VARCHAR2) IS
     i_err NUMBER := 0;
     cur_inf_id NUMBER := 0;
  BEGIN
     IF err_batch_process_id_tbl.COUNT > 0 THEN
        FOR i_err IN err_batch_process_id_tbl.FIRST
            .. err_batch_process_id_tbl.LAST LOOP
           --
           -- whenever there is a change in interface id, we will change header
           --
           IF cur_inf_id <> err_interface_id_tbl(i_err) THEN
               cur_inf_id := err_interface_id_tbl(i_err);
               FND_MSG_PUB.initialize;
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_ART_IMP_LOG_HEADER',
                p_token1       => 'ENTITY',
                p_token1_value => err_entity_tbl(i_err),
                p_token2       => 'ARTICLE_TITLE',
                p_token2_value => err_article_title_tbl(i_err));
                FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));
           END IF;

           FND_FILE.PUT_LINE(FND_FILE.LOG, err_error_description_tbl(i_err));
           FND_FILE.PUT_LINE(FND_FILE.LOG, '');

        END LOOP;
     END IF;

     IF FND_MSG_PUB.Count_Msg > 1 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
     ELSE
         FND_FILE.PUT_LINE(FND_FILE.LOG,p_msg_data);
     END IF;

     --recycle it
     FND_MSG_PUB.initialize;

  END get_print_msgs_stack;


/*===================================================
 | Prints summary of the run in cuncurrent output
 +==================================================*/

  PROCEDURE wrap_up(p_validate_only IN VARCHAR2,
                    p_batch_number  IN VARCHAR2,
				p_tot_rows_processed IN NUMBER,
				p_tot_rows_failed IN NUMBER,
				p_tot_rows_warned IN NUMBER,
				p_batch_process_id IN NUMBER DEFAULT NULL,
				p_entity IN VARCHAR2 DEFAULT NULL
				) IS
    l_batch_process_id NUMBER;
    l_validate_meaning VARCHAR2(80);
    l_entity_meaning   VARCHAR2(80);
    l_entity           VARCHAR2(30);
    l_org_name         HR_ORGANIZATION_UNITS.NAME%TYPE;
    l_tot_rows_processed  NUMBER;
    l_tot_rows_failed  NUMBER;
    l_tot_rows_warned  NUMBER;

    CURSOR lookup_meaning_csr (cp_code IN VARCHAR2) IS
      SELECT meaning
      FROM   fnd_lookups
      WHERE  lookup_type = 'OKC_YN' and lookup_code = cp_code;

    CURSOR org_name_csr (cp_org_id IN NUMBER) IS
      SELECT NAME
      FROM HR_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = cp_org_id;

    CURSOR entity_meaning_csr (cp_ent_code IN VARCHAR2) IS
      SELECT meaning
      FROM   fnd_lookups
      WHERE  lookup_type = 'OKC_ARTICLE_IMPORT_ENTITY' and lookup_code = cp_ent_code;
  BEGIN
     FND_MSG_PUB.initialize;

     --initialize validate_meaning with p_validate_only
     --and fetch the translated lookup meaning for this
     l_entity              := p_entity;
     l_batch_process_id    := p_batch_process_id;
     l_validate_meaning    := p_validate_only;
     l_tot_rows_processed  := p_tot_rows_processed;
     l_tot_rows_failed     := p_tot_rows_failed;
     l_tot_rows_warned     := p_tot_rows_warned;

     OPEN lookup_meaning_csr(p_validate_only);
     FETCH lookup_meaning_csr INTO l_validate_meaning;
     CLOSE lookup_meaning_csr;


     OPEN entity_meaning_csr(p_entity);
     FETCH entity_meaning_csr INTO l_entity_meaning;
     CLOSE entity_meaning_csr;

	-- MOAC
	G_CURRENT_ORG_ID := mo_global.get_current_org_id();

	IF G_CURRENT_ORG_ID IS NULL THEN
	   Okc_Api.Set_Message(G_APP_NAME,'OKC_ART_NULL_ORG_ID');
	   RAISE FND_API.G_EXC_ERROR;
     END IF;

     OPEN org_name_csr (G_CURRENT_ORG_ID);
     FETCH org_name_csr INTO l_org_name;
     CLOSE org_name_csr;

/* commented for XML Based clause Import
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_IMP_OUTPUT',
                        p_token1       => 'ENTITY',
                        p_token1_value => p_entity,
                        p_token2       => 'BATCH_NUMBER',
                        p_token2_value => p_batch_number,
                        p_token3       => 'BATCH_PROCESS_ID',
                        p_token3_value => l_batch_process_id,
                        p_token4       => 'TOTAL_ROWS',
                        p_token4_value => l_tot_rows_processed,
                        p_token5       => 'TOTAL_SUCCESS',
                        p_token5_value => l_tot_rows_processed-l_tot_rows_failed,
                        p_token6       => 'TOTAL_FAILED',
                        p_token6_value => l_tot_rows_failed,
                        p_token7       => 'TOTAL_WARNED',
                        p_token7_value => l_tot_rows_warned,
                        p_token8       => 'ORG_NAME',
                        p_token8_value => l_org_name,
                        p_token9       => 'VALIDATE_ONLY',
                        p_token9_value => l_validate_meaning);
*/
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_IMP_OUT1',
                        p_token1       => 'ENTITY',
                        p_token1_value => l_entity_meaning,
                        p_token2       => 'TOTAL_ROWS',
                        p_token2_value => l_tot_rows_processed,
                        p_token3       => 'TOTAL_SUCCESS',
                        p_token3_value => l_tot_rows_processed-l_tot_rows_failed,
                        p_token4       => 'TOTAL_FAILED',
                        p_token4_value => l_tot_rows_failed);

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));

      FND_MSG_PUB.initialize;
     commit;
   END wrap_up;

/*===================================================
 | PROCEDURE import articles details
 +==================================================*/
  PROCEDURE import_articles(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100,
    p_rows_processed               OUT NOCOPY NUMBER,
    p_rows_failed                  OUT NOCOPY NUMBER,
    p_rows_warned                  OUT NOCOPY NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'import_articles';
    l_sts_warning                 CONSTANT VARCHAR2(1) := 'W';
    l_row_notfound                BOOLEAN := FALSE;
    l_user_id                     NUMBER;
    l_login_id                    NUMBER;
    l_insert_errors_exception     EXCEPTION;
    l_insert_errors_error         CONSTANT VARCHAR2(1) := 'X';
    l_userenv_lang                VARCHAR2(10);

-- Some (minimal) Article Level attributes are nvl-ed in the case of update and
-- new version as they cannot be changed after the first version is created.
-- User must pass all other attibutes irregardless of the mode (except of course
-- the ids)

    CURSOR l_interface_csr ( cp_local_org_id IN NUMBER,
                             cp_batch_number IN VARCHAR2) IS
      SELECT
           INTRFC.INTERFACE_ID     ,
           INTRFC.BATCH_NUMBER             ,
           INTRFC.OBJECT_VERSION_NUMBER  ,
           INTRFC.ARTICLE_TITLE    ,
           INTRFC.ORG_ID       ,
           INTRFC.PROCESS_STATUS           ,
           INTRFC.ACTION                  ,
           NVL(INTRFC.ARTICLE_NUMBER, ART.ARTICLE_NUMBER)   ,
           NVL(INTRFC.ARTICLE_INTENT, ART.ARTICLE_INTENT)   ,
           ART.ARTICLE_INTENT         X_ARTICLE_INTENT      ,
           INTRFC.ARTICLE_LANGUAGE  ,
           ART.ARTICLE_LANGUAGE       X_ARTICLE_LANGUAGE    ,
           NVL(INTRFC.ARTICLE_TYPE, ART.ARTICLE_TYPE)   ,
           ART.ARTICLE_ID   ,
           INTRFC.ART_SYSTEM_REFERENCE_CODE,
           INTRFC.ART_SYSTEM_REFERENCE_ID1,
           INTRFC.ART_SYSTEM_REFERENCE_ID2,
           INTRFC.ARTICLE_VERSION_NUMBER  ,
           INTRFC.ARTICLE_TEXT    ,
           INTRFC.PROVISION_YN  ,
           INTRFC.INSERT_BY_REFERENCE ,
           INTRFC.LOCK_TEXT   ,
           INTRFC.GLOBAL_YN   ,
           INTRFC.ARTICLE_STATUS    ,
           INTRFC.START_DATE    ,
           INTRFC.END_DATE    ,
           INTRFC.DISPLAY_NAME    ,
           INTRFC.ARTICLE_DESCRIPTION     ,
           INTRFC.DATE_APPROVED   ,
           INTRFC.DEFAULT_SECTION   ,
           INTRFC.REFERENCE_SOURCE        ,
           INTRFC.REFERENCE_TEXT          ,
           INTRFC.VER_SYSTEM_REFERENCE_CODE ,
           INTRFC.VER_SYSTEM_REFERENCE_ID1  ,
           INTRFC.VER_SYSTEM_REFERENCE_ID2  ,
           INTRFC.ADDITIONAL_INSTRUCTIONS         ,
		 INTRFC.DATE_PUBLISHED,
           INTRFC.ATTRIBUTE_CATEGORY,
           INTRFC.ATTRIBUTE1  ,
           INTRFC.ATTRIBUTE2  ,
           INTRFC.ATTRIBUTE3  ,
           INTRFC.ATTRIBUTE4  ,
           INTRFC.ATTRIBUTE5  ,
           INTRFC.ATTRIBUTE6  ,
           INTRFC.ATTRIBUTE7  ,
           INTRFC.ATTRIBUTE8  ,
           INTRFC.ATTRIBUTE9  ,
           INTRFC.ATTRIBUTE10 ,
           INTRFC.ATTRIBUTE11 ,
           INTRFC.ATTRIBUTE12 ,
           INTRFC.ATTRIBUTE13 ,
           INTRFC.ATTRIBUTE14 ,
           INTRFC.ATTRIBUTE15,
 --Clause editing in word
           INTRFC.EDITED_IN_WORD,
           INTRFC.ARTICLE_TEXT_IN_WORD,
           TO_NUMBER(NULL) ARTICLE_VERSION_ID
      FROM OKC_ART_INTERFACE_ALL INTRFC, OKC_ARTICLES_ALL ART
      WHERE nvl(PROCESS_STATUS,'*') NOT IN ('W', 'S')
         AND INTRFC.ORG_ID = cp_local_org_id
         AND BATCH_NUMBER = cp_batch_number
         AND RTRIM(INTRFC.ARTICLE_TITLE) = ART.ARTICLE_TITLE(+)
         AND INTRFC.ORG_ID = ART.ORG_ID(+)
         AND ART.STANDARD_YN(+) = 'Y'
      ORDER BY RTRIM(INTRFC.ARTICLE_TITLE) ASC;

-- Cursor returns article status, version id and version number
-- for the most recent version with article_id

    CURSOR get_max_article_version_csr    (cp_article_id IN NUMBER) IS
     SELECT
          ARTICLE_VERSION_ID,
          ARTICLE_VERSION_NUMBER,
          ARTICLE_STATUS,
	  START_DATE,
 --Clause Editing
           EDITED_IN_WORD
     FROM OKC_ARTICLE_VERSIONS A
     WHERE article_id = cp_article_id
       and start_date = (SELECT max(start_date)
                         FROM   okc_article_versions
                         WHERE  article_id = a.article_id);

-- Cursor to get article level information for V, U interface row
    CURSOR get_article_info_csr    (cp_article_id IN NUMBER) IS
     SELECT
          ARTICLE_INTENT,
          ARTICLE_LANGUAGE
     FROM OKC_ARTICLES_ALL
     WHERE  ARTICLE_ID = cp_article_id;

-- Cursor to validate article type
-- If article type is not active any more but it is not valid
    CURSOR validate_article_type_csr ( cp_article_type IN VARCHAR2,
                                       cp_article_id IN NUMBER,
                                       cp_action IN VARCHAR2) IS
     SELECT lookup_code
     FROM  fnd_lookups
     WHERE lookup_type = 'OKC_SUBJECT'
       AND lookup_code = cp_article_type
       AND start_date_active <= trunc(sysdate)
       AND nvl(end_date_active,sysdate+1) >= trunc(sysdate);

-- Check validity of valueset
--  Split into two cursor for performance as var_name may not be used frequently
    CURSOR l_check_valid_valueset_csr (cp_variable_code IN VARCHAR2) IS
      SELECT FLX.FLEX_VALUE_SET_ID,
             BVB.VARIABLE_TYPE
      FROM
         OKC_BUS_VARIABLES_B BVB,
         FND_FLEX_VALUE_SETS FLX
      WHERE BVB.VARIABLE_CODE = cp_variable_code
      --AND BVB.VARIABLE_TYPE = 'U'
      AND FLX.FLEX_VALUE_SET_ID(+) = BVB.VALUE_SET_ID;

    CURSOR l_var_name_csr (cp_variable_code IN VARCHAR2,
                           cp_lang IN VARCHAR2) IS
      SELECT BVT.VARIABLE_NAME
      FROM
         OKC_BUS_VARIABLES_TL BVT
      WHERE BVT.VARIABLE_CODE = cp_variable_code
      AND BVT.LANGUAGE = cp_lang;

-- Interface Rows

    TYPE l_inf_interface_id             IS TABLE OF OKC_ART_INTERFACE_ALL.INTERFACE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_batch_number             IS TABLE OF OKC_ART_INTERFACE_ALL.BATCH_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_object_version_number    IS TABLE OF OKC_ART_INTERFACE_ALL.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_title            IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_TITLE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_org_id                   IS TABLE OF OKC_ART_INTERFACE_ALL.ORG_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_process_status           IS TABLE OF OKC_ART_INTERFACE_ALL.PROCESS_STATUS%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_action                   IS TABLE OF OKC_ART_INTERFACE_ALL.ACTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_number           IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_intent           IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_INTENT%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_language         IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_LANGUAGE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_type             IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_id               IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_art_reference_code       IS TABLE OF OKC_ART_INTERFACE_ALL.ART_SYSTEM_REFERENCE_CODE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_art_reference_id1        IS TABLE OF OKC_ART_INTERFACE_ALL.ART_SYSTEM_REFERENCE_ID1%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_art_reference_id2        IS TABLE OF OKC_ART_INTERFACE_ALL.ART_SYSTEM_REFERENCE_ID2%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_text             IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_TEXT%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_provision_yn             IS TABLE OF OKC_ART_INTERFACE_ALL.PROVISION_YN%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_insert_by_reference      IS TABLE OF OKC_ART_INTERFACE_ALL.INSERT_BY_REFERENCE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_lock_text                IS TABLE OF OKC_ART_INTERFACE_ALL.LOCK_TEXT%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_global_yn                IS TABLE OF OKC_ART_INTERFACE_ALL.GLOBAL_YN%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_status           IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_STATUS%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_start_date               IS TABLE OF OKC_ART_INTERFACE_ALL.START_DATE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_end_date                 IS TABLE OF OKC_ART_INTERFACE_ALL.END_DATE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_display_name             IS TABLE OF OKC_ART_INTERFACE_ALL.DISPLAY_NAME%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_description      IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_DESCRIPTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_date_approved            IS TABLE OF OKC_ART_INTERFACE_ALL.DATE_APPROVED%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_default_section          IS TABLE OF OKC_ART_INTERFACE_ALL.DEFAULT_SECTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_reference_source         IS TABLE OF OKC_ART_INTERFACE_ALL.REFERENCE_SOURCE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_reference_text           IS TABLE OF OKC_ART_INTERFACE_ALL.REFERENCE_TEXT%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_ver_reference_code       IS TABLE OF OKC_ART_INTERFACE_ALL.VER_SYSTEM_REFERENCE_CODE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_ver_reference_id1        IS TABLE OF OKC_ART_INTERFACE_ALL.VER_SYSTEM_REFERENCE_ID1%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_ver_reference_id2        IS TABLE OF OKC_ART_INTERFACE_ALL.VER_SYSTEM_REFERENCE_ID2%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_instructions             IS TABLE OF OKC_ART_INTERFACE_ALL.ADDITIONAL_INSTRUCTIONS%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_date_published           IS TABLE OF OKC_ART_INTERFACE_ALL.DATE_PUBLISHED%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute_category       IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE_CATEGORY%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute1               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute2               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute3               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE3%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute4               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute5               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute6               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute7               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE7%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute8               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE8%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute9               IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE9%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute10              IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE10%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute11              IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE11%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute12              IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE12%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute13              IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE13%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute14              IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE14%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_attribute15              IS TABLE OF OKC_ART_INTERFACE_ALL.ATTRIBUTE15%TYPE INDEX BY BINARY_INTEGER ;
 --Clause Editing
     TYPE l_inf_edited_in_word           IS TABLE OF OKC_ART_INTERFACE_ALL.EDITED_IN_WORD%TYPE INDEX BY BINARY_INTEGER ;
     TYPE l_inf_article_text_in_word     IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_TEXT_IN_WORD%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_version_id       IS TABLE OF OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_article_version_number   IS TABLE OF OKC_ART_INTERFACE_ALL.ARTICLE_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_inf_adoption_type            IS TABLE OF OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE INDEX BY BINARY_INTEGER ;
    --clm
--    TYPE l_inf_variable_code            IS TABLE OF OKC_ARTICLE_VERSIONS.VARIABLE_CODE%TYPE INDEX BY BINARY_INTEGER ;

-- For Article Variables
    TYPE list_artv_article_version_id   IS TABLE OF OKC_ARTICLE_VARIABLES.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_artv_variable_code        IS TABLE OF OKC_ARTICLE_VARIABLES.VARIABLE_CODE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_artv_action               IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER ;

    l_article_language                  VARCHAR2(3);

-- Variables for interface
   inf_interface_id_tbl                 l_inf_interface_id ;
   inf_batch_number_tbl                 l_inf_batch_number ;
   inf_object_version_number_tbl        l_inf_object_version_number ;
   inf_article_title_tbl                l_inf_article_title ;
   inf_org_id_tbl                       l_inf_org_id ;
   inf_process_status_tbl               l_inf_process_status ;
   inf_action_tbl                       l_inf_action ;
   inf_article_number_tbl               l_inf_article_number ;
   inf_article_intent_tbl               l_inf_article_intent ;
   inf_x_article_intent_tbl             l_inf_article_intent ;
   inf_article_language_tbl             l_inf_article_language ;
   inf_x_article_language_tbl           l_inf_article_language ;
   inf_article_type_tbl                 l_inf_article_type ;
   inf_article_id_tbl                   l_inf_article_id ;
   inf_art_reference_code_tbl           l_inf_art_reference_code ;
   inf_art_reference_id1_tbl            l_inf_art_reference_id1 ;
   inf_art_reference_id2_tbl            l_inf_art_reference_id2 ;
   inf_article_text_tbl                 l_inf_article_text ;
   inf_provision_yn_tbl                 l_inf_provision_yn ;
   inf_insert_by_reference_tbl          l_inf_insert_by_reference ;
   inf_lock_text_tbl                    l_inf_lock_text ;
   inf_global_yn_tbl                    l_inf_global_yn ;
   inf_article_status_tbl               l_inf_article_status ;
   inf_start_date_tbl                   l_inf_start_date ;
   inf_end_date_tbl                     l_inf_end_date ;
   inf_display_name_tbl                 l_inf_display_name ;
   inf_article_description_tbl          l_inf_article_description ;
   inf_date_approved_tbl                l_inf_date_approved ;
   inf_default_section_tbl              l_inf_default_section ;
   inf_reference_source_tbl             l_inf_reference_source ;
   inf_reference_text_tbl               l_inf_reference_text ;
   inf_ver_reference_code_tbl           l_inf_ver_reference_code ;
   inf_ver_reference_id1_tbl            l_inf_ver_reference_id1 ;
   inf_ver_reference_id2_tbl            l_inf_ver_reference_id2 ;
   inf_instructions_tbl                 l_inf_instructions ;
   inf_date_published_tbl               l_inf_date_published ;
   inf_attribute_category_tbl           l_inf_attribute_category ;
   inf_attribute1_tbl                   l_inf_attribute1 ;
   inf_attribute2_tbl                   l_inf_attribute2 ;
   inf_attribute3_tbl                   l_inf_attribute3 ;
   inf_attribute4_tbl                   l_inf_attribute4 ;
   inf_attribute5_tbl                   l_inf_attribute5 ;
   inf_attribute6_tbl                   l_inf_attribute6 ;
   inf_attribute7_tbl                   l_inf_attribute7 ;
   inf_attribute8_tbl                   l_inf_attribute8 ;
   inf_attribute9_tbl                   l_inf_attribute9 ;
   inf_attribute10_tbl                  l_inf_attribute10 ;
   inf_attribute11_tbl                  l_inf_attribute11 ;
   inf_attribute12_tbl                  l_inf_attribute12 ;
   inf_attribute13_tbl                  l_inf_attribute13 ;
   inf_attribute14_tbl                  l_inf_attribute14 ;
   inf_attribute15_tbl                  l_inf_attribute15 ;
 --Clause Editing
   inf_edited_in_word_tbl               l_inf_edited_in_word ;
   inf_article_text_in_word_tbl         l_inf_article_text_in_word ;
   inf_article_version_id_tbl           l_inf_article_version_id ;
   inf_earlier_version_id_tbl           l_inf_article_version_id ;
   inf_article_version_number_tbl       l_inf_article_version_number ;
   inf_adoption_type_tbl                l_inf_adoption_type;
   --clm
--   inf_variable_code_tbl                 l_inf_variable_code;

   artv_article_version_id_tbl          list_artv_article_version_id ;
   artv_variable_code_tbl               OKC_ARTICLES_GRP.variable_code_tbl_type ;
   artv_action_tbl                      list_artv_action ;
   l_variable_code_tbl                  OKC_ARTICLES_GRP.variable_code_tbl_type ;

   I NUMBER := 0;
   j NUMBER := 0;
   k NUMBER := 0;
   x NUMBER := 0;
   l_earlier_version_id                 OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE;
   l_article_version_id                 OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE;
   l_article_status                     OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE;
   l_start_date                         OKC_ARTICLE_VERSIONS.START_DATE%TYPE;
   l_edited_in_word                     OKC_ARTICLE_VERSIONS.EDITED_IN_WORD%TYPE;
   l_tmp_article_status                 OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE;
   l_earlier_version_number             OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE;
   l_earlier_adoption_type              OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;
   l_article_number                     OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;
   l_article_version_number             OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE;
   l_variables_to_insert_tbl            OKC_ARTICLES_GRP.variable_code_tbl_type;
   l_variables_to_delete_tbl            OKC_ARTICLES_GRP.variable_code_tbl_type;
   l_adoption_type                      OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;
   l_program_id                         OKC_ART_INTERFACE_ALL.PROGRAM_ID%TYPE;
   l_program_login_id                   OKC_ART_INTERFACE_ALL.PROGRAM_LOGIN_ID%TYPE;
   l_program_appl_id                    OKC_ART_INTERFACE_ALL.PROGRAM_APPLICATION_ID%TYPE;
   l_request_id                         OKC_ART_INTERFACE_ALL.REQUEST_ID%TYPE;
   l_variable_name                      OKC_BUS_VARIABLES_TL.VARIABLE_NAME%TYPE;
   l_variable_type                      OKC_BUS_VARIABLES_B.VARIABLE_TYPE%TYPE;
   l_value_set_id                       FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_ID%TYPE;
   l_return_status                      VARCHAR2(1);
   api_return_status                    VARCHAR2(1);
   l_doc_sequence_type                  CHAR(1);
   l_error_index                        NUMBER          := 1;
   l_replace_text                       VARCHAR2(1)     := 'N';
   l_batch_process_id                   NUMBER          := 1;
   l_context                            VARCHAR2(50)    := NULL;
   l_init_msg_list                      VARCHAR2(200)   := okc_api.g_true;
   l_tot_rows_processed                 NUMBER          := 0;
   l_tot_rows_failed                    NUMBER          := 0;
   l_tot_rows_warned                    NUMBER          := 0;
   l_part_rows_processed                NUMBER          := 0;
   l_part_rows_failed                   NUMBER          := 0;
   l_part_rows_warned                   NUMBER          := 0;
   l_bulk_failed                        VARCHAR2(1)     := 'Y';
   l_exist_approver                     VARCHAR2(5)     := 'NOK';
   save_threshold                       WF_ENGINE.threshold%TYPE;

------------------------------------------------------------------------
--  PROCEDURE import_articles body starts
-------------------------------------------------------------------------

BEGIN


IF (l_debug = 'Y') THEN
  okc_debug.log('100: Entered article_import', 2);
END IF;


------------------------------------------------------------------------
--  Variable Initialization
-------------------------------------------------------------------------

-- Standard Start of API savepoint
FND_MSG_PUB.initialize;
--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_return_status := G_RET_STS_SUCCESS;
--  Cache user_id, login_id and org_id
l_user_id  := Fnd_Global.user_id;
l_login_id := Fnd_Global.login_id;
l_userenv_lang := USERENV('LANG');

-- MOAC
G_CURRENT_ORG_ID := mo_global.get_current_org_id();
/*
OPEN cur_org_csr;
FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
CLOSE cur_org_csr;
*/
-- MOAC
IF G_CURRENT_ORG_ID IS NULL THEN
   Okc_Api.Set_Message(G_APP_NAME,'OKC_ART_NULL_ORG_ID');
   RAISE FND_API.G_EXC_ERROR;
END IF;


IF G_CURRENT_ORG_ID = G_GLOBAL_ORG_ID THEN
   l_adoption_type := NULL;
ELSE
   l_adoption_type := 'LOCAL';
END IF;


IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
   l_program_id := NULL;
ELSE
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
END IF;

IF FND_GLOBAL.CONC_LOGIN_ID = -1 THEN
   l_program_login_id := NULL;
ELSE
   l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
END IF;

IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
   l_program_appl_id := NULL;
ELSE
   l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
END IF;

IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
   l_request_id := NULL;
ELSE
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
END IF;

l_batch_process_id := p_batch_procs_id;
------------------------------------------------------------------------
--  Parameter Validation
-------------------------------------------------------------------------

IF (p_fetchsize > G_FETCHSIZE_LIMIT) THEN
   x_return_status := G_RET_STS_ERROR;
   l_return_status := G_RET_STS_ERROR;

   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                       p_msg_name     => 'OKC_ART_IMP_LIM_FETCHSIZE');

   build_error_array(
       p_msg_data     => x_msg_data,
       p_context      => NULL,
       p_batch_process_id => l_batch_process_id,
       p_interface_id  => -99,
       p_article_title => NULL,
       p_error_type    => l_return_status,
	  p_entity        => 'CLAUSE'
   );

   RAISE FND_API.G_EXC_ERROR ;
END IF;

------------------------------------------------------------------------
--  Global TempClob Array Initialization
-------------------------------------------------------------------------
    g_temp_clob_tbl.extend(p_fetchsize);
    FOR i in 1..p_fetchsize LOOP
       -- Create Temporary Clob.  Clob is created not in session level to prevent
       -- from running ouf of session memory
       DBMS_LOB.CREATETEMPORARY(g_temp_clob_tbl(i), TRUE);
    END LOOP;

-------------------------------------------------------------------------
--------------- the outermost loop of this procedure --------------------
-- Bulk fetch all interface rows based on the fetchsize passed by the user
-------------------------------------------------------------------------

l_context :='BULK FETCH CLAUSE INTERFACE ROW';
OPEN l_interface_csr ( G_CURRENT_ORG_ID ,
                       p_batch_number );
LOOP
BEGIN
    FETCH l_interface_csr BULK COLLECT INTO
        inf_interface_id_tbl   ,
        inf_batch_number_tbl   ,
        inf_object_version_number_tbl  ,
        inf_article_title_tbl ,
        inf_org_id_tbl   ,
        inf_process_status_tbl   ,
        inf_action_tbl   ,
        inf_article_number_tbl   ,
        inf_article_intent_tbl   ,
        inf_x_article_intent_tbl ,
        inf_article_language_tbl   ,
        inf_x_article_language_tbl ,
        inf_article_type_tbl   ,
        inf_article_id_tbl   ,
        inf_art_reference_code_tbl   ,
        inf_art_reference_id1_tbl   ,
        inf_art_reference_id2_tbl   ,
        inf_article_version_number_tbl   ,
        inf_article_text_tbl   ,
        inf_provision_yn_tbl   ,
        inf_insert_by_reference_tbl   ,
        inf_lock_text_tbl   ,
        inf_global_yn_tbl   ,
        inf_article_status_tbl   ,
        inf_start_date_tbl   ,
        inf_end_date_tbl   ,
        inf_display_name_tbl   ,
        inf_article_description_tbl   ,
        inf_date_approved_tbl   ,
        inf_default_section_tbl   ,
        inf_reference_source_tbl   ,
        inf_reference_text_tbl   ,
        inf_ver_reference_code_tbl   ,
        inf_ver_reference_id1_tbl   ,
        inf_ver_reference_id2_tbl   ,
        inf_instructions_tbl   ,
        inf_date_published_tbl   ,
        inf_attribute_category_tbl   ,
        inf_attribute1_tbl   ,
        inf_attribute2_tbl   ,
        inf_attribute3_tbl   ,
        inf_attribute4_tbl   ,
        inf_attribute5_tbl   ,
        inf_attribute6_tbl   ,
        inf_attribute7_tbl   ,
        inf_attribute8_tbl   ,
        inf_attribute9_tbl   ,
        inf_attribute10_tbl   ,
        inf_attribute11_tbl   ,
        inf_attribute12_tbl   ,
        inf_attribute13_tbl   ,
        inf_attribute14_tbl   ,
        inf_attribute15_tbl   ,
        inf_edited_in_word_tbl   ,
        inf_article_text_in_word_tbl   ,
        inf_article_version_id_tbl  LIMIT p_fetchsize;
    EXIT WHEN inf_interface_id_tbl.COUNT = 0 ;

    ------------------------------------------------------------------------
    -- Variable initialization
    -------------------------------------------------------------------------
    --For each fetch, article variable table index should be initialized
    j := 1;
    --##count:initialization
    l_tot_rows_processed    := l_tot_rows_processed+l_part_rows_processed;
    l_tot_rows_failed       := l_tot_rows_failed+l_part_rows_failed;
    l_tot_rows_warned       := l_tot_rows_warned+l_part_rows_warned;
    l_part_rows_processed   := 0;
    l_part_rows_failed      := 0;
    l_part_rows_warned      := 0;
    l_bulk_failed           := 'N';
    ---------------------------------------------------------------------------
    --------------------- Inner Loop thru fetched rows for---------------------
    -- validation, parse and validate article text, create a variable list
    -- prepare rows for DML if validate_only is 'N'
    /***  Processing Rule to set process_status
    Because we want to collect as much info as possible, we need to
    maintain process status while keeping the process moving.
    So, we'll set l_return_status as validation goes on and
    at the end we will set inf_process_status_tbl(i) with l_return_status
    for final result.  However, we will get out of this process if there
    is a significant error such as 'U'.
    The return status examined
    -api_return_status : return status for api call
    -l_return_status : validation result of each row
    -x_return_status : final result status for concurrent program request
    Rule to set return status
    If api_return_status for api call is
    * 'S' then continue
    * 'W' and l_return_status not 'E' or 'U' then set l_return_status = 'W'
        and build_error_array then continue
    * 'E' and it is significant then set l_return_status = 'E' and raise
      Exception
    * 'E' and it is minor then set l_return_status = 'E' and continue. Raise
       'E' at the end of validation
    * 'U' then set l_return_status = 'U' and raise 'U' exception
    * At the end, if it goes thru with no Exception,
    Check if l_return_status is 'E' then raise Exception
       Otherwise (meaning l_return_status is 'S' or 'W'),
          inf_process_status_tbl(i) = l_return_status
    * In the exception, we will set
          inf_process_status_tbl(i) = l_return_status and build_error_array
    ***/
    -------------------------------------------------------------------------

    FOR i in inf_interface_id_tbl.FIRST ..inf_interface_id_tbl.LAST LOOP
      BEGIN
      -- Increment total processed rows
      --##Count
      --l_tot_rows_processed := l_tot_rows_processed+1;
      l_part_rows_processed := l_part_rows_processed+1;
      -- Initialization for each iteration
      l_row_notfound       := FALSE;
      l_return_status      := G_RET_STS_SUCCESS;
      --for validate_row, we will pass 'DRAFT' status for 'APPROVED'
      --and 'PENDING_APPROVAL' status as it just means for submission for approval
      --or approved
      l_tmp_article_status := inf_article_status_tbl(i);
      -- following variables are not fetched from interface table
      -- thus initialize it here
      inf_earlier_version_id_tbl(i) := -99;
      inf_adoption_type_tbl(i) := l_adoption_type;


      l_context := 'CLAUSE VALIDATING';

      -- To find duplicate title in the batch after RTRIM is performed Bug 3487759
      IF i>1 THEN
         x := i-1;
         IF RTRIM(inf_article_title_tbl(i)) = RTRIM(inf_article_title_tbl(x)) THEN
            Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_DUP_TITLE_ORG');
            l_return_status := G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      -- Logic to decide what to do in case of Action='S'
	 -- If there is no existing article in system then it is 'N' otherwise 'V'

	 IF inf_action_tbl(i) = 'S' THEN
         IF inf_article_id_tbl(i) IS NULL THEN
	       inf_action_tbl(i) := 'N';
	    ELSE
-- Changes for Bug# 6891498 Begins
 	            OPEN get_max_article_version_csr (inf_article_id_tbl(i));
 	            FETCH get_max_article_version_csr INTO l_article_version_id,
 	                                                   l_article_version_number,
 	                                                   l_article_status,
 	                                                   l_start_date,
                                                           l_edited_in_word;
 	            l_row_notfound := get_max_article_version_csr%NOTFOUND;
 	            CLOSE get_max_article_version_csr;
 	             IF nvl(l_article_status,'*') in ('DRAFT', 'REJECTED') THEN
 	               inf_action_tbl(i) := 'U';
 	             ELSE
-- Changes for Bug# 6891498 Ends
	       inf_action_tbl(i) := 'V';
           END IF; -- For Bug# 6891498
 --Clause Editing start
  IF nvl(l_edited_in_word,'N') = 'Y' AND inf_edited_in_word_tbl(i) = 'N' THEN
                         Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKC_ART_IMP_INV_EDT_WORD_UPD');
                        l_return_status := G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR ;
                    END IF;
 --Clause Editing end
	    END IF;
	 END IF;

	 IF inf_action_tbl(i) = 'N' THEN

          inf_article_id_tbl(i) := NULL;
          IF nvl(inf_article_status_tbl(i), '*') not in
                 ('DRAFT','APPROVED','PENDING_APPROVAL')  THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_IMP_INV_STS_NEWA',
                      p_token1       => 'STATUS1',
                      p_token1_value => 'DRAFT',
                      p_token2       => 'STATUS2',
                      p_token2_value => 'APPROVED',
                      p_token3       => 'STATUS3',
                      p_token3_value => 'PENDING_APPROVAL');
              l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;

          --TRIM trailing space because article title in library table has been trimmed
          --for successful comparison, this should be trimmed
          inf_article_title_tbl(i) := RTRIM(inf_article_title_tbl(i));

          -- Set article version number as 1
          inf_article_version_number_tbl(i) := 1;

          --validate this article with 'DRAFT'
          l_tmp_article_status := 'DRAFT';

      ELSIF inf_action_tbl(i) = 'U' THEN

          IF inf_article_id_tbl(i) is NULL THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_ARTICLE_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => inf_article_title_tbl(i));
              l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;

          OPEN get_max_article_version_csr (inf_article_id_tbl(i));
           FETCH get_max_article_version_csr INTO l_article_version_id,
                                                  l_article_version_number,
                                                  l_article_status,
						  l_start_date,
						  l_edited_in_word;
           l_row_notfound := get_max_article_version_csr%NOTFOUND;
          CLOSE get_max_article_version_csr;

          IF nvl(l_article_status,'*') not in ('DRAFT', 'REJECTED') THEN
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_IMP_INV_CUR_STS_UPD');
              l_return_status := G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR ;
          END IF;
 --Clause Editing start
  IF nvl(l_edited_in_word,'N') = 'Y' AND inf_edited_in_word_tbl(i) = 'N' THEN
                         Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKC_ART_IMP_INV_EDT_WORD_NV');
                        l_return_status := G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR ;
                    END IF;
 --Clause Editing end
          -- this status may be null for update row
          -- inf_article_status_tbl(i) := l_article_status;
          -- set the version number
          inf_article_version_number_tbl(i) := l_article_version_number;
          -- set article version id
          inf_article_version_id_tbl(i)  := l_article_version_id;

          IF nvl(inf_article_status_tbl(i), '*') not in
                 ('DRAFT','REJECTED','APPROVED','PENDING_APPROVAL')  THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_IMP_INV_STS_UPD',
                      p_token1       => 'STATUS1',
                      p_token1_value => 'DRAFT',
                      p_token2       => 'STATUS2',
                      p_token2_value => 'REJECTED',
                      p_token3       => 'STATUS3',
                      p_token3_value => 'APPROVED',
                      p_token4       => 'STATUS4',
                      p_token4_value => 'PENDING_APPROVAL');
                l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;

          --if interface article status is DRAFT and REJECTED then keep
          --the one in the library table.  We don't want user to be able to change them
          --validate this article with 'DRAFT' for 'DRAFT', 'APPROVED', 'PENDING_APPROVAL'
          --or 'REJECTED' for 'REJECTED'
          IF nvl(inf_article_status_tbl(i), '*') in ('DRAFT', 'REJECTED') THEN
              inf_article_status_tbl(i) := l_article_status;
              l_tmp_article_status := l_article_status;
          ELSE
              l_tmp_article_status := 'DRAFT';
          END IF;


          -- User entered attribute in article level (intent, language) may not be
          -- accurate because we do not validate them for Update
          -- so here we need to fill some important attribute
          -- in interface table from database
          inf_article_intent_tbl(i) := inf_x_article_intent_tbl(i);
          inf_article_language_tbl(i) := inf_x_article_language_tbl(i);

      ELSIF inf_action_tbl(i) = 'V' THEN

          inf_article_version_id_tbl(i) := NULL;
          IF inf_article_id_tbl(i) is NULL THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_ARTICLE_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => inf_article_title_tbl(i));
              l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;

          IF nvl(inf_article_status_tbl(i), '*') not in
                 ('DRAFT','APPROVED','PENDING_APPROVAL')  THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_IMP_INV_STS_NEWA',
                      p_token1       => 'STATUS1',
                      p_token1_value => 'DRAFT',
                      p_token2       => 'STATUS2',
                      p_token2_value => 'APPROVED',
                      p_token3       => 'STATUS3',
                      p_token3_value => 'PENDING_APPROVAL');
                l_return_status := G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
          END IF;


          -- User entered attribute in article level (intent, language)may not be
          -- accurate because we do not validate them for New Version
          -- so here we need to fill some important attribute
          -- in interface table from database
          inf_article_intent_tbl(i) := inf_x_article_intent_tbl(i);
          inf_article_language_tbl(i) := inf_x_article_language_tbl(i);

          OPEN get_max_article_version_csr (inf_article_id_tbl(i));
           FETCH get_max_article_version_csr INTO l_article_version_id,
                                                  l_article_version_number,
                                                  l_article_status,
						  l_start_date,
						  l_edited_in_word;
           l_row_notfound := get_max_article_version_csr%NOTFOUND;
          CLOSE get_max_article_version_csr;
     --Clause Editing
 IF nvl(l_edited_in_word,'N') = 'Y' AND inf_edited_in_word_tbl(i) = 'N' THEN
                         Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKC_ART_IMP_INV_EDT_WORD_NV');
                        l_return_status := G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR ;
                    END IF;
 --Clause Editing
          -- Set article version number
          inf_article_version_number_tbl(i) := l_article_version_number +1;

          --validate article with 'DRAFT' status
          --because validate_row api validation for 'Approved' article
          --is more suitable for article in 'Approved' status already
          --but in import, status 'Approved' means submission for approval
          l_tmp_article_status := 'DRAFT';
      ELSIF inf_action_tbl(i) = 'D' THEN

          IF inf_article_id_tbl(i) is NULL THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_ARTICLE_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => inf_article_title_tbl(i));
              l_return_status := G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR ;
          END IF;

          IF inf_end_date_tbl(i) IS NULL THEN
                  Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                      p_msg_name => 'OKC_ART_NULL_END_DATE');
                  l_return_status := G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
          END IF;

          OPEN get_max_article_version_csr (inf_article_id_tbl(i));
          FETCH get_max_article_version_csr INTO l_article_version_id,
                                                  l_article_version_number,
                                                  l_article_status,
						  l_start_date,
						  l_edited_in_word;
           l_row_notfound := get_max_article_version_csr%NOTFOUND;
           CLOSE get_max_article_version_csr;

           IF l_row_notfound THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_ARTICLE_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => inf_article_title_tbl(i));

                l_return_status := G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
         ELSE

            IF l_start_date IS NOT NULL
            THEN
               IF l_start_date > inf_end_date_tbl(i) THEN
                  Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                      p_msg_name => 'OKC_INVALID_END_DATE');
                  l_return_status := G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
         END IF;

          -- set the version number
          inf_article_version_number_tbl(i) := l_article_version_number;
          -- set article version id
          inf_article_version_id_tbl(i)  := l_article_version_id;

      ELSE

          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_ART_INV_IMP_ACTION');
          l_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR ;
      END IF;

      -----------------------------------------------------------
      -- Common validation or attribute settting
      -- regardless of status and import action
      -- this validation is not included in validate api
      -----------------------------------------------------------

      -- Do not import article if status or org_id or global_flag is not provided
	 IF inf_article_status_tbl(i) IS NULL OR
	    inf_org_id_tbl(i) IS NULL OR
	    inf_global_yn_tbl(i) IS NULL THEN
		    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
		                        p_msg_name     => 'OKC_ART_ATTRS_NOT_PROVIDED');
	         l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Do not import 'PENDING_APPROVAL' article if approver is not set
      IF nvl(inf_article_status_tbl(i), '*') = 'PENDING_APPROVAL' THEN
         l_exist_approver := OKC_ARTWF_PVT.pre_submit_validation(G_CURRENT_ORG_ID);
         IF l_exist_approver = 'NOK' THEN
           l_return_status := G_RET_STS_ERROR;
         END IF;
      END IF;

      -- Do not import article if orig_system_reference_code begins with 'OKCMIG'
      IF instr(nvl(inf_art_reference_code_tbl(i), '*'), 'OKCMIG') = 1 THEN
            Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_ART_IMP_RES_SYS_REF_CODE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF instr(nvl(inf_ver_reference_code_tbl(i), '*'), 'OKCMIG') = 1 THEN
            Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_ART_IMP_RES_SYS_REF_CODE');
            l_return_status := G_RET_STS_ERROR;
      END IF;


      --for non 'APPROVED' article, make DATE_APPROVED null
      IF nvl(inf_article_status_tbl(i),'*') <> 'APPROVED' THEN
        inf_date_approved_tbl(i) := NULL;
      END IF;

      --if article status is in 'APPROVED' and date_approved is null
      --then set date approved as sysdate
      --otherwise, the validate api will complain
      IF nvl(inf_article_status_tbl(i), '*') in ('APPROVED') AND
         inf_date_approved_tbl(i) is NULL THEN
         inf_date_approved_tbl(i) := sysdate;
      END IF;

      --Bug 3680486: no provision for sell intent clause
      IF     nvl(inf_article_intent_tbl(i), '*') = 'S'
         AND nvl(inf_provision_yn_tbl(i), '*') = 'Y' THEN
            Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_ART_INVALID_PROVISIONYN');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Validate attrs of the interface row
      IF inf_action_tbl(i) = 'N' THEN
          api_return_status :=
          OKC_ARTICLES_ALL_PVT.VALIDATE_RECORD(
                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                p_import_action              => inf_action_tbl(i),
                p_article_id                 => inf_article_id_tbl(i),
                p_article_title              => inf_article_title_tbl(i),
                p_org_id                     => G_CURRENT_ORG_ID,
                p_article_number             => inf_article_number_tbl(i),
                p_standard_yn                => 'Y',
                p_article_intent             => inf_article_intent_tbl(i),
                p_article_language           => inf_article_language_tbl(i),
                p_article_type               => inf_article_type_tbl(i),
                p_orig_system_reference_code => inf_art_reference_code_tbl(i),
                p_orig_system_reference_id1  => inf_art_reference_id1_tbl(i),
                p_orig_system_reference_id2  => inf_art_reference_id2_tbl(i),
                p_attribute_category         => NULL ,
                p_attribute1                 => NULL ,
                p_attribute2                 => NULL ,
                p_attribute3                 => NULL ,
                p_attribute4                 => NULL ,
                p_attribute5                 => NULL ,
                p_attribute6                 => NULL ,
                p_attribute7                 => NULL ,
                p_attribute8                 => NULL ,
                p_attribute9                 => NULL ,
                p_attribute10                => NULL ,
                p_attribute11                => NULL ,
                p_attribute12                => NULL ,
                p_attribute13                => NULL ,
                p_attribute14                => NULL ,
                p_attribute15                => NULL
          );
      --
      -- If error is Unexpected then raise exception
      -- Otherwise, keep going
      --
      IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (api_return_status = G_RET_STS_ERROR) THEN
         l_return_status := G_RET_STS_ERROR;
      END IF;
          api_return_status :=
            OKC_ARTICLE_VERSIONS_PVT.validate_record(
                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                p_import_action              => inf_action_tbl(i),
                x_earlier_adoption_type      => l_earlier_adoption_type,
                x_earlier_version_id         => l_earlier_version_id,
                x_earlier_version_number     => l_earlier_version_number,
                x_article_language           => l_article_language,
                p_article_version_id         => inf_article_version_id_tbl(i),
                p_article_id                 => inf_article_id_tbl(i),
                p_article_version_number     => inf_article_version_number_tbl(i),
                p_article_text               => inf_article_text_tbl(i),
                p_provision_yn               => inf_provision_yn_tbl(i),
                p_insert_by_reference        => inf_insert_by_reference_tbl(i),
                p_lock_text                  => inf_lock_text_tbl(i),
                p_global_yn                  => inf_global_yn_tbl(i),
                p_article_language           => inf_article_language_tbl(i),
                p_article_status             => l_tmp_article_status,
                p_sav_release                => NULL,
                p_start_date                 => inf_start_date_tbl(i),
                p_end_date                   => inf_end_date_tbl(i),
                p_std_article_version_id     => NULL,
                p_display_name               => inf_display_name_tbl(i),
                p_translated_yn              => NULL,
                p_article_description        => inf_article_description_tbl(i),
                p_date_approved              => inf_date_approved_tbl(i),
                p_default_section            => inf_default_section_tbl(i),
                p_reference_source           => inf_reference_source_tbl(i),
                p_reference_text             => inf_reference_text_tbl(i),
                p_orig_system_reference_code => inf_art_reference_code_tbl(i),
                p_orig_system_reference_id1  => inf_art_reference_id1_tbl(i),
                p_orig_system_reference_id2  => inf_art_reference_id2_tbl(i),
                p_program_id                 => NULL,
                p_program_application_id     => NULL,
                p_request_id                 => NULL,
                p_current_org_id             => G_CURRENT_ORG_ID,
                p_additional_instructions    => inf_instructions_tbl(i),
                p_variation_description      => NULL,
                p_date_published             => inf_date_published_tbl(i) ,
                p_attribute_category         => inf_attribute_category_tbl(i) ,
                p_attribute1                 => inf_attribute1_tbl(i) ,
                p_attribute2                 => inf_attribute2_tbl(i) ,
                p_attribute3                 => inf_attribute3_tbl(i) ,
                p_attribute4                 => inf_attribute4_tbl(i) ,
                p_attribute5                 => inf_attribute5_tbl(i) ,
                p_attribute6                 => inf_attribute6_tbl(i) ,
                p_attribute7                 => inf_attribute7_tbl(i) ,
                p_attribute8                 => inf_attribute8_tbl(i) ,
                p_attribute9                 => inf_attribute9_tbl(i) ,
                p_attribute10                => inf_attribute10_tbl(i) ,
                p_attribute11                => inf_attribute11_tbl(i) ,
                p_attribute12                => inf_attribute12_tbl(i) ,
                p_attribute13                => inf_attribute13_tbl(i) ,
                p_attribute14                => inf_attribute14_tbl(i) ,
                p_attribute15                => inf_attribute15_tbl(i) ,
 --Clause Editing
                p_edited_in_word             => inf_edited_in_word_tbl(i) ,
                p_article_text_in_word       => inf_article_text_in_word_tbl(i)
                --clm
                --p_variable_code              => inf_variable_code_tbl(i)
            );

      IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (api_return_status = G_RET_STS_ERROR) THEN
         l_return_status := G_RET_STS_ERROR;
      END IF;

      ELSIF inf_action_tbl(i) in ('U','V') THEN
         --validating only article type because only article type is updated
         l_row_notfound := FALSE;
         OPEN validate_article_type_csr (inf_article_type_tbl(i),
                                         inf_article_id_tbl(i),
                                         inf_action_tbl(i));
           FETCH validate_article_type_csr INTO inf_article_type_tbl(i);
           l_row_notfound := validate_article_type_csr%NOTFOUND;
         CLOSE validate_article_type_csr;

         IF l_row_notfound THEN
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_ART_INVALID_ARTICLE_TYPE',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => inf_article_title_tbl(i));
              l_return_status := G_RET_STS_ERROR;

         END IF;

            -- nvl for nullable column to avoid getting database value
            -- in the validate API
          api_return_status :=
            OKC_ARTICLE_VERSIONS_PVT.validate_record(
                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                p_import_action              => inf_action_tbl(i),
                x_earlier_adoption_type      => l_earlier_adoption_type,
                x_earlier_version_id         => l_earlier_version_id,
                x_earlier_version_number     => l_earlier_version_number,
                x_article_language           => l_article_language,
                p_article_version_id         => inf_article_version_id_tbl(i),
                p_article_id                 => inf_article_id_tbl(i),
                p_article_version_number     => inf_article_version_number_tbl(i),
                p_article_text               => inf_article_text_tbl(i),
                p_provision_yn               => inf_provision_yn_tbl(i),
                p_insert_by_reference        => inf_insert_by_reference_tbl(i),
                p_lock_text                  => inf_lock_text_tbl(i),
                p_global_yn                  => inf_global_yn_tbl(i),
                p_article_language           => inf_article_language_tbl(i),
                p_article_status             => l_tmp_article_status,
                p_sav_release                => NULL,
                p_start_date                 => inf_start_date_tbl(i),
                p_end_date                   => inf_end_date_tbl(i),
                p_std_article_version_id     => NULL,
                p_display_name               => inf_display_name_tbl(i),
                p_translated_yn              => NULL,
                p_article_description        => inf_article_description_tbl(i),
                p_date_approved              => inf_date_approved_tbl(i),
                p_default_section            => inf_default_section_tbl(i),
                p_reference_source           => inf_reference_source_tbl(i),
                p_reference_text             => inf_reference_text_tbl(i),
                p_orig_system_reference_code => inf_art_reference_code_tbl(i),
                p_orig_system_reference_id1  => inf_art_reference_id1_tbl(i),
                p_orig_system_reference_id2  => inf_art_reference_id2_tbl(i),
                p_program_id                 => NULL,
                p_program_application_id     => NULL,
                p_request_id                 => NULL,
                p_current_org_id             => G_CURRENT_ORG_ID,
                p_additional_instructions    => inf_instructions_tbl(i),
                p_variation_description      => NULL,
                p_date_published             => inf_date_published_tbl(i) ,
                p_attribute_category         => inf_attribute_category_tbl(i) ,
                p_attribute1                 => inf_attribute1_tbl(i) ,
                p_attribute2                 => inf_attribute2_tbl(i) ,
                p_attribute3                 => inf_attribute3_tbl(i) ,
                p_attribute4                 => inf_attribute4_tbl(i) ,
                p_attribute5                 => inf_attribute5_tbl(i) ,
                p_attribute6                 => inf_attribute6_tbl(i) ,
                p_attribute7                 => inf_attribute7_tbl(i) ,
                p_attribute8                 => inf_attribute8_tbl(i) ,
                p_attribute9                 => inf_attribute9_tbl(i) ,
                p_attribute10                => inf_attribute10_tbl(i) ,
                p_attribute11                => inf_attribute11_tbl(i) ,
                p_attribute12                => inf_attribute12_tbl(i) ,
                p_attribute13                => inf_attribute13_tbl(i) ,
                p_attribute14                => inf_attribute14_tbl(i) ,
                p_attribute15                => inf_attribute15_tbl(i) ,
                p_edited_in_word             => inf_edited_in_word_tbl(i) ,
                p_article_text_in_word       => inf_article_text_in_word_tbl(i)
                --clm
                --p_variable_code              => inf_variable_code_tbl(i)
            );
      END IF;


      --
      --
      -- If error is Unexpected then raise exception
      -- Otherwise, keep going
      --
      --
      IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (api_return_status = G_RET_STS_ERROR) THEN
         l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Continue with the rest of validation unless some unexpected error is encountered.
      -- It is always a good idea to show all errors at one shot.
      -- Parse through the article text and build the list of variables to be used.
      -- For validate only mode = N change the user friendly variable tags with valid XML and variable codes.

      IF p_validate_only = 'N' THEN
         l_replace_text := 'Y';
      ELSE
         l_replace_text := 'N';
      END IF;

      --
      -- Copying the clob in interface into temporary clob
      --
      --

      DBMS_LOB.TRIM(g_temp_clob_tbl(i), 0);

      OKC_ARTICLES_GRP.parse_n_replace_text(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            p_article_text                 => inf_article_text_tbl(i),
            p_dest_clob                    => g_temp_clob_tbl(i),
            p_calling_mode                 => 'IMPORT',
		  p_batch_number                 => p_batch_number,  -- Bug 4659659
            p_replace_text                 => l_replace_text,
            p_article_intent               => inf_article_intent_tbl(i),
            p_language                     => inf_article_language_tbl(i),
            x_return_status                => api_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            x_variables_tbl                => l_variable_code_tbl
      ) ;

      -- Add value_set check for 'PENDING_APPROVAL' and 'APPROVED' clause
      IF (inf_article_status_tbl(i) in ('PENDING_APPROVAL','APPROVED')) THEN
        IF l_variable_code_tbl.COUNT > 0 THEN
           k:=0;
           FOR k in l_variable_code_tbl.FIRST ..l_variable_code_tbl.LAST LOOP
              OPEN  l_check_valid_valueset_csr (l_variable_code_tbl(k));
              FETCH l_check_valid_valueset_csr  INTO l_value_set_id,
                                                     l_variable_type;
              CLOSE l_check_valid_valueset_csr;

              IF l_value_set_id is NULL AND l_variable_type = 'U' THEN
                OPEN  l_var_name_csr (l_variable_code_tbl(k),
                                      inf_article_language_tbl(i));
                FETCH l_var_name_csr  INTO l_variable_name;
                CLOSE l_var_name_csr;
                 Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKC_ART_INV_VALUESET',
                          p_token1       => 'VARIABLE_NAME',
                          p_token1_value => l_variable_name,
                          p_token2       => 'ARTICLE_TITLE',
                          p_token2_value => inf_article_title_tbl(i),
                          p_token3       => 'ARTICLE_VERSION',
                          p_token3_value => inf_article_version_number_tbl(i));
                  api_return_status := G_RET_STS_ERROR;
              END IF;
           END LOOP;
        END IF;
      END IF;

      IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (api_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
      END IF;

      ------------------------------------------------------------------------
      -- Now that we have validated and data is clean we can fetch sequences and ids
      -- for new articles for DML and also set the process status to Success
      -------------------------------------------------------------------------
      IF p_validate_only = 'N' THEN
          l_context:='PREPARING DML FOR CLAUSE';

          IF inf_action_tbl(i) = 'N' THEN
          -- Generate article number based on autonumbering

              -- When article number is not given, then we get number from autonumber API
              IF nvl(inf_article_number_tbl(i),'-99') = '-99' THEN
                OKC_ARTICLES_GRP.GET_ARTICLE_SEQ_NUMBER
                    (p_article_number =>inf_article_number_tbl(i),
                     p_seq_type_info_only  => 'N',
                     p_org_id  => G_CURRENT_ORG_ID,
                     x_article_number => l_article_number,
                     x_doc_sequence_type => l_doc_sequence_type,
                     x_return_status   => api_return_status
                      ) ;

               IF api_return_status = G_RET_STS_SUCCESS Then
                 inf_article_number_tbl(i) := l_article_number;
               ELSIF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 l_return_status := api_return_status;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSE
                 l_return_status := api_return_status; -- whatever error, it will overwrite it
               END IF;
             END IF;

          -- Get article id.
              api_return_status := Get_Seq_Id (p_object_type => 'ART',
                                             x_object_id  =>  inf_article_id_tbl(i));
              IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (api_return_status = G_RET_STS_ERROR) THEN
                l_return_status := api_return_status;
                RAISE FND_API.G_EXC_ERROR ;
              END IF;

              api_return_status := Get_Seq_Id (p_object_type => 'VER',
                                             x_object_id  =>  inf_article_version_id_tbl(i));
              IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (api_return_status = G_RET_STS_ERROR) THEN
                l_return_status := api_return_status;
                RAISE FND_API.G_EXC_ERROR ;
              END IF;

          -- Create variable association for the new article - 1st version.
            IF l_variable_code_tbl.COUNT > 0 THEN
               FOR k in l_variable_code_tbl.FIRST ..l_variable_code_tbl.LAST LOOP
                  artv_variable_code_tbl(j) := l_variable_code_tbl(k);
                  artv_article_version_id_tbl(j) := inf_article_version_id_tbl(i);
                  artv_action_tbl(j) := 'N';
                  j := j+1;
               END LOOP;

            END IF;


            ELSIF inf_action_tbl(i) = 'V' THEN -- new version

              -- if status is APPROVED then save id of prev. version
              -- to set end date of previous version
              IF inf_article_status_tbl(i) = 'APPROVED' THEN
                  inf_earlier_version_id_tbl(i) := l_earlier_version_id;
              END IF;

            -- Get article version id.

            api_return_status := Get_Seq_Id (p_object_type => 'VER',
                                             x_object_id  =>  inf_article_version_id_tbl(i));
            IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (api_return_status = G_RET_STS_ERROR) THEN
                l_return_status := api_return_status;
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

          -- Create variable association for the new version.
            IF l_variable_code_tbl.COUNT > 0 THEN

               FOR k in l_variable_code_tbl.FIRST ..l_variable_code_tbl.LAST LOOP
                  artv_variable_code_tbl(j) := l_variable_code_tbl(k);
                  artv_article_version_id_tbl(j) := inf_article_version_id_tbl(i);
                  artv_action_tbl(j) := 'N';
                  j := j+1;
               END LOOP;
            END IF;

          -- Set adoption type with earlier adoption type
            inf_adoption_type_tbl(i) := l_earlier_adoption_type;


          ELSIF inf_action_tbl(i) = 'U' THEN

          -- Find out the variables that need to be added as these are new
          -- or those that need to be deleted as they are no longer used.

              OKC_ARTICLES_GRP.UPDATE_ARTICLE_VARIABLES (
                            p_article_version_id => inf_article_version_id_tbl(i),
                            p_variable_code_tbl => l_variable_code_tbl,
                            p_do_dml => 'N', -- indicates not to do dml in the API
                            x_variables_to_insert_tbl => l_variables_to_insert_tbl,
                            x_variables_to_delete_tbl => l_variables_to_delete_tbl,
                            x_return_status => api_return_status);
              IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (api_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
              END IF;

          -- New Variables
              IF l_variables_to_insert_tbl.COUNT > 0 THEN

                FOR k in l_variables_to_insert_tbl.FIRST ..l_variables_to_insert_tbl.LAST LOOP
                  artv_variable_code_tbl(j) := l_variables_to_insert_tbl(k);
                  artv_article_version_id_tbl(j) := inf_article_version_id_tbl(i);
                  artv_action_tbl(j) := 'N';
                  j := j+1;
                END LOOP;
              END IF;
          -- Variables no longer used.
              IF l_variables_to_delete_tbl.COUNT > 0 THEN
                 FOR k in l_variables_to_delete_tbl.FIRST ..l_variables_to_delete_tbl.LAST LOOP
                   artv_variable_code_tbl(j) := l_variables_to_delete_tbl(k);
                   artv_article_version_id_tbl(j) := inf_article_version_id_tbl(i);
                   artv_action_tbl(j) := 'D';
                   j := j+1;
                 END LOOP;
               END IF;

          END IF; -- end of IF inf_action_tbl(i) = 'N'

          --Delete variables cache tables for next interface row
          l_variables_to_insert_tbl.DELETE;
          l_variables_to_delete_tbl.DELETE;
          l_variable_code_tbl.DELETE;

      END IF; -- validate_only = 'N'

      -- Summarize report for this row
      -- Status 'F' is for internal use meaning parsing failure marked in
      -- java concurrent program
      IF (l_return_status = G_RET_STS_SUCCESS) THEN
         IF (nvl(inf_process_status_tbl(i), 'E') = 'E') THEN
           inf_process_status_tbl(i) := G_RET_STS_SUCCESS;
         ELSIF ( inf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           inf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = l_sts_warning) THEN
         IF (nvl(inf_process_status_tbl(i),'E') = 'E') THEN
           inf_process_status_tbl(i) := l_sts_warning;
           --##count
           --l_tot_rows_warned := l_tot_rows_warned+1;
           l_part_rows_warned := l_part_rows_warned+1;
         ELSIF (inf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           inf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop
    -- validation and unexpected errors
    -- In case of unexpected error, escape the loop
    -------------------------
    -------------------------

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('300: In Articles_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
              END IF;
              --l_return_status := G_RET_STS_ERROR ;
              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => inf_interface_id_tbl(i),
                 p_article_title => inf_article_title_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'CLAUSE'
                );
               inf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
               -- Continue to next row

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('400: Leaving Articles_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
              END IF;

              --
              -- Freeing temporary clobs
              --
              j := g_temp_clob_tbl.FIRST;
              LOOP
               DBMS_LOB.FREETEMPORARY(g_temp_clob_tbl(j));
               EXIT WHEN (j = g_temp_clob_tbl.LAST);
               j := g_temp_clob_tbl.NEXT(j);
              END LOOP;
              g_temp_clob_tbl.DELETE;
              --
              -- Freeing temporary clobs
              --

              IF l_interface_csr%ISOPEN THEN
                 CLOSE l_interface_csr;
              END IF;

              IF get_max_article_version_csr%ISOPEN THEN
                 CLOSE get_max_article_version_csr;
              END IF;

              IF get_article_info_csr%ISOPEN THEN
                 CLOSE get_article_info_csr;
              END IF;

              IF validate_article_type_csr%ISOPEN THEN
                 CLOSE validate_article_type_csr;
              END IF;
              --Set_Message
              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => inf_interface_id_tbl(i),
                 p_article_title => inf_article_title_tbl(i),
                 p_error_type    => G_RET_STS_UNEXP_ERROR,
			  p_entity        => 'CLAUSE'
                 );
               inf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit; -- exit the current fetch

          WHEN OTHERS THEN
              IF (l_debug = 'Y') THEN
                okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||sqlerrm, 2);
              END IF;


              --
              -- Freeing temporary clobs
              --
              j := g_temp_clob_tbl.FIRST;
              LOOP
               DBMS_LOB.FREETEMPORARY(g_temp_clob_tbl(j));
               EXIT WHEN (j = g_temp_clob_tbl.LAST);
               j := g_temp_clob_tbl.NEXT(j);
              END LOOP;
              g_temp_clob_tbl.DELETE;
              --
              -- Freeing temporary clobs
              --

              IF l_interface_csr%ISOPEN THEN
                 CLOSE l_interface_csr;
              END IF;

              IF get_max_article_version_csr%ISOPEN THEN
                 CLOSE get_max_article_version_csr;
              END IF;

              IF get_article_info_csr%ISOPEN THEN
                CLOSE get_article_info_csr;
              END IF;

              IF validate_article_type_csr%ISOPEN THEN
                 CLOSE validate_article_type_csr;
              END IF;
              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_UNEXPECTED_ERROR,
                                p_token1       => G_SQLCODE_TOKEN,
                                p_token1_value => sqlcode,
                                p_token2       => G_SQLERRM_TOKEN,
                                p_token2_value => sqlerrm);

              build_error_array(
                 p_msg_data     => G_UNEXPECTED_ERROR,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => inf_interface_id_tbl(i),
                 p_article_title => inf_article_title_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'CLAUSE'
                );
               inf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit;  -- exit the current fetch
          END;
    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop ends
    -------------------------
    -------------------------


     END LOOP; -- end of FOR i in inf_interface_id_tbl.FIRST ..
    ------------------------------------------------------------------------
    -------------- End of Inner Loop thru fetched row for---------------------
    -- validation, parse and validate article text, create a variable list
    -- prepare rows for DML if validate_only is 'N'
    -------------------------------------------------------------------------
    -- In order to propagate Unexpected error raise it if it is 'U'
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -------------------------
    -------------------------
    -- Exception Block for Inner Loop starts
    -- Handles unexpected errors as last step
    -------------------------
    -------------------------
    EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF (l_debug = 'Y') THEN
                okc_debug.log('400: Leaving Articles_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
             END IF;
             --
             -- Freeing temporary clobs
             --
             j := g_temp_clob_tbl.FIRST;
             LOOP
               DBMS_LOB.FREETEMPORARY(g_temp_clob_tbl(j));
                EXIT WHEN (j = g_temp_clob_tbl.LAST);
                j := g_temp_clob_tbl.NEXT(j);
             END LOOP;
             g_temp_clob_tbl.DELETE;
             --
             -- Freeing temporary clobs
             --

             IF l_interface_csr%ISOPEN THEN
                CLOSE l_interface_csr;
             END IF;
             IF get_max_article_version_csr%ISOPEN THEN
                CLOSE get_max_article_version_csr;
             END IF;
             IF get_article_info_csr%ISOPEN THEN
               CLOSE get_article_info_csr;
             END IF;
             IF validate_article_type_csr%ISOPEN THEN
                CLOSE validate_article_type_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop

        WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;

             --
             -- Freeing temporary clobs
             --
             j := g_temp_clob_tbl.FIRST;
             LOOP
              DBMS_LOB.FREETEMPORARY(g_temp_clob_tbl(j));
              EXIT WHEN (j = g_temp_clob_tbl.LAST);
              j := g_temp_clob_tbl.NEXT(j);
             END LOOP;
             g_temp_clob_tbl.DELETE;
             --
             -- Freeing temporary clobs
             --

             IF l_interface_csr%ISOPEN THEN
                CLOSE l_interface_csr;
             END IF;
             IF get_max_article_version_csr%ISOPEN THEN
                CLOSE get_max_article_version_csr;
             END IF;
             IF get_article_info_csr%ISOPEN THEN
               CLOSE get_article_info_csr;
             END IF;
             IF validate_article_type_csr%ISOPEN THEN
                CLOSE validate_article_type_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop
     END;

    -------------------------
    -------------------------
    -- Exception Block for Each Iteration of outermost Loop ends
    -------------------------
    -------------------------

    ------------------------------------------------------------------------
    --------------------- Start Do_DML for Article Library   ---------------
    -- Insert or Update Article, Article Version
    -- Insert variable association
    -------------------------------------------------------------------------
    -- initialize l_return_status to track status of DML execution
     l_return_status := G_RET_STS_SUCCESS;


    IF p_validate_only = 'N' THEN
         BEGIN
         SAVEPOINT bulkdml;

         i := 0;
        -- Bulk insert New Valid Records
         BEGIN
         l_context := 'INSERTING NEW CLAUSE';

           FORALL  i in inf_interface_id_tbl.FIRST ..inf_interface_id_tbl.LAST
            INSERT INTO OKC_ARTICLES_ALL(
             ARTICLE_ID,
             ARTICLE_TITLE,
             ORG_ID,
             ARTICLE_NUMBER,
             STANDARD_YN,
             ARTICLE_INTENT,
             ARTICLE_LANGUAGE,
             ARTICLE_TYPE,
             ORIG_SYSTEM_REFERENCE_CODE,
             ORIG_SYSTEM_REFERENCE_ID1,
             ORIG_SYSTEM_REFERENCE_ID2,
             CZ_TRANSFER_STATUS_FLAG,
             PROGRAM_ID,
             PROGRAM_LOGIN_ID,
             PROGRAM_APPLICATION_ID,
             REQUEST_ID,
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE)
           SELECT
             inf_article_id_tbl(i),
             inf_article_title_tbl(i),
             G_CURRENT_ORG_ID,
             inf_article_number_tbl(i),
             'Y',
             inf_article_intent_tbl(i),
             nvl(inf_article_language_tbl(i),l_userenv_lang),
             inf_article_type_tbl(i),
             inf_art_reference_code_tbl(i),
             inf_art_reference_id1_tbl(i),
             inf_art_reference_id2_tbl(i),
             'N',
             l_program_id,
             l_program_login_id,
             l_program_appl_id,
             l_request_id,
             1.0,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate
           FROM DUAL
           WHERE inf_action_tbl(i)  = 'N' and
                 inf_process_status_tbl(i)  in ('S', 'W')  ;

        -- Using a " select from dual" aproach as above prevents creation of
        -- additional PL/SQL tables for bulk insert of
        -- articles if we were to use a FORALL INSERT INTO .... VALUES .... approach.
        -- We cannot use FORALL INSERT INTO .... VALUES ....using
        -- the existing inf*tbl since the error rows need to be
        -- filtered out.

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

         --
         --  End of Insert into OKC_ARTICLES_ALL
         --
         --

         i := 0;
         BEGIN
         l_context := 'INSERTING NEW VERSION OF CLAUSE';

         FORALL  i in inf_interface_id_tbl.FIRST ..inf_interface_id_tbl.LAST
           INSERT INTO OKC_ARTICLE_VERSIONS(
             ARTICLE_VERSION_ID,
              ARTICLE_ID,
              ARTICLE_VERSION_NUMBER,
              ARTICLE_TEXT,
              PROVISION_YN,
              INSERT_BY_REFERENCE,
              LOCK_TEXT,
              GLOBAL_YN,
              ARTICLE_LANGUAGE,
              ARTICLE_STATUS,
              SAV_RELEASE,
              START_DATE,
              END_DATE,
              STD_ARTICLE_VERSION_ID,
              DISPLAY_NAME,
              TRANSLATED_YN,
              ARTICLE_DESCRIPTION,
              DATE_APPROVED,
              DEFAULT_SECTION,
              REFERENCE_SOURCE,
              REFERENCE_TEXT,
              ORIG_SYSTEM_REFERENCE_CODE,
              ORIG_SYSTEM_REFERENCE_ID1,
              ORIG_SYSTEM_REFERENCE_ID2,
              ADDITIONAL_INSTRUCTIONS,
              VARIATION_DESCRIPTION,
		    DATE_PUBLISHED,
              ADOPTION_TYPE,
              PROGRAM_ID,
              PROGRAM_LOGIN_ID,
              PROGRAM_APPLICATION_ID,
              REQUEST_ID,
              ATTRIBUTE_CATEGORY,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15,
 --Clause Editing
              EDITED_IN_WORD,
              ARTICLE_TEXT_IN_WORD,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE)
           SELECT
              inf_article_version_id_tbl(i),
              inf_article_id_tbl(i),
              inf_article_version_number_tbl(i),
              g_temp_clob_tbl(i),
              inf_provision_yn_tbl(i),
              inf_insert_by_reference_tbl(i),
              inf_lock_text_tbl(i),
              inf_global_yn_tbl(i),
              nvl(inf_article_language_tbl(i),l_userenv_lang),
              inf_article_status_tbl(i),
              NULL,
              trunc(inf_start_date_tbl(i)),
              trunc(inf_end_date_tbl(i)),
              NULL,
              inf_display_name_tbl(i),
              NULL,
              inf_article_description_tbl(i),
              inf_date_approved_tbl(i),
              inf_default_section_tbl(i),
              inf_reference_source_tbl(i),
              inf_reference_text_tbl(i),
              inf_ver_reference_code_tbl(i),
              inf_ver_reference_id1_tbl(i),
              inf_ver_reference_id2_tbl(i),
              inf_instructions_tbl(i),
              NULL,
              inf_date_published_tbl(i),
              inf_adoption_type_tbl(i),
              l_program_id,
              l_program_login_id,
              l_program_appl_id,
              l_request_id,
              inf_attribute_category_tbl(i),
              inf_attribute1_tbl(i),
              inf_attribute2_tbl(i),
              inf_attribute3_tbl(i),
              inf_attribute4_tbl(i),
              inf_attribute5_tbl(i),
              inf_attribute6_tbl(i),
              inf_attribute7_tbl(i),
              inf_attribute8_tbl(i),
              inf_attribute9_tbl(i),
              inf_attribute10_tbl(i),
              inf_attribute11_tbl(i),
              inf_attribute12_tbl(i),
              inf_attribute13_tbl(i),
              inf_attribute14_tbl(i),
              inf_attribute15_tbl(i),
 --Clause Editing
              inf_edited_in_word_tbl(i),
              inf_article_text_in_word_tbl(i),
              1.0,
              l_user_id,
              sysdate,
              l_user_id,
              l_login_id,
              sysdate
           FROM OKC_ARTICLES_ALL
           WHERE inf_action_tbl(i)  IN ( 'N', 'V')
             AND inf_process_status_tbl(i) in ('S', 'W')
             AND article_id = inf_article_id_tbl(i);

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Article Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

          --
          -- End of Insert into OKC_ARTICLE_VERSIONS
          --
          --

          i := 0;
          BEGIN
             IF artv_variable_code_tbl.COUNT > 0 Then
                l_context := 'INSERT ASSOCIATION FOR VARIABLES';

                i := 0;

                FORALL i in artv_variable_code_tbl.FIRST .. artv_variable_code_tbl.LAST
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
                   artv_article_version_id_tbl(i),
                   artv_variable_code_tbl(i),
                   1.0,
                   l_user_id,
                   sysdate,
                   sysdate,
                   l_user_id,
                   l_login_id
                 FROM OKC_ARTICLE_VERSIONS
                 WHERE artv_action_tbl(i) = 'N'
                   AND article_version_id = artv_article_version_id_tbl(i);

              END IF;

              IF artv_variable_code_tbl.COUNT > 0 Then
                l_context := 'DELETE ASSOCIATION FOR VARIABLES';
                FORALL i in artv_variable_code_tbl.FIRST .. artv_variable_code_tbl.LAST
                  DELETE FROM OKC_ARTICLE_VARIABLES
                   WHERE VARIABLE_CODE = artv_variable_code_tbl(i)
                   AND ARTICLE_VERSION_ID = artv_article_version_id_tbl(i)
                   AND artv_action_tbl(i) = 'D';
              END IF;
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Article Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

         artv_article_version_id_tbl.DELETE;
         artv_variable_code_tbl.DELETE;
         artv_action_tbl.DELETE;

         --
         -- End of OKC_ARTICLES_VARIABLES
         --
         --

         i := 0;
         BEGIN
           l_context := 'SET END DATE IN PREV. VER';

         FORALL  i in inf_interface_id_tbl.FIRST ..inf_interface_id_tbl.LAST
           UPDATE OKC_ARTICLE_VERSIONS
            SET END_DATE              = trunc(inf_start_date_tbl(i)-1),
              PROGRAM_ID                 = l_program_id,
              REQUEST_ID                 = l_request_id,
              PROGRAM_LOGIN_ID           = l_program_login_id,
              PROGRAM_APPLICATION_ID     = l_program_appl_id,
              OBJECT_VERSION_NUMBER      = object_version_number + 1,
              LAST_UPDATED_BY            = l_user_id,
              LAST_UPDATE_LOGIN          = l_login_id,
              LAST_UPDATE_DATE           = SYSDATE
           WHERE inf_action_tbl(i)  = 'V'
             AND inf_process_status_tbl(i) in ('S','W')
             AND inf_earlier_version_id_tbl(i) <> -99
             AND article_version_id = inf_earlier_version_id_tbl(i);
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;
          --
          -- End of Insert into OKC_ARTICLE_VERSIONS
          --
          --

         i := 0;
         BEGIN
           l_context := 'UPDATING CLAUSE TYPE FOR ACTION V AND U';

         FORALL  i in inf_interface_id_tbl.FIRST ..inf_interface_id_tbl.LAST
           UPDATE OKC_ARTICLES_ALL
           SET ARTICLE_TYPE               = inf_article_type_tbl(i),
               PROGRAM_ID                 = l_program_id,
               REQUEST_ID                 = l_request_id,
               PROGRAM_LOGIN_ID           = l_program_login_id,
               PROGRAM_APPLICATION_ID     = l_program_appl_id,
               OBJECT_VERSION_NUMBER      = object_version_number + 1,
               LAST_UPDATED_BY            = l_user_id,
               LAST_UPDATE_LOGIN          = l_login_id,
               LAST_UPDATE_DATE           = SYSDATE
           WHERE inf_action_tbl(i)  in ('U', 'V')
             AND inf_process_status_tbl(i) in ('S','W')
             AND article_id = inf_article_id_tbl(i);
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;
         ---
	    ---
	    ---
         i := 0;
         BEGIN
           l_context := 'UPDATING CLAUSE END DATE FOR ACTION D ';

         FORALL  i in inf_interface_id_tbl.FIRST ..inf_interface_id_tbl.LAST
           UPDATE OKC_ARTICLE_VERSIONS
           SET END_DATE                   = trunc(inf_end_date_tbl(i)),
               PROGRAM_ID                 = l_program_id,
               REQUEST_ID                 = l_request_id,
               PROGRAM_LOGIN_ID           = l_program_login_id,
               PROGRAM_APPLICATION_ID     = l_program_appl_id,
               OBJECT_VERSION_NUMBER      = object_version_number + 1,
               LAST_UPDATED_BY            = l_user_id,
               LAST_UPDATE_LOGIN          = l_login_id,
               LAST_UPDATE_DATE           = SYSDATE
           WHERE inf_action_tbl(i)  in ('D')
             AND inf_process_status_tbl(i) in ('S','W')
             AND article_version_id = inf_article_version_id_tbl(i);
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

         ---
	    ---
	    ---
          i := 0;
          BEGIN
           l_context := 'UPDATING CLAUSE VERSION';

           FORALL  i in inf_interface_id_tbl.FIRST ..inf_interface_id_tbl.LAST
             UPDATE OKC_ARTICLE_VERSIONS VO SET (
                ARTICLE_TEXT,
                PROVISION_YN,
                INSERT_BY_REFERENCE,
                LOCK_TEXT,
                GLOBAL_YN,
                ARTICLE_STATUS,
                START_DATE,
                END_DATE,
                DISPLAY_NAME,
                ARTICLE_DESCRIPTION,
                DEFAULT_SECTION,
                REFERENCE_SOURCE,
                REFERENCE_TEXT,
                ORIG_SYSTEM_REFERENCE_CODE,
                ORIG_SYSTEM_REFERENCE_ID1,
                ORIG_SYSTEM_REFERENCE_ID2,
                ADDITIONAL_INSTRUCTIONS,
			 DATE_PUBLISHED,
                PROGRAM_ID,
                PROGRAM_LOGIN_ID,
                PROGRAM_APPLICATION_ID,
                REQUEST_ID,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
 --Clause Editing
                EDITED_IN_WORD,
                ARTICLE_TEXT_IN_WORD,
                OBJECT_VERSION_NUMBER,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE) = (
             SELECT
                g_temp_clob_tbl(i),
                inf_provision_yn_tbl(i),
                inf_insert_by_reference_tbl(i),
                inf_lock_text_tbl(i),
                inf_global_yn_tbl(i),
                inf_article_status_tbl(i),
                trunc(inf_start_date_tbl(i)),
                trunc(inf_end_date_tbl(i)),
                inf_display_name_tbl(i),
                inf_article_description_tbl(i),
                inf_default_section_tbl(i),
                inf_reference_source_tbl(i),
                inf_reference_text_tbl(i),
                inf_ver_reference_code_tbl(i),
                inf_ver_reference_id1_tbl(i),
                inf_ver_reference_id2_tbl(i),
                inf_instructions_tbl(i),
                inf_date_published_tbl(i),
                l_program_id,
                l_program_login_id,
                l_program_appl_id,
                l_request_id,
                inf_attribute_category_tbl(i),
                inf_attribute1_tbl(i),
                inf_attribute2_tbl(i),
                inf_attribute3_tbl(i),
                inf_attribute4_tbl(i),
                inf_attribute5_tbl(i),
                inf_attribute6_tbl(i),
                inf_attribute7_tbl(i),
                inf_attribute8_tbl(i),
                inf_attribute9_tbl(i),
                inf_attribute10_tbl(i),
                inf_attribute11_tbl(i),
                inf_attribute12_tbl(i),
                inf_attribute13_tbl(i),
                inf_attribute14_tbl(i),
                inf_attribute15_tbl(i),
 --Clause Editing
                inf_edited_in_word_tbl(i),
                inf_article_text_in_word_tbl(i),
                vi.object_version_number+1,
                l_user_id,
                l_login_id,
                sysdate
             FROM OKC_ART_INTERFACE_ALL VI
             WHERE inf_action_tbl(i)  = 'U'
             AND nvl(process_status, 'E') in ('E')
             AND inf_process_status_tbl(i) in ('S', 'W')
             AND VI.interface_id = inf_interface_id_tbl(i))
          WHERE  vo.article_version_id = inf_article_version_id_tbl(i)
            AND  inf_process_status_tbl(i) in ('S','W')
            AND  inf_action_tbl(i) = 'U';

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END;
          --
          -- End of Update OKC_ARTICLE_VERSIONS
          --
          --



          --
          -- Start Auto Adoption
          --
          --
          -- Auto adopt all approved global articles in New/New Version case.

          IF G_CURRENT_ORG_ID = G_GLOBAL_ORG_ID THEN
            BEGIN
              i := 0;
              l_context := 'AUTO ADOPTION';
              For i IN inf_interface_id_tbl.FIRST ..inf_interface_id_tbl.LAST LOOP
                IF   nvl(inf_process_status_tbl(i),'E') <> 'E'
                 and nvl(inf_article_status_tbl(i), '*') = 'APPROVED'
                 and inf_global_yn_tbl(i) = 'Y' THEN
                     OKC_ADOPTIONS_GRP.AUTO_ADOPT_ARTICLES
                     (
                        p_api_version                  => l_api_version ,
                        p_init_msg_list                => l_init_msg_list ,
                        x_return_status                => api_return_status ,
                        x_msg_count                    => x_msg_count,
                        x_msg_data                     => x_msg_data,
                        p_relationship_yn              => 'N',
                        p_adoption_yn                  => 'Y',
                        p_fetchsize                    => 100,
                        p_global_article_id            => inf_article_id_tbl(i),
                        p_global_article_version_id    => inf_article_version_id_tbl(i)
                     );

                    IF (api_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      -- in order to mark interface_id, we build error_array in the loop
                      build_error_array(
                        p_msg_data     => x_msg_data,
                        p_context      => l_context,
                        p_batch_process_id => l_batch_process_id,
                        p_interface_id  => inf_interface_id_tbl(i),
                        p_article_title => inf_article_title_tbl(i),
                        p_error_type    => G_RET_STS_ERROR,
				    p_entity        => 'CLAUSE'
                      );
                      inf_process_status_tbl(i):= G_RET_STS_ERROR;
                      -- Unexpected Error occurred rollback
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                    ELSIF (api_return_status = G_RET_STS_ERROR) THEN
                      -- Set return status as 'E' and move on to next record
                      -- l_return_status := G_RET_STS_ERROR;
                      build_error_array(
                        p_msg_data     => x_msg_data,
                        p_context      => l_context,
                        p_batch_process_id => l_batch_process_id,
                        p_interface_id  => inf_interface_id_tbl(i),
                        p_article_title => inf_article_title_tbl(i),
                        p_error_type    => G_RET_STS_ERROR,
				    p_entity        => 'CLAUSE'
                      );
                      inf_process_status_tbl(i):= G_RET_STS_ERROR;
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;
              END LOOP;


          EXCEPTION
             WHEN OTHERS THEN
               IF (l_debug = 'Y') THEN
                 okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END;
       END IF;  ---- If CURRENT_ORG_ID = GLOBAL_ORG_ID

      --
      -- End of Auto Adoption
      --
      --

      -- Exception for bulk DML block
      EXCEPTION
        WHEN OTHERS THEN
             l_bulk_failed := 'Y'; -- indicating that bulk operation has failed
              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_UNEXPECTED_ERROR,
                                  p_token1       => G_SQLCODE_TOKEN,
                                  p_token1_value => sqlcode,
                                  p_token2       => G_SQLERRM_TOKEN,
                                  p_token2_value => sqlerrm);
              Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKC_ART_FETCH_FAILED',
                                  p_token1       => 'CONTEXT',
                                  p_token1_value => l_context);

              build_error_array(
                                 p_msg_data     => null,
                                 p_context      => l_context,
                                 p_batch_process_id => l_batch_process_id,
                                 p_interface_id  => -99,
                                 p_article_title => NULL,
                                 p_error_type    => G_RET_STS_ERROR,
						   p_entity        => 'CLAUSE'
              );
              l_return_status := G_RET_STS_UNEXP_ERROR;
              x_return_status := G_RET_STS_UNEXP_ERROR;

              --##count:rollback the count
              l_part_rows_failed := l_part_rows_processed;
              l_part_rows_warned := 0;

              ROLLBACK TO SAVEPOINT bulkdml;
              exit; -- exit outermost loop
      END;

    END IF; --- validate_only = 'N'

    ------------------------------------------------------------------------
    --------------------- End of Do_DML for Article Library   ---------------
    -------------------------------------------------------------------------

    ------------------------------------------------------------------------
    --------------- Start of Do_DML for import related tables   ------------
    -- Update interface table
    -- Insert Errors into Error table
    -------------------------------------------------------------------------
    -- Update Interface Table
    i:=0;
    BEGIN
     l_context := 'UPDATING CLAUSE INTERFACE TABLE';
     FORALL i in inf_interface_id_tbl.FIRST..inf_interface_id_tbl.LAST
       UPDATE OKC_ART_INTERFACE_ALL
       SET
           -- We don't want to update process_status to 'S' or 'W' in validation_mode
           -- because it is not going to be picked up in next run if we do so
           PROCESS_STATUS = decode(p_validate_only||inf_process_status_tbl(i)||l_bulk_failed,
                                               'NEN','E',
                                               'NSN','S',
                                               'NWN','W',
                                               'NEY','E',
                                               'NSY',NULL,
                                               'NWY',NULL,
                                               'YEY','E',
                                               'YEN','E',
                                               'NFY','E',
                                               'YFY','E',
                                               'NFN','E',
                                               'YFN','E',NULL),
           ARTICLE_VERSION_NUMBER     = inf_article_version_number_tbl(i),
           PROGRAM_ID                 = l_program_id,
           REQUEST_ID                 = l_request_id,
           PROGRAM_LOGIN_ID           = l_program_login_id,
           PROGRAM_APPLICATION_ID     = l_program_appl_id,
           OBJECT_VERSION_NUMBER      = inf_object_version_number_tbl(i) + 1,
           LAST_UPDATED_BY            = l_user_id,
           LAST_UPDATE_LOGIN          = l_login_id,
           LAST_UPDATE_DATE           = SYSDATE
         WHERE
           interface_id = inf_interface_id_tbl(i);
    EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Article_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;
             Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
             Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_INT_UPDATE_FAILED');
             build_error_array(
                       p_msg_data     => null,
                       p_context      => l_context,
                       p_batch_process_id => l_batch_process_id,
                       p_interface_id  => -99,
                       p_article_title => NULL,
                       p_error_type    => G_RET_STS_ERROR,
				   p_entity        => 'CLAUSE'
             );
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             --##count:rollback the count
             l_part_rows_failed := l_part_rows_processed;
             l_part_rows_warned := 0;

             --RAISE FND_API.G_EXC_ERROR ;
    END;
    --
    -- End of Update OKC_ART_INTERFACE_ALL
    --
    --
    --Insert Errors into Error table for this fetch
    insert_error_array(
     x_return_status => api_return_status,
     x_msg_count     => x_msg_count,
     x_msg_data      => x_msg_data
    );


    IF (api_return_status = l_insert_errors_error) THEN
      NULL;
     -- Ignore
     -- RAISE l_insert_errors_exception;
    END IF;
    ------------------------------------------------------------------------
    --------------- End of Do_DML for import related tables   ------------
    -------------------------------------------------------------------------
    commit;
    -- Now delete cache for next bulk fetch


    inf_interface_id_tbl.DELETE;
    inf_batch_number_tbl.DELETE;
    inf_object_version_number_tbl.DELETE;
    inf_article_title_tbl.DELETE;
    inf_org_id_tbl.DELETE;
    inf_process_status_tbl.DELETE;
    inf_action_tbl.DELETE;
    inf_article_number_tbl.DELETE;
    inf_article_intent_tbl.DELETE;
    inf_article_language_tbl.DELETE;
    inf_article_type_tbl.DELETE;
    inf_article_id_tbl.DELETE;
    inf_art_reference_code_tbl.DELETE;
    inf_art_reference_id1_tbl.DELETE;
    inf_art_reference_id2_tbl.DELETE;
    inf_article_version_number_tbl.DELETE;
    inf_article_text_tbl.DELETE;
    inf_provision_yn_tbl.DELETE;
    inf_insert_by_reference_tbl.DELETE;
    inf_lock_text_tbl.DELETE;
    inf_global_yn_tbl.DELETE;
    inf_article_status_tbl.DELETE;
    inf_start_date_tbl.DELETE;
    inf_end_date_tbl.DELETE;
    inf_display_name_tbl.DELETE;
    --inf_translated_yn_tbl.DELETE;
    inf_article_description_tbl.DELETE;
    inf_date_approved_tbl.DELETE;
    inf_default_section_tbl.DELETE;
    inf_reference_source_tbl.DELETE;
    inf_reference_text_tbl.DELETE;
    inf_ver_reference_code_tbl.DELETE;
    inf_ver_reference_id1_tbl.DELETE;
    inf_ver_reference_id2_tbl.DELETE;
    inf_instructions_tbl.DELETE;
    inf_date_published_tbl.DELETE;
    inf_attribute_category_tbl.DELETE;
    inf_attribute1_tbl.DELETE;
    inf_attribute2_tbl.DELETE;
    inf_attribute3_tbl.DELETE;
    inf_attribute4_tbl.DELETE;
    inf_attribute5_tbl.DELETE;
    inf_attribute6_tbl.DELETE;
    inf_attribute7_tbl.DELETE;
    inf_attribute8_tbl.DELETE;
    inf_attribute9_tbl.DELETE;
    inf_attribute10_tbl.DELETE;
    inf_attribute11_tbl.DELETE;
    inf_attribute12_tbl.DELETE;
    inf_attribute13_tbl.DELETE;
    inf_attribute14_tbl.DELETE;
    inf_attribute15_tbl.DELETE;
 --Clause Editing
    inf_edited_in_word_tbl.DELETE;
    inf_article_text_in_word_tbl.DELETE;
    inf_article_version_id_tbl.DELETE;
    inf_earlier_version_id_tbl.DELETE;
    inf_adoption_type_tbl.DELETE;
    err_batch_process_id_tbl.DELETE;
    err_article_title_tbl.DELETE;
    err_interface_id_tbl.DELETE;
    err_error_number_tbl.DELETE;
    err_object_version_number_tbl.DELETE;
    err_error_type_tbl.DELETE;
    err_entity_tbl.DELETE;
    err_error_description_tbl.DELETE;

   EXIT WHEN l_interface_csr%NOTFOUND;
END LOOP;


-----------------------------------------------------------------------
-- End of outermost loop for bulk fetch
-----------------------------------------------------------------------

IF l_interface_csr%ISOPEN THEN
CLOSE l_interface_csr;
END IF;

--
-- Freeing temporary clobs
--
--

j := g_temp_clob_tbl.FIRST;
LOOP
 DBMS_LOB.FREETEMPORARY(g_temp_clob_tbl(j));
EXIT WHEN (j = g_temp_clob_tbl.LAST);
j := g_temp_clob_tbl.NEXT(j);
END LOOP;
g_temp_clob_tbl.DELETE;

--
-- Freeing temporary clobs
--
--

--##count:add up last processed counts
l_tot_rows_processed := l_tot_rows_processed + l_part_rows_processed;
l_tot_rows_failed := l_tot_rows_failed + l_part_rows_failed;
l_tot_rows_warned := l_tot_rows_warned + l_part_rows_warned;

BEGIN
--If there are successful records and validate mode is off

IF     p_validate_only = 'N'
   AND (l_tot_rows_processed - l_tot_rows_failed) > 0 THEN
   okc_artwf_pvt.start_wf_after_import( p_req_id => l_request_id,
                                        p_batch_number => p_batch_number,
                                        p_org_id => G_CURRENT_ORG_ID);
END IF;

EXCEPTION

WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Articles_Import because of EXCEPTION in workflow: '||sqlerrm, 2);
      END IF;
      Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKC_ART_IMP_WF_FAILED');

      build_error_array(
                       p_msg_data     => null,
                       p_context      => l_context,
                       p_batch_process_id => l_batch_process_id,
                       p_interface_id  => -99,
                       p_article_title => NULL,
                       p_error_type    => G_RET_STS_ERROR,
				   p_entity        => 'CLAUSE'
      );

      l_return_status := G_RET_STS_UNEXP_ERROR ;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_ERROR ;
END;
/*********
--Update Batch Process Table as a last step
UPDATE OKC_ART_INT_BATPROCS_ALL
SET
  TOTAL_ROWS_PROCESSED       = l_tot_rows_processed,
  TOTAL_ROWS_FAILED          = l_tot_rows_failed,
  TOTAL_ROWS_WARNED          = l_tot_rows_warned,
  END_DATE                   = SYSDATE,
  PROGRAM_ID                 = l_program_id,
  REQUEST_ID                 = l_request_id,
  PROGRAM_LOGIN_ID           = l_program_login_id,
  PROGRAM_APPLICATION_ID     = l_program_appl_id,
  OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
  LAST_UPDATED_BY            = l_user_id,
  LAST_UPDATE_LOGIN          = l_login_id,
  LAST_UPDATE_DATE           = SYSDATE
WHERE
  BATCH_PROCESS_ID  = l_batch_process_id
  AND ENTITY = 'Clause';
*****************/
p_rows_processed := l_tot_rows_processed;
p_rows_failed := l_tot_rows_failed;
p_rows_warned := l_tot_rows_warned;
IF err_error_number_tbl.COUNT > 0 THEN
 insert_error_array(
   x_return_status => api_return_status,
   x_msg_count     => x_msg_count,
   x_msg_data      => x_msg_data
 );
END IF;

-- Print statistic of this run in the log
-- Commented for new XML Based Import - Moved to new_wrap_up in conc_import_articles
--wrap_up(p_validate_only,p_batch_number,l_tot_rows_processed,l_tot_rows_failed,l_tot_rows_warned,l_batch_process_id,'CLAUSE');
commit; -- Final commit for status update

IF (l_debug = 'Y') THEN
 okc_debug.log('200: Leaving articles import', 2);
END IF;
--x_return_status := l_return_status; this may cause to erase error x_return_status

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Articles_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;
      x_return_status := G_RET_STS_ERROR ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Articles_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      --Insert Errors into Error table if there is any

      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;
      --
      -- Freeing temporary clobs
      --
      --

      IF g_temp_clob_tbl.COUNT > 0 THEN
        j := g_temp_clob_tbl.FIRST;
        LOOP
         DBMS_LOB.FREETEMPORARY(g_temp_clob_tbl(j));
        EXIT WHEN (j = g_temp_clob_tbl.LAST);
        j := g_temp_clob_tbl.NEXT(j);
        END LOOP;
        g_temp_clob_tbl.DELETE;
      END IF;
      --
      -- Freeing temporary clobs
      --
      --

      IF l_interface_csr%ISOPEN THEN
         CLOSE l_interface_csr;
      END IF;
      IF get_max_article_version_csr%ISOPEN THEN
         CLOSE get_max_article_version_csr;
      END IF;
      IF get_article_info_csr%ISOPEN THEN
         CLOSE get_article_info_csr;
      END IF;
      IF validate_article_type_csr%ISOPEN THEN
         CLOSE validate_article_type_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);

  WHEN l_insert_errors_exception THEN
      --
      -- In this exception handling, we don't insert error array again
      -- because error happend in the module
      --
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Articles_Import because of EXCEPTION in insert_error_array: '||sqlerrm, 2);
      END IF;
      --
      -- Freeing temporary clobs
      --
      --

      IF g_temp_clob_tbl.COUNT > 0 THEN
        j := g_temp_clob_tbl.FIRST;
        LOOP
         DBMS_LOB.FREETEMPORARY(g_temp_clob_tbl(j));
        EXIT WHEN (j = g_temp_clob_tbl.LAST);
        j := g_temp_clob_tbl.NEXT(j);
        END LOOP;
        g_temp_clob_tbl.DELETE;
      END IF;

      --
      -- Freeing temporary clobs
      --
      --

      IF l_interface_csr%ISOPEN THEN
         CLOSE l_interface_csr;
      END IF;

      IF get_max_article_version_csr%ISOPEN THEN
         CLOSE get_max_article_version_csr;
      END IF;

      IF get_article_info_csr%ISOPEN THEN
         CLOSE get_article_info_csr;
      END IF;

      IF validate_article_type_csr%ISOPEN THEN
         CLOSE validate_article_type_csr;
      END IF;


      --x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      get_print_msgs_stack(p_msg_data => x_msg_data);
      commit;

  WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Articles_Import because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;
      --
      -- Freeing temporary clobs
      --
      --
      IF g_temp_clob_tbl.COUNT > 0 THEN
        j := g_temp_clob_tbl.FIRST;
        LOOP
         DBMS_LOB.FREETEMPORARY(g_temp_clob_tbl(j));
        EXIT WHEN (j = g_temp_clob_tbl.LAST);
        j := g_temp_clob_tbl.NEXT(j);
        END LOOP;
        g_temp_clob_tbl.DELETE;
      END IF;
      --
      -- Freeing temporary clobs
      --
      --

      IF l_interface_csr%ISOPEN THEN
         CLOSE l_interface_csr;
      END IF;
      IF get_max_article_version_csr%ISOPEN THEN
         CLOSE get_max_article_version_csr;
      END IF;
      IF get_article_info_csr%ISOPEN THEN
         CLOSE get_article_info_csr;
      END IF;
      IF validate_article_type_csr%ISOPEN THEN
         CLOSE validate_article_type_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);

END import_articles;

PROCEDURE import_variables(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100
   ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'import_variables';
    l_sts_warning                 CONSTANT VARCHAR2(1) := 'W';
    l_row_notfound                BOOLEAN := FALSE;
    l_user_id                     NUMBER;
    l_login_id                    NUMBER;
    l_insert_errors_exception     EXCEPTION;
    l_insert_errors_error         CONSTANT VARCHAR2(1) := 'X';

    CURSOR l_var_interface_csr ( cp_batch_number IN VARCHAR2) IS
      SELECT
           VARINT.INTERFACE_ID     ,
           VARINT.BATCH_NUMBER             ,
           VARINT.OBJECT_VERSION_NUMBER  ,
           RTRIM(VARINT.VARIABLE_CODE) VARIABLE_CODE    ,
           VARINT.VARIABLE_NAME    ,
           VARINT.PROCESS_STATUS           ,
           VARINT.ACTION                  ,
           VARINT.LANGUAGE  ,
		 VARINT.DESCRIPTION,
		 VARINT.VARIABLE_TYPE,
		 VARINT.VARIABLE_INTENT,
		 VARINT.CONTRACT_EXPERT_YN,
		 VARINT.XPRT_VALUE_SET_NAME,
		 VARINT.DISABLED_YN,
		 VARINT.EXTERNAL_YN,
		 VARINT.VARIABLE_DATATYPE,
		 VARINT.APPLICATION_ID,
		 VARINT.VALUE_SET_NAME,
		 VARINT.VARIABLE_DEFAULT_VALUE,
		 VARINT.ORIG_SYSTEM_REFERENCE_CODE,
		 VARINT.ORIG_SYSTEM_REFERENCE_ID1,
		 VARINT.ORIG_SYSTEM_REFERENCE_ID2,
		 VARINT.DATE_PUBLISHED,
           VARINT.ATTRIBUTE_CATEGORY,
           VARINT.ATTRIBUTE1  ,
           VARINT.ATTRIBUTE2  ,
           VARINT.ATTRIBUTE3  ,
           VARINT.ATTRIBUTE4  ,
           VARINT.ATTRIBUTE5  ,
           VARINT.ATTRIBUTE6  ,
           VARINT.ATTRIBUTE7  ,
           VARINT.ATTRIBUTE8  ,
           VARINT.ATTRIBUTE9  ,
           VARINT.ATTRIBUTE10 ,
           VARINT.ATTRIBUTE11 ,
           VARINT.ATTRIBUTE12 ,
           VARINT.ATTRIBUTE13 ,
           VARINT.ATTRIBUTE14 ,
           VARINT.ATTRIBUTE15 ,
		 VAR.VARIABLE_CODE EXISTING_CODE,
		 VAR.DATE_PUBLISHED EXISTING_DPUBLISHED,
		 VARTL.LANGUAGE EXISTING_LANGUAGE
      FROM OKC_VARIABLES_INTERFACE VARINT, OKC_BUS_VARIABLES_B VAR,
	      OKC_BUS_VARIABLES_TL VARTL
      WHERE nvl(PROCESS_STATUS,'*') NOT IN ('W', 'S')
         AND BATCH_NUMBER = cp_batch_number
         AND RTRIM(VARINT.VARIABLE_CODE) = VAR.VARIABLE_CODE(+)
         AND RTRIM(VARINT.VARIABLE_CODE) = VARTL.VARIABLE_CODE(+)
         AND VARINT.LANGUAGE = VARTL.LANGUAGE(+)
      ORDER BY RTRIM(VARINT.VARIABLE_CODE) ASC;

-- Cursor to check that variable code is unique in the system

      CURSOR l_code_exist_csr (cp_var_code IN VARCHAR2) IS
	 SELECT '1' FROM OKC_BUS_VARIABLES_B
	 WHERE variable_code = cp_var_code;

-- Cursor to check that variable name and intent is unique in the system

    CURSOR get_var_unq_csr    (cp_var_name IN VARCHAR2,
                                cp_var_intent IN VARCHAR2) IS
     SELECT
           '1'
     FROM OKC_BUS_VARIABLES_B B,OKC_BUS_VARIABLES_TL TL
     WHERE B.VARIABLE_CODE = TL.VARIABLE_CODE AND
	      B.VARIABLE_INTENT = cp_var_intent AND
		 TL.VARIABLE_NAME = cp_var_name;

-- Cursor to check that variable code is not duplicate in the system

    CURSOR get_var_info_csr    (cp_var_code IN VARCHAR2 ) IS
    SELECT
           '1'
     FROM OKC_BUS_VARIABLES_B B,OKC_BUS_VARIABLES_TL TL
     WHERE B.VARIABLE_CODE = TL.VARIABLE_CODE AND
	      B.VARIABLE_CODE = cp_var_code;

-- Cursor to derive value set id from value set name

    CURSOR get_valset_id_csr    (cp_valset_name IN VARCHAR2 ) IS
    SELECT
           FLX.FLEX_VALUE_SET_ID ,
		 DECODE(FORMAT_TYPE,'C','V','X','D',FORMAT_TYPE) FORMAT_TYPE
     FROM  FND_FLEX_VALUE_SETS FLX
     WHERE FLX.FLEX_VALUE_SET_NAME = cp_valset_name;


-- Cursor to check valueset exists in the valueset interface Table
    CURSOR valset_exists_csr (cp_valset_name IN VARCHAR2,
                              cp_batch_number IN VARCHAR2) IS
    SELECT '1'
    FROM OKC_VALUESETS_INTERFACE
    WHERE flex_value_set_name = cp_valset_name
    AND   batch_number = cp_batch_number
    AND   nvl(process_status,'X') not in ('E');

-- Cursor to verify language is installed
    CURSOR check_lang_csr(lang_code IN VARCHAR2) IS
    SELECT '1'
    FROM FND_LANGUAGES
    WHERE INSTALLED_FLAG IN ('I','B')
    AND   language_code = lang_code;

-- Variable Interface Rows

    TYPE l_vinf_interface_id             IS TABLE OF OKC_VARIABLES_INTERFACE.INTERFACE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_batch_number             IS TABLE OF OKC_VARIABLES_INTERFACE.BATCH_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_object_version_number    IS TABLE OF OKC_VARIABLES_INTERFACE.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_variable_code            IS TABLE OF OKC_VARIABLES_INTERFACE.VARIABLE_CODE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_variable_name            IS TABLE OF OKC_VARIABLES_INTERFACE.VARIABLE_NAME%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_process_status           IS TABLE OF OKC_VARIABLES_INTERFACE.PROCESS_STATUS%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_action                   IS TABLE OF OKC_VARIABLES_INTERFACE.ACTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_language                 IS TABLE OF OKC_VARIABLES_INTERFACE.LANGUAGE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_description              IS TABLE OF OKC_VARIABLES_INTERFACE.DESCRIPTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_variable_type            IS TABLE OF OKC_VARIABLES_INTERFACE.VARIABLE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_variable_intent          IS TABLE OF OKC_VARIABLES_INTERFACE.VARIABLE_INTENT%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_contract_expert_yn       IS TABLE OF OKC_VARIABLES_INTERFACE.CONTRACT_EXPERT_YN%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_xprt_value_set_name      IS TABLE OF OKC_VARIABLES_INTERFACE.XPRT_VALUE_SET_NAME%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_disabled_yn              IS TABLE OF OKC_VARIABLES_INTERFACE.DISABLED_YN%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_external_yn              IS TABLE OF OKC_VARIABLES_INTERFACE.EXTERNAL_YN%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_variable_datatype        IS TABLE OF OKC_VARIABLES_INTERFACE.VARIABLE_DATATYPE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_application_id           IS TABLE OF OKC_VARIABLES_INTERFACE.APPLICATION_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_value_set_name           IS TABLE OF OKC_VARIABLES_INTERFACE.VALUE_SET_NAME%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_var_default_value        IS TABLE OF OKC_VARIABLES_INTERFACE.VARIABLE_DEFAULT_VALUE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_system_reference_code    IS TABLE OF OKC_VARIABLES_INTERFACE.ORIG_SYSTEM_REFERENCE_CODE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_system_reference_id1     IS TABLE OF OKC_VARIABLES_INTERFACE.ORIG_SYSTEM_REFERENCE_ID1%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_system_reference_id2     IS TABLE OF OKC_VARIABLES_INTERFACE.ORIG_SYSTEM_REFERENCE_ID2%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_date_published           IS TABLE OF OKC_VARIABLES_INTERFACE.DATE_PUBLISHED%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute_category       IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE_CATEGORY%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute1               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute2               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute3               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE3%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute4               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute5               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute6               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute7               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE7%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute8               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE8%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute9               IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE9%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute10              IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE10%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute11              IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE11%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute12              IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE12%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute13              IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE13%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute14              IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE14%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_attribute15              IS TABLE OF OKC_VARIABLES_INTERFACE.ATTRIBUTE15%TYPE INDEX BY BINARY_INTEGER ;


    TYPE l_vinf_existing_code            IS TABLE OF OKC_BUS_VARIABLES_B.VARIABLE_CODE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_existing_dpublished      IS TABLE OF OKC_BUS_VARIABLES_B.DATE_PUBLISHED%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_value_set_id             IS TABLE OF OKC_BUS_VARIABLES_B.VALUE_SET_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_existing_language        IS TABLE OF OKC_BUS_VARIABLES_TL.LANGUAGE%TYPE INDEX BY BINARY_INTEGER ;


   l_return_status                      VARCHAR2(1);
   l_error_index                        NUMBER          := 1;
   l_batch_process_id                   NUMBER          := 1;
   l_context                            VARCHAR2(50)    := NULL;
   l_init_msg_list                      VARCHAR2(200)   := okc_api.g_true;
   l_tot_rows_processed                 NUMBER          := 0;
   l_tot_rows_failed                    NUMBER          := 0;
   l_tot_rows_warned                    NUMBER          := 0;
   l_part_rows_processed                NUMBER          := 0;
   l_part_rows_failed                   NUMBER          := 0;
   l_part_rows_warned                   NUMBER          := 0;
   l_bulk_failed                        VARCHAR2(1)     := 'Y';

-- Variables for variables interface
   vinf_interface_id_tbl                 l_vinf_interface_id ;
   vinf_batch_number_tbl                 l_vinf_batch_number ;
   vinf_object_version_number_tbl        l_vinf_object_version_number ;
   vinf_variable_code_tbl                l_vinf_variable_code ;
   vinf_variable_name_tbl                l_vinf_variable_name ;
   vinf_process_status_tbl               l_vinf_process_status ;
   vinf_action_tbl                       l_vinf_action ;
   vinf_language_tbl                     l_vinf_language ;
   vinf_description_tbl                  l_vinf_description ;
   vinf_variable_type_tbl                l_vinf_variable_type ;
   vinf_variable_intent_tbl              l_vinf_variable_intent ;
   vinf_contract_expert_yn_tbl           l_vinf_contract_expert_yn ;
   vinf_xprt_value_set_name_tbl          l_vinf_xprt_value_set_name ;
   vinf_disabled_yn_tbl                  l_vinf_disabled_yn ;
   vinf_external_yn_tbl                  l_vinf_external_yn ;
   vinf_variable_datatype_tbl            l_vinf_variable_datatype ;
   vinf_application_id_tbl               l_vinf_application_id ;
   vinf_value_set_name_tbl               l_vinf_value_set_name ;
   vinf_var_default_value_tbl            l_vinf_var_default_value ;
   vinf_system_reference_code_tbl        l_vinf_system_reference_code ;
   vinf_system_reference_id1_tbl         l_vinf_system_reference_id1 ;
   vinf_system_reference_id2_tbl         l_vinf_system_reference_id2 ;
   vinf_date_published_tbl               l_vinf_date_published ;
   vinf_attribute_category_tbl           l_vinf_attribute_category ;
   vinf_attribute1_tbl                   l_vinf_attribute1 ;
   vinf_attribute2_tbl                   l_vinf_attribute2 ;
   vinf_attribute3_tbl                   l_vinf_attribute3 ;
   vinf_attribute4_tbl                   l_vinf_attribute4 ;
   vinf_attribute5_tbl                   l_vinf_attribute5 ;
   vinf_attribute6_tbl                   l_vinf_attribute6 ;
   vinf_attribute7_tbl                   l_vinf_attribute7 ;
   vinf_attribute8_tbl                   l_vinf_attribute8 ;
   vinf_attribute9_tbl                   l_vinf_attribute9 ;
   vinf_attribute10_tbl                  l_vinf_attribute10 ;
   vinf_attribute11_tbl                  l_vinf_attribute11 ;
   vinf_attribute12_tbl                  l_vinf_attribute12 ;
   vinf_attribute13_tbl                  l_vinf_attribute13 ;
   vinf_attribute14_tbl                  l_vinf_attribute14 ;
   vinf_attribute15_tbl                  l_vinf_attribute15 ;


   vinf_existing_code_tbl                l_vinf_existing_code ;
   vinf_existing_dpublished_tbl          l_vinf_existing_dpublished ;
   vinf_value_set_id_tbl                 l_vinf_value_set_id ;
   vinf_existing_language_tbl            l_vinf_existing_language ;

   I NUMBER := 0;
   j NUMBER := 0;
   k NUMBER := 0;
   x NUMBER := 0;
   l_program_id                         OKC_VARIABLES_INTERFACE.PROGRAM_ID%TYPE;
   l_program_login_id                   OKC_VARIABLES_INTERFACE.PROGRAM_LOGIN_ID%TYPE;
   l_program_appl_id                    OKC_VARIABLES_INTERFACE.PROGRAM_APPLICATION_ID%TYPE;
   l_request_id                         OKC_VARIABLES_INTERFACE.REQUEST_ID%TYPE;
   l_dummy_unq VARCHAR2(1) := '?';
   l_dummy     VARCHAR2(1) := '?';
   l_vs_id     VARCHAR2(1) := NULL;
   l_language  varchar2(1) := '?';
   l_value_set_id                       FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_ID%TYPE;
   l_variable_datatype                 OKC_BUS_VARIABLES_B.VARIABLE_DATATYPE%TYPE;

BEGIN
IF (l_debug = 'Y') THEN
  okc_debug.log('100: Entered variables_import', 2);
END IF;

------------------------------------------------------------------------
--  Variable Initialization
-------------------------------------------------------------------------

-- Standard Start of API savepoint
FND_MSG_PUB.initialize;
--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_return_status := G_RET_STS_SUCCESS;
--  Cache user_id, login_id and org_id
l_user_id  := Fnd_Global.user_id;
l_login_id := Fnd_Global.login_id;

IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
   l_program_id := NULL;
ELSE
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
END IF;

IF FND_GLOBAL.CONC_LOGIN_ID = -1 THEN
   l_program_login_id := NULL;
ELSE
   l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
END IF;

IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
   l_program_appl_id := NULL;
ELSE
   l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
END IF;

IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
   l_request_id := NULL;
ELSE
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
END IF;

l_batch_process_id := p_batch_procs_id;
-------------------------------------------------------------------------
--------------- the outermost loop of this procedure --------------------
-- Bulk fetch all interface rows based on the fetchsize passedby the user
-------------------------------------------------------------------------

l_context :='BULK FETCH VARIABLE INTERFACE ROW';
OPEN l_var_interface_csr ( p_batch_number );
LOOP
BEGIN
    FETCH l_var_interface_csr BULK COLLECT INTO
          vinf_interface_id_tbl                  ,
          vinf_batch_number_tbl                  ,
          vinf_object_version_number_tbl         ,
          vinf_variable_code_tbl                 ,
          vinf_variable_name_tbl                 ,
          vinf_process_status_tbl                ,
          vinf_action_tbl                        ,
          vinf_language_tbl                      ,
          vinf_description_tbl                   ,
          vinf_variable_type_tbl                 ,
          vinf_variable_intent_tbl               ,
          vinf_contract_expert_yn_tbl            ,
          vinf_xprt_value_set_name_tbl           ,
          vinf_disabled_yn_tbl                   ,
          vinf_external_yn_tbl                   ,
          vinf_variable_datatype_tbl             ,
          vinf_application_id_tbl                ,
          vinf_value_set_name_tbl                ,
          vinf_var_default_value_tbl        ,
          vinf_system_reference_code_tbl    ,
          vinf_system_reference_id1_tbl     ,
          vinf_system_reference_id2_tbl     ,
          vinf_date_published_tbl                ,
          vinf_attribute_category_tbl            ,
          vinf_attribute1_tbl                    ,
          vinf_attribute2_tbl                    ,
          vinf_attribute3_tbl                    ,
          vinf_attribute4_tbl                    ,
          vinf_attribute5_tbl                    ,
          vinf_attribute6_tbl                    ,
          vinf_attribute7_tbl                    ,
          vinf_attribute8_tbl                    ,
          vinf_attribute9_tbl                    ,
          vinf_attribute10_tbl                   ,
          vinf_attribute11_tbl                   ,
          vinf_attribute12_tbl                   ,
          vinf_attribute13_tbl                   ,
          vinf_attribute14_tbl                   ,
          vinf_attribute15_tbl                   ,
          vinf_existing_code_tbl                 ,
          vinf_existing_dpublished_tbl           ,
          vinf_existing_language_tbl  LIMIT p_fetchsize;
    EXIT WHEN vinf_interface_id_tbl.COUNT = 0 ;

    ------------------------------------------------------------------------
    -- Variable initialization
    -------------------------------------------------------------------------
    --For each fetch, variable variable table index should be initialized
    j := 1;
    --##count:initialization
    l_tot_rows_processed    := l_tot_rows_processed+l_part_rows_processed;
    l_tot_rows_failed       := l_tot_rows_failed+l_part_rows_failed;
    l_tot_rows_warned       := l_tot_rows_warned+l_part_rows_warned;
    l_part_rows_processed   := 0;
    l_part_rows_failed      := 0;
    l_part_rows_warned      := 0;
    l_bulk_failed           := 'N';
    ---------------------------------------------------------------------------
    --------------------- Inner Loop thru fetched rows for---------------------
    -- validation, parse and validate article text, create a variable list
    -- prepare rows for DML if validate_only is 'N'
    /***  Processing Rule to set process_status
    Because we want to collect as much info as possible, we need to
    maintain process status while keeping the process moving.
    So, we'll set l_return_status as validation goes on and
    at the end we will set inf_process_status_tbl(i) with l_return_status
    for final result.  However, we will get out of this process if there
    is a significant error such as 'U'.
    The return status examined
    -api_return_status : return status for api call
    -l_return_status : validation result of each row
    -x_return_status : final result status for concurrent program request
    Rule to set return status
    If api_return_status for api call is
    * 'S' then continue
    * 'W' and l_return_status not 'E' or 'U' then set l_return_status = 'W'
        and build_error_array then continue
    * 'E' and it is significant then set l_return_status = 'E' and raise
      Exception
    * 'E' and it is minor then set l_return_status = 'E' and continue. Raise
       'E' at the end of validation
    * 'U' then set l_return_status = 'U' and raise 'U' exception
    * At the end, if it goes thru with no Exception,
    Check if l_return_status is 'E' then raise Exception
       Otherwise (meaning l_return_status is 'S' or 'W'),
          vinf_process_status_tbl(i) = l_return_status
    * In the exception, we will set
          vinf_process_status_tbl(i) = l_return_status and build_error_array
    ***/
    -------------------------------------------------------------------------

    FOR i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST LOOP
      BEGIN
      -- Increment total processed rows
      --##Count
      l_part_rows_processed := l_part_rows_processed+1;
      -- Initialization for each iteration
      l_row_notfound       := FALSE;
      l_return_status      := G_RET_STS_SUCCESS;

      -- following variables are not fetched from interface table
      -- thus initialize it here
      vinf_value_set_id_tbl(i) := NULL;
      vinf_variable_datatype_tbl(i) := NULL;

      l_context := 'VARIABLE VALIDATING';

      -- To find duplicate variable code in the batch
      IF i>1 THEN
         x := i-1;
         IF ((RTRIM(vinf_variable_code_tbl(i)) = RTRIM(vinf_variable_code_tbl(x)))
	    --THEN
	   AND (vinf_language_tbl(i)) = (vinf_language_tbl(x))) THEN
            Okc_Api.Set_Message(G_APP_NAME,
		                      'OKC_VAR_DUP_TITLE_ORG',
						  'VAR_CODE',
						  vinf_variable_code_tbl(i),
						  'LANG',
						  vinf_language_tbl(i));
            l_return_status := G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      -- Logic to decide what to do in case of Action='S'
	 -- If there is no existing variable in system then it is 'N' otherwise 'U'

	 IF vinf_action_tbl(i) = 'S' THEN
         IF vinf_existing_code_tbl(i) IS NULL THEN
	       vinf_action_tbl(i) := 'N';
	    ELSE
	       vinf_action_tbl(i) := 'U';
	    END IF;
	 END IF;


      IF vinf_action_tbl(i) = 'N' THEN

          --TRIM trailing space because
          vinf_variable_code_tbl(i) := RTRIM(vinf_variable_code_tbl(i));

      ELSIF vinf_action_tbl(i) in ('U','D') THEN

          IF vinf_existing_code_tbl(i) is NULL THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_VAR_CODE_NOT_FOUND',
                      p_token1       => 'VARIABLE_CODE',
                      p_token1_value => vinf_variable_code_tbl(i));
              l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;

      ELSE

          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_VAR_INV_IMP_ACTION');
          l_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR ;
      END IF;

      -----------------------------------------------------------
      -- Common validation or attribute settting
      -- regardless of status and import action
      -- this validation is not included in validate api
      -----------------------------------------------------------
      -- Get Value set id and Datatype from Value set name provided by the user
         OPEN  get_valset_id_csr(vinf_value_set_name_tbl(i));
	    FETCH get_valset_id_csr into l_value_set_id,l_variable_datatype;
	    CLOSE get_valset_id_csr;
	    IF l_value_set_id is null THEN
	        IF p_validate_only = 'Y' THEN
                OPEN valset_exists_csr (vinf_value_set_name_tbl(i),
		                              vinf_batch_number_tbl(i));
	           FETCH valset_exists_csr into l_vs_id;
	           CLOSE valset_exists_csr;
		      IF l_vs_id is null THEN
                Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                    p_msg_name => 'OKC_ART_VAL_SET_NOT_FOUND');
                l_return_status := G_RET_STS_ERROR;
			 ELSE
		      -- Reset Local Variables
			 l_vs_id := NULL;

		      END IF;
             ELSE
                Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                   p_msg_name => 'OKC_ART_VAL_SET_NOT_FOUND');
                l_return_status := G_RET_STS_ERROR;
		   END IF;

         ELSE
	       vinf_value_set_id_tbl(i) := l_value_set_id;
		  vinf_variable_datatype_tbl(i)    := l_variable_datatype;
		  -- Reset Local Variables
		  l_value_set_id := NULL;
		  l_variable_datatype := NULL;
         END IF;


      -- Checking Date Published Validation
      IF vinf_existing_dpublished_tbl(i) >= vinf_date_published_tbl(i) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_DATE_PUBLISHED');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Checking Variable Flags
      IF nvl(vinf_disabled_yn_tbl(i), '*') not in ('Y','N') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_DISABLED_FLAG');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF nvl(vinf_external_yn_tbl(i), '*') not in ('Y','N') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_EXTERNAL_FLAG');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF nvl(vinf_contract_expert_yn_tbl(i), '*') not in ('Y','N') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_CONTRACT_EXPERT_FLAG');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF nvl(vinf_variable_intent_tbl(i), '*') not in ('B','S') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_INTENT_FLAG');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF nvl(vinf_variable_type_tbl(i), '*') <> 'U' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_VARIABLE_TYPE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Checking Variable Type and Value set id
      IF nvl(vinf_variable_type_tbl(i), '*')  = 'U' THEN
	    IF vinf_value_set_name_tbl(i) is null THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_VS_NOT_DEFINED');
            l_return_status := G_RET_STS_ERROR;
         END IF;
      END IF;


      IF nvl(vinf_contract_expert_yn_tbl(i), '*') not in ('Y','N') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_CONTRACT_EXPERT_FLAG');
            l_return_status := G_RET_STS_ERROR;
      END IF;

     -- Validate Contract Expert related data

      IF ((vinf_xprt_value_set_name_tbl(i) is not null OR
	    vinf_contract_expert_yn_tbl(i) = 'Y' ) AND
	    vinf_variable_type_tbl(i) <> 'S')
	    THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_VAR_INV_XPRT_DATA');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ((vinf_xprt_value_set_name_tbl(i) is not null OR
	    vinf_contract_expert_yn_tbl(i) = 'Y' ) AND
	    vinf_variable_type_tbl(i) <> 'S')
	    THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_VAR_INV_XPRT_DATA');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ((vinf_variable_datatype_tbl(i)  = 'D') AND
	    ((vinf_contract_expert_yn_tbl(i) = 'Y' ) OR
	    (vinf_xprt_value_set_name_tbl(i) <> 'S')))
	    THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_VAR_INV_XPRT_DATA');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ((vinf_variable_datatype_tbl(i)  = 'V') AND
	    (vinf_contract_expert_yn_tbl(i) = 'Y' ) AND
	    (vinf_xprt_value_set_name_tbl(i) is null) )
	    THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_VAR_INV_XPRT_DATA');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ((vinf_contract_expert_yn_tbl(i) = 'N') AND
	    (vinf_xprt_value_set_name_tbl(i) is not null) )
	    THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_VAR_INV_XPRT_DATA');
            l_return_status := G_RET_STS_ERROR;
      END IF;
      -- Check for Valid External Flag
      IF ((vinf_variable_intent_tbl(i)  = 'S') AND
	    (vinf_external_yn_tbl(i)  = 'Y') )
	    THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_VAR_INVALID_EXTERNALYN',
						  p_token1   => 'VAR_NAME',
						  p_token1_value => vinf_variable_name_tbl(i));
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Validate "Language" is installed or not
         OPEN  check_lang_csr(vinf_language_tbl(i));
	    FETCH check_lang_csr into l_language;
	    CLOSE check_lang_csr;
	    --IF check_lang_csr%NOTFOUND  THEN
	    IF l_language <> '1'  THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_LANG_NOT_INSTALLED',
                                p_token1       => 'LANGUAGE',
                                p_token1_value => vinf_language_tbl(i));
            l_return_status := G_RET_STS_ERROR;
		  ELSE
            l_language := '?';
         END IF;


      -- Validate attrs of the interface row
      IF vinf_action_tbl(i) = 'N' THEN
      -- Checking uniqueness of variable name and intent
         OPEN  get_var_unq_csr(vinf_variable_name_tbl(i),
	                           vinf_variable_intent_tbl(i));
	    FETCH get_var_unq_csr into l_dummy_unq;
	    CLOSE get_var_unq_csr;
	    IF l_dummy_unq = '1' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_VAR_NAME_NOT_UNIQUE');
            l_return_status := G_RET_STS_ERROR;
         END IF;

      -- Checking variable code is unique in the system
         OPEN  get_var_info_csr(vinf_variable_code_tbl(i));
	    FETCH get_var_info_csr into l_dummy;
	    CLOSE get_var_info_csr;
	    IF l_dummy = '1' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_VAR_CODE_NOT_UNIQUE');
            l_return_status := G_RET_STS_ERROR;
         END IF;

      ELSIF vinf_action_tbl(i) = 'U' THEN
	     NULL;
      END IF;

      ------------------------------------------------------------------------
      -- Now that we have validated and data is clean we can fetch sequences and ids
      -- for new variables for DML and also set the process status to Success
      -------------------------------------------------------------------------

      -- Summarize report for this row
      -- Status 'F' is for internal use meaning parsing failure marked in
      -- java concurrent program
      IF (l_return_status = G_RET_STS_SUCCESS) THEN
         IF (nvl(vinf_process_status_tbl(i), 'E') = 'E') THEN
           vinf_process_status_tbl(i) := G_RET_STS_SUCCESS;
         ELSIF ( vinf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           vinf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = l_sts_warning) THEN
         IF (nvl(vinf_process_status_tbl(i),'E') = 'E') THEN
           vinf_process_status_tbl(i) := l_sts_warning;
           --##count
           --l_tot_rows_warned := l_tot_rows_warned+1;
           l_part_rows_warned := l_part_rows_warned+1;
         ELSIF (vinf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           vinf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop
    -- validation and unexpected errors
    -- In case of unexpected error, escape the loop
    -------------------------
    -------------------------


      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('300: In Variables_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
              END IF;
              --l_return_status := G_RET_STS_ERROR ;
              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vinf_interface_id_tbl(i),
                 p_article_title => vinf_variable_code_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'VARIABLE'
                );
               vinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
               -- Continue to next row

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('400: Leaving Variables_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
              END IF;

              IF l_var_interface_csr%ISOPEN THEN
                 CLOSE l_var_interface_csr;
              END IF;

              --Set_Message
              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vinf_interface_id_tbl(i),
                 p_article_title => vinf_variable_code_tbl(i),
                 p_error_type    => G_RET_STS_UNEXP_ERROR,
			  p_entity        => 'VARIABLE'
                 );
               vinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit; -- exit the current fetch

          WHEN OTHERS THEN
              IF (l_debug = 'Y') THEN
                okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||sqlerrm, 2);
              END IF;

              IF l_var_interface_csr%ISOPEN THEN
                 CLOSE l_var_interface_csr;
              END IF;

              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_UNEXPECTED_ERROR,
                                p_token1       => G_SQLCODE_TOKEN,
                                p_token1_value => sqlcode,
                                p_token2       => G_SQLERRM_TOKEN,
                                p_token2_value => sqlerrm);

              build_error_array(
                 p_msg_data     => G_UNEXPECTED_ERROR,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vinf_interface_id_tbl(i),
                 p_article_title => vinf_variable_code_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'VARIABLE'
                );
               vinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit;  -- exit the current fetch
          END;
    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop ends
    -------------------------
    -------------------------


     END LOOP; -- end of FOR i in inf_interface_id_tbl.FIRST ..
    ------------------------------------------------------------------------
    -------------- End of Inner Loop thru fetched row for---------------------
    -- validation,
    -------------------------------------------------------------------------
    -- In order to propagate Unexpected error raise it if it is 'U'
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -------------------------
    -------------------------
    -- Exception Block for Inner Loop starts
    -- Handles unexpected errors as last step
    -------------------------
    -------------------------
    EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF (l_debug = 'Y') THEN
                okc_debug.log('400: Leaving Variables_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
             END IF;

             IF l_var_interface_csr%ISOPEN THEN
                CLOSE l_var_interface_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop

        WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;

             IF l_var_interface_csr%ISOPEN THEN
                CLOSE l_var_interface_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop
     END;

    -------------------------
    -------------------------
    -- Exception Block for Each Iteration of outermost Loop ends
    -------------------------
    -------------------------

    ------------------------------------------------------------------------
    --------------------- Start Do_DML for Variables   ---------------
    -- Insert or Update Variable
    -------------------------------------------------------------------------
    -- initialize l_return_status to track status of DML execution
     l_return_status := G_RET_STS_SUCCESS;


    IF p_validate_only = 'N' THEN
         BEGIN
         SAVEPOINT bulkdml;

         i := 0;
        -- Bulk insert New Valid Records
         BEGIN
         l_context := 'INSERTING NEW VARIABLE INTO B TABLE';

           FORALL  i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST
            INSERT INTO OKC_BUS_VARIABLES_B(
             VARIABLE_CODE,
             OBJECT_VERSION_NUMBER,
             VARIABLE_TYPE,
             EXTERNAL_YN,
             VARIABLE_INTENT,
             CONTRACT_EXPERT_YN,
	        DISABLED_YN,
	        VARIABLE_DATATYPE,
	        APPLICATION_ID,
	        VALUE_SET_ID,
	        VARIABLE_DEFAULT_VALUE,
	    	   XPRT_VALUE_SET_NAME,
	        DATE_PUBLISHED,
             ORIG_SYSTEM_REFERENCE_CODE,
             ORIG_SYSTEM_REFERENCE_ID1,
             ORIG_SYSTEM_REFERENCE_ID2,
    --         PROGRAM_ID,
    --         PROGRAM_LOGIN_ID,
    --         PROGRAM_APPLICATION_ID,
    --         REQUEST_ID,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE,
              VARIABLE_SOURCE)   --Added for Bug 10227193
           SELECT
             vinf_variable_code_tbl(i),
		   1.0,
             vinf_variable_type_tbl(i),
             vinf_external_yn_tbl(i),
             vinf_variable_intent_tbl(i),
             vinf_contract_expert_yn_tbl(i),
             vinf_disabled_yn_tbl(i),
             vinf_variable_datatype_tbl(i),
             vinf_application_id_tbl(i),
             vinf_value_set_id_tbl(i),
             vinf_var_default_value_tbl(i),
             vinf_xprt_value_set_name_tbl(i),
             vinf_date_published_tbl(i),
             vinf_system_reference_code_tbl(i),
             vinf_system_reference_id1_tbl(i),
             vinf_system_reference_id2_tbl(i),
     --        l_program_id,
     --        l_program_login_id,
     --        l_program_appl_id,
     --        l_request_id,
             vinf_attribute_category_tbl(i),
             vinf_attribute1_tbl(i),
             vinf_attribute2_tbl(i),
             vinf_attribute3_tbl(i),
             vinf_attribute4_tbl(i),
             vinf_attribute5_tbl(i),
             vinf_attribute6_tbl(i),
             vinf_attribute7_tbl(i),
             vinf_attribute8_tbl(i),
             vinf_attribute9_tbl(i),
             vinf_attribute10_tbl(i),
             vinf_attribute11_tbl(i),
             vinf_attribute12_tbl(i),
             vinf_attribute13_tbl(i),
             vinf_attribute14_tbl(i),
             vinf_attribute15_tbl(i),
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate,
              'M'            --Added for Bug 10227193
           FROM DUAL
           WHERE vinf_action_tbl(i)  = 'N' and
                 vinf_process_status_tbl(i)  in ('S', 'W') and
			  vinf_language_tbl(i) = USERENV('LANG');

        -- Using a " select from dual" aproach as above prevents creation of
        -- additional PL/SQL tables for bulk insert of
        -- variables if we were to use a FORALL INSERT INTO .... VALUES .... approach.
        -- We cannot use FORALL INSERT INTO .... VALUES ....using
        -- the existing inf*tbl since the error rows need to be
        -- filtered out.

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

         --
         --  End of Insert into OKC_BUS_VARIABLES_B
         --
         --

         i := 0;
         BEGIN
         l_context := 'INSERTING VARIABLE INTO TL TABLE';

         FORALL  i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST
           INSERT INTO OKC_BUS_VARIABLES_TL(
              VARIABLE_CODE,
              VARIABLE_NAME,
              LANGUAGE,
              SOURCE_LANG,
              DESCRIPTION,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE)
           SELECT
              vinf_variable_code_tbl(i),
              vinf_variable_name_tbl(i),
              vinf_language_tbl(i),
              userenv('LANG'),
              vinf_description_tbl(i),
              l_user_id,
              sysdate,
              l_user_id,
              l_login_id,
              sysdate
           FROM OKC_BUS_VARIABLES_B
           WHERE vinf_action_tbl(i)  IN ('N')
             AND vinf_process_status_tbl(i) in ('S', 'W')
             AND variable_code  = vinf_variable_code_tbl(i);

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

          --
          -- End of Insert into OKC_BUS_VARIABLES_TL
          --
          --

         i := 0;
         BEGIN
           l_context := 'UPDATING DATE_PUBLISHED FOR ACTION U';

         FORALL  i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST
           UPDATE OKC_BUS_VARIABLES_B
           SET DATE_PUBLISHED             = vinf_date_published_tbl(i),
               LAST_UPDATED_BY            = l_user_id,
               LAST_UPDATE_LOGIN          = l_login_id,
               LAST_UPDATE_DATE           = SYSDATE
           WHERE vinf_action_tbl(i)  =  ('U')
             AND vinf_process_status_tbl(i) in ('S','W')
             AND variable_code = vinf_variable_code_tbl(i)
		   AND vinf_existing_language_tbl(i) IS NOT NULL;
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

          --
          -- End of Update OKC_BUS_VARIABLES_B
          --
          --
         i := 0;
         BEGIN
           l_context := 'UPDATING DESCRIPTION FOR ACTION U';

         FORALL  i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST
           UPDATE OKC_BUS_VARIABLES_TL
           SET DESCRIPTION                = vinf_description_tbl(i),
               --PROGRAM_ID                 = l_program_id,
               --REQUEST_ID                 = l_request_id,
               --PROGRAM_LOGIN_ID           = l_program_login_id,
               --PROGRAM_APPLICATION_ID     = l_program_appl_id,
               LAST_UPDATED_BY            = l_user_id,
               LAST_UPDATE_LOGIN          = l_login_id,
               LAST_UPDATE_DATE           = SYSDATE
           WHERE vinf_action_tbl(i)  =  ('U')
             AND vinf_process_status_tbl(i) in ('S','W')
             AND variable_code = vinf_variable_code_tbl(i)
		   AND vinf_existing_language_tbl(i) IS NOT NULL;
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

          --
          -- End of Update OKC_BUS_VARIABLES_TL
          --
          --

         i := 0;
         BEGIN
         l_context := 'INSERTING VARIABLE INTO TL TABLE FOR ACTION U';

         FORALL  i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST
           INSERT INTO OKC_BUS_VARIABLES_TL(
              VARIABLE_CODE,
              VARIABLE_NAME,
              LANGUAGE,
              SOURCE_LANG,
              DESCRIPTION,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE)
           SELECT
              vinf_variable_code_tbl(i),
              vinf_variable_name_tbl(i),
              vinf_language_tbl(i),
              userenv('LANG'),
              vinf_description_tbl(i),
              l_user_id,
              sysdate,
              l_user_id,
              l_login_id,
              sysdate
           FROM OKC_BUS_VARIABLES_B
           WHERE vinf_action_tbl(i) = ('U')
             AND vinf_process_status_tbl(i) in ('S', 'W')
             AND variable_code  = vinf_variable_code_tbl(i)
		   AND vinf_existing_language_tbl(i) IS NULL;

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

          --
          -- End of Insert into OKC_BUS_VARIABLES_TL for Action U
          --
          --

         i := 0;
         BEGIN
           l_context := 'DISABLING VARIABLE FOR ACTION D';

         FORALL  i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST
           UPDATE OKC_BUS_VARIABLES_B
           SET DISABLED_YN                  = vinf_disabled_yn_tbl(i),
               --PROGRAM_ID                 = l_program_id,
               --REQUEST_ID                 = l_request_id,
               --PROGRAM_LOGIN_ID           = l_program_login_id,
               --PROGRAM_APPLICATION_ID     = l_program_appl_id,
               LAST_UPDATED_BY            = l_user_id,
               LAST_UPDATE_LOGIN          = l_login_id,
               LAST_UPDATE_DATE           = SYSDATE
           WHERE vinf_action_tbl(i)  =  ('D')
             AND vinf_process_status_tbl(i) in ('S','W')
             AND variable_code = vinf_variable_code_tbl(i);
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

          --
          -- End of Update OKC_BUS_VARIABLES_TL for Disable
          --
          --


      -- Exception for bulk DML block
      EXCEPTION
        WHEN OTHERS THEN
             l_bulk_failed := 'Y'; -- indicating that bulk operation has failed
              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_UNEXPECTED_ERROR,
                                  p_token1       => G_SQLCODE_TOKEN,
                                  p_token1_value => sqlcode,
                                  p_token2       => G_SQLERRM_TOKEN,
                                  p_token2_value => sqlerrm);
              Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKC_ART_FETCH_FAILED',
                                  p_token1       => 'CONTEXT',
                                  p_token1_value => l_context);

              build_error_array(
                                 p_msg_data     => null,
                                 p_context      => l_context,
                                 p_batch_process_id => l_batch_process_id,
                                 p_interface_id  => -99,
                                 p_article_title => NULL,
                                 p_error_type    => G_RET_STS_ERROR,
						   p_entity        => 'VARIABLE'
              );
              l_return_status := G_RET_STS_UNEXP_ERROR;
              x_return_status := G_RET_STS_UNEXP_ERROR;

              --##count:rollback the count
              l_part_rows_failed := l_part_rows_processed;
              l_part_rows_warned := 0;

              ROLLBACK TO SAVEPOINT bulkdml;
              exit; -- exit outermost loop
      END;

    END IF; --- validate_only = 'N'

    ------------------------------------------------------------------------
    --------------------- End of Do_DML for Variables   ---------------
    -------------------------------------------------------------------------

    ------------------------------------------------------------------------
    --------------- Start of Do_DML for import related tables   ------------
    -- Update interface table
    -- Insert Errors into Error table
    -------------------------------------------------------------------------
    -- Update Interface Table
    i:=0;
    BEGIN
     l_context := 'UPDATING VARIABLES INTERFACE TABLE';
     FORALL i in vinf_interface_id_tbl.FIRST..vinf_interface_id_tbl.LAST
       UPDATE OKC_VARIABLES_INTERFACE
       SET
           -- We don't want to update process_status to 'S' or 'W' in validation_mode
           -- because it is not going to be picked up in next run if we do so
           PROCESS_STATUS = decode(p_validate_only||vinf_process_status_tbl(i)||l_bulk_failed,
                                               'NEN','E',
                                               'NSN','S',
                                               'NWN','W',
                                               'NEY','E',
                                               'NSY',NULL,
                                               'NWY',NULL,
                                               'YEY','E',
                                               'YEN','E',
                                               'NFY','E',
                                               'YFY','E',
                                               'NFN','E',
                                               'YFN','E',NULL),
           PROGRAM_ID                 = l_program_id,
           REQUEST_ID                 = l_request_id,
           PROGRAM_LOGIN_ID           = l_program_login_id,
           PROGRAM_APPLICATION_ID     = l_program_appl_id,
           OBJECT_VERSION_NUMBER      = vinf_object_version_number_tbl(i) + 1,
           LAST_UPDATED_BY            = l_user_id,
           LAST_UPDATE_LOGIN          = l_login_id,
           LAST_UPDATE_DATE           = SYSDATE
         WHERE
           interface_id = vinf_interface_id_tbl(i);
    EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Variables_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;
             Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
             Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_VAR_INT_UPDATE_FAILED');
             build_error_array(
                       p_msg_data     => null,
                       p_context      => l_context,
                       p_batch_process_id => l_batch_process_id,
                       p_interface_id  => -99,
                       p_article_title => NULL,
                       p_error_type    => G_RET_STS_ERROR,
				   p_entity        => 'VARIABLE'
             );

		      l_return_status := G_RET_STS_UNEXP_ERROR ;
		      x_return_status := G_RET_STS_UNEXP_ERROR ;
		       --##count:rollback the count
		      l_part_rows_failed := l_part_rows_processed;
		      l_part_rows_warned := 0;

             --RAISE FND_API.G_EXC_ERROR ;
  END;
   --
   -- End of Update OKC_VARIABLES_INTERFACE
   --
   --

    --
    --Insert Errors into Error table for this fetch
    --

    insert_error_array(
     x_return_status => x_return_status,
     x_msg_count     => x_msg_count,
     x_msg_data      => x_msg_data
    );


    IF (x_return_status = l_insert_errors_error) THEN
      NULL;
     -- Ignore
     -- RAISE l_insert_errors_exception;
    END IF;

    ------------------------------------------------------------------------
    --------------- End of Do_DML for import related tables   ------------
    -------------------------------------------------------------------------
    commit;

    -- Now delete cache for next bulk fetch

    vinf_interface_id_tbl.DELETE;
    vinf_batch_number_tbl.DELETE;
    vinf_object_version_number_tbl.DELETE;
    vinf_variable_code_tbl.DELETE;
    vinf_variable_name_tbl.DELETE;
    vinf_process_status_tbl.DELETE;
    vinf_action_tbl.DELETE;
    vinf_language_tbl.DELETE;
    vinf_description_tbl.DELETE;
    vinf_variable_type_tbl.DELETE;
    vinf_variable_intent_tbl.DELETE;
    vinf_contract_expert_yn_tbl.DELETE;
    vinf_xprt_value_set_name_tbl.DELETE;
    vinf_disabled_yn_tbl.DELETE;
    vinf_external_yn_tbl.DELETE;
    vinf_variable_datatype_tbl.DELETE;
    vinf_application_id_tbl.DELETE;
    vinf_value_set_name_tbl.DELETE;
    vinf_var_default_value_tbl.DELETE;
    vinf_system_reference_code_tbl.DELETE;
    vinf_system_reference_id1_tbl.DELETE;
    vinf_system_reference_id2_tbl.DELETE;
    vinf_date_published_tbl.DELETE;
    vinf_attribute_category_tbl.DELETE;
    vinf_attribute1_tbl.DELETE;
    vinf_attribute2_tbl.DELETE;
    vinf_attribute3_tbl.DELETE;
    vinf_attribute4_tbl.DELETE;
    vinf_attribute5_tbl.DELETE;
    vinf_attribute6_tbl.DELETE;
    vinf_attribute7_tbl.DELETE;
    vinf_attribute8_tbl.DELETE;
    vinf_attribute9_tbl.DELETE;
    vinf_attribute10_tbl.DELETE;
    vinf_attribute11_tbl.DELETE;
    vinf_attribute12_tbl.DELETE;
    vinf_attribute13_tbl.DELETE;
    vinf_attribute14_tbl.DELETE;
    vinf_attribute15_tbl.DELETE;

    vinf_value_set_id_tbl.DELETE;
    vinf_existing_code_tbl.DELETE;
    vinf_existing_dpublished_tbl.DELETE;
    vinf_existing_language_tbl.DELETE;

    err_batch_process_id_tbl.DELETE;
    err_article_title_tbl.DELETE;
    err_interface_id_tbl.DELETE;
    err_error_number_tbl.DELETE;
    err_object_version_number_tbl.DELETE;
    err_error_type_tbl.DELETE;
    err_entity_tbl.DELETE;
    err_error_description_tbl.DELETE;

   EXIT WHEN l_var_interface_csr%NOTFOUND;
END LOOP;


-----------------------------------------------------------------------
-- End of outermost loop for bulk fetch
-----------------------------------------------------------------------

IF l_var_interface_csr%ISOPEN THEN
CLOSE l_var_interface_csr;
END IF;

 -- Insert records into OKC_BUS_VARIABLES_TL for missing languages
   IF p_validate_only = 'N' THEN
     BEGIN
     SAVEPOINT bulklanginsert;
     IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Entering Insert Missing Lang Records', 2);
     END IF;

      INSERT INTO OKC_BUS_VARIABLES_TL (
        VARIABLE_CODE,
        VARIABLE_NAME,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG
      )
 	SELECT
        VART.VARIABLE_CODE,
        VART.VARIABLE_NAME,
        VART.DESCRIPTION,
        l_user_id,
        sysdate,
        sysdate,
        l_user_id,
        l_login_id,
        LANG.LANGUAGE_CODE,
        VART.SOURCE_LANG
      FROM OKC_BUS_VARIABLES_TL VART,
 		 FND_LANGUAGES LANG,
 		 OKC_VARIABLES_INTERFACE VARI
      WHERE LANG.INSTALLED_FLAG IN ('I', 'B')
      AND VART.VARIABLE_CODE = RTRIM(VARI.VARIABLE_CODE)
      AND NVL(VARI.PROCESS_STATUS,'*') = 'S'
      AND VARI.BATCH_NUMBER = p_batch_number
      AND VARI.ACTION  <> 'D'
      AND NOT EXISTS
       (SELECT NULL
        FROM OKC_BUS_VARIABLES_TL VART1
        WHERE VART1.VARIABLE_CODE = VART.VARIABLE_CODE
        AND VART1.LANGUAGE = LANG.LANGUAGE_CODE)
        AND VART.ROWID = (SELECT MIN(VART2.ROWID)
    	                 FROM OKC_BUS_VARIABLES_TL VART2
                        WHERE VART2.VARIABLE_CODE = VART.VARIABLE_CODE)
      AND VARI.ROWID = (SELECT MIN(VARI1.ROWID)
                  FROM OKC_VARIABLES_INTERFACE VARI1
                  WHERE RTRIM(VARI1.VARIABLE_CODE) = RTRIM(VARI.VARIABLE_CODE)
 				   AND VARI1.ACTION <> 'D'
 				   AND VARI1.BATCH_NUMBER = VARI.BATCH_NUMBER
 				   AND NVL(VARI1.PROCESS_STATUS,'*') = 'S');
      COMMIT;

     IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Leaving Insert Missing Lang Records', 2);
     END IF;

     EXCEPTION
       WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
           okc_debug.log('1200: Leaving Missing langauge Insert because of EXCEPTION: '||l_context||sqlerrm, 2);
         END IF;
         ROLLBACK TO SAVEPOINT bulklanginsert;
     END;

   END IF;  --p_validate_only = 'N' THEN

--##count:add up last processed counts
l_tot_rows_processed := l_tot_rows_processed + l_part_rows_processed;
l_tot_rows_failed := l_tot_rows_failed + l_part_rows_failed;
l_tot_rows_warned := l_tot_rows_warned + l_part_rows_warned;

--Update Batch Process Table as a last step
UPDATE OKC_ART_INT_BATPROCS_ALL
SET
  TOTAL_ROWS_PROCESSED       = l_tot_rows_processed,
  TOTAL_ROWS_FAILED          = l_tot_rows_failed,
  TOTAL_ROWS_WARNED          = l_tot_rows_warned,
  END_DATE                   = SYSDATE,
  PROGRAM_ID                 = l_program_id,
  REQUEST_ID                 = l_request_id,
  PROGRAM_LOGIN_ID           = l_program_login_id,
  PROGRAM_APPLICATION_ID     = l_program_appl_id,
  OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
  LAST_UPDATED_BY            = l_user_id,
  LAST_UPDATE_LOGIN          = l_login_id,
  LAST_UPDATE_DATE           = SYSDATE
WHERE
  BATCH_PROCESS_ID  = l_batch_process_id
  AND ENTITY = 'Variable';

IF err_error_number_tbl.COUNT > 0 THEN
 insert_error_array(
   x_return_status => x_return_status,
   x_msg_count     => x_msg_count,
   x_msg_data      => x_msg_data
 );
END IF;

-- Print statistic of this run in the log
-- Commented for new XML Based Import - Moved to new_wrap_up in conc_import_articles
--wrap_up(p_validate_only,p_batch_number,l_tot_rows_processed,l_tot_rows_failed,l_tot_rows_warned,l_batch_process_id,'VARIABLE');
commit; -- Final commit for status update

IF (l_debug = 'Y') THEN
 okc_debug.log('2000: Leaving variables import', 2);
END IF;
--x_return_status := l_return_status; this may cause to erase error x_return_status

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('3000: Leaving Variables_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      x_return_status := G_RET_STS_ERROR ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('4000: Leaving Variables_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any

      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;

      IF l_var_interface_csr%ISOPEN THEN
         CLOSE l_var_interface_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);

  WHEN l_insert_errors_exception THEN
      --
      -- In this exception handling, we don't insert error array again
      -- because error happend in the module
      --
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Variables_Import because of EXCEPTION in insert_error_array: '||sqlerrm, 2);
      END IF;

      IF l_var_interface_csr%ISOPEN THEN
         CLOSE l_var_interface_csr;
      END IF;


      --x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);
      commit;

  WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Variables_Import because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;
      --
      IF l_var_interface_csr%ISOPEN THEN
         CLOSE l_var_interface_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
	 get_print_msgs_stack(p_msg_data => x_msg_data);
END import_variables;

PROCEDURE import_relationships(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100,
    p_rows_processed               OUT NOCOPY NUMBER,
    p_rows_failed                  OUT NOCOPY NUMBER,
    p_rows_warned                  OUT NOCOPY NUMBER
   ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'import_relationships';
    l_sts_warning                 CONSTANT VARCHAR2(1) := 'W';
    l_row_notfound                BOOLEAN := FALSE;
    l_user_id                     NUMBER;
    l_login_id                    NUMBER;
    l_insert_errors_exception     EXCEPTION;
    l_insert_errors_error         CONSTANT VARCHAR2(1) := 'X';

    CURSOR l_rel_interface_csr ( cp_local_org_id IN NUMBER,
                                 cp_batch_number IN VARCHAR2) IS
      SELECT
           RELINT.INTERFACE_ID     ,
           RELINT.BATCH_NUMBER             ,
           RELINT.OBJECT_VERSION_NUMBER  ,
           RELINT.SOURCE_ARTICLE_TITLE    ,
           RELINT.TARGET_ARTICLE_TITLE    ,
           RELINT.ORG_ID,
           RELINT.RELATIONSHIP_TYPE       ,
           RELINT.PROCESS_STATUS           ,
           RELINT.ACTION                  ,
           RELS.ARTICLE_INTENT SOURCE_INTENT,
           RELS.ARTICLE_ID SOURCE_ARTICLE_ID    ,
           RELT.ARTICLE_INTENT TARGET_INTENT,
           RELT.ARTICLE_ID TARGET_ARTICLE_ID
      FROM OKC_ART_RELS_INTERFACE RELINT,
	      OKC_ARTICLES_ALL RELS, OKC_ARTICLES_ALL RELT
      WHERE nvl(PROCESS_STATUS,'*') NOT IN ('W', 'S')
         AND BATCH_NUMBER = cp_batch_number
         AND RELINT.ORG_ID = cp_local_org_id
         AND RELINT.SOURCE_ARTICLE_TITLE = RELS.ARTICLE_TITLE(+)
	    AND RELINT.ORG_ID = RELS.ORG_ID(+)
         AND RELINT.TARGET_ARTICLE_TITLE = RELT.ARTICLE_TITLE(+)
	    AND RELINT.ORG_ID = RELT.ORG_ID(+)
      ORDER BY RELINT.SOURCE_ARTICLE_TITLE,RELINT.TARGET_ARTICLE_TITLE ASC;

      CURSOR l_rel_exist_csr (cp_src_article_id IN NUMBER,
	                         cp_tar_article_id IN NUMBER,
		                    cp_org_id IN NUMBER,
						cp_rel_type IN VARCHAR2) IS
	 SELECT '1' FROM OKC_ARTICLE_RELATNS_ALL
	 WHERE source_article_id = cp_src_article_id
	 AND  target_article_id = cp_tar_article_id
	 AND  org_id = cp_org_id
	 AND  relationship_type = cp_rel_type;

      CURSOR l_org_valid_csr (cp_org_id IN NUMBER) IS
	 SELECT '1'
	 FROM HR_ORGANIZATION_INFORMATION_V orgi, HR_ORGANIZATION_UNITS_V orgu
      WHERE orgi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
      AND   orgi.organization_id = orgu.organization_id
	 AND   orgi.organization_id = cp_org_id;

      CURSOR l_provision_csr (cp_article_id IN NUMBER) IS
	 SELECT provision_yn FROM OKC_ARTICLE_VERSIONS
	 WHERE article_id = cp_article_id
	 AND   article_version_number = 1;

   -- Cursor to check clause in the clause interface Table
       CURSOR clause_exists_csr (cp_article_title IN VARCHAR2,
	                            cp_org_id IN NUMBER,
                                 cp_batch_number IN VARCHAR2) IS
       SELECT '1'
       FROM OKC_ART_INTERFACE_ALL
       WHERE article_title = cp_article_title
	  AND   org_id = cp_org_id
       AND   batch_number = cp_batch_number
       AND   nvl(process_status,'X') not in ('E');


-- Relationships Interface Rows

    TYPE l_rinf_interface_id             IS TABLE OF OKC_ART_RELS_INTERFACE.INTERFACE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_batch_number             IS TABLE OF OKC_ART_RELS_INTERFACE.BATCH_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_object_version_number    IS TABLE OF OKC_ART_RELS_INTERFACE.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_source_article_title     IS TABLE OF OKC_ART_RELS_INTERFACE.SOURCE_ARTICLE_TITLE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_target_article_title     IS TABLE OF OKC_ART_RELS_INTERFACE.TARGET_ARTICLE_TITLE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_org_id                   IS TABLE OF OKC_ART_RELS_INTERFACE.ORG_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_relationship_type        IS TABLE OF OKC_ART_RELS_INTERFACE.RELATIONSHIP_TYPE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_process_status           IS TABLE OF OKC_ART_RELS_INTERFACE.PROCESS_STATUS%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_action                   IS TABLE OF OKC_ART_RELS_INTERFACE.ACTION%TYPE INDEX BY BINARY_INTEGER ;

    TYPE l_rinf_source_article_id        IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_source_intent            IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_INTENT%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_target_article_id        IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_rinf_target_intent            IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_INTENT%TYPE INDEX BY BINARY_INTEGER ;


   l_return_status                      VARCHAR2(1);
   l_error_index                        NUMBER          := 1;
   l_batch_process_id                   NUMBER          := 1;
   l_context                            VARCHAR2(50)    := NULL;
   l_init_msg_list                      VARCHAR2(200)   := okc_api.g_true;
   l_tot_rows_processed                 NUMBER          := 0;
   l_tot_rows_failed                    NUMBER          := 0;
   l_tot_rows_warned                    NUMBER          := 0;
   l_part_rows_processed                NUMBER          := 0;
   l_part_rows_failed                   NUMBER          := 0;
   l_part_rows_warned                   NUMBER          := 0;
   l_bulk_failed                        VARCHAR2(1)     := 'Y';

-- Variables for relationships interface
   rinf_interface_id_tbl                 l_rinf_interface_id ;
   rinf_batch_number_tbl                 l_rinf_batch_number ;
   rinf_object_version_number_tbl        l_rinf_object_version_number ;
   rinf_source_article_title_tbl         l_rinf_source_article_title ;
   rinf_target_article_title_tbl         l_rinf_target_article_title ;
   rinf_org_id_tbl                       l_rinf_org_id ;
   rinf_relationship_type_tbl            l_rinf_relationship_type ;
   rinf_process_status_tbl               l_rinf_process_status ;
   rinf_action_tbl                       l_rinf_action ;

   rinf_source_article_id_tbl            l_rinf_source_article_id ;
   rinf_source_intent_tbl                l_rinf_source_intent ;
   rinf_target_article_id_tbl            l_rinf_target_article_id ;
   rinf_target_intent_tbl                l_rinf_target_intent ;

   I NUMBER := 0;
   j NUMBER := 0;
   k NUMBER := 0;
   x NUMBER := 0;
   l_program_id                         OKC_ART_RELS_INTERFACE.PROGRAM_ID%TYPE;
   l_program_login_id                   OKC_ART_RELS_INTERFACE.PROGRAM_LOGIN_ID%TYPE;
   l_program_appl_id                    OKC_ART_RELS_INTERFACE.PROGRAM_APPLICATION_ID%TYPE;
   l_request_id                         OKC_ART_RELS_INTERFACE.REQUEST_ID%TYPE;
   l_dummy     VARCHAR2(1) := '2';
   l_dummy1    VARCHAR2(1) := '3';
   l_clause    VARCHAR2(1) := NULL;
   l_tmp_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;

   l_source_provision VARCHAR2(1);
   l_target_provision VARCHAR2(1);

BEGIN
IF (l_debug = 'Y') THEN
  okc_debug.log('100: Entered relationships_import', 2);
END IF;

------------------------------------------------------------------------
--  Variable Initialization
-------------------------------------------------------------------------


-- Standard Start of API savepoint
FND_MSG_PUB.initialize;
--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_return_status := G_RET_STS_SUCCESS;
--  Cache user_id, login_id and org_id
l_user_id  := Fnd_Global.user_id;
l_login_id := Fnd_Global.login_id;
-- MOAC
G_CURRENT_ORG_ID := mo_global.get_current_org_id();
/*
  OPEN cur_org_csr;
  FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
  CLOSE cur_org_csr;
*/

-- MOAC
IF G_CURRENT_ORG_ID IS NULL THEN
   OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_ART_NULL_ORG_ID');
   RAISE FND_API.G_EXC_ERROR ;
END IF;

IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
   l_program_id := NULL;
ELSE
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
END IF;

IF FND_GLOBAL.CONC_LOGIN_ID = -1 THEN
   l_program_login_id := NULL;
ELSE
   l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
END IF;

IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
   l_program_appl_id := NULL;
ELSE
   l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
END IF;

IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
   l_request_id := NULL;
ELSE
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
END IF;

l_batch_process_id := p_batch_procs_id;
-------------------------------------------------------------------------
--------------- the outermost loop of this procedure --------------------
-- Bulk fetch all interface rows based on the fetchsize passedby the user
-------------------------------------------------------------------------
l_context :='BULK FETCH RELATIONSHIP INTERFACE ROW';
OPEN l_rel_interface_csr ( G_CURRENT_ORG_ID,p_batch_number );
LOOP
BEGIN
    FETCH l_rel_interface_csr BULK COLLECT INTO
          rinf_interface_id_tbl                  ,
          rinf_batch_number_tbl                  ,
          rinf_object_version_number_tbl         ,
          rinf_source_article_title_tbl         ,
          rinf_target_article_title_tbl         ,
          rinf_org_id_tbl         ,
          rinf_relationship_type_tbl         ,
          rinf_process_status_tbl                ,
          rinf_action_tbl                        ,
          rinf_source_intent_tbl                 ,
          rinf_source_article_id_tbl             ,
          rinf_target_intent_tbl                 ,
          rinf_target_article_id_tbl    LIMIT p_fetchsize;
    EXIT WHEN rinf_interface_id_tbl.COUNT = 0 ;

    ------------------------------------------------------------------------
    -- Variable initialization
    -------------------------------------------------------------------------
    --For each fetch, relationship variable table index should be initialized
    j := 1;
    --##count:initialization
    l_tot_rows_processed    := l_tot_rows_processed+l_part_rows_processed;
    l_tot_rows_failed       := l_tot_rows_failed+l_part_rows_failed;
    l_tot_rows_warned       := l_tot_rows_warned+l_part_rows_warned;
    l_part_rows_processed   := 0;
    l_part_rows_failed      := 0;
    l_part_rows_warned      := 0;
    l_bulk_failed           := 'N';
    ---------------------------------------------------------------------------
    --------------------- Inner Loop thru fetched rows for---------------------
    -- validation, parse and validate article text, create a variable list
    -- prepare rows for DML if validate_only is 'N'
    /***  Processing Rule to set process_status
    Because we want to collect as much info as possible, we need to
    maintain process status while keeping the process moving.
    So, we'll set l_return_status as validation goes on and
    at the end we will set inf_process_status_tbl(i) with l_return_status
    for final result.  However, we will get out of this process if there
    is a significant error such as 'U'.
    The return status examined
    -api_return_status : return status for api call
    -l_return_status : validation result of each row
    -x_return_status : final result status for concurrent program request
    Rule to set return status
    If api_return_status for api call is
    * 'S' then continue
    * 'W' and l_return_status not 'E' or 'U' then set l_return_status = 'W'
        and build_error_array then continue
    * 'E' and it is significant then set l_return_status = 'E' and raise
      Exception
    * 'E' and it is minor then set l_return_status = 'E' and continue. Raise
       'E' at the end of validation
    * 'U' then set l_return_status = 'U' and raise 'U' exception
    * At the end, if it goes thru with no Exception,
    Check if l_return_status is 'E' then raise Exception
       Otherwise (meaning l_return_status is 'S' or 'W'),
         rinf_process_status_tbl(i) = l_return_status
    * In the exception, we will set
         rinf_process_status_tbl(i) = l_return_status and build_error_array
    ***/
    -------------------------------------------------------------------------

    FOR i in rinf_interface_id_tbl.FIRST ..rinf_interface_id_tbl.LAST LOOP
      BEGIN
      -- Increment total processed rows
      --##Count
      l_part_rows_processed := l_part_rows_processed+1;
      -- Initialization for each iteration
      l_row_notfound       := FALSE;
      l_return_status      := G_RET_STS_SUCCESS;

      l_context := 'RELATIONSHIP VALIDATING';

      -- To find duplicate relationship in the batch
      IF i>1 THEN
         x := i-1;
         IF (RTRIM(rinf_source_article_title_tbl(i)) = RTRIM(rinf_source_article_title_tbl(x))) AND
            (RTRIM(rinf_target_article_title_tbl(i)) = RTRIM(rinf_target_article_title_tbl(x)))
	    THEN
            Okc_Api.Set_Message(G_APP_NAME,
		                      'OKC_REL_DUP_TITLE_ORG',
						  'CLAUSE1',
						  rinf_source_article_title_tbl(i),
						  'CLAUSE2',
						  rinf_target_article_title_tbl(i));
            l_return_status := G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      -- Logic to decide what to do in case of Action='S'

	 IF rinf_action_tbl(i) = 'S' THEN
	    rinf_action_tbl(i) := 'N';
	 END IF;


      IF rinf_action_tbl(i) = 'N' THEN

          --TRIM trailing space because
          rinf_source_article_title_tbl(i) := RTRIM(rinf_source_article_title_tbl(i));
          rinf_target_article_title_tbl(i) := RTRIM(rinf_target_article_title_tbl(i));


        IF rinf_source_article_id_tbl(i) is NULL THEN
	        IF p_validate_only = 'Y' THEN
                OPEN clause_exists_csr (rinf_source_article_title_tbl(i),
			                         rinf_org_id_tbl(i),
		                              rinf_batch_number_tbl(i));
	           FETCH clause_exists_csr into l_clause;
	           CLOSE clause_exists_csr;
		      IF l_clause is null THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_SOURCE_ART_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => rinf_source_article_title_tbl(i));
                l_return_status := G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR ;
			 ELSE
		      -- Reset Local Variables
			 l_clause := NULL;
		      END IF;
	        ELSE
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_SOURCE_ART_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => rinf_source_article_title_tbl(i));
              l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;
        END IF;

        IF rinf_target_article_id_tbl(i) is NULL THEN
	        IF p_validate_only = 'Y' THEN
                OPEN clause_exists_csr (rinf_target_article_title_tbl(i),
			                         rinf_org_id_tbl(i),
		                              rinf_batch_number_tbl(i));
	           FETCH clause_exists_csr into l_clause;
	           CLOSE clause_exists_csr;
		      IF l_clause is null THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_TARGET_ART_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => rinf_target_article_title_tbl(i));
                l_return_status := G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR ;
			 ELSE
		      -- Reset Local Variables
			 l_clause := NULL;
		      END IF;
	        ELSE
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_TARGET_ART_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => rinf_target_article_title_tbl(i));
              l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;
       END IF;



/*        IF rinf_source_article_id_tbl(i) is NULL THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_SOURCE_ART_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => rinf_source_article_title_tbl(i));
              l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;

          IF rinf_target_article_id_tbl(i) is NULL THEN
                Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_TARGET_ART_NOT_FOUND',
                      p_token1       => 'ARTICLE_TITLE',
                      p_token1_value => rinf_target_article_title_tbl(i));
              l_return_status := G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;
          END IF;
*/
      ELSIF rinf_action_tbl(i) = 'D' THEN

      -- Check Relationship already exists or not
         OPEN  l_rel_exist_csr(rinf_source_article_id_tbl(i),
                               rinf_target_article_id_tbl(i),
                               rinf_org_id_tbl(i),
						 rinf_relationship_type_tbl(i));
	    FETCH l_rel_exist_csr into l_dummy;
	    CLOSE l_rel_exist_csr;
	    IF l_dummy <> '1' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_REL_NOT_EXIST',
						  p_token1   => 'ARTICLE1',
						  p_token1_value => rinf_source_article_title_tbl(i),
						  p_token2   => 'ARTICLE2',
						  p_token2_value => rinf_target_article_title_tbl(i)
						  );
		  -- Reset local variable
	       l_dummy := NULL;
            l_return_status := G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR ;

         END IF;
      ELSE

          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_REL_INV_IMP_ACTION');
          l_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR ;
      END IF;

      -----------------------------------------------------------
      -- Common validation or attribute settting
      -- regardless of status and import action
      -- this validation is not included in validate api
      -----------------------------------------------------------
      IF rinf_action_tbl(i) = 'N' THEN

	 -- Check Source Article and Target Article should not be same

          IF rinf_target_article_id_tbl(i)  = rinf_source_article_id_tbl(i) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_IMP_SAME_ART_RELTNSHP',
						  p_token1   => 'ARTICLE1',
						  p_token1_value => rinf_source_article_title_tbl(i));
            l_return_status := G_RET_STS_ERROR;
         END IF;

      -- Check Org id is valid org and EIT is defined for this org
         OPEN  l_org_valid_csr(rinf_org_id_tbl(i));
	    FETCH l_org_valid_csr into l_dummy1;
	    CLOSE l_org_valid_csr;
	    IF l_dummy1 <> '1' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_ORG_INVALID');
            l_return_status := G_RET_STS_ERROR;
         END IF;


      -- Check Relationship already exists or not
         OPEN  l_rel_exist_csr(rinf_source_article_id_tbl(i),
	                          rinf_target_article_id_tbl(i),
						 rinf_org_id_tbl(i),
						 rinf_relationship_type_tbl(i));
	    FETCH l_rel_exist_csr into l_dummy;
	    CLOSE l_rel_exist_csr;
	    IF l_dummy = '1' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_REL_EXIST',
						  p_token1   => 'ARTICLE1',
						  p_token1_value => rinf_source_article_title_tbl(i),
						  p_token2   => 'ARTICLE2',
						  p_token2_value => rinf_target_article_title_tbl(i));
            l_return_status := G_RET_STS_ERROR;
		  -- Reset local variable
	       l_dummy := NULL;
         END IF;

      -- Checking Relationship types
/*
        IF nvl(rinf_relationship_type_tbl(i), '*') not in ('ALTERNATE','INCOMPATIBLE') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_RELTYPE');
            l_return_status := G_RET_STS_ERROR;
      END IF;
*/
        IF rinf_relationship_type_tbl(i) IS NOT NULL THEN
	      l_tmp_return_status := okc_util.check_lookup_code('OKC_ARTICLE_RELATIONSHIP_TYPE',rinf_relationship_type_tbl(i));
           IF (l_tmp_return_status <> G_RET_STS_SUCCESS) THEN
		    Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'RELATIONSHIP_TYPE');
		    l_return_status := G_RET_STS_ERROR;
	      END IF;
	   END IF;

       -- Soruce Article and Target Article should have same intent
          IF rinf_target_intent_tbl(i)  <> rinf_source_intent_tbl(i) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_ART_NOT_SAME_INTENT',
						  p_token1   => 'ARTICLE1',
						  p_token1_value => rinf_source_article_title_tbl(i),
						  p_token2   => 'ARTICLE2',
						  p_token2_value => rinf_target_article_title_tbl(i));
            l_return_status := G_RET_STS_ERROR;
         END IF;
       -- Soruce Article and Target Article should have same provision flag
	   FOR source in l_provision_csr(rinf_source_article_id_tbl(i))
	   LOOP
	      l_source_provision := source.provision_yn;
           END LOOP;
	   FOR target in l_provision_csr(rinf_target_article_id_tbl(i))
	   LOOP
	      l_target_provision := target.provision_yn;
           END LOOP;
	   IF l_source_provision <> l_target_provision THEN
		   okc_Api.Set_Message(p_app_name => G_APP_NAME,
		                       p_msg_name => 'OKC_ART_IMP_PROVISION_RELATION',
						   p_token1   => 'ARTICLE1',
						   p_token1_value => rinf_source_article_title_tbl(i),
						   p_token2   => 'ARTICLE2',
						   p_token2_value => rinf_target_article_title_tbl(i));
		    l_return_status := G_RET_STS_ERROR;
	   END IF;

       END IF;
      ------------------------------------------------------------------------
      -- Now that we have validated and data is clean we can fetch sequences and ids
      -- for new relationships for DML and also set the process status to Success
      -------------------------------------------------------------------------

      -- Summarize report for this row
      -- Status 'F' is for internal use meaning parsing failure marked in
      -- java concurrent program
      IF (l_return_status = G_RET_STS_SUCCESS) THEN
         IF (nvl(rinf_process_status_tbl(i), 'E') = 'E') THEN
           rinf_process_status_tbl(i) := G_RET_STS_SUCCESS;
         ELSIF ( rinf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           rinf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = l_sts_warning) THEN
         IF (nvl(rinf_process_status_tbl(i),'E') = 'E') THEN
           rinf_process_status_tbl(i) := l_sts_warning;
           --##count
           --l_tot_rows_warned := l_tot_rows_warned+1;
           l_part_rows_warned := l_part_rows_warned+1;
         ELSIF (rinf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           rinf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop
    -- validation and unexpected errors
    -- In case of unexpected error, escape the loop
    -------------------------
    -------------------------


      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('300: In Relationships_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
              END IF;
              --l_return_status := G_RET_STS_ERROR ;
              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => rinf_interface_id_tbl(i),
                 p_article_title => rinf_source_article_title_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'RELATIONSHIP'
                );
               rinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
               -- Continue to next row

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('400: Leaving Relationships_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
              END IF;

              IF l_rel_interface_csr%ISOPEN THEN
                 CLOSE l_rel_interface_csr;
              END IF;

              --Set_Message
              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => rinf_interface_id_tbl(i),
                 p_article_title => rinf_source_article_title_tbl(i),
                 p_error_type    => G_RET_STS_UNEXP_ERROR,
			  p_entity        => 'RELATIONSHIP'
                 );
               rinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit; -- exit the current fetch

          WHEN OTHERS THEN
              IF (l_debug = 'Y') THEN
                okc_debug.log('500: Leaving Relationships_Import because of EXCEPTION: '||sqlerrm, 2);
              END IF;

              IF l_rel_interface_csr%ISOPEN THEN
                 CLOSE l_rel_interface_csr;
              END IF;

              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_UNEXPECTED_ERROR,
                                p_token1       => G_SQLCODE_TOKEN,
                                p_token1_value => sqlcode,
                                p_token2       => G_SQLERRM_TOKEN,
                                p_token2_value => sqlerrm);

              build_error_array(
                 p_msg_data     => G_UNEXPECTED_ERROR,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => rinf_interface_id_tbl(i),
                 p_article_title => rinf_source_article_title_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'RELATIONSHIP'
                );
               rinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit;  -- exit the current fetch
          END;
    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop ends
    -------------------------
    -------------------------


     END LOOP; -- end of FOR i in inf_interface_id_tbl.FIRST ..
    ------------------------------------------------------------------------
    -------------- End of Inner Loop thru fetched row for---------------------
    -- validation
    -------------------------------------------------------------------------
    -- In order to propagate Unexpected error raise it if it is 'U'
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -------------------------
    -------------------------
    -- Exception Block for Inner Loop starts
    -- Handles unexpected errors as last step
    -------------------------
    -------------------------
    EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF (l_debug = 'Y') THEN
                okc_debug.log('400: Leaving Relationships_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
             END IF;

             IF l_rel_interface_csr%ISOPEN THEN
                CLOSE l_rel_interface_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop

        WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Relationships_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;

             IF l_rel_interface_csr%ISOPEN THEN
                CLOSE l_rel_interface_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop
     END;

    -------------------------
    -------------------------
    -- Exception Block for Each Iteration of outermost Loop ends
    -------------------------
    -------------------------

    ------------------------------------------------------------------------
    --------------------- Start Do_DML for Relationships   ---------------
    -- Insert or Update Relationships
    -------------------------------------------------------------------------
    -- initialize l_return_status to track status of DML execution
     l_return_status := G_RET_STS_SUCCESS;


    IF p_validate_only = 'N' THEN
         BEGIN
         SAVEPOINT bulkdml;

         i := 0;
        -- Bulk insert New Valid Records
         BEGIN
         l_context := 'INSERTING FIRST NEW RELATIONSHIP INTO TABLE';

           FORALL  i in rinf_interface_id_tbl.FIRST ..rinf_interface_id_tbl.LAST
            INSERT INTO OKC_ARTICLE_RELATNS_ALL(
             SOURCE_ARTICLE_ID,
             TARGET_ARTICLE_ID,
             ORG_ID,
             RELATIONSHIP_TYPE,
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE)
           SELECT
             rinf_source_article_id_tbl(i),
             rinf_target_article_id_tbl(i),
             rinf_org_id_tbl(i),
             rinf_relationship_type_tbl(i),
	     1.0,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate
           FROM DUAL
           WHERE rinf_action_tbl(i)  = 'N' and
                 rinf_process_status_tbl(i)  in ('S', 'W')  ;


   FORALL  i in rinf_interface_id_tbl.FIRST ..rinf_interface_id_tbl.LAST
            INSERT INTO OKC_ARTICLE_RELATNS_ALL(
             TARGET_ARTICLE_ID,
             SOURCE_ARTICLE_ID,
	     ORG_ID,
	     RELATIONSHIP_TYPE,
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE)
           SELECT
             rinf_source_article_id_tbl(i),
             rinf_target_article_id_tbl(i),
             rinf_org_id_tbl(i),
             rinf_relationship_type_tbl(i),
		   1.0,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             sysdate
           FROM DUAL
           WHERE rinf_action_tbl(i)  = 'N' and
                 rinf_process_status_tbl(i)  in ('S', 'W')  ;
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Relationships_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
          END;

         --
         --  End of Insert into OKC_ARTICLE_RELATNS_ALL
         --
         --


         i := 0;
        -- Bulk delete Valid Records
         BEGIN
         l_context := 'DELETE RELATIONSHIP FROM TABLE';

           FORALL  i in rinf_interface_id_tbl.FIRST ..rinf_interface_id_tbl.LAST
            DELETE FROM OKC_ARTICLE_RELATNS_ALL
            WHERE
             SOURCE_ARTICLE_ID = rinf_source_article_id_tbl(i) AND
             TARGET_ARTICLE_ID = rinf_target_article_id_tbl(i) AND
             ORG_ID = rinf_org_id_tbl(i) AND
             RELATIONSHIP_TYPE = rinf_relationship_type_tbl(i) AND
             rinf_action_tbl(i)  = 'D' AND
             rinf_process_status_tbl(i)  in ('S', 'W')  ;


           FORALL  i in rinf_interface_id_tbl.FIRST ..rinf_interface_id_tbl.LAST
             DELETE FROM OKC_ARTICLE_RELATNS_ALL
	     WHERE
	     TARGET_ARTICLE_ID = rinf_source_article_id_tbl(i) AND
	     SOURCE_ARTICLE_ID = rinf_target_article_id_tbl(i) AND
	     ORG_ID = rinf_org_id_tbl(i) AND
	     RELATIONSHIP_TYPE = rinf_relationship_type_tbl(i) AND
	     rinf_action_tbl(i)  = 'D' AND
	     rinf_process_status_tbl(i)  in ('S', 'W')  ;

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Relationships_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
          END;

         --
         --  End of Delete from OKC_ARTICLE_RELATNS_ALL
         --
         --



      -- Exception for bulk DML block
      EXCEPTION
        WHEN OTHERS THEN
             l_bulk_failed := 'Y'; -- indicating that bulk operation has failed
              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_UNEXPECTED_ERROR,
                                  p_token1       => G_SQLCODE_TOKEN,
                                  p_token1_value => sqlcode,
                                  p_token2       => G_SQLERRM_TOKEN,
                                  p_token2_value => sqlerrm);
              Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKC_ART_FETCH_FAILED',
                                  p_token1       => 'CONTEXT',
                                  p_token1_value => l_context);

              build_error_array(
                                 p_msg_data     => null,
                                 p_context      => l_context,
                                 p_batch_process_id => l_batch_process_id,
                                 p_interface_id  => -99,
                                 p_article_title => NULL,
                                 p_error_type    => G_RET_STS_ERROR,
						   p_entity        => 'RELATIONSHIP'
              );
              l_return_status := G_RET_STS_UNEXP_ERROR;
              x_return_status := G_RET_STS_UNEXP_ERROR;

              --##count:rollback the count
              l_part_rows_failed := l_part_rows_processed;
              l_part_rows_warned := 0;

              ROLLBACK TO SAVEPOINT bulkdml;
              exit; -- exit outermost loop
      END;

    END IF; --- validate_only = 'N'

    ------------------------------------------------------------------------
    --------------------- End of Do_DML for Relationships   ---------------
    -------------------------------------------------------------------------

    ------------------------------------------------------------------------
    --------------- Start of Do_DML for import related tables   ------------
    -- Update interface table
    -- Insert Errors into Error table
    -------------------------------------------------------------------------
    -- Update Interface Table
    i:=0;
    BEGIN
     l_context := 'UPDATING RELATIONSHIPS INTERFACE TABLE';
     FORALL i in rinf_interface_id_tbl.FIRST..rinf_interface_id_tbl.LAST
       UPDATE OKC_ART_RELS_INTERFACE
       SET
           -- We don't want to update process_status to 'S' or 'W' in validation_mode
           -- because it is not going to be picked up in next run if we do so
           PROCESS_STATUS = decode(p_validate_only||rinf_process_status_tbl(i)||l_bulk_failed,
                                               'NEN','E',
                                               'NSN','S',
                                               'NWN','W',
                                               'NEY','E',
                                               'NSY',NULL,
                                               'NWY',NULL,
                                               'YEY','E',
                                               'YEN','E',
                                               'NFY','E',
                                               'YFY','E',
                                               'NFN','E',
                                               'YFN','E',NULL),
           PROGRAM_ID                 = l_program_id,
           REQUEST_ID                 = l_request_id,
           PROGRAM_LOGIN_ID           = l_program_login_id,
           PROGRAM_APPLICATION_ID     = l_program_appl_id,
           OBJECT_VERSION_NUMBER      = rinf_object_version_number_tbl(i) + 1,
           LAST_UPDATED_BY            = l_user_id,
           LAST_UPDATE_LOGIN          = l_login_id,
           LAST_UPDATE_DATE           = SYSDATE
         WHERE
           interface_id = rinf_interface_id_tbl(i);
    EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Relationships_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;
             Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
             Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_REL_INT_UPDATE_FAILED');
             build_error_array(
                       p_msg_data     => null,
                       p_context      => l_context,
                       p_batch_process_id => l_batch_process_id,
                       p_interface_id  => -99,
                       p_article_title => NULL,
                       p_error_type    => G_RET_STS_ERROR,
				   p_entity        => 'RELATIONSHIP'
             );

		      l_return_status := G_RET_STS_UNEXP_ERROR ;
		      x_return_status := G_RET_STS_UNEXP_ERROR ;
		       --##count:rollback the count
		      l_part_rows_failed := l_part_rows_processed;
		      l_part_rows_warned := 0;

             --RAISE FND_API.G_EXC_ERROR ;
  END;
   --
   -- End of Update OKC_RELATIONSHIPS_INTERFACE
   --
   --

    --
    --Insert Errors into Error table for this fetch
    --
    insert_error_array(
     x_return_status => x_return_status,
     x_msg_count     => x_msg_count,
     x_msg_data      => x_msg_data
    );


    IF (x_return_status = l_insert_errors_error) THEN
      NULL;
     -- Ignore
     -- RAISE l_insert_errors_exception;
    END IF;

    ------------------------------------------------------------------------
    --------------- End of Do_DML for import related tables   ------------
    -------------------------------------------------------------------------
    commit;

    -- Now delete cache for next bulk fetch

    rinf_interface_id_tbl.DELETE;
    rinf_batch_number_tbl.DELETE;
    rinf_object_version_number_tbl.DELETE;
    rinf_source_article_title_tbl.DELETE;
    rinf_target_article_title_tbl.DELETE;
    rinf_org_id_tbl.DELETE;
    rinf_relationship_type_tbl.DELETE;
    rinf_process_status_tbl.DELETE;
    rinf_action_tbl.DELETE;
    rinf_source_intent_tbl.DELETE;
    rinf_source_article_id_tbl.DELETE;
    rinf_target_intent_tbl.DELETE;
    rinf_target_article_id_tbl.DELETE;

    err_batch_process_id_tbl.DELETE;
    err_article_title_tbl.DELETE;
    err_interface_id_tbl.DELETE;
    err_error_number_tbl.DELETE;
    err_object_version_number_tbl.DELETE;
    err_error_type_tbl.DELETE;
    err_entity_tbl.DELETE;
    err_error_description_tbl.DELETE;

   EXIT WHEN l_rel_interface_csr%NOTFOUND;
END LOOP;


-----------------------------------------------------------------------
-- End of outermost loop for bulk fetch
-----------------------------------------------------------------------

IF l_rel_interface_csr%ISOPEN THEN
CLOSE l_rel_interface_csr;
END IF;


--##count:add up last processed counts
l_tot_rows_processed := l_tot_rows_processed + l_part_rows_processed;
l_tot_rows_failed := l_tot_rows_failed + l_part_rows_failed;
l_tot_rows_warned := l_tot_rows_warned + l_part_rows_warned;
/*****************
--Update Batch Process Table as a last step
UPDATE OKC_ART_INT_BATPROCS_ALL
SET
  TOTAL_ROWS_PROCESSED       = l_tot_rows_processed,
  TOTAL_ROWS_FAILED          = l_tot_rows_failed,
  TOTAL_ROWS_WARNED          = l_tot_rows_warned,
  END_DATE                   = SYSDATE,
  PROGRAM_ID                 = l_program_id,
  REQUEST_ID                 = l_request_id,
  PROGRAM_LOGIN_ID           = l_program_login_id,
  PROGRAM_APPLICATION_ID     = l_program_appl_id,
  OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
  LAST_UPDATED_BY            = l_user_id,
  LAST_UPDATE_LOGIN          = l_login_id,
  LAST_UPDATE_DATE           = SYSDATE
WHERE
  BATCH_PROCESS_ID  = l_batch_process_id
  AND ENTITY = 'Relationship' ;
*********************/

  p_rows_processed := l_tot_rows_processed;
  p_rows_failed := l_tot_rows_failed;
  p_rows_warned := l_tot_rows_warned;

IF err_error_number_tbl.COUNT > 0 THEN
 insert_error_array(
   x_return_status => x_return_status,
   x_msg_count     => x_msg_count,
   x_msg_data      => x_msg_data
 );
END IF;

-- Print statistic of this run in the log
-- Commented for new XML Based Import - Moved to new_wrap_up in conc_import_articles
--wrap_up(p_validate_only,p_batch_number,l_tot_rows_processed,l_tot_rows_failed,l_tot_rows_warned,l_batch_process_id,'RELATIONSHIP');
/*
      FND_MSG_PUB.initialize;
     Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_IMP_ERR');

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));

      FND_MSG_PUB.initialize;
*/
commit; -- Final commit for status update

IF (l_debug = 'Y') THEN
 okc_debug.log('2000: Leaving relationships import', 2);
END IF;
--x_return_status := l_return_status; this may cause to erase error x_return_status

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('3000: Leaving Relationships_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      x_return_status := G_RET_STS_ERROR ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('4000: Leaving Relationships_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any

      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;

      IF l_rel_interface_csr%ISOPEN THEN
         CLOSE l_rel_interface_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);

  WHEN l_insert_errors_exception THEN
      --
      -- In this exception handling, we don't insert error array again
      -- because error happend in the module
      --
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Relationships_Import because of EXCEPTION in insert_error_array: '||sqlerrm, 2);
      END IF;

      IF l_rel_interface_csr%ISOPEN THEN
         CLOSE l_rel_interface_csr;
      END IF;


      --x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);
      commit;

  WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Relationships_Import because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;
      --
      IF l_rel_interface_csr%ISOPEN THEN
         CLOSE l_rel_interface_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
 get_print_msgs_stack(p_msg_data => x_msg_data);
END import_relationships;

PROCEDURE import_fnd_flex_value_sets(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100
   ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'import_fnd_flex_value_sets';
    l_sts_warning                 CONSTANT VARCHAR2(1) := 'W';
    l_row_notfound                BOOLEAN := FALSE;
    l_user_id                     NUMBER;
    l_login_id                    NUMBER;
    l_insert_errors_exception     EXCEPTION;
    l_insert_errors_error         CONSTANT VARCHAR2(1) := 'X';

    CURSOR l_valset_interface_csr ( cp_batch_number IN VARCHAR2) IS
      SELECT
           VSINT.INTERFACE_ID           ,
           VSINT.BATCH_NUMBER           ,
           VSINT.OBJECT_VERSION_NUMBER  ,
           VSINT.FLEX_VALUE_SET_NAME    ,
           VSINT.VALIDATION_TYPE        ,
           VSINT.PROCESS_STATUS         ,
           VSINT.ACTION                 ,
           VSINT.FORMAT_TYPE            ,
           VSINT.MAXIMUM_SIZE           ,
           VSINT.DESCRIPTION            ,
           VSINT.MINIMUM_VALUE          ,
           VSINT.MAXIMUM_VALUE          ,
           VSINT.NUMBER_PRECISION       ,
           VSINT.UPPERCASE_ONLY_FLAG    ,
           VSINT.NUMBER_ONLY_FLAG
      FROM OKC_VALUESETS_INTERFACE VSINT
      WHERE nvl(PROCESS_STATUS,'*') NOT IN ('W', 'S')
         AND BATCH_NUMBER = cp_batch_number
      ORDER BY VSINT.FLEX_VALUE_SET_NAME ASC;

-- Flex Valuesets Interface Rows

    TYPE l_vsinf_interface_id             IS TABLE OF OKC_VALUESETS_INTERFACE.INTERFACE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_batch_number             IS TABLE OF OKC_VALUESETS_INTERFACE.BATCH_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_obj_ver_number    IS TABLE OF OKC_VALUESETS_INTERFACE.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_flex_value_set_name      IS TABLE OF OKC_VALUESETS_INTERFACE.FLEX_VALUE_SET_NAME%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_validation_type          IS TABLE OF OKC_VALUESETS_INTERFACE.VALIDATION_TYPE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_process_status           IS TABLE OF OKC_VALUESETS_INTERFACE.PROCESS_STATUS%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_action                   IS TABLE OF OKC_VALUESETS_INTERFACE.ACTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_format_type              IS TABLE OF OKC_VALUESETS_INTERFACE.FORMAT_TYPE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_maximum_size             IS TABLE OF OKC_VALUESETS_INTERFACE.MAXIMUM_SIZE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_description              IS TABLE OF OKC_VALUESETS_INTERFACE.DESCRIPTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_minimum_value            IS TABLE OF OKC_VALUESETS_INTERFACE.MINIMUM_VALUE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_maximum_value            IS TABLE OF OKC_VALUESETS_INTERFACE.MAXIMUM_VALUE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_number_precision         IS TABLE OF OKC_VALUESETS_INTERFACE.NUMBER_PRECISION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_uppercase_only_flag      IS TABLE OF OKC_VALUESETS_INTERFACE.UPPERCASE_ONLY_FLAG%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vsinf_number_only_flag         IS TABLE OF OKC_VALUESETS_INTERFACE.NUMBER_ONLY_FLAG%TYPE INDEX BY BINARY_INTEGER ;



   l_return_status                      VARCHAR2(1);
   l_error_index                        NUMBER          := 1;
   l_batch_process_id                   NUMBER          := 1;
   l_context                            VARCHAR2(50)    := NULL;
   l_init_msg_list                      VARCHAR2(200)   := okc_api.g_true;
   l_tot_rows_processed                 NUMBER          := 0;
   l_tot_rows_failed                    NUMBER          := 0;
   l_tot_rows_warned                    NUMBER          := 0;
   l_part_rows_processed                NUMBER          := 0;
   l_part_rows_failed                   NUMBER          := 0;
   l_part_rows_warned                   NUMBER          := 0;
   l_bulk_failed                        VARCHAR2(1)     := 'Y';

-- Variables for flex value sets interface
   vsinf_interface_id_tbl                 l_vsinf_interface_id ;
   vsinf_batch_number_tbl                 l_vsinf_batch_number ;
   vsinf_obj_ver_number_tbl               l_vsinf_obj_ver_number ;
   vsinf_flex_value_set_name_tbl          l_vsinf_flex_value_set_name ;
   vsinf_validation_type_tbl              l_vsinf_validation_type ;
   vsinf_process_status_tbl               l_vsinf_process_status ;
   vsinf_action_tbl                       l_vsinf_action ;
   vsinf_format_type_tbl                  l_vsinf_format_type ;
   vsinf_maximum_size_tbl                 l_vsinf_maximum_size ;
   vsinf_description_tbl                  l_vsinf_description ;
   vsinf_minimum_value_tbl                l_vsinf_minimum_value ;
   vsinf_maximum_value_tbl                l_vsinf_maximum_value ;
   vsinf_number_precision_tbl             l_vsinf_number_precision ;
   vsinf_uppercase_only_flag_tbl          l_vsinf_uppercase_only_flag ;
   vsinf_number_only_flag_tbl             l_vsinf_number_only_flag ;


   I NUMBER := 0;
   j NUMBER := 0;
   k NUMBER := 0;
   x NUMBER := 0;
   l_program_id                         OKC_VALUESETS_INTERFACE.PROGRAM_ID%TYPE;
   l_program_login_id                   OKC_VALUESETS_INTERFACE.PROGRAM_LOGIN_ID%TYPE;
   l_program_appl_id                    OKC_VALUESETS_INTERFACE.PROGRAM_APPLICATION_ID%TYPE;
   l_request_id                         OKC_VALUESETS_INTERFACE.REQUEST_ID%TYPE;
   l_tmp_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;


BEGIN
IF (l_debug = 'Y') THEN
  okc_debug.log('100: Entered valueset_import', 2);
END IF;


------------------------------------------------------------------------
--  Variable Initialization
-------------------------------------------------------------------------

-- Standard Start of API savepoint
FND_MSG_PUB.initialize;
--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_return_status := G_RET_STS_SUCCESS;
--  Cache user_id, login_id and org_id
l_user_id  := Fnd_Global.user_id;
l_login_id := Fnd_Global.login_id;

IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
   l_program_id := NULL;
ELSE
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
END IF;

IF FND_GLOBAL.CONC_LOGIN_ID = -1 THEN
   l_program_login_id := NULL;
ELSE
   l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
END IF;

IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
   l_program_appl_id := NULL;
ELSE
   l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
END IF;

IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
   l_request_id := NULL;
ELSE
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
END IF;


l_batch_process_id := p_batch_procs_id;
-------------------------------------------------------------------------
--------------- the outermost loop of this procedure --------------------
-- Bulk fetch all interface rows based on the fetchsize passedby the user
-------------------------------------------------------------------------

l_context :='BULK FETCH FLEX VALUE SETS INTERFACE ROW';
OPEN l_valset_interface_csr ( p_batch_number );
LOOP
BEGIN
    FETCH l_valset_interface_csr BULK COLLECT INTO
          vsinf_interface_id_tbl                  ,
          vsinf_batch_number_tbl                  ,
          vsinf_obj_ver_number_tbl         ,
          vsinf_flex_value_set_name_tbl           ,
          vsinf_validation_type_tbl               ,
          vsinf_process_status_tbl                ,
          vsinf_action_tbl                        ,
          vsinf_format_type_tbl                   ,
          vsinf_maximum_size_tbl                  ,
          vsinf_description_tbl                   ,
          vsinf_minimum_value_tbl                 ,
          vsinf_maximum_value_tbl                 ,
          vsinf_number_precision_tbl              ,
          vsinf_uppercase_only_flag_tbl           ,
          vsinf_number_only_flag_tbl              LIMIT p_fetchsize;
    EXIT WHEN vsinf_interface_id_tbl.COUNT = 0 ;

    ------------------------------------------------------------------------
    -- Variable initialization
    -------------------------------------------------------------------------
    --For each fetch, valueset variable table index should be initialized
    j := 1;
    --##count:initialization
    l_tot_rows_processed    := l_tot_rows_processed+l_part_rows_processed;
    l_tot_rows_failed       := l_tot_rows_failed+l_part_rows_failed;
    l_tot_rows_warned       := l_tot_rows_warned+l_part_rows_warned;
    l_part_rows_processed   := 0;
    l_part_rows_failed      := 0;
    l_part_rows_warned      := 0;
    l_bulk_failed           := 'N';
    ---------------------------------------------------------------------------
    --------------------- Inner Loop thru fetched rows for---------------------
    -- validation, parse and validate article text, create a variable list
    -- prepare rows for DML if validate_only is 'N'
    /***  Processing Rule to set process_status
    Because we want to collect as much info as possible, we need to
    maintain process status while keeping the process moving.
    So, we'll set l_return_status as validation goes on and
    at the end we will set inf_process_status_tbl(i) with l_return_status
    for final result.  However, we will get out of this process if there
    is a significant error such as 'U'.
    The return status examined
    -api_return_status : return status for api call
    -l_return_status : validation result of each row
    -x_return_status : final result status for concurrent program request
    Rule to set return status
    If api_return_status for api call is
    * 'S' then continue
    * 'W' and l_return_status not 'E' or 'U' then set l_return_status = 'W'
        and build_error_array then continue
    * 'E' and it is significant then set l_return_status = 'E' and raise
      Exception
    * 'E' and it is minor then set l_return_status = 'E' and continue. Raise
       'E' at the end of validation
    * 'U' then set l_return_status = 'U' and raise 'U' exception
    * At the end, if it goes thru with no Exception,
    Check if l_return_status is 'E' then raise Exception
       Otherwise (meaning l_return_status is 'S' or 'W'),
          vsinf_process_status_tbl(i) = l_return_status
    * In the exception, we will set
          vsinf_process_status_tbl(i) = l_return_status and build_error_array
    ***/
    -------------------------------------------------------------------------

    FOR i in vsinf_interface_id_tbl.FIRST ..vsinf_interface_id_tbl.LAST LOOP
      BEGIN
      -- Increment total processed rows
      --##Count
      l_part_rows_processed := l_part_rows_processed+1;
      -- Initialization for each iteration
      l_row_notfound       := FALSE;
      l_return_status      := G_RET_STS_SUCCESS;

      l_context := 'VALUE SETS VALIDATING';

      -- To find duplicate value set in the batch
      IF i>1 THEN
         x := i-1;
         IF RTRIM(vsinf_flex_value_set_name_tbl(i)) = RTRIM(vsinf_flex_value_set_name_tbl(x))
	    THEN
            Okc_Api.Set_Message(G_APP_NAME, 'OKC_VALSET_DUP_TITLE','VALUESET',vsinf_flex_value_set_name_tbl(i));
            l_return_status := G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      -- Logic to decide what to do in case of Action='S'

	 IF vsinf_action_tbl(i) = 'S' THEN
	    vsinf_action_tbl(i) := 'N';
	 END IF;


      IF vsinf_action_tbl(i) = 'N' THEN

          --TRIM trailing space because
          vsinf_flex_value_set_name_tbl(i) := RTRIM(vsinf_flex_value_set_name_tbl(i));
         -- Need to do some  defaulting logic
	       IF vsinf_format_type_tbl(i) = 'N' THEN
		     vsinf_number_only_flag_tbl(i) := 'Y';
		     vsinf_uppercase_only_flag_tbl(i) := 'N';
            END IF;
	       IF vsinf_format_type_tbl(i) = 'C' THEN
		     vsinf_number_only_flag_tbl(i) := 'N';
            END IF;
	       IF vsinf_format_type_tbl(i) in ('X','Y') THEN
		     vsinf_uppercase_only_flag_tbl(i) := 'Y';
            END IF;
	       IF vsinf_format_type_tbl(i) = 'X' THEN
		     vsinf_maximum_size_tbl(i) := 11;
            END IF;
	       IF vsinf_format_type_tbl(i) = 'Y' THEN
		     vsinf_maximum_size_tbl(i) := 20;
            END IF;

      ELSE

          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_VALSET_INV_IMP_ACTION');
          l_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR ;
      END IF;

      -----------------------------------------------------------
      -- Common validation or attribute settting
      -- regardless of status and import action
      -- this validation is not included in validate api
      -----------------------------------------------------------
	 -- Check if value set already exists in the System

          IF Fnd_Flex_Val_Api.Valueset_Exists(vsinf_flex_value_set_name_tbl(i)) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_IMP_VALSET_EXIST',
						  p_token1   => 'VALUESET',
						  p_token1_value => vsinf_flex_value_set_name_tbl(i)
						  );
            l_return_status := G_RET_STS_ERROR;
            --RAISE FND_API.G_EXC_ERROR ;
         END IF;

      -- Check if format_type is set properly
	 -- 'N' for Numeric
	 -- 'C' for Character
	 -- 'X' for Standard Date in Canonical Format YYYY/MM/DD
	 -- 'Y' for Standard DateTime in Canonical Format YYYY/MM/DD HH24:MI:SS
	 -- For Standard Date , Default Max size is 11
	 -- For Standard DateTime , Default Max size is 12

      IF nvl(vsinf_format_type_tbl(i),'*') not in ('N','C','X','Y')  THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_FORMATTYPE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Check if Max Value and Min Value is passed then it is as per Format Type
      IF vsinf_minimum_value_tbl(i) IS NOT NULL THEN
	    IF NOT is_value_valid(vsinf_format_type_tbl(i),vsinf_minimum_value_tbl(i)) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_MINIMUM_VALUE');
            l_return_status := G_RET_STS_ERROR;

         END IF;
      END IF;

      IF vsinf_maximum_value_tbl(i) IS NOT NULL THEN
	    IF NOT is_value_valid(vsinf_format_type_tbl(i),vsinf_maximum_value_tbl(i)) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_MAXIMUM_VALUE');
            l_return_status := G_RET_STS_ERROR;
         END IF;
      END IF;
      -- Check Maximum Value is always greater than Mimium Value
      IF vsinf_minimum_value_tbl(i) IS NOT NULL AND
         vsinf_maximum_value_tbl(i) IS NOT NULL
	 THEN
         IF vsinf_format_type_tbl(i) = 'N' THEN
	      IF to_number(vsinf_minimum_value_tbl(i)) >=
		      to_number(vsinf_maximum_value_tbl(i)) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_RANGE');
            l_return_status := G_RET_STS_ERROR;
		 END IF;
         ELSIF vsinf_format_type_tbl(i) = 'C' THEN
	      IF vsinf_minimum_value_tbl(i) >= vsinf_maximum_value_tbl(i) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_RANGE');
            l_return_status := G_RET_STS_ERROR;
		 END IF;
         ELSIF vsinf_format_type_tbl(i) in ('X','Y') THEN
	      IF to_date(vsinf_minimum_value_tbl(i),'YYYY/MM/DD HH24:MI:SS') >=
		      to_date(vsinf_maximum_value_tbl(i),'YYYY/MM/DD HH24:MI:SS') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_RANGE');
            l_return_status := G_RET_STS_ERROR;
		 END IF;

	    END IF;
      END IF;

      -- Check if uppercase_only_flag is set properly
      IF vsinf_uppercase_only_flag_tbl(i) not in ('Y','N') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_UPPERCASE_FLAG');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Check if number_only_flag is set properly
      IF vsinf_number_only_flag_tbl(i) not in ('Y','N') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_NUMBERONLY_FLAG');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Check if format_type and number_only_flag is set properly
      IF vsinf_format_type_tbl(i) = 'N' AND
	    vsinf_number_only_flag_tbl(i)  = 'N' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_FORMATTYPE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Check if format_type and uppercase_only_flag is set properly
      IF vsinf_format_type_tbl(i) = 'N' AND
	    vsinf_uppercase_only_flag_tbl(i)  = 'Y' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_FORMATTYPE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Check if format_type and number_only_flag is set properly
      IF vsinf_format_type_tbl(i) = 'C' AND
	    (vsinf_uppercase_only_flag_tbl(i)  = 'Y' AND
	     vsinf_number_only_flag_tbl(i) = 'Y') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_FORMATTYPE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Check if format_type and maximum_size is set properly
      IF vsinf_format_type_tbl(i) = 'C' AND
	    vsinf_maximum_size_tbl(i)  > 999  THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_MAXIMUMSIZE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      -- Check if format_type and maximum_size is set properly
      IF vsinf_format_type_tbl(i) = 'N' AND
	        vsinf_maximum_size_tbl(i)  > 38  THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_MAXIMUMSIZE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

	 IF ( vsinf_number_precision_tbl(i) IS NOT NULL AND
	      vsinf_format_type_tbl(i) <> 'N') THEN
		 vsinf_number_precision_tbl(i) := NULL;
      END IF;
/*
      -- Check if alphanumeric_allowed_flag is set properly
      IF nvl(vsinf_alphanumeric_allowed_flag_tbl(i), '*') not in ('Y','N') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_ALPHANUMERIC_FLAG');
            l_return_status := G_RET_STS_ERROR;
      END IF;
*/
      -- Check if Validation Type is 'Independent' or 'None'
      IF nvl(vsinf_validation_type_tbl(i), '*') not in ('I','N') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_VALIDATION_TYPE');
            l_return_status := G_RET_STS_ERROR;
      END IF;

      ------------------------------------------------------------------------
      -- Now that we have validated and data is clean we can fetch sequences and ids
      -- for new relationships for DML and also set the process status to Success
      -------------------------------------------------------------------------

      -- Summarize report for this row
      -- Status 'F' is for internal use meaning parsing failure marked in
      -- java concurrent program
      IF (l_return_status = G_RET_STS_SUCCESS) THEN
         IF (nvl(vsinf_process_status_tbl(i), 'E') = 'E') THEN
           vsinf_process_status_tbl(i) := G_RET_STS_SUCCESS;
         ELSIF ( vsinf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           vsinf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = l_sts_warning) THEN
         IF (nvl(vsinf_process_status_tbl(i),'E') = 'E') THEN
           vsinf_process_status_tbl(i) := l_sts_warning;
           --##count
           --l_tot_rows_warned := l_tot_rows_warned+1;
           l_part_rows_warned := l_part_rows_warned+1;
         ELSIF (vsinf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           vsinf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop
    -- validation and unexpected errors
    -- In case of unexpected error, escape the loop
    -------------------------
    -------------------------


      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('300: In Fnd_flex_value_sets_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
              END IF;
              --l_return_status := G_RET_STS_ERROR ;
              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vsinf_interface_id_tbl(i),
                 p_article_title => vsinf_flex_value_set_name_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'VALUESET'
                );
               vsinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
               -- Continue to next row

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('400: Leaving Fnd_flex_value_sets_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
              END IF;

              IF l_valset_interface_csr%ISOPEN THEN
                 CLOSE l_valset_interface_csr;
              END IF;

              --Set_Message
              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vsinf_interface_id_tbl(i),
                 p_article_title => vsinf_flex_value_set_name_tbl(i),
                 p_error_type    => G_RET_STS_UNEXP_ERROR,
			  p_entity        => 'VALUESET'
                 );
               vsinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit; -- exit the current fetch

          WHEN OTHERS THEN
              IF (l_debug = 'Y') THEN
                okc_debug.log('500: Leaving Fnd_flex_value_sets_Import because of EXCEPTION: '||sqlerrm, 2);
              END IF;

              IF l_valset_interface_csr%ISOPEN THEN
                 CLOSE l_valset_interface_csr;
              END IF;

              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_UNEXPECTED_ERROR,
                                p_token1       => G_SQLCODE_TOKEN,
                                p_token1_value => sqlcode,
                                p_token2       => G_SQLERRM_TOKEN,
                                p_token2_value => sqlerrm);

              build_error_array(
                 p_msg_data     => G_UNEXPECTED_ERROR,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vsinf_interface_id_tbl(i),
                 p_article_title => vsinf_flex_value_set_name_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'VALUESET'
                );
               vsinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit;  -- exit the current fetch
          END;
    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop ends
    -------------------------
    -------------------------


     END LOOP; -- end of FOR i in inf_interface_id_tbl.FIRST ..
    ------------------------------------------------------------------------
    -------------- End of Inner Loop thru fetched row for---------------------
    -- validation
    -------------------------------------------------------------------------
    -- In order to propagate Unexpected error raise it if it is 'U'
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -------------------------
    -------------------------
    -- Exception Block for Inner Loop starts
    -- Handles unexpected errors as last step
    -------------------------
    -------------------------
    EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF (l_debug = 'Y') THEN
                okc_debug.log('400: Leaving Fnd_flex_value_sets_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
             END IF;

             IF l_valset_interface_csr%ISOPEN THEN
                CLOSE l_valset_interface_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop

        WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Fnd_flex_value_sets_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;

             IF l_valset_interface_csr%ISOPEN THEN
                CLOSE l_valset_interface_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop
     END;

    -------------------------
    -------------------------
    -- Exception Block for Each Iteration of outermost Loop ends
    -------------------------
    -------------------------

    ------------------------------------------------------------------------
    --------------------- Start Do_DML for Fnd Flex Value Sets   ---------------
    -- Insert Fnd Flex Value Sets
    -------------------------------------------------------------------------
    -- initialize l_return_status to track status of DML execution
     l_return_status := G_RET_STS_SUCCESS;


    IF p_validate_only = 'N' THEN
         BEGIN
         SAVEPOINT bulkdml;

         i := 0;
        -- Bulk insert New Valid Records
         BEGIN
         l_context := 'INSERTING NEW VALUESETS INTO TABLE';
           FOR  i in vsinf_interface_id_tbl.FIRST ..vsinf_interface_id_tbl.LAST LOOP

		  IF vsinf_action_tbl(i) = 'N' AND vsinf_process_status_tbl(i) in ('S','W') THEN
	     	   IF vsinf_validation_type_tbl(i) = 'N' THEN

                      -- Set the Session Mode
				  FND_FLEX_VAL_API.SET_SESSION_MODE('customer_data');

				  -- Call the API to create value set
                      FND_FLEX_VAL_API.CREATE_VALUESET_NONE(
		             VALUE_SET_NAME     => vsinf_flex_value_set_name_tbl(i),
		             DESCRIPTION        => vsinf_description_tbl(i),
	                  SECURITY_AVAILABLE => 'N',
		             ENABLE_LONGLIST    => 'N',
		             FORMAT_TYPE        => vsinf_format_type_tbl(i),
		             MAXIMUM_SIZE       => vsinf_maximum_size_tbl(i),
		             NUMBERS_ONLY       => vsinf_number_only_flag_tbl(i),
		             UPPERCASE_ONLY     => vsinf_uppercase_only_flag_tbl(i),
		             RIGHT_JUSTIFY_ZERO_FILL => 'N',
		             MIN_VALUE          => vsinf_minimum_value_tbl(i),
		             MAX_VALUE          => vsinf_maximum_value_tbl(i),
				   PRECISION          => vsinf_number_precision_tbl(i));

		        ELSIF vsinf_validation_type_tbl(i) = 'I' THEN

                      -- Set the Session Mode
				  FND_FLEX_VAL_API.SET_SESSION_MODE('customer_data');

				  -- Call the API to create value set
                      FND_FLEX_VAL_API.CREATE_VALUESET_INDEPENDENT(
		             VALUE_SET_NAME     => vsinf_flex_value_set_name_tbl(i),
		             DESCRIPTION        => vsinf_description_tbl(i),
	                  SECURITY_AVAILABLE => 'N',
		             ENABLE_LONGLIST    => 'N',
		             FORMAT_TYPE        => vsinf_format_type_tbl(i),
		             MAXIMUM_SIZE       => vsinf_maximum_size_tbl(i),
		             NUMBERS_ONLY       => vsinf_number_only_flag_tbl(i),
		             UPPERCASE_ONLY     => vsinf_uppercase_only_flag_tbl(i),
		             RIGHT_JUSTIFY_ZERO_FILL => 'N',
		             MIN_VALUE          => vsinf_minimum_value_tbl(i),
		             MAX_VALUE          => vsinf_maximum_value_tbl(i),
				   PRECISION          => vsinf_number_precision_tbl(i));

		        END IF;
		   END IF;
        END LOOP;

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Fnd_flex_value_sets_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

         --
         --  End of Insert into FND FLEX VALUE SETS
         --
         --


      -- Exception for bulk DML block
      EXCEPTION
        WHEN OTHERS THEN
             l_bulk_failed := 'Y'; -- indicating that bulk operation has failed
              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_UNEXPECTED_ERROR,
                                  p_token1       => G_SQLCODE_TOKEN,
                                  p_token1_value => sqlcode,
                                  p_token2       => G_SQLERRM_TOKEN,
                                  p_token2_value => sqlerrm);
              Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKC_ART_FETCH_FAILED',
                                  p_token1       => 'CONTEXT',
                                  p_token1_value => l_context);

              build_error_array(
                                 p_msg_data     => null,
                                 p_context      => l_context,
                                 p_batch_process_id => l_batch_process_id,
                                 p_interface_id  => -99,
                                 p_article_title => NULL,
                                 p_error_type    => G_RET_STS_ERROR,
						   p_entity        => 'VALUESET'
              );
              l_return_status := G_RET_STS_UNEXP_ERROR;
              x_return_status := G_RET_STS_UNEXP_ERROR;

              --##count:rollback the count
              l_part_rows_failed := l_part_rows_processed;
              l_part_rows_warned := 0;

              ROLLBACK TO SAVEPOINT bulkdml;
              exit; -- exit outermost loop
      END;

    END IF; --- validate_only = 'N'

    ------------------------------------------------------------------------
    --------------------- End of Do_DML for Value sets   ---------------
    -------------------------------------------------------------------------

    ------------------------------------------------------------------------
    --------------- Start of Do_DML for import related tables   ------------
    -- Update interface table
    -- Insert Errors into Error table
    -------------------------------------------------------------------------
    -- Update Interface Table
    i:=0;
    BEGIN
     l_context := 'UPDATING VALUE SETS INTERFACE TABLE';
     FORALL i in vsinf_interface_id_tbl.FIRST..vsinf_interface_id_tbl.LAST
       UPDATE OKC_VALUESETS_INTERFACE
       SET
           -- We don't want to update process_status to 'S' or 'W' in validation_mode
           -- because it is not going to be picked up in next run if we do so
           PROCESS_STATUS = decode(p_validate_only||vsinf_process_status_tbl(i)||l_bulk_failed,
                                               'NEN','E',
                                               'NSN','S',
                                               'NWN','W',
                                               'NEY','E',
                                               'NSY',NULL,
                                               'NWY',NULL,
                                               'YEY','E',
                                               'YEN','E',
                                               'NFY','E',
                                               'YFY','E',
                                               'NFN','E',
                                               'YFN','E',NULL),
           PROGRAM_ID                 = l_program_id,
           REQUEST_ID                 = l_request_id,
           PROGRAM_LOGIN_ID           = l_program_login_id,
           PROGRAM_APPLICATION_ID     = l_program_appl_id,
           OBJECT_VERSION_NUMBER      = vsinf_obj_ver_number_tbl(i) + 1,
           LAST_UPDATED_BY            = l_user_id,
           LAST_UPDATE_LOGIN          = l_login_id,
           LAST_UPDATE_DATE           = SYSDATE
         WHERE
           interface_id = vsinf_interface_id_tbl(i);
    EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Fnd_flex_value_sets_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;

             Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
             Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_VALSET_INT_UPDATE_FAILED');

             build_error_array(
                       p_msg_data     => null,
                       p_context      => l_context,
                       p_batch_process_id => l_batch_process_id,
                       p_interface_id  => -99,
                       p_article_title => NULL,
                       p_error_type    => G_RET_STS_ERROR,
				   p_entity        => 'VALUESET'
             );

		      l_return_status := G_RET_STS_UNEXP_ERROR ;
		      x_return_status := G_RET_STS_UNEXP_ERROR ;
		       --##count:rollback the count
		      l_part_rows_failed := l_part_rows_processed;
		      l_part_rows_warned := 0;

             --RAISE FND_API.G_EXC_ERROR ;
  END;
   --
   -- End of Update OKC_VALUESETS_INTERFACE
   --
   --

    --
    --Insert Errors into Error table for this fetch
    --
    insert_error_array(
     x_return_status => x_return_status,
     x_msg_count     => x_msg_count,
     x_msg_data      => x_msg_data
    );


    IF (x_return_status = l_insert_errors_error) THEN
      NULL;
     -- Ignore
     -- RAISE l_insert_errors_exception;
    END IF;

    ------------------------------------------------------------------------
    --------------- End of Do_DML for import related tables   ------------
    -------------------------------------------------------------------------
    commit;

    -- Now delete cache for next bulk fetch

    vsinf_interface_id_tbl.DELETE;
    vsinf_batch_number_tbl.DELETE;
    vsinf_obj_ver_number_tbl.DELETE;
    vsinf_flex_value_set_name_tbl.DELETE;
    vsinf_validation_type_tbl.DELETE;
    vsinf_process_status_tbl.DELETE;
    vsinf_action_tbl.DELETE;
    vsinf_format_type_tbl.DELETE;
    vsinf_maximum_size_tbl.DELETE;
    vsinf_description_tbl.DELETE;
    vsinf_minimum_value_tbl.DELETE;
    vsinf_maximum_value_tbl.DELETE;
    vsinf_number_precision_tbl.DELETE;
    vsinf_uppercase_only_flag_tbl.DELETE;
    vsinf_number_only_flag_tbl.DELETE;

    err_batch_process_id_tbl.DELETE;
    err_article_title_tbl.DELETE;
    err_interface_id_tbl.DELETE;
    err_error_number_tbl.DELETE;
    err_object_version_number_tbl.DELETE;
    err_error_type_tbl.DELETE;
    err_entity_tbl.DELETE;
    err_error_description_tbl.DELETE;

   EXIT WHEN l_valset_interface_csr%NOTFOUND;
END LOOP;


-----------------------------------------------------------------------
-- End of outermost loop for bulk fetch
-----------------------------------------------------------------------

IF l_valset_interface_csr%ISOPEN THEN
CLOSE l_valset_interface_csr;
END IF;


--##count:add up last processed counts
l_tot_rows_processed := l_tot_rows_processed + l_part_rows_processed;
l_tot_rows_failed := l_tot_rows_failed + l_part_rows_failed;
l_tot_rows_warned := l_tot_rows_warned + l_part_rows_warned;

--Update Batch Process Table as a last step
UPDATE OKC_ART_INT_BATPROCS_ALL
SET
  TOTAL_ROWS_PROCESSED       = l_tot_rows_processed,
  TOTAL_ROWS_FAILED          = l_tot_rows_failed,
  TOTAL_ROWS_WARNED          = l_tot_rows_warned,
  END_DATE                   = SYSDATE,
  PROGRAM_ID                 = l_program_id,
  REQUEST_ID                 = l_request_id,
  PROGRAM_LOGIN_ID           = l_program_login_id,
  PROGRAM_APPLICATION_ID     = l_program_appl_id,
  OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
  LAST_UPDATED_BY            = l_user_id,
  LAST_UPDATE_LOGIN          = l_login_id,
  LAST_UPDATE_DATE           = SYSDATE
WHERE
  BATCH_PROCESS_ID  = l_batch_process_id
  AND ENTITY = 'Valueset';
IF err_error_number_tbl.COUNT > 0 THEN
 insert_error_array(
   x_return_status => x_return_status,
   x_msg_count     => x_msg_count,
   x_msg_data      => x_msg_data
 );
END IF;

-- Print statistic of this run in the log
-- Commented for new XML Based Import - Moved to new_wrap_up in conc_import_articles
--wrap_up(p_validate_only,p_batch_number,l_tot_rows_processed,l_tot_rows_failed,l_tot_rows_warned,l_batch_process_id,'VALUESET');
commit; -- Final commit for status update

IF (l_debug = 'Y') THEN
 okc_debug.log('2000: Leaving Fnd_flex_value_sets import', 2);
END IF;
--x_return_status := l_return_status; this may cause to erase error x_return_status

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('3000: Leaving Fnd_flex_value_sets_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      x_return_status := G_RET_STS_ERROR ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('4000: Leaving Fnd_flex_value_sets_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any

      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;

      IF l_valset_interface_csr%ISOPEN THEN
         CLOSE l_valset_interface_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);

  WHEN l_insert_errors_exception THEN
      --
      -- In this exception handling, we don't insert error array again
      -- because error happend in the module
      --
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Fnd_flex_value_sets_Import because of EXCEPTION in insert_error_array: '||sqlerrm, 2);
      END IF;

      IF l_valset_interface_csr%ISOPEN THEN
         CLOSE l_valset_interface_csr;
      END IF;


      --x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);
      commit;

  WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Fnd_flex_value_sets_Import because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;
      --
      IF l_valset_interface_csr%ISOPEN THEN
         CLOSE l_valset_interface_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
	 get_print_msgs_stack(p_msg_data => x_msg_data);
END import_fnd_flex_value_sets;

PROCEDURE import_fnd_flex_values(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100
   ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'import_fnd_flex_values';
    l_sts_warning                 CONSTANT VARCHAR2(1) := 'W';
    l_row_notfound                BOOLEAN := FALSE;
    l_user_id                     NUMBER;
    l_login_id                    NUMBER;
    l_insert_errors_exception     EXCEPTION;
    l_insert_errors_error         CONSTANT VARCHAR2(1) := 'X';

   CURSOR l_val_interface_csr ( cp_batch_number IN VARCHAR2) IS
      SELECT
           VINT.INTERFACE_ID           ,
           VINT.BATCH_NUMBER           ,
           VINT.OBJECT_VERSION_NUMBER  ,
           VINT.FLEX_VALUE_SET_NAME    ,
           VINT.FLEX_VALUE             ,
           VINT.PROCESS_STATUS         ,
           VINT.ACTION                 ,
           VINT.ENABLED_FLAG           ,
           VINT.START_DATE_ACTIVE      ,
           VINT.END_DATE_ACTIVE        ,
           VINT.LANGUAGE               ,
           VINT.DESCRIPTION            ,
           VINT.FLEX_VALUE_MEANING     ,
	   VS.FLEX_VALUE_SET_ID        ,
	   VS.VALIDATION_TYPE          ,
	   VS.FORMAT_TYPE              ,
	   VS.MAXIMUM_SIZE             ,
	   VS.NUMBER_PRECISION         ,
	   VS.ALPHANUMERIC_ALLOWED_FLAG,
	   VS.UPPERCASE_ONLY_FLAG      ,
	   VS.NUMERIC_MODE_ENABLED_FLAG,
	   VS.MINIMUM_VALUE            ,
	   VS.MAXIMUM_VALUE            ,
           TO_NUMBER(NULL) FLEX_VALUE_ID
      FROM OKC_VS_VALUES_INTERFACE VINT,FND_FLEX_VALUE_SETS VS
      WHERE VINT.FLEX_VALUE_SET_NAME = VS.FLEX_VALUE_SET_NAME
	    AND nvl(PROCESS_STATUS,'*') NOT IN ('W', 'S')
         AND BATCH_NUMBER = cp_batch_number
	 UNION ALL
      SELECT
           VINT.INTERFACE_ID           ,
           VINT.BATCH_NUMBER           ,
           VINT.OBJECT_VERSION_NUMBER  ,
           VINT.FLEX_VALUE_SET_NAME    ,
           VINT.FLEX_VALUE             ,
           VINT.PROCESS_STATUS         ,
           VINT.ACTION                 ,
           VINT.ENABLED_FLAG           ,
           VINT.START_DATE_ACTIVE      ,
           VINT.END_DATE_ACTIVE        ,
           VINT.LANGUAGE               ,
           VINT.DESCRIPTION            ,
           VINT.FLEX_VALUE_MEANING     ,
	      TO_NUMBER(NULL)  FLEX_VALUE_SET_ID        ,
	      VS.VALIDATION_TYPE          ,
	      VS.FORMAT_TYPE              ,
	      VS.MAXIMUM_SIZE             ,
	      VS.NUMBER_PRECISION         ,
	      TO_CHAR(NULL) ALPHANUMERIC_ALLOWED_FLAG,
	      VS.UPPERCASE_ONLY_FLAG      ,
	      VS.NUMBER_ONLY_FLAG NUMERIC_MODE_ENABLED_FLAG,
	      VS.MINIMUM_VALUE            ,
	      VS.MAXIMUM_VALUE            ,
           TO_NUMBER(NULL) FLEX_VALUE_ID
      FROM OKC_VS_VALUES_INTERFACE VINT,OKC_VALUESETS_INTERFACE VS
      WHERE VINT.FLEX_VALUE_SET_NAME = VS.FLEX_VALUE_SET_NAME (+)
         AND VINT.BATCH_NUMBER = VS.BATCH_NUMBER (+)
	    AND nvl(VS.PROCESS_STATUS,'*') NOT IN ('E')
         AND VINT.BATCH_NUMBER = cp_batch_number
	    AND NOT EXISTS
	    ( SELECT 1 FROM FND_FLEX_VALUE_SETS FVS
	      WHERE FVS.FLEX_VALUE_SET_NAME = VINT.FLEX_VALUE_SET_NAME)
      ORDER BY FLEX_VALUE_SET_NAME,FLEX_VALUE ASC;


    CURSOR l_val_exist_csr ( l_flex_value IN VARCHAR2, l_flex_value_set_id IN NUMBER ) IS
      SELECT
           B.FLEX_VALUE_SET_ID         ,
           B.FLEX_VALUE_ID             ,
           B.FLEX_VALUE                ,
           B.START_DATE_ACTIVE         ,
           B.END_DATE_ACTIVE
      FROM FND_FLEX_VALUES B,FND_FLEX_VALUES_TL T
      WHERE B.FLEX_VALUE_ID = T.FLEX_VALUE_ID
      AND   T.LANGUAGE = userenv('LANG')
      AND   B.FLEX_VALUE = l_flex_value
      AND   B.FLEX_VALUE_SET_ID = l_flex_value_set_id;

   -- Cursor to check valueset in the valueset interface Table
       CURSOR valset_exists_csr (cp_vs_name IN VARCHAR2,
                                 cp_batch_number IN VARCHAR2) IS
       SELECT '1'
       FROM OKC_VALUESETS_INTERFACE
       WHERE flex_value_set_name = cp_vs_name
       AND   batch_number = cp_batch_number
       AND   nvl(process_status,'X') not in ('E');


-- Flex Values Interface Rows

    TYPE l_vinf_interface_id             IS TABLE OF OKC_VS_VALUES_INTERFACE.INTERFACE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_batch_number             IS TABLE OF OKC_VS_VALUES_INTERFACE.BATCH_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_obj_ver_number           IS TABLE OF OKC_VS_VALUES_INTERFACE.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_flex_value_set_name      IS TABLE OF OKC_VS_VALUES_INTERFACE.FLEX_VALUE_SET_NAME%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_flex_value               IS TABLE OF OKC_VS_VALUES_INTERFACE.FLEX_VALUE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_process_status           IS TABLE OF OKC_VS_VALUES_INTERFACE.PROCESS_STATUS%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_action                   IS TABLE OF OKC_VS_VALUES_INTERFACE.ACTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_enabled_flag             IS TABLE OF OKC_VS_VALUES_INTERFACE.ENABLED_FLAG%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_start_date_active        IS TABLE OF OKC_VS_VALUES_INTERFACE.START_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_end_date_active          IS TABLE OF OKC_VS_VALUES_INTERFACE.END_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_language                 IS TABLE OF OKC_VS_VALUES_INTERFACE.LANGUAGE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_description              IS TABLE OF OKC_VS_VALUES_INTERFACE.DESCRIPTION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_flex_value_meaning       IS TABLE OF OKC_VS_VALUES_INTERFACE.FLEX_VALUE_MEANING%TYPE INDEX BY BINARY_INTEGER ;


    TYPE l_vinf_flex_value_id            IS TABLE OF FND_FLEX_VALUES.flex_value_id%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_value_set_id             IS TABLE OF FND_FLEX_VALUE_SETS.flex_value_set_id%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_validation_type          IS TABLE OF FND_FLEX_VALUE_SETS.VALIDATION_TYPE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_format_type              IS TABLE OF FND_FLEX_VALUE_SETS.FORMAT_TYPE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_maximum_size             IS TABLE OF FND_FLEX_VALUE_SETS.MAXIMUM_SIZE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_number_precision         IS TABLE OF FND_FLEX_VALUE_SETS.NUMBER_PRECISION%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_alphanum_allowed IS TABLE OF FND_FLEX_VALUE_SETS.ALPHANUMERIC_ALLOWED_FLAG%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_uppercase_only       IS TABLE OF FND_FLEX_VALUE_SETS.UPPERCASE_ONLY_FLAG%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_num_mode_enabled IS TABLE OF FND_FLEX_VALUE_SETS.NUMERIC_MODE_ENABLED_FLAG%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_maximum_value             IS TABLE OF FND_FLEX_VALUE_SETS.MAXIMUM_VALUE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_vinf_minimum_value             IS TABLE OF FND_FLEX_VALUE_SETS.MINIMUM_VALUE%TYPE INDEX BY BINARY_INTEGER ;


    TYPE l_vinf_flex_value_orig           IS TABLE OF OKC_VS_VALUES_INTERFACE.FLEX_VALUE%TYPE INDEX BY BINARY_INTEGER ;

   l_return_status                      VARCHAR2(1);
   l_error_index                        NUMBER          := 1;
   l_batch_process_id                   NUMBER          := 1;
   l_context                            VARCHAR2(50)    := NULL;
   l_init_msg_list                      VARCHAR2(200)   := okc_api.g_true;
   l_tot_rows_processed                 NUMBER          := 0;
   l_tot_rows_failed                    NUMBER          := 0;
   l_tot_rows_warned                    NUMBER          := 0;
   l_part_rows_processed                NUMBER          := 0;
   l_part_rows_failed                   NUMBER          := 0;
   l_part_rows_warned                   NUMBER          := 0;
   l_bulk_failed                        VARCHAR2(1)     := 'Y';

-- Variables for flex values interface
   vinf_interface_id_tbl                 l_vinf_interface_id ;
   vinf_batch_number_tbl                 l_vinf_batch_number ;
   vinf_obj_ver_number_tbl               l_vinf_obj_ver_number ;
   vinf_flex_value_set_name_tbl          l_vinf_flex_value_set_name ;
   vinf_flex_value_tbl                   l_vinf_flex_value ;
   vinf_process_status_tbl               l_vinf_process_status ;
   vinf_action_tbl                       l_vinf_action ;
   vinf_enabled_flag_tbl                 l_vinf_enabled_flag ;
   vinf_start_date_active_tbl            l_vinf_start_date_active ;
   vinf_end_date_active_tbl              l_vinf_end_date_active ;
   vinf_language_tbl                     l_vinf_language ;
   vinf_description_tbl                  l_vinf_description ;
   vinf_flex_value_meaning_tbl           l_vinf_flex_value_meaning ;

   vinf_flex_value_id_tbl                l_vinf_flex_value_id ;
   vinf_value_set_id_tbl                 l_vinf_value_set_id ;
   vinf_validation_type_tbl              l_vinf_validation_type ;
   vinf_format_type_tbl                  l_vinf_format_type ;
   vinf_maximum_size_tbl                 l_vinf_maximum_size ;
   vinf_number_precision_tbl             l_vinf_number_precision ;
   vinf_alphanum_allowed_tbl             l_vinf_alphanum_allowed ;
   vinf_uppercase_only_tbl               l_vinf_uppercase_only ;
   vinf_num_mode_enabled_tbl             l_vinf_num_mode_enabled ;
   vinf_maximum_value_tbl                l_vinf_maximum_value ;
   vinf_minimum_value_tbl                l_vinf_minimum_value ;

   --vinf_flex_value_orig_tbl              l_vinf_flex_value_orig ;

   I NUMBER := 0;
   j NUMBER := 0;
   k NUMBER := 0;
   x NUMBER := 0;
   l_program_id                         OKC_VS_VALUES_INTERFACE.PROGRAM_ID%TYPE;
   l_program_login_id                   OKC_VS_VALUES_INTERFACE.PROGRAM_LOGIN_ID%TYPE;
   l_program_appl_id                    OKC_VS_VALUES_INTERFACE.PROGRAM_APPLICATION_ID%TYPE;
   l_request_id                         OKC_VS_VALUES_INTERFACE.REQUEST_ID%TYPE;
   l_rowid                              ROWID;
   api_return_status                    VARCHAR2(1);
   l_tmp_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
   l_display_value    VARCHAR2(2000);
   l_storage_value    VARCHAR2(32000);


   l_flex_value_set_id NUMBER;
   l_flex_value_id     NUMBER;
   l_flex_value        VARCHAR2(150);
   l_start_date        DATE;
   l_end_date          DATE;
   l_vs_name           VARCHAR2(1) := NULL;


BEGIN
IF (l_debug = 'Y') THEN
  okc_debug.log('100: Entered values_import', 2);
END IF;


------------------------------------------------------------------------
--  Variable Initialization
-------------------------------------------------------------------------

-- Standard Start of API savepoint
FND_MSG_PUB.initialize;
--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_return_status := G_RET_STS_SUCCESS;
--  Cache user_id, login_id and org_id
l_user_id  := Fnd_Global.user_id;
l_login_id := Fnd_Global.login_id;

IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
   l_program_id := NULL;
ELSE
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
END IF;

IF FND_GLOBAL.CONC_LOGIN_ID = -1 THEN
   l_program_login_id := NULL;
ELSE
   l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
END IF;

IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
   l_program_appl_id := NULL;
ELSE
   l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
END IF;

IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
   l_request_id := NULL;
ELSE
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
END IF;


l_batch_process_id := p_batch_procs_id;
-------------------------------------------------------------------------
--------------- the outermost loop of this procedure --------------------
-- Bulk fetch all interface rows based on the fetchsize passedby the user
-------------------------------------------------------------------------

l_context :='BULK FETCH FLEX VALUES INTERFACE ROW';
OPEN l_val_interface_csr ( p_batch_number );
LOOP
BEGIN
    FETCH l_val_interface_csr BULK COLLECT INTO
          vinf_interface_id_tbl                  ,
          vinf_batch_number_tbl                  ,
          vinf_obj_ver_number_tbl                ,
          vinf_flex_value_set_name_tbl           ,
          vinf_flex_value_tbl                    ,
          vinf_process_status_tbl                ,
          vinf_action_tbl                        ,
          vinf_enabled_flag_tbl                  ,
          vinf_start_date_active_tbl             ,
          vinf_end_date_active_tbl               ,
          vinf_language_tbl                      ,
          vinf_description_tbl                   ,
          vinf_flex_value_meaning_tbl            ,
          vinf_value_set_id_tbl                  ,
          vinf_validation_type_tbl               ,
          vinf_format_type_tbl                   ,
          vinf_maximum_size_tbl                  ,
          vinf_number_precision_tbl              ,
          vinf_alphanum_allowed_tbl              ,
          vinf_uppercase_only_tbl                ,
          vinf_num_mode_enabled_tbl              ,
          vinf_maximum_value_tbl                 ,
          vinf_minimum_value_tbl                 ,
          vinf_flex_value_id_tbl    LIMIT p_fetchsize;
    EXIT WHEN vinf_interface_id_tbl.COUNT = 0 ;

    ------------------------------------------------------------------------
    -- Variable initialization
    -------------------------------------------------------------------------
    --For each fetch, value variable table index should be initialized
    j := 1;
    --##count:initialization
    l_tot_rows_processed    := l_tot_rows_processed+l_part_rows_processed;
    l_tot_rows_failed       := l_tot_rows_failed+l_part_rows_failed;
    l_tot_rows_warned       := l_tot_rows_warned+l_part_rows_warned;
    l_part_rows_processed   := 0;
    l_part_rows_failed      := 0;
    l_part_rows_warned      := 0;
    l_bulk_failed           := 'N';
    ---------------------------------------------------------------------------
    --------------------- Inner Loop thru fetched rows for---------------------
    -- validation, parse and validate article text, create a variable list
    -- prepare rows for DML if validate_only is 'N'
    /***  Processing Rule to set process_status
    Because we want to collect as much info as possible, we need to
    maintain process status while keeping the process moving.
    So, we'll set l_return_status as validation goes on and
    at the end we will set inf_process_status_tbl(i) with l_return_status
    for final result.  However, we will get out of this process if there
    is a significant error such as 'U'.
    The return status examined
    -api_return_status : return status for api call
    -l_return_status : validation result of each row
    -x_return_status : final result status for concurrent program request
    Rule to set return status
    If api_return_status for api call is
    * 'S' then continue
    * 'W' and l_return_status not 'E' or 'U' then set l_return_status = 'W'
        and build_error_array then continue
    * 'E' and it is significant then set l_return_status = 'E' and raise
      Exception
    * 'E' and it is minor then set l_return_status = 'E' and continue. Raise
       'E' at the end of validation
    * 'U' then set l_return_status = 'U' and raise 'U' exception
    * At the end, if it goes thru with no Exception,
    Check if l_return_status is 'E' then raise Exception
       Otherwise (meaning l_return_status is 'S' or 'W'),
          vinf_process_status_tbl(i) = l_return_status
    * In the exception, we will set
          vinf_process_status_tbl(i) = l_return_status and build_error_array
    ***/
    -------------------------------------------------------------------------

    FOR i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST LOOP
      BEGIN
      -- Increment total processed rows
      --##Count
      l_part_rows_processed := l_part_rows_processed+1;
      -- Initialization for each iteration
      l_row_notfound       := FALSE;
      l_return_status      := G_RET_STS_SUCCESS;

      l_context := 'VALUES VALIDATING';

      -- To find duplicate values in the same valueset in the batch
      IF i>1 THEN
         x := i-1;
         IF RTRIM(vinf_flex_value_set_name_tbl(i)) = RTRIM(vinf_flex_value_set_name_tbl(x)) AND
            RTRIM(vinf_flex_value_tbl(i)) = RTRIM(vinf_flex_value_tbl(x))
	    THEN
            Okc_Api.Set_Message(G_APP_NAME,
		                      'OKC_VALSET_VAL_DUP_TITLE',
						  'VALUE',
						  vinf_flex_value_tbl(i),
						  'VALSET',
						  vinf_flex_value_set_name_tbl(i)
						  );
            l_return_status := G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      -- Logic to decide what to do in case of Action='S'

	 IF vinf_action_tbl(i) = 'S' THEN
	    vinf_action_tbl(i) := 'N';
	 END IF;


	 IF vinf_action_tbl(i) = 'N' THEN
	 -- Check if value set already exists in the System
         IF NOT Fnd_Flex_Val_Api.Valueset_Exists(vinf_flex_value_set_name_tbl(i)) THEN
           IF p_validate_only = 'N' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_VALSET_NOT_EXISTS',
						  p_token1   => 'VALUE',
						  p_token1_value => vinf_flex_value_tbl(i),
						  p_token2   => 'VALSET',
						  p_token2_value => vinf_flex_value_set_name_tbl(i)
						  );
            l_return_status := G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
           ELSE
            IF vinf_validation_type_tbl(i) IS NULL AND vinf_format_type_tbl(i) IS NULL THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_VALSET_NOT_EXISTS',
						  p_token1   => 'VALUE',
						  p_token1_value => vinf_flex_value_tbl(i),
						  p_token2   => 'VALSET',
						  p_token2_value => vinf_flex_value_set_name_tbl(i)
						  );
            l_return_status := G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
		  END IF;
           END IF;
         END IF;
	 END IF;

      IF vinf_action_tbl(i) = 'N' THEN

          --TRIM trailing space because
          vinf_flex_value_set_name_tbl(i) := RTRIM(vinf_flex_value_set_name_tbl(i));
          vinf_flex_value_tbl(i) := RTRIM(vinf_flex_value_tbl(i));
	    -- Store original value before converting to display format
	    --vinf_flex_value_orig_tbl(i) := vinf_flex_value_orig_tbl(i);

         -- Need to convert flex value to display format
	    vinf_flex_value_tbl(i) := Fnd_Flex_Val_Util.to_display_value
		          (p_value          => vinf_flex_value_tbl(i),
			      p_vset_format    => vinf_format_type_tbl(i),
			      p_vset_name      => vinf_flex_value_set_name_tbl(i),
			      p_max_length     => vinf_maximum_size_tbl(i),
			      p_precision      => vinf_number_precision_tbl(i),
			      p_alpha_allowed  => vinf_alphanum_allowed_tbl(i),
			      p_uppercase_only => vinf_uppercase_only_tbl(i),
			      p_zero_fill      => vinf_num_mode_enabled_tbl(i),
			      p_min_value      => vinf_minimum_value_tbl(i),
			      p_max_value      => vinf_maximum_value_tbl(i));

      ELSIF vinf_action_tbl(i) = 'D' THEN
         IF vinf_end_date_active_tbl(i) IS NULL THEN
                  Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                      p_msg_name => 'OKC_NULL_END_DATE');
                  l_return_status := G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Check if value exists in the system or not
         OPEN l_val_exist_csr(vinf_flex_value_tbl(i),vinf_value_set_id_tbl(i));
         FETCH l_val_exist_csr INTO l_flex_value_set_id,
                                    l_flex_value_id,
                                    l_flex_value,
                                    l_start_date,
                                    l_end_date;
         IF l_val_exist_csr%NOTFOUND THEN
                  Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                      p_msg_name => 'OKC_INVALID_VS_VALUE',
					                p_token1=> 'VALUE',
					                p_token1_value => vinf_flex_value_tbl(i),
					                p_token2=> 'VALSET',
					                p_token2_value => vinf_flex_value_set_name_tbl(i));
                  l_return_status := G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;

         ELSE

            IF l_start_date IS NOT NULL
            THEN
               IF l_start_date > vinf_end_date_active_tbl(i) THEN
                  Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                      p_msg_name => 'OKC_INVALID_END_DATE');
                  l_return_status := G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
         END IF;

	    CLOSE l_val_exist_csr;
      ELSE

          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_VAL_INV_IMP_ACTION');
          l_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR ;
      END IF;

      -----------------------------------------------------------
      -- Common validation or attribute settting
      -- regardless of status and import action
      -- this validation is not included in validate api
      -----------------------------------------------------------
      IF vinf_action_tbl(i) = 'N' THEN
	 /*
	 -- Check if value set already exists in the System
         IF NOT Fnd_Flex_Val_Api.Valueset_Exists(vinf_flex_value_set_name_tbl(i)) THEN
           IF p_validate_only = 'N' THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_VALSET_NOT_EXISTS',
						  p_token1   => 'VALUE',
						  p_token1_value => vinf_flex_value_tbl(i),
						  p_token2   => 'VALSET',
						  p_token2_value => vinf_flex_value_set_name_tbl(i)
						  );
            l_return_status := G_RET_STS_ERROR;
           ELSE
            IF vinf_validation_type_tbl(i) IS NULL AND vinf_format_type_tbl(i) IS NULL THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_VALSET_NOT_EXISTS',
						  p_token1   => 'VALUE',
						  p_token1_value => vinf_flex_value_tbl(i),
						  p_token2   => 'VALSET',
						  p_token2_value => vinf_flex_value_set_name_tbl(i)
						  );
            l_return_status := G_RET_STS_ERROR;
		  END IF;
           END IF;
         END IF;
	    */


      -- Check if Validation Type for value set is 'I' otherwise values cannot be created
          IF (vinf_validation_type_tbl(i) <> 'I') THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_VAL_VALSET_NOT_VALID',
						  p_token1   => 'VALUE',
						  p_token1_value => vinf_flex_value_tbl(i),
						  p_token2   => 'VALSET',
						  p_token2_value => vinf_flex_value_set_name_tbl(i)
						  );
            l_return_status := G_RET_STS_ERROR;
         END IF;


	 -- Check if value is valid for the value set
           l_display_value := fnd_flex_ext.get_message;
          IF (NOT Fnd_Flex_Val_Util.Is_Value_Valid
		          (p_value          => vinf_flex_value_tbl(i),
				 --p_is_displayed   => TRUE,
			      p_vset_name      => vinf_flex_value_set_name_tbl(i),
			      p_vset_format    => vinf_format_type_tbl(i),
			      p_max_length     => vinf_maximum_size_tbl(i),
			      p_precision      => vinf_number_precision_tbl(i),
			      p_alpha_allowed  => vinf_alphanum_allowed_tbl(i),
			      p_uppercase_only => vinf_uppercase_only_tbl(i),
			      p_zero_fill      => vinf_num_mode_enabled_tbl(i),
			      p_min_value      => vinf_minimum_value_tbl(i),
			      p_max_value      => vinf_maximum_value_tbl(i),
			      x_storage_value  => l_storage_value,
			      x_display_value  => l_display_value)) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_VAL_NOT_VALID');
            l_return_status := G_RET_STS_ERROR;
         END IF;

      IF nvl(vinf_enabled_flag_tbl(i),'*') not in ('N','Y')  THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_ENABLED_FLAG');
            l_return_status := G_RET_STS_ERROR;

      END IF;

      IF vinf_start_date_active_tbl(i) IS NOT NULL
	 AND vinf_end_date_active_tbl(i)  IS NOT NULL
	 THEN
	    IF vinf_start_date_active_tbl(i) > vinf_end_date_active_tbl(i) THEN
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKC_INVALID_END_DATE');
            l_return_status := G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;
      ------------------------------------------------------------------------
      -- Now that we have validated and data is clean,  we can
      -- get ready for DML and also set the process status to Success
      -------------------------------------------------------------------------

      -- Summarize report for this row
      -- Status 'F' is for internal use meaning parsing failure marked in
      -- java concurrent program
      IF (l_return_status = G_RET_STS_SUCCESS) THEN
         IF (nvl(vinf_process_status_tbl(i), 'E') = 'E') THEN
           vinf_process_status_tbl(i) := G_RET_STS_SUCCESS;
         ELSIF ( vinf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           vinf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = l_sts_warning) THEN
         IF (nvl(vinf_process_status_tbl(i),'E') = 'E') THEN
           vinf_process_status_tbl(i) := l_sts_warning;
           --##count
           --l_tot_rows_warned := l_tot_rows_warned+1;
           l_part_rows_warned := l_part_rows_warned+1;
         ELSIF (vinf_process_status_tbl(i) = 'F') THEN
           -- ##count parser failure as error
           --l_tot_rows_failed := l_tot_rows_failed+1;
           l_part_rows_failed := l_part_rows_failed+1;
           vinf_process_status_tbl(i) := G_RET_STS_ERROR;
         END IF;
      ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop
    -- validation and unexpected errors
    -- In case of unexpected error, escape the loop
    -------------------------
    -------------------------


      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('300: In Fnd_flex_values_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
              END IF;
              IF l_val_exist_csr%ISOPEN THEN
	            CLOSE l_val_exist_csr;
              END IF;
              --l_return_status := G_RET_STS_ERROR ;
              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vinf_interface_id_tbl(i),
                 p_article_title => vinf_flex_value_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
                 p_entity        => 'VALUE'
                );
               vinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
               -- Continue to next row

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('400: Leaving Fnd_flex_values_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
              END IF;

              IF l_val_exist_csr%ISOPEN THEN
	            CLOSE l_val_exist_csr;
              END IF;
              IF l_val_interface_csr%ISOPEN THEN
                 CLOSE l_val_interface_csr;
              END IF;

              --Set_Message
              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              build_error_array(
                 p_msg_data     => x_msg_data,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vinf_interface_id_tbl(i),
                 p_article_title => vinf_flex_value_tbl(i),
                 p_error_type    => G_RET_STS_UNEXP_ERROR,
			  p_entity        => 'VALUE'
                 );
               vinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit; -- exit the current fetch

          WHEN OTHERS THEN
              IF (l_debug = 'Y') THEN
                okc_debug.log('500: Leaving Fnd_flex_values_Import because of EXCEPTION: '||sqlerrm, 2);
              END IF;
              IF l_val_exist_csr%ISOPEN THEN
	            CLOSE l_val_exist_csr;
              END IF;

              IF l_val_interface_csr%ISOPEN THEN
                 CLOSE l_val_interface_csr;
              END IF;

              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;

              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_UNEXPECTED_ERROR,
                                p_token1       => G_SQLCODE_TOKEN,
                                p_token1_value => sqlcode,
                                p_token2       => G_SQLERRM_TOKEN,
                                p_token2_value => sqlerrm);

              build_error_array(
                 p_msg_data     => G_UNEXPECTED_ERROR,
                 p_context      => l_context,
                 p_batch_process_id => l_batch_process_id,
                 p_interface_id  => vinf_interface_id_tbl(i),
                 p_article_title => vinf_flex_value_tbl(i),
                 p_error_type    => G_RET_STS_ERROR,
			  p_entity        => 'VALUE'
                );
               vinf_process_status_tbl(i) := G_RET_STS_ERROR;
               --##count
               --l_tot_rows_failed := l_tot_rows_failed+1;
               l_part_rows_failed := l_part_rows_failed+1;
              exit;  -- exit the current fetch
          END;
    -------------------------
    -------------------------
    -- Exception Block for each iteration in Loop ends
    -------------------------
    -------------------------


     END LOOP; -- end of FOR i in inf_interface_id_tbl.FIRST ..
    ------------------------------------------------------------------------
    -------------- End of Inner Loop thru fetched row for validation --------
    -------------------------------------------------------------------------
    -- In order to propagate Unexpected error raise it if it is 'U'
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -------------------------
    -------------------------
    -- Exception Block for Inner Loop starts
    -- Handles unexpected errors as last step
    -------------------------
    -------------------------
    EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF (l_debug = 'Y') THEN
                okc_debug.log('400: Leaving Fnd_flex_values_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
             END IF;
              IF l_val_exist_csr%ISOPEN THEN
	            CLOSE l_val_exist_csr;
              END IF;

             IF l_val_interface_csr%ISOPEN THEN
                CLOSE l_val_interface_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop

        WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Fnd_flex_values_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;
              IF l_val_exist_csr%ISOPEN THEN
	            CLOSE l_val_exist_csr;
              END IF;

             IF l_val_interface_csr%ISOPEN THEN
                CLOSE l_val_interface_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit; -- exit outermost loop
     END;

    -------------------------
    -------------------------
    -- Exception Block for Each Iteration of outermost Loop ends
    -------------------------
    -------------------------

    ------------------------------------------------------------------------
    --------------------- Start Do_DML for Fnd Flex Values   ---------------
    -- Insert Fnd Flex Values
    -------------------------------------------------------------------------
    -- initialize l_return_status to track status of DML execution
     l_return_status := G_RET_STS_SUCCESS;


    IF p_validate_only = 'N' THEN
         BEGIN
         SAVEPOINT bulkdml;

         i := 0;
        -- Bulk insert New Valid Records
         BEGIN
         l_context := 'INSERTING NEW VALUES INTO TABLE';
           FOR  i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST LOOP

		  IF vinf_action_tbl(i) = 'N' AND vinf_process_status_tbl(i) in ('S','W') THEN


  FND_FLEX_VAL_API.CREATE_INDEPENDENT_VSET_VALUE(
         P_FLEX_VALUE_SET_NAME     => vinf_flex_value_set_name_tbl(i),
	 P_FLEX_VALUE              => vinf_flex_value_tbl(i),
	 P_DESCRIPTION             => vinf_description_tbl(i),
	 P_ENABLED_FLAG            => vinf_enabled_flag_tbl(i),
	 P_START_DATE_ACTIVE       => vinf_start_date_active_tbl(i),
	 P_END_DATE_ACTIVE         => vinf_end_date_active_tbl(i),
	 P_SUMMARY_FLAG            => 'N',
	 P_STRUCTURED_HIERARCHY_LEVEL => NULL,
	 P_HIERARCHY_LEVEL         => NULL,
	 X_STORAGE_VALUE           => l_storage_value);

		   END IF;
        END LOOP;

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Fnd_flex_values_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

         --
         --  End of Insert into FND FLEX VALUES
         --
         --

         i := 0;
        -- Bulk disable Valid Records
         BEGIN
         l_context := 'DISABLE VALUES BY UPDATING THE END DATE';
           FOR  i in vinf_interface_id_tbl.FIRST ..vinf_interface_id_tbl.LAST LOOP

		  IF vinf_action_tbl(i) = 'D' AND vinf_process_status_tbl(i) in ('S','W') THEN


  FND_FLEX_VAL_API.UPDATE_INDEPENDENT_VSET_VALUE(
         P_FLEX_VALUE_SET_NAME     => vinf_flex_value_set_name_tbl(i),
	 P_FLEX_VALUE              => vinf_flex_value_tbl(i),
	 --P_DESCRIPTION             => vinf_description_tbl(i),
	 --P_ENABLED_FLAG            => vinf_enabled_flag_tbl(i),
	 --P_START_DATE_ACTIVE       => vinf_start_date_active_tbl(i),
	 P_END_DATE_ACTIVE         => vinf_end_date_active_tbl(i),
	 --P_SUMMARY_FLAG            => 'N',
	 --P_STRUCTURED_HIERARCHY_LEVEL => NULL,
	 --P_HIERARCHY_LEVEL         => NULL,
	 X_STORAGE_VALUE           => l_storage_value);

		   END IF;
        END LOOP;

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Fnd_flex_values_Import because of EXCEPTION: '||l_context||sqlerrm, 2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END;

         --
         --  End of Disable FND FLEX VALUES
         --
         --



      -- Exception for bulk DML block
      EXCEPTION
        WHEN OTHERS THEN
             l_bulk_failed := 'Y'; -- indicating that bulk operation has failed
              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_UNEXPECTED_ERROR,
                                  p_token1       => G_SQLCODE_TOKEN,
                                  p_token1_value => sqlcode,
                                  p_token2       => G_SQLERRM_TOKEN,
                                  p_token2_value => sqlerrm);
              Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKC_ART_FETCH_FAILED',
                                  p_token1       => 'CONTEXT',
                                  p_token1_value => l_context);

              build_error_array(
                                 p_msg_data     => null,
                                 p_context      => l_context,
                                 p_batch_process_id => l_batch_process_id,
                                 p_interface_id  => -99,
                                 p_article_title => NULL,
                                 p_error_type    => G_RET_STS_ERROR,
						   p_entity        => 'VALUE'
              );
              l_return_status := G_RET_STS_UNEXP_ERROR;
              x_return_status := G_RET_STS_UNEXP_ERROR;

              --##count:rollback the count
              l_part_rows_failed := l_part_rows_processed;
              l_part_rows_warned := 0;

              ROLLBACK TO SAVEPOINT bulkdml;
              exit; -- exit outermost loop
      END;

    END IF; --- validate_only = 'N'

    ------------------------------------------------------------------------
    --------------------- End of Do_DML for Values   ---------------
    -------------------------------------------------------------------------

    ------------------------------------------------------------------------
    --------------- Start of Do_DML for import related tables   ------------
    -- Update interface table
    -- Insert Errors into Error table
    -------------------------------------------------------------------------
    -- Update Interface Table
    i:=0;
    BEGIN
     l_context := 'UPDATING VALUES INTERFACE TABLE';
     FORALL i in vinf_interface_id_tbl.FIRST..vinf_interface_id_tbl.LAST
       UPDATE OKC_VS_VALUES_INTERFACE
       SET
           -- We don't want to update process_status to 'S' or 'W' in validation_mode
           -- because it is not going to be picked up in next run if we do so
           PROCESS_STATUS = decode(p_validate_only||vinf_process_status_tbl(i)||l_bulk_failed,
                                               'NEN','E',
                                               'NSN','S',
                                               'NWN','W',
                                               'NEY','E',
                                               'NSY',NULL,
                                               'NWY',NULL,
                                               'YEY','E',
                                               'YEN','E',
                                               'NFY','E',
                                               'YFY','E',
                                               'NFN','E',
                                               'YFN','E',NULL),
           PROGRAM_ID                 = l_program_id,
           REQUEST_ID                 = l_request_id,
           PROGRAM_LOGIN_ID           = l_program_login_id,
           PROGRAM_APPLICATION_ID     = l_program_appl_id,
           OBJECT_VERSION_NUMBER      = vinf_obj_ver_number_tbl(i) + 1,
           LAST_UPDATED_BY            = l_user_id,
           LAST_UPDATE_LOGIN          = l_login_id,
           LAST_UPDATE_DATE           = SYSDATE
         WHERE
           interface_id = vinf_interface_id_tbl(i);
    EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Fnd_flex_values_Import because of EXCEPTION: '||sqlerrm, 2);
             END IF;

             Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
             Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_VAL_INT_UPDATE_FAILED');
             build_error_array(
                       p_msg_data     => null,
                       p_context      => l_context,
                       p_batch_process_id => l_batch_process_id,
                       p_interface_id  => -99,
                       p_article_title => NULL,
                       p_error_type    => G_RET_STS_ERROR,
				   p_entity        => 'VALUE'
             );

		      l_return_status := G_RET_STS_UNEXP_ERROR ;
		      x_return_status := G_RET_STS_UNEXP_ERROR ;
		       --##count:rollback the count
		      l_part_rows_failed := l_part_rows_processed;
		      l_part_rows_warned := 0;

             --RAISE FND_API.G_EXC_ERROR ;
  END;
   --
   -- End of Update OKC_VS_VALUES_INTERFACE
   --
   --

    --
    --Insert Errors into Error table for this fetch
    --
    insert_error_array(
     x_return_status => x_return_status,
     x_msg_count     => x_msg_count,
     x_msg_data      => x_msg_data
    );


    IF (x_return_status = l_insert_errors_error) THEN
      NULL;
     -- Ignore
     -- RAISE l_insert_errors_exception;
    END IF;

    ------------------------------------------------------------------------
    --------------- End of Do_DML for import related tables   ------------
    -------------------------------------------------------------------------
    commit;

    -- Now delete cache for next bulk fetch

    vinf_interface_id_tbl.DELETE;
    vinf_batch_number_tbl.DELETE;
    vinf_obj_ver_number_tbl.DELETE;
    vinf_flex_value_set_name_tbl.DELETE;
    vinf_flex_value_tbl.DELETE;
    vinf_process_status_tbl.DELETE;
    vinf_action_tbl.DELETE;
    vinf_enabled_flag_tbl.DELETE;
    vinf_start_date_active_tbl.DELETE;
    vinf_end_date_active_tbl.DELETE;
    vinf_language_tbl.DELETE;
    vinf_description_tbl.DELETE;
    vinf_flex_value_meaning_tbl.DELETE;

    vinf_flex_value_id_tbl.DELETE;
    vinf_value_set_id_tbl.DELETE;
    vinf_format_type_tbl.DELETE;
    vinf_maximum_size_tbl.DELETE;
    vinf_number_precision_tbl.DELETE;
    vinf_alphanum_allowed_tbl.DELETE;
    vinf_uppercase_only_tbl.DELETE;
    vinf_num_mode_enabled_tbl.DELETE;
    vinf_maximum_value_tbl.DELETE;
    vinf_minimum_value_tbl.DELETE;

    --vinf_flex_value_orig_tbl.DELETE;

    err_batch_process_id_tbl.DELETE;
    err_article_title_tbl.DELETE;
    err_interface_id_tbl.DELETE;
    err_error_number_tbl.DELETE;
    err_object_version_number_tbl.DELETE;
    err_error_type_tbl.DELETE;
    err_entity_tbl.DELETE;
    err_error_description_tbl.DELETE;

   EXIT WHEN l_val_interface_csr%NOTFOUND;
END LOOP;


-----------------------------------------------------------------------
-- End of outermost loop for bulk fetch
-----------------------------------------------------------------------

IF l_val_interface_csr%ISOPEN THEN
CLOSE l_val_interface_csr;
END IF;


--##count:add up last processed counts
l_tot_rows_processed := l_tot_rows_processed + l_part_rows_processed;
l_tot_rows_failed := l_tot_rows_failed + l_part_rows_failed;
l_tot_rows_warned := l_tot_rows_warned + l_part_rows_warned;

--Update Batch Process Table as a last step
UPDATE OKC_ART_INT_BATPROCS_ALL
SET
  TOTAL_ROWS_PROCESSED       = l_tot_rows_processed,
  TOTAL_ROWS_FAILED          = l_tot_rows_failed,
  TOTAL_ROWS_WARNED          = l_tot_rows_warned,
  END_DATE                   = SYSDATE,
  PROGRAM_ID                 = l_program_id,
  REQUEST_ID                 = l_request_id,
  PROGRAM_LOGIN_ID           = l_program_login_id,
  PROGRAM_APPLICATION_ID     = l_program_appl_id,
  OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
  LAST_UPDATED_BY            = l_user_id,
  LAST_UPDATE_LOGIN          = l_login_id,
  LAST_UPDATE_DATE           = SYSDATE
WHERE
  BATCH_PROCESS_ID  = l_batch_process_id
  AND ENTITY = 'Value';

IF err_error_number_tbl.COUNT > 0 THEN
 insert_error_array(
   x_return_status => x_return_status,
   x_msg_count     => x_msg_count,
   x_msg_data      => x_msg_data
 );
END IF;

-- Print statistic of this run in the log
-- Commented for new XML Based Import - Moved to new_wrap_up in conc_import_articles
--wrap_up(p_validate_only,p_batch_number,l_tot_rows_processed,l_tot_rows_failed,l_tot_rows_warned,l_batch_process_id,'VALUE');
commit; -- Final commit for status update

IF (l_debug = 'Y') THEN
 okc_debug.log('2000: Leaving Fnd_flex_values import', 2);
END IF;
--x_return_status := l_return_status; this may cause to erase error x_return_status

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('3000: Leaving Fnd_flex_values_Import: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      x_return_status := G_RET_STS_ERROR ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('4000: Leaving Fnd_flex_values_Import: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      --Insert Errors into Error table if there is any

      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;

      IF l_val_interface_csr%ISOPEN THEN
         CLOSE l_val_interface_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);

  WHEN l_insert_errors_exception THEN
      --
      -- In this exception handling, we don't insert error array again
      -- because error happend in the module
      --
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Fnd_flex_values_Import because of EXCEPTION in insert_error_array: '||sqlerrm, 2);
      END IF;

      IF l_val_interface_csr%ISOPEN THEN
         CLOSE l_val_interface_csr;
      END IF;


      --x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack(p_msg_data => x_msg_data);
      commit;

  WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Fnd_flex_values_Import because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      --Insert Errors into Error table if there is any
      insert_error_array(
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
      );
      commit;
      --
      IF l_val_interface_csr%ISOPEN THEN
         CLOSE l_val_interface_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
	 get_print_msgs_stack(p_msg_data => x_msg_data);
END import_fnd_flex_values;

-- MOAC
/*
  BEGIN
       OPEN cur_org_csr;
       FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
       CLOSE cur_org_csr;
*/
--CLM impact on contracts changes

PROCEDURE import_scn_map(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_batch_number                 IN VARCHAR2,
    p_fetchsize                    IN NUMBER := 100
   )IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'import_scn_map';
    l_sts_warning                 CONSTANT VARCHAR2(1) := 'W';
 /* CURSOR l_scnmap_interface_csr ( cp_batch_number IN VARCHAR2) IS
      SELECT
           SMINT.ARTICLE_TITLE          ,
           SMINT.BATCH_NUMBER  ,
           SMINT.ORG_ID    ,
           SMINT.VARIABLE_VALUE        ,
           SMINT.SCN_CODE
      FROM OKC_SCN_MAP_INTERFACE SMINT
      WHERE BATCH_NUMBER = cp_batch_number;

    TYPE l_sminf_article_title             IS TABLE OF OKC_SCN_MAP_INTERFACE.ARTICLE_TITLE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_sminf_batch_number             IS TABLE OF OKC_SCN_MAP_INTERFACE.BATCH_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_sminf_org_id    IS TABLE OF OKC_SCN_MAP_INTERFACE.ORG_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_sminf_variable_value      IS TABLE OF OKC_SCN_MAP_INTERFACE.VARIABLE_VALUE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_sminf_scn_code          IS TABLE OF OKC_SCN_MAP_INTERFACE.SCN_CODE%TYPE INDEX BY BINARY_INTEGER ;
v_sminf_article_title_tbl l_sminf_article_title;
v_sminf_batch_number_tbl l_sminf_batch_number;
v_sminf_org_id_tbl l_sminf_org_id;
v_sminf_variable_value_tbl l_sminf_variable_value;
v_sminf_scn_code_tbl l_sminf_scn_code;

l_article_id OKC_ART_VAR_SECTIONS.ARTICLE_ID%TYPE;
l_article_version_id OKC_ART_VAR_SECTIONS.ARTICLE_VERSION_ID%TYPE;
l_variable_code OKC_ART_VAR_SECTIONS.VARIABLE_CODE%TYPE;
l_variable_value OKC_ART_VAR_SECTIONS.VARIABLE_VALUE%TYPE;
l_variable_value_id OKC_ART_VAR_SECTIONS.VARIABLE_VALUE_ID%TYPE;
l_scn_code OKC_ART_VAR_SECTIONS.SCN_CODE%TYPE;

CURSOR okc_art_var_ins_csr(p_article_title IN VARCHAR2,p_batch_number IN VARCHAR2,p_org_id IN NUMBER,p_variable_value IN VARCHAR2) IS
SELECT art.article_id,av.article_version_id,art.variable_code,intf.variable_value,flx.flex_value_id,intf.scn_code
                 FROM okc_articles_all art,okc_scn_map_interface intf,fnd_flex_values flx,okc_bus_variables_b bus,okc_article_versions av
                 WHERE art.article_title = intf.article_title
                 AND art.org_id=intf.org_id
                 AND art.variable_code =  bus.variable_code
                 AND bus.value_set_id = flx.flex_value_set_id
                 AND flx.flex_value = intf.variable_value
                 AND av.article_id = art.article_id
                 AND intf.article_title = p_article_title
                 AND intf.batch_number = p_batch_number
                 AND intf.org_id = p_org_id
                 AND intf.variable_value = p_variable_value;
*/
BEGIN
 IF (l_debug = 'Y') THEN
  okc_debug.log('1100: Entered scn_import', 2);
END IF;
 x_return_status := G_RET_STS_SUCCESS ;

/*OPEN l_scnmap_interface_csr ( p_batch_number );
LOOP
BEGIN
FETCH l_scnmap_interface_csr BULK COLLECT INTO
v_sminf_article_title_tbl,
v_sminf_batch_number_tbl,
v_sminf_org_id_tbl,
v_sminf_variable_value_tbl,
v_sminf_scn_code_tbl  LIMIT p_fetchsize;
    EXIT WHEN v_sminf_article_title_tbl.COUNT = 0 ;

      FOR i in v_sminf_article_title_tbl.FIRST ..v_sminf_article_title_tbl.LAST LOOP
      BEGIN
        OPEN okc_art_var_ins_csr(v_sminf_article_title_tbl(i),v_sminf_batch_number_tbl(i),v_sminf_org_id_tbl(i),v_sminf_variable_value_tbl(i));
        FETCH okc_art_var_ins_csr INTO l_article_id,l_article_version_id,l_variable_code,l_variable_value,l_variable_value_id,l_scn_code;
        CLOSE okc_art_var_ins_csr;

        INSERT INTO okc_art_var_sections(variable_code,variable_value_id,variable_value,article_id,article_version_id,scn_code)
         VALUES(
        l_variable_code ,
        l_variable_value_id ,
        l_variable_value ,
        l_article_id ,
        l_article_version_id ,
        l_scn_code );
         END;
        END LOOP;   --for loop ends

     END;
      CLOSE l_scnmap_interface_csr;
           END LOOP;
 EXCEPTION
  WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1200: Leaving scn_map_import because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
*/

   END import_scn_map;

END OKC_ARTICLES_IMPORT_GRP;

/
