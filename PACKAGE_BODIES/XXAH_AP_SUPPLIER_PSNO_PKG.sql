--------------------------------------------------------
--  DDL for Package Body XXAH_AP_SUPPLIER_PSNO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_AP_SUPPLIER_PSNO_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPLIER_CONV_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Bank Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY           Remarks
   * 21-May-2015        1.0       Sunil Thamke     Initial
   * 21-Dec-2016        1.1          Sunil Thamke        Added SS with same address of other OU
   ****************************************************************************/
PROCEDURE P_MAIN (errbuf OUT VARCHAR2, retcode OUT NUMBER)
IS
   g_request_id         NUMBER := fnd_global.conc_request_id;
   l_vendor_id            ap_suppliers.vendor_id%TYPE;
   l_vendor_site_id        ap_supplier_sites_all.vendor_site_id%TYPE;
   v_error_exists        VARCHAR2(1);
   v_error_log            VARCHAR2(4000);
   v_return_status            VARCHAR2(1);
   l_error_flag             VARCHAR2(1);
   l_error_msg            VARCHAR2(4000);
   l_ven_site_code        ap_supplier_sites_all.vendor_site_code%TYPE;
   l_vend_site_id        ap_supplier_sites_all.vendor_site_id%TYPE;
   l_new_vendor_site_id        ap_supplier_sites_all.vendor_site_id%TYPE;
   CURSOR c_ps_supplier
   IS
      SELECT   rowid row_id,
            TRIM(xps.supplier_number) supplier_number,
            TRIM(xps.SUPPLIER_NAME)SUPPLIER_NAME,
            trim(XPS.SUPPLIER_SITE_NAME) SUPPLIER_SITE_NAME,
            trim(XPS.OPERATING_UNIT_ID) OPERATING_UNIT_ID,
                        trim(XPS.ADDRESS_LINE1) ADDRESS_LINE1,
                        trim(XPS.ADDRESS_LINE2) ADDRESS_LINE2,
                        trim(XPS.ADDRESS_LINE3) ADDRESS_LINE3,
                        trim(XPS.ADDRESS_LINE4) ADDRESS_LINE4,
                        trim(XPS.CITY) CITY,
                        trim(XPS.POSTAL_CODE) POSTAL_CODE,
                        trim(XPS.COUNTRY) COUNTRY,
                        trim(XPS.COUNTY) COUNTY,
                        trim(PEOPLE_SOFT_NUMBER) PEOPLE_SOFT_NUMBER
          FROM XXAH_PS_EBS_LINK_NUMBER xps
         WHERE status='N'
      ORDER BY supplier_number;

