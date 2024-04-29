--------------------------------------------------------
--  DDL for Package Body XXAH_SUPP_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SUPP_UPDATE_PKG" as
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_SUPP_UPDATE_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Update Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 25-May-2016        1.0       Sunil Thamke     Initial
   * 24-Jun-2016        1.1          Sunil Thamke       Added Supplier Inactive and Error supplier if same supplier errored.
   ****************************************************************************/
gv_request_id                     fnd_concurrent_requests.request_id%TYPE:= Fnd_Global.conc_request_id;
gv_commit_flag                    VARCHAR2(1);
gv_api_msg                        VARCHAR2(2000);

PROCEDURE P_GET_VENDOR_ID
IS
l_vendor_id                     ap_suppliers.vendor_id%TYPE;
l_party_id                    hz_parties.party_id%TYPE;
l_object_version_number        hz_parties.object_version_number%TYPE;
l_vendor_name                ap_suppliers.vendor_name%TYPE;
l_vendor_site_id            ap_supplier_sites_all.vendor_site_id%TYPE;
l_location_id                ap_supplier_sites_all.location_id%TYPE;
l_party_site_id                ap_supplier_sites_all.party_site_id%TYPE;
l_error_flag                varchar2(1);
l_error_log                    varchar2(240);
l_territory_code            fnd_territories.TERRITORY_CODE%TYPE;
l_email    varchar2(240);
l_xxah_supplier_type_att        POS_XXAH_SUPPLIER_TY_AGV.XXAH_SUPPLIER_TYPE_ATT%TYPE;
l_leaf_commodity                xxah_ps_ebs_supp_update.leaf_commodity%TYPE;
l_content_group                    xxah_ps_ebs_supp_update.content_group%TYPE;
l_count    NUMBER;

CURSOR c_get_supplier_id IS
select rowid, a.* from xxah_ps_ebs_supp_update a
          where nvl(a.conversion_status,'N') = 'N'
          and a.supplier_type='NFR'
          ORDER BY OLD_SUPPLIER_NAME;

    BEGIN
        FOR r_get_supplier_id IN c_get_supplier_id
        LOOP
                l_vendor_id                 := NULL;
                l_vendor_name             := NULL;
                l_object_version_number    := NULL;
                l_party_id                := NULL;
                l_vendor_site_id        := NULL;
                l_location_id            := NULL;
                l_error_log                := NULL;
                l_error_flag             := NULL;
                l_party_site_id            := NULL;
                l_territory_code        := NULL;
                l_email                    := NULL;
                l_xxah_supplier_type_att    := NULL;
                l_leaf_commodity            := NULL;
                l_content_group                := NULL;
                l_count        := NULL;

        BEGIN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Validating Supplier > '|| r_get_supplier_id.old_supplier_name );
FND_FILE.PUT_LINE(FND_FILE.LOG,'Validating Site > '|| r_get_supplier_id.SUPPLIER_SITE_NAME );

            BEGIN
                select aps.vendor_id, aps.vendor_name, hzp.PARTY_ID
                into l_vendor_id, l_vendor_name, l_party_id
                    from ap_suppliers aps, hz_parties hzp,POS_XXAH_SUPPLIER_TY_AGV xxah
                where aps.party_id = hzp.party_id
                and aps.party_id=xxah.party_id
                and xxah.XXAH_SUPPLIER_TYPE_ATT='NFR'
                AND upper(aps.vendor_name) =upper(r_get_supplier_id.old_supplier_name);

                IF l_vendor_id is not null then
                l_error_flag := 'N';
                END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                    BEGIN

                        select aps.vendor_id, xxah.XXAH_SUPPLIER_TYPE_ATT
                            into l_vendor_id, l_xxah_supplier_type_att
                            from ap_suppliers aps, hz_parties hzp,POS_XXAH_SUPPLIER_TY_AGV xxah
                            where aps.party_id = hzp.party_id
                            and aps.party_id=xxah.party_id
                            AND upper(aps.vendor_name) =upper(r_get_supplier_id.old_supplier_name);
                            IF l_vendor_id IS NOT NULL THEN
                                    l_error_flag := 'Y';
                                    l_error_log := l_error_log||'//Supplier Type is not NFR!!! And Type is '||l_xxah_supplier_type_att;
                            ELSE
                                l_error_flag := 'Y';
                                l_error_log := l_error_log||'//Supplier Not Found !!! ';
                            END IF;
                        EXCEPTION
                        WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Supplier Not Found :  '||SQLCODE||'-'||SQLERRM;
                        NULL;
                    END;
                    NULL;
                END;

                IF l_vendor_id IS NOT NULL THEN

                --Get Supplier Site ID
                IF r_get_supplier_id.SUPPLIER_SITE_NAME is NOT NULL THEN
                BEGIN
                    select apss.vendor_site_id, apss.party_site_id, apss.location_id
                    into l_vendor_site_id, l_party_site_id, l_location_id
                        from ap_suppliers aps, AP_SUPPLIER_SITES_ALL  apss
                        where aps.vendor_id = apss.vendor_id
                    AND aps.vendor_id = l_vendor_id
                    and (INACTIVE_DATE is  null OR INACTIVE_DATE > sysdate)  --<1.1>--
                    and apss.org_id=83
                    AND upper(apss.vendor_site_code) = upper(r_get_supplier_id.SUPPLIER_SITE_NAME);
                    EXCEPTION
                        WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//SUPPLIER_SITE_NAME : '||SQLCODE||'-'||SQLERRM;
                        NULL;
                    END;
                END IF;

                IF r_get_supplier_id.COUNTRY IS NOT NULL THEN
                BEGIN
                select TERRITORY_CODE into l_territory_code from  fnd_territories where TERRITORY_CODE = r_get_supplier_id.COUNTRY
                AND OBSOLETE_FLAG = 'N';

                IF l_territory_code IS NULL THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid Country';
                END IF;
                  EXCEPTION
                        WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid Country - not found '||SQLCODE||'-'||SQLERRM;
                        NULL;
                END;
                END IF;

                IF r_get_supplier_id.PO_EMAIL_ADDRESS IS NOT NULL THEN
                BEGIN
                    select PO_EMAIL_ADDRESS into l_email from xxah_ps_ebs_supp_update
                    where REGEXP_LIKE(r_get_supplier_id.PO_EMAIL_ADDRESS,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')
                    AND rowid = r_get_supplier_id.rowid;

                    IF l_email IS NULL THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid email';
                    END IF;
                  EXCEPTION
                        WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid PO_EMAIL_ADDRESS: '||SQLCODE||'-'||SQLERRM;
                        NULL;
                    END;
                END IF;

                IF r_get_supplier_id.PO_MATCH IS NOT NULL THEN
                IF r_get_supplier_id.PO_MATCH not in ('2-way match','3-way match','4-way match')
                THEN

                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid PO_MATCH';
                END IF;
                END IF;
        IF r_get_supplier_id.leaf_commodity IS NOT NULL THEN
        BEGIN
        SELECT flex_value
        INTO   l_leaf_commodity
        FROM   fnd_flex_values_vl ffv
              ,fnd_flex_value_sets ffvs
        WHERE  ffvs.flex_value_set_id = ffv.flex_value_set_id
        AND    flex_value_set_name    = 'XXAH_LEAF_COMMODITY'
        AND    flex_value     = r_get_supplier_id.leaf_commodity
        AND    ffv.enabled_flag       = 'Y'
        AND    TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) and nvl(end_date_active,to_date('31-DEC-4721','DD-MON-YYYY'));

        IF l_leaf_commodity IS NULL THEN
                                l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid XXAH_LEAF_COMM: ';
        END IF;
      EXCEPTION WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid XXAH_LEAF_COMM: '||SQLCODE||'-'||SQLERRM;
      END;
      END IF;

        IF r_get_supplier_id.CONTENT_GROUP IS NOT NULL THEN
        BEGIN
        SELECT flex_value
        INTO   l_content_group
        FROM   fnd_flex_values_vl ffv
              ,fnd_flex_value_sets ffvs
        WHERE  ffvs.flex_value_set_id = ffv.flex_value_set_id
        AND    flex_value_set_name    = 'XXAH_COUPA_CONTENT_GROUP'
        AND    flex_value     = r_get_supplier_id.CONTENT_GROUP
        AND    ffv.enabled_flag       = 'Y'
        AND    TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) and nvl(end_date_active,to_date('31-DEC-4721','DD-MON-YYYY'));

        IF l_content_group IS NULL THEN
                                l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid CONTENT_GROUP: ';
        END IF;
      EXCEPTION WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid CONTENT_GROUP: '||SQLCODE||'-'||SQLERRM;
      END;
      END IF;
       END IF;--IF l_vendor_id IS NOT NULL THEN

