--------------------------------------------------------
--  DDL for Package Body OKC_RENEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RENEW_PVT" AS
/* $Header: OKCRRENB.pls 120.2 2006/08/02 17:58:30 skekkar noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--this is the default value for the renewal rule on lines
g_def_cle_ren varchar2(3):='FUL';

-- this g_cached_cle_id will help this program to remember which cle_id it had processed last time
-- when called from renew consolidation. This can help in saving the effort to build the
-- tree upwards for LRT rule when that rule is not defined on the line itself
g_cached_cle_id NUMBER := -100;
-- this g_cached_chr_id will help this program to remember which chr_id it had processed last time when
-- it was called. Thus if the same chr_id is called again as in renew consolidation, this
--will save the extra overhead of remaking the tables that are made of same values again and again
g_cached_chr_id NUMBER := OKC_API.G_MISS_NUM;


TYPE IdTab is table of okc_k_lines_b.id%type;
g_parent_id_tbl idTab;--used to cache in values of parents of a given line from renconsol
TYPE CLE_DATES_REC_TYPE IS RECORD(
	ID               NUMBER:=OKC_API.G_MISS_NUM,
	orig_start_date  DATE:=OKC_API.G_MISS_DATE,
	orig_end_date    DATE:=OKC_API.G_MISS_DATE,
	start_date       DATE:=OKC_API.G_MISS_DATE,
	end_date         DATE:=OKC_API.G_MISS_DATE
	);

--TYPE CLE_DATES_TBL_TYPE IS TABLE OF CLE_DATES_REC_TYPE
-- INDEX BY BINARY_INTEGER;

-- g_cle_dates_tbl CLE_DATES_TBL_TYPE;

CURSOR cur_time_values(p_chr_id number) is
      SELECT id,object_version_number,uom_code,duration,tve_id_started,tve_id_ended,
	 tve_id_limited,tve_type
	 FROM okc_timevalues
      WHERE DNZ_CHR_ID = p_chr_id;
tve_rec cur_time_values%rowtype;
TYPE time_tbl_type is table of cur_time_values%rowtype
INDEX BY BINARY_INTEGER;
g_time_tbl time_tbl_type;


CURSOR cur_rules(p_chr_id number) is
  SELECT nvl(rgp.cle_id,rgp.chr_id) comp_id  ,nvl(rul.rule_information1,g_def_cle_ren) rule_type
  FROM okc_rules_b rul,okc_rule_groups_b rgp
  WHERE    rgp.dnz_chr_id = p_chr_id
	 and   rgp.id=rul.rgp_id
--	 and   rgp.rgd_code='RENEW'
	 and   rul.rule_information_category='LRT' order by rgp.cle_id;

cursor cur_line(p_chr_id number) is
select id comp_id,nvl(line_renewal_type_code,g_def_cle_ren) rule_type
from okc_k_lines_b
where dnz_chr_id = p_chr_id;

cursor cur_headers(p_chr_id number) is
select application_id from okc_k_headers_b where id = p_chr_id;

p_appl_id1 number;
cur_lines_rec cur_line%rowtype;


 Type l_rules_tbl_type  is table of cur_rules%rowtype
 Index By Binary_Integer;
 g_rules_tbl   l_rules_tbl_type;

-- /striping/
p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

 --------------------------------------------------------------------------------------------
  -- Auto renew is a concurrent program initiated to renew the contracts automatically for
   -- which auto_renew_days is given
   --------------------------------------------------------------------------------------------
-- PROCEDURE Auto_Renew (errbuf out varchar2, retcode out varchar2) is
PROCEDURE Auto_Renew(errbuf out nocopy varchar2,
		     retcode out nocopy varchar2,
                     p_chr_id IN Number ,
                     p_duration IN Number ,
                     p_uom_code IN Varchar2 ,
		     p_renewal_called_from_ui    IN VARCHAR2 ,
                     p_contract_number IN Varchar2 ,
                     p_contract_number_modifier IN VARCHAR2
		     ) is
  CURSOR cur_auto_renew is
  SELECT k.id,k.contract_number,k.contract_number_modifier,k.start_date,k.END_date,k.object_version_number
    FROM okc_k_headers_b k,
         okc_statuses_b sts
   WHERE k.date_renewed is null
     and k.sts_code = sts.code
     and sts.ste_code in ('ACTIVE','EXPIRED','SIGNED')
     and k.date_terminated is null
     and k.template_yn = 'N'
     and k.id = p_chr_id ;
	-- bug 5017286
	--    or (p_chr_id is null
     --    and (k.END_date-k.auto_renew_days) <= trunc(sysdate)));

  --san rencol take out later p_auto_renew_rec renew_in_parameters_rec;
  p_auto_renew_rec okc_renew_pvt.renew_in_parameters_rec;

  l_api_name constant VARCHAR2(30) := 'Auto_Renew';
  l_return_status varchar2(1) := okc_api.g_ret_sts_success;
  l_chr_id   number;
  l_timeunit okx_units_of_measure_v.uom_code%type;
  l_duration number;
  l_contract_number okc_k_headers_b.contract_number%TYPE;
  l_msg_count Number;
  l_msg Varchar2(2000);

  x_return_status varchar2(1) := okc_api.g_ret_sts_success;
  x_msg_count number := okc_api.g_miss_num;
  x_msg_data varchar2(2000) := okc_api.g_miss_char;
  l_date Date := Sysdate;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('100: Entered Auto_Renew', 2);
    END IF;

 retcode := '0';
 fnd_msg_pub.initialize;
 /* FND_FILE.PUT_LINE( FND_FILE.LOG, 'Start Auto Renew');
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Id ' || to_char(p_chr_id));
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'timeunit ' || p_uom_code);
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'duration ' || to_char(p_duration)); */

 FOR auto_renew_rec IN cur_auto_renew
 LOOP
    l_contract_number := auto_renew_rec.contract_number;
    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Contract Number ' || l_contract_number);
    END IF;
    If p_chr_id Is Not Null Then
       l_duration := p_duration;
       l_timeunit := p_uom_code;
       l_return_status := OKC_API.G_RET_STS_SUCCESS;
    Else

       OKC_TIME_UTIL_PUB.get_duration(Auto_renew_rec.start_date,
						   auto_renew_rec.END_date,
						   l_duration,
						   l_timeunit,
						   l_return_status);

    End If;

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;

	    FND_MESSAGE.set_name('OKC','OKC_AUTO_RENEW_FAILURE');
         FND_MESSAGE.set_token('NUMBER',auto_renew_rec.contract_number);
         FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);

	    FND_MESSAGE.set_name('OKC','OKC_GET_DURATION_ERROR');
         FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;
 ELSE

 p_auto_renew_rec.p_contract_id           := auto_renew_rec.id;
 p_auto_renew_rec.p_orig_start_date       := auto_renew_rec.start_date;
 p_auto_renew_rec.p_orig_END_date         := auto_renew_rec.END_date;
 p_auto_renew_rec.p_start_date            := auto_renew_rec.END_date + 1;
 p_auto_renew_rec.p_uom_code              := l_timeunit;
 p_auto_renew_rec.p_duration              := l_duration;
 p_auto_renew_rec.p_new_contract_number   := Nvl(p_contract_number,auto_renew_rec.contract_number);
 p_auto_renew_rec.p_new_contract_modifier := Nvl(p_contract_number_modifier, fnd_profile.value('OKC_CONTRACT_IDENTIFIER')|| l_date || To_char(l_date,' HH24:MI:SS'));
 p_auto_renew_rec.p_object_version_number := auto_renew_rec.object_version_number;
 p_auto_renew_rec.p_contract_number       := auto_renew_rec.contract_number;
 p_auto_renew_rec.p_contract_modifier     := auto_renew_rec.contract_number_modifier;
 p_auto_renew_rec.p_perpetual_flag        := OKC_API.G_FALSE;

   -- FND_FILE.PUT_LINE( FND_FILE.LOG, 'Before Pre_Renew');
   IF (l_debug = 'Y') THEN
      okc_debug.log('300: Before Pre_Renew');
   END IF;
   OKC_RENEW_PUB.PRE_Renew(p_api_version   => 1,
                           p_init_msg_list => OKC_API.G_TRUE,
                           x_return_status => l_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_contract_id   => l_chr_id,
                           p_renew_in_parameters_rec => p_auto_renew_rec,
			   p_do_commit               => OKC_API.G_TRUE ,
			   p_renewal_called_from_ui => p_renewal_called_from_ui);
   IF (l_debug = 'Y') THEN
      okc_debug.log('400: After Pre_Renew');
   END IF;

       -- FND_FILE.PUT_LINE( FND_FILE.LOG, 'After Pre_Renew');
       -- FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_return_status ' || l_return_status)
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;

	 fnd_msg_pub.count_and_get(p_count => l_msg_count,
                  p_data  => l_msg);
      For I In 1..l_msg_count LOOP
	    l_msg := FND_MSG_PUB.Get(p_msg_index => i,
			  p_encoded  => 'F');
	    Fnd_File.Put_Line(FND_FILE.LOG, l_msg);

	 END LOOP;

         FND_MESSAGE.set_name('OKC','OKC_AUTO_RENEW_FAILURE');
         FND_MESSAGE.set_token('NUMBER',auto_renew_rec.contract_number);
         FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;
     ELSE
      FND_MESSAGE.set_name('OKC','OKC_AUTO_RENEW_SUCCESS');
      FND_MESSAGE.set_token('NUMBER',auto_renew_rec.contract_number);
      FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);
    END IF;

END IF;

END LOOP;

IF (l_debug = 'Y') THEN
   okc_debug.log('800:  Leaving Auto_Renew', 2);
   okc_debug.Reset_Indentation;
END IF;

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Exiting Auto_Renew:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

   retcode := '2';

   FND_MESSAGE.set_name('OKC','OKC_AUTO_RENEW_FAILURE');
   FND_MESSAGE.set_token('NUMBER',l_contract_number);
   FND_FILE.PUT_LINE( FND_FILE.LOG,FND_MESSAGE.GET);

 FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
   FND_FILE.PUT_LINE( FND_FILE.LOG,(FND_MSG_PUB.Get(I,p_encoded =>FND_API.G_FALSE )));
 END LOOP;

WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting Auto_Renew:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

   retcode := '2';
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
 FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
   FND_FILE.PUT_LINE( FND_FILE.LOG,(FND_MSG_PUB.Get(I,p_encoded =>FND_API.G_FALSE )));
 END LOOP;

END Auto_Renew;
--------------------------------------------------------------------------------------------
--called from launchpad, it runs through certain validations and returns  status
--------------------------------------------------------------------------------------------
FUNCTION is_renew_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS

/*p_sts_code is not being used right now as not sure if the refresh from launchpad
  will take place everytime a change happens to a contract or not. That is
  If the status of the contract showing in launchpad would at all times be in sync
  with database.It might not happen due to performance reasons of launchpad. So the current approach.
  But if this sync is assured then  we could use p_sts_code as well*/

    l_status VARCHAR2(100) := '1';
    l_cls_code VARCHAR2(100);
    l_template_yn VARCHAR2(10);
    l_code VARCHAR2(100);
    l_app_id okc_k_headers_b.application_id%TYPE;
    l_scs_code okc_k_headers_b.scs_code%TYPE;
    --l_k okc_k_headers_b.contract_number%TYPE;
    l_k VARCHAR2(255);
    l_mod okc_k_headers_b.contract_number_modifier%TYPE ;
    l_end_date okc_k_headers_b.end_date%TYPE;
    l_date_terminated okc_k_headers_b.date_terminated%TYPE;
    l_start_date    okc_k_headers_b.start_date%TYPE;
    x_msg_count     number;
    x_msg_data      VARCHAR2(3000);
    l_rnrl_rec                    OKS_RENEW_UTIL_PVT.RNRL_REC_TYPE;
    x_rnrl_rec                    OKS_RENEW_UTIL_PVT.RNRL_REC_TYPE;


    l_api_name Varchar2(30) := 'is_renew_allowed';
    l_return_status              Varchar2(1);

    CURSOR c_chr IS
    SELECT sts_code,template_yn, application_id, scs_code,contract_number,
		 contract_number_modifier,end_date,date_terminated, start_date
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR cur_status(p_code IN VARCHAR2) IS
    SELECT ste_code
    FROM   okc_statuses_v
    WHERE  code = p_code;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('900: Entered is_renew_allowed', 2);
    END IF;

    OPEN c_chr;
    FETCH c_chr INTO l_code,l_template_yn,l_app_id,l_scs_code,l_k,l_mod,
                     l_end_date,l_date_terminated, l_start_date;
    CLOSE c_chr;

    IF (l_mod is not null) and (l_mod <> OKC_API.G_MISS_CHAR) then
	   l_k := l_k ||'-'||l_mod;
    END IF;

    IF l_template_yn = 'Y' then
       IF (l_debug = 'Y') THEN
          okc_debug.log('1000: Templates non-renewable !!');
       END IF;
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => 'OKC_K_TEMPLATE',
                           p_token1        => 'NUMBER',
                           p_token1_value  => l_k);

       IF (l_debug = 'Y') THEN
          okc_debug.log('1010: Leaving is_renew_allowed ', 2);
          okc_debug.Reset_Indentation;
       END IF;
	 RETURN(FALSE);
    END IF;

    -- A perpetual cannot be renewed further !!
    IF l_end_date Is Null then
       IF (l_debug = 'Y') THEN
          okc_debug.log('1011: Perpetual Contracts non-renewable !!');
       END IF;
       OKC_API.set_message(p_app_name      => g_app_name,
				       p_msg_name      => 'OKC_NO_PERPETUAL',
					  p_token1        => 'component',
					  p_token1_value  => l_k);
       IF (l_debug = 'Y') THEN
          okc_debug.log('1012: Leaving is_renew_allowed ', 2);
          okc_debug.Reset_Indentation;
       END IF;
    	  RETURN(FALSE);
    END IF;

    Open cur_status(l_code);
    Fetch cur_status into l_status;
    close cur_status;

    --Bug 3431436 Future terminated contracts are non-renewable
    IF (l_status in ('ACTIVE','EXPIRED','SIGNED') and l_date_terminated is not null)then
       IF (l_debug = 'Y') THEN
          okc_debug.log('1013: Future Terminated Contracts non-renewable !!');
       END IF;
       OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_FUTURE_TERMINATED_K',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_k );
       IF (l_debug = 'Y') THEN
          okc_debug.log('1014: Leaving is_renew_allowed ', 2);
          okc_debug.Reset_Indentation;
       END IF;
       return(false);
    END IF;

    If okc_util.Get_All_K_Access_Level(p_application_id => l_app_id,
                                       p_chr_id => p_chr_id,
                                       p_scs_code => l_scs_code) <> 'U' Then
       IF (l_debug = 'Y') THEN
          okc_debug.log('1015: Secured Contracts non-renewable !!');
       END IF;
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => 'OKC_NO_UPDATE',
                           p_token1        => 'CHR',
                           p_token1_value  => l_k);
       IF (l_debug = 'Y') THEN
          okc_debug.log('1016: Leaving is_renew_allowed ', 2);
          okc_debug.Reset_Indentation;
       END IF;
      Return(FALSE);
    End If;

    --OPEN c_sts(l_code);
    --FETCH c_sts INTO l_sts_code;
    --CLOSE c_sts;

    -- commenting for Bug 3118707
    --  IF l_sts_code IN ('ACTIVE','EXPIRED','SIGNED') then
    --okc_debug.log('1017: Leaving is_renew_allowed ', 2);
    --okc_debug.Reset_Indentation;
    --      return(TRUE);


	-- invoke OKS procedure to check renew eligibility for service class
	If l_scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION') THEN
        OKS_RENEW_UTIL_PUB.GET_RENEW_RULES (
                                  p_api_version      =>    1.0,
                                  p_init_msg_list    =>    OKC_API.G_FALSE,
                                  x_return_status    =>    l_return_status,
                                  x_msg_count        =>    x_msg_count,
                                  x_msg_data        =>    x_msg_data,
                                  P_Chr_Id          =>    p_chr_id,
                                  P_PARTY_ID        =>    NULL,
                                  P_ORG_ID          =>    NULL,
                                  P_Date            =>   l_start_date,
                                  P_RNRL_Rec        =>    l_rnrl_rec,
                                  X_RNRL_Rec        =>    x_rnrl_rec
                                          );
        IF x_rnrl_rec.renewal_type = 'DNR' THEN
                OKC_API.set_message(
                        G_APP_NAME,
                        G_DNR_MSG);
                okc_debug.log('1000: Leaving is_renew_allowed ', 2);
                okc_debug.Reset_Indentation;
                return(FALSE);
        End If;
        IF (OKC_OKS_PUB.Is_Renew_Allowed(p_chr_id => p_chr_id,
                                         x_return_status => l_return_status)) Then
		  IF (l_debug = 'Y') THEN
                okc_debug.log('1018: Leaving is_renew_allowed ', 2);
                okc_debug.Reset_Indentation;
	       END IF;
            return(TRUE);
        ELSE
            -- Bug 3280617
            /*OKC_API.set_message(p_app_name      => g_app_name,
                                p_msg_name      => 'OKC_INVALID_STS',
                                p_token1        => 'component',
                                p_token1_value  => l_k);*/

            IF (l_debug = 'Y') THEN
                okc_debug.log('1000: Leaving is_renew_allowed ', 2);
                okc_debug.Reset_Indentation;
            END IF;
            return(FALSE);
        END IF;

    End If;

  RETURN (TRUE);

