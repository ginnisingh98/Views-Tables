--------------------------------------------------------
--  DDL for Package Body OKS_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_DRT_PKG" AS
 /* $Header: oksdrtapib.pls 120.0.12010000.6 2018/07/17 09:55:07 skuchima noship $ */

  g_debug         CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_pkg_name      CONSTANT VARCHAR2(30) := 'OKS_DRT_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'oks.plsql.' || g_pkg_name || '.';

 procedure print_log(p_module varchar2, p_message varchar2) is
   begin
       if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
           if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
               fnd_log.string(log_level => fnd_log.level_statement,
                               module    => p_module,
                               message   => p_message);
           end if;
       end if;
   end;
  -- DRC function for person type : HR
  -- Does validation if passed in HR person can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error

    PROCEDURE oks_hr_drc (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy PER_DRT_PKG.RESULT_TBL_TYPE
    ) IS

    l_cnt      NUMBER       := 0;
    l_cnt1      NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'oks_hr_drc';

    BEGIN
    print_log( g_module_prefix || l_api_name, 'Start');
    print_log( g_module_prefix || l_api_name, ' Check for user in Service Contracts');

    select count(*)
    into   l_cnt
    FROM okc_contacts okc,okc_k_headers_all_b okh,okx_salesreps_v okx,okc_statuses_b sts
    WHERE okc.dnz_chr_id=okh.id AND
     okc.CRO_CODE='SALESPERSON' AND okc.object1_id1=to_char(okx.id1)
      AND okc.object1_id2=okx.id2 AND okx.person_id=p_person_id AND
     okh.sts_code = sts.code AND ste_code NOT IN ('TERMINATED','EXPIRED')  ;

    print_log( g_module_prefix || l_api_name, ' Count for user in Service Contracts :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'E',
            msgcode       => 'OKS_DRT_K_EXIST_FOR_USER',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


    SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKS_SALESPERSON_ID'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 515
	AND v.profile_option_value  in (SELECT to_char(id1) FROM okx_salesreps_v WHERE person_id=p_person_id )
  AND ROWNUM=1;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKS_SALESPERSON_ID reference :'||l_cnt);


    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'E',
            msgcode       => 'OKS_DRT_SALESPERSON_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;

    -- if no warning/errors so far, record success to process_tbl
     IF ( result_tbl.count < 1 ) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'S',
            msgcode       => NULL,
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
     END IF;

     print_log( g_module_prefix || l_api_name, 'End');
EXCEPTION
    WHEN OTHERS THEN
        IF    ( g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level )  THEN
            fnd_log.string(
                fnd_log.level_procedure,
                g_module_prefix || l_api_name,
                'Exception : sqlcode :'
                 || sqlcode
                 || ' Error Message : '
                 || sqlerrm
            );
        END IF;

        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'E',
            msgcode       => 'OKS_DRT_DRC_UNEXPECTED',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );

    END oks_hr_drc;


  -- DRC function for person type : TCA
  -- Does validation if passed in TCA Party ID can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error

    PROCEDURE oks_tca_drc (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy PER_DRT_PKG.RESULT_TBL_TYPE
    ) IS

      l_cnt      NUMBER       := 0;
      l_api_name VARCHAR2(30) := 'oks_tca_drc';
      l_cnt1      NUMBER       := 0;
      l_c_cnt     NUMBER      :=0;
      l_s_cnt     NUMBER      :=0;
      l_p_cnt     NUMBER       :=0;
    BEGIN

    print_log( g_module_prefix || l_api_name, 'Start');
    print_log( g_module_prefix || l_api_name, ' Check for contracts with Quote to Contact ');

    select count(*)
    into l_cnt
    FROM oks_k_headers_b oks,okc_k_headers_all_b okh,okx_cust_contacts_v okx,okc_statuses_b sts WHERE
        oks.quote_to_contact_id=okx.id1
        AND oks.chr_id=okh.id
        AND okh.sts_code=sts.code
        AND sts.ste_code = 'ENTERED'
        AND okx.person_party_id=p_person_id;


    print_log( g_module_prefix || l_api_name, ' Count for contracts with Quote to Contact :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'TCA',
            status        => 'E',
            msgcode       => 'OKS_DRT_Q_CONTACT_PEND',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;

print_log( g_module_prefix || l_api_name, ' Check for contracts with customer or Subscriber ');

    select count(*)
    into l_cnt1
    FROM okc_k_party_roles_b okc,hz_parties hz,okc_k_headers_all_b okh,okc_statuses_b sts
   WHERE okc.rle_code IN ('SUBSCRIBER','CUSTOMER')
     AND OKC.OBJECT1_ID1   = to_char(HZ.PARTY_ID)
     AND hz.party_id=p_person_id
    AND hz.party_type IN ('PERSON')
    AND okc.dnz_chr_id=okh.id
    AND okh.sts_code=sts.code
    AND sts.ste_code NOT IN ('TERMINATED','EXPIRED');

    print_log( g_module_prefix || l_api_name, ' Count for contracts with customer or subscriber :'||l_cnt1);

    IF(l_cnt1                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'TCA',
            status        => 'E',
            msgcode       => 'OKS_DRT_CUSTOMER_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;

/*skuchima bug */

print_log( g_module_prefix || l_api_name, ' Check for contracts with Party as Covered Level ');

  SELECT Count(*) INTO l_p_cnt
 FROM okc_k_items oki,okc_k_lines_b okl,hz_parties hz,okc_statuses_b sts
    WHERE oki.object1_id1=to_char(hz.party_id)
    AND oki.JTOT_OBJECT1_CODE='OKX_PARTY'
    AND hz.party_type IN ('PERSON')
    AND oki.cle_id=okl.id
    AND okl.sts_code=sts.code
    AND sts.ste_code NOT IN ('TERMINATED','EXPIRED')
    AND hz.party_id=p_person_id;

    print_log( g_module_prefix || l_api_name, ' Count for contracts with Party as Covered Level :'||l_p_cnt);

    IF(l_p_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'TCA',
            status        => 'E',
            msgcode       => 'OKS_DRT_COVER_PARTY_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;

print_log( g_module_prefix || l_api_name, ' Check for contracts with Customer as Covered Level ');

       SELECT Count(*) INTO l_c_cnt
       FROM okc_k_items oki,okc_k_lines_b okl,hz_parties hz,okc_statuses_b sts ,HZ_CUST_ACCOUNTS_all hzc
    WHERE oki.object1_id1=to_char(hzc.cust_account_id)
    AND oki.JTOT_OBJECT1_CODE='OKX_CUSTACCT'
    AND hz.party_type IN ('PERSON')
    AND oki.cle_id=okl.id
    AND okl.sts_code=sts.code
    AND sts.ste_code NOT IN ('TERMINATED','EXPIRED')
    AND hzc.party_id=hz.party_id
    AND hz.party_id=p_person_id;


    print_log( g_module_prefix || l_api_name, ' Count for contracts with customer as Covered Level :'||l_c_cnt);

    IF(l_c_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'TCA',
            status        => 'E',
            msgcode       => 'OKS_DRT_COVER_CUST_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


print_log( g_module_prefix || l_api_name, ' Check for contracts with Site as Covered Level ');

    SELECT Count(*) INTO l_s_cnt
     FROM okc_k_items oki,okc_k_lines_b okl,hz_parties hz,okc_statuses_b sts ,HZ_PARTY_SITES hps
    WHERE oki.object1_id1=to_char(hps.party_site_id)
    AND oki.JTOT_OBJECT1_CODE='OKX_PARTYSITE'
    AND hz.party_type IN ('PERSON')
    AND oki.cle_id=okl.id
    AND okl.sts_code=sts.code
    AND sts.ste_code NOT IN ('TERMINATED','EXPIRED')
    AND hps.party_id=hz.party_id
    AND hz.party_id=p_person_id;


    print_log( g_module_prefix || l_api_name, ' Count for contracts with Site as Covered Level :'||l_s_cnt);

    IF(l_cnt1                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'TCA',
            status        => 'E',
            msgcode       => 'OKS_DRT_COVER_SITE_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;

    -- if no warning/errors so far, record success to process_tbl
     IF ( result_tbl.count < 1 ) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'TCA',
            status        => 'S',
            msgcode       => NULL,
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
     END IF;

     print_log( g_module_prefix || l_api_name, 'End');

EXCEPTION
    WHEN OTHERS THEN
        IF   ( g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level )   THEN
            fnd_log.string(
                fnd_log.level_procedure,
                g_module_prefix || l_api_name,
                'Exception : sqlcode :'
                 || sqlcode
                 || ' Error Message : '
                 || sqlerrm
            );
        END IF;

        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'TCA',
            status        => 'E',
            msgcode       => 'OKS_DRT_DRC_UNEXPECTED',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END oks_tca_drc;

  -- DRC function for person type : FND
  -- Does validation if passed in FND User can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error

    PROCEDURE oks_fnd_drc (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy PER_DRT_PKG.RESULT_TBL_TYPE
    ) IS

      l_cnt      NUMBER       := 0;
      l_api_name VARCHAR2(30) := 'oks_fnd_drc';
      l_user_name  VARCHAR2(320);
    BEGIN

    print_log( g_module_prefix || l_api_name, 'Start');
    print_log( g_module_prefix || l_api_name, ' Check for profiles ');

begin
SELECT user_name
        INTO l_user_name
        from fnd_user
        WHERE user_id =   p_person_id;
exception
when others then
 l_user_name:=null;
end;
    print_log( g_module_prefix || l_api_name, ' l_user_name '||l_user_name);

	  SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKS_INTEGRATION_NOTIFY_TO'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 515
	AND v.profile_option_value  = l_user_name
  AND ROWNUM=1;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKS_INTEGRATION_NOTIFY_TO reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_INT_NOTIFY_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


	  SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKS_SETUP_ADMIN_ID'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 515
	AND v.profile_option_value  = to_char(p_person_id)
  AND ROWNUM=1;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKS_SETUP_ADMIN_ID reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_SETUP_ADMIN_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


	  SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKS_CONTRACT_ADMIN_ID'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 515
	AND v.profile_option_value  = to_char(p_person_id)
  AND ROWNUM=1;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKS_CONTRACT_ADMIN_ID reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_K_ADMIN_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


	  SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKS_TERR_ADMIN_ID'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 515
	AND v.profile_option_value  = to_char(p_person_id)
  AND ROWNUM=1;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKS_TERR_ADMIN_ID reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_TERR_ADMIN_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


	  SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKS_SERVICE_REQUEST_CREATOR'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 515
	AND v.profile_option_value  = l_user_name
  AND ROWNUM=1;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKS_SERVICE_REQUEST_CREATOR reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_SR_CREAT_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


	  SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKC_K_APPROVER'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 510
	AND v.profile_option_value  = l_user_name
  AND ROWNUM=1;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKC_K_APPROVER reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_K_APPROV_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;



	  SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKC_CR_APPROVER'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 510
	AND v.profile_option_value  = l_user_name
  AND ROWNUM=1;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKC_CR_APPROVER reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_CR_APPR_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;

SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKC_E_RECIPIENT'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 510
	AND v.profile_option_value  in (SELECT to_char(id1) FROM okx_resources_v WHERE user_id=p_person_id )
  AND ROWNUM=1;

    print_log( g_module_prefix || l_api_name, ' Count for profile OKC_E_RECIPIENT reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_E_RECIP_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


	  SELECT COUNT(*) into l_cnt
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'OKC_S_RECIPIENT'
	AND p.profile_option_id     = v.profile_option_id
  AND V.APPLICATION_ID = 510
	AND v.profile_option_value  in  (SELECT to_char(id1) FROM okx_resources_v WHERE user_id=p_person_id )
  AND ROWNUM=1 ;


    print_log( g_module_prefix || l_api_name, ' Count for profile OKC_S_RECIPIENT reference :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_S_RECIP_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;



    SELECT Count(*) INTO l_cnt FROM oks_k_defaults WHERE user_id=p_person_id;

    print_log( g_module_prefix || l_api_name, ' Count for help desk reference in GCD :'||l_cnt);

    IF(l_cnt                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_HELP_DESK_EXIST',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END IF;


    -- if no warning/errors so far, record success to process_tbl
     IF ( result_tbl.count < 1 ) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'S',
            msgcode       => NULL,
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
     END IF;

     print_log( g_module_prefix || l_api_name, 'End');

EXCEPTION
    WHEN OTHERS THEN
        IF   ( g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level )   THEN
            fnd_log.string(
                fnd_log.level_procedure,
                g_module_prefix || l_api_name,
                'Exception : sqlcode :'
                 || sqlcode
                 || ' Error Message : '
                 || sqlerrm
            );
        END IF;

        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'FND',
            status        => 'E',
            msgcode       => 'OKS_DRT_DRC_UNEXPECTED',
            msgaplid      => 515,
            result_tbl    => result_tbl
        );
    END oks_fnd_drc;


    -- Post Processing function to handle attribute masking for TCA Person

  PROCEDURE oks_tca_pre(
      person_id IN NUMBER )
  IS
    l_api_name  VARCHAR2(30) := 'oks_tca_pre';
    p_person_id NUMBER       := person_id;

    CURSOR c_party_csr is
      SELECT oktl.id,oktl.language,oktl.invoice_text,hz.party_number description
        FROM oks_k_lines_tL oktl,okc_k_lines_b okl,oks_k_lines_b oksl,okc_statuses_b sts,okc_k_items oki,hz_parties hz
          WHERE  oktl.id=oksl.id
          AND oksl.cle_id=okl.id
          AND okl.sts_code=sts.code
          AND  oki.object1_id1=to_char(hz.party_id)
          AND oki.JTOT_OBJECT1_CODE='OKX_PARTY'
          AND hz.party_type IN ('PERSON')
          AND oki.cle_id=okl.id
          AND sts.ste_code IN  ('TERMINATED','EXPIRED')
          AND hz.party_id=person_id;

 CURSOR c_cust_csr is
  SELECT oktl.id,oktl.language,oktl.invoice_text,hzc.account_number description FROM oks_k_lines_tL oktl,okc_k_lines_b okl,oks_k_lines_b oksl,okc_statuses_b sts,
          okc_k_items oki,HZ_CUST_ACCOUNTS_all hzc ,hz_parties hz
          WHERE  oktl.id=oksl.id
          AND oksl.cle_id=okl.id
          AND okl.sts_code=sts.code
          AND  oki.object1_id1=to_char(hzc.cust_account_id)
          AND oki.JTOT_OBJECT1_CODE='OKX_CUSTACCT'
          AND hzc.party_id=hz.party_id
          AND hz.party_type IN ('PERSON')
          AND oki.cle_id=okl.id
          AND sts.ste_code IN  ('TERMINATED','EXPIRED')
          AND hz.party_id=person_id;

    CURSOR c_site_csr is
          SELECT oktl.id,oktl.language,oktl.invoice_text,hps.description description FROM oks_k_lines_tL oktl,okc_k_lines_b okl,oks_k_lines_b oksl,okc_statuses_b sts,
          okc_k_items oki,okx_party_sites_v hps ,hz_parties hz
          WHERE  oktl.id=oksl.id
          AND oksl.cle_id=okl.id
          AND okl.sts_code=sts.code
          AND  oki.object1_id1=to_char(hps.id1)
          AND oki.JTOT_OBJECT1_CODE='OKX_PARTYSITE'
          AND hps.party_id=hz.party_id
          AND hz.party_type IN ('PERSON')
          AND oki.cle_id=okl.id
          AND sts.ste_code IN  ('TERMINATED','EXPIRED')
          AND hz.party_id=person_id;



  BEGIN
  print_log( g_module_prefix || l_api_name, 'Start');
  print_log( g_module_prefix || l_api_name, ' TCA Pre DRC ');

  FOR i IN c_party_csr LOOP
   UPDATE oks_k_lines_tl
   SET invoice_text=REPLACE(invoice_text,i.description)
   WHERE id=i.id
   AND LANGUAGE=i.LANGUAGE;


  END LOOP;

   print_log( g_module_prefix || l_api_name, ' TCA Pre c_party_csr ');

  FOR i IN c_cust_csr LOOP

  UPDATE oks_k_lines_tl
   SET invoice_text=REPLACE(invoice_text,i.description)
   WHERE id=i.id
   AND LANGUAGE=i.LANGUAGE;

  END LOOP;

   print_log( g_module_prefix || l_api_name, ' TCA Pre c_cust_csr ');

  FOR i IN c_site_csr LOOP

  UPDATE oks_k_lines_tl
   SET invoice_text=REPLACE(invoice_text,i.description)
   WHERE id=i.id
   AND LANGUAGE=i.LANGUAGE;

  END LOOP;

  print_log( g_module_prefix || l_api_name, ' TCA Post c_site_csr ');

 EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix ||
        l_api_name, 'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
    raise_application_error( -20001, 'Exception at ' || g_module_prefix ||
      l_api_name || ' : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);

  END OKS_TCA_Pre;

 END oks_drt_pkg;


/