IF l_error_flag = 'Y' THEN
  UPDATE xxah_ps_ebs_supp_update
  SET    conversion_status = 'E' ,
         error_log = l_error_log ,
         request_id = gv_request_id
  WHERE  ROWID = r_get_supplier_id.ROWID;
  COMMIT;
  FND_FILE.put_line(fnd_file.log,'Error Record - '
  ||r_get_supplier_id.supplier_site_name );
  FND_FILE.put_line(fnd_file.log,'Error > '||l_error_log);
  ELSE
  UPDATE xxah_ps_ebs_supp_update
  SET    ora_vendor_id = l_vendor_id ,
         ora_vendor_name = l_vendor_name ,
         ora_party_id = l_party_id ,
         ora_vendor_site_id = l_vendor_site_id ,
         ora_party_site_id = l_party_site_id ,
         ora_location_id = l_location_id ,
         conversion_status = 'V' ,
         request_id = gv_request_id
  WHERE  ROWID = r_get_supplier_id.ROWID;
  COMMIT;
  FND_FILE.put_line(fnd_file.log,'Valid Record - '
  ||r_get_supplier_id.supplier_site_name );
END IF;

  P_SUPPLIER_UPDATE(r_get_supplier_id.old_supplier_name);

EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_GET_VENDOR_ID '||SQLCODE||' -ERROR- '||SQLERRM);
NULL;
END;
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

        END LOOP;

    EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_GET_VENDOR_ID '||SQLCODE||' -ERROR- '||SQLERRM);

    END P_GET_VENDOR_ID;

PROCEDURE P_UPDATE_SUPPLIER(errbuf OUT VARCHAR2
                           ,retcode OUT NUMBER) is
l_vendor HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
v_return_status VARCHAR2(2000);
v_msg_count NUMBER;
v_msg_data VARCHAR2(2000);
v_profile_id NUMBER;
V_OBJECT NUMBER :=1;
l_party_id  hz_parties.party_id%type;
l_vendor_name  ap_suppliers.vendor_name%type;
l_object_version_number hz_parties.object_version_number%type;
v_uan_status        VARCHAR2(1);
l_msg_index_out         NUMBER    := NULL;
l_api_msg VARCHAR2(2000);
        l_api_error_flag        VARCHAR2(1);
        l_api_error_msg            VARCHAR2(2000);


l_msg_data                   varchar2 (20000);
l_return_status              varchar2 (100);
l_msg_count                  number;

l_vendor_rec                 ap_vendor_pub_pkg.r_vendor_rec_type;

cursor c1 is select rowid, xxsu.* from xxah_ps_ebs_supp_update xxsu
                      where xxsu.conversion_status ='V'
                      and xxsu.supplier_type='NFR'
                      and REQUEST_ID = gv_request_id
                      AND ORA_VENDOR_ID is not null
                      ORDER BY ROWID;

