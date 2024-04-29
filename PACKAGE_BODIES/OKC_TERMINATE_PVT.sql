--------------------------------------------------------
--  DDL for Package Body OKC_TERMINATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMINATE_PVT" as
/* $Header: OKCRTERB.pls 120.2 2006/06/21 12:05:25 nechatur noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


FUNCTION is_k_term_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS

/*p_sts_code is not being used right now as not sure if the refresh from launchpad
  will take place everytime a change happens to a contract or not. That is
  If the status of the contract showing in launchpad would at all times be in sync
  with database.It might not happen due to performance reasons of launchpad. So the current approach.
  But if this sync is assured then  we could use p_sts_code as well*/

    l_sts_code VARCHAR2(100);
    l_cls_code VARCHAR2(100);
    l_template_yn VARCHAR2(10);
    l_code VARCHAR2(100);
    l_app_id okc_k_headers_b.application_id%TYPE;
    l_scs_code okc_k_headers_b.scs_code%TYPE;
    l_k VARCHAR2(255);
    l_mod okc_k_headers_b.contract_number_modifier%TYPE ;
    l_date_term DATE;
    l_allow Varchar2(1) := 'N';


    CURSOR c_chr IS
    SELECT sts_code, template_yn, application_id, scs_code  ,contract_number,
			    contract_number_modifier, date_terminated
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR c_sts(p_code IN VARCHAR2) IS
    SELECT ste_code
    FROM   okc_statuses_b
    WHERE  code = p_code;

    CURSOR c_invoice(p_code IN VARCHAR2,p_sts_code IN VARCHAR2) IS
    SELECT allowed_yn
    FROM OKC_ASSENTS_V
    WHERE opn_code = 'INVOICE'
    AND scs_code = p_code
    AND sts_code = p_sts_code;

  BEGIN

    OPEN c_chr;
    FETCH c_chr INTO l_code, l_template_yn, l_app_id, l_scs_code,l_k,l_mod, l_date_term;
    CLOSE c_chr;

    -- Only for service class
    If l_scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION') THEN
        OPEN c_sts(l_code);
        FETCH c_sts INTO l_sts_code;
        CLOSE c_sts;
        If l_sts_code = 'HOLD' AND l_code <> 'QA_HOLD' Then
           RETURN(TRUE);
        End If;
    End If;

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

    IF l_code = 'QA_HOLD' then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_INVALID_STS',
					 p_token1        => 'component',
					 p_token1_value  => l_k);
	 RETURN(FALSE);
    END IF;

    OPEN c_sts(l_code);
    FETCH c_sts INTO l_sts_code;
    CLOSE c_sts;

    IF l_sts_code NOT IN ('ACTIVE','HOLD','SIGNED','EXPIRED') THEN
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_INVALID_STS',
					 p_token1        => 'component',
					 p_token1_value  => l_k);
      RETURN(FALSE);
    END IF;
-- Added by MSENGUPT on 12/09/2001 for Bug#2143096
    IF l_date_term IS NOT NULL Then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_ALREADY_TERM');
	 RETURN(FALSE);
    end if;

-- end of bug#2143096 -------------

    If okc_util.Get_All_K_Access_Level(p_application_id => l_app_id,
                                       p_chr_id => p_chr_id,
                                       p_scs_code => l_scs_code) <> 'U' Then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_NO_UPDATE',
					 p_token1        => 'CHR',
					 p_token1_value  => l_k);
     Return(FALSE);
    End If;

    -- Bug#3143093 ---
    IF l_scs_code = 'WARRANTY' or l_scs_code = 'SERVICE' then
	  OPEN c_invoice(l_scs_code, l_sts_code);
	  FETCH c_invoice into l_allow;
	  CLOSE c_invoice;

	  IF l_allow <> 'Y' then
		OKC_API.set_message(p_app_name => g_app_name,
						p_msg_name => 'OKC_INVOICE_TERM',
						p_token1 => 'component',
						p_token1_value => l_k);
           RETURN(FALSE);--------------
       END IF;
      END IF;
-- End of Bug# 3143093 ---

    RETURN(TRUE);
  END is_k_term_allowed;


FUNCTION is_kl_term_allowed(p_cle_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS

/*p_sts_code is not being used right now as not sure if the refresh from launchpad
  will take place everytime a change happens to a contract or not. That is
  If the status of the contract showing in launchpad would at all times be in sync
  with database.It might not happen due to performance reasons of launchpad. So the current approach.
  But if this sync is assured then  we could use p_sts_code as well*/

    l_sts_code VARCHAR2(100);
    l_cls_code VARCHAR2(100);
    l_template_yn VARCHAR2(10);
    l_code VARCHAR2(100);
    l_hdr_code VARCHAR2(100);
    l_chr_id   number:=OKC_API.G_MISS_NUM;
    l_app_id okc_k_headers_b.application_id%TYPE;
    l_scs_code okc_k_headers_b.scs_code%TYPE;
    l_k VARCHAR2(255);
    l_mod okc_k_headers_b.contract_number_modifier%TYPE ;
    l_no okc_k_lines_b.line_number%TYPE;
    l_date_term_chr DATE;
    l_date_term_cle DATE;
    l_allow Varchar2(1) := 'N';

    CURSOR c_chr(p_chr_id number) IS
    SELECT template_yn ,sts_code, application_id, scs_code ,contract_number, contract_number_modifier, date_terminated
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR c_cle IS
    SELECT sts_code,dnz_chr_id,line_number , date_terminated
    FROM   okc_k_lines_b
    WHERE  id = p_cle_id;

    CURSOR c_sts(p_code IN VARCHAR2) IS
    SELECT ste_code
    FROM   okc_statuses_b
    WHERE  code = p_code;

    CURSOR c_invoice(p_code IN VARCHAR2,p_sts_code IN VARCHAR2) IS
        SELECT allowed_yn
        FROM OKC_ASSENTS_V
        WHERE opn_code = 'INVOICE'
        AND scs_code = p_code
        AND sts_code = p_sts_code;

  BEGIN

    OPEN c_cle;
    FETCH c_cle INTO l_code,l_chr_id,l_no, l_date_term_cle;
    CLOSE c_cle;

    If l_chr_id=OKC_API.G_MISS_NUM then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_NO_CHR',
					 p_token1        => 'component',
					 p_token1_value  => l_no);
	RETURN (FALSE);
    END IF;

    OPEN c_chr(l_chr_id);
    FETCH c_chr INTO l_template_yn,l_hdr_code, l_app_id, l_scs_code,l_k,l_mod, l_date_term_chr;
    CLOSE c_chr;

    -- Only for service class
    If l_scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION') THEN
        OPEN c_sts(l_code);
        FETCH c_sts INTO l_sts_code;
        CLOSE c_sts;
        If l_sts_code = 'HOLD' AND l_code <> 'QA_HOLD' Then
           RETURN(TRUE);
        End If;
    End If;


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

    IF  l_hdr_code = 'QA_HOLD' then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_INVALID_STS',
					 p_token1        => 'component',
					 p_token1_value  => l_k);
	 RETURN(FALSE);
    END IF;

    OPEN c_sts(l_code);
    FETCH c_sts INTO l_sts_code;
    CLOSE c_sts;

    IF l_sts_code NOT IN ('ACTIVE','HOLD','SIGNED','EXPIRED') THEN
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_INVALID_STS',
					 p_token1        => 'component',
					 p_token1_value  => l_no);
      RETURN(FALSE);
    END IF;