BEGIN
   fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );

    FOR r_ps_supplier IN c_ps_supplier
        LOOP
            l_vendor_id            := NULL;
            l_vendor_site_id    := NULL;
            v_return_status        := NULL;
            v_error_log            := NULL;
            v_error_exists        := NULL;
            l_error_flag        := NULL;
            l_error_msg            := NULL;
            l_ven_site_code        := NULL;
            l_vend_site_id            := NULL;
            l_new_vendor_site_id    := NULL;
            fnd_file.put_line (fnd_file.LOG,'Supplier Number: '||r_ps_supplier.supplier_number);
            fnd_file.put_line (fnd_file.LOG,'Supplier Name: '||r_ps_supplier.SUPPLIER_NAME);
            fnd_file.put_line (fnd_file.LOG,'Supplier Site Name: '||r_ps_supplier.SUPPLIER_SITE_NAME);
                --<Supplier Number Check>--
                if r_ps_supplier.supplier_number is not null AND r_ps_supplier.SUPPLIER_NAME is not null then
                BEGIN
                    select vendor_id
                        into l_vendor_id
                    from ap_suppliers
                    where upper(segment1) = upper(r_ps_supplier.supplier_number)
                    AND upper(vendor_name) = upper(r_ps_supplier.SUPPLIER_NAME);
                    EXCEPTION
                WHEN OTHERS THEN
                    --v_error_exists := 'Y';
                    --v_error_log := v_error_log || '//l_vendor_id : '||substr(SQLERRM,1,255);
                    fnd_file.put_line (fnd_file.LOG,'//Error-1 : Supplier not found '||substr(SQLERRM,1,255));
                END;
                end if;
                fnd_file.put_line (fnd_file.LOG,'vendor_id : '||l_vendor_id);

                    /* --<Supplier Name Check>--
                BEGIN
                    select vendor_id
                        into l_vendor_id
                    from ap_suppliers
                    where upper(vendor_name) = upper(r_ps_supplier.SUPPLIER_NAME);
                    EXCEPTION
                WHEN OTHERS THEN
                    --v_error_exists := 'Y';
                    --v_error_log := v_error_log || '//l_vendor_id : '||substr(SQLERRM,1,255);
                    fnd_file.put_line (fnd_file.LOG,'Error-1.1 : '||substr(SQLERRM,1,255));
                END;
                       fnd_file.put_line (fnd_file.LOG,'vendor_id supplier_number : '||l_vendor_id);*/

                IF l_vendor_id IS NOT NULL and r_ps_supplier.supplier_number is not null THEN
                      BEGIN
                    select vendor_id
                        into l_vendor_id
                    from ap_suppliers
                    where upper(segment1) = upper(r_ps_supplier.supplier_number)
                    AND upper(vendor_name) = upper(r_ps_supplier.SUPPLIER_NAME)
                    AND  nvl(END_DATE_ACTIVE,sysdate)> trunc(sysdate);

                    EXCEPTION
                WHEN OTHERS THEN
                    v_error_exists := 'Y';
                    v_error_log := v_error_log || '//Supplier Inactive';
                    fnd_file.put_line (fnd_file.LOG,'Error-2 : '||v_error_log);
                END;
                END IF;

                 IF l_vendor_id IS NOT NULL and r_ps_supplier.SUPPLIER_NAME is not null THEN
                      BEGIN
                    select vendor_id
                        into l_vendor_id
                    from ap_suppliers
                    where upper(vendor_name) = upper(r_ps_supplier.SUPPLIER_NAME)
                    AND upper(segment1) = upper(r_ps_supplier.supplier_number)
                    AND  nvl(END_DATE_ACTIVE,sysdate)> trunc(sysdate);

                    EXCEPTION
                WHEN OTHERS THEN
                    v_error_exists := 'Y';
                    v_error_log := v_error_log || '//Supplier name inactive';
                    fnd_file.put_line (fnd_file.LOG,'//Supplier name inactive '||v_error_log);
                END;
                END IF;

                IF v_error_exists IS NULL THEN
                --<Create Supplier>--
                IF l_vendor_id IS NULL THEN
                fnd_file.put_line (fnd_file.LOG,'Creating supplier');
                    P_CREATE_SUPPLIER(r_ps_supplier.row_id, r_ps_supplier.SUPPLIER_NAME, l_vendor_id, l_error_flag, l_error_msg);
                    IF l_error_flag = 'Y' THEN
                            v_error_exists := l_error_flag;
                            v_error_log := v_error_log || l_error_msg;
                    END IF;
                END IF;
                --<Supplier Site Name Check>
                IF r_ps_supplier.SUPPLIER_SITE_NAME IS NOT NULL THEN
                    BEGIN
                        select vendor_site_code into l_ven_site_code from ap_supplier_sites_all
                        where vendor_id =l_vendor_id
                        AND upper(vendor_site_code) = upper(r_ps_supplier.SUPPLIER_SITE_NAME)
                        AND org_id = 150;
                        EXCEPTION
                    WHEN OTHERS THEN
                    --v_error_exists := 'Y';
                    --v_error_log := v_error_log || '//l_ven_site_code: : '||substr(SQLERRM,1,255);
                    fnd_file.put_line (fnd_file.LOG,'//Supplier site not exists for OU 150 ');
                    END;

                END IF;

                --<Supplier Site is active or not Check>--
                IF l_vendor_id IS NOT NULL
                    AND l_ven_site_code IS NOT NULL
                    AND r_ps_supplier.SUPPLIER_SITE_NAME IS NOT NULL THEN

                    BEGIN
                        select assa.vendor_site_id
                        into l_vendor_site_id
                        from ap_supplier_sites_all assa, HZ_PARTY_SITES hps
                        where assa.vendor_id = l_vendor_id
                        AND upper(assa.vendor_site_code) = upper(r_ps_supplier.SUPPLIER_SITE_NAME)
                        AND assa.org_id = 150
                        AND assa.location_id = hps.location_id
                        AND HPS.party_site_id=ASSA.party_site_id
                        AND hps.status = 'A'
                        and nvl(assa.INACTIVE_DATE,sysdate)> trunc(sysdate);
                        EXCEPTION
                    WHEN OTHERS THEN
                    --v_error_exists := 'Y';
                    --v_error_log := v_error_log || '//l_vendor_site_id: '||substr(SQLERRM,1,255);
                    fnd_file.put_line (fnd_file.LOG,'//Supplier Site is active or not Check ');
                    END;
                END IF;
                  fnd_file.put_line (fnd_file.LOG,'vendor_site_id : '||l_vendor_site_id);

                --<Create Supplier Site for OU Albert Heijn Netherlands >---<1.1>-
                    IF r_ps_supplier.SUPPLIER_SITE_NAME IS NOT NULL THEN
                     BEGIN
                        select vendor_site_id into l_vend_site_id 
                        from ap_supplier_sites_all
                        where vendor_id = l_vendor_id
                        AND upper(vendor_site_code) = upper(r_ps_supplier.SUPPLIER_SITE_NAME)
                        AND org_id <> 150
                        AND rownum = 1;
                        EXCEPTION
                    WHEN OTHERS THEN
                    --v_error_exists := 'Y';
                    --v_error_log := v_error_log || '//l_vend_site_id: : '||substr(SQLERRM,1,255);
                    l_vend_site_id    := NULL;
                    fnd_file.put_line (fnd_file.LOG,'//No supplier site with same name of other OU');
                    END;
                    END IF;
                    
                    --<1.1>-
                IF l_vendor_site_id IS NULL AND l_ven_site_code IS NULL AND l_vend_site_id IS NOT NULL THEN
               l_error_flag := NULL;
                l_error_msg := NULL;
            P_SUPPLIER_SITE_AHN(l_vendor_id,
                    l_vend_site_id,
                       l_error_flag,
                        l_error_msg,
                        l_new_vendor_site_id);
                  IF l_error_flag = 'Y' THEN
                            v_error_exists := l_error_flag;
                            v_error_log := v_error_log || l_error_msg;
                    END IF;
                    
                    --<update people soft number >--
                IF l_vendor_id IS NOT NULL
                AND l_new_vendor_site_id IS NOT NULL
                AND v_error_exists IS NULL THEN
                    P_UPDATE_DFF(l_new_vendor_site_id, r_ps_supplier.PEOPLE_SOFT_NUMBER, v_return_status);
                END IF;
                
        END IF;
                    
                --<Create Supplier Site>--
                IF l_vendor_site_id IS NULL AND l_ven_site_code IS NULL AND l_vend_site_id IS NULL THEN
                l_error_flag := NULL;
                l_error_msg := NULL;

                    P_SUPPLIER_SITE(l_vendor_id ,
                        r_ps_supplier.SUPPLIER_SITE_NAME,
                        r_ps_supplier.OPERATING_UNIT_ID,
                        r_ps_supplier.ADDRESS_LINE1,
                        r_ps_supplier.ADDRESS_LINE2,
                        r_ps_supplier.ADDRESS_LINE3,
                        r_ps_supplier.ADDRESS_LINE4,
                        r_ps_supplier.CITY,
                        r_ps_supplier.POSTAL_CODE,
                        r_ps_supplier.COUNTRY,
                        r_ps_supplier.COUNTY,
                        l_vendor_site_id,
                        l_error_flag,
                        l_error_msg
                        );
                    IF l_error_flag = 'Y' THEN
                            v_error_exists := l_error_flag;
                            v_error_log := v_error_log || l_error_msg;
                    END IF;
                END IF;
