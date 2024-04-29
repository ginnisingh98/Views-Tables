--------------------------------------------------------
--  DDL for Package Body XXAH_SUPPLIER_STATUS_NFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SUPPLIER_STATUS_NFR_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_SUPP_STATUS_NFR_PKG
   * DESCRIPTION       : PACKAGE TO Inactivate Supplier status Mass Update Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 17-March-2018        1.0       TCS     Initial
   * 16-March-2018         2.0       TCS     Added Supplier Site
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
   gv_ps_number      NUMBER;
   gv_ps_numbers     NUMBER;

   PROCEDURE P_MAIN (errbuf OUT VARCHAR2, retcode OUT NUMBER)
   IS
      CURSOR c_supp_record
      IS
         SELECT DISTINCT VENDOR_number,
                         vendor_site_id,
                         vendor_id,
                         ROWID
           FROM XXAH_SUPPLIER_STATUS_NFR
          WHERE UPDATE_FLAG = 'N'  and rownum <=1000 order by vendor_number  ;-- AND ps_number IS NULL;

     BEGIN   

      fnd_global.Apps_initialize (user_id        => fnd_global.user_id,
                                  resp_id        => fnd_global.resp_id,
                                  resp_appl_id   => fnd_global.resp_appl_id);

      FND_FILE.PUT_LINE (FND_FILE.LOG, 'Main loop');
                                                    --1

      FOR i IN c_supp_record
      LOOP
              FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                  'Starting status update for supplier' ||i.vendor_id );
               P_UPDATE_SUPPLIER (i.ROWID,i.vendor_number);
        