-- Added by MSENGUPT on 12/09/2001 for Bug#2143096

    IF l_date_term_chr IS NOT NULL OR
       l_date_term_cle IS NOT NULL Then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_ALREADY_TERM');
	 RETURN(FALSE);
    end if;
-- end of bug#2143096 -------------

    If okc_util.Get_All_K_Access_Level(p_application_id => l_app_id,
                                       p_chr_id => l_chr_id,
                                       p_scs_code => l_scs_code) <> 'U' Then
      OKC_API.set_message(p_app_name      => g_app_name,
				      p_msg_name      => 'OKC_NO_UPDATE',
					 p_token1        => 'CHR',
					 p_token1_value  => l_k);
      Return(FALSE);
    End If;
--Bug# 3143093 ---

    IF l_scs_code = 'WARRANTY' or l_scs_code = 'SERVICE' then
	  OPEN c_invoice(l_scs_code, l_sts_code);
	  FETCH c_invoice into l_allow;
	  CLOSE c_invoice;

	  IF l_allow <> 'Y' then
		OKC_API.set_message(p_app_name => g_app_name,
		                    p_msg_name => 'OKC_INVOICE_TERM',
						p_token1 => 'component',
						p_token1_value => l_no);
          RETURN(FALSE);
        END IF;
     END IF;
--Bug# 3143093 ---

    RETURN(TRUE);
  END is_kl_term_allowed;


PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
  	                   p_init_msg_list                IN  VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_terminate_in_parameters_rec  IN  terminate_in_parameters_rec ) is

   CURSOR cur_k_header is
    SELECT
	   STS_CODE,
	   CONTRACT_NUMBER,
	   CONTRACT_NUMBER_MODIFIER,
	   TEMPLATE_YN,
	   DATE_TERMINATED,
	   DATE_RENEWED,
        APPLICATION_ID,
        SCS_CODE
      FROM okc_k_headers_b
      WHERE id = p_terminate_in_parameters_rec.p_contract_id;


-- Will not need object_version_number this termination is an adverse step. Even if there
--   was a change in between, contract will be terminated.

 l_chrv_rec  cur_k_header%rowtype;

 CURSOR is_k_locked is
  SELECT 'Y'
  FROM okc_k_processes v
 WHERE v.chr_id = p_terminate_in_parameters_rec.p_contract_id
   and v.in_process_yn='Y';

  CURSOR cur_sts_code (l_code varchar2) is
  SELECT sts.ste_code,sts.meaning
    FROM okc_statuses_v sts
   WHERE sts.code = l_code;

--Commeting Bug 4354983 Takintoy.
--SR check done in OKS_BILL_REC_PUB
/*
  CURSOR cur_service_requests is
   SELECT 'x'
   FROM  okx_incident_statuses_v xis,
         okc_k_lines_b cle
   WHERE cle.id = xis.contract_service_id
     and cle.dnz_chr_id = p_terminate_in_parameters_rec.p_contract_id
     and xis.status_code in ('OPEN'); -- Impact -- DepENDency on status of service requests
*/

--	CURSOR cur_old_contract is
--	  select contract_number,
--		    contract_number_modifier
--	    from okc_k_headers_b
--	   where chr_id_renewed = p_terminate_in_parameters_rec.p_contract_id;

      Cursor cur_old_contract(p_chr_id number) is
	 select k.contract_number,k.contract_number_modifier
		from okc_k_headers_b k,okc_operation_lines a,
		okc_operation_instances b,okc_class_operations c
		where  k.id=a.subject_chr_id
		and a.object_chr_id=p_chr_id and
		c.id=b.cop_id and c.opn_code='RENEWAL'
		and b.id=a.oie_id and a.active_yn='Y' and
		a.subject_cle_id is null and a.object_cle_id is null;
     l_k_num okc_k_headers_v.contract_number%type;
	l_k_mod okc_k_headers_v.contract_number_modifier%type;

-- Find out which statuses are valid FOR termination to continue

  l_chg_request_in_process varchar2(1);

  l_status  varchar2(30);   -- Impact on status
  l_meaning  okc_statuses_v.meaning%type;

  l_return_status varchar2(1) := okc_api.g_ret_sts_success;

BEGIN

   --dbms_output.put_line(' validate_chr (+) ');

   x_return_status := okc_api.g_ret_sts_success;

   okc_api.init_msg_list(p_init_msg_list);

    OPEN cur_k_header;
    FETCH cur_k_header into l_chrv_rec;
    CLOSE cur_k_header;

  IF l_chrv_rec.template_Yn = 'Y' THEN

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_K_TEMPLATE',
                            p_token1        => 'NUMBER',
                            p_token1_value  => l_chrv_rec.contract_number);

         x_return_status := okc_api.g_ret_sts_error;
         RAISE g_exception_halt_validation;
   END if;

   OPEN is_k_locked;
   FETCH is_k_locked into l_chg_request_in_process;

   IF is_k_locked%FOUND THEN

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_K_LOCKED',
                            p_token1        => 'NUMBER',
                            p_token1_value  => l_chrv_rec.contract_number);

      x_return_status := okc_api.g_ret_sts_error;
      CLOSE is_k_locked;
      RAISE g_exception_halt_validation;

   END IF;

   CLOSE is_k_locked;

--Commeting Bug 4354983 Takintoy.
--SR check done in OKS_BILL_REC_PUB
/*
   OPEN cur_service_requests;
   FETCH cur_service_requests into l_status;

   if cur_service_requests%FOUND THEN

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_SR_PENDING',
                            p_token1        => 'NUMBER',
                            p_token1_value  => l_chrv_rec.contract_number);

       x_return_status := okc_api.g_ret_sts_error;

       CLOSE cur_service_requests;
       RAISE g_exception_halt_validation;

   END if;

  CLOSE cur_service_requests;

  */

   l_status:='1';

   OPEN cur_sts_code(l_chrv_rec.sts_code);
   FETCH cur_sts_code into l_status,l_meaning;
   CLOSE cur_sts_code;

   IF l_status='1' then
      --
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_K_STATUS',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_chrv_rec.contract_number,
			           p_token2        => 'MODIFIER',
                          p_token2_value  => l_chrv_rec.contract_number_modifier,
			           p_token3        => 'STATUS',
                          p_token3_value  => l_chrv_rec.sts_code);

      RAISE g_exception_halt_validation;
      --
   END IF;

   IF (l_status NOT IN ('ACTIVE','HOLD','SIGNED','EXPIRED')) OR (l_status='HOLD' and l_chrv_rec.sts_code='QA_HOLD')  THEN

      x_return_status := OKC_API.G_RET_STS_ERROR;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_K_STATUS',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_chrv_rec.contract_number,
                          p_token2        => 'MODIFIER',
                          p_token2_value  => l_chrv_rec.contract_number_modifier,
			           p_token3        => 'STATUS',
                          p_token3_value  => l_meaning);

       RAISE g_exception_halt_validation;

   ELSIF l_chrv_rec.date_terminated is not null THEN

     x_return_status := OKC_API.G_RET_STS_ERROR;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_FUTURE_TERMINATED_K',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_chrv_rec.contract_number );

       RAISE g_exception_halt_validation;

   ELSIF l_chrv_rec.date_renewed is not null THEN

    open cur_old_contract(p_terminate_in_parameters_rec.p_contract_id);
    fetch cur_old_contract into l_k_num,l_k_mod;
    close cur_old_contract;

    x_return_status := 'W';

     OKC_API.set_message( p_app_name      => g_app_name,
                          p_msg_name      =>'OKC_RENEWED_CONTRACT_TERM',
-- nechatur 21-Jun-2006 Bug#5122905 Not display the original Contract and its Modifier, Only display the number and modifier of the renewed contract
/*                        p_token1        =>'NUMBER',
                          p_token1_value  => l_chrv_rec.contract_number,
                          p_token2        =>'MODIFIER',
                          p_token2_value  => l_chrv_rec.contract_number_modifier,  */
                          p_token1        =>'NUMBER',
                          p_token1_value  => l_k_num,
                          p_token2        =>'MODIFIER',
                          p_token2_value  => l_k_mod
					 );
