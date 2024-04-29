--------------------------------------------------------
--  DDL for Package Body OKC_STATUS_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_STATUS_CHANGE_PVT" as
/* $Header: OKCRSTSB.pls 120.5.12010000.8 2011/10/20 12:42:37 spingali ship $*/

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--

--variables declared here



 p_hdr_errors			NUMBER 		:= 0;
 p_line_errors			NUMBER 		:= 0;
 p_hdr_count			NUMBER 		:= 0;
 p_line_count			NUMBER 		:= 0;
 --
 v_active 			VARCHAR2(30) 	:= 'ACTIVE';
 v_expired 			VARCHAR2(30) 	:= 'EXPIRED';
 v_terminated   		VARCHAR2(30) 	:= 'TERMINATED';
 v_signed 			VARCHAR2(30) 	:= 'SIGNED';

-- The following are used in case there is some goof up in the sts cursor

 v_active_m 			VARCHAR2(90) 	:= 'Active';
 v_expired_m 			VARCHAR2(90) 	:= 'Expired';
 v_terminated_m   		VARCHAR2(90) 	:= 'Terminated';
 v_signed_m 			VARCHAR2(90) 	:= 'Signed';

cursor sts(p_status_type varchar2) is
  select code, meaning
  from okc_statuses_v
  where ste_code = p_status_type
  and default_yn = 'Y';


 h_new_status 		VARCHAR2(30);
 h_new_status_m 	VARCHAR2(90);
 h_status 		    VARCHAR2(30);
 h_status_m 		VARCHAR2(90);
 h_status_type 	    VARCHAR2(30);

 l_new_status       VARCHAR2(30);
 l_new_status_m     VARCHAR2(90);
--
 v_id 							  NUMBER := 0;
 v_termination_reason   fnd_lookups.meaning%type := NULL ;

-- Global var holding the User Id
     user_id             NUMBER;

-- Global var to hold the ERROR value
     ERROR               NUMBER := 1;

-- Global var to hold the SUCCESS value
     SUCCESS           	NUMBER := 0;

-- Global var holding the Current Error code for the error encountered
     Current_Error_Code   Varchar2(20) := NULL;

-- Global var to hold the Concurrent Process return values
   	conc_ret_code       NUMBER 	:= 0; --SUCCESS;
   	v_retcode   		NUMBER 	:= 0; --SUCCESS;
	CONC_STATUS 		BOOLEAN;

   l_last_rundate DATE;
-- Cursors -- Contract Header Level

   T number;

----------------------------------------------------------------
-- End of global variables --
----------------------------------------------------------------
  PROCEDURE get_fnd_msg_stack(p_msg_data IN VARCHAR2) IS
    BEGIN
  --   IF FND_MSG_PUB.Count_Msg > 1 Then
      FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
  	    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
      END LOOP;
    -- ELSE
         --FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get);
      --   FND_FILE.PUT_LINE(FND_FILE.LOG,p_msg_data);
    -- END IF;
    FND_MSG_PUB.initialize;

    END get_fnd_msg_stack;

  FUNCTION Update_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2 Is
	l_api_version                 NUMBER := 1;
	l_init_msg_list               VARCHAR2(1) := 'F';
	x_return_status               VARCHAR2(1);
	x_msg_count                   NUMBER;
	x_msg_data                    VARCHAR2(2000);
	x_out_rec                     OKC_CVM_PVT.cvmv_rec_type;
	l_cvmv_rec                    OKC_CVM_PVT.cvmv_rec_type;
  BEGIN

	-- initialize return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- assign/populate contract header id
	l_cvmv_rec.chr_id := p_chr_id;
	OKC_CVM_PVT.update_row(
    			l_api_version,
    			l_init_msg_list,
    			x_return_status,
    			x_msg_count,
    			x_msg_data,
    			l_cvmv_rec,
    			x_out_rec);

	return (x_return_status);
  EXCEPTION
    when OTHERS then
	   -- notify caller of an error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	return (x_return_status);
  END;

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY OKC_CHR_PVT.chrv_rec_type) IS

    l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    x_chrv_rec := p_chrv_rec;
    UPDATE OKC_K_HEADERS_B
    SET STS_CODE =  p_chrv_rec.sts_code,
        OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),PROGRAM_ID),
        REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),REQUEST_ID),
        PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,SYSDATE),
        PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),PROGRAM_APPLICATION_ID),
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
    WHERE  ID = p_chrv_rec.id;

    /*cgopinee bugfix for 6882512*/
    IF (p_chrv_rec.old_ste_code <> p_chrv_rec.new_ste_code) THEN

       OKC_CTC_PVT.update_contact_stecode(p_chr_id => p_chrv_rec.id,
                              x_return_status=>l_return_status);

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;


        FND_FILE.PUT_LINE( FND_FILE.LOG,'old_sts_code'||p_chrv_rec.old_sts_code);
        FND_FILE.PUT_LINE( FND_FILE.LOG,'old_ste_code'||p_chrv_rec.old_ste_code);
        FND_FILE.PUT_LINE( FND_FILE.LOG,'new_sts_code'||p_chrv_rec.new_sts_code);
        FND_FILE.PUT_LINE( FND_FILE.LOG,'new_ste_code'||p_chrv_rec.new_ste_code);
    -- Call action assembler if status is changed
    If  p_chrv_rec.old_sts_code is not null AND
        p_chrv_rec.new_sts_code is not null AND
        p_chrv_rec.old_ste_code is not null AND
	p_chrv_rec.new_ste_code is not null AND
	(p_chrv_rec.old_sts_code <> p_chrv_rec.new_sts_code OR
	 p_chrv_rec.old_ste_code <> p_chrv_rec.new_ste_code)
    Then
        OKC_K_STS_CHG_ASMBLR_PVT.Acn_Assemble(
	      p_api_version	 => p_api_version,
	      p_init_msg_list  => p_init_msg_list,
              x_return_status	 => x_return_status,
              x_msg_count    	 => x_msg_count,
              x_msg_data     	 => x_msg_data,
              p_k_id           => p_chrv_rec.id,
              p_k_number       => p_chrv_rec.contract_number,
              p_k_nbr_mod      => p_chrv_rec.contract_number_modifier,
              p_k_cur_sts_code => p_chrv_rec.new_sts_code,
              p_k_cur_sts_type => p_chrv_rec.new_ste_code,
              p_k_pre_sts_code => p_chrv_rec.old_sts_code,
              p_k_pre_sts_type => p_chrv_rec.old_ste_code,
              p_k_source_system_code => p_chrv_rec.ORIG_SYSTEM_SOURCE_CODE);
    End If;
      -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
	  x_return_status := Update_Minor_Version(p_chrv_rec.id);

    End If;
  exception
    when OTHERS then
       	   -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_header;

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_update_minor_version         IN VARCHAR2 ,
    p_contract_number              IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type,
    x_clev_rec                     OUT NOCOPY OKC_CLE_PVT.clev_rec_type) IS

    l_api_name		CONSTANT	VARCHAR2(30) := 'Update_Contract_Line';

  BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    x_clev_rec := p_clev_rec;
    UPDATE OKC_K_LINES_B
    SET STS_CODE =  p_clev_rec.sts_code,
        OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),PROGRAM_ID),
        REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),REQUEST_ID),
        PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,SYSDATE),
        PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),PROGRAM_APPLICATION_ID),
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
    WHERE  ID = p_clev_rec.id;
    	-- Call action assembler if status is changed
    If NVL(p_clev_rec.Call_Action_Asmblr,'Y') = 'Y' AND
        p_clev_rec.old_sts_code is not null AND
        p_clev_rec.new_sts_code is not null AND
        p_clev_rec.old_ste_code is not null AND
	   p_clev_rec.new_ste_code is not null AND
	   (p_clev_rec.old_sts_code <> p_clev_rec.new_sts_code OR
	    p_clev_rec.old_ste_code <> p_clev_rec.new_ste_code)
    Then

        OKC_KL_STS_CHG_ASMBLR_PVT.Acn_Assemble(
	         p_api_version	  => p_api_version,
	         p_init_msg_list   => p_init_msg_list,
                 x_return_status	  => x_return_status,
                 x_msg_count    	  => x_msg_count,
                 x_msg_data     	  => x_msg_data,
                 p_k_id            => p_clev_rec.dnz_chr_id,
		    p_kl_id           => p_clev_rec.id,
		    p_k_number        => p_contract_number,
		    p_k_nbr_mod       => p_contract_number_modifier,
		    p_kl_number       => p_clev_rec.line_number,
		    p_kl_cur_sts_code => p_clev_rec.new_sts_code,
		    p_kl_cur_sts_type => p_clev_rec.new_ste_code,
		    p_kl_pre_sts_code => p_clev_rec.old_sts_code,
                 p_kl_pre_sts_type => p_clev_rec.old_ste_code,
                 p_kl_source_system_code => p_clev_rec.ORIG_SYSTEM_SOURCE_CODE);
      End If;

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
      If  p_update_minor_version ='Y' Then
	  x_return_status := Update_Minor_Version(p_clev_rec.dnz_chr_id);

      End If;
    End If;
  exception
    when OTHERS then

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_line;
-----------------------------------------------------------------
-- Begin LINE Status change procedure
-----------------------------------------------------------------

Procedure line_message(p_knum_and_mod IN VARCHAR2,
                       p_line_number IN VARCHAR2,
                       p_old_status      IN VARCHAR2 DEFAULT NULL,
                       p_status      IN VARCHAR2 DEFAULT NULL,
                       p_msg_data    IN VARCHAR2 DEFAULT NULL,
                       p_type     IN VARCHAR2) IS
BEGIN
  if p_type='S' Then
/*
      FND_MESSAGE.set_name('OKC','OKC_LINE_STS_CHANGE_SUCCESS');
      FND_MESSAGE.set_token('CONTRACT_NUMBER',p_knum_and_mod);
      FND_MESSAGE.set_token('LINE_NUMBER',p_line_number);
      FND_MESSAGE.set_token('OLD_STATUS', p_old_status);
      FND_MESSAGE.set_token('STATUS', p_status);
      FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
*/
      NULL;
  elsif p_type='E'Then
      get_fnd_msg_stack(p_msg_data);
      FND_MESSAGE.set_name('OKC','OKC_LINE_STS_CHANGE_FAILURE');
      FND_MESSAGE.set_token('CONTRACT_NUMBER',p_knum_and_mod);
      FND_MESSAGE.set_token('LINE_NUMBER',p_line_number);
      FND_MESSAGE.set_token('OLD_STATUS', p_old_status);
      FND_MESSAGE.set_token('STATUS', p_status);
      FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
  elsif p_type='U'Then
      get_fnd_msg_stack(p_msg_data);
      FND_MESSAGE.set_name('OKC',G_UNEXPECTED_ERROR);
      FND_MESSAGE.set_token(G_SQLCODE_TOKEN,SQLCODE);
      FND_MESSAGE.set_token(G_SQLERRM_TOKEN,SQLERRM);
      FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
      FND_MESSAGE.set_name('OKC','OKC_LINE_STS_CHANGE_FAILURE');
      FND_MESSAGE.set_token('CONTRACT_NUMBER',p_knum_and_mod);
      FND_MESSAGE.set_token('LINE_NUMBER',p_line_number);
      FND_MESSAGE.set_token('OLD_STATUS', p_old_status);
      FND_MESSAGE.set_token('STATUS', p_status);
      FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
  end if;
end line_message;


-- NEW --
-- BUG 4285665 --
-- GCHADHA --
-- Added the fix done for the bug 3967643 --
Procedure line_status_change (p_kid       IN NUMBER DEFAULT NULL,
                              p_cls_code  IN okc_subclasses_b.cls_code%TYPE DEFAULT NULL,
                              p_scs_code  IN okc_k_headers_b.scs_code%TYPE  DEFAULT NULL,
 			      p_from_k 	   IN VARCHAR2 DEFAULT NULL,
 			      p_to_k 	      IN VARCHAR2 DEFAULT NULL,
 			      p_from_m 	   IN VARCHAR2 DEFAULT NULL,
 			      p_to_m 	      IN VARCHAR2 DEFAULT NULL,
                              p_k_num     IN okc_k_headers_b.contract_number%TYPE DEFAULT NULL,
                              p_k_num_mod IN okc_k_headers_b.contract_number_modifier%TYPE DEFAULT NULL,
			      p_update_minor_version IN VARCHAR2 DEFAULT 'Y',
                              x_return_status OUT NOCOPY VARCHAR2) IS
  C number := 0;

  l_knum_and_mod VARCHAR2(240) := p_k_num||' '||p_k_num_mod;
  l_line_number  VARCHAR2(150);
  l_return_status 		VARCHAR2(1) 	:= okc_api.g_ret_sts_success;
  p_init_msg_list 		VARCHAR2(200) 	:= okc_api.g_true;
  x_msg_count 			NUMBER 		:= okc_api.g_miss_num;
  x_msg_data 			VARCHAR2(2000) := okc_api.g_miss_char;

  l_cle_rec  okc_contract_pub.clev_rec_type;
  x_cle_rec  okc_contract_pub.clev_rec_type;

  TYPE line_rec_type IS RECORD (
        contract_number    okc_k_headers_b.contract_number%TYPE,
        contract_number_modifier okc_k_headers_b.contract_number_modifier%TYPE,
 	ID  okc_k_lines_b.id%TYPE,
 	OBJECT_VERSION_NUMBER okc_k_lines_b.object_version_number%TYPE,
 	STS_CODE okc_k_lines_b.sts_code%TYPE,
 	DATE_TERMINATED  okc_k_lines_b.date_terminated%TYPE,
 	START_DATE  okc_k_lines_b.start_date%TYPE,
 	END_DATE okc_k_lines_b.end_date%TYPE,
 	LINE_NUMBER okc_k_lines_b.line_number%TYPE,
 	PRICE_NEGOTIATED okc_k_lines_b.price_negotiated%TYPE,
        dnz_chr_id okc_k_lines_b.dnz_chr_id%TYPE,
        TERMINATION_REASON fnd_lookups.meaning%TYPE,
 	CODE okc_statuses_b.code%TYPE,
 	STE_CODE okc_statuses_b.ste_code%TYPE,
 	meaning okc_statuses_v.meaning%TYPE);

  line_rec                          line_rec_type;
  r_terminate_line_rec line_rec_type;
  r_expired_line_rec line_rec_type;
  r_active_line_rec line_rec_type;
  r_signed_line_rec line_rec_type;

  -- GCHADHA --
  -- 4285665 --
  TYPE line_Table_Type IS TABLE OF line_rec_type INDEX BY BINARY_INTEGER;
  r_terminate_line_tbl   line_Table_Type;
  r_expired_line_tbl     line_Table_Type;
  r_active_line_tbl      line_Table_Type;
  r_signed_line_tbl      line_Table_Type;
  Type Num_Tbl_Type is table of NUMBER index  by BINARY_INTEGER ;
  Type Num9_Tbl_Type is table of NUMBER(9,0) index  by BINARY_INTEGER ;
  TYPE VC30_Tbl_Type is TABLE of VARCHAR2(30) index  by BINARY_INTEGER ;
  TYPE VC120_Tbl_Type is TABLE of VARCHAR2(120) index  by BINARY_INTEGER ;
  TYPE VC150_Tbl_Type is TABLE of VARCHAR2(150) index  by BINARY_INTEGER ;
  TYPE VC80_Tbl_Type is TABLE of VARCHAR2(80) index  by BINARY_INTEGER ;
  TYPE Date_Tbl_Type is TABLE of DATE index  by BINARY_INTEGER ;

  l_contract_number_tbl          VC120_Tbl_Type;
  l_contract_number_modifier_tbl VC120_Tbl_Type;
  l_id_tbl                       Num_Tbl_Type;
  l_object_version_number_tbl    Num9_Tbl_Type;
  l_sts_code_tbl                 VC120_Tbl_Type;
  l_date_terminated_tbl	         Date_Tbl_Type;
  l_start_date_tbl               Date_Tbl_Type;
  l_end_date_tbl		 Date_Tbl_Type;
  l_line_number_tbl              VC150_Tbl_Type;
  l_price_negotiated_tbl         Num_Tbl_Type;
  l_dnz_chr_id_tbl               Num_Tbl_Type;
  l_termination_reason_tbl       VC80_Tbl_Type;
  l_code_tbl                     VC30_Tbl_Type;
  l_ste_code_tbl                 VC30_Tbl_Type;
  l_meaning_tbl                  VC30_Tbl_Type;
  -- Used as Counters --
  i                               NUMBER := 0;
  x_num				  NUMBER := 0;

  -- END GCHADHA --

  -- Cursors -- Contract LINE Level

 -- From ACTIVE/SIGNED to Terminated.
 /* Commented for Bug #3967643. Split cursor into 3 parts based on
   parameters as suggested by Appsperf Team
  CURSOR c_terminate_line_all IS
  SELECT   chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
          fnd.meaning TERMINATION_REASON,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_LINES_B  line,
   	  OKC_STATUSES_V  status,
       fnd_lookups fnd,
       okc_k_headers_b chr,
       okc_subclasses_b scs
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND ((p_scs_code         is NULL) or (chr.scs_code  = p_scs_code))
    AND ((p_from_k      is NULL) or (chr.CONTRACT_NUMBER          >= p_from_k ))
    AND ((p_to_k        is NULL) or (chr.CONTRACT_NUMBER          <= p_to_k   ))
    AND ((p_from_m      is NULL) or (chr.CONTRACT_NUMBER_modifier >= p_from_m ))
    AND ((p_to_m        is NULL) or (chr.CONTRACT_NUMBER_modifier <= p_to_m   ))
    AND status.ste_code      IN ('ACTIVE','HOLD','SIGNED')
    AND line.date_terminated <= trunc(sysdate) + 0.99999
    AND LINE.date_terminated >= trunc(l_last_rundate)
    AND line.trn_code = fnd.lookup_code
    AND fnd.LOOKUP_TYPE= 'OKC_TERMINATION_REASON';
*/
 -- Bug #3967643. Split cursors into 3 parts as suggested by Appsperf Team
 -- Hint added as suggested by Appsperf Team
 -- From ACTIVE/SIGNED to Terminated

 -- When only the From-to Contract number range is provided with optional Contract number modifier range
 -- and optional Category code
   CURSOR c_termnt_line_all_cntr IS
    SELECT
      CHR.CONTRACT_NUMBER, CHR.CONTRACT_NUMBER_MODIFIER, LINE.ID,
      LINE.OBJECT_VERSION_NUMBER, LINE.STS_CODE, LINE.DATE_TERMINATED, LINE.START_DATE,
      LINE.END_DATE, LINE.LINE_NUMBER, LINE.PRICE_NEGOTIATED, LINE.DNZ_CHR_ID,
      FND.MEANING TERMINATION_REASON, STSB.CODE,  STSB.STE_CODE, STST.MEANING
   FROM     OKC_K_LINES_B         LINE,
      OKC_STATUSES_TL stst,
      OKC_STATUSES_B stsb,
      FND_LOOKUPS         FND,
      OKC_K_HEADERS_B     CHR,
      OKC_SUBCLASSES_B     SCS
   WHERE     LINE.STS_CODE = STST.CODE
   AND     LINE.DNZ_CHR_ID = CHR.ID
   AND stst.code = stsb.code
   AND STST.LANGUAGE = USERENV('LANG')
   AND ((p_scs_code         is NULL) or (chr.scs_code  = p_scs_code))
   AND     CHR.CONTRACT_NUMBER >= p_from_k
   AND     CHR.CONTRACT_NUMBER <= p_to_k
   AND ((p_from_m      is NULL) or (chr.CONTRACT_NUMBER_modifier >= p_from_m ))
   AND ((p_to_m        is NULL) or (chr.CONTRACT_NUMBER_modifier <= p_to_m   ))
   --BUG 4915692 Gchadha
   --  AND      STATUS.STE_CODE IN ('ACTIVE','HOLD','SIGNED')
   -- AND      STATUS.STE_CODE IN ('ACTIVE','SIGNED')
   AND stsb.ste_code   IN ('ACTIVE','SIGNED')
   --END BUG 4915692 Gchadha
   AND     LINE.DATE_TERMINATED <=  TRUNC(SYSDATE) + 0.99999
   AND     LINE.DATE_TERMINATED >= TRUNC(l_last_rundate)
   AND      LINE.TRN_CODE = FND.LOOKUP_CODE
   AND     FND.LOOKUP_TYPE=  'OKC_TERMINATION_REASON'
   --AND exists (select 1 from okc_subclasses_b scs where scs.cls_code <> 'OKL' AND chr.scs_code = scs.code); -- new
   AND chr.scs_code = scs.code
   And scs.cls_code <> 'OKL';

  -- When only Category is provided
   CURSOR c_termnt_line_all_category IS
    SELECT /*+ leading(stsb, stst, line) index(line OKC_K_LINES_N13) */    ---Modified hint for bug 12976183
      CHR.CONTRACT_NUMBER, CHR.CONTRACT_NUMBER_MODIFIER, LINE.ID,
      LINE.OBJECT_VERSION_NUMBER, LINE.STS_CODE, LINE.DATE_TERMINATED, LINE.START_DATE,
      LINE.END_DATE, LINE.LINE_NUMBER, LINE.PRICE_NEGOTIATED, LINE.DNZ_CHR_ID,
      FND.MEANING TERMINATION_REASON, STSB.CODE,  STSB.STE_CODE, STST.MEANING
   FROM     OKC_K_LINES_B         LINE,
           OKC_STATUSES_TL stst,
      OKC_STATUSES_B stsb,
      FND_LOOKUPS         FND,
      OKC_K_HEADERS_B     CHR,
      OKC_SUBCLASSES_B     SCS
   WHERE     LINE.STS_CODE = STST.CODE
   AND     LINE.DNZ_CHR_ID = CHR.ID
   AND stst.code = stsb.code
   AND STST.LANGUAGE = USERENV('LANG')
   AND     chr.scs_code  = p_scs_code
   --BUG 4915692 Gchadha
   --   AND      STATUS.STE_CODE IN ('ACTIVE','HOLD','SIGNED')
   -- AND      STATUS.STE_CODE IN ('ACTIVE','SIGNED')
   AND stsb.ste_code   IN ('ACTIVE','SIGNED')
   --BUG 4915692 Gchadha
   AND     LINE.DATE_TERMINATED <=  TRUNC(SYSDATE) + 0.99999
   AND     LINE.DATE_TERMINATED >= TRUNC(l_last_rundate)
   AND      LINE.TRN_CODE = FND.LOOKUP_CODE
   AND     FND.LOOKUP_TYPE=  'OKC_TERMINATION_REASON'
   --AND exists (select 1 from okc_subclasses_b scs where scs.cls_code <> 'OKL' AND chr.scs_code = scs.code); -- new
   And chr.scs_code = scs.code
   And scs.cls_code <> 'OKL';

