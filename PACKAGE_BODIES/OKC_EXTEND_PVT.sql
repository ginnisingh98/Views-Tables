--------------------------------------------------------
--  DDL for Package Body OKC_EXTEND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_EXTEND_PVT" as
/* $Header: OKCREXTB.pls 120.2.12000000.2 2007/03/08 11:17:19 skgoud ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- /striping/
p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

  FUNCTION is_k_extend_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS

/*p_sts_code is not being used right now as not sure if the refresh from launchpad
  will take place everytime a change happens to a contract or not. That is
  If the status of the contract showing in launchpad would at all times be in sync
  with database.It might not happen due to performance reasons of launchpad. So the current approach.
  But if this sync is assured then  we could use p_sts_code as well*/

    l_sts_code VARCHAR2(100);
    l_cls_code VARCHAR2(100);
    l_template_yn VARCHAR2(10);
    l_code VARCHAR2(100);
    l_end_date okc_k_headers_b.end_date%TYPE;
    l_app_id okc_k_headers_b.application_id%TYPE;
    l_scs_code okc_k_headers_b.scs_code%TYPE;
    l_k VARCHAR2(255);
    l_mod okc_k_headers_b.contract_number_modifier%TYPE ;


    CURSOR c_chr IS
    SELECT sts_code,template_yn,end_date,application_id,scs_code ,contract_number,
			contract_number_modifier
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR c_sts(p_code IN VARCHAR2) IS
    SELECT ste_code
    FROM   okc_statuses_b
    WHERE  code = p_code;

  BEGIN

    OPEN c_chr;
    FETCH c_chr INTO l_code,l_template_yn,l_end_date,l_app_id,l_scs_code,l_k,l_mod;
    CLOSE c_chr;

    IF (l_mod is not null) and (l_mod <> OKC_API.G_MISS_CHAR) then
			 l_k := l_k ||'-'||l_mod;
    END IF;


    IF l_template_yn = 'Y' then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_K_TEMPLATE',
					 p_token1        => 'NUMBER',
					 p_token1_value  => l_k);

	 RETURN(FALSE);
    END IF;

    -- A perpetual cannot be extended further !!
    IF l_end_date Is Null then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_NO_PERPETUAL',
					 p_token1        => 'component',
					 p_token1_value  => l_k);
	 RETURN(FALSE);
    END IF;

    -- If there is Update access, do not allow extend
    If Okc_Util.Get_All_K_Access_Level(p_application_id => l_app_id,
							    p_chr_id => p_chr_id,
                                       p_scs_code => l_scs_code) <> 'U' Then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_NO_UPDATE',
					 p_token1        => 'CHR',
					 p_token1_value  => l_k);
      RETURN(FALSE);
    END IF;

    OPEN c_sts(l_code);
    FETCH c_sts INTO l_sts_code;
    CLOSE c_sts;

    IF l_sts_code NOT IN ('ACTIVE','EXPIRED','SIGNED') THEN
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_INVALID_STS',
					 p_token1        => 'component',
					 p_token1_value  => l_k);
      RETURN(FALSE);
    END IF;

    RETURN(TRUE);
  END is_k_extend_allowed;


  FUNCTION is_kl_extend_allowed(p_cle_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS

/*p_sts_code is not being used right now as not sure if the refresh from launchpad
  will take place everytime a change happens to a contract or not. That is
  If the status of the contract showing in launchpad would at all times be in sync
  with database.It might not happen due to performance reasons of launchpad. So the current approach.
  But if this sync is assured then  we could use p_sts_code as well*/

    l_sts_code VARCHAR2(100);
    l_cls_code VARCHAR2(100);
    l_template_yn VARCHAR2(10);
    l_code VARCHAR2(100);
    l_chr_id   number:=OKC_API.G_MISS_NUM;
    l_app_id okc_k_headers_b.application_id%TYPE;
    l_scs_code okc_k_headers_b.scs_code%TYPE;
    l_k VARCHAR2(255);
    l_mod okc_k_headers_b.contract_number_modifier%TYPE ;
    l_no okc_k_lines_b.line_number%TYPE;
    l_end_date okc_k_lines_b.end_date%TYPE;

    CURSOR c_chr(p_chr_id number) IS
    SELECT template_yn, application_id, scs_code ,contract_number,
			    contract_number_modifier
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR c_cle IS
    SELECT sts_code,dnz_chr_id ,line_number,end_date
    FROM   okc_k_lines_b
    WHERE  id = p_cle_id;

    CURSOR c_sts(p_code IN VARCHAR2) IS
    SELECT ste_code
    FROM   okc_statuses_b
    WHERE  code = p_code;


  BEGIN

    OPEN c_cle;
    FETCH c_cle INTO l_code,l_chr_id,l_no,l_end_date;
    CLOSE c_cle;

    If l_chr_id=OKC_API.G_MISS_NUM then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_NO_CHR',
					 p_token1        => 'LINE',
					 p_token1_value  => l_no);
	RETURN (FALSE);
    END IF;

    -- A perpetual cannot be extended further !!
    IF l_end_date Is Null then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_NO_PERPETUAL',
					 p_token1        => 'component',
					 p_token1_value  => l_no);
	 RETURN(FALSE);
    END IF;

    OPEN c_chr(l_chr_id);
    FETCH c_chr INTO l_template_yn, l_app_id, l_scs_code,l_k,l_mod;
    CLOSE c_chr;

    IF l_template_yn = 'Y' then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_K_TEMPLATE',
					 p_token1        => 'number',
					 p_token1_value  => l_k);
	 RETURN(FALSE);
    END IF;

    If Okc_Util.Get_All_K_Access_Level(p_application_id => l_app_id,
							    p_chr_id => l_chr_id,
                                       p_scs_code => l_scs_code) <> 'U' Then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_NO_UPDATE',
					 p_token1        => 'CHR',
					 p_token1_value  => l_k);
      RETURN(FALSE);
    END IF;

    OPEN c_sts(l_code);
    FETCH c_sts INTO l_sts_code;
    CLOSE c_sts;

    IF l_sts_code NOT IN ('ACTIVE','EXPIRED','ENTERED','SIGNED') THEN
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_INVALID_STS',
					 p_token1        => 'component',
					 p_token1_value  => l_no);
      RETURN(FALSE);
    END IF;

    RETURN(TRUE);
  END is_kl_extend_allowed;

  -- Added for Bug 2648677/2346862
  -- p_pdf id is for Process Defn id for seeded procedure
  -- p_chr_id is Contract id (always required) for Contract Header Extend
  -- p_cle_id is Contract Line id (optional ) for Contract Header Extend it is
  -- NULL and for Contract Line Extend is required

  PROCEDURE OKC_CREATE_PLSQL (p_pdf_id IN  NUMBER,
                              x_string OUT NOCOPY VARCHAR2) IS

  l_string     VARCHAR2(2000);

   -- Cursor to get the package.procedure name from PDF
   CURSOR pdf_cur(l_pdf_id IN NUMBER) IS
   SELECT
   decode(pdf.pdf_type,'PPS',
          pdf.package_name||'.'||pdf.procedure_name,NULL) proc_name
   FROM okc_process_defs_v pdf
   WHERE pdf.id = l_pdf_id;

   pdf_rec pdf_cur%ROWTYPE;

   BEGIN
      OPEN pdf_cur(p_pdf_id);
      FETCH pdf_cur INTO pdf_rec;
      CLOSE pdf_cur;

      l_string := l_string||pdf_rec.proc_name;
      x_string := l_string ;

  END OKC_CREATE_PLSQL;


PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
      	              p_init_msg_list                IN  VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_rec     IN  extend_in_parameters_rec ) is

    CURSOR cur_k_header is
    SELECT STS_CODE,
	      CONTRACT_NUMBER,
	      CONTRACT_NUMBER_MODIFIER,
	      TEMPLATE_YN,
	      DATE_TERMINATED,
	      DATE_RENEWED,
	      END_DATE
      FROM okc_k_headers_b
      WHERE id = p_extend_in_parameters_rec.p_contract_id;

 CURSOR  is_k_locked is
 SELECT 'Y'
   FROM okc_k_processes v
  WHERE v.chr_id = p_extend_in_parameters_rec.p_contract_id
    AND v.in_process_yn='Y';

  CURSOR cur_status(p_sts_code varchar2) is
  SELECT ste_code
    FROM okc_statuses_b
   WHERE code = p_sts_code;

  CURSOR cur_mean(p_sts_code varchar2) is
  SELECT meaning
    FROM okc_statuses_v
   WHERE code = p_sts_code;

  l_chg_request_in_process  varchar2(1);
  l_status                  varchar2(30);
  l_status_meaning okc_statuses_v.meaning%type;
  l_return_status           varchar2(1)  := OKC_API.g_ret_sts_success;
  l_chr_rec                 cur_k_header%rowtype;

BEGIN

  x_return_status := okc_api.g_ret_sts_success;

  OKC_API.init_msg_list(p_init_msg_list);

     OPEN  cur_k_header;
     FETCH cur_k_header into l_chr_rec;
     CLOSE cur_k_header;

   If p_extend_in_parameters_rec.p_perpetual_flag = OKC_API.G_FALSE Then
     IF l_chr_rec.end_date >= p_extend_in_parameters_rec.p_end_date then

        OKC_API.set_message( p_app_name      => g_app_name,
                             p_msg_name      => 'OKC_INVALID_EXTEND_DATE');

        x_return_status := okc_api.g_ret_sts_error;
        RAISE g_exception_halt_validation;

     END IF;
   END IF;

/* Templates can not be extended */
   IF l_chr_rec.template_Yn = 'Y' THEN

        OKC_API.set_message( p_app_name      => g_app_name,
                             p_msg_name      => 'OKC_K_TEMPLATE',
                             p_token1        => 'NUMBER',
                             p_token1_value  => l_chr_rec.contract_number );

         x_return_status := okc_api.g_ret_sts_error;
         RAISE g_exception_halt_validation;
   end IF;

   OPEN is_k_locked;
   FETCH is_k_locked into l_chg_request_in_process;

   IF is_k_locked%found THEN

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_K_LOCKED',
                            p_token1        => 'NUMBER',
                            p_token1_value  => l_chr_rec.contract_number);

      x_return_status := okc_api.g_ret_sts_error;
	 CLOSE is_k_locked;
      RAISE g_exception_halt_validation;

   end IF;

   CLOSE is_k_locked;

   l_status:='1';
   OPEN cur_status(l_chr_rec.sts_code);
   FETCH cur_status into l_status;
   CLOSE cur_status;
   IF l_status='1' then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_K_STATUS',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_chr_rec.contract_number,
                          p_token2        => 'MODIFIER',
                          p_token2_value  => l_chr_rec.contract_number_modifier,
			           p_token3        => 'STATUS',
                          p_token3_value  => l_chr_rec.sts_code);

      RAISE g_exception_halt_validation;
   END IF;

   OPEN cur_mean(l_status);
   FETCH cur_mean into l_status_meaning;
   CLOSE cur_mean;

   IF l_status NOT IN ('ACTIVE','EXPIRED','SIGNED') THEN

      x_return_status := OKC_API.G_RET_STS_ERROR;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_K_STATUS',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_chr_rec.contract_number,
                          p_token2        => 'MODIFIER',
                          p_token2_value  => l_chr_rec.contract_number_modifier,
			           p_token3        => 'STATUS',
                          p_token3_value  => l_status_meaning);

      RAISE g_exception_halt_validation;
   ELSIF l_chr_rec.date_terminated is not null THEN

     x_return_status := OKC_API.G_RET_STS_ERROR;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_FUTURE_TERMINATED_K',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_chr_rec.contract_number );

      RAISE g_exception_halt_validation;
   ELSIF l_chr_rec.date_renewed is not null THEN -- as per connie 11-22-1999

     x_return_status := OKC_API.G_RET_STS_ERROR;

     OKC_API.set_message( p_app_name      => g_app_name,
                          p_msg_name      =>'OKC_RENEWED_CONTRACT',
                          p_token1        =>'NUMBER',
                          p_token1_value  => l_chr_rec.contract_number );

      RAISE g_exception_halt_validation;
   END IF;

 If p_extend_in_parameters_rec.p_perpetual_flag = OKC_API.G_FALSE Then
   IF ( p_extend_in_parameters_rec.p_end_date is null )
    AND
     ( (p_extend_in_parameters_rec.p_uom_code is null)
      OR
       (p_extend_in_parameters_rec.p_duration is null)
     )
   THEN

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_INVALID_PARAMETERS');

        x_return_status := OKC_API.g_ret_sts_error;
        RAISE g_exception_halt_validation;
   END IF;
 END IF;

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
 NULL;
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_chr;

PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
       	              p_init_msg_list                IN  VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_rec     IN  extend_in_cle_rec ) is