fnd_file.put_line (fnd_file.LOG,'v_error_exists'||v_error_exists);
                --<update people soft number >--
                IF l_vendor_id IS NOT NULL
                AND l_vendor_site_id IS NOT NULL
                AND v_error_exists IS NULL THEN
                    P_UPDATE_DFF(l_vendor_site_id, r_ps_supplier.PEOPLE_SOFT_NUMBER, v_return_status);
                END IF;

                    END IF; --IF v_error_exists IS NULL THEN

        IF l_vendor_id IS NOT NULL AND v_return_status = 'S' THEN
            update XXAH_PS_EBS_LINK_NUMBER
            set status = 'P',
            vendor_id = l_vendor_id,
            vendor_site_id = l_vendor_site_id,
            REQUEST_ID = g_request_id
            where rowid = r_ps_supplier.row_id;

            ELSE
            update XXAH_PS_EBS_LINK_NUMBER
            set status = 'E',
            error_log = v_error_log,
            vendor_id = l_vendor_id,
            vendor_site_id = l_vendor_site_id,
            REQUEST_ID = g_request_id
            where rowid = r_ps_supplier.row_id;

        END IF;


                    commit;

        END LOOP;

        P_REPORT(g_request_id);

END P_MAIN;

PROCEDURE P_CREATE_SUPPLIER(p_row_id IN VARCHAR2, p_supp_name IN VARCHAR2, p_vendor_id OUT NUMBER, p_error_flag OUT VARCHAR2, p_error_msg OUT VARCHAR2)
IS

   lv_return_status                VARCHAR2 (10);
   lv_msg_count                    NUMBER;
   lv_msg_data                     VARCHAR2 (1000);
   l_api_error_flag                VARCHAR2 (1);
   l_api_error_msg                 VARCHAR2 (4000);
   l_vendor_id            ap_suppliers.vendor_id%TYPE;
   l_party_id            ap_suppliers.party_id%TYPE;
      ln_msg_index_out                NUMBER   ;
         lv_api_msg                      VARCHAR2 (8000);
          lv_vendor_rec                   ap_vendor_pub_pkg.r_vendor_rec_type;

   BEGIN

   l_vendor_id := NULL;
             --<Supplier Name Check>--
                BEGIN
                    select vendor_id
                        into l_vendor_id
                    from ap_suppliers
                    where upper(vendor_name) = upper(p_supp_name);
                     fnd_file.put_line (fnd_file.LOG,'//Supplier already exists.');
                    p_vendor_id :=  l_vendor_id;
                    
                    EXCEPTION
                WHEN OTHERS THEN