-- End nechatur Bug#5122905

   END IF;
  -- Bug 1349841, Use NVL for Perpetual Contracts
  IF Nvl(p_terminate_in_parameters_rec.p_orig_end_date,
         p_terminate_in_parameters_rec.p_termination_date + 1) <
         p_terminate_in_parameters_rec.p_termination_date then

     x_return_status := OKC_API.G_RET_STS_ERROR;

     OKC_API.set_message( p_app_name      => g_app_name,
                          p_msg_name      =>'OKC_TRMDATE_MORE_END'
                         );


    RAISE g_exception_halt_validation;
  END IF;
   --dbms_output.put_line(' validate_chr (+) ');
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

END;

PROCEDURE terminate_chr( p_api_version                 IN NUMBER,
	 	               p_init_msg_list               IN VARCHAR2 ,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_rec IN terminate_in_parameters_rec
	                  ) is

   CURSOR cur_k_header is
    SELECT ID,
           OBJECT_VERSION_NUMBER,
		 sts_code
      FROM okc_k_headers_v
     WHERE id = p_terminate_in_parameters_rec.p_contract_id
       for update of object_version_number nowait;

-- Will not need object_version_number this termination is an adverse step. Even if there
-- was a change in between, contract will be terminated.

rec_k_header   OKC_CONTRACT_PUB.chrv_rec_type;
--
--
l_ste_code     OKC_STATUSES_V.CODE%TYPE;

  CURSOR C_GET_STE_CODE(p_sts_code varchar2) IS
    SELECT STE_CODE
	 FROM OKC_STATUSES_V
	WHERE CODE = p_sts_code;
--

CURSOR lock_lines is
  SELECT cle.id,
         cle.lse_id,  --added so that we can tell if the line is price hold line
 	    cle.object_version_number,
	    sts.ste_code,
	    cle.start_date,
	    cle.end_date
    FROM okc_k_lines_v cle,
 	    okc_statuses_b sts
   WHERE cle.dnz_chr_id = p_terminate_in_parameters_rec.p_contract_id
     AND cle.sts_code   = sts.code
     AND cle.date_terminated is null
     FOR update of line_number nowait;

-- CURSOR lock_rules is
-- SELECT *
--  FROM  okc_rules_v
-- WHERE  dnz_chr_id = p_terminate_in_parameters_rec.p_contract_id
--   FOR  update of object1_id1 nowait;

-- Bug 1524889: Changed the status check to <> TERMINATED from the
-- earlier ones. This check is required so that you do not try to call
-- the OKS routine that issues a credit memo for a line that was
-- terminated earlier using line termination.

-- Bug 1925467: Commented
-- Bug 1932363: Added another linestyle in the where for 'Usage'
/*
 CURSOR service_top_lines is
 SELECT cle.id,
	   cle.object_version_number,
	   cle.start_date,
	   cle.end_date
  FROM okc_k_lines_b cle,
       okc_line_styles_b lse,
       okc_statuses_b sts,
       okc_k_headers_b k,
       okc_assents a,
       okc_operations_b opn,
       okc_val_line_operations lopn
WHERE cle.chr_id     = p_terminate_in_parameters_rec.p_contract_id
  and lse.id         = cle.lse_id
  and lopn.lse_id    = cle.lse_id
  and lse.lty_code   in ('SERVICE','EXT_WARRANTY','USAGE')
  and cle.sts_code   = sts.code
  and sts.ste_code   <> 'TERMINATED'
  and a.scs_code     = k.scs_code
  and a.sts_code     = cle.sts_code
  and a.allowed_yn   = 'Y'
  and a.opn_code     = opn.code
  and opn.opn_type   = 'LON'
  and opn.code       = 'INVOICE'
  and opn.code       = lopn.opn_code
  and cle.chr_id     = k.id;
*/

 CURSOR cur_condition_headers is
 SELECT id,object_version_number,date_active,date_inactive
   FROM okc_condition_headers_b
  WHERE dnz_chr_id = p_terminate_in_parameters_rec.p_contract_id
    and ( date_inactive > p_terminate_in_parameters_rec.p_termination_date
           or  date_inactive is null )
    FOR update of date_inactive nowait;

 CURSOR cur_change_requests is
 SELECT id,object_version_number
   FROM okc_change_requests_b crt
  WHERE crt.chr_id = p_terminate_in_parameters_rec.p_contract_id
    and crt.crs_code = 'ENT'   ---Impact on change request status
    FOR update of datetime_ineffective nowait;

 CURSOR cur_header_aa IS
 SELECT k.estimated_amount,k.scs_code,scs.cls_code,k.sts_code
   FROM OKC_K_HEADERS_B K,
  	   OKC_SUBCLASSES_B SCS
  WHERE k.id = p_terminate_in_parameters_rec.p_contract_id
    AND k.scs_code = scs.code;

  -- CURSOR for bug 1982629, TERMINATION OF AN EXPIRED CONTRACT
  CURSOR c_get_terminate_date (b_cnh_id NUMBER) IS
  SELECT greatest(nvl(co.datetime, cnh.date_active),
                  p_terminate_in_parameters_rec.p_termination_date )
  FROM   okc_condition_headers_b cnh,
         okc_condition_occurs    co
  WHERE  dnz_chr_id = p_terminate_in_parameters_rec.p_contract_id
  AND    cnh.id     = b_cnh_id
  AND    cnh.id     = co.cnh_id (+);

 l_lse_id number;
 l_cnh_terminate_date DATE;
 l_scs_code okc_subclasses_v.code%type;
 l_cls_code okc_subclasses_v.cls_code%type;
 l_k_status_code okc_k_headers_v.sts_code%type;
 l_estimated_amount number;
 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;

 l_api_name constant varchar2(30) := 'terminate_chr';

 l_chrv_rec   okc_contract_pub.chrv_rec_type ;
 i_chrv_rec   okc_contract_pub.chrv_rec_type ;
 l_clev_rec   okc_contract_pub.clev_rec_type ;
 i_clev_rec   okc_contract_pub.clev_rec_type ;
 l_cnh_rec    okc_conditions_pub.cnhv_rec_type ;
 i_cnh_rec    okc_conditions_pub.cnhv_rec_type ;

 l_crtv_rec  okc_change_request_pub.crtv_rec_type;
 i_crtv_rec  okc_change_request_pub.crtv_rec_type;

 E_Resource_Busy               EXCEPTION;
 PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
 l_amount number;
 l_ter_status_code varchar2(30);
 l_can_status_code varchar2(30);

