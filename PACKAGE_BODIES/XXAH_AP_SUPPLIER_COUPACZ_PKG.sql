--------------------------------------------------------
--  DDL for Package Body XXAH_AP_SUPPLIER_COUPACZ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_AP_SUPPLIER_COUPACZ_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPLIER_COUPACZ_PKG
   * DESCRIPTION       : PACKAGE BODY TO Coua CZ Supplier Bank Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY           Remarks
   * 04-DEC-2017        1.0       Sunil Thamke     Initial
   ****************************************************************************/
PROCEDURE P_MAIN (errbuf OUT VARCHAR2, retcode OUT NUMBER, p_rownum IN NUMBER)
IS
   g_request_id                    NUMBER       := fnd_global.conc_request_id;
   lv_supplier_status              VARCHAR2 (10);
   lv_territory                    VARCHAR2 (10);
   lv_vendor_rec                   ap_vendor_pub_pkg.r_vendor_rec_type;
   lv_vendor_site_rec              ap_vendor_pub_pkg.r_vendor_site_rec_type;
   lv_return_status                VARCHAR2 (10);
   lv_msg_count                    NUMBER;
   lv_msg_data                     VARCHAR2 (1000);
   lv_vendor_id                    NUMBER;
   lv_party_id                     NUMBER;
   lv_row_count                    NUMBER;
   l_row_count                       NUMBER;
   lv_output                       VARCHAR2 (8000);
   lv_api_msg                      VARCHAR2 (8000);
   v_msg_dummy                     NUMBER;
   lv_branch_error_msg             VARCHAR2 (200);
   x_vendor_id                     NUMBER;
   x_party_id                      NUMBER;
   x_vendor_site_id                NUMBER;
   x_party_site_id                 NUMBER;
   x_location_id                   NUMBER;
   l_party_site_id                 NUMBER;
   l_supp_party_id                 NUMBER;
   lv_bank_id                      NUMBER;
   lv_branch_id                    NUMBER;
   lv_bank_error_msg               VARCHAR2 (200);
   lv_bank_error_flag              VARCHAR2 (1);
   lv_account_id                   NUMBER;
   x_return_status                 VARCHAR2 (1);
   x_msg_count                     NUMBER;
   x_msg_data                      VARCHAR2 (8000); -- Modified size
   lv_vend_site_id                 NUMBER;
   lv_party_site_id                NUMBER;
   l_user_id                       NUMBER;
   l_resp_id                       NUMBER;
   l_appl_id                       NUMBER;
   ln_msg_index_out                NUMBER                             := NULL;
   l_inspection_required_flag      VARCHAR2 (1):=NULL;
   l_receipt_required_flag         VARCHAR2 (1):=NULL;
   l_api_error_flag                VARCHAR2 (1);
   l_supplier_exists_flag          VARCHAR2 (1);
   l_ss_exists_flag                VARCHAR2 (1);
   l_api_error_msg                 VARCHAR2 (4000);
   lv_branch_error_flag            VARCHAR2 (1);
   lv_acct_error_msg               VARCHAR2 (200);
   lv_acct_error_flag              VARCHAR2 (1);
   x_profile_id                    NUMBER;
   l_organization_rec              apps.hz_party_v2pub.organization_rec_type;
   l_party_rec                     apps.hz_party_v2pub.party_rec_type;
   l_party_object_version_number   NUMBER;
                      l_vendor_site_id NUMBER;
                      l_vendor_name   VARCHAR2(240);
                      l_vendor_site_name VARCHAR2(640);
                      l_term_id number;
                    l_pay_group_lookup_code VARCHAR2(50);
                    l_pay_group_code VARCHAR2(50);
                    l_po_match VARCHAR2(50);
                    x_supp_check VARCHAR2(1):=NULL;
                    l_paygroup_length number;
                    l_length_site_pay number;
                    l_leaf_commodity VARCHAR2(100);


   CURSOR c_create_vendor
   IS
      SELECT   *
          FROM XXAH_PS_EBS_COUPACZ_SUPP
         WHERE conversion_status='N'
         and rownum <= nvl(p_rownum, rownum)
         --and SUPPLIER_SEQ= '35602'
      ORDER BY supplier_name, supplier_site_name ,bank_priority DESC;


    CURSOR c_supplier_remit
    IS
      SELECT   xsb.*
          FROM XXAH_PS_EBS_COUPACZ_SUPP xsb, ap_suppliers asp
         WHERE upper(xsb.supplier_name)=upper(asp.vendor_name)
         AND xsb.conc_request_id = g_request_id
         AND conversion_status <> 'A'
         AND REMIT_SUPPLIER_NAME is not null
      ORDER BY xsb.supplier_name,xsb.supplier_site_name;