BEGIN

P_GET_VENDOR_ID;

for i in c1 loop
v_uan_status:= NULL;
        l_api_error_flag    := NULL;
        l_api_error_msg     := NULL;
        gv_commit_flag      := 'Y';
        l_object_version_number := NULL;

--fnd_file.put_line(fnd_file.log,'Start For Loop ');
fnd_file.put_line(fnd_file.log,'Old Supplier Name => '||i.old_supplier_name ||' '||' New Supplier Name => '||i.NEW_SUPPLIER_NAME);

 select hzp.object_version_number
                into l_object_version_number
                    from hz_parties hzp
                where PARTY_ID = i.ORA_PARTY_ID;

l_vendor.party_rec.party_id := i.ORA_PARTY_ID;
l_vendor.organization_name := i.NEW_SUPPLIER_NAME;
v_object := l_object_version_number;

IF i.VAT_REGISTRATION_NUM IS NOT NULL THEN
        l_vendor.tax_reference    := i.VAT_REGISTRATION_NUM    ;
END IF;

HZ_PARTY_V2PUB.update_organization (
p_init_msg_list => fnd_api.g_true, --FND_API.G_FALSE,
p_organization_rec => l_vendor ,
p_party_object_version_number => v_object,
x_profile_id => v_profile_id,
x_return_status => v_return_status,
x_msg_count => v_msg_count,
x_msg_data => v_msg_data
);

fnd_file.put_line(fnd_file.log,'--NEW_SUPPLIER_NAME => '||v_return_status);
if (v_return_status <> 'S') then
    ROLLBACK;
    gv_commit_flag := 'N';
--fnd_file.put_line(fnd_file.log,l_msg_data);
l_api_msg := NULL;
IF v_msg_count >= 1 THEN
FOR i IN 1..v_msg_count LOOP
                    fnd_msg_pub.get(p_msg_index     => i,
                                    p_data          => v_msg_data,
                                    p_encoded       => 'F',
                                    p_msg_index_out => l_msg_index_out);
                    fnd_message.set_encoded(v_msg_data);
l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| v_msg_data);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - NEW_SUPPLIER_NAME -ERROR- '||l_api_msg);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END LOOP;
l_api_error_flag     :=    'Y';
l_api_error_msg     :=    '//Update NEW_SUPPLIER_NAME : '||l_api_msg;
END IF;

                          p_write_log(i.rowid, l_api_error_msg);

end if;


IF i.PO_MATCH IS NOT NULL AND gv_commit_flag <> 'N' THEN
    P_UPDATE_VENDOR (i.rowid, i.ora_vendor_id, i.PO_MATCH);
END IF;

IF (i.ADDRESS_LINE1 IS NOT NULL AND l_api_error_flag is null AND gv_commit_flag <> 'N') THEN
P_UPDATE_ADDRESS(i.rowid,
i.ora_location_id,
i.ADDRESS_LINE1,
i.ADDRESS_LINE2,
i.ADDRESS_LINE3,
i.ADDRESS_LINE4,
i.CITY,
i.ZIP_CODE,
i.STATE,
i.COUNTY,
i.COUNTRY
);
END IF;

IF (i.PRIMARY_CONTACT_NAME_GIVEN IS NOT NULL OR
i.PRIMARY_CONTACT_NAME_FAMILY IS NOT NULL OR
i.PRIMARY_CONTACT_EMAIL IS NOT NULL OR
i.PRIMARY_CONTACT_PHONE_WORK IS NOT NULL OR
i.PRIMARY_CONTACT_PH_WORK_AREA IS NOT NULL OR
i.PRIMARY_CONTACT_PHONE_MOBILE IS NOT NULL OR
i.PRIMARY_CONTACT_PHONE_FAX IS NOT NULL OR
i.PRIMARY_WORK_COUNTRY_CODE IS NOT NULL)
AND gv_commit_flag <> 'N'
 THEN

P_UPDATE_DFF(i.rowid,
i.ora_vendor_site_id,
i.PRIMARY_CONTACT_NAME_GIVEN,
i.PRIMARY_CONTACT_NAME_FAMILY,
i.PRIMARY_CONTACT_EMAIL,
i.PRIMARY_CONTACT_PHONE_WORK,
i.PRIMARY_CONTACT_PH_WORK_AREA,
i.PRIMARY_CONTACT_PHONE_MOBILE,
i.PRIMARY_CONTACT_PHONE_FAX,
i.PRIMARY_WORK_COUNTRY_CODE
);
END IF;

IF i.PO_EMAIL_ADDRESS  IS NOT NULL AND gv_commit_flag <> 'N' THEN
    P_UPDATE_SUPPLIER_SITE(i.rowid,
            i.ora_vendor_site_id,
            i.PO_EMAIL_ADDRESS);
END IF;

        IF i.ADDRESS_NAME IS NOT NULL  AND gv_commit_flag <> 'N' THEN
            P_UPDATE_ADDRESS_NAME(i.rowid,
                            i.ora_party_site_id,
                            i.ADDRESS_NAME,
                            v_uan_status);
        END IF;

IF (i.CONTENT_GROUP IS NOT NULL OR i.leaf_commodity IS NOT NULL) AND gv_commit_flag <> 'N'  THEN
            BEGIN
               p_uda ( i.rowid,
               i.ORA_PARTY_ID,
                      'XXAH_COUPA_CONTENT',
                      'Coupa Content Group',
                      i.CONTENT_GROUP,
                      i.leaf_commodity,
                      'SUPP_ADDR_SITE_LEVEL',
                      i.ora_party_site_id,
                      i.ora_vendor_site_id
                     );
            END;