BEGIN

   --dbms_output.put_line(' terminate_chr (+) ');
   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                             p_init_msg_list,
                                             '_PROCESS',
                                             x_return_status);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

 OPEN cur_k_header;
 FETCH cur_k_header into
         rec_k_header.ID,
	    rec_k_header.OBJECT_VERSION_NUMBER,
	    rec_k_header.STS_CODE;

 if cur_k_header%NOTFOUND THEN

     OKC_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => 'OKC_K_CHANGED',
                         p_token1        => 'NUMBER',
                         --p_token1_value  =>  rec_k_header.contract_number);
                         p_token1_value  =>  p_terminate_in_parameters_rec.p_contract_number,
                         p_token2        => 'MODIFIER',
                         p_token2_value  =>  p_terminate_in_parameters_rec.p_contract_modifier);

     x_return_status := OKC_API.G_RET_STS_ERROR;

    CLOSE cur_k_header;

    raise OKC_API.G_EXCEPTION_ERROR;

 END if;

 CLOSE cur_k_header;

   --dbms_output.put_line(' validate_chr (+) ');

     OKC_TERMINATE_PVT.validate_chr(p_api_version     	            => 1,
                                    p_init_msg_list   	            => OKC_API.G_FALSE,
                                    x_return_status   	            => l_return_status,
                                    x_msg_count       	            => x_msg_count,
                                    x_msg_data        	            => x_msg_data,
                                    p_terminate_in_parameters_rec  => p_terminate_in_parameters_rec);

   --dbms_output.put_line(' validate_chr (-) ');
      IF l_return_status = 'W' then
	    x_return_status := 'W';
      end if;
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                         p_status_type   => 'TERMINATED',
                                         x_status_code   => l_ter_status_code);
      IF (l_debug = 'Y') THEN
         okc_debug.set_trace_off;
      END IF;
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                         p_status_type   => 'CANCELLED',
                                         x_status_code   => l_can_status_code);
      IF (l_debug = 'Y') THEN
         okc_debug.set_trace_off;
      END IF;
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
 l_chrv_rec := rec_k_header;

 l_chrv_rec.trn_code                  := p_terminate_in_parameters_rec.p_termination_reason;
 l_chrv_rec.date_terminated           := p_terminate_in_parameters_rec.p_termination_date;
 l_chrv_rec.id                        := rec_k_header.id;
 l_chrv_rec.object_version_number     := rec_k_header.object_version_number;

 IF p_terminate_in_parameters_rec.p_termination_date <= sysdate THEN

  l_chrv_rec.sts_code := l_ter_status_code;
  --
  -- Added for Bug# 1468224, Action Assembler/OKE related changes
  --
  OPEN C_GET_STE_CODE(rec_k_header.sts_code);
  FETCH C_GET_STE_CODE INTO l_ste_code;
  CLOSE C_GET_STE_CODE;
  --
  l_chrv_rec.old_sts_code := rec_k_header.sts_code;
  l_chrv_rec.new_sts_code := l_ter_status_code;
  l_chrv_rec.old_ste_code := l_ste_code;
  l_chrv_rec.new_ste_code := 'TERMINATED';
  --
 END if;

	  okc_contract_pub.update_contract_header ( p_api_version       => 1,
                                                 p_init_msg_list     => OKC_API.G_FALSE,
	                                            x_return_status     => l_return_status,
	                                            x_msg_count         => x_msg_count,
	                                            x_msg_data          => x_msg_data,
                                                 p_restricted_update => okc_api.g_true,
	                                            p_chrv_rec          => l_chrv_rec,
	                                            x_chrv_rec          => i_chrv_rec  );

   --dbms_output.put_line(' update_contract_header (-) ');

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;

-- Bug 1473143: The loop below was after the loop to update contract
-- lines. The cursor was not working because at that point the lines
-- were already terminated and the status code would not match. It
-- would not be enough to change the cursor clause to look for
-- terminated lines only because this would also include lines that
-- had been terminated much earlier - not in the current run. Hence
-- this procedure is being moved up.

--
-- Bug 1827571: Commented out the following check as it prevents issue
-- of credit memo if the termination date is some time in future.
--
-- IF p_terminate_in_parameters_rec.p_termination_date <= sysdate THEN
/* Commented for Bug 1925467
FOR lines_rec IN service_top_lines LOOP

-- Bug 1524889: Removed date check which used to exist here. The date
-- check ensured that the OKS routine was called only when the
-- termination date was between the start and end date of the line.
-- This check is redudant as the OKS routine should only be called
-- based on the status of the line. To see the exact code removed,
-- take a look at the earlier version.

  --dbms_output.put_line(' PRE_TERMINATE_SERVICE (+) ');

   OKS_BILL_REC_PUB.pre_terminate_service ( p_api_version     	   => 1,
                                 p_init_msg_list   	   => OKC_API.G_FALSE,
                                 x_return_status   	   => l_return_status,
			         p_calledfrom             => NULL,
                                 x_msg_count       	   => x_msg_count,
                                 x_msg_data         	   => x_msg_data,
                                 p_k_line_id              => lines_rec.id,
                                 p_termination_date       => p_terminate_in_parameters_rec.p_termination_date,
                                 p_termination_flag       => 1,
                                 x_amount                 => l_amount );

   --dbms_output.put_line(' PRE_TERMINATE_SERVICE (-) ');

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
   END IF;
 END LOOP;
*/
-- END if;
FOR lines_rec in lock_lines LOOP
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_off;
  END IF;
  l_lse_id := lines_rec.lse_id;

 IF lines_rec.ste_code in ('ACTIVE','ENTERED','HOLD','SIGNED','EXPIRED') THEN
  -- Bug 1349841, Use NVL for Perpetual Contracts
  IF (p_terminate_in_parameters_rec.p_termination_date <=
      Nvl(lines_rec.end_date, p_terminate_in_parameters_rec.p_termination_date))
		--san bug 1662549
	     -- and (p_terminate_in_parameters_rec.p_termination_date >= lines_rec.start_date)
	 then

   IF p_terminate_in_parameters_rec.p_termination_date <= sysdate THEN

    IF lines_rec.ste_code in ('ACTIVE','HOLD','SIGNED','EXPIRED') then

     l_clev_rec.sts_code         := l_ter_status_code;   -- Impact on status --use default method
	l_clev_rec.date_terminated       := p_terminate_in_parameters_rec.p_termination_date;
