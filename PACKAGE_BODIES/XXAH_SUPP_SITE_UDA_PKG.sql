--------------------------------------------------------
--  DDL for Package Body XXAH_SUPP_SITE_UDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SUPP_SITE_UDA_PKG" as
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_SUPP_SITE_UDA_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Update Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 05-APR-2017        1.0       Sunil Thamke     Initial
   ****************************************************************************/
gv_request_id                     fnd_concurrent_requests.request_id%TYPE:= Fnd_Global.conc_request_id;
gv_commit_flag                    VARCHAR2(1);
gv_api_msg                        VARCHAR2(2000);


PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER)
IS

   lv_bank_id                      NUMBER;
   lv_branch_id                    NUMBER;
      lv_account_id                   NUMBER;
      l_sup_type            VARCHAR2(50);
      l_ssup_type            VARCHAR2(50);
      l_short_code            hr_operating_units.short_code%TYPE;

CURSOR c_supp_rec
IS
select distinct aps.vendor_id, aps.party_id, aps.vendor_name, aps.segment1 supplier_number from pos_supp_prof_ext_b psp,
ap_suppliers aps
where psp.party_id = aps.party_id
and (aps.END_DATE_ACTIVE is null OR trunc(aps.END_DATE_ACTIVE) >= trunc(sysdate))
AND psp.ATTR_GROUP_ID = 224
and psp.C_EXT_ATTR1 = 'NFR'
--and aps.vendor_name = 'Coupa'
order by  aps.vendor_id;

CURSOR c_supplier_site(p_vendor_id IN NUMBER)
IS
select  party_site_id, vendor_site_id, VENDOR_SITE_CODE, org_id
 from ap_supplier_sites_all
where vendor_id = p_vendor_id
and (INACTIVE_DATE is null or trunc(INACTIVE_DATE)>=trunc(sysdate))
and org_id=83
order by vendor_site_id;


CURSOR c_ss_nfr(p_party_id IN NUMBER, p_party_site_id IN VARCHAR2, p_vendor_site_id IN VARCHAR2 )
IS
SELECT edl.DATA_LEVEL_NAME,psp.PK1_VALUE, psp.PK2_VALUE, psp.C_EXT_ATTR1
  FROM APPS.pos_supp_prof_ext_b psp,
       APPS.ego_attr_groups_v egv,
       EGO.EGO_DATA_LEVEL_B edl
 WHERE    psp.ATTR_GROUP_ID = egv.ATTR_GROUP_ID
       AND psp.DATA_LEVEL_ID = edl.DATA_LEVEL_ID
       AND edl.DATA_LEVEL_NAME = 'SUPP_ADDR_SITE_LEVEL'
       AND psp.C_EXT_ATTR1 = 'NFR'
       AND psp.party_id = p_party_id
       AND psp.PK1_VALUE = p_party_site_id
       AND psp.PK2_VALUE = p_vendor_site_id
       AND psp.ATTR_GROUP_ID = 241;

        l_supplier_type    VARCHAR2(10);

BEGIN
    fnd_global.Apps_initialize (user_id => fnd_global.user_id,
                                resp_id => fnd_global.resp_id,
                                resp_appl_id => fnd_global.resp_appl_id);

            FND_FILE.PUT_LINE(FND_FILE.LOG,'--BEGIN--');
    FOR i IN c_supp_rec
        LOOP
        l_supplier_type    := NULL;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'SUPPLIERS_NAME:'||i.vendor_name);
            FOR j IN c_supplier_site(i.vendor_id)
            LOOP
            FND_FILE.PUT_LINE(FND_FILE.LOG,'VENDOR_SITE_NAME:'||j.VENDOR_SITE_CODE);

                         FND_FILE.PUT_LINE(FND_FILE.LOG,'party_site_id:'||TO_CHAR(j.party_site_id)||'vendor_site_id:'||TO_CHAR(j.vendor_site_id));

                FOR k IN c_ss_nfr(i.party_id, TO_CHAR(j.party_site_id), TO_CHAR(j.vendor_site_id))
                LOOP
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'SUPPLIER_TYPE:'|| k.C_EXT_ATTR1);

                    l_supplier_type    := NULL;
                    l_supplier_type := k.C_EXT_ATTR1;
                END LOOP;

                    IF l_supplier_type IS NULL THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_supplier_type '||l_supplier_type);

                     p_uda (i.party_id,
                     'XXAH_Supplier_Site_Type',
                     'Supplier Site Type',
                     'NFR',
                     NULL,
                     'SUPP_ADDR_SITE_LEVEL',
                     j.party_site_id,
                     j.vendor_site_id
                     );

