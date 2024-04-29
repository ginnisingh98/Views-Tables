--------------------------------------------------------
--  DDL for Package Body XXAH_NFR_SUPPNAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_NFR_SUPPNAME_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_NFR_SUPPNAME_PKG
   * DESCRIPTION       : PACKAGE TO  Update NFR Supplier name
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 25-AUG-2017        1.0       Menaka      Supplier name update for NFR Suppliers
   ****************************************************************************/
   gv_request_id    fnd_concurrent_requests.request_id%TYPE
                       := Fnd_Global.conc_request_id;
   gv_commit_flag   VARCHAR2 (1);
   gv_api_msg       VARCHAR2 (2000);
   row_id           NUMBER;


   PROCEDURE P_MAIN (errbuf          OUT VARCHAR2,
                     retcode         OUT NUMBER)
   IS
      l_vendor_id                NUMBER;
      l_vendor_name              VARCHAR2 (100);
      l_party_id                 NUMBER;
      l_error_flag               VARCHAR2 (1);
      l_error_log                VARCHAR2 (100);

      CURSOR C1
      IS
         SELECT ROWID,
                supplier_number,
                supplier_name,new_supplier_name
                FROM APPS.XXAH_SUPP_NFR_UPDATE where  NEW_SUPPLIER_NAME is not null; 
             
   BEGIN
      fnd_global.Apps_initialize (user_id        => fnd_global.user_id,
                                  resp_id        => fnd_global.resp_id,
                                  resp_appl_id   => fnd_global.resp_appl_id);

      FND_FILE.PUT_LINE (FND_FILE.LOG, 'Main loop');
      gv_commit_flag := 'Y';


      FOR i IN c1
      LOOP
         l_vendor_id := NULL;

         -- Validating Supplier Type
         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Main loop1');

          --  IF gv_commit_flag = 'Y'
          --  THEN
              P_UPD_VENDOR_NAME (i.ROWID, i.NEW_SUPPLIER_NAME,i.supplier_number);
          --  END IF;

      END LOOP;
      p_report;
   END;

   PROCEDURE P_UPD_VENDOR_NAME (p_row_id      IN VARCHAR2,
                                 p_new_supp_name   IN VARCHAR2,p_supp_num in number)
   IS
      p_api_version                NUMBER;
      l_vendor HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
      p_init_msg_list              VARCHAR2 (200);
      p_commit                     VARCHAR2 (200);
      p_validation_level           NUMBER;
    --  x_return_status              VARCHAR2 (200);
      x_msg_count                  NUMBER;
      x_msg_data                   VARCHAR2 (200);
      lr_vendor_rec                apps.ap_vendor_pub_pkg.r_vendor_rec_type;
      lr_existing_vendor_rec       ap_suppliers%ROWTYPE;
      l_msg                        VARCHAR2 (200);
      l_object_version_number   NUMBER := NULL;
      l_party_id     NUMBER := NULL;
      l_rowid                      VARCHAR2 (200);
      ln_msg_index_out             NUMBER := NULL;
      l_api_msg                    VARCHAR2 (2000);
     V_OBJECT NUMBER :=1;
     v_msg_count NUMBER;
     v_profile_id NUMBER;
     v_return_status VARCHAR2(2000);
     v_msg_data VARCHAR2(2000);
     l_old_name VARCHAR2(2000);
      l_new_name VARCHAR2(2000);
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

      l_object_version_number := NULL;
      l_party_id:= NULL;
      l_api_msg := NULL;
      l_rowid := NULL;
      
        fnd_file.put_line(fnd_file.log,'--NEW_SUPPLIER_NAME update starts => ');  
      begin
       select aps.party_id ,hzp.object_version_number,vendor_name
                into l_party_id ,l_object_version_number,l_old_name
                    from ap_suppliers aps,hz_parties hzp
                where aps.party_id=hzp.party_id and
                segment1 = p_supp_num;
                exception when others then
                    FND_FILE.PUT_LINE (
         FND_FILE.LOG,
            'Error while fetching party and object version  number::'||SQLERRM||SQLCODE);
                end;

fnd_file.put_line(fnd_file.log,'--oldSUPPLIER_NAME => '||l_party_id||l_old_name||l_object_version_number);

         --Deactivate Vendor
l_vendor.party_rec.party_id := l_party_id;
l_vendor.organization_name := p_new_supp_name;
v_object := l_object_version_number;


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
   /*begin
       select aps.party_id ,hzp.object_version_number,vendor_name
                into l_party_id ,l_object_version_number,l_new_name
                    from ap_suppliers aps,hz_parties hzp
                where aps.party_id=hzp.party_id and
                segment1 = p_supp_num;
                exception when others then
                    FND_FILE.PUT_LINE (
         FND_FILE.LOG,
            'Error while fetching party and object version  number::'||SQLERRM||SQLCODE);
                end;*/
  fnd_file.put_line(fnd_file.log,'--before error condition' ||v_return_status||fnd_api.g_ret_sts_success);
