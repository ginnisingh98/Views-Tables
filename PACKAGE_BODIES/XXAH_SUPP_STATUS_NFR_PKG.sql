--------------------------------------------------------
--  DDL for Package Body XXAH_SUPP_STATUS_NFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SUPP_STATUS_NFR_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_SUPP_STATUS_NFR_PKG
   * DESCRIPTION       : PACKAGE TO Inactivate  status for NFR sites.
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 13-Feb-2019         1.0       TCS     Initial
   * 20-Feb-2019         1.0       TCS     Added Supplier Site
   ****************************************************************************/
  gv_request_id     fnd_concurrent_requests.request_id%TYPE
                        := Fnd_Global.conc_request_id;
   gv_commit_flag    VARCHAR2 (1);
   gv_api_msg        VARCHAR2 (2000);
   gv_vendor_id      NUMBER;
   gv_site_id        NUMBER;
   gv_address_flag   VARCHAR2 (1);
   gv_site_flag      VARCHAR2 (1);
   lv_address_flag   VARCHAR2 (1);
   lv_site_flag      VARCHAR2 (1);


   PROCEDURE P_MAIN (errbuf OUT VARCHAR2, retcode OUT NUMBER)
   IS
      CURSOR c_supp_record
      IS
         SELECT DISTINCT VENDOR_number,
                         vendor_site_id,
                         vendor_id,
                         ROWID
           FROM apps.XXAH_SUPP_STATUS_NFR
          WHERE SITE_FLAG = 'BK' and  rownum <=1000 order by vendor_number ;

   BEGIN                                                           --Pending 1
      fnd_global.Apps_initialize (user_id        => fnd_global.user_id,
                                  resp_id        => fnd_global.resp_id,
                                  resp_appl_id   => fnd_global.resp_appl_id);

      FND_FILE.PUT_LINE (FND_FILE.LOG, 'Main loop');
      
      FOR i IN c_supp_record
         LOOP
         --IF gv_commit_flag = 'Y' 
           -- THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                  'Starting site update for ' ||i.vendor_id || lv_address_flag || lv_site_flag);
               P_UPDATE_SUPPLIER_SITE (i.ROWID,i.vendor_site_id);
          --  END IF;
            
            end loop;
                      
      p_report;
      END P_MAIN;
      
   PROCEDURE P_UPDATE_SUPPLIER_SITE (p_row_id IN VARCHAR2,p_vendor_site_id IN NUMBER)
   IS
      p_api_version                 NUMBER;
      p_init_msg_list               VARCHAR2 (200);
      p_commit                      VARCHAR2 (200);
      p_validation_level            NUMBER;
      x_return_status               VARCHAR2 (200);
      x_msg_count                   NUMBER;
      x_msg_data                    VARCHAR2 (200);
      lr_vendor_site_rec            apps.ap_vendor_pub_pkg.r_vendor_site_rec_type;
      lr_existing_vendor_site_rec   ap_supplier_sites_all%ROWTYPE;
      l_msg_index_out               NUMBER := NULL;
      l_rowid                       VARCHAR2 (200);
      l_api_msg                     VARCHAR2 (2000);
      l_ss_update                   VARCHAR2 (1);
   BEGIN
      l_rowid := NULL;
      l_ss_update := NULL;

      -- Initialize apps session
      fnd_global.apps_initialize (user_id        => fnd_global.user_id,
                                  resp_id        => fnd_global.resp_id,
                                  resp_appl_id   => fnd_global.resp_appl_id);

      -- Assign Basic Values
      p_api_version := 1.0;
      p_init_msg_list := FND_API.G_FALSE;                    --fnd_api.g_true;
      p_commit := FND_API.G_FALSE;                           --fnd_api.g_true;
      p_validation_level := fnd_api.g_valid_level_full;

      BEGIN
         SELECT *
           INTO lr_existing_vendor_site_rec
           FROM ap_supplier_sites_all assa
          WHERE assa.vendor_site_id = p_vendor_site_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
            FND_FILE.put_line (
               FND_FILE.LOG,
                  'Unable to derive the supplier site information for site id:'
               || p_vendor_site_id);
                   p_write_log (p_row_id, gv_api_msg);
      END;

      -- Assign Vendor Site Details
      lr_vendor_site_rec.vendor_site_id :=
         lr_existing_vendor_site_rec.vendor_site_id;
      FND_FILE.put_line (
         FND_FILE.LOG,
         'vendor_site_id ' || lr_vendor_site_rec.vendor_site_id);
      lr_vendor_site_rec.last_update_date := SYSDATE;
      lr_vendor_site_rec.last_updated_by := fnd_global.user_id;
      lr_vendor_site_rec.vendor_id := lr_existing_vendor_site_rec.vendor_id;
      lr_vendor_site_rec.org_id := lr_existing_vendor_site_rec.org_id;
      --   lr_vendor_site_rec.INACTIVE_DATE           := lr_existing_vendor_site_rec.INACTIVE_DATE;

     -- FND_FILE.put_line (
       --  FND_FILE.LOG,
        --    'lr_existing_vendor_site_rec.INACTIVE_DAT'
       --  || lr_existing_vendor_site_rec.INACTIVE_DATE);

      IF     lr_existing_vendor_site_rec.INACTIVE_DATE IS NULL
      THEN --AND p_ss_inactive_date <> nvl(lr_existing_vendor_site_rec.INACTIVE_DATE,to_date('31-DEC-4721','DD-MON-YYYY')) THEN

        lr_vendor_site_rec.INACTIVE_DATE := SYSDATE;
         FND_FILE.put_line (FND_FILE.LOG,
                            '--update inactive_date for Supplier Site');
                              l_ss_update := 'Y';
      END IF;


      IF l_ss_update = 'Y' 
      THEN
         AP_VENDOR_PUB_PKG.UPDATE_VENDOR_SITE (
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            p_commit             => p_commit,
            p_validation_level   => p_validation_level,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_vendor_site_rec    => lr_vendor_site_rec,
            p_vendor_site_id     => p_vendor_site_id);
            
            commit;

         FND_FILE.put_line (FND_FILE.LOG,
                            '--UPDATE_VENDOR_SITE => ' || x_return_status);

        -- FND_FILE.put_line (FND_FILE.LOG,
                          --  '-- p_vendor_site_id => ' || p_vendor_site_id);
         /*FND_FILE.put_line (
            FND_FILE.LOG,
               'Details before calling Vendor API'
            || lr_vendor_site_rec.vendor_site_id
            || p_vendor_site_id
            || l_ss_update
            || lv_address_flag);*/

         IF x_return_status = fnd_api.g_ret_sts_success
         THEN
            NULL;
            gv_commit_flag := 'Y';
            FND_FILE.put_line (
               FND_FILE.LOG,
               '-- p_vendor_site_id for before loop => ' || p_vendor_site_id);

            --Update Supplier SET flag
            BEGIN
               UPDATE XXAH_SUPP_STATUS_NFR
                  SET SITE_FLAG = 'Y'
                WHERE VENDOR_SITE_ID = p_vendor_site_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                        'Error -update details vendor Flag '
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM);
                         p_write_log (p_row_id, gv_api_msg);
            END;
         ELSE
           gv_commit_flag := 'N';
            ROLLBACK;
  FND_FILE.put_line (FND_FILE.LOG,
                            '-gv_commit_flag => ' || gv_commit_flag);
            --Update Supplier SET flag for failed records
            BEGIN
              FND_FILE.put_line (FND_FILE.LOG,
                            '-gv_commit_flag Insife false flag => '|| p_vendor_site_id );
               UPDATE XXAH_SUPP_STATUS_NFR
                  SET SITE_FLAG = 'N'
                WHERE VENDOR_SITE_ID = p_vendor_site_id;
                commit;
            EXCEPTION
               WHEN OTHERS
               THEN
                 FND_FILE.put_line (FND_FILE.LOG,
                            '-gv_commit_flag Insife false flag exception => ' );
                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                        'Error -update details vendor Flag '
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM);
                         p_write_log (p_row_id, gv_api_msg);
            END;

            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index       => i,
                                p_data            => x_msg_data,
                                p_encoded         => 'F',
                                p_msg_index_out   => l_msg_index_out);
               fnd_message.set_encoded (x_msg_data);
               l_api_msg :=
                     l_api_msg
                  || ' / '
                  || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
            END LOOP;

            FND_FILE.put_line (
               FND_FILE.LOG,
               'Error P_UPDATE_SUPPLIER_SITE : ' || l_api_msg);
            gv_api_msg := gv_api_msg || l_api_msg;
           p_write_log (p_row_id, gv_api_msg);
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
               'Error -P_UPDATE_SUPPLIER_SITE '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
                p_write_log (p_row_id, gv_api_msg);
   END P_UPDATE_SUPPLIER_SITE;
   
   PROCEDURE p_report