BEGIN
   fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );

                              SELECT MESSAGE_TEXT into x_supp_check FROM fnd_new_messages
                              WHERE message_name='XXAH_SUPPLIER_CHECK_MSG';
                               IF x_supp_check='Y' THEN

                              BEGIN
                              p_supplier_check(g_request_id);
                              EXCEPTION
                                WHEN OTHERS THEN
                                FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
                                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - p_supplier_check exc '||SQLCODE||' -ERROR- '||SQLERRM);
                                FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
                               END;
                             END IF;

   FOR r_create_vendor IN c_create_vendor
   LOOP
      lv_row_count := c_create_vendor%ROWCOUNT;
      EXIT WHEN c_create_vendor%NOTFOUND;
      lv_supplier_status := NULL;
      lv_territory := NULL;
      l_api_error_flag := NULL;
      l_supplier_exists_flag := 'N';
      l_ss_exists_flag := 'N';
      l_api_error_msg := NULL;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier Name => '||r_create_vendor.SUPPLIER_NAME||' Site => '||r_create_vendor.SUPPLIER_SITE_NAME);
                FND_FILE.PUT_LINE(FND_FILE.LOG,'SUPPLIER_SEQ => '||r_create_vendor.SUPPLIER_SEQ);
      lv_territory := r_create_vendor.iso_territory_code;

      update XXAH_PS_EBS_COUPACZ_SUPP
      set conc_request_id = g_request_id
      WHERE supplier_seq = r_create_vendor.supplier_seq;
      commit;
      l_pay_group_lookup_code := NULL;
      l_pay_group_code := NULL;
      l_po_match := NULL;

       begin
       select distinct payment_group_code, po_match into l_pay_group_code, l_po_match from  XXAH_PS_EBS_COUPACZ_SUPP
            where supplier_name = r_create_vendor.supplier_name
                    and purchasing_flag = 'Y'
                    and pay_site_flag = 'Y'
                    and primary_pay_site_flag = 'Y'
                    and conversion_status = 'N';
            EXCEPTION
            WHEN OTHERS THEN
            l_pay_group_code := NULL;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error at l_pay_group_code '||SQLCODE||' -ERROR- '||SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
        end;

        l_paygroup_length:=null;
        l_pay_group_lookup_code:=null;

                    if l_pay_group_code is not null then

                      select length(l_pay_group_code) into l_paygroup_length from dual;


                         if l_paygroup_length=1 then
                                l_pay_group_lookup_code := '0' || NVL (l_pay_group_code, 4);
                                else
                                l_pay_group_lookup_code := NVL (l_pay_group_code, '04');
                         end if;

                     else
                                l_pay_group_lookup_code := NVL (l_pay_group_code, '04');
                     end if;

  fnd_file.put_line (fnd_file.LOG,' l_pay_group_lookup_code => '||l_pay_group_lookup_code);
      --------------------------<Supplier Creation>---------------------------------
            --<Match Approval Level>--
      IF l_po_match        = '2-way match'
      THEN
         l_inspection_required_flag     := 'N';
         l_receipt_required_flag         := 'N';
      ELSIF l_po_match    = '3-way match'
      THEN
         l_inspection_required_flag     := 'N';
         l_receipt_required_flag         := 'Y';
      ELSIF l_po_match    = '4-way match'
      THEN
         l_inspection_required_flag        := 'Y';
         l_receipt_required_flag         := 'Y';
      ELSE
         l_inspection_required_flag     := NULL;
         l_receipt_required_flag         := NULL;
      END IF;

      --end if;



      --<Assingning Staging Table Data To Record Type>--
      lv_vendor_rec.vendor_name             := r_create_vendor.supplier_name;
      lv_vendor_rec.terms_name                 := r_create_vendor.payment_term;
      lv_vendor_rec.invoice_currency_code   := r_create_vendor.currency_code;   -- RFC- 027
      lv_vendor_rec.pay_group_lookup_code     := l_pay_group_lookup_code; --'0' || NVL (r_create_vendor.payment_group_code, 4);
      lv_vendor_rec.summary_flag             := 'N';
      lv_vendor_rec.enabled_flag             := 'Y';
      lv_vendor_rec.match_option             := 'P';
      lv_vendor_rec.tax_reference             := r_create_vendor.vat_registration_num;
      lv_vendor_rec.inspection_required_flag := l_inspection_required_flag;
      lv_vendor_rec.receipt_required_flag     := l_receipt_required_flag;
      lv_vendor_rec.sic_code                 := r_create_vendor.sic_code;
      --lv_vendor_rec.segment1        :=    XXAH_COUPA_SUPPLIER_SEQ.nextval ;
      --<API To Create Supplier>--
      lv_msg_count         := '';
      lv_return_status     := NULL;

      --<Supplier Exists?>--
      BEGIN
         lv_vendor_id := NULL;
         lv_party_id := NULL;
      --l_supplier_flag := NULL;
         SELECT vendor_id, party_id
           INTO lv_vendor_id, lv_party_id
           FROM ap_suppliers
          WHERE UPPER (TRIM (vendor_name)) =  UPPER (TRIM (r_create_vendor.supplier_name));
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
            lv_vendor_id := NULL;
      END;

      IF lv_vendor_id IS NULL
      THEN
         ap_vendor_pub_pkg.create_vendor
                                        (p_api_version        => 1,
                                         p_vendor_rec         => lv_vendor_rec,
                                         x_return_status      => lv_return_status,
                                         x_msg_count          => lv_msg_count,
                                         x_msg_data           => lv_msg_data,
                                         x_vendor_id          => lv_vendor_id,
                                         x_party_id           => lv_party_id
                                        );

         IF (lv_return_status <> fnd_api.g_ret_sts_success)
         THEN
            fnd_file.put_line (fnd_file.LOG,'Encountered ERROR in supplier creation!!!');
            fnd_file.put_line (fnd_file.LOG,'+--------------------------------------+');
            fnd_file.put_line (fnd_file.LOG, lv_msg_data);
            fnd_file.put_line (fnd_file.LOG, lv_msg_count);
            ln_msg_index_out     := NULL;
            lv_api_msg             := NULL;

            FOR i IN 1 .. lv_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => lv_msg_data,
                                p_encoded            => 'F',
                                p_msg_index_out      => ln_msg_index_out
                               );
               fnd_message.set_encoded (lv_msg_data);
               fnd_file.put_line (fnd_file.LOG,
                                     'Error at Supplier: '
                                  || i
                                  || ', '
                                  || lv_msg_data
                                 );
               lv_api_msg :=
                     lv_api_msg
                  || ' / '
                  || ('Msg' || TO_CHAR (i) || ': ' || SUBSTR(lv_msg_data,1,200));
            END LOOP;

            ROLLBACK;
            fnd_file.put_line
                           (fnd_file.LOG,'Supplier NOT Created! and rollback executed');
            fnd_file.put_line (fnd_file.LOG,'+--------------------------------------+');
            l_api_error_flag     := 'Y';
            l_api_error_msg     := 'CREATE_VENDOR : ' || lv_api_msg;
         ELSE
            IF lv_vendor_id IS NOT NULL
            THEN
               fnd_file.put_line (fnd_file.LOG, '--Supplier created');
            END IF;                             --IF (lv_return_status <> 'S')
         END IF;        --IF (lv_return_status <>  fnd_api.g_ret_sts_success )
      ELSE
         l_api_error_flag := 'Y';
         l_supplier_exists_flag := 'Y';
         l_api_error_msg := l_api_error_msg || '//Supplier Already Exists';
         fnd_file.put_line (fnd_file.LOG, '//Supplier Already Exists');
      END IF;                                 --  IF lv_vendor_id IS NULL THEN

      --IF l_supplier_flag is null THEN
      -----------------------<Supplier Creation END>---------------------------------
      -----------------------<Supplier Site Creation>--------------------------------
      BEGIN
         lv_vend_site_id := NULL;
         lv_party_site_id := NULL;
         fnd_file.put_line (fnd_file.LOG, '1');
         SELECT b.vendor_site_id, b.party_site_id
           INTO lv_vend_site_id, lv_party_site_id
           FROM ap_suppliers a, ap_supplier_sites_all b
          WHERE a.vendor_id = b.vendor_id
            AND TRIM (b.vendor_site_code) =
                                     TRIM (r_create_vendor.supplier_site_name)
            AND a.vendor_name = r_create_vendor.supplier_name;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
            lv_vend_site_id := NULL;
         WHEN TOO_MANY_ROWS
         THEN
            fnd_file.put_line (fnd_file.LOG,
                                  r_create_vendor.supplier_name
                               || ' // '
                               || r_create_vendor.supplier_site_name
                               || ' - '
                               || ' SUPPLIER SITE NAME Already Exists'
                              );
         WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG,
                                  'Error at SUPPLIER_SITE_NAME '
                               || SQLCODE
                               || ' - '
                               || SQLERRM
                              );
      END;
 fnd_file.put_line (fnd_file.LOG, '2');
      IF lv_vend_site_id IS NULL
      THEN
         lv_vendor_site_rec.vendor_id             := lv_vendor_id;
          fnd_file.put_line (fnd_file.LOG, '3');
          fnd_file.put_line (fnd_file.LOG, 'supplier_site_name '||to_char(r_create_vendor.supplier_site_name)||' '||length(r_create_vendor.supplier_site_name));
         lv_vendor_site_rec.vendor_site_code     := to_char(r_create_vendor.supplier_site_name);
          fnd_file.put_line (fnd_file.LOG, '4');
         lv_vendor_site_rec.org_id                 := r_create_vendor.operating_unit_id;
         lv_vendor_site_rec.country             := lv_territory;
         lv_vendor_site_rec.address_line1         := r_create_vendor.primary_address_line1;
         lv_vendor_site_rec.address_line2         := r_create_vendor.primary_address_line2;
         lv_vendor_site_rec.address_line3         := r_create_vendor.primary_address_line3;
         lv_vendor_site_rec.address_line4         := r_create_vendor.primary_address_line4;
         lv_vendor_site_rec.city                 := r_create_vendor.primary_city;
         lv_vendor_site_rec.zip                 := to_char(replace(r_create_vendor.primary_zip_code,'"',NULL));--r_create_vendor.primary_zip_code;
         lv_vendor_site_rec.country             := r_create_vendor.primary_country;
         lv_vendor_site_rec.county                 := r_create_vendor.primary_county;
         lv_vendor_site_rec.phone                 := r_create_vendor.secondary_phone;
         lv_vendor_site_rec.fax                 := r_create_vendor.primary_fax;
         lv_vendor_site_rec.purchasing_site_flag := r_create_vendor.purchasing_flag;
         lv_vendor_site_rec.pay_site_flag         := r_create_vendor.pay_site_flag;
         lv_vendor_site_rec.PRIMARY_PAY_SITE_FLAG    := r_create_vendor.primary_pay_site_flag;
         lv_vendor_site_rec.state                 := r_create_vendor.primary_state;--NVL (r_create_vendor.primary_state, 'NA');
         lv_vendor_site_rec.match_option         := 'P';
         lv_vendor_site_rec.email_address         := r_create_vendor.primary_email_address;
         lv_vendor_site_rec.vat_registration_num := r_create_vendor.vat_registration_num;
         IF r_create_vendor.payment_term is not null then
         lv_vendor_site_rec.terms_name := r_create_vendor.payment_term ;
         END IF;

         if r_create_vendor.payment_group_code IS NOT NULL THEN
         l_length_site_pay:=null;
            select length( r_create_vendor.payment_group_code) into l_length_site_pay from dual;
            IF   l_length_site_pay = 1 then
            lv_vendor_site_rec.pay_group_lookup_code :='0' || NVL (r_create_vendor.payment_group_code, 4);
            else
             lv_vendor_site_rec.pay_group_lookup_code :=NVL (r_create_vendor.payment_group_code, '04');
            end if;
             else
             lv_vendor_site_rec.pay_group_lookup_code :=NVL (r_create_vendor.payment_group_code, '04');

         END IF;
         --lv_vendor_site_rec.distribution_set_name := 'COST';
         x_return_status    := NULL;
         x_msg_count         := NULL;
         ap_vendor_pub_pkg.create_vendor_site
                                    (p_api_version          => 1,
                                     x_return_status        => x_return_status,
                                     x_msg_count            => x_msg_count,
                                     x_msg_data             => x_msg_data,
                                     p_vendor_site_rec      => lv_vendor_site_rec,
                                     x_vendor_site_id       => x_vendor_site_id,
                                     x_party_site_id        => x_party_site_id,
                                     x_location_id          => x_location_id
                                    );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            fnd_file.put_line (fnd_file.LOG,'ERROR in supplier site creation');
            fnd_file.put_line (fnd_file.LOG,'+--------------------------------------+');
            ln_msg_index_out := NULL;

            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_encoded            => 'F',
                                p_msg_index_out      => ln_msg_index_out
                               );
               fnd_message.set_encoded (x_msg_data);
               lv_api_msg :=
                     SUBSTR(lv_api_msg,1,200)
                  || ' / '
                  || ('Msg' || TO_CHAR (i) || ': ' ||SUBSTR(x_msg_data,1,200));
               fnd_file.put_line (fnd_file.LOG,
                                     'Error at Supplier Site : '
                                  || i
                                  || ', '
                                  || x_msg_data
                                 );
            END LOOP;

            ROLLBACK;
            l_api_error_flag := 'Y';
            l_api_error_msg :=
                    l_api_error_msg || '//CREATE_VENDOR_SITE : ' || SUBSTR(lv_api_msg,1,200);
            fnd_file.put_line(fnd_file.LOG,'Supplier Site NOT Created! and rollback executed');
            fnd_file.put_line (fnd_file.LOG,'+--------------------------------------+');
         ELSE
            IF x_vendor_site_id IS NOT NULL
            THEN
                COMMIT;
               fnd_file.put_line (fnd_file.LOG, '--Supplier Site Created');
               l_api_error_flag := 'N';
                        --<Supplier Site END>--
               IF r_create_vendor.primary_phone IS NOT NULL
               THEN
                        --<Create phone on contact>--
                  p_create_contact_point (x_party_site_id,
                                          r_create_vendor.primary_phone
                                         );
               END IF;

                IF r_create_vendor.INVOICE_EMAIL IS NOT NULL
               THEN
                        --<Create EMAIL on Contact Point>--
                  P_CREATE_EMAIL_CONTACT_POINT (x_party_site_id,
                                          r_create_vendor.INVOICE_EMAIL
                                         );
               END IF;
               --Commented Remit to Site relation using through User Defined Attributes(UDA)

               IF r_create_vendor.purchasing_flag='Y' --IS NOT NULL
               THEN
                  p_address_purpose (x_party_site_id, 'PAY');
               END IF;

               IF r_create_vendor.pay_site_flag='Y'-- IS NOT NULL
               THEN
                  p_address_purpose (x_party_site_id, 'PURCHASING');
               END IF;
                            --<DUNS number>--
               IF r_create_vendor.duns_number IS NOT NULL
               THEN
                  BEGIN
                     l_party_rec.party_id             := lv_party_id;
                     l_organization_rec.party_rec     := l_party_rec;
                     l_organization_rec.duns_number_c := r_create_vendor.duns_number;
                     x_profile_id         := NULL;
                     x_return_status     := NULL;
                     x_msg_count         := NULL;
                     x_msg_data         := NULL;

                     SELECT object_version_number
                       INTO l_party_object_version_number
                       FROM hz_parties
                      WHERE party_id = l_party_rec.party_id AND status = 'A';

                     --<API for DUNS Number>--
                     apps.hz_party_v2pub.update_organization
                        (p_init_msg_list                    => apps.fnd_api.g_true,
                         p_organization_rec                 => l_organization_rec,
                         p_party_object_version_number      => l_party_object_version_number,
                         x_profile_id                       => x_profile_id,
                         x_return_status                    => x_return_status,
                         x_msg_count                        => x_msg_count,
                         x_msg_data                         => x_msg_data
                        );

                     IF x_return_status <> fnd_api.g_ret_sts_success
                     THEN
                        fnd_file.put_line(fnd_file.LOG,'ERROR in update_organization');

                        ln_msg_index_out := NULL;

                        FOR i IN 1 .. x_msg_count
                        LOOP
                           fnd_msg_pub.get
                                         (p_msg_index          => i,
                                          p_data               => x_msg_data,
                                          p_encoded            => 'F',
                                          p_msg_index_out      => ln_msg_index_out
                                         );
                           fnd_message.set_encoded (x_msg_data);
                           lv_api_msg :=
                                 lv_api_msg
                              || ' / '
                              || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
                           fnd_file.put_line
                                         (fnd_file.LOG,
                                             'Error at update_organization : '
                                          || i
                                          || ', '
                                          || x_msg_data
                                         );
                        END LOOP;

                        ROLLBACK;
                        l_api_error_flag := 'Y';
                        l_api_error_msg :=
                              l_api_error_msg
                           || '//UPDATE_ORGANIZATION : '
                           || lv_api_msg;
                        fnd_file.put_line(fnd_file.LOG,'UPDATE_ORGANIZATION NOT Created! and rollback executed');
                        --fnd_file.put_line(fnd_file.LOG,'+--------------------------------------+'); ST    08/10/2015    Log writing issue
                     ELSE
                        COMMIT;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        fnd_file.put_line(fnd_file.LOG,'Unexpected Error at UPDATE_ORGANIZATION'|| SUBSTR (SQLERRM, 1, 250));
                  END;
               END IF;       --IF r_create_vendor.duns_number IS NOT NULL THEN
               --<DUNS number END>--
            END IF;                   --  IF x_vendor_site_id is not null THEN
         END IF;         --if (x_return_status <>  fnd_api.g_ret_sts_success )
      ELSE
         IF lv_vend_site_id IS NOT NULL
         THEN
            UPDATE XXAH_PS_EBS_COUPACZ_SUPP
               SET vendor_site_id = lv_vend_site_id
               , conversion_status = 'E'
             WHERE supplier_seq = r_create_vendor.supplier_seq;

            COMMIT;
            x_vendor_site_id     := lv_vend_site_id;
            x_party_site_id     := lv_party_site_id;
            l_api_error_flag     := 'Y';
            l_ss_exists_flag     := 'Y';
            l_api_error_msg     := l_api_error_msg || '//Supplier Site Already Exists';
            fnd_file.put_line(fnd_file.LOG, '//Supplier Site Already Exists');
         END IF;
      END IF;                                --IF lv_vend_site_id IS NULL THEN

      IF l_api_error_flag = 'Y'
      THEN
         UPDATE XXAH_PS_EBS_COUPACZ_SUPP
            SET vendor_id = lv_vendor_id,
                party_id = lv_party_id,
                vendor_site_id = x_vendor_site_id,
                error_log = SUBSTR(l_api_error_msg,1,3000),
                conversion_status = 'E',
                conc_request_id = g_request_id
          WHERE supplier_seq = r_create_vendor.supplier_seq;

         COMMIT;
      ELSE

         UPDATE XXAH_PS_EBS_COUPACZ_SUPP
            SET vendor_site_id = x_vendor_site_id,
                vendor_id = lv_vendor_id,
                party_id = lv_party_id,
                conversion_status = 'P',
                conc_request_id = g_request_id
          WHERE supplier_seq = r_create_vendor.supplier_seq;

         COMMIT;
      END IF;                               --  IF l_api_error_flag = 'Y' THEN
        lv_bank_id := NULL;
      IF r_create_vendor.bank_name is not null and r_create_vendor.bank_number is not null THEN
      -----------------------<Create Bank>--------------------------------
      p_create_bank (r_create_vendor.bank_name,
                     r_create_vendor.bank_name,
                     r_create_vendor.bank_number,   -- Added by Vema Based on RFC 027
                     lv_territory,
                     NULL,
                     NULL,
                     r_create_vendor.supplier_seq,
                     lv_bank_id,
                     lv_bank_error_msg,
                     lv_bank_error_flag
                    );
     END IF;

      IF lv_bank_error_flag = 'Y'
      THEN
         l_api_error_msg := l_api_error_msg || lv_bank_error_msg;
      END IF;

      IF lv_bank_id IS NOT NULL and r_create_vendor.bank_branch_name IS NOT NULL
      THEN
                p_create_branch (lv_bank_id,
                          r_create_vendor.bank_branch_name,
                          NULL,
                          r_create_vendor.supplier_seq,
                          r_create_vendor.eft_swift_code,
                          lv_branch_id,
                          lv_branch_error_msg,
                          lv_branch_error_flag
                         );
         IF lv_bank_error_flag = 'Y' OR lv_branch_error_flag = 'Y'
         THEN
            l_api_error_msg := l_api_error_msg || lv_branch_error_msg;

            UPDATE XXAH_PS_EBS_COUPACZ_SUPP
               SET error_log = SUBSTR(l_api_error_msg,1,3000),
                   bank_id = lv_bank_id,
                   branch_id = lv_branch_id,
                   acct_id = lv_account_id,
                   conversion_status = 'E',
                   conc_request_id = g_request_id
             WHERE supplier_seq = r_create_vendor.supplier_seq;

            COMMIT;
         END IF;
      END IF;

      IF lv_branch_id IS NOT NULL AND to_char(replace(r_create_vendor.bank_account_number,'"',NULL)) IS NOT NULL
      THEN
         BEGIN
            p_create_bank_acct (lv_bank_id,
                                lv_branch_id,
                                lv_party_id,
                                r_create_vendor.bank_account_name,
                                to_char(replace(r_create_vendor.bank_account_number,'"',NULL)),
                                lv_territory,
                                x_vendor_site_id,
                                x_party_site_id,
                                lv_account_id,
                                trim(replace(r_create_vendor.iban,'"',NULL)),
                                trim(replace(r_create_vendor.check_digits,'"',NULL)),
                                r_create_vendor.operating_unit_id,
                                r_create_vendor.bank_priority,
                                lv_acct_error_msg,
                                lv_acct_error_flag
                               );

            IF lv_acct_error_flag = 'Y'
            THEN
               l_api_error_msg := l_api_error_msg || lv_acct_error_msg;

               UPDATE XXAH_PS_EBS_COUPACZ_SUPP
                  SET error_log = SUBSTR(l_api_error_msg,1,3000),
                      bank_id = lv_bank_id,
                      branch_id = lv_branch_id,
                      acct_id = lv_account_id,
                      conversion_status = 'E',
                      conc_request_id = g_request_id
                WHERE supplier_seq = r_create_vendor.supplier_seq;

               COMMIT;
            ELSE
               UPDATE XXAH_PS_EBS_COUPACZ_SUPP
                  SET bank_id = lv_bank_id,
                      branch_id = lv_branch_id,
                      acct_id = lv_account_id,
                      conversion_status = 'P',
                      conc_request_id = g_request_id
                WHERE supplier_seq = r_create_vendor.supplier_seq;

               COMMIT;
            END IF;
         END;
      END IF;

      IF x_vendor_site_id IS NOT NULL
      THEN

            BEGIN
               p_uda (lv_party_id,
                      'XXAH_Supplier_Type',
                      'Supplier Type',
                      NVL (r_create_vendor.supplier_type, 'NFR'),
                      NULL,
                      'SUPP_LEVEL',
                      NULL,
                      NULL
                     );
            END;


            BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'updating site type'||r_create_vendor.supplier_type||' TO party/vendor site '||nvl(x_party_site_id, lv_party_site_id)||' / '||nvl(x_vendor_site_id, lv_vend_site_id));
                P_SS_UDA (lv_party_id,
                     'XXAH_Supplier_Site_Type',
                     'Supplier Site Type',
                     NVL (r_create_vendor.supplier_type, 'NFR'),
                     NULL,
                     'SUPP_ADDR_SITE_LEVEL',
                     nvl(x_party_site_id, lv_party_site_id),
                     nvl(x_vendor_site_id, lv_vend_site_id)
                     );
                FND_FILE.PUT_LINE(FND_FILE.LOG,'<Site type updated>');
            END;



             -- PeopleSoft Intercompany Number

