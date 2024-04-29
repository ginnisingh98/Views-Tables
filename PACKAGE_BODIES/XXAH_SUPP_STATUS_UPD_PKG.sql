--------------------------------------------------------
--  DDL for Package Body XXAH_SUPP_STATUS_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SUPP_STATUS_UPD_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_SUPP_STATUS_UPD_PKG
   * DESCRIPTION       : PACKAGE TO Inactivate Supplier status Mass Update Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 17-June-2018        1.0       TCS     Initial
   * 16-Aug-2018         2.0       TCS     Added Supplier Site
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
           FROM XXAH_MASS_SUPP_STATUS_UPDATE
          WHERE UPDATE_FLAG = 'N'  order by vendor_number ;-- AND ps_number IS NULL;

      CURSOR c_BPA_check (
         p_vendor_id        IN NUMBER,
         p_vendor_site_id   IN NUMBER)
      IS
         SELECT DISTINCT pha.vendor_id
           FROM po_headers_all pha
          WHERE     TYPE_LOOKUP_CODE = 'BLANKET'
                AND (                   --TRUNC (pha.end_date) IS NOT NULL AND
                     TRUNC (pha.end_date) <=
                        TO_DATE ('01/01/2017', 'DD/MM/YYYY')) --TRUNC(SYSDATE))   >01.01.2017
                AND pha.org_id = 83
                AND pha.vendor_id = p_vendor_id
       AND pha.vendor_id NOT IN (SELECT DISTINCT pha.vendor_id
                                FROM po_headers_all pha
                               WHERE     TYPE_LOOKUP_CODE =
                                            'BLANKET'
                                     AND (   TRUNC (pha.end_date) >
                                                TO_DATE ('01/01/2017', 'DD/MM/YYYY')--TRUNC (SYSDATE)
                                          OR TRUNC (pha.end_date)
                                                IS NULL)
                                     AND pha.vendor_id =
                                            p_vendor_id);

      CURSOR c_supp_NOPO
      IS
         SELECT DISTINCT VENDOR_number,
                         vendor_site_id,
                         vendor_id,
                         ROWID
           FROM XXAH_MASS_SUPP_STATUS_UPDATE a
          WHERE     UPDATE_FLAG = 'N'
                AND prg_vendor_id IS NULL;
                --and rownum < 50;
                --AND ps_number IS NULL;
   --and ROWNUM <= 20 ORDER BY vendor_number DESC;


   BEGIN                                                           --Pending 1
      fnd_global.Apps_initialize (user_id        => fnd_global.user_id,
                                  resp_id        => fnd_global.resp_id,
                                  resp_appl_id   => fnd_global.resp_appl_id);

      FND_FILE.PUT_LINE (FND_FILE.LOG, 'Main loop');

      BEGIN                                                                --1
         FOR i IN c_supp_record
         LOOP
            BEGIN
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'start loop'||gv_ps_numbers);
               SELECT count(distinct apss.attribute9)
             INTO gv_ps_numbers
                 FROM ap_supplier_sites_all apss, ap_suppliers aps
                WHERE     apss.vendor_id = aps.vendor_id
                      AND aps.vendor_id = i.vendor_id;
                    --  and apss.vendor_site_id = i.vendor_site_id;

                IF gv_ps_numbers > 0 then
                  BEGIN

                     UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
                        SET update_flag = 'PS',
                            PRG_vendor_id = i.vendor_id,
                            PRG_VENDOR_SITE_ID = i.vendor_site_id
                      WHERE          vendor_id = i.vendor_id;
                      --and vendor_site_id = i.vendor_site_id;

                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        FND_FILE.PUT_LINE (
                           FND_FILE.LOG,
                              'Error -update details in validatin PS records '
                           || SQLCODE
                           || ' -ERROR- '
                           || SQLERRM);
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                      FND_FILE.PUT_LINE (
                           FND_FILE.LOG,
                              'Error in updating PS records in Temp table '
                           || SQLCODE
                           || ' -ERROR- '
                           || SQLERRM);
            END;
         END LOOP;
      END;                                                                 --1

      FOR i IN c_supp_record
      LOOP
         --  FOR j IN  c_supp_detail (i.vendor_number,i.vendor_site_code)
         -- LOOP
         FOR j IN c_BPA_check (i.vendor_id, i.vendor_site_id)
         LOOP
            gv_api_msg := NULL;
            gv_commit_flag := 'Y';
            gv_address_flag := NULL;
            gv_site_flag := NULL;
            gv_ps_number := NULL;
            lv_address_flag := 'Y';
            lv_site_flag := 'Y';

   FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                     'Starting address update for '||i.vendor_id
                  || lv_address_flag
                  || lv_site_flag);

            IF gv_commit_flag = 'Y' AND lv_address_flag = 'Y'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                     'Starting address update for '||i.vendor_id
                  || lv_address_flag
                  || lv_site_flag);
               P_UPDATE_SUPPLIER_ADDRESS (i.ROWID,i.vendor_id, i.vendor_site_id);
            END IF;

            IF gv_commit_flag = 'Y' AND lv_site_flag = 'Y'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                  'Starting site update for ' ||i.vendor_id || lv_address_flag || lv_site_flag);
               P_UPDATE_SUPPLIER_SITE (i.ROWID,i.vendor_site_id);
            END IF;

            BEGIN                                                          --3
               SELECT address_flag, site_flag
                 INTO gv_address_flag, gv_site_flag
                 FROM XXAH_MASS_SUPP_STATUS_UPDATE
                WHERE vendor_site_id = i.vendor_site_id;
            EXCEPTION                                                      --3
               WHEN OTHERS
               THEN
                  fnd_file.put_line (
                     fnd_file.LOG,
                        'error while fetching flag '
                     || gv_address_flag
                     || gv_site_flag);
            END;                                                           --3

            IF gv_commit_flag = 'Y'
            THEN
             FND_FILE.PUT_LINE (FND_FILE.LOG,
                               'Starting vendor update' || gv_commit_flag);

               IF gv_address_flag = 'Y' AND gv_site_flag = 'Y'
               THEN
                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                        'Starting vendor update'
                     || gv_address_flag
                     || gv_site_flag);
                  P_UPDATE_VENDOR (i.ROWID, i.VENDOR_number);
               END IF;
            END IF;


            IF gv_commit_flag <> 'N'
            THEN
               UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
                  SET UPDATE_FLAG = 'P',VENDOR_FLAG='P',PRG_vendor_id = i.vendor_id,
                            PRG_VENDOR_SITE_ID = i.vendor_site_id
                WHERE ROWID = i.ROWID and vendor_number =i.VENDOR_number;

               COMMIT;
            ELSE
               ROLLBACK;
               NULL;
               p_write_log (i.ROWID, gv_api_msg);
            END IF;
         END LOOP;
      END LOOP;

      -- Code for updating Suppliers with NO PO
      FOR i IN c_supp_NOPO --(i.vendor_id,i.vendor_site_id) --(p_vendor_id IN NUMBER,p_vendor_site_id IN NUMBER)
      LOOP
         --  FOR j IN  c_supp_detail (i.vendor_number,i.vendor_site_code)
         -- LOOP
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
               'Update starts for supplier with NO BPA '
            || i.vendor_number
            || ' -'
            || i.vendor_id
            || '-'
            || i.vendor_site_id);
         gv_api_msg := NULL;
         gv_commit_flag := 'Y';
         gv_address_flag := NULL;
         gv_site_flag := NULL;
         lv_address_flag := NULL;
         lv_site_flag := NULL;
         gv_ps_number := NULL;

         BEGIN                                                             --4
            UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
               SET prg_vendor_id = i.vendor_id,
                   prg_vendor_site_id = i.vendor_site_id
             WHERE     vendor_number = i.vendor_number
                   AND vendor_site_id = i.vendor_site_id;
         EXCEPTION                                                         --4
            WHEN OTHERS
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                     'Error -update details in temp table '
                  || SQLCODE
                  || ' -ERROR- '
                  || SQLERRM);
         END;                                                              --4

         BEGIN --Pending 2                     -- Feching vendor id for No BPA
            SELECT vendor_id
              INTO gv_vendor_id
              FROM po_headers_all
             WHERE vendor_id = i.vendor_id;
         EXCEPTION                                                --Caling API
            WHEN NO_DATA_FOUND
            THEN                               -- Feching vendor id for No BPA
                     lv_address_flag := 'Y';
                     lv_site_flag := 'Y';
    FND_FILE.PUT_LINE (
            FND_FILE.LOG,
               'Inside no data found for NO BPA '
            || lv_address_flag
            || ' -'
            || lv_site_flag
            || '-'
            || gv_commit_flag);
               IF gv_commit_flag = 'Y' AND lv_address_flag = 'Y'
               THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'before calling supplier update '||SQLCODE||' -ERROR- '||SQLERRM);
                  P_UPDATE_SUPPLIER_ADDRESS (i.ROWID,i.vendor_id, i.vendor_site_id);
               END IF;

               IF     gv_commit_flag = 'Y'
                  AND lv_site_flag = 'Y'
                  AND lv_address_flag = 'Y'
               THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'before calling supplier site update '||SQLCODE||' -ERROR- '||SQLERRM);
                  P_UPDATE_SUPPLIER_SITE (i.ROWID,i.vendor_site_id);
               END IF;

               BEGIN                                                       --6
                  SELECT address_flag, site_flag
                    INTO gv_address_flag, gv_site_flag
                    FROM XXAH_MASS_SUPP_STATUS_UPDATE
                   WHERE vendor_site_id = i.vendor_site_id;
               EXCEPTION                                                   --6
                  WHEN OTHERS
                  THEN
                     fnd_file.put_line (
                        fnd_file.LOG,
                           'error while fetching flag '
                        || gv_address_flag
                        || gv_site_flag);
               END;

               fnd_file.put_line (fnd_file.LOG,
                                 ' before calling vendor API ' || gv_commit_flag||gv_address_flag||gv_site_flag);                                               --6

               IF gv_commit_flag = 'Y'
               THEN
                  IF gv_address_flag = 'Y' AND gv_site_flag = 'Y'
                  THEN
                     fnd_file.put_line (fnd_file.LOG,
                                 ' before calling vendor API after if ' || gv_commit_flag||gv_address_flag||gv_site_flag);
                     P_UPDATE_VENDOR (i.ROWID, i.VENDOR_number);
                  END IF;
               END IF;

             --  fnd_file.put_line (fnd_file.LOG,
                              --    'gv_commit_flag ' || gv_commit_flag);

               IF gv_commit_flag <> 'N'
               THEN
                  UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
                     SET UPDATE_FLAG = 'R',VENDOR_FLAG='P'
                   WHERE ROWID = i.ROWID;

                  COMMIT;
               ELSE
                  ROLLBACK;
                  NULL;
                  p_write_log (i.ROWID, gv_api_msg);
               END IF;
            WHEN too_many_rows
            THEN
               -- Feching vendor id for No BPA
               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                     'Error while fetching vendor id for No BPA Suppliers '
                  || SQLCODE
                  || ' -ERROR- '
                  || SQLERRM);
              --   p_write_log(l_rowid, '//NO PO '||l_api_msg);
           UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
         SET UPDATE_FLAG = 'E', error_log = 'Active PO Available'
       WHERE vendor_id = i.vendor_id;
               --   p_write_log (i.ROWID,'Too Many rows');
                  when others then  FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                     'when others '
                  || SQLCODE
                  || ' -ERROR- '
                  || SQLERRM);
         END;                                                      --Pending 2
      -- Feching vendor id for No BPA
      END LOOP;

      -- end loop;
      p_report;
   --  end ;--Pending 1
   END P_MAIN;


   PROCEDURE P_UPDATE_SUPPLIER_ADDRESS (p_row_id IN VARCHAR2,p_vendor_id        IN NUMBER,
                                        p_vendor_site_id   IN NUMBER)
   IS
      l_party_site_rec   hz_party_site_v2pub.PARTY_SITE_REC_TYPE;
      l_obj_num          NUMBER;
      x_return_status    VARCHAR2 (1);
      x_msg_count        NUMBER;
      x_msg_data         VARCHAR2 (2000);
      l_party_id         VARCHAR2 (2000);
      l_address_flag     VARCHAR2 (20);
      l_msg_index_out    NUMBER := NULL;
      l_rowid            VARCHAR2 (200);
      l_api_msg          VARCHAR2 (2000);
      lv_ps_number       NUMBER := NULL;
      lv_party_site_id   NUMBER := NULL;
   BEGIN
      -- Initialize apps session
      fnd_global.apps_initialize (user_id        => fnd_global.user_id,
                                  resp_id        => fnd_global.resp_id,
                                  resp_appl_id   => fnd_global.resp_appl_id);

      FND_FILE.PUT_LINE (
         FND_FILE.LOG,
         'Inside address update' || lv_address_flag || lv_site_flag);

      BEGIN
         SELECT aps.party_id,
                apss.attribute9,
                hps.party_site_id,
                hps.OBJECT_VERSION_NUMBER
           INTO l_party_id,
                lv_ps_number,
                lv_party_site_id,
                l_obj_num
           FROM ap_suppliers aps,
                ap_supplier_sites_all apss,
                hz_party_sites hps
          WHERE     aps.vendor_id = apss.vendor_id
                AND apss.party_site_id = hps.party_site_id
                AND apss.vendor_site_id = p_vendor_site_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            FND_FILE.put_line (
               FND_FILE.LOG,
                  'Unable to derive the party_id information for site id:'
               || p_vendor_id);
      END;

      IF lv_party_site_id IS NOT NULL AND l_obj_num IS NOT NULL
      THEN
        -- FND_FILE.put_line (
         --   FND_FILE.LOG,
           --    'l_party_site_id  => '
         --   || lv_party_site_id
         --   || l_obj_num
         --   || l_party_id);
         l_party_site_rec.party_site_id := lv_party_site_id; -- rec_party_site.party_site_id;
         l_party_site_rec.status := 'I';

        -- FND_FILE.put_line (
          --  FND_FILE.LOG,
          --     ' l_party_site_rec.status   => '
         --   || l_party_site_rec.party_site_id
         --   || l_party_site_rec.status);                     --p_party_status;
         hz_party_site_v2pub.update_party_site (
            p_party_site_rec          => l_party_site_rec,
            p_object_version_number   => l_obj_num, --rec_party_site.object_version_number,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data);

         FND_FILE.put_line (FND_FILE.LOG,
                            '--UPDATE_VENDOR_ADDRESS => ' || x_return_status);

         IF x_return_status = fnd_api.g_ret_sts_success
         THEN
            NULL;
            gv_commit_flag := 'Y';

            FND_FILE.put_line (
               FND_FILE.LOG,
                  '--Inside UPDATE_VENDOR_ADDRESS for flag upadte => '
               || x_return_status
               || p_vendor_id
               || p_vendor_site_id);

            --Update Supplier SET flag for pass records
            BEGIN
               UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
                  SET ADDRESS_FLAG = 'Y'
                WHERE     vendor_id = p_vendor_id
                      AND VENDOR_SITE_ID = p_vendor_site_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                        'Error -update details ADDRESS_FLAG'
                     || p_vendor_id
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM);
            END;
         ELSE
              FND_FILE.put_line (FND_FILE.LOG,
                            '-gv_commit_flag => ' || gv_commit_flag);
            gv_commit_flag := 'N';
              FND_FILE.put_line (FND_FILE.LOG,
                            '-gv_commit_flag => ' || gv_commit_flag);
            ROLLBACK;

            --Update Supplier SET flag for failed records
            BEGIN
               UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
                  SET ADDRESS_FLAG = 'N'
                WHERE     vendor_number = p_vendor_id
                      AND VENDOR_SITE_ID = p_vendor_site_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                        'Error -update details ADDRESS_FLAG'
                     || p_vendor_id
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM);
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
         --   p_write_log (P_ROWID, gv_api_msg);
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
               'Error -P_UPDATE_SUPPLIER_ADDRESS '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END P_UPDATE_SUPPLIER_ADDRESS;


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
         AND lr_existing_vendor_site_rec.attribute9 IS NULL
      THEN --AND p_ss_inactive_date <> nvl(lr_existing_vendor_site_rec.INACTIVE_DATE,to_date('31-DEC-4721','DD-MON-YYYY')) THEN

        lr_vendor_site_rec.INACTIVE_DATE := SYSDATE;
         FND_FILE.put_line (FND_FILE.LOG,
                            '--update inactive_date for Supplier Site');
      END IF;
  l_ss_update := 'Y';

      IF l_ss_update = 'Y' AND lv_address_flag = 'Y'
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
               UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
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
            END;
         ELSE
            gv_commit_flag := 'N';
            ROLLBACK;
  FND_FILE.put_line (FND_FILE.LOG,
                            '-gv_commit_flag => ' || gv_commit_flag);
            --Update Supplier SET flag for failed records
            BEGIN
               UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
                  SET SITE_FLAG = 'N'
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
   END P_UPDATE_SUPPLIER_SITE;

   PROCEDURE P_UPDATE_VENDOR (p_row_id IN VARCHAR2, p_vendor_num IN NUMBER)
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
         ' Inside Vendor update Vendor_number' || p_vendor_num);

      l_api_msg := NULL;
      l_rowid := NULL;
      l_end_date_active := NULL;
      l_update_flag := NULL;

      BEGIN
         SELECT ROWID
           INTO l_rowid
           FROM XXAH_MASS_SUPP_STATUS_UPDATE
          WHERE ROWID = p_row_id AND vendor_number = p_vendor_num;

         FND_FILE.put_line (
            FND_FILE.LOG,
            'Vendor_number' || p_vendor_num || 'Row number ' || l_rowid);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
            FND_FILE.put_line (
               FND_FILE.LOG,
               'Unable to derive the row id n for vendor id:' || p_vendor_num);
      END;

      BEGIN
         SELECT *
           INTO lr_existing_vendor_rec
           FROM ap_suppliers asa
          WHERE asa.segment1 = p_vendor_num;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
            FND_FILE.put_line (
               FND_FILE.LOG,
                  'Unable to derive the supplier  information for vendor id:'
               || p_vendor_num);
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
            NULL;
            --commit;
            gv_commit_flag := 'Y';
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
   END P_UPDATE_VENDOR;

   PROCEDURE p_write_log (p_row_id VARCHAR2, p_message IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FND_FILE.put_line (FND_FILE.LOG,
                         'Executing PRAGMA autonomous_transaction!!');

                          FND_FILE.put_line (FND_FILE.LOG,
                         'P message'||p_message||p_row_id);
begin
      UPDATE XXAH_MASS_SUPP_STATUS_UPDATE
         SET UPDATE_FLAG = 'E', error_log = p_message
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


   PROCEDURE p_report
   IS
      CURSOR c_rec
      IS
           SELECT *
             FROM XXAH_MASS_SUPP_STATUS_UPDATE ORDER BY UPDATE_FLAG DESC;
         --where  ROWID = p_row_id
         --where request_id = gv_request_id
         --ORDER BY UPDATE_FLAG DESC;

      l_success_header   VARCHAR2 (1) := 'N';
      l_fail_header      VARCHAR2 (1) := 'N';
      l_nobpa            VARCHAR2 (1) := 'N';
      l_active           VARCHAR2 (1) := 'N';
      l_scnt             NUMBER := 0;
      l_fcnt             NUMBER := 0;
      l_bcnt             NUMBER := 0;
      l_acnt             NUMBER := 0;
      l_actcnt           NUMBER := 0;
      l_pscnt            NUMBER := 0;
   BEGIN
      FOR r_rec IN c_rec
      LOOP
         IF r_rec.UPDATE_FLAG = 'P'
         THEN
            IF l_success_header = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '| XXAH:Sites Update API Program                    |');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Success Record');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |vendor_site_code');
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
               || r_rec.vendor_number
               || ' | '
               || r_rec.vendor_name
               || ' | '
               || r_rec.vendor_site_code);
         END IF;

         IF r_rec.UPDATE_FLAG = 'E'
         THEN
            IF l_fail_header = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Failed Record');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |vendor_site_code| ERROR_LOG ');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               l_fail_header := 'Y';
            END IF;

            l_fcnt := l_fcnt + 1;
            FND_FILE.PUT_LINE (
               FND_FILE.OUTPUT,
                  l_fcnt
               || ' | '
               || r_rec.vendor_number
               || ' | '
               || r_rec.vendor_name
               || ' | '
               || r_rec.vendor_site_code
               || ' | '
               || r_rec.error_log);
         -- FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
         END IF;

         IF r_rec.UPDATE_FLAG = 'R'
         THEN
            IF l_nobpa = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                                  'Suppliers with NO PO Record');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |vendor_site_code| ERROR_LOG ');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               l_nobpa := 'Y';
            END IF;

            l_bcnt := l_bcnt + 1;
            FND_FILE.PUT_LINE (
               FND_FILE.OUTPUT,
                  l_bcnt
               || ' | '
               || r_rec.vendor_number
               || ' | '
               || r_rec.vendor_name
               || ' | '
               || r_rec.vendor_site_code
               || ' | '
               || r_rec.error_log);
         -- FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
         END IF;

         IF r_rec.UPDATE_FLAG = 'N'
         THEN
            IF l_active = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                                  'Suppliers with Active PO');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |vendor_site_code| ERROR_LOG ');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               l_active := 'Y';
            END IF;

            l_actcnt := l_actcnt + 1;
            FND_FILE.PUT_LINE (
               FND_FILE.OUTPUT,
                  l_actcnt
               || ' | '
               || r_rec.vendor_number
               || ' | '
               || r_rec.vendor_name
               || ' | '
               || r_rec.vendor_site_code
               || ' | '
               || r_rec.error_log);
         -- FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
         END IF;
         --- Updating active peolesoft records