-- bug # 5757116 added trunc in the where clause of the cursor.
 CURSOR cur_k_lines is
 SELECT cle.line_number,cle.item_description,cle.id,cle.lse_id,cle.sts_code,cle.dnz_chr_id,
        cle.object_version_number,cle.date_terminated,cle.end_date,sts.ste_code
  FROM  okc_k_lines_v cle,
        okc_statuses_b sts
  WHERE cle.id       = p_extend_in_parameters_rec.p_cle_id
   AND  trunc(cle.end_date) = trunc(p_extend_in_parameters_rec.p_orig_end_date)
   AND  cle.sts_code = sts.code;

  CURSOR cur_mean(p_sts_code varchar2) is
  SELECT meaning
    FROM okc_statuses_v
   WHERE code = p_sts_code;

   Cursor cur_k_end_date(p_id number) is
   SELECT end_date+1 from okc_k_headers_b
   WHERE id=p_id;

 k_lines_rec  cur_k_lines%rowtype;

 l_return_status varchar2(1) := OKC_API.g_ret_sts_success;

 l_status_meaning okc_statuses_v.meaning%type;
 l_extend_in_parameters_rec extend_in_parameters_rec;

 BEGIN
 --dbms_output.put_line('validate cle (+) ');
   x_return_status := okc_api.g_ret_sts_success;

   OKC_API.init_msg_list(p_init_msg_list);

   OPEN cur_k_lines;
   FETCH cur_k_lines into k_lines_rec;

   IF cur_k_lines%notfound THEN  -- contract header_id is wrong

     OKC_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => 'OKC_LINE_ID_MISSING',
                         p_token1        => 'LINE_NUMBER',
                         p_token1_value  => k_lines_rec.line_number,
                         p_token2        => 'DESCRIPTION',
                         p_token2_value  => k_lines_rec.item_description);

      CLOSE cur_k_lines;
      x_return_status := okc_api.g_ret_sts_error;
      RAISE g_exception_halt_validation;
   end IF;

  CLOSE cur_k_lines;

  -- Commenting out the following since this check is also performed
  -- at the end of this procedure.
  /* IF k_lines_rec.end_date >= p_extend_in_parameters_rec.p_end_date then

        OKC_API.set_message( p_app_name      => g_app_name,
                             p_msg_name      => 'OKC_INVALID_EXTEND_DATE');

     x_return_status := okc_api.g_ret_sts_error;
     RAISE g_exception_halt_validation;

  END IF; */

  IF g_lines_count = 0 THEN   -- validate header only once

     g_lines_count := 1;

--san
-- Since 'the new enddate for contract should be greater than existing end date for contract' check
-- has been already performed when we extend the header in extend_cle in pub if new end_date
--for line is greater than end date of header. There is no need
--to check the end_date of the line against the end date of header
--as this will return false error when new end date of line is less or equal
--false error because a line can end before contract ends
--so populate with the existing header end_date+1 to avoid that false error
--coming from validate_chr
--end san

   Open cur_k_end_date(k_lines_rec.dnz_chr_id);
   FETCH cur_k_end_date into l_extend_in_parameters_rec.p_end_date;
   Close cur_k_end_date;


   l_extend_in_parameters_rec.p_contract_id     :=   k_lines_rec.dnz_chr_id;

   If l_extend_in_parameters_rec.p_end_date Is Null Then
     l_extend_in_parameters_rec.p_perpetual_flag := OKC_API.G_TRUE;
   Else
     l_extend_in_parameters_rec.p_perpetual_flag := OKC_API.G_FALSE;
   End If;

   --san its wrong to populate the new_end_date of line in new end_date of contract
   --as these are two differnet dates and may or maynot be same
   --so commented the following and wrote the above cursor instead

   --l_extend_in_parameters_rec.p_uom_code        :=   p_extend_in_parameters_rec.p_uom_code;
   --l_extend_in_parameters_rec.p_duration        :=   p_extend_in_parameters_rec.p_duration;
   --l_extend_in_parameters_rec.p_end_date        :=   p_extend_in_parameters_rec.p_end_date;

    --dbms_output.put_line('validate chr (+) ');

    OKC_EXTEND_PVT.validate_chr(p_api_version          	=> 1,
                       	        p_init_msg_list        	=> OKC_API.G_FALSE,
                       	        x_return_status        	=> l_return_status,
	                        x_msg_count            	=> x_msg_count,
                                x_msg_data             	=> x_msg_data,
  	                        p_extend_in_parameters_rec  => l_extend_in_parameters_rec );

	--dbms_output.put_line('validate chr (-) ');
     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	   x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

   end IF;


   IF k_lines_rec.ste_code NOT IN ('ACTIVE','EXPIRED','ENTERED','SIGNED') THEN

      x_return_status := OKC_API.G_RET_STS_ERROR;

	 open cur_mean(k_lines_rec.ste_code);
	 fetch cur_mean into l_status_meaning;
	 close cur_mean;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_K_STATUS',
                          p_token1        => 'NUMBER',
                          p_token1_value  => k_lines_rec.line_number||' - '||k_lines_rec.item_description,
                          p_token3        => 'STATUS',
                          p_token3_value  => l_status_meaning);

        RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSIF k_lines_rec.date_terminated is not null THEN

     x_return_status := OKC_API.G_RET_STS_ERROR;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_FUTURE_TERMINATED_K',
                          p_token1        => 'NUMBER',
                          p_token1_value  => k_lines_rec.line_number||' - '|| k_lines_rec.item_description );

        RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   If p_extend_in_parameters_rec.p_perpetual_flag = OKC_API.G_FALSE Then
     If (p_extend_in_parameters_rec.p_end_date is null) And
        ((p_extend_in_parameters_rec.p_uom_code is null) Or
         (p_extend_in_parameters_rec.p_duration is null)) Then

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_INVALID_PARAMETERS');

        x_return_status := OKC_API.g_ret_sts_error;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     End If;
   End If;

 IF (p_extend_in_parameters_rec.p_end_date is not null)  THEN
   IF p_extend_in_parameters_rec.p_end_date < k_lines_rec.end_date  THEN

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_EXTEND_DATE');

      x_return_status := OKC_API.g_ret_sts_error;
   end IF;
 end IF;

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
 null;
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cle;

PROCEDURE update_enddate( p_api_version           IN  NUMBER,
            	           p_init_msg_list         IN  VARCHAR2 ,
	                     x_return_status         OUT NOCOPY VARCHAR2,
                          x_msg_count             OUT NOCOPY NUMBER,
                          x_msg_data              OUT NOCOPY VARCHAR2,
			           p_chr_rec               IN  okc_contract_pub.chrv_rec_type,
                          p_new_end_date          IN  DATE ) is