-- When no parameters are provided
   CURSOR c_terminate_line_all IS
    SELECT
      CHR.CONTRACT_NUMBER, CHR.CONTRACT_NUMBER_MODIFIER, LINE.ID,
      LINE.OBJECT_VERSION_NUMBER, LINE.STS_CODE, LINE.DATE_TERMINATED, LINE.START_DATE,
      LINE.END_DATE, LINE.LINE_NUMBER, LINE.PRICE_NEGOTIATED, LINE.DNZ_CHR_ID,
      FND.MEANING TERMINATION_REASON,  STSB.CODE,  STSB.STE_CODE, STST.MEANING
   FROM     OKC_K_LINES_B         LINE,
      OKC_STATUSES_TL stst,
      OKC_STATUSES_B stsb,
      FND_LOOKUPS         FND,
      OKC_K_HEADERS_B     CHR,
      OKC_SUBCLASSES_B     SCS
   WHERE     LINE.STS_CODE = STST.CODE
   AND     LINE.DNZ_CHR_ID = CHR.ID
   AND stst.code = stsb.code
   AND STST.LANGUAGE = USERENV('LANG')
   -- BUG 4915692 Gchadha
   --   AND      STATUS.STE_CODE IN ('ACTIVE','HOLD','SIGNED')
   -- AND      STATUS.STE_CODE IN ('ACTIVE','SIGNED')
   AND stsb.ste_code   IN ('ACTIVE','SIGNED')
   -- BUG 4915692 Gchadha
   AND     LINE.DATE_TERMINATED <=  TRUNC(SYSDATE) + 0.99999
   AND     LINE.DATE_TERMINATED >= TRUNC(l_last_rundate)
   AND      LINE.TRN_CODE = FND.LOOKUP_CODE
   AND     FND.LOOKUP_TYPE=  'OKC_TERMINATION_REASON'
   --AND exists (select 1 from okc_subclasses_b scs where scs.cls_code <> 'OKL' AND chr.scs_code = scs.code); -- new
   And chr.scs_code = scs.code
   And scs.cls_code <> 'OKL';

 -- From ACTIVE/SIGNED/HOLD to EXPIRED
 -- Hint added as per Bug 2563108 (Suggested by Appsperf Team)
 -- Commented for Bug #3967643. Split cursor into 3 parts based on parameters
 -- as suggested by Appsperf Team
 --CURSOR c_expired_line_all IS
 --SELECT /*+leading(CHR) USE_NL(CHR SCS LINE FND.LV STATUS.STSB STATUS.STST))*/
 /*         chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM  OKC_K_LINES_B   line,
 	 OKC_STATUSES_V  status,
         OKC_K_HEADERS_B chr,
         okc_subclasses_b scs
  WHERE line.STS_CODE   = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND ((p_scs_code         is NULL) or (chr.scs_code  = p_scs_code))
    AND ((p_from_k      is NULL) or (chr.CONTRACT_NUMBER          >= p_from_k ))
    AND ((p_to_k        is NULL) or (chr.CONTRACT_NUMBER          <= p_to_k   ))
    AND ((p_from_m      is NULL) or (chr.CONTRACT_NUMBER_modifier >= p_from_m ))
    AND ((p_to_m        is NULL) or (chr.CONTRACT_NUMBER_modifier <= p_to_m   ))
    and status.ste_code          in ('ACTIVE','SIGNED','HOLD')  -- <> 'EXPIRED'
    --
    -- Bug 2672565 - Removed time component and changed from <= to <
    --
    --AND line.end_date   <= trunc(sysdate) + 0.99999
    AND line.end_date   < trunc(sysdate)
    AND line.end_date   >= trunc(l_last_rundate)
    AND (line.date_terminated IS NULL
     OR  line.date_terminated >= trunc(sysdate)); */

 -- Bug #3967643. Split cursors into 3 parts as suggested by Appsperf Team
 -- Hint added as suggested by Appsperf Team
 -- From ACTIVE/SIGNED to EXPIRED

 -- When only the From-to Contract number range is provided with optional Contract number modifier range
 -- and optional Category code
 CURSOR c_expr_line_all_cntr IS
  SELECT
  	  chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
	  stsb.CODE,
 	  stsb.STE_CODE,
 	  stst.meaning
   FROM  OKC_K_LINES_B   line,
 	 OKC_STATUSES_TL stst,
         OKC_STATUSES_B stsb,
         OKC_K_HEADERS_B chr
       --  okc_subclasses_b scs
  WHERE line.STS_CODE   = stst.CODE
    AND line.dnz_chr_id      = chr.id
    AND stst.code = stsb.code
    AND STST.LANGUAGE = USERENV('LANG')
    AND ((p_scs_code         is NULL) or (chr.scs_code  = p_scs_code))
    AND     CHR.CONTRACT_NUMBER >= p_from_k
    AND     CHR.CONTRACT_NUMBER <= p_to_k
    AND ((p_from_m      is NULL) or (chr.CONTRACT_NUMBER_modifier >= p_from_m ))
    AND ((p_to_m        is NULL) or (chr.CONTRACT_NUMBER_modifier <= p_to_m   ))
  -- BUG 4915692 Gchadha
--  AND      STATUS.STE_CODE IN ('ACTIVE','HOLD','SIGNED')
    -- AND      STATUS.STE_CODE IN ('ACTIVE','SIGNED')
    AND      STSB.STE_CODE IN ('ACTIVE','SIGNED')
    --BUG 4915692 Gchadha
    --
    -- Bug 2672565 - Removed time component and changed from <= to <
    --
    --AND line.end_date   <= trunc(sysdate) + 0.99999
    AND line.end_date   < trunc(sysdate)
    AND line.end_date   >= trunc(l_last_rundate)
    AND (line.date_terminated IS NULL
    OR  line.date_terminated >= trunc(sysdate))
    AND exists (select 1 from okc_subclasses_b scs where scs.cls_code <> 'OKL' AND chr.scs_code = scs.code);


  -- When only Category is provided
   CURSOR c_expr_line_all_category IS
    SELECT /*+ leading(stsb, stst, line) index(line okc_k_lines_b_n12) */    ---Modified hint for bug 12976183
  	  chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  stsb.CODE,
 	  stsb.STE_CODE,
 	  stst.meaning
   FROM  OKC_K_LINES_B   line,
 	 -- OKC_STATUSES_V  status,
	 OKC_STATUSES_TL stst,
         OKC_STATUSES_B stsb,
         OKC_K_HEADERS_B chr
      --   okc_subclasses_b scs
  WHERE line.STS_CODE   = stst.CODE
    AND line.dnz_chr_id      = chr.id
    AND stst.code = stsb.code
    AND STST.LANGUAGE = USERENV('LANG')
    AND chr.scs_code  = p_scs_code
 -- Bug 4915692 --
--  AND      STATUS.STE_CODE IN ('ACTIVE','HOLD','SIGNED')
   -- AND      STATUS.STE_CODE IN ('ACTIVE','SIGNED')
    AND      STSB.STE_CODE IN ('ACTIVE','SIGNED')
  -- Bug 4915692 --
    --
    -- Bug 2672565 - Removed time component and changed from <= to <
    --
    --AND line.end_date   <= trunc(sysdate) + 0.99999
    AND line.end_date   < trunc(sysdate)
    AND line.end_date   >= trunc(l_last_rundate)
    AND (line.date_terminated IS NULL
    OR  line.date_terminated >= trunc(sysdate))
    AND exists (select 1 from okc_subclasses_b scs where scs.cls_code <> 'OKL' AND chr.scs_code = scs.code);

  -- When no parameters are is provided
   CURSOR c_expired_line_all IS
    SELECT
  	  chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  stsb.CODE,
 	  stsb.STE_CODE,
 	  stst.meaning
   FROM  OKC_K_LINES_B   line,
 	 OKC_STATUSES_TL stst,
         OKC_STATUSES_B stsb,
         OKC_K_HEADERS_B chr
        -- okc_subclasses_b scs
  WHERE line.STS_CODE   = stst.CODE
    AND line.dnz_chr_id      = chr.id
    AND stst.code = stsb.code
    AND STST.LANGUAGE = USERENV('LANG')
    -- Bug 4915692 --
    --AND      STATUS.STE_CODE IN ('ACTIVE','HOLD','SIGNED')
    AND      STSB.STE_CODE IN ('ACTIVE','SIGNED')

    -- Bug 4915692 --
    --
    -- Bug 2672565 - Removed time component and changed from <= to <
    --
    --AND line.end_date   <= trunc(sysdate) + 0.99999
    AND line.end_date   < trunc(sysdate)
    AND line.end_date   >= trunc(l_last_rundate)
    AND (line.date_terminated IS NULL
    OR  line.date_terminated >= trunc(sysdate))
    AND exists (select 1 from okc_subclasses_b scs where scs.cls_code <> 'OKL' AND chr.scs_code = scs.code);

 -- LINE from SIGNED to ACTIVE
  /* Commented for Bug #3967643. Split cursor into 3 parts based on
   parameters as suggested by Appsperf Team
 CURSOR c_active_line_all IS
 SELECT   chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status,
 	  OKC_STATUSES_B  status1,
       okc_k_headers_b chr,
       okc_subclasses_b scs
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND ((p_scs_code         is NULL) or (chr.scs_code  = p_scs_code))
    AND ((p_from_k      is NULL) or (chr.CONTRACT_NUMBER          >= p_from_k ))
    AND ((p_to_k        is NULL) or (chr.CONTRACT_NUMBER          <= p_to_k   ))
    AND ((p_from_m      is NULL) or (chr.CONTRACT_NUMBER_modifier >= p_from_m ))
    AND ((p_to_m        is NULL) or (chr.CONTRACT_NUMBER_modifier <= p_to_m   ))
    AND status.ste_code   = 'SIGNED'
    AND chr.STS_CODE        = status1.CODE
    AND status1.ste_code   = 'ACTIVE'
    AND line.start_date >= trunc(l_last_rundate) AND
        line.start_date <= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));
*/
 -- Bug #3967643. Split cursors into 3 parts as suggested by Appsperf Team
 -- Hint added as suggested by Appsperf Team
 -- LINE from SIGNED to ACTIVE

 -- When only the From-to Contract number range is provided with optional Contract number modifier range
 -- and optional Category code
 CURSOR c_actv_line_all_cntr IS
 SELECT      /*+leading(CHR) USE_NL(CHR SCS LINE FND.LV STATUS.STSB STATUS.STST))*/
          chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
 FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status,
 	  OKC_STATUSES_B  status1,
       okc_k_headers_b chr,
       okc_subclasses_b scs
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND ((p_scs_code         is NULL) or (chr.scs_code  = p_scs_code))
    AND chr.CONTRACT_NUMBER          >= p_from_k
    AND chr.CONTRACT_NUMBER          <= p_to_k
    AND ((p_from_m      is NULL) or (chr.CONTRACT_NUMBER_modifier >= p_from_m ))
    AND ((p_to_m        is NULL) or (chr.CONTRACT_NUMBER_modifier <= p_to_m   ))
    AND status.ste_code   = 'SIGNED'
    AND chr.STS_CODE        = status1.CODE
    AND status1.ste_code   = 'ACTIVE'
    AND line.start_date >= trunc(l_last_rundate)
    AND line.start_date <= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));

-- When only Category is provided
 CURSOR c_actv_line_all_category IS
 SELECT  /*+leading(status, line) index(line okc_k_lines_b_n11) */   ---Modified hint for bug 12976183
          chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
 FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status,
 	  OKC_STATUSES_B  status1,
       okc_k_headers_b chr,
       okc_subclasses_b scs
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND CHR.SCS_CODE = p_scs_code
    AND status.ste_code   = 'SIGNED'
    AND chr.STS_CODE        = status1.CODE
    AND status1.ste_code   = 'ACTIVE'
    AND line.start_date >= trunc(l_last_rundate)
    AND line.start_date <= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));

-- When no parameters are provided
 CURSOR c_active_line_all IS
 SELECT   /*+leading(LINE) USE_NL(LINE CHR SCS FND.LV STATUS.STSB STATUS.STST))*/
          chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
 FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status,
 	  OKC_STATUSES_B  status1,
       okc_k_headers_b chr,
       okc_subclasses_b scs
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND status.ste_code   = 'SIGNED'
    AND chr.STS_CODE        = status1.CODE
    AND status1.ste_code   = 'ACTIVE'
    AND line.start_date >= trunc(l_last_rundate)
    AND line.start_date <= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));

--bug 5930684
 -- LINE from ACTIVE to SIGNED

 -- When only the From-to Contract number range is provided with optional Contract number modifier range
 -- and optional Category code
 CURSOR c_sign_line_all_cntr IS
 SELECT      /*+leading(CHR) USE_NL(CHR SCS LINE FND.LV STATUS.STSB STATUS.STST))*/
          chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
 FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status,
 	  OKC_STATUSES_B  status1,
       okc_k_headers_b chr,
       okc_subclasses_b scs
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND ((p_scs_code         is NULL) or (chr.scs_code  = p_scs_code))
    AND chr.CONTRACT_NUMBER          >= p_from_k
    AND chr.CONTRACT_NUMBER          <= p_to_k
    AND ((p_from_m      is NULL) or (chr.CONTRACT_NUMBER_modifier >= p_from_m ))
    AND ((p_to_m        is NULL) or (chr.CONTRACT_NUMBER_modifier <= p_to_m   ))
    AND status.ste_code   = 'ACTIVE'
    AND chr.STS_CODE        = status1.CODE
    AND status1.ste_code   = 'SIGNED'
    AND line.start_date >= trunc(l_last_rundate)
    AND line.start_date >= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));

-- When only Category is provided
 CURSOR c_sign_line_all_category IS
 SELECT  /*+leading(SCS) USE_NL(SCS LINE CHR FND.LV STATUS.STSB STATUS.STST))*/
          chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
 FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status,
 	  OKC_STATUSES_B  status1,
       okc_k_headers_b chr,
       okc_subclasses_b scs
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND CHR.SCS_CODE = p_scs_code
    AND status.ste_code   = 'ACTIVE'
    AND chr.STS_CODE        = status1.CODE
    AND status1.ste_code   = 'SIGNED'
    AND line.start_date >= trunc(l_last_rundate)
    AND line.start_date >= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));

-- When no parameters are provided
 CURSOR c_signed_line_all IS
 SELECT   /*+leading(LINE) USE_NL(LINE CHR SCS FND.LV STATUS.STSB STATUS.STST))*/
          chr.contract_number,
          chr.contract_number_modifier,
 	  line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
 FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status,
 	  OKC_STATUSES_B  status1,
       okc_k_headers_b chr,
       okc_subclasses_b scs
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id      = chr.id
    AND chr.scs_code = scs.code
    AND scs.cls_code <> 'OKL'
    AND status.ste_code   = 'ACTIVE'
    AND chr.STS_CODE        = status1.CODE
    AND status1.ste_code   = 'SIGNED'
    AND line.start_date >= trunc(l_last_rundate)
    AND line.start_date >= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));
-- end of bug 5930684.

-- From ACTIVE/SIGNED to Terminated.
 CURSOR c_terminate_line_k IS
 SELECT   line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
          fnd.meaning TERMINATION_REASON,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_LINES_B  line,
   	  OKC_STATUSES_V  status,
       fnd_lookups fnd
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id = p_kid
    --BUG 4915692 --
    --AND      STATUS.STE_CODE IN ('ACTIVE','HOLD','SIGNED')
    AND      STATUS.STE_CODE IN ('ACTIVE','SIGNED')
    --Bug 4915692 --
    AND line.date_terminated <= trunc(sysdate) + 0.99999
    AND LINE.date_terminated >= trunc(l_last_rundate)
    AND line.trn_code = fnd.lookup_code
    AND fnd.LOOKUP_TYPE= 'OKC_TERMINATION_REASON';

 -- From ACTIVE/SIGNED to EXPIRED
 CURSOR c_expired_line_k IS
 SELECT   line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM  OKC_K_LINES_B   line,
 	 OKC_STATUSES_V  status
  WHERE line.STS_CODE   = status.CODE
    AND line.dnz_chr_id = p_kid
    --BUG 4915692 --
    --AND      STATUS.STE_CODE IN ('ACTIVE','HOLD','SIGNED')
    AND      STATUS.STE_CODE IN ('ACTIVE','SIGNED')
    -- Bug 4915692 --
    --
    -- Bug 2672565 - Removed time component and changed <= to <
    --AND line.end_date   <= trunc(sysdate) + 0.99999
    --
    AND line.end_date   < trunc(sysdate)
    AND line.end_date   >= trunc(l_last_rundate)
    AND (line.date_terminated IS NULL
     OR  line.date_terminated >= trunc(sysdate));


 -- LINE from SIGNED to ACTIVE
 CURSOR c_active_line_k IS
 SELECT   line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id = p_kid
    AND status.ste_code   = 'SIGNED'
    AND line.start_date >= trunc(l_last_rundate) AND
        line.start_date <= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));

