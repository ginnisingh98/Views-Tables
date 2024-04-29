--------------------------------------------------------
--  DDL for Package Body XXAH_NFRML_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_NFRML_UPDATE_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_NFRML_UPDATE_PKG
   * DESCRIPTION       : PACKAGE TO  Update NFR Supplier Match level
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 25-AUG-2017        1.0       Menaka      Supplier name update for Match level update
   ****************************************************************************/
   gv_request_id    fnd_concurrent_requests.request_id%TYPE
                       := Fnd_Global.conc_request_id;
   gv_commit_flag   VARCHAR2 (1);
   gv_api_msg       VARCHAR2 (2000);
   row_id           NUMBER;

   PROCEDURE P_MAIN ( errbuf          OUT VARCHAR2,
                     retcode         OUT NUMBER)
   IS
      l_vendor_id                NUMBER;
      l_error_flag               VARCHAR2 (10);
      l_error_log                VARCHAR2 (10000);
      l_vendor_name              VARCHAR2 (1000);
      l_party_id                 NUMBER;
      l_xxah_supplier_type_att   VARCHAR2 (1000);

      CURSOR C1
      IS
         -- Updating 1way to 3 way p_po_match  
         SELECT ROWID,
                supplier_number,
                match_level,
                new_match_level
           FROM APPS.XXAH_SUPP_NFR_UPDATE
          WHERE match_level = '3-Way' AND new_match_level ='1-Way' ;-- IS NOT NULL ;
   -- Updating
 /*  SELECT ROWID,
                supplier_number,
                match_level,
                new_match_level
           FROM APPS.XXAH_SUPP_NFR_UPDATE
          WHERE match_level = '1-Way' AND new_match_level ='3-Way';-- IS NOT NULL ;*/

   BEGIN
      fnd_global.Apps_initialize (user_id        => fnd_global.user_id,
                                  resp_id        => fnd_global.resp_id,
                                  resp_appl_id   => fnd_global.resp_appl_id);
      FND_FILE.PUT_LINE (FND_FILE.LOG, 'Main loop');
     -- FND_FILE.PUT_LINE (FND_FILE.LOG, 'Main loop:::'||p_po_match );

      FOR i IN c1
      LOOP
         l_vendor_id := NULL;
     FND_FILE.PUT_LINE (FND_FILE.LOG, ' loop1' );
         -- Validating Supplier Type

         BEGIN
            SELECT aps.vendor_id, aps.vendor_name, hzp.PARTY_ID
              INTO l_vendor_id, l_vendor_name, l_party_id
              FROM ap_suppliers aps,
                   hz_parties hzp,
                   POS_XXAH_SUPPLIER_TY_AGV xxah
             WHERE     aps.party_id = hzp.party_id
                   AND aps.party_id = xxah.party_id
                   AND xxah.XXAH_SUPPLIER_TYPE_ATT = 'NFR'
                   AND UPPER (aps.segment1) = i.supplier_number;
         -- AND upper(aps.vendor_name) =upper(i.supplier_name);
         EXCEPTION
            WHEN OTHERS
            THEN
               BEGIN
                  SELECT aps.vendor_id, xxah.XXAH_SUPPLIER_TYPE_ATT
                    INTO l_vendor_id, l_xxah_supplier_type_att
                    FROM ap_suppliers aps,
                         hz_parties hzp,
                         POS_XXAH_SUPPLIER_TY_AGV xxah
                   WHERE     aps.party_id = hzp.party_id
                         AND aps.party_id = xxah.party_id
                         AND UPPER (aps.segment1) = UPPER (i.supplier_number);

                  --AND upper(aps.vendor_name) =upper(i.supplier_name);
                  IF l_vendor_id IS NOT NULL
                  THEN
                     l_error_flag := 'Y';
                     l_error_log :=
                           l_error_log
                        || '//Supplier Type is not NFR!!! And Type is '
                        || l_xxah_supplier_type_att;
                  ELSE
                     l_error_flag := 'Y';
                     l_error_log := l_error_log || '//Supplier Not Found !!! ';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_error_flag := 'Y';
                     l_error_log :=
                           l_error_log
                        || '//Supplier Not Found :  '
                        || SQLCODE
                        || '-'
                        || SQLERRM;
                     NULL;
               END;

               NULL;
         END;
 --    FND_FILE.PUT_LINE (FND_FILE.LOG, ' loop4'||p_po_match );
         BEGIN
            gv_commit_flag := 'Y';
           -- FND_FILE.PUT_LINE (FND_FILE.LOG, 'Updating Match:' || p_po_match);

            IF gv_commit_flag = 'Y'
            THEN
               P_UPDATE_NFRML (i.ROWID, i.supplier_number);
            END IF;
         END;
      END LOOP;
         p_report;
   END;

   PROCEDURE P_UPDATE_NFRML (p_row_id       IN VARCHAR2,
                             p_vendor_num   IN NUMBER
                            )
   IS
      p_api_version                NUMBER;
      p_init_msg_list              VARCHAR2 (200);
      p_commit                     VARCHAR2 (200);
      p_validation_level           NUMBER;
      x_return_status              VARCHAR2 (200);
      x_msg_count                  NUMBER;
      x_msg_data                   VARCHAR2 (200);
      lr_vendor_rec                apps.ap_vendor_pub_pkg.r_vendor_rec_type;
      lr_existing_vendor_rec       ap_suppliers%ROWTYPE;
      l_msg                        VARCHAR2 (200);
      l_inspection_required_flag   VARCHAR2 (1) := NULL;
      l_receipt_required_flag      VARCHAR2 (1) := NULL;
      l_rowid                      VARCHAR2 (200);
      ln_msg_index_out             NUMBER := NULL;
      l_api_msg                    VARCHAR2 (2000);
      p_vendor_id                  NUMBER;
      ppo_match VARCHAR2(10);
      
