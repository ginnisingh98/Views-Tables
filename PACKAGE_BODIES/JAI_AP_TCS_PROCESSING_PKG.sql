--------------------------------------------------------
--  DDL for Package Body JAI_AP_TCS_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TCS_PROCESSING_PKG" AS
/* $Header: jai_ap_tcs_prc.plb 120.3.12010000.2 2009/07/14 10:51:15 vkaranam ship $ */
/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tcs_prc.plb

 Created By    : Balaji

 Created Date  : 30-jan-2007

 Bug           : 5631784

 Purpose       : Solution for TCS

 Called from   : Concurrent,
                 JAINTCSC -  India - Generate TCS Certificates

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date             Author and Details
 -------------------------------------------------------------------------------
 1         30-JAN-2007      bgowrava for forward porting bug#5631784 (4742259).
                            Created this package for generating TCS Certificates. This is called from
                            JAINTCSC concurrent. A new column regime_code is added to table jai_ap_tds_cert_nums
                            to store the regime_code. This will allow us to use the table for both TDS and
                            TCS. A migration script is prepared to populate the regime_code as TDS for all
                            existing records. Changes in package jai_ap_tds_processing_pkg are made accordingly.

2         14-05-2007		ssawant for bug 5879769,
				Objects was not compiling. so changes are done to make it compiling.

3.        22-06-2007        sacsethi for bug 6144923 File version - 120.2

                           Problem -  R12RUP03-ST1:REPORT NOT AVAILABLE-INDIA - GENERATE TCS CERTIFICATES

			   Solution - Insert Statement is changed jai_ap_tds_cert_nums , Column FIN_YR_CERT_ID
			              is added According to R12 standard.

4.   14-JUL-2009  vkaranam for bug#8679068 120.3.12000000.2
                  Issue:
		  TCS Certificates are generated without the TCS invoice is been paid and settled.
		  Fix:
		  TCS certificates will be generated only if the TCS invoice is been settled.
		  Changes:
		  Added jai_rgm_settlements.status='SETTLED'  condition in the cursor
 c_group_for_certificate.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files          Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
----------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------- */


---------------------------------------------------------------------------- */

/* ******************************  generate_tcs_certificates *****************************************  */
  PROCEDURE generate_tcs_certificates
  (
    errbuf                              out            nocopy    varchar2,
    retcode                             out            nocopy    varchar2,
    pd_rgm_from_date                    in             varchar2,
    pd_rgm_to_date                      in             varchar2,
    pv_org_tan_num                      in             varchar2,
    pn_tax_authority_id                 in             number    ,
    pn_tax_authority_site_id            in             number    default null,
    pn_customer_id                        in             number    default null,
    pn_customer_site_id                   in             number    default null
  )
  is
    cursor c_group_for_certificate
    (
      pd_rgm_from_date          date,
      pd_rgm_to_date            date,
      pv_org_tan_num            varchar2,
      pn_tax_authority_id       number,
      pn_tax_authority_site_id  number,
      pn_customer_id            number,
      pn_customer_site_id       number
    )
    is
    SELECT  jrr.fin_year,
            jrr.org_tan_no,
            jrr.organization_id,
            jrr.party_id,
            jrr.party_site_id,
            jrs.tax_authority_id,
            jrs.tax_authority_site_id
      FROM JAI_RGM_REFS_ALL    jrr,
           JAI_RGM_SETTLEMENTS jrs
     WHERE jrr.settlement_id = jrs.settlement_id
       AND jrr.source_document_date  BETWEEN  pd_rgm_from_date and  pd_rgm_to_date
       AND jrr.certificate_id        IS  NULL
       AND jrs.status='SETTLED' --added for bug#8679068
       AND jrs.tax_authority_id      = pn_tax_authority_id
       AND jrs.tax_authority_site_id = nvl(pn_tax_authority_site_id, tax_authority_site_id)
       AND jrr.party_type            = 'C'
       AND jrr.party_id              = nvl(pn_customer_id, party_id)
       AND jrr.party_site_id         = nvl(pn_customer_site_id, party_site_id)
       AND jrr.org_tan_no            = pv_org_tan_num
     GROUP BY jrr.fin_year,
              jrr.org_tan_no,
              jrr.organization_id,
              jrr.party_id,
              jrr.party_site_id,
              jrs.tax_authority_id,
              jrs.tax_authority_site_id;

    CURSOR c_jai_ap_tds_cert_nums(pv_org_tan_num VARCHAR2,
                                  pn_fin_year    NUMBER  ,
                                  pv_regime_code VARCHAR2)
    IS
		SELECT nvl(certificate_num, 0) + 1
			FROM jai_ap_tds_cert_nums
		 WHERE org_tan_num   =  pv_org_tan_num
			 AND fin_yr      =  pn_fin_year
			 AND REGIME_CODE   =  pv_regime_code;

    CURSOR c_get_certificate_id is
    SELECT jai_rgm_certificates_s.nextval
      FROM dual;

    CURSOR cur_regime_id(cp_regime_code VARCHAR2) IS
    SELECT regime_id
      FROM JAI_RGM_DEFINITIONS
     WHERE regime_code = cp_regime_code;

    ln_certificate_num         jai_ap_tds_cert_nums.certificate_num%type;
    ln_certificate_id          number;
    ln_regime_id               NUMBER;

    ln_program_id              number;
    ln_program_login_id        number;
    ln_program_application_id  number;
    ln_request_id              number;
    ln_user_id                 number(15);
    ln_last_update_login       number(15);
    ln_certificate_count       number;
    ld_from_date               date;
    ld_to_date                 date;

  begin