--bug 5930684
 -- LINE from ACTIVE to SIGNED
 CURSOR c_signed_line_k IS
 SELECT   line.ID ,
 	  line.OBJECT_VERSION_NUMBER,
 	  line.STS_CODE,
 	  line.DATE_TERMINATED ,
 	  line.START_DATE ,
 	  line.END_DATE,
 	  line.LINE_NUMBER,
 	  line.PRICE_NEGOTIATED,
          line.dnz_chr_id,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_LINES_B  line,
 	  OKC_STATUSES_V  status
  WHERE line.STS_CODE        = status.CODE
    AND line.dnz_chr_id = p_kid
    AND status.ste_code   = 'ACTIVE'
    AND line.start_date >= trunc(l_last_rundate) AND
        line.start_date >= trunc(sysdate) + 0.99999
    AND (line.date_terminated IS NULL
     or  line.date_terminated >= trunc(sysdate));
--end of bug 5930684

PROCEDURE line_terminate(p_term_line_rec IN line_rec_type) IS
  BEGIN


    if ((C >= T) and p_kid IS NULL) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_line_count:= p_line_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_knum_and_mod := p_term_line_rec.contract_number||' '||p_term_line_rec.contract_number_modifier;
    l_new_status := null;
    l_new_status_m := null;
    l_line_number := p_term_line_rec.line_number;
    if (h_status_type = 'TERMINATED') then
       l_new_status := h_status;
       l_new_status_m := h_status_m;
    else
       l_new_status := v_terminated ;
       l_new_status_m := v_terminated_m ;
    end if;

    l_cle_rec.id := p_term_line_rec.id ;
    l_cle_rec.object_version_number  :=  p_term_line_rec.object_version_number ;
    l_cle_rec.sts_code := l_new_status;
    l_cle_rec.dnz_chr_id := p_term_line_rec.dnz_chr_id;
--
-- Assign values if and only if the change in line status is not resulting
-- from the change in header status
---- Bug# 1405237
	l_cle_rec.call_action_asmblr := 'N';
--
     IF h_new_status is null and l_new_status is not null then
	     l_cle_rec.old_sts_code := p_term_line_rec.sts_code;
	     l_cle_rec.old_ste_code := p_term_line_rec.ste_code;
	     l_cle_rec.new_sts_code := l_new_status;
	     l_cle_rec.new_ste_code := 'TERMINATED';
	     l_cle_rec.call_action_asmblr := 'Y';
      END IF;

--
-- lock added not to depend on update implementation
--


	okc_contract_pub.lock_contract_line(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_clev_rec                     =>     l_cle_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

       update_contract_line   (
   		 	      p_api_version                  =>     1.0,
   		 	      p_init_msg_list                =>     p_init_msg_list,
                              p_contract_number              =>     p_term_line_rec.contract_number,
                              p_contract_number_modifier     =>     p_term_line_rec.contract_number_modifier,
                              p_update_minor_version         =>     p_update_minor_version,
    			      x_return_status                =>     l_return_status,
    			      x_msg_count                    =>     x_msg_count,
    			      x_msg_data                     =>     x_msg_data,
    			      p_clev_rec                     =>     l_cle_rec,
    			      x_clev_rec	               =>   x_cle_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;


	OKC_KL_TERM_ASMBLR_PVT.acn_assemble(
	    		p_api_version		=>	1.0 ,
			p_init_msg_list 	=>	p_init_msg_list,
			x_return_status 	=>	l_return_status,
			x_msg_count		=>	x_msg_count,
			x_msg_data		=>	x_msg_data,
			p_k_class           =>   p_cls_code,
			p_k_id			=>	p_kid,
			p_kl_id			=>	p_term_line_rec.id,
			p_kl_term_date		=>	p_term_line_rec.date_terminated,
			p_kl_term_reason	=>	p_term_line_rec.termination_reason,
			p_k_number		=>	p_term_line_rec.contract_number,
			p_k_nbr_mod		=>	p_term_line_rec.contract_number_modifier,
			p_k_subclass        =>   p_scs_code,
			P_KL_STATUS_CODE => p_term_line_rec.STS_CODE,
			p_estimated_amount  =>   p_term_line_rec.price_negotiated );
--
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OKC_TIME_RES_PUB.res_time_termnt_k(
			P_CHR_ID  		=> NULL,
			P_CLE_ID         	=> p_term_line_rec.id,
			P_END_DATE     		=> p_term_line_rec.DATE_TERMINATED,
			P_API_VERSION  		=> 1.0 ,
			p_init_msg_list		 =>	p_init_msg_list,
			x_return_status		 =>	l_return_status
	);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      if p_kid is NULL then
         c := c+1;
--

      line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_old_status =>p_term_line_rec.meaning,
                 p_status =>l_new_status,
                 p_type  =>'S');
      end if;


  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_old_status =>p_term_line_rec.meaning,
                 p_status =>l_new_status,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_old_status =>p_term_line_rec.meaning,
                 p_status =>l_new_status,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
	p_line_errors := p_line_errors +1 ;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        rollback to H_STATUS;
    WHEN OTHERS then
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_old_status =>p_term_line_rec.meaning,
                 p_status =>l_new_status,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        rollback to H_STATUS;
  END line_terminate;

 PROCEDURE line_expire(p_exp_line_rec IN line_rec_type) IS
  BEGIN

    if ((C >= T) and p_kid IS NULL) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_line_count:= p_line_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_knum_and_mod := p_exp_line_rec.contract_number||' '||p_exp_line_rec.contract_number_modifier;
    l_new_status := null;
    l_new_status_m := null;

    l_line_number := p_exp_line_rec.line_number;
    if (h_status_type = 'EXPIRED') then
  	l_new_status := h_status;
	l_new_status_m := h_status_m;
    else
	l_new_status := v_expired ;
	l_new_status_m := v_expired_m ;
    end if;

    l_cle_rec.id := p_exp_line_rec.id ;
    l_cle_rec.object_version_number  :=  p_exp_line_rec.object_version_number ;
    l_cle_rec.sts_code := l_new_status;
    l_cle_rec.dnz_chr_id := p_exp_line_rec.dnz_chr_id;
--
--
-- Start: Added for Status Change Action Assembler Changes 10/19/2000
--
-- Assign values if and oly if the change in line status is not resulting
-- from the change in header status
--
   l_cle_rec.call_action_asmblr := 'N';
   IF h_new_status is null and l_new_status is not null then
	l_cle_rec.old_sts_code := p_exp_line_rec.sts_code;
	l_cle_rec.old_ste_code := p_exp_line_rec.ste_code;
	l_cle_rec.new_sts_code := l_new_status;
	l_cle_rec.new_ste_code := 'EXPIRED';
	l_cle_rec.call_action_asmblr := 'Y';
   END IF;

-- lock added not to depend on update implementation
--

   okc_contract_pub.lock_contract_line(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_clev_rec                     =>     l_cle_rec);


    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
--

     update_contract_line(
   		 	 p_api_version                  =>     1.0,
   		 	 p_init_msg_list                =>     p_init_msg_list,
                         p_update_minor_version         =>     p_update_minor_version,
                         p_contract_number              =>     p_exp_line_rec.contract_number,
                         p_contract_number_modifier     =>     p_exp_line_rec.contract_number_modifier,
    			 x_return_status                =>     l_return_status,
    			 x_msg_count                    =>     x_msg_count,
    			 x_msg_data                     =>     x_msg_data,
    			 p_clev_rec                     =>     l_cle_rec,
    			 x_clev_rec	               =>     x_cle_rec);


      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      if p_kid is NULL then
         c := c+1;
--


        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_exp_line_rec.meaning,
                 p_type  =>'S');
      end if;

   EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_exp_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_exp_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
	p_line_errors := p_line_errors +1 ;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        rollback to H_STATUS;
    WHEN OTHERS then
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_exp_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        rollback to H_STATUS;
    END line_expire;

 PROCEDURE line_active(p_active_line_rec IN line_rec_type) IS
  BEGIN


    if ((C >= T) and p_kid IS NULL) then
      commit;
      c := 0;
    end if;
   savepoint H_STATUS;
    p_line_count:= p_line_count + 1;
   l_return_status := OKC_API.G_RET_STS_SUCCESS;
   l_knum_and_mod := p_active_line_rec.contract_number||' '||p_active_line_rec.contract_number_modifier;
   l_new_status := null;
   l_new_status_m := null;

   l_line_number := p_active_line_rec.line_number;
   if (h_status_type = 'ACTIVE') then
     l_new_status := h_status;
     l_new_status_m := h_status_m;
   else
     l_new_status := v_active;
     l_new_status_m := v_active_m ;
   end if;

   l_cle_rec.id                    := p_active_line_rec.id ;
   l_cle_rec.object_version_number := p_active_line_rec.object_version_number ;
   l_cle_rec.sts_code              := l_new_status;
   l_cle_rec.dnz_chr_id := p_active_line_rec.dnz_chr_id;
--
--
-- Assign values if and oly if the change in line status is not resulting
-- from the change in header status
--
   l_cle_rec.call_action_asmblr := 'N';
--
   IF h_new_status is null and l_new_status is not null then
	l_cle_rec.old_sts_code := p_active_line_rec.sts_code;
	l_cle_rec.old_ste_code := p_active_line_rec.ste_code;
	l_cle_rec.new_sts_code := l_new_status;
	l_cle_rec.new_ste_code := 'ACTIVE';
	l_cle_rec.call_action_asmblr := 'Y';
   END IF;

--
-- lock added not to depend on update implementation
--

	okc_contract_pub.lock_contract_line(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_clev_rec                     =>     l_cle_rec);


      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--

    update_contract_line (
   		 	p_api_version                  =>     1.0,
   		 	p_init_msg_list                =>     p_init_msg_list,
                        p_update_minor_version         =>     p_update_minor_version,
                        p_contract_number              =>     p_active_line_rec.contract_number,
                        p_contract_number_modifier     =>     p_active_line_rec.contract_number_modifier,
    			x_return_status                =>     l_return_status,
    			x_msg_count                    =>     x_msg_count,
    			x_msg_data                     =>     x_msg_data,
    			p_clev_rec                     =>     l_cle_rec,
    			x_clev_rec	               =>     x_cle_rec);


      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      if p_kid is NULL then
         c := c+1;

    line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_active_line_rec.meaning,
                 p_type  =>'S');
      end if;


  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_active_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_active_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
	p_line_errors := p_line_errors +1 ;
	x_return_status := OKC_API.G_RET_STS_ERROR;
        rollback to H_STATUS;
    WHEN OTHERS then
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_active_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        rollback to H_STATUS;
 END line_active;

--bug  5930684
 PROCEDURE line_signed(p_signed_line_rec IN line_rec_type) IS
  BEGIN


    if ((C >= T) and p_kid IS NULL) then
      commit;
      c := 0;
    end if;
   savepoint H_STATUS;
    p_line_count:= p_line_count + 1;
   l_return_status := OKC_API.G_RET_STS_SUCCESS;
   l_knum_and_mod := p_signed_line_rec.contract_number||' '||p_signed_line_rec.contract_number_modifier;
   l_new_status := null;
   l_new_status_m := null;

   l_line_number := p_signed_line_rec.line_number;
   if (h_status_type = 'SIGNED') then
     l_new_status := h_status;
     l_new_status_m := h_status_m;
   else
     l_new_status := v_signed;
     l_new_status_m := v_signed_m ;
   end if;

   l_cle_rec.id                    := p_signed_line_rec.id ;
   l_cle_rec.object_version_number := p_signed_line_rec.object_version_number ;
   l_cle_rec.sts_code              := l_new_status;
   l_cle_rec.dnz_chr_id := p_signed_line_rec.dnz_chr_id;
--
--
-- Assign values if and oly if the change in line status is not resulting
-- from the change in header status
--
   l_cle_rec.call_action_asmblr := 'N';
--
   IF h_new_status is null and l_new_status is not null then
	l_cle_rec.old_sts_code := p_signed_line_rec.sts_code;
	l_cle_rec.old_ste_code := p_signed_line_rec.ste_code;
	l_cle_rec.new_sts_code := l_new_status;
	l_cle_rec.new_ste_code := 'SIGNED';
	l_cle_rec.call_action_asmblr := 'Y';
   END IF;

--
-- lock added not to depend on update implementation
--

	okc_contract_pub.lock_contract_line(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_clev_rec                     =>     l_cle_rec);


      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--

    update_contract_line (
   		 	p_api_version                  =>     1.0,
   		 	p_init_msg_list                =>     p_init_msg_list,
                        p_update_minor_version         =>     p_update_minor_version,
                        p_contract_number              =>     p_signed_line_rec.contract_number,
                        p_contract_number_modifier     =>     p_signed_line_rec.contract_number_modifier,
    			x_return_status                =>     l_return_status,
    			x_msg_count                    =>     x_msg_count,
    			x_msg_data                     =>     x_msg_data,
    			p_clev_rec                     =>     l_cle_rec,
    			x_clev_rec	               =>     x_cle_rec);


      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      if p_kid is NULL then
         c := c+1;

    line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_signed_line_rec.meaning,
                 p_type  =>'S');
      end if;


  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_signed_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_signed_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
	p_line_errors := p_line_errors +1 ;
	x_return_status := OKC_API.G_RET_STS_ERROR;
        rollback to H_STATUS;
    WHEN OTHERS then
        line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_old_status =>p_signed_line_rec.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        rollback to H_STATUS;
 END line_signed;
-- end of bug 5930684

 -- New procedure Added to Delete the --
 -- table type after each iteration --
 Procedure delete_table_type IS
 BEGIN
    l_Contract_number_tbl.delete;
    l_Contract_number_modifier_tbl.delete;
    l_Id_tbl.delete;
    l_Object_version_number_tbl.delete;
    l_sts_code_tbl.delete;
    l_date_terminated_tbl.delete;
    l_start_date_tbl.delete;
    l_end_date_tbl.delete;
    l_line_number_tbl.delete;
    l_price_negotiated_tbl.delete;
    l_dnz_chr_id_tbl.delete;
    l_termination_reason_tbl.delete;
    l_code_tbl.delete;
    l_ste_code_tbl.delete;
    l_meaning_tbl.delete;
 END delete_table_type;


BEGIN


x_return_status := OKC_API.G_RET_STS_SUCCESS;
--added for bug fix 5285247
Savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
-- terminate line

IF (h_status = 'TERMINATED') OR (h_status IS NULL) THEN
  IF p_kid IS NULL THEN

/*		Commented for Bug #3967643.
    FOR r_terminate_line in  c_terminate_line_all LOOP
        r_terminate_line_rec.contract_number := r_terminate_line.contract_number;
        r_terminate_line_rec.contract_number_modifier := r_terminate_line.contract_number_modifier;
        r_terminate_line_rec.id := r_terminate_line.id;
        r_terminate_line_rec.object_version_number := r_terminate_line.object_version_number;
        r_terminate_line_rec.sts_code := r_terminate_line.sts_code;
        r_terminate_line_rec.date_terminated := r_terminate_line.date_terminated;
        r_terminate_line_rec.start_date := r_terminate_line.start_date;
        r_terminate_line_rec.end_date := r_terminate_line.end_date;
        r_terminate_line_rec.line_number := r_terminate_line.line_number;
        r_terminate_line_rec.price_negotiated := r_terminate_line.price_negotiated;
        r_terminate_line_rec.dnz_chr_id := r_terminate_line.dnz_chr_id;
        r_terminate_line_rec.termination_reason := r_terminate_line.termination_reason;
        r_terminate_line_rec.code := r_terminate_line.code;
        r_terminate_line_rec.ste_code := r_terminate_line.ste_code;
        r_terminate_line_rec.meaning := r_terminate_line.meaning;
        line_terminate(r_terminate_line_rec);
    END LOOP; -- r_line_cursor_AHS
    commit;
    c:= 0; */
  -- Added for BUG #3967643
    IF p_from_k IS NOT NULL THEN

	-- When only the From-to Contract number range is provided
	x_num :=0;
	open c_termnt_line_all_cntr;
        LOOP -- I
	FETCH c_termnt_line_all_cntr BULK COLLECT INTO
	  l_Contract_number_tbl,
	  l_Contract_number_modifier_tbl,
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_termination_reason_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN

		i := l_Id_tbl.FIRST;
		LOOP --II
			r_terminate_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_terminate_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_terminate_line_tbl(x_num).id := l_Id_tbl(i);
			r_terminate_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_terminate_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_terminate_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_terminate_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_terminate_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_terminate_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_terminate_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_terminate_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_terminate_line_tbl(x_num).termination_reason := l_termination_reason_tbl(i);
			r_terminate_line_tbl(x_num).code := l_code_tbl(i);
			r_terminate_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_terminate_line_tbl(x_num).meaning := l_meaning_tbl(i);
			-- line_terminate(r_terminate_line_rec);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP; --II

	  END IF;
  	  Exit when c_termnt_line_all_cntr%NOTFOUND;
       END LOOP;  --I
        IF(r_terminate_line_tbl.COUNT > 0) Then
	   i := r_terminate_line_tbl.FIRST;
	   LOOP
		line_terminate(r_terminate_line_tbl(i));
	   EXIT WHEN (i = r_terminate_line_tbl.LAST);
	   i := r_terminate_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
       commit;
       c:=0;
     ELSIF (p_from_k IS NULL) AND (p_scs_code IS NOT NULL) THEN
    	   -- When only Category is provided
	x_num :=0;
	open c_termnt_line_all_category;
	LOOP       -- I
	FETCH  c_termnt_line_all_category BULK COLLECT INTO
	  l_Contract_number_tbl,
	  l_Contract_number_modifier_tbl,
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_termination_reason_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP   -- II
			r_terminate_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_terminate_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_terminate_line_tbl(x_num).id := l_Id_tbl(i);
			r_terminate_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_terminate_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_terminate_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_terminate_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_terminate_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_terminate_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_terminate_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_terminate_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_terminate_line_tbl(x_num).termination_reason := l_termination_reason_tbl(i);
			r_terminate_line_tbl(x_num).code := l_code_tbl(i);
			r_terminate_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_terminate_line_tbl(x_num).meaning := l_meaning_tbl(i);
			-- line_terminate(r_terminate_line_rec);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP; --II
	  END IF;
  	  Exit when c_termnt_line_all_category%NOTFOUND;
        END LOOP;  	--I
        IF(r_terminate_line_tbl.COUNT > 0) Then
	   i := r_terminate_line_tbl.FIRST;
	   LOOP
		line_terminate(r_terminate_line_tbl(i));
	   EXIT WHEN (i = r_terminate_line_tbl.LAST);
	   i := r_terminate_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
	commit;
	c:=0;
     ELSIF (p_from_k IS NULL) AND (p_scs_code IS NULL) THEN
	-- When no parameters are provided
	x_num :=0;
	open c_terminate_line_all;
	LOOP     -- I
	FETCH  c_terminate_line_all BULK COLLECT INTO
	  l_Contract_number_tbl,
	  l_Contract_number_modifier_tbl,
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_termination_reason_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP    --II
			r_terminate_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_terminate_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_terminate_line_tbl(x_num).id := l_Id_tbl(i);
			r_terminate_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_terminate_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_terminate_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_terminate_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_terminate_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_terminate_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_terminate_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_terminate_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_terminate_line_tbl(x_num).termination_reason := l_termination_reason_tbl(i);
			r_terminate_line_tbl(x_num).code := l_code_tbl(i);
			r_terminate_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_terminate_line_tbl(x_num).meaning := l_meaning_tbl(i);
			-- line_terminate(r_terminate_line_rec);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;   --II
	  END IF;
  	  Exit when c_terminate_line_all%NOTFOUND;
        END LOOP;   --I
       IF(r_terminate_line_tbl.COUNT > 0) Then
	   i := r_terminate_line_tbl.FIRST;
	   LOOP
		line_terminate(r_terminate_line_tbl(i));
	   EXIT WHEN (i = r_terminate_line_tbl.LAST);
	   i := r_terminate_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
	commit;
	c:=0;
    END IF;-- Added for BUG #3967643
  ELSE -- p_kid IS NULL
	x_num :=0;
	open c_terminate_line_k;
        LOOP       -- I
	FETCH  c_terminate_line_k BULK COLLECT INTO
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_termination_reason_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP    -- II
			r_terminate_line_tbl(x_num).contract_number := p_k_num;
			r_terminate_line_tbl(x_num).contract_number_modifier := p_k_num_mod;
			r_terminate_line_tbl(x_num).id := l_Id_tbl(i);
			r_terminate_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_terminate_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_terminate_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_terminate_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_terminate_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_terminate_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_terminate_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_terminate_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_terminate_line_tbl(x_num).termination_reason := l_termination_reason_tbl(i);
			r_terminate_line_tbl(x_num).code := l_code_tbl(i);
			r_terminate_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_terminate_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;   --II
	  END IF;
  	  Exit when c_terminate_line_k%NOTFOUND;
        END LOOP;  --I
        IF(r_terminate_line_tbl.COUNT > 0) Then
	   i := r_terminate_line_tbl.FIRST;
	   LOOP
		line_terminate(r_terminate_line_tbl(i));
	   EXIT WHEN (i = r_terminate_line_tbl.LAST);
	   i := r_terminate_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
  END IF;