END IF;

        IF i.VAT_REGISTRATION_NUM IS NOT NULL AND gv_commit_flag <> 'N' THEN
            P_VAT_REGISTRATION_NUM(i.rowid,
                                    i.ORA_PARTY_ID,
                                    i.VAT_REGISTRATION_NUM );
        END IF;

                    fnd_file.put_line(fnd_file.LOG,'gv_commit_flag '||gv_commit_flag);
            IF gv_commit_flag <> 'N' THEN
            update xxah_ps_ebs_supp_update
                set conversion_status='P'
                where
                rowid = i.rowid;
                commit;

                ELSE
                ROLLBACK;
                NULL;
                          p_write_log(i.rowid, gv_api_msg);

            END IF;

fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
     end loop;
     p_report;
EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_UPDATE_SUPPLIER '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

END P_UPDATE_SUPPLIER;

PROCEDURE P_UPDATE_ADDRESS( p_rowid IN VARCHAR2,
p_location_id IN NUMBER,
p_address_line1 IN VARCHAR2,
p_address_line2 IN VARCHAR2,
p_address_line3 IN VARCHAR2,
p_address_line4 IN VARCHAR2,
p_city IN VARCHAR2,
p_postal_code IN VARCHAR2,
p_state IN VARCHAR2,
p_county IN VARCHAR2,
p_country IN VARCHAR2)
IS
p_location_rec          HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
p_object_version_number NUMBER;
x_return_status         VARCHAR2(2000);
x_msg_count             NUMBER;
x_msg_data              VARCHAR2(2000);
l_api_msg VARCHAR2(2000);
ln_msg_index_out         NUMBER    := NULL;
l_rowid                      VARCHAR2(200);

BEGIN
-- Setting the Context --
    l_rowid        := NULL;

        select ROWID into l_rowid from xxah_ps_ebs_supp_update
            where rowid = p_rowid
            AND ora_location_id = p_location_id
            and request_id = gv_request_id;

fnd_global.apps_initialize ( user_id      => FND_GLOBAL.USER_ID
                            ,resp_id      => FND_GLOBAL.RESP_ID
                            ,resp_appl_id => FND_GLOBAL.RESP_APPL_ID);

p_object_version_number := null;

SELECT MAX(HZL.OBJECT_VERSION_NUMBER) INTO p_object_version_number
 FROM HZ_LOCATIONS HZL
WHERE HZL.LOCATION_ID = p_location_id;

-- Initializing the Mandatory API parameters
p_location_rec.location_id := p_location_id;
p_location_rec.country     := p_country;
p_location_rec.address1    := p_address_line1;
p_location_rec.address2    := p_address_line2;
p_location_rec.address3    := p_address_line3;
p_location_rec.address4    := p_address_line4;
p_location_rec.city            := p_city;
p_location_rec.postal_code    := p_postal_code;
p_location_rec.state        := p_state;
p_location_rec.county        := UPPER(p_county);

hz_location_v2pub.update_location
            (
             p_init_msg_list           => FND_API.G_FALSE,
             --p_commit                   => FND_API.G_FALSE,
             p_location_rec            => p_location_rec,
             p_object_version_number   => p_object_version_number,
             x_return_status           => x_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data
                  );
    fnd_file.put_line(fnd_file.log,'--update_location => '||x_return_status);
IF x_return_status <> fnd_api.g_ret_sts_success THEN
        ROLLBACK;
        fnd_file.put_line(fnd_file.log,'!!Rollback Executed!!');
        gv_commit_flag := 'N';

      FOR i IN 1 .. x_msg_count
        LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => x_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (x_msg_data);
      l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| x_msg_data);
      END LOOP;
          p_write_log(l_rowid, '//P_UPDATE_ADDRESS '||l_api_msg);
    FND_FILE.put_line(FND_FILE.LOG,'Error P_UPDATE_ADDRESS : ' || l_api_msg);
    gv_api_msg := l_api_msg;

END IF;
EXCEPTION
WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_UPDATE_ADDRESS '||SQLCODE||' -ERROR- '||SQLERRM);
    p_write_log(l_rowid, '//P_UPDATE_ADDRESS '||SQLERRM);
    gv_api_msg := '//P_UPDATE_ADDRESS '||SQLERRM;

END P_UPDATE_ADDRESS;

PROCEDURE P_UPDATE_DFF(p_rowid             IN VARCHAR2,
                       l_vendor_site_id IN NUMBER,
                       p_attribute1     IN VARCHAR2,
                       p_attribute2     IN VARCHAR2,
                       p_attribute3     IN VARCHAR2,
                       p_attribute4     IN VARCHAR2,
                       p_attribute5     IN VARCHAR2,
                       p_attribute6     IN VARCHAR2,
                       p_attribute7     IN VARCHAR2,
                       p_attribute8     IN VARCHAR2
                       )
IS
  l_vendor_site_rec AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
  l_return_status     VARCHAR2 (30);
  l_msg_count         NUMBER;
  l_msg_data        VARCHAR2 (3000);
  l_msg_index_out   NUMBER    := NULL;
  l_api_msg         VARCHAR2(2000);
  l_rowid                      VARCHAR2(200);