IS
CURSOR c_rec
IS
select * from XXAH_SUPP_STATUS_NFR
--where request_id = gv_request_id
ORDER BY SITE_FLAG DESC;

l_success_header VARCHAR2(1):='N';
l_fail_header VARCHAR2(1):='N';
l_scnt    NUMBER:=0;
l_fcnt    NUMBER:=0;
l_acnt    NUMBER:=0;


BEGIN
    FOR r_rec IN c_rec
        LOOP
            IF r_rec.SITE_FLAG = 'Y' THEN
                IF l_success_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'| XXAH: NFR Sites Update API Program                    |');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Record');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | SUPPLIER_NAME | ORA_VENDOR_ID |ORA_SITE_NAME | ORA_VENDOR_SITE_ID  ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_success_header := 'Y';
                END IF;
                l_scnt := l_scnt + 1;
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_scnt||' | '|| r_rec.VENDOR_NAME ||' | '|| r_rec.VENDOR_ID ||' | '||r_rec.VENDOR_SITE_CODE ||' | '|| r_rec.VENDOR_SITE_ID           );

            END IF;

                IF r_rec.SITE_FLAG = 'N' THEN
                IF l_fail_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Record');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | SUPPLIER_NAME | ORA_VENDOR_ID |ORA_SITE_NAME | ORA_VENDOR_SITE_ID  | ERROR_LOG ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_fail_header := 'Y';
                END IF;
                l_fcnt := l_fcnt + 1;
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.VENDOR_NAME ||' | '|| r_rec.VENDOR_ID ||' | '||r_rec.VENDOR_SITE_CODE ||' | '|| r_rec.VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
            END IF;
            l_acnt := l_acnt + 1;
        END LOOP;
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Total Records => '||    l_acnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Records => '|| l_scnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Records => '|| l_fcnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');

END p_report;
   
 PROCEDURE p_write_log ( p_row_id VARCHAR2, p_message IN VARCHAR2 )
IS
  PRAGMA autonomous_transaction;
BEGIN
FND_FILE.put_line(FND_FILE.LOG,'Executing   PRAGMA autonomous_transaction!!');

  UPDATE XXAH_SUPP_STATUS_NFR
  SET    ERROR_FLAG='E',
         error_log = p_message
  WHERE  ROWID = p_row_id;
  commit;
  FND_FILE.put_line(FND_FILE.LOG,'Commit Executed!!');

END p_write_log;  
   
     END XXAH_SUPP_STATUS_NFR_PKG;

/