END IF;   -- End if for termination condition.

l_new_status  := null;
l_new_status_m := null;
l_knum_and_mod := null;
l_line_number := null;

delete_table_type;
---------------------------------------------------------------------------------
--Added for bug 5402421
Savepoint H_STATUS;

l_return_status := OKC_API.G_RET_STS_SUCCESS;
-- From ACTIVE/SIGNED to Expired
IF (h_status = 'EXPIRED') OR (h_status IS NULL) THEN
  IF p_kid IS NULL THEN
       /*		Commented for Bug #3967643.
    FOR r_expired_line in  c_expired_line_all LOOP
        r_expired_line_rec.contract_number := r_expired_line.contract_number;
        r_expired_line_rec.contract_number_modifier := r_expired_line.contract_number_modifier;
        r_expired_line_rec.id := r_expired_line.id;
        r_expired_line_rec.object_version_number := r_expired_line.object_version_number;
        r_expired_line_rec.sts_code := r_expired_line.sts_code;
        r_expired_line_rec.date_terminated := r_expired_line.date_terminated;
        r_expired_line_rec.start_date := r_expired_line.start_date;
        r_expired_line_rec.end_date := r_expired_line.end_date;
        r_expired_line_rec.line_number := r_expired_line.line_number;
        r_expired_line_rec.price_negotiated := r_expired_line.price_negotiated;
        r_expired_line_rec.dnz_chr_id := r_expired_line.dnz_chr_id;
        r_expired_line_rec.termination_reason := NULL;
        r_expired_line_rec.code := r_expired_line.code;
        r_expired_line_rec.ste_code := r_expired_line.ste_code;
        r_expired_line_rec.meaning := r_expired_line.meaning;
        line_expire(r_expired_line_rec);
    END LOOP; -- r_line_cursor_AHS
    commit;
    c:= 0;*/
  -- Added for BUG #3967643
    IF p_from_k IS NOT NULL THEN

	   -- When only the From-to Contract number range is provided
	/* FOR r_expired_line in  c_expr_line_all_cntr LOOP


           r_expired_line_rec.contract_number := r_expired_line.contract_number;
           r_expired_line_rec.contract_number_modifier := r_expired_line.contract_number_modifier;
           r_expired_line_rec.id := r_expired_line.id;
           r_expired_line_rec.object_version_number := r_expired_line.object_version_number;
           r_expired_line_rec.sts_code := r_expired_line.sts_code;
           r_expired_line_rec.date_terminated := r_expired_line.date_terminated;
           r_expired_line_rec.start_date := r_expired_line.start_date;
           r_expired_line_rec.end_date := r_expired_line.end_date;
           r_expired_line_rec.line_number := r_expired_line.line_number;
           r_expired_line_rec.price_negotiated := r_expired_line.price_negotiated;
           r_expired_line_rec.dnz_chr_id := r_expired_line.dnz_chr_id;
           r_expired_line_rec.termination_reason := NULL;
           r_expired_line_rec.code := r_expired_line.code;
           r_expired_line_rec.ste_code := r_expired_line.ste_code;
           r_expired_line_rec.meaning := r_expired_line.meaning;

           line_expire(r_expired_line_rec);
       END LOOP; -- r_line_cursor_AHS
       commit;
       c:= 0;*/
	x_num :=0;
	open  c_expr_line_all_cntr;
       	LOOP	-- I
	FETCH  c_expr_line_all_cntr BULK COLLECT INTO

	  l_Contract_number_tbl,
	  l_Contract_number_modifier_tbl,
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP    -- II
			r_expired_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_expired_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_expired_line_tbl(x_num).id := l_Id_tbl(i);
			r_expired_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_expired_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_expired_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_expired_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_expired_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_expired_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_expired_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_expired_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_expired_line_tbl(x_num).termination_reason :=NULL;
			r_expired_line_tbl(x_num).code := l_code_tbl(i);
			r_expired_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_expired_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP; --II
	  END IF;
  	  Exit when c_expr_line_all_cntr%NOTFOUND;
        END LOOP;  --I
	IF(r_expired_line_tbl.COUNT > 0) Then
	   i := r_expired_line_tbl.FIRST;
	   LOOP
		line_expire(r_expired_line_tbl(i));
	   EXIT WHEN (i = r_expired_line_tbl.LAST);
	   i := r_expired_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
	commit;
	c:=0;
	ELSIF (p_from_k IS NULL) AND (p_scs_code IS NOT NULL) THEN

	   -- When only Category is provided
	  /*FOR r_expired_line in c_expr_line_all_category LOOP

           r_expired_line_rec.contract_number := r_expired_line.contract_number;
           r_expired_line_rec.contract_number_modifier := r_expired_line.contract_number_modifier;
           r_expired_line_rec.id := r_expired_line.id;
           r_expired_line_rec.object_version_number := r_expired_line.object_version_number;
           r_expired_line_rec.sts_code := r_expired_line.sts_code;
           r_expired_line_rec.date_terminated := r_expired_line.date_terminated;
           r_expired_line_rec.start_date := r_expired_line.start_date;
           r_expired_line_rec.end_date := r_expired_line.end_date;
           r_expired_line_rec.line_number := r_expired_line.line_number;
           r_expired_line_rec.price_negotiated := r_expired_line.price_negotiated;
           r_expired_line_rec.dnz_chr_id := r_expired_line.dnz_chr_id;
           r_expired_line_rec.termination_reason := NULL;
           r_expired_line_rec.code := r_expired_line.code;
           r_expired_line_rec.ste_code := r_expired_line.ste_code;
           r_expired_line_rec.meaning := r_expired_line.meaning;

           line_expire(r_expired_line_rec);

	   END LOOP; -- r_line_cursor_AHS */
          x_num :=0;
	  open c_expr_line_all_category;
	  LOOP	--I
	  FETCH  c_expr_line_all_category BULK COLLECT INTO
	  l_Contract_number_tbl,
	  l_Contract_number_modifier_tbl,
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP	--II
			r_expired_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_expired_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_expired_line_tbl(x_num).id := l_Id_tbl(i);
			r_expired_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_expired_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_expired_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_expired_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_expired_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_expired_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_expired_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_expired_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_expired_line_tbl(x_num).termination_reason := NULL;
			r_expired_line_tbl(x_num).code := l_code_tbl(i);
			r_expired_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_expired_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;	--II
	  END IF;
  	  Exit when c_expr_line_all_category%NOTFOUND;
        END LOOP;  --I
        IF(r_expired_line_tbl.COUNT > 0) Then
	   i := r_expired_line_tbl.FIRST;
	   LOOP
		line_expire(r_expired_line_tbl(i));
	   EXIT WHEN (i = r_expired_line_tbl.LAST);
	   i := r_expired_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
        commit;
        c:= 0;
      ELSIF (p_from_k IS NULL) AND (p_scs_code IS NULL) THEN

	   -- When no parameters are provided
	/*   FOR r_expired_line in c_expired_line_all LOOP

           r_expired_line_rec.contract_number := r_expired_line.contract_number;
           r_expired_line_rec.contract_number_modifier := r_expired_line.contract_number_modifier;
           r_expired_line_rec.id := r_expired_line.id;
           r_expired_line_rec.object_version_number := r_expired_line.object_version_number;
           r_expired_line_rec.sts_code := r_expired_line.sts_code;
           r_expired_line_rec.date_terminated := r_expired_line.date_terminated;
           r_expired_line_rec.start_date := r_expired_line.start_date;
           r_expired_line_rec.end_date := r_expired_line.end_date;
           r_expired_line_rec.line_number := r_expired_line.line_number;
           r_expired_line_rec.price_negotiated := r_expired_line.price_negotiated;
           r_expired_line_rec.dnz_chr_id := r_expired_line.dnz_chr_id;
           r_expired_line_rec.termination_reason := NULL;
           r_expired_line_rec.code := r_expired_line.code;
           r_expired_line_rec.ste_code := r_expired_line.ste_code;
           r_expired_line_rec.meaning := r_expired_line.meaning;


           line_expire(r_expired_line_rec);
       END LOOP; -- r_line_cursor_AHS
       commit;
       c:= 0; */
       x_num :=0;
       open c_expired_line_all;
       LOOP	--I
	FETCH  c_expired_line_all BULK COLLECT INTO
	  l_Contract_number_tbl,
	  l_Contract_number_modifier_tbl,
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP	--II
			r_expired_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_expired_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_expired_line_tbl(x_num).id := l_Id_tbl(i);
			r_expired_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_expired_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_expired_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_expired_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_expired_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_expired_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_expired_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_expired_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_expired_line_tbl(x_num).termination_reason :=NULL;
			r_expired_line_tbl(x_num).code := l_code_tbl(i);
			r_expired_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_expired_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;	--II
	  END IF;
  	  Exit when c_expired_line_all%NOTFOUND;
        END LOOP;  		--I
       IF(r_expired_line_tbl.COUNT > 0) Then
	   i := r_expired_line_tbl.FIRST;
	   LOOP
		line_expire(r_expired_line_tbl(i));
	   EXIT WHEN (i = r_expired_line_tbl.LAST);
	   i := r_expired_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
       commit;
       c:= 0;

	END IF;-- Added for BUG #3967643
  ELSE  -- p_kid IS NULL

       /* FOR r_expired_line in  c_expired_line_k LOOP


        r_expired_line_rec.contract_number := p_k_num;
        r_expired_line_rec.contract_number_modifier := p_k_num_mod;
        r_expired_line_rec.id := r_expired_line.id;
        r_expired_line_rec.object_version_number := r_expired_line.object_version_number;
        r_expired_line_rec.sts_code := r_expired_line.sts_code;
        r_expired_line_rec.date_terminated := r_expired_line.date_terminated;
        r_expired_line_rec.start_date := r_expired_line.start_date;
        r_expired_line_rec.end_date := r_expired_line.end_date;
        r_expired_line_rec.line_number := r_expired_line.line_number;
        r_expired_line_rec.price_negotiated := r_expired_line.price_negotiated;
        r_expired_line_rec.dnz_chr_id := r_expired_line.dnz_chr_id;
        r_expired_line_rec.termination_reason := NULL;
        r_expired_line_rec.code := r_expired_line.code;
        r_expired_line_rec.ste_code := r_expired_line.ste_code;
        r_expired_line_rec.meaning := r_expired_line.meaning;

        line_expire(r_expired_line_rec);
        END LOOP; -- r_line_cursor_AHS */
	x_num :=0;
	open c_expired_line_k;
        LOOP		-- I
	FETCH  c_expired_line_k BULK COLLECT INTO
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP	--II
			r_expired_line_tbl(x_num).contract_number := p_k_num;
			r_expired_line_tbl(x_num).contract_number_modifier := p_k_num_mod;
			r_expired_line_tbl(x_num).id := l_Id_tbl(i);
			r_expired_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_expired_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_expired_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_expired_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_expired_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_expired_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_expired_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_expired_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_expired_line_tbl(x_num).termination_reason := NULL;
			r_expired_line_tbl(x_num).code := l_code_tbl(i);
			r_expired_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_expired_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;	--II
	  END IF;
  	  Exit when c_expired_line_k%NOTFOUND;
        END LOOP;	--I
       IF(r_expired_line_tbl.COUNT > 0) Then
	   i := r_expired_line_tbl.FIRST;
	   LOOP
		line_expire(r_expired_line_tbl(i));
	   EXIT WHEN (i = r_expired_line_tbl.LAST);
	   i := r_expired_line_tbl.NEXT(i);
	   END LOOP;
       END IF;
   END IF;
END IF; --
l_return_status := OKC_API.G_RET_STS_SUCCESS;
l_new_status  := null;
l_new_status_m := null;
l_knum_and_mod := null;
l_line_number := null;

delete_table_type;

--added for bug fix 5402421
Savepoint H_STATUS;

