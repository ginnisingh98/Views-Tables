--------------------------------------------------------
--  DDL for Package Body XXAH_SUPP_LC_UDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SUPP_LC_UDA_PKG" as
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_SUPP_LC_UDA_PKG
   * DESCRIPTION       : PACKAGE TO NFR Supplier Leaf Commodity update
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 20-AUG-2018       1.0       Menaka    Initial
   ****************************************************************************/
--gv_request_id                     fnd_concurrent_requests.request_id%TYPE:= Fnd_Global.conc_request_id;
gv_commit_flag                    VARCHAR2(1);
gv_api_msg                        VARCHAR2(2000);


PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER)
IS

   p_site_id NUMBER;
    l_leaf_commodity varchar2(1000);
     lc_new_lc_value  varchar2(1000);

CURSOR c_lc 
IS
select rowid, new_Site_Leaf_commodity,site_id from XXAH_SUPP_NFR_UPDATE a where new_Site_Leaf_commodity is not null  and created_by=99  ;

/*CURSOR c_new_lc
IS
select rowid, new_Site_Leaf_commodity,site_id from XXAH_SUPP_NFR_UPDATE a where new_Site_Leaf_commodity is not null and lc_flag is null and site_id=531816;
*/
cursor c_lc_details (p_site_id IN number)
is
select apss.vendor_site_id,aps.party_id,hps.party_site_id
from ap_suppliers aps,ap_supplier_sites_all apss,hz_party_sites hps
where aps.vendor_id=apss.vendor_id
and hps.party_id=aps.party_id
and apss.party_site_id = hps.party_site_id
and apss.vendor_site_id=p_site_id;


BEGIN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside Begin:');
    fnd_global.Apps_initialize (user_id => fnd_global.user_id,
                                resp_id => fnd_global.resp_id,
                                resp_appl_id => fnd_global.resp_appl_id);

                
--egoattributeeo.attr_group_name = 'XXAH_COUPA_CONTENT'
--egoattributeeo.attr_display_name = 'Leaf Commodity';

    FOR i IN  c_lc 
        LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside first loop:'||i.site_id);
 for j in c_lc_details(i.site_id)
 loop 
  lc_new_lc_value := null;
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Inside second loop Before trimming i.new_Site_Leaf_commodity:'||i.new_Site_Leaf_commodity||'--'||lc_new_lc_value);
        lc_new_lc_value := trim( i.new_Site_Leaf_commodity);
             FND_FILE.PUT_LINE(FND_FILE.LOG,' After trimming i.new_Site_Leaf_commodity:'||lc_new_lc_value );
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Before calling procedure:'||j.party_id||'-'||j.party_site_id||'-'||j.vendor_site_id||'-'||lc_new_lc_value);
 --IF i.leaf_commodity IS NOT NULL THEN
        BEGIN
        SELECT flex_value
        INTO   l_leaf_commodity
        FROM   fnd_flex_values_vl ffv
              ,fnd_flex_value_sets ffvs
        WHERE  ffvs.flex_value_set_id = ffv.flex_value_set_id
        AND    flex_value_set_name    = 'XXAH_LEAF_COMMODITY'
        AND    flex_value     = lc_new_lc_value
        AND    ffv.enabled_flag       = 'Y'
        AND    TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) and nvl(end_date_active,to_date('31-DEC-4721','DD-MON-YYYY'));

       -- IF l_leaf_commodity IS NULL THEN
         --                       l_error_flag := 'Y';
            --            l_error_log := l_error_log||'//Invalid XXAH_LEAF_COMM: ';
      --  END IF;
      EXCEPTION WHEN OTHERS THEN
      null;
                        --l_error_flag := 'Y';
                       -- l_error_log := l_error_log||'//Invalid XXAH_LEAF_COMM: '||SQLCODE||'-'||SQLERRM;
      END;
  
    FND_FILE.PUT_LINE(FND_FILE.LOG,' l_leaf_commodity:'|| l_leaf_commodity);          
                    p_uda (
               j.PARTY_ID,
                      'XXAH_COUPA_CONTENT',
                      'Leaf Commodity',
                      lc_new_lc_value ,
                      'SUPP_ADDR_SITE_LEVEL',
                      j.party_site_id,
                      j.vendor_site_id
                     );


 /* If i.leaf_commodity = l_leaf_commodity then
                       p_uda (
               i.ORA_PARTY_ID,
                      'XXAH_LEAF_COMM',
                      'Leaf Commodity',
                      i.leaf_commodity,
                      'SUPP_ADDR_SITE_LEVEL',
                      i.ora_party_site_id,
                      i.ora_vendor_site_id
                     );
else 
            l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid XXAH_LEAF_COMM: ';
                        end if;*/
        END LOOP;
        end loop;