--Bug 3378196
If p_terminate_in_parameters_rec.p_termination_date < lines_rec.start_date THEN
                l_clev_rec.date_terminated       := lines_rec.start_date;
end if;

    ELSIF lines_rec.ste_code = 'ENTERED' then

    l_clev_rec.sts_code             := l_can_status_code;   -- Impact on status --use default method
    l_clev_rec.date_terminated      := p_terminate_in_parameters_rec.p_termination_date;
--Bug 3378196
If p_terminate_in_parameters_rec.p_termination_date < lines_rec.start_date THEN
                l_clev_rec.date_terminated       := lines_rec.start_date;
end if;
   END IF;

   ELSE

       IF lines_rec.ste_code in ('ACTIVE','HOLD','SIGNED','ENTERED','EXPIRED') then
           l_clev_rec.date_terminated       := p_terminate_in_parameters_rec.p_termination_date;
--Bug 3378196
If p_terminate_in_parameters_rec.p_termination_date < lines_rec.start_date THEN
                l_clev_rec.date_terminated       := lines_rec.start_date;
end if;
       END IF;

	 /*
      IF lines_rec.ste_code = 'ACTIVE' then
        l_clev_rec.date_terminated       := p_terminate_in_parameters_rec.p_termination_date;
      ELSIF lines_rec.ste_code = 'ENTERED' then
        l_clev_rec.date_terminated       := p_terminate_in_parameters_rec.p_termination_date;
	  NULL;
      END IF;
	 */

  END IF;

   l_clev_rec.id                    :=  lines_rec.id;
   l_clev_rec.object_version_number :=  lines_rec.object_version_number;
   l_clev_rec.trn_code              :=  p_terminate_in_parameters_rec.p_termination_reason;