-- bug#5757116 added trunc in the where clause of the cursor.
 CURSOR cur_k_lines is
 SELECT cle.id
   FROM okc_k_lines_b cle,
	   okc_statuses_b sts
  WHERE trunc(cle.end_date)   = trunc(p_chr_rec.end_date)
    AND cle.dnz_chr_id = p_chr_rec.id
    AND Cle.chr_id is not null
    AND cle.sts_code  = sts.code
    AND sts.ste_code in ('ACTIVE','EXPIRED','ENTERED','SIGNED');

 CURSOR cur_k_sublines(p_id number) is
 SELECT cle.id,cle.object_version_number,cle.sts_code,cle.end_date
   FROM okc_k_lines_b cle
   CONNECT BY PRIOR id=cle_id
   start with id=p_id;

  CURSOR cur_status(p_sts_code varchar2) is
  SELECT ste_code
    FROM okc_statuses_b
   WHERE code = p_sts_code;

 l_chr_rec  okc_contract_pub.chrv_rec_type := p_chr_rec;
 i_chr_rec  okc_contract_pub.chrv_rec_type;

 l_cle_rec  okc_contract_pub.clev_rec_type;
 i_cle_rec  okc_contract_pub.clev_rec_type;

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_api_name constant varchar2(30) := 'update_enddate';
 l_status_code okc_statuses_v.ste_code%type;

BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PROCESS',
                                              x_return_status);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


  -- The following check is required because this PROCEDURE will be called when a line or a contract
  -- is extended. when a line is extended it is required to update the header only IF line is extended beyond
  -- the headers end date.


    l_chr_rec.end_date := p_new_end_date;

  --Bug 3926932 Checking if the new end date is null incase of perpetual extension
  IF p_new_end_date is null or p_new_end_date >= trunc(sysdate) THEN

   OPEN cur_status(l_chr_rec.sts_code);
   FETCH cur_status into l_status_code;
   CLOSE cur_status;

   IF l_status_code = 'EXPIRED' then

      OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                         p_status_type   => 'ACTIVE',
                                         x_status_code   => l_status_code );

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

     l_chr_rec.sts_code := l_status_code;
	--
	-- Bug# 1468224, Status Change Action Assembler
	-- The status will change from 'EXPIRED" to 'ACTIVE' when a contract gets extended
	--
	l_chr_rec.old_sts_code := 'EXPIRED';
	l_chr_rec.old_ste_code := 'EXPIRED';
	l_chr_rec.new_sts_code := l_status_code;
	l_chr_rec.new_ste_code := 'ACTIVE';


  END IF;
 END IF;
	  OKC_CONTRACT_PUB.update_contract_header ( p_api_version        => 1,
	                                            p_init_msg_list      => OKC_API.G_FALSE,
	                                            x_return_status      => l_return_status,
	      					              x_msg_count          => x_msg_count,
	                                            x_msg_data           => x_msg_data,
									    p_restricted_update  => okc_api.g_true,
	                                            p_chrv_rec           => l_chr_rec,
	                                            x_chrv_rec           => i_chr_rec  );

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


 FOR k_main_rec in cur_k_lines
 LOOP
  FOR k_lines_rec in cur_k_sublines(k_main_rec.id)
  LOOP
      l_status_code:=OKC_API.G_MISS_CHAR;
      OPEN cur_status(k_lines_rec.sts_code);
      FETCH cur_status into l_status_code;
      CLOSE cur_status;

-- bug # 5757116 Added trunc to the end date to truncate the time stamps.
      IF k_lines_rec.end_date is not null AND trunc(k_lines_rec.end_date)=trunc(p_chr_rec.end_date)
	   AND l_status_code in ('ACTIVE','EXPIRED','ENTERED','SIGNED') THEN

            l_cle_rec.id                    := k_lines_rec.id;
            l_cle_rec.object_version_number := k_lines_rec.object_version_number;
            l_cle_rec.end_date              := trunc(p_new_end_date);

            --Bug 3926932 Checking if the new end date is null incase of perpetual extension
            IF p_new_end_date is null or p_new_end_date >= trunc(sysdate) THEN

            /* OPEN cur_status(k_lines_rec.sts_code);
             FETCH cur_status into l_status_code;
             CLOSE cur_status;
	       */

             IF l_status_code = 'EXPIRED' then

                OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                         p_status_type   => 'ACTIVE',
                                         x_status_code   => l_status_code );

                 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                       raise OKC_API.G_EXCEPTION_ERROR;
                 END IF;

                 l_cle_rec.sts_code := l_status_code;

             END IF;
          END IF;
--
-- Bug# 1405237. Avoide calling action assembler
--
		l_cle_rec.call_action_asmblr := 'N';

	       OKC_CONTRACT_PUB.update_contract_line ( p_api_version         => 1,
	                                          p_init_msg_list       => OKC_API.G_FALSE,
	                                          x_return_status       => l_return_status,
	                                          x_msg_count           => x_msg_count,
	                                          x_msg_data            => x_msg_data,
									  p_restricted_update   => okc_api.g_true,
	                                          p_clev_rec            => l_cle_rec,
	                                          x_clev_rec            => i_cle_rec  );

             IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
         END IF;

   END LOOP;
 END LOOP;

OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
WHEN OTHERS THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
END update_enddate;

PROCEDURE update_condition_headers ( p_api_version                  IN  NUMBER,
       	                           p_init_msg_list                IN  VARCHAR2 ,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_chr_id                       IN  NUMBER,
                                     p_old_end_date                 IN  VARCHAR2,
                                     p_new_end_date                 IN  VARCHAR2) is

 CURSOR cur_condition_headers is
 SELECT id,object_version_number,date_active,date_inactive
 FROM okc_condition_headers_b
 WHERE dnz_chr_id = p_chr_id
   and date_inactive = p_old_end_date
   FOR update of id nowait;

 l_cnh_rec  okc_conditions_pub.cnhv_rec_type;
 i_cnh_rec  okc_conditions_pub.cnhv_rec_type;

 E_Resource_Busy               EXCEPTION;
 PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_api_name constant varchar2(30) := 'update_conditions';

BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                               p_init_msg_list,
                               '_PROCESS',
                               x_return_status);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


 FOR conditions_rec in cur_condition_headers LOOP
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_off;
  END IF;
  l_cnh_rec.id := conditions_rec.id;

  l_cnh_rec.object_version_number := conditions_rec.object_version_number;

  l_cnh_rec.date_inactive := p_new_end_date;

	  okc_conditions_pub.update_cond_hdrs( p_api_version     => 1,
	                                       p_init_msg_list   => OKC_API.G_FALSE,
	                                       x_return_status   => l_return_status,
	                                       x_msg_count       => x_msg_count,
	                                       x_msg_data        => x_msg_data,
	                                       p_cnhv_rec        => l_cnh_rec,
	                                       x_cnhv_rec        => i_cnh_rec);
       IF (l_debug = 'Y') THEN
          okc_debug.set_trace_off;
       END IF;
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

 end LOOP;
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
 END IF;
 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
 WHEN E_Resource_Busy THEN
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
 END IF;
 x_return_status := okc_api.g_ret_sts_error;

      OKC_API.set_message(G_FND_APP,
                          G_FORM_UNABLE_TO_RESERVE_REC);
      RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;

 WHEN OKC_API.G_EXCEPTION_ERROR THEN
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_on;
  END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');

 WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_on;
  END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
 WHEN OTHERS THEN
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_on;
  END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