/*  */

    /* Get the statis fnd values for populating into the table */
    Fnd_File.put_line(Fnd_File.LOG, '** Start of procedure jai_ap_tcs_processing_pkg.generate_tcs_certificates **');

    ln_user_id                  :=   fnd_global.user_id           ;
    ln_last_update_login        :=   fnd_global.login_id          ;
    ln_program_id               :=   fnd_global.conc_program_id   ;
    ln_program_login_id         :=   fnd_global.conc_login_id     ;
    ln_program_application_id   :=   fnd_global.prog_appl_id      ;
    ln_request_id               :=   fnd_global.conc_request_id   ;
    ld_from_date                :=   fnd_date.canonical_to_date(pd_rgm_from_date);
    ld_to_date                  :=   fnd_date.canonical_to_date(pd_rgm_to_date) ;
    ln_certificate_count        :=   0 ;

    OPEN  cur_regime_id(jai_constants.tcs_regime);
    FETCH cur_regime_id INTO ln_regime_id;
    CLOSE cur_regime_id;

    /* Group for TCS Certificates */

    Fnd_File.put_line(Fnd_File.LOG, ' Generating Certificates ' );

    for cur_rec in
					c_group_for_certificate
					(
						ld_from_date          ,
						ld_to_date            ,
						pv_org_tan_num            ,
						pn_tax_authority_id       ,
						pn_tax_authority_site_id  ,
						pn_customer_id            ,
						pn_customer_site_id
					)
    loop

      /* Get certificate number */
      ln_certificate_num := null;
      OPEN  c_jai_ap_tds_cert_nums(pv_org_tan_num, cur_rec.fin_year,jai_constants.tcs_regime);
      FETCH c_jai_ap_tds_cert_nums into ln_certificate_num;
      CLOSE c_jai_ap_tds_cert_nums;

      IF ln_certificate_num IS NULL THEN
        ln_certificate_num := 1;
      END IF;

      OPEN  c_get_certificate_id;
      FETCH c_get_certificate_id INTO ln_certificate_id;
      CLOSE c_get_certificate_id;

      UPDATE jai_rgm_refs_all
         SET certificate_id    = ln_certificate_id
             , last_update_date  = sysdate
             , last_update_login = ln_last_update_login
      where  trx_ref_id in ( SELECT jrr.trx_ref_id
                               FROM jai_rgm_refs_all jrr,
                                    jai_rgm_settlements jrs
                              WHERE jrr.settlement_id         = jrs.settlement_id
                                AND jrr.source_document_date  BETWEEN  ld_from_date and  ld_to_date
                                AND jrr.certificate_id        IS  NULL
                                AND jrs.tax_authority_id      = cur_rec.tax_authority_id
                                AND jrs.tax_authority_site_id = cur_rec.tax_authority_site_id
                                AND jrr.party_type            = jai_constants.party_type_customer
                                AND jrr.party_id              = cur_rec.party_id
                                AND jrr.party_site_id         = cur_rec.party_site_id
                                AND jrr.org_tan_no            = cur_rec.org_tan_no
                                AND jrr.fin_year              = cur_rec.fin_year
                                AND jrr.organization_id       = cur_rec.organization_id);

      if sql%rowcount = 0 then
        goto continue_with_next_certificate;
      end if;

      Fnd_File.put_line(Fnd_File.LOG, 'Certificate Number : ' || ln_certificate_num);
      Fnd_File.put_line(Fnd_File.LOG, ' No of Records for the Certificate : ' || to_char(sql%rowcount) );
      ln_certificate_count := ln_certificate_count + 1;

      if ln_certificate_num = 1 then
        Fnd_File.put_line(Fnd_File.LOG, 'Created a certificate record in jai_ap_tds_cert_nums');
        insert into jai_ap_tds_cert_nums
        (
          FIN_YR_CERT_ID          ,   -- Date 22/06/2007 by sacsethi for bug 6144923
	  regime_code             ,
          org_tan_num             ,
          fin_yr                ,
          certificate_num         ,
          created_by              ,
          creation_date           ,
          last_updated_by         ,
          last_update_date        ,
          last_update_login
        )
        values
        (
          JAI_AP_TDS_CERT_NUMS_S.NEXTVAL , -- Date 22/06/2007 by sacsethi for bug 6144923
	  jai_constants.tcs_regime,
          pv_org_tan_num          ,
          cur_rec.fin_year        ,
          1                       ,
          ln_user_id              ,
          sysdate                 ,
          ln_user_id              ,
          sysdate                 ,
          ln_last_update_login
        );

      else


        Fnd_File.put_line(Fnd_File.LOG, 'Updated certificate number in jai_ap_tds_cert_nums');
        update jai_ap_tds_cert_nums
           set certificate_num = ln_certificate_num
         where org_tan_num     =  pv_org_tan_num
           and fin_yr        =  cur_rec.fin_year
           and regime_code     = jai_constants.tcs_regime;
      end if;

      /* insert into JAI_RGM_CERTIFICATES */
      Fnd_File.put_line(Fnd_File.LOG, 'Inserting record in JAI_RGM_CERTIFICATES with certificate_id : ' || to_char(ln_certificate_id));

      INSERT INTO
         jai_rgm_certificates( CERTIFICATE_ID        ,
                               CERTIFICATE_NUM       ,
			       CERTIFICATE_DATE      ,
			       PARTY_TYPE            ,
			       PARTY_ID              ,
			       PARTY_SITE_ID         ,
			       REGIME_ID             ,
			       TAX_AUTHORITY_ID      ,
				 TAX_AUTHORITY_SITE_ID ,
				 FROM_DATE             ,
				 TO_DATE               ,
				 PRINT_FLAG            ,
				 organization_id                ,
				 ISSUE_DATE            ,
				 FIN_YEAR              ,
				 ORG_TAN_NO            ,
				 PROGRAM_ID            ,
				 PROGRAM_LOGIN_ID      ,
				 PROGRAM_APPLICATION_ID,
				 REQUEST_ID            ,
				 OBJECT_VERSION_NUMBER ,
				 CREATION_DATE         ,
				 CREATED_BY            ,
				 LAST_UPDATE_DATE      ,
				 LAST_UPDATED_BY       ,
				 LAST_UPDATE_LOGIN     )
                       VALUES( ln_certificate_id     ,
                               ln_certificate_num    ,
                               trunc(sysdate)        ,
                               jai_constants.party_type_customer            ,
                               cur_rec.party_id			 ,
				cur_rec.party_site_id ,
				ln_regime_id,
				cur_rec.tax_authority_id			,
				cur_rec.tax_authority_site_id,
				ld_from_date             ,
				ld_to_date               ,
				NULL,
				cur_rec.organization_id               ,
				NULL                         ,
				cur_rec.fin_year             ,
				cur_rec.org_tan_no          ,
				ln_program_id                ,
				ln_program_login_id          ,
				ln_program_application_id    ,
				ln_request_id                ,
				NULL                         ,
				SYSDATE                      ,
				ln_user_id                   ,
				SYSDATE                      ,
				ln_user_id                   ,
				ln_last_update_login     );


      << continue_with_next_certificate >>
        null;

    end loop; /* c_group_for_certificate */


    <<exit_from_procedure>>
    Fnd_File.put_line(Fnd_File.LOG, 'No of Certificates Generated : ' || to_char(ln_certificate_count));
    Fnd_File.put_line(Fnd_File.LOG, '** Successful End of procedure jai_ap_tcs_processing_pkg.generate_tcs_certificates **');

    return;

exception
    when others then
      retcode := 2;
      errbuf := 'Error from jai_ap_tcs_processing_pkg.generate_tcs_certificates : ' || sqlerrm;
      Fnd_File.put_line(Fnd_File.LOG, 'Error End of procedure jai_ap_tcs_processing_pkg.process_tds_payments : ' || sqlerrm);

end generate_tcs_certificates;

/* ******************************  generate_tcs_certificates *****************************************  */

END jai_ap_tcs_processing_pkg;

/
