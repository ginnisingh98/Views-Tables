--------------------------------------------------------
--  DDL for Package Body DDR_SETUP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_SETUP_UTIL" AS
/* $Header: ddrstpub.pls 120.2.12010000.7 2010/03/15 22:01:55 gglover ship $ */

  v_version CONSTANT VARCHAR2(30):= 'DDR seed verion 1.1';

  PROCEDURE Raise_Error (p_error_text IN VARCHAR2)
  IS
      l_error_text        VARCHAR2(240);
  BEGIN
      l_error_text := p_error_text;
      Raise_Application_Error(-20001,l_error_text);
  END Raise_Error;

  PROCEDURE setup(p_mfg_org VARCHAR2) IS
    v_org_exists NUMBER:=0;
  BEGIN
    setup_mfg_org(p_mfg_org);
    setup_ws_metadata;
    setup_lookup_type;
    setup_lookup(p_mfg_org);
    commit;
  END setup;

  PROCEDURE setup_mfg_org(p_mfg_org VARCHAR2) IS
    v_org_exists NUMBER:=0;
  BEGIN
    SELECT COUNT(*)
    INTO   v_org_exists
    FROM   DDR_R_ORG
    WHERE  mfg_org_cd = p_mfg_org
    AND    org_cd = p_mfg_org;

    IF v_org_exists = 0 THEN
      INSERT INTO ddr_r_org
      (mfg_org_cd, org_cd, org_typ, glbl_loc_id, glbl_loc_id_typ,
      created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
      VALUES
      (p_mfg_org, p_mfg_org, 'MFG', -1, -1,
       -1, SYSDATE, '-1', SYSDATE, '-1', v_version, SYSDATE, '-1', '-1');
    END IF;
  END  setup_mfg_org;

  PROCEDURE setup_lookup(p_mfg_org VARCHAR2) IS
  BEGIN
    --DELETE ddr_r_lkup_mst
    --WHERE  mfg_org_cd = p_mfg_org;

    MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'BSNS_UNIT_TYP' AND lkup.lkup_cd = 'CATALOGUE')
        WHEN NOT MATCHED THEN INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'BSNS_UNIT_TYP','CATALOGUE','Catalogue','Catalogue',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'BSNS_UNIT_TYP' AND lkup.lkup_cd = 'DC')
        WHEN NOT MATCHED THEN INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'BSNS_UNIT_TYP','DC','Distribution Centre','Distribution Centre',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'BSNS_UNIT_TYP' AND lkup.lkup_cd = 'RTLSTORE')
        WHEN NOT MATCHED THEN INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'BSNS_UNIT_TYP','RTLSTORE','Retail Store','Retail Store',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'BSNS_UNIT_TYP' AND lkup.lkup_cd = 'WAREHOUSE')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'BSNS_UNIT_TYP','WAREHOUSE','Warehouse','Warehouse',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'BSNS_UNIT_TYP' AND lkup.lkup_cd = 'WEBSTORE')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'BSNS_UNIT_TYP','WEBSTORE','Web Store','Web Store',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


       MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'BSNS_UNIT_TYP' AND lkup.lkup_cd = 'MFG')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'BSNS_UNIT_TYP','MFG','Manufacturer','Manufacturer',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'CHNL_TYP' AND lkup.lkup_cd = 'Direct')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'CHNL_TYP','Direct','Direct','Direct',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1001')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1001','NULL not allowed','This column value can not be NULL, please provide non NULL value',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1002')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1002','Invalid Value','No matching value found in setup, please provide valid column value',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1003')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1003','Zero Value','This column can not have zero values, please provide non zero value',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1004')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1004','Invalid item association','The item is not authorized to be sold from this Business Unit',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1005')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1005','Invalid Organization Type','Invalid Organization Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1006')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1006','Invalid Combination','Invalid Combination',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1007')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1007','Inactive Business Unit','The Business Unit is not operational',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1008')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1008','Time Alloc % Not Found','No record found for Time allocation in setup ',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1009')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1009','Org Alloc % Not Found','No record found for Organization  allocation in setup',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1010')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1010','No UOM conversion Found','No matching value found in the setup conversion table',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1011')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1011','No Exchange Rate found ','No matching value found in the setup exchange rate table',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1012')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1012','Inactive Item','The Item has expired',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1013')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ERR','DSR-1013','Clustrtyp and BU combination exists','Cluster type and BU combination already exists',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
          ON  (lkup.lkup_typ_cd = 'ERR' AND lkup.lkup_cd = 'DSR-1014')
        WHEN NOT MATCHED THEN
         INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
         VALUES (p_mfg_org,'ERR','DSR-1014','ItmClustrTyp and SKU combination exists','Item Cluster type and SKU Item combination already exists',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = '% RETURNS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','% RETURNS','% RETURNS','% Returns',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'CATEGORY MONETARY SALES')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','CATEGORY MONETARY SALES','CATEGORY MONETARY SALES','CATEGORY MONETARY SALES',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                    ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'DEDUCTION AMT')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','DEDUCTION AMT','Deduction Amount','Deduction Amount',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'DEDUCTION BALANCE')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','DEDUCTION BALANCE','Deduction Balance','Deduction Balance',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


       MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'DOLLAR SALE')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','DOLLAR SALE','Dollar Sale','Dollar Sale',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

         MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'GROSS MARGIN')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','GROSS MARGIN','Gross Margin','Gross Margin',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'IN STOCK %')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','IN STOCK %','IN STOCK %','In Stock % ',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                    ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'INVENTORY COVER MAX')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','INVENTORY COVER MAX','INVENTORY COVER MAX','Inventory Cover max ',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'INVENTORY COVER MIN')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','INVENTORY COVER MIN','INVENTORY COVER MIN','Inventory Cover min ',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                            ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'INVENTORY TURNS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','INVENTORY TURNS','Inventory Turns','Inventory Turns',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                                ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'INVOICE ACCURACY')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','INVOICE ACCURACY','Invoice Accuracy','Invoice Accuracy',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'ITEM DATA ACCURACY')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','ITEM DATA ACCURACY','Item Data Accuracy','Item Data Accuracy',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'ITEM DATA SYNCHRONIZATION')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','ITEM DATA SYNCHRONIZATION','Item Data Synchronization','Item Data Synchronization',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'LATE PAYMENT')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','LATE PAYMENT','Late Payment','Late Payment',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'MONETARY SALES')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','MONETARY SALES','MONETARY SALES','MONETARY SALES',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'NO OF DEDUCTIONS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','NO OF DEDUCTIONS','No. of Deductions','No. of Deductions',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'ON TIME DELIVERY DATE')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','ON TIME DELIVERY DATE','On Time Delivery - Date','On Time Delivery - Date',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'ON TIME DELIVERY TIME')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','ON TIME DELIVERY TIME','On Time Delivery - Time','On Time Delivery - Time',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'ON-HAND INVENTORY')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','ON-HAND INVENTORY','ON-HAND INVENTORY','On-Hand Inventory ',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'ORDER CHANGE %')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','ORDER CHANGE %','Order Change %','Order Change %',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'ORDER CYCLE TIME')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','ORDER CYCLE TIME','Order Cycle Time','Order Cycle Time',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'PAYEMENT DAYS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','PAYEMENT DAYS','Payment Days','Payment Days',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'PERFECT ORDER %')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','PERFECT ORDER %','Perfect Order %','Perfect Order %',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'RETAIL GROSS MARGIN (%)')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','RETAIL GROSS MARGIN (%)','RETAIL GROSS MARGIN (%)','Retail Gross Margin (%)',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

         MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'SALES FORECAST ACCURACY (%)')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','SALES FORECAST ACCURACY (%)','SALES FORECAST ACCURACY (%)','Sales Forecast Accuracy (%)',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'SERVICE LEVEL')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','SERVICE LEVEL','SERVICE LEVEL','Service Level ',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

         MERGE INTO ddr_r_lkup_mst lkup USING dual
         ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'SHARE OF MARKET')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','SHARE OF MARKET','Share of Market','Share of Market',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'SHOPPER PENETRATION')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','SHOPPER PENETRATION','Shopper Penetration','Shopper Penetration',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'UNIT SALE')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','UNIT SALE','Unit Sale','Unit Sale',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE' AND lkup.lkup_cd = 'UNSALEABLES')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE','UNSALEABLES','Unsaleables','Unsaleables',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE_TYP' AND lkup.lkup_cd = 'EXTERNAL')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE_TYP','EXTERNAL','External Measure','External Measure',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

         MERGE INTO ddr_r_lkup_mst lkup USING dual
         ON  (lkup.lkup_typ_cd = 'MEASURE_TYP' AND lkup.lkup_cd = 'GOAL')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE_TYP','GOAL','Goal','Goal',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MEASURE_TYP' AND lkup.lkup_cd = 'THRESHOLD')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MEASURE_TYP','THRESHOLD','Threshold','Threshold',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MFG_ITEM_LVL' AND lkup.lkup_cd = 'CLASS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MFG_ITEM_LVL','CLASS','Item Class / Category','Item Class / Category',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'MFG_ITEM_LVL' AND lkup.lkup_cd = 'COMPANY')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MFG_ITEM_LVL','COMPANY','Item Company','Item Company',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

         MERGE INTO ddr_r_lkup_mst lkup USING dual
                ON  (lkup.lkup_typ_cd = 'MFG_ITEM_LVL' AND lkup.lkup_cd = 'DIVISION')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MFG_ITEM_LVL','DIVISION','Item Division','Item Division',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MFG_ITEM_LVL' AND lkup.lkup_cd = 'GROUP')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MFG_ITEM_LVL','GROUP','Item Group','Item Group',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MFG_ITEM_LVL' AND lkup.lkup_cd = 'ITEM')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MFG_ITEM_LVL','ITEM','Item','Item',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MFG_ITEM_LVL' AND lkup.lkup_cd = 'NA')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MFG_ITEM_LVL','NA','Not Applicable','Not Applicable',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'MFG_ITEM_LVL' AND lkup.lkup_cd = 'SKU')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MFG_ITEM_LVL','SKU','SKU','SKU',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'MFG_ITEM_LVL' AND lkup.lkup_cd = 'SUBCLASS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'MFG_ITEM_LVL','SUBCLASS','Item Sub-Class','Item Sub-Class',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ORG_LVL' AND lkup.lkup_cd = 'AREA')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_LVL','AREA','Area','Area',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'ORG_LVL' AND lkup.lkup_cd = 'BU')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_LVL','BU','Business Unit','Business Unit',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                ON  (lkup.lkup_typ_cd = 'ORG_LVL' AND lkup.lkup_cd = 'CHAIN')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_LVL','CHAIN','Chain','Chain',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                    ON  (lkup.lkup_typ_cd = 'ORG_LVL' AND lkup.lkup_cd = 'DISTRICT')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_LVL','DISTRICT','District','District',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ORG_LVL' AND lkup.lkup_cd = 'NA')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_LVL','NA','Not Applicable','Not Applicable',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ORG_LVL' AND lkup.lkup_cd = 'ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_LVL','ORGANIZATION','Organization','Organization',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ORG_LVL' AND lkup.lkup_cd = 'REGION')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_LVL','REGION','Region','Region',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ORG_TYP' AND lkup.lkup_cd = 'CMP')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_TYP','CMP','Competitor','Competitor',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ORG_TYP' AND lkup.lkup_cd = 'MFG')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_TYP','MFG','Manufacturer','Manufacturer',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ORG_TYP' AND lkup.lkup_cd = 'RTL')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ORG_TYP','RTL','Retailer','Retailer',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ORG_TYP' AND lkup.lkup_cd = 'DST')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
	VALUES (p_mfg_org,'ORG_TYP','DST','Distributor','Distributor',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'CLASS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','CLASS','Item Class / Category','Item Class / Category',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'COMPANY')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','COMPANY','Item Company','Item Company',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'DEPARTMENT')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','DEPARTMENT','Item Department','Item Department',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'DIVISION')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','DIVISION','Item Division','Item Division',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'GROUP')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','GROUP','Item Group','Item Group',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'ITEM')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','ITEM','Item','Item',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'NA')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','NA','Not Applicable','Not Applicable',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'SKU')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','SKU','SKU','SKU',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'RTL_ITEM_LVL' AND lkup.lkup_cd = 'SUBCLASS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'RTL_ITEM_LVL','SUBCLASS','Item Sub-Class','Item Sub-Class',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'DISCOVERY_MODE')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','DISCOVERY_MODE','N','Discovery mode for POS Data: Possible values are N for Strict Mode and Y for Item Discovery Mode',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'MAX_OUTPUT_RECORDS')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','MAX_OUTPUT_RECORDS','20000000','Maximum records that can be returned to the calling application through web services',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'MAX_REC_PER_FILE')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','MAX_REC_PER_FILE','200000','Maximum number of records per output file created by web service',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'OUTPUT_DIR_PATH')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','OUTPUT_DIR_PATH',NULL,'Directory for web service output files',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'PERFORM_DUP_CHECK')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','PERFORM_DUP_CHECK','N','Duplicate record check for Fact data: Possible values are Y to perform check for duplicate records and N to skip check for duplicate records',v_version
               ,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

         MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RUN_TYPE_FACT')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RUN_TYPE_FACT','P','Data Load Mode for Fact data: Possible values are P for Partial data load, S for Simulation and A for All or None data load',v_version,SYSDATE,'-1','-1','-1'
               ,SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RUN_TYP_REF')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RUN_TYP_REF','P','Data Load Mode for Reference data: Possible values are P for Partial Load and S for Simulation Load',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'STAGE_TO_TARGET_VALIDATION')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','STAGE_TO_TARGET_VALIDATION','N','Dangling key check for data in staging tables: Possible values are Y to perform dangling key validation, N to skip dangling key validation',v_version
               ,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'DDR_WS_FILE_PATH')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','DDR_WS_FILE_PATH',NULL,'Complete directory path for output files location',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'DFLT_GLBL_LOC_ID_TYP')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','DFLT_GLBL_LOC_ID_TYP',NULL,'Default Global Location ID Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'DFLT_ADDR_TYP_CD')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','DFLT_ADDR_TYP_CD',NULL,'Default Address Type Code',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'DFLT_PRMRY_CRNCY_CD')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','DFLT_PRMRY_CRNCY_CD',NULL,'Default Primary Currency Code',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'DFLT_SRC_SYS_IDNT')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','DFLT_SRC_SYS_IDNT','-1','Default Source System Identifier',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'DFLT_BSNS_UNIT_TYP')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','DFLT_BSNS_UNIT_TYP',NULL,'Default Business Unit Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'TIME_LVL' AND lkup.lkup_cd = 'DAY')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'TIME_LVL','DAY','Day','Day',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'TIME_LVL' AND lkup.lkup_cd = 'MONTH')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'TIME_LVL','MONTH','Month','Month',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'TIME_LVL' AND lkup.lkup_cd = 'NA')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'TIME_LVL','NA','Not Applicable','Not Applicable',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

         MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'TIME_LVL' AND lkup.lkup_cd = 'QUARTER')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'TIME_LVL','QUARTER','Quarter','Quarter',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'TIME_LVL' AND lkup.lkup_cd = 'WEEK')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'TIME_LVL','WEEK','Week','Week',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

         MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'TIME_LVL' AND lkup.lkup_cd = 'YEAR')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'TIME_LVL','YEAR','Year','Year',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                ON  (lkup.lkup_typ_cd = 'PRMTN_FLAG' AND lkup.lkup_cd = 'Y')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'PRMTN_FLAG','Y','Promotion','Promotion Sales',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
                    ON  (lkup.lkup_typ_cd = 'PRMTN_FLAG' AND lkup.lkup_cd = 'N')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'PRMTN_FLAG','N','Regular','Non Promotion Sales',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RETL_DSR_SRC_DIR')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RETL_DSR_SRC_DIR',NULL,'Directory location for the data file',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RETL_DSR_SRC_FILENAME')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RETL_DSR_SRC_FILENAME',NULL,'Name of the data file',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RETL_DSR_SUCCESS_DIR')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RETL_DSR_SUCCESS_DIR',NULL,'Archive directory for data file after successful data load',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RETL_DSR_FAILED_DIR')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RETL_DSR_FAILED_DIR',NULL,'Archive directory for data file if data load fails',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RETL_DSR_TO_ADDR')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RETL_DSR_TO_ADDR',NULL,'To email address for process notifications',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RETL_DSR_FM_ADDR')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RETL_DSR_FM_ADDR',NULL,'From email address for process notifications',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
            ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RETL_DSR_MAIL_SERVER')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RETL_DSR_MAIL_SERVER',NULL,'Email server for process notifications',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'SYS_PARAM' AND lkup.lkup_cd = 'RETL_DSR_CLASS_DIR')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'SYS_PARAM','RETL_DSR_CLASS_DIR',NULL,'Directory location for java class files used for RMS integration',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ITM_TYP' AND lkup.lkup_cd = 'M')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ITM_TYP','M','Manufacturer Item','Item from manufacturer item hierarchy',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'ITM_TYP' AND lkup.lkup_cd = 'C')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'ITM_TYP','C','Competitor Item','Item from competitor item hierarchy',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'EXCPTN_TYP' AND lkup.lkup_cd = 'FCSTACC')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'EXCPTN_TYP','FCSTACC','Sales Forecast Accuracy','Sales Forecast Accuracy',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'EXCPTN_TYP' AND lkup.lkup_cd = 'IFPL')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'EXCPTN_TYP','IFPL','In-flight Promotional Lift','In-flight Promotional Lift',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'EXCPTN_TYP' AND lkup.lkup_cd = 'NPISALES')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'EXCPTN_TYP','NPISALES','New Item Not Selling','New Item Not Selling',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'EXCPTN_TYP' AND lkup.lkup_cd = 'OOSIM')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'EXCPTN_TYP','OOSIM','Out of Stock Imputed','Out of Stock Imputed',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'EXCPTN_TYP' AND lkup.lkup_cd = 'OOSOH')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'EXCPTN_TYP','OOSOH','Out of Stock On Hand','Out of Stock On Hand',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'EXCPTN_TYP' AND lkup.lkup_cd = 'OVRSTCK')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'EXCPTN_TYP','OVRSTCK','Overstock','Overstock',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'EXCPTN_TYP' AND lkup.lkup_cd = 'PPD')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'EXCPTN_TYP','PPD','Promotional Price','Promotional Price',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'EXCPTN_TYP' AND lkup.lkup_cd = 'REORDR')
        WHEN NOT MATCHED THEN
        INSERT  (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES (p_mfg_org,'EXCPTN_TYP','REORDR','Reorder Point','Reorder Point',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

				MERGE INTO ddr_r_lkup_mst lkup USING dual
				ON  (lkup.lkup_typ_cd = 'FRCST_TYP' AND lkup.lkup_cd = 'BASE')
				WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'FRCST_TYP','BASE','BASE','BASE',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

				MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'FRCST_TYP' AND lkup.lkup_cd = 'PROMO')
        WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'FRCST_TYP','PROMO','PROMO','PROMO',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'FRCST_TYP' AND lkup.lkup_cd = 'TOTAL')
        WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'FRCST_TYP','TOTAL','TOTAL','TOTAL',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'FRCST_PURP' AND lkup.lkup_cd = 'SALES')
        WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'FRCST_PURP','SALES','SALES','SALES',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

				MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'FRCST_PURP' AND lkup.lkup_cd = 'ORDERS')
        WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'FRCST_PURP','ORDERS','ORDERS','ORDERS',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
				ON  (lkup.lkup_typ_cd = 'FRCST_PURP' AND lkup.lkup_cd = 'SHIPMENT')
        WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'FRCST_PURP','SHIPMENT','SHIPMENT','SHIPMENT',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

				MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'FRCST_PURP' AND lkup.lkup_cd = 'RECEIPTS')
        WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'FRCST_PURP','RECEIPTS','RECEIPTS','RECEIPTS',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

				MERGE INTO ddr_r_lkup_mst lkup USING dual
				ON  (lkup.lkup_typ_cd = 'SLS_TYP' AND lkup.lkup_cd = '1')
				WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'SLS_TYP','1','Manufacturer Promoted','POS Sales that were identified by the customer as promotional sales and have been associated to a manufacturer promotion',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

				MERGE INTO ddr_r_lkup_mst lkup USING dual
				ON  (lkup.lkup_typ_cd = 'SLS_TYP' AND lkup.lkup_cd = '2')
				WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'SLS_TYP','2','Manufacturer Non Compliant',
				        'POS Sales that were identified by the customer as regular (non-promotional) sales but according to the manufacturer promotion plan criteria should have been promoted',
				        v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

				MERGE INTO ddr_r_lkup_mst lkup USING dual
				ON  (lkup.lkup_typ_cd = 'SLS_TYP' AND lkup.lkup_cd = '3')
				WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'SLS_TYP','3','Other Promoted','POS Sales that were identified by the customer as promotional sales but there is no associated manufacturer promotion',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

				MERGE INTO ddr_r_lkup_mst lkup USING dual
				ON  (lkup.lkup_typ_cd = 'SLS_TYP' AND lkup.lkup_cd = '4')
				WHEN NOT MATCHED THEN
				INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
				VALUES (p_mfg_org,'SLS_TYP','4','Regular','POS Sales that were identified by the customer as regular (non-promotional) sales and there is no associated manufacturer promotion',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_TYPE' AND lkup.lkup_cd = 'MFG_ITEM')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_TYPE','MFG_ITEM','Manufacturer Item Hierarchy','Manufacturer Item Hierarchy',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_TYPE' AND lkup.lkup_cd = 'RTL_ITEM')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_TYPE','RTL_ITEM','Retailer Item Hierarchy','Retailer Item Hierarchy',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_TYPE' AND lkup.lkup_cd = 'ORG')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_TYPE','ORG','Organization Hierarchy','Organization Hierarchy',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'CMPNY')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','CMPNY','Company','Company',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'DIV')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','DIV','Division','Division',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'CLASS')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','CLASS','Class','Class',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'SBC')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','SBC','Sub-Class','Sub-Class',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'GRP')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','GRP','Group','Group',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'ITEM')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','ITEM','Item','Item',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'DEPT')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','DEPT','Department','Department',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'CHAIN')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','CHAIN','Chain','Chain',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'AREA')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','AREA','Area','Area',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'RGN')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','RGN','Region','Region',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_mst lkup USING dual
        ON  (lkup.lkup_typ_cd = 'HCHY_LVL' AND lkup.lkup_cd = 'DSTRCT')
        WHEN NOT MATCHED THEN
        INSERT (mfg_org_cd,lkup_typ_cd,lkup_cd,lkup_name,lkup_desc,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date
                ,last_update_login)
        VALUES (p_mfg_org,'HCHY_LVL','DSTRCT','District','District',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


      END setup_lookup;

      PROCEDURE setup_ws_metadata IS
      BEGIN
        --DELETE ddr_ws_metadata;
        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='MFG_CLASS_CD' AND hrchy_lvl_name='ITEM')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('MFG_CLASS_CD', 'ITEM', 'Item Class', 4, NULL,
        'Y', 'Y', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='MFG_SBC_CD' AND hrchy_lvl_name='ITEM')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('MFG_SBC_CD', 'ITEM', 'Item SubClass', 3, NULL,
        'Y', 'Y', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
            ON (ws.hrchy_lvl_cd='MFG_ITEM_NBR' AND hrchy_lvl_name='ITEM')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('MFG_ITEM_NBR', 'ITEM', 'Item Number', 2, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='MFG_SKU_ITEM_NBR' AND hrchy_lvl_name='ITEM')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('MFG_SKU_ITEM_NBR', 'ITEM', 'Sku Item Number', 1, NULL,
        'Y', 'Y', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='MFG_DIV_CD' AND hrchy_lvl_name='ITEM')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('MFG_DIV_CD', 'ITEM', 'Item Division', 6, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='MFG_GRP_CD' AND hrchy_lvl_name='ITEM')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('MFG_GRP_CD', 'ITEM', 'Item Group', 5, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CLSTR_CD' AND hrchy_lvl_name='ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CLSTR_CD', 'ORGANIZATION', 'Organization Retail Cluster', 7, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='ORG_CD' AND hrchy_lvl_name='ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('ORG_CD', 'ORGANIZATION', 'Organization Retail Org', 6, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CHAIN_CD' AND hrchy_lvl_name='ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CHAIN_CD', 'ORGANIZATION', 'Organization Retail Chain', 5, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='AREA_CD' AND hrchy_lvl_name='ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('AREA_CD', 'ORGANIZATION', 'Organization Retail Area', 4, NULL,
        'N', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='RGN_CD' AND hrchy_lvl_name='ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('RGN_CD', 'ORGANIZATION', 'Organization Retail Region', 3, NULL,
        'N', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='DSTRCT_CD' AND hrchy_lvl_name='ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('DSTRCT_CD', 'ORGANIZATION', 'Organization Retail District', 2, NULL,
        'N', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='BSNS_UNIT_CD' AND hrchy_lvl_name='ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('BSNS_UNIT_CD', 'ORGANIZATION', 'Organization Retail Bus. Unit', 1, NULL,
        'N', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='INV_LOC_CD' AND hrchy_lvl_name='ORGANIZATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('INV_LOC_CD', 'ORGANIZATION', 'Organization Inventory Level', 0, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CNTRY_CD' AND hrchy_lvl_name='LOCATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CNTRY_CD', 'LOCATION', 'Location Country', 3, NULL,
        'N', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='STATE_CD' AND hrchy_lvl_name='LOCATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('STATE_CD', 'LOCATION', 'Location State', 2, NULL,
        'N', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CITY_CD' AND hrchy_lvl_name='LOCATION')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CITY_CD', 'LOCATION', 'Location City', 1, NULL,
        'N', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CLNDR_YR_CD' AND hrchy_lvl_name='GREGORIAN TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CLNDR_YR_CD', 'GREGORIAN TIME', 'Calander Year', 5, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CLNDR_QTR_CD' AND hrchy_lvl_name='GREGORIAN TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CLNDR_QTR_CD', 'GREGORIAN TIME', 'Calander Quarter', 4, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CLNDR_MNTH_CD' AND hrchy_lvl_name='GREGORIAN TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CLNDR_MNTH_CD', 'GREGORIAN TIME', 'Calander Month', 3, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CLNDR_WK_CD' AND hrchy_lvl_name='GREGORIAN TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CLNDR_WK_CD', 'GREGORIAN TIME', 'Calander Week', 2, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='CLNDR_DAY_CD' AND hrchy_lvl_name='GREGORIAN TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('CLNDR_DAY_CD', 'GREGORIAN TIME', 'Calander Day', 1, NULL,
        'Y', 'Y', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='BSNS_YR_CD' AND hrchy_lvl_name='BUSINESS TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('BSNS_YR_CD', 'BUSINESS TIME', 'Business Year', 5, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
            ON (ws.hrchy_lvl_cd='BSNS_QTR_CD' AND hrchy_lvl_name='BUSINESS TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('BSNS_QTR_CD', 'BUSINESS TIME', 'Business Quarter', 4, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='BSNS_MNTH_CD' AND hrchy_lvl_name='BUSINESS TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('BSNS_MNTH_CD', 'BUSINESS TIME', 'Business Month', 3, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
            ON (ws.hrchy_lvl_cd='BSNS_DAY_CD' AND hrchy_lvl_name='BUSINESS TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
       ('BSNS_DAY_CD', 'BUSINESS TIME', 'Business Day', 1, NULL,
        'Y', 'N', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');

        MERGE INTO ddr_ws_metadata ws USING dual
        ON (ws.hrchy_lvl_cd='BSNS_WK_CD' AND hrchy_lvl_name='BUSINESS TIME')
        WHEN NOT MATCHED THEN
        INSERT
        (hrchy_lvl_cd, hrchy_lvl_name, hrchy_lvl_desc, lvl_rnk, lvl_grp, input, output, created_by, creation_date, last_updated_by, last_update_date, last_update_login, src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr)
        VALUES
        ('BSNS_WK_CD', 'BUSINESS TIME', 'Business Week', 2, 1,
        'Y', 'Y', -1, SYSDATE, '-1',
        SYSDATE, '-1', v_version, SYSDATE, '-1',
        '-1');
      END setup_ws_metadata;

      PROCEDURE setup_lookup_type IS
      BEGIN
        --DELETE ddr_r_lkup_typ;
        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='ADDR_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('ADDR_TYP','Address Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='BRND')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('BRND','Item Brand',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='BSNS_UNIT_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('BSNS_UNIT_TYP','Business Unit Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='CHNL_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('CHNL_TYP','Channel Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='COATING')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('COATING','Coating Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='COLOR')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('COLOR','Color',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='DYE')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('DYE','Dye',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='ERR')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('ERR','Error',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='FABRIC')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('FABRIC','Fabric',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='FIBER')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('FIBER','Fiber',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='GIID_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('GIID_TYP','GIID Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='GLID_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('GLID_TYP','GLID Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='MEASURE')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('MEASURE','Measure Name',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='MEASURE_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('MEASURE_TYP','Measure Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='MFG_ITEM_LVL')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('MFG_ITEM_LVL','Mfg Item Level Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='ORG_LVL')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('ORG_LVL','Organization Level',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='ORG_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('ORG_TYP','Organization Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='RPLNSHMNT_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('RPLNSHMNT_TYP','Replenishment Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='RTL_ITEM_LVL')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('RTL_ITEM_LVL','Retailer Item Level',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='RTL_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('RTL_TYP','Retail Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='SKU_ITEM_STYLE')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('SKU_ITEM_STYLE','SKU Item Style',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='SKU_ITEM_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('SKU_ITEM_TYP','SKU Item Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='SLNG_LOC_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('SLNG_LOC_TYP','Selling Location Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='STCK_ITEM_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('STCK_ITEM_TYP','Stock Item Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='SYS_PARAM')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('SYS_PARAM','System Parameter',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='SZ_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('SZ_TYP','Size Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='TIME_LVL')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('TIME_LVL','Time Level',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='VRTY_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('VRTY_TYP','Variety Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='WEAVE')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('WEAVE','Weave Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='PRMTN_FLAG')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('PRMTN_FLAG','Promotion Flag',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='MKT_AREA_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('MKT_AREA_TYP','Market Area Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='ITM_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('ITM_TYP','Item Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='EXCPTN_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('EXCPTN_TYP','Exception Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='STR_ACV_RANGE')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('STR_ACV_RANGE','Store ACV Range',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='CMPNY_SIZE')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('CMPNY_SIZE','Company Size',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

		    MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='SUB_CHNL_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('SUB_CHNL_TYP','Sub Channel Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='SRC_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('SRC_TYP','Source Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='MSR_SET')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('MSR_SET','Measure Set',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='STR_CLSTR_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('STR_CLSTR_TYP','Store Cluster Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='FRCST_PURP')
        WHEN NOT MATCHED THEN
        INSERT (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
	      VALUES('FRCST_PURP','Forecast Purpose',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

	      MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='FRCST_TYP')
        WHEN NOT MATCHED THEN
	      INSERT (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
	      VALUES('FRCST_TYP','Forecast Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');


				MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='SLS_TYP')
        WHEN NOT MATCHED THEN
        INSERT
        (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('SLS_TYP','Sales Type',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='HCHY_TYPE')
        WHEN NOT MATCHED THEN
        INSERT (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('HCHY_TYPE','Additional Attributed Hierarchy Types',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

        MERGE INTO ddr_r_lkup_typ lkuptyp USING dual
        ON(lkup_typ_cd='HCHY_LVL')
        WHEN NOT MATCHED THEN
        INSERT (lkup_typ_cd,lkup_typ_name,src_sys_idnt,src_sys_dt,crtd_by_dsr,last_updt_by_dsr,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
        VALUES ('HCHY_LVL','Additional Attributed Hierarchy Levels',v_version,SYSDATE,'-1','-1','-1',SYSDATE,'-1',SYSDATE,'-1');

		END setup_lookup_type;
    END ddr_setup_util;

/