END update_condition_headers;


PROCEDURE update_time_values ( p_api_version     IN  NUMBER,
       	                     p_init_msg_list   IN  VARCHAR2 ,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_msg_count       OUT NOCOPY NUMBER,
                               x_msg_data        OUT NOCOPY VARCHAR2,
		                     p_tve_id          IN  NUMBER,
                               p_tve_id_limited  IN  NUMBER,
                               p_tve_type  	    IN  VARCHAR2,
		                     p_new_end_date    IN  DATE ) is

 l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 l_tavv_ext_rec  OKC_TIME_PUB.tavv_rec_type;
 i_tavv_ext_rec  OKC_TIME_PUB.tavv_rec_type;

 l_isev_rec      OKC_TIME_PUB.isev_ext_rec_type;
 i_isev_rec      OKC_TIME_PUB.isev_ext_rec_type;

CURSOR CUR_TIME_VALUES (p_tve_id in okc_timevalues.id%type)is
 SELECT id,object_version_number
 FROM okc_timevalues
 WHERE id = p_tve_id;

CURSOR CUR_IS_ISE(p_tve_id okc_timevalues.id%type) is
SELECT 'x'
FROM okc_time_ia_startend_val_v
WHERE id = p_tve_id;

l_flag varchar2(1);
l_id okc_timevalues.id%type;
l_object_version_number  okc_timevalues.object_version_number%type;
l_api_name constant varchar2(30) := 'update_time_values';

BEGIN
   --dbms_output.put_line('update time (+)');
   --dbms_output.put_line('p_new_end_date'||p_new_end_date);
   OKC_API.init_msg_list(p_init_msg_list);

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                             p_init_msg_list,
                                             '_PROCESS',
                                             x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  IF p_tve_type = 'ISE' THEN
   --dbms_output.put_line('ISE');
  OPEN cur_time_values(p_tve_id);
  FETCH cur_time_values into l_id,l_object_version_number;

   IF cur_time_values%found THEN

    OPEN cur_is_ise(p_tve_id);
    FETCH cur_is_ise into l_flag;

    IF cur_is_ise%found THEN -- This implies that this ISE will have TAV's, so update those

     l_isev_rec.id := l_id;
     l_isev_rec.object_version_number := l_object_version_number;
     l_isev_rec.end_date := p_new_end_date;

     OKC_TIME_PUB.lock_ia_startend(p_api_version     	=> 1,
                                   p_init_msg_list   	=> OKC_API.G_FALSE,
                                   x_return_status   	=> l_return_status,
                                   x_msg_count       	=> x_msg_count,
                                   x_msg_data        	=> x_msg_data,
                                   p_isev_ext_rec      => l_isev_rec );


     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_TIME_PUB.update_ia_startend(p_api_version    	=> 1,
                                     p_init_msg_list  	=> OKC_API.G_FALSE,
                                     x_return_status  	=> l_return_status,
                                     x_msg_count      	=> x_msg_count,
                                     x_msg_data       	=> x_msg_data,
  	                                p_isev_ext_rec    => l_isev_rec,
  	                                x_isev_ext_rec    => i_isev_rec );

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

   end IF; -- cur_is_ise

   CLOSE cur_is_ise;

   end IF; -- cur_time_values

   CLOSE cur_time_values;

  ELSIF p_tve_type = 'TPA' THEN
   --dbms_output.put_line('TPA');
  OPEN cur_time_values(p_tve_id);
  FETCH cur_time_values into l_id,l_object_version_number;

   IF cur_time_values%found THEN

    l_tavv_ext_rec.id := l_id;
    l_tavv_ext_rec.object_version_number := l_object_version_number;
    l_tavv_ext_rec.datetime := p_new_end_date;


      OKC_TIME_PUB.lock_tpa_value(  p_api_version   => 1,
                                    p_init_msg_list => okc_api.g_false,
 	            	                x_return_status => l_return_status,
  	                               x_msg_count     => x_msg_count,
        	                          x_msg_data      => x_msg_data,
 	                               p_tavv_rec      => l_tavv_ext_rec );


       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


      OKC_TIME_PUB.update_tpa_value(p_api_version   => 1,
                                    p_init_msg_list => okc_api.g_false,
 	            	                x_return_status => l_return_status,
  	                               x_msg_count     => x_msg_count,
        	                          x_msg_data      => x_msg_data,
 	                               p_tavv_rec      => l_tavv_ext_rec,
 	                               x_tavv_rec      => i_tavv_ext_rec );


       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
   END IF;

   CLOSE cur_time_values;

  ELSIF ( p_tve_type in ('TGD','CYL') and p_tve_id_limited is not null)  THEN
   --dbms_output.put_line('TGD,CYL tve_id_limited not null');
  OPEN cur_time_values(p_tve_id_limited);

  FETCH cur_time_values into l_id,l_object_version_number;

   IF cur_time_values%found THEN

     l_isev_rec.id := l_id;
     l_isev_rec.object_version_number := l_object_version_number;
     l_isev_rec.end_date := p_new_end_date;

       OKC_TIME_PUB.lock_ia_startend(p_api_version     => 1,
                                     p_init_msg_list   => OKC_API.G_FALSE,
                                     x_return_status   => l_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
  	                                p_isev_ext_rec    => l_isev_rec );


       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


     OKC_TIME_PUB.update_ia_startend(p_api_version     => 1,
                                     p_init_msg_list   => OKC_API.G_FALSE,
                                     x_return_status   => l_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
  	                                p_isev_ext_rec    => l_isev_rec,
  	                                x_isev_ext_rec    => i_isev_rec );

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

   END IF;

   CLOSE cur_time_values;

  END IF;

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   --dbms_output.put_line('update time (-) ');
EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN
 IF cur_time_values%isOPEN THEN
    CLOSE cur_time_values;
 end IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                      'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

 IF cur_time_values%isOPEN THEN
    CLOSE cur_time_values;
 end IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
WHEN OTHERS THEN
 IF cur_time_values%isOPEN THEN
    CLOSE cur_time_values;
 end IF;
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
end update_time_values;