--
-- Bug# 1405237 Avoide calling Action Assembler when the change in line status is resulting from a change in the header status
--
   l_clev_rec.call_action_asmblr    := 'N';


   --dbms_output.put_line(' update_contract_line (+) ');

	  OKC_CONTRACT_PUB.update_contract_line ( p_api_version       => 1,
                                               p_init_msg_list     => OKC_API.G_FALSE,
	                                          x_return_status     => l_return_status,
	                                          x_msg_count         => x_msg_count,
	                                          x_msg_data          => x_msg_data,
                                               p_restricted_update => okc_api.g_true,
	                                          p_clev_rec          => l_clev_rec,
	                                          x_clev_rec          => i_clev_rec  );
            IF (l_debug = 'Y') THEN
               okc_debug.set_trace_off;
            END IF;
   --dbms_output.put_line(' update_contract_line (-) ');

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
   END IF;


   If l_lse_id = 61 Then
            --if the contract line being terminated is a Price Hold line, we need to delete the entry in QP
            --disable the entry in QP
            OKC_PHI_PVT.process_price_hold(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => l_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_chr_id         => p_terminate_in_parameters_rec.p_contract_id,
                         p_termination_date => l_clev_rec.date_terminated,
                         p_operation_code => 'TERMINATE');
    End If;

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          raise OKC_API.G_EXCEPTION_ERROR;
    END IF;



 END IF; -- effectivity check
 END IF; -- ste_code

 END LOOP;
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_on;
  END IF;
 FOR conditions_rec in cur_condition_headers LOOP
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_off;
  END IF;
  l_cnh_rec.id := conditions_rec.id;
  l_cnh_rec.object_version_number := conditions_rec.object_version_number;
  l_cnh_rec.date_inactive := p_terminate_in_parameters_rec.p_termination_date;
  --san the following change done to avoid error return in case date_active is greater than
  --termination date and we try to make date_inactive equal to termination date
  -- This returns error from conditions API. So make both the dates equal to termination date
  IF l_cnh_rec.date_active > p_terminate_in_parameters_rec.p_termination_date then
      l_cnh_rec.date_active := p_terminate_in_parameters_rec.p_termination_date;
  END IF;

  OPEN  c_get_terminate_date(conditions_rec.id);
  FETCH c_get_terminate_date INTO l_cnh_terminate_date;
  IF    c_get_terminate_date%FOUND THEN
        l_cnh_rec.date_inactive := l_cnh_terminate_date;
  END IF;
  CLOSE c_get_terminate_date;

   --dbms_output.put_line(' update_cond_hdrs (+) ');

	  OKC_CONDITIONS_PUB.update_cond_hdrs( p_api_version       => 1,
	                                       p_init_msg_list     => OKC_API.G_FALSE,
	                                       x_return_status     => l_return_status,
	                                       x_msg_count         => x_msg_count,
	                                       x_msg_data          => x_msg_data,
	                                       p_cnhv_rec          => l_cnh_rec,
	                                       x_cnhv_rec          => i_cnh_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.set_trace_off;
    END IF;
   --dbms_output.put_line(' update_cond_hdrs (-) ');

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

 END LOOP;
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
 END IF;
 FOR change_requests_rec in cur_change_requests LOOP
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_off;
 END IF;
   l_crtv_rec.id                    := change_requests_rec.id;
   l_crtv_rec.object_version_number := change_requests_rec.object_version_number;
   l_crtv_rec.datetime_ineffective  := p_terminate_in_parameters_rec.p_termination_date;

 -- Impact on change request status

   --dbms_output.put_line(' update_change_request (+) ');

   OKC_CHANGE_REQUEST_PUB.update_change_request( p_api_version       => 1,
	                                            p_init_msg_list     => OKC_API.G_FALSE,
	                                            x_return_status     => l_return_status,
	                                            x_msg_count         => x_msg_count,
	                                            x_msg_data          => x_msg_data,
	                                            p_crtv_rec          => l_crtv_rec,
	                                            x_crtv_rec          => i_crtv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.set_trace_off;
    END IF;
   --dbms_output.put_line(' update_change_request (-) ');

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

 END LOOP;
IF (l_debug = 'Y') THEN
   okc_debug.set_trace_on;
END IF;

  --dbms_output.put_line(' acn_assemble (+) ');
 -- Raise the event
 IF p_terminate_in_parameters_rec.p_termination_date <= sysdate THEN

  --dbms_output.put_line(' acn_assemble (+) ');

  	open cur_header_aa;
	fetch cur_header_aa into l_estimated_amount,l_scs_code,l_cls_code,l_k_status_code;
	close cur_header_aa;

OKC_K_TERM_ASMBLR_PVT.acn_assemble(p_api_version    => 1,
                                    p_init_msg_list  => OKC_API.G_FALSE,
                                    x_return_status  => l_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data,
                                    p_k_id           => p_terminate_in_parameters_rec.p_contract_id,
	      					 p_k_number       => p_terminate_in_parameters_rec.p_contract_number,
						      p_k_nbr_mod      => p_terminate_in_parameters_rec.p_contract_modifier,
							 p_term_date      => p_terminate_in_parameters_rec.p_termination_date,
							 p_term_reason    => p_terminate_in_parameters_rec.p_termination_reason,
							 p_k_class          => l_cls_code,
							 p_k_subclass       => l_scs_code,
							 p_k_status_code       => l_k_status_code,
							 p_estimated_amount => l_estimated_amount);

  --dbms_output.put_line(' acn_assemble (-) ');
     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

 END IF;

  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   --dbms_output.put_line(' terminate_chr (-) ');
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
END;

PROCEDURE validate_cle( p_api_version                  IN NUMBER,
		              p_init_msg_list                IN VARCHAR2 ,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_terminate_in_parameters_rec  IN  terminate_in_cle_rec
                       ) is

 CURSOR is_line_a_top_line is
 SELECT 'x'
  FROM okc_k_lines_b
 WHERE id = p_terminate_in_parameters_rec.p_cle_id
   and chr_id is not null;

-- Bug 1925467 Commented
-- Bug 1932363: Added another linestyle in the where for 'Usage'
/*
 CURSOR is_line_a_service_line is
 SELECT 'x'
   FROM okc_k_lines_b cle,
        okc_line_styles_b lse
  WHERE cle.id = p_terminate_in_parameters_rec.p_cle_id
    and cle.lse_id = lse.id
    and lse.lty_code in ('SERVICE','EXT_WARRANTY','USAGE');
*/
 CURSOR k_csr is
  SELECT k.template_Yn, k.date_renewed, k.contract_number,
         k.contract_number_modifier, k.sts_code, k.application_id,
         k.scs_code
  FROM okc_k_headers_b k
 WHERE k.id = p_terminate_in_parameters_rec.p_dnz_chr_id;

 l_chrv_rec k_csr%rowtype;

 CURSOR is_k_locked is
  SELECT 'x'
  FROM okc_k_processes v
 WHERE v.chr_id = p_terminate_in_parameters_rec.p_dnz_chr_id
   and v.in_process_yn = 'Y';

  -- p_code changed from number to Varchar2
  CURSOR cur_sts_code(p_code VARCHAR2) is
  SELECT sts.ste_code,sts.meaning
    FROM okc_statuses_v sts
   WHERE sts.code = p_code;
  CURSOR cur_service_requests is
   SELECT 'x'
   FROM  okx_incident_statuses_v xis,
         okc_k_lines_b cle
   WHERE cle.id = xis.contract_service_id
--san below cle.id condition added as we just want to check SRs againt this line only.
	 and cle.id=p_terminate_in_parameters_rec.p_cle_id   --bug 1325866
      and xis.status_code in ('OPEN'); -- Impact -- DepENDency on status of service requests

-- Find out which statuses are valid FOR termination to continue

  l_chg_request_in_process varchar2(1);

  l_status  varchar2(30) ;  -- Impact on status
  l_meaning  okc_statuses_v.meaning%type;

  l_return_status varchar2(1) := okc_api.g_ret_sts_success;
  l_dummy varchar2(1);

  --CURSOR cur_old_contract is
  --SELECT contract_number,contract_number_modifier
  --FROM okc_k_headers_b
  --WHERE chr_id_renewed = p_terminate_in_parameters_rec.p_dnz_chr_id;

    Cursor cur_old_contract(p_chr_id number) is
	 select k.contract_number,k.contract_number_modifier
		from okc_k_headers_b k,okc_operation_lines a,
		okc_operation_instances b,okc_class_operations c
		where  k.id=a.subject_chr_id
		and a.object_chr_id=p_chr_id and
		c.id=b.cop_id and c.opn_code='RENEWAL'
		and b.id=a.oie_id and a.active_yn='Y' and
		a.subject_cle_id is null and a.object_cle_id is null;

   l_k_num okc_k_headers_v.contract_number%type;
   l_k_mod okc_k_headers_v.contract_number_modifier%type;
BEGIN

   x_return_status := okc_api.g_ret_sts_success;

   okc_api.init_msg_list(p_init_msg_list);

   --dbms_output.put_line('is top line (+)');


   OPEN is_line_a_top_line;
   FETCH is_line_a_top_line into l_dummy;

   IF is_line_a_top_line%NOTFOUND THEN

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_CLE_NOT_TOP_LINE' ,
                            p_token1        => 'NUMBER',
                            p_token1_value  => p_terminate_in_parameters_rec.p_line_number);

      x_return_status := okc_api.g_ret_sts_error;
      CLOSE is_line_a_top_line;
      raise G_EXCEPTION_HALT_VALIDATION;
    END if;

   CLOSE is_line_a_top_line;

  --dbms_output.put_line('is top line (-)');
   Open k_csr;
   Fetch k_csr Into l_chrv_rec;
   Close k_csr;
  --dbms_output.put_line('is k locked (+)');

   OPEN is_k_locked;
   FETCH is_k_locked into l_dummy;

   IF is_k_locked%FOUND THEN

	   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_K_LOCKED',
                            p_token1        => 'NUMBER',
                            p_token1_value  => l_chrv_rec.contract_number);

      x_return_status := okc_api.g_ret_sts_error;
      CLOSE is_k_locked;
      raise G_EXCEPTION_HALT_VALIDATION;
   END if;
   CLOSE is_k_locked;

   --dbms_output.put_line('is k locked (-)');

   If l_chrv_rec.template_Yn = 'Y' THEN

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_K_TEMPLATE',
                            p_token1        => 'NUMBER',
                            p_token1_value  => l_chrv_rec.contract_number);

         x_return_status := okc_api.g_ret_sts_error;
      raise G_EXCEPTION_HALT_VALIDATION;
   END if;

  IF l_chrv_rec.sts_code='QA_HOLD' then
          OPEN cur_sts_code(l_chrv_rec.sts_code);
          FETCH cur_sts_code into l_status,l_meaning;
          CLOSE cur_sts_code;

          x_return_status := OKC_API.G_RET_STS_ERROR;

          OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_K_STATUS',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_chrv_rec.contract_number,
                          p_token2        => 'MODIFIER',
                          p_token2_value  => l_chrv_rec.contract_number_modifier,
			           p_token3        => 'STATUS',
                          p_token3_value  => l_meaning);

          RAISE g_exception_halt_validation;
 END IF;

   --dbms_output.put_line('is service lin (+)');
 /*

/*
   OPEN is_line_a_service_line;
   FETCH is_line_a_service_line into l_dummy;

   if is_line_a_service_line%FOUND THEN

	--dbms_output.put_line('is service reqests (+)');

     OPEN cur_service_requests;
     FETCH cur_service_requests into l_status;

	IF cur_service_requests%FOUND THEN

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_SR_PENDING',
                            p_token1        => 'NUMBER',
                            p_token1_value  => l_chrv_rec.contract_number);

       x_return_status := okc_api.g_ret_sts_error;
       CLOSE cur_service_requests;
       raise G_EXCEPTION_HALT_VALIDATION;
    END if;

   CLOSE cur_service_requests;
  --dbms_output.put_line('is service reqests (-)');

  else
      CLOSE is_line_a_service_line;
  END if;
 */

   --dbms_output.put_line('is service lin (-)');

  OPEN cur_sts_code(p_terminate_in_parameters_rec.p_sts_code);
  FETCH cur_sts_code into l_status,l_meaning;
  CLOSE cur_sts_code;

  IF l_status NOT IN ('ACTIVE','HOLD','SIGNED','EXPIRED') THEN

    x_return_status := OKC_API.G_RET_STS_ERROR;

    OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKC_INVALID_K_STATUS',
                        p_token1        => 'NUMBER',
                        p_token1_value  => p_terminate_in_parameters_rec.p_line_number,
				    p_token2        => 'STATUS',
				    p_token2_value  => l_meaning);

    RAISE g_exception_halt_validation;
  END IF;

   if l_chrv_rec.date_renewed is not null THEN

    --open cur_old_contract;
    open cur_old_contract(p_terminate_in_parameters_rec.p_dnz_chr_id);
    fetch cur_old_contract into l_k_num,l_k_mod;
    close cur_old_contract;

    x_return_status := 'W';

     OKC_API.set_message( p_app_name      => g_app_name,
                          p_msg_name      =>'OKC_RENEWED_CONTRACT_TERM',
-- nechatur 21-Jun-2006 Bug#5122905 Not display the original Contract and its Modifier, Only display the number and modifier of the renewed contract
 /*                       p_token1        =>'NUMBER',
                          p_token1_value  => l_chrv_rec.contract_number,
                          p_token2        =>'MODIFIER',
                          p_token2_value  => l_chrv_rec.contract_number_modifier,  */
                          p_token1        =>'NUMBER',
                          p_token1_value  => l_k_num,
                          p_token2        =>'MODIFIER',
                          p_token2_value  => l_k_mod
					 );
