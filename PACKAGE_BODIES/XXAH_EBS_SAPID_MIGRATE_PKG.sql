--------------------------------------------------------
--  DDL for Package Body XXAH_EBS_SAPID_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_EBS_SAPID_MIGRATE_PKG" as
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_EBS_SAPID_MIGRATE_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Update Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 06-May-2019        1.0       Menaka Kumar     Initial
   ****************************************************************************/
gv_request_id                     fnd_concurrent_requests.request_id%TYPE:= Fnd_Global.conc_request_id;
gv_commit_flag                    VARCHAR2(1);
gv_api_msg                        VARCHAR2(2000);


PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER)
IS

   lv_bank_id                      NUMBER;

CURSOR c_supp_rec
IS
select rowid, a.* from XXAH_SAPNUM_UPLOAD a
where conversion_status = 'N' and creation_date is not null;


BEGIN
    fnd_global.Apps_initialize (user_id => fnd_global.user_id,
                                resp_id => fnd_global.resp_id,
                                resp_appl_id => fnd_global.resp_appl_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Executing started');

    FOR i IN c_supp_rec
        LOOP
        gv_api_msg := NULL;
        gv_commit_flag    := NULL;
 
          
         --   IF gv_commit_flag = 'Y' THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Executing started for site update');
            P_UPDATE_SUPPLIER_SITE(i.vendor_site_id,i.sap_number );
        --    END IF;
            --
            --
            fnd_file.put_line(fnd_file.LOG,'gv_commit_flag '||gv_commit_flag);
            IF gv_commit_flag = 'Y' THEN
            update XXAH_SAPNUM_UPLOAD
                set conversion_status='P'
                where
                rowid = i.rowid;
                commit;

                ELSE
                ROLLBACK;
                NULL;
                          p_write_log(i.rowid, gv_api_msg);

            END IF;

        END LOOP;
     p_report;

END P_MAIN;

PROCEDURE P_UPDATE_SUPPLIER_SITE(
    p_vendor_site_id             IN NUMBER,
       p_sap_number    IN VARCHAR2
    )
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
l_ss_update        VARCHAR2(1);

BEGIN
    l_rowid    := NULL;
    l_ss_update    := NULL;

  -- Initialize apps session
  fnd_global.apps_initialize(user_id => fnd_global.user_id,
                             resp_id => fnd_global.resp_id,
                             resp_appl_id => fnd_global.resp_appl_id);

  -- Assign Basic Values
  p_api_version      := 1.0;
  p_init_msg_list    := FND_API.G_FALSE;--fnd_api.g_true;
  p_commit           := FND_API.G_FALSE;--fnd_api.g_true;
  p_validation_level := fnd_api.g_valid_level_full;
  
  FND_FILE.PUT_LINE(FND_FILE.LOG,'1');

  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'2');
    SELECT *
      INTO lr_existing_vendor_site_rec
      FROM ap_supplier_sites_all assa
     WHERE assa.vendor_site_id = p_vendor_site_id;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
      FND_FILE.put_line(FND_FILE.LOG,'Unable to derive the supplier site information for site id:' ||p_vendor_site_id);

  END;

  -- Assign Vendor Site Details
  lr_vendor_site_rec.vendor_site_id   := lr_existing_vendor_site_rec.vendor_site_id;
  FND_FILE.put_line(FND_FILE.LOG,'vendor_site_id '||lr_vendor_site_rec.vendor_site_id);
lr_vendor_site_rec.attribute10 := lr_existing_vendor_site_rec.attribute10;
  lr_vendor_site_rec.last_updated_by  := fnd_global.user_id;
  lr_vendor_site_rec.vendor_id        := lr_existing_vendor_site_rec.vendor_id;
  lr_vendor_site_rec.org_id           := lr_existing_vendor_site_rec.org_id;




    IF lr_vendor_site_rec.attribute10 IS  NULL  THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'3');
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute10    :=    p_sap_number;
        FND_FILE.put_line(FND_FILE.LOG,'--update SAP Number');
    END IF;

    IF l_ss_update = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'4');

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

  FND_FILE.put_line(FND_FILE.LOG,'--UPDATE_VENDOR_SITE => '||x_return_status);

  IF x_return_status =  fnd_api.g_ret_sts_success  THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'5');
    NULL;
    gv_commit_flag := 'Y';
  ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'6');
         gv_commit_flag := 'N';
        ROLLBACK;
    FOR i IN 1 .. x_msg_count
    LOOP
      fnd_msg_pub.get(p_msg_index     => i,
                      p_data          => x_msg_data,
                      p_encoded       => 'F',
                      p_msg_index_out => l_msg_index_out);
      fnd_message.set_encoded(x_msg_data);
      l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| x_msg_data);
    END LOOP;
         FND_FILE.put_line(FND_FILE.LOG,'Error P_UPDATE_SUPPLIER_SITE : ' || l_api_msg);
         gv_api_msg := gv_api_msg||l_api_msg;
  END IF;

  END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UPDATE_SUPPLIER_SITE '||SQLCODE||' -ERROR- '||SQLERRM);

END P_UPDATE_SUPPLIER_SITE;


PROCEDURE p_write_log ( p_row_id VARCHAR2, p_message IN VARCHAR2 )
IS
  PRAGMA autonomous_transaction;
BEGIN
FND_FILE.put_line(FND_FILE.LOG,'Executing   PRAGMA autonomous_transaction!!');

  UPDATE XXAH_SAPNUM_UPLOAD
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
select * from XXAH_SAPNUM_UPLOAD where creation_date is not null
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
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | SUPPLIER_NAME | SUPPLIER_NUMBER |SAP_NUMBER | VENDOR_SITE_ID  ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_success_header := 'Y';
                END IF;
                l_scnt := l_scnt + 1;
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_scnt||' | '|| r_rec.SUPPLIER_NAME ||' | '|| r_rec.SUPPLIER_NUMBER ||' | '||r_rec.SAP_NUMBER ||' | '|| r_rec.VENDOR_SITE_ID            );

            END IF;

                IF r_rec.CONVERSION_STATUS = 'E' THEN
                IF l_fail_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Record');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | SUPPLIER_NAME | SUPPLIER_NUMBER |SAP_NUMBER | VENDOR_SITE_ID  | ERROR_LOG ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_fail_header := 'Y';
                END IF;
                l_fcnt := l_fcnt + 1;
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.SUPPLIER_NAME ||' | '|| r_rec.SUPPLIER_NUMBER ||' | '||r_rec.SAP_NUMBER ||' | '|| r_rec.VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
            END IF;
            l_acnt := l_acnt + 1;
        END LOOP;
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Total Records => '||    l_acnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Records => '|| l_scnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Records => '|| l_fcnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');

END p_report;

end XXAH_EBS_SAPID_MIGRATE_PKG;

/