NULL;
                END;
IF l_vendor_id IS NULL THEN
      --<Assingning Staging Table Data To Record Type>--
      lv_vendor_rec.vendor_name             := p_supp_name;

      --<API To Create Supplier>--
      lv_msg_count         := '';
      lv_return_status     := NULL;
fnd_file.put_line (fnd_file.LOG, 'Creating Supplier');
         ap_vendor_pub_pkg.create_vendor
                                        (p_api_version        => 1,
                                         p_vendor_rec         => lv_vendor_rec,
                                         x_return_status      => lv_return_status,
                                         x_msg_count          => lv_msg_count,
                                         x_msg_data           => lv_msg_data,
                                         x_vendor_id          => l_vendor_id,
                                         x_party_id           => l_party_id
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
            fnd_file.put_line(fnd_file.LOG,'Supplier NOT Created! and rollback executed');
            fnd_file.put_line(fnd_file.LOG,'+--------------------------------------+');
            l_api_error_flag     := 'Y';
            l_api_error_msg      := 'CREATE_VENDOR : ' || lv_api_msg;

            p_error_flag := l_api_error_flag;
            p_error_msg  := l_api_error_msg;
         ELSE
            IF l_vendor_id IS NOT NULL
            THEN
            p_vendor_id :=  l_vendor_id;
               fnd_file.put_line (fnd_file.LOG, '--Supplier created');
               commit;
            END IF;                             --IF (lv_return_status <> 'S')
         END IF;        --IF (lv_return_status <>  fnd_api.g_ret_sts_success )
        END IF; --IF l_vendor_id IS NULL THEN
END P_CREATE_SUPPLIER;

PROCEDURE P_SUPPLIER_SITE(p_vendor_id IN NUMBER,
p_supplier_site_name IN VARCHAR2,
p_operating_unit_id IN NUMBER,
p_ad_line1 IN VARCHAR2,
p_ad_line2 IN VARCHAR2,
p_ad_line3 IN VARCHAR2,
p_ad_line4 IN VARCHAR2,
p_city IN VARCHAR2,
p_zip_code IN VARCHAR2,
p_country IN VARCHAR2,
p_county IN VARCHAR2,
p_vendor_site_id OUT NUMBER,
p_err_flag OUT VARCHAR2,
p_err_msg OUT VARCHAR2
)
IS
   lv_return_status                VARCHAR2 (10);
   lv_msg_count                    NUMBER;
   lv_msg_data                     VARCHAR2 (1000);
   l_api_error_flag                VARCHAR2 (1);
   l_api_error_msg                 VARCHAR2 (4000);
   l_vendor_id                        ap_suppliers.vendor_id%TYPE;
   l_party_id                        ap_suppliers.party_id%TYPE;
   ln_msg_index_out                NUMBER   ;
   lv_api_msg                      VARCHAR2 (8000);
   lv_vendor_rec                   ap_vendor_pub_pkg.r_vendor_rec_type;
   lv_vendor_site_rec              ap_vendor_pub_pkg.r_vendor_site_rec_type;
   x_return_status                 VARCHAR2 (1);
   x_msg_data                      VARCHAR2 (8000);
   x_vendor_site_id                NUMBER;
   x_party_site_id                 NUMBER;
   x_location_id                   NUMBER;
BEGIN

         lv_vendor_site_rec.vendor_id           := p_vendor_id;
         lv_vendor_site_rec.vendor_site_code    := p_supplier_site_name;
         lv_vendor_site_rec.org_id              := p_operating_unit_id;
         lv_vendor_site_rec.address_line1       := p_ad_line1;
         lv_vendor_site_rec.address_line2       := p_ad_line2;
         lv_vendor_site_rec.address_line3       := p_ad_line3;
         lv_vendor_site_rec.address_line4       := p_ad_line4;
         lv_vendor_site_rec.city                := p_city;
         lv_vendor_site_rec.zip                 := p_zip_code;
         lv_vendor_site_rec.country             := p_country;
         lv_vendor_site_rec.county              := p_county;

         lv_return_status                        := NULL;
         lv_msg_count                             := NULL;
fnd_file.put_line (fnd_file.LOG, 'Creating Supplier Site');
         ap_vendor_pub_pkg.create_vendor_site
                                    (p_api_version          => 1,
                                     x_return_status        => lv_return_status,
                                     x_msg_count            => lv_msg_count,
                                     x_msg_data             => x_msg_data,
                                     p_vendor_site_rec      => lv_vendor_site_rec,
                                     x_vendor_site_id       => x_vendor_site_id,
                                     x_party_site_id        => x_party_site_id,
                                     x_location_id          => x_location_id
                                    );

         IF (lv_return_status <> fnd_api.g_ret_sts_success)
         THEN
            fnd_file.put_line (fnd_file.LOG,'ERROR in supplier site creation');
            fnd_file.put_line (fnd_file.LOG,'+--------------------------------------+');
            ln_msg_index_out := NULL;

            FOR i IN 1 .. lv_msg_count
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
            p_err_flag := l_api_error_flag;
            p_err_msg  := l_api_error_msg;
         ELSE
            IF x_vendor_site_id IS NOT NULL
            THEN
                p_vendor_site_id    := x_vendor_site_id;
                COMMIT;
               fnd_file.put_line (fnd_file.LOG, '--Supplier Site Created');
               l_api_error_flag := 'N';
                        --<Supplier Site END>--
            END IF;
            END IF;

END P_SUPPLIER_SITE;

--<1.1>-
PROCEDURE P_SUPPLIER_SITE_AHN(p_vendor_id IN NUMBER, 
p_vendor_site_id IN NUMBER,
p_errflag OUT VARCHAR2,
p_errmsg OUT VARCHAR2 ,
p_new_vend_site_id OUT NUMBER)
IS


      ln_msg_index_out                NUMBER   ;
       lv_api_msg                      VARCHAR2 (8000);
      
 CURSOR c_vendor_sites IS
   SELECT vendor_site_code,
          vendor_id,
          org_id,
      party_site_id,
          address_line1,
          address_line2,
          address_line3,
          address_line4,
          city,
          state,
          zip,
          province,
          county,
          country,
          area_code,
          phone,
          fax_area_code,
          fax,
          email_address,
          purchasing_site_flag,
          pay_site_flag,
          rfq_only_site_flag,
          hold_all_payments_flag,
          duns_number,location_id
    FROM ap_supplier_sites_all
    WHERE vendor_site_id = p_vendor_site_id;  -- used to create a new vendor site in a different OU

 l_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
 l_vendor_rec_type ap_vendor_pub_pkg.r_vendor_rec_type;
 p_api_version       NUMBER   := 1;
 p_commit            VARCHAR2(1) := FND_API.G_TRUE;  
 x_return_status  VARCHAR2(1);
 x_msg_count      NUMBER;
 x_msg_data       VARCHAR2(2000);
 x_vendor_site_id NUMBER;
 x_party_site_id  NUMBER;
 x_location_id    NUMBER;
 v_vendor_id      NUMBER;

BEGIN
fnd_global.apps_initialize(21312, 51038, 201);
 FOR r_site IN c_vendor_sites LOOP
   v_vendor_id := p_vendor_id;
 
   l_vendor_site_rec.vendor_id              := r_site.vendor_id;
   l_vendor_site_rec.vendor_site_code       := r_site.vendor_site_code;
   l_vendor_site_rec.org_id                 := 150; -- Target ORG ID where the new Site will be created
   l_vendor_site_rec.party_site_id          := r_site.party_site_id;
   l_vendor_site_rec.location_id            := r_site.location_id ;
   l_vendor_site_rec.address_line1          := r_site.address_line1;
   l_vendor_site_rec.address_line2          := r_site.address_line2;
   l_vendor_site_rec.address_line3          := r_site.address_line3;
   l_vendor_site_rec.address_line4          := r_site.address_line4;
   l_vendor_site_rec.city                  := r_site.city;
   l_vendor_site_rec.zip                    := r_site.zip;
   --l_vendor_site_rec.province               := r_site.province;
   l_vendor_site_rec.county                 := r_site.county;
   l_vendor_site_rec.country                := r_site.country;
   l_vendor_site_rec.purchasing_site_flag   := r_site.purchasing_site_flag;
   l_vendor_site_rec.pay_site_flag          := r_site.pay_site_flag;
   l_vendor_site_rec.email_address          := r_site.email_address;
   /*l_vendor_site_rec.area_code              := r_site.area_code;
   l_vendor_site_rec.phone                  := r_site.phone;
   l_vendor_site_rec.fax_area_code          := r_site.fax_area_code;
   l_vendor_site_rec.fax                    := r_site.fax;
   l_vendor_site_rec.rfq_only_site_flag     := r_site.rfq_only_site_flag;
   l_vendor_site_rec.hold_all_payments_flag := r_site.hold_all_payments_flag;
   l_vendor_site_rec.duns_number            := r_site.duns_number;
   l_vendor_site_rec.language             := 'AMERICAN'; --- Language
   l_vendor_site_rec.address_style        := 'POSTAL_ADDR_US'; */ --- Address Style of the country which needs to be done. Take address style code of the specific country
  --DBMS_OUTPUT.PUT_LINE( l_vendor_site_rec.party_site_id );
   ap_vendor_pub_pkg.create_vendor_site(p_api_version     => p_api_version,
                                        p_commit          => p_commit,
                                        x_return_status   => x_return_status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_vendor_site_rec => l_vendor_site_rec,
                                        x_vendor_site_id  => x_vendor_site_id,
                                        x_party_site_id   => x_party_site_id,
                                        x_location_id     => x_location_id);
 
   IF x_return_status = fnd_api.g_ret_sts_success THEN
        fnd_file.put_line(fnd_file.LOG,'Vendor Site Created with same address');
        fnd_file.put_line(fnd_file.LOG,'New Vendor Site id is : ' || x_vendor_site_id);
        fnd_file.put_line(fnd_file.LOG,'New Party Site id is  : ' || x_party_site_id);
        fnd_file.put_line(fnd_file.LOG,'New Location Id is    : ' || x_location_id);
        
        p_new_vend_site_id := x_vendor_site_id;
   ELSE
     fnd_file.put_line(fnd_file.LOG,'Return Status ' || x_return_status );
        
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
                                     'Error at P_SUPPLIER_SITE_AHN : '
                                  || i
                                  || ', '
                                  || x_msg_data
                                 );
           fnd_file.put_line(fnd_file.LOG,'P_SUPPLIER_SITE_AHN error'|| lv_api_msg );   

            END LOOP;
                    p_errflag := 'Y';
                    p_errmsg  := lv_api_msg;
            
   END IF;
 END LOOP;