-- End nechatur Bug#5122905

  END IF;

  -- Bug 1349841, Use NVL for Perpetual Contracts
  IF Nvl(p_terminate_in_parameters_rec.p_orig_end_date,
         p_terminate_in_parameters_rec.p_termination_date + 1) <
         p_terminate_in_parameters_rec.p_termination_date then

     x_return_status := OKC_API.G_RET_STS_ERROR;

     OKC_API.set_message( p_app_name      => g_app_name,
                          p_msg_name      =>'OKC_TRMDATE_MORE_END');


    RAISE g_exception_halt_validation;
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
END;

PROCEDURE terminate_cle( p_api_version                 IN  NUMBER,
		               p_init_msg_list               IN  VARCHAR2 ,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_rec	IN  terminate_in_cle_rec
	                  )is

 l_return_status varchar2(1)      := OKC_API.G_RET_STS_SUCCESS;
 l_api_name constant varchar2(30) := 'terminate_cle';
 l_dummy varchar2(1);

CURSOR cur_header is
SELECT k.contract_number,k.contract_number_modifier,k.scs_code,scs.cls_code,
		cle.price_negotiated,cle.sts_code
  FROM okc_k_headers_b k,
	  okc_subclasses_b scs,
	  okc_k_lines_b cle
 WHERE k.id = p_terminate_in_parameters_rec.p_dnz_chr_id
   AND cle.chr_id = k.id
   AND cle.id  = p_terminate_in_parameters_rec.p_cle_id
   AND k.scs_code = scs.code;

 l_contract_modifier okc_k_headers_v.contract_number_modifier%type;
 l_contract_number okc_k_headers_v.contract_number%type;
 l_kl_sts_code okc_k_lines_v.sts_code%type;

 l_scs_code okc_subclasses_v.code%type;
 l_cls_code okc_subclasses_v.cls_code%type;
 l_price_negotiated number;

CURSOR cur_lines is
 SELECT id,object_version_number,sts_code,lse_id,start_date,end_date
 FROM okc_k_lines_b
 WHERE date_terminated is null
 START WITH id = p_terminate_in_parameters_rec.p_cle_id
 CONNECT BY PRIOR id = cle_id
 ORDER BY LEVEL DESC
 FOR UPDATE OF id NOWAIT;

-- Bug 1925467: Commented
-- Bug 1932363: Added another linestyle in the where for 'Usage'
/*
 CURSOR is_line_a_service_line is
 SELECT 'x'
  FROM okc_k_lines_b cle,
       okc_line_styles_b lse
 WHERE cle.id = p_terminate_in_parameters_rec.p_cle_id
    and cle.lse_id = lse.id
    and lse.lty_code   in ('SERVICE','EXT_WARRANTY','USAGE');
*/

 CURSOR cur_status (p_code in varchar2) is
 SELECT ste_code
 FROM okc_statuses_b
 WHERE code = p_code;

 l_clev_tbl        okc_contract_pub.clev_tbl_type;
 i_clev_tbl        okc_contract_pub.clev_tbl_type;
 L_LOOP_COUNTER NUMBER := 0;

 E_Resource_Busy               EXCEPTION;
 PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

 l_amount number;
 l_ter_status_code varchar2(30);
 l_can_status_code varchar2(30);

 l_status fnd_lookups.lookup_code%type;
 l_lse_id NUMBER;

BEGIN
 --dbms_output.put_line(' terminate_cle (+) ');

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   l_return_status := OKC_API.START_ACTIVITY( l_api_name,
	                               	      p_init_msg_list,
                               		      '_PROCESS',
                               		      x_return_status );

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     raise OKC_API.G_EXCEPTION_ERROR;
   END IF;

 --dbms_output.put_line(' VALIDATE_CLE (+) ');

  OKC_TERMINATE_PUB.validate_cle(p_api_version     	        => 1,
                                 p_init_msg_list   	        => OKC_API.G_FALSE,
                                 x_return_status   	        => l_return_status,
                                 x_msg_count       	        => x_msg_count,
                                 x_msg_data          	        => x_msg_data,
                                 p_terminate_in_parameters_rec => p_terminate_in_parameters_rec);

 --dbms_output.put_line(' VALIDATE_CLE (-) ');

-- Special status used to show user a message that a renewed contract already exists
 IF l_return_status = 'W' then
	x_return_status := 'W';
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;

  OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                     p_status_type   => 'TERMINATED',
                                     x_status_code   => l_ter_status_code );
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_off;
  END IF;
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                     p_status_type   => 'CANCELLED',
                                     x_status_code   => l_can_status_code);
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_off;
  END IF;
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
IF (l_debug = 'Y') THEN
   OKC_DEBUG.SET_TRACE_OFF;
END IF;
FOR lines_rec in cur_lines LOOP
  l_loop_counter := l_loop_counter + 1;
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_off;
 END IF;
   OPEN cur_status(lines_rec.sts_code);
   fetch cur_status into l_status;
   close cur_status;

   l_lse_id := lines_rec.lse_id;

   IF l_status in ('ACTIVE','HOLD','SIGNED','ENTERED','EXPIRED') then

      -- Bug 1349841, Use NVL for Perpetual Contracts
      IF (p_terminate_in_parameters_rec.p_termination_date <=
          Nvl(lines_rec.end_date, p_terminate_in_parameters_rec.p_termination_date))
		--san bug 1662549
		--and (p_terminate_in_parameters_rec.p_termination_date >= lines_rec.start_date)
		then
         If p_terminate_in_parameters_rec.p_termination_date <= sysdate THEN

             IF l_status in ('ACTIVE','HOLD','SIGNED','EXPIRED') then

	           l_clev_tbl(l_loop_counter).sts_code              := l_ter_status_code;
                l_clev_tbl(l_loop_counter).date_terminated       := p_terminate_in_parameters_rec.p_termination_date;
 --Bug 3378196