PROCEDURE extend_chr( p_api_version                  IN  NUMBER,
         	            p_init_msg_list                IN  VARCHAR2 ,
                      x_return_status                OUT NOCOPY VARCHAR2,
                      x_msg_count                    OUT NOCOPY NUMBER,
                      x_msg_data                     OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_rec     IN  extend_in_parameters_rec
                    ) is

--bug # 5757116 added trunc to the start and end date in the where clause of the cursor.
    CURSOR cur_k_header is
    SELECT ID,
        OBJECT_VERSION_NUMBER,
	   STS_CODE,
	   CONTRACT_NUMBER,
	   CONTRACT_NUMBER_MODIFIER,
	   END_DATE
      FROM okc_k_headers_v
      WHERE id         = p_extend_in_parameters_rec.p_contract_id
        and trunc(start_date) = trunc(p_extend_in_parameters_rec.p_orig_start_date)
        and trunc(end_date)   = trunc(p_extend_in_parameters_rec.p_orig_end_date)
        FOR UPDATE OF start_date NOWAIT;

rec_k_header  OKC_CONTRACT_PUB.chrv_rec_type;

CURSOR lock_lines is
SELECT *
FROM okc_k_lines_v
WHERE dnz_chr_id = p_extend_in_parameters_rec.p_contract_id
FOR update of line_number nowait;

CURSOR lock_rules is
 SELECT *
  FROM  okc_rules_v
 WHERE  dnz_chr_id = p_extend_in_parameters_rec.p_contract_id
   FOR  update of object1_id1 nowait;

CURSOR cur_header_aa IS
SELECT k.estimated_amount,k.scs_code,scs.cls_code,k.sts_code
 FROM OKC_K_HEADERS_B K,
	 OKC_SUBCLASSES_B SCS
WHERE k.id = p_extend_in_parameters_rec.p_contract_id
 AND  k.scs_code = scs.code;

 l_scs_code okc_subclasses_v.code%type;
 l_cls_code okc_subclasses_v.cls_code%type;
 l_k_status_code okc_k_headers_v.sts_code%type;
 l_estimated_amount number;

-- Bring only those line that have the same end date as of the header.

-- bug # 5757116 Added trunc to the end date in the where clause of the cursor.
CURSOR cur_k_lines(p_chr_id number,p_end_date date) is
 SELECT cle.id,cle.end_date,cle.start_date,cle.object_version_number
  FROM  okc_k_lines_b cle,
        okc_statuses_b sts
  WHERE cle.dnz_chr_id = p_chr_id
    and trunc(cle.end_date) = trunc(p_end_date)
    and cle.sts_code = sts.code
    and sts.ste_code in ('ACTIVE','EXPIRED','ENTERED','SIGNED')
    and date_terminated is null;

 l_extend_in_parameters_rec  extend_in_parameters_rec := p_extend_in_parameters_rec;
 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;

 l_api_name constant varchar2(30) := 'extend_chr';
 l_new_end_date date;

  CURSOR cur_status(p_sts_code varchar2) is
  SELECT ste_code
  FROM   okc_statuses_b
  WHERE   code = p_sts_code;

l_ste_code okc_statuses_v.ste_code%type;

-- Added for providing extend callout - from header - Bug 2346862/2648677
-- Cursor created to get the PDF_ID for Class 'SERVICE'
    --CURSOR c_pdf IS
    --SELECT pdf_id
    --FROM okc_class_operations
    --WHERE opn_code = 'EXTEND'
    --AND   cls_code = 'SERVICE';

    CURSOR c_pdf(p_cls_code okc_class_operations_v.cls_code%type) IS
    SELECT pdf_id
    FROM okc_class_operations
    WHERE opn_code = 'EXTEND'
    AND   cls_code = p_cls_code;

    l_pdf_id  NUMBER;
    l_cle_id  NUMBER;
    l_chr_id  NUMBER;
    l_cnt     NUMBER;
    l_string  VARCHAR2(32000);
    proc_string VARCHAR2(32000);
-- Cursor created to get the PDF_ID for Class 'SERVICE'

BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PROCESS',
                                              x_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;



IF g_called_FROM = 'HEADER' THEN  -- Included this condition because line will also call header

 OPEN cur_k_header;
 FETCH cur_k_header into
         rec_k_header.ID,
	    rec_k_header.OBJECT_VERSION_NUMBER,
	    rec_k_header.STS_CODE,
	    rec_k_header.CONTRACT_NUMBER,
	    rec_k_header.CONTRACT_NUMBER_MODIFIER,
	    rec_k_header.END_DATE;
 -- This condition will imply that the dates on the contract have been changed after the user submitted
 -- the contract for extension.  In this case skip the contract for extension and RAISE expected error.

IF (l_debug = 'Y') THEN
   okc_debug.set_trace_off;
END IF;
 IF cur_k_header%notfound THEN

     OKC_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => 'OKC_K_CHANGED',
                         p_token1        => 'CONTRACT_NUMBER',
                         p_token1_value  =>  p_extend_in_parameters_rec.p_contract_number,
                         p_token2        => 'MODIFIER',
                         p_token2_value  =>  p_extend_in_parameters_rec.p_contract_modifier);

    CLOSE cur_k_header;
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_on;
  END IF;
   RAISE okc_api.g_exception_error;

 END IF;

 CLOSE cur_k_header;
IF (l_debug = 'Y') THEN
   okc_debug.set_trace_on;
END IF;
-- Now that the dates haven't changed validate the input arguements

    --dbms_output.put_line(' VALIDATE_CHR + ');

    OKC_EXTEND_PVT.validate_chr(p_api_version     	    => 1,
                                p_init_msg_list   	    => OKC_API.G_FALSE,
                                x_return_status   	    => l_return_status,
                                x_msg_count       	    => x_msg_count,
                                x_msg_data          	    => x_msg_data,
                                p_extend_in_parameters_rec => l_extend_in_parameters_rec);
    --dbms_output.put_line(' VALIDATE_CHR - ');

       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

 -- The following commented out since this check is already done in validate_chr
 /* IF p_extend_in_parameters_rec.p_end_date is not null THEN
   IF p_extend_in_parameters_rec.p_end_date < rec_k_header.end_date  THEN

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_EXTEND_DATE');

      RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;
 END IF; */

 -- Set the new end date. At this point since validation is done
 -- assume either end_date or UOM and Duration exists

 If p_extend_in_parameters_rec.p_perpetual_flag = OKC_API.G_FALSE Then
   IF p_extend_in_parameters_rec.p_end_date is not null THEN
     l_new_end_date := p_extend_in_parameters_rec.p_end_date;
   else
     l_new_end_date := okc_time_util_pub.get_enddate(rec_k_header.end_date + 1,
                                                     p_extend_in_parameters_rec.p_uom_code,
                                                     p_extend_in_parameters_rec.p_duration);
   end if;
 Else
   l_new_end_date := Null;
 End If;

  --dbms_output.put_line('l_new_end_date '||l_new_end_date);

    --dbms_output.put_line('l_new_end_date '||l_new_end_date);

    --dbms_output.put_line('update_dnz_startend + ');

           update_enddate( p_api_version     	=> 1,
                           p_init_msg_list   	=> OKC_API.G_FALSE,
                           x_return_status   	=> l_return_status,
                           x_msg_count       	=> x_msg_count,
                           x_msg_data        	=> x_msg_data,
                           p_chr_rec              => rec_k_header,
                           p_new_end_date         => l_new_end_date );

    --dbms_output.put_line('update_dnz_startend - ');

          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