IF r_create_vendor.PEOPLESOFT_INTERCOMPANY IS NOT NULL THEN
               BEGIN
               p_uda (lv_party_id,
                      'XXAH_PSFT_Intercompany',
                      'PeopleSoft Intercompany Number',
                      r_create_vendor.PEOPLESOFT_INTERCOMPANY,
                      NULL,
                      'SUPP_LEVEL',
                      NULL,
                      NULL
                     );

            END;
END IF;
            --<Registration Number>--
            IF r_create_vendor.STD_ID_QUAL_SUPP IS NOT NULL THEN

            BEGIN
               p_uda (lv_party_id,
                      'XXAH_STD_QUAL_SUPP',
                      'Registration Type',
                      r_create_vendor.STD_ID_QUAL_SUPP,
                      to_char(replace(r_create_vendor.STD_ID_NUM_SUPP,'"',NULL)),--r_create_vendor.STD_ID_NUM_SUPP,
                      'SUPP_LEVEL',
                      lv_party_site_id,
                      x_vendor_site_id
                     );
            END;

            END IF;


            BEGIN

            l_leaf_commodity := NULL;

                SELECT distinct
                ffv.flex_value
                into
                l_leaf_commodity
                FROM fnd_flex_value_sets ffvs ,
                fnd_flex_values ffv ,
                fnd_flex_values_tl ffvt
                WHERE
                ffvs.flex_value_set_id = ffv.flex_value_set_id
                and ffv.flex_value_id = ffvt.flex_value_id
                AND ffvt.language = USERENV('LANG')
                AND upper(ffv.flex_value) = upper(r_create_vendor.leaf_commodity)
                and flex_value_set_name = 'XXAH_LEAF_COMMODITY';

            END;

            BEGIN
               p_uda (lv_party_id,
                      'XXAH_COUPA_CONTENT',
                      'Coupa Content Group',
                      NVL (r_create_vendor.content_group, 'Non preferred'),
                      l_leaf_commodity,--r_create_vendor.leaf_commodity,
                      'SUPP_ADDR_SITE_LEVEL',
                      x_party_site_id,
                      x_vendor_site_id
                     );
            END;

            /*If r_create_vendor.STD_ID_NUM_SUPP IS NOT NULL THEN

            BEGIN
               p_uda (lv_party_id,
                      'XXAH_STD_QUAL_SITE',
                      'Registration Type Site',
                      r_create_vendor.STD_ID_QUAL_SUPP,
                      to_char(replace(r_create_vendor.STD_ID_NUM_SUPP,'"',NULL)),
                      'SUPP_ADDR_SITE_LEVEL',
                      x_party_site_id,
                      x_vendor_site_id
                     );
            END;

            END IF;*/


                    --<Supplier Site DFF>--
            p_update_dff (x_vendor_site_id,
                          r_create_vendor.primary_contact_name_given,
                          r_create_vendor.primary_contact_name_family,
                          r_create_vendor.primary_contact_email,
                          to_char(replace(r_create_vendor.primary_contact_phone_work,'"',NULL)),--r_create_vendor.primary_contact_phone_work,
                          r_create_vendor.primary_contact_ph_work_area,
                          r_create_vendor.primary_contact_phone_mobile,
                          r_create_vendor.primary_contact_phone_fax,
                          to_char(replace(r_create_vendor.primary_work_country_code,'"',NULL)),--r_create_vendor.primary_work_country_code,
                          r_create_vendor.retainage_code,
                          r_create_vendor.duns_number
                         );
      END IF;                           --IF x_vendor_site_id IS NOT NULL THEN

   END LOOP;

   BEGIN
   FOR r_supplier_remit IN c_supplier_remit
   LOOP
         l_row_count := c_supplier_remit%ROWCOUNT;
      EXIT WHEN c_supplier_remit%NOTFOUND;
      IF r_supplier_remit.remit_supplier_name IS NOT NULL THEN
      l_supp_party_id := NULL;
      l_party_site_id := NULL;
      l_vendor_site_id := NULL;

         select asa.party_id, assa.PARTY_SITE_ID, assa.vendor_site_id,asa.vendor_name,assa.vendor_site_code
            into l_supp_party_id, l_party_site_id, l_vendor_site_id,l_vendor_name,l_vendor_site_name
        from ap_suppliers asa,
            ap_supplier_sites_all assa
    where asa.vendor_id = assa.vendor_id
            AND   upper(asa.vendor_name)= upper(r_supplier_remit.SUPPLIER_NAME)
            AND upper(assa.vendor_site_code) = upper(r_supplier_remit.SUPPLIER_SITE_NAME);

            p_uda (l_supp_party_id,
                      'XXAH_REMIT_TO_SUPP',
                      'Remit To Supplier',
                       r_supplier_remit.remit_supplier_name,
                       r_supplier_remit.remit_supplier_site,
                      'SUPP_ADDR_SITE_LEVEL',
                      l_party_site_id,
                      l_vendor_site_id
                     );
      END IF;
   END LOOP;
   EXCEPTION
        WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - Remit To Supplier UDA '||SQLCODE||' -ERROR- '||SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
   END;


       P_REPORT(g_request_id);