If p_terminate_in_parameters_rec.p_termination_date < lines_rec.start_date THEN
                l_clev_tbl(l_loop_counter).date_terminated       := lines_rec.start_date;
end if;
             ELSIF l_status = 'ENTERED' then

                l_clev_tbl(l_loop_counter).sts_code         := l_can_status_code;
                l_clev_tbl(l_loop_counter).date_terminated  := p_terminate_in_parameters_rec.p_termination_date;
 --Bug 3378196
If p_terminate_in_parameters_rec.p_termination_date < lines_rec.start_date THEN
                l_clev_tbl(l_loop_counter).date_terminated       := lines_rec.start_date;
end if;
             END IF;


          ELSE

             IF l_status in ('ACTIVE','HOLD','SIGNED','ENTERED','EXPIRED') then
                l_clev_tbl(l_loop_counter).date_terminated       := p_terminate_in_parameters_rec.p_termination_date;
 --Bug 3378196
If p_terminate_in_parameters_rec.p_termination_date < lines_rec.start_date THEN
                l_clev_tbl(l_loop_counter).date_terminated       := lines_rec.start_date;
end if;
            END IF;
		    /*
              IF l_status = 'ACTIVE' then
                l_clev_tbl(l_loop_counter).date_terminated       := p_terminate_in_parameters_rec.p_termination_date;
              ELSIF l_status = 'ENTERED' then
               l_clev_tbl(l_loop_counter).date_terminated       := p_terminate_in_parameters_rec.p_termination_date;
		     NULL;
              END IF;
		    */

          END if;

          l_clev_tbl(l_loop_counter).id                    := lines_rec.id;
          l_clev_tbl(l_loop_counter).object_version_number := lines_rec.object_version_number;
          l_clev_tbl(l_loop_counter).trn_code              := p_terminate_in_parameters_rec.p_termination_reason;
--
-- Bug# 1405237 Avoide calling Action Assembler when the change in line status is resulting from a change in the header status
--
   l_clev_tbl(l_loop_counter).call_action_asmblr    := 'N';
--
   --dbms_output.put_line('update_contract_line (+) ');
/*
             OKC_CONTRACT_PUB.update_contract_line( p_api_version       => 1,
                                               p_init_msg_list     => OKC_API.G_FALSE,
	                                          x_return_status     => l_return_status,
	                                          x_msg_count         => x_msg_count,
	                                          x_msg_data          => x_msg_data,
	                                          p_restricted_update => okc_api.g_true,
	                                          p_clev_rec          => l_clev_rec,
	                                          x_clev_rec          => i_clev_rec  );
               IF (l_debug = 'Y') THEN
                  okc_debug.set_trace_off;
               END IF;
      --dbms_output.put_line('update_contract_line (-) ');
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               raise OKC_API.G_EXCEPTION_ERROR;
           END IF;
*/
           If l_lse_id = 61 Then
                   --if the contract line being terminated is a Price Hold line, we need to delete the entry in QP
                   --disable the entry in QP
                   OKC_PHI_PVT.process_price_hold(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => l_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_chr_id         => p_terminate_in_parameters_rec.p_dnz_chr_id,
                         p_termination_date => l_clev_tbl(l_loop_counter).date_terminated,
                         p_operation_code => 'TERMINATE');
           End If;

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               raise OKC_API.G_EXCEPTION_ERROR;
           END IF;

       END IF; -- effectivity
  END IF; -- l_status
END LOOP;
IF (l_debug = 'Y') THEN
   OKC_DEBUG.set_trace_off;
END IF;
             OKC_CONTRACT_PUB.update_contract_line( p_api_version       => 1,
                                               p_init_msg_list     => OKC_API.G_FALSE,
	                                          x_return_status     => l_return_status,
	                                          x_msg_count         => x_msg_count,
	                                          x_msg_data          => x_msg_data,
	                                          p_restricted_update => OKC_API.g_true,
	                                          p_clev_tbl          => l_clev_tbl,
	                                          x_clev_tbl          => i_clev_tbl  );
               IF (l_debug = 'Y') THEN
                  OKC_DEBUG.set_trace_off;
               END IF;
      --dbms_output.put_line('update_contract_line (-) ');
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
 END IF;
/* Commented for Bug 1925467
OPEN is_line_a_service_line;
FETCH is_line_a_service_line into l_dummy;
CLOSE is_line_a_service_line;
--
-- Bug 1827571: Commented out the check of termination date against sysdate as it
-- prevents issue of credit memo if the termination date is some time in future.
--
-- If l_dummy = 'x' and p_terminate_in_parameters_rec.p_termination_date <= sysdate and
 If l_dummy = 'x' And
    OKC_ASSENT_PUB.line_operation_allowed(p_terminate_in_parameters_rec.p_cle_id,
                                          'INVOICE') = okc_api.g_true THEN

--dbms_output.put_line('PRE_TERMINATE_SERVICE  (+) ');

   OKS_BILL_REC_PUB.pre_terminate_service ( p_api_version     	   => 1,
                                            p_init_msg_list   	   => OKC_API.G_FALSE,
                                            x_return_status   	   => l_return_status,
                                            x_msg_count       	   => x_msg_count,
                                            x_msg_data         	   => x_msg_data,
					    p_calledfrom           => NULL,
                                            p_k_line_id            => p_terminate_in_parameters_rec.p_cle_id,
                                            p_termination_date     => p_terminate_in_parameters_rec.p_termination_date,
                                            p_termination_flag     => 1,
                                            x_amount               => l_amount );

    --dbms_output.put_line('PRE_TERMINATE_SERVICE  (-) ');

   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
   END IF;
 END if;
*/

-- Raise the line_terminated event

  IF p_terminate_in_parameters_rec.p_termination_date <= sysdate THEN

 OPEN cur_header;
 FETCH cur_header into l_contract_number,l_contract_modifier,l_scs_code,l_cls_code,
				   l_price_negotiated,l_kl_sts_code;
 CLOSE cur_header;

OKC_KL_TERM_ASMBLR_PVT.acn_assemble(p_api_version      => 1,
                                    p_init_msg_list    => OKC_API.G_FALSE,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => x_msg_count,
                                    x_msg_data         => x_msg_data,
                                    p_k_id             => p_terminate_in_parameters_rec.p_dnz_chr_id,
							 p_kl_id            => p_terminate_in_parameters_rec.p_cle_id,
							 p_kl_term_date     => p_terminate_in_parameters_rec.p_termination_date,
							 p_kl_term_reason   => p_terminate_in_parameters_rec.p_termination_reason,
	   						 p_k_number         => l_contract_number,
							 p_k_nbr_mod        => l_contract_modifier,
							 p_k_class          => l_cls_code,
							 p_k_subclass       => l_scs_code,
							 p_kl_status_code       => l_kl_sts_code,
							 p_estimated_amount => l_price_negotiated);

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

  END IF;

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
 --dbms_output.put_line(' terminate_cle (-) ');

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
END;

END;

/