-- From Signed to Active
IF h_status = 'ACTIVE' OR h_status IS NULL THEN
  IF p_kid IS NULL THEN
  /*		Commented for Bug #3967643.
    FOR r_active_line in  c_active_line_all LOOP
        r_active_line_rec.contract_number := r_active_line.contract_number;
        r_active_line_rec.contract_number_modifier := r_active_line.contract_number_modifier;
        r_active_line_rec.id := r_active_line.id;
        r_active_line_rec.object_version_number := r_active_line.object_version_number;
        r_active_line_rec.sts_code := r_active_line.sts_code;
        r_active_line_rec.date_terminated := r_active_line.date_terminated;
        r_active_line_rec.start_date := r_active_line.start_date;
        r_active_line_rec.end_date := r_active_line.end_date;
        r_active_line_rec.line_number := r_active_line.line_number;
        r_active_line_rec.price_negotiated := r_active_line.price_negotiated;
        r_active_line_rec.dnz_chr_id := r_active_line.dnz_chr_id;
        r_active_line_rec.termination_reason := NULL;
        r_active_line_rec.code := r_active_line.code;
        r_active_line_rec.ste_code := r_active_line.ste_code;
        r_active_line_rec.meaning := r_active_line.meaning;
        line_active(r_active_line_rec);
    END LOOP; -- r_line_cursor_AHS
    commit;
    c:= 0;*/
  -- Added for BUG #3967643
    IF p_from_k IS NOT NULL THEN
	   -- When only the From-to Contract number range is provided
	/* FOR r_active_line in  c_actv_line_all_cntr LOOP
	  r_active_line_rec.contract_number := r_active_line.contract_number;
	  r_active_line_rec.contract_number_modifier := r_active_line.contract_number_modifier;
          r_active_line_rec.id := r_active_line.id;
          r_active_line_rec.object_version_number := r_active_line.object_version_number;
        r_active_line_rec.sts_code := r_active_line.sts_code;
        r_active_line_rec.date_terminated := r_active_line.date_terminated;
        r_active_line_rec.start_date := r_active_line.start_date;
        r_active_line_rec.end_date := r_active_line.end_date;
        r_active_line_rec.line_number := r_active_line.line_number;
        r_active_line_rec.price_negotiated := r_active_line.price_negotiated;
        r_active_line_rec.dnz_chr_id := r_active_line.dnz_chr_id;
        r_active_line_rec.termination_reason := NULL;
        r_active_line_rec.code := r_active_line.code;
        r_active_line_rec.ste_code := r_active_line.ste_code;
        r_active_line_rec.meaning := r_active_line.meaning;


        line_active(r_active_line_rec);
	END LOOP; -- r_line_cursor_AHS
	commit;
	c:= 0; */
	x_num :=0;
	open c_actv_line_all_cntr;
	LOOP	--I
	FETCH  c_actv_line_all_cntr BULK COLLECT INTO
	  l_Contract_number_tbl,
	  l_Contract_number_modifier_tbl,
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP	--II
			r_active_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_active_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_active_line_tbl(x_num).id := l_Id_tbl(i);
			r_active_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_active_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_active_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_active_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_active_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_active_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_active_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_active_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_active_line_tbl(x_num).termination_reason := NULL;
			r_active_line_tbl(x_num).code := l_code_tbl(i);
			r_active_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_active_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;	--II
	  END IF;
  	  Exit when c_actv_line_all_cntr%NOTFOUND;
        END LOOP;	--I
        IF(r_active_line_tbl.COUNT > 0) Then
	   i := r_active_line_tbl.FIRST;
	   LOOP
		line_active(r_active_line_tbl(i));
	   EXIT WHEN (i = r_active_line_tbl.LAST);
	   i := r_active_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
       commit;
       c:= 0;

	ELSIF (p_from_k IS NULL) AND (p_scs_code IS NOT NULL) THEN
	   -- When only Category is provided
	  /* FOR r_active_line in c_actv_line_all_category LOOP


		r_active_line_rec.contract_number := r_active_line.contract_number;
		r_active_line_rec.contract_number_modifier := r_active_line.contract_number_modifier;
		r_active_line_rec.id := r_active_line.id;
		r_active_line_rec.object_version_number := r_active_line.object_version_number;
		r_active_line_rec.sts_code := r_active_line.sts_code;
		r_active_line_rec.date_terminated := r_active_line.date_terminated;
		r_active_line_rec.start_date := r_active_line.start_date;
		r_active_line_rec.end_date := r_active_line.end_date;
		r_active_line_rec.line_number := r_active_line.line_number;
		r_active_line_rec.price_negotiated := r_active_line.price_negotiated;
		r_active_line_rec.dnz_chr_id := r_active_line.dnz_chr_id;
		r_active_line_rec.termination_reason := NULL;
		r_active_line_rec.code := r_active_line.code;
		r_active_line_rec.ste_code := r_active_line.ste_code;
		r_active_line_rec.meaning := r_active_line.meaning;

	      line_active(r_active_line_rec);
	    END LOOP; -- r_line_cursor_AHS
	    commit;
	    c:= 0;*/
	    x_num :=0;
	    open c_actv_line_all_category;
	    LOOP	--I
	    FETCH  c_actv_line_all_category BULK COLLECT INTO
		l_Contract_number_tbl,
		l_Contract_number_modifier_tbl,
		l_Id_tbl,
		l_Object_version_number_tbl,
		l_sts_code_tbl,
		l_date_terminated_tbl,
		l_start_date_tbl,
		l_end_date_tbl,
		l_line_number_tbl,
		l_price_negotiated_tbl,
		l_dnz_chr_id_tbl,
		l_code_tbl,
		l_ste_code_tbl,
		l_meaning_tbl
	   LIMIT 1000;
	   IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	   END IF;
	   IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP	--II
			r_active_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_active_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_active_line_tbl(x_num).id := l_Id_tbl(i);
			r_active_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_active_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_active_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_active_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_active_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_active_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_active_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_active_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_active_line_tbl(x_num).termination_reason := NULL;
			r_active_line_tbl(x_num).code := l_code_tbl(i);
			r_active_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_active_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;	--II
	  END IF;
  	  Exit when c_actv_line_all_category%NOTFOUND;
          END LOOP;  	--I
          IF(r_active_line_tbl.COUNT > 0) Then
	   i := r_active_line_tbl.FIRST;
	   LOOP
		line_active(r_active_line_tbl(i));
	   EXIT WHEN (i = r_active_line_tbl.LAST);
	   i := r_active_line_tbl.NEXT(i);
	   END LOOP;
          END IF;
          commit;
          c:= 0;
       ELSIF (p_from_k IS NULL) AND (p_scs_code IS NULL) THEN
	   -- When no parameters are provided
		/* FOR r_active_line in c_active_line_all LOOP


	        r_active_line_rec.contract_number := r_active_line.contract_number;
	        r_active_line_rec.contract_number_modifier := r_active_line.contract_number_modifier;
	        r_active_line_rec.id := r_active_line.id;
	        r_active_line_rec.object_version_number := r_active_line.object_version_number;
	        r_active_line_rec.sts_code := r_active_line.sts_code;
	        r_active_line_rec.date_terminated := r_active_line.date_terminated;
	        r_active_line_rec.start_date := r_active_line.start_date;
	        r_active_line_rec.end_date := r_active_line.end_date;
	        r_active_line_rec.line_number := r_active_line.line_number;
	        r_active_line_rec.price_negotiated := r_active_line.price_negotiated;
	        r_active_line_rec.dnz_chr_id := r_active_line.dnz_chr_id;
	        r_active_line_rec.termination_reason := NULL;
	        r_active_line_rec.code := r_active_line.code;
	        r_active_line_rec.ste_code := r_active_line.ste_code;
	        r_active_line_rec.meaning := r_active_line.meaning;

	        line_active(r_active_line_rec);
		END LOOP; -- r_line_cursor_AHS */
	    x_num :=0;
	    open c_active_line_all;
            LOOP	--I
	    FETCH  c_active_line_all BULK COLLECT INTO
		l_Contract_number_tbl,
		l_Contract_number_modifier_tbl,
		l_Id_tbl,
		l_Object_version_number_tbl,
		l_sts_code_tbl,
		l_date_terminated_tbl,
		l_start_date_tbl,
		l_end_date_tbl,
		l_line_number_tbl,
		l_price_negotiated_tbl,
		l_dnz_chr_id_tbl,
		l_code_tbl,
		l_ste_code_tbl,
		l_meaning_tbl
		LIMIT 1000;
		IF (l_Id_tbl.COUNT < 1) THEN
			EXIT;
		END IF;
		IF (l_Id_tbl.COUNT > 0) THEN
			i := l_Id_tbl.FIRST;
		   LOOP	--II
			r_active_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_active_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_active_line_tbl(x_num).id := l_Id_tbl(i);
			r_active_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_active_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_active_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_active_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_active_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_active_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_active_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_active_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_active_line_tbl(x_num).termination_reason := NULL;
			r_active_line_tbl(x_num).code := l_code_tbl(i);
			r_active_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_active_line_tbl(x_num).meaning := l_meaning_tbl(i);
		    x_num :=x_num+1;
		    EXIT WHEN (i = l_Id_tbl.LAST);
		    i := l_Id_tbl.NEXT(i);
		    END LOOP;	--II
	      END IF;
  	      Exit when c_active_line_all%NOTFOUND;
         END LOOP;  	--I
         IF(r_active_line_tbl.COUNT > 0) Then
	   i := r_active_line_tbl.FIRST;
	   LOOP
		line_active(r_active_line_tbl(i));
	   EXIT WHEN (i = r_active_line_tbl.LAST);
	   i := r_active_line_tbl.NEXT(i);
	   END LOOP;
         END IF;

	 commit;
	 c:= 0;
	END IF;-- Added for BUG #3967643
  ELSE  -- p_kid IS NULL

   /* FOR r_active_line in  c_active_line_k LOOP


        r_active_line_rec.contract_number := p_k_num;
        r_active_line_rec.contract_number_modifier := p_k_num_mod;
        r_active_line_rec.id := r_active_line.id;
        r_active_line_rec.object_version_number := r_active_line.object_version_number;
        r_active_line_rec.sts_code := r_active_line.sts_code;
        r_active_line_rec.date_terminated := r_active_line.date_terminated;
        r_active_line_rec.start_date := r_active_line.start_date;
        r_active_line_rec.end_date := r_active_line.end_date;
        r_active_line_rec.line_number := r_active_line.line_number;
        r_active_line_rec.price_negotiated := r_active_line.price_negotiated;
        r_active_line_rec.dnz_chr_id := r_active_line.dnz_chr_id;
        r_active_line_rec.termination_reason := NULL;
        r_active_line_rec.code := r_active_line.code;
        r_active_line_rec.ste_code := r_active_line.ste_code;
        r_active_line_rec.meaning := r_active_line.meaning;

        line_active(r_active_line_rec);
    END LOOP; -- r_line_cursor_AHS */
	    x_num :=0;
	    open c_active_line_k;
	    LOOP	--I
	    FETCH  c_active_line_k BULK COLLECT INTO
		l_Id_tbl,
		l_Object_version_number_tbl,
		l_sts_code_tbl,
		l_date_terminated_tbl,
		l_start_date_tbl,
		l_end_date_tbl,
		l_line_number_tbl,
		l_price_negotiated_tbl,
		l_dnz_chr_id_tbl,
		l_code_tbl,
		l_ste_code_tbl,
		l_meaning_tbl
		LIMIT 1000;
		IF (l_Id_tbl.COUNT < 1) THEN
			EXIT;
		END IF;
		IF (l_Id_tbl.COUNT > 0) THEN
			i := l_Id_tbl.FIRST;
			LOOP	--II
			r_active_line_tbl(x_num).contract_number := p_k_num;
			r_active_line_tbl(x_num).contract_number_modifier := p_k_num_mod;
			r_active_line_tbl(x_num).id := l_Id_tbl(i);
			r_active_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_active_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_active_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_active_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_active_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_active_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_active_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_active_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_active_line_tbl(x_num).termination_reason := NULL;
			r_active_line_tbl(x_num).code := l_code_tbl(i);
			r_active_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_active_line_tbl(x_num).meaning := l_meaning_tbl(i);
			x_num :=x_num+1;
			EXIT WHEN (i = l_Id_tbl.LAST);
			i := l_Id_tbl.NEXT(i);
			END LOOP;	--II
	      END IF;
  	      Exit when c_active_line_k%NOTFOUND;
         END LOOP;  	--I
         IF(r_active_line_tbl.COUNT > 0) Then
	   i := r_active_line_tbl.FIRST;
	   LOOP
		line_active(r_active_line_tbl(i));
	   EXIT WHEN (i = r_active_line_tbl.LAST);
	   i := r_active_line_tbl.NEXT(i);
	   END LOOP;
         END IF;
  END IF;
END IF;

Savepoint H_STATUS;

l_return_status := OKC_API.G_RET_STS_SUCCESS;
l_new_status  := null;
l_new_status_m := null;
l_knum_and_mod := null;
l_line_number := null;

delete_table_type;
-------------------------------------------------------------------------
-- BUG 5930684
-- From  Active To Signed
IF h_status = 'SIGNED' OR h_status IS NULL THEN
  IF p_kid IS NULL THEN
  -- Added for BUG #3967643
    IF p_from_k IS NOT NULL THEN
	   -- When only the From-to Contract number range is provided
	x_num :=0;
	open c_sign_line_all_cntr;
	LOOP	--I
	FETCH  c_sign_line_all_cntr BULK COLLECT INTO
	  l_Contract_number_tbl,
	  l_Contract_number_modifier_tbl,
	  l_Id_tbl,
	  l_Object_version_number_tbl,
	  l_sts_code_tbl,
	  l_date_terminated_tbl,
	  l_start_date_tbl,
	  l_end_date_tbl,
	  l_line_number_tbl,
	  l_price_negotiated_tbl,
	  l_dnz_chr_id_tbl,
	  l_code_tbl,
	  l_ste_code_tbl,
	  l_meaning_tbl
	  LIMIT 1000;
	  IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	  END IF;
	  IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP	--II
			r_signed_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_signed_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_signed_line_tbl(x_num).id := l_Id_tbl(i);
			r_signed_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_signed_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_signed_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_signed_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_signed_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_signed_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_signed_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_signed_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_signed_line_tbl(x_num).termination_reason := NULL;
			r_signed_line_tbl(x_num).code := l_code_tbl(i);
			r_signed_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_signed_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;	--II
	  END IF;
  	  Exit when c_sign_line_all_cntr%NOTFOUND;
        END LOOP;	--I
        IF(r_signed_line_tbl.COUNT > 0) Then
	   i := r_signed_line_tbl.FIRST;
	   LOOP
		line_signed(r_signed_line_tbl(i));
	   EXIT WHEN (i = r_signed_line_tbl.LAST);
	   i := r_signed_line_tbl.NEXT(i);
	   END LOOP;
        END IF;
       commit;
       c:= 0;

	ELSIF (p_from_k IS NULL) AND (p_scs_code IS NOT NULL) THEN
	   -- When only Category is provided

	    x_num :=0;
	    open c_sign_line_all_category;
	    LOOP	--I
	    FETCH  c_sign_line_all_category BULK COLLECT INTO
		l_Contract_number_tbl,
		l_Contract_number_modifier_tbl,
		l_Id_tbl,
		l_Object_version_number_tbl,
		l_sts_code_tbl,
		l_date_terminated_tbl,
		l_start_date_tbl,
		l_end_date_tbl,
		l_line_number_tbl,
		l_price_negotiated_tbl,
		l_dnz_chr_id_tbl,
		l_code_tbl,
		l_ste_code_tbl,
		l_meaning_tbl
	   LIMIT 1000;
	   IF (l_Id_tbl.COUNT < 1) THEN
		EXIT;
	   END IF;
	   IF (l_Id_tbl.COUNT > 0) THEN
		i := l_Id_tbl.FIRST;
		LOOP	--II
			r_signed_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_signed_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_signed_line_tbl(x_num).id := l_Id_tbl(i);
			r_signed_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_signed_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_signed_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_signed_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_signed_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_signed_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_signed_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_signed_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_signed_line_tbl(x_num).termination_reason := NULL;
			r_signed_line_tbl(x_num).code := l_code_tbl(i);
			r_signed_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_signed_line_tbl(x_num).meaning := l_meaning_tbl(i);
		x_num :=x_num+1;
		EXIT WHEN (i = l_Id_tbl.LAST);
		i := l_Id_tbl.NEXT(i);
		END LOOP;	--II
	  END IF;
  	  Exit when c_sign_line_all_category%NOTFOUND;
          END LOOP;  	--I
          IF(r_signed_line_tbl.COUNT > 0) Then
	   i := r_signed_line_tbl.FIRST;
	   LOOP
		line_signed(r_signed_line_tbl(i));
	   EXIT WHEN (i = r_signed_line_tbl.LAST);
	   i := r_signed_line_tbl.NEXT(i);
	   END LOOP;
          END IF;
          commit;
          c:= 0;
       ELSIF (p_from_k IS NULL) AND (p_scs_code IS NULL) THEN
	   -- When no parameters are provided

	    x_num :=0;
	    open c_signed_line_all;
            LOOP	--I
	    FETCH  c_signed_line_all BULK COLLECT INTO
		l_Contract_number_tbl,
		l_Contract_number_modifier_tbl,
		l_Id_tbl,
		l_Object_version_number_tbl,
		l_sts_code_tbl,
		l_date_terminated_tbl,
		l_start_date_tbl,
		l_end_date_tbl,
		l_line_number_tbl,
		l_price_negotiated_tbl,
		l_dnz_chr_id_tbl,
		l_code_tbl,
		l_ste_code_tbl,
		l_meaning_tbl
		LIMIT 1000;
		IF (l_Id_tbl.COUNT < 1) THEN
			EXIT;
		END IF;
		IF (l_Id_tbl.COUNT > 0) THEN
			i := l_Id_tbl.FIRST;
		   LOOP	--II
			r_signed_line_tbl(x_num).contract_number := l_Contract_number_tbl(i);
			r_signed_line_tbl(x_num).contract_number_modifier := l_Contract_number_modifier_tbl(i);
			r_signed_line_tbl(x_num).id := l_Id_tbl(i);
			r_signed_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_signed_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_signed_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_signed_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_signed_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_signed_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_signed_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_signed_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_signed_line_tbl(x_num).termination_reason := NULL;
			r_signed_line_tbl(x_num).code := l_code_tbl(i);
			r_signed_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_signed_line_tbl(x_num).meaning := l_meaning_tbl(i);
		    x_num :=x_num+1;
		    EXIT WHEN (i = l_Id_tbl.LAST);
		    i := l_Id_tbl.NEXT(i);
		    END LOOP;	--II
	      END IF;
  	      Exit when c_signed_line_all%NOTFOUND;
         END LOOP;  	--I
         IF(r_signed_line_tbl.COUNT > 0) Then
	   i := r_signed_line_tbl.FIRST;
	   LOOP
		line_signed(r_signed_line_tbl(i));
	   EXIT WHEN (i = r_signed_line_tbl.LAST);
	   i := r_signed_line_tbl.NEXT(i);
	   END LOOP;
         END IF;

	 commit;
	 c:= 0;
	END IF;-- Added for BUG #3967643
  ELSE  -- p_kid IS NULL

	    x_num :=0;
	    open c_signed_line_k;
	    LOOP	--I
	    FETCH  c_signed_line_k BULK COLLECT INTO
		l_Id_tbl,
		l_Object_version_number_tbl,
		l_sts_code_tbl,
		l_date_terminated_tbl,
		l_start_date_tbl,
		l_end_date_tbl,
		l_line_number_tbl,
		l_price_negotiated_tbl,
		l_dnz_chr_id_tbl,
		l_code_tbl,
		l_ste_code_tbl,
		l_meaning_tbl
		LIMIT 1000;
		IF (l_Id_tbl.COUNT < 1) THEN
			EXIT;
		END IF;
		IF (l_Id_tbl.COUNT > 0) THEN
			i := l_Id_tbl.FIRST;
			LOOP	--II
			r_signed_line_tbl(x_num).contract_number := p_k_num;
			r_signed_line_tbl(x_num).contract_number_modifier := p_k_num_mod;
			r_signed_line_tbl(x_num).id := l_Id_tbl(i);
			r_signed_line_tbl(x_num).object_version_number := l_Object_version_number_tbl(i);
			r_signed_line_tbl(x_num).sts_code := l_sts_code_tbl(i);
			r_signed_line_tbl(x_num).date_terminated := l_date_terminated_tbl(i);
			r_signed_line_tbl(x_num).start_date := l_start_date_tbl(i);
			r_signed_line_tbl(x_num).end_date := l_end_date_tbl(i);
			r_signed_line_tbl(x_num).line_number := l_line_number_tbl(i);
			r_signed_line_tbl(x_num).price_negotiated := l_price_negotiated_tbl(i);
			r_signed_line_tbl(x_num).dnz_chr_id := l_dnz_chr_id_tbl(i);
			r_signed_line_tbl(x_num).termination_reason := NULL;
			r_signed_line_tbl(x_num).code := l_code_tbl(i);
			r_signed_line_tbl(x_num).ste_code := l_ste_code_tbl(i);
			r_signed_line_tbl(x_num).meaning := l_meaning_tbl(i);
			x_num :=x_num+1;
			EXIT WHEN (i = l_Id_tbl.LAST);
			i := l_Id_tbl.NEXT(i);
			END LOOP;	--II
	      END IF;
  	      Exit when c_signed_line_k%NOTFOUND;
         END LOOP;  	--I
         IF(r_signed_line_tbl.COUNT > 0) Then
	   i := r_signed_line_tbl.FIRST;
	   LOOP
		line_signed(r_signed_line_tbl(i));
	   EXIT WHEN (i = r_signed_line_tbl.LAST);
	   i := r_signed_line_tbl.NEXT(i);
	   END LOOP;
         END IF;
  END IF;
END IF;
--END OF BUG 5930684

delete_table_type;
-------------------------------------------------------------------------