BEGIN

    l_api_msg    := NULL;
    l_rowid        := NULL;

     select ROWID into l_rowid from xxah_ps_ebs_supp_update
    where rowid = p_rowid
            AND ORA_VENDOR_SITE_ID = l_vendor_site_id
            and request_id = gv_request_id;

    l_vendor_site_rec.attribute1 := p_attribute1;
    l_vendor_site_rec.attribute2 := p_attribute2;
    l_vendor_site_rec.attribute3 := p_attribute3;
    l_vendor_site_rec.attribute4 := p_attribute4;
    l_vendor_site_rec.attribute5 := p_attribute5;
    l_vendor_site_rec.attribute6 := p_attribute6;
    l_vendor_site_rec.attribute7 := p_attribute7;
    l_vendor_site_rec.attribute8 := p_attribute8;

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
FND_FILE.put_line(FND_FILE.LOG,'--Updated DFF Values = >'||l_return_status);

    IF l_return_status <>  fnd_api.g_ret_sts_success  THEN
        ROLLBACK;
    gv_commit_flag := 'N';

    FOR i IN 1 .. l_msg_count
    LOOP
      fnd_msg_pub.get(p_msg_index     => i,
                      p_data          => l_msg_data,
                      p_encoded       => 'F',
                      p_msg_index_out => l_msg_index_out);
      fnd_message.set_encoded(l_msg_data);
      l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| l_msg_data);
    END LOOP;
    p_write_log(l_rowid, '//P_UPDATE_DFF '||l_api_msg);
    FND_FILE.put_line(FND_FILE.LOG,'Error P_UPDATE_DFF : ' || l_api_msg);
  END IF;

EXCEPTION
WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - p_update_dff '||SQLCODE||' -ERROR- '||SQLERRM);
    p_write_log(l_rowid, '//P_UPDATE_DFF '||SQLERRM);

END P_UPDATE_DFF;

PROCEDURE P_UPDATE_SUPPLIER_SITE(
p_row_id IN VARCHAR2,
p_vendor_site_id IN NUMBER,
p_email_address IN VARCHAR2)
IS
  p_api_version               NUMBER;
  p_init_msg_list             VARCHAR2(200);
  p_commit                    VARCHAR2(200);
  p_validation_level          NUMBER;
  x_return_status             VARCHAR2(200);
  x_msg_count                 NUMBER;
  x_msg_data                  VARCHAR2(200);
  lr_vendor_site_rec          apps.ap_vendor_pub_pkg.r_vendor_site_rec_type;
  lr_existing_vendor_site_rec ap_supplier_sites_all%ROWTYPE;
l_msg_index_out   NUMBER    := NULL;
  l_rowid                      VARCHAR2(200);
   l_api_msg VARCHAR2(2000);

BEGIN
    l_rowid    := NULL;

  select ROWID into l_rowid from xxah_ps_ebs_supp_update
    where rowid = p_row_id
    AND ORA_VENDOR_SITE_ID = p_vendor_site_id
            and request_id = gv_request_id;

  -- Initialize apps session
  fnd_global.apps_initialize(user_id => fnd_global.user_id,
                             resp_id => fnd_global.resp_id,
                             resp_appl_id => fnd_global.resp_appl_id);

  -- Assign Basic Values
  p_api_version      := 1.0;
  p_init_msg_list    := FND_API.G_FALSE;--fnd_api.g_true;
  p_commit           := FND_API.G_FALSE;--fnd_api.g_true;
  p_validation_level := fnd_api.g_valid_level_full;

  BEGIN
    SELECT *
      INTO lr_existing_vendor_site_rec
      FROM ap_supplier_sites_all assa
     WHERE assa.vendor_site_id = p_vendor_site_id;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
      p_write_log(l_rowid, 'Unable to derive the supplier site information for vendor');
      DBMS_OUTPUT.put_line('Unable to derive the supplier site information for site id:' ||p_vendor_site_id);

  END;

  -- Assign Vendor Site Details
  lr_vendor_site_rec.vendor_site_id   := lr_existing_vendor_site_rec.vendor_site_id;
  lr_vendor_site_rec.last_update_date := SYSDATE;
  lr_vendor_site_rec.last_updated_by  := fnd_global.user_id;
  lr_vendor_site_rec.vendor_id        := lr_existing_vendor_site_rec.vendor_id;
  lr_vendor_site_rec.org_id           := lr_existing_vendor_site_rec.org_id;
  lr_vendor_site_rec.EMAIL_ADDRESS    := p_email_address;

  AP_VENDOR_PUB_PKG.UPDATE_VENDOR_SITE(p_api_version      => p_api_version,
                                       p_init_msg_list    => p_init_msg_list,
                                       p_commit           => p_commit,
                                       p_validation_level => p_validation_level,
                                       x_return_status    => x_return_status,
                                       x_msg_count        => x_msg_count,
                                       x_msg_data         => x_msg_data,
                                       p_vendor_site_rec  => lr_vendor_site_rec,
                                       p_vendor_site_id   => p_vendor_site_id
                                       );

  FND_FILE.put_line(FND_FILE.LOG,'--PO_EMAIL_ADDRESS => '||x_return_status);

  IF x_return_status =  fnd_api.g_ret_sts_success  THEN
    NULL;
  ELSE
        ROLLBACK;
    gv_commit_flag := 'N';
    FOR i IN 1 .. x_msg_count
    LOOP
      fnd_msg_pub.get(p_msg_index     => i,
                      p_data          => x_msg_data,
                      p_encoded       => 'F',
                      p_msg_index_out => l_msg_index_out);
      fnd_message.set_encoded(x_msg_data);
      l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| x_msg_data);
    END LOOP;
         p_write_log(l_rowid, '//P_UPDATE_SUPPLIER_SITE '||l_api_msg);
         FND_FILE.put_line(FND_FILE.LOG,'Error P_UPDATE_SUPPLIER_SITE : ' || l_api_msg);
  END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UPDATE_SUPPLIER_SITE '||SQLCODE||' -ERROR- '||SQLERRM);
        p_write_log(l_rowid, '//P_UPDATE_SUPPLIER_SITE : '||SQLERRM);
END P_UPDATE_SUPPLIER_SITE;

PROCEDURE P_UPDATE_VENDOR(p_row_id IN VARCHAR2,
                        p_vendor_id IN NUMBER,
                        p_po_match IN VARCHAR2)