--create new UDA started
/*begin


    FOR i IN  c_new_lc 
        LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside creare uda loop:'||i.site_id);
 for j in c_lc_details(i.site_id)
 loop 
  lc_new_lc_value := null;
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Inside second loop Before trimming i.new_Site_Leaf_commodity:'||i.new_Site_Leaf_commodity||'--'||lc_new_lc_value);
        lc_new_lc_value := trim( i.new_Site_Leaf_commodity);
             FND_FILE.PUT_LINE(FND_FILE.LOG,' After trimming i.new_Site_Leaf_commodity:'||lc_new_lc_value );
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Before calling procedure:'||j.party_id||'-'||j.party_site_id||'-'||j.vendor_site_id||'-'||lc_new_lc_value);
 --IF i.leaf_commodity IS NOT NULL THEN
        BEGIN
        SELECT flex_value
        INTO   l_leaf_commodity
        FROM   fnd_flex_values_vl ffv
              ,fnd_flex_value_sets ffvs
        WHERE  ffvs.flex_value_set_id = ffv.flex_value_set_id
        AND    flex_value_set_name    = 'XXAH_LEAF_COMMODITY'
        AND    flex_value     = lc_new_lc_value
        AND    ffv.enabled_flag       = 'Y'
        AND    TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) and nvl(end_date_active,to_date('31-DEC-4721','DD-MON-YYYY'));

      EXCEPTION WHEN OTHERS THEN
      null;
                        --l_error_flag := 'Y';
                       -- l_error_log := l_error_log||'//Invalid XXAH_LEAF_COMM: '||SQLCODE||'-'||SQLERRM;
      END;
  
    FND_FILE.PUT_LINE(FND_FILE.LOG,' l_leaf_commodity * calling procedure:'|| l_leaf_commodity);          
                     
                        P_CRE_UDA (j.PARTY_ID,
                      'XXAH_COUPA_CONTENT',
                      'Leaf Commodity',
                       lc_new_lc_value ,
                      'SUPP_ADDR_SITE_LEVEL',
                     j.party_site_id,
                      j.vendor_site_id
                     );


 
        END LOOP;
        end loop;

exception when others then
  FND_FILE.PUT_LINE(FND_FILE.LOG,'error while creating UDA');
end    ;  */
        p_report;

END P_MAIN;


PROCEDURE P_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
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
  FND_FILE.PUT_LINE(FND_FILE.LOG,'inside procedure:');
   fnd_global.apps_initialize (user_id           => fnd_global.user_id,                                                                                                                                    
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );
l_extension_id    := NULL;
l_c_ext_attr1    := NULL;
l_c_ext_attr2    := NULL;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'bedin stmt UDA:');
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
           fnd_file.put_line(fnd_file.LOG,'lv_attr_group_id '||lv_attr_group_id||' lv_attr_name '||lv_attr_name);
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

fnd_file.put_line(fnd_file.LOG,'Before statement111:::::'||lv_attr_group_name);

   lv_pk_column_values.EXTEND (1);
   lv_pk_column_values (1) :=
                         ego_col_name_value_pair_obj ('PARTY_ID', ln_party_id);
   lv_class_code.EXTEND (1);
   lv_class_code (1) :=
                ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE');


   IF lv_attr_group_name = 'XXAH_COUPA_CONTENT'
   THEN
   fnd_file.put_line(fnd_file.LOG,'Inside statement ln_attr_value_str1'||ln_attr_value_str1);
      fnd_file.put_line(fnd_file.LOG,'data Level'||ln_attr_value_str1||p_data_level||p_data_level_1||p_data_level_2);
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                     attr_name                 => 'XXAH_LEAF_COMM',
                                   attr_value_str            => ln_attr_value_str1,
                                     attr_value_num            => null,--ln_attr_num,
                                     attr_value_date           => null,--ldt_attr_date,
                                     attr_disp_value           => NULL,
                                     attr_unit_of_measure      => NULL,
                                     user_row_identifier       => 1
                                  )
            );
   END IF;
   fnd_file.put_line(fnd_file.LOG,'data Level'||ln_attr_value_str1||p_data_level||p_data_level_1||p_data_level_2);
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

   IF lv_return_status = fnd_api.g_ret_sts_success
   THEN
        commit;
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Sucess message '||lv_return_status);
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'UDA updated '|| lv_attr_group_name||p_data_level_2);
                
         update XXAH_SUPP_NFR_UPDATE set LC_FLAG= 'P' where site_id=p_data_level_2;
                 
   ELSE
      fnd_file.put_line (fnd_file.LOG,'Error Message UDA Data  : ' || lv_msg_data);
 begin
  FND_FILE.PUT_LINE(FND_FILE.LOG,'UDA updated '|| lv_attr_group_name||p_data_level_2);
 update XXAH_SUPP_NFR_UPDATE set LC_FLAG= 'E',LC_ERROR= lv_msg_data where site_id=p_data_level_2;
 commit;
  fnd_file.put_line (fnd_file.LOG,'Error Message UDA Data  : ' || lv_msg_data);