g_null_char constant varchar2(1) := chr(0);
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

      l_inspection_required_flag := NULL;
      l_receipt_required_flag := NULL;
      l_api_msg := NULL;
      l_rowid := NULL;
      
ppo_match := '1-Way';
      SELECT ROWID
        INTO l_rowid
        FROM APPS.XXAH_SUPP_NFR_UPDATE
       WHERE ROWID = p_row_id AND SUPPLIER_NUMBER = p_vendor_num;

 FND_FILE.PUT_LINE (FND_FILE.LOG, 'rOWID:' || l_rowid);
  FND_FILE.PUT_LINE (FND_FILE.LOG, 'ppo_match:' || ppo_match);
      --Fetching vendor_id
      BEGIN
         SELECT vendor_id
           INTO p_vendor_id
           FROM ap_suppliers asa
          WHERE asa.segment1 = p_vendor_num;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
            p_write_log(l_rowid, 'Unable to derive the supplier  information for vendor');
            FND_FILE.put_line (
               FND_FILE.LOG,
                  'Unable to derive the supplier  information for p_vendor_num:'
               || p_vendor_num);
      END;

      BEGIN
         SELECT *
           INTO lr_existing_vendor_rec
           FROM ap_suppliers asa
          WHERE asa.segment1 = p_vendor_num;
      -- WHERE asa.vendor_id in (select vendor_id from ap_suppliers where segment1=p_vendor_num);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
            --p_write_log(l_rowid, 'Unable to derive the supplier  information for vendor');
            FND_FILE.put_line (
               FND_FILE.LOG,
                  'Unable to derive the supplier  information for p_vendor_num:'
               || p_vendor_num);
      END;
          --  l_inspection_required_flag        := 'Y';
     --   l_receipt_required_flag         := 'Y';
 FND_FILE.PUT_LINE (FND_FILE.LOG, 'before assigninh:' || ppo_match||l_inspection_required_flag|| l_receipt_required_flag);

      --<Match Approval Level>--
      IF ppo_match        = '2-Way'
      THEN
         l_inspection_required_flag     := 'N';
         l_receipt_required_flag         := 'N';
      ELSIF ppo_match    = '3-Way'
      THEN
         l_inspection_required_flag     := 'N';
         l_receipt_required_flag         := 'Y';
      ELSIF ppo_match    = '4-Way'
      THEN
         l_inspection_required_flag        := 'Y';
         l_receipt_required_flag         := 'Y';
      ELSE
         l_inspection_required_flag     := fnd_api.g_null_char;
         l_receipt_required_flag         := fnd_api.g_null_char;
      END IF;
            --  l_inspection_required_flag        := 'Y';
       --  l_receipt_required_flag         := 'Y';
  FND_FILE.PUT_LINE (FND_FILE.LOG, 'after assigninh:' || ppo_match||l_inspection_required_flag|| l_receipt_required_flag);
    /*  --<Match Approval Level>--
      IF ppo_match = '1-Way'
      THEN
  
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'iNSIDRE ASSIGNMENT p_po_match:' || ppo_match||l_inspection_required_flag|| l_receipt_required_flag);
             l_inspection_required_flag := 'N';
         l_receipt_required_flag := 'Y';
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'iNSIDRE ASSIGNMENT p_po_match:' || ppo_match||l_inspection_required_flag|| l_receipt_required_flag);
      ELSIF ppo_match = '3-Way'
      THEN
           l_inspection_required_flag := NULL;
         l_receipt_required_flag := NULL;
      END IF;*/

      IF (ppo_match = '1-Way' OR ppo_match = '3-Way')
      THEN
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'iNSIDRE calling ppo_match:' || ppo_match||l_inspection_required_flag|| l_receipt_required_flag||ppo_match);
         --Deactivate Vendor
         lr_vendor_rec.vendor_id := lr_existing_vendor_rec.vendor_id;
         lr_vendor_rec.inspection_required_flag :=  l_inspection_required_flag;
         lr_vendor_rec.receipt_required_flag := l_receipt_required_flag;


         ap_vendor_pub_pkg.update_vendor (
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            p_commit             => p_commit,
            p_validation_level   => p_validation_level,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_vendor_rec         => lr_vendor_rec,
            p_vendor_id          => p_vendor_id);
            commit;
         FND_FILE.put_line (FND_FILE.LOG,
                            '--PO_MATCH => ' || x_return_status);

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            ROLLBACK;
            gv_commit_flag := 'N';

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
         p_write_log(l_rowid, '//P_match level update '||l_api_msg);
         ELSE
                  begin
            update APPS.XXAH_SUPP_NFR_UPDATE set ml_flag='P' where supplier_number= p_vendor_num;
            commit;
            exception when others then
            FND_FILE.put_line (FND_FILE.LOG, 'Error while updating match level flag'||SQLERRM||SQLCODE);
            end;
         END IF;
      ELSE
         FND_FILE.put_line (FND_FILE.LOG, 'rollback executed!!');
         ROLLBACK;

         --p_write_log(l_rowid, '//Invalid PO Match Name');
         gv_commit_flag := 'N';
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
 p_write_log(l_rowid, '//P_Match level : '||SQLERRM);
   END P_UPDATE_NFRML;
  
   
   PROCEDURE p_report
   IS
      CURSOR c_rec
      IS
           SELECT *
             FROM APPS.XXAH_SUPP_NFR_UPDATE where new_match_level='1-Way'and  ml_flag is not null ORDER BY ML_FLAG DESC;


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
         IF r_rec.ML_FLAG = 'P'
         THEN
            IF l_success_header = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '| XXAH:Supplier match level  Update API Program                    |');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Success Record');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
 'SR NO | Vendor Number | Vendor Name |Match Level|New Match Level| ERROR_LOG ');
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
               || r_rec.match_level
               || ' | '
               || r_rec.new_match_level);
         END IF;

         IF r_rec.ML_FLAG = 'E'
         THEN
            IF l_fail_header = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Failed Record');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |Match Level|New Match Level| ERROR_LOG ');
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
               || r_rec.MATCH_LEVEL
               ||' | '
                || r_rec.new_MATCH_LEVEL
                  ||' | '
               || r_rec.mL_error);
         -- FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
         END IF;

       /*  IF r_rec.ML_FLAG = null
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
         END IF;*/


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
   
      PROCEDURE p_write_log (p_row_id VARCHAR2, p_message IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FND_FILE.put_line (FND_FILE.LOG,
                         'Executing PRAGMA autonomous_transaction!!');
                         
                          FND_FILE.put_line (FND_FILE.LOG,
                         'P message'||p_message||p_row_id);
begin
      UPDATE XXAH_SUPP_NFR_UPDATE
         SET ML_FLAG = 'E', ML_ERROR = p_message
       WHERE ROWID = p_row_id;
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
END XXAH_NFRML_UPDATE_PKG;

/