END is_renew_allowed;

PROCEDURE VALIDATE(p_api_version             IN  NUMBER,
       	           p_init_msg_list           IN  VARCHAR2 ,
                   x_return_status           OUT NOCOPY VARCHAR2,
                   x_msg_count               OUT NOCOPY NUMBER,
                   x_msg_data                OUT NOCOPY VARCHAR2,
	           p_renew_in_parameters_rec IN  Renew_in_parameters_rec,
		   p_renewal_called_from_ui    IN VARCHAR2  /* Added for bugfix 2093117 */
		  ) is

    CURSOR cur_k_header is
    SELECT ID,
	   STS_CODE,
	   CONTRACT_NUMBER,
	   CONTRACT_NUMBER_MODIFIER,
	   TEMPLATE_YN,
	   DATE_TERMINATED,
	   DATE_RENEWED,
	   END_DATE
      FROM okc_k_headers_b
     WHERE id = p_renew_in_parameters_rec.p_contract_id;

   CURSOR cur_status(p_sts_code varchar2) is
   SELECT ste_code,meaning
     FROM okc_statuses_v
    WHERE code = p_sts_code;

    CURSOR cur_uom is
    SELECT 'x'
      FROM okc_time_code_units_b
     WHERE uom_code = p_renew_in_parameters_rec.p_uom_code;

  -- Cursor to check if a Quote is cerated for renewal of
  -- contract.

/*
  Commented out nocopy as per Bug#1938017 as renewal of contract from quote is desupported from 11.5.6
  CURSOR cur_qte(p_chr_id number) IS
  SELECT qte.quote_number
  FROM okc_k_rel_objs_v rel,
	  aso_quote_headers_all_v qte
  WHERE jtot_object1_code = okc_oc_int_qtk_pvt.g_jtot_qte_hdr
  AND   chr_id            = p_chr_id
  AND   rty_code          = okc_oc_int_qtk_pvt.g_k2q_ren
  AND   rel.object1_id1   = qte.quote_header_id;
*/

 l_status  varchar2(30):='1';
 l_meaning okc_statuses_v.meaning%TYPE;
 l_dummy  varchar2(1);
 k_header_rec  cur_k_header%rowtype;
-- qte_rec    cur_qte%rowtype;
 l_api_name Varchar2(30) := 'Validate';
 l_msg_name Varchar2(1);

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('1400: Entered VALIDATE', 2);
    END IF;

   okc_api.init_msg_list(p_init_msg_list);

   x_return_status := okc_api.g_ret_sts_success;

  If p_renew_in_parameters_rec.p_perpetual_flag = OKC_API.G_FALSE OR
     p_renew_in_parameters_rec.p_perpetual_flag IS NULL
  Then
  if ( p_renew_in_parameters_rec.p_END_date is null
      and
 	   (
          p_renew_in_parameters_rec.p_uom_code is null
	     or
          p_renew_in_parameters_rec.p_duration is null
        )
	 )
 then

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_PARAMETERS');

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RAISE g_exception_halt_validation;
 END if;
 END IF; -- End perpetual_flag = OKC_API.G_FALSE

  if ( p_renew_in_parameters_rec.p_start_date is not null and
	  p_renew_in_parameters_rec.p_orig_end_date is  not null ) then
     if ( p_renew_in_parameters_rec.p_start_date <= p_renew_in_parameters_rec.p_orig_end_date) then

             OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_NEW_START_MORE_END');

             x_return_status := OKC_API.G_RET_STS_ERROR;
             RAISE g_exception_halt_validation;
	  END IF;
 END if;

 if p_renew_in_PARAMETERs_rec.p_uom_code is not null then

  open cur_uom;
  fetch cur_uom into l_dummy;

  if cur_uom%notfound then

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_INVALID_UOM',
                            p_token1        => 'UOM_CODE',
                            p_token1_value  => p_renew_in_parameters_rec.p_uom_code);

        x_return_status := OKC_API.G_RET_STS_ERROR;
	   close cur_uom;
        RAISE g_exception_halt_validation;
   END if;

  close cur_uom;

 END if;

  open cur_k_header;
  fetch cur_k_header into k_header_rec;

  if cur_k_header%notfound then  -- contract header_id is wrong

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_K_HEADER_NOT_FOUND',
					   p_token1        => 'NUMBER',
                            p_token1_value  => p_renew_in_parameters_rec.p_contract_number);

        x_return_status := OKC_API.G_RET_STS_ERROR;
	   close cur_k_header;
        RAISE g_exception_halt_validation;

   END if;

  close cur_k_header;

    -- A perpetual cannot be renewed further !!
    IF k_header_rec.end_date Is Null then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_NO_PERPETUAL',
                          p_token1        => 'component',
                          p_token1_value  => p_renew_in_parameters_rec.p_contract_number);
        x_return_status := okc_api.g_ret_sts_error;
        RAISE g_exception_halt_validation;
    END IF;

  If k_header_rec.template_Yn = 'Y' then

        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => 'OKC_K_TEMPLATE',
                            p_token1        => 'NUMBER',
                            p_token1_value  => p_renew_in_parameters_rec.p_contract_number);

        x_return_status := okc_api.g_ret_sts_error;
        RAISE g_exception_halt_validation;

   END if;

   open cur_status(k_header_rec.sts_code);
   fetch cur_status into l_status,l_meaning;
   close cur_status;

   IF l_status='1' then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_K_STATUS',
                          p_token1        => 'NUMBER',
                          p_token1_value  => k_header_rec.contract_number,
			  p_token2        => 'MODIFIER',
                          p_token2_value  => k_header_rec.contract_number_modifier,
			  p_token3        => 'STATUS',
                          p_token3_value  => k_header_rec.sts_code);
      RAISE g_exception_halt_validation;
   END IF;

   IF l_status NOT IN ('ACTIVE','EXPIRED','SIGNED') then
     x_return_status := OKC_API.G_RET_STS_ERROR;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_INVALID_K_STATUS',
                          p_token1        => 'NUMBER',
                          p_token1_value  => k_header_rec.contract_number,
			  p_token2        => 'MODIFIER',
                          p_token2_value  => k_header_rec.contract_number_modifier,
			  p_token3        => 'STATUS',
                          p_token3_value  => l_meaning);

        RAISE g_exception_halt_validation;
   ELSIF k_header_rec.date_terminated is not null then
     x_return_status := OKC_API.G_RET_STS_ERROR;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_FUTURE_TERMINATED_K',
                          p_token1        => 'NUMBER',
                          p_token1_value  => k_header_rec.contract_number );

        RAISE g_exception_halt_validation;

   /* Modified the following logic for bugfix 2093117 */

   ELSIF (( k_header_rec.date_renewed is not null) OR (p_renewal_called_from_ui = 'N' )) THEN
       --Bug 3560988 Passing p_renewal_called_from_ui to the is_already_not_renewed function
       IF (is_already_not_renewed(k_header_rec.id,k_header_rec.contract_number, l_msg_name, p_renewal_called_from_ui) = OKC_API.G_FALSE) THEN
          x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
   END IF;
   /* added for bug 3005039 */
   if p_renewal_called_from_UI = 'N' then
	 IF (validate_line(p_renew_in_parameters_rec.p_contract_id) = OKC_API.G_FALSE) THEN
	  x_return_status := OKC_API.G_RET_STS_ERROR;
	  end if;
  end if;
  /* added for bug 3005039  */
/*
  Commented out nocopy as per Bug#1938017 as renewal of contract from quote is desupported from 11.5.6
   -- For on-line renewals check if a quote is created for contract
   -- renewal.  If a quote is created, then only the quote should be
   -- used to renew the contract.
   -- Also make sure to prevent creation of another Quote( for renewal) if
   -- one already exists.
   --
   IF ( p_renew_in_parameters_rec.p_context = OKC_API.G_MISS_CHAR
	   OR
	   p_renew_in_parameters_rec.p_context IS NULL
      OR
      p_renew_in_parameters_rec.p_context = okc_oc_int_qtk_pvt.g_k2q_ren ) THEN

	 -- on-line renewal / duplicate quote renewal case

	 OPEN cur_qte(k_header_rec.id);
	 FETCH cur_qte INTO qte_rec;

	 IF cur_qte%FOUND THEN
	 --
	 -- i.e Found a quote that should be used for renewal of
	 -- contract. So do not allow on-line renewal

         OKC_API.set_message( p_app_name      => g_app_name,
                          p_msg_name      =>'OKC_RENEWAL_QUOTE',
                          p_token1        => 'QUOTE',
                          p_token1_value  => qte_rec.quote_number,
                          p_token2        =>'NUMBER',
                          p_token2_value  => k_header_rec.contract_number );

         x_return_status := OKC_API.G_RET_STS_ERROR;
         CLOSE cur_qte;
	    RAISE g_exception_halt_validation;

      END IF; -- End cur_qte%FOUND

	 CLOSE cur_qte;
   END IF; -- end p_context = G_miss_char
 */

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500:  Leaving VALIDATE', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Exiting VALIDATE:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.Reset_Indentation;
 END IF;

 -- NULL;
WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Exiting VALIDATE:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE;

FUNCTION VALIDATE_LINE(p_contract_id IN NUMBER) RETURN VARCHAR2
IS
   CURSOR cur_k_lines is
            SELECT ID
                    FROM okc_k_lines_b l, okc_statuses_b sts
                    WHERE sts.code = l.sts_code
                    and sts.ste_code in ('ACTIVE','EXPIRED','SIGNED')
                    and l.dnz_chr_id = p_contract_id
                   and l.date_renewed is null
                   and l.date_terminated is null;

 k_lines_rec cur_k_lines%rowtype;
 l_return_flag varchar2(1) := OKC_API.G_TRUE;
BEGIN
  open cur_k_lines;
  fetch cur_k_lines into k_lines_rec;
  if cur_k_lines%notfound then
     OKC_API.set_message(p_app_name => g_app_name,
          		   p_msg_name => 'OKC_LINES_SUBLINES_TERMINATED');
     close cur_k_lines;
     RETURN(OKC_API.G_FALSE);
  END IF;

  -- Bug 3584224 Invoking validate_oks_lines to check if all the sublines have been terminated.
  l_return_flag := OKC_OKS_PUB.VALIDATE_OKS_LINES(p_contract_id);
  return l_return_flag;

END VALIDATE_LINE;


--updates the dates and timevalues in all the rules for the renew copy
/*
 * bug 5438257
 *  stubbed
*/
PROCEDURE update_rules(
                 p_api_version                  IN  NUMBER,
                 p_init_msg_list                IN  VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
                 p_chr_id                       IN  number
                 )  is
BEGIN
 NULL;