end IF;  ---Header

    --dbms_output.put_line('    update_condition_headers + ');

    update_condition_headers( p_api_version     	=> 1,
                              p_init_msg_list   	=> OKC_API.G_FALSE,
                              x_return_status   	=> l_return_status,
                              x_msg_count       	=> x_msg_count,
                              x_msg_data        	=> x_msg_data,
                              p_chr_id           	=> p_extend_in_parameters_rec.p_contract_id,
                              p_old_end_date     	=> p_extend_in_parameters_rec.p_orig_end_date,
                              p_new_end_date     	=> l_new_end_date );

    --dbms_output.put_line('    update_condition_headers - ');

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
/* Commenting out as Time Values is obsoleted*/
    --dbms_output.put_line('RES_TIME_EXTND_K + ');
/*
    OKC_TIME_RES_PUB.res_time_extnd_k( p_api_version        => 1,
                                       p_init_msg_list      => OKC_API.G_FALSE,
                                       x_return_status      => l_return_status,
                               	    p_chr_id             => rec_k_header.id,
                                       p_cle_id             => null,
                                       p_start_date        	=> p_extend_in_parameters_rec.p_orig_end_date,
                                       p_end_date           => l_new_end_date);
    --dbms_output.put_line('RES_TIME_EXTND_K - ');
*/
     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

    -- ACTION ASSEMBLER
  	open cur_header_aa;
	fetch cur_header_aa into l_estimated_amount,l_scs_code,l_cls_code,l_k_status_code;
	close cur_header_aa;

	OKC_K_EXTD_ASMBLR_PVT.acn_assemble( p_api_version      => 1,
                                         p_init_msg_list    => OKC_API.G_FALSE,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => x_msg_count,
                                         x_msg_data         => x_msg_data,
                                         p_k_id             => p_extend_in_parameters_rec.p_contract_id,
	      						 p_k_number         => p_extend_in_parameters_rec.p_contract_number,
							      p_k_nbr_mod        => p_extend_in_parameters_rec.p_contract_modifier,
								 p_k_end_date       => p_extend_in_parameters_rec.p_orig_end_date,
								 p_k_class          => l_cls_code,
								 p_k_subclass       => l_scs_code,
								 p_k_status_code    => l_k_status_code,
								 p_estimated_amount => l_estimated_amount,
								 p_new_k_end_date   => l_new_end_date );

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call out for External procedure provided by different classes

  -- Begin - Changes done for Bug 2648677/2346862
      OPEN c_pdf(l_cls_code);
      FETCH c_pdf INTO l_pdf_id;
      okc_create_plsql (p_pdf_id => l_pdf_id,
                        x_string => l_string) ;
      CLOSE c_pdf;

    IF l_string is NOT NULL THEN
       l_chr_id := p_extend_in_parameters_rec.p_contract_id;
       l_cle_id := NULL;
       proc_string := 'begin '||l_string || ' (:b1,:b2,:b3); end ;';
       EXECUTE IMMEDIATE proc_string using l_chr_id,l_cle_id, out l_return_status;
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
           x_return_status := l_return_status;
       END IF;
    END IF;

  -- End - Changes done for Bug 2648677/2346862



	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION

WHEN OKC_API.G_EXCEPTION_ERROR THEN
IF (l_debug = 'Y') THEN
   okc_debug.set_trace_on;
END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');

WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
IF (l_debug = 'Y') THEN
   okc_debug.set_trace_on;
END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
WHEN OTHERS THEN
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
 END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');

end extend_chr;

PROCEDURE extend_cle( p_api_version                  IN  NUMBER,
                      p_init_msg_list                IN  VARCHAR2 ,
                      x_return_status                OUT NOCOPY VARCHAR2,
                      x_msg_count                    OUT NOCOPY NUMBER,
                      x_msg_data                     OUT NOCOPY VARCHAR2,
	              p_extend_in_parameters_rec     IN  extend_in_cle_rec  ) is

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_api_name constant varchar2(30) := 'extend_cle';

 l_new_end_date date;


 CURSOR cur_lines is
 SELECT id,object_version_number,chr_id,date_terminated,end_date,sts_code, start_date
   FROM okc_k_lines_b
  WHERE date_terminated is null
  START WITH id = p_extend_in_parameters_rec.p_cle_id
  CONNECT BY PRIOR id = cle_id
  ORDER BY LEVEL asc
  FOR UPDATE OF id NOWAIT;

CURSOR cur_status (p_sts_code okc_statuses_v.code%type) is
SELECT ste_code
  FROM okc_statuses_b
 WHERE code = p_sts_code;

CURSOR cur_header is
SELECT k.contract_number,k.contract_number_modifier,k.scs_code,scs.cls_code,
	  cle.price_negotiated,cle.sts_code
  FROM okc_k_headers_b k,
	  okc_subclasses_b scs,
	  okc_k_lines_b cle
 WHERE k.id = p_extend_in_parameters_rec.p_dnz_chr_id
   AND cle.chr_id = k.id
   AND cle.id  = p_extend_in_parameters_rec.p_cle_id
   AND k.scs_code = scs.code;

 l_contract_number okc_k_headers_v.contract_number%type;
 l_contract_modifier okc_k_headers_v.contract_number_modifier%type;
 l_kl_sts_code okc_k_lines_v.sts_code%type;
 l_scs_code okc_subclasses_v.code%type;
 l_cls_code okc_subclasses_v.cls_code%type;
 l_price_negotiated number;
 i_cle_rec  okc_contract_pub.clev_rec_type;
 l_cle_rec  okc_contract_pub.clev_rec_type;
 l_status varchar2(30);
 l_status_code okc_statuses_v.code%type;