EXCEPTION
  WHEN OTHERS THEN
    line_message(p_knum_and_mod =>l_knum_and_mod,
                 p_line_number=>l_line_number,
                 p_status =>l_new_status,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_line_errors := p_line_errors +1 ;
    rollback to H_STATUS;
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
return;

END; -- procedure line_status_change
-- BUG 4285665 --
-- NEW --
-----------------------------------------------------------------
-- End LINE Status change procedure
-----------------------------------------------------------------

-----------------------------------------------------------------
-- End LINE Status change procedure
-----------------------------------------------------------------


-----------------------------------------------------------------
-- Begin Status change procedure
-----------------------------------------------------------------
Procedure header_message(p_knum_and_mod IN VARCHAR2,
                       p_old_status      IN VARCHAR2 DEFAULT NULL,
                       p_status      IN VARCHAR2 DEFAULT NULL,
                       p_msg_data    IN VARCHAR2 DEFAULT NULL,
                       p_type     IN VARCHAR2) IS
BEGIN
  if p_type='S' Then
/*
        FND_MESSAGE.set_name('OKC','OKC_HDR_STS_CHANGE_SUCCESS');
        FND_MESSAGE.set_token('CONTRACT_NUMBER', p_knum_and_mod);
        FND_MESSAGE.set_token('OLD_STATUS', p_old_status);
        FND_MESSAGE.set_token('STATUS', p_status);
        FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
*/
        NULL;
  elsif p_type='E'Then
        get_fnd_msg_stack(p_msg_data);
	p_hdr_errors := p_hdr_errors +1 ;
        FND_MESSAGE.set_name('OKC','OKC_HDR_STS_CHANGE_FAILURE');
        FND_MESSAGE.set_token('CONTRACT_NUMBER', p_knum_and_mod);
        FND_MESSAGE.set_token('OLD_STATUS', p_old_status);
        FND_MESSAGE.set_token('STATUS', p_status);
        FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
  elsif p_type='U'Then
        get_fnd_msg_stack(p_msg_data);
        FND_MESSAGE.set_name('OKC',G_UNEXPECTED_ERROR);
        FND_MESSAGE.set_token(G_SQLCODE_TOKEN,SQLCODE);
        FND_MESSAGE.set_token(G_SQLERRM_TOKEN,SQLERRM);
        FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
        FND_MESSAGE.set_name('OKC','OKC_HDR_STS_CHANGE_FAILURE');
        FND_MESSAGE.set_token('CONTRACT_NUMBER', p_knum_and_mod);
        FND_MESSAGE.set_token('OLD_STATUS', p_old_status);
        FND_MESSAGE.set_token('STATUS', p_status);
        FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
  end if;
end header_message;

PROCEDURE WrapUp IS
 BEGIN
   ----------------------------------------------------------------------------------------
   ---LOG MESSAGES (SUMMARY)
   ----------------------------------------------------------------------------------------
   FND_FILE.PUT_LINE( FND_FILE.LOG,'   ');
   FND_FILE.PUT_LINE( FND_FILE.LOG,'   ');
   FND_MESSAGE.set_name('OKC','OKC_SUMMARY');
   FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
   IF p_hdr_errors > 0 or p_line_errors > 0 then
     FND_FILE.PUT_LINE( FND_FILE.LOG,'--------------------------------------');
     FND_MESSAGE.set_name('OKC','OKC_HDR_NUM_ERRORS');
     FND_MESSAGE.set_token('HEADER_ERROR', p_hdr_errors);
     FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'   ');
     FND_MESSAGE.set_name('OKC','OKC_LINE_NUM_ERRORS');
     FND_MESSAGE.set_token('LINE_ERRORS', p_line_errors);
     FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
     FND_FILE.PUT_LINE( FND_FILE.LOG,'--------------------------------------');
     FND_MESSAGE.set_name('OKC','OKC_HDR_NUM_ERRORS');
     FND_MESSAGE.set_token('HEADER_ERROR', p_hdr_errors);
     FND_FILE.PUT_LINE( FND_FILE.OUTPUT,FND_MESSAGE.GET);
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');
     FND_MESSAGE.set_name('OKC','OKC_LINE_NUM_ERRORS');
     FND_MESSAGE.set_token('LINE_ERRORS', p_line_errors);
     FND_FILE.PUT_LINE( FND_FILE.OUTPUT,FND_MESSAGE.GET);
     FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'--------------------------------------');
   ELSE
     FND_FILE.PUT_LINE( FND_FILE.LOG,'--------------------------------------');
     FND_MESSAGE.set_name('OKC','OKC_NO_ERRORS');
     FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
     FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'--------------------------------------');
     FND_MESSAGE.set_name('OKC','OKC_NO_ERRORS');
     FND_FILE.PUT_LINE( FND_FILE.OUTPUT,FND_MESSAGE.GET);
   END IF;
   FND_FILE.PUT_LINE( FND_FILE.LOG,'--------------------------------------');
   FND_MESSAGE.set_name('OKC','OKC_HDR_NUM_TOTAL');
   FND_MESSAGE.set_token('HEADER_TOTAL', p_hdr_count);
   FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
   FND_MESSAGE.set_name('OKC','OKC_LINE_NUM_TOTAL');
   FND_MESSAGE.set_token('LINE_TOTAL', p_line_count);
   FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
   FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'--------------------------------------');
   FND_MESSAGE.set_name('OKC','OKC_HDR_NUM_TOTAL');
   FND_MESSAGE.set_token('HEADER_TOTAL', p_hdr_count);
   FND_FILE.PUT_LINE( FND_FILE.OUTPUT,FND_MESSAGE.GET);
   FND_MESSAGE.set_name('OKC','OKC_LINE_NUM_TOTAL');
   FND_MESSAGE.set_token('LINE_TOTAL', p_line_count);
   FND_FILE.PUT_LINE( FND_FILE.OUTPUT,FND_MESSAGE.GET);

   --Comments
   FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'===============================================================');
   FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'           End of Status Change Concurrent Program');
   FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'===============================================================');
 END;

 PROCEDURE change_status (
 			ERRBUF     	   OUT NOCOPY VARCHAR2,
 			RETCODE    	   OUT NOCOPY NUMBER,
 			p_category 	   IN VARCHAR2 ,
 			p_from_k 	   IN VARCHAR2 ,
 			p_to_k 	      IN VARCHAR2 ,
 			p_from_m 	   IN VARCHAR2 ,
 			p_to_m 	      IN VARCHAR2 ,
 			p_debug 	      IN VARCHAR2  ,
                        p_last_rundate IN VARCHAR2 ) IS
   L_K_N_W_M   VARCHAR2(240);  -- contract number conactinated with contract number modifier.
   C number := 0;
   l_return_status 		VARCHAR2(1) 	:= okc_api.g_ret_sts_success;
   p_init_msg_list 		VARCHAR2(200) 	:= okc_api.g_true;
   x_msg_count 			NUMBER 		:= okc_api.g_miss_num;
   x_msg_data 			VARCHAR2(2000) := okc_api.g_miss_char;
   l_chr_rec  okc_contract_pub.chrv_rec_type;
   i_chr_rec  okc_contract_pub.chrv_rec_type;
   p_error_from_line            VARCHAR2(1) := 'N';

/*commented for bug6475371 and split the cursors into 4 parts*/
 -- 'SIGNED' to ACTIVE
 --CURSOR C_ACTIVE IS
 --SELECT
/* 	  hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and ((p_category    is NULL) or (scs.CODE                      = p_category))
   and ((p_from_k      is NULL) or (hdr.CONTRACT_NUMBER          >= p_from_k ))
   and ((p_to_k        is NULL) or (hdr.CONTRACT_NUMBER          <= p_to_k   ))
   and ((p_from_m      is NULL) or (hdr.CONTRACT_NUMBER_modifier >= p_from_m ))
   and ((p_to_m        is NULL) or (hdr.CONTRACT_NUMBER_modifier <= p_to_m   ))
   and hdr.STS_CODE             <> 'QA_HOLD'
   and status.ste_code          = 'SIGNED'
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date   <= trunc(sysdate)+0.99999
    AND hdr.start_date   >= trunc(l_last_rundate);
*/

 -- 'SIGNED' to ACTIVE
 -- when from-to contract range with optional category and contract modifier is provided
 CURSOR c_actv_hdr_all_cntr IS
 SELECT   hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and ((p_category is NULL) or (scs.CODE = p_category))
   and hdr.CONTRACT_NUMBER >= p_from_k
   and hdr.CONTRACT_NUMBER <= p_to_k
   and ((p_from_m is NULL) or (hdr.CONTRACT_NUMBER_modifier >= p_from_m ))
   and ((p_to_m is NULL) or (hdr.CONTRACT_NUMBER_modifier <= p_to_m   ))
   and hdr.STS_CODE <> 'QA_HOLD'
   and status.ste_code = 'SIGNED'
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date <= trunc(sysdate)+0.99999
    AND hdr.start_date >= trunc(l_last_rundate);

-- 'SIGNED' to ACTIVE
 -- when only from-to contract range with all other options as null
 CURSOR c_actv_hdr_only_contract IS
 SELECT   hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and hdr.CONTRACT_NUMBER >= p_from_k
   and hdr.CONTRACT_NUMBER <= p_to_k
   and hdr.STS_CODE <> 'QA_HOLD'
   and status.ste_code = 'SIGNED'
   AND (hdr.date_terminated IS NULL or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date <= trunc(sysdate)+0.99999
    AND hdr.start_date >= trunc(l_last_rundate);


-- 'SIGNED' to ACTIVE
 -- when only category is provided
 CURSOR c_actv_hdr_only_category IS
 SELECT   /*+ leading( status, hdr, scs ) index(hdr okc_k_headers_all_b_n12) */  ---Added hint for bug 12976183
          hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and scs.CODE = p_category
   and hdr.STS_CODE <> 'QA_HOLD'
   and status.ste_code = 'SIGNED'
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date <= trunc(sysdate)+0.99999
    AND hdr.start_date >= trunc(l_last_rundate);

-- 'SIGNED' to ACTIVE
 -- when no parameter is provided
 CURSOR c_active_hdr_all IS
 SELECT   hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and hdr.STS_CODE <> 'QA_HOLD'
   and status.ste_code = 'SIGNED'
   AND (hdr.date_terminated IS NULL or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date <= trunc(sysdate)+0.99999
    AND hdr.start_date >= trunc(l_last_rundate);

/*commented for bug6475371 and split the cursor into 4 parts*/
--bug 5930684
-- 'ACTIVE' to SIGNED
-- CURSOR C_SIGNED IS
-- SELECT
/* 	  hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and ((p_category    is NULL) or (scs.CODE                      = p_category))
   and ((p_from_k      is NULL) or (hdr.CONTRACT_NUMBER          >= p_from_k ))
   and ((p_to_k        is NULL) or (hdr.CONTRACT_NUMBER          <= p_to_k   ))
   and ((p_from_m      is NULL) or (hdr.CONTRACT_NUMBER_modifier >= p_from_m ))
   and ((p_to_m        is NULL) or (hdr.CONTRACT_NUMBER_modifier <= p_to_m   ))
   and hdr.STS_CODE             <> 'QA_HOLD'
   and status.ste_code          = 'ACTIVE'
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date   >= trunc(sysdate)+0.99999
    AND hdr.start_date   >= trunc(l_last_rundate);
*/
--end of bug 5930684.

-- 'ACTIVE' to SIGNED
 -- when from-to contract range with optional category and contract modifier is provided
 CURSOR C_SIG_HDR_ALL_CNTR IS
 SELECT
 	  hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and ((p_category is NULL) or (scs.CODE = p_category))
   and hdr.CONTRACT_NUMBER >= p_from_k
   and hdr.CONTRACT_NUMBER <= p_to_k
   and ((p_from_m is NULL) or (hdr.CONTRACT_NUMBER_modifier >= p_from_m ))
   and ((p_to_m is NULL) or (hdr.CONTRACT_NUMBER_modifier <= p_to_m   ))
   and hdr.STS_CODE <> 'QA_HOLD'
   and status.ste_code = 'ACTIVE'
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date >= trunc(sysdate)+0.99999
    AND hdr.start_date >= trunc(l_last_rundate);

-- 'ACTIVE' to SIGNED
-- WHEN ONLY FROM-TO CONTRACT RANGE IS PROVIDED
 CURSOR C_SIG_HDR_ONLY_CONTRACT IS
     SELECT
 	  hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and hdr.CONTRACT_NUMBER >= p_from_k
   and hdr.CONTRACT_NUMBER <= p_to_k
   and hdr.STS_CODE <> 'QA_HOLD'
   and status.ste_code = 'ACTIVE'
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date >= trunc(sysdate)+0.99999
    AND hdr.start_date >= trunc(l_last_rundate);

-- 'ACTIVE' to SIGNED
 -- WHEN ONLY CATEGORY IS PROVIDED
 CURSOR C_SIG_HDR_ONLY_CATEGORY IS
     SELECT
 	  hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and scs.CODE = p_category
   and hdr.STS_CODE <> 'QA_HOLD'
   and status.ste_code = 'ACTIVE'
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date   >= trunc(sysdate)+0.99999
    AND hdr.start_date   >= trunc(l_last_rundate);

-- 'ACTIVE' to SIGNED
--when no parameter is provided
CURSOR C_SIGNED_HDR_ALL IS
     SELECT
 	  hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and hdr.STS_CODE <> 'QA_HOLD'
   and status.ste_code = 'ACTIVE'
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate))
    AND hdr.start_date   >= trunc(sysdate)+0.99999
    AND hdr.start_date   >= trunc(l_last_rundate);


/*commented for bug6475371 and split the cursor into 4 parts*/
 -- 'ACTIVE,HOLD,SIGNED to EXPIRED'
-- CURSOR C_EXPIRED IS
-- SELECT /*+ leading(hdr) no_merge(status) use_hash(hdr scs status.stsb status.stst)   */
/* 	  hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and ((p_category    is NULL) or (scs.CODE                      = p_category))
   and ((p_from_k      is NULL) or (hdr.CONTRACT_NUMBER          >= p_from_k ))
   and ((p_to_k        is NULL) or (hdr.CONTRACT_NUMBER          <= p_to_k   ))
   and ((p_from_m      is NULL) or (hdr.CONTRACT_NUMBER_modifier >= p_from_m ))
   and ((p_to_m        is NULL) or (hdr.CONTRACT_NUMBER_modifier <= p_to_m   ))
   and hdr.STS_CODE             <> 'QA_HOLD'
   -- and status.ste_code          in ('ACTIVE','SIGNED','HOLD')  -- <> 'EXPIRED'
   and status.ste_code          in ('ACTIVE','SIGNED') -- Bug 4915692 --
   AND hdr.end_date             >= trunc(l_last_rundate)
   --
   -- Bug 2672565 - Removed time component and changed from <= to <
   --and hdr.end_date 	          <= trunc(sysdate)+0.99999
   --
   and hdr.end_date               < trunc(sysdate)
   AND (hdr.date_terminated IS NULL
    or  hdr.date_terminated >= trunc(sysdate));
*/

-- 'ACTIVE,SIGNED to EXPIRED'
 -- when from-to contract range with optional category and contract modifier is provided
 CURSOR C_EXPIRED_HDR_ALL_CNTR IS
 SELECT /*+ leading(hdr) no_merge(status) use_hash(hdr scs status.stsb status.stst)   */
  hdr.ID,
  hdr.OBJECT_VERSION_NUMBER,
  hdr.STS_CODE,
  hdr.CONTRACT_NUMBER,
  hdr.CONTRACT_NUMBER_MODIFIER,
  hdr.CONTRACT_NUMBER ||
  decode(hdr.contract_number_modifier,
         NULL,
         NULL,
         ' - ' || hdr.contract_number_modifier) K_N_W_M,
  hdr.DATE_TERMINATED,
  hdr.TRN_CODE,
  hdr.START_DATE,
  hdr.END_DATE,
  hdr.SCS_CODE,
  hdr.ESTIMATED_AMOUNT,
  scs.CLS_CODE,
  status.CODE,
  status.STE_CODE,
  status.meaning
   FROM OKC_K_HEADERS_B hdr, OKC_STATUSES_V status, OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
    AND scs.code = hdr.scs_code
    AND scs.cls_code <> 'OKL'
    AND ((p_category IS NULL) OR (scs.CODE = p_category))
    AND hdr.CONTRACT_NUMBER >= p_from_k
    AND hdr.CONTRACT_NUMBER <= p_to_k
    AND ((p_from_m IS NULL) OR (hdr.CONTRACT_NUMBER_modifier >= p_from_m))
    AND ((p_to_m IS NULL) OR (hdr.CONTRACT_NUMBER_modifier <= p_to_m))
    AND hdr.STS_CODE <> 'QA_HOLD'
    AND status.ste_code IN ('ACTIVE', 'SIGNED')
    AND hdr.end_date >= trunc(l_last_rundate)
    AND hdr.end_date < trunc(SYSDATE)
    AND (hdr.date_terminated IS NULL OR
        hdr.date_terminated >= trunc(SYSDATE));



 -- 'ACTIVE,SIGNED to EXPIRED'
-- WHEN ONLY FROM-TO CONTRACT RANGE IS PROVIDED
 CURSOR C_EXP_HDR_ONLY_CONTRACT IS
SELECT /*+ leading(hdr) no_merge(status) use_hash(hdr scs status.stsb status.stst)   */
 hdr.ID,
 hdr.OBJECT_VERSION_NUMBER,
 hdr.STS_CODE,
 hdr.CONTRACT_NUMBER,
 hdr.CONTRACT_NUMBER_MODIFIER,
 hdr.CONTRACT_NUMBER ||
 decode(hdr.contract_number_modifier,
        NULL,
        NULL,
        ' - ' || hdr.contract_number_modifier) K_N_W_M,
 hdr.DATE_TERMINATED,
 hdr.TRN_CODE,
 hdr.START_DATE,
 hdr.END_DATE,
 hdr.SCS_CODE,
 hdr.ESTIMATED_AMOUNT,
 scs.CLS_CODE,
 status.CODE,
 status.STE_CODE,
 status.meaning
  FROM OKC_K_HEADERS_B hdr, OKC_STATUSES_V status, OKC_SUBCLASSES_B scs
 WHERE hdr.STS_CODE = status.CODE
   AND scs.code = hdr.scs_code
   AND scs.cls_code <> 'OKL'
   AND hdr.CONTRACT_NUMBER >= p_from_k
   AND hdr.CONTRACT_NUMBER <= p_to_k
   AND hdr.STS_CODE <> 'QA_HOLD'
   AND status.ste_code IN ('ACTIVE', 'SIGNED')
   AND hdr.end_date >= trunc(l_last_rundate)
   AND hdr.end_date < trunc(SYSDATE)
   AND (hdr.date_terminated IS NULL OR
       hdr.date_terminated >= trunc(SYSDATE));


 -- 'ACTIVE,SIGNED to EXPIRED'
 -- WHEN ONLY CATEGORY IS PROVIDED
 CURSOR C_EXP_HDR_ONLY_CATEGORY IS
SELECT /*+ leading( status, hdr, scs ) index(hdr okc_k_headers_all_b_n13) */  -----Modified hint for bug 12976183
 hdr.ID,
 hdr.OBJECT_VERSION_NUMBER,
 hdr.STS_CODE,
 hdr.CONTRACT_NUMBER,
 hdr.CONTRACT_NUMBER_MODIFIER,
 hdr.CONTRACT_NUMBER ||
 decode(hdr.contract_number_modifier,
        NULL,
        NULL,
        ' - ' || hdr.contract_number_modifier) K_N_W_M,
 hdr.DATE_TERMINATED,
 hdr.TRN_CODE,
 hdr.START_DATE,
 hdr.END_DATE,
 hdr.SCS_CODE,
 hdr.ESTIMATED_AMOUNT,
 scs.CLS_CODE,
 status.CODE,
 status.STE_CODE,
 status.meaning
  FROM OKC_K_HEADERS_B hdr, OKC_STATUSES_V status, OKC_SUBCLASSES_B scs
 WHERE hdr.STS_CODE = status.CODE
   AND scs.code = hdr.scs_code
   AND scs.cls_code <> 'OKL'
   AND scs.CODE = p_category
   AND hdr.STS_CODE <> 'QA_HOLD'
   AND status.ste_code IN ('ACTIVE', 'SIGNED')
   AND hdr.end_date >= trunc(l_last_rundate)
   AND hdr.end_date < trunc(SYSDATE)
   AND (hdr.date_terminated IS NULL OR
       hdr.date_terminated >= trunc(SYSDATE));


 -- 'ACTIVE,SIGNED to EXPIRED'
 --when no parameter is provided
 CURSOR C_EXPIRED_HDR_ALL IS
SELECT /*+ leading(hdr) no_merge(status) use_hash(hdr scs status.stsb status.stst)   */
 hdr.ID,
 hdr.OBJECT_VERSION_NUMBER,
 hdr.STS_CODE,
 hdr.CONTRACT_NUMBER,
 hdr.CONTRACT_NUMBER_MODIFIER,
 hdr.CONTRACT_NUMBER ||
 decode(hdr.contract_number_modifier,
        NULL,
        NULL,
        ' - ' || hdr.contract_number_modifier) K_N_W_M,
 hdr.DATE_TERMINATED,
 hdr.TRN_CODE,
 hdr.START_DATE,
 hdr.END_DATE,
 hdr.SCS_CODE,
 hdr.ESTIMATED_AMOUNT,
 scs.CLS_CODE,
 status.CODE,
 status.STE_CODE,
 status.meaning
  FROM OKC_K_HEADERS_B hdr, OKC_STATUSES_V status, OKC_SUBCLASSES_B scs
 WHERE hdr.STS_CODE = status.CODE
   AND scs.code = hdr.scs_code
   AND scs.cls_code <> 'OKL'
   AND hdr.STS_CODE <> 'QA_HOLD'
   AND status.ste_code IN ('ACTIVE', 'SIGNED')
   AND hdr.end_date >= trunc(l_last_rundate)
   AND hdr.end_date < trunc(SYSDATE)
   AND (hdr.date_terminated IS NULL OR
       hdr.date_terminated >= trunc(SYSDATE));



/*commented for bug6475371 and split cursor into 4 parts*/
 -- 'ACTIVE','HOLD','SIGNED' to TERMINATED