END P_MAIN;

PROCEDURE P_CREATE_BANK (
   p_bank_name             IN       VARCHAR2,
   p_alternate_bank_name   IN       VARCHAR2,
   p_bank_number           IN       VARCHAR2,
   p_country_code          IN       VARCHAR2,
   p_short_bank_name       IN       VARCHAR,
   p_description           IN       VARCHAR2,
   p_supplier_seq          IN       NUMBER,
   p_bank_id               OUT      NUMBER,
   p_bank_error_msg        OUT      VARCHAR2,
   p_error_flag            OUT      VARCHAR2
)
IS
   p_init_msg_list       VARCHAR2 (200);
   x_bank_id             NUMBER;
   x_return_status       VARCHAR2 (200);
   x_msg_count           NUMBER;
   x_msg_data            VARCHAR2 (200);
   p_count               NUMBER;
   x_end_date            DATE;
   l_count_short_bname   NUMBER;
   l_error_flag          VARCHAR2 (1);
   l_error_msg           VARCHAR2 (2000);
   lv_api_msg            VARCHAR2 (2000);
   ln_msg_index_out      NUMBER          := NULL;
BEGIN
   p_init_msg_list := fnd_api.g_true;
   p_bank_error_msg := NULL;
   lv_api_msg := NULL;
   p_bank_id := NULL;
   --<Check Bank Exist>--
   ce_bank_pub.check_bank_exist (p_country_code      => p_country_code,
                                 p_bank_name         => p_bank_name,
                                 p_bank_number       => p_bank_number,
                                 x_bank_id           => x_bank_id,
                                 x_end_date          => x_end_date
                                );

   IF x_bank_id IS NOT NULL
   THEN
      l_error_flag := 'Y';
      l_error_msg := '//Bank Already Exists';
      p_bank_id := x_bank_id;
      fnd_file.put_line (fnd_file.LOG, '//Bank Already Exists');
   END IF;

   IF x_bank_id IS NULL
   THEN
      fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                                  resp_id           => fnd_global.resp_id,
                                  resp_appl_id      => fnd_global.resp_appl_id
                                 );
      ce_bank_pub.create_bank (p_init_msg_list            => p_init_msg_list,
                               p_country_code             => p_country_code,
                               p_bank_name                => p_bank_name,
                               p_bank_number              => p_bank_number,
                               p_alternate_bank_name      => p_alternate_bank_name,
                               p_description              => p_description,
                               x_bank_id                  => x_bank_id,
                               x_return_status            => x_return_status,
                               x_msg_count                => x_msg_count,
                               x_msg_data                 => x_msg_data
                              );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         ln_msg_index_out := NULL;

         FOR i IN 1 .. x_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                             p_data               => x_msg_data,
                             p_encoded            => 'F',
                             p_msg_index_out      => ln_msg_index_out
                            );
            fnd_message.set_encoded (x_msg_data);
            lv_api_msg :=
                  lv_api_msg
               || ' / '
               || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
            fnd_file.put_line (fnd_file.LOG,
                               'Error at Bank API : ' || i || ', '
                               || x_msg_data
                              );
         END LOOP;

         ROLLBACK;
         l_error_flag := 'Y';
         l_error_msg := l_error_msg || '//Bank API : ' || lv_api_msg;
         fnd_file.put_line (fnd_file.LOG,
                            'Bank NOT Created! and rollback executed'
                           );
      ELSE
         p_bank_id := x_bank_id;
         l_error_flag := 'N';
         fnd_file.put_line (fnd_file.LOG, '--Bank Created');
      END IF;            --if (x_return_status <>  fnd_api.g_ret_sts_success )
   END IF;

   p_bank_error_msg := l_error_msg;
   p_error_flag := l_error_flag;
   EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_CREATE_BANK '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END P_CREATE_BANK;

PROCEDURE P_CREATE_BRANCH (
   p_bank_id            IN       NUMBER,
   p_branch_name        IN       VARCHAR2,
   p_branch_number      IN       VARCHAR2,
   p_supplier_seq       IN       NUMBER,
   p_bic                IN       VARCHAR,
   p_branch_id          OUT      NUMBER,
   p_branch_error_msg   OUT      VARCHAR2,
   p_error_flag         OUT      VARCHAR2
)
IS
   p_init_msg_list           VARCHAR2 (200);
   p_branch_type             VARCHAR2 (200);
   p_alternate_branch_name   VARCHAR2 (200);
   p_description             VARCHAR2 (200);
   p_rfc_identifier          VARCHAR2 (200);
   x_branch_id               NUMBER          := NULL;
   x_return_status           VARCHAR2 (200);
   x_msg_count               NUMBER;
   x_msg_data                VARCHAR2 (200);
   p_count                   NUMBER;
   x_end_date                DATE;
   lv_branch_number          NUMBER;
   l_error_flag              VARCHAR2 (1);
   l_error_msg               VARCHAR2 (2000);
   lv_api_msg                VARCHAR2 (2000);
   ln_msg_index_out          NUMBER          := NULL;
   l_bic                     VARCHAR2 (1);
BEGIN
   p_init_msg_list := fnd_api.g_true;
   p_alternate_branch_name := p_branch_name;
   p_description := p_branch_name;
   p_branch_type := 'ABA';
   p_rfc_identifier := 'AFC';

   BEGIN
      ce_bank_pub.check_branch_exist (p_bank_id            => p_bank_id,
                                      p_branch_name        => p_branch_name,
                                      p_branch_number      => p_branch_number,
                                      x_branch_id          => x_branch_id,
                                      x_end_date           => x_end_date
                                     );
   END;

   IF x_branch_id IS NOT NULL
   THEN
      l_error_flag := 'Y';
      l_error_msg := '//Branch Already Exists';
      fnd_file.put_line (fnd_file.LOG, '//Branch Already Exists');
      p_branch_id := x_branch_id;
   END IF;

   ce_validate_bankinfo.ce_validate_bic (x_bic_code           => p_bic,
                                         p_init_msg_list      => p_init_msg_list,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         x_return_status      => x_return_status
                                        );

   IF (x_return_status <> fnd_api.g_ret_sts_success)
   THEN
      ln_msg_index_out := NULL;

      FOR i IN 1 .. x_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => x_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (x_msg_data);
         lv_api_msg :=
            lv_api_msg || ' / '
            || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
         fnd_file.put_line (fnd_file.LOG,
                               'Error at CE_VALIDATE_BIC : '
                            || i
                            || ', '
                            || x_msg_data
                           );
      END LOOP;

      l_error_flag := 'Y';
      l_error_msg := l_error_msg || '//CE_VALIDATE_BIC API : ' || lv_api_msg;
      fnd_file.put_line (fnd_file.LOG, 'BIC Invalid');
   ELSE
      l_bic := 'V';
   END IF;               --if (x_return_status <>  fnd_api.g_ret_sts_success )

   IF x_branch_id IS NULL AND l_bic = 'V'
   THEN
      x_msg_count := NULL;
      x_msg_data := NULL;
      x_return_status := NULL;
      ce_bank_pub.create_bank_branch
                         (p_init_msg_list              => p_init_msg_list,
                          p_bank_id                    => p_bank_id,
                          p_branch_name                => p_branch_name,
                          p_branch_number              => p_branch_number,
                          p_branch_type                => p_branch_type,
                          p_alternate_branch_name      => p_alternate_branch_name,
                          p_description                => p_description,
                          p_bic                        => p_bic,
                          --p_eft_number          =>  p_bic,
                          p_rfc_identifier             => p_rfc_identifier,
                          x_branch_id                  => x_branch_id,
                          x_return_status              => x_return_status,
                          x_msg_count                  => x_msg_count,
                          x_msg_data                   => x_msg_data
                         );

      IF x_branch_id IS NOT NULL
      THEN
         p_branch_id := x_branch_id;
         fnd_file.put_line (fnd_file.LOG, '--Branch Created');
      END IF;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         ln_msg_index_out := NULL;

         FOR i IN 1 .. x_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                             p_data               => x_msg_data,
                             p_encoded            => 'F',
                             p_msg_index_out      => ln_msg_index_out
                            );
            fnd_message.set_encoded (x_msg_data);
            lv_api_msg :=
                  lv_api_msg
               || ' / '
               || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
            fnd_file.put_line (fnd_file.LOG,
                                  'Error at Branch API : '
                               || i
                               || ', '
                               || x_msg_data
                              );
         END LOOP;

         ROLLBACK;
         l_error_flag := 'Y';
         l_error_msg := l_error_msg || '//Branch API : ' || lv_api_msg;
         fnd_file.put_line (fnd_file.LOG,
                            'Bank NOT Created! and rollback executed'
                           );
      ELSE
         p_branch_id := x_branch_id;
         l_error_flag := 'N';
      END IF;            --if (x_return_status <>  fnd_api.g_ret_sts_success )
   END IF;                      --IF x_branch_id IS NULL and  l_bic = 'V' THEN

   p_branch_error_msg :=SUBSTR(l_error_msg,1,200);

   p_error_flag := l_error_flag;
   EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_CREATE_BRANCH '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END P_CREATE_BRANCH;