exception
when others then
 fnd_file.put_line (fnd_file.LOG,'Error Message UDA Data  : ' || SQLCODE||SQLERRM);
end;
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

PROCEDURE P_CRE_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
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
FND_FILE.PUT_LINE(FND_FILE.LOG,'inside create UDA');
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
                                  )         );
   END IF;

      fnd_file.put_line (fnd_file.LOG,'p_data_level_1 '||p_data_level_1||' p_data_level_2'||p_data_level_2||' ln_party_id '||ln_party_id);

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
        FND_FILE.PUT_LINE(FND_FILE.LOG,'UDA created '|| ln_party_id);
   ELSE
      fnd_file.put_line (fnd_file.LOG,'Error Message Count : ' || ln_msg_count);
      fnd_file.put_line (fnd_file.LOG,'Error Message Data  : ' || lv_msg_data);
      fnd_file.put_line (fnd_file.LOG,'Error Code          : ' || ln_errorcode);
      fnd_file.put_line (fnd_file.LOG,'Entering Error Loop ');

      FOR i IN 1 .. ln_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => lv_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (lv_msg_data);
         fnd_file.put_line (fnd_file.LOG,
                            'Inside Error Loop P_UDA : ' || i || ', ' || lv_msg_data
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
END P_CRE_UDA;

PROCEDURE p_report
   IS
      CURSOR c_rec 
      IS
           SELECT *
             FROM XXAH_SUPP_NFR_UPDATE where LC_FLAG in ('P','E','N') and  created_by=99  ORDER BY LC_FLAG DESC;
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
         IF r_rec.LC_FLAG = 'P'
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
                  'SR NO | Vendor Number | Vendor Name |vendor_site_code|Leaf COMM|New Leaf Comm');
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
               || r_rec.SUPPLIER_NAME
               || ' | '
               || r_rec.site_id
               || ' | '
               || r_rec.SITE_LEAF_COMMODITY
               || ' | '
               || r_rec.NEW_SITE_LEAF_COMMODITY
               );
         END IF;

         IF r_rec.LC_FLAG = 'E'
         THEN
            IF l_fail_header = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Failed Record');
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                'SR NO | Vendor Number | Vendor Name |vendor_site_code|Leaf COMM|New Leaf Comm|LC_ERROR');
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
               || r_rec.supplier_number
               || ' | '
               || r_rec.SUPPLIER_NAME
               || ' | '
               || r_rec.site_id
               || ' | '
               || r_rec.SITE_LEAF_COMMODITY
               || ' | '
               || r_rec.NEW_SITE_LEAF_COMMODITY
               || ' | '
               || r_rec.LC_ERROR
               );
         -- FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
         END IF;

         IF r_rec.LC_FLAG is null and  r_rec.LC_FLAG = 'N'
         THEN
            IF l_nobpa = 'N'
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                  '+---------------------------------------------------------------------------+');
          FND_FILE.PUT_LINE (
                  FND_FILE.OUTPUT,
                'SR NO | Vendor Number | Vendor Name |vendor_site_code|Leaf COMM|New Leaf Comm');
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
               || r_rec.supplier_number
               || ' | '
               || r_rec.SUPPLIER_NAME
               || ' | '
               || r_rec.site_id
               || ' | '
               || r_rec.lc_error);
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
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Failed Records => ' || l_fcnt);
      FND_FILE.PUT_LINE (
         FND_FILE.OUTPUT,
         '+---------------------------------------------------------------------------+');
   END p_report;


end XXAH_SUPP_LC_UDA_PKG;

/