IS
  p_api_version          NUMBER;
  p_init_msg_list        VARCHAR2(200);
  p_commit               VARCHAR2(200);
  p_validation_level     NUMBER;
  x_return_status        VARCHAR2(200);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(200);
  lr_vendor_rec          apps.ap_vendor_pub_pkg.r_vendor_rec_type;
  lr_existing_vendor_rec ap_suppliers%ROWTYPE;
  l_msg                  VARCHAR2(200);
     l_inspection_required_flag      VARCHAR2 (1):=NULL;
   l_receipt_required_flag         VARCHAR2 (1):=NULL;
   l_rowid                VARCHAR2(200);
ln_msg_index_out         NUMBER    := NULL;
l_api_msg VARCHAR2(2000);

BEGIN

  -- Initialize apps session
  fnd_global.apps_initialize(user_id => fnd_global.user_id,
                             resp_id => fnd_global.resp_id,
                             resp_appl_id => fnd_global.resp_appl_id);

  -- Assign Basic Values
  p_api_version      := 1.0;
  p_init_msg_list    := FND_API.G_FALSE;--fnd_api.g_true;
  p_commit           := FND_API.G_FALSE;--fnd_api.g_true;
  p_validation_level := fnd_api.g_valid_level_full;

  -- gather vendor details

  l_inspection_required_flag    := NULL;
  l_receipt_required_flag       := NULL;
  l_api_msg                        := NULL;
  l_rowid                        := NULL;

  select ROWID into l_rowid from xxah_ps_ebs_supp_update
    where rowid = p_row_id
    and ora_vendor_id = p_vendor_id
            and request_id = gv_request_id;

  BEGIN
    SELECT *
      INTO lr_existing_vendor_rec
      FROM ap_suppliers asa
     WHERE asa.vendor_id = p_vendor_id;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
    p_write_log(l_rowid, 'Unable to derive the supplier  information for vendor');
    FND_FILE.put_line(FND_FILE.LOG,'Unable to derive the supplier  information for vendor id:' ||p_vendor_id);
  END;
            --<Match Approval Level>--
      IF p_po_match        = '2-way match'
      THEN
         l_inspection_required_flag     := 'N';
         l_receipt_required_flag         := 'N';
      ELSIF p_po_match    = '3-way match'
      THEN
         l_inspection_required_flag     := 'N';
         l_receipt_required_flag         := 'Y';
      ELSIF p_po_match    = '4-way match'
      THEN
         l_inspection_required_flag        := 'Y';
         l_receipt_required_flag         := 'Y';
      --ELSE
         --l_inspection_required_flag     := NULL;
         --l_receipt_required_flag         := NULL;
      END IF;

      IF (p_po_match   = '2-way match' OR
        p_po_match    = '3-way match' OR
        p_po_match    = '4-way match') THEN
  --Deactivate Vendor
      lr_vendor_rec.vendor_id                   := lr_existing_vendor_rec.vendor_id;
      lr_vendor_rec.inspection_required_flag     := l_inspection_required_flag;
      lr_vendor_rec.receipt_required_flag         := l_receipt_required_flag;


  ap_vendor_pub_pkg.update_vendor(p_api_version      => p_api_version,
                                  p_init_msg_list    => p_init_msg_list,
                                  p_commit           => p_commit,
                                  p_validation_level => p_validation_level,
                                  x_return_status    => x_return_status,
                                  x_msg_count        => x_msg_count,
                                  x_msg_data         => x_msg_data,
                                  p_vendor_rec       => lr_vendor_rec,
                                  p_vendor_id        => p_vendor_id);
    FND_FILE.put_line(FND_FILE.LOG,'--PO_MATCH => '||x_return_status);

  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      ROLLBACK;
    gv_commit_flag := 'N';
    FOR i IN 1 .. x_msg_count
        LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => x_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
            fnd_message.set_encoded (x_msg_data);
            l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| x_msg_data);
        END LOOP;
        FND_FILE.put_line(FND_FILE.LOG,'The API P_UPDATE_VENDOR call failed with error ' || l_api_msg);
        p_write_log(l_rowid, '//P_UPDATE_VENDOR '||l_api_msg);
  ELSE
    NULL;
  END IF;
  ELSE
   FND_FILE.put_line(FND_FILE.LOG,'rollback executed!!');
  rollback;

        p_write_log(l_rowid, '//Invalid PO Match Name');
        gv_commit_flag := 'N';

  END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UPDATE_VENDOR '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
        p_write_log(l_rowid, '//P_UPDATE_VENDOR : '||SQLERRM);
END P_UPDATE_VENDOR;