END update_rules;
/*
 * bug 5438257
PROCEDURE update_rules(
                 p_api_version                  IN  NUMBER,
       	       p_init_msg_list                IN  VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_chr_id                       IN  number
			  )  is


CURSOR cur_rules(p_chr_id number) is
     SELECT nvl(rg.cle_id,rg.chr_id) parent_ID,ru.id id,ru.object_version_number,
		   ru.comments,ru.rule_information_category from
	okc_rules_v ru,okc_rule_groups_b rg
     WHERE  rgp_id=rg.id and rg.DNZ_CHR_ID = p_chr_id for update of ru.id nowait;

CURSOR cur_ia(p_tve_id number) is
     SELECT start_date ,end_date FROM okc_time_ia_startend_val_v
     WHERE id = p_tve_id for update of id nowait;

l_col_vals   OKC_TIME_UTIL_PUB.T_COL_VALS;
tmp_rulv_rec OKC_RULE_PUB.rulv_rec_type;
l_no_of_cols number;

E_Resource_Busy               EXCEPTION;
PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;

l_api_name constant varchar2(30) := 'update_rules';
l_string varchar2(2000);
l_uom_code okx_units_of_measure_v.uom_code%type;
l_duration number;
l_new_date date;
-- The following data types are included for rule comments

j number;

l_tve_id number;

l_cle_dates_rec   cle_dates_rec_type;


Function get_date_rec(p_id number) Return cle_dates_rec_type is
    l_rec cle_dates_rec_type;
    i BINARY_INTEGER;
    l_api_name Varchar2(30) := 'get_date_rec';

    CURSOR c_get_date_rec(b_id IN NUMBER) IS
    SELECT id, orig_start_date, orig_end_date, start_date, end_date
    FROM   okc_cle_dates_tmp
    WHERE  id = b_id;
--    AND    chr_or_cle='CLE'; -- need to check if this is needed.

  Begin

    -- okc_debug.Set_Indentation('get_date_rec');
    -- okc_debug.log('1800: Entered get_date_rec', 2);

     l_rec.id:=OKC_API.G_MISS_NUM;

     OPEN  c_get_date_rec(p_id);
     FETCH c_get_date_rec INTO l_rec;
     CLOSE c_get_date_rec;

     RETURN l_rec;

 END;


Function get_tve_rec(p_tve_id number) Return cur_time_values%rowtype is
    l_rec cur_time_values%rowtype;
    i BINARY_INTEGER;
    l_api_name Varchar2(30) := 'get_tve_rec';
  Begin

    -- okc_debug.Set_Indentation('get_tve_rec');
    -- okc_debug.log('2000: Entered get_tve_rec', 2);

	 l_rec.id:=OKC_API.G_MISS_NUM;
	 If g_time_tbl.count >0 then
	   i:=g_time_tbl.first;
	   LOOP
		If g_time_tbl(i).id=p_tve_id then
                   -- okc_debug.log('2100: Exiting get_tve_rec', 2);

                   return g_time_tbl(i);
          END IF;
		Exit when i=g_time_tbl.last;
		i:=g_time_tbl.next(i);
       END LOOP;
     END IF;

-- okc_debug.log('1860: Leaving  Function Get_TVE_Rec ', 2);
-- okc_debug.Reset_Indentation;

     return l_rec;
 END;

FUNCTION check_ia(p_tve_id number,p_obj_no number , p_rule_rec cur_rules%rowtype , p_date_rec cle_dates_rec_type)
	    Return varchar2 is
 l_return_status varchar2(1):=OKC_API.G_RET_STS_SUCCESS;
 l_tve_start date :=OKC_API.G_MISS_DATE;
 l_tve_end   date :=OKC_API.G_MISS_DATE;
 l_isev_ext_rec_type  OKC_TIME_PUB.isev_ext_rec_type;
 i_isev_ext_rec_type  OKC_TIME_PUB.isev_ext_rec_type;
 i_rulv_rec   OKC_RULE_PUB.rulv_rec_type;
 l_rulv_rec   OKC_RULE_PUB.rulv_rec_type;
 l_exception_stop exception;
 l_orig_start_date date :=OKC_API.G_MISS_DATE;
 l_orig_end_date date :=OKC_API.G_MISS_DATE;
 l_new_start_date date :=OKC_API.G_MISS_DATE;
 l_new_end_date   date :=OKC_API.G_MISS_DATE;
 l_api_name Varchar2(30) := 'check_ia';
 BEGIN

    -- okc_debug.Set_Indentation('check_ia');
    -- okc_debug.log('2200: Entered check_ia', 2);

    --get dates
    l_orig_start_date:=p_date_rec.orig_start_date;
    l_orig_end_date:=p_date_rec.orig_end_date;
    l_new_start_date:=p_date_rec.start_date;
    l_new_end_date:=p_date_rec.end_date;

    open cur_ia(p_tve_id);
    Fetch cur_ia into l_tve_start,l_tve_end;
    close cur_ia;
    If l_tve_start <>OKC_API.G_MISS_DATE and l_tve_end <>OKC_API.G_MISS_DATE then
                if l_tve_start = l_orig_start_date and l_tve_end = l_orig_end_date then
				l_isev_ext_rec_type.id:=p_tve_id;
				l_isev_ext_rec_type.object_version_number:=p_obj_no;
				l_isev_ext_rec_type.start_date:=l_new_start_date;
				l_isev_ext_rec_type.end_date:=l_new_end_date;
                	--san comment update the ia
                     -- okc_debug.log('2300: Before update_ia_startend');
				 OKC_TIME_PUB.UPDATE_IA_STARTEND(
					p_api_version=> p_api_version,
				     p_init_msg_list=> okc_api.g_false,
				     x_return_status=> l_return_status,
				     x_msg_count=>    x_msg_count,
				     x_msg_data=>     x_msg_data,
					p_isev_ext_rec=> l_isev_ext_rec_type,
				     x_isev_ext_rec=> i_isev_ext_rec_type) ;
                      -- okc_debug.log('2400: After update_ia_startend');
                      IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
					 RAISE l_exception_stop;
                      END IF;

                      l_rulv_rec.id := p_rule_rec.id;
                      l_rulv_rec.object_version_number := p_rule_rec.object_version_number;
	                 l_rulv_rec.comments := replace(p_rule_rec.comments,
						  to_char(l_orig_start_date,'DD-MM-YYYY HH24:MI:SS'),
						  to_char(l_new_start_date,'DD-MM-YYYY HH24:MI:SS'));
	                 l_rulv_rec.comments := replace(l_rulv_rec.comments,
						  to_char(l_orig_end_date,'DD-MM-YYYY HH24:MI:SS'),
						  to_char(l_new_end_date,'DD-MM-YYYY HH24:MI:SS'));
                      -- okc_debug.log('2500: Before update_rule');
	                 OKC_RULE_PUB.UPDATE_RULE(  p_api_version     	=> 1,
                                                 p_init_msg_list   	=> OKC_API.G_FALSE,
                                                 x_return_status   	=> l_return_status,
                                                 x_msg_count       	=> x_msg_count,
                                                 x_msg_data        	=> x_msg_data,
                                                 p_rulv_rec           => l_rulv_rec,
                                                 x_rulv_rec           => i_rulv_rec
                                             );
                      -- okc_debug.log('2600: After update_rule');
                      IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
					 RAISE l_exception_stop;
                      END IF;
                 else
                  --san comment disable the rule;
                   null;
                end if;
    END IF;

    -- okc_debug.log('2700:  Leaving check_ia', 2);
    -- okc_debug.Reset_Indentation;

    return l_return_status;

 EXCEPTION
  WHEN l_exception_stop then

    -- okc_debug.log('2800: Exiting check_ia:l_exception_stop Exception', 2);
    -- okc_debug.Reset_Indentation;

	   return l_return_status;
  when others then

    -- okc_debug.log('2900: Exiting check_ia:others Exception', 2);
    -- okc_debug.Reset_Indentation;

   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

   return (l_return_status);

 END check_ia;
BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Update_Rules');
       okc_debug.log('3000: Entered Update_Rules', 2);
    END IF;

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
  j := 1;

  --store the current time values in g_time_tbl again if current chr id is different from the
  --one that called this program last time.
  IF g_cached_chr_id <> p_chr_id then
     FOR time_rec in cur_time_values(p_chr_id) loop
        g_time_tbl(J) := time_rec;
        j := j + 1;
     END loop;
  END IF;

--for all the rules defined for the contract
 IF (l_debug = 'Y') THEN
    okc_debug.log('3100: Before cur_rules Cursor');
 END IF;
 FOR rule_rec in cur_rules(p_chr_id) loop
       IF (l_debug = 'Y') THEN
          okc_debug.set_trace_off;
         okc_debug.log('3200: Before get_date_rec');
       END IF;
	l_cle_dates_rec:=get_date_rec(rule_rec.parent_id);
     -- okc_debug.log('3300: After get_date_rec');
	IF l_cle_dates_rec.id <> OKC_API.G_MISS_NUM then

         okc_renew_pvt.g_rulv_rec.id := rule_rec.id;
         okc_renew_pvt.g_rulv_rec.object_version_number := rule_rec.object_version_number;

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(rule_rec.rule_information_category);
p_dff_name := okc_rld_pvt.get_dff_name(rule_rec.rule_information_category);

         -- okc_debug.log('3400: Before get_dff_column_values');
--	    okc_time_util_pub.get_dff_column_values( p_app_id => 510,     -- /striping/
	    okc_time_util_pub.get_dff_column_values( p_app_id => p_appl_id,
--                                              p_dff_name => 'OKC Rule Developer DF',   -- /striping/
                                              p_dff_name => p_dff_name,
                                              p_rdf_code => rule_rec.rule_information_category,
                                              p_fvs_name => 'FND_STANDARD_DATE',
                                              p_rule_id  => rule_rec.id,
                                              p_col_vals => l_col_vals,
                                              p_no_of_cols => l_no_of_cols );
            IF (l_debug = 'Y') THEN
               okc_debug.set_trace_off;
            END IF;
         -- okc_debug.log('3500: After get_dff_column_values');

          if nvl(l_no_of_cols,0) >= 1 then

           --san comment disable the rule here later
              null;
          end if; --  the rule has absolute dates

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(rule_rec.rule_information_category);
p_dff_name := okc_rld_pvt.get_dff_name(rule_rec.rule_information_category);

         -- okc_debug.log('3600: Before get_dff_column_values');
--         okc_time_util_pub.get_dff_column_values( p_app_id => 510,    -- /striping/
         okc_time_util_pub.get_dff_column_values( p_app_id => p_appl_id,
--                                              p_dff_name => 'OKC Rule Developer DF',    -- /striping/
                                              p_dff_name => p_dff_name,
                                              p_rdf_code => rule_rec.rule_information_category,
                                              p_fvs_name => 'OKC_TIMEVALUES',
                                              p_rule_id  => rule_rec.id,
                                              p_col_vals => l_col_vals,
                                              p_no_of_cols => l_no_of_cols );
          IF (l_debug = 'Y') THEN
             okc_debug.set_trace_off;
          END IF;
         -- okc_debug.log('3700: After get_dff_column_values');
           if nvl(l_no_of_cols,0) >= 1 then

         -- Implies that there are some rule attribute categories for the rule which have time values
        -- okc_debug.log('3800: Before For Loop');
        for i in l_col_vals.first..l_col_vals.last
        loop
          if l_col_vals.exists(i) then
	        tve_rec:=get_tve_rec(l_col_vals(i).col_value);
	        IF tve_rec.id <> OKC_API.G_MISS_NUM then
			 -- in the below type checks we are not checking for effectivity limits on cover times
			 --and react_intervals as they are always bound by the effectivity of lines
			 -- to which they are attached in OKS. But in case this changes, then check and
			 -- adjust the rules and tve_id's effectivities in these tables as well
	           If tve_rec.tve_type = 'TAV' then
		    --san comment later disable the rule;
		    null;
                ELSIF tve_rec.tve_type = 'ISE' then --ise
                     --fetch the dates
			         x_return_status:=check_ia(tve_rec.id,tve_rec.object_version_number,rule_rec,l_cle_dates_rec);
	                   IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                        END IF;
                ELSIF tve_rec.tve_id_limited is not null then
				  --this means that there is some effectivity specified on this time value
	                tve_rec:=get_tve_rec(tve_rec.tve_id_limited);
                     --fetch the dates
			        x_return_status:=check_ia(tve_rec.id,tve_rec.object_version_number,rule_rec,l_cle_dates_rec);
	                  IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                       END IF;
		      END IF; --tve_type
              END IF; -- tve_rec is OKC_API.G_MISS_NUM
            END IF; -- if col_vals exists
          END loop;
          -- okc_debug.log('3900: After For Loop');
        END IF; -- if col_vals>=1
        -- okc_debug.log('4000: After EndIf');
      END IF; -- id not found in dates_rec table
      -- okc_debug.log('41000: After EndIf');
  END loop;
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_on;
     okc_debug.log('4200: After cur_rules Cursor');
  END IF;
  --reset the dates table
--  g_cle_dates_tbl.delete;

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4300:  Leaving Update_Rules', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
WHEN E_Resource_Busy THEN
    IF (l_debug = 'Y') THEN
       okc_debug.set_trace_on;
       okc_debug.log('4400: Exiting Update_Rules:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;


     IF (cur_time_values%ISOPEN) THEN
        CLOSE cur_time_values;
     END IF;
     x_return_status := okc_api.g_ret_sts_error;
     OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);

     RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;

WHEN OKC_API.G_EXCEPTION_ERROR THEN
     IF (l_debug = 'Y') THEN
        okc_debug.set_trace_on;
       okc_debug.log('4500: Exiting Update_Rules:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('4600: Exiting Update_Rules:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('4700: Exiting Update_Rules:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
     END IF;

  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');


END Update_Rules;
*/

PROCEDURE update_condition_headers (
                 p_api_version                  IN  NUMBER,
       	       p_init_msg_list                IN  VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_chr_id                       IN  NUMBER,
                 p_orig_start_date              IN  DATE,
                 p_orig_end_date                IN  DATE,
                 p_new_start_date               IN  DATE,
                 p_new_end_date                 IN  DATE ) is

 CURSOR cur_condition_headers is
 SELECT cnh.id,cnh.object_version_number,cnh.date_active,cnh.date_inactive
 FROM okc_condition_headers_b cnh
 WHERE dnz_chr_id = p_chr_id;


 l_cnh_rec  okc_conditions_pub.cnhv_rec_type;
 i_cnh_rec  okc_conditions_pub.cnhv_rec_type;

 E_Resource_Busy               EXCEPTION;
 PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_api_name constant varchar2(30) := 'update_headers';
 l_duration number;
 l_uom_code okx_units_of_measure_v.uom_code%type;
BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('4800: Entered update_condition_headers', 2);
    END IF;

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

 IF (l_debug = 'Y') THEN
    okc_debug.log('4900: Before cur_condition_headers Cursor');
 END IF;
 FOR conditions_rec in cur_condition_headers loop

  l_cnh_rec.id := conditions_rec.id;
  l_cnh_rec.object_version_number := conditions_rec.object_version_number;

  l_cnh_rec.date_active := p_new_start_date;
  l_cnh_rec.date_inactive := null;

  If conditions_rec.date_inactive is not null then
             If conditions_rec.date_inactive = p_orig_end_date AND
					 conditions_rec.date_active = p_orig_start_date then

                     l_cnh_rec.date_inactive := p_new_end_date;

             ELSE
                     l_cnh_rec.date_inactive := p_new_start_date;

             END IF;
  ELSE
	    IF  conditions_rec.date_active <> p_orig_start_date then
	                l_cnh_rec.date_inactive := p_new_start_date;

         END IF;

  END if;


      IF (l_debug = 'Y') THEN
         okc_debug.log('5000: Before update_cond_hdrs');
      END IF;
       okc_conditions_pub.update_cond_hdrs(
	              p_api_version   => 1,
	              p_init_msg_list => OKC_API.G_FALSE,
	              x_return_status => l_return_status,
	              x_msg_count     => x_msg_count,
	              x_msg_data      => x_msg_data,
	              p_cnhv_rec      => l_cnh_rec,
	              x_cnhv_rec      => i_cnh_rec  );
      IF (l_debug = 'Y') THEN
         okc_debug.log('5100: After update_cond_hdrs');
      END IF;

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

 END loop;

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log(' 5200:  Leaving update_condition_headers', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Exiting update_condition_headers:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;


   x_return_status := okc_api.g_ret_sts_error;
   OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);

   RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;

WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5400: Exiting update_condition_headers:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('5500: Exiting update_condition_headers:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('5600: Exiting update_condition_headers:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');


END update_condition_headers;

PROCEDURE update_old_contract(
                 p_api_version                  IN NUMBER,
       	       p_init_msg_list                IN VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_new_header                   IN  number,
	            p_chr_id                       IN  number) is

 CURSOR cur_header(p_chr_id number) is
 SELECT id,object_version_number
 FROM okc_k_headers_b
 WHERE id = p_chr_id;

 CURSOR cur_lines(p_chr_id number) is
 SELECT a.id,b.id cle_id_ren_to ,a.object_version_number
 FROM okc_k_lines_b a,okc_k_lines_b b
 WHERE a.dnz_chr_id = p_chr_id and a.id=b.cle_id_renewed and b.dnz_chr_id=p_new_header;

 TYPE objTab is table of okc_k_lines_b.object_version_number%type;

 l_id_tbl idTab;
 l_obj_tbl objtab;
 l_ren_id_tbl idTab;

 header_rec cur_header%rowtype;

 l_chr_rec  okc_contract_pub.chrv_rec_type;
 i_chr_rec  okc_contract_pub.chrv_rec_type;

 l_cle_tbl  okc_contract_pub.clev_tbl_type;
 x_cle_tbl  okc_contract_pub.clev_tbl_type;
 i number;

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_api_name constant VARCHAR2(30) := 'update_old_contract';
 l_date  DATE := trunc(sysdate);
BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('5700: Entered update_old_contract', 2);
    END IF;

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

  open cur_header(p_chr_id);
  fetch cur_header into header_rec;
  close cur_header;

  l_chr_rec.id := header_rec.id;
  l_chr_rec.object_version_number := header_rec.object_version_number;
  l_chr_rec.date_renewed := l_date;
  --san rencol

    IF (l_debug = 'Y') THEN
       okc_debug.log('5800: Before lock_contract_header');
    END IF;
    okc_contract_pub.lock_contract_header(
              p_api_version => 1,
	         p_init_msg_list => OKC_API.G_FALSE,
	         x_return_status => l_return_status,
	         x_msg_count => x_msg_count,
	         x_msg_data => x_msg_data,
	         p_chrv_rec => l_chr_rec );
    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: After lock_contract_header');
    END IF;

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

	  IF (l_debug = 'Y') THEN
   	  okc_debug.log('6000: Before update_contract_header');
	  END IF;
	  okc_contract_pub.update_contract_header (
	      p_api_version => 1,
	      p_init_msg_list => OKC_API.G_FALSE,
	      x_return_status => l_return_status,
	      x_msg_count => x_msg_count,
	      x_msg_data => x_msg_data,
		 p_restricted_update => okc_api.g_true,
	      p_chrv_rec => l_chr_rec,
	      x_chrv_rec => i_chr_rec  );
	  IF (l_debug = 'Y') THEN
   	  okc_debug.log('6100: After update_contract_header');
	  END IF;

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

--san rencol
     SELECT l.id,l.object_version_number
	bulk collect into l_id_tbl,l_obj_tbl
     FROM okc_k_lines_b l, okc_operation_lines a
     where a.object_chr_id=p_chr_id and
		 a.subject_chr_id=p_new_header and
		a.active_yn='Y'
		and l.id=a.object_cle_id and
		a.subject_cle_id is not null and a.object_cle_id is not null;

	If l_id_tbl.count>0 then
	    i:=l_id_tbl.first;
	    LOOP
	       l_cle_tbl(i).id:=l_id_tbl(i);
	       l_cle_tbl(i).object_version_number:=l_obj_tbl(i);
	       l_cle_tbl(i).date_renewed:= l_date;

            EXIT WHEN i=l_id_tbl.last;
	       i:=l_id_tbl.next(i);
	    END LOOP;
         okc_contract_pub.lock_contract_line(
              p_api_version => 1,
	         p_init_msg_list => OKC_API.G_FALSE,
	         x_return_status => l_return_status,
	         x_msg_count => x_msg_count,
	         x_msg_data => x_msg_data,
	         p_clev_tbl => l_cle_tbl );

         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

	      okc_contract_pub.update_contract_line (
	          p_api_version => 1,
	          p_init_msg_list => OKC_API.G_FALSE,
	          x_return_status => l_return_status,
	          x_msg_count => x_msg_count,
	          x_msg_data => x_msg_data,
		     p_restricted_update => okc_api.g_true,
	          p_clev_tbl => l_cle_tbl,
	          x_clev_tbl => x_cle_tbl  );

         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
      END IF; -- if some lines are there that renewed


 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   --dbms_output.put_line('old (-)');

    IF (l_debug = 'Y') THEN
       okc_debug.log('6200:  Leaving update_old_contract', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6300: Exiting update_old_contract:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('6400: Exiting update_old_contract:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('6500: Exiting update_old_contract:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
END update_old_contract;

-------------------------------------------------------------------------------------------
--Adjust the dates in the renew copy as per new start and end dates
-------------------------------------------------------------------------------------------
/*
 * bug 5438257
 * stubbed
 *
*/
PROCEDURE update_renewal_dates(p_api_version       IN  NUMBER,
                               p_init_msg_list     IN  VARCHAR2 ,
                               x_return_status     OUT NOCOPY VARCHAR2,
                               x_msg_count         OUT NOCOPY NUMBER,
                               x_msg_data          OUT NOCOPY VARCHAR2,
                               p_chr_id            IN  NUMBER,
                               p_parent_cle_id     IN  NUMBER ,
                               p_parent_new_st_dt  IN  DATE,
                               p_parent_new_end_dt IN  DATE,
                               p_parent_old_st_dt  IN  DATE,
                               p_cle_id            IN  NUMBER ,
                               p_rencon_yn         IN  VARCHAR2 )  is
BEGIN
  null;
END update_renewal_dates;
/*
 * bug 5438257
PROCEDURE update_renewal_dates(p_api_version       IN  NUMBER,
                               p_init_msg_list     IN  VARCHAR2 ,
                               x_return_status     OUT NOCOPY VARCHAR2,
                               x_msg_count         OUT NOCOPY NUMBER,
                               x_msg_data          OUT NOCOPY VARCHAR2,
                               p_chr_id            IN  NUMBER,
                               p_parent_cle_id     IN  NUMBER ,
                               p_parent_new_st_dt  IN  DATE,
                               p_parent_new_end_dt IN  DATE,
                               p_parent_old_st_dt  IN  DATE,
                               p_cle_id            IN  NUMBER ,
                               p_rencon_yn         IN  VARCHAR2 )  is

--/Rules Migration/-added application id
  CURSOR cur_headers is
  Select start_date,end_date,object_version_number,application_id
  from okc_k_headers_b
  where id = p_chr_id;

  CURSOR cur_lines(p_id number) is
  SELECT id,object_version_number,start_date,end_date,level,cle_id
  FROM okc_k_lines_b
  where dnz_chr_id=p_id
  start with (chr_id=p_id)
  connect by prior id=cle_id;

 -- Modiifed for Bug 2084147
 -- Added new field price_negotiated in the SELECT
 Cursor l_rencon_n_cur(l_chr_id number) is
       SELECT id,object_version_number,start_date,END_date,level,cle_id,price_negotiated
                  FROM okc_k_lines_b
                  where dnz_chr_id=l_chr_id
                  start with (chr_id=l_chr_id)
                  connect by prior id=cle_id;

 -- Modiifed for Bug 2084147
 -- Added new field price_negotiated in the SELECT
 Cursor l_rencon_y_cur(l_chr_id number,l_cle_id number) is
       SELECT id,object_version_number,start_date,END_date,level,cle_id,price_negotiated
                  FROM okc_k_lines_b
                  where dnz_chr_id=l_chr_id
                  start with (id=l_cle_id)
                  connect by prior id=cle_id;

-- Modified for bug 2084147
 -- Added new field price_negotiated in the record definition
 TYPE CLE_REC_TYPE IS RECORD(
	ID                     NUMBER:=OKC_API.G_MISS_NUM,
	object_version_number  NUMBER:=OKC_API.G_MISS_NUM,
	start_date             DATE:=OKC_API.G_MISS_DATE,
	end_date               DATE:=OKC_API.G_MISS_DATE,
	level                  NUMBER:=OKC_API.G_MISS_NUM,
	CLE_ID                 NUMBER:=OKC_API.G_MISS_NUM,
        price_negotiated       NUMBER:=OKC_API.G_MISS_NUM
	);
 lines_rec CLE_REC_TYPE;

 l_num number;

 header_rec cur_headers%rowtype;
 rule_rec cur_rules%rowtype;

 l_chr_rec  okc_contract_pub.chrv_rec_type;
 i_chr_rec  okc_contract_pub.chrv_rec_type;

 l_cle_rec  okc_contract_pub.clev_rec_type;
 i_cle_rec  okc_contract_pub.clev_rec_type;

 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_api_name constant VARCHAR2(30) := 'update_renewal_dates';
 l_uom_code okx_units_of_measure_v.uom_code%type;
 l_duration number;

 l_parent_orig_start_date date;
 l_parent_end_date date;
 l_parent_start_date date;
 l_parent_level number;
 l_DNR_LEVEL      number:=0;
 l_cle_renew_type OKC_RULES_V.rule_information1%type;
 l_cle_tbl  okc_contract_pub.clev_tbl_type;
 l_cle BINARY_INTEGER:=0;
 j  BINARY_INTEGER;

 k_dates number :=0;
 TYPE CLE_PARENT_REC_TYPE IS RECORD(
	ID               NUMBER:=OKC_API.G_MISS_NUM,
	orig_start_date  DATE:=OKC_API.G_MISS_DATE,
	start_date       DATE:=OKC_API.G_MISS_DATE,
	end_date         DATE:=OKC_API.G_MISS_DATE,
	lrt_type         okc_rules_v.rule_information_category%TYPE:=OKC_API.G_MISS_CHAR
	);

 TYPE CLE_PARENT_TBL_TYPE IS TABLE OF CLE_PARENT_REC_TYPE
 INDEX BY BINARY_INTEGER;

 l_cle_parent_rec CLE_PARENT_REC_TYPE;
 l_parent_cle_tbl CLE_PARENT_TBL_TYPE;
 l_additional_days  NUMBER;

 Function get_parent(p_cle_id number) Return cle_parent_rec_type is
    l_rec CLE_PARENT_REC_TYPE;
    i BINARY_INTEGER;
    l_api_name Varchar2(30) := 'get_parent';
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('get_parent');
       okc_debug.log('6500: Entered Get_Parent', 2);
    END IF;

	 If l_parent_cle_tbl.count >0 then
	   i:=l_parent_cle_tbl.first;
	   LOOP
		If l_parent_cle_tbl(i).id=p_cle_id then
-- MKS: Following line is introduced to fix Bug#2106425
                   IF (l_debug = 'Y') THEN
                      okc_debug.Reset_Indentation;
                   END IF;
                   return l_parent_cle_tbl(i);
          END IF;
		Exit when i=l_parent_cle_tbl.last;
		i:=l_parent_cle_tbl.next(i);
       END LOOP;
     END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('6510: Leaving  Function Get_Parent ', 2);
   okc_debug.Reset_Indentation;
END IF;

     return l_rec;
   END;

 Function get_cle_renew_type(p_comp_id number) Return varchar2 is
   l_return OKC_RULES_V.rule_information1%type:=g_def_cle_ren;
   i BINARY_INTEGER;
   l_rule okc_rules_v.rule_information1%type;
   l_api_name Varchar2(30) := 'get_cle_renew_type';
 Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('get_cle_renew_type');
       okc_debug.log('6600: Entered get_cle_renew_type', 2);
    END IF;


	l_rule:=OKC_API.G_MISS_CHAR;
	If g_rules_tbl.count>0 then
	   i:=g_rules_tbl.first;
	   loop
	       If g_rules_tbl(i).comp_id = p_comp_id then
			  l_rule:=g_rules_tbl(i).rule_type;
-- MKS: Following line is introduced to fix Bug#2106425
                 IF (l_debug = 'Y') THEN
                    okc_debug.Reset_Indentation;
                 END IF;
                 return l_rule;
            End If;
		  Exit when i = g_rules_tbl.last;
		  i:=g_rules_tbl.next(i);
       End Loop;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('6610: Leaving  Function Get_Cle_Renew_Type ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    return l_rule;
 End;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('6700: Entered Update_Renewal_Dates', 2);
    END IF;

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

    --reset global table for dates
--     g_cle_dates_tbl.delete;

--/Rules migration/ moved cursor from below.
-- Get the info about the header unconditionally
   Open cur_headers;
   Fetch cur_headers into header_rec;
   Close cur_headers;

   --san added for renconsolidation  as for calls from oks line renewal, header reneewal is not needed
   If p_rencon_yn='N' then

--/Rules Migration/ Moved above
      -- Get the info about the header and update dates
        -- open cur_headers;
        -- fetch cur_headers into header_rec;
        -- close cur_headers;

         l_chr_rec.id := p_chr_id;
         l_chr_rec.object_version_number := header_rec.object_version_number;
         l_chr_rec.start_date := p_parent_new_st_dt;
         l_chr_rec.END_date   := p_parent_new_end_dt;


         IF (l_debug = 'Y') THEN
            okc_debug.log('6800: Before update_contract_header');
         END IF;
l_chr_rec.start_date := TO_DATE(TO_CHAR(l_chr_rec.start_date, 'dd/mm/yyYY') || TO_CHAR(header_rec.start_date, 'hh24:mi:ss'), 'dd/mm/yyYYhh24:mi:ss');
if l_chr_rec.end_date is not null then  -- Added for Bugfix 2803674 to avoid Perpetual
    l_chr_rec.end_date := TO_DATE(TO_CHAR(l_chr_rec.end_date, 'dd/mm/yyYY') || TO_CHAR(header_rec.end_date, 'hh24:mi:ss'), 'dd/mm/yyYYhh24:mi:ss');
end if;

         okc_contract_pub.update_contract_header (
	           p_api_version => 1,
	           p_init_msg_list => OKC_API.G_FALSE,
	           x_return_status => l_return_status,
	           x_msg_count => x_msg_count,
	           x_msg_data => x_msg_data,
	           p_chrv_rec => l_chr_rec,
	           x_chrv_rec => i_chr_rec  );


         IF (l_debug = 'Y') THEN
            okc_debug.log('6900: After update_contract_header');
         END IF;

          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

          -- added 19-MAR-2002 by rgalipo -- performance bug
          -- added call to cursor on temporary table
          INSERT INTO okc_cle_dates_tmp(ID, ORIG_START_DATE, ORIG_END_DATE,
                                         START_DATE, END_DATE)
 VALUES (
             p_chr_id, header_rec.start_date, header_rec.end_date,
             p_parent_new_st_dt, p_parent_new_end_dt);

-- added 19-MAR-2002 by rgalipo -- performance bug
-- removed dependency on pl/sql tables
 -- use temporary table to store data

	     --put headers dates in global dates table
	     -- k_dates:=1;
          -- g_cle_dates_tbl(k_dates).id:=p_chr_id;
          -- g_cle_dates_tbl(k_dates).orig_start_date:=header_rec.start_date;
          -- g_cle_dates_tbl(k_dates).orig_end_date:=header_rec.end_date;
          -- g_cle_dates_tbl(k_dates).start_date:=p_parent_new_st_dt;
          -- g_cle_dates_tbl(k_dates).end_date:=p_parent_new_end_dt;

     END IF; --rencon_yn

  -- Make a table of 'LRT' rule values defined for the lines of the new contract
  -- again if current chr id is different from the one that called this program last time.
  IF g_cached_chr_id <> p_chr_id then
    j:=1;

--/Rules migration/
    If header_rec.application_id in(510,871) Then
      Open cur_rules(p_chr_id);
      Loop
        Fetch cur_rules into rule_rec;

	   Exit when cur_rules%notfound;
	   g_rules_tbl(j).comp_id:=rule_rec.comp_id;
	   g_rules_tbl(j).rule_type:=rule_rec.rule_type;
	   j:=j+1;
      End Loop;
      If cur_rules%isopen then
	    close cur_rules;
      End If;
    Else
      For cur_lines_rec in cur_line(p_chr_id) Loop
        g_rules_tbl(j).comp_id:=cur_lines_rec.comp_id;
        g_rules_tbl(j).rule_type:=cur_lines_rec.rule_type;
	   j:=j+1;
       End Loop;
    End If;
--

  END IF;
    --Now for all the lines, adjust dates based on the rule value 'LRT' for them
  IF p_rencon_yn='N' then
	 -- then build a heirarchy for all lines for this contract
       OPEN l_rencon_n_cur(p_chr_id);
   ELSE
	 --else if renew consolidation, build a heirarchy of lines starting from line sent in
       OPEN l_rencon_y_cur(p_chr_id,p_cle_id);

   END IF; --p_rencon_yn

   loop
     -- Modified for bug 2084147
     -- Fetching new field price_negotiated
     IF p_rencon_yn='N' then
           FETCH l_rencon_n_cur into lines_rec.id,lines_rec.object_version_number,lines_rec.start_date,
				  lines_rec.end_date,lines_rec.level,lines_rec.cle_id,lines_rec.price_negotiated ;
          	EXIT WHEN l_rencon_n_cur%NOTFOUND;
     ELSE
           FETCH l_rencon_y_cur into lines_rec.id,lines_rec.object_version_number,lines_rec.start_date,
				  lines_rec.end_date,lines_rec.level,lines_rec.cle_id,lines_rec.price_negotiated ;
          	EXIT WHEN l_rencon_y_cur%NOTFOUND;
     END IF;

-- check if the parent of the line had rule type 'DNR'
   IF (l_dnr_level=0) OR ( l_dnr_level > 0 and  l_dnr_level >= lines_rec.level)  then
	--reset DNR level
     l_DNR_level:=0;
     -- check the renewal type of line
	l_cle_renew_type:=get_cle_renew_type(lines_rec.id);

	-- the below code added in place of the commented code to fix bug 1398533
	If lines_rec.cle_id is null then
	     If l_cle_renew_type = OKC_API.G_MISS_CHAR then
			l_cle_renew_type:=get_cle_renew_type(p_chr_id);
			IF l_cle_renew_type = OKC_API.G_MISS_CHAR then
			     l_cle_renew_type:=g_def_cle_ren;
               END IF;
          END IF;
		--san rencon
     ELSIF (p_rencon_yn='Y' and lines_rec.id=p_cle_id) then
	   -- that means that this line is a renew consol line sent in and not a top line
		If l_cle_renew_type = OKC_API.G_MISS_CHAR then
			If g_cached_cle_id <> p_parent_cle_id   then
			-- renew_rule not defined for this line, we will have to get it from its parent
			-- so collect a tree of its parents
                  SELECT id
                  bulk collect into g_parent_id_tbl
                  FROM okc_k_lines_b
                  where dnz_chr_id=p_chr_id
                  start with (id=p_parent_cle_id)
                  connect by prior cle_id=id;

			   IF p_parent_cle_id<> OKC_API.G_MISS_NUM then
				  g_cached_cle_id:=p_parent_cle_id;
                  END IF;
              END IF;

             l_num:=g_parent_id_tbl.FIRST;
             LOOP
		      EXIT when (l_cle_renew_type <> OKC_API.G_MISS_CHAR) OR l_num=g_parent_id_tbl.last;
			 --exit when either renew rule is found or none of its parents have any renew rule
			 --defined. In the second case we will check the header for rule
		        l_cle_renew_type:= get_cle_renew_type(g_parent_id_tbl(l_num));
		        l_num:=g_parent_id_tbl.next(l_num);
             END LOOP;
	        If l_cle_renew_type = OKC_API.G_MISS_CHAR then
		    -- if the renew rule could not be found on any of the parents, get from header
			l_cle_renew_type:=get_cle_renew_type(p_chr_id);
			IF l_cle_renew_type = OKC_API.G_MISS_CHAR then
			    -- if even the header doesnot have the rule, take the default.
			     l_cle_renew_type:=g_def_cle_ren;
               END IF;
             END IF;

        END IF;
     ELSE
	      --get the values for parent rec
	      l_cle_parent_rec:=get_parent(lines_rec.cle_id);
	      If l_cle_renew_type = OKC_API.G_MISS_CHAR then
		     l_cle_renew_type:=l_cle_parent_rec.lrt_type;
          END IF;

    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.log('7000: l_cle_renew_type ' || l_cle_renew_type);
    END IF;

     IF l_cle_renew_type='DNR' then
	  l_cle:=l_cle+1;
	  l_cle_tbl(l_cle).id:=lines_rec.id;
	  l_cle_tbl(l_cle).object_version_number:=lines_rec.object_version_number;
          -- Adding for bug 2084147
          l_cle_tbl(l_cle).price_negotiated:=lines_rec.price_negotiated;
       l_DNR_level:=lines_rec.level;
     ELSE
	        --populate the parent start dates.
	        --IF lines_rec.level=1 then
	        --IF lines_rec.cle_id is null then
		   --san rencon
	        IF lines_rec.cle_id is null or lines_rec.id=p_cle_id then
	        	l_parent_end_date:=p_parent_new_end_dt;
	        	l_parent_start_date:=p_parent_new_st_dt;
	        	l_parent_orig_start_date :=p_parent_old_st_dt;
	        	l_parent_cle_tbl.delete;
	        	j:=0;
            -- when sub line of line last processed
             --ELSIF lines_rec.level > l_parent_level  AND lines_rec.level > l_cle_rec.level then
             ELSE
		   -- not needed to reget the parent rec here as we already did it once above while getting renewal type
	         --get the values for parent rec
	         -- l_cle_parent_rec:=get_parent(lines_rec.cle_id);
	        	l_parent_orig_start_date :=l_cle_parent_rec.orig_start_date;
	        	l_parent_end_date:=l_cle_parent_rec.end_date;
	        	l_parent_start_date:=l_cle_parent_rec.start_date;
             END IF;

             l_cle_rec.id := lines_rec.id;
             l_cle_rec.object_version_number :=  lines_rec.object_version_number;
	        IF l_cle_renew_type = 'FUL' then
	     	     l_cle_rec.end_date:=l_parent_end_date;
				--san rencon the below line commented and added a new one below
	     	        --l_cle_rec.start_date:=l_parent_start_date;
				   -- the logic below added for renconsolidation but also valid for us as for us the
				   -- new start date will be the start_date of the parent most of the times.
	               IF lines_rec.cle_id is null then
				   -- that means this is a top line so it starts at the same time as header
	     	        l_cle_rec.start_date:=l_parent_start_date;
                    else
				  -- for sublines
				  -- that means the new start date has to be old_end_date+1 or parent start
				  --date whichever is greater
	     	        l_cle_rec.start_date:=greatest(l_parent_start_date,lines_rec.end_date+1);
                    END IF; -- cle_id is null
             ELSIF l_cle_renew_type = 'KEP' then
-- Bug#2249285: Replaced get_duration with oracle_months_and_days
--
--                  okc_time_util_pub.get_duration(l_parent_orig_start_date,lines_rec.start_date, l_duration,l_uom_code,l_return_status);
                  okc_time_util_pvt.get_oracle_months_and_days(l_parent_orig_start_date,lines_rec.start_date, l_duration,l_additional_days,l_return_status);

                  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                         OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => 'OKC_GET_DURATION_ERROR');

                         RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

-- Bug#2249285: Changed to add_months + days for offset calculations.
--
--	             l_cle_rec.start_date := okc_time_util_pub.get_ENDdate(l_parent_start_date,l_uom_code,l_duration);
--
	             l_cle_rec.start_date := ADD_MONTHS(l_parent_Start_date, l_duration) + l_additional_days;

			   -- For perpetual contracts, the parent may not have any end date
                  IF l_cle_rec.start_date <= nvl(l_parent_end_date,l_cle_rec.start_date) then
-- Bug#2249285: Replaced get_duration with oracle_months_and_days
--                            okc_time_util_pub.get_duration(l_parent_orig_start_date,
--			     	            lines_rec.end_date,l_duration,l_uom_code,l_return_status);
                  l_duration := 0;
                  l_additional_days := 0;
                  okc_time_util_pvt.get_oracle_months_and_days(l_parent_orig_start_date,lines_rec.end_date, l_duration,l_additional_days,l_return_status);

                            IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                                    OKC_API.set_message(p_app_name      => g_app_name,
                                            p_msg_name      => 'OKC_GET_DURATION_ERROR');
                                    RAISE OKC_API.G_EXCEPTION_ERROR;
                            END IF;
-- Bug#2249285: Changed to add_months + days for offset calculations.

--
--                           l_cle_rec.END_date   := okc_time_util_pub.get_ENDdate(l_parent_start_date, l_uom_code,l_duration);

	             l_cle_rec.end_date := add_months(l_parent_Start_date, l_duration) + l_additional_days;

                           IF l_cle_rec.end_date > nvl(l_parent_end_date,l_cle_rec.end_date) then
			                 l_cle_rec.end_date:=l_parent_end_date;
                           END IF;
                  ELSE
			          l_cle_rec.start_date:=l_parent_start_date;
			          l_cle_rec.end_date:=l_parent_start_date;
                  END IF; -- new_start_date < parent_start_date
               END IF;-- renew type FUL or KEP


               IF (l_debug = 'Y') THEN
                  okc_debug.log('7100: Before update_contract_line');
               END IF;

 --Added decode for Bug 2911298
SELECT TO_DATE(TO_CHAR(l_cle_rec.start_date, 'dd/mm/yyYY') || TO_CHAR(start_date, 'hh24:mi:ss'), 'dd/mm/yyYYhh24:mi:ss'),
    decode(l_cle_rec.end_date, null, null, TO_DATE(TO_CHAR(l_cle_rec.end_date, 'dd/mm/yyYY') || TO_CHAR(end_date, 'hh24:mi:ss'), 'dd/mm/yyYYhh24:mi:ss'))
  INTO l_cle_rec.start_date, l_cle_rec.end_date
  FROM okc_k_lines_b
  WHERE id = (SELECT object_cle_id FROM okc_operation_lines WHERE subject_cle_id = l_cle_rec.id);

               okc_contract_pub.update_contract_line (
	                p_api_version => 1,
	                p_init_msg_list => OKC_API.G_FALSE,
	                x_return_status => l_return_status,
	                x_msg_count => x_msg_count,
	                x_msg_data => x_msg_data,
	                p_clev_rec => l_cle_rec,
	                x_clev_rec => i_cle_rec  );
               IF (l_debug = 'Y') THEN
                  okc_debug.log('7200: After update_contract_line');
               END IF;

                 IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;

              --add the line in parent table
                 j:=j+1;
                 l_parent_cle_tbl(j).id:=l_cle_rec.id;
                 l_parent_cle_tbl(j).orig_start_date:=lines_rec.start_date;
                 l_parent_cle_tbl(j).start_date:=l_cle_rec.start_date;
                 l_parent_cle_tbl(j).end_date:=l_cle_rec.end_date;
                 l_parent_cle_tbl(j).lrt_type:=l_cle_renew_type;


          -- added 19-MAR-2002 by rgalipo -- performance bug
          -- insert data into temporary table
          -- in order to remove dependency on pl/sql tables
          INSERT INTO okc_cle_dates_tmp (ID, ORIG_START_DATE, ORIG_END_DATE,
                                         START_DATE, END_DATE)
VALUES (
             l_cle_rec.id, lines_rec.start_date, lines_rec.end_date,
             l_cle_rec.start_date, l_cle_rec.end_date);

-- removed dependency on pl/sql tables
-- use temporary table for better performance
           --put line dates in dates table
 --            k_dates:=k_dates+1;
  --             g_cle_dates_tbl(k_dates).id:=l_cle_rec.id;
   --            g_cle_dates_tbl(k_dates).orig_start_date:=lines_rec.start_date;
    --           g_cle_dates_tbl(k_dates).orig_end_date:=lines_rec.end_date;
     --          g_cle_dates_tbl(k_dates).start_date:=l_cle_rec.start_date;
      --         g_cle_dates_tbl(k_dates).end_date:=l_cle_rec.end_date;




          END IF; -- when the renew rule type is 'DNR'
       END IF; -- dnr_level
    END loop;-- main loop

    IF l_rencon_n_cur%ISOPEN then
	  close l_rencon_n_cur;
    END IF;
    IF l_rencon_y_cur%ISOPEN then
	  close l_rencon_y_cur;
    END IF;

      IF l_cle_tbl.count>0 then
	    j:=l_cle_tbl.first;
	    loop
            OKC_CONTRACT_PUB.Delete_Contract_Line(
  		          p_api_version      => 1,
	               p_init_msg_list    => OKC_API.G_FALSE,
	               x_return_status    => l_return_status,
	               x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
		          p_line_id          => l_cle_tbl(j).id);
             IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
   -- Adding for bug 2084147 - Start
   -- IF Line Rule is DONOT RENEW then price_negotiated should be substracted from header
   -- level estimated amount
   -- Not calling Update Contract api for performance reason as well as it is a process api
   -- donot need to do all the validation for updating the price

               UPDATE OKC_K_HEADERS_B
               set estimated_amount = estimated_amount - l_cle_tbl(j).price_negotiated
               WHERE  id = p_chr_id;
   -- Adding for bug 2084147 - End

		   exit when j = l_cle_tbl.last;
		   j:=l_cle_tbl.next(j);
	     END loop;
       END IF;


--update rules has to be called after update_startend as update_start... sets dates table for rules

--update the the dates and timevalues in the rules defined for renew copy

       IF (l_debug = 'Y') THEN
          okc_debug.log('7300: Before update_rules');
       END IF;
	  update_rules(p_api_version     	=> 1,
                 p_init_msg_list   	=> OKC_API.G_FALSE,
                 x_return_status   	=> l_return_status,
                 x_msg_count       	=> x_msg_count,
                 x_msg_data        	=> x_msg_data,
                 p_chr_id          	=> p_chr_id
			  );
       IF (l_debug = 'Y') THEN
          okc_debug.log('7400: After update_rules');
       END IF;

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


    IF (l_debug = 'Y') THEN
       okc_debug.log('7500:  Leaving Update_Renewal_Dates', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7600: Exiting Update_Renewal_Dates:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    IF l_rencon_n_cur%ISOPEN then
	  close l_rencon_n_cur;
    END IF;
    IF l_rencon_y_cur%ISOPEN then
	  close l_rencon_y_cur;
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
       okc_debug.log('7700: Exiting Update_Renewal_Dates:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    IF l_rencon_n_cur%ISOPEN then
	  close l_rencon_n_cur;
    END IF;
    IF l_rencon_y_cur%ISOPEN then
	  close l_rencon_y_cur;
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
       okc_debug.log('7800: Exiting Update_Renewal_Dates:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    IF l_rencon_n_cur%ISOPEN then
	  close l_rencon_n_cur;
    END IF;
    IF l_rencon_y_cur%ISOPEN then
	  close l_rencon_y_cur;
    END IF;
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');

END Update_Renewal_Dates;
*/

-- this procedure sets the notification for post_renew
PROCEDURE set_notify(
                 x_return_status                OUT NOCOPY  VARCHAR2 ,
                 p_old_k                    IN VARCHAR2 ,
                 p_old_mod                    IN VARCHAR2 ,
                 p_new_k                    IN VARCHAR2 ,
                 p_new_mod                    IN VARCHAR2 ,
                 p_qa_stat                    IN VARCHAR2 ,
                 p_wf_found                     IN VARCHAR2 ,
                 p_subj_msg                     IN VARCHAR2 ,
	            p_ren_type                     IN VARCHAR2 ) IS
   l_oldk Varchar2(255);
   l_newk Varchar2(255);
   l_api_name Varchar2(30) := 'set_notify';
BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('7900: Entered set_notify', 2);
    END IF;

            x_return_status :=OKC_API.G_RET_STS_SUCCESS;

	    If (p_old_mod Is Null) Or (p_old_mod = OKC_API.G_MISS_CHAR) Then
		   l_oldk := p_old_k;
         Else
             l_oldk := p_old_k || '-' || p_old_mod;
         End If;
																	   If (p_new_mod Is Null) Or (p_new_mod = OKC_API.G_MISS_CHAR) Then
           l_newk := p_new_k;
        Else
           l_newk := p_new_k || '-' || p_new_mod;
        End If;

	  If p_subj_msg <> OKC_API.G_MISS_CHAR then
                 OKC_API.set_message(p_app_name      => g_app_name,
                                     p_msg_name      => p_subj_msg);
            ELSE
                 OKC_API.set_message(p_app_name      => g_app_name,
                                     p_msg_name      => 'OKC_REN_SUBJECT',
                                     p_token1        => 'NUMBER',
                                     p_token1_value  => l_oldk);
            END IF;
		  If p_ren_type = 'NSR' then
                 OKC_API.set_message(p_app_name      => g_app_name,
                                     p_msg_name      => 'OKC_REN_NSR',
                                     p_token1        => 'OLDK',
                                     p_token1_value  => l_oldk,
                                     p_token2        => 'NEWK',
                                     p_token2_value  => l_newk);
            ELSE
			  IF p_qa_stat = 'S' then
                      OKC_API.set_message(p_app_name      => g_app_name,
                                          p_msg_name      => 'OKC_QA_FAILED');
                      IF p_ren_type='SFA' then
                            OKC_API.set_message(p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_REN_NO_SFA',
                                                p_token1        => 'OLDK',
                                                p_token1_value  => l_oldk,
                                                p_token2        => 'NEWK',
                                                p_token2_value  => l_newk);
                      ELSIF p_ren_type='EVN' then
                            OKC_API.set_message(p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_REN_NO_EVN',
                                                p_token1        => 'OLDK',
                                                p_token1_value  => l_oldk,
                                                p_token2        => 'NEWK',
                                                p_token2_value  => l_newk);
                     END IF;
                 ELSE
				 IF p_qa_stat = 'W' then
                           OKC_API.set_message(p_app_name      => g_app_name,
                                               p_msg_name      => 'OKC_QA_WARNINGS');
			      END IF;
                     IF p_ren_type='SFA' then
					If p_wf_found='F' then
                            OKC_API.set_message(p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_REN_NO_WF',
                                                p_token1        => 'OLDK',
                                                p_token1_value  => l_oldk,
                                                p_token2        => 'NEWK',
                                                p_token2_value  => l_newk);

					ELSE
                            OKC_API.set_message(p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_REN_SFA',
                                                p_token1        => 'OLDK',
                                                p_token1_value  => l_oldk,
                                                p_token2        => 'NEWK',
                                                p_token2_value  => l_newk);
                         END IF;
                     ELSIF p_ren_type='EVN' then
                            OKC_API.set_message(p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_REN_EVN',
                                                p_token1        => 'OLDK',
                                                p_token1_value  => l_oldk,
                                                p_token2        => 'NEWK',
                                                p_token2_value  => l_newk);
                    END IF;

                 END IF;

		  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.log('8000: Leaving Set_Notify', 2);
     okc_debug.Reset_Indentation;
  END IF;
END Set_Notify;

--------------------------------------------------------------------------------------------
--called from renew procedure in public, this procedure sends the notifiactions
-- and a few other things depending on the renew rule defined on the contract
-- This procedure should be called after creating a renewed contract to decide what
--should be the final state of the renewed contract
--------------------------------------------------------------------------------------------
PROCEDURE post_renewed_contract(
                 p_api_version                  IN NUMBER,
       	       p_init_msg_list                IN VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_renew_chr_id                 IN  number,
	            p_renew_in_parameters_rec      IN  Renew_in_parameters_rec,
	            p_ren_type                     IN VARCHAR2 ,
	            p_contact                      IN  VARCHAR2 ) is

  CURSOR cur_rules(p_chr_id number) is
  SELECT nvl(rul.rule_information1,OKC_API.G_MISS_CHAR) renew_type,
					 nvl(rul.rule_information2,OKC_API.G_MISS_CHAR) contact
  FROM okc_rules_b rul,okc_rule_groups_b rgp
  WHERE    rgp.dnz_chr_id = p_chr_id
	 and   rgp.id=rul.rgp_id
	 --and   rgp.rgd_code='RENEW'
	 and   rul.rule_information_category='REN' ;

--/Rules migration/ replaced by cursor below
/*
CURSOR cur_qa(p_chr_id number) is select nvl(qcl_id,OKC_API.G_MISS_NUM)
		    from OKC_K_HEADERS_b
		    where id=p_chr_id;
*/


 CURSOR cur_header(p_chr_id number) is
 select nvl(qcl_id,OKC_API.G_MISS_NUM) qcl_id,
        nvl(renewal_type_code,OKC_API.G_MISS_CHAR) renewal_type_code,renewal_notify_to,
        application_id
 from OKC_K_HEADERS_b
 where id=p_chr_id;

  CURSOR cur_wf(p_chr_id number)
  is select pdf_id from okc_k_processes kp, okc_process_defs_b pd  where
	    kp.chr_id=p_chr_id and kp.pdf_id=pd.id and pd.usage='APPROVE';

  CURSOR cur_user(p_user_id number)
  is select fnd.user_name from okx_resources_v res, fnd_user fnd   where
               fnd.user_id=res.user_id and res.id1=p_user_id;

 CURSOR cur_header_aa IS
 SELECT k.estimated_amount,k.scs_code,scs.cls_code,k.sts_code
   FROM OKC_K_HEADERS_B K,
  	   OKC_SUBCLASSES_B SCS
  WHERE k.id = p_renew_in_parameters_rec.p_contract_id
    AND k.scs_code = scs.code;

  CURSOR cur_startend(p_chr_id number) is
  select start_date,end_date from okc_k_headers_b where
   id=p_chr_id;

 l_scs_code okc_subclasses_v.code%type;
 l_cls_code okc_subclasses_v.cls_code%type;
 l_k_status_code okc_k_headers_v.sts_code%type;
 l_end_date date;
 l_start_date date;
 l_estimated_amount number;
 --l_wf_msg_tbl okc_async_pvt.par_tbl_typ;
 l_pdf_id number :=OKC_API.G_MISS_NUM;
 rule_rec cur_rules%rowtype;
 l_ren_type  okc_rules_v.rule_information1%type:=OKC_API.G_MISS_CHAR;
 l_contact  okc_rules_v.rule_information2%type:=OKC_API.G_MISS_CHAR;
 l_qcl_id number;
 l_msg_tbl  OKC_QA_CHECK_PUB.MSG_TBL_TYPE;
 i BINARY_INTEGER;
 l_max_severity varchar2(1):='I';
 l_wf_found varchar2(1):='T';
 l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_api_name constant VARCHAR2(30) := 'post_renewed_contract';
 l_lead_id Number;
 cur_header_rec cur_header%rowtype;

 --FUNCTION notify(p_msg_tbl okc_async_pvt.par_tbl_typ,p_user varchar2) RETURN varchar2 IS
 FUNCTION notify(p_user varchar2) RETURN varchar2 IS
    l_user_name fnd_user.user_name%type :=OKC_API.G_MISS_CHAR;
    l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_exception_stop exception;
    l_proc varchar2(4000);
    l_api_name Varchar2(30) := 'notify';
   BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('8100: Entered notify', 2);
    END IF;

	 IF p_ren_type = OKC_API.G_MISS_CHAR then
	    open cur_user(to_number(p_user));
	    FETCH cur_user into l_user_name;
	    close cur_user;
      ELSE
		 l_user_name := p_user;
      END IF;

	 IF l_user_name <> OKC_API.G_MISS_CHAR  AND l_user_name is not null then

	    l_proc:='begin OKC_RENEW_PVT.SET_NOTIFY(x_return_status=>:1,p_old_k=>'''||
			  p_renew_in_parameters_rec.p_contract_number ||'''';
			  IF p_renew_in_parameters_rec.p_contract_modifier <> OKC_API.G_MISS_CHAR then
			     l_proc:= l_proc||',p_old_mod=>'''||p_renew_in_parameters_rec.p_contract_modifier ||'''';
                 END IF;

			  l_proc:= l_proc||',p_new_k=>'''||p_renew_in_parameters_rec.p_new_contract_number ||'''';

			  IF p_renew_in_parameters_rec.p_new_contract_modifier <> OKC_API.G_MISS_CHAR then
			     l_proc:= l_proc||',p_new_mod=>'''||p_renew_in_parameters_rec.p_new_contract_modifier ||'''';
                 END IF;

			  l_proc:= l_proc||',p_qa_stat=>'''||l_max_severity||
						  ''',p_wf_found=>'''||l_wf_found||
						  ''',p_ren_type=>'''||l_ren_type||''' ); end;';


         IF (l_debug = 'Y') THEN
            okc_debug.log('8200: Before proc_msg_call');
         END IF;
	    OKC_ASYNC_PUB.proc_msg_call(
		    p_api_version => 1,
		    x_return_status => l_return_status,
		    x_msg_count  => x_msg_count,
		    x_msg_data => x_msg_data,
		    p_proc => l_proc,
		    p_s_recipient => l_user_name,
		    p_e_recipient => l_user_name,
		    p_contract_id => p_renew_chr_id
		    );
         IF (l_debug = 'Y') THEN
            okc_debug.log('8300: After proc_msg_call');
         END IF;


          IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			 RAISE l_exception_stop;
          END IF;

     END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8400:  Leaving notify', 2);
       okc_debug.Reset_Indentation;
    END IF;

     return (l_return_status);

 EXCEPTION
  WHEN l_exception_stop then

    IF (l_debug = 'Y') THEN
       okc_debug.log('8500: Exiting notify:l_exception_stop Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

     return l_return_status;
  when others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Exiting notify:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

   return (l_return_status);
END notify;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('8700: Entered post_renewed_contract', 2);
    END IF;

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

--/Rules migration/  added
  open cur_header(p_renew_chr_id);
  fetch cur_header into cur_header_rec;
  close cur_header;

  IF p_ren_type = OKC_API.G_MISS_CHAR then
    If cur_header_rec.application_id in (510,871) Then
       open cur_rules(p_renew_chr_id);
       fetch cur_rules into rule_rec;
       close cur_rules;
	  l_ren_type:=rule_rec.renew_type;
	  l_contact:=rule_rec.contact;
    Else
	  l_ren_type := cur_header_rec.renewal_type_code;
	  If cur_header_rec.renewal_notify_to is null Then
         l_contact := OKC_API.G_MISS_CHAR;
       Else
         l_contact :=cur_header_rec.renewal_notify_to;
       End If;
    End If;

   ELSE
	  l_ren_type:=p_ren_type;
	  l_contact :=p_contact;

 END IF;
 IF (l_debug = 'Y') THEN
    okc_debug.log('8800: l_ren_type ' || l_ren_type);
 END IF;

 IF l_ren_type in ('SFA','EVN','NSR') then
	If l_contact = OKC_API.G_MISS_CHAR then
          OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => 'OKC_NO_RENEW_CONTACT');
          RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
	IF l_ren_type in ('SFA','EVN') then
	  --do qa check
--/Rules migration/ Use cur_header_rec

/*	    Open cur_qa(p_renewed_chr_id);
	    Fetch cur_qa into l_qcl_id;
	    Close cur_qa;
*/
	    l_qcl_id := cur_header_rec.qcl_id;
--
	    If l_qcl_id  <> OKC_API.G_MISS_NUM then
            IF (l_debug = 'Y') THEN
               okc_debug.log('8900: Before QA Check');
            END IF;
		  OKC_QA_CHECK_PUB.execute_qa_check_list(
			 p_api_version =>p_api_version
			 ,p_init_msg_list=>okc_api.g_false
			 ,x_return_status=>x_return_status
			 ,x_msg_count=>x_msg_count
			 ,x_msg_data=>x_msg_data
			 ,p_qcl_id=>l_qcl_id
			 ,p_chr_id=>p_renew_chr_id
			 ,x_msg_tbl=>l_msg_tbl
			 );
             IF (l_debug = 'Y') THEN
                okc_debug.log('9000: After QA Check');
             END IF;
             IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
		   l_max_severity:='I';
		   If l_msg_tbl.count >0 then
			 i:=l_msg_tbl.first;
			 LOOP
               --dbms_output.put_line('san dbms in loop severity level'||i||' '||l_msg_tbl(i).severity);
               --dbms_output.put_line('san dbms in loop severity error status'||i||' '||l_msg_tbl(i).error_status);
               --dbms_output.put_line('san dbms in loop severity name '||i||' '||l_msg_tbl(i).name);
               --dbms_output.put_line('san dbms in loop severity package_name'||i||' '||l_msg_tbl(i).package_name);
               --dbms_output.put_line('san dbms in loop severity procedure_name'||i||' '||l_msg_tbl(i).procedure_name);
               --dbms_output.put_line('san dbms in loop severity descriptio'||i||' '||l_msg_tbl(i).description);
			    If l_msg_tbl(i).severity='W' and l_msg_tbl(i).error_status='E' then
				    l_max_severity:='W';
				    --san comment later on make the message with warnings
--	                   l_wf_msg_tbl(2).par_type := 'C';
--	                   l_wf_msg_tbl(2).par_name := 'MESSAGE1';
--	                   l_wf_msg_tbl(2).par_value := 'QA returned with warnings';
                   ELSIF l_msg_tbl(i).severity='S' and l_msg_tbl(i).error_status='E' then
				    l_max_severity:='S';
				    --san comment later on make the message with stop error
--	                   l_wf_msg_tbl(2).par_type := 'C';
--	                   l_wf_msg_tbl(2).par_name := 'MESSAGE1';
--	                   l_wf_msg_tbl(2).par_value := 'QA returned with errors. Post renewal stopped';
				    exit;
                   END IF;
			    exit when i=l_msg_tbl.last;
			    i:=l_msg_tbl.next(i);
                END LOOP;
            END IF;--table count

         END IF; -- if qcl_id found
            -- start appropriate workflows

            IF l_max_severity <> 'S' then
			  IF l_ren_type = 'SFA' then

				--san comment start contract approval workflow
				open cur_wf(p_renew_chr_id);
				Fetch cur_wf into l_pdf_id;
				close cur_wf;
				IF l_pdf_id <> OKC_API.G_MISS_NUM then
                       IF (l_debug = 'Y') THEN
                          okc_debug.log('9100: Before k_approval_start');
                       END IF;
				   OKC_CONTRACT_APPROVAL_PUB.k_approval_start(
						   p_api_version=>p_api_version,
						   p_init_msg_list=>okc_api.g_false,
						   x_return_status=>x_return_status,
						   x_msg_count=>x_msg_count,
						   x_msg_data=>x_msg_data,
						   p_contract_id=>p_renew_chr_id,
						   p_process_id=>l_pdf_id,
						   p_do_commit=>okc_api.g_false,
                                                   p_access_level=>'Y'
                        );
                       IF (l_debug = 'Y') THEN
                          okc_debug.log('9200: After k_approval_start');
                       END IF;
                           IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                                   RAISE OKC_API.G_EXCEPTION_ERROR;
                           END IF;

--	                      l_wf_msg_tbl(2).par_type := 'C';
--	                      l_wf_msg_tbl(2).par_name := 'MESSAGE1';
--	                      l_wf_msg_tbl(2).par_value := 'Contract renewed and sent for approval';
				ELSE
					  l_wf_found:='F';
--	                      l_wf_msg_tbl(2).par_type := 'C';
--	                      l_wf_msg_tbl(2).par_name := 'MESSAGE1';
--	                      l_wf_msg_tbl(2).par_value := 'Contract renewed but no workflow to activate';
				END IF;
                 ELSE
				-- call alex api to update status and resolve time values

			  -- update the date approved of the contract
                       IF (l_debug = 'Y') THEN
                          okc_debug.log('9300: Before k_approved');
                       END IF;
				   OKC_CONTRACT_APPROVAL_PUB.k_approved(
						   p_contract_id=>p_renew_chr_id,
						   x_return_status=>x_return_status
                        );
                       IF (l_debug = 'Y') THEN
                          okc_debug.log('9400: After k_approved');
                       END IF;
                        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                                   RAISE OKC_API.G_EXCEPTION_ERROR;
                        END IF;
                       -- sign the contract
                       IF (l_debug = 'Y') THEN
                          okc_debug.log('9500: Before k_signed');
                       END IF;
				   OKC_CONTRACT_APPROVAL_PUB.k_signed(
						   p_contract_id=>p_renew_chr_id,
						   x_return_status=>x_return_status
                        );
                       IF (l_debug = 'Y') THEN
                          okc_debug.log('9600: After k_signed');
                       END IF;
                        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                                   RAISE OKC_API.G_EXCEPTION_ERROR;
                        END IF;

                 END IF;

             ELSE
			  null;

             END IF;--severity check
     ELSE
			    null;

     END IF;-- if ren type sfa or evn
		  -- start notify workflow

       IF (l_debug = 'Y') THEN
          okc_debug.log('9700: Before notify');
       END IF;
	  --x_return_status := notify(l_wf_msg_tbl,l_contact);
	  x_return_status := notify(l_contact);
       IF (l_debug = 'Y') THEN
          okc_debug.log('9800: After notify');
       END IF;
       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
 END IF;-- if ren type sfa,evn or nsr
 --call action assembler here.

  IF Nvl(l_ren_type, '*') <> 'DNR' then
  	open cur_header_aa;
	fetch cur_header_aa into l_estimated_amount,l_scs_code,l_cls_code,l_k_status_code;
	close cur_header_aa;

     l_end_date:=p_renew_in_parameters_rec.p_end_date;
     l_start_date:=p_renew_in_parameters_rec.p_start_date;

	IF l_end_date is null or l_start_date is null then
	   open cur_startend(p_renew_chr_id);
	   fetch cur_startend into l_start_date,l_end_date;
	   close cur_startend;
     END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('9900: Before acn_assemble');
    END IF;
     OKC_K_RENEW_ASMBLR_PVT.acn_assemble(
           p_api_version           => 1,
           p_init_msg_list         => OKC_API.G_FALSE,
           x_return_status         => l_return_status,
           x_msg_count             => x_msg_count,
           x_msg_data              => x_msg_data,
           p_k_nbr_mod             => p_renew_in_parameters_rec.p_contract_modifier,
           p_new_k_END_date        => l_END_date,
           p_k_number              => p_renew_in_parameters_rec.p_new_contract_number,
           p_new_k_id              => p_renew_chr_id,
           p_new_k_start_date      => l_start_date,
           p_original_k_END_date   => p_renew_in_parameters_rec.p_orig_END_date,
           p_original_kid          => p_renew_in_parameters_rec.p_contract_id,
           p_original_k_start_date => p_renew_in_parameters_rec.p_orig_start_date,
           p_k_class               => l_cls_code,
           p_k_subclass            => l_scs_code,
           p_k_status_code         => l_k_status_code,
           p_estimated_amount      => l_estimated_amount);
    IF (l_debug = 'Y') THEN
       okc_debug.log('10000: After acn_assemble');
    END IF;

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Opportunity Integration starts from here. See bug 1865416 for more details.
     -- Create opportunity for this renewed contract only if it is allowed.
     IF (l_debug = 'Y') THEN
        okc_debug.log('11000: Before is_opp_creation_allowed');
     END IF;
     okc_opportunity_pub.is_opp_creation_allowed(
                 p_context => 'RENEW',
                 p_contract_id => p_renew_chr_id,
                 x_return_status => l_return_status);
     IF (l_debug = 'Y') THEN
        okc_debug.log('10100: After is_opp_creation_allowed');
        okc_debug.log('10200: Return Status of opp_creation_allowed - ' || l_return_status);
     END IF;
     -- In case of unexpected error, raise the exception, however if it is
     -- a normal error, it means opportunity cannot be created and success
     -- should be returned from this procedure.
     If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     /* Elsif l_return_status = OKC_API.G_RET_STS_ERROR Then
       Raise OKC_API.G_EXCEPTION_ERROR; */
     End If;

     If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
       IF (l_debug = 'Y') THEN
          okc_debug.log('10300: Before Create_Opportunity');
       END IF;

       okc_opportunity_pub.create_opportunity(
			  p_api_version          => 1,
                 p_context              => 'RENEW',
                 p_contract_id          => p_renew_chr_id,
                 p_win_probability      => Null,
                 p_expected_close_days  => Null,
                 x_lead_id              => l_lead_id,
			  p_init_msg_list        => OKC_API.G_FALSE,
			  x_msg_data             => x_msg_data,
                 x_msg_count            => x_msg_count,
                 x_return_status        => l_return_status);

       IF (l_debug = 'Y') THEN
          okc_debug.log('10400: After Create_Opportunity');
          okc_debug.log('10500: Return Status of Create_Opportunity - ' || l_return_status);
          okc_debug.log('10600: Lead ID - ' || To_Char(l_lead_id));
       END IF;

       If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
         Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       /* Elsif l_return_status = OKC_API.G_RET_STS_ERROR Then
         Raise OKC_API.G_EXCEPTION_ERROR; */
       End If;
     End If;

   END IF; -- ren_type not 'DNR'
 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('10700:  Leaving post_renewed_contract', 2);
   okc_debug.Reset_Indentation;
END IF;

EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10800: Exiting post_renewed_contract:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('10900: Exiting post_renewed_contract:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('11000: Exiting post_renewed_contract:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');


END post_renewed_contract;


--------------------------------------------------------------------------------------------
--called from renew procedure in public, this procedure actually creates a copy of
--of the contract to be renewed and adjust the dates on the various components of this
--copy
--------------------------------------------------------------------------------------------
PROCEDURE Create_Renewed_Contract
                 (p_api_version             IN  NUMBER,
                  p_init_msg_list           IN  VARCHAR2 ,
                  x_return_status           OUT NOCOPY VARCHAR2,
                  x_msg_count               OUT NOCOPY NUMBER,
                  x_msg_data                OUT NOCOPY VARCHAR2,
                  x_contract_id             OUT NOCOPY NUMBER,
                  p_renew_in_parameters_rec IN  Renew_in_parameters_rec,
                  x_renew_in_parameters_rec OUT NOCOPY  Renew_in_parameters_rec,
                  p_ren_type                IN  varchar2 ,
		  p_renewal_called_from_ui    IN VARCHAR2
		  ) is

l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
l_renew_in_parameters_rec  renew_in_parameters_rec := p_renew_in_parameters_rec;
l_ren_type  okc_rules_v.rule_information1%type;
l_ultimate_end_date Date;

l_api_name constant VARCHAR2(30) := 'CREATE_RENEWD_CONTRACT';


  -- Cursor modified for Bug 2292300
  CURSOR cur_rules(p_chr_id number) is
  SELECT nvl(rul.rule_information1, OKC_API.G_MISS_CHAR) renew_type,
         fnd_date.Canonical_To_Date(rul.rule_information3) ultimate_end_date
         --To_Date(rul.rule_information3, 'YYYY/MM/DD') ultimate_end_date
    FROM okc_rules_b rul,
         okc_rule_groups_b rgp
   WHERE rgp.dnz_chr_id = p_chr_id
     and rgp.id = rul.rgp_id
  -- and rgp.rgd_code = 'RENEW'
     and rul.rule_information_category = 'REN';

--commented /rules migration/
--replaced by cur_header
/*cursor cur_org is select  authoring_org_id,inv_organization_id
from okc_k_headers_b
where id = p_renew_in_parameters_rec.p_contract_id;*/

-- /rules migration/
Cursor cur_header is
   	select authoring_org_id,inv_organization_id,application_id,
	nvl(renewal_type_code,OKC_API.G_MISS_CHAR) renewal_type_code,
     renewal_end_date
     from okc_k_headers_b
     where id = p_renew_in_parameters_rec.p_contract_id;

cur_header_rec cur_header%rowtype;
--
r_org OKC_K_HEADERS_B.authoring_org_id%type;
r_inv_org OKC_K_HEADERS_B.inv_organization_id%type;

FUNCTION set_attributes(p_renew_in_rec IN OUT NOCOPY renew_in_parameters_rec) RETURN varchar2 is

  l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name Varchar2(30) := 'set_attributes';
  --
  Procedure Set_Evergreen_Date_Uom(p_return_status OUT NOCOPY Varchar2) Is
    l_return_status Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('11100: Entered Set_Evergreen_Date_Uom', 2);
    END IF;

    p_return_status := l_return_status;
    --
    -- In case of evergreen contract, the contract end date must be less than
    -- the renewal rule ultimate end date. If it not so, set the end date to
    -- ultimate end date.
    If l_ren_type = 'EVN' Then
      If l_ultimate_end_date Is Not Null Then
        --
        -- Make sure that contract has not already reached its ultimate
        -- end date
        If l_ultimate_end_date <= p_renew_in_rec.p_start_date Then
          OKC_API.set_message(p_app_name => g_app_name,
                              p_msg_name => 'OKC_ULTIMATE_END_REACHED');
          p_return_status := okc_api.g_ret_sts_error;
        Else
          If l_ultimate_end_date < p_renew_in_rec.p_end_date Then
            p_renew_in_rec.p_end_date := l_ultimate_end_date;
            --
            -- Recalculate the UOM Code and the duration based on this
            -- new date.
            okc_time_util_pub.get_duration(p_renew_in_rec.p_start_date,
                                           p_renew_in_rec.p_end_date,
                                           p_renew_in_rec.p_duration,
                                           p_renew_in_rec.p_uom_code,
                                           l_return_status);
            if l_return_status <> okc_api.g_ret_sts_success then
              OKC_API.set_message(p_app_name => g_app_name,
                                  p_msg_name => 'OKC_GET_DURATION_ERROR');
              p_return_status := l_return_status;
            End If;
          End If;
        End If;
      End If;
    End If;

IF (l_debug = 'Y') THEN
   okc_debug.log('11150: Leaving Set_Evergreen_Date_Uom', 2);
   okc_debug.Reset_Indentation;
END IF;
  End Set_Evergreen_Date_Uom;
BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('11200: Entered set_attributes', 2);
    END IF;

  -- calculate new start date if not provided
  If p_renew_in_rec.p_start_date is null then

    p_renew_in_rec.p_start_date := p_renew_in_rec.p_orig_end_date + 1;
  End if;

  -- calculate new end date if not provided else calculate duration and uom code
  If p_renew_in_rec.p_perpetual_flag = OKC_API.G_FALSE  OR
     p_renew_in_parameters_rec.p_perpetual_flag IS NULL Then
    If p_renew_in_rec.p_end_date is null then
      p_renew_in_rec.p_end_date := okc_time_util_pub.get_enddate
			  (p_renew_in_rec.p_start_date,
                           p_renew_in_rec.p_uom_code,
                           p_renew_in_rec.p_duration);
      --
      -- Bug 1787600 - For Evergreen Contracts, if ultimate end date has
      -- been supplied, make sure this is less than the contract end date
      -- otherwise use the ultimate end date as the contract end date
      --
      Set_Evergreen_Date_Uom(l_return_status);
      If l_return_status <> okc_api.g_ret_sts_success then
        return (l_return_status);
      End If;
    Else
      Set_Evergreen_Date_Uom(l_return_status);
      If l_return_status <> okc_api.g_ret_sts_success then
        return (l_return_status);
      End If;
      If p_renew_in_rec.p_uom_code is null OR  p_renew_in_rec.p_duration is null then
        okc_time_util_pub.get_duration(p_renew_in_rec.p_start_date,
                                       p_renew_in_rec.p_end_date,
                                       p_renew_in_rec.p_duration,
                                       p_renew_in_rec.p_uom_code,
       	                               l_return_status);

        if l_return_status <> okc_api.g_ret_sts_success then
          OKC_API.set_message(p_app_name => g_app_name,
                              p_msg_name => 'OKC_GET_DURATION_ERROR');
          return (l_return_status);
        End If;
      End If;
    End If;
  Else -- if perpetual contract
    p_renew_in_rec.p_end_date := Null;
    p_renew_in_rec.p_duration := Null;
    p_renew_in_Rec.p_uom_code := Null;
  End If; -- end perpetual flag = OKC_API.G_FALSE

    IF (l_debug = 'Y') THEN
       okc_debug.log('11300:  Leaving set_attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

  Return (l_return_status);


EXCEPTION
 when others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('11400: Exiting set_attributes:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

   return (l_return_status);
END Set_Attributes;
BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('11500: Entered Create_Renewed_Contract', 2);
    END IF;

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

   -- get the renew type defined for the rule. If not passed in as parameter already
   -- get it from the rules table
--/Rules migration/
--For oko/okc contracts use rules, for other contracts use rules colunns
   open cur_header;
   fetch cur_header into cur_header_rec;
   close cur_header;

   If cur_header_rec.application_id in (510,871) then

     open cur_rules(p_renew_in_parameters_rec.p_contract_id);
     fetch cur_rules into l_ren_type, l_ultimate_end_date;
     close cur_rules;

   Else
	l_ren_type          := cur_header_rec.renewal_type_code;
	l_ultimate_end_date :=  cur_header_rec.renewal_end_date;
   End If;
--

   IF p_ren_type Is Not Null And
      p_ren_type <> OKC_API.G_MISS_CHAR then
     l_ren_type := p_ren_type;
   END IF;
   IF (l_debug = 'Y') THEN
      okc_debug.log('11600: l_ren_type - ' || l_ren_type);
   END IF;

   --Renew is not allowed when renew_type is DNR
  If l_ren_type = 'DNR' then
    OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKC_RENEW_NOT_ALLOWED');
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

   -- validate the contract to be renewed
   IF (l_debug = 'Y') THEN
      okc_debug.log('11700: Before validate');
   END IF;
   validate(p_api_version              => 1,
            p_init_msg_list            => 'F',
            x_return_status            =>l_return_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data,
            p_renew_in_parameters_rec  => p_renew_in_parameters_rec,
	    p_renewal_called_from_ui => p_renewal_called_from_ui);
   IF (l_debug = 'Y') THEN
      okc_debug.log('11800: After validate');
   END IF;


  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;

   l_return_status := set_attributes(l_renew_in_parameters_rec);

 	   IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

--/Rules migration/ use cur_header_rec
    /*open cur_org;
      fetch cur_org into r_org,r_inv_org;
      close cur_org;*/

     r_org     := cur_header_rec.authoring_org_id;
	r_inv_org := cur_header_rec.inv_organization_id;
----

     IF (l_debug = 'Y') THEN
        okc_debug.log('119900: Before copy_contract');
     END IF;
     okc_copy_contract_pub.copy_contract(
	                  p_api_version              => 1,
			        p_init_msg_list            => 'F',
			        x_return_status            => l_return_status,
			        x_msg_count                => x_msg_count,
			        x_msg_data                 => x_msg_data,
				p_commit                   => 'F',
			        p_chr_id                   => l_renew_in_parameters_rec.p_contract_id,
			        p_contract_number          => l_renew_in_parameters_rec.p_new_contract_number,
                       p_contract_number_modifier => l_renew_in_PARAMETERs_rec.p_new_contract_modifier,
                       p_to_template_yn           => 'N',
                       p_renew_ref_yn             => 'Y',
				   --san comment dbms - take out the following 2 paramater
                       p_override_org             => 'Y',
                       p_copy_lines_yn             => 'Y',
				   --san comment dbms - take out the above 2 paramater
			        x_chr_id                   => x_contract_id);

     IF (l_debug = 'Y') THEN
        okc_debug.log('12000: After copy_contract');
     END IF;

         IF l_return_status = 'W' then
		  x_return_status := 'W';
         END IF;
     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

--update the start and end dates for the header and lines in the renew copy
     IF (l_debug = 'Y') THEN
        okc_debug.log('12100: Before update_renewal_dates');
     END IF;
    update_renewal_dates(p_api_version     	=> 1,
                    p_init_msg_list   	=> OKC_API.G_FALSE,
                    x_return_status   	=> l_return_status,
                    x_msg_count       	=> x_msg_count,
                    x_msg_data        	=> x_msg_data,
                    p_chr_id          	=> x_contract_id,
				p_parent_new_st_dt  =>  l_renew_in_parameters_rec.p_start_date,
			     p_parent_new_end_dt =>  l_renew_in_parameters_rec.p_end_date,
				p_parent_old_st_dt  =>  l_renew_in_parameters_rec.p_orig_start_date);

     IF (l_debug = 'Y') THEN
        okc_debug.log('12200: After update_renewal_dates');
     END IF;


     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


		 --update date_active and date_inactive in the condition headers for the renew copy

     IF (l_debug = 'Y') THEN
        okc_debug.log('123300: Before update_condition_headers');
     END IF;
	update_condition_headers (p_api_version     	=> 1,
                               p_init_msg_list   	=> OKC_API.G_FALSE,
                               x_return_status   	=> l_return_status,
                               x_msg_count       	=> x_msg_count,
                               x_msg_data        	=> x_msg_data,
                               p_chr_id          	=> x_contract_id,
			                p_new_start_date   => l_renew_in_parameters_rec.p_start_date,
			                p_new_end_date     => l_renew_in_parameters_rec.p_end_date,
			                p_orig_start_date  => l_renew_in_parameters_rec.p_orig_start_date,
					      p_orig_end_date    => l_renew_in_parameters_rec.p_orig_end_date);

     IF (l_debug = 'Y') THEN
        okc_debug.log('12400: After update_condition_headers');
     END IF;

	IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

  --update the old contract - update date_renewed and links to renew copy

     IF (l_debug = 'Y') THEN
        okc_debug.log('12500: Before update_old_contract');
     END IF;
	update_old_contract(p_api_version     	=> 1,
                                   p_init_msg_list   	=> OKC_API.G_FALSE,
                                   x_return_status   	=> l_return_status,
                                   x_msg_count       	=> x_msg_count,
                                   x_msg_data        	=> x_msg_data,
                                   p_new_header       	=> x_contract_id ,
                                   p_chr_id          	=> l_renew_in_parameters_rec.p_contract_id );

     IF (l_debug = 'Y') THEN
        okc_debug.log('12600: After update_old_contract');
     END IF;

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


	-- If this contract is being renewed from Quote, then update
	-- the contrcat with Quote information( like price, Ship-to etc.)
	-- The p_context is not null then this contract is being renewed
	-- by quote, so call the integration API that will update K with
	-- quote information.

	IF ( p_renew_in_parameters_rec.p_context IS NOT NULL
		AND
		p_renew_in_parameters_rec.p_context <>  OKC_API.G_MISS_CHAR ) THEN
        IF (l_debug = 'Y') THEN
           okc_debug.log('12700: Before create_k_from_q');
        END IF;
	   okc_oc_int_qtk_pvt.create_k_from_q(x_return_status => l_return_status
                                   ,p_context       => p_renew_in_parameters_rec.p_context
                                   ,p_chr_id        => x_contract_id);


        IF (l_debug = 'Y') THEN
           okc_debug.log('12800: After create_k_from_q');
        END IF;
        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

	END IF;
	x_renew_in_parameters_rec:=l_renew_in_parameters_rec;
     g_cached_chr_id     := x_contract_id;
--san comment remove later from here

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   --dbms_output.put_line('renew(-)');

    IF (l_debug = 'Y') THEN
       okc_debug.log('12900:  Leaving Create_Renewed_Contract', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION

WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13000: Exiting Create_Renewed_Contract:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('13100: Exiting Create_Renewed_Contract:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('13200: Exiting Create_Renewed_Contract:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Create_Renewed_Contract;

------------------------------------------------------------------------------
-- This procedure updates Date_Renewed field in headers and lines table
-- The Date_Renewed field for a line is updated when the Date_Renewed field
-- of all its sublines is not null and is updated by the maximum Date_Renewed
-- of all its sublines. True for all the levels. The contract header
-- Date_Renewed is updated when all it's top lines Date_Renewed is not null
-- and is updated by by the maximum Date_Renewed of all the top lines
------------------------------------------------------------------------------

Procedure Update_Parents_Date_Renewed( p_api_version        IN  NUMBER,
                                       p_init_msg_list      IN  VARCHAR2 ,
                                       x_return_status      OUT NOCOPY VARCHAR2,
                                       x_msg_count          OUT NOCOPY NUMBER,
                                       x_msg_data           OUT NOCOPY VARCHAR2,
                                       p_chr_id             IN NUMBER
                                     ) is
	l_top_count		NUMBER;
     l_invalid_chr_id    NUMBER;
	l_cle_id_ascendant	NUMBER;
     l_level			NUMBER;
	l_line_count		NUMBER;
	l_date_count		NUMBER;
     l_top_date_count	NUMBER;
	l_no_lines_count	NUMBER;
     Contract_Not_Found  EXCEPTION;
     l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name constant VARCHAR2(30) := 'Update_Parents_Date_Renewed';

	-- To get the distinct cle_id_ascendant for that particular level
 	CURSOR ancestry_cle_id( l_level NUMBER) IS
                    SELECT distinct(cle_id_ascendant)
                    FROM OKC_UPD_REN_TEMP
                    WHERE level_sequence = l_level;
Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_RENEW_PVT');
       okc_debug.log('13300: Entered Update_Parents_Date_Renewed', 2);
    END IF;

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
      -- Raising an exception when the contract header id is invalid
      select count(*) into l_invalid_chr_id
      from okc_k_headers_b
      where id = p_chr_id;

      if (l_invalid_chr_id = 0) Then
         RAISE Contract_Not_Found;
      end if;

      -- Inserting into temporary table
     IF (l_debug = 'Y') THEN
        okc_debug.log('13400: Before Insert Into OKC_UPD_REN_TEMP');
     END IF;
  	insert into OKC_UPD_REN_TEMP(DNZ_CHR_ID,
                                      CLE_ID,
                                     CLE_ID_ASCENDANT,
                                     LEVEL_SEQUENCE)
        select line.dnz_chr_id, ans.cle_id,
                                   ans.cle_id_ascendant, ans.level_sequence
  	from okc_k_lines_b line, okc_ancestrys ans
  	where line.id = ans.cle_id
    	  and line.dnz_chr_id = p_chr_id;

     -- To check whether any sublines are present
	select count(*) into l_top_count
	from okc_k_lines_b line, okc_ancestrys ans
  	where line.id = ans.cle_id
    	   and line.dnz_chr_id = p_chr_id;
     -- If sublines are present
              If l_top_count > 0 Then
		    -- Get the maximum level sequence
                  select MAX(level_sequence) into l_level
                  from OKC_UPD_REN_TEMP
                  where dnz_chr_id = p_chr_id;

                  While (l_level > 0)
                  Loop
                     open ancestry_cle_id(l_level);
                     Loop
				 -- To get the cle_id_ascendant
                          fetch ancestry_cle_id into l_cle_id_ascendant;
                          exit when ancestry_cle_id%NOTFOUND;
                     -- To check whether any sublines are present for this line
                          select count(*) into l_line_count
                          from okc_k_lines_b
                          where cle_id = l_cle_id_ascendant;

                          If l_line_count > 0 Then
                     -- To check the Date_Renewed field for all sublines
                             select count(*) into l_date_count
	                        from okc_k_lines_b
                             where cle_id = l_cle_id_ascendant
                                and date_renewed IS NULL;
                     -- If Date_Renewed is not null for all the sublines
                             If l_date_count = 0 Then
					    -- Update Date_Renewed field of parent line
                               update okc_k_lines_b
                               set date_renewed = ( select MAX(date_renewed )
                                                    from okc_k_lines_b
                                                    where cle_id = l_cle_id_ascendant )
                               where id = l_cle_id_ascendant;
                             End If;
                          End If;
                      End Loop;
				  -- Go to next level
                      l_level := l_level - 1;
 	                 close ancestry_cle_id;
                   End Loop;
               End If;

               -- To check whether the header has any top line
			select count(*) into l_no_lines_count
			from okc_k_lines_b
			where chr_id = p_chr_id;
			-- If header has a top line
			If l_no_lines_count > 0 Then
			-- To check the Date_Renewed field for all top lines
                  select count(*) into l_top_date_count
                  from okc_k_lines_b
                  where chr_id = p_chr_id
                    and date_renewed IS NULL;

                  -- If Date_Renewed is not null for all the top lines
                  If l_top_date_count = 0 Then
			   -- Update Date_Renewed field of contract header
                     update okc_k_headers_b
	  	           set date_renewed = ( select MAX(date_renewed)
			                           from okc_k_lines_b
			               	       where chr_id = p_chr_id )
                     where id = p_chr_id;
                  End If;
               End If;

IF (l_debug = 'Y') THEN
   okc_debug.log('13500:  Leaving Update_Parents_Date_Renewed', 2);
   okc_debug.Reset_Indentation;
END IF;
EXCEPTION
WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13600: Exiting Update_Parents_Date_Renewed:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
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
       okc_debug.log('13700: Exiting Update_Parents_Date_Renewed:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');

WHEN Contract_Not_Found THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13800: Exiting Update_Parents_Date_Renewed:Contract_Not_Found Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.set_message(G_APP_NAME, 'OKC_CONTRACT_NOT_FOUND');

WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13900: Exiting Update_Parents_Date_Renewed:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

 x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');

End Update_Parents_Date_Renewed;

/* Added the following function for bugfix 2093117 */

FUNCTION is_already_not_renewed(p_chr_id IN NUMBER, p_contract_number IN VARCHAR2, x_msg_name OUT NOCOPY VARCHAR2, p_renewal_called_from_ui IN VARCHAR2) RETURN VARCHAR2 IS
  Cursor cur_opn(p_chr_id number) is
   SELECT a.subject_chr_id,
   		a.process_flag  -- bugfix 2952330, selecting Process_flag to check the value 'A'
    FROM okc_operation_lines a,okc_operation_instances  b, okc_class_operations c
    where a.object_chr_id=p_chr_id and
		c.id=b.cop_id and
		c.opn_code in ('RENEWAL', 'REN_CON')
		and b.id=a.oie_id and
--                a.active_yn='Y' and  /* Commented out to fix the bug 2108667 */
                a.subject_cle_id is null and
		a.object_cle_id is null
    order by a.active_yn desc,a.process_flag desc; /* Added this order by to get the 'Entered' contract
                                  first so that correct message (OKC_RENCOPY_ENTERED)
                                  can be given from the logic below, otherwise
                                  the cusrsor will fetch the 'Cancelled' contarct
                                  and the wrong message OKC_SHOULD_NOT_COME will
                                  be displayed.  */

  Cursor cur_ren(p_chr_id number) is
   SELECT CONTRACT_NUMBER,CONTRACT_NUMBER_MODIFIER,ste_code
    FROM okc_k_headers_b k,okc_statuses_b  s
    where k.id=p_chr_id and k.sts_code=s.code;

 k_ren_rec  cur_ren%rowtype;
 l_id number:=OKC_API.G_MISS_NUM;
 l_process_flag varchar2(1):=OKC_API.G_MISS_CHAR;
 l_k varchar2(250):=' ';
 l_already_renewed varchar2(1) := OKC_API.G_FALSE;

BEGIN
     x_msg_name := 'O'; -- Bug 3386577 Assigning some intial value
     open cur_opn(p_chr_id);
     fetch cur_opn into l_id,l_process_flag;
        IF cur_opn%NOTFOUND THEN
	      close cur_opn;
	      RETURN OKC_API.G_TRUE;
        END IF;
	close cur_opn;

     -- Bug 3560988 If the renewal is called from event
     -- then check if the contract has been renewed atleast once
     If p_renewal_called_from_ui = 'N' then
      For k_cur_opn_rec in cur_opn(p_chr_id)
      Loop
       if k_cur_opn_rec.process_flag = 'P' then
        l_already_renewed := OKC_API.G_TRUE;
        l_id := k_cur_opn_rec.subject_chr_id;
        exit;
       End if;
      End Loop;
     End if;


     /* Bugfix 2952330, if Process_Flag is 'A'(OKS requirement), the renewal continues */
     -- Bug 3560988 Added l_already_renewed to the If clause condition
     if l_process_flag = 'A' and l_already_renewed <> OKC_API.G_TRUE then
	   RETURN OKC_API.G_TRUE;
     end if;
     /* End bugfix 2952330 */

	If l_id <> OKC_API.G_MISS_NUM then
           open cur_ren(l_id);
	   --san rencol
           --open cur_ren(k_header_rec.chr_id_renewed_to);
	   fetch cur_ren into k_ren_rec;
	   If cur_ren%NOTFOUND then
              OKC_API.set_message( p_app_name      => g_app_name,
                                   p_msg_name      =>'OKC_RENEWED_CONTRACT',
                                   p_token1        => 'NUMBER',
                                   p_token1_value  => p_contract_number );

	      close cur_ren;
              RAISE g_exception_halt_validation;
           END IF;
	   close cur_ren;
           l_k := k_ren_rec.contract_number;
	   IF k_ren_rec.contract_number_modifier is not null then
               l_k := l_k ||' '|| k_ren_rec.contract_number_modifier;
           END IF;
           If k_ren_rec.ste_code = 'ENTERED' then
              OKC_API.set_message( p_app_name      => g_app_name,
                                   p_msg_name      =>'OKC_RENCOPY_ENTERED',
                                   p_token1        => 'NUMBER',
                                   p_token1_value  => p_contract_number,
                                   p_token2        =>'RENCOPY',
                                   -- p_token2_value  => k_ren_rec.contract_number );
                                   p_token2_value  => l_k );
           /* The following ELSIF for CANCELLED is added to display the correct
              message in the log file when the Renew is run from SRS and the
              contract has already been renewed more than once. Before this code,
              OKC_SHOULD_NOT_COME was being displayed which was not correct */
           ELSIF k_ren_rec.ste_code = 'CANCELLED' then
              OKC_API.set_message( p_app_name      => g_app_name,
                                   p_msg_name      =>'OKC_ALREADY_NOT_RENEWED');
	      x_msg_name := 'C'; -- Cancelled --Bug 3386577
           ELSIF k_ren_rec.ste_code not in ('ENTERED','CANCELLED') then
                OKC_API.set_message( p_app_name      => g_app_name,
                              p_msg_name      =>'OKC_RENCOPY_APPROVE',
                              p_token1        => 'NUMBER',
                              p_token1_value  => p_contract_number,
                              p_token2        =>'RENCOPY',
                              p_token2_value  => l_k );
	   ELSE
                OKC_API.set_message( p_app_name      => g_app_name,
                              p_msg_name      =>'OKC_SHOULD_NOT_COME');
	   END IF; --ste_code
        ELSE
            OKC_API.set_message( p_app_name      => g_app_name,
                                 p_msg_name      =>'OKC_RENEWED_CONTRACT',
                                 p_token1        => 'XXXXXX',
                                 p_token1_value  => p_contract_number );

           RAISE g_exception_halt_validation;
        END IF; --l_id
        RETURN OKC_API.G_FALSE;

END is_already_not_renewed;

END OKC_RENEW_PVT;

/