-- CURSOR C_TERMINATED IS
-- SELECT
/* 	  hdr.ID,
 	  hdr.OBJECT_VERSION_NUMBER,
 	  hdr.STS_CODE,
 	  hdr.CONTRACT_NUMBER,
 	  hdr.CONTRACT_NUMBER_MODIFIER,
 	  hdr.CONTRACT_NUMBER||decode(hdr.contract_number_modifier,NULL,NULL,
 		' - '||hdr.contract_number_modifier) K_N_W_M,
 	  hdr.DATE_TERMINATED,
 	  hdr.TRN_CODE,
 	  hdr.START_DATE,
 	  hdr.END_DATE,
 	  hdr.SCS_CODE,
 	  hdr.ESTIMATED_AMOUNT,
       fnd.meaning TERMINATION_REASON,
 	  scs.CLS_CODE,
 	  status.CODE,
 	  status.STE_CODE,
 	  status.meaning
   FROM OKC_K_HEADERS_B hdr,
 	  OKC_STATUSES_V status,
       FND_LOOKUPS fnd,
 	  OKC_SUBCLASSES_B scs
  WHERE hdr.STS_CODE = status.CODE
   AND  scs.code = hdr.scs_code
   and scs.cls_code <> 'OKL'
   and ((p_category    is NULL) or (scs.CODE                      = p_category))
   and ((p_from_k      is NULL) or (hdr.CONTRACT_NUMBER          >= p_from_k ))
   and ((p_to_k        is NULL) or (hdr.CONTRACT_NUMBER          <= p_to_k   ))
   and ((p_from_m      is NULL) or (hdr.CONTRACT_NUMBER_modifier >= p_from_m ))
   and ((p_to_m        is NULL) or (hdr.CONTRACT_NUMBER_modifier <= p_to_m   ))
   and hdr.STS_CODE             <> 'QA_HOLD'
   -- and status.ste_code          IN ('ACTIVE','HOLD','SIGNED')
   and status.ste_code          IN ('ACTIVE','SIGNED') -- Bug 4915692
   and hdr.trn_code = fnd.lookup_code
   and fnd.LOOKUP_TYPE= 'OKC_TERMINATION_REASON'
   and hdr.date_terminated      >= trunc(l_last_rundate)
   and hdr.date_terminated      <= trunc(sysdate)+0.99999;
*/

 -- 'ACTIVE','HOLD','SIGNED' to TERMINATED
 --when from-to contract range is provided with optional contract modifier and category
 CURSOR C_TERMN_HDR_ALL_CNTR IS
SELECT hdr.ID,
       hdr.OBJECT_VERSION_NUMBER,
       hdr.STS_CODE,
       hdr.CONTRACT_NUMBER,
       hdr.CONTRACT_NUMBER_MODIFIER,
       hdr.CONTRACT_NUMBER ||
       decode(hdr.contract_number_modifier,
              NULL,
              NULL,
              ' - ' || hdr.contract_number_modifier) K_N_W_M,
       hdr.DATE_TERMINATED,
       hdr.TRN_CODE,
       hdr.START_DATE,
       hdr.END_DATE,
       hdr.SCS_CODE,
       hdr.ESTIMATED_AMOUNT,
       fnd.meaning TERMINATION_REASON,
       scs.CLS_CODE,
       status.CODE,
       status.STE_CODE,
       status.meaning
  FROM OKC_K_HEADERS_B  hdr,
       OKC_STATUSES_V   status,
       FND_LOOKUPS      fnd,
       OKC_SUBCLASSES_B scs
 WHERE hdr.STS_CODE = status.CODE
   AND scs.code = hdr.scs_code
   AND scs.cls_code <> 'OKL'
   AND ((p_category IS NULL) OR (scs.CODE = p_category))
   AND hdr.CONTRACT_NUMBER >= p_from_k
   AND hdr.CONTRACT_NUMBER <= p_to_k
   AND ((p_from_m IS NULL) OR (hdr.CONTRACT_NUMBER_modifier >= p_from_m))
   AND ((p_to_m IS NULL) OR (hdr.CONTRACT_NUMBER_modifier <= p_to_m))
   AND hdr.STS_CODE <> 'QA_HOLD'
   AND status.ste_code IN ('ACTIVE', 'SIGNED')
   AND hdr.trn_code = fnd.lookup_code
   AND fnd.LOOKUP_TYPE = 'OKC_TERMINATION_REASON'
   AND hdr.date_terminated >= trunc(l_last_rundate)
   AND hdr.date_terminated <= trunc(SYSDATE) + 0.99999;

 -- 'ACTIVE','HOLD','SIGNED' to TERMINATED
 --WHEN ONLY FROM-TO CONTRACT RANGE IS PROVIDED
 CURSOR C_TERMN_HDR_ONLY_CONTRACT IS
SELECT hdr.ID,
       hdr.OBJECT_VERSION_NUMBER,
       hdr.STS_CODE,
       hdr.CONTRACT_NUMBER,
       hdr.CONTRACT_NUMBER_MODIFIER,
       hdr.CONTRACT_NUMBER ||
       decode(hdr.contract_number_modifier,
              NULL,
              NULL,
              ' - ' || hdr.contract_number_modifier) K_N_W_M,
       hdr.DATE_TERMINATED,
       hdr.TRN_CODE,
       hdr.START_DATE,
       hdr.END_DATE,
       hdr.SCS_CODE,
       hdr.ESTIMATED_AMOUNT,
       fnd.meaning TERMINATION_REASON,
       scs.CLS_CODE,
       status.CODE,
       status.STE_CODE,
       status.meaning
  FROM OKC_K_HEADERS_B  hdr,
       OKC_STATUSES_V   status,
       FND_LOOKUPS      fnd,
       OKC_SUBCLASSES_B scs
 WHERE hdr.STS_CODE = status.CODE
   AND scs.code = hdr.scs_code
   AND scs.cls_code <> 'OKL'
   AND hdr.CONTRACT_NUMBER >= p_from_k
   AND hdr.CONTRACT_NUMBER <= p_to_k
   AND hdr.STS_CODE <> 'QA_HOLD'
   AND status.ste_code IN ('ACTIVE', 'SIGNED')
   AND hdr.trn_code = fnd.lookup_code
   AND fnd.LOOKUP_TYPE = 'OKC_TERMINATION_REASON'
   AND hdr.date_terminated >= trunc(l_last_rundate)
   AND hdr.date_terminated <= trunc(SYSDATE) + 0.99999;


-- 'ACTIVE','HOLD','SIGNED' to TERMINATED
 --when only category is provided
 CURSOR C_TERMN_HDR_ONLY_CATEGORY IS
SELECT hdr.ID,
       hdr.OBJECT_VERSION_NUMBER,
       hdr.STS_CODE,
       hdr.CONTRACT_NUMBER,
       hdr.CONTRACT_NUMBER_MODIFIER,
       hdr.CONTRACT_NUMBER ||
       decode(hdr.contract_number_modifier,
              NULL,
              NULL,
              ' - ' || hdr.contract_number_modifier) K_N_W_M,
       hdr.DATE_TERMINATED,
       hdr.TRN_CODE,
       hdr.START_DATE,
       hdr.END_DATE,
       hdr.SCS_CODE,
       hdr.ESTIMATED_AMOUNT,
       fnd.meaning TERMINATION_REASON,
       scs.CLS_CODE,
       status.CODE,
       status.STE_CODE,
       status.meaning
  FROM OKC_K_HEADERS_B  hdr,
       OKC_STATUSES_V   status,
       FND_LOOKUPS      fnd,
       OKC_SUBCLASSES_B scs
 WHERE hdr.STS_CODE = status.CODE
   AND scs.code = hdr.scs_code
   AND scs.cls_code <> 'OKL'
   AND scs.CODE = p_category
   AND hdr.STS_CODE <> 'QA_HOLD'
   AND status.ste_code IN ('ACTIVE', 'SIGNED')
   AND hdr.trn_code = fnd.lookup_code
   AND fnd.LOOKUP_TYPE = 'OKC_TERMINATION_REASON'
   AND hdr.date_terminated >= trunc(l_last_rundate)
   AND hdr.date_terminated <= trunc(SYSDATE) + 0.99999;

-- 'ACTIVE','HOLD','SIGNED' to TERMINATED
 --when no parameter is provided
 CURSOR C_TERMN_HDR_ALL IS
SELECT hdr.ID,
       hdr.OBJECT_VERSION_NUMBER,
       hdr.STS_CODE,
       hdr.CONTRACT_NUMBER,
       hdr.CONTRACT_NUMBER_MODIFIER,
       hdr.CONTRACT_NUMBER ||
       decode(hdr.contract_number_modifier,
              NULL,
              NULL,
              ' - ' || hdr.contract_number_modifier) K_N_W_M,
       hdr.DATE_TERMINATED,
       hdr.TRN_CODE,
       hdr.START_DATE,
       hdr.END_DATE,
       hdr.SCS_CODE,
       hdr.ESTIMATED_AMOUNT,
       fnd.meaning TERMINATION_REASON,
       scs.CLS_CODE,
       status.CODE,
       status.STE_CODE,
       status.meaning
  FROM OKC_K_HEADERS_B  hdr,
       OKC_STATUSES_V   status,
       FND_LOOKUPS      fnd,
       OKC_SUBCLASSES_B scs
 WHERE hdr.STS_CODE = status.CODE
   AND scs.code = hdr.scs_code
   AND scs.cls_code <> 'OKL'
   AND hdr.STS_CODE <> 'QA_HOLD'
   AND status.ste_code IN ('ACTIVE', 'SIGNED')
   AND hdr.trn_code = fnd.lookup_code
   AND fnd.LOOKUP_TYPE = 'OKC_TERMINATION_REASON'
   AND hdr.date_terminated >= trunc(l_last_rundate)
   AND hdr.date_terminated <= trunc(SYSDATE) + 0.99999;

----------------------------------------------------------------------------------------
--- BEGIN CHANGE STATUS AT HEADER LEVEL ---
----------------------------------------------------------------------------------------
 BEGIN

    savepoint H_STATUS;
    FND_MSG_PUB.initialize;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'===============================================================');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'         Start of Status Change Concurrent Program');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'===============================================================');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Parameters for the Run:');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Last Run Date: ' || p_last_rundate);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Category: ' || p_category);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Contract Number From: ' || p_from_k ||'*'||p_from_m);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Contract Number To: ' || p_to_k ||'*'||p_to_m);
 --
   ERRBUF 	:= 	NULL;
   RETCODE 	:= 	0;

   -- Bug 5086847 --
   IF (p_from_m IS NOT NULL) AND (p_from_k IS NULL) THEN

      FND_MESSAGE.set_name('OKC','OKC_ENTER_K_NUMBER');
      FND_FILE.PUT_LINE( FND_FILE.OUTPUT,FND_MESSAGE.GET);

      RETCODE := 2;
	  return;
   END IF;

   IF (p_to_m IS NOT NULL) AND (p_to_k IS NULL) THEN

      FND_MESSAGE.set_name('OKC','OKC_ENTER_K_NUMBER');
      FND_FILE.PUT_LINE( FND_FILE.OUTPUT,FND_MESSAGE.GET);

      RETCODE := 2;
	  return;
   END IF;

   -- Bug 5086847 --

   T := NVL(to_number(FND_PROFILE.VALUE('OKC_BATCH_SIZE')),1000);
   open sts(v_active);
   fetch sts into v_active,v_active_m;
   if sts%NOTFOUND Then
     v_active := 'ACTIVE';
     v_active_m := 'Active';
   end if;
   close sts;

   open sts(v_expired);
   fetch sts into v_expired,v_expired_m;
   if sts%NOTFOUND Then
     v_active := 'EXPIRED';
     v_active_m := 'Expired';
   end if;
   close sts;

   open sts(v_terminated);
   fetch sts into v_terminated,v_terminated_m;
   if sts%NOTFOUND Then
     v_active := 'TERMINATED';
     v_active_m := 'Terminated';
   end if;
   close sts;

   open sts(v_signed);
   fetch sts into v_signed,v_signed_m;
   if sts%NOTFOUND Then
     v_active := 'SIGNED';
     v_active_m := 'Signed';
   end if;
   close sts;

 l_last_rundate := nvl(fnd_date.canonical_to_date(p_last_rundate), to_date('01011901','ddmmyyyy')) - 3; --  a three day grace period.

-- from active hold signed to terminated

/*MODIFIED FOR THE BUG6475371*/
--WHEN FROM-TO CONTRACT NUMBER RANGE WITH OPTIONAL CATEGORY
--AND CONTRACT MODIFIER IS PROVIDED
IF (p_from_k IS NOT NULL) or (p_to_k IS NOT NULL) THEN
   IF (p_category is NOT NULL) or (p_from_m is not null or p_to_m is not null) THEN
c := 0;
l_new_status  := null;
l_new_status_m := null;

FND_FILE.PUT_LINE(FND_FILE.LOG,'when from-to contract number range with optional category and contract modifier is provided');

FOR r_terminated in  c_termn_hdr_all_cntr LOOP


   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active, signed to terminated' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_terminated.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status      := null;
    h_new_status   := v_terminated ;
    h_new_status_m := v_terminated_m ;
    h_status_type  := 'TERMINATED';

    l_chr_rec.id                    := r_terminated.id ;
    l_chr_rec.object_version_number := r_terminated.object_version_number ;
    l_chr_rec.sts_code              := h_new_status ;
    l_chr_rec.old_sts_code := r_terminated.sts_code;
    l_chr_rec.old_ste_code := r_terminated.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