END P_SUPPLIER_SITE_AHN;

PROCEDURE P_UPDATE_DFF(l_vendor_site_id IN NUMBER,
                       p_attribute9     IN VARCHAR2,
                       l_ret_status OUT VARCHAR2
                       )
IS
  l_vendor_site_rec AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
  l_return_status     VARCHAR2 (30);
  l_msg_count         NUMBER;
  l_msg_data        VARCHAR2 (3000);
  l_msg_index_out   NUMBER    := NULL;
  lv_return_status  VARCHAR2(1);
  lv_api_msg     VARCHAR2 (8000);

BEGIN
    lv_api_msg:= null;
    l_vendor_site_rec.ATTRIBUTE9 := p_attribute9;

  fnd_global.apps_initialize(user_id => fnd_global.user_id,
                             resp_id => fnd_global.resp_id,
                             resp_appl_id => fnd_global.resp_appl_id);
  l_return_status     := NULL;
  l_msg_count         := NULL;
  l_msg_data         := NULL;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating PS number'||l_vendor_site_id);
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
    l_ret_status := l_return_status;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'l_ret_status '||l_ret_status);
    IF l_return_status =  fnd_api.g_ret_sts_success  THEN
    commit;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'--PS number updated.');
  ELSE
    FOR i IN 1 .. l_msg_count
    LOOP
      fnd_msg_pub.get(p_msg_index     => i,
                      p_data          => l_msg_data,
                      p_encoded       => 'F',
                      p_msg_index_out => l_msg_index_out);
      fnd_message.set_encoded(l_msg_data);
               lv_api_msg :=
                     SUBSTR(lv_api_msg,1,200)
                  || ' / '
                  || ('Msg' || TO_CHAR (i) || ': ' ||SUBSTR(l_msg_data,1,200));
               fnd_file.put_line (fnd_file.LOG,
                                     'Error at UPDATE Supplier Site : '
                                  || i
                                  || ', '
                                  || l_msg_data
                                 );
    END LOOP;

    rollback;

  END IF;