fnd_file.put_line(fnd_file.log,'--NEW_SUPPLIER_NAME => '||l_party_id||l_new_name||l_object_version_number);
        IF (v_return_status <> fnd_api.g_ret_sts_success)
         THEN
            ROLLBACK;
            fnd_file.put_line(fnd_file.log,'--insidre error condition' ||v_return_status||fnd_api.g_ret_sts_success||'v_msg_count'||v_msg_count);
            gv_commit_flag := 'N';

            FOR i IN 1 .. v_msg_count
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
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - NEW_SUPPLIER_NAME -ERROR- '||l_api_msg);
            END LOOP;
                  FND_FILE.put_line (FND_FILE.LOG, 'befrore calling write log !!');
          p_write_log(p_supp_num, '//Supplier Update '||l_api_msg);
                  FND_FILE.put_line (FND_FILE.LOG, 'rollback executed!!');
            FND_FILE.put_line (
               FND_FILE.LOG,
               'The API P_UPDATE_VENDOR call failed with error ' || l_api_msg);
        
         ELSE
         begin
            update APPS.XXAH_SUPP_NFR_UPDATE set SUPP_NAME_FLAG='P' where supplier_number= p_supp_num;
            commit;
            exception when others then
            FND_FILE.put_line (FND_FILE.LOG, 'Error while updating supplier flag'||SQLERRM||SQLCODE);
            end;
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
   p_write_log(p_supp_num, '//P_UPDATE_VENDOR : '||SQLERRM);
   END P_UPD_VENDOR_NAME;
   
   -- Report
   
   PROCEDURE p_report
   IS
      CURSOR c_rec
      IS
           SELECT *
             FROM APPS.XXAH_SUPP_NFR_UPDATE ORDER BY SUPP_NAME_FLAG DESC;


      l_success_header   VARCHAR2 (1) := 'N';
      l_fail_header      VARCHAR2 (1) := 'N';
      l_noupd          VARCHAR2 (1) := 'N';
      l_active           VARCHAR2 (1) := 'N';
      l_scnt             NUMBER := 0;
      l_ecnt             NUMBER := 0;
      l_npcnt             NUMBER := 0;
      l_acnt    NUMBER := 0;

   BEGIN
      FOR r_rec IN c_rec
      LOOP
         IF r_rec.SUPP_NAME_FLAG = 'P'
         THEN
            IF l_success_header = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '| XXAH:Supplier Name Update API Program                    |');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Success Record');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |new Supplier Name');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               l_success_header := 'Y';
            END IF;

            l_scnt := l_scnt + 1;
            FND_FILE.PUT_LINE (
               FND_FILE.OUTPUT,
                  l_scnt
               || ' | '
               || r_rec.supplier_number
               || ' | '
               || r_rec.supplier_name
               || ' | '
               || r_rec.new_supplier_name);
         END IF;

         IF r_rec.SUPP_NAME_FLAG = 'E'
         THEN
            IF l_fail_header = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Failed Record');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |NEW Vendor Name| ERROR_LOG ');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               l_fail_header := 'Y';
            END IF;

            l_ecnt := l_ecnt + 1;
            FND_FILE.PUT_LINE (
               FND_FILE.OUTPUT,
                  l_ecnt
               || ' | '
               || r_rec.supplier_number
               || ' | '
               || r_rec.supplier_name
               || ' | '
               || r_rec.NEW_SUPPLIER_NAME
               || r_rec.supp_name_error);
         -- FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
         END IF;

         IF r_rec.SUPP_name_FLAG = null
         THEN
            IF l_noupd = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                                  'Suppliers with No Match update');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |vendor_site_code| ERROR_LOG ');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               l_noupd := 'Y';
            END IF;

            l_npcnt := l_npcnt + 1;
            FND_FILE.PUT_LINE (
               FND_FILE.OUTPUT,
                  l_npcnt
               || ' | '
               || r_rec.supplier_number
               || ' | '
               || r_rec.supplier_name);
    --  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
         END IF;


         l_acnt := l_acnt + 1;
      END LOOP;

      FND_FILE.PUT_LINE (
         FND_FILE.OUTPUT,
         '+---------------------------------------------------------------------------+');
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Total Records => ' || l_acnt);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Success Records => ' || l_scnt);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error records => ' || l_ecnt);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                         'Suppliers with no  update => ' || l_npcnt);

      FND_FILE.PUT_LINE (
         FND_FILE.OUTPUT,
         '+---------------------------------------------------------------------------+');
   END p_report;
   
      PROCEDURE p_write_log (p_supp_num VARCHAR2, p_message IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FND_FILE.put_line (FND_FILE.LOG,
                         'Executing PRAGMA autonomous_transaction!!');
                         
                          FND_FILE.put_line (FND_FILE.LOG,
                         'P message'||p_message||p_supp_num);
begin
      UPDATE XXAH_SUPP_NFR_UPDATE
         SET SUPP_name_FLAG = 'E', supp_name_error = p_message
       WHERE supplier_number = p_supp_num;
       commit;
       exception when too_many_rows then
         FND_FILE.put_line (FND_FILE.LOG,
                         'P message'||p_message||p_supp_num||SQLERRM||SQLCODE);
                         when others then
                           FND_FILE.put_line (FND_FILE.LOG,
                         'others'||p_message||p_supp_num||SQLERRM||SQLCODE);
       end;

      COMMIT;
      FND_FILE.put_line (FND_FILE.LOG, 'Commit Executed!!');
   END p_write_log;
END XXAH_NFR_SUPPNAME_PKG;

/