-- End: Added for Status Change Action Assembler Changes 10/19/2000
--
-- lock added not to depend on update implementation
--
  	okc_contract_pub.lock_contract_header(
      		 		p_api_version                  =>     1.0,
     		 		p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
--
      update_contract_header   (
   	     			p_api_version                  =>     1.0,
   	    	 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OKC_K_TERM_ASMBLR_PVT.acn_assemble(
	    		p_api_version  =>	1.0 ,
			p_init_msg_list    =>	p_init_msg_list,
			x_return_status    =>	l_return_status,
			x_msg_count	       =>	x_msg_count,
			x_msg_data	       =>	x_msg_data,
			p_k_class          =>   r_terminated.cls_code,
			p_k_id		       =>	r_terminated.id,
			p_k_number	       =>	r_terminated.contract_number,
			p_k_nbr_mod	       =>	r_terminated.contract_number_modifier,
			p_k_subclass       =>   r_terminated.scs_code,
			p_estimated_amount =>   r_terminated.estimated_amount,
			P_K_STATUS_CODE    =>   r_terminated.STS_CODE,
			p_term_date	       =>	r_terminated.date_terminated,
			p_term_reason	   =>	r_terminated.termination_reason);


	--
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_TIME_RES_PUB.res_time_termnt_k(
			P_CHR_ID  		=> r_terminated.id,
			P_CLE_ID       	=> NULL,
			P_END_DATE     	=> r_terminated.DATE_TERMINATED,
			P_API_VERSION  	=> 1.0 ,
			p_init_msg_list => p_init_msg_list,
			x_return_status => l_return_status
	);


      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
--+
--+ remember header status for lines to follow it, not default
--+

  h_status   := h_new_status;
  h_status_m := h_new_status_m ;

  line_status_change (p_kid       => r_terminated.id,
                      p_cls_code  => r_terminated.cls_code,
                      p_scs_code  => r_terminated.scs_code,
                      p_k_num     => r_terminated.contract_number,
                      p_k_num_mod => r_terminated.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);



  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_old_status =>r_terminated.meaning,
                 p_status =>h_new_status_m,
                 p_type  =>'S');
  c:= c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;

END LOOP; -- from active hold signed to terminated
commit;
c:= 0;
savepoint H_STATUS;
----------------------------------------------------------------------------------------
l_new_status  := null;
l_new_status_m := null;

-- From Active, hold, signed to EXPIRED
FOR r_expired in c_expired_hdr_all_cntr LOOP


   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active, signed to expired' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;

    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_expired.K_N_W_M;
    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_expired;
    h_new_status_m := v_expired_m;
    h_status_type := 'EXPIRED';

    l_chr_rec.id := r_expired.id ;
    l_chr_rec.object_version_number := r_expired.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_expired.sts_code;
    l_chr_rec.old_ste_code := r_expired.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
-- lock added not to depend on update implementation
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
  h_status   := h_new_status;
  h_status_m := h_new_status_m ;
  line_status_change (p_kid       => r_expired.id,
                      p_cls_code  => r_expired.cls_code,
                      p_scs_code  => r_expired.scs_code,
                      p_k_num     => r_expired.contract_number,
                      p_k_num_mod => r_expired.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_type  =>'S');

  c := c + 1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Active, hold, signed to EXPIRED

commit;
c:= 0;
savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
----------------------------------------------------------------------------------------
-- From Signed to Active
FOR r_active in c_actv_hdr_all_cntr LOOP

   BEGIN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'C from signed to active' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_active.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_active ;
    h_new_status_m := v_active_m ;
    h_status_type := 'ACTIVE';

    l_chr_rec.id := r_active.id ;
    l_chr_rec.object_version_number  :=  r_active.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_active.sts_code;
    l_chr_rec.old_ste_code := r_active.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
    h_status := h_new_status;
    h_status_m := h_new_status_m ;

    line_status_change (p_kid       => r_active.id,
                      p_cls_code  => r_active.cls_code,
                      p_scs_code  => r_active.scs_code,
                      p_k_num     => r_active.contract_number,
                      p_k_num_mod => r_active.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_type  =>'S');
  c := c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Signed to Active

commit;
c := 0;

savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
----------------------------------------------------------------------------------------
--bug 5930684
-- From Active to Signed

FOR r_signed in c_sig_hdr_all_cntr LOOP

   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active to signed ' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_signed.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_signed ;
    h_new_status_m := v_signed_m ;
    h_status_type := 'SIGNED';

    l_chr_rec.id := r_signed.id ;
    l_chr_rec.object_version_number  :=  r_signed.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_signed.sts_code;
    l_chr_rec.old_ste_code := r_signed.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
    h_status := h_new_status;
    h_status_m := h_new_status_m ;

    line_status_change (p_kid       => r_signed.id,
                      p_cls_code  => r_signed.cls_code,
                      p_scs_code  => r_signed.scs_code,
                      p_k_num     => r_signed.contract_number,
                      p_k_num_mod => r_signed.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_type  =>'S');
  c := c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From  Active to signed

commit;
c := 0;
--- end of bug 5930684
   ELSE
      /*when only contract from-to range is provided*/
      /*changes made for bug6475371*/
     -- from active, signed to terminated
c := 0;
l_new_status  := null;
l_new_status_m := null;

FND_FILE.PUT_LINE(FND_FILE.LOG,'when only contract from-to range is provided as input');

FOR r_terminated in  c_termn_hdr_only_contract LOOP


   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active, signed to terminated ' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_terminated.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status      := null;
    h_new_status   := v_terminated ;
    h_new_status_m := v_terminated_m ;
    h_status_type  := 'TERMINATED';

    l_chr_rec.id                    := r_terminated.id ;
    l_chr_rec.object_version_number := r_terminated.object_version_number ;
    l_chr_rec.sts_code              := h_new_status ;
    l_chr_rec.old_sts_code := r_terminated.sts_code;
    l_chr_rec.old_ste_code := r_terminated.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
-- End: Added for Status Change Action Assembler Changes 10/19/2000
--
-- lock added not to depend on update implementation
--
  	okc_contract_pub.lock_contract_header(
      		 		p_api_version                  =>     1.0,
     		 		p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
--
      update_contract_header   (
   	     			p_api_version                  =>     1.0,
   	    	 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'update_contract_header ' || l_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OKC_K_TERM_ASMBLR_PVT.acn_assemble(
	    		p_api_version  =>	1.0 ,
			p_init_msg_list    =>	p_init_msg_list,
			x_return_status    =>	l_return_status,
			x_msg_count	       =>	x_msg_count,
			x_msg_data	       =>	x_msg_data,
			p_k_class          =>   r_terminated.cls_code,
			p_k_id		       =>	r_terminated.id,
			p_k_number	       =>	r_terminated.contract_number,
			p_k_nbr_mod	       =>	r_terminated.contract_number_modifier,
			p_k_subclass       =>   r_terminated.scs_code,
			p_estimated_amount =>   r_terminated.estimated_amount,
			P_K_STATUS_CODE    =>   r_terminated.STS_CODE,
			p_term_date	       =>	r_terminated.date_terminated,
			p_term_reason	   =>	r_terminated.termination_reason);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKC_K_TERM_ASMBLR_PVT ' || l_return_status);

	--
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_TIME_RES_PUB.res_time_termnt_k(
			P_CHR_ID  		=> r_terminated.id,
			P_CLE_ID       	=> NULL,
			P_END_DATE     	=> r_terminated.DATE_TERMINATED,
			P_API_VERSION  	=> 1.0 ,
			p_init_msg_list => p_init_msg_list,
			x_return_status => l_return_status
	);

      FND_FILE.PUT_LINE(FND_FILE.LOG,'res_time_termnt_k ' || l_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
--+
--+ remember header status for lines to follow it, not default
--+

  h_status   := h_new_status;
  h_status_m := h_new_status_m ;

  line_status_change (p_kid       => r_terminated.id,
                      p_cls_code  => r_terminated.cls_code,
                      p_scs_code  => r_terminated.scs_code,
                      p_k_num     => r_terminated.contract_number,
                      p_k_num_mod => r_terminated.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'line_status_change ' || l_return_status);


  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_old_status =>r_terminated.meaning,
                 p_status =>h_new_status_m,
                 p_type  =>'S');
  c:= c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;

END LOOP; -- from active hold signed to terminated
commit;
c:= 0;
savepoint H_STATUS;
----------------------------------------------------------------------------------------
l_new_status  := null;
l_new_status_m := null;

-- From Active, signed to EXPIRED
FOR r_expired in c_exp_hdr_only_contract LOOP


   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active, signed to expired' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;

    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_expired.K_N_W_M;
    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_expired;
    h_new_status_m := v_expired_m;
    h_status_type := 'EXPIRED';

    l_chr_rec.id := r_expired.id ;
    l_chr_rec.object_version_number := r_expired.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_expired.sts_code;
    l_chr_rec.old_ste_code := r_expired.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
-- lock added not to depend on update implementation
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
  h_status   := h_new_status;
  h_status_m := h_new_status_m ;
  line_status_change (p_kid       => r_expired.id,
                      p_cls_code  => r_expired.cls_code,
                      p_scs_code  => r_expired.scs_code,
                      p_k_num     => r_expired.contract_number,
                      p_k_num_mod => r_expired.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_type  =>'S');

  c := c + 1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Active, hold, signed to EXPIRED

commit;
c:= 0;
savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
----------------------------------------------------------------------------------------
-- From Signed to Active
FOR r_active in c_actv_hdr_only_contract LOOP

   BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'C from signed to active ' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_active.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_active ;
    h_new_status_m := v_active_m ;
    h_status_type := 'ACTIVE';

    l_chr_rec.id := r_active.id ;
    l_chr_rec.object_version_number  :=  r_active.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_active.sts_code;
    l_chr_rec.old_ste_code := r_active.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
    h_status := h_new_status;
    h_status_m := h_new_status_m ;

    line_status_change (p_kid       => r_active.id,
                      p_cls_code  => r_active.cls_code,
                      p_scs_code  => r_active.scs_code,
                      p_k_num     => r_active.contract_number,
                      p_k_num_mod => r_active.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_type  =>'S');
  c := c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Signed to Active

commit;
c := 0;
savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
----------------------------------------------------------------------------------------
--bug 5866484
-- From Active to Signed

FOR r_signed in c_sig_hdr_only_contract LOOP

   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active to signed ' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_signed.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_signed ;
    h_new_status_m := v_signed_m ;
    h_status_type := 'SIGNED';

    l_chr_rec.id := r_signed.id ;
    l_chr_rec.object_version_number  :=  r_signed.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_signed.sts_code;
    l_chr_rec.old_ste_code := r_signed.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
    h_status := h_new_status;
    h_status_m := h_new_status_m ;

    line_status_change (p_kid       => r_signed.id,
                      p_cls_code  => r_signed.cls_code,
                      p_scs_code  => r_signed.scs_code,
                      p_k_num     => r_signed.contract_number,
                      p_k_num_mod => r_signed.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_type  =>'S');
  c := c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Active to Signed

commit;
c := 0;
END IF;

ELSIF (p_from_k is null) AND (p_category is not null) THEN
/*WHEN ONLY CATEGORY IS PROVIDED*/
/*changes made for bug6475371*/

-- from active signed to terminated
c := 0;
l_new_status  := null;
l_new_status_m := null;

FND_FILE.PUT_LINE(FND_FILE.LOG,'Category is provided as input ' || p_category);

FOR r_terminated in  c_termn_hdr_only_category LOOP


   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active, signed to terminated' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_terminated.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status      := null;
    h_new_status   := v_terminated ;
    h_new_status_m := v_terminated_m ;
    h_status_type  := 'TERMINATED';

    l_chr_rec.id                    := r_terminated.id ;
    l_chr_rec.object_version_number := r_terminated.object_version_number ;
    l_chr_rec.sts_code              := h_new_status ;
    l_chr_rec.old_sts_code := r_terminated.sts_code;
    l_chr_rec.old_ste_code := r_terminated.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
-- End: Added for Status Change Action Assembler Changes 10/19/2000
--
-- lock added not to depend on update implementation
--
  	okc_contract_pub.lock_contract_header(
      		 		p_api_version                  =>     1.0,
     		 		p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
--
      update_contract_header   (
   	     			p_api_version                  =>     1.0,
   	    	 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'update_contract_header ' || l_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OKC_K_TERM_ASMBLR_PVT.acn_assemble(
	    		p_api_version  =>	1.0 ,
			p_init_msg_list    =>	p_init_msg_list,
			x_return_status    =>	l_return_status,
			x_msg_count	       =>	x_msg_count,
			x_msg_data	       =>	x_msg_data,
			p_k_class          =>   r_terminated.cls_code,
			p_k_id		       =>	r_terminated.id,
			p_k_number	       =>	r_terminated.contract_number,
			p_k_nbr_mod	       =>	r_terminated.contract_number_modifier,
			p_k_subclass       =>   r_terminated.scs_code,
			p_estimated_amount =>   r_terminated.estimated_amount,
			P_K_STATUS_CODE    =>   r_terminated.STS_CODE,
			p_term_date	       =>	r_terminated.date_terminated,
			p_term_reason	   =>	r_terminated.termination_reason);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKC_K_TERM_ASMBLR_PVT ' || l_return_status);

	--
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_TIME_RES_PUB.res_time_termnt_k(
			P_CHR_ID  		=> r_terminated.id,
			P_CLE_ID       	=> NULL,
			P_END_DATE     	=> r_terminated.DATE_TERMINATED,
			P_API_VERSION  	=> 1.0 ,
			p_init_msg_list => p_init_msg_list,
			x_return_status => l_return_status
	);

      FND_FILE.PUT_LINE(FND_FILE.LOG,'res_time_termnt_k ' || l_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
--+
--+ remember header status for lines to follow it, not default
--+

  h_status   := h_new_status;
  h_status_m := h_new_status_m ;

  line_status_change (p_kid       => r_terminated.id,
                      p_cls_code  => r_terminated.cls_code,
                      p_scs_code  => r_terminated.scs_code,
                      p_k_num     => r_terminated.contract_number,
                      p_k_num_mod => r_terminated.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'line_status_change ' || l_return_status);


  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_old_status =>r_terminated.meaning,
                 p_status =>h_new_status_m,
                 p_type  =>'S');
  c:= c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;

END LOOP; -- from active signed to terminated
commit;
c:= 0;
savepoint H_STATUS;
----------------------------------------------------------------------------------------
l_new_status  := null;
l_new_status_m := null;

-- From Active, signed to EXPIRED
FOR r_expired in c_exp_hdr_only_category LOOP


   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active, signed to expired' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;

    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_expired.K_N_W_M;
    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_expired;
    h_new_status_m := v_expired_m;
    h_status_type := 'EXPIRED';

    l_chr_rec.id := r_expired.id ;
    l_chr_rec.object_version_number := r_expired.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_expired.sts_code;
    l_chr_rec.old_ste_code := r_expired.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
-- lock added not to depend on update implementation
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
  h_status   := h_new_status;
  h_status_m := h_new_status_m ;
  line_status_change (p_kid       => r_expired.id,
                      p_cls_code  => r_expired.cls_code,
                      p_scs_code  => r_expired.scs_code,
                      p_k_num     => r_expired.contract_number,
                      p_k_num_mod => r_expired.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_type  =>'S');

  c := c + 1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Active, signed to EXPIRED

commit;
c:= 0;
savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
----------------------------------------------------------------------------------------
-- From Signed to Active
FOR r_active in c_actv_hdr_only_category LOOP

   BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'C from signed to active ' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_active.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_active ;
    h_new_status_m := v_active_m ;
    h_status_type := 'ACTIVE';

    l_chr_rec.id := r_active.id ;
    l_chr_rec.object_version_number  :=  r_active.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_active.sts_code;
    l_chr_rec.old_ste_code := r_active.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
    h_status := h_new_status;
    h_status_m := h_new_status_m ;

    line_status_change (p_kid       => r_active.id,
                      p_cls_code  => r_active.cls_code,
                      p_scs_code  => r_active.scs_code,
                      p_k_num     => r_active.contract_number,
                      p_k_num_mod => r_active.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_type  =>'S');
  c := c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Signed to Active

commit;
c := 0;
savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
----------------------------------------------------------------------------------------
--bug 5866484
-- From Active to Signed

FOR r_signed in c_sig_hdr_only_category LOOP

   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active to signed ' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_signed.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_signed ;
    h_new_status_m := v_signed_m ;
    h_status_type := 'SIGNED';

    l_chr_rec.id := r_signed.id ;
    l_chr_rec.object_version_number  :=  r_signed.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_signed.sts_code;
    l_chr_rec.old_ste_code := r_signed.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
    h_status := h_new_status;
    h_status_m := h_new_status_m ;

    line_status_change (p_kid       => r_signed.id,
                      p_cls_code  => r_signed.cls_code,
                      p_scs_code  => r_signed.scs_code,
                      p_k_num     => r_signed.contract_number,
                      p_k_num_mod => r_signed.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_type  =>'S');
  c := c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Active to Signed

commit;
c := 0;

ELSIF (p_from_k is null) AND (p_category is null) THEN
/*WHEN NO PARAMETER IS PROVIDED*/
/*changes made for bug6475371*/

-- from active signed to terminated
c := 0;
l_new_status  := null;
l_new_status_m := null;

FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent request submitted with last_run_date as '||p_last_rundate);

FOR r_terminated in  c_termn_hdr_all LOOP


   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active, signed to terminated' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_terminated.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status      := null;
    h_new_status   := v_terminated ;
    h_new_status_m := v_terminated_m ;
    h_status_type  := 'TERMINATED';

    l_chr_rec.id                    := r_terminated.id ;
    l_chr_rec.object_version_number := r_terminated.object_version_number ;
    l_chr_rec.sts_code              := h_new_status ;
    l_chr_rec.old_sts_code := r_terminated.sts_code;
    l_chr_rec.old_ste_code := r_terminated.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
-- End: Added for Status Change Action Assembler Changes 10/19/2000
--
-- lock added not to depend on update implementation
--
  	okc_contract_pub.lock_contract_header(
      		 		p_api_version                  =>     1.0,
     		 		p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
--
      update_contract_header   (
   	     			p_api_version                  =>     1.0,
   	    	 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'update_contract_header ' || l_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OKC_K_TERM_ASMBLR_PVT.acn_assemble(
	    		p_api_version  =>	1.0 ,
			p_init_msg_list    =>	p_init_msg_list,
			x_return_status    =>	l_return_status,
			x_msg_count	       =>	x_msg_count,
			x_msg_data	       =>	x_msg_data,
			p_k_class          =>   r_terminated.cls_code,
			p_k_id		       =>	r_terminated.id,
			p_k_number	       =>	r_terminated.contract_number,
			p_k_nbr_mod	       =>	r_terminated.contract_number_modifier,
			p_k_subclass       =>   r_terminated.scs_code,
			p_estimated_amount =>   r_terminated.estimated_amount,
			P_K_STATUS_CODE    =>   r_terminated.STS_CODE,
			p_term_date	       =>	r_terminated.date_terminated,
			p_term_reason	   =>	r_terminated.termination_reason);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKC_K_TERM_ASMBLR_PVT ' || l_return_status);

	--
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_TIME_RES_PUB.res_time_termnt_k(
			P_CHR_ID  		=> r_terminated.id,
			P_CLE_ID       	=> NULL,
			P_END_DATE     	=> r_terminated.DATE_TERMINATED,
			P_API_VERSION  	=> 1.0 ,
			p_init_msg_list => p_init_msg_list,
			x_return_status => l_return_status
	);

      FND_FILE.PUT_LINE(FND_FILE.LOG,'res_time_termnt_k ' || l_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
--+
--+ remember header status for lines to follow it, not default
--+

  h_status   := h_new_status;
  h_status_m := h_new_status_m ;

  line_status_change (p_kid       => r_terminated.id,
                      p_cls_code  => r_terminated.cls_code,
                      p_scs_code  => r_terminated.scs_code,
                      p_k_num     => r_terminated.contract_number,
                      p_k_num_mod => r_terminated.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'line_status_change ' || l_return_status);


  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_old_status =>r_terminated.meaning,
                 p_status =>h_new_status_m,
                 p_type  =>'S');
  c:= c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_terminated.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;

END LOOP; -- from active signed to terminated
commit;
c:= 0;
savepoint H_STATUS;
----------------------------------------------------------------------------------------
l_new_status  := null;
l_new_status_m := null;

-- From Active, signed to EXPIRED
FOR r_expired in c_expired_hdr_all LOOP


   BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active, signed to expired' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;

    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_expired.K_N_W_M;
    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_expired;
    h_new_status_m := v_expired_m;
    h_status_type := 'EXPIRED';

    l_chr_rec.id := r_expired.id ;
    l_chr_rec.object_version_number := r_expired.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_expired.sts_code;
    l_chr_rec.old_ste_code := r_expired.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
-- lock added not to depend on update implementation
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
  h_status   := h_new_status;
  h_status_m := h_new_status_m ;
  line_status_change (p_kid       => r_expired.id,
                      p_cls_code  => r_expired.cls_code,
                      p_scs_code  => r_expired.scs_code,
                      p_k_num     => r_expired.contract_number,
                      p_k_num_mod => r_expired.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_type  =>'S');

  c := c + 1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_expired.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Active, hold, signed to EXPIRED

commit;
c:= 0;
savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
----------------------------------------------------------------------------------------
-- From Signed to Active
FOR r_active in c_active_hdr_all LOOP

   BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'C from signed to active ' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_active.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_active ;
    h_new_status_m := v_active_m ;
    h_status_type := 'ACTIVE';

    l_chr_rec.id := r_active.id ;
    l_chr_rec.object_version_number  :=  r_active.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_active.sts_code;
    l_chr_rec.old_ste_code := r_active.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
    h_status := h_new_status;
    h_status_m := h_new_status_m ;

    line_status_change (p_kid       => r_active.id,
                      p_cls_code  => r_active.cls_code,
                      p_scs_code  => r_active.scs_code,
                      p_k_num     => r_active.contract_number,
                      p_k_num_mod => r_active.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_type  =>'S');
  c := c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_active.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Signed to Active

commit;
c := 0;
savepoint H_STATUS;
l_new_status  := null;
l_new_status_m := null;
----------------------------------------------------------------------------------------
--bug 5866484
-- From Active to Signed

FOR r_signed in c_signed_hdr_all LOOP

   BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'C from active to signed ' || C);
    if (C >= T) then
      commit;
      c := 0;
    end if;
    savepoint H_STATUS;
    p_hdr_count:= p_hdr_count + 1;
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    L_K_N_W_M := r_signed.K_N_W_M;

    l_new_status  := null;
    l_new_status_m := null;
    h_status := null;
    h_new_status := v_signed ;
    h_new_status_m := v_signed_m ;
    h_status_type := 'SIGNED';

    l_chr_rec.id := r_signed.id ;
    l_chr_rec.object_version_number  :=  r_signed.object_version_number ;
    l_chr_rec.sts_code := h_new_status ;
    l_chr_rec.old_sts_code := r_signed.sts_code;
    l_chr_rec.old_ste_code := r_signed.ste_code;
    l_chr_rec.new_sts_code := h_new_status;
    l_chr_rec.new_ste_code := h_status_type;
--
  	okc_contract_pub.lock_contract_header(
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--
      update_contract_header   (
   		 			p_api_version                  =>     1.0,
   		 			p_init_msg_list                =>     p_init_msg_list,
    					x_return_status                =>     l_return_status,
    					x_msg_count                    =>     x_msg_count,
    					x_msg_data                     =>     x_msg_data,
    					p_chrv_rec                     =>     l_chr_rec,
    					x_chrv_rec	                =>     i_chr_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--+
--+ remember header status for lines to follow it, not default
--+
    h_status := h_new_status;
    h_status_m := h_new_status_m ;

    line_status_change (p_kid       => r_signed.id,
                      p_cls_code  => r_signed.cls_code,
                      p_scs_code  => r_signed.scs_code,
                      p_k_num     => r_signed.contract_number,
                      p_k_num_mod => r_signed.contract_number_modifier,
                      p_update_minor_version =>'N',
                      x_return_status => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     p_error_from_line            := 'Y';
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_type  =>'S');
  c := c+1;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'E');
        if p_error_from_line  <>  'Y' then
	  p_hdr_errors := p_hdr_errors +1 ;
        else
          p_error_from_line := 'N';
        end if;
        rollback to H_STATUS;
    WHEN OTHERS then
        header_message(p_knum_and_mod =>L_K_N_W_M,
                 p_status =>h_new_status_m,
                 p_old_status =>r_signed.meaning,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
	p_hdr_errors := p_hdr_errors +1 ;
        rollback to H_STATUS;
    END;
END LOOP; -- From Active to Signed

commit;
c := 0;
END IF;

----------------------------------------------------------------------------------------
--- END CHANGE STATUS AT HEADER LEVEL ---
----------------------------------------------------------------------------------------
l_new_status  := null;
l_new_status_m := null;

-- Perform line status changes indepenant of Contract Header
-- For Terminate, Expire, and Active

   h_status   := NULL;
   h_status_type   := NULL;
   h_status_m := NULL;

  h_new_status := NULL;
  h_new_status_m := NULL;
  -- line_status_change;
  line_status_change (p_kid       => NULL
                     ,p_cls_code  => NULL
                     ,p_scs_code  => p_category
 		     ,p_from_k 	  => p_from_k
 		     ,p_to_k 	  => p_to_k
 		     ,p_from_m 	  => p_from_m
 		     ,p_to_m 	  => p_to_m
                     ,p_k_num     => NULL
                     ,p_k_num_mod => NULL
                     ,p_update_minor_version =>'Y'
                     ,x_return_status => l_return_status );
  commit;
  wrapup;
EXCEPTION
   WHEN OTHERS THEN
        header_message(p_knum_and_mod =>NULL,
                 p_status =>NULL,
                 p_old_status =>NULL,
                 p_msg_data => x_msg_data,
                 p_type  =>'U');
        retcode := 1;
        wrapup;
	rollback to H_STATUS;
END change_status; --1

END okc_status_change_pvt;

/