PROCEDURE P_CREATE_BANK_ACCT (
   p_bank_id            IN       NUMBER,
   p_branch_id          IN       NUMBER,
   p_party_id           IN       NUMBER,
   p_account_name       IN       VARCHAR2,
   p_account_num        IN       VARCHAR2,--Number
   p_territory_code     IN       VARCHAR,
   p_supp_site_id       IN       NUMBER,
   p_partysite_id       IN       NUMBER,
   p_account_id         OUT      NUMBER,
   p_iban               IN       VARCHAR2,
   p_check_digits       IN       VARCHAR2,
   p_ou_id              IN       NUMBER,
   p_priority           IN       NUMBER,
   p_branch_error_msg   OUT      VARCHAR2,
   p_error_flag         OUT      VARCHAR2
)
IS
   l_bank_acct_rec          apps.iby_ext_bankacct_pub.extbankacct_rec_type;
   out_mesg                 apps.iby_fndcpt_common_pub.result_rec_type;
   l_acct                   NUMBER;
   l_assign                 apps.iby_fndcpt_setup_pub.pmtinstrassignment_tbl_type;
   l_payee_rec              apps.iby_disbursement_setup_pub.payeecontext_rec_type;
   l_return_status          VARCHAR2 (30);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2 (3000);
   l_msg_dummy              VARCHAR2 (3000);
   l_output                 VARCHAR2 (3000);
   l_bank_id                NUMBER;
   l_branch_id              NUMBER;
   l_bank                   VARCHAR2 (1000);
   l_acct_owner_party_id    NUMBER;
   l_supplier_site_id       NUMBER;
   l_party_site_id          NUMBER;
   l_msg_index              NUMBER := 0;
   v_return_status          VARCHAR2 (20);
   v_msg_count              NUMBER;
   v_msg_data               VARCHAR2 (500);
   l_currency_code          VARCHAR2 (10);
   ln_partyid               NUMBER;
   ln_ext_bank_account_id   NUMBER;
   p_instrument             iby_fndcpt_setup_pub.pmtinstrument_rec_type;
   p_payee                  iby_disbursement_setup_pub.payeecontext_rec_type;
   l_assg_attr              iby_fndcpt_setup_pub.pmtinstrassignment_rec_type;
   l_assg_id                NUMBER;
   l_response               iby_fndcpt_common_pub.result_rec_type;
   l_joint_acct_owner_id    NUMBER;
   p_assignment_attribs     iby_fndcpt_setup_pub.pmtinstrassignment_rec_type;
   l_result_rec             iby_fndcpt_common_pub.result_rec_type;
   x_assign_id              NUMBER;
   x_return_status          VARCHAR2 (10);
   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2 (256);
   x_response_rec           iby_fndcpt_common_pub.result_rec_type;
   l_error_flag             VARCHAR2 (1);
   l_error_msg              VARCHAR2 (2000);
   lv_api_msg               VARCHAR2 (2000);
   ln_msg_index_out         NUMBER := NULL;
   l_priority               NUMBER;
BEGIN


   fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );

   BEGIN
      ln_partyid := NULL;
      ln_ext_bank_account_id := NULL;
      fnd_file.put_line (fnd_file.LOG, 'bank_account_num '||trim(p_account_num));

      SELECT MAX (ext_bank_account_id)
        INTO ln_ext_bank_account_id
        FROM iby_ext_bank_accounts
       WHERE trim(bank_account_num) = trim(p_account_num)
         AND country_code = p_territory_code
         AND bank_id = p_bank_id
         AND branch_id = p_branch_id
         --AND bank_account_name = p_account_name  Vema commented due to PSFT doesn't have bank account name
         AND end_date IS NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
         ln_ext_bank_account_id := NULL;
   END;

   IF ln_ext_bank_account_id IS NULL
   THEN
      l_bank_acct_rec.bank_id := p_bank_id;
      l_bank_acct_rec.branch_id := p_branch_id;
      l_bank_acct_rec.country_code := p_territory_code;
      l_bank_acct_rec.bank_account_name := p_account_name;
      l_bank_acct_rec.bank_account_num := p_account_num;
      l_bank_acct_rec.acct_owner_party_id := p_party_id;
      l_bank_acct_rec.currency := NULL;   -- BANK Account Currency Code is not required
      l_bank_acct_rec.object_version_number := '1';
      l_bank_acct_rec.start_date := SYSDATE;
      l_bank_acct_rec.iban := p_iban;
      l_bank_acct_rec.check_digits := p_check_digits;
      apps.iby_ext_bankacct_pub.create_ext_bank_acct
                                     (p_api_version            => 1.0,
                                      p_init_msg_list          => fnd_api.g_true,
                                      p_ext_bank_acct_rec      => l_bank_acct_rec,
                                      p_association_level      => 'SS',
                                      p_supplier_site_id       => p_supp_site_id,
                                      p_party_site_id          => p_partysite_id,
                                      p_org_id                 => p_ou_id,
                                      p_org_type               => 'OPERATING_UNIT',
                                      x_acct_id                => l_acct,
                                      x_return_status          => l_return_status,
                                      x_msg_count              => l_msg_count,
                                      x_msg_data               => l_msg_data,
                                      x_response               => out_mesg
                                     );

      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
         ln_msg_index_out := NULL;

         FOR i IN 1 .. l_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                             p_data               => l_msg_data,
                             p_encoded            => 'F',
                             p_msg_index_out      => ln_msg_index_out
                            );
            fnd_message.set_encoded (l_msg_data);
            lv_api_msg :=
                  lv_api_msg
               || ' / '
               || ('Msg' || TO_CHAR (i) || ': ' || l_msg_data);
            fnd_file.put_line (fnd_file.LOG,
                                  'Error at bank_acct API : '
                               || i
                               || ', '
                               || l_msg_data
                              );
         END LOOP;

         ROLLBACK;
         l_error_flag := 'Y';
         l_error_msg := l_error_msg || '//Bank Account API : ' || lv_api_msg;
         fnd_file.put_line (fnd_file.LOG,
                            'Bank Account NOT Created! and rollback executed'
                           );
      ELSE
         COMMIT;
         p_account_id := l_acct;
         l_error_flag := 'N';

         COMMIT;
         fnd_file.put_line (fnd_file.LOG, '--Account Created');
      END IF;            --if (l_return_status <>  fnd_api.g_ret_sts_success )
   ELSE
      BEGIN
         iby_ext_bankacct_pub.add_joint_account_owner
                             (p_api_version              => 1.0,
                              p_init_msg_list            => fnd_api.g_true,
                              p_bank_account_id          => ln_ext_bank_account_id,
                              p_acct_owner_party_id      => p_party_id,
                              x_joint_acct_owner_id      => l_joint_acct_owner_id,
                              x_return_status            => l_return_status,
                              x_msg_count                => l_msg_count,
                              x_msg_data                 => l_msg_data,
                              x_response                 => l_result_rec
                             );
         IF (l_return_status <> fnd_api.g_ret_sts_success)
         THEN
            ln_msg_index_out := NULL;

            FOR i IN 1 .. l_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => l_msg_data,
                                p_encoded            => 'F',
                                p_msg_index_out      => ln_msg_index_out
                               );
               fnd_message.set_encoded (l_msg_data);
               lv_api_msg :=
                     lv_api_msg
                  || ' / '
                  || ('Msg' || TO_CHAR (i) || ': ' || l_msg_data);
               fnd_file.put_line (fnd_file.LOG,
                                     'Error at bank_acct API : '
                                  || i
                                  || ', '
                                  || l_msg_data
                                 );
            END LOOP;

            ROLLBACK;
            l_error_flag := 'Y';
            l_error_msg :=
                          l_error_msg || '//Bank Account API : ' || lv_api_msg;
            fnd_file.put_line
                            (fnd_file.LOG,
                             'Bank Account NOT Created! and rollback executed'
                            );
         ELSE
            l_error_flag := 'N';
         END IF;         --if (l_return_status <>  fnd_api.g_ret_sts_success )
      END;

      IF l_return_status = fnd_api.g_ret_sts_success
      THEN
         IF p_priority IS NULL
         THEN
            BEGIN
               SELECT MAX (piu.order_of_preference) priority
                 INTO l_priority
                 FROM apps.ap_suppliers sup,
                      apps.ap_supplier_sites_all ss,
                      apps.ap_supplier_sites_all ss2,
                      apps.iby_external_payees_all epa,
                      apps.iby_pmt_instr_uses_all piu,
                      apps.iby_ext_bank_accounts eba
                WHERE sup.vendor_id = ss.vendor_id
                  AND ss.vendor_site_id = epa.supplier_site_id
                  AND ss2.vendor_id = sup.vendor_id
                  AND ss2.vendor_site_code = ss.vendor_site_code
                  AND epa.ext_payee_id = piu.ext_pmt_party_id
                  AND piu.instrument_id = eba.ext_bank_account_id
                  AND sup.party_id = p_party_id
                  AND ss.vendor_site_id = p_supp_site_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
                  fnd_file.put_line(fnd_file.LOG,'Error - priority '|| SQLCODE|| ' -ERROR- '|| SQLERRM);
                  fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
            END;
         END IF;

         BEGIN
            p_payee.supplier_site_id         := p_supp_site_id;
            p_payee.party_id                 := p_party_id;
            p_payee.party_site_id             := p_partysite_id;
            p_payee.payment_function         := 'PAYABLES_DISB';
            p_payee.org_id                     := p_ou_id;
            p_payee.org_type                 := 'OPERATING_UNIT';
            p_instrument.instrument_id         := ln_ext_bank_account_id;
            p_instrument.instrument_type     := 'BANKACCOUNT';
            p_assignment_attribs.start_date := SYSDATE;
           -- p_assignment_attribs.priority     := NVL (p_priority, l_priority + 1);
            p_assignment_attribs.instrument := p_instrument;
            x_msg_count     := 0;
            x_msg_data         := NULL;
            x_return_status := NULL;
            x_response_rec     := NULL;
            iby_disbursement_setup_pub.set_payee_instr_assignment
                               (p_api_version             => 1.0,
                                p_init_msg_list           => fnd_api.g_true,
                                p_commit                  => fnd_api.g_true,
                                x_return_status           => x_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data,
                                p_payee                   => p_payee,
                                p_assignment_attribs      => p_assignment_attribs,
                                x_assign_id               => x_assign_id,
                                x_response                => x_response_rec
                               );

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               ln_msg_index_out := NULL;

               FOR i IN 1 .. x_msg_count
               LOOP
                  fnd_msg_pub.get (p_msg_index          => i,
                                   p_data               => x_msg_data,
                                   p_encoded            => 'F',
                                   p_msg_index_out      => ln_msg_index_out
                                  );
                  fnd_message.set_encoded (x_msg_data);
                  lv_api_msg :=
                        lv_api_msg
                     || ' / '
                     || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
                  fnd_file.put_line
                              (fnd_file.LOG,
                                  'Error at SET_PAYEE_INSTR_ASSIGNMENT API : '
                               || i
                               || ', '
                               || x_msg_data
                              );
               END LOOP;

               ROLLBACK;
               l_error_flag := 'Y';
               l_error_msg :=
                     l_error_msg
                  || '//SET_PAYEE_INSTR_ASSIGNMENT API : '
                  || lv_api_msg;
               fnd_file.put_line(fnd_file.LOG,'Bank Account NOT Created! and rollback executed');
            ELSE
               p_account_id := ln_ext_bank_account_id;
               COMMIT;
               l_error_flag := 'N';
               fnd_file.put_line (fnd_file.LOG, '--Account Attached to Site');
            END IF;      --if (x_return_status <>  fnd_api.g_ret_sts_success )
         EXCEPTION
            WHEN OTHERS
            THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occurred during procedure P_CREATE_BANK_ACCT '||SQLCODE||' -ERROR- '||SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

               NULL;
         END;
      END IF;                 --IF l_return_status = fnd_api.g_ret_sts_success
   END IF;                               --IF ext_bank_account_id is NULL THEN

   p_branch_error_msg :=SUBSTR(l_error_msg,1,200);
   p_error_flag := l_error_flag;

EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_CREATE_BANK_ACCT'||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

END P_CREATE_BANK_ACCT;

PROCEDURE P_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
   ln_attr_value_str2     IN   VARCHAR2,
   p_data_level           IN   VARCHAR2,
   p_data_level_1         IN   NUMBER,
   p_data_level_2         IN   NUMBER
)
IS
   ln_attr_num                    NUMBER                        := NULL;
   ln_msg_index_out               NUMBER                        := NULL;
   lv_failed_row_id_list          VARCHAR2 (100)                := NULL;
   ldt_attr_date                  DATE                          := NULL;
   ln_attr_value_str              VARCHAR2 (50)                 := NULL;
   lv_pk_column_values            ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   lv_attributes_row_table        ego_user_attr_row_table;
   lv_attributes_row_table1       ego_user_attr_row_table;
   lv_attributes_data_table       ego_user_attr_data_table;
   lv_attributes_data_table1      ego_user_attr_data_table;
   lv_class_code                  ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   l_pk_column_name_value_pairs   ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   lv_return_status               VARCHAR2 (10)                 := NULL;
   ln_msg_count                   NUMBER                        := 0;
   lv_msg_data                    VARCHAR2 (1000)               := NULL;
   ln_errorcode                   NUMBER                        := 0;
   lv_attr_name                   VARCHAR2 (50);
   lv_attr_group_id               NUMBER;
   l_data_level_1                 NUMBER;
   l_data_level_2                 NUMBER;
   l_vendor_id                       NUMBER;
   l_vendor_site_id                  NUMBER;
   l_party_site_id                  NUMBER;
   l_ego_col_name                  VARCHAR2 (30);
BEGIN
   fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );

   BEGIN
      SELECT egoattributeeo.attr_name, ext.attr_group_id
        INTO lv_attr_name, lv_attr_group_id
        FROM ego_attrs_v egoattributeeo, ego_fnd_dsc_flx_ctx_ext ext
       WHERE egoattributeeo.application_id = ext.application_id
         AND egoattributeeo.attr_group_type = ext.descriptive_flexfield_name
         AND egoattributeeo.attr_group_name = ext.descriptive_flex_context_code
         AND egoattributeeo.application_id = 177
         AND egoattributeeo.attr_group_type = 'POS_SUPP_PROFMGMT_GROUP'
         AND egoattributeeo.attr_group_name = lv_attr_group_name
         AND egoattributeeo.attr_display_name = lv_attr_display_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
         fnd_file.put_line (fnd_file.LOG,
                               'lv_attr_group_name '
                            || lv_attr_group_name
                            || ' lv_attr_display_name '
                            || lv_attr_display_name
                           );
         fnd_file.put_line (fnd_file.LOG,
                               'Error at ego_attrs_v '
                            || SQLCODE
                            || ' -ERROR- '
                            || SQLERRM
                           );
         fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
   END;



   lv_pk_column_values.EXTEND (1);
   lv_pk_column_values (1) :=
                         ego_col_name_value_pair_obj ('PARTY_ID', ln_party_id);
   lv_class_code.EXTEND (1);
   lv_class_code (1) :=
                ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE');

   IF lv_attr_group_name = 'XXAH_Supplier_Type'
   THEN
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => lv_attr_name,
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  )
            );
   END IF;


    IF lv_attr_group_name = 'XXAH_PSFT_Intercompany'
   THEN
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_PeopleSoft_INT',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  )
            );
   END IF;

   IF lv_attr_group_name = 'XXAH_COUPA_CONTENT'
   THEN
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_COUPA_CONTENT',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ),
             ego_user_attr_data_obj (row_identifier            => 1,
                                     attr_name                 => 'XXAH_LEAF_COMM',
                                     attr_value_str            => ln_attr_value_str2,
                                     attr_value_num            => ln_attr_num,
                                     attr_value_date           => ldt_attr_date,
                                     attr_disp_value           => NULL,
                                     attr_unit_of_measure      => NULL,
                                     user_row_identifier       => 1
                                    )
            );
   END IF;

   IF lv_attr_group_name = 'XXAH_REMIT_TO_SUPP'
   THEN

   BEGIN
       select asa.vendor_id, assa.vendor_site_id , assa.party_site_id
            into l_vendor_id, l_vendor_site_id , l_party_site_id
        from ap_suppliers asa,
            ap_supplier_sites_all assa
    where asa.vendor_id = assa.vendor_id
            AND    asa.vendor_name = ln_attr_value_str1
            AND assa.vendor_site_code = ln_attr_value_str2;
EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - XXAH_REMIT_TO_SUPP '||SQLCODE||' -ERROR- '||SQLERRM);
END;

      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'Remit_To_Supplier',
                                   attr_value_str            => l_vendor_id,--ln_attr_value_str,--TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ),
             ego_user_attr_data_obj (row_identifier            => 1,
                                     attr_name                 => 'Remit_To_Supp_Site',
                                     attr_value_str            => l_vendor_site_id,--ln_attr_value_str2,
                                     attr_value_num            => NULL,
                                     attr_value_date           => NULL,
                                     attr_disp_value           => NULL,
                                     attr_unit_of_measure      => NULL,
                                     user_row_identifier       => 1
                                    ),
                         ego_user_attr_data_obj (row_identifier => 1,
                                     attr_name                 => 'From_Date',
                                     attr_value_str            => NULL,
                                     attr_value_num            => NULL,
                                     attr_value_date           => trunc(sysdate),
                                     attr_disp_value           => NULL,
                                     attr_unit_of_measure      => NULL,
                                     user_row_identifier       => 1
                                    )
            );
   END IF;

   IF lv_attr_group_name = 'XXAH_STD_QUAL_SUPP'
   THEN
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_REG_TYPE',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ),
             ego_user_attr_data_obj
                   (row_identifier            => 1,
                    attr_name                 => 'XXAH_REG_NUM',
                    attr_value_str            => ln_attr_value_str2,
                    attr_value_num            => ln_attr_num,
                    attr_value_date           => ldt_attr_date,
                    attr_disp_value           => NULL,
                    attr_unit_of_measure      => NULL,
                    user_row_identifier       => 1
                   )
            );
   END IF;

   ------------------------------RFC-027 --------------
   IF lv_attr_group_name = 'XXAH_STD_QUAL_SITE'
   THEN
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_REG_TYPE_SITE',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ),
             ego_user_attr_data_obj
                   (row_identifier            => 1,
                    attr_name                 => 'XXAH_REG_NUM_SITE',
                    attr_value_str            => ln_attr_value_str2,
                    attr_value_num            => ln_attr_num,
                    attr_value_date           => ldt_attr_date,
                    attr_disp_value           => NULL,
                    attr_unit_of_measure      => NULL,
                    user_row_identifier       => 1
                   )
            );
   END IF;
   ------------------------------RFC 027 --------------

   lv_attributes_row_table :=
      ego_user_attr_row_table
         (ego_user_attr_row_obj
                    (row_identifier         => 1,
                     attr_group_id          => lv_attr_group_id,
                     attr_group_app_id      => 177,
                     attr_group_type        => 'POS_SUPP_PROFMGMT_GROUP',
                     attr_group_name        => lv_attr_group_name,
                     data_level             => p_data_level,
                     data_level_1           => 'N',
                     data_level_2           => p_data_level_1,
                     data_level_3           => p_data_level_2,
                     data_level_4           => NULL,
                     data_level_5           => NULL,
                     transaction_type       => ego_user_attrs_data_pvt.g_create_mode
                    )
         );
   --Supplier uda updation started
   pos_vendor_pub_pkg.process_user_attrs_data
                         (p_api_version                      => 1.0,
                          p_attributes_row_table             => lv_attributes_row_table,
                          p_attributes_data_table            => lv_attributes_data_table,
                          p_pk_column_name_value_pairs       => lv_pk_column_values,
                          p_class_code_name_value_pairs      => lv_class_code,
                          x_failed_row_id_list               => lv_failed_row_id_list,
                          x_return_status                    => lv_return_status,
                          x_errorcode                        => ln_errorcode,
                          x_msg_count                        => ln_msg_count,
                          x_msg_data                         => lv_msg_data
                         );

   IF lv_return_status = fnd_api.g_ret_sts_success
   THEN
      COMMIT;
   ELSE
      fnd_file.put_line (fnd_file.LOG,'Error Message Data  : ' || lv_msg_data);

      FOR i IN 1 .. ln_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => lv_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (lv_msg_data);

      END LOOP;

      ROLLBACK;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UDA '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
      ROLLBACK;