EXCEPTION
WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - p_update_dff '||SQLCODE||' -ERROR- '||SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END P_UPDATE_DFF;

   PROCEDURE P_REPORT(l_con_req_id IN NUMBER)
   IS
    l_print_flag1 VARCHAR2(1) := 'N';
    l_print_flag2 VARCHAR2(1) := 'N';
    l_print_flag3 VARCHAR2(1) := 'N';
   CURSOR c_report(l_reqs_id IN NUMBER)
   IS
   select * from XXAH_PS_EBS_LINK_NUMBER
   where REQUEST_ID = l_reqs_id
   order by STATUS desc;

   BEGIN

    fnd_file.put_line (fnd_file.OUTPUT, '  ');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT, '|    Program Name => XXAH: Supplier People Soft Number Updation Program    |');
    fnd_file.put_line (fnd_file.OUTPUT, '|    Request ID => '||l_con_req_id||'                            |');
    fnd_file.put_line (fnd_file.OUTPUT, '|    Request Date => '||sysdate||'                        |');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');


    FOR r_report IN c_report(l_con_req_id)
    LOOP
    IF r_report.STATUS = 'P' and    l_print_flag1 = 'N' THEN
    --fnd_file.put_line (fnd_file.OUTPUT,'+---------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT,'|*******************************Processed Records*******************************|');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    l_print_flag1 := 'Y';
    fnd_file.put_line (fnd_file.OUTPUT,'SUPPLIER_NAME'||' | '||'SUPPLIER_SITE_NAME'||' | '||'STATUS'||' | '||'ERROR_LOG'||' | '||'VENDOR_ID'||' | '||'VENDOR_SITE_ID');
    END IF;

    IF r_report.STATUS = 'E' and  l_print_flag2 = 'N' THEN
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT, '  ');
    fnd_file.put_line (fnd_file.OUTPUT, '  ');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT,'|*********************************Error Records*********************************|');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
    l_print_flag2 := 'Y';
 fnd_file.put_line (fnd_file.OUTPUT,'SUPPLIER_NAME'||' | '||'SUPPLIER_SITE_NAME'||' | '||'STATUS'||' | '||'ERROR_LOG'||' | '||'VENDOR_ID'||' | '||'VENDOR_SITE_ID');
     END IF;

   /* IF r_report.CONVERSION_STATUS = 'A'  and l_print_flag3 = 'N' THEN
    fnd_file.put_line (fnd_file.OUTPUT,'+---------------------------------------------------------------------------+');
    fnd_file.put_line (fnd_file.OUTPUT,'|*******************************Supplier Exists Records*******************************|');
    fnd_file.put_line (fnd_file.OUTPUT,'+-------------------------------------------------------------------------------+');
        l_print_flag3 := 'Y';
    fnd_file.put_line (fnd_file.OUTPUT,'SUPPLIER_SEQ'||' | '|| 'SUPPLIER_NAME'||' | '||'SUPPLIER_SITE_NAME'||' | '||'BANK_NAME'||' | '||'BANK_BRANCH_NAME'||' | '||'BANK_ACCOUNT_NAME'||' | '||'BANK_ACCOUNT_NUMBER'||' | '||'CONVERSION_STATUS'||' | '||'ERROR_LOG'||' | '||'VENDOR_ID'||' | '||'VENDOR_SITE_ID'||' | '||'BANK_ID'||' | '||'BRANCH_ID'||' | '||'ACCT_ID');
        END IF;*/


    fnd_file.put_line (fnd_file.OUTPUT,r_report.SUPPLIER_NAME||' | '||r_report.SUPPLIER_SITE_NAME||' | '||r_report.STATUS||' | '||r_report.ERROR_LOG||' | '||r_report.VENDOR_ID||' | '||r_report.VENDOR_SITE_ID);
    END LOOP;

   END P_REPORT;


END XXAH_AP_SUPPLIER_PSNO_PKG; 

/