end loop;
      p_report;
   --  end ;--Pending 1
   END P_MAIN;


   

   PROCEDURE P_UPDATE_SUPPLIER (p_row_id IN VARCHAR2, p_vendor_number IN NUMBER)
   IS
      p_api_version            NUMBER;
      p_init_msg_list          VARCHAR2 (200);
      p_commit                 VARCHAR2 (200);
      p_validation_level       NUMBER;
      x_return_status          VARCHAR2 (200);
      x_msg_count              NUMBER;
      x_msg_data               VARCHAR2 (200);
      lr_vendor_rec            apps.ap_vendor_pub_pkg.r_vendor_rec_type;
      lr_existing_vendor_rec   ap_suppliers%ROWTYPE;

      l_msg                    VARCHAR2 (200);
      l_rowid                  VARCHAR2 (200);
      ln_msg_index_out         NUMBER := NULL;
      l_api_msg                VARCHAR2 (2000);

      l_end_date_active        ap_suppliers.end_date_active%TYPE;
      l_update_flag            VARCHAR2 (1);
   BEGIN
      -- Initialize apps session
      fnd_global.apps_initialize (user_id        => fnd_global.user_id,
                                  resp_id        => fnd_global.resp_id,
                                  resp_appl_id   => fnd_global.resp_appl_id);

      -- Assign Basic Values
      p_api_version := 1.0;
      p_init_msg_list := FND_API.G_FALSE;                    --fnd_api.g_true;
      p_commit := FND_API.G_FALSE;                           --fnd_api.g_true;
      p_validation_level := fnd_api.g_valid_level_full;

      -- gather vendor details
      FND_FILE.put_line (
         FND_FILE.LOG,
         ' Inside Vendor update Vendor_number' || p_vendor_number);

      l_api_msg := NULL;
      l_rowid := NULL;
      l_end_date_active := NULL;
      l_update_flag := NULL;

      BEGIN
         SELECT ROWID
           INTO l_rowid
           FROM XXAH_SUPPLIER_STATUS_NFR
          WHERE ROWID = p_row_id AND vendor_number = p_vendor_number;

         FND_FILE.put_line (
            FND_FILE.LOG,
            'Vendor_number' || p_vendor_number || 'Row number ' || l_rowid);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
            FND_FILE.put_line (
               FND_FILE.LOG,
               'Unable to derive the row id n for vendor id:' || p_vendor_number);
      END;

      BEGIN
         SELECT *
           INTO lr_existing_vendor_rec
           FROM ap_suppliers asa
          WHERE asa.segment1 = p_vendor_number;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
            FND_FILE.put_line (
               FND_FILE.LOG,
                  'Unable to derive the supplier  information for vendor id:'
               || p_vendor_number);
      END;

      lr_vendor_rec.vendor_id := lr_existing_vendor_rec.vendor_id;

      FND_FILE.put_line (
         FND_FILE.LOG,
            'lr_existing_vendor_rec.end_date_active:'
         || lr_existing_vendor_rec.end_date_active);

      IF lr_existing_vendor_rec.end_date_active IS NULL
      THEN
         FND_FILE.PUT_LINE (FND_FILE.LOG, '--update inactive date');
         l_update_flag := 'Y';
         lr_vendor_rec.end_date_active := SYSDATE;
      END IF;


      IF l_update_flag = 'Y'
      THEN
         FND_FILE.PUT_LINE (FND_FILE.LOG,
                            '--Updating inactive date to supplier  ');
         ap_vendor_pub_pkg.update_vendor (
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            p_commit             => p_commit,
            p_validation_level   => p_validation_level,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_vendor_rec         => lr_vendor_rec,
            p_vendor_id          => lr_vendor_rec.vendor_id);
         --commit;
         FND_FILE.put_line (FND_FILE.LOG, '--status => ' || x_return_status);

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            ROLLBACK;
            gv_commit_flag := 'N';
              FND_FILE.put_line (FND_FILE.LOG,
                            '-gv_commit_flag => ' || gv_commit_flag);

            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index       => i,
                                p_data            => x_msg_data,
                                p_encoded         => 'F',
                                p_msg_index_out   => ln_msg_index_out);
               fnd_message.set_encoded (x_msg_data);
               l_api_msg :=
                     l_api_msg
                  || ' / '
                  || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
            END LOOP;

            FND_FILE.put_line (
               FND_FILE.LOG,
               'The API P_UPDATE_VENDOR call failed with error ' || l_api_msg);
            gv_api_msg := gv_api_msg || l_api_msg;
            p_write_log (p_row_id, gv_api_msg);

         ELSE
           -- NULL;
            --commit;
            gv_commit_flag := 'Y';
            
            begin
      UPDATE XXAH_SUPPLIER_STATUS_NFR
         SET UPDATE_FLAG = 'Y'
       WHERE ROWID = p_row_id;
       commit;
       exception when too_many_rows then
         FND_FILE.put_line (FND_FILE.LOG,
                        p_row_id||SQLERRM||SQLCODE);
                         when others then
                           FND_FILE.put_line (FND_FILE.LOG,
                         'others'||p_row_id||SQLERRM||SQLCODE);
       end;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            '+---------------------------------------------------------------------------+');
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Error -P_UPDATE_VENDOR ' || SQLCODE || ' -ERROR- ' || SQLERRM);
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            '+---------------------------------------------------------------------------+');
   END P_UPDATE_SUPPLIER;

   PROCEDURE p_write_log (p_row_id VARCHAR2, p_message IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FND_FILE.put_line (FND_FILE.LOG,
                         'Executing PRAGMA autonomous_transaction!!');

                          FND_FILE.put_line (FND_FILE.LOG,
                         'P message'||p_message||p_row_id);
begin
      UPDATE XXAH_SUPPLIER_STATUS_NFR
         SET UPDATE_FLAG = 'E', error_log = p_message
       WHERE ROWID = p_row_id;
       commit;
       exception when too_many_rows then
         FND_FILE.put_line (FND_FILE.LOG,
                         'P message'||p_message||p_row_id||SQLERRM||SQLCODE);
                         when others then
                           FND_FILE.put_line (FND_FILE.LOG,
                         'others'||p_message||p_row_id||SQLERRM||SQLCODE);
       end;

      COMMIT;
      FND_FILE.put_line (FND_FILE.LOG, 'Commit Executed!!');
   END p_write_log;

PROCEDURE p_report
IS
CURSOR c_rec
IS
select * from XXAH_SUPPLIER_STATUS_NFR
--where request_id = gv_request_id
ORDER BY UPDATE_FLAG DESC;

l_success_header VARCHAR2(1):='N';
l_fail_header VARCHAR2(1):='N';
l_scnt    NUMBER:=0;
l_fcnt    NUMBER:=0;
l_acnt    NUMBER:=0;


BEGIN
    FOR r_rec IN c_rec
        LOOP
            IF r_rec.UPDATE_FLAG = 'Y' THEN
                IF l_success_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'| XXAH: NFR Sites Update API Program                    |');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Record');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | SUPPLIER_NAME | VENDOR_ID | VENDOR_NUMBER ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_success_header := 'Y';
                END IF;
                l_scnt := l_scnt + 1;
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_scnt||' | '|| r_rec.VENDOR_NAME ||' | '|| r_rec.VENDOR_ID ||' | '||r_rec.VENDOR_NUMBER);

            END IF;

                IF r_rec.UPDATE_FLAG = 'N' THEN
                IF l_fail_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Record');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | SUPPLIER_NAME | VENDOR_ID | VENDOR_NUMBER ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_fail_header := 'Y';
                END IF;
                l_fcnt := l_fcnt + 1;
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.VENDOR_NAME ||' | '|| r_rec.VENDOR_ID ||' | '||r_rec.VENDOR_NUMBER);
            END IF;
            l_acnt := l_acnt + 1;
        END LOOP;
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Total Records => '||    l_acnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Records => '|| l_scnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Records => '|| l_fcnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');

END p_report;

  
END XXAH_SUPPLIER_STATUS_NFR_PKG;

/