END P_UDA;

PROCEDURE P_UPDATE_DFF(l_vendor_site_id IN NUMBER,
                       p_attribute1     IN VARCHAR2,
                       p_attribute2     IN VARCHAR2,
                       p_attribute3     IN VARCHAR2,
                       p_attribute4     IN VARCHAR2,
                       p_attribute5     IN VARCHAR2,
                       p_attribute6     IN VARCHAR2,
                       p_attribute7     IN VARCHAR2,
                       p_attribute8     IN VARCHAR2,
                       p_retainage_rate IN NUMBER,
                       p_duns_number IN VARCHAR2
                       )
IS
  l_vendor_site_rec AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
  l_return_status     VARCHAR2 (30);
  l_msg_count         NUMBER;
  l_msg_data        VARCHAR2 (3000);
  l_msg_index_out   NUMBER    := NULL;

BEGIN
    l_vendor_site_rec.attribute1 := p_attribute1;
    l_vendor_site_rec.attribute2 := p_attribute2;
    l_vendor_site_rec.attribute3 := p_attribute3;
    l_vendor_site_rec.attribute4 := p_attribute4;
    l_vendor_site_rec.attribute5 := p_attribute5;
    l_vendor_site_rec.attribute6 := p_attribute6;
    l_vendor_site_rec.attribute7 := p_attribute7;
    l_vendor_site_rec.attribute8 := p_attribute8;
    l_vendor_site_rec.retainage_rate := p_retainage_rate;

  fnd_global.apps_initialize(user_id => fnd_global.user_id,
                             resp_id => fnd_global.resp_id,
                             resp_appl_id => fnd_global.resp_appl_id);
  l_return_status     := NULL;
  l_msg_count         := NULL;
  l_msg_data         := NULL;
  ap_vendor_pub_pkg.update_vendor_site (p_api_version => 1.0,
                                        p_init_msg_list => fnd_api.g_true,
                                        p_commit => fnd_api.g_false,
                                        p_validation_level => fnd_api.g_valid_level_full,
                                        x_return_status => l_return_status,
                                        x_msg_count => l_msg_count,
                                        x_msg_data => l_msg_data,
                                        p_vendor_site_rec => l_vendor_site_rec,
                                        p_vendor_site_id => l_vendor_site_id
                                        );

    IF l_return_status =  fnd_api.g_ret_sts_success  THEN
    commit;
  ELSE

    FOR i IN 1 .. l_msg_count
    LOOP
      fnd_msg_pub.get(p_msg_index     => i,
                      p_data          => l_msg_data,
                      p_encoded       => 'F',
                      p_msg_index_out => l_msg_index_out);
      fnd_message.set_encoded(l_msg_data);

    END LOOP;
    rollback;

  END IF;

EXCEPTION
WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - p_update_dff '||SQLCODE||' -ERROR- '||SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END P_UPDATE_DFF;


PROCEDURE P_CREATE_CONTACT_POINT (
   p_party_site_id   IN   NUMBER,
   p_phone_number    IN   VARCHAR2
)
IS
   p_contact_point_rec   hz_contact_point_v2pub.contact_point_rec_type;
   p_edi_rec             hz_contact_point_v2pub.edi_rec_type;
   p_email_rec           hz_contact_point_v2pub.email_rec_type;
   p_phone_rec           hz_contact_point_v2pub.phone_rec_type;
   p_telex_rec           hz_contact_point_v2pub.telex_rec_type;
   p_web_rec             hz_contact_point_v2pub.web_rec_type;
   x_return_status       VARCHAR2 (2000);
   x_msg_count           NUMBER;
   x_msg_data            VARCHAR2 (2000);
   x_contact_point_id    NUMBER;
   lv_api_msg            VARCHAR2 (2000);
   ln_msg_index_out      NUMBER := NULL;
BEGIN
   p_contact_point_rec.contact_point_type     :=     'PHONE';
   p_contact_point_rec.owner_table_name     :=     'HZ_PARTY_SITES';
   p_contact_point_rec.owner_table_id         :=      p_party_site_id;
   p_contact_point_rec.primary_flag         :=      'Y';
   p_phone_rec.phone_number                 :=     p_phone_number;
   p_phone_rec.phone_line_type                 :=      'GEN';
   p_contact_point_rec.created_by_module     :=      'TCA_V2_API';

   hz_contact_point_v2pub.create_contact_point
                                 (p_init_msg_list          => fnd_api.g_true,
                                  p_contact_point_rec      => p_contact_point_rec,
                                  p_edi_rec                => p_edi_rec,
                                  p_email_rec              => p_email_rec,
                                  p_phone_rec              => p_phone_rec,
                                  p_telex_rec              => p_telex_rec,
                                  p_web_rec                => p_web_rec,
                                  x_contact_point_id       => x_contact_point_id,
                                  x_return_status          => x_return_status,
                                  x_msg_count              => x_msg_count,
                                  x_msg_data               => x_msg_data
                                 );

   IF (x_return_status <> fnd_api.g_ret_sts_success)
   THEN
      ln_msg_index_out := NULL;

      FOR i IN 1 .. x_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => x_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (x_msg_data);
         lv_api_msg :=
            lv_api_msg || ' / '
            || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
         fnd_file.put_line (fnd_file.LOG,
                               'Error at CREATE_CONTACT_POINT API : '
                            || i
                            || ', '
                            || x_msg_data
                           );
      END LOOP;

      ROLLBACK;
      fnd_file.put_line (fnd_file.LOG,'Phone NOT Created! and rollback executed');
   END IF;               --if (x_return_status <>  fnd_api.g_ret_sts_success )
EXCEPTION
   WHEN OTHERS
   THEN
      fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
      fnd_file.put_line(fnd_file.LOG,'Error at CREATE_CONTACT_POINT '|| SQLCODE|| ' -ERROR- '|| SQLERRM);
      fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
END P_CREATE_CONTACT_POINT;

PROCEDURE P_ADDRESS_PURPOSE (
   p_party_site_id   IN   NUMBER,
   p_site_use_type   IN   VARCHAR2
)
IS
   p_party_site_use_rec   hz_party_site_v2pub.party_site_use_rec_type;
   x_party_site_use_id    NUMBER;
   x_return_status        VARCHAR2 (2000);
   x_msg_count            NUMBER;
   x_msg_data             VARCHAR2 (2000);
   lv_api_msg             VARCHAR2 (2000);
   ln_msg_index_out       NUMBER                                      := NULL;
BEGIN
   p_party_site_use_rec.site_use_type := p_site_use_type;
   p_party_site_use_rec.party_site_id := p_party_site_id;
   p_party_site_use_rec.created_by_module := 'TCA_V2_API';
   hz_party_site_v2pub.create_party_site_use
                               (p_init_msg_list           => fnd_api.g_true,
                                p_party_site_use_rec      => p_party_site_use_rec,
                                x_party_site_use_id       => x_party_site_use_id,
                                x_return_status           => x_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data
                               );

   IF (x_return_status <> fnd_api.g_ret_sts_success)
   THEN
      ln_msg_index_out := NULL;

      FOR i IN 1 .. x_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => x_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (x_msg_data);
         lv_api_msg :=
            lv_api_msg || ' / '
            || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
         fnd_file.put_line (fnd_file.LOG,
                               'Error at P_ADDRESS_PURPOSE API : '
                            || i
                            || ', '
                            || x_msg_data
                           );
      END LOOP;

      fnd_file.put_line (fnd_file.LOG,
                         'Purpose NOT Created! and rollback executed'
                        );
   ELSE
      COMMIT;
   END IF;               --if (x_return_status <>  fnd_api.g_ret_sts_success )
EXCEPTION
   WHEN OTHERS
   THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error at P_ADDRESS_PURPOSE '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END P_ADDRESS_PURPOSE;

PROCEDURE P_CREATE_EMAIL_CONTACT_POINT( p_party_site_id IN NUMBER, p_email_address IN VARCHAR2 )
IS
p_contact_point_rec             hz_contact_point_v2pub.contact_point_rec_type;
    p_email_rec                   hz_contact_point_v2pub.email_rec_type;
    x_contact_point_id            NUMBER;
    x_return_status                 VARCHAR2(200);
    x_msg_count                    NUMBER;
    x_msg_data                      VARCHAR2(200);
begin
p_contact_point_rec.contact_point_type    := 'EMAIL';
  p_contact_point_rec.owner_table_name      := 'HZ_PARTY_SITES';
  p_contact_point_rec.owner_table_id        := p_party_site_id;
   p_email_rec.email_address                 := p_email_address;
  p_email_rec.email_format                  := 'MAILTEXT';--'MAILHTML';
  p_contact_point_rec.created_by_module     := 'HZ_CPUI';
hz_contact_point_v2pub.create_email_contact_point (
   'T',
    p_contact_point_rec        ,
    p_email_rec                ,
    x_contact_point_id         ,
    x_return_status            ,
    x_msg_count                ,
    x_msg_data
  );
   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
    COMMIT;

ELSE
    ROLLBACK;
    FOR i IN 1 .. x_msg_count
    LOOP
      x_msg_data := fnd_msg_pub.get( p_msg_index => i, p_encoded => 'F');
      fnd_file.put_line (fnd_file.LOG, i|| ' - '|| x_msg_data);
    END LOOP;
END IF;
END P_CREATE_EMAIL_CONTACT_POINT;