PROCEDURE P_UDA (
   ln_rowid                  IN   VARCHAR2,
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
   l_rowid                VARCHAR2(200);
   l_api_msg VARCHAR2(2000);


BEGIN
    l_rowid     := NULL;
    l_api_msg    := NULL;

    select ROWID into l_rowid from xxah_ps_ebs_supp_update
        where rowid = ln_rowid
        AND ORA_PARTY_ID = ln_party_id
            and request_id = gv_request_id;

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



   IF lv_attr_group_name = 'XXAH_COUPA_CONTENT'
   THEN
      /*lv_attributes_data_table :=
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
            );*/
            IF ln_attr_value_str1 IS NOT NULL AND ln_attr_value_str2 IS NOT NULL THEN
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
            ELSIF ln_attr_value_str1 IS NOT NULL AND ln_attr_value_str2 IS  NULL THEN
            
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
                                  ));
                    ELSIF ln_attr_value_str1 IS  NULL AND ln_attr_value_str2 IS NOT NULL THEN
                      lv_attributes_data_table :=
         ego_user_attr_data_table
            (   ego_user_attr_data_obj (row_identifier            => 1,
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
                     transaction_type       => Ego_User_Attrs_Data_Pvt.G_Sync_Mode--ego_user_attrs_data_pvt.g_create_mode
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

                     FND_FILE.PUT_LINE(FND_FILE.LOG,'--CONTENT_GROUP/leaf_commodity => '||lv_return_status);

   IF lv_return_status = fnd_api.g_ret_sts_success
   THEN
      NULL;
   ELSE
        ROLLBACK;
        gv_commit_flag := 'N';

      FOR i IN 1 .. ln_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => lv_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (lv_msg_data);
         l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| lv_msg_data);
      END LOOP;
      FND_FILE.put_line(FND_FILE.LOG,'The API P_UDA error ' || l_api_msg);
        p_write_log(l_rowid, '//P_UDA '||l_api_msg);

   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UDA '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
        p_write_log(l_rowid, SQLERRM);
END P_UDA;

PROCEDURE P_UPDATE_ADDRESS_NAME(p_row_id IN VARCHAR2,
                                p_party_site_id IN NUMBER,
                                p_party_site_name IN VARCHAR2,
                                p_return_status OUT VARCHAR)
IS
  l_party_site_rec hz_party_site_v2pub.PARTY_SITE_REC_TYPE;
  l_obj_num        NUMBER;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
     ln_msg_index_out               NUMBER                        := NULL;
     l_api_msg VARCHAR2(2000);
    l_rowid     VARCHAR2(200);
BEGIN
    l_rowid    := NULL;

    select ROWID into l_rowid from xxah_ps_ebs_supp_update
        where rowid = p_row_id
            AND ORA_PARTY_SITE_ID = p_party_site_id
            and request_id = gv_request_id;

  select object_version_number INTO l_obj_num
  from hz_party_sites where party_site_id =p_party_site_id ;

  l_party_site_rec.party_site_id        := p_party_site_id;
  l_party_site_rec.party_site_name         := p_party_site_name;

  hz_party_site_v2pub.update_party_site
  ( p_init_msg_list         =>  FND_API.G_FALSE
  , p_party_site_rec        =>  l_PARTY_SITE_REC
  , p_object_version_number => l_obj_num
  , x_return_status         => l_return_status
  , x_msg_count             => l_msg_count
  , x_msg_data              => l_msg_data
  ) ;
  p_return_status := l_return_status;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'--ADDRESS_NAME => '||l_return_status);


     IF l_return_status = fnd_api.g_ret_sts_success
   THEN
      NULL;
   ELSE
        ROLLBACK;
        FND_FILE.put_line(FND_FILE.LOG,'!!rollback executed!!');
        gv_commit_flag := 'N';

      FOR i IN 1 .. l_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => l_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (l_msg_data);
      l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| l_msg_data);
      END LOOP;
      FND_FILE.put_line(FND_FILE.LOG,'The API P_UPDATE_ADDRESS_NAME error ' || l_api_msg);
        p_write_log(l_rowid, '//P_UPDATE_ADDRESS_NAME : '||l_api_msg);

   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UPDATE_ADDRESS_NAME '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
        p_write_log(l_rowid, '//P_UPDATE_ADDRESS_NAME : '||SQLERRM);

END P_UPDATE_ADDRESS_NAME;

PROCEDURE P_VAT_REGISTRATION_NUM(p_row_id IN VARCHAR2,
                                lv_PARTY_ID IN NUMBER,
                                lv_vat_registration_num IN VARCHAR2 )
IS

 l_party_tax_profile_id zx_party_tax_profile.party_tax_profile_id%type;
 l_return_status VARCHAR2(1);
 l_debug_info                  VARCHAR2(500);
   l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
       ln_msg_index_out               NUMBER                        := NULL;
     l_api_msg VARCHAR2(2000);
    l_rowid     VARCHAR2(200);
 BEGIN
    l_rowid    := NULL;
    L_PARTY_TAX_PROFILE_ID := NULL;

     select ROWID into l_rowid from xxah_ps_ebs_supp_update
        where rowid = p_row_id
            AND ORA_PARTY_ID = lv_PARTY_ID
            and request_id = gv_request_id;

       BEGIN
    SELECT PARTY_TAX_PROFILE_ID
      INTO
     L_PARTY_TAX_PROFILE_ID
            FROM ZX_PARTY_TAX_PROFILE
            WHERE PARTY_ID = lv_PARTY_ID
            AND PARTY_TYPE_CODE = 'THIRD_PARTY'
            AND ROWNUM = 1;

          EXCEPTION
            WHEN OTHERS THEN
               L_PARTY_TAX_PROFILE_ID := NULL;
               p_write_log(l_rowid,'No data returned from ZX_PARTY_TAX_PROFILE for party_id');
               FND_FILE.PUT_LINE(FND_FILE.LOG,'No data returned from ZX_PARTY_TAX_PROFILE for party_id = '||lv_party_id);
       END;