-- Added for providing extend callout - from Line
-- Cursor created to get the PDF_ID for Class 'SERVICE' - Bug 2648677/2346862
    --CURSOR c_pdf IS
    --SELECT pdf_id
    --FROM okc_class_operations
    --WHERE opn_code = 'EXTEND'
    --AND   cls_code = 'SERVICE';

    CURSOR c_pdf(p_cls_code okc_class_operations_v.cls_code%type) IS
    SELECT pdf_id
    FROM okc_class_operations
    WHERE opn_code = 'EXTEND'
    AND   cls_code = p_cls_code;

    l_pdf_id  NUMBER;
    l_cle_id  NUMBER;
    l_chr_id  NUMBER;
    l_cnt     NUMBER;
    l_string  VARCHAR2(32000);
    proc_string VARCHAR2(32000);


    Cursor LineCov_cur(p_cle_id IN Number) Is
      Select id
      From   OKC_K_LINES_V
      Where  cle_id = p_cle_id
      and    lse_id in (2,13,15,20);
BEGIN

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   l_return_status := OKC_API.START_ACTIVITY( l_api_name,
	                               	      p_init_msg_list,
                               		      '_PROCESS',
                               		      x_return_status );

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

 --dbms_output.put_line('validate cle (+) ');

     OKC_EXTEND_PUB.validate_cle( p_api_version     	      => 1,
                                  p_init_msg_list   	      => OKC_API.G_FALSE,
                                  x_return_status   	      => l_return_status,
                                  x_msg_count       	      => x_msg_count,
                                  x_msg_data          	      => x_msg_data,
                                  p_extend_in_parameters_rec => p_extend_in_parameters_rec );
 --dbms_output.put_line('validate cle (-) ');

       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

 If p_extend_in_parameters_rec.p_perpetual_flag = OKC_API.G_FALSE Then
   IF p_extend_in_parameters_rec.p_end_date is not null and
      p_extend_in_parameters_rec.p_end_date <> okc_api.g_miss_date THEN
     l_new_end_date := p_extend_in_parameters_rec.p_end_date;
   else
     l_new_end_date := okc_time_util_pub.get_enddate(p_extend_in_parameters_rec.p_orig_end_date + 1,
                                                     p_extend_in_parameters_rec.p_uom_code,
                                                     p_extend_in_parameters_rec.p_duration);
   end IF;
 Else
   l_new_end_date := Null;
 End If;


  FOR lines_rec in cur_lines LOOP
    --dbms_output.put_line('header line handler (+) ');
    IF (l_debug = 'Y') THEN
       okc_debug.set_trace_off;
    END IF;

     OPEN cur_status(lines_rec.sts_code);
     FETCH cur_status into l_status;
     CLOSE cur_status;
     IF l_status IN ('ACTIVE','EXPIRED','ENTERED','SIGNED') THEN
        l_cle_rec.id := lines_rec.id;
        l_cle_rec.object_version_number := lines_rec.object_version_number;
        l_cle_rec.end_date := l_new_end_date;
        l_cle_rec.start_date := lines_rec.start_date;


        IF (l_new_end_date Is Null) Or
             (l_new_end_date >= trunc(sysdate)) THEN

             -- Commenting the following since it is exactly same as above fetch.
             -- Instead just set the value of l_status_code.
             /* OPEN cur_status(lines_rec.sts_code);
             FETCH cur_status into l_status_code;
             CLOSE cur_status; */
             l_status_code := l_status;

             IF l_status_code = 'EXPIRED' then

                OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                         p_status_type   => 'ACTIVE',
                                         x_status_code   => l_status_code );
                IF (l_debug = 'Y') THEN
                   okc_debug.set_trace_off;
                END IF;
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_ERROR;
                END IF;

               l_cle_rec.sts_code := l_status_code;

            END IF;
           END IF;
           --
           -- Bug# 1405237: Avoide calling Action Assembler here
           --
                 l_cle_rec.call_action_asmblr := 'N';


                OKC_CONTRACT_PUB.update_contract_line ( p_api_version        => 1,
	                                          p_init_msg_list      => OKC_API.G_FALSE,
	                                          x_return_status      => l_return_status,
	                                          x_msg_count          => x_msg_count,
	                                          x_msg_data           => x_msg_data,
								p_restricted_update  => okc_api.g_true,
	                                          p_clev_rec           => l_cle_rec,
	                                          x_clev_rec           => i_cle_rec  );
                   IF (l_debug = 'Y') THEN
                        okc_debug.set_trace_off;
                   END IF;
                  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

              END IF; -- l_status

 END LOOP;
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
 END IF;
 OPEN cur_header;
 FETCH cur_header into l_contract_number,l_contract_modifier,l_scs_code,l_cls_code,
		l_price_negotiated,l_kl_sts_code;
 CLOSE cur_header;

     OKC_KL_EXTD_ASMBLR_PVT.acn_assemble(p_api_version      => 1,
                                         p_init_msg_list    => OKC_API.G_FALSE,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => x_msg_count,
                                         x_msg_data         => x_msg_data,
                                         p_k_id             => p_extend_in_parameters_rec.p_dnz_chr_id,
					 p_kl_id            => p_extend_in_parameters_rec.p_cle_id,
					 p_kl_end_date      => p_extend_in_parameters_rec.p_orig_end_date,
					 p_new_kl_end_date  => l_new_end_date,
					 p_k_class          => l_cls_code,
					 p_k_subclass       => l_scs_code,
					 p_kl_status_code   => l_kl_sts_code,
					 p_estimated_amount => l_price_negotiated,
					 p_k_number         => l_contract_number,
					 p_k_nbr_mod        => l_contract_modifier );

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call out for External procedure provided by different classes

  -- Begin - Changes done for Bug 2648677/2346862
      OPEN c_pdf(l_cls_code);
      FETCH c_pdf INTO l_pdf_id;
      okc_create_plsql (p_pdf_id => l_pdf_id,
                        x_string => l_string) ;
      CLOSE c_pdf;

    IF l_string is NOT NULL THEN
       l_chr_id := p_extend_in_parameters_rec.p_dnz_chr_id;
       l_cle_id := p_extend_in_parameters_rec.p_cle_id;
       proc_string := 'begin '||l_string || ' (:b1,:b2,:b3); end ;';
       EXECUTE IMMEDIATE proc_string using l_chr_id,l_cle_id, out l_return_status;
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
           x_return_status := l_return_status;
       END IF;
    END IF;

  -- End - Changes done for Bug 2648677/2346862

  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
 END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_on;
  END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
WHEN OTHERS THEN
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
 END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
END extend_cle;
END OKC_EXTEND_PVT;

/