IF r_rec.UPDATE_FLAG = 'PS'
         THEN
            IF l_active = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                                  'Suppliers with Peoplsoft Number');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  'SR NO | Vendor Number | Vendor Name |vendor_site_code| ERROR_LOG ');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               l_active := 'Y';
            END IF;

            l_pscnt := l_pscnt + 1;
            FND_FILE.PUT_LINE (
               FND_FILE.OUTPUT,
                  l_pscnt
               || ' | '
               || r_rec.vendor_number
               || ' | '
               || r_rec.vendor_name
               || ' | '
               || r_rec.vendor_site_code
               || ' | '
               || r_rec.error_log);
         -- FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
         END IF;

         l_acnt := l_acnt + 1;
      END LOOP;

      FND_FILE.PUT_LINE (
         FND_FILE.OUTPUT,
         '+---------------------------------------------------------------------------+');
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Total Records => ' || l_acnt);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Success Records => ' || l_scnt);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'NO PO Records => ' || l_bcnt);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                         'Suppliers with Active BPA => ' || l_actcnt);
     FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                         'Suppliers with Peoplesoft Record => ' || l_pscnt);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Failed Records => ' || l_fcnt);
      FND_FILE.PUT_LINE (
         FND_FILE.OUTPUT,
         '+---------------------------------------------------------------------------+');
   END p_report;
END XXAH_SUPP_STATUS_UPD_PKG;

/