PROCEDURE P_SS_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
   ln_attr_value_str2     IN   VARCHAR2,
   p_data_level           IN   VARCHAR2,
   p_data_level_1         IN   NUMBER,
   p_data_level_2         IN   NUMBER
)
IS
   ln_attr_num                    NUMBER                        := NULL;
   ln_msg_index_out               NUMBER                        := NULL;
   lv_failed_row_id_list          VARCHAR2 (100)                := NULL;
   ldt_attr_date                  DATE                          := NULL;
   ln_attr_value_str              VARCHAR2 (50)                 := NULL;
   lv_pk_column_values            ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   lv_attributes_row_table        ego_user_attr_row_table;
   lv_attributes_row_table1       ego_user_attr_row_table;
   lv_attributes_data_table       ego_user_attr_data_table;
   lv_attributes_data_table1      ego_user_attr_data_table;
   lv_class_code                  ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   l_pk_column_name_value_pairs   ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   lv_return_status               VARCHAR2 (10)                 := NULL;
   ln_msg_count                   NUMBER                        := 0;
   lv_msg_data                    VARCHAR2 (1000)               := NULL;
   ln_errorcode                   NUMBER                        := 0;
   lv_attr_name                   VARCHAR2 (50);
   lv_attr_group_id               NUMBER;
   l_data_level_1                 NUMBER;
   l_data_level_2                 NUMBER;
   l_vendor_id                       NUMBER;
   l_vendor_site_id                  NUMBER;
   l_party_site_id                  NUMBER;
   l_ego_col_name                  VARCHAR2 (30);
   l_extension_id            NUMBER;
   l_c_ext_attr1             VARCHAR2 (30);
   l_c_ext_attr2             VARCHAR2 (30);
  l_msg                VARCHAR2(200);

BEGIN
   fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );
l_extension_id    := NULL;
l_c_ext_attr1    := NULL;
l_c_ext_attr2    := NULL;

   BEGIN
      SELECT egoattributeeo.attr_name, ext.attr_group_id
        INTO lv_attr_name, lv_attr_group_id
        FROM ego_attrs_v egoattributeeo, ego_fnd_dsc_flx_ctx_ext ext
       WHERE egoattributeeo.application_id = ext.application_id
         AND egoattributeeo.attr_group_type = ext.descriptive_flexfield_name
         AND egoattributeeo.attr_group_name = ext.descriptive_flex_context_code
         AND egoattributeeo.application_id = 177
         AND egoattributeeo.attr_group_type = 'POS_SUPP_PROFMGMT_GROUP'
         AND egoattributeeo.attr_group_name = lv_attr_group_name
         AND egoattributeeo.attr_display_name = lv_attr_display_name;
           --fnd_file.put_line(fnd_file.LOG,'lv_attr_group_id '||lv_attr_group_id||' lv_attr_name '||lv_attr_name);
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
         fnd_file.put_line (fnd_file.LOG,
                               'lv_attr_group_name '
                            || lv_attr_group_name
                            || ' lv_attr_display_name '
                            || lv_attr_display_name
                           );
         fnd_file.put_line (fnd_file.LOG,
                               'Error at ego_attrs_v '
                            || SQLCODE
                            || ' -ERROR- '
                            || SQLERRM
                           );
         fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
   END;



   lv_pk_column_values.EXTEND (1);
   lv_pk_column_values (1) :=
                         ego_col_name_value_pair_obj ('PARTY_ID', ln_party_id);
   lv_class_code.EXTEND (1);
   lv_class_code (1) :=
                ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE');

   IF lv_attr_group_name = 'XXAH_Supplier_Site_Type'
   THEN
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => lv_attr_name,
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  )
            );
   END IF;

   lv_attributes_row_table :=
      ego_user_attr_row_table
         (ego_user_attr_row_obj
                    (row_identifier         => 1,
                     attr_group_id          => lv_attr_group_id,
                     attr_group_app_id      => 177,
                     attr_group_type        => 'POS_SUPP_PROFMGMT_GROUP',
                     attr_group_name        => lv_attr_group_name,
                     data_level             => p_data_level,
                     data_level_1           => 'N',
                     data_level_2           => p_data_level_1,
                     data_level_3           => p_data_level_2,
                     data_level_4           => NULL,
                     data_level_5           => NULL,
                     transaction_type       => ego_user_attrs_data_pvt.g_create_mode
                    )
         );
   --Supplier uda updation started
   pos_vendor_pub_pkg.process_user_attrs_data
                         (p_api_version                      => 1.0,
                          p_attributes_row_table             => lv_attributes_row_table,
                          p_attributes_data_table            => lv_attributes_data_table,
                          p_pk_column_name_value_pairs       => lv_pk_column_values,
                          p_class_code_name_value_pairs      => lv_class_code,
                          x_failed_row_id_list               => lv_failed_row_id_list,
                          x_return_status                    => lv_return_status,
                          x_errorcode                        => ln_errorcode,
                          x_msg_count                        => ln_msg_count,
                          x_msg_data                         => lv_msg_data
                         );

   IF lv_return_status = fnd_api.g_ret_sts_success
   THEN
        commit;
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'UDA updated '|| lv_attr_group_name);
   ELSE
      fnd_file.put_line (fnd_file.LOG,'Error Message UDA Data  : ' || lv_msg_data);


      FOR i IN 1 .. ln_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => lv_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (lv_msg_data);

         fnd_file.put_line (fnd_file.LOG,
                            'API ERROR - P_UDA : ' || i || ', ' || lv_msg_data
                           );
      END LOOP;

      ROLLBACK;

   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UDA '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
      ROLLBACK;
END P_SS_UDA;

   PROCEDURE P_REPORT(l_con_req_id IN NUMBER)
   IS
    l_print_flag1 VARCHAR2(1) := 'N';
    l_print_flag2 VARCHAR2(1) := 'N';
    l_print_flag3 VARCHAR2(1) := 'N';
   CURSOR c_report(l_reqs_id IN NUMBER)
   IS
   select * from XXAH_PS_EBS_COUPACZ_SUPP
   where CONC_REQUEST_ID = l_reqs_id
   order by CONVERSION_STATUS desc;

   BEGIN

    fnd_file.put_line (fnd_file.OUTPUT, '  ');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT, '|    Program Name => XXAH: PS to EBS Initial load Suppliers - API Program    |');
    fnd_file.put_line (fnd_file.OUTPUT, '|    Request ID => '||l_con_req_id||'                            |');
    fnd_file.put_line (fnd_file.OUTPUT, '|    Request Date => '||sysdate||'                        |');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    --fnd_file.put_line (fnd_file.OUTPUT, '  ');
    --fnd_file.put_line (fnd_file.OUTPUT, '  ');


    FOR r_report IN c_report(l_con_req_id)
    LOOP
    IF r_report.CONVERSION_STATUS = 'P' and    l_print_flag1 = 'N' THEN
    --fnd_file.put_line (fnd_file.OUTPUT,'+---------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT,'|*******************************Processed Records*******************************|');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    l_print_flag1 := 'Y';
    fnd_file.put_line (fnd_file.OUTPUT,'SUPPLIER_SEQ'||' | '|| 'SUPPLIER_NAME'||' | '||'SUPPLIER_SITE_NAME'||' | '||'BANK_NAME'||' | '||'BANK_BRANCH_NAME'||' | '||'BANK_ACCOUNT_NAME'||' | '||'BANK_ACCOUNT_NUMBER'||' | '||'CONVERSION_STATUS'||' | '||'ERROR_LOG'||' | '||'VENDOR_ID'||' | '||'VENDOR_SITE_ID'||' | '||'BANK_ID'||' | '||'BRANCH_ID'||' | '||'ACCT_ID');
    END IF;

    IF r_report.CONVERSION_STATUS = 'E' and  l_print_flag2 = 'N' THEN
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT, '  ');
    fnd_file.put_line (fnd_file.OUTPUT, '  ');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT,'|*********************************Error Records*********************************|');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    l_print_flag2 := 'Y';
     fnd_file.put_line (fnd_file.OUTPUT,'SUPPLIER_SEQ'||' | '|| 'SUPPLIER_NAME'||' | '||'SUPPLIER_SITE_NAME'||' | '||'BANK_NAME'||' | '||'BANK_BRANCH_NAME'||' | '||'BANK_ACCOUNT_NAME'||' | '||'BANK_ACCOUNT_NUMBER'||' | '||'CONVERSION_STATUS'||' | '||'ERROR_LOG'||' | '||'VENDOR_ID'||' | '||'VENDOR_SITE_ID'||' | '||'BANK_ID'||' | '||'BRANCH_ID'||' | '||'ACCT_ID');
     END IF;

    IF r_report.CONVERSION_STATUS = 'A'  and l_print_flag3 = 'N' THEN
    fnd_file.put_line (fnd_file.OUTPUT,'+---------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT,'|*******************************Supplier Exists Records*******************************|');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
        l_print_flag3 := 'Y';
    fnd_file.put_line (fnd_file.OUTPUT,'SUPPLIER_SEQ'||' | '|| 'SUPPLIER_NAME'||' | '||'SUPPLIER_SITE_NAME'||' | '||'BANK_NAME'||' | '||'BANK_BRANCH_NAME'||' | '||'BANK_ACCOUNT_NAME'||' | '||'BANK_ACCOUNT_NUMBER'||' | '||'CONVERSION_STATUS'||' | '||'ERROR_LOG'||' | '||'VENDOR_ID'||' | '||'VENDOR_SITE_ID'||' | '||'BANK_ID'||' | '||'BRANCH_ID'||' | '||'ACCT_ID');
        END IF;


    fnd_file.put_line (fnd_file.OUTPUT,r_report.SUPPLIER_SEQ||' | '||r_report.SUPPLIER_NAME||' | '||r_report.SUPPLIER_SITE_NAME||' | '||r_report.BANK_NAME||' | '||r_report.BANK_BRANCH_NAME||' | '||r_report.BANK_ACCOUNT_NAME||' | '||to_char(replace(r_report.BANK_ACCOUNT_NUMBER,'"',NULL))||' | '||r_report.CONVERSION_STATUS||' | '||r_report.ERROR_LOG||' | '||r_report.VENDOR_ID||' | '||r_report.VENDOR_SITE_ID||' | '||r_report.BANK_ID||' | '||r_report.BRANCH_ID||' | '||r_report.ACCT_ID);
    END LOOP;

   END P_REPORT;

   PROCEDURE p_supplier_check(p_request_id IN NUMBER)
   IS
   l_sup_cnt number;
   cursor c_supp
   is
     SELECT   *
          FROM XXAH_PS_EBS_COUPACZ_SUPP
          where conversion_status = 'N';

   BEGIN

   FOR r_supp IN c_supp
   LOOP
   l_sup_cnt := NULL;

      select count(*) into l_sup_cnt from ap_suppliers where upper(vendor_name) = upper(r_supp.SUPPLIER_NAME);

      IF l_sup_cnt > 0 then

      update XXAH_PS_EBS_COUPACZ_SUPP
      set CONVERSION_STATUS = 'A'
      , conc_request_id = p_request_id
      where SUPPLIER_SEQ = r_supp.SUPPLIER_SEQ;
      commit;
      end if;

   END LOOP;

EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - p_supplier_check '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

   END p_supplier_check;


    END XXAH_AP_SUPPLIER_COUPACZ_PKG;

/