BEGIN
        l_short_code    := NULL;

        select SHORT_CODE
            into l_short_code
        from hr_operating_units
        where organization_id = j.org_id;

    EXCEPTION
        WHEN OTHERS
             THEN
        fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
        fnd_file.put_line (fnd_file.LOG,
                               'Error at l_short_code '
                            || SQLCODE
                            || ' -ERROR- '
                            || SQLERRM
                           );
        fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
END;

BEGIN
    l_sup_type    := NULL;

      SELECT LISTAGG (psp.c_ext_attr1, ';')
                     WITHIN GROUP (ORDER BY psp.party_id)
                     into l_sup_type
             FROM APPS.pos_supp_prof_ext_b psp,
                  APPS.ego_attr_groups_v egv,
                  EGO.EGO_DATA_LEVEL_B edl
            WHERE     psp.party_id = i.party_id
                  AND psp.d_ext_attr3 IS NULL
                  AND psp.ATTR_GROUP_ID = egv.ATTR_GROUP_ID
                  AND psp.DATA_LEVEL_ID = edl.DATA_LEVEL_ID
                  AND egv.attr_group_name = 'XXAH_Supplier_Type'
                  AND edl.DATA_LEVEL_NAME = 'SUPP_LEVEL';
        EXCEPTION
        WHEN OTHERS
             THEN
        fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
        fnd_file.put_line (fnd_file.LOG,
                               'Error at l_sup_type '
                            || SQLCODE
                            || ' -ERROR- '
                            || SQLERRM
                           );
        fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
END;

BEGIN
    l_ssup_type    := NULL;

      SELECT LISTAGG (psp.c_ext_attr1, ';')
                     WITHIN GROUP (ORDER BY psp.party_id)
                     into l_ssup_type
             FROM APPS.pos_supp_prof_ext_b psp,
                  APPS.ego_attr_groups_v egv,
                  EGO.EGO_DATA_LEVEL_B edl
            WHERE     psp.party_id = i.party_id
                  and psp.PK2_VALUE = j.vendor_site_id
                  AND psp.d_ext_attr3 IS NULL
                  AND psp.ATTR_GROUP_ID = egv.ATTR_GROUP_ID
                  AND psp.DATA_LEVEL_ID = edl.DATA_LEVEL_ID
                  AND egv.attr_group_name = 'XXAH_Supplier_Site_Type'
                  AND edl.DATA_LEVEL_NAME = 'SUPP_ADDR_SITE_LEVEL';
        EXCEPTION
        WHEN OTHERS
             THEN
        fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
        fnd_file.put_line (fnd_file.LOG,
                               'Error at l_ssup_type '
                            || SQLCODE
                            || ' -ERROR- '
                            || SQLERRM
                           );
        fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
END;



  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,i.vendor_name||' | '||i.supplier_number||' | '||l_sup_type||' | '||j.VENDOR_SITE_CODE||' | '||l_ssup_type||' | '||l_short_code);
   END IF;

            END LOOP;
             FND_FILE.PUT_LINE(FND_FILE.LOG,'--END--');
        END LOOP;

END P_MAIN;


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
END P_UDA;

end XXAH_SUPP_SITE_UDA_PKG;

/