IF L_PARTY_TAX_PROFILE_ID IS NOT NULL THEN

          ZX_PARTY_TAX_PROFILE_PKG.update_row (
          P_PARTY_TAX_PROFILE_ID => L_PARTY_TAX_PROFILE_ID,
           P_COLLECTING_AUTHORITY_FLAG => null,
           P_PROVIDER_TYPE_CODE => null,
           P_CREATE_AWT_DISTS_TYPE_CODE => null,
           P_CREATE_AWT_INVOICES_TYPE_COD => null,
           P_TAX_CLASSIFICATION_CODE => null,
           P_SELF_ASSESS_FLAG => null,
           P_ALLOW_OFFSET_TAX_FLAG => null,
           P_REP_REGISTRATION_NUMBER => lv_vat_registration_num,
           P_EFFECTIVE_FROM_USE_LE => null,
           P_RECORD_TYPE_CODE => null,
           P_REQUEST_ID => null,
           P_ATTRIBUTE1 => null,
           P_ATTRIBUTE2 => null,
           P_ATTRIBUTE3 => null,
           P_ATTRIBUTE4 => null,
           P_ATTRIBUTE5 => null,
           P_ATTRIBUTE6 => null,
           P_ATTRIBUTE7 => null,
           P_ATTRIBUTE8 => null,
           P_ATTRIBUTE9 => null,
           P_ATTRIBUTE10 => null,
           P_ATTRIBUTE11 => null,
           P_ATTRIBUTE12 => null,
           P_ATTRIBUTE13 => null,
           P_ATTRIBUTE14 => null,
           P_ATTRIBUTE15 => null,
           P_ATTRIBUTE_CATEGORY => null,
           P_PARTY_ID => lv_PARTY_ID,
           P_PROGRAM_LOGIN_ID => null,
           P_PARTY_TYPE_CODE => null,
           P_SUPPLIER_FLAG => null,
           P_CUSTOMER_FLAG => null,
           P_SITE_FLAG => null,
           P_PROCESS_FOR_APPLICABILITY_FL => null,
           P_ROUNDING_LEVEL_CODE => null,
           P_ROUNDING_RULE_CODE => null,
           P_WITHHOLDING_START_DATE => null,
           P_INCLUSIVE_TAX_FLAG => null,
           P_ALLOW_AWT_FLAG => null,
           P_USE_LE_AS_SUBSCRIBER_FLAG => null,
           P_LEGAL_ESTABLISHMENT_FLAG => null,
           P_FIRST_PARTY_LE_FLAG => null,
           P_REPORTING_AUTHORITY_FLAG => null,
           X_RETURN_STATUS => l_return_status,
           P_REGISTRATION_TYPE_CODE => null,
           P_COUNTRY_CODE => null
           );
  FND_FILE.PUT_LINE(FND_FILE.LOG,'--VAT_REGISTRATION_NUM => '||l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
          ROLLBACK;
        gv_commit_flag := 'N';
        p_write_log(l_rowid, '//P_VAT_REGISTRATION_NUM : unable to update vat');
    END IF;
END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_VAT_REGISTRATION_NUM '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
        p_write_log(l_rowid, '//P_VAT_REGISTRATION_NUM : '||SQLERRM);

end P_VAT_REGISTRATION_NUM;

--
-- This procedure will error out supplier if same supplier record errored. --<1.1>--
--
PROCEDURE P_SUPPLIER_UPDATE(p_supplier_name IN VARCHAR2)
is

l_count        NUMBER;

BEGIN

BEGIN
    SELECT Count(*)
    INTO   l_count
    FROM   xxah_ps_ebs_supp_update
    WHERE  old_supplier_name = p_supplier_name
           AND conversion_status = 'E'
           AND request_id = gv_request_id;

    fnd_file.Put_line(fnd_file.log, 'Error count > '||l_count);

EXCEPTION
    WHEN OTHERS THEN
      fnd_file.Put_line(fnd_file.log, 'Error - l_count '
                                      ||SQLCODE
                                      ||' -ERROR- '
                                      ||SQLERRM);
END;

BEGIN
IF l_count > 0 THEN

  UPDATE xxah_ps_ebs_supp_update
  SET    conversion_status = 'E' ,
         error_log = 'Supplier Other record errored!!' ,
         ora_vendor_id = NULL
  WHERE  old_supplier_name = p_supplier_name
  AND    request_id = gv_request_id
  AND    error_log IS NULL
  AND      ora_vendor_id IS NOT NULL;

  COMMIT;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier Other record errored!! '||p_supplier_name);

END IF;
  EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - l_count > 0 '||SQLCODE||' -ERROR- '||SQLERRM);
        NULL;
END;

  EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_SUPPLIER_UPDATE '||SQLCODE||' -ERROR- '||SQLERRM);
        NULL;
END P_SUPPLIER_UPDATE;

PROCEDURE p_write_log ( p_row_id VARCHAR2, p_message IN VARCHAR2 )
IS
  PRAGMA autonomous_transaction;
BEGIN
FND_FILE.put_line(FND_FILE.LOG,'Executing   PRAGMA autonomous_transaction!!');

  UPDATE xxah_ps_ebs_supp_update
  SET    conversion_status = 'E' ,
         error_log = p_message
  WHERE  ROWID = p_row_id;
  commit;
  FND_FILE.put_line(FND_FILE.LOG,'Commit Executed!!');

END p_write_log;

PROCEDURE p_report
IS
CURSOR c_rec
IS
select * from xxah_ps_ebs_supp_update
where request_id = gv_request_id
ORDER BY CONVERSION_STATUS DESC;

l_success_header VARCHAR2(1):='N';
l_fail_header VARCHAR2(1):='N';
l_scnt    NUMBER:=0;
l_fcnt    NUMBER:=0;
l_acnt    NUMBER:=0;


BEGIN
    FOR r_rec IN c_rec
        LOOP
            IF r_rec.CONVERSION_STATUS = 'P' THEN
                IF l_success_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'| XXAH: Supplier and Sites Update API Program                    |');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Record');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | OLD_SUPPLIER_NAME | NEW_SUPPLIER_NAME |ORA_VENDOR_ID | ORA_VENDOR_SITE_ID  ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_success_header := 'Y';
                END IF;
                l_scnt := l_scnt + 1;
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_scnt||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID            );

            END IF;

                IF r_rec.CONVERSION_STATUS = 'E' THEN
                IF l_fail_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Record');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | OLD_SUPPLIER_NAME | NEW_SUPPLIER_NAME |ORA_VENDOR_ID | ORA_VENDOR_SITE_ID | ERROR_LOG ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_fail_header := 'Y';
                END IF;
                l_fcnt := l_fcnt + 1;
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
            END IF;
            l_acnt := l_acnt + 1;
        END LOOP;
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Total Records => '||    l_acnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Records => '|| l_scnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Records => '|| l_fcnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');

END p_report;


end XXAH_SUPP_UPDATE_PKG; 

/
